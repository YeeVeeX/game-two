# v20 T1 follow-up: lobber_reach re-cut for floor -1 (v2b district).
# Identity: the lobber's level-5 ranged reach — swap to lobber at the
# mouth, farm the south-trail spawns northward with projectiles + two
# volley casts, then idle-wipe deep. Manifest wants UNCHANGED
# (special_started 2, attack_hit 63, actor_died 23 per double replay).
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/lobber_reach.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [],
          "attack" => [], "special" => [], "swap" => [], "aim" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 11,
          start: { progression: { level: 5, xp: 0 }, zone: "district" },
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/lobber_reach_tune.json")
  File.write(tmp, JSON.generate(raw))
  Headless.run_script(tmp)
end

def reach(waypoint, from_frame, zone:, budget: 14, near: 0)
  frame = from_frame
  budget.times do
    r = run(frame + 4)
    abort "reach #{waypoint.inspect}: wrong zone #{r.world.zone_name} (want #{zone})" if r.world.zone_name != zone
    tile = r.world.possessed.tile
    return [frame, r] if [(waypoint[0] - tile[0]).abs, (waypoint[1] - tile[1]).abs].max <= near
    dx = (waypoint[0] - tile[0]).clamp(-1, 1)
    dy = (waypoint[1] - tile[1]).clamp(-1, 1)
    steps = [(waypoint[0] - tile[0]).abs, (waypoint[1] - tile[1]).abs].max
    steps.times do |i|
      f = frame + i * STEP
      HOLDS["right"] << [f, f] if dx.positive? && i < (waypoint[0] - tile[0]).abs
      HOLDS["left"]  << [f, f] if dx.negative? && i < (waypoint[0] - tile[0]).abs
      HOLDS["down"]  << [f, f] if dy.positive? && i < (waypoint[1] - tile[1]).abs
      HOLDS["up"]    << [f, f] if dy.negative? && i < (waypoint[1] - tile[1]).abs
    end
    frame += steps * STEP + STEP
  end
  r = run(frame + 4)
  abort "waypoint #{waypoint.inspect} unreached (at #{r.world.possessed.tile.inspect} zone=#{r.world.zone_name})"
end

def events(r, name) = r.lines.grep(/^EVENT #{name} /)

# ---- P1: swap until the lobber is possessed (seat order cycles).
f = 30
possessed = nil
3.times do
  r = run(f + 10)
  possessed = r.world.possessed.kit_name
  break if possessed == :lobber
  HOLDS["swap"] << [f + 12, f + 12]
  f += 40
end
r = run(f + 10)
abort "P1 could not possess lobber (#{r.world.possessed.kit_name})" if r.world.possessed.kit_name != :lobber
puts "P1 lobber possessed at #{f}"

# ---- P2: north out of the mouth pocket; engage [14,76] group at range.
f, = reach([11, 80], f + STEP, zone: "district", near: 1, budget: 12)
HOLDS["attack"] << [f, f + 700]
HOLDS["special"] << [f + 90, f + 90]
f, = reach([12, 74], f + STEP, zone: "district", near: 2, budget: 16)
r = run(f + 60)
f += 60
puts "P2 kills=#{events(r, 'actor_died').length} hits=#{events(r, 'attack_hit').length} specials=#{events(r, 'special_started').length}"

# ---- P3: farm northward up the trail; more volleys spaced past exhaust.
HOLDS["special"] << [f + 120, f + 120]
[[13, 68], [11, 64], [11, 58], [10, 56], [11, 53], [12, 52]].each do |wp|
  HOLDS["attack"] << [f + 2, f + 500]
  f, = reach(wp, f + STEP, zone: "district", near: 2, budget: 18)
end
r = run(f + 40)
f += 40
puts "P3 kills=#{events(r, 'actor_died').length} hits=#{events(r, 'attack_hit').length} specials=#{events(r, 'special_started').length}"

# ---- P3b: continue north through the intact west arena (the trail
# spine), volleys re-tapped past exhaust windows.
HOLDS["special"] << [f + 200, f + 200]
HOLDS["special"] << [f + 1000, f + 1000]
[[12, 45], [12, 42], [11, 39], [11, 35], [10, 30], [11, 26], [12, 23], [12, 20], [11, 16], [10, 12]].each do |wp|
  HOLDS["attack"] << [f + 2, f + 500]
  f, = reach(wp, f + STEP, zone: "district", near: 2, budget: 18)
  r = run(f + 4)
  break if events(r, "actor_died").length >= 13 && events(r, "attack_hit").length >= 34
end
r = run(f + 40)
f += 40
puts "P3b kills=#{events(r, 'actor_died').length} hits=#{events(r, 'attack_hit').length} specials=#{events(r, 'special_started').length}"

# ---- P4: idle where the march ended; arrivals finish the counts.
finish = nil
r2 = nil
8.times do |i|
  probe = f + 400 + i * 400
  r2 = run(probe)
  died = events(r2, "actor_died").length
  hits = events(r2, "attack_hit").length
  sp = events(r2, "special_started").length
  wiped = events(r2, "pack_wiped").any?
  puts "P4 probe@#{probe} died=#{died} hits=#{hits} specials=#{sp} wiped=#{wiped}"
  if died >= 12 && hits >= 32 && sp >= 1
    finish = probe + 100
    break
  end
  break if wiped && died >= 12 && hits >= 32
end
r2 = run(f + 4000) unless finish
unless finish
  died = events(r2, "actor_died").length
  hits = events(r2, "attack_hit").length
  abort "P4 fell short: died=#{died} hits=#{hits} specials=#{events(r2, 'special_started').length}"
end

r = run(finish)
sp_frame = events(r, "special_started").first[/frame=(\d+)/, 1].to_i
script = {
  "scenario" => "world", "seed" => 11, "width" => 960, "height" => 540,
  "out_dir" => "captures/lobber_reach",
  "start" => { "progression" => { "level" => 5, "xp" => 0 }, "zone" => "district" },
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => [40, sp_frame + 6, sp_frame + 30, 900, 1500, 2200, finish - 1].select { |c| c < finish }.uniq.sort,
  "run_until" => finish,
  "manifest" => { "special_started" => 2, "attack_hit" => 63, "actor_died" => 23 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish}"
puts "MANIFEST-PROOF special_started=#{events(r, 'special_started').length} attack_hit=#{events(r, 'attack_hit').length} actor_died=#{events(r, 'actor_died').length}"
