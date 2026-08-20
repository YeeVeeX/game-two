# World-builder T2 (D2): the PRODUCTION importer — the ONLY door from
# LDtk output to zone JSON. LDtk owns SPATIAL truth (IntGrid tiles,
# entities, the display_name/floor level fields); the per-zone sidecar
# owns presentation/tuning scalars (palette incl. alpha, drop_gradient,
# gradient_anchor, tile_size). The emitter below defines the CANONICAL
# zone-JSON byte format; import -> emit -> import is a byte-stable
# fixpoint (enforced by test/tools/import_ldtk_test.rb).
#
# Every refusal is NAMED (save-decoder register) and exits nonzero from
# the CLI. The refusal set implements the T1 findings table
# (drafts/_ldtk-spike-findings-20260819.md) — pin ceremony, tamper
# tells, void cells, order discipline, template-shape pins.
#
# dev-tooling ONLY: no game-runtime require may reach into tools/ (the
# game boots without this file). This file reaching INTO src/ is the
# allowed direction.
#
# Usage:
#   ruby tools/import_ldtk.rb <project.ldtk> --sidecars <dir> --out <dir>
#                             [--zones data/zones] [--tiles data/tiles.json]
#
# Sidecar file per zone: <sidecars>/<zone>.sidecar.json
# Known-zone universe for transition targets = project levels + *.json
# in --zones (the live world). Output NEVER defaults into data/zones —
# merging into the live world is a deliberate copy (D12 merge law).

$LOAD_PATH.unshift File.expand_path("../src", __dir__)

require "json"
require "core/tile_map"
require "core/tile_registry"

module Tools
  class LdtkImporter
    class Refusal < StandardError; end

    PINNED_JSON_VERSION = "1.5.3".freeze # D1: pin on jsonVersion ONLY (appBuildId churns per resave)
    PINNED_IDENTIFIER_STYLE = "Free".freeze # wrinkle 5: Capitalize would rewrite zone names
    ZONE_NAME_SHAPE = /\A[a-z][a-z0-9_]*\z/
    ALLOWED_WORLD_XY = [-1, 0].freeze # -1 = auto layouts (observed in vendor resave), 0 = manual origin
    LAYERS = { "Terrain" => "IntGrid", "Entities" => "Entities" }.freeze

    # Entity field contract: required fields must be present and non-null;
    # optional fields may be null/absent. Unknown identifiers refuse
    # (template drift is deliberate re-pinning, never silent).
    ENTITY_FIELDS = {
      "Station" => { required: %w[type], optional: %w[price opens line] },
      "Transition" => { required: %w[to spawn], optional: %w[sealed type stairs_unlocked_by] },
      "PackSpawn" => { required: %w[order], optional: [] },
      "EnemySpawn" => { required: %w[kind], optional: [] },
      "Region" => { required: %w[id intent], optional: [] }
    }.freeze

    SIDECAR_REQUIRED = %w[palette tile_size].freeze
    SIDECAR_OPTIONAL = %w[drop_gradient gradient_anchor].freeze

    # registry: Core::TileRegistry (IntGrid value -> glyph mapping, D7).
    # sidecars: { zone_name => Hash } (plain JSON.parse, string keys).
    # known_zones: Array of zone names that transitions may target
    # (callers pass the live data/zones/*.json basenames; project levels
    # are added automatically).
    def initialize(registry:, sidecars:, known_zones: [])
      @registry = registry
      @sidecars = sidecars
      @known_zones = known_zones
    end

    # doc: parsed .ldtk project (plain JSON.parse, string keys).
    # -> { zone_name => canonical zone JSON bytes }
    def import(doc)
      refuse "jsonVersion #{doc['jsonVersion'].inspect} != pinned #{PINNED_JSON_VERSION.inspect} " \
             "(D1 pin ceremony: upgrades are a deliberate re-pin, never an accident)" \
        unless doc["jsonVersion"] == PINNED_JSON_VERSION
      refuse "identifierStyle #{doc['identifierStyle'].inspect} != pinned #{PINNED_IDENTIFIER_STYLE.inspect} " \
             "(Capitalize/Lowercase rewrite level identifiers)" \
        unless doc["identifierStyle"] == PINNED_IDENTIFIER_STYLE
      refuse "externalLevels: true is unsupported (separate .ldtkl files null layerInstances)" \
        if doc["externalLevels"]

      levels = doc["levels"] || []
      refuse "project has no levels" if levels.empty?
      names = levels.map { |l| l["identifier"] }
      dup = names.tally.select { |_, c| c > 1 }.keys
      refuse "duplicate level identifier(s) #{dup.inspect}" unless dup.empty?

      universe = (@known_zones + names).uniq
      levels.to_h { |level| import_level(level, universe) }
    end

    # Canonical serializer — THE zone-JSON byte format (D2). Public on
    # purpose: the fixpoint property (emit(parse(emit(x))) == emit(x)) is
    # enforced by test through this exact method.
    def emit(zone_hash) = JSON.pretty_generate(zone_hash) + "\n"

    private

    def refuse(msg) = raise(Refusal, msg)

    def import_level(level, universe)
      zone = level["identifier"]
      refuse "level identifier #{zone.inspect} is not a zone-name shape (#{ZONE_NAME_SHAPE.inspect})" \
        unless zone&.match?(ZONE_NAME_SHAPE)
      %w[worldX worldY].each do |k|
        refuse "level #{zone}: #{k}=#{level[k].inspect} not in #{ALLOWED_WORLD_XY.inspect} " \
               "(multi-level world offsets are a later, explicit mapping)" \
          unless ALLOWED_WORLD_XY.include?(level[k])
      end

      layers = level["layerInstances"]
      refuse "level #{zone}: layerInstances is null (externalLevels project?)" if layers.nil?
      layer_index = validate_layers!(zone, layers)
      terrain = layer_index.fetch("Terrain")
      entities = layer_index.fetch("Entities")
      grid_size = terrain["__gridSize"]

      lf = level_fields(zone, level)
      tiles = decode_int_grid(zone, terrain)
      ents = decode_entities(zone, entities, grid_size, universe)
      sidecar = sidecar_for(zone)

      zone_hash = assemble(zone, lf, tiles, ents, sidecar)
      bytes = emit(zone_hash)
      validate_emitted!(zone, bytes)
      [zone, bytes]
    end

    def validate_layers!(zone, layers)
      index = {}
      layers.each do |l|
        id = l["__identifier"]
        expected_type = LAYERS[id]
        refuse "level #{zone}: unknown layer #{id.inspect} (template pins exactly #{LAYERS.keys.join(' + ')})" \
          unless expected_type
        refuse "level #{zone}: layer #{id} type #{l['__type'].inspect} != #{expected_type.inspect}" \
          unless l["__type"] == expected_type
        refuse "level #{zone}: duplicate layer #{id}" if index.key?(id)
        unless (l["__pxTotalOffsetX"] || 0).zero? && (l["__pxTotalOffsetY"] || 0).zero?
          refuse "level #{zone}: layer #{id} carries a pixel offset " \
                 "(#{l['__pxTotalOffsetX']},#{l['__pxTotalOffsetY']}) — offsets shift px->grid math"
        end
        index[id] = l
      end
      missing = LAYERS.keys - index.keys
      refuse "level #{zone}: missing layer(s) #{missing.inspect}" unless missing.empty?
      unless index["Terrain"]["__gridSize"] == index["Entities"]["__gridSize"]
        refuse "level #{zone}: Terrain gridSize #{index['Terrain']['__gridSize']} != " \
               "Entities gridSize #{index['Entities']['__gridSize']}"
      end
      index
    end

    # Level custom fields: display_name required; floor optional Int
    # (wrinkle 9 — the natural LDtk home for zone metadata).
    def level_fields(zone, level)
      known = { "display_name" => "String", "floor" => "Int" }
      out = {}
      (level["fieldInstances"] || []).each do |fi|
        id = fi["__identifier"]
        refuse "level #{zone}: unknown level field #{id.inspect}" unless known.key?(id)
        out[id] = field_value(fi, "level #{zone}")
      end
      refuse "level #{zone}: display_name level field missing or empty" \
        if !out["display_name"].is_a?(String) || out["display_name"].empty?
      if out.key?("floor") && !out["floor"].nil? && !out["floor"].is_a?(Integer)
        refuse "level #{zone}: floor must be an Int"
      end
      out
    end

    def decode_int_grid(zone, terrain)
      w = terrain["__cWid"]
      h = terrain["__cHei"]
      csv = terrain["intGridCsv"]
      refuse "level #{zone}: intGridCsv length #{csv&.length.inspect} != #{w}x#{h}" \
        unless csv.is_a?(Array) && csv.length == w * h
      (0...h).map do |y|
        (0...w).map do |x|
          v = csv[y * w + x]
          @registry.char_for_int_grid(v) ||
            refuse("level #{zone}: IntGrid value #{v} at [#{x},#{y}] has no tile type " \
                   "(0 = void — non-rectangular zones unsupported; new values are a " \
                   "deliberate data/tiles.json addition)")
        end.join
      end
    end

    def decode_entities(zone, layer, grid_size, universe)
      out = { stations: [], transitions: [], pack: [], enemy_spawns: {}, regions: [] }
      occupied = {}
      (layer["entityInstances"] || []).each do |ei|
        kind = ei["__identifier"]
        spec = ENTITY_FIELDS[kind]
        refuse "level #{zone}: unknown entity #{kind.inspect}" unless spec
        at = entity_tile(zone, ei, grid_size)
        ctx = "level #{zone}: #{kind} at #{at.inspect}"
        f = entity_fields(ctx, ei, spec)
        # One tile, one entity — regions are a rect DATA LAYER above the
        # grid and exempt by design (a town region covers stations).
        unless kind == "Region"
          if (other = occupied[at])
            refuse "level #{zone}: #{kind} overlaps #{other} on tile #{at.inspect}"
          end
          occupied[at] = kind
        end
        case kind
        when "Station" then out[:stations] << station(ctx, at, f)
        when "Transition" then out[:transitions] << transition(ctx, at, f, universe)
        when "PackSpawn" then out[:pack] << [f["order"], at]
        when "EnemySpawn"
          refuse "#{ctx}: kind must be a non-empty String" unless f["kind"].is_a?(String) && !f["kind"].empty?
          (out[:enemy_spawns][f["kind"]] ||= []) << at
        when "Region" then out[:regions] << region(ctx, ei, f, grid_size)
        end
      end
      validate_pack!(zone, out[:pack])
      out
    end

    def entity_tile(zone, ei, grid_size)
      refuse "level #{zone}: entity #{ei['__identifier']} pivot #{ei['__pivot'].inspect} != [0, 0] " \
             "(pinned: pivot shifts px->grid derivation)" unless ei["__pivot"] == [0, 0]
      px = ei["px"]
      unless (px[0] % grid_size).zero? && (px[1] % grid_size).zero?
        refuse "level #{zone}: entity #{ei['__identifier']} px #{px.inspect} off the #{grid_size}px grid"
      end
      derived = [px[0] / grid_size, px[1] / grid_size]
      unless ei["__grid"] == derived
        refuse "level #{zone}: entity #{ei['__identifier']} __grid #{ei['__grid'].inspect} disagrees " \
               "with px#{px.inspect}/#{grid_size} (hand-edit tell)"
      end
      derived
    end

    def entity_fields(ctx, ei, spec)
      known = spec[:required] + spec[:optional]
      out = {}
      (ei["fieldInstances"] || []).each do |fi|
        id = fi["__identifier"]
        refuse "#{ctx}: unknown field #{id.inspect}" unless known.include?(id)
        out[id] = field_value(fi, ctx)
      end
      spec[:required].each do |id|
        refuse "#{ctx}: required field #{id.inspect} missing or null" if out[id].nil?
      end
      out
    end

    # Wrinkle 1 (hit live in the spike): 1.5.3 LOADS from
    # realEditorValues, not __value. We READ __value (the documented
    # final value) but REFUSE when the two disagree — a hand-edited
    # __value is silently ignored by the editor, so disagreement is a
    # tamper/hand-edit tell, never a formatting choice.
    def field_value(fi, ctx)
      v = fi["__value"]
      return nil if v.nil? # consistent-null: optional field left empty
      real = fi["realEditorValues"]
      r = real.is_a?(Array) ? real[0] : nil
      if r.nil?
        refuse "#{ctx}: field #{fi['__identifier']} carries __value #{v.inspect} with no " \
               "realEditorValues backing (hand-edit tell — 1.5.3 loads realEditorValues)"
      end
      ok =
        case fi["__type"]
        when "String", "Multilines" then r["id"] == "V_String" && r["params"]&.first == v
        when "Int" then r["id"] == "V_Int" && r["params"]&.first == v
        when "Bool" then r["id"] == "V_Bool" && r["params"]&.first == v
        when "Point"
          r["id"] == "V_String" && r["params"]&.first == "#{v['cx']},#{v['cy']}"
        else
          refuse "#{ctx}: field #{fi['__identifier']} type #{fi['__type'].inspect} unsupported " \
                 "(supported: String, Multilines, Int, Bool, Point)"
        end
      unless ok
        refuse "#{ctx}: field #{fi['__identifier']} __value #{v.inspect} disagrees with " \
               "realEditorValues #{r.inspect} (hand-edit tell)"
      end
      v
    end

    def point(ctx, name, v)
      refuse "#{ctx}: #{name} must be a Point" unless v.is_a?(Hash) && v["cx"].is_a?(Integer) && v["cy"].is_a?(Integer)
      [v["cx"], v["cy"]]
    end

    def station(ctx, at, f)
      s = { "type" => f["type"], "at" => at }
      s["price"] = f["price"] if f["price"]
      s["opens"] = point(ctx, "opens", f["opens"]) if f["opens"]
      s["line"] = f["line"] if f["line"]
      s
    end

    def transition(ctx, at, f, universe)
      unless universe.include?(f["to"])
        refuse "#{ctx}: transition targets unknown zone #{f['to'].inspect} " \
               "(known: project levels + the zones dir)"
      end
      t = { "at" => at, "to" => f["to"], "spawn" => point(ctx, "spawn", f["spawn"]) }
      t["sealed"] = true if f["sealed"] == true
      t["type"] = f["type"] if f["type"]
      t["stairs_unlocked_by"] = f["stairs_unlocked_by"] if f["stairs_unlocked_by"]
      t
    end

    def region(ctx, ei, f, grid_size)
      w, h = ei["width"], ei["height"]
      unless (w % grid_size).zero? && (h % grid_size).zero?
        refuse "#{ctx}: Region size #{w}x#{h}px off the #{grid_size}px grid"
      end
      { "id" => f["id"], "rect" => ei["__grid"] + [w / grid_size, h / grid_size],
        "intent" => f["intent"] }
    end

    def validate_pack!(zone, pack)
      orders = pack.map(&:first)
      refuse "level #{zone}: PackSpawn order missing" if orders.any?(&:nil?)
      dup = orders.tally.select { |_, c| c > 1 }.keys
      refuse "level #{zone}: duplicate PackSpawn order #{dup.inspect} " \
             "(array order is authoring-fragile; order is the law)" unless dup.empty?
    end

    def sidecar_for(zone)
      sidecar = @sidecars[zone]
      refuse "level #{zone}: no sidecar (LDtk owns spatial truth; palette/tile_size/" \
             "drop_gradient/gradient_anchor live in <zone>.sidecar.json — D2)" unless sidecar
      unknown = sidecar.keys - SIDECAR_REQUIRED - SIDECAR_OPTIONAL
      refuse "level #{zone}: sidecar unknown key(s) #{unknown.inspect} " \
             "(the sidecar owns #{(SIDECAR_REQUIRED + SIDECAR_OPTIONAL).join('/')} ONLY — D2)" \
        unless unknown.empty?
      missing = SIDECAR_REQUIRED - sidecar.keys
      refuse "level #{zone}: sidecar missing #{missing.inspect}" unless missing.empty?
      refuse "level #{zone}: sidecar tile_size must be an Integer" unless sidecar["tile_size"].is_a?(Integer)
      refuse "level #{zone}: sidecar palette must be a map" unless sidecar["palette"].is_a?(Hash)
      sidecar
    end

    # Canonical key order = the live zone files' order; v2 keys slot in
    # deterministically (floor after display_name, regions last). Emit
    # omits defaults (floor 0, empty regions) so a v1-shaped zone emits
    # v1-shaped bytes.
    def assemble(zone, lf, tiles, ents, sidecar)
      out = { "name" => zone, "display_name" => lf["display_name"] }
      out["floor"] = lf["floor"] if lf["floor"] && lf["floor"] != 0
      out["tile_size"] = sidecar["tile_size"]
      out["palette"] = sidecar["palette"]
      out["tiles"] = tiles
      out["pack_spawn"] = ents[:pack].sort_by(&:first).map(&:last)
      out["enemy_spawns"] = ents[:enemy_spawns]
      out["stations"] = ents[:stations]
      out["transitions"] = ents[:transitions]
      out["drop_gradient"] = sidecar["drop_gradient"] if sidecar.key?("drop_gradient")
      out["gradient_anchor"] = sidecar["gradient_anchor"] if sidecar.key?("gradient_anchor")
      out["regions"] = ents[:regions] unless ents[:regions].empty?
      out
    end

    # The final gate: the emitted bytes must decode through the SAME
    # strict shapes the game boots with (TileMap validation + registry
    # cross-check) — the door composes the loader's own law.
    def validate_emitted!(zone, bytes)
      cfg = JSON.parse(bytes, symbolize_names: true)
      map = Core::TileMap.new(cfg)
      @registry.validate_map!(map)
    rescue Core::TileMap::BadMap => e
      refuse "level #{zone}: emitted zone refused by the loader — #{e.message}"
    end
  end
end

# --- CLI ----------------------------------------------------------------

if __FILE__ == $PROGRAM_NAME
  args = ARGV.dup
  project = args.shift
  opts = { "--zones" => "data/zones", "--tiles" => "data/tiles.json" }
  usage = "usage: ruby tools/import_ldtk.rb <project.ldtk> --sidecars <dir> --out <dir> " \
          "[--zones data/zones] [--tiles data/tiles.json]"
  until args.empty?
    k = args.shift
    abort "IMPORT REFUSED: unknown option #{k.inspect}\n#{usage}" \
      unless %w[--sidecars --out --zones --tiles].include?(k)
    v = args.shift
    abort "IMPORT REFUSED: option #{k} needs a value\n#{usage}" unless v
    opts[k] = v
  end
  abort "IMPORT REFUSED: #{usage}" unless project && opts["--sidecars"] && opts["--out"]

  begin
    doc = JSON.parse(File.read(project))
    registry = Core::TileRegistry.new(JSON.parse(File.read(opts["--tiles"])))
    known = Dir[File.join(opts["--zones"], "*.json")].map { |p| File.basename(p, ".json") }
    sidecars = (doc["levels"] || []).to_h do |l|
      path = File.join(opts["--sidecars"], "#{l['identifier']}.sidecar.json")
      [l["identifier"], File.exist?(path) ? JSON.parse(File.read(path)) : nil]
    end
    sidecars.compact!
    zones = Tools::LdtkImporter.new(registry:, sidecars:, known_zones: known).import(doc)
    require "fileutils"
    FileUtils.mkdir_p(opts["--out"])
    zones.each do |zone, bytes|
      path = File.join(opts["--out"], "#{zone}.json")
      File.write(path, bytes)
      parsed = JSON.parse(bytes)
      puts "IMPORTED #{zone} -> #{path} " \
           "(#{parsed['tiles'].length} rows, #{parsed['transitions'].length} transitions)"
    end
  rescue Tools::LdtkImporter::Refusal, Core::TileRegistry::BadRegistry, JSON::ParserError, Errno::ENOENT => e
    abort "IMPORT REFUSED: #{e.message}"
  end
end
