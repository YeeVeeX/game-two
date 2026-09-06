#!/usr/bin/env ruby
# Lane guard — the FENCE that makes multi-agent lanes collide-free by
# construction (drafts/_multiagent-lanes-design-20260906.md §2.2).
#
# v3 (after two fresh-eyes reviews, 2026-09-06):
#   * brief + BOARD are read from a TRUSTED REF (default `main`, `--trust <ref>`),
#     never from the working tree — a lane cannot widen its own `owns`;
#   * POLICY = everything under drafts/lanes/ except drafts/lanes/receipts/
#     (briefs, README, BOARD are integrator-only); an owns pattern that could
#     COVER a policy path (glob intersection, segment-wise) is refused at parse;
#   * paths are CANONICALIZED (\ -> /, // -> /, leading ./ dropped) and any
#     "." / ".." segment is refused as MALFORMED;
#   * renames/copies fence BOTH sides (`git diff --name-status -z -M -C`);
#   * the current branch must equal the brief's `branch:` in EVERY mode
#     (`--no-branch-check` exists for probes/tests only and says so);
#   * `src/game/**` additionally requires BOARD's machine row `SIM LANE: <lane>`
#     to name this lane (the human `SIM TOKEN:` line is attribution only);
#   * strict schema: `lane` [a-z0-9._-], `branch` == "lane/<lane>", `owns`/`never`
#     = LISTS of non-empty strings (a scalar is an error, never coerced);
#   * a lane may own ONLY its own receipt drafts/lanes/receipts/<lane>.md;
#   * policy decisions are case-insensitive (core.ignorecase filesystems);
#   * BOARD `SIM LANE:` must be exactly one same-line row (two or empty => refuse);
#   * fail-CLOSED: unknown option, empty operands, git errors => exit 2.
#
#   ruby tools/lane_guard.rb <lane>                       # staged files (pre-commit)
#   ruby tools/lane_guard.rb <lane> --base <ref>          # everything changed since <ref>
#   ruby tools/lane_guard.rb <lane> --files <paths...>    # explicit list
#   ... [--trust <ref>] [--no-branch-check]
require "yaml"
require "open3"

module LaneGuard
  class BadBrief < StandardError; end
  class GitError < StandardError; end

  POLICY_DIR = "drafts/lanes".freeze
  RECEIPTS_DIR = "drafts/lanes/receipts".freeze
  SIM_PATHS = ["src/game/**"].freeze
  LANE_NAME = /\A[a-z0-9][a-z0-9._-]*\z/

  # Canonical repo-relative path; nil when any segment is "", "." or "..".
  def self.canon(path)
    p = path.to_s.strip.tr("\\", "/").squeeze("/").sub(%r{\A\./}, "")
    segs = p.split("/")
    return nil if p.empty? || segs.empty? || segs.any? { |s| s.empty? || s == "." || s == ".." }
    segs.join("/")
  end

  def self.parse_brief(text)
    t = text.sub(/\A\xEF\xBB\xBF/, "").gsub("\r\n", "\n")
    m = t.match(/\A---\n(.*?)\n---(\n|\z)/m)
    raise BadBrief, "brief has no front matter (--- ... ---)" unless m
    cfg = YAML.safe_load(m[1], permitted_classes: [], aliases: false) || {}
    raise BadBrief, "front matter is not a mapping" unless cfg.is_a?(Hash)
    lane = cfg["lane"]
    raise BadBrief, "brief has no valid `lane:` (#{LANE_NAME.inspect})" unless lane.is_a?(String) && lane.match?(LANE_NAME)
    raise BadBrief, "brief `#{lane}`: `branch:` must be exactly \"lane/#{lane}\"" unless cfg["branch"] == "lane/#{lane}"
    owns = list!(cfg["owns"], "owns", lane)
    never = cfg.key?("never") ? list!(cfg["never"], "never", lane) : []
    raise BadBrief, "brief `#{lane}` owns nothing" if owns.empty?
    owns.each do |o|
      raise BadBrief, "brief `#{lane}` owns a POLICY pattern #{o.inspect} (only #{RECEIPTS_DIR}/<lane>.md is a lane's)" if policy?(o)
      under_receipts = o.downcase.tr("\\", "/").squeeze("/").sub(%r{\A\./}, "").start_with?(RECEIPTS_DIR)
      if under_receipts && o != "#{RECEIPTS_DIR}/#{lane}.md"
        raise BadBrief, "brief `#{lane}` may own ONLY its receipt #{RECEIPTS_DIR}/#{lane}.md, not #{o.inspect}"
      end
    end
    { "lane" => lane, "branch" => cfg["branch"], "owns" => owns, "never" => never }
  end

  def self.list!(v, key, lane)
    ok = v.is_a?(Array) && !v.empty? && v.all? { |x| x.is_a?(String) && !x.strip.empty? }
    raise BadBrief, "brief `#{lane}`: `#{key}:` must be a LIST of non-empty strings (got #{v.inspect})" unless ok
    v = v.map(&:strip)
    raise BadBrief, "brief `#{lane}`: `#{key}:` repeats an entry" unless v.uniq.length == v.length
    v
  end

  # One glob segment vs one literal segment ("*" within a segment; "**" = anything).
  def self.seg_match?(seg, name)
    seg = seg.downcase # policy decisions are case-insensitive (core.ignorecase filesystems)
    return true if seg == name || seg == "**"
    return false unless seg.include?("*")
    Regexp.new("\\A" + Regexp.escape(seg).gsub("\\*", "[^/]*") + "\\z").match?(name)
  end

  # Could this OWNS pattern cover anything under drafts/lanes/ other than
  # receipts/? Decided segment-wise on the pattern (glob intersection), so
  # `drafts/l*/x.md`, `./drafts/lanes/x.md`, `drafts//lanes/`, `drafts/`, `**`
  # are all policy; `drafts/lanes/receipts/...` and `drafts/_review-*.md` are not.
  def self.policy?(pattern)
    c = pattern.to_s.strip.tr("\\", "/").squeeze("/").sub(%r{\A\./}, "")
    return true if c.empty?
    segs = c.sub(%r{/\*\*\z}, "").sub(%r{/\z}, "").split("/").reject(&:empty?)
    return true if segs.empty? || segs == ["**"] || segs == ["*"]
    return true if segs.any? { |x| x == "." || x == ".." } # a dotted pattern can escape anywhere: refuse
    return false unless seg_match?(segs[0], "drafts")
    return true if segs.length == 1
    return false unless seg_match?(segs[1], "lanes")
    return true if segs.length == 2
    segs[2] != "receipts"
  end

  # Path pattern -> true/false. "dir/" and "dir/**" own the subtree; "*" one segment.
  def self.match?(pattern, path)
    pat = pattern.strip.tr("\\", "/")
    p = path.tr("\\", "/")
    return p == pat[0..-2] || p.start_with?(pat) if pat.end_with?("/")
    return p == pat[0..-4] || p.start_with?(pat[0..-3]) if pat.end_with?("/**")
    if pat.include?("*")
      rx = Regexp.new("\\A" + Regexp.escape(pat).gsub("\\*", "[^/]*") + "\\z")
      return rx.match?(p)
    end
    p == pat
  end

  def self.policy_path?(f)
    f = f.downcase # case-insensitive FS: Drafts/Lanes/BOARD.md IS drafts/lanes/BOARD.md
    f == POLICY_DIR || (f.start_with?("#{POLICY_DIR}/") && !f.start_with?("#{RECEIPTS_DIR}/"))
  end

  # -> { ok:, malformed:, policy:, forbidden:, outside:, sim: }
  def self.check(cfg, files, sim_lane: nil)
    r = { malformed: [], policy: [], forbidden: [], outside: [], sim: [] }
    files.each do |raw|
      f = canon(raw)
      if f.nil?
        r[:malformed] << raw
      elsif policy_path?(f)
        r[:policy] << f
      elsif cfg["never"].any? { |n| match?(n, f) }
        r[:forbidden] << f
      elsif cfg["owns"].none? { |o| match?(o, f) }
        r[:outside] << f
      elsif SIM_PATHS.any? { |sp| match?(sp, f) } && sim_lane != cfg["lane"]
        r[:sim] << f
      end
    end
    r[:ok] = r.values.all?(&:empty?)
    r
  end

  # `git diff --name-status -z -M -C` -> every path on BOTH sides of a change.
  def self.changed_paths(status_z)
    fields = status_z.split("\0").reject(&:empty?)
    out = []
    i = 0
    while i < fields.length
      st = fields[i]
      if st.start_with?("R", "C")
        out << fields[i + 1] << fields[i + 2]
        i += 3
      else
        out << fields[i + 1]
        i += 2
      end
    end
    out.compact.uniq
  end

  # BOARD machine row `SIM LANE: <lane|NONE>` (same line, exactly ONE row).
  # Absent -> nil (no grant). Two rows, or an empty row, -> BadBrief (refuse).
  def self.sim_lane(board_text)
    text = board_text.to_s.gsub("\r\n", "\n")
    rows = text.scan(/^SIM LANE:[ \t]*([^\n]*)$/).flatten.map(&:strip)
    return nil if rows.empty?
    raise BadBrief, "BOARD has #{rows.length} `SIM LANE:` rows; exactly one is allowed" if rows.length > 1
    v = rows.first
    raise BadBrief, "BOARD `SIM LANE:` row is empty; write NONE or a lane name" if v.empty?
    raise BadBrief, "BOARD `SIM LANE:` value #{v.inspect} is not a lane name" unless v == "NONE" || v.match?(LANE_NAME)
    v == "NONE" ? nil : v
  end

  def self.git(root, *args)
    out, err, st = Open3.capture3("git", "-C", root, *args)
    raise GitError, "git #{args.join(' ')}: #{err.strip}" unless st.success?
    out
  end

  def self.main(argv)
    argv = argv.dup
    lane = argv.shift
    usage = "usage: ruby tools/lane_guard.rb <lane> [--base <ref> | --files <paths...>] [--trust <ref>] [--no-branch-check]"
    return (warn usage) || 2 if lane.nil? || lane.start_with?("--") || !lane.match?(LANE_NAME)
    root = File.expand_path("..", __dir__)
    trust = "main"
    mode = :staged
    base = nil
    files = nil
    branch_check = true
    until argv.empty?
      case (opt = argv.shift)
      when "--trust" then trust = argv.shift or return (warn "--trust needs a ref") || 2
      when "--base"  then mode = :base; base = argv.shift or return (warn "--base needs a ref") || 2
      when "--files" then mode = :files; files = argv.dup; argv.clear
      when "--no-branch-check" then branch_check = false
      else return (warn "unknown option #{opt.inspect}\n#{usage}") || 2
      end
    end
    cfg = parse_brief(git(root, "show", "#{trust}:#{POLICY_DIR}/#{lane}.md"))
    board = begin
      git(root, "show", "#{trust}:#{POLICY_DIR}/BOARD.md")
    rescue GitError
      ""
    end
    holder = sim_lane(board)
    if branch_check
      cur = git(root, "rev-parse", "--abbrev-ref", "HEAD").strip
      if cur != cfg["branch"]
        warn "lane_guard #{cfg['lane']}: REFUSED - on branch #{cur.inspect}, the lane's branch is #{cfg['branch'].inspect} (probes: --no-branch-check)"
        return 1
      end
    end
    case mode
    when :files
      return (warn "--files needs at least one path") || 2 if files.nil? || files.empty?
    when :base
      files = changed_paths(git(root, "diff", "--name-status", "-z", "-M", "-C", "#{base}...HEAD"))
    else
      files = changed_paths(git(root, "diff", "--cached", "--name-status", "-z", "-M", "-C"))
    end
    files = files.map(&:strip).reject(&:empty?)
    r = check(cfg, files, sim_lane: holder)
    if r[:ok]
      puts "lane_guard #{cfg['lane']}: OK (#{files.length} path(s) inside the fence; brief @ #{trust}#{branch_check ? '' : '; branch check OFF'})"
      0
    else
      puts "lane_guard #{cfg['lane']}: REFUSED"
      r[:malformed].each { |f| puts "  MALFORMED (./.. segment): #{f}" }
      r[:policy].each { |f| puts "  POLICY (integrator-only): #{f}" }
      r[:forbidden].each { |f| puts "  FORBIDDEN (never): #{f}" }
      r[:outside].each { |f| puts "  OUTSIDE (not in owns): #{f}  -> PATCH REQUEST in your receipt" }
      r[:sim].each { |f| puts "  SIM LANE required (holder: #{holder.inspect}): #{f}" }
      1
    end
  rescue BadBrief, GitError => e
    warn "lane_guard: #{e.message}"
    2
  end
end

exit LaneGuard.main(ARGV) if $PROGRAM_NAME == __FILE__
