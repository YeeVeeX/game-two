# v20 pre-grill evidence — measured engine truth (s96, 2026-08-27, drafts-only)

STATUS: **EVIDENCE ONLY.** Owner-directed (s96 chat: slate item 2 —
v20 prep). This file converts two pre-grill open questions from
claim to measured code truth, read-only: zero code/data touched, no
frozen file named, no design decided — shape picks and lane order
stay grill calls (the verdict is the unlock, spec §12). On any
disagreement the cited source lines win over these summaries.

## 0. Index freshness (re-verified this session at `8e988ad`)

All 9 digests in `drafts/_v20-pregrill-index-20260827.md` §1
recomputed s96 in the commands that cite them: 7 local blobs @ HEAD
(slate `4b95c13f…` · pacing `7a8feb19…` · J-T1 `0959d0c1…` · J-T2
`0203a6cc…` · J-T3 `adc3c16e…` · foundation `26a6eea2…` · ritual spec
`0ca46597…`) + worldsmith dossier @ `4fd1f66` (`56a6ee9b…`) + uiux
block-anchor @ `3728d76` (`6eb0bbba…`) — **all match, index fresh**.

## 1. Controls surface — the substrate under open question 4 (slate candidate 6 fence)

The fence's claim "the CONTROLS SURFACE is full" is an ERGONOMIC
claim about the shipped dual-binding scheme, not a physical one.
Measured:

- **Bound today: 13 actions** (`data/bindings.json`, the single data
  surface): left/right/up/down (Arrows + WASD) · attack (J, Space) ·
  dodge (K, LShift) · special (L, E) · mark (;, Q) · interact (H, F)
  · sustain (U, R) · aim (LCtrl, RCtrl) · swap (Tab) · menu (Escape).
  ONE special verb per kit is the whole spell surface.
- **Laws already enforced load-time, fail-loud**
  (`src/core/binding_map.rb`): one-key-one-action (dual-bind refusal,
  lines 46-54) · unknown key names refuse (lines 43-46) · per-machine
  override via `data/bindings.local.json`, whole-array replace
  (lines 20-29); the harness pins `local: false` (gate comparability,
  lines 15-18). In-game rebind UI is PARKED (AGENTS.md out-of-scope).
- **Key vocabulary** (`src/app/key_table.rb:13-32`): A-Z · 0-9 ·
  arrows · Space · Tab · Enter · L/RShift · L/RCtrl · LAlt · `;` `,`
  `.` · Escape. Extending = one-entry addition (engine fact, not a
  tunable). Scancodes are POSITIONAL — non-US layouts remap via the
  local override, never this table (file header note).
- **Free names measured: 28** — letters B C G I M N O P T V X Y Z
  (13) · digits 0-9 (10) · Enter, RShift, LAlt, `,`, `.` (5). The
  classic spell-slot digit row 1-5 is ENTIRELY free.
- **What the dual-binding scheme has left** (every shipped action
  pairs a right-hand primary + a left-hand-near-WASD secondary):
  left-hand-reachable free letters T G B V C X Z; right-hand
  home-adjacent free I O P N M. Clean PAIRS remain (e.g. I+T, O+G) —
  scarce, not exhausted.
- **True cost of a new verb** (beyond the bindings row): an input
  consumer in the sim + a controls-strip surface — the strip renders
  `{glyphs, label}` pairs in ACTIONS order from the live BindingMap
  (`src/app/controls_overlay.rb:48-50`), so every new action is a
  Rule 2 visual change + an i18n label (en/es/pt-br) by construction.
- **What stays a grill call** (this file decides nothing): loadout/
  spell-select layer (Q4's named shape, J-6 menu family) vs direct
  digit binds vs special-verb overload. The measured substrate says
  the binding table itself is not the constraint; legibility and
  hand-position economics are.

## 2. Vertical-UP ("towers") — candidate 9 rung iii / T26 H4, engine side

The slate marks UP floors "needs importer/renderer verification — a
NEW axis question." Verified this session — **the axis already
exists; basic towers cost zero engine work:**

- **`stairs_up` is a live, shipped transition type** — not
  hypothetical: `Core::TileMap::TRANSITION_TYPES = %w[stairs_up
  stairs_down hole rope_spot]` (`src/core/tile_map.rb:12`); live
  usage: basement_1 [4,3] and basement_2 both return to zone_7 via
  `type: stairs_up` (`data/zones/basement_1.json`,
  `data/zones/basement_2.json`).
- **`floor` is a SIGNED Int, positive imports today**: zone metadata,
  default 0 (`tile_map.rb:57`); the strict importer refuses non-Int
  ONLY (`tools/import_ldtk.rb:172-173`) and emits any non-zero value
  (`:363`). "0 = surface, negative = down" is comment convention
  (`tile_map.rb:51-52`), not enforced law — `floor: 3` imports and
  loads unchanged.
- **ZERO consumers of `map.floor` anywhere in src/** (grep this
  session: no reader outside the TileMap attr; the map_artifact hit
  is a palette ref). The T2 comment ("nothing in the sim consumes
  any of these yet") is still byte-true post-T5. A floor:+N zone is
  just another zone to the sim, renderer, god-view, audio, and J-7
  catch-up (all keyed by ZONE, never by floor).
- **Transition semantics are floor-blind and already uniform**:
  absent type = gate; `rope_spot` = interact-consent
  (`src/game/world.rb:500`, `:1015`); stairs/hole auto-fire;
  `stairs_unlocked_by` is legal on `hole` only (D4 amendment,
  `tile_map.rb:157-160`). Nothing anywhere assumes "down".
- **Measured gap (fact, not recommendation): floor-delta consistency
  is UNENFORCED** — no validator checks that a `stairs_up` target
  sits at floor+1 (transitions name `to` zones; floor arithmetic is
  authoring discipline). If v20 authors towers, the grill decides
  whether that stays discipline or becomes an importer check.
- **Net for the grill**: rung iii's engine floor is ALREADY PAID for
  basic towers (author zone with `floor: 1`, wire `stairs_up`/
  `stairs_down`, play today). What does NOT exist is any FLOOR-AWARE
  behavior (per-floor ambience, god-view floor stacking, floor-keyed
  spawns) — each would be its own gated piece under the SIM-class
  tile-behavior law if ever wanted.

## 3. What this file refuses to do

No shape picks · no lane order · no new design content · no
foundation drafting · no ritual-topic commentary. Hygiene: nothing
in the freeze set was touched or extended — this bank is read-only
observation of unfrozen engine files plus two foreign blobs verified
at their named refs, read-only.
