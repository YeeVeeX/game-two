require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v20 T7: the stinger — the game's first RANGED hostile. The controller
# path is faction-agnostic and data-driven (engage -> projectile? ->
# in_attack_range?/retreat_step read kit[:attack][:arc]), but NO hostile
# kind ever rode it before this ticket: these tests are the engine proof
# the floor -3 fauna stands on (spark: prove the path before relying on
# it). Real World + real data, no mocks; the threat-free fixture zone
# (grass_fixture: open room, zero authored spawns) is the clean range.
class StingerTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  # One stinger on a clear aligned row, dist 4 (inside aggro 8, inside
  # range [2,5]): it must acquire, telegraph, and FIRE — projectile_fired
  # from a hostile attacker, and the shot must land on the pack body.
  def stage!(dist: 4)
    world.start_in("grass_fixture")
    body = world.possessed
    (world.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    body.walker.teleport(6, 6)
    world.send(:add_human, "grass_fixture", :stinger, [6 + dist, 6])
  end

  def test_a_hostile_projectile_kind_fires_and_the_shot_lands
    stinger = stage!(dist: 4)
    fired = []
    world.bus.subscribe(:projectile_fired) { |e| fired << e }
    body = world.possessed
    hp_before = body.hp
    windup = DATA["balance/combat"][:kits][:stinger][:attack][:windup_frames]
    drive(world, scripted({}), windup + 10)
    assert_equal 1, fired.length, "the stinger opens fire through the generic engage path"
    assert fired.first[:attacker].equal?(stinger), "the shot belongs to the HOSTILE attacker"
    # flight: 4 tiles at projectile_frames_per_tile — drive past arrival
    drive(world, scripted({}), 4 * DATA["balance/combat"][:kits][:stinger][:attack][:projectile_frames_per_tile] + 5)
    assert_operator body.hp, :<, hp_before,
                    "the hostile shot damages the pack victim (one combat law for all sources)"
  end

  def test_a_hugged_stinger_retreats_to_reopen_range
    stinger = stage!(dist: 1)
    drive(world, scripted({}), 30)
    dist = [(stinger.tile[0] - world.possessed.tile[0]).abs,
            (stinger.tile[1] - world.possessed.tile[1]).abs].max
    assert_operator dist, :>=, 2,
                    "adjacency is inert for a projectile kit - retreat_step must reopen range (got #{dist})"
  end

  def test_melee_interrupts_the_sting
    stinger = stage!(dist: 2)
    drive(world, scripted({}), 6)
    assert_equal :windup, stinger.attack_state, "the sting is charging (windup 22 is readable)"
    stinger.take_hit(damage: 5, attacker: world.possessed)
    assert_equal :idle, stinger.attack_state,
                 "interrupt_on_hit: reaching the stinger cancels the sting (hit-and-run contract)"
  end
end
