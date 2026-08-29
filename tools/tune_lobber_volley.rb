# v20 T1 follow-up: lobber_volley re-cut for floor -1 (v2b district).
# Identity: the volley telegraph choreography — lobber possessed, volleys
# through a long farm march, one pickup riding the route. Manifest wants
# UNCHANGED (special_started 4, attack_hit 106, actor_died 34,
# drop_picked_up 2 per double replay).
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/lobber_volley.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [],
          "attack" => [], "special" => [], "swap" => [], "aim" => [],
          "interact" => [] }

# Non-aborting reach: nil on failure, restores HOLDS.
def try_reach(waypoint, from_frame, zone:, budget: 10, near: 0)
  snapshot = HOLDS.transform_values(&:dup)
  result = begin
    reach(waypoint, from_frame, zone: zone, budget: budget, near: near)
  rescue SystemExit
    nil
  end
  unless result
    HOLDS.each_key { |k| HOLDS[k] = snapshot[k] }
  end
  result
end

def run(run_until)
  raw = { scenario: "world", seed: 11,
          start: { progression: { level: 5, xp: 0 }, zone: "district" },
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/lobber_volley_tune.json")
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

# ---- P3b: continue north through the intact west arena; pick the first
# reachable drop en route (drop_picked_up >= 1 per run).
HOLDS["special"] << [f + 200, f + 200]
HOLDS["special"] << [f + 1000, f + 1000]
picked = false
[[12, 45], [12, 42], [11, 39], [11, 35], [10, 30], [11, 26], [12, 23], [12, 20], [11, 16], [10, 12]].each do |wp|
  HOLDS["attack"] << [f + 2, f + 500]
  f, = reach(wp, f + STEP, zone: "district", near: 2, budget: 18)
  r = run(f + 4)
  unless picked
    live = events(r, "drop_spawned").select { |l| l[/frame=(\d+)/, 1].to_i > r.world.frame - 1500 }
    live.last(2).each do |l|
      tile = [l[/tile=\[(\d+),/, 1].to_i, l[/, (\d+)\]/, 1].to_i]
      res = try_reach(tile, f + STEP, zone: "district", budget: 10)
      next unless res
      f, = res
      HOLDS["interact"] << [f + 8, f + 8]
      f += 30
      r = run(f)
      if events(r, "drop_picked_up").any?
        picked = true
        puts "  P3b pickup at #{tile.inspect}"
        break
      end
    end
  end
  break if picked && events(r, "actor_died").length >= 18 && events(r, "attack_hit").length >= 55
end
r = run(f + 40)
f += 40
puts "P3b kills=#{events(r, 'actor_died').length} hits=#{events(r, 'attack_hit').length} specials=#{events(r, 'special_started').length} picked=#{picked}"
abort "P3b never picked a drop" unless picked

# ---- P3c: over bridge-1 into the east pocket (sentry + trio + the
# respawn pit) until the counts land.
[[14, 15], [24, 15], [34, 15], [39, 13]].each do |wp|
  HOLDS["attack"] << [f + 2, f + 600]
  f, = reach(wp, f + STEP, zone: "district", near: 2, budget: 20)
  r = run(f + 4)
  break if events(r, "actor_died").length >= 18 && events(r, "attack_hit").length >= 55
end
r = run(f + 40)
f += 40
puts "P3c kills=#{events(r, 'actor_died').length} hits=#{events(r, 'attack_hit').length}"

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
  if died >= 18 && hits >= 55 && sp >= 2
    finish = probe + 100
    break
  end
  break if wiped && died >= 18 && hits >= 55
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
  "out_dir" => "captures/lobber_volley",
  "start" => { "progression" => { "level" => 5, "xp" => 0 }, "zone" => "district" },
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => [40, sp_frame + 6, sp_frame + 30, 900, 1500, 2200, finish - 1].select { |c| c < finish }.uniq.sort,
  "run_until" => finish,
  "manifest" => { "special_started" => 4, "attack_hit" => 106, "actor_died" => 34,
                  "drop_picked_up" => 2 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish}"
puts "MANIFEST-PROOF special_started=#{events(r, 'special_started').length} attack_hit=#{events(r, 'attack_hit').length} actor_died=#{events(r, 'actor_died').length}"
