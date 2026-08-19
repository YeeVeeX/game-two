require "app/controls_overlay"
require "app/kill_pop"
require "app/stamp"
require "app/writ"
require "app/zone_identity"

module App
  # Draws the world sim with Gosu primitives. Flat-rect minimalism: kit
  # identity is COLOR + silhouette behavior; the possessed body is brightened
  # and white-ringed. Carried vision-critique fixes live here: facing notch,
  # crimson (never white) pack hurt-flash, two-tone telegraph distinct from
  # gate gold, corpses persist, attack lunge. Palettes from data/zones/*.json.
  class Renderer
    HUMAN_BODY = Gosu::Color.new(255, 205, 198, 180) # pale bone
    KIT_BODY = Hash.new(HUMAN_BODY).merge(
      striker:      Gosu::Color.new(255, 235, 120, 40),
      blocker:      Gosu::Color.new(255, 190, 80, 35),
      lobber:       Gosu::Color.new(255, 225, 170, 90),
      rusher_hater: HUMAN_BODY
    ).freeze

    POSSESSED_RING = Gosu::Color.new(255, 255, 255, 255)
    ALLY_DIM       = Gosu::Color.new(120, 10, 8, 12)  # overlay that dims unpossessed kin
    PACK_HURT      = Gosu::Color.new(255, 200, 30, 30) # crimson, never white (critique)
    HUMAN_HURT     = Gosu::Color.new(255, 255, 80, 80)
    TELEGRAPH_EDGE = Gosu::Color.new(255, 235, 60, 40)  # hot red border...
    TELEGRAPH_CORE = Gosu::Color.new(255, 250, 210, 60) # ...around the yellow core (≠ gate gold)
    SLASH          = Gosu::Color.new(220, 255, 255, 255)
    WINDUP         = Gosu::Color.new(90, 255, 255, 255)
    SPECIAL_WINDUP = Gosu::Color.new(120, 255, 190, 90)
    SPECIAL_ACTIVE = Gosu::Color.new(235, 255, 225, 150)
    LUNGE_WINDUP   = Gosu::Color.new(110, 255, 125, 45)
    LUNGE_ACTIVE   = Gosu::Color.new(245, 255, 245, 210)
    PROJECTILE     = Gosu::Color.new(255, 250, 235, 170)
    VOLLEY_EDGE    = Gosu::Color.new(220, 245, 125, 35)
    VOLLEY_CORE    = Gosu::Color.new(235, 255, 220, 150)
    MARK_GLYPH     = Gosu::Color.new(255, 75, 235, 205)
    TAUNT_RUST     = Gosu::Color.new(255, 190, 80, 35) # blocker body color — ownership
    DROP_CORE      = Gosu::Color.new(255, 205, 70, 225) # glean drops — magenta/violet, owned by no other element
    DROP_BAND1     = Gosu::Color.new(255, 225, 105, 130) # mid-band drops — warm rose (v11 depth rider)
    DROP_BAND2     = Gosu::Color.new(255, 240, 170, 60)  # deep-band drops — ember/gold + glow (v11 depth rider)
    NOTCH          = Gosu::Color.new(255, 20, 14, 12)
    HP_BACK        = Gosu::Color.new(255, 50, 20, 30)
    HP_DEAD        = Gosu::Color.new(255, 35, 25, 30)
    WIPE_VEIL      = Gosu::Color.new(170, 8, 4, 10)
    BANNER         = Gosu::Color.new(255, 225, 215, 190)
    STAGGER_VEIL   = Gosu::Color.new(90, 20, 8, 8)
    LEDGER_NEG     = Gosu::Color.new(255, 200, 40, 40) # wipe-red family
    LEDGER_DARK    = Gosu::Color.new(255, 26, 13, 30)  # expiry-flash family
    BEAT_PANEL     = [10, 6, 12].freeze                 # near-black panel RGB
    BEAT_FLASH     = [255, 240, 220].freeze             # warm-white arrival flash RGB
    BEAT_GLYPH     = 20                                 # tally glyph square, px
    BEAT_GLYPH_BIG = 32                                 # solo-line glyph, matches 42pt type
    BEAT_LINE_GAP  = 6
    BEAT_PAD_X     = 24                                 # panel padding around the block
    BEAT_PAD_Y     = 14

    CUE_OK = Gosu::Color.new(230, 240, 220, 150)
    CUE_REFUSED = Gosu::Color.new(230, 200, 60, 50)
    SEAL_SLAB = Gosu::Color.new(255, 20, 16, 24)   # sealed door: near-wall dark
    BREACH_GOLD = Gosu::Color.new(255, 235, 190, 90) # the writ line, gate-gold
    GOD_MARK = Gosu::Color.new(230, 235, 220, 170)
    # Cause-keyed why-they-turned cues. The gate critic arbitrated the first
    # palette: proximity's pale RGB(200,200,190) vanished against HUMAN_BODY,
    # and lowhp rendered red while the check reads "yellow=wounded-prey" —
    # lemon (not telegraph-core golden) and cool blue-pale keep every cue off
    # the palette of the body it floats over.
    RETARGET_CUE = {
      hate: Gosu::Color.new(230, 150, 60, 40),
      lowhp: Gosu::Color.new(230, 235, 235, 90),
      proximity: Gosu::Color.new(230, 180, 210, 250),
    }.freeze

    SIZE = Game::Creature::SIZE

    # Presentation timing/placement rides data/display.json (zone_banner_frames
    # precedent) — the fetch defaults only keep a bare Renderer.new drawable.
    # strings: Core::Strings resolver (v13 i18n) — RENDER-time only; the
    # harness constructs it pinned to "en" (replay comparability law).
    def initialize(display: {}, strings: nil, bindings: nil, local_seat: 1)
      @display = display
      @strings = strings
      @pressure_alpha = @display.fetch(:pressure_outline_alpha, 140)
      # v17 renderer seam (Codex fold #7): every possessed/camera read goes
      # through the LOCAL seat — default 1, so single-player output is
      # byte-identical by default.
      @local_seat = local_seat
      @controls_overlay = ControlsOverlay.new(display:, strings:, bindings:, local_seat:)
    end

    def draw(world)
      cam = world.camera(@local_seat)
      Gosu.translate(world.feel.shake_x - cam.x, world.feel.shake_y - cam.y) do
        draw_map(world)
        draw_impacts(world)
        draw_corpses(world)
        draw_stations(world)
        draw_drops(world)
        draw_corpse_loads(world)
        draw_expiry_flashes(world)
        draw_seal_marks(world)
        draw_respawn_tells(world)
        world.humans.each { |h| draw_creature(h, world) }
        world.pack.living.each { |m| draw_creature(m, world) }
        world.projectiles.each { |p| draw_projectile(p) }
        draw_taunt_pulses(world)
        draw_kill_pops(world)
        draw_chant_rings(world)
        draw_mark(world)
        draw_station_ledger(world)
      end
      draw_writ_veil(world)
      draw_hud(world)
      # Strip BEFORE edge pips (their bottom clamp lands inside the strip
      # band — an off-screen ally's pip must stay visible ON the strip) and
      # BEFORE the veils in call order (all default z: the wipe veil dims
      # it, ledger beats at z=29-31 stay above everything).
      @controls_overlay.draw(world)
      draw_edge_pips(world)
      draw_banner(world) if world.banner?
      draw_breach_line(world)
      draw_wipe_overlay(world) if world.states.current == :nest_respawn
      # AFTER the wipe overlay BY DESIGN: the alpha-170 veil would bury the
      # recap, and the recap legible through the veil is the point (spec:
      # one owned draw-order decision; review M1-codefit).
      draw_ledger_beat(world)
      draw_stagger_veil(world) if world.possessed(@local_seat)&.staggered?
    end

    def draw_impacts(world)
      ts = world.map.tile_size
      world.impacts.each do |impact|
        delay = impact[:owner].kit[:special][:delay_frames]
        size = 6 + (impact[:frames_left].fdiv(delay) * 10).round
        impact[:tiles].each do |(tx, ty)|
          x = tx * ts
          y = ty * ts
          Gosu.draw_rect(x + 4, y + 4, ts - 8, 3, VOLLEY_EDGE)
          Gosu.draw_rect(x + 4, y + ts - 7, ts - 8, 3, VOLLEY_EDGE)
          Gosu.draw_rect(x + 4, y + 7, 3, ts - 14, VOLLEY_EDGE)
          Gosu.draw_rect(x + ts - 7, y + 7, 3, ts - 14, VOLLEY_EDGE)
          inset = (ts - size) / 2.0
          Gosu.draw_rect(x + inset, y + inset, size, size, VOLLEY_CORE)
        end
      end
    end

    def draw_mark(world)
      target = world.marked_target
      return unless target && !target.dead?
      x = target.x - 5
      y = target.y - 5
      span = SIZE + 10
      arm = 8
      thick = 3
      [[x, y], [x + span - arm, y], [x, y + span - thick],
       [x + span - arm, y + span - thick]].each do |(cx, cy)|
        Gosu.draw_rect(cx, cy, arm, thick, MARK_GLYPH)
      end
      [[x, y], [x + span - thick, y], [x, y + span - arm],
       [x + span - thick, y + span - arm]].each do |(cx, cy)|
        Gosu.draw_rect(cx, cy, thick, arm, MARK_GLYPH)
      end
      Gosu.draw_rect(target.x + SIZE / 2 - 2, target.y - 9, 4, 4, MARK_GLYPH)
    end

    # v18 sustain cues (presentation spec): ONLY the provision kinds carry
    # a text line — every pre-v18 cue kind stays ring/X-bar-only, so the
    # walled captures cannot move (7iii family; the canary sweep is the
    # proof). Pure content resolution; EN fallbacks keep a strings-less
    # construct drawable (the ControlsOverlay precedent).
    CUE_TEXT_FALLBACK = { provision_bought: "PROVISION BOUGHT",
                          provision_used: "PROVISION USED",
                          provision_refused: "REFUSED" }.freeze

    def station_cue_text(kind)
      fallback = CUE_TEXT_FALLBACK[kind]
      return nil unless fallback
      @strings ? @strings.t("cue.#{kind}", fallback) : fallback
    end

    # Flywheel fix (2026-08-19, verified vs clip low_quay_run 104223
    # frames v_000729/2492/3836): a kills-only window resolves with zero
    # loot movement and rendered a solo "+0" for 150 frames — a reward
    # beat carrying no information trains players to ignore the slot
    # that later carries real "+N" (critique issue 5). All-zero non-wipe
    # beats are suppressed at DRAW time (the sim record and the
    # fight_resolved event are untouched — renderer-only, digest-blind).
    # Wipe recaps keep their "+0 held" format by design (praised; the
    # veil is the punch and the zeros are the receipt).
    def self.silent_beat?(beat)
      beat[:kind] != :wipe && beat[:gained].zero? &&
        beat[:pip_amount].zero? && beat[:dark_amount].zero?
    end

    private

    def color(rgb, alpha = 255) = Gosu::Color.new(alpha, rgb[0], rgb[1], rgb[2])

    def draw_map(world)
      map = world.map
      ts = map.tile_size
      floor = color(map.palette[:floor])
      grid = color(map.palette[:grid])
      wall = color(map.palette[:wall])
      transition = color(map.palette[:transition])

      Gosu.draw_rect(0, 0, map.pixel_width, map.pixel_height, floor)
      map.rows.times do |ty|
        map.cols.times do |tx|
          Gosu.draw_rect(tx * ts, ty * ts, ts, ts, wall) if map.wall?(tx, ty)
        end
      end
      (0..map.cols).each { |tx| Gosu.draw_rect(tx * ts, 0, 1, map.pixel_height, grid) }
      (0..map.rows).each { |ty| Gosu.draw_rect(0, ty * ts, map.pixel_width, 1, grid) }
      # v16 (b): identity channels — motif texture + authored landmarks
      # after the grid (floor detail), under transitions (gold stays law).
      # Geometry memoized per map: pure function of immutable zone config.
      motif, decor = identity_rects(map)
      unless motif.empty?
        mcol = color(map.palette[:motif_rgb])
        motif.each { |(x, y, w, h)| Gosu.draw_rect(x, y, w, h, mcol) }
      end
      decor.each { |(x, y, w, h, rgb, a)| Gosu.draw_rect(x, y, w, h, color(rgb, a)) }
      map.transitions.each do |t|
        tx, ty = t[:at]
        if t[:sealed] && !world.breached?(world.zone_name, t[:at])
          # A sealed door is NOT gold — gold means walkable. Dark slab with
          # a thin gold seam: shut, but a door (v12 presentation spec 1).
          Gosu.draw_rect(tx * ts + 1, ty * ts + 1, ts - 2, ts - 2, SEAL_SLAB)
          Gosu.draw_rect(tx * ts + ts / 2 - 1, ty * ts + 4, 2, ts - 8, transition)
        else
          Gosu.draw_rect(tx * ts + 3, ty * ts + 3, ts - 6, ts - 6, transition)
        end
      end
      # Ambient tint LAST over the whole map quad — a faint colored light
      # the zone sits in; actors draw after (untinted — W6, bodies anchor).
      if (amb = App::ZoneIdentity.ambient(map))
        Gosu.draw_rect(0, 0, map.pixel_width, map.pixel_height,
                       color(amb[0, 3], amb[3]))
      end
    end

    def identity_rects(map)
      @identity_cache ||= {}
      @identity_cache[map] ||= [App::ZoneIdentity.motif_rects(map),
                                App::ZoneIdentity.decor_rects(map)]
    end

    # Drops read as PLACE (v11 rider): size is the primary depth channel —
    # band 0 keeps the pre-v11 magenta 10/14px (amount step), band 1 warm
    # rose 16px, band 2 ember/gold 18px behind a faint glow halo. The band
    # rides the record (stamped at spawn, like decay_frames) — no gradient
    # read here. Alpha still fades over the final third of the decay clock.
    def draw_drops(world)
      ts = world.map.tile_size
      world.drops.each do |d|
        outer, size, inner =
          case d[:band] || 0
          when 2 then [DROP_BAND2, 18, [255, 235, 180]] # bright ember core
          when 1 then [DROP_BAND1, 16, [255, 215, 220]] # pale rose core
          else        [DROP_CORE, d[:amount] >= 2 ? 14 : 10, [250, 225, 255]]
          end
        frac = d[:frames_left].fdiv(d[:decay_frames])
        alpha = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
        tx, ty = d[:tile]
        inset = (ts - size) / 2.0
        if (d[:band] || 0) == 2 # the glow ring: a wider, faint halo
          halo = size + 8
          hi = (ts - halo) / 2.0
          Gosu.draw_rect(tx * ts + hi, ty * ts + hi, halo, halo,
                         Gosu::Color.new((alpha * 0.35).round, outer.red, outer.green, outer.blue))
        end
        Gosu.draw_rect(tx * ts + inset, ty * ts + inset, size, size,
                       Gosu::Color.new(alpha, outer.red, outer.green, outer.blue))
        Gosu.draw_rect(tx * ts + inset + 3, ty * ts + inset + 3, size - 6, size - 6,
                       Gosu::Color.new(alpha, *inner))
      end
    end

    # Glean pip (D1): hollow magenta OUTLINE on the CONTAINER's tile —
    # outline because a free drop is a filled square and the two render
    # concentric when a drop sits on a loaded corpse (review DS-4);
    # tile-anchored because a knockback kill can leave the corpse rect a
    # tile away from the interact tile (review CF-3). Dim while settling,
    # snapping to full on lootable (the ready tell, review FN-5); fades
    # over the term's final third like drops and the taunt underline.
    def draw_corpse_loads(world)
      ts = world.map.tile_size
      world.corpse_loads.each do |c|
        frac = c[:term_left].fdiv(c[:term])
        alpha = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
        alpha = (alpha * c[:settle_alpha]).round if c[:settle_left].positive?
        col = Gosu::Color.new(alpha, DROP_CORE.red, DROP_CORE.green, DROP_CORE.blue)
        size = 16
        t = 3
        x = c[:tile][0] * ts + (ts - size) / 2.0
        y = c[:tile][1] * ts + (ts - size) / 2.0
        Gosu.draw_rect(x, y, size, t, col)
        Gosu.draw_rect(x, y + size - t, size, t, col)
        Gosu.draw_rect(x, y, t, size, col)
        Gosu.draw_rect(x + size - t, y, t, size, col)
      end
    end

    # Term expiry read as an EVENT, not a disappearance: one brief dark
    # flash on the tile (per-zone records; only the current zone draws).
    def draw_expiry_flashes(world)
      ts = world.map.tile_size
      world.expiry_flashes.each do |f|
        a = (200 * f[:frames_left].fdiv(f[:frames])).round
        tx, ty = f[:tile]
        Gosu.draw_rect(tx * ts, ty * ts, ts, ts, Gosu::Color.new(a, 12, 6, 14))
      end
    end

    # v14 respawn tell (spec Presentation 2): a growing pale green-white
    # ground mark drawn UNDER bodies — "something arrives HERE". The
    # outline brightens and the core fill grows with progress; a
    # materialize-deferred tell (frames_left 0) holds at full intensity
    # (deferral is honest waiting, W3). Pure function of the accessor
    # record — replay determinism holds. The pale green-white family is
    # its own: distinct from volley orange, telegraph red/yellow, gate
    # gold, taunt rust, and the magenta drop/pip grammar.
    def draw_respawn_tells(world)
      ts = world.map.tile_size
      world.respawn_tells.each do |tell|
        progress = 1.0 - tell[:frames_left].fdiv(tell[:total])
        tx, ty = tell[:tile]
        x = tx * ts
        y = ty * ts
        ec = tell_edge_rgb
        edge = Gosu::Color.new((tell_max_alpha * (0.45 + 0.55 * progress)).round,
                               ec[0], ec[1], ec[2])
        t = 2
        Gosu.draw_rect(x + 2, y + 2, ts - 4, t, edge)
        Gosu.draw_rect(x + 2, y + ts - 2 - t, ts - 4, t, edge)
        Gosu.draw_rect(x + 2, y + 2, t, ts - 4, edge)
        Gosu.draw_rect(x + ts - 2 - t, y + 2, t, ts - 4, edge)
        # Core fill: grows from a seed toward the outline; the subtle pulse
        # rides frames_left (sim state), so it freezes steady when held.
        pulse = 1.0 + 0.1 * Math.sin(tell[:frames_left] * tell_pulse_speed / 10.0)
        size = [(4 + progress * (ts - 12)) * pulse, ts - 6].min
        inset = (ts - size) / 2.0
        cc = tell_core_rgb
        Gosu.draw_rect(x + inset, y + inset, size, size,
                       Gosu::Color.new((tell_max_alpha * (0.25 + 0.75 * progress)).round,
                                       cc[0], cc[1], cc[2]))
      end
    end

    def tell_edge_rgb = @display.fetch(:respawn_tell_edge_rgb, [180, 220, 200])
    def tell_core_rgb = @display.fetch(:respawn_tell_core_rgb, [220, 240, 230])
    def tell_max_alpha = @display.fetch(:respawn_tell_max_alpha, 180)
    def tell_pulse_speed = @display.fetch(:respawn_tell_pulse_speed, 3)

    # Station fixture: palette-driven block with a hollow center — reads as
    # a PLACE, not a wall (walls are solid) and not a gate (gates are gold).
    # Per-type palette keys (Task 7): bank keeps :station, altar/vat get their
    # own (station_altar, station_vat) — three distinct interactable reads.
    def draw_stations(world)
      ts = world.map.tile_size
      world.map.stations.each do |s|
        tx, ty = s[:at]
        x = tx * ts
        y = ty * ts
        key = s[:type] == "bank" ? :station : :"station_#{s[:type]}"
        fill = world.map.palette[key] || world.map.palette[:station] || world.map.palette[:wall]
        Gosu.draw_rect(x + 2, y + 2, ts - 4, ts - 4, color(fill))
        Gosu.draw_rect(x + 8, y + 8, ts - 16, ts - 16, color(world.map.palette[:floor]))
      end
      draw_station_cue(world)
    end

    # Banked total shows ONLY at the station, only when the possessed is
    # near (quiet-HUD law: the world HUD never carries the score). Radius 3,
    # not 2: GridWalker commits the tile at step START while the pixel tween
    # trails, so a body that LOOKS adjacent can already be 3 tiles away —
    # the numeral must read whenever the player would say "I'm at it".
    # D1b: altar/vat get their price prefixed with "-" in the same slot.
    LEDGER_RADIUS_TILES = 3

    def draw_station_ledger(world)
      # v17 waiting-for-body: no body, no instruments (the netplay overlay
      # carries the NO BODY line). Guard never taken single-player.
      return unless (body = world.possessed(@local_seat))
      world.map.stations.each do |s|
        tx, ty = s[:at]
        px, py = body.tile
        next unless [(tx - px).abs, (ty - py).abs].max <= LEDGER_RADIUS_TILES
        ts = world.map.tile_size
        if s[:type] == "bank"
          text = world.pack.banked.to_s
          hud_font.draw_text(text, tx * ts + (ts - hud_font.text_width(text)) / 2,
                             ty * ts - 18, 10, 1, 1, DROP_CORE)
        else
          price = world.station_price(s)
          next unless price && price.positive?
          text = "-#{price}"
          hud_font.draw_text(text, tx * ts + (ts - hud_font.text_width(text)) / 2,
                             ty * ts - 18, 10, 1, 1, DROP_CORE)
        end
      end
    end

    # Station cue (D1b): success kinds flash a bright 1-tile pulse ring at
    # the transaction's own fixture (the cue carries its tile); :refused
    # draws a short dark-red X-bar.
    def draw_station_cue(world)
      cue = world.station_cue
      return unless cue
      ts = world.map.tile_size
      tx, ty = cue[:at]
      x = tx * ts
      y = ty * ts
      if cue[:kind] == :refused
        # Dark-red X-bar
        Gosu.draw_rect(x + 6, y + ts / 2 - 2, ts - 12, 4, CUE_REFUSED)
        Gosu.draw_rect(x + ts / 2 - 2, y + 6, 4, ts - 12, CUE_REFUSED)
      elsif cue[:kind] == :provision_refused
        # v18 sustain refusal: its OWN kind (add-only — the walled :refused
        # draw above is untouched). The presser STANDS on the refusing
        # tile, so the X-bar rides z=9 (above bodies, below the z=10 text
        # line) and the text names the beat — a refusal must never read as
        # nothing (decision 9: cue, never a silent eat).
        Gosu.draw_rect(x + 6, y + ts / 2 - 2, ts - 12, 4, CUE_REFUSED, 9)
        Gosu.draw_rect(x + ts / 2 - 2, y + 6, 4, ts - 12, CUE_REFUSED, 9)
        if (text = station_cue_text(cue[:kind]))
          hud_font.draw_text(text, x + (ts - hud_font.text_width(text)) / 2,
                             y - 32, 10, 1, 1, CUE_REFUSED)
        end
      else
        # Bright 1-tile pulse ring
        t = 3
        Gosu.draw_rect(x, y, ts, t, CUE_OK)
        Gosu.draw_rect(x, y + ts - t, ts, t, CUE_OK)
        Gosu.draw_rect(x, y, t, ts, CUE_OK)
        Gosu.draw_rect(x + ts - t, y, t, ts, CUE_OK)
        # v18 provision kinds add a functional text line above the tile —
        # one row clear of the station-ledger line at y-18, so a buy cue
        # never collides with the bank's banked count (pilot capture
        # caught the overlap). Pre-v18 kinds resolve nil and keep their
        # exact ring-only draw.
        if (text = station_cue_text(cue[:kind]))
          hud_font.draw_text(text, x + (ts - hud_font.text_width(text)) / 2,
                             y - 32, 10, 1, 1, CUE_OK)
        end
      end
    end

    # Bodies stay where they fell and fade out (critique: vanishing kills
    # erase the fight's history).
    def draw_corpses(world)
      world.corpses.each do |c|
        alpha =
          if c[:container_id]
            140 # loaded: held at full strength while the container lives
          else
            age = world.frame - c[:at_frame]
            (140 * (1.0 - age.fdiv(Game::World::CORPSE_FADE_FRAMES))).clamp(0, 140).round
          end
        base = c[:faction] == :human ? [140, 135, 125] : [150, 80, 40]
        Gosu.draw_rect(c[:x] + 4, c[:y] + 10, SIZE - 8, SIZE - 14,
                       Gosu::Color.new(alpha, *base))
      end
    end

    def draw_creature(c, world)
      lx, ly = lunge_offset(c)
      x = c.x + lx
      y = c.y + ly
      if c.equal?(world.possessed(@local_seat))
        Gosu.draw_rect(x - 3, y - 3, SIZE + 6, SIZE + 6, POSSESSED_RING)
      elsif c.faction == :pack && world.controlled?(c)
        # v17 decision 10: seat identity is RINGS ONLY — the partner's body
        # carries the second color (display.json), labels untouched.
        # Unreachable single-seat (the only controlled body IS possessed).
        Gosu.draw_rect(x - 3, y - 3, SIZE + 6, SIZE + 6, partner_ring)
      end
      if c.faction == :pack && c.marked?
        Gosu.draw_rect(x + SIZE / 2 - 4, y - 10, 8, 8, GOD_MARK)
        Gosu.draw_rect(x + SIZE / 2 - 2, y - 8, 4, 4, color(world.map.palette[:floor]))
      end
      draw_taunt_underline(c, x, y) if c.faction == :human && c.taunted_target
      # v15 seizure state: the exact mirror of the taunt underline in the
      # chant's deep blue — rust says "they come to you", blue says "your
      # flesh goes to him". Pack-only slot: no collision with taunt (human).
      draw_seized_underline(c, x, y) if c.faction == :pack && c.seized_by
      draw_nameplate(c, x, y) if c.faction == :human && c.kit[:seize]
      if c.faction == :human && (cue = c.retarget_cue)
        Gosu.draw_rect(x + SIZE / 2 - 4, y - 10, 8, 8, RETARGET_CUE.fetch(cue[:cause]))
      end
      draw_pressure_outline(c, x, y, world) if c.faction == :human &&
                                                world.pressure_role(c) == :pressuring
      if c.faction == :human && c.telegraphing?
        swell = 8
        Gosu.draw_rect(x - swell / 2, y - swell / 2, SIZE + swell, SIZE + swell, TELEGRAPH_EDGE)
        Gosu.draw_rect(x - 2, y - 2, SIZE + 4, SIZE + 4, TELEGRAPH_CORE)
        # The body stays visible INSIDE the flare: two adjacent telegraphing
        # humans otherwise read as an ownerless ground-tile pattern,
        # indistinguishable from Volley target tiles (gate critique finding).
        Gosu.draw_rect(x + 5, y + 5, SIZE - 10, SIZE - 10, HUMAN_BODY)
      else
        Gosu.draw_rect(x, y, SIZE, SIZE, body_color(c, world))
        Gosu.draw_rect(x, y, SIZE, SIZE, ALLY_DIM) if ally?(c, world)
        # v16 (d): the seized body carries visual WEIGHT — darkened toward
        # the chant's deep blue for the whole hold (underline keeps the
        # clock; this makes the state read at body scale).
        if c.faction == :pack && c.seized_by
          Gosu.draw_rect(x, y, SIZE, SIZE,
                         Gosu::Color.new(@display.fetch(:seized_weight_alpha, 110), *seized_rgb))
        end
      end
      draw_facing_notch(c, x, y)
      draw_attack(c, world.map.tile_size) if c.faction == :pack
    end

    def ally?(c, world) = c.faction == :pack && !c.equal?(world.possessed(@local_seat))

    def body_color(c, world)
      if c.faction == :pack && c.iframes? && (world.frame / 3).even?
        PACK_HURT
      elsif c.faction == :human && c.hurt?
        HUMAN_HURT
      elsif c.faction == :pack && c.hurt? && (world.frame / 3).even?
        PACK_HURT
      else
        KIT_BODY[c.kit_name]
      end
    end

    # Which way a body faces must be readable at a glance (critique fix):
    # a dark notch on the facing edge.
    def draw_facing_notch(c, x, y)
      fx, fy = c.facing
      n = 6
      nx = fx.positive? ? x + SIZE - n : x
      ny = fy.positive? ? y + SIZE - n : y
      if fx.zero? # vertical facing: notch spans centered horizontally
        Gosu.draw_rect(x + SIZE / 2 - n / 2, ny, n, n, NOTCH)
      elsif fy.zero?
        Gosu.draw_rect(nx, y + SIZE / 2 - n / 2, n, n, NOTCH)
      else # diagonal: corner notch
        Gosu.draw_rect(nx, ny, n, n, NOTCH)
      end
    end

    # Weight shifts into the swing (critique fix): sink back on windup,
    # lunge forward on active. Draw-only — tiles never move.
    def lunge_offset(c)
      return [0, 0] unless c.faction == :pack
      return [0, 0] if c.current_action == :special
      fx, fy = c.facing
      case c.attack_state
      when :windup then [-3 * fx, -3 * fy]
      when :active then [6 * fx, 6 * fy]
      else [0, 0]
      end
    end

    def draw_attack(c, ts)
      return unless %i[windup active].include?(c.attack_state)
      # Bright lunge family for the dash arc AND the striker's ring burst
      # (v13, review-confirmed): without it the whirlwind renders in the
      # blocker's SPECIAL colors on the same 8-tile pattern and two specials
      # read as one (check 14, three-specials-three-visuals).
      if c.current_action == :special &&
         (c.action_config[:arc] == "dash" || c.kit_name == :striker)
        col = c.attack_state == :windup ? LUNGE_WINDUP : LUNGE_ACTIVE
        inset = c.attack_state == :windup ? 10 : 6
        c.action_tiles.each do |(tx, ty)|
          Gosu.draw_rect(tx * ts + inset, ty * ts + inset,
                         ts - inset * 2, ts - inset * 2, col)
        end
        return
      end
      col =
        if c.current_action == :special
          c.attack_state == :windup ? SPECIAL_WINDUP : SPECIAL_ACTIVE
        else
          c.attack_state == :windup ? WINDUP : SLASH
        end
      c.action_tiles.each do |(tx, ty)|
        Gosu.draw_rect(tx * ts + 4, ty * ts + 4, ts - 8, ts - 8, col)
      end
    end

    def draw_projectile(p)
      Gosu.draw_rect(p.x, p.y, Game::Projectile::SIZE, Game::Projectile::SIZE, PROJECTILE)
    end

    # Taunt victim tell (A0.6): rust underline pinned BELOW the telegraph
    # swell (which floods to y+SIZE+4 in near-identical hot red — the offset
    # is what keeps the tell alive in the mid-attack frame). Also clear of
    # the mark reticle's bottom corner brackets (draw_mark, which extend to
    # y+SIZE+5 when a human is BOTH marked and taunted — a real combo, focus
    # the taunted target — the two persistent tells crowded into one 8px band
    # and neither read; +9 leaves a clean 4px gap). Alpha fades over the
    # lock's final third: the snap back to free targeting is telegraphed
    # with the same grammar drop decay taught.
    def draw_taunt_underline(c, x, y)
      duration = c.taunted_target.kit[:special][:challenge][:duration_frames]
      frac = c.taunt_frames.fdiv(duration)
      alpha = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
      Gosu.draw_rect(x - 2, y + SIZE + 9, SIZE + 4, 3,
                     Gosu::Color.new(alpha, TAUNT_RUST.red, TAUNT_RUST.green, TAUNT_RUST.blue))
    end

    # v16 (d): the writ-frame — while a chant runs the court draws its
    # writ around the chanter: outside darkens hard, inside stays FULLY
    # readable (dread + the fairness ladder both served — GLM fold).
    # Pure per-frame reader of chant-active: no stored state, nothing to
    # flicker or stick; abort_all_chants! on zone transition covers the
    # edge cases by construction. Drawn BEFORE the HUD/strip — the world
    # dims, the player's instruments never do.
    def draw_writ_veil(world)
      chanter = world.humans.find(&:chanting?)
      return unless chanter
      cam = world.camera(@local_seat)
      cx = (chanter.x + SIZE / 2 + world.feel.shake_x - cam.x).round
      cy = (chanter.y + SIZE / 2 + world.feel.shake_y - cam.y).round
      radius = @display.fetch(:writ_radius_tiles, 4) * world.map.tile_size
      r = App::Writ.rects(cx:, cy:, radius:, view_w: cam.view_w, view_h: cam.view_h)
      out = Gosu::Color.new(@display.fetch(:writ_out_alpha, 140), 0, 0, 0)
      r[:out].each { |(x, y, w, h)| Gosu.draw_rect(x, y, w, h, out) }
      border = Gosu::Color.new(230, *chant_rgb)
      r[:border].each { |(x, y, w, h)| Gosu.draw_rect(x, y, w, h, border) }
    end

    def draw_seized_underline(c, x, y)
      duration = c.seized_by.kit[:seize][:duration_frames]
      frac = c.seized_frames.fdiv(duration)
      alpha = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
      Gosu.draw_rect(x - 2, y + SIZE + 9, SIZE + 4, 3,
                     Gosu::Color.new(alpha, *seized_rgb))
    end

    # The only human with a NAME (v15): small bone type above the body —
    # placeholder name per the 2026-08-16 owner order (no lore in repo).
    def draw_nameplate(c, x, y)
      name = tr("challenger.name", "BOSS 1")
      f = nameplate_font
      f.draw_text(name, x + SIZE / 2 - f.text_width(name) / 2, y - 24, 5, 1, 1, BANNER)
    end

    # Chant tell (v15): an expanding hollow DEEP-BLUE square repeating over
    # the chant (taunt-pulse grammar, virgin color audited vs the pale-blue
    # retarget cue) out to the seize range — the calling range made visible.
    # The pinned vessel carries a hollow blue square ABOVE the god-mark slot.
    def draw_chant_rings(world)
      ts = world.map.tile_size
      world.humans.each do |h|
        next unless h.chanting?
        cfg = h.kit[:seize]
        elapsed = cfg[:chant_frames] - h.chant_left
        cycle = @display.fetch(:chant_ring_cycle_frames, 40)
        progress = (elapsed % cycle).fdiv(cycle)
        reach = (cfg[:range_tiles] * ts * progress).round
        cx = h.tile[0] * ts + ts / 2
        cy = h.tile[1] * ts + ts / 2
        if reach >= 4
          alpha = (220 * (1.0 - progress * 0.6)).round
          col = Gosu::Color.new(alpha, *chant_rgb)
          thick = 3
          Gosu.draw_rect(cx - reach, cy - reach, reach * 2, thick, col)
          Gosu.draw_rect(cx - reach, cy + reach - thick, reach * 2, thick, col)
          Gosu.draw_rect(cx - reach, cy - reach, thick, reach * 2, col)
          Gosu.draw_rect(cx + reach - thick, cy - reach, thick, reach * 2, col)
        end
        if (t = h.chant_target) && !t.dead?
          Gosu.draw_rect(t.x + SIZE / 2 - 4, t.y - 20, 8, 8,
                         Gosu::Color.new(255, *chant_rgb))
          Gosu.draw_rect(t.x + SIZE / 2 - 2, t.y - 18, 4, 4,
                         color(world.map.palette[:floor]))
        end
      end
    end

    def chant_rgb = @chant_rgb ||= @display.fetch(:chant_ring_rgb, [60, 100, 220])
    def seized_rgb = @seized_rgb ||= @display.fetch(:seized_underline_rgb, [60, 100, 220])
    def partner_ring = @partner_ring ||= Gosu::Color.new(255, *@display.fetch(:partner_ring_rgb, [80, 200, 220]))
    def nameplate_font = @nameplate_font ||= Gosu::Font.new(@display.fetch(:nameplate_font_size, 10))

    # Pressuring stance (A2): a thin hollow outline — present, encircling,
    # not swinging. Distinct from the telegraph's FILLED swell and the taunt
    # underline. Outline = state (the glean-pip grammar).
    def draw_pressure_outline(c, x, y, world)
      col = Gosu::Color.new(@pressure_alpha, HUMAN_BODY.red, HUMAN_BODY.green, HUMAN_BODY.blue)
      t = 2
      Gosu.draw_rect(x - 4, y - 4, SIZE + 8, t, col)
      Gosu.draw_rect(x - 4, y + SIZE + 2, SIZE + 8, t, col)
      Gosu.draw_rect(x - 4, y - 4, t, SIZE + 8, col)
      Gosu.draw_rect(x + SIZE + 2, y - 4, t, SIZE + 8, col)
    end

    # Taunt cast tell (A0.6): one continuous expanding hollow SQUARE outline —
    # square because range is Chebyshev (a circle under-reads the corners),
    # continuous because per-tile marks would read as volley brackets.
    # v16 (e): the FLASH is the primary channel (solid bright body-rect for
    # the first frames), shards are the secondary motion read — geometry is
    # pure integer math in App::KillPop (deterministic by construction).
    def draw_kill_pops(world)
      ts = world.map.tile_size
      flash_frames = @display.fetch(:kill_pop_flash_frames, 5)
      flash = color(@display.fetch(:kill_pop_flash_rgb, [255, 250, 230]))
      shard = color(@display.fetch(:kill_pop_shard_rgb, [255, 150, 90]))
      world.kill_pops.each do |p|
        age = p[:pop_frames] - p[:frames_left]
        if age < flash_frames
          Gosu.draw_rect(p[:tile][0] * ts + 2, p[:tile][1] * ts + 2, ts - 4, ts - 4, flash)
        end
        App::KillPop.shards(tile: p[:tile], phase: p[:phase], frames_left: p[:frames_left],
                            pop_frames: p[:pop_frames], ts: ts).each do |x, y, size|
          Gosu.draw_rect(x, y, size, size, shard)
        end
      end
    end

    def draw_taunt_pulses(world)
      ts = world.map.tile_size
      world.taunt_pulses.each do |p|
        progress = 1.0 - p[:frames_left].fdiv(p[:pulse_frames])
        reach = (p[:range_tiles] * ts * progress).round
        cx = p[:tile][0] * ts + ts / 2
        cy = p[:tile][1] * ts + ts / 2
        alpha = (220 * (1.0 - progress * 0.6)).round
        col = Gosu::Color.new(alpha, TAUNT_RUST.red, TAUNT_RUST.green, TAUNT_RUST.blue)
        thick = 3
        Gosu.draw_rect(cx - reach, cy - reach, reach * 2, thick, col)
        Gosu.draw_rect(cx - reach, cy + reach - thick, reach * 2, thick, col)
        Gosu.draw_rect(cx - reach, cy - reach, thick, reach * 2, col)
        Gosu.draw_rect(cx + reach - thick, cy - reach, thick, reach * 2, col)
      end
    end

    # Three kit-colored bars; the possessed one is wider, white-edged, and
    # carries the exhaust-ready pip.
    def draw_hud(world)
      world.pack.members.each_with_index do |m, i|
        y = 16 + i * 20
        mine = m.equal?(world.possessed(@local_seat))
        w = mine ? 260 : 200
        x = 32
        Gosu.draw_rect(x - 2, y - 2, w + 4, 18, POSSESSED_RING) if mine
        Gosu.draw_rect(x, y, w, 14, m.dead? ? HP_DEAD : HP_BACK)
        frac = m.hp.fdiv(m.max_hp)
        if frac.positive?
          Gosu.draw_rect(x, y, (w * frac).round, 14, KIT_BODY[m.kit_name])
        end
        attack_pip = !m.dead? && m.exhaust_ready? ? POSSESSED_RING : HP_BACK
        special_ready = !m.dead? && m.kit[:special] && m.special_ready?
        special_pip = special_ready ? KIT_BODY[m.kit_name] : HP_BACK
        Gosu.draw_rect(300, y + 2, 10, 10, attack_pip)
        Gosu.draw_rect(314, y + 2, 10, 10, special_pip)
        Gosu.draw_rect(317, y + 5, 4, 4, POSSESSED_RING) if special_ready
        # Carried numeral: possessed bar only, reserved slot right of the
        # pips — layout never shifts (quiet-HUD law).
        if mine && m.carried.positive?
          hud_font.draw_text(m.carried.to_s, 332, y, 20, 1, 1, DROP_CORE)
        end
      end
    end

    # Living off-screen kin show as kit-colored pips clamped to the viewport
    # edge toward their true position — ally state is never invisible.
    def draw_edge_pips(world)
      cam = world.camera(@local_seat)
      world.pack.living.each do |m|
        next if m.equal?(world.possessed(@local_seat))
        sx = m.x - cam.x
        sy = m.y - cam.y
        on_screen = sx > -SIZE && sx < cam.view_w && sy > -SIZE && sy < cam.view_h
        next if on_screen
        px = (sx + SIZE / 2).clamp(6, cam.view_w - 16)
        py = (sy + SIZE / 2).clamp(6, cam.view_h - 16)
        Gosu.draw_rect(px, py, 10, 10, KIT_BODY[m.kit_name])
      end
    end

    # v15 banner FIFO: the slot renders the ACTIVE queue entry — zone
    # banners in bone, court stamps in gate-gold. Entries carry KEYS;
    # locale resolves here at draw time (comparability law preserved).
    # v16 (c): stamps LAND — scale-in over stamp_in_frames (endpoints in
    # data), full dwell, final-third fade, framed by a top+bottom rule
    # pair (the acta look). Zone banners keep their quiet entrance:
    # places announce, courts JUDGE.
    def draw_banner(world)
      entry = world.active_banner
      return unless entry
      text = tr(entry[:text_key], entry[:fallback])
      font = banner_font
      if entry[:color] == :gold
        return draw_stamp_line(world, text, frames_left: entry[:frames_left],
                                            frames_total: entry[:frames_total], top: 48)
      end
      x = (view_width(world) - font.text_width(text)) / 2
      font.draw_text(text, x, 48, 10, 1, 1, BANNER)
    end

    # Shared court-stamp delivery: the banner-slot stamps AND the breach
    # writ line land with the same grammar (a court has ONE seal press).
    def draw_stamp_line(world, text, frames_left:, frames_total:, top:)
      font = banner_font
      age = frames_total - frames_left
      s = App::Stamp.scale(age:, in_frames: @display.fetch(:stamp_in_frames, 12),
                           in_scale: @display.fetch(:stamp_in_scale, 1.6))
      a = App::Stamp.alpha(frames_left:, frames_total:)
      col = Gosu::Color.new(a, BREACH_GOLD.red, BREACH_GOLD.green, BREACH_GOLD.blue)
      w = font.text_width(text) * s
      h = font.height * s
      cx = view_width(world) / 2.0
      cy = top + font.height / 2.0
      font.draw_text(text, cx - w / 2, cy - h / 2, 10, s, s, col)
      pad = @display.fetch(:stamp_rule_pad, 8) * s
      rule_h = @display.fetch(:stamp_rule_h, 2) * s
      rule_col = color(@display.fetch(:stamp_rule_rgb, [200, 160, 80]), a)
      rule_w = w + pad * 2
      Gosu.draw_rect(cx - rule_w / 2, cy - h / 2 - pad - rule_h, rule_w, rule_h, rule_col, 10)
      Gosu.draw_rect(cx - rule_w / 2, cy + h / 2 + pad, rule_w, rule_h, rule_col, 10)
    end

    # v16 (c): located stamps press a seal mark into the floor at the event
    # tile — rect frame + inner glyph in stamp gold, dwelling with the
    # banner, fading on the same final-third grammar. Pure reader of
    # world.seal_marks (replay determinism holds).
    def draw_seal_marks(world)
      ts = world.map.tile_size
      rgb = @display.fetch(:seal_mark_rgb, [235, 190, 90])
      world.seal_marks.each do |m|
        a = App::Stamp.alpha(frames_left: m[:frames_left], frames_total: m[:frames_total])
        col = color(rgb, a)
        x = m[:at][0] * ts
        y = m[:at][1] * ts
        Gosu.draw_rect(x + 2, y + 2, ts - 4, 2, col)
        Gosu.draw_rect(x + 2, y + ts - 4, ts - 4, 2, col)
        Gosu.draw_rect(x + 2, y + 4, 2, ts - 8, col)
        Gosu.draw_rect(x + ts - 4, y + 4, 2, ts - 8, col)
        Gosu.draw_rect(x + ts / 2 - 4, y + ts / 2 - 4, 8, 8, col)
      end
    end

    # The writ line (v12 breach beat): gate-gold, one slot below the zone
    # banner so the two can never stack illegibly. Pure reader of world
    # state — replay determinism holds. v16 (c): lands with the SAME stamp
    # grammar as the banner-slot court lines (rule pair + scale-in + fade)
    # — the wall critic caught the flat render as broken court ceremony.
    def draw_breach_line(world)
      line = world.breach_line
      return unless line
      draw_stamp_line(world, tr("breach.line", line[:text]),
                      frames_left: line[:frames_left],
                      frames_total: line.fetch(:frames_total, @display.fetch(:breach_banner_frames, 150)),
                      top: 88)
    end

    def draw_wipe_overlay(world)
      # v16 owner order (2026-08-16): the wipe TEXT is removed — the lore
      # rework renames or retires it. The veil + the recap ARE the wipe's
      # delivery until the new bible speaks.
      Gosu.draw_rect(0, 0, view_width(world), view_height(world), WIPE_VEIL)
    end

    # Forced swap lands with a one-beat red edge so losing a body FEELS lost.
    def draw_stagger_veil(world)
      Gosu.draw_rect(0, 0, view_width(world), view_height(world), STAGGER_VEIL)
    end

    # Registration beat (fight-ledger spec; presentation iteration 2026-08-11):
    # 1-3 glyph+number lines on a dark contrast panel, centered just above the
    # avatar (the camera keeps the possessed body at screen center — this IS
    # player-anchored). Glyph grammar is the game's own: filled square =
    # acquired value, hollow pip = pile-on-a-corpse (recoverable, calm), dark
    # square = destroyed (gone). No words — nothing blocks on the bible.
    # Entrance: scale pop 1.35→1.0 + additive flash; exit: alpha fade over the
    # final third of beat_left (the drop-decay grammar). Wipe recaps sit lower
    # (ledger_wipe_y), clear of the 64pt wipe line. RENDER-ONLY: everything is
    # a pure function of the beat record — replay determinism holds.
    # Z within the block: panel 29, glyphs+text 30, flash 31.
    def draw_ledger_beat(world)
      beat = world.ledger_beat
      return unless beat
      return if self.class.silent_beat?(beat)
      frac = beat[:beat_left].fdiv(beat[:beat_frames])
      a = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
      age = beat[:beat_frames] - beat[:beat_left]
      scale = age < ledger_pop_frames ? 1.35 - 0.35 * (age.fdiv(ledger_pop_frames)**0.5) : 1.0
      cx = view_width(world) / 2
      top = beat[:kind] == :wipe ? ledger_wipe_y : ledger_block_y
      lines = beat_lines(beat, a)
      h = lines.sum { |l| l[:height] } + BEAT_LINE_GAP * (lines.length - 1)
      w = lines.map { |l| l[:width] }.max
      cy = top + h / 2.0
      draw_beat_panel(cx, cy, w, h, scale, a)
      # No arrival flash on wipe recaps: beat_left freezes for the whole veil
      # (age pinned at 0), so an age-driven flash would sit at full additive
      # alpha over the text for ~90 frames and wash the recap out — the exact
      # legibility wipe_recap_reads gates on. The veil IS the wipe's punch.
      draw_beat_flash(cx, cy, w, h, scale, age) unless beat[:kind] == :wipe
      y_off = -h / 2.0
      lines.each do |line|
        draw_beat_line(line, cx, cy, y_off, scale)
        y_off += line[:height] + BEAT_LINE_GAP
      end
    end

    # Line specs carry block-local coords (x from line center, dy from line
    # top) so the pop can scale the whole block around its center point.
    # The summary line is always the loud one: net when losses exist, the
    # take itself when it stands alone (the most common beat — a lone +N —
    # must not be the quietest).
    def beat_lines(beat, a)
      solo = (beat[:pip_amount] + beat[:dark_amount]).zero?
      lines = [beat_take_line(beat, a, solo: solo)]
      unless solo
        lines << beat_losses_line(beat, a)
        lines << beat_net_line(beat, a)
      end
      lines
    end

    def beat_take_line(beat, a, solo:)
      col = fade(DROP_CORE, a)
      font = solo ? ledger_net_font : ledger_line_font
      glyph = solo ? BEAT_GLYPH_BIG : BEAT_GLYPH
      h = solo ? 42 : 26
      text = "+#{beat[:gained]}"
      w = glyph + 8 + font.text_width(text)
      w += glyph + 8 if beat[:recovery]
      x = -w / 2.0
      dy = (h - glyph) / 2.0
      parts = []
      if beat[:recovery]
        parts << { type: :pip, x: x, dy: dy, size: glyph, col: col }
        x += glyph + 8
      end
      parts << { type: :square, x: x, dy: dy, size: glyph, col: col }
      parts << { type: :text, x: x + glyph + 8, dy: 0, text: text,
                 font: font, col: col }
      { width: w, height: h, parts: parts }
    end

    def beat_losses_line(beat, a)
      specs = []
      specs << [:pip, "-#{beat[:pip_amount]}", fade(BANNER, a)] if beat[:pip_amount].positive?
      specs << [:dark, "-#{beat[:dark_amount]}", fade(LEDGER_NEG, a)] if beat[:dark_amount].positive?
      w = specs.sum { |(_, t, _)| BEAT_GLYPH + 8 + ledger_line_font.text_width(t) + 14 } - 14
      x = -w / 2.0
      parts = []
      specs.each do |(kind, text, text_col)|
        parts <<
          if kind == :pip
            { type: :pip, x: x, dy: 3, size: BEAT_GLYPH, col: fade(DROP_CORE, a) }
          else
            { type: :dark, x: x, dy: 3, size: BEAT_GLYPH,
              edge: fade(LEDGER_NEG, a), core: fade(LEDGER_DARK, a) }
          end
        parts << { type: :text, x: x + BEAT_GLYPH + 8, dy: 0, text: text,
                   font: ledger_line_font, col: text_col }
        x += BEAT_GLYPH + 8 + ledger_line_font.text_width(text) + 14
      end
      { width: w, height: 26, parts: parts }
    end

    def beat_net_line(beat, a)
      col = beat[:net].negative? ? fade(LEDGER_NEG, a) : fade(DROP_CORE, a)
      text = "= #{beat[:net].negative? ? '' : '+'}#{beat[:net]}"
      w = ledger_net_font.text_width(text)
      { width: w, height: 42,
        parts: [{ type: :text, x: -w / 2.0, dy: 0, text: text, font: ledger_net_font, col: col }] }
    end

    def draw_beat_panel(cx, cy, w, h, scale, a)
      pw = (w + BEAT_PAD_X * 2) * scale
      ph = (h + BEAT_PAD_Y * 2) * scale
      col = Gosu::Color.new((ledger_panel_alpha * a / 255.0).round, *BEAT_PANEL)
      Gosu.draw_rect(cx - pw / 2, cy - ph / 2, pw, ph, col, 29)
    end

    # Peak alpha 120, not higher: at ~200 the flash whites the magenta glyph
    # out entirely at age 0 — an arrival punch must never erase the gain/loss
    # color identity the grammar teaches.
    def draw_beat_flash(cx, cy, w, h, scale, age)
      return unless age < ledger_flash_frames
      fa = (ledger_flash_alpha * (1.0 - age.fdiv(ledger_flash_frames))).round
      pw = (w + BEAT_PAD_X * 2) * scale
      ph = (h + BEAT_PAD_Y * 2) * scale
      Gosu.draw_rect(cx - pw / 2, cy - ph / 2, pw, ph,
                     Gosu::Color.new(fa, *BEAT_FLASH), 31, :additive)
    end

    def draw_beat_line(line, cx, cy, y_off, scale)
      line[:parts].each do |p|
        x = cx + p[:x] * scale
        y = cy + (y_off + p[:dy]) * scale
        case p[:type]
        when :text
          p[:font].draw_text(p[:text], x, y, 30, scale, scale, p[:col])
        when :square
          Gosu.draw_rect(x, y, p[:size] * scale, p[:size] * scale, p[:col], 30)
        when :pip
          draw_hollow_pip(x, y, p[:size] * scale, p[:col])
        when :dark
          s = p[:size] * scale
          Gosu.draw_rect(x - 2 * scale, y - 2 * scale, s + 4 * scale, s + 4 * scale, p[:edge], 30)
          Gosu.draw_rect(x, y, s, s, p[:core], 30)
        end
      end
    end

    def draw_hollow_pip(x, y, size, col)
      t = [3, (size * 0.15).round].max
      Gosu.draw_rect(x, y, size, t, col, 30)
      Gosu.draw_rect(x, y + size - t, size, t, col, 30)
      Gosu.draw_rect(x, y, t, size, col, 30)
      Gosu.draw_rect(x + size - t, y, t, size, col, 30)
    end

    def fade(color, a)
      Gosu::Color.new((color.alpha * a / 255.0).round, color.red, color.green, color.blue)
    end

    def view_width(world) = world.camera(@local_seat).view_w
    def view_height(world) = world.camera(@local_seat).view_h

    # v13 i18n seam: every player-visible string funnels through here.
    # No resolver (bare Renderer.new) = the fallback = pre-v13 exact text.
    def tr(key, fallback = nil) = @strings ? @strings.t(key, fallback) : fallback

    def banner_font = @banner_font ||= Gosu::Font.new(28, bold: true)
    def wipe_font = @wipe_font ||= Gosu::Font.new(64, bold: true)
    def hud_font = @hud_font ||= Gosu::Font.new(14)
    def ledger_font = @ledger_font ||= Gosu::Font.new(16, bold: true)
    # Beat tally fonts, created at target size — glyphs only blur during the
    # brief >1.0 pop overshoot (intentional punch).
    def ledger_line_font = @ledger_line_font ||= Gosu::Font.new(26, bold: true)
    def ledger_net_font = @ledger_net_font ||= Gosu::Font.new(42, bold: true)

    def ledger_pop_frames = @display.fetch(:ledger_pop_frames, 10)
    def ledger_flash_frames = @display.fetch(:ledger_flash_frames, 6)
    def ledger_flash_alpha = @display.fetch(:ledger_flash_alpha, 120)
    def ledger_panel_alpha = @display.fetch(:ledger_panel_alpha, 160)
    def ledger_block_y = @display.fetch(:ledger_block_y, 160)
    def ledger_wipe_y = @display.fetch(:ledger_wipe_y, 340)
  end
end
