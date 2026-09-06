require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/session"
require "fileutils"
require "json"

# v17 increment 6 — THE etapa-1 test (spec Test lane): two REAL Worlds and
# two REAL Sessions over real loopback TCP in ONE process, scripted inputs
# on both seats, synchronous alternating pumps, NO THREADS (decision 7),
# caller-fed fake clock (no test ever waits on real time). Three endings —
# hold, divergence, stall — the outcomes the SIXTEENTH ask can produce.
class NetplayIntegrationTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["netplay"]
  HELLO = { version: 2, ruby: "3.4.10", platform: "test", fingerprint: "c" * 32,
            digest_version: 1 }.freeze

  def sessions(epoch:, seed: 7)
    @h = Net::Session.host(player_id: "bot-1", bind: "127.0.0.1", port: 0, config: CFG,
                           seed:, epoch:, hello: HELLO.dup)
    @j = Net::Session.join(player_id: "bot-2", host: "127.0.0.1", port: @h.port, config: CFG, hello: HELLO.dup)
    [@h, @j]
  end

  def teardown
    [@h, @j].each do |s|
      next if s.nil? || s.ended?
      s.quit!(10**12)
      s.update(10**12 + CFG[:drain_timeout_ms] + 1)
    end
  end

  # Full handshake + world attach; returns [world_h, world_j, fake_ms].
  def handshake(h, j)
    t = 0
    400.times do
      break if h.params_known? && j.params_known?
      h.update(t)
      j.update(t)
      t += 10
    end
    flunk "handshake never produced params" unless h.params_known? && j.params_known?
    wh = Game::World.new(DATA, seed: h.params.seed, seats: 2)
    wj = Game::World.new(DATA, seed: j.params.seed, seats: 2)
    h.attach(wh)
    j.attach(wj)
    50.times do
      break if h.running? && j.running?
      h.update(t)
      j.update(t)
      t += 10
    end
    flunk "START barrier never resolved" unless h.running? && j.running?
    [wh, wj, t]
  end

  # Scripted seat drives: movement + verbs on staggered cycles so the two
  # seats exercise different masks every tick (real fights, real AI).
  def seat1_input
    Core::ScriptedInput.new(frames: (0..4200).to_h do |f|
      actions = case f % 120
                when 0...50 then ["right"]
                when 50...70 then ["attack"]
                when 70...100 then ["down"]
                else []
                end
      [f, actions]
    end)
  end

  def seat2_input
    Core::ScriptedInput.new(frames: (0..4200).to_h do |f|
      actions = case f % 150
                when 0...40 then ["left"]
                when 40...60 then ["up"]
                when 60...80 then ["dodge"]
                when 80...110 then ["attack"]
                else []
                end
      [f, actions]
    end)
  end

  # --- the hold (oracle half A's shape) --------------------------------------

  def test_hold_3k_ticks_zero_desyncs_identical_digest_streams_clean_end
    h, j = sessions(epoch: 1111)
    _wh, _wj, t = handshake(h, j)
    in1 = seat1_input
    in2 = seat2_input
    target = 3000

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    rounds = 0
    (target + 200).times do
      break if h.ticks >= target && j.ticks >= target
      h.update(t, in1)
      j.update(t, in2)
      rounds += 1
      t += 10
    end
    elapsed_s = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started

    assert_operator h.ticks, :>=, target
    assert_equal h.ticks, j.ticks, "lockstep: both seats executed the same tick count"

    # Perf print (informational) + the generous in-process ceiling: BOTH
    # sims + wire per executed tick.
    per_tick_ms = elapsed_s * 1000.0 / rounds
    puts format("NETPLAY PERF ticks=%d rounds=%d per_tick=%.3fms (two sims + wire, one process)",
                h.ticks, rounds, per_tick_ms)
    assert_operator per_tick_ms, :<=, 8.0, "two sims + wire blew the in-process budget"

    # Zero desyncs, digest streams identical, boundaries actually compared.
    assert_equal 0, h.lockstep.desyncs
    assert_equal 0, j.lockstep.desyncs
    assert_equal target / CFG[:digest_every], h.digest_log.length
    assert_equal h.digest_log, j.digest_log, "the two sims produced identical window md5s"
    assert_operator h.lockstep.boundaries_compared, :>=, h.digest_log.length - 2,
                    "digest pairs were compared live, not just logged"

    # Clean end: both seats quit at the same executed tick.
    h.quit!(t)
    j.quit!(t)
    30.times do
      break if h.ended? && j.ended?
      h.update(t)
      j.update(t)
      t += 10
    end
    assert h.ended? && j.ended?, "quit drain never resolved"
    assert_equal :quit, h.reason
    assert_equal :quit, j.reason
    assert_equal 0, h.lockstep.stall_updates, "in-process alternating pumps never stall"
    assert_match(/desyncs=0/, h.telemetry_line)
    # Lag P0: the extended line rides the SAME cross-seat coherence — both
    # seats quit at the same fake-clock t, so d/link_slow/run_ms/stall
    # fields must all agree (shared handshake + shared window); the masked
    # equality below now covers them, and this pins their presence.
    assert_match(/reason=quit d=\d+ link_slow=(?:true|false) run_ms=\d+ stall_run_max=0 stall_worst_run=0\z/,
                 h.telemetry_line)
    assert_equal h.telemetry_line.sub("seat=1", "seat=X"),
                 j.telemetry_line.sub("seat=2", "seat=X"),
                 "final TELEMETRY identical modulo seat"
  end

  # --- divergence injection (oracle half A's failure shape) --------------------

  def test_divergence_desyncs_at_the_next_boundary_with_artifacts_on_both_seats
    h, j = sessions(epoch: 2222)
    wh, _wj, t = handshake(h, j)
    in1 = seat1_input
    in2 = seat2_input
    artifact = File.join(Net::Session::ROOT, "tmp", "netplay",
                         "desync_#{h.params.session_id}_tick60.json")
    FileUtils.rm_f(artifact)

    30.times do
      h.update(t, in1)
      j.update(t, in2)
      t += 10
    end
    assert_operator h.ticks, :<, 60, "staging: the poke must land before the first boundary"
    wh.pack.bank!(1) # poke ONE world's sim state mid-run: the sims have now diverged

    200.times do
      break if h.ended? && j.ended?
      h.update(t, in1)
      j.update(t, in2)
      t += 10
    end
    assert h.ended? && j.ended?, "desync exchange never resolved"
    assert_equal :desync, h.reason
    assert_equal :desync, j.reason, "both ends read reason=desync (D2 fold)"
    assert_equal 1, h.lockstep.desyncs
    assert_equal 1, j.lockstep.desyncs
    assert_match(/desyncs=1/, h.telemetry_line)
    assert_match(/desyncs=1/, j.telemetry_line)

    # The artifact: written by BOTH seats (same path in-process — on real
    # machines each seat writes its own copy; Junior shares his).
    refute_nil h.artifact_path
    refute_nil j.artifact_path
    assert File.exist?(artifact), "the desync artifact must exist"
    report = JSON.parse(File.read(artifact), symbolize_names: true)
    assert_equal 60, report[:tick], "detection at the NEXT boundary after the poke"
    assert_equal h.params.session_id, report[:session_id]
    refute_equal report[:own_md5], report[:peer_md5]
    assert report[:snapshot].any?, "the retained window snapshot rides the artifact"
    assert_equal HELLO, report[:manifest]
  end

  # --- stall abort (frozen peer) -------------------------------------------------

  def test_frozen_peer_pump_reads_as_connection_lost_on_both_ends
    h, j = sessions(epoch: 3333)
    _wh, _wj, t = handshake(h, j)
    in1 = seat1_input
    in2 = seat2_input

    30.times do
      h.update(t, in1)
      j.update(t, in2)
      t += 10
    end
    refute h.ended?

    # Freeze seat 2's pump entirely; only the host updates, fake clock
    # marching in 100ms steps past abort_stall_ms (500 x 100ms = 50s > 45s).
    warn_seen = false
    500.times do
      h.update(t, in1)
      warn_seen ||= !h.stall_warning_ms.nil?
      break if h.ended?
      t += 100
    end
    assert h.ended?, "continuous stall past abort_stall_ms must end the session"
    assert_equal :conn_lost, h.reason
    assert warn_seen, "the stall overlay feed fired past stall_warn_ms (presentation spec 3)"
    assert_operator h.lockstep.stall_updates, :>, 0
    assert_operator h.lockstep.stall_ms_max, :>=, CFG[:abort_stall_ms]
    assert_match(/reason=conn_lost/, h.telemetry_line)

    # Thaw the frozen seat: it discovers the peer's honest end.
    30.times do
      j.update(t, in2)
      break if j.ended?
      t += 10
    end
    assert j.ended?
    assert_equal :conn_lost, j.reason, "CONNECTION LOST on both ends"
  end
end
