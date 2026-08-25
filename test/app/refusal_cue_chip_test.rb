require_relative "../test_helper"
require "app/renderer"
require "json"

# D1 (uiux M1 adoption, s75 — drafts/_d1d2-adoption-20260825.md): the
# refusal-cue text chip vocabulary ships in data (non-negotiable 3 —
# fetch defaults only keep a bare Renderer.new drawable). The adopted
# values are spec-verbatim from the uiux staged delta d1_cue_backing.json
# (blob md5 97ac3f709d9f2891f205ef8f32f209ad @ game-two-uiux 9907021) —
# pinned here as a drift guard, the safe-chip wording-pin precedent.
# Draw OUTPUT (chip geometry, cream-on-dark legibility on both grounds)
# is judged by the Rule 2 gate (town_gates + sustain_run), not here —
# the silent_beat? precedent.
class RefusalCueChipTest < Minitest::Test
  def display
    @display ||= JSON.parse(
      File.read(File.expand_path("../../data/display.json", __dir__))
    )
  end

  def test_display_declares_the_cue_chip_keys
    %w[cue_text_rgb cue_backing_rgb cue_backing_alpha cue_backing_pad].each do |k|
      assert display.key?(k), "display.json missing #{k}"
    end
  end

  def test_adopted_values_are_spec_verbatim
    assert_equal [225, 215, 190], display.fetch("cue_text_rgb"),
                 "cue text = banner cream (adopted d1 spec)"
    assert_equal [12, 10, 14], display.fetch("cue_backing_rgb")
    assert_equal 160, display.fetch("cue_backing_alpha"),
                 "ledger_panel_alpha family"
    assert_equal 4, display.fetch("cue_backing_pad"),
                 "pad 4 keeps the chip inside the cue's line box (occlusion budget)"
  end
end
