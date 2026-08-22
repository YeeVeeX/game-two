require_relative "../test_helper"
require "core/event_bus"
require "core/tile_map"
require "core/input"
require "game/creature"
require "game/pack"
require "game/progression"
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
    special: { damage: 30, windup_frames: 12, active_frames: 4, recovery_frames: 12,
               exhaust_frames: 600, arc: "ring", knockback_tiles: 2,
               stagger_frames: 45, interrupt_windup: true },
    dodge: { tiles: 2, frames_per_tile: 7, iframes: 18, cooldown_frames: 50 },
    knockback_frames_per_tile: 5
  }.freeze
  EVENTS = %i[attack_started special_started attack_hit damage_dealt actor_died dodged].freeze

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

  def test_mark_is_pack_owned_and_survives_possession_changes
    first = Object.new
    second = Object.new
    pack.mark!(first)
    pack.swap_next!
    assert_same first, pack.mark

    killer = member([2, 2], "k")
    4.times { pack.possessed.take_hit(damage: 25, attacker: killer) }
    pack.forced_swap!
    assert_same first, pack.mark

    pack.mark!(second)
    assert_same second, pack.mark
    pack.clear_mark!
    assert_nil pack.mark
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

  def test_special_is_rising_edge_and_masks_across_swap
    frames = (0..605).to_h { |frame| [frame, [:special]] }
    frames[606] = []
    frames[607] = [:special]
    input = Core::ScriptedInput.new(frames:)
    ctl = Game::PossessedController.new
    c = pack.possessed
    starts = 0
    bus.subscribe(:special_started) { starts += 1 }

    608.times do |frame|
      input.update(frame)
      ctl.tick(c, input, nil)
      c.tick_body
      bus.process
    end

    assert_equal 2, starts, "held key casts once; release/re-press casts again after recharge"

    fresh = pack.members[1]
    masked = Core::ScriptedInput.new(frames: { 0 => [:special], 1 => [], 2 => [:special] })
    masked.update(0)
    ctl.rearm!(masked)
    ctl.tick(fresh, masked, nil)
    assert_nil fresh.current_action, "held special cannot ghost-cast into a swapped body"
    masked.update(1)
    ctl.tick(fresh, masked, nil)
    masked.update(2)
    ctl.tick(fresh, masked, nil)
    assert_equal :special, fresh.current_action
  end

  def test_mark_input_is_safe_with_nil_controller_view
    input = Core::ScriptedInput.new(frames: { 0 => [:mark] })
    ctl = Game::PossessedController.new
    input.update(0)
    ctl.tick(pack.possessed, input, nil)
    assert_nil pack.possessed.current_action
  end

  # --- Tank-first initial possession ---

  def striker
    @striker ||= Game::Creature.new(bus:, kit: KIT, kit_name: :striker, map: MAP, tile: [1, 1], faction: :pack, name: "striker")
  end

  def blocker
    @blocker ||= Game::Creature.new(bus:, kit: KIT, kit_name: :blocker, map: MAP, tile: [5, 1], faction: :pack, name: "blocker")
  end

  def lobber
    @lobber ||= Game::Creature.new(bus:, kit: KIT, kit_name: :lobber, map: MAP, tile: [9, 1], faction: :pack, name: "lobber")
  end

  def test_initial_possession_honors_initial_kit_without_reordering_the_cycle
    pack = Game::Pack.new(members: [striker, blocker, lobber],
                          stagger_frames: 20, initial_kit: "blocker")
    assert_equal blocker, pack.possessed
    pack.swap_next!
    assert_equal lobber, pack.possessed, "cycle order still follows the members array"
  end

  # --- P4: shared pack-level max hp ---------------------------------------

  def test_sync_max_hp_handles_multi_level_growth_and_is_idempotent
    progression = Game::Progression.new(config: {
      curve: { k: 10, level_cap: 5 },
      growth: { dmg_growth_pct: 0, hp_growth_pct: 10 },
      kill_xp: { rusher: 1 }
    })
    progression.load_progress!(level: 4, xp: 0)

    pack.sync_max_hp!(progression:)
    once = pack.members.map { |member| [member.hp, member.max_hp] }
    pack.sync_max_hp!(progression:)

    assert_equal [[130, 130], [130, 130], [130, 130]], once
    assert_equal once, pack.members.map { |member| [member.hp, member.max_hp] },
                 "re-sync at the same level must be idempotent"
  end

  # --- D1b: spend! + possess! ---

  def test_spend_subtracts_when_affordable
    pack.bank!(10)
    assert pack.spend!(7)
    assert_equal 3, pack.banked
  end

  def test_spend_refuses_without_mutation_when_insufficient
    pack.bank!(5)
    refute pack.spend!(6)
    assert_equal 5, pack.banked, "refusal must not mutate"
  end

  def test_possess_moves_pointer_without_stagger
    target = pack.members[2]
    assert_equal target, pack.possess!(target)
    assert_equal target, pack.possessed
    refute target.staggered?, "judgment snap is not a combat swap"
  end
end
