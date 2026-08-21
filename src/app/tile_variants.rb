module App
  # T3 flora visual variants (world-builder D7): which palette ref paints
  # each typed tile, derived as a PURE function of zone name + tile coord +
  # authored data — never runtime randomness, so replays, both netplay
  # seats, and the two Rule 2 gate halves agree byte-for-byte.
  # Presentation-only: the sim never reads this (passable? stays TileMap's
  # '#' law).
  #
  # Visible-overlay rule: a typed tile emits a rect ONLY when its resolved
  # palette color differs from the zone's floor color. A footstep-only
  # remap (nest's "." -> dirt, palette dirt == floor) therefore draws
  # NOTHING — the live zone's look stays byte-identical by construction,
  # with zero extra draw calls.
  module TileVariants
    module_function

    # FNV-1a over "zone:x:y" — cheap, stable across processes and machines
    # (never Object#hash: Ruby randomizes string hashes per process, which
    # would break replay determinism).
    def pick(zone, tx, ty, n)
      return 0 if n <= 1
      h = 2_166_136_261
      "#{zone}:#{tx}:#{ty}".each_byte { |b| h = ((h ^ b) * 16_777_619) & 0xffffffff }
      h % n
    end

    # -> [[tx, ty, palette_ref_sym], ...] for every visible typed tile.
    # Pure function of immutable zone config + registry — callers memoize
    # per map (the renderer's identity_rects pattern).
    def rects(map, registry)
      return [] unless registry
      specs = registry.default_char_map.merge(map.tile_types || {})
                      .transform_values { |id| registry.type(id) }
      floor_rgb = map.palette[:floor]
      out = []
      map.rows.times do |ty|
        map.cols.times do |tx|
          spec = specs[map.char_at(tx, ty)]
          next if spec.nil? || spec["passability"] == "wall"
          refs = [spec["render"]] + (spec["variants"] || [])
          ref = refs[pick(map.name.to_s, tx, ty, refs.length)].to_sym
          next if map.palette[ref] == floor_rgb
          out << [tx, ty, ref]
        end
      end
      out
    end
  end
end
