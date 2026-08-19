# SPARK: v18 session 17 — the SEVENTEENTH: full harvest + adjudication (or honest PARTIAL/EMPTY) + flywheel job 1: critique verification pass + verified renderer fixes

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (rule 8) — RESTRUCTURED 2026-08-19: operating
model (peer model: Gabriel + Junior co-direct with equal creative
standing; each seat's agent = dev of record for ITS session; owner
overrides = law, recorded in one line) + the two permanent red lines
(quality gates · measurement hygiene) + current-cycle lanes; the live
file beats this spark on any drift. Ruby per shell:
`export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language English;
owner surfaces es-CR ustedeo; Junior pt-br; everyday gamer words
(register law — the foreclosure-register audit applies to your own
es/pt output).

**What this session is:** (a) the adjudication vehicle for the
SEVENTEENTH ask, revision r9 — supersedes r8
(`drafts/_v18-seventeenth-harvest-spark-r8-20260819.md`); (b) when
evidence is not FULL, the first flywheel work session: verify the
banked self-eval critique claim-by-claim, then ship ONLY verified
renderer/data fixes, each behind the blocking Rule 2 gate.
**Adjudication evidence outranks everything** — if the ritual runs
live or its evidence lands, the flywheel yields the session.

**What changed since r8 (all session 16, 2026-08-19 ~08:00–13:00 —
checkpoint top entry is the map; it is a DOUBLE entry: EMPTY gate +
owner pivot + post-power-cut continuation):**

- **Sixth EMPTY gate (08:20), expected** — then the owner redirected
  LIVE ("juega en automático… debemos seguir avanzando, depurando y
  mejorando… no te cierres ni te limites"): the tuning/build freeze is
  LIFTED (AGENTS.md records it); measurement hygiene stands untouched.
- **Crash-class audit CLEAN:** `b6c110f`'s site was the only unguarded
  `possessed` deref in the tree; nothing else owed.
- **Soak: 13 episodes PASS across 5 runs** + the zone-coverage lane
  BUILT (bot-gated `--start-zone` via `World#start_in` at world birth
  both seats · `soak/seed_save.rb` seeded scratch saves through the
  real encode/decode (home=nest banked=60 provisions=3) · chain_check
  seed+zone asserts (START_ZONE both seats; combat required outside
  hubs nest/camp) · `SOAK_AUDIO=1` noDevice bot audio). All six zones
  exercised with real combat: district fights=4 wipes=1 used=3 ·
  district_two 2/2 · camp 4/1 used=3 · low_quay 2/2 · slow_door 5/5 ·
  nest 0 (hub-quiet by design). Zero desyncs in ~130 sim-minutes.
  One run POWER-CUT mid-EP4 (named cut, world safe, remainder re-run
  PASSed). Recorded gap: bots never bank (interact rarely lands on a
  station) — future soak iteration, not owed now.
- **Audio retune SHIPPED `d91281a` (owner asks 1+3):** calm ambient =
  his `msfx_drone_4s` render; stem gains 4.0→2.0 (−6.02 dB interim).
  **OWNER EAR-CHECK PENDING** — his next solo listen is the
  listen-verdict AND a solo chain link.
- **Attack-cue spec DRAFTED (ask 2):**
  `drafts/_audio-cue-spec-attacks-20260819.md` — seven renders wait on
  the owner's Reaper session; mapping rows ready verbatim.
- **Video bridge SHIPPED `1917cca`:** env-gated `VIDEO_EVERY` frame
  dump in the replay runner (wall byte-identical — it never sets it) +
  `harness/make_clip.sh` (ffmpeg assembly) + `harness/self_eval.py`
  (structure-vs-asset critique persona, spend rails). Three canonical
  clips cut (world_loop 21 s · varekka_duel 45 s · low_quay_run 144 s)
  under `captures/clips/` (gitignored); dense PNG dirs under
  `tmp/clip_*/video/` (every=2 → 30 fps; frame N ≈ t×30).
- **FIRST CRITIQUE BANKED:**
  `drafts/_self-eval/clip_low_quay_run_20260819-104223_critique.md` —
  readability 5 / juice 4 / fluidity 7 / loop 7; strengths (identity
  layer, hit-flash, death ledger, loop cadence) + 10 ranked issues
  with timestamps + a re-check list keyed to the SAME script.
  **Sampling-artifact law (verified live): the critic saw ~160 of 4306
  frames — kill_pop EXISTS (5-frame flash, `data/display.json`) yet
  was called missing. NO critique claim becomes a work item without
  verification against code + exact frames.**
- **Gamesmith round-5/6 banked** (`34c9939` + `4bebc37`, RECEIPTs
  returned to the owner); **assets audio-v1 exports banked on hash**
  (seven sha256s bit-exact, assets `811031c`; ZERO in-tree change;
  LUFS report-only heads-up recorded in the M5a verdict §Mails —
  game-two never compensates levels in code). Mail inbox EMPTY at
  close (done/ = 3).
- **v19 intake: idea 2 banked** (owner: safe zones vs battle zones —
  Tibia PZ touchstone INCLUDING the combat-lock trap; BANK,
  post-verdict class). Intake file now carries 2 ideas.
- **AGENTS.md RESTRUCTURED (`c972044`) + peer model + CLAUDE.md
  (`099e440`, owner order):** the cycle block is now operating-model +
  current-lanes (v17/M5a history moved to checkpoint + git log);
  Gabriel + Junior are PEERS — both contribute design/code/creative
  with equal standing, neither is the other's worker; `CLAUDE.md` is a
  thin pointer so Junior's Claude sessions load the SAME contract
  (AGENTS.md wins on any disagreement). Soak env vars
  (ZONES/SEED_SAVE/SOAK_AUDIO) + clip/critique commands are now
  documented in AGENTS.md §Commands.

The moving anchor is UNCHANGED since link #4:
`189a80723c87b90f27bc8436533d8cc1` (sessions=6, save md5
`30ff315dc36ee183c42eb040c08e6030`). **Bots never adjudicate: any log
carrying an `AUTOPILOT seed=` line is DISQUALIFIED as session
evidence** — apply to every log you touch. Never fudge, never waive,
never nag the humans to play.

## Read first, in order

1. `AGENTS.md` — whole file (restructured: operating model + peer
   seats + current lanes; CLAUDE.md is Junior's pointer to it).
2. `docs/CHECKPOINT.md` — top TWO entries (s16 double entry; s15).
3. `drafts/_v18-fun-verify-skeleton-20260818.md` — THE working file:
   ritual + owner-amendment blocks (now including the 2026-08-19
   owner-direction addendum: the re-run rides the retuned-audio
   novelty caveat; Junior's AUDIO line still picks the branch), six
   dated EMPTY re-check blocks, solo chain links #1–#4 + fork
   forensics, crash-attempt block, side-signals HELD, gaps list.
4. Spec §Fun-verify:
   `docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md`
   — four Half-A checks + ROUTING TABLE, CLOSED; same-day amendment
   recorded (spacing caveat reads SPACING, never the calendar line).
5. `drafts/_v18-seventeenth-runsheet-20260818.md` — questions (es +
   pt-br) VIRGIN + amendment section. Questions go out from this
   sheet; answers come back verbatim.
6. `drafts/_quality-flywheel-plan-20260819.md` — the program contract
   (lanes, budgets, what-ships-when).
7. `drafts/_self-eval/clip_low_quay_run_20260819-104223_critique.md`
   — the claims under verification (Job 6).
8. `drafts/_m5a-verdict-20260818.md` — audio lanes + §Mails state.
9. Project memory traps (auto-injected): judge sessions ONLY by
   TELEMETRY lines; human logs flush at CLOSE (0-byte mid-play =
   normal); `$?` after a pipe lies; two solo instances fork the chain;
   never edit a script a live run executes; wall runs DETACHED.
10. `git pull --ff-only` FIRST and before every push. After any crash:
    HEAD==origin, tree clean, save strict-decodes BEFORE anything else.

## Job 0 — evidence inventory (three-mode gate; ~30 min, blocking; runs FIRST no matter what)

Baselines at session-16 close (2026-08-19 ~14:0x; s16 commits =
`2786754` · `d91281a` · `fd006f9` · `1917cca` · `34c9939` · `4bebc37`
· `8cff809` · `9e4be7f` · `0af91b9` (r9 + override paragraph) ·
`c972044` (AGENTS restructure) · `099e440` (peer model + CLAUDE.md) ·
the r9-update commit = HEAD; `git log` disambiguates):

- **Launcher logs: 29/29 both patterns**
  (`/tmp/game_two_session_*.log` AND
  `/c/Users/gabri/AppData/Local/Temp/game_two_session_*.log` — same
  dir both ways, check both). Newest = `game_two_session_7196.log`
  (00:06, crashed attempt, CONSUMED s14). Anything newer is
  unconsumed; classify per the tree: `AUTOPILOT seed=` → BOT,
  disqualified · netplay `ticks=0` → idle attempt · `reason=`≠quit or
  ticks<36000 → ritual shortfall (re-runs owner-paced; bank + name) ·
  else → candidate ritual session (bank verbatim: netplay + every
  persist + sustain + AUDIO lines, file + mtime) · solo
  `loaded`+`saved` pair on the REAL save → chain link #N (bank per the
  #1–#4 pattern: verbatim lines, md5 copy into
  `drafts/_v18-seventeenth-evidence/`, anchor update, disk decode ==
  saved digest) · `loaded` without `saved` → unclean attempt, NAMED
  (7196 precedent; a stack trace = defect, crash protocol).
- **Save expectation IF NOTHING MOVED IT:** strict decode LOADS
  `digest=189a80723c87b90f27bc8436533d8cc1`, sessions=6, banked=20,
  seals=2, marks=0, boss_1_defeats=1, provisions=0, notices=[]; file
  md5 `30ff315dc36ee183c42eb040c08e6030` (mtime 2026-08-18 22:36).
  Pinned decode shape: `App::SaveStore.new(path:).load(data:
  Core::DataStore.new(<data dir>))` → `Loaded` record
  (`.digest`/`.facts`/`.notices`), NOT a hash. Every save move needs a
  matching human launcher log; a moved save with NO log = NAMED
  anomaly. NOTE: the owner's pending ambient ear-check listen will
  legitimately move it — bank as solo link #5 AND record his listen
  verbatim in the M5a verdict (ask 1 closes on his "ok").
- **Junior baseline:** tip `b155bcb`; anything past it arrives by
  paste, drafts file, or commit. **His seat must pull CURRENT main
  before joining** (the audio retune moved tree content → stale seat =
  named handshake refusal; plain `git pull` fixes) — the same pull
  hands his Claude the peer contract (CLAUDE.md → AGENTS.md). His
  AUDIO `on:/off:/refused:` line is read VERBATIM at harvest — it
  decides the Half-B caveat branch (on = symmetric novelty;
  off/refused = original asymmetry). Never assume; read the line.
  Peer law: his ideas/commits/creative contributions get the same
  intake standing as the owner's.
- **Residue baselines:** suite desync trio
  (`desync_00000064`/`000008a9`/`00000bf7`, `platform:"test"`,
  `dddd…`/`cccc…`) rewritten by EVERY hook rake — s16 made 12 commits;
  correlate mtimes with `git log` commit times.
  `drafts/_gate-verdicts.log` last entry still
  `=== 20260819-022901 captures\pilot\quay8_r10_replay_gate_a ===`
  (clips are NOT gates); growth = new gate runs to classify (your own
  Job-6 gate runs will append PASS entries — expected, classify them
  to your commits). tmp/soak newest report =
  `tmp/soak/20260819-120805/report.txt`; all five s16 runs consumed
  (`084538` PASS 3/3 · `092912` PASS 6/6 · `103453` smoke 1/1 ·
  `105759` power-cut partial, EP4 named · `120805` PASS 3/3); anything
  newer = new run to read (sub-second compare, `stat -c '%y'`). Soak
  consoles `tmp/soak_console_20260819-s16*.log` = consumed bot
  artifacts.
- **Seat mail:** `~/.pi/agent/mail/game-two/` inbox EMPTY at close
  (done/ = 3). Expected arrivals: audio-seat receipts (clock-anchor
  fix, cue-spec replies) · gamesmith round-7 (keys on our SEVENTEENTH
  state: pending, fired-rows none) · assets (nothing owed).
  Sibling-delivery rules (r8, unchanged): a delivery EXECUTES only if
  ALL of owner-approved + digest-grounded (md5 verified, STOP on
  mismatch) + docs-only banking + zero code/data/oracle touch;
  anything more = RECORD + wait. Seat-lease route: read tool → write
  tool into game-two; md5 is the byte-identity arbiter.
- **Answers:** all eight (4 owner es, 4 Junior pt-br), asked
  SEPARATELY by the owner, after both sessions. Partial answers =
  PARTIAL mode.

**Mode decision (write it in the skeleton first):**
- **FULL** = two ritual coop sessions (same day / straddling midnight
  allowed; both seats' logs, ≥36000 ticks, reason=quit,
  AUTOPILOT-free, two separate launches, session 2 loads session 1's
  close) + all eight answers → Jobs 1–4 own the session.
- **PARTIAL** = anything less but something new → bank verbatim, name
  exact gaps; sessions-without-answers → hand the owner run-sheet
  POINTERS (file + section; wording stays virgin). Job 6 may still run
  after banking IF the humans are done for the day (ask the owner).
- **EMPTY** = nothing new → dated re-check block (seventh; the
  s9/s10/s11/s13/s15/s16 pattern) → Job 6 is the session.

## Live-launch protocol (the ritual may run DURING this session — owner hosts at his ask; unchanged law)

- Single-instance guard FIRST, separate call, judged by printed
  output: `MSYS_NO_PATHCONV=1 tasklist /FI "IMAGENAME eq ruby.exe"`
  must print the no-tasks INFO line; REFUSE otherwise (#2a/#2b).
- Coop host: `git pull --ff-only`, then DETACHED
  `nohup bin/play es --host > tmp/coop_console_<ts>.log 2>&1 &`. Solo
  (including the ambient ear-check listen): same shape without
  `--host`. **NEVER `--fresh`**, never a killable timeout, never write
  into the play path. Remind the owner ONCE per launch: **Junior pulls
  first** (current main).
- Judge by the log AFTER exit (flush-at-close). On each "listo":
  guard again → read the newest log IN FULL → classify per the tree →
  disk == saved digest → bank (md5 copy + skeleton slot) + commit +
  push. Session 1 banks BEFORE session 2 when pacing allows; never
  delay the humans for bookkeeping.
- **Crash protocol (s14 precedent):** stack trace → bank log + console
  md5-identical, classify unclean attempt (world unmoved — verify save
  md5 + strict decode), name the defect. Fix in-session ONLY small +
  mechanical (TDD red-green, own commit, push for Junior; wall owed
  detached). Too big → RECORD + PARTIAL with the defect named.
- **Wall/suite never run beside a live seat.** Wall ~90 min DETACHED
  (nohup + poll; never under a bash-call timeout; judge disrupted
  gates by re-running standalone).
- **Priming quarantine (until all eight answers are in):** never
  discuss with either player: continuity feel, respawn/difficulty,
  sustain/provisions, audio IMPRESSIONS (the ear-check ask "¿cómo se
  oye el ambiente nuevo?" is ALLOWED — owner-initiated audio lane —
  but never bundled with ritual questions), corpus-brief/threads
  content, or anything a routing row reads. You never ask the
  run-sheet questions; the owner asks; you hand POINTERS only.

## Jobs 1–4 — FULL only (unchanged law; r8 wording governs, spec is the arbiter)

Harvest every telemetry slot VERBATIM into the skeleton (2 sessions ×
2 seats netplay; every persist line host+joiner; solo links in mtime
order; sustain lines; Junior's AUDIO line quoted beside each of his
sessions). Evidence logs copied md5-identical into
`drafts/_v18-seventeenth-evidence/`. Half A: the four spec checks,
each PASS/FAIL with quoted lines (session-2 host `loaded` == latest
prior `saved`; joiner handshake digest == host BOTH sessions;
desyncs=0 + reason=quit all four lines + ticks ≥ 36000 +
AUTOPILOT-free; ≥1 strictly-positive carried fact NAMED). Chain walk =
diagnostic context; a FAILED check = an adjudication result, not a bug
hunt. Half B: all eight answers verbatim, protocol deviations NAMED
beside them; BOTH caveats attach mechanically BEFORE reading (same-day
spacing weakens "return later"; the audio branch Junior's OWN log
picked — now covering the RETUNED build per the skeleton addendum).
HELD side-signals + `TELEMETRY sustain` numbers enter ONLY after both
sets. Routing: EVERY row quoted, TRIGGERED/NOT, exact evidence lines;
triggered = RECORDED item + next-spark shape (the corpus brief may be
CITED inside a recorded item's next-spark shape — its only legal use).
Decide on the spec's terms (v17 verdict format). CUMPLIDO both halves
→ v18 CLOSES: AGENTS.md adjudication line; checkpoint carries the
next-brainstorm inputs (v19 pool = 2 ideas · M5a deferred lanes ·
audio asks · corpus brief · flywheel findings). Do NOT open v19. Any
half NOT cumplido → honest verdict + named backlog, owner-paced.
Owner queue es-CR (~5 líneas).

## Job 6 — flywheel: critique verification pass (the session's main work when not FULL; ~2h)

**Law: NO critique claim becomes a work item or a fix without
verification.** Method per claim: (1) read the code that owns the
surface; (2) EYES ON EXACT FRAMES — the dense PNG dirs exist
(`tmp/clip_low_quay_run_20260819-104223/video/v_NNNNNN.png`, every=2 →
30 fps → frame index ≈ t_seconds × 30; use the read tool on specific
frames around each critique timestamp — you can SEE them); cut a
VIDEO_EVERY=1 window with a short script ONLY if 30 fps is ambiguous;
(3) classify: CONFIRMED-DEFECT / EXISTS-SAMPLING-ARTIFACT / PARTIAL
(exists but weak) / UNKNOWN-NEEDS-INSTRUMENT / SIM-CLASS (v19, record
only). Table + verdicts land in
`drafts/_flywheel-verification-20260819.md`.

The 10 claims + priors (verify, never trust the prior): **#1 silent
kills** — kill_pop EXISTS (`src/app/kill_pop.rb`,
`kill_pop_flash_frames=5`); verify visibility at 30 fps; candidate =
data-only frames/size bump. **#2 damage attribution** — inventory what
player-hurt feedback exists (feel layer: hitstop/shake; renderer:
stagger veil); a red hurt-flash is renderer-only IF readable world
state already carries it; enemy wind-up telegraph = SIM-CLASS. **#3
attack visuals** — verify whether basic attacks render anything; an
arc is renderer-only if attack state is readable from the creature.
**#4 knockback** = SIM-CLASS, record. **#5 "+0" popups** — find the
emitter (banner/ledger pops); FIRST verify the +0/-150 economics are
INTENDED (data/balance + toll config): value right → suppression/
threshold is renderer/UI; value wrong → data defect, separate item.
**#6 boss banner pointer** — screen-edge arrow (renderer reads boss
position; camera is presentation state, digest-excluded); M effort,
may record instead of ship. **#7 pursuit AI** = SIM-CLASS, record.
**#8 zone-2 palette** — `data/zones/district*.json` palette step,
data-only. **#9 taxonomy shapes** — renderer, M; likely RECORD for the
asset era (overlaps their leverage list). **#10 toast anchoring** —
find the toast owner; corner-anchor + fade = renderer.

**Ship rules:** max 3–4 fixes this session, smallest-verified-first,
renderer/data ONLY (digest-blind by construction — if a candidate
touches sim state it is SIM-CLASS, record). Each fix: own commit
(explicit paths) + `rake gate SCRIPT=harness/scripts/low_quay_run.json`
(or the surface's canonical script) — BLOCKING per Rule 2. After the
last fix: re-cut the low_quay clip (same script ⇒ comparable) +
eyes-on-frames re-check of each fixed timestamp from the critique's
re-check list; ONE optional self_eval re-run (≤$5) only if the owner
wants the scored comparison now. **Wall sweep
`harness/run_wall.sh flywheel1-<date>` DETACHED at close** (renderer
changes re-judge every visual surface; ~90 min; never under a
bash-call timeout).

## Job 7 — owner-dependent lanes (only if they land; never nag)

- **Owner's 7 attack renders arrive** → v1 conversion precedent (M5a
  verdict Phase 4): sha-verify sources against his handoff manifest ·
  24→16-bit PCM16 mono 48 kHz conversion · `fixtures.json` sha-pinned
  entries · `cues.json` rows VERBATIM from
  `drafts/_audio-cue-spec-attacks-20260819.md` · AudioData.load check
  + suite · gains at the +12 dB family interim · owner ear-check = the
  gate (listen-verdict precedent; bank his verbatim).
- **Owner ambient ear-check** (solo listen): launch per protocol; bank
  the log as chain link #5; record his verbatim in the M5a verdict
  (ask 1 closes on his "ok"; a "still too X" = recorded iteration).
- **Junior returns** → the ritual outranks everything.

## Job 8 — v19 intake slot (docs-only)

New ideas from EITHER peer (paste/drafts/commit; SPLIT bundled
answers→skeleton, ideas→intake): append verbatim to
`drafts/_junior-v19-ideas-20260819.md` (2 ideas banked), Itexo-style
triage (FOLD-NOW only as adjudication evidence / BANK / PARK+trigger /
ROUTE-SIBLING). Equal standing regardless of which peer it came from.
v19 does NOT open. Nothing arrived → one checkpoint line.

## Job 9 — close

- Suite green via commit hooks; wall owed ONLY if Job 6 shipped visual
  changes (detached, AFTER the humans finish).
- `docs/CHECKPOINT.md` new top entry: mode, verification table
  verdicts, fixes shipped (commits + gate receipts) vs RECORDED,
  soak/side-lane receipts, v19 slot, quarantine spot (save md5 +
  digest + sessions + newest temp log + count), Junior pull bar
  (current main), owner-pending list (ear-check · renders · ritual).
- Commits: explicit paths, one concern each; hooks run the suite;
  never `--no-verify`. Pull before every push; push promptly (Junior
  visibility — owner standing ask).
- Owner queue last (es-CR ustedeo, ~5 líneas): qué se verificó, qué se
  corrigió (o qué quedó honesto sin corregir), qué sigue de su lado.

## Laws that bite (r9 edition)

- **Measurement hygiene is ABSOLUTE (it survives the freeze lift):**
  ritual questions virgin (you never ask them) · TELEMETRY oracle
  wording (netplay/persist/sustain) frozen · runsheet + JUNIOR.md
  frozen · bot logs never fun-evidence · respawn/difficulty/sustain
  SIM numbers wait for the verdict (they ARE the measured questions) ·
  priming quarantine on corpus/threads content until all 8 answers in.
- **The flywheel ships renderer/data surfaces ONLY this era**; every
  visual change through the blocking Rule 2 gate; sim changes =
  v19-class, RECORDED. Verify-before-fix (sampling-artifact law).
- **Verbatim means verbatim.** Players' answers + telemetry
  byte-exact; your prose lives around them.
- **Never waive, never fudge, never re-litigate:** shortfalls re-run
  owner-paced; 7196 stays an attempt; CLOSED spec sections stay
  closed; solo links never substitute for ritual sessions; owner
  amendments are RECORDED law.
- **Sibling seats may be LIVE:** mail, never write into their trees;
  read tool for their files, md5 arbiter; deliveries per the r8 rules
  (quoted in Job 0).
- **Single-instance guard before EVERY launch**, separate call, judged
  by printed output. Human logs flush at CLOSE. Never edit a script a
  live run executes. Wall runs DETACHED.
- Budget: single session, ~3h attended; council = 0 (protocol
  settled); Bedrock ≤ $8 (the optional re-critique only, tripwired);
  no sub-agent fan-outs.

## Stop conditions

- FULL done → adjudication + AGENTS.md + checkpoint + owner queue
  pushed → STOP (next cycle opens at the owner's brainstorm carrying
  the recorded inputs — not with this spark).
- PARTIAL/EMPTY → banked + gaps named; Job 6 verification table +
  shipped fixes + wall receipt → checkpoint + queue pushed → STOP
  (owner-paced).
- A finding too big for the session → RECORD with a next-spark shape,
  never rush a fix into an adjudication-capable session.
