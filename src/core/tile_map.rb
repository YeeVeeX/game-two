module Core
  # Tile map parsed from a zone JSON config. The grid IS the world (Tibia
  # doctrine): a tile is passable or it isn't — no pixel-perfect collision.
  # Engine-agnostic; rendering decides what a wall looks like.
  class TileMap
    class BadMap < StandardError; end

    WALL_CHAR = "#".freeze

    # v2 (world-builder T2): typed transitions + region intents. Absent
    # type = today's gate/breach shape — every v1 file reads unchanged.
    TRANSITION_TYPES = %w[stairs_up stairs_down hole rope_spot].freeze
    REGION_INTENTS = %w[town dungeon guard].freeze

    attr_reader :cols, :rows, :tile_size, :pack_spawn, :enemy_spawns,
                :display_name, :palette, :transitions, :stations, :drop_gradient,
                :hub, :gradient_anchor, :name, :decor, :floor, :regions, :tile_types,
                :water_drained_by

    def initialize(cfg)
      @tile_size = cfg.fetch(:tile_size)
      # v13 i18n: internal zone name keys locale lookups ("zone.<name>.…");
      # optional so fixture maps stay valid — nil name just falls back to
      # the canonical display_name at render.
      @name = cfg.fetch(:name, nil)
      @display_name = cfg.fetch(:display_name)
      @palette = cfg.fetch(:palette)
      @grid = cfg.fetch(:tiles).map(&:chars)
      @rows = @grid.length
      @cols = @grid.first.length
      @pack_spawn = cfg.fetch(:pack_spawn)
      @enemy_spawns = cfg.fetch(:enemy_spawns, {})
      @transitions = cfg.fetch(:transitions, [])
      @stations = cfg.fetch(:stations, [])
      @drop_gradient = cfg.fetch(:drop_gradient, nil)
      # v12: hub zones re-anchor the pack's home; the gradient anchor pins
      # the gate-field origin so arrival-list ORDER can never flip a zone's
      # band map (sorted zone keys reorder arrivals when zones are added).
      @hub = cfg.fetch(:hub, false)
      @gradient_anchor = cfg.fetch(:gradient_anchor, nil)
      # v16 (b): authored landmark features — RENDER-ONLY (never blocking,
      # never validated against passability: braziers mount on walls).
      @decor = cfg.fetch(:decor, [])
      # v2 (world-builder T2, D3/D9/D7 — all additive, defaults preserve
      # every v1 file byte-for-byte): floors are zone metadata (0 =
      # surface, negative = down); regions are a named-rect DATA LAYER
      # (no rules read them — D9); tile_types optionally remaps grid
      # chars onto data/tiles.json type ids (default mapping comes from
      # the registry). Nothing in the sim consumes any of these yet —
      # behavior lands in T3/T4/T5, one gated piece at a time.
      @floor = cfg.fetch(:floor, 0)
      @regions = (cfg.fetch(:regions, []) || []).map { |r| normalize_region(r) }
      @tile_types = cfg[:tile_types]&.to_h { |k, v| [k.to_s, v] }
      # T4 (the well): OPTIONAL presentation link — when the breach-family
      # fact [zone, water_drained_by] is set, water-typed tiles RENDER their
      # drained look (renderer + god-view custody). Pure data here: no sim
      # system reads it, passability never changes with state (the '#' law).
      @water_drained_by = cfg.fetch(:water_drained_by, nil)
      validate!
    end

    def passable?(tx, ty)
      return false if tx.negative? || ty.negative? || tx >= @cols || ty >= @rows
      @grid[ty][tx] != WALL_CHAR
    end

    def wall?(tx, ty) = !passable?(tx, ty)

    # T3 readers: the grid char under a tile (nil out of bounds — footstep
    # material derivation) and the distinct chars this zone's grid uses
    # (TileRegistry#validate_map!'s scope law). Pure readers of the
    # immutable grid; memoized where derivation costs.
    def char_at(tx, ty)
      return nil if tx.negative? || ty.negative? || tx >= @cols || ty >= @rows
      @grid[ty][tx]
    end

    def used_chars = @used_chars ||= @grid.flatten.uniq.freeze

    def transition_at(tx, ty)
      @transitions.find { |t| t[:at] == [tx, ty] }
    end

    def station_at(tx, ty)
      @stations.find { |s| s[:at] == [tx, ty] }
    end

    def pixel_width = @cols * @tile_size
    def pixel_height = @rows * @tile_size

    private

    def validate!
      raise BadMap, "empty map" if @rows.zero? || @cols.zero?
      @grid.each_with_index do |row, y|
        raise BadMap, "row #{y} has #{row.length} tiles, expected #{@cols}" if row.length != @cols
      end
      raise BadMap, "pack_spawn needs >= 3 tiles" if @pack_spawn.length < 3
      raise BadMap, "pack_spawn tiles must be distinct" if @pack_spawn.uniq.length != @pack_spawn.length
      @pack_spawn.each { |s| check_passable!("pack_spawn", s) }
      @enemy_spawns.each_value { |spawns| spawns.each { |s| check_passable!("enemy spawn", s) } }
      @transitions.each { |t| check_passable!("transition", t[:at]) }
      @stations.each { |s| check_passable!("station", s[:at]) }
      validate_seal_opens!
      check_passable!("gradient_anchor", @gradient_anchor) if @gradient_anchor
      validate_v2!
    end

    # Schema v2 (T2): shape-only — no behavior reads these fields yet.
    def validate_v2!
      raise BadMap, "floor must be an Integer (got #{@floor.inspect})" unless @floor.is_a?(Integer)
      @transitions.each { |t| validate_transition_type!(t) }
      validate_regions!
      validate_tile_types!
      validate_water_drained_by!
    end

    def validate_transition_type!(t)
      type = t[:type]
      if type && !TRANSITION_TYPES.include?(type)
        raise BadMap, "transition at #{t[:at].inspect}: unknown type #{type.inspect} " \
                      "(valid: #{TRANSITION_TYPES.join(', ')}; absent = gate)"
      end
      # T4 (the boss gate): OPTIONAL fact-gate — the way stays shut until the
      # persisted boss_1_defeats counter reaches this value (World custody;
      # a breach-variant reading a fact instead of a price — spec §THE GATE).
      rd = t[:requires_defeats]
      if rd && !(rd.is_a?(Integer) && rd >= 1)
        raise BadMap, "transition at #{t[:at].inspect}: requires_defeats must be an " \
                      "Integer >= 1 (got #{rd.inspect})"
      end
      # T5 (P9): OPTIONAL level fact-gate — the way stays shut until the
      # LIVE pack level reaches this value (requires_defeats' full sibling;
      # gates compose as independent ANDs — the s34 comment law below).
      rl = t[:requires_level]
      if rl && !(rl.is_a?(Integer) && rl >= 1)
        raise BadMap, "transition at #{t[:at].inspect}: requires_level must be an " \
                      "Integer >= 1 (got #{rl.inspect})"
      end
      unlock = t[:stairs_unlocked_by]
      return unless unlock
      unless type == "hole"
        raise BadMap, "transition at #{t[:at].inspect}: stairs_unlocked_by is legal on " \
                      "type \"hole\" only (D4 amendment), got type #{type.inspect}"
      end
      unless unlock.is_a?(String) && !unlock.empty?
        raise BadMap, "transition at #{t[:at].inspect}: stairs_unlocked_by must be a " \
                      "non-empty breach-family fact name"
      end
    end

    def validate_regions!
      seen = {}
      @regions.each do |r|
        id = r[:id]
        raise BadMap, "region id must be a non-empty String (got #{id.inspect})" unless id.is_a?(String) && !id.empty?
        raise BadMap, "duplicate region id #{id.inspect}" if seen[id]
        seen[id] = true
        unless REGION_INTENTS.include?(r[:intent])
          raise BadMap, "region #{id}: unknown intent #{r[:intent].inspect} (valid: #{REGION_INTENTS.join(', ')})"
        end
        rect = r[:rect]
        unless rect.is_a?(Array) && rect.length == 4 && rect.all? { |v| v.is_a?(Integer) }
          raise BadMap, "region #{id}: rect must be [x, y, w, h] Integers (got #{rect.inspect})"
        end
        x, y, w, h = rect
        if x.negative? || y.negative? || w < 1 || h < 1 || x + w > @cols || y + h > @rows
          raise BadMap, "region #{id}: rect #{rect.inspect} outside #{@cols}x#{@rows} map"
        end
      end
    end

    # tile_types: optional char => type-id remap over the registry's
    # default mapping. SHAPE only here — the cross-reference against the
    # registry lives in TileRegistry#validate_map! (World wires it; bare
    # fixture maps stay valid — the name-key precedent).
    def validate_tile_types!
      return unless @tile_types
      @tile_types.each do |ch, type_id|
        raise BadMap, "tile_types key #{ch.inspect} must be a single character" unless ch.length == 1
        unless type_id.is_a?(String) && !type_id.empty?
          raise BadMap, "tile_types[#{ch.inspect}] must be a type id String"
        end
      end
    end

    def normalize_region(r)
      { id: r[:id], rect: r[:rect], intent: r[:intent] }
    end

    # T4 shape law: a drained-look link needs a legal tile AND the palette
    # ref it swaps to — a missing water_drained key would crash the draw
    # path mid-frame (presentation must refuse at load, never at draw).
    def validate_water_drained_by!
      return unless @water_drained_by
      w = @water_drained_by
      unless w.is_a?(Array) && w.length == 2 && w.all? { |v| v.is_a?(Integer) } &&
             w[0] >= 0 && w[1] >= 0 && w[0] < @cols && w[1] < @rows
        raise BadMap, "water_drained_by must be an in-bounds [x, y] tile (got #{w.inspect})"
      end
      unless @palette.key?(:water_drained)
        raise BadMap, "water_drained_by declared but palette carries no water_drained ref " \
                      "(the drained look must be authored)"
      end
    end

    # Seal opens law (s33; the refusal RECORDED at s31 + s32): downstream,
    # a seal's opens is consumed BLIND — interact_seal reads it into
    # breached? -> spend_banked -> restore_breach!, and the price sheet
    # feeds it to the breached callback pre-breach — so an ill-shaped
    # opens (nil / string pair / float / 3-element) or a legal-shaped
    # opens naming NO transition BURNS the toll, opens nothing visible,
    # and persists the inert fact into the save at clean quit. The save
    # side is already guarded (SaveState's breached-vs-opens cross-check
    # at restore); this is the missing zone-side half: refuse NAMED at
    # load. Shape first (the s32 idiom), then bounds (a coordinate typo
    # reads differently from a missing Transition entity), then the
    # semantic kill — opens must name a transition tile in THIS zone.
    # The importer's round-trip gate (validate_emitted!) composes this
    # law automatically — hand-edited zones were the exposed path.
    #
    # s34 gating law (the s33 review's recorded nit, grilled + promoted):
    # the named transition must ALSO carry truthy sealed — the exact read
    # the WAY-consumers make (Crossing#open?, Renderer.way_locked?:
    # `t[:sealed] && !breached`). On an unsealed way the way never moves:
    # a requires_defeats-only way stays shut regardless (independent AND
    # branch), an ungated way was open before the toll — either way TOLL
    # PAID burns banked and opens nothing. One more reader rides the
    # fact: Renderer.water_drained? (render-only, keyed by tile alias,
    # sealed-independent) — a drain-only seal onto an unsealed way was
    # expressible pre-s34 and is REFUSED BY DESIGN here (zone_7 composes
    # the pattern honestly: the drained well IS the sealed hole).
    # requires_defeats may CO-EXIST with sealed: true (both branches read
    # their own facts); "toll bypasses the boss gate" would need OR
    # semantics in open? — a sim change, not a validator relaxation.
    def validate_seal_opens!
      @stations.each do |s|
        next unless s[:type] == "seal"
        opens = s[:opens]
        unless tile_pair?(opens)
          raise BadMap, "seal at #{s[:at].inspect}: opens must be an [x, y] tile (got #{opens.inspect})"
        end
        ox, oy = opens
        if ox.negative? || oy.negative? || ox >= @cols || oy >= @rows
          raise BadMap, "seal at #{s[:at].inspect}: opens #{opens.inspect} outside #{@cols}x#{@rows} map"
        end
        t = transition_at(ox, oy)
        if t.nil?
          raise BadMap, "seal at #{s[:at].inspect}: opens #{opens.inspect} names no transition " \
                        "(the toll would open nothing)"
        end
        next if t[:sealed]
        raise BadMap, "seal at #{s[:at].inspect}: opens #{opens.inspect} names an unsealed " \
                      "transition (only a sealed: true way reads the breach — the toll " \
                      "would open nothing)"
      end
    end

    # Shape law (s31 review nit 1): destructuring a blind tile split
    # ill-shaped data two ways — UNNAMED crashes (nil / string pairs feed
    # passable?'s .negative?) and WORSE, silent mis-validation (Array#[]
    # truncates Floats, a 3-element tile drops its tail — both validate
    # against the WRONG tile while transition_at's == never matches: a
    # DEAD transition). Shape refuses NAMED first; then today's
    # passability check, unchanged. One choke point covers every caller
    # (pack_spawn, enemy spawns, transitions, stations, gradient_anchor);
    # the seal opens law above shares the predicate (never drift two
    # copies of the tile shape).
    def tile_pair?(tile)
      tile.is_a?(Array) && tile.length == 2 && tile.all? { |v| v.is_a?(Integer) }
    end

    def check_passable!(label, tile)
      raise BadMap, "#{label} must be an [x, y] tile (got #{tile.inspect})" unless tile_pair?(tile)
      tx, ty = tile
      raise BadMap, "#{label} [#{tx}, #{ty}] is not passable" unless passable?(tx, ty)
    end
  end
end
