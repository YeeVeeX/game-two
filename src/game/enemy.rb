module Game
  # The slice's one enemy: a husk. Behavior states :idle, :chase, :windup,
  # :active, :cooldown, :dead. Telegraphs its attack by flashing during windup.
  class Enemy
    SIZE = 32

    attr_reader :x, :y, :hp, :state

    def initialize(bus:, stats:, x:, y:)
      @bus = bus
      @stats = stats
      @x = x
      @y = y
      @hp = stats[:max_hp]
      @state = :idle
      @state_frames = 0
      @knock = [0.0, 0.0]
      @hurt_frames = 0
    end

    def dead? = @state == :dead
    def telegraphing? = @state == :windup
    def attacking_active? = @state == :active
    def hurt? = @hurt_frames.positive?

    def tick(player:, bounds:)
      return if dead?

      @hurt_frames -= 1 if @hurt_frames.positive?
      apply_knockback(bounds)
      px, py = player.center
      cx, cy = center
      dist = Math.hypot(px - cx, py - cy)

      case @state
      when :idle
        @state = :chase if dist <= @stats[:aggro_range] && !player.dead?
      when :chase
        if player.dead?
          @state = :idle
        elsif dist <= @stats[:attack][:range]
          @state = :windup
          @state_frames = @stats[:attack][:windup_frames]
          @bus.emit(:enemy_telegraph)
        else
          step_toward(px, py, bounds)
        end
      when :windup
        @state_frames -= 1
        if @state_frames <= 0
          @state = :active
          @state_frames = @stats[:attack][:active_frames]
        end
      when :active
        strike(player) unless player.dead?
        @state_frames -= 1
        if @state_frames <= 0
          @state = :cooldown
          @state_frames = @stats[:attack][:cooldown_frames]
        end
      when :cooldown
        @state_frames -= 1
        @state = :chase if @state_frames <= 0
      end
    end

    def take_hit(damage:, knockback:, from_x:, from_y:)
      return if dead?
      @hp = [@hp - damage, 0].max
      @hurt_frames = 8
      dx = center[0] - from_x
      dy = center[1] - from_y
      len = Math.hypot(dx, dy)
      @knock = len.zero? ? [knockback, 0.0] : [dx / len * knockback, dy / len * knockback]
      if @hp.zero?
        @state = :dead
        @bus.emit(:entity_died, entity: :husk)
      else
        @bus.emit(:damage_dealt, target: :husk, hp: @hp)
      end
    end

    def hitbox = [@x, @y, SIZE, SIZE]
    def center = [@x + SIZE / 2, @y + SIZE / 2]

    private

    def strike(player)
      px, py = player.center
      cx, cy = center
      return unless Math.hypot(px - cx, py - cy) <= @stats[:attack][:range] + Player::SIZE / 2
      player.take_hit(damage: @stats[:attack][:damage], from_x: cx, from_y: cy)
    end

    def step_toward(px, py, bounds)
      cx, cy = center
      dx = px - cx
      dy = py - cy
      len = Math.hypot(dx, dy)
      return if len.zero?
      speed = @stats[:move_speed]
      @x = (@x + dx / len * speed).clamp(bounds[0], bounds[2] - SIZE)
      @y = (@y + dy / len * speed).clamp(bounds[1], bounds[3] - SIZE)
    end

    def apply_knockback(bounds)
      return if @knock[0].abs < 0.1 && @knock[1].abs < 0.1
      @x = (@x + @knock[0]).clamp(bounds[0], bounds[2] - SIZE)
      @y = (@y + @knock[1]).clamp(bounds[1], bounds[3] - SIZE)
      @knock = [@knock[0] * 0.8, @knock[1] * 0.8]
    end
  end
end
