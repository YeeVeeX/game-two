require_relative "../test_helper"
require "app/renderer"
require "json"

# D2 (uiux M1 adoption, s75 — drafts/_d1d2-adoption-20260825.md): the
# economy-numeral halo vocabulary ships in data (non-negotiable 3).
# Values are spec-verbatim from the uiux staged delta d2_price_halo.json
# (blob md5 dbf21b0fd0d840ec5e47959fa574e9ad @ game-two-uiux 9907021);
# their price_text_rgb key is deliberately NOT adopted — the glyph color
# is unchanged DROP_CORE (deviation recorded in the adoption doc). Halo
# offsets are the one pure half (their harness mechanism verbatim);
# draw OUTPUT is judged by the Rule 2 gate (world_loop + mercy_floor) —
# the silent_beat? precedent.
class PriceHaloTest < Minitest::Test
  def display
    @display ||= JSON.parse(
      File.read(File.expand_path("../../data/display.json", __dir__))
    )
  end

  def test_display_declares_the_halo_keys
    assert_equal 1, display.fetch("price_text_halo_px"),
                 "1px halo (adopted d2 spec)"
    assert_equal [20, 14, 12], display.fetch("price_text_halo_rgb"),
                 "dark halo, NOTCH-family near-black"
  end

  def test_halo_offsets_at_1px_are_the_eight_chebyshev_neighbors
    offsets = App::Renderer.halo_offsets(1)
    assert_equal 8, offsets.length
    refute_includes offsets, [0, 0], "the glyph's own cell is never a halo draw"
    assert_equal offsets.uniq.length, offsets.length
    offsets.each do |(dx, dy)|
      assert_equal 1, [dx.abs, dy.abs].max, "px=1 offsets sit at Chebyshev 1"
    end
  end

  def test_halo_offsets_union_rings_not_outermost_only
    offsets = App::Renderer.halo_offsets(2)
    App::Renderer.halo_offsets(1).each do |o|
      assert_includes offsets, o,
                      "a 2px halo keeps every 1px offset (union, not outer ring — " \
                      "outermost-only leaves slivers at stroke ends)"
    end
    assert_includes offsets, [2, 2]
    refute_includes offsets, [0, 0]
  end
end
