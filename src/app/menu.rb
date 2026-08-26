require "gosu"
require "core/input"
require "app/audio_bridge"
require "app/stats_panel"

module App
  # J-6 non-pausing menu (v19 Lane 4; brief drafts/_j6-menu-brief-20260823.md).
  # App-layer ONLY: the world never knows the menu exists — while open the
  # window routes the world/session a NullInput (idle frames keep flowing in
  # netplay; the sim keeps ticking underneath). Never World StateStack state
  # (that stack is lockstep sim state — brief D1), never on the wire
  # (Protocol.ACTIONS untouched; :menu is local presentation).
  #
  # Input: poll + edge-detect over the abstract :menu/:up/:down/:attack
  # actions (brief D2) — the SAME seam serves KeyboardInput (Escape binding)
  # and ScriptedInput (the Rule 2 reel names `menu` rows directly). No
  # key-repeat (D5): a short root list needs none; reel authors keep
  # presses >= 8 frames apart (edge-merge trap).
  #
  # #draw is the only Gosu-touching method (NetplayOverlay pattern); state
  # resolution + #draw_model are pure and headless-tested. Geometry/tone
  # knobs live in data/display.json as menu_* keys (Rule 3), fetch-fallback
  # per the ControlsOverlay precedent. Identity colors are code constants
  # (Renderer::BANNER family precedent).
  class Menu
    BONE = [225, 215, 190].freeze          # NetplayOverlay text family
    DIM  = [160, 152, 140].freeze          # ControlsOverlay label tone
    BG   = [12, 10, 14].freeze             # ledger-panel near-black family

    TRACKED = %i[menu up down left right attack].freeze
    ROOT_ROWS = %i[resume stats controls settings quit].freeze
    ROW_FALLBACK = { resume: "RESUME", stats: "STATS", controls: "CONTROLS",
                     settings: "SETTINGS", quit: "QUIT" }.freeze
    LOCALES = %w[en es pt-br].freeze
    VOLUME_STEP_DB = 6.0

    # Read-only controls sheet (D5): one row per teachable verb group,
    # movement/aim/menu INCLUDED (the v14 "movement stays off the strip"
    # parking governs the STRIP, not a dedicated sheet). Glyphs come from
    # the injected Core::BindingMap — the one source that feeds
    # KeyboardInput and the strip (v15 law).
    SHEET = [
      { label: "menu.label.move", fallback: "MOVE", actions: %i[up down left right] },
      { label: "menu.label.aim", fallback: "AIM", actions: %i[aim] },
      { label: "overlay.attack", fallback: "attack", actions: %i[attack] },
      { label: "overlay.dodge", fallback: "dodge", actions: %i[dodge] },
      { label: "menu.label.special", fallback: "SPECIAL", actions: %i[special] },
      { label: "overlay.mark", fallback: "mark", actions: %i[mark] },
      { label: "overlay.interact", fallback: "interact", actions: %i[interact] },
      { label: "overlay.sustain", fallback: "provision", actions: %i[sustain] },
      { label: "overlay.swap", fallback: "swap", actions: %i[swap] },
      { label: "menu.label.menu", fallback: "MENU", actions: %i[menu] }
    ].freeze

    # Bare-construct fallback glyphs (VESSEL_FALLBACK law: a bindings-less
    # Menu stays drawable) — canonical glyphs come from data/bindings.json.
    GLYPH_FALLBACK = { up: %w[Up W], down: %w[Down S], left: %w[Left A],
                       right: %w[Right D], aim: %w[LCtrl RCtrl],
                       attack: %w[J Space], dodge: %w[K LShift],
                       special: %w[L E], mark: [";", "Q"],
                       interact: %w[H F], sustain: %w[U R],
                       swap: %w[Tab], menu: %w[Escape] }.freeze

    def initialize(display: {}, strings: nil, bindings: nil, prefs: nil, audio: nil,
                   on_locale: nil, on_scale: nil, on_fullscreen: nil,
                   view_w: 960, view_h: 540)
      @display = display
      @strings = strings
      @bindings = bindings
      @prefs = prefs
      @audio = audio
      @audio_buses = App::AudioBridge.volume_bus_ids(audio)
      @on_locale = on_locale
      @on_scale = on_scale
      @on_fullscreen = on_fullscreen
      @view_w = view_w
      @view_h = view_h
      @state = :closed
      @cursor = 0
      @prev = {}
      @swallow_route = false
      @null_input = Core::NullInput.new # D1: the menu holds the one instance
      # J-3: the stats screen delegates to its own module (s53 precedent);
      # the panel shares this menu's live strings ref (locale switches
      # mutate the ONE resolver) and holds no world — world arrives at
      # #draw (D7 law).
      @stats_panel = StatsPanel.new(display:, strings:, view_w:, view_h:)
    end

    def open? = @state != :closed

    # J6-C: the window force-closes an open menu the moment a session ends
    # — the end screen owns the frame (A-close banked row; z-war refused).
    def close!
      @state = :closed
      @swallow_route = false
    end

    # The window's routing seam (D1): closed -> the SAME object it was
    # handed (byte-path identical for every shipped script — wall-debt
    # audit); open -> the held NullInput (mask 0 on the wire, idle frames
    # keep flowing).
    def route(input)
      if open? || @swallow_route
        @swallow_route = false unless open?
        @null_input
      else
        input
      end
    end

    # One call per frame, both modes. Consumes menu/nav edges while open;
    # watches only the :menu edge while closed. Returns :quit when the
    # QUIT row is selected (the window owns what quitting means — D3);
    # nil otherwise.
    def tick(input)
      edges = {}
      TRACKED.each do |a|
        now = input.down?(a)
        edges[a] = now && !@prev[a]
        @prev[a] = now
      end
      case @state
      when :closed
        open! if edges[:menu]
        nil
      when :root
        tick_root(edges)
      when :stats
        @state = :root if edges[:menu]
        nil
      when :controls
        @state = :root if edges[:menu]
        nil
      when :settings
        tick_settings(edges)
      end
    end

    # Pure frame description (headless-tested; #draw renders it verbatim).
    # nil while closed; :root lists rows + cursor; :controls lists the
    # glyph sheet.
    def draw_model
      case @state
      when :closed then nil
      when :root
        { screen: :root, title: tr("menu.title", "MENU"),
          hint: tr("menu.hint", "ESC: CLOSE"),
          rows: ROOT_ROWS.each_with_index.map do |id, i|
            { id:, label: tr("menu.#{id}", ROW_FALLBACK[id]), selected: i == @cursor }
          end }
      when :stats
        { screen: :stats, title: tr("menu.stats", "STATS"),
          hint: tr("menu.hint", "ESC: CLOSE") }
      when :controls
        { screen: :controls, title: tr("menu.controls", "CONTROLS"),
          hint: tr("menu.hint", "ESC: CLOSE"),
          rows: SHEET.map do |row|
            { label: tr(row[:label], row[:fallback]),
              glyphs: row[:actions].map { |a| glyphs_for(a) } }
          end }
      when :settings
        { screen: :settings, title: tr("menu.settings", "SETTINGS"),
          hint: tr("menu.hint", "ESC: CLOSE"), rows: settings_rows }
      end
    end

    # J6-C (D14): read-only session diagnostics from EXISTING readers only
    # (session/lockstep counters + the progression readers the HUD uses).
    # Pure — no Gosu; nil outside a params-known session. The reel proves
    # the pixels; labels are locale-invariant technical register.
    # s56 merge fold: XP carries its threshold (x/Δe, MAX at cap — a bare
    # count reads as noise without scale) and a live ledger beat carries
    # its signed net (the number IS the ledger; kind alone says nothing).
    def net_model(session, world)
      return nil unless session&.params_known? && world
      ls = session.lockstep
      span = session.ticks / 60
      prog = world.progression
      xp = prog.level >= prog.level_cap ? "MAX" : "#{prog.xp}/#{prog.delta_e(prog.level + 1)}"
      { link: ["#{tr('menu.net.seat', 'SEAT')} #{session.seat}",
               "#{tr('menu.net.ticks', 'TICKS')} #{session.ticks}",
               "D #{session.params.d}",
               "#{tr('menu.net.stalls', 'STALLS')} #{ls ? ls.stall_updates : 0} · " \
               "#{tr('menu.net.max', 'MAX')} #{ls ? ls.stall_ms_max.round : 0} MS",
               "#{tr('menu.net.desyncs', 'DESYNCS')} #{ls ? ls.desyncs : 0}",
               (tr("net.link_slow", "LINK SLOW") if session.link_slow)].compact,
        ledger: ["#{tr('hud.level', 'LEVEL')} #{prog.level} · XP #{xp}",
                 "#{tr('menu.net.run', 'RUN')} #{format('%d:%02d', span / 60, span % 60)}",
                 ((b = world.ledger_beat) ? format("%s %+d", b[:kind].to_s.upcase, b[:net]) : nil)].compact }
    end

    def draw(session: nil, world: nil)
      m = draw_model
      return unless m
      Gosu.draw_rect(0, 0, @view_w, @view_h, Gosu::Color.new(veil_alpha, *BG), 50)
      case m[:screen]
      when :controls then draw_sheet(m)
      when :stats then @stats_panel.draw(world)
      else
        draw_root(m)
        draw_net_panels(net_model(session, world)) if m[:screen] == :root
      end
    end

    private

    def open!
      @state = :root
      @cursor = 0 # deterministic reopen: cursor always starts on RESUME
      @swallow_route = false # a stale RESUME swallow never crosses an open
    end

    def tick_root(edges)
      if edges[:menu] then @state = :closed
      elsif edges[:up] then @cursor = [@cursor - 1, 0].max
      elsif edges[:down] then @cursor = [@cursor + 1, ROOT_ROWS.size - 1].min
      elsif edges[:attack] then return select_row
      end
      nil
    end

    def select_row
      case ROOT_ROWS[@cursor]
      when :resume
        @state = :closed
        @swallow_route = true # Rule 6 bank: confirm must not leak a world attack
      when :stats then @state = :stats
      when :controls then @state = :controls
      when :settings
        @state = :settings
        @cursor = 0
      when :quit then return :quit
      end
      nil
    end

    def tick_settings(edges)
      if edges[:menu]
        @state = :root
        @cursor = 0
      elsif edges[:up]
        @cursor = [@cursor - 1, 0].max
      elsif edges[:down]
        @cursor = [@cursor + 1, settings_rows.size - 1].min
      elsif edges[:left] || edges[:right] || edges[:attack]
        change_setting(edges[:left] ? -1 : 1)
      end
      nil
    end

    def change_setting(step)
      case @cursor
      when 0
        current = @prefs&.locale || @strings&.locale || "en"
        value = cycle(LOCALES, current, step)
        @prefs.locale = value if @prefs
        @on_locale&.call(value)
      when 1
        presets = @display.fetch(:menu_scale_presets, ["auto", 1, 2, 3])
        current = @prefs&.window_scale || @display[:window_scale] || "auto"
        value = cycle(presets, current, step)
        @prefs.window_scale = value if @prefs
        @on_scale&.call(value)
      when 2
        value = !(@prefs&.fullscreen || false)
        @prefs.fullscreen = value if @prefs
        @on_fullscreen&.call(value)
      else
        change_audio_setting(@cursor - 3, step)
      end
    end

    def cycle(values, current, step)
      values[((values.index(current) || 0) + step) % values.size]
    end

    def settings_rows
      scale = @prefs&.window_scale || @display[:window_scale] || "auto"
      rows = [{ id: :language, label: tr("menu.language", "LANGUAGE"),
                value: (@prefs&.locale || @strings&.locale || "en").upcase },
              { id: :scale, label: tr("menu.scale", "WINDOW SCALE"),
                value: scale == "auto" ? tr("menu.auto", "AUTO") : "#{scale}X" },
              { id: :fullscreen, label: tr("menu.fullscreen", "FULLSCREEN"),
                value: tr(@prefs&.fullscreen ? "menu.on" : "menu.off",
                          @prefs&.fullscreen ? "ON" : "OFF") }]
      unless @audio_buses.empty?
        rows.concat(@audio_buses.map do |bus|
          db = audio_db(bus)
          { id: "volume_#{bus}".to_sym,
            label: "#{tr('menu.volume', 'VOLUME')} #{bus.upcase}",
            value: format_db(db) }
        end)
        rows << { id: :mute, label: tr("menu.mute", "MUTE"),
                  value: tr(@prefs&.muted ? "menu.on" : "menu.off",
                            @prefs&.muted ? "ON" : "OFF") }
      end
      rows.each_with_index.map do |row, i|
        row.merge(selected: i == @cursor, label: "#{row[:label]}: #{row[:value]}")
      end
    end

    def change_audio_setting(index, step)
      return if @audio_buses.empty?
      if index < @audio_buses.length
        bus = @audio_buses.fetch(index)
        db = (audio_db(bus) + step * VOLUME_STEP_DB)
             .clamp(App::Prefs::AUDIO_DB_FLOOR, App::Prefs::AUDIO_DB_CEILING)
        applied = @audio.set_bus_volume(bus, db)
        @prefs.volume_db = [bus, applied] if @prefs
        @audio.set_bus_volume("master", App::Prefs::AUDIO_DB_FLOOR) if @prefs&.muted
      elsif index == @audio_buses.length
        value = !(@prefs&.muted || false)
        @prefs.muted = value if @prefs
        master = value ? App::Prefs::AUDIO_DB_FLOOR : audio_db("master")
        @audio.set_bus_volume("master", master) if @audio_buses.include?("master")
      end
    end

    def audio_db(bus)
      @prefs&.volumes_db&.fetch(bus, 0.0) || 0.0
    end

    def format_db(db)
      db <= App::Prefs::AUDIO_DB_FLOOR ? tr("menu.muted", "MUTED") : format("%+.0f DB", db)
    end

    def glyphs_for(action)
      @bindings ? @bindings.glyphs(action) : GLYPH_FALLBACK.fetch(action, [])
    end

    def draw_root(m)
      w = panel_w
      h = pad * 2 + title_h + m[:rows].size * row_h + hint_h
      x = (@view_w - w) / 2
      y = (@view_h - h) / 2
      Gosu.draw_rect(x, y, w, h, Gosu::Color.new(panel_alpha, *BG), 50)
      ty = y + pad
      title_font.draw_text(m[:title], x + (w - title_font.text_width(m[:title])) / 2,
                           ty, 50, 1, 1, Gosu::Color.new(255, *BONE))
      ty += title_h
      m[:rows].each do |row|
        text = row[:selected] ? "> #{row[:label]}" : row[:label]
        tone = row[:selected] ? BONE : DIM
        row_font.draw_text(text, x + pad * 2, ty, 50, 1, 1, Gosu::Color.new(255, *tone))
        ty += row_h
      end
      draw_hint(m[:hint], x + pad * 2, y + h - hint_h)
    end

    def draw_sheet(m)
      w = sheet_w
      h = pad * 2 + title_h + m[:rows].size * sheet_row_h + hint_h
      x = (@view_w - w) / 2
      y = (@view_h - h) / 2
      Gosu.draw_rect(x, y, w, h, Gosu::Color.new(panel_alpha, *BG), 50)
      ty = y + pad
      title_font.draw_text(m[:title], x + (w - title_font.text_width(m[:title])) / 2,
                           ty, 50, 1, 1, Gosu::Color.new(255, *BONE))
      ty += title_h
      m[:rows].each do |row|
        row_font.draw_text(row[:label], x + pad * 2, ty, 50, 1, 1,
                           Gosu::Color.new(255, *DIM))
        gx = x + w / 2
        row[:glyphs].each do |group|
          primary, *rest = group
          next if primary.nil?
          row_font.draw_text(primary, gx, ty, 50, 1, 1, Gosu::Color.new(255, *BONE))
          gx += row_font.text_width(primary)
          rest.each do |g|
            row_font.draw_text("/#{g}", gx, ty, 50, 1, 1, Gosu::Color.new(255, *DIM))
            gx += row_font.text_width("/#{g}")
          end
          gx += glyph_gap
        end
        ty += sheet_row_h
      end
      draw_hint(m[:hint], x + pad * 2, y + h - hint_h)
    end

    # Two read-only side panels flanking the root menu (session mode only;
    # solo and the single-player wall pass session nil — absent by
    # construction).
    def draw_net_panels(nm)
      return unless nm
      w = net_panel_w
      { tr("menu.net.link_title", "LINK") =>
          [(@view_w - panel_w) / 2 - net_panel_gap - w, nm[:link]],
        tr("menu.net.session_title", "SESSION") =>
          [(@view_w + panel_w) / 2 + net_panel_gap, nm[:ledger]] }.each do |title, (x, rows)|
        h = pad * 2 + net_row_h * (rows.size + 1)
        y = (@view_h - h) / 2
        Gosu.draw_rect(x, y, w, h, Gosu::Color.new(panel_alpha, *BG), 50)
        net_font.draw_text(title, x + pad, y + pad, 50, 1, 1, Gosu::Color.new(255, *BONE))
        rows.each_with_index do |r, i|
          net_font.draw_text(r, x + pad, y + pad + net_row_h * (i + 1), 50, 1, 1,
                             Gosu::Color.new(255, *DIM))
        end
      end
    end

    def draw_hint(text, x, y)
      hint_font.draw_text(text, x, y, 50, 1, 1, Gosu::Color.new(255, *DIM))
    end

    def tr(key, fallback) = @strings ? @strings.t(key, fallback) : fallback

    def veil_alpha = @display.fetch(:menu_veil_alpha, 150)
    def panel_alpha = @display.fetch(:menu_panel_alpha, 220)
    def panel_w = @display.fetch(:menu_panel_w, 320)
    def sheet_w = @display.fetch(:menu_sheet_w, 560)
    def row_h = @display.fetch(:menu_row_h, 34)
    def sheet_row_h = @display.fetch(:menu_sheet_row_h, 24)
    def title_h = @display.fetch(:menu_title_h, 44)
    def hint_h = @display.fetch(:menu_hint_h, 24)
    def pad = @display.fetch(:menu_pad, 20)
    def glyph_gap = @display.fetch(:menu_glyph_gap, 14)
    def net_panel_w = @display.fetch(:menu_net_panel_w, 230)
    def net_panel_gap = @display.fetch(:menu_net_panel_gap, 14)
    def net_row_h = @display.fetch(:menu_net_row_h, 20)
    def net_font = @net_font ||= Gosu::Font.new(@display.fetch(:menu_net_font_size, 13))
    def title_font = @title_font ||= Gosu::Font.new(@display.fetch(:menu_title_font_size, 28), bold: true)
    def row_font = @row_font ||= Gosu::Font.new(@display.fetch(:menu_row_font_size, 18))
    def hint_font = @hint_font ||= Gosu::Font.new(@display.fetch(:menu_hint_font_size, 12))
  end
end
