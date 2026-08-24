# Striker dash-strike — kit-identity decision + ship record (s66)

**Owner order (live in chat, 2026-08-24):** "el ataque de la E/L del
striker se podrá hacer que abarque más área? Debe diferenciarse del
tank" → fork presented (A: honest-ring now + dash spec later · B: dash
now · C: bigger ring) → owner: **"procede con ambos el dash strike
tambien"** — both shipped this session. Junior async-ratifies (peer
law; he was at lunch — flag in the checkpoint).

## The identity argument (reference wall)

- Session data (their own coop S1): `whirl{casts=11 hits{1=3 2=2 5plus=2}}`
  — the ring rarely caught clumps; the refund identity never expressed.
- Touchstone (game-research shelf, Tibia combat differentiation): big
  AoE belongs to the artillery class — a 5×5 striker ring would eat the
  LOBBER's identity, not fix the blocker overlap. Refused (option C).
- Final grammar: **striker CUTS THROUGH (dash line, mobile, iframes) ·
  blocker PLANTS (ring + taunt + stagger) · lobber BOMBARDS (ranged
  volley line)** — three verbs the eye can tell apart (Vlambeer:
  aggression reads as motion).

## What shipped

- `combat.json` striker special: `arc dash, max_tiles 3,
  frames_per_tile 6, damage 30, exhaust 480, refund 120, kb 0`
  (damage/exhaust/refund UNCHANGED — shape moved, numbers didn't;
  windup 6 kept, recovery 8 kept). Engine dash machinery pre-existed
  (v13 era: plan/commit/iframes/digest rows) — data flip + one law fix.
- **The struck law** (found live in pilot run 1 — the dash whiffed the
  everyday case): `plan_dash` movement truncates at the last FREE tile,
  so a body PAST your landing stopped the feet AND the blade — enemy
  dead ahead with no free tile beyond = whiff into its face.
  `DashPlan` gains `struck` = the full scan line; `action_tiles` serves
  struck for damage; crossed/landing stay the movement (dodge/knockback
  untouched). Composes with covers? (pack-burst occupancy, `bec0398`).
- Tests: whirlwind_test rewritten as the dash spec (14 tests — v13
  refund law carried WHOLE: scales/floors/interrupt-refunds-nothing;
  iframes in flight, windup interruptible, wall truncation, blocked
  refusal burns nothing, stop-short strike, off-line spared);
  grid_walker struck tests; audio staging → line.

## Evidence

- Pilot session (seed 4242, district): run 1 exposed the whiff (state
  polls: rusher0 covering the last scan tile, hp untouched, striker
  landed short). Fix, then run 2 — same deterministic staging — struck
  the mover: captures `captures/pilot/dashcap2_r1/frame_0223_windup_full_line.png`
  (3 telegraph tiles incl. the occupied one — run 1 showed only 2),
  `frame_0228_flight_strike.png` (hit flash mid-rip), `frame_0238_landing_short.png`
  (feet at last free tile, kill site past).
- Wall script #27: `harness/scripts/dash_strike_rip.json` (pilot
  export) — **GATE PASS** (3 captures byte-identical ×2, vision green).
  The striker special finally owns a wall surface (recorded gap from
  the volley ship closes for the striker; the varekka re-cut ticket
  still owes the LOBBER its volley script).
- Canary: UNMOVED (suite green incl. canary — pinned replays cast no
  striker special; coverage gap noted above).
- Full suite: 1186/0F pre-gate; hook re-runs at commit.

## Balance note (measurement hygiene)

Damage/exhaust/refund/windup byte-identical to the ring version; the
only new numbers are GEOMETRY (3 tiles × 6 f/t travel). Difficulty
family: the special now lands where it visibly should (same class as
the volley call — completing designed intent, not tuning). Ritual
instruments stay virgin.
