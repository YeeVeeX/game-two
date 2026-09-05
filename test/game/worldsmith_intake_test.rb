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
  # edge gate (transitions []). s70 wire-in (2026-08-24, the intake debt
  # list executed): the pin moves CONSCIOUSLY — identity dose + camp
  # pack_spawn + vat/altar station pair + the free return gate at the
  # delivered gate corner [63,19]. Everything else stays the delivery.

  # CONSCIOUS pin move (MUNDO VIVO FASE 6.1, 2026-09-05): the return spawn
  # into dungeon_1 moved [29,4] -> [29,7] — [29,4] is wall in the medusa
  # geometry that now occupies DUNGEON 1 (swap spec §1 M2). One row, same
  # commit as the swap; previous pin 89ba053f0436b3d422cccc9dbf7f6617.
  LANDED_MD5 = "fc7ccfc8f63cf69f84b29a857ab76508".freeze
  LANDED = File.expand_path("../../data/zones/zone_8.json", __dir__)

  def test_landed_zone_bytes_match_the_intake_record
    assert_equal LANDED_MD5, Digest::MD5.file(LANDED).hexdigest,
                 "zone_8.json drifted from the recorded wire-in " \
                 "(drafts/_worldsmith-v0-intake-20260823.md \u00a7Wire-in debt + the s70 record)"
  end

  # The inertness pin FLIPPED at the s70 wire-in (the exemption comment
  # always named this moment): zone_8 is now REACHABLE — dungeon_1's
  # far-east rope way (the s68 ladder's frontier rung, level 8) goes out,
  # the delivered gate corner comes home free, and the arrival geometry
  # knows both directions.
  def test_landed_zone_is_wired_into_the_live_world_graph
    zones = DATA.keys.grep(%r{\Azones/}).map { |k| k.sub("zones/", "") }
    assert_includes zones, "zone_8", "zone_8 loads with the world's own discovery rule"
    maps = zones.to_h { |n| [n, Core::TileMap.new(DATA["zones/#{n}"])] }
    assert_equal "ZONE 8", maps["zone_8"].display_name, "re-numbered at intake (next free N)"

    # FASE 6.1: DUNGEON 1 is the MEDUSA LOWER geometry — the frontier rope
    # sits on the serpent head's north rim [29,7] ([29,4] is wall there).
    way = maps["dungeon_1"].transition_at(29, 7)
    refute_nil way, "dungeon_1's serpent-head north rim carries the frontier way"
    assert_equal "zone_8", way[:to]
    assert_equal "rope_spot", way[:type], "climbing out is the interact verb (gate-consent law)"
    assert_equal 8, way[:requires_level], "the frontier rung prices the way, not the return"
    assert_equal [62, 18], way[:spawn]

    back = maps["zone_8"].transition_at(63, 19)
    refute_nil back, "the delivered gate corner is the way home"
    assert_equal "dungeon_1", back[:to]
    assert_nil back[:type], "non-pilot zones stay untyped v1 gates (tile_map_test law)"
    assert_nil back[:requires_level], "the return is FREE"
    assert_nil back[:sealed], "the return is FREE"
    assert_equal [29, 7], back[:spawn], "you land at the rope you'd climb back up"

    arrivals = Game::Crossing.validated_arrivals(maps)
    assert_equal [[62, 18]], arrivals["zone_8"], "one way in, beside \u2014 never on \u2014 the gate"
    assert_includes arrivals["dungeon_1"], [29, 7]
  end
end
