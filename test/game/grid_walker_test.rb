require_relative "../test_helper"
require "core/tile_map"
require "game/grid_walker"

class GridWalkerTest < Minitest::Test
  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["##########", "#........#", "#........#", "#........#", "##########"],
    pack_spawn: [[1, 1], [2, 1], [3, 1]]
  )

  def walker(tile: [3, 2])
    Game::GridWalker.new(map: MAP, tile_x: tile[0], tile_y: tile[1], size: 28)
  end

  def test_plan_dash_returns_landing_crossed_tiles_and_duration
    plan = walker.plan_dash(
      1, 0, max_tiles: 4, frames_per_tile: 4,
      blocked: [[4, 2]], through: true
    )

    assert_equal [7, 2], plan.landing
    assert_equal [[4, 2], [5, 2], [6, 2], [7, 2]], plan.crossed
    assert_equal 16, plan.duration
    assert_equal [1, 0], [plan.dx, plan.dy]
  end

  def test_plan_dash_wall_truncates_crossed_path
    plan = walker(tile: [7, 2]).plan_dash(
      1, 0, max_tiles: 4, frames_per_tile: 4, through: true
    )

    assert_equal [8, 2], plan.landing
    assert_equal [[8, 2]], plan.crossed
    assert_equal 4, plan.duration
  end

  def test_plan_dash_refuses_when_every_reachable_landing_is_occupied
    plan = walker.plan_dash(
      1, 0, max_tiles: 2, frames_per_tile: 4,
      blocked: [[4, 2], [5, 2]], through: true
    )

    assert_nil plan
  end

  def test_non_through_plan_stops_before_first_body
    plan = walker.plan_dash(
      1, 0, max_tiles: 4, frames_per_tile: 4,
      blocked: [[5, 2]], through: false
    )

    assert_equal [4, 2], plan.landing
    assert_equal [[4, 2]], plan.crossed
  end

  def test_diagonal_duration_uses_existing_rounded_cost
    plan = walker.plan_dash(
      1, 1, max_tiles: 2, frames_per_tile: 4, through: true
    )

    assert_equal [4, 3], plan.landing
    assert_equal 6, plan.duration
  end
end
