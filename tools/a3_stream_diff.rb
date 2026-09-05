# A3 stream-diff: ally brain OFF vs ON, same seed + inputs (canary law audit).
$LOAD_PATH.unshift File.expand_path("../src", __dir__)
require "json"
require "digest"
require_relative "../test/support/headless_script"
ROOT = File.expand_path("..", __dir__)
def run(name, on:)
  raw = JSON.parse(File.read("#{ROOT}/harness/scripts/#{name}.json"), symbolize_names: true)
  data = Core::DataStore.new("#{ROOT}/data")
  t = data["balance/threat"]
  t[:ally][:enabled] = on
  t[:human][:enabled] = on
  world = Game::World.new(data, seed: raw.fetch(:seed, 0))
  Harness.apply_start(world, raw[:start])
  lines = []
  Harness::EventLog.attach(world) { |l| lines << l }
  input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
  raw.fetch(:run_until).times { input.update(world.frame); world.tick(input) }
  [lines, Digest::MD5.hexdigest(lines.map { |l| "#{l}\n" }.join)]
end
canary = File.read("#{ROOT}/test/harness/sim_identity_canary_test.rb")
puts "| script | OFF md5 | = ACTIVE bank? | ON md5 | lines OFF -> ON | first divergent line |"
puts "|---|---|---|---|---|---|"
details = []
ARGV.each do |name|
  off, hoff = run(name, on: false)
  on, hon = run(name, on: true)
  active = canary[/ACTIVE = {.*?}/m].to_s[/"#{name}" => "([0-9a-f]{32})"/, 1]
  i = (0...[off.length, on.length].max).find { |k| off[k] != on[k] }
  puts "| #{name} | `#{hoff[0, 8]}` | #{active == hoff ? 'YES' : "NO (bank #{active.to_s[0, 8]})"} | `#{hon[0, 8]}` | #{off.length} -> #{on.length} | #{i ? "#{i + 1} of #{off.length}" : 'none'} |"
  cls = ->(ls) { ls.each_with_object(Hash.new(0)) { |l, h| h[l.split(/\s+/)[1] || l.split(/\s+/)[0]] += 1 } }
  co, cn = cls.(off), cls.(on)
  d = (co.keys | cn.keys).map { |k| [k, co[k], cn[k]] }.select { |_, a, b| a != b }.sort_by { |k, a, b| [-(b - a).abs, k] }
  details << "\n### #{name}\n\n"
  if i
    details << "First divergence at line #{i + 1} (prefix of #{i} lines byte-identical):\n\n```\n"
    details << "  OFF: #{off[i]}\n   ON: #{on[i]}\n```\n\n"
  end
  details << "Event-class deltas (count OFF -> ON):\n\n| class | OFF | ON |\n|---|---|---|\n"
  d.first(14).each { |k, a, b| details << "| #{k} | #{a} | #{b} |\n" }
end
puts details.join
