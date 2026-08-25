require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/save_state"

# s69 content-fill: the INTERIOR DOOR law — a sealed same-zone transition
# (basement_2's toll pocket, first live instance). The pocket is walled
# off; the ONLY way in is the seal-priced door teleport, the only way out
# the rope. Crossing machinery is untouched: Crossing.validated_arrivals
# accepts a self-edge (the destination zone is known — it is the source),
# enter_zone with name == @zone_name never stamps zone_left_at, and the
# no-stamp branch snaps displaced humans home (frozen-zone law applied
# same-zone). These tests pin that composition against the REAL data.
class InteriorDoorTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]

  def seeded_facts
    members = DATA["balance/combat"][:pack][:members].map do |kit|
      { "kit" => kit, "hp" => 40, "inscribed" => false }
    end
    { "banked" => 60, "provisions" => 0, "home_zone" => "zone_7", "breached" => [],
      "members" => members, "counters" => { "boss_1_defeats" => 1, "sessions" => 1 },
      "progression" => { "level" => 5, "xp" => 0 } }
  end

  def drive(w, n = 2)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(w.frame)
      w.tick(input)
    end
  end

  def park_allies_beside(w, tile)
    (w.pack.living - [w.possessed]).each_with_index do |m, i|
      m.walker.teleport(tile[0] - 1 - i, tile[1])
    end
  end

  def pocket_world
    w = Game::World.new(DATA, seed: 7, save: seeded_facts)
    w.start_in("basement_2")
    w
  end

  def test_the_divide_is_solid_and_the_door_is_sealed_same_zone
    w = pocket_world
    (1..6).each { |y| assert w.map.wall?(7, y), "divide column [7,#{y}] must be wall" }
    door = w.map.transition_at(6, 3)
    assert_equal "basement_2", door[:to], "the door is a SAME-ZONE way"
    assert door[:sealed], "the door reads sealed until the toll is paid"
    seal = w.map.station_at(6, 2)
    assert_equal "seal", seal[:type]
    assert_equal [6, 3], seal[:opens], "the seal opens the door (s34 law shape)"
  end

  def test_sealed_door_refuses_and_toll_opens_the_pocket
    w = pocket_world
    w.possessed.walker.teleport(6, 3)
    park_allies_beside(w, [6, 3])
    drive(w)
    assert_equal [6, 3], w.possessed.tile, "a sealed interior door is not a way"

    w.possessed.walker.teleport(6, 2)
    assert w.interact(w.possessed), "the toll is a priced station action"
    assert w.breached?("basement_2", [6, 3])
    assert_equal 60 - ECO[:breach_cost], w.pack.banked

    w.possessed.walker.teleport(6, 3)
    park_allies_beside(w, [6, 3])
    drive(w, DATA["balance/combat"][:feel][:hitstop_frames_kill] + 6)
    assert_equal "basement_2", w.zone_name, "the crossing stays inside the zone"
    assert_equal [9, 3], w.possessed.tile, "the door lands the pack in the pocket"
  end

  def test_same_zone_crossing_snaps_displaced_humans_home
    w = pocket_world
    displaced = w.humans.find { |h| h.kit_name == :husk }
    home = displaced.home_tile
    displaced.walker.teleport(home[0] - 1, home[1])
    refute_equal home, displaced.tile

    w.possessed.walker.teleport(6, 2)
    w.interact(w.possessed)
    w.possessed.walker.teleport(6, 3)
    park_allies_beside(w, [6, 3])
    drive(w, DATA["balance/combat"][:feel][:hitstop_frames_kill] + 6)
    assert_equal "basement_2", w.zone_name
    assert_equal home, displaced.tile,
                 "no-stamp same-zone entry snaps humans home (frozen-zone law)"
  end

  def test_the_rope_climbs_back_out_of_the_pocket
    w = pocket_world
    w.possessed.walker.teleport(6, 2)
    w.interact(w.possessed)
    w.possessed.walker.teleport(6, 3)
    park_allies_beside(w, [6, 3])
    drive(w, DATA["balance/combat"][:feel][:hitstop_frames_kill] + 6)
    assert_equal [9, 3], w.possessed.tile

    w.possessed.walker.teleport(10, 1)
    park_allies_beside(w, [9, 1])
    drive(w, 30)
    assert_equal [10, 1], w.possessed.tile, "resting on the rope never auto-climbs"
    assert w.interact(w.possessed), "the climb out is a free interact"
    assert_equal "basement_2", w.zone_name
    assert_equal [5, 3], w.possessed.tile, "the rope lands back in the main room"
  end

  def test_the_interior_breach_survives_the_strict_decoder
    facts = seeded_facts.merge("breached" => [["basement_2", [6, 3]]])
    refusal = Game::SaveState.refusal_for(facts, data: DATA)
    assert_nil refusal, "an interior seal's breach tuple is a legal save fact (got: #{refusal})"
  end

  # --- dungeon_1's toll-bypass fork (content-fill wave 3/3) -------------

  def test_dungeon_fork_door_is_sealed_same_zone_and_the_chamber_is_walled
    w = Game::World.new(DATA, seed: 7, save: seeded_facts)
    w.start_in("dungeon_1")
    door = w.map.transition_at(18, 2)
    assert_equal "dungeon_1", door[:to], "the bypass door is a SAME-ZONE way"
    assert door[:sealed]
    seal = w.map.station_at(17, 2)
    assert_equal "seal", seal[:type]
    assert_equal [18, 2], seal[:opens]
    # The chamber is watertight except the door teleport and the circuit
    # mouth at [25,8]/[26,8]: column x19 (y1-7) + row-8 walls both sides.
    (1..7).each { |y| assert w.map.wall?(19, y), "[19,#{y}] must be wall" }
    (18..24).each { |x| assert w.map.wall?(x, 8), "[#{x},8] must be wall" }
    (27..30).each { |x| assert w.map.wall?(x, 8), "[#{x},8] must be wall" }
    assert w.map.passable?(25, 8), "the circuit mouth stays open"
    assert w.map.passable?(26, 8), "the circuit mouth stays open"
  end

  def test_dungeon_toll_bypass_teleports_into_the_chamber
    w = Game::World.new(DATA, seed: 7, save: seeded_facts)
    w.start_in("dungeon_1")
    w.possessed.walker.teleport(17, 2)
    park_allies_beside(w, [17, 2])
    assert w.interact(w.possessed), "the bypass toll is a priced station action"
    assert w.breached?("dungeon_1", [18, 2])
    w.possessed.walker.teleport(18, 2)
    park_allies_beside(w, [18, 2])
    drive(w, DATA["balance/combat"][:feel][:hitstop_frames_kill] + 6)
    assert_equal "dungeon_1", w.zone_name
    assert_equal [21, 2], w.possessed.tile, "the door lands the pack inside the chamber"
  end
end
