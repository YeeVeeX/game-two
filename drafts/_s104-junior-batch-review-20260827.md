# s104 review — Junior batch J-T4..J-T7 + self-directed J-T8 (2026-08-27)

Reviewer: hub seat (dev of record, s104) — fresh-eyes per Rule 6 (the
authoring seat is Junior's; this seat wrote none of it). Deliverables
landed `33cbdd3` → `b3ab265` → `7f59685` → `95ec6b6` under the owner's
carte-blanche release (verbatim recorded in the lane doc §RELEASE
2026-08-27). Numbering of record = Junior's (J-T6 spell-select ·
J-T7 practice LDtk); the hub's independently-drafted release section
carries a reconciliation note (benign two-seat race — both seats
numbered the same owner-released batch; hub rails now serve as this
review's source map).

## Verdicts

| Ticket | File | Verdict |
|---|---|---|
| J-T4 city-hub routes | `drafts/_junior-cityhub-dossier-20260827.md` | **PASS** |
| J-T5 BOSS 2 verbs | `drafts/_junior-boss2-verbs-20260827.md` | **PASS** |
| J-T6 spell-select | `drafts/_junior-spell-select-20260827.md` | **PASS** |
| J-T7 practice LDtk | `authoring/dungeon_2_draft.ldtk` + handoff §J-T7 | **PASS** |
| J-T8 CITY 1 blueprint | `drafts/_junior-city1-blueprint-20260827.md` | **PASS, one geometry observation (grill-class, no rework)** |

## Independent verification performed (not trust)

- **Freeze surface:** `git log cc5f356..HEAD` over the full watch list
  (data/balance · data/zones · telemetry · save_state · save_store ·
  autopilot · session · creature · aggro) — CLEAN through `95ec6b6` +
  the hub's `709a337`. Suite green via hooks at every commit (his close
  line + this seat's own hook runs, 1317/27591).
- **J-T4 live-truth claims, byte-checked this session:** zone_7 tiles =
  44×28 ✓ · bank at [27,14] + seal at [31,14] ✓ · camp = 20×11 ✓ ·
  the four ways + gate rules (basement_1 L4 · basement_2 L5 · dungeon_1
  L6+sealed · low_quay free) ✓ — all exact.
- **J-T7 .ldtk, structurally decoded:** one level `dungeon_2_draft`,
  IntGrid 34×22 (gridSize 32) ✓ · 13 entities = 2 Transition + 1
  Station + 3 PackSpawn + 7 EnemySpawn ✓ (matches handoff claim
  exactly). **Connectivity re-proven independently**: flood-fill from
  PackSpawn over the IntGrid (wall+water blocked) reaches all 13
  entities — his self-caught corridor fix holds. `authoring/pilot.ldtk`
  md5 `d59056b790eba44f4c7c71b1a07beb3a` pre-batch == post-batch ✓ ·
  importer never run (freeze-watch + data/zones untouched) ✓.
- **J-T6 substrate figures** (13 actions · 28 free names · digit row
  free · strip-order law) == the banked s96 evidence file ✓.

## Observations (recorded, none block)

1. **J-T8 geometry (grill-class):** the transitions table assigns
   "DUNGEON 2 side" to the EAST gate, but J-T4 §3 R2 + J-T2's own spine
   (`zone_8 → DUNGEON 2 → CITY 1`) put D2 on the ARRIVAL side from the
   existing world — i.e. west. Under the owner's sketch pattern the
   east gate is the FUTURE next-dungeon spoke (toward CITY 2). The
   table's own hedge ("or the spine zone the grill wires") + fork 3
   ("decide together") absorb this; the district program is
   compass-independent. Route to the grill beside J-T8 fork 3 —
   same class as the s91 J-T3 pocket-flank note.
2. **J-T7 draft slack (transcription-time note):** 51 IntGrid cells
   carry value 0 (unassigned) — legal in a never-imported draft;
   the post-verdict authoring session assigns or walls them.
3. **J-T5 concept labels** (Warden/Tollkeeper/Sealbreaker) read as
   mechanical-descriptive design vocabulary (striker/challenger
   class), doc-side only — any player-visible surface stays BOSS 2
   (his own hygiene statement says the same; noted so the build
   ticket remembers).
4. **Hygiene held across all five:** drafts + one sanctioned authoring
   file only · §9 unread · zero balance numbers (canvas dims are
   geometry sketches, J-T2 precedent) · no feel-surveys — banked
   verbatims cited as the only feel source · item 5 untouched ·
   ritual-topic contact: none (J-T5 contrasts mechanisms, never
   difficulty-feel).

## Standing after this review

- All five deliverables enter the v20 pre-grill input set. The index
  (`drafts/_v20-pregrill-index-20260827.md`) stays closed to inline
  additions by its own law — these five bank as NEW rows at the next
  index refresh (grill-open time), digests computed then, in the
  commands that cite them.
- Junior's seat remains fully released under the owner's carte blanche
  (lane doc §RELEASE): new paper ideas ride the same laws, no further
  asks needed.
- Nothing here unfreezes anything: ritual s1 is declared for today;
  the verdict stays the unlock.
