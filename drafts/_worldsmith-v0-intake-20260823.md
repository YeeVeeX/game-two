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

**EXECUTED s70 (2026-08-24) — all five rows, one gated commit.** Receipts:

1. **The way in:** dungeon_1 far-east chamber corridor [29,4] → zone_8
   spawn [62,18] — `rope_spot` (gate-consent law: climbing out is the
   interact verb) + `requires_level: 8` (the s68 ladder's frontier rung;
   composes with the chamber's toll geography). Authored in
   `authoring/pilot.ldtk` (uid-116 fieldDef, s69 mutation pattern) →
   canonical re-import; sibling emissions byte-identical. Return FREE:
   zone_8 [63,19] (the delivered gate corner, hand-edit — worldsmith
   JSON custody) → dungeon_1 spawn [29,4], typeless v1 edge gate
   (tile_map_test law). Arrival spawns sit beside — never on — the far
   way (the low_quay/zone_7 anti-ping-pong pattern; [62,18] keeps the
   ally spread off the auto-fire gate tile). As-landed md5 pin moved
   CONSCIOUSLY `3f3cce1f…` → `89ba053f0436b3d422cccc9dbf7f6617`;
   `landed_zone_is_inert` FLIPPED to `landed_zone_is_wired` (reachability
   pin: way + return + validated arrivals). D12 inertness law gained its
   SECOND ratified edge pair (tile_registry_test).
2. **Identity dose:** floor [38,44,28] / grid [46,54,36] / transition
   gold / station + station_altar + station_vat (camp vocabulary) /
   motif chip [52,64,38] / ambient [70,160,90,10] — all identity-law
   compliant (spread 76, motif luma 57.4 between floor and midpoint);
   ZoneIdentityDataTest.ZONES gained zone_8 same commit.
3. **Station slots:** [16,25] → **vat**, [18,25] → **altar** (deep-side
   camp pair; no-bank-in-deep KEPT). Proven live in the wall reel: a
   striker died crossing, the camp vat regrew him (tribute 16, banked
   20→4, `body_regrown` in the manifest).
4. **pack_spawn review:** east-edge gate pocket → camp shore
   [[12,26],[13,26],[14,26]] (the zone's authored anchor).
5. **Rule 2:** NEW wall script `harness/scripts/zone8_crossing.json`
   (L8+banked staged; seal toll → fork door → chamber fight → rope
   crossing → forest walk → camp vat regrow; 5 captures, manifest
   zone_entered/seal_breached/body_regrown/tribute_paid) — GATE PASS
   (5/5 byte-identical + vision) + MANIFEST PASS. Affected dungeon
   reels re-gated: dungeon_fork PASS, multi_floor_descent PASS. Map
   re-gate: PROBES 13/13 (two NEW pins: frontier way level-locked at
   staged L6; zone_8 return gold) + vision 7/7 PASS. Tier row zone_8
   150/100 now live-reachable (enemy_spawns stays {} — the zone lands
   wired but SPARSE; interior fill = a later wave).

Original debt list (for the record):

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
  **CORRECTION (2026-08-23, worldsmith mail `2026-08-23-worldsmith-
  zone7-drift-correction.md`): the drift was PHANTOM — CRLF working-
  tree checkout vs LF git blob. Re-verified at this seat:
  `git show HEAD:data/zones/zone_7.json | md5sum` = `a0567f37…` == the
  worldsmith pin, byte-exact. The R1 resync debt is VOID.**
- Nice-to-have (not owed): emitting `floor: 0` explicitly would
  self-document the surface-level default; game-two defaults it — no
  action required.
