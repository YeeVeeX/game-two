# Slice spec v2 — the grid is the world

> **STATUS: fun-verified 2026-08-09 and superseded.** The active spec is
> `docs/superpowers/specs/2026-08-09-a0-possession-core-design.md` (monster flip, A0 =
> possession core). This file stays as the record of the shipped grid slice.

**Supersedes v1 (arena duel) after the 2026-08-09 playtest verdict:** feel layer validated,
but the owner wants Tibia-style grid movement and the real Kethral shape — hub-and-spoke
world, not a one-room duel. v2 rebuilds movement + world on the grid; the feel layer
(hitstop, shake, telegraph, hurt-flash) carries over untouched.

**Fun thesis (unchanged):** *every hit must feel impactful.* Death hurts; survival feels
earned. NEW: *the grid IS the world* — spatial awareness in discrete steps is the identity,
not a limitation (Tibia doctrine, from the old repo's own alignment addendum).

## The world (hub-and-spoke — kethral's proven shape, minimum viable version)

Two zones, walk between them through gate tiles (gold):

| Zone | Role | Palette |
|---|---|---|
| **Solthrekan — South Gate** | Safe town. No enemies. Respawn point. | Warm browns |
| **Threketh — The Entry Wound** | Dungeon. 3 husks hunt you. | Cold dark blues |

Zone name banner on entry (~2.5s). Camera lerps (0.1) and clamps at zone edges — zones are
bigger than the 960x540 viewport, so the world reads as a place, not a screen.

## Movement (kethral's implemented model, ported to Ruby)

- 32px tiles. Logical position = integer tile; visual position tweens with cubic ease
  (`3t^2-2t^3`) over `step_frames` (15f = 0.25s/tile, kethral's 4 tiles/sec).
- The tile commits the instant a step starts; all logic (combat, AI, collision,
  transitions) reads tiles. Transitions fire when the step *lands*.
- Diagonals cost x1.414. Held key = continuous stepping. Walls are binary: passable or not.
- Creatures body-block — no two living things share a tile.

## Verbs (all numbers in `data/balance/combat.json`)

| Verb | Design |
|---|---|
| Move | tile step, 15f; held-key repeat; 8-way |
| Attack | windup 6f → active 4f → recovery 10f; hits once; fires even mid-step; **3-tile arc** in facing direction (front tile + flanks — husks melee diagonally, so must we) |
| Dodge | 2-tile burst at 7f/tile, 18f i-frames, 50f cooldown; THE defense verb |
| Die/respawn | hp 0 → 90f veil → respawn **in town** (hub-and-spoke: death sends you home) |

## Enemy: the husk (3 in Threketh)

HP 60 (3 hits), aggro 12 tiles, chases **downhill on a BFS flow field** (walks around walls,
recomputed only when the player's tile changes), melees at Chebyshev adjacency (diagonals
hit) with the 30f yellow telegraph → 6f active → 45f cooldown. Killed husks respawn at the
nearest spawn tile after 300f. Deviation from v1 logged: aggro is now tile-based (12 tiles
~ 384px vs v1's 600px — the dungeon has walls now; sight-length aggro would feel psychic).

## Feel (unchanged from v1 — validated fun)

hitstop (3f hit / 8f kill) → deterministic shake (decay 0.85) → hurt-flash → knockback
(now a 1-tile grid push) → HP bar. 30f post-hit i-frames.

## Visual identity

Flat-rect minimalism carried from v1, now per-zone palettes in `data/zones/*.json`.
Player ember orange, husk pale bone, telegraph hot yellow, swing white 3-tile arc,
transitions gold. Wall tiles + faint grid lines make the tile structure legible.

## Deliberately absent (parked, not forgotten)

Corpse-run gear drop, stamina, loot, XP-through-use, NPCs, second enemy type, BSP-generated
zones, breathing cycle, minimap — PARKING_LOT.md. Next candidates after fun-verify:
corpse-run (kethral's signature death tension) and a third zone tier.

## Ship gate

`rake` green + `rake capture SCRIPT=harness/scripts/world_loop.json` byte-identical across
runs + vision critique passes on the captured frames + owner says "fun".
