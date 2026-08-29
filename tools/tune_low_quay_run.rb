# v20 T1 follow-up: low_quay_run re-cut for floor -1 (v2b district leg).
# The traveler: nest (3 inscriptions, swapping bodies) -> district west
# fight + pickups -> bank home -> east over bridge-1 (sentry pickup) ->
# seal breach #1 -> camp (bank #2 + vat tribute) -> district_two ->
# seal breach #2 -> slow_door -> low_quay arrival fight.
# Manifest wants UNCHANGED.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/low_quay_run.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [],
          "attack" => [], "interact" => [], "swap" => [], "dodge" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 13,
          start: { banked: 2000, progression: { level: 5, xp: 0 } },
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/low_quay_tune.json")
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

# Non-aborting reach: nil on failure, restores HOLDS so a failed try
# leaves no stray taps.
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

# ---- P1: three inscriptions at the nest altar — swap, then WALK each
# newly-possessed body onto the altar tile before its interact.
f, = reach([16, 8], 10, zone: "nest")
HOLDS["interact"] << [f + 8, f + 8]     # inscribe body 1
HOLDS["swap"] << [f + 40, f + 40]
f, = reach([16, 8], f + 70, zone: "nest", budget: 10)
HOLDS["interact"] << [f + 8, f + 8]     # inscribe body 2
HOLDS["swap"] << [f + 40, f + 40]
f, = reach([16, 8], f + 70, zone: "nest", budget: 10)
HOLDS["interact"] << [f + 8, f + 8]     # inscribe body 3
f += 30
r = run(f)
ins = events(r, "inscribed").length
puts "P1 inscribed=#{ins}"
abort "P1 needs 3 inscriptions, got #{ins}" if ins < 3

# ---- P2: district west fight; pick 3 drops.
f, = reach([28, 8], f + STEP, zone: "nest")
f, r = cross("right", "district", f + STEP)
f, = reach([10, 12], f + STEP, zone: "district")
HOLDS["attack"] << [f, f + 420]
fight_end = f + 460
r = run(fight_end)
kills = events(r, "actor_died").grep(/faction=human/).length
puts "P2 kills=#{kills}"
abort "P2 needs >=3 kills" if kills < 3
picked = 0
events(r, "drop_spawned").first(4).each do |l|
  tile = [l[/tile=\[(\d+),/, 1].to_i, l[/, (\d+)\]/, 1].to_i]
  f, = reach(tile, fight_end + STEP, zone: "district", budget: 16)
  HOLDS["interact"] << [f + 8, f + 8]
  fight_end = f + STEP
  r2 = run(fight_end + 8)
  picked = events(r2, "drop_picked_up").length
  puts "  pickup at #{tile.inspect} -> #{picked}"
  break if picked >= 3
end
abort "P2 needs >=3 pickups" if picked < 3
f = fight_end + 8

# ---- P3: bank the carry at home (banked #1).
f, = reach([1, 13], f + STEP, zone: "district", budget: 16)
f, = cross("left", "nest", f + STEP)
f, = reach([12, 8], f + STEP, zone: "nest")
HOLDS["interact"] << [f + 8, f + 8]
f += 30
r = run(f)
abort "P3 bank missed" if events(r, "banked").empty?
puts "P3 banked=#{events(r, 'banked').length}"

# ---- P4: east over bridge-1; kill the chasing sentry, pick its drop.
f, = reach([28, 8], f + STEP, zone: "nest")
f, = cross("right", "district", f + STEP)
f, = reach([14, 15], f + STEP, zone: "district", near: 1, budget: 18)
f, = reach([24, 15], f + STEP, zone: "district", near: 1, budget: 18)
HOLDS["attack"] << [f, f + 520]
f += 560
r = run(f)
fresh = events(r, "drop_spawned").select { |l| l[/frame=(\d+)/, 1].to_i > f - 620 }
abort "P4 no sentry drop" if fresh.empty?
got = events(r, "drop_picked_up").length
fresh.each do |l|
  tile = [l[/tile=\[(\d+),/, 1].to_i, l[/, (\d+)\]/, 1].to_i]
  res = try_reach(tile, f + STEP, zone: "district", budget: 12)
  next unless res
  f, = res
  HOLDS["interact"] << [f + 8, f + 8]
  f += 30
  r = run(f)
  now = events(r, "drop_picked_up").length
  puts "  P4 pickup try at #{tile.inspect} -> #{now}"
  break if now > got
end
abort "P4 pickup failed" if events(r, "drop_picked_up").length <= got
puts "P4 pickups total=#{events(r, 'drop_picked_up').length}"

# ---- P5: fight through the east pocket; pick one more drop (#5);
# then the seal; breach #1; cross.
f, = reach([34, 15], f + STEP, zone: "district", near: 1, budget: 18)
HOLDS["attack"] << [f, f + 900]
f, = reach([39, 13], f + STEP, zone: "district", near: 1, budget: 20)
r = run(f + 200)
f += 200
fresh = events(r, "drop_spawned").select { |l| l[/frame=(\d+)/, 1].to_i > f - 1100 }
abort "P5 no east drop" if fresh.empty?
got5 = events(r, "drop_picked_up").length
fresh.reverse_each do |l|
  tile = [l[/tile=\[(\d+),/, 1].to_i, l[/, (\d+)\]/, 1].to_i]
  res = try_reach(tile, f + STEP, zone: "district", budget: 12)
  next unless res
  f, = res
  HOLDS["interact"] << [f + 8, f + 8]
  f += 30
  r = run(f)
  now = events(r, "drop_picked_up").length
  puts "  P5 pickup try at #{tile.inspect} -> #{now}"
  break if now > got5
end
puts "P5 pickups total=#{events(r, 'drop_picked_up').length}"
abort "P5 needs >=5 pickups" if events(r, "drop_picked_up").length < 5
f, = reach([41, 13], f + STEP, zone: "district", budget: 20)
HOLDS["interact"] << [f + 8, f + 8]
f += 30
r = run(f)
abort "P5 seal 1 not breached" if events(r, "seal_breached").empty?
puts "P5 seal_breached=#{events(r, 'seal_breached').length}"
f, r = cross("right", "camp", f + STEP)   # [42,13] -> camp [1,5]

# ---- P6: camp: bank leftovers if any, tribute at the vat (heals/regrows).
f, = reach([8, 4], f + STEP, zone: "camp", budget: 16)
HOLDS["interact"] << [f + 8, f + 8]       # bank #2 (carried from P4/P5 fights)
f, = reach([10, 6], f + STEP, zone: "camp", budget: 16)
HOLDS["interact"] << [f + 8, f + 8]       # vat tribute
f += 30
r = run(f)
tr = events(r, "tribute_paid").length
bk = events(r, "banked").length
puts "P6 banked_total=#{bk} tribute_paid=#{tr}"
abort "P6 tribute missed" if tr.zero?
abort "P6 needs 2 banked, got #{bk}" if bk < 2

# ---- P7: camp -> district_two -> its seal [41,13]; breach #2; cross.
f, = reach([19, 5], f + STEP, zone: "camp", near: 1, budget: 18)
r = run(f + 30)
if r.world.zone_name != "district_two"
  f, r = cross("right", "district_two", f + STEP)
else
  f += 30
end
HOLDS["attack"] << [f, f + 1600]
waypoints = [[8, 12], [14, 12], [20, 12], [26, 12], [32, 12], [38, 12]]
re_entries = 0
guard = 0
until waypoints.empty?
  guard += 1
  abort "P7 march guard blown" if guard > 90
  r = run(f + 4)
  case r.world.zone_name
  when "camp"
    # A wipe mid-march respawns at camp (deep-side home). Re-enter and
    # resume: pass-1 kills stay dead, so each pass runs cleaner.
    re_entries += 1
    abort "P7 wiped #{re_entries}x — march untenable" if re_entries > 3
    puts "  P7 wiped; re-entering district_two (pass #{re_entries + 1})"
    f, = reach([19, 5], f + STEP, zone: "camp", near: 1, budget: 14)
    r2 = run(f + 30)
    if r2.world.zone_name == "camp"
      f, = cross("right", "district_two", f + STEP)
    else
      f += 30
    end
    HOLDS["attack"] << [f, f + 1200]
  when "district_two"
    tile = r.world.possessed.tile
    wp = waypoints.first
    if [(wp[0] - tile[0]).abs, (wp[1] - tile[1]).abs].max <= 2
      waypoints.shift
      next
    end
    HOLDS["dodge"] << [f + 6, f + 6] if (wp[0] - tile[0]).abs > 3
    dx = (wp[0] - tile[0]).clamp(-1, 1)
    dy = (wp[1] - tile[1]).clamp(-1, 1)
    steps = [[(wp[0] - tile[0]).abs, (wp[1] - tile[1]).abs].max, 4].min
    steps.times do |i|
      ff = f + i * STEP
      HOLDS["right"] << [ff, ff] if dx.positive? && i < (wp[0] - tile[0]).abs
      HOLDS["left"]  << [ff, ff] if dx.negative? && i < (wp[0] - tile[0]).abs
      HOLDS["down"]  << [ff, ff] if dy.positive? && i < (wp[1] - tile[1]).abs
      HOLDS["up"]    << [ff, ff] if dy.negative? && i < (wp[1] - tile[1]).abs
    end
    f += steps * STEP + STEP
  else
    abort "P7 march lost in #{r.world.zone_name}"
  end
end
f, = reach([41, 13], f + STEP, zone: "district_two", budget: 20)
HOLDS["interact"] << [f + 8, f + 8]
f += 30
r = run(f)
abort "P7 seal 2 not breached" if events(r, "seal_breached").length < 2
puts "P7 seal_breached=#{events(r, 'seal_breached').length}"
f, r = cross("right", "slow_door", f + STEP)

# ---- P8: slow_door [7,7]-ish -> [7,1] -> low_quay; short arrival fight.
f, = reach([7, 2], f + STEP, zone: "slow_door", budget: 16)
f, r = cross("up", "low_quay", f + STEP)
puts "P8 in low_quay at #{r.world.possessed.tile.inspect}"
f, = reach([6, 6], f + STEP, zone: "low_quay", near: 1, budget: 18)
HOLDS["attack"] << [f, f + 380]
finish = f + 420
r = run(finish)
ze = events(r, "zone_entered").length
puts "P8 zone_entered=#{ze}"
abort "zone_entered < 6" if ze < 6

script = {
  "scenario" => "world", "seed" => 13, "width" => 960, "height" => 540,
  "out_dir" => "captures/low_quay_run",
  "start" => { "banked" => 2000, "progression" => { "level" => 5, "xp" => 0 } },
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => [40, 700, 1600, events(r, "seal_breached").first[/frame=(\d+)/, 1].to_i + 30,
                 events(r, "tribute_paid").first[/frame=(\d+)/, 1].to_i + 12,
                 events(r, "seal_breached").last[/frame=(\d+)/, 1].to_i + 30,
                 events(r, "zone_entered").last[/frame=(\d+)/, 1].to_i + 40,
                 finish - 1].uniq.sort,
  "run_until" => finish,
  "manifest" => { "inscribed" => 6, "seal_breached" => 4, "banked" => 2,
                  "tribute_paid" => 2, "drop_picked_up" => 10, "zone_entered" => 12 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish}"
puts "MANIFEST-PROOF inscribed=#{events(r, 'inscribed').length} seal_breached=#{events(r, 'seal_breached').length} banked=#{events(r, 'banked').length} tribute_paid=#{events(r, 'tribute_paid').length} drop_picked_up=#{events(r, 'drop_picked_up').length} zone_entered=#{ze}"
