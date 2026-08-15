require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v16 (e): a death records a kill pop — transient render data on the world
# (taunt_pulses pattern: ticked in tick_world so hitstop pauses it, reset on
# zone entry, renderer is a pure reader).
class KillPopTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  POP = DATA["balance/combat"][:feel][:pop_frames]

  def drive(world, n)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  # The home zone starts empty of humans — plant victims on free passable
  # tiles (drop_band_test's add_human idiom).
  def free_tiles(world, count)
    map = world.map
    tiles = []
    map.rows.times do |ty|
      map.cols.times do |tx|
        next unless map.passable?(tx, ty)
        next if world.actors.any? { |a| a.tile == [tx, ty] }
        tiles << [tx, ty]
        return tiles if tiles.size == count
      end
    end
    tiles
  end

  def spawn_and_kill(world, tile)
    world.send(:add_human, world.zone_name, :rusher, tile)
    victim = world.humans.find { |c| c.tile == tile }
    victim.take_hit(damage: victim.hp, attacker: world.possessed) until victim.dead?
    victim
  end

  def test_death_records_a_pop_at_the_victim_tile
    world = Game::World.new(DATA)
    tile = free_tiles(world, 1).first
    spawn_and_kill(world, tile)
    drive(world, 1) # bus flush -> :actor_died -> pop recorded
    pop = world.kill_pops.find { |p| p[:tile] == tile }
    refute_nil pop, "kill left no pop record"
    assert_equal POP, pop[:pop_frames]
    assert_kind_of Integer, pop[:phase]
  end

  def test_pop_ticks_down_and_expires
    world = Game::World.new(DATA)
    spawn_and_kill(world, free_tiles(world, 1).first)
    drive(world, 1)
    # The possessed's kill starts hitstop, which PAUSES pops (the tick_drops
    # law — exactly what the spec promises). Burn it before measuring.
    hitstop = DATA["balance/combat"][:feel][:hitstop_frames_kill]
    drive(world, hitstop)
    start = world.kill_pops.first[:frames_left]
    drive(world, 3)
    assert_equal start - 3, world.kill_pops.first[:frames_left]
    drive(world, POP)
    assert_empty world.kill_pops
  end

  def test_same_frame_kills_get_distinct_phases
    world = Game::World.new(DATA)
    free_tiles(world, 2).each { |t| spawn_and_kill(world, t) }
    drive(world, 1)
    phases = world.kill_pops.map { |p| p[:phase] }
    assert_equal 2, phases.size
    refute_equal phases[0], phases[1], "phase must vary by tile"
  end
end
