require "game/grid_walker"

module Game
  # The husk, now a tile creature. Chebyshev-adjacent melee (Tibia melee
  # hits diagonals), chases downhill on the zone's flow field so walls are
  # walked around, same telegraph feel as slice v1. States :idle, :chase,
  # :windup, :active, :cooldown, :dead.
  class Enemy
    SIZE = 28

    attr_reader :hp, :state, :walker

    def initialize(bus:, stats:, map:, tile:)
      @bus = bus
      @stats = stats
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
      @hp = stats[:max_hp]
      @state = :idle
      @state_frames = 0
      @hurt_frames = 0
    end

    def tile = [@walker.tile_x, @walker.tile_y]
    def x = @walker.px
    def y = @walker.py
    def dead? = @state == :dead
    def telegraphing? = @state == :windup
    def hurt? = @hurt_frames.positive?

    def tick(player:, flow:, blocked: [])
      return if dead?

      @walker.tick
      @hurt_frames -= 1 if @hurt_frames.positive?
      dist = chebyshev(player.tile)

      case @state
      when :idle
        @state = :chase if dist <= @stats[:aggro_tiles] && !player.dead?
      when :chase
        if player.dead?
          @state = :idle
        elsif dist <= 1
          @state = :windup
          @state_frames = @stats[:attack][:windup_frames]
          @bus.emit(:enemy_telegraph)
        else
          chase_step(flow, blocked)
        end
      when :windup
        @state_frames -= 1
        if @state_frames <= 0
          @state = :active
          @state_frames = @stats[:attack][:active_frames]
        end
      when :active
        strike(player, blocked)
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

    def take_hit(damage:, from_tile:, blocked: [])
      return if dead?
      @hp = [@hp - damage, 0].max
      @hurt_frames = 8
      knock_away_from(from_tile, blocked)
      if @hp.zero?
        @state = :dead
        @bus.emit(:entity_died, entity: :husk)
      else
        @bus.emit(:damage_dealt, target: :husk, hp: @hp)
      end
    end

    private

    def chebyshev((tx, ty))
      [(tx - @walker.tile_x).abs, (ty - @walker.tile_y).abs].max
    end

    def strike(player, blocked)
      return if player.dead? || chebyshev(player.tile) > 1
      player.take_hit(damage: @stats[:attack][:damage], from_tile: tile, blocked:)
    end

    def chase_step(flow, blocked)
      return if @walker.moving?
      dir = flow.downhill_from(@walker.tile_x, @walker.tile_y, blocked:)
      return unless dir
      @walker.step(dir[0], dir[1], frames: @stats[:step_frames], blocked:)
    end

    def knock_away_from(from_tile, blocked)
      dx = (@walker.tile_x - from_tile[0]).clamp(-1, 1)
      dy = (@walker.tile_y - from_tile[1]).clamp(-1, 1)
      dx = 1 if dx.zero? && dy.zero?
      @walker.dash(dx, dy,
                   max_tiles: @stats[:knockback_tiles],
                   frames_per_tile: @stats[:knockback_frames_per_tile],
                   blocked:)
    end
  end
end
