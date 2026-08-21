# SPARK sesión 28 — frame-tail draw fix (trigger FIRED) + WB T5 wire-in (ZONE 7 joins the LIVE world)

You are the dev of record in game-two (cwd `~/workspace/game-two`). Read
`AGENTS.md` FIRST (rule 8) — the live file beats this spark on any drift.
Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language
English; owner surfaces es-CR ustedeo (everyday gamer words — never the
foreclosure register); Junior surfaces pt-br. Quality over cost: council 0
(Lane 3 consumed its consult budget); paid calls = Rule-2 gate/critic runs
only. Evidence-first: claims are not evidence — file:line, log line, or
UNVERIFIED tag.

## Program state (2026-08-21 session-27 close — verify live)

- v18 CLOSED · **v19 NOT open** (brainstorm at the owners' word; agenda:
  `drafts/_v19-intake-docket-20260820.md`). Session 27 shipped **WB T4**
  (`3fdfae9..c5c146d` pushed): ZONE 7 (town hub + THE WELL) + BASEMENT
  1/2 + DUNGEON 1 authored in LDtk through the importer, INERT per D12;
  typed transitions live (rope=interact under the gate-consent law,
  holes/stairs auto-fire, `requires_defeats` boss fact-gate implemented,
  wired into ZERO live files); `Game::Crossing` extracted (line-cap law,
  world.rb AT 1800). Fresh-eyes PASS 9/9; ticket
  `drafts/_wb-t4-pilot-20260821.md`; receipt
  `drafts/_wb-t4-review-20260821.md`.
- **THE OWNER WALKED THE PILOT AND RATIFIED ("Aprobado", 2026-08-21)**
  — his walk log banked at the checkpoint addendum (all five materials,
  amb_town ×6 live, toll paid 60→20, one wipe respawned at town, roped
  back, clean quit). **JUNIOR ALSO WALKED IT** (his
  `drafts/_junior-pilot-walk-20260821.md`, f60d51e): amb_town ear-check
  **PASS** by human ears · rope+well "muito boa" · aim v3 re-test works
  (closes docket J-1) · the autocrlf provenance pin VERIFIED on his
  Windows clone · suite 994 green on his machine. Both walks were
  SCRATCH play — the live save never moved.
- **TRIGGER FIRED — the frame-tail ticket re-opens as J1.** The ~7%
  over20 tail was closed NO-SHIP-BY-DEFAULT gated on "the owners still
  FEELING it" (lag-T4 verdict §6). Junior FELT it ("lentidão geral") in
  the T4 zones AND banked numbers (his file §ACHADO):
  `frame_probe frames=11663 period{p50=16.8 p90=33.4 p99=50.0 max=185.5}
  update{p50=0.4 p95=1.1 max=62.8} draw{p50=3.9 p95=15.3 max=121.3}
  over20=1958(16.8%) over35=316 over100=3` — update is cheap, **the tail
  lives in DRAW** (p95 ≈ the whole 16.7 ms budget), and 16.8% over20 is
  ~2.4× the known ~7% live-world tail. AUDIO drift corroborates
  (+7→+12% engine deficit). Context: T4 zones on HIS machine. He
  measured; the DIAGNOSIS is the hub's (his own framing: "medir ≠
  diagnosticar").
- **World-builder lane:** T1–T4 SHIPPED · **T5 wire-in = J2 this
  session** — the SEVENTEENTH verdict landed AND the owner ratified the
  pilot; T5's own gate is a FULL WALL PASS (spec §T5), which this
  session runs ONCE for both jobs.
- **Decisive fact (verified read-only s27):** the shared world save
  already carries `boss_1_defeats: 1` (saves/world.json counters) — the
  moment the gate wires in, the owners' EARNED defeat opens ZONE 7 from
  their existing save.
- **BOSS 1 geography (verified):** the challenger spawns in **low_quay
  (ZONE 5)** (`data/zones/low_quay.json:183`); low_quay DECLARES
  `gradient_anchor` (line ~218), as do zone_7 `[4,14]` and dungeon_1 —
  the v12 arrival re-anchor trap is pre-covered for edges touching
  those zones (verify live, don't assume).
- **Audio seat:** T3 cue-spec mail still unanswered (md5 `d556358a…`).
  NOTHING owed before the owner's renders; their receipt/reply is an
  expected mail delta, not work.
- **Junior awaits the coop-S1 invite** (his `ad517e2`) — the invite is
  the owner's to send, NEVER nag. After T5 pushes, BOTH seats must pull
  before any coop (protocol v3 refuses mixed builds NAMED).
- **Owner-pending (never nag):** ear-checks + audio-v12 batch · T3
  footstep/bed renders (es-CR list in the cue-spec mail) · coop S1
  invite · v19 brainstorm.
- **R-A2 measure (silent, NEVER prime):** `sustain bought=0` on every
  banked LIVE-WORLD human log (scratch walks don't count). Harvest
  `TELEMETRY sustain` + frame_probe/handshake lines from every NEW human
  launcher log; bot lines are never evidence.

## Job 0 — standing gate (~10 min; anything moved = classify in writing FIRST)

Baselines at staging: origin/main tip = the s28 spark commit — `git log
--oneline -3` reads: that commit · `f60d51e` Junior's pilot-walk bank ·
`c5c146d` T4 close. Save `saves/world.json` md5
`98fe75edb6d72deab18cd48eaa88bdaf` mtime 08-20 15:51 (banked=7
provisions=0 seals=2 sessions=13 boss_1_defeats=1 home=camp) · launcher
logs **40×2** (`$TEMP` + `/tmp`, pattern `game_two_session_*.log`; the
+2 vs s26 are s27's owner walk `…2451218385.log` md5 `b26c81aa…` ALREADY
HARVESTED + the killed-instance empty artifact `…247187407.log`;
Junior's two walk logs live on HIS machine, md5s banked in his file) ·
mail inbox EMPTY, done/=21 · tmp/soak newest `20260820-232208` ·
untracked `drafts/_refs/` only · tmp/t4/ + tmp/pilot_walk/ = session-27
artifacts (expected; the scratch save tmp/pilot_walk/world.json is the
owners' ongoing dev-walk world — Junior's seat wrote sessions=2
banked=75 — never delete, never play it yourself). EXPECTED deltas:
Junior docs-only commits (read before rebasing) · audio-seat receipt ·
new human launcher logs (harvest silently) · coop S1 artifacts if the
invite went out.
`git pull --ff-only` FIRST. Single-instance guard before any launch
(separate call, judged by printed output). `--fresh` NEVER. Background
`bin/play` from pi's bash DIES silently — the working launcher is
`powershell Start-Process bin\play.cmd -ArgumentList ...`; bot seats
launch fine as `nohup … src/main.rb --bot <seed> --bot-ticks <n> --save
tmp/<dir>/world.json [--start-zone <z>] &`. ⚠️ s27 lesson: Start-Process
can LAG ~40 s before ruby appears — guard AGAIN after launching, kill
any double BEFORE either instance quits (quit writes the save).

## GATE 0 OVERRIDE — any live owner order preempts this whole queue

- **Ear-check verdicts** are LAW: bank verbatim, route per the three
  checkpoint questions; stinger-overlap failure → depth-aware-duck gets
  grilled in game-two-audio (library increment), never a data tweak here.
- **T3/T4 renders landing** (owner Reaper exports via game-two-audio
  handoff): sha-pinned fixture conversion (v1.1 pattern) + data-only
  `cues.json`/`fixtures.json` rows for `footstep_<material>` /
  `ambience_<key>` + suite + a noDevice re-walk banking the now-mapped
  keys + one es-CR line for the ear-check queue. Do it BEFORE J1 if the
  handoff is waiting at gate 0. (Note: his walk proved footstep_water is
  live too — if he asks, the water family needs a NEW cue-spec mail
  first; the sent mail is FROZEN, never edit it.)
- **A live coop session = lag segment S1**: support, harvest verbatim
  per `drafts/_lag-t2-evidence/README.md`, bank md5-stamped.

## J1 — frame-tail draw diagnosis + render fix (the FIRED trigger; bounded)

The wire-in (J2) makes ZONE 7 reachable in the shared world — shipping
the payoff zone while it draws 2.4× the known tail on a peer's machine
would sour the arc's best moment. Diagnose FIRST, fix if in-box, and let
ONE full-wall sweep gate both jobs.

Read before acting: `drafts/_junior-pilot-walk-20260821.md` (the
numbers) · `drafts/_lag-t4-vsync-20260820.md` §6 (the tail ticket's
no-ship verdict + what re-opens it) · `src/app/renderer.rb` draw_map
(the T3/T4 typed overlay + motif/decor passes; geometry memoized,
DRAWING is per-frame) · `src/app/tile_variants.rb`.

**Hypothesis to verify (named, not assumed):** live zones draw ~0 typed
rects; zone_7 is 44×28 with most tiles typed (grass/dirt/water/wood) →
the overlay pass alone adds several HUNDRED `Gosu.draw_rect` calls per
frame, plus motif rects, on top of the per-tile wall loop that always
ran. Junior's draw p95 15.3 ms ≈ the whole frame budget; his update p95
is 1.1 ms (the sim is innocent — consistent with the lag-T4 verdict).

**Steps:**
1. Reproduce mechanically on THIS machine: `GAME_FRAME_PROBE=1` bot
   sessions on scratch (`--start-zone zone_7` vs `--start-zone
   district`, same ticks) — bank both `TELEMETRY frame_probe` lines; the
   zone_7-vs-district DRAW delta is the diagnosis. Count the actual
   rects (one-off script: TileVariants.rects(zone_7).length + motif
   count) — numbers in the ticket doc.
2. If the overlay/static tile pass is the cost: the fix is the
   **per-map static-layer macro** — `Gosu.record` the immutable tile
   geometry (floor bg + typed rects + wall tiles + grid lines + motif)
   once per map and draw ONE macro per frame. Custody rules: the
   recorded layer is a pure function of zone config + registry — the
   SAME inputs the memoized geometry already uses; water_drained state
   swaps water rect colors, so key the macro on the drained BOOL (≤2
   macros/map, invalidation-free — breach facts only ever go false→true
   mid-session). Transitions/seal slabs/decor/ambient/actors stay live
   draws (state-dependent or above-grid by design). God-view
   (map_artifact) keeps reading TileVariants directly — untouched.
3. Prove it: frame_probe re-run on this machine (before/after DRAW
   numbers in the ticket) · the standard gates prove pixels — macro
   drawing must be BYTE-IDENTICAL in captures (determinism ×2 per
   script; if macros perturb capture bytes AT ALL → STOP, classify,
   fall back to partial batching or ship T5 alone).
4. Junior verification is owner-paced: stage a pt-br two-liner in the
   ticket (pull + `GAME_FRAME_PROBE=1` walk, expect over20 to drop
   toward his ~7% live-world baseline) — his re-run is the decisive
   seat, never nag.

**Box:** diagnosis + fix ≤ ~90 min before the wall runs. Cause not
found, or fix not render-pure, or capture bytes move → bank the
diagnosis as its own ticket doc, ship J2 alone, and name the tail as
still-open (the trigger stays fired; never a rushed fix under a wall
deadline).

## J2 — WB T5: wire-in (spec §T5 is law)

Read IN ORDER before any edit: (1) AGENTS.md whole · (2) checkpoint top
2 entries + the s27 close addendum · (3)
`docs/superpowers/specs/2026-08-19-world-builder-pipeline.md` §T5 +
§THE GATE + D4/D9/D12 · (4) T4 ticket + review
(`drafts/_wb-t4-*-20260821.md`) — the seams T5 builds on · (5)
`data/zones/low_quay.json` whole (boss arena, anchors, existing
transitions) + `data/zones/zone_7.json` transitions block · (6)
`harness/run_wall.sh` header + `ls harness/scripts/` (the wall is the
directory, not a list) · (7) the INERT pin
(`test_pilot_and_fixture_zones_stay_inert`,
test/core/tile_registry_test.rb) — T5 amends it DELIBERATELY.

**T5 contract (spec verbatim):** the boss-gated transition joins the
live graph; `multi_floor_descent.json` joins the wall; full wall sweep;
ritual-world caveat block updated. Gated on: SEVENTEENTH adjudication
complete (✓ landed 2026-08-20). Verify: full wall PASS + chain-anchor
discipline (the live save moves only via logged human play). Done:
ZONE 7 reachable in the shared world.

**Design forks — settle in a 15-min written grill block at the TOP of
the ticket doc (`drafts/_wb-t5-wirein-20260821.md`), then execute (rule
5: one bundled change-set). Dev-of-record proposals to defend or beat:**

1. **Gate placement.** Proposal: the edge lives in **low_quay** (BOSS
   1's own zone — the owner vision verbatim: the open zone sits past
   the boss; the earned defeat opens it where it was earned). Pick a
   legible tile (edge/wall-adjacent, not inside the arena's fight
   space; read the grid + the challenger spawn before choosing), author
   `{ to: zone_7, spawn: <meadow-west tile near [4,14]>,
   requires_defeats: 1 }` — UNTYPED gate (ordinary two-way grammar),
   the fact-gate key does the locking; it renders as the sealed slab
   until the counter meets (T4's `way_locked?` — already live). Return
   edge in zone_7's west meadow → low_quay (spawn beside the gate
   tile). Two-way per the owner's revisitability framing (D4 note).
2. **The zone_7 side goes through the DOOR.** The return edge is a new
   Transition entity in `authoring/pilot.ldtk` + re-import + deliberate
   copy (D2; the provenance pin `pilot_authoring_test` re-emits — the
   committed zone must equal the emission or the pin names it). The
   low_quay side is a hand JSON edit (live zones are NOT
   LDtk-authored; surgical text op, one transition object). zone_7
   loses INERT status BY DESIGN: amend
   `test_pilot_and_fixture_zones_stay_inert` to permit EXACTLY the one
   ratified edge pair (low_quay↔zone_7) and keep basements/dungeon_1/
   grass_fixture fully inert — the test text should name the D12
   completion, not delete the law.
3. **`multi_floor_descent.json` shape.** The wall stays
   persistence-blind (banked=0 at replay start — the well toll is
   UNPAYABLE in a wall script; its visual is already gated by map
   probes + the loop test). Proposal: `start.zone = dungeon_1` → walk
   to the rope [3,16] → interact → arrive zone_7 [33,16] → cross the
   town (footsteps/ambience move in the frames) → enter HOUSE 1 →
   stairs_down basement_1 [26,3] → stairs_up back → end near the
   plaza. That exercises rope + hole-landing zone + stairs both ways +
   town render in ONE deterministic script. Include a `manifest` block
   (zone_entered ≥ 3 — the v15 manifest law) + captures at the
   crossings. Gate it standalone FIRST (`rake gate SCRIPT=… `), then it
   joins `harness/scripts/` (D10: the ONE new surface script T5 is
   owed).
4. **Ritual-world caveat block.** Find it (grep the runsheet/verdict
   docs + AGENTS for the caveat wording; the SEVENTEENTH verdict doc
   names the measured-world framing) and update: the measured six-zone
   world now has a boss-gated exit to authored content; name the date,
   the edge, and that the SIM numbers the ritual measured were closed
   BEFORE the wire-in (verdict 2026-08-20 precedes edge 2026-08-21).
   One block, not a rewrite.

**Traps named (hit these, classify in writing, never patch around):**
- **low_quay's captures WILL move** (a new slab/gold tile in frame) —
  that is T5's deliberate Rule-2 visual change: low_quay_run +
  varekka_duel (+ any script whose walk shows the tile) go through the
  BLOCKING gate with vision critique; determinism must stay
  byte-identical ×2 per script. Any OTHER script's captures moving =
  STOP, classify (nothing else may shift).
- **Full wall ≈ 20 scripts × ~5 min ≈ 100 min — DETACHED** (nohup
  `harness/run_wall.sh t5`, poll by per-script rc lines in tmp/wall/;
  NEVER under a bash-call timeout — a killed gate is judged by a
  standalone re-run, MEMORY law). **Freeze ALL code/data edits while
  the sweep runs** (replays load source fresh — the R-A2 contamination
  lesson).
- **zone_identity_data_test** pins the "six real zones" list — zone_7
  becoming REACHABLE makes it a real zone: add the four pilot zones to
  the list deliberately (T4 authored them to the contracts: wall−floor
  luma ≥40, motif between, ambient ≤24) or record in the ticket why
  not. Expect map_artifact/labels tests to stay green (11 panels
  already pinned s27).
- **Save discipline:** saves/world.json md5 must NOT move this session
  (no live-world play by you; bots on scratch with `--save`;
  tmp/pilot_walk is the OWNER'S). After push, the owners' next LIVE
  session may legitimately move it — that is theirs.
- **Junior sync:** T5 changes live-zone bytes → protocol v3 refuses
  mixed builds. The owner queue must say BOTH seats pull before coop.
- The wall runner is `harness/run_wall.sh`, never a tmp copy; wall
  scripts live in `harness/scripts/` (netplay gates stay outside).

**Sequencing the dev of record proposes:** bank capture baselines FIRST
(world_loop + grass_fixture_walk + low_quay_run md5s BEFORE any commit —
they serve BOTH jobs; freeze code while the replays run) → J1 diagnosis
(bank probe numbers) → J1 fix if in-box (one render commit; world_loop +
grass_fixture_walk captures must equal the banked baselines — the macro
is invisible or it doesn't ship) → T5 grill block → authoring re-import
+ zone_7 data + low_quay edge + INERT-test amendment + identity-list
addition (one data commit, provenance pin green) → multi_floor_descent
script + standalone gate PASS → spot-gates on moved surfaces
(low_quay_run, varekka_duel) → **ONE FULL WALL DETACHED covering J1+J2**
(THE gate — a FAIL blocks ship, never downgraded) → caveat block + docs
→ one-concern commits → **fresh-eyes review BLOCKING over BOTH jobs**
(scrubbed read-only pi via nohup wrapper — s27: plain background `pi -p`
dies silently; the prompt MUST say "touch NOTHING, including seat
mail") → checkpoint + AGENTS lane-3 line + push + owner queue es-CR
(~5 líneas: ambos jalan antes del coop · cómo entrar a ZONE 7 desde el
mundo real — su `boss_1_defeats=1` ya abre la puerta, dónde queda la
entrada en ZONE 5 · el fix de draw espera la re-medición de Junior ·
respuesta a su pregunta: los sótanos van SIN ambiente por diseño v0 —
cada bed es trabajo de grabación del owner; cuando exista un render, es
UNA fila de datos) + pt-br two-liner for Junior's re-measure staged in
the ticket.

Hard limits: zero edits to the OTHER five live zones (only low_quay
gains its edge; district/nest/camp/district_two/slow_door stay
byte-identical) · no new EventBus symbols (rule 4) · `src/app/window.rb`
≤ ~300 lines · world.rb ≤ 1800 (the line-cap gate is armed — extract on
touch) · sim-class TILE behaviors stay OUT (post-verdict increments,
refuse in writing) · no balance-file changes · placeholder law on every
new line (es-CR everyday words in the queue).

## J3 — docket hygiene (only if J1+J2 leave room; ~15 min, docs-only)

Docket rows to move (verify live first): **J-1 CLOSES** (Junior's aim-v3
re-test works — his file is the receipt) · **the frame-tail row flips to
TRIGGER FIRED** with his numbers + this session's diagnosis pointer ·
basement-ambience question answered (design v0; a data row when a bed
render exists — also queue it as a future cue-spec mail candidate, the
sent mail stays FROZEN). If T5 shipped: checkpoint entry + AGENTS Lane-3
line. The docket adds pointers, never opinions; v19 opens at the
brainstorm, not here.

## Laws that bite (short list)

- Deterministic gates decide; a failed gate/critique BLOCKS ship —
  never downgraded. Presentation never mutates sim; audio stays a pure
  sink; replays deterministic by tick count.
- Read-before-edit · one-concern commits, explicit paths (never `git
  add -A`) · hooks run the suite (~60 s/commit; pre-push re-runs) ·
  long jobs DETACHED (nohup + poll) · JSON edits are SURGICAL text ops
  · multi-line scripts in temp files, never inline heredocs.
- Two instances fork a save — guard EVERY launch in a separate call
  judged by printed output; re-guard after Start-Process (s27 lag
  lesson); bot seats need `--save` scratch.
- Junior's lane (`drafts/_junior-*`, docs/JUNIOR.md) is his — harvest,
  never edit. Owner overrides are law the moment they land — one line,
  never re-litigated. No lore anywhere; placeholder names only.
- Cross-repo: read siblings freely, write ONLY via seat mail
  (+ RECEIPT lines); never write into a held seat. Sub-agent prompts
  forbid seat-mail handling explicitly.
- Verbatim means verbatim; partial evidence = bank what exists + name
  the gap. A rebase over a peer's push rewrites local hashes — re-verify
  cited hashes after any rebase.

## Budget + stop conditions

One attended session ~3.5 h (the wall sweep runs detached inside it),
context guard 85% → compact-checkpoint skill. Council 0; paid calls =
Rule-2 critics (the full wall burns ~20 critic calls — that IS the gate,
never economize it); sub-agents = the fresh-eyes reviewer only.
**Stop when:** J1 diagnosed (numbers banked) + fixed-or-honestly-boxed ·
T5 shipped behind the FULL WALL PASS + review PASS (or honestly STOPPED
with the ticket doc naming the block — a wall FAIL on a moved surface is
a finding to fix-and-rerun; on an UNMOVED surface it is a
STOP-and-classify) · checkpoint + owner queue es-CR + push.
**Stop early, honestly, if:** the spec's T5 text conflicts with this
spark (spec wins; re-plan in writing) · a gate fails non-mechanically ·
any zone other than low_quay/zone_7 moves bytes (STOP, name it) · the
owners redirect (their word is the router).
