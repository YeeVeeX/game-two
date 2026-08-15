# v14 wall log — gate provenance (2026-08-14, SSoT — read before touching any gate)

Branch junior-tibia after TDD 6/6 (`19d082b`). Checks 46 (ADD-ONLY from 44:
+controls_overlay_reads +respawn_telegraph_reads; #19 strip carve-out
non-narrowing; #42 District One→The Longrow — owner ratifies both at the
twelfth). Suite 395/1601. Retry law: 2 attempts, INFRA-only. Verdicts from
tmp/wall/*_v14_*.log teed files, NEVER task exit codes. ONE window at a time.
FULL re-run = the v14 comparability reset (renames on every banner, strip in
every frame, respawn-stream isolation shifts drop rolls).

## Machine-checked mandatory beats (Codex fold Q9/Q10 — NEW triage law)

Self-gating checks are FORCED to pass when unexercised (vision_critic.py
self_gating set), so the critic cannot catch a dead staged beat. Every staged
script's teed log MUST show its manifest events (grep `EVENT <name>`); a
missing staged event = semantic desync = RE-PILOT even when the critic
passes. Manifests measured from the v13 teed logs (counts are per DOUBLE
replay — halve for per-run):

| script | manifest (must appear in log) |
|---|---|
| world_loop | banked ≥1, drop_picked_up ≥1 |
| district_hunt | pack_wiped ≥1, pack_respawned ≥1, kills ≥10 |
| loot_loop | drop_picked_up ≥1, banked ≥1 |
| corpse_run | corpse_loaded ≥1, pack_wiped ≥1, corpse_looted ≥1, banked ≥1 |
| threat_pull | human_retargeted ≥20, human_leashed ≥20, corpse_loaded ≥1 |
| ledger_loop | banked ≥1, corpse_loaded ≥1, pack_wiped ≥1 |
| vat_economy | **tribute_paid ≥1 + body_regrown ≥1** (DEAD at v13 — pre-known re-pilot), banked ≥1, inscribed ≥1 |
| specials_chain | special_started ≥3 (three kits), taunted ≥1 |
| taunt_anchor | special_started ≥1, taunted ≥1 |
| aoe_specials | special_started ≥2 (whirl + challenge), taunted ≥1 |
| nest_advance | banked ≥2, corpse_loaded ≥1, corpse_looted ≥1, pack_wiped ≥2 |
| respawn_telegraph | respawn_telegraphed ≥2, human_respawned-at-a-told-tile ≥1 (cross-check tiles event-to-event) |
| moving_square / critic_reel | det-only (v11 INFRA law), no manifest |

Pre-existing coverage gap (recorded, OUT of v14 scope): NO wall script
stages a seal breach — `seal_breached` appears in zero v13 logs; check #41
has ridden its self-gate since v12. Zone-3/arc scripts are the v15 lead's
concern.

## respawn_telegraph.json provenance (pilot tg1, seed 7, generation r2, 1467 frames)

Captures (9): 14 vigil banner+strip+initial-pulse · 534 Longrow banner+strip ·
567 swap pulse (hevet) · 717 tell early, no human · 743 TWO tells grown ·
795 tell full held (W3, pack-blocked — honest deferral) · 1265 NE tells held
(blocker cam) · 1435 tell [40,13] full pre-delivery · 1446 body materialized
[40,13] (delivery, camera-edge).

Honest deviations from the spec's 12-beat list:
- **Delivery capture is CAMERA-EDGE** (frames 1435/1446: tile x=40 sits at
  the right view boundary; the tell/body are half-cut). The delivery is
  UNAMBIGUOUS in the event log (respawn_telegraphed [40,13]@1323 →
  human_respawned [40,13]@1443, +10 telegraphs total in telemetry) — the
  machine manifest passes; the VISUAL read is weak. If the critic fails
  #46 on it, re-pilot r3 with the solo-body recipe below.
- Beat 8 (tell + volley same frame) NOT staged — the r1 lobber died before
  a volley/tell coincidence; volley distinctness is exercised by
  specials_chain/aoe_specials gates.
- Beats 11-12 (wipe veil over strip / post-wipe strip) not in THIS script —
  every wipe-staging script (corpse_run, ledger_loop, district_hunt,
  vat_economy, nest_advance) now shows the strip under its veil for #45.
- Beat 9 (tell + human attack telegraph same frame) best-effort: combat
  runs through the tell windows; verify at critic verdict.

## Pilot doctrine additions (tg1 r1+r2 — do not re-derive; HARD-WON)

- **The pin/materialize block radius is 12 tiles = half a screen.** A tell
  can NEVER be born within 12 of any pack body, and the camera sees ~14-15
  tiles — the visible-birth band is dist 13-14, TWO tiles wide, against a
  semi-chaotic anchor. Chasing births in-band is a lottery (0/5 attempts).
- **The winning camera trick is the DEFERRAL itself**: park inside 12 →
  tell holds at full; walk out compactly → delivery fires the tick the
  last body crosses 12 — you control WHEN, with the camera pre-aimed.
  What broke it in r1/r2: AI allies free-hunt and rotate through the
  12-line for minutes (dists 3-11), re-holding everything. Solo-body (or
  possessing the straggler and walking it out yourself) is the reliable
  variant. Swap = instant camera teleport to any pack body.
- W5 unpin observed live TWICE (r1 [22,5]@1009→recompute to [32,17]; r2
  [24,14]@~1079): a camped tell vanishes and the respawn escapes far —
  design working as folded.
- Every un-blocked tell delivered EXACTLY at its at_frame (1531, 1917,
  2323, 1321, 1443 — zero drift): materialize-tick-unchanged holds live.
- Hitstop from kill bursts pauses tick_world — releases/pins slip a few
  ticks after big clears; drive ≥10 ticks before asserting.
- Allies die fast when you retreat and they don't (r1 lost striker+lobber
  to the east swarm while the possessed walked west).

## Wall run A (order; sequential, ONE window; logs tmp/wall/<script>_v14_a1.log)

moving_square → critic_reel → world_loop → district_hunt → loot_loop →
corpse_run → threat_pull → ledger_loop → vat_economy → specials_chain →
taunt_anchor → aoe_specials → nest_advance (~65 min, long event-silent
stretch is NOT a hang) → respawn_telegraph (ran FIRST as early validation).

## Gate table (filled as verdicts land — from teed logs only)

| # | script | verdict |
|---|--------|---------|
| 1 | respawn_telegraph | **PASS a1** (det 9/9 byte-identical ×2 runs; vision PASS — #46 EXERCISED for real: "Pale teal-green tiles in frame_0743 and later brighten and hold, reading as arrival tells distinct from telegraphs"; #45 EXERCISED: "swaps between goret shout, hevet lob, and ithet spin with possession". The camera-edge delivery worry did NOT bite — the critic read the tell grammar from the clean mid-script frames. Log: tmp/wall/respawn_telegraph_v14_a1.log) |
| 2 | moving_square | **PASS a1** (det-only per v11 INFRA law: 3 captures byte-identical ×2) |
| 3 | critic_reel | **PASS a1** (det-only per v11 INFRA law: 20 captures byte-identical ×2) |
| 4 | world_loop | **PASS a1** (det 10/10; vision PASS; manifest OK: banked=2, drop_picked_up=2 per double replay; #45 EXERCISED again: "swaps names from goret to hevet across possession changes") |
| 5 | district_hunt | **PASS a1** (det; vision PASS; manifest OK: pack_wiped=2, pack_respawned=2, kills=13/run ≥10; BONUS: #46 exercised ORGANICALLY in a non-staged script — "Teal-pale floor tiles in 1029 through 1041 read as arrival tells distinct from all attack telegraphs") |
| 6 | loot_loop | **PASS a1** (det 13/13; vision PASS; manifest OK: drop_picked_up=2, banked=2) |
| 7 | threat_pull | **PASS a1** (det 20/20; vision PASS; manifest OK: human_retargeted=78, human_leashed=62, corpse_loaded=2. Note: `leash_walkback_reads` self-gated this run — the EVENT fired 62×, the critic just didn't catch a walkback in the sampled frames; manifest law judges events, not per-check exercise) |
| 8 | corpse_run | **MANIFEST FAIL a1 → RE-PILOT** (det 17/17 + vision PASS, but corpse_looted=0 + banked=0 vs manifest ≥1 each; v13 had 2/2. W1 RNG-stream shift moved the world under the recorded inputs — corpse_loaded=2 fires but the recovery press lands on nothing; `corpse_run_reads` self-gated "Not exercised" IN ITS OWN SCRIPT while the critic passed. Textbook Codex-fold catch: the manifest law, not the critic, caught it. Re-pilot cr2 after the wall frees the window.) |
| 9 | ledger_loop | **MANIFEST FAIL a1 → RE-PILOT** (det 13/13 + vision PASS + ledger panel read clean, but corpse_loaded=0 vs manifest ≥1; banked=2 + pack_wiped=6 OK. Same W1 mode: the body that died carrying in v13 no longer does. Re-pilot ll2.) |
| 10 | vat_economy | **MANIFEST FAIL a1 → RE-PILOT (pre-known, and WIDER than v13)** (det 14/14 + vision PASS; banked=4 OK but tribute_paid=0 + body_regrown=0 — the v13 dead beat, expected — AND inscribed=0 where v13 still had 2: the RNG shift killed the altar beat too. Full re-pilot vat6 stages all four.) |
| 11 | specials_chain | **PASS a1** (det 14/14; vision PASS; manifest OK: special_started=6 = lobber+striker+blocker per run — three distinct kits verbatim; taunted=2) |
| 12 | taunt_anchor | **PASS a1** (det; vision PASS; manifest OK: special_started=2, taunted=2) |
| 13 | aoe_specials | **PASS a1** (det; vision PASS; manifest OK: special_started=4 = blocker challenge + striker whirl per run, taunted=2; #43/#44 exercised for real — "bright tile ring around the striker with an adjacent human flashing", "rust pulse answered by rust-underlined humans inside its radius") |
| 14 | nest_advance | **MANIFEST FAIL a1 → RE-PILOT** (det + vision PASS but banked=0 vs ≥2 and corpse_looted=0 vs ≥1; corpse_loaded=4 + pack_wiped=8 OK; carried_lost=4 shows the value DIED instead of banking. The owner SAW this one live: "solo te veo dando vueltas en El Nido hace horas" — the diverged replay loops without ever banking. Re-pilot na2.) |
| 10b | vat_economy | **PASS a2 — replacement script (pilot vat6)** (det 11/11; vision PASS; manifest COMPLETE: tribute_paid=2, body_regrown=4, banked=4, inscribed=2 per double replay. `tribute_beat_reads` EXERCISED on a real tribute for the first time since v12: "After banking, dead bars refill and bodies stand alive near the stations in frame 2869"; god_mark_reads: "tiny pale hollow square floating above the possessed body". Log: tmp/wall/vat_economy_v14_a2.log) |
| 14b | nest_advance | a2 = **VISION FAIL (capture selection, not sim)**: det 6/6 + manifest COMPLETE (banked=4, corpse_loaded=2, corpse_looted=2, pack_wiped=10) but 4 mandatory-beat checks failed — kits_distinct/possessed_readable/hud_three_bars/carried_count_reads all need the FULL PACK on screen and every na2 capture showed the solo-vessel stretch (memory `gate-critic-mandatory-beat-checks` verbatim). Fix: splice-legal early captures (15/700/1600, full pack alive+carrying) → **PASS a3** (det 9/9; vision PASS; same complete manifest. Log: tmp/wall/nest_advance_v14_a3.log) |

**WALL 14/14 PASS** (10 scripts a1 + vat_economy/corpse_run/ledger_loop a2 +
nest_advance a3; 4 re-pilots of the 2-5 budget — every one a W1 RNG-shift
semantic desync the MANIFEST law caught while the critic passed 3 of 4).
| 9b | ledger_loop | **PASS a2 — replacement script (pilot ll2, 4386 frames — fastest pilot of the day: bank EARLY while the pack lives, then the suicide push)** (det 6/6; vision PASS; manifest COMPLETE: banked=2, corpse_loaded=2, pack_wiped=2 + fight_resolved staged. Splices paid twice: `ledger_beat_reads` on 1520 "large magenta glyph plus 4... banner-scale prominent" and `ledger_negative_reads` EXERCISED — "hollow -7 line resolves to a red = -7 net, clearly negative" — the 7 lost at the wipe became a read loss line. Log: tmp/wall/ledger_loop_v14_a2.log) |
| 8b | corpse_run | **PASS a2 — replacement script (pilot cr2)** (det 8/8; vision PASS; manifest COMPLETE: corpse_loaded=8, corpse_looted=6, pack_wiped=14, banked=2. `wipe_recap_reads` exercised via the spliced veil frame: "Tally renders over the veil in 1920 and 8785 and stays fully legible" — #45's under-veil interplay verified. HONEST NOTE: `corpse_run_reads` stayed self-gated this run (events all fire; the critic's sampled frames didn't show the return-to-pip sequence it wants — sampling luck, recorded not hidden). Log: tmp/wall/corpse_run_v14_a2.log) |

## vat_economy replacement provenance (pilot vat6, seed 7, generation r2, 20213 frames)

Exported after the r1 timeline burned ~30 min on solo-grind failures (reset r2 at
frame ~11.7K of r1; r1 is NOT in the script). The r2 story the script replays:
pack hunt west→mid (28 banked by 2777) → tribute 26 at the vat @2864 (regrown=2
healed=1 — the pack had wiped once and the one-vessel floor kept the blocker) →
deep-east hunt wipes the pack repeatedly (lobber becomes the kept vessel) →
solo-lobber campaign: volley special @16668 kills rusher21 mid-chase, cardinal
snipes + the corpse-container RATCHET carry 8 home → banked=8 @20075 → inscribed
@20164. Captures (11): 315 Longrow banner+strip · 1560 triple-kill fight · 2590
wipe veil over strip (SPLICED) · 2776/2787 bank press+numeral · 2869/2899
tribute cue + regrown bodies · 14330 second veil (SPLICED) · 20163/20172/20212
altar press + inscribe cue + god mark. Splice law respected: capture-frame
additions only (1560/2590/14330), zero input edits post-export.

## Pilot doctrine additions (vat6 — 14 deaths of tuition; do not re-derive)

- **Melee combat = `hold attack,<dir>`** (each swing re-aims; standing attack
  swings at a fixed facing forever). **Ranged combat = the OPPOSITE**:
  attack+direction WALKS you into the swarm; the lobber protocol is tap-face
  (`hold <dir> 3`) then `hold attack N` stationary, at range 4-6, CARDINAL
  only — projectiles fly in 4 directions; a diagonal-adjacent dancer is
  unhittable and will melee you down.
- **Dodge dashes along CURRENT FACING** (2 tiles + iframes). To dodge AWAY,
  face away first — dodging mid-duel while facing the enemy closes distance.
- **Volley (lobber special): impacts at d2/3/4 along facing, 40-frame delay,
  35 dmg.** Fire it at CHASERS 5-6 tiles behind — they walk INTO the impacts
  during the delay. Against idle targets the delay makes it whiff.
- **`aggro_tiles=10` governs the hate-scan too** — rusher_haters beeline the
  lobber (`cause=hate`) but only inside ~10 tiles. Standing at the gate does
  NOT bait anyone from a parked camp 20+ tiles away; respawned humans idle at
  their east pockets and never patrol west. A dried-out map = you go to them.
- **The one-vessel floor keeps the body possessed AT the wipe** — i.e. the
  LAST body to die (possession auto-transfers as bodies drop). Die as the
  blocker mid-pack-collapse and the vessel you get back may be the lobber.
- **The corpse-container RATCHET: value is nearly indestructible.** Dying
  while carrying re-containers the value AT the death tile with a FRESH 5400
  term. Deliberate die-carrying moves money toward home in hops. Only DROPS
  decay (1800); containers effectively don't (within a session's patience).
- **`press interact` is eaten by attack recovery** (attack_state != :idle
  returns false silently). Always `wait 15-20` between combat and any press.
- **Step timing is PER KIT: striker 13 f/tile, lobber 16, blocker 19.** A
  `hold <dir> 16` moves the lobber exactly one tile and the blocker ZERO —
  the press then lands on the wrong tile. This single error killed FOUR
  grab attempts across cr2/na2. Blocker steps = `hold <dir> 22`; goto for
  precision when ground is clear.
- **The D0 two-press rule bites at recoveries**: a drop stacked ON the
  container tile takes the first press; the container needs a SECOND.
  Always press twice with `wait 15` between.
- **attack+direction KEEPS WALKING after the kill** — a 110-frame melee
  hold overshoots the corpse tile by 3-4 tiles. Kill with short holds
  (40-50), then reposition with goto.
- **`goto` aborts leave you STANDING in the open** — the r1 deaths were
  goto-chains stalling mid-swarm. In contested ground move with directional
  holds; save goto for verified-clear paths.
- **`speed 20` + `wait N` fast-forwards waiting** (leash cycles, respawn
  clocks) — don't real-time idle the window.

## corpse_run replacement provenance (pilot cr2, seed 7, r1, 10103 frames)

The D1 loop staged THREE times over (manifest wants ≥1 of each): pack hunt →
deep-east push wipes the pack @1872 with the blocker carrying 4 (corpse_loaded
@1796 at [42,11]) → lobber vessel → pip-district approach capture @2974 →
recovery @3041 (corpse_looted) → two ratchet hops ([42,11]→[21,14], the
die-carrying container relocation) with re-loots @4452/@6439 → trio duel
(rusher24 column-sniped at [10,10]) → drop walked home ALIVE → banked=1
@10092. Captures (8): 1810 corpse pip (SPLICED) · 1920 wipe veil over strip
(SPLICED) · 2974 pip-marked district return · 6430 recovery press (SPLICED) ·
8785/8796 misfire pair (post-death nest frames, harmless) · 10091/10102 bank
press + numeral. Splices: capture-frame additions only.

## ledger_loop replacement provenance (pilot ll2, seed 7, r1, 4386 frames)

Fastest pilot of the day — the lesson applied: bank EARLY while the pack
lives. Opening hunt → fight_resolved @1488 (kills=10 net=4) → banked=4
@1829 → mid-map re-sweep carrying 7 → deep push → corpse_loaded + wipe
@4128 at [32,16] → recap over veil. Captures (6): 710/1040 opening ·
1520 ledger panel (SPLICED) · 1839 bank beat · 4133/4170 loss line +
recap over veil (SPLICED).

## nest_advance replacement provenance (pilot na2, seed 7, r1, 13034 frames)

The endurance contract in two full trips: bank 6 @1767 (trip 1) → pack
attrition → 5 solo-vessel wipes (the middle stretch: 4 failed grab
attempts, all step-timing bugs — see doctrine) → drop stack grabbed
@10054 (+6) → corpse_loaded @10301 [25,10] → recovery duel (rusher17
killed off the container tile) → corpse_looted @11948 (+6) → carry-home
SUCCEEDED → banked=12 @12963 (trip 2). Captures (6): 1777 bank1 · 3266
mid · 4390 wipe veil (SPLICED) · 10310 corpse pip (SPLICED) · 11940
recovery press (SPLICED) · 12973 bank2.

## Re-pilot plans (designed while the wall ran — execute AFTER it frees the window)

Common: `rake pilot NAME=<n> SEED=7`; append via `printf 'cmd\n' >>
tmp/pilot/<n>/inbox.txt`; interact is a PRESS on the exact station/container
tile (`station_at(*source.tile)`); corpse recovery is settle-gated
(`loot_settle_frames=300` — wait ≥5s after the death) and term-bound
(`corpse_term_frames=5400` — recover within 90s); hitstop pauses tick_world
after kill bursts (drive ≥10 ticks before asserting); wait 25 after swap.
Nest fixtures: bank [12,8] · altar [16,8] · vat [14,10]; pack spawns
[14,8] [13,8] [15,8]. Costs: inscribe 8, regrow 12/dead, heal 2/wounded.

- **vat6 (vat_economy replacement)** — stage banked ≥1, inscribed ≥1,
  tribute_paid ≥1, body_regrown ≥1. Hunt Longrow → pick drops → bank ~24+
  → altar press (inscribed, capture god-mark cue) → get ONE body killed
  (retreat while it's engaged) → vat press (tribute_paid + body_regrown —
  capture the tribute station cue, THE first real exercise of
  tribute_beat_reads since v12) → capture regrown body at spawn.
- **cr2 (corpse_run replacement)** — stage corpse_loaded, pack_wiped,
  corpse_looted, banked. Hunt carrying → die carrying (corpse_loaded,
  capture pip) → full wipe (capture veil OVER strip) → respawn at nest →
  walk back (capture pip-marked district = corpse_run_reads) → stand on
  container after settle, press (corpse_looted) → carry home → bank.
- **ll2 (ledger_loop replacement)** — stage banked, corpse_loaded,
  pack_wiped + the ledger beats: fight → fight_resolved (capture center
  panel) → bank → die carrying (corpse_loaded) → wipe (capture recap).

## Sequence after wall

perf ALONE → full bundle exec rake → CHECKPOINT + scope v15 rewrite +
PARKING_LOT → fetch (Junior may have pushed) → merge --no-ff INTO
junior-tibia → push → TWELFTH blind verify (Spanish; harvest
/tmp/game_two_session_<pid>.log BEFORE questions; skeleton
drafts/_v14-fun-verify-20260814.md) → v15 debate.
