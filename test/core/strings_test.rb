require "minitest/autorun"
require "core/data_store"
require "core/strings"

module Core
  # Locale resolver law (v13 i18n): player-visible text resolves at RENDER
  # time only; precedence explicit locale > GAME_LOCALE env > display.json >
  # "en"; missing key falls through locale table -> en table -> caller
  # fallback. Real DataStore over the real data/ dir (no mocks law).
  class StringsTest < Minitest::Test
    DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

    def setup
      @env_was = ENV.fetch("GAME_LOCALE", nil)
      ENV.delete("GAME_LOCALE")
    end

    def teardown
      @env_was ? ENV["GAME_LOCALE"] = @env_was : ENV.delete("GAME_LOCALE")
    end

    def test_es_locale_resolves_translated_zone_name
      s = Strings.new(DATA, locale: "es")
      assert_equal "La Segunda Vela", s.t("zone.camp.display_name", "The Second Vigil")
    end

    def test_pt_br_locale_resolves_translated_breach_line
      s = Strings.new(DATA, locale: "pt-br")
      assert_equal "A PASSAGEM ESTÁ PAGA", s.t("breach.line", "THE WAY IS PAID")
    end

    def test_en_locale_returns_fallback_for_zone_keys
      # en.json deliberately holds no zone keys — the zone JSON display_name
      # (the caller's fallback) is the canonical EN text, unchanged bytes.
      s = Strings.new(DATA, locale: "en")
      assert_equal "The Second Vigil", s.t("zone.camp.display_name", "The Second Vigil")
    end

    def test_wipe_line_lives_in_en_json_not_ruby
      # The extraction proof: the wipe line resolves from data with NO
      # fallback argument at every locale. v14 rename batch: the judgment
      # register line (v12 fiction annex pre-registration).
      assert_equal "THE FLESH IS SPENT", Strings.new(DATA, locale: "en").t("wipe.line")
      assert_equal "LA REENCARNACIÓN ES INMINENTE", Strings.new(DATA, locale: "es").t("wipe.line")
    end

    def test_explicit_locale_beats_env
      ENV["GAME_LOCALE"] = "es"
      s = Strings.new(DATA, locale: "en")
      assert_equal "The Keyward", s.t("zone.district_two.display_name", "The Keyward")
    end

    def test_env_beats_display_json
      ENV["GAME_LOCALE"] = "pt-br"
      s = Strings.new(DATA)
      assert_equal "A Primeira Vigília", s.t("zone.nest.display_name", "The First Vigil")
    end

    def test_display_json_default_is_en
      s = Strings.new(DATA)
      assert_equal "en", s.locale
    end

    def test_unknown_locale_falls_through_to_en_then_fallback
      s = Strings.new(DATA, locale: "fr")
      assert_equal "THE FLESH IS SPENT", s.t("wipe.line")          # en table
      # zone.camp has no en.json override — proves the caller-fallback leg.
      assert_equal "The Second Vigil", s.t("zone.camp.display_name", "The Second Vigil")
    end

    def test_renamed_zones_resolve_from_en_overrides
      # v14 rename batch: the two renamed zones carry en.json overrides so
      # every locale (known or not) sees the new canon names.
      s = Strings.new(DATA, locale: "fr")
      assert_equal "The First Vigil", s.t("zone.nest.display_name", "stale")
      assert_equal "The Longrow", s.t("zone.district.display_name", "stale")
    end

    def test_missing_key_everywhere_returns_nil_without_fallback
      assert_nil Strings.new(DATA, locale: "es").t("no.such.key")
    end
  end
end
