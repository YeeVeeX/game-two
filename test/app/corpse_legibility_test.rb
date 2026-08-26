require_relative "../test_helper"
require "game/creature"
require "app/renderer"
require "json"

# Corpse-legibility pass (s74-verified flywheel candidate; claimed
# 2026-08-26): the human remnant vocabulary ships in data
# (non-negotiable 3). The s74 forensics proved the old base
# [140,135,125] sits ~30 grey points over floor [56-64] at alpha 128 —
# near-invisible — and the drop marker legitimately covers the death
# tile. The fix rides the SHIPPED outline grammar (C1 hairline / N2
# nameplate halo / N4 glyph outline): a 1px near-black rim fading with
# the body + a keyed lift of the human base. Pixels are judged by the
# Rule 2 gate (corpses_persist row); these tests pin the data contract
# and the contrast direction so a data edit can't silently regress the
# legibility this pass buys.
class CorpseLegibilityTest < Minitest::Test
  def display
    @display ||= JSON.parse(
      File.read(File.expand_path("../../data/display.json", __dir__))
    )
  end

  def test_display_declares_the_corpse_keys
    assert_equal 1, display.fetch("corpse_outline_px"),
                 "1px rim (C1/N2/N4 outline family)"
    assert_equal [20, 14, 12], display.fetch("corpse_outline_rgb"),
                 "near-black rim, NOTCH-family (one shared dark, s77 law)"
    assert_equal [175, 165, 145], display.fetch("corpse_human_rgb"),
                 "human remnant base, lifted from the near-floor 140-family"
  end

  def test_human_base_clears_the_floor_grey_family
    # s74 forensics: floor greys run 56-64; the OLD base's brightest
    # channel (140) landed ~30 effective grey points away at fresh
    # alpha 128. Pin the lifted base far enough that even the DIMMEST
    # channel beats the old brightest one — direction, not taste.
    rgb = display.fetch("corpse_human_rgb")
    assert_operator rgb.min, :>=, 140,
                    "every channel must clear the old near-floor base"
    assert_operator rgb.max, :<=, 220,
                    "remnant stays a remnant — never brighter than bone text [225,215,190]"
  end

  def test_rim_is_darker_than_every_floor_grey
    rgb = display.fetch("corpse_outline_rgb")
    assert_operator rgb.max, :<, 56,
                    "the rim separates body from floor by sitting BELOW the darkest floor grey"
  end
end
