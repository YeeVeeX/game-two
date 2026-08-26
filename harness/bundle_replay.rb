require "json"
require "digest"
require "core/data_store"
require "game/world"
require "game/save_state"
require "net/protocol"
require "net/state_digest"
require "net/fingerprint"
require_relative "support"
require_relative "state_track"

# E3a-T1 — headless bundle re-executor + verification gate (spec
# docs/superpowers/specs/2026-08-26-e3a-capture-contract.md §4).
#
# HEADLESS by design: World + StateDigest are pure sim — no Gosu, no
# renderer, no window (grill D9: the replay runner exists for pixels;
# Mode T needs none). Flow: load bundle -> member integrity -> refuse on
# fingerprint mismatch (NAMED, both values) -> strict-decode save if
# present (refusals NAMED) -> N fresh re-executions feeding SampledInput
# masks from the log, folding digests at the recorded cadence -> compare
# every produced chain to the recorded chain and to each other.
#
# Verification gate (grill D10): TWO fresh re-executions; both chains must
# equal each other AND the recorded chain. The receipt
# (verification.json) is a separate file — the production manifest never
# mutates (grill D7). This receipt IS the producer's attestation the
# assets seat's intake gate names.
#
# CLI exit statuses: 0 verdict PASS · 1 verdict RED (member sha mismatch,
# chain divergence, or terminal divergence) · 2 refusal (missing/bad
# member JSON, fingerprint mismatch, save refusal — the bundle cannot be
# JUDGED on this tree; refusals never write a receipt).
#
#   ruby -Isrc harness/bundle_replay.rb bundles/<bundle_id> [runs] \
#     [--track=A..B [--track-name=NAME]]
#
# --track (E3a-T2): after a PASS verdict, write the Mode T state track
# for the inclusive frame window A..B (tracks/<name>.json + sidecar
# sha256 — harness/state_track.rb). The sampler rides verification run 1,
# so the sampled run's chain is itself gate-checked; a RED verdict emits
# nothing (exit 1), and track refusals (bad range/name, existing track,
# zone-crossing window) exit 2 like every refusal.
module Harness
  module BundleReplay
    ROOT = File.expand_path("..", __dir__)

    # "Cannot execute here" — not a verdict on the bundle's honesty.
    class Refusal < StandardError; end

    module_function

    # Full verification. Returns the receipt hash (also written to
    # <dir>/verification.json unless a Refusal is raised).
    def verify(dir, runs: 2, root: ROOT, now: Time.now.utc, observer: nil)
      # The gate LAW is two fresh re-executions (spec §4) — fewer cannot
      # attest "both chains equal each other AND the recorded chain". A
      # runs<2 request (typo'd CLI arg, misbuilt caller) must refuse, not
      # write a vacuous PASS receipt (review s84).
      unless runs >= 2
        raise Refusal,
              "REFUSED — runs=#{runs.inspect}: the verification gate is TWO fresh " \
              "re-executions minimum (spec §4); a receipt from fewer would attest nothing"
      end
      manifest = read_json(dir, "manifest.json")
      receipt = {
        bundle_id: manifest[:bundle_id],
        runs: 0,
        verdict: nil,
        reason: nil,
        first_divergent_window: nil,
        fingerprint_at_verification: nil,
        date: now.strftime("%Y-%m-%dT%H:%M:%SZ"),
        tool: "harness/bundle_replay.rb"
      }

      # 1. Fingerprint of the verifying tree — stamped on EVERY receipt
      # (a member-mismatch RED should still name the tree that judged it —
      # review s83); the member check below is build-independent.
      live = Net::Fingerprint.tree_md5(root)
      receipt[:fingerprint_at_verification] = live

      # 2. Member integrity — a file-level tamper (or a missing member) is
      # a verdict on the BUNDLE: RED, without executing a tick.
      bad = member_mismatches(dir, manifest)
      unless bad.empty?
        receipt[:verdict] = "RED"
        receipt[:reason] = "member sha256 mismatch: #{bad.join('; ')}"
        return write_receipt(dir, receipt)
      end

      # 3. Fingerprint match — the EOL-normalized handshake identity. A
      # mismatch means this tree cannot re-execute the bundle's build: REFUSE.
      unless live == manifest.fetch(:fingerprint_md5)
        raise Refusal,
              "REFUSED — fingerprint: bundle #{manifest.fetch(:fingerprint_md5)} / " \
              "tree #{live} (re-execution needs the producing build — same commit, " \
              "same data files; pull/checkout it, then retry)"
      end

      # 4. N fresh re-executions + 5. compare.
      recorded = read_json(dir, "digest_chain.json")
      results = Array.new(runs) do |i|
        execute(dir, manifest, root: root, observer: (i.zero? ? observer : nil))
      end
      receipt[:runs] = runs
      if (div = first_divergence(recorded, results))
        receipt[:verdict] = "RED"
        receipt[:reason] = div[:reason]
        receipt[:first_divergent_window] = div[:window]
      else
        receipt[:verdict] = "PASS"
      end
      write_receipt(dir, receipt)
    end

    # E3a-T2 — Mode T track emission (spec §5): verify with the sampler
    # riding run 1; write the track ONLY on PASS. Returns
    # { receipt:, track: } — track nil when the verdict blocked emission.
    # Request-shape refusals raise BEFORE any execution burns.
    def emit_track(dir, range:, name: nil, runs: 2, root: ROOT, now: Time.now.utc)
      manifest = read_json(dir, "manifest.json")
      StateTrack.validate_request!(dir, manifest, range: range, name: name)
      sampler = StateTrack::Sampler.new(range: range)
      receipt = verify(dir, runs: runs, root: root, now: now, observer: sampler)
      return { receipt: receipt, track: nil } unless receipt[:verdict] == "PASS"
      path = StateTrack.write(dir, sampler: sampler, manifest: manifest,
                              receipt: receipt, root: root, name: name, range: range)
      { receipt: receipt, track: path }
    end

    # One fresh headless re-execution: preconditions -> World -> start
    # staging -> per-tick mask feed in the recorded order (fold BEFORE
    # tick, boundary right after — the emitter/netplay order). Returns
    # { chain:, terminal: }. An observer (E3a-T2 Mode T sampler) sees the
    # world + the consumed masks after every executed tick — read-only by
    # contract; it rides run 1 only, so its run's chain is gate-checked.
    def execute(dir, manifest, root: ROOT, observer: nil)
      pre = read_json(dir, "preconditions.json")
      data = Core::DataStore.new(File.join(root, "data"))
      world = Game::World.new(data, seed: pre.fetch(:seed),
                              seats: manifest.fetch(:seats),
                              save: load_save(dir, manifest, data))
      Harness.apply_start(world, pre[:start])
      digest = Net::StateDigest.new(world: world, every: manifest.fetch(:digest_every))
      chain = []
      read_json(dir, "input_log.json").fetch(:masks).each do |masks|
        digest.fold_input(world.frame, masks)
        inputs = masks.each_with_index.to_h { |m, i| [i + 1, Net::SampledInput.new(m)] }
        world.tick(inputs)
        observer&.call(world, masks)
        (w = digest.after_tick) and chain << [w.tick, w.md5]
      end
      terminal = [world.frame,
                  Digest::MD5.hexdigest(Net::StateDigest.canonical(world.digest_snapshot))]
      { chain: chain, terminal: terminal }
    end

    # --- internals ---------------------------------------------------------

    def read_json(dir, rel)
      path = File.join(dir, rel)
      raise Refusal, "REFUSED — #{rel} missing from #{dir}" unless File.file?(path)
      JSON.parse(File.binread(path), symbolize_names: true)
    rescue JSON::ParserError => e
      raise Refusal, "REFUSED — #{rel} unparseable: #{e.message}"
    end

    # P2 bundles carry the canonical save-facts bytes EXACTLY as SESSION
    # carried them; the strict decoder refuses NAMED (spec §2). P1 bundles
    # have no save member -> honest fresh construction.
    def load_save(dir, manifest, data)
      return nil unless manifest.fetch(:members).key?(:"save.json")
      facts = JSON.parse(File.binread(File.join(dir, "save.json")))
      if (text = Game::SaveState.refusal_for(facts, data: data))
        raise Refusal, "REFUSED — #{text}"
      end
      facts
    rescue JSON::ParserError => e
      raise Refusal, "REFUSED — save.json unparseable: #{e.message}"
    end

    def member_mismatches(dir, manifest)
      manifest.fetch(:members).filter_map do |rel, declared|
        path = File.join(dir, rel.to_s)
        unless File.file?(path)
          next "#{rel} declared #{declared} but the file is missing"
        end
        actual = Digest::SHA256.hexdigest(File.binread(path))
        "#{rel} declared #{declared} actual #{actual}" unless actual == declared
      end
    end

    # First window where any produced chain disagrees with the recorded
    # chain (or the chains disagree with each other), else the terminal
    # snapshot digest, else nil. Windowed comparison localizes a
    # divergence to one cadence window (grill D4).
    def first_divergence(recorded, results)
      rec_chain = recorded.fetch(:chain)
      chains = results.map { |r| r[:chain] }
      length = ([rec_chain] + chains).map(&:length).max
      length.times do |i|
        entries = [rec_chain[i]] + chains.map { |c| c[i] }
        next if entries.uniq.length == 1
        tick = entries.compact.first&.first
        return { reason: "digest chain diverged at window tick=#{tick}",
                 window: { tick: tick, recorded: rec_chain[i],
                           runs: chains.map { |c| c[i] } } }
      end
      terminals = results.map { |r| r[:terminal] }
      entries = [recorded.fetch(:terminal)] + terminals
      unless entries.uniq.length == 1
        return { reason: "terminal snapshot digest diverged " \
                         "(ticks past the last cadence boundary)",
                 window: { tick: entries.compact.first&.first,
                           recorded: recorded.fetch(:terminal), runs: terminals } }
      end
      nil
    end

    def write_receipt(dir, receipt)
      File.binwrite(File.join(dir, "verification.json"),
                    JSON.pretty_generate(receipt) << "\n")
      receipt
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  usage = "Usage: ruby -Isrc harness/bundle_replay.rb bundles/<bundle_id> [runs] " \
          "[--track=A..B [--track-name=NAME]]"
  track = nil
  track_name = nil
  args = ARGV.reject do |a|
    case a
    when /\A--track=(\d+)\.\.(\d+)\z/
      track = (Regexp.last_match(1).to_i..Regexp.last_match(2).to_i)
    when /\A--track-name=(.+)\z/
      track_name = Regexp.last_match(1)
    end
  end
  # Malformed flags must abort, never degrade to a plain verify (review
  # s84: a space-form typo like "--track 5..10" would otherwise become a
  # bogus runs arg / be silently ignored).
  if (bad = args.find { |a| a.start_with?("-") })
    abort "unrecognized argument #{bad.inspect}\n#{usage}"
  end
  dir = args[0] or abort usage
  abort "--track-name needs --track\n#{usage}" if track_name && track.nil?
  if args[1] && args[1] !~ /\A\d+\z/
    abort "runs must be a positive integer, got #{args[1].inspect}\n#{usage}"
  end
  runs = (args[1] || 2).to_i
  begin
    if track
      out = Harness::BundleReplay.emit_track(dir, range: track, name: track_name, runs: runs)
      receipt = out[:receipt]
    else
      receipt = Harness::BundleReplay.verify(dir, runs: runs)
    end
    puts "verdict=#{receipt[:verdict]} runs=#{receipt[:runs]} " \
         "receipt=#{File.join(dir, 'verification.json')}"
    puts "reason=#{receipt[:reason]}" if receipt[:reason]
    puts "track=#{out[:track]}" if track && out[:track]
    exit(receipt[:verdict] == "PASS" ? 0 : 1)
  rescue Harness::BundleReplay::Refusal, Harness::StateTrack::Refused => e
    warn e.message
    exit 2
  end
end
