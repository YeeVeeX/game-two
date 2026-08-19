# SPARK: v18 session 11 — the SEVENTEENTH: full harvest + adjudication (or honest PARTIAL/EMPTY); solo chain links + v19 intake ride

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST — the v18 scope contract is ground truth. Ruby
per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language
English; owner surfaces es-CR ustedeo; Junior surfaces pt-br;
everyday gamer words everywhere (register law — no legal/notarial
vocabulary; the foreclosure-register audit applies to your own es/pt
output).

**What this session is:** the adjudication vehicle for the SEVENTEENTH
ask, revision r4 — supersedes r3
(`drafts/_v18-seventeenth-harvest-spark-r3-20260818.md`). What changed
since r3: session 10 ran the gate and found EMPTY — every r3 baseline
re-verified live and UNCHANGED (anchor `602e94bb…` held on disk, logs
23/23, Junior silent, 0/8 answers); the only movement was mechanical
residue (the desync trio rewrites on every hook rake — correlation
baseline below), and the strict-decode call shape is now pinned (it
cost session 10 one failed try). If both ritual sessions + all eight
answers exist, you harvest, run the four Half-A checks, record Half B
verbatim, walk EVERY routing row, and decide on the spec's own terms.
If evidence is incomplete, you bank what exists verbatim, name the
gaps, and STOP — session 5 (`72e9297`) is the PARTIAL precedent;
sessions 9+10 (`2db6118`, `fa4f323`) are the EMPTY precedent; the
session-9 addendum (`040d548`) is the solo-link banking precedent.
Never fudge, never waive, never nag the humans to play.

**What this session is NOT:** not a build session (build phase CLOSED,
increments 0–8 + soak shipped), not the ritual itself (a dev session
never plays it), not v19 (nothing new starts until this adjudicates —
the intake slot banks and triages only). **Bots never adjudicate: any
log carrying an `AUTOPILOT seed=` line is bot-driven and DISQUALIFIED
as session evidence, no matter how green it looks** — apply it to
every log you touch.

## Read first, in order

1. `AGENTS.md` — whole file (scope contract, Commands, the soak
   bullet's quarantine law, enforcement).
2. `docs/CHECKPOINT.md` — top FOUR entries (session 10: second EMPTY
   gate, the re-check pattern; session 9: EMPTY + the solo chain link
   #1 addendum; session 8: soak shipped + residue laws; sessions 7/5:
   the banking format).
3. `drafts/_v18-fun-verify-skeleton-20260818.md` — THE working file:
   ritual restated, telemetry slots, Half A checks PENDING, Half B
   questions, residue traps (tmp/netplay + soak), TWO dated re-check
   blocks (sessions 9+10 — the EMPTY pattern), **Solo chain link #1**
   (the banking pattern you reuse for any new solo log), side-signal
   HELD, gaps list. You fill THIS file; adjudication sections get
   written only in FULL mode.
4. The spec §Fun-verify:
   `docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md`
   — the four Half-A checks and the ROUTING TABLE are CLOSED there;
   quote rows verbatim when you walk them, never restate from memory.
5. `drafts/_v18-seventeenth-runsheet-20260818.md` — the question
   wording (es + pt-br, pre-registered, panel-checked). Questions go
   out VIRGIN from this sheet; answers come back verbatim.
6. `drafts/_v17-fun-verify-skeleton-20260816.md` — the SIXTEENTH's
   adjudicated file = the verdict FORMAT precedent.
7. `drafts/_junior-soak-20260818.md` + `_v18-soak-brief-20260818.md` —
   what bot artifacts look like (banner line, tmp/soak layout), so you
   never mistake one for evidence.
8. Project memory traps: judge sessions ONLY by TELEMETRY lines
   (process-alive ≠ session-alive); HUMAN launcher logs flush at CLOSE
   (a 0-byte log mid-play is normal; log bytes lie until quit); `$?`
   after a pipe lies; never edit a script a live run is executing.
9. `git pull --ff-only` FIRST and before every push. After any crash
   or power cut on this machine (two survived already): verify
   HEAD==origin, tree clean, and the save strict-decodes BEFORE
   anything else.

## Job 0 — evidence inventory (three-mode gate; ~30 min, blocking)

Baselines at session-10 close (2026-08-18 ~20:47) — re-verified live
that session, all unchanged from r3:

- **Newest legitimate human launcher log:** `game_two_session_6508.log`
  (2026-08-18 18:00:31, 1791 bytes) — the owner's SOLO session, ALREADY
  BANKED as chain link #1 (skeleton + md5-identical copy in
  `drafts/_v18-seventeenth-evidence/`). Count was **23 per temp dir**.
  Anything newer than it is unconsumed evidence; anything older is
  already classified.
- **Save expectation IF NOTHING MOVED IT:** play-path strict decode
  returns LOADED `digest=602e94bbf7d417d845c73e3702fd4675`,
  sessions=3, banked=20, seals=2, marks=3, boss_1_defeats=1; file md5
  `213076c540cc9eed846172748aae2e10`, mtime 2026-08-18 18:00:31.
  Decode shape (pinned in s10): `App::SaveStore.new(path:).load(data:
  Core::DataStore.new(<data dir>))` — `data:` is a kwarg of `#load`,
  not the constructor. Owner solo/coop play legitimately moves the
  save — but **every save move must have a matching human launcher
  log to bank; a moved save with NO matching log is a NAMED anomaly**
  (investigate, never assume). The save is DIAGNOSTIC context for the
  chain walk, never one of the four checks.
- **Junior baseline:** no commits past `184f652` (session-10 close);
  stale remote branches (`origin/junior/ci` = `057fb03`, 2026-08-16;
  `origin/v13-aoe`) stay stale. His artifacts arrive by paste, drafts
  file, or commit only — his ritual logs live on HIS machine.
- **Residue baseline:** the suite trio
  `desync_00000064`/`000008a9`/`00000bf7` (`platform:"test"`,
  `dddd…`/`cccc…` fingerprints) is rewritten by EVERY `bundle exec
  rake` — hooks included, so every commit moves its mtimes (at s10
  close: 20:46:27–48, the `fa4f323`/`184f652` hook window). Correlate
  with commit times + `drafts/_gate-verdicts.log` (tail unchanged
  since 2026-08-18 17:11 unless a real gate ran), classify, move on.
  `desync_00000047` (17:10:53) = session-9's net-gates close run,
  already classified. tmp/soak reports all ≤ 15:16:05 (session-8's
  own validation).

Inventory BOTH patterns (`/tmp/game_two_session_*.log` AND
`/c/Users/gabri/AppData/Local/Temp/game_two_session_*.log` — same dir
both ways on this machine, check both anyway), sorted by mtime; read
EVERY log newer than baseline IN FULL. Classification tree per log:

- has `AUTOPILOT seed=` → BOT, disqualified (note it, move on).
- has `TELEMETRY netplay` lines: `ticks=0` → idle attempt · `reason=`
  ≠ quit or ticks < 36000 → ritual shortfall (ritual law: that session
  RE-RUNS, owner-paced — bank the log, name the shortfall) · else →
  **candidate ritual session** (bank verbatim: netplay + every persist
  + any sustain line, with file name + mtime).
- no netplay lines, `persist loaded` + `persist saved` pair → **SOLO
  CHAIN LINK #N** (the link-#1 pattern): bank loaded/saved lines
  verbatim in the skeleton's pre-session evidence, record any sustain
  line as HELD, copy the file md5-identical into
  `drafts/_v18-seventeenth-evidence/`, update the moving-anchor
  statement (ritual session 1's expected host `loaded` = the LATEST
  saved digest in the chain) + the checkpoint quarantine spot, verify
  disk strict-decode == the saved digest line. Solo links are
  diagnostic chain context, never ritual sessions, never gap-fillers.
- `persist loaded` but NO saved line → unclean/crashed solo attempt:
  recorded NAMED; the world did not move.
- `tmp/netplay/` + `tmp/soak/**` artifacts: the skeleton's residue
  laws (suite/gate windows via `drafts/_gate-verdicts.log` + hook-rake
  correlation, `platform:"test"` / `dddd…` fingerprints, AUTOPILOT) —
  classify every one, bank none as live evidence.
- **Answers:** all eight (4 owner es, 4 Junior pt-br), gathered
  SEPARATELY, after both sessions. Partial answer sets = PARTIAL mode.
- Also inventory NEW `tmp/soak/*/report.txt` newer than 2026-08-18
  15:16:05 (the owner has the overnight one-liner) → feeds Job 5,
  never the oracle.

**Mode decision (write it in the skeleton before anything else):**
- **FULL** = two ritual coop sessions on DIFFERENT days (both seats'
  logs, all ≥ 36000 ticks, reason=quit, AUTOPILOT-free) + all eight
  answers → Jobs 1–4.
- **PARTIAL** = anything less, but something new banked → bank
  verbatim (session-5 style: provenance + attribution
  machine-verified), name the exact gaps in the skeleton's gap list,
  then Job 5+. If sessions exist but answers are missing: hand the
  owner the run-sheet POINTERS for the asking step (exact file +
  section; do NOT rewrite or paraphrase the questions — wording stays
  virgin) and stop there.
- **EMPTY** = nothing new → dated re-check line appended to the
  skeleton's gate-result section (the session-9/10 blocks are the
  pattern), then Job 5+.

## Live-launch protocol (if the owner asks to play DURING this session)

Session-9 precedent — sanctioned interactive work, not a detour:

- Solo: `git pull --ff-only`, verify no ruby.exe is already running
  (`tasklist //FI "IMAGENAME eq ruby.exe"`), then launch DETACHED:
  `nohup bin/play es > tmp/solo_launcher_console_<ts>.log 2>&1 &`.
  **NEVER `--fresh`** (it resets his world), never a bash timeout that
  can kill the game, never write into the play path.
- Coop at his ask: same shape with `--host` (Junior joins from his
  machine). A ritual attempt is judged by its LOG at close, never
  mid-flight.
- Human logs flush at CLOSE: a 0-byte `game_two_session_<pid>.log`
  mid-play is normal. Process alive (Console session 1) = handed over;
  tell him the window may open behind others, and that Esc saves.
- On his "listo": confirm the process exited, read the log IN FULL,
  run the classification tree, verify the chain against disk
  (strict-decode == the log's saved digest), bank + commit + push.
- **Priming quarantine:** while any Half-B answer is pending, never
  discuss with either player: continuity feel, respawn/difficulty,
  sustain/provisions, or anything a routing row reads. Factual world
  state (what carried, counters) is fine — they see it in-game anyway.
  You never ask the run-sheet questions yourself; the owner asks, you
  hand pointers.

## Job 1 — FULL only: harvest into the skeleton (~45 min)

Fill every telemetry slot VERBATIM (2 sessions × 2 seats netplay
lines; every persist line host+joiner; solo-link logs into the chain
in mtime order; sustain lines if any). Every line cites its source
file + mtime; Junior's lines cite paste/commit provenance. Copy every
evidence log md5-identical into `drafts/_v18-seventeenth-evidence/`
(tracked — the harvest must survive temp-dir cleanup).

## Job 2 — FULL only: Half A, the four checks (~30 min)

Spec verbatim, each PASS/FAIL with the quoted lines beside it:
1. Session 2 host `persist loaded digest` == latest prior `persist
   saved digest` (SOLO saves included in the chain).
2. Joiner `loaded … source=handshake` digest == host's digest, BOTH
   sessions.
3. `desyncs=0` + `reason=quit` on all four netplay lines; ticks ≥
   36000 each session; all four logs AUTOPILOT-free.
4. Carried fact: session 2's persist line shows accreted state
   matching session 1's close — at least one strictly-positive carried
   fact named (banked/seals/marks/sessions).
Full chronological chain walk (every `loaded` == previous `saved`,
solo links included) as diagnostic context. A FAILED check = an
adjudication result, not a bug hunt — no in-session fixes; the routing
table owns what happens next.

## Job 3 — FULL only: Half B verbatim (~20 min)

Record all eight answers in the players' own words and language — no
paraphrase, no scoring, no register cleanup of THEIR words. Any
protocol deviation (wording changed, asked together, changelog shown)
is recorded NAMED beside the answer — adjudicate with the caveat,
never silently. ONLY after both sets are in do these enter the
reading: the HELD side-signal
(`_junior-specials-chain-retry-20260818.md`) and every `TELEMETRY
sustain` line (chain link #1 already banked
`sustain bought=0 used=0 refused=4` — HELD, unread).

## Job 4 — FULL only: routing walk + decision + close-out (~45 min)

- Walk EVERY row of the spec's routing table: quote the row, TRIGGERED
  / NOT, exact evidence lines cited. Triggered row = RECORDED work
  item with a recommended next-spark shape — never an in-session fix.
- Decide on the spec's terms: Half A mechanical, Half B felt. Write
  the Adjudication section (v17 skeleton = format precedent).
- **CUMPLIDO both halves** → v18 cycle CLOSES: AGENTS.md scope block
  gets the adjudication line (v17-close precedent — status + date +
  verdict pointer; do NOT open v19, do NOT restructure the file);
  PARKING_LOT pointer to the waiting v19 pool noted in the checkpoint.
- **Any half NOT cumplido** → verdict recorded honestly; AGENTS.md
  status line updated (still open, what's owed); triggered rows = the
  named backlog, owner-paced.
- Owner queue (es-CR ustedeo, ~5 lines): el resultado en sus términos,
  qué línea de evidencia lo decidió, qué sigue (o que no sigue nada
  hasta que ustedes quieran).

## Job 5 — soak-report side harvest (hardening lane; ~15 min)

New `tmp/soak/*/report.txt` runs (newer than 2026-08-18 15:16:05):
read reports + any FAIL bundles. Findings are RECORDED with next-spark
shapes. Exception tripwire: a desync or persistence defect caught by
bots BEFORE the ritual is played = flag in the owner queue as
"recomiendo arreglar antes de su sesión" — fix in-session ONLY if
small and mechanical (TDD, own commit, wall owed at close); anything
bigger is bundled + recorded. A soak PASS is one checkpoint line.

## Job 6 — v19 intake slot (docs-only)

If Junior's ideas list arrived (paste/drafts/commit — it may arrive
BUNDLED with his ritual answers: SPLIT them; answers → skeleton
verbatim, ideas → intake): bank verbatim in
`drafts/_junior-v19-ideas-<date>.md` (his words, his language), then
triage Itexo-style (`drafts/_itexo-intake-triage-20260818.md` is the
template): FOLD-NOW (only as evidence input to adjudication — build is
closed) / BANK / PARK with named trigger / ROUTE-SIBLING, reasons
cited. PARKING_LOT entries for parks. Owner ideas arriving live in
chat get the same banking, his words verbatim. **v19 does NOT open
this session** — even on CUMPLIDO, the next cycle starts with an owner
brainstorm, not this spark. Not arrived → one checkpoint line, move
on.

## Job 7 — close

- Docs-only session: suite green (`bundle exec rake`) is the only owed
  gate; the wall is owed ONLY if a Job-5 tripwire fix touched code
  (then: `harness/run_wall.sh seventeenth-<date>`, backgrounded,
  variance → `0d9433a` retry precedent).
- `docs/CHECKPOINT.md` new top entry: mode declared (FULL/PARTIAL/
  EMPTY), what was banked/decided (verdict + the deciding lines, or
  gaps named), any new chain links, soak-lane findings, v19 slot
  status, quarantine spot (save md5 + digest + sessions + newest temp
  log + count), seat note for Junior only if something is pending on
  his side.
- Commits: explicit paths, one concern each (evidence/ + skeleton ·
  adjudication + AGENTS.md · intake · checkpoint). Hooks run the
  suite; never `--no-verify`. Pull before every push.
- Owner queue last, es-CR (content per Job 4 or, in PARTIAL/EMPTY: qué
  existe, qué falta exactamente, y que el ritmo es de ustedes).

## Laws that bite

- **The oracle surface is FROZEN even now:** TELEMETRY wording,
  `bin/play*`, the run sheet questions, JUNIOR.md, respawn/pacing/
  sustain numbers, `data/**`. Adjudication is reading, not editing.
- **Verbatim means verbatim:** players' answers and telemetry lines
  land byte-exact; your prose lives AROUND them.
- **Never waive, never fudge, never re-litigate:** shortfall sessions
  re-run owner-paced; the two session-4 recorded defects stay as
  ruled; the spec's CLOSED sections stay closed; solo links never
  substitute for ritual sessions.
- **A bot log is never evidence** (AUTOPILOT line = disqualified), a
  soak PASS changes nothing about the oracle, and the skeleton's
  residue-trap laws apply to every artifact you classify.
- **Sibling seats (assets/audio/lore) may be LIVE** — their trees are
  never yours to touch; read-only glances only if the owner asks for
  stack state. Seat conflict or push race → coordinate via drafts/ +
  seat mail, never route around.
- Budget: single session, ~3h attended; no council (protocol settled);
  no sub-agent fan-outs.

## Stop conditions

- FULL path done → adjudication + AGENTS.md + checkpoint + owner queue
  pushed → STOP (next cycle is the owner's brainstorm, not yours).
- PARTIAL/EMPTY → banked + gaps named + checkpoint + queue pushed →
  STOP (cycle stays owner-paced).
- A Job-5 finding too big for the tripwire → bundle + RECORD +
  checkpoint, never rush the fix into an adjudication session.
