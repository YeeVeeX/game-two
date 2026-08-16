require_relative "../test_helper"
require "app/writ_frame"

# v16 (d): writ-frame dim geometry — up to 4 rects covering the map MINUS
# the writ square, pure function of (center, half, bounds). The GLM fold:
# a full-screen veil reads as a GPU glitch and threatens fairness — the
# inside of the writ stays fully readable, so the dim rects must never
# bleed into it.
class WritFrameTest < Minitest::Test
  def rects(cx: 200, cy: 150, half: 64, w: 400, h: 300)
    App::WritFrame.dim_rects(cx:, cy:, half:, w:, h:)
  end

  def area(list) = list.sum { |_, _, w, h| w * h }

  def test_dim_covers_everything_but_the_writ
    assert_equal 400 * 300 - 128 * 128, area(rects)
  end

  def test_rects_never_bleed_into_the_writ_interior
    rects.each do |x, y, w, h|
      overlap_x = x < 200 + 64 && x + w > 200 - 64
      overlap_y = y < 150 + 64 && y + h > 150 - 64
      refute(overlap_x && overlap_y, "[#{x},#{y},#{w},#{h}] bleeds into the writ")
    end
  end

  def test_clips_at_the_map_corner
    list = rects(cx: 20, cy: 20)
    assert_equal 400 * 300 - 84 * 84, area(list),
                 "only the visible sliver of the writ is spared"
    list.each do |x, y, w, h|
      assert x >= 0 && y >= 0 && x + w <= 400 && y + h <= 300,
             "[#{x},#{y},#{w},#{h}] leaves the bounds"
    end
  end

  def test_writ_larger_than_the_bounds_dims_nothing
    assert_empty rects(half: 500)
  end

  def test_pure_and_integer
    assert_equal rects, rects
    rects.flatten.each { |v| assert_kind_of Integer, v }
  end
end
