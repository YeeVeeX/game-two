# Headless BOSS probe (authoring aid for the wall; no window). Runs a wall
# script headless and reports, per frame, where a boss kit is relative to the
# possessed (Chebyshev), whether it is ON CAMERA (960x540 / 32px tiles), and
# its state (idle / windup / CHANT / SEIZE ...), plus every boss bus event and
# the frame ranges where a capture would SHOW the boss doing something.
#
#   ruby tools/boss_probe.rb floor3_run challenger
#
# Written 2026-09-06 for the owner-named debt (s135): floor3_run SHOWS BOSS 1 for
# ~880 frames (on camera f764..f1646) but no capture falls in the window, so
# `challenger_tell_reads` never truly passed. Finding: CHANT is on camera
# f1463..f1577 (7 -> 6 tiles), interrupted f1577, boss dies f1646. Recommended
# capture(s) - to apply AFTER the E1 re-pin sweep closes (pins alignment):
# 1500 (mid-chant, 7 tiles) and 1600 (post-interrupt, wounded, 4 tiles).
# FRAME LAW: this probe counts world.frame after each tick (1-based); the runner
# saves capture N right after tick N (frame_000N, 0-based) => f1500 = capture 1499.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
require "json"
require_relative "../test/support/headless_script"
ROOT = File.expand_path("..", __dir__)
script = ARGV[0] || "floor3_run"
kit = (ARGV[1] || "challenger").to_sym
raw = JSON.parse(File.read("#{ROOT}/harness/scripts/#{script}.json"), symbolize_names: true)
data = Core::DataStore.new("#{ROOT}/data")
world = Game::World.new(data, seed: raw.fetch(:seed, 0))
Harness.apply_start(world, raw[:start])
lines = []
Harness::EventLog.attach(world) { |l| lines << l }
input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
puts "captures today: #{raw[:captures].inspect} run_until=#{raw[:run_until]} zone=#{world.zone_name}"
rows = []
view_w, view_h = 960 / 32, 540 / 32 # tiles on camera (32px tiles, 960x540)
raw.fetch(:run_until).times do
  input.update(world.frame)
  world.tick(input)
  boss = world.humans.find { |h| h.kit_name == kit && !h.dead? }
  me = world.possessed
  next unless boss && me
  dx = (boss.tile[0] - me.tile[0]).abs
  dy = (boss.tile[1] - me.tile[1]).abs
  on_cam = dx <= view_w / 2 - 1 && dy <= view_h / 2 - 1
  state = boss.chanting? ? "CHANT" : (boss.respond_to?(:seizing?) && boss.seizing? ? "SEIZE" : boss.instance_variable_get(:@attack_state).to_s)
  rows << [world.frame, me.tile, boss.tile, [dx, dy].max, on_cam, state, boss.hp]
end
oncam = rows.select { |r| r[4] }
puts "boss alive frames: #{rows.length}; on-camera frames: #{oncam.length}; first on-cam f#{oncam.first&.first} last f#{oncam.last&.first}"
ev = lines.select { |l| l =~ /challenger_engaged|challenger_chant_started|vessel_seized|chant_interrupted|seizure_ended/ }
puts "boss events:"; ev.first(12).each { |l| puts "  #{l[0, 120]}" }
puts "--- on-camera samples every 60f (frame, me, boss, dist, state, hp) ---"
oncam.each_with_index { |r, i| puts "  #{r.inspect}" if (i % 60).zero? }
best = oncam.select { |r| r[5] == "CHANT" || r[5] == "SEIZE" }
puts "--- CHANT/SEIZE on camera: #{best.length} frames; first 8 ---"
best.first(8).each { |r| puts "  #{r.inspect}" }
near = oncam.select { |r| r[3] <= 6 }
puts "--- on camera within 6 tiles: #{near.length} frames; ranges ---"
puts near.map(&:first).slice_when { |a, b| b != a + 1 }.map { |g| "#{g.first}-#{g.last}" }.first(10).join(" ")
