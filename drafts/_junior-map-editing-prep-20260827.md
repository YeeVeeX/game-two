# Map-editing prep — Junior seat operating guide (2026-08-27)

Role split agreed (peers, 2026-08-27): Junior DIRECTS map edits on the
current world (picks the map + supplies a reference image); this seat
EXECUTES: structure-faithful edit, strategically placed spawns,
configured portals, zero bugs/crashes/glitches. This doc is the studied
structure + the fixed workflow, distilled from the governing docs
(WB pipeline spec D1–D12 · tools/import_ldtk.rb · pilot_authoring_test
· worldsmith_intake_test · content-fill s69 · seal-gating s34 · zone
JSONs read live). It is the checklist every edit will follow.

## 1. The three custody classes (which map = which door)

| Zone | Custody | Edit path |
|---|---|---|
| zone_7 · basement_1 · basement_2 · dungeon_1 | **LDtk pilot** (authoring/pilot.ldtk + sidecars) | edit in pilot.ldtk → `ruby tools/import_ldtk.rb` → deliberate copy into data/zones → commit BOTH sides together (provenance pin: data/zones must equal the emission byte-exact) |
| zone_8 | **worldsmith emission** (md5 pin in worldsmith_intake_test) | edits move the pin CONSCIOUSLY (test constant updates in the same commit) — s70 precedent; never silent |
| camp · district · district_two · nest · low_quay · slow_door · gate_fixture · grass_fixture | **legacy hand JSON** (pre-pipeline) | direct JSON edit, loader-validated; T2 regression bar proved they ride the canonical loader |

**NEVER:** hand-edit data/zones for a pilot zone (provenance test goes
red and blocks the commit — by design) · run import_ldtk.rb with a
5th level in pilot.ldtk · touch authoring/dungeon_2_draft.ldtk into the
import path (draft stays draft).

## 2. Zone JSON anatomy (the edit surface)

- `tiles`: ASCII rows (glyph per tile; vocabulary via data/tiles.json —
  `#` wall · `.` floor · `,` dirt · `g` grass · `w` wood · `~` water).
  Registry declares render + footstep + passability per glyph.
- `palette`: colors incl. per-glyph refs + ambient_rgba (sidecar custody
  in pilot zones).
- `pack_spawn`: [[x,y]×3] — where the pack lands on zone entry
  (fixture/arrival). Must be passable, non-overlapping.
- `enemy_spawns`: { kit => [[x,y]…] } — kits live in combat.json
  (rusher, rusher_hater, husk, challenger). Placement = design;
  counts/stats = balance custody (grill/verdict).
- `transitions`: [{at, to, spawn, type?, sealed?, requires_level?,
  requires_defeats?, stairs_unlocked_by?}]. Types: absent=gate,
  `rope_spot`=interact-consent, `stairs_up`/`stairs_down`/`hole`=
  auto-fire. Holes ONE-WAY (D4); `stairs_unlocked_by` legal on hole
  only. Both ends must exist; spawn tile must be passable and NOT
  ping-pong onto the return trigger tile.
- `stations`: bank/vat/altar/seal(+price/opens/line). Seal law (s34):
  `opens` must name a transition with TRUTHY `sealed`.
- `regions`, `floor`, `gradient_anchor`, `display_name` per the D3/D9
  schema. Depth palettes are authored darker, not computed.

## 3. Laws that bind every edit (from the specs, non-negotiable)

1. **D2 — importer is the only door** for pilot zones; round-trip
   byte-stability is test-enforced.
2. **D5 — no cross-floor effects** — never design against it.
3. **No-bank-in-deep (B2/B3)** — bank stations only at surface hubs.
4. **Seal gating (s34)** — seals open TRUTHY-sealed transitions only.
5. **SIM-class one-gated-piece law** — new tile BEHAVIORS (lava, water
   movement, tile-gated spawns) are individually gated tickets; layout/
   decor/spawn PLACEMENT is content.
6. **Rule 2** — any visual surface change re-gates affected wall
   scripts; map probes (`rake map PROBES=1`) + zone-identity rows must
   stay green; suite green via hooks on every commit.
7. **Netplay**: data/ is fingerprinted in the coop handshake — both
   seats must be on the same commit to play; edits land via git, never
   ad-hoc.
8. **Placeholder law** — display names stay ZONE N / generic.
9. **Balance custody** — spawn COUNTS/stats/gate values are freeze/
   grill territory; placement and wiring are design territory.

## 4. THE FREEZE GATE (the one scheduling truth)

The eighteenth ritual is mid-flight (s1 harvested 2026-08-27; s2 owed on
a DIFFERENT host-clock day; then 10 answers → fresh-session verdict).
Until the verdict: **the measured world stays byte-stable** — edits to
LIVE zones (spawns/transitions/layout on maps the ritual measures) may
be fully PREPARED (LDtk draft, emission preview, probe plan) but land in
data/zones only POST-VERDICT. This is mechanical hygiene, not caution
(D12 precedent: T4 authored everything, T5 wired post-verdict).

## 5. The fixed workflow per edit (what Junior's ask triggers)

1. Junior names the map + sends the reference image.
2. Seat reads the image → tile-plan against the zone's custody class.
3. Edit in the correct door (LDtk for pilot zones / JSON otherwise),
   spawns placed strategically (chokepoint/clump/approach logic from
   the banked pattern menu), portals wired with both ends + spawn
   tiles verified passable + no ping-pong.
4. Local verification battery, in order: importer round-trip (pilot) or
   loader boot (legacy) → suite (`bundle exec rake`) → god-view render
   (`rake map PROBES=1`) eyeballed against the reference → affected
   wall-script re-gate (determinism; critic where owed) → solo
   walkthrough via `--start-zone` on a scratch save (crossings, seals,
   spawn behavior live).
5. Delivery: diff + before/after god-view renders + verification log.
   Post-verdict: lands in main; pre-verdict: parked as ready-to-land.

## 6. Current state

- Ritual s1 harvested BOTH sides (joiner log banked `1d095a5`).
- Next external event: s2 declaration (different day) → answers →
  verdict → freeze lifts → edits land.
- This seat is READY: structure studied, doors mapped, workflow fixed.
  Awaiting Junior's first map pick + reference image.
