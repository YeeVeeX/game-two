# v20 T1: world_loop district-leg re-cut tuner (one-shot dev tool).
# PASS A probes the fight outcome on the new floor; PASS B emits the full
# static script and verifies its manifest headless. Output overwrites
# harness/scripts/world_loop.json only when the verification passes.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/world_loop.json")

# --- shared choreography pieces -----------------------------------------
NEST_RIGHTS = (1..281).step(20).map { |f| [f, f] }          # nest spawn -> door
SWAPS = [[301, 301], [304, 305]]                            # blocker -> striker
DISTRICT_RIGHTS = (306..418).step(14).map { |f| [f, f] }    # pocket -> arena
ATTACK = [[432, 701]]

def run(holds, run_until)
  raw = { scenario: "world", seed: 42, hold: holds, run_until: run_until }
  tmp = File.join(REPO, "tmp/world_loop_tune.json")
  File.write(tmp, JSON.generate(raw))
  Headless.run_script(tmp)
end

def taps(from, steps, every: 14)
  steps.times.map { |i| f = from + i * every; [f, f] }
end

# --- PASS A: probe the fight ---------------------------------------------
holds = { "right" => NEST_RIGHTS + DISTRICT_RIGHTS, "swap" => SWAPS, "attack" => ATTACK }
r = run(holds, 760)
w = r.world
puts "A: zone=#{w.zone_name} possessed=#{w.possessed.kit_name}@#{w.possessed.tile.inspect}"
kills = r.lines.grep(/human_died|fight_resolved/)
puts kills.first(6)
drops = w.drops.map { |d| d[:tile] }
puts "A: drops=#{drops.inspect} living_pack=#{w.pack.living.length}"
abort "A: no drops - fight failed" if drops.empty?

# --- PASS B: generate the tail ------------------------------------------
pos = w.possessed.tile
drop = drops.min_by { |t| [(t[0] - pos[0]).abs, (t[1] - pos[1]).abs].max }
puts "B: walk #{pos.inspect} -> drop #{drop.inspect}"

frames = 710
lefts, rights, ups, downs, interacts = [], [], [], [], []
push = lambda do |dx, dy|
  arr = dx.negative? ? lefts : rights
  arry = dy.negative? ? ups : downs
  n = [dx.abs, dy.abs].max
  n.times do |i|
    f = frames + i * 14
    arr << [f, f] if i < dx.abs
    arry << [f, f] if i < dy.abs
  end
  frames += n * 14 + 14
end
push.call(drop[0] - pos[0], drop[1] - pos[1])
interacts << [frames, frames]
frames += 20
# walk home: row of the drop -> row 13 -> west to the door [0,13]
push.call(0, 13 - drop[1])
push.call(-(drop[0]), 0) # to x=0 (the crossing fires en route at x=0)
frames += 40 # crossing + arrival settle
# nest: arrival [28,8] -> bank [12,8]
push.call(-16, 0)
bank_f = frames + 10
interacts << [bank_f, bank_f]
run_until = bank_f + 12

holds_b = {
  "right" => NEST_RIGHTS + DISTRICT_RIGHTS + rights.sort,
  "left" => lefts.sort, "up" => ups.sort, "down" => downs.sort,
  "swap" => SWAPS, "attack" => ATTACK, "interact" => interacts.sort
}.reject { |_, v| v.empty? }

rb = run(holds_b, run_until)
picked = rb.lines.count { |l| l =~ /drop_picked_up/ }
banked = rb.lines.count { |l| l =~ /EVENT banked/ }
puts "B: zone=#{rb.world.zone_name} possessed@#{rb.world.possessed.tile.inspect} picked=#{picked} banked=#{banked} lines=#{rb.lines.length}"
puts rb.lines.grep(/banked|drop_picked|zone_entered/).join
abort "B: manifest unsatisfied" unless picked >= 1 && banked >= 1 && rb.world.zone_name == "nest"

# --- emit ------------------------------------------------------------------
script = {
  "scenario" => "world", "seed" => 42, "width" => 960, "height" => 540,
  "out_dir" => "captures/world_loop",
  "hold" => holds_b.transform_values { |v| v.map { |a| a.dup } },
  "captures" => [0, 300, 303, 415, 431, 441, 701, 710 + ((drop[0] - pos[0]).abs + (drop[1] - pos[1]).abs) * 7, bank_f - 200, run_until - 1].uniq.sort,
  "run_until" => run_until,
  "manifest" => { "banked" => 1, "drop_picked_up" => 1 }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{run_until}"
