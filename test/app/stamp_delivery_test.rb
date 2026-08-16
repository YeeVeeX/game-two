require_relative "../test_helper"
require "app/stamp_delivery"

# v16 (c): stamp delivery window math — pure functions of the entry clock
# (no RNG stream, no wall clock), the KillPop-geometry law. Factor
# endpoints ride data/display.json; nothing in the module is a tunable.
class StampDeliveryTest < Minitest::Test
  def scale(age, in_frames: 12, from: 1.6)
    App::StampDelivery.scale_at(age:, in_frames:, from:, to: 1.0)
  end

  def alpha(frames_left, fade_frames: 30)
    App::StampDelivery.alpha_at(frames_left:, fade_frames:)
  end

  def test_scale_starts_at_from_and_lands_on_to
    assert_in_delta 1.6, scale(0)
    assert_in_delta 1.0, scale(12)
  end

  def test_scale_in_is_linear_no_easing_constants
    assert_in_delta 1.3, scale(6)
    assert_in_delta 1.45, scale(3)
  end

  def test_scale_holds_at_to_through_the_dwell
    assert_in_delta 1.0, scale(13)
    assert_in_delta 1.0, scale(149)
  end

  def test_degenerate_in_window_is_already_landed
    assert_in_delta 1.0, scale(0, in_frames: 0)
  end

  def test_alpha_full_through_the_dwell
    assert_equal 255, alpha(150)
    assert_equal 255, alpha(30)
  end

  def test_alpha_fades_linearly_over_the_tail
    assert_equal 128, alpha(15)
    assert_equal 0, alpha(0)
  end

  def test_degenerate_fade_window_never_dims
    assert_equal 255, alpha(0, fade_frames: 0)
  end
end
