module App
  # T3 flora visual variants (world-builder D7): which palette ref paints
  # each typed tile, derived as a PURE function of zone name + tile coord +
  # authored data — never runtime randomness, so replays, both netplay
  # seats, and the two Rule 2 gate halves agree byte-for-byte.
  # Presentation-only: the sim never reads this (passable? stays TileMap's
  # wall-char set law).
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
      specs = specs(map, registry)
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

    # The effective char -> type-spec map for a zone (registry defaults
    # overlaid by the zone's tile_types remap). Extracted (v20 T5) so the
    # wall passes — renderer static runs + god-view cells — resolve through
    # the SAME derivation as the typed-floor pass; nil registry = {} (bare
    # fixture data dirs).
    def specs(map, registry)
      return {} unless registry
      registry.default_char_map.merge(map.tile_types || {})
              .transform_values { |id| registry.type(id) }
    end

    # v20 T5 (foundation L11): which palette ref paints a WALL tile — the
    # tile's own render-ref, never the :wall literal, so a second wall
    # class (wall_inner) coexists with the boundary wall in one zone.
    # :wall fallback covers ONLY registry-less fixture maps — a zone wired
    # through World cannot reach it (TileRegistry#validate_map! refuses a
    # used char whose render ref is absent from the palette at load).
    def wall_ref(specs, map, tx, ty)
      spec = specs[map.char_at(tx, ty)]
      spec && spec["passability"] == "wall" ? spec["render"].to_sym : :wall
    end
  end
end
