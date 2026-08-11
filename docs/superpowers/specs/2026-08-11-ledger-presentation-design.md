# Ledger presentation iteration — "louder, closer, animated" (render-only)

**Status:** approved 2026-08-11 (plan mode). Iteration on the SHIPPED v8 fight
ledger (merge `677b2ac`) — the fight-ledger spec §fun-verify pre-registers this
exact contingency ("Q6 couldn't-read → presentation iteration first"). NOT new
scope; the scope contract stays v8 until the re-verify lands.

## Why

The ledger fun-verify came back INVALID AS A MEANING TEST: total visibility
failure (`drafts/_ledger-fun-verify-20260811.md`). The owner answered all 8
questions; Q6's escape-valve fired at maximum ("never saw any of it") while
telemetry proved 4 fights, 1 loss beat, and 2 wipe recaps fired.

Why it was invisible (measured, not guessed): the beat is 14pt regular text
(16pt bold net) at top-center y=96 on a 960x540 screen — half the size of the
zone banner the owner DOES notice (28pt bold), with zero animation (the repo's
only motion grammar is alpha fades), and on wipes it competes with 64pt
"THE HUNT ENDS" at screen center. Even the veil recap (a forced 90-frame pause)
went unnoticed twice → size/placement/contrast, not timing.

**Design stance: err LOUD.** Overshooting salience is a cheap data-key
tune-down; undershooting costs an entire fun-verify cycle. FR-025 permits this:
it bans SATURATION (many simultaneous floating texts), not prominence — one
tally at a time is already enforced sim-side.

## Hard constraint: RENDER-ONLY

A resolve-punch via hitstop is a SIM change — new freeze frames shift the world
trajectory against the 7 recorded replay input streams (one-tick choreography
like the corpse_run gate-loot trick breaks). Therefore:

- `src/game/**` untouched. NO new hitstop/shake/feel events.
- All animation is a pure function of the existing beat record
  `{kind, gained, pip_amount, dark_amount, net, recovery, beat_left,
  beat_frames}` via `world.ledger_beat` — determinism holds, every replay
  script stays valid.
- Replay INPUT streams are sacred; capture INDICES are free
  (the runner renders captures without ticking — determinism-neutral, proven).
- No audio (none exists in the build; owner order).
- Taught grammar unchanged: glyphs + signed numbers, no words; filled square =
  acquired, hollow pip = recoverable pile, dark square = destroyed; red never
  for recoverable; max 3 lines.

## The design

- **Position:** beat block horizontally centered, top edge at `ledger_block_y`
  (160) — just above the avatar. The camera lerps the possessed body to screen
  center (~480,270), so screen-center IS player-anchored. Quiet resolves fire
  after 3 s of no combat by definition, so occlusion of live fights is rare.
  Wipe recaps (`kind: :wipe`) draw at `ledger_wipe_y` (340; the plan's 310
  was amended at implementation: `beat_left` freezes for the whole veil, so
  the recap holds full 1.35 pop scale for ~90 frames and its panel top would
  persistently overlap "THE HUNT ENDS" — 340 clears the 64pt em box even at
  full pop). After the veil lifts the recap stays mid-screen through the
  run-back start: mission number front and center — intended.
- **Type:** new fonts `ledger_net_font` 42 bold (net line), `ledger_line_font`
  26 bold (take/loss lines); glyphs scale to ~20px squares. **Summary-line
  rule (implementation amendment):** the block's summary line is always the
  loud one — net at 42 when losses exist, the take itself at 42 (glyph 32)
  when it stands alone. Without this the most common beat (a lone +N) is the
  QUIETEST, inverting err-loud. Colors and glyph grammar unchanged.
- **Contrast panel:** dark rect (`ledger_panel_alpha` 160) at z=29 behind the
  text (z=30), sized to the widest line + padding, scales with the pop.
  Carries readability over the busy field AND over the alpha-170 wipe veil.
- **Entrance pop:** first `ledger_pop_frames` (10) frames scale eases
  1.35 → 1.0 (sqrt ease-out) around the block center; brief upscale blur is
  intentional Vlambeer punch. **Arrival flash:** first `ledger_flash_frames`
  (6) frames an additive bright rect over the panel decays to 0. Both driven
  by `age = beat_frames - beat_left`. **Wipe beats get NO flash
  (implementation amendment):** `beat_left` freezes during the veil, so an
  age-driven flash would sit at full additive alpha over the recap text for
  ~90 frames and wash it out — the exact legibility `wipe_recap_reads` gates
  on. The veil is the wipe's punch; the frozen 1.35 scale keeps the recap the
  star of the pause, and the pop animates as the veil lifts. Exit keeps the
  repo-standard final-third alpha fade.
- **No per-kind pop variants:** wipe/bank differentiate by position + context,
  negative by color — per-kind scale keys are unverifiable-by-critic
  complexity. Tune later via data if wanted.
- **Z map:** veils 0, banner/wipe text 10, HUD 20, panel 29, tally text 30,
  flash 31.

All five new keys live in `data/display.json` (canonical presentation-timing
home; `zone_banner_frames` precedent): `ledger_pop_frames`,
`ledger_flash_frames`, `ledger_panel_alpha`, `ledger_block_y`, `ledger_wipe_y`.
Zero balance constants in Ruby.

## Verification

- Vision checks retargeted, never weakened: `ledger_beat_reads` +
  `bank_tally_reads` gain center-screen + prominence language; NEW
  `ledger_prominence` check ("one of the two-three most visually prominent
  elements; a player watching screen center cannot fail to notice").
- `ledger_loop.json` captures += 579, 2110, 11131 (the plan's 594/2020/11146
  assumed beats start AT the old capture frames; a headless sim probe showed
  the real resolves fire at 576/2017+veil/11128 — the retargets catch a solo
  take mid-pop, the post-veil recap settling, and a 3-line negative beat
  mid-pop). 18 captures, under the critic's 20-image cap.
- Data sanity asserts in `fight_ledger_test` (pop < beat_frames,
  flash <= pop, block_y clears the HUD, wipe_y clears the wipe line).
- Full 7-script wall with critic (rendering change re-runs everything), then
  `rake perf`.

## Re-verify protocol (FIFTH chore ask)

Owner plays (`bin/play`), unprimed. Same 8 questions VERBATIM from the
fight-ledger spec §fun-verify, two AskUserQuestion batches (Q1-Q4, Q5-Q8).
Verdict + v8 routing banked in `drafts/_ledger-fun-verify2-20260811.md`.
Routing (locked, owner 2026-08-11):

- Q3 "still a chore" on a VISIBLE ledger → **A2 promotes AUTOMATICALLY**
  (scope contract to v9 FIRST; fold PARKING_LOT A2 notes + tank-first + hub
  rename into its brainstorm; decide ledger disposition per Q1/Q2/Q5/Q7 BEFORE
  the A2 spec; no A2 implementation in the verdict session).
- Q6 couldn't-read AGAIN → presentation is not the layer; targeted
  reward-salience research is the pre-authorized contingency.
- Q1/Q2/Q5/Q7 any real signal → ledger STAYS through A2; wallpaper +
  wouldn't-miss → REMOVED before A2.
- Economy (D1b, spending) stays parked in ALL branches.

## Risks

- **Panel occludes elements other scripts' checks verify** (beats fire in
  district_hunt/corpse_run captures too): alpha-160 translucency mitigates;
  if a shared check fails 2x consistently under the panel, flake discipline —
  pixel-verify, then factual check amendment or panel-alpha data tune.
- **Pop blur:** intentional, 10 frames; tune `ledger_pop_frames` down via data
  if the owner objects.
- **Fifth verify fails on visibility again:** presentation isn't the problem
  layer — reward-salience research contingency (pre-authorized).
