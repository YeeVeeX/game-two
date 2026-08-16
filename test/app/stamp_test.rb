require_relative "../test_helper"
require "app/stamp"

# v16 (c): stamp delivery timing is pure window math — scale-in over
# stamp_in_frames (factor endpoints live in data; no easing-curve constants
# in code), full-alpha dwell, fade tail over the final third (the
# drop-decay/ledger grammar).
class StampTest < Minitest::Test
  def scale(age, in_frames: 12, in_scale: 1.6)
    App::Stamp.scale(age:, in_frames:, in_scale:)
  end

  def alpha(left, total: 150)
    App::Stamp.alpha(frames_left: left, frames_total: total)
  end

  def test_scale_opens_at_the_data_endpoint
    assert_in_delta 1.6, scale(0)
  end

  def test_scale_eases_linearly_to_one_over_the_in_window
    assert_in_delta 1.3, scale(6)
    assert_in_delta 1.0, scale(12)
  end

  def test_scale_holds_at_one_through_the_dwell
    assert_in_delta 1.0, scale(60)
  end

  def test_scale_degenerate_window_is_flat
    assert_in_delta 1.0, scale(0, in_frames: 0)
  end

  def test_alpha_full_through_the_dwell
    assert_equal 255, alpha(150)
    assert_equal 255, alpha(50), "fade starts strictly inside the final third"
  end

  def test_alpha_fades_over_the_final_third
    assert_equal 128, alpha(25)
    assert_operator alpha(10), :<, alpha(25), "the tail keeps falling"
    assert_equal 0, alpha(0)
  end
end
