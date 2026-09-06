require "gosu"

module App
  # S2 — the BAG SCREEN (read-only this ticket; select/use/equip verbs come
  # with S3/S4 through the protocol). A centered dark panel: title with the
  # used/slots count, a 5x4 grid of cells (icon + qty), a detail column that
  # describes the first stack of each kind (name · kind · what it does), and
  # the close hint with the bag key glyph. Toggled by the `bag` binding in
  # App::Window (UI, not a sim verb — lockstep never sees it). Pure function
  # of (bag, catalog, strings); nothing here writes state.
  class BagScreen
    COLS = 5
    ROWS = 4
    CELL = 36
    GAP = 4

    def initialize(display:, strings:, icons:, bindings: nil)
      @display = display
      @strings = strings
      @icons = icons
      @bindings = bindings
    end

    def draw(world, view_w, view_h)
      bag = world.bag
      catalog = world.catalog
      gw = COLS * (CELL + GAP) - GAP
      pw = gw + 24 + 220
      ph = ROWS * (CELL + GAP) - GAP + 78
      x0 = (view_w - pw) / 2
      y0 = (view_h - ph) / 2
      z = 30
      # dim the world, then the plate
      Gosu.draw_rect(0, 0, view_w, view_h, Gosu::Color.new(150, 6, 4, 6), z)
      Gosu.draw_rect(x0 - 2, y0 - 2, pw + 4, ph + 4, Gosu::Color.new(255, 200, 190, 170), z)
      Gosu.draw_rect(x0, y0, pw, ph, Gosu::Color.new(245, 18, 14, 14), z)
      Gosu.draw_rect(x0 + 1, y0 + 1, pw - 2, 1, Gosu::Color.new(70, 255, 230, 200), z)
      # title
      title = "#{tr('hud.bag', 'BAG')}  #{bag.used}/#{bag.slots}"
      title_font.draw_text(title, x0 + 12, y0 + 8, z, 1, 1, gold)
      # grid
      gx = x0 + 12
      gy = y0 + 34
      # the pack's flasks (provisions) SHOW as the catalog flask - one truth on
      # screen; the counter itself stays where the save keeps it until T1
      stacks = bag.sorted
      if world.respond_to?(:pack) && world.pack.provisions.positive? && catalog.include?(:flask_sap)
        stacks = [{ id: :flask_sap, qty: world.pack.provisions, virtual: true }] + stacks
      end
      (ROWS * COLS).times do |i|
        cx = gx + (i % COLS) * (CELL + GAP)
        cy = gy + (i / COLS) * (CELL + GAP)
        filled = i < stacks.length
        Gosu.draw_rect(cx, cy, CELL, CELL, Gosu::Color.new(255, 30, 24, 26), z)
        Gosu.draw_rect(cx, cy, CELL, 1, Gosu::Color.new(255, 52, 44, 44), z)
        next unless filled
        st = stacks[i]
        item = catalog.fetch(st[:id])
        ico = item && @icons&.icon(item)
        if ico
          ico.draw(cx + (CELL - 32) / 2, cy + (CELL - 32) / 2, z + 1, 2, 2)
        else
          Gosu.draw_rect(cx + 10, cy + 10, CELL - 20, CELL - 20, Gosu::Color.new(255, 205, 198, 180), z + 1)
        end
        if st[:qty] > 1
          q = st[:qty].to_s
          haloed(font, q, cx + CELL - font.text_width(q) - 3, cy + CELL - 15, z + 2, Gosu::Color::WHITE)
        end
        Gosu.draw_rect(cx, cy + CELL - 2, CELL, 2, tier_color(item&.tier || 0), z + 1) if item
      end
      # detail column: the first stack of each kind, in bag order
      dx = gx + gw + 24
      dy = gy
      Gosu.draw_rect(dx - 8, gy, 1, ROWS * (CELL + GAP) - GAP, Gosu::Color.new(255, 52, 44, 44), z)
      shown = 0
      stacks.map { |s| catalog.fetch(s[:id]) }.compact.uniq(&:kind).each do |item|
        break if shown >= 6
        name = tr("item.#{item.id}.name", item.id.to_s.upcase)
        kind = tr("item.kind.#{item.kind}", item.kind.to_s.upcase)
        font.draw_text(name, dx, dy, z, 1, 1, Gosu::Color.new(255, 245, 240, 225))
        small.draw_text("#{kind} · #{describe(item)}", dx, dy + 14, z, 1, 1, dim)
        dy += 30
        shown += 1
      end
      if stacks.empty?
        small.draw_text(tr("bag.empty", "EMPTY"), dx, dy, z, 1, 1, dim)
      end
      # close hint
      glyph = (@bindings&.glyphs(:bag)&.first) || "I"
      hint = "#{glyph}  #{tr('bag.close', 'CLOSE')}"
      small.draw_text(hint, x0 + pw - small.text_width(hint) - 12, y0 + ph - 18, z, 1, 1, dim)
    end

    private

    # One line of what an item DOES, from the catalog (no strings needed:
    # numbers + mod keys are language-invariant on purpose).
    def describe(item)
      if item.use
        item.use.map { |k, v| v.is_a?(Hash) ? "#{k} #{v.map { |a, b| "#{a} #{b}" }.join(' ')}" : "#{k} #{Array(v).join('/')}" }.join(" · ")
      elsif !item.mods.empty?
        item.mods.map { |k, v| v.is_a?(Hash) ? v.map { |a, b| "#{a} #{fmt(b)}" }.join(" ") : "#{k} #{fmt(v)}" }.join(" · ")
      else
        "#{tr('bag.sell', 'SELL')} #{item.sell}"
      end
    end

    def fmt(v)
      return v.to_s if v.is_a?(Integer)
      pct = (v * 100).round
      (pct.positive? ? "+" : "") + "#{pct}%"
    end

    def tier_color(t)
      case t
      when 0 then Gosu::Color.new(255, 120, 112, 100)
      when 1 then Gosu::Color.new(255, 90, 180, 110)
      else Gosu::Color.new(255, 170, 140, 220)
      end
    end

    def haloed(f, text, x, y, z, col)
      hc = Gosu::Color.new(255, 20, 14, 12)
      [[1, 0], [-1, 0], [0, 1], [0, -1]].each { |(ddx, ddy)| f.draw_text(text, x + ddx, y + ddy, z, 1, 1, hc) }
      f.draw_text(text, x, y, z, 1, 1, col)
    end

    def gold = @gold ||= Gosu::Color.new(255, 200, 160, 80)
    def dim = @dim ||= Gosu::Color.new(255, 150, 138, 120)
    def font = @font ||= Gosu::Font.new(14)
    def small = @small ||= Gosu::Font.new(12)
    def title_font = @title_font ||= Gosu::Font.new(18)
    def tr(key, fallback) = @strings ? @strings.t(key, fallback) : fallback
  end
end
