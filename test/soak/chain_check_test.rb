require_relative "../test_helper"
require_relative "../../soak/chain_check"

# v18 session-8 soak (brief D6/D7): the chain checker judges a soak run
# from LOGS + exit codes ONLY (never process liveness — memorized law:
# process-alive != session-alive). Its input IS log text, so these
# fixtures are the real interface, not mocks. The invariants are
# Half-A-SHAPED rehearsals on scratch data: reason=quit both seats,
# desyncs=0, ticks >= target, loaded digest == previous saved digest,
# sessions +1 per episode. The spec's arbiter stays CLOSED — a soak
# verdict is never oracle evidence.
class ChainCheckTest < Minitest::Test
  D1 = "aaaa1111aaaa1111aaaa1111aaaa1111".freeze
  D2 = "bbbb2222bbbb2222bbbb2222bbbb2222".freeze
  D3 = "cccc3333cccc3333cccc3333cccc3333".freeze

  def persist(kind, digest: nil, sessions: nil, source: nil)
    parts = ["TELEMETRY persist #{kind}"]
    parts << "digest=#{digest}" if digest
    parts << "schema=1 banked=0 provisions=0 seals=0 marks=0" if digest
    parts << "sessions=#{sessions}" if sessions
    parts << "source=#{source}" if source
    parts.join(" ")
  end

  def netplay(seat:, ticks:, desyncs: 0, reason: "quit")
    "TELEMETRY netplay seat=#{seat} ticks=#{ticks} desyncs=#{desyncs} " \
      "stalls=0 stall_ms_max=0 reason=#{reason}"
  end

  def host_log(seed:, ticks:, saved: nil, sessions: nil, loaded: nil,
               fresh: false, desyncs: 0, reason: "quit", banner: true, error: nil)
    lines = []
    lines << "AUTOPILOT seed=#{seed} quit_tick=#{ticks + 120}" if banner
    lines << persist("fresh", source: "fresh") if fresh
    lines << persist("loaded", digest: loaded, sessions: [sessions.to_i - 1, 1].max, source: "file") if loaded
    lines << "hosting on port 43218 (Esc cancels)"
    lines << "EVENT arena_pulse zone=1"
    lines << "persist ERROR #{error}" if error
    lines << persist("saved", digest: saved, sessions:) if saved
    lines << netplay(seat: 1, ticks:, desyncs:, reason:)
    lines << "relaunch: bin/play --host 43218"
    lines.join("\n") + "\n"
  end

  def joiner_log(seed:, ticks:, loaded: nil, desyncs: 0, reason: "quit", banner: true)
    lines = []
    lines << "AUTOPILOT seed=#{seed} quit_tick=#{ticks + 3720}" if banner
    lines << persist("loaded", digest: loaded, sessions: 1, source: "handshake") if loaded
    lines << netplay(seat: 2, ticks:, desyncs:, reason:)
    lines << "relaunch: bin/play --join 127.0.0.1:43218"
    lines.join("\n") + "\n"
  end

  def ep(index, host, joiner, host_exit: 0, joiner_exit: 0, timeout: false)
    { index:, host_log: host, joiner_log: joiner,
      host_exit:, joiner_exit:, timeout: }
  end

  def green_run
    [ep(1, host_log(seed: 101, ticks: 36_050, fresh: true, saved: D1, sessions: 1),
        joiner_log(seed: 102, ticks: 36_047)),
     ep(2, host_log(seed: 103, ticks: 36_101, loaded: D1, saved: D2, sessions: 2),
        joiner_log(seed: 104, ticks: 36_098, loaded: D1)),
     ep(3, host_log(seed: 105, ticks: 36_200, loaded: D2, saved: D3, sessions: 3),
        joiner_log(seed: 106, ticks: 36_190, loaded: D2))]
  end

  def check(eps, min_ticks: 36_000, mode: "both", allow_link_faults: false)
    Soak::ChainCheck.check(eps, min_ticks:, mode:, allow_link_faults:)
  end

  def test_green_three_episode_run_passes_with_intact_chain
    pass, lines = check(green_run)
    report = lines.join("\n")
    assert pass, report
    assert_match(/SOAK PASS episodes=3/, report)
    assert_match(/CHAIN intact/, report)
    assert_match(/sessions 1->3/, report)
  end

  def test_desync_is_a_hard_fail_even_with_exit_zero
    eps = green_run
    eps[1][:host_log] = host_log(seed: 103, ticks: 20_000, loaded: D1,
                                 desyncs: 1, reason: "desync")
    eps[1][:joiner_log] = joiner_log(seed: 104, ticks: 20_000, loaded: D1,
                                     desyncs: 1, reason: "desync")
    pass, lines = check(eps)
    refute pass
    assert_match(/desyncs=1/, lines.join("\n"))
    assert_match(/SOAK FAIL/, lines.join("\n"))
  end

  def test_chain_break_names_both_digests
    eps = green_run
    eps[2][:host_log] = host_log(seed: 105, ticks: 36_200, loaded: D1,
                                 saved: D3, sessions: 3)
    pass, lines = check(eps)
    refute pass
    report = lines.join("\n")
    assert_match(/chain break/i, report)
    assert_includes report, D1
    assert_includes report, D2
  end

  def test_sessions_must_increment_by_one
    eps = green_run
    eps[1][:host_log] = host_log(seed: 103, ticks: 36_101, loaded: D1,
                                 saved: D2, sessions: 1)
    pass, lines = check(eps)
    refute pass
    assert_match(/sessions/, lines.join("\n"))
  end

  def test_joiner_handshake_digest_must_match_hosts
    eps = green_run
    eps[1][:joiner_log] = joiner_log(seed: 104, ticks: 36_098, loaded: D3)
    pass, lines = check(eps)
    refute pass
    assert_match(/handshake/, lines.join("\n"))
  end

  def test_fresh_episode_forbids_a_joiner_loaded_line
    eps = green_run
    eps[0][:joiner_log] = joiner_log(seed: 102, ticks: 36_047, loaded: D1)
    pass, lines = check(eps)
    refute pass
    assert_match(/fresh/, lines.join("\n"))
  end

  def test_link_fault_fails_on_loopback
    eps = green_run
    eps[1][:host_log] = host_log(seed: 103, ticks: 12_000, loaded: D1,
                                 reason: "conn_lost")
    eps[1][:host_exit] = 2
    eps[1][:joiner_log] = joiner_log(seed: 104, ticks: 12_000, loaded: D1,
                                     reason: "conn_lost")
    eps[1][:joiner_exit] = 2
    pass, = check(eps)
    refute pass
  end

  def test_link_fault_tolerated_when_allowed_and_chain_skips_the_unsaved_episode
    eps = green_run
    eps[1][:host_log] = host_log(seed: 103, ticks: 12_000, loaded: D1,
                                 reason: "conn_lost")
    eps[1][:host_exit] = 2
    eps[1][:joiner_log] = joiner_log(seed: 104, ticks: 12_000, loaded: D1,
                                     reason: "conn_lost")
    eps[1][:joiner_exit] = 2
    # conn_lost writes no save -> ep3 legitimately loads D1 (last saved)
    eps[2][:host_log] = host_log(seed: 105, ticks: 36_200, loaded: D1,
                                 saved: D3, sessions: 2)
    eps[2][:joiner_log] = joiner_log(seed: 106, ticks: 36_190, loaded: D1)
    pass, lines = check(eps, allow_link_faults: true)
    report = lines.join("\n")
    assert pass, report
    assert_match(/FINDING: .*link fault/, report)
  end

  def test_ticks_below_target_fail
    eps = green_run
    eps[0][:host_log] = host_log(seed: 101, ticks: 9_000, fresh: true,
                                 saved: D1, sessions: 1)
    pass, lines = check(eps)
    refute pass
    assert_match(/ticks/, lines.join("\n"))
  end

  def test_clean_quit_without_a_saved_line_fails
    eps = green_run
    eps[1][:host_log] = host_log(seed: 103, ticks: 36_101, loaded: D1)
    pass, lines = check(eps)
    refute pass
    assert_match(/no persist saved/, lines.join("\n"))
  end

  def test_missing_netplay_line_fails
    eps = green_run
    eps[0][:host_log] = "AUTOPILOT seed=101 quit_tick=36120\ncrash backtrace here\n"
    pass, lines = check(eps)
    refute pass
    assert_match(/netplay line/, lines.join("\n"))
  end

  def test_timeout_fails_named
    eps = green_run
    eps[2][:timeout] = true
    pass, lines = check(eps)
    refute pass
    assert_match(/timeout/, lines.join("\n"))
  end

  def test_persist_error_fails
    eps = green_run
    eps[1][:host_log] = host_log(seed: 103, ticks: 36_101, loaded: D1,
                                 saved: D2, sessions: 2,
                                 error: "save replace refused")
    pass, lines = check(eps)
    refute pass
    assert_match(/persist ERROR/, lines.join("\n"))
  end

  def test_missing_banner_fails_bots_did_not_drive
    eps = green_run
    eps[0][:host_log] = host_log(seed: 101, ticks: 36_050, fresh: true,
                                 saved: D1, sessions: 1, banner: false)
    pass, lines = check(eps)
    refute pass
    assert_match(/AUTOPILOT/, lines.join("\n"))
  end

  def test_nonzero_exit_one_fails
    eps = green_run
    eps[0][:host_exit] = 1
    pass, lines = check(eps)
    refute pass
    assert_match(/exit/, lines.join("\n"))
  end

  # Cross-machine single-side mode (brief Job-4 seam): the absent seat is
  # a named SKIP, never a silent pass and never a failure.
  def test_host_only_mode_skips_the_absent_joiner
    eps = green_run.map do |e|
      e.merge(joiner_log: nil, joiner_exit: nil)
    end
    pass, lines = check(eps, mode: "host_only")
    report = lines.join("\n")
    assert pass, report
    assert_match(/SKIP.*joiner/, report)
  end

  def test_both_mode_fails_on_a_missing_joiner_log
    eps = green_run
    eps[1][:joiner_log] = nil
    pass, lines = check(eps)
    refute pass
    assert_match(/joiner log missing/, lines.join("\n"))
  end

  def test_join_only_mode_checks_the_joiner_and_skips_persistence
    eps = [ep(1, nil, joiner_log(seed: 102, ticks: 36_047, loaded: D1),
              host_exit: nil),
           ep(2, nil, joiner_log(seed: 104, ticks: 36_098, loaded: D2),
              host_exit: nil)]
    pass, lines = check(eps, mode: "join_only")
    report = lines.join("\n")
    assert pass, report
    assert_match(/SKIP.*host/, report)
  end
end
