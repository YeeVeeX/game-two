module Core
  # Player-visible text resolver (v13 i18n). RENDER-time only — locale must
  # never touch sim state (replay determinism law; the harness constructs
  # this pinned to "en"). Precedence: explicit locale > GAME_LOCALE env >
  # display.json "locale" > "en". Lookup falls through locale table -> en
  # table -> the caller's fallback (the pre-v13 literal, unchanged bytes).
  class Strings
    attr_reader :locale

    def initialize(data, locale: nil)
      @locale = (locale || ENV.fetch("GAME_LOCALE", nil) ||
                 data["display"][:locale] || "en").to_s
      @base = table_for(data, "en")
      @table = @locale == "en" ? @base : table_for(data, @locale)
    end

    def t(key, fallback = nil)
      k = key.to_sym
      @table.fetch(k) { @base.fetch(k) { fallback } }
    end

    # J6-B runtime locale switch: mutate the ONE resolver shared by every
    # presentation surface. Strings remain render-only and never enter sim.
    def switch!(data, locale)
      @locale = locale.to_s
      @table = @locale == "en" ? @base : table_for(data, @locale)
      self
    end

    private

    # DataStore raises on missing keys by design; an unshipped locale
    # degrades to en/fallback instead of crashing the renderer.
    def table_for(data, locale)
      key = "strings/#{locale}"
      data.keys.include?(key) ? data[key] : {}
    end
  end
end
