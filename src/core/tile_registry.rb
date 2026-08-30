require "core/tile_map"

module Core
  # Tile-type registry (world-builder D7). v0 (T2): data/tiles.json declares
  # each tile type's authoring glyph (`char`), LDtk IntGrid value
  # (`int_grid`), render palette ref (`render`), footstep material
  # (`footstep`) and `passability` ("wall"/"floor"; "swim" is reserved for a
  # post-verdict sim-class increment and REFUSED). T3 (the D7 SAFE-behavior
  # cycle) unlocks `variants` — an optional list of ALTERNATE render palette
  # refs for authored visual variety (selection is a pure function of
  # zone+coord, App::TileVariants; no runtime randomness) — and consumes
  # `footstep` through #material_at (audio-bridge custody, pure sink).
  # `hooks` stays a reserved key name (D7 hazard/spawn_affinity) — its
  # presence refuses NAMED until its gated post-verdict cycle lands.
  #
  # v0 wall law (generalized by v20 T5): TileMap#passable? reads the frozen
  # TileMap::WALL_CHARS set — blocking is a grid-char fact, never a registry
  # lookup. The registry therefore ENFORCES that WALL_CHARS membership and
  # passability "wall" imply each other — a wall type whose char TileMap
  # would not block (or a walkable type on a blocking char) refuses NAMED.
  # Rewiring passable? through the registry stays a sim-visible change that
  # ships gated, not here.
  class TileRegistry
    class BadRegistry < StandardError; end

    REQUIRED_TYPE_KEYS = %w[char int_grid render footstep passability].freeze
    OPTIONAL_TYPE_KEYS = %w[variants].freeze
    RESERVED_TYPE_KEYS = %w[hooks].freeze
    PASSABILITIES = %w[wall floor].freeze
    WALL_CHARS = Core::TileMap::WALL_CHARS

    attr_reader :types

    # Accepts DataStore-symbolized or plain-string keys (the importer reads
    # the same file standalone); normalizes to strings internally.
    def initialize(cfg)
      raw = deep_stringify(cfg)
      types = raw["types"]
      raise BadRegistry, "tiles registry needs a non-empty \"types\" map" unless types.is_a?(Hash) && !types.empty?
      unknown_root = raw.keys - ["types"]
      raise BadRegistry, "tiles registry unknown root key(s) #{unknown_root.inspect}" unless unknown_root.empty?
      @types = {}
      types.each { |id, spec| @types[id] = validate_type!(id, spec) }
      validate_uniqueness!
      validate_wall_law!
    end

    def type(id) = @types[id]
    def type_for_char(char) = @types.find { |_, t| t["char"] == char }&.first
    def char_for_int_grid(value) = @types.values.find { |t| t["int_grid"] == value }&.[]("char")
    def int_grid_values = @types.values.map { |t| t["int_grid"] }.sort

    # char => type id, for zones that declare no tile_types override.
    def default_char_map = @types.to_h { |id, t| [t["char"], id] }

    # Cross-reference check for a LOADED zone map (World wires this after
    # TileMap's own shape validation). Scope law (T3): only the chars the
    # zone's GRID actually uses — plus its tile_types overrides — are
    # checked, so registering a new type never invalidates zones that don't
    # use it (the live-world guarantee). Every checked char must name a
    # registered type whose render ref AND variant refs exist in the zone's
    # palette. Raises TileMap::BadMap so refusals surface in the
    # zone-loading register.
    def validate_map!(map)
      effective = default_char_map.merge(map.tile_types || {})
      used = (map.used_chars + (map.tile_types || {}).keys).uniq
      used.each do |ch|
        type_id = effective[ch]
        unless type_id
          raise Core::TileMap::BadMap,
                "zone #{map.name}: grid char #{ch.inspect} has no registered tile type " \
                "(neither the registry default map nor this zone's tile_types names it)"
        end
        spec = @types[type_id]
        unless spec
          raise Core::TileMap::BadMap,
                "zone #{map.name}: tile char #{ch.inspect} maps to #{type_id.inspect}: unknown tile type"
        end
        # v20 T5 (review advisory, executed): a zone's tile_types override
        # must not LIE about blocking — the grid-char set decides passability
        # (TileMap law), so a WALL_CHARS char remapped onto a walkable type
        # would render floor-ish yet block, and a passability-"wall" type on
        # a non-blocking char would read wall yet walk. Both refuse NAMED.
        wall_char = Core::TileMap::WALL_CHARS.include?(ch)
        wall_type = spec["passability"] == "wall"
        if wall_char != wall_type
          raise Core::TileMap::BadMap,
                "zone #{map.name}: tile char #{ch.inspect} maps to #{type_id.inspect} " \
                "(passability #{spec['passability'].inspect}) but #{ch.inspect} is " \
                "#{wall_char ? 'IN' : 'NOT in'} TileMap's wall-char set — blocking is " \
                "the grid-char law and the mapping may not disagree with it"
        end
        ([spec["render"]] + (spec["variants"] || [])).each do |ref|
          next if map.palette.key?(ref.to_sym)
          raise Core::TileMap::BadMap,
                "zone #{map.name}: tile type #{type_id} renders palette ref " \
                "#{ref.inspect}, absent from this zone's palette"
        end
      end
      nil
    end

    # T3 footstep consumption: the material key under a tile, through the
    # zone's effective char→type mapping. nil out of bounds or for chars
    # with no registered type (bare fixture maps) — callers treat nil as
    # silence, never an error (presentation must not raise mid-frame).
    def material_at(map, tx, ty)
      ch = map.char_at(tx, ty)
      return nil unless ch
      type_id = (map.tile_types || {})[ch] || default_char_map[ch]
      @types.dig(type_id, "footstep")
    end

    private

    def validate_type!(id, spec)
      raise BadRegistry, "tile type id #{id.inspect} must be snake_case" unless id.match?(/\A[a-z][a-z0-9_]*\z/)
      raise BadRegistry, "tile type #{id}: spec must be a map" unless spec.is_a?(Hash)
      missing = REQUIRED_TYPE_KEYS - spec.keys
      raise BadRegistry, "tile type #{id}: missing #{missing.inspect}" unless missing.empty?
      reserved = spec.keys & RESERVED_TYPE_KEYS
      unless reserved.empty?
        raise BadRegistry, "tile type #{id}: #{reserved.inspect} are reserved keys " \
                           "(hooks land in their own gated cycles, not here)"
      end
      unknown = spec.keys - REQUIRED_TYPE_KEYS - OPTIONAL_TYPE_KEYS
      raise BadRegistry, "tile type #{id}: unknown key(s) #{unknown.inspect}" unless unknown.empty?
      unless spec["char"].is_a?(String) && spec["char"].length == 1
        raise BadRegistry, "tile type #{id}: char must be a single character"
      end
      unless spec["int_grid"].is_a?(Integer) && spec["int_grid"] >= 1
        raise BadRegistry, "tile type #{id}: int_grid must be an Integer >= 1 (0 is LDtk void)"
      end
      %w[render footstep].each do |k|
        unless spec[k].is_a?(String) && !spec[k].empty?
          raise BadRegistry, "tile type #{id}: #{k} must be a non-empty String"
        end
      end
      unless PASSABILITIES.include?(spec["passability"])
        raise BadRegistry, "tile type #{id}: passability #{spec['passability'].inspect} not in " \
                           "#{PASSABILITIES.inspect} (\"swim\" is reserved, post-verdict)"
      end
      validate_variants!(id, spec)
      spec
    end

    # T3 visual variants: an optional list of ALTERNATE render palette refs
    # (the base `render` is implicit pick 0). Authored data only — selection
    # never randomizes at runtime (D7 determinism hygiene).
    def validate_variants!(id, spec)
      return unless spec.key?("variants")
      v = spec["variants"]
      unless v.is_a?(Array) && !v.empty? && v.all? { |r| r.is_a?(String) && !r.empty? }
        raise BadRegistry, "tile type #{id}: variants must be a non-empty Array of " \
                           "palette-ref Strings (authored alternates to render)"
      end
      raise BadRegistry, "tile type #{id}: variants carries duplicates" if v.uniq.length != v.length
    end

    def validate_uniqueness!
      %w[char int_grid].each do |k|
        seen = {}
        @types.each do |id, t|
          if (other = seen[t[k]])
            raise BadRegistry, "tile types #{other} and #{id} share #{k} #{t[k].inspect}"
          end
          seen[t[k]] = id
        end
      end
    end

    def validate_wall_law!
      @types.each do |id, t|
        if t["passability"] == "wall" && !WALL_CHARS.include?(t["char"])
          raise BadRegistry, "tile type #{id}: passability \"wall\" requires a char in " \
                             "#{WALL_CHARS.inspect} (TileMap's wall-char set; rewiring " \
                             "passable? is a gated sim change)"
        end
        if WALL_CHARS.include?(t["char"]) && t["passability"] != "wall"
          raise BadRegistry, "tile type #{id}: char #{t['char'].inspect} is in TileMap's " \
                             "wall-char set and requires passability \"wall\""
        end
      end
    end

    def deep_stringify(obj)
      case obj
      when Hash then obj.to_h { |k, v| [k.to_s, deep_stringify(v)] }
      when Array then obj.map { |v| deep_stringify(v) }
      else obj
      end
    end
  end
end
