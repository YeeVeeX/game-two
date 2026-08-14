require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v13 guard-scope lane (fairness only): a leashing wanderer whose HOME sits
# inside the corpse-guard radius of the newest live corpse load re-homes to
# a shifted tile outside the radius — live humans can no longer camp the
# corpse run. Engaged humans never read this path (leash runs no-focus
# only); difficulty stays pinned. Spec §4 (redesigned at the Codex fold:
# per-tick steering oscillates against leash_home; the DESTINATION shifts).
class GuardScopeTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  GUARD = DATA["balance/threat"][:density][:corpse_guard_tiles]
  LINGER = DATA["balance/threat"][:leash_linger_frames]
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    assert_equal "district", world.zone_name
  end

  def nearest_human(world)
    px, py = world.possessed.tile
    world.humans.reject(&:dead?).min_by { |h| [(h.tile[0] - px).abs, (h.tile[1] - py).abs].max }
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  def press_interact(world)
    drive(world, scripted({}), 1) while world.feel.hitstop?
    drive(world, scripted({ world.frame.to_s => ["interact"] }), 1)
    drive(world, scripted({}), 1)
  end

  # corpse_run_test idiom: drop under possessed -> pick up -> swap off ->
  # carrier killed by a human -> a live corpse load exists at the death tile.
  def stage_loaded_death(world)
    enter_district(world)
    world.drops.clear
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 1)
    tile = world.drops.first[:tile]
    world.possessed.walker.teleport(*tile)
    drive(world, scripted({}), 1)
    press_interact(world)
    carrier = world.possessed
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    refute_equal carrier, world.possessed
    kill(carrier, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    world.corpse_loads.last or flunk "staging failed: no corpse load"
  end

  def dist((ax, ay), (bx, by)) = [(bx - ax).abs, (by - ay).abs].max

  def test_leash_home_is_true_home_without_loads
    enter_district(world)
    assert_empty world.corpse_loads
    h = world.humans.reject(&:dead?).first
    assert_equal h.home_tile, world.leash_home_tile(h)
  end

  def test_home_inside_guard_shifts_outside_and_stays_walkable
    load = stage_loaded_death(world)
    h = world.humans.reject(&:dead?).find { |x| dist(load[:tile], x.home_tile) <= GUARD }
    flunk "no human homes inside the guard radius" unless h

    shifted = world.leash_home_tile(h)
    refute_equal h.home_tile, shifted, "camping home must shift"
    assert_operator dist(load[:tile], shifted), :>, GUARD, "outside the guard radius"
    assert world.map.passable?(shifted[0], shifted[1]), "shifted home is walkable"
    assert_operator dist(h.home_tile, shifted), :<=, GUARD * 2, "bounded relocation"
  end

  def test_home_outside_guard_never_shifts
    load = stage_loaded_death(world)
    h = world.humans.reject(&:dead?).find { |x| dist(load[:tile], x.home_tile) > GUARD }
    flunk "no human homes outside the guard radius" unless h
    assert_equal h.home_tile, world.leash_home_tile(h)
  end

  def test_leashed_wanderer_walks_to_the_shifted_home_and_stays
    load = stage_loaded_death(world)
    h = world.humans.reject(&:dead?).find { |x| dist(load[:tile], x.home_tile) <= GUARD }
    flunk "no human homes inside the guard radius" unless h
    world.humans.replace([h])
    # Park the pack out of aggro so the wanderer has no focus and leashes.
    world.pack.living.each_with_index { |m, i| m.walker.teleport(1, 1 + i) }

    shifted = world.leash_home_tile(h)
    drive(world, scripted({}), LINGER + STEP * 3 * (GUARD * 2 + 4))
    assert_equal shifted, h.tile, "the wanderer settled on the shifted home, off the corpse"
  end

  def test_human_leashed_event_carries_the_steered_flag
    load = stage_loaded_death(world)
    h = world.humans.reject(&:dead?).find { |x| dist(load[:tile], x.home_tile) <= GUARD }
    flunk "no human homes inside the guard radius" unless h
    world.humans.replace([h])
    world.pack.living.each_with_index { |m, i| m.walker.teleport(1, 1 + i) }

    events = []
    world.bus.subscribe(:human_leashed) { |e| events << e }
    drive(world, scripted({}), LINGER + 5)
    assert_equal 1, events.length, "one leash episode"
    assert events.first[:steered], "episode flagged steered (destination shifted)"
  end
end
