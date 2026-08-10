require_relative "../test_helper"
require "core/event_bus"
require "core/tile_map"
require "game/creature"
require "game/projectile"

class ProjectileTest < Minitest::Test
  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["############", "#..........#", "#..........#", "#..........#", "############"],
    pack_spawn: [[1, 1], [1, 2], [1, 3]]
  )

  KIT = {
    max_hp: 50, step_frames: 16, aggro_tiles: 12,
    attack: { damage: 12, windup_frames: 24, active_frames: 6, recovery_frames: 0,
              exhaust_frames: 66, arc: "ring", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    knockback_frames_per_tile: 5, interrupt_on_hit: false
  }.freeze

  EVENTS = %i[attack_started special_started attack_hit damage_dealt actor_died dodged].freeze

  def bus = @bus ||= Core::EventBus.new.register(*EVENTS)

  def human(tile, name)
    Game::Creature.new(bus:, kit: KIT, kit_name: :rusher, map: MAP, tile:, faction: :human, name:)
  end

  def shooter
    @shooter ||= human([1, 2], "owner")
  end

  def projectile(tile: [2, 2], dir: [1, 0], range: 6)
    Game::Projectile.new(owner: shooter, map: MAP, tile:, dir:,
                         damage: 20, range_tiles: range, frames_per_tile: 4)
  end

  def test_flies_one_tile_per_step_window
    p = projectile
    assert_equal [2, 2], p.tile
    3.times { p.tick(hostiles: []) }
    assert_equal [2, 2], p.tile, "tile commits on the 4th frame, not before"
    p.tick(hostiles: [])
    assert_equal [3, 2], p.tile
  end

  def test_stops_at_wall
    p = projectile(tile: [9, 2]) # wall at x=11; travels 10, then blocked
    12.times { p.tick(hostiles: []) }
    assert p.done?, "wall ends the flight"
    assert_equal [10, 2], p.tile, "rests on the last passable tile"
  end

  def test_hits_first_hostile_and_reports_it
    target = human([5, 2], "victim")
    p = projectile
    hit = nil
    16.times { hit ||= p.tick(hostiles: [target]) }
    assert_equal target, hit, "the projectile reports what it struck"
    assert p.done?
    assert_equal [5, 2], p.tile
  end

  def test_range_cap_expires_flight
    p = projectile(range: 3)
    24.times { p.tick(hostiles: []) }
    assert p.done?
    assert_equal [5, 2], p.tile, "3 tiles from [2,2] and no further"
  end

  def test_determinism_two_identical_projectiles
    a = projectile
    b = projectile
    positions = ->(pr) { 10.times.map { pr.tick(hostiles: []); [pr.tile, pr.x, pr.y] } }
    assert_equal positions.call(a), positions.call(b)
  end
end
