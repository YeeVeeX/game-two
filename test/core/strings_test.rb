require "minitest/autorun"
require "core/data_store"
require "core/strings"

module Core
  # Locale resolver law (v13 i18n): player-visible text resolves at RENDER
  # time only; precedence explicit locale > GAME_LOCALE env > display.json >
  # "en"; missing key falls through locale table -> en table -> caller
  # fallback. Real DataStore over the real data/ dir (no mocks law).
  #
  # 2026-08-16 owner order: all player-visible names/lines are generic
  # placeholders (ZONE N / HUB 1 / BOSS 1 / player N / TOLL PAID). Name
  # values are locale-invariant; functional verbs stay translated, so the
  # precedence tests below lean on verb keys (the values that still differ
  # per locale).
  class StringsTest < Minitest::Test
    DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

    def setup
      @env_was = ENV.fetch("GAME_LOCALE", nil)
      ENV.delete("GAME_LOCALE")
    end

    def teardown
      @env_was ? ENV["GAME_LOCALE"] = @env_was : ENV.delete("GAME_LOCALE")
    end

    def test_es_locale_resolves_zone_key
      s = Strings.new(DATA, locale: "es")
      assert_equal "HUB 1", s.t("zone.camp.display_name", "stale")
    end

    def test_pt_br_locale_resolves_breach_line
      s = Strings.new(DATA, locale: "pt-br")
      assert_equal "TOLL PAID", s.t("breach.line", "stale")
    end

    def test_en_zone_overrides_beat_caller_fallback
      # Every zone key now carries an en.json override (placeholder batch);
      # the caller fallback (zone JSON display_name) loses.
      s = Strings.new(DATA, locale: "en")
      assert_equal "HUB 1", s.t("zone.camp.display_name", "stale")
    end

    def test_missing_key_falls_through_to_caller_fallback
      s = Strings.new(DATA, locale: "en")
      assert_equal "fallback text", s.t("zone.nowhere.display_name", "fallback text")
    end

    def test_stamp_line_lives_in_json_not_ruby
      # The extraction proof: a stamp line resolves from data with NO
      # fallback argument at every locale.
      assert_equal "TOLL PAID", Strings.new(DATA, locale: "es").t("breach.line")
      assert_equal "TOLL PAID", Strings.new(DATA, locale: "pt-br").t("breach.line")
    end

    def test_explicit_locale_beats_env
      # Verb keys still differ per locale, so they carry the precedence proof.
      ENV["GAME_LOCALE"] = "es"
      s = Strings.new(DATA, locale: "en")
      assert_equal "attack", s.t("overlay.attack", "stale")
    end

    def test_env_beats_display_json
      ENV["GAME_LOCALE"] = "pt-br"
      s = Strings.new(DATA)
      assert_equal "interagir", s.t("overlay.interact", "stale")
    end

    def test_display_json_default_is_en
      s = Strings.new(DATA)
      assert_equal "en", s.locale
    end

    def test_unknown_locale_falls_through_to_en_table
      s = Strings.new(DATA, locale: "fr")
      assert_equal "BOSS 1 DEFEATED", s.t("challenger.term.line") # en table
      assert_equal "HUB 1", s.t("zone.camp.display_name", "stale")
    end

    def test_switch_mutates_the_one_shared_resolver
      s = Strings.new(DATA, locale: "en")
      assert_same s, s.switch!(DATA, "es")
      assert_equal "es", s.locale
      assert_equal "atacar", s.t("overlay.attack")
      s.switch!(DATA, "pt-br")
      assert_equal "interagir", s.t("overlay.interact")
    end

    def test_placeholder_names_are_locale_invariant
      # Placeholder law (2026-08-16): names/lines are identical across
      # locales — no authored fiction lives in this repo.
      %w[en es pt-br].each do |loc|
        s = Strings.new(DATA, locale: loc)
        assert_equal "ZONE 1", s.t("zone.nest.display_name", "stale")
        assert_equal "BOSS 1", s.t("challenger.name", "stale")
      end
    end

    def test_missing_key_everywhere_returns_nil_without_fallback
      assert_nil Strings.new(DATA, locale: "es").t("no.such.key")
    end

    # v18 sustain strings (presentation spec): functional dictionary words
    # only — the label translates, the register stays flat mechanics.
    # pt-br 2026-08-18 history: Junior ratified SUPRIMENTO for the v18
    # provisions surface. v20 T3 (foundation L14, owner-ratified at the
    # grill): the system's true identity is POTIONS — the noun flips to
    # the potion word in all three locales (poção/poción/potion); COMPRADA/
    # USADA agree with the feminine noun in es AND pt-br now.
    def test_sustain_strings_resolve_per_locale
      en = Strings.new(DATA, locale: "en")
      es = Strings.new(DATA, locale: "es")
      pt = Strings.new(DATA, locale: "pt-br")
      assert_equal "potion", en.t("overlay.sustain")
      assert_equal "poción", es.t("overlay.sustain")
      assert_equal "poção", pt.t("overlay.sustain")
      assert_equal "POTION", en.t("hud.provisions")
      assert_equal "POCIÓN", es.t("hud.provisions")
      assert_equal "POÇÃO", pt.t("hud.provisions")
      assert_equal "POTION BOUGHT", en.t("cue.provision_bought")
      assert_equal "POCIÓN COMPRADA", es.t("cue.provision_bought")
      assert_equal "POÇÃO COMPRADA", pt.t("cue.provision_bought")
      assert_equal "POTION USED", en.t("cue.provision_used")
      assert_equal "POCIÓN USADA", es.t("cue.provision_used")
      assert_equal "POÇÃO USADA", pt.t("cue.provision_used")
      assert_equal "REFUSED", en.t("cue.provision_refused")
      assert_equal "RECHAZADO", es.t("cue.provision_refused")
      assert_equal "RECUSADO", pt.t("cue.provision_refused")
    end
  end
end
