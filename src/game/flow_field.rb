module Game
  # BFS distance field from the player's tile. Husks chase by stepping
  # downhill, which walks them around walls without per-husk pathfinding.
  # Deterministic: fixed neighbor order, plain array queue. Recomputed only
  # when the player's tile changes (~every 15 frames while walking).
  class FlowField
    UNREACHED = Float::INFINITY

    # Cardinals before diagonals; fixed order = deterministic tie-breaks.
    STEPS = [[0, -1], [1, 0], [0, 1], [-1, 0], [1, -1], [1, 1], [-1, 1], [-1, -1]].freeze

    def initialize(map)
      @map = map
      @dist = Array.new(map.rows) { Array.new(map.cols, UNREACHED) }
    end

    def recompute!(target)
      @dist.each { |row| row.fill(UNREACHED) }
      tx, ty = target
      return unless @map.passable?(tx, ty)
      @dist[ty][tx] = 0
      queue = [[tx, ty]]
      head = 0
      while head < queue.length
        cx, cy = queue[head]
        head += 1
        d = @dist[cy][cx] + 1
        STEPS.each do |(dx, dy)|
          nx = cx + dx
          ny = cy + dy
          next unless open?(cx, cy, dx, dy)
          next unless @dist[ny][nx] == UNREACHED
          @dist[ny][nx] = d
          queue << [nx, ny]
        end
      end
    end

    def distance(tx, ty) = @dist[ty][tx]

    # The neighbor step that best descends toward the target, or nil if
    # nothing improves (cornered / already adjacent / unreachable).
    def downhill_from(tx, ty, blocked: [])
      best = nil
      best_d = @dist[ty][tx]
      STEPS.each do |(dx, dy)|
        nx = tx + dx
        ny = ty + dy
        next unless open?(tx, ty, dx, dy)
        next if blocked.include?([nx, ny])
        nd = @dist[ny][nx]
        if nd < best_d
          best_d = nd
          best = [dx, dy]
        end
      end
      best
    end

    private

    # Diagonal steps may not cut wall corners.
    def open?(cx, cy, dx, dy)
      return false unless @map.passable?(cx + dx, cy + dy)
      return true if dx.zero? || dy.zero?
      @map.passable?(cx + dx, cy) && @map.passable?(cx, cy + dy)
    end
  end
end
