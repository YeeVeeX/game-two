require_relative "../test_helper"
require "core/data_store"
require "game/world"
require "app/renderer"

RENDERER_DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

# Flywheel fix 1 (2026-08-19): the ledger beat slot must never spend its
# 150-frame dwell on a zero-information "+0" (verified against clip
# low_quay_run 104223, frames v_000729/2492/3836 — kills-only windows
# force-resolved by zone_entered render solo "+0"). The suppression
# predicate is pure logic — draw output itself is judged by the Rule 2
# gate, not here.
class RendererViewportCullingTest < Minitest::Test
  Camera = Data.define(:x, :y, :view_w, :view_h)

  def camera = Camera.new(x: 100.5, y: 50.25, view_w: 960, view_h: 540)

  def test_rect_inside_or_touching_padded_view_is_visible
    assert App::Renderer.rect_visible?([101, 51, 10, 10], camera)
    assert App::Renderer.rect_visible?([99.5, 80, 1, 1], camera),
           "one-pixel pad preserves fractional camera-edge coverage"
    assert App::Renderer.rect_visible?([1061.5, 80, 1, 1], camera)
  end

  def test_rect_strictly_outside_padded_view_is_culled
    refute App::Renderer.rect_visible?([98, 80, 1, 1], camera)
    refute App::Renderer.rect_visible?([1063, 80, 1, 1], camera)
    refute App::Renderer.rect_visible?([200, 47, 1, 1], camera)
    refute App::Renderer.rect_visible?([200, 592, 1, 1], camera)
  end

  def test_visible_grid_indices_cover_view_edges_and_cull_far_lines
    assert_equal 3..9, App::Renderer.visible_grid_indices(20, 32, 100.5, 180)
    assert_equal 0..20, App::Renderer.visible_grid_indices(20, 32, 0, 960)
    assert_equal 34..64, App::Renderer.visible_grid_indices(64, 32, 1_100, 960)
  end

  def test_zone_8_culls_most_static_runs_at_its_spawn_camera
    world = Game::World.new(RENDERER_DATA, seed: 1)
    world.start_in("zone_8")
    renderer = App::Renderer.new(display: RENDERER_DATA["display"])
    tile_runs, motif_runs = renderer.send(:static_runs, world.map, world)
    camera = world.camera
    visible = (tile_runs + motif_runs).count do |rect|
      App::Renderer.rect_visible?(rect, camera)
    end
    total = tile_runs.length + motif_runs.length

    assert_operator total, :>, 1_000, "fixture must retain the ZONE 8 stress shape"
    assert_operator visible, :<, total / 3,
                    "viewport culling must remove the large off-screen majority"
  end
end

class RendererSilentBeatTest < Minitest::Test
  def beat(kind: :fight, gained: 0, pip: 0, dark: 0)
    { kind: kind, gained: gained, pip_amount: pip, dark_amount: dark,
      net: gained - pip - dark, recovery: false,
      beat_left: 150, beat_frames: 150 }
  end

  def test_all_zero_fight_beat_is_silent
    assert App::Renderer.silent_beat?(beat)
  end

  def test_all_zero_bank_beat_is_silent
    assert App::Renderer.silent_beat?(beat(kind: :bank))
  end

  def test_wipe_recap_is_never_silenced_even_all_zero
    refute App::Renderer.silent_beat?(beat(kind: :wipe))
  end

  def test_gained_keeps_the_beat
    refute App::Renderer.silent_beat?(beat(gained: 5))
  end

  def test_stranded_pip_keeps_the_beat
    refute App::Renderer.silent_beat?(beat(pip: 11))
  end

  def test_destroyed_dark_keeps_the_beat
    refute App::Renderer.silent_beat?(beat(dark: 3))
  end
end
