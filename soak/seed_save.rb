# soak/seed_save.rb — fabricate a SCRATCH save for zone-coverage soak
# episodes (quality-flywheel lane 1, 2026-08-19) through the REAL encode
# and decode paths — never hand-rolled JSON. The fabricated VALUES are
# validated by the same strict decoder the game boots with; a refusal
# here fails the seeding, named, before any episode spawns.
#
# What it seeds and why:
#   home_zone  = a HUB (nest|camp — the decoder refuses non-hubs by law);
#                wipe respawns anchor here.
#   banked     = enough value that the autopilot's sustain cadence (U
#                every 1500 ticks) executes REAL buys instead of pure
#                refusals (economy: provision_cost=5).
#   provisions = start at cap so provision_used fires early too.
#
# The soak's deep-zone coverage comes from --start-zone (both seats get
# the same flag from run_soak.sh); this seed only makes the world state
# combat-ready. NEVER point this at saves/world.json — soak scratch
# saves only (the run_soak quarantine still verifies the real save).
#
# Usage: ruby -Isrc soak/seed_save.rb <out.json> [hub] [banked] [provisions]

require "core/data_store"
require "game/world"
require "app/save_store"

out = ARGV[0] or abort "usage: ruby -Isrc soak/seed_save.rb <out.json> [hub] [banked] [provisions]"
hub = ARGV[1] || "nest"
banked = Integer(ARGV[2] || 60)
provisions = Integer(ARGV[3] || 3)

if File.expand_path(out) == File.expand_path("saves/world.json")
  abort "seed_save: refusing to touch the REAL save (soak scratch saves only)"
end

data = Core::DataStore.new(File.expand_path("../data", __dir__))
world = Game::World.new(data, seed: 0, seats: 2)
facts = world.save_facts
facts["home_zone"] = hub
facts["banked"] = banked
facts["provisions"] = provisions

store = App::SaveStore.new(path: out)
digest = store.write(facts)

# Verify through the strict decoder — the same gate the game boots with.
loaded = store.load(data:)
unless loaded.is_a?(App::SaveStore::Loaded) && loaded.digest == digest
  detail = loaded.respond_to?(:refusal) ? loaded.refusal : "digest mismatch"
  abort "seed_save: strict decode REFUSED the seeded save — #{detail}"
end

puts "SEEDED #{out} digest=#{digest} home=#{hub} banked=#{banked} " \
     "provisions=#{provisions} (strict decode verified)"
