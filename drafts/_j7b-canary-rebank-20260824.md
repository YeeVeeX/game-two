# J7-B canary rebank — varekka_duel stream-diff audit (s59, 2026-08-24)

**Protocol:** versioned-bank (test/harness/sim_identity_canary_test.rb
header). This doc is the stream-diff audit; the outgoing bank hash is
preserved immutable in the test file; the sim change is the double-
ratified J-7 lane (foundation row 12, RATIFIED-G + RATIFIED-J
2026-08-22; brief `drafts/_j7-catchup-brief-20260824.md` md5
`9802eec972b754c255af83fdf07662b1`). **REBANK RATIFICATION: PENDING
(Gabriel, async per owner order 2026-08-22)** — revert = swap one hash
back (history preserved in the test file).

## What moved

- `varekka_duel` ACTIVE `68fa69f6e23f0ae39361eec2fbc8c5d1` (220 lines)
  → `31c699cb2ecea5257cd55ec801aa0805` (222 lines).
- `world_loop` + `burn_duel` canaries: UNCHANGED (hashes identical).
- Full-wall headless stream audit (25 scripts, old worktree @473c3d2 vs
  J7-B tree, `tmp/s59_audit/verdict.txt`): **24 IDENTICAL, 1 MOVED
  (varekka_duel only)**.
- Identity pairs (D8): world_loop + low_quay_run **24/24 byte-identical**
  (`tmp/s59_baseline/` vs `tmp/s59_post/`) — the brief's pre-declared
  expectation held exactly.

## Prefix identity

Old and new streams are **byte-identical through line 159** (EVENT
`possession_changed frame=1050`). First divergence = old line 160: the
snap-home burst. The change's first effect is exactly the first stamped
re-entry — nothing upstream moved.

## The divergence, line by line

At frame 1049 the scripted pack steps onto low_quay[1,4] → slow_door
(arrival [7,2]); slow_door [7,1] auto-fires straight back → re-enters
low_quay at frame 1050. **elapsed = 1 tick.**

- OLD law: the 1-frame bounce snap-teleported every displaced low_quay
  human home — 8 `human_leashed` lines at frame 1050 (rusher4/13/16,
  rusher_hater22/24/25/28, and BOSS challenger29 from [11,2] back to
  [43,15]) = a free mid-duel room reset.
- NEW law (brief D4, verbatim clause): "leave-and-immediately-return
  reads as nobody moved" — elapsed(1) ≤ linger(90) → walk_ticks 0 →
  zero placements, zero emissions. The 8 lines are DELETED; the room
  honestly stays where it stood.
- `human_retargeted frame=1051 rusher13 → lobber cause=lowhp`: the
  wounded rusher that was NOT teleported away re-acquires — the finite-
  speed law's direct consequence.
- `respawn_telegraphed tile [33,16] → [3,18]`: the release-time pocket/
  seed anchor computes over the ACTUAL (unmoved) roster positions; same
  draw count, different anchor. Not an rng divergence.
- Everything after (chant/possession/death timing, and the NEW stream's
  `pack_wiped frame=2198` + nest judgment at 2288): the duel evolving
  against 7 hostiles + the boss who stayed engaged instead of resetting.
  Single root cause; no second mechanism.

## Consequence surfaced (the STOP-worthy finding)

varekka_duel's choreography (and its manifest: 6 chants / 4 interrupts /
2 seizures) was **earned via the now-dead teleport-reset exploit** — the
brief's wall-debt audit claim "zone-start duel scripts never
leave-and-return" is refuted by this script. Under the new law the same
inputs wipe at 2198: captures ≥ 2578 move, the manifest cannot be met.
The script is a stale test of removed behavior and needs an interactive
re-pilot under the new law — **its own ticket (queued s60-first)**. The
manifest is NOT weakened in the interim; varekka_duel's wall slot is
declared RED until re-authored. Boss-tell captures 149/937/998 sit in
the identical prefix and still prove their checks.

## Artifacts

- Streams: `tmp/s59_stream_old.txt` / `tmp/s59_stream_new.txt` (+ per-
  script pairs under `tmp/s59_audit/`).
- Repro: `tmp/dump_stream.rb` via test/support/headless_script (the
  banked etapa-0 instrument path).
