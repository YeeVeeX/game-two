require_relative "../test_helper"
require "core/event_bus"
require "core/tile_map"
require "game/creature"

class CreatureTest < Minitest::Test
  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["##########", "#........#", "#........#", "#........#", "##########"],
    pack_spawn: [[1, 1], [2, 1], [3, 1]]
  )

  KIT = {
    max_hp: 100, step_frames: 15, aggro_tiles: 8,
    attack: { damage: 25, windup_frames: 6, active_frames: 4, recovery_frames: 10,
              exhaust_frames: 45, arc: "arc3", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    special: { damage: 50, windup_frames: 6, recovery_frames: 0,
               exhaust_frames: 480, arc: "dash", max_tiles: 4,
               frames_per_tile: 4, knockback_tiles: 0 },
    dodge: { tiles: 2, frames_per_tile: 7, iframes: 18, cooldown_frames: 50 },
    knockback_frames_per_tile: 5
  }.freeze

  RING_KIT = {
    max_hp: 60, step_frames: 17, aggro_tiles: 12,
    attack: { damage: 15, windup_frames: 30, active_frames: 6, recovery_frames: 0,
              exhaust_frames: 81, arc: "ring", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    knockback_frames_per_tile: 5
  }.freeze

  BLOCKER_KIT = {
    max_hp: 160, step_frames: 19, aggro_tiles: 10,
    attack: { damage: 25, windup_frames: 8, active_frames: 4, recovery_frames: 12,
              exhaust_frames: 60, arc: "arc3", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    special: { damage: 30, windup_frames: 12, active_frames: 4, recovery_frames: 12,
               exhaust_frames: 600, arc: "ring", knockback_tiles: 2,
               stagger_frames: 45, interrupt_windup: true },
    dodge: { tiles: 1, frames_per_tile: 9, iframes: 12, cooldown_frames: 70 },
    knockback_frames_per_tile: 5,
    interrupt_on_hit: false
  }.freeze

  EVENTS = %i[attack_started special_started attack_hit damage_dealt actor_died dodged].freeze

  def bus = @bus ||= Core::EventBus.new.register(*EVENTS)

  def creature(kit: KIT, kit_name: :striker, tile: [3, 2], faction: :pack)
    Game::Creature.new(bus:, kit:, kit_name:, map: MAP, tile:, faction:, name: "c1")
  end

  def test_exhaust_gates_attack_cadence
    c = creature
    assert c.start_attack, "first swing starts"
    assert_equal :attack, c.current_action
    refute c.start_attack, "second swing refused while exhausted"
    44.times { c.tick_body }
    refute c.exhaust_ready?, "still exhausted at 44f"
    c.tick_body
    assert c.exhaust_ready?, "exhaust clears at 45f"
    assert c.start_attack, "swing available again at exhaust pace"
  end

  def test_special_uses_action_data_and_per_victim_registry
    c = creature(kit: BLOCKER_KIT, kit_name: :blocker)
    a = creature(kit: RING_KIT, tile: [2, 1], faction: :human)
    b = creature(kit: RING_KIT, tile: [4, 1], faction: :human)

    assert c.start_special(blocked: [])
    assert_equal :special, c.current_action
    assert_equal BLOCKER_KIT[:special], c.action_config
    refute c.special_ready?
    refute c.start_attack, "basic attack cannot start inside a special"

    BLOCKER_KIT[:special][:windup_frames].times { c.tick_body }
    assert_equal :active, c.attack_state
    assert_equal 8, c.action_tiles.length
    assert c.action_can_hit?(a)
    c.action_hit!(a)
    refute c.action_can_hit?(a)
    assert c.action_can_hit?(b), "one victim must not close a multi-target cast"
  end

  def test_volley_has_no_caster_local_action_tiles
    volley_kit = BLOCKER_KIT.merge(
      special: BLOCKER_KIT[:special].merge(arc: "volley")
    )
    c = creature(kit: volley_kit, kit_name: :lobber)

    assert c.start_special(blocked: [])
    assert_empty c.action_tiles, "Volley's only target tiles belong to its delayed impact"
  end

  def test_special_exhaust_is_independent_and_revive_resets_it_ready
    c = creature(kit: BLOCKER_KIT, kit_name: :blocker)
    assert c.start_special(blocked: [])
    assert c.exhaust_ready?, "special never spends the basic-attack clock"
    599.times { c.tick_body }
    refute c.special_ready?
    c.tick_body
    assert c.special_ready?

    assert c.start_special(blocked: [])
    refute c.special_ready?
    c.revive!(map: MAP, tile: [3, 2])
    assert c.special_ready?, "wipe revive resets the special ready"
    assert_nil c.current_action
    assert_equal :idle, c.attack_state
  end

  def test_lunge_refuses_without_a_free_landing_and_spends_nothing
    c = creature
    blocked = [[4, 2], [5, 2], [6, 2], [7, 2]]
    refute c.start_special(blocked:)
    assert c.special_ready?
    assert_nil c.current_action
    assert_equal [3, 2], c.tile
  end

  def test_lunge_commits_stored_plan_and_grants_dash_iframes_only
    c = creature
    assert c.start_special(blocked: [[4, 2], [6, 2]])
    assert_equal [7, 2], c.reserved_tile
    assert_equal [[4, 2], [5, 2], [6, 2], [7, 2]], c.action_tiles
    assert_equal 0, c.dodge_cooldown

    KIT[:special][:windup_frames].times { c.tick_body }

    assert_equal :active, c.attack_state
    assert_equal [7, 2], c.tile
    assert c.iframes?
    assert_equal 0, c.dodge_cooldown, "Lunge never spends the dodge clock"
    assert_nil c.reserved_tile, "logical landing is committed at active entry"
  end

  def test_no_blanket_invuln_two_attackers_both_land
    c = creature
    a1 = creature(kit: RING_KIT, tile: [2, 2], faction: :human)
    a2 = creature(kit: RING_KIT, tile: [4, 2], faction: :human)
    assert c.take_hit(damage: 15, attacker: a1)
    assert c.take_hit(damage: 15, attacker: a2), "no post-hit immunity: second attacker also lands"
    assert_equal 70, c.hp
  end

  def test_dodge_iframes_still_block
    c = creature
    attacker = creature(kit: RING_KIT, tile: [2, 2], faction: :human)
    assert c.dodge([1, 0])
    assert c.iframes?
    refute c.take_hit(damage: 15, attacker:), "dodge i-frames block (active defense stays)"
    assert_equal 100, c.hp
  end

  def test_arc3_and_ring_attack_tiles
    c = creature(tile: [3, 2])
    c.face([1, 0])
    assert c.start_attack
    assert_equal [[4, 2], [4, 3], [4, 1]], c.action_tiles, "cardinal facing: front + diagonals"
    r = creature(kit: RING_KIT, tile: [3, 2])
    assert r.start_attack
    assert_equal 8, r.action_tiles.length, "ring hits all Chebyshev neighbors"
    assert_includes r.action_tiles, [2, 1]
    refute_includes r.action_tiles, [3, 2], "ring excludes own tile"
  end

  # M2.1 fix 4: the pincer fills the adjacent ring; a dodge must pass THROUGH
  # bodies and land on the first free tile in range, or it is a dead verb
  # exactly when it matters.
  def test_dodge_passes_through_adjacent_body
    c = creature(tile: [3, 2])
    # Body on [4,2] (first tile right), [5,2] free, dodge range 2.
    assert c.dodge([1, 0], blocked: [[4, 2]])
    assert_equal [5, 2], c.tile, "dodge crosses the body and lands beyond it"
    assert c.iframes?, "escape grants i-frames"
  end

  def test_dodge_never_lands_on_a_body
    c = creature(tile: [3, 2])
    # Bodies on BOTH tiles in range: nowhere free -> refuse, no cooldown burn.
    refute c.dodge([1, 0], blocked: [[4, 2], [5, 2]])
    assert_equal [3, 2], c.tile
    refute c.iframes?, "refused dodge grants nothing"
    assert c.dodge([-1, 0], blocked: [[4, 2], [5, 2]]), "cooldown not burned by the refusal"
  end

  def test_dodge_still_stops_at_walls
    c = creature(tile: [7, 2]) # wall at x=9; range-2 dodge right can only reach [8,2]
    assert c.dodge([1, 0])
    assert_equal [8, 2], c.tile, "wall clamps the dash"
    d = creature(tile: [8, 2])
    refute d.dodge([1, 0]), "dodging straight into a wall refuses"
  end

  def test_stagger_blocks_verbs_until_expired
    c = creature
    c.stagger!(20)
    refute c.start_attack, "staggered: no attack"
    refute c.step(1, 0, blocked: []), "staggered: no step"
    refute c.dodge([1, 0]), "staggered: no dodge"
    20.times { c.tick_body }
    assert c.step(1, 0, blocked: []), "stagger expired: verbs return"
  end

  def test_death_emits_actor_died_with_killer
    c = creature
    killer = creature(kit: RING_KIT, tile: [2, 2], faction: :human)
    died = nil
    bus.subscribe(:actor_died) { |e| died = e }
    4.times { c.take_hit(damage: 25, attacker: killer) }
    bus.process
    assert c.dead?
    assert_equal c, died[:actor]
    assert_equal killer, died[:killer]
  end

  def test_kill_does_not_double_fire
    c = creature
    killer = creature(kit: RING_KIT, tile: [2, 2], faction: :human)
    4.times { c.take_hit(damage: 25, attacker: killer) }
    refute c.take_hit(damage: 25, attacker: killer), "dead creatures take no hits"
  end

  def test_carried_starts_zero_accumulates_and_drains
    c = creature
    assert_equal 0, c.carried
    c.pick_up(2)
    c.pick_up(1)
    assert_equal 3, c.carried
    assert_equal 3, c.drain_carried!
    assert_equal 0, c.carried
  end

  def test_revive_zeroes_carried
    c = creature
    c.pick_up(5)
    c.revive!(map: MAP, tile: [3, 2])
    assert_equal 0, c.carried, "a revived body starts empty-handed"
  end

  # --- A2: Threat state ---

  def test_home_tile_is_stamped_at_construction
    c = creature(tile: [5, 2], faction: :human)
    c.step(1, 0, blocked: [])
    60.times { c.tick_body }
    assert_equal [5, 2], c.home_tile
  end

  def test_leash_counter_ticks_and_resets
    c = creature(faction: :human)
    3.times { c.tick_leash }
    assert_equal 3, c.leash_frames
    c.reset_leash!
    assert_equal 0, c.leash_frames
  end

  def test_landed_pack_hit_waives_beachhead
    h = creature(faction: :human)
    p = creature(faction: :pack, tile: [4, 2])
    refute h.beachhead_waived?
    h.take_hit(damage: 1, attacker: p)
    assert h.beachhead_waived?
  end

  def test_taunt_waives_beachhead
    h = creature(faction: :human)
    p = creature(faction: :pack, tile: [4, 2])
    h.taunt!(p, 300)
    assert h.beachhead_waived?
  end
end
