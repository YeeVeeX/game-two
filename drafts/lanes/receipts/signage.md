# Receipt — lane `signage` (renderer.rb extraction byte-inert + pressure outline only when the body IS on the ring)

RECEIPT: signage 7dcb601 READY c1 658e5a1 App::Signage extracted byte-inert (renderer.rb 2124 -> 1969) · c2 7dcb601 Signage.pressure_outline? = :pressuring AND Chebyshev <= 3 (pressure_ring_tiles 2 + 1) AND sight_open? (presentation Bresenham, NOT the 8-way sim ray) · display rows pressure_outline_max_tiles 3 / pressure_outline_needs_line true · suite 1534/0 · canaries YES x3 · sim/digest untouched

Branch `lane/signage` (from `junior/premium-build` @ 193e148), pushed to origin. Two code commits, in order, fence
`ruby tools/lane_guard.rb signage --trust junior/premium-build` rc 0 before each: **658e5a1** (commit 1) · **7dcb601**
(commit 2). A third commit carries this receipt + the reviewer's two P2 test-hygiene fixes + one comment (no behaviour;
see §Review). No window opened at any point.

## Evidence (verbatim, headless only)
- commit 1: `bundle exec rake` -> `1525 runs, 89440 assertions, 0 failures, 0 errors, 0 skips`
- commit 2: `bundle exec rake` -> `1534 runs, 89493 assertions, 0 failures, 0 errors, 0 skips`
- `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run` (identical after both commits):
  `| world_loop | e0b1f38f | YES |` · `| brasa2_run | 3fd04895 | YES |` · `| floor3_run | 648810ff | YES |`
- fence: `lane_guard signage: OK (3 path(s) inside the fence; brief @ junior/premium-build)` (c1) ·
  `lane_guard signage: OK (4 path(s) inside the fence; brief @ junior/premium-build)` (c2)
- `wc -l src/app/renderer.rb` 2124 -> **1969** (c1) -> **1970** (c2; the draw-site comment). `signage.rb` 198 -> 269
  lines (under the ~300 advisory).
- Byte-inertness of c1, mechanical (tmp/inert_check.rb, not committed): every moved body normalized (comments
  dropped, `Renderer::` prefix stripped, the `size` local = `SIZE`) is TEXTUALLY IDENTICAL old vs new:
  interact_verb 8/8 · interact_prompt_for 7/7 · way_locked? 5/5 · draw_exit_arrows 63/63 · draw_interact_prompt
  23/23 · way-breath body 6/6 · draw_pressure_outline = one line wrap of the same expression. Draw order unchanged
  (the `exit_pulse` block of `draw_map` calls `draw_way_breath(world, map, tx, ty, ts)` in the same place under the same
  condition). `window.rb`, `world.rb`, `src/game/**`, `src/core/**`, `harness/**`, `docs/**` untouched.

## Commit 1 — 658e5a1 extraction (`src/app/signage.rb`, mixin, the `Game::Loot` pattern)
`App::Signage` = module; `Renderer` does `extend Signage::ClassMethods` (`interact_verb`, `way_locked?` — so
`App::Renderer.interact_verb` / `App::Renderer.way_locked?` answer exactly as before for minimap.rb, map_artifact.rb,
minimap_test, map_artifact_test) + `include Signage` (`interact_prompt_for` public; `draw_way_breath`,
`draw_pressure_outline`, `draw_exit_arrows`, `draw_interact_prompt` private — the module's own `private`).
`Renderer::INTERACT_STATIONS = Signage::INTERACT_STATIONS` (same frozen object). Constants read as `Renderer::SIZE` /
`Renderer::HUMAN_BODY` / `Renderer::BANNER`; helpers `color`/`tr`/`hud_font`/`art_lift` and ivars
`@display/@light/@minimap/@bindings/@local_seat/@pressure_alpha` are the renderer's, reached through the mixin.
Test `test/app/signage_test.rb` (5): module exists + mixed in (ancestors both sides), the 3 public names + arities, the
four draws private, `way_locked?` pure on real zones — dungeon_1 `requires_level` 8 (locked -> open at level 8),
basement_2 seal (locked -> open after `restore_breach!`), boss fact, no-key => `false` never nil.

## Commit 2 — 7dcb601 the rule (`src/app/signage.rb`, `data/display.json`, draw site `renderer.rb`)
`Signage.pressure_outline?(world, c, possessed, max_tiles:, needs_line:)` (pure): `c.faction == :human` AND
`world.pressure_role(c) == :pressuring` AND `possessed` alive AND `Chebyshev(c.tile, possessed.tile) <= max_tiles` AND
(`needs_line` false OR `Signage.sight_open?(world.map, c.tile, possessed.tile)`). Instance shim
`Renderer#pressure_outline?(world, c)` feeds it the LOCAL seat's possessed + the two display rows; the draw site
(renderer.rb:1189) is `draw_pressure_outline(...) if c.faction == :human && pressure_outline?(world, c)`.

**`pressure_outline_max_tiles` = 3** = the sim's pressure ring radius + 1. Source: `src/game/aggro.rb:108`
`r = @threat[:pressure_ring_tiles]` (ring = the Chebyshev square at r, `aggro.rb:101-116`), value
`data/balance/threat.json:5` `"pressure_ring_tiles": 2`. (Melee/engaged slots are `Creature::RING`, Chebyshev 1,
`creature.rb:11`.) `pressure_outline_needs_line: true` = the owner's data toggle for the sight clause.

**Deviation from the brief, decided by the integrator (B, in-thread):** the brief's clause was
`world.line_clear?(c.tile, possessed.tile)`. That method (`world.rb:387`) is the ranged AI's 8-WAY shot ray
(clamp(-1..1) step) — FALSE for every pair off a row/column/diagonal. Verified headlessly on a real World (nest):
offsets [2,0] [2,2] [0,2] -> true; [2,1] [1,2] [-2,1] -> false on open floor. The pressure ring is the full 16-tile
Chebyshev-2 square, of which only 8 slots are aligned — the rule verbatim would outline at most half the ring and
render `pressure_ring_reads`' "deliberate encirclement" as a broken ring. So: `Signage.sight_open?(map, from, to)` =
presentation geometry (header says so: NOT the sim ray), plain integer Bresenham, fixed tie-break, walls only
(`map.passable?`, never bodies), endpoints unchecked, from == to open. Agreement with the sim ray on the 8 aligned
offsets d=1..3 over the whole district map: **57,280 pairs, 0 disagreements** (test vi). Sim + digest untouched.

What did NOT change: `world.pressure_role` (who is `:pressuring`), the ring claims, the digest, the outline's
alpha/colour (`pressure_outline_alpha`, `HUMAN_BODY`). **In brasa2 the DISTANCE clause alone removes the trapped embers'
outline** (a3-stalemate §FINDING: they sit at d=6-9 behind the row-6 wall); the sight clause only covers a ring slot
across a thin wall. The pocket itself (embers stuck on the greedy-vs-flow ping-pong) stays the owner's SIM candidate
(c), brain-OFF path — this lane did not touch it.

Test `test/app/pressure_outline_test.rb` (9, real World, district arena, `threat_pressure_test` staging: possessed
blocker parked, 5 rushers at d=1 fill `engaged_cap_per_target`, the 6th is `:pressuring`): max_tiles = ring+1 ·
(i) pressuring at d<=3 open sight -> true · (ii) pressuring at d=6 -> false (needs_line either way) · (iii)
pressuring at d=3 behind a REAL wall (target [23,11], pressurer [20,14], `wall?(22,12)`) -> false · (iv) every
engaged -> false · (v) `needs_line: false` -> (iii) true · (vi) agreement 57k aligned pairs · knight offsets open on
floor where the sim ray is false · pure guards (from==to, pack body, nil possessed).

## Integrator's Rule 2 gates (I did not open a window)
- **Commit 1 (byte-identical proof):** `ledger_loop`, `town_gates` — capture md5s must equal wall #4's
  (`captures/<script>_gate_a/*.png` @ cbaa4a5). If one pixel moves, the extraction is wrong.
- **Commit 2 (visual change):** `brasa2_run` (the red `pressure_ring_reads` x3 — the 6-9-tile outlined embers lose the
  outline) + every reel where >5 hostiles share one target: `district_hunt`, `threat_pull`, `sustain_run`,
  `corpse_run`, `zone_catchup`, `brasa1_run`, `brasa3_run`, `floor2_run`, `tower2_run`. The wall log prints only FAILs,
  so brasa2 is the one row I can name as changed; the others are where the outline can appear at all.

## PATCH REQUESTS (outside my `owns`)
1. `test/app/line_caps_test.rb`: add the cap `src/app/renderer.rb` <= **2000** (now 1970). Why: the brief's DoD;
   the integrator said he pins it at integration.
2. `harness/gate_checks.json` row `pressure_ring_reads` (line ~141): **no reword needed** — it already asks for
   "bodies positioned around the pack creature at a fixed perimeter distance" = what the rule now delivers. Optional
   additive clause if a critic ever needs it: "an outlined body is always within 3 tiles of the possessed with no wall
   between; a hostile farther away or behind rock carries NO outline even while it walks toward you".

## Helpers (read-only, async)
- `scout` -> `tmp/scout_signage.md`: file:line map of the signage block (INTERACT_STATIONS 354, interact_verb 356-363,
  interact_prompt_for 367-373, way_locked? 398-402 after `private` 389, breath block inside draw_map 531-543,
  draw_pressure_outline 1602-1609 decided at 1222-1223, draw_exit_arrows 1721-1787, draw_interact_prompt 1795-1820),
  every caller, the renderer-only helpers the draws need; ring geometry = `Creature::RING` Chebyshev 1 (engaged) /
  `pressure_ring_tiles` 2 (pressure) `aggro.rb:101-116` + `threat.json:5`; `threat_pressure_test` as the staging
  pattern. Matched my own scan.
- `reviewer` -> `tmp/review_signage.md`: see §Review below.

## Review (fresh-eyes `reviewer`, read-only, async — `tmp/review_signage.md`)
**Verdict: OK with notes** (no P1). Findings, verbatim gist: (1) c1 moved bodies identical line-by-line incl. float/int
division + Gosu call order; (2) constants resolve to the same objects (dynamic lookup; `assert_same` on
INTERACT_STATIONS); (3) visibility preserved (`extend` public singleton, module `private` carried by `include`);
(5) `sight_open?` terminates, never overshoots — the `break if x == x1` guards are unreachable for integer input,
dx==0 / dy==0 / negative directions traced; (6) endpoint semantics == the sim ray, exact diagonal never touches the
orthogonal neighbours (no supercover pinch); (7) display rows valid, `display_knobs_test` covers both keys; (8) draw site
correct — NOTE the one intended delta beyond the brief: the outline now also needs the local possessed to exist and be
alive (a dead possessed = no outline; the seat swaps anyway); (11) role tests non-vacuous. Its oracle question (main
worktree @ e9a5fd7 == 193e148 for renderer.rb?) — confirmed: `git diff --stat 193e148 junior/premium-build --
src/app/renderer.rb` is empty.
Applied in the receipt commit: **P2 #9** knight-offset test counts checked offsets (`assert_operator checked, :>, 0`) so
it can never pass vacuously; **P2 #10** test (vi) asserts `"district"` before sampling (loud on a spawn/map change);
**NIT #4** signage.rb header no longer claims the renderer cap already exists in line_caps_test (it lands at
integration — PATCH REQUEST 1). Suite after: pressure_outline_test 9 runs / 55 assertions green; display_knobs 4/4.
