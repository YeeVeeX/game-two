# Content-fill design — dungeon_1 / basements + ZONE 8 wire-in plan (s68, 2026-08-24)

Owner datum (s67, verbatim): "bajé a los sotanos y al dungeon 1 pero no
había nada interesante" — literal: basements carry ZERO spawns and ZERO
stations; dungeon_1 has 4r+1rh and nothing else. Ladder slot: ratified
s67 (difficulty tier → **content-fill + ZONE 8 wire-in** → B1-T1).
Pattern menu: Kimi Q3, banked `tmp/council_kimi_s67.json` (no new
spend). Difficulty context now LIVE (s68 `0d5cc40`): gates 4/5/6 on the
town ways; tiers basements 50/25 · dungeon 100/75 · zone_8 150/100.
**This doc is the design; authoring is its own session (WB pipeline law).**

## Non-negotiables carried into authoring

- **Pipeline**: dungeon_1/basements live in `authoring/pilot.ldtk` —
  every geometry/entity change goes LDtk → re-import → canonical
  emission (provenance pin `pilot_authoring_test`; the s68 precedent:
  parse-mutate-dump reproduces the file byte-style-exact). zone_8 is
  worldsmith JSON — its as-landed md5 pin moves CONSCIOUSLY in the
  wire-in commit (`worldsmith_intake_test` names it).
- **SIM-CLASS routing**: spawns, station kinds, seals, transitions =
  one gated piece at a time; SAFE decorative work ships freely.
- **No-bank-in-deep KEPT** (foundation B2/B3): no bank station below
  the surface — TOWN 1 (zone_7) stays the deep-side banking anchor.
  Field vats/seals/altars are legal vocabulary; banks are not.
- **Ritual hygiene**: spawn/station data lands BEFORE ritual staging
  freezes; after staging, the numbers wait for the verdict.
- Affected wall scripts re-gate in the same commit
  (`multi_floor_descent` for dungeon_1; new coverage per zone-coverage
  soak law when zones become reachable).

## Zone-by-zone (patterns from the banked menu, mapped to real geometry)

### basement_1 (8×8 cellar, L4 gate, tier 50/25) — "first taste of the deep"

Pattern: plain **spawn pocket with drop payoff** (no station). Husk
family (kill_xp 8, drop economy pays the visit); 3-4 spawns in the
single room. The L4 gate already frames it as "come back later" — the
room's job is to pay that anticipation off with the first
tiered fight, not to be a puzzle. Tibia parallel: town sewers.

### basement_2 (8×8 cellar, L5 gate, tier 50/25) — "the priced pocket"

Pattern: **Dead-End Toll Pocket** (menu #1), miniature: a seal mid-room
splits the cellar; behind it, elevated spawn density (husk+rusher mix)
in the cul-de-sac. Sunk toll + no lateral escape + drops behind the
seal. First appearance of "pay to open the fight you then have to win"
below the town. Seal-gating law `abe04d6` applies (the seal's `opens`
names a TRUTHY-sealed transition… seals here gate a WAY only if we add
an interior door — if the authored shape is a pure room-divide, the
seal opens an interior transition tile; verify the law's shape at
authoring).

### dungeon_1 (32×20, L6 gate, tier 100/75, floor -1) — "the passage"

Two moves, one identity: the dungeon stops being a dead-end pocket and
becomes the PASSAGE to the frontier.

1. Pattern: **Gated Loop with Pocket Fork** (menu #3) on the existing
   geometry (entry landing [15,3] top-center, rope [3,16] bottom-left,
   wall clusters already form corridors): one branch = level-gated…
   no — one branch = seal-toll BYPASS (cheap, no reward), other branch
   = the spawn-pocket circuit (fight through, drops + density). Spawn
   roster grows (rusher/rusher_hater mix, +husks as fodder) — exact
   counts at authoring, tier does the stat work.
2. **ZONE 8 attaches HERE** (wire-in recommendation, dev of record):
   a stairs/rope way in dungeon_1's far-east corridor →
   zone_8 [63,19]-family east edge (its neutralized-gate corner;
   pack_spawn review rides the wire-in per the intake debt).
   `requires_level: 8` on the dungeon-side way (the s68 ladder's
   frontier rung; tier row 150/100 already dormant-live). Return free.
   WHY the dungeon and not the town hub: a chain (town L4/5/6 →
   dungeon → L8 frontier) builds a traversable risk GRADIENT — the
   Tibia touchstone is dungeons as passages between surface regions,
   and the foundation vision says "a real geography of risk", not a
   star of doors on one plaza. The town still SHOWS the ladder's
   first three rungs; the dungeon earns its crossing traffic.
   (Alternative recorded: zone_7 direct spoke — maximally legible from
   the hub but flattens the world into hub-and-spokes; REJECTED at dev
   discretion, owner veto stands.)

### ZONE 8 wire-in (executes the intake debt list, `_worldsmith-v0-intake-20260823.md` §Wire-in debt)

All five debt rows owed in the wire-in commit: real transition(s) as
above · identity dose (motif/palette keys + ZoneIdentityDataTest row) ·
station kinds for the two `station_slot`s at [16,25]/[18,25] —
recommendation: **vat + altar pair** (the deep-side camp: regrow + mark
afield at full price, bank stays in town; the slots sit beside the
'w' well structure, reading as a waystation camp) · pack_spawn review ·
Rule 2 wall coverage + map re-gate. Sequencing: wire-in is its OWN
gated commit AFTER dungeon_1's fill (ONE gated piece at a time).

## Explicitly NOT in this wave

Corpse-Deposit Threshold + Nested Altar Gauntlet (menu #4/#5) — parked
for zone_8's INTERIOR fill (a later wave; the zone lands wired but
sparse). New enemy kits/spell classes (v20 intake, ratified s67). Any
kill_xp change (the s68 fork stands). Station-Locked Breach (menu #2)
— needs paired stations across a transition; no current geometry wants
it; parked.

## Kimi Q5 debt (banked s67, binding on this wave's authoring)

Deferred content must cite the owners' LIVED history — the harvest
docs are the corpus (sessions 13-15: the varekka kills, the level-8
climb, the first crossings). Concretely: dungeon_1's fill is the zone
they ALREADY explored and found empty — the fill must read as "this
was always down here past where you turned back", not as a re-skin of
district (different kit mix + the toll pocket does that mechanically;
placeholder naming stays, lore stays OUTSIDE the repo).
