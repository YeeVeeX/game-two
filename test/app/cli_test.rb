require_relative "../test_helper"
require "app/cli"

# v17 increment 7 — the CLI seam: window mode untouched without flags;
# --host/--join parse with the data-driven default port; every error is
# an ArgumentError carrying usage (console abort, nonzero — the
# bindings-error precedent).
class CliTest < Minitest::Test
  DEFAULT = 43_117

  def parse(*argv) = App::Cli.parse(argv, default_port: DEFAULT)

  def test_no_args_is_window_mode_unchanged
    assert_nil parse
  end

  # v18 decision 14: --fresh backs the save up and starts over (solo lane).
  def test_fresh_parses_solo_fresh
    assert_equal({ mode: :solo, fresh: true }, parse("--fresh"))
  end

  def test_fresh_takes_no_arguments
    err = assert_raises(ArgumentError) { parse("--fresh", "now") }
    assert_match(/usage:/, err.message)
  end

  # v18 decision 16: one seed derivation for solo AND host — 32-bit
  # masked, fresh per call (the fixed-seed-0 solo field is the dead bug).
  def test_new_seed_is_masked_and_varies
    seeds = Array.new(8) { App::Cli.new_seed }
    assert seeds.all? { |s| s.is_a?(Integer) && s >= 0 && s <= 0xffff_ffff }
    assert seeds.uniq.length > 1, "eight identical seeds — derivation is not per-session"
  end

  def test_host_defaults_the_port_from_data
    assert_equal({ mode: :host, port: DEFAULT }, parse("--host"))
  end

  def test_host_takes_an_explicit_port
    assert_equal({ mode: :host, port: 5000 }, parse("--host", "5000"))
  end

  def test_join_parses_bare_ip_with_default_port
    assert_equal({ mode: :join, host: "100.64.0.7", port: DEFAULT },
                 parse("--join", "100.64.0.7"))
  end

  def test_join_parses_ip_colon_port
    assert_equal({ mode: :join, host: "100.64.0.7", port: 5000 },
                 parse("--join", "100.64.0.7:5000"))
  end

  def test_join_without_address_raises_usage
    err = assert_raises(ArgumentError) { parse("--join") }
    assert_match(/usage:/, err.message)
  end

  def test_unknown_flag_raises_usage
    err = assert_raises(ArgumentError) { parse("--serve") }
    assert_match(/usage:/, err.message)
  end

  def test_bad_port_raises
    assert_raises(ArgumentError) { parse("--host", "not-a-port") }
    assert_raises(ArgumentError) { parse("--join", "100.64.0.7:99999") }
  end

  def test_extra_args_raise
    assert_raises(ArgumentError) { parse("--host", "5000", "extra") }
    assert_raises(ArgumentError) { parse("--join", "1.2.3.4", "extra") }
  end

  # v17 SIXTEENTH support — exit-status seam: launchers loop ONLY on link
  # faults (2). Clean quit (0) and refusals/desync (1/0) stop the loop —
  # honest ends stay honest (etapa-1 law: end LOUDLY, never mask).
  def test_exit_status_clean_quit_is_zero
    assert_equal 0, App::Cli.exit_status(reason: :quit, refusal: nil)
  end

  def test_exit_status_refusal_is_one_regardless_of_reason
    assert_equal 1, App::Cli.exit_status(reason: :fingerprint, refusal: "peer refused: fingerprint")
    assert_equal 1, App::Cli.exit_status(reason: :conn_lost, refusal: "peer refused: fingerprint")
  end

  def test_exit_status_conn_lost_is_two
    assert_equal 2, App::Cli.exit_status(reason: :conn_lost, refusal: nil)
  end

  def test_exit_status_desync_and_protocol_stop_the_loop
    assert_equal 0, App::Cli.exit_status(reason: :desync, refusal: nil)
    assert_equal 0, App::Cli.exit_status(reason: :protocol, refusal: nil)
  end

  def test_exit_status_single_player_no_session_is_zero
    assert_equal 0, App::Cli.exit_status(reason: nil, refusal: nil)
  end
end
