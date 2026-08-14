require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v13 (B) clump-payoff whirlwind — striker special becomes a ring burst whose
# efficiency scales with target count via an exhaust refund per extra victim.
# Spec: docs/superpowers/specs/2026-08-14-v13-aoe-specials-design.md §1.
# Real World, no mocks. Refund anchors at the active->recovery transition
# (Codex fold: interrupt paths clear @hit_victims and refund NOTHING).
class WhirlwindTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  SPECIAL = DATA["balance/combat"][:kits][:striker][:special]
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]

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

  # Striker at [12,12], other pack parked, `ring` humans on adjacent tiles
  # (fixed order), everyone staggered so only the whirlwind acts.
  RING_TILES = [[13, 12], [11, 12], [12, 11], [12, 13],
                [13, 11], [11, 13], [13, 13], [11, 11]].freeze

  def stage(world, victims:)
    enter_district(world)
    striker = possess_kit(world, :striker)
    striker.interrupt_action!
    striker.walker.teleport(12, 12)
    (world.pack.living - [striker]).each_with_index do |member, i|
      member.walker.teleport(2, 12 + i)
    end
    humans = world.humans.first(victims)
    flunk "district spawned too few humans" if humans.length < victims
    world.humans.replace(humans)
    humans.each_with_index do |h, i|
      h.walker.teleport(*RING_TILES.fetch(i))
      h.stagger!(600)
    end
    [striker, humans]
  end

  # Hitstop pauses actor clocks (v12 trap: HITSTOP_SLACK) — world-level
  # drives run long and assert BEHAVIOR (ready or not), never exact clocks.
  HITSTOP_SLACK = 60

  def cast_and_resolve(world, striker)
    assert striker.start_special(blocked: world.blocked_for(striker))
    drive(world, SPECIAL[:windup_frames] + SPECIAL[:active_frames] + HITSTOP_SLACK)
  end

  # --- refund math: pure creature (real striker kit, no feel/hitstop) -------

  PURE_EVENTS = %i[attack_started special_started attack_hit damage_dealt
                   actor_died dodged].freeze

  def pure_bus = @pure_bus ||= Core::EventBus.new.register(*PURE_EVENTS)

  def pure_map
    @pure_map ||= Core::TileMap.new(
      tile_size: 32, display_name: "test", palette: {},
      tiles: ["##########", "#........#", "#........#", "#........#", "##########"],
      pack_spawn: [[1, 1], [2, 1], [3, 1]]
    )
  end

  def pure_striker(tile: [3, 2])
    Game::Creature.new(bus: pure_bus, kit: DATA["balance/combat"][:kits][:striker],
                       kit_name: :striker, map: pure_map, tile:, faction: :pack, name: "s")
  end

  def pure_victim(tile:, name:)
    Game::Creature.new(bus: pure_bus, kit: DATA["balance/combat"][:kits][:rusher],
                       kit_name: :rusher, map: pure_map, tile:, faction: :human, name:)
  end

  # Mirrors World#resolve_tile_action: register hits during the active window.
  def spin_with_hits(striker, victims)
    assert striker.start_special(blocked: [])
    SPECIAL[:windup_frames].times { striker.tick_body }
    assert striker.action_active?, "active window open"
    victims.each { |v| striker.action_hit!(v) }
    SPECIAL[:active_frames].times { striker.tick_body }
    assert_equal :recovery, striker.attack_state, "refund anchor crossed"
  end

  def exhaust_of(c) = c.instance_variable_get(:@special_exhaust)

  def expected_exhaust(victims)
    ticks = SPECIAL[:windup_frames] + SPECIAL[:active_frames]
    refund = SPECIAL[:refund_frames_per_extra_hit] * [victims - 1, 0].max
    [SPECIAL[:exhaust_frames] - ticks - refund, 0].max
  end

  def test_whirlwind_hits_every_adjacent_enemy_once_and_spares_range_two
    striker, humans = stage(world, victims: 3)
    far = humans.last
    far.walker.teleport(14, 12) # Chebyshev 2 — outside the ring
    hps = humans.map(&:hp)

    cast_and_resolve(world, striker)

    assert_equal hps[0] - SPECIAL[:damage], humans[0].hp
    assert_equal hps[1] - SPECIAL[:damage], humans[1].hp
    assert_equal hps[2], far.hp, "ring1 only — no reach-2 hits"
  end

  def test_refund_scales_with_extra_victims
    striker = pure_striker
    victims = 3.times.map { |i| pure_victim(tile: RING_TILES[i].map { |v| v - 9 }, name: "v#{i}") }
    spin_with_hits(striker, victims)
    assert_equal expected_exhaust(3), exhaust_of(striker)
  end

  def test_single_victim_gets_no_refund
    striker = pure_striker
    spin_with_hits(striker, [pure_victim(tile: [4, 2], name: "v0")])
    assert_equal expected_exhaust(1), exhaust_of(striker)
  end

  def test_refund_floors_at_zero_on_a_full_ring
    striker = pure_striker
    victims = 8.times.map { |i| pure_victim(tile: [1 + i, 3], name: "v#{i}") }
    spin_with_hits(striker, victims)
    assert_equal 0, exhaust_of(striker)
    assert striker.special_ready?, "a full-ring burst re-arms the special"
  end

  def test_interrupted_spin_refunds_nothing
    striker = pure_striker
    victim = pure_victim(tile: [4, 2], name: "v0")
    assert striker.start_special(blocked: [])
    SPECIAL[:windup_frames].times { striker.tick_body }
    assert striker.action_active?
    striker.action_hit!(victim)
    striker.action_hit!(pure_victim(tile: [2, 2], name: "v1"))
    striker.take_hit(damage: 5, attacker: victim) # interrupt_on_hit
    assert_equal :idle, striker.attack_state, "striker spin breaks on a hit"
    4.times { striker.tick_body }
    ticks = SPECIAL[:windup_frames] + 4
    assert_equal SPECIAL[:exhaust_frames] - ticks, exhaust_of(striker),
                 "no refund on an interrupted spin"
  end

  # World-level refund read (hitstop-proof): a full ring re-arms within the
  # slack window; a single victim leaves the long clock running.
  def test_full_ring_rearms_in_world_single_victim_does_not
    striker, = stage(world, victims: 8)
    cast_and_resolve(world, striker)
    assert striker.special_ready?, "8-victim burst refunds to zero — ready again"

    @world = nil # fresh world
    striker2, = stage(world, victims: 1)
    cast_and_resolve(world, striker2)
    refute striker2.special_ready?, "single-victim spin keeps the full exhaust"
  end

  def test_whirlwind_does_not_move_the_striker
    striker, = stage(world, victims: 2)
    assert striker.start_special(blocked: world.blocked_for(striker))
    assert_nil striker.reserved_tile, "no dash plan — nothing reserved"
    drive(world, SPECIAL[:windup_frames] + SPECIAL[:active_frames] +
                 SPECIAL[:recovery_frames])
    assert_equal [12, 12], striker.tile, "the dash is gone: the spin stands its ground"
  end

  def test_victims_knocked_radially_outward
    striker, humans = stage(world, victims: 2)
    east, west = humans # RING_TILES order: [13,12] then [11,12]
    cast_and_resolve(world, striker)
    drive(world, SPECIAL[:knockback_tiles] *
                 DATA["balance/combat"][:kits][:striker][:knockback_frames_per_tile] + 2)
    assert_equal [14, 12], east.tile, "east victim shoved further east"
    assert_equal [10, 12], west.tile, "west victim shoved further west"
  end
end
