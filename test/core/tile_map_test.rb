require_relative "../test_helper"
require "core/tile_map"
require "core/tile_registry"
require "core/data_store"

class TileMapTest < Minitest::Test
  def base_cfg
    {
      tile_size: 32,
      display_name: "T",
      palette: { floor: [0, 0, 0], grid: [0, 0, 0], wall: [0, 0, 0], transition: [0, 0, 0] },
      tiles: ["#####", "#...#", "#...#", "#...#", "#####"],
      pack_spawn: [[1, 1], [2, 1], [3, 1]]
    }
  end

  def test_stations_parse_and_lookup
    map = Core::TileMap.new(base_cfg.merge(stations: [{ type: "bank", at: [2, 2] }]))
    assert_equal({ type: "bank", at: [2, 2] }, map.station_at(2, 2))
    assert_nil map.station_at(1, 1)
  end

  def test_station_on_wall_raises_bad_map
    assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(stations: [{ type: "bank", at: [0, 0] }]))
    end
  end

  def test_zones_without_stations_stay_valid
    assert_empty Core::TileMap.new(base_cfg).stations
  end

  # v13 i18n: the renderer keys zone strings off the INTERNAL zone name
  # ("zone.<name>.display_name"); display_name stays the canonical EN text.
  def test_name_exposed_for_locale_keys
    assert_equal "t_zone", Core::TileMap.new(base_cfg.merge(name: "t_zone")).name
  end

  def test_name_optional_for_fixture_maps
    assert_nil Core::TileMap.new(base_cfg).name
  end

  # T3: char + used-chars readers (footstep material derivation + the
  # used-chars scope law in TileRegistry#validate_map!).
  def test_char_at_reads_grid_and_nils_out_of_bounds
    map = Core::TileMap.new(base_cfg)
    assert_equal "#", map.char_at(0, 0)
    assert_equal ".", map.char_at(1, 1)
    assert_nil map.char_at(-1, 0)
    assert_nil map.char_at(0, -1)
    assert_nil map.char_at(99, 0)
    assert_nil map.char_at(0, 99)
  end

  def test_used_chars_lists_each_grid_char_once
    assert_equal ["#", "."], Core::TileMap.new(base_cfg).used_chars.sort
  end

  # --- schema v2 (world-builder T2): floors, typed transitions, regions,
  # tile-type ids. All additive — defaults preserve v1 files exactly.

  def registry
    Core::TileRegistry.new(
      "types" => {
        "wall" => { "char" => "#", "int_grid" => 1, "render" => "wall",
                    "footstep" => "stone", "passability" => "wall" },
        "floor" => { "char" => ".", "int_grid" => 2, "render" => "floor",
                     "footstep" => "stone", "passability" => "floor" }
      }
    )
  end

  def test_floor_defaults_to_zero
    assert_equal 0, Core::TileMap.new(base_cfg).floor
  end

  def test_floor_reads_negative_depth
    assert_equal(-1, Core::TileMap.new(base_cfg.merge(floor: -1)).floor)
  end

  def test_floor_non_integer_refuses
    e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(base_cfg.merge(floor: "-1")) }
    assert_match(/floor must be an Integer/, e.message)
  end

  def test_typed_transitions_parse
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "below", spawn: [1, 1], type: "stairs_down" }]
    ))
    assert_equal "stairs_down", map.transition_at(2, 2)[:type]
  end

  def test_untyped_transition_stays_valid_v1_shape
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "next", spawn: [1, 1] }]
    ))
    assert_nil map.transition_at(2, 2)[:type]
  end

  def test_unknown_transition_type_refuses_named
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(transitions: [{ at: [2, 2], to: "x", spawn: [1, 1], type: "elevator" }]))
    end
    assert_match(/unknown type "elevator"/, e.message)
  end

  def test_hole_may_declare_stairs_unlocked_by
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "below", spawn: [1, 1], type: "hole",
                      stairs_unlocked_by: "well_drained" }]
    ))
    assert_equal "well_drained", map.transition_at(2, 2)[:stairs_unlocked_by]
  end

  def test_stairs_unlocked_by_off_hole_refuses_named
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(
        transitions: [{ at: [2, 2], to: "x", spawn: [1, 1], type: "stairs_down",
                        stairs_unlocked_by: "well_drained" }]
      ))
    end
    assert_match(/legal on type "hole" only/, e.message)
  end

  def test_stairs_unlocked_by_needs_fact_name
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(
        transitions: [{ at: [2, 2], to: "x", spawn: [1, 1], type: "hole", stairs_unlocked_by: "" }]
      ))
    end
    assert_match(/non-empty breach-family fact/, e.message)
  end

  # --- T4: the boss fact-gate + the well's drained-look link -------------

  def test_requires_defeats_parses_on_any_transition
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "next", spawn: [1, 1], requires_defeats: 1 }]
    ))
    assert_equal 1, map.transition_at(2, 2)[:requires_defeats]
  end

  def test_requires_defeats_refuses_non_positive_or_non_integer
    [0, -1, "1", 1.5].each do |bad|
      e = assert_raises(Core::TileMap::BadMap) do
        Core::TileMap.new(base_cfg.merge(
          transitions: [{ at: [2, 2], to: "x", spawn: [1, 1], requires_defeats: bad }]
        ))
      end
      assert_match(/requires_defeats must be an Integer >= 1/, e.message)
    end
  end

  def test_water_drained_by_parses_with_authored_palette_ref
    cfg = base_cfg
    cfg[:palette] = cfg[:palette].merge(water_drained: [9, 9, 9])
    map = Core::TileMap.new(cfg.merge(water_drained_by: [2, 2]))
    assert_equal [2, 2], map.water_drained_by
  end

  def test_water_drained_by_defaults_nil
    assert_nil Core::TileMap.new(base_cfg).water_drained_by
  end

  def test_water_drained_by_refuses_out_of_bounds_or_bad_shape
    cfg = base_cfg
    cfg[:palette] = cfg[:palette].merge(water_drained: [9, 9, 9])
    [[9, 9], [2], ["2", "2"], [-1, 1]].each do |bad|
      e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(cfg.merge(water_drained_by: bad)) }
      assert_match(/water_drained_by must be an in-bounds \[x, y\] tile/, e.message)
    end
  end

  def test_water_drained_by_refuses_without_drained_palette_ref
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(water_drained_by: [2, 2]))
    end
    assert_match(/palette carries no water_drained ref/, e.message)
  end

  def test_regions_parse_as_data_layer
    map = Core::TileMap.new(base_cfg.merge(
      regions: [{ id: "town_1", rect: [1, 1, 3, 2], intent: "town" }]
    ))
    assert_equal [{ id: "town_1", rect: [1, 1, 3, 2], intent: "town" }], map.regions
  end

  def test_regions_default_empty
    assert_empty Core::TileMap.new(base_cfg).regions
  end

  def test_region_duplicate_id_refuses
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(regions: [
        { id: "a", rect: [1, 1, 1, 1], intent: "town" },
        { id: "a", rect: [2, 2, 1, 1], intent: "guard" }
      ]))
    end
    assert_match(/duplicate region id "a"/, e.message)
  end

  def test_region_unknown_intent_refuses
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(regions: [{ id: "a", rect: [1, 1, 1, 1], intent: "casino" }]))
    end
    assert_match(/unknown intent "casino"/, e.message)
  end

  def test_region_rect_outside_map_refuses
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(regions: [{ id: "a", rect: [3, 3, 4, 1], intent: "town" }]))
    end
    assert_match(/outside 5x5 map/, e.message)
  end

  def test_region_rect_bad_shape_refuses
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(regions: [{ id: "a", rect: [1, 1, 2], intent: "town" }]))
    end
    assert_match(/rect must be \[x, y, w, h\]/, e.message)
  end

  def test_tile_types_normalizes_symbolized_keys
    map = Core::TileMap.new(base_cfg.merge(tile_types: { "#": "wall", ".": "floor" }))
    assert_equal({ "#" => "wall", "." => "floor" }, map.tile_types)
  end

  def test_tile_types_default_nil
    assert_nil Core::TileMap.new(base_cfg).tile_types
  end

  def test_tile_types_unknown_type_refuses_under_registry
    map = Core::TileMap.new(base_cfg.merge(tile_types: { ".": "lava" }))
    e = assert_raises(Core::TileMap::BadMap) { registry.validate_map!(map) }
    assert_match(/"lava": unknown tile type/, e.message)
  end

  def test_registry_render_ref_must_exist_in_palette
    cfg = base_cfg
    cfg[:palette] = cfg[:palette].reject { |k, _| k == :floor }
    map = Core::TileMap.new(cfg)
    e = assert_raises(Core::TileMap::BadMap) { registry.validate_map!(map) }
    assert_match(/renders palette ref "floor", absent/, e.message)
  end

  # T2 regression bar, T3 amendment: the five untouched zones stay v1-shaped;
  # nest carries EXACTLY the footstep-only dirt remap (T3, look byte-stable —
  # see TileRegistryTest's palette-equality pin); grass_fixture is the T3
  # authored v2 zone (region + threat-free by data, INERT per D12).
  def test_live_zones_load_under_registry_with_declared_shapes
    data = Core::DataStore.new("data")
    reg = Core::TileRegistry.new(data["tiles"])
    zones = data.keys.grep(%r{\Azones/})
    assert_equal 7, zones.length
    v1 = %w[zones/camp zones/district zones/district_two zones/low_quay zones/slow_door]
    zones.each do |key|
      map = Core::TileMap.new(data[key])
      reg.validate_map!(map)
      assert_equal 0, map.floor, "#{key} must default to floor 0"
      map.transitions.each { |t| assert_nil t[:type], "#{key} transitions stay untyped v1 gates" }
      if v1.include?(key)
        assert_empty map.regions, "#{key} must default to no regions"
        assert_nil map.tile_types, "#{key} must carry no tile_types override"
      end
    end
    assert_equal({ "." => "dirt" }, Core::TileMap.new(data["zones/nest"]).tile_types)
    fixture = Core::TileMap.new(data["zones/grass_fixture"])
    assert_equal %w[plaza], fixture.regions.map { |r| r[:id] }
    assert_empty fixture.enemy_spawns, "the fixture zone is threat-free by data"
  end
end
