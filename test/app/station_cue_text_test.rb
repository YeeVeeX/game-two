require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "app/renderer"

# v18 sustain cues (presentation spec): buy/use ride the existing
# station-cue channel — the OK pulse ring gains a functional text line for
# the provision kinds ONLY. Every pre-v18 kind keeps its exact ring-only /
# X-bar-only draw (the wall's byte-identity is the walled proof; this lane
# pins the content rule headlessly — text resolution is pure).
class StationCueTextTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def renderer(locale: "en")
    App::Renderer.new(display: DATA["display"],
                      strings: Core::Strings.new(DATA, locale: locale))
  end

  def test_provision_kinds_carry_localized_text
    r = renderer
    assert_equal "PROVISION BOUGHT", r.station_cue_text(:provision_bought)
    assert_equal "PROVISION USED", r.station_cue_text(:provision_used)
    assert_equal "REFUSED", r.station_cue_text(:provision_refused)
    es = renderer(locale: "es")
    assert_equal "PROVISIÓN COMPRADA", es.station_cue_text(:provision_bought)
    assert_equal "RECHAZADO", es.station_cue_text(:provision_refused)
  end

  # T5 (P9/D4): the level-gate refusal line — the <N> placeholder rides
  # the tables in all three locales (numerals never enter the flat K/V
  # tables; the sub happens at draw, the net.desync idiom).
  def test_level_required_carries_the_placeholder_in_every_locale
    assert_equal "LEVEL <N> REQUIRED", renderer.station_cue_text(:level_required)
    assert_equal "NIVEL <N> REQUERIDO",
                 renderer(locale: "es").station_cue_text(:level_required)
    assert_equal "NÍVEL <N> NECESSÁRIO",
                 renderer(locale: "pt-br").station_cue_text(:level_required)
  end

  def test_level_required_sub_renders_the_named_level
    text = renderer.station_cue_text(:level_required).sub("<N>", 2.to_s)
    assert_equal "LEVEL 2 REQUIRED", text, "the draw-site sub (P9 placeholder verbatim)"
  end

  def test_level_required_falls_back_strings_less
    bare = App::Renderer.new(display: DATA["display"])
    assert_equal "LEVEL <N> REQUIRED", bare.station_cue_text(:level_required),
                 "a strings-less construct stays drawable (CUE_TEXT_FALLBACK law)"
  end

  def test_pre_v18_kinds_stay_textless
    r = renderer
    %i[inscribed tribute breached refused].each do |kind|
      assert_nil r.station_cue_text(kind),
                 "#{kind}: ring/X-bar only — the walled line must not move"
    end
  end
end
