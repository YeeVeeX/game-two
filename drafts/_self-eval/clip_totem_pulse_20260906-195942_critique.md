# Self-eval: clip_totem_pulse_20260906-195942

Focus: The green heal totem on bridge 3 (mid-screen from about t=0:35 to the end): the ring is meant to beat every 3 seconds as a WAVE that grows from the fixture to a four-tile reach and fades over 0.67 s. Judge from the timestamps whether it reads as a slow heartbeat with a visible edge or as flicker/noise; whether the green +N heal numerals on bodies read as caused by the beat; and whether the ring's reach reads as 'stand here to be healed'. Cite t= evidence for every claim.

# Clip critique: clip_totem_pulse_20260906-195942

## Verdict in three lines
**Appealing?** Structurally, yes — the totem's beat fires on-spec as a visible traveling edge (t=0:33.27→0:33.60), and the clip contains a complete risk/recovery micro-loop (t=0:28.20→0:48.00) with zero art support. **Entertaining?** Intermittently — the kite-and-turn at t=0:04.77→0:06.40 and the arrow-payoff enemy entry at t=0:09.97→0:10.83 are real moments, but ~15s of low-pressure traversal (t=0:09.97–0:24.57) and ~13s parked at the totem (t=0:34.60→0:48.00) mean dead air is roughly half the clip. **Fluid?** Movement yes (clean tile-stepping, t=0:13.80→0:16.70), feedback no — the heal payoff arrives orphaned from its cause (t=0:48.10) and player-side damage is HUD-only (t=0:12.10→0:12.47).

### Focus verdict: the heal totem
- **Heartbeat vs flicker: HEARTBEAT — passes.** A beat is caught at t=0:27.23, absent at t=0:28.20 / 0:29.27 / 0:31.23 / 0:32.63 (all outside a 0.67s window of beats at ~27.2s and ~30.2s), and caught again exactly two periods later mid-growth at t=0:33.27–0:33.60. The sampling is consistent with a clean 3s cadence, not noise. Growth reads as a wave, not a pop: the outline is at ~half reach then full reach across two frames 0.33s apart (t=0:33.27 vs t=0:33.60), and the edge is crisp — a bright green rectangle outline, clearly separable from the tan bridge and dark water, not particle mush.
- **Heal numerals caused by the beat: FAILS in the sampled frames.** The +15/+12 green numerals spawn over the companions with NO ring edge visible in the same frame (t=0:48.00 no numerals/no ring → t=0:48.10 numerals present, no ring anywhere). Either the numerals lag the ring past its 0.67s life or the ring draws too faintly at that moment — either way, the payoff frame is missing its cause. This is the top fix.
- **"Stand here to be healed": PARTIALLY reads.** At full expansion the rectangle spans open water on both sides of the bridge (t=0:33.60) — telling the player the heal zone includes tiles they can never stand on. Behaviorally, the player doesn't trust the edge: all three bodies hug within ~2 tiles of the fixture despite the claimed 4-tile reach (t=0:48.00). Between beats the totem is an inert green square with no idle signal (t=0:24.90, 0:31.63, 0:32.63), so a first-time crosser gets no advance hint it's a device at all.

## Scores (0–10)
- **Readability: 6** — Active-unit marking (t=0:04.43), objective handoff (t=0:15.43–0:16.27), and green-vs-red telegraph grammar (t=0:33.60) all work; but heal cause→effect is broken (t=0:48.10), player-side damage attribution is HUD-only (t=0:12.10→0:12.47), and hostile/ally silhouettes blur (t=0:04.93).
- **Feel-juice: 4** — Enemy hit-flash exists and pops (t=0:12.10, 0:28.20), the expanding totem edge is satisfying proto-juice (t=0:33.27→0:33.60); but the player takes 198→186 with zero shake/flash/knockback (t=0:05.83→0:06.03), kills resolve with no death burst (t=0:12.47), pickups are near-invisible (t=0:14.83), and heals are punchless numerals (t=0:48.10 vs the flashier damage at t=0:28.20).
- **Fluidity-pacing: 5** — Tile cadence is smooth with no snagging (t=0:04.77→0:05.20, t=0:13.80→0:16.70), and the totem sits flow-friendly on the transit choke (t=0:33.60, 0:48.00); but the skeleton fight is flat attrition (t=0:02.67→0:09.77, ~24 HP in 7s), segment two is nearly pure walking, and topping up costs ~13s of standing still (t=0:34.60→0:48.00).
- **Loop-engagement: 7** — Genuine visible decisions: kite-and-turn (t=0:04.77→0:06.40), navigate→fight→loot→re-target (t=0:10.83→0:24.57), and a complete fight→retreat→bank-heal beat (t=0:28.20→0:48.00). Docked for the follower who vanishes with no visible cause (3 on-screen at t=0:16.70, 2 at t=0:24.57, HUD still shows three) and idle followers contributing nothing readable (t=0:06.40–0:09.77).

## What already works (keep + amplify)
1. **Totem beat timing and edge crispness.** The 3s/0.67s spec is firing correctly and the hard outline survives the dark palette (t=0:27.23, t=0:33.27→0:33.60). Do not soften this edge when real art arrives — the pre-emptive worry in segment one (that a soft radial fade would vanish against the brown tiles at t=0:00.00) turned out to be exactly right to avoid.
2. **Shared telegraph grammar, hue-split.** Green friendly outline and red 3x3 hostile tiles coexist on one screen and both read instantly (t=0:33.60). This is a language — extend it, don't fragment it.
3. **Anticipation from geometry.** Edge arrows paying off with the skeleton entering exactly where the arrow pointed (t=0:09.97→0:10.83) and the clean objective handoff (minimap green box t=0:15.43 + in-world green square t=0:16.27) are working with zero final art.
4. **Active-unit marking and target-acquisition flash.** The chevron+ring survives cluster chaos (t=0:04.43, 0:07.30); the snap-on highlight frame (t=0:05.57, 0:07.53) is the closest thing to punch in the clip — reuse the pattern.
5. **Persistent field rewards.** Purple gem corpse-markers create legible pull (t=0:04.43→0:09.77, two visible at t=0:09.20).

## Top issues (ranked)
1. **Heal numerals are orphaned from the beat.** No ring visible in the frame where +15/+12 spawn (t=0:48.00→0:48.10). *Fix:* spawn the numeral on ring-contact, not on the heal tick's internal resolution — and/or hold the ring's leading edge at full reach for ~0.15s before fading so cause and payoff coexist in at least one frame.
2. **Player-side damage has no on-body feedback.** HP 174→162 with the only visible event being a white flash on the *enemy* (t=0:12.10→0:12.47); earlier, 198→186 with the scene static except a small popup (t=0:05.83→0:06.03). *Fix:* red flash + floating numeral + 2px knockback on whoever loses HP. Smallest change, biggest attribution win.
3. **A party member disappears with no readable cause.** Three on-screen at t=0:16.70, two at t=0:24.57, HUD unchanged. Death without feedback and off-screen straggling are indistinguishable. *Fix:* death burst / corpse-fade state for party units, plus an edge arrow for stragglers (you already have the arrow system).
4. **Wave reach paints unstandable water.** The rectangle spans both sides of the bridge (t=0:33.60), teaching a false footprint — and the player compensates by hugging the fixture (t=0:48.00). *Fix:* mask the wave to walkable tiles, and add a persistent faint floor decal marking true reach between beats.
5. **Enemy resolution doesn't read as a kill.** Skeleton flashes at t=0:12.10, is simply absent/displaced at t=0:12.47 — no burst, no corpse. *Fix:* 2–3 frame death pop.
6. **Totem is inert between beats.** No idle pulse across t=0:24.90–0:32.63 — a first-time player gets no "active device" signal for up to ~2.3s. *Fix:* 2-frame idle glow oscillation on the fixture.
7. **Heal fires at full HP.** 198/198 at t=0:48.00 yet numerals still spawn at t=0:48.10 (companion HP not individually legible at this size — unknown whether those are real heals). *Fix:* suppress +N on full-HP targets so green numerals always mean something.
8. **Low-intensity stretches.** 7s attrition fight with no arc (t=0:02.67→0:09.77); ~13s parked healing (t=0:34.60→0:48.00). *Fix candidates:* raise per-beat heal so 2–3 beats suffice, and give the skeleton a second attack pattern or the followers visible attacks (none observed t=0:06.40–0:09.77).

## Asset-era leverage (separate — ranked by multiplier)
1. **Hostile-vs-ally silhouette/palette split** (cold palette + outline on enemies) — at t=0:04.93 the skeleton is only findable by prior knowledge; also makes a missing follower instantly noticed in-world (t=0:24.57), not just on the HUD.
2. **Larger, outlined, color-coded damage/heal numerals** — the fading '33' at t=0:06.67 is near-illegible; numeral legibility is the load-bearing channel for the totem's +N attribution.
3. **Per-character heal flash/tint on ring contact** — the asset half of fix #1; makes healing feel as punchy as the enemy hit-flash at t=0:28.20 currently does for damage.
4. **Persistent walkable-tiles floor decal for the totem reach** — one asset fixes both the water over-read (t=0:33.60) and the conservative hugging (t=0:48.00).
5. **Directional swing frames / smeared arc VFX** replacing the flat white quad (t=0:02.67, 0:06.67) so hit tiles read spatially.
6. **Death burst + pickup pop** — kill resolution (t=0:12.47) and gem collection (t=0:14.83's near-invisible '+', COINS stuck at 0 through t=0:24.57) both need a beat of celebration.
7. **Totem idle-pulse frames** (t=0:31.63–0:32.63 inertness).

## What to re-check on the next clip (same script, verifiable)
1. **Ring+numeral co-frame:** at least one frame around the ~t=0:48 heal beat must show ring edge AND +N numerals simultaneously. That is the pass/fail for fix #1.
2. **Fade quality:** no partially-faded ring frame was ever sampled (nothing between t=0:33.87 and the next beat) — request denser sampling across one full beat (e.g., 10 frames over t=0:33.2–0:34.0) to confirm the 0.67s fade doesn't strobe.
3. **Wave footprint:** at full expansion (~t=0:33.60 equivalent), confirm the wave/decal no longer paints water tiles, and check whether the party positions at the reach *edge* rather than hugging the fixture (compare t=0:48.00 cluster).
4. **Player hurt feedback:** at the t=0:12.10–0:12.47 exchange, confirm a red flash/numeral on the unit that loses HP, and that the HP drop is attributable without reading the HUD.
5. **Follower accountability:** track the third party member across t=0:16.70→0:24.57 — either a visible death event or an edge arrow must explain the absence.
6. **Full-HP heals:** at t=0:48.00-equivalent, confirm no +N spawns on 198/198 targets (and get a readable view of companion HP so "overheal vs real heal" stops being unknown).
7. **Heal duration:** confirm the 150→198 recovery (t=0:34.60→0:48.00 baseline, ~13s) has shrunk if the per-beat value was raised.
8. **Companion combat contribution:** any visible follower attack quads during the t=0:02.67–0:09.77-equivalent fight window (none observed in this clip).
