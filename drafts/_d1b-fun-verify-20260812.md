# SEVENTH fun-verify — D1b vat economy (2026-08-12, post-merge 402ba1c)

Owner played bin/play (play-first law held: build launched, session
completed, telemetry harvested from the session log BEFORE any question).
Answers collected via AskUserQuestion in two batches, spec §Fun-verify
verbatim.

## Telemetry (ground truth, harvested from the session log)

```
TELEMETRY d1_fired  carrying_deaths=0 wipes=0 corpse_looted=0 carried_lost=0
                    banked_events=3 fights=5 recovery_fights=0 negative_fights=0
TELEMETRY a2_fired  wipes=0 body_deaths=2 retargets{hate=9 lowhp=0 proximity=2
                    acquired=34} leashes=0 deepest_band=2 banked=3
TELEMETRY d1b_fired inscriptions=1 marks_consumed=0 dissolved=0 regrown=2
                    tributes=3 floor_fired=0 banked_spent{inscribe=8 tribute=36}
                    banked_end=23
```

Both sinks FIRED (1 inscription + 3 tributes). Never wiped → judgment and
floor unexercised (preamble applied: not negative).

## Verdict — D1b VALID. Q1 (the meaning question) MOVED on the SEVENTH ask.

| Q | Answer | Read |
|---|---|---|
| Q1 meaning (headline) | **"It moved — I'd care"** | FIRST positive in seven asks. Banked matters; spends were real decisions. |
| Q2 pact | "A bet — push felt different" | Inscribing changed the push. Caveat: mark never judged (no wipe) — the bet was placed, never cashed. |
| Q3 judgment | UNEXERCISED | wipes=0, marks_consumed=0. |
| Q4 floor | UNEXERCISED | floor_fired=0. |
| Q5 hunt length | **"Moved — hunts run longer"** | The owner's own complaint (no healing → hunts end early → repetitive) RESOLVED by priced flesh. |
| Q6 dilemma (Q3 rerun) | **"Collapsed: always-bank"** | REGRESSED. Banking constantly to afford tribute/marks; push-deeper side lost. |
| Q7 fairness valve | "Better, not fixed" | Some switches read, others still arbitrary. Cue itself not misreading. |
| Q8 price feel | "Prices felt right" | No per-unit price complaint — the Q6 collapse is cadence, not cost. |
| Entrainment probe | Flat | Same as sixth verify. No somatic tell (but also no wipe/thin-stretch of A2 severity). |

## Pre-registered routing APPLIED (spec §Fun-verify, verbatim — three lines fired)

1. **Q1 moved → D1b WINS; next increment = scope debate.** The Challenger
   is the standing queued candidate (trigger MET + RECORDED at the sixth
   verify) — promotion remains the owner's explicit call at that debate.
2. **Q6 REGRESSED → economy retune with the dilemma as the oracle; the A2
   threat layer is NOT touched** (it verified). Data-only (economy.json).
3. **Q7 unmoved-ish → threshold iteration continues (data); cue redesign
   stays parked** — owner says the cue reads, the frequency/threshold is
   what's left.

## Retune observation (recorded for the retune session, NOT designed here)

Q8 "prices felt right" + Q6 "always-bank" together say the collapse is not
a unit-price bug: carried counts for nothing until banked, and tribute
gives a STANDING reason to convert early and often — the deeper-push side
of the dilemma pays in a currency you now always want liquid. The dilemma
oracle for the retune: a fix must make holding carried in the field worth
something again WITHOUT touching A2 threat or adding scope. Telemetry
cadence this session: banked 3 times in 5 fights.

## Tension worth carrying into the scope debate

Q2 answered "a bet" but the bet never resolved (no wipe all session, and
Q5 says hunts run longer = fewer wipes structurally). The judgment — the
system D1b exists to make wipes meaningful — fires RARELY in the new
equilibrium. Cheap-wipe → priced-wipe worked so well the priced part is
almost never exercised. Not a defect; a thing the next increment should
know.
