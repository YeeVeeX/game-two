# A0.6 impl adversarial review — banked verdict + fold ledger (2026-08-10)

Reviewer: code-reviewer agent over `git diff main...HEAD` on a0.6-blocker-taunt,
with two live headless repros. Full attack surface: determinism, the lazy-clear
reader, anchor-rule scope, swap/gate/hitstop interactions, renderer nil-dig,
test honesty, scope.

## Finding 1 — CONFIRMED BUG (HIGH): wipe revival resurrected taunt locks

The lazy clear lived ONLY inside `taunted_target`, and in organic play no reader
runs between the blocker's death and its revival: death lands after the AI reads
of the same tick, the wipe transition happens same-tick at bus-process, and
`:nest_respawn` ticks nothing. `revive!` restores the same object → `dead?` is
false again → the frozen victim re-locks a taunter that never re-cast. Live
repro: abandoned-zone victim held frames=299 and re-acquired after respawn.
**The shipped wipe test was green anyway** — its `kill` helper injects deaths
outside `resolve_attacks`, so one extra `:world` tick ran and the victim's AI
read fired the clear: the test encoded the helper's artificial ordering, not
the sim's.

## Finding 2 — the load-bearing question: mutating reader = draw-path sim mutation

Ordinary (non-revive) death: idempotent, safe. Revive window: the renderer's
`taunted_target` read from `draw` was the ONLY reader running, so whether a lock
survived a wipe depended on whether draw happened to run — sim state mutated at
wall-clock rate; two replays could diverge (gate md5 could flake). The harness
compounds it: capture frames call draw twice.

## Fold (commit 4574510)

- `taunted_target` is now a **pure reader** (returns nil for a dead taunter,
  never mutates).
- Clearing is **sim-owned**: `tick_body` clears when `@taunted_by&.dead?`
  (ticking victims), and `respawn_pack` sweeps **every zone's** humans with
  `release_taunt!` before reviving (frozen victims).
- Two new tests: the organic abandoned-zone resurrection case (whole-pack gate
  transit → wipe in nest → respawn → frozen victim NOT re-locked) and reader
  purity (frames survive a read; state untouched).

## Finding 3 — LOW, accepted with comment

`draw_taunt_underline` digs `taunted_target.kit[:special][:taunt]` — guaranteed
by construction today (only `resolve_taunt_pulse` calls `taunt!`, and it
requires the block). The A1 gambit era must keep the invariant or guard the
dig. Recorded here, not coded.

## Verified clean by the reviewer (no action)

Determinism of the new sim code (array orders, min_by tie-breaks, no PRNG/wall
clock); humans running anchor_victim_for is a no-op (pack members can't be
taunted); dead-mid-windup blocker can't pulse posthumously; enter_zone clears
pulses while victim locks persist (spec's gate-pull call); hitstop/veil pause
frames+pulses like stagger/impacts; window.rb untouched; zero balance constants
in Ruby; both trio tiles passable.

## Gate status at review time

taunt_anchor: full PASS 23/23 (13 captures, byte-identical). district_hunt +
loot_loop: PASS. world_loop: FAILed once on a critic hallucination (inferred
taunt from an ordinary swarm with no underline present — frame 0672 predates
any taunt in that script); check wording hardened ("do not infer taunt from a
swarm; judge only if a pulse or underline is visible"). specials_chain: two
INFRA ERRORs (critic returned malformed JSON — transient).

## Finding 4 — REAL bug found by the gate, not a critic hallucination (MED)

specials_chain re-run FAILed `taunt_underline_reads`/`taunt_convergence_reads`
after the fold. Pixel-verified before touching code: the underline pixels WERE
present at the spec'd y+SIZE+5 offset (confirmed via direct RGB sampling at the
correct screen coordinate, camera-corrected). The real defect: specials_chain's
scripted mark press lands on rusher2, the SAME human the Slam pulse taunts one
frame later — a human that is both marked and taunted is a legal, sensible
combo (focus fire the taunted target). The mark reticle's bottom corner
brackets extend to y+SIZE+5 (draw_mark), landing exactly on the underline's
offset — an 8px band carrying two persistent tells, neither legible. Fixed:
underline moved to y+SIZE+9 (4px clear gap). This is the kind of bug Rule 2
exists to catch — a code-review pass would not have found it, since both
tells are individually correct in isolation; only a real frame with both
active exposed the collision. Fold: renderer.rb, re-verify all 5 gates.

## Fold status: ALL FINDINGS FOLDED. Full 5-gate suite GREEN.

world_loop / taunt_anchor / district_hunt / loot_loop: PASS on the first
post-fix pass. specials_chain: PASS on a solo retry after one more
`corpses_persist` flake — pixel-verified BEFORE retrying that the corpse
record and its render code are correct and untouched by this branch (a real
but subtle remnant sits behind a crowded frame with the mark glyph, drop
rings, and two pack bodies); the retry confirmed critic variance, not a
regression. All determinism halves byte-identical across every script.

rake: 173 runs, 689 assertions, 0 failures. rake perf: PASS (p95 0.057ms).
Ready for merge --no-ff, no push.
