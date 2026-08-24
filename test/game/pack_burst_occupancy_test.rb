require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# D2 pack-burst occupancy (s66, owner-picked scope — rides the volley
# law): PACK ring specials hit a foe still tweening off a ring tile
# (walker covers?); ENEMY ring attacks keep committed-tile equality —
# the extension is deliberately asymmetric (player-facing fairness vs
# the eye; enemy difficulty untouched). Real World, no mocks
# (whirlwind_test staging grammar).
class PackBurstOccupancyTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, n, input: scripted({}))
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    drive(world, STEP * 30, input: scripted(hold(:right, 0, STEP * 30 - 1)))
    assert_equal "district", world.zone_name
  end

  def possess_kit(world, kit_name)
    world.pack.members.length.times do
      return world.possessed if world.possessed.kit_name == kit_name
      world.pack.swap_next!
    end
    flunk "could not possess #{kit_name}"
  end

  def stage_striker_with_one_human(world, stagger_human: true)
    enter_district(world)
    striker = possess_kit(world, :striker)
    striker.interrupt_action!
    striker.walker.teleport(12, 12)
    (world.pack.living - [striker]).each_with_index do |member, i|
      member.walker.teleport(2, 12 + i)
    end
    human = world.humans.first
    flunk "district spawned no humans" if human.nil?
    world.humans.replace([human])
    human.heal_full!
    human.walker.teleport(13, 12) # on the ring
    human.stagger!(600) if stagger_human # frozen AI; direct walker drives only
    [striker, human]
  end

  # The kinetic case the owner reported: the body is mid-tween OFF the
  # ring tile (committed one tile out) when the whirl's active window
  # opens — visually inside the burst, logically gone. Pack ring counts
  # covers?: the hit lands.
  def test_pack_ring_special_hits_a_foe_mid_step_off_the_ring
    striker, human = stage_striker_with_one_human(world)
    windup = DATA["balance/combat"][:kits][:striker][:special][:windup_frames]
    hp_before = human.hp

    assert striker.start_special(blocked: [])
    drive(world, windup - 1) # one frame before the active window
    human.walker.step(1, 0, frames: 16) # departs [13,12] -> commits [14,12]
    assert_equal [14, 12], human.tile, "logically already off the ring"
    assert human.walker.moving?
    drive(world, 2) # windup completes; active resolves

    assert_operator human.hp, :<, hp_before,
                    "a body still tweening off the ring tile is IN the burst"
  end

  # The asymmetry pin: an ENEMY ring attack gets NO covers? extension —
  # a pack body that committed off the adjacent tile mid-windup is
  # honestly missed (enemy difficulty against moving players unchanged).
  def test_enemy_ring_attack_still_misses_a_pack_body_that_stepped_off
    striker, human = stage_striker_with_one_human(world, stagger_human: false)
    human.interrupt_action!
    hp_before = striker.hp
    windup = human.kit[:attack][:windup_frames]

    assert human.start_attack, "the enemy must swing (idle + exhaust ready)"
    drive(world, windup - 1)
    striker.walker.step(-1, 0, frames: 16) # departs [12,12] mid-windup
    assert striker.walker.moving?
    assert striker.walker.covers?(12, 12),
           "the body still COVERS the departed tile — only the enemy rule ignores it"
    drive(world, 2)

    assert_equal hp_before, striker.hp,
                 "enemy ring keeps committed-tile equality (no covers? extension)"
  end
end
