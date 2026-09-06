require "gosu"

module App
  # PREMIUM v22 — the HUD as a PANEL, not three loose bars. Top-left: a
  # translucent dark plate framing three rows (portrait · framed hp bar
  # with fill/highlight/ticks · numeral · pips · carried slot · status
  # icons), the LEVEL strip with tick marks, and two chips (COINS = banked
  # value with a gold disc, POTION = provisions with a flask). Every value
  # already exists in the sim; nothing here reads the clock or lands in the
  # digest. Layout is FIXED (quiet-HUD law: numbers appear/disappear, the
  # frame never shifts). Colors ride display.json with defaults.
  #
  # The gate rows that judge this (hud_three_bars, carried_count_reads,
  # hud_level_strip_reads) keep their truths: three stacked kit-colored
  # bars, the possessed one wider and framed (GOLD now, was white), the
  # carried numeral in its reserved slot right of the two pips, a thin gold
  # LEVEL bar under the rows.
  class Hud
    ROW_H = 20
    BAR_H = 14
    PORTRAIT = 22
    PULSE_FRAMES = 30

    # kit_name -> world frame of the ally's last announced act (from App::Fx)
    attr_accessor :acts

    def initialize(display:, strings:, art:, kit_body:, hp_back:, hp_dead:, drop_core:, item_icons: nil)
      @display = display
      @item_icons = item_icons
      @strings = strings
      @art = art
      @kit_body = kit_body
      @hp_back = hp_back
      @hp_dead = hp_dead
      @drop_core = drop_core
    end

    def draw(world, local_seat)
      possessed = world.possessed(local_seat)
      draw_plate
      world.pack.members.each_with_index do |m, i|
        draw_row(m, i, m.equal?(possessed), world.frame)
      end
      draw_level(world.progression)
      draw_chips(world)
    end

    private

    # --- plate ---------------------------------------------------------------
    def draw_plate
      x, y, w, h = @display.fetch(:hud_plate_rect, [20, 8, 352, 108])
      a = @display.fetch(:hud_plate_alpha, 150)
      Gosu.draw_rect(x, y, w, h, Gosu::Color.new(a, *@display.fetch(:hud_plate_rgb, [14, 10, 10])), 19)
      edge = Gosu::Color.new(a + 40, *@display.fetch(:hud_plate_edge_rgb, [70, 56, 44]))
      Gosu.draw_rect(x, y, w, 1, edge, 19)
      Gosu.draw_rect(x, y + h - 1, w, 1, edge, 19)
      Gosu.draw_rect(x, y, 1, h, edge, 19)
      Gosu.draw_rect(x + w - 1, y, 1, h, edge, 19)
      # a warmer top hairline (light from above)
      Gosu.draw_rect(x + 1, y + 1, w - 2, 1, Gosu::Color.new(60, 255, 230, 200), 19)
    end

    # --- rows ----------------------------------------------------------------
    def draw_row(m, i, mine, frame)
      y = 16 + i * ROW_H
      x = 32
      w = mine ? 260 : 200
      draw_portrait(m, x - 4, y - 4, frame)
      bx = x + PORTRAIT + 2
      bw = w - PORTRAIT - 2
      # frame: gold for the possessed, warm hairline for the downed, dark edge otherwise
      if mine
        Gosu.draw_rect(bx - 2, y - 2, bw + 4, BAR_H + 4, gold, 20)
        Gosu.draw_rect(bx - 1, y - 1, bw + 2, BAR_H + 2, dark, 20)
      elsif m.dead? && (opx = @display.fetch(:hud_bar_down_outline_px, 1)).positive?
        Gosu.draw_rect(bx - opx, y - opx, bw + 2 * opx, BAR_H + 2 * opx,
                       rgb(@display.fetch(:hud_bar_down_outline_rgb, [140, 120, 110])), 20)
      else
        Gosu.draw_rect(bx - 1, y - 1, bw + 2, BAR_H + 2, dark, 20)
      end
      # pass 7: the row PULSES (pale frame fading over 30 frames) when this
      # ally just drank / rolled / fired its special — the HUD says WHO acted
      if !mine && (at = (@acts || {})[m.kit_name]) && (age = frame - at).between?(0, PULSE_FRAMES - 1)
        pa = (220 * (1.0 - age.fdiv(PULSE_FRAMES))).round
        Gosu.draw_rect(bx - 2, y - 2, bw + 4, BAR_H + 4, Gosu::Color.new(pa, 245, 240, 225), 20)
        Gosu.draw_rect(bx - 1, y - 1, bw + 2, BAR_H + 2, dark, 20)
      end
      Gosu.draw_rect(bx, y, bw, BAR_H, m.dead? ? @hp_dead : @hp_back, 20)
      frac = m.hp.fdiv(m.max_hp)
      if frac.positive?
        fw = (bw * frac).round
        kit = @kit_body[m.kit_name]
        Gosu.draw_rect(bx, y, fw, BAR_H, kit, 20)
        # highlight strip + bottom shade = a rounded, lit bar
        Gosu.draw_rect(bx, y, fw, 3, Gosu::Color.new(90, 255, 255, 255), 20)
        Gosu.draw_rect(bx, y + BAR_H - 3, fw, 3, Gosu::Color.new(70, 0, 0, 0), 20)
      end
      # quarter ticks (read the fraction at a glance)
      [0.25, 0.5, 0.75].each do |t|
        Gosu.draw_rect(bx + (bw * t).round, y + BAR_H - 4, 1, 4, Gosu::Color.new(120, 0, 0, 0), 20)
      end
      # numeral on the possessed bar (hp / max)
      if mine && !m.dead?
        txt = "#{m.hp}/#{m.max_hp}"
        tw = font.text_width(txt)
        haloed(font, txt, bx + bw - tw - 5, y - 1, 21, Gosu::Color::WHITE)
      end
      # pips (attack exhaust / special) - same slots as v21
      attack_pip = !m.dead? && m.exhaust_ready? ? gold : @hp_back
      special_ready = !m.dead? && m.kit[:special] && m.special_ready?
      special_pip = special_ready ? @kit_body[m.kit_name] : @hp_back
      Gosu.draw_rect(299, y + 1, 12, 12, dark, 20)
      Gosu.draw_rect(300, y + 2, 10, 10, attack_pip, 20)
      Gosu.draw_rect(313, y + 1, 12, 12, dark, 20)
      Gosu.draw_rect(314, y + 2, 10, 10, special_pip, 20)
      Gosu.draw_rect(317, y + 5, 4, 4, Gosu::Color::WHITE, 20) if special_ready
      # carried numeral: reserved slot (possessed only) - unchanged grammar
      haloed(font, m.carried.to_s, 332, y, 21, @drop_core) if mine && m.carried.positive?
      # status icons right of the carried slot: poison drop (green), seized (blue)
      sx = 352
      if m.respond_to?(:poisoned?) && m.poisoned?
        draw_poison_icon(sx, y + 2)
        sx += 12
      end
      if m.respond_to?(:seized_by) && m.seized_by
        Gosu.draw_rect(sx, y + 2, 10, 10, dark, 20)
        Gosu.draw_rect(sx + 1, y + 3, 8, 8, rgb(@display.fetch(:seized_underline_rgb, [60, 100, 220])), 20)
      end
    end

    def draw_portrait(m, x, y, frame)
      Gosu.draw_rect(x - 1, y - 1, PORTRAIT + 2, PORTRAIT + 2, dark, 20)
      Gosu.draw_rect(x, y, PORTRAIT, PORTRAIT, Gosu::Color.new(255, 30, 24, 26), 20)
      img = portrait_image(m, frame)
      if img
        tint = m.dead? ? Gosu::Color.new(255, 120, 90, 96) : Gosu::Color::WHITE
        # head + shoulders: a pre-cropped 22x22 window of the idle frame
        # (clip_to is illegal inside Gosu.render, the harness capture path)
        img.draw(x, y, 21, 1, 1, tint)
      else
        Gosu.draw_rect(x + 5, y + 5, PORTRAIT - 10, PORTRAIT - 10, @kit_body[m.kit_name], 21)
      end
      # a kit-colored bottom hairline names the kit even with the sprite
      Gosu.draw_rect(x, y + PORTRAIT - 2, PORTRAIT, 2, @kit_body[m.kit_name], 21)
    end

    # The idle-down frame cropped to the head+shoulders window (frame rows
    # 8..29, cols 5..26 for the 32x48 grid), memoized per kit. Image#subimage
    # is a view on the same texture (no re-upload).
    # The portrait BREATHES: the idle cycle's frame for this world frame
    # (same pure column pick the body uses), cropped to head+shoulders and
    # memoized per (kit, column). Image#subimage is a texture view.
    def portrait_image(m, frame)
      return nil unless @art
      atlas = @art.atlas_for(m.kit_name)
      return nil unless atlas
      col = m.dead? ? atlas.frames(:idle).first : App::Art::Body.frame_col(atlas, :idle, frame)
      @portraits ||= {}
      key = [m.kit_name, col]
      return @portraits[key] if @portraits.key?(key)
      full = atlas.tile(@art.facing_row("down"), col)
      @portraits[key] =
        if full
          ox = @display.fetch(:hud_portrait_ox, 5)
          oy = @display.fetch(:hud_portrait_oy, 8)
          full.subimage(ox, oy, PORTRAIT, PORTRAIT)
        end
    end

    # --- level strip -------------------------------------------------------------
    def draw_level(prog)
      sy = @display.fetch(:hud_level_y, 78)
      font.draw_text("#{tr('hud.level', 'LEVEL')} #{prog.level}", 32, sy, 20, 1, 1, gold)
      bx = @display.fetch(:hud_level_bar_x, 140)
      bw = @display.fetch(:hud_level_bar_w, 200)
      bh = @display.fetch(:hud_level_bar_h, 6)
      Gosu.draw_rect(bx - 1, sy + 3, bw + 2, bh + 2, dark, 20)
      Gosu.draw_rect(bx, sy + 4, bw, bh, rgb(@display.fetch(:hud_level_back_rgb, [45, 32, 22])), 20)
      fill = prog.level >= prog.level_cap ? bw : (bw * prog.xp) / prog.delta_e(prog.level + 1)
      if fill.positive?
        Gosu.draw_rect(bx, sy + 4, fill, bh, gold, 20)
        Gosu.draw_rect(bx, sy + 4, fill, 2, Gosu::Color.new(110, 255, 255, 230), 20)
      end
      (1..9).each do |k|
        Gosu.draw_rect(bx + (bw * k / 10.0).round, sy + 4 + bh - 2, 1, 2, Gosu::Color.new(150, 0, 0, 0), 20)
      end
    end

    # --- chips: COINS (banked) · POTION (provisions) --------------------------------
    def draw_chips(world)
      y = @display.fetch(:hud_chips_y, 94)
      x = 32
      # coin disc
      draw_coin(x, y + 1)
      haloed(font, world.pack.banked.to_s, x + 16, y - 2, 21, gold)
      font.draw_text(tr("hud.coins", "COINS"), x + 16 + font.text_width(world.pack.banked.to_s) + 6, y - 2, 20, 1, 1, dim)
      # potion flask
      px = 180
      # S1: the flask chip IS the catalog's flask_sap icon when the sheet is
      # present (one drawing for the HUD, the bag and the floor); else the
      # hand-drawn glyph (fallback law).
      if (ico = @item_icons&.icon("flask_sap"))
        ico.draw(px - 2, y - 2, 20)
      else
        draw_flask(px, y)
      end
      haloed(font, world.pack.provisions.to_s, px + 14, y - 2, 21, Gosu::Color::WHITE)
      font.draw_text(tr("hud.provisions", "POTION"), px + 14 + font.text_width(world.pack.provisions.to_s) + 6, y - 2, 20, 1, 1, dim)
      # S2: the BAG chip - used/slots (a small satchel glyph)
      if world.respond_to?(:bag)
        bx2 = 262
        Gosu.draw_rect(bx2 + 1, y, 10, 3, dark, 20)
        Gosu.draw_rect(bx2, y + 3, 12, 9, Gosu::Color.new(255, 110, 72, 50), 20)
        Gosu.draw_rect(bx2 + 4, y + 5, 4, 2, gold, 20)
        txt = "#{world.bag.used}/#{world.bag.slots}"
        haloed(font, txt, bx2 + 16, y - 2, 21, world.bag.free_slots.zero? ? Gosu::Color.new(255, 240, 90, 80) : Gosu::Color::WHITE)
        font.draw_text(tr("hud.bag", "BAG"), bx2 + 16 + font.text_width(txt) + 6, y - 2, 20, 1, 1, dim)
      end
    end

    def draw_coin(x, y)
      Gosu.draw_rect(x + 2, y, 8, 12, dark, 20)
      Gosu.draw_rect(x, y + 2, 12, 8, dark, 20)
      Gosu.draw_rect(x + 3, y + 1, 6, 10, gold, 20)
      Gosu.draw_rect(x + 1, y + 3, 10, 6, gold, 20)
      Gosu.draw_rect(x + 4, y + 3, 4, 6, Gosu::Color.new(255, 150, 105, 40), 20)
      Gosu.draw_rect(x + 3, y + 2, 3, 1, Gosu::Color.new(255, 255, 245, 200), 20)
    end

    def draw_flask(x, y)
      Gosu.draw_rect(x + 4, y - 1, 4, 3, dark, 20)
      Gosu.draw_rect(x + 2, y + 2, 8, 2, dark, 20)
      Gosu.draw_rect(x, y + 4, 12, 9, dark, 20)
      Gosu.draw_rect(x + 5, y, 2, 3, Gosu::Color.new(255, 220, 220, 230), 20)
      Gosu.draw_rect(x + 1, y + 5, 10, 7, Gosu::Color.new(255, 230, 90, 140), 20)
      Gosu.draw_rect(x + 2, y + 6, 2, 3, Gosu::Color.new(255, 255, 180, 210), 20)
    end

    def draw_poison_icon(x, y)
      g = Gosu::Color.new(255, 110, 220, 90)
      Gosu.draw_rect(x - 1, y, 12, 12, dark, 20)
      Gosu.draw_rect(x + 4, y + 1, 2, 2, g, 20)
      Gosu.draw_rect(x + 3, y + 3, 4, 2, g, 20)
      Gosu.draw_rect(x + 2, y + 5, 6, 4, g, 20)
      Gosu.draw_rect(x + 3, y + 9, 4, 1, g, 20)
      Gosu.draw_rect(x + 3, y + 5, 1, 2, Gosu::Color.new(255, 200, 255, 190), 20)
    end

    # --- helpers -------------------------------------------------------------------
    def haloed(f, text, x, y, z, col)
      hc = rgb(@display.fetch(:price_text_halo_rgb, [20, 14, 12]))
      [[1, 0], [-1, 0], [0, 1], [0, -1]].each { |(dx, dy)| f.draw_text(text, x + dx, y + dy, z, 1, 1, hc) }
      f.draw_text(text, x, y, z, 1, 1, col)
    end

    def rgb(c, a = 255) = Gosu::Color.new(a, c[0], c[1], c[2])
    def gold = @gold ||= rgb(@display.fetch(:hud_level_rgb, [200, 160, 80]))
    def dark = @dark ||= Gosu::Color.new(255, 16, 12, 12)
    def dim = @dim ||= Gosu::Color.new(255, 150, 138, 120)
    def font = @font ||= Gosu::Font.new(14)
    def small_font = @small_font ||= Gosu::Font.new(11)
    def tr(key, fallback) = @strings ? @strings.t(key, fallback) : fallback
  end
end
