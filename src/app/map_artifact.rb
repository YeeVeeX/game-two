require "gosu"
require "game/save_state"
require "app/renderer"
require "app/tile_variants"

module App
  # v18 god-view v0 (spec decision 13): the OFFLINE full-map artifact —
  # one PNG from data + save, composed inside a live GL context (`rake
  # map`; Gosu.render law). Every zone's full tile grid renders from the
  # SAME palette/identity data the renderer reads (zone palettes +
  # Renderer::SEAL_SLAB — a structural test pins the source; no second
  # color table exists). In-game map/teleport/editing stay parked.
  #
  # Content resolution (layout/colors/labels/stamps/filename) is PURE and
  # tested headlessly; #compose is the only Gosu-touching method.
  class MapArtifact
    SCALE = 6      # px per tile — layout constant, not a color
    GAP = 14
    HEADER_H = 26
    LABEL_H = 16
    PAD = 10
    COLS = 3
    # Artifact chrome (furniture, not world surfaces — the palette law
    # binds TILE colors to zone data; text/backing are artifact-own).
    CHROME_BG = [12, 10, 14].freeze
    CHROME_TEXT = [225, 218, 205].freeze
    HOME_MARK = [255, 255, 255].freeze # possession-white: "you live here"

    def initialize(data, strings: nil)
      @data = data
      @strings = strings
    end

    # Zones sorted by display label (HUB 1, ZONE 1..5) — deterministic and
    # presentation-meaningful; labels resolve through the strings table
    # (placeholder law: locale-invariant values).
    def panels(world)
      world.zone_maps.map do |name, map|
        { name:, map:, label: label_for(name) }
      end.sort_by { |p| p[:label] }
    end

    def layout(world)
      ps = panels(world)
      cell_w = ps.map { |p| p[:map].cols }.max * SCALE
      cell_h = ps.map { |p| p[:map].rows }.max * SCALE
      entries = ps.each_with_index.map do |p, i|
        x = PAD + (i % COLS) * (cell_w + GAP)
        y = HEADER_H + LABEL_H + (i / COLS) * (cell_h + LABEL_H + GAP)
        p.merge(origin: [x, y], home: p[:name] == world.home_zone)
      end
      rows = (ps.length + COLS - 1) / COLS
      { panels: entries,
        width: PAD * 2 + COLS * cell_w + (COLS - 1) * GAP,
        height: HEADER_H + rows * (cell_h + LABEL_H + GAP) + PAD }
    end

    # Header strip: the persisted counters, flat placeholder register.
    def header_text(world)
      marks = world.pack.members.count(&:marked?)
      "BANKED #{world.pack.banked} · MARKS #{marks} · " \
        "PROVISIONS #{world.pack.provisions} · " \
        "BOSS 1 DEFEATS #{world.boss_1_defeats}"
    end

    # Tile color straight from the zone palette — the structural law.
    # Resolution order mirrors the renderer: transition (sealed = the
    # renderer's own SEAL_SLAB constant, breached/open = gate gold) →
    # station (the draw_stations key ladder) → wall → typed tile (T3:
    # the SAME App::TileVariants derivation the renderer draws, variants
    # included — no second color source, no second selection rule) → floor.
    def cell_rgb(world, name, map, tx, ty)
      t = map.transitions.find { |tr| tr[:at] == [tx, ty] }
      if t
        sealed = t[:sealed] && !world.breached?(name, t[:at])
        return sealed ? seal_slab_rgb : map.palette[:transition]
      end
      s = map.station_at(tx, ty)
      if s
        key = s[:type] == "bank" ? :station : :"station_#{s[:type]}"
        return map.palette[key] || map.palette[:station] || map.palette[:wall]
      end
      return map.palette[:wall] if map.wall?(tx, ty)
      map.palette[typed_ref(map, world, tx, ty) || :floor]
    end

    def typed_ref(map, world, tx, ty)
      @typed_cache ||= {}
      lookup = (@typed_cache[map] ||= App::TileVariants.rects(map, world.tile_registry)
                                                       .to_h { |(x, y, ref)| [[x, y], ref] })
      lookup[[tx, ty]]
    end

    # SEALED/OPEN stamps for every seal-gated way, state from the save.
    def seal_stamps(world)
      world.zone_maps.flat_map do |name, map|
        map.transitions.select { |t| t[:sealed] }.map do |t|
          open = world.breached?(name, t[:at])
          { zone: name, at: t[:at], text: open ? "OPEN" : "SEALED" }
        end
      end
    end

    # Provenance filename: the WORLD's own facts digest + a timestamp.
    def filename(world)
      digest8 = Game::SaveState.digest(world.save_facts)[0, 8]
      format("world_%s_%d.png", digest8, Time.now.to_i)
    end

    # --- the GL half (rake map only; never runs in the suite) --------------

    def compose(world)
      l = layout(world)
      Gosu.render(l[:width], l[:height]) { draw(world, l) }
    end

    private

    def label_for(name)
      fallback = name.tr("_", " ").upcase
      @strings ? @strings.t("zone.#{name}.display_name", fallback) : fallback
    end

    def seal_slab_rgb
      slab = App::Renderer::SEAL_SLAB
      [slab.red, slab.green, slab.blue]
    end

    def color(rgb, alpha = 255) = Gosu::Color.new(alpha, rgb[0], rgb[1], rgb[2])
    def font = @font ||= Gosu::Font.new(12)
    def header_font = @header_font ||= Gosu::Font.new(16)

    def draw(world, l)
      Gosu.draw_rect(0, 0, l[:width], l[:height], color(CHROME_BG))
      header_font.draw_text(header_text(world), PAD, (HEADER_H - 16) / 2, 0,
                            1, 1, color(CHROME_TEXT))
      stamps = seal_stamps(world)
      l[:panels].each do |panel|
        draw_panel(world, panel, stamps)
      end
    end

    def draw_panel(world, panel, stamps)
      map = panel[:map]
      ox, oy = panel[:origin]
      label = panel[:home] ? "#{panel[:label]} · HOME" : panel[:label]
      font.draw_text(label, ox, oy - LABEL_H + 2, 0, 1, 1,
                     color(panel[:home] ? HOME_MARK : CHROME_TEXT))
      map.rows.times do |ty|
        map.cols.times do |tx|
          Gosu.draw_rect(ox + tx * SCALE, oy + ty * SCALE, SCALE, SCALE,
                         color(cell_rgb(world, panel[:name], map, tx, ty)))
        end
      end
      # Home marker: a 2px possession-white frame around the home panel —
      # the landmark probe reads its corner pixel.
      if panel[:home]
        w = map.cols * SCALE
        h = map.rows * SCALE
        [[ox - 2, oy - 2, w + 4, 2], [ox - 2, oy + h, w + 4, 2],
         [ox - 2, oy, 2, h], [ox + w, oy, 2, h]].each do |(x, y, rw, rh)|
          Gosu.draw_rect(x, y, rw, rh, color(HOME_MARK))
        end
      end
      stamps.select { |s| s[:zone] == panel[:name] }.each do |s|
        tx, ty = s[:at]
        rgb = s[:text] == "OPEN" ? map.palette[:transition] : CHROME_TEXT
        font.draw_text(s[:text], ox + tx * SCALE - 8, oy + ty * SCALE - LABEL_H + 2,
                       1, 1, 1, color(rgb))
      end
    end
  end
end
