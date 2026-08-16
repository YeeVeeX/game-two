require "digest"
require "net/protocol"
require "net/state_digest"

module Net
  # v17 handshake identity (spec Netplay spec): the sim fingerprint is an
  # md5 over sorted (relpath, content-md5) of src/**/*.rb + data/** +
  # Gemfile.lock — EXCLUDING data/bindings.local.json (display-only,
  # legitimately per-machine). Ruby/platform/protocol/digest versions ride
  # HELLO as separate fields so a mismatch can NAME what differs (the
  # error reaches the person who must act — W6, stale-line joins).
  module Fingerprint
    EXCLUDED = ["data/bindings.local.json"].freeze

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
        "#{rel}:#{Digest::MD5.file(path).hexdigest}"
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
