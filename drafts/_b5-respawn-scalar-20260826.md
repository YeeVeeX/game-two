# B5 — respawn scalar stage 1 (`respawn_delay_scale` 2.0 → 3.0) — SHIPPED s79 (2026-08-26)

Foundation row 10, RATIFIED-G + RATIFIED-J at the v19 foundation
(`drafts/_v19-foundation-20260822.md` §Lane 2: "stage 1 = ONE
`coop.json` scalar + data-only re-session (pre-registered shape);
presence-block respawn RECORDED as the stage-2 structural candidate
if the scalar doesn't kill the complaint"). Owner picked B5 live in
the hub chat s79 ("B5") from the surfaced candidate slate — the last
Lane-2 data move before the eighteenth ritual stages. Source
complaint: R-A1 (v18 fun-verify verdict §row 3) — Junior, live
DURING ritual session 1, with the 2.0 scale already active: **"the
enemies spawn too fast"**; Gabriel's direct P2 answer banked beside
it, not averaged: "la verdad no lo noté o no le puse atención".

## Pre-registered shape — walked verbatim

1. **Corpus brief §2 read FIRST**
   (`docs/design-corpus/gamesmith/addenda/corpus-to-v18-evidence-brief-20260819.md`):
   supports pricing failed attempts in supplies + walk-back time and
   a retry loop paced by prep windows (OSRS prep cycles ~1.5–2 min);
   explicitly **cannot settle** game-two's per-seat numbers — "the
   SIXTEENTH's telemetry is the declared baseline; numbers close at
   spec". Baseline banked below.
2. **ONE scalar** — `data/balance/coop.json` seats=2
   `respawn_delay_scale` 2.0 → 3.0. Nothing else moves (the other
   two seats=2 knobs are C2's re-session, recorded order B5→C2).
3. **Suite via hooks + `rake perf`** — evidence below.
4. **No visual surface moves → no wall debt, no Rule 2 gate** —
   critic calls this ticket: 0 (declared at start; no visual delta).

## Baseline telemetry (SIXTEENTH/SEVENTEENTH — stays the oracle)

- s1: `arrivals{pocket=88 seed=28 home=0}` over 74469 ticks ·
  `density pockets{mean=3.7 max=17}` — one respawn release ≈ every
  642 ticks (~10.7 s), 76% rejoining the pocket the pack fights.
- s2: `arrivals{pocket=83 seed=5}` over 36079 ticks — one release ≈
  every 410 ticks (~6.8 s), **94% pocket joins**.
- Verdict forensics note carried: tick-lock protects the "too fast"
  reading from lag inflation (stalls make spawns SLOWER in wall
  time, never faster).

## Shape picks (dev of record)

1. **The scalar buys PHASE LAG, not rate.** In steady state every
   kill schedules exactly one echo (`schedule_human_respawn`,
   world.rb:1652, decision-11 schedule-time law) — total
   arrivals/hour is population-conserving, so the knob's real
   purchase is the CLEAR WINDOW: how long a cleared pocket stays
   clear before the echoes walk back in. The complaint is exactly
   that texture (94% of respawns rejoined the fight ~10 s after
   dying). 3.0 stretches the per-kit echo 10 s → 15 s on the base
   300-frame kits (rusher/rusher_hater/husk — the only kits carrying
   `respawn_frames` besides the pack's own 90).
2. **3.0, not 4.0.** The 1.0→2.0 move "moved the needle without
   closing the gap" — but s68's difficulty tier has ALSO moved coop
   pressure since the complaint, unmeasured. Compounding two
   aggressive same-direction moves risks overshooting into an empty
   district (the hunt sustains because the ground refills — Tibia
   touchstone; shelf: hunts should end by exhaustion/choice, not
   starvation). +50% (clearly above duration-JND) on a legible
   ladder — 1.0 → 2.0 → 3.0, each step = +5 s wall-clock — is the
   decisive-but-single step. If the eighteenth ritual says the
   complaint survives 3.0, **stage 2 = presence-block respawn** is
   already the recorded structural candidate; the scalar does not
   have to carry the whole fix.
3. **Solo untouched by construction.** seats=1 has no coop block →
   `@coop` nil → the arithmetic never evaluates (suite-pinned).
   Owner's s67 solo session read "me gustó mucho" — solo pacing was
   never the complaint. The whole single-player wall + canaries are
   therefore replay-byte-inert to this change.
4. **Netplay gates not owed here** (they are owed at C2, the CODE
   change): a data scalar cannot split lockstep — both seats decode
   the same committed JSON, and the v17 handshake refuses mismatched
   builds before a tick runs.

## Evidence

- Suite **1275 runs / 22805 assertions / 0F** green post-change
  (`tmp/s79_b5_suite.log`); `coop_feel_test` contract pins hold by
  design — the floor pin (`> 1.0`, "walk-back relief scales UP") and
  the decision-11 schedule-time test compute expected values FROM the
  data file (Rule 3: no balance constant in code to chase).
- `rake perf` **PASS**: `ticks=6990 p50=0.398ms p95=0.614ms
  max=3.981ms zone=district` (`tmp/s79_b5_perf.log`) — schedule-time
  multiply, zero hot-path cost.
- Consumers audit: `respawn_delay_scale` has exactly one read site
  (world.rb:1652); the other `@coop` reads (`human_hp_scale`,
  `ally_flee_hp_pct`) untouched.

## Re-measure (the data-only re-session's second half)

The eighteenth ritual is the oracle — respawn is one of the four sim
numbers it freezes at staging; this move lands BEFORE staging
exactly so the ritual measures it (foundation sequencing law: "the
ritual re-freezes what it measures"). Any earlier coop session gives
an informal read only — bot/soak logs are never fun-evidence. With
B5 landed, **C2's re-session is sequence-unblocked** (B5→C2 order
satisfied).

## Field notes

- Junior async ratification of the SHIP (not the shape — the shape
  was foundation-ratified) travels with tonight's ledger.
- The assets-seat v27 re-pin mail (s79 inbox, approve-by-default,
  handled) flagged the E3a capture-contract spec as still un-mailed
  — fifth consecutive empty close on their side. E3a is now
  sequence-unblocked (all four lanes have first ships); surfaced to
  the owner as the honest second pick this session. Their armed
  review lane branches on arrival — no reply owed meanwhile.
