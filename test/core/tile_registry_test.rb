require_relative "../test_helper"
require "core/tile_registry"
require "core/data_store"

# Tile-type registry v0 (world-builder T2, D7): render + footstep +
# passability only; hooks/variants reserved; refusals NAMED.
class TileRegistryTest < Minitest::Test
  def v0
    {
      "types" => {
        "wall" => { "char" => "#", "int_grid" => 1, "render" => "wall",
                    "footstep" => "stone", "passability" => "wall" },
        "floor" => { "char" => ".", "int_grid" => 2, "render" => "floor",
                     "footstep" => "stone", "passability" => "floor" }
      }
    }
  end

  def test_live_registry_file_loads
    data = Core::DataStore.new("data")
    reg = Core::TileRegistry.new(data["tiles"])
    # MUNDO VIVO FASE 3: + six DECORATIVE floor types (m r b L p R) — SAFE
    # class, passability floor, some carry an ambience preset.
    assert_equal %w[bones dirt floor grass lava_deco moss puddle roots rubble sand wall wall_inner water wood],
                 reg.types.keys.sort
    assert_equal "wall", reg.type_for_char("#")
    assert_equal "#", reg.char_for_int_grid(1)
    assert_equal ".", reg.char_for_int_grid(2)
    assert_equal({ "#" => "wall", "." => "floor", "," => "dirt",
                   "g" => "grass", "w" => "wood", "~" => "water",
                   "%" => "wall_inner", "s" => "sand",
                   "m" => "moss", "r" => "rubble", "b" => "bones",
                   "L" => "lava_deco", "p" => "puddle", "R" => "roots" }, reg.default_char_map)
    assert_equal %w[grass_b grass_c], reg.type("grass")["variants"]
    assert_equal %w[dirt grass stone water wood], reg.types.values.map { |t| t["footstep"] }.uniq.sort
    # v20 T5 (L11): the second wall CLASS — same blocking, own render ref.
    assert_equal "wall", reg.type("wall_inner")["passability"]
    assert_equal "%", reg.char_for_int_grid(7)
    assert_equal "wall_inner", reg.type("wall_inner")["render"]
    # T4: water WALKS in v0 ("swim" stays reserved/refused) — the well's
    # unmapped footstep_water sink key is a silent no-op until specced.
    assert_equal "floor", reg.type("water")["passability"]
  end

  # T3 live-data laws (the two invariants the ship leaned on):
  # 1. nest's dirt remap is footstep-only — its dirt palette entry equals
  #    floor, so the renderer's visible-overlay rule draws NOTHING new and
  #    the zone's look stays byte-identical.
  # 2. grass_fixture is INERT (D12): no live zone's transition reaches it —
  #    dev entry via --start-zone only.
  def test_nest_dirt_remap_is_footstep_only
    nest = JSON.parse(File.read("data/zones/nest.json"))
    assert_equal({ "." => "dirt" }, nest["tile_types"])
    assert_equal nest["palette"]["floor"], nest["palette"]["dirt"],
                 "nest dirt palette must equal floor (look byte-stability law)"
  end

  # T3/T4 (D12): authored content lands INERT — no LIVE zone's transition
  # may reach the fixture or any pilot zone; the pilot cluster reaches the
  # live world nowhere (arrivals must not re-anchor a live gate field).
  # T5 (2026-08-21) COMPLETES D12 deliberately: the SEVENTEENTH verdict
  # landed 2026-08-20 and the owner ratified the pilot walk ("Aprobado") —
  # EXACTLY ONE edge pair joins the live graph, low_quay [44,19] <->
  # zone_7 [1,14] (boss fact-gated on the low_quay side; both endpoint
  # zones declare gradient_anchor, so no live gate field re-anchors).
  # The other pilot zones stay fully inert; grass_fixture stays
  # INBOUND-inert (its T3 outbound dev-walk edge to district predates
  # T5 and is not part of this completion) — this is the completion the
  # law always named, not its deletion.
  # s70 (2026-08-24) adds the SECOND ratified pair: dungeon_1 [29,4] <->
  # zone_8 [63,19] (the worldsmith-intake wire-in debt, owner-ratified
  # ZONE-8 GO s67 + attach-at-dungeon RATIFIED-G — the frontier rung,
  # level-8-gated outbound, free return).
  # MUNDO VIVO FASE 6.3 (2026-09-05): the tower descends — dungeon_1
  # (MEDUSA LOWER) <-> dungeon_2 (A divisória) is a ratified pair (level-8
  # gated down, free up); every new tower floor joins here as it lands.
  INERT_ZONES = %w[grass_fixture zone_7 basement_1 basement_2 dungeon_1 dungeon_2 dungeon_3 dungeon_4 ember_1 ember_2 ember_3].freeze
  RATIFIED_EDGES = { "low_quay" => %w[zone_7], "zone_7" => %w[low_quay ember_1],
                     "dungeon_1" => %w[zone_8 dungeon_2], "zone_8" => %w[dungeon_1],
                     "dungeon_2" => %w[dungeon_1 dungeon_3], "dungeon_3" => %w[dungeon_2 dungeon_4],
                     "dungeon_4" => %w[dungeon_3],
                     "ember_1" => %w[zone_7 ember_2], "ember_2" => %w[ember_1 ember_3], "ember_3" => %w[ember_2] }.freeze

  def test_pilot_and_fixture_zones_stay_inert
    live = Dir["data/zones/*.json"].reject { |p| INERT_ZONES.include?(File.basename(p, ".json")) }
    live.each do |path|
      zone = File.basename(path, ".json")
      targets = JSON.parse(File.read(path)).fetch("transitions", []).map { |t| t["to"] }
      stray = (targets & INERT_ZONES) - RATIFIED_EDGES.fetch(zone, [])
      assert_empty stray,
                   "#{path}: the live graph must not reach authored zones beyond the T5-ratified edge (D12)"
    end
    pilot = %w[zone_7 basement_1 basement_2 dungeon_1 dungeon_2 dungeon_3 dungeon_4 ember_1 ember_2 ember_3]
    live_names = live.map { |p| File.basename(p, ".json") }
    pilot.each do |zone|
      targets = JSON.parse(File.read("data/zones/#{zone}.json")).fetch("transitions", []).map { |t| t["to"] }
      stray = (targets & live_names) - RATIFIED_EDGES.fetch(zone, [])
      assert_empty stray,
                   "#{zone}: the pilot cluster must not target the live world beyond the T5-ratified edge (re-anchor risk)"
      assert targets.all? { |t| pilot.include?(t) || RATIFIED_EDGES.fetch(zone, []).include?(t) },
             "#{zone}: pilot transitions stay in-cluster (plus the ratified edge)"
    end
  end

  # T5 wire-in pin (spec §THE GATE): the ratified edge EXISTS, the gate
  # reads the persisted boss fact, the return is free, and each spawn
  # sits beside (never ON) the far transition — no auto-fire ping-pong.
  def test_the_t5_ratified_edge_is_wired_and_gated
    gate = JSON.parse(File.read("data/zones/low_quay.json"))["transitions"]
               .find { |t| t["to"] == "zone_7" }
    refute_nil gate, "low_quay: the T5 boss gate is missing"
    # v20 T7 re-anchored the edge to the serpent's tail; MUNDO VIVO FASE 6.1
    # (the swap) re-anchors it to the MUSGO A south door - gate SEMANTICS
    # unchanged both times (fact-gated out, free back).
    assert_equal [24, 34], gate["at"]
    assert_equal [2, 14], gate["spawn"]
    assert_equal 1, gate["requires_defeats"],
                 "the gate must read the persisted boss fact (spec §THE GATE)"
    ret = JSON.parse(File.read("data/zones/zone_7.json"))["transitions"]
              .find { |t| t["to"] == "low_quay" }
    refute_nil ret, "zone_7: the return edge is missing"
    assert_equal [1, 14], ret["at"]
    assert_equal [24, 33], ret["spawn"] # FASE 6.1: one tile inside the MUSGO south door
    assert_nil ret["requires_defeats"], "the return is free — the defeat was already earned"
  end

  def test_accepts_symbolized_keys_from_data_store
    sym = { types: { wall: { char: "#", int_grid: 1, render: "wall",
                             footstep: "stone", passability: "wall" },
                     floor: { char: ".", int_grid: 2, render: "floor",
                              footstep: "stone", passability: "floor" } } }
    assert_equal %w[floor wall], Core::TileRegistry.new(sym).types.keys.sort
  end

  def test_missing_required_key_refuses_named
    cfg = v0
    cfg["types"]["floor"].delete("footstep")
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/floor: missing \["footstep"\]/, e.message)
  end

  def test_reserved_keys_refuse_named
    cfg = v0
    cfg["types"]["floor"]["hooks"] = { "hazard" => "lava" }
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/reserved keys/, e.message)
    assert_match(/gated cycles/, e.message)
  end

  def test_unknown_key_refuses_named
    cfg = v0
    cfg["types"]["floor"]["sprite"] = "x.png"
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/unknown key\(s\) \["sprite"\]/, e.message)
  end

  def test_duplicate_char_refuses_named
    cfg = v0
    cfg["types"]["grass"] = { "char" => ".", "int_grid" => 3, "render" => "floor",
                              "footstep" => "grass", "passability" => "floor" }
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/share char "\."/, e.message)
  end

  def test_duplicate_int_grid_refuses_named
    cfg = v0
    cfg["types"]["grass"] = { "char" => ",", "int_grid" => 2, "render" => "floor",
                              "footstep" => "grass", "passability" => "floor" }
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/share int_grid 2/, e.message)
  end

  def test_int_grid_zero_refuses_as_void
    cfg = v0
    cfg["types"]["floor"]["int_grid"] = 0
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/0 is LDtk void/, e.message)
  end

  def test_swim_refuses_as_reserved
    cfg = v0
    cfg["types"]["floor"]["passability"] = "swim"
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/"swim" is reserved, post-verdict/, e.message)
  end

  def test_wall_law_passability_wall_requires_wall_set_char
    cfg = v0
    cfg["types"]["rock"] = { "char" => "o", "int_grid" => 3, "render" => "wall",
                             "footstep" => "stone", "passability" => "wall" }
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/requires a char in \["#", "%"\]/, e.message)
  end

  def test_wall_law_hash_char_requires_passability_wall
    cfg = v0
    cfg["types"]["wall"]["passability"] = "floor"
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/char "#" is in TileMap's wall-char set and requires passability "wall"/, e.message)
  end

  # v20 T5: the second wall char binds the same law, both directions.
  def test_wall_law_percent_char_requires_passability_wall
    cfg = v0
    cfg["types"]["reef"] = { "char" => "%", "int_grid" => 3, "render" => "reef",
                             "footstep" => "stone", "passability" => "floor" }
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/char "%" is in TileMap's wall-char set and requires passability "wall"/, e.message)
  end

  def test_second_wall_type_on_percent_char_is_accepted
    cfg = v0
    cfg["types"]["wall_inner"] = { "char" => "%", "int_grid" => 3, "render" => "wall_inner",
                                   "footstep" => "stone", "passability" => "wall" }
    reg = Core::TileRegistry.new(cfg)
    assert_equal "wall_inner", reg.type_for_char("%")
  end

  def test_multi_char_refuses
    cfg = v0
    cfg["types"]["floor"]["char"] = ".."
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/single character/, e.message)
  end

  # --- T3 (D7 gated cycle): visual variants unlock + footstep consumption.

  def v1_grass
    cfg = v0
    cfg["types"]["grass"] = { "char" => "g", "int_grid" => 4, "render" => "grass",
                              "footstep" => "grass", "passability" => "floor",
                              "variants" => %w[grass_b grass_c] }
    cfg
  end

  def map_for(tiles:, palette:, tile_types: nil)
    cfg = { tile_size: 32, name: "t", display_name: "T", palette: palette,
            tiles: tiles, pack_spawn: [[1, 1], [2, 1], [3, 1]] }
    cfg[:tile_types] = tile_types if tile_types
    Core::TileMap.new(cfg)
  end

  BASE_PALETTE = { floor: [0, 0, 0], grid: [0, 0, 0], wall: [9, 9, 9],
                   transition: [1, 1, 1] }.freeze

  def test_variants_key_accepted_and_exposed
    reg = Core::TileRegistry.new(v1_grass)
    assert_equal %w[grass_b grass_c], reg.type("grass")["variants"]
  end

  def test_variants_shape_refusals_are_named
    [["not an array", "grass_b"], ["empty", []], ["blank entry", [""]],
     ["duplicate entry", %w[grass_b grass_b]]].each do |label, bad|
      cfg = v1_grass
      cfg["types"]["grass"]["variants"] = bad
      e = assert_raises(Core::TileRegistry::BadRegistry, label) { Core::TileRegistry.new(cfg) }
      assert_match(/variants/, e.message, label)
    end
  end

  def test_hooks_stays_reserved_after_variants_unlock
    cfg = v1_grass
    cfg["types"]["grass"]["hooks"] = { "hazard" => "lava" }
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/reserved/, e.message)
  end

  # validate_map! scope law (T3): only chars the zone's GRID uses (plus
  # tile_types overrides) are cross-checked — registering a new type must
  # never invalidate zones that don't use it (the live-world guarantee).
  def test_validate_map_ignores_types_the_zone_never_uses
    reg = Core::TileRegistry.new(v1_grass)
    map = map_for(tiles: ["#####", "#...#", "#####"], palette: BASE_PALETTE.dup)
    assert_nil reg.validate_map!(map) # no grass char, no grass palette: fine
  end

  def test_validate_map_refuses_used_char_missing_render_ref
    reg = Core::TileRegistry.new(v1_grass)
    map = map_for(tiles: ["#####", "#g..#", "#####"], palette: BASE_PALETTE.dup)
    e = assert_raises(Core::TileMap::BadMap) { reg.validate_map!(map) }
    assert_match(/"grass"/, e.message)
  end

  # v20 T5 (review advisory, executed): a tile_types override may not
  # disagree with the grid-char blocking law in either direction.
  def test_validate_map_refuses_wall_char_remapped_to_walkable_type
    reg = Core::TileRegistry.new(v1_grass)
    map = map_for(tiles: ["#####", "#...#", "#####"], palette: BASE_PALETTE.dup,
                  tile_types: { "#" => "floor" })
    e = assert_raises(Core::TileMap::BadMap) { reg.validate_map!(map) }
    assert_match(/is IN TileMap's wall-char set/, e.message)
  end

  def test_validate_map_refuses_wall_type_on_walkable_char
    cfg = v1_grass
    cfg["types"]["wall_inner"] = { "char" => "%", "int_grid" => 7, "render" => "wall_inner",
                                   "footstep" => "stone", "passability" => "wall" }
    reg = Core::TileRegistry.new(cfg)
    map = map_for(tiles: ["#####", "#o..#", "#####"], palette: BASE_PALETTE.merge(wall_inner: [9, 9, 9]),
                  tile_types: { "o" => "wall_inner" })
    e = assert_raises(Core::TileMap::BadMap) { reg.validate_map!(map) }
    assert_match(/is NOT in TileMap's wall-char set/, e.message)
  end

  def test_validate_map_refuses_used_char_missing_variant_ref
    reg = Core::TileRegistry.new(v1_grass)
    palette = BASE_PALETTE.merge(grass: [0, 5, 0], grass_b: [0, 6, 0]) # grass_c absent
    map = map_for(tiles: ["#####", "#g..#", "#####"], palette: palette)
    e = assert_raises(Core::TileMap::BadMap) { reg.validate_map!(map) }
    assert_match(/grass_c/, e.message)
  end

  def test_validate_map_covers_tile_types_overrides
    cfg = v1_grass
    cfg["types"]["dirt"] = { "char" => ",", "int_grid" => 3, "render" => "dirt",
                             "footstep" => "dirt", "passability" => "floor" }
    reg = Core::TileRegistry.new(cfg)
    map = map_for(tiles: ["#####", "#...#", "#####"], palette: BASE_PALETTE.dup,
                  tile_types: { "." => "dirt" })
    e = assert_raises(Core::TileMap::BadMap) { reg.validate_map!(map) }
    assert_match(/"dirt"/, e.message)
  end

  def test_validate_map_refuses_grid_chars_with_no_registered_type
    reg = Core::TileRegistry.new(v0)
    map = map_for(tiles: ["#####", "#.z.#", "#####"], palette: BASE_PALETTE.dup)
    e = assert_raises(Core::TileMap::BadMap) { reg.validate_map!(map) }
    assert_match(/grid char "z" has no registered tile type/, e.message)
  end

  # material_at (T3): footstep consumption — char under the tile through
  # the zone's effective mapping to the type's material key.
  def test_material_at_reads_default_and_override_mappings
    cfg = v1_grass
    cfg["types"]["dirt"] = { "char" => ",", "int_grid" => 3, "render" => "floor",
                             "footstep" => "dirt", "passability" => "floor" }
    reg = Core::TileRegistry.new(cfg)
    plain = map_for(tiles: ["#####", "#g..#", "#####"],
                    palette: BASE_PALETTE.merge(grass: [0, 5, 0], grass_b: [0, 6, 0],
                                                grass_c: [0, 7, 0]))
    assert_equal "grass", reg.material_at(plain, 1, 1)
    assert_equal "stone", reg.material_at(plain, 2, 1)
    assert_equal "stone", reg.material_at(plain, 0, 0) # wall type carries stone
    assert_nil reg.material_at(plain, 99, 1) # out of bounds: no material
    remapped = map_for(tiles: ["#####", "#...#", "#####"], palette: BASE_PALETTE.dup,
                       tile_types: { "." => "dirt" })
    assert_equal "dirt", reg.material_at(remapped, 1, 1)
  end
end
