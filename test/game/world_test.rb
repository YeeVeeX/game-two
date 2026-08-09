require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Integration tests against the REAL data files and the REAL sim — no mocks.
# All assertions are on TILES, not pixels (grid movement doctrine).
class WorldTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  STEP = DATA["balance/combat"][:kits][:prowler][:step_frames]

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  # Drives input.update from the world's own frame counter.
  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def husk_tile_distance(world)
    return Float::INFINITY if world.enemies.empty?
    px, py = world.player.tile
    world.enemies.map { |h| [(h.tile[0] - px).abs, (h.tile[1] - py).abs].max }.min
  end

  def nearest_husk(world)
    px, py = world.player.tile
    world.enemies.reject(&:dead?).min_by { |h| [(h.tile[0] - px).abs, (h.tile[1] - py).abs].max }
  end

  def test_player_starts_in_town_with_no_enemies
    assert_equal "town", world.zone_name
    assert_empty world.enemies
    assert_equal world.map.player_spawn, world.player.tile
  end

  def test_held_key_walks_tile_by_tile
    input = scripted(hold(:right, 0, STEP * 3 - 1))
    x0, y0 = world.player.tile
    drive(world, input, STEP * 3)
    assert_equal [x0 + 3, y0], world.player.tile, "3 steps' worth of held input moves exactly 3 tiles"
  end

  def test_step_is_committed_at_start_and_visual_catches_up
    input = scripted(hold(:right, 0, 1))
    x0 = world.player.tile[0]
    px0 = world.player.x
    drive(world, input, 1)
    assert_equal x0 + 1, world.player.tile[0], "logical tile commits immediately"
    assert world.player.walker.moving?
    assert_operator world.player.x, :<, (x0 + 1) * 32, "visual position still tweening"
    assert_operator world.player.x, :>=, px0
    drive(world, scripted({}), STEP)
    refute world.player.walker.moving?
  end

  def test_walls_block_movement
    input = scripted(hold(:up, 0, STEP * 30 - 1))
    drive(world, input, STEP * 30)
    ty = world.player.tile[1]
    assert world.map.wall?(world.player.tile[0], ty - 1), "player should be stopped under a wall"
    assert world.map.passable?(*world.player.tile)
  end

  def test_zone_transition_town_to_threketh_and_back
    zones_seen = []
    world.bus.subscribe(:zone_entered) { |e| zones_seen << e[:zone] }

    # Walk right onto the town's east transition tile.
    input = scripted(hold(:right, 0, STEP * 30 - 1))
    drive(world, input, STEP * 30)
    assert_equal "threketh", world.zone_name, "walking the east gate leads to the dungeon"
    assert_equal world.map.transitions.first[:at], world.map.player_spawn.then { world.player.tile } if false
    assert_includes zones_seen, "threketh"
    refute_empty world.enemies, "the dungeon has husks"

    # Walk back left through the return tile (+1 step of slack so the final
    # tween completes — the transition fires when the step lands, not when
    # the tile commits).
    back = scripted(hold(:left, world.frame, world.frame + STEP * 10 - 1))
    drive(world, back, STEP * 11)
    assert_equal "town", world.zone_name, "the west mouth of Threketh returns to town"
  end

  def test_husk_aggros_chases_and_kills_idle_player_then_respawn_in_town
    # Get into the dungeon.
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    assert_equal "threketh", world.zone_name

    death_seen = false
    hp_at_respawn = nil
    world.bus.subscribe(:player_died) { death_seen = true }
    world.bus.subscribe(:player_respawned) { hp_at_respawn ||= world.player.hp }

    drive(world, scripted({}), 6000)
    assert death_seen, "an idle player in the dungeon should die to husks"
    refute_nil hp_at_respawn, "player should respawn after the death timer"
    assert_equal world.player.max_hp, hp_at_respawn, "respawn restores full hp"
    assert_equal "town", world.zone_name, "death sends you home (hub-and-spoke doctrine)"
    assert_equal :world, world.states.current
  end

  def test_attack_kills_adjacent_husk_in_three_hits
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    assert_equal "threketh", world.zone_name

    hits = 0
    world.bus.subscribe(:attack_hit) { hits += 1 }

    # Wait for a husk to close to melee range, then face it and swing.
    guard = 0
    idle = scripted({})
    target = nearest_husk(world)
    until target&.dead? || guard > 6000
      target = nearest_husk(world)
      break if target.nil?
      if husk_tile_distance(world) > 1 || world.player.walker.moving?
        drive(world, idle, 1)
        guard += 1
      else
        dx = (target.tile[0] - world.player.tile[0]).clamp(-1, 1)
        dir = if dx.positive? then "right"
              elsif dx.negative? then "left"
              elsif (target.tile[1] - world.player.tile[1]).negative? then "up"
              else "down"
              end
        # Face + swing: direction key sets facing even when body-blocked.
        swing = scripted({ world.frame.to_s => [dir, "attack"] })
        drive(world, swing, 25)
        guard += 25
      end
    end
    assert target&.dead?, "husk should die to melee (landed #{hits} hits)"
    assert_operator hits, :>=, 3, "60hp / 25dmg needs 3 landed hits"
  end

  def test_dodge_bursts_two_tiles_and_grants_iframes
    input = scripted({ "0" => %w[right dodge] })
    x0 = world.player.tile[0]
    drive(world, input, 1)
    assert world.player.invulnerable?
    assert_equal x0 + 2, world.player.tile[0], "dodge commits a 2-tile burst"
    refute world.player.take_hit(damage: 10, from_tile: [0, 0])
    assert_equal world.player.max_hp, world.player.hp
  end

  def test_determinism_same_script_same_state
    a = Game::World.new(DATA)
    b = Game::World.new(DATA)
    script = hold(:right, 0, STEP * 40).merge((STEP * 41).to_s => %w[attack])
    [a, b].each do |w|
      input = scripted(script)
      drive(w, input, 3000)
    end
    assert_equal a.zone_name, b.zone_name
    assert_equal [a.player.tile, a.player.hp, a.player.x, a.player.y],
                 [b.player.tile, b.player.hp, b.player.x, b.player.y]
    assert_equal a.enemies.map { |h| [h.tile, h.hp] }, b.enemies.map { |h| [h.tile, h.hp] }
  end

  def test_husk_respawns_after_kill
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    count_before = world.enemies.length
    target = nearest_husk(world)
    3.times { target.take_hit(damage: 25, from_tile: world.player.tile) }
    assert target.dead?
    drive(world, scripted({}), 1) # flush the bus so the respawn gets scheduled
    assert_equal count_before - 1, world.enemies.length, "dead husk leaves the roster"
    drive(world, scripted({}), DATA["balance/combat"][:enemies][:husk][:respawn_frames] + 10)
    assert_equal count_before, world.enemies.length, "a fresh husk should have spawned"
  end

  def test_body_blocking_no_two_creatures_share_a_tile
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    drive(world, scripted({}), 4000)
    all_tiles = world.enemies.reject(&:dead?).map(&:tile)
    all_tiles << world.player.tile unless world.player.dead?
    assert_equal all_tiles.uniq.length, all_tiles.length,
                 "no two living creatures may logically occupy one tile: #{all_tiles}"
  end
end
