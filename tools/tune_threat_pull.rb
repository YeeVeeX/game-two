# v20 T1 follow-up: threat_pull re-cut for floor -1 (v2b district).
# Identity: the leash/retarget surface — pull-and-release cycles through
# the west door (zone-cross strips focus; linger 90f -> human_leashed;
# re-entry re-acquires -> human_retargeted), then one carried death for
# corpse_loaded. Manifest wants UNCHANGED (human_retargeted 20,
# human_leashed 20, corpse_loaded 1 per double replay).
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/threat_pull.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [],
          "attack" => [], "interact" => [], "swap" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 42,
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/threat_pull_tune.json")
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

# ---- P1: nest -> district door; possess the striker (fastest retreat).
f, = reach([28, 8], 10, zone: "nest")
f, r = cross("right", "district", f + STEP)
puts "P1 door at #{f}"
3.times do
  r = run(f + 10)
  break if r.world.possessed.kit_name == :striker
  HOLDS["swap"] << [f + 12, f + 12]
  f += 40
end
r = run(f + 10)
abort "P1 could not possess striker" if r.world.possessed.kit_name != :striker

# ---- P2: TOUCHLESS pull-and-release cycles — bait at the aggro edge
# ([6,9]: Cheb 6-7 from the [12,12]/[13,10] pair), retreat into the
# beachhead pocket BEFORE contact (no provocation, allies stand down,
# chasers lose focus shielded, linger 90f, leash home).
leashes = 0
retargets = 0
r = nil
10.times do |cycle|
  f, = reach([6, 9], f + STEP, zone: "district", near: 1, budget: 12)
  f, = reach([2, 13], f + STEP, zone: "district", near: 1, budget: 12)
  r = run(f + 300)
  f += 300
  leashes = events(r, "human_leashed").length
  retargets = events(r, "human_retargeted").length
  puts "P2 cycle #{cycle + 1}: leashes=#{leashes} retargets=#{retargets}"
  abort "P2 mechanism dead (cycle 1 leashed nothing) — RETIRE to C3" if cycle.zero? && leashes.zero?
  break if leashes >= 10 && retargets >= 10
end
abort "P2 fell short: leashes=#{leashes} retargets=#{retargets}" if leashes < 10 || retargets < 10

# ---- P3: kill one, pick its drop, carry east; die carrying.
f, = reach([10, 12], f + STEP, zone: "district", near: 1, budget: 14)
HOLDS["attack"] << [f, f + 600]
f += 640
r = run(f)
drops = events(r, "drop_spawned")
abort "P3 no drop" if drops.empty?
got = events(r, "drop_picked_up").length
drops.last(3).each do |l|
  tile = [l[/tile=\[(\d+),/, 1].to_i, l[/, (\d+)\]/, 1].to_i]
  frame_res = begin
    reach(tile, f + STEP, zone: "district", budget: 12)
  rescue SystemExit
    nil
  end
  next unless frame_res
  f, = frame_res
  HOLDS["interact"] << [f + 8, f + 8]
  f += 30
  r = run(f)
  break if events(r, "drop_picked_up").length > got
end
abort "P3 pickup failed" if events(r, "drop_picked_up").length <= got
puts "P3 carrying"

# ---- P4: walk into the east arena unarmed; the carrier dies.
[[14, 15], [24, 15], [34, 15]].each do |wp|
  res = begin
    reach(wp, f + STEP, zone: "district", near: 2, budget: 16)
  rescue SystemExit
    nil
  end
  break unless res
  f, = res
  r = run(f + 4)
  break if events(r, "corpse_loaded").any?
end
r = run(f + 2400)
loaded = events(r, "corpse_loaded")
if loaded.empty?
  puts "  DIAG tile=#{r.world.possessed.tile.inspect} living=#{r.world.pack.members.map { |m| [m.kit_name, m.hp, m.carried] }.inspect} zone=#{r.world.zone_name}"
  abort "P4 corpse_loaded never fired"
end
load_frame = loaded.first[/frame=(\d+)/, 1].to_i
finish = load_frame + 200

r = run(finish)
first_leash = events(r, "human_leashed").first[/frame=(\d+)/, 1].to_i
script = {
  "scenario" => "world", "seed" => 42, "width" => 960, "height" => 540,
  "out_dir" => "captures/threat_pull",
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => [360, first_leash + 20, first_leash + 90, 1500, 2600,
                 load_frame - 30, load_frame + 30, finish - 1].select { |c| c < finish }.uniq.sort,
  "run_until" => finish,
  "manifest" => { "human_retargeted" => 20, "human_leashed" => 20, "corpse_loaded" => 1 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish}"
puts "MANIFEST-PROOF human_retargeted=#{events(r, 'human_retargeted').length} human_leashed=#{events(r, 'human_leashed').length} corpse_loaded=#{events(r, 'corpse_loaded').length}"
