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
    assert_equal plan.crossed, plan.struck, "free landing beyond — blade and feet agree"
    assert_equal 16, plan.duration
    assert_equal [1, 0], [plan.dx, plan.dy]
  end

  # s66 dash-strike: a body on the tile past the landing is in STRUCK
  # (the damage scan) but never in CROSSED (the movement) — feet stop
  # short, blade reaches.
  def test_plan_dash_struck_reaches_past_a_blocked_landing
    plan = walker.plan_dash(
      1, 0, max_tiles: 3, frames_per_tile: 4,
      blocked: [[6, 2]], through: true
    )

    assert_equal [5, 2], plan.landing
    assert_equal [[4, 2], [5, 2]], plan.crossed
    assert_equal [[4, 2], [5, 2], [6, 2]], plan.struck
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

  # --- covers? (D2 impact occupancy, s66) --------------------------------

  def test_covers_settled_body_covers_exactly_its_tile
    w = walker
    assert w.covers?(3, 2)
    refute w.covers?(2, 2), "a settled body covers no neighbour"
    refute w.covers?(4, 2)
  end

  def test_covers_mid_step_body_covers_departure_and_landing
    w = walker
    w.step(1, 0, frames: 16)
    assert w.covers?(3, 2), "departure tile stays covered while the tween flies"
    assert w.covers?(4, 2), "landing tile is covered from commit (logical tile law)"
    refute w.covers?(5, 2)
    16.times { w.tick }
    refute w.covers?(3, 2), "a finished tween releases the departure tile"
    assert w.covers?(4, 2)
  end

  def test_covers_teleport_carries_no_phantom_departure
    w = walker
    w.step(1, 0, frames: 16)
    w.teleport(6, 3)
    refute w.covers?(3, 2)
    refute w.covers?(4, 2)
    assert w.covers?(6, 3)
  end

  def test_covers_interrupted_step_departs_from_the_committed_tile
    w = walker
    w.step(1, 0, frames: 16) # committed to [4,2], tween in flight
    w.dash(0, 1, max_tiles: 2, frames_per_tile: 8) # retarget mid-tween (wall caps at y=3)
    assert w.covers?(4, 2), "the interrupted step's landing is the new departure"
    assert w.covers?(4, 3), "dash landing covered from commit"
    refute w.covers?(3, 2), "two steps back is never covered"
  end
end
