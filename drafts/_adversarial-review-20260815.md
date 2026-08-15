# Adversarial project review — 2026-08-15 (owner-commissioned)

Owner ask: full adversarial review — gaps, quality start→now, drift from the
original vision, steering. Reviewer: dev agent (pi session), with cross-vendor
council. Everything below is evidence-backed; claims without evidence are
marked as judgment.

## Method

- Local sweep: source, tests, harness, data, git history (304 commits,
  2026-08-09 → 2026-08-15), specs (14), drafts (108), PARKING_LOT (95 entries).
- Live gates: `bundle exec rake` → 451 runs, 1,961 assertions, 0 failures
  (14.0s). `rake gate world_loop SKIP_CRITIC=1` → 10 captures byte-identical.
- Vision reconstruction: `drafts/_goal-20260809.txt` + first CLAUDE.md +
  earliest commits.
- Council (budget: one round, 2 calls, ~4KB brief): DeepSeek V3.2 (adversarial
  arch/process) + Kimi K2.5 (design/steering). Verdicts reconciled below.

## Verdict

Well-run project with one blind spot that could erase it. The methodology
(scope contracts, blind fun-verifies with pre-registered routing, layered
md5+manifest+vision wall, seeded split-stream RNG, data-driven balance) is
real and mechanically enforced — and it provably catches its own failures
(manifest law caught desyncs the critic missed; the pilot found the tax-wall
before the owner did). Quality trend: rising. The blind spot: the process's
own artifacts were the least-engineered part of the project.

## Findings (ranked)

1. **CRITICAL — institutional memory had zero VCS protection.** `.gitignore`
   excluded `drafts/_*`: 107/108 process artifacts (every fun-verify verdict,
   calibration doc, impl review — the files the scope contract cites as ground
   truth) existed on one disk only. The wall runner itself lived in gitignored
   `tmp/`; the one silent-failure incident in project history (PIPESTATUS
   masking critic failures ~2 cycles) happened exactly there. Council: both
   CONFIRMED, both ranked the fix top-2. **FIXED THIS SESSION** (see below).
2. **HIGH — the god-object relocated.** window.rb 69/300 lines (cap holds),
   but world.rb = 1,522 lines / 107 methods; the bus is a telemetry spine
   (38/43 emits → telemetry/ledger), not decoupling. Council pushback
   accepted: sim is deterministic, tested, shipping — a refactor cycle risks
   more than it buys. Ruling: growth cap + extract-on-touch, plain objects
   with explicit call order, NO bus-mediation in the sim. Filed in
   PARKING_LOT process debt.
3. **MEDIUM — telemetry accretes forever.** 429 lines of per-cycle counters,
   never retired. Both council models independently escalated this as the
   biggest unnamed risk; verified their worst fear wrong (telemetry only
   READS world — no mutation path, no determinism risk) but the accretion is
   real. Filed: retirement rule.
4. **MEDIUM — English lives in code literals.** strings.rb falls back to
   caller literals by design; es/pt-br carry 4 keys en lacks; renderer makes
   ~100 t() calls with inline English. The one-locale violation of the
   data-driven rule. Filed: en.json backfill riding v15.5(b).
5. **LOW-MEDIUM — single-machine truth.** No CI; hooks + wall are local;
   gosu compiles from source. Filed: headless CI for the pure-sim majority,
   GL tests skip loudly. Full CI rejected (poor solo-hobby ROI, council
   concurred).
6. **LOW — ADD-ONLY check policy needs its amendment valve codified.** My
   original "replace with versioned baselines" was REFUTED by DeepSeek
   (conservative comparability is a feature) — conceded. v15.5(d) is the
   ad-hoc precedent; codify it. Filed.
7. **LOW — no README** for humans (Junior clones for multiplayer). Filed.

## Council reconciliation (the disagreement was the finding)

- C5 "presentation is the real bottleneck": DeepSeek CONFIRMED, Kimi REFUTED
  (the 19-second death is a systems/balance fault — healing access — not a
  renderer fault). Both right at different layers: **livability is the
  blocker (v15.5a, in flight); presentation is the ceiling** (P1 "otro
  distrito más", P5 illegible, P6 "suenan falsos" are all presentation-family
  reads). Steering reflects that order.
- Corrections accepted from review: "failed livability twice" overstated (one
  verify, two zone entries); "plain objects is the right fix" was prescription
  beyond evidence (kept as ruling, labeled judgment).

## Drift analysis

- Original (2026-08-09): fun-verified vertical slice, depth-first. The pivot
  to "full Kethral shape" was owner-ratified AFTER the slice verified fun
  (e320ccf) — process working, not drift.
- Real drift: systems velocity outran presentation the whole way (6 zones /
  economy / challenger vs rects, placeholder audio, native-res text). The
  owner's last three answers all hit that ceiling.
- Looming drift: v16 multiplayer before the loop is livable+legible repeats
  the Kethral breadth pattern (council: CONFIRMED top strategic risk). The
  lockstep-over-Tailscale plan (PARKING_LOT directives) is technically sound;
  the recommendation is about ORDER, not feasibility. On record: presentation
  cycle first, multiplayer v17. Owner decides at the fourteenth.

## Executed this session (owner approved 2026-08-15)

- `.gitignore`: drafts tracked (media corpus `drafts/_tibia-videos/` stays
  ignored — 250MB video reference); ~107 text artifacts (3.1MB) enter git.
- `harness/run_wall.sh`: canonical wall runner, tracked — `set -o pipefail`
  + explicit PIPESTATUS, dynamic glob over `harness/scripts/` (inline lists
  went stale), bundle exec, fail summary + nonzero exit. tmp/ copies are
  superseded (left in place; tmp is scratch).
- `test/harness/run_wall_test.rb`: guards the shell invariants (syntax,
  pipefail+PIPESTATUS, dynamic glob, loud failure, bundler).
- AGENTS.md (renamed from CLAUDE.md by owner; trim + rename ratified in git):
  run_wall in Commands, tracked-drafts note in Enforcement, history pointer
  now `git log --follow -- AGENTS.md`.
- PARKING_LOT.md: process-debt section (en backfill, telemetry retirement,
  world.rb cap, check-amendment policy, headless CI, README, v16
  recommendation).

## Not executed (deliberately)

- No game-scope changes: v15.5 (a)–(d) untouched, owned by the dev-of-record
  cycle session. No world.rb refactor. No CI yet. No new systems. Nothing
  outside the approved bundle.
