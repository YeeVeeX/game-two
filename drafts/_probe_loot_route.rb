# Dev iteration aid (gitignored): headless run of a replay script against the
# REAL sim, printing possessed tile/zone/carried + key events so loot_loop.json
# movement taps can be aimed. Usage:
#   ruby -Isrc drafts/_probe_loot_route.rb harness/scripts/loot_loop.json [step]
require "json"
require "core/data_store"
require "core/input"
require "game/world"

raw = JSON.parse(File.read(ARGV[0]), symbolize_names: true)
step = (ARGV[1] || 25).to_i

frames = Hash.new { |h, k| h[k] = [] }
raw.fetch(:hold, {}).each do |action, ranges|
  ranges.each { |(from, to)| (from..to).each { |f| frames[f] << action.to_s } }
end
raw.fetch(:frames, {}).each { |f, actions| frames[Integer(f.to_s)].concat(actions) }

data = Core::DataStore.new(File.expand_path("../data", __dir__))
world = Game::World.new(data, seed: raw.fetch(:seed, 0))
input = Core::ScriptedInput.new(frames:)
%i[actor_died drop_spawned drop_picked_up drop_decayed banked carried_lost
   possession_changed zone_entered pack_wiped projectile_fired].each do |ev|
  world.bus.subscribe(ev) do |e|
    desc = e.payload.map { |k, v| "#{k}=#{v.respond_to?(:name) ? v.name : v.inspect}" }.join(" ")
    puts "EVENT #{ev} frame=#{world.frame} #{desc}"
  end
end

raw.fetch(:run_until).times do |f|
  input.update(world.frame)
  world.tick(input)
  if (f % step).zero?
    c = world.possessed
    puts format("f=%4d zone=%-8s pos=%-9s kit=%-8s carried=%d hp=%d banked=%d",
                f, world.zone_name, c.tile.inspect, c.kit_name, c.carried, c.hp,
                world.pack.banked)
  end
end
c = world.possessed
puts format("END  zone=%-8s pos=%-9s kit=%-8s carried=%d banked=%d drops=%s",
            world.zone_name, c.tile.inspect, c.kit_name, c.carried,
            world.pack.banked, world.drops.map { |d| [d[:tile], d[:amount]] }.inspect)
