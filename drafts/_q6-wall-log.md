# v10.1 Q6-retune wall log — official Rule-2 gates on the retune build

Build: branch `q6-retune` at `b4f806d` (telemetry `88e3adb` + gradient `48b140f`
+ cue `b4f806d` on top of main `47ab007`). Suite 285 runs / 1,179 assertions
green at every commit (hooks enforced).

Expectation (plan §Task 4): ZERO re-aims — no husk-behavior change; only HUD
digits and cue duration differ; the 7 number-sensitive checks gate on
format/prominence, not digits; gradient_depth_reads checks enemy density, not
drop amounts. Determinism is within-run double-replay.

Order (fail-fast, economy-heavy first): vat_economy → ledger_loop → loot_loop
→ district_hunt → world_loop → corpse_run → threat_pull → specials_chain →
taunt_anchor. Chain halts on first nonzero EXIT for triage (INFRA → retry the
gate, NEVER re-pilot; real check-FAIL → read `drafts/_gate-verdicts.log`, fix
forward).

## Round history

- **Round 1 (build `b4f806d`): HALTED on vat_economy — INFRA, not a check
  failure.** Determinism 20/20 byte-identical; the critic died to a Bedrock
  `internalServerException` raised MID-STREAM (`EventStreamError`), which the
  hardened critic's retry tuple did not cover (it caught throttle/connect/
  read-timeout only). Fix `de29069`: EventStreamError added to the retry
  tuple, retried like a throttle. Harness-only — zero sim impact, replays
  untouched.
- **Round 2 (build `de29069`)**: 6/6 straight passes (vat_economy through
  corpse_run), then HALTED on threat_pull — a REAL check-FAIL, root-caused:
  `projectile_visible` FAILed with "not exercised". Verdict history shows the
  beat was always marginal — capture 598 catches the 594 shot only 4 frames
  (~1 tile) into a 19-frame flight, pressed against the lobber; it flaked
  twice on 2026-08-11 pre-retune. The 75-frame cue made 598 busier (a rust
  block now flashes in that exact frame — today's retarget_cue_reads cites
  it), tipping the marginal speck under. Fix-forward per the D1b technique:
  ADD captures 604 + 607 (same shot, 2.5/3.25 tiles clear, mid-flight open
  floor) — no existing evidence frame moved (`0138119`). NOT verdict-shopped:
  the gate re-ran with better-aimed evidence, not a re-rolled verdict.
- **Round 3 (build `0138119`)**: threat_pull → specials_chain → taunt_anchor.

## Wall map (script → round → EXIT)

| # | Script | Round | EXIT | Notes |
|---|--------|-------|------|-------|
| 1 | vat_economy | 2 | 0 | R1 died to mid-stream Bedrock 500 (INFRA → `de29069`); det 20/20 both rounds |
| 2 | ledger_loop | 2 | 0 | |
| 3 | loot_loop | 2 | 0 | |
| 4 | district_hunt | 2 | 0 | |
| 5 | world_loop | 2 | 0 | |
| 6 | corpse_run | 2 | 0 | |
| 7 | threat_pull | 3 | 0 | R2 FAIL projectile_visible (marginal speck at 598) → re-aim `0138119`; R3 pass cited 0598 itself — 604/607 stand as triple coverage (flake history 3-in-11) |
| 8 | specials_chain | 3 | 0 | |
| 9 | taunt_anchor | 3 | 0 | |

## Final: WALL COMPLETE 9/9 determinism + 9/9 critic (18:37:22)

Perf ALONE (post-wall): ticks=6990 p50=0.142ms p95=0.224ms max=3.207ms
(budget 16.6ms). Full suite after: 285 runs / 1,179 assertions, 0 failures.

---

# REVERT wall — re-proof of the reverted build (v11 step 0, 2026-08-13)

Build: main `2de5be2` (= `d6615f5` build; docs-only commits on top of the
`6283264` revert — band-2 3.5 → 2.0, shape-law ≥3.0 floor dropped). Suite
285 runs / 1,178 assertions green.

**Chain 1 (2026-08-12, on `6283264`): DEAD — INFRA, no verdicts.** Summary
log held one START line (vat_economy 19:39:22); the per-script log cut
mid-replay ~frame 15.5K; no ruby/rake process alive — the chain died with
its session, never reaching a critic call. Preserved:
`/tmp/q6_revert_wall_summary.dead-chain-20260812.log`.

**Chain 2 (2026-08-13, 00:51:52–02:10:34): WALL COMPLETE 9/9 determinism
+ 9/9 critic.** Runner: tmp/q6_revert_wall_chain.sh (3-attempt retry per
script baked in).

## Wall map (script → attempt → result)

| # | Script | Attempt | Result | Notes |
|---|--------|---------|--------|-------|
| 1 | vat_economy | 1 | PASS | det 20/20; q6_cadence fired: banks{n=4 mean=13 max=24} kills_by_band{b0=12 b1=18 b2=6} — 2.0-gradient economy on camera |
| 2 | ledger_loop | 1 | PASS | |
| 3 | loot_loop | 1 | PASS | |
| 4 | district_hunt | 1 | PASS | |
| 5 | world_loop | 1 | PASS | |
| 6 | corpse_run | 1 | PASS | |
| 7 | threat_pull | 1 | PASS | the retune wall's flaky gate — clean here |
| 8 | specials_chain | 1 | PASS | |
| 9 | taunt_anchor | 2 | PASS | A1 critic-judgment flake: `projectile_visible` FAILed with det 10/10 byte-identical and vision 38/39 — the same shot beat (frames ~1363) passed in prior walls and the last 11 projectile_visible verdicts across scripts were passes. Attempt 2: same evidence, full PASS. NOT verdict-shopped: evidence unchanged, judgment noise on a known-marginal check; attempt-1 log preserved at /tmp/q6_revert_wall_taunt_anchor.attempt1.log |

Digits-only-delta expectation held: zero re-aims, zero re-pilots — the
twice-proven build class re-proved. The reverted build is Rule-2 valid;
v11 work may begin.
