module App
  # SIGNAGE (mixed into Renderer — the Game::Loot pattern): everything that
  # tells the player WHERE TO GO and WHAT TO PRESS — the one lock predicate
  # for ways (`way_locked?`), the interact prompt decision + draw, the open
  # ways' breathing glow, the off-camera gold exit arrows, and the pressuring
  # hostile's hollow outline. Extracted byte-inert from renderer.rb (lane
  # `signage`, commit 1) so the renderer stays under its growth ceiling
  # (<= 2000 lines; the cap lands in test/app/line_caps_test.rb at
  # integration). Every draw here is Gosu-only; every
  # DECISION is a pure method testable headlessly (test/app/signage_test.rb,
  # test/app/interact_prompt_test.rb, test/app/pressure_outline_test.rb).
  #
  # Wiring: `Renderer` does `extend Signage::ClassMethods` (the public names
  # `App::Renderer.interact_verb` / `App::Renderer.way_locked?` keep every
  # caller — minimap.rb, map_artifact.rb, the tests — untouched) and
  # `include Signage` (instance methods; `interact_prompt_for` public, the
  # draws private, exactly as before). Constants live on Renderer.
  module Signage
    # E3 b3 (T0 finding b3): the prompt's truth = `World#interact` on the
    # possessed's OWN tile — a station type `interact_station` dispatches (a
    # totem is its deliberate no-op) or a `rope_spot` way (`interact_rope`).
    # Beside a station H does nothing: no prompt. Mirrored from the MAP (the
    # sim is never touched); pure, so test/app/interact_prompt_test.rb proves it.
    INTERACT_STATIONS = %w[bank altar vat seal].freeze

    # --- pressure outline rule (lane `signage` commit 2) ------------------
    # Presentation GEOMETRY: which tiles a straight segment from `from` to `to`
    # crosses, walls only (`map.passable?`), never bodies (the ring reads
    # through bodies). NOT the sim's ranged shot ray (`World#line_clear?`,
    # world.rb — an 8-WAY ray that is false for every pair off a row/column/
    # diagonal; the pressure ring is the full Chebyshev square, 16 tiles at
    # r=2, of which only 8 are 8-way aligned). Plain integer Bresenham with a
    # FIXED tie-break (error term, x-step first): on the 8 aligned offsets it
    # visits EXACTLY the tiles the sim ray visits (a supercover diagonal would
    # also touch the two orthogonal neighbours and get pinched where the sim
    # is not) — test/app/pressure_outline_test.rb (vi) asserts the agreement.
    # Endpoint semantics mirror the sim ray: intermediate tiles are checked,
    # `from` and `to` themselves are not; from == to is open.
    def self.sight_open?(map, from, to)
      x0, y0 = from
      x1, y1 = to
      dx = (x1 - x0).abs
      dy = -(y1 - y0).abs
      sx = x0 < x1 ? 1 : -1
      sy = y0 < y1 ? 1 : -1
      err = dx + dy
      x = x0
      y = y0
      loop do
        return true if x == x1 && y == y1
        e2 = 2 * err
        if e2 >= dy
          break if x == x1
          err += dy
          x += sx
        end
        if e2 <= dx
          break if y == y1
          err += dx
          y += sy
        end
        return true if x == x1 && y == y1
        return false unless map.passable?(x, y)
      end
      true
    end

    def self.chebyshev((ax, ay), (bx, by)) = [(bx - ax).abs, (by - ay).abs].max

    # The one decision for the hostile's hollow outline (pure, headless):
    # outline IFF the sim says the body is `:pressuring` (claimed a ring slot;
    # `World#pressure_role`, untouched) AND it is close enough to BE on the
    # ring — Chebyshev(c, possessed) <= `pressure_outline_max_tiles` (= the
    # sim's `pressure_ring_tiles` + 1, data/balance/threat.json) — AND (unless
    # `pressure_outline_needs_line` is false) no wall cuts the sight between
    # them. A pressuring body stuck 6-9 tiles away behind rock (brasa2
    # `pressure_ring_reads`, a3-stalemate §FINDING) now reads as what it is —
    # a hostile walking — not "I am encircling you". The pocket itself is
    # the sim's (owner candidate (c)); this rule never touches it.
    def self.pressure_outline?(world, c, possessed, max_tiles:, needs_line:)
      return false unless c.faction == :human
      return false unless world.pressure_role(c) == :pressuring
      return false unless possessed && !possessed.dead?
      return false if chebyshev(c.tile, possessed.tile) > max_tiles
      return true unless needs_line
      sight_open?(world.map, c.tile, possessed.tile)
    end

    module ClassMethods
      def interact_verb(map, tile)
        tx, ty = tile
        station = map.station_at(tx, ty)
        return station[:type] if station && INTERACT_STATIONS.include?(station[:type])
        return nil if station # a station H ignores (totem) never shows a prompt
        t = map.transition_at(tx, ty)
        t && t[:type] == "rope_spot" ? "rope_spot" : nil
      end

      # --- T4 way/water state (ONE condition source — the god-view reads
      # these too; the palette-source law extends to state resolution) ----

      # A way is LOCKED while its toll is unpaid (v12 seal law), its
      # required boss_1_defeats count is unmet (T4 fact-gate), or the live
      # pack level sits below its requires_level (T5 sibling). Locked draws
      # the slab — gold means walkable, never a shut way.
      def way_locked?(world, zone_name, t)
        (t[:sealed] && !world.breached?(zone_name, t[:at])) ||
          (t[:requires_defeats] && world.boss_1_defeats < t[:requires_defeats]) ||
          (t[:requires_level] && world.progression.level < t[:requires_level]) || false
      end
    end

    # Pure decision for the prompt: nil | { verb:, key: } for the local seat's
    # possessed body this tick (nil when off, no body, dead, or no verb).
    def interact_prompt_for(world, me = world.possessed(@local_seat))
      return nil unless @display.fetch(:interact_prompt)
      return nil unless me && !me.dead?
      verb = Renderer.interact_verb(world.map, me.tile)
      return nil unless verb
      # landing review 2026-09-06: a seal whose way is already breached DISPATCHES
      # but does nothing (World#interact_seal returns false) - no prompt for it.
      # The prompt promises "H acts here", not "H is routed here".
      if verb == "seal"
        station = world.map.station_at(*me.tile)
        return nil if station && station[:opens] && world.respond_to?(:breached?) && world.breached?(world.zone_name, station[:opens])
      end
      { verb: verb, key: (@bindings&.glyphs(:interact)&.first) || "H" }
    end

    # Instance shim for the draw site: the local seat's possessed body + the
    # two display knobs feed the pure decision above.
    def pressure_outline?(world, c)
      Signage.pressure_outline?(world, c, world.possessed(@local_seat),
                                max_tiles: @display.fetch(:pressure_outline_max_tiles),
                                needs_line: @display.fetch(:pressure_outline_needs_line))
    end

    private

    # PREMIUM v22 pass 8 SIGNAGE: an OPEN way BREATHES - a soft additive
    # gold glow pulsing on a 90-frame cycle, phase per tile so a hub's
    # exits do not blink in lockstep. Shut ways stay dark (the slab +
    # seam already say "door, locked"). Tick-driven: world.frame only.
    # Called from draw_map per transition, inside the camera translate.
    def draw_way_breath(world, map, tx, ty, ts)
      ph = (world.frame + tx * 11 + ty * 7) % 90
      k = ph < 45 ? ph / 45.0 : (90 - ph) / 45.0
      gold_rgb = map.palette[:transition] || [235, 190, 90]
      a = (@display.fetch(:exit_pulse_alpha) * (0.55 + 0.45 * k)).round
      @light.glow_at(tx * ts + ts / 2, ty * ts + ts / 2, 0.6 + 0.3 * k, a, gold_rgb)
      @light.glow_at(tx * ts + ts / 2, ty * ts + ts / 2, 0.28 + 0.1 * k, (a * 0.9).round, [255, 240, 200])
    end

    # Pressuring stance (A2): a thin hollow outline — present, encircling,
    # not swinging. Distinct from the telegraph's FILLED swell and the taunt
    # underline. Outline = state (the glean-pip grammar).
    def draw_pressure_outline(c, x, y, world)
      col = Gosu::Color.new(@pressure_alpha, Renderer::HUMAN_BODY.red, Renderer::HUMAN_BODY.green,
                            Renderer::HUMAN_BODY.blue)
      t = 2
      size = Renderer::SIZE
      Gosu.draw_rect(x - 4, y - 4, size + 8, t, col)
      Gosu.draw_rect(x - 4, y + size + 2, size + 8, t, col)
      Gosu.draw_rect(x - 4, y - 4, t, size + 8, col)
      Gosu.draw_rect(x + size + 2, y - 4, t, size + 8, col)
    end

    # PREMIUM v22 pass 8 SIGNAGE: every OPEN way that is OFF-SCREEN gets a
    # small gold arrowhead clamped to the viewport edge, pointing at it (the
    # ARPG "there is a door that way" grammar). Screen space, above the
    # vignette, under the HUD plate (an arrow that would land under the plate
    # slides below it). Kit pips (allies) are squares; the possession chevron
    # points DOWN over a body; this is a gold arrowhead on the edge pointing
    # OUT - three shapes, three meanings. Pure function of (camera, map).
    def draw_exit_arrows(world)
      return unless @display.fetch(:exit_arrows)
      cam = world.camera(@local_seat)
      map = world.map
      ts = map.tile_size
      vw = cam.view_w
      vh = cam.view_h
      m = @display.fetch(:exit_arrow_margin)
      bottom = vh - @display.fetch(:overlay_strip_height) - m
      cxs = vw / 2.0
      cys = vh / 2.0
      gold = color(map.palette[:transition] || [235, 190, 90])
      edge = Gosu::Color.new(255, 30, 20, 12)
      z = 18
      shown = 0
      map.transitions.each do |t|
        break if shown >= @display.fetch(:exit_arrow_max)
        next if Renderer.way_locked?(world, world.zone_name, t)
        tx, ty = t[:at]
        sx = tx * ts + ts / 2.0 - cam.x
        sy = ty * ts + ts / 2.0 - cam.y
        next if sx.between?(0, vw) && sy.between?(0, vh) # on screen: the pulse carries it
        dx = sx - cxs
        dy = sy - cys
        next if dx.zero? && dy.zero?
        # ray from the view center to the inset rectangle boundary
        kx = dx.zero? ? Float::INFINITY : ((dx.positive? ? vw - m : m) - cxs) / dx
        ky = dy.zero? ? Float::INFINITY : ((dy.positive? ? bottom : m) - cys) / dy
        k = [kx, ky].min
        ax = cxs + dx * k
        ay = cys + dy * k
        # never under the HUD plate (top-left) or the minimap (top-right) - and
        # never INTO the world: slide ALONG the edge (a mid-screen gold triangle
        # read as a stray world marker - brasa2 wall #3)
        px, py, pw, ph = @display.fetch(:hud_plate_rect)
        if ax < px + pw + m && ay < py + ph + m
          if ay <= m + 1
            ax = px + pw + m       # top band: right of the plate, still on the top edge
          else
            ay = py + ph + m       # left band: below the plate, still on the left edge
          end
        end
        if @minimap.enabled?
          mx, my, mw, mh = @minimap.rect(vw)
          if ax > mx - m && ay < my + mh + m
            if ay <= m + 1
              ax = mx - m - @display.fetch(:exit_arrow_gap) # top band: left of the box, still on the top edge
            else
              ay = my + mh + m     # right band: below the box, still on the right edge
            end
          end
        end
        len = Math.sqrt(dx * dx + dy * dy)
        ux = dx / len
        uy = dy / len
        tipx = ax + ux * 6
        tipy = ay + uy * 6
        bx = ax - ux * 6
        by = ay - uy * 6
        wx = -uy * 6
        wy = ux * 6
        Gosu.draw_triangle(tipx + ux * 2, tipy + uy * 2, edge, bx + wx * 1.4 - ux * 2, by + wy * 1.4 - uy * 2, edge,
                           bx - wx * 1.4 - ux * 2, by - wy * 1.4 - uy * 2, edge, z)
        Gosu.draw_triangle(tipx, tipy, gold, bx + wx, by + wy, gold, bx - wx, by - wy, gold, z)
        shown += 1
      end
    end

    # PREMIUM v22 pass 11 / E3 b3: the INTERACT PROMPT — a small bubble over
    # the possessed's head with the interact key glyph + the verb ("H
    # INTERACT"), shown iff `World#interact` reaches the station/rope dispatch
    # on THIS tile (decision: interact_prompt_for; guards like stagger and the
    # drop/loot-first presses are the sim's, not mirrored). Screen space,
    # above the vignette, under the HUD.
    def draw_interact_prompt(world)
      me = world.possessed(@local_seat)
      prompt = interact_prompt_for(world, me)
      return unless prompt
      cam = world.camera(@local_seat)
      glyph = prompt[:key]
      label = tr("overlay.interact", "interact").upcase
      f = hud_font
      gw = f.text_width(glyph)
      lw = f.text_width(label)
      w = gw + lw + 22
      h = 18
      size = Renderer::SIZE
      x = (me.x - cam.x + size / 2.0 - w / 2.0).round
      y = (me.y - cam.y - 30 - art_lift).round
      z = 18
      # bubble: dark plate, BONE hairline (UI, not the pack's orange nor the
      # ways' gold - kits_distinct read the gold cap as a second orange body)
      bone = Gosu::Color.new(255, 200, 190, 170)
      Gosu.draw_rect(x - 1, y - 1, w + 2, h + 2, bone, z)
      Gosu.draw_rect(x, y, w, h, Gosu::Color.new(235, 16, 12, 12), z)
      Gosu.draw_rect(x + w / 2 - 2, y + h, 4, 2, bone, z)
      # key cap: bone square with the glyph in dark
      Gosu.draw_rect(x + 4, y + 3, gw + 6, h - 6, bone, z)
      f.draw_text(glyph, x + 7, y + 2, z, 1, 1, Gosu::Color.new(255, 30, 20, 12))
      f.draw_text(label, x + gw + 14, y + 2, z, 1, 1, Renderer::BANNER)
    end
  end
end
