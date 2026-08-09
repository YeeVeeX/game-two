require_relative "../test_helper"
require "core/event_bus"
require "core/tile_map"
require "game/creature"

class CreatureTest < Minitest::Test
  # player_spawn is the pre-Task-8 schema; Task 8 migrates this fixture to
  # pack_spawn: [[1, 1], [2, 1], [3, 1]] with the TileMap change.
  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["##########", "#........#", "#........#", "#........#", "##########"],
    player_spawn: [1, 1]
  )

  KIT = {
    max_hp: 100, step_frames: 15, aggro_tiles: 8,
    attack: { damage: 25, windup_frames: 6, active_frames: 4, recovery_frames: 10,
              exhaust_frames: 45, arc: "arc3", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    dodge: { tiles: 2, frames_per_tile: 7, iframes: 18, cooldown_frames: 50 },
    knockback_tiles_received: 1, knockback_frames_per_tile: 5
  }.freeze

  RING_KIT = {
    max_hp: 60, step_frames: 17, aggro_tiles: 12,
    attack: { damage: 15, windup_frames: 30, active_frames: 6, recovery_frames: 0,
              exhaust_frames: 81, arc: "ring", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    knockback_tiles_received: 1, knockback_frames_per_tile: 5
  }.freeze

  EVENTS = %i[attack_started attack_hit damage_dealt actor_died dodged].freeze

  def bus = @bus ||= Core::EventBus.new.register(*EVENTS)

  def creature(kit: KIT, tile: [3, 2], faction: :pack)
    Game::Creature.new(bus:, kit:, kit_name: :prowler, map: MAP, tile:, faction:, name: "c1")
  end

  def test_exhaust_gates_attack_cadence
    c = creature
    assert c.start_attack, "first swing starts"
    refute c.start_attack, "second swing refused while exhausted"
    44.times { c.tick_body }
    refute c.exhaust_ready?, "still exhausted at 44f"
    c.tick_body
    assert c.exhaust_ready?, "exhaust clears at 45f"
    assert c.start_attack, "swing available again at exhaust pace"
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
    assert_equal [[4, 2], [4, 3], [4, 1]], c.attack_tiles, "cardinal facing: front + diagonals"
    r = creature(kit: RING_KIT, tile: [3, 2])
    assert_equal 8, r.attack_tiles.length, "ring hits all Chebyshev neighbors"
    assert_includes r.attack_tiles, [2, 1]
    refute_includes r.attack_tiles, [3, 2], "ring excludes own tile"
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
end
