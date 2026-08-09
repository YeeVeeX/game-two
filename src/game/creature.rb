require "game/grid_walker"

module Game
  # The unified actor: ANY creature on the grid — pack member or human —
  # is a Creature with a kit (all numbers from data), a faction, and a body.
  # Controllers (possessed or AI) drive it through public verbs; the World
  # resolves combat by reading the ATTACKER's kit (never a player path).
  class Creature
    SIZE = 28

    RING = [[0, -1], [1, 0], [0, 1], [-1, 0], [1, -1], [1, 1], [-1, 1], [-1, -1]].freeze

    attr_reader :hp, :max_hp, :kit, :kit_name, :faction, :name, :walker,
                :facing, :attack_state, :stagger, :dodge_cooldown

    def initialize(bus:, kit:, kit_name:, map:, tile:, faction:, name:)
      @bus = bus
      @kit = kit
      @kit_name = kit_name
      @faction = faction
      @name = name
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
      @max_hp = kit[:max_hp]
      @hp = @max_hp
      @facing = [1, 0]
      @attack_state = :idle
      @state_frames = 0
      @exhaust = 0
      @iframes = 0
      @stagger = 0
      @dodge_cooldown = 0
      @hurt_frames = 0
      @attack_landed = false
    end

    def tile = [@walker.tile_x, @walker.tile_y]
    def x = @walker.px
    def y = @walker.py
    def dead? = @hp <= 0
    def moving? = @walker.moving?
    def hurt? = @hurt_frames.positive?
    def iframes? = @iframes.positive?
    def exhaust_ready? = @exhaust <= 0
    def staggered? = @stagger.positive?
    def attacking_active? = @attack_state == :active
    def telegraphing? = @attack_state == :windup

    # One swing hits at most once (per-swing hit registry).
    def attack_landed! = @attack_landed = true
    def attack_can_hit? = attacking_active? && !@attack_landed

    # Timers + tween advance every frame regardless of controller.
    def tick_body
      @walker.tick
      return if dead?
      @exhaust -= 1 if @exhaust.positive?
      @iframes -= 1 if @iframes.positive?
      @stagger -= 1 if @stagger.positive?
      @dodge_cooldown -= 1 if @dodge_cooldown.positive?
      @hurt_frames -= 1 if @hurt_frames.positive?
      advance_attack_state
    end

    def face(dir)
      @facing = dir unless dir == [0, 0]
    end

    def step(dx, dy, blocked:)
      return false if dead? || staggered? || %i[windup active].include?(@attack_state)
      @walker.step(dx, dy, frames: @kit[:step_frames], blocked:)
    end

    # Exhaust is the ONLY cadence gate (law 1): a swing may not begin until
    # the clock runs out. Creature-owned, swap-inert by construction (law 4).
    def start_attack
      return false if dead? || staggered? || @attack_state != :idle || !exhaust_ready?
      @attack_state = :windup
      @state_frames = @kit[:attack][:windup_frames]
      @exhaust = @kit[:attack][:exhaust_frames]
      @attack_landed = false
      @bus.emit(:attack_started, attacker: self)
      true
    end

    def attack_tiles
      tx, ty = tile
      case @kit[:attack][:arc]
      when "ring"
        RING.map { |(dx, dy)| [tx + dx, ty + dy] }
      when "front1" # striker: one precise tile, no flanks
        [[tx + @facing[0], ty + @facing[1]]]
      when "projectile" # lobber: the swing itself touches nothing — World spawns the shot
        []
      else # "arc3": front + flanks (diagonal facing -> cardinal components)
        fx, fy = @facing
        front = [tx + fx, ty + fy]
        flanks =
          if fx != 0 && fy != 0
            [[tx + fx, ty], [tx, ty + fy]]
          else
            [[front[0] + fy, front[1] + fx], [front[0] - fy, front[1] - fx]]
          end
        [front, *flanks]
      end
    end

    def dodge(dir, blocked: [])
      cfg = @kit[:dodge]
      return false if dead? || staggered? || cfg.nil?
      return false unless @dodge_cooldown.zero? && @attack_state == :idle
      d = dir == [0, 0] ? @facing : dir
      moved = @walker.dash(d[0], d[1], max_tiles: cfg[:tiles],
                           frames_per_tile: cfg[:frames_per_tile], blocked:)
      return false unless moved
      @iframes = [@iframes, cfg[:iframes]].max
      @dodge_cooldown = cfg[:cooldown_frames]
      @bus.emit(:dodged, actor: self)
      true
    end

    # No blanket post-hit invuln (law 5): only dodge i-frames block. Damage
    # pacing comes from each attacker's own exhaust cadence. Interrupt-on-hit
    # is a kit property (old game: the player was interrupted, husks were
    # NOT — an uninterruptible windup is what lets pressure through).
    # Knockback is the ATTACKER's stat (kit identity: a blocker displaces,
    # a striker doesn't) — the victim only supplies the tween speed.
    def take_hit(damage:, attacker:, knockback_tiles: 0, blocked: [])
      return false if iframes? || dead?
      @hp = [@hp - damage, 0].max
      @hurt_frames = 8
      @attack_state = :idle if @kit[:interrupt_on_hit]
      knock_away_from(attacker.tile, knockback_tiles, blocked)
      if dead?
        @bus.emit(:actor_died, actor: self, killer: attacker, faction: @faction)
      else
        @bus.emit(:damage_dealt, target: self, hp: @hp, attacker:)
      end
      true
    end

    def stagger!(frames)
      @stagger = [@stagger, frames].max
    end

    def rebind(map:, tile:)
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
    end

    def revive!(map:, tile:)
      @hp = @max_hp
      @attack_state = :idle
      @exhaust = 0
      @iframes = 0
      @stagger = 0
      @dodge_cooldown = 0
      @hurt_frames = 0
      rebind(map:, tile:)
    end

    private

    def knock_away_from(from_tile, tiles, blocked)
      return if tiles.zero?
      dx = (@walker.tile_x - from_tile[0]).clamp(-1, 1)
      dy = (@walker.tile_y - from_tile[1]).clamp(-1, 1)
      dx = 1 if dx.zero? && dy.zero?
      @walker.dash(dx, dy, max_tiles: tiles,
                   frames_per_tile: @kit[:knockback_frames_per_tile], blocked:)
    end

    def advance_attack_state
      return if @attack_state == :idle
      @state_frames -= 1
      return if @state_frames.positive?
      case @attack_state
      when :windup
        @attack_state = :active
        @state_frames = @kit[:attack][:active_frames]
      when :active
        @attack_state = :recovery
        @state_frames = @kit[:attack][:recovery_frames]
        @attack_state = :idle if @state_frames.zero?
      when :recovery
        @attack_state = :idle
      end
    end
  end
end
