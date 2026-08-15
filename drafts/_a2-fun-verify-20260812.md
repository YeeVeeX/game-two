# SIXTH fun-verify — A2 threat/pull economy (2026-08-12)

Build: merge `e3759c3` (A2 shipped; wall 8/8+8/8, impl review clean). Owner played one
session via bin/play launched from the harness session (telemetry captured directly from
the process stdout — no paste step).

**VERDICT: VALID — and Q3 MOVED on the SIXTH ask. A2 WINS.**
First positive chore answer in six verifies. Pre-registered routing applied verbatim below.

## Protocol note (on the record)

One AskUserQuestion batch was fired BEFORE the owner had played the new build (my error —
play-first is the protocol). Owner caught it ("let me play the game first"); those four
answers were DISCARDED unbanked. Everything below is post-play.

## Telemetry (banked first, from the session process)

```
TELEMETRY d1_fired carrying_deaths=1 wipes=1 corpse_looted=0 carried_lost=0 banked_events=3 fights=5 recovery_fights=0 negative_fights=1
TELEMETRY a2_fired wipes=1 body_deaths=3 retargets{hate=2 lowhp=11 proximity=1 acquired=14} leashes=2 deepest_band=0 banked=3
```

Behavioral reads: **banked_events=3** (5 in verify #5, 0 in #1-4 — voluntary banking is now
habitual); **wipes=1** in a full session (vs the 6-8 arcade-lives baseline — the cadence
goal landed); 5 fights, 1 negative; a carrying death whose pile was NEVER recovered
(corpse_looted=0, carried_lost=0 — still stranded at session end: recoveries are no longer
free, and this one was abandoned); leashes=2; retargets show the intelligence layer firing
(11 lowhp switches, 2 hater beelines, 1 proximity steal).

⚠️ `deepest_band=0` is an ARTIFACT: the band converts at summary time against the CURRENT
zone's gradient, and the owner quit from the nest (after banking) where drop_gradient=nil.
hate=2 proves at least mid-band play (haters spawn at [22,18]+). This is the residual arm
of the impl-review's refuted finding — refuted as "trivially narrow," but quitting from the
nest after banking is the NATURAL session end, so it fired first try. Fix candidate
(bundle with next sim change): convert the band at kill/drop time, not summary time.

## The eight answers (verbatim questions, spec §Fun-verify)

| Q | Answer | Read |
|---|--------|------|
| Q1 pull sizing | "Sometimes, only deep" | Partial — near the gate pulls still just happen; deep, sizing became a choice. Confirms depth reached. |
| Q2 the box | **"Felt it — and ran"** | THREAT FELT — the encirclement changed behavior. |
| Q3 the chore (SIXTH ask) | **"It changed — real dilemma"** | **MOVED.** First time in six verifies. |
| Q4 run-back | **"In doubt at least once"** | Corridor contested — recovery no longer free (telemetry agrees: one pile abandoned). |
| Q5 wipe weight + entrainment | "Rarer, no body reaction" | Cadence landed (1 wipe); entrainment probe NEGATIVE — no physical peak. |
| Q6 fairness valve | "Read as randomness" | NEGATIVE — retargets not legible as intent. Tuning signal (below). |
| Q7 breather | "Real option, felt fair" | Leash-with-no-heal landed as designed. |
| Q8 carryover control | "Still wouldn't care" | Banked number still pure score — meaning still awaits D1b. |

## Owner free-text (same session)

1. **"feels good"** — overall positive.
2. **"team still doesn't have a healing mechanic so hunts don't last too long, it turns
   repetitive after a while"** — sustain absence caps hunt length. This is direct owner
   evidence for the parked economy layer (priced sustain / "what does the pile buy") —
   feeds the next scope debate, NOT code now.
3. **BUG — held-Shift dodge locks movement.** Root cause found (controllers.rb:33-37):
   dodge is level-triggered in PlayerController#tick; while Shift is held the dodge branch
   swallows every tick (cooldown-refused) and the `elsif` walk branch never runs — the
   character only moves during the periodic successful dashes. One-line fix (edge-trigger
   dodge or fall through to step on refusal) but it CHANGES INPUT SEMANTICS → invalidates
   all 8 replay streams. Bundle with the next sim increment (the tank-first lesson).

## Routing (pre-registered in the spec — applied, not re-derived)

- **Q3 MOVED → A2 WINS.** Ledger disposition already locked: STAYS. Next increment is a
  SCOPE DEBATE with D1b-inscription as the queued candidate (inscription-within-ritual,
  PARKING_LOT outcomes; session-only persistence first).
- **Q6 "randomness" → margin/threshold tuning signal, RECORDED** (per spec: degrades
  fairness, does not quarantine Q3). Candidates: proximity_switch_margin_tiles,
  lowhp_switch_pct — data-only, and the retarget-cause telemetry exists precisely to make
  switches explainable; a presentation cue for WHY a human turned is a legitimate polish
  candidate for the scope debate.
- **Q5 threat-felt-but-no-scary-peaks → the Challenger trigger condition is MET and
  RECORDED** (Q2/Q4 positive + entrainment flat). Per the spec/R6: a trigger firing records
  the condition for that future increment — it does NOT promote now.
- Q8 unchanged + banking healthy (3 banks, no collapse) → D1b's own emergency trigger did
  not fire; D1b arrives via the primary route above instead.
- Owner evidence #2 (sustain caps hunts) → scope-debate input alongside D1b-inscription.

## Next session

Scope debate (v10): D1b-inscription is the queued candidate; agenda items on the table —
dodge bug fix (bundles with any sim change), deepest_band at-kill fix (same bundle), Q6
legibility tuning (data + maybe a retarget cue), sustain/hunt-length evidence, Challenger
trigger on record. NO code before the debate closes.
