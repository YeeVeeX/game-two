# Receipt — lane `e3-presentation` (v22 ticket E3, presentation truth)

RECEIPT: e3-presentation f880c7c READY b3 prompt iff verb (own tile bank/altar/vat/seal|rope_spot) · b4 minimap ways by Renderer.way_locked? (gold open / cold-grey locked) · b5 38 knobs written + 176 strict fetches + display_knobs_test · F-A3-1 safe_chip_y 138 · suite 1519 runs green · canaries YES x3

Branch `lane/e3-presentation` (from `junior/premium-build` @ 13a223c). Code head = `f880c7c`; this receipt lands as the
commit after it (receipt-only). Fence `ruby tools/lane_guard.rb e3-presentation --trust junior/premium-build` rc 0 before
every commit (5 code commits: a1cec35 b5 · 61df059 F-A3-1 · c6abbf5 b3 · c986608 b4 · f880c7c reviewer P1).

## Evidence (headless only — no window opened)
- `bundle exec rake` → `1519 runs, 89223 assertions, 0 failures, 0 errors, 0 skips`
- `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run` → `= ACTIVE bank?` **YES / YES / YES** (sim untouched)
- `src/app/window.rb` untouched; `src/game/**`, `src/core/**`, `harness/**`, `docs/**` untouched.
- Byte-identity (b5): mechanical check — every one of the 38 written values `==` the removed code default (script in
  the lane report); the only existing key whose value moved is `safe_chip_y` (F-A3-1, by order).

## Pieces
1. **b5** `data/display.json` +38 rows (values = the code defaults verbatim); every `display.fetch(:k, default)` in
   `src/app/*.rb` (176 calls, 11 files) → strict `fetch(:k)`; `hud_plate_rect` = ONE row, two readers (hud.rb:52,
   renderer.rb exit arrows). `Renderer.new` with no `display:` now reads `data/display.json` (`DISPLAY_PATH`) so a bare
   construct stays drawable. Test `test/app/display_knobs_test.rb` (4): existence + no-default + optional-marker law.
2. **F-A3-1** `safe_chip_y` 98 → 138 (only that number).
3. **b3** `Renderer.interact_verb(map, tile)` + `Renderer#interact_prompt_for(world)` (pure) mirror
   `World#interact` → `interact_station` (bank/altar/vat/seal; totem = no-op) / `interact_rope` (rope_spot) on the
   possessed's OWN tile; `draw_interact_prompt` reads the decision. Test `test/app/interact_prompt_test.rb` (7): each
   station type, adjacent tiles, totem, rope_spot vs stairs, empty tile, real World + bound glyph, switch/dead body.
   No `World#interact_available?` needed (map read suffices) — no PATCH REQUEST for it.
4. **b4** `Minimap#way_color(map, world, tx, ty)` (pure): open = zone palette transition gold (fallback row
   `minimap_way_open_rgb` [235,190,90]), locked = `minimap_way_locked_rgb` [120,130,150], decided by
   `App::Renderer.way_locked?` (the signage + exit-arrow predicate — no list of its own); zone image cache keyed by
   `[map, locked tiles]` so a level-up / breach / boss fact repaints once. Test `test/app/minimap_test.rb` (5):
   dungeon_1 requires_level 8 (grey → gold at level 8), basement_2 sealed (grey → gold after breach) + rope gold,
   non-way nil, agreement with `Renderer.way_locked?` for every way, cache key flips.

## Wall scripts whose surfaces changed (integrator's Rule 2 gates — I did not open a window)
- **Minimap lock color** (zones with a locked way; every reel with a HUD there): `town_gates`, `toll_pocket`,
  `floor1_run`, `floor2_run`, `floor3_run`, `zone8_crossing`, `multi_floor_descent`, `tower2_run`, `tower3_run`,
  `brasa1_run`, `brasa2_run`, `level_gate`, `menu_tour`, `boss1_writ`, `blink_arrival`, `dash_strike_rip`,
  `lobber_reach`, `lobber_volley`, `totem_pulse`.
- **INTERACT prompt** (station zones — prompt now absent beside stations/on the totem, present on rope_spot):
  `ledger_loop`, `world_loop`, `vat_economy`, `sustain_run`, `totem_pulse`, `toll_pocket`, `town_gates` + every
  nest-start script that walks a station.
- **SAFE chip y** (safe/hub zones): every nest/zone_7/camp reel with the HUD — `world_loop`, `ledger_loop`,
  `town_gates`, `safe_boundary`, `menu_tour` (if HUD shown), `critic_reel`.
- Suggested minimum set (brief's candidates + the lock-bearing ones): `town_gates`, `ledger_loop`, `world_loop`,
  `basement_pocket`, `menu_tour`, `toll_pocket`, `floor3_run`, `zone8_crossing`.

## PATCH REQUESTS (files outside my `owns`)
1. **d12 — `harness/gate_checks.json`, row `id: minimap_reads` (line ~345), replace the `check` text with:**
   "A small framed RADAR box sits top-right in every frame with the HUD: the zone's layout in miniature (walls in the
   zone's wall color, floor darker, water blue), OPEN ways as GOLD dots and LOCKED ways (level, seal or boss fact not
   yet met) as COLD GREY dots - gold means walkable, the same law as the floor signage, so a way that is a dark slab
   on camera is a grey dot on the radar and a glowing way is a gold dot; a magenta dot for stations, small RED dots
   for hostiles, kit-colored dots for pack bodies and one GOLD dot with a dark ring for the possessed — the pattern
   plausibly matches what is on camera (a hostile beside you on camera = a red dot beside the gold dot). It never
   covers the zone banner (top-center) nor the HUD plate (top-left). If no HUD frame is present, pass with why='not
   exercised by this script'."
   Why: today's row says "gold dots for open ways/stations" AND "a magenta dot for stations" (contradiction) and
   names no locked color; b4 now paints locked ways grey.
2. **(small, optional) `harness/gate_checks.json`, row `id: interact_prompt_reads` (line ~369):** the row already says
   "stands at a STATION (bank, altar, vat, seal) ... gone once the body leaves the station" — b3-true. Suggested
   additive clause after "'H INTERACT')": ", and ON a rope spot (the climb-back way); a body merely BESIDE a station,
   or on a totem, shows NO prompt". Why: the two new facts (rope prompts; beside/totem never) become judgeable.

## Notes for the integrator (not changes)
- `minimap_way_open_rgb` is a fallback only reached by a map whose palette names no `transition` (all 20 zones name
  one) — kept for the fixture path, byte-faithful to the old `|| [235,190,90]`.
- `renderer.rb` 2099 → 2124 lines (+25: the pure b3 extraction + comments); no formal cap, flagged per the brief.
- Four pre-existing keys had a code default that DIFFERED from the JSON value (`art_facing_notch`,
  `art_human_hurt_tint_rgb`, `art_ally_dim_rgb`, `breach_line_top`) — the JSON already won on screen; nothing moved.

## Helpers
- `scout` (read-only, async) → mapped `interact`/`interact_station`/`interact_rope` (own tile; bank/altar/vat/seal;
  totem no-op; rope via `transition_at`), `Renderer.way_locked?` as the single lock predicate, the 176 fetch sites and
  the 38 missing keys (matched my own scan), zero partial-display constructions in test/ or harness/.
- `reviewer` (read-only, async) → "OK with notes, no blockers"; P1 `ControlsOverlay.new(display:)` got the raw nil on a
  bare `Renderer.new` → fixed in f880c7c with a test that fails without the fix; NITs (comment "IFF" overstated →
  reworded; open-rgb fallback reachability → noted above; renderer growth → noted).
