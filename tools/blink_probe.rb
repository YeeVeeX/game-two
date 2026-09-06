# Headless BLINK probe (authoring aid for the wall; no window). Places the pack
# at X,Y in DUNGEON 3, applies `hold` spans, ticks N frames and prints, around
# the blink, the possessed / nearest blinker tiles, the kit cooldown and the
# flash counter, plus every bus `blinked` line. Used to author
# harness/scripts/blink_arrival.json (2026-09-06; owner-named debt s135
# "blink fires in NO reel").
#
#   ruby tools/blink_probe.rb 23,23 "right:30-44" 100
#
# FRAME LAW: this probe counts world.frame AFTER each tick (1-based: the first
# tick prints f1); replay_runner saves capture N right AFTER tick N and names it
# frame_000N (0-based). So "blink at f31" here = capture 0030 in the reel.
# Reads: kit blink { min_tiles, cooldown_frames, flash_frames } (combat.json);
# aggro is pure Chebyshev <= aggro_tiles (controllers.rb select_target), no LoS.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
require "json"
require_relative "../test/support/headless_script"
ROOT = File.expand_path("..", __dir__)
data = Core::DataStore.new("#{ROOT}/data")
at = ARGV[0].split(",").map(&:to_i)
holds = {}
(ARGV[1] || "").split(";").reject(&:empty?).each do |h|
  k, span = h.split(":")
  a, b = span.split("-").map(&:to_i)
  (holds[k.to_sym] ||= []) << [a, b]
end
frames_n = (ARGV[2] || 120).to_i
raw = { seed: 7, start: { zone: "dungeon_3", at: at, progression: { level: 12, xp: 0 } }, hold: holds, run_until: frames_n }
world = Game::World.new(data, seed: 7)
Harness.apply_start(world, raw[:start])
me = world.possessed
serp = world.humans.select { |c| c.kit[:blink] }
puts "possessed #{me.name} @#{me.tile.inspect} (asked #{at.inspect}); pack: #{world.pack.members.map { |m| "#{m.name}@#{m.tile.inspect}" }.join(' ')}"
lines = []
Harness::EventLog.attach(world) { |l| lines << l }
input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
blink_frames = []
frames_n.times do
  input.update(world.frame)
  world.tick(input)
  n = lines.count { |l| l.include?("blinked") }
  blink_frames << world.frame if n > blink_frames.length
  s = serp.min_by { |c| [(c.tile[0] - me.tile[0]).abs, (c.tile[1] - me.tile[1]).abs].max }
  d = [(s.tile[0] - me.tile[0]).abs, (s.tile[1] - me.tile[1]).abs].max
  if (world.frame.between?(28, 46)) || blink_frames.last == world.frame
    puts "  f#{world.frame} me@#{me.tile.inspect} hp=#{me.hp} | #{s.name}@#{s.tile.inspect} d=#{d} cd=#{s.instance_variable_get(:@blink_cooldown)} flash=#{s.instance_variable_get(:@blink_flash)} #{blink_frames.last == world.frame ? '<== BLINK' : ''}"
  end
end
puts "blink frames: #{blink_frames.inspect}"
puts "events: " + lines.map { |l| l[/EVENT (\w+)/, 1] }.compact.tally.inspect
lines.select { |l| l.include?("blinked") }.each { |l| puts "  #{l}" }
