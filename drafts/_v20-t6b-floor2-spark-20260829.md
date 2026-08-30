# SPARK — v20 T6b: FLOOR -2 RETHEME + NEW KINDS + CAP 13 (lane D, first content ticket) — staged s121 (2026-08-29)

You are a fresh session executing v20 ticket T6b in game-two
(cwd ~/workspace/game-two). AGENTS.md + MEMORY auto-inject beside this
brief; live files beat this spark on any drift. Ruby per shell:
`export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language English;
peer surfaces es-CR / pt-br.

OWNER RULING (s120, Gabriel): CONTENT PRIORITY — he watched the soaks
and named the gap ("I don't see any new zones, areas, enemies, items,
mechanics"). T5 (second wall class) SHIPPED s121 — the engine key
exists. THIS ticket is the answer: a new floor, new enemies, a cap
step. Ship things the players SEE.

Law of the ticket: spec §SECOND WAVE (floors -2/-3 outline) +
foundation L5 (cap never outruns content) + L6 (deep pays more;
existing kill_xp rows untouched) + L13 (Rule 2 costs priced) —
`docs/superpowers/specs/2026-08-28-v20-descent-cycle.md`,
`drafts/_v20-foundation-20260828.md`. T1's transcription-faithful
pipeline is the method precedent (see its ticket record via
`git log --oneline --grep=v20-t1`).

## MISSION

1. **Floor -2 = district_two (ZONE 3) retheme** from Junior's banked
   directions: `drafts/_junior-floor2-directions-20260829.md` — THREE
   approved candidates for the SAME map (v1 CALASSA chambers /
   v2 NAUTILUS spiral / v3 FIEHONJA open plain+canal), 88x44,
   west→east flow, endpoints preserved (entry from floor -1 chain,
   east exit SEALED → ZONE 4 → floor -3), 3-wide passages, 4
   crossings, ~30 minions + 5 guardians at the heart. **Pick or mix
   is a PEER decision** — Junior approved all three and left the call
   open ("a escolha é da dupla"). If Gabriel is in chat, ask in ONE
   line; if solo, the dev of record picks WITH a one-line defense
   (v3 exercises T5's wall_inner where his drawing wants coexisting
   reef + dark rim; v1 is closest to the shipped v2b feel; v2 is the
   most authored landmark) and records the pick as the recorded lean
   for async ratification.
2. **New creature kind(s) with OWN kill_xp rows** — deep pays more
   (L6), existing rows byte-untouched. Data-driven (data/balance/),
   zero constants in code; new kinds are zone-authored spawns
   (enemy_spawns) — check whether kind plumbing needs any engine seam
   at all before assuming it does.
3. **Cap 10→12 is already live (T2); this ticket ships 12→13 RIDING
   the floor** (L5: the cap step lands in the same change-set as the
   content that justifies it, `tools/pacing_table.rb` re-run banked
   in the record).

## BINDING ADVERSARIAL ROWS (s113 review — execution law)

- **Water is PASSABLE today (swim reserved):** any water in the
  retheme is either wall-ringed (unreachable) or accepted as cosmetic
  walkable water — name the choice per area in the record. The
  intransponível in Junior's drawings (fossas/salmoura/canal) should
  be WALL-class tiles (near-black `wall` bounds or `%` wall_inner
  per look), NOT water, wherever it must actually block.
- **`rake perf` BEFORE wire-in:** 88x44 = 1.5x zone_8's area. Run the
  perf smoke with the new zone loaded before wiring transitions; a
  p95 regression parks the wire-in.
- **T5's wall classes:** `%`/wall_inner renders its own palette ref;
  a zone using `%` MUST author `wall_inner` in its sidecar palette or
  the importer door refuses NAMED (proven behavior, import_ldtk_test).
  Review-advisory riders (T5 fresh-eyes, banked in its record §7):
  any NEW transcription build script derives its char/int_grid maps
  from data/tiles.json (registry-driven like the importer) —
  tools/build_district_v2b.py's hardcoded maps predate `%`:7 and
  cannot emit the second wall class as-is; and a wall_inner-heavy
  zone should author its station palette refs (station fill falls
  back palette[key]→:station→:wall — boundary-black stations beside
  red walls otherwise).

## METHOD (T1 precedent — transcription-faithful)

- Junior's generators are banked: `drafts/_refs/junior-floor2-v*-gen.py`
  (deterministic, seeded; PNG digests in the directions doc §each).
  Build path: generator/params → transcription build script →
  pilot.ldtk level (authoring/pilot.ldtk — fixpoint-prove BEFORE
  editing: json indent=2 + CRLF + trailing newline; sidecars indent=2
  + LF) → `tools/import_ldtk.rb` → deliberate copy into data/zones/
  → provenance pin (district_two joins the pilot set in
  test/tools/pilot_authoring_test.rb).
- district_two is CURRENTLY a hand-maintained 44x26 v1 zone — the
  retheme graduates it through the importer door (district/T1
  precedent exactly).
- Endpoints preserved = the transition GRAPH stays: low_quay↔ links
  and slow_door seal rows keep their zone/coord contract (re-anchor
  coords lawfully if geometry moves them; Crossing validates at boot).

## SIM-CLASS DISCIPLINE (one gated piece)

The gated piece of THIS ticket = new kinds + their kill_xp rows + cap
13. It RIDES the NINETEENTH delta clock (delta-triggered; name the
accumulated deltas in the record: totem SIM + v2b presentation + THIS
floor+kinds+cap). No freeze arms until a fun-verify is DECLARED.
Respawn/difficulty/sustain numbers beyond the new rows: NOT this
ticket.

## RULE 2 / GATES (priced per L13)

- New wall scripts: a floor -2 traversal script (entry→heart→east
  seal) joins harness/scripts/ as the zone's permanent member; gate
  it affirmatively (wall_class_reads already exempts honestly if v3's
  wall_inner isn't picked — if v3 IS picked, the row reads
  affirmatively here too, free).
- Re-gate the wall scripts that TRAVERSE district_two
  (multi_floor_descent + any low_quay/slow_door path members — check
  the directory, trust it over this list).
- Sim-identity canary rebank: INTENDED map change on district_two —
  versioned protocol per L13 (the retheme moves canary baselines for
  that zone deliberately; world_loop/floor1_run stay byte-identical).
- god-view: map_checks zone_grids row names ZONE 3 "cold
  slate-and-indigo" — the submerged retheme CHANGES that read; update
  the row's ZONE 3 clause in the same commit as the retheme (Rule 2
  gate on the map artifact: rake map PROBES=1 + critique).
- Soak N=1 with ZONES including district_two before close.
- Suite green per commit (hooks); pilot pin extended to district_two.

## STEP 0 — ENTRY (before anything)

1. `git fetch origin` + ff-merge. Read: checkpoint TOP (latest s) —
   this spark — the directions doc + its three PNGs (read tool) —
   spec §SECOND WAVE — foundation L5/L6/L13 — T1 + T5 ticket records
   (method + wall-class API) — data/zones/district_two.json (current)
   — authoring/ sidecar shapes.
2. Collision check (s56/s104 law): peer commits touching
   district_two, authoring/pilot.ldtk, data/balance/ xp rows, or a
   T6b CLAIMED line in checkpoint / seat mail. Junior may lawfully
   start this too — the CLAIMED line arbitrates.
3. Push `CLAIMED: T6b — <seat> <date>` into docs/CHECKPOINT.md top
   BEFORE building.

## BUDGET/STOP (Rule 7)

One attended session (large ticket — if the transcription alone fills
the window, land floor-geometry-through-importer as commit 1 and
STOP with the spark for a follow-up session carrying kinds+cap;
scope-break law, not failure). Gates: floor script + traversal
re-gates + map gate + soak. Council: taste consult on the pick ONLY
if solo and genuinely torn (1 consult max). STOP and surface on:
pilot fixpoint red on authoring edits (twice = stop) — perf red on
the 88x44 — any canary red outside district_two — context ≥75% with
work unlanded (compact-checkpoint skill).

## DoD (then STOP)

- Floor -2 retheme live through the importer door, endpoints intact,
  provenance-pinned.
- New kind(s) spawning there with own kill_xp rows; cap 13 unlocked
  riding it; pacing_table re-run banked.
- All gates green (floor script affirmative, traversals re-gated,
  map gate, soak, suite, perf).
- Record + checkpoint s-entry + push + fresh-eyes review PASS.
- Queue line for the peers (es-CR + pt-br): el piso -2 existe — el
  mapa de Junior es jugable, con enemigos nuevos que pagan más y cap
  13 / o piso -2 existe — o mapa do Junior é jogável, com inimigos
  novos que pagam mais e cap 13.
