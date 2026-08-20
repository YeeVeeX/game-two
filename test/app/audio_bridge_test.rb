require_relative "../test_helper"
require "core/data_store"
require "app/audio_bridge"
require "app/autopilot"
require "game/world"
require "net/state_digest"
require "digest"
require "json"
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

  def test_boot_maps_owner_cue_and_tears_down_clean
    skip "game-two-audio library not present — bridge device tests untestable here" unless lib_present?
    bridge, out = boot
    assert bridge.active?, out.string
    assert_match(/\AAUDIO on: device=0 sha=/, out.string)
    # unmapped real event: nil by design (audio is a sink)
    assert_nil bridge.handle_event(10, :attack_started, { pan: 0.5 })
    # owner-approved v1 cues start voices (owner originals only — no tones)
    bridge.handle_event(20, "banked")
    bridge.update(20)
    assert_equal 1, bridge.audio.active_voices
    # music boots into the owner's calm stem
    assert_equal "calm", bridge.audio.music_state
    # shutdown is idempotent and prints the teardown receipt
    bridge.shutdown
    bridge.shutdown
    assert_match(/AUDIO teardown clean/, out.string)
  end

  # Music derivation (music.json state_events): a real World bus emit of
  # challenger_engaged must request the combat state — data-driven, no code
  # mapping; fight_resolved returns to calm.
  def test_music_derivation_from_real_bus_events
    skip "game-two-audio library not present — bridge device tests untestable here" unless lib_present?
    world = Game::World.new(data, seed: 99)
    bridge, = boot
    bridge.attach(bus: world.bus, world: world)
    world.bus.emit(:challenger_engaged, actor: nil)
    world.bus.process
    assert bridge.audio.music_pending?, "challenger_engaged must request combat"
    bridge.shutdown
  end

  # -- v1.1 take rotation (pure paths — run everywhere) ---------------------

  def test_rotor_is_deterministic_and_never_repeats_adjacent
    names = %w[a b c d]
    seq1 = App::AudioBridge::VariantRotor.new(names).then { |r| Array.new(200) { r.next! } }
    seq2 = App::AudioBridge::VariantRotor.new(names).then { |r| Array.new(200) { r.next! } }
    assert_equal seq1, seq2, "same list must yield the same sequence (replay/netplay stability)"
    seq1.each_cons(2) { |a, b| refute_equal a, b, "immediate repeat breaks the anti-repetition ask" }
    assert_equal names.sort, seq1.uniq.sort, "every take must get airtime"
  end

  def test_rotor_single_take_is_identity
    rotor = App::AudioBridge::VariantRotor.new(["only"])
    assert_equal %w[only only only], Array.new(3) { rotor.next! }
  end

  def test_variants_table_is_fully_backed_by_cues_and_fixtures
    audio_dir = File.expand_path("../../data/audio", __dir__)
    variants = JSON.parse(File.read(File.join(audio_dir, "variants.json"))).fetch("events")
    cues = JSON.parse(File.read(File.join(audio_dir, "cues.json"))).fetch("cues")
    tones = JSON.parse(File.read(File.join(audio_dir, "fixtures.json"))).fetch("tones")
    events_carried = cues.values.map { |c| c.fetch("event") }
    variants.each do |event, synths|
      assert_operator synths.length, :>=, 2, "#{event}: rotation needs >= 2 takes"
      synths.each do |synth|
        assert_includes events_carried, synth, "#{synth} has no cue row"
      end
      refute_includes events_carried, event,
                      "#{event}: raw event must NOT carry a cue (double-fire would layer takes)"
    end
    cues.each_value do |cue|
      file = cue.fetch("file")
      assert tones.key?(file), "cue file #{file} missing from fixtures"
      path = File.join(audio_dir, tones[file].fetch("path"))
      assert File.exist?(path), "fixture file missing on disk: #{path}"
      assert_equal tones[file].fetch("sha256"), Digest::SHA256.file(path).hexdigest,
                   "sha mismatch: #{file}"
    end
  end

  # Real bus + real library: attack_hit fires exactly one rotated take cue
  # (raw event maps to nothing; the synthetic name starts the voice).
  def test_variant_rotation_fires_real_cues_through_the_bus
    skip "game-two-audio library not present — bridge device tests untestable here" unless lib_present?
    world = Game::World.new(data, seed: 7)
    bridge, = boot
    bridge.attach(bus: world.bus, world: world)
    3.times do |i|
      world.bus.emit(:attack_hit, actor: nil)
      world.bus.process
      bridge.update(world.frame + i)
    end
    assert_operator bridge.audio.active_voices, :>=, 1,
                    "rotated synthetic cues must reach the sink and start voices"
    bridge.shutdown
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
