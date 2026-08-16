require_relative "../test_helper"
require "core/tile_map"

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

  # v16 (b): decor landmarks are RENDER-ONLY paint — never blocking, so
  # validation is bounds+shape only (a stain MAY lie across walls).
  def test_decor_parses_and_defaults_empty
    assert_empty Core::TileMap.new(base_cfg).decor
    map = Core::TileMap.new(base_cfg.merge(
      decor: [{ at: [1, 1], size: [2, 2], rgb: [10, 20, 30], alpha: 90 }]
    ))
    assert_equal [1, 1], map.decor.first[:at]
  end

  def test_decor_may_lie_across_walls_render_only
    map = Core::TileMap.new(base_cfg.merge(
      decor: [{ at: [0, 0], size: [2, 2], rgb: [10, 20, 30] }]
    ))
    assert_equal 1, map.decor.length, "paint over a wall is legal — never blocking"
  end

  def test_decor_out_of_bounds_raises_bad_map
    assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(decor: [{ at: [4, 4], size: [2, 2], rgb: [1, 1, 1] }]))
    end
  end

  def test_decor_missing_keys_raise_bad_map
    assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(decor: [{ at: [1, 1], rgb: [1, 1, 1] }]))
    end
  end
end
