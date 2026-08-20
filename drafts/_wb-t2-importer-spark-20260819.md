# SPARK: world-builder T2 — production importer + zone schema v2 (+ optional owner audio-morning lane)

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (rule 8) — Lane 3 (world-builder) is
owner-ratified; its spec is CLOSED:
`docs/superpowers/specs/2026-08-19-world-builder-pipeline.md` (D1–D12,
T1–T5; the live file beats this spark on any drift). T1 returned
**GO** — this session = **T2 exactly as ticketed**. Ruby per shell:
`export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language English;
owner surfaces es-CR ustedeo (everyday gamer words).

## Read first, in order

1. `AGENTS.md` — whole file (Lane 3 block; red lines; out-of-scope).
2. `docs/CHECKPOINT.md` — top TWO entries (session 19 = T1 GO + the
   same-day audio arc + links #5/#6; session 18 = grill/spec day).
3. The Lane 3 spec — WHOLE file. T2's ticket text is law; D1 (pin),
   D2 (importer sole door), D3/D4 (floors + `stairs_unlocked_by`
   amendment), D7 (tiles registry), D11/D12 (facts-only save, merge
   law) bind this session directly.
4. `drafts/_ldtk-spike-findings-20260819.md` — WHOLE file. The pin
   block + the 10-wrinkle table ARE this session's requirements
   feed (each wrinkle → a NAMED refusal case or a pinned project
   convention). The sidecar contract proposal lands in D2's wording.
5. `drafts/_m5a-verdict-20260818.md` §Ear-check 2 (asks 5–8) — ONLY
   if the owner opens the audio-morning lane (below).
6. Project memory traps (auto-injected): single-instance guard by
   printed output · logs flush at CLOSE · never edit a live-run
   script · wall receipts judged by per-script rc lines.

## Job 0 — standing SEVENTEENTH gate (compressed r9; ~15 min, FIRST)

- Launcher logs both temp-dir patterns — baseline **31/31**, newest
  `game_two_session_7461.log` (2026-08-19 20:44, CONSUMED — banked as
  solo chain link #6). Anything newer: classify per the r9 tree
  (AUTOPILOT → disqualified bot · ritual candidate → bank verbatim,
  the ritual OUTRANKS this session · solo `loaded`+`saved` pair on
  the real save → bank as link #7 per the #1–#6 pattern, anchor
  moves).
- Save quarantine: `saves/world.json` md5
  `8e94dcb8237b729eaa17222ae234d44d` mtime 2026-08-19 20:44; strict
  decode (pinned shape: `App::SaveStore.new(path:).load(data:
  Core::DataStore.new(<data dir>))` → `Loaded` record) LOADS
  `digest=66784a92f268776eeb917efb655449c6` sessions=8 banked=12
  provisions=0 breached=2 notices=[]. A moved save with no matching
  human log = NAMED anomaly.
- Junior baseline: `origin/junior/ci` `057fb03`, 0 commits past main;
  his seat pulls CURRENT main before any ritual join (audio v1.1 +
  ambient v2 moved tree content — same-commit handshake law).
- Seat mail (`~/.pi/agent/mail/game-two/`): done/=7 at spark time.
  Expected receipts (pre-approved banking acks only): audio seat
  (v1.1 masters banked) · assets (Gnomoria/RavenDawn style ack) ·
  gamesmith (NW-intro video ingest artifacts). Anything asking for
  code/data/oracle changes = RECORD + wait.
- Answers 0/8 expected. Residue: suite desync trio rewritten by every
  hook rake (session 19 made ~12 commits — correlate mtimes with
  `git log`); `drafts/_gate-verdicts.log` tail = the flywheel1 wall
  PASS entries (consumed); tmp/soak newest still `20260819-120805`.
- **EMPTY → ninth dated re-check block in
  `drafts/_v18-fun-verify-skeleton-20260818.md` (the established
  pattern; anchor now `66784a92…`/sessions=8) → the session's work
  begins. Anything else → r9 rules govern, T2 yields.**

## Owner audio-morning lane (OPTIONAL — runs FIRST only if the owner is present and asks; est. ≤1 h attended)

The owner scheduled asks 5–8 for "mañana con más calma" (verbatims +
dev plans: M5a verdict §Ear-check 2). If he opens with it:

- **Ask 5 (−4 dB percussive):** data-only — attack-family cue rows in
  `data/audio/cues.json` gain 4.0 → 2.5 (−4.08 dB). Suite proves
  structure; his ear proves level (next listen).
- **Ask 6 (dodge curation):** he names the WARM takes (A/B playback
  from `data/audio/files/msfx_dodge_150ms_*.wav` — ffplay or Reaper);
  shrink `variants.json` events.dodged to the keepers. No re-render,
  files stay banked.
- **Ask 8 (32-bar evolving loop — the REAL ask-4 intent):** scaffold
  ONE 64 s region in his open Reaper project (reascript pattern from
  session 19: `tmp/reaper_*.lua`, receipt-verified, `-nonewinst`
  works; near-miss law: matrix must carry ONLY the new region before
  any render — verify by receipt, unbind everything else). He
  designs; render → convert (`tmp/convert_24to16.py` pattern,
  sha-pinned) → `music.json` calm stem swaps to the 64 s loop;
  rotation config in `variants.json` goes dormant (bridge needs NO
  code change — config-only). Bar-exact: 64 s = 32 bars @120bpm.
- **Ask 7 (zone sound):** NEW owner render for `zone_entered`; the
  old ping's item-pickup repurpose PARKS with the item system (v19)
  — do not wire a fake event.
- Each ask = own commit (explicit paths, hooks run suite). Ear-check
  of results = his next play session (chain-link banking law applies
  to ANY solo launch: guard → detached → log → bank link #7).
- **Context guard:** if the audio lane consumed >40% of the session,
  STOP after it — checkpoint + re-spark T2 fresh. T2's byte-stability
  work must not run on a starved context.

## T2 — importer + schema v2 (the session's core; ticket text is law)

**Goal: the production door. LDtk output → zone JSON via
`tools/import_ldtk.rb`; zone schema grows floors/regions/tile-ids;
the six live zones stay BYTE-IDENTICAL on disk and byte-identical in
sim (D12: the measured world does not move).**

1. **D1 pin lands in the spec** (one amendment line): LDtk 1.5.3,
   `jsonVersion == "1.5.3"` refusal (appBuildId explicitly NOT
   pinned), installer md5 `11f9057d5889c0e51eee2ed43e8096cf`, pin
   ceremony (decline update prompts; upgrade = deliberate re-pin).
2. **Importer `tools/import_ldtk.rb`:** LDtk project → zone JSON.
   Every findings-table wrinkle becomes a NAMED refusal or pinned
   convention — minimum set: jsonVersion drift · `__value` vs
   `realEditorValues` disagreement (tamper tell) · unknown IntGrid
   value INCLUDING 0/void (cell coords in the error) · unknown entity
   type · missing/duplicate PackSpawn `order` · identifierStyle
   non-Free / unexpected level identifier · `externalLevels` (null
   layerInstances) · non-(0,0) entity pivot or level worldX/worldY ·
   overlapping entities on one tile · transition targeting an unknown
   zone. Refusals print NAMED reasons and exit nonzero (save-decoder
   register).
3. **Sidecar contract (D2 wording amendment):** LDtk owns SPATIAL
   truth (tiles + entities + display_name level field); the per-zone
   sidecar owns palette (incl. alpha), drop_gradient, gradient_anchor,
   tile_size. Importer merges; emitter defines the canonical byte
   format; round-trip property = import→emit→import fixpoint on
   authored zones (byte-stable), enforced by test.
4. **Zone schema v2 (ADDITIVE, defaults preserve today's files):**
   typed transitions (`stairs_up`/`stairs_down`/`hole`/`rope_spot`;
   default = today's breach shape) · `hole` may carry
   `stairs_unlocked_by: <breach-family fact>` (D4 amendment — schema
   + loader read this session; behavior wiring is T4/T5) · `floor:`
   int (default 0) · `regions:` list (id, rect, intent tag; LAYER
   only — no rules) · optional tile-type ids per D7. The six zone
   files in `data/zones/` are NOT touched; the loader reads v1 files
   unchanged (byte-identical disk + digest-identical sim).
5. **`data/tiles.json` registry v0:** `#` and `.` declare render
   (palette ref) + footstep material + passability. Hooks/variants
   stay reserved keys. Loader reads it; nothing consumes footstep yet
   (T3's lane).
6. **Tests (minitest, REAL fixtures — no mocks):** salvage
   `tmp/spike_district.ldtk` (LDtk-1.5.3-resaved REAL vendor bytes,
   md5 `59363c9427dde76e742a6b2bba31b563`) into `test/fixtures/`
   while it still exists — if tmp/ was cleaned, re-export district
   from the installed LDtk GUI (project regenerable via
   `tmp/spike_gen_ldtk.py` pattern; findings doc carries the schema
   notes). Refusal fixtures: small hand-mutated variants per named
   case. Round-trip byte-stability test. Schema-v2 loader tests.
7. **Verify (Rule 2/5):** `bundle exec rake` green · wall spot-gates:
   `rake gate SCRIPT=harness/scripts/low_quay_run.json` +
   `world_loop.json` (detached, no bash-call timeout — the
   disruption law; judge by printed output) · strict decode of the
   real save still loads (`66784a92…` sessions=8 — quarantine
   re-check at close).
8. **Done when:** importer refuses every named bad case with a NAMED
   error; six zones byte-stable on disk; suite + both spot-gates
   PASS; D1/D2/D4 amendment lines committed in the spec; findings doc
   cross-referenced.

## Laws that bite

- The SEVENTEENTH outranks everything — live ritual evidence → bank,
  T2 yields (r9 governs; the ritual runsheet still says Esc-quit —
  idea 6's menu is POST-VERDICT, do not touch Esc).
- The measured world stays byte-stable: `data/zones/*.json` and
  `data/balance/**` untouched; new schema is additive with defaults;
  any sim-digest movement = STOP, re-examine.
- One concern per commit, explicit paths, hooks run the suite; pull
  before push (Junior may land commits — rebase docs-only, inspect
  anything else); push promptly.
- Single-instance guard before ANY launch (separate call, judged by
  printed output). Never `--fresh`. Never write into the play path.
- tools/ is dev-tooling: no game-runtime require may reach into
  tools/ (the game must boot without it).
- Budget: one attended session; council 0 (lane budget consumed);
  Bedrock $0; no sub-agent fan-outs. If the audio lane ran long,
  STOP at the context guard — a half-done importer does not ship
  (Rule 6: gates decide, not optimism).

## Close

`docs/CHECKPOINT.md` new top entry: gate result (ninth EMPTY or what
landed) · audio-lane outcomes if run (asks 5–8 status + any link #7)
· T2 state (refusal cases landed / byte-stability proof / spot-gate
receipts) · quarantine spot (save md5 + digest + sessions + newest
temp log + count) · owner-pending (ritual when Junior is available ·
tomorrow-list remainder). Owner queue es-CR (~5 líneas): qué cerró,
qué sigue (T3 safe behaviors / T4 pilot authoring), qué espera de su
lado. Commit spark receipt + checkpoint, push.

## Stop conditions

- T2 done-conditions met + checkpoint + queue pushed → STOP (T3/T4
  run in fresh sessions).
- Ritual evidence landed → banked per r9 + checkpoint → STOP.
- Context guard fired after the audio lane → audio committed +
  checkpoint records "T2 re-spark owed" → STOP.
- Importer hits an unforeseen LDtk schema wall (something the spike
  missed) → findings-doc addendum + RECORD in checkpoint, ship what
  passed its gates, name the remainder → STOP.
