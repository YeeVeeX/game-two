# Junior — v19 ideas intake (2026-08-19)

Banked per the v18 session-14 spark Job 6 (Itexo-style triage:
FOLD-NOW / BANK / PARK+trigger / ROUTE-SIBLING). **v19 does NOT open
this session** — these are brainstorm inputs for the cycle that starts
after the SEVENTEENTH adjudicates.

## Idea 1 — Tibia stationary facing (Ctrl + direction)

**Provenance:** relayed by the owner, live chat 2026-08-19 ~00:2x
(mid-ritual-night, between session-1 crash and re-run). Owner verbatim
(English):

> Junior had the idea to add the stationary facing direction change
> that Tibia uses, by holding ctrl and pressing a direction key (either
> AWSD or arrow keys) and the character should stuck in place during
> the time it holds ctrl and faces towards the side that it presses the
> direction on, what is the best approach?

**Triage: BANK (v19 brainstorm input).** Small, grid-native, cites a
real touchstone.

- **Touchstone (reference wall):** Tibia's Ctrl+arrow turn-in-place —
  a real Tibia control, same modifier shape Junior names.
- **What it serves mechanically:** facing is load-bearing here —
  projectile kits fire along facing lanes and `front_tile` reads
  facing for follow/yield logic. Today facing only changes by
  stepping; a free stationary turn = aim without committing a tile
  move (doorway holds, lobber lane re-aims, corner peeks). Real value,
  not chrome.
- **Recommended approach (next-spark shape, dev of record):**
  1. **Input layer** (`src/core/input`): a held FACE modifier (Ctrl)
     reroutes direction presses from MOVE intent to a new FACE intent.
     While held, no move intents are emitted — "stuck in place" falls
     out of intent generation, the sim never needs a modifier state.
  2. **Lockstep/replay safety:** FACE travels as one more intent in
     the per-tick input frame — additive, deterministic, replay
     scripts unaffected; netplay build identity already enforced by
     the same-commit fingerprint law.
  3. **Sim:** facing mutation without a move enqueue (grid-walker
     skip) — a few lines; facing already exists on creatures.
  4. **Bindings:** data-driven in the bindings file (bindings.json law
     stands — no rebind UI).
  5. **Feel pass:** instant turn per the juice wall; capture + Rule 2
     gate (visible facing change = visual surface).
- **Effort:** S. **Risks:** none structural; interplay with attack
  aiming is the point, watch balance in playtest.

## Slot status

Nothing else arrived (no paste, no drafts file beyond this relay, no
Junior commit carrying ideas). Answers, when they arrive bundled with
ideas, get SPLIT per the spark (answers → skeleton, ideas → here).
