# v20 T3: sustain_run re-cut for the C2-era sim + potions identity surfaces.
# The v18-era choreography died with 04b218b (free allies acquire PROVOKED
# humans only): every fight beat missed, so buys/uses/banked/pickups/wipe
# all read zero (T1 wall record section 2; s117 spark). Manifest wants stay
# BYTE-UNCHANGED (6/2/8/4/16/2/2 = double-replay minimums; manifest_check
# judges the teed DOUBLE-replay log, so a single run owes ceil(want/2)).
#
# Beat sheet (single-run):
#   R1 spawn: 2x sustain press, 0 stock -> :none refusals (cue on camera)
#   R2 nest bank [12,8], banked=0: 2x press -> :broke refusals
#   F1/F2... district west-arena fights (ledger tuner waypoints), pick
#      drops to >=8; deposit at the nest bank between batches (banked >=2)
#   HINT idle on the bank tile, cue-free, banked>=15, stock 0 -> the
#      affordable pre-buy frame the sustain_hint checklist REQUIRES
#   BUY 3 (receipts), then 2x press -> :at_cap refusals (>=4 refusals now)
#   USE afield with a hurt body -> 1 use receipt
#   CARRY a fresh drop east into the arena, idle -> pack_wiped; respawn,
#      walk back, settle-gated interact -> corpse_looted
# Captures cover: none cue, broke cue, hint frame, buy receipt, at_cap cue,
# use receipt, wipe straddle, corpse loot, final strip (always-on pair +
# POTION N counter ride every frame).
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/sustain_run.json")
STEP = 20
START = { progression: { level: 5, xp: 0 } }.freeze

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [],
          "attack" => [], "interact" => [], "sustain" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 7, start: START,
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/sustain_run_tune.json")
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
def refusals(r) = events(r, "provision_refused")

CAPS = []

# ---- R1: two :none refusals at spawn (0 stock, off bank).
HOLDS["sustain"] << [30, 30] << [50, 50]
r = run(70)
abort "R1 wants 2 none refusals, got #{refusals(r).length}" if refusals(r).length < 2
abort "R1 reasons wrong: #{refusals(r).inspect}" unless refusals(r).all? { |l| l.include?("reason=none") }
CAPS << 44
puts "R1 none refusals=2 @30/@50"

# ---- R2: nest bank [12,8], banked=0 -> two :broke refusals.
f, = reach([12, 8], 90, zone: "nest")
HOLDS["sustain"] << [f + 8, f + 8] << [f + 28, f + 28]
f += 48
r = run(f)
broke = refusals(r).count { |l| l.include?("reason=broke") }
abort "R2 wants 2 broke, got #{broke}" if broke < 2
CAPS << f - 26
puts "R2 broke refusals=2 by #{f}"

# ---- P1: nest -> district west door.
f, = reach([28, 8], f + STEP, zone: "nest")
f, r = cross("right", "district", f + STEP)
puts "P1 door at #{f}"

# ---- F-batches: sweep the WEST-HALF spawn column (probed geometry — rooms
# chained by narrow slots; straight-line stepping needs corridor waypoints).
# F1 clears the door pair; F2 the y=22 pocket; F3+ walk rooms 2-3 south.
# ONE deposit trip after F2 (B1/B2 pattern), one more after the sweep (B3).
picked_total = 0

def fight(anchor, f, waypoints: [])
  waypoints.each { |wp| f, = reach(wp, f + STEP, zone: "district", budget: 18, near: 1) }
  f, = reach(anchor, f + STEP, zone: "district", budget: 18, near: 2)
  HOLDS["attack"] << [f, f + 620]
  f += 660
  r = run(f)
  puts "  fight #{anchor.inspect}: kills=#{events(r, 'actor_died').grep(/faction=human/).length} field_drops=#{r.world.drops.length}"
  [f, r]
end

def pick_field(f)
  r = run(f)
  r.world.drops.map { |d| d[:tile] }.first(6).each do |tile|
    nf, = reach(tile, f + STEP, zone: "district", budget: 16)
    HOLDS["interact"] << [nf + 8, nf + 8]
    f = nf + STEP
  end
  r = run(f + 8)
  [f + 8, r]
end

def deposit(f)
  f, = reach([14, 20], f + STEP, zone: "district", budget: 18, near: 1)
  f, = reach([1, 13], f + STEP, zone: "district", budget: 20)
  f, = cross("left", "nest", f + STEP)
  f, = reach([12, 8], f + STEP, zone: "nest")
  HOLDS["interact"] << [f + 8, f + 8]
  f += 30
  r = run(f)
  puts "  deposit: banked_events=#{events(r, 'banked').length} banked=#{r.world.pack.banked}"
  [f, r]
end

# F1: door pair [13,10]/[12,12] (+ chasing sentry sometimes).
f, r = fight([10, 12], f)
f, r = pick_field(f)
f, r = deposit(f)
# back out to the district for F2.
f, = reach([28, 8], f + STEP, zone: "nest")
f, r = cross("right", "district", f + STEP)
# F2: the y=22 pocket rusher — enter via the x=13-16 slot at y=21.
f, r = fight([13, 22], f, waypoints: [[14, 18]])
f, r = pick_field(f)
f, r = deposit(f)
f, = reach([28, 8], f + STEP, zone: "nest")
f, r = cross("right", "district", f + STEP)
# F3/F4: room 2 pair ([9,28], [15,32]) — south through the y=21-24 slot.
f, r = fight([11, 28], f, waypoints: [[14, 18], [14, 24]])
f, r = fight([14, 32], f)
f, r = pick_field(f)
# F5: the y=38 pocket rusher; F6: room 3 ([8,46], [13,50]) if still short.
f, r = fight([11, 38], f, waypoints: [[14, 36]])
f, r = pick_field(f)
picked_total = events(r, "drop_picked_up").length
if picked_total < 8
  f, r = fight([9, 46], f, waypoints: [[12, 39], [10, 42]])
  f, r = fight([13, 50], f)
  f, r = pick_field(f)
  picked_total = events(r, "drop_picked_up").length
end
abort "sweep short: picked=#{picked_total} < 8" if picked_total < 8
# B3: bank the sweep haul — walk back north through the slots.
f, = reach([14, 36], f + STEP, zone: "district", budget: 18, near: 1) if r.world.possessed.tile[1] > 38
f, = reach([14, 24], f + STEP, zone: "district", budget: 20, near: 1)
f, = reach([14, 18], f + STEP, zone: "district", budget: 18, near: 1)
f, r = deposit(f)
banked_events = events(r, "banked").length
abort "banked events short: #{banked_events} < 2" if banked_events < 2
abort "funds short: banked=#{r.world.pack.banked} < 15" if r.world.pack.banked < 15
puts "SWEEP picked=#{picked_total} banked_events=#{banked_events} banked=#{r.world.pack.banked}"

# ---- HINT + BUY: idle cue-free on the bank tile (hint frame), then buy 3,
# then two :at_cap refusals. (We are standing on the nest bank post-deposit.)
f, = reach([12, 8], f + STEP, zone: "nest")
f += 170 # let any station cue expire; hint (banked>=15, stock 0) speaks
r = run(f)
abort "hint idle: cue still live" if r.world.station_cue
CAPS << f - 4
[0, 24, 48].each { |d| HOLDS["sustain"] << [f + d, f + d] }
f += 68
r = run(f)
bought = events(r, "provision_bought").length
abort "BUY wants 3, got #{bought}" if bought < 3
CAPS << f - 40
HOLDS["sustain"] << [f + 8, f + 8] << [f + 28, f + 28]
f += 48
r = run(f)
at_cap = refusals(r).count { |l| l.include?("reason=at_cap") }
abort "at_cap wants 2, got #{at_cap}" if at_cap < 2
CAPS << f - 26
puts "BUY=3 at_cap=2 banked_left=#{r.world.pack.banked} stock=#{r.world.pack.provisions}"

# ---- USE: afield with a hurt body -> one use receipt. The fights hurt the
# pack; if everyone healed to full, expose briefly in the district first.
f, = reach([28, 8], f + STEP, zone: "nest")
f, r = cross("right", "district", f + STEP)
if r.world.pack.living.none? { |m| m.hp < m.max_hp }
  f, = reach([24, 14], f + STEP, zone: "district", budget: 16, near: 2)
  f += 240 # the bridge sentry pokes us; no attack held
  r = run(f)
  abort "USE staging: nobody hurt after exposure" if r.world.pack.living.none? { |m| m.hp < m.max_hp }
  f, = reach([16, 14], f + STEP, zone: "district", budget: 16, near: 1)
end
HOLDS["sustain"] << [f + 8, f + 8]
f += 28
r = run(f)
abort "USE wants 1, got #{events(r, 'provision_used').length}" if events(r, "provision_used").empty?
CAPS << f - 6
puts "USE=1 stock=#{r.world.pack.provisions}"

# ---- WIPE: kill the bridge-1 sentry [26,14] for a fresh CARRY drop, then
# chain-aggro the north-east arena ([38,12]/[43,10]/[40,20]) and idle
# undefended — a level-5 pack needs several attackers before it goes down
# (C2: provoked allies fight back).
f, = reach([24, 14], f + STEP, zone: "district", budget: 18, near: 2)
HOLDS["attack"] << [f, f + 420]
f += 460
r = run(f)
abort "WIPE staging: sentry kill left no drop to carry" if r.world.drops.empty?
tile = r.world.drops.first[:tile]
f, = reach(tile, f + STEP, zone: "district", budget: 16)
HOLDS["interact"] << [f + 8, f + 8]
f += 30
r = run(f)
abort "WIPE staging: carry pickup missed" if r.world.pack.members.sum(&:carried).zero?
wipe_frame = nil
# Aggro-pull hops east, idling after each; stop at the first wipe.
[[38, 12], [42, 11], [40, 20]].each do |hop|
  f, r = reach(hop, f + STEP, zone: "district", budget: 20, near: 2)
  f += 900 # idle exposed, no attack, no dodge
  r = run(f + 4)
  if events(r, "pack_wiped").any?
    wipe_frame = events(r, "pack_wiped").first[/frame=(\d+)/, 1].to_i
    break
  end
  puts "  hop #{hop.inspect} survived: living=#{r.world.pack.living.map { |m| [m.kit_name, m.hp] }.inspect}"
end
unless wipe_frame
  r = run(f + 3000)
  if events(r, "pack_wiped").empty?
    puts "  DIAG tile=#{r.world.possessed.tile.inspect} living=#{r.world.pack.members.map { |m| [m.kit_name, m.hp] }.inspect}"
    abort "WIPE did not land"
  end
  wipe_frame = events(r, "pack_wiped").first[/frame=(\d+)/, 1].to_i
  f = wipe_frame
end
r = run(wipe_frame + 10)
abort "WIPE landed without a corpse load (carried was zero?)" if events(r, "corpse_loaded").empty?
corpse_tile = [events(r, "corpse_loaded").first[/tile=\[(\d+),/, 1].to_i,
               events(r, "corpse_loaded").first[/, (\d+)\]/, 1].to_i]
CAPS << wipe_frame - 40 << wipe_frame + 40
puts "WIPE @#{wipe_frame} corpse at #{corpse_tile.inspect}"

# Respawn lands the pack home (nest); walk back to the corpse and loot it.
f = wipe_frame + 320 # veil + rearm slack
f, = reach([28, 8], f, zone: "nest", budget: 18)
f, r = cross("right", "district", f + STEP)
f, = reach(corpse_tile, f + STEP, zone: "district", budget: 20)
f += 80 # settle gate (corpse_loads settle_left)
HOLDS["interact"] << [f, f]
f += 20
r = run(f)
abort "LOOT missed (settle?)" if events(r, "corpse_looted").empty?
CAPS << f - 4
puts "LOOT done @#{f}"

finish = f + 150
r = run(finish)

# ---- Final proof + emission. Manifest wants BYTE-UNCHANGED.
counts = {
  "provision_bought" => events(r, "provision_bought").length,
  "provision_used" => events(r, "provision_used").length,
  "provision_refused" => refusals(r).length,
  "banked" => events(r, "banked").length,
  "drop_picked_up" => events(r, "drop_picked_up").length,
  "pack_wiped" => events(r, "pack_wiped").length,
  "corpse_looted" => events(r, "corpse_looted").length
}
wants = { "provision_bought" => 6, "provision_used" => 2, "provision_refused" => 8,
          "banked" => 4, "drop_picked_up" => 16, "pack_wiped" => 2, "corpse_looted" => 2 }
wants.each do |ev, want|
  doubled = counts[ev] * 2
  abort "PROOF FAIL #{ev}: single=#{counts[ev]} doubled=#{doubled} < want=#{want}" if doubled < want
end
script = {
  "scenario" => "world", "seed" => 7, "width" => 960, "height" => 540,
  "out_dir" => "captures/sustain_run",
  "start" => { "progression" => { "level" => 5, "xp" => 0 } },
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  "captures" => (CAPS + [finish - 1]).uniq.sort,
  "run_until" => finish,
  "manifest" => wants
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish}"
puts "MANIFEST-PROOF #{counts.map { |k, v| "#{k}=#{v}" }.join(' ')} (double-replay law: all >= wants when doubled)"
puts "REASONS #{refusals(r).map { |l| l[/reason=(\w+)/, 1] }.tally.inspect}"
