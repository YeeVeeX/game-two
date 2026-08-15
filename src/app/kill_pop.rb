module App
  # v16 (e): kill pop shard geometry. PURE integer math from
  # (tile, phase, frames_left) — deterministic by construction: no RNG
  # stream, no wall clock (Feel's sin/cos-shake law). The renderer is the
  # only consumer; the sim owns the records (world.kill_pops).
  module KillPop
    DIRS = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]].freeze

    # Returns [x, y, size] pixel rects for one pop record. Radius grows
    # 2px per sim frame of age; sizes alternate 3/4 px seeded by phase.
    def self.shards(tile:, phase:, frames_left:, pop_frames:, ts:)
      age = pop_frames - frames_left
      cx = tile[0] * ts + ts / 2
      cy = tile[1] * ts + ts / 2
      radius = 2 + age * 2
      DIRS.each_with_index.map do |(dx, dy), i|
        size = 3 + ((phase + i) % 2)
        [cx + dx * radius - size / 2, cy + dy * radius - size / 2, size]
      end
    end
  end
end
