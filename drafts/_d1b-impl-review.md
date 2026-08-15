# D1b implementation adversarial review ledger (2026-08-12)

Subject: full branch diff `main...d1b-vat` at `64302bc` + the 5 re-piloted
wall scripts (committed unchanged as `bc98096`). 25 files, ~3,961
insertions. Two independent tracks, per the Task-14 protocol.

## Track 1 — Workflow (same-family, wf_2241b722-775)

3 finder lenses (sim-correctness / regression-integration /
presentation-harness) + 1 refuter. **Declared envelope ~1.0M subagent
tokens (3 finders ~110K + <=12 refuters ~55K); actual 380,375 — underran
because only ONE finding surfaced.** Convergence held exactly: one find
round + one verify round. All agents `us.anthropic.claude-opus-4-6-v1[1m]`.

- sim-correctness finder: **0 findings** (109,498 tokens, 43 tool calls)
- regression-integration finder: **0 findings** (107,079 tokens, 45 calls)
- presentation-harness finder: 1 finding → **REFUTED**

### [low/presentation-harness] retarget_cue_frames misplaced in economy.json — REFUTED
CLAIM: it is a presentation timer that belongs in display.json beside
station_cue_frames (the "timers/alphas in display.json" law).
REFUTATION (refuter, verified): it is a SIM-owned timer by design —
stored on the creature, decremented in the creature's own tick beside
exhaust/iframes/stagger, read by the renderer from the entity (never the
display hash), and the comment at creature.rb:220 says exactly that.
station_cue is world-owned presentation state; the consumption patterns
are not identical. No fold.

## Track 2 — Codex cross-vendor (GPT-5.6 Sol pinned; self-reported
## "GPT-5 Codex" — expected, never trust self-report)

Thread `019ff750-2d66-...`; smoke-test file read passed first
(131 lines). Verdict: **REJECT with 4 blocking findings.** Each re-verified
from the actual code by the dev of record before acting (skill law).

### CONFIRMED → FIXED (commit `5a9229c`, TDD: 3 failing tests written first)

1. **Floor telemetry counted the kept vessel as dissolved** (world.rb
   respawn_pack): every unmarked body emitted `:body_dissolved`, then the
   floor revived the vessel — `dissolved=3 floor_fired=1` while only 2
   stayed dead. The d1b_fired line is the seventh verify's meaning oracle;
   it was wrong in exactly the floor scenario Q4 asks about. Fix: floor
   determined before the loop; the vessel emits `:vessel_kept` only.
   Pin: economy_judgment_test floor test asserts dissolved == the two
   non-vessel bodies.
2. **Stale retarget cue** (world.rb assign_human_focus): unkeyed retargets
   (taunt/anchor/sticky) never cleared a live cue — a human could turn for
   a taunt while wearing the lowhp color for up to 45 more frames, lying
   about the cause Q7 exists to make legible. Fix: every retarget
   stamps-or-clears (`Creature#clear_retarget_cue!`).
   Pin: test_unkeyed_retarget_clears_a_stale_cue.
3. **Station cue unbound from its fixture** (renderer draw_station_cue):
   the cue stored `{kind, frames_left}` and the renderer drew it on the
   fixture nearest the possessed AT DRAW TIME — walking during the
   30-frame window dragged the pulse/X onto a neighboring fixture,
   misreporting which transaction fired. Fix: `station_cue!` stamps the
   transaction tile (`at:`); renderer draws at `cue[:at]` (the nearest-
   station search is deleted). Pin: altar refusal test asserts
   `station_cue[:at] == altar_tile`.

### REFUTED (recorded so nothing re-raises it)

4. **Vat tribute not exception-atomic** (spend before revive!): the window
   requires `revive!` to raise between spend and rebind. `revive!` is a
   hard teleport onto fixed zone-data tiles (`home.pack_spawn[i]`,
   `@zones.fetch(HOME_ZONE)` is a boot-time invariant; dead ⊂ members so
   `index` never nils). No reachable game state raises there; the scenario
   needs an already-corrupt sim. Recorded, not fixed — reordering would
   scramble the event order (:banked_spent carries the post-spend balance)
   to defend against a state that cannot occur.

### Minor notes (recorded, no action)

- God-mark glyph can be covered by the HUD bars when a marked body stands
  in the top ~2 screen rows (world glyph vs screen-space HUD); 1px overlap
  with the possession ring. Cosmetic; the god_mark_reads gate check
  arbitrates and passed 39/39 twice.
- threat_targeting_test.rb comments at ~86/98/151 still cite the old
  0.35/3 values in prose (assertions all restaged correctly — Codex
  confirmed no assertion weakening). Comment-only; left for the next
  touch of that file.
- `Pack#bank!(-1)` would violate the never-negative invariant if called —
  no such call site exists; the never-taxed law is call-site-scoped.

## Cross-vendor calibration (for the next review's budget)

The same-family finders (Opus 4.6, 216K finder tokens) returned **zero**
of the three real defects Codex caught. All three were semantic-honesty
bugs (event meaning, cue meaning, cue location) rather than crash/law
violations — exactly the class the lens prompts under-specified. Keep the
Codex leg mandatory on merge-gates; consider a "does every emitted signal
tell the truth" lens next time. Token actuals: workflow 380K vs 1.0M
declared; Codex 1 session + smoke test.

## Consequence for the wall

Fixes 2 and 3 are pixel-visible → the goalcomp-era official passes were
invalidated. Full official 9-script sweep re-run on the post-fix build
(commit `5a9229c`): results recorded in docs/CHECKPOINT.md and
drafts/_gate-verdicts.log. (The pre-fix build had reached official
9/9+9/9: sweep b7r5qae5o 8/9 + vat gate exit-0 after the critic INFRA
retries — determinism 20/20 byte-identical, vision 39/39.)

## Post-review harness delta (self-verified, harness-only — no sim change)

After the review closed, the re-proof rounds surfaced two gate-infra
failure modes (full round log: `_d1b-wall-log.md`):
- loot_loop/corpse_run captures[] re-aimed onto real projectile flight
  windows (inputs untouched; determinism unaffected; loot round-2 critic
  cited the new frame 0716 by name).
- vision_critic.py hardened: verdict attempts 4→6, and a self-gating
  check returning pass=false with a not-exercised why now voids the
  verdict (retry) instead of deciding the gate — observed live on
  specials_distinct. Stricter-or-neutral by construction; gate_checks.json
  untouched (ADD-ONLY law holds at 39).
