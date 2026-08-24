require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Striker special = DASH-STRIKE (owner-directed s66, kit-identity fork:
# striker CUTS THROUGH, blocker plants and controls, lobber bombards).
# Lineage: v13 (B) clump-payoff whirlwind — the ring shape is gone but
# the v13 refund LAW carries whole: efficiency scales with bodies
# crossed via the exhaust refund per extra victim, refund anchors at
# the active->recovery transition, and interrupt paths refund NOTHING.
# Real World / real creatures, no mocks.
class WhirlwindTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  SPECIAL = DATA["balance/combat"][:kits][:striker][:special]
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]
  # Dash active window = travel duration (cardinal): tiles * frames_per_tile.
  DURATION = SPECIAL[:max_tiles] * SPECIAL[:frames_per_tile]

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

  # Striker at [12,12] facing right (fresh possession default), other
  # pack parked far left, victims ON THE DASH LINE [13,12], [14,12] —
  # the landing [15,12] stays free (through: true crosses bodies but
  # never lands on one). victims: 1 or 2.
  LINE_TILES = [[13, 12], [14, 12]].freeze

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
      h.heal_full!
      h.walker.teleport(*LINE_TILES.fetch(i))
      h.stagger!(600)
    end
    [striker, humans]
  end

  # Hitstop pauses actor clocks (v12 trap: HITSTOP_SLACK) — world-level
  # drives run long and assert BEHAVIOR (ready or not), never exact clocks.
  HITSTOP_SLACK = 60

  def cast_and_resolve(world, striker)
    assert striker.start_special(blocked: world.blocked_for(striker))
    drive(world, SPECIAL[:windup_frames] + DURATION + HITSTOP_SLACK)
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

  # Mirrors World#resolve_dash_action: register hits during the active window.
  def rip_with_hits(striker, victims)
    assert striker.start_special(blocked: [])
    SPECIAL[:windup_frames].times { striker.tick_body }
    assert striker.action_active?, "active window open (dash committed)"
    victims.each { |v| striker.action_hit!(v) }
    striker.instance_variable_get(:@dash_plan).duration.times { striker.tick_body }
    assert_equal :recovery, striker.attack_state, "refund anchor crossed"
  end

  def exhaust_of(c) = c.instance_variable_get(:@special_exhaust)

  def expected_exhaust(victims, duration: DURATION)
    ticks = SPECIAL[:windup_frames] + duration
    refund = SPECIAL[:refund_frames_per_extra_hit] * [victims - 1, 0].max
    [SPECIAL[:exhaust_frames] - ticks - refund, 0].max
  end

  # --- the cut-through verb (world level) --------------------------------

  def test_dash_hits_every_crossed_body_once_and_spares_off_line
    striker, humans = stage(world, victims: 2)
    hps = humans.map(&:hp)

    cast_and_resolve(world, striker)

    assert_equal hps[0] - SPECIAL[:damage], humans[0].hp, "first crossed body struck"
    assert_equal hps[1] - SPECIAL[:damage], humans[1].hp, "second crossed body struck"
  end

  # World-level stop-short: bodies on the LAST TWO scan tiles — the feet
  # land on the only free tile; both bodies still take the blade.
  def test_dash_strikes_bodies_past_a_short_landing
    striker, humans = stage(world, victims: 2)
    humans[0].walker.teleport(14, 12)
    humans[1].walker.teleport(15, 12) # scan [13..15,12]: only [13,12] free
    hps = humans.map(&:hp)

    cast_and_resolve(world, striker)

    assert_equal [13, 12], striker.tile, "feet stop on the last free tile"
    assert_equal hps[0] - SPECIAL[:damage], humans[0].hp, "blade reaches tile 2"
    assert_equal hps[1] - SPECIAL[:damage], humans[1].hp, "blade reaches tile 3"
  end

  def test_dash_moves_the_striker_to_the_landing_past_the_bodies
    striker, = stage(world, victims: 2)
    assert striker.start_special(blocked: world.blocked_for(striker))
    assert_equal [15, 12], striker.reserved_tile,
                 "windup telegraphs the landing (reserved through the plan)"
    drive(world, SPECIAL[:windup_frames] + DURATION + HITSTOP_SLACK)
    assert_equal [15, 12], striker.tile, "the rip ends PAST the crossed bodies"
  end

  def test_crossed_victims_are_not_displaced
    striker, humans = stage(world, victims: 2)
    cast_and_resolve(world, striker)
    assert_equal LINE_TILES[0], humans[0].tile, "kb 0 — pass through, no shove"
    assert_equal LINE_TILES[1], humans[1].tile
  end

  def test_dash_is_invulnerable_in_flight_but_not_in_windup
    striker = pure_striker
    foe = pure_victim(tile: [3, 3], name: "v0")
    assert striker.start_special(blocked: [])
    SPECIAL[:windup_frames].times { striker.tick_body }
    assert striker.action_active?
    hp = striker.hp
    landed = striker.take_hit(damage: 5, attacker: foe)
    refute landed, "iframes cover the flight"
    assert_equal hp, striker.hp
  end

  def test_windup_hit_breaks_the_cast_striker_interrupt_law
    striker = pure_striker
    foe = pure_victim(tile: [3, 3], name: "v0")
    assert striker.start_special(blocked: [])
    2.times { striker.tick_body }
    assert striker.take_hit(damage: 5, attacker: foe), "no iframes in windup"
    assert_equal :idle, striker.attack_state, "interrupt_on_hit breaks the wind"
  end

  # --- launch geometry edges ---------------------------------------------

  def test_wall_truncates_the_rip_honestly
    striker = pure_striker(tile: [7, 2]) # wall at x=9: one free tile ahead
    assert striker.start_special(blocked: [])
    plan = striker.instance_variable_get(:@dash_plan)
    assert_equal [8, 2], plan.landing, "the chain shortens at the wall"
    assert_equal [[8, 2]], plan.crossed
    assert_equal [[8, 2]], plan.struck, "walls stop the blade AND the feet"
  end

  # The stop-short strike (s66 pilot evidence, capture dashcap_r1): a body
  # on the tile PAST the landing stops the FEET, never the BLADE — the
  # strike line is the full scan; the movement truncates at the last free
  # tile. Without this the everyday case (enemy dead ahead, no free tile
  # beyond) whiffed into the target's face.
  def test_body_past_the_landing_is_struck_while_the_feet_stop_short
    striker = pure_striker # [3,2] facing right; scan [4,2],[5,2],[6,2]
    blocked = [[6, 2]] # a body on the LAST scanned tile
    assert striker.start_special(blocked:)
    plan = striker.instance_variable_get(:@dash_plan)
    assert_equal [5, 2], plan.landing, "feet stop on the last free tile"
    assert_equal [[4, 2], [5, 2]], plan.crossed
    assert_equal [[4, 2], [5, 2], [6, 2]], plan.struck,
                 "the blade reaches the body the feet cannot pass"
    assert_equal plan.struck, striker.action_tiles, "action_tiles serves the strike line"
  end

  def test_fully_blocked_landing_refuses_and_burns_nothing
    striker = pure_striker # facing right from [3,2]
    blocked = [[4, 2], [5, 2], [6, 2]] # a body on every reachable landing
    refute striker.start_special(blocked:), "nowhere to land — refuse"
    assert_equal :idle, striker.attack_state
    assert striker.special_ready?, "a refused cast burns no exhaust"
  end

  # --- v13 refund law (carried whole) --------------------------------------

  def test_refund_scales_with_extra_victims
    striker = pure_striker
    victims = 3.times.map { |i| pure_victim(tile: [4 + i, 3], name: "v#{i}") }
    rip_with_hits(striker, victims)
    assert_equal expected_exhaust(3), exhaust_of(striker)
  end

  def test_single_victim_gets_no_refund
    striker = pure_striker
    rip_with_hits(striker, [pure_victim(tile: [4, 2], name: "v0")])
    assert_equal expected_exhaust(1), exhaust_of(striker)
  end

  def test_refund_floors_at_zero_on_a_dense_rip
    striker = pure_striker
    victims = 8.times.map { |i| pure_victim(tile: [1 + i, 3], name: "v#{i}") }
    rip_with_hits(striker, victims)
    assert_equal 0, exhaust_of(striker)
    assert striker.special_ready?, "a dense burst re-arms the special"
  end

  def test_interrupted_rip_refunds_nothing
    striker = pure_striker
    victim = pure_victim(tile: [4, 2], name: "v0")
    assert striker.start_special(blocked: [])
    SPECIAL[:windup_frames].times { striker.tick_body }
    assert striker.action_active?
    striker.action_hit!(victim)
    striker.action_hit!(pure_victim(tile: [2, 2], name: "v1"))
    striker.interrupt_action! # external break (seize-class) mid-flight
    assert_equal :idle, striker.attack_state
    4.times { striker.tick_body }
    ticks = SPECIAL[:windup_frames] + 4
    assert_equal SPECIAL[:exhaust_frames] - ticks, exhaust_of(striker),
                 "interrupt paths never cross the refund anchor"
  end

  # World-level refund read (hitstop-proof): two crossed bodies refund one
  # extra (120f) — that striker re-arms first; the single-victim striker's
  # longer clock is still running when it does.
  def test_two_body_rip_rearms_before_a_single_body_rip
    striker, = stage(world, victims: 2)
    cast_and_resolve(world, striker)
    drive(world, 320)
    assert striker.special_ready?, "two crossed bodies = one extra refund — re-armed"

    @world = nil # fresh world
    striker2, = stage(world, victims: 1)
    cast_and_resolve(world, striker2)
    drive(world, 320)
    refute striker2.special_ready?, "single victim keeps the full exhaust clock"
  end
end
