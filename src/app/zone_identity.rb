module App
  # v16 (b): zone identity channels — PURE geometry policy, no Gosu.
  # Motif: sparse deterministic floor texture, INTEGER arithmetic only
  # ((tx*7 + ty*13 + seed) % 9 — no floats, no RNG stream); ~1/9 of
  # passable tiles. Decor: authored landmark rects from zone data
  # (render-only, never blocking). Ambient: flat post-map tint. Absent
  # keys yield empty output — a zone without an identity block renders
  # exactly as before (fallback/comparability law).
  module ZoneIdentity
    GLYPHS = %w[plank chip ripple brick].freeze
    DECOR_KINDS = %w[stain brazier edge].freeze

    module_function

    # -> [[x, y, w, h], ...] one glyph per eligible tile, single zone color.
    def motif_rects(map)
      glyph = map.palette[:motif]
      return [] unless glyph
      raise ArgumentError, "unknown motif glyph #{glyph}" unless GLYPHS.include?(glyph)
      seed = map.palette.fetch(:motif_seed, 0)
      ts = map.tile_size
      rects = []
      map.rows.times do |ty|
        map.cols.times do |tx|
          next unless map.passable?(tx, ty)
          next unless ((tx * 7 + ty * 13 + seed) % 9).zero?
          rects.concat(glyph_rects(glyph, tx, ty, ts))
        end
      end
      rects
    end

    # -> [[x, y, w, h, rgb, alpha], ...] authored landmarks, resolved to
    # pixel rects. Unknown kinds raise (fail loud, the EventBus law).
    def decor_rects(map)
      ts = map.tile_size
      map.decor.flat_map do |d|
        x = d.fetch(:at)[0] * ts
        y = d.fetch(:at)[1] * ts
        w = d.fetch(:w, 1) * ts
        h = d.fetch(:h, 1) * ts
        rgb = d.fetch(:rgb)
        alpha = d.fetch(:alpha)
        case d[:kind]
        when "stain"
          [[x, y, w, h, rgb, alpha]]
        when "brazier"
          # Iron bowl (darkened family of the ember) + the ember core.
          base = rgb.map { |c| c / 3 }
          [[x + ts / 4, y + ts / 4, ts / 2, ts / 2, base, alpha],
           [x + ts * 3 / 8, y + ts * 3 / 8, ts / 4, ts / 4, rgb, alpha]]
        when "edge"
          # A thin lip highlight along the tile-row top: silhouette, not bar.
          [[x, y, w, 2, rgb, alpha]]
        else
          raise ArgumentError, "unknown decor kind #{d[:kind]}"
        end
      end
    end

    # -> [r, g, b, a] or nil.
    def ambient(map)
      map.palette[:ambient_rgba]
    end

    # Glyphs stay strictly inside their tile; parity (tx+ty)%2 breaks the
    # placement-formula banding without leaving integer space.
    def glyph_rects(glyph, tx, ty, ts)
      x = tx * ts
      y = ty * ts
      p = (tx + ty) % 2
      case glyph
      when "plank"
        [[x + ts / 8 + p * (ts / 8), y + (p.zero? ? ts / 3 : ts * 3 / 5), ts * 5 / 8, 2]]
      when "chip"
        p.zero? ? [[x + ts / 4, y + ts / 4, ts / 8, ts / 8]]
                : [[x + ts * 9 / 16, y + ts * 9 / 16, ts / 8, ts / 8]]
      when "ripple"
        [[x + ts / 4, y + ts * 3 / 8, ts / 2, 2],
         [x + ts * 3 / 8 + p * (ts / 8), y + ts * 5 / 8, ts * 3 / 8, 2]]
      when "brick"
        [[x + ts / 5, y + ts / 3, ts / 4, ts / 6],
         [x + ts * 11 / 20, y + ts * 3 / 5, ts / 4, ts / 6]]
      end
    end
  end
end
