# tools/dev_save.rb — fabricate the DEV WARP scratch save (owner order
# 2026-09-05: "we are still 2 devs working on the game — how can I see what
# is new myself?"). Same shape as soak/seed_save.rb: values go through the
# REAL World + encode + strict decode paths, never hand-rolled JSON.
#
# What it seeds and why:
#   level      = the live cap (data/balance/progression.json) — every
#                requires_level gate in the world is open.
#   breached   = EVERY seal in data/zones (stations type "seal" → opens) —
#                no toll stands between a dev and the content.
#   boss_1     = 1 defeat — requires_defeats gates open.
#   banked     = 9999, provisions = the economy cap — potions on tap.
#   hp         = full at the leveled max (P3 apply-order law honored).
#   home_zone  = a HUB (zone_7 by default — the center of the v21 graph).
#
# NEVER the live save: the persistence path is refused by name here AND in
# main.rb; bin/warp writes tmp/dev/world.json. A warp session's launcher
# log is named game_two_warp_*.log — outside the fun-verify harvest glob.
#
# Usage: ruby -Isrc tools/dev_save.rb <out.json> [level=cap] [hub=zone_7]

require "core/data_store"
require "game/world"
require "app/save_store"

out = ARGV[0] or abort "usage: ruby -Isrc tools/dev_save.rb <out.json> [level=cap] [hub=zone_7]"
data = Core::DataStore.new(File.expand_path("../data", __dir__))

live = File.expand_path("../#{data['persistence'][:save_path]}", __dir__)
if File.expand_path(out) == live
  abort "dev_save: refusing to touch the LIVE save #{live} (scratch saves only)"
end

# v22 T1: the warp save's character is keyed by THIS machine's player id
# (data/player.local.json, created on first use like any boot) so the human
# seat bin/warp launches is SEATED at the cap — a foreign id would seat a
# new level-1 character and every gate would stay shut.
require "app/player_file"
player_id = App::PlayerFile.load.player_id
world = Game::World.new(data, seed: 0, players: { 1 => player_id })
cap = world.progression.level_cap
level = ARGV[1] ? Integer(ARGV[1]) : cap
abort "dev_save: level #{level} outside 1..#{cap}" unless level.between?(1, cap)
hub = ARGV[2] || "zone_7"

seals = data.keys.select { |k| k.start_with?("zones/") }.flat_map do |key|
  zone = key.delete_prefix("zones/")
  data[key].fetch(:stations, []).select { |s| s[:type] == "seal" }
                                .map { |s| [zone, s[:opens]] }
end

world.load_home!(hub)
world.progression.load_counters!(boss_1_defeats: 1, sessions: 0)
world.progression.load_progress!(level:, xp: 0)
world.pack.sync_max_hp!(progression: world.progression)
world.pack.members.each { |m| m.load_hp!(m.max_hp) }
world.pack.bank!(9999)
world.pack.load_provisions!(data["balance/economy"][:provision_cap])
seals.each { |(zone, tile)| world.restore_breach!(zone, tile) }

require "fileutils"
FileUtils.mkdir_p(File.dirname(File.expand_path(out)))
store = App::SaveStore.new(path: out)
digest = store.write(world.save_facts)

# Verify through the strict decoder — the same gate the game boots with.
loaded = store.load(data:, player_id:)
unless loaded.is_a?(App::SaveStore::Loaded) && loaded.digest == digest
  detail = loaded.respond_to?(:refusal) ? loaded.refusal : "digest mismatch"
  abort "dev_save: strict decode REFUSED the seeded save — #{detail}"
end

puts "DEV_SAVE #{out} digest=#{digest} schema=#{Game::SaveState::SCHEMA} player=#{player_id} " \
     "level=#{level}/#{cap} home=#{hub} seals_open=#{seals.length} (strict decode verified)"
