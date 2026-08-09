require "game/grid_walker"

module Game
  # Player entity on the tile grid. Logic reads tiles; GridWalker owns the
  # smooth pixel tween between them. Attack state machine (:idle, :windup,
  # :active, :recovery) is unchanged from slice v1 — the feel layer stays.
  # All numbers come from data/balance/combat.json.
  class Player
    SIZE = 28

    attr_reader :hp, :max_hp, :attack_state, :facing, :dodge_cooldown, :walker

    def initialize(bus:, stats:, map:, tile:)
      @bus = bus
      @stats = stats
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
      @max_hp = stats[:max_hp]
      @hp = @max_hp
      @facing = [1, 0]
      @attack_state = :idle
      @state_frames = 0
      @invuln = 0
      @dodge_cooldown = 0
      @attack_landed = false
    end

    def tile = [@walker.tile_x, @walker.tile_y]
    def x = @walker.px
    def y = @walker.py
    def dead? = @hp <= 0
    def attacking_active? = @attack_state == :active
    def invulnerable? = @invuln.positive?

    # One swing hits at most once.
    def attack_landed! = @attack_landed = true
    def attack_can_hit? = attacking_active? && !@attack_landed

    def rebind(map:, tile:)
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
    end

    def tick(input, blocked: [])
      @walker.tick
      return if dead?

      @invuln -= 1 if @invuln.positive?
      @dodge_cooldown -= 1 if @dodge_cooldown.positive?
      advance_attack_state
      return if %i[windup active].include?(@attack_state)

      dir = held_direction(input)
      @facing = dir unless dir == [0, 0]
      if input.down?(:dodge) && can_dodge?
        start_dodge(dir, blocked) # dodge preempts the step — no 3-tile stack
      elsif dir != [0, 0]
        @walker.step(dir[0], dir[1], frames: @stats[:step_frames], blocked:)
      end
      # Swings fire even mid-step (Tibia: attacking is independent of the
      # walk); the windup/active lock above still plants the NEXT step.
      start_attack if input.down?(:attack) && @attack_state == :idle
    end

    # A swing is a 3-tile arc: the facing tile plus its two flanks. Husks
    # melee at Chebyshev adjacency (diagonals hit), so the swing must reach
    # diagonals too or a corner-parked husk would be unhittable. Front tile
    # first — it wins when two husks are in the arc.
    def attack_tiles
      fx, fy = @facing
      front = [@walker.tile_x + fx, @walker.tile_y + fy]
      flanks =
        if fx != 0 && fy != 0 # diagonal facing: the two cardinal components
          [[@walker.tile_x + fx, @walker.tile_y], [@walker.tile_x, @walker.tile_y + fy]]
        else # cardinal facing: the two diagonals beside the front tile
          [[front[0] + fy, front[1] + fx], [front[0] - fy, front[1] - fx]]
        end
      [front, *flanks]
    end

    def take_hit(damage:, from_tile:, blocked: [])
      return false if invulnerable? || dead?
      @hp = [@hp - damage, 0].max
      @invuln = @stats[:invuln_frames_after_hit]
      @attack_state = :idle
      knock_away_from(from_tile, blocked)
      if dead?
        @bus.emit(:player_died)
      else
        @bus.emit(:player_hit, hp: @hp)
      end
      true
    end

    def respawn(map:, tile:)
      @hp = @max_hp
      rebind(map:, tile:)
      @attack_state = :idle
      @invuln = 0
      @dodge_cooldown = 0
      @bus.emit(:player_respawned)
    end

    private

    def can_dodge? = @dodge_cooldown.zero? && @attack_state == :idle

    def start_dodge(dir, blocked)
      d = dir == [0, 0] ? @facing : dir
      moved = @walker.dash(d[0], d[1],
                           max_tiles: @stats[:dodge][:tiles],
                           frames_per_tile: @stats[:dodge][:frames_per_tile],
                           blocked:)
      return unless moved
      @invuln = [@invuln, @stats[:dodge][:iframes]].max
      @dodge_cooldown = @stats[:dodge][:cooldown_frames]
      @bus.emit(:player_dodged)
    end

    def knock_away_from(from_tile, blocked)
      dx = (@walker.tile_x - from_tile[0]).clamp(-1, 1)
      dy = (@walker.tile_y - from_tile[1]).clamp(-1, 1)
      dx = 1 if dx.zero? && dy.zero?
      @walker.dash(dx, dy,
                   max_tiles: @stats[:knockback_tiles_received],
                   frames_per_tile: @stats[:knockback_frames_per_tile],
                   blocked:)
    end

    def held_direction(input)
      dx = (input.down?(:right) ? 1 : 0) - (input.down?(:left) ? 1 : 0)
      dy = (input.down?(:down) ? 1 : 0) - (input.down?(:up) ? 1 : 0)
      [dx, dy]
    end

    def start_attack
      @attack_state = :windup
      @state_frames = @stats[:attack][:windup_frames]
      @attack_landed = false
      @bus.emit(:attack_started)
    end

    def advance_attack_state
      return if @attack_state == :idle
      @state_frames -= 1
      return if @state_frames.positive?

      case @attack_state
      when :windup
        @attack_state = :active
        @state_frames = @stats[:attack][:active_frames]
      when :active
        @attack_state = :recovery
        @state_frames = @stats[:attack][:recovery_frames]
      when :recovery
        @attack_state = :idle
      end
    end
  end
end
