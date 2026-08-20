# v18 fun-verify — SEVENTEENTH ask, skeleton (2026-08-18, PARTIAL/STANDBY — ritual sessions not yet played)

Protocol: spec `2026-08-17-v18-persistent-world-design.md` §Fun-verify
(CLOSED — pre-registered), transcribed for the owner in
`drafts/_v18-seventeenth-runsheet-20260818.md`. Two real sessions on
DIFFERENT days, two halves (A PERSISTED / B FELT). Evidence harvested
from both seats BEFORE any question. A dev session never runs the live
session; it adjudicates what the seats produce.

**Mode declaration (2026-08-18, session 5 per spark `7224819`):**
**PARTIAL.** The evidence gate (inventory below) found ZERO ritual
evidence on this machine, no Junior-side paste/commit, no answers; the
owner confirmed live: *"nothing on my end for now"*. Timeline makes
this expected — the run sheet only opened at increment-8 close
(`90c75e6`, 2026-08-18 02:09), and the ritual needs two different
days. Everything that exists is banked verbatim below; the gaps are
named; adjudication stays EMPTY until a FULL harvest.

## Ritual (what must happen before this file gets a verdict)

1. `git pull` on BOTH seats before each session (stale seat = named
   handshake refusal). **Both seats should be on `main` now** — see
   the mainline note below; until Junior switches, `junior-tibia` is
   kept identical, so either branch is safe.
2. Owner hosts (`bin\host-coop.cmd`), Junior joins
   (`bin\join-coop.cmd`). Each session ≥ 10 sim-min (ticks ≥ 36000),
   ends by Esc (clean quit is what saves the world).
3. Sessions 1 and 2 on DIFFERENT days. Owner MAY play solo between —
   it advances the world; those logs join the chain.
4. Harvest BEFORE any question: all four `TELEMETRY netplay` lines
   (2 sessions × 2 seats) + EVERY `TELEMETRY persist` line + any
   `TELEMETRY sustain` line. Persist lines live ONLY in the session
   logs: `%TEMP%\game_two_session_*.log` (cmd) /
   `/tmp/game_two_session_*.log` (Git Bash) — one per launch through
   `bin/play`; save the files.
5. Then the questions, each player SEPARATELY, no changelog, wording
   virgin from the run sheet. Answers recorded verbatim here.

**Ritual shortfall law (spark):** a session under 36000 ticks, a
non-quit `reason=`, or a lost log is NOT a routing failure — that
session RE-RUNS, owner-paced. Never waive a check, never fudge a pass.

**Owner amendment (2026-08-18 late, live in chat — dev session 12).**
Owner verbatim (English, in chat): "I would like to integrate the
audio now, and move the testing sessions to tomorrow, not monday or
anything like that, we can do 2 sessions in a single day". Effects,
recorded BEFORE the sessions run:

1. **Ritual step 3 amended:** sessions 1 and 2 MAY share one day
   (tomorrow). Half A is mechanically intact — two separate launches,
   session 2's host `loaded` must still equal the latest prior `saved`
   digest. CAVEAT pre-registered: the felt-half "coming back later"
   spacing weakens at same-day; adjudication reads Half B with that
   named beside it.
2. **The ritual runs on an audio-carrying build** (M5a integration,
   owner override — AGENTS.md scope block). Audio is a pure sink
   (never sim/saves/netplay; lockstep and the digest chain are
   audio-blind by construction) and HOST-ONLY tomorrow (Junior's
   machine has no library — his seat prints `AUDIO off` and plays
   silent). CAVEAT pre-registered: Half B answers carry a
   novelty/asymmetry confound — owner hears new audio mid-ritual,
   Junior does not; adjudication reads both answer sets with that
   named.
3. **Junior Q1 premise variant authorized** (wording-virgin law
   otherwise intact): if both sessions land the same day, "No segundo
   dia" may read "Na segunda sessão" — same substance (returned vs
   new game), temporal premise only. Recorded in the runsheet
   amendment section; any use is noted beside his answer.

**Owner amendment 2 (2026-08-18 ~23:00, live in chat — dev session 13).**
Owner verbatim (es): "yo quiero que él tenga el audio on y los assets
que creamos ya en la versión de él para que lo testee". Effects,
recorded BEFORE the sessions run:

1. **Junior's seat runs the ritual with audio ON (intended).** No
   game-two code change needed — the bridge boots audio on every human
   seat; his silence was only the missing sibling library checkout.
   Setup (docs/JUNIOR.md §"Som no jogo"): clone
   `https://github.com/YeeVeeX/game-two-audio.git` BESIDE his game-two
   folder + `bundle install` (ffi arrives prebuilt, lock pins
   `1.17.4-x64-mingw-ucrt`). Both repos verified PUBLIC — no access
   grant needed. The owner-original renders themselves already travel
   in game-two (`data/audio/files/`, sha-pinned) — his `git pull`
   carries them; the clone adds only the engine (DLL + src, vendor-sha
   law enforced at his boot too).
2. **Pre-registered caveat 2 (novelty/ASYMMETRY) is AMENDED:** intended
   state = both seats sounded — the silent-seat asymmetry dissolves and
   the confound becomes SYMMETRIC novelty (both hear the owner-original
   audio during the ritual; first exposure for Junior, first coop
   exposure for the owner). FALLBACK recorded: if his console prints
   `AUDIO off`/`AUDIO refused` (clone missing, sha mismatch, device
   fail), his seat plays silent, the session STAYS VALID (audio is
   optional by design), and the ORIGINAL asymmetry caveat stands
   unchanged. **Which branch applied is read at harvest from the
   `AUDIO on:/off:/refused:` line in each seat's session log** — never
   assumed.
3. **Origin bootability PROVEN on this machine (2026-08-18 22:58):**
   fresh `git clone --depth 1` of origin/master (`c1123af`, == the
   audio seat's local HEAD) booted the bridge in noDevice mode, cue
   played, teardown clean — verbatim:
   `AUDIO on: device=0 sha=15f03e0219d6 lib=C:/Users/gabri/workspace/game-two/tmp/audio_clone_check`
   + `AUDIO teardown clean (dropped_cues=0)`. What Junior clones is
   what booted. Oracle checks unchanged; audio stays a pure sink;
   `data/**` and TELEMETRY wording untouched by this amendment.

**Owner timing shift (2026-08-18 ~23:05, live in chat — dev session
13).** Owner verbatim (es): "en vez de mañana que sea hoy, él está
esperando (ya corregí el mensaje)" — the ritual runs TONIGHT, not
tomorrow; Junior is waiting live. The same-day pair stands as recorded;
if the two sessions straddle midnight, the spacing caveat still rides
(it reads SPACING between sessions, not the calendar line).

**Owner direction (2026-08-19, live chat — dev session 16, recorded
BEFORE the ritual sessions run).** Owner verbatim (es): "debemos seguir
avanzando, depurando y mejorando lo que tenemos hasta ahora" + "no te
cierres ni te limites, nosotros somos dueños de este proyecto y podemos
dirigirlo como queramos". Effects: the dev-side adjudication freeze on
tuning lanes is lifted BY THE OWNER (M5a-override precedent); his three
audio asks execute early (ambient → his drone render; −6 dB interim;
attack-cue spec drafted — details in `_m5a-verdict-20260818.md`
§post-close). RITUAL CAVEAT ADDENDUM: the re-run now carries the
2026-08-19 retuned audio — this rides the SAME pre-registered audio
novelty caveat (both branches unchanged; Junior's AUDIO line still
decides which). Measurement hygiene stands undisturbed: questions
virgin, bot logs never evidence, verbatim harvest.

## Evidence gate result (2026-08-18 ~02:47–03:05, this machine)

- **Launcher session logs:** newest `game_two_session_*.log` in BOTH
  temp dirs = 2026-08-17 11:15, and every post-SIXTEENTH log is a
  `ticks=0` idle host attempt, e.g. verbatim from
  `/tmp/game_two_session_25414137.log`:
  `TELEMETRY netplay seat=1 ticks=0 desyncs=0 stalls=0 stall_ms_max=0 reason=quit`
  The only ≥36000-tick log on this machine is the SIXTEENTH's
  (`game_two_session_1012229766.log`, ticks=89575 — v17, already
  adjudicated). **Zero SEVENTEENTH launcher logs exist.**
- **Junior side:** no paste, no drafts file, no commit (his latest =
  `0873c31`, the JUNIOR.md ratification).
- **Answers:** none gathered (owner confirmed live).
- ⇒ **PARTIAL mode.**

**Re-check 2026-08-18 17:22–17:33 (session 9, spark r2 — the standing
harvest vehicle, `drafts/_v18-seventeenth-harvest-spark-r2-20260818.md`,
which supersedes `7224819`): EMPTY — nothing new.** Launcher logs still
22/22 in both temp dirs (count == session-8 close), newest still
2026-08-17 11:15 `ticks=0` idle host, zero `AUTOPILOT` lines in any
launcher log (bot-disqualification law applied — nothing to classify).
Save quarantine holds: `saves/world.json` mtime 2026-08-17 17:12, md5
`a249aec13c9af947c93641a63b2d77ea` == session-8 close, play-path strict
decode LOADED `digest=d63fd8ea72551208fc03bf7e4b1b65cd` sessions=2
banked=0 — the chain anchor is untouched. Junior side: no commit past
`766cfa2` (origin/junior/ci tip still 2026-08-16, `junior-tibia`
retired), no new `_junior-*` draft (newest 15:58 = his soak return,
consumed session 8), no paste. Answers 0/8. Residue classified per the
laws below: tmp/netplay desync artifacts 17:10–17:13 = the net-gates
close run (`=== 20260818-171110 captures\netplay_desync_gate_a ===`,
real fingerprint `b39f7a31…` INSIDE the gate window) + the `766cfa2`
pre-push hook rake (commit 17:13:18; three `platform:"test"`
artifacts 17:13:48–58); tmp/soak runs all ≤15:16 = session-8's own
validation (incl. the report-less power-cut burst dir `20260818-135217`)
— no overnight run. Skeleton stays PARTIAL/STANDBY; gaps 1–8 unchanged;
adjudication stays EMPTY.

**Re-check 2026-08-18 20:39–20:43 (session 10, spark r3 — the standing
harvest vehicle, `drafts/_v18-seventeenth-harvest-spark-r3-20260818.md`,
which supersedes r2): EMPTY — nothing new past the solo-link-#1
baseline.** Launcher logs 23/23 in both temp dirs (count == the r3
baseline), newest still `game_two_session_6508.log` 2026-08-18
18:00:31 = solo chain link #1, already banked below; zero `AUTOPILOT`
lines in any launcher log. Save quarantine holds at the post-link
values: `saves/world.json` mtime 18:00:31, md5
`213076c540cc9eed846172748aae2e10`, play-path strict decode LOADED
`digest=602e94bbf7d417d845c73e3702fd4675` sessions=3 banked=20 seals=2
marks=3 boss_1_defeats=1 — the moving anchor sits exactly where link
#1 left it (every save move has its matching banked log; no anomaly).
Junior side: no commit past the 2026-08-16 `origin/junior/ci` tip
(`057fb03`, ancestor of main), no new `_junior-*` draft (newest 15:58
soak return, consumed s8), no paste, no v19 ideas list. **Answers
0/8.** Residue classified per the laws below: the suite trio
`desync_00000064`/`000008a9`/`00000bf7` rewritten 20:38:06–09
(`platform:"test"`, `dddd…`/`cccc…` fingerprints) = the `0aaa986`
spark commit's pre-commit/pre-push hook rake (commit 20:37:34);
`_gate-verdicts.log` unchanged since 17:11; tmp/soak reports all
≤15:16:05 = session-8's own validation — still no overnight run.
Skeleton stays PARTIAL/STANDBY; gaps 1–8 unchanged; adjudication
stays EMPTY.

**Re-check 2026-08-18 21:24–21:33 (session 11, spark r4 — the standing
harvest vehicle, `drafts/_v18-seventeenth-harvest-spark-r4-20260818.md`,
which supersedes r3): EMPTY — third empty gate, nothing new.** Launcher
logs 23/23 in both temp dirs (count == the r4 baseline), newest still
`game_two_session_6508.log` 2026-08-18 18:00:31 = solo chain link #1,
banked below; zero `AUTOPILOT` lines in any launcher log. Save
quarantine holds at the post-link values: `saves/world.json` mtime
18:00:31, md5 `213076c540cc9eed846172748aae2e10`, play-path strict
decode (pinned call shape: `App::SaveStore.new(path:).load(data:
Core::DataStore.new(<data dir>))`) LOADED
`digest=602e94bbf7d417d845c73e3702fd4675` sessions=3 banked=20 seals=2
marks=3 boss_1_defeats=1 — the moving anchor sits exactly where link
#1 left it (every save move has its matching banked log; no anomaly).
Junior side: no commit past the 2026-08-16 `origin/junior/ci` tip
(`057fb03`), no new `_junior-*` draft (newest 15:58 soak return,
consumed s8), no paste, no v19 ideas list. **Answers 0/8.** Residue
classified per the laws below: the suite trio
`desync_00000064`/`000008a9`/`00000bf7` rewritten 21:21:52–21:22:01
(`platform:"test"`, `dddd…` fingerprints verified in-file) = the
`74fb3b8` r4-spark commit's pre-push hook rake (commit 21:21:17);
`_gate-verdicts.log` unchanged since 17:11; tmp/soak reports all
≤15:16:05 = session-8's own validation — still no overnight run.
Skeleton stays PARTIAL/STANDBY; gaps 1–8 unchanged; adjudication
stays EMPTY.

**Re-check 2026-08-18 22:47–22:56 (session 13, spark r5 — the standing
harvest vehicle, `drafts/_v18-seventeenth-harvest-spark-r5-20260819.md`,
which supersedes r4): EMPTY — fourth empty gate, expected by the
calendar (the owner-amended ritual is scheduled for TOMORROW,
2026-08-19; this gate ran nine minutes after the r5 spark commit
`51814f3`, 22:45:51).** Launcher logs 28/28 in both temp-dir patterns
(same dir both ways), newest still `game_two_session_6240.log` 22:36 =
solo chain link #4, banked below; zero `AUTOPILOT` lines in any
launcher log. **Baseline arithmetic slip resolved NAMED:** the r5
spark carried "29 per temp dir" from the session-12 checkpoint — that
tally double-counted `6508` (link #1, already inside session-11's 23)
when it added six session-12 logs; disk truth is 23 + 5 = 28, every
log classified (links #1–#4 + scratch `5949` + 22 pre-session-12
logs), none missing, none unconsumed. Save quarantine holds at the
link-#4 values: `saves/world.json` md5
`30ff315dc36ee183c42eb040c08e6030` mtime 22:36 == log close; play-path
strict decode (pinned call shape) LOADED
`digest=189a80723c87b90f27bc8436533d8cc1` sessions=6 banked=20 seals=2
marks=0 boss_1_defeats=1 provisions=0 notices=[] — the moving anchor
sits exactly where link #4 left it (every save move has its matching
banked log; no anomaly). Junior side: no commit past the 2026-08-16
`origin/junior/ci` tip (`057fb03`), no new `_junior-*` draft (newest
15:58 soak return, consumed s8), no paste, no v19 ideas list.
**Answers 0/8.** Seat mail inbox empty (done/ only) — no audio-seat or
assets-lane receipts. Residue classified per the laws below: the suite
trio `desync_00000064`/`000008a9`/`00000bf7` rewritten 22:46 = the
`51814f3` r5-spark commit's pre-push hook rake; `_gate-verdicts.log`
unchanged since 17:11; tmp/soak reports all ≤15:16:05 — still no
overnight run. Skeleton stays PARTIAL/STANDBY; gaps 1–8 unchanged;
adjudication stays EMPTY. Ritual session 1's host `loaded` expectation
stays `189a8072…`; audio-era log rules (r5 spark) in force for the
harvest: `AUDIO on:/off:/refused:` + drift + teardown lines are NORMAL
context, never oracle lines; Junior's seat prints `AUDIO off: library
not present` by design.

**Re-check 2026-08-19 05:04–05:1x (session 15, spark r7 — the standing
harvest vehicle, `drafts/_v18-seventeenth-harvest-spark-r7-20260819.md`,
which supersedes r6): EMPTY — fifth empty gate, expected (the crashed
session-1 attempt closed 00:06 the same night; the RE-RUN is
owner-paced).** Launcher logs 29/29 in both temp-dir patterns, newest
still `game_two_session_7196.log` 00:06 = the crashed attempt, CONSUMED
(banked + classified s14, block below); zero `AUTOPILOT` lines in any
launcher log; the only coop console remains
`tmp/coop_console_20260818-234037.log` (banked). Save quarantine holds
at the link-#4 values (crash saved nothing): `saves/world.json` md5
`30ff315dc36ee183c42eb040c08e6030` mtime 22:36; play-path strict decode
(pinned call shape) LOADED `digest=189a80723c87b90f27bc8436533d8cc1`
sessions=6 banked=20 seals=2 marks=0 boss_1_defeats=1 provisions=0
notices=[] — the moving anchor sits exactly where link #4 left it;
ritual session 1's host `loaded` expectation stays `189a8072…`. Junior
side: tip = `b155bcb` (his crash receipt, in main), nothing past main
on any remote ref, no new `_junior-*` draft (newest = the s14-consumed
crash/setup/v19 files, 00:10–00:20), no paste; **his seat must pull ≥
`b6c110f` before rejoining.** **Answers 0/8.** Seat mail inbox empty
(done/ only). Residue classified per the laws below:
`_gate-verdicts.log` grew +18 verdict entries 00:47:14→02:29:01 = the
s14 PAID wall (17 in-sweep verdicts — low_quay's in-sweep critic was
killed by the timeout disruption, no verdict written — plus the
standalone low_quay re-gate PASS at 02:29:01, the file's last entry),
correlated with the 18 teed `tmp/wall/*_seventeenth-20260819.log`
(00:47–02:20); the entries out-raced the `6a3e1f3` close commit
(02:31:11) and are committed THIS session as banking, not live-session
evidence. Suite trio `desync_00000064`/`000008a9`/`00000bf7` rewritten
02:31 (`platform:"test"`, `dddd…`/`cccc…` fingerprints verified
in-file) = the `6a3e1f3` close commit's hook rake. tmp/soak: newest
report mtime 15:16:05.122993 = the session-8 report ITSELF (the
"≤ 15:16:05" baseline was written at second precision; fractional
boundary, same file, consumed s8) — no new runs, Job 5 empty. v19
intake: nothing new arrived (file stays at idea 1). Skeleton stays
PARTIAL/STANDBY; session 1 still RE-RUNS owner-paced; adjudication
stays EMPTY.

**Re-check 2026-08-19 08:20–08:24 (session 16, spark r8 — the standing
harvest vehicle, `drafts/_v18-seventeenth-harvest-spark-r8-20260819.md`,
which supersedes r7): EMPTY — sixth empty gate, expected (this gate ran
~7 minutes after the r8 spark commit `86c5748`, 08:17:03; the session-1
RE-RUN is owner-paced and has not happened).** Launcher logs 29/29 in
both temp-dir patterns, newest still `game_two_session_7196.log` 00:06
= the crashed attempt, CONSUMED (banked + classified s14); zero
`AUTOPILOT` lines in any launcher log; the only coop console remains
`tmp/coop_console_20260818-234037.log` (banked). Save quarantine holds
at the link-#4 values: `saves/world.json` md5
`30ff315dc36ee183c42eb040c08e6030` mtime 22:36; play-path strict decode
(pinned call shape) LOADED `digest=189a80723c87b90f27bc8436533d8cc1`
sessions=6 banked=20 seals=2 marks=0 boss_1_defeats=1 provisions=0
notices=[] — the moving anchor sits exactly where link #4 left it;
ritual session 1's host `loaded` expectation stays `189a8072…`. Junior
side: tip = `b155bcb` (in main), `origin/junior/ci` still `057fb03`,
nothing past main on any remote ref, no new `_junior-*` draft (newest =
the s14-consumed 00:10–00:20 files), no paste; **his seat must pull ≥
`b6c110f` before rejoining.** **Answers 0/8.** Seat mail inbox empty
(done/ holds the two consumed mails: assets audio-v1 ingest reply +
audio order-lifted). Residue classified per the laws below: suite trio
`desync_00000064`/`000008a9`/`00000bf7` rewritten 08:17:27–35
(`platform:"test"`, `dddd…`/`cccc…` fingerprints verified in-file) =
the `86c5748` r8-spark commit's hook rake (commit 08:17:03);
`_gate-verdicts.log` unchanged since 02:29:01 (last entry still
`=== 20260819-022901 captures\pilot\quay8_r10_replay_gate_a ===`);
tmp/soak newest report still 15:16:05.122993 = the session-8 report
itself (sub-second compare) — no new runs, Job 5 empty. v19 intake:
nothing arrived (file stays at idea 1). Skeleton stays PARTIAL/STANDBY;
session 1 still RE-RUNS owner-paced; adjudication stays EMPTY.

**Re-check 2026-08-19 13:47–13:53 (session 17, spark r9 — the standing
harvest vehicle, `drafts/_v18-seventeenth-harvest-spark-r9-20260819.md`,
which supersedes r8): EMPTY — seventh empty gate, expected (this gate
ran ~10 minutes after the r9-update-2 commit `dde2039`, 13:43:42; the
session-1 RE-RUN is owner-paced and has not happened).** Launcher logs
29/29 in both temp-dir patterns, newest still
`game_two_session_7196.log` 00:06 = the crashed attempt, CONSUMED
(banked + classified s14); zero `AUTOPILOT` lines in any launcher log;
the only coop console remains `tmp/coop_console_20260818-234037.log`
(banked). Save quarantine holds at the link-#4 values:
`saves/world.json` md5 `30ff315dc36ee183c42eb040c08e6030` mtime 22:36;
play-path strict decode (pinned call shape) LOADED
`digest=189a80723c87b90f27bc8436533d8cc1` sessions=6 banked=20 seals=2
marks=0 boss_1_defeats=1 provisions=0 notices=[] — the moving anchor
sits exactly where link #4 left it; ritual session 1's host `loaded`
expectation stays `189a8072…`. Junior side: `origin/main` == `dde2039`
(this seat's own s16/hub docs commits — nothing from his machine),
`origin/junior/ci` still `057fb03`, tip `b155bcb` in main, no new
`_junior-*` draft (newest = the s16-consumed v19-ideas file), no
paste; **his seat must pull CURRENT main before rejoining** (audio
retune `d91281a` moved tree content — same-commit handshake law).
**Answers 0/8.** Seat mail inbox empty (done/ = 6 — the assets
family-sync receipt has NOT arrived; their held session applies at its
own pace). Residue classified per the laws below: suite trio
`desync_00000064`/`000008a9`/`00000bf7` rewritten 13:44
(`platform:"test"`, `dddd…`/`cccc…` fingerprints verified in-file) =
the `dde2039` r9-update-2 commit's hook rake (commit 13:43:42);
`_gate-verdicts.log` unchanged (last entry still
`=== 20260819-022901 captures\pilot\quay8_r10_replay_gate_a ===`);
tmp/soak newest report still `20260819-120805/report.txt`
(12:37:55.308, consumed s16); soak consoles all `s16*`-tagged and
consumed. v19 intake: nothing arrived (file stays at 2 ideas).
Skeleton stays PARTIAL/STANDBY; session 1 still RE-RUNS owner-paced;
adjudication stays EMPTY. **Per r9: Job 6 (flywheel critique
verification) is the session.**

**Re-check 2026-08-19 16:53–16:56 (session 19, T1 spark — compressed
r9 Job 0 gate): EMPTY — eighth empty gate, expected (ritual
owner-paced; wall `flywheel1-20260819` still sweeping live at gate
time, 13/13 PASS zero failures, script 14/18 in flight).** Launcher
logs 29/29 in both temp-dir patterns, newest still
`game_two_session_7196.log` 00:06 = the crashed attempt, CONSUMED
(banked + classified s14). Save quarantine holds at the link-#4
values: `saves/world.json` md5 `30ff315dc36ee183c42eb040c08e6030`
mtime 2026-08-18 22:36; play-path strict decode (pinned call shape)
LOADED `digest=189a80723c87b90f27bc8436533d8cc1` sessions=6 banked=20
breached=2 (district + district_two — the seals) marks=0
boss_1_defeats=1 provisions=0 notices=[] — the moving anchor sits
exactly where link #4 left it. Junior side: `origin/main` == this
seat's `772c914` (s18 hub docs), `origin/junior/ci` still `057fb03`,
0 commits past main, no new `_junior-*` draft (newest = the
s16-consumed v19-ideas file), no paste; **his seat must pull CURRENT
main before rejoining** (same-commit handshake law). **Answers 0/8.**
Seat mail inbox EMPTY (done/ = 7 — the assets family-sync/repin
receipt `from-game-two-assets-repin-1360b272` arrived and was
consumed s18; no new arrivals). Residue classified:
`_gate-verdicts.log` growing with PASS entries = the LIVE wall sweep
appending (launched s17 detached, expected); tmp/soak newest report
still `20260819-120805` (consumed s16); no new soak consoles. v19
intake: file stays at 4 ideas (ideas 3–4 banked s18, hub-live).
Skeleton stays PARTIAL/STANDBY; session 1 still RE-RUNS owner-paced;
adjudication stays EMPTY. **Per the T1 spark: the LDtk spike
(world-builder T1) is the session.**

**Re-check 2026-08-19 21:10–21:16 (session 20, T2 spark — compressed
r9 Job 0 gate): EMPTY — ninth empty gate, expected (ritual
owner-paced).** Launcher logs 31/31 in both temp-dir patterns, newest
still `game_two_session_7461.log` 2026-08-19 20:44 = chain link #6's
ear-check-2 launch, CONSUMED (banked s19). Save quarantine holds at
the link-#6 values: `saves/world.json` md5
`8e94dcb8237b729eaa17222ae234d44d` mtime 2026-08-19 20:44; play-path
strict decode (pinned call shape) LOADED
`digest=66784a92f268776eeb917efb655449c6` sessions=8 banked=12
provisions=0 breached=2 boss_1_defeats=1 notices=[] — the moving
anchor sits exactly where link #6 left it. Junior side: `main` ==
`origin/main` (`21690b0` s19 T2-spark staging), `origin/junior/ci`
still `057fb03`, 0 commits past main; **his seat must pull CURRENT
main before rejoining** (same-commit handshake law — audio v1.1 +
ambient v2 moved tree content). **Answers 0/8.** Seat mail inbox
EMPTY (done/ = 7, no new arrivals — the expected banking acks
haven't landed yet). Residue classified: `_gate-verdicts.log` tail =
the flywheel1 wall PASS entries (consumed s19); tmp/soak newest
report still `20260819-120805` (consumed s16); no new soak consoles;
untracked `drafts/_refs/` = the s18/s19 banked reference images
(untracked by design). Owner NOT present at session start → the
optional audio-morning lane (asks 5–8) did not open; it stays on his
tomorrow list. Skeleton stays PARTIAL/STANDBY; session 1 still
RE-RUNS owner-paced; adjudication stays EMPTY. **Per the T2 spark:
the production importer + zone schema v2 is the session.**

## Pre-session evidence banked (verbatim, with provenance)

### World-save chain anchor (dev-smoke provenance — NOT ritual evidence)

`saves/world.json` (mtime 2026-08-17 17:12, `saved_at_ms=1787008370764`
= 2026-08-17 17:12:50 CAST), verbatim:

```
{"schema":1,"saved_at_ms":1787008370764,"facts":{"banked":0,"breached":[],"counters":{"boss_1_defeats":0,"sessions":2},"home_zone":"nest","members":[{"hp":80,"inscribed":false,"kit":"striker"},{"hp":160,"inscribed":false,"kit":"blocker"},{"hp":60,"inscribed":false,"kit":"lobber"}],"provisions":0}}
```

`saves/world.json.bak-20260817152904` (the pre-`--fresh` world, backup
law fired 2026-08-17 15:29:04; its own last save 15:28:50 CAST),
verbatim:

```
{"schema":1,"saved_at_ms":1787002130590,"facts":{"banked":0,"breached":[],"counters":{"boss_1_defeats":0,"sessions":2},"home_zone":"nest","members":[{"hp":80,"inscribed":false,"kit":"striker"},{"hp":160,"inscribed":false,"kit":"blocker"},{"hp":60,"inscribed":false,"kit":"lobber"}],"provisions":0}}
```

**Provenance of the live save:** a dev host+join e2e smoke run over
loopback wrote it (fixed-name logs `tmp/e2e_host.log` /
`tmp/e2e_join.log`, both mtime 17:12 — a launch through `bin/play`
would have left a `game_two_session_*.log`, and none exists in that
window). Verbatim persist/netplay lines from those logs:

```
host:   TELEMETRY persist loaded digest=569130683c29e9b977d08b8838d624df schema=1 banked=0 provisions=0 seals=0 marks=0 sessions=1 source=file
joiner: TELEMETRY persist loaded digest=569130683c29e9b977d08b8838d624df schema=1 banked=0 provisions=0 seals=0 marks=0 sessions=1 source=handshake
host:   TELEMETRY persist saved digest=d63fd8ea72551208fc03bf7e4b1b65cd schema=1 banked=0 provisions=0 seals=0 marks=0 sessions=2
host:   TELEMETRY netplay seat=1 ticks=2434 desyncs=0 stalls=0 stall_ms_max=0 reason=quit
joiner: TELEMETRY netplay seat=2 ticks=2431 desyncs=0 stalls=0 stall_ms_max=0 reason=quit
```

2434 ticks ≈ 40 s — smoke, nowhere near the 36000-tick ritual floor.
`sessions` counter = +1 per clean-quit save (`save_store.rb:156`), so
sessions=2 means two clean-quit saves since the 15:29 fresh start —
both dev smoke.

**Anchor, integrity-checked live:** strict-decoding
`saves/world.json` through the game's own load path
(`App::SaveStore#load` + `Game::SaveState.digest`) returns
`digest=d63fd8ea72551208fc03bf7e4b1b65cd` — byte-exact match with the
logged `saved digest`. When ritual session 1 opens, the host's
`persist loaded digest=` should equal the save's digest AT THAT TIME
(`d63fd8ea…` if nothing moves the world first; more solo/smoke play
legitimately moves it — this anchor is DIAGNOSTIC context for the
chain walk, not one of the four checks). Note for the chain reading:
the ritual will open with `sessions=` starting from 2, `banked=0`.

### Solo chain link #1 (2026-08-18 18:00 — owner solo session, HUMAN)

Launched by the dev seat at the owner's live ask ("abre el juego para
mi para jugarlo en solo, en el mundo persistente"), played and Esc-quit
by the owner. Log `/tmp/game_two_session_6508.log` (mtime 2026-08-18
18:00:31, 1791 bytes, NO `AUTOPILOT` line — human; launcher console
empty = clean exit 0), full copy preserved md5-identical
(`cf3e4af052774bd69c4abf203ccc2572`) at
`drafts/_v18-seventeenth-evidence/game_two_session_6508.log`. Chain
lines verbatim:

```
TELEMETRY persist loaded digest=d63fd8ea72551208fc03bf7e4b1b65cd schema=1 banked=0 provisions=0 seals=0 marks=0 sessions=2 source=file
TELEMETRY persist saved digest=602e94bbf7d417d845c73e3702fd4675 schema=1 banked=20 provisions=0 seals=2 marks=3 sessions=3
```

Sustain line (recorded VERBATIM for the post-answers reading only —
enters with the HELD side-signal, never before):

```
TELEMETRY sustain bought=0 used=0 refused=4
```

`loaded` == the anchor above (`d63fd8ea…`) — the first real link in
the chain. Disk verified at harvest (18:05, play-path strict decode):
LOADED `digest=602e94bbf7d417d845c73e3702fd4675`, sessions=3,
banked=20, provisions=0, boss_1_defeats=1; save md5 now
`213076c540cc9eed846172748aae2e10` (mtime 18:00:31 == log close — the
`a249aec…` quarantine value is superseded by LEGITIMATE owner play,
not a breach). **The anchor moves:** ritual session 1's host `persist
loaded digest=` should now equal `602e94bb…` — unless more solo/smoke
play moves it again first (each such log joins the chain the same
way). Diagnostic context, not one of the four checks; NOT a ritual
session (solo, pre-session-1 — it advances the shared world per F4).

### Solo chain links #2a/#2b (2026-08-18 22:03–04 — DOUBLE-LAUNCH INCIDENT, dev fault, recorded NAMED)

Dev session 12 (M5a in-game listen) double-launched `bin/play es
--audio-smoke`: a failed pre-launch `tasklist` was masked by its
pipeline rc (`tasklist | tail` — the $?-after-a-pipe trap, hit live
AGAIN) so the background chain launched anyway (pid 20528, 22:03:34);
the deliberate retry launched pid 15392 (22:03:49). TWO solo instances
ran concurrently on the same save; the owner played one (~1 min, 4
kills, no persisted-fact changes) and closed both cleanly ~22:04:33/39.
Both wrote the save (clean quit law) — the chain FORKED at
`602e94bb…`:

- **#2a `game_two_session_5861.log`** (22:04:33, md5
  `64c2abc93225bccf47dc89f2dca0cb4d`, banked in
  `drafts/_v18-seventeenth-evidence/`) — the owner-PLAYED instance:
  `loaded digest=602e94bbf7d417d845c73e3702fd4675 … sessions=3` →
  `saved digest=38f1bc6233ff4a1a39f5e01f99310c85 … sessions=4`.
  **ORPHANED**: clobbered 6 s later by #2b; `38f1bc62…` was never
  loaded by anyone. `sustain bought=0 used=0 refused=0` (HELD).
- **#2b `game_two_session_5847.log`** (22:04:39, md5
  `cac30d3a25c47f9f558f4a14edf9eb30`, banked same dir) — the idle
  window: `loaded digest=602e94bb… sessions=3` → `saved
  digest=822b2e98814439b6295883f573f09451 … banked=20 provisions=0
  seals=2 marks=3 sessions=4`. **SURVIVOR** — disk verified at
  banking (play-path strict decode): LOADED `822b2e98…` sessions=4
  banked=20 seals=2 marks=3 boss_1_defeats=1; save md5
  `15568e1b266a3342c26ca56525c80b49`.

**Chain law status:** both save moves have matching banked human logs
(no unexplained anomaly); the fork is NAMED here so tomorrow's chain
walk reads two `loaded 602e94bb…` lines as this incident, not as a
breach. **The anchor moves: ritual session 1's host `persist loaded
digest=` should now equal `822b2e98…`** (unless more solo play moves
it again — each such log banks the same way). Fix applied same
session: launches are now single-instance-checked with the pipeline rc
trap avoided (verify by printed output, not `$?`). Both logs carry
`AUDIO on/teardown clean` lines — first audio-carrying chain links
(audio is save-blind: facts changed only by the sessions counter).

### Solo chain links #3/#4 (2026-08-18 22:2x–22:4x — owner M5a verify listens, HUMAN, single-instance)

Owner verify sessions for the owner-originals audio swap (M5a; launches
single-instance-checked, judged by printed output). Real world, real
save; smoke choreography is direct-injection and sim-blind (pure-sink
proof). Logs md5-banked in `drafts/_v18-seventeenth-evidence/`:

- **#3 `game_two_session_6087.log`** (md5
  `f6d6e7c00e67273d0687f28c6c0e1409`): `loaded 822b2e98… sessions=4` →
  `saved digest=c4b8df2bd9cecb0b887578b7ec0e80a1 … banked=20 seals=2
  marks=0 sessions=5` (marks 3→0 = owner play). Chain intact.
- **#4 `game_two_session_6240.log`** (md5
  `493c94901bb49172bdbf3c7e2ae3ff99`): `loaded c4b8df2b… sessions=5` →
  `saved digest=189a80723c87b90f27bc8436533d8cc1 … banked=20 seals=2
  marks=0 sessions=6`. Chain intact; disk md5
  `30ff315dc36ee183c42eb040c08e6030` at banking.

**The anchor moves: ritual session 1's host `persist loaded digest=`
should now equal `189a80723c87b90f27bc8436533d8cc1`** (unless more solo
play moves it — same banking). The ritual build carries owner-original
audio at +12 dB (AGENTS M5a block; the Half-B caveat pre-registered in
the owner-amendment block covers it — asymmetry note superseded by
amendment 2: Junior's seat set up for AUDIO on, receipt `168f28d`).

### Solo chain link #5 (2026-08-19 18:07 — owner ambient EAR-CHECK listen, HUMAN, single-instance)

The owner-pending ambient ear-check (M5a verdict ask 1: drone swap
`msfx_drone_4s` + −6 dB family) executed at the owner's word ("vamos
lo del ambiente … ahora mismo"), T1-session live chat. Launch per
protocol: guard printed the no-tasks INFO line (separate call) ·
detached solo `bin/play es` · judged by the launcher log after Esc.
Log `game_two_session_6739.log` (30th, both temp patterns; md5-banked
copy `78296c20d6c26a2f3729779d82b0e0f4` in
`drafts/_v18-seventeenth-evidence/`):

- `AUDIO on: device=1 sha=15f03e0219d6` (real device, owner listening)
- `loaded digest=189a80723c87b90f27bc8436533d8cc1 … sessions=6` →
  `saved digest=9890bb5ed431b4094106983196381f62 schema=1 banked=20
  provisions=0 seals=2 marks=1 sessions=7` — chain intact off link #4.
- Real play, not idle: wipes=3, quay entries=1, varekka engaged=1,
  inscriptions=1; `AUDIO teardown clean (dropped_cues=0)`; zero
  AUTOPILOT; reason=quit (Esc).
- Disk verified at banking: `saves/world.json` md5
  `8be26601ed5be2444c17f7a0145861f5` (mtime 18:07:32), strict decode
  == saved digest `9890bb5e…` sessions=7 banked=20 boss_1_defeats=1
  notices=[]. (Log `marks=1` = inscribed-member count; the facts
  carry it inside `members[].inscribed` — digest equality is the
  arbiter.)
- **Ear-check verdict (owner verbatim, es-CR chat): "me gusta como
  suena! … el sonido de ambiente ahora suena mucho más agradable y
  los niveles en general se escuchan bien y normalizados" — M5a ask 1
  CLOSED (recorded in `drafts/_m5a-verdict-20260818.md`).** Two
  follow-up observations volunteered FOR LATER (owner: "para después,
  por ahora el juego puede andar así") — recorded in the M5a verdict
  post-close lane (ask 4: longer/varied ambient loop), NOT
  fun-verify evidence (owner-initiated audio lane, never bundled with
  ritual questions; quarantine held — only the allowed audio question
  was asked).

**The anchor moves again: ritual session 1's host `persist loaded
digest=` should now equal `9890bb5ed431b4094106983196381f62`**
(sessions=7). Every earlier expectation block reading `189a8072…`
is superseded by this link — the #1–#4 pattern law ("unless more solo
play moves it") applied.

### Solo chain link #6 (2026-08-19 20:44 — owner cue+rotation EAR-CHECK listen, HUMAN, single-instance)

Same-day verify listen for audio v1.1 (23 attack-take cues `f228df8`)
+ ambient v2 (calm-family rotation `3d20b93`), owner ask "probémoslo
ya". Launch per protocol (guard printed no-tasks; detached solo
`bin/play es`; judged by launcher log after Esc). Log
`game_two_session_7461.log` (31st both patterns; md5-banked copy
`ab7e961fdcf6ee072e1cd6a73a958371`):

- `AUDIO on: device=1 sha=15f03e0219d6`; real combat (wipes=3,
  challenges=13, quay+varekka entered, marks_consumed=2, tribute
  economy moved banked 20→12); `AUDIO teardown clean
  (dropped_cues=0)`; zero AUTOPILOT; reason=quit.
- `loaded digest=9890bb5ed431b4094106983196381f62 … sessions=7` →
  `saved digest=66784a92f268776eeb917efb655449c6 … sessions=8` —
  chain intact off link #5. Disk verified: save md5
  `8e94dcb8237b729eaa17222ae234d44d` (mtime 20:44:17), strict decode
  == saved digest, sessions=8, notices=[].
- **Ear-check verdict (owner verbatim, es-CR): "se oye muy bien!"**
  + four tuning asks volunteered FOR TOMORROW (banked in the M5a
  verdict asks 5–7 + ask 4 amendment — owner: "dejémos la nota y lo
  arreglamos todo mañana con más calma"). Owner-initiated audio lane;
  ritual quarantine held (no routing-row topics touched).

**The anchor moves again: ritual session 1's host `persist loaded
digest=` should now equal `66784a92f268776eeb917efb655449c6`**
(sessions=8) — same supersession law as above.

### Ritual session 1 ATTEMPT (2026-08-18 23:40 → 2026-08-19 00:06 — CRASH on both seats; shortfall, RE-RUNS; world UNMOVED)

Launch per the live-launch protocol (owner ask "procede por favor"):
single-instance guard printed 0 · `git pull --ff-only` clean at
`dfc7697` · detached host `bin/play es --host`, console
`tmp/coop_console_20260818-234037.log`, PID 8692 sole instance. Owner
hosted, Junior joined (his handshake PASSED — receipt `b155bcb`:
"clean AUDIO on + handshake loaded 189a8072").

**Crash ~00:06 on BOTH seats, same line — lockstep-symmetric:**
`NoMethodError undefined method 'hp' for nil` at
`src/game/telemetry.rb:190` (`:banked` margin sampler dereferenced
`@world.possessed` while seat 1 was WAITING FOR BODY — v17 decision 3:
partner held the last living flesh — and a bank fired). Host evidence
banked md5-identical in `drafts/_v18-seventeenth-evidence/`:
`game_two_session_7196.log` (md5 `34cb7e3abd780267901410e9fdb28350`) +
`coop_console_20260818-234037.log` (md5
`aae118089eaf85570604b842b5a12d62`, wrapper line `game exited with
code 1`). Joiner: same trace in HIS tick, then rejoin retries died
`IO::TimeoutError session.rb:143` (host dead — correct refusal); his
logs live on his machine, pointers in `b155bcb`; he correctly shipped
NO fix (routing law).

Host log key lines verbatim (stdout partially lost at crash — stderr
carried the trace; NO netplay line, NO `saved` line):

```
AUDIO on: device=1 sha=15f03e0219d6 lib=C:/Users/gabri/workspace/game-two-audio
TELEMETRY persist loaded digest=189a80723c87b90f27bc8436533d8cc1 schema=1 banked=20 provisions=0 seals=2 marks=0 sessions=6 source=file
hosting on port 43117 (Esc cancels)
```

**Classification (spark tree): unclean attempt — `loaded` without
`saved`, NAMED, world unmoved** (save md5 `30ff315dc36ee183c42eb040c08e6030`
intact post-crash, strict decode re-verified: `189a8072…` sessions=6).
Shortfall law → **session 1 RE-RUNS, owner-paced**; this attempt is
NOT a ritual session and never enters the four checks. Positive
diagnostic context it DOES give: host loaded the anchor exactly, and
the joiner handshake digest-matched on the amendment-2 audio-on build.

**Defect fixed same night (tripwire: small + mechanical, TDD
red-green):** commit `b6c110f` — nil-guard in the `:banked` sampler
(fleshless seat samples hp=0.0), regression test reproduces the exact
live trace; suite 811/17035 green; pushed. **Junior must `git pull`
before the re-run** (same-commit fingerprint law — a stale seat gets a
named handshake refusal). **Wall debt recorded:** the fix touched
`src/game/telemetry.rb` → `harness/run_wall.sh seventeenth-20260819`
owed before session-14 close (runs AFTER the humans' sessions — never
beside a live seat). **PAID same session (02:20–02:3x):** 17/18 PASS
in-sweep; `low_quay_run` gate_rc=1 was a bash-timeout DISRUPTION (the
supervising shell's kill hit the vision critic mid-gate — `Command
failed with status ()`; determinism 11/11 byte-identical + manifest
PASS had already printed) — re-gated standalone: `GATE PASS` by
printed output.

**Both-seats audio state for the re-run:** owner seat `AUDIO on:
device=1 sha=15f03e0219d6` (verbatim above); Junior's seat booted
`AUDIO on` this attempt per his receipt — the caveat branch is still
read from HIS RE-RUN session log at harvest, never assumed.

### tmp/netplay/ — the residue trap, defused for future harvesters

Four `desync_*_tick60.json` artifacts existed at gate time. NONE is
live-session evidence:

- `desync_00000064` / `desync_000008a9` / `desync_00000bf7` (mtimes
  2026-08-18 02:41): **test-suite residue** — manifest
  `platform: "test"`, `fingerprint: "dddd…"`. Proven live: the 02:41
  batch matches the spark commit's pre-commit/pre-push hook rake run
  (`7224819`, 02:41:46), and a pre-push rake run at 02:53 this session
  REWROTE all three with the same session ids. They regenerate on
  EVERY suite run — hooks included.
- `desync_00000047` (mtime 2026-08-17 17:54): **Rule-2 gate residue**
  — real manifest (v2, `x64-mingw-ucrt`, fingerprint `00a797b2…`) but
  it matches the `netplay_desync` GATE run logged
  `=== 20260817-175509 captures\netplay_desync_gate_a ===`
  (`drafts/_gate-verdicts.log:67704`); the script stages
  `diverge_at_tick: 40` and detection lands at the tick-60 digest
  compare — exactly this artifact's `tick: 60`.

**Law for the FULL harvest:** judge sessions by session LOGS only; a
tmp/netplay artifact is candidate live evidence only if it appears
OUTSIDE suite/gate run windows AND carries the real fingerprint.

**Soak residue (added session 8, same law):** `tmp/soak/**` (scratch
saves, `AUTOPILOT`-tagged logs, reports) and any log carrying an
`AUTOPILOT seed=` line are bot artifacts — NEVER session evidence; the
harvest judges human launcher logs (`game_two_session_*.log`) only.

### Side-signal (HELD — enters only after both answer sets are recorded)

`drafts/_junior-specials-chain-retry-20260818.md`: in his first sustain
session Junior "não entendeu o que a provisão era" — pre-registered
context for the routing row "sustain unused (`bought=0`) →
discoverability first". It decides nothing alone; it is read WITH the
answers, after them.

**Owner spontaneous fragments (2026-08-19, live chat, pre-questions —
HELD the same way, verbatim):** beside the crash report: "it crashed
for some reason **but it was fun**"; beside the audio asks (full asks
recorded in `drafts/_m5a-verdict-20260818.md` §post-close): "the
ambient music that is always playing is **too repetitive**", "the main
theme instruments themselves can be 6db lower, **its too high**".
Volunteered, not asked; they enter the reading only WITH the answer
sets (the audio fragments ride the Half-B audio-caveat reading).

### pt-br lane

CLOSED — `0873c31`: Junior ratified the JUNIOR.md persistence/custody
section as written (post-`29edda3` wording). Nothing pending from his
seat except playing the two sessions.

### Mainline promotion (2026-08-18, mid-session owner ask — no file changes)

`main` fast-forwarded to the `junior-tibia` tip (`fff5e18..7224819`,
183 commits, clean ancestor, content byte-identical). CI already
triggers on both branches. Bridge until Junior runs `git switch main`:
every push from this seat updates BOTH refs, so the handshake
fingerprint (same-commit law) is safe on either branch meanwhile.
After his first push to `main`, `junior-tibia` gets deleted.

## Telemetry slots (fill verbatim at harvest — both seats, both sessions)

```
SESSION 1 — date: ______  (host log file: ______)
seat 1 (owner, host):  TELEMETRY netplay <pending>
seat 2 (Junior):       TELEMETRY netplay <pending>
host   persist loaded: <pending>
joiner persist loaded (source=handshake): <pending>
host   persist saved:  <pending>
sustain lines (if any): <pending>

SOLO BETWEEN (if any) — logs: ______
persist lines: <pending>

SESSION 2 — date: ______ (DIFFERENT day; host log file: ______)
seat 1 (owner, host):  TELEMETRY netplay <pending>
seat 2 (Junior):       TELEMETRY netplay <pending>
host   persist loaded: <pending>   <- must equal the latest prior saved digest
joiner persist loaded (source=handshake): <pending>
host   persist saved:  <pending>
sustain lines (if any): <pending>
```

## Half A (PERSISTED) — mechanical arbiter, ALL of (spec verbatim)

1. Digest chain: session 2's `persist loaded digest` == the latest
   prior `persist saved digest` in the host's logs (solo saves
   included) — **PENDING**
2. Joiner's `loaded … source=handshake` digest == the host's digest,
   BOTH sessions — **PENDING**
3. `desyncs=0` + `reason=quit` on all four netplay lines; ticks ≥
   36000 each session — **PENDING**
4. Carried fact: session 2's persist line shows the accreted state
   matching session 1's close — at least one strictly-positive carried
   fact named (banked/seals/marks/sessions) — **PENDING**

Full chronological chain walk (every `loaded` == previous `saved`) =
welcome diagnostic context; the four checks alone decide.

## Half B (FELT) — asked separately, questions virgin, answers UNEDITED

Owner (es, run-sheet verbatim):
1. Al volver hoy, ¿sintieron que retomaban donde habían parado, o que
   era una partida nueva? — **PENDING**
2. ¿Cómo se sintió el respawn de los enemigos esta vez? — **PENDING**
3. ¿Usaste las provisiones? ¿Cómo cambió la cacería? ¿El precio? —
   **PENDING**
4. Veredicto libre. — **PENDING**

Junior (pt-br, run-sheet verbatim):
1. No segundo dia, pareceu que vocês tinham voltado pra onde pararam,
   ou que era uma partida nova? — **PENDING**
2. Em dupla, como sentiu a dificuldade dessa vez? — **PENDING**
3. O terceiro corpo (a IA) — como se comportou? — **PENDING**
4. Veredicto livre. — **PENDING**

Answers land here in the players' own words and language — no
paraphrase, no scoring, no register cleanup of THEIR words. Only after
both sets are recorded do the side-signal and the `TELEMETRY sustain`
numbers enter the reading.

## Routing

The spec's §Fun-verify routing table is CLOSED and is the single
source — deliberately NOT restated here (drift risk). At adjudication
every row gets walked: quoted, TRIGGERED / NOT, exact evidence lines
cited. A triggered row = a RECORDED work item with a recommended
next-spark shape — never an in-session fix.

## Gaps (exactly what PARTIAL is missing)

1. Ritual session 1 (coop, ≥36000 ticks, Esc quit) — not played.
2. Ritual session 2 (different day) — not played.
3. All four `TELEMETRY netplay` lines (2 sessions × 2 seats).
4. All `TELEMETRY persist` lines from the ritual sessions (+ any solo
   between), host logs saved.
5. Junior-side lines (his two netplay lines + his
   `loaded … source=handshake` lines) via paste, drafts file, or
   commit.
6. Any `TELEMETRY sustain` lines from the sessions.
7. Owner's four answers (es) — asked separately, after harvest.
8. Junior's four answers (pt-br) — asked separately, after harvest.

## Adjudication

EMPTY — written only in FULL mode (both sessions + all answers in
hand): Half A checks each PASS/FAIL with quoted lines, Half B recorded
verbatim, every routing row walked, then the decision on the spec's
own terms.
