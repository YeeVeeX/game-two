# J-T3 — zone_8 approach pockets (Junior seat, 2026-08-26)

Ticket: `drafts/_junior-parallel-lane-20260826.md` §J-T3 (owner word,
s91). Brief: my v20 input item 4 ("zone_8 parece vazio pelo seu
tamanho") + the J-T2 blueprint's anchor (east arrival [62,18] → DUNGEON 2
NW entrance [~5,5]). Paper-only under the armed freeze: zone_8 is a
worldsmith emission with an md5 intake pin — NEVER hand-edited; this doc
designs, the worldsmith/WB lane authors post-verdict. No balance
numbers: kits named, counts/HP deferred to the grill. Patterns cite the
s69 playbook (`drafts/_content-fill-design-20260824.md`).

## a. Route read — the [62,18] → [~5,5] walk as it exists today

Read from `data/zones/zone_8.json` this session (64×40; legend: `g`
grass · `,` dirt · `#` rock/wall · `~` water · `w` well structure):

- **Arrival [62,18], east edge:** a dirt band (x≈59-63) runs north-south
  along the border — the natural first corridor. South of the arrival is
  the already-lived half (vat+altar camp [16-18,25], the well, the big
  south lakes). The route to D2 goes NORTH.
- **NE lake [53-60, 2-4]:** the only landmark on the route's first leg —
  a water pocket ringed by dirt shore. The dirt band funnels the walk
  right past its southern shore.
- **Central rock formation [26-40, 2-14]:** the map's dominant unbuilt
  feature — rock walls (`#` clusters at x≈28-31/33-38 across rows 2-14)
  enclosing an interior DIRT hollow (rows 5-9, x≈28-36) with two natural
  mouths (west row ~7, east row ~5-6). Today it is scenery you walk
  around; nothing lives in it.
- **NW dirt field [0-12, 0-8]:** the D2 entrance quadrant — a broad
  empty dirt plain with sparse rocks ([4,4], [6,8]-family). Dead air
  end-to-end.
- **Dead-air legs today:** (1) NE lake → central formation (~15 tiles of
  bare grass); (2) formation → NW corner (~15 tiles of bare dirt/grass).
  The whole ~70-tile walk offers zero decisions — the mechanical root of
  item 4, now with the D2 anchor to aim at.

## b. Two pocket sketches

### Pocket A — "the drowned jetty" (NE lake shore, ~[54-60, 2-5])

s69 pattern: **spawn pocket with drop payoff** (the basement_1 shape —
no station, no seal; the room's job is to pay anticipation off with a
fight). First contact of the route: light posture.

```
      x: 50........63
 r1   g g g g , , , , , , g g # g
 r2   g g g , ~ ~ ~ ~ ~ ~ , g # g     ~ : NE lake (existing)
 r3   g g g g , ~ ~ ~ ~ ~ , g g g     , : existing dirt shore = the jetty walk
 r4   g g g g g , ~ ~ ~ ~ , g g g     * : spawn posture zone (husk family)
 r5   g g g g g g , *, *, , g g g ,   L : landmark anchor (see below)
              (south shore, mouth to the dirt band)
```

- Geometry is ALREADY there: the lake + dirt shore need zero terrain
  moves; the pocket is spawns + landmark identity on the existing shore.
- Landmark: one authored structure tile-cluster on the south shore
  (`L`, ~[57,5]-family) — worldsmith vocabulary; visual identity =
  water-adjacent (the drowned read; SAFE-class decor family, zone_8's
  own `~`/`,` palette).
- Kits: **husk family** (fodder-first contact; the s69 basement_1
  precedent). Counts = grill.
- Typed transitions: none. No seal (nothing to gate — the fight IS the
  content).

### Pocket B — "the hollow camp" (central rock formation, ~[28-38, 4-10])

s69 pattern: **Dead-End Toll Pocket, unsealed variant** — the enclosure
and its two mouths do the toll work GEOMETRICALLY (block-cap law: a
2-tile mouth is holdable), without spending a seal. The route's main
event, sitting almost exactly mid-walk.

```
      x: 26..............42
 r2   g g # g g g g g # # # # g g        # : existing rock walls
 r3   g g g g g g g g # # # # g # # #    , : existing interior dirt hollow
 r4   g g g # # # g g g # # # g # # #    M : mouths (west r7, east r5-6)
 r5   # g g g g g g g # # # M , , , #    * : spawn posture (rusher+husk mix)
 r6   g g g g g g g g # # # M , *, ,     D : drop payoff deep in the hollow
 r7   M , , , , *, , , g g g g , , ,     L : landmark anchor (center, ~[33,8])
 r8   g g , *, , D , #, g g g g , ,
 r9   g g , , L , # # g g g g g
 r10  g g g g , # # # # # g g g
```

- The rock enclosure EXISTS; the design adds life inside it: spawns in
  the hollow, drop payoff at the deep end, landmark at center.
- Denser posture than A (**rusher + husk mix**, rusher_hater as the
  grill's option) — the route's difficulty rises toward D2, the radial
  gradient applied inside one map (J-T1 dossier §3 logic, KB seed 2).
- Clump geometry for free: the hollow's corners are lure-clump-burst
  bait (`_tibia-aoe-research-20260813.md` principles 2/5) — the AoE
  payoff room ON the way to the dungeon whose boss fight wants it.
- Typed transitions: none required. **Explicitly considered and
  deferred:** an interior sealed door making the deep half a true paid
  toll pocket (s34 law shape is available — basement_2 precedent) —
  left as a grill fork (see d.); the unsealed variant ships value
  without spending SIM-class budget.

## c. Shipped-grammar vs NEW asks

| Piece | Status |
|---|---|
| Spawns per kit (husk/rusher/rusher_hater) | shipped grammar (`enemy_spawns`) — values = grill |
| Drop payoff | shipped (drop economy) |
| Landmark clusters (jetty L, hollow L) | shipped vocabulary (worldsmith landmark/decor; SAFE-class) |
| Zone-identity dose (motif on the north half) | shipped (ZoneIdentity rows; SAFE-class) |
| Region-layer ambience (north = quieter band?) | shipped grammar (WB region layer); OPTIONAL, audio-seat ask if wanted |
| Interior sealed door in Pocket B | shipped grammar (s34/basement_2) but SIM-class — DEFERRED to grill fork |
| **NEW asks** | **none** — both pockets compose entirely from shipped pieces |

Difficulty context: zone_8's tier row (150/100) is already dormant-live
(s68) — the pockets inherit it; no tier work owed.

## d. Sequencing + open forks for the v20 grill

**Anticipation sequence (the route as designed):** arrival [62,18] →
north along the dirt band → **Pocket A** (light fight, water landmark —
"the frontier is inhabited") → short empty leg (breath) → **Pocket B**
(the committed fight, clump geometry — "it gets harder this way") →
NW dirt plain (quiet approach, the D2 rope visible ahead) → **DUNGEON 2**.
Empty legs SHRINK but don't vanish: the s69 lesson is pockets, not
carpet — the remaining quiet is what makes the pockets land.

Forks (questions, not answers):

1. **Pocket B seal:** unsealed (drawn) vs interior sealed door (true
   toll pocket, s34 shape)? SIM-class budget question — one gated piece
   at a time law applies to the authoring wave.
2. **Landmark visibility:** should Pocket B's landmark be tall/bright
   enough to read from the arrival band (a "go there" beacon), or
   discovered? (Zone-identity dose is SAFE-class either way.)
3. **Route ambience:** does the north half want its own region-layer
   ambience band (quieter than the south camp), or stay silent? Audio
   seat ask if wanted; zero game-side cost either way.
4. **Third pocket?** The ticket caps at 1-2; the NW plain leg stays
   empty by design here (quiet approach). If the grill wants a third
   beat, the plain's sparse rocks [4,4]-family are the site — named,
   not designed.
5. **Sequencing vs D2 gating (dossier fork 1):** if D2's rope carries a
   defeats/level rung, do the pockets want to foreshadow it (e.g.
   Pocket B posture matching the rung's tier)? Grill's call; values are
   theirs.

## Freeze-hygiene statement

Paper only. `data/zones/zone_8.json` read, never touched (worldsmith md5
intake pin respected); no data/src/harness edits; pilot.ldtk untouched
(zone_8 isn't in it); import_ldtk.rb not run; ritual spec §9 unread; no
balance numbers (kits and postures named, every count/value deferred);
no peer-feel survey — my own recorded v20 input item 4 is the only feel
source. Authoring = post-verdict worldsmith/WB lane per the grill.
