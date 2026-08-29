# v20 T1 follow-up: corpse_run re-cut for floor -1 (v2b district).
# Waypoint-corrected generation per the tune_floor1_run.rb precedent:
# deterministic replays mean observed drift is exactly correctable.
#
# Beat sheet (mirrors the retired S-era script's economy loop):
#   nest -> district west door -> kill 3+ rushers -> pick 3 drops ->
#   walk deeper carrying -> WIPE (corpse_loaded + pack_wiped +
#   vessel_kept) -> respawn nest -> return -> corpse_looted ->
#   nest -> banked.  Manifest wants UNCHANGED (never weakened).
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/corpse_run.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [],
          "attack" => [], "interact" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 7,
          start: { progression: { level: 5, xp: 0 } },
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/corpse_run_tune.json")
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

# One tap toward the auto-firing way tile; verify the zone flipped.
def cross(dir, expect_zone, from_frame)
  HOLDS[dir] << [from_frame, from_frame]
  frame = from_frame + STEP + 10
  r = run(frame)
  abort "cross #{dir} -> #{expect_zone} failed (zone=#{r.world.zone_name} tile=#{r.world.possessed.tile.inspect})" if r.world.zone_name != expect_zone
  [frame, r]
end

def events(r, name) = r.lines.grep(/^EVENT #{name} /)

# ---- Phase 1: nest spawn [14,8] -> beside the way [28,8] -> cross -> [1,13].
f, = reach([28, 8], 10, zone: "nest")
f, r = cross("right", "district", f + STEP)
puts "P1 district door at #{f} tile=#{r.world.possessed.tile.inspect}"

# ---- Phase 2: east into the west arena; engage [12,12]/[13,10] group.
f, = reach([10, 12], f + STEP, zone: "district")
HOLDS["attack"] << [f, f + 380]
fight_end = f + 420
r = run(fight_end)
kills = events(r, "actor_died").reject { |l| l =~ /faction=pack/ }.length
drops = events(r, "drop_spawned").map { |l| l[/tile=\[(\d+), (\d+)\]/, 0] }
puts "P2 fight: kills=#{kills} drops=#{events(r, 'drop_spawned').length} at #{r.world.possessed.tile.inspect}"
abort "P2 needs >=3 kills, got #{kills}" if kills < 3

# ---- Phase 3: pick up 3 drops (walk onto tile, interact).
picked = 0
events(r, "drop_spawned").first(4).each do |l|
  tile = [l[/tile=\[(\d+),/, 1].to_i, l[/, (\d+)\]/, 1].to_i]
  f, r2 = reach(tile, fight_end + STEP, zone: "district")
  HOLDS["interact"] << [f + 8, f + 8]
  fight_end = f + STEP
  r3 = run(fight_end + 8)
  now = events(r3, "drop_picked_up").length
  puts "  pickup at #{tile.inspect} -> drop_picked_up=#{now}"
  picked = now
  break if picked >= 3
end
abort "P3 needs >=3 pickups, got #{picked}" if picked < 3
f = fight_end + 8

# ---- Phase 4: cross bridge-1 (row 15 wood; the row-14 sentry hater
# aggros and chases) into the east arena; stand at [39,13] where
# [43,10]/[38,12]/[40,20] converge in the open. Idle unarmed -> wipe.
ROUTE_EAST = [[14, 15], [22, 15], [30, 15], [36, 15]].freeze
ROUTE_EAST.each do |wp|
  f, = reach(wp, f + STEP, zone: "district", near: 1, budget: 18)
end
f, = reach([39, 13], f + STEP, zone: "district", near: 1, budget: 18)
wipe_wait = f + 2200
r = run(wipe_wait)
wiped = events(r, "pack_wiped").length
loaded = events(r, "corpse_loaded")
kept = events(r, "vessel_kept").length
puts "P4 wipe: pack_wiped=#{wiped} corpse_loaded=#{loaded.length} vessel_kept=#{kept} zone=#{r.world.zone_name}"
if wiped.zero? || loaded.empty?
  pk = r.world.pack
  puts "  DIAG tile=#{r.world.possessed.tile.inspect} living=#{pk.living.map { |m| [m.kit_name, m.hp] }.inspect}"
  puts "  DIAG pack_deaths=#{events(r, 'actor_died').grep(/faction=pack/).length} human_kills=#{events(r, 'actor_died').grep(/faction=human/).length}"
  puts "  DIAG retargets=#{events(r, 'human_retargeted').length} last=#{events(r, 'human_retargeted').last}"
  puts "  DIAG hits_on_pack=#{events(r, 'attack_hit').grep(/victim=(striker|blocker|lobber)/).length} hits_by_pack=#{events(r, 'attack_hit').grep(/attacker=(striker|blocker|lobber)/).length}"
  abort "P4 wipe did not land"
end
wipe_frame = events(r, "pack_wiped").first[/frame=(\d+)/, 1].to_i
corpse_tile = [loaded.first[/tile=\[(\d+),/, 1].to_i, loaded.first[/, (\d+)\]/, 1].to_i]
respawn_frame = r.lines.grep(/pack_respawned/).first[/frame=(\d+)/, 1].to_i
puts "  wipe@#{wipe_frame} corpse@#{corpse_tile.inspect} respawn@#{respawn_frame}"

# ---- Phase 5: from nest respawn back over bridge-1 to the corpse pile.
f, = reach([28, 8], respawn_frame + 30, zone: "nest")
f, = cross("right", "district", f + STEP)
ROUTE_EAST.each do |wp|
  f, = reach(wp, f + STEP, zone: "district", near: 1, budget: 18)
end
f, r = reach(corpse_tile, f + STEP, zone: "district", near: 0, budget: 18)
HOLDS["interact"] << [f + 8, f + 8]
r = run(f + 40)
looted = events(r, "corpse_looted").length
puts "P5 loot: corpse_looted=#{looted}"
abort "P5 loot missed" if looted.zero?
f += 40

# ---- Phase 6: recross west, home to the bank ([12,8]; stand at [13,8]).
ROUTE_EAST.reverse_each do |wp|
  f, = reach(wp, f + STEP, zone: "district", near: 1, budget: 18)
end
f, = reach([1, 13], f + STEP, zone: "district", near: 0, budget: 18)
f, = cross("left", "nest", f + STEP)
f, = reach([12, 8], f + STEP, zone: "nest")
HOLDS["interact"] << [f + 8, f + 8]
finish = f + 60
r = run(finish)
banked = events(r, "banked").length
puts "P6 bank: banked=#{banked}"
if banked.zero?
  puts "  DIAG tile=#{r.world.possessed.tile.inspect} possessed=#{r.world.possessed.kit_name}"
  puts "  DIAG carried=#{r.world.pack.members.map { |m| [m.kit_name, m.carried, m.hp] }.inspect}"
  puts "  DIAG looted_line=#{events(r, 'corpse_looted').last}"
  puts "  DIAG post_loot_deaths=#{events(r, 'actor_died').grep(/faction=pack/).map { |l| l[/frame=\d+ actor=\w+/] }.inspect}"
  abort "P6 bank missed"
end

# ---- Emit: manifest wants byte-identical to the retired script's.
caps = [330, events(r, "drop_picked_up").first[/frame=(\d+)/, 1].to_i,
        wipe_frame + 40, respawn_frame + 20, wipe_frame - 40,
        events(r, "corpse_looted").first[/frame=(\d+)/, 1].to_i - 40,
        events(r, "corpse_looted").first[/frame=(\d+)/, 1].to_i,
        events(r, "banked").first[/frame=(\d+)/, 1].to_i + 12,
        finish - 1].uniq.sort
script = {
  "scenario" => "world", "seed" => 7, "width" => 960, "height" => 540,
  "out_dir" => "captures/pilot/cr3_r1_replay",
  "start" => { "progression" => { "level" => 5, "xp" => 0 } },
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => caps,
  "run_until" => finish,
  "manifest" => { "corpse_loaded" => 2, "pack_wiped" => 2, "corpse_looted" => 2,
                  "banked" => 2, "drop_picked_up" => 6, "vessel_kept" => 2 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish}"
puts "MANIFEST-PROOF corpse_loaded=#{events(r, 'corpse_loaded').length} pack_wiped=#{events(r, 'pack_wiped').length} corpse_looted=#{looted} banked=#{banked} drop_picked_up=#{events(r, 'drop_picked_up').length} vessel_kept=#{events(r, 'vessel_kept').length}"
