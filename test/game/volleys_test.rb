require_relative "../test_helper"
require "core/event_bus"
require "core/tile_map"
require "game/creature"
require "game/volleys"

# T4 commit A (the Volleys carve): the volley subsystem as a plain
# object — launch geometry, delay tick, hit resolution through the
# injected callables, clear!, and the digest fold. Real map + real
# creatures (the callables ARE the contract, not stand-ins for a lower
# layer); World's own suite pins the live seam (world_test volley
# family + net/state_digest impact rows).
class VolleysTest < Minitest::Test
  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: [
      "############",
      "#..........#",
      "#....#.....#",
      "#..........#",
      "############"
    ],
    pack_spawn: [[1, 1], [2, 1], [3, 1]]
  )

  # Volley-shaped kit (synthetic — sim numbers stay unfrozen in units).
  KIT = {
    max_hp: 60, step_frames: 16, aggro_tiles: 10,
    attack: { damage: 20, windup_frames: 10, active_frames: 2, recovery_frames: 10,
              exhaust_frames: 60, arc: "projectile", range_tiles: 6,
              projectile_frames_per_tile: 4, knockback_tiles: 0,
              knockback_frames_per_tile: 5 },
    special: { damage: 35, windup_frames: 10, active_frames: 1, recovery_frames: 12,
               exhaust_frames: 720, arc: "volley", impact_distances: [2, 3, 4],
               delay_frames: 40, knockback_tiles: 0 },
    dodge: { tiles: 2, frames_per_tile: 8, iframes: 15, cooldown_frames: 60 },
    knockback_frames_per_tile: 5
  }.freeze

  EVENTS = %i[attack_started special_started attack_hit damage_dealt
              actor_died dodged].freeze

  def bus = @bus ||= Core::EventBus.new.register(*EVENTS)

  def creature(name:, tile:, faction: :pack)
    Game::Creature.new(bus:, kit: KIT, kit_name: :lobber, map: MAP,
                       tile:, faction:, name:)
  end

  def hits = @hits ||= []

  def volleys(foes: [])
    Game::Volleys.new(
      hostiles: ->(_owner) { foes },
      blocked: ->(_victim) { [] },
      hit_sink: ->(attacker, victim, landed) { hits << [attacker, victim, landed] }
    )
  end

  def launch(v, owner, distances: KIT[:special][:impact_distances],
             delay_frames: KIT[:special][:delay_frames])
    v.launch(owner:, map: MAP, origin: owner.tile, dir: owner.facing,
             distances:, delay_frames:, damage: 35)
    v.records.last
  end

  # --- launch geometry ------------------------------------------------

  def test_tiles_march_the_facing_and_keep_only_named_distances
    owner = creature(name: "l1", tile: [1, 1])
    record = launch(volleys, owner)
    assert_equal [[3, 1], [4, 1]], record[:tiles].first(2)
    assert_equal [[3, 1], [4, 1], [5, 1]], record[:tiles]
  end

  def test_tiles_stop_at_the_first_impassable_tile
    owner = creature(name: "l1", tile: [1, 2]) # wall at [5, 2]
    record = launch(volleys, owner)
    assert_equal [[3, 2], [4, 2]], record[:tiles],
                 "the chain honestly shortens at a wall (truncation law)"
  end

  def test_tile_order_is_fixed_regardless_of_distances_order
    owner = creature(name: "l1", tile: [1, 1])
    record = launch(volleys, owner, distances: [4, 2, 3])
    assert_equal [[3, 1], [4, 1], [5, 1]], record[:tiles],
                 "geometry is order-insensitive to the distances array"
  end

  # --- record shape (FROZEN API: renderer + digest read it) ------------

  def test_record_shape_is_frozen_with_live_owner_reference
    owner = creature(name: "l1", tile: [1, 1])
    record = launch(volleys, owner)
    assert_equal %i[owner tiles frames_left damage], record.keys
    assert_same owner, record[:owner],
                "renderer reads owner.kit through a LIVE reference"
    assert_equal 40, record[:frames_left]
    assert_equal 35, record[:damage]
  end

  # --- delay tick + resolution -----------------------------------------

  def test_tick_decrements_and_never_resolves_while_frames_remain
    owner = creature(name: "l1", tile: [1, 1])
    victim = creature(name: "v1", tile: [4, 1], faction: :human)
    v = volleys(foes: [victim])
    record = launch(v, owner, delay_frames: 3)
    v.tick!
    assert_equal 2, record[:frames_left]
    assert_equal victim.max_hp, victim.hp
    assert_empty hits
    assert_equal [record], v.records
  end

  def test_resolution_hits_victims_on_tiles_reports_the_sink_and_rejects_the_record
    owner = creature(name: "l1", tile: [1, 1])
    victim = creature(name: "v1", tile: [4, 1], faction: :human)
    bystander = creature(name: "v2", tile: [4, 3], faction: :human)
    v = volleys(foes: [victim, bystander])
    launch(v, owner, delay_frames: 1)

    v.tick!

    assert_equal victim.max_hp - 35, victim.hp
    assert_equal bystander.max_hp, bystander.hp, "off-tile foes are untouched"
    assert_equal [[owner, victim, true]], hits
    assert_empty v.records, "a resolved volley leaves the roster"
  end

  def test_resolution_skips_dead_foes
    owner = creature(name: "l1", tile: [1, 1])
    victim = creature(name: "v1", tile: [4, 1], faction: :human)
    victim.take_hit(damage: victim.hp, attacker: owner) until victim.dead?
    hp_when_dead = victim.hp
    v = volleys(foes: [victim])
    launch(v, owner, delay_frames: 1)

    v.tick!

    assert_equal hp_when_dead, victim.hp
    assert_empty hits
    assert_empty v.records
  end

  # --- kinetic occupancy (D2, s66 live-play evidence) ---------------------
  # The walker commits its logical tile the instant a step starts; a foe
  # visually still ON an impact tile used to be "already gone" and the
  # volley whiffed with the blast drawn on top of the body (owner report,
  # coop S1). Impact resolution now counts a foe on a tile it COVERS —
  # departure while the tween flies, landing from commit.

  def test_resolution_hits_a_foe_mid_step_off_an_impact_tile
    owner = creature(name: "l1", tile: [1, 1])
    victim = creature(name: "v1", tile: [4, 1], faction: :human)
    v = volleys(foes: [victim])
    launch(v, owner, delay_frames: 2)
    v.tick!
    victim.walker.step(0, 1, frames: 16) # departs [4,1] → commits [4,2] (off-line)
    assert_equal [4, 2], victim.tile, "logical tile has already left the impact line"

    v.tick!

    assert_equal victim.max_hp - 35, victim.hp,
                 "a body still tweening off the tile is IN the blast"
    assert_equal [[owner, victim, true]], hits
  end

  def test_resolution_misses_a_foe_whose_tween_finished_leaving
    owner = creature(name: "l1", tile: [1, 1])
    victim = creature(name: "v1", tile: [4, 1], faction: :human)
    v = volleys(foes: [victim])
    launch(v, owner, delay_frames: 2)
    v.tick!
    victim.walker.step(0, 1, frames: 16)
    16.times { victim.walker.tick } # tween completes — body fully on [4,2]

    v.tick!

    assert_equal victim.max_hp, victim.hp, "a body that finished leaving is out"
    assert_empty hits
  end

  def test_resolution_never_double_hits_a_foe_spanning_two_impact_tiles
    owner = creature(name: "l1", tile: [1, 1])
    victim = creature(name: "v1", tile: [4, 1], faction: :human)
    v = volleys(foes: [victim])
    launch(v, owner, delay_frames: 2)
    v.tick!
    victim.walker.step(1, 0, frames: 16) # [4,1] → [5,1]: BOTH are impact tiles

    v.tick!

    assert_equal victim.max_hp - 35, victim.hp, "one record, one foe, ONE hit"
    assert_equal 1, hits.length
  end

  def test_resolution_still_hits_one_victim_per_tile_alongside_the_dedup
    owner = creature(name: "l1", tile: [1, 1])
    leaver = creature(name: "v1", tile: [3, 1], faction: :human)
    sitter = creature(name: "v2", tile: [4, 1], faction: :human)
    v = volleys(foes: [leaver, sitter])
    launch(v, owner, delay_frames: 2)
    v.tick!
    leaver.walker.step(0, 1, frames: 16) # covers [3,1] while tweening off

    v.tick!

    assert_equal leaver.max_hp - 35, leaver.hp
    assert_equal sitter.max_hp - 35, sitter.hp
    assert_equal 2, hits.length, "dedup never starves a second tile's victim"
  end

  # --- clear! (zone entry) ----------------------------------------------

  def test_clear_empties_the_roster
    owner = creature(name: "l1", tile: [1, 1])
    v = volleys
    launch(v, owner)
    v.clear!
    assert_empty v.records
  end

  # --- digest fold (byte shape pinned) -----------------------------------

  def test_digest_groups_byte_shape
    owner = creature(name: "l1", tile: [1, 1])
    v = volleys
    launch(v, owner)
    launch(v, owner, distances: [2])
    assert_equal [
      ["impact.0", [["owner", "l1"], ["tiles", "3,1|4,1|5,1"],
                    ["frames_left", 40], ["damage", 35]]],
      ["impact.1", [["owner", "l1"], ["tiles", "3,1"],
                    ["frames_left", 40], ["damage", 35]]]
    ], v.digest_groups
  end
end
