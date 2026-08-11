# Plan: ledger presentation iteration (render-only)

Spec: `docs/superpowers/specs/2026-08-11-ledger-presentation-design.md`.
Approved plan of record: `~/.claude/plans/happy-exploring-hinton.md` (tasks
0-10). Context harvest (verbatim check drafts + code sketches):
`drafts/_ledger-presentation-harvest.md`. This file is the in-repo summary.

## Tasks

0. Branch `ledger-presentation` off main; this spec + plan; fix
   "top-left" → "top-center" in `drafts/_ledger-fun-verify-20260811.md`.
1. `data/display.json` += `ledger_pop_frames` 10, `ledger_flash_frames` 6,
   `ledger_flash_alpha` 120 (added at implementation: a 200 peak whited out the
   glyph color at age 0, capture-proven), `ledger_panel_alpha` 160,
   `ledger_block_y` 160, `ledger_wipe_y` 340 (was 310: `beat_left` freezes all
   veil long, so the recap holds full pop scale ~90 frames and 310 persistently
   overlapped THE HUNT ENDS).
2. `Renderer#initialize(display: {})` + call sites `src/app/window.rb` and
   `harness/scenes/world_scene.rb` (both already hold the data store).
3. Fonts `ledger_net_font` (42 bold), `ledger_line_font` (26 bold), memoized-def
   style. Keep `hud_font`/`ledger_font` (station ledger + HUD consumers).
4. Rewrite `draw_ledger_beat` + helpers: measure-lines pass → panel (z=29) →
   flash (z=31 additive) → scaled line drawers (grammar identical, new sizes);
   `draw_hollow_pip` gains a size param; remove dead `LEDGER_BEAT_Y`;
   wipe-kind block at `ledger_wipe_y`. Two implementation amendments (both in
   the spec): wipe beats get NO flash (age freezes during the veil — a frozen
   flash washed the recap out, capture-proven), and the summary line is always
   the 42pt one (solo take promotes; a lone +N was the quietest beat).
5. `harness/gate_checks.json`: retarget `ledger_beat_reads` +
   `bank_tally_reads`, ADD `ledger_prominence`. Count: 30 → 31 (the harvest's
   "32 measured" was wrong — recounted 30 at execution start; checkpoint's 30
   was correct).
6. `harness/scripts/ledger_loop.json` captures += 579, 2110, 11131 (15 → 18;
   the plan's 594/2020/11146 assumed beats start at the old capture frames — a
   headless probe showed resolves fire at 576 / 2017+veil / 11128).
7. `test/game/fight_ledger_test.rb`: display sanity asserts.
8. Visual iteration BEFORE the wall: SKIP_CRITIC ledger_loop, Read the PNGs
   (591/594/2017/2037/9297/11143/19817), fix by eye.
9. BLOCKING wall: `rake` → SKIP_CRITIC x7 → full `rake gate` x7 → `rake perf`.
   Critic flake rules: pixel-verify FAILs, retry INFRA, 2x-consistent =
   check-text defect.
10. Merge `--no-ff` to main (NO push), measured checkpoint, then hand the owner
    the FIFTH fun-verify (protocol in the spec).

## Files touched

`data/display.json` · `src/app/renderer.rb` · `src/app/window.rb` ·
`harness/scenes/world_scene.rb` · `harness/gate_checks.json` ·
`harness/scripts/ledger_loop.json` · `test/game/fight_ledger_test.rb` ·
these docs · CHECKPOINT.md at the end.

NOT touched: `src/game/**`, replay input streams, the other 6 scripts,
CLAUDE.md scope contract.
