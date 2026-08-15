require_relative "../test_helper"
require "app/scale"

# v16 (a): the scaling POLICY is pure math (no Gosu) so it tests headless.
# The wiring test at the bottom constructs the real window — no mocks.
class ScaleTest < Minitest::Test
  def factor(setting, sw:, sh:)
    App::Scale.factor(setting, view_w: 960, view_h: 540, screen_w: sw, screen_h: sh)
  end

  def test_auto_doubles_on_1080p = assert_equal(2, factor("auto", sw: 1920, sh: 1080))
  def test_auto_quadruples_on_4k = assert_equal(4, factor("auto", sw: 3840, sh: 2160))
  def test_auto_clamps_to_one_on_small_screens = assert_equal(1, factor("auto", sw: 1366, sh: 768))
  def test_auto_is_one_when_screen_equals_view = assert_equal(1, factor("auto", sw: 960, sh: 540))
  def test_auto_limited_by_shorter_axis = assert_equal(2, factor("auto", sw: 3840, sh: 1080))
  def test_explicit_integer_wins_over_screen = assert_equal(3, factor(3, sw: 1920, sh: 1080))
  def test_explicit_integer_clamps_to_one = assert_equal(1, factor(0, sw: 1920, sh: 1080))
  def test_absent_key_keeps_pre_v16_behavior = assert_equal(1, factor(nil, sw: 3840, sh: 2160))
  def test_garbage_setting_falls_back_to_one = assert_equal(1, factor("huge", sw: 3840, sh: 2160))

  # Spec harness law: the capture pipeline never sees the factor. The replay
  # window opens at SCRIPT dims; window_scale must not leak in.
  def test_harness_never_reads_window_scale
    src = File.read(File.expand_path("../../harness/replay_runner.rb", __dir__))
    refute_includes src, "window_scale",
                    "harness must stay pinned at script dims (capture pipeline untouched)"
  end

  # Real wiring, real data, real Gosu window (not shown) — no mocks.
  def test_window_opens_at_scaled_logical_dimensions
    require "app/window"
    w = App::Window.new
    assert_equal w.view_width * w.scale, w.width
    assert_equal w.view_height * w.scale, w.height
    assert w.scale >= 1
  end
end
