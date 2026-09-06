#!/usr/bin/env ruby
# Headless MANIFEST CENSUS (no window, no critic). For every wall script with
# `"scenario": "world"`, replays the sim exactly as the gate does (same seed,
# Harness.apply_start, Harness.expand_script, EventLog's curated list), counts
# the `EVENT <name>` lines and judges the script's `manifest` the way
# harness/manifest_check.rb does over a DOUBLE replay (the gate runs the script
# twice into one log, so a floor is met when 2 x one run's count >= floor).
#
#   ruby tools/manifest_census.rb              # all world scripts
#   ruby tools/manifest_census.rb brasa2_run vat_economy
#
# Why: the wall costs ~3.5 h of GL window (capture + vision); the MANIFEST half
# of its verdict is pure sim and takes minutes headless. Run it before a wall
# to know the red census in advance (2026-09-06, Junior's seat; E1.4 re-cut the
# census manifests to observed counts - this is how a seat re-measures them).
# It is a report, not a gate: exit 0 always; vision rows are NOT judged here.
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
require "json"
require_relative "../test/support/headless_script"

ROOT = File.expand_path("..", __dir__)
names = ARGV.empty? ? Dir[File.join(ROOT, "harness/scripts/*.json")].map { |f| File.basename(f, ".json") }.sort : ARGV
fails = []
not_judged = []
t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
names.each do |name|
  raw = JSON.parse(File.read(File.join(ROOT, "harness/scripts/#{name}.json")), symbolize_names: true)
  unless raw[:scenario].to_s == "world"
    if raw[:manifest] && !raw[:manifest].empty?
      not_judged << name
      puts "#{name.ljust(22)} SKIP   scenario=#{raw[:scenario]} - HAS A MANIFEST #{raw[:manifest].inspect}: NOT judged here " \
           "(that scene builds its own World; the wall's manifest_check is its only judge)"
    else
      puts "#{name.ljust(22)} SKIP   scenario=#{raw[:scenario]} (no manifest)"
    end
    next
  end
  manifest = raw.fetch(:manifest, {})
  begin
    data = Core::DataStore.new(File.join(ROOT, "data"))
    world = Game::World.new(data, seed: raw.fetch(:seed, 0))
    Harness.apply_start(world, raw[:start])
    counts = Hash.new(0)
    Harness::EventLog.attach(world) { |l| counts[l[/\AEVENT (\w+) frame=/, 1]] += 1 if l.start_with?("EVENT ") }
    input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
    raw.fetch(:run_until).times do
      input.update(world.frame)
      world.tick(input)
    end
    red = manifest.reject { |ev, min| counts[ev.to_s] * 2 >= min }
    cells = manifest.map { |ev, min| "#{ev}=#{counts[ev.to_s] * 2}#{red.key?(ev) ? "(<#{min})" : ""}" }.join(" ")
    if red.empty?
      puts "#{name.ljust(22)} PASS   #{cells}"
    else
      fails << name
      puts "#{name.ljust(22)} FAIL   #{cells}"
    end
  rescue StandardError => e
    fails << name
    puts "#{name.ljust(22)} ERROR  #{e.class}: #{e.message[0, 110]}"
  end
end
dt = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0).round
puts "CENSUS #{names.length} scripts in #{dt}s - #{fails.empty? ? 'ALL PASS' : "#{fails.length} FAIL: #{fails.join(' ')}"}" \
     "#{not_judged.empty? ? '' : " · NOT JUDGED (manifest outside the world scenario): #{not_judged.join(' ')}"}"
