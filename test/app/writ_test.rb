require_relative "../test_helper"
require "app/writ"

# v16 (d): the writ-frame is pure window math — a square ritual frame
# around the chanter; the world OUTSIDE darkens (four bands tiling the
# view minus the square), INSIDE stays fully readable (GLM review fold:
# a full-screen veil reads as a GPU glitch and threatens fairness).
class WritTest < Minitest::Test
  VIEW_W = 960
  VIEW_H = 540

  def rects(cx:, cy:, radius: 128)
    App::Writ.rects(cx:, cy:, radius:, view_w: VIEW_W, view_h: VIEW_H)
  end

  def area(list) = list.sum { |(_, _, w, h)| w * h }

  def visible_square(cx, cy, radius)
    left = (cx - radius).clamp(0, VIEW_W)
    right = (cx + radius).clamp(0, VIEW_W)
    top = (cy - radius).clamp(0, VIEW_H)
    bottom = (cy + radius).clamp(0, VIEW_H)
    [right - left, 0].max * [bottom - top, 0].max
  end

  def test_out_bands_tile_the_view_minus_the_writ_square
    r = rects(cx: 480, cy: 270)
    assert_equal VIEW_W * VIEW_H - visible_square(480, 270, 128), area(r[:out]),
                 "outside bands cover exactly the view minus the square"
  end

  def test_out_bands_never_overlap_the_inside
    r = rects(cx: 480, cy: 270, radius: 100)
    r[:out].each do |(x, y, w, h)|
      refute x < 580 && x + w > 380 && y < 370 && y + h > 170,
             "band [#{x},#{y},#{w},#{h}] bleeds into the writ interior"
    end
  end

  def test_frame_clamps_at_the_view_corner
    r = rects(cx: 30, cy: 30) # chanter near the camera corner
    assert_equal VIEW_W * VIEW_H - visible_square(30, 30, 128), area(r[:out])
    r[:out].each do |(x, y, w, h)|
      assert x >= 0 && y >= 0 && w >= 0 && h >= 0, "negative geometry"
      assert x + w <= VIEW_W && y + h <= VIEW_H, "band leaves the view"
    end
  end

  def test_border_hugs_the_square
    r = rects(cx: 480, cy: 270, radius: 128)
    xs = r[:border].map { |(x, _, _, _)| x }
    ys = r[:border].map { |(_, y, _, _)| y }
    assert_equal 4, r[:border].length
    assert_includes xs, 480 - 128
    assert_includes ys, 270 - 128
  end

  def test_integer_geometry
    rects(cx: 481, cy: 271, radius: 96).values.flatten.each do |v|
      assert_kind_of Integer, v
    end
  end
end
