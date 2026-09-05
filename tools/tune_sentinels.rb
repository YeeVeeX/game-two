# MUNDO VIVO FASE 6 — sentinel authoring tuner for the NEW zones (the
# tune_floor{2,3}_run.rb pattern, generic): waypoint-corrected generation of
# a wall script per zone, headless + deterministic. Route = the zone's own
# geometry law (the forced loop / the lava veins / the maze), walk-by swings
# clear engaged fauna, the reel ends on a fight beat. Manifest = OBSERVED
# event counts (double-replay margin: each count is the single-run count).
#
#   ruby tools/tune_sentinels.rb [zone ...]      (default: all seven)
#
# Emits harness/scripts/<sentinel>.json; prints per-zone kills/shots.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
STEP = 20

ZONES = {
  "floor3_run" => { zone: "low_quay", level: 13, way: [[7, 18], [16, 18], [24, 18], [24, 8], [30, 4], [38, 8], [38, 12]] },
  # Short routes, arriving band +2 over the floor's rung: the sentinel walks
  # straight and never dodges, so it probes LEGIBILITY + determinism of the
  # first fights, not the floor's difficulty (that is the peers' verdict).
  "tower2_run" => { zone: "dungeon_2", level: 10, way: [[29, 40], [22, 38], [16, 30], [16, 22]] },
  "tower3_run" => { zone: "dungeon_3", level: 12, way: [[20, 40], [14, 30], [14, 22]] },
  "tower4_run" => { zone: "dungeon_4", level: 14, way: [[34, 38], [40, 30], [40, 22]] },
  "brasa1_run" => { zone: "ember_1",   level: 15, way: [[8, 16], [14, 20], [22, 17]] },
  "brasa2_run" => { zone: "ember_2",   level: 17, way: [[8, 13], [14, 8], [22, 13], [30, 20], [38, 13], [44, 13]] },
  "brasa3_run" => { zone: "ember_3",   level: 19, way: [[10, 15], [18, 15]] }
}.freeze

def run(cfg, holds, run_until)
  raw = { scenario: "world", seed: 7,
          start: { zone: cfg[:zone], progression: { level: cfg[:level], xp: 0 } },
          hold: holds.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/sentinel_tune.json")
  File.write(tmp, JSON.generate(raw))
  Headless.run_script(tmp)
end

def reach(cfg, holds, waypoint, from_frame, budget: 22)
  frame = from_frame
  last_ok = from_frame
  budget.times do
    r = run(cfg, holds, frame + 4)
    w = r.world
    return [last_ok, :collapsed, r] if w.pack.living.length < 2 || w.possessed.dead?
    last_ok = frame
    return [frame, :left, r] unless w.zone_name == cfg[:zone]
    tile = w.possessed.tile
    return [frame, :arrived, r] if [(waypoint[0] - tile[0]).abs, (waypoint[1] - tile[1]).abs].max <= 1
    dx = (waypoint[0] - tile[0]).clamp(-1, 1)
    dy = (waypoint[1] - tile[1]).clamp(-1, 1)
    steps = [[(waypoint[0] - tile[0]).abs, (waypoint[1] - tile[1]).abs].max, 4].min
    steps.times do |i|
      f = frame + i * STEP
      holds["right"] << [f, f] if dx.positive? && i < (waypoint[0] - tile[0]).abs
      holds["left"]  << [f, f] if dx.negative? && i < (waypoint[0] - tile[0]).abs
      holds["down"]  << [f, f] if dy.positive? && i < (waypoint[1] - tile[1]).abs
      holds["up"]    << [f, f] if dy.negative? && i < (waypoint[1] - tile[1]).abs
    end
    frame += steps * STEP + 40
  end
  [frame, :budget, run(cfg, holds, frame)]
end

targets = ARGV.empty? ? ZONES.keys : ARGV
targets.each do |name|
  cfg = ZONES.fetch(name)
  holds = { "up" => [], "down" => [], "left" => [], "right" => [], "attack" => [] }
  holds["attack"] << [120, 6000] # walk-by swings from the first fight onward
  frame = 12
  status = :arrived
  last = nil
  cfg[:way].each_with_index do |wp, i|
    frame, status, last = reach(cfg, holds, wp, frame + 10)
    kills = last.lines.grep(/^EVENT actor_died/).length
    puts "#{name} W#{i + 1} #{wp.inspect} @#{frame} #{status} kills=#{kills} living=#{last.world.pack.living.length}"
    break unless %i[arrived budget].include?(status)
  end
  # on collapse: end the reel at the last stable frame (the fight is on
  # camera, the pack is standing) — trim any holds past it
  finish = status == :collapsed ? [frame - 30, 200].max : frame + 90
  holds.each_value { |v| v.reject! { |(a, _)| a >= finish } }
  r = run(cfg, holds, finish)
  w = r.world
  kills = r.lines.grep(/^EVENT actor_died/)
  shots = r.lines.grep(/^EVENT projectile_fired/)
  hits = r.lines.grep(/^EVENT attack_hit/)
  entered = r.lines.grep(/^EVENT zone_entered/)
  puts "#{name} FINAL @#{finish} tile=#{w.possessed.tile.inspect} zone=#{w.zone_name} kills=#{kills.length} shots=#{shots.length} hits=#{hits.length} living=#{w.pack.living.length} status=#{status}"
  if w.zone_name != cfg[:zone] || w.pack.living.length < 2
    puts "#{name}: SKIPPED (left zone or pack collapsed) — route needs a hand re-cut"
    next
  end
  frames_of = ->(lines) { lines.map { |l| l[/frame=(\d+)/, 1].to_i } }
  beats = (frames_of.call(hits).first(3) + frames_of.call(kills).first(3) + frames_of.call(shots).first(2))
  captures = ([40, finish / 3, (2 * finish) / 3, finish - 1] + beats.map { |f| f + 2 }).select { |f| f.between?(1, finish - 1) }.uniq.sort
  manifest = { "zone_entered" => entered.length }
  manifest["actor_died"] = kills.length if kills.length.positive?
  manifest["attack_hit"] = hits.length if hits.length.positive?
  manifest["projectile_fired"] = shots.length if shots.length.positive?
  script = {
    "scenario" => "world", "seed" => 7, "width" => 960, "height" => 540,
    "out_dir" => "captures/#{name}",
    "start" => { "zone" => cfg[:zone], "progression" => { "level" => cfg[:level], "xp" => 0 } },
    "hold" => holds.reject { |_, v| v.empty? },
    "captures" => captures,
    "run_until" => finish,
    "manifest" => manifest
  }
  path = File.join(REPO, "harness/scripts/#{name}.json")
  File.write(path, JSON.pretty_generate(script) + "\n")
  puts "#{name}: wrote #{path} (#{captures.length} captures, manifest #{manifest})"
end
