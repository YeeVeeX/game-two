require_relative "../test_helper"
require "core/tile_map"
require "game/flow_field"

# A flow-field query outside the grid answers "no knowledge" (UNREACHED /
# nil) — it never raises and never wraps through Ruby's negative Array
# indexing. Pinned by the coop-night crash (2026-08-26): an away-from-home
# vat regrow left a body on a FOREIGN map whose tile indexed a 9-row field
# at y=14 — @dist[ty] was nil and the whole host session died mid-play.
class FlowFieldOobTest < Minitest::Test
  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["##########", "#........#", "#........#", "#........#", "##########"],
    pack_spawn: [[1, 1], [2, 1], [3, 1]]
  )

  def field
    f = Game::FlowField.new(MAP)
    f.recompute!([2, 2])
    f
  end

  def test_downhill_from_answers_nil_outside_the_grid_instead_of_raising
    f = field
    assert_nil f.downhill_from(4, 14),  "row past the grid must read as no-knowledge"
    assert_nil f.downhill_from(14, 2),  "col past the grid must read as no-knowledge"
    assert_nil f.downhill_from(2, -6),  "negative row must not wrap through Array#[]"
    assert_nil f.downhill_from(-6, 2),  "negative col must not wrap through Array#[]"
  end

  def test_distance_answers_unreached_outside_the_grid
    f = field
    assert_equal Game::FlowField::UNREACHED, f.distance(4, 14)
    assert_equal Game::FlowField::UNREACHED, f.distance(-6, 2)
  end

  def test_in_bounds_behavior_is_unchanged
    f = field
    assert_equal 0, f.distance(2, 2)
    step = f.downhill_from(4, 2)
    refute_nil step, "a reachable in-bounds tile still descends"
    assert_equal [-1, 0], step, "fixed STEPS order keeps the deterministic tie-break"
  end
end
