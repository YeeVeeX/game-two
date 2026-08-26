require "json"
require "digest"
require "fileutils"
require "net/protocol"
require "net/state_digest"
require "net/fingerprint"
require_relative "support"

# E3a-T1 — P1 scripted bundle production (spec
# docs/superpowers/specs/2026-08-26-e3a-capture-contract.md §2-§4).
#
# A replay bundle is the atom of runtime evidence: write-once manifest
# (identity + member sha256s) + per-tick seat-ordered consumed-mask log +
# the FULL digest chain at the recorded cadence + constructor-time
# preconditions. The recorder rides the replay runner's existing update
# loop (script key "bundle": true) and writes at run end — offline tooling
# only, zero live-play surface (the ratified fence: recording at session
# end only, never during play).
#
# Determinism law carried here: the emitter folds masks and closes windows
# in the netplay run loop's exact order (session.rb run_tick — fold BEFORE
# World#tick, boundary check right after), keyed by world.frame, so the
# headless re-executor (bundle_replay.rb) reproduces the chain from the
# bundle alone.
module Harness
  # NAMED refusal (spec §3 refusal class + the write-once law). The runner
  # aborts with this message; no bundle dir is created.
  class BundleRefused < StandardError; end

  class BundleRecorder
    ROOT = File.expand_path("..", __dir__)
    # Top-level and gitignored, never under data/ — a machine-written file
    # inside the fingerprint glob manufactures permanent handshake
    # refusals (s55 twin law; grill D2).
    DEFAULT_OUT = File.join(ROOT, "bundles")

    attr_reader :chain, :masks

    # Validates the script against the P1 v1 scope and binds a recorder to
    # the scene's world. Raises BundleRefused (NAMED): only single-world
    # scenes driven purely by scripted input + `start` are reproducible
    # from masks + preconditions (spec §3 — netplay scenes' frame-keyed
    # mid-run sim pokes are not).
    def self.for_script(raw, world:, producer:)
      scenario = raw.fetch(:scenario)
      unless scenario == "world"
        raise BundleRefused,
              "bundle refused — P1 v1 records the \"world\" scenario only, got " \
              "#{scenario.inspect} (other scenes are not reproducible from masks + " \
              "preconditions — E3a spec §3)"
      end
      alien = Harness.expand_script(raw).values.flatten.map(&:to_sym).uniq -
              Net::Protocol::ACTIONS
      unless alien.empty?
        raise BundleRefused,
              "bundle refused — script holds action(s) outside the mask vocabulary: " \
              "#{alien.inspect} (Protocol::ACTIONS is the recorded input contract; " \
              "a mask cannot carry them)"
      end
      netplay = JSON.parse(File.binread(File.join(ROOT, "data", "netplay.json")),
                           symbolize_names: true)
      new(world:, every: netplay.fetch(:digest_every), seed: raw.fetch(:seed, 0),
          start: raw[:start], scenario: scenario, producer: producer)
    end

    def initialize(world:, every:, seed:, start:, scenario:, producer:)
      @world = world
      @every = every
      @seed = seed
      @start = start
      @scenario = scenario
      @producer = producer
      @digest = Net::StateDigest.new(world: world, every: every)
      @masks = []
      @chain = []
    end

    # Once per executed tick, AFTER input.update(frame) and BEFORE
    # World#tick: sample the mask exactly once (the sampling law —
    # Protocol.mask is the authoritative record of what was held), fold it
    # keyed by the tick about to execute.
    def before_tick(input)
      mask = Net::Protocol.mask(input)
      @masks << [mask]
      @digest.fold_input(@world.frame, [mask])
    end

    # Once per executed tick, right after World#tick — collects the closed
    # window at each cadence boundary.
    def after_tick
      (w = @digest.after_tick) and @chain << [w.tick, w.md5]
    end

    # Terminal snapshot digest, recorded beside the cadence chain: windows
    # close only at cadence boundaries, so ticks past the last boundary
    # would otherwise be covered by member sha256s alone — a tampered
    # trailing mask re-stamped by a consistent liar would escape the chain
    # compare. Snapshot-only canonical (no pending lines); the re-executor
    # computes the same value at end-of-run. Residual, named: a trailing
    # tamper that changes NO snapshot state still escapes the compare
    # (the member sha256 remains the file-level check for that).
    def terminal
      [@world.frame,
       Digest::MD5.hexdigest(Net::StateDigest.canonical(@world.digest_snapshot))]
    end

    # Writes bundles/<bundle_id>/ — members first, manifest LAST and
    # write-once (spec D7: the production manifest never mutates;
    # verification receipts are separate files). Returns the bundle dir.
    def write(out_root: DEFAULT_OUT, now: Time.now.utc)
      id = "#{now.strftime('%Y%m%dT%H%M%SZ')}_p1_#{@seed}"
      dir = File.join(out_root, id)
      if File.exist?(dir)
        raise BundleRefused,
              "bundle refused — #{dir} already exists (bundles are write-once)"
      end
      FileUtils.mkdir_p(dir)
      write_json(File.join(dir, "input_log.json"), { masks: @masks })
      write_json(File.join(dir, "digest_chain.json"),
                 { chain: @chain, terminal: terminal })
      write_json(File.join(dir, "preconditions.json"),
                 { seats: 1, seed: @seed, scenario: @scenario, start: @start })
      members = %w[input_log.json digest_chain.json preconditions.json].to_h do |rel|
        [rel, Digest::SHA256.hexdigest(File.binread(File.join(dir, rel)))]
      end
      write_json(File.join(dir, "manifest.json"), {
                   bundle_id: id,
                   mode: "p1",
                   produced_at: now.strftime("%Y-%m-%dT%H:%M:%SZ"),
                   producer: @producer,
                   # The EOL-normalized handshake identity — REQUIRED; the
                   # re-executor refuses on mismatch, naming both values.
                   fingerprint_md5: Net::Fingerprint.tree_md5(ROOT),
                   # Best-effort, never load-bearing: a commit SHA lies
                   # about uncommitted drift and autocrlf checkouts (the
                   # v17 W6 trap; grill D3).
                   game_commit: game_commit,
                   digest_version: Net::StateDigest::DIGEST_VERSION,
                   digest_every: @every,
                   seed: @seed,
                   seats: 1,
                   ticks_executed: @world.frame,
                   end_reason: "run_until",
                   machine: ENV["COMPUTERNAME"] || ENV["HOSTNAME"] || "unknown",
                   members: members
                 })
      dir
    end

    private

    # LF bytes on every platform (binwrite): member sha256s must not
    # depend on the producing machine's text-mode translation.
    def write_json(path, obj)
      File.binwrite(path, JSON.pretty_generate(obj) << "\n")
    end

    def game_commit
      out = IO.popen({ "GIT_DIR" => nil, "GIT_INDEX_FILE" => nil, "GIT_WORK_TREE" => nil },
                     %w[git rev-parse HEAD], chdir: ROOT, err: File::NULL, &:read)
      $?.success? ? out.strip : nil
    rescue SystemCallError
      nil
    end
  end
end
