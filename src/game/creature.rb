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
                :facing, :attack_state, :stagger, :dodge_cooldown, :current_action,
                :carried, :taunt_frames

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
      @current_action = nil
      @action_frames = {}
      @hit_victims = []
      @action_triggered = false
      @dash_plan = nil
      @exhaust = 0
      @special_exhaust = 0
      @iframes = 0
      @stagger = 0
      @dodge_cooldown = 0
      @hurt_frames = 0
      @carried = 0
      @taunted_by = nil
      @taunt_frames = 0
    end

    def tile = [@walker.tile_x, @walker.tile_y]
    def x = @walker.px
    def y = @walker.py
    def dead? = @hp <= 0
    def moving? = @walker.moving?
    def hurt? = @hurt_frames.positive?
    def iframes? = @iframes.positive?
    def exhaust_ready? = @exhaust <= 0
    def special_ready? = @special_exhaust <= 0
    def staggered? = @stagger.positive?
    def action_active? = @attack_state == :active && !@current_action.nil?
    def telegraphing? = @attack_state == :windup
    def action_config = @current_action && @kit[@current_action]
    def special_committed? = @current_action == :special && %i[windup active].include?(@attack_state)

    def reserved_tile
      @dash_plan&.landing if @attack_state == :windup
    end

    def action_can_hit?(victim) = action_active? && !@hit_victims.include?(victim)
    def action_hit!(victim)
      @hit_victims << victim unless @hit_victims.include?(victim)
    end
    def action_can_trigger? = action_active? && !@action_triggered
    def action_triggered! = @action_triggered = true

    # Timers + tween advance every frame regardless of controller.
    def tick_body
      @walker.tick
      return if dead?
      @exhaust -= 1 if @exhaust.positive?
      @special_exhaust -= 1 if @special_exhaust.positive?
      @iframes -= 1 if @iframes.positive?
      @stagger -= 1 if @stagger.positive?
      @dodge_cooldown -= 1 if @dodge_cooldown.positive?
      @hurt_frames -= 1 if @hurt_frames.positive?
      if @taunt_frames.positive?
        @taunt_frames -= 1
        clear_taunt! if @taunt_frames.zero? || @taunted_by&.dead?
      end
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
      @exhaust = @kit[:attack][:exhaust_frames]
      begin_action(:attack)
    end

    def start_special(blocked: [])
      cfg = @kit[:special]
      return false unless cfg
      return false if dead? || staggered? || @attack_state != :idle || !special_ready?
      active_frames = nil
      if cfg[:arc] == "dash"
        @dash_plan = @walker.plan_dash(
          @facing[0], @facing[1],
          max_tiles: cfg[:max_tiles], frames_per_tile: cfg[:frames_per_tile],
          blocked:, through: true
        )
        return false unless @dash_plan
        active_frames = @dash_plan.duration
      end
      @special_exhaust = cfg[:exhaust_frames]
      begin_action(:special, active_frames:)
    end

    def action_tiles
      cfg = action_config
      return [] unless cfg
      return @dash_plan.crossed if cfg[:arc] == "dash" && @dash_plan
      tx, ty = tile
      case cfg[:arc]
      when "ring"
        RING.map { |(dx, dy)| [tx + dx, ty + dy] }
      when "front1" # striker: one precise tile, no flanks
        [[tx + @facing[0], ty + @facing[1]]]
      when "projectile", "volley" # World owns the shot / delayed target tiles
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

    # Dodge passes THROUGH bodies (through: true) — the surround ring can be
    # escaped but never landed on; walls still stop it. Knockback keeps the
    # stop-short dash (being shoved through a body would be wrong).
    def dodge(dir, blocked: [])
      cfg = @kit[:dodge]
      return false if dead? || staggered? || cfg.nil?
      return false unless @dodge_cooldown.zero? && @attack_state == :idle
      d = dir == [0, 0] ? @facing : dir
      moved = @walker.dash(d[0], d[1], max_tiles: cfg[:tiles],
                           frames_per_tile: cfg[:frames_per_tile], blocked:, through: true)
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
      interrupt_action! if @kit[:interrupt_on_hit] || (dead? && @current_action == :special)
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

    # Taunt lock (A0.6): victim-owned, swap-inert — bound to the taunter's
    # BODY, never the possession pointer. A fresh taunt overwrites.
    def taunt!(taunter, frames)
      @taunted_by = taunter
      @taunt_frames = frames
    end

    # PURE reader — never mutates (the renderer calls it from draw, and a
    # mutating reader would let wall-clock draw timing change sim state).
    # Clearing is sim-owned: tick_body for ticking victims, and the World's
    # respawn sweep for victims frozen in abandoned zones (impl review 1+2:
    # a lazy clear here is unreachable between wipe and revival, so revival
    # would resurrect locks the blocker never re-cast).
    def taunted_target
      return nil unless @taunted_by && @taunt_frames.positive?
      @taunted_by.dead? ? nil : @taunted_by
    end

    def release_taunt! = clear_taunt!

    # Carried value is creature-owned and swap-inert (law 4): it rides the
    # body, not the possession pointer. Drained by banking and by death.
    def pick_up(amount) = @carried += amount

    def drain_carried!
      amount = @carried
      @carried = 0
      amount
    end

    def interrupt_action!
      @attack_state = :idle
      @state_frames = 0
      @current_action = nil
      @action_frames = {}
      @hit_victims = []
      @action_triggered = false
      @dash_plan = nil
    end

    def rebind(map:, tile:)
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
    end

    def revive!(map:, tile:)
      @hp = @max_hp
      interrupt_action!
      @exhaust = 0
      @special_exhaust = 0
      @iframes = 0
      @stagger = 0
      @dodge_cooldown = 0
      @hurt_frames = 0
      @carried = 0
      clear_taunt!
      rebind(map:, tile:)
    end

    private

    def clear_taunt!
      @taunted_by = nil
      @taunt_frames = 0
    end

    def begin_action(kind, active_frames: nil)
      cfg = @kit.fetch(kind)
      @current_action = kind
      @action_frames = {
        windup: cfg[:windup_frames],
        active: active_frames || cfg[:active_frames],
        recovery: cfg[:recovery_frames]
      }
      @dash_plan = nil unless cfg[:arc] == "dash"
      @hit_victims = []
      @action_triggered = false
      @attack_state = :windup
      @state_frames = @action_frames[:windup]
      event = kind == :attack ? :attack_started : :special_started
      @bus.emit(event, attacker: self)
      true
    end

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
        @state_frames = @action_frames[:active]
        activate_action
      when :active
        @attack_state = :recovery
        @state_frames = @action_frames[:recovery]
        interrupt_action! if @state_frames.zero?
      when :recovery
        interrupt_action!
      end
    end

    def activate_action
      return unless action_config[:arc] == "dash"
      @walker.commit_dash(@dash_plan)
      @iframes = [@iframes, @dash_plan.duration].max
    end
  end
end
