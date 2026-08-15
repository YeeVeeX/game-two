# D1 corpse-run — adversarial implementation review (2026-08-11)

Reviewer: code-reviewer agent (static, seeded with the plan's 5 suspicions + 3 more).
Scope: `git diff main` incl. working tree (sim, renderer, telemetry, harness, tests, gates).
Verdicts assigned by the dev of record; fold status recorded per finding.

## Findings

### 1. HIGH — D1 gate surface uncommitted (staging, not defect) — RESOLVED BY PROCESS
`corpse_run.json` untracked; `gate_checks.json` / `vision_critic.py` / `CLAUDE.md` modified-unstaged
at review time. Deliberate: the plan commits Task 9 only after the full wall is green. The merge
checklist requires these to land in the Task 9 commit before `merge --no-ff`. **Fold: commit order.**

### 2. MEDIUM — recovery-margin oracle unmeasurable — CONFIRMED, FOLDED
Spec demands per-corpse recovery margin (`term_left_at_loot / term`, target 0.3-0.5) as the term-
tuning oracle, "never by feel". The `:corpse_looted` payload (actor, tile, amount, carried) cannot
yield it, and frame subtraction across EVENT lines is wrong whenever hitstop, the veil freeze, or a
wipe-grace rewrite intervened — exactly the corpse-run case. **Fold: payload extended additively
with `term_left:` + `term:` (world.rb), test asserts them, spec payload pin updated with a fold
note.** CF-5's pin was about preventing drift, not forbidding the field its own telemetry section
requires.

### 3. LOW — cap eviction can clobber a foreign container link — CONFIRMED (latent), FOLDED
With 40+ linked records in one zone, `leave_corpse` evicts the record it just appended, then
`spawn_corpse_load` stamps `corpses.last` = some OTHER container's corpse — overwriting its link.
Unreachable with a 3-body pack at 90s term (~bounded well under 40 live containers), but the fix is
cheap and removes the identity assumption. **Fold: `leave_corpse` returns the appended record (nil
if it was the eviction victim); the handler passes it to `spawn_corpse_load`, which stamps that
identity and skips the stamp when nil. Test added (40-linked flood).**

### 4. LOW — container expiring on the exact wipe tick dodges the grace — CONFIRMED, SPEC NOTE
Within the wipe tick, `tick_corpse_loads` removes a `term_left==1` container before the bus flush
runs the grace top-up. Deterministic, one-frame, semantically "it expired before the wipe landed".
**Fold: recorded as a boundary note in the spec's wipe section; no code change.**

### 5. LOW — draw-path autovivification on new accessors — CONFIRMED (theoretical), FOLDED
`corpse_loads` / `expiry_flashes` public readers indexed a default-proc Hash, so renderer reads
inserted keys into sim state (pure-reader law). No pixel/MD5 impact today; same pattern pre-exists
for `corpses`/`drops` (out of D1 scope). **Fold: the two NEW readers use non-autovivifying
`fetch(zone) { [] }`; internal writers keep the default-proc hash.**

## Watch-list addition (reviewer seed-5 note) — SPEC NOTE
Dying-breath loot is a free **term refresh**: loot a near-expired container with a body about to
die and the merged pile respawns as a fresh-term container. Sibling of the spec's grace-refresh
watch item. **Fold: added to the spec's OUT/watch list.**

## Seeds cleared (traced, no defect)
Settle/term at exactly 0 (interact precedes tick_corpse_loads — loot wins the boundary tick
deterministically); stacked same-tile release (monotonic serial, no cross-release); dying-breath
loot ordering (synchronous interact, end-of-tick death flush — no double-count); zone keying
(explicit zone args everywhere off-current); telemetry wiring (double-close harmless, respond_to?
guard correct); wipe grace hits all zones; flipped D0 tests faithful.
