require_relative "../test_helper"
require "core/data_store"
require "net/lockstep"
require "net/state_digest"

# v17 increment 4 — the pure scheduler's laws (spec fork 2 + decisions
# 1/2/8): the delay window, once-per-executed-tick submission, the
# duplicate-slot fault, ready/stall + wall-ms warn/abort verdicts,
# boundary retention bounds, and the desync compare machine under late
# and bursty delivery schedules. Pure class — no sockets, no clocks.
class LockstepTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["netplay"]

  def lockstep(seat: 1, delay: 4, every: 10, rtt_ticks: 0,
               warn: CFG[:stall_warn_ms], abort: CFG[:abort_stall_ms])
    Net::Lockstep.new(local_seat: seat, delay:, digest_every: every,
                      stall_warn_ms: warn, abort_stall_ms: abort, rtt_ticks:)
  end

  def window(tick, md5)
    Net::StateDigest::Window.new(tick:, md5:, snapshot: [["world", [["frame", tick]]]],
                                 lines: ["EVENT test frame=#{tick}"])
  end

  # Drive one executed tick: sample -> submit -> advance (the pinned order).
  def step(ls, mask = 0)
    ls.submit_local(mask)
    ls.advance!
  end

  # --- Rule 3: the tunables live in data/netplay.json ---------------------

  def test_netplay_config_pins
    assert_equal 43117, CFG[:port]
    assert_equal({ min: 4, max: 12, default: 8, jitter_margin_ticks: 3 }, CFG[:delay])
    assert_equal 60, CFG[:digest_every]
    assert_equal 500, CFG[:stall_warn_ms]
    assert_equal 10_000, CFG[:abort_stall_ms]
    assert_equal 2_000, CFG[:drain_timeout_ms]
    assert_equal 5, CFG[:probe_count]
  end

  # --- delay window --------------------------------------------------------

  def test_first_delay_ticks_execute_on_empty_masks_without_peer_traffic
    ls = lockstep(delay: 4)
    4.times do |t|
      assert ls.ready?, "tick #{t} < D consumes by-definition empties"
      assert_equal({ 1 => 0, 2 => 0 }, step(ls, t + 100))
    end
    assert_equal 4, ls.tick
    refute ls.ready?, "tick D gates on the remote slot"
    ls.receive_remote(4, 9)
    assert ls.ready?
    masks = step(ls, 500)
    assert_equal({ 1 => 100, 2 => 9 }, masks,
                 "slot D carries the mask submitted while executing tick 0")
  end

  def test_consumed_masks_come_back_in_pinned_seat_order_for_seat_2
    ls = lockstep(seat: 2, delay: 4)
    4.times { step(ls, 3) }   # ticks 0..3 on empties; local submits slots 4..7
    ls.receive_remote(4, 7)   # seat 1 is the remote on this machine
    masks = step(ls, 3)
    assert_equal({ 1 => 7, 2 => 3 }, masks,
                 "seat 1 = remote mask, seat 2 = the mask submitted while executing tick 0")
    assert_equal [1, 2], masks.keys, "seat order is pinned, not local-first"
  end

  # --- sampling law (decision 1) -------------------------------------------

  def test_submit_returns_the_scheduled_slot_and_is_once_per_executed_tick
    ls = lockstep(delay: 4)
    assert_equal 4, ls.submit_local(1), "executing tick 0 schedules slot D"
    err = assert_raises(RuntimeError) { ls.submit_local(2) }
    assert_match(/sampling law/, err.message)
    ls.advance!
    assert_equal 5, ls.submit_local(1)
  end

  def test_advance_before_submit_raises_the_sampling_law
    ls = lockstep(delay: 4)
    err = assert_raises(RuntimeError) { ls.advance! }
    assert_match(/sample -> submit -> advance/, err.message)
  end

  def test_advance_without_ready_raises
    ls = lockstep(delay: 2)
    2.times { step(ls) }
    err = assert_raises(RuntimeError) { ls.advance! }
    assert_match(/without ready/, err.message)
  end

  def test_submit_on_a_stalled_tick_raises_the_no_sampling_law
    ls = lockstep(delay: 2)
    2.times { step(ls) }
    refute ls.ready?
    err = assert_raises(RuntimeError) { ls.submit_local(0) }
    assert_match(/samples NOTHING/, err.message)
  end

  # --- duplicate-slot law ----------------------------------------------------

  def test_duplicate_remote_slot_identical_is_idempotent_differing_is_a_fault
    ls = lockstep(delay: 4)
    ls.receive_remote(4, 9)
    ls.receive_remote(4, 9) # idempotent
    err = assert_raises(Net::Protocol::Fault) { ls.receive_remote(4, 8) }
    assert_match(/duplicate INPUT slot 4/, err.message)
  end

  def test_pre_delay_slots_are_empty_by_definition
    ls = lockstep(delay: 4)
    ls.receive_remote(2, 0) # agrees with the definition: idempotent
    assert_raises(Net::Protocol::Fault) { ls.receive_remote(2, 5) }
  end

  def test_late_duplicate_for_a_consumed_slot_is_still_checked
    ls = lockstep(delay: 2)
    ls.receive_remote(2, 6)
    3.times { step(ls) }
    assert_equal 3, ls.tick, "slot 2 was consumed"
    ls.receive_remote(2, 6) # identical late duplicate: fine
    assert_raises(Net::Protocol::Fault) { ls.receive_remote(2, 7) }
  end

  # --- stall accounting (wall ms fed by the caller) --------------------------

  def test_stall_runs_count_and_warn_abort_thresholds_come_from_data
    ls = lockstep(delay: 2)
    2.times { step(ls) } # tick 2 now gates on the peer
    refute ls.ready?

    v = ls.record_stall(1000)
    assert_equal 0, v.elapsed_ms, "a run is measured from its first stalled update"
    refute v.warn?
    v = ls.record_stall(1400)
    assert_equal 400, v.elapsed_ms
    refute v.warn?, "below stall_warn_ms"
    v = ls.record_stall(1000 + CFG[:stall_warn_ms])
    assert v.warn?
    refute v.abort?
    assert_equal 3, ls.stall_updates
    assert_equal 3, ls.stall_run
    assert_equal 3, ls.stall_run_max
    assert_equal CFG[:stall_warn_ms], ls.stall_ms_max

    ls.receive_remote(2, 0)
    step(ls)
    assert_equal 0, ls.stall_run, "an advance ends the run"
    assert_equal 3, ls.stall_run_max

    v = ls.record_stall(20_000)
    assert_equal 0, v.elapsed_ms, "new run, new start"
    v = ls.record_stall(20_000 + CFG[:abort_stall_ms])
    assert v.abort?, "continuous stall past abort_stall_ms"
    assert_equal 5, ls.stall_updates
    assert_equal 2, ls.stall_run
    assert_equal 3, ls.stall_run_max
    assert_equal CFG[:abort_stall_ms], ls.stall_ms_max
  end

  # --- boundary retention (decision 8) ---------------------------------------

  def test_retention_bound_formula_and_local_overflow_faults
    ls = lockstep(delay: 4, every: 10, rtt_ticks: 0) # ceil(4/10)+1 = 2
    assert_nil ls.record_boundary(window(10, "aa"))
    assert_nil ls.record_boundary(window(20, "bb"))
    err = assert_raises(Net::Protocol::Fault) { ls.record_boundary(window(30, "cc")) }
    assert_match(/retention exceeded/, err.message)
  end

  def test_pending_peer_digests_are_bounded_too
    ls = lockstep(delay: 4, every: 10)
    ls.receive_digest(10, "aa")
    ls.receive_digest(20, "bb")
    assert_raises(Net::Protocol::Fault) { ls.receive_digest(30, "cc") }
  end

  def test_matched_pairs_release_retained_windows
    ls = lockstep(delay: 4, every: 10)
    ls.record_boundary(window(10, "aa"))
    ls.record_boundary(window(20, "bb"))
    assert_nil ls.receive_digest(10, "aa")
    assert_nil ls.receive_digest(20, "bb")
    assert_equal 2, ls.boundaries_compared
    # Released: two more retained boundaries fit under the bound again.
    ls.record_boundary(window(30, "cc"))
    assert_nil ls.record_boundary(window(40, "dd"))
  end

  def test_duplicate_local_boundary_is_a_programming_error
    ls = lockstep(delay: 4, every: 10)
    ls.record_boundary(window(10, "aa"))
    assert_raises(RuntimeError) { ls.record_boundary(window(10, "aa")) }
  end

  # --- desync compare machine (late/bursty schedules) -------------------------

  def test_bursty_peer_digests_arriving_before_local_boundaries_compare_in_order
    ls = lockstep(delay: 4, every: 10)
    ls.receive_digest(10, "aa")
    ls.receive_digest(20, "bb")
    assert_nil ls.record_boundary(window(10, "aa"))
    assert_nil ls.record_boundary(window(20, "bb"))
    assert_equal 2, ls.boundaries_compared
    refute ls.desynced?
  end

  def test_late_peer_digest_burst_drains_retained_windows
    ls = lockstep(delay: 4, every: 10)
    ls.record_boundary(window(10, "aa"))
    ls.record_boundary(window(20, "bb"))
    assert_equal 0, ls.boundaries_compared
    assert_nil ls.receive_digest(10, "aa")
    assert_nil ls.receive_digest(20, "bb")
    assert_equal 2, ls.boundaries_compared
  end

  def test_mismatch_latches_the_machine_and_halts_tick_admission
    ls = lockstep(delay: 2, every: 10)
    2.times { step(ls) }
    ls.receive_remote(2, 0)
    ls.record_boundary(window(10, "aa"))
    verdict = ls.receive_digest(10, "zz")
    assert_instance_of Net::Lockstep::Desync, verdict
    assert_equal 10, verdict.tick
    assert_equal "aa", verdict.local_md5
    assert_equal "zz", verdict.peer_md5
    assert_equal "aa", verdict.record.md5, "the retained window rides the verdict (artifact source)"
    assert ls.desynced?
    assert_equal 1, ls.desyncs
    refute ls.ready?, "tick admission halts even though slot 2 is present"
    assert_raises(RuntimeError) { ls.advance! }
    assert_raises(RuntimeError) { ls.submit_local(0) }
    # Drain traffic after the latch is ignored, never faulted.
    assert_nil ls.receive_digest(20, "whatever")
    assert_nil ls.record_boundary(window(20, "xx"))
    ls.receive_remote(2, 9) # would be a differing duplicate mid-run
    assert_equal 1, ls.desyncs
  end

  def test_mismatch_detects_when_the_peer_digest_arrived_first
    ls = lockstep(delay: 4, every: 10)
    ls.receive_digest(10, "zz")
    verdict = ls.record_boundary(window(10, "aa"))
    assert_instance_of Net::Lockstep::Desync, verdict
    assert_equal 10, verdict.tick
  end

  def test_non_boundary_digest_tick_is_a_protocol_fault
    ls = lockstep(delay: 4, every: 10)
    assert_raises(Net::Protocol::Fault) { ls.receive_digest(7, "aa") }
    assert_raises(Net::Protocol::Fault) { ls.receive_digest(0, "aa") }
  end

  def test_duplicate_digest_for_a_compared_boundary_follows_the_duplicate_law
    ls = lockstep(delay: 4, every: 10)
    ls.record_boundary(window(10, "aa"))
    ls.receive_digest(10, "aa")
    assert_nil ls.receive_digest(10, "aa"), "identical late duplicate is idempotent"
    assert_raises(Net::Protocol::Fault) { ls.receive_digest(10, "zz") }
  end

  def test_latch_desync_records_the_peer_declared_halt
    ls = lockstep(delay: 4, every: 10)
    ls.record_boundary(window(10, "aa"))
    verdict = ls.latch_desync!(10)
    assert ls.desynced?
    assert_equal 10, verdict.tick
    assert_equal "aa", verdict.local_md5
    assert_nil verdict.peer_md5
    assert_equal 1, ls.desyncs
    assert_same verdict, ls.latch_desync!(10), "idempotent: one latch per session"
    assert_equal 1, ls.desyncs
  end

  def test_latch_desync_for_an_unreached_boundary_holds_what_we_have
    ls = lockstep(delay: 4, every: 10)
    verdict = ls.latch_desync!(30)
    assert_equal 30, verdict.tick
    assert_nil verdict.local_md5, "we never reached the boundary — recorded honestly"
    assert_nil verdict.record
  end

  # --- D derivation (fork 5) ---------------------------------------------------

  def test_derive_delay_median_formula
    d = Net::Lockstep.derive_delay([100, 100, 100, 100, 100], CFG[:delay])
    assert_equal 6, d.d # ceil(50/16.67)=3 + jitter 3
    refute d.link_slow
    d = Net::Lockstep.derive_delay([150] * 5, CFG[:delay])
    assert_equal 8, d.d # the banked BR<->US estimate lands on the default
  end

  def test_derive_delay_uses_the_median_not_the_mean
    d = Net::Lockstep.derive_delay([50, 5000, 100, 90, 110], CFG[:delay])
    assert_equal 6, d.d, "one outlier probe must not inflate D"
    even = Net::Lockstep.derive_delay([100, 200], CFG[:delay])
    assert_equal 8, even.d # median 150
  end

  def test_derive_delay_probe_failure_falls_back_to_default
    d = Net::Lockstep.derive_delay([], CFG[:delay])
    assert_equal CFG[:delay][:default], d.d
    refute d.link_slow
    assert_equal 8, Net::Lockstep.derive_delay(nil, CFG[:delay]).d
  end

  def test_derive_delay_clamps_and_flags_link_slow
    slow = Net::Lockstep.derive_delay([400] * 5, CFG[:delay])
    assert_equal CFG[:delay][:max], slow.d # raw 15 clamped to 12
    assert slow.link_slow, "above-clamp starts anyway with the LINK SLOW flag"
    fast = Net::Lockstep.derive_delay([10] * 5,
                                      { min: 4, max: 12, default: 8, jitter_margin_ticks: 0 })
    assert_equal 4, fast.d, "clamped up to min"
    refute fast.link_slow
  end
end
