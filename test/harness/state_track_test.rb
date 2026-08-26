require_relative "../test_helper"
require "json"
require "digest"
require "tmpdir"
require "fileutils"
require "core/data_store"
require "core/input"
require "game/world"
require "net/lockstep"
require "net/protocol"
require_relative "../../harness/bundle_writer"
require_relative "../../harness/bundle_replay"

# E3a-T2 (spec 2026-08-26-e3a-capture-contract.md §5 + §7): the Mode T
# state-track emitter. REAL sim, REAL files — no mocks. The track is
# emitted through the re-executor's verification gate (sampler rides
# run 1), so every test here exercises the same path the CLI ships:
# verify PASS -> tracks/<name>.json + sidecar; RED -> no track.
class StateTrackTest < Minitest::Test
  FIXTURE = File.expand_path("../fixtures/bundle_roundtrip.json", __dir__)
  RAW = JSON.parse(File.read(FIXTURE), symbolize_names: true)
  DATA_DIR = File.expand_path("../../data", __dir__)
  COMBAT = JSON.parse(File.read(File.expand_path("../../data/balance/combat.json", __dir__)),
                      symbolize_names: true)
  WINDOW = (5..75) # covers mid-walk (hold right 0..40) + the full tick-50 attack cycle

  ATTACK_STATES = %w[idle windup active recovery].freeze

  def self.pristine
    @pristine ||= begin
      root = Dir.mktmpdir("track_emit")
      Minitest.after_run { FileUtils.remove_entry(root) }
      world = Game::World.new(Core::DataStore.new(DATA_DIR), seed: RAW.fetch(:seed))
      Harness.apply_start(world, RAW[:start])
      recorder = Harness::BundleRecorder.for_script(
        RAW, world: world, producer: "test: state_track"
      )
      input = Core::ScriptedInput.new(frames: Harness.expand_script(RAW))
      RAW.fetch(:run_until).times do |f|
        input.update(f)
        recorder.before_tick(input)
        world.tick(input)
        recorder.after_tick
      end
      recorder.write(out_root: root)
    end
  end

  # One emitted track shared by the read-only assertions (emission = a
  # full two-run verification; run it once for the class).
  def self.tracked
    @tracked ||= begin
      tmp = Dir.mktmpdir("track_case")
      Minitest.after_run { FileUtils.remove_entry(tmp) }
      dir = File.join(tmp, File.basename(pristine))
      FileUtils.cp_r(pristine, dir)
      out = Harness::BundleReplay.emit_track(dir, range: WINDOW)
      { dir: dir, out: out,
        doc: JSON.parse(File.binread(out[:track]), symbolize_names: true) }
    end
  end

  def with_copy
    Dir.mktmpdir("track_tmp") do |tmp|
      dir = File.join(tmp, File.basename(self.class.pristine))
      FileUtils.cp_r(self.class.pristine, dir)
      yield dir
    end
  end

  def doc = self.class.tracked[:doc]

  def manifest
    JSON.parse(File.binread(File.join(self.class.tracked[:dir], "manifest.json")),
               symbolize_names: true)
  end

  # --- top level: schema "1", RUNTIME class, provenance ----------------------

  def test_top_level_schema_runtime_class_and_bundle_id_provenance
    assert_equal "1", doc.fetch(:schema_version)
    assert_equal "RUNTIME", doc.fetch(:class)
    assert_equal Net::Lockstep::TICK_MS, doc.fetch(:tick_ms),
                 "tick_ms is Net::Lockstep::TICK_MS verbatim (spec §5 correction 2)"
    refute_empty doc.fetch(:zone)

    view = doc.fetch(:view)
    assert_equal [0, 0], view.fetch(:origin_px)
    assert_kind_of Integer, view.fetch(:width)
    assert_kind_of Integer, view.fetch(:height)
    assert view.fetch(:width).positive? && view.fetch(:height).positive?

    prov = doc.fetch(:provenance)
    assert_equal "RUNTIME", prov.fetch(:class), "provenance.class must equal track class"
    assert_equal manifest.fetch(:bundle_id), prov.fetch(:bundle_id),
                 "a track never self-certifies — it names its bundle (spec §5 correction 4)"
    refute_empty prov.fetch(:producer)
    assert_match(/verdict PASS/, prov.fetch(:statement))

    roster = doc.fetch(:creatures)
    refute_empty roster
    roster.each do |c|
      refute_empty c.fetch(:name)
      assert_includes %w[pack human], c.fetch(:faction)
      refute_empty c.fetch(:kit)
    end
    assert_includes roster.map { |c| c.fetch(:faction) }, "pack"
  end

  def test_verification_receipt_passed_and_track_written_beside_bundle
    out = self.class.tracked[:out]
    assert_equal "PASS", out[:receipt][:verdict]
    assert_equal 2, out[:receipt][:runs]
    assert_equal File.join(self.class.tracked[:dir], "tracks", "t5-75.json"), out[:track]
    assert File.file?(out[:track])
  end

  # --- per-tick records: leaf types, consecutive frames, masks ---------------

  def test_leaf_types_every_record
    doc.fetch(:ticks).each do |t|
      assert_kind_of Integer, t.fetch(:frame)
      refute_empty t.fetch(:creatures)
      t.fetch(:creatures).each do |name, r|
        ctx = "#{name}@#{t[:frame]}"
        %i[tile_x tile_y tween_left tween_total state_frames hp iframes].each do |k|
          assert_kind_of Integer, r.fetch(k), "#{ctx} #{k}"
        end
        assert_kind_of Numeric, r.fetch(:px), ctx
        assert_kind_of Numeric, r.fetch(:py), ctx
        facing = r.fetch(:facing)
        assert_equal 2, facing.length, ctx
        facing.each { |v| assert_kind_of Integer, v, ctx }
        assert_includes ATTACK_STATES, r.fetch(:attack_state), ctx
        action = r.fetch(:current_action)
        assert action.nil? || action.is_a?(String), "#{ctx} current_action"
        assert_includes [true, false], r.fetch(:possessed), ctx
      end
      t.fetch(:masks).each do |seat, mask|
        assert_match(/\A\d+\z/, seat.to_s)
        assert_kind_of Integer, mask
      end
    end
  end

  def test_frames_are_consecutive_and_exactly_the_requested_window
    assert_equal WINDOW.to_a, doc.fetch(:ticks).map { |t| t.fetch(:frame) }
  end

  def test_roster_is_the_union_of_per_tick_creature_keys
    observed = doc.fetch(:ticks).flat_map { |t| t.fetch(:creatures).keys }.uniq.sort
    assert_equal observed, doc.fetch(:creatures).map { |c| c.fetch(:name).to_sym }.sort
  end

  def test_masks_are_the_input_log_slice_that_produced_each_frame
    log = JSON.parse(
      File.binread(File.join(self.class.tracked[:dir], "input_log.json")),
      symbolize_names: true
    ).fetch(:masks)
    doc.fetch(:ticks).each do |t|
      expected = log[t.fetch(:frame) - 1].each_with_index.to_h { |m, i| [(i + 1).to_s.to_sym, m] }
      assert_equal expected, t.fetch(:masks),
                   "record frame=#{t[:frame]} must carry the masks consumed by the " \
                   "tick that produced it (input_log[frame-1])"
    end
  end

  def test_exactly_one_possessed_pack_body_per_tick
    factions = doc.fetch(:creatures).to_h { |c| [c.fetch(:name).to_sym, c.fetch(:faction)] }
    doc.fetch(:ticks).each do |t|
      possessed = t.fetch(:creatures).select { |_, r| r.fetch(:possessed) }.keys
      assert_equal 1, possessed.length, "seats=1: exactly one possessed body at #{t[:frame]}"
      assert_equal "pack", factions.fetch(possessed.first)
    end
  end

  # --- constants: per-kit, from combat.json at the fingerprint ---------------

  def test_constants_per_kit_match_combat_json
    constants = doc.fetch(:constants)
    roster_kits = doc.fetch(:creatures).map { |c| c.fetch(:kit) }.uniq.sort
    assert_equal roster_kits, constants.keys.map(&:to_s).sort,
                 "constants cover exactly the roster's kits (per-kit — spec §5 correction 3)"
    constants.each do |kit, block|
      src = COMBAT.fetch(:kits).fetch(kit.to_sym)
      assert_equal src.fetch(:step_frames), block.fetch(:step_frames), kit
      %i[windup_frames active_frames recovery_frames].each do |k|
        assert_equal src.fetch(:attack).fetch(k), block.fetch(k),
                     "#{kit} #{k} comes from the kit's attack sub-object"
      end
      assert_equal %i[step_frames windup_frames active_frames recovery_frames].sort,
                   block.keys.sort,
                   "the px pair is out of schema (draft-1's windup_px/active_px dropped)"
    end
  end

  # --- the attack cycle + windowed mid-phase start ---------------------------

  def test_attack_cycle_phases_ride_the_track_with_positional_state_frames
    states = doc.fetch(:ticks).filter_map do |t|
      r = t.fetch(:creatures).values.find { |c| c.fetch(:possessed) }
      [t.fetch(:frame), r.fetch(:attack_state), r.fetch(:state_frames)] if r
    end
    phases = states.map { |_, s, _| s }.uniq
    %w[windup active recovery].each do |phase|
      assert_includes phases, phase,
                      "the fixture's tick-50 attack must show #{phase} inside #{WINDOW}"
    end
    windup = states.select { |_, s, _| s == "windup" }
    assert_operator windup.length, :>=, 2
    assert_equal windup.map { |_, _, f| f }, windup.map { |_, _, f| f }.sort.reverse,
                 "state_frames counts down inside a phase (the positional timeline index)"
  end

  def test_windowed_track_starting_mid_phase_is_self_describing
    mid = doc.fetch(:ticks).find do |t|
      r = t.fetch(:creatures).values.find { |c| c.fetch(:possessed) }
      r && r.fetch(:tween_left).positive? && r.fetch(:tween_left) < r.fetch(:tween_total)
    end
    refute_nil mid, "the hold-right span must contain a mid-tween tick"

    start = mid.fetch(:frame)
    out = Harness::BundleReplay.emit_track(
      self.class.tracked[:dir], range: (start..[start + 10, RAW.fetch(:run_until)].min),
      name: "midphase"
    )
    first = JSON.parse(File.binread(out[:track]), symbolize_names: true)
            .fetch(:ticks).first
    assert_equal start, first.fetch(:frame)
    r = first.fetch(:creatures).values.find { |c| c.fetch(:possessed) }
    assert r.fetch(:tween_left).positive? && r.fetch(:tween_left) < r.fetch(:tween_total),
           "a window may open mid-phase; tween/state counters make it self-describing"
  end

  # --- artifact integrity -----------------------------------------------------

  def test_sidecar_sha256_matches_the_track_bytes
    path = self.class.tracked[:out][:track]
    hex, named = File.binread("#{path}.sha256").split
    assert_equal Digest::SHA256.hexdigest(File.binread(path)), hex
    assert_equal File.basename(path), named
  end

  def test_two_emissions_from_copies_are_byte_identical
    a = with_copy do |dir|
      File.binread(Harness::BundleReplay.emit_track(dir, range: (10..20))[:track])
    end
    b = with_copy do |dir|
      File.binread(Harness::BundleReplay.emit_track(dir, range: (10..20))[:track])
    end
    assert_equal a, b, "the track artifact is deterministic — no timestamps, no machine state"
  end

  # --- refusals + the RED gate ------------------------------------------------

  def test_range_outside_produced_frames_refuses_named_before_any_execution
    err = assert_raises(Harness::StateTrack::Refused) do
      Harness::BundleReplay.emit_track(self.class.tracked[:dir], range: (0..5))
    end
    assert_match(/frame 0 is constructor state/, err.message)

    err = assert_raises(Harness::StateTrack::Refused) do
      Harness::BundleReplay.emit_track(self.class.tracked[:dir], range: (100..2000))
    end
    assert_match(/1\.\.#{RAW.fetch(:run_until)}/, err.message)
  end

  def test_track_names_are_write_once_and_validated
    err = assert_raises(Harness::StateTrack::Refused) do
      Harness::BundleReplay.emit_track(self.class.tracked[:dir], range: WINDOW)
    end
    assert_match(/already exists/, err.message, "t5-75 was emitted by the class helper")

    err = assert_raises(Harness::StateTrack::Refused) do
      Harness::BundleReplay.emit_track(self.class.tracked[:dir], range: (10..20),
                                       name: "../escape")
    end
    assert_match(/name/, err.message)
  end

  def test_red_bundle_emits_no_track
    with_copy do |dir|
      log_path = File.join(dir, "input_log.json")
      log = JSON.parse(File.binread(log_path), symbolize_names: true)
      log[:masks][10] = [log[:masks][10][0] ^ (1 << Net::Protocol::ACTIONS.index(:attack))]
      File.binwrite(log_path, JSON.pretty_generate(log) << "\n")
      manifest_path = File.join(dir, "manifest.json")
      m = JSON.parse(File.binread(manifest_path), symbolize_names: true)
      m[:members][:"input_log.json"] = Digest::SHA256.hexdigest(File.binread(log_path))
      File.binwrite(manifest_path, JSON.pretty_generate(m) << "\n")

      out = Harness::BundleReplay.emit_track(dir, range: (10..20))
      assert_equal "RED", out[:receipt][:verdict]
      assert_nil out[:track], "a track is emitted ONLY from a verified bundle (spec §5)"
      refute File.exist?(File.join(dir, "tracks")),
             "no tracks/ dir may appear beside a RED verdict"
    end
  end

  # --- zone-crossing refusal (sampler bookkeeping, real worlds) ---------------

  def test_a_window_that_crosses_a_zone_transition_refuses_named
    data = Core::DataStore.new(DATA_DIR)
    sampler = Harness::StateTrack::Sampler.new(range: (1..10))
    world_a = Game::World.new(data, seed: 7)
    world_a.tick(Core::NullInput.new)
    sampler.call(world_a, [0])
    world_b = Game::World.new(data, seed: 7)
    Harness.apply_start(world_b, { zone: "low_quay" })
    world_b.tick(Core::NullInput.new)
    sampler.call(world_b, [0])

    refute_nil sampler.zone_crossing
    err = assert_raises(Harness::StateTrack::Refused) do
      Harness::StateTrack.write(
        Dir.tmpdir, sampler: sampler,
        manifest: { bundle_id: "test" }, receipt: { runs: 2, verdict: "PASS" },
        root: File.expand_path("../..", __dir__), range: (1..10)
      )
    end
    assert_match(/crosses a zone transition/, err.message)
    assert_match(/split the window/, err.message)
  end
end
