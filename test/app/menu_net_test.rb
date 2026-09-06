require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "core/input"
require "game/world"
require "net/session"
require "app/menu"

# J6-C (brief D14): Menu#net_model reads EXISTING session/lockstep/world
# readers only, against a REAL loopback pair (no mocks; fake caller-fed
# clock — the netplay_overlay_test pattern). The pixels are gated by the
# netplay reel; this lane pins the pure model + the force-close verb.
class MenuNetTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["netplay"]
  HELLO = { version: 1, ruby: "3.4.10", platform: "test", fingerprint: "d" * 32,
            digest_version: 1 }.freeze

  def menu
    @menu ||= App::Menu.new(display: DATA["display"],
                            strings: Core::Strings.new(DATA, locale: "en"))
  end

  def teardown
    [@h, @j].each do |s|
      next if s.nil? || s.ended?
      s.quit!(10**12)
      s.update(10**12 + CFG[:drain_timeout_ms] + 1)
    end
  end

  def run_session
    @h = Net::Session.host(player_id: "bot-1", bind: "127.0.0.1", port: 0, config: CFG,
                           seed: 7, epoch: 99, hello: HELLO.dup)
    @j = Net::Session.join(player_id: "bot-2", host: "127.0.0.1", port: @h.port, config: CFG, hello: HELLO.dup)
    t = 0
    200.times do
      break if @h.params_known? && @j.params_known?
      @h.update(t)
      @j.update(t)
      t += 10
    end
    @wh = Game::World.new(DATA, seed: @h.params.seed, seats: 2)
    @wj = Game::World.new(DATA, seed: @j.params.seed, seats: 2)
    @h.attach(@wh)
    @j.attach(@wj)
    50.times do
      break if @h.running? && @j.running?
      @h.update(t)
      @j.update(t)
      t += 10
    end
    [@h, t]
  end

  def test_net_model_is_nil_outside_a_session
    assert_nil menu.net_model(nil, nil), "solo mode carries no panels"
    h = Net::Session.host(player_id: "bot-1", bind: "127.0.0.1", port: 0, config: CFG,
                          seed: 7, epoch: 99, hello: HELLO.dup)
    @h = h
    h.update(0)
    assert_nil menu.net_model(h, nil), "params-unknown session carries no panels"
  end

  def test_net_model_reads_the_live_pair_through_existing_readers
    h, t = run_session
    idle = Core::ScriptedInput.new(frames: {})
    30.times do
      h.update(t, idle)
      @j.update(t, idle)
      t += 10
    end
    m = menu.net_model(h, @wh)
    assert_equal %w[link ledger], m.keys.map(&:to_s)
    assert_includes m[:link], "SEAT 1"
    assert_includes m[:link], "TICKS #{h.ticks}"
    assert_includes m[:link], "D #{h.params.d}"
    assert(m[:link].any? { |r| r.start_with?("STALLS ") }, "stall counters row present")
    assert(m[:link].any? { |r| r.start_with?("DESYNCS ") })
    assert(m[:ledger].any? { |r| r.start_with?("LEVEL 1 ") }, "progression reader row")
    prog = @wh.progression
    assert_includes m[:ledger],
                    "LEVEL #{prog.level} · XP #{prog.xp}/#{prog.delta_e(prog.level + 1)}",
                    "XP carries its threshold (s56 merge fold — scale, not a bare count)"
    assert(m[:ledger].any? { |r| r =~ /\ARUN \d+:\d{2}\z/ }, "run span mm:ss")
    refute(m[:ledger].any? { |r| r =~ /\A(FIGHT|BANK|WIPE)/ }, "no beat row while no beat is live")
  end

  def test_ledger_beat_row_carries_kind_and_signed_net
    run_session
    # The REAL registered event vocabulary (EventBus::EVENTS pins :banked;
    # world.rb emits it from the station banking flow) — real bus, real
    # FightLedger handler, real flush.
    @wh.bus.emit(:banked, actor: nil, amount: 1, banked: 1)
    idle = Core::ScriptedInput.new(frames: {})
    @wh.tick({ 1 => idle, 2 => idle })
    beat = @wh.ledger_beat
    refute_nil beat, "staging: the banked event must raise a ledger beat"
    m = menu.net_model(@h, @wh)
    assert_includes m[:ledger], format("%s %+d", beat[:kind].to_s.upcase, beat[:net]),
                    "a live beat surfaces kind + signed net (the number IS the ledger)"
  end

  def test_close_bang_force_closes_and_clears_the_swallow
    input = Core::ScriptedInput.new(frames: { 0 => ["menu"] })
    input.update(0)
    menu.tick(input)
    assert menu.open?
    menu.close!
    refute menu.open?
    fresh = Core::ScriptedInput.new(frames: {})
    assert_same fresh, menu.route(fresh),
                "force-close leaves no stale swallow — the route contract holds"
  end
end
