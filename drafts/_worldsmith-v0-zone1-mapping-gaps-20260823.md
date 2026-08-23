# Mapping gaps - ZONE 1 (zone_1.json)

Source bundle: bundle (seed 7102, prompt digest 876eb8511ded55de4f2ec14825dd91f2).
Fixture registry: fixtures/game-two/tiles.json (md5 2d0094b4581480fd904bfae2b272ebc8, game-two@d687f3a).

Labels: SAFE-class = presentation/data-only addition game-two could ship
this era; sim-class = gameplay/balance vocabulary, quarantined there (D8).
Every entry is a REPORT for intake to judge - nothing here is ever
auto-applied to game-two (A3/D4); delivery stays owner-gated (D16).

## Unresolved transition targets (intake MUST resolve before delivery)

- transitions[0] at [63, 19] (type absent = edge gate): to "unresolved"; spawn [63, 19] is a placeholder mirror of its own cell (the real spawn lives in a target zone that does not exist yet).

## Dropped gate fields

(none)

## Lossy flattenings

- rock x38 (blocks=true): flattened to wall char '#' over their footprint cells - material identity lost. PROPOSAL (SAFE-class): a statics/decor lane or dedicated tile types would preserve it; intake decides.
- tree x230 (blocks=true): flattened to wall char '#' over their footprint cells - material identity lost. PROPOSAL (SAFE-class): a statics/decor lane or dedicated tile types would preserve it; intake decides.
- bush x76 (blocks=false): VANISHES from the export - the zone JSON has no non-blocking statics lane. PROPOSAL (SAFE-class): a 'decor' entities lane; their loader already fetches a decor key (render-only), but the canonical emitter never emits one.
- 2 station(s) emitted as type "station_slot" (kind-free, loader-inert): kind assignment (bank/altar/vat) is intake business (sim-class) - worldsmith never decided a sim meaning.
- worldsmith region partition NOT exported (2 region(s): region_1 (forest), region_2 (water)) - game-two regions are rect-based town/dungeon/guard intents and biome partitions do not map; their emitter omits empty regions. PROPOSAL (SAFE-class, data-layer): a biome intent, if their region vocabulary ever wants one.

## Unmapped vocabulary types (proposals, never auto-applied)

(none)

## Padded palette variant refs

- grass_c: absent from the artifact palette; padded with the base ref 'grass' color verbatim (their loader demands every variant ref of a used tile type - tile_registry.rb validate_map!). SAFE-class: authoring a real variant hue is intake/T10 business.

## Never emitted (intake-side business)

- hub, floor, drop_gradient, gradient_anchor, water_drained_by, sealed,
  stairs_unlocked_by, decor, regions, tile_types: their emitter omits or
  sidecars own them; worldsmith has no authority over any of them.
- enemy_spawns is always {} (D8 sim-quarantine).
- Presentation palette keys their RENDERER consults at draw time
  (transition, station, grid, motif, motif_rgb, ambient_rgba) are not part
  of the loader's door law and are not artifact business - verify at their
  seat before shipping the zone into data/zones.
