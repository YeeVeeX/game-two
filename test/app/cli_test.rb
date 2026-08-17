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
end
