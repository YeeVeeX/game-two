require "gosu"

module App
  # J-3 stats panel v0 (v19 Lane 4, s74): the STATS screen inside the J-6
  # menu — the pack's progression truths read from the REAL objects the
  # sim runs on. Rendering never computes progression (non-negotiable 3):
  # every number leaves World through the SAME reader the sim hits —
  # damage_for (leveled_damage's pack branch, base = kit attack damage),
  # max_hp (already leveled via sync_max_hp!), special_impact_distances_for
  # (volley_distances) and next_spell_growth_level (threshold logic stays
  # home in Progression). Own module per the J-6/s53 precedent: menu.rb
  # stays lean; #draw is the only Gosu-touching method, #model is pure and
  # headless-tested. World arrives as an ARGUMENT every call (menu D7 law
  # — no world ref is ever held). kills_xp is SESSION-earned by
  # construction (spec P12; not a save fact) — the label says so honestly.
  # Geometry reuses the menu_* display keys (zero new knobs); body names
  # reuse the ratified overlay.vessel.* placeholders (player 1/2/3).
  class StatsPanel
    BONE = [225, 215, 190].freeze # NetplayOverlay text family
    DIM  = [160, 152, 140].freeze # ControlsOverlay label tone
    BG   = [12, 10, 14].freeze    # ledger-panel near-black family

    # Bare-construct fallbacks (Menu VESSEL/GLYPH_FALLBACK law: a
    # strings-less panel stays drawable); canonical names come from
    # data/strings/*.json.
    VESSEL_FALLBACK = { striker: "player 1", blocker: "player 2",
                        lobber: "player 3" }.freeze

    def initialize(display: {}, strings: nil, view_w: 960, view_h: 540)
      @display = display
      @strings = strings
      @view_w = view_w
      @view_h = view_h
    end

    # Pure frame description (#draw renders it verbatim; nil without a
    # world). Sections render in order with a gap between them:
    #   header — pack level + XP into the next level (x/ΔE, MAX at cap —
    #            the net_model format, one expression both surfaces) +
    #            XP earned this session (kills_xp);
    #   bodies — one row per pack member: placeholder name, live/max HP,
    #            leveled attack damage, DEAD marked when dead;
    #   growth — one row per kit that carries special impact distances:
    #            the CURRENT tier honestly (active array) + the next
    #            threshold level when a higher tier exists.
    def model(world)
      return nil unless world
      prog = world.progression
      { title: tr("menu.stats", "STATS"),
        hint: tr("menu.hint", "ESC: CLOSE"),
        header: header_rows(prog),
        bodies: world.pack.members.map { |m| body_row(m, prog) },
        growth: growth_rows(world.pack.members, prog) }
    end

    def draw(world)
      m = model(world)
      return unless m
      sections = [m[:header], m[:bodies].map { |b| b[:text] }, m[:growth]].reject(&:empty?)
      rows = sections.sum(&:size) + (sections.size - 1) # one gap row between sections
      w = panel_w
      h = pad * 2 + title_h + rows * row_h + hint_h
      x = (@view_w - w) / 2
      y = (@view_h - h) / 2
      Gosu.draw_rect(x, y, w, h, Gosu::Color.new(panel_alpha, *BG), 50)
      title_font.draw_text(m[:title], x + (w - title_font.text_width(m[:title])) / 2,
                           y + pad, 50, 1, 1, Gosu::Color.new(255, *BONE))
      ty = y + pad + title_h
      m[:header].each do |row|
        row_font.draw_text(row, x + pad * 2, ty, 50, 1, 1, Gosu::Color.new(255, *BONE))
        ty += row_h
      end
      ty += row_h
      m[:bodies].each do |body|
        tone = body[:dead] ? DIM : BONE
        row_font.draw_text(body[:text], x + pad * 2, ty, 50, 1, 1, Gosu::Color.new(255, *tone))
        ty += row_h
      end
      unless m[:growth].empty?
        ty += row_h
        m[:growth].each do |row|
          row_font.draw_text(row, x + pad * 2, ty, 50, 1, 1, Gosu::Color.new(255, *BONE))
          ty += row_h
        end
      end
      hint_font.draw_text(m[:hint], x + pad * 2, y + h - hint_h, 50, 1, 1,
                          Gosu::Color.new(255, *DIM))
    end

    private

    def header_rows(prog)
      xp = prog.level >= prog.level_cap ? "MAX" : "#{prog.xp}/#{prog.delta_e(prog.level + 1)}"
      ["#{tr('hud.level', 'LEVEL')} #{prog.level} · XP #{xp}",
       "#{tr('stats.session_xp', 'SESSION XP')} #{prog.kills_xp}"]
    end

    def body_row(member, prog)
      text = "#{vessel(member.kit_name)} · HP #{member.hp}/#{member.max_hp} · " \
             "#{tr('stats.damage', 'DMG')} #{prog.damage_for(member.kit[:attack][:damage])}"
      text += " · #{tr('stats.dead', 'DEAD')}" if member.dead?
      { text:, dead: member.dead? }
    end

    def growth_rows(members, prog)
      members.filter_map do |m|
        base = m.kit.dig(:special, :impact_distances)
        next unless base
        row = "#{vessel(m.kit_name)} · #{tr('stats.reach', 'REACH')} " +
              prog.special_impact_distances_for(m.kit_name, base:).join("-")
        nxt = prog.next_spell_growth_level(m.kit_name)
        nxt ? "#{row} · #{tr('stats.next', 'NEXT')} L#{nxt}" : row
      end
    end

    def vessel(kit_name)
      tr("overlay.vessel.#{kit_name}", VESSEL_FALLBACK.fetch(kit_name, kit_name.to_s))
    end

    def tr(key, fallback) = @strings ? @strings.t(key, fallback) : fallback

    def panel_w = @display.fetch(:menu_sheet_w)
    def panel_alpha = @display.fetch(:menu_panel_alpha)
    def row_h = @display.fetch(:menu_sheet_row_h)
    def title_h = @display.fetch(:menu_title_h)
    def hint_h = @display.fetch(:menu_hint_h)
    def pad = @display.fetch(:menu_pad)
    def title_font = @title_font ||= Gosu::Font.new(@display.fetch(:menu_title_font_size), bold: true)
    def row_font = @row_font ||= Gosu::Font.new(@display.fetch(:menu_row_font_size))
    def hint_font = @hint_font ||= Gosu::Font.new(@display.fetch(:menu_hint_font_size))
  end
end
