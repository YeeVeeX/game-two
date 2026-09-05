# PREMIUM v22 — the day's evidence (Junior seat, 2026-09-05 11:30–19:05)

Direction (Junior, 11:30): "achei todos os personagens bem ruim ... modelo muito
mais premium ... mapa muito quadrado ... a inteligência dos inimigos e aliados
refinada ... não gosto desse quadro branco ... itens, inventário, equipamentos
... barras de vida nível e moedas mais premium". Full autonomy, minimal stops.

## What landed on `main` (all presentation unless noted; each piece gated
## = critic PASS + two replays byte-identical; suite green at every commit)

| # | Commit | Piece | Gate(s) |
|---|---|---|---|
| 1 | `03259d0` | drawn characters: 20 kits, 32x48, hue-shifted ramps, selective outline, ground shadow; humanoid rig + 7 monster rigs; depth sort; overlay lift | world_loop |
| 2 | `7189be7` | dual-grid material tiles (16 masks x 4 variants x 12 textures, neutral grey tinted by the zone palette; cliff/rim/shadow/foam baked; ground detail scatter) | world_loop |
| 3 | `58e6153` | possession = gold ground halo + chevron (partner cyan) | dash_strike_rip |
| 4 | `41e1d95` | HUD panel (portraits, framed bars, numerals, LEVEL ticks, COINS/POTION chips, status icons); drops = bobbing gems; facing notch OFF | world_loop, loot_loop |
| 5 | `595b3ab` | **SIM, ships OFF:** ally brain (focus fire, drink <30%, dodge the aimed telegraph, role by arc, specials) + coward husks — `threat.json ally.enabled/human.enabled=false` (canary law) | suite (ally_brain_test) |
| 6 | `385f429` | SYSTEMS proposal (items/bag/equipment/attributes/bank/vendors/drops/status; 7 tickets) — now v24 THE REWARD's spec input; S1–S3 in v22 = both-seats line (Junior's half YES) | — |
| 7 | `c6f5fcf` | FX: hit spark, death burst, footstep dust; hurt squash; sprite corpses; breathing portraits; taller cliffs | dash_strike_rip, tower2_run |
| 8 | `064bd80` | LIGHT: additive fire glows, vignette (hub-light), kill punch, level flash | brasa2_run, dash_strike_rip |
| 9 | `93cf9e6` | dodge = tuck-and-roll (i-frames without hurt), cool tint; atlases 18 cols | dash_strike_rip |
| 10 | `0af8c67` | idle 4 s cycle + glance; SPECIAL silhouettes (Fio lunge, Aro ring, Pomo fan, singer throat ring); monsters breathe harder; atlases 22 cols | lobber_volley |
| 11 | `d3a00c5` | combat legibility: floating numbers (hp-delta poll), wounded-enemy hp bars, boss bar with phase notches/pips | floor3_run |
| 12 | `195a01f` | RECEIPT J-v22 1–6 + L15 (Junior's word on the ONE BODY pivot etc.) | — |
| 13 | `546375b` | wall re-gate fixes: world ends in ROCK past the map edge; camera CENTERS worlds smaller than the view; menu_scene wired with art/tiles; hurt tint constant | basement_pocket, toll_pocket, menu_tour, tower2_run |

## The wall (42 scripts, worktree @ `064bd80`, 15:24–17:52) — `drafts/_wall-premium-v22-20260905.log`

- **Manifests:** 9 fails = exactly the T7 census (basement_pocket level_gate
  loot_loop nest_advance threat_pull toll_pocket vat_economy zone8_crossing
  zone_catchup) → **zero regression** in the event streams.
- **Vision first pass:** 6 fails / 42 (14%, in the observed flip band).
  Re-gate (same worktree): mercy_floor PASS, multi_floor_descent PASS = flips.
  **Four REAL findings**, all fixed in `546375b` and re-gated green:
  1. basement_pocket + toll_pocket `no_render_garbage`: pocket zones (512x448)
     in a 960x540 view — the void past the map read as a broken render once
     the tiles had texture → tileset draws rock to the view edge; and the
     camera pinned the small map under the HUD → camera centers it.
  2. menu_tour `possessed_readable`: the harness menu scene built the
     Renderer without art → quad ring. Wired like the world scene.
  3. tower2_run `hurt_flash_not_white`: the crimson tint blinked odd/even;
     on even frames a pale kit's raw hurt frame read WHITE → tint holds for
     the whole hurt window.
- Coverage note: the wall ran at `064bd80` (passes 1–4). Passes 5a/5b/6 and
  the fixes (`93cf9e6`..`546375b`) each carry their own 1–2 gates (table);
  the next full wall covers them.

## Not done / owed
- Ally brain ON = A3 gated piece in Gabriel's T2 (owner word owed).
- S1–S3 = Gabriel's half of the both-seats line (owed; program now puts the
  full SYSTEMS plan at v24 THE REWARD).
- Visual debts I see: ram (ember_a) facing down still flat; lurker silhouette
  weak; 32 px faces are suggested, not drawn; the boss bar has no name string
  per form yet (BOSS N only).
- Fresh-eyes review of the whole PREMIUM wave (Rule 6) = Gabriel's T0.

## Junior's verdict (2026-09-05 19:07–19:33, human seat, scratch save tmp/junior_play.json)

Session: 26 min in ZONE 7 (the city), 1 fight (292 kill-xp), 0 deaths, 0 potions,
no dungeon entered (quay entries=0, d2 entered=0). Pack at close: Fio 38, Aro 70,
Pomo 60. Asked "what was the session?" (numbered, his format), he answered **1:
"Fiquei olhando — o visual me prendeu."** (the visual held me). Reading: the
premium wave passed the only gate that matters; the city alone held 26 minutes.
He has not yet SEEN the dungeons as a player (tower / BRASA are the richest
surfaces: torches, lava, glows, cobras, braziers).

Ticket 1 for tomorrow (his pick): FINE POLISH — ram (ember_a) facing down,
lurker silhouette, 32 px faces; then open him INSIDE the tower / BRASA.

## Junior's second session (19:37–19:39, healed scratch save, level 15, 200 coins)

~2 min: 1 fight (70 xp), paid a 40 toll at a SECOND seal (200->160: he went
north-east to the basement stairs, not south to BRASA), Aro's taunt cast once
-> 19 retargets (the whole room came), **Pomo (lobber) died**; Fio 29, Aro 79.
No dungeon entered in either session. Asked in numbers, he answered **1:
"Perdi o Pomo cedo - a cidade tá mais dura do que parece."**

Reading (dev): the taunt pulls every hostile onto the pack and the ranged body
hugs the target and has no flask reflex -> the squishiest body dies first.
That is precisely what the ally brain (595b3ab, OFF) fixes: drink <30%, hold
3 tiles, dodge the aimed telegraph. Second reading still stands: twice given
TILE coordinates, twice no dungeon - the game must point the way (signage).

Ticket 1 tomorrow (his pick): (a) play session with the ally brain ON
LOCALLY (threat.json ally/human enabled=true, never committed - canary law;
his feel = half the A3 audit); (b) read the basement/city density + taunt
pull at level 15 and propose the tuning numbers (data only). Ticket 2:
SIGNAGE (edge arrow to the nearest exit/stairs, light pulse on holes/doors,
floor in the banner). Then the fine polish (ram / lurker / faces).

## Junior's third session (19:42-19:44, ally brain ON LOCALLY, threat.json reverted after)

Same start, same ~2 min. Brain OFF -> ON: fights 1 -> 5 · kill-xp 70 -> 1230 ·
zones city only -> city + ZONE 5 (39 s, 8 kills) · **BOSS 1 defeated** (0 -> 1)
· specials: Aro ring x2, Fio dash + Pomo volley 3 frames apart (the brain, not
him) · flasks 0 -> 3 used · deaths 1 -> 4 (2 wipes) · enemy lowhp retargets
4 -> 23. Asked in numbers, he answered **1: "Não notei diferença nos aliados."**

Dev reading (disagreeing with the conclusion, not the perception): the brain
ACTED (telemetry above) but nothing on screen SAYS an ally did it — no callout
when an ally drinks / rolls / fires its special; and 2 min with 2 wipes leaves
no attention for the bodies beside you. Finding = LEGIBILITY of ally acts, not
brain strength. His feel is still half the A3 audit: "did the companion earn
its price?" -> today: not yet visible.

Ticket 1 tomorrow: ALLY CALLOUTS (presentation): a small icon pop over the
ally on drink (flask), roll (chevron), special (kit glyph) + a 1-line quiet
banner ("POMO BEBEU" / "ARO: ANEL"); HUD row pulse. Ticket 2: thresholds as
data (drink 30% -> 45%, ring_min_adjacent 2 -> 1) so the acts happen EARLIER
and more often. Ticket 3: density / lowhp-retarget tuning at level 15 (23
retargets in 2 min hammers the wounded). Then a LONGER session (10 min+).

## Junior's fourth session (19:55-19:59, brain ON locally + ally CALLOUTS d626550 + thresholds drink .45 / ring_min 1; reverted after)

4 min (14398 frames), same start/route as session 3. Brain ON without callouts
(2 min) -> brain ON with callouts + earlier thresholds (4 min): fights 5 -> 11 ·
kill-xp 1230 -> 3440 · wipes 2 -> **0** · deaths 4 -> 1 (corpse recovered) ·
ZONE 5: 39 s / 8 kills -> 74 s / 27 kills / 0 deaths · BOSS 1 defeated again ·
Aro ring 2 -> **12 casts, 8 kills** · all three kits fired specials · flasks 3 ·
banked 200 -> **451 (3 deposits)** · close: Fio 147, Aro 294, Pomo 110 - all alive.

Dev reading: same brain, same route; the deltas are (a) the player SEES the
allies act (callouts + HUD pulse) and plays with them, (b) the brain acts
earlier (data). This is the A3 evidence pair the owner needs: brain OFF vs ON
under the same player, and ON-silent vs ON-announced. His word: below.

