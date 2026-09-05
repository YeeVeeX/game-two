# MAP EDITING — the map-lane operating manual (v1, 2026-08-27)

Role split (peer-ratified 2026-08-27; **SUPERSEDED by owner order
2026-08-28 — FULL SEAT SYMMETRY**, recorded in AGENTS.md §Operating
model): **either peer DIRECTS, either peer EXECUTES** — a direction
may arrive from any seat, and the executing seat may be the same one
or the other; directions-by-reference-image and full deliveries are
both legal from both peers. What never moves is the MECHANICS: the
deliverable passes the gates below regardless of who lands it.
Fidelity to a reference image stays approximate BY AGREEMENT;
tolerance for bugs/crashes/glitches is ZERO —
which in this repo means the deliverable passes the mechanical gates
below, not that anyone promises hard enough.

> **FREEZE GATE — EXPIRED 2026-08-28:** the eighteenth's verdict
> landed (`drafts/_v19-fun-verify-verdict-20260828.md`) and lifted the
> measurement freezes by its own terms — zone/map executions are
> LEGAL again under the normal gates below. This block stays as
> history: while any FUTURE fun-verify is pending (cadence reform:
> freeze arms at declaration), `data/zones/**` re-freezes the same way.

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
  (basement returns). **Floor-delta consistency between linked zones
  is LINT LAW since WB-T6 (2026-09-05):** `tools/lint_world_graph.rb`
  judges every transition — `stairs_down`/`hole` = −1, `stairs_up`/
  `rope_spot` = +1, plain gate = 0 — plus target-exists, arrival-cell
  passable in the TARGET zone, and (report-only) A→B has a B→A (holes
  are one-way by D4). The 14 live rows that predate the law sit in
  `authoring/world_graph_allowlist.json`, each classified INTENDED or
  LEGACY with a reason; `test/tools/world_graph_lint_test.rb` blocks
  any NEW row and any stale allowlist row (fix a row → remove it).
  The LDtk AfterSave command runs the lint on every Ctrl+S (§4).
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
- LDtk version pin: jsonVersion 1.5.3, identifier style "Free"
  (installer md5 `11f9057d5889c0e51eee2ed43e8096cf`,
  `drafts/_ldtk-spike-findings-20260819.md`; DECLINE update prompts —
  a re-pin is a deliberate ceremony, D1).
- Practice drafts (e.g. `authoring/dungeon_2_draft.ldtk`) are INERT:
  the provenance test reads `authoring/pilot.ldtk` only.

### 4.1 The normalizer law (WB-T6, 2026-09-05)

The builders (`tools/build_*.py`) pin `pilot.ldtk` to ONE byte format —
`json.dumps(indent=2, ensure_ascii=False)` + CRLF (`tools/
build_tower_floor.py:83-88` refuses anything else) — and every LDtk
GUI save rewrites the whole file in LDtk's own style (tabs + LF).
**LDtk saves are re-canonicalised by `tools/normalize_ldtk.py`**; the
AfterSave command does it for you; a non-canonical `pilot.ldtk` fails
`--check` in the suite (`test/tools/normalize_ldtk_test.rb`).

```
python tools/normalize_ldtk.py --check authoring/pilot.ldtk      # exit 0 = canonical
python tools/normalize_ldtk.py normalize authoring/pilot.ldtk    # rewrite in place
python tools/normalize_ldtk.py --semantic-diff <a.ldtk> <b.ldtk> # parsed-equal? (paths otherwise)
```

Values are untouched by construction (parse → re-dump); the semantic
diff is the arbiter when a GUI save is suspected of changing MEANING
(`appBuildId` churn is expected and fine; anything the importer reads
moving = stop and read). Never hand-edit `pilot.ldtk` in a text
editor: script + normalizer, or the GUI + AfterSave.

### 4.2 The AfterSave loop (Ctrl+S in LDtk runs the pipeline)

`pilot.ldtk` carries `customCommands: [{"command": "python
../tools/ldtk_aftersave.py ../authoring/pilot.ldtk", "when":
"AfterSave"}]`. LDtk 1.5.3 spawns it with cwd = `authoring/`, split on
spaces, **no shell** (so the first token must be an executable name on
the Windows PATH of the LDtk process — `python`; a `.cmd` wrapper would
not launch). LDtk asks ONCE to trust the project's commands — say yes.
The driver: (1) normalizes the file, (2) runs the importer into
`tmp/ldtk_out` (never `data/zones` — D12), (3) runs the world-graph lint
over `data/zones` overlaid by that emission. The runner window closes
by itself on success and STAYS OPEN with the output on any refusal —
fix, Ctrl+S again. Ruby is found via `C:\Ruby34-x64\bin` first, then
PATH; a missing `ruby` or `python` is a named refusal (JUNIOR.md has
the per-machine checks). Manual equivalent from the repo root:
`cd authoring && python ../tools/ldtk_aftersave.py ../authoring/pilot.ldtk`.

**Backups:** `backupOnSave: true`, `backupLimit: 10`,
`backupRelPath: "../tmp/ldtk-backups"` → LDtk keeps the last 10 saves
under `tmp/ldtk-backups/` (gitignored — git is the real backup; never
commit these). Restore only through LDtk's own UI.

### 4.3 Editor ergonomics that the importer never reads (S1, WB-T6)

Every entity, field and level field carries a `doc` (hover in LDtk);
`Transition.to`, `EnemySpawn.kind`, `Region.id` carry the regex
`^[a-z][a-z0-9_]*$` (in-editor; the importer's `ZONE_NAME_SHAPE`
stays the law); entities are tagged `structure` / `spawn` / `region`;
the Entities layer is not selectable while inactive (painting terrain
cannot grab a spawn); Terrain fades to 0.5 when inactive; a seal's
`opens` draws its arrow (`PointStar`). All defs-only: the 13 emitted
zones stayed byte-identical (WB-T6 D6 proof). NOT in that wave, each
its own spark: entity icons (needs a TilesetDef — GUI), enums/
EntityRef (S3), tilesets + auto-layer rules (S4), `worldDepth`/layout
(S5).

### 4.4 Builder rule for future auto-layers (recorded now, binds S4)

A builder-written level that carries auto-layer RULES must write
`"autoLayerTiles": null` — LDtk re-bakes the rules on project open
ONLY when that array is null; `[]` reads as "already baked" and the
floor stays bare (LDtk v1.5.3 `LayerInstance.hx:409/935`,
`Editor.hx:356`; brief §3.7/§6.19, gamesmith
`docs/ldtk-research-brief-2026-09-05.md`). Today's builders write `[]`
for rule-less layers — correct today, wrong the day a layer gets
rules.

### 4.5 Two GUI-safety laws measured live on the first GUI save (WB-T6, 2026-09-05)

The first-ever LDtk save of the 13-zone project (through the AfterSave
loop, screenshots in `drafts/_wb-t6-gui/`) was REFUSED by the importer
— LDtk's load-time tidy had changed the data. Two laws follow:

1. **Every IntGrid value a level uses MUST be declared in the Terrain
   layer def (`defs.layers[Terrain].intGridValues`), and the
   declarations mirror `data/tiles.json` (value → type id).** LDtk
   silently ZEROES undeclared values on load and writes the zeros on
   save: values 9/10/12 (moss/rubble/lava_deco, written by the MUNDO
   VIVO builders without the T6b declaration law of
   `tools/build_district_two_v3.py:381-390`) lost 924 cells across
   low_quay/ember_1-3 in one Ctrl+S. Fixed by script (values 9–14
   declared, `771508d`); pinned by
   `test/tools/pilot_authoring_test.rb`
   (`test_every_used_intgrid_value_is_declared_in_the_terrain_def`).
   Builders adding a registry type: declare it in the def in the same
   change.
2. **A transition whose `spawn` cell lies OUTSIDE the SOURCE level's
   rectangle is an INVALID field to LDtk** (Point fields are
   level-local): it renders `<ERR: Invalid field value: Transition>` /
   `spawn = <Value required>` in red, cannot be re-entered with the
   point picker, and a level tidy NULLS it (hit live: ember_3 [1,15] →
   ember_2 spawn [60,14] came back `null` when ember_3's IntGrid was
   tidied; the four other out-of-bounds spawns — zone_7→low_quay,
   basement_1/2→zone_7, dungeon_1→zone_8 — survived an untidied save).
   The importer refuses the null NAMED (visible in the AfterSave
   window), so `data/zones` is never silently damaged — but until the
   data model moves (WB-T7 candidate: `spawn` as an EntityRef with
   `allowOutOfLevelRef`, or a String `"x,y"`; importer + builders
   re-pin, emissions byte-identical), **never edit those five
   transitions in the GUI, and read every AfterSave refusal before
   saving again.** Cross-zone spawns stay authored by builders/scripts.

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
