# SPARK sesión 27 — WB T4 pilot content authoring (owner-ratified lane) + owner-paced harvest lanes

You are the dev of record in game-two (cwd `~/workspace/game-two`). Read
`AGENTS.md` FIRST (rule 8) — the live file beats this spark on any drift.
Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language
English; owner surfaces es-CR ustedeo (everyday gamer words — never the
foreclosure register); Junior surfaces pt-br. Quality over cost: council 0
(Lane 3 consumed its consult budget, receipts banked); paid calls = Rule-2
gate/probe critics only. Evidence-first: claims are not evidence —
file:line, log line, or UNVERIFIED tag.

## Program state (2026-08-20 session-26 close — verify live)

- v18 CLOSED · **v19 NOT open** (brainstorm at the owners' word; agenda:
  `drafts/_v19-intake-docket-20260820.md` — pointers only). Session 26
  shipped **WB T3** (`261b867..6b829e4` pushed): footstep materials
  (registry v1: dirt/grass/wood; nest `.`→dirt remap, look PROVEN
  byte-stable 29/29 md5) · ambience keying (`data/audio/ambience.json`,
  bridge polls possessed body per seat, `AUDIO …` change-lines = the
  noDevice evidence lane) · flora variants (`App::TileVariants`, FNV
  coord hash; ZONE 6 `grass_fixture` INERT fixture) · god-view typed
  cells · `grass_fixture_walk` joined the wall + `flora_variants_read`
  conditioned check. Fresh-eyes PASS 8/8; ticket
  `drafts/_wb-t3-safe-behaviors-20260820.md`; review receipt
  `drafts/_wb-t3-review-20260820.md`.
- **World-builder lane:** T1 GO (s19) · T2 importer+schema v2 (s20) ·
  T3 SHIPPED (s26) · **T4 is THE session job** · T5 wire-in stays gated
  on its OWN full-wall pass (the SEVENTEENTH verdict landed but T5 waits
  its turn; lane order owner-steerable — note, never promote).
- **Audio seat:** T3 cue-spec mail SENT and unanswered (their root:
  `from-game-two-t3-cue-spec.md` md5 `d556358aa68d4d10c39f27191801a8cc`
  — step families stone/dirt/grass/wood + beds meadow/town/dungeon).
  NOTHING owed before the owner's renders; their receipt/reply is an
  expected mail delta, not work.
- **Junior is READY for coop S1 and awaits GABRIEL'S INVITE** (his
  `ad517e2`) — the invite is the owner's to send, NEVER nag. Both seats
  pull `ce78bfc`+ first (protocol v3 refuses mixed builds NAMED).
- **Owner-pending (never nag):** ear-checks (¿se acabó la duplicación? ·
  ¿la música respira? · stinger overlap → depth-duck library increment si
  falla) + audio-v12 batch · Junior's lag-T4 re-run (outcome classes
  pre-declared in `drafts/_lag-t4-vsync-20260820.md` §4) · **T3
  footstep/bed renders** (es-CR list lives in the cue-spec mail) · the
  v19 brainstorm.
- **R-A2 measure (silent, NEVER prime):** `sustain bought=0` on every
  banked HUMAN log. Harvest `TELEMETRY sustain` + frame_probe/handshake
  lines from every NEW human launcher log; bot lines are never evidence.

## Job 0 — standing gate (~10 min; anything moved = classify in writing FIRST)

Baselines at staging: origin/main `6b829e4` + EXPECTED docs-only delta
(this spark's own commit) · save `saves/world.json` md5
`98fe75edb6d72deab18cd48eaa88bdaf` mtime 08-20 15:51 (sessions=13
banked=7 provisions=0 seals=2) · launcher logs 38×2 (`$TEMP` +
`/tmp` views, pattern `game_two_session_*.log`) · game-two mail inbox
EMPTY, done/=19 · tmp/soak newest `20260820-020422` · untracked
`drafts/_refs/` only · tmp/t3/ + captures/grass_fixture* = session-26
artifacts (expected). EXPECTED deltas: Junior docs-only commits (his
lane — read before rebasing) · audio-seat receipt for the cue-spec mail
(their done/ move or a reply into OUR inbox) · new human launcher logs
if the owners played (harvest silently) · coop S1 artifacts if the
invite went out. `git pull --ff-only` FIRST. Single-instance guard
before any launch (separate call, judged by printed output). `--fresh`
NEVER. Background `bin/play` from pi's bash DIES silently — the working
launcher is `powershell Start-Process bin\play.cmd`; bot seats launch
fine as `nohup … src/main.rb --bot <seed> --bot-ticks <n> --save
tmp/<dir>/world.json [--start-zone <z>] &`.

## GATE 0 OVERRIDE — any live owner order preempts this whole queue

- **Ear-check verdicts** are LAW: bank verbatim, route per the three
  checkpoint questions; stinger-overlap failure → depth-aware-duck gets
  grilled in game-two-audio (library increment), never a data tweak here.
- **T3 renders landing** (owner Reaper exports via game-two-audio
  handoff): a ~45-min integration lane — sha-pinned fixture conversion
  (v1.1 pattern) + data-only `cues.json`/`fixtures.json` rows for
  `footstep_<material>` / `ambience_<key>` + suite + a noDevice re-walk
  banking the now-mapped keys + one es-CR line for the ear-check queue.
  Do it BEFORE J1 if the handoff is waiting at gate 0.
- **Junior's lag re-run lines** (chat or docs push): bank verbatim into
  the lag ticket §4, adjudicate against the pre-declared classes, es-CR
  line to the owner (~30 min, before J1 if waiting).
- **A live coop session = lag segment S1**: support, harvest verbatim
  per `drafts/_lag-t2-evidence/README.md`, bank md5-stamped.

## J1 — WB T4: pilot content authoring (THE session job; spec is law)

Read IN ORDER before any edit: (1) AGENTS.md whole · (2) checkpoint top
2 entries · (3) `docs/superpowers/specs/2026-08-19-world-builder-pipeline.md`
WHOLE — T4's ticket text + §Pilot content + D1–D12 govern · (4) T3
ticket + review (`drafts/_wb-t3-*-20260820.md`) — the shipped seams T4
builds on · (5) `tools/import_ldtk.rb` header→CLI + the T2 fixture
(`test/fixtures/spike_district.ldtk` = REAL 1.5.3 vendor bytes, the
reference shape for authored projects) · (6) how seals/breach work
today (`grep -n breached src/game/world.rb`, seal render in
renderer.rb) — the well reuses this machinery.

**T4 ticket (spec §Tickets, verbatim scope):** ZONE 7 + TOWN 1 + THE
WELL + DUNGEON 1 authored IN LDTK through the T2 importer; boss-gate
transition + well-drain fact implemented but the zone stays INERT (D12
— no live-graph transition; dev entry via `--start-zone`). Probe gates
per zone + soak rotation extended. Verify: probe gate PASS ×2 zones;
soak episode in ZONE 7/DUNGEON 1 PASS; live-world saves byte-stable.
Done: owner can walk the town, drain the well, fall into DUNGEON 1,
rope back — from a dev launch.

**Three shape forks — settle them in a 15-min written grill block at the
TOP of the ticket doc (`drafts/_wb-t4-pilot-20260821.md`), then execute
(rule 5: one bundled change-set). Dev-of-record proposals to defend or
beat, spec citations attached:**

1. **Authored-source home + authoring mode.** Proposal: `authoring/`
   dir at repo root — `authoring/pilot.ldtk` + per-zone sidecars,
   committed (git is the world store, D1); import = the DELIBERATE copy
   `ruby tools/import_ldtk.rb authoring/pilot.ldtk --sidecars authoring/
   --out data/zones` (D2: output never defaults into data/zones).
   Hand-write the .ldtk JSON against the T2 fixture's 1.5.3 shape — the
   importer's refusal set (pin, tamper tells, realEditorValues backing:
   `field_value` in import_ldtk.rb) is the arbiter of "authored in
   LDtk"; the owner opens the same project in his pinned 1.5.3 later.
   ⚠️ hand-authored fields MUST carry consistent `__value` +
   `realEditorValues` pairs or the importer refuses (that refusal is
   CORRECT — satisfy it, never relax it). `.gitattributes -text` for
   .ldtk (T2 precedent).
2. **THE WELL = existing machinery, zero new sim vocabulary.**
   Proposal: the well is a SEALED `hole` transition (breach family —
   priced station opens it, toll machinery verbatim per spec) + WATER
   as a decorative tile type (passability floor, new registry type +
   palette refs; "swim" stays RESERVED) whose look swaps on the
   persisted fact (render-only: palette/variant law, the T3
   visible-overlay seam). Passability NEVER changes with state. The
   drain fact persists through the EXISTING breached family (D11:
   zero new save schema — verify the strict decoder needs NOTHING).
3. **Impassable borders stay `#`.** Trees/fence/structure looks come
   from per-zone palette + motif + decor (v16 identity channels) —
   the wall law (`#` ⇔ passability wall, tile_registry.rb) stands;
   rewiring `passable?` through the registry is a RECORDED post-verdict
   increment, not T4 (T2's own comment says gated, sim-visible).

**Sim wiring T4 DOES own (the D4 note says behavior lands T4/T5):**
typed-transition behaviors — `hole` one-way (falling commits; no return
transition at the landing) · `rope_spot` = free station-type interact
back up (v0 free; rope-as-item waits for the items cycle) ·
`stairs_up/down` = ordinary two-way transitions · `stairs_unlocked_by`
on a hole (D4 amendment — schema shipped in T2, wire if authoring uses
it). Absent `type` = today's gate behavior BYTE-EXACT (every live zone
is untyped — that is the regression bar). D5: nothing crosses floors
(projectiles/AoE/AI/targeting) — structurally true, keep it so. D6:
respawn/home rules untouched.

**Zones + names (placeholder law):** `zone_7` "ZONE 7" (surface, floor
0; TOWN 1 is a REGION in it, town intent — ambience amb_town keys for
free from T3) · basements ≥2 as FLOOR -1 zones via stairs_down
(BASEMENT 1/2) · `dungeon_1` "DUNGEON 1" (FLOOR -1, conservative combat
authored) · THE WELL + depot slot + empty SLOTS per spec (stores/NPCs/
quests/ledger-board = future cycles, author the SPACE not the system).
Boss-gate transition INTO zone_7 reads persisted `boss_1_defeats ≥ 1`
— implemented but NOT wired into any live zone's JSON (D12: the live
world's files stay untouched; the gate lands in T5). Locale lines
(en/es/pt-br) locale-invariant placeholders; depth darkens palettes
(authored, D3).

**Sequencing the dev of record proposes:** grill block → registry/data
additions (water + any decor types; TDD like T3) → transition-behavior
sim wiring (red-first: hole one-way, rope interact, stairs, unlock
fact; world_test lane) → author the .ldtk + sidecars → import →
per-zone probe gates (D10: decision-13 pattern — staged facts + pixel
asserts + vision critique per zone; NO new wall scripts,
`multi_floor_descent.json` is T5's) → soak lane (see trap below) →
walkthrough evidence (bot + scripted pilot: town → drain → fall → rope,
logs banked) → one-concern commits → ticket doc → **fresh-eyes review
BLOCKING** (scrubbed read-only pi; the prompt MUST say "touch NOTHING,
including seat mail" — s26 lesson, it's in MEMORY.md) → checkpoint +
push + es-CR owner queue (~5 líneas).

**Traps named (hit these, classify in writing, never patch around):**
- soak `chain_check.rb` asserts combat outside hubs — a threat-free
  ZONE 7 episode FAILS it by design. Extending rotation means a
  deliberate, tested chain_check amendment (per-zone combat
  expectation) or dungeon-only episodes — decide in the grill block;
  soak infra lives under `soak/`, never `harness/` (the wall stays
  persistence-blind).
- Two sim-code baselines: bank `rake capture` md5 baselines
  (world_loop at minimum) BEFORE the first sim-touching commit (T3
  precedent, `tmp/t3_world_loop_baseline.md5` pattern) — a detached
  sweep loads source fresh per episode (MEMORY: freeze edits while
  anything replays).
- God-view + `map_artifact` labels test + zone-shape mirror tests WILL
  move when zones land (T3 hit all three) — update them deliberately,
  one commit with the data.
- `saves/world.json` md5 must NEVER move this session (no live-world
  play; bots on scratch saves with `--save`).

Hard limits: zero live-zone file edits (the six + grass_fixture stay
byte-identical; D12) · no new EventBus symbols unless a system truly
needs one (rule 4) · `src/app/window.rb` ≤ ~300 lines ·
sim-class TILE behaviors (lava damage, water movement, tile-gated
spawns) stay OUT (post-verdict, one gated piece each — refuse in
writing if tempted; the well's machinery is breach-family, not a tile
hook) · DUNGEON 1 combat must not retune what the live world measures
(conservative numbers, data-only, its own balance file entries).

## J2 — docket hygiene (only if J1 leaves room; ~15 min, docs-only)

If T4 shipped: checkpoint entry + AGENTS Lane-3 ticket-state line (T4
SHIPPED, T5 next-at-owner-word) + push. Docket rows: none expected to
move (verify — its "T4" rows are the LAG namespace, s26 precedent).

## Laws that bite (short list)

- Deterministic gates decide; a failed gate/critique BLOCKS ship —
  never downgraded. Presentation never mutates sim; audio stays a pure
  sink; replays deterministic by tick count.
- Read-before-edit · one-concern commits, explicit paths (never `git
  add -A`) · hooks run the suite (~60 s/commit; pre-push re-runs) ·
  long jobs DETACHED (nohup + poll; never under a bash-call timeout — a
  killed gate is judged by a standalone re-run) · JSON edits are
  SURGICAL text ops · multi-line scripts in temp files, never inline
  heredocs.
- Two instances fork the save — guard every launch in a separate call
  judged by printed output; bot seats need `--save` scratch; phantom
  sessions get NAMED.
- Junior's lane (`drafts/_junior-*`, docs/JUNIOR.md) is his — harvest,
  never edit. Owner overrides are law the moment they land — one line,
  never re-litigated. No lore anywhere; placeholder names only;
  register law on every player-visible line (es-CR everyday words).
- Cross-repo: read siblings freely, write ONLY via seat mail
  (+ RECEIPT lines); never write into a held seat. Sub-agent prompts
  forbid seat-mail handling explicitly (s26 lesson).
- Verbatim means verbatim; partial evidence = bank what exists + name
  the gap. A rebase over a peer's push rewrites local hashes — re-verify
  cited hashes after any rebase.

## Budget + stop conditions

One attended session ~3 h, context guard 85% → compact-checkpoint
skill. Council 0; paid calls = Rule-2 gate/probe critics only;
sub-agents = J1's fresh-eyes reviewer only. **Stop when:** T4 shipped
behind its gates + review PASS (or honestly STOPPED with the ticket doc
naming the block and the authored subset banked INERT) · checkpoint +
owner queue es-CR (~5 líneas) + push. **Stop early, honestly, if:** the
spec's T4 text conflicts with this spark (spec wins; re-plan in
writing) · a gate fails non-mechanically · the live-world byte-stability
bar breaks (STOP, name it, never patch around) · scope genuinely
exceeds the session (ship the INERT authored subset behind its gates,
name the remainder — never a rushed unreviewed tail) · the owners
redirect (their word is the router).
