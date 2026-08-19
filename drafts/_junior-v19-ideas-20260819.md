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

## Idea 2 — safe zones vs battle zones (owner, 2026-08-19)

**Provenance:** owner, live chat 2026-08-19 mid-day (dev session 16,
post-power-cut). Owner verbatim (English):

> I just had an idea (nothing groundbreaking, more like a thought), we
> should separate battle areas from safe areas, so players can't
> attack or inflict damage to others while in a safe zone (like depots
> at temples in Tibia) so when the world opens up to more players
> later on or we add any specific mission/quest/NPC related task, we
> can also play with those definitions, what do you recommend? Maybe
> it is too soon for thinking about that but I just had that in my
> mind so I wanted to share so I don't forget

**Triage: BANK (v19 brainstorm input), with one pre-recorded design
trap.** Cites a real touchstone (Tibia protection zones — depots/
temples); serves the parked multiplayer-expansion and NPC/quest lanes.

- **Touchstone (reference wall):** Tibia PZ — two halves, and the
  second is the load-bearing one: (a) no damage resolves inside a
  protection zone; (b) **the combat lock** — a battle-flagged player
  CANNOT enter the PZ until the flag expires. Without (b), safe zones
  become the exploit (dive into the depot to drop aggro/escape
  retaliation). Any future spec must carry both halves.
- **Current-era fit:** co-op has NO player-to-player damage today, so
  the only feelable v18-era version would be "enemies never pursue/
  damage into safe areas" — that is a SIM change (lockstep/replay
  identity) = post-verdict by class. Nothing ships now.
- **Cheap shape when it lands (data-driven law):** zones already carry
  `hub: true`; `safe:` is the natural sibling attribute (zone-level
  first; per-tile only if a real need appears). Systems READ the flag
  (damage resolution, AI pursuit, later PvP/quest givers) — zero
  constants in code. Hubs nest/camp are the obvious first carriers —
  note today's soak observed camp DOES host combat (fights=4), so
  formalizing `safe` would visibly change camp's character: an owner
  fork at the brainstorm, not a default.
- **What it unlocks later (the owner's own framing):** PvP rules by
  area when >2 players unparks; NPC/quest/mission placement (parked
  Kethral lanes) gets a sanctioned "town" surface; composes with the
  banking ritual (banks live in hubs — "sanctuary" reading).
- **Effort when built:** S–M (flag + damage/pursuit gates + Rule 2
  visual language for the boundary — players must SEE where safety
  starts; unmarked safe borders are a readability defect, not a
  mystery).

## Slot status

Nothing else arrived (no paste, no drafts file beyond this relay, no
Junior commit carrying ideas). Answers, when they arrive bundled with
ideas, get SPLIT per the spark (answers → skeleton, ideas → here).
