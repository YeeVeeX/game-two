require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/state_digest"

# MUNDO VIVO FASE 4.6 — `aura`: a field around a living bearer that burns
# every hostile inside radius_tiles every period_frames (ember_b, BRASA).
# Field damage = Creature#burn! (bypasses i-frames/knockback like poison;
# death via actor_died with the bearer as killer). Cadence = world.frame %
# period → nothing new in the digest; deterministic by construction.
class AuraTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  KIT = DATA["balance/combat"][:kits][:ember_b]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def stage!(w = world, dist: 2)
    w.start_in("grass_fixture")
    body = w.possessed
    (w.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    body.walker.teleport(7, 6)
    w.send(:add_human, "grass_fixture", :ember_b, [7 + dist, 6])
  end

  def test_kit_shape_and_family_gradient
    a = KIT[:aura]
    assert a && a[:radius_tiles] >= 1 && a[:period_frames] >= 10
    xp = DATA["balance/progression"][:kill_xp]
    assert xp[:ember_a] < xp[:ember_b] && xp[:ember_b] < xp[:ember_d] && xp[:ember_d] < xp[:ember_boss], "L6 inside BRASA"
  end

  def test_a_body_inside_the_radius_burns_on_the_cadence_and_outside_does_not
    bearer = stage!(dist: 2) # inside radius 2
    body = world.possessed
    burns = []
    world.bus.subscribe(:aura_burn) { |e| burns << e }
    hp0 = body.hp
    drive(world, scripted({}), KIT[:aura][:period_frames] * 2 + 1)
    assert_operator burns.count { |e| e[:victim].equal?(body) }, :>=, 1, "the field ticked at least once inside the window"
    assert_operator body.hp, :<, hp0, "the body burned"
    assert burns.all? { |e| e[:attacker].equal?(bearer) }
    # far body: no burn
    w2 = Game::World.new(DATA)
    stage!(w2, dist: 5)
    burns2 = []
    w2.bus.subscribe(:aura_burn) { |e| burns2 << e }
    drive(w2, scripted({}), KIT[:aura][:period_frames] * 2 + 1)
    assert_empty burns2.select { |e| e[:victim].equal?(w2.possessed) }, "outside the radius nothing burns"
  end

  def test_burn_bypasses_iframes_and_death_names_the_bearer
    bearer = stage!(dist: 1)
    body = world.possessed
    body.load_hp!(2)
    body.instance_variable_set(:@iframes, 30) # i-frames up: a HIT would be refused
    died = []
    world.bus.subscribe(:actor_died) { |e| died << e }
    drive(world, scripted({}), KIT[:aura][:period_frames] + 1)
    ev = died.find { |e| e[:actor].equal?(body) }
    refute_nil ev, "the field burned through i-frames (it is not a hit)"
    assert ev[:killer].equal?(bearer), "killer = the bearer (xp/drops attribution law)"
  end

  def test_aura_is_deterministic_with_no_new_digest_fields
    stage!(dist: 2)
    drive(world, scripted({}), 45)
    a = Net::StateDigest.canonical(world.digest_snapshot)
    w2 = Game::World.new(DATA)
    stage!(w2, dist: 2)
    drive(w2, scripted({}), 45)
    assert_equal a, Net::StateDigest.canonical(w2.digest_snapshot)
    refute world.digest_snapshot.to_s.include?("aura"), "cadence rides world.frame — no aura clock in the digest"
  end
end
