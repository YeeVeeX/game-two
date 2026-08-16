require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v16 (c): located stamps land IN the world — a floor seal mark at the
# event tile (GLM review fold: screen-space scale-in alone reads
# "achievement popup"). Marks dwell on the banner clock (hitstop pauses
# both), clear on zone entry, and the renderer is a pure reader.
class SealMarkTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  DISPLAY = DATA["display"]

  def world = @world ||= Game::World.new(DATA)

  def drive(n)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def test_located_stamp_lands_a_floor_mark_on_the_banner_clock
    world.send(:enqueue_stamp, "challenger.term.line", "BOSS 1 DEFEATED", at: [4, 3])
    mark = world.seal_marks.find { |m| m[:at] == [4, 3] }
    refute_nil mark, "a located stamp presses its seal into the floor"
    assert_equal DISPLAY[:stamp_banner_frames], mark[:frames_total],
                 "the mark dwells with the banner"
    assert_equal mark[:frames_total], mark[:frames_left]
  end

  def test_unlocated_stamp_leaves_no_mark
    world.send(:enqueue_stamp, "challenger.stands.line", "BOSS 1 SPAWNED")
    assert_empty world.seal_marks
  end

  def test_marks_tick_and_expire
    world.send(:enqueue_stamp, "stamp.probe", "PROBE", at: [4, 3])
    drive(3)
    assert_equal DISPLAY[:stamp_banner_frames] - 3, world.seal_marks.first[:frames_left]
    drive(DISPLAY[:stamp_banner_frames])
    assert_empty world.seal_marks, "spent marks leave the floor"
  end

  def test_hitstop_pauses_marks_like_the_banner
    world.send(:enqueue_stamp, "stamp.probe", "PROBE", at: [4, 3])
    start = world.seal_marks.first[:frames_left]
    world.feel.on_kill
    drive(DATA["balance/combat"][:feel][:hitstop_frames_kill])
    assert_equal start, world.seal_marks.first[:frames_left],
                 "hitstop pauses the court clock"
  end

  def test_marks_clear_on_zone_entry
    world.send(:enqueue_stamp, "stamp.probe", "PROBE", at: [4, 3])
    world.start_in("district")
    assert_empty world.seal_marks, "marks are world-space — leaving abandons them"
  end

  def test_banner_entries_carry_frames_total
    entry = world.active_banner
    assert_equal DISPLAY[:zone_banner_frames], entry[:frames_total],
                 "the renderer needs age = total - left for the scale-in window"
  end

  # The real call site: a seize-kit death is a court event — THE TERM IS
  # PAID stamps the screen AND the floor at the death tile.
  def test_a_seize_kit_death_stamps_the_term_at_the_death_tile
    tile = free_tile
    world.send(:add_human, world.zone_name, :challenger, tile)
    victim = world.humans.find { |c| c.tile == tile }
    victim.take_hit(damage: victim.hp, attacker: world.possessed) until victim.dead?
    drive(1) # bus flush -> :actor_died -> stamp + mark
    assert world.seal_marks.any? { |m| m[:at] == tile },
           "BOSS 1 DEFEATED presses its seal at the death tile"
  end

  def test_display_carries_the_delivery_keys
    assert_operator DISPLAY[:stamp_in_frames], :>, 0
    assert_operator DISPLAY[:stamp_in_scale], :>, 1.0
    assert_operator DISPLAY[:stamp_rule_pad], :>, 0
    assert_operator DISPLAY[:stamp_rule_h], :>, 0
    assert_equal 3, DISPLAY[:stamp_rule_rgb].length
    assert_equal 3, DISPLAY[:seal_mark_rgb].length
  end

  private

  # First free passable tile away from the pack (kill_pop_test idiom).
  def free_tile
    map = world.map
    map.rows.times do |ty|
      map.cols.times do |tx|
        next unless map.passable?(tx, ty)
        next if world.actors.any? { |a| a.tile == [tx, ty] }
        return [tx, ty]
      end
    end
  end
end
