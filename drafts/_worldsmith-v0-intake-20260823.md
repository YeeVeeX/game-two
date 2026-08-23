# WorldSmith v0 intake verdict — zone_1 export lands as ZONE 8 (inert)

Session 54 (hub seat), 2026-08-23. Owner-approved intake (the SPARK-UP
prompt IS the approval; placement + recorded edits approved in-chat:
"approved, proceed as you consider best"). This doc is the D16 delivery
record; the mapping-gap report banks beside it
(`drafts/_worldsmith-v0-zone1-mapping-gaps-20260823.md`).

## Verdict: LOADED-INERT

The worldsmith v0-zone-1b export passes game-two's play-path strict
decoders end to end; the ONE unresolved edge gate refuses NAMED exactly
as designed on both sides and was neutralized at intake (recorded edit,
owner word). The zone lives at `data/zones/zone_8.json`, joined to the
world graph NOWHERE (no way in, no way out — basements/dungeon_1 inert
precedent). An inert zone moves no sim number the pending ritual
measures.

## Digest chain (verified end to end this session)

| artifact | md5 | verified against |
|---|---|---|
| worldsmith `out/v0-demo-export/zone_1.json` | `b1b8db981878060af4e991b12430f86c` | prompt pin + receipt (d) in `worldsmith/docs/receipts/v0-demo-2026-08-23.md` (worldsmith@e63602f) |
| fixture copy `test/fixtures/worldsmith/zone_1_v0_export.json` | `b1b8db981878060af4e991b12430f86c` | byte-identical (read-tool copy; seat-lease lawful — cp/python into the held worldsmith seat is blocked, digest is the arbiter) |
| mapping-gap report source | `3d627159f087b9a1dedd3bcc01f20899` | measured at source |
| banked copy `drafts/_worldsmith-v0-zone1-mapping-gaps-20260823.md` | `3d627159f087b9a1dedd3bcc01f20899` | byte-identical |
| live `data/tiles.json` | `2d0094b4581480fd904bfae2b272ebc8` | == worldsmith's fixture registry pin (report header) — no registry drift for THIS artifact |
| **as-landed** `data/zones/zone_8.json` | `3f3cce1fe8ae84a20f95d05d7cb1c4f3` | diff vs fixture = EXACTLY the two recorded edits below |

Provenance: bundle seed 7102, prompt digest
`876eb8511ded55de4f2ec14825dd91f2`, prompt verbatim "a forest zone
around a lake with a camp on the shore" (receipt §v0-zone-1b).

## Recorded intake edits (owner-approved, nothing else moved)

1. **Re-number**: `name` zone_1 → **zone_8**, `display_name` ZONE 1 →
   **ZONE 8**, filename `zone_8.json`. "ZONE 1" collides with nest's
   live placeholder; ZONE 8 = next free N (de-slop law, trap 4).
2. **Neutralize the unresolved edge gate**: `transitions` → `[]`. The
   delivered gate at [63,19] carried `to: "unresolved"` — worldsmith
   cannot invent our geography (its D16); our loader refuses it NAMED
   (verbatim, now pinned in test):
   `zone edge zone_1 [63, 19] -> unresolved: unknown destination zone "unresolved"`
   Correct behavior on both sides. world.rb:1186 loads EVERY file in
   data/zones/ at boot, so an unneutralized copy would brick bin/play —
   the proof ran fixture-first (trap 2).

## D16 final proof (test/game/worldsmith_intake_test.rb — permanent)

Judged the AS-DELIVERED bytes (fixture) through the play path, no mocks:

- `test_fixture_bytes_match_the_worldsmith_receipt` — provenance lock.
- `test_delivered_zone_passes_the_strict_decoder` — TileMap strict
  decode: 64×40, 3-tile distinct passable pack_spawn, enemy_spawns {}.
- `test_delivered_zone_passes_the_live_registry_cross_check` —
  `TileRegistry#validate_map!` against LIVE tiles.json: all five used
  chars (`,` `g` `#` `~` `w`) registered; every render + variant ref
  (grass_b, padded grass_c) present in the palette.
- `test_unresolved_transition_target_refuses_named_at_world_load` —
  the verbatim refusal above (Crossing.validated_arrivals).
- AS-LANDED half: `test_landed_zone_bytes_match_the_intake_record`
  (md5 pin) + `test_landed_zone_is_inert_in_the_live_world_graph`
  (world's own discovery rule finds it; transitions empty; NO inbound
  edge from any live zone; no arrival geometry targets it).

Suite: 1137/0F at open → **1143/0F** with the zone landed (every World
construction in the suite now loads + validates zone_8). Count rows
moved with the surface (7ab5612 law, two instances):
`tile_map_test.rb` zone count 12→13; `map_artifact_test.rb` panel
labels + "ZONE 8"; `map_checks.json` "Twelve"→"Thirteen labeled zone
panels" + ZONE 8 palette-family clause (same commit as the zone).

## Rule 2 visual artifact

God-view (decision 13 pattern: probes + vision critique, no replay
half): `rake map PROBES=1` + `python harness/vision_critic.py
--verdict <out> --checks harness/map_checks.json` against the updated
checks. Identity pairs (world_loop + low_quay_run, SKIP_CRITIC, 24
captures) run vs a pre-change baseline captured at this session's tip —
the mechanical proof that an inert zone changes no sim byte. Verdicts
recorded below at close.

- Identity pairs: **PASS — 24/24 byte-identical** vs the pre-change
  baseline (world_loop 10/10 + low_quay_run 14/14; both gates rc=0
  determinism-half; verdict tmp/s54_pair_verdict.txt, 24 OK / 0 FAILED).
- Map probes: **PASS 11/11** — artifact
  `captures/map/world_4fb4a5ea_1787518888.png` (13 panels; ZONE 8
  renders forest-and-lake — green land, tree-wall clusters, dirt
  patches, the wood camp cluster at rows 25-27, a large south/east
  water mass — distinct from ZONE 7's meadow-town at a glance; dev
  read the PNG BEFORE the critic ran, sampling-artifact law).
- Vision critique: **PASS 7/7** on the updated checks
  (`map_all_zones_present` = thirteen panels; `map_zone_grids_read`
  names ZONE 8 land-vs-water; log tmp/s54_map_verdict.log). Spend:
  one Bedrock vision call ≈ $0.02-0.05, declared cap $5 — no tripwire.

## Wire-in debt (Lane 2 geography session, owner-directed — NOT this session)

The wire-in session that joins ZONE 8 to the world graph OWES, in its
own commit:

1. Real transition(s) + neighbor assignment + `requires_defeats`/
   `requires_level` pricing (geography lane law: ONE knob per
   re-session).
2. **Identity dose**: motif, motif_rgb, ambient_rgba, grid, floor,
   transition, station palette keys (the live Renderer fetches
   :floor/:grid/:motif at draw time — an inert zone never draws in
   live play, a wired one does; ZoneIdentityDataTest.ZONES gains
   zone_8 in the SAME commit — the exemption comment there names this).
3. Station kind assignment for the two `station_slot` entries at
   [16,25]/[18,25] (sim-class — bank/altar/vat vocabulary).
4. pack_spawn review (delivered spawn hugs the east edge where the
   neutralized gate sat).
5. Rule 2: the wired zone becomes reachable → wall-script coverage per
   the zone-coverage soak law + map re-gate.

## Proposal triage (report → parked rows, dev recommendation attached)

- SAFE-class → PARKING_LOT.md rows added this session: statics/decor
  material identity (rock/tree → '#', bush x76 vanishes); biome region
  intent; grass_c real variant hue.
- sim-class (station kinds) → wire-in checklist above, not parked.
- tiles.json: UNTOUCHED (per intake law + prompt).

## Worldsmith findings (receipted back, none blocking)

- Format verdict: NO format bugs. The export is decoder-clean against
  the live registry; the unresolved target is designed intake business.
- zone_7 fixture drift (01af8448… live vs a0567f37… @d687f3a pin) =
  worldsmith's recorded R1 resync debt — acknowledged, not an intake
  blocker (judged with the LIVE decoder; tiles.json pin still exact).
- Nice-to-have (not owed): emitting `floor: 0` explicitly would
  self-document the surface-level default; game-two defaults it — no
  action required.
