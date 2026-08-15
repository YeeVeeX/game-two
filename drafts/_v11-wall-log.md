# v11 density/re-massing wall log — official Rule-2 gates on `v11-density`

Build: branch `v11-density` at `55751dd` (anchoring `7470c2b` + rider/
telemetry/checks `42c22e6` + harness log line `55751dd` on top of main
`f11a643`). Suite 302 runs / 1,238 assertions green at every commit
(hooks enforced). Checks 39 → 40 (ADD-ONLY: `deep_drop_band_reads` added;
check #20's recognition template broadened per the spec — requirements
unchanged).

## Triage (single replay per script, no critic — 2026-08-13 03:27–03:50)

Respawn tiles changed for every stream with a kill (the increment), so
each script's beats were counted against its revert-wall stream
(`/tmp/q6_revert_wall_<s>.log`, counts halved — gates run two replays)
before paying for gates. Verdicts:

| Script | Triage | Evidence (old per-replay vs new) |
|---|---|---|
| loot_loop | GATE AS-IS | beats identical: banked 1≡1, picked 1≡1, kills 8≡8 |
| world_loop | GATE AS-IS | beats identical incl. 9 projectiles |
| specials_chain | GATE AS-IS | specials 3≡3, taunt 1≡1, kills 9 vs 8 |
| taunt_anchor | GATE AS-IS | beats identical |
| district_hunt | TRY AS-IS | beats intact; an UNPLANNED wipe appeared (0→1) |
| ledger_loop | TRY AS-IS | bank+tallies intact; second wipe gone (2→1) |
| vat_economy | RE-PILOT | tribute 0 vs 2, banked 1 vs 4, corpse_loaded 0 vs 1 — acts 3-5 dead |
| corpse_run | RE-PILOT | corpse_looted 0 vs 1 — the namesake beat never fires |
| threat_pull | RE-PILOT | drop_picked_up 0 vs 1, corpse_loaded 0 vs 1 — economy beats dead |

Mechanism evidence, in-stream: density telemetry fired in ALL 9 triage
replays — e.g. vat_economy `pockets{mean=6.0 max=5} arrivals{pocket=13
seed=0 home=0} singles_pct=53`; district_hunt `arrivals{pocket=7 seed=4}`
(seed path live); singles_pct falls with session length (86 → 62 → 53).
Pockets of 7-8 observed: legitimate — the cap bounds JOIN-driven growth;
humans converging by aggro/leash merge pockets organically.

NOTE: no current stream stages a band-2 kill (every q6 line shows b2=0),
so `deep_drop_band_reads` would pass everywhere as not-exercised. The
deep-kill + ember-drop beat is REQUIRED STAGING in the threat_pull
re-pilot (it already pushes deep) — the rider must be SEEN passing.

## Phase 1 — the six as-is gates (map)

| # | Script | Attempt | Result | Notes |
|---|--------|---------|--------|-------|
| 1 | loot_loop | 1 | PASS | |
| 2 | world_loop | 1 | PASS | |
| 3 | specials_chain | 1 | PASS | |
| 4 | taunt_anchor | 2 | PASS | A1 = INFRA, explicitly labeled: `GATE INFRA ERROR: unusable verdict` (critic returned malformed JSON); det 10/10, all telemetry fired. A2 clean. |
| 5 | district_hunt | 1 | PASS | unplanned mid-script wipe read fine (judgment floor on camera) |
| 6 | ledger_loop | 1 | PASS | one-wipe stream judged fine (recap + negative net on camera) |

**PHASE 1 COMPLETE 6/6** (03:54:42–04:54:38, one INFRA retry total).

Chain runner: `tmp/v11_wall_asis.sh`; per-script logs `/tmp/v11_wall_<s>.log`
(failed attempts preserved as `.attempt<n>.log`); summary
`/tmp/v11_wall_summary.log`.

## Phase 2 — re-pilots (pending)

vat_economy / corpse_run / threat_pull via `rake pilot` (protocol:
harness/pilot.rb header; append to inbox with printf, NEVER Write). Every
check exercised in the revert wall must re-stage (memory:
gate-critic-mandatory-beat-checks); the per-script exercised lists were
extracted from the revert-wall verdicts — grep `[PASS]` minus
"not exercised" in `/tmp/q6_revert_wall_<s>.log`. Key beats:

- **threat_pull** (seed 42): near-gate calm + deep-crowd frames
  (gradient_depth), pressure ring, 3 spaced projectile captures
  (open-floor — the flake lesson), retarget cues, drop pickup, corpse
  load + pip, **NEW: deep kill → band-2 ember/gold drop on camera**
  (deep_drop_band_reads).
- **corpse_run** (seed 7): nest fixtures frame, retarget cue, projectile,
  carry (numeral), die carrying (pip), wipe (veil + recap + negative
  net), RETURN with pip visible (corpse_run_reads), LOOT (corpse_looted),
  bank tally, pressure ring.
- **vat_economy** (seed 7, five acts): hunt + bank; inscribe (god-mark
  frames, 2 zones); volley + taunt underline; tribute with dead+wounded
  (before/after regrowth); wipe with ONE marked (judgment: marked
  survives, mark burns); rebuild; wipe broke+unmarked (floor: vessel
  kept); deep push (gradient depth + deep corpse load + projectile).

Then: `rake perf` ALONE (p95 < 16.6 ms) → full rake → merge `--no-ff`
(NO push) → CHECKPOINT → BLIND ninth verify.

## Phase 2 — re-pilot results (2026-08-13, 06:22–07:40)

All three re-piloted via `rake pilot` (printf-append protocol), exports
installed in `harness/scripts/`, then official gates (double replay + md5 +
critic on 40 checks). Chain: `tmp/v11_wall_phase2.sh <script>`; logs
`/tmp/v11_wall_<s>.log`, summary `/tmp/v11_wall_summary.log`.

| # | Script | Attempt | Result | Notes |
|---|--------|---------|--------|-------|
| 7 | corpse_run | 1 | PASS | pilot corpse3 (seed 7, r2, 4133f, 18 captures incl. post-hoc veil@2500). Negative-net staged via window split: pickups resolved quiet (+4), lobber died carrying 4 in a FRESH window → wipe recap `+0/-4/=-4` bold red. corpse_looted@3314, bank +4@4126. |
| 8 | threat_pull | 2 | PASS | A1 = INFRA, explicitly labeled (`no JSON object in model output: ''`); det 20/20 both attempts. Pilot tp3 (seed 42, r3, 5109f, 20 captures, 7 post-hoc). **deep_drop_band_reads EXERCISED-PASS** — critic: "glowing ember-gold square in 4392 reads visibly richer than the small magenta drops". Two band-2 kills staged (rusher5→[29,5]=2, rusher16→[27,6]=4; q6 line b2=2). Unplanned wipe@3019 read fine (veil 3067). r1/r2 abandoned: deep field mobbed the walk-in twice — the v11 mass IS the hazard; final route looped W→S→E row 18 then plan-B vessel walk-back killed the wounded straggler deep. |
| 9 | vat_economy | 1 | PASS | Pilot vat3 (seed 7, r1 single generation, 12797f, 20 captures curated from 31). All five acts + riders event-confirmed: banked 20/8/25 (tallies on camera), tribute×2 (26 both, before/fired/after), inscribe@9143 (striker), god-mark nest 9187 + district 10173 (2 zones), taunt victims=9 (pulse 10246 + underlines 10264), volley cast 9928 (brackets cited at 10264), deep pip corpse_loaded@10367 [32,11] (on camera 10380), wipe#1 marked → mark_consumed + 2 dissolved (veil 11693, judgment 11813), wipe#2 broke+unmarked → vessel_kept (floor veil 12696, return 12796). Swap-stagger (20f) eats special presses — cast only after `wait 25`. |

**WALL COMPLETE 9/9** (phase 1: 6/6 one INFRA retry; phase 2: 3/3 one INFRA
retry). Determinism passed every attempt for every script. Density telemetry
in the re-piloted streams: corpse_run `arrivals{pocket=13 seed=0} singles 61`
· threat_pull `arrivals{pocket=6 seed=0} singles 76, b2=2` · vat_economy
`arrivals{pocket=36 seed=3} singles 41, b2=20` — pocket anchor dominant, seed
path live, home fallback never needed.
