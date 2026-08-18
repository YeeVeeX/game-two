require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/telemetry"

# v18 increment 5 — the sustain verb (spec decisions 9/15; test lane 5),
# headless against the REAL World, no mocks. Owner law 2026-08-11: priced,
# portable, banked-funded — never a free cooldown. All numbers live in
# data/balance/economy.json (Rule 3). The verb is EDGE-TRIGGERED and rides
# the swap-rearm law (Codex #16); a same-tick two-seat race resolves by the
# first-success-per-tick latch in seat order (decision 9 — deterministic on
# both machines). Refusals (at_cap/broke/none/no_effect/seat_race) cue and
# spend NOTHING — never a silent eat, a charge can never burn for nothing.
class SustainTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]
  KITS = DATA["balance/combat"][:kits]
  BANK = DATA["zones/nest"][:stations].find { |s| s[:type] == "bank" }[:at]

  Held = Struct.new(:actions) do
    def down?(action) = actions.include?(action)
    def update(_frame) = nil
  end

  def world(seats: 1, seed: 7) = Game::World.new(DATA, seed:, seats:)
  def idle = @idle ||= Held.new([])
  def hold(*actions) = Held.new(actions)
  def member(w, kit) = w.pack.members.find { |m| m.kit_name == kit }

  def drive(w, n, inputs: idle)
    n.times { w.tick(inputs) }
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  # Staging through the PUBLIC verb (the rich_world w.interact precedent):
  # stand on the bank, buy n, tick between presses (the per-tick latch),
  # walk back. Never load_provisions! — that seam is save-apply only.
  def stage_provisions!(w, n)
    home = w.possessed.tile
    w.possessed.walker.teleport(*BANK)
    n.times do
      raise "staging: buy refused" unless w.sustain(w.possessed)
      drive(w, 1)
    end
    w.possessed.walker.teleport(*home)
  end

  def refusals_of(w)
    events = []
    w.bus.subscribe(:provision_refused) { |e| events << e }
    events
  end

  # --- the edge trigger (Codex #16) ----------------------------------------

  def test_a_held_key_buys_exactly_once_and_rebuys_after_release
    w = world
    w.pack.bank!(50)
    w.possessed.walker.teleport(*BANK)
    drive(w, 6, inputs: hold(:sustain))
    assert_equal 1, w.pack.provisions, "edge-triggered: a held key buys ONCE"
    assert_equal 50 - ECO[:provision_cost], w.pack.banked
    assert_equal :provision_bought, w.station_cue[:kind], "the buy cues"
    drive(w, 2) # release once
    drive(w, 3, inputs: hold(:sustain))
    assert_equal 2, w.pack.provisions, "release-then-press buys again"
  end

  def test_a_held_key_uses_exactly_once_heals_clamped_dead_untouched
    w = world
    w.pack.bank!(50)
    stage_provisions!(w, 2)
    assert_equal 50 - 2 * ECO[:provision_cost], w.pack.banked,
                 "buy x2 drains banked by cost x2 through spend! (never-taxed law)"
    striker = member(w, :striker)
    blocker = member(w, :blocker)
    lobber  = member(w, :lobber)
    striker.load_hp!(striker.max_hp - ECO[:provision_heal] - 20)
    blocker.load_hp!(blocker.max_hp - 10)
    kill(lobber, by: striker)
    drive(w, 2) # flush the death
    w.possessed.walker.teleport(5, 5) # plain ground, no station
    drive(w, 4, inputs: hold(:sustain))
    assert_equal 1, w.pack.provisions, "edge-triggered: a held key uses ONCE"
    assert_equal striker.max_hp - 20, striker.hp, "provision_heal landed whole"
    assert_equal blocker.max_hp, blocker.hp, "heal clamps at max_hp"
    assert lobber.dead?, "dead untouched — the vat keeps its regrowth monopoly"
    assert_equal :provision_used, w.station_cue[:kind], "the use cues"
  end

  # --- the swap-rearm law (Codex #16) --------------------------------------

  def test_sustain_held_across_tab_is_masked_until_released_once
    w = world
    w.pack.bank!(50)
    w.possessed.walker.teleport(*BANK)
    drive(w, 2, inputs: hold(:sustain)) # one edge buy
    assert_equal 1, w.pack.provisions
    member(w, :blocker).load_hp!(10) # a ghost USE on the new body would show
    drive(w, 1, inputs: hold(:sustain, :swap)) # Tab while the key is held
    refute_equal :striker, w.possessed.kit_name, "staging: the swap landed"
    drive(w, 5, inputs: hold(:sustain))
    assert_equal 1, w.pack.provisions,
                 "a key held across Tab is masked — no ghost buy or use"
    assert_equal 10, member(w, :blocker).hp
    drive(w, 1) # release once
    drive(w, 2, inputs: hold(:sustain))
    assert_equal 0, w.pack.provisions, "released-then-pressed fires on the new body"
  end

  # --- the refusal guards (cue + spend NOTHING) -----------------------------

  def test_buy_at_cap_refuses_and_spends_nothing
    w = world
    w.pack.bank!(50)
    stage_provisions!(w, ECO[:provision_cap])
    refused = refusals_of(w)
    banked_before = w.pack.banked
    w.possessed.walker.teleport(*BANK)
    drive(w, 2, inputs: hold(:sustain))
    assert_equal ECO[:provision_cap], w.pack.provisions
    assert_equal banked_before, w.pack.banked, "a refusal never spends"
    assert_equal [:at_cap], refused.map { |e| e[:reason] }
    assert_equal :refused, w.station_cue[:kind], "never a silent eat"
  end

  def test_buy_broke_refuses_and_spends_nothing
    w = world
    w.pack.bank!(ECO[:provision_cost] - 1)
    refused = refusals_of(w)
    w.possessed.walker.teleport(*BANK)
    drive(w, 2, inputs: hold(:sustain))
    assert_equal 0, w.pack.provisions
    assert_equal ECO[:provision_cost] - 1, w.pack.banked
    assert_equal [:broke], refused.map { |e| e[:reason] }
  end

  def test_use_with_zero_charges_refuses
    w = world
    member(w, :blocker).load_hp!(10) # wounded: :none must win over :no_effect
    refused = refusals_of(w)
    w.possessed.walker.teleport(5, 5)
    drive(w, 2, inputs: hold(:sustain))
    assert_equal [:none], refused.map { |e| e[:reason] }
    assert_equal :refused, w.station_cue[:kind]
  end

  def test_use_with_every_living_member_at_full_hp_refuses_and_keeps_the_charge
    w = world
    w.pack.bank!(50)
    stage_provisions!(w, 1)
    refused = refusals_of(w)
    w.possessed.walker.teleport(5, 5)
    drive(w, 2, inputs: hold(:sustain))
    assert_equal 1, w.pack.provisions, "a charge can never burn for nothing"
    assert_equal [:no_effect], refused.map { |e| e[:reason] }
  end

  # --- the same-tick seat race (decision 9's latch) -------------------------

  def test_same_tick_race_seat_one_wins_seat_two_refuses_that_tick
    w = world(seats: 2)
    w.pack.bank!(50)
    stage_provisions!(w, 1)
    third = w.pack.members.find { |m| !w.controlled?(m) }
    third.load_hp!(third.max_hp - 10) # seat 2's use WOULD be effective
    w.possessed(1).walker.teleport(*BANK)
    w.possessed(2).walker.teleport(5, 5)
    refused = refusals_of(w)
    w.tick({ 1 => hold(:sustain), 2 => hold(:sustain) })
    assert_equal 2, w.pack.provisions, "seat 1's BUY won the tick"
    assert_equal third.max_hp - 10, third.hp, "seat 2's USE never fired"
    assert_equal [:seat_race], refused.map { |e| e[:reason] }
    # The complementary tick proves the refusal was the RACE, not a guard:
    drive(w, 2) # both seats release
    w.tick({ 1 => idle, 2 => hold(:sustain) })
    assert_equal 1, w.pack.provisions, "alone, seat 2's press succeeds"
    assert_equal third.max_hp, third.hp
  end

  # --- seizure x sustain (recorded micro-decision: hands-verb) --------------

  # The seizure branch suppresses the FEET and keeps the hands (interact
  # precedent) — sustain is a hands-verb, so a seized body may still buy
  # or use. Smallest faithful reading of the v15 seizure law; recorded in
  # the checkpoint.
  def test_a_seized_body_may_still_fire_sustain
    w = world
    w.pack.bank!(50)
    stage_provisions!(w, 1)
    blocker = member(w, :blocker)
    blocker.load_hp!(blocker.max_hp - 10)
    w.possessed.walker.teleport(5, 5)
    seizer = Game::Creature.new(bus: w.bus, kit: KITS[:challenger],
                                kit_name: :challenger, map: w.map,
                                tile: [6, 5], faction: :human, name: "seizer")
    w.possessed.seize!(seizer, 100) # adjacent seizer: seized_step is a no-op
    drive(w, 2, inputs: hold(:sustain))
    assert_equal 0, w.pack.provisions,
                 "seizure suppresses the feet, never the hands (interact precedent)"
    assert_equal blocker.max_hp, blocker.hp
  end

  # --- telemetry (the SEVENTEENTH's sustain-routing arbiter) ----------------

  def test_telemetry_sustain_line_counts_bought_used_refused
    w = world
    t = Game::Telemetry.new(w.bus, world: w)
    w.pack.bank!(50)
    stage_provisions!(w, 2) # bought=2
    member(w, :blocker).load_hp!(10)
    w.possessed.walker.teleport(5, 5)
    drive(w, 2, inputs: hold(:sustain)) # used=1
    w.pack.living.each(&:heal_full!)
    drive(w, 2)
    drive(w, 2, inputs: hold(:sustain)) # refused=1 (:no_effect)
    assert_match(/TELEMETRY sustain bought=2 used=1 refused=1/, t.summary)
  end
end
