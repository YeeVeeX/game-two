# World-builder pipeline + pilot content — design spec (2026-08-19)

Owner-ratified lane (AGENTS.md Lane 3). Grill record + council receipts:
`drafts/_world-builder-grill-20260819.md` (supersedes nothing; the
SEVENTEENTH spec stays the pending arbiter for the live world).
Working language English; every player-visible name is a placeholder
(standing order 2026-08-16). Tickets at the end are the durable
execution artifact; one ticket = one fresh session.

## Owner vision (verbatim north star, 2026-08-19 chat — "nothing written on stone")

> lets create an "open world" zone outside of the "tutorial dungeon"
> after defeating the boss that has some grass and beautifull
> trees/flora/fauna without threads on some radio that is limited to
> an area surrounded by trees/fence/structures that take you to the
> starting town that will have houses, a few basements, a "depot",
> stores for potions (mana, health, weapon/armory store, npc's a net
> of simple starting quests to introduce new mechanics/systems as we
> add them, think of some combination of Kakariko village from Zelda
> OoT (with a well filled with water that gives access to a hidden
> dungeon when drained out after completing some errands/questline
> that unlocks a room in a house that drains the well)

Dev reading (flagged in chat): "without threads on some radio" =
*without threats in some radius*. Touchstones cited: Kakariko Village
(Zelda OoT), Tibia depot, CryoFall charm (style, assets era).

## Decisions (D1–D12, closed)

- **D1 — Authoring front-end = LDtk, version-PINNED.** Owner draws in
  LDtk; a strict importer converts to zone JSON. The importer refuses
  `jsonVersion` drift NAMED (vendor-sha ceremony pattern). Tiled is
  the recorded fallback if the spike fails. Git stays the world store.
  **T2 pin (2026-08-19, T1 evidence):** LDtk **1.5.3** — refusal key
  `jsonVersion == "1.5.3"` ONLY (`appBuildId` churns per resave,
  observed 473702→473703, and is explicitly NOT pinned); installer md5
  `11f9057d5889c0e51eee2ed43e8096cf` (Windows, per-user, silent `/S`).
  Pin ceremony: decline in-app update prompts; an upgrade is a
  deliberate re-pin of this line + importer + fixtures, never an
  accident.
- **D2 — Importer is the only door.** LDtk output never ships raw; the
  importer emits our zone JSON (ASCII rows + entities) and REFUSES
  invalid content with named errors (save-decoder pattern). Round-trip
  property: import(export(zone)) byte-stable for authored zones.
  **T2 wording (2026-08-19, ratifying the T1 sidecar proposal):** LDtk
  owns SPATIAL truth (IntGrid tiles, entities, `display_name`/`floor`
  level fields); the per-zone sidecar (`<zone>.sidecar.json`) owns
  presentation/tuning scalars — `palette` (incl. alpha),
  `drop_gradient`, `gradient_anchor`, `tile_size` — and NOTHING else
  (unknown sidecar keys refuse NAMED; hub/decor mapping is T4's
  deliberate extension if a pipeline zone ever needs them). The
  importer's emitter defines the CANONICAL zone-JSON byte format; the
  round-trip property is the import→emit→import fixpoint
  (byte-stable), enforced by test. Shipped: `tools/import_ldtk.rb`
  (every T1 wrinkle a named refusal) + `test/tools/import_ldtk_test.rb`
  (real 1.5.3 vendor-byte fixture, md5-pinned, `.gitattributes -text`).
- **D3 — Floors = zones + typed transitions.** New transition types:
  `stairs_up` / `stairs_down` / `hole` / `rope_spot`; zones gain
  `floor:` depth metadata (0 = surface, negative = down). Placeholder
  naming: FLOOR -1 style in banners. Depth darkens palettes (authored,
  not computed).
- **D4 — Holes are ONE-WAY** (owner-ratified): falling commits you;
  rope spots (station-type interact) are the way back up. Rope = free
  interact v0; whether a rope is an ITEM waits for the items cycle.
  **Amendment (owner, same day — revisitability):** a hole may declare
  `stairs_unlocked_by: <fact>` — when that breach-family persistent
  fact is set, the hole renders and behaves as two-way stairs (the
  shortcut-unlock pattern: Zelda dungeon shortcuts / Souls elevator;
  the quest era later re-skins the unlock beat). Backtracking comfort
  is a designed loop, not an accident: towns/zones stay revisitable
  (materials, future NPCs/quests) per the owner's WoW/TES framing.
  Schema lands in T2; DUNGEON 1 MAY use one if authoring time allows
  (optional, not owed in the pilot). **T2 note (2026-08-19):**
  `stairs_unlocked_by` schema + loader validation SHIPPED (TileMap v2:
  hole-only, non-empty fact name, refusals named); behavior wiring
  stays T4/T5.
- **D5 — No cross-floor effects, ever** (council fold): projectiles,
  AoE, AI pursuit, targeting never cross a transition. Structurally
  true today; now law so nothing gets designed against it.
- **D6 — Floors do not touch respawn/home rules.** Depth lengthens the
  corpse-run walk-back — a watched knob; a depth-pricing debate opens
  only if playtests name it.
- **D7 — Tile-type registry** (`data/tiles.json`): each type declares
  `render` (palette ref now, sprite id later) + `footstep` material +
  `passability` (wall/floor; swim reserved) + `hooks` (reserved:
  hazard, spawn_affinity). SAFE behaviors ship in this era (visual
  variants, footstep materials, region ambience — pure sink/renderer).
  SIM behaviors (lava damage, water movement, tile-gated spawns) are
  post-verdict increments, one gated piece each. Variants are authored
  data only — no runtime randomness (determinism hygiene).
- **D8 — The 10-minute rule** (council fold, harmonizes with the
  every-commit-is-felt law): a tile type ships only if it alters a
  tactical decision or an emotional state within 10 minutes of play.
  First SAFE family (owner-ratified): footstep materials + region
  ambience — correctly framed as POLISH; the aliveness bet is the
  first sim-class hazard tile (lava, telegraphed per our legibility
  laws) at the verdict gate.
- **D9 — Region data layer.** Named rects per zone (`regions:` list:
  id, rect, intent tag: town/dungeon/guard). The LAYER ships now
  (importer + god-view render + ambience keying); RULES (safe-zone
  damage/pursuit gates — intake idea 2 with the combat-lock trap) wait
  for the v19 brainstorm.
- **D10 — Wall scales by SURFACE, never by zone** (council fold): new
  zones get importer validation + a probe-based render gate
  (map_checks/decision-13 pattern) + soak-rotation coverage — NOT a
  dedicated wall script each. The canonical wall stays ~18 surface
  scripts; ONE new surface script (multi-floor descent) joins when the
  pilot wires in.
- **D11 — Save stays facts-only** (F1 re-seed law, restated as
  inherited invariant): builder content adds ZERO save vocabulary. The
  well-drain persists through the EXISTING `breached` family (a
  breach-variant fact), not a new schema field.
- **D12 — Merge law (owner-ratified):** new content code+data may land
  in main INERT (no transition from the live graph reaches it; dev
  entry via `--start-zone`), but WIRING it into the live world (the
  boss-gate transition) happens only after the SEVENTEENTH verdict.
  The measured world stays byte-stable until then.

## Pilot content (the first authored pieces — all placeholder-named)

- **ZONE 7 (surface, floor 0)** — the peaceful open zone: grass/trees/
  flora tile types + decor, enclosed by tree/fence/structure tiles
  (bounded radius), ZERO enemy spawns (threat-free by data, not by
  rules). First carrier of footstep materials + region ambience.
- **TOWN 1 (region inside ZONE 7)** — the starting town STAGE:
  houses (HOUSE 1..N) with interiors; ≥2 basements via `stairs_down`
  (FLOOR -1); a depot v0 = bank station + `town` region intent (safe
  RULES arrive with the v19 debate); plaza with distinct footstep
  material. Empty SLOTS designed to receive future cycles: stores
  (items cycle), NPCs (NPC cycle), quest net (quest cycle), session-
  ledger board (results surface, v19-class), map table (stays PARKED —
  in-game map view; promotion candidate named).
- **THE WELL (TOWN 1)** — water-tile well; a priced station action
  (toll machinery verbatim — the future questline re-skins this
  unlock) flips a breach-family fact `well_drained`; drained state
  swaps water→dry tiles and opens a **one-way hole → DUNGEON 1**.
- **DUNGEON 1 (FLOOR -1 under TOWN 1)** — the hidden dungeon: first
  authored multi-floor descent; rope spot back up; combat content
  authored but conservative (it must not retune difficulty the ritual
  measures — merge is post-verdict anyway per D12).
- **THE GATE** — ZONE 7 is reached from the existing arc via a
  transition gated on the persisted `boss_1_defeats ≥ 1` fact
  (breach-variant reading a fact instead of a price). Wired at D12
  time, not before.

## Non-goals (recorded so review never re-litigates)

No in-game editor / map view / teleport (parked, unchanged). No NPCs,
quests, stores, potions, or items now (slots only; each has its own
future cycle). No ambient fauna now (sim-class AI faction —
PARKING_LOT entry with the 10-minute-rule note). No live placement
while seats play (server-authoritative family, parked). No safe-zone
RULES (v19 debate). No lore, no fiction names (standing order). No
LDtk auto-upgrade (pin + ceremony only).

## Verification strategy (Rule 2/5 mapping)

- Importer: minitest with REAL LDtk export fixtures (no mocks) —
  round-trip byte-stability, refusal cases NAMED (bad version, unknown
  tile id, overlapping entities, unreachable transitions).
- New zones: probe-based render gate (staged facts + pixel asserts +
  vision critique — god-view/decision-13 pattern) per zone; soak
  rotation (`ZONES=`) gains ZONE 7/DUNGEON 1 for bot coverage
  (scratch saves, quarantine laws unchanged).
- Tile registry + footstep/ambience: pure-sink proof extends the M5a
  test (digest byte-identical with audio attached vs not, now over
  material-keyed cues); visual variants ride the standard gate.
- The canonical wall stays intact; `multi_floor_descent.json` joins
  `harness/scripts/` only when the pilot WIRES in (D12), with a
  full wall re-run at that merge.
- Suite green via hooks on every commit; every visual change through
  the blocking gate — unchanged, non-negotiable.

## Tickets (one per fresh session; verify step + done-condition each)

- **T1 — LDtk spike.** Goal: prove the pipeline direction cheaply.
  Install pinned LDtk; rebuild `district` in it; write a THROWAWAY
  import script producing byte-plausible zone JSON; walk the imported
  zone in-game (solo, scratch). Files: `tmp/` only + a findings doc
  `drafts/_ldtk-spike-findings-<date>.md`. Verify: imported district
  boots + plays; findings doc names schema risks. Done: GO/NO-GO on
  LDtk recorded (NO-GO → Tiled fallback ticket replaces T2's front
  half). NO production code.
- **T2 — Importer + schema v2.** Goal: production importer
  (`tools/import_ldtk.rb`) + zone schema gains typed transitions,
  `floor:`, `regions:`, tile-type ids; `data/tiles.json` registry v0
  (render+footstep+passability only). Strict refusals + round-trip
  tests (real fixtures). Existing six zones re-emit BYTE-IDENTICAL
  through the new loader (regression bar) — the live world untouched.
  Verify: `rake` green + wall spot-gate on `low_quay_run` +
  `world_loop`. Done: importer refuses the named bad cases; six zones
  byte-stable.
- **T3 — Safe tile behaviors.** Goal: footstep materials + region
  ambience wired as pure sinks (cue-spec mail to audio seat first —
  owner records renders at his pace; noDevice fallback fine) + flora
  visual variants. Pure-sink test extension; Rule 2 gate per visual
  surface. Verify: digest-invariance test + gate PASS. Done: walking
  district vs nest vs a grass fixture zone SOUNDS different (or
  noDevice-logs the material keys), zero sim delta.
- **T4 — Pilot content authoring.** Goal: ZONE 7 + TOWN 1 + THE WELL
  + DUNGEON 1 authored IN LDTK through the T2 importer; boss-gate
  transition + well-drain fact implemented but the zone stays INERT
  (D12 — no live-graph transition; dev entry via `--start-zone`).
  Probe gates per zone + soak rotation extended. Verify: probe gate
  PASS ×2 zones; soak episode in ZONE 7/DUNGEON 1 PASS; live-world
  saves byte-stable. Done: owner can walk the town, drain the well,
  fall into DUNGEON 1, rope back — from a dev launch.
- **T5 — Wire-in (POST-VERDICT only).** Goal: the boss-gated
  transition joins the live graph; `multi_floor_descent.json` joins
  the wall; full wall sweep; ritual-world caveat block updated. Gated
  on: SEVENTEENTH adjudication complete. Verify: full wall PASS +
  chain-anchor discipline (save moves only via logged play). Done:
  ZONE 7 reachable in the shared world.

Budgets: T1–T4 ≈ one attended session each; council spend this lane
already consumed ($0.01, receipts banked); no further consults owed
unless a ticket hits an irreversible fork. Ideation continues in
`drafts/_junior-v19-ideas-20260819.md` + PARKING_LOT — never in
tickets mid-flight.
