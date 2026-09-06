# frozen_string_literal: true

# Wall PIN LEDGER (v22 prep, s131). A "pin" = the last time a wall script
# went through the blocking gate + manifest check, recorded as data so
# "is this surface's verdict still current?" is computed, never remembered.
#
# Two verbs, both plain Ruby over one JSON array (harness/pins.json,
# tracked; starts as []):
#
#   ruby harness/pins.rb record --script <name> --tag <tag> --gate-rc <n> --manifest-rc <n>
#       appends {script, tag, commit, date, gate_rc, manifest_rc}. Called by
#       harness/run_wall.sh after EVERY script (so a sweep killed midway still
#       leaves the pins it earned). commit = HEAD of the tree the sweep ran in.
#
#   ruby harness/pins.rb report [--pins <path>] [--scripts <dir>]
#       one line per wall script: PINNED (verdict current), STALE (render/sim
#       paths — src/app src/game data/ — changed since the pin commit; lists
#       the count + newest hash), FAILED (last pin was red), UNPINNED (no
#       entry). Exit 0 always — this is a ledger, not a gate; `rake gate`
#       stays the ship-gate.
#
# Laws: the ledger never runs a replay; it reads pins.json + git. The ledger
# lives in the MAIN clone even when a sweep runs in a worktree (T0 d4: the
# 064bd80 sweep ran in worktree game-two-wall3, since pruned — its pins died
# with it): DEFAULT_PATH resolves through `git rev-parse --git-common-dir`,
# a no-op in the main clone. Unknown paths / malformed JSON refuse NAMED
# (no silent []).

require "json"
require "time"

module Harness
  module Pins
    # The main clone's root from ANY worktree (git-common-dir points home);
    # no git on PATH / not a repo → fall back to this file's own repo.
    # GIT_* scrubbed: under a git hook (rebase exec, pre-commit) inherited
    # GIT_DIR/GIT_INDEX_FILE would override the -C discovery (hit live s135).
    GIT_ENV_SCRUB = { "GIT_DIR" => nil, "GIT_INDEX_FILE" => nil,
                      "GIT_WORK_TREE" => nil, "GIT_PREFIX" => nil }.freeze

    def self.main_repo_root
      out = IO.popen(
        GIT_ENV_SCRUB,
        ["git", "-C", __dir__, "rev-parse", "--path-format=absolute", "--git-common-dir"],
        err: File::NULL, &:read
      ).to_s.strip
      return File.expand_path("..", __dir__) if out.empty?
      File.expand_path("..", out)
    rescue SystemCallError
      File.expand_path("..", __dir__)
    end

    DEFAULT_PATH = File.join(main_repo_root, "harness", "pins.json")
    DEFAULT_SCRIPTS = File.expand_path("scripts", __dir__)
    RENDER_PATHS = %w[src/app src/game data].freeze
    REQUIRED = %w[script tag commit date gate_rc manifest_rc].freeze

    class Refusal < StandardError; end

    def self.load(path)
      raise Refusal, "pins: #{path} missing (start it as [])" unless File.exist?(path)
      parsed = JSON.parse(File.read(path, encoding: "utf-8"))
      raise Refusal, "pins: #{path} must be a JSON array (got #{parsed.class})" unless parsed.is_a?(Array)
      parsed.each_with_index do |row, i|
        missing = REQUIRED - (row.is_a?(Hash) ? row.keys : [])
        raise Refusal, "pins: row #{i} missing #{missing.join(',')}" unless missing.empty?
      end
      parsed
    rescue JSON::ParserError => e
      raise Refusal, "pins: #{path} is not valid JSON (#{e.message[0, 80]})"
    end

    def self.record(path:, script:, tag:, gate_rc:, manifest_rc:, commit: nil, date: nil)
      raise Refusal, "pins record: --script is required" if script.nil? || script.empty?
      raise Refusal, "pins record: --tag is required" if tag.nil? || tag.empty?
      [["gate-rc", gate_rc], ["manifest-rc", manifest_rc]].each do |name, v|
        raise Refusal, "pins record: --#{name} must be an integer (got #{v.inspect})" unless v.to_s.match?(/\A\d+\z/)
      end
      rows = File.exist?(path) ? load(path) : []
      rows << {
        "script" => File.basename(script, ".json"),
        "tag" => tag,
        "commit" => commit || head_commit,
        "date" => date || Time.now.utc.iso8601,
        "gate_rc" => Integer(gate_rc),
        "manifest_rc" => Integer(manifest_rc)
      }
      File.write(path, JSON.pretty_generate(rows) + "\n")
      rows.last
    end

    def self.git(*args)
      IO.popen(["git", *args], err: File::NULL, &:read).to_s
    rescue SystemCallError
      ""
    end

    def self.head_commit
      out = git("rev-parse", "--short=7", "HEAD").strip
      out.empty? ? "unknown" : out
    end

    # Commits touching the render/sim paths since a pin commit. nil when the
    # pin commit is unknown to this repo (a worktree pin from a branch that
    # was never merged, or the "unknown" placeholder) — reported as such.
    def self.drift_since(commit)
      return nil if commit.nil? || commit == "unknown"
      known = system("git", "cat-file", "-e", "#{commit}^{commit}", out: File::NULL, err: File::NULL)
      return nil unless known
      out = git("log", "--format=%h", "#{commit}..HEAD", "--", *RENDER_PATHS)
      out.split("\n").map(&:strip).reject(&:empty?)
    end

    def self.report(path: DEFAULT_PATH, scripts_dir: DEFAULT_SCRIPTS)
      rows = load(path)
      scripts = Dir[File.join(scripts_dir, "*.json")].map { |p| File.basename(p, ".json") }.sort
      lines = []
      if rows.empty?
        lines << "PINS: no pins recorded yet (#{scripts.size} wall scripts; the next harness/run_wall.sh sweep populates #{path})"
        return lines
      end
      latest = rows.group_by { |r| r["script"] }.transform_values { |rs| rs.max_by { |r| r["date"] } }
      tally = Hash.new(0)
      scripts.each do |s|
        pin = latest[s]
        if pin.nil?
          tally[:unpinned] += 1
          lines << format("UNPINNED  %-24s no entry", s)
          next
        end
        red = pin["gate_rc"].to_i != 0 || pin["manifest_rc"].to_i != 0
        drift = drift_since(pin["commit"])
        state =
          if red then :failed
          elsif drift.nil? then :unknown
          elsif drift.empty? then :pinned
          else :stale
          end
        tally[state] += 1
        detail =
          case state
          when :failed then "gate_rc=#{pin['gate_rc']} manifest_rc=#{pin['manifest_rc']}"
          when :unknown then "pin commit #{pin['commit']} not in this repo"
          when :pinned then "current"
          when :stale then "#{drift.size} render/sim commit(s) since, newest #{drift.first}"
          end
        lines << format("%-9s %-24s %s %s %s", state.to_s.upcase, s, pin["commit"], pin["date"][0, 10], detail)
      end
      orphans = latest.keys - scripts
      orphans.each { |s| lines << format("RETIRED   %-24s pinned but no longer in %s", s, scripts_dir) }
      lines << "PINS: #{scripts.size} scripts — pinned=#{tally[:pinned]} stale=#{tally[:stale]} " \
               "failed=#{tally[:failed]} unpinned=#{tally[:unpinned]} unknown=#{tally[:unknown]} retired=#{orphans.size}"
      lines
    end

    def self.parse_args(argv)
      opts = {}
      argv.each_slice(2) do |flag, value|
        raise Refusal, "pins: unexpected argument #{flag.inspect}" unless flag.to_s.start_with?("--")
        opts[flag.sub(/\A--/, "").tr("-", "_").to_sym] = value
      end
      opts
    end

    def self.main(argv)
      verb = argv.shift
      opts = parse_args(argv)
      case verb
      when "record"
        row = record(path: opts[:pins] || DEFAULT_PATH, script: opts[:script], tag: opts[:tag],
                     gate_rc: opts[:gate_rc], manifest_rc: opts[:manifest_rc],
                     commit: opts[:commit], date: opts[:date])
        puts "PIN recorded: #{row['script']} tag=#{row['tag']} commit=#{row['commit']} " \
             "gate_rc=#{row['gate_rc']} manifest_rc=#{row['manifest_rc']}"
      when "report"
        puts report(path: opts[:pins] || DEFAULT_PATH, scripts_dir: opts[:scripts] || DEFAULT_SCRIPTS)
      else
        raise Refusal, "usage: ruby harness/pins.rb record|report [--flags]"
      end
      0
    rescue Refusal => e
      warn "PINS REFUSED: #{e.message}"
      2
    end
  end
end

exit Harness::Pins.main(ARGV.dup) if $PROGRAM_NAME == __FILE__
