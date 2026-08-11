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

    # margin = 3. Need: d(focus) - d(steal) >= 3.
    # rusher at [5,3], focus(striker) at [11,3] (d=6), steal(lobber) at [8,3] (d=3).
    # diff = 6-3 = 3 >= margin => steal fires.
    striker_m.walker.teleport(11, 3)  # d=6 from rusher
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
end
