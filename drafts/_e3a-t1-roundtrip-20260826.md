# E3a-T1 — P1 bundle emitter + headless re-executor + verification receipt (s83, 2026-08-26)

Spec: `docs/superpowers/specs/2026-08-26-e3a-capture-contract.md` §7 T1
(rider row 22, fence ratified verbatim). CLAIMED at `c6ceb8c` before
work (s56 race law). Ship commit: `c35701c` + review-fix commit (this
doc rides it). Legal under the EIGHTEENTH freeze: touched files =
`harness/bundle_writer.rb` (new) · `harness/bundle_replay.rb` (new) ·
`harness/replay_runner.rb` (wiring) · `.gitignore` (`bundles/`) ·
`test/fixtures/bundle_roundtrip.json` + `test/harness/
bundle_roundtrip_test.rb` (new) · spec §2 one-row amend — ZERO frozen
files (freeze-watch clean before and after), zero live-play surface,
no renderer, critic calls 0.

## What shipped

- **Emitter (P1):** script key `"bundle": true` on the replay runner.
  `Harness::BundleRecorder` samples `Protocol.mask` once per executed
  tick (sampling law), folds `[mask]` keyed by `world.frame` BEFORE
  `World#tick` and closes windows right after — the netplay
  `run_tick` order verbatim. Writes `bundles/<UTC>_p1_<seed>/`:
  members first, manifest LAST and write-once (D7); member sha256s
  from disk bytes; LF-pinned binwrite. Manifest carries every §2
  field (fingerprint_md5 REQUIRED = `Net::Fingerprint.tree_md5`;
  game_commit best-effort with GIT_* scrubbed, null on failure — W6).
- **Terminal snapshot digest (spec §2 amend, s83):** windows close
  only at cadence boundaries — trailing ticks were covered by member
  sha256s alone, so a consistent-liar trailing tamper would escape
  the chain compare. Both sides now record/compare a snapshot-only
  `[tick, md5]` at end-of-run. Residual named in the writer: a
  trailing tamper that changes NO snapshot state still escapes.
- **Refusals NAMED at construction (§3):** non-world scenarios
  (netplay/menu/moving_square) + actions outside `Protocol::ACTIONS`;
  the runner reaches the refusal via `respond_to?(:world)` so a
  worldless scene refuses instead of NoMethodError (review fix).
- **Re-executor:** headless (no Gosu — D9). Flow: manifest →
  fingerprint of the verifying tree stamped on EVERY receipt → member
  integrity (mismatch/missing = RED without executing a tick) →
  fingerprint mismatch = REFUSAL naming both values, NO receipt →
  save.json strict-decode seam (P2-ready; refusals NAMED) → N fresh
  re-executions (fresh World + StateDigest each, `apply_start`
  preserved, `SampledInput` masks in the recorded fold order) →
  three-way compare (recorded + every run, index-wise incl. length
  mismatch, then terminal) → `verification.json` receipt. Exit: 0
  PASS · 1 RED · 2 refusal.
- **Gate (D10):** default runs=2 — both chains must equal each other
  AND the recorded chain; first divergence localized to one cadence
  window (D4).

## Verify evidence (ticket's Done-when, all captured this session)

- Suite roundtrip (real sim, real files, no mocks): 8 runs, 73
  assertions, 0 failures — PASS direction + BOTH tamper directions
  (file-level sha RED runs=0; consistent-liar restamp RED at the
  first cadence window) + fingerprint refusal (both values, no
  receipt) + write-once + scope refusals.
- CLI (the real runner, world_loop-derived + `bundle: true`, 1249
  ticks): `BUNDLE bundles/20260826T175326Z_p1_42` → re-executor twice:
  `verdict=PASS runs=2` / `verdict=PASS runs=2` (exit 0).
- CLI tamper (mask tick 100 attack-bit flip + re-stamped sha):
  `verdict=RED runs=2` `reason=digest chain diverged at window
  tick=120` (exit 1) — correct D4 localization.
- CLI scope refusal (moving_square + bundle): NAMED one-liner, exit 1.
- `rake` green through hooks: 1295 runs, 23197 assertions, 0 failures.

## Fresh-eyes review (Rule 6 — non-authoring headless session)

Verdict: **PASS_WITH_FIXES**, 0 blockers. Applied before push:
(1) MAJOR — runner evaluated `@scene.world` before the scenario
refusal (worldless scenes died NoMethodError): fixed via
`respond_to?`, proven by live CLI refusal. (2) minor — member-RED
receipts now stamp `fingerprint_at_verification` (the tree that
judged). (3) minor — spec §2 digest_chain row amended to name the
`terminal` field. Record-only minors (not built, on purpose):
cadence-range coupling in the chain-window test assertion (breaks
loudly on retune — acceptable); manifest `machine` = hostname where
spec says "machine class" (stated at source, consumer records
as-stated); manifest seed/seats duplicate preconditions without a
cross-check (semantics stay bound by the chain compare — a lying
precondition diverges the chain; refusal nicety declined, lean-tool
bias).

## Notes for T2/T3

- T2 (Mode T tracks) hangs off `BundleReplay.execute`'s world loop —
  emit per-tick records behind a flag + tick range from a VERIFIED
  bundle only.
- T3 (P2 dump-at-close) serializes Session's retained queues +
  `@digest_log` + handshake facts through `BundleRecorder`-shaped
  members; `save.json` decode seam already live in the re-executor.
- Delivery to the assets seat (spec §6) = MAIL naming bundle path +
  manifest sha256s + receipt — owed at T2 (reference track + schema
  section), not now.
