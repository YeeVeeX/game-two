require_relative "../test_helper"
require "core/data_store"
require "core/event_bus"
require "core/input"
require "core/tile_map"
require "game/world"

# A0.6 blocker taunt — pure creature state + real-World integration (no mocks).
# Spec: docs/superpowers/specs/2026-08-10-a0.6-blocker-taunt.md (REVISED).
class TauntTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]
  # v13: the taunt block evolved into the challenge (radius 9, duration 450,
  # cause :challenged) — the lock MECHANISM this file pins is unchanged.
  TAUNT = DATA["balance/combat"][:kits][:blocker][:special][:challenge]
  SLAM_WINDUP = DATA["balance/combat"][:kits][:blocker][:special][:windup_frames]

  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["##########", "#........#", "#........#", "#........#", "##########"],
    pack_spawn: [[1, 1], [2, 1], [3, 1]]
  )

  KIT = {
    max_hp: 100, step_frames: 15, aggro_tiles: 8,
    attack: { damage: 10, windup_frames: 6, active_frames: 4, recovery_frames: 10,
              exhaust_frames: 45, arc: "arc3", knockback_tiles: 0, knockback_frames_per_tile: 5 },
    knockback_frames_per_tile: 5
  }.freeze

  EVENTS = %i[attack_started special_started attack_hit damage_dealt actor_died dodged].freeze

  def bus = @bus ||= Core::EventBus.new.register(*EVENTS)

  def pure_creature(tile: [3, 2], faction: :human, name: "c1")
    Game::Creature.new(bus:, kit: KIT, kit_name: :test, map: MAP, tile:, faction:, name:)
  end

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, n, input: scripted({}))
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    drive(world, STEP * 30, input: scripted(hold(:right, 0, STEP * 30 - 1)))
    assert_equal "district", world.zone_name
  end

  def possess_kit(world, kit_name)
    world.pack.members.length.times do
      return world.possessed if world.possessed.kit_name == kit_name
      world.pack.swap_next!
    end
    flunk "could not possess #{kit_name}"
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  # Teleports the blocker to `tile`, parks the other pack members far away,
  # keeps only `keep` humans and stations them per the block.
  def stage(world, blocker_at:, keep: 1)
    enter_district(world)
    blocker = possess_kit(world, :blocker)
    blocker.interrupt_action!
    blocker.walker.teleport(*blocker_at)
    (world.pack.living - [blocker]).each_with_index do |member, i|
      member.walker.teleport(2, 12 + i)
    end
    humans = world.humans.first(keep)
    world.humans.replace(humans)
    [blocker, humans]
  end

  # --- pure creature state --------------------------------------------------

  def test_taunt_sets_target_and_decays_in_tick_body
    victim = pure_creature
    taunter = pure_creature(tile: [5, 2], faction: :pack, name: "t")
    victim.taunt!(taunter, 10)
    assert_same taunter, victim.taunted_target
    assert_equal 10, victim.taunt_frames
    9.times { victim.tick_body }
    assert_same taunter, victim.taunted_target, "still locked at 1 frame left"
    victim.tick_body
    assert_nil victim.taunted_target, "lock expires when frames run out"
  end

  def test_dead_taunter_releases_the_lock
    victim = pure_creature
    taunter = pure_creature(tile: [5, 2], faction: :pack, name: "t")
    victim.taunt!(taunter, 300)
    kill(taunter, by: victim)
    assert_nil victim.taunted_target
  end

  def test_revive_clears_taunt_state
    victim = pure_creature
    taunter = pure_creature(tile: [5, 2], faction: :pack, name: "t")
    victim.taunt!(taunter, 300)
    victim.revive!(map: MAP, tile: [3, 2])
    assert_nil victim.taunted_target
    assert_equal 0, victim.taunt_frames
  end

  def test_retaunt_overwrites_the_lock
    victim = pure_creature
    a = pure_creature(tile: [5, 2], faction: :pack, name: "a")
    b = pure_creature(tile: [6, 2], faction: :pack, name: "b")
    victim.taunt!(a, 5)
    victim.taunt!(b, 300)
    assert_same b, victim.taunted_target
    assert_equal 300, victim.taunt_frames
  end

  # --- pulse (real World) ---------------------------------------------------

  def test_pulse_taunts_range_boundary_and_emits_once
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 2)
    inside, outside = humans
    inside.walker.teleport(21, 12)  # Chebyshev 9 — in (v13 challenge radius)
    outside.walker.teleport(22, 12) # Chebyshev 10 — out
    humans.each { |h| h.stagger!(400) }

    events = []
    world.bus.subscribe(:taunted) { |e| events << e }

    assert blocker.start_special(blocked: [])
    drive(world, SLAM_WINDUP) # windup->active flips in tick_body; pulse resolves same tick
    assert_same blocker, inside.taunted_target
    assert_nil outside.taunted_target
    assert_equal 1, events.length
    assert_equal 1, events.first[:victims]
    assert_equal 1, world.taunt_pulses.length

    drive(world, 3) # rest of the 4 active frames
    assert_equal 1, events.length, "pulse fires ONCE per cast"
    assert_equal TAUNT[:duration_frames] - 3, inside.taunt_frames, "decayed, not re-pulsed"
  end

  def test_ring_damage_unchanged_by_taunt_block
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 1)
    adjacent = humans.first
    adjacent.walker.teleport(13, 12)
    adjacent.stagger!(400)
    hp_before = adjacent.hp

    assert blocker.start_special(blocked: [])
    drive(world, SLAM_WINDUP + 4)
    slam_damage = DATA["balance/combat"][:kits][:blocker][:special][:damage]
    assert_equal hp_before - slam_damage, adjacent.hp, "hit exactly once for slam damage"
    assert_same blocker, adjacent.taunted_target, "adjacent victim is also taunted"
  end

  def test_pulse_records_cleared_on_zone_entry
    blocker = possess_kit(world, :blocker)
    blocker.walker.teleport(27, 8) # nest, near the district gate at [29,8]
    assert blocker.start_special(blocked: [])
    drive(world, SLAM_WINDUP)
    assert world.taunt_pulses.any?, "pulse record exists after cast"
    blocker.walker.teleport(29, 8)
    drive(world, 1)
    assert_equal "district", world.zone_name
    assert_empty world.taunt_pulses, "ghost pulse must not cross the gate"
  end

  # --- AI obedience (real World) --------------------------------------------

  def test_taunted_human_bypasses_the_aggro_gate
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 1)
    far = humans.first
    far.walker.teleport(24, 12) # Chebyshev 12 > aggro 10
    drive(world, 3)
    assert_equal [24, 12], far.tile, "un-taunted human beyond aggro stands still"

    far.taunt!(blocker, 300)
    drive(world, 3)
    refute_equal [24, 12], far.tile, "taunted human chases regardless of distance"
    assert_operator far.tile[0], :<, 24, "…toward the blocker"
  end

  def test_tie_break_goes_striker_untaunted_blocker_taunted
    enter_district(world)
    striker = possess_kit(world, :striker)
    assert_equal :striker, striker.kit_name
    blocker = world.pack.members.find { |m| m.kit_name == :blocker }
    striker.walker.teleport(12, 12)
    blocker.walker.teleport(14, 12)
    (world.pack.living - [striker, blocker]).each { |m| m.walker.teleport(2, 12) }
    human = world.humans.first
    world.humans.replace([human])
    human.walker.teleport(13, 12) # d=1 to BOTH
    # C2: allies trail the walk instead of charging, so the walk-era sticky
    # focus differs — drop it; the subject is the tie-break at ACQUISITION.
    human.focus = nil

    drive(world, 1)
    assert_equal [-1, 0], human.facing, "distance tie goes to the striker (roster index)"

    human.taunt!(blocker, 300)
    drive(world, 1)
    assert_equal [1, 0], human.facing, "taunted, the same tie goes to the blocker"
  end

  # --- the anchor rule (design decision 5) -----------------------------------

  def test_anchor_with_living_victims_ignores_mark
    enter_district(world)
    striker = possess_kit(world, :striker) # stays possessed; blocker is a husk
    blocker = world.pack.members.find { |m| m.kit_name == :blocker }
    striker.walker.teleport(8, 12)
    blocker.revive!(map: world.map, tile: [12, 12]) # clears walk-in combat exhaust
    (world.pack.living - [striker, blocker]).each { |m| m.walker.teleport(2, 13) }
    victim, marked = world.humans.first(2)
    world.humans.replace([victim, marked])
    victim.walker.teleport(11, 12)  # left of the blocker
    marked.walker.teleport(14, 12)  # right of the blocker
    [victim, marked].each { |h| h.stagger!(400) }
    victim.taunt!(blocker, 300)
    world.pack.mark!(marked)

    drive(world, 1)
    assert_equal [-1, 0], blocker.facing, "anchor engages its victim, not the mark"
    assert_equal :windup, blocker.attack_state, "…and swings instead of chasing off"
  end

  def test_anchor_chases_victim_beyond_aggro_instead_of_following
    enter_district(world)
    striker = possess_kit(world, :striker)
    blocker = world.pack.members.find { |m| m.kit_name == :blocker }
    striker.walker.teleport(2, 12)
    blocker.walker.teleport(12, 12)
    (world.pack.living - [striker, blocker]).each { |m| m.walker.teleport(2, 13) }
    victim = world.humans.first
    world.humans.replace([victim])
    victim.walker.teleport(24, 12) # beyond aggro 10 — pre-A0.6 the husk would FOLLOW left
    victim.stagger!(600)
    victim.taunt!(blocker, 600)

    drive(world, 45) # blocker step_frames 19 — enough for 2 committed steps
    assert_operator blocker.tile[0], :>, 12, "anchor holds the line toward its victim"
  end

  # --- lock lifecycle across possession/death (real World) -------------------

  def test_lock_survives_possession_swap
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 1)
    victim = humans.first
    victim.walker.teleport(15, 12)
    victim.taunt!(blocker, 300)
    world.pack.swap_next!
    refute_equal blocker, world.possessed
    assert_same blocker, victim.taunted_target, "the lock rides the body, not the pointer"
  end

  def test_wipe_and_respawn_do_not_resurrect_the_lock
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 1)
    victim = humans.first
    victim.walker.teleport(15, 12)
    victim.stagger!(2000)
    victim.taunt!(blocker, 30_000) # deliberately huge: only a CLEAR can pass this test
    (world.pack.living - [blocker]).each { |m| kill(m, by: victim) }
    kill(blocker, by: victim)
    drive(world, 1)
    assert_equal :nest_respawn, world.states.current

    drive(world, DATA["balance/combat"][:respawn_frames] + 1)
    assert_equal :world, world.states.current
    refute blocker.dead?, "pack respawned"
    assert_nil victim.taunted_target, "revival must not resurrect a lock the blocker never re-cast"
    assert_equal 0, victim.taunt_frames, "state cleared, not merely gated"
  end

  # The organic case the impl review live-reproduced: the victim is FROZEN in
  # an abandoned zone (never ticks), the wipe happens elsewhere, and no reader
  # touches the victim between the taunter's death and its revival. Only the
  # respawn sweep can release this lock.
  def test_abandoned_zone_victim_does_not_relock_after_wipe
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 1)
    victim = humans.first
    victim.walker.teleport(20, 12)
    victim.taunt!(blocker, 30_000)

    # Whole pack transits home; the district victim freezes with its lock.
    ([blocker] + (world.pack.living - [blocker])).each_with_index do |m, i|
      m.walker.teleport(0 + (i.zero? ? 0 : 1), 13 - i)
    end
    blocker.walker.teleport(0, 13)
    drive(world, 1)
    assert_equal "nest", world.zone_name

    # Wipe in the nest — no district reader runs from here to revival.
    world.pack.living.each { |m| kill(m, by: victim) }
    drive(world, DATA["balance/combat"][:respawn_frames] + 2)
    assert_equal :world, world.states.current
    refute blocker.dead?

    assert_nil victim.taunted_target, "frozen victim must not re-lock the revived taunter"
    assert_equal 0, victim.taunt_frames, "respawn sweep released the abandoned-zone lock"
  end

  # The reader is PURE (impl review 2): calling taunted_target on a victim of
  # a dead taunter must not mutate — the renderer calls it from draw, and a
  # mutating reader would let wall-clock draw timing change sim state.
  def test_taunted_target_reader_is_pure
    victim = pure_creature
    taunter = pure_creature(tile: [5, 2], faction: :pack, name: "t")
    victim.taunt!(taunter, 300)
    kill(taunter, by: victim)
    assert_nil victim.taunted_target
    assert_equal 300, victim.taunt_frames, "reader must not clear state (sim owns clearing)"
  end
end
