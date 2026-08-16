require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "core/tile_map"
require "game/world"

# v12 breach chain, increment 3: The Keyward (district_two) behind the first
# seal, the second seal priced as a stretch, and The Slow Door landing behind
# it. Real World + data, no mocks — these tests pin the DATA wiring; the seal
# verb mechanics are already pinned generically in seal_breach_test.
class DistrictTwoTest < Minitest::Test
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

  def seal1
    @seal1 ||= DATA["zones/district"][:stations].find { |s| s[:type] == "seal" }
  end

  def seal2
    @seal2 ||= DATA["zones/district_two"][:stations].find { |s| s[:type] == "seal" }
  end

  def enter_camp!
    world.possessed.walker.teleport(29, 8)
    drive(world, scripted({}), 2)
    src = world.possessed
    src.walker.teleport(*seal1[:at])
    (world.pack.living - [src]).each_with_index do |m, i|
      m.walker.teleport(2, 2 + i)
    end
    world.pack.bank!(ECO[:breach_cost])
    assert world.interact(src)
    src.walker.teleport(*seal1[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_equal "camp", world.zone_name
  end

  def enter_district_two!
    enter_camp!
    world.possessed.walker.teleport(19, 5)
    drive(world, scripted({}), 2)
    assert_equal "district_two", world.zone_name
  end

  def at_seal2!
    enter_district_two!
    src = world.possessed
    src.walker.teleport(*seal2[:at])
    (world.pack.living - [src]).each_with_index do |m, i|
      m.walker.teleport(2, 2 + i)
    end
    src
  end

  # --- the zone itself -----------------------------------------------------

  def test_the_keyward_declares_its_shape
    map = Core::TileMap.new(DATA["zones/district_two"])
    assert_equal "ZONE 3", map.display_name
    assert_equal 44, map.cols
    assert_equal 26, map.rows
    refute map.hub, "new ground is not a refuge"
    assert_equal [1, 13], map.gradient_anchor
  end

  def test_the_keyward_seeds_a_denser_field
    enter_district_two!
    kits = world.humans.map(&:kit_name).tally
    assert_equal 16, kits[:rusher]
    assert_equal 4, kits[:rusher_hater]
  end

  def test_the_keyward_band_map_is_richer
    enter_district_two!
    assert_equal 0, world.send(:gradient_band, [2, 13])
    assert_equal 1, world.send(:gradient_band, [20, 13])
    assert_equal 2, world.send(:gradient_band, [42, 13])
    assert_in_delta 2.0, world.send(:gradient_multiplier, [2, 13])
    assert_in_delta 2.5, world.send(:gradient_multiplier, [20, 13])
    assert_in_delta 3.0, world.send(:gradient_multiplier, [42, 13])
  end

  # --- the second seal (the stretch) ----------------------------------------

  def test_second_seal_prices_the_stretch
    at_seal2!
    assert_equal ECO[:breach_cost_2], world.station_price(seal2)
    assert ECO[:breach_cost_2] > ECO[:breach_cost] * 3,
           "the second toll is a long-greedy-session stretch, not a step"
  end

  def test_second_seal_transition_is_sealed_until_paid
    at_seal2!
    world.possessed.walker.teleport(*seal2[:opens])
    drive(world, scripted({}), 3)
    assert_equal "district_two", world.zone_name, "a sealed door is not a gate"
  end

  def test_second_breach_opens_the_slow_door
    src = at_seal2!
    world.pack.bank!(ECO[:breach_cost_2])
    assert world.interact(src)
    src.walker.teleport(*seal2[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_equal "slow_door", world.zone_name
    assert_equal "ZONE 4", world.map.display_name
    assert world.banner?, "arriving somewhere new announces itself"
    refute world.map.hub, "the landing does not re-home — it only waits"
  end

  def test_the_slow_door_returns_to_the_keyward
    src = at_seal2!
    world.pack.bank!(ECO[:breach_cost_2])
    world.interact(src)
    src.walker.teleport(*seal2[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_equal "slow_door", world.zone_name
    world.possessed.walker.teleport(7, 7)
    drive(world, scripted({}), 2)
    assert_equal "district_two", world.zone_name
  end
end
