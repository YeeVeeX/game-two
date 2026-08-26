require "json"
require "digest"
require "core/data_store"
require "game/world"
require "game/save_state"
require "net/protocol"
require "net/state_digest"
require "net/fingerprint"
require_relative "support"

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
#   ruby -Isrc harness/bundle_replay.rb bundles/<bundle_id> [runs]
module Harness
  module BundleReplay
    ROOT = File.expand_path("..", __dir__)

    # "Cannot execute here" — not a verdict on the bundle's honesty.
    class Refusal < StandardError; end

    module_function

    # Full verification. Returns the receipt hash (also written to
    # <dir>/verification.json unless a Refusal is raised).
    def verify(dir, runs: 2, root: ROOT, now: Time.now.utc)
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
      results = Array.new(runs) { execute(dir, manifest, root: root) }
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

    # One fresh headless re-execution: preconditions -> World -> start
    # staging -> per-tick mask feed in the recorded order (fold BEFORE
    # tick, boundary right after — the emitter/netplay order). Returns
    # { chain:, terminal: }.
    def execute(dir, manifest, root: ROOT)
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
  dir = ARGV[0] or abort "Usage: ruby -Isrc harness/bundle_replay.rb bundles/<bundle_id> [runs]"
  runs = (ARGV[1] || 2).to_i
  begin
    receipt = Harness::BundleReplay.verify(dir, runs: runs)
    puts "verdict=#{receipt[:verdict]} runs=#{receipt[:runs]} " \
         "receipt=#{File.join(dir, 'verification.json')}"
    puts "reason=#{receipt[:reason]}" if receipt[:reason]
    exit(receipt[:verdict] == "PASS" ? 0 : 1)
  rescue Harness::BundleReplay::Refusal => e
    warn e.message
    exit 2
  end
end
