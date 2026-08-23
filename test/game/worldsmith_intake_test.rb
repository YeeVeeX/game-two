require_relative "../test_helper"
require "digest"
require "json"
require "core/data_store"
require "core/tile_map"
require "core/tile_registry"
require "game/crossing"

# WorldSmith v0 intake (2026-08-23) — the D16 final proof, in test form.
# The candidate zone (worldsmith v0-zone-1b export, seed 7102) is judged by
# the PLAY-PATH strict decoders against the LIVE registry — real files, no
# mocks (non-negotiable 5). The fixture is the AS-DELIVERED bytes; landing
# edits (re-number, gate neutralization) are recorded intake edits judged
# separately (drafts/_worldsmith-v0-intake-20260823.md).
class WorldsmithIntakeTest < Minitest::Test
  FIXTURE = File.expand_path("../fixtures/worldsmith/zone_1_v0_export.json", __dir__)
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  # Digest chain: worldsmith demo receipt (d) pinned this exact md5; the
  # fixture IS the delivery. A drifted fixture is no longer the audited
  # artifact — this test is the provenance lock.
  DELIVERED_MD5 = "b1b8db981878060af4e991b12430f86c".freeze

  def fixture_cfg
    JSON.parse(File.read(FIXTURE), symbolize_names: true)
  end

  def test_fixture_bytes_match_the_worldsmith_receipt
    assert_equal DELIVERED_MD5, Digest::MD5.file(FIXTURE).hexdigest,
                 "fixture drifted from the delivered bytes (receipt d, worldsmith@e63602f)"
  end

  def test_delivered_zone_passes_the_strict_decoder
    map = Core::TileMap.new(fixture_cfg)
    assert_equal 64, map.cols
    assert_equal 40, map.rows
    assert_equal "ZONE 1", map.display_name, "as-delivered placeholder (re-numbered at landing)"
    assert_equal 3, map.pack_spawn.length
    assert_empty map.enemy_spawns, "worldsmith D8 sim-quarantine: enemy_spawns always {}"
  end

  def test_delivered_zone_passes_the_live_registry_cross_check
    map = Core::TileMap.new(fixture_cfg)
    registry = Core::TileRegistry.new(DATA["tiles"])
    assert_nil registry.validate_map!(map),
               "every used char must name a registered type whose render + variant refs " \
               "exist in the zone palette (grass_b/grass_c ride the grass variants)"
  end

  # The ONE unresolved transition target refuses NAMED at world load — the
  # exact refusal the intake neutralization exists to prevent. Correct
  # behavior on BOTH sides (worldsmith cannot invent our geography; our
  # loader refuses what it cannot place) — never patch-around.
  def test_unresolved_transition_target_refuses_named_at_world_load
    map = Core::TileMap.new(fixture_cfg)
    err = assert_raises(ArgumentError) do
      Game::Crossing.validated_arrivals({ "zone_1" => map })
    end
    assert_equal 'zone edge zone_1 [63, 19] -> unresolved: unknown destination zone "unresolved"',
                 err.message
  end

  # --- the AS-LANDED zone (data/zones/zone_8.json) --------------------------
  # Recorded intake edits, owner-approved 2026-08-23: re-number (ZONE 1
  # collided with nest's live placeholder) + neutralize the one unresolved
  # edge gate (transitions []). Everything else is byte-identical to the
  # delivery (diff-verified at intake).

  LANDED_MD5 = "3f3cce1fe8ae84a20f95d05d7cb1c4f3".freeze
  LANDED = File.expand_path("../../data/zones/zone_8.json", __dir__)

  def test_landed_zone_bytes_match_the_intake_record
    assert_equal LANDED_MD5, Digest::MD5.file(LANDED).hexdigest,
                 "zone_8.json drifted from the recorded intake edit " \
                 "(drafts/_worldsmith-v0-intake-20260823.md pins the before/after chain)"
  end

  def test_landed_zone_is_inert_in_the_live_world_graph
    zones = DATA.keys.grep(%r{\Azones/}).map { |k| k.sub("zones/", "") }
    assert_includes zones, "zone_8", "zone_8 loads with the world's own discovery rule"
    maps = zones.to_h { |n| [n, Core::TileMap.new(DATA["zones/#{n}"])] }
    assert_equal "ZONE 8", maps["zone_8"].display_name, "re-numbered at intake (next free N)"
    assert_empty maps["zone_8"].transitions, "no way OUT (the edge gate was neutralized)"
    inbound = maps.flat_map { |name, m| m.transitions.map { |t| [name, t[:to]] } }
                  .select { |_, to| to == "zone_8" }
    assert_empty inbound, "no way IN from any live zone (inert law — wire-in is a later " \
                          "owner-directed geography session)"
    arrivals = Game::Crossing.validated_arrivals(maps)
    refute arrivals.key?("zone_8"), "no arrival geometry targets zone_8"
  end
end
