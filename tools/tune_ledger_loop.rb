# v20 T1 follow-up: ledger_loop re-cut for floor -1 (v2b district).
# Beat sheet (retired S-era identity): fight at the west door arena ->
# pick 2 drops -> bank home (positive tally) -> return, pick the third ->
# carry it east over bridge-1 into the arena -> WIPE (corpse_loaded +
# pack_wiped = the negative ledger beat). Manifest wants UNCHANGED.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/ledger_loop.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [],
          "attack" => [], "interact" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 7,
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/ledger_loop_tune.json")
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

# ---- P1: nest -> district west door.
f, = reach([28, 8], 10, zone: "nest")
f, r = cross("right", "district", f + STEP)
puts "P1 door at #{f}"

# ---- P2: engage the [12,12]/[13,10] pair at level 1 (longer fight).
f, = reach([10, 12], f + STEP, zone: "district")
HOLDS["attack"] << [f, f + 700]
fight_end = f + 740
r = run(fight_end)
kills = events(r, "actor_died").grep(/faction=human/).length
puts "P2 kills=#{kills} drops=#{events(r, 'drop_spawned').length}"
abort "P2 needs >=2 kills, got #{kills}" if kills < 2

# ---- P3: pick 2 drops.
picked = 0
events(r, "drop_spawned").first(3).each do |l|
  tile = [l[/tile=\[(\d+),/, 1].to_i, l[/, (\d+)\]/, 1].to_i]
  f, = reach(tile, fight_end + STEP, zone: "district", budget: 16)
  HOLDS["interact"] << [f + 8, f + 8]
  fight_end = f + STEP
  r2 = run(fight_end + 8)
  picked = events(r2, "drop_picked_up").length
  puts "  pickup at #{tile.inspect} -> #{picked}"
  break if picked >= 2
end
abort "P3 needs >=2 pickups" if picked < 2
f = fight_end + 8

# ---- P4: home, bank the tally.
f, = reach([1, 13], f + STEP, zone: "district", budget: 16)
f, = cross("left", "nest", f + STEP)
f, = reach([12, 8], f + STEP, zone: "nest")
HOLDS["interact"] << [f + 8, f + 8]
f += 30
r = run(f)
banked = events(r, "banked").length
puts "P4 banked=#{banked}"
abort "P4 bank missed" if banked.zero?

# ---- P5: cross bridge-1; the [26,14] sentry chases — kill it mid-bridge,
# pick its drop, then continue east into the arena; idle to wipe carrying.
f, = reach([28, 8], f + STEP, zone: "nest")
f, = cross("right", "district", f + STEP)
f, = reach([14, 15], f + STEP, zone: "district", near: 1, budget: 18)
f, = reach([24, 15], f + STEP, zone: "district", near: 1, budget: 18)
HOLDS["attack"] << [f, f + 520]
f += 560
r = run(f)
fresh = events(r, "drop_spawned").select { |l| l[/frame=(\d+)/, 1].to_i > f - 600 }
if fresh.empty?
  puts "  DIAG tile=#{r.world.possessed.tile.inspect} deaths=#{events(r, 'actor_died').grep(/faction=human/).length}"
  abort "P5 no fresh drop"
end
tile = [fresh.first[/tile=\[(\d+),/, 1].to_i, fresh.first[/, (\d+)\]/, 1].to_i]
f, = reach(tile, f + STEP, zone: "district", budget: 16)
HOLDS["interact"] << [f + 8, f + 8]
f += 30
r = run(f)
puts "P5 carried pickup at #{tile.inspect} total=#{events(r, 'drop_picked_up').length}"

# ---- P6: snap to the bridge row, push east; the east arena converges —
# accept the wipe wherever it lands (zone flips to nest at judgment).
f, = reach([21, 15], f + STEP, zone: "district", budget: 16)
wipe_frame = nil
18.times do
  HOLDS["right"] << [f, f]
  f += STEP
  r = run(f + 4)
  if events(r, "pack_wiped").any?
    wipe_frame = events(r, "pack_wiped").first[/frame=(\d+)/, 1].to_i
    break
  end
end
unless wipe_frame
  r = run(f + 2400)
  if events(r, "pack_wiped").empty?
    puts "  DIAG tile=#{r.world.possessed.tile.inspect} living=#{r.world.pack.members.map { |m| [m.kit_name, m.hp, m.carried] }.inspect}"
    abort "P6 wipe did not land"
  end
  wipe_frame = events(r, "pack_wiped").first[/frame=(\d+)/, 1].to_i
end
r = run(wipe_frame + 10)
loaded = events(r, "corpse_loaded").length
puts "P6 wiped@#{wipe_frame} corpse_loaded=#{loaded}"
abort "P6 wipe landed without a carried corpse load" if loaded.zero?
finish = wipe_frame + 180

r = run(finish)
script = {
  "scenario" => "world", "seed" => 7, "width" => 960, "height" => 540,
  "out_dir" => "captures/ledger_loop",
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => [340, events(r, "banked").first[/frame=(\d+)/, 1].to_i + 12,
                 wipe_frame - 60, wipe_frame + 40, wipe_frame + 130,
                 finish - 1].uniq.sort,
  "run_until" => finish,
  "manifest" => { "banked" => 1, "corpse_loaded" => 1, "pack_wiped" => 1 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish}"
puts "MANIFEST-PROOF banked=#{events(r, 'banked').length} corpse_loaded=#{events(r, 'corpse_loaded').length} pack_wiped=#{events(r, 'pack_wiped').length}"
