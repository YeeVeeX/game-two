# Self-eval: clip_world_loop_20260824-051415

Focus: General quality pass: is this appealing, entertaining and fluid? What should we improve first?

# Clip critique: clip_world_loop_20260824-051415

## Verdict in three lines (appealing? entertaining? fluid? — honest, structure-only)
**Appealing:** Structurally, partly — the telegraph language (t=0:12.43, t=0:13.77) and possession swap (t=0:05.00→0:05.23) show a real combat grammar forming, but combat itself is largely invisible (no swings, no deaths, HUD-only damage at t=0:07.80).
**Entertaining:** Not yet — fights are either one-button trivial (whole cluster deleted by one spin, t=0:13.13→0:13.77) or happen off-camera without the player (t=0:12.37–0:12.80), so there's little visible tension or counterplay.
**Fluid:** Yes, genuinely — tile-step cadence is smooth (t=0:11.77→0:12.13, t=0:14.87→0:16.37) and zone transitions are instant (t=0:16.37→0:16.40); fluidity is the build's strongest current property.

## Scores (0–10)
- **Readability: 4/10** — telegraphs, active-unit outline, and HUD are excellent (t=0:12.43, t=0:05.23, t=0:13.77), but attacks are invisible, deaths are despawns (t=0:11.37→0:11.77), enemies camouflage against floor tiles (t=0:12.90), and the red screen flash inverts convention (t=0:13.77).
- **Feel/juice: 3/10** — one working hit flash (t=0:12.80) and one great stacked beat (spin at t=0:13.77), but zero knockback, no discernible hitstop/shake (t=0:08.37→0:09.63, t=0:12.37–0:12.80), and no on-field player-damage feedback (t=0:07.80).
- **Fluidity/pacing: 7/10** — traversal and transitions are the best thing in the build (t=0:00.00→0:05.00, t=0:16.37→0:16.40), docked for ~3s of dead air (t=0:08.37–0:10.53), lingering center-screen toasts (t=0:16.40–0:20.73), and a combat-to-walking ratio that skews toward downtime (t=0:13.77→0:16.37).
- **Loop engagement: 4/10** — real verbs exist (possession swap t=0:05.00→0:05.23, mark t=0:07.30) and progression ticks visibly (t=0:11.03→0:11.77), but enemies are passive (static t=0:05.23 vs t=0:07.30), companion fights resolve without the player (t=0:12.37–0:12.80), and the one player engagement was one-input trivial (t=0:13.77).

## What already works (keep + amplify)
1. **The red-tile telegraph language.** The 3x3 enemy telegraph (t=0:12.43, t=0:12.57) and the player's spin ring (t=0:13.77) are instantly legible in flat color. This is the pattern to build the entire combat vocabulary around — every attack in the game should eventually speak this dialect.
2. **The spin clear as a juice template.** At t=0:13.77 the AOE tile flash, screen tint, and kill-counter tick land on one frame — the only fully stacked feedback beat in the clip, and it works. Copy this stacking discipline to every hit.
3. **Possession-swap legibility.** White outline + HUD rewrite ("player 2"→"player 1", shout→spin) at t=0:05.00→0:05.23 sells the core fantasy with zero art. Don't touch it.
4. **Traversal and transitions.** Smooth tile-stepping (t=0:11.77→0:12.13, t=0:14.87→0:16.37) and hard-cut zone swaps with zero load hitch (t=0:16.37→0:16.40, t=0:00.00→0:05.00). The movement tuning is done; leave it alone.
5. **Progression pulses.** XP sliver growing mid-fight (t=0:11.03→0:11.77→0:12.13) and the kill counter tick (t=0:13.77) give per-kill reward feedback. The enemy hit flash (t=0:12.80) proves the flash pipeline exists — extend it.

## Top issues (ranked)
1. **Attacks are invisible.** No swing arc, lunge, or contact frame anywhere; the player's HP bar loses a chunk between t=0:05.23 and t=0:07.80 with no on-field cause (adjacent enemy at t=0:07.30 is the only candidate), and the ZONE 1 exchange at t=0:19.57–0:20.63 reads as adjacency-tick overlap, not a strike. **Fix:** a 2-frame lunge (offset the attacker's rect 4–8px toward the target, snap back) — pure code, no art, and it grounds every hit spatially.
2. **Deaths are despawns.** Enemies vanish between frames (t=0:11.37→0:11.77; cluster at t=0:13.13 absent by t=0:14.13); kill confirmation is currently only the XP bar. **Fix:** 3–5 frame white flash + a few scattering pixels at the death tile. Cheap, and it pairs with the already-working XP tick.
3. **Player damage has no on-field feedback.** Bars drain (t=0:07.80, t=0:08.37) while the field shows nothing — deaths in this build will feel unexplained. **Fix:** red character flash + 2px screen shake on player-hit. Meanwhile the red screen-edge flash currently fires on player *attack* (t=0:13.77), inverting universal convention — **reassign red vignette to damage-taken, give attacks a white/gold accent.**
4. **Enemy passivity + one-button trivial fights.** Enemies hold position for seconds (static t=0:05.23 vs t=0:07.30; player orbits one passive enemy t=0:08.37–0:10.53), then a single spin deletes the whole cluster (t=0:13.13→0:13.77) — no positioning pressure, no counterplay. **Fix candidates:** shorter enemy aggro/approach timers, and either a spin cooldown or reduced spin damage so multi-enemy clusters require two beats.
5. **Off-camera companion fights.** The party splits and a full combat beat — telegraph, hit flash, drops — happens at the clipped bottom edge while the possessed unit is idle (t=0:10.53, t=0:12.37–0:12.80). The player is blind to half the party's HP pressure, and the game looks like it plays itself. **Fix:** edge arrows + mini HP pips for off-screen companions; the possession design guarantees split fights, so this is a systemic need, not polish.
6. **Enemy/floor palette collision.** White/tan enemy squares sit in the same band as platform tiles and read as terrain (t=0:12.90, t=0:14.27). **Fix:** one-line palette change — push all hostiles to a saturated or dark band now, don't wait for the asset lane.
7. **Damage numbers near-invisible and possibly not firing in combat.** Tiny dark-purple digits visible in the hub (t=0:00.00) and at t=0:19.57, but none seen during the entire ZONE 2 fight (t=0:07.30–0:12.80) — unknown whether they fire there. **Fix:** larger, outlined, color-coded (white=dealt, red=taken), and verify they spawn in dungeon combat.
8. **Center-screen pickup toasts occlude combat.** "pink square +2" cards sit dead-center over active entities for 4+ seconds (t=0:16.40 through t=0:20.73). **Fix:** corner-anchored toast queue with ~1.5s TTL.
9. **Overloaded outline language.** Player = white outline, mark = orange outline (t=0:07.30, t=0:14.73), plus unexplained hollow purple/green/tan squares in ZONE 1 that take damage but never act (t=0:16.40, t=0:19.57 — role unknown). **Fix:** reserve outlines for control/selection only; move mark to an over-head icon or tile underlay; document/label the hollow squares' role.
10. **Telegraph duration unverified.** The 3x3 appears and is gone within one ~0.14s sampling gap (t=0:12.43 vs t=0:12.57) — if the real wind-up is under ~0.4s it's undodgeable at tile-step speed. Actual duration unknown; needs measurement, not a fix yet.

## Asset-era leverage (separate — ranked by multiplier)
1. **Attack wind-up + swing frames** (even 2-frame on the squares) — fixes the biggest readability hole (t=0:19.57 overlap-tick combat) before any real art exists.
2. **Enemy silhouette + palette pass** — every hostile is an identical white notched square (t=0:05.00–0:12.80) that camouflages against floors (t=0:12.90); even three distinct placeholder shapes creates threat assessment and tactics.
3. **Death burst VFX** (poof/shatter + score popup) — converts vanishing kills (t=0:13.13→0:14.13) into confirmation; makes the spin clear feel spectacular.
4. **Player-hit feedback bundle** (flash + vignette + small shake) — gives HUD drops (t=0:07.80) an on-field cause.
5. **Telegraph pulse/fill animation** — makes the red 3x3 (t=0:12.43) communicate time-remaining, not just area; also derisks issue #10.
6. **Damage number restyle** — outlined, color-coded, rise-and-fade (current digits nearly invisible, t=0:19.57).
7. **Off-screen party indicators** (edge arrows + HP pips) — structural, but asset-adjacent (t=0:10.53, t=0:12.37).
8. **Pickup identity** — the magenta drops read as "interesting" (t=0:11.37, t=0:12.70) but communicate nothing; a small icon set fixes both the drop and the toast content.

## What to re-check on the next clip (same script, verifiable)
1. **Attack lunge present?** At the exchanges corresponding to t=0:07.30–0:07.80 and t=0:19.57 — can you name the attacker from the field alone, no HUD?
2. **Death events readable?** The kills at t=0:11.37→0:11.77 and t=0:13.13→0:14.13 should show a flash/burst frame in the sampled interval.
3. **Red vignette semantics.** Player spin at t=0:13.77 should no longer fire red; the player-damage moment near t=0:07.80 should.
4. **Telegraph duration measured.** Count frames the 3x3 persists around t=0:12.43 against tile-step time — is it dodgeable?
5. **Damage numbers in ZONE 2 combat.** Confirm they fire during t=0:07.30–0:12.80, and are legible at a glance.
6. **Off-screen fight awareness.** At t=0:10.53/0:12.37, are edge indicators showing the companion fight and its HP pressure?
7. **Spin balance.** Does the cluster at t=0:13.13 still die to one input, or does the fight now take at least two beats with any enemy response in between?
8. **Toast behavior.** At t=0:16.40, is the pickup notice out of the play area and gone within ~1.5s?
9. **Dead-air window.** Does the t=0:08–0:11 stretch now contain pressure (enemy approach) instead of orbiting a passive square?
10. **Hollow ZONE 1 squares.** Can their role (t=0:16.40, t=0:19.57) now be inferred from behavior or labeling?
