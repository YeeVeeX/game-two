# Fight-ledger fun-verify — verdict + routing (2026-08-11)

Build: main @ merge `677b2ac` (+ checkpoint/parking commits). Protocol: spec
`2026-08-11-fight-ledger-design.md` §Fun-verify — 8 questions VERBATIM via
AskUserQuestion, two batches, pre-registered routing locked with scope v8.

## Sessions played (telemetry, measured in-conversation)

- Session 1 (too thin — questions deliberately NOT asked on it):
  `TELEMETRY d1_fired carrying_deaths=1 wipes=0 corpse_looted=0 carried_lost=0
  banked_events=0 fights=1 recovery_fights=0 negative_fights=0`
- Session 2 (questions asked on this one):
  `TELEMETRY d1_fired carrying_deaths=1 wipes=2 corpse_looted=0 carried_lost=0
  banked_events=0 fights=3 recovery_fights=0 negative_fights=1`

The system FIRED (no threshold bug): 4 fights total, 1 negative fight (loss-line
beat printed), 2 wipes (recap printed over the veil twice). Never fired for the
owner: redemption beat (corpse_looted=0 both sessions) and bank tally
(banked_events=0 both sessions) — Q5 is a ZERO-EXPOSURE reading by construction;
impl-review finding 2 (cross-leg bank beats) is therefore moot for this round.

## The 8 answers (owner, AskUserQuestion, two batches)

| Q | Question (short) | Answer |
|---|---|---|
| Q1 | wins: payoff or wallpaper? | **Never noticed one** |
| Q2 | losses: sting or nothing? | **Never saw a loss line** |
| Q3 | chore (FOURTH ask): bank-or-push changed? | **Not sure / didn't register** |
| Q4 | wipe recap vs D1's walk? | **Didn't notice the recap** |
| Q5 | bank tally meaning? | **Never banked** (zero exposure) |
| Q6 | legibility escape-valve | **Never saw any of it** |
| Q7 | instrument oracle: notice + miss? | **Wouldn't notice** |
| Q8 | control: banked halved, care? | **No, wouldn't care** |

## VERDICT (per the locked routing — not re-derived)

**INVALID AS A MEANING TEST — total visibility failure. Q6's escape-valve fires
at maximum strength: the owner never perceived the instrument existing.**

Routing application, clause by clause:

1. **Q6 quarantine (spec: "a badly built beat must not masquerade as a meaning
   result"):** Q6 = "never saw any of it" quarantines Q1, Q2, Q4, Q5, Q7 — all
   five are readings of an instrument that never reached the player's eyes.
   → **Presentation iteration FIRST; the meaning verdict WAITS.**
2. **Q3 (the A2 promotion oracle):** answer is "not sure / didn't register",
   NOT "still a chore" — the auto-promotion trigger did NOT fire. And under the
   Q6 quarantine the chore reading is uninterpretable anyway (the prices were
   invisible, so "did pricing change the decision" was never actually tested).
   → **A2 does NOT promote this round. It stays PRE-QUEUED** (the v8 owner lock
   binds the NEXT valid fun-verify: if a *visible* ledger still doesn't move
   the chore, A2 promotes automatically).
3. **Q7/Q8:** "wouldn't notice" is quarantined (can't miss what you never saw).
   Q8 control = "no, wouldn't care" — unchanged from D1's reading; the pile
   still lacks meaning. Control did its job: no false movement.
4. **Ledger disposition (Q1/Q2/Q5/Q7):** NOT decidable this round — disposition
   requires a valid meaning reading, which waits on presentation.
5. **D1b trigger check:** no banking-collapse *exploit*, no convenience deaths
   — zero banking is disengagement, not gaming. D1b stays parked. Economy stays
   parked (all branches).

## Behavioral evidence (recorded, not verdict)

- **Two sessions, ZERO voluntary banks and ZERO corpse recoveries.** Owner
  wiped twice and never ran back to loot (quit or re-wiped instead). Consistent
  with the D1 finding (threat never contests the corpse; the walk is "in
  between") and with the pile-lacks-meaning line — but under the quarantine
  this is context for the NEXT verify, not a verdict input now.
- Owner's unprompted session-1 comment (banked earlier): "the rest feels good
  for now."

## Diagnosis hypotheses for the presentation iteration (dev of record)

The renderer facts: beat draws at fixed screen anchor LEDGER_BEAT_Y=96
(top-CENTER — corrected 2026-08-11, this doc originally said top-left; the
block centers on cx=480), font 16, BEAT=150 frames (~2.5 s); wipe recap draws
over the veil during the forced pause.

- **H-vis1 (gaze):** combat gaze is on the avatar (center screen, ~y=270); a
  fixed top-edge line at y=96 is outside the attention cone — the diagnosis
  stands with the corrected location. The vision critic verified
  STATIC-FRAME legibility — a different perceptual task from in-play salience.
  The Rule-2 gate never tested "does a playing human notice."
- **H-vis2 (no juice):** the beat appears with zero animation, flash, scale-in,
  or sound. Vlambeer touchstone: an event without punch does not register.
  There is no audio in the build at all (MIDI/SFX dropped by owner order) —
  visual juice is the available lever.
- **H-vis3 (even the veil recap missed):** the recap prints during a forced
  90-frame pause with nothing else happening and STILL went unnoticed twice —
  strongest evidence that size/placement/contrast is deficient, not just
  timing. During a wipe the owner's attention is on the field/frustration.

## Next increment (defined, NOT started — verdict session ends here)

**Ledger presentation iteration:** make the beat impossible to miss (candidate
levers: anchor near the player / center-screen toast, scale-in + color flash,
larger type for the net line, recap contrast on the veil) — then RE-RUN this
exact 8-question fun-verify (Q3 becomes the FIFTH chore ask). Vision checks may
be ADDED (never weakened); any rendering change re-runs the full 7-script wall.
A2 remains pre-queued behind that verify's Q3.
