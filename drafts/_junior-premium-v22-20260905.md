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

His word on session 4 (numbered): **1 — "Sim: vi o Pomo beber, o Aro fechar o anel; joguei junto."**
A3 audit closed on the Junior side: `drafts/_a3-ally-brain-audit-20260905.md` (player
evidence + canary stream diff + one named finding: the ranged-hold stalemate in
brasa2_run, 2 fix candidates). Owner's line owed.

## Build continues (20:25-21:31, Junior: "segue com a construção, já testei e está bom")

| pass | commit | piece | gate |
|---|---|---|---|
| 8 | `10f7dda` | EXIT SIGNAGE: open ways breathe (additive gold glow + core, phase per tile); off-camera open ways = gold arrowhead on the viewport edge (<=4, slides under HUD plate / minimap); gate row exit_signage_reads | world_loop |
| 9 | `d2f242a` | MINIMAP top-right (128x80, 2 px/tile, ~4x camera; zone image once per map; hostiles red, pack kit dots, YOU gold ringed; pips z21 above it); gate row minimap_reads | world_loop |
| 10 | `f70ff2d` | PICKUP gleam + "+N" gold number; LOW-HP edge pulse (<30%, breath, deeper as hp falls) | loot_loop, mercy_floor |
| 11 | `a18b40b` | INTERACT PROMPT (bone bubble: key cap + verb, on/beside a station) + COLOR TRUTH fix (below) | ledger_loop, world_loop |

**Color truth fix (from the gate, not from taste):** `kits_distinct` failed 4x on
ledger_loop with one complaint: "two orange-haired sprites; HUD fills share one
orange". Aro's KIT_BODY 190/80/35 was a second orange beside Fio's 235/120/40,
and his gold crest read as orange hair. Aro is now deep RUST 158/52/30 (renderer
KIT_BODY + controls overlay + atlas armor ramp - one truth, three places) with a
dark-iron helm and iron crest. The low-hp pulse collided with the wipe veil's red
(wipe_reads) -> WINE red, silent during nest_respawn. Both rows green after.
Floor-in-banner deliberately NOT shipped until L11 (Junior's receipt 3) lands.

## Wall #2 (42 scripts @ `5f5f992`, 21:33-00:04) - `drafts/_wall-premium-v22b-20260906.log`

- **Manifests:** 9 fails = the T7 census exactly -> zero regression in the event streams.
- **Vision first pass:** 6/42 (14%). Re-gate: brasa3_run, ledger_loop, taunt_anchor,
  zone_catchup PASS = flips. Two REAL findings + one debt:
  1. **floor2_run `floor2_channel_reads` x2** ("one rust rock family, no coral"): the
     dual-grid tileset gave `wall_inner` the SAME texture as `wall` (two tints of one
     rock) - the flat-rect era had two colors, the textured era needs two MATERIALS.
     Fix: `wall_inner` -> its own `coral` texture (worley bulbs, pores, ridge ring;
     reads coral in ZONE 3, pumice in BRASA, near-black rock in the tower).
     Re-gated floor2_run + tower2_run + brasa1_run.
  2. **brasa1_run `no_render_garbage`** (found while re-gating 1): hard rectangular
     seams in the low-hp wine vignette - the vignette was 4 OVERLAPPING full bands,
     alpha doubled at the corners (invisible at the dark alpha, loud in wine). Fix:
     a non-overlapping FRAME (4 bands + 8 corner triangles, alpha by distance to the
     nearest edge). Re-gated brasa1_run.
  3. **zone_catchup `no_render_garbage`** first pass ("ZONE 1 banner over ZONE 2's map"):
     passed on re-gate (the frame the critic picks varies), but the banner WAS stale -
     the v15 FIFO let an old zone banner play out over a new zone (5 crossings in 560
     frames); the minimap now contradicts it on screen. Fix: entering a zone PREEMPTS
     earlier ZONE banners (stamps keep their FIFO turn); test added.
  - **brasa2_run `pressure_ring_reads` x2 = named DEBT** (not a regression: the ring is
    an open-room grammar; BRASA's maze puts pressuring bodies in corridors; sim tuning
    = owner's call). Joins vat_economy / aoe_specials in the re-author class.

## BUILD phase (branch `junior/premium-build`, 2026-09-06 01:00-01:50) - Junior: "nunca vamos encerrar ... validação começa quando chegarmos ao fim das atualizações"

Mode change: build commits with the suite green; the critic wall runs ONCE at the end (below).
Owner s133: S1-S3 YES ("as you both consider best"; S1 after T1 on main). Built on the branch:

| ticket | commit | piece | tests |
|---|---|---|---|
| S1 | `be2bd31` | items catalog (16: 3 consumables, 4 weapons, 2 armor, 2 trinkets, 5 materials), strict loader, names x3 locales (functional, no fiction), 16 drawn 16x16 icons md5-pinned, App::ItemIcons; HUD flask = catalog icon | item_catalog_test (4) |
| S2 | `e896ac4` `d96c114` `a97097d` | Game::Bag (20 slots, stacks by catalog, smart sort, order-free digest); Game::Loot mixed into World (:loot RNG stream, own salt - combat/respawn draw counts untouched, canaries byte-identical); drops.json (17 kits); item drops per zone (accumulate/decay/digested); interact picks the item after the coin (bag_full named); floor icons; pickup gleam + name callout; HUD BAG chip; BAG SCREEN (I/B, UI toggle, read-only: grid 5x4, detail column, provisions shown as the flask) | bag_test (6), digest/save CLASSIFICATION |
| S3 | `5f44dc5` | status.json registry (poison/burn/stone/seized/chill; burn DOT numbers); Creature#ignite!/tick_burn/cure!/statuses; the aura IGNITES a burn; sustain off the bank uses a CURE from the bag first (antidote -> poison, ember_salve -> burn; item_used), flask fallback; burn tint + HUD icon + callout | status_test (4) |
| polish | `3892c1f` | ram head/mane/ridge, lurker ridge/bulges/waterline, faces gain a mouth (open on windup) | art_registry md5 |

Suite 1478/0 at every commit. world.rb 1798/1800 (Game::Loot extracted). The 3 canaries' OFF
streams = ACTIVE bank throughout (tools/a3_stream_diff.rb). Not built (owner sequenced to
v24 THE REWARD): S4 equipment/StatResolver, S5 attributes, S6 vendors/bank storage, S7 boss
tables. Bag persistence = one line on T1's player record when it lands.

## VALIDATION phase - wall #3 on the branch (worktree game-two-wall5 @ 3892c1f, 01:51 -> )

### Fresh-eyes review (child `delegate`, gpt-5.6-sol, 02:40) -> `drafts/_review-s1s3-freshEyes-20260906.md`
Verdict BLOCKED: 1 BLOCKER (bag classified persisted but never serialized), 5 MAJOR, 2 MINOR.
All 8 answered in the next commit: (1) bag = session_only, NAMED debt until T1's player
record; (2) poison/burn INTERVAL digested + pinned + classified; (3) aura contract = instant
tick AND DOT, asserted + documented as a named balance choice; (4) a FULL bag falls through to
the station (no soft-lock) + test; (5) ember_salve's unimplemented `resist` removed; (6)
status.json = sim numbers only, tints + bag layout in display.json, strict economy fetch; (7)
cure choice in canonical id order (pin-independent); (8) provisions = title chip, never a grid
cell. The BLOCKER's merge condition (T1 first) = the owner's sequencing already in force.


### Fresh-eyes reviews #2, #3, #4 (02:50-04:26) on the multi-agent FENCE
- #2 `delegate` on 5595c11 (lanes design) -> `drafts/_review-lanes-freshEyes-20260906.md`: BLOCKED (7 fence holes:
  self-modifiable brief, rename source unfenced, no branch/token check, BOARD handoff, fail-open CLI, test gaps,
  ad-hoc YAML) + A4/A6 -> all answered in a13e5bf (brief + BOARD read from the trusted ref, both rename sides,
  branch check, SIM TOKEN, rc 2 fail-closed, real YAML, receipts per lane).
- #3 `delegate` on a13e5bf -> `drafts/_review-fence2-freshEyes-20260906.md`: WITH MINORS (policy? not canonical,
  --files skipped the branch check, permissive schema, presentation fallbacks) -> answered in b40ab7f (lane_guard v3:
  canonical paths + MALFORMED, policy by glob intersection, branch check in every mode, `SIM LANE:` machine row,
  strict lists, strict display rows).
- #4 `lane-reviewer` (custom agent, **fable-5.1-thinking**, Junior's model order 04:00) on b40ab7f ->
  `drafts/_review-fence3-laneReviewer-20260906.md`: WITH MINORS, 20 adversarial probes all refused; 3 minors
  (receipts dir ownable, SIM LANE regex crossed newlines, case-insensitive FS) + 2 notes -> answered in 3a0ef57.
  Suite 1488 runs / 0 failures; canaries OFF = ACTIVE x3.

### Wall #3 closed (04:28) + re-gate (04:29-05:02, main clone @ 3a0ef57) -> `drafts/_wall-premium-build-20260906.log`
42 scripts: 5 vision fails, 9 manifest fails (= the T7 census, unchanged). Re-gate: basement_pocket, dash_strike_rip,
ledger_loop, sustain_run PASS; brasa2_run exit_signage_reads PASS, pressure_ring_reads FAIL (named debt since wall #2).
Classification: 2 real fixed (pack spark crimson + minimap per-map scale; exit arrows slide along the edge),
2 flips, 1 row reworded to the owner's v16 design (`wipe_reads`: veil + recap, no headline - the row demanded
"large text" the owner removed), 1 named debt. The branch is VALIDATED at 3a0ef57; landing waits on T1 (S1) and the
TWENTIETH verdict (S2+S3) per the owner's sequencing.

### Multi-agent PROOF lane `a3-stalemate` (10:45-11:24) - the team works as designed
Integrator (this seat) wrote the brief + BOARD grant (`8034192`), cut worktree `../game-two-lane-a3` on
`lane/a3-stalemate`, launched `lane-worker` (**fable-5.1-thinking**, custom agent WITH the `subagent` tool). The lane:
spawned a `scout` (default gpt-5.6-sol) to map the module, traced brasa2 headless, **contacted the supervisor** with
a corrected reading of audit §4 (the lobber has NO target; the embers ping-pong on the row-6 wall; the brain-OFF
canary only hides the same pocket) - integrator answered SCOPE CONFIRMED + 5 guardrails via `steer` without
pausing it - built the rule (candidate (a), brain-ON only, `ally.stalemate_frames`/`stalemate_advance_tiles` as
PROPOSALS), spawned a `reviewer` (fable) on its own diff (PASS WITH MINORS -> 1 MAJOR freeze-at-floor + 1 MINOR stale
stall count fixed in `97ce289`), ran `lane_guard` before each of 3 commits (rc 0 x3), pushed, wrote the receipt.
Integrator validation in the lane's worktree: fence `--base 8034192` rc 0 (4 paths = owns), suite **1510 runs / 0
failures**, canaries OFF = ACTIVE x3 with ON md5s identical to audit §3 (the rule never fires in the canaries),
`world.rb` 1798 untouched, no clock/rand, OFF path provably unreachable (`ally_config` returns nil when
`enabled: false`; `@stall` only allocated behind it). Receipt folded into BOARD; `SIM LANE` back to NONE; audit §4
corrected in place; candidates (c)/(d) named for the owner. Landing on `main`: owner's word only (A3 is OFF).

### Owner's word read (s135/s136) and answered (11:30-11:50)
- Gabriel's 11 new gate rows judging the PREMIUM surfaces (86 -> 97; s135 pt-br note: "a tua palavra e lei"):
  spot-checked against the code they describe (`big` numeral = `max_hp * 0.25` = "about a quarter"; `aura_rgb`
  ember-orange hollow square; `blink_flash_rgb` violet snap-shut; pickup = sparks rising from the collecting body,
  no flash ring / falling chips). **All 11 describe my intent correctly - kept verbatim.** Named debts he handed
  me: blink fires in NO reel today (authoring), `floor3_run` shows BOSS 1 for 892 frames with no capture in
  733-1646 (add one capture AFTER his E1 sweep closes, or the pins misalign).
- T1 CLAIMED by Gabriel (`a41ca0c`, branch `t1-schema3`, local). Spec §T1 already reserves `bag []` /
  `equipment {}` / `attributes {}` / `bank_items []` in the per-PLAYER record. Built the canonical persisted form
  now so the landing is mechanical: `Game::Bag#to_save` / `Game::Bag.from_save` (canonical, order-free, strict;
  2 tests) + `drafts/_s1s3-landing-plan-20260906.md` = the 3-line PATCH REQUEST for T1 + the per-player vs
  per-pack fact (host character's record carries the pack bag in v22; per-character split = v23 grill item).

### Owner debt closed: "blink fires in NO reel" -> `harness/scripts/blink_arrival.json` (12:00-12:10)
Why no reel had it: the two blink kits (`serpent_c`, `serpent_boss`) live in DUNGEON 3/4 and `tower3_run` spawns the
pack at [27,44] while the serpents sit at y<=27 (aggro 9): in 1600 frames they never meet. Authoring: pack at Chebyshev
10 from `serpent_c28` @[34,23] (not acquired), one `right` step at tick 30 -> distance 9 -> acquire + BLINK to the flank
(headless probe `tools/blink_probe.rb`: f31 serpent [34,23] -> [24,23], flash 10..1 on f31..f40). Capture law learned
(replay_runner saves capture N right AFTER tick N): the reel's adjacent pair is 0029 (serpent at range, no outline) /
0030 (serpent 10 tiles displaced, violet outline widest); 0032/0035/0038 snapping shut; 0040 gone. Gate x2 (captures
[0,24,30,31,...] then the corrected [0,24,29,30,32,35,38,40,70]): `blink_flash_reads` **PASS** both times ("Violet
outline snaps shut on the arriving serpent across 0030 and 0032; no unmarked long jumps"), vision PASS, 9 captures
byte-identical x2 each run; manifest floors zone_entered 1 / human_retargeted 4 / telegraph 2 / attack_hit 1 vs observed
4/18/6/6. `blinked` stays OUT of the curated EventLog (canary md5 law) - the reel proves the blink by captures.
Pin recorded (`harness/pins.rb record`, tag build-junior @ 5a14a63). Remaining owner debt from s135: the `floor3_run`
BOSS 1 capture in 733-1646 - AFTER his E1 sweep closes (pins alignment).

### v22 ticket E4 DONE (12:15-12:35) - `drafts/_v22-e4-record-20260906.md`
The six MUNDO VIVO zones enter the identity contract (they were ABSENT: no test read them). Decision = the spec's
second path, a RECORDED LAW AMENDMENT: the v20 "wall LIGHTER than floor, luma spread >= 40" was a value-only,
one-orientation encoding of the real goal (legibility in the flat fallback). Amended: legible by VALUE (|spread| >= 40,
orientation-free) OR by CHROMA (RGB distance >= 40 AND |spread| >= 20); orientation NAMED per zone and asserted by sign
(TOWER = light floor / dark red wall, inverted on purpose; pilot + BRASA = dark floor); motif law orientation-free.
No pixel changed (art = law; every tower/brasa pin stays valid). Honesty row: BRASA passes the chroma channel by
1.4-12 (lava + fire glows carry it in play); the lever, if the owner wants a stronger fallback, is the sidecar +
importer, then re-gate brasa1..3. 8 identity rows x 17 zones = 374 assertions green.

### v22 ticket E5 (partial, Junior's files) - no-lore renames, docs-only (12:40)
Spec §5 E5 names `gen_premium_art.py:46` and `premium_art/humanoid.py` comments as "Junior's files - asked, never
rewritten by the other seat". Done on the dev seat: 6 comment/docstring lines, lore names -> functional kit names
(`Fio`->striker, `Aro`->blocker, `Pomo`->lobber). Proof it is docs-only: `python tools/gen_premium_art.py` re-run
in place after the edit leaves `data/art/` UNTOUCHED (`git status --short data/art` empty; pack atlas md5s
5f45ef79f80f / ca3e324da09d / b7b0269d2e15 before and after) - no regenerated art, no re-gate owed.
`harness/vision_critic.py` "Threketh" is already gone (Gabriel's E1 persona rewrite). Left for later, by
collision/ownership: `renderer.rb:1479` comment (lane E3 owns renderer.rb right now); `face_varekka!` test helper
(test/game/challenger_test.rb + dread_test.rb: test-only names, either seat, one commit); rows "MEDUSA TOWER / BRASA /
MUSGO" + script names `brasa*_run` / `tower*_run` = the OWNER's line (theme words vs fiction) - not touched.

### E5, second slice - test helpers (12:50)
`face_varekka!` -> `face_challenger!`, helper `varekka` -> `challenger` in `test/game/challenger_test.rb` +
`dread_test.rb`; message in `zone_tier_test.rb` -> "BOSS 1 (challenger)". Test-only names. Deliberately NOT touched
(spec §5: owner line owed on the frozen oracle wording): the `TELEMETRY varekka` line and everything that reads it
(`telemetry.rb`, `telemetry_test.rb`, `v15_telemetry_test.rb`, `dread_test.rb` test name, `manifest_check_test.rb`);
the retired `varekka_duel` canary bank + history (`sim_identity_canary_test.rb`); "Kethral" = the predecessor
PROJECT's name (history, not fiction). 33 runs green in the three files. E5 remaining after this: `renderer.rb:1549`
comment (lane E3 owns the file) + the owner's line on `varekka` / MEDUSA-BRASA-MUSGO / script names.

### Owner debt (s135) measured, fix READY-NOT-APPLIED: `floor3_run` BOSS 1 capture (12:55) - `tools/boss_probe.rb`
Headless probe: BOSS 1 alive 1646 frames, ON CAMERA f764..f1646 (883 frames), `challenger_engaged` f152,
`challenger_chant_started` f1462 -> CHANT on camera f1463..f1577 at 7 -> 6 tiles, `chant_interrupted` f1577, boss
wounded (hp 91) from ~f1600, dead f1646. Today's captures [40..273, 2270, 4541, 6811] miss the whole window - that is
why `challenger_tell_reads` never truly passed. The fix is ONE line in `harness/scripts/floor3_run.json` captures:
add **1499** (mid-chant, 7 tiles; capture N = state after tick N) and optionally **1599** (post-interrupt, wounded,
4 tiles). NOT applied: Gabriel's E1 re-pin sweep is running on `main` @ 5bca200 over floor3_run; changing its captures
now would misalign the pin he is about to record (his own instruction). Apply + re-gate + re-pin right after he closes
the sweep (one commit, one gate). `tools/boss_probe.rb <script> <kit>` is general (any boss kit, any script).

### Wall #4 prep: headless MANIFEST CENSUS of the branch head (13:00) - `tools/manifest_census.rb`
The manifest half of a wall verdict is pure sim: replay each world script headless (same seed / apply_start /
expand_script / EventLog list), count `EVENT` lines x2 (the gate's double replay), judge the script's floors. 42 world
scripts in **62 s**, byte-equal to the gate log where I have a reference (`blink_arrival` 4/18/6/6). Result on
`junior/premium-build` @ 83a306a (= main E1.4 + S1-S3 + E3-in-flight excluded): **40/42 PASS**. The T7 census of nine
reds (basement_pocket level_gate loot_loop nest_advance threat_pull toll_pocket vat_economy zone8_crossing zone_catchup)
is now TWO after Gabriel's E1.4 re-cut - neither a regression of mine (E1.4 did not touch them; both red at 3892c1f):
- `toll_pocket` FAIL: `seal_breached=0(<1) actor_died=0(<8) drop_spawned=0(<6) drop_picked_up=0(<1)`. Probe: pack
  (level 5, banked 60) sits at [3,5]..[4,6] in basement_2 for 1400 frames, hp 198 -> 99, 7 hostiles alive start to end,
  20 `attack` holds land on nothing. The script no longer stages the fight it promises -> RE-AUTHOR (E-ticket list).
- `basement_pocket` FAIL: `drop_picked_up=0(<1)` (4 deaths, 6 drops spawn, the pack never steps on one) -> one
  `hold` toward a drop tile, or the floor re-cut to observed. Same list.
Use before every wall: `ruby tools/manifest_census.rb` (report, exit 0; vision rows are the wall's).

### E-ticket (one per session): `basement_pocket` RE-AUTHORED - census 2 reds -> 1 (13:10)
Why it was red: the fight ends late (husks die f767/f872/f888, drops at [9,4]/[10,5]/[9,5]), the possessed blocker
stands at [10,6], and the three `interact` presses (620/720/760) fired BEFORE any drop existed -> `drop_picked_up=0`
forever. Re-author (same fight, same first 900 frames): `up` 900-918 steps onto [10,5], `interact` 922 picks the drop
up (`World#interact` on the drop's own tile), `run_until` 960, captures 923/945. Headless census: PASS
(`zone_entered=4 actor_died=6 drop_spawned=6 drop_picked_up=2`). Gate with window: vision PASS (`drops_read_as_pickups`,
`pickup_gleam_reads` both read frame 0923: gem + facet highlight; the blocker's "+1" numeral rises in the capture I
looked at), **8 captures byte-identical x2**, manifest PASS on the double replay. Pin recorded (build-junior @ 282041c).
Remaining red: `toll_pocket` (the whole fight fails to stage; bigger re-author, next session's E-ticket).

### `toll_pocket` DIAGNOSED (measure only; re-author = next session's E-ticket) (13:45)
basement_2 (12x8): pack spawns [3,5]/[4,5]/[5,5] with husk0 ADJACENT at [2,6] (d=1) + 4 husks (aggro 12 = whole map).
1400 frames: ZERO telegraph / attack_hit / hostile movement (`hostiles_moved=0` start to end); the pack fires 16
`attack_started` that hit nothing (possessed at [3,5]/[4,4]/[4,6], never facing [2,6]). The "damage" seen earlier
(198 -> 74 -> 99) was the two possession swaps (480/580: lobber max 74, striker max 99), not hits. Whole bus in 1400 f:
attack_started x16, zone_entered x2, possession_changed x2. Reading: authored on the pre-LDtk basement_2; today the husks
behave like scoped guards (cf. guard_scope_test) whose scope the pack never enters, and the holds face the wrong way.
Fix = step into the scope (or face husk0) + redo holds; `manifest_census toll_pocket` confirms in 1 s, gate in 5 min.
Red since wall #2 (pre-S1-S3); E1.4 did not reach it. Recorded for the owner/next seat in
`drafts/_junior-note-to-gabriel-20260906.md` §7. Lesson banked: the watchdog's 240 s bash threshold fires on every
lane that runs `bundle exec rake` (3-4 min) - a false positive, not a hang (3 ruby processes = bundle > rake > loader).

### v22 ticket E3 INTEGRATED (10:00-10:10) - lane e3-presentation -> d557f67
Lane (fable + scout + reviewer) delivered 4/4 in the ordered sequence (b5 -> F-A3-1 -> b3 -> b4) + one REAL P1 its own
reviewer caught (a bare `Renderer.new` handed `nil` display to ControlsOverlay -> NoMethodError on draw; fixed f880c7c with a
failing-then-passing test). Integrator validation in the lane's worktree BEFORE reading its report: fence `--base 13a223c`
rc 0 (16 paths = owns), suite 1519/0, canaries YES x3, no clock/rand. Rebased 6 commits onto 2620cb8, ff, then the
integrator-only patches: d12 `minimap_reads` (gold = OPEN, cold grey = LOCKED - the old row said "gold dots for open
ways/stations AND a magenta dot for stations"), `interact_prompt_reads` clause (rope prompts; beside/totem never),
`renderer.rb:1580` comment (E5, last item on my side). Head d557f67: suite 1520/0, canaries YES x3, census 41/42.
Rule 2 smoke with the window: `town_gates` PASS ("gold and grey way dots"), `ledger_loop` PASS ("H INTERACT bubble at the
bank") - 6+6 captures byte-identical x2; pins recorded. The full re-gate of the 19+7+6 scripts the lane listed = wall #4
(next). Debt named: renderer.rb 2099 -> 2124 (+25, b3 extraction; no formal cap).

### Wall #4 prep II: `tools/wall_triage.rb` (10:26) - the flip-vs-real call leaves one seat's memory
Reads a live or banked wall log + the HISTORY of banked `drafts/_wall-*.log`; per failing vision row: NEW (re-gate first),
FLIP-PRONE (failed an earlier sweep, PASSED its re-gate), DEBT (failed an earlier RE-GATE too), REPEAT; plus the per-row
noise signature across scripts. Validated on wall #3 as "current" with #1/#2 as history: brasa2 `pressure_ring_reads` and
`wipe_reads` come out as history-bearing, the basement rows as NEW - matching what I classified by hand that night.
Live on wall #4 (4/42): `aim_hold specials_distinct` = NEW, row flipped 1x in history -> re-gate first. Noise signature so
far: `kits_distinct` (3 flips), `wipe_reads` (3), then singletons. Never runs a replay; prints the `tmp/_regate.sh` line.

### Wall #4 live triage (10:34): `boss1_writ impact_fx_reads` = two rows pulling one pixel apart (root cause found)
Hypothesis "captures miss the hit" REFUTED by the headless probe: captures 0210/0211 sit 2-3 frames after `spore_b17 ->
blocker` (spark life ~14 frames, peak until age 4). The 4x crop of the wall's own captures shows the star IS drawn - as a
CRIMSON cross on a crimson-tinted (hurt) body beside red telegraph tiles: red on red, present in the buffer, unreadable.
Cause = my wall #3 fix `fx_spark_pack_rgb` -> crimson, made so `hurt_flash_not_white` (judges the BODY tint) would stop
reading the pale spark as a "white flash": I fixed the symptom on the wrong pixel. Gabriel's E1.8 row `impact_fx_reads`
("small BRIGHT 4-point star") was written on the pre-crimson fx.rb and lands in the same rebase -> the two rows collide.
Fix in two parts: (1) NOW `hurt_flash_not_white` says the impact star is a SEPARATE element that may be bright/pale, judge
the body only (gate_checks.json, mine, no lane owns it); (2) at signage-lane integration (display.json is its `owns` until
then) the pack spark goes back to bright - warm-white core [255,235,200] + amber arms [255,180,80] (distinct from the
hostile star's near-white core, never pure white), then Rule 2 gates on basement_pocket (row 1) + boss1_writ (row 2).
`boss2_phases possessed_readable` = 3rd wall fail, NEW - likely the possessed seized/dead in the boss beats; re-gate at close.

### Wall #4 live triage (10:40): `boss2_phases possessed_readable` = two presentation truths, both mine (root causes found)
Sim facts (headless): the possessed blocker is alive, never seized, at [28,13] with all three pack bodies alive in all 8
captures -> the halo + chevron MUST be drawn. 4x crops of the wall's own captures 0094/0256/0282: (1) the gold ground
ellipse IS drawn but barely reads on DUNGEON 4's LIGHT stone floor ([94,94,97]; the halo's soft fill alpha 92 + pale-gold
rim were tuned on the pilot's dark floors, nest [28,24,22]) - the TOWER's inverted palette (E4) was never in the halo's
design brief; (2) the gold chevron above the head sits INSIDE a pink diamond = a DROP GEM lying on the tile behind the
possessed's head ([28,12]): two diamond-shaped markers on one spot, "pink gem above heads confuses the marker". Both are
my surfaces (pass 3 halo/chevron, S2 drop gems). Fix (presentation-only, renderer.rb + display.json, both owned by lane
signage until it folds -> at integration): dark CONTOUR outside the halo's gold rim (reads on dark AND light floors) and a
dark 1px outline/backing on the chevron (a MARKER, not a gem); knobs `possess_halo_contour_rgb/alpha`,
`possess_chevron_outline_rgb`. Gates after: boss2_phases (row) + world_loop (pilot dark floor, no regression). The row
`possessed_readable` is right as written. Named: the TOWER floor may expose more dark-floor-tuned overlays (aura square,
telegraph edges) - wall #4 is the census.

### Landing review (lane-reviewer, fable, 10:21-10:38) -> `drafts/_review-landing-freshEyes-20260906.md`: WITH MINORS, 2 MAJORs, answered (10:45)
Both MAJORs were mine and both were RIGHT:
- **MAJOR 1 - the E4 "chroma" clause measured the wrong thing.** Euclidean RGB distance carries the grey axis: the
  reviewer's counterexample wall [124,124,124] / floor [100,100,100] (spread 24, ZERO hue) passed as "legible by
  chroma", and BRASA's 41-52 was value relabelled - its ORTHOGONAL chroma is 15-18 (TOWER: 83-100, genuinely hue-carried).
  Fixed: `chroma_dist` = component of wall-floor perpendicular to grey; the law now has THREE NAMED clauses - value
  |spread| >= 40 · chroma >= 40 with |spread| >= 20 · **low-key** (20 <= |spread| < 40 AND floor luma <= 30 AND a carrier
  key `lava_deco`) - BRASA passes by the low-key clause with its carrier named in code; the same palette WITHOUT
  `lava_deco` is refused (tested); the counterexample is a unit test; a new `data/zones/*.json` must be in ZONES or in
  UNCONTRACTED_ZONES (today: gate_fixture, grass_fixture, wall_fixture) or the suite fails. Record got a CORRECTION
  section with the honest table. Lesson: "40/40/20 = the v20 budget reused" was units-blind - luma vs RGB distance.
- **MAJOR 2 - `Bag.from_save` refused the record on value drift**, against the P3 churn law in save_state.rb ("a retune
  must never brick a save": level/xp/hp/provisions CLAMP with a warn). Lowering `bag_slots` or retiring an item would
  have bricked every save with a full bag. Fixed: SHAPE errors (not an Array, bad entry types) raise -> the validator
  refuses; VALUE drift (unknown id, overflow, qty <= 0, duplicate id) CLAMPS with a printed `save: ...` line via an
  `on_drop` callback (default warn; tests collect). Plan updated (§NEW + PATCH REQUEST 2), `@pinned` = display state, not saved.
MINORs answered now (mine, no lane owns the files): blink_arrival floors = ONE run's observed counts 2/9/3/3 (the checker
reads the double log, so 2x) + `_doc` cites `tools/blink_probe.rb`; `manifest_census` prints NOT JUDGED loudly for a
manifest outside the world scenario (menu_tour) instead of a silent SKIP; README/BOARD carry an EN header (machine rows,
paths and the executable law are English; prose pt-br for the running seat). Deferred to the signage-lane integration
(its files): `interact_verb` nil for an already-breached seal + "iff a DISPATCH exists" comment; minimap literal
fallbacks -> `minimap_*_rgb` knobs. basement_pocket floors (4/4/4/1 vs single-run 3/3/3/1) are Gabriel's E1.4 numbers
- not mine to move. Answer 8 (T1 collision forecast) banked for the landing: world.rb attr block + interact hunks,
save_state_test CLASSIFICATION rows, state_digest_test FACT_KEYS; world.rb 1798/1800 -> if T1's apply! bridge needs
lines, I extract `interact*` to `src/game/interact.rb` (byte-inert, canaries prove) on his word.

### Wall #4 live triage (11:05): `brasa3_run aura_ring_reads` = my drawing, not the map; fixed headless, gate owed
Facts: ember_3 has 20 `ember_b` aura bearers among 39 hostiles (radius_tiles 2 = a 5x5 square each); 6-10 on camera per
capture, up to 7 overlapping pairs at 0501. The density is the BRASA design and stays. The DRAWING failed the row's own
words: a 2px orange line at alpha 150->45 with NOTHING inside - "the ground inside that square must read as dangerous"
was never drawn, and thin orange on the red-brown floor beside the fire glows reads as wireframes ("debug boxes").
Re-cut (presentation only, geometry untouched, every number a display row; `draw_aura` moved to Signage - renderer.rb
1990 -> 1973): translucent warm FILL that breathes with the outline (`aura_fill_alpha_max` 26 - never "fills in"; pinned
< 64 by test), 1px dark CONTOUR outside the line (overlaps read as burning ground, not wire), line 3px, and alpha FALLOFF
by distance to the possessed (`Signage.aura_alpha_pct`: 1.0 to 5 tiles, linear to 0.5 at 12+; the squares that bite next
read first, the far ones stay visible). Pure falloff pinned in signage_test. Rule 2 gates owed: brasa3_run (row) +
brasa1_run/brasa2_run/aoe_specials (aura reels) - in the post-wall window, same batch as halo/spark/ring.

### Wall #4 live triage (11:12): `dash_strike_rip whirlwind_reads` + `specials_distinct` = ROWS describing a ring the kit does not have
Sim fact: the striker's special is a linear DASH (`combat.json` arc "dash", max_tiles 3, windup 6, active 1): at capture
0396 (windup) a pale telegraph LINE runs ahead; at 0402 (active) the body has moved [6,68] -> [9,68]; `attack_hit` x2 at
f398 = the dash landed on two bodies. The critic saw exactly that ("two pale tiles to one side only, no ring") and failed
the rows because BOTH asked for a RING: Gabriel's new `whirlwind_reads` ("bright ring tiles around the striker") and my
wall-#3 `specials_distinct` ("Striker as a bright ring burst"). Source of the misread found: a v13 comment in
`renderer.rb` draw_attack ("the striker's ring burst ... the whirlwind renders...") - the special was a ring in v13 and is a
dash now; the comment was never updated and two rows were written on it. Fixed (my surface, my word): both rows describe
LINE + DISPLACEMENT (short line where a wall/body stops it is correct; never expect a ring; row id `whirlwind_reads` kept as
legacy, explained in the text); the renderer comment now says which era is which. No pixel changed; re-gate dash_strike_rip
in the post-wall window (its third row, impact_fx_reads, = the bright-spark fix already on the branch).

### Wall #4 live triage (11:16): `aim_hold specials_distinct` = critic MISREAD of the pack's ordinary windup; row disambiguated
Sim fact: at capture 0235 the blocker is in WINDUP of an ORDINARY attack (`current_action :attack`, no arc);
`special_started` never fires in aim_hold. Pixel: the "three flat dim grey slabs north of him" are the pack's ordinary
windup tiles (`WINDUP` = white alpha 90 over the dark nest floor reads grey) - correct, functional, and NOT a special. The
critic assumed "Blocker cast" and failed the row for the missing ring; by the row's own text it was "not exercised". A
repeatable misread is an ambiguous row: `specials_distinct` now says how a special is recognised (warm amber windup /
pale-gold active family + the HUD special pip spending) and that an ordinary windup (flat pale translucent reach tiles,
no ring, no pip) must not be judged as one. No pixel changed. Observation, not a failure: the pack's ordinary windup is a
flat slab; an outlined reach marker could read better - a later presentation pass, not this wall. With this, all 9
failing rows of wall #4 so far have a named cause: 4 drawings fixed on the branch, 4 rows corrected, 1 flip-prone.

### Wall #4 live triage (11:22): `district_hunt low_hp_pulse_reads` = the pulse is DRAWN and does not READ (formula floor)
Sim fact: 54/198 = 0.27 < low_hp_pct 0.30 in captures 2400 and 3219 - the condition holds, the vignette IS drawn.
Formula: depth = 1 - hp/(max*pct) = 0.09 just under the threshold; alpha = 150 x (0.45 + 0.55*0.09) x (0.6..1.0) =
42..71 - a wine tint that thin sits UNDER the base vignette (130) on the district's warm floor. Pixel: edge/corner
samples 1900 (no pulse) vs 2400 (pulse) differ by dR 0..11 = scene noise. Gabriel's row ("a dark RED vignette breathes
... deepens as hp falls") and pass 10's intent ("the frame bleeds") both want the pulse LEGIBLE at onset, then deeper.
Fix (light.rb, mine; two display rows, no magic numbers): `low_hp_alpha_floor` 0.75 and `low_hp_breath_floor` 0.85 ->
onset alpha ~96-113 (was 42-71), full depth 128-150; depth still carries "how badly", breath still pulses. Gate owed:
district_hunt (row) + world_loop (base vignette / no false pulse at full hp). With this, every failing row of wall #4
so far (10 across 6 scripts) has a named cause and a fix or a corrected row on the branch.

### Wall #4 live triage (11:26): `floor1_run telegraph_reads` = critic MISREAD (no hostile telegraph exists in the reel); row disambiguated
Sim fact: 0 hostiles in windup at every one of the 10 captures and 0 `telegraph` bus events in 1570 frames - floor1_run
never shows a hostile telegraph. The "faint pale-yellow square on tan bridge planks with no red edge" at 0700 is a ground
square that the headless probe could NOT pin to a way tile, a station or the pack's windup (none on camera; possessed idle) -
the remaining candidates are a coin/gem drop or a light-valued ground glyph (mark / pip); either way it has no red edge and no
hostile body inside it, so it is not a telegraph; by the row's own text the verdict was "not exercised". Same family as aim_hold: a pale square read as an attack
cue. The row now states the invariant the code has always had (renderer.rb draw_creature: the swell is drawn AROUND THE
HOSTILE BODY, red edge + yellow core, body visible inside) and that a ground square without a red edge and without a body
is not a telegraph. No pixel changed. Score: all 11 failing rows of wall #4 so far (7 scripts) have a named cause - 5
drawings fixed on the branch, 5 rows corrected (all rows written on the quad era or on stale comments), 1 flip-prone.

### PAUSE 11:45 — wall #4 at 19/42 (closes ~13:40, detached); state note `drafts/_junior-checkpoint-20260906-pause.md`
New at 19/42: `ledger_loop` fails `impact_fx_reads` (= the bright-spark fix already on the branch) and `low_hp_pulse_reads`
with a DIFFERENT phrase than district_hunt's: "At 25/169 the red wash tints the whole frame including HUD" -> this is
geometry/z-order, not alpha (the row: edges only, never HUD plate / bottom strip / centre). OPEN: measure `Light#draw_vignette`
band geometry + draw order before trusting `da473aa` (a higher floor could make a whole-frame wash worse), then gate
ledger_loop + district_hunt + world_loop. Everything else pushed; pins/verdicts written by the running wall stay
uncommitted on purpose until the close commit. Close = 3 steps in the pause note; `tmp/_gates_build4.sh` mirrored there.

### Resume 11:50 — the OPEN cause closed: `ledger_loop low_hp_pulse_reads` was GEOMETRY + Z-ORDER (both mine)
Measured: `Light#draw_vignette` uses FIXED bands of 22% (w) / 28% (h) per side with a gradient to clear - the frame
screen_light_reads approves for the neutral base vignette (alpha 130), but the WINE PULSE reused the same geometry, so it
tinted ~75% of the frame; with da473aa's higher alpha floor that is exactly the "red wash tints the whole frame" the critic
read. Pixel (ledger_loop 4943 vs the reel's first frame): bottom controls strip (480,528) 69,48,40 -> 33,14,19 (darker
AND redder) - the row says "never the bottom controls strip". Second cause: `ControlsOverlay` drew every rect/text at z 0
while the light draws at z 17 (the HUD plate draws at z 19) -> the strip sat UNDER the vignette. Fix (presentation, mine):
`draw_vignette(bw_pct:, bh_pct:)` - the base keeps 0.22/0.28, the pulse reads `low_hp_band_w_pct` 0.12 / `low_hp_band_h_pct`
0.16 (display rows: an edge bleed, the middle and the HUD row untouched); ControlsOverlay backing + 6 texts at z 19 (above
the light, level with the HUD plate). da473aa (alpha floors) stays - it fixed onset legibility; this fixes WHERE it bleeds.
Gates owed: ledger_loop, district_hunt, world_loop (base vignette unchanged), town_gates (strip). Wall #4: 20/42 at resume.

### Resume 11:55 — `lobber_reach impact_fx_reads` = SAMPLING (numeral outlives the star); row disambiguated
Sim fact: the two hits nearest capture 0900 are f873 (28 frames before) and f920 (19 after); the lobber's projectile hit
emits `attack_hit landed=true` (kind ""), so it DOES spark. Star life ~14 frames, numeral ~40 -> at 0900 the numeral is
still up and the star is gone; the critic inferred "a hit beat" from the numeral. Row now says a numeral without a star
means the hit is older than the star's life, not a missing star; judge within a dozen frames of a hit. No pixel changed.
Wall #4 score at 22/42: 14 rows / 9 scripts, all with a named cause (7 drawings fixed on the branch, 6 rows corrected,
2 flip-prone). Close procedure unchanged (pause note); wall ETA ~13:40.

### 13:45 — wall #4 CLOSED (44 scripts, 16 gate fails, 1 manifest fail = toll_pocket); 25-gate close batch RUNNING; fixes review in
Sweep verdicts: `tmp/wall/sweep_build4_filtered.log` (banked at the close). Last four scripts classified: `tower3_run
hurt_flash_not_white` = the possessed is a PETRIFIED stone block (white square, TOWER serpents petrify) taking 12 - a named
state tint, not a hurt flash -> row clause at close; `zone8_crossing impact_fx` = bright spark + numeral-outlives-star (on
branch); `zone8_crossing no_render_garbage` = REAL: thin grey-blue lines across walkable ground at two y's + one vertical
(the reel is Gabriel's E1.5 re-author on DUNGEON 1 = the first time that zone's render is judged with the dual-grid tileset)
-> measure at high zoom after the gates (tile seam vs palette `grid`); `tower2_run lobber_reach_reads` (volley 2 tiles, not
4 at LEVEL 10) -> measure after the gates. Final sweep score: 20 rows / 16 scripts - 18 named (7 drawings fixed, 7 rows
corrected/to correct, 4 sampling/flip-prone), 2 to measure (zone8 seam, tower2 volley).
Fresh-eyes review of the 12 fix commits (`drafts/_review-wall4-fixes-freshEyes-20260906.md`): MERGEABLE WITH MINORS; sim/
digest/net untouched (diff empty), suite 1538/0, canaries YES x3. Queue for the CLOSE commit (nothing touched while the
gates read these files): MAJOR gate_batch --ref: read out_dir from the script JSON, tot=0 -> NO-CAPTURES (never
IDENTICAL(0)), count ref-only files; gate_batch prints `=== REGATE` so wall_triage sees batch re-gates; arg-parse guards;
wall_triage skips REGATE blocks with nil gate_rc / INFRA-only; halo contour as the SAME ellipse at rx+1/ry+1 (closed
outline, not a per-row staircase); zone banner z 10 -> 18 and safe-chip backing z 0 -> 19 (same class as the overlay fix);
fx.rb stale "CRIMSON" comment + chip rgb 235,60,60 -> display row; impact_fx_reads "~14" -> "~12" (Fx::SPARK_FRAMES);
signage_test range asserts (low_hp_band_* < 0.22/0.28, floors <= 1); petrify clause on hurt_flash_not_white. Then re-gate
boss2_phases + world_loop + town_gates for the halo/banner/chip pixel changes (3 gates). Named for the netplay side (not
wall-visible): partner halo contour + aura falloff keyed on @local_seat, ControlsOverlay now above the netplay end veil.
