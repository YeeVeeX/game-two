require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# The wipe becomes the judgment (spec S4): marked revive + burn, unmarked
# stay dead, one-vessel floor. Driven through the REAL wipe path: kill all
# three, tick through the respawn timer.
class EconomyJudgmentTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  RESPAWN = DATA["balance/combat"][:respawn_frames]

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(n)
    input = scripted({})
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def wipe!
    killer = world.humans.first || world.possessed
    world.pack.members.each do |m|
      m.take_hit(damage: m.hp, attacker: killer) until m.dead?
    end
    drive(RESPAWN + 2)
  end

  def test_marked_survive_and_burn_unmarked_dissolve
    marked = world.possessed
    marked.inscribe_mark!
    consumed = []
    dissolved = []
    world.bus.subscribe(:mark_consumed) { |e| consumed << e[:body] }
    world.bus.subscribe(:body_dissolved) { |e| dissolved << e[:body] }
    wipe!
    refute marked.dead?
    refute marked.marked?, "the judgment consumes the mark"
    assert_equal [marked], consumed
    others = world.pack.members - [marked]
    assert others.all?(&:dead?), "unmarked stay dead (dissolved) until regrown"
    assert_equal others.sort_by { |m| world.pack.members.index(m) },
                 dissolved.sort_by { |m| world.pack.members.index(m) }
    assert_equal marked, world.pack.possessed
  end

  def test_floor_keeps_the_possessed_vessel_when_nothing_marked
    vessel = world.pack.possessed
    kept = []
    world.bus.subscribe(:vessel_kept) { |e| kept << e[:body] }
    wipe!
    assert_equal [vessel], kept
    refute vessel.dead?
    assert_equal vessel, world.pack.possessed
    assert_equal 2, world.pack.members.count(&:dead?)
  end

  def test_possession_snaps_when_the_possessed_dissolved
    marked = (world.pack.members - [world.possessed]).first
    marked.inscribe_mark!
    wipe!
    assert_equal marked, world.pack.possessed,
                 "possession snaps to the revived member"
    refute marked.staggered?, "judgment snap pays no stagger"
  end

  def test_banked_survives_the_judgment_untaxed
    world.pack.bank!(9)
    wipe!
    assert_equal 9, world.pack.banked
  end

  def test_judgment_clears_unloaded_pack_corpse_records_only
    # Stage: one unloaded pack corpse record + wipe. Loaded containers are
    # D1 pile markers and MUST survive (grace law).
    wipe!
    world.corpses.each do |c|
      assert c[:faction] != :pack || c[:container_id],
             "unloaded pack husks must be gone after the judgment"
    end
  end
end
