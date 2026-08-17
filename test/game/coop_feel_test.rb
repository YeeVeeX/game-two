require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/state_digest"

# v18 increment 4 — coop feel (spec decisions 11/12 + 7ii; test lane 4)
# against the REAL World, no mocks. Seat scalars live in
# data/balance/coop.json and apply ONLY when a seats-count block exists:
# seats=1 reads no block and executes ZERO scalar arithmetic (the wall's
# byte-identity is the structural proof; these lanes pin the values).
# Third-body caution (flee) sits at the PINNED AiController precedence:
# seizure -> flee -> mark/aggro/target; committed swings FINISH.
class CoopFeelTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  COOP = DATA["balance/coop"][:seats][:"2"]
  KITS = DATA["balance/combat"][:kits]

  Held = Struct.new(:actions) do
    def down?(action) = actions.include?(action)
    def update(_frame) = nil
  end

  def world(seats: 1, seed: 7) = Game::World.new(DATA, seed:, seats:)
  def idle = @idle ||= Core::ScriptedInput.new(frames: {})

  def drive(w, n, inputs: nil)
    n.times { w.tick(inputs || idle) }
  end

  def member(w, kit) = w.pack.members.find { |m| m.kit_name == kit }

  # The uncontrolled third body in a seats=2 world (seats hold 2 of 3).
  def free_ally(w)
    w.pack.members.find { |m| !w.controlled?(m) }
  end

  def flee_threshold(creature)
    (creature.max_hp * COOP[:ally_flee_hp_pct]).floor
  end

  # --- the data contract (knob deletion fails a test, decision 11) --------

  def test_coop_json_pins_the_v18_knob_set
    assert_equal %i[ally_flee_hp_pct human_hp_scale respawn_delay_scale],
                 COOP.keys.sort
    assert_operator COOP[:respawn_delay_scale], :>, 1.0, "walk-back relief scales UP"
    assert_operator COOP[:human_hp_scale], :>, 1.0, "difficulty scales UP"
    assert COOP[:ally_flee_hp_pct].between?(0.0, 1.0)
    assert_nil DATA["balance/coop"][:seats][:"1"],
               "seats=1 must have NO block — decision 7ii hinges on its absence"
  end

  # --- decision 11: human_hp_scale at spawn (Integers, boss included) ------

  def test_seats2_humans_spawn_with_scaled_integer_hp
    w = world(seats: 2)
    w.start_in("low_quay") # rushers + haters + the challenger (BOSS 1)
    humans = w.humans.reject(&:dead?)
    refute_empty humans
    humans.each do |h|
      base = KITS[h.kit_name][:max_hp]
      expected = (base * COOP[:human_hp_scale]).round
      assert_equal expected, h.max_hp, "#{h.name}: spawn-time scale"
      refute_equal base, h.max_hp, "#{h.name}: scale 1.25 must actually bite"
      assert_instance_of Integer, h.max_hp
      assert_equal h.max_hp, h.hp, "spawns at full (scaled) health"
    end
    boss = humans.find { |h| h.kit_name == :challenger }
    refute_nil boss, "the boss spawns through the same add_human path and scales"
  end

  def test_seats1_humans_spawn_with_exact_kit_hp_no_arithmetic
    w = world(seats: 1)
    w.start_in("low_quay")
    w.humans.reject(&:dead?).each do |h|
      assert_equal KITS[h.kit_name][:max_hp], h.max_hp,
                   "#{h.name}: seats=1 is IDENTITY — the block never evaluates"
      assert_instance_of Integer, h.max_hp
    end
  end

  # --- decision 11: respawn_delay_scale at SCHEDULE time -------------------

  def kill_one_rusher(w)
    victim = w.humans.reject(&:dead?).find { |h| h.kit_name == :rusher }
    victim.take_hit(damage: victim.hp, attacker: w.possessed) until victim.dead?
    drive(w, 1, inputs: w.seats.length == 2 ? { 1 => idle, 2 => idle } : idle)
    victim
  end

  def scheduled_delay(w)
    record = w.instance_variable_get(:@human_respawns)[w.zone_name].last
    refute_nil record, "the kill must schedule a respawn"
    record[:at_frame] - (w.frame - 1) # scheduled on the flush tick
  end

  def test_seats2_respawn_delay_scales_rounded_integer
    w = world(seats: 2)
    w.start_in("district")
    kill_one_rusher(w)
    expected = (KITS[:rusher][:respawn_frames] * COOP[:respawn_delay_scale]).round
    assert_equal expected, scheduled_delay(w)
    assert_instance_of Integer, scheduled_delay(w)
    refute_equal KITS[:rusher][:respawn_frames], scheduled_delay(w),
                 "scale 2.0 must actually bite (owner Q3a: the walk-back)"
  end

  def test_seats1_respawn_delay_is_the_exact_kit_value
    w = world(seats: 1)
    w.start_in("district")
    kill_one_rusher(w)
    assert_equal KITS[:rusher][:respawn_frames], scheduled_delay(w),
                 "seats=1: identity, no arithmetic"
  end

  # --- decision 12: third-body caution at the pinned precedence ------------

  # Stage: seats=2, the free ally (the LOBBER — projectile kit) aligned at
  # dist 2 from a live hostile with a clear line — a non-fleeing AI opens a
  # swing THIS tick; controlled bodies far west (the flee anchor direction
  # is unambiguous).
  def flee_stage(hp:)
    w = world(seats: 2)
    w.start_in("district")
    ally = free_ally(w)
    hostile = w.humans.reject(&:dead?).min_by { |h| h.name }
    ally.walker.teleport(hostile.tile[0] + 2, hostile.tile[1])
    w.controlled_bodies.each_with_index do |b, i|
      b.walker.teleport(2, 2 + i)
    end
    ally.load_hp!(hp) if hp
    [w, ally, hostile]
  end

  def two_seat_idle = { 1 => idle, 2 => idle }

  def chebyshev(a, b) = [(a[0] - b[0]).abs, (a[1] - b[1]).abs].max

  def test_low_hp_free_ally_disengages_and_starts_no_attack
    w, ally, hostile = flee_stage(hp: 1)
    before = ally.tile
    anchor = w.controlled_bodies.first
    drive(w, 1, inputs: two_seat_idle)
    assert_equal :idle, ally.attack_state,
                 "hostile in range + line clear, but a fleeing body starts NO new swings"
    assert_operator chebyshev(ally.tile, anchor.tile), :<, chebyshev(before, anchor.tile),
                    "fleeing = move toward the follow anchor"
    refute hostile.dead?
  end

  def test_flee_threshold_is_strict_less_than
    threshold = flee_threshold(free_ally(world(seats: 2)))
    w, ally, = flee_stage(hp: threshold)
    drive(w, 1, inputs: two_seat_idle)
    refute_equal :idle, ally.attack_state,
                 "hp == threshold is NOT fleeing (spec: hp < pct*max) — it fights"
  end

  def test_fleeing_ally_ignores_the_mark
    w, ally, hostile = flee_stage(hp: 1)
    # A controlled seat marks the hostile the fleeing ally is next to.
    marker = w.controlled_bodies.first
    marker.walker.teleport(hostile.tile[0], hostile.tile[1] + 1)
    assert w.set_mark(marker)
    assert_equal hostile, w.marked_target
    drive(w, 1, inputs: two_seat_idle)
    assert_equal :idle, ally.attack_state,
                 "the mark commands the pack — but a fleeing body ignores it"
  end

  def test_seized_ally_does_not_flee_mid_seizure
    w, ally, = flee_stage(hp: 1)
    challenger = Game::Creature.new(bus: w.bus, kit: KITS[:challenger],
                                    kit_name: :challenger,
                                    map: w.instance_variable_get(:@zones)[w.zone_name],
                                    tile: [ally.tile[0] + 3, ally.tile[1]],
                                    faction: :human, name: "seizer")
    ally.seize!(challenger, 100)
    before = ally.tile
    drive(w, 1, inputs: two_seat_idle)
    # Seizure precedence holds: the body answers the SEIZER's voice (walks
    # east toward it), never the flee anchor (far west).
    assert_operator ally.tile[0], :>=, before[0],
                    "seized flesh walks to the voice, never flees home"
  end

  def test_committed_swing_finishes_then_no_new_swings_start
    w, ally, = flee_stage(hp: nil) # full hp: stages the swing
    drive(w, 1, inputs: two_seat_idle)
    refute_equal :idle, ally.attack_state, "staging: full-hp ally opened a swing"
    ally.load_hp!(1) # the wound lands MID-SWING
    drive(w, 1, inputs: two_seat_idle)
    refute_equal :idle, ally.attack_state,
                 "flee never interrupts an executing action — it resolves body-owned"
    atk = ally.kit[:attack]
    swing = atk[:windup_frames] + atk[:active_frames] + atk[:recovery_frames] + 4
    drive(w, swing, inputs: two_seat_idle)
    assert_equal :idle, ally.attack_state, "the committed swing ended on its own clock"
    drive(w, 3, inputs: two_seat_idle)
    assert_equal :idle, ally.attack_state, "still bloodied: no NEW swing ever starts"
  end

  def test_seats1_low_hp_ally_never_flees
    w = world(seats: 1)
    w.start_in("district")
    ally = w.pack.members.find { |m| !w.controlled?(m) && m.kit_name == :lobber }
    hostile = w.humans.reject(&:dead?).min_by { |h| h.name }
    ally.walker.teleport(hostile.tile[0] + 2, hostile.tile[1])
    ally.load_hp!(1)
    drive(w, 1)
    refute_equal :idle, ally.attack_state,
                 "seats=1: the guard never evaluates — the wounded ally fights"
  end

  # --- lane 4's two-sim identity with the block ACTIVE ---------------------

  def test_two_seats2_sims_stay_digest_identical_with_the_coop_block
    w1 = world(seats: 2, seed: 99)
    w2 = world(seats: 2, seed: 99)
    ins = { 1 => Held.new(["right"]), 2 => Held.new(["attack"]) }
    120.times do
      w1.tick(ins)
      w2.tick(ins)
    end
    assert_equal Net::StateDigest.canonical(w1.digest_snapshot),
                 Net::StateDigest.canonical(w2.digest_snapshot),
                 "coop scalars are deterministic — same seed, same bytes"
  end
end
