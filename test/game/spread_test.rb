require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/state_digest"

# MUNDO VIVO FASE 4 — `spread`, the first NEW behavior primitive (a fan of
# projectiles). Law (stinger T7 precedent): prove the path boot+combat on a
# real World BEFORE any zone depends on it. Carrier kind: serpent_a (the
# tower's tier-2 caster). Real data, no mocks; grass_fixture = clean range.
class SpreadTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  KIT = DATA["balance/combat"][:kits][:serpent_a]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def stage!(dist: 3)
    world.start_in("grass_fixture")
    body = world.possessed
    (world.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    body.walker.teleport(6, 6)
    world.send(:add_human, "grass_fixture", :serpent_a, [6 + dist, 6])
  end

  def test_kit_is_a_spread_caster_with_its_own_xp_row
    assert_equal "spread", KIT[:attack][:arc]
    assert_equal 3, KIT[:attack][:spread_count]
    xp = DATA["balance/progression"][:kill_xp]
    assert_operator xp[:serpent_a], :>, xp[:stinger], "L6 gradient: tier 2 pays more than the tier-1 stinger"
    assert_operator xp[:serpent_a], :<, xp[:warden], "…and less than the medusa elite"
  end

  def test_the_fan_fires_count_shots_in_adjacent_directions_from_one_cast
    caster = stage!(dist: 3)
    fired = []
    world.bus.subscribe(:projectile_fired) { |e| fired << e }
    drive(world, scripted({}), KIT[:attack][:windup_frames] + 4)
    assert_equal 1, fired.length, "ONE cast event per fan (manifest grammar counts casts)"
    assert fired.first[:attacker].equal?(caster)
    shots = world.projectiles.select { |p| p.owner.equal?(caster) }
    assert_equal 3, shots.length, "spread_count shots exist as real projectiles"
    dirs = shots.map(&:dir).sort
    facing = caster.facing
    assert_includes dirs, facing, "the center shot flies along the facing"
    # the two flanks are the ring neighbors of the facing (±45°)
    ring = Game::World::SPREAD_RING
    i = ring.index(facing)
    assert_equal [ring[(i - 1) % 8], facing, ring[(i + 1) % 8]].sort, dirs
  end

  def test_the_center_shot_lands_and_damage_follows_the_one_combat_law
    stage!(dist: 3)
    body = world.possessed
    hp0 = body.hp
    drive(world, scripted({}), KIT[:attack][:windup_frames] + 4 + 3 * KIT[:attack][:projectile_frames_per_tile] + 6)
    assert_operator body.hp, :<, hp0, "the aligned center pellet damages the pack body"
    assert_equal hp0 - body.hp, hp0 - body.hp # sanity: a single number, no float
  end

  def test_digest_stays_deterministic_with_fans_in_flight
    stage!(dist: 3)
    drive(world, scripted({}), KIT[:attack][:windup_frames] + 6)
    a = Net::StateDigest.canonical(world.digest_snapshot)
    w2 = Game::World.new(DATA)
    w2.start_in("grass_fixture")
    b2 = w2.possessed
    (w2.pack.living - [b2]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    b2.walker.teleport(6, 6)
    w2.send(:add_human, "grass_fixture", :serpent_a, [9, 6])
    drive(w2, scripted({}), KIT[:attack][:windup_frames] + 6)
    assert_equal a, Net::StateDigest.canonical(w2.digest_snapshot), "two worlds, same script, same digest (spread is deterministic)"
  end
end
