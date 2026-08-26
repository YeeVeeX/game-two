# C2 canary rebank — stream-diff audit (s80, 2026-08-26)

**Protocol run:** versioned-bank protocol per
`test/harness/sim_identity_canary_test.rb` header. The change under
test is C2 (ally defensive-default engage rule, v19 foundation Lane 3
row 13, RATIFIED-G + RATIFIED-J 2026-08-22; decision doc
`drafts/_c2-defensive-default-20260826.md`). A ratified sim change
moves event streams by design — the S43 precedent (T2 progression)
walked exactly this shape. Owner/peer ratification of the REBANK rides
the standing async-ratification lane (s79 checkpoint queue); flagged
prominently in the s80 checkpoint entry + ship commit.

**Method:** old streams generated from a git worktree pinned at
`5c3ec67` (pre-C2 HEAD; the mid-sweep-contamination law), new streams
from the live tree, both via the same `Headless.run_script` instrument
the canary asserts with. Old md5s reproduce the ACTIVE bank EXACTLY
(worktree baseline sound):

| script | old (= ACTIVE bank) | lines | new | lines |
|---|---|---|---|---|
| world_loop | `a4150c43669b9783e59cb6c39c322b67` | 70 | `982bfd66085005e73d808fcf5d05761d` | 37 |
| varekka_duel | `bf35628a3d2ba50b0aa7d78f9749755e` | 167 | `ecc750ec4577bed854f1d210ba41aac5` | 43 |
| burn_duel | `fedf0452fc35b62850895016710abdea` | 184 | `36d6281cb5988432eda9022fe16acc3c` | 156 |

Streams archived: `tmp/s80_streams_old/` + `tmp/s80_streams_new/`
(tmp is gitignored; this doc carries the audit).

## Prefix identity up to the change's first effect

- **world_loop:** byte-identical through line 4 (zone entries +
  scripted possessions). First divergence = line 5: old
  `human_retargeted frame=359 … to=lobber`, new
  `human_retargeted frame=390 … to=striker`. Effect: free allies no
  longer CHARGE ahead of the walking possessed, so the rushers' first
  proximity acquisition fires 31 frames later and lands on the
  possessed striker (nearest body of the clumped formation) instead of
  the charging lobber. Human-side chain untouched (cause=acquired,
  same chain order).
- **varekka_duel:** byte-identical through line 2. Old line 3 =
  `attack_hit frame=6 attacker=striker victim=rusher11` — the free
  striker's UNPROVOKED frame-6 swing, i.e. the exact behavior C2
  removes; it is gone from the new stream, whose first sim event is
  the SCRIPTED possessed blocker special (frame 30). Its taunt pulse
  now catches 3 victims (was 2): the rushers the old striker
  aggression had displaced/killed by frame 42 are alive and in radius.
- **burn_duel:** byte-identical through line 2; same first effect (the
  old frame-6 unprovoked striker swing removed). New first event =
  mass `human_retargeted frame=90 … to=blocker cause=acquired` — the
  clumped pack walks into rusher aggro radii together, so many humans
  acquire the same nearest body.

## Divergent-line classes (every line explained)

All divergent lines fall into these classes; no new event kind appears
and none escapes the EventBus whitelist:

1. **Removed unprovoked free-ally engagements** (attack_hit /
   projectile_fired / telegraph / actor_died / drop chains initiated by
   uncontrolled striker/lobber/blocker with no prior provocation) —
   the ratified change verbatim.
2. **Shifted human acquisitions** (human_retargeted frame/target
   deltas; `challenged`/`acquired` causes preserved) — humans acquire a
   FORMATION now (allies trail the possessed), not charging singletons;
   the selection chain itself is untouched.
3. **Downstream combat re-sequencing** (all later frames): once any
   human connects, provocation stamps and allies answer — fights still
   occur (new streams: 11 actor_died, 60 attack_hit, 41 telegraph
   across the three scripts) but along the new geometry, so every
   subsequent kill/drop/respawn line moves.
4. **Consequence deltas of fixed choreography**: the scripts' inputs
   were authored against offensive allies. world_loop loses its
   banked/drop_picked_up lines (drops land on different tiles than the
   old walk path collects); **burn_duel now ends in pack_wiped +
   pack_respawned** — the scripted possessed absorbs pressure the old
   pre-clearing allies used to burn down. RECORDED as a ritual watch
   item (pressure shifts to the possessed under defensive allies), not
   a defect: the canary law asserts byte-determinism of the stream,
   and the wipe is lawful sim behavior under fixed inputs.

**Boss-cycle note (varekka):** new stream holds 1
challenger_chant_started, 0 vessel_seized within the window (old s73
profile: 1 chant, completion + vessel-died). The chant starts later
along the new fight geometry and the window closes before completion.
The s73 header note ("second cycle unreachable pre-Lane-3 C2/C3")
anticipated C2 would move this surface.

## Bank rotation

Outgoing ACTIVE preserved as `S73_HISTORY` (immutable) in the canary
file; new ACTIVE = the C2 streams above. Determinism of the new bank
verified by double replay (same md5s twice) before landing.
