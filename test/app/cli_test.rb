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

  # v18 increment 3 (spark order): --fresh composes with --host — host
  # custody is live, so the shared world resets AT the host launch (the
  # backup law still fires first). Order-insensitive; never with --join
  # (the joiner owns no save to reset).
  def test_fresh_composes_with_host_in_either_order
    assert_equal({ mode: :host, port: DEFAULT, fresh: true }, parse("--fresh", "--host"))
    assert_equal({ mode: :host, port: DEFAULT, fresh: true }, parse("--host", "--fresh"))
    assert_equal({ mode: :host, port: 5000, fresh: true }, parse("--host", "5000", "--fresh"))
    assert_equal({ mode: :host, port: 5000, fresh: true }, parse("--fresh", "--host", "5000"))
    assert_equal({ mode: :host, port: 5000, fresh: true }, parse("--host", "--fresh", "5000"),
                 "--fresh is an order-free modifier, never a port")
  end

  def test_fresh_never_composes_with_join
    err = assert_raises(ArgumentError) { parse("--join", "1.2.3.4", "--fresh") }
    assert_match(/usage:/, err.message)
    assert_raises(ArgumentError) { parse("--fresh", "--join", "1.2.3.4") }
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

  # v18 session-8 soak — the save-quarantine seam (brief D3): --save
  # overrides the save file (solo/host lanes, order-free); --bot in a
  # save-owning role REFUSES without it; the joiner never keeps a save,
  # so --join --save refuses and --join --bot needs no --save.
  def test_save_parses_solo_override
    assert_equal({ mode: :solo, save: "tmp/x.json" }, parse("--save", "tmp/x.json"))
  end

  def test_save_composes_with_host_in_either_order
    assert_equal({ mode: :host, port: DEFAULT, save: "tmp/x.json" },
                 parse("--host", "--save", "tmp/x.json"))
    assert_equal({ mode: :host, port: 5000, save: "tmp/x.json" },
                 parse("--save", "tmp/x.json", "--host", "5000"))
  end

  def test_save_composes_with_fresh
    assert_equal({ mode: :host, port: DEFAULT, fresh: true, save: "tmp/x.json" },
                 parse("--host", "--fresh", "--save", "tmp/x.json"))
  end

  def test_save_needs_a_value
    err = assert_raises(ArgumentError) { parse("--save") }
    assert_match(/usage:/, err.message)
    assert_raises(ArgumentError) { parse("--save", "--host") }
  end

  def test_save_never_composes_with_join
    err = assert_raises(ArgumentError) { parse("--join", "1.2.3.4", "--save", "tmp/x.json") }
    assert_match(/never keeps the save/, err.message)
  end

  def test_bot_with_seed_parses
    assert_equal({ mode: :solo, save: "tmp/x.json", bot: { seed: 5, ticks: nil } },
                 parse("--bot", "5", "--save", "tmp/x.json"))
  end

  def test_bot_seed_is_optional
    assert_equal({ mode: :solo, save: "tmp/x.json", bot: { seed: nil, ticks: nil } },
                 parse("--bot", "--save", "tmp/x.json"))
  end

  def test_bot_ticks_parses
    assert_equal({ mode: :solo, save: "tmp/x.json", bot: { seed: 5, ticks: 7200 } },
                 parse("--bot", "5", "--bot-ticks", "7200", "--save", "tmp/x.json"))
  end

  def test_bot_composes_with_host
    assert_equal({ mode: :host, port: DEFAULT, save: "tmp/x.json", bot: { seed: 7, ticks: nil } },
                 parse("--host", "--bot", "7", "--save", "tmp/x.json"))
  end

  # D3: the refusal that makes bots shippable — a bot that would OWN the
  # save (solo or host) must be pointed at a scratch file, mechanically.
  def test_bot_solo_without_save_refuses_named
    err = assert_raises(ArgumentError) { parse("--bot", "5") }
    assert_match(/--bot needs --save/, err.message)
    assert_match(/never touches the real save/, err.message)
  end

  def test_bot_host_without_save_refuses_named
    err = assert_raises(ArgumentError) { parse("--host", "--bot") }
    assert_match(/--bot needs --save/, err.message)
  end

  def test_bot_joiner_needs_no_save
    assert_equal({ mode: :join, host: "1.2.3.4", port: DEFAULT, bot: { seed: 9, ticks: nil } },
                 parse("--join", "1.2.3.4", "--bot", "9"))
  end

  # Quality-flywheel lane 1 (2026-08-19): --start-zone is soak coverage
  # tooling — bot-gated by law (a human start-zone would be a teleport
  # cheat on the real save; the in-game map/teleport lane stays parked).
  def test_start_zone_parses_with_bot
    assert_equal({ mode: :solo, save: "tmp/x.json", start_zone: "low_quay",
                   bot: { seed: 5, ticks: nil } },
                 parse("--bot", "5", "--save", "tmp/x.json", "--start-zone", "low_quay"))
  end

  def test_start_zone_composes_with_host_and_join
    host = parse("--host", "--bot", "7", "--save", "tmp/x.json", "--start-zone", "district")
    assert_equal "district", host[:start_zone]
    join = parse("--join", "1.2.3.4", "--bot", "9", "--start-zone", "district")
    assert_equal "district", join[:start_zone]
  end

  def test_start_zone_without_bot_refuses_named
    err = assert_raises(ArgumentError) { parse("--start-zone", "district") }
    assert_match(/--start-zone needs --bot/, err.message)
  end

  def test_start_zone_needs_a_value
    assert_raises(ArgumentError) { parse("--bot", "--save", "tmp/x.json", "--start-zone") }
  end

  def test_bot_ticks_without_bot_refuses
    err = assert_raises(ArgumentError) { parse("--bot-ticks", "7200") }
    assert_match(/--bot-ticks needs --bot/, err.message)
  end

  def test_bad_bot_ticks_raises
    assert_raises(ArgumentError) { parse("--bot", "--bot-ticks", "zero", "--save", "x") }
    assert_raises(ArgumentError) { parse("--bot", "--bot-ticks", "0", "--save", "x") }
  end

  # The absence pin (D2): without --bot no :bot key exists, so the
  # guarded AUTOPILOT banner print site in main.rb cannot fire — non-bot
  # output stays byte-identical.
  def test_no_bot_key_without_the_flag
    refute parse("--host").key?(:bot)
    refute parse("--join", "1.2.3.4").key?(:bot)
    refute parse("--save", "tmp/x.json").key?(:bot)
    assert_nil parse
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

  def test_exit_status_save_refusals_are_one_never_a_rehost
    # v18 decision 6b RC-matrix extension: every save refusal reason ends
    # with a refusal text on BOTH seats -> exit 1 -> the coop launchers
    # stop (rehost/rejoin fires ONLY on 2).
    ["REFUSED — save schema: theirs 99 / ours 1",
     "REFUSED — save digest: declared \"abc\" / received bytes def",
     "REFUSED — save facts unparseable: unexpected token",
     "REFUSED — save home_zone: unknown zone \"attic\""].each do |text|
      assert_equal 1, App::Cli.exit_status(reason: :protocol, refusal: text), text
    end
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
