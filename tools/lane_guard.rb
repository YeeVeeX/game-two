#!/usr/bin/env ruby
# Lane guard — the FENCE that makes multi-agent lanes collide-free by
# construction (drafts/_multiagent-lanes-design-20260906.md §2.2).
#
# Hardened after the fresh-eyes review of 2026-09-06 (drafts/_review-lanes-...):
#   * the brief is read from a TRUSTED REF (default `main`, `--trust <ref>`),
#     never from the working tree — a lane cannot widen its own `owns`;
#   * a lane never owns policy (any drafts/lanes/*.md brief or BOARD.md);
#   * renames/copies fence BOTH sides (`git diff --name-status -z -M -C`);
#   * the current branch must equal the brief's `branch:` (staged/--base modes);
#   * `src/game/**` additionally requires the SIM TOKEN line in BOARD.md (at
#     the trusted ref) to name this lane;
#   * fail-CLOSED: unknown options, empty operands, git errors => exit 2.
#
# Front matter (real YAML, parsed with the stdlib):
#   ---
#   lane: s4-equipment
#   branch: lane/s4-equipment
#   owns: [src/game/equipment.rb, test/game/equipment_test.rb]
#   never: [src/game/world.rb]
#   ---
#
#   ruby tools/lane_guard.rb <lane>                       # staged files (pre-commit)
#   ruby tools/lane_guard.rb <lane> --base <ref>          # everything changed since <ref>
#   ruby tools/lane_guard.rb <lane> --files <paths...>    # explicit list (tests/probes; no branch check)
#   ... [--trust <ref>]  brief + BOARD read from <ref> (default main)
require "yaml"
require "open3"

module LaneGuard
  class BadBrief < StandardError; end
  class GitError < StandardError; end

  POLICY_PATHS = ["drafts/lanes/*.md"].freeze          # briefs, README, BOARD: integrator-only
  SIM_PATHS = ["src/game/**"].freeze

  def self.parse_brief(text)
    t = text.sub(/\A\xEF\xBB\xBF/, "").gsub("\r\n", "\n")
    m = t.match(/\A---\n(.*?)\n---(\n|\z)/m)
    raise BadBrief, "brief has no front matter (--- ... ---)" unless m
    cfg = YAML.safe_load(m[1], permitted_classes: [], aliases: false) || {}
    raise BadBrief, "front matter is not a mapping" unless cfg.is_a?(Hash)
    raise BadBrief, "brief has no `lane:`" unless cfg["lane"].is_a?(String)
    owns = Array(cfg["owns"]).map(&:to_s).map(&:strip).reject(&:empty?)
    never = Array(cfg["never"]).map(&:to_s).map(&:strip).reject(&:empty?)
    raise BadBrief, "brief `#{cfg['lane']}` owns nothing" if owns.empty?
    owns.each do |o|
      raise BadBrief, "brief `#{cfg['lane']}` owns POLICY path #{o.inspect} (integrator-only)" if policy?(o)
    end
    { "lane" => cfg["lane"], "branch" => cfg["branch"].to_s, "owns" => owns, "never" => never }
  end

  # A pattern that could cover a policy file (literal or glob).
  def self.policy?(pattern)
    p = pattern.tr("\\", "/")
    return true if POLICY_PATHS.any? { |pp| match?(pp, p) }
    return true if p == "drafts/lanes/" || p == "drafts/lanes/**" || p.start_with?("drafts/") && (p.end_with?("/") || p.end_with?("/**")) && "drafts/lanes/x.md".start_with?(p.sub(/\*\*\z/, ""))
    return true if p == "drafts/" || p == "drafts/**" || p == "./" || p == "**"
    false
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

  # -> { ok:, outside: [...], forbidden: [...], policy: [...], sim: [...] }
  def self.check(cfg, files, token_holder: nil)
    outside, forbidden, policy, sim = [], [], [], []
    files.each do |f|
      if POLICY_PATHS.any? { |pp| match?(pp, f) }
        policy << f
      elsif cfg["never"].any? { |n| match?(n, f) }
        forbidden << f
      elsif cfg["owns"].none? { |o| match?(o, f) }
        outside << f
      elsif SIM_PATHS.any? { |sp| match?(sp, f) } && token_holder != cfg["lane"]
        sim << f
      end
    end
    { ok: [outside, forbidden, policy, sim].all?(&:empty?), outside:, forbidden:, policy:, sim: }
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

  # BOARD line `SIM TOKEN: <holder> ...` -> holder (first token), nil if absent.
  def self.token_holder(board_text)
    m = board_text.to_s.match(/^SIM TOKEN:\s*([^\s(]+)/m)
    m && m[1]
  end

  def self.git(root, *args)
    out, err, st = Open3.capture3("git", "-C", root, *args)
    raise GitError, "git #{args.join(' ')}: #{err.strip}" unless st.success?
    out
  end

  def self.main(argv)
    argv = argv.dup
    lane = argv.shift
    usage = "usage: ruby tools/lane_guard.rb <lane> [--base <ref> | --files <paths...>] [--trust <ref>]"
    return (warn usage) || 2 if lane.nil? || lane.start_with?("--")
    root = File.expand_path("..", __dir__)
    trust = "main"
    mode = :staged
    base = nil
    files = nil
    until argv.empty?
      case (opt = argv.shift)
      when "--trust" then trust = argv.shift or return (warn "--trust needs a ref") || 2
      when "--base"  then mode = :base; base = argv.shift or return (warn "--base needs a ref") || 2
      when "--files" then mode = :files; files = argv.dup; argv.clear
      else return (warn "unknown option #{opt.inspect}\n#{usage}") || 2
      end
    end
    begin
      brief = git(root, "show", "#{trust}:drafts/lanes/#{lane}.md")
    rescue GitError => e
      warn "lane_guard: cannot read the brief at trusted ref #{trust}: #{e.message}"
      return 2
    end
    cfg = parse_brief(brief)
    board = begin
      git(root, "show", "#{trust}:drafts/lanes/BOARD.md")
    rescue GitError
      ""
    end
    holder = token_holder(board)
    case mode
    when :files
      return (warn "--files needs at least one path") || 2 if files.nil? || files.empty?
    when :base
      files = changed_paths(git(root, "diff", "--name-status", "-z", "-M", "-C", "#{base}...HEAD"))
    else
      files = changed_paths(git(root, "diff", "--cached", "--name-status", "-z", "-M", "-C"))
    end
    if mode != :files && !cfg["branch"].empty?
      cur = git(root, "rev-parse", "--abbrev-ref", "HEAD").strip
      if cur != cfg["branch"]
        warn "lane_guard #{cfg['lane']}: REFUSED - on branch #{cur.inspect}, the lane's branch is #{cfg['branch'].inspect}"
        return 1
      end
    end
    files = files.map(&:strip).reject(&:empty?)
    r = check(cfg, files, token_holder: holder)
    if r[:ok]
      puts "lane_guard #{cfg['lane']}: OK (#{files.length} path(s) inside the fence; brief @ #{trust})"
      0
    else
      puts "lane_guard #{cfg['lane']}: REFUSED"
      r[:policy].each { |f| puts "  POLICY (integrator-only): #{f}" }
      r[:forbidden].each { |f| puts "  FORBIDDEN (never): #{f}" }
      r[:outside].each { |f| puts "  OUTSIDE (not in owns): #{f}  -> PATCH REQUEST in your receipt" }
      r[:sim].each { |f| puts "  SIM TOKEN required (holder: #{holder.inspect}): #{f}" }
      1
    end
  rescue BadBrief, GitError => e
    warn "lane_guard: #{e.message}"
    2
  end
end

exit LaneGuard.main(ARGV) if $PROGRAM_NAME == __FILE__
