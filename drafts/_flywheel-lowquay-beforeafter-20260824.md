# Flywheel verify — low_quay re-clip BEFORE/AFTER vs the 08-19 first critique (s63, 2026-08-24)

Standing-program rung (quality flywheel, owner-directed 2026-08-19).
Clip: `captures/clips/low_quay_run_20260824-071706.mp4` (2202 frames,
every=2, seed 13, staged level 5 / banked 2000 — the s47 re-authored
wall script `0da0347`). Critique (blind, IDENTICAL focus string as
08-19): `drafts/_self-eval/clip_low_quay_run_20260824-071706_critique.md`
(8 batches, 156/2202 frames ≈ 7% sampling). Event ground truth:
headless stream `tmp/s63_lowquay_stream.txt` (441 lines,
md5 `1306fdd45d9ce29b92ef3b5ba8033b49`, via `tmp/dump_stream.rb`).
Tree: origin `4b810ac` + the staged J7-B set — low_quay_run was
byte-identical across both trees in s59's D8 identity pairs.

**Comparability caveat (named up front):** the 08-19 clip ran the
v15-era script; `low_quay_run.json` was re-authored 2026-08-23
(`0da0347`, staged-level-5 re-cut). Timestamp-level before/after is
dead; SURFACE-level (same zone loop: descent, fights, banking, toll,
boss) and SCORE-level (same rubric + focus) comparisons hold.

## Headline: the 08-19 fix batch survives a blind re-critique

Scores (same rubric): Readability **5→6** · Feel-juice **4→5** ·
Fluidity **7→7.5** · Loop **7→7**. The 08-19 top-3 issues — silent
kills, unattributed incoming damage, invisible attacks — ALL THREE
appear in today's KEEP list, not the issue list: the kill chain is
"the reference frames" (keep 6), receiving-damage stack "best-in-clip
feedback channel" (keep 3), enemy hit-flash "carries combat" (08-19
keep 2, intact). The critic was blind to the 08-19 critique and to
the fix history.

## 08-19 re-check list, item by item (the loop this session closes)

1. Death burst where enemies vanished → **SHIPPED+READS**: v_000824
   shows white flash + shard burst at the 1647 kill; keep 6 praises
   the chain. (Residual: see REFUTED-1 — the "still evaporating"
   windows contain zero deaths.)
2. Player flash + identifiable attacker on HP drop → **SHIPPED+READS**
   (keep 3: body flash + vignette + ghost chunks) + telegraph events
   precede strikes (REFUTED-5).
3. Attack visibility → **SHIPPED** (strike tiles/AoE tiles on-frame);
   knockback half → **ROUTED unchanged** (sim change, v19 lanes; D1
   cadence refusal / D2 evidence gate — by design, not a defect).
4. Fatal-dogpile countability → **N/A script drift** (no wipe in the
   re-authored script).
5. "+0" popups suppressed → **RESOLVED ON-FRAME**: fight_resolved
   frame=3424 net=0 produced NO card (v_001714); the blind re-critique
   raises no +0 complaint anywhere.
6. Boss banner directional cue → **STILL OPEN** (banked B′ below).
7. Pursuit pressure → not re-flagged; kite-and-punish + conga-line
   pulls PRAISED (keep 5). The "stranded pink group" (t=0:52–0:59) is
   aggro-radius-10 spawn placement reading as designed, not pursuit
   failure.
8. Enemy-vs-terrain palette → **STILL OPEN** (banked A′, extends
   s62-A).
9. Loot toast out of center → **RESOLVED** (ledger beat y=160, s62
   refuted the center claim; no center-toast complaint today — the
   new banner-stacking complaint is a DIFFERENT surface, B′).
10. Hitstop unknown at sampling rate → **EXISTS IN CODE** (feel.rb:
    hitstop gates the whole tick, `hitstop_frames_hit`/`_kill`,
    digest-field deterministic; receiving hits shake-only by design).
    Meta: frozen ticks emit identical frames and phash dedup DELETES
    identical frames — hitstop is structurally invisible to sampled
    critique BY CONSTRUCTION. Confirm only via frame-timing log,
    never stills (calibration row carried forward).

## New critique claims — sampling-artifact law applied

### REFUTED (stream + exact frames; sim frame = 2 × video index)

1. **"Kills mostly evaporate" (4 cited windows) — REFUTED.** Stream
   has ZERO `actor_died` in three windows and the fourth is adjacent
   to an on-frame pop: t=0:05.80–0:08.20 (sim 348–492) = the NEST
   ceremony, no enemies exist (first hostile contact frame=720);
   t=0:26.50–0:27.03 (1590–1622) = retargets/hits only, the actual
   kill lands frame=1647 with full pop ON FRAME (v_000824);
   t=0:28.87–0:28.97 (1732–1738) = zero deaths, aggro retargets at
   1741 (enemies MOVED); t=1:08.63–1:09.30 (4118–4158) = zero deaths
   — drop_picked_up 4145 + drop_decayed 4166 (vanishing squares were
   DROPS being collected/expiring). Where things die, they pop
   (kill_pop wall-gated: `kill_pop_reads` standing row).
2. **"Opening fight: counter ticks with no visible react" +
   "U PROVISION -5 noise mid-scrum" (t=0:00–0:07.77) — REFUTED
   (category error).** Sim 0–492 is the nest inscription ceremony:
   banked 2000→1976 via three `inscribed` events + possession swaps;
   zero combat events, zero enemies. The "counters" are economy
   costs; "U provision" is the R-A2 bank BUY hint at the bank,
   working as shipped (`d31f579`).
3. **"Hit-flash absent on the spin's targets" (t=0:26.90/0:27.80) —
   REFUTED.** No `attack_hit attacker=striker landed=true` exists at
   either instant — the spins whiffed (no target in the AoE); flash
   fires on landed hits and does so on-frame at the 1647 kill. The
   HP costs in those engagements are incoming rusher hits (1611,
   1665), separately vignette-covered. No landed hit → no flash owed.
4. **"No hitstop/shake confirmed; existence unknown" — REFUTED by
   code** (item 10 above — and the dedup-blindness explanation).
5. **"Enemy intent invisible — no windup before contact damage" —
   REFUTED.** `telegraph` events precede strikes throughout the
   stream (1604 rusher2 → hit 1623; 4363 rusher13 → hit 4382);
   threat.json `telegraph_frames: 120`; red strike-tile pattern
   visible on the pack cluster at v_002186 before the 4382 hit.
   Honest residual: OWNERSHIP of red tiles in a 3-adjacent scrum is
   ambiguous — merged into banked A′ (one red-family observation,
   not a missing system).
6. **"Companion inert during the boss fight (static ~(285,230))" —
   REFUTED (triple category error).** That body is the POSSESSED
   (white identity outline, v_002160/v_002186 — the marker the
   critic's own keep-1 praises); the live ally is FIRING
   (projectile_fired 4250) and being targeted (hit 4382); the third
   body is DEAD — `actor_died frame=4020 actor=striker faction=pack
   killer=rusher1` — which the critic separately reported as "no
   death occurred in this clip." A pack member died on-screen
   (pop visible v_002012 under the boss banner) and the sampled
   critique missed the event class entirely.

### CONFIRMED → BANKED (no code this session)

- **A′ (extends s62-A): faction/effect palette collision.** Enemy
  beige vs floor/platform beige (v_000824); the boss is
  label-findable only (beige = trash beige, v_002186); pink drops vs
  magenta pickups; RED carries 4+ meanings (player spin AoE, hostile
  strike tiles, hurt vignette, kill burst). Candidate stays the
  s62-A family plus one ownership-color law (player-owned effects
  white/gold vs hostile red). Cost unchanged: display.json is
  assets-repo PINNED (re-pin mail owed) + Rule 2 gate + full-wall
  recalibration; assets-era silhouette/palette pass, or one
  placeholder-era display.json move on owner word.
- **B′ (NEW): banner pile-up at compressed transitions.** CONFIRMED
  on-frame: v_001856 shows ZONE 4 + TOLL PAID stacked
  simultaneously; four center banners in ~5.5s (toll 3659 →
  slow_door 3691 → low_quay 3837 → boss engage 3924). Folds in the
  still-open 08-19 item 6: BOSS 1 SPAWNED carries no direction cue
  (first boss visibility t=1:10.63, banner t=1:06.53). Candidate:
  banner ROUTING rule (center = zone identity only; toll/boss →
  side ticker or offset slot) + a boss direction cue. Lane-4
  presentation family (J-6-adjacent), own Rule 2 gate when landed.
  BANK ONLY.
- (carry) s62-B edge-pip HP tick — unchanged, low.
- **Asset-era list** (silhouettes, windup frames, death pass, boss
  kit, owner-coded VFX palettes, projectile glow-up, typography) —
  aligns with s62-C; carried as-is for the assets era.

### ROUTED

- Knockback / melee pile separation → sim change, v19 lanes (D1/D2
  posture unchanged; same as s62-D).
- "Spin spam / cooldown unknown" + difficulty-attrition reads →
  EIGHTEENTH-ritual-frozen numbers; zero knob moves.

## Meta (flywheel calibration, extends s62's)

s62's law held: every severity-major ABSENT-feedback claim was again
a sampling artifact (6 REFUTED). New rows for the standing
calibration: (1) hitstop is UNPROVABLE from deduped stills — frozen
ticks dedup away; use frame-timing logs. (2) Context blindness:
economy ceremonies (nest inscriptions) get read as combat — cross-
check WHERE the clip is (zone_entered stream lines) before accepting
combat claims. (3) Entity-identity claims ("companion inert", "no
death occurred") need stream cross-check — `tmp/dump_stream.rb` is
cheap and names every actor/event. The critique's durable value this
session, as s62 predicted, is the perceptual adjacency reads (A′/B′)
and the keep-list — which sampling cannot fake.

## Next-clip re-check list

1. If A′ lands: boss + hostiles separable from terrain without
   labels in v_002186-class frames; red split player/hostile at
   v_000824-class kill moments.
2. If B′ lands: v_001856-class window shows one center banner max +
   ticker; boss banner co-fires with a direction cue.
3. Ritual-post: pacing/attrition reads (spin cost, approach cadence)
   against whatever the verdict unfreezes.
