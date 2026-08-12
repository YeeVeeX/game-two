require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Fight-ledger integration tests — REAL data, REAL sim, no mocks.
# Helpers mirror corpse_run_test.rb (same staging idiom).
class FightLedgerTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  LEDGER = DATA["balance/ledger"]
  DEATH = DATA["balance/death"]
  QUIET = DATA["balance/ledger"][:ledger_quiet_frames]
  BEAT = DATA["balance/ledger"][:ledger_beat_frames]
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]

  def world = @world ||= Game::World.new(DATA)

  def possess_kit(world, kit_name)
    world.pack.members.length.times do
      return world.possessed if world.possessed.kit_name == kit_name
      world.pack.swap_next!
    end
    flunk "could not possess #{kit_name}"
  end

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    assert_equal "district", world.zone_name
  end

  def nearest_human(world)
    px, py = world.possessed.tile
    world.humans.reject(&:dead?).min_by { |h| [(h.tile[0] - px).abs, (h.tile[1] - py).abs].max }
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  def press_interact(world)
    drive(world, scripted({}), 1) while world.feel.hitstop?
    drive(world, scripted({ world.frame.to_s => ["interact"] }), 1)
    drive(world, scripted({}), 1)
  end

  def isolate_humans(world, count = 2)
    kept = world.humans.first(count)
    world.humans.replace(kept)
    kept.each_with_index do |h, i|
      h.walker.teleport(40, 23 + i)
      h.stagger!(30_000)
    end
    # Clear pending respawns from enter_district combat: A2 stickiness makes
    # humans more flankable → kills can spawn respawns that re-enter mid-test.
    world.instance_variable_get(:@human_respawns).clear
  end

  # Kills BY the possessed trigger hitstop at the NEXT flush — so flush one
  # tick first, THEN drain, or the check runs before hitstop even starts and
  # the frozen frames silently eat the drive budget (D1 lesson, one level
  # deeper).
  def drain_hitstop(world)
    drive(world, scripted({}), 1)
    drive(world, scripted({}), 1) while world.feel.hitstop?
  end

  # Capture :fight_resolved payloads for the whole test.
  def resolved_events(world)
    @resolved ||= [].tap do |list|
      world.bus.subscribe(:fight_resolved) { |e| list << e.payload.dup }
    end
  end

  # enter_district's walk can aggro a rusher into an ally skirmish, leaving
  # a combat window OPEN when a test starts staging. Tests that assert exact
  # spans or counts quiesce first: let the leftover window resolve/dissolve,
  # then forget it.
  def quiesce_ledger(world, events)
    drive(world, scripted({}), QUIET + 2)
    events.clear
  end

  # Open a combat window without hitstop: hurt (never kill) a parked human.
  def poke(world)
    h = world.humans.reject(&:dead?).first
    h.take_hit(damage: 1, attacker: world.possessed)
    drive(world, scripted({}), 1)
  end

  # Kill a drop-carrying human and pick its drop up (opens a window too).
  def stage_pickup(world)
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 1)
    tile = world.drops.first[:tile]
    world.possessed.walker.teleport(*tile)
    drive(world, scripted({}), 1)
    press_interact(world)
  end

  # Carrier dies loaded as an ALLY death (no wipe): pickup, swap off, kill.
  def stage_loaded_death(world)
    stage_pickup(world)
    carrier = world.possessed
    amount = carrier.carried
    assert_operator amount, :>, 0
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    refute_equal carrier, world.possessed
    kill(carrier, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    [carrier, amount]
  end

  # --- data invariants (review M5-design: the interlock is load-bearing) ---

  def test_ledger_balance_invariants
    assert_operator LEDGER[:ledger_quiet_frames], :<, DEATH[:loot_settle_frames],
                    "quiet >= settle silently kills the mid-fight negative beat (spec M5)"
    %i[ledger_quiet_frames ledger_beat_frames].each do |k|
      assert_operator LEDGER[k], :>, 0, "#{k} must be a positive frame count"
    end
  end

  # Presentation-iteration display keys (spec 2026-08-11-ledger-presentation).
  def test_ledger_display_invariants
    display = DATA["display"]
    assert_operator display[:ledger_pop_frames], :>, 0
    assert_operator display[:ledger_pop_frames], :<, LEDGER[:ledger_beat_frames],
                    "pop must finish inside the beat's display budget"
    assert_operator display[:ledger_flash_frames], :>, 0
    assert_operator display[:ledger_flash_frames], :<=, display[:ledger_pop_frames],
                    "flash rides the pop; a flash outliving it reads as a stuck highlight"
    assert_operator display[:ledger_panel_alpha], :>, 0
    assert_operator display[:ledger_panel_alpha], :<=, 255
    assert_operator display[:ledger_flash_alpha], :>, 0
    assert_operator display[:ledger_flash_alpha], :<, 200,
                    "a flash peak near 255 whites out the glyph color identity at age 0"
    assert_operator display[:ledger_block_y], :>, 80,
                    "block must clear the HUD bars (three rows end ~y=76)"
    assert_operator display[:ledger_wipe_y], :>, 294,
                    "wipe recap must sit below THE HUNT ENDS (y=230 + 64pt em box)"
  end

  # --- window lifecycle (Task 2) ---

  def test_window_opens_on_damage_and_resolves_after_quiet
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    quiesce_ledger(world, events)
    poke(world)                          # damage_dealt opens (flush this frame)
    drive(world, scripted({}), QUIET - 30)
    assert_empty events
    kill(world.humans.reject(&:dead?).first, by: world.possessed) # refresh + qualify
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    assert_equal 1, events.length
    e = events.first
    assert_equal "district", e[:zone]
    assert_equal :combat, e[:opened_by]
    assert_equal 1, e[:kills]
    refute e[:wiped]
    assert_equal :fight, world.ledger_beat[:kind]
  end
  # (The kill at QUIET-30 also PROVES refresh: the window outlived its
  # original deadline.)

  def test_kill_without_pickup_prints_honest_zero
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    quiesce_ledger(world, events)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    assert_equal 1, events.length
    assert_equal 1, events.first[:kills]
    assert_equal 0, events.first[:gained], "abandonment prints +0 (spec H3 trade)"
  end

  def test_graze_only_window_dissolves_silently
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    quiesce_ledger(world, events)
    poke(world)                          # damage, but no kill and no loot
    drive(world, scripted({}), QUIET + 2)
    assert_empty events, "a pure graze exchange must dissolve, not print"
    assert_nil world.ledger_beat
  end

  def test_beat_clears_after_beat_frames
    enter_district(world)
    isolate_humans(world)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    refute_nil world.ledger_beat
    drive(world, scripted({}), BEAT + 1)
    assert_nil world.ledger_beat
  end

  def test_span_frames_counts_ticked_frames_not_at_frame
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    quiesce_ledger(world, events)        # en-route skirmish window must not pollute the span
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    e = events.first
    # window opened at the kill's flush; span counts TICKED frames only —
    # the drained hitstop frames advanced @frame but not the span.
    assert_operator e[:span_frames], :>=, QUIET
    assert_operator e[:span_frames], :<=, QUIET + 8
  end

  # --- accrual correctness (Task 3) ---

  def test_pickup_refreshes_an_open_window_and_counts
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    quiesce_ledger(world, events)
    kill(world.humans.reject(&:dead?).first, by: world.possessed) # opens + drop
    drain_hitstop(world)
    drive(world, scripted({}), QUIET - 30)           # near deadline...
    tile = world.drops.first[:tile]
    amount = world.drops.first[:amount]
    world.possessed.walker.teleport(*tile)
    press_interact(world)                            # ...sweep refreshes
    drive(world, scripted({}), QUIET - 30)
    assert_empty events, "pickup must refresh the quiet clock (spec H3)"
    drive(world, scripted({}), 40)
    assert_equal 1, events.length
    assert_equal amount, events.first[:gained], "the sweep is the fight's take"
  end

  def test_pickup_outside_any_window_opens_nothing
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    quiesce_ledger(world, events)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)            # fight resolves, +0
    assert_equal 1, events.length
    tile = world.drops.first[:tile]
    world.possessed.walker.teleport(*tile)
    press_interact(world)                            # ambient glean
    drive(world, scripted({}), QUIET + 2)
    assert_equal 1, events.length, "ambient gleaning must not open a window"
  end

  def test_recovery_opens_a_window_and_marks_the_beat
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world, 2)   # stage_pickup kills one; the carrier needs a killer
    quiesce_ledger(world, events)
    # Quiesce BETWEEN pickup and death: pickup-and-death in one window is
    # the churn case (next test); the clean NEGATIVE fight needs the pickup
    # fight closed first.
    stage_pickup(world)
    quiesce_ledger(world, events)
    carrier = world.possessed
    amount = carrier.carried
    assert_operator amount, :>, 0
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    refute_equal carrier, world.possessed
    kill(carrier, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    # the pickup rusher's respawn wanders into ally aggro and refreshes the
    # window (probe: damage at deadline-28) — drive bounded until it resolves
    120.times do
      break if events.length >= 1
      drive(world, scripted({}), 10)
    end
    assert_equal 1, events.length
    assert_equal amount, events.first[:stranded]
    assert_equal 0, events.first[:gained]
    assert_equal(-amount, events.first[:net], "stranded fight is negative")
    assert_equal amount, world.ledger_beat[:pip_amount]
    # bloodless recovery: skip the settle by mutation (the D1 clock idiom —
    # outwaiting 300f collides with the rusher respawn cycle)
    load = world.corpse_loads.first
    load[:settle_left] = 0
    world.possessed.walker.teleport(*load[:tile])
    press_interact(world)
    # the respawned rusher may wander in and refresh the recovery window —
    # drive bounded until it resolves (deterministic; same script each run)
    120.times do
      break if events.length >= 2
      drive(world, scripted({}), 10)
    end
    assert_equal 2, events.length
    e = events.last
    assert_equal :recovery, e[:opened_by]
    assert_equal amount, e[:gained]
    assert world.ledger_beat[:recovery], "redemption beat carries the pip prefix"
  end

  def test_stranded_then_recovered_same_window_nets_zero
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world, 2)   # stage_pickup kills one; the carrier needs a killer
    quiesce_ledger(world, events)
    _carrier, amount = stage_loaded_death(world)
    load = world.corpse_loads.first
    # loot inside the SAME window: skip the settle by mutation (D1 clock
    # idiom) — the whole kill-pickup-death-loot sequence is one engagement
    load[:settle_left] = 0
    world.possessed.walker.teleport(*load[:tile])
    press_interact(world)                            # loot IN-window
    drive(world, scripted({}), QUIET + 2)
    assert_equal 1, events.length
    e = events.first
    assert_equal amount, e[:stranded]
    assert_operator e[:gained], :>=, amount          # recovery + the pickup
    assert_equal e[:gained] - e[:stranded], e[:net], "churn nets honestly"
  end

  def test_carried_lost_is_zone_filtered_for_the_window_but_not_the_leg
    possess_kit(world, :striker)
    events = resolved_events(world)
    # Make a container IN THE NEST (carrier killed at home by direct hits).
    enter_district(world)
    isolate_humans(world, 2)   # #2 must survive the nest trip for the poke
    stage_pickup(world)
    # stage_pickup teleported the possessed to the isolated human's drop at
    # (40,23) — 40 tiles from the west gate. Teleport gate-adjacent and take
    # the short walk (deterministic staging, not player-plausible movement).
    world.possessed.walker.teleport(2, 13)
    drive(world, scripted({}), 1)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 4 - 1)), STEP * 4)
    assert_equal "nest", world.zone_name
    carrier = world.possessed
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    kill(carrier, by: world.possessed)               # attacker identity irrelevant
    drive(world, scripted({}), 2)
    nest_load = world.corpse_loads("nest").first
    refute_nil nest_load
    # Back to the district. The post-swap possessed may sit OFF row 8 (the
    # only row with the east gate) — teleport onto the gate row first.
    world.possessed.walker.teleport(27, 8)
    drive(world, scripted({}), 1)
    drive(world, scripted(hold(:right, world.frame, world.frame + STEP * 4 - 1)), STEP * 4)
    assert_equal "district", world.zone_name
    world.possessed.walker.teleport(2, 13)
    drive(world, scripted({}), 1)
    events.clear
    poke(world)
    nest_load[:term_left] = 5
    drive(world, scripted({}), 10)                   # expiry fires off-zone
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    e = events.last
    assert_equal 0, e[:destroyed], "off-zone expiry must not enter the window"
  end

  def test_zone_transition_force_resolves_with_the_origin_zone
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    quiesce_ledger(world, events)
    # Stage NEXT TO the gate so the retreat fits inside the quiet window —
    # a 30-tile walk would let the window quiet-resolve mid-walk and the
    # test would pass without exercising the force-resolve at all.
    world.possessed.walker.teleport(3, 13)
    drive(world, scripted({}), 1)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 6 - 1)), STEP * 6)
    assert_equal "nest", world.zone_name
    assert_equal 1, events.length
    assert_equal "district", events.first[:zone], "zone captured at OPEN (review M2)"
  end

  # --- wipe recap + replacement (Task 4) ---

  # Kill every living ally first, then the possessed — all deaths flush in
  # ONE bus process, so the possessed death's corpse_loaded lands in the
  # same flush as pack_wiped (the ordering pin under test).
  def wipe_pack(world)
    (world.pack.living - [world.possessed]).each do |ally|
      kill(ally, by: world.humans.reject(&:dead?).first || world.possessed)
    end
    kill(world.possessed, by: world.humans.reject(&:dead?).first || world.pack.members.first)
    drive(world, scripted({}), 1)
  end

  # Respawn-skirmish-tolerant resolve wait (the Task 3 bounded-drive idiom).
  def drive_until_resolved(world, events, count)
    120.times do
      break if events.length >= count
      drive(world, scripted({}), 10)
    end
    assert_equal count, events.length
  end

  def test_wipe_resolves_immediately_with_field_truth_snapshot
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world, 2)   # stage_pickup kills one; the carrier needs a killer
    quiesce_ledger(world, events)
    _carrier, amount = stage_loaded_death(world)     # container 1 (pre-wipe)
    drive_until_resolved(world, events, 1)           # that fight resolves
    events.clear
    stage_pickup(world)                              # possessed carries again
    carrying = world.possessed.carried
    assert_operator carrying, :>, 0
    wipe_pack(world)                                 # dying possessed strands #2
    e = events.last
    refute_nil e
    assert e[:wiped]
    assert_equal carrying, e[:stranded],
                 "wipe-tick corpse_loaded accrued BEFORE the resolve (ordering pin, spec M6)"
    beat = world.ledger_beat
    assert_equal :wipe, beat[:kind]
    assert_equal amount + carrying, beat[:pip_amount],
                 "recap pip = ALL live containers (field truth, review M4)"
    assert_equal world.total_stranded, beat[:pip_amount]
  end

  def test_wipe_recap_survives_the_veil_frozen
    enter_district(world)
    isolate_humans(world, 1)
    stage_pickup(world)
    wipe_pack(world)
    beat_left_at_wipe = world.ledger_beat[:beat_left]
    drive(world, scripted({}), 40)                   # deep inside the veil
    assert_equal :nest_respawn, world.states.current
    assert_equal beat_left_at_wipe, world.ledger_beat[:beat_left],
                 "beat_left must freeze during nest_respawn (tick_world never runs)"
  end

  def test_dissolve_never_stomps_a_live_beat
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    quiesce_ledger(world, events)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive_until_resolved(world, events, 1)           # beat is live (150f budget)
    live_beat = world.ledger_beat
    refute_nil live_beat
    # Gate-adjacent staging: the whole poke-and-exit must finish well inside
    # the beat's 150-frame display budget or the assert races the clear.
    world.possessed.walker.teleport(2, 13)
    drive(world, scripted({}), 1)
    poke(world)                                      # graze-only window...
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 5 - 1)), STEP * 5)
    assert_equal "nest", world.zone_name             # ...force-resolved: dissolves
    assert_equal 1, events.length
    assert_same live_beat, world.ledger_beat,
                 "a dissolve must never replace a live beat (review M4)"
  end

  # QUIET (180) > BEAT (150), so a quiet resolve can never catch a live
  # beat — only a FORCE resolve (gate, wipe, bank) can exercise the replace
  # rule. Stage the second qualifying fight through the gate.
  def test_qualifying_resolve_replaces_a_live_beat
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world, 2)
    quiesce_ledger(world, events)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive_until_resolved(world, events, 1)
    first_beat = world.ledger_beat
    refute_nil first_beat
    world.possessed.walker.teleport(3, 13)
    drive(world, scripted({}), 1)
    kill(world.humans.reject(&:dead?).first, by: world.possessed) # qualifying window
    drain_hitstop(world)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 6 - 1)), STEP * 6)
    assert_equal "nest", world.zone_name
    assert_equal 2, events.length
    refute_nil world.ledger_beat
    refute_same first_beat, world.ledger_beat,
                "a qualifying force-resolve replaces the live beat (screen budget)"
  end

  def test_quiet_clock_freezes_under_hitstop
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    quiesce_ledger(world, events)
    poke(world)
    # a possessed kill triggers hitstop (feel.on_kill) while also refreshing
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)                 # frozen frames: clock must not move
    drive(world, scripted({}), QUIET - 1)
    assert_empty events, "hitstop frames must not count against the quiet clock"
    drive(world, scripted({}), 3)
    assert_equal 1, events.length
  end

  # --- bank-leg tally (Task 5) ---

  # Walk home through the west gate (gate-adjacent teleport — the Task 3
  # staging lesson: long row walks never reach the gate row), then bank.
  def walk_home_and_bank(world)
    world.possessed.walker.teleport(2, 13)
    drive(world, scripted({}), 1)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 4 - 1)), STEP * 4)
    assert_equal "nest", world.zone_name
    station = world.map.stations.find { |s| s[:type] == "bank" }
    world.possessed.walker.teleport(*station[:at])
    press_interact(world)
  end

  # Back into the district after a bank (nest east gate is on row 8 only).
  def walk_to_district(world)
    world.possessed.walker.teleport(27, 8)
    drive(world, scripted({}), 1)
    drive(world, scripted(hold(:right, world.frame, world.frame + STEP * 4 - 1)), STEP * 4)
    assert_equal "district", world.zone_name
  end

  def test_bank_tally_reconciles_the_leg_and_resets
    possess_kit(world, :striker)
    enter_district(world)
    isolate_humans(world)
    kill(nearest_human(world), by: world.possessed)
    drain_hitstop(world)
    tile = world.drops.first[:tile]
    amount = world.drops.first[:amount]
    world.possessed.walker.teleport(*tile)
    press_interact(world)
    walk_home_and_bank(world)
    beat = world.ledger_beat
    assert_equal :bank, beat[:kind]
    assert_equal amount, beat[:gained], "leg gained = first-acquisition pickups"
    assert_equal 0, beat[:pip_amount]
    assert_equal 0, beat[:dark_amount]
    assert_equal amount, beat[:net]
    # a second immediate bank has nothing to bank (carried is 0), so stage
    # another pickup round-trip and verify the accumulator was RESET
    walk_to_district(world)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    tile2 = world.drops.first[:tile]
    amount2 = world.drops.first[:amount]
    world.possessed.walker.teleport(*tile2)
    press_interact(world)
    walk_home_and_bank(world)
    assert_equal amount2, world.ledger_beat[:gained], "leg reset on bank"
  end

  def test_recovery_does_not_double_count_into_the_leg
    enter_district(world)
    isolate_humans(world, 2)   # stage_pickup kills one; the carrier needs a killer
    _carrier, amount = stage_loaded_death(world)
    load = world.corpse_loads.first
    load[:settle_left] = 0     # skip the settle by mutation (D1 clock idiom)
    world.possessed.walker.teleport(*load[:tile])
    press_interact(world)                            # recovery re-acquires
    walk_home_and_bank(world)
    assert_equal amount, world.ledger_beat[:gained],
                 "corpse_looted must NOT feed leg_gained (first-acquisition convention)"
  end

  def test_bank_tally_shows_outstanding_stranded_excluded_from_net
    enter_district(world)
    isolate_humans(world, 2)                         # TWO kills staged below
    stage_pickup(world)                              # possessed carries A
    kill(world.humans.reject(&:dead?).first, by: world.possessed) # drop B
    drain_hitstop(world)
    b_tile = world.drops.first[:tile]
    b_amount = world.drops.first[:amount]
    carrier = world.possessed
    a_amount = carrier.carried
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    kill(carrier, by: world.possessed)               # A stranded (ally death)
    drive(world, scripted({}), 2)
    world.possessed.walker.teleport(*b_tile)
    press_interact(world)                            # B picked up
    walk_home_and_bank(world)
    beat = world.ledger_beat
    assert_equal :bank, beat[:kind]
    assert_equal a_amount + b_amount, beat[:gained]
    assert_equal a_amount, beat[:pip_amount], "outstanding stranded on the pip line"
    assert_equal a_amount + b_amount, beat[:net], "outstanding EXCLUDED from leg net"
  end
end
