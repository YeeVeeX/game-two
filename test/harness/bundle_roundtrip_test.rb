require_relative "../test_helper"
require "json"
require "digest"
require "tmpdir"
require "fileutils"
require "core/data_store"
require "core/input"
require "game/world"
require "net/protocol"
require "net/state_digest"
require_relative "../../harness/bundle_writer"
require_relative "../../harness/bundle_replay"

# E3a-T1 roundtrip (spec 2026-08-26-e3a-capture-contract.md §7): the P1
# emitter and the headless re-executor ship together because an emitter
# without its verifier is unverifiable. REAL sim, REAL files (tmp dirs) —
# no mocks. Both verify directions are exercised: a pristine bundle
# PASSES the two-run gate; a tampered mask byte flips it RED (file-level
# via member sha256, semantic via chain divergence when the sha is
# re-stamped by a consistent liar).
class BundleRoundtripTest < Minitest::Test
  FIXTURE = File.expand_path("../fixtures/bundle_roundtrip.json", __dir__)
  RAW = JSON.parse(File.read(FIXTURE), symbolize_names: true)
  DATA_DIR = File.expand_path("../../data", __dir__)
  NETPLAY = JSON.parse(File.read(File.expand_path("../../data/netplay.json", __dir__)),
                       symbolize_names: true)

  # Emission is the expensive half (130 real ticks + a tree fingerprint):
  # run it ONCE for the class; each test copies the pristine bundle into
  # its own tmp dir (verification writes a receipt, tamper tests mutate).
  def self.pristine
    @pristine ||= begin
      root = Dir.mktmpdir("bundle_emit")
      Minitest.after_run { FileUtils.remove_entry(root) }
      emit(out_root: root)
    end
  end

  # The replay runner's exact loop shape (input.update -> before_tick ->
  # World#tick -> after_tick), headless — the wiring inside the Gosu
  # window is proven by the ticket's CLI verify (a live runner run).
  def self.emit(out_root:)
    world = Game::World.new(Core::DataStore.new(DATA_DIR), seed: RAW.fetch(:seed))
    Harness.apply_start(world, RAW[:start])
    recorder = Harness::BundleRecorder.for_script(
      RAW, world: world, producer: "test: bundle_roundtrip"
    )
    input = Core::ScriptedInput.new(frames: Harness.expand_script(RAW))
    RAW.fetch(:run_until).times do |f|
      input.update(f)
      recorder.before_tick(input)
      world.tick(input)
      recorder.after_tick
    end
    recorder.write(out_root: out_root)
  end

  def with_copy
    Dir.mktmpdir("bundle_case") do |tmp|
      dir = File.join(tmp, File.basename(self.class.pristine))
      FileUtils.cp_r(self.class.pristine, dir)
      yield dir
    end
  end

  def read_json(dir, rel, symbolize: true)
    JSON.parse(File.binread(File.join(dir, rel)), symbolize_names: symbolize)
  end

  # --- emitter: the spec §2 members, byte-verified --------------------------

  def test_emitter_writes_the_spec_members_with_a_write_once_manifest
    dir = self.class.pristine
    %w[manifest.json input_log.json digest_chain.json preconditions.json].each do |rel|
      assert File.file?(File.join(dir, rel)), "#{rel} missing from the bundle"
    end

    manifest = read_json(dir, "manifest.json")
    assert_match(/\A\d{8}T\d{6}Z_p1_7\z/, manifest.fetch(:bundle_id))
    assert_equal "p1", manifest.fetch(:mode)
    assert_equal 1, manifest.fetch(:seats)
    assert_equal 7, manifest.fetch(:seed)
    assert_equal NETPLAY.fetch(:digest_every), manifest.fetch(:digest_every),
                 "digest_every must come from data/netplay.json — the ONE cadence source"
    assert_equal Net::StateDigest::DIGEST_VERSION, manifest.fetch(:digest_version)
    assert_equal RAW.fetch(:run_until), manifest.fetch(:ticks_executed)
    assert_equal "run_until", manifest.fetch(:end_reason)
    assert_match(/\A\h{32}\z/, manifest.fetch(:fingerprint_md5),
                 "fingerprint_md5 is REQUIRED (the handshake identity)")
    refute_empty manifest.fetch(:producer)
    refute_empty manifest.fetch(:machine)

    manifest.fetch(:members).each do |rel, sha|
      assert_equal sha, Digest::SHA256.hexdigest(File.binread(File.join(dir, rel.to_s))),
                   "manifest sha256 for #{rel} does not match the bytes on disk"
    end

    masks = read_json(dir, "input_log.json").fetch(:masks)
    assert_equal RAW.fetch(:run_until), masks.length, "one seat-ordered mask array per tick"
    right = 1 << Net::Protocol::ACTIONS.index(:right)
    attack = 1 << Net::Protocol::ACTIONS.index(:attack)
    assert_equal [right], masks[0], "tick 0 holds right (the fixture's hold)"
    assert_equal attack, masks[50][0] & attack, "tick 50 holds attack"
    assert_equal [0], masks[129], "the idle tail records zero masks (they ARE consumed masks)"

    chain_doc = read_json(dir, "digest_chain.json")
    every = NETPLAY.fetch(:digest_every)
    assert_equal [every, every * 2], chain_doc.fetch(:chain).map(&:first),
                 "cadence windows for a 130-tick run at every=#{every}"
    chain_doc.fetch(:chain).each { |(_, md5)| assert_match(/\A\h{32}\z/, md5) }
    assert_equal RAW.fetch(:run_until), chain_doc.fetch(:terminal).first,
                 "terminal snapshot digest covers the trailing partial window"

    assert_equal({ seats: 1, seed: 7, scenario: "world", start: { banked: 3 } },
                 read_json(dir, "preconditions.json"),
                 "preconditions carry the script's start object VERBATIM (grill D6)")
  end

  def test_write_is_write_once
    world = Game::World.new(Core::DataStore.new(DATA_DIR), seed: RAW.fetch(:seed))
    recorder = Harness::BundleRecorder.for_script(
      RAW, world: world, producer: "test: write-once"
    )
    Dir.mktmpdir("bundle_once") do |tmp|
      at = Time.utc(2026, 8, 26, 12, 0, 0)
      recorder.write(out_root: tmp, now: at)
      err = assert_raises(Harness::BundleRefused) { recorder.write(out_root: tmp, now: at) }
      assert_match(/already exists/, err.message)
    end
  end

  # --- re-executor: PASS direction ------------------------------------------

  def test_two_run_verification_gate_passes_a_pristine_bundle
    with_copy do |dir|
      manifest_before = File.binread(File.join(dir, "manifest.json"))
      receipt = Harness::BundleReplay.verify(dir, runs: 2)

      assert_equal "PASS", receipt[:verdict]
      assert_equal 2, receipt[:runs]
      assert_nil receipt[:first_divergent_window]
      assert_equal read_json(dir, "manifest.json").fetch(:fingerprint_md5),
                   receipt[:fingerprint_at_verification]

      on_disk = read_json(dir, "verification.json")
      assert_equal "PASS", on_disk.fetch(:verdict), "receipt must be written beside the bundle"
      assert_equal manifest_before, File.binread(File.join(dir, "manifest.json")),
                   "verification must never mutate the production manifest (grill D7)"
    end
  end

  # --- re-executor: RED directions ------------------------------------------

  def test_tampered_mask_byte_without_restamp_is_red_via_member_sha
    with_copy do |dir|
      log = read_json(dir, "input_log.json")
      log[:masks][10] = [log[:masks][10][0] ^ (1 << Net::Protocol::ACTIONS.index(:attack))]
      File.binwrite(File.join(dir, "input_log.json"), JSON.pretty_generate(log) << "\n")

      receipt = Harness::BundleReplay.verify(dir, runs: 2)
      assert_equal "RED", receipt[:verdict]
      assert_equal 0, receipt[:runs], "a lying member is RED before any tick executes"
      assert_match(/member sha256 mismatch/, receipt[:reason])
      assert_match(/input_log\.json/, receipt[:reason])
      assert_match(/\A\h{32}\z/, receipt[:fingerprint_at_verification].to_s,
                   "even a member-mismatch RED names the tree that judged it (review s83)")
      assert_equal "RED", read_json(dir, "verification.json").fetch(:verdict)
    end
  end

  def test_tampered_mask_byte_with_restamped_sha_is_red_at_the_first_divergent_window
    with_copy do |dir|
      log_path = File.join(dir, "input_log.json")
      log = read_json(dir, "input_log.json")
      log[:masks][10] = [log[:masks][10][0] ^ (1 << Net::Protocol::ACTIONS.index(:attack))]
      File.binwrite(log_path, JSON.pretty_generate(log) << "\n")
      # The consistent liar: re-stamp the member sha so file integrity passes.
      manifest = read_json(dir, "manifest.json")
      manifest[:members][:"input_log.json"] = Digest::SHA256.hexdigest(File.binread(log_path))
      File.binwrite(File.join(dir, "manifest.json"), JSON.pretty_generate(manifest) << "\n")

      receipt = Harness::BundleReplay.verify(dir, runs: 2)
      assert_equal "RED", receipt[:verdict]
      assert_equal 2, receipt[:runs]
      assert_match(/diverged at window/, receipt[:reason])
      window = receipt[:first_divergent_window]
      assert_equal NETPLAY.fetch(:digest_every), window[:tick],
                   "a tick-10 tamper must be localized to the FIRST cadence window (grill D4)"
      refute_equal window[:recorded], window[:runs].first,
                   "the recorded and re-executed window md5s must actually differ"
    end
  end

  # --- refusals: NAMED, never a verdict --------------------------------------

  def test_fingerprint_mismatch_refuses_named_with_both_values_and_no_receipt
    with_copy do |dir|
      manifest = read_json(dir, "manifest.json")
      manifest[:fingerprint_md5] = "0" * 32
      File.binwrite(File.join(dir, "manifest.json"), JSON.pretty_generate(manifest) << "\n")

      err = assert_raises(Harness::BundleReplay::Refusal) do
        Harness::BundleReplay.verify(dir, runs: 2)
      end
      assert_match(/bundle #{'0' * 32}/, err.message, "refusal must name the bundle's value")
      assert_match(/tree \h{32}/, err.message, "refusal must name the live tree's value")
      refute File.exist?(File.join(dir, "verification.json")),
             "a refusal is not a verdict — no receipt may be written"
    end
  end

  def test_bundle_key_refuses_non_world_scenarios_named
    err = assert_raises(Harness::BundleRefused) do
      Harness::BundleRecorder.for_script(
        { scenario: "menu", run_until: 10 }, world: nil, producer: "test"
      )
    end
    assert_match(/"world" scenario only/, err.message)
    assert_match(/menu/, err.message)
  end

  def test_bundle_key_refuses_actions_outside_the_mask_vocabulary_named
    raw = { scenario: "world", run_until: 10, hold: { confirm: [[0, 5]] } }
    err = assert_raises(Harness::BundleRefused) do
      Harness::BundleRecorder.for_script(raw, world: nil, producer: "test")
    end
    assert_match(/outside the mask vocabulary/, err.message)
    assert_match(/confirm/, err.message)
  end
end
