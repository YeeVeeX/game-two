# World-builder WB-T6 (S2): the world-graph lint — the cross-zone checks
# no single zone can make about itself. Zones load through the SAME
# strict path the game boots with (Core::TileMap + the data/tiles.json
# registry; real files), then every transition is judged:
#
#   (1) target   — `to` names a loaded zone                       HARD
#   (2) spawn    — the arrival cell is inside the TARGET zone's
#                  bounds and passable there                       HARD
#   (3) floor    — floor(to) - floor(here) matches the type:
#                  stairs_down / hole = -1 · stairs_up / rope_spot
#                  = +1 · plain gate (no type) = 0                  HARD, minus the allowlist
#   (4) return   — for A->B some B->A exists; holes are ONE-WAY by
#                  law (v20 D4), so this only REPORTS               INFO
#
# (1) and (2) are already boot law — Game::Crossing.validated_arrivals
# (src/game/crossing.rb:24-43) raises NAMED on the first violation when
# a World is built. The lint restates them for AUTHORING time (the LDtk
# AfterSave command runs it over data/zones overlaid by the fresh
# tmp/ldtk_out emission) and reports every row, not just the first.
# (3) is the NEW law: MAP_EDITING §3 recorded floor-delta consistency
# as "UNENFORCED — authoring discipline" until this file.
#
# The allowlist (authoring/world_graph_allowlist.json) names every
# KNOWN (3) violation with a classification + one-line reason: the live
# world predates the law (legacy plain gates across floors, the T5
# world join, harness fixtures). The suite (test/tools/
# world_graph_lint_test.rb) blocks on any NEW hard finding AND on any
# stale allowlist row (a fixed row must leave the list), so the list
# can only shrink or grow consciously.
#
# dev-tooling ONLY: nothing in src/ requires this file; reaching INTO
# src/ is the allowed direction. Zone JSONs are never edited here — an
# importer-emitted zone's fix goes through authoring/pilot.ldtk, a
# hand-authored zone's through its JSON, both under Rule 2.
#
# Usage:
#   ruby tools/lint_world_graph.rb [--zones DIR] [--overlay DIR] [--tiles data/tiles.json]
#                                  [--allowlist authoring/world_graph_allowlist.json] [--report]
#   defaults: --zones data/zones; --overlay replaces same-named zones (the
#   world as it WOULD be after the deliberate copy); --report prints the
#   full table (allowlisted + info rows) for the record.
#   exit 0 = no new hard finding, no stale allowlist row · 1 = findings · 2 = refused to load

$LOAD_PATH.unshift File.expand_path("../src", __dir__)

require "json"
require "core/tile_map"
require "core/tile_registry"

module Tools
  class WorldGraphLint
    class Refusal < StandardError; end

    Finding = Struct.new(:check, :severity, :zone, :at, :to, :message, keyword_init: true) do
      def key = [check.to_s, zone, at, to]
      def to_s = "#{severity == :hard ? 'HARD' : 'INFO'} #{check} #{zone} #{at.inspect} -> #{to}: #{message}"
    end

    HARD_CHECKS = %i[target spawn floor].freeze
    # nil = plain gate (absent type). Every Core::TileMap::TRANSITION_TYPES
    # member has a row here — the test pins that.
    EXPECTED_DELTA = { "stairs_down" => -1, "hole" => -1, "stairs_up" => 1, "rope_spot" => 1, nil => 0 }.freeze
    ONE_WAY_TYPES = %w[hole].freeze
    ALLOWLIST_STATUSES = %w[intended legacy].freeze
    ALLOWLIST_KEYS = %w[check zone at to status reason].freeze

    # dirs: Array of zone directories, later ones OVERLAY earlier ones
    # (same basename replaces). Every zone goes through TileMap.new +
    # registry.validate_map! — a zone the game would refuse refuses here.
    # -> { name => Core::TileMap }
    def self.load_zones(dirs, tiles_path)
      registry = Core::TileRegistry.new(JSON.parse(File.read(tiles_path)))
      paths = {}
      dirs.each do |dir|
        raise Refusal, "zones dir #{dir.inspect} does not exist" unless File.directory?(dir)
        Dir[File.join(dir, "*.json")].sort.each { |p| paths[File.basename(p, ".json")] = p }
      end
      raise Refusal, "no zone JSON found in #{dirs.inspect}" if paths.empty?
      paths.to_h do |name, path|
        cfg = JSON.parse(File.read(path), symbolize_names: true)
        map = Core::TileMap.new(cfg)
        registry.validate_map!(map)
        [name, map]
      rescue Core::TileMap::BadMap, Core::TileRegistry::BadRegistry, JSON::ParserError => e
        raise Refusal, "zone #{name} (#{path}) refused by the loader — #{e.message}"
      end
    end

    # -> Array of allowlist rows (string-keyed Hashes), shape-validated.
    def self.load_allowlist(path)
      return [] unless path && File.exist?(path)
      rows = JSON.parse(File.read(path))
      raise Refusal, "allowlist #{path}: top level must be an array" unless rows.is_a?(Array)
      rows.each_with_index do |row, i|
        missing = ALLOWLIST_KEYS - row.keys
        raise Refusal, "allowlist #{path} row #{i}: missing #{missing.inspect}" unless missing.empty?
        unless HARD_CHECKS.map(&:to_s).include?(row["check"])
          raise Refusal, "allowlist #{path} row #{i}: check #{row['check'].inspect} not in #{HARD_CHECKS.inspect}"
        end
        unless ALLOWLIST_STATUSES.include?(row["status"])
          raise Refusal, "allowlist #{path} row #{i}: status #{row['status'].inspect} not in #{ALLOWLIST_STATUSES.inspect}"
        end
        raise Refusal, "allowlist #{path} row #{i}: reason must be a non-empty String" \
          unless row["reason"].is_a?(String) && !row["reason"].strip.empty?
      end
      rows
    end

    def initialize(zones)
      @zones = zones
    end

    # Every finding, in zone-name order (deterministic report).
    def findings
      @findings ||= @zones.keys.sort.flat_map { |name| judge_zone(name, @zones[name]) }
    end

    def hard_findings = findings.select { |f| f.severity == :hard }
    def info_findings = findings.select { |f| f.severity == :info }

    # Hard findings not covered by the allowlist — the blocking set.
    def new_hard_findings(allowlist)
      keys = allowlist.map { |r| self.class.row_key(r) }
      hard_findings.reject { |f| keys.include?(f.key) }
    end

    # Allowlist rows that match no finding — a fixed row must LEAVE the list.
    def stale_allowlist(allowlist)
      keys = findings.map(&:key)
      allowlist.reject { |r| keys.include?(self.class.row_key(r)) }
    end

    def self.row_key(row) = [row["check"], row["zone"], row["at"], row["to"]]

    private

    def judge_zone(name, map)
      out = []
      map.transitions.each do |t|
        at = t[:at]
        to = t[:to]
        type = t[:type]
        target = @zones[to]
        unless target
          out << Finding.new(check: :target, severity: :hard, zone: name, at:, to:,
                             message: "targets unknown zone #{to.inspect} (loaded: #{@zones.keys.sort.join(', ')})")
          next
        end
        spawn = t[:spawn]
        if !spawn.is_a?(Array) || spawn.length != 2 || !spawn.all? { |v| v.is_a?(Integer) }
          out << Finding.new(check: :spawn, severity: :hard, zone: name, at:, to:,
                             message: "spawn #{spawn.inspect} is not an [x, y] tile")
        elsif spawn[0].negative? || spawn[1].negative? || spawn[0] >= target.cols || spawn[1] >= target.rows
          out << Finding.new(check: :spawn, severity: :hard, zone: name, at:, to:,
                             message: "spawn #{spawn.inspect} outside #{to}'s #{target.cols}x#{target.rows} bounds")
        elsif !target.passable?(*spawn)
          out << Finding.new(check: :spawn, severity: :hard, zone: name, at:, to:,
                             message: "spawn #{spawn.inspect} lands on #{target.char_at(*spawn).inspect} (impassable) in #{to}")
        end
        expected = EXPECTED_DELTA.fetch(type)
        delta = target.floor - map.floor
        if delta != expected
          out << Finding.new(check: :floor, severity: :hard, zone: name, at:, to:,
                             message: "#{type || 'gate'}: floor #{map.floor} -> #{target.floor} (delta #{format('%+d', delta)}, " \
                                      "#{type || 'plain gate'} expects #{format('%+d', expected)})")
        end
        unless target.transitions.any? { |back| back[:to] == name }
          note = ONE_WAY_TYPES.include?(type) ? " (hole: one-way by law D4)" : ""
          out << Finding.new(check: :return, severity: :info, zone: name, at:, to:,
                             message: "no #{to} -> #{name} transition exists#{note}")
        end
      end
      out
    end
  end
end

# --- CLI ----------------------------------------------------------------

if __FILE__ == $PROGRAM_NAME
  args = ARGV.dup
  opts = { zones: [], tiles: "data/tiles.json", allowlist: "authoring/world_graph_allowlist.json", report: false }
  usage = "usage: ruby tools/lint_world_graph.rb [--zones DIR] [--overlay DIR] [--tiles FILE] [--allowlist FILE] [--report]"
  refuse = lambda do |msg|
    warn "LINT REFUSED: #{msg}"
    exit 2
  end
  until args.empty?
    k = args.shift
    case k
    when "--zones", "--overlay" then opts[:zones] << (args.shift or refuse.call("#{k} needs a value\n#{usage}"))
    when "--tiles" then opts[:tiles] = args.shift or refuse.call("--tiles needs a value\n#{usage}")
    when "--allowlist" then opts[:allowlist] = args.shift or refuse.call("--allowlist needs a value\n#{usage}")
    when "--report" then opts[:report] = true
    else refuse.call("unknown option #{k.inspect}\n#{usage}")
    end
  end
  opts[:zones] = ["data/zones"] if opts[:zones].empty?

  begin
    zones = Tools::WorldGraphLint.load_zones(opts[:zones], opts[:tiles])
    allowlist = Tools::WorldGraphLint.load_allowlist(opts[:allowlist])
  rescue Tools::WorldGraphLint::Refusal, Errno::ENOENT, JSON::ParserError => e
    refuse.call(e.message)
  end
  lint = Tools::WorldGraphLint.new(zones)
  new_hard = lint.new_hard_findings(allowlist)
  stale = lint.stale_allowlist(allowlist)
  edges = zones.values.sum { |m| m.transitions.length }
  puts "WORLD GRAPH LINT: #{zones.length} zones, #{edges} transitions (#{opts[:zones].join(' + ')}) — " \
       "#{lint.hard_findings.length} hard finding(s) (#{lint.hard_findings.length - new_hard.length} allowlisted), " \
       "#{lint.info_findings.length} info, #{new_hard.length} NEW, #{stale.length} stale allowlist row(s)"
  if opts[:report]
    puts "\n| sev | check | zone | at | -> to | finding | allowlist |"
    puts "|---|---|---|---|---|---|---|"
    lint.findings.each do |f|
      row = allowlist.find { |r| Tools::WorldGraphLint.row_key(r) == f.key }
      tag = row ? "#{row['status'].upcase}: #{row['reason']}" : (f.severity == :hard ? "**NEW**" : "—")
      puts "| #{f.severity} | #{f.check} | #{f.zone} | #{f.at.inspect} | #{f.to} | #{f.message} | #{tag} |"
    end
  end
  new_hard.each { |f| puts "NEW #{f}" }
  stale.each { |r| puts "STALE allowlist row #{Tools::WorldGraphLint.row_key(r).inspect} matches no finding — remove it (#{r['reason']})" }
  exit(new_hard.empty? && stale.empty? ? 0 : 1)
end
