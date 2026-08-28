# v20 T1: floor1_run authoring tuner v2 — waypoint-corrected generation.
# Deterministic replays mean observed drift is exactly correctable: build
# the stream phase by phase, re-running from frame 0 each time and
# appending corrective taps until each waypoint is reached.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/floor1_run.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [], "attack" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 7, start: { zone: "district" },
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/floor1_tune.json")
  File.write(tmp, JSON.generate(raw))
  Headless.run_script(tmp)
end

# Append one tap per axis-step toward the waypoint, run, repeat until there
# (or the budget dies). Returns the frame after arrival.
def reach(waypoint, from_frame, budget: 12)
  frame = from_frame
  budget.times do
    r = run(frame + 4)
    tile = r.world.possessed.tile
    return frame if tile == waypoint
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
  abort "waypoint #{waypoint.inspect} unreached (at #{r.world.possessed.tile.inspect})"
end

# Phase 1: up the west trail to the bridge-4 approach, fighting the camp
# group on the way (attack window rides the walk).
HOLDS["attack"] << [120, 460]
f = reach([11, 75], 10)
puts "P1 done at frame #{f}"
# Phase 2: onto the bridge row and across under the sentry.
f = reach([17, 74], f + 20)
HOLDS["attack"] << [f + 120, f + 420]
f = reach([30, 74], f + 20)   # mid-bridge waypoint (the money shot zone)
puts "P2 mid-bridge at #{f}"
f = reach([38, 74], f + 20)   # east side arrival
puts "P3 east side at #{f}"
f = reach([39, 71], f + 20)   # into the mossy grove
finish = f + 80

r = run(finish)
w = r.world
kills = r.lines.grep(/^EVENT actor_died/).length
fights = r.lines.grep(/fight_resolved/)
puts "final@#{w.possessed.tile.inspect} kills=#{kills} living=#{w.pack.living.length}"
puts fights.join
abort "no combat staged" if kills.zero?
abort "pack losses" if w.pack.living.length < 3

mid_bridge_f = HOLDS["right"].map(&:first).select { |x| x > 0 }.sort.find { |x| x > 600 } || 700

script = {
  "scenario" => "world", "seed" => 7, "width" => 960, "height" => 540,
  "out_dir" => "captures/floor1_run",
  "start" => { "zone" => "district" },
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => [0, 90, 250, 400, 520, 620, 700, 780, 880, finish - 1].uniq.sort,
  "run_until" => finish,
  "manifest" => { "fight_resolved" => 2, "actor_died" => 4 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish} kills=#{kills}"
