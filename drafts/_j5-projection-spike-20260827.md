# J-5 projection spike — record (s93, 2026-08-27; owner-present, ratified Lane-4 shape)

STATUS: **CLOSED s93 — owner pick: FLAT.** Nothing ships. Adoption of
any alternative projection is refused for v19/v20 geometry; the
depth-read ask routes to the art-depth candidate below. No gate run
(no-gate by ratified shape); the live repo's code and frozen surfaces
were untouched by construction — the spike lived in a throwaway worktree
at `tmp/j5-spike/` (gitignored, detached HEAD `a2f6644`), torn down at
the pick.

## What was built

ONE seam edit in the worktree's `src/app/renderer.rb` (+22 lines): the
whole world pass in `Renderer#draw` (already a single `Gosu.translate`
block; HUD/overlays/banner draw outside it) wrapped in a screen-space
transform keyed by `PROJECTION` env:

- `flat` (default) — passthrough, current game.
- `threequarter` — `Gosu.scale(1.0, 0.7)` around the view center
  (vertical squash, fakes camera tilt).
- `iso` — `Gosu.scale(1.0, 0.5) { Gosu.rotate(45) }` around the view
  center (classic 2:1 diamond).

Same replay all three ways: `harness/scripts/world_loop.json` (the
everyday-loop wall script, 1249 frames, 10 captures), out-dir override
per projection. Sim untouched — render-only transform; replay determinism
irrelevant here (look-pick, not a gate).

## Artifacts

- Worktree captures (`j5_flat/`, `j5_threequarter/`, `j5_iso/` — 10
  frames each, `REPLAY_DONE` all three runs) died with the worktree at
  teardown.
- The four decisive triptychs are preserved LOCAL (untracked, the
  junior-refs banking pattern) in `drafts/_refs/j5-projection-20260827/`:
  `compare_0300.png` md5 `351db2351462bde8c374acd10620bef9` ·
  `compare_0441.png` md5 `4610cddd6cfd515324aa07b1d67d32e8` (the one
  shown in-chat at the pick) · `compare_0805.png` md5
  `f646a93e8356563951be9cb1b2ea934d` · `compare_1248.png` md5
  `28a490253adffa9690b56d30296b2eb9`.

## Caveats named at the pick (honest-cost notes, not fixes)

1. **Whole-scene transform shears bodies and world-anchored text** —
   under iso, square bodies read as diamonds and station numerals/
   nameplates tilt. A real adoption would billboard entities and keep
   world text upright (per-draw-site work, not a seam wrap).
2. **Iso corners show void** — a rotated 960×540 view needs ~1061px of
   world diagonal; near map edges the corners fall outside the drawn
   map. Adoption would overdraw or fit-scale.
3. **3/4 squash thins walls** — a real 3/4 adds per-tile height offsets
   (fake z) for walls/bodies instead of squashing everything uniformly.
4. HUD, controls strip, banner, veils stay screen-aligned in all three
   (they draw outside the world block) — that part is adoption-real.

## Owner pick

- **FLAT** — dev recommendation accepted; owner (Gabriel, s93 chat,
  verbatim): "approved, proceed" on the recommendation "pick FLAT for
  v19/v20 geometry; bank 'art-depth on flat grid' (wall faces + body
  lift) as the presentation-lane candidate for the v20 grill."
- Recommendation grounds (recorded for the grill): iso = render-layer
  rewrite (~40 direct-coord draw sites + billboarding + diamond-grid
  input remap + full re-pin of 35 wall scripts / 69 gate rows / canary)
  AND fights tile-locked combat legibility; Tibia — the reference wall —
  is flat square grid, not iso. 3/4 squash = "same game, shorter": no
  depth cue without wall faces, costs vertical aim/dodge legibility.

## Banked candidate — ART-DEPTH ON FLAT GRID (v20 presentation lane)

- Origin: dev proposal at the J-5 pick (s93), owner-approved same
  session ("approved, proceed").
- Shape: keep grid geometry byte-flat; buy the depth read in ART —
  darker face band on south-facing wall edges + small body "standing"
  lift (and later, drawn-in tile depth if assets mature). The
  Tibia/Zelda-LttP projection lesson: their 3/4 read lives in tile art,
  not geometry.
- Cost shape: cheap renderer work, gate-able with the EXISTING wall
  (visual change → Rule 2 gate + wall re-pin owed when it ships);
  geometry, input, hitboxes, combat grammar untouched.
- Cross: composes with the recorded "game still looks too simple"
  presentation pointer (slate §non-candidates) — this is its first
  concrete shape. Post-verdict like everything player-visible; the v20
  grill prices it against the other presentation candidates.
