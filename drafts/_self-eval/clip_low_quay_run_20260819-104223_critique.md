# Self-eval: clip_low_quay_run_20260819-104223

Focus: General quality pass: is this appealing, entertaining and fluid? What should we improve first? This clip walks the descent into ZONE low_quay: fights on the way down, banking, and the return loop.

# Clip critique: clip_low_quay_run_20260819-104223

## Verdict in three lines (appealing? entertaining? fluid? — honest, structure-only)

**Appealing? Yes, structurally.** The descent-bank-return skeleton is genuinely legible from raw frames alone — collect (t=0:52.17), die and lose it (t=0:56.90), recover and bank (t=1:08.00) is a working roguelite arc with visible stakes.
**Entertaining? Half.** Kiting fights and swarm ramps generate real drama (the low-HP escape at t=1:19.70–1:22.33 is story-worthy), but the entire cause-and-effect layer of combat — what I swung, what hit me, what died — is invisible, so the best moments are inferred, not felt.
**Fluid? Mostly.** Movement cadence is brisk and stutter-free (t=2:09.13→2:11.17), turnarounds are tight (~7s death-to-hub, t=1:43.73→1:50.90), but the clip is bracketed by dead-air return legs (t=2:00.90–2:07.30) and a pursuit AI that gives up (t=2:16.03–2:17.87).

## Scores (0–10)

- **Readability: 5/10** — Self-identification and hit-confirms are excellent (white outline + hit-flash, t=0:00.00, t=0:38.10), but damage *attribution* fails everywhere: unexplained HP loss (t=0:13.47), unreadable death dogpile (t=1:42.93–1:43.73), invisible boss (t=0:49.83), and enemies that vanish vs. move ambiguously (t=0:35.90→0:36.13).
- **Feel/juice: 4/10** — The hit-flash and two-layer HP bar are the right primitives (t=0:20.67, t=0:13.47) and the death ledger lands hard (t=1:43.73), but there is no confirmed knockback, hitstop, shake, death VFX, or attack visual anywhere in ~2.5 minutes of combat (t=1:38.23–1:38.57 flash-without-displacement; t=0:41.83→0:43.73 silent kills).
- **Fluidity/pacing: 7/10** — Escalation ramps are excellent (2→8+ enemies in ~10s, t=0:13.47–0:20.67; the swarm doom-ramp at t=0:55.27–0:56.90), hub turnarounds are tight (t=0:24.30→0:31.30), but the pressure curve is spiky — overwhelm-then-nothing (t=1:42.93 vs t=2:03.73) — and return legs are dead air (t=2:12.73–2:17.87).
- **Loop engagement: 7/10** — Real decisions are on screen: kiting (t=0:16.73→0:17.93), fighting retreat (t=0:38.67→0:43.50), mid-swarm possession swap off a hurt body (t=1:40.93→1:41.77), post-death build change lob→spin→shout (t=1:42.03/1:52.10/1:56.13). Undercut by "+0" reward beats (t=0:24.30, t=1:23.07, t=2:07.87) and pursuit that never punishes retreat (t=2:14.87–2:17.13).

## What already works (keep + amplify)

1. **Identity layer is solved.** White outline on the possessed unit + matching HUD bar highlight + footer label means you always know who you are, through swaps and swarms alike (t=0:00.00–0:05.33, t=1:41.77, t=2:10.50). Don't let the asset pass regress this.
2. **Enemy hit-flash carries combat alone.** The yellow/orange outline flash makes even a three-body scrum parseable with zero animation (t=0:38.10 triple-flash off one spin; t=0:20.67 multi-hit in a crowd). This is the hook to hang all future juice on.
3. **The death ledger.** "+5 / -11 / = -6" on a dimmed screen (t=1:43.73), and "+0 held / -6 banked" (t=0:56.90) — instantly understood, emotionally blunt death receipts. Keep exactly this format.
4. **Loop cadence.** Bank→heal→descend in ~7s (t=0:24.30→0:31.30); death→hub in ~7s (t=1:43.73→1:50.90); hub→fighting in ~3s (t=1:10.07→1:13.23). Respawn friction is already tuned better than many shipped games.
5. **Escalation curves and zone storytelling.** Enemy counts ramp readably within each descent (t=0:13.47→0:20.67, t=1:36.27→1:39.43), and zone banners + palette snaps (warm hub → cold blue dungeon, t=0:30.50→0:31.30; t=1:23.07/1:31.97) sell "going deeper" with placeholder tiles.
6. **Party verbs are real.** Distinct actions per character (lob/spin/shout) and tactical mid-fight swapping (t=1:40.93→1:41.77) prove the possession fantasy functions.

## Top issues (ranked, each with evidence + a concrete, small fix candidate)

1. **Kills evaporate silently — the single biggest feel leak, present in every segment.** Enemies present one frame are absent the next with no burst, corpse, or fade (t=0:35.90→0:36.13; t=0:51.20→0:51.67; t=0:20.67→0:22.37; t=1:16.57→1:17.27), and "did I kill it or did it move?" is genuinely ambiguous. *Fix:* 4–6 frame geometric shatter in the enemy's own color + one-frame white pop. Pure code, no art.

2. **Incoming damage is unattributed — the player cannot learn from getting hit or dying.** HP drops with no telegraph, source, or on-sprite feedback (t=0:13.47–0:15.53; t=1:14.27→1:15.83), chip damage registers only as a HUD tick (t=2:05.63), and the fatal dogpile drains 2/3 HP to death in ~1.2s with no per-hit chain (t=1:42.63–1:43.73). *Fix:* player red-flash (2 frames) + 200ms enemy wind-up pulse before any contact damage. The wind-up hook already exists in embryo (outline shift at t=1:42.63) — amplify it.

3. **Player attacks have no visible existence.** No swing arc, hitbox flash, or directional cue in any sampled frame across the whole clip; kills read as "proximity happened" (t=0:15.53, t=1:16.57, t=1:38.23). *Fix:* a 2–3 frame directional slash arc. This single element converts every fight from inferred to performed.

4. **No knockback → enemies stack into unreadable, unkitable blobs.** Struck enemies don't displace (t=1:38.23 vs 1:38.57; t=0:38.10 formation intact after multi-hit), and swarms collapse 6+ units into a 3×2 blob so threat count is uncountable — likely a direct contributor to the t=1:42.93 death ("thought I faced 3, faced 8"). *Fix:* 1-tile grid-step shove on hit + hard tile-occupancy (or small offsets) for enemies. Fixes feel and readability in one change.

5. **The "+0" reward beats are actively harmful.** Zero-value popups occupy the hero feedback channel for seconds at a time (t=0:24.30 "TOLL PAID +0"; t=1:23.07; t=2:07.87–2:10.03), train players to ignore the popup slot that must later carry the real "+5" (t=2:18.00), and read as bugs. The lone "-150" at the gate is similarly undecodable (t=0:43.20). Whether these zeros are correct economy or defects is *unknown from frames* — but either way the presentation fails. *Fix:* suppress zero-value popups; add a carried-value indicator over the active character so the descent's stakes are visible before the receipt.

6. **"BOSS 1 SPAWNED" points at nothing.** Banner fires twice (t=0:49.83, t=0:51.13) with no visible boss, spawn VFX, camera move, or directional cue; the player leaves the zone immediately (t=0:52.17) and we can't distinguish avoidance from ignorance — which itself is the indictment. The yellow-dot state change on field enemies (t=0:50.20) is interesting but stakeless. *Fix:* screen-edge arrow + brief camera nudge toward the spawn point.

7. **Pursuit AI fails, hollowing out retreat tension.** The pack clumps against geometry and stops closing (t=2:16.03–2:17.87 barely moves between frames), pursuers shadow for 7s without engaging (t=2:00.90→2:07.30), so escapes and the "bank or push" decision are formalities (t=2:14.87–2:17.13). *Fix:* pathing pass around pillar rooms + a minimum-pressure leash so retreat costs something.

8. **ZONE 2 enemy-vs-terrain contrast fails.** Pale beige squares on tan walls share value; stationary enemies disappear into wall blocks (t=0:11.27, t=0:17.63 worst case). This is palette structure, not placeholder art. *Fix:* darken/saturate enemies one value step away from any terrain in their zone.

9. **Entity taxonomy is conflated.** Pink pickups vs pink dotted telegraphs vs static pink enemies vs gold squares are near-identical (t=0:36.70 vs t=0:38.10; t=0:54.20; t=1:39.03), and stray flashes far from the player collide with the damage-flash language (t=2:11.77). *Fix:* one geometry variant per class (circle=pickup, diamond=hazard, square=combatant) — still placeholder, zero art cost.

10. **UI occlusion and camera framing nits.** Loot toast sits center-screen for seconds over live combat (t=0:52.17–0:54.33); combat happens half off the right screen edge with the "-40" clipping (t=0:23.60); post-transition idle under the HUD text (t=0:45.83–0:49.83). *Fix:* corner-anchored toasts with 1s fade; camera lead in facing direction.

## Asset-era leverage (separate — what better assets would multiply, ranked)

1. **Enemy death burst VFX** — cheapest juice, highest payoff in swarm fights (fixes t=0:35.90→0:36.13 class of moments everywhere).
2. **Player attack swing/arc sprite** (2–3 frames per verb: lob/spin/shout) — connects cause to the already-working hit-flash effect (t=1:38.23).
3. **Distinct silhouettes per enemy behavior class** — chaser/static/elite currently differ only by outline color (t=0:54.20, t=1:19.30); 2–3 shape variants multiply threat readability more than any animation.
4. **Player hurt bundle** — red tint + directional damage tick pointing at the attacker (t=0:13.47, t=2:05.63), plus a low-HP bar pulse (t=0:56.13).
5. **Zone-specific enemy palettes with guaranteed terrain separation** (t=0:17.63) — zero animation cost, fixes the worst readability case.
6. **Consistent, higher-contrast damage numbers** — the system provably exists (t=1:09.97, t=0:43.20) but fires intermittently and in low-contrast purple (t=0:22.37); commit everywhere or nowhere, anchored to the correct actor.
7. **Boss presentation kit** — spawn telegraph VFX + camera pan so the banner (t=0:49.83) cashes in the excellent calm-then-spike pacing beat at t=0:48.63→0:49.83.
8. **Zone transition wipe/fade** (~200ms) replacing the hard black cut (t=0:44.57) and hard teleport (t=2:17.87→2:18.00).
9. **Pickup sparkle/pulse + banking deposit VFX** — makes the flee-and-grab micro-decision (t=0:38.37–0:44.13) and the "+5" arrival beat (t=2:18.00) pop.

## What to re-check on the next clip (same deterministic script, so these are directly verifiable)

1. **t=0:35.90→0:36.13 and t=0:51.20→0:51.67:** does a death burst now appear in at least one sampled frame where enemies previously vanished?
2. **t=0:13.47 and t=1:40.40:** when HP drops, is there now a visible player flash and an identifiable attacker (wind-up pulse in the preceding frames)?
3. **t=1:38.23 / t=0:38.10:** is the attack arc visible, and do struck enemies displace by a tile between adjacent frames (knockback confirmed)?
4. **t=1:42.93:** does the fatal dogpile now resolve into countable, non-overlapping units — and does the same death still occur, or does knockback change the outcome? (If the death disappears, difficulty retune flag.)
5. **t=0:24.30, t=1:23.07, t=2:07.87:** are "+0" popups gone/suppressed, and does a carried-value indicator make stakes visible *before* the receipts at t=0:56.90/t=1:43.73?
6. **t=0:49.83:** does the boss banner now co-occur with a directional cue or camera move — and does player behavior at t=0:52.17 change from immediate exit?
7. **t=2:16.03–2:17.87:** does the pack still clump against geometry, or does pursuit now pressure the corridor run-out (t=2:12.73–2:17.87 should no longer be free)?
8. **t=0:17.63:** ZONE 2 enemies distinguishable from wall tiles at a glance?
9. **t=0:52.17–0:54.33:** loot toast relocated out of the playfield center?
10. **Hitstop/shake remain *unknown* at this sampling rate** — if implemented, confirm via a frame-timing log or higher sample density around t=1:16.57 rather than eyeballing stills.
