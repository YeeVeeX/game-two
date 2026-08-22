require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/save_state"
require "net/session"
require "app/cli"
require "digest"

# v17 increment 5 — the handshake over REAL 127.0.0.1 sockets (explicit:
# no firewall prompt, CI-safe), synchronous pumps, NO THREADS (decision
# 7). The clock is caller-fed fake ms, so probe RTTs — and therefore D —
# are deterministic and no test ever waits on real time.
class SessionTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["netplay"]
  HELLO = { version: 2, ruby: "3.4.10", platform: "test", fingerprint: "a" * 32,
            digest_version: 1 }.freeze
  VALIDATOR = ->(facts) { Game::SaveState.refusal_for(facts, data: DATA) }

  # The joiner is always constructed the way main.rb constructs it (real
  # schema + real strict decoder — no mocks); hosts opt into a save via
  # save_kw. valid_facts mirrors save_state_test's fixture (real zone +
  # roster names from data/).
  def valid_facts
    {
      "banked" => 12, "provisions" => 1, "home_zone" => "nest",
      "breached" => [["district", [42, 13]]],
      "members" => [
        { "kit" => "striker", "hp" => 80, "inscribed" => false },
        { "kit" => "blocker", "hp" => 0, "inscribed" => true },
        { "kit" => "lobber", "hp" => 33, "inscribed" => false }
      ],
      "counters" => { "boss_1_defeats" => 2, "sessions" => 5 },
      "progression" => { "level" => 1, "xp" => 0 }
    }
  end

  def host_session(seed: 7, hello: HELLO, epoch: 4242, **save_kw)
    @host = Net::Session.host(bind: "127.0.0.1", port: 0, config: CFG,
                              seed:, epoch:, hello: hello.dup, **save_kw)
  end

  def join_session(port, hello: HELLO)
    @join = Net::Session.join(host: "127.0.0.1", port:, config: CFG,
                              hello: hello.dup,
                              save_schema: Game::SaveState::SCHEMA,
                              save_validator: VALIDATOR)
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
    assert_match(
      /\ATELEMETRY netplay seat=1 ticks=\d+ desyncs=0 stalls=\d+ stall_ms_max=\d+ reason=quit d=\d+ link_slow=(?:true|false) run_ms=\d+ stall_run_max=\d+ stall_worst_run=\d+\z/,
      h.telemetry_line
    )
    assert_match(/seat=2/, j.telemetry_line)
  end

  # --- lag P0 (2026-08-20): run_ms + the handshake line -------------------------

  def test_run_ms_spans_run_phase_start_to_conclude_excluding_drain
    h = host_session
    j = join_session(h.port)
    run_started = handshake(h, j)
    t = pump_until(h, j, cap: 30, start_ms: run_started, what: "some executed ticks") do
      h.ticks > 10 && j.ticks > 10
    end
    quit_at = t
    h.quit!(quit_at)
    pump_until(h, j, start_ms: t, what: "both ended") { h.ended? && j.ended? }
    h_run = h.telemetry_line[/run_ms=(\d+)/, 1].to_i
    assert_operator h_run, :>, 0, "run phase spanned real fake-clock time"
    assert_operator h_run, :<=, quit_at - run_started + 10,
                    "drain time (#{CFG[:drain_timeout_ms]}ms deadline) must NOT count into run_ms"
  end

  def test_run_ms_is_zero_when_the_session_never_ran
    h = host_session
    h.update(0)
    h.quit!(10)
    assert h.ended?
    assert_match(/run_ms=0 /, h.telemetry_line, "hosting-screen quit never ran")
  end

  def test_handshake_line_carries_d_and_host_side_rtt_probes
    h = host_session
    j = join_session(h.port)
    handshake(h, j)
    assert_match(/\ANETPLAY handshake seat=1 d=4 link_slow=false rtt_ms=\d+(?:,\d+){4}\z/,
                 h.handshake_line,
                 "host banks its #{CFG[:probe_count]} probe RTTs (10ms pump rounds)")
    assert_equal "NETPLAY handshake seat=2 d=4 link_slow=false rtt_ms=-",
                 j.handshake_line, "probe RTTs are host-side only; nothing new crosses the wire"
  end

  def test_handshake_line_before_params_raises
    h = host_session
    assert_raises(RuntimeError) { h.handshake_line }
  end

  def test_quit_while_hosting_alone_ends_immediately_without_a_drain
    h = host_session
    h.update(0)
    h.quit!(10)
    assert h.ended?, "Esc on the HOSTING screen has no peer to drain for"
    assert_equal :quit, h.reason
  end

  # --- sever! (harness fault injection: process death, no BYE) -----------------

  def test_severed_peer_reads_as_conn_lost_not_quit
    h = host_session
    j = join_session(h.port)
    t = handshake(h, j)
    j.sever!
    pump_until(h, j, start_ms: t, what: "host discovers the dead wire") { h.ended? }
    assert_equal :conn_lost, h.reason, "no BYE arrived — this is a dead link, not a quit"
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

  # --- v18 increment 3: SESSION save transfer (spec decisions 5/6) ------------

  def canonical_save
    Game::SaveState.canonical_bytes(valid_facts)
  end

  def host_with_save(canonical: canonical_save, digest: nil, schema: Game::SaveState::SCHEMA,
                     facts: valid_facts)
    host_session(save_facts: facts, save_canonical: canonical,
                 save_digest: digest || Digest::MD5.hexdigest(canonical),
                 save_schema: schema)
  end

  def test_session_transfers_the_save_and_the_joiner_recomputes_the_digest
    canonical = canonical_save
    h = host_with_save(canonical:)
    j = join_session(h.port)
    pump_until(h, j, what: "params") { h.params_known? && j.params_known? }
    assert_equal valid_facts, j.params.save, "the joiner parsed the received canonical string"
    assert_equal valid_facts, h.params.save, "the host carries the tree it validated at load"
    assert_equal Digest::MD5.hexdigest(canonical), j.params.save_digest,
                 "joiner digest RECOMPUTED from received bytes == declared"
    assert_equal h.params.save_digest, j.params.save_digest
    assert_equal Game::SaveState::SCHEMA, j.params.save_schema
  end

  def test_fresh_world_session_carries_null_save
    h = host_session # no save kwargs = fresh
    j = join_session(h.port)
    pump_until(h, j, what: "params") { h.params_known? && j.params_known? }
    assert_nil j.params.save
    assert_nil j.params.save_digest
    assert_nil h.params.save
  end

  def test_schema_skew_refuses_named_on_both_seats_before_any_params
    h = host_with_save(schema: 99)
    j = join_session(h.port)
    pump_until(h, j, what: "both ended") { h.ended? && j.ended? }
    refute j.params_known?, "a refused save never yields params (no window opens)"
    [h, j].each do |s|
      assert_equal :protocol, s.reason
      assert_match(/save schema/, s.refusal)
      assert_match(/git pull/, s.refusal, "W7: the refusal names the fix")
      assert_equal 1, App::Cli.exit_status(reason: s.reason, refusal: s.refusal)
    end
    assert_equal j.refusal, h.refusal, "decision 6b: BOTH seats print the SAME named refusal"
  end

  def test_tampered_save_refuses_save_digest_on_both_seats
    canonical = canonical_save
    tampered = canonical.sub('"banked":12', '"banked":9999')
    h = host_with_save(canonical: tampered, digest: Digest::MD5.hexdigest(canonical))
    j = join_session(h.port)
    pump_until(h, j, what: "both ended") { h.ended? && j.ended? }
    refute j.params_known?
    [h, j].each do |s|
      assert_match(/save digest/, s.refusal)
      assert_equal 1, App::Cli.exit_status(reason: s.reason, refusal: s.refusal)
    end
    assert_equal j.refusal, h.refusal
  end

  def test_unparseable_save_with_a_true_digest_refuses_save_invalid
    garbage = "{this is not json"
    h = host_with_save(canonical: garbage, digest: Digest::MD5.hexdigest(garbage), facts: nil)
    j = join_session(h.port)
    pump_until(h, j, what: "both ended") { h.ended? && j.ended? }
    assert_match(/save facts unparseable/, j.refusal)
    assert_equal j.refusal, h.refusal
  end

  def test_invalid_facts_refuse_through_the_strict_decoder_with_the_named_text
    bad = valid_facts
    bad["home_zone"] = "district" # not a hub — a NAMED strict-decoder refusal
    canonical = Game::SaveState.canonical_bytes(bad)
    h = host_with_save(canonical:, digest: Digest::MD5.hexdigest(canonical))
    j = join_session(h.port)
    pump_until(h, j, what: "both ended") { h.ended? && j.ended? }
    refute j.params_known?
    assert_match(/home_zone/, j.refusal, "the strict decoder's named refusal reaches the console")
    assert_equal j.refusal, h.refusal, "detail rides the BYE — same text on both seats"
    assert_equal 1, App::Cli.exit_status(reason: j.reason, refusal: j.refusal)
  end

  # --- v18 decision 6c: the wire preflight -------------------------------------

  def test_wire_preflight_passes_a_real_save_under_budget
    canonical = canonical_save
    assert_nil Net::Session.session_wire_refusal(
      save_canonical: canonical, save_digest: Digest::MD5.hexdigest(canonical),
      save_schema: Game::SaveState::SCHEMA, config: CFG,
      budget: DATA["persistence"][:wire_budget_bytes]
    )
  end

  def test_wire_preflight_refuses_named_over_budget_and_past_protocol_max
    big = %({"pad":"#{'x' * 3300}"})
    refusal = Net::Session.session_wire_refusal(
      save_canonical: big, save_digest: Digest::MD5.hexdigest(big),
      save_schema: 1, config: CFG, budget: 3072
    )
    assert_match(/save too large for the wire/, refusal)
    assert_match(/3072/, refusal, "the refusal names the budget")

    huge = %({"pad":"#{'x' * 5000}"})
    refusal = Net::Session.session_wire_refusal(
      save_canonical: huge, save_digest: Digest::MD5.hexdigest(huge),
      save_schema: 1, config: CFG, budget: 3072
    )
    assert_match(/MAX_LINE_BYTES/, refusal, "encode Oversize maps to the same named family")
  end

  def test_wire_preflight_passes_the_worst_case_save
    # W4 tripwire (spec watched risks): the ENCODED line for a maximal
    # save — EVERY seal in data/ breached, counters at 32-bit max — must
    # clear wire_budget_bytes with room. Derived from data, never
    # hardcoded: new seals grow this test's save automatically.
    all_seals = Dir[File.expand_path("../../data/zones/*.json", __dir__)].flat_map do |f|
      zone = File.basename(f, ".json")
      DATA["zones/#{zone}"].fetch(:stations, [])
          .select { |s| s[:type] == "seal" }
          .map { |s| [zone, s[:opens]] }
    end.sort
    refute_empty all_seals, "staging: the world lost its seals"
    worst = valid_facts.merge(
      "breached" => all_seals,
      "banked" => 2**31 - 1, "provisions" => 2**31 - 1,
      "counters" => { "boss_1_defeats" => 2**31 - 1, "sessions" => 2**31 - 1 }
    )
    canonical = Game::SaveState.canonical_bytes(worst)
    assert_nil Net::Session.session_wire_refusal(
      save_canonical: canonical, save_digest: Digest::MD5.hexdigest(canonical),
      save_schema: Game::SaveState::SCHEMA, config: CFG,
      budget: DATA["persistence"][:wire_budget_bytes]
    ), "the worst-case save must fit the wire budget (W4)"
  end

  def test_wire_preflight_passes_a_fresh_world
    assert_nil Net::Session.session_wire_refusal(
      save_canonical: nil, save_digest: nil, save_schema: nil,
      config: CFG, budget: DATA["persistence"][:wire_budget_bytes]
    )
  end
end
