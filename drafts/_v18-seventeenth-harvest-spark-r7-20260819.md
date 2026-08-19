# SPARK: v18 session 15 — the SEVENTEENTH: full harvest + adjudication (or honest PARTIAL/EMPTY); session-1 RE-RUN vigilance; crash-fix era rules; v19 intake ride

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST — the v18 scope contract is ground truth (owner
overrides M5a + ritual amendments 1+2 live there). Ruby per shell:
`export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language English;
owner surfaces es-CR ustedeo; Junior surfaces pt-br; everyday gamer
words everywhere (register law — the foreclosure-register audit applies
to your own es/pt output).

**What this session is:** the adjudication vehicle for the SEVENTEENTH
ask, revision r7 — supersedes r6
(`drafts/_v18-seventeenth-harvest-spark-r6-20260819.md`). What changed
since r6 (all of it session 14, 2026-08-18/19 night — checkpoint top
entry is the map):

- **Ritual session 1 ATTEMPT crashed on BOTH seats** (23:40→00:06):
  `NoMethodError nil.hp` at `src/game/telemetry.rb:190` — the `:banked`
  margin sampler dereferenced `possessed` while seat 1 was WAITING FOR
  BODY (v17 decision 3) and a bank fired; lockstep-symmetric, joiner
  died same line (his receipt `b155bcb`). Host log
  `game_two_session_7196.log` + console banked md5-identical in
  `drafts/_v18-seventeenth-evidence/`. **Classified: unclean attempt
  (`loaded` without `saved`), world UNMOVED — session 1 RE-RUNS,
  owner-paced.** The attempt never enters the four checks; it DID prove
  host loaded the anchor exactly and the joiner handshake
  digest-matched on the audio-on build.
- **Fix shipped same night** (tripwire: small + mechanical, TDD
  red-green): `b6c110f` — nil-guard in the sampler, regression test
  reproduces the live trace, suite 811/17035 green, pushed. **Junior
  must be pulled ≥ `b6c110f` before joining — a handshake refusal in
  his log reads against a stale pull FIRST** (he pushed `b155bcb`
  BEFORE the fix landed; plain `git pull` on main fixes it).
- **Wall debt from the fix: PAID — tag `seventeenth-20260819`**: 17/18
  scripts PASS in-sweep; `low_quay_run` gate_rc=1 was a DISRUPTION (the
  s14 bash-call timeout killed the vision critic mid-gate — `Command
  failed with status ()`; determinism + manifest had already passed) —
  re-gated standalone same session: `GATE PASS`. Verdicts in
  `drafts/_gate-verdicts.log`; teed logs
  `tmp/wall/*_seventeenth-20260819.log`. Wall lesson now in project
  memory: the sweep runs ~5 min/script (~90 min full) — launch it
  DETACHED (nohup + poll), never under a bash-call timeout; judge a
  disrupted gate by re-running it, never by its rc.
- **Three owner audio asks RECORDED** (verbatim in
  `drafts/_m5a-verdict-20260818.md` §post-close): smoother ambient ·
  attack/effect cues · main-theme instruments −6 dB. All post-
  adjudication audio-lane work — `data/audio/**` stays FROZEN; tuning
  asks never execute in an adjudication session.
- **v19 intake is OPEN**: `drafts/_junior-v19-ideas-20260819.md` —
  idea 1 (Tibia Ctrl+direction stationary facing, Junior via owner)
  banked + triaged BANK with a next-spark shape. Append new arrivals
  there; **v19 does NOT open until the SEVENTEENTH adjudicates.**
- **Held spontaneous fragments** (skeleton §side-signals): owner's "it
  was fun" (crash report) + "too repetitive"/"too high" (audio asks) —
  pre-questions, HELD, enter only WITH the answer sets.

The moving anchor is UNCHANGED by the crash (crash = no save):
`189a80723c87b90f27bc8436533d8cc1` (sessions=6, save md5
`30ff315dc36ee183c42eb040c08e6030`). If both ritual sessions + all
eight answers exist, you harvest, run the four Half-A checks, record
Half B verbatim WITH the caveats beside the answers, walk EVERY routing
row, and decide on the spec's own terms. If evidence is incomplete:
bank verbatim, name the gaps, STOP. Precedents: PARTIAL = sessions 5 +
14; EMPTY = sessions 9/10/11/13; unclean-attempt classification = log
`7196` (s14); solo-link banking = skeleton links #1–#4. Never fudge,
never waive, never nag the humans to play.

**What this session is NOT:** not a build session (v18 increments +
soak + M5a CLOSED; the audio asks and the Ctrl-facing idea are RECORDED
lanes — never in-session), not the ritual itself (a dev session never
plays it — but it MAY launch the owner's seat at his ask, protocol
below), not v19. **Bots never adjudicate: any log carrying an
`AUTOPILOT seed=` line is DISQUALIFIED as session evidence** — apply to
every log you touch.

## Read first, in order

1. `AGENTS.md` — whole file.
2. `docs/CHECKPOINT.md` — top THREE entries (s14: crash + fix + wall +
   intake; s13: EMPTY gate + amendment 2 + timing shift; s12: M5a ship
   + incident + chain state).
3. `drafts/_v18-fun-verify-skeleton-20260818.md` — THE working file:
   ritual + BOTH owner-amendment blocks (amendment 2 carries the
   which-caveat-applies rule), telemetry slots, Half A checks PENDING,
   Half B questions, residue-trap laws, FOUR dated EMPTY re-check
   blocks, solo chain links #1–#4 + the #2a/#2b fork forensics, **the
   session-1 crash-attempt block (s14)**, side-signals HELD, gaps
   list. You fill THIS file.
4. The spec §Fun-verify:
   `docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md` —
   the four Half-A checks and the ROUTING TABLE are CLOSED there; quote
   rows verbatim. "Different days" is owner-amended (same-day pair /
   straddling midnight valid; spacing caveat reads SPACING between
   sessions, never the calendar line); every OTHER word stands.
5. `drafts/_v18-seventeenth-runsheet-20260818.md` — question wording
   (es + pt-br) + amendment section (same-day + Junior Q1 variant +
   both-seats sound). Questions go out VIRGIN from this sheet; answers
   come back verbatim.
6. `drafts/_v17-fun-verify-skeleton-20260816.md` — verdict FORMAT
   precedent.
7. `drafts/_m5a-verdict-20260818.md` — audio-era context + deferred
   lanes + the three post-close owner asks.
8. Project memory traps (auto-injected): judge sessions ONLY by
   TELEMETRY lines; human logs flush at CLOSE (0-byte mid-play =
   normal); `$?` after a pipe lies; two solo instances fork the chain —
   single-instance guard in a SEPARATE call judged by printed output;
   never edit a script a live run executes; wall runs detached.
9. `git pull --ff-only` FIRST and before every push. After any crash:
   HEAD==origin, tree clean, save strict-decodes BEFORE anything else.

## Job 0 — evidence inventory (three-mode gate; ~30 min, blocking)

Baselines at session-14 close (2026-08-19 ~01:5x, commits `b6c110f` fix
· `8541980` docs · wall/checkpoint/spark commits after — `git log`
disambiguates):

- **Newest launcher log:** `game_two_session_7196.log` (2026-08-19
  00:06) = the CRASHED session-1 attempt — CONSUMED (banked +
  classified s14; never a chain link, never a ritual session). Count
  was **29 per temp dir** (both patterns:
  `/tmp/game_two_session_*.log` AND
  `/c/Users/gabri/AppData/Local/Temp/game_two_session_*.log` — same
  dir both ways, check both anyway). Anything newer is unconsumed;
  everything older is classified (skeleton links #1–#4 + scratch
  `5949` + attempt `7196` + 23 pre-s12 logs).
- **Save expectation IF NOTHING MOVED IT:** strict decode LOADS
  `digest=189a80723c87b90f27bc8436533d8cc1`, sessions=6, banked=20,
  seals=2, marks=0, boss_1_defeats=1; file md5
  `30ff315dc36ee183c42eb040c08e6030` (mtime 2026-08-18 22:36). Decode
  shape (pinned): `App::SaveStore.new(path:).load(data:
  Core::DataStore.new(<data dir>))` — `data:` is a kwarg of `#load`;
  the return is a `Loaded` record (`.digest`/`.facts`/`.notices`), NOT
  a hash. Owner play legitimately moves the save — **every save move
  needs a matching human launcher log; a moved save with NO matching
  log is a NAMED anomaly.** The #2a/#2b fork = banked history; the
  7196 attempt = loaded-no-saved precedent.
- **Junior baseline:** his tip = `b155bcb` (crash receipt) — anything
  past it arrives by paste, drafts file, or commit. His ritual logs
  live on HIS machine — ask-by-pointer, never invent. **His seat must
  be ≥ `b6c110f` to join** (stale = named handshake refusal — read
  refusals against that FIRST). His audio: setup receipt `168f28d` +
  crash-attempt boot proved `AUDIO on` capable — but the caveat branch
  is read from his RE-RUN session log VERBATIM at harvest, never
  assumed.
- **Residue baseline:** suite desync trio
  (`desync_00000064`/`000008a9`/`00000bf7`, `platform:"test"`,
  `dddd…`) is rewritten by EVERY hook rake — correlate mtimes with
  `git log` commit times. `drafts/_gate-verdicts.log` grew by the
  s14 wall run (18 verdicts tagged in `tmp/wall/
  *_seventeenth-20260819.log`) — entries in that window are the paid
  wall, not live-session evidence. tmp/soak reports all ≤ 2026-08-18
  15:16:05.

**BOTH-SEATS AUDIO LOG RULES:** every launcher log carries `AUDIO
on:/off:/refused:` + `AUDIO drift …` + `AUDIO teardown clean` lines —
NORMAL, never disqualifying, never oracle lines (the oracle greps
`TELEMETRY netplay/persist/sustain` only). Owner's seat expects `AUDIO
on: device=1 sha=15f03e0219d6
lib=C:/Users/gabri/workspace/game-two-audio`. **Junior's seat: `AUDIO
on:` (intended) OR `off:/refused:` (fallback — still a VALID session,
audio optional by design). Record his line VERBATIM beside his session
entries: it mechanically decides the Half-B caveat — `on` = symmetric
novelty, `off/refused` = the original silent-seat asymmetry. Never
assume; read the line.** A scratch-save log (`--save tmp/…`, `persist
fresh` + sessions=1) is instrumentation — bank as such, never a chain
link.

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
world unmoved (precedent: 7196; a stack trace in the log = also a
DEFECT to route per the crash protocol below). **Answers:** all eight
(4 owner es, 4 Junior pt-br), asked separately, after both sessions.
Partial answers = PARTIAL mode.

**Seat mail check:** `~/.pi/agent/mail/game-two/` may carry audio-seat
receipts (anchor-fix commit, cue-spec replies) or assets-lane replies
(LUFS exports) — process as BANKING (verify trails, record in the M5a
verdict doc's lanes, move to done/); never start build work from them
mid-adjudication.

**Mode decision (write it in the skeleton first):**
- **FULL** = two ritual coop sessions (same day / straddling midnight
  allowed; both seats' logs, all ≥ 36000 ticks, reason=quit,
  AUTOPILOT-free, two separate launches with session 2 loading
  session 1's close) + all eight answers → Jobs 1–4.
- **PARTIAL** = anything less but something new → bank verbatim, name
  exact gaps; sessions-without-answers → hand the owner run-sheet
  POINTERS (file + section; wording stays virgin) and stop there.
- **EMPTY** = nothing new → dated re-check block in the skeleton
  (s9/s10/s11/s13 blocks are the pattern), then Job 5+.

## Live-launch protocol (the ritual may run DURING this session — the owner hosts from this machine at his ask)

- **Single-instance guard FIRST, separate call, judged by printed
  output** (the #2a/#2b lesson): `tasklist //FI "IMAGENAME eq
  ruby.exe"` → must print the no-tasks INFO line before any launch;
  REFUSE otherwise.
- Coop host at his ask: `git pull --ff-only`, then DETACHED:
  `nohup bin/play es --host > tmp/coop_console_<ts>.log 2>&1 &`.
  Solo between sessions at his ask: same shape without `--host`.
  **NEVER `--fresh`**, never a killable timeout, never write into the
  play path. Junior joins from HIS machine (`bin\join-coop.cmd`) —
  nothing to launch here. **Remind the owner ONCE per launch: Junior
  pulls first** (≥ `b6c110f`).
- Human logs flush at CLOSE; judge by the log after exit, never
  mid-flight (0 bytes mid-play = normal). On each "listo": confirm
  exit (guard again — must print the INFO line), read the newest log
  IN FULL, classify per the tree, verify disk == saved digest, bank
  (md5 copy + skeleton slot) + commit + push — session 1 banks BEFORE
  session 2 launches when the humans' pacing allows; never delay them
  for bookkeeping.
- **Crash protocol (s14 precedent):** if a launch dies with a stack
  trace: bank log + console md5-identical, classify unclean attempt
  (world unmoved — verify by save md5 + strict decode), name the
  defect. Fix in-session ONLY if small + mechanical (TDD red-green,
  own commit, push so Junior can pull; wall owed at close — DETACHED).
  Too big → RECORD + verdict PARTIAL with the defect named; never rush.
- **Wall/suite never run beside a live seat.** The wall takes ~90 min
  detached — schedule it after the humans finish.
- **Priming quarantine (in force until all eight answers are in):**
  never discuss with either player: continuity feel, respawn/
  difficulty, sustain/provisions, audio impressions, or anything a
  routing row reads. You never ask the run-sheet questions; the owner
  asks — you hand POINTERS (file + section) only.

## Job 1 — FULL only: harvest into the skeleton (~45 min)

Every telemetry slot VERBATIM (2 sessions × 2 seats netplay; every
persist line host+joiner; solo links in mtime order; sustain lines).
Junior's lines cite paste/commit provenance; his AUDIO line quoted
beside each of his sessions (the caveat-branch rule). Every evidence
log copied md5-identical into `drafts/_v18-seventeenth-evidence/`.

## Job 2 — FULL only: Half A, the four checks (~30 min)

Spec verbatim, each PASS/FAIL with quoted lines:
1. Session 2 host `persist loaded digest` == latest prior `persist
   saved digest` (solo links included; session 1 host should load
   `189a8072…` if nothing moved the world first).
2. Joiner `loaded … source=handshake` digest == host's, BOTH sessions.
3. `desyncs=0` + `reason=quit` all four netplay lines; ticks ≥ 36000
   each session; all four logs AUTOPILOT-free.
4. Carried fact: session 2's persist line shows accreted state
   matching session 1's close — ≥1 strictly-positive carried fact
   NAMED.
Chain walk (every `loaded` == previous `saved`; fork #2a/#2b and
attempt 7196 read as banked incidents) = diagnostic context. A FAILED
check = an adjudication result, not a bug hunt — the routing table owns
what happens next.

## Job 3 — FULL only: Half B verbatim (~20 min)

All eight answers in the players' own words and language — no
paraphrase, no scoring, no register cleanup. Protocol deviations
(wording changed, asked together, changelog shown, Q1 variant used)
recorded NAMED beside the answer. **The caveats attach mechanically,
BEFORE reading the answers:** (a) same-day/short spacing weakens
"return later" — write it beside both Q1s; (b) the audio caveat in the
branch Junior's OWN LOG picked. ONLY after both sets are in: the HELD
side-signals (`_junior-specials-chain-retry-20260818.md` + the owner
fragments: "it was fun", "too repetitive", "too high") and every
`TELEMETRY sustain` line enter the reading.

## Job 4 — FULL only: routing walk + decision + close-out (~45 min)

- EVERY row of the spec's routing table: quoted, TRIGGERED/NOT, exact
  evidence lines. Triggered row = RECORDED work item + next-spark
  shape — never an in-session fix.
- Decide on the spec's terms: Half A mechanical, Half B felt (caveats
  named, not waived — a caveat colors the reading, never auto-fails a
  half). Adjudication section per the v17 format.
- **CUMPLIDO both halves** → v18 CLOSES: AGENTS.md scope block gets the
  adjudication line (v17-close precedent); checkpoint notes the
  owner's next-brainstorm inputs: the v19 pool
  (`drafts/_junior-v19-ideas-20260819.md` + owner ideas live in chat)
  + M5a deferred lanes + the three audio asks. Do NOT open v19.
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
in-session ONLY if small + mechanical (TDD, own commit, wall owed
detached). Audio-lane receipts = banking only.

## Job 6 — v19 intake slot (docs-only)

New ideas (paste/drafts/commit; may arrive BUNDLED with answers —
SPLIT: answers → skeleton, ideas → intake): append verbatim to
`drafts/_junior-v19-ideas-20260819.md`, triage Itexo-style
(`drafts/_itexo-intake-triage-20260818.md` template): FOLD-NOW (only as
adjudication evidence) / BANK / PARK+trigger / ROUTE-SIBLING. Owner
ideas live in chat get the same banking. **v19 does NOT open this
session.** Nothing arrived → one checkpoint line.

## Job 7 — close

- Docs-only: suite green (`bundle exec rake`) via commit hooks is the
  only owed gate; wall owed ONLY if a tripwire fix touched code
  (`harness/run_wall.sh seventeenth2-<date>`, DETACHED, after the
  humans finish).
- `docs/CHECKPOINT.md` new top entry: mode, banked/decided (verdict +
  deciding lines, or gaps), new chain links, Junior's AUDIO line
  branch, side-lane receipts, v19 slot, quarantine spot (save md5 +
  digest + sessions + newest temp log + count), Junior seat note only
  if something pends on his side.
- Commits: explicit paths, one concern each. Hooks run the suite; never
  `--no-verify`. Pull before every push; push promptly (Junior
  visibility — owner standing ask).
- Owner queue last, es-CR.

## Laws that bite

- **The oracle surface is FROZEN during adjudication:** TELEMETRY
  wording, `bin/play*`, run-sheet questions, JUNIOR.md,
  respawn/pacing/sustain numbers, `data/**` (including `data/audio/**`
  — the three recorded audio asks WAIT). Adjudication is reading, not
  editing. The s14 crash fix is the tripwire exception SHAPE (defect
  blocking the ritual, TDD, own commit) — not a license to edit.
- **Verbatim means verbatim.** Players' answers + telemetry byte-exact;
  your prose lives around them.
- **Never waive, never fudge, never re-litigate:** shortfalls re-run
  owner-paced; the 7196 attempt stays an attempt (never retroactively
  counted); recorded defects stay as ruled; CLOSED spec sections stay
  closed; solo links never substitute for ritual sessions; the owner
  amendments are RECORDED law (same-day/straddle-midnight valid — do
  not "never-waive" yourself into refusing them; the caveats ride the
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
  the v19 pool + M5a lanes + audio asks as inputs — not with this
  spark).
- PARTIAL/EMPTY → banked + gaps named + checkpoint + queue pushed →
  STOP (owner-paced).
- A finding too big for the tripwire → bundle + RECORD, never rush a
  fix into an adjudication session.
