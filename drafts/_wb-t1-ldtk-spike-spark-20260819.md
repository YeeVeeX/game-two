# SPARK: world-builder T1 — LDtk spike (GO/NO-GO) + standing-gate pass + wall-receipt harvest

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (rule 8) — Lane 3 (world-builder pipeline) is
OWNER-RATIFIED and its spec is CLOSED:
`docs/superpowers/specs/2026-08-19-world-builder-pipeline.md` (D1–D12
+ tickets T1–T5; the live file beats this spark on any drift). This
session = **T1 exactly as ticketed** — prove or kill the LDtk bet.
Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`. Working
language English; owner surfaces es-CR ustedeo (everyday gamer words —
the register law).

## Read first, in order

1. `AGENTS.md` — whole file (Lane 3 block; the two permanent red
   lines; out-of-scope list).
2. `docs/CHECKPOINT.md` — top TWO entries (session 18 = grill/spec/
   spark day; session 17 = flywheel fixes + the still-standing
   SEVENTEENTH state).
3. The Lane 3 spec — WHOLE file (D1–D12, pilot, non-goals, T1's own
   ticket text governs this session).
4. `drafts/_world-builder-grill-20260819.md` — owner verbatims,
   council folds, ratified answers (context, not new law).
5. `drafts/_v18-seventeenth-harvest-spark-r9-20260819.md` §Job 0 —
   the STANDING evidence gate (runs first, compressed; below).
6. Project memory traps (auto-injected): single-instance guard by
   printed output · human logs flush at CLOSE · never edit a script a
   live run executes · wall receipts judged by per-script rc lines.

## Job 0 — wall receipt + standing gate (~20 min, FIRST no matter what)

- **Wall `flywheel1-20260819` receipt** (launched session 17,
  detached): read `tmp/wall_flywheel1.log` — count
  `gate_rc=0 manifest_rc=0` lines vs `=== WALL` headers (18 scripts).
  Expected 18/18 PASS (11/18 and climbing at spark time, zero
  failures). ANY failed script: re-run that gate STANDALONE
  (`rake gate SCRIPT=harness/scripts/<name>.json`, detached, no
  bash-call timeout — the disruption law) and judge by its printed
  output; a REAL failure = the three renderer fixes (`48cf0db`,
  `abc9f53`, `1360b27`) get re-examined, T1 yields the session.
  Record the receipt in the checkpoint either way.
- **Standing SEVENTEENTH gate (compressed r9 Job 0; EMPTY expected):**
  launcher logs both temp-dir patterns — baseline 29/29, newest
  `game_two_session_7196.log` (00:06, CONSUMED); anything newer =
  classify per the r9 tree (AUTOPILOT → disqualified bot · ritual
  candidate → bank verbatim, the ritual OUTRANKS this whole session ·
  solo chain link → bank per the #1–#4 pattern, anchor moves).
  Save quarantine: `saves/world.json` md5
  `30ff315dc36ee183c42eb040c08e6030` mtime 2026-08-18 22:36; strict
  decode (pinned shape) LOADS `digest=189a80723c87b90f27bc8436533d8cc1`
  sessions=6 banked=20 seals=2 marks=0 boss_1_defeats=1 provisions=0
  notices=[]. A moved save with no matching human log = NAMED anomaly.
  NOTE: the owner's pending ambient ear-check listen legitimately
  moves it → bank as solo link #5 + record his verbatim in the M5a
  verdict. Junior baseline: nothing past main (`origin/junior/ci`
  `057fb03`); his seat pulls CURRENT main before any ritual join.
  Seat mail: expect possible receipts (assets tile-era ack · audio
  cue-families ack · assets family-sync — pre-approved banking only;
  anything asking for code/data/oracle changes = RECORD + wait).
  Answers 0/8 expected. EMPTY → one dated re-check block in the
  fun-verify skeleton (eighth; the established pattern) → T1 owns the
  session. Anything else → r9 rules govern, T1 yields.

## T1 — LDtk spike (the session's work; ticket text is law)

**Goal: GO/NO-GO on LDtk as the authoring front-end. THROWAWAY code
only — no production files, no `data/` changes in the real tree, no
Rule 2 gate owed (nothing ships).**

1. **Install + pin:** download LDtk (Windows). Record the EXACT
   version installed — that version becomes the D1 pin candidate.
   Note install friction honestly (the owner will use this tool).
2. **Rebuild `district` in LDtk:** IntGrid layer for walls/floor
   (26 rows — read `data/zones/district.json` tiles), entity layer
   for stations/transitions/spawns (fields: type, at, price, opens,
   to, spawn). You are ALSO evaluating authoring UX — note where the
   editor delights or fights (the owner's joy is a requirement, not a
   nicety).
3. **Throwaway importer** (`tmp/spike_import_ldtk.rb`): LDtk JSON →
   our zone JSON shape. Hardcode freely, no tests owed — but note
   every mapping wrinkle (IntGrid→ASCII, entity fields, coordinate
   origins, `jsonVersion` location) in the findings doc: T2 inherits
   these as its refusal cases.
4. **Walk it in-game (worktree isolation — never the live tree/save):**
   `git worktree add tmp/spike_wt HEAD` · overwrite ONLY
   `tmp/spike_wt/data/zones/district.json` with the imported output ·
   single-instance guard (separate call, judged by printed output:
   `MSYS_NO_PATHCONV=1 tasklist /FI "IMAGENAME eq ruby.exe"`) ·
   launch the WORKTREE solo detached
   (`cd tmp/spike_wt && nohup bin/play > ../spike_console.log 2>&1 &`)
   — its `saves/` is worktree-local, the real save untouched by
   construction · play into ZONE 2, verify walls/gates/stations sit
   where authored · Esc quit · judge by the worktree's session log
   (flush-at-close) · verify the REAL `saves/world.json` md5 unmoved ·
   `git worktree remove tmp/spike_wt --force`.
5. **Findings doc** `drafts/_ldtk-spike-findings-20260820.md`:
   version pinned · authoring-UX verdict (owner-joy axis, honest) ·
   mapping wrinkles table (→ T2 refusal cases) · round-trip gaps ·
   **GO/NO-GO recommendation**. NO-GO → the Tiled fallback replaces
   the front-end half of T2 (D1 records the swap; owner informed in
   the queue, his veto stands).

## Laws that bite

- The SEVENTEENTH outranks everything — live ritual evidence appears
  → bank it, T1 yields (r9 governs).
- Real tree stays clean: spike artifacts live in `tmp/` +
  `drafts/_ldtk-spike-findings-*.md` ONLY. The spec and AGENTS.md do
  NOT change this session (T2 lands the pin into D1 after GO).
- Single-instance guard before EVERY launch, separate call, printed
  output. Never `--fresh`. Never write into the play path.
- Commits: findings doc + checkpoint entry only, explicit paths,
  hooks run the suite; pull before push, push promptly.
- Budget: one session ~2h attended; council 0; Bedrock $0; no
  sub-agent fan-outs. LDtk download is the only network dependency —
  if it fails, record and stop (don't improvise a different tool
  mid-session; the fallback decision is T2's, informed by findings).

## Close

`docs/CHECKPOINT.md` new top entry: wall receipt (18/18 or the named
re-runs) · standing-gate result (eighth EMPTY block or what landed) ·
T1 GO/NO-GO + findings path + LDtk version · quarantine spot (save
md5 + digest + sessions + newest temp log + count) · owner-pending
list unchanged (ear-check · 7 renders · ritual — never nag). Owner
queue es-CR (~5 líneas): qué se probó, el veredicto GO/NO-GO en
palabras simples, qué sigue (T2) y qué está esperando de su lado.

## Stop conditions

- GO/NO-GO recorded + findings committed + checkpoint + queue pushed
  → STOP (T2 runs in a FRESH session with the findings doc as input).
- Ritual evidence landed → banked per r9 + checkpoint → STOP.
- LDtk unobtainable → findings doc records the block, NO-GO-pending
  → STOP.
