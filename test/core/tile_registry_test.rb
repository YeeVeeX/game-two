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
end
