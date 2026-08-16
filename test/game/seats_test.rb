require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v17 increment 2 — the seat map (spec Sim spec + decisions 2/3/11) against
# the REAL World, no mocks. Two seats share one pack: seat-ordered
# arbitration, partner exclusion, waiting-for-body, judgment assignment,
# gate co-location consent, seizure targeting, per-seat cameras. The
# single-seat wall is guarded separately (canaries + full-wall rake canary).
class SeatsTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]
  SEIZE = DATA["balance/combat"][:kits][:challenger][:seize]

  # A real input source holding a fixed action set (the ScriptedInput
  # duck-type — the input abstraction IS the lockstep seam).
  Held = Struct.new(:actions) do
    def down?(action) = actions.include?(action)
    def update(_frame) = nil
  end

  def world2 = Game::World.new(DATA, seed: 7, seats: 2)
  def idle = @idle ||= Core::ScriptedInput.new(frames: {})
  def held(*actions) = Held.new(actions)

  def drive(w, inputs, n)
    n.times { w.tick(inputs) }
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  def collect(w, event)
    seen = []
    w.bus.subscribe(event) { |e| seen << e }
    seen
  end

  # --- construction ------------------------------------------------------

  def test_two_seats_hold_distinct_bodies_seat1_keeps_the_initial_kit
    w = world2
    assert_equal [1, 2], w.seats
    assert_equal :blocker, w.possessed(1).kit_name # balance initial_possessed
    assert_equal :striker, w.possessed(2).kit_name # first free body, roster order
    refute w.possessed(1).equal?(w.possessed(2))
    assert_equal [w.possessed(1), w.possessed(2)], w.controlled_bodies
    assert_equal 1, w.seat_for(w.possessed(1))
    assert_equal 2, w.seat_for(w.possessed(2))
    refute w.controlled?(w.pack.members.find { |m| m.kit_name == :lobber })
  end

  # --- per-seat input ----------------------------------------------------

  def test_seat_2_input_drives_seat_2s_body_only
    w = world2
    b1 = w.possessed(1)
    b2 = w.possessed(2)
    b2.walker.teleport(20, 8) # open nest corridor, clear of the pack
    from1 = b1.tile
    from2 = b2.tile
    drive(w, { 1 => idle, 2 => held(:right) }, b2.kit[:step_frames] * 2)
    assert_operator w.possessed(2).tile[0], :>, from2[0], "seat 2's hold moved seat 2's body"
    assert_equal from1, w.possessed(1).tile, "seat 1 held nothing and did not move"
  end

  def test_missing_seat_entry_reads_as_null_input
    w = world2
    from = w.possessed(2).tile
    drive(w, { 1 => idle }, 30)
    assert_equal from, w.possessed(2).tile
  end

  # --- swap arbitration (decision 3) --------------------------------------

  def test_voluntary_swap_skips_the_partners_body
    w = world2
    w.tick({ 1 => held(:swap), 2 => idle })
    assert_equal :lobber, w.possessed(1).kit_name,
                 "blocker's Tab skips striker (seat 2's) and lands on lobber"
  end

  def test_same_tick_swaps_resolve_in_seat_order
    w = world2
    w.tick({ 1 => held(:swap), 2 => held(:swap) })
    assert_equal :lobber, w.possessed(1).kit_name, "seat 1 resolved first"
    assert_equal :blocker, w.possessed(2).kit_name,
                 "seat 2's rotation sees seat 1's OLD body freed in the same tick"
  end

  def test_forced_swap_excludes_the_partner_even_when_nearer
    w = world2
    b1 = w.possessed(1)
    b2 = w.possessed(2)
    lobber = w.pack.members.find { |m| m.kit_name == :lobber }
    b2.walker.teleport(b1.tile[0] + 1, b1.tile[1]) # partner adjacent (nearest)
    lobber.walker.teleport(20, 13)                 # free body far away
    swaps = collect(w, :possession_changed)
    kill(b1, by: w.humans.first || b2)
    w.tick({ 1 => idle, 2 => idle })
    assert_equal lobber, w.possessed(1), "snap skips the partner's nearer body"
    forced = swaps.find { |e| e[:forced] }
    assert_equal lobber, forced[:to]
  end

  # --- waiting-for-body (decision 3) ---------------------------------------

  def waiting_world
    w = world2
    lobber = w.pack.members.find { |m| m.kit_name == :lobber }
    kill(lobber, by: w.possessed(2))
    w.tick({ 1 => idle, 2 => idle })
    kill(w.possessed(1), by: w.possessed(2))
    w.tick({ 1 => idle, 2 => idle })
    w
  end

  def test_seat_waits_when_partner_holds_the_last_living_body
    w = waiting_world
    wipes = collect(w, :pack_wiped)
    assert_nil w.possessed(1), "no free body: seat 1 waits"
    assert_equal :striker, w.possessed(2).kit_name
    assert_empty wipes, "a waiting seat is not a wipe"
    assert_equal :world, w.states.current
    assert_equal [w.possessed(2)], w.controlled_bodies
  end

  def test_waiting_seat_inputs_are_ignored_and_camera_spectates_the_partner
    w = waiting_world
    drive(w, { 1 => held(:right, :attack, :swap), 2 => held(:left) }, 30)
    assert_nil w.possessed(1), "held keys on a waiting seat drive nothing"
    assert_in_delta w.camera(2).x, w.camera(1).x, 0.001, "spectate: camera follows the partner"
    assert_in_delta w.camera(2).y, w.camera(1).y, 0.001
  end

  def test_waiting_seat_auto_repossesses_at_vat_regrow_in_roster_order
    w = waiting_world
    w.pack.bank!(ECO[:regrow_cost] * 2 + ECO[:heal_cost_per_body] * 3)
    b2 = w.possessed(2)
    b2.walker.teleport(14, 10) # nest vat
    changes = collect(w, :possession_changed)
    assert w.interact(b2)
    w.tick({ 1 => idle, 2 => idle })
    assert_equal :blocker, w.possessed(1).kit_name,
                 "first revived uncontrolled body in roster order (striker is held)"
    repossess = changes.find { |e| e[:from].nil? }
    assert repossess, "repossession announces itself (from: nil, forced)"
    assert repossess[:forced]
  end

  # --- wipe + judgment (decisions 3/6-fold) --------------------------------

  def test_both_seats_dying_in_one_flush_emits_pack_wiped_exactly_once
    w = world2
    wipes = collect(w, :pack_wiped)
    killer = w.possessed(2)
    kill(w.pack.members.find { |m| m.kit_name == :lobber }, by: killer)
    kill(w.possessed(1), by: killer)
    kill(killer, by: killer)
    w.tick({ 1 => idle, 2 => idle }) # ONE bus flush resolves every death
    assert_equal 1, wipes.length
    assert_equal :nest_respawn, w.states.current
  end

  def test_judgment_floor_gives_seat_1_the_vessel_and_seat_2_waits
    w = world2
    wait_frames = DATA["balance/combat"][:respawn_frames]
    killer = w.possessed(2)
    kill(w.pack.members.find { |m| m.kit_name == :lobber }, by: killer)
    kill(w.possessed(1), by: killer)
    kill(killer, by: killer)
    drive(w, { 1 => idle, 2 => idle }, wait_frames + 20)
    assert_equal :world, w.states.current
    refute_nil w.possessed(1)
    refute w.possessed(1).dead?, "the one-vessel floor revived seat 1's body"
    assert_nil w.possessed(2), "seat 2 waits until regrow/next judgment (spec decision 3)"
  end

  # --- zone gates (decision 11, Kimi fold) ---------------------------------

  def test_gate_waits_for_the_partner_then_fires_when_co_located
    w = world2
    w.possessed(2).walker.teleport(20, 13) # far from the gate
    w.possessed(1).walker.teleport(29, 8)  # nest -> district gate tile
    w.tick({ 1 => idle, 2 => idle })
    assert_equal "nest", w.zone_name, "gate holds: partner not in the gate group"
    w.possessed(2).walker.teleport(28, 8)  # adjacent = the gate group
    w.tick({ 1 => idle, 2 => idle })
    assert_equal "district", w.zone_name, "co-location = consent; the gate fires"
  end

  def test_waiting_seat_does_not_block_the_gate
    w = waiting_world
    drive(w, { 1 => idle, 2 => idle }, 12) # drain the kill hitstop first
    w.possessed(2).walker.teleport(29, 8)
    w.tick({ 1 => idle, 2 => idle })
    assert_equal "district", w.zone_name
  end

  # --- decision 11: verbs, feel, seizure -----------------------------------

  def test_seat_2s_body_can_interact_and_uncontrolled_bodies_cannot
    w = world2
    b2 = w.possessed(2)
    lobber = w.pack.members.find { |m| m.kit_name == :lobber }
    b2.pick_up(5)
    lobber.pick_up(5)
    b2.walker.teleport(12, 8) # nest bank
    lobber.walker.teleport(12, 8)
    refute w.interact(lobber), "an AI body is nobody's hands"
    assert w.interact(b2)
    assert_equal 5, w.pack.banked
  end

  def test_seat_2s_hits_drive_the_shared_hitstop
    w = world2
    w.start_in("district")
    b2 = w.possessed(2)
    h = w.humans.reject(&:dead?).first
    h.stagger!(120) # pinned: staggered bodies cannot step off the front tile
    b2.walker.teleport(h.tile[0] - 1, h.tile[1])
    b2.face([1, 0])
    refute w.feel.hitstop?
    b2.start_attack
    drive(w, { 1 => idle, 2 => idle }, b2.kit[:attack][:windup_frames] + 2)
    assert w.feel.hitstop?, "hitstop is global sim state — both seats' hits pause both machines"
  end

  def test_mark_is_shared_last_write_wins
    w = world2
    w.start_in("district")
    b1 = w.possessed(1)
    b2 = w.possessed(2)
    h1, h2 = w.humans.reject(&:dead?).first(2)
    b1.walker.teleport(h1.tile[0] + 1, h1.tile[1])
    b2.walker.teleport(h2.tile[0] + 1, h2.tile[1])
    assert w.set_mark(b1)
    assert_equal h1, w.marked_target
    assert w.set_mark(b2)
    assert_equal h2, w.marked_target, "one pack mark, last write wins (decision 4)"
    refute w.set_mark(w.pack.members.find { |m| m.kit_name == :lobber })
  end

  def test_seizure_targets_the_nearest_controlled_body
    w = world2
    w.start_in("low_quay")
    boss = w.humans.find { |h| h.kit[:seize] }
    w.humans.reject { |h| h.equal?(boss) || h.dead? }.each { |h| kill(h, by: boss) }
    b2 = w.possessed(2)
    boss.walker.teleport(10, 4)
    b2.walker.teleport(12, 4)                 # inside seize range
    w.possessed(1).walker.teleport(2, 4)      # seat 1 far outside
    w.pack.members.find { |m| m.kit_name == :lobber }.walker.teleport(2, 5)
    chants = collect(w, :challenger_chant_started)
    drive(w, { 1 => idle, 2 => idle }, 30)
    refute_empty chants, "the boss chants at the nearest controlled body"
    assert_equal b2, chants.first[:body], "seat 2's body is nearest — it gets named"
  end
end
