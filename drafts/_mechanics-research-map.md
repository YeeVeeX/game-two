# Mechanics research → game-two map (2026-08-09)

Two new swept corpora condensed into 4 vault notes (all `hub kb query --domain
game-research`). Docs-only fuel per PARKING_LOT — nothing touches src/ until fun-verify.
This memo exists because PARKING_LOT.md was dirty in the parallel M2 session at write
time; fold these pointers into it when that session settles.

## The 4 notes and which parked item each feeds

| Vault note | Feeds parked item |
|---|---|
| tile-autotiling-wang-tiles-and-wave-function-collapse | BSP dungeon layouts (A-queue): recommends BSP+WFC hybrid w/ fixed seed, autotiling first, Wang tiles for wilderness; do-NOT list (runtime WFC) |
| classic-2d-mmo-terrain-uo-tibia-map-formats-and-isometric-rendering | Third zone tier + map tooling: statics/ground split, chunked map files, draw-order rules, what a map editor must do before content scales |
| rpg-xp-curves-and-leveling-formulas | Skill-through-use + stamina economy: Tibia XP cubic + skill exponential (exact, capture-verified), concrete starting curve dE(L)=40L^2-120L+160, Skyrim use-based exploit lessons |
| death-penalties-stat-scaling-and-progression-balance | Corpse-run gear drop (TOP candidate): Tibia exp-loss formula exact, blessing economy maps 1:1 onto the world bible's passage-scroll fiction (deliberate), starting numbers for a low-cap slice, niche-protection rule for factions/party |

## Trust one-liners (full: knowledge/.scratch/*-sweep.md)

- NEVER cite terrain 10/13/17 or progression 28/1/23 (17 = AI self-synthesis TDD,
  28 = fabricated guide for a dead game).
- TibiaWiki formulas survived capture as inline LaTeX; 5 constant tables LOST —
  recapture from TibiaWiki if constants ever needed.
- NotebookLM exports drop code blocks + HTML tables corpus-wide; consult linked
  repos for implementations.

## Cross-links

- World bible (committed b027453, branch a0-m2.1-feel-repair): its Toll/blessing/
  passage-scroll fiction was written to price exactly the death-penalty math in the
  death-penalties note. §13 gameplay hooks + these 4 notes = the full docs-side kit
  for the corpse-run slice when the owner promotes it.
- Egypt canon: 4 more game-research notes (egyptian-*, akhenaten-*, new-kingdom-*).
