# SPARK — v20 T6b: FLOOR -2 CONTENT (district_two retheme + new kinds + cap 13) — lane D's first content ticket; CONTENT PRIORITY IS OWNER LAW — staged s121, enriched at T5 close (2026-08-29)

You are a fresh session executing v20 ticket T6b in game-two
(cwd ~/workspace/game-two). AGENTS.md + MEMORY auto-inject beside this
brief; live files beat this spark on any drift. Ruby per shell:
`export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language English;
peer surfaces es-CR / pt-br. Quality over cost: design and review ride
maximum thinking; only mechanical closed-DoD sub-steps ride lower.

OWNER RULING (s120, Gabriel): CONTENT PRIORITY — he watched the soaks
and named the gap himself: "I don't see any new zones, areas, enemies,
items, mechanics." T5 (second wall class) SHIPPED s121 — the engine
key exists. THIS ticket is the answer: a new floor, new enemies, a cap
step. Ship things the players SEE.

Law of the ticket: spec §SECOND WAVE
(`docs/superpowers/specs/2026-08-28-v20-descent-cycle.md`) + foundation
L5 (cap never outruns content) · L6 (deep pays more; existing kill_xp
rows untouched) · L13 (Rule 2 costs priced, not adjectived)
(`drafts/_v20-foundation-20260828.md`) — foundation wins on
disagreement. Method precedent: T1's transcription-faithful pipeline
(`git log --oneline --grep=v20-t1`, read its ticket record).

## STATE YOU INHERIT (verified s121, re-verify from disk)

- **T5 SHIPPED** (record `drafts/_v20-t5-wallclass-20260829.md`,
  commits `1d00d12..14c235c`): `wall_inner` (char `%`, int_grid 7,
  own palette ref) renders red inner walls beside near-black `#`
  bounds. Blocking = frozen `TileMap::WALL_CHARS`; renderer + god-view
  resolve per-tile render-refs via `App::TileVariants.specs/wall_ref`.
  PROVEN: a zone using `%` without `wall_inner` in its (sidecar)
  palette refuses NAMED at the IMPORTER DOOR (validate_emitted!), and
  `validate_map!` refuses tile_types overrides that disagree with the
  wall-char blocking law (both directions).
- **district_two TODAY** (read `data/zones/district_two.json`): ZONE 3,
  44x26, hand-maintained v1 JSON, floor UNSET (=0), palette has NO
  wall_inner. Live transitions — the ENDPOINTS CONTRACT: west
  `[0,13] → camp (spawn [18,5])` (untyped, free both ways) and east
  `[42,13] → slow_door, SEALED`. Kinds spawning there: rusher,
  rusher_hater.
- **Balance surfaces**: `data/balance/progression.json` — curve
  `{k: 40, level_cap: 12}` (T2's cap 10→12 live) + kill_xp rows
  `{husk: 8, rusher: 15, rusher_hater: 25, challenger: 120}`. Enemy
  kinds are data kit blocks in `data/balance/combat.json` (hostile
  kits: rusher, rusher_hater, husk, challenger). Standing script:
  `tools/pacing_table.rb`.
- **Junior's directions** (banked, approved by him):
  `drafts/_junior-floor2-directions-20260829.md` — THREE candidates
  for the SAME 88x44 map (v1 CALASSA chambers / v2 NAUTILUS spiral /
  v3 FIEHONJA open plain+canal; PNGs + deterministic generators in
  `drafts/_refs/junior-floor2-*`, digests in the doc). Theme
  correction recorded there: floor -2 is SUBMERSO (walking the sea
  floor); deeper = darker (+bluer). v3 needs T5's wall class (orange
  reef + dark rim) — now available.
- **Suite 1340 runs green; gate_checks.json 74 rows**
  (wall_class_reads last); map_checks.json census "Fourteen (+TEST 2)"
  and its zone_grids row reads ZONE 3 as "cold slate-and-indigo" — the
  submerged retheme CHANGES that read (update rides the retheme
  commit). No wall script starts in district_two (verified by grep);
  traversal members must be identified by reading scripts (the name
  multi_floor_descent suggests the descent chain — verify at entry,
  trust the directory).
- **Pilot five** (byte-exact importer emissions, pinned in
  test/tools/pilot_authoring_test.rb): zone_7, basement_1, basement_2,
  dungeon_1, district. district_two GRADUATES INTO this set this
  ticket. test/core/tile_map_test.rb keeps hardcoded v1/pilot arrays
  (district_two sits in v1 today) — both move deliberately.

## STEP 0 — ENTRY (before anything)

1. `git fetch origin` + ff-merge. Read: checkpoint TOP entry — this
   spark — the directions doc + its three PNGs (read tool, they are
   images) — spec §SECOND WAVE — foundation L5/L6/L13 — T1 + T5
   ticket records — `data/zones/district_two.json` —
   `authoring/pilot.ldtk` level/sidecar shapes — `tools/import_ldtk.rb`
   header.
2. Collision check (s56/s104 law): peer commits touching district_two,
   authoring/pilot.ldtk, data/balance/, or a T6b CLAIMED line in
   checkpoint / seat mail. Junior may lawfully start this too — the
   CLAIMED line arbitrates; on collision coordinate, never duplicate.
3. Push `CLAIMED: T6b — <seat> <date>` into docs/CHECKPOINT.md top
   BEFORE building (two-seat race law).

## MISSION

1. **Floor -2 = district_two retheme** from Junior's candidates —
   88x44 (grows from 44x26), west→east flow, 3-wide passages + 2-wide
   risky gaps, 4 crossings of the impassable, ~30 minions in arena
   groups + 5 guardians at the heart, sets `floor: -2` (zone metadata,
   data honesty). **Pick or mix is a PEER decision** — Junior approved
   all three ("a escolha é da dupla"). If Gabriel is in chat: ask in
   ONE line. If solo (owner order 2026-08-22 — never gate on peer
   availability): the dev of record picks WITH a one-line defense and
   records it as the recorded lean for async ratification. Honest
   inputs for the pick: v3 exercises T5's wall_inner exactly as
   Junior's ask intended (reef + rim coexisting) and is his newest
   reference; v1 is closest kin to the shipped v2b feel; v2 is the
   most authored landmark. Taste consult (council, 1 max) only if
   genuinely torn.
2. **New creature kind(s)** for the deep: new kit block(s) in
   `data/balance/combat.json` + OWN kill_xp rows in progression.json —
   deep pays MORE than rusher_hater's 25 (L6; existing rows
   byte-untouched). Junior's drawings name 5 "águas-vivas" guardians
   at the heart + arena minions — kind count and stats are yours to
   propose-and-defend against the pacing table. Verify the spawn path
   accepts new kit ids as pure data before assuming an engine seam is
   owed (Rule 3 says it should; prove it with a boot + spawn test).
3. **Cap 12→13 riding the floor** (L5): the `level_cap` knob +
   `tools/pacing_table.rb` re-run banked in the record.

## MISREAD GUARDS (each sourced from a live trap or verified fact)

1. **The live west edge goes to CAMP, not the floor -1 chain.**
   Junior's doc says "entrada oeste (da cadeia do -1)" — that is the
   FUTURE descent graph, and graph rewiring is the lane-F/L2-class
   single-row decision, NOT this ticket. T1 precedent exactly:
   internal retheme is destination-independent; the retheme PRESERVES
   the live endpoints (west↔camp free, east→slow_door SEALED). If the
   88x44 geometry moves the mouth coordinates, re-anchor coords
   lawfully (Crossing validates at boot; slow_door's return spawn must
   stay passable) — but the to/from ZONES do not move without an owner
   line.
2. **Water is PASSABLE today (swim reserved).** The impassable in all
   three drawings (fossas/salmoura/canal) must BLOCK — author it as
   wall-class tiles (`#` bounds or `%` wall_inner per the look), or
   wall-ring any water. Walkable cosmetic water is lawful where
   walking is intended. Name the choice per area in the record (s113
   adversarial row).
3. **The importer door will refuse `%` without the palette ref** —
   author `wall_inner` in the district_two sidecar palette FIRST
   (T5-proven refusal). Also: any NEW transcription build script
   derives char/int_grid maps from `data/tiles.json`
   (registry-driven) — `tools/build_district_v2b.py`'s hardcoded maps
   predate `%`:7 and cannot emit the second wall class (T5 review
   advisory). A wall_inner-heavy zone should author station palette
   refs too (station fill falls back palette[key]→:station→:wall).
4. **Authored-file byte laws**: fixpoint-prove BEFORE editing
   authoring/pilot.ldtk (python json.load→dumps(indent=2)+CRLF+trailing
   newline reproduces its bytes — project memory 2026-08-24); sidecars
   indent=2 + LF. Pilot-pin the new emission AFTER landing
   (pilot_authoring_test gains district_two; hand edits to emitted
   JSONs trip provenance).
5. **Perf BEFORE wire-in** (s113 row): 88x44 = 1.5x zone_8's area.
   `rake perf` with the new zone loaded before transitions go live; a
   p95 regression parks the wire-in.
6. **Census pins move deliberately** (T5 precedent): tile_map_test v1
   list loses district_two, its pilot list + pilot_authoring_test gain
   it; map_checks ZONE 3 palette clause changes with the theme. Zone
   COUNT stays 14 (retheme, not addition). Legit-growth pin updates,
   never law-weakening.
7. **Mid-sweep source freeze**: while ANY gate/replay runs, edit no
   src/ or data/ file. Detach gates (nohup/Start-Process + poll the
   log); a Bedrock read-timeout in the vision critic is INFRA flake —
   re-run the gate standalone (disrupted-gate law).
8. **Record-first + evidence honesty**: open the ticket record with
   evidence sections as UNCHECKED placeholders; fill only with real
   artifacts (the fabricated-evidence trap is in global memory).
9. **Sim-class discipline**: the gated piece of THIS ticket = new
   kinds + kill_xp rows + cap 13. It rides the NINETEENTH delta clock
   (delta-triggered; name accumulated deltas in the record: totem SIM
   + v2b presentation + this floor/kinds/cap). No freeze arms until a
   fun-verify is DECLARED. Respawn/difficulty/sustain numbers beyond
   the new rows: NOT this ticket.

## RULE 2 / GATES (priced per L13)

- **New wall member**: a floor -2 traversal script (west
  entry→heart→east seal) joins `harness/scripts/` as the zone's
  permanent regression surface; gate it with an affirmative read on
  its own strongest surface. If v3 (wall_inner) is picked, the
  existing wall_class_reads row reads affirmatively here for free.
- **Re-gate traversal members** that cross district_two (identify at
  entry; likely multi_floor_descent) — INTENDED map change: their
  district_two frames move deliberately, canary rebank versioned per
  L13.
- **Canaries elsewhere unchanged**: world_loop + one district (floor
  -1) member must stay byte-identical (pre-change baseline md5s BEFORE
  any edit — bank them first; compare gate_a frames, never the plain
  out_dir, which accumulates stale strays).
- **God-view**: `rake map PROBES=1` + critique (copy artifact to
  frame_0000.png for the critic's glob; map_checks ZONE 3 clause
  updated in the retheme commit).
- **Soak**: `rake soak N=1 ZONES=district_two` (or the env shape
  soak/run_soak.sh documents) before close.
- Suite green per commit (hooks); language critique on any new
  player-visible strings (placeholder law: generic names only).

## PHASES (serial, one bundled change-set after the pick)

1. Record-first: open `drafts/_v20-t6b-floor2-20260829.md` (or dated
   today) — pick + defense, kind design vs pacing table, water/wall
   choices per area, evidence sections UNCHECKED.
2. Pre-change baselines: canary captures + pilot emission md5s.
3. Transcription: build script → pilot.ldtk level + sidecar →
   importer → deliberate copy → provenance pins. Perf smoke.
4. Kinds + kill_xp + cap 13 + pacing table re-run (the gated piece,
   one commit).
5. Gates: floor script + traversal re-gates + canaries + map + soak.
6. Bank evidence + checkpoint s-entry + push + fresh-eyes review
   (Rule 6, scrubbed context, JSON verdict as LAST message; execute
   or disposition every advisory).
7. Queue line for the peers (es-CR + pt-br, seat registers).

## BUDGET/STOP (Rule 7)

One attended session. This is a LARGE ticket: if transcription alone
fills the window, land floor-geometry-through-importer as its own
green commit and STOP, staging a follow-up spark for kinds+cap
(scope-break law, not failure — L5 then holds cap 13 back with the
unfinished content). Gates: 1 floor script + traversal re-gates + 2
canaries + map + 1 soak (+ re-runs only per the disrupted-gate law).
Council: 1 taste consult max (only if solo AND torn on the pick).
STOP and surface on: pilot fixpoint red on authoring edits (twice =
stop, never force re-emission) — perf red on the 88x44 — any canary
red OUTSIDE district_two — context ≥75% with attended work unlanded
(compact-checkpoint skill).

## DoD (then STOP)

- Floor -2 retheme live through the importer door, endpoints
  preserved (west↔camp, east slow_door seal), floor: -2 set,
  provenance-pinned, 88x44 perf-proven.
- New kind(s) spawning there with own kill_xp rows (existing rows
  byte-identical); cap 13 riding it; pacing_table output banked.
- All gates green: floor script affirmative, traversals re-gated
  versioned, canaries byte-identical, map critique PASS, soak clean,
  suite green.
- Record + checkpoint s-entry + push + fresh-eyes review PASS.
- Queue line (es-CR): el piso -2 existe — el mapa de Junior es
  jugable, con enemigos nuevos que pagan más y cap 13. (pt-br): o
  piso -2 existe — teu mapa é jogável, com inimigos novos que pagam
  mais e cap 13.
