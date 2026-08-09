require_relative "../test_helper"
require "core/event_bus"
require "core/tile_map"
require "core/input"
require "game/creature"
require "game/pack"
require "game/controllers"

class PackTest < Minitest::Test
  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["############", "#..........#", "#..........#", "#..........#", "############"],
    pack_spawn: [[1, 1], [5, 1], [9, 1]]
  )
  KIT = {
    max_hp: 100, step_frames: 15, aggro_tiles: 8,
    attack: { damage: 25, windup_frames: 6, active_frames: 4, recovery_frames: 10,
              exhaust_frames: 45, arc: "arc3", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    dodge: { tiles: 2, frames_per_tile: 7, iframes: 18, cooldown_frames: 50 },
    knockback_frames_per_tile: 5
  }.freeze
  EVENTS = %i[attack_started attack_hit damage_dealt actor_died dodged].freeze

  def bus = @bus ||= Core::EventBus.new.register(*EVENTS)

  def member(tile, name)
    Game::Creature.new(bus:, kit: KIT, kit_name: :striker, map: MAP, tile:, faction: :pack, name:)
  end

  def pack
    @pack ||= Game::Pack.new(
      members: [member([1, 1], "a"), member([5, 1], "b"), member([9, 1], "c")],
      stagger_frames: 20
    )
  end

  def test_swap_cycles_living_members
    assert_equal "a", pack.possessed.name
    pack.swap_next!
    assert_equal "b", pack.possessed.name
    pack.swap_next!
    assert_equal "c", pack.possessed.name
    pack.swap_next!
    assert_equal "a", pack.possessed.name, "cycles back around"
  end

  def test_swap_skips_dead_members
    killer = member([2, 2], "k")
    4.times { pack.members[1].take_hit(damage: 25, attacker: killer) }
    pack.swap_next!
    assert_equal "c", pack.possessed.name, "dead b is skipped"
  end

  def test_voluntary_swap_has_no_stagger
    pack.swap_next!
    refute pack.possessed.staggered?
  end

  def test_forced_swap_picks_nearest_living_and_staggers
    killer = member([2, 2], "k")
    4.times { pack.possessed.take_hit(damage: 25, attacker: killer) } # kills a at [1,1]
    survivor = pack.forced_swap!
    assert_equal "b", survivor.name, "b at [5,1] is nearer to a than c at [9,1]"
    assert survivor.staggered?, "forced swap costs a stagger (law 2)"
  end

  def test_wipe_detection
    killer = member([2, 2], "k")
    refute pack.wipe?
    pack.members.each { |m| 4.times { m.take_hit(damage: 25, attacker: killer) } }
    assert pack.wipe?
    assert_nil pack.forced_swap!, "no survivor to swap to"
  end

  def test_possessed_controller_edge_trigger_masks_held_combat_keys
    input = Core::ScriptedInput.new(frames: { 0 => %i[attack right], 1 => %i[attack right], 2 => [], 3 => %i[attack] })
    ctl = Game::PossessedController.new
    c = pack.possessed
    input.update(0)
    ctl.rearm!(input)              # swap happened while attack+right held
    ctl.tick(c, input, nil)
    assert_equal :idle, c.attack_state, "held attack masked after swap"
    assert_equal [2, 1], c.tile, "held movement SURVIVES a swap (M2.1 fix 3)"
    input.update(1)
    ctl.tick(c, input, nil)
    assert_equal :idle, c.attack_state, "still masked while still held"
    input.update(2)
    ctl.tick(c, input, nil)        # released this frame -> unmask
    input.update(3)
    ctl.tick(c, input, nil)        # re-pressed -> fires
    assert_equal :windup, c.attack_state, "re-press after release fires (edge-trigger, law 2)"
  end

  def test_held_dodge_masked_after_swap
    input = Core::ScriptedInput.new(frames: { 0 => %i[dodge right] })
    ctl = Game::PossessedController.new
    c = pack.possessed
    input.update(0)
    ctl.rearm!(input)              # swap happened while dodge held
    ctl.tick(c, input, nil)
    assert_equal [2, 1], c.tile, "held dodge masked -> falls through to a normal step"
  end
end
