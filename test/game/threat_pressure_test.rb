require_relative "../test_helper"
require "core/data_store"
require "core/event_bus"
require "core/input"
require "core/tile_map"
require "game/world"

# A2 engaged cap + pressuring ring: humans sharing a focus target are
# partitioned each tick -- the nearest N fight (engaged), the rest follow,
# body-block, and NEVER swing (pressuring). Deterministic by construction:
# partition sorting is (tile_distance, roster index).
class ThreatPressureTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  THREAT = DATA["balance/threat"]

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

  def make_human(world, kit_name, tile)
    kit = DATA["balance/combat"][:kits].fetch(kit_name.to_sym)
    Game::Creature.new(bus: world.bus, kit: kit, kit_name: kit_name.to_sym,
                       map: world.map, tile: tile, faction: :human, name: "test_#{kit_name}_#{tile}")
  end

  # --- cap + determinism -------------------------------------------------------

  def test_partition_caps_engaged_at_the_data_value_and_is_deterministic
    # 7 rushers all focused on the blocker; cap 5: nearest 5 engaged,
    # 2 pressuring, ties broken by roster order -- assert exact membership twice
    # (two fresh worlds, same seed) for determinism.
    cap = THREAT[:engaged_cap_per_target]
    assert_equal 5, cap, "test assumes cap = 5"

    results = 2.times.map do
      w = Game::World.new(DATA, seed: 42)
      enter_district(w)
      w.humans.clear

      target = w.pack.members.find { |m| m.kit_name == :blocker }
      target.walker.teleport(5, 3)

      # Park other pack members far away so they don't interfere
      w.pack.members.reject { |m| m.equal?(target) }.each_with_index do |m, i|
        m.walker.teleport(1, 1 + i)
      end

      rushers = 7.times.map { |i| make_human(w, :rusher, [5 + i + 1, 3]) }
      rushers.each { |r| w.humans << r }

      # Assign focus manually (mimics assign_human_focus)
      rushers.each { |r| r.focus = target }

      # Drive one tick to run partition_pressure
      drive(w, 1)

      engaged = rushers.select { |r| w.pressure_role(r) == :engaged }
      pressuring = rushers.select { |r| w.pressure_role(r) == :pressuring }
      [engaged.map(&:tile), pressuring.map(&:tile)]
    end

    # Cap enforced
    assert_equal cap, results[0][0].length, "exactly cap humans are engaged"
    assert_equal 2, results[0][1].length, "the rest are pressuring"

    # Determinism: both runs produce identical membership
    assert_equal results[0][0], results[1][0], "engaged set is deterministic across worlds"
    assert_equal results[0][1], results[1][1], "pressuring set is deterministic across worlds"
  end

  # --- pressuring humans never swing -------------------------------------------

  def test_pressuring_humans_never_start_attacks
    # Force a pressuring human adjacent to its target for 120 ticks:
    # attack_started never fires from it.
    w = Game::World.new(DATA, seed: 7)
    enter_district(w)
    w.humans.clear

    # Possess the blocker so it stays stationary (no AI, no input) — stable
    # distances keep the partition deterministic across 120 ticks.
    target = w.pack.members.find { |m| m.kit_name == :blocker }
    w.pack.members.length.times { break if w.possessed.equal?(target); w.pack.swap_next! }
    target.walker.teleport(5, 3)
    # Park allies FAR from the action so they never aggro humans (d>10)
    w.pack.members.reject { |m| m.equal?(target) }.each_with_index do |m, i|
      m.walker.teleport(40, 1 + i)
    end

    cap = THREAT[:engaged_cap_per_target]
    # Fill engaged slots: all at d=1 (adjacent) so they stay engaged
    adjacent_tiles = [[4, 2], [5, 2], [6, 2], [4, 3], [6, 3]]
    engaged_rushers = adjacent_tiles.first(cap).map { |t| make_human(w, :rusher, t) }
    engaged_rushers.each { |r| w.humans << r }

    # The pressuring rusher: also d=1 from target but roster index > cap => pressuring
    pressurer = make_human(w, :rusher, [5, 4])
    w.humans << pressurer

    attack_sources = []
    w.bus.subscribe(:attack_started) { |e| attack_sources << e[:attacker] }

    # Drive 120 ticks
    drive(w, 120)

    refute attack_sources.include?(pressurer),
           "a pressuring human must NEVER start an attack"
    # Sanity: at least one engaged human DID attack
    assert attack_sources.any? { |a| engaged_rushers.include?(a) },
           "at least one engaged human attacked (sanity)"
  end

  # --- ring distance -----------------------------------------------------------

  def test_pressuring_humans_hold_ring_distance
    # After 300 ticks, every pressuring human sits at pressure_ring_tiles
    # (Chebyshev) from the target, or is still moving toward a free ring tile.
    w = Game::World.new(DATA, seed: 99)
    enter_district(w)
    w.humans.clear

    target = w.pack.members.find { |m| m.kit_name == :blocker }
    target.walker.teleport(5, 3)
    w.pack.members.reject { |m| m.equal?(target) }.each_with_index do |m, i|
      m.walker.teleport(1, 1 + i)
    end

    cap = THREAT[:engaged_cap_per_target]
    ring_r = THREAT[:pressure_ring_tiles]

    # Fill engaged slots: all at d=1 so they remain engaged
    adjacent_tiles = [[4, 2], [5, 2], [6, 2], [4, 3], [6, 3]]
    engaged_rushers = adjacent_tiles.first(cap).map { |t| make_human(w, :rusher, t) }
    engaged_rushers.each { |r| w.humans << r }

    # 3 pressuring rushers start at d=3-4 (close enough to reach ring in 300 ticks)
    pressurers = 3.times.map { |i| make_human(w, :rusher, [8, 2 + i]) }
    pressurers.each { |r| w.humans << r }

    drive(w, 300)

    pressurers.reject(&:dead?).each do |p|
      d = chebyshev(p.tile, target.tile)
      on_ring = (d == ring_r)
      still_moving = p.moving?
      assert on_ring || still_moving,
             "pressuring human at #{p.tile} is d=#{d} from target (want #{ring_r} or moving)"
    end
  end

  # --- promotion on death ------------------------------------------------------

  def test_engaged_slot_refills_when_an_engaged_human_dies
    # Kill one engaged human; next tick a pressuring one is promoted.
    w = Game::World.new(DATA, seed: 13)
    enter_district(w)
    w.humans.clear

    target = w.pack.members.find { |m| m.kit_name == :blocker }
    target.walker.teleport(5, 3)
    w.pack.members.reject { |m| m.equal?(target) }.each_with_index do |m, i|
      m.walker.teleport(1, 1 + i)
    end

    cap = THREAT[:engaged_cap_per_target]

    # cap+1 rushers so exactly 1 is pressuring
    rushers = (cap + 1).times.map { |i| make_human(w, :rusher, [4 + i, 2]) }
    rushers.each { |r| w.humans << r }

    # Run a tick to partition
    drive(w, 1)

    pressuring_before = rushers.select { |r| w.pressure_role(r) == :pressuring }
    assert_equal 1, pressuring_before.length, "exactly 1 pressuring pre-kill"

    engaged_before = rushers.select { |r| w.pressure_role(r) == :engaged }
    # Kill one engaged human
    victim = engaged_before.first
    victim.take_hit(damage: victim.hp + 10, attacker: target, knockback_tiles: 0, blocked: [])
    assert victim.dead?, "victim must be dead"

    # Next tick: the pressuring one should be promoted
    drive(w, 1)

    living = rushers.reject(&:dead?)
    engaged_after = living.select { |r| w.pressure_role(r) == :engaged }
    pressuring_after = living.select { |r| w.pressure_role(r) == :pressuring }

    assert_equal [cap, living.length].min, engaged_after.length,
                 "after a death, engaged slots refill up to cap"
    assert_equal 0, pressuring_after.length,
                 "no pressuring humans remain when living <= cap"
  end

  private

  def chebyshev((ax, ay), (bx, by)) = [(bx - ax).abs, (by - ay).abs].max
end
