require_relative "../test_helper"
require "core/data_store"
require "game/world"
require "net/session"
require "app/autopilot"

# v18 session-8 soak (brief D1 wiring proof): bots drive BOTH seats of
# two REAL Worlds + two REAL Sessions over real loopback TCP in ONE
# process (the increment-6 pattern, no threads, fake clock). The session
# samples the autopilot through the exact keyboard seam (update(t) +
# Protocol.mask once per executed tick) — if the bot were tick-impure or
# emitted an illegal mask, the digest windows would catch it as a desync
# right here. No mocks: this IS the layer under test.
class AutopilotSessionTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["netplay"]
  HELLO = { version: 2, ruby: "3.4.10", platform: "test", fingerprint: "c" * 32,
            digest_version: 1 }.freeze

  def teardown
    [@h, @j].each do |s|
      next if s.nil? || s.ended?
      s.quit!(10**12)
      s.update(10**12 + CFG[:drain_timeout_ms] + 1)
    end
  end

  def handshake_and_run
    @h = Net::Session.host(player_id: "bot-1", bind: "127.0.0.1", port: 0, config: CFG,
                           seed: 7, epoch: 3, hello: HELLO.dup)
    @j = Net::Session.join(player_id: "bot-2", host: "127.0.0.1", port: @h.port, config: CFG, hello: HELLO.dup)
    t = 0
    400.times do
      break if @h.params_known? && @j.params_known?
      @h.update(t)
      @j.update(t)
      t += 10
    end
    flunk "handshake never produced params" unless @h.params_known? && @j.params_known?
    @h.attach(Game::World.new(DATA, seed: @h.params.seed, seats: 2))
    @j.attach(Game::World.new(DATA, seed: @j.params.seed, seats: 2))
    50.times do
      break if @h.running? && @j.running?
      @h.update(t)
      @j.update(t)
      t += 10
    end
    flunk "START barrier never resolved" unless @h.running? && @j.running?
    t
  end

  def test_bots_drive_a_real_session_to_clean_quit_without_desync
    t = handshake_and_run
    host_bot = App::Autopilot.new(seed: 21, quit_tick: 620)
    join_bot = App::Autopilot.new(seed: 22, quit_tick: 5000) # backstop only
    quit_sent = false
    4000.times do
      break if @h.ended? && @j.ended?
      if !@h.ended? && !quit_sent && host_bot.quit?(@h.ticks)
        quit_sent = true
        @h.quit!(t)
      end
      @h.update(t, host_bot) unless @h.ended?
      @j.update(t, join_bot) unless @j.ended?
      t += 8
    end
    assert @h.ended? && @j.ended?, "sessions never ended (h=#{@h.phase} j=#{@j.phase})"
    assert_equal :quit, @h.reason, "host: #{@h.telemetry_line}"
    assert_equal :quit, @j.reason, "joiner: #{@j.telemetry_line}"
    assert_operator @h.ticks, :>=, 620, "host quit before the bot's quit_tick"
    assert_equal 0, @h.lockstep.desyncs, "bot input desynced the sims: #{@h.telemetry_line}"
    assert_equal 0, @j.lockstep.desyncs
    assert_operator @h.digest_log.length, :>=, 10, "too few digest windows crossed"
  end
end
