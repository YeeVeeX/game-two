# Flywheel job 1 — critique verification pass (2026-08-19, dev session 17)

Input: `drafts/_self-eval/clip_low_quay_run_20260819-104223_critique.md`
(10 ranked claims). Law applied: **sampling-artifact law** — no claim
becomes a work item without verification against code + exact frames.
Frame source: `tmp/clip_low_quay_run_20260819-104223/video/v_NNNNNN.png`
(every=2 → 30 fps → frame ≈ t×30; the dense dir carries ALL 4306
frames — the critic sampled ~160). Method per claim: (1) read the
owning code; (2) eyes on the exact frames at the cited timestamps;
(3) classify: CONFIRMED-DEFECT / EXISTS-SAMPLING-ARTIFACT / PARTIAL /
UNKNOWN-NEEDS-INSTRUMENT / SIM-CLASS (v19, record only).

## Verdict table

| # | Claim | Verdict | Evidence (code + frames) | Disposition |
|---|-------|---------|--------------------------|-------------|
| 1 | Kills evaporate silently | **EXISTS-SAMPLING-ARTIFACT** | `world.rb:1606` emits a kill pop on EVERY `actor_died`; `renderer.rb draw_kill_pops` = 5-frame near-white tile flash + 14-frame shard shatter (`combat.json pop_frames=14`, `display.json kill_pop_flash_frames=5`); corpses persist+fade (`draw_corpses`); drops spawn. Frames: v_001141 flash tile + shards at the death tile; v_001143/1145/1147 shard spread + magenta drop + corpse; v_001548 flash+shards; v_001551 spread. The critique's cited windows (v_001077→1084, t=0:35.90→0:36.13) contain enemy MOVES, not kills — no pop because no death (no corpse, no drop appeared either). | No fix owed. The pop is present in ≥3 consecutive sampled frames per kill; a ~27-frame critic stride misses it ~90% of the time. |
| 2 | Incoming damage unattributed | **PARTIAL** (exists but weak + one real gap) | Pre-hit telegraph EXISTS: every human melee has 20–30 windup frames rendered as the red/yellow body swell (`combat.json`, `draw_creature telegraphing?`) — frames v_000400–406 show the swell straddling the cited t=0:13.47 hit. On-hit feedback EXISTS: `creature.rb take_hit` sets `hurt_frames=8` → crimson flicker (`body_color`), `feel.rb on_player_hit` shake 6.0. **GAP (code-verified): `draw_attack` is pack-gated — an enemy's ACTIVE strike renders nothing**; the landed hit has no enemy-side visual. | SHIP fix 2 (enemy strike tiles, renderer-only) + fix 3 (possessed hurt vignette, renderer-only — amplifies existing `hurt?` state). Wind-up landing-tile PREVIEW = RECORDED, difficulty-adjacent (pending ritual measures difficulty — frozen). |
| 3 | Player attacks invisible | **EXISTS-SAMPLING-ARTIFACT** | Pack attacks render: windup dim + active bright tile (`draw_attack`; basic active=4 sim frames = 2 dumped frames). Pixel-scan over v_001130–1179 found the SLASH spike at v_001169/1170 (near-white pixels 93→233), visually confirmed (two bright white-cyan strike tiles beside the attacking pack bodies). At the critic's stride the catch probability per swing ≈ 7%. The cited t=1:38.23 "flash" is a TELEGRAPH swell (v_002947). | No pack-side fix. The enemy-side half folds into claim 2's gap (fix 2). |
| 4 | No knockback → blobs | **SIM-CLASS, RECORD** | Knockback EXISTS as an ATTACKER stat by kit-identity design (`take_hit knockback_tiles`; combat.json: blocker attack=1/special=2, striker special=1, striker/lobber basic=0). Enemy stacking/tile-occupancy = sim design. Difficulty-adjacent. | RECORDED for the v19 pool; frozen while the ritual is pending. |
| 5 | "+0" reward beats harmful | **CONFIRMED-DEFECT (presentation; economics INTENDED)** | Mechanism verified: `fight_ledger.rb` — `zone_entered` force-resolves the window; kills qualify it; `gained=0` when drops stay unlooted → solo "+0" beat, 150-frame center-screen dwell (`ledger.json ledger_beat_frames=150`). Frames: v_000729 (HUB 1 + TOLL PAID + "+0"), v_002492 (ZONE 1 + "+0"), v_003836 ("+0" over live field). The "-150" at v_001296 is the seal PRICE TAG (`economy.json breach_cost_2=150`, `draw_station_ledger`) — intended existing grammar. Carried-value indicator ALREADY EXISTS (possessed HUD numeral — v_004081 shows "5"). | SHIP fix 1: suppress all-zero non-wipe beats (renderer-only). Wipe recaps untouched (praised format). |
| 6 | Boss banner points at nothing | **CONFIRMED-DEFECT (presentation), RECORD** | v_001497–1551: BOSS 1 SPAWNED stamp legible, boss off-screen, no directional cue anywhere in the window. Fix candidates (screen-edge arrow toward the challenger / camera nudge) are M-effort and touch the camera-presentation seam. | RECORDED with next-spark shape (below) — not rushed into an adjudication-capable session. |
| 7 | Pursuit AI gives up | **SIM-CLASS, RECORD** | v_004081→4130: the pack of ~7 pursuers closes barely any distance while the player crosses half the zone; several carry PRESSURE OUTLINES — part of the read is the pressure-stance system working as designed (encirclement, `pressure_ring_reads` is a walled check), part is leash/pathing behavior. AI/threat iteration = sim; difficulty-adjacent. | RECORDED for the v19 pool (with the pressure-stance context named); frozen while the ritual is pending. |
| 8 | ZONE 2 enemy/terrain contrast | **PARTIAL** | district wall `[176,140,88]` vs HUMAN_BODY `(205,198,180)`: same warm family, ΔL real but modest. v_000529: enemies ON the dark floor read fine; bodies adjacent to/overlapping tan wall blocks genuinely soften — but "disappear" overstates it (notch + size still separate them). Enemy-side color change would re-judge EVERY zone (HUMAN_BODY is global); wall-side step re-tints ZONE 2's identity. | RECORDED for the asset-era palette pass (critique's own leverage list #5: zone palettes with guaranteed terrain separation). |
| 9 | Entity taxonomy conflated | **PARTIAL, RECORD** | The grammar exists and is walled: drops = FILLED squares (size/color banded), corpse loads = HOLLOW magenta pips, bodies carry facing notches, telegraphs are two-tone (checks `drops_read_as_pickups`, `corpse_load_reads`, `volley_telegraph_distinct`). Shape-per-class beyond that = asset-era work (leverage list #3). | RECORDED for the asset era. |
| 10 | Loot toast center-screen | **PARTIAL** | The "toast" IS the ledger beat panel — placement is a DESIGNED decision (fight-ledger spec: player-anchored, camera keeps the avatar centered; prominence is a walled check `ledger_prominence`). Dwell 150 frames. The harmful instances the critique cites are the "+0" beats (fix 1 removes them); real beats (+5/+6, wipe recaps) the critique itself praises. | Fix 1 covers the harm. Panel placement re-evaluation RECORDED as an owner-facing design question for the post-verdict brainstorm. |

## Fixes shipped this session (renderer-only, digest-blind by construction)

1. **Suppress all-zero non-wipe ledger beats** — `draw_ledger_beat`
   early-returns when `gained == pip == dark == 0` and kind ≠ wipe;
   predicate extracted pure (`Renderer.silent_beat?`) + unit test.
   Kills keep their pops; the beat slot stops training players to
   ignore it.
2. **Enemy strike tiles** — a hostile-red active-window tile flash on
   the enemy's `action_tiles` (drawn AFTER both body passes, before
   HUD; brief: active=1–6 sim frames). The windup half stays the
   existing body swell; the landed hit now has a WHERE. Color audited
   against the walled families (pack SLASH white-cyan, volley orange,
   telegraph two-tone swell, gate gold).
3. **Possessed hurt vignette** — thin red edge frame while the
   possessed body's existing `hurt?` window (8 sim frames) runs;
   reads "I took damage" without inspecting the HP bar. Edge-bars
   only — distinct from the full-screen stagger veil and wipe veil.
   Keys in `display.json` (`hurt_vignette_px`, `hurt_vignette_alpha`).

Each fix: own commit + `rake gate SCRIPT=harness/scripts/low_quay_run.json`
(blocking). After the last: re-cut the same clip, eyes-on re-check of
the critique's re-check list items 2/5, wall sweep detached.

## Recorded items (owner brainstorm inputs — NOT in-session work)

- **R1 (from #6):** boss spawn pointer — screen-edge arrow toward the
  challenger while `BOSS 1 SPAWNED` dwells + optional camera nudge.
  Renderer reads boss position (camera = presentation state,
  digest-excluded). M effort. Next-spark shape: presentation-only,
  gate on `varekka_duel` + a boss-window script; `seizure_reads` /
  `challenger_tell_reads` checks extended with a pointer row.
- **R2 (from #2):** enemy wind-up LANDING-TILE preview (dim hostile
  tint on `action_tiles` during windup). Renderer-only mechanically,
  but it changes how dodging reads → difficulty-adjacent →
  post-verdict class.
- **R3 (from #4):** knockback coverage debate (basic attacks 0 tiles
  by kit identity today) + enemy tile-occupancy/stacking. SIM-CLASS,
  v19 pool.
- **R4 (from #7):** pursuit pressure — leash/pathing pass around
  pillar rooms + minimum-pressure leash so retreat costs something.
  SIM-CLASS, v19 pool (read WITH the pressure-stance design intent).
- **R5 (from #8):** zone-palette separation guarantee (enemy body vs
  wall value step per zone) — asset-era palette pass.
- **R6 (from #9):** shape-per-class silhouettes — asset era.
- **R7 (from #10):** ledger panel anchoring (player-anchored center
  vs corner toast) — owner taste call at the brainstorm; evidence:
  this clip's beat windows.
- **R8 (from #1, optional):** kill-pop amplification knobs already
  exist as data (`pop_frames`, `kill_pop_flash_frames`) — only if the
  owner asks for more punch after seeing the next clip.

## Re-check results (post-fix, same script)

Filled after the re-cut below.
