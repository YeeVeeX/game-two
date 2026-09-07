require "gosu"

module App
  # PREMIUM v22 pass 4 — CAMERA + LIGHT. Presentation only, tick-driven.
  #   * glows: a soft warm radial light around every fire-family ambience
  #     source (torch_flicker / fire / lava_glow / ember_sparks) drawn
  #     ADDITIVE over the world, flickering on a per-source phase of
  #     world.frame — the dungeon gets light where its fire is.
  #   * vignette: screen-space edge darkening (stronger underground, light
  #     in hubs/safe zones) — the eye lands on the center, depth reads.
  #   * kill punch: a 2-frame 3% zoom around the view center on actor_died
  #     (fed by the same bus event Fx uses), the "hit lands" camera beat.
  #   * level flash: a warm full-screen flash decaying over 14 frames on
  #     :level_up.
  # Pure functions of (world.frame, zone config, bus events). No clock,
  # no RNG, nothing in the digest. display.json knobs: light_glows,
  # vignette_alpha / vignette_alpha_safe, kill_punch, level_flash.
  class Light
    FIRE_PRESETS = %w[torch_flicker fire lava_glow ember_sparks].freeze
    GLOW_R = 48

    def initialize(display:)
      @display = display
      @enabled = display.fetch(:light_enabled)
      @glow_img = nil
      @worlds = {}
    end

    def enabled? = @enabled

    # ---- bus state (punch / flash) ----------------------------------------------
    def state_for(world)
      @worlds[world] ||= begin
        st = { kill_at: -99, level_at: -99 }
        if world.respond_to?(:bus)
          world.bus.subscribe(:actor_died) { |_ev| st[:kill_at] = world.frame }
          world.bus.subscribe(:level_up) { |_ev| st[:level_at] = world.frame }
        end
        st
      end
    end

    # Scale factor for the world pass: 1.03 on the kill frame and the next,
    # 1.0 otherwise (display.json kill_punch = 0 disables).
    def punch(world)
      return 1.0 unless @enabled
      k = @display.fetch(:kill_punch).to_f
      return 1.0 if k <= 0
      age = world.frame - state_for(world)[:kill_at]
      age.between?(0, 1) ? 1.0 + k : 1.0
    end

    # ---- glows (world space, additive) --------------------------------------------
    def glow_image
      @glow_img ||= begin
        d = GLOW_R * 2
        blob = String.new(capacity: d * d * 4)
        d.times do |y|
          d.times do |x|
            dx = x + 0.5 - GLOW_R
            dy = y + 0.5 - GLOW_R
            t = Math.sqrt(dx * dx + dy * dy) / GLOW_R
            a = t >= 1.0 ? 0 : (255 * (1.0 - t)**2.2).round
            blob << [255, 255, 255, a].pack("C4")
          end
        end
        Gosu::Image.new(RawBlob.new(d, d, blob), retro: false)
      end
    end

    RawBlob = Struct.new(:columns, :rows, :to_blob)

    def draw_glows(world, camera, sources, ts)
      return unless @enabled && @display.fetch(:light_glows)
      img = glow_image
      rgb = @display.fetch(:light_fire_rgb)
      base_a = @display.fetch(:light_fire_alpha)
      sources.each do |(preset, tx, ty, seed)|
        next unless FIRE_PRESETS.include?(preset.to_s)
        cx = tx * ts + ts / 2
        cy = ty * ts + ts / 2
        next if cx + GLOW_R * 2 < camera.x || cx - GLOW_R * 2 > camera.x + camera.view_w ||
                cy + GLOW_R * 2 < camera.y || cy - GLOW_R * 2 > camera.y + camera.view_h
        # flicker: two slow triangle waves on different periods, per-source phase
        ph = (world.frame + seed.to_i * 7 + tx * 3 + ty * 5)
        f1 = (ph % 40) < 20 ? (ph % 40) / 20.0 : (40 - (ph % 40)) / 20.0
        f2 = (ph % 26) < 13 ? (ph % 26) / 13.0 : (26 - (ph % 26)) / 13.0
        flick = 0.78 + 0.14 * f1 + 0.08 * f2
        scale = (preset.to_s == "lava_glow" ? 1.15 : 1.5) * flick
        a = (base_a * flick).round.clamp(0, 255)
        img.draw_rot(cx, cy, 0, 0, 0.5, 0.5, scale, scale,
                     Gosu::Color.new(a, *rgb), :additive)
        # hot core, smaller and brighter
        img.draw_rot(cx, cy, 0, 0, 0.5, 0.5, scale * 0.45, scale * 0.45,
                     Gosu::Color.new((a * 0.6).round, 255, 220, 150), :additive)
      end
    end

    # One additive glow at a world point (exit pulses, later: pickups). scale
    # 1.0 = 96px diameter blob; alpha 0..255. No-op when glows are off.
    def glow_at(cx, cy, scale, alpha, rgb, z: 0)
      return unless @enabled && @display.fetch(:light_glows)
      glow_image.draw_rot(cx, cy, z, 0, 0.5, 0.5, scale, scale, Gosu::Color.new(alpha.clamp(0, 255), *rgb), :additive)
    end

    # ---- screen space: vignette + level flash --------------------------------------
    def draw_screen(world, view_w, view_h, possessed: nil)
      return unless @enabled
      map = world.map
      # pass 10: LOW HP — the frame bleeds. Below low_hp_pct of max, a red
      # edge pulse (40-frame breath) grows as hp falls: the ARPG "you are
      # dying" read, no numeral needed. Pure function of (hp, frame).
      # never during the wipe veil (nest_respawn): the veil owns "you fell";
      # and in WINE red (dark, desaturated) so it never reads as that veil.
      wiping = world.respond_to?(:states) && world.states.current == :nest_respawn
      if !wiping && possessed && !possessed.dead? && possessed.hp < possessed.max_hp * @display.fetch(:low_hp_pct)
        depth = 1.0 - possessed.hp.fdiv([possessed.max_hp * @display.fetch(:low_hp_pct), 1].max)
        ph = world.frame % 40
        breath = ph < 20 ? ph / 20.0 : (40 - ph) / 20.0
        # Wall #4 (district_hunt low_hp_pulse_reads, 2026-09-06): the old floor
        # 0.45 x 0.6 = 27% of low_hp_alpha (~41) at onset sat UNDER the base
        # vignette (130) on a warm floor - measured dR 0..11, scene noise. The
        # pulse must READ the moment hp crosses low_hp_pct, then deepen; the
        # floors are display rows. Depth still carries "how badly", breath the pulse.
        af = @display.fetch(:low_hp_alpha_floor)
        bf = @display.fetch(:low_hp_breath_floor)
        a = (@display.fetch(:low_hp_alpha) * (af + (1.0 - af) * depth) * (bf + (1.0 - bf) * breath)).round
        draw_vignette(view_w, view_h, a, rgb: @display.fetch(:low_hp_rgb),
                      bw_pct: @display.fetch(:low_hp_band_w_pct), bh_pct: @display.fetch(:low_hp_band_h_pct))
        # Wall #5 (corpse_run + district_hunt low_hp_pulse_reads): on DARK floors the wine
        # bleed reads as "darker edges", not "red edges" (pixel-measured: edges (53,24,26),
        # R ~2x G,B, still judged "no red"). A thin BRIGHT saturated red RIM at the very
        # edge says RED on any floor; alpha rides the pulse. Display rows.
        rp = @display.fetch(:low_hp_rim_px)
        if rp.positive?
          rim = Gosu::Color.new([a, 255].min, *@display.fetch(:low_hp_rim_rgb))
          Gosu.draw_rect(0, 0, view_w, rp, rim, 17)
          Gosu.draw_rect(0, view_h - rp, view_w, rp, rim, 17)
          Gosu.draw_rect(0, 0, rp, view_h, rim, 17)
          Gosu.draw_rect(view_w - rp, 0, rp, view_h, rim, 17)
        end
      end
      safe = map.respond_to?(:safe?) ? map.safe? : false
      hub = map.respond_to?(:hub?) ? map.hub? : false
      a = (safe || hub) ? @display.fetch(:vignette_alpha_safe) : @display.fetch(:vignette_alpha)
      draw_vignette(view_w, view_h, a) if a.positive?
      fl = @display.fetch(:level_flash)
      age = world.frame - state_for(world)[:level_at]
      if fl.positive? && age.between?(0, fl - 1)
        k = 1.0 - age.fdiv(fl)
        Gosu.draw_rect(0, 0, view_w, view_h, Gosu::Color.new((150 * k * k).round, 255, 220, 140), 18)
      end
    end

    # A FRAME with no overlap: top/bottom bands full-width, left/right bands
    # only between them, and each corner as TWO triangles whose alpha follows
    # the distance to the NEAREST edge (dark at the outer edge, clear at the
    # inner corner) - so every shared edge matches its neighbour exactly.
    # Overlapping full bands double the alpha at the corners and draw hard
    # rectangular seams (brasa1 low-hp pulse, wall re-gate 2026-09-05).
    # bw_pct/bh_pct = band width/height as a fraction of the view (the base
    # vignette keeps 0.22/0.28 = the frame screen_light_reads approves; the
    # low-hp PULSE passes narrower bands - wall #4 ledger_loop: at 22/28 the wine
    # pulse read as a wash over the whole frame, HUD and bottom strip included).
    def draw_vignette(w, h, a, rgb: [8, 4, 6], bw_pct: 0.22, bh_pct: 0.28)
      bw = (w * bw_pct).round
      bh = (h * bh_pct).round
      dark = Gosu::Color.new(a, *rgb)
      clear = Gosu::Color.new(0, *rgb)
      z = 17
      Gosu.draw_quad(bw, 0, dark, w - bw, 0, dark, w - bw, bh, clear, bw, bh, clear, z)           # top
      Gosu.draw_quad(bw, h - bh, clear, w - bw, h - bh, clear, w - bw, h, dark, bw, h, dark, z)   # bottom
      Gosu.draw_quad(0, bh, dark, bw, bh, clear, bw, h - bh, clear, 0, h - bh, dark, z)           # left
      Gosu.draw_quad(w - bw, bh, clear, w, bh, dark, w, h - bh, dark, w - bw, h - bh, clear, z)   # right
      # corners: outer vertex dark, the two edge vertices dark, inner clear
      Gosu.draw_triangle(0, 0, dark, bw, 0, dark, bw, bh, clear, z)                    # TL upper
      Gosu.draw_triangle(0, 0, dark, 0, bh, dark, bw, bh, clear, z)                    # TL lower
      Gosu.draw_triangle(w, 0, dark, w - bw, 0, dark, w - bw, bh, clear, z)            # TR upper
      Gosu.draw_triangle(w, 0, dark, w, bh, dark, w - bw, bh, clear, z)                # TR lower
      Gosu.draw_triangle(0, h, dark, bw, h, dark, bw, h - bh, clear, z)                # BL lower
      Gosu.draw_triangle(0, h, dark, 0, h - bh, dark, bw, h - bh, clear, z)            # BL upper
      Gosu.draw_triangle(w, h, dark, w - bw, h, dark, w - bw, h - bh, clear, z)        # BR lower
      Gosu.draw_triangle(w, h, dark, w, h - bh, dark, w - bw, h - bh, clear, z)        # BR upper
    end
  end
end
