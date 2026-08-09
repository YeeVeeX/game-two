# A0 — Possession core (spec)

**Date:** 2026-08-09 · **Status:** awaiting owner review · **Supersedes:** the Increment A design
(docs/design-increment-a.html), cut down per the dual adversarial review
(drafts/_design-review-reconciliation.md — the 5 design laws there are binding on this spec).

## Naming discipline (de-slop rule, owner-set)

Every name in this spec is **internal spec-speak** — deliberately generic, never player-visible.
The fiction is being authored in a parallel session from the New Kingdom Egypt corpus
(`knowledge/sources/Power and Piety in New Kingdom Egypt-backup-2026-08-09`). Player-visible
text (zone banners, HUD labels, any flavor) ships only after binding to that bible; until then
captures may show placeholder glyphs. See "Fiction order form" at the end.

## What A0 is

You are a pack of **three creatures** hunting **humans** in one district of a collapsing city.
You possess one creature at a time (**Tab** cycles the living); the other two fight on with
husk-grade AI. When your possessed body dies, control **force-swaps** to a survivor. When all
three die, the pack is wiped and respawns at the **nest** (the hub zone).

**Fun thesis:** *being* the pack — three bodies that feel different, swap under pressure,
survive as a unit. (Programming the pack — gambits — is A1, behind its own fun-verify.)

## The refactor (the real work)

The current World is structurally single-protagonist. A0 replaces the Player/Enemy dichotomy:

- **Actor** — anything on the grid: tile, walker, HP, kit, faction (`:pack` / `:human`).
- **Controller** — each actor has one: `:possessed` (reads input) or `:ai` (a brain).
  Possession = moving the `:possessed` controller between pack actors. Humans are never possessed.
- **Combat resolution reads the attacker's kit** (damage, arc, exhaust) — never a hardcoded
  `[:player]` path. Any actor can hit any hostile actor.
- **Events:** `player_*` vocabulary retires; new symbols (`possession_changed`, `actor_died`,
  `pack_wiped`, …) registered when first used (non-negotiable #4).
- **State machine:** `world → nest_respawn` replaces `world → death`. Forced-swap is NOT a
  state change — the world keeps running.

## The three kits (hardcoded in A0; all numbers = hypotheses in `data/balance/creatures.json`)

| Kit (spec-speak) | Role | Sketch |
|---|---|---|
| **Blocker** | holds chokes | high HP, slow steps, 3-tile front arc, knockback on hit, slowest exhaust |
| **Striker** | flanks, finishes | low-mid HP, fastest steps, single-tile hit, fastest exhaust |
| **Lobber** | pressure at range | low HP, straight-line tile projectile (~6 tiles), mid exhaust |

The Lobber's projectile is the one new mechanic: tile-stepped, deterministic, stops at first
wall/actor. No arcs, no homing.

**Exhaust mechanics:** exhaust is a per-creature clock gating `start_attack` — the existing
windup→active→recovery state machine is unchanged; a new swing may not *begin* until
`exhaust_frames` have passed since the last swing began. Holding attack retriggers at that pace.

**Dodge is a shared verb:** all three kits keep the existing 2-tile dodge burst, with
per-kit `frames_per_tile` / `cooldown_frames` in creature data (Striker's is the snappiest).
Dodge cooldown is creature-owned and swap-inert, same as exhaust.

**Ally AI (husk-grade, deliberately dumb — gambits are A1):** unpossessed pack creatures run
the same brain shape as today's husk: idle until a human enters aggro range → chase nearest
human downhill on its flow field → attack when in kit range (Blocker/Striker: Chebyshev
adjacency; Lobber: aligned row/column within projectile range, clear line) → repeat. No
retreating, no coordination, no target-switching logic beyond "nearest". If they die dumb,
that is the pitch for A1's gambits — the gap is a feature.

## Combat laws (from the review — binding)

1. **Exhaust replaces free-swing.** Every attack pays a per-creature exhaust clock
   (frame-quantized; 45f baseline hypothesis — research says Tibia melee is ~2s, we bias
   action-ward and tune). Holding attack auto-swings **at exhaust pace** — this fixes the
   owner's held-space-barrier complaint: pace + human pressure, not input denial.
2. **Exhaust + input buffers are creature-owned and swap-inert.** Swapping never resets or
   transfers a clock. Post-swap inputs are **edge-triggered**: held keys do nothing until
   released and re-pressed (kills ghost-fire and held-dodge burn). `swap_cooldown_frames`
   exists as a data knob, default 0 — raised only if playtest shows degenerate swap-rotation.
3. **Blanket 30f post-hit invuln is REMOVED.** A single swing hits a given victim at most once
   (per-swing hit registry, as today); beyond that, victims take each attacker's hits
   independently — damage pacing comes from each attacker's own attack cadence, not from victim
   immunity. Dodge i-frames stay (active defense ≠ passive immunity). This is what makes human
   density a real threat and un-breaks synchronized volleys.
4. **Hitstop is scoped to the possessed body** — it fires only when the possessed creature
   deals or takes a hit. Ally/AI-vs-AI hits emit events (for HUD/feel later) but never freeze
   the world. Shake/hurt-flash still world-visible.
5. **Forced-swap on possessed death:** control snaps to the nearest living pack creature with
   a short action-lock stagger (`swap_stagger_frames`, ~20f hypothesis) — the cost of losing a
   body. Voluntary Tab-swap has no stagger. Wipe (all three dead) → veil → pack respawns at nest.

## Humans (prey): Rushers only

Melee mooks at existing-husk grade: flow-field chase, Chebyshev melee, telegraph → active →
cooldown, fixed spawn tiles, timed respawn. **They target the nearest pack creature** (not the
possessed one) — that asymmetry is what makes allies feel alive. Numbers in
`data/balance/humans.json`. Shooters (ranged humans) are A1+.

**Pathing:** one BFS flow field **per pack creature** (3 max), recomputed only when that
creature's tile changes; each Rusher walks downhill on its target's field, nearest-target
tie-broken by actor id. Bounded, deterministic, cheap at zone scale (~40×23) even on no-YJIT Ruby.

## Determinism spec (before any AI code — law #3 of the review)

- One seeded PRNG stream owned by the sim (`Random.new(seed)`); seed recorded in every replay
  script; **no** `Gosu.milliseconds`, `Time`, or global `rand` in the sim.
- All ticks frame-quantized. Actor iteration in fixed spawn order — never hash order.
- Harness input schema grows a **swap lane** (`"swap"` in `hold`) + a **`seed`** field.
- The byte-identical-capture regression stays as a permanent gate: new script
  `district_hunt.json` covering possess-all-3 + forced-swap + wipe; two runs, identical md5s.

## Zones

Two hand-authored zones, reusing the shipped zone system unchanged: **nest** (safe hub,
respawn, no humans) and **one city district** (streets-and-buildings ASCII layout, Rusher
spawns). Town/Threketh retire from the wired game (files kept as reference). Banner text =
fiction-bound (order form below).

## Carried critique fixes (ride with A0's renderer work; each verified by capture)

Facing notch on every actor · hurt-flash never white (reads as spawn) · telegraph color ≠
gate/transition color · wall brightness 2–3× · corpses persist (fade, don't vanish) ·
tween ease verified in motion capture · attack lunge (visual weight into the swing).

## Camera + off-screen allies (answering the review's single-protagonist finding)

Camera follows the **possessed** creature (existing lerp/clamp unchanged); on swap it lerps to
the new body — the swap *feels* like relocating. Living off-screen pack members get an edge
pip (kit-colored arrow at the viewport border) so ally state is never invisible. For Rule 2,
the `district_hunt.json` script is authored so every assertion-bearing moment (each possession,
the forced swap, the wipe) happens **on-screen for the possessed camera** — what the harness
must verify, the viewport must show. AI-vs-AI fights that resolve off-screen are asserted in
tests via events, not captures.

## HUD

Three HP bars (possessed one highlighted) + exhaust-ready pip on the possessed bar. Nothing else.

## Deliberately absent from A0 (A1+ queue, each behind its own fun-verify)

Gambit engine + hot-reload · Shooters · pull economy with aggro soft-cap · nest advance /
district progression · fiction-bound audio/visual identity pass.

## Ship gate

`rake` green · `rake capture SCRIPT=harness/scripts/district_hunt.json` byte-identical across
two runs · vision critique passes (including the carried critique fixes) · **owner possesses
all three creatures in a real hunt and calls it fun.**

---

## Fiction order form (for the bible session — name these from INSIDE the fiction)

Each handle below ships player-visible and must be named by the bible, not by spec-speak.
Mechanical role attached so the fiction can be written to fit:

1. **The pack species / collective** — what the three creatures are; why they hunt together.
2. **Three kit names** — blocker (holds ground, massive), striker (fast, kills), lobber
   (ranged, keeps distance). Distinct silhouettes in fiction as well as on the grid.
3. **Possession** — what the player *is*, such that it inhabits one body at a time and
   survives body-death by moving to another. (Egypt corpus hook: ka/ba soul concepts map
   directly onto swap-on-death.)
4. **The nest** — the safe place the pack returns to on wipe. (Hook: death-and-rebirth
   cosmology; the wipe→nest loop is literally a salvation cycle.)
5. **The humans** — who they are, why they are prey; a name for the melee mook (Rusher role).
6. **The collapse** — what is unmaking the modern city. (Hook: a state theology failing —
   Akhenaten-shaped revolutions and their aftermath are all over the corpus.)
7. **The first district** — banner name for the A0 hunting ground.
8. **UI voice** — whose language do banners/HUD speak: the creatures' side, or a neutral chronicle?

Slop test applies to every answer: *if the name could ship in another game unchanged, it goes
back.*
