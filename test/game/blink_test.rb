require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/state_digest"

# MUNDO VIVO FASE 4.3 — `blink`: a short teleport to the target's far
# flank when the kind is far and off cooldown (serpent_c, the tower's
# tier-4 hunter). Boot+combat proof on a real World; the cooldown is
# digested (sim state), the flash is presentation only.
class BlinkTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  KIT = DATA["balance/combat"][:kits][:serpent_c]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def stage!(w = world, dist: 6)
    w.start_in("grass_fixture")
    body = w.possessed
    (w.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    body.walker.teleport(8, 6)
    w.send(:add_human, "grass_fixture", :serpent_c, [8 + dist, 6])
  end

  def test_kit_shape
    assert KIT[:blink], "serpent_c carries the blink block"
    assert_operator KIT[:blink][:min_tiles], :>=, 3, "blink is a GAP closer, never a melee reposition"
    assert_operator KIT[:blink][:cooldown_frames], :>=, 120, "one blink per engagement beat, not a strobe"
    xp = DATA["balance/progression"][:kill_xp]
    assert xp[:serpent_b] < xp[:serpent_c] && xp[:serpent_c] < xp[:warden]
  end

  def test_a_far_hunter_blinks_behind_its_target_and_faces_it
    hunter = stage!(dist: 6)
    body = world.possessed
    blinks = []
    world.bus.subscribe(:blinked) { |e| blinks << e }
    drive(world, scripted({}), 3)
    assert_equal 1, blinks.length, "off cooldown + far = blink on the first engage tick"
    assert blinks.first[:attacker].equal?(hunter)
    # "behind" = the far side of the body relative to the hunter's approach
    # (hunter came from +x, so it lands at body.x - 1)
    assert_equal [body.tile[0] - 1, body.tile[1]], hunter.tile, "lands on the flank BEHIND the target"
    assert_equal [1, 0], hunter.facing, "faces the target after the jump"
    assert_operator hunter.blink_cooldown, :>, 0
    assert hunter.blink_flash?, "arrival flash armed for the renderer"
  end

  def test_no_blink_inside_min_tiles_and_none_while_on_cooldown
    hunter = stage!(dist: 2)
    blinks = []
    world.bus.subscribe(:blinked) { |e| blinks << e }
    drive(world, scripted({}), 20)
    assert_empty blinks, "close range: the hunter walks/strikes, never blinks"
    # far again with cooldown armed → still no second blink
    hunter.walker.teleport(20, 6)
    hunter.instance_variable_set(:@blink_cooldown, 100)
    drive(world, scripted({}), 5)
    assert_empty blinks, "cooldown gates the verb"
  end

  def test_blink_is_deterministic_and_digested
    stage!(dist: 6)
    drive(world, scripted({}), 12)
    a = Net::StateDigest.canonical(world.digest_snapshot)
    w2 = Game::World.new(DATA)
    stage!(w2, dist: 6)
    drive(w2, scripted({}), 12)
    assert_equal a, Net::StateDigest.canonical(w2.digest_snapshot)
    assert(world.digest_snapshot.to_s.include?("blink_cooldown"), "the cooldown rides the digest (sim truth)")
  end
end
