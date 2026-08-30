require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "core/tile_map"
require "game/world"

# v15 increment 1: zone 5 (low_quay) — the stretch zone past zone 4
# Stationless by design (fork 1: value climbs
# home); densest field; the stair down is UNSEALED (the way was paid at
# seal2). Real World + data, no mocks — these tests pin the DATA wiring;
# the challenger's chant/seize mechanics land in increments 3-4.
class LowQuayTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]
  HITSTOP_SLACK = DATA["balance/combat"][:feel][:hitstop_frames_kill] + 4

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def seal1
    @seal1 ||= DATA["zones/district"][:stations].find { |s| s[:type] == "seal" }
  end

  def seal2
    @seal2 ||= DATA["zones/district_two"][:stations].find { |s| s[:type] == "seal" }
  end

  # The full paid chain: Longrow seal -> camp -> Keyward seal -> Slow Door.
  def enter_slow_door!
    world.possessed.walker.teleport(29, 8)
    drive(world, scripted({}), 2)
    src = world.possessed
    src.walker.teleport(*seal1[:at])
    (world.pack.living - [src]).each_with_index { |m, i| m.walker.teleport(2, 2 + i) }
    world.pack.bank!(ECO[:breach_cost])
    assert world.interact(src)
    src.walker.teleport(*seal1[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_equal "camp", world.zone_name
    world.possessed.walker.teleport(19, 5)
    drive(world, scripted({}), 2)
    assert_equal "district_two", world.zone_name
    src = world.possessed
    src.walker.teleport(*seal2[:at])
    (world.pack.living - [src]).each_with_index { |m, i| m.walker.teleport(2, 2 + i) }
    world.pack.bank!(ECO[:breach_cost_2])
    assert world.interact(src)
    src.walker.teleport(*seal2[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_equal "slow_door", world.zone_name
  end

  def descend!
    enter_slow_door!
    world.possessed.walker.teleport(7, 1)
    drive(world, scripted({}), 2)
    assert_equal "low_quay", world.zone_name
  end

  # --- the zone itself -----------------------------------------------------

  def test_the_low_quay_declares_its_shape
    map = Core::TileMap.new(DATA["zones/low_quay"])
    assert_equal "ZONE 5", map.display_name
    # v20 T7: floor -3, Junior's MEDUSA LOWER canvas (52x52), anchored at
    # the serpent-head arrival.
    assert_equal 52, map.cols
    assert_equal 52, map.rows
    assert_equal(-3, map.floor, "the abyss is the descent's last step")
    refute map.hub, "the abyss is not a refuge"
    assert_equal [10, 8], map.gradient_anchor
  end

  def test_the_low_quay_has_no_stations
    map = Core::TileMap.new(DATA["zones/low_quay"])
    assert_empty map.stations, "stationless by design — value climbs home"
  end

  # Codex fold 1b: BOTH sides of the new edge declare anchors — the reverse
  # transition mutates slow_door's arrival list, and the fallback anchor is
  # arrival-order-dependent (the v12 re-anchor trap).
  def test_the_slow_door_declares_an_anchor
    map = Core::TileMap.new(DATA["zones/slow_door"])
    refute_nil map.gradient_anchor, "slow_door must pin its own anchor"
  end

  def test_the_stair_descends_unsealed
    descend!
    assert_equal "ZONE 5", world.map.display_name
    assert world.banner?, "arriving somewhere earned announces itself"
    refute world.map.hub, "the quay does not re-home the pack"
  end

  def test_the_low_quay_returns_up_the_stair
    descend!
    world.possessed.walker.teleport(9, 8)
    drive(world, scripted({}), 2)
    assert_equal "slow_door", world.zone_name
  end

  def test_the_low_quay_seeds_the_densest_field
    descend!
    kits = world.humans.map(&:kit_name).tally
    assert_equal 24, kits[:stinger], "the abyss watchers (first ranged hostiles)"
    assert_equal 5, kits[:warden], "the medusas hold the core (kit carried from -2)"
    assert_equal 1, kits[:challenger], "one named human, posted deep"
  end

  def test_the_low_quay_band_map_is_richest
    descend!
    # v20 T7: gate_distance is WALK distance - the coil detours price the
    # gradient (head pocket 3.0, causeway 3.5, the medusa core pays max).
    assert_in_delta 3.0, world.send(:gradient_multiplier, [12, 8])
    assert_in_delta 3.5, world.send(:gradient_multiplier, [20, 25])
    assert_in_delta 4.0, world.send(:gradient_multiplier, [33, 25])
  end

  # --- the challenger KIND (data-complete now; code reads it at 3-4) -------

  def test_the_challenger_kit_is_declared_and_unique
    kit = DATA["balance/combat"][:kits][:challenger]
    refute_nil kit, "the challenger kind exists in data"
    assert_nil kit[:respawn_frames], "no respawn: one man, one death per session"
    seize = kit[:seize]
    refute_nil seize, "the seize block ships with the kit"
    %i[chant_frames range_tiles duration_frames cooldown_frames cause].each do |k|
      refute_nil seize[k], "seize.#{k} declared in data"
    end
    assert_equal [8], kit[:drop_table], "one fat drop"
  end
end
