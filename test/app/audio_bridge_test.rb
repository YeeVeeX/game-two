require_relative "../test_helper"
require "core/data_store"
require "app/audio_bridge"
require "app/autopilot"
require "game/world"
require "net/state_digest"
require "stringio"
require "fileutils"
require "tmpdir"

# M5a audio bridge — integration tests against the REAL sibling library
# (real DLL, real render graph in the library's own noDevice gate mode; no
# mocks — law 5). On a machine without the library (CI, Junior) the
# device-path tests SKIP LOUDLY; the refusal/absence paths run everywhere
# (they need only real files in a temp tree).
class AudioBridgeTest < Minitest::Test
  LIB = App::AudioBridge::LIB_ROOT

  def lib_present? = File.exist?(File.join(LIB, "vendor/miniaudio.dll"))

  def boot(device: 0, smoke: false, bot: false, lib_root: LIB)
    out = StringIO.new
    bridge = App::AudioBridge.boot(lib_root:, device:, smoke:, bot:, out:)
    [bridge, out]
  end

  def data = @data ||= Core::DataStore.new(File.expand_path("../../data", __dir__))

  # -- absence / refusal paths (run everywhere; real files only) -----------

  def test_absent_library_is_a_named_no_op
    Dir.mktmpdir do |dir|
      bridge, out = boot(lib_root: File.join(dir, "nope"))
      assert_instance_of App::AudioBridge::Null, bridge
      assert_match(/\AAUDIO off: library not present/, out.string)
      # every seam is callable and silent
      assert_nil bridge.update(1)
      assert_nil bridge.handle_event(1, "toll_paid")
      assert_nil bridge.shutdown
      refute bridge.active?
    end
  end

  def test_vendor_sha_mismatch_refuses_named
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "vendor"))
      File.binwrite(File.join(dir, "vendor/miniaudio.dll"), "not the pinned dll")
      File.write(File.join(dir, "vendor/VERSION"),
                 "#{'0' * 64}  miniaudio.dll\n")
      bridge, out = boot(lib_root: dir)
      assert_instance_of App::AudioBridge::Null, bridge
      assert_match(/\AAUDIO refused: vendor dll sha mismatch/, out.string)
    end
  end

  def test_bot_seat_never_boots_audio
    bridge, out = boot(bot: true)
    assert_instance_of App::AudioBridge::Null, bridge
    assert_match(/\AAUDIO off: bot seat/, out.string)
  end

  # -- real-library paths (noDevice — the library's own gate mode) ---------

  def test_boot_maps_placeholder_cue_and_tears_down_clean
    skip "game-two-audio library not present — bridge device tests untestable here" unless lib_present?
    bridge, out = boot
    assert bridge.active?, out.string
    assert_match(/\AAUDIO on: device=0 sha=/, out.string)
    # unmapped real event: nil by design (audio is a sink)
    assert_nil bridge.handle_event(10, :attack_started, { pan: 0.5 })
    # identity-mapped placeholder cue starts a voice
    bridge.handle_event(20, "toll_paid")
    bridge.update(20)
    # shutdown is idempotent and prints the teardown receipt
    bridge.shutdown
    bridge.shutdown
    assert_match(/AUDIO teardown clean/, out.string)
  end

  # -- pure-sink proof: attached audio changes NOTHING in the sim ----------
  # Two real Worlds, same seed, same seeded autopilot input; one carries the
  # bridge (noDevice, real DLL). StateDigest windows must stay identical —
  # the mechanical statement of law 2 (audio never enters sim/saves/netplay).
  def test_attached_bridge_is_sim_invisible
    skip "game-two-audio library not present — bridge device tests untestable here" unless lib_present?
    digests = [false, true].map do |with_audio|
      world = Game::World.new(data, seed: 4242)
      digest = Net::StateDigest.new(world:, every: 60)
      bridge = nil
      if with_audio
        bridge, = boot
        assert bridge.active?
        bridge.attach(bus: world.bus, world: world)
      end
      input = App::Autopilot.new(seed: 777, quit_tick: 1 << 30)
      windows = []
      300.times do
        input.update(world.frame)
        world.tick(input)
        bridge&.update(world.frame)
        w = digest.after_tick
        windows << w.md5 if w
      end
      bridge&.shutdown
      assert_equal 5, windows.size
      windows
    end
    assert_equal digests[0], digests[1]
  end
end
