# D0 implementation — adversarial review (2026-08-10)

Reviewer: code-reviewer agent (Fable lane) over `git diff main...HEAD` on `d0-loot-loop`.
Method: read every changed file against the revised spec + laws, ran the full suite
(121 green), ran the determinism half of the loot_loop gate live (15/15 byte-identical),
replayed the script and audited the event log against the seven spec beats, and
**sabotage-probed** the swap-mask tests (monkey-patched the mask out and re-ran).
Banked by the dev of record verbatim-in-substance (the reviewer's environment had no
Write tool).

## Verdict: ACCEPT — two low-severity findings, both folded same day

### Finding 1 — CONFIRMED (test strength, not a game bug): both swap-mask tests pass with the mask removed

Sabotage probe: with `rearm!` patched to exclude `:interact` from `@masked`, both
`test_held_interact_masks_across_*_swap` tests still pass. The no-ghost-fire behavior
they assert is actually enforced by the shared `@edge_was_down` hash in
`PossessedController#pressed?` — a key held continuously across a swap never produces a
rising edge on the new body regardless of the mask. The mask's only load-bearing
scenario for an edge-triggered verb is a key pressed on the EXACT tick of the swap;
that scenario was untested. Risk left open: a refactor moving `@edge_was_down`
per-creature (or resetting it on swap) would silently re-open same-tick ghost-fire with
green tests. **Fold: new test `test_interact_pressed_on_swap_tick_is_masked`** — press
interact on the same frame as Tab with the incoming body parked on a drop; assert no
pickup (the mask is the only thing refusing it), then a fresh press picks up.
No game defect: all three ghost-fire paths (held-across-voluntary, held-across-forced
via deferred rearm, press-on-swap-tick) are closed in the shipped code.

### Finding 2 — CONFIRMED (doc/check drift): ledger radius is 3, docs said "~2 tiles"

Commit `62e413f` set `LEDGER_RADIUS_TILES = 3` (sound: the tile commits at step START
while the pixel tween trails), but `bank_station_reads` in gate_checks.json and the
spec's quiet-HUD prose still said 2. Not gate-breaking (the check demands legibility
WHEN near, and 3 is a superset), but drift invites a future critic surprise. **Fold:
check text and spec synced to ~3 tiles with the tween rationale.**

## Hunted and cleared (verified in code — do not re-hunt)

- **Economy exploits:** one interact per rising edge per tick; pickup returns before
  the bank arm (drop-on-station = two presses, tested); `bank!` single call site;
  `drain_carried!` can't go negative; pickup-then-die-same-tick resolves
  controller → resolution → bus-flush, deterministic and per spec.
- **Replay divergence:** `spawn_drop` is the sole `@rng` consumer; bus is a FIFO
  shift-loop appending nested emits to the same flush → multiple deaths consume the
  PRNG in emit order = resolution order = fixed. No handler causes a death mid-flush.
  `@drops` Hash iteration is insertion-ordered; its only order observable is a log
  line. Gate ran clean 15/15.
- **Law 4 carried:** untouched by `swap_next!`/`forced_swap!`/`rebind`/`enter_zone`;
  zeroed by `revive!` and the death handler. Masked-release in `pressed?` produces no
  stale edge.
- **Hitstop/veil:** `tick_drops` has exactly one call site; both the hitstop
  early-return and the `:nest_respawn` branch skip it; all-zone decay verified by test
  and live replay.
- **Interact mid-dodge:** allowed; the logical tile is the dash LANDING (crossed tiles
  unreachable), and `start_attack` is equally available mid-dodge — consistent
  doctrine, not a defect.
- **Renderer:** during the veil the possessed's `#tile` still works and the district
  map has no stations (empty loop). `spawn_drop` always sets `decay_frames`; merge
  keeps the original. Telegraph body inlay hides nothing that was ever visible
  (telegraphing humans previously drew no body); `hurt_flash_not_white` judges pack
  only. No regression.
- **TileMap/schema:** `fetch(:stations, [])` keeps station-less zones valid;
  `[12,8]` symbolizes fine; station tile verified passable, off the gate column.
- **Tests:** seed-determinism test proves run-to-run identity at fixed kill order
  under seed 7 (the law-3 property; kills land on distinct tiles, no sum-masking).
  No mocks, no excusing hatches.
- **loot_loop.json:** all seven beats verified in the event log with captures aimed at
  each (drop 387→cap 395, pickup 680→683, nest carry 817→850, banked 1050→1040/1053,
  re-pickup+carried_lost 1480/1510→1470–1512, decay 2356→2380 which doubles as the
  wipe frame, projectile 231→234/242). New checks carry the pass-true hatch; existing
  17 untouched.
- **Scope:** window.rb 62 lines; `core/input.rb` byte-identical; the only new balance
  number lives in JSON (`drops.decay_frames`); `LEDGER_RADIUS_TILES` judged
  presentation (when a numeral renders), not balance.

## Process note (satisfied)

The reviewer flagged: confirm the full 4-script vision gate ran AFTER the last render
commit. It did — the telegraph-inlay commit landed first, then loot_loop, world_loop,
specials_chain, district_hunt all ran full (determinism + vision) and passed. The
finding-2 check-text sync changes the shared checklist, so the four gates were re-run
again after the fold (results in the checkpoint).
