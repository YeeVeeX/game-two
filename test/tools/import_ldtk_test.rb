require_relative "../test_helper"
require "json"
require "open3"
require "rbconfig"
require "tmpdir"
require "fileutils"
require_relative "../../tools/import_ldtk"

# World-builder T2: the production importer. REAL fixture — LDtk
# 1.5.3-resaved vendor bytes (test/fixtures/spike_district.ldtk, salvaged
# from the T1 spike, md5 59363c9427dde76e742a6b2bba31b563). Refusal cases
# are runtime mutations of those real bytes, one per named wrinkle
# (drafts/_ldtk-spike-findings-20260819.md).
class ImportLdtkTest < Minitest::Test
  FIXTURE = File.expand_path("../fixtures/spike_district.ldtk", __dir__)
  SIDECAR = File.expand_path("../fixtures/district.sidecar.json", __dir__)
  # v20 T1: the LIVE district graduated to the pilot project (its provenance
  # pin lives in pilot_authoring_test now); the spike fixture keeps proving
  # importer semantics against its own committed expected emission.
  EXPECTED = File.expand_path("../fixtures/district_expected.json", __dir__)
  TILES = File.expand_path("../../data/tiles.json", __dir__)

  def doc = JSON.parse(File.read(FIXTURE))
  def sidecar = JSON.parse(File.read(SIDECAR))
  def registry = Core::TileRegistry.new(JSON.parse(File.read(TILES)))

  def importer(sidecars: { "district" => sidecar }, known: %w[nest camp])
    Tools::LdtkImporter.new(registry: registry, sidecars: sidecars, known_zones: known)
  end

  def level(d) = d["levels"][0]
  def layer(d, id) = level(d)["layerInstances"].find { |l| l["__identifier"] == id }
  def entity(d, kind, i = 0) = layer(d, "Entities")["entityInstances"].select { |e| e["__identifier"] == kind }[i]

  def str_field(id, value)
    { "__identifier" => id, "__type" => "String", "__value" => value, "__tile" => nil,
      "defUid" => 9000 + id.sum, "realEditorValues" => [{ "id" => "V_String", "params" => [value] }] }
  end

  def int_field(id, value)
    { "__identifier" => id, "__type" => "Int", "__value" => value, "__tile" => nil,
      "defUid" => 9000 + id.sum, "realEditorValues" => [{ "id" => "V_Int", "params" => [value] }] }
  end

  def refusal(d, **kw)
    e = assert_raises(Tools::LdtkImporter::Refusal) { importer(**kw).import(d) }
    e.message
  end

  # --- the happy path: round-trip + fixpoint -----------------------------

  def test_round_trip_semantic_identity_with_expected_emission
    bytes = importer.import(doc).fetch("district")
    assert_equal JSON.parse(File.read(EXPECTED)), JSON.parse(bytes),
                 "imported fixture district must match its committed expected emission"
  end

  def test_import_emit_import_fixpoint_is_byte_stable
    bytes = importer.import(doc).fetch("district")
    reemitted = importer.emit(JSON.parse(bytes))
    assert_equal bytes, reemitted, "emit(parse(emit(x))) must be byte-identical (D2)"
  end

  def test_emitted_zone_loads_through_the_game_loader
    bytes = importer.import(doc).fetch("district")
    map = Core::TileMap.new(JSON.parse(bytes, symbolize_names: true))
    assert_equal 0, map.floor
    assert_equal 44, map.cols
    assert_equal 26, map.rows
    registry.validate_map!(map)
  end

  # --- v20 T5: the second wall class rides the SAME registry door --------
  # int_grid 7 (wall_inner) is a pure data/tiles.json addition: decode,
  # fixpoint, and game-loader legality all hold with ZERO importer code.

  def wall_inner_doc
    d = doc
    terrain = layer(d, "Terrain")
    terrain["intGridCsv"][44 * 2 + 2] = 7 # plain interior floor tile [2,2], no entities
    d
  end

  # The importer door composes the palette law: emitting '%' needs the
  # sidecar to author its wall_inner palette ref, or import refuses NAMED
  # (validate_emitted! — proven by the refusal test below).
  def wall_inner_importer
    sc = JSON.parse(JSON.generate(sidecar))
    sc["palette"]["wall_inner"] = [158, 42, 48]
    importer(sidecars: { "district" => sc })
  end

  def test_int_grid_seven_decodes_to_the_wall_inner_char
    bytes = wall_inner_importer.import(wall_inner_doc).fetch("district")
    grid = JSON.parse(bytes).fetch("tiles")
    assert_equal "%", grid[2][2], "IntGrid 7 must emit the wall_inner glyph"
  end

  def test_wall_inner_emission_keeps_the_fixpoint_byte_stable
    imp = wall_inner_importer
    bytes = imp.import(wall_inner_doc).fetch("district")
    reemitted = imp.emit(JSON.parse(bytes))
    assert_equal bytes, reemitted, "emit(parse(emit(x))) must stay byte-identical with '%' tiles (D2)"
  end

  def test_wall_inner_emission_loads_and_blocks_through_the_game_loader
    bytes = wall_inner_importer.import(wall_inner_doc).fetch("district")
    map = Core::TileMap.new(JSON.parse(bytes, symbolize_names: true))
    assert map.wall?(2, 2), "the imported wall_inner tile must BLOCK like any wall"
    assert_equal [158, 42, 48], map.palette[:wall_inner], "the sidecar palette ref rides the emission"
    registry.validate_map!(map)
  end

  def test_wall_inner_without_sidecar_palette_ref_refuses_at_the_importer_door
    msg = refusal(wall_inner_doc)
    assert_match(/emitted zone refused by the loader/, msg)
    assert_match(/renders palette ref "wall_inner", absent/, msg)
  end

  # --- D1 pin + project-shape refusals -----------------------------------

  def test_refuses_json_version_drift
    d = doc
    d["jsonVersion"] = "1.5.2"
    assert_match(/jsonVersion "1\.5\.2" != pinned "1\.5\.3"/, refusal(d))
  end

  def test_refuses_identifier_style_capitalize
    d = doc
    d["identifierStyle"] = "Capitalize"
    assert_match(/identifierStyle "Capitalize" != pinned "Free"/, refusal(d))
  end

  def test_refuses_external_levels
    d = doc
    d["externalLevels"] = true
    assert_match(/externalLevels: true is unsupported/, refusal(d))
  end

  def test_refuses_null_layer_instances
    d = doc
    d["externalLevels"] = false
    level(d)["layerInstances"] = nil
    assert_match(/layerInstances is null/, refusal(d))
  end

  def test_refuses_duplicate_level_identifiers
    d = doc
    d["levels"] << JSON.parse(JSON.generate(level(d)))
    assert_match(/duplicate level identifier\(s\) \["district"\]/, refusal(d))
  end

  def test_refuses_bad_level_identifier_shape
    d = doc
    level(d)["identifier"] = "District"
    assert_match(/"District" is not a zone-name shape/, refusal(d))
  end

  def test_refuses_world_offset
    d = doc
    level(d)["worldX"] = 256
    assert_match(/worldX=256 not in \[-1, 0\]/, refusal(d))
  end

  def test_refuses_unknown_layer
    d = doc
    level(d)["layerInstances"] << { "__identifier" => "Decor", "__type" => "Tiles",
                                    "__gridSize" => 32, "__pxTotalOffsetX" => 0, "__pxTotalOffsetY" => 0 }
    assert_match(/unknown layer "Decor"/, refusal(d))
  end

  def test_refuses_layer_pixel_offset
    d = doc
    layer(d, "Terrain")["__pxTotalOffsetX"] = 16
    assert_match(/carries a pixel offset/, refusal(d))
  end

  # --- IntGrid refusals (wrinkle 3) ---------------------------------------

  def test_refuses_void_cell_with_coordinates
    d = doc
    t = layer(d, "Terrain")
    t["intGridCsv"][2 * t["__cWid"] + 5] = 0
    assert_match(/IntGrid value 0 at \[5,2\]/, refusal(d))
  end

  def test_refuses_unknown_int_grid_value_with_coordinates
    d = doc
    t = layer(d, "Terrain")
    t["intGridCsv"][0] = 8
    msg = refusal(d)
    assert_match(/IntGrid value 8 at \[0,0\]/, msg)
    assert_match(/deliberate data\/tiles\.json addition/, msg)
  end

  def test_refuses_csv_length_mismatch
    d = doc
    layer(d, "Terrain")["intGridCsv"] = [1, 2, 1]
    assert_match(/intGridCsv length 3/, refusal(d))
  end

  # --- field-value tamper tells (wrinkle 1) --------------------------------

  def test_refuses_value_disagreeing_with_real_editor_values
    d = doc
    f = entity(d, "Station")["fieldInstances"].find { |fi| fi["__identifier"] == "line" }
    f["__value"] = "HAND EDITED"
    assert_match(/__value "HAND EDITED" disagrees with realEditorValues/, refusal(d))
  end

  def test_refuses_value_with_no_real_editor_backing
    d = doc
    f = entity(d, "Station")["fieldInstances"].find { |fi| fi["__identifier"] == "line" }
    f["realEditorValues"] = []
    assert_match(/no realEditorValues backing/, refusal(d))
  end

  def test_refuses_point_field_tamper
    d = doc
    f = entity(d, "Transition")["fieldInstances"].find { |fi| fi["__identifier"] == "spawn" }
    f["__value"] = { "cx" => 1, "cy" => 1 }
    assert_match(/spawn __value .* disagrees/, refusal(d))
  end

  # --- entity refusals ------------------------------------------------------

  def test_refuses_unknown_entity
    d = doc
    entity(d, "Station")["__identifier"] = "Shop"
    assert_match(/unknown entity "Shop"/, refusal(d))
  end

  def test_refuses_unknown_entity_field
    d = doc
    entity(d, "Station")["fieldInstances"] << str_field("discount", "half")
    assert_match(/unknown field "discount"/, refusal(d))
  end

  def test_refuses_non_zero_pivot
    d = doc
    entity(d, "EnemySpawn")["__pivot"] = [0.5, 1]
    assert_match(/pivot \[0\.5, 1\] != \[0, 0\]/, refusal(d))
  end

  def test_refuses_off_grid_px
    d = doc
    e = entity(d, "EnemySpawn")
    e["px"] = [e["px"][0] + 3, e["px"][1]]
    assert_match(/off the 32px grid/, refusal(d))
  end

  def test_refuses_grid_px_disagreement
    d = doc
    e = entity(d, "EnemySpawn")
    e["px"] = [e["px"][0] + 32, e["px"][1]]
    assert_match(/__grid .* disagrees with px/, refusal(d))
  end

  def test_refuses_overlapping_entities
    d = doc
    a = entity(d, "EnemySpawn", 0)
    b = entity(d, "EnemySpawn", 1)
    b["px"] = a["px"].dup
    b["__grid"] = a["__grid"].dup
    assert_match(/EnemySpawn overlaps EnemySpawn on tile/, refusal(d))
  end

  def test_refuses_missing_pack_spawn_order
    d = doc
    entity(d, "PackSpawn")["fieldInstances"] = []
    assert_match(/required field "order" missing or null/, refusal(d))
  end

  def test_refuses_duplicate_pack_spawn_order
    d = doc
    f = entity(d, "PackSpawn", 0)["fieldInstances"].find { |fi| fi["__identifier"] == "order" }
    g = entity(d, "PackSpawn", 1)["fieldInstances"].find { |fi| fi["__identifier"] == "order" }
    g["__value"] = f["__value"]
    g["realEditorValues"] = JSON.parse(JSON.generate(f["realEditorValues"]))
    assert_match(/duplicate PackSpawn order/, refusal(d))
  end

  def test_refuses_transition_to_unknown_zone
    d = doc
    f = entity(d, "Transition")["fieldInstances"].find { |fi| fi["__identifier"] == "to" }
    f["__value"] = "atlantis"
    f["realEditorValues"] = [{ "id" => "V_String", "params" => ["atlantis"] }]
    assert_match(/targets unknown zone "atlantis"/, refusal(d))
  end

  # --- the composed loader gate --------------------------------------------

  def test_refuses_station_on_wall_via_loader_gate
    d = doc
    e = entity(d, "Station")
    e["px"] = [0, 0]
    e["__grid"] = [0, 0]
    msg = refusal(d)
    assert_match(/emitted zone refused by the loader/, msg)
    assert_match(/station \[0, 0\] is not passable/, msg)
  end

  # --- sidecar contract (D2) -------------------------------------------------

  def test_refuses_missing_sidecar
    assert_match(/no sidecar/, refusal(doc, sidecars: {}))
  end

  def test_refuses_unknown_sidecar_key
    s = sidecar.merge("hub" => true)
    msg = refusal(doc, sidecars: { "district" => s })
    assert_match(/sidecar unknown key\(s\) \["hub"\]/, msg)
    assert_match(/D2/, msg)
  end

  def test_refuses_sidecar_missing_required
    s = sidecar.tap { |x| x.delete("palette") }
    assert_match(/sidecar missing \["palette"\]/, refusal(doc, sidecars: { "district" => s }))
  end

  # --- schema v2 emission (floor, typed transitions, regions) ---------------

  def test_missing_display_name_refuses
    d = doc
    level(d)["fieldInstances"] = []
    assert_match(/display_name level field missing/, refusal(d))
  end

  def test_floor_level_field_emits
    d = doc
    level(d)["fieldInstances"] << int_field("floor", -1)
    parsed = JSON.parse(importer.import(d).fetch("district"))
    assert_equal(-1, parsed["floor"])
    keys = parsed.keys
    assert_equal keys.index("display_name") + 1, keys.index("floor"), "floor slots after display_name"
  end

  def test_floor_zero_is_omitted_as_default
    d = doc
    level(d)["fieldInstances"] << int_field("floor", 0)
    parsed = JSON.parse(importer.import(d).fetch("district"))
    refute parsed.key?("floor")
  end

  # --- T4: hub level field + requires_defeats + water_drained_by ---------

  def bool_field(id, value)
    { "__identifier" => id, "__type" => "Bool", "__value" => value, "__tile" => nil,
      "defUid" => 9000 + id.sum, "realEditorValues" => [{ "id" => "V_Bool", "params" => [value] }] }
  end

  def test_hub_level_field_emits_after_display_name
    d = doc
    level(d)["fieldInstances"] << bool_field("hub", true)
    parsed = JSON.parse(importer.import(d).fetch("district"))
    assert parsed["hub"]
    keys = parsed.keys
    assert_equal keys.index("display_name") + 1, keys.index("hub"),
                 "hub slots after display_name (camp.json order)"
  end

  def test_hub_false_is_omitted_as_default
    d = doc
    level(d)["fieldInstances"] << bool_field("hub", false)
    parsed = JSON.parse(importer.import(d).fetch("district"))
    refute parsed.key?("hub")
  end

  # B1: safe rides the same level-field custody as hub (zone metadata is
  # never sidecar territory — the sidecar refuses unknown keys by law)
  # and slots directly after hub in the canonical emission order. The
  # fixture ships EnemySpawn entities, so they are stripped first — the
  # emit gate composes the loader's D2 sanctuary refusal (pinned below).
  def strip_enemy_spawns(d)
    layer(d, "Entities")["entityInstances"].reject! { |e| e["__identifier"] == "EnemySpawn" }
    d
  end

  def test_safe_level_field_emits_after_hub
    d = strip_enemy_spawns(doc)
    level(d)["fieldInstances"] << bool_field("hub", true)
    level(d)["fieldInstances"] << bool_field("safe", true)
    parsed = JSON.parse(importer.import(d).fetch("district"))
    assert parsed["safe"]
    keys = parsed.keys
    assert_equal keys.index("hub") + 1, keys.index("safe"),
                 "safe slots after hub (camp.json order)"
  end

  def test_safe_with_enemy_spawns_refuses_through_the_emit_gate
    d = doc
    level(d)["fieldInstances"] << bool_field("safe", true)
    assert_match(/safe: true with non-empty enemy_spawns/, refusal(d))
  end

  def test_safe_false_is_omitted_as_default
    d = doc
    level(d)["fieldInstances"] << bool_field("safe", false)
    parsed = JSON.parse(importer.import(d).fetch("district"))
    refute parsed.key?("safe")
  end

  def test_requires_defeats_transition_field_emits
    d = doc
    tr = entity(d, "Transition", 0)
    tr["fieldInstances"] << int_field("requires_defeats", 1)
    parsed = JSON.parse(importer.import(d).fetch("district"))
    gate = parsed["transitions"].find { |t| t["requires_defeats"] }
    assert_equal 1, gate["requires_defeats"]
  end

  def test_requires_defeats_zero_refuses_via_loader
    d = doc
    tr = entity(d, "Transition", 0)
    # 0 is TRUTHY in Ruby, so the pass-through emits it and the loader
    # gate refuses NAMED (>= 1 law) — same for negatives. Pin both.
    tr["fieldInstances"] << int_field("requires_defeats", 0)
    assert_match(/requires_defeats must be an Integer >= 1/, refusal(d))
    tr["fieldInstances"].pop
    tr["fieldInstances"] << int_field("requires_defeats", -1)
    assert_match(/requires_defeats must be an Integer >= 1/, refusal(d))
  end

  # s68 difficulty tier: requires_level rides the same pass-through law
  # (found live: the field was MISSING from ENTITY_FIELDS — a re-export
  # of a gated zone would have refused; the WB round-trip must carry
  # every shipped transition fact).
  def test_requires_level_transition_field_emits
    d = doc
    tr = entity(d, "Transition", 0)
    tr["fieldInstances"] << int_field("requires_level", 6)
    parsed = JSON.parse(importer.import(d).fetch("district"))
    gate = parsed["transitions"].find { |t| t["requires_level"] }
    assert_equal 6, gate["requires_level"]
  end

  def test_requires_level_zero_refuses_via_loader
    d = doc
    tr = entity(d, "Transition", 0)
    tr["fieldInstances"] << int_field("requires_level", 0)
    assert_match(/requires_level must be an Integer >= 1/, refusal(d))
  end

  def test_water_drained_by_sidecar_key_emits_after_gradient_anchor
    sc = sidecar
    sc["palette"]["water_drained"] = [50, 44, 30]
    sc["water_drained_by"] = [1, 1]
    parsed = JSON.parse(importer(sidecars: { "district" => sc }).import(doc).fetch("district"))
    assert_equal [1, 1], parsed["water_drained_by"]
    keys = parsed.keys
    assert_operator keys.index("water_drained_by"), :>, keys.index("gradient_anchor"),
                    "presentation links slot after gradient_anchor"
  end

  def test_water_drained_by_without_palette_ref_refuses_via_loader
    sc = sidecar
    sc["water_drained_by"] = [1, 1]
    e = assert_raises(Tools::LdtkImporter::Refusal) do
      importer(sidecars: { "district" => sc }).import(doc)
    end
    assert_match(/palette carries no water_drained ref/, e.message)
  end

  def test_typed_hole_transition_with_unlock_fact_emits
    d = doc
    tr = entity(d, "Transition", 1) # the sealed camp transition
    tr["fieldInstances"] << str_field("type", "hole")
    tr["fieldInstances"] << str_field("stairs_unlocked_by", "well_drained")
    parsed = JSON.parse(importer.import(d).fetch("district"))
    hole = parsed["transitions"].find { |t| t["type"] == "hole" }
    assert_equal "well_drained", hole["stairs_unlocked_by"]
  end

  def test_unlock_fact_off_hole_refuses_via_loader
    d = doc
    tr = entity(d, "Transition", 1)
    tr["fieldInstances"] << str_field("type", "stairs_down")
    tr["fieldInstances"] << str_field("stairs_unlocked_by", "well_drained")
    assert_match(/legal on type "hole" only/, refusal(d))
  end

  def test_region_entity_emits_rect_data_layer
    d = doc
    layer(d, "Entities")["entityInstances"] << {
      "__identifier" => "Region", "__grid" => [1, 1], "__pivot" => [0, 0],
      "__tags" => [], "__tile" => nil, "__smartColor" => "#FFFFFF",
      "iid" => "test-region-1", "width" => 96, "height" => 64, "defUid" => 999,
      "px" => [32, 32],
      "fieldInstances" => [str_field("id", "town_1"), str_field("intent", "town")]
    }
    parsed = JSON.parse(importer.import(d).fetch("district"))
    assert_equal [{ "id" => "town_1", "rect" => [1, 1, 3, 2], "intent" => "town" }],
                 parsed["regions"]
  end

  def test_region_off_grid_size_refuses
    d = doc
    layer(d, "Entities")["entityInstances"] << {
      "__identifier" => "Region", "__grid" => [1, 1], "__pivot" => [0, 0],
      "__tags" => [], "__tile" => nil, "__smartColor" => "#FFFFFF",
      "iid" => "test-region-2", "width" => 90, "height" => 64, "defUid" => 999,
      "px" => [32, 32],
      "fieldInstances" => [str_field("id", "town_1"), str_field("intent", "town")]
    }
    assert_match(/Region size 90x64px off the 32px grid/, refusal(d))
  end

  def test_region_bad_intent_refuses_via_loader
    d = doc
    layer(d, "Entities")["entityInstances"] << {
      "__identifier" => "Region", "__grid" => [1, 1], "__pivot" => [0, 0],
      "__tags" => [], "__tile" => nil, "__smartColor" => "#FFFFFF",
      "iid" => "test-region-3", "width" => 32, "height" => 32, "defUid" => 999,
      "px" => [32, 32],
      "fieldInstances" => [str_field("id", "x"), str_field("intent", "casino")]
    }
    assert_match(/unknown intent "casino"/, refusal(d))
  end

  # --- CLI (the real door, subprocess) ---------------------------------------

  def test_cli_imports_district
    Dir.mktmpdir do |dir|
      side_dir = File.join(dir, "sidecars")
      out_dir = File.join(dir, "out")
      FileUtils.mkdir_p(side_dir)
      FileUtils.cp(SIDECAR, File.join(side_dir, "district.sidecar.json"))
      cmd = [RbConfig.ruby, File.expand_path("../../tools/import_ldtk.rb", __dir__),
             FIXTURE, "--sidecars", side_dir, "--out", out_dir,
             "--zones", File.expand_path("../../data/zones", __dir__), "--tiles", TILES]
      stdout, stderr, status = Open3.capture3(*cmd)
      assert status.success?, "CLI failed: #{stderr}"
      assert_match(/IMPORTED district -> .*district\.json \(26 rows, 2 transitions\)/, stdout)
      assert_equal JSON.parse(File.read(EXPECTED)),
                   JSON.parse(File.read(File.join(out_dir, "district.json")))
    end
  end

  def test_cli_refuses_named_and_exits_nonzero
    Dir.mktmpdir do |dir|
      bad = File.join(dir, "bad.ldtk")
      d = doc
      d["jsonVersion"] = "1.4.0"
      File.write(bad, JSON.generate(d))
      side_dir = File.join(dir, "sidecars")
      FileUtils.mkdir_p(side_dir)
      FileUtils.cp(SIDECAR, File.join(side_dir, "district.sidecar.json"))
      cmd = [RbConfig.ruby, File.expand_path("../../tools/import_ldtk.rb", __dir__),
             bad, "--sidecars", side_dir, "--out", File.join(dir, "out"), "--tiles", TILES]
      _, stderr, status = Open3.capture3(*cmd)
      refute status.success?
      assert_match(/IMPORT REFUSED: jsonVersion "1\.4\.0" != pinned "1\.5\.3"/, stderr)
    end
  end
end
