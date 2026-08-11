# Parking lot — ideas go here, never to code

Rule: nothing below starts until the current loop is fun-verified by the owner.
Append freely; promoting an item requires updating the scope contract in CLAUDE.md first.

## Parked from Kethral (proven-built once, deliberately not rebuilt yet)

- Procedural dungeon generation
- Branching dialogue / NPC trust / factions
- Status effects, crafting, charms, bestiary, codex
- Weather + time-of-day systems, NPC schedules
- Quests, shops, inventory, hotbar
- Multiple weapons / damage triangle
- Local co-op
- MIDI engine / procedural SFX (dropped by owner order — do not revive)

## New ideas (this project)

- YJIT via self-built Ruby (only if profiling ever shows frame drops)
- Diagonal corner-cutting asymmetry (M2.1 review finding, preexisting): GridWalker
  step/dash check only destination passability, so the PLAYER can move diagonally through
  a two-wall pinch that FlowField#open? forbids the AI. Guaranteed-escape exploit if the
  owner ever notices it; the fix (orthogonal-neighbor check in commit/commit_through)
  changes movement feel, so it waits for an owner verdict rather than shipping silently.

## World mythology (docs-only — no code until fun-verify, then only via scope-contract update)

- `docs/lore/world-bible.md` — standalone Egyptian×Fantasy world bible (Tibia-method: original
  pantheon, every creature family traced to the mythology, gods withdrawn but omnipresent).
  Deliberately NOT bound to Kethral names (owner call 2026-08-09) — integration is a future
  decision. Research canon behind it: 4 `game-research/` vault notes (egyptian-cosmology,
  egyptian-death-afterlife, akhenaten-amarna, new-kingdom-power — query via
  `hub kb query --domain game-research`). Its gameplay-hooks appendix maps lore → parked
  systems (corpse-run, respawn, skill-through-use, factions, bestiary). Unblocks the
  "fiction-bound audio/visual identity pass" below.

## Queued from the feature map (drafts/_kethral-feature-map.md) — next candidates post fun-verify

- Corpse-run gear drop (kethral's signature death tension — top candidate) — **now fully
  designed**: `docs/design-corpus/death-economy-design.md` (3-critic panel gated, D0-D3
  staging, soul model). D-track is PARALLEL to A1-A3; ordering = owner call at promotion.
  **D0 PROMOTED 2026-08-10** (owner call; scope contract v4) — D1 corpse containers /
  body fees, D2 wipe fine + insurance, D3 extras remain parked behind D0's fun-verify.

## Parked by the D0 spec (2026-08-10 — decided against, not deferred by accident)

- Carry friction (slowdown while carrying, bank fees, drop weight) — cadence was MEASURED
  non-trivial (`drafts/_d0-cadence-measurements.md`); artificial friction only returns if
  telemetry proves cadence collapsed, and A3 (bigger districts) outranks it even then.
- Ally auto-pickup / drop magnetism — kills the "which body holds the value" decision.
- Sub-pile pickup / stack limits — inventory-grid territory.
- Restart persistence for the banked total — a save system with no fun-thesis need;
  banked is session-only by decision (D0 spec challenge 5).
- Third zone tier (Vonash) + BSP-generated dungeon layouts (fixed seed, learnable geography)
- Room names on first visit ("The Entry Wound" style — cheap atmosphere)
- Stamina economy, loot drops, skill-through-use progression

## Owner playtest feedback awaiting promotion (recorded 2026-08-10, mid-D0)

- **Blocker taunt — SHIPPED 2026-08-10 (merge `38064ac`; owner call via structured
  Q&A; scope contract v5).** Original ask verbatim: "the tank is too weak, and should
  get more aggro from the enemies or have an exeta res-like spell to pull aggro."
  Dev-of-record analysis that carried into the spec: the sim has NO aggro system —
  humans target the nearest hostile (`AiController#nearest`), so "more aggro" would
  mean inventing invisible threat weighting; the readable, Tibia-faithful fix is a
  TAUNT VERB (symmetry with the shipped mark: mark orders allies onto one target,
  taunt orders enemies onto one body). Spec: `docs/superpowers/specs/2026-08-10-a0.6-blocker-taunt.md`
  (REVISED). Fun-verify questions pending owner in CHECKPOINT.md.

## D0 fun-verify verdict (owner, 2026-08-10 — recorded, NOT yet acted on)

- **"Bank now or push deeper" = "No, just a chore."** Progression/variety question:
  "Not sure" (inconclusive). D0's substrate works (all mechanics verified); the FUN
  failed. Dev-of-record read: stakes are too low because combat itself carries no
  threat texture — rushers die trivially, nothing endangers the carry, so banking is
  errand-running. Taunt (A0.6) is upstream of this: sticky, controllable fights are
  what make a carried pile feel at risk. **Decision: do NOT tune D0 blind now**
  (drop amounts / decay pressure / station placement wait); re-run the D0 fun-verify
  AFTER A0.6 ships and only then tune with fresh signal.
  **RE-VERIFY LANDED 2026-08-10 (post-taunt): "still a chore."** Taunt fixed combat
  feel, not carry stakes — as its own spec predicted. Revised diagnosis: D0's loss
  moment is a SILENT NOTHING (harshest possible rule — vanish — yet unfelt: no drama,
  no decision, no recovery). Fix promoted: **D1 corpse run** (scope contract v7,
  spec `2026-08-10-d1-corpse-run-design.md`). **D1b (body fees + vat re-growth) split
  out and PARKED** — the tension slice ships alone, one variable at a time; fees
  return with the economy/ledger increment. The post-fight ledger (Tibia Hunt
  Analyser beat, gamesmith FR-024) is the NEXT candidate after D1's fun-verify —
  it is the stakes' readout, so it waits for stakes to exist.
  **D1 fun-verify LANDED 2026-08-11: "still a chore" (THIRD ask).** The corpse
  run fired (owner session: 2 carrying deaths, 2 wipes, 2 recoveries, 0 losses)
  and read cleanly, but drama alone did not move the verdict. Pre-registered
  routing: primary = the pile lacks meaning (Q4 "banked, wouldn't care" = the
  spec's D1b/ledger clause verbatim); secondary = threat never contests the
  corpse. **Post-fight ledger PROMOTED (scope v8, owner lock via
  AskUserQuestion); A2 threat PRE-QUEUED** — promotes automatically if the
  ledger's fun-verify does not move the chore. Full verdict + routing:
  `drafts/_d1-fun-verify-20260811.md`.
  **LEDGER fun-verify LANDED 2026-08-11: INVALID as a meaning test — Q6
  escape-valve at maximum ("never saw any of it"; Q1/Q2/Q4 "never noticed",
  while telemetry proves the system fired: 4 fights, 1 loss beat, 2 wipe
  recaps).** Per the locked routing: presentation iteration FIRST, meaning
  verdict WAITS; Q3 was "not sure", NOT "still a chore" → **A2 did NOT
  auto-promote, stays pre-queued behind the next VALID verify** (visible
  ledger + unmoved chore → promotes automatically). Behavioral note: two
  sessions, zero banks, zero corpse recoveries. Next: make the beat
  impossible to miss, re-run the same 8 questions (FIFTH chore ask). Full
  verdict + diagnosis: `drafts/_ledger-fun-verify-20260811.md`.

## Owner playtest feedback (recorded 2026-08-11, mid-ledger-fun-verify — parked, NOT promoted)

- **"The tank should be the main character to be selected in the party, so he can
  drive the hunt; the rest feels good for now."** Dev-of-record read: initial
  possession should start on the BLOCKER, not the striker (pack member order in
  `data/balance/combat.json`). Independent corroboration: the ledger pilot flight
  organically converged on blocker-as-driver (it survived every stretch and landed
  repeated double-kills; the striker died first in nearly every life). Likely a
  one-line data change BUT it invalidates every recorded gate script (the initial
  possessed body is baked into all 7 replay input streams — flipping it desyncs
  corpse_run + ledger_loop, both pilot-authored). SHIP WITH A2 (or whichever next
  increment re-pilots anyway); do not ship standalone.

## Owner design questions (recorded 2026-08-11, mid-ledger-ship — answered, parked, NOT promoted)

- **Sustain (potions / healer / heals): route through D1b as the SPEND side of the
  ledger, never as a free cooldown.** Owner observation (correct, and measured: the
  ledger pilot flight logged 8 wipes in 5.5 sim-minutes; bodies only refresh via
  wipes, so hunts bleed out monotonically): hunts can't hold longer periods without
  sustain. The touchstone agrees — the EK-1037 Hunt Analyser's 59-minute hunt exists
  BECAUSE of its 311k supply burn; sustain and cost are the same mechanic. Dev-of-record
  shape when D1b promotes: healing/re-growth PRICED in banked value (the vat), so the
  banked pile buys hunt length — this is what finally makes the pile mean something,
  closing the loop the ledger instruments. Owner's healer-fairy/Navi kernel (invokable
  periodic AoE heal) folds in as a PRICED invocation (a portable bank-sink), not a free
  cooldown — free sustain lengthens hunts by weakening death (D1) and deleting the
  P&L's cost column (FR-024). No healer kit (4th body), no inventory potions (grids
  parked), no battle-rez.
- **Reviving teammates: mid-hunt re-crew AT THE HUB for a fee (D1b vat re-growth),
  not in the field.** Wipes already revive (the vat); the gap is dead-ally attrition
  mid-hunt (flight evidence: long last-body death-spirals). A paid hub re-crew gives
  the walk back a purpose beyond banking (Q2 "in between" gets a decision), keeps
  death meaningful, costs banked value. Field revival stays out.
- **Gate-camping / entrance-stacking: real, measured, and A2's problem.** Flight
  evidence: aggroed rushers never leash — chasers that lose the player IDLE at the
  gate; respawns walk back toward the last fight; the west gate re-formed a meat
  grinder every life, and re-entry at the arrival tile was spawn-adjacent ambush.
  Shape notes for A2 (this is pull-economy/aggro territory): (a) leash-with-no-heal —
  rushers that lose contact for N seconds walk home; they KEEP current HP, so
  zone-flipping is a breather, never a reset (the owner's named exploit); leash timer
  >> gate round-trip; (b) gate beachhead — small no-camp radius around arrival tiles
  unless attacked; (c) chaser cap ties into A2's aggro soft-cap. Do NOT ship as a
  standalone fix — it reshapes threat, which is exactly the variable A2 owns.
- **"The Nest" rename — SECOND owner complaint on record (2026-08-11; first was
  earlier).** The name is fiction-pending spec-speak that leaked player-visible (zone
  banner draws display_name). PRIORITY item on the fiction order form for the bible
  session; renaming now would invalidate every gate capture (banner text renders in
  frames), so it lands as its own post-bible increment: rename + one full wall re-run.

## A1+ queue (cut from Increment A by the 2026-08-09 dual review — each behind its own fun-verify)

- A1: gambit engine (JSON IF/THEN ally rules) + dev hot-reload keybind for iteration
  - ~~Adjacent-lobber inertness~~ CLOSED in M2.1 (owner verdict "teammates feel dumb"
    promoted the minimal fix): husk-grade retreat_step in AiController — adjacent
    projectile kit steps away to open range, then fires. FULL kiting/retreat behavior
    (hold range while repositioning, flee at low HP) remains gambit territory here.
- A1+: Shooters (ranged humans — needs per-attacker cadence proven first)
- A2: pull economy with aggro soft-cap (8-12) + density costs (review: without the cap it is
  monotonically exploitable). **Promoted v6 then DEMOTED same day (2026-08-10), zero code
  written** — owner pullback: "more complex aggro system is nice to have but seems more like
  an extra for later." Shape notes banked for whenever it returns: (a) owner picked a
  per-human threat-accumulator shape (taunt as threat CEILING, preserving the fun-verified
  hard lock) over this entry's original pull-density shape — reconcile the two at promotion;
  (b) gamesmith corpus has ZERO touchstone evidence for threat/aggro systems in any of the
  5 games (Tibia's only "pull" concept is over-pull as route-risk) — A2 must be defended
  from game-two's own diagnosed problems (the taunt-fuse finding, spec decision 6), not
  cited evidence. **PRE-QUEUED 2026-08-11 (scope v8 owner lock): if the post-fight
  ledger's fun-verify does not move the chore, A2 promotes AUTOMATICALLY — no new scope
  debate. Three converging signals on file (D0 dev-read, taunt not moving the chore,
  D1's 2/2 uncontested recoveries).**
- A3: nest advance / district progression (break districts, re-home the nest)
- Fiction-bound audio/visual identity pass (waits on the bible)
