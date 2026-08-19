# World-builder pipeline — grill record (2026-08-19, dev session 17-live)

Stage-1 grill per the grill-and-ticket discipline. Budget declared:
grill = this chat session (≥ implementation-session budget); no code
until the spec closes. This file is the spec's input; the spec is
`docs/superpowers/specs/2026-08-19-world-builder-pipeline.md` (lands
when the open questions below close).

## Ratified by the owner in chat (law; AGENTS.md Lane 3 records the summary)

1. **Intro-arc framing:** the existing six-zone world IS the game's
   introduction arc ("tutorial dungeon" — owner's clarification: "I am
   calling tutorial dungeon to what we already created until now …
   introduces the basic mechanics pretty clearly"). No new starter
   zone is owed; expansion grows outward from this trunk.
2. **World-builder lane approach ("Approved, I agree"):** external pro
   editor front-end (LDtk lead, Tiled fallback) + strict importer to
   zone JSON (refuses invalid NAMED, save-decoder pattern) + hot-reload
   preview loop + god-view map as world-truth artifact. Git stays the
   world store. In-game god mode = later rung (2026-08-17 staging
   unchanged); live editing while seats play = server-authoritative
   family, parked with its named trigger.
3. **Floors (owner ask, "vertical movement"):** zones ARE floors —
   typed transitions (`stairs_up`/`stairs_down`/`hole`/`rope_spot`),
   one-way hole semantics (open Q3), `floor:` depth metadata,
   placeholder naming (FLOOR -1), depth-darkened palettes, per-floor
   god-view rendering (Tibia visibility model, verified KB note:
   classic-2d-mmo-terrain-uo-tibia-map-formats).
4. **Tile grammar (owner idea, verbatim shape):** "actually even be
   able to select different kinds of tiles for the floor that act on a
   certain way (lava: burns, water: swim/drown/water creatures, wood:
   sounds of steps over wood)" — a tile-TYPE registry in data/: each
   type declares render + footstep material + passability + behavior
   hooks. SAFE behaviors ship in the builder era (decorative variants,
   footstep audio materials, region ambience — pure sink/renderer);
   SIM-CLASS behaviors (lava damage, water movement/drowning,
   tile-gated spawns) are post-verdict increments, one gated piece at
   a time ("build our game as a jigsaw puzzle" — owner). The parked
   elemental dossier legs A/C/E are the natural behavior engine for
   hazard tiles when they land.
5. **Region data layer:** named rects bound to rules (town/dungeon/
   guard) — UO/Tibia note: "worth their own lightweight editor". The
   LAYER ships with the builder; protection RULES (safe/battle zones,
   intake idea 2 with the combat-lock trap) wait for the v19
   brainstorm.

## Owner reference images (local untracked copies, gamesmith-addenda precedent)

| File (drafts/_refs/) | md5 | What it shows |
|---|---|---|
| wb-cryofall-resource-palette.png | 99ed85eb… | sci-fi material/currency icon vocabulary (CryoFall) |
| wb-material-states-mining.png | 1a5794ca… | material families in ~5 states each (ore→shards→chunk→pebbles→ingot) + tools |
| wb-aquatic-content-pack.png | 30ffbecf… | ~60-sprite water behavior family (fish/creatures/rod) |
| wb-behavioral-terrain-octet.png | 99eff372… | grass/sand/stone/cave/water/ice/lava/wood — the behavioral-tile idea in one image |
| wb-seamless-texture-atlas.png | e15f4a20… | tileable ground/wall texture families (stock ref, watermarked — style ref only) |
| wb-cryofall-inventory-stats.png | 4cc2f267… | CryoFall player menu: paper-doll + skills tally + grid inventory + hotbar (v19 intake idea 3) |

## Routed to siblings (mails dispatched this session)

- **assets:** tile-sized modular export constraint (per-tile material
  metadata so sprite↔behavior bind by id; material-states pattern) +
  owner style signals (CryoFall charm named twice) + refs table.
- **audio:** future cue families heads-up — footstep materials per
  tile type + region ambience (M5a sink pattern, attack-cue-spec
  shape); no action owed now.
- **lore:** world-expansion era heads-up; placeholder law + no-lore
  standing order UNCHANGED; if naming/fiction ever restarts it
  restarts in their repo. No action owed.

## Council consult (2026-08-19, 2 asks ≤900 tok, receipts: tmp/council_ds_worldbuilder.json · tmp/council_qw_direction.json)

DeepSeek (adversarial-technical) + Qwen3-next (design). Every REFUTED
re-verified against the codebase before acceptance (council
fabrication memory applies). What SURVIVED review → folded as spec
lines; what didn't → named.

**Folded into the spec (7 corrections/hardenings):**
1. **Non-goal, stated:** no cross-floor effects — projectiles/AoE/AI
   never cross transitions (already structurally true; now law so no
   one designs an arrow-through-hole). [DS-Q1, partial]
2. **Respawn/home rules unchanged by floors;** depth lengthens the
   corpse-run walk-back — a watched design knob (depth-pricing debate
   only if playtests name it). [DS-Q1, partial]
3. **LDtk version PIN** + importer refuses `jsonVersion` drift NAMED
   (vendor-sha law pattern) — schema churn was DS's "bites first"
   CONFIRMED. [DS-Q2]
4. **Tile variants are authored data only** — no runtime variant
   randomness, ever (determinism hygiene). The audio-leak half of
   DS-Q3 was REFUTED on re-verify: material cues are pure reads of
   deterministic tile data feeding a proven sink; and the md5 gate
   compares run-A-vs-run-B of the SAME build, never golden frames —
   visual variants can't "break the wall", they just re-judge it.
5. **Wall scales by SURFACE, never by zone** (DS-Q4 CONFIRMED: the
   gate is the first thing 30 zones break): new zones get importer
   validation + a probe-based render gate (god-view/decision-13
   pattern) + sampled soak rotation — NOT a dedicated wall script
   each; the canonical wall stays ~18 surface scripts.
6. **Save stays facts-only (F1 re-seed law)** — builder content adds
   ZERO save vocabulary; DS-Q5's cross-floor-save risk is structurally
   absent (field state never persists), now stated as an inherited
   invariant.
7. **Queue + rhetoric correction (Qwen-Q2, the round's best catch):**
   footstep materials + ambience stay the first SAFE ship but are
   POLISH, not the aliveness bet — reactivity beats ambiance. The
   aliveness bet = the FIRST sim-class tile behavior at the verdict:
   a telegraphed hazard tile (lava — readable per our fairness laws;
   the council's "hidden instakill tile" pitch is REJECTED as-is, it
   violates every legibility law this project runs on). **Tile-grammar
   admission test adopted ("the 10-minute rule"):** every tile type
   must alter a tactical decision or emotional state within 10 minutes
   of play, or it doesn't ship — harmonizes with the standing
   every-commit-is-felt law. [Qwen-Q1 edge-tell + Q2 synthesis]

**Named and set aside:** Qwen-Q3 ("you have no juice: no hitstop, no
shake, no audio") is FACTUALLY REFUTED by the codebase (hitstop 3/8
frames, three shake channels, kill pops, hurt flashes, owner-composed
cue set — all gate-verified); the surviving kernel — outside players
meet the ASSET era's first impression before any system — is already
the recorded asset-era understanding. Qwen Q4/Q5 lost to max_tokens;
not re-asked (budget: one round; housing-trap reasoning already
banked in PARKING_LOT with its trigger).

## Open grill questions (spec waits on these)

- **Q-merge:** new floors/zones merge into the LIVE world only after
  the SEVENTEENTH verdict (dev recommendation), or earlier under a
  pre-registered caveat?
- **Q-holes:** holes one-way (commitment device + rope spots — dev
  recommendation) or always two-way?
- **Q-first-behavior:** first SAFE behavior family to ship with the
  pilot — dev recommendation: footstep materials + region ambience
  (pure audio sink, zero sim risk, feels magical).
- **Q-pilot-content:** first authored content = a multi-floor dungeon
  off which existing zone? (Implied by the floors ask; confirm entry
  point + depth.)

## Measurement-hygiene note (standing, restated for this lane)

The SEVENTEENTH's world stays byte-stable until its verdict: builder
tooling, importer, refs, specs are all repo-side and touch nothing the
ritual measures. Any content merge before the verdict needs its caveat
pre-registered in the fun-verify skeleton (audio-novelty precedent).
