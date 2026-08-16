require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/session"

# v17 increment 5 — the handshake over REAL 127.0.0.1 sockets (explicit:
# no firewall prompt, CI-safe), synchronous pumps, NO THREADS (decision
# 7). The clock is caller-fed fake ms, so probe RTTs — and therefore D —
# are deterministic and no test ever waits on real time.
class SessionTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["netplay"]
  HELLO = { version: 1, ruby: "3.4.10", platform: "test", fingerprint: "a" * 32,
            digest_version: 1 }.freeze

  def host_session(seed: 7, hello: HELLO, epoch: 4242)
    @host = Net::Session.host(bind: "127.0.0.1", port: 0, config: CFG,
                              seed:, epoch:, hello: hello.dup)
  end

  def join_session(port, hello: HELLO)
    @join = Net::Session.join(host: "127.0.0.1", port:, config: CFG, hello: hello.dup)
  end

  def teardown
    [@host, @join].each do |s|
      next if s.nil? || s.ended?
      s.quit!(10**12)
      s.update(10**12 + CFG[:drain_timeout_ms] + 1)
    end
  end

  # Alternating synchronous pump rounds on a fake clock. One host update
  # then one joiner update per round; step_ms controls measured RTTs.
  def pump_until(h, j, cap: 200, step_ms: 10, start_ms: 0, what: "condition")
    t = start_ms
    cap.times do
      return t if yield
      h.update(t)
      j.update(t)
      t += step_ms
    end
    flunk "#{what} not reached within #{cap} pump rounds"
  end

  def handshake(h, j, step_ms: 10)
    pump_until(h, j, step_ms:, what: "params") { h.params_known? && j.params_known? }
    h.attach(Game::World.new(DATA, seed: h.params.seed, seats: 2))
    j.attach(Game::World.new(DATA, seed: j.params.seed, seats: 2))
    pump_until(h, j, step_ms:, what: "run phase") { h.running? && j.running? }
  end

  # --- happy path -----------------------------------------------------------

  def test_happy_path_reaches_run_with_agreed_params_on_both_seats
    h = host_session
    j = join_session(h.port)
    handshake(h, j)
    assert_equal 1, h.seat, "host = seat 1 always"
    assert_equal 2, j.seat
    assert_equal h.params, j.params, "SESSION carries what the host decided"
    assert_equal format("%08x", 7 ^ 4242), h.params.session_id, "seed XOR epoch, human-readable"
    assert_equal 7, j.params.seed
    assert_equal CFG[:digest_every], h.params.digest_every
    assert_equal 4, h.params.d, "loopback 10ms rounds: ceil(5/16.67)=1 + jitter 3 = 4"
    refute h.link_slow
    refute j.link_slow
  end

  def test_probe_rtts_drive_d_derivation
    h = host_session
    j = join_session(h.port)
    pump_until(h, j, step_ms: 100, what: "params") { h.params_known? && j.params_known? }
    assert_equal 6, h.params.d, "RTT 100ms: ceil(50/16.67)=3 + jitter 3 = 6"
    assert_equal 6, j.params.d
  end

  def test_slow_link_clamps_d_and_flags_link_slow_on_both_seats
    h = host_session
    j = join_session(h.port)
    pump_until(h, j, step_ms: 400, what: "params") { h.params_known? && j.params_known? }
    assert_equal CFG[:delay][:max], h.params.d, "raw 15 clamps to 12"
    assert h.link_slow, "the host derived it"
    assert j.link_slow, "SESSION carried it — both seats can banner LINK SLOW"
  end

  # --- the READY -> START barrier ---------------------------------------------

  def test_start_barrier_holds_until_both_seats_attach_worlds
    h = host_session
    j = join_session(h.port)
    pump_until(h, j, what: "params") { h.params_known? && j.params_known? }

    j.attach(Game::World.new(DATA, seed: j.params.seed, seats: 2))
    t = 1000
    10.times do
      h.update(t)
      j.update(t)
      t += 10
    end
    refute h.running?, "host holds: READY received but its own world is not attached"
    refute j.running?, "joiner holds: no START yet"

    h.attach(Game::World.new(DATA, seed: h.params.seed, seats: 2))
    pump_until(h, j, start_ms: t, what: "run") { h.running? && j.running? }
    assert h.running? && j.running?
  end

  def test_attach_before_params_raises
    h = host_session
    err = assert_raises(RuntimeError) { h.attach(Game::World.new(DATA, seed: 1, seats: 2)) }
    assert_match(/params/, err.message)
  end

  # --- refusal (W6: stale-line joins) -------------------------------------------

  def test_fingerprint_mismatch_refuses_on_both_seats_naming_the_field
    h = host_session
    j = join_session(h.port, hello: HELLO.merge(fingerprint: "b" * 32))
    pump_until(h, j, what: "both ended") { h.ended? && j.ended? }
    [h, j].each do |s|
      assert_equal :protocol, s.reason
      assert_match(/sim fingerprint/, s.refusal, "the print NAMES the differing field")
      assert_match(/git pull/, s.refusal)
    end
  end

  def test_version_mismatch_names_protocol_version
    h = host_session
    j = join_session(h.port, hello: HELLO.merge(version: 99))
    pump_until(h, j, what: "both ended") { h.ended? && j.ended? }
    assert_match(/protocol version/, h.refusal)
    assert_match(/protocol version/, j.refusal)
  end

  # --- termination: clean quit ---------------------------------------------------

  def test_clean_quit_records_reason_quit_on_both_seats
    h = host_session
    j = join_session(h.port)
    t = handshake(h, j)
    t = pump_until(h, j, cap: 30, start_ms: t, what: "some executed ticks") do
      h.ticks > 10 && j.ticks > 10
    end
    h.quit!(t)
    pump_until(h, j, start_ms: t, what: "both ended") { h.ended? && j.ended? }
    assert_equal :quit, h.reason
    assert_equal :quit, j.reason, "receiver records quit too (no initiator distinction)"
    assert_match(/\ATELEMETRY netplay seat=1 ticks=\d+ desyncs=0 stalls=\d+ stall_ms_max=\d+ reason=quit\z/,
                 h.telemetry_line)
    assert_match(/seat=2/, j.telemetry_line)
  end

  # --- protocol faults (raw-socket peer: a REAL socket speaking wrong) ------------

  def raw_peer(host)
    TCPSocket.new("127.0.0.1", host.port)
  end

  def pump_host_until(h, cap: 50, what: "condition")
    t = 0
    cap.times do
      return if yield
      h.update(t)
      t += 10
    end
    flunk "#{what} not reached"
  end

  def test_out_of_phase_message_is_a_protocol_fault
    h = host_session
    raw = raw_peer(h)
    raw.write(Net::Protocol.encode(:hello, **HELLO))
    pump_host_until(h, what: "probe phase") { h.phase == :probe }
    raw.write(Net::Protocol.encode(:input, t: 0, bits: 0))
    pump_host_until(h, what: "fault end") { h.ended? }
    assert_equal :protocol, h.reason
    assert_match(/INPUT out of phase/, h.fault_message)
    raw.close
  end

  def test_garbage_line_is_a_protocol_fault
    h = host_session
    raw = raw_peer(h)
    raw.write("this is not json\n")
    pump_host_until(h, what: "fault end") { h.ended? }
    assert_equal :protocol, h.reason
    assert_match(/bad JSON/, h.fault_message)
    raw.close
  end

  def test_silent_connected_peer_times_out_as_conn_lost
    h = host_session
    raw = raw_peer(h)
    raw.write(Net::Protocol.encode(:hello, **HELLO))
    pump_host_until(h, what: "probe phase") { h.phase == :probe }
    h.update(100)
    h.update(200 + CFG[:abort_stall_ms])
    assert h.ended?, "a connected peer stuck past abort_stall_ms is a dead handshake"
    assert_equal :conn_lost, h.reason
    raw.close
  end

  def test_listening_alone_never_times_out
    h = host_session
    h.update(0)
    h.update(CFG[:abort_stall_ms] * 3)
    refute h.ended?, "hosting waits for a partner indefinitely (Esc cancels)"
    assert_equal :listen, h.phase
  end
end
