# FIFTH fun-verify — fight ledger, loud presentation (2026-08-11)

Build: main @ merge `42b54d6` (ledger-presentation iteration; 7-gate wall green
with critic incl. `ledger_prominence`). Protocol: owner played via `! bin/play`
(unprimed on what changed), then the fight-ledger spec §fun-verify's 8 questions
VERBATIM via AskUserQuestion in two batches. Routing applied MECHANICALLY from
the pre-registration (spec §fun-verify + the v8 owner lock) — no re-derivation.

## Session telemetry (in-conversation, session end)

```
TELEMETRY d1_fired carrying_deaths=2 wipes=6 corpse_looted=1 carried_lost=1
banked_events=5 fights=15 recovery_fights=0 negative_fights=1
```

Every beat kind fired: ~15 fight beats, 6 wipe recaps, 5 bank tallies, 1
negative fight. Best exposure profile of any verify session — no threshold-bug
ambiguity, no zero-exposure questions except the loss line (n=1).

## The 8 answers

| Q | Question (short) | Answer |
|---|---|---|
| 1 | Wins: payoff or wallpaper? | **"Landed as a payoff"** |
| 2 | Losses: sting or nothing? | "Never saw a loss line" |
| 3 | **Chore oracle (FIFTH ask)** | **"Still a chore"** |
| 4 | Wipe recap: mission or same walk? | "The same walk" |
| 5 | Bank: banked to close the leg? | "Banked anyway — tally meant little" |
| 6 | Legibility escape-valve | "Some I couldn't read/understand" |
| 7 | Instrument oracle: miss them? | "Wouldn't notice" |
| 8 | Control: banked halved, care? | "Wouldn't care" |

## Validity: VALID as a meaning test (unlike round 1)

Q1 "landed as a payoff" is the FIRST positive signal in five verifies and
proves the instrument was SEEN and understood in the common case — the
presentation iteration did its job (visibility failure round 1 → payoff round
2). Q6's partial flag ("some") quarantines only the AFFECTED tallies (spec
wording), not the verdict: the plausible "some" are the single loss line
(negative_fights=1; Q2 says it never registered — likely the same event), the
pip-vs-dark loss distinction, and/or the bank reconciliation's extra lines (Q5
"meant little"). Recorded as a polish signal, NOT a re-route: v8 made this
presentation pass the last one, and the research contingency was reserved for
couldn't-read-AGAIN-as-verdict-blocker, which did not happen.

## Routing (pre-registered, applied clause by clause)

1. **Q3 "still a chore" on a VISIBLE ledger → A2 PROMOTES AUTOMATICALLY.**
   The v8 owner lock fires exactly as written (owner pre-authorized
   2026-08-11; no new scope debate). This supersedes the 2026-08-10 demotion.
2. **Ledger disposition: STAYS through A2.** Q1/Q2/Q5/Q7 clause: "any real
   signal (Q7 yes, or Q1/Q2/Q5 any positive) → the ledger STAYS." Q1 is a
   clear positive. (Q7 "wouldn't notice" alone would have removed it only
   with zero positives.)
3. **Q4 "same walk"** — pre-registered CONSISTENT with LB-1's limits; feeds
   A2's case (a number at second 3 does not fix minute 2; threat's territory).
4. **Q8 "wouldn't care"** — control unchanged (fourth consecutive reading);
   the pile still isn't valued, which is D1b/A2 territory, not the control's.
5. **Economy stays parked in ALL branches** (D1b, spending banked).

## The experiment's answer: LB-1 REFUTED

LB-1 asked: does making each fight's outcome legible give the pile meaning,
without new threat and without new economy? **No.** The tally lands as a
moment-payoff (Q1) and still creates zero meaning: the bank decision is
unchanged (Q3), the run back is unchanged (Q4), the reconciliation doesn't
drive banking (Q5), the instrument wouldn't be missed (Q7), the pile wouldn't
be mourned (Q8). Chain now complete and clean, one variable at a time:
**drama (D1) → no; legibility (ledger) → no; the remaining lever is
consequence — A2 threat/pull economy.** This also confirms the owner's
mid-session design read (the arcade question): a number with no
world-consequence is score, however well it is presented.

## Behavioral evidence (recorded, not verdict input)

- **banked_events=5 — the first voluntary banks in ANY verify session** (0
  across both round-1 sessions). corpse_looted=1 (also a first). Self-report
  says the decision is unchanged; behavior shows more loop engagement. Session
  lengths differ across rounds — do not over-read; A2's verify should watch
  whether this holds.
- Q2/Q6 overlap: one negative fight fired, owner never saw its loss line —
  with n=1 this is attention or the loss line's salience; watch at A2.

## Next session (in order — none of it in this verdict session)

1. **Scope contract → v9 in CLAUDE.md FIRST** (A2 threat/pull economy IN;
   everything else stays parked; ledger recorded as STAYS).
2. A2 brainstorm, folding in: PARKING_LOT A2 shape notes (owner's per-human
   threat-accumulator vs the original pull-density shape — reconcile at
   promotion; leash-with-no-heal, gate beachhead, chaser cap), aggro soft-cap
   8-12 + density costs, tank-first possession feedback, and the corpus
   caveat (zero touchstone evidence for aggro systems — defend A2 from
   game-two's own diagnosed problems, not citations).
3. Spec → plan → implement → wall → SIXTH fun-verify.
