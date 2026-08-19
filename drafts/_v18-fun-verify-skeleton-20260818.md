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
