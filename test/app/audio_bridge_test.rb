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

  def scripted_input(frames = {}) = Core::ScriptedInput.new(frames:)

  def drive(world, count, input: scripted_input, bridge: nil)
    count.times do
      input.update(world.frame)
      world.tick(input)
      bridge&.update(world.frame)
    end
  end

  # Real three-target whirlwind staging, matching WhirlwindTest's ring setup.
  def stage_three_target_whirl(world)
    step = data["balance/combat"][:kits][:striker][:step_frames]
    frames = (0...(step * 30)).to_h { |frame| [frame.to_s, ["right"]] }
    drive(world, step * 30, input: scripted_input(frames))
    assert_equal "district", world.zone_name

    striker = world.pack.members.find { |member| member.kit_name == :striker }
    world.pack.swap_next! until world.possessed.equal?(striker)
    striker.interrupt_action!
    striker.walker.teleport(12, 12)
    (world.pack.living - [striker]).each_with_index do |member, index|
      member.walker.teleport(2, 12 + index)
    end

    victims = world.humans.first(3)
    assert_equal 3, victims.length, "district must supply three real targets"
    world.humans.replace(victims)
    [[13, 12], [11, 12], [12, 11]].each_with_index do |tile, index|
      victims[index].heal_full!
      victims[index].walker.teleport(*tile)
      victims[index].stagger!(600)
    end
    [striker, victims]
  end

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

  def test_rotor_coalesces_one_family_per_tick_without_consuming_a_take
    names = %w[a b c d]
    expected = App::AudioBridge::VariantRotor.new(names)
    rotor = App::AudioBridge::VariantRotor.new(names)

    assert_equal expected.next!, rotor.next_for_tick(40)
    assert_nil rotor.next_for_tick(40), "same family + tick must not consume another take"
    assert_nil rotor.next_for_tick(40), "every duplicate in that tick stays coalesced"
    assert_equal expected.next!, rotor.next_for_tick(41),
                 "the next tick must receive the next deterministic take"
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

  def test_music_rotation_config_is_backed_by_music_states_and_fixtures
    audio_dir = File.expand_path("../../data/audio", __dir__)
    music = JSON.parse(File.read(File.join(audio_dir, "music.json")))
    tones = JSON.parse(File.read(File.join(audio_dir, "fixtures.json"))).fetch("tones")
    # Every music stem is fixture-backed — rotation live or dormant (ask 8
    # widened this to the superset: the rotation walk below only covers
    # states the rotor can reach).
    music.fetch("stems").each do |stem_id, stem|
      next if stem["file"].nil?
      assert tones.key?(stem.fetch("file")), "stem #{stem_id} file #{stem.fetch('file')} missing from fixtures"
    end
    rotation = JSON.parse(File.read(File.join(audio_dir, "variants.json")))["music_rotation"]
    if rotation.nil?
      # DORMANT (ask 8, 2026-08-20): the evolving 64 s loop carries calm;
      # the absent block is the recorded config, not a gap.
      assert_equal "msfx_calm_evolving_64s",
                   music.fetch("stems").fetch("stem_calm").fetch("file"),
                   "rotation dormant is only legal while calm carries the evolving loop"
      return
    end
    assert_operator rotation.fetch("period_ticks"), :>, 0
    assert_operator rotation.fetch("states").length, :>=, 2
    rotation.fetch("states").each do |state|
      stem_id = music.fetch("states").fetch(state) { flunk "rotation state #{state} missing from music.json" }.fetch("stem")
      stem = music.fetch("stems").fetch(stem_id) { flunk "stem #{stem_id} missing" }
      assert tones.key?(stem.fetch("file")), "stem file #{stem.fetch('file')} missing from fixtures"
      assert stem.fetch("loop"), "calm-family stems must loop"
    end
  end

  # Real library: rotation LIVE → the period boundary requests the next
  # variant; rotation DORMANT (block absent) → no tick may interrupt the
  # evolving loop — both branches are behavior, never a skip.
  def test_calm_rotation_requests_variant_at_period
    skip "game-two-audio library not present — bridge device tests untestable here" unless lib_present?
    world = Game::World.new(data, seed: 11)
    bridge, = boot
    bridge.attach(bus: world.bus, world: world)   # @music_state = initial "calm"
    rotation = JSON.parse(File.read(File.expand_path("../../data/audio/variants.json", __dir__)))["music_rotation"]
    if rotation.nil?
      [1919, 1920, 3840].each { |t| bridge.update(t) }
      refute bridge.audio.music_pending?,
             "rotation dormant: no tick may request a calm variant (the evolving loop plays uninterrupted)"
    else
      period = rotation.fetch("period_ticks")
      bridge.update(period - 1)
      refute bridge.audio.music_pending?, "no rotation off-period"
      bridge.update(period)
      assert bridge.audio.music_pending?, "period boundary must request a calm variant"
    end
    bridge.shutdown
  end

  # Real bus + real library: same-tick attack_hit emits coalesce into exactly
  # one rotated take cue (raw event maps to nothing; the synthetic name
  # starts the voice).
  def test_variant_rotation_fires_real_cues_through_the_bus
    skip "game-two-audio library not present — bridge device tests untestable here" unless lib_present?
    world = Game::World.new(data, seed: 7)
    bridge, = boot
    world.bus.process # drain the construction zone_entered emit pre-attach
    bridge.attach(bus: world.bus, world: world)
    3.times do |i|
      world.bus.emit(:attack_hit, actor: nil)
      world.bus.process
      bridge.update(world.frame + i)
    end
    assert_equal 1, bridge.audio.active_voices,
                 "three same-tick hits must reach the sink as ONE coalesced take voice"
    bridge.shutdown
  end

  # Regression for the owner's duplicate-trigger report: the sim keeps one
  # attack_hit fact per connected target, while presentation starts one hit
  # take for the whole same-family/same-tick batch.
  def test_real_whirl_keeps_three_hit_events_but_starts_one_hit_voice
    skip "game-two-audio library not present — bridge device tests untestable here" unless lib_present?
    world = Game::World.new(data, seed: 24)
    striker, = stage_three_target_whirl(world)
    bridge, = boot
    bridge.attach(bus: world.bus, world: world)
    hit_ticks = []
    voices_after_hit = []
    world.bus.subscribe(:attack_hit) do |_event|
      hit_ticks << world.frame
      voices_after_hit << bridge.audio.active_voices
    end

    assert striker.start_special(blocked: world.blocked_for(striker))
    special = data["balance/combat"][:kits][:striker][:special]
    drive(world, special[:windup_frames] + special[:active_frames] + 60, bridge:)

    assert_equal 3, hit_ticks.length, "sim truth remains one hit event per target"
    assert_equal 1, hit_ticks.uniq.length, "the three connections belong to one tick"
    assert_equal [2, 2, 2], voices_after_hit,
                 "one special voice + one coalesced hit voice; duplicates add no voices"
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
