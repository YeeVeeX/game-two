module App
  # v16 (b): sparse deterministic floor motif — the zone-identity texture
  # channel. PURE integer math from (tx, ty): placement hits ~1/9 tiles
  # via (tx*7 + ty*13) % 9 (the spec's own arithmetic law — no floats in
  # placement), and an in-tile phase drift keeps the pattern from reading
  # as a printed grid. A zone picks a glyph by name in its palette
  # (motif key); glyphs are small authored rect sets that fit a 14px box
  # so no offset can bleed past the 32px tile (watched risk W5: sparse,
  # small, never gold — texture must not read as drops).
  module Motif
    # [dx, dy, w, h] sets, each confined to a 14x14 box.
    GLYPHS = {
      "ember"  => [[0, 0, 4, 4], [7, 5, 2, 2]],                    # fleck + spark
      "brick"  => [[0, 0, 12, 2], [6, 6, 8, 2]],                   # staggered seams
      "tally"  => [[0, 0, 2, 8], [4, 0, 2, 8], [8, 0, 2, 8]],      # measure ticks
      "crack"  => [[0, 0, 2, 10], [2, 8, 8, 2]],                   # L fissure
      "ripple" => [[0, 0, 12, 2], [2, 5, 10, 2], [4, 10, 8, 2]],   # waterline
    }.freeze

    def self.placed?(tx, ty) = ((tx * 7 + ty * 13) % 9).zero?

    # Pixel rects [x, y, w, h] for one tile; [] off-pattern. Unknown glyph
    # fails loud with the valid list (BindingMap law) — a data typo stops
    # the first draw of that zone, and the gate/canary catches it.
    def self.rects(glyph:, tx:, ty:, ts:)
      shapes = GLYPHS.fetch(glyph) do
        raise ArgumentError,
              "unknown motif #{glyph.inspect} — valid: #{GLYPHS.keys.join(', ')}"
      end
      return [] unless placed?(tx, ty)
      ox = 4 + ((tx * 3 + ty * 5) % 4) * 3
      oy = 4 + ((tx + ty * 2) % 4) * 3
      shapes.map { |dx, dy, w, h| [tx * ts + ox + dx, ty * ts + oy + dy, w, h] }
    end
  end
end
