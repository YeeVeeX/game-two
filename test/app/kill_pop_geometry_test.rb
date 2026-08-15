require_relative "../test_helper"
require "app/kill_pop"

# v16 (e): shard geometry is pure integer math — deterministic by
# construction (no RNG stream, no wall clock), same law as Feel's shake.
class KillPopGeometryTest < Minitest::Test
  def shards(frames_left: 10, phase: 123)
    App::KillPop.shards(tile: [4, 3], phase:, frames_left:, pop_frames: 14, ts: 32)
  end

  def test_deterministic_same_inputs_same_shards
    assert_equal shards, shards
  end

  def test_eight_integer_shards_sized_three_to_four
    s = shards
    assert_equal 8, s.size
    s.each do |x, y, size|
      assert_kind_of Integer, x
      assert_kind_of Integer, y
      assert_includes 3..4, size
    end
  end

  def test_shards_fly_outward_with_age
    near = shards(frames_left: 13) # age 1
    far  = shards(frames_left: 2)  # age 12
    cx = 4 * 32 + 16
    cy = 3 * 32 + 16
    d = ->(list) { list.sum { |x, y, _| (x - cx).abs + (y - cy).abs } }
    assert_operator d.call(far), :>, d.call(near)
  end

  def test_phase_changes_the_pattern
    refute_equal shards(phase: 1), shards(phase: 2)
  end
end
