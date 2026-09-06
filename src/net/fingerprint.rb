require "digest"
require "net/protocol"
require "net/state_digest"

module Net
  # v17 handshake identity (spec Netplay spec): the sim fingerprint is an
  # md5 over sorted (relpath, content-md5) of src/**/*.rb + data/** +
  # Gemfile.lock — EXCLUDING the per-machine display/client files
  # (data/bindings.local.json, data/prefs.local.json — display-only,
  # legitimately per-machine; the prefs twin of DataStore::MACHINE_WRITTEN,
  # J6-B D9). Content md5s are EOL-NORMALIZED (\r\n and
  # \r → \n) — live trap 2026-08-16: the first cross-machine join refused
  # on an autocrlf=true checkout of the SAME commit (byte drift, identical
  # sim; Ruby and JSON are EOL-agnostic). Real content drift still refuses.
  # Ruby/platform/protocol/digest versions ride
  # HELLO as separate fields so a mismatch can NAME what differs (the
  # error reaches the person who must act — W6, stale-line joins).
  module Fingerprint
    # Per-machine files never enter the shared identity: a gitignored file
    # can never be equalized by "git pull", so including one manufactures a
    # permanent refusal with a lying hint (s55 review finding). The next
    # machine-written file must land HERE and in DataStore::MACHINE_WRITTEN.
    # v22 T1: data/player.local.json (App::PlayerFile) — the ONE identity
    # file; its id rides HELLO as its own field, never the tree hash.
    EXCLUDED = ["data/bindings.local.json", "data/prefs.local.json",
                "data/player.local.json"].freeze

    LABELS = {
      version: "protocol version",
      ruby: "Ruby version",
      platform: "platform",
      fingerprint: "sim fingerprint",
      digest_version: "digest version"
    }.freeze

    module_function

    def tree_md5(root)
      root = File.expand_path(root)
      rels = Dir.glob("src/**/*.rb", base: root) +
             Dir.glob("data/**/*", base: root) +
             ["Gemfile.lock"]
      entries = rels.map { |r| r.tr("\\", "/") }.uniq.sort.filter_map do |rel|
        next if EXCLUDED.include?(rel)
        path = File.join(root, rel)
        next unless File.file?(path) # skips dirs; a MISSING Gemfile.lock honestly changes the hash
        "#{rel}:#{Digest::MD5.hexdigest(File.binread(path).gsub(/\r\n?/, "\n"))}"
      end
      Digest::MD5.hexdigest(entries.join("\n"))
    end

    # The five HELLO identity fields (Protocol::MESSAGES[:hello] shape).
    def hello(root:)
      {
        version: Protocol::VERSION,
        ruby: RUBY_VERSION,
        platform: RUBY_PLATFORM,
        fingerprint: tree_md5(root),
        digest_version: StateDigest::DIGEST_VERSION
      }
    end

    # nil when the seats match; else a print-ready refusal that NAMES every
    # differing field and hints the fix.
    def mismatch(ours, theirs)
      diffs = LABELS.keys.select { |k| ours[k] != theirs[k] }
      return nil if diffs.empty?
      lines = ["REFUSED — seats differ:"]
      diffs.each { |k| lines << "  #{LABELS[k]}: ours #{ours[k]} / theirs #{theirs[k]}" }
      lines << "  hint: git pull on BOTH seats (same commit, same Ruby), then relaunch"
      lines.join("\n")
    end
  end
end
