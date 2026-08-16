# Systemic-worlds research shelf — consumption workflow

> Banked 2026-08-16 by the knowledge-repo research session (NOT the dev seat; no scope
> change, nothing owed in v17). Status: REFERENCE. This doc tells future cycles where the
> verified systems research lives and how to spend it without re-deriving or diluting it.
> Same class as `tibia-research.md` / the A2 evidence banking in PARKING_LOT.md.

## What exists (as of 2026-08-16)

A 16-file research corpus on systemic-world logic (`knowledge/sources/
rpg-systemic-worlds-research-2026-08`) passed a per-claim adversarial verification pass
(~50 VERIFIED / ~31 CORRECTED / ~43 FLAGGED / 2 REMOVED; per-file verdict tables; fetch
evidence in `knowledge/.scratch/rpg-verify-2026-08-16/`) and was condensed into five
curated vault notes, each ending in a "For game-two" section:

| Vault note (`game-research/`) | Carries |
|---|---|
| `living-world-simulation-and-npc-schedules` | Time-indexed waypoint schedules (U7/Gothic/MM/Stardew, verified formats), why MMO NPCs are statues, offline-sim LOD (STALKER switch_distance, M&B, X4, RimWorld raid-points formula), 3-tier hot/warm/cold scheme, catch-up-on-load |
| `mmo-economy-design-sinks-and-faucets` | Faucet/sink law, UO closed-economy failure (Koster firsthand), OSRS GE tax + item sink (2% since 2025-05), vendor spread anchors (verified Tibia numbers), inflation/deflation postmortems, arbitrage loops, telemetry targets |
| `damage-elements-and-combat-math` | Verified formula archetypes (Pokémon/FFX/Tibia classic+modern/OSRS max-hit), WoW K-curve mitigation + EHP math, PoE stacking taxonomy, FE true-hit psychology, one-roll attack tables, element charts as content, DoT shapes, recommended 5-piece stack for a skills-through-use 2D game |
| `crafting-loot-and-consumable-economies` | Consumable demand machinery (rune economy, toxicity budgets), Skyrim/BotW alchemy-cooking math (verified), enhancement sinks (imbuement timers vs failstack casino), flat loot rolls vs treasure classes, pity math (Genshin 74/90 verified, token pity) |
| `world-events-towns-and-folklore-mechanics` | Hub trinity + single-hub law, danger-gradient geography, verified spawn/raid anatomy (presence-block, population-scaled respawn, staged broadcasts, 2-175-day intervals), keyword-dialogue + rumor-file folklore (verified), reputation/witness/skull machinery, Nemesis patent boundary (US10926179B2, expires 2036-08-11) |

Companion notes already on the shelf: `death-penalties-stat-scaling-and-progression-balance`,
`rpg-xp-curves-and-leveling-formulas`, `tibia-mechanics-lore-and-virtual-world`,
`classic-2d-mmo-terrain-uo-tibia-map-formats-and-isometric-rendering`,
`black-desert-online-economy-combat-and-progression`,
`new-world-aeternum-factions-crafting-and-governance`,
`warhaven-melee-combat-audit-and-failure-analysis`.

## How to consume (KB-first, never copy)

```
hub kb query --domain game-research "<topic>"          # curated, verified layer — default
hub kb query --domain game-research "<topic>" --top-k 5
# raw provenance only (which primary source said X):
cd C:/Users/gabri/knowledge && python scripts/kb.py verify "<claim>"
```

- Never copy research wholesale into this repo — query it, cite it. Copies fork-drift
  from the verified layer and bloat context.
- Cite as: vault note § + corpus file number + verdict tier. Every constant that lands
  in `data/**/*.json` should trace to a primary source through that chain.

## Trust tiers (hard rule)

- **VERIFIED** — re-fetched against a primary source (live wiki API, engine source,
  patent text, config files). May enter a spec as a number, with citation.
- **CORRECTED** — the capture was wrong; the corrected value is the citable one.
- **FLAGGED** — plausible community folklore. Shape/mechanism only; a FLAGGED number
  NEVER lands in a spec or in `data/` without fresh re-verification.
- Live-wiki constants are 2026-08 snapshots; they drift with patches. Re-check anything
  load-bearing older than ~6 months (`last_verified` in the note frontmatter).

## The spec pipeline (codified from this repo's own precedents)

The death-economy track is the proven shape (`death-economy-design.md` → 3-critic panel →
owner forks → scope-contract update → D0-D3 staging → fun-verify gates with
pre-registered routing). Generalized:

1. **Query the shelf first** (`hub kb query`) — the reference-wall rule already demands a
   touchstone per design idea; the shelf is where touchstones with verified numbers live.
2. **Spec in `docs/design-corpus/` or `docs/superpowers/specs/`** with tier-cited
   constants, explicit tuning knobs (all in `data/`, per non-negotiable 3), and a
   telemetry plan (2-3 metrics per system; the corpus's integration blueprint, file 10,
   has the 12-metric menu: faucet/sink ratio, TTK by band, pity-trigger %, ...).
3. **Gate before build**: critic panel; `council` cross-vendor for irreversible or
   taste-heavy shapes (Rule 6). Owner forks close at the brainstorm (v13 precedent).
4. **Scope contract updated BEFORE code** (the parking-lot law).
5. **Build deterministic-first**: the recommended combat/schedule shapes were chosen
   partly because they keep replays bit-stable (single seeded RNG stream, one-roll
   tables, schedules read the sim clock) — the wall depends on this.
6. **Telemetry ships WITH the feature**, not after (the ledger cycle re-proved why:
   verdicts without instruments are invalid).

## Mapping to the recorded owner wishlist (v11, verbatim: "more purpose… progress, leveling, equipment, new enemies and zones, lore, cities")

- progress/leveling/equipment → `damage-elements-and-combat-math` (skills-through-use
  stack) + `rpg-xp-curves` + `crafting-loot` (pity, enhancement sinks)
- new enemies/zones → `world-events-towns` (danger gradient, spawn/raid anatomy) +
  `living-world-simulation` (spawn LOD)
- cities → `world-events-towns` (hub trinity) + `mmo-economy` (vendor anchors, sinks)
- economy/D1b-family increments → `mmo-economy` + `crafting-loot`
- multiplayer-era systems (post-v17) → `living-world-simulation` (server LOD) +
  `mmo-economy` (the corpus was built MMO-first; it scales down cleanly)
- lore → NOT this repo (standing order 2026-08-16). Fiction-bound hooks in the vault
  notes route through `../game-two-lore`; anything crossing into this repo arrives as
  placeholders/mechanics only.

## Anti-patterns (each already bitten someone)

- Pre-building parked systems because the research is exciting — the parking-lot rule
  exists so promotion day is cheap, not so shelves become backlogs.
- Importing FLAGGED numbers (the corpus's research LLM invented GDC talks and spell
  names that survived until the verification pass — folklore looks exactly like fact).
- Copying research into the repo (fork-drift; the vault is queryable from any session).
- A separate "systems repo": only a franchise-scale production program (the MMO-scale
  stack as its own multi-session pipeline, like the lore program) earns its own repo.
  Feature design for THIS game lives here, behind this repo's gates.
