# v20 T6b: floor2_run authoring tuner — waypoint-corrected generation on the
# FIEHONJA floor (tune_floor1_run.rb v2 pattern). Route: entry pocket -> open
# plain east (lurker packs engage on the way) -> F2 main ford under its warden
# -> east plateau -> F4 reef gap -> the arena approach (coral ring + wardens
# on camera). Deterministic; emits harness/scripts/floor2_run.json.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/floor2_run.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [], "attack" => [], "aim" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 7,
          start: { zone: "district_two", progression: { level: 12, xp: 0 } },
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/floor2_tune.json")
  File.write(tmp, JSON.generate(raw))
  Headless.run_script(tmp)
end

def reach(waypoint, from_frame, budget: 24)
  frame = from_frame
  budget.times do
    r = run(frame + 4)
    tile = r.world.possessed.tile
    if r.world.pack.living.length < 2 || r.world.possessed.dead?
      r.world.pack.members.each { |m| puts "  #{m.kit_name}: hp=#{m.hp}/#{m.max_hp} tile=#{m.tile.inspect} dead=#{m.dead?}" }
      abort "pack collapse mid-tune (living=#{r.world.pack.living.length}) at frame #{frame}"
    end
    abort "left the zone mid-tune (#{r.world.zone_name}) at frame #{frame}" unless r.world.zone_name == "district_two"
    puts "  round@#{frame}: tile=#{tile.inspect} kills=#{r.lines.grep(/actor_died/).length}"
    return frame if tile == waypoint
    dx = (waypoint[0] - tile[0]).clamp(-1, 1)
    dy = (waypoint[1] - tile[1]).clamp(-1, 1)
    # combat-tolerant: correct at most 4 steps per round (knockback and
    # body-blocks move the target between rounds — long batches runaway),
    # then settle 60f so shoves resolve before the next correction.
    steps = [[(waypoint[0] - tile[0]).abs, (waypoint[1] - tile[1]).abs].max, 4].min
    steps.times do |i|
      f = frame + i * STEP
      HOLDS["right"] << [f, f] if dx.positive? && i < (waypoint[0] - tile[0]).abs
      HOLDS["left"]  << [f, f] if dx.negative? && i < (waypoint[0] - tile[0]).abs
      HOLDS["down"]  << [f, f] if dy.positive? && i < (waypoint[1] - tile[1]).abs
      HOLDS["up"]    << [f, f] if dy.negative? && i < (waypoint[1] - tile[1]).abs
    end
    frame += steps * STEP + 60
  end
  r = run(frame + 4)
  abort "waypoint #{waypoint.inspect} unreached (at #{r.world.possessed.tile.inspect})"
end

# The reel rides the floor's intended band: start.progression level 12 (the
# arriving player; harness seam = the SaveState load order). Choreography
# found by live tuning (three failed shapes recorded in the ticket doc):
# blind marches abandon the trailing allies to the swarm — so the reel
# PULLS each roadside pack and fights it STANDING (aim-hold faces east
# without stepping), then advances through cleared ground.
HOLDS["attack"] << [200, 6400]
f = reach([20, 22], 10)            # the (24,26) trio dies to walk-by swings
puts "P1 roadside at #{f}"
# P2: push THROUGH the arena band without stopping — dwelling here feeds
# the free allies to the 8-lurker swarm ((32,20)+(30,28) overlap); the
# floor's price is visible either way (an ally may fall covering the
# crossing — the manifest pins it, the C3 stance debt owns the fix).
f = reach([40, 21], f + 20, budget: 40)
puts "P3 ford approach at #{f}"
f = reach([48, 21], f + 40, budget: 30)   # the crossing; the ford warden engages
puts "P4 ford crossed at #{f}"
f = reach([52, 22], f + 40, budget: 30)
finish = f + 200

# (route ends on the east bank — the arena/coral-ring read rides the
# god-view critique; keeping the wall member short keeps it stable.)

r = run(finish)
w = r.world
kills = r.lines.grep(/^EVENT actor_died/)
fights = r.lines.grep(/fight_resolved/)
puts "final@#{w.possessed.tile.inspect} kills=#{kills.length} living=#{w.pack.living.length} zone=#{w.zone_name}"
puts kills.first(8).join
puts fights.first(4).join
abort "no combat staged" if kills.empty?
abort "pack collapsed" if w.pack.living.length < 2 || w.possessed.dead?
abort "left the zone" unless w.zone_name == "district_two"

script = {
  "scenario" => "world", "seed" => 7, "width" => 960, "height" => 540,
  "out_dir" => "captures/floor2_run",
  "start" => { "zone" => "district_two", "progression" => { "level" => 12, "xp" => 0 } },
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => [0, 150, 320, 480, 640, 820, 1000, 1200, 1450, finish - 1].uniq.sort,
  "run_until" => finish,
  "manifest" => { "actor_died" => 2, "fight_resolved" => 1 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish} kills=#{kills.length}"
