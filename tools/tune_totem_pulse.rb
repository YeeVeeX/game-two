# v20 T4: cut harness/scripts/totem_pulse.json — the totem's own wall
# script (new regression surface: the contested heal pulse on floor -1).
# Beat sheet (single run, start.zone=district, level 5 — sustain_run's
# staged-progression precedent):
#   walk the west trail from the mouth [11,87] north (trail rushers
#   engage en route — wounds are the heal targets), onto bridge 3 via
#   row 54, kill the bridge guardian at [26,54] (fight_resolved beside
#   the totem), then DWELL wounded inside the radius-2 field across TWO
#   pulses (~f900 + ~f1800 district ticks + hitstop drift — empirical
#   frames read back from the EVENT log).
# Captures: spawn, trail, guardian fight, both pulse rings (mid
# expansion), post-heal dwell, final. Manifest wants = double-replay
# minimums (min law) set from the cut's actual counts.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
OUT = File.join(REPO, "harness/scripts/totem_pulse.json")
STEP = 20
START = { zone: "district", progression: { level: 5, xp: 0 } }.freeze

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [],
          "attack" => [], "interact" => [], "sustain" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 7, start: START,
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/totem_pulse_tune.json")
  File.write(tmp, JSON.generate(raw))
  Headless.run_script(tmp)
end

def reach(waypoint, from_frame, zone:, budget: 16, near: 0)
  frame = from_frame
  budget.times do
    r = run(frame + 4)
    abort "reach #{waypoint.inspect}: wrong zone #{r.world.zone_name}" if r.world.zone_name != zone
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
  abort "waypoint #{waypoint.inspect} unreached (at #{r.world.possessed.tile.inspect})"
end

def events(r, name) = r.lines.grep(/^EVENT #{name} /)

CAPS = [0]

# ---- Leg 1: up the west trail (waypoints hug the dirt column).
f, = reach([11, 78], 20, zone: "district", near: 1)
CAPS << f
f, = reach([11, 66], f + STEP, zone: "district", near: 1, budget: 20)
f, r = reach([11, 59], f + STEP, zone: "district", near: 1, budget: 20)
puts "leg1 trail: at #{r.world.possessed.tile.inspect} f=#{f} kills=#{events(r, 'actor_died').length}"

# ---- Leg 2: clear the trail pocket if engaged, then the upper bend.
HOLDS["attack"] << [f + 10, f + 400]
f += 440
r = run(f)
puts "leg2 trail fight: kills=#{events(r, 'actor_died').grep(/faction=human/).length} hp=#{r.world.possessed.hp}/#{r.world.possessed.max_hp}"
f, = reach([11, 56], f + STEP, zone: "district", near: 1, budget: 18)
f, r = reach([12, 54], f + STEP, zone: "district", near: 0, budget: 18)
puts "leg2 bend: at #{r.world.possessed.tile.inspect} f=#{f}"

# ---- Leg 3: east along row 54 to the bridge, fight the guardian.
f, = reach([17, 54], f + STEP, zone: "district", near: 0, budget: 18)
CAPS << f
f, r = reach([24, 54], f + STEP, zone: "district", near: 1, budget: 18)
puts "leg3 bridge approach: at #{r.world.possessed.tile.inspect} f=#{f}"
HOLDS["attack"] << [f + 10, f + 700]
f += 740
r = run(f)
guard_dead = events(r, "actor_died").any? { |l| l.include?("rusher_hater") }
puts "leg3 guardian fight: guardian_dead=#{guard_dead} hp=#{r.world.possessed.hp}/#{r.world.possessed.max_hp} fights=#{events(r, 'fight_resolved').length}"
CAPS << f - 400

# ---- Leg 4: settle INTO the radius-2 field and dwell across two pulses.
f, r = reach([25, 55], f + STEP, zone: "district", near: 0, budget: 18)
abort "dwell tile wrong: #{r.world.possessed.tile.inspect}" unless r.world.possessed.tile == [25, 55]
wounded = r.world.pack.living.count { |m| m.hp < m.max_hp }
arrival = f
puts "leg4 dwell from f=#{f} wounded=#{wounded} (heal targets)"

r = run(arrival + 2000)
pulses = events(r, "totem_pulse")
pf_all = pulses.map { |l| l[/frame=(\d+)/, 1].to_i }
pf = pf_all.select { |x| x > arrival }
abort "want >=2 pulses after arrival #{arrival} (all: #{pf_all.inspect})" if pf.length < 2
healed = pulses.last(pf.length).map { |l| l[/healed=(\d+)/, 1].to_i }
puts "pulses at #{pf_all.inspect} post-arrival #{pf.inspect} healed=#{healed.inspect}"
abort "no pulse healed anybody — the dwell must carry wounds" if healed.sum.zero?

CAPS << pf[0] + 12 << pf[0] + 24 << pf[0] + 60
CAPS << pf[1] + 12 << pf[1] + 24
final = pf[1] + 80
CAPS << final - 1

raw = {
  scenario: "world", seed: 7, width: 960, height: 540,
  out_dir: "captures/totem_pulse",
  start: START,
  hold: HOLDS.reject { |_, v| v.empty? }.sort.to_h,
  run_until: final,
  captures: CAPS.uniq.sort,
  manifest: {
    totem_pulse: 4,
    fight_resolved: [events(r, "fight_resolved").length, 1].max * 2,
    attack_hit: [events(r, "attack_hit").length / 2, 1].max * 2
  }
}
File.write(OUT, JSON.pretty_generate(raw))
r2 = Headless.run_script(OUT)
puts "FINAL: pulses=#{events(r2, 'totem_pulse').length} healed=#{events(r2, 'totem_pulse').map { |l| l[/healed=(\d+)/, 1].to_i }.inspect} " \
     "fights=#{events(r2, 'fight_resolved').length} hits=#{events(r2, 'attack_hit').length} md5=#{r2.md5}"
puts "wrote #{OUT}"
