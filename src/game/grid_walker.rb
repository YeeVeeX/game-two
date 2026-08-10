module Game
  # Tibia-style tile stepper (the movement model kethral proved out):
  # the logical tile commits the instant a move starts; the visual pixel
  # position tweens to catch up with a cubic ease. Everything gameplay-
  # relevant (collision, combat range, AI) reads tiles; the floats exist
  # only so walking looks smooth.
  class GridWalker
    DIAGONAL = Math.sqrt(2)
    DashPlan = Data.define(:landing, :crossed, :duration, :dx, :dy)

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
      plan = plan_dash(dx, dy, max_tiles: 1, frames_per_tile: frames, blocked:)
      plan ? commit_dash(plan) : false
    end

    # Burst move (dodge, knockback): travels up to max_tiles in a direction.
    # Default: stops short at the first wall or blocked tile (knockback).
    # through: true (dodge): bodies may be CROSSED but not landed on — lands
    # on the furthest free tile in range; walls still hard-stop the scan.
    # Interrupts an in-flight step — the tween retargets from the current
    # visual position.
    def dash(dx, dy, max_tiles:, frames_per_tile:, blocked: [], through: false)
      plan = plan_dash(dx, dy, max_tiles:, frames_per_tile:, blocked:, through:)
      plan ? commit_dash(plan) : false
    end

    # The one authoritative scan for every burst move. The returned plan is
    # immutable and can be committed later without re-reading map/occupancy.
    def plan_dash(dx, dy, max_tiles:, frames_per_tile:, blocked: [], through: false)
      return nil if dx.zero? && dy.zero?
      tx = @tile_x
      ty = @tile_y
      path = []
      landing_index = nil

      max_tiles.times do
        nx = tx + dx
        ny = ty + dy
        break unless @map.passable?(nx, ny)
        occupied = blocked.include?([nx, ny])
        break if occupied && !through
        tx = nx
        ty = ny
        path << [tx, ty]
        landing_index = path.length - 1 unless occupied
      end

      return nil unless landing_index
      crossed = path.take(landing_index + 1)
      duration = frames_per_tile * crossed.length
      duration = (duration * DIAGONAL).round if dx.abs + dy.abs == 2
      DashPlan.new(landing: crossed.last, crossed:, duration:, dx:, dy:)
    end

    def commit_dash(plan)
      return false unless plan
      @from_x = @px
      @from_y = @py
      @tile_x, @tile_y = plan.landing
      @tween_total = plan.duration
      @tween_left = plan.duration
      true
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

    # Entities smaller than a tile sit centered in it.
    def tile_px(tx) = tx * @map.tile_size + (@map.tile_size - @size) / 2.0
    def tile_py(ty) = ty * @map.tile_size + (@map.tile_size - @size) / 2.0
  end
end
