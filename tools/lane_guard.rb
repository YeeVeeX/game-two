#!/usr/bin/env ruby
# Lane guard — the FENCE that makes multi-agent lanes collide-free by
# construction (drafts/_multiagent-lanes-design-20260906.md §2.2).
#
# A lane brief (drafts/lanes/<lane>.md) opens with YAML-ish front matter:
#   ---
#   lane: s4-equipment
#   branch: lane/s4-equipment
#   owns:
#     - src/game/equipment.rb
#     - test/game/equipment_test.rb
#   never:
#     - src/game/world.rb
#   ---
# This tool lists the files the lane has touched and refuses (exit 1) any
# path outside `owns` or inside `never`. Globs: a trailing `/` or `/**`
# means "anything under"; `*` matches within one segment.
#
#   ruby tools/lane_guard.rb <lane>                 # staged files (pre-commit)
#   ruby tools/lane_guard.rb <lane> --base main     # every file changed vs main
#   ruby tools/lane_guard.rb <lane> --files a b c   # explicit list (tests)
#
# No dependencies beyond git + Ruby. Pure: same inputs, same verdict.
module LaneGuard
  class BadBrief < StandardError; end

  # Parses the front matter into { "lane" => ..., "owns" => [...], "never" => [...] }.
  def self.parse_brief(text)
    m = text.match(/\A---\r?\n(.*?)\r?\n---/m)
    raise BadBrief, "brief has no front matter (--- ... ---)" unless m
    cfg = { "owns" => [], "never" => [] }
    key = nil
    m[1].each_line do |raw|
      line = raw.rstrip
      next if line.strip.empty?
      if (it = line.match(/\A\s*-\s+(.+)\z/)) && key
        cfg[key] << it[1].strip
      elsif (kv = line.match(/\A([a-z_]+):\s*(.*)\z/))
        key = kv[1]
        val = kv[2].strip
        if val.empty?
          cfg[key] ||= []
        else
          cfg[key] = val
        end
      else
        raise BadBrief, "unparseable front matter line: #{line.inspect}"
      end
    end
    raise BadBrief, "brief has no `lane:`" unless cfg["lane"].is_a?(String)
    raise BadBrief, "brief `#{cfg['lane']}` owns nothing" if cfg["owns"].empty?
    cfg
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

  # -> { ok: bool, outside: [...], forbidden: [...] }
  def self.check(cfg, files)
    outside = []
    forbidden = []
    files.each do |f|
      if cfg["never"].any? { |n| match?(n, f) }
        forbidden << f
      elsif cfg["owns"].none? { |o| match?(o, f) }
        outside << f
      end
    end
    { ok: outside.empty? && forbidden.empty?, outside:, forbidden: }
  end

  def self.main(argv)
    lane = argv.shift or abort "usage: ruby tools/lane_guard.rb <lane> [--base <ref> | --files <paths...>]"
    root = File.expand_path("..", __dir__)
    brief = File.join(root, "drafts", "lanes", "#{lane}.md")
    abort "no brief at #{brief}" unless File.file?(brief)
    cfg = parse_brief(File.read(brief, encoding: "utf-8"))
    files =
      if argv.first == "--files"
        argv.drop(1)
      elsif argv.first == "--base"
        `git -C "#{root}" diff --name-only #{argv[1]}...HEAD`.split("\n")
      else
        `git -C "#{root}" diff --cached --name-only`.split("\n")
      end
    files = files.map(&:strip).reject(&:empty?)
    r = check(cfg, files)
    if r[:ok]
      puts "lane_guard #{cfg['lane']}: OK (#{files.length} file(s) inside the fence)"
      0
    else
      puts "lane_guard #{cfg['lane']}: REFUSED"
      r[:forbidden].each { |f| puts "  FORBIDDEN (never): #{f}" }
      r[:outside].each { |f| puts "  OUTSIDE (not in owns): #{f}  -> PATCH REQUEST in drafts/lanes/BOARD.md" }
      1
    end
  end
end

exit LaneGuard.main(ARGV.dup) if $PROGRAM_NAME == __FILE__
