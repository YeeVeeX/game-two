# EIGHTH fun-verify — v10.1 Q6 retune (2026-08-12, post-merge ba4e0ad)

BLIND verify held: the owner played bin/play with NO changelog in the handoff
(the depth premium had to be felt, not announced). Questions via
AskUserQuestion, two batches, plan §Task 7 verbatim.

## ⚠ Telemetry LOST (dev error, on record)

The session's TELEMETRY lines (incl. the first real q6_cadence data) were
destroyed by a double-launch: two `bin/play` processes redirected to the SAME
log file; the unplayed second window's all-zeros summary clobbered the played
session's output. Lesson: unique log per launch (`/tmp/game_two_session_$$.log`),
and never relaunch while a session window is open. The verdict below is from
FELT answers only; the q6_cadence integration proof stands on the replay
evidence (line fires end-to-end in the wall gates: banks{n=4 mean=15 max=32}
kills_by_band{b0=12 b1=18 b2=6}).

## Verdict table

| Q | Answer | Read |
|---|---|---|
| Q6 dilemma (HEADLINE) | **"Still always-bank"** | COLLAPSED — the 3.5× premium did NOT restore the dilemma. |
| Depth premium | **"No — uniform"** | Kills nowhere felt richer. The premium exists in numbers (rolls [4,4,7] vs [1,1,2]) but did not READ as place. |
| Q7 cue | **"Still arbitrary"** | REGRESSED from "better, not fixed" despite 45→75 frames — read-time was not the lever; the cue itself misreads. |
| Q1 GUARD | **"Money got easy"** | REGRESSED — the inflation risk written into decision D1 fired. |
| Q5 GUARD | **"Back to the nest too often"** | REGRESSED from the seventh verify's "hunts run longer" win. |
| Judgment | Never wiped | Unexercised (preamble applied: not negative). |
| Entrainment | **Flat** | THIRD consecutive flat — the Challenger's recorded trigger, third confirmation. |

Free-form (verbatim, same session): "yeah I played it, feels good, now it
needs more purpose in the gameplay for the user/player, move or advance
toward something, progress, leveling, equipment, new enemies and zones,
lore, cities" — moment-to-moment positive; the named gap is an ARC/macro
purpose, not the second-to-second feel.

## Dev-of-record causal read (working hypothesis — telemetry gone, marked as inference)

"Money got easy" is only explicable if deep kills happened (band-2 pay is the
ONLY income change), yet depth felt "uniform" — so the premium was EARNED but
not ATTRIBUTED. An unfelt premium doesn't just fail to create pull; it
degrades into inflation: richer without knowing why → banked cheapens → Q1
regresses → tribute always affordable → more nest trips ride free → Q5
regresses → banking stays the reflex → Q6 stays collapsed. One story fits
all four negatives. The premium's failure is LEGIBILITY-first (drop digits
and pips announce nothing about place), with the structural collapse
(bank/altar/vat share one room; banking rides every heal trip free)
underneath it, unfalsified.

## Pre-registered routing APPLIED (plan §Task 7 table, verbatim)

1. **Q6 still collapsed** → the telemetry fork (deep-kill share UP vs
   UNCHANGED) is UNRESOLVABLE this session (telemetry lost). BOTH branch
   consequences carry to the debate, honestly labeled: the legibility
   candidate (drop/pickup presentation — supported by the felt evidence
   above) AND the mechanism candidates (banking rides heal trips free —
   structural; never unilaterally to code).
2. **Q7 still arbitrary** → "cue redesign opens as its own presentation
   item" (the read-time bump exhausted the threshold/timing lane; two
   passes have not moved it).
3. **Entrainment flat again** → third consecutive flat — strengthens the
   Challenger case at the debate (its recorded trigger).
4. NOT in the table (recorded as new evidence, not a route): Q1+Q5 guard
   regressions put the 3.5 VALUE itself in question — trim (≥3.0 floor per
   the shape-law test) or revert are debate options; the premium SHAPE law
   (strictly increasing gradient) stands either way.

## Post-questions owner evidence (same session, verbatim)

"only on the first pull (when the game starts) there are a good amount of
enemies, but then the respawns are just a smaller part of the enemies and
too easy to clean up. game gets boring and stale after a few rounds, but
the core system and combat feels good for now."

**Code-grounded diagnosis (verified in src/game/world.rb:995-1003, 852-870 +
data):** kills schedule 1:1 respawns at +300 frames (5 s, combat.json), each
at the kit's nearest HOME spawn tile; `respawn_block_tiles: 12` (threat.json)
defers any respawn near the pack. Net: the opening walk-in masses all 15
district humans once (unrepeatable peak); steady state delivers scattered
SINGLES walking back from home tiles — count conserved, CLUMPING decays.
"Too easy to clean up" is the 1-vs-1 trickle. This is upstream of the
verify's failures: a thinned field ends hunts early (Q5), prevents sustained
deep pushes (depth "uniform", Q6), makes cleanup income free (Q1), and never
re-masses a scary group (entrainment flat). Candidate shape belongs to the
debate (density/re-massing is threat-adjacent — A2's own shape notes said
"respawns walk back toward the last fight").

## Status of v10.1

The build is technically sound (wall 9/9+9/9, perf p95 0.224 ms, suite
green) and the oracle it was built to move did not move. The retune is a
recorded negative result: one number was not the lever. Per the scope
contract, nothing new starts without the debate — which this verdict routes
to directly.
