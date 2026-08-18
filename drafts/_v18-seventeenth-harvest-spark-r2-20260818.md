# SPARK: v18 session 9 — the SEVENTEENTH: full harvest + adjudication (or honest PARTIAL); v19 intake rides

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST — the v18 scope contract is ground truth. Ruby
per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language
English; owner surfaces es-CR ustedeo; Junior surfaces pt-br;
everyday gamer words everywhere (register law — no legal/notarial
vocabulary).

**What this session is:** the adjudication vehicle for the SEVENTEENTH
ask. If both ritual sessions + all eight answers exist, you harvest,
run the four Half-A checks, record Half B verbatim, walk EVERY routing
row, and decide on the spec's own terms. If evidence is incomplete,
you bank what exists verbatim, name the gaps, and STOP — session 5
(`72e9297`) is the PARTIAL precedent; never fudge, never waive, never
nag the humans to play. This spark supersedes `7224819` as the harvest
vehicle (it folds session-8's soak-era residue laws).

**What this session is NOT:** not a build session (build phase CLOSED,
increments 0–8 + soak shipped), not the ritual itself (a dev session
never plays it), not v19 (nothing new starts until this adjudicates —
the intake slot banks and triages only). **Bots never adjudicate: any
log carrying an `AUTOPILOT seed=` line is bot-driven and DISQUALIFIED
as session evidence, no matter how green it looks** — this is new
since the skeleton was written; apply it to every log you touch.

## Read first, in order

1. `AGENTS.md` — whole file (scope contract, Commands, the soak
   bullet's quarantine law, enforcement).
2. `docs/CHECKPOINT.md` — top THREE entries (session 8: soak shipped,
   cross-machine green, residue laws, v19 slot open; session 7
   interlude; session 5 PARTIAL — the banking format you'll reuse).
3. `drafts/_v18-fun-verify-skeleton-20260818.md` — THE working file:
   ritual restated, telemetry slots, Half A checks PENDING, Half B
   questions, residue traps (tmp/netplay AND the session-8 soak line),
   side-signal HELD, gaps list. You fill THIS file; adjudication
   sections get written only in FULL mode.
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
   (process-alive ≠ session-alive; log bytes lie until quit); `$?`
   after a pipe lies; seats print at CLOSE.
9. `git pull --ff-only` FIRST and before every push.

## Job 0 — evidence inventory (three-mode gate; ~30 min, blocking)

Baseline: the newest legitimate human launcher log on this machine is
2026-08-17 11:15 (`ticks=0` idle host). Session 8's soak wrote ZERO
temp-dir logs (verified at its close), so anything newer is
human-launched — but a human CAN launch `bin/play --join … --bot`, so
classify every candidate:

- Inventory `/tmp/game_two_session_*.log` AND
  `/c/Users/gabri/AppData/Local/Temp/game_two_session_*.log` (same dir
  both ways on this machine — check both patterns anyway), sorted by
  mtime; read EVERY log newer than the baseline in full.
- Classification tree per log: has `AUTOPILOT seed=` → BOT, disqualified
  (note it, move on) · `ticks=0` → idle attempt · `reason=` ≠ quit or
  ticks < 36000 → shortfall (ritual law: that session RE-RUNS,
  owner-paced — bank the log, name the shortfall) · else → candidate
  ritual session (bank verbatim: netplay + every persist + any sustain
  line, with file name + mtime).
- `saves/world.json`: mtime + strict-decode digest through the game's
  own load path (`App::SaveStore#load` — the session-5 snippet).
  Opening expectation if nothing moved it: digest `d63fd8ea…`,
  sessions=2, md5 `a249aec13c9af947c93641a63b2d77ea`. Solo/smoke play
  legitimately moves it — the save is DIAGNOSTIC context for the chain
  walk, never one of the four checks.
- Junior side: `git log` since `766cfa2` for his commits; new
  `drafts/_junior-*` files; owner pastes in this chat. His two ritual
  sessions produce HIS logs — they arrive by paste/drafts/commit only.
- Answers: all eight (4 owner es, 4 Junior pt-br), gathered SEPARATELY,
  after both sessions. Partial answer sets = PARTIAL mode.
- `tmp/netplay/` artifacts: apply the skeleton's residue law (suite
  runs regenerate `platform:"test"` / `dddd…` fingerprints on every
  hook rake; gate runs are logged in `drafts/_gate-verdicts.log`).
  `tmp/soak/**`: bot residue by definition.
- Also inventory NEW `tmp/soak/*/report.txt` since session 8 (the
  owner may have run the overnight command) → feeds Job 5, never the
  oracle.

**Mode decision (write it in the skeleton before anything else):**
- **FULL** = two sessions on DIFFERENT days (both seats' logs, all ≥
  36000 ticks, reason=quit, AUTOPILOT-free) + all eight answers → Jobs
  1–4.
- **PARTIAL** = anything less → bank verbatim (session-5 style:
  provenance + attribution machine-verified), name the exact gaps in
  the skeleton's gap list, then Job 5+. If sessions exist but answers
  are missing: hand the owner the run sheet POINTERS for the asking
  step (the exact file + section; do NOT rewrite or paraphrase the
  questions — wording stays virgin) and stop there.
- **EMPTY** = nothing new → update the skeleton's gate-result section
  with the re-check timestamp, Job 5+.

## Job 1 — FULL only: harvest into the skeleton (~45 min)

Fill every telemetry slot VERBATIM (2 sessions × 2 seats netplay
lines; every persist line host+joiner; solo-between logs into the
chain; sustain lines if any). Every line cites its source file +
mtime. Junior's lines cite paste/commit provenance. Save copies of the
log files into `drafts/_v18-seventeenth-evidence/` (tracked — the
harvest must survive temp-dir cleanup).

## Job 2 — FULL only: Half A, the four checks (~30 min)

Spec verbatim, each PASS/FAIL with the quoted lines beside it:
1. Session 2 host `persist loaded digest` == latest prior `persist
   saved digest` (solo saves included in the chain).
2. Joiner `loaded … source=handshake` digest == host's digest, BOTH
   sessions.
3. `desyncs=0` + `reason=quit` on all four netplay lines; ticks ≥
   36000 each session; all four logs AUTOPILOT-free.
4. Carried fact: session 2's persist line shows accreted state
   matching session 1's close — at least one strictly-positive carried
   fact named (banked/seals/marks/sessions).
Full chronological chain walk (every `loaded` == previous `saved`) as
diagnostic context. A FAILED check = adjudication result, not a bug
hunt — no in-session fixes; the routing table owns what happens next.

## Job 3 — FULL only: Half B verbatim (~20 min)

Record all eight answers in the players' own words and language — no
paraphrase, no scoring, no register cleanup of THEIR words. Any
protocol deviation (wording changed, asked together, changelog shown)
is recorded NAMED beside the answer — adjudicate with the caveat,
never silently. ONLY after both sets are in: the HELD side-signal
(`_junior-specials-chain-retry-20260818.md`) and the `TELEMETRY
sustain` numbers enter the reading.

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
  status line updated (still open, what's owed); triggered rows =
  the named backlog, owner-paced.
- Owner queue (es-CR ustedeo, ~5 lines): el resultado en sus términos,
  qué línea de evidencia lo decidió, qué sigue (o que no sigue nada
  hasta que ustedes quieran).

## Job 5 — soak-report side harvest (hardening lane; ~15 min)

New `tmp/soak/*/report.txt` runs: read reports + any FAIL bundles.
Findings are RECORDED with next-spark shapes. Exception tripwire: a
desync or persistence defect caught by bots BEFORE the ritual is
played = flag in the owner queue as "recomiendo arreglar antes de su
sesión" — fix in-session ONLY if small and mechanical (TDD, own
commit, wall then owed at close); anything bigger is bundled +
recorded. A soak PASS is one checkpoint line, nothing more.

## Job 6 — v19 intake slot (docs-only)

If Junior's ideas list arrived (paste/drafts/commit — it may arrive
BUNDLED with his ritual answers: split them; answers → skeleton
verbatim, ideas → intake): bank verbatim in
`drafts/_junior-v19-ideas-<date>.md` (his words, his language), then
triage Itexo-style (`drafts/_itexo-intake-triage-20260818.md` is the
template): FOLD-NOW (only as evidence input to adjudication — build is
closed) / BANK / PARK with named trigger / ROUTE-SIBLING, reasons
cited. PARKING_LOT entries for parks. **v19 does NOT open this
session** — even on CUMPLIDO, the next cycle starts with an owner
brainstorm, not this spark. Not arrived → one checkpoint line, move on.

## Job 7 — close

- Docs-only session: suite green (`bundle exec rake`) is the only owed
  gate; the wall is owed ONLY if a Job-5 tripwire fix touched code
  (then: `harness/run_wall.sh seventeenth-<date>`, backgrounded,
  variance → `0d9433a` retry precedent).
- `docs/CHECKPOINT.md` new top entry: mode declared (FULL/PARTIAL/
  EMPTY), what was banked/decided (verdict + the deciding lines, or
  gaps named), soak-lane findings, v19 slot status, quarantine spot
  (save md5 + newest temp log), seat note for Junior only if something
  is pending on his side.
- Commits: explicit paths, one concern each (evidence/ + skeleton ·
  adjudication + AGENTS.md · intake · checkpoint). Hooks run the
  suite; never `--no-verify`. Pull before every push.
- Owner queue last, es-CR (content per Job 4 or, in PARTIAL: qué
  existe, qué falta exactamente, y que el ritmo es de ustedes).

## Laws that bite

- **The oracle surface is FROZEN even now:** TELEMETRY wording,
  `bin/play*`, the run sheet questions, JUNIOR.md, respawn/pacing/
  sustain numbers, `data/**`. Adjudication is reading, not editing.
- **Verbatim means verbatim:** players' answers and telemetry lines
  land byte-exact; your prose lives AROUND them. Es/pt human surfaces
  use everyday gamer words (foreclosure-register audit applies to your
  own output).
- **Never waive, never fudge, never re-litigate:** shortfall sessions
  re-run owner-paced; the two session-4 recorded defects stay as
  ruled; the spec's CLOSED sections stay closed.
- **A bot log is never evidence** (AUTOPILOT line = disqualified), a
  soak PASS changes nothing about the oracle, and the skeleton's
  residue-trap laws apply to every artifact you classify.
- Budget: single session, ~3h attended; no council (protocol settled);
  no sub-agent fan-outs; seat conflict or push race → coordinate via
  drafts/ + seat mail, never route around.

## Stop conditions

- FULL path done → adjudication + AGENTS.md + checkpoint + owner queue
  pushed → STOP (next cycle is the owner's brainstorm, not yours).
- PARTIAL/EMPTY → banked + gaps named + checkpoint + queue pushed →
  STOP (cycle stays owner-paced).
- A Job-5 finding too big for the tripwire → bundle + RECORD +
  checkpoint, never rush the fix into an adjudication session.
