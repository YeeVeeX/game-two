# MAP EDITING — the map-lane operating manual (v1, 2026-08-27)

Role split (peer-ratified 2026-08-27, hub chat, recorded s104):
**Junior DIRECTS the editing of current maps** — he picks the zone and
sends a reference image of the intent; **the dev seat EXECUTES** — it
delivers the complete edit with strategically placed respawns and
configured transitions ("portals"). Fidelity to the reference image is
approximate BY AGREEMENT; tolerance for bugs/crashes/glitches is ZERO —
which in this repo means the deliverable passes the mechanical gates
below, not that anyone promises hard enough.

> **FREEZE GATE (read first, binds until the eighteenth's verdict):**
> `data/zones/**` is a freeze-watched surface and respawn/difficulty
> moves are the exact objects the pending ritual measures — measurement
> hygiene while a fun-verify is pending relaxes under NO override
> (AGENTS.md operating model, item 2). Directions received now are
> BANKED (drafts/) and execute the day the verdict lands. Everything
> in this manual is prep until then.

## 1. The zone inventory — every map has ONE lawful edit path

| Zone | Origin | Edit path | Law |
|---|---|---|---|
| `zone_7`, `basement_1`, `basement_2`, `dungeon_1` | LDtk importer emissions (the "pilot four") | edit `authoring/pilot.ldtk` (+ per-zone sidecar) → re-import via `tools/import_ldtk.rb` → deliberate copy into `data/zones/` | **NEVER hand-edit the JSONs** — `test/tools/pilot_authoring_test.rb` byte-compares committed JSON against a fresh emission; any drift = red suite |
| `zone_8` | worldsmith seat emission (their v0 export, wired s70) | re-emission by the worldsmith seat, OR a consciously recorded re-pin | **NEVER hand-edit silently** — the pin is TEST-ENFORCED: `test/game/worldsmith_intake_test.rb` (`test_landed_zone_bytes_match_the_intake_record`) byte-pins `data/zones/zone_8.json` against the intake record; any edit = red suite unless the pin moves CONSCIOUSLY in the same commit (intake record: `drafts/_worldsmith-v0-intake-20260823.md`) |
| `camp` (HUB 1), `district`, `district_two`, `low_quay`, `nest`, `gate_fixture`, `grass_fixture`, `slow_door` | hand-authored JSON (pre-WB era) | direct JSON edit, one concern per commit | strict loader refuses malformed zones NAMED at load; suite + gates still bind |

New zones (post-verdict) author through the WB pipeline: LDtk → strict
importer → sidecar → wire-in (T1–T5 precedent, one session per zone;
spec: `docs/superpowers/specs/2026-08-19-world-builder-pipeline.md`).

## 2. Anatomy of a zone JSON (live examples, verified 2026-08-27)

Top-level keys (zone_7): `name` · `display_name` (player-visible —
placeholder law: ZONE N / HUB N / generic only) · `tile_size` · `tiles`
(row strings of glyphs; registry = `data/tiles.json`) · `transitions` ·
`stations` · `enemy_spawns` · `pack_spawn` · `regions` · `palette` ·
`safe` · `hub` · `gradient_anchor` · `water_drained_by`.

- **`tiles`**: rows × cols of single-glyph tile classes — registry =
  `data/tiles.json`, verified vocabulary: `#` wall · `.` floor · `,`
  dirt · `g` grass · `w` wood · `~` water (the registry declares
  render + footstep + passability + IntGrid id per glyph). Grid dims
  come from the row/col counts (zone_7 = 44×28, zone_8 = 64×40).
- **`enemy_spawns`** (the "respawns"): dict of kit → coordinate list,
  e.g. dungeon_1: `{"rusher": [[8,8],…], "rusher_hater": [[26,16],…],
  "husk": [[23,11],…]}`. Empty `{}` is legal (zone_7 is a safe hub).
  Which KITS exist and their stats live in `data/balance/` — never in
  zone files.
- **`pack_spawn`**: exactly the pack's entry cells, e.g.
  `[[4,14],[4,13],[4,15]]`.
- **`stations`**: `{"type": "bank"|"vat"|"altar"|"seal", "at": [x,y]}`;
  seals add `"price"` (a KEY into balance data, e.g. `"breach_cost"` —
  data-driven law: no literals), `"opens": [x,y]` and `"line"` (stamp
  text — placeholder register).
- **`regions`**: `[{"id", "rect": [x,y,w,h], "intent"}]` — region
  identity / ambience (SAFE-class vocabulary).
- **`safe` / `hub`**: sanctuary law (B1) + home-hub identity. **The
  home-hub flags are LOAD-BEARING** — mercy floor (B4) and rehoming
  hang off them; moving "home" is a design decision, never a map edit.
- **`palette`**: per-zone render colors + motif + ambient — SAFE-class,
  ships freely (still Rule 2 gated).

## 3. Transitions ("portals") — types and laws

Verified shape (dungeon_1):
`{"at": [x,y], "to": "<zone>", "spawn": [x,y]}` + optional
`"type"`, `"sealed"`, `"requires_level"`, `"requires_defeats"`,
`"stairs_unlocked_by"`.

- **Types** (`Core::TileMap::TRANSITION_TYPES`, `src/core/tile_map.rb:12`):
  `stairs_up` · `stairs_down` · `hole` · `rope_spot`. Absent type =
  plain gate. **Consent law:** rope_spot fires on INTERACT only;
  stairs/holes auto-fire on step.
- **Gate rules:** `requires_level` / `requires_defeats` gate the
  crossing (refusal cues shipped); returns are conventionally free
  (v1 edge-gate pattern, s70).
- **Seal gating law (s34, `abe04d6`):** a seal station's `opens` must
  name a transition whose `sealed` is TRUTHY — unsealed or
  requires-only targets refuse NAMED at zone load.
- **Floors:** `floor` is signed Int zone metadata (default 0; down =
  negative by convention). `stairs_up` is live and shipped
  (basement returns). Floor-delta consistency between linked zones is
  UNENFORCED — authoring discipline until the grill says otherwise
  (s96 evidence file).
- **INERT law:** an inbound transition may be deliberately inert
  (grass_fixture precedent) — record it when authored.
- In coop, zone crossings require the living controlled bodies
  co-located at the gate (v17 law) — transition placement is a
  two-player ergonomics question, not just solo flow.

## 4. The LDtk pipeline (pilot four + all new zones)

`tools/import_ldtk.rb` is **the ONLY door** from LDtk to zone JSON
(file header, verified): LDtk owns SPATIAL truth (IntGrid `Terrain`,
entities, display_name/floor/hub); the per-zone
`authoring/<zone>.sidecar.json` owns presentation/tuning scalars
(palette incl. alpha, drop_gradient, gradient_anchor,
water_drained_by). The emitter defines the CANONICAL byte format;
import → emit → import is a byte-stable fixpoint (enforced by
`test/tools/import_ldtk_test.rb`). Every refusal is NAMED and exits
nonzero.

```
ruby tools/import_ldtk.rb <project.ldtk> --sidecars <dir> --out <dir> \
                          [--zones data/zones] [--tiles data/tiles.json]
```

- Output **NEVER defaults into `data/zones`** — merging into the live
  world is a deliberate copy (D12 merge law).
- LDtk version pin: jsonVersion 1.5.3, identifier style "Free".
- Practice drafts (e.g. `authoring/dungeon_2_draft.ldtk`) are INERT:
  the provenance test reads `authoring/pilot.ldtk` only.

## 5. Delivery workflow (one direction → one shippable edit)

1. **Direction intake (Junior):** which zone + reference image +
   one-line intent. Banked as `drafts/_junior-mapdir-<zone>-<date>.md`
   (image in `drafts/_refs/`, md5 recorded). Approximate fidelity is
   the contract — the dev proposes deviations where the engine or a
   law forces them, in the same doc.
2. **Author** via the zone's lawful edit path (§1 table — WRONG PATH =
   the whole edit is refused at review).
3. **Import + suite:** `bundle exec rake` green (hooks enforce; the
   provenance and fixpoint tests catch pipeline violations
   mechanically).
4. **Respawn placement:** kits from the zone's tier vocabulary
   (`data/balance/tiers.json` reading), counts/positions strategic per
   the direction — NO new balance numbers in zone files, kits named
   only. Post-verdict, spawn changes in existing zones are sim-feel
   moves: **ONE zone per re-session** (owner method ruling s89,
   serial + intensive testing).
5. **Rule 2 gate (BLOCKING):** the zone's wall script exists or is
   authored (`harness/scripts/`), then
   `rake gate SCRIPT=harness/scripts/<script>.json` — double replay +
   md5 + vision verdict. New/changed zone = its own script + gate rows
   (T5 precedent). A red gate blocks the ship — fix, never waive.
6. **Crash claim = soak evidence:** the "zero crashes" guarantee is
   `rake soak` (bots, scratch save) crossing the edited zone + the
   gate's double replay — captured logs, not assurances.
7. **Canary awareness:** edits touching zones that
   `world_loop`/`varekka_duel`/`burn_duel` traverse will shift the
   sim-identity event stream — an INTENDED map change follows the
   versioned-bank protocol in
   `test/harness/sim_identity_canary_test.rb`'s header; an unintended
   shift is a defect. Never rebank to silence a mistake.
8. **Deliver:** commit (one concern), push, evidence paths in the
   direction doc, review per lane law (fresh-eyes, s90/s91/s104
   precedent).

## 6. Class laws that bind every edit (carried, not new)

- **SAFE-class** (decorative tile variants, footstep materials, region
  ambience, palettes): ships freely — still gated visually (Rule 2).
- **SIM-class** (lava/water behaviors, tile-gated spawns, hostile
  ground): ONE gated piece at a time, its own lane decision — never
  rides a map edit silently.
- **Data-driven:** zero balance constants in zone files or code;
  prices/stats are keys into `data/balance/`.
- **Placeholder law:** display names stay generic (ZONE N, DUNGEON N,
  CITY N); no fiction names anywhere.
- **Every commit changes what the player sees/hears/feels** — a map
  edit that can't be felt in a capture doesn't merge.

## 7. What a map edit costs (so directions can be sized honestly)

Suite ~2 min (hooks, every commit) · one gate run ~5 min/script ·
a NEW zone = wall script + gate rows + zone-identity row (~1 session,
T1–T5 precedent) · broad visual moves owe a full-wall re-pin (~35
scripts, ~3h detached) · spawn/difficulty moves post-verdict read
against the ritual's routed rows first (R-D1/R-D2 lineage). Editing an
importer-emission zone without the pipeline costs a red suite
immediately — the table in §1 is the first thing to check, every time.
