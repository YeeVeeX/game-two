require "core/tile_map"

module Core
  # Tile-type registry v0 (world-builder D7, T2): data/tiles.json declares
  # each tile type's authoring glyph (`char`), LDtk IntGrid value
  # (`int_grid`), render palette ref (`render`), footstep material
  # (`footstep`, declared only — nothing consumes it until T3), and
  # `passability` ("wall"/"floor"; "swim" is reserved for a post-verdict
  # sim-class increment and REFUSED in v0). `hooks` and `variants` are
  # reserved key names (D7: hazard/spawn_affinity hooks, visual variants)
  # — their presence refuses NAMED until their gated cycles land.
  #
  # v0 wall law: TileMap#passable? stays the '#' check (byte-identical sim
  # for the live world). The registry therefore ENFORCES that '#' and
  # passability "wall" imply each other — rewiring passable? through the
  # registry is a sim-visible change that ships gated, not here.
  class TileRegistry
    class BadRegistry < StandardError; end

    REQUIRED_TYPE_KEYS = %w[char int_grid render footstep passability].freeze
    RESERVED_TYPE_KEYS = %w[hooks variants].freeze
    PASSABILITIES = %w[wall floor].freeze
    WALL_CHAR = "#".freeze

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
    # TileMap's own shape validation): every char in the zone's effective
    # mapping must name a registered type whose render palette ref exists
    # in the zone's palette. Raises TileMap::BadMap so refusals surface
    # in the zone-loading register.
    def validate_map!(map)
      effective = default_char_map.merge(map.tile_types || {})
      effective.each do |ch, type_id|
        spec = @types[type_id]
        unless spec
          raise Core::TileMap::BadMap,
                "zone #{map.name}: tile_types[#{ch.inspect}] = #{type_id.inspect}: unknown tile type"
        end
        next if map.palette.key?(spec["render"].to_sym)
        raise Core::TileMap::BadMap,
              "zone #{map.name}: tile type #{type_id} renders palette ref " \
              "#{spec['render'].inspect}, absent from this zone's palette"
      end
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
                           "(hooks/variants land in their own gated cycles, not v0)"
      end
      unknown = spec.keys - REQUIRED_TYPE_KEYS
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
      spec
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
        if t["passability"] == "wall" && t["char"] != WALL_CHAR
          raise BadRegistry, "tile type #{id}: passability \"wall\" requires char \"#\" in v0 " \
                             "(TileMap's wall law; rewiring is a gated sim change)"
        end
        if t["char"] == WALL_CHAR && t["passability"] != "wall"
          raise BadRegistry, "tile type #{id}: char \"#\" requires passability \"wall\" in v0"
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
