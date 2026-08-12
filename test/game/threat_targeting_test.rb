require_relative "../test_helper"
require "core/data_store"
require "core/event_bus"
require "core/input"
require "core/tile_map"
require "game/world"

# A2 priority-targeting chain: taunt -> anchor -> kit-hate -> lowest-HP ->
# sticky focus (proximity-margin steal) -> nearest acquisition.
class ThreatTargetingTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  THREAT = DATA["balance/threat"]

  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["############", "#..........#", "#..........#", "#..........#",
            "#..........#", "#..........#", "#..........#", "############"],
    pack_spawn: [[1, 1], [2, 1], [3, 1]]
  )

  def load_data = DATA

  # --- kit-parity pin ----------------------------------------------------------

  def test_hater_kit_is_rusher_plus_hate_field_only
    kits = load_data["balance/combat"][:kits]
    assert_equal "lobber", kits[:rusher_hater][:hate]
    assert_equal kits[:rusher], kits[:rusher_hater].reject { |k, _| k == :hate }
  end

  # --- world + AI helpers ------------------------------------------------------

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, n, input: scripted({}))
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    step = DATA["balance/combat"][:kits][:striker][:step_frames]
    drive(world, step * 30, input: scripted((0..step * 30 - 1).to_h { |f| [f.to_s, ["right"]] }))
    assert_equal "district", world.zone_name
  end

  def possess_kit(world, kit_name)
    world.pack.members.length.times do
      return world.possessed if world.possessed.kit_name == kit_name
      world.pack.swap_next!
    end
    flunk "could not possess #{kit_name}"
  end

  # Build a mini-world scenario: place specific creatures on fixed tiles for
  # deterministic chain assertions. Uses the real World (no mocks).
  def setup
    @world = Game::World.new(DATA)
    enter_district(@world)
    @ai = Game::AiController.new
  end

  # --- helpers for test scenarios ---

  def make_human(world, kit_name, tile)
    kit = DATA["balance/combat"][:kits].fetch(kit_name.to_sym)
    Game::Creature.new(bus: world.bus, kit: kit, kit_name: kit_name.to_sym,
                       map: world.map, tile: tile, faction: :human, name: "test_#{kit_name}")
  end

  # --- first-seen stickiness ---------------------------------------------------

  def test_first_seen_focus_is_sticky_within_margin
    # Place a rusher (human) and two pack targets
    rusher = make_human(@world, :rusher, [5, 3])
    striker = make_human(@world, :striker, [5, 3]) # dummy for type; we'll use pack members
    # Actually: use real pack members as targets (humans target pack).
    # Rethink: rusher is :human, targets are :pack members.
    # Place rusher near pack members; assign a focus (striker at d=4, lobber at d=3).
    # The rusher acquires striker first. Then lobber gets closer but within margin.

    # Simpler: place the rusher at [5,3], striker(pack) at [9,3] (d=4), lobber(pack) at [8,3] (d=3)
    # margin = 3. diff = 4-3 = 1 < 3 => sticky holds.
    world = @world
    world.humans.clear
    rusher = make_human(world, :rusher, [5, 3])
    world.humans << rusher

    # Park pack members at known tiles
    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }

    striker_m.walker.teleport(9, 3)  # d=4 from rusher
    lobber_m.walker.teleport(8, 3)   # d=3 from rusher (nearer by 1 < margin 3)
    blocker_m.walker.teleport(1, 6)  # far away, irrelevant

    # First call: no focus, so acquired target = nearest = lobber (d=3)
    # Wait — we want to test stickiness: the rusher already HAS a focus.
    # Assign focus to striker first (simulating prior acquisition).
    rusher.focus = striker_m

    target, cause = @ai.select_target(rusher, world)
    assert_equal striker_m, target, "focus holds when rival is closer by less than margin"
    assert_equal :sticky, cause
  end

  def test_proximity_steal_fires_at_the_margin
    world = @world
    world.humans.clear
    rusher = make_human(world, :rusher, [5, 3])
    world.humans << rusher

    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }

    # margin = 4. Need: d(focus) - d(steal) >= 4.
    # rusher at [5,3], focus(striker) at [12,3] (d=7), steal(lobber) at [8,3] (d=3).
    # diff = 7-3 = 4 >= margin => steal fires.
    striker_m.walker.teleport(12, 3)  # d=7 from rusher
    lobber_m.walker.teleport(8, 3)    # d=3 from rusher
    blocker_m.walker.teleport(1, 6)   # irrelevant

    rusher.focus = striker_m

    target, cause = @ai.select_target(rusher, world)
    assert_equal lobber_m, target, "proximity steal fires when difference >= margin"
    assert_equal :proximity, cause
  end

  # --- lowhp override ----------------------------------------------------------

  def test_lowhp_override_targets_the_wounded_body
    world = @world
    world.humans.clear
    rusher = make_human(world, :rusher, [5, 3])
    world.humans << rusher

    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }

    striker_m.walker.teleport(8, 3)   # d=3
    lobber_m.walker.teleport(7, 3)    # d=2 (nearer, would normally be picked)
    blocker_m.walker.teleport(1, 6)   # irrelevant

    # Wound striker below 35% HP threshold
    threshold_hp = (striker_m.max_hp * THREAT[:lowhp_switch_pct]).floor
    damage = striker_m.hp - threshold_hp + 1
    striker_m.take_hit(damage: damage, attacker: rusher, knockback_tiles: 0, blocked: [])

    assert striker_m.hp < striker_m.max_hp * THREAT[:lowhp_switch_pct],
           "striker must be below lowhp threshold"

    target, cause = @ai.select_target(rusher, world)
    assert_equal striker_m, target, "lowhp overrides normal proximity"
    assert_equal :lowhp, cause
  end

  # --- kit hate -----------------------------------------------------------------

  def test_hater_beelines_the_lobber_inside_aggro
    world = @world
    world.humans.clear
    hater = make_human(world, :rusher_hater, [5, 3])
    world.humans << hater

    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }

    # lobber further but hated; striker nearer
    striker_m.walker.teleport(7, 3)   # d=2 (nearer)
    lobber_m.walker.teleport(9, 3)    # d=4 (further but hated)
    blocker_m.walker.teleport(1, 6)   # irrelevant

    target, cause = @ai.select_target(hater, world)
    assert_equal lobber_m, target, "hater targets the hated kit regardless of distance"
    assert_equal :hate, cause
  end

  # --- taunt outranks everything -----------------------------------------------

  def test_taunt_outranks_everything
    world = @world
    world.humans.clear
    hater = make_human(world, :rusher_hater, [5, 3])
    world.humans << hater

    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }

    striker_m.walker.teleport(7, 3)
    lobber_m.walker.teleport(9, 3)
    blocker_m.walker.teleport(6, 3)

    hater.taunt!(blocker_m, 300)

    target, cause = @ai.select_target(hater, world)
    assert_equal blocker_m, target, "taunt outranks everything including hate"
    assert_equal :taunt, cause
  end

  # --- retarget event -----------------------------------------------------------

  def test_retarget_event_fires_on_change_with_cause
    world = @world
    world.humans.clear
    rusher = make_human(world, :rusher, [5, 3])
    world.humans << rusher

    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }

    striker_m.walker.teleport(8, 3)
    lobber_m.walker.teleport(7, 3)
    blocker_m.walker.teleport(1, 6)

    # Wound striker to force a lowhp switch
    threshold_hp = (striker_m.max_hp * THREAT[:lowhp_switch_pct]).floor
    damage = striker_m.hp - threshold_hp + 1
    striker_m.take_hit(damage: damage, attacker: rusher, knockback_tiles: 0, blocked: [])

    # Give the rusher a current focus on lobber (the nearest)
    rusher.focus = lobber_m

    events = []
    world.bus.subscribe(:human_retargeted) { |e| events << e }

    # Tick the world — assign_human_focus should fire the retarget event
    # because lowhp(striker) != current focus(lobber)
    input = scripted({})
    input.update(world.frame)
    world.tick(input)

    assert events.any?, "retarget event must fire when focus changes"
    assert_equal :lowhp, events.last[:cause]
    assert_equal striker_m, events.last[:to]
    assert_equal lobber_m, events.last[:from]
    assert_equal rusher, events.last[:actor]
  end

  # --- acquisition (no prior focus) --------------------------------------------

  def test_acquisition_targets_nearest_when_no_focus
    world = @world
    world.humans.clear
    rusher = make_human(world, :rusher, [5, 3])
    world.humans << rusher

    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }

    striker_m.walker.teleport(9, 3)   # d=4
    lobber_m.walker.teleport(7, 3)    # d=2 (nearest)
    blocker_m.walker.teleport(1, 6)   # far

    rusher.focus = nil

    target, cause = @ai.select_target(rusher, world)
    assert_equal lobber_m, target, "with no focus, acquires nearest"
    assert_equal :acquired, cause
  end

  # --- beachhead (A2): acquisition shield + waiver ----------------------------

  def test_unwaived_humans_cannot_acquire_a_target_on_the_doormat
    world = @world
    world.humans.clear
    # Arrival for district is [1,13]; beachhead_tiles = 4.
    # Place a pack member at [2,13] (Chebyshev d=1 from arrival — inside beachhead).
    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }

    striker_m.walker.teleport(2, 13)   # inside beachhead (d=1 from [1,13])
    blocker_m.walker.teleport(40, 1)   # far outside aggro range
    lobber_m.walker.teleport(41, 1)    # far outside aggro range

    # Rusher within aggro range of striker but unwaived
    rusher = make_human(world, :rusher, [3, 13])
    world.humans << rusher

    target, = @ai.select_target(rusher, world)
    assert_nil target, "unwaived human cannot acquire a target on the doormat"
  end

  def test_attacking_from_the_doormat_waives_that_human_only
    world = @world
    world.humans.clear
    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }

    striker_m.walker.teleport(2, 13)   # inside beachhead
    blocker_m.walker.teleport(40, 1)   # far outside aggro range
    lobber_m.walker.teleport(41, 1)    # far outside aggro range

    rusher = make_human(world, :rusher, [3, 13])
    other_rusher = make_human(world, :rusher, [4, 13])
    world.humans << rusher
    world.humans << other_rusher

    # Pack hits rusher => waiver fires for rusher only
    rusher.take_hit(damage: 1, attacker: striker_m, knockback_tiles: 0, blocked: [])

    target, = @ai.select_target(rusher, world)
    assert_equal striker_m, target, "waived human can acquire doormat target"

    other_target, = @ai.select_target(other_rusher, world)
    assert_nil other_target, "other human is still shielded"
  end

  def test_taunt_binds_through_the_beachhead
    world = @world
    world.humans.clear
    striker_m = world.pack.members.find { |m| m.kit_name == :striker }
    blocker_m = world.pack.members.find { |m| m.kit_name == :blocker }
    lobber_m = world.pack.members.find { |m| m.kit_name == :lobber }

    blocker_m.walker.teleport(2, 13)   # inside beachhead
    striker_m.walker.teleport(40, 1)   # far outside aggro range
    lobber_m.walker.teleport(41, 1)    # far outside aggro range

    rusher = make_human(world, :rusher, [3, 13])
    world.humans << rusher

    # Taunt binds even though the target is inside the beachhead
    # (taunt is checked BEFORE the reject line in the chain)
    rusher.taunt!(blocker_m, 300)

    target, cause = @ai.select_target(rusher, world)
    assert_equal blocker_m, target, "taunt binds through the beachhead"
    assert_equal :taunt, cause
  end

  # --- Q6 rider: retarget cue (why-they-turned) --------------------------------

  def test_retarget_stamps_cause_cue_and_acquired_does_not
    h = @world.humans.reject(&:dead?).find { |x| x.kit_name == :rusher }
    # Clear h's focus so the first drive is a clean acquisition.
    h.focus = nil
    # Ensure at least 2 living pack members for the lowhp switch.
    assert @world.pack.living.length >= 2, "need >= 2 living pack members"
    # Park the pack inside h's aggro, deep in the district (away from the
    # beachhead). First acquisition = nearest = living.first (:acquired).
    @world.pack.living.each_with_index do |m, i|
      m.walker.teleport(h.tile[0] - 2, h.tile[1] + i)
    end
    drive(@world, 1)
    assert_nil h.retarget_cue, "first sight is :acquired — no cue"
    # Wound a NON-focused body below the lowhp threshold -> :lowhp switch.
    wounded = @world.pack.living.reject { |m| m.equal?(h.focus) }.first
    refute_nil wounded, "need a living non-focused body to wound"
    dmg = (wounded.max_hp * (1 - THREAT[:lowhp_switch_pct])).to_i + 1
    wounded.take_hit(damage: dmg, attacker: h)
    drive(@world, 1)
    refute_nil h.retarget_cue
    assert_equal :lowhp, h.retarget_cue[:cause]
    assert h.retarget_cue[:frames_left].positive?
  end

  def test_retarget_cue_expires_by_ticking
    h = @world.humans.reject(&:dead?).first
    h.retarget_cue!(:lowhp, 5)
    assert_equal :lowhp, h.retarget_cue[:cause]
    drive(@world, 6)
    assert_nil h.retarget_cue
  end
end
