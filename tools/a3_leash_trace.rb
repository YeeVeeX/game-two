$LOAD_PATH.unshift File.expand_path("../src", __dir__)
require "json"; require "digest"
require_relative "../test/support/headless_script"
ROOT = File.expand_path("..", __dir__)
raw = JSON.parse(File.read("#{ROOT}/harness/scripts/brasa2_run.json"), symbolize_names: true)
data = Core::DataStore.new("#{ROOT}/data"); t = data["balance/threat"]; t[:ally][:enabled] = true; t[:human][:enabled] = true
world = Game::World.new(data, seed: raw.fetch(:seed, 0)); Harness.apply_start(world, raw[:start])
lines = []; Harness::EventLog.attach(world) { |l| lines << l }
input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
raw.fetch(:run_until).times { input.update(world.frame); world.tick(input) }
le = lines.select { |l| l.include?("human_leashed") }
by = le.each_with_object(Hash.new(0)) { |l, h| h[l[/actor=(\S+)/, 1]] += 1 }
puts "leashed por ator: #{by.inspect}"
fr = le.map { |l| l[/frame=(\d+)/, 1].to_i }
puts "frames leashed (primeiros 30): #{fr.first(30).inspect}"
gaps = fr.each_cons(2).map { |a, b| b - a }
puts "gaps: min=#{gaps.min} max=#{gaps.max} mediana=#{gaps.sort[gaps.length / 2]}"
top = by.max_by { |_, n| n }[0]
puts "--- linha do tempo de #{top} (retarget/leash/died), primeiras 24 ---"
lines.select { |l| l.include?("actor=#{top}") || l.include?("victim=#{top}") || l.include?("attacker=#{top}") }.first(24).each { |l| puts "  " + l[0, 150] }
