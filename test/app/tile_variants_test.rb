require_relative "../test_helper"
require "core/data_store"
require "core/tile_map"
require "core/tile_registry"
require "app/tile_variants"

# T3 flora visual variants (D7): overlay-rect derivation is a PURE
# function of zone name + coord + authored data — no runtime randomness,
# no Gosu. The two laws under test:
#   1. determinism (same inputs, same rects — replay/netplay/gate halves
#      agree by construction);
#   2. the visible-overlay rule (a typed tile draws ONLY when its resolved
#      palette color differs from the zone floor — nest's footstep-only
#      dirt remap yields ZERO rects, the look byte-stability law).
class TileVariantsTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def registry = @registry ||= Core::TileRegistry.new(DATA["tiles"])
  def map(key) = Core::TileMap.new(DATA["zones/#{key}"])

  def test_pick_is_deterministic_in_range_and_covers_all_indices
    picks = (0...12).flat_map { |x| (0...12).map { |y| App::TileVariants.pick("z", x, y, 3) } }
    again = (0...12).flat_map { |x| (0...12).map { |y| App::TileVariants.pick("z", x, y, 3) } }
    assert_equal picks, again
    assert_equal [0, 1, 2], picks.uniq.sort, "a 12x12 field must exercise every variant"
    assert_equal 0, App::TileVariants.pick("z", 5, 5, 1)
    refute_equal App::TileVariants.pick("a", 5, 5, 3).then { |p| [p] * 144 },
                 (0...12).flat_map { |x| (0...12).map { |y| App::TileVariants.pick("a", x, y, 3) } },
                 "picks must vary across coords, not repeat one index"
  end

  def test_live_remapped_zones_draw_nothing
    %w[nest district].each do |z|
      assert_empty App::TileVariants.rects(map(z), registry),
                   "#{z} must draw zero overlay rects (look byte-stability law)"
    end
  end

  def test_grass_fixture_draws_visible_typed_tiles_only
    rects = App::TileVariants.rects(map("grass_fixture"), registry)
    refute_empty rects
    refs = rects.map { |(_, _, ref)| ref }.uniq.sort
    assert_equal %i[dirt grass grass_b grass_c wood], refs,
                 "grass variants + dirt + wood show; stone plaza ('.') resolves floor and draws nothing"
    grass_cols = rects.select { |(tx, _, _)| tx.between?(1, 8) }
    assert_equal %i[grass grass_b grass_c], grass_cols.map { |(_, _, r)| r }.uniq.sort,
                 "the grass field must show all three authored variants"
    assert rects.none? { |(tx, ty, _)| map("grass_fixture").wall?(tx, ty) },
           "walls never carry overlay rects"
  end

  def test_rects_are_deterministic_across_instances
    a = App::TileVariants.rects(map("grass_fixture"), registry)
    b = App::TileVariants.rects(map("grass_fixture"), Core::TileRegistry.new(DATA["tiles"]))
    assert_equal a, b
  end

  def test_nil_registry_is_empty
    assert_empty App::TileVariants.rects(map("nest"), nil)
  end
end
