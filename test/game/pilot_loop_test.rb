require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# T4 done-condition, mechanized (spec §T4: "owner can walk the town,
# drain the well, fall into DUNGEON 1, rope back — from a dev launch"):
# the full loop through the REAL World over the REAL committed pilot
# data. Movement is staged (walker teleports, the seal_breach_test
# pattern); every crossing and the drain go through live verbs.
class PilotLoopTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]

  def seeded_facts
    members = DATA["balance/combat"][:pack][:members].map do |kit|
      { "kit" => kit, "hp" => 1, "inscribed" => false }
    end
    # level 6 clears the s68 town gates (basements 4/5, dungeon 6) —
    # this suite's subject is transition TYPING, not the level fact-gate
    # (level_gate_test/zone_tier_test own that law).
    { "banked" => 60, "provisions" => 0, "home_zone" => "zone_7", "breached" => [],
      "members" => members, "counters" => { "boss_1_defeats" => 1, "sessions" => 1 },
      "progression" => { "level" => 6, "xp" => 0 } }
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

  def test_the_pilot_loop_town_drain_fall_rope
    w = Game::World.new(DATA, seed: 7, save: seeded_facts)
    assert_equal "zone_7", w.zone_name, "home_zone zone_7 starts the session in town (hub law)"

    # The town: depot bank exists; the well is sealed water.
    bank = w.map.station_at(27, 14)
    assert_equal "bank", bank[:type], "the depot v0 is a bank station"
    hole = w.map.transition_at(33, 14)
    assert_equal "hole", hole[:type]
    assert hole[:sealed]

    # Walk onto the sealed hole: nothing (the well is not drained).
    w.possessed.walker.teleport(33, 14)
    park_allies_beside(w, [33, 14])
    drive(w)
    assert_equal "zone_7", w.zone_name, "an undrained well is not a way"

    # Drain it: pay the toll at the seal station (existing machinery).
    w.possessed.walker.teleport(31, 14)
    assert w.interact(w.possessed), "the drain is a priced station action"
    assert w.breached?("zone_7", [33, 14]), "the drain persists as a breached tuple (D11)"
    assert_equal 60 - ECO[:breach_cost], w.pack.banked

    # Fall in (drive past the breach hitstop).
    w.possessed.walker.teleport(33, 14)
    park_allies_beside(w, [33, 14])
    drive(w, DATA["balance/combat"][:feel][:hitstop_frames_kill] + 6)
    assert_equal "dungeon_1", w.zone_name, "falling commits"
    # FASE 6.1: DUNGEON 1 is the MEDUSA LOWER geometry - the fall lands at
    # the serpent head [10,8] (the rope back sits one tile west at [9,8]).
    assert_equal [10, 8], w.possessed.tile

    # No return transition at the landing (D4 one-way law).
    assert_nil w.map.transition_at(10, 8)

    # Rope back up — beside the landing (FASE 6.1: the medusa head's west edge).
    w.possessed.walker.teleport(9, 8)
    park_allies_beside(w, [9, 8])
    refute w.map.transition_at(9, 8)[:sealed]
    drive(w, 30)
    assert_equal "dungeon_1", w.zone_name, "resting on the rope never auto-climbs"
    assert w.interact(w.possessed), "the climb is a free interact"
    assert_equal "zone_7", w.zone_name
    assert_equal [33, 16], w.possessed.tile, "the rope lands beside the well"

    # The drain is session-durable: the way stays open on return.
    w.possessed.walker.teleport(33, 14)
    park_allies_beside(w, [33, 14])
    drive(w)
    assert_equal "dungeon_1", w.zone_name, "the drained well stays a way (wipe-proof family)"
  end

  def test_basement_stairs_are_two_way
    w = Game::World.new(DATA, seed: 7, save: seeded_facts)
    w.possessed.walker.teleport(26, 3)
    park_allies_beside(w, [26, 3])
    drive(w)
    assert_equal "basement_1", w.zone_name, "stairs_down fires on rest (D3)"
    assert_equal [4, 4], w.possessed.tile
    w.possessed.walker.teleport(4, 3)
    park_allies_beside(w, [4, 3])
    drive(w)
    assert_equal "zone_7", w.zone_name, "stairs_up returns — floors are zones"
  end

  def test_the_pilot_save_facts_survive_the_strict_decoder
    # The seeded dev-walk save (home zone_7 + the drained well) must be a
    # LEGAL save: the decoder's hub law + breached seal-tuple law both
    # cover the pilot data with ZERO schema changes (D11).
    facts = seeded_facts.merge("breached" => [["zone_7", [33, 14]]])
    refusal = Game::SaveState.refusal_for(facts, data: DATA)
    assert_nil refusal, "strict decoder must accept the pilot facts (got: #{refusal})"
  end
end
