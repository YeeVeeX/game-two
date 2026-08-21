# s31 — edge validation at world load (unknown targets + impassable spawns refuse NAMED)

Session: 31 (2026-08-21) · dev of record, Gabriel's hub seat
Commit: `3c4b988` (pushed `da5119c..3c4b988`)
Provenance: s30 fresh-eyes review **finding 6**, RECORDED candidate
(`drafts/_s30-gate-pin-20260821.md` §review).

## Classification (stated per the operating model)

Engine hardening in the ACTIVE lane 3 — the strict-importer /
named-refusal law is that lane's own doctrine. NOT v19-class, NOT
sim-class: any legal world keeps byte-identical behavior (verified two
ways below); only illegal DATA changes outcome, from silent corruption
to a named boot refusal.

## Problem killed

A transition's `at` tile was load-validated (`src/core/tile_map.rb`
check_passable!), but its `to` was validated NOWHERE (KeyError at
crossing time in `Crossing#arrival_tiles` / ArgumentError in
`enter_zone`) and its `spawn` was placed UNCONDITIONALLY
(`src/game/crossing.rb` arrival_tiles — only ally neighbors get
`passable?`). The importer refuses unknown targets at import
(`tools/import_ldtk.rb:300`) but never checks spawn passability — and
hand-edited zone JSON never meets the importer at all. A mis-authored
spawn shipped players inside a wall silently.

## What shipped

`Crossing.validated_arrivals(zones)` — pure class method, called from
`World#load_zones` (world.rb:1216), the one point every consumer
converges (play, netplay, map, harness, soak, pilot). Three NAMED
refusals (ArgumentError — World's house style for unknown-zone
refusals), message carries the full grep-able tuple:

- `zone edge <src> [x, y] -> <to>: unknown destination zone "<to>"`
- `zone edge <src> [x, y] -> <to>: spawn must be an [x, y] tile (got …)`
  (shape guard — passable?(*nil) would raise an UNNAMED arity error
  before the passability check; the degenerate impassable case)
- `zone edge <src> [x, y] -> <to>: spawn [x, y] impassable in <to>`

Returns the arrivals table World previously built inline — the
validated edges ARE the arrival geometry, one pass builds both.

**Line-cap story:** world.rb sat at EXACTLY its 1800-line growth
ceiling (line_caps_test caught the first draft at 1830) — the
extract-on-touch law fired as designed; the logic lives in the Crossing
policy object (which already owns open?/group_wait/arrival_tiles, i.e.
the exact consumer that trusted spawn blindly). world.rb back to 1800.

## Suite counts

Before: 999 runs green (s30 close). After: **1004 runs, 18760
assertions, 0 failures** (5 new in
`test/game/zone_edge_validation_test.rb`: unknown-target · impassable
spawn · out-of-bounds spawn · malformed/absent spawn · legal-pair
control; all message-asserted, green first run). Hook ran the suite at
commit and again at push.

## Blast radius (verified, not assumed)

- **Real data pre-scan (ephemeral script, run before implementing):
  all 19 edges across 11 zones LEGAL — bad=0.** No defect branch; no
  wall gates owed. The reviewer independently re-ran an equivalent
  read-only scan: bad=0 of 19, claim confirmed.
- Fixture stores: only `map_artifact_test.rb` WELL_ZONE injects
  transitions (self-target, spawn [1,1] = pack_spawn tile — legal);
  typed_transitions UPPER/LOWER legal both ways; every other citer of
  `zones/` reads real data. Suite green confirms.
- No Rule-2 gate owed: load-time refusal, zero visual surface moves
  (stated in the commit body; reviewer's axis-5 check concurs — no
  render path, no data files touched).

## Preview-loop verification (spark asked)

**There is NO dedicated preview entry point.** The spec's ticket list
(`docs/superpowers/specs/2026-08-19-world-builder-pipeline.md` §Tickets)
never shipped a standalone hot-reload preview tool; authors iterate by
booting a real World (`--start-zone` dev entry per T4, `rake pilot`,
`rake map`). Every one of those constructs World → `load_zones` → the
new refusal fires at authoring speed anyway. The spark's claim holds in
substance with that naming correction.

## Importer mirror decision: NO (bias toward subtraction)

The importer's `transition()` already refuses unknown targets against
its name-only universe (project levels + zones dir — `import_ldtk.rb:
300`). Spawn passability at import would require loading the
DESTINATION zone's grid — for cross-zone edges that is a cross-file
pass over zones that may not be part of the import at all (the
universe is names, not grids). Not ~trivial → not duplicated.
RECORDED follow-up (only if authoring friction ever shows): an
importer post-decode pass reading target-zone JSON grids. World-load
refusal already covers every boot path at preview speed.

## Fresh-eyes review (Rule 6) — receipt

Scrubbed read-only pi sub-session over the diff (prompt banked at the
time in tmp/, ephemeral; verdict + findings recorded here).

**VERDICT: PASS-WITH-NITS** — "semantics for legal worlds
byte-identical (verified against all 19 real edges), refusals complete
and NAMED, tests pin messages not just classes; nits are cosmetic or
pre-existing."

Axes: (1) legal-world semantics byte-identical — default-proc hash
preserved, insertion order preserved (sorted DataStore keys), same
spawn object references, both @arrivals consumers (arrival_tiles_for
fetch-with-default; gate-fields key?-guarded anchor) unaffected.
(2) Refusal coverage complete in scope; nil `to` safe (`key?(nil)` →
false); no unnamed path inside validated_arrivals. (3) All five tests
pin the full message; delete-the-validation makes every refusal test
fail; control constructs a real World through load_zones. (4) Placement
correct (Crossing owns edge policy; Game→Core direction clean).
(5) Zero Rule-2 exposure, independently re-verified.

Nits recorded (none blocking, none acted on this session):
1. Nil/malformed `at` still crashes UNNAMED in TileMap#check_passable!
   (nil destructure) — PRE-EXISTING, zone-local, fires before Crossing;
   next spot if the named-refusal doctrine extends.
2. Cosmetic: edge label interpolates raw `t[:to]` — nil renders
   `-> : unknown destination zone nil`; no information lost.
3. `zones.fetch` after `key?` is a redundant second lookup — reads fine.
4. **world.rb sits at exactly 1800/1800 — ZERO headroom.** The next
   material world.rb touch owes another extraction. Flagged for the
   next ticket that lands there.

Process note from the reviewer: one seat-lease false-positive block on
a read-only one-liner (comparison-token classifier); reworded, nothing
mutated. Mail dir audited after the run: inbox 0 / done 22 / audio
seat unchanged — clean.

## Session-31 standing-gate record (Job 0)

All baselines HELD at open: tip = s31 spark commit · save md5
`98fe75ed…` mtime 08-20 15:51 (owners have NOT walked the gate yet) ·
launcher logs 40×2 · soak newest `20260820-232208` · untracked
`drafts/_refs/` only · `tmp/pilot_walk/world.json` intact · lag-evidence
README only · game-two inbox empty. Junior's newest bank still
`_junior-pilot-walk-20260821.md` (PRE-fix probe) → **J2 did not
trigger** (re-measure still pending, owner-paced; adjudication classes
carry to s32 verbatim). No new human logs → **J3 did not trigger**;
R-A2 stays silent, nothing to harvest. Save re-checked unmoved at
session close.
