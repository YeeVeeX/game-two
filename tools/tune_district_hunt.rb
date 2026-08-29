# v20 T1 follow-up: district_hunt re-cut for floor -1 (v2b district).
# Kill tour: west door trio -> bridge-1 sentry chase -> east arena farm
# stand (respawn anchors are the east pockets, so arrivals feed the
# count). Manifest wants UNCHANGED (actor_died >= 20 per double replay).
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/district_hunt.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [],
          "attack" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 7,
          start: { progression: { level: 5, xp: 0 } },
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/district_hunt_tune.json")
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

def cross(dir, expect_zone, from_frame)
  HOLDS[dir] << [from_frame, from_frame]
  frame = from_frame + STEP + 10
  r = run(frame)
  abort "cross #{dir} -> #{expect_zone} failed (zone=#{r.world.zone_name} tile=#{r.world.possessed.tile.inspect})" if r.world.zone_name != expect_zone
  [frame, r]
end

def events(r, name) = r.lines.grep(/^EVENT #{name} /)
def kills(r) = events(r, "actor_died").grep(/faction=human/).length

# ---- P1: nest -> district west door.
f, = reach([28, 8], 10, zone: "nest")
f, r = cross("right", "district", f + STEP)
puts "P1 door at #{f}"

# ---- P2: west door trio.
f, = reach([10, 12], f + STEP, zone: "district")
HOLDS["attack"] << [f, f + 420]
f += 460
r = run(f)
puts "P2 kills=#{kills(r)}"

# ---- P3: bridge crossing; sentry chases; keep attacking on the move.
f, = reach([14, 15], f + STEP, zone: "district", near: 1, budget: 18)
HOLDS["attack"] << [f, f + 520]
f, = reach([24, 15], f + STEP, zone: "district", near: 1, budget: 18)
r = run(f + 40)
f += 40
puts "P3 kills=#{kills(r)}"

# ---- P4: east arena farm stand at [39,13]; attack through arrivals.
f, = reach([34, 15], f + STEP, zone: "district", near: 1, budget: 18)
f, = reach([39, 13], f + STEP, zone: "district", near: 1, budget: 18)
HOLDS["attack"] << [f, f + 2000]
finish = nil
r = nil
7.times do |i|
  probe = f + 600 + i * 300
  r = run(probe)
  abort "P4 pack wiped early" if events(r, "pack_wiped").any?
  k = kills(r)
  puts "P4 probe@#{probe} kills=#{k} living=#{r.world.pack.living.length}"
  if k >= 10
    finish = probe + 120
    break
  end
end
abort "P4 farm too slow (kills=#{kills(r)})" unless finish

r = run(finish)
k = kills(r)
first_pick = events(r, "drop_spawned").first
script = {
  "scenario" => "world", "seed" => 7, "width" => 960, "height" => 540,
  "out_dir" => "captures/district_hunt",
  "start" => { "progression" => { "level" => 5, "xp" => 0 } },
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => [340, 620, 900, 1400, 1900, 2400, finish - 1].select { |c| c < finish }.uniq.sort,
  "run_until" => finish,
  "manifest" => { "actor_died" => 20 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish}"
puts "MANIFEST-PROOF actor_died=#{events(r, 'actor_died').length} (human=#{k})"
