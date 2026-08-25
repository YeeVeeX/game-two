require_relative "../test_helper"
require "core/tile_map"
require "game/creature"
require "app/renderer"
require "json"

# B1-T2 (spec D5): the visible boundary's pure halves. Threshold cues
# derive from DESTINATION safety over live maps (never a prose list);
# the chip wording is the ratified three-locale set; the display
# vocabulary ships in data (non-negotiable 3 — fetch defaults only keep
# a bare Renderer.new drawable). Draw OUTPUT is judged by the Rule 2
# gate (harness/scripts/safe_boundary.json), not here — the
# silent_beat? precedent.
class SafeBoundaryRenderTest < Minitest::Test
  def tmap(safe:)
    Core::TileMap.new(
      tile_size: 32, display_name: "T",
      palette: { floor: [0, 0, 0], grid: [0, 0, 0], wall: [0, 0, 0],
                 transition: [0, 0, 0] },
      tiles: ["#####", "#...#", "#...#", "#...#", "#####"],
      pack_spawn: [[1, 1], [2, 1], [3, 1]], safe: safe
    )
  end

  def test_unsafe_to_safe_marks_into_safety
    assert_equal :into_safety,
                 App::Renderer.threshold_kind(tmap(safe: false), tmap(safe: true))
  end

  def test_safe_to_unsafe_marks_into_danger
    assert_equal :into_danger,
                 App::Renderer.threshold_kind(tmap(safe: true), tmap(safe: false))
  end

  def test_same_safety_edges_carry_nothing
    assert_nil App::Renderer.threshold_kind(tmap(safe: false), tmap(safe: false))
    assert_nil App::Renderer.threshold_kind(tmap(safe: true), tmap(safe: true))
  end

  def test_unknown_destination_carries_nothing
    assert_nil App::Renderer.threshold_kind(tmap(safe: false), nil)
  end

  # The ratified wording (spec D5, human-facing-output pass at build):
  # a drift pin, same spirit as safe_zone_test's coverage pin.
  CHIP = { "en" => "SAFE", "es" => "SEGURO", "pt-br" => "SEGURO" }.freeze

  def test_chip_wording_pinned_in_all_three_locales
    CHIP.each do |locale, word|
      table = JSON.parse(
        File.read(File.expand_path("../../data/strings/#{locale}.json", __dir__))
      )
      assert_equal word, table.fetch("safe.chip"), "#{locale} safe.chip"
    end
  end

  def test_display_declares_the_boundary_keys
    display = JSON.parse(File.read(File.expand_path("../../data/display.json", __dir__)))
    %w[safe_chip_x safe_chip_y safe_chip_rgb safe_chip_alpha
       safe_chip_backing_alpha safe_threshold_rgb safe_threshold_alpha
       danger_threshold_rgb danger_threshold_alpha].each do |k|
      assert display.key?(k), "display.json missing #{k}"
    end
  end
end
