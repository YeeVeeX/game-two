require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/state_digest"

# MUNDO VIVO FASE 4.5 — `poison`: a damage-over-time rider on a landed hit
# (spore family, floor -3 MUSGO). Ticks bypass i-frames/knockback (not a
# hit) but death walks the actor_died door with the poisoner as killer, so
# drops/xp/corpse laws hold. Refreshes, never stacks. Boot+combat proof.
class PoisonTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  KITS = DATA["balance/combat"][:kits]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def stage!(kind, w = world)
    w.start_in("grass_fixture")
    body = w.possessed
    (w.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    body.walker.teleport(7, 6)
    w.send(:add_human, "grass_fixture", kind, [8, 6]) # adjacent melee
  end

  def test_kits_shape_and_family_gradient
    a = KITS[:spore_a][:attack][:poison]
    b = KITS[:spore_b][:attack][:poison]
    assert a && b
    assert_operator b[:ticks] * b[:dmg_per], :>, a[:ticks] * a[:dmg_per], "tier 2 poisons harder"
    xp = DATA["balance/progression"][:kill_xp]
    assert xp[:stinger] < xp[:spore_a] && xp[:spore_a] < xp[:spore_b] && xp[:spore_b] < xp[:challenger], "L6 inside MUSGO"
    # the floor -3 clear (14 spore_a + 9 spore_b + BOSS 1) out-pays floor -2 (1780)
    assert_operator 14 * xp[:spore_a] + 9 * xp[:spore_b] + xp[:challenger], :>, 1780
  end

  def test_a_landed_hit_poisons_and_the_dot_ticks_past_iframes
    spore = stage!(:spore_a)
    body = world.possessed
    poisoned = []
    world.bus.subscribe(:poisoned) { |e| poisoned << e }
    atk = KITS[:spore_a][:attack]
    drive(world, scripted({}), atk[:windup_frames] + atk[:active_frames] + 2)
    assert_equal 1, poisoned.length, "the landed hit applies poison"
    assert poisoned.first[:attacker].equal?(spore) && poisoned.first[:victim].equal?(body)
    assert body.poisoned?
    hp_after_hit = body.hp
    # tick 1 lands after interval_frames — while the hit's i-frames may still be up
    drive(world, scripted({}), atk[:poison][:interval_frames] + 1)
    assert_equal hp_after_hit - atk[:poison][:dmg_per], body.hp, "poison ticks bypass i-frames (not a hit)"
    # full course: ticks_left reaches 0, no more damage
    drive(world, scripted({}), atk[:poison][:interval_frames] * atk[:poison][:ticks] + 5)
    refute body.poisoned?, "the DOT expires after its ticks"
  end

  def test_reapplication_refreshes_and_never_stacks
    stage!(:spore_a)
    body = world.possessed
    body.poison!(ticks: 2, dmg_per: 4, interval_frames: 30, by: nil)
    body.poison!(ticks: 3, dmg_per: 4, interval_frames: 30, by: nil)
    assert_equal 3, body.poison_ticks, "max(ticks), not sum"
  end

  def test_poison_death_walks_the_actor_died_door_with_the_poisoner_as_killer
    spore = stage!(:spore_b)
    body = world.possessed
    died = []
    world.bus.subscribe(:actor_died) { |e| died << e }
    body.load_hp!(3) # one tick kills
    body.poison!(ticks: 4, dmg_per: 5, interval_frames: 10, by: spore)
    drive(world, scripted({}), 12)
    ev = died.find { |e| e[:actor].equal?(body) }
    assert ev, "the body died to the DOT"
    assert ev[:killer].equal?(spore), "killer = the poisoner (xp/drops attribution law)"
    refute body.poisoned?, "death clears the DOT"
  end

  def test_poison_is_digested_and_deterministic
    stage!(:spore_a)
    drive(world, scripted({}), 60)
    a = Net::StateDigest.canonical(world.digest_snapshot)
    w2 = Game::World.new(DATA)
    stage!(:spore_a, w2)
    drive(w2, scripted({}), 60)
    assert_equal a, Net::StateDigest.canonical(w2.digest_snapshot)
    assert world.digest_snapshot.to_s.include?("poison_ticks")
  end
end
