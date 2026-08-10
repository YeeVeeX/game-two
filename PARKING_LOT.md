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

- **Blocker taunt — PROMOTED 2026-08-10 (owner call via structured Q&A; scope contract
  v5).** Original ask verbatim: "the tank is too weak, and should get more aggro from
  the enemies or have an exeta res-like spell to pull aggro." Dev-of-record analysis
  that carried into the spec: the sim has NO aggro system — humans target the nearest
  hostile (`AiController#nearest`), so "more aggro" would mean inventing invisible
  threat weighting; the readable, Tibia-faithful fix is a TAUNT VERB (symmetry with the
  shipped mark: mark orders allies onto one target, taunt orders enemies onto one
  body). Spec: `docs/superpowers/specs/2026-08-10-a0.6-blocker-taunt.md`.

## D0 fun-verify verdict (owner, 2026-08-10 — recorded, NOT yet acted on)

- **"Bank now or push deeper" = "No, just a chore."** Progression/variety question:
  "Not sure" (inconclusive). D0's substrate works (all mechanics verified); the FUN
  failed. Dev-of-record read: stakes are too low because combat itself carries no
  threat texture — rushers die trivially, nothing endangers the carry, so banking is
  errand-running. Taunt (A0.6) is upstream of this: sticky, controllable fights are
  what make a carried pile feel at risk. **Decision: do NOT tune D0 blind now**
  (drop amounts / decay pressure / station placement wait); re-run the D0 fun-verify
  AFTER A0.6 ships and only then tune with fresh signal. D1 (corpse containers)
  remains parked behind that re-verify.

## A1+ queue (cut from Increment A by the 2026-08-09 dual review — each behind its own fun-verify)

- A1: gambit engine (JSON IF/THEN ally rules) + dev hot-reload keybind for iteration
  - ~~Adjacent-lobber inertness~~ CLOSED in M2.1 (owner verdict "teammates feel dumb"
    promoted the minimal fix): husk-grade retreat_step in AiController — adjacent
    projectile kit steps away to open range, then fires. FULL kiting/retreat behavior
    (hold range while repositioning, flee at low HP) remains gambit territory here.
- A1+: Shooters (ranged humans — needs per-attacker cadence proven first)
- A2: pull economy with aggro soft-cap (8-12) + density costs (review: without the cap it is
  monotonically exploitable)
- A3: nest advance / district progression (break districts, re-home the nest)
- Fiction-bound audio/visual identity pass (waits on the bible)
