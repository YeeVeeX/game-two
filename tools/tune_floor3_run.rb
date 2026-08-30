# v20 T7: floor3_run authoring tuner — waypoint-corrected generation on
# the MEDUSA LOWER floor (tune_floor2_run.rb pattern). Route: head pocket
# -> west limb south (stinger watchers open ranged fire on the march) ->
# the row-25 causeway east — BOSS 1 acquires at spawn (aggro 45 owns the
# zone) and marches to meet the pack; the reel ends mid-chant with the
# tell on camera (the full seize choreography stays with the retired
# boss scripts' re-author session). Deterministic; emits
# harness/scripts/floor3_run.json.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "json"
require "support/headless_script"

REPO = File.expand_path("..", __dir__)
PATH = File.join(REPO, "harness/scripts/floor3_run.json")
STEP = 20

HOLDS = { "up" => [], "down" => [], "left" => [], "right" => [], "attack" => [], "aim" => [] }

def run(run_until)
  raw = { scenario: "world", seed: 7,
          start: { zone: "low_quay", progression: { level: 13, xp: 0 } },
          hold: HOLDS.reject { |_, v| v.empty? }, run_until: run_until }
  tmp = File.join(REPO, "tmp/floor3_tune.json")
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
    abort "left the zone mid-tune (#{r.world.zone_name}) at frame #{frame}" unless r.world.zone_name == "low_quay"
    chants = r.lines.grep(/challenger_chant_started/).length
    puts "  round@#{frame}: tile=#{tile.inspect} kills=#{r.lines.grep(/actor_died/).length} " \
         "shots=#{r.lines.grep(/projectile_fired/).length} chants=#{chants}"
    return [frame, :chanting] if chants.positive?
    return [frame, :arrived] if tile == waypoint
    dx = (waypoint[0] - tile[0]).clamp(-1, 1)
    dy = (waypoint[1] - tile[1]).clamp(-1, 1)
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
  [frame, :budget]
end

# Arriving band: level 13 (the -2 cap; the harness seam = the SaveState
# load order, sync_max_hp! heals the delta). Walk-by swings clear engaged
# watchers; NO dwell inside the core's warden bubbles (they hold the
# heart by design and the reel never enters it).
HOLDS["attack"] << [200, 4000]
f, why = reach([7, 14], 10)
puts "P1 limb at #{f} (#{why})"
unless why == :chanting
  f, why = reach([8, 22], f + 20, budget: 30)
  puts "P2 limb south at #{f} (#{why})"
end
unless why == :chanting
  f, why = reach([14, 25], f + 20, budget: 30)
  puts "P3 causeway at #{f} (#{why})"
end
unless why == :chanting
  f, why = reach([18, 25], f + 20, budget: 30)
  puts "P4 causeway east at #{f} (#{why})"
end

# find the exact chant frame (the meet), then end mid-chant window
r = run(f + 400)
chant_line = r.lines.grep(/challenger_chant_started/).first
abort "BOSS 1 never chanted (lines=#{r.lines.length})" unless chant_line
chant_frame = chant_line[/frame=(\d+)/, 1].to_i
finish = chant_frame + 110

r = run(finish)
w = r.world
kills = r.lines.grep(/^EVENT actor_died/)
shots = r.lines.grep(/projectile_fired/)
engaged = r.lines.grep(/challenger_engaged/)
chants = r.lines.grep(/challenger_chant_started/)
puts "final@#{w.possessed.tile.inspect} kills=#{kills.length} shots=#{shots.length} " \
     "engaged=#{engaged.length} chants=#{chants.length} living=#{w.pack.living.length} zone=#{w.zone_name}"
puts "chant_frame=#{chant_frame}"
puts kills.first(6).join
abort "no ranged fire staged (the fauna row needs volleys)" if shots.empty?
abort "pack collapsed" if w.pack.living.length < 2 || w.possessed.dead?
abort "left the zone" unless w.zone_name == "low_quay"

script = {
  "scenario" => "world", "seed" => 7, "width" => 960, "height" => 540,
  "out_dir" => "captures/floor3_run",
  "start" => { "zone" => "low_quay", "progression" => { "level" => 13, "xp" => 0 } },
  "hold" => HOLDS.reject { |_, v| v.empty? }.transform_values(&:sort),
  # captures re-cut to EVENT frames after tuning (arrival banner / shot
  # in flight f332+5 / SPAWNED stamp window (engaged f290) / kill pop
  # f438+6 / volley mid-flight f577+8 / the chant tell +30/+80 / final);
  # manifest pins under the deterministic counts (double-replay margin,
  # floor2_run precedent).
  "captures" => [60, 337, 400, 444, 585, chant_frame + 30, chant_frame + 80, finish - 1].uniq.sort,
  "run_until" => finish,
  "manifest" => { "challenger_engaged" => 1, "challenger_chant_started" => 1,
                  "projectile_fired" => [shots.length / 2, 1].max }
}
File.write(PATH, JSON.pretty_generate(script) + "\n")
puts "WROTE #{PATH} run_until=#{finish} kills=#{kills.length} shots=#{shots.length}"
