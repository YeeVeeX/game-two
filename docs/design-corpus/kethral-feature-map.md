# Kethral feature map (mined 2026-08-09, 4 researcher agents, 651K tokens — do not re-mine)

Source: `C:/Users/gabri/Documents.stale-20260413/coding_projects_main/Game On(e)` (read-only).
Every claim below was verified against CODE unless marked docs-only. The old repo's docs
overclaim chronically — trust the .py citations, not the .md summaries.

## Version verdict — which dirs are "the first and second versions"

| Dir | What it is | Evidence |
|---|---|---|
| `prototype/` | **FIRST version.** Free PIXEL movement (grid was planned in TIBIA_ALIGNMENT_ADDENDUM.md but never coded here). 3,393-line main.py god object. | README.md:229 "prototype/ LEGACY (superseded by kethral/)" |
| `kethral/` | **SECOND version — the feature-rich one the owner means.** Grid-stepped movement ACTUALLY IMPLEMENTED. 21+ phases, 1,364 doc-claimed tests, game.py = 3,997 lines (worse than the 2,663 our CLAUDE.md cites — that number was already stale in their own docs). | README.md:207 "ACTIVE PROTOTYPE"; wc -l verified |
| `kethral_v2/` | Abandoned THIRD restart. Never committed to git (whole tree untracked). One room, 2 ravagers, combat-feel focus. Grid-stepped too. Useful as a combat-feel reference only. | git ls-files empty for it; built concurrently with kethral Phase 22 |
| `project/` | Godot 4.x port attempt, v0.3.0. Generators ported but zone scene dirs are empty (.gdkeep only) — never reached a playable world. | project.godot; empty scenes/zones/* |

**So "first and second versions" = `prototype/` + `kethral/`.** The name `kethral_v2/` is a trap —
it's the least complete dir in the tree.

## THE MOVEMENT SPEC (kethral/'s proven implementation — the pivot's blueprint)

From `kethral/entities/base_entity.py:19-236`, `entities/player.py:239-676`, `world/tilemap.py`:

- **TILE_SIZE = 32px.** Logical position = integer (grid_x, grid_y); visual position = float
  pixels that interpolates between tiles. ALL game logic (collision, combat range, AI, zone
  transitions) runs on the integer grid. The floats exist only to animate the walk.
- **Grid pos updates instantly on move commit**; visual pos smooth-steps with **cubic ease
  `3t^2 - 2t^3`** over the step duration.
- **Player speed 4.0 tiles/sec = 0.25s/tile = 15 frames @60fps.** (run_speed 6.0 defined but
  dead code.) Enemies 3.5 tiles/sec in kethral_v2.
- **Diagonals allowed, cost x1.414** (~21 frames).
- **Held-key = single-slot input buffer**: while a step is interpolating, new directional input
  is captured and fires the instant the step completes → continuous-feeling walk, always
  grid-locked between steps.
- **Collision is binary tile passability** (`is_passable(x,y)` against a passable-TileType set)
  PLUS a `blocked_tiles` set of enemy-occupied tiles — entities body-block each other.
- **Dodge = special multi-tile grid move**: scans for the farthest passable tile up to
  dodge_distance_tiles (2) in a direction, at HALF the normal per-tile duration; can cancel an
  in-progress step. (player.py:581-676)
- kethral_v2 kept knockback as continuous-pixel physics on top of the grid (v0=sqrt(2ad),
  per-axis wall check) — the one non-grid motion. We can simplify to a 1-tile push.

## World shape (what "kethral arena is not what I intend" means)

**Hub-and-spoke, town + dungeon — NOT open world, NOT one arena room.**

- **The venture loop (the game's actual shape):** town (safe: NPCs, shop, craft) → venture into
  dungeon → fight/loot → return alive OR die → death drops gear at death location as a corpse →
  respawn in town → corpse-run to retrieve gear. Designed session: 20-30 min per venture.
- kethral/ zones in code: **Solthrekan** town (40x30 tiles, hand-authored `town_gen.py`),
  **Threketh** dungeon (80x60 BSP, seeded, `dungeon_gen.py`), forest (7 hand-authored ~20x15
  rooms chained door-to-door, Zelda-style), oramek coastal zone. One shared TileMap class; a
  `transition_targets` dict maps specific (x,y) tiles → target zone string. WorldManager
  centralizes current_zone + transition detection + anti-ping-pong cooldown.
- Dungeon design intent (creative bible/v5): 3 tiers — Threketh (entrance, 8-12 rooms, linear),
  Vonash (mid, 15-20 rooms, branching), Kurvorn (deep, 6-10 rooms, labyrinthine). Fixed seed —
  "the player learns the geography over time" (prototype used seeds 42/137/847).
- Room NAMES on first visit ("The Entry Wound", "Kelvor Feeding Grounds") — cheap, beloved,
  pure atmosphere.

## Feature inventory of kethral/ (IN CODE, with citations)

- **Combat**: light/heavy/spin/ranged attacks, stamina costs, 3-hit combo chains (L-L-H
  finisher 2.0-2.2x), charge heavies, parry (perfect window reflects), positional damage
  (front/side/back multipliers via atan2), dodge with i-frames, stagger/exhaustion.
  [player.py:432-676, systems/parry.py, systems/positional_damage.py]
- **4 weapons**: Sword balanced / Axe slow-heavy / Dagger fast / Spear reach. [combat_manager]
- **Enemies**: 4+ JSON stat blocks (wind_wraith, stone_sentinel, tide_lurker, coral_crawler)
  beyond the 2 the status doc claims. Boss entity class + boss rooms. [data/enemies/*.json]
- **Death system**: gear drops at death location, corpse retrieval, XP penalty. [systems/death]
- **Skill-through-use progression** — no character levels. [managers/progression]
- **NPC dialogue** (branching trees, JSON), **trust/reputation**, **NPC schedules** (venture-time
  based). [systems/dialogue_manager.py:15-243, npc_schedules.py]
- **Bestiary/Codex** (discovery tiers, kill counts, charm unlocks). [systems/codex_system.py]
- **Crafting** (blueprint-gated recipes), **weight-based inventory**. [systems/crafting.py]
- **Breathing cycle** — dungeon walls seal/unseal dynamically (SEALED_WALL TileType). 
- **Aethyn Awakening** transformation gauge. **Save/load.** **Procedural SFX + adaptive music**
  (owner has since dropped audio — placeholder only).
- **Stubs/vapor**: local co-op (self-admitted stub), weather (one class def), KETHRAL_V2
  architecture + Godot migration (docs only — never treat as built).

## Fun thesis across the lineage (and the recurring failure)

- Identity: "the fissure hums, and it's hungry" — hardcore, melancholic, Tibia-veteran-targeted.
  Pillars: risk/reward tension, earned mastery, death hurts, improve-through-use.
- **No version ever recorded a fun-verified playtest.** README lists "fun rating >=7/10" as a
  NEXT STEP. Their own docs diagnose "Phase 20: 20,000 lines of code that produced zero visual
  changes." Every restart (kethral_v2, Godot) died before a validated slice. game-two's slice v1
  "simple, fun" verdict is already further than any predecessor got.
- kethral's own GAP_ANALYSIS flags what fun combat still needed: encounter composition
  (multiple enemies fighting together), hit-stun/i-frame specifics, stamina economy numbers,
  telegraph variety. Our feel layer already covers hitstop/telegraph/i-frames.

## Key files worth Reading directly later (don't re-mine, go straight here)

- Movement: `kethral/entities/base_entity.py`, `kethral/entities/player.py`
- World: `kethral/world/tilemap.py`, `kethral/managers/world_manager.py`,
  `kethral/world/{town_gen,dungeon_gen,forest_gen}.py`
- Design intent: `docs/CREATIVE_BIBLE_V3.md`, `docs/v5/V5_REDESIGN_BLUEPRINT.md`,
  `prototype/TIBIA_ALIGNMENT_ADDENDUM.md` (grid spec tables), `kethral/KETHRAL_V2_GAP_ANALYSIS.md`
