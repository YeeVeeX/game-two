require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/session"
require "app/netplay_overlay"

# v17 increment 7 — the netplay overlay's pure state resolution (#flags)
# against REAL sessions over real loopback (no mocks; #draw itself is
# gated by the Rule-2 netplay captures). Fake caller-fed clock throughout.
class NetplayOverlayTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["netplay"]
  HELLO = { version: 1, ruby: "3.4.10", platform: "test", fingerprint: "d" * 32,
            digest_version: 1 }.freeze

  def overlay = @overlay ||= App::NetplayOverlay.new(display: DATA["display"])

  def sessions
    @h = Net::Session.host(bind: "127.0.0.1", port: 0, config: CFG,
                           seed: 7, epoch: 99, hello: HELLO.dup)
    @j = Net::Session.join(host: "127.0.0.1", port: @h.port, config: CFG, hello: HELLO.dup)
    [@h, @j]
  end

  def teardown
    [@h, @j].each do |s|
      next if s.nil? || s.ended?
      s.quit!(10**12)
      s.update(10**12 + CFG[:drain_timeout_ms] + 1)
    end
  end

  def run_session(step_ms: 10)
    h, j = sessions
    t = 0
    200.times do
      break if h.params_known? && j.params_known?
      h.update(t)
      j.update(t)
      t += step_ms
    end
    @wh = Game::World.new(DATA, seed: h.params.seed, seats: 2)
    @wj = Game::World.new(DATA, seed: j.params.seed, seats: 2)
    h.attach(@wh)
    j.attach(@wj)
    50.times do
      break if h.running? && j.running?
      h.update(t)
      j.update(t)
      t += step_ms
    end
    [h, j, t]
  end

  def idle = @idle ||= Core::ScriptedInput.new(frames: {})

  def test_hosting_alone_is_the_hosting_screen_with_the_port
    h = Net::Session.host(bind: "127.0.0.1", port: 0, config: CFG,
                          seed: 7, epoch: 99, hello: HELLO.dup)
    @h = h
    h.update(0)
    f = overlay.flags(h, nil)
    assert_equal :hosting, f[:screen]
    assert_operator h.port, :>, 0, "the hosting screen prints a live port"
  end

  def test_handshake_phases_read_as_connecting
    h, j = sessions
    h.update(0)
    j.update(0) # joiner sent HELLO, host accepted
    h.update(10)
    refute_equal :listen, h.phase
    assert_equal :connecting, overlay.flags(h, nil)[:screen]
    assert_equal :connecting, overlay.flags(j, nil)[:screen]
  end

  def test_clean_run_shows_no_screen_and_no_cues
    h, _j, = run_session
    f = overlay.flags(h, @wh)
    assert_nil f[:screen]
    assert_nil f[:stall_ms]
    refute f[:link_slow], "10ms probe rounds derive a fast link"
    refute f[:no_body]
    assert_nil f[:gate_wait]
  end

  def test_slow_probes_flag_link_slow_only_near_session_start
    h, j, t = run_session(step_ms: 400)
    assert overlay.flags(h, @wh)[:link_slow], "clamped D flags LINK SLOW at start"
    in1 = Core::ScriptedInput.new(frames: {})
    net_banner_frames = DATA["display"][:net_banner_frames]
    (net_banner_frames + CFG[:delay][:max] + 5).times do
      h.update(t, in1)
      j.update(t, idle)
      t += 10
    end
    refute overlay.flags(h, @wh)[:link_slow], "the banner yields after net_banner_frames ticks"
  end

  def test_stall_past_warn_ms_feeds_the_stall_cue
    h, _j, t = run_session
    30.times do |i|
      h.update(t + i * (CFG[:stall_warn_ms] / 10), idle)
      f = overlay.flags(h, @wh)
      if f[:stall_ms]
        assert_operator f[:stall_ms], :>=, CFG[:stall_warn_ms]
        return
      end
    end
    flunk "frozen peer never produced the stall cue"
  end

  def test_waiting_seat_reads_no_body
    h, _j, = run_session
    lobber = @wh.pack.members.find { |m| !@wh.controlled?(m) }
    killer = @wh.possessed(2)
    [lobber, @wh.possessed(1)].each do |b|
      b.take_hit(damage: b.hp, attacker: killer) until b.dead?
    end
    12.times { @wh.tick({ 1 => idle, 2 => idle }) } # drain hitstop; forced swap resolves
    assert_nil @wh.possessed(1), "staging: seat 1 waits"
    assert overlay.flags(h, @wh)[:no_body]
  end

  def test_gate_wait_tile_feeds_the_gate_cue
    h, _j, = run_session
    @wh.possessed(2).walker.teleport(20, 13)
    @wh.possessed(1).walker.teleport(29, 8)
    @wh.tick({ 1 => idle, 2 => idle })
    assert_equal [29, 8], overlay.flags(h, @wh)[:gate_wait]
  end

  def test_quit_end_shows_partner_left_desync_and_conn_lost_show_theirs
    h, j, t = run_session
    h.quit!(t)
    20.times do
      break if h.ended? && j.ended?
      h.update(t)
      j.update(t)
      t += 10
    end
    # J6-C (D14): quit-ended maps to :partner_left UNCONDITIONALLY — in the
    # live game only the abandoned seat ever draws a post-end frame (the
    # initiator's window closes first), so the notice reaches exactly the
    # seat that was left behind.
    assert_equal :partner_left, overlay.flags(h, @wh)[:screen],
                 "the abandoned seat is told WHY its world froze"
    assert_equal :partner_left, overlay.flags(j, @wj)[:screen]

    h2, j2, t2 = begin
      teardown
      run_session
    end
    @wh.pack.bank!(1) # diverge the host world only
    in_idle = idle
    300.times do
      break if h2.ended? && j2.ended?
      h2.update(t2, in_idle)
      j2.update(t2, in_idle)
      t2 += 10
    end
    assert_equal :desync, overlay.flags(h2, @wh)[:screen]

    h3, j3, t3 = begin
      teardown
      run_session
    end
    j3.sever!
    50.times do
      break if h3.ended?
      h3.update(t3, in_idle)
      t3 += 10
    end
    assert_equal :conn_lost, overlay.flags(h3, @wh)[:screen]
  end
end
