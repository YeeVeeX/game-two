require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "core/tile_map"
require "game/world"

# v12 breach chain, increment 2: the hub advances with you. Home is the
# LAST HUB ENTERED (session-only) — wipe respawn and vat regrowth anchor
# to the current home, not the hardcoded nest. Real World + data, no mocks.
class RehomingTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]
  # The breach fires the strongest feel kick; hitstop pauses the sim clock.
  HITSTOP_SLACK = DATA["balance/combat"][:feel][:hitstop_frames_kill] + 4

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def seal_station
    @seal_station ||= DATA["zones/district"][:stations].find { |s| s[:type] == "seal" }
  end

  def camp_map = @camp_map ||= Core::TileMap.new(DATA["zones/camp"])

  def enter_district!
    world.possessed.walker.teleport(29, 8)
    drive(world, scripted({}), 2)
    assert_equal "district", world.zone_name
  end

  def breach_and_enter_camp!
    enter_district!
    src = world.possessed
    src.walker.teleport(*seal_station[:at])
    # Park allies far from the seal so nothing contests the interaction.
    (world.pack.living - [src]).each_with_index do |m, i|
      m.walker.teleport(2, 2 + i)
    end
    world.pack.bank!(ECO[:breach_cost])
    assert world.interact(src)
    src.walker.teleport(*seal_station[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_equal "camp", world.zone_name
  end

  # --- the hub declaration ------------------------------------------------

  def test_nest_is_declared_a_hub
    assert Core::TileMap.new(DATA["zones/nest"]).hub,
           "the nest is the initial home — hubs are data, not code"
  end

  # --- re-homing on hub entry ----------------------------------------------

  def test_entering_the_camp_rehomes_once
    events = []
    world.bus.subscribe(:home_rehomed) { |e| events << e }
    breach_and_enter_camp!
    world.bus.process
    assert_equal 1, events.length
    assert_equal "camp", events.first[:zone]
    # Step out to the district and back in: re-entering the CURRENT home
    # emits nothing — the event marks change, not presence.
    world.possessed.walker.teleport(0, 5)
    drive(world, scripted({}), 2)
    assert_equal "district", world.zone_name
    world.possessed.walker.teleport(42, 13)
    drive(world, scripted({}), 2)
    assert_equal "camp", world.zone_name
    world.bus.process
    assert_equal 1, events.length, "camp re-entry is not a re-home"
  end

  def test_home_is_the_last_hub_entered
    events = []
    world.bus.subscribe(:home_rehomed) { |e| events << e }
    breach_and_enter_camp!
    # Walk all the way home: camp -> district -> nest. The nest is a hub,
    # so returning re-homes BACK (home = last hub entered, period).
    world.possessed.walker.teleport(0, 5)
    drive(world, scripted({}), 2)
    assert_equal "district", world.zone_name
    world.possessed.walker.teleport(0, 13)
    drive(world, scripted({}), 2)
    assert_equal "nest", world.zone_name
    world.bus.process
    assert_equal 2, events.length
    assert_equal "nest", events.last[:zone]
  end

  def test_nest_only_session_never_rehomes
    events = []
    world.bus.subscribe(:home_rehomed) { |e| events << e }
    enter_district!
    world.possessed.walker.teleport(0, 13)
    drive(world, scripted({}), 2)
    assert_equal "nest", world.zone_name
    world.bus.process
    assert_empty events, "a nest-only session behaves exactly as today"
  end

  # --- what home MEANS: wipe respawn + vat regrowth ------------------------

  def test_wipe_respawn_lands_at_the_current_home
    breach_and_enter_camp!
    world.pack.members.each { |m| m.take_hit(damage: m.hp, attacker: m) until m.dead? }
    drive(world, scripted({}), DATA["balance/combat"][:respawn_frames] + HITSTOP_SLACK + 5)
    assert_equal "camp", world.zone_name,
                 "the wipe sends the pack HOME — and home has advanced"
    world.pack.living.each do |m|
      assert_includes camp_map.pack_spawn, m.tile
    end
  end

  def test_vat_regrowth_targets_the_current_home
    breach_and_enter_camp!
    ally = (world.pack.members - [world.possessed]).first
    ally.take_hit(damage: ally.hp, attacker: ally) until ally.dead?
    world.pack.bank!(ECO[:regrow_cost])
    vat = camp_map.stations.find { |s| s[:type] == "vat" }
    world.possessed.walker.teleport(*vat[:at])
    assert world.interact(world.possessed)
    refute ally.dead?
    assert_equal camp_map.pack_spawn[world.pack.members.index(ally)], ally.tile,
                 "regrowth pulls flesh HOME — and home is the camp now"
  end
end
