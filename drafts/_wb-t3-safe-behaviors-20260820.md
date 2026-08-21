# WB T3 — safe tile behaviors (footstep materials + region ambience + flora variants)

Session 26 (hub), 2026-08-20. Spec:
`docs/superpowers/specs/2026-08-19-world-builder-pipeline.md` §T3 (D7/D8/D9
govern). **SHIPPED** — gates below all PASS; fresh-eyes review PASS 8/8 laws
(receipt `drafts/_wb-t3-review-20260820.md`; its 2 cheap defects fixed in
place: footstep adjacency guard [a multi-tile jump is never a step — also
suppresses multi-tile dodge steps, P.S. appended to the audio mail] +
unmapped-grid-char refusal message/test).

## What shipped (one concern per commit)

- `261b867` feat(core) — registry capability: `variants` unlocked as a
  validated optional key (T3 IS its gated cycle; `hooks` stays reserved),
  `validate_map!` re-scoped to the chars a zone's grid USES + tile_types
  overrides (the old all-registered-types scope would have invalidated every
  live zone the moment a new type registered — found by reading, pinned by
  test), `material_at` = the footstep consumer, `TileMap#char_at/used_chars`.
- `aa8e8c6` feat(data) — dirt (`,`/3) grass (`g`/4, variants b/c) wood
  (`w`/5); nest remaps `.`→dirt (footstep-only); `data/zones/
  grass_fixture.json` = ZONE 6 (INERT, D12); `data/audio/ambience.json`
  (intents town/dungeon + fixture meadow); ZONE 6 locale lines (en/es/pt-br,
  locale-invariant placeholder).
- `2eee709` feat(app) — `App::TileVariants` (FNV-1a over zone:x:y — never
  Object#hash, per-process randomized; never Random in draw) + renderer
  overlay pass, memoized per map.
- `2428b2b` feat(app) — bridge polls the LOCAL seat's possessed body:
  `FootstepPoller` (same body + same zone + new tile = step; jumps reset
  silently), ambience key = region intent → zone default → nil, synthetic
  sink names `footstep_<material>` / `ambience_<key>`, `AUDIO …` log lines
  on change. Window passes `seat:` at attach (netplay: each seat hears its
  own steps).
- `f05a635` fix(app) — god-view typed cells through TileVariants (the map
  critique's real catch, below).
- `5cc4115` feat(harness) — `harness/scripts/grass_fixture_walk.json`
  joins the wall + ONE conditioned check `flora_variants_read` in
  `harness/gate_checks.json` (D10: the wall scales by surface) + fixture
  palette legibility tuning from the first honest gate FAIL.

## Deliberately moved surfaces (each named, per the T3 bar)

1. **nest data** (`tile_types` + palette `dirt`==floor): footstep-only —
   LOOK PROVEN byte-stable: world_loop 29/29 captures md5-identical to the
   pre-change baseline (`tmp/t3_world_loop_baseline.md5`), plus the
   palette-equality law pinned in `TileRegistryTest`.
2. **ZONE 6 grass_fixture** (new surface): gated below; INERT pinned by test
   (no live transition targets it — D12; dev entry `--start-zone`).
3. **god-view artifact**: gains the ZONE 6 panel (labels test updated;
   probes+critique in the gate list).
4. **the wall itself**: +1 script, +1 conditioned check — every other
   script's checks untouched.

## Design decisions (defended, spec-cited)

- **No sim events added.** The spark assumed existing movement events;
  the sim has none (verified: no `:moved`/`:step` in any `emit(`). Polling
  the possessed body read-only at the bridge (renderer-style) keeps the sim
  byte-untouched — stronger than registering a new event, and the pure-sink
  digest test now covers the polling lanes explicitly (fixture-walk digest
  test, audio attached vs not).
- **District vs nest differentiation = the T2 `tile_types` remap lever**
  (this is what T2 shipped it for): nest walks say dirt, district stays
  stone, ZONE 6 says grass/dirt/stone/wood. Zero look movement (visible-
  overlay rule: a typed tile draws only when its resolved color differs
  from the zone floor).
- **Live zones carry NO ambience beds yet** — each bed is owner recording
  work; the table grows a line at a time at his pace. Fixture meadow +
  intents town/dungeon are the v0 keys (T4's TOWN 1/DUNGEON 1 land on the
  intent lane for free).
- **Variant selection**: authored alternates in data, coord-hashed at
  render — D7's "no runtime randomness" law satisfied mechanically
  (unit-pinned determinism + gate double-replay md5).

## Audio seat mail (sequencing step 1 — sent before any code)

`~/.pi/agent/mail/game-two-audio/from-game-two-t3-cue-spec.md`
md5 `d556358aa68d4d10c39f27191801a8cc` (post-review P.S. included) —
footstep families
stone/dirt/grass/wood (es-CR owner list, one take per material to start),
ambience beds meadow/town/dungeon, mapping rows, cadence (step_frames
13–19 ticks ≈ 217–317 ms), low-priority no-duck lane, LUFS ref =
their integration-readiness table. Their PARKING triggers (their
`2171462`/`2471b5d`) now have the concrete spec. NOTHING owed before
renders exist; T3 done-condition rides the noDevice log lane.

## Gate evidence (Rule 2 — blocking, all PASS before ship)

- `grass_fixture_walk` FULL gate: determinism 8/8 byte-identical + vision
  PASS 0 fails (`tmp/t3/gate_fixture2.log`; first run FAILED honestly:
  the construction-banner FIFO showed ZONE 1 over fixture pixels — fixed
  by the varekka_duel capture-window precedent [first capture ≥150], NOT
  by relaxing the check; `flora_variants_read` PASS with all four
  materials named by the critic).
- world_loop + low_quay_run spot-gates: BOTH `GATE PASS` rc=0
  (`tmp/t3/spot_gates.log`) — the live-world regression bar, nest remap
  live in the frames.
- god-view: probes 5/5 + map critique PASS (`tmp/t3/map2`,
  `drafts/_gate-verdicts.log`) — after a REAL critic catch: ZONE 6
  rendered as an empty slab (cell_rgb floor-fallback); fixed `f05a635` by
  routing typed cells through the same TileVariants derivation (no second
  color source), critic re-run PASS ("stripes read as coarse biome bands,
  not corruption").
- Suite green via hooks on every commit (951→964 runs).
- noDevice walkthrough (bots, SCRATCH save, SOAK_AUDIO=1 — mechanical
  evidence, never fun-evidence; `tmp/t3/walk/*.log`, live save md5
  unmoved `98fe75edb6d72deab18cd48eaa88bdaf`):
  - district: `AUDIO footstep material=stone zone=district` (+`ambience key=none`)
  - nest: `AUDIO footstep material=dirt zone=nest`
  - grass_fixture: `AUDIO ambience key=amb_meadow zone=grass_fixture` +
    `material=grass` then `material=dirt` as the bot crossed the path
  → the T3 done-condition verbatim: the three walks log DIFFERENT
  material keys, zero sim delta (pure-sink digest tests + byte-identical
  gate replays).

## Waits on owner (never nag)

- Footstep/bed renders (es-CR list in the mail) — keys are live and logged
  meanwhile; first renders land as cues.json rows + fixtures (v1.1 pattern).
- Multi-take footstep rotation + bed playback mechanism = audio-seat
  architecture calls at their pace (named in the mail).

## Out of scope, refused in writing

Sim-class tile behaviors (lava/water/spawn-gates): post-verdict increments,
one gated piece each — NOT T3, even with the SEVENTEENTH verdict landed
(lane order stays owner-steerable; T4 precedes). No safe-zone RULES (D9:
layer ships, rules wait for the v19 debate). No live-zone visual retouches.
