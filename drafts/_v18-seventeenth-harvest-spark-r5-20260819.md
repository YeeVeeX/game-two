# SPARK: v18 session 13 — the SEVENTEENTH: full harvest + adjudication (or honest PARTIAL/EMPTY); audio-era log rules; v19 intake ride

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST — the v18 scope contract is ground truth, and it
now carries TWO owner overrides (M5a audio shipped mid-standby; ritual
amendments). Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`.
Working language English; owner surfaces es-CR ustedeo; Junior surfaces
pt-br; everyday gamer words everywhere (register law — the
foreclosure-register audit applies to your own es/pt output).

**What this session is:** the adjudication vehicle for the SEVENTEENTH
ask, revision r5 — supersedes r4
(`drafts/_v18-seventeenth-harvest-spark-r4-20260818.md`). What changed
since r4 (all of it session 12, 2026-08-18 night — checkpoint top entry
is the map): **M5a audio integration SHIPPED by owner override** (owner
originals only, +12 dB, verdict "acceptable for now" —
`drafts/_m5a-verdict-20260818.md`); **the ritual was owner-amended**:
sessions may share ONE day (tomorrow = 2026-08-19), pre-registered
Half-B caveats (same-day spacing weakens "return later"; audio
novelty/asymmetry — owner hears his sounds, Junior's seat prints
`AUDIO off` and plays silent; Junior Q1 premise variant "Na segunda
sessão" authorized); **four solo chain links banked** (#2a/#2b the
double-launch fork, #3/#4 the M5a verify listens) — the moving anchor
is now `189a80723c87b90f27bc8436533d8cc1` (sessions=6). If both ritual
sessions + all eight answers exist, you harvest, run the four Half-A
checks, record Half B verbatim WITH the pre-registered caveats beside
the answers, walk EVERY routing row, and decide on the spec's own
terms. If evidence is incomplete: bank verbatim, name the gaps, STOP.
Precedents: PARTIAL = session 5 (`72e9297`); EMPTY = sessions 9/10/11;
solo-link banking = the skeleton's links #1–#4. Never fudge, never
waive, never nag the humans to play.

**What this session is NOT:** not a build session (v18 increments 0–8 +
soak + M5a all CLOSED; audio tuning asks go to the recorded lane, never
in-session), not the ritual itself (a dev session never plays it), not
v19 (M5a was the ONE owner-ordered exception; nothing else starts until
this adjudicates). **Bots never adjudicate: any log carrying an
`AUTOPILOT seed=` line is DISQUALIFIED as session evidence** — apply to
every log you touch.

## Read first, in order

1. `AGENTS.md` — whole file (scope block: the two override paragraphs +
   the amended oracle; Commands; enforcement).
2. `docs/CHECKPOINT.md` — top THREE entries (session 12: M5a ship +
   incident + chain state; sessions 11/10: the EMPTY gate pattern).
3. `drafts/_v18-fun-verify-skeleton-20260818.md` — THE working file:
   ritual + owner-amendment block (the caveats you must adjudicate
   with), telemetry slots, Half A checks PENDING, Half B questions,
   residue-trap laws, THREE dated EMPTY re-check blocks, **solo chain
   links #1–#4 + the #2a/#2b fork forensics** (the banking pattern for
   any new link), side-signal HELD, gaps list. You fill THIS file.
4. The spec §Fun-verify:
   `docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md` —
   the four Half-A checks and the ROUTING TABLE are CLOSED there; quote
   rows verbatim. The "different days" phrase is owner-amended
   (2026-08-18, recorded in skeleton + runsheet) — two sessions may
   share a day; every OTHER word stands.
5. `drafts/_v18-seventeenth-runsheet-20260818.md` — question wording
   (es + pt-br) + the amendment section (same-day + Junior Q1 variant).
   Questions go out VIRGIN from this sheet; answers come back verbatim.
6. `drafts/_v17-fun-verify-skeleton-20260816.md` — verdict FORMAT
   precedent. 7. `drafts/_m5a-verdict-20260818.md` — the audio-era
   context + deferred lanes (LUFS, anchor fix, tuning).
8. Project memory traps (auto-injected): judge sessions ONLY by
   TELEMETRY lines; human logs flush at CLOSE (0-byte mid-play =
   normal); `$?` after a pipe lies; **two solo instances fork the chain
   — single-instance guard in a SEPARATE call judged by printed
   output**; never edit a script a live run executes.
9. `git pull --ff-only` FIRST and before every push. After any crash:
   HEAD==origin, tree clean, save strict-decodes BEFORE anything else.

## Job 0 — evidence inventory (three-mode gate; ~30 min, blocking)

Baselines at session-12 close (2026-08-18 ~23:00):

- **Newest legitimate human launcher log:** `game_two_session_6240.log`
  (2026-08-18 22:4x, banked = chain link #4). Count was **29 per temp
  dir** (both patterns: `/tmp/game_two_session_*.log` AND
  `/c/Users/gabri/AppData/Local/Temp/game_two_session_*.log` — same dir
  both ways, check both anyway). Anything newer is unconsumed; anything
  older is classified (skeleton links #1–#4 + `5949` = the scratch-save
  drift run, NOT a chain link).
- **Save expectation IF NOTHING MOVED IT:** strict decode LOADED
  `digest=189a80723c87b90f27bc8436533d8cc1`, sessions=6, banked=20,
  seals=2, marks=0, boss_1_defeats=1; file md5
  `30ff315dc36ee183c42eb040c08e6030`. Decode shape (pinned):
  `App::SaveStore.new(path:).load(data: Core::DataStore.new(<data
  dir>))` — `data:` is a kwarg of `#load`. Owner play legitimately
  moves the save — **every save move needs a matching human launcher
  log; a moved save with NO matching log is a NAMED anomaly.** The
  #2a/#2b fork (two `loaded 602e94bb…` lines) is BANKED history, not an
  anomaly — read the skeleton before judging the chain.
- **Junior baseline:** no commits past `origin/junior/ci` = `057fb03`
  (2026-08-16). His artifacts arrive by paste, drafts file, or commit
  only. His ritual logs live on HIS machine — ask-by-pointer, never
  invent.
- **Residue baseline:** the suite desync trio
  (`desync_00000064`/`000008a9`/`00000bf7`, `platform:"test"`,
  `dddd…`) is rewritten by EVERY hook rake — correlate mtimes with
  `git log` commit times (session-12 commits ran ~21:2x–23:0x) +
  `drafts/_gate-verdicts.log` (tail unchanged since 2026-08-18 17:11
  unless a real gate ran). tmp/soak reports all ≤ 2026-08-18 15:16:05.

**AUDIO-ERA LOG RULES (new since r4):** every launcher log now carries
`AUDIO on:/off:/refused:` + `AUDIO drift …` + `AUDIO teardown clean`
lines — NORMAL, never disqualifying, never oracle lines (the oracle
greps `TELEMETRY netplay/persist/sustain` only). Junior's ritual logs
will read `AUDIO off: library not present …` — EXPECTED, not a defect.
A scratch-save log (`--save tmp/…`, `persist fresh` + sessions=1) is
instrumentation — bank as such, never a chain link.

Classification tree per new log: `AUTOPILOT seed=` → BOT, disqualified
· `TELEMETRY netplay` lines: `ticks=0` → idle attempt · `reason=` ≠
quit or ticks < 36000 → ritual shortfall (that session RE-RUNS,
owner-paced; bank + name it) · else → **candidate ritual session**
(bank verbatim: netplay + every persist + any sustain line + AUDIO
lines as context, with file + mtime) · no netplay, `persist
loaded`+`saved` pair on the REAL save → **solo chain link #N** (bank
per the link-#1–#4 pattern: verbatim lines, md5 copy into
`drafts/_v18-seventeenth-evidence/`, moving-anchor update, disk decode
== saved digest) · `loaded` without `saved` → unclean attempt, NAMED,
world unmoved. **Answers:** all eight (4 owner es, 4 Junior pt-br),
asked separately, after both sessions. Partial answers = PARTIAL mode.

**Seat mail check:** `~/.pi/agent/mail/game-two/` may carry audio-seat
receipts (anchor-fix commit) or assets-lane replies (LUFS exports) —
process as BANKING (verify trails, record in the M5a verdict doc's
deferred lanes, move to done/); never start build work from them
mid-adjudication.

**Mode decision (write it in the skeleton first):**
- **FULL** = two ritual coop sessions (SAME day allowed per the
  amendment; both seats' logs, all ≥ 36000 ticks, reason=quit,
  AUTOPILOT-free, two separate launches with session 2 loading session
  1's close) + all eight answers → Jobs 1–4.
- **PARTIAL** = anything less but something new → bank verbatim, name
  exact gaps; sessions-without-answers → hand the owner run-sheet
  POINTERS (file + section; wording stays virgin) and stop there.
- **EMPTY** = nothing new → dated re-check block in the skeleton (the
  s9/s10/s11 blocks are the pattern), then Job 5+.

## Live-launch protocol (if the owner asks to play DURING this session)

- **Single-instance guard FIRST, separate call, judged by printed
  output** (the #2a/#2b lesson): `tasklist //FI "IMAGENAME eq
  ruby.exe"` → count must print 0 before any launch; REFUSE otherwise.
- Solo: `git pull --ff-only`, then DETACHED:
  `nohup bin/play es > tmp/solo_console_<ts>.log 2>&1 &`. **NEVER
  `--fresh`**, never a killable timeout, never write into the play
  path. Coop at his ask: same shape with `--host`.
- Human logs flush at CLOSE; judge by the log after exit, never
  mid-flight. On his "listo": confirm exit, read the log IN FULL,
  classify, verify disk == saved digest, bank + commit + push.
- **Priming quarantine:** while any Half-B answer is pending, never
  discuss with either player: continuity feel, respawn/difficulty,
  sustain/provisions, audio impressions, or anything a routing row
  reads. You never ask the run-sheet questions; the owner asks — you
  hand pointers.

## Job 1 — FULL only: harvest into the skeleton (~45 min)

Every telemetry slot VERBATIM (2 sessions × 2 seats netplay; every
persist line host+joiner; solo links in mtime order; sustain lines).
Junior's lines cite paste/commit provenance. Every evidence log copied
md5-identical into `drafts/_v18-seventeenth-evidence/`.

## Job 2 — FULL only: Half A, the four checks (~30 min)

Spec verbatim, each PASS/FAIL with quoted lines:
1. Session 2 host `persist loaded digest` == latest prior `persist
   saved digest` (solo links included; session 1 host should have
   loaded `189a8072…` if nothing moved the world first).
2. Joiner `loaded … source=handshake` digest == host's, BOTH sessions.
3. `desyncs=0` + `reason=quit` all four netplay lines; ticks ≥ 36000
   each session; all four logs AUTOPILOT-free.
4. Carried fact: session 2's persist line shows accreted state matching
   session 1's close — ≥1 strictly-positive carried fact NAMED.
Chain walk (every `loaded` == previous `saved`, fork #2a/#2b read as
banked incident) = diagnostic context. A FAILED check = an adjudication
result, not a bug hunt — the routing table owns what happens next.

## Job 3 — FULL only: Half B verbatim (~20 min)

All eight answers in the players' own words and language — no
paraphrase, no scoring, no register cleanup. Protocol deviations
(wording changed, asked together, changelog shown, Q1 variant used)
recorded NAMED beside the answer. **The pre-registered caveats attach
here mechanically:** same-day spacing + audio novelty/asymmetry are
written beside the affected answers BEFORE reading them. ONLY after
both sets are in: the HELD side-signal
(`_junior-specials-chain-retry-20260818.md`) and every `TELEMETRY
sustain` line enter the reading.

## Job 4 — FULL only: routing walk + decision + close-out (~45 min)

- EVERY row of the spec's routing table: quoted, TRIGGERED/NOT, exact
  evidence lines. Triggered row = RECORDED work item + next-spark
  shape — never an in-session fix.
- Decide on the spec's terms: Half A mechanical, Half B felt (with
  caveats named, not waived — a caveat colors the reading, it never
  auto-fails a half). Adjudication section per the v17 format.
- **CUMPLIDO both halves** → v18 CLOSES: AGENTS.md scope block gets the
  adjudication line (v17-close precedent); the waiting v19 pool +
  M5a deferred lanes noted in the checkpoint as the owner's next
  brainstorm inputs. Do NOT open v19.
- **Any half NOT cumplido** → verdict recorded honestly; AGENTS.md
  status line updated; triggered rows = the named backlog, owner-paced.
- Owner queue (es-CR ustedeo, ~5 líneas): el resultado en sus términos,
  qué línea de evidencia lo decidió, qué sigue (o que nada sigue hasta
  que ustedes quieran).

## Job 5 — soak + side lanes (~15 min)

New `tmp/soak/*/report.txt` (> 2026-08-18 15:16:05): read reports +
FAIL bundles; findings RECORDED with next-spark shapes. Tripwire
exception: a desync/persistence defect caught by bots BEFORE the ritual
= "recomiendo arreglar antes de su sesión" in the owner queue; fix
in-session ONLY if small + mechanical (TDD, own commit, wall owed).
Audio-lane receipts (anchor fix, LUFS exports) = banking only.

## Job 6 — v19 intake slot (docs-only)

Junior's ideas list (paste/drafts/commit; may arrive BUNDLED with
answers — SPLIT: answers → skeleton, ideas → intake): bank verbatim in
`drafts/_junior-v19-ideas-<date>.md`, triage Itexo-style
(`drafts/_itexo-intake-triage-20260818.md` template): FOLD-NOW (only as
adjudication evidence) / BANK / PARK+trigger / ROUTE-SIBLING. Owner
ideas live in chat get the same banking. **v19 does NOT open this
session.** Not arrived → one checkpoint line.

## Job 7 — close

- Docs-only: suite green (`bundle exec rake`) is the only owed gate;
  wall owed ONLY if a tripwire fix touched code
  (`harness/run_wall.sh seventeenth-<date>`).
- `docs/CHECKPOINT.md` new top entry: mode, banked/decided (verdict +
  deciding lines, or gaps), new chain links, side-lane receipts, v19
  slot, quarantine spot (save md5 + digest + sessions + newest temp log
  + count), Junior seat note only if something pends on his side.
- Commits: explicit paths, one concern each. Hooks run the suite; never
  `--no-verify`. Pull before every push; push promptly (Junior
  visibility — owner standing ask).
- Owner queue last, es-CR.

## Laws that bite

- **The oracle surface is FROZEN during adjudication:** TELEMETRY
  wording, `bin/play*`, run-sheet questions, JUNIOR.md,
  respawn/pacing/sustain numbers, `data/**` (including `data/audio/**`
  — tuning asks are a recorded lane, post-adjudication). Adjudication
  is reading, not editing.
- **Verbatim means verbatim.** Players' answers + telemetry byte-exact;
  your prose lives around them.
- **Never waive, never fudge, never re-litigate:** shortfalls re-run
  owner-paced; recorded defects stay as ruled; CLOSED spec sections
  stay closed; solo links never substitute for ritual sessions; the
  owner amendments are RECORDED law (same-day valid — do not
  "never-waive" yourself into refusing them; the caveats ride the
  reading instead).
- **A bot log is never evidence; a soak PASS changes nothing; residue
  laws apply to every artifact.**
- Sibling seats (audio/assets/lore) may be LIVE — mail, never write
  into their trees; read-only glances only at owner ask.
- Budget: single session, ~3h attended; council = 0 (protocol settled);
  no sub-agent fan-outs.

## Stop conditions

- FULL done → adjudication + AGENTS.md + checkpoint + owner queue
  pushed → STOP (next cycle opens with the owner's brainstorm, carrying
  the v19 pool + M5a deferred lanes as inputs — not with this spark).
- PARTIAL/EMPTY → banked + gaps named + checkpoint + queue pushed →
  STOP (owner-paced).
- A Job-5 finding too big for the tripwire → bundle + RECORD, never
  rush a fix into an adjudication session.
