# Regrow-cadence investigation (v14 lane e — DOC ONLY, no numeric ship)

Status: analysis for the v15 debate. Authorized by the v14 scope contract
("regrow-CADENCE design investigation — the pricing dose is a recorded
negative result"). Zero code, zero data changes ride this doc.

## The evidence chain (two verifies + one failed dose)

**Tenth verify (v12, drafts/_v12-fun-verify-20260813.md):**
q6_margins `banks{n=19 pure=0} amount{mean=58 max=144} hp{mean=0.41}
dead{mean=1.3} wounded{mean=1.7} gap{mean_s=83}`; 21 tributes, 402 banked
spent on tribute. Owner Q5: money moved ("for something") but trips still
too often. Routing named the lever family: maintenance economics
(tribute/inscribe pricing + regrow cadence), NOT trip distance.

**The pricing dose (v13):** `regrow_cost` 12→9 (dead-body price, the
dominant mandatory-spend term). Pre-registered gap arbiter: gap up = dose
worked; gap down + "still too often" = backfired.

**Eleventh verify (v13, drafts/_v13-fun-verify-20260814.md):**
q6_margins `banks{n=11 pure=0} amount{mean=33 max=67} hp{mean=0.36}
dead{mean=1.1} wounded{mean=1.6} gap{mean_s=47}`; 11 tributes, 144 spent.
Owner Q5 verbatim: "PARA algo, viajes aún frecuentes". **Gap 83→47 s +
trips-still-often = the arbiter fired: DOSE BACKFIRED.** Reverted same
session (`52314c9`, regrow_cost back to 12).

## What the data actually says

1. **pure=0 across 30 consecutive banks (19+11).** Not one trip in two
   full sessions was a pure deposit. Every single bank visit happened
   with dead (mean ~1.2) and/or wounded (mean ~1.65) bodies in tow. The
   player does not bank when pockets are full — he banks when the PACK
   DEGRADES. Trip cadence is attrition cadence.
2. **Price gates trips DOWNWARD, not upward.** Maintenance is
   player-triggered: a cheaper tribute lowered the affordability
   threshold, so trips became MORE frequent (47 s gaps), not less. The
   two-sided risk the v13 spec pre-registered is exactly what happened.
   Conclusion, now recorded twice: **pricing is the wrong lever family
   for cadence.** Do not propose a third pricing dose.
3. **The wounded term is a constant background tax.** wounded{mean 1.6-1.7}
   at essentially every bank, at 2/body — small money, but it makes every
   return trip *also* a maintenance stop, which trains the habit loop
   "come home = pay". The dead term (~1.2 × 12) is the felt price; the
   wounded term is the metronome.
4. **v13's challenge already cut the attrition INPUT** (carrying_deaths
   21→2), and gaps still compressed when price dropped — more evidence
   that trip frequency tracks affordability + habit, not raw attrition
   volume alone.

## Cadence levers for the v15 debate (design changes, owner decides)

Ranked by dev preference. All change WHEN maintenance happens, not what
it costs — the recorded-negative pricing family is excluded.

- **L1 — Regrow-over-time at the vat (tribute = haste).** A dead body
  regrows FREE after a long timer anchored at the home vat; the tribute
  price buys "now" instead of "eventually". The trip stops being
  mandatory for regrowth (fighting shorthanded for the timer IS the
  cost); banking decouples from maintenance, so gap starts measuring
  greed-vs-fear again. Fiction-legal (the vat grows flesh; growth takes
  time; tribute hurries the gods). Risk to debate: removes a banked sink
  → surplus inflation; seal/inscribe pricing may need to absorb it.
  Touchstone: Tibia's time-based regen economy; the corpse-term grammar
  the game already teaches (clocks on containers).
- **L2 — Passive out-of-combat mend for WOUNDED bodies only.** Slow
  regen to full outside combat; the heal_cost_per_body term (the
  metronome) disappears; death stays priced. Cheapest change, directly
  attacks finding 3. Risk: mild difficulty softening (sustained-fight
  attrition unchanged, between-fight attrition gone) — needs the owner's
  difficulty-pin waiver to even reach the table.
- **L3 — Batch gate at the vat.** The vat refuses (or steeply discounts)
  service below a threshold (e.g. 2+ dead or pack HP under half) —
  mechanically enforces consolidated trips, gap widens by construction.
  Bluntest instrument; risks feeling arbitrary ("why won't it take my
  money"); fiction cover is thin. Include for completeness.
- **L0 — Do nothing (real option).** v14's Q5 re-read runs with the dose
  REVERTED (regrow 12 restored). If the twelfth reads "rhythm okay", the
  complaint may have been the dose itself + v13's attrition spike, and
  this lane CLOSES with no lever shipped.

## Pre-registered reading for the twelfth (Q5)

- "Rhythm okay / trips fine" → **lane closes**, L0 wins, nothing ships.
- "Still too often" + q6_margins pure=0 again → bring L1 (lead) and L2
  to the v15 debate as design forks; L3 stays the fallback.
- Any answer + pure>0 appearing → new information (greed trips exist
  now); re-read this doc's premise before proposing anything.
