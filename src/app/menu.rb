require "gosu"
require "core/input"

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
  # key-repeat (D5): a three-row menu needs none; reel authors keep presses
  # >= 8 frames apart (edge-merge trap).
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

    TRACKED = %i[menu up down attack].freeze
    ROOT_ROWS = %i[resume controls quit].freeze
    ROW_FALLBACK = { resume: "RESUME", controls: "CONTROLS", quit: "QUIT" }.freeze

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

    def initialize(display: {}, strings: nil, bindings: nil, view_w: 960, view_h: 540)
      @display = display
      @strings = strings
      @bindings = bindings
      @view_w = view_w
      @view_h = view_h
      @state = :closed
      @cursor = 0
      @prev = {}
      @null_input = Core::NullInput.new # D1: the menu holds the one instance
    end

    def open? = @state != :closed

    # The window's routing seam (D1): closed -> the SAME object it was
    # handed (byte-path identical for every shipped script — wall-debt
    # audit); open -> the held NullInput (mask 0 on the wire, idle frames
    # keep flowing).
    def route(input) = open? ? @null_input : input

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
      when :controls
        @state = :root if edges[:menu]
        nil
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
      when :controls
        { screen: :controls, title: tr("menu.controls", "CONTROLS"),
          hint: tr("menu.hint", "ESC: CLOSE"),
          rows: SHEET.map do |row|
            { label: tr(row[:label], row[:fallback]),
              glyphs: row[:actions].map { |a| glyphs_for(a) } }
          end }
      end
    end

    def draw
      m = draw_model
      return unless m
      Gosu.draw_rect(0, 0, @view_w, @view_h, Gosu::Color.new(veil_alpha, *BG), 50)
      m[:screen] == :root ? draw_root(m) : draw_sheet(m)
    end

    private

    def open!
      @state = :root
      @cursor = 0 # deterministic reopen: cursor always starts on RESUME
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
      when :resume then @state = :closed
      when :controls then @state = :controls
      when :quit then return :quit
      end
      nil
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
    def title_font = @title_font ||= Gosu::Font.new(@display.fetch(:menu_title_font_size, 28), bold: true)
    def row_font = @row_font ||= Gosu::Font.new(@display.fetch(:menu_row_font_size, 18))
    def hint_font = @hint_font ||= Gosu::Font.new(@display.fetch(:menu_hint_font_size, 12))
  end
end
