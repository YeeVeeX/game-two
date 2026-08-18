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

  def test_pre_v18_kinds_stay_textless
    r = renderer
    %i[inscribed tribute breached refused].each do |kind|
      assert_nil r.station_cue_text(kind),
                 "#{kind}: ring/X-bar only — the walled line must not move"
    end
  end
end
