module Game
  # Player entity: 8-way movement, dodge (the defense verb), attack state
  # machine (:idle, :windup, :active, :recovery). All numbers come from
  # data/balance/combat.json (stats hash) — no balance constants here.
  class Player
    SIZE = 28

    attr_reader :x, :y, :hp, :max_hp, :attack_state, :facing, :dodge_cooldown

    def initialize(bus:, stats:, x:, y:)
      @bus = bus
      @stats = stats
      @x = x
      @y = y
      @max_hp = stats[:max_hp]
      @hp = @max_hp
      @facing = [1.0, 0.0]
      @attack_state = :idle
      @state_frames = 0
      @invuln = 0
      @dodge_frames = 0
      @dodge_cooldown = 0
      @dodge_dir = [0.0, 0.0]
      @knock = [0.0, 0.0]
      @attack_landed = false
    end

    def dead? = @hp <= 0
    def attacking_active? = @attack_state == :active
    def invulnerable? = @invuln.positive?
    def dodging? = @dodge_frames.positive?

    # One swing hits at most once.
    def attack_landed! = @attack_landed = true
    def attack_can_hit? = attacking_active? && !@attack_landed

    def tick(input, bounds:)
      return if dead?

      @invuln -= 1 if @invuln.positive?
      @dodge_cooldown -= 1 if @dodge_cooldown.positive?
      advance_attack_state
      apply_knockback(bounds)

      if dodging?
        dodge_step(bounds)
      else
        locked = %i[windup active].include?(@attack_state)
        move(input, bounds) unless locked
        start_attack if input.down?(:attack) && @attack_state == :idle
        start_dodge(input) if input.down?(:dodge) && can_dodge?
      end
    end

    # Reach box in front of the player while the attack is active.
    def attack_hitbox
      return nil unless attacking_active?
      range = @stats[:attack][:range]
      cx = @x + SIZE / 2 + @facing[0] * (SIZE / 2 + range / 2)
      cy = @y + SIZE / 2 + @facing[1] * (SIZE / 2 + range / 2)
      half = range / 2.0
      [cx - half, cy - half, range, range]
    end

    def hitbox = [@x, @y, SIZE, SIZE]
    def center = [@x + SIZE / 2, @y + SIZE / 2]
    def attack_range = @stats[:attack][:range]

    def take_hit(damage:, from_x:, from_y:)
      return false if invulnerable? || dodging? || dead?
      @hp = [@hp - damage, 0].max
      @invuln = @stats[:invuln_frames_after_hit]
      dx = center[0] - from_x
      dy = center[1] - from_y
      len = Math.hypot(dx, dy)
      kb = @stats[:knockback_received]
      @knock = len.zero? ? [kb, 0.0] : [dx / len * kb, dy / len * kb]
      @attack_state = :idle
      if dead?
        @bus.emit(:player_died)
      else
        @bus.emit(:player_hit, hp: @hp)
      end
      true
    end

    def respawn(x:, y:)
      @hp = @max_hp
      @x = x
      @y = y
      @attack_state = :idle
      @invuln = 0
      @dodge_frames = 0
      @dodge_cooldown = 0
      @knock = [0.0, 0.0]
      @bus.emit(:player_respawned)
    end

    private

    def can_dodge? = @dodge_cooldown.zero? && @attack_state == :idle

    def start_dodge(input)
      dir = held_direction(input)
      @dodge_dir = dir == [0.0, 0.0] ? @facing.dup : dir
      @dodge_frames = @stats[:dodge][:duration_frames]
      @invuln = [@invuln, @stats[:dodge][:iframes]].max
      @dodge_cooldown = @stats[:dodge][:cooldown_frames]
      @bus.emit(:player_dodged)
    end

    def dodge_step(bounds)
      speed = @stats[:dodge][:distance] / @stats[:dodge][:duration_frames]
      @x = (@x + @dodge_dir[0] * speed).clamp(bounds[0], bounds[2] - SIZE)
      @y = (@y + @dodge_dir[1] * speed).clamp(bounds[1], bounds[3] - SIZE)
      @dodge_frames -= 1
    end

    def held_direction(input)
      dx = (input.down?(:right) ? 1 : 0) - (input.down?(:left) ? 1 : 0)
      dy = (input.down?(:down) ? 1 : 0) - (input.down?(:up) ? 1 : 0)
      return [0.0, 0.0] if dx.zero? && dy.zero?
      len = Math.hypot(dx, dy)
      [dx / len, dy / len]
    end

    def move(input, bounds)
      dir = held_direction(input)
      return if dir == [0.0, 0.0]
      speed = @stats[:move_speed]
      @x = (@x + dir[0] * speed).clamp(bounds[0], bounds[2] - SIZE)
      @y = (@y + dir[1] * speed).clamp(bounds[1], bounds[3] - SIZE)
      @facing = dir
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

    def apply_knockback(bounds)
      return if @knock[0].abs < 0.1 && @knock[1].abs < 0.1
      @x = (@x + @knock[0]).clamp(bounds[0], bounds[2] - SIZE)
      @y = (@y + @knock[1]).clamp(bounds[1], bounds[3] - SIZE)
      @knock = [@knock[0] * 0.8, @knock[1] * 0.8]
    end
  end
end
