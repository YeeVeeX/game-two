require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v11 density/re-massing: release-time anchored respawns (spec
# 2026-08-13-v11-density-remassing-design.md §1-2). The tile is chosen when
# the respawn RELEASES, not when the human died: join the nearest eligible
# pocket, else seed at the spawn tile farthest from the pack, else home.
class DensityRespawnTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]
  RESPAWN = DATA["balance/combat"][:kits][:rusher][:respawn_frames]
  DENSITY = DATA["balance/threat"][:density]

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    assert_equal "district", world.zone_name
  end

  def chebyshev((ax, ay), (bx, by)) = [(bx - ax).abs, (by - ay).abs].max

  # Kill every district human and drop the scheduled respawns — a clean
  # field to stage pockets on (the threat_respawn_test idiom).
  def clear_field(world)
    world.humans.dup.each { |h| h.take_hit(damage: h.hp, attacker: world.possessed) until h.dead? }
    drive(world, scripted({}), 1) # flush bus -> respawns scheduled
    world.instance_variable_get(:@human_respawns)["district"].clear
  end

  def park_pack(world, tiles)
    world.pack.living.each_with_index { |m, i| m.walker.teleport(*tiles[i]) }
  end

  FAR_PARK = [[1, 1], [1, 2], [1, 3]].freeze

  # Add a human that stays put: staggered far past the test horizon.
  def stage_human(world, tile, kit: :rusher)
    world.send(:add_human, "district", kit, tile)
    h = world.humans.find { |c| c.tile == tile }
    h.stagger!(30_000)
    h
  end

  # Kill a freshly added human on the spot -> exactly one scheduled respawn.
  def schedule_one_respawn(world, tile: [20, 12])
    world.send(:add_human, "district", :rusher, tile)
    victim = world.humans.find { |c| c.tile == tile }
    victim.take_hit(damage: victim.hp, attacker: world.possessed) until victim.dead?
    drive(world, scripted({}), 1) # flush -> schedules {kit_name, at_frame}
  end

  def record_respawn_events(world)
    events = []
    world.bus.subscribe(:human_respawned) { |e| events << e }
    events
  end

  # --- density_pockets (the shared reader) --------------------------------

  def test_density_pockets_groups_living_humans_by_chain_distance
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    r = DENSITY[:join_radius_tiles]
    # A—B at exactly join radius, C chained off B, D isolated.
    stage_human(w, [10, 5])
    stage_human(w, [10 + r, 5])
    stage_human(w, [10 + 2 * r, 5])
    stage_human(w, [30, 12])
    sizes = w.density_pockets.map(&:length).sort
    assert_equal [1, 3], sizes,
                 "chain distance groups A-B-C into one pocket, D alone"
  end

  def test_density_pockets_excludes_dead_humans
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    stage_human(w, [10, 5])
    doomed = stage_human(w, [12, 5])
    doomed.take_hit(damage: doomed.hp, attacker: w.possessed) until doomed.dead?
    # Not yet flushed: doomed is dead but still on the roster this instant.
    sizes = w.density_pockets.map(&:length)
    assert_equal [1], sizes, "a dead body is not a pocket member"
  end

  # --- release-time anchoring ---------------------------------------------

  def test_respawn_joins_the_surviving_pocket_at_release_time
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    stage_human(w, [40, 23])
    stage_human(w, [40, 24])
    events = record_respawn_events(w)
    schedule_one_respawn(w) # dies at [20, 12] — the OLD law would re-home it
    park_pack(w, FAR_PARK)
    count = w.humans.length
    drive(w, scripted({}), RESPAWN + 10)
    assert_equal count + 1, w.humans.length, "the respawn released"
    fresh = w.humans.find { |h| ![[40, 23], [40, 24]].include?(h.tile) }
    assert fresh, "a new body joined the field"
    assert chebyshev(fresh.tile, [40, 23]) <= DENSITY[:scatter_radius_tiles],
           "release-time anchor: the respawn lands beside the pocket, " \
           "not at its home spawn (landed #{fresh.tile})"
    assert_equal 1, events.length
    assert_equal :pocket, events.first[:anchor]
    assert_equal fresh, events.first[:actor],
                 "event actor is the creature itself, not the roster array"
    assert_equal fresh.tile, events.first[:tile]
  end

  def test_respawn_seeds_farthest_spawn_when_the_field_is_empty
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    events = record_respawn_events(w)
    schedule_one_respawn(w)
    park_pack(w, FAR_PARK)
    # Farthest rusher spawn from the pack at column 1: [40, 19].
    drive(w, scripted({}), RESPAWN + 10)
    fresh = w.humans.first
    refute_nil fresh, "the respawn released onto the empty field"
    assert chebyshev(fresh.tile, [40, 19]) <= DENSITY[:scatter_radius_tiles],
           "seed anchors at the spawn tile farthest from the pack " \
           "(landed #{fresh.tile})"
    assert_equal :seed, events.first[:anchor]
  end

  def test_back_to_back_releases_never_stack
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    stage_human(w, [40, 23])
    schedule_one_respawn(w, tile: [20, 12])
    schedule_one_respawn(w, tile: [22, 12])
    park_pack(w, FAR_PARK)
    drive(w, scripted({}), RESPAWN + 12)
    tiles = w.actors.map(&:tile)
    assert_equal tiles.uniq.length, tiles.length,
                 "two same-tick releases claim different tiles: #{tiles}"
    assert_equal 3, w.humans.length
  end

  # --- defer rules on the CHOSEN tile -------------------------------------

  def test_respawn_defers_while_the_pack_covers_every_scatter_tile
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    stage_human(w, [40, 23]) # single pocket -> the anchor is known
    schedule_one_respawn(w)
    # Park within block_radius - scatter_radius of the anchor: every
    # possible scatter tile sits inside the block radius, whatever the RNG
    # picks. Freeze the pack so 300 frames of proximity stage no combat.
    park_pack(w, [[34, 21], [34, 22], [34, 23]])
    w.pack.living.each { |m| m.stagger!(30_000) }
    count = w.humans.length
    drive(w, scripted({}), RESPAWN + 20)
    assert_equal count, w.humans.length,
                 "respawn defers while a pack body blocks the chosen tile's radius"
    park_pack(w, FAR_PARK)
    drive(w, scripted({}), 3)
    assert_equal count + 1, w.humans.length, "deferred respawn lands once clear"
    fresh = w.humans.find { |h| h.tile != [40, 23] }
    assert chebyshev(fresh.tile, [40, 23]) <= DENSITY[:scatter_radius_tiles],
           "the deferred release still re-masses onto the pocket"
  end

  def test_respawn_defers_within_corpse_guard_of_a_live_load
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    events = record_respawn_events(w)
    schedule_one_respawn(w)
    # A live corpse load 2 tiles from the seed anchor [40, 19]: every
    # scatter candidate sits within corpse_guard_tiles (2 + 4 <= 6).
    w.possessed.walker.teleport(38, 19)
    w.possessed.pick_up(2)
    w.field_economy.spawn_corpse_load(w.possessed, nil, zone: w.zone_name)
    park_pack(w, FAR_PARK)
    count = w.humans.length
    drive(w, scripted({}), RESPAWN + 20)
    assert_equal count, w.humans.length,
                 "a re-massed pocket must not camp the run-back (corpse guard)"
    w.corpse_loads.clear # loot/expiry lifts the guard
    drive(w, scripted({}), 3)
    assert_equal count + 1, w.humans.length, "guard lifts with the load"
    assert_equal :seed, events.first[:anchor]
  end

  # --- fallbacks -----------------------------------------------------------

  def test_home_fallback_lands_on_the_death_tile_when_the_zone_has_no_spawns
    w = Game::World.new(DATA, seed: 42)
    # The nest has enemy_spawns {} — the no-spawn-list edge, today's exact
    # behavior: the record's own fallback tile.
    assert_equal "nest", w.zone_name
    events = record_respawn_events(w)
    w.send(:add_human, "nest", :rusher, [28, 2]) # 13 tiles from the pack spawn
    victim = w.humans.find { |c| c.tile == [28, 2] }
    victim.take_hit(damage: victim.hp, attacker: w.possessed) until victim.dead?
    drive(w, scripted({}), RESPAWN + 10)
    fresh = w.humans.first
    refute_nil fresh, "the respawn released in the spawnless zone"
    assert_equal [28, 2], fresh.tile, "no spawn list -> the death tile, as today"
    assert_equal :home, events.first[:anchor]
  end

  def test_empty_pack_falls_through_to_the_first_home_spawn
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    # The last pack body can die mid-tick before the wipe transition lands:
    # seed's "farthest from the pack" has no referent.
    w.pack.members.each { |m| m.take_hit(damage: m.hp, attacker: m) until m.dead? }
    w.instance_variable_get(:@human_respawns)["district"] <<
      { kit_name: :rusher, at_frame: 0 }
    w.send(:respawn_due_humans)
    fresh = w.humans.first
    refute_nil fresh, "an empty pack must not strand the release"
    assert_equal DATA["zones/district"][:enemy_spawns][:rusher].first, fresh.tile,
                 "empty pack -> deterministic home fallback (first spawn tile)"
  end

  # --- determinism ----------------------------------------------------------

  def test_same_seed_same_staging_lands_on_the_same_tile
    tiles = 2.times.map do
      w = Game::World.new(DATA, seed: 7)
      enter_district(w)
      clear_field(w)
      stage_human(w, [40, 23])
      stage_human(w, [40, 24])
      schedule_one_respawn(w)
      park_pack(w, FAR_PARK)
      drive(w, scripted({}), RESPAWN + 10)
      fresh = w.humans.find { |h| ![[40, 23], [40, 24]].include?(h.tile) }
      refute_nil fresh
      fresh.tile
    end
    assert_equal tiles[0], tiles[1],
                 "seeded scatter picks are replay-deterministic"
  end
end
