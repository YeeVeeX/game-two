require "json"
require "app/ambience"
require "app/art"
require "app/controls_overlay"
require "app/kill_pop"
require "app/stamp"
require "app/tile_art"
require "app/tileset"
require "app/hud"
require "app/fx"
require "app/light"
require "app/minimap"
require "app/signage"
require "app/item_icons"
require "app/bag_screen"
require "app/tile_variants"
require "app/writ"
require "app/zone_identity"
require "app/key_table"
require "core/strings"
require "core/binding_map"

module App
  # Draws the world sim with Gosu primitives. Flat-rect minimalism: kit
  # identity is COLOR + silhouette behavior; the possessed body is brightened
  # and white-ringed. Carried vision-critique fixes live here: facing notch,
  # crimson (never white) pack hurt-flash, two-tone telegraph distinct from
  # gate gold, corpses persist, attack lunge. Palettes from data/zones/*.json.
  class Renderer
    # SIGNAGE (src/app/signage.rb): interact_verb / way_locked? (class), the
    # interact prompt decision + draw, way breath, exit arrows, pressure
    # outline — extracted byte-inert (lane `signage`); callers unchanged.
    extend Signage::ClassMethods
    include Signage
    INTERACT_STATIONS = Signage::INTERACT_STATIONS

    HUMAN_BODY = Gosu::Color.new(255, 205, 198, 180) # pale bone
    KIT_BODY = Hash.new(HUMAN_BODY).merge(
      striker:      Gosu::Color.new(255, 235, 120, 40),
      blocker:      Gosu::Color.new(255, 158, 52, 30), # deep RUST (kits_distinct 2026-09-05: 190/80/35 read as a second orange)
      lobber:       Gosu::Color.new(255, 225, 170, 90),
      rusher_hater: HUMAN_BODY,
      # v20 T6b floor -2 fauna: each deep kind reads at a glance (L6).
      # Lurker = pale algae-bone (green-shifted from HUMAN_BODY, pops on
      # dark seabed AND inside green algae fields); warden = jellyfish
      # pink (Junior's medusa marker family, no other body owns pink).
      lurker:       Gosu::Color.new(255, 168, 205, 140),
      warden:       Gosu::Color.new(255, 235, 150, 210),
      # v20 T7 floor -3 fauna: stinger = pale translucent cyan (no other
      # body owns cyan; jellyfish family beside the warden's pink) - the
      # ranged watcher reads at a glance against the near-black abyss.
      stinger:      Gosu::Color.new(255, 150, 215, 230),
      # MUNDO VIVO FASE 4 ember family (BRASA): hot red-orange bodies; the
      # pack's ember ORANGE is lighter/yellower — critic-checked at gate.
      ember_a:      Gosu::Color.new(255, 210, 60, 30),
      ember_b:      Gosu::Color.new(255, 225, 110, 40),
      ember_d:      Gosu::Color.new(255, 240, 90, 20),
      # FASE 4.5 spore family (MUSGO, floor -3): yellow-green caps — the
      # lurker is pale algae, spores are saturated fungus green
      spore_a:      Gosu::Color.new(255, 150, 200, 70),
      spore_b:      Gosu::Color.new(255, 110, 170, 60),
      serpent_boss: Gosu::Color.new(255, 150, 100, 220),
      ember_boss:   Gosu::Color.new(255, 255, 70, 20),
      # MUNDO VIVO FASE 4 serpent family (the tower): violet-grey — no other
      # body owns violet; the quad fallback keeps the same color truth.
      serpent_a:    Gosu::Color.new(255, 170, 140, 210),
      serpent_b:    Gosu::Color.new(255, 200, 190, 175),
      serpent_c:    Gosu::Color.new(255, 120, 90, 170)
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
    TOTEM_HEAL     = Gosu::Color.new(255, 120, 235, 160) # heal pulse — no other ring family owns green
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
    ENEMY_STRIKE   = Gosu::Color.new(210, 255, 80, 60) # hostile red — the landed hit's WHERE
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
    # precedent). E3 b5: every knob is a WRITTEN row read by a STRICT fetch (no
    # code default; test/app/display_knobs_test.rb) — a bare Renderer.new reads
    # the repo's own display.json so it stays drawable (DISPLAY_PATH).
    # strings: Core::Strings resolver (v13 i18n) — RENDER-time only; the
    # harness constructs it pinned to "en" (replay comparability law).
    #
    # One construction seam for the FULL presentation stack (T0 d1/b2: the
    # netplay gate scene built a Renderer without art/ambience/tileset, so
    # the three net gates judged the quad fallback and the partner halo was
    # never captured; the three-loader wiring was copy-pasted 4x). Defaults
    # are the CANONICAL capture shape: locale "en" + local: false bindings
    # (check-comparability law, harness/scenes/world_scene.rb header).
    # window.rb passes its LIVE strings/bindings/seat instead.
    def self.build(data, display: data["display"], strings: nil, bindings: nil, local_seat: 1)
      new(display: display,
          strings: strings || Core::Strings.new(data, locale: "en"),
          bindings: bindings || Core::BindingMap.load(data, key_table: App::KEY_TABLE, local: false),
          local_seat: local_seat,
          art: App::Art::Registry.load(data),
          ambience: App::Ambience.load(data, display: display),
          tileset: App::Tileset.load(data, display: display),
          item_icons: App::ItemIcons.load(data)) # S1: catalog icons (HUD flask, drops, bag)
    end

    DISPLAY_PATH = File.expand_path("../../data/display.json", __dir__)

    def initialize(display: nil, strings: nil, bindings: nil, local_seat: 1, art: nil, ambience: nil,
                   tileset: nil, item_icons: nil)
      @display = display || JSON.parse(File.read(DISPLAY_PATH), symbolize_names: true)
      @strings = strings
      # PREMIUM v22: dual-grid material tiles (App::Tileset). nil -> the
      # flat-run + FASE 3 face path below (fallback law, byte-identical to
      # v21). display.json `tileset: false` forces the fallback.
      @tileset = tileset
      # S1: item icon sheet (App::ItemIcons) - HUD flask chip now, bag/drops next
      @item_icons = item_icons
      @bag_open = false
      # MUNDO VIVO FASE 2: animated ambient layers (App::Ambience::Scene);
      # nil = none. display.json `ambience: false` is honored inside it.
      @ambience = ambience
      # MUNDO VIVO FASE 1: sprite registry (App::Art). nil or a kit without
      # an atlas → the legacy quad (fallback law). display.json
      # `art_enabled: false` forces quads everywhere (debug/perf switch).
      @art = @display.fetch(:art_enabled) ? art : nil
      @art_notch = @display.fetch(:art_facing_notch)
      # R-A2: the bank BUY hint speaks the sustain key's own glyph — ONE
      # source (Core::BindingMap) feeds input, strip, and hint alike.
      @bindings = bindings
      @pressure_alpha = @display.fetch(:pressure_outline_alpha)
      # v17 renderer seam (Codex fold #7): every possessed/camera read goes
      # through the LOCAL seat — default 1, so single-player output is
      # byte-identical by default.
      @local_seat = local_seat
      @controls_overlay = ControlsOverlay.new(display: @display, strings:, bindings:, local_seat:)
      # PREMIUM v22 pass 3: impact particles (hit sparks, death bursts,
      # footstep dust) — bus-fed, frame-keyed, presentation-only.
      @fx = App::Fx.new(display: @display, kit_body: KIT_BODY,
                        labels: { drink: tr("hud.provisions", "POTION"), roll: tr("overlay.dodge", "dodge").upcase,
                                  special: tr("menu.label.special", "SPECIAL"),
                                  bag_full: tr("bag.full", "BAG FULL"),
                                  item: ->(id) { tr("item.#{id}.name", id.to_s.upcase) } })
      # PREMIUM v22 pass 4: fire glows, vignette, kill punch, level flash.
      @light = App::Light.new(display: @display)
      # PREMIUM v22 pass 9: the radar (App::Minimap), top-right.
      @minimap = App::Minimap.new(display: @display, kit_body: KIT_BODY)
    end

    # S2: the bag screen is a UI toggle owned by the window (never a sim verb)
    attr_accessor :bag_open

    def draw(world)
      cam = world.camera(@local_seat)
      # pass 4 kill punch: a 2-frame zoom about the view center wraps the
      # whole world pass (screen-space layers below stay unscaled).
      punch = @light.punch(world)
      Gosu.scale(punch, punch, cam.view_w / 2.0, cam.view_h / 2.0) do
      Gosu.translate(world.feel.shake_x - cam.x, world.feel.shake_y - cam.y) do
        draw_map(world)
        draw_impacts(world)
        draw_corpses(world)
        draw_stations(world)
        draw_drops(world)
        draw_item_drops(world)
        draw_corpse_loads(world)
        draw_expiry_flashes(world)
        draw_seal_marks(world)
        draw_respawn_tells(world)
        # PREMIUM v22: one depth-sorted pass (feet y, then x, then list
        # order) so a tall sprite standing SOUTH of another draws over its
        # feet, never under — the depth cue every top-down game relies on.
        # Pure and deterministic: same world -> same order on both seats.
        bodies = world.humans.each_with_index.map { |h, i| [h, 0, i] } +
                 world.pack.living.each_with_index.map { |m, i| [m, 1, i] }
        bodies.sort_by! { |(c, grp, i)| [c.y, c.x, grp, i] }
        @fx.update(world)
        @fx.draw(world)
        bodies.each { |(c, _grp, _i)| draw_creature(c, world) }
        @fx.draw_numbers(world)
        # Flywheel fix (2026-08-19, critique issue 2 — the verified gap):
        # draw_attack is pack-gated, so an enemy's ACTIVE strike rendered
        # nothing — the landed hit had no WHERE. Enemy strike tiles draw in
        # their own pass AFTER both body loops (a strike must read OVER its
        # victim, and pack bodies draw after humans), before projectiles/
        # pops/HUD. Windup stays the body swell — a landing-tile PREVIEW is
        # recorded as difficulty-adjacent, deliberately NOT drawn here.
        world.humans.each { |h| draw_enemy_strike(h, world.map.tile_size) }
        world.projectiles.each { |p| draw_projectile(p) }
        draw_taunt_pulses(world)
        draw_totem_pulses(world)
        draw_kill_pops(world)
        draw_level_pops(world)
        draw_chant_rings(world)
        draw_mark(world)
        draw_station_ledger(world)
        # pass 4: additive fire light over everything in the world pass
        @light.draw_glows(world, cam, @ambience ? @ambience.sources(world.map, world.tile_registry) : [],
                          world.map.tile_size)
      end
      end
      # pass 4: screen-space vignette + level flash, under the HUD
      @light.draw_screen(world, cam.view_w, cam.view_h, possessed: world.possessed(@local_seat))
      draw_writ_veil(world)
      draw_hud(world)
      draw_boss_bar(world)
      @minimap.draw(world, @local_seat)
      if @bag_open && world.respond_to?(:bag)
        @bag_screen ||= App::BagScreen.new(display: @display, strings: @strings, icons: @item_icons, bindings: @bindings)
        @bag_screen.draw(world, cam.view_w, cam.view_h)
      end
      draw_safe_chip(world)
      # Strip BEFORE edge pips (their bottom clamp lands inside the strip
      # band — an off-screen ally's pip must stay visible ON the strip) and
      # BEFORE the veils in call order (all default z: the wipe veil dims
      # it, ledger beats at z=29-31 stay above everything).
      @controls_overlay.draw(world)
      draw_edge_pips(world)
      draw_exit_arrows(world)
      draw_interact_prompt(world)
      draw_banner(world) if world.banner?
      draw_breach_line(world)
      draw_wipe_overlay(world) if world.states.current == :nest_respawn
      # AFTER the wipe overlay BY DESIGN: the alpha-170 veil would bury the
      # recap, and the recap legible through the veil is the point (spec:
      # one owned draw-order decision; review M1-codefit).
      draw_ledger_beat(world)
      draw_stagger_veil(world) if world.possessed(@local_seat)&.staggered?
      draw_hurt_vignette(world) if world.possessed(@local_seat)&.hurt?
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
    CUE_TEXT_FALLBACK = { provision_bought: "POTION BOUGHT",
                          provision_used: "POTION USED",
                          provision_refused: "REFUSED",
                          level_required: "LEVEL <N> REQUIRED" }.freeze

    def station_cue_text(kind)
      fallback = CUE_TEXT_FALLBACK[kind]
      return nil unless fallback
      @strings ? @strings.t("cue.#{kind}", fallback) : fallback
    end

    # R-A2 (verdict row 4 — the SEVENTEENTH's bought=0 discoverability hole):
    # the bank BUY hint, "U POTION -5" (v20 T3 noun). Speaks ONLY when the buy would
    # succeed (banked >= cost AND provisions < cap) — teaches success, never
    # a refusal — and yields its slot (the cue's y-32 text line) while a
    # station cue lives on this bank's tile: idle → hint, press → receipt,
    # receipt expires → hint recomputed. banked=0 at spawn keeps every walled
    # spawn frame byte-identical (the 7iii cost lesson; grill spec Q3).
    # Touchstone: Tibia's sustain is legible because verb + price are visible
    # AT the vendor (corpus brief §1 — shape, never numbers). Zero new
    # strings: glyph + ratified hud.provisions + the altar/vat "-price"
    # grammar. Proximity stays at the draw site (the ledger's radius-3 law).
    # Pure content resolution — tested headlessly (station_cue_text lane).
    SUSTAIN_GLYPH_FALLBACK = "U".freeze
    HUD_STOCK_FALLBACK = "POTION".freeze

    def sustain_hint(world, station)
      return nil unless station[:type] == "bank"
      pack = world.pack
      return nil unless pack.banked >= world.provision_cost
      return nil unless pack.provisions < world.provision_cap
      cue = world.station_cue
      return nil if cue && cue[:at] == station[:at]
      glyph = (@bindings&.glyphs(:sustain)&.first) || SUSTAIN_GLYPH_FALLBACK
      noun = @strings ? @strings.t("hud.provisions", HUD_STOCK_FALLBACK) : HUD_STOCK_FALLBACK
      "#{glyph} #{noun} -#{world.provision_cost}"
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

    # --- T4 way/water state (ONE condition source — the god-view reads
    # these too; the palette-source law extends to state resolution).
    # The way LOCK predicate (`Renderer.way_locked?`) lives in Signage. ----

    # The well's drained look (T4, render-only): water-typed tiles swap to
    # the authored water_drained ref once the zone's linked breach fact is
    # set. Read at DRAW time — never baked into the memoized variant cache
    # (state must not contaminate a pure-config cache); passability is
    # untouched by construction (the '#' law).
    def self.water_drained?(world, zone_name, map)
      !map.water_drained_by.nil? && world.breached?(zone_name, map.water_drained_by)
    end

    # B1-T2 (spec D5): a door's threshold cue derives from DESTINATION
    # safety at draw time — live transition tables, never the spec's prose
    # inventory (fresh-eyes nit-2: the basement/dungeon returns into
    # zone_7 are thresholds too, and only derivation catches every future
    # edge). Same-safety edges and unknown destinations (fixture maps)
    # carry nothing. Pure map reads — headlessly testable.
    def self.threshold_kind(from_map, to_map)
      return nil unless to_map
      return :into_safety if to_map.safe && !from_map.safe
      return :into_danger if from_map.safe && !to_map.safe
      nil
    end

    def color(rgb, alpha = 255) = Gosu::Color.new(alpha, rgb[0], rgb[1], rgb[2])

    def draw_map(world)
      map = world.map
      ts = map.tile_size
      transition = color(map.palette[:transition])

      # J1 frame-tail fix (s28, ticket drafts/_wb-t5-wirein-20260821.md):
      # the static tile pass — typed overlays + walls + motif — draws
      # MERGED RECT RUNS memoized per map instead of one rect per tile.
      # zone_7 issued ~1030 rects/frame here (census in the ticket;
      # Junior's draw p95 15.3 ms ≈ the whole budget); merging abutting
      # same-color spans cuts the call count ~2× while keeping the exact
      # primitive (solid opaque draw_rect under the same camera translate
      # — abutting spans of one color tile the SAME pixels as their union,
      # so capture bytes are unchanged BY CONSTRUCTION; the banked
      # baselines are the proof). Texture/macro composition was tried and
      # REJECTED: Macro#draw is illegal inside Gosu.render on gosu 1.4.6,
      # and a rasterized layer resamples under the float camera's
      # fractional offsets — both probes banked in the ticket. Geometry
      # stays a pure function of zone config + registry (memo per map);
      # the drained bool swaps water run colors at DRAW time, never in
      # the cache. Decor, transitions, seal slabs, and ambient stay live
      # draws (state-dependent or above-grid by design).
      drained = Renderer.water_drained?(world, world.zone_name, map)
      tile_runs, motif_runs = static_runs(map, world)
      # Large maps (ZONE 8 is 2048x1280) keep most static runs outside the
      # viewport. Gosu still submits every primitive inside the translated
      # block, so cull only immutable map rectangles against the camera in
      # WORLD coordinates. A 1px pad preserves edge-touching grid/rect
      # coverage under the camera's fractional lerp; visible pixels stay
      # byte-identical while off-screen submissions disappear.
      camera = world.camera(@local_seat)
      static_visible = ->(rect) { Renderer.rect_visible?(rect, camera) }
      Gosu.draw_rect(0, 0, map.pixel_width, map.pixel_height,
                     color(map.palette[:floor]))
      if @tileset
        # PREMIUM v22: the dual-grid material layer replaces flat runs AND
        # the FASE 3 faces (cliffs/rims/shadows/foam are baked per piece).
        @tileset.draw(map, world.tile_registry, camera, drained: drained)
      else
        tile_runs.each do |run|
          next unless static_visible.call(run)
          x, y, w, h, ref = run
          ref = :water_drained if ref == :water && drained
          Gosu.draw_rect(x, y, w, h, color(map.palette[ref]))
        end
        # FASE 3: tile faces (wall cliffs, rims, floor shadows, water foam) —
        # memoized pure geometry, culled. Drawn right over the flat runs and
        # under the grid/motif/decor so authored landmarks stay on top.
        if @display.fetch(:tile_faces)
          face_rects(map, world).each do |rect|
            next unless static_visible.call(rect)
            x, y, w, h, rgb, a = rect
            Gosu.draw_rect(x, y, w, h, color(rgb, a))
          end
        end
      end
      # D7 (FASE 3): the tile grid is optional once tiles carry their own
      # edges — default OFF; display.json `grid_lines: true` restores it.
      if @display.fetch(:grid_lines)
        grid = color(map.palette[:grid])
        Renderer.visible_grid_indices(map.cols, ts, camera.x, camera.view_w).each do |tx|
          Gosu.draw_rect(tx * ts, 0, 1, map.pixel_height, grid)
        end
        Renderer.visible_grid_indices(map.rows, ts, camera.y, camera.view_h).each do |ty|
          Gosu.draw_rect(0, ty * ts, map.pixel_width, 1, grid)
        end
      end
      unless motif_runs.empty?
        mcol = color(map.palette[:motif_rgb])
        motif_runs.each do |rect|
          next unless static_visible.call(rect)
          x, y, w, h = rect
          Gosu.draw_rect(x, y, w, h, mcol)
        end
      end
      _, decor = identity_rects(map)
      decor.each do |rect|
        next unless static_visible.call(rect)
        x, y, w, h, rgb, a = rect
        Gosu.draw_rect(x, y, w, h, color(rgb, a))
      end
      # FASE 2: living layer — over floor/decor, under gates, actors and
      # the ambient tint (the tint colors it like everything else). Tick-
      # driven: every value derives from world.frame (see App::Ambience).
      @ambience&.draw(world, camera, world.tile_registry)
      map.transitions.each do |t|
        tx, ty = t[:at]
        if Renderer.way_locked?(world, world.zone_name, t)
          # A shut way is NOT gold — gold means walkable. Dark slab with
          # a thin gold seam: shut, but a door (v12 presentation spec 1;
          # T4 boss fact-gates share the exact grammar).
          Gosu.draw_rect(tx * ts + 1, ty * ts + 1, ts - 2, ts - 2, SEAL_SLAB)
          Gosu.draw_rect(tx * ts + ts / 2 - 1, ty * ts + 4, 2, ts - 8, transition)
        else
          Gosu.draw_rect(tx * ts + 3, ty * ts + 3, ts - 6, ts - 6, transition)
        end
        # B1-T2 (spec D5): the visible boundary — a thin static frame at
        # the tile border, OUTSIDE the gold fill's inset (walkability
        # grammar underneath stays legible; slab-vs-gold keeps the lock
        # read, the frame carries the destination fact).
        if (kind = Renderer.threshold_kind(map, world.zone_maps[t[:to]]))
          draw_threshold_frame(tx, ty, ts, kind)
        end
        # PREMIUM v22 pass 8 SIGNAGE: an OPEN way BREATHES (Signage#draw_way_breath).
        if @display.fetch(:exit_pulse) && !Renderer.way_locked?(world, world.zone_name, t)
          draw_way_breath(world, map, tx, ty, ts)
        end
      end
      # Ambient tint LAST over the whole map quad — a faint colored light
      # the zone sits in; actors draw after (untinted — W6, bodies anchor).
      if (amb = App::ZoneIdentity.ambient(map))
        # covers the whole view (the tileset now draws rock past the map's
        # edge for pocket zones smaller than the window); same pixels where
        # the map already filled the view.
        Gosu.draw_rect(camera.x - ts * 2, camera.y - ts * 2, camera.view_w + ts * 4, camera.view_h + ts * 4,
                       color(amb[0, 3], amb[3]))
      end
    end

    def self.rect_visible?(rect, camera, pad: 1)
      x, y, w, h = rect
      x + w >= camera.x - pad && x <= camera.x + camera.view_w + pad &&
        y + h >= camera.y - pad && y <= camera.y + camera.view_h + pad
    end

    def self.visible_grid_indices(count, tile_size, camera_pos, view_size, pad: 1)
      first = ((camera_pos - pad) / tile_size).floor.clamp(0, count)
      last = ((camera_pos + view_size + pad) / tile_size).ceil.clamp(0, count)
      first..last
    end

    def identity_rects(map)
      @identity_cache ||= {}
      @identity_cache[map] ||= [App::ZoneIdentity.motif_rects(map),
                                App::ZoneIdentity.decor_rects(map)]
    end

    # B1-T2 (spec D5): mint = "reach that door = safety" (finding B's
    # actual need, read from the DANGEROUS side); dark ember = "beyond
    # this = danger" (read from inside the sanctuary — deliberately
    # dimmer than the hot TELEGRAPH_EDGE: a signpost, not an attack).
    # Static by design v0 — a persistent boundary is state, not an event;
    # any pulse is T3-feel territory. rgb/alpha ride display.json.
    def draw_threshold_frame(tx, ty, ts, kind)
      rgb, alpha =
        if kind == :into_safety
          [@display.fetch(:safe_threshold_rgb),
           @display.fetch(:safe_threshold_alpha)]
        else
          [@display.fetch(:danger_threshold_rgb),
           @display.fetch(:danger_threshold_alpha)]
        end
      col = color(rgb, alpha)
      x = tx * ts
      y = ty * ts
      t = 3
      Gosu.draw_rect(x, y, ts, t, col)
      Gosu.draw_rect(x, y + ts - t, ts, t, col)
      Gosu.draw_rect(x, y + t, t, ts - t * 2, col)
      Gosu.draw_rect(x + ts - t, y + t, t, ts - t * 2, col)
    end

    # J1 (s28): merged static geometry, memoized per map — a pure
    # function of zone config + registry (the identity_rects pattern;
    # state like the drained bool NEVER lands in this cache). Returns
    # [tile_runs, motif_runs]: tile_runs = typed floor overlays then wall
    # tiles as [x, y, w, h, ref] pixel rects, horizontally then
    # vertically merged where spans abut with the same ref; motif_runs
    # likewise for the motif glyph rects. Merging is byte-safe by
    # construction: every merged class is a solid alpha-255 color, spans
    # only merge when they tile EXACTLY (no overlap, no gap), and classes
    # keep their draw order (typed → walls → grid → motif; within a
    # class all rects are one color or — for typed — disjoint per tile,
    # so intra-class order cannot change a pixel).
    def static_runs(map, world)
      @static_runs_cache ||= {}
      @static_runs_cache[map] ||= begin
        ts = map.tile_size
        typed = typed_rects(map, world).map do |(tx, ty, ref)|
          [tx * ts, ty * ts, ts, ts, ref]
        end
        walls = []
        wall_specs = App::TileVariants.specs(map, world.tile_registry)
        map.rows.times do |ty|
          map.cols.times do |tx|
            next unless map.wall?(tx, ty)
            # v20 T5: walls draw by the tile's OWN render-ref (wall vs
            # wall_inner), not the :wall literal — '#' still resolves :wall,
            # so every existing zone's runs stay byte-identical.
            walls << [tx * ts, ty * ts, ts, ts,
                      App::TileVariants.wall_ref(wall_specs, map, tx, ty)]
          end
        end
        motif, = identity_rects(map)
        [merge_runs(typed) + merge_runs(walls),
         merge_runs(motif.map { |(x, y, w, h)| [x, y, w, h, :m] })
           .map { |(x, y, w, h, _)| [x, y, w, h] }]
      end
    end

    # Horizontal pass: extend a run while the next rect abuts it exactly
    # (same y/h/ref, x == run end). Vertical pass: stack runs of equal
    # x/w/ref whose y abuts. Input arrives row-major, so both passes are
    # deterministic — replays and both gate halves see identical lists.
    def merge_runs(rects)
      rows = []
      rects.each do |(x, y, w, h, ref)|
        last = rows.last
        if last && last[4] == ref && last[1] == y && last[3] == h &&
           last[0] + last[2] == x
          last[2] += w
        else
          rows << [x, y, w, h, ref]
        end
      end
      out = []
      open = {} # [x, w, ref] => index into out for the still-stackable rect
      rows.each do |(x, y, w, h, ref)|
        key = [x, w, ref]
        i = open[key]
        if i && out[i][1] + out[i][3] == y
          out[i][3] += h
        else
          open[key] = out.length
          out << [x, y, w, h, ref]
        end
      end
      out
    end

    def typed_rects(map, world)
      @typed_cache ||= {}
      @typed_cache[map] ||= App::TileVariants.rects(map, world.tile_registry)
    end

    def face_rects(map, world)
      @face_cache ||= {}
      @face_cache[map] ||= App::TileArt.rects(map, world.tile_registry)
    end

    # Drops read as PLACE (v11 rider): size is the primary depth channel —
    # band 0 keeps the pre-v11 magenta 10/14px (amount step), band 1 warm
    # rose 16px, band 2 ember/gold 18px behind a faint glow halo. The band
    # rides the record (stamped at spawn, like decay_frames) — no gradient
    # read here. Alpha still fades over the final third of the decay clock.
    def draw_drops(world)
      ts = world.map.tile_size
      world.drops.each do |d|
        band = d[:band] || 0
        outer, size, inner =
          case band
          when 2 then [DROP_BAND2, 16, [255, 235, 180]] # bright ember core
          when 1 then [DROP_BAND1, 14, [255, 215, 220]] # pale rose core
          else        [DROP_CORE, d[:amount] >= 2 ? 12 : 10, [250, 225, 255]]
          end
        frac = d[:frames_left].fdiv(d[:decay_frames])
        alpha = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
        tx, ty = d[:tile]
        # PREMIUM v22: a GEM, not a square — a diamond that bobs 2px and
        # throws a 4-point sparkle, with a soft ground shadow. Shape +
        # motion own the "pickup" read (the telegraph is a static square
        # frame; the gate tile a flat slab). Tick-driven: world.frame only.
        phase = (world.frame + tx * 7 + ty * 13) % 48
        bob = phase < 24 ? phase / 12 : (48 - phase) / 12   # 0,1,2,1
        cx = tx * ts + ts / 2.0
        cy = ty * ts + ts / 2.0 - bob
        half = size / 2
        Gosu.draw_rect(cx - half + 2, ty * ts + ts / 2.0 + half - 1, size - 4, 2,
                       Gosu::Color.new((alpha * 0.45).round, 0, 0, 0))
        if band == 2 # the glow halo
          (0...4).each do |k|
            r = half + 2 + k * 2
            Gosu.draw_rect(cx - r, cy - 1, r * 2, 2, Gosu::Color.new((alpha * (0.22 - k * 0.05)).round, outer.red, outer.green, outer.blue))
            Gosu.draw_rect(cx - 1, cy - r, 2, r * 2, Gosu::Color.new((alpha * (0.22 - k * 0.05)).round, outer.red, outer.green, outer.blue))
          end
        end
        oc = Gosu::Color.new(alpha, outer.red, outer.green, outer.blue)
        ic = Gosu::Color.new(alpha, *inner)
        edge = Gosu::Color.new(alpha, (outer.red * 0.45).round, (outer.green * 0.45).round, (outer.blue * 0.45).round)
        (-half..half).each do |dy|
          w = half - dy.abs
          next if w <= 0
          Gosu.draw_rect(cx - w - 1, cy + dy, 2 * w + 2, 1, edge)
          Gosu.draw_rect(cx - w, cy + dy, 2 * w, 1, oc)
          Gosu.draw_rect(cx - w + 2, cy + dy, [w - 3, 0].max, 1, ic) if dy < 0 && w > 3
        end
        # facet highlight + sparkle (phase-gated, so it TWINKLES)
        Gosu.draw_rect(cx - 1, cy - half + 2, 1, half - 2, Gosu::Color.new(alpha, 255, 255, 255))
        if phase % 24 < 8
          sp = Gosu::Color.new(alpha, 255, 255, 255)
          Gosu.draw_rect(cx + half - 1, cy - half - 1, 1, 5, sp)
          Gosu.draw_rect(cx + half - 3, cy - half + 1, 5, 1, sp)
        end
      end
    end

    # S2: ITEM drops - the catalog icon on a small dark plate, bobbing like the
    # gems (phase per tile), fading over the last third of its decay. Quads
    # path / missing icon: a bone square.
    def draw_item_drops(world)
      ts = world.map.tile_size
      world.item_drops.each do |d|
        frac = d[:frames_left].fdiv(d[:decay_frames])
        alpha = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
        tx, ty = d[:tile]
        phase = (world.frame + tx * 5 + ty * 9) % 48
        bob = phase < 24 ? phase / 12 : (48 - phase) / 12
        x = tx * ts + ts / 2 - 9
        y = ty * ts + ts / 2 - 9 - bob
        Gosu.draw_rect(x - 2, ty * ts + ts / 2 + 8, 22, 2, Gosu::Color.new((alpha * 0.45).round, 0, 0, 0))
        Gosu.draw_rect(x - 1, y - 1, 20, 20, Gosu::Color.new((alpha * 0.85).round, 16, 12, 12))
        if (ico = @item_icons&.icon(world.catalog.fetch(d[:id])&.icon))
          ico.draw(x + 1, y + 1, 0, 1, 1, Gosu::Color.new(alpha, 255, 255, 255))
        else
          Gosu.draw_rect(x + 3, y + 3, 12, 12, Gosu::Color.new(alpha, 205, 198, 180))
        end
        if d[:qty] > 1
          f = hud_font
          f.draw_text(d[:qty].to_s, x + 20 - f.text_width(d[:qty].to_s), y + 8, 1, 1, 1, Gosu::Color.new(alpha, 245, 240, 225))
        end
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

    def tell_edge_rgb = @display.fetch(:respawn_tell_edge_rgb)
    def tell_core_rgb = @display.fetch(:respawn_tell_core_rgb)
    def tell_max_alpha = @display.fetch(:respawn_tell_max_alpha)
    def tell_pulse_speed = @display.fetch(:respawn_tell_pulse_speed)

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
          draw_haloed_text(text, tx * ts + (ts - hud_font.text_width(text)) / 2,
                           ty * ts - 18, 10)
          # R-A2 BUY hint in the cue's text slot (y-32, one row above the
          # numeral) — content + suppression rules live in sustain_hint.
          if (hint = sustain_hint(world, s))
            draw_haloed_text(hint, tx * ts + (ts - hud_font.text_width(hint)) / 2,
                             ty * ts - 32, 10)
          end
        else
          price = world.station_price(s)
          next unless price && price.positive?
          text = "-#{price}"
          draw_haloed_text(text, tx * ts + (ts - hud_font.text_width(text)) / 2,
                           ty * ts - 18, 10)
        end
      end
    end

    # D2 (uiux M1 adoption, s75 — drafts/_d1d2-adoption-20260825.md): the
    # economy numerals (banked total, BUY hint, altar/vat price) are
    # world-anchored and the HUD carried counter scrolls over the world —
    # raw DROP_CORE purple measured 1.02:1 where it crossed pink walls
    # (uiux first-critique S4; adopted delta d2_price_halo.json). A thin
    # dark halo makes glyph-adjacent contrast ground-independent while
    # the purple identity stays. Mechanism = their harness verbatim:
    # union of the 1..px Chebyshev offset RINGS (the outermost ring alone
    # leaves slivers at stroke ends), drawn same-z before the glyph —
    # call order stacks within a z. Ledger beat numerals stay bare: the
    # BEAT_PANEL backing already controls their ground.
    def self.halo_offsets(px)
      (1..px).flat_map do |d|
        [-d, 0, d].product([-d, 0, d]).reject { |(dx, dy)| dx.zero? && dy.zero? }
      end
    end

    def draw_haloed_text(text, x, y, z)
      px = @display.fetch(:price_text_halo_px)
      if px.positive?
        hc = color(@display.fetch(:price_text_halo_rgb))
        Renderer.halo_offsets(px).each do |(dx, dy)|
          hud_font.draw_text(text, x + dx, y + dy, z, 1, 1, hc)
        end
      end
      hud_font.draw_text(text, x, y, z, 1, 1, DROP_CORE)
    end

    # N4 (uiux M6 adoption, s77 — drafts/_m5m6-adoption-20260825.md): the
    # light-valued floating glyph class (retarget cues, god mark, edge
    # pips) rendered raw over variable ground — worst ~1.01:1 on light
    # walls, and the off-screen-ally pips exist to be never-invisible. A
    # 1px near-black solid underdraw (the ring-underdraw grammar) makes
    # the boundary ground-independent; ONE shared key family on purpose
    # (one lever, one class). Alpha deliberately UNKEYED at 255 (C1
    # reasoning). Residual recorded, not solved: the dark hate cue rides
    # the class but the outline cannot fully carry it on dark grounds —
    # its color identity is the wall-critic arbitration above, untouched.
    # The chant-blue tell stays OUT (own surface, same dark-value logic);
    # drops keep size-as-depth custody.
    def draw_outlined_quad(x, y, size, col, z = 0)
      opx = @display.fetch(:glyph_outline_px)
      if opx.positive?
        Gosu.draw_rect(x - opx, y - opx, size + 2 * opx, size + 2 * opx,
                       color(@display.fetch(:glyph_outline_rgb)), z)
      end
      Gosu.draw_rect(x, y, size, size, col, z)
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
          draw_refusal_text(text, x + (ts - hud_font.text_width(text)) / 2,
                            y - 32)
        end
      elsif cue[:kind] == :level_required
        # T5 (P9/D3): the level-gate refusal — the provision_refused
        # grammar verbatim (the presser STANDS on the way tile: X-bar at
        # z 9 above bodies, text at z 10). The required level substitutes
        # into the locale row at draw time (the net.desync <N> idiom —
        # numerals never enter the flat K/V tables).
        Gosu.draw_rect(x + 6, y + ts / 2 - 2, ts - 12, 4, CUE_REFUSED, 9)
        Gosu.draw_rect(x + ts / 2 - 2, y + 6, 4, ts - 12, CUE_REFUSED, 9)
        if (text = station_cue_text(cue[:kind]))
          text = text.sub("<N>", cue[:n].to_s)
          draw_refusal_text(text, x + (ts - hud_font.text_width(text)) / 2,
                            y - 32)
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

    # D1 (uiux M1 adoption, s75 — drafts/_d1d2-adoption-20260825.md):
    # the refusal EXPLANATION line reads banner-cream on a small dark
    # backing chip — raw CUE_REFUSED caps measured 1.23:1 where letters
    # crossed light-green tiles (uiux first-critique S8; adopted delta
    # d1_cue_backing.json, re-measured at our wall). The X-bar keeps
    # CUE_REFUSED: the refusal IDENTITY stays red, only the text line
    # changes surface. Chip = the text's own padded line box (ledger-
    # panel style family), z 9 under the z-10 text, above bodies.
    def draw_refusal_text(text, x, y)
      w = hud_font.text_width(text)
      pad = @display.fetch(:cue_backing_pad)
      Gosu.draw_rect(x - pad, y - pad, w + 2 * pad, hud_font.height + 2 * pad,
                     color(@display.fetch(:cue_backing_rgb),
                           @display.fetch(:cue_backing_alpha)), 9)
      hud_font.draw_text(text, x, y, 10, 1, 1,
                         color(@display.fetch(:cue_text_rgb)))
    end

    # Bodies stay where they fell and fade out (critique: vanishing kills
    # erase the fight's history). Corpse-legibility pass (s74-verified
    # flywheel candidate, claimed 2026-08-26): the human remnant was
    # near-floor grey-on-grey and the drop marker covers the death tile,
    # so "fights leave history" was unreadable in honest play. Fix on the
    # shipped grammar: a 1px near-black rim (C1/N2/N4 family) fading WITH
    # the body, plus a keyed lift of the human base tone. Placement, fade
    # timing, drops, and sim stay untouched — presentation only.
    def draw_corpses(world)
      world.corpses.each do |c|
        alpha =
          if c[:container_id]
            140 # loaded: held at full strength while the container lives
          else
            age = world.frame - c[:at_frame]
            (140 * (1.0 - age.fdiv(Game::World::CORPSE_FADE_FRAMES))).clamp(0, 140).round
          end
        # PREMIUM v22 pass 3: with art, the corpse IS the kit's dead frame
        # (fading with the same alpha clock) — you see WHO fell. Quads path
        # keeps the legacy rect.
        if @art && c[:kit_name] && (img = App::Art::Body.dead_image(c[:kit_name], @art))
          ax, ay = @art.anchor
          img.draw(c[:x] - ax, c[:y] - ay, 0, 1, 1, Gosu::Color.new((alpha * 1.6).clamp(0, 255).round, 235, 225, 215))
          next
        end
        base = c[:faction] == :human ? human_corpse_rgb : [150, 80, 40]
        opx = @display.fetch(:corpse_outline_px)
        if opx.positive?
          Gosu.draw_rect(c[:x] + 4 - opx, c[:y] + 10 - opx,
                         SIZE - 8 + 2 * opx, SIZE - 14 + 2 * opx,
                         Gosu::Color.new(alpha, *@display.fetch(:corpse_outline_rgb)))
        end
        Gosu.draw_rect(c[:x] + 4, c[:y] + 10, SIZE - 8, SIZE - 14,
                       Gosu::Color.new(alpha, *base))
      end
    end

    def possess_rgb = @possess_rgb ||= @display.fetch(:possess_halo_rgb)

    # 24x3 bar 2px above the head-room: dark socket, red->orange fill by hp
    # fraction, 1px lighter lip. Pure function of (hp, max_hp).
    def draw_enemy_hp_bar(c, x, y)
      w = 24
      h = 3
      bx = x + SIZE / 2 - w / 2
      by = y - 14 - art_lift
      frac = c.hp.fdiv(c.max_hp).clamp(0.0, 1.0)
      Gosu.draw_rect(bx - 1, by - 1, w + 2, h + 2, Gosu::Color.new(230, 16, 10, 10))
      fw = (w * frac).round
      return if fw <= 0
      r = 235
      g = (60 + 120 * frac).round
      Gosu.draw_rect(bx, by, fw, h, Gosu::Color.new(255, r, g, 40))
      Gosu.draw_rect(bx, by, fw, 1, Gosu::Color.new(120, 255, 255, 230))
    end

    # The BOSS BAR: for the first boss/seizer on camera, a 260x10 bar under
    # the banner slot (top-center), its name above, phase pips below. Reads
    # the same truths as the nameplate/pips (hp, max_hp, boss_phase).
    def draw_boss_bar(world)
      return unless @display.fetch(:boss_bar)
      cam = world.camera(@local_seat)
      boss = world.humans.find do |h|
        !h.dead? && (h.kit[:boss] || h.kit[:seize]) &&
          h.x + SIZE >= cam.x && h.x <= cam.x + cam.view_w && h.y + SIZE >= cam.y && h.y <= cam.y + cam.view_h
      end
      return unless boss
      w = @display.fetch(:boss_bar_w)
      h = @display.fetch(:boss_bar_h)
      bx = (cam.view_w - w) / 2
      by = @display.fetch(:boss_bar_y)
      name = boss.kit_name == :challenger ? tr("challenger.name", "BOSS 1") : BOSS_NAMES.fetch(boss.kit_name, "BOSS")
      f = hud_font
      tx = cam.view_w / 2 - f.text_width(name) / 2
      Renderer.halo_offsets(1).each { |(dx, dy)| f.draw_text(name, tx + dx, by - 18 + dy, 20, 1, 1, Gosu::Color.new(255, 20, 14, 12)) }
      f.draw_text(name, tx, by - 18, 20, 1, 1, BANNER)
      Gosu.draw_rect(bx - 2, by - 2, w + 4, h + 4, Gosu::Color.new(255, 16, 10, 10), 20)
      Gosu.draw_rect(bx - 1, by - 1, w + 2, h + 2, Gosu::Color.new(255, 90, 40, 30), 20)
      Gosu.draw_rect(bx, by, w, h, Gosu::Color.new(255, 40, 16, 20), 20)
      frac = boss.hp.fdiv(boss.max_hp).clamp(0.0, 1.0)
      fw = (w * frac).round
      if fw.positive?
        Gosu.draw_rect(bx, by, fw, h, Gosu::Color.new(255, 200, 40, 50), 20)
        Gosu.draw_rect(bx, by, fw, 2, Gosu::Color.new(110, 255, 255, 230), 20)
      end
      # phase thresholds as notches on the socket; pips under the bar
      n = boss.boss_phase_count
      if n > 1
        phases = boss.kit.dig(:boss, :phases) || []
        phases.drop(1).each do |ph|
          nx = bx + (w * ph[:hp_pct] / 100.0).round
          Gosu.draw_rect(nx, by - 1, 1, h + 2, Gosu::Color.new(255, 235, 215, 190), 20)
        end
        cur = boss.boss_phase
        pw = 6
        gap = 3
        px0 = cam.view_w / 2 - (n * pw + (n - 1) * gap) / 2
        n.times do |i|
          px = px0 + i * (pw + gap)
          col = Gosu::Color.new(255, 190, 90, 40)
          if i == cur
            Gosu.draw_rect(px, by + h + 3, pw, pw, col, 20)
          else
            Gosu.draw_rect(px, by + h + 3, pw, 1, col, 20)
            Gosu.draw_rect(px, by + h + 3 + pw - 1, pw, 1, col, 20)
            Gosu.draw_rect(px, by + h + 3, 1, pw, col, 20)
            Gosu.draw_rect(px + pw - 1, by + h + 3, 1, pw, col, 20)
          end
        end
      end
    end

    # Ground halo: an ellipse of horizontal slices under the feet (outer
    # soft ring + brighter inner rim), plus an optional chevron above the
    # head that bobs 2px on a 40-frame cycle. Pure function of (x, y, frame).
    def draw_possession_halo(x, y, frame, rgb, chevron: true)
      cx = x + SIZE / 2.0
      cy = y + SIZE + 1
      rx, ry = @display.fetch(:possess_halo_rx), @display.fetch(:possess_halo_ry)
      outer = Gosu::Color.new(@display.fetch(:possess_halo_alpha), *rgb)
      rim = Gosu::Color.new(@display.fetch(:possess_halo_rim_alpha), *rgb)
      # Wall #4 (boss2_phases possessed_readable, 2026-09-06): the soft gold ellipse
      # was tuned on the pilot's DARK floors and barely read on the TOWER's light
      # stone. A 1px dark CONTOUR outside the gold rim (the ring-underdraw grammar,
      # cf. draw_outlined_quad) makes the halo ground-independent: it reads on
      # dark AND light floors. Drawn first, one pixel wider than every slice plus
      # one row above and below the ellipse.
      contour = Gosu::Color.new(@display.fetch(:possess_halo_contour_alpha), *@display.fetch(:possess_halo_contour_rgb))
      (-ry..ry).each do |dy|
        t = dy.to_f / (ry + 0.5)
        hw = Math.sqrt([1.0 - t * t, 0.0].max) * rx
        w = (hw * 2).round
        next if w <= 0
        Gosu.draw_rect((cx - hw).round - 1, (cy + dy).round, w + 2, 1, contour)
        Gosu.draw_rect((cx - hw).round + 1, (cy + dy).round + (dy.negative? ? -1 : 1), [w - 2, 1].max, 1, contour) if dy.abs == ry
      end
      (-ry..ry).each do |dy|
        t = dy.to_f / (ry + 0.5)
        hw = Math.sqrt([1.0 - t * t, 0.0].max) * rx
        w = (hw * 2).round
        next if w <= 0
        Gosu.draw_rect((cx - hw).round, (cy + dy).round, w, 1, outer)
        # rim = the two outermost pixels of every slice
        Gosu.draw_rect((cx - hw).round, (cy + dy).round, 2, 1, rim)
        Gosu.draw_rect((cx + hw).round - 2, (cy + dy).round, 2, 1, rim)
      end
      return unless chevron
      bob = ((frame % 40) < 20 ? (frame % 40) : 40 - (frame % 40)) / 10  # 0..2
      top = y - 7 - art_lift - bob
      fill = Gosu::Color.new(255, *rgb)
      edge = Gosu::Color.new(255, 40, 28, 12)
      # downward chevron: 4 slices narrowing to the tip, 1px dark edge, plus a
      # dark row ABOVE the widest slice and a 2px-wider edge (wall #4: a drop gem
      # on the tile behind the head - also a diamond - swallowed the marker; the
      # heavier dark contour makes it read as a MARKER, not a gem).
      Gosu.draw_rect((cx - 5).round - 2, top - 1, 14, 1, edge)
      [[10, 0], [8, 1], [6, 2], [4, 3], [2, 4]].each do |(w, k)|
        Gosu.draw_rect((cx - w / 2.0).round - 2, top + k, w + 4, 1, edge)
        Gosu.draw_rect((cx - w / 2.0).round, top + k, w, 1, fill)
      end
      Gosu.draw_rect((cx - 2).round, top + 5, 4, 1, edge)
      Gosu.draw_rect((cx - 1).round, top + 6, 2, 1, edge)
    end

    # Overhang of the art frame above the body box: anchor_y - the 2px the
    # placeholder grid used (so FASE 1 atlases lift 0). 0 without art.
    def art_lift
      return 0 unless @art
      @art_lift ||= [(@art.anchor[1] || 2) - 2, 0].max
    end

    def human_corpse_rgb
      @display.fetch(:corpse_human_rgb)
    end

    def draw_creature(c, world)
      lx, ly = lunge_offset(c)
      x = c.x + lx
      y = c.y + ly
      # FASE 1: sprites carry a 1px outline + weapon overhang in the frame's
      # 2px margin, which would eat the ring down to 2px — pad 4 under art
      # keeps the SAME 3 visible pixels the gate learned on quads.
      rp = @art ? 4 : 3
      if c.equal?(world.possessed(@local_seat))
        if @art
          # PREMIUM v22: the possessed body stands on a warm GROUND HALO
          # (soft gold ellipse under the feet) and wears a small chevron
          # bobbing above the head — the ARPG "this one is you" grammar,
          # replacing the white square. Tick-driven bob (world.frame).
          draw_possession_halo(x, y, world.frame, possess_rgb)
        else
          Gosu.draw_rect(x - rp, y - rp, SIZE + rp * 2, SIZE + rp * 2, POSSESSED_RING)
        end
      elsif c.faction == :pack && world.controlled?(c)
        # v17 decision 10: seat identity is RINGS ONLY — the partner's body
        # carries the second color (display.json), labels untouched.
        # Unreachable single-seat (the only controlled body IS possessed).
        if @art
          draw_possession_halo(x, y, world.frame, @display.fetch(:partner_ring_rgb), chevron: false)
        else
          Gosu.draw_rect(x - rp, y - rp, SIZE + rp * 2, SIZE + rp * 2, partner_ring)
        end
      end
      # PREMIUM v22: head-room. Sprites taller than the body box carry their
      # head above y; every above-body overlay lifts by the art's overhang
      # so the mark/cue/nameplate never sit ON a face (0 under quads).
      lift = art_lift
      if c.faction == :pack && c.marked?
        draw_outlined_quad(x + SIZE / 2 - 4, y - 10 - lift, 8, GOD_MARK)
        Gosu.draw_rect(x + SIZE / 2 - 2, y - 8 - lift, 4, 4, color(world.map.palette[:floor]))
      end
      draw_taunt_underline(c, x, y) if c.faction == :human && c.taunted_target
      # v15 seizure state: the exact mirror of the taunt underline in the
      # chant's deep blue — rust says "they come to you", blue says "your
      # flesh goes to him". Pack-only slot: no collision with taunt (human).
      draw_seized_underline(c, x, y) if c.faction == :pack && c.seized_by
      draw_nameplate(c, x, y) if c.faction == :human && (c.kit[:seize] || c.kit[:boss])
      # PREMIUM v22 pass 6: a WOUNDED hostile (hp < max, not a boss - the boss
      # bar is on screen) wears a tiny hp bar over its head; full hp = no bar
      # (the ARPG grammar: the bar IS the wound).
      if c.faction == :human && !c.kit[:boss] && !c.kit[:seize] && c.hp < c.max_hp &&
         @display.fetch(:enemy_hp_bars)
        draw_enemy_hp_bar(c, x, y)
      end
      if c.faction == :human && (cue = c.retarget_cue)
        draw_outlined_quad(x + SIZE / 2 - 4, y - 10 - lift, 8, RETARGET_CUE.fetch(cue[:cause]))
      end
      # Outline IFF pressuring AND on/near the ring with open sight to the
      # local body (Signage.pressure_outline?, display pressure_outline_*).
      draw_pressure_outline(c, x, y, world) if c.faction == :human && pressure_outline?(world, c)
      if c.faction == :human && c.telegraphing?
        swell = 8
        if c.action_config&.dig(:petrify)
          # FASE 4.2 petrify: the windup telegraph goes STONE (grey edge,
          # pale-grey core) — "this will freeze you", a third family beside
          # the red/yellow hurt telegraph and the volley's orange brackets.
          Gosu.draw_rect(x - swell / 2, y - swell / 2, SIZE + swell, SIZE + swell,
                         Gosu::Color.new(255, *@display.fetch(:petrify_edge_rgb)))
          Gosu.draw_rect(x - 2, y - 2, SIZE + 4, SIZE + 4,
                         Gosu::Color.new(250, *@display.fetch(:petrify_core_rgb)))
        else
          Gosu.draw_rect(x - swell / 2, y - swell / 2, SIZE + swell, SIZE + swell, TELEGRAPH_EDGE)
          Gosu.draw_rect(x - 2, y - 2, SIZE + 4, SIZE + 4, TELEGRAPH_CORE)
        end
        # The body stays visible INSIDE the flare: two adjacent telegraphing
        # humans otherwise read as an ownerless ground-tile pattern,
        # indistinguishable from Volley target tiles (gate critique finding).
        # Sprite path: the windup frame sits inside the flare (the core
        # shows through the frame's transparent margin); quad fallback
        # keeps the inset bone square.
        unless App::Art::Body.draw(c, world, x, y, @art)
          Gosu.draw_rect(x + 5, y + 5, SIZE - 10, SIZE - 10, HUMAN_BODY)
        end
      else
        draw_body(c, world, x, y)
      end
      draw_facing_notch(c, x, y) if @art_notch || @art.nil?
      draw_attack(c, world.map.tile_size) if c.faction == :pack
      # FASE 4.3 blink arrival tell: a violet hollow square snapping shut on
      # the body over the flash frames — "it was not there a moment ago".
      draw_blink_flash(c, x, y) if c.respond_to?(:blink_flash?) && c.blink_flash?
      draw_aura(c, world) if c.faction == :human && c.kit[:aura]
    end

    # FASE 4.6 aura tell: a hollow ember square at the aura's reach that
    # BREATHES on the burn cadence (bright at the tick, fading to the next)
    # — "stand here and you cook". Distinct from the taunt pulse (rust,
    # expanding once) and the totem ring (green): steady, hot, sized to
    # the radius. Tick-driven: reads world.frame only.
    def draw_aura(c, world)
      aura = c.kit[:aura]
      ts = world.map.tile_size
      period = [aura[:period_frames], 1].max
      phase = (world.frame % period).fdiv(period)
      alpha = (@display.fetch(:aura_alpha_max) * (1.0 - phase * 0.7)).round
      reach = aura[:radius_tiles] * ts + ts / 2
      cx = c.tile[0] * ts + ts / 2
      cy = c.tile[1] * ts + ts / 2
      col = Gosu::Color.new(alpha, *@display.fetch(:aura_rgb))
      t = 2
      Gosu.draw_rect(cx - reach, cy - reach, reach * 2, t, col)
      Gosu.draw_rect(cx - reach, cy + reach - t, reach * 2, t, col)
      Gosu.draw_rect(cx - reach, cy - reach, t, reach * 2, col)
      Gosu.draw_rect(cx + reach - t, cy - reach, t, reach * 2, col)
    end

    def draw_blink_flash(c, x, y)
      total = c.kit.dig(:blink, :flash_frames) || 8
      k = total - c.instance_variable_get(:@blink_flash) # 0 → total
      grow = 10 - (10 * k / [total, 1].max)
      col = Gosu::Color.new(230, *@display.fetch(:blink_flash_rgb))
      t = 2
      Gosu.draw_rect(x - grow, y - grow, SIZE + grow * 2, t, col)
      Gosu.draw_rect(x - grow, y + SIZE + grow - t, SIZE + grow * 2, t, col)
      Gosu.draw_rect(x - grow, y - grow, t, SIZE + grow * 2, col)
      Gosu.draw_rect(x + SIZE + grow - t, y - grow, t, SIZE + grow * 2, col)
    end

    # FASE 1 body: sprite (tinted for hurt/ally-dim/seized) or the legacy
    # quad + overlays. The tint reproduces the quad grammar the gate already
    # judges — crimson (never white) pack flash, dimmed unpossessed kin,
    # blue weight while seized — by color MODULATION on the sprite.
    def draw_body(c, world, x, y)
      tint = sprite_tint(c, world)
      return if App::Art::Body.draw(c, world, x, y, @art, tint: tint)
      Gosu.draw_rect(x, y, SIZE, SIZE, body_color(c, world))
      Gosu.draw_rect(x, y, SIZE, SIZE, ALLY_DIM) if ally?(c, world)
      # v16 (d): the seized body carries visual WEIGHT — darkened toward
      # the chant's deep blue for the whole hold (underline keeps the
      # clock; this makes the state read at body scale).
      if c.faction == :pack && c.seized_by
        Gosu.draw_rect(x, y, SIZE, SIZE,
                       Gosu::Color.new(@display.fetch(:seized_weight_alpha), *seized_rgb))
      end
    end

    def sprite_tint(c, world)
      return nil unless @art
      r, g, b = 255, 255, 255
      # pass 5: the crimson flash means HIT (hurt window only). A dodging
      # body (i-frames, not hurt) reads cool instead — "untouchable", not
      # "bleeding".
      # ...and it holds for the whole hurt window (no odd/even blink: the
      # untinted hurt frame of a pale kit read WHITE on the even frames -
      # tower2_run re-gate 2026-09-05; "never white" is the law, blinking is not)
      flash = c.faction == :pack && c.hurt?
      if flash
        r, g, b = @display.fetch(:art_hurt_tint_rgb)
      elsif c.faction == :pack && c.iframes? && !c.hurt?
        r, g, b = @display.fetch(:art_dodge_tint_rgb)
      elsif c.faction == :human && c.hurt?
        r, g, b = @display.fetch(:art_human_hurt_tint_rgb)
      end
      if ally?(c, world)
        dr, dg, db = @display.fetch(:art_ally_dim_rgb)
        r, g, b = r * dr / 255, g * dg / 255, b * db / 255
      end
      if c.faction == :pack && c.seized_by
        sr, sg, sb = @display.fetch(:art_seized_tint_rgb)
        r, g, b = r * sr / 255, g * sg / 255, b * sb / 255
      end
      # FASE 4.5 poison: sick-green pulse (every other 6-frame window) —
      # no other body state owns green; the DOT reads without a number.
      if c.respond_to?(:poisoned?) && c.poisoned? && ((world.frame / 6) % 2).zero?
        pr, pg, pb = @display.fetch(:art_poison_tint_rgb)
        r, g, b = r * pr / 255, g * pg / 255, b * pb / 255
      end
      # S3: burn pulse (orange) on the OTHER 6-frame window, so a body that is
      # both poisoned and burning alternates green/orange.
      if c.respond_to?(:burning?) && c.burning? && ((world.frame / 6) % 2) == 1
        br, bg, bb = @display.fetch(:art_burn_tint_rgb)
        r, g, b = r * br / 255, g * bg / 255, b * bb / 255
      end
      return nil if [r, g, b] == [255, 255, 255]
      Gosu::Color.new(255, r, g, b)
    end

    def ally?(c, world) = c.faction == :pack && !c.equal?(world.possessed(@local_seat))

    def body_color(c, world)
      if c.respond_to?(:poisoned?) && c.poisoned? && ((world.frame / 6) % 2).zero?
        Gosu::Color.new(255, *@display.fetch(:art_poison_tint_rgb))
      elsif c.faction == :pack && c.iframes? && (world.frame / 3).even?
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

    # Hostile-red flash on the enemy's action tiles for the active window
    # only (1–6 sim frames by kit). Same inset grammar as the pack SLASH,
    # hostile family (telegraph-edge red, never the pack's white-cyan) —
    # attribution, not warning: by the active window the hit is landing.
    def draw_enemy_strike(c, ts)
      return unless c.faction == :human
      cfg = c.action_config
      arc = cfg && cfg[:arc]
      if c.attack_state == :windup && %w[dash beam].include?(arc)
        # FASE 4.4 ground telegraph: the charge run / the beam line is
        # drawn on the FLOOR during the windup (a fourth telegraph family:
        # "this lane is about to be hit") — dark red for the charge, dark
        # ember for the beam, both distinct from body flares and volley.
        rgb = arc == "dash" ? @display.fetch(:charge_telegraph_rgb) : @display.fetch(:beam_telegraph_rgb)
        col = Gosu::Color.new(150, *rgb)
        inset = arc == "dash" ? 10 : 12
        c.action_tiles.each do |(tx, ty)|
          Gosu.draw_rect(tx * ts + inset, ty * ts + inset, ts - inset * 2, ts - inset * 2, col)
        end
        return
      end
      return unless c.attack_state == :active
      col, inset =
        case arc
        when "beam" then [Gosu::Color.new(235, *@display.fetch(:beam_stroke_rgb)), 6]
        when "dash" then [Gosu::Color.new(220, *@display.fetch(:charge_stroke_rgb)), 8]
        else [ENEMY_STRIKE, 4]
        end
      c.action_tiles.each do |(tx, ty)|
        Gosu.draw_rect(tx * ts + inset, ty * ts + inset, ts - inset * 2, ts - inset * 2, col)
      end
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

    # FASE 5: phase pips under the nameplate — one hollow rust square per
    # phase, the CURRENT one filled. A boss that changed its attacks says so
    # at body scale (the "objective vacuum" answer starts with a legible
    # fight arc). Presentation only: reads boss_phase (f(hp)).
    def draw_boss_phase_pips(c, x, y)
      n = c.boss_phase_count
      cur = c.boss_phase
      col = Gosu::Color.new(255, *@display.fetch(:boss_pip_rgb))
      w = 6
      gap = 3
      x0 = x + SIZE / 2 - (n * w + (n - 1) * gap) / 2
      py = y - 12 - art_lift
      n.times do |i|
        px = x0 + i * (w + gap)
        if i == cur
          Gosu.draw_rect(px, py, w, w, col)
        else
          Gosu.draw_rect(px, py, w, 1, col)
          Gosu.draw_rect(px, py + w - 1, w, 1, col)
          Gosu.draw_rect(px, py, 1, w, col)
          Gosu.draw_rect(px + w - 1, py, 1, w, col)
        end
      end
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
      radius = @display.fetch(:writ_radius_tiles) * world.map.tile_size
      r = App::Writ.rects(cx:, cy:, radius:, view_w: cam.view_w, view_h: cam.view_h)
      out = Gosu::Color.new(@display.fetch(:writ_out_alpha), 0, 0, 0)
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
    # N2 (uiux M6 adoption, s77 — drafts/_m5m6-adoption-20260825.md): the
    # 10px cream plate is the smallest type in the game and walks past
    # light walls (~3:1 worst) — the D2 halo grammar makes it ground-
    # independent while the bone identity and size stay.
    BOSS_NAMES = { challenger: "BOSS 1", serpent_boss: "BOSS 2", ember_boss: "BOSS 4" }.freeze

    def draw_nameplate(c, x, y)
      name = c.kit_name == :challenger ? tr("challenger.name", "BOSS 1") : BOSS_NAMES.fetch(c.kit_name, "BOSS")
      draw_boss_phase_pips(c, x, y) if c.respond_to?(:boss_phase_count) && c.boss_phase_count > 1
      f = nameplate_font
      tx = x + SIZE / 2 - f.text_width(name) / 2
      ty = y - 24 - art_lift
      hpx = @display.fetch(:nameplate_halo_px)
      if hpx.positive?
        hc = color(@display.fetch(:nameplate_halo_rgb))
        Renderer.halo_offsets(hpx).each do |(dx, dy)|
          f.draw_text(name, tx + dx, ty + dy, 5, 1, 1, hc)
        end
      end
      f.draw_text(name, tx, ty, 5, 1, 1, BANNER)
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
        cycle = @display.fetch(:chant_ring_cycle_frames)
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
          # T3 regression fix (s46, BOSS 1 / challenger gate catch): the tell rides at
          # z 15 — above every z-0 HUD rect (level strip, hp bars), below
          # HUD numerals (z 20). A safety cue ("he is calling THAT body")
          # must never be buried by chrome; frames without a pinned vessel
          # are byte-identical (these two rects are the only draws gated on
          # chant_target).
          Gosu.draw_rect(t.x + SIZE / 2 - 4, t.y - 20, 8, 8,
                         Gosu::Color.new(255, *chant_rgb), 15)
          Gosu.draw_rect(t.x + SIZE / 2 - 2, t.y - 18, 4, 4,
                         color(world.map.palette[:floor]), 15)
        end
      end
    end

    def chant_rgb = @chant_rgb ||= @display.fetch(:chant_ring_rgb)
    def seized_rgb = @seized_rgb ||= @display.fetch(:seized_underline_rgb)
    def partner_ring = @partner_ring ||= Gosu::Color.new(255, *@display.fetch(:partner_ring_rgb))
    def nameplate_font = @nameplate_font ||= Gosu::Font.new(@display.fetch(:nameplate_font_size))

    # Taunt cast tell (A0.6): one continuous expanding hollow SQUARE outline —
    # square because range is Chebyshev (a circle under-reads the corners),
    # continuous because per-tile marks would read as volley brackets.
    # v16 (e): the FLASH is the primary channel (solid bright body-rect for
    # the first frames), shards are the secondary motion read — geometry is
    # pure integer math in App::KillPop (deterministic by construction).
    def draw_kill_pops(world)
      ts = world.map.tile_size
      flash_frames = @display.fetch(:kill_pop_flash_frames)
      flash = color(@display.fetch(:kill_pop_flash_rgb))
      shard = color(@display.fetch(:kill_pop_shard_rgb))
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

    # T3 (P4): the level-up beat's world-located half — gold shards fly
    # from every living pack tile. Shards ONLY, no flash: white flash =
    # spawn/holy (hurt_flash_not_white family), and the co-firing kill pop
    # at the victim tile keeps its white flash — color is what separates
    # the two pop families on the boundary kill.
    def draw_level_pops(world)
      ts = world.map.tile_size
      shard = color(@display.fetch(:level_pop_shard_rgb))
      world.level_up_pops.each do |p|
        App::KillPop.shards(tile: p[:tile], phase: p[:phase], frames_left: p[:frames_left],
                            pop_frames: p[:pop_frames], ts: ts).each do |x, y, size|
          Gosu.draw_rect(x, y, size, size, shard)
        end
      end
    end

    def draw_taunt_pulses(world)
      ts = world.map.tile_size
      world.taunt_pulses.each do |p|
        draw_pulse_ring(p, ts, TAUNT_RUST)
      end
    end

    # v20 T4: the totem's heal pulse — same expanding square-ring grammar
    # as a taunt pulse; the family separator is COLOR (heal green vs taunt
    # rust), never shape. Ring covers the sim radius at full expansion, so
    # what the player reads as "in range" IS the Chebyshev truth.
    def draw_totem_pulses(world)
      ts = world.map.tile_size
      world.totem_pulses.each do |p|
        draw_pulse_ring(p, ts, TOTEM_HEAL)
      end
    end

    def draw_pulse_ring(p, ts, base)
      progress = 1.0 - p[:frames_left].fdiv(p[:pulse_frames])
      reach = (p[:range_tiles] * ts * progress).round
      cx = p[:tile][0] * ts + ts / 2
      cy = p[:tile][1] * ts + ts / 2
      alpha = (220 * (1.0 - progress * 0.6)).round
      col = Gosu::Color.new(alpha, base.red, base.green, base.blue)
      thick = 3
      Gosu.draw_rect(cx - reach, cy - reach, reach * 2, thick, col)
      Gosu.draw_rect(cx - reach, cy + reach - thick, reach * 2, thick, col)
      Gosu.draw_rect(cx - reach, cy - reach, thick, reach * 2, col)
      Gosu.draw_rect(cx + reach - thick, cy - reach, thick, reach * 2, col)
    end

    # PREMIUM v22: the HUD panel lives in App::Hud (portraits, framed bars,
    # numerals, LEVEL strip, COINS/POTION chips). Quads path (no art) keeps
    # the same panel with kit-colored portrait squares.
    def draw_hud(world)
      @hud ||= App::Hud.new(display: @display, strings: @strings, art: @art, kit_body: KIT_BODY,
                            hp_back: HP_BACK, hp_dead: HP_DEAD, drop_core: DROP_CORE, item_icons: @item_icons)
      @hud.acts = @fx.acts(world)
      @hud.draw(world, @local_seat)
    end

    # B1-T2 (spec D5): the persistent SAFE chip — the zone banner is
    # transient (zone_banner_frames), a sanctuary is a STATE (Tibia
    # PZ-icon touchstone), so the chip renders every frame the active
    # zone is safe: small type on a quiet near-black backing (overlay
    # vocabulary) under the level strip in the pack status block.
    # Pure zone read — replay determinism holds; strings via the v13
    # resolver (EN fallback keeps a bare Renderer.new drawable).
    def draw_safe_chip(world)
      return unless world.map.safe
      text = tr("safe.chip", "SAFE")
      x = @display.fetch(:safe_chip_x)
      y = @display.fetch(:safe_chip_y)
      pad = 6
      Gosu.draw_rect(x, y, hud_font.text_width(text) + pad * 2, 18,
                     Gosu::Color.new(@display.fetch(:safe_chip_backing_alpha), *BEAT_PANEL))
      hud_font.draw_text(text, x + pad, y + 2, 20, 1, 1,
                         color(@display.fetch(:safe_chip_rgb),
                               @display.fetch(:safe_chip_alpha)))
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
        draw_outlined_quad(px, py, 10, KIT_BODY[m.kit_name], 21) # above the minimap plate
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
      # T3 (decision 5): an optional locale-invariant suffix (" N") lands
      # AFTER translation — numerals never enter the flat K/V string tables.
      text = "#{text}#{entry[:suffix]}" if entry[:suffix]
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
      s = App::Stamp.scale(age:, in_frames: @display.fetch(:stamp_in_frames),
                           in_scale: @display.fetch(:stamp_in_scale))
      a = App::Stamp.alpha(frames_left:, frames_total:)
      col = Gosu::Color.new(a, BREACH_GOLD.red, BREACH_GOLD.green, BREACH_GOLD.blue)
      w = font.text_width(text) * s
      h = font.height * s
      cx = view_width(world) / 2.0
      cy = top + font.height / 2.0
      font.draw_text(text, cx - w / 2, cy - h / 2, 10, s, s, col)
      pad = @display.fetch(:stamp_rule_pad) * s
      rule_h = @display.fetch(:stamp_rule_h) * s
      rule_col = color(@display.fetch(:stamp_rule_rgb), a)
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
      rgb = @display.fetch(:seal_mark_rgb)
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
                      frames_total: line.fetch(:frames_total, @display.fetch(:breach_banner_frames)),
                      top: @display.fetch(:breach_line_top))
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

    # Flywheel fix (2026-08-19, critique issue 2 — verified PARTIAL): the
    # possessed body's own hurt window (creature.rb take_hit, 8 sim frames)
    # already flickers the body crimson, but at body scale it escapes a
    # player watching the whole fight. A thin crimson EDGE frame carries
    # the same state at screen scale: "that hit landed on ME". Edge bars
    # only — the full-screen flood stays the stagger veil's read (and the
    # wipe veil's). Crimson stays in the pack-hurt family (never white —
    # walled check). Pure reader of hurt? — replay determinism holds.
    def draw_hurt_vignette(world)
      w = view_width(world)
      h = view_height(world)
      t = @display.fetch(:hurt_vignette_px)
      col = Gosu::Color.new(@display.fetch(:hurt_vignette_alpha), 220, 45, 35)
      Gosu.draw_rect(0, 0, w, t, col)
      Gosu.draw_rect(0, h - t, w, t, col)
      Gosu.draw_rect(0, t, t, h - t * 2, col)
      Gosu.draw_rect(w - t, t, t, h - t * 2, col)
    end

    # Registration beat (fight-ledger spec; presentation iteration 2026-08-11):
    # 1-3 glyph+number lines on a dark contrast panel, centered just above the
    # avatar (the camera keeps the possessed body at screen center — this IS
    # player-anchored). Glyph grammar is the game's own: filled square =
    # acquired value, hollow pip = pile-on-a-corpse (recoverable, calm), dark
    # square = destroyed (gone). No words — nothing blocks on the bible.
    # Entrance: scale pop 1.35→1.0 + additive flash; exit: alpha fade over the
    # final third of beat_left (the drop-decay grammar). Wipe recaps sit lower
    # (ledger_wipe_y), clear of the veil's center field (the v16 owner order
    # removed the wipe TEXT — the veil + recap ARE the wipe's delivery; stale
    # "64pt wipe line" reference caught by the uiux M5 audit). RENDER-ONLY:
    # everything is a pure function of the beat record — replay determinism
    # holds. Z within the block: panel 29, glyphs+text 30, flash 31.
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
    def hud_font = @hud_font ||= Gosu::Font.new(14)
    def ledger_font = @ledger_font ||= Gosu::Font.new(16, bold: true)
    # Beat tally fonts, created at target size — glyphs only blur during the
    # brief >1.0 pop overshoot (intentional punch).
    def ledger_line_font = @ledger_line_font ||= Gosu::Font.new(26, bold: true)
    def ledger_net_font = @ledger_net_font ||= Gosu::Font.new(42, bold: true)

    def ledger_pop_frames = @display.fetch(:ledger_pop_frames)
    def ledger_flash_frames = @display.fetch(:ledger_flash_frames)
    def ledger_flash_alpha = @display.fetch(:ledger_flash_alpha)
    def ledger_panel_alpha = @display.fetch(:ledger_panel_alpha)
    def ledger_block_y = @display.fetch(:ledger_block_y)
    def ledger_wipe_y = @display.fetch(:ledger_wipe_y)
  end
end
