# D1 fun-verify — owner verdict (2026-08-11)

Session telemetry (bin/play, read off the launch shell at close):
`TELEMETRY d1_fired carrying_deaths=2 wipes=2 corpse_looted=2 carried_lost=0 banked_events=1`
The system FIRED — no N/A branch. Both piles recovered, nothing expired, one bank.

## Answers (verbatim option picks, AskUserQuestion 2026-08-11)

| Q | Question (short) | Answer |
|---|---|---|
| 1 | Settling corpse: tense or standing in line? | **Standing in line** |
| 2a | Run back dangerous — could you have lost it? | **In between** (contact, never in doubt) |
| 2b | Run back long enough to dread? | **Too long / tedious** |
| 3 | Did "bank or push deeper" change? (3rd ask) | **Still a chore** |
| 4 | Banked? Would halving the number hurt? | **Banked, wouldn't care** |
| 5 | Corpse clock ever influence a decision? | **Never noticed** |
| 6 | Deliberate convenience death/wipe? | **No** |

## Routing (per the spec's pre-registered attribution)

- **Primary: the pile lacks meaning — D1b / ledger route.** Q4 is the spec's own
  routing clause verbatim: "a didn't-bank / wouldn't-care routes the failure to
  D1b/the ledger — the pile itself lacks meaning — not to the corpse run." Q3's
  third "still a chore" is the same signal: drama cannot price a stake the player
  doesn't value.
- **Secondary: combat threat doesn't contest the corpse.** Q1 standing-in-line +
  Q2a in-between + telemetry 2/2 recoveries with 0 losses = the settle window and
  the run back are never actually threatened. The spec predicted this exact
  attribution (FN-1); it now has data. NB the owner demoted A2 (threat) as "an
  extra for later" — this is the second fun-verify pointing the other way.
- **Q2b "too long / tedious" is length WITHOUT danger, not length.** Dread needs
  threat; absent it, travel time converts to tedium. Couples with the secondary
  route — do not read it as "shrink the map" (A3) in isolation.
- **Q5 never-noticed = term-tuning signal, recorded, NOT actioned.** No measured
  margins exist from this session (bin/play logs counts only). Term stays 5400
  until measured `wipe_to_last_loot_s` / margin data exists (spec: never by feel).
- **Q6 no — watch-list items (suicide fast-travel, grace-refresh, dying-breath
  refresh) stay dormant.**

## Experimental result (DS-1, the inversion owned by the spec)

D1's question was: does drama ALONE move the chore verdict? **Answer: no.**
Clean result — the corpse run works mechanically and reads visually, but with a
valueless pile and uncontesting threat there is no tension to dramatize.

## Next-increment candidates (dev-of-record reading)

1. **Post-fight ledger** (pre-queued candidate; Q4's route) — make gains/losses
   legible and felt at the moment they happen. Cheapest probe of "the pile lacks
   meaning" before reaching for economy mechanics.
2. **Threat** (Q1/Q2a/Q2b route) — owner demoted A2; the data now argues back.
   Owner's call to re-promote; the evidence is on file either way.
3. **D1b fees** — NOT yet: its trigger (banking collapse / corpse-as-bank abuse,
   Q6-style exploits) did not fire.
