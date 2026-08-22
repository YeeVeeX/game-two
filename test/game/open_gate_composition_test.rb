require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/save_state"

# T5 composition pin (s30, owner-approved): the ratified edge pair on REAL
# zone data through the REAL restore path — no fixture zones, no mock store.
# Gap closed (s29 audit): the sim law (requires_defeats reads the persisted
# fact) was proven on synthetic zones only, and the multi_floor_descent
# replay walks the real pair at defeats=0 — nothing had executed the OPEN
# gate end-to-end before the owners' payoff walk. These tests are that walk,
# in-suite, from a save-shaped fact hash the strict decoder itself accepts:
#   1. the earned defeat (boss_1_defeats: 1 — the owners' banked fact)
#      carries the pack low_quay [44,19] -> zone_7, landing on the declared
#      spawn [2,14] beside the return tile (the no-ping-pong law);
#   2. at defeats=0 the same real slab refuses (the mfd refusal, suite-pinned);
#   3. the return zone_7 [1,14] -> low_quay [43,19] is FREE (no fact required).
# Spawn/at literals are the ratified T5 pins (drafts/_wb-t5-wirein-20260821.md)
# — hardcoded on purpose, so data drift SCREAMS here before it can fizzle a
# live crossing.
class OpenGateCompositionTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  # Save-shaped facts modeled on the owners' live save (home=camp, full
  # roster, sessions carried) — the counters block is the fact under test.
  def owners_facts(defeats:)
    members = DATA["balance/combat"][:pack][:members].map do |kit|
      { "kit" => kit, "hp" => DATA["balance/combat"][:kits][kit.to_sym][:max_hp],
        "inscribed" => false }
    end
    { "banked" => 7, "provisions" => 0, "home_zone" => "camp", "breached" => [],
      "members" => members,
      "counters" => { "boss_1_defeats" => defeats, "sessions" => 13 },
      "progression" => { "level" => 1, "xp" => 0 } }
  end

  def world(defeats:)
    Game::World.new(DATA, save: owners_facts(defeats:))
  end

  def drive(w, n = 2)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(w.frame)
      w.tick(input)
    end
  end

  def park_allies_adjacent(w, tile)
    (w.pack.living - [w.possessed]).each_with_index do |m, i|
      m.walker.teleport(tile[0], tile[1] - 1 - i)
    end
  end

  def test_the_earned_defeat_opens_the_gate_on_the_real_pair
    facts = owners_facts(defeats: 1)
    assert_nil Game::SaveState.refusal_for(facts, data: DATA),
               "the fixture must be a save the strict decoder accepts — " \
               "otherwise this pins a state no real session can reach"
    w = Game::World.new(DATA, save: facts)
    assert_equal 1, w.boss_1_defeats,
                 "the restore path must carry the persisted defeat into the sim"
    w.start_in("low_quay")
    w.possessed.walker.teleport(44, 19)
    park_allies_adjacent(w, [44, 19])
    drive(w)
    assert_equal "zone_7", w.zone_name,
                 "the persisted defeat must open the T5 gate on the real pair"
    assert_equal [2, 14], w.possessed.tile,
                 "arrival is the declared spawn BESIDE the return tile (no ping-pong)"
  end

  def test_the_slab_stays_locked_while_the_fact_is_unmet
    w = world(defeats: 0)
    w.start_in("low_quay")
    w.possessed.walker.teleport(44, 19)
    park_allies_adjacent(w, [44, 19])
    drive(w)
    assert_equal "low_quay", w.zone_name,
                 "at boss_1_defeats=0 the real slab refuses (the mfd refusal, in-suite)"
  end

  def test_the_return_is_free
    w = world(defeats: 0)
    w.start_in("zone_7")
    w.possessed.walker.teleport(1, 14)
    park_allies_adjacent(w, [1, 14])
    drive(w)
    assert_equal "low_quay", w.zone_name,
                 "the return crossing is free — no fact gates the way home"
    assert_equal [43, 19], w.possessed.tile,
                 "the return lands on the ratified spawn beside the quay gate"
  end
end
