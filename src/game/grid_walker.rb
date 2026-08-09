module Game
  # Tibia-style tile stepper (the movement model kethral proved out):
  # the logical tile commits the instant a move starts; the visual pixel
  # position tweens to catch up with a cubic ease. Everything gameplay-
  # relevant (collision, combat range, AI) reads tiles; the floats exist
  # only so walking looks smooth.
  class GridWalker
    DIAGONAL = Math.sqrt(2)

    attr_reader :tile_x, :tile_y, :px, :py

    def initialize(map:, tile_x:, tile_y:, size:)
      @map = map
      @size = size
      teleport(tile_x, tile_y)
    end

    def teleport(tx, ty)
      @tile_x = tx
      @tile_y = ty
      @px = tile_px(tx)
      @py = tile_py(ty)
      @from_x = @px
      @from_y = @py
      @tween_total = 0
      @tween_left = 0
    end

    def moving? = @tween_left.positive?

    # One step to an adjacent tile; refused while a step is in flight.
    def step(dx, dy, frames:, blocked: [])
      return false if moving?
      commit(dx, dy, 1, frames, blocked)
    end

    # Burst move (dodge, knockback): travels up to max_tiles in a direction.
    # Default: stops short at the first wall or blocked tile (knockback).
    # through: true (dodge): bodies may be CROSSED but not landed on — lands
    # on the furthest free tile in range; walls still hard-stop the scan.
    # Interrupts an in-flight step — the tween retargets from the current
    # visual position.
    def dash(dx, dy, max_tiles:, frames_per_tile:, blocked: [], through: false)
      return commit(dx, dy, max_tiles, frames_per_tile, blocked) unless through
      commit_through(dx, dy, max_tiles, frames_per_tile, blocked)
    end

    def tick
      return unless moving?
      @tween_left -= 1
      t = 1.0 - @tween_left.fdiv(@tween_total)
      ease = t * t * (3.0 - 2.0 * t) # kethral's smoothstep: 3t^2 - 2t^3
      @px = @from_x + (tile_px(@tile_x) - @from_x) * ease
      @py = @from_y + (tile_py(@tile_y) - @from_y) * ease
    end

    private

    def commit(dx, dy, max_tiles, frames_per_tile, blocked)
      return false if dx.zero? && dy.zero?
      tx = @tile_x
      ty = @tile_y
      tiles = 0
      max_tiles.times do
        nx = tx + dx
        ny = ty + dy
        break unless @map.passable?(nx, ny)
        break if blocked.include?([nx, ny])
        tx = nx
        ty = ny
        tiles += 1
      end
      return false if tiles.zero?
      start_tween(tx, ty, tiles, frames_per_tile, dx, dy)
    end

    # Pass-through scan: every reachable tile is inspected out to max_tiles
    # or the first wall; occupied tiles can be crossed but not landed on.
    # Refuses only when NO free tile exists in range (M2.1 fix 4 — a full
    # surround ring stops being a coffin).
    def commit_through(dx, dy, max_tiles, frames_per_tile, blocked)
      return false if dx.zero? && dy.zero?
      nx = @tile_x
      ny = @tile_y
      land = nil
      1.upto(max_tiles) do |dist|
        nx += dx
        ny += dy
        break unless @map.passable?(nx, ny)
        land = [nx, ny, dist] unless blocked.include?([nx, ny])
      end
      return false unless land
      start_tween(land[0], land[1], land[2], frames_per_tile, dx, dy)
    end

    def start_tween(tx, ty, tiles, frames_per_tile, dx, dy)
      cost = frames_per_tile * tiles
      cost = (cost * DIAGONAL).round if dx.abs + dy.abs == 2
      @from_x = @px
      @from_y = @py
      @tile_x = tx
      @tile_y = ty
      @tween_total = cost
      @tween_left = cost
      true
    end

    # Entities smaller than a tile sit centered in it.
    def tile_px(tx) = tx * @map.tile_size + (@map.tile_size - @size) / 2.0
    def tile_py(ty) = ty * @map.tile_size + (@map.tile_size - @size) / 2.0
  end
end
