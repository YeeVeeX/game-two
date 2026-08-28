# Review — Junior's ZONE 2 retheme directions (three concepts, 2026-08-28)

**Delivery:** `b71cc8b` (Junior seat, 04:32 -0300) — direction intake per
`docs/MAP_EDITING.md` role split (Junior directs, hub executes,
post-verdict). Doc `drafts/_junior-zone2-map-directions-20260828.md` +
three PNGs in `drafts/_refs/`. Digests verified against git blobs 3/3:
v1 `3e7af4e3f17c9f11cde9a443733390c0` · v2b
`0ba972e094bf4ed065a1470e618dd03f` · v3
`124155a71359c8b23c37c0dbbe183e3b`. Reviewer: hub dev-of-record, s113.
Status: **PASS as direction intake + v20 grill input** — banked,
EXECUTES nothing (map-lane law + ritual freeze; Junior scoped it that
way himself).

## What it delivers (faithful summary)

Three alternative rethemes of the SAME zone — ZONE 2 (`district`),
floor 1 of the forest-first descent (parent proposal: PASS at s109) —
for the pair to pick one or pieces. Each sandbox-playtested by Junior
off-repo (isolated copy, repo untouched), BFS connectivity-proven
before human test, and approved by him in play. Playable zone-JSONs
held on his machine (`Desktop/game-two-conceitos/*.json`) as
post-verdict transcription sources. One v20 ask surfaced: a second
wall class in the tile registry.

## Independent verification (claims vs repo ground truth)

| Claim | Verdict |
|---|---|
| ZONE 2 = district, current W→E flow | CONFIRMED — 44×26, transitions [0,13]→nest (W) · [42,13]→camp sealed (E); v1's "flow preserved" matches ground truth |
| PNG md5s in-doc | CONFIRMED — all three == git blob md5s |
| "one wall color per zone" limitation | **CONFIRMED TRUE** — `data/tiles.json` has exactly ONE `passability: wall` type; `TileMap#wall?` = `!passable?`; renderer draws every wall through the single `palette[:wall]` RGB (renderer.rb wall pass keys `:wall`). Red inner wall + near-black bounds cannot coexist today. |
| "D7 already provided hooks" | CONFIRMED with a caveat — WB spec D7 declares `render` as open palette ref + reserved `hooks`; the registry accepts a new type as pure data, BUT the renderer's wall pass draws by the `:wall` key, not by render-ref → the ask costs: tiles.json entry + palette key + importer int_grid mapping + a small renderer touch + Rule 2 re-gate. Well-formed, correctly routed to v20. |
| Totem = slate candidate 3 convergence | CONFIRMED — same convergence recorded in the s109 forest-first review (healing pillars) |
| Spawn headcounts sane (25 / 27 / 20+5) | CONFIRMED CONSERVATIVE — today's district: 15 enemies / 1,144 tiles (~1/76). v1 ~1/183 · v2b ~1/169 · v3 ~1/108 — all LOWER density than live, grouped deliberately |
| "repo never touched" by the sandbox | CONFIRMED — freeze-watch clean through `b71cc8b` (commit is docs+PNGs only) |
| medusas = existing archetype | CONFIRMED — `rusher_hater` is a live enemy type (3 in district today); no new sim behavior smuggled in |

## Adversarial rows (execution-time; none block intake)

1. **Water is PASSABLE today** (`tiles.json` water `passability:
   floor`; swim = reserved, D7). v2b already solved its chasm the
   right way — wall-ringed rock, iterated in his test (that is WHY
   "parte alta inalcançável" BFS-proves). v1's 4 water pits with
   walkways: today those pits are walkable unless wall-ringed —
   execution must ring them or accept cosmetic water until the
   water-movement sim increment (post-verdict, one gated piece).
2. **v1 is the largest zone ever proposed** — 88×52 = 4,576 tiles =
   1.79× zone_8 (64×40, current largest). Run `rake perf` against the
   transcribed zone BEFORE wire-in (existing tool, cheap).
3. **Provenance pin** — district is a pilot-four importer emission:
   transcription lands in `authoring/pilot.ldtk` →
   `tools/import_ldtk.rb`, never hand-edited JSON. His sandbox JSONs
   are geometry proof, not landable artifacts — the doc frames this
   correctly ("transcrição").
4. **v3's central hole auto-fires** (typed-transition law) inside a
   5-guardian arena — correct Tibia descent grammar (commit under
   pressure), but guard-ring sizing must keep the hole from reading
   as a free combat-escape hatch. Its "floor -2" target = ZONE 3
   under forest-first — the concept composes with the descent chain
   literally.
5. **Graph endpoints hang on the grill's re-root decision** (s109 row
   1: re-root vs parallel loop). All three concepts survive either
   answer (edge flows re-wire; v3's hole IS the descent) — a pick
   before the grill is direction preference, not wiring.
6. **Retheme = full Rule 2 re-gate** of every wall script that
   touches district (`world_loop` family) + recalibration; budget in
   tickets at execution (same law the s109 review priced).

## Design evaluation (touchstones)

- **v1 "Caverna de câmaras"** — Czepeku cave language, flow
  preserved, 8 arena-chambers fit pack combat + grouped spawns. The
  3-wide-tunnel finding (1-wide claustrophobic in the real viewport)
  is genuine playtest knowledge — adopt it as a corridor standard
  regardless of pick. Weaknesses: biggest perf footprint; most
  generic identity of the three, and chamber-cavern overlaps
  DUNGEON 1's existing language.
- **v2b "Dois espaços + 4 pontes"** — the strongest tactical
  statement: bridge choice = visible commitment, guarded key bridges
  = chokepoint grammar (Tibia bridges/passes), and it rehearses the
  totem's contested-ground logic (value priced in position) before
  the totem exists. Impassable chasm solved with TODAY's engine (wall
  ring) — zero new asks. Risk: two-halves can play as two rooms; his
  west-dry/east-alive theming is the mitigation, keep it.
- **v3 "MEDUSA LOWER"** — strongest identity: a real Tibia touchstone
  (Medusa Tower) inverted downward, literal descent grammar, smallest
  and cheapest. Full fidelity gates on the v20 second-wall-class ask
  (red inner wall vs near-black bounds); a one-wall-color reduced
  version is possible today.

**Dev-of-record read (humans pick; pieces-of-each is live per
Junior):** if forest-first survives the grill, **v2b is the strongest
ZONE 2 / floor 1** — legible geography-of-risk in the first minute,
zero new engine asks. **Bank v3 for a deeper floor** (hole-descent +
guardian-circle grammar fits floor 2→3, and by then the wall-class
ask may be shipped). **Mine v1** for the arena-grouping + 3-wide
standard rather than picking it wholesale.

## Routing

- **NOW (docs-only):** banked + this review + registered in the v20
  grill index (joins: forest-first, archaeology A-rows, underground
  ask, J-T4..T8; the wall-class ask joins as its own grill row).
- **NO outbound to Junior** on this until ritual 10/10 is banked
  (contamination guard — geography is ritual-adjacent; same rule the
  s109 review applied; the "4 ANDARES" discrepancy stays HELD too).
  The pick conversation is the peers' own chat whenever they choose.
- **POST-VERDICT:** pick (or fusion) → transcription via the
  provenance path → perf smoke (row 2) → Rule 2 gates → wire-in.

**Verdict: PASS (banked, grill-ready).** The map-lane role split is
working exactly as chartered: direction arrives playtested with
honest limitations named, mechanical proof done off-repo, and the one
engine ask routed to the grill instead of smuggled in.
