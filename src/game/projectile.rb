module Game
  # A tile-stepped shot (lobber kit): commits one tile per frames_per_tile
  # window along a fixed direction, stops at the first wall or hostile, and
  # dies at its range cap. Passes through friendlies — no friendly fire
  # (Tibia-faithful). Deterministic: no randomness, integer frame counters;
  # the floats exist only so the flight draws smooth.
  class Projectile
    SIZE = 10

    attr_reader :owner, :dir

    def initialize(owner:, map:, tile:, dir:, damage:, range_tiles:, frames_per_tile:)
      @owner = owner
      @map = map
      @tile_x, @tile_y = tile
      @dir = dir
      @damage = damage
      @range_left = range_tiles
      @frames_per_tile = frames_per_tile
      @countdown = frames_per_tile
      @done = false
    end

    def tile = [@tile_x, @tile_y]
    def done? = @done
    def damage = @damage

    # Smooth draw position: interpolates toward the NEXT tile it is flying at.
    def x
      progress = 1.0 - @countdown.fdiv(@frames_per_tile)
      base = @tile_x * @map.tile_size + (@map.tile_size - SIZE) / 2.0
      @done ? base : base + @dir[0] * progress * @map.tile_size
    end

    def y
      progress = 1.0 - @countdown.fdiv(@frames_per_tile)
      base = @tile_y * @map.tile_size + (@map.tile_size - SIZE) / 2.0
      @done ? base : base + @dir[1] * progress * @map.tile_size
    end

    # Advances the flight; returns the Creature struck this frame, or nil.
    # The caller (World) applies take_hit — the projectile only reports.
    def tick(hostiles:)
      return nil if @done
      @countdown -= 1
      return nil if @countdown.positive?

      nx = @tile_x + @dir[0]
      ny = @tile_y + @dir[1]
      unless @map.passable?(nx, ny)
        @done = true
        return nil
      end

      @tile_x = nx
      @tile_y = ny
      @range_left -= 1
      @countdown = @frames_per_tile

      victim = hostiles.find { |h| !h.dead? && h.tile == [nx, ny] }
      if victim
        @done = true
        return victim
      end

      @done = true if @range_left.zero?
      nil
    end
  end
end
