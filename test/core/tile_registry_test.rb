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
    assert_equal %w[floor wall], reg.types.keys.sort
    assert_equal "wall", reg.type_for_char("#")
    assert_equal "#", reg.char_for_int_grid(1)
    assert_equal ".", reg.char_for_int_grid(2)
    assert_equal({ "#" => "wall", "." => "floor" }, reg.default_char_map)
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

  def test_wall_law_passability_wall_requires_hash_char
    cfg = v0
    cfg["types"]["rock"] = { "char" => "o", "int_grid" => 3, "render" => "wall",
                             "footstep" => "stone", "passability" => "wall" }
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/requires char "#" in v0/, e.message)
  end

  def test_wall_law_hash_char_requires_passability_wall
    cfg = v0
    cfg["types"]["wall"]["passability"] = "floor"
    e = assert_raises(Core::TileRegistry::BadRegistry) { Core::TileRegistry.new(cfg) }
    assert_match(/char "#" requires passability "wall"/, e.message)
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
