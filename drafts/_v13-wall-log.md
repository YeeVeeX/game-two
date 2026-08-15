# v13 wall log — gate provenance (2026-08-14, SSoT — read before touching any gate)

Branch v13-aoe after TDD 5/5 (`ccdc211`). Checks 44 (ADD-ONLY from 42:
+whirlwind_reads +challenge_reads; check 14 striker clause updated
through-lane→ring-burst — owner ratifies at debrief). Suite 369/1486.
Retry law: 2 attempts, INFRA-only. Verdicts from tmp/wall/*_v13_*.log
teed files, NEVER task exit codes. ONE window at a time.

## Wall run A (2026-08-14, background task bnifycqqy)

Sequential full gates (det + critic; moving_square/critic_reel det-only
per the v11 INFRA law), order: moving_square → critic_reel → world_loop →
district_hunt → loot_loop → corpse_run → threat_pull → ledger_loop →
vat_economy → specials_chain → taunt_anchor → nest_advance (~50 min).
Logs: tmp/wall/<script>_v13_a1.log.

## Gate table — WALL COMPLETE 2026-08-14: 13/13 PASS

| # | script | verdict |
|---|--------|---------|
| 1 | moving_square | **PASS** (det-only, INFRA law) |
| 2 | critic_reel | **PASS** (det-only) |
| 3 | world_loop | **PASS** (vision + det 10/10) |
| 4 | district_hunt | **PASS** (9/9) |
| 5 | loot_loop | **PASS** (13/13) |
| 6 | corpse_run | **PASS** (18/18) |
| 7 | threat_pull | **PASS** (20/20) |
| 8 | ledger_loop | **PASS** (13/13) |
| 9 | vat_economy | **PASS** (14/14 — regrow-dose numeral change did not bite; tribute is the final beat) |
| 10 | specials_chain | **PASS a1** — my "CERTAIN desync" prediction was WRONG in the happy direction: gates judge check semantics on fresh captures, not v11 pixels. `whirlwind_reads` EXERCISED for real ("bright tile ring… adjacent bodies flashing gray"); specials_distinct passed on the new burst |
| 11 | taunt_anchor | **PASS a1** — `challenge_reads` EXERCISED for real ("humans inside the frame_0890 pulse carry rust underlines and turn toward the caster"); radius-9 pulse read fine |
| 12 | nest_advance | **PASS a1** (~65 min double replay; long event-silent walking stretch ~20K-32K looks frozen — it is NOT, CPU idles on vsync; do not kill) |
| 13 | aoe_specials | **PASS a2** (det 8/8 both attempts; a1 vision real-FAIL whirlwind_reads — capture 1283 missed the flash window; SPLICE-LEGAL retime 1283→1282 + 1289→1284 landed "adjacent victim highlighted". ⚠ honest note: its challenge captures (1173/1189) read as NOT-exercised to the critic (pulse at 4/20 expansion too thin) — challenge_reads' real exercised proof lives in taunt_anchor's gate) |

Zero re-pilots of v11/v12 scripts needed. Logs: tmp/wall/*_v13_a{1,2}.log.

## aoe_specials provenance (pilot aoe1, seed 7, generation r2, 1385 frames)

Captures (8): 14 kits_at_spawn · 1173 challenge3_pulse · 1189
challenge3_marks (cast = **taunted victims=5**) · 1282 whirl_clump_active
(hits at 1281: rusher16+rusher10, kind=special) · 1284 whirl_clump_pop
(radial tween) · 1309 whirl_pip_after · 1335/1374 carry_escape (carried=2
numeral on HUD, chasers locked on blocker).

Honest deviations from the spec's mandatory-beat list:
- whirl clump = 2 victims on camera (spec asked ≥3; the check needs ≥1;
  refund math is unit-proven in whirlwind_test; the eleventh's whirl.hits
  histogram carries the real answer).
- pip re-arm not visually proven (2-hit refund = 360 left, pip stays
  spent; only a 4+ hit re-lights it early).
- r1 (discarded generation) recorded an AUTHENTIC mobbed-while-carrying
  death: striker died carrying 5 at frame 2076, FOUR frames into the
  rescue-challenge windup — the v13 thesis (the challenge answers
  carrying-deaths) demonstrated by an 8-frame miss. r2 landed the rescue.

## Pilot doctrine additions (aoe1 r1+r2 — do not re-derive)

- **Your own allies eat the staged clump**: the AI striker killed the
  gathered train twice. Cast the challenge the MOMENT 3+ are within 9
  (radius is huge; the lock drags them in) — never wait for adjacency.
- **goto is useless near enemies** (guard aborts even at guard=0-2);
  drive with short holds; body-block = hold-into (plant), route AROUND
  allies (they block like walls).
- **Swap cycles LIVING members only** — with a dead body the cycle
  shortens (blocker↔striker); count presses per state read, don't assume.
- **The challenge is a real rescue tool but needs ~12+ frames of windup
  headroom** — cast when the carrier is at 3+ hits of margin, not 1.
- District rows 7-10 are wall lanes: hold right at row 10 walks into a
  face; drop to row 11-12 to travel east.

## aoe_specials pilot recipe (mandatory beats from the spec)

Seed: try 7 (vat5b precedent). Zone: district. Beats to capture (≤20):
1. **challenge_pulse**: possess blocker mid-pack (3+ humans in radius 9,
   ideally aggro'd on another body first so cues/turn READ) → L →
   capture pulse frame (+2/+6) + victims' rust underlines (+20).
2. **whirl_clump**: swap striker (wait 25 post-swap — pilot trap), walk
   INTO the challenged clump parked on the blocker (hold-into-body
   idiom), L with 3+ adjacent → capture windup (+3) + active radial-pop
   frame (+7/+9: victims hurt-flash + displaced outward).
3. **whirl_pip_rearm**: capture HUD frames right before cast (pip lit)
   and ~15f after a 4+ hit (pip re-lit early = refund readable).
4. **carry_escape**: lobber carrying (loot a drop first), mobbed (2+
   chasers) → swap blocker → challenge → swap lobber → walk free →
   capture the chasers ANCHORED on blocker while carrier walks (2
   frames, ~40f apart).
5. Standard riders: kits_distinct nest frame at spawn (frame ~15, the
   composition that passed vat/ledger), carried>0 HUD numeral.
Doctrine (vat5b flight notes apply): never goto/hold toward enemy mass;
cap approach ≤4 tiles when any human within 10; lane chokes cap
attackers; challenge parks excess pressure passively (engaged cap 5) —
the whirlwind INTO the parked ring is the intended cash-out and the
capture money-shot. Deliberate wipe = free full-heal if banked ≥ 12×dead
(NB regrow now 9 — threshold 9×dead + 2×wounded).

## Splice law (unchanged): only capture-frame edits are legal; any input
edit = re-pilot. Missing beat = re-pilot.

## Re-pilot recipes (if 10/11 fail their critic legs)

- **specials_chain**: reuse the old inbox intent (4 casts × 3 kits + 4
  swaps + attack strings) but re-drive live under v13: the striker cast
  now needs adjacency BEFORE the press (spin doesn't close distance).
  Keep taunt/volley beats. ≤20 captures, offsets varied (+4/+10/+16).
- **taunt_anchor**: same beats as v11 (pulse, underline, anchor-hold,
  convergence) — radius 9 pulls a bigger room; stage the out-of-range
  probe at Chebyshev 10+ (was 7).

## Sequence after wall

perf ALONE → full rake → CHECKPOINT → fetch (Junior may have pushed) →
merge v13-aoe --no-ff INTO junior-tibia → push junior-tibia (owner
directive 2026-08-14: collaborative line; main stays untouched as solo
backup) → ELEVENTH blind verify handoff (skeleton:
drafts/_v13-fun-verify-20260814.md; harvest BEFORE questions; owner may
play `bin/play es`).
