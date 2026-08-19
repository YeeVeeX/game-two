# LDtk spike findings — T1, world-builder lane (2026-08-19)

**VERDICT: GO.** LDtk is the authoring front-end. Version pinned below;
T2 lands the pin into D1 and builds the production importer with the
refusal cases catalogued here.

## Pin (D1 candidate)

- **LDtk 1.5.3** (Windows installer `LDtk-1.5.3-installer.exe`,
  md5 `11f9057d5889c0e51eee2ed43e8096cf`, installed silent `/S`,
  per-user `%LOCALAPPDATA%/Programs/ldtk`, no admin needed).
- Project files stamp `jsonVersion: "1.5.3"` at root — **pin on
  jsonVersion ONLY**; `appBuildId` moves on every resave by the
  installed build (473702 → 473703 observed) and must NOT be pinned.
- Latest upstream release (2024-01-15) — slow project cadence, pin is
  low-churn. First launch shows a changelog splash + "NEW UPDATE"
  ribbon (phones home); it does NOT auto-update without consent. Pin
  ceremony: decline update prompts; upgrades only via D1 re-pin.
- Install friction: LOW (installer-only on Windows — no portable zip;
  silent install worked first try; ~167 MB download).

## What was proven (evidence tiers)

1. **Schema both ways:** `district` generated as a 1.5.3 project
   (template cloned from the vendor's own samples), LDtk LOADED and
   RENDERED it (layout visually verified: border walls, building
   blocks, 21 entities with field values drawn in-world), then LDtk
   RE-SAVED it through its own writer (md5 moved, file normalized).
2. **Round-trip semantic identity:** throwaway importer
   (`tmp/spike_import_ldtk.rb`) read BOTH my generated file and LDtk's
   own re-saved bytes → zone JSON **semantically identical to
   `data/zones/district.json` on all 11 keys**, both paths equal.
3. **In-game byte-identity (the strongest tier):** worktree with the
   imported district ran the deterministic `district_hunt` replay —
   **9/9 capture frames byte-identical (md5) to the real tree's
   baseline** (`tmp/spike_frames_real.md5` vs `tmp/spike_frames_wt.md5`).
   The imported zone IS the authored zone, to the pixel.
4. **Human-visible walk:** pilot session in the worktree walked
   nest → district through the west transition: ZONE 2 banner, all 15
   enemy spawns at authored tiles (STATE dump matched
   `enemy_spawns` 1:1), combat live (possessed blocker took damage),
   clean quit with TELEMETRY lines (console:
   `tmp/spike_pilot_console.log`; captures `tmp/frame_0359_entry.png`,
   `tmp/frame_0715_mid.png`). Real save untouched (md5
   `30ff315dc36ee183c42eb040c08e6030`, mtime 2026-08-18 22:36, before
   AND after). Worktree removed. (Honest note: the worktree-local
   pilot log + export script were torn down with the worktree; the
   frame-md5 files, console log, PNGs, and chat-captured STATE lines
   are the surviving artifacts — sufficient for a throwaway spike,
   and T2's fixtures replace them with committed tests.)

## Authoring-UX read (owner-joy axis, honest)

- Entity palette (Station/Transition/PackSpawn/EnemySpawn), IntGrid
  painting, and per-instance field editing all behave as a pro tool
  should; field VALUES render on the canvas ("TOLL PAID", spawn-point
  pins) — placement errors will be visible while drawing, which is
  exactly what zone authoring needs.
- Externally generated projects load clean (after the
  realEditorValues fix below) — machine-assisted authoring is viable
  alongside hand-drawing.
- Not yet evaluated: sustained drawing FEEL under the owner's hands
  (his first real authoring session is the true test — T4). Nothing
  observed fights the grid workflow.
- Stability: survived repeated load/kill/relaunch beside a running
  wall sweep + game replay windows without interference.

## Mapping wrinkles (T2 inherits as refusal cases / laws)

| # | Wrinkle | T2 consequence |
|---|---|---|
| 1 | **1.5.3 loads field values from `realEditorValues`, NOT `__value`** (hit live: empty realEditorValues → `<ERR: Invalid field value>` + `<Value required>` in-editor; values encode as `{"id":"V_String/V_Int/V_Bool","params":[…]}`, Points as `V_String "cx,cy"`) | Importer READS `__value` (documented final value) but REFUSES NAMED when `__value` and `realEditorValues` disagree (tamper/hand-edit tell). Any future file GENERATION must write both. |
| 2 | `jsonVersion` at root; `appBuildId` churns per resave | Refuse `jsonVersion != "1.5.3"` NAMED; ignore appBuildId. |
| 3 | IntGrid CSV is row-major; **0 = empty/void** (we author 1=wall, 2=floor) | Refuse any unmapped value INCLUDING 0 (non-rectangular zones unsupported) with cell coordinates in the error. |
| 4 | Point fields = `{cx,cy}` in the layer's OWN grid coords; entity `__grid` derives from px+pivot | Pin entity pivot (0,0) + level `worldX/worldY` (0,0) in the project; refuse deviations NAMED (multi-level world offsets are a later, explicit mapping). |
| 5 | `identifierStyle` default "Capitalize" would rewrite `district` → `District` | Project must set `identifierStyle: "Free"`; importer refuses a level identifier that doesn't match an expected zone-name shape. |
| 6 | Non-spatial scalars (palette incl. alpha, drop_gradient, gradient_anchor, tile_size) have no natural LDtk field home (LDtk Color fields carry no alpha; array-of-pairs doesn't exist) | **Sidecar contract:** LDtk owns SPATIAL truth (tiles + entities + display_name level field); a per-zone sidecar owns presentation/tuning scalars. T2 ratifies this split in D2's wording. |
| 7 | `externalLevels: true` nulls `layerInstances` (separate .ldtkl files) | Keep false; refuse null layerInstances NAMED. |
| 8 | Entity-instance ORDER in JSON is authoring-order (fragile) | Semantics never read array order: pack_spawn carries an explicit `order` Int field; enemy spawns collect per-kind. Duplicate/missing `order` = refusal. |
| 9 | Level custom fields (defs.levelFields) work for scalars (display_name proven) | Available for future zone metadata (floor: could live here in T2's schema v2). |
| 10 | No tileset art bound in spike (render = editor colors only) | Asset era binds tilesets; D7 registry's render/sprite-id seam carries it — no importer change needed. |

## Round-trip gaps (named, none blocking)

- Formatting canonicalization: the importer's emitter defines the
  canonical zone-JSON byte format; the hand-authored district.json
  differs only in whitespace/key style (semantic equality proven).
  D2's byte-stability property applies to pipeline-authored zones
  (import→emit→import fixpoint), which T2's tests enforce.
- LDtk re-save normalization is stable (import(generated) ==
  import(resaved)) — no drift observed across a save cycle.

## Session evidence trail

Generator `tmp/spike_gen_ldtk.py` · importer `tmp/spike_import_ldtk.rb`
· project `tmp/spike_district.ldtk` (LDtk-resaved bytes, md5
`59363c9427dde76e742a6b2bba31b563`) · imports
`tmp/spike_district_imported{,2}.json` · frame md5s
`tmp/spike_frames_{real,wt}.md5` · GUI shots
`tmp/spike_ldtk_shot{1..5}.png` · pilot console
`tmp/spike_pilot_console.log` + entry/mid PNGs (tmp/ = ephemeral;
this doc is the durable record).
