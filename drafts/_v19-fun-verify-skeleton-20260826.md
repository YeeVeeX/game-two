# v19 fun-verify — THE EIGHTEENTH, skeleton (staged 2026-08-26 s82; execution OWNER-PACED)

Protocol: `docs/superpowers/specs/2026-08-26-v19-eighteenth-ritual.md`
(CLOSED at staging — this file transcribes nothing, it BANKS).
Runsheet (owner-facing, es): `drafts/_v19-eighteenth-runsheet-20260826.md`.
Evidence dir when execution opens: `drafts/_v19-eighteenth-evidence/`
(md5-banked log copies, v18 pattern).

**Mode: STANDBY** — staged, zero ritual evidence exists. Adjudication
stays EMPTY until a FULL harvest (both sessions, both seats, 10/10
answers).

## Staging-time anchors (2026-08-26, s82 — re-verify at execution open)

- `saves/world.json` md5 `0ed80c516168b41d6314aaf28c7848f7`
  (mtime 2026-08-24 13:47), play-path strict decode: progression
  **level=8 xp=1855** (needs 465 of ΔE(9)=2320 to level; ΔE(10)=2960;
  cap 10). Every pre-ritual ordinary session legitimately moves this
  anchor — each such log joins the chain (v18 supersession law).
- Launcher logs at staging: **39** (both temp patterns). Every log
  after #39 must be classified at harvest (chain link / scratch /
  attempt / ritual).
- Main at staging: `87aefb4` (the spec + freeze commit lands after —
  the skeleton's exposure-build floor is THAT commit, recorded in the
  s82 checkpoint entry).
- Sim-number freeze set + oracle freeze set: spec §12.3–12.4.
  Verify at execution open: `git log --oneline -- data/balance/
  data/zones/ src/game/telemetry.rb src/game/save_state.rb
  src/app/save_store.rb src/app/autopilot.rb src/net/session.rb`
  shows nothing after the staging commit (or each hit carries a
  recorded owner override line).

## Exposure ledger status (spec §3 — REQUIRED before ritual session 1)

| Seat | Ordinary session on build ≥ staging commit? | Evidence |
|---|---|---|
| Gabriel (host) | **PAID 2026-08-26** | coop session, host log #41 (`game_two_session_282671153.log`, md5 `d8acc0acaee6e19c68974888151bbdba`, banked `pre-ritual/`); build `e187266` (> staging floor `cc5f356`); netplay `ticks=80513 desyncs=0 reason=quit`; handshake proves build identity |
| Junior (joiner) | **PAID 2026-08-26** | same coop session — the v17 handshake refuses non-identical builds, so his seat ran `e187266` by construction (`NETPLAY handshake seat=1 d=9` in the host log); his own netplay line LANDED in-repo `6b5b7a5` (joiner console capture, indexed in the chain below) — corroboration; exposure was already proven by the handshake |

Recommended vehicle: coop part 2 (handshake proves both at once; pays
the standing focus-A/B item — its baseline: host 7265 vs joiner 243
stalls).

## Pre-ritual log chain (logs after staging #39, classified at harvest)

- **#40** `game_two_session_2032820641.log` (md5 `f1ffc8cfcd39649323fb8b55e71587ab`,
  banked `pre-ritual/`; launch 2026-08-26 ~14:5x, mtime 15:09) — **CRASH
  ATTEMPT, unclean**: coop, handshake landed, ~25 min of play, then the
  away-vat flow-field crash (fix `e187266`, repro pinned in
  `economy_vat_test`). `loaded digest=43cd395d…` and NO `saved` line —
  world unmoved (save md5 `0ed80c51…` verified before relaunch). AUTOPILOT=0.
- **#41** `game_two_session_282671153.log` (md5 `d8acc0acaee6e19c68974888151bbdba`,
  banked `pre-ritual/`; launch 2026-08-26 ~15:4x, mtime 16:08) — **CLEAN
  ORDINARY LINK + the exposure session**: `loaded digest=43cd395d…
  sessions=15 source=file` → `saved digest=b3c37a09823070dcdb07af116f8117d7
  sessions=16 banked=102 seals=4`; save file md5 now
  `da5a0b2d0e1b97d8890bda5351807fdd` (chain law: loaded==prior saved ✓,
  crash gap classified ✓). `progression level=10 xp=644 kills_xp=4069`
  (LEVEL CAP reached pre-ritual — spec A5's at-cap note applies: state
  reads trivially true, xp-pin named). `sustain bought=0 used=0 refused=2
  reasons{none=2}` (R-A2 telemetry row still B=0/U=0). Link quality:
  stalls 8862/80513 = 11.0% (<14%), `stall_ms_max=9805` (≥2500 — under
  RITUAL rules that value alone licenses an optional pre-question re-run;
  played through and called fun tonight). AUTOPILOT=0.
- **Joiner console capture** (corroboration, not a chain link):
  `game_two_coop_join_seat2_20260826.log` (banked `pre-ritual/` by
  Junior's seat, `6b5b7a5`) — join-coop.cmd console tee (11 lines):
  `TELEMETRY netplay seat=2 ticks=80514 desyncs=0 stalls=1487
  stall_ms_max=9690 reason=quit d=9 link_slow=false run_ms=1477302`.
  Cross-reads clean against host #41 (ticks 80513/80514, both
  desyncs=0, worst stall window 9690 vs 9805 ms — same event from
  both ends). **Digest re-anchor (s87):** the checkpoint-cited md5
  `2d90604c…` verifies against NOTHING in the repo (likely computed
  on his machine's pre-commit byte-state; CRLF/LF and accent
  transforms all tested, none match) — the durable anchor is the git
  blob md5 `ecdf6fc77275e3a76693a25a76374867`
  (`git show HEAD:drafts/_v19-eighteenth-evidence/pre-ritual/game_two_coop_join_seat2_20260826.log | md5sum`);
  content verbatim-matches his quoted line, so the corroboration
  value is intact. **Harvest note (binds ritual s1/s2):** a console
  capture carries NO `persist loaded` line — A2 (joiner
  `source=handshake` digest) reads only from the joiner's REAL
  launcher log (`/tmp/game_two_session_<pid>.log` on his machine);
  at ritual harvest Junior's seat banks the log FILE, and every
  banked md5 is re-verified at the GIT BLOB when it lands in-repo.
- Exposure ledger extension (spec §3): `e187266` (field-vat regrow beside
  the payer — crash fix) is a post-staging player-visible sim fix; its
  exposure was PAID the same evening by session #41 (both seats, 13
  tributes / 15 regrown in the close lines).

## Harvest checklist (fill at execution; BEFORE any question)

- [x] Ritual session 1 declared in chat before launch *(s104, verbatims in the session-1 block below)*
- [x] Pre-launch save decode banked (session-1-open {level, xp} — A5 state needs it; the persist line carries no level) *(s104: level=10 xp=644 @ save `da5a0b2d…`; re-verify at launch)*
- [x] Session 1 host log banked (md5) — netplay + persist + progression lines verbatim; LAUNCH DATE recorded from the ORIGINAL file's ctime (copies lose it) *(s104: #42 `5bc9cb46…`, launch 2026-08-27 14:26:28 -0600)*
- [ ] Session 1 joiner log banked (md5, Junior pastes/commits) *(ASKED s104 — the REAL launcher log FILE, md5 re-verified at the git blob when it lands)*
- [x] Session 1 hosting-console tee banked IF the launch path produced one (corroboration, never required — spec A6) *(s104: none produced — `bin\host-coop.cmd` path, by construction)*
- [x] Link-quality read BEFORE questions: stalls% + stall_ms_max vs spec §11 thresholds (≥14% / ≥2500ms) — re-run window closes at the first question *(s104: 7.4% / 591ms — neither met, session STANDS)*
- [ ] Ritual session 2 declared in chat before launch
- [ ] Session 2 host log banked (md5) — `loaded` == latest prior `saved` in the chain; LAUNCH DATE from original ctime
- [ ] Session 2 joiner log banked (md5)
- [ ] Session 2 hosting-console tee banked IF produced
- [ ] Day-gap read: host-clock LAUNCH dates (original-file ctime + chat declaration timestamps) DIFFERENT, or pre-recorded compression line quoted
- [ ] AUTOPILOT grep = 0 on all four files
- [ ] Chain walk: every loaded == a previous saved, every gap classified
- [ ] THEN: owner 5 answers (es, one-by-one, byte-virgin from spec §9) — VERBATIM below
- [ ] THEN: Junior 5 answers (pt-br, his seat administers) — VERBATIM below
- [ ] Deviations named beside each set (capture-before-debrief status included)
- [ ] HELD material admitted (sustain lines · mid-session observations · forensics)
- [ ] Adjudication in a FRESH session → `drafts/_v19-fun-verify-verdict-<date>.md`

## RITUAL SESSION 1 — DECLARED 2026-08-27, pre-launch banked (s104)

- **Declaration (chat, verbatim, BEFORE launch):** Junior 12:55 p.m.
  2026-08-27: "Mae, ¿le hacemos a la sesión 1 del ritual hoy? Ya
  estamos en otro día de calendario, así que es legal. Vos hospedás
  como siempre y yo me conecto. ¡Pura vida!" · Gabriel 1:06 p.m.:
  "Go…" + confirmed in the hub session ("ok got it") after the dev
  stated s1 is declared for today. Chat timestamps corroborate the
  launch date per spec §4.4.
- **Pre-launch save decode (play-path strict, s104):** save md5
  `da5a0b2d0e1b97d8890bda5351807fdd` (mtime 2026-08-26 16:08) →
  `DECODE OK digest=b3c37a09823070dcdb07af116f8117d7` —
  **session-1-open {level=10, xp=644}** (== log #41 close values;
  chain continuous, no launcher log after #41). At-cap note (spec
  A5): state reads trivially true, xp-pin named. RE-VERIFY at launch:
  if the save md5 moved (ordinary play is legal), re-decode and
  supersede this block's values (v18 supersession law).
- **Insurance copy:** `tmp/world.pre-s104.json` md5 `da5a0b2d…`
  (identical), taken s104 before any launch.
- **Launch protocol executed (s104):** fork check 0 ruby · save md5
  re-verified `da5a0b2d…` UNMOVED at launch (pre-launch decode
  stands, no re-decode owed) · visible Start-Process
  `bin\host-coop.cmd`, NO env extras · both seats at tip `9f0c491`
  (handshake proves build identity).

### HARVEST (s104, capture-before-debrief — banked before any question)

- **Host log #42** `game_two_session_66512654.log`, md5
  `5bc9cb46244b80076bba1a6cf36bf106`, copy banked `session1/`
  (md5 identical). **LAUNCH DATE (host clock, ORIGINAL file ctime,
  recorded at banking): 2026-08-27 14:26:28 -0600** — corroborated by
  the chat declaration timestamps (12:55/1:06 p.m.) and the hub
  session's launch command. AUTOPILOT grep = 0 ✓.
- **Oracle lines, verbatim:**
  - `TELEMETRY persist loaded digest=b3c37a09823070dcdb07af116f8117d7 schema=2 banked=102 provisions=0 seals=4 marks=0 sessions=16 source=file`
  - `TELEMETRY sustain bought=0 used=0 refused=0 reasons{at_cap=0 broke=0 none=0 no_effect=0 seat_race=0}` *(HELD — §8 reading waits for 10/10)*
  - `TELEMETRY progression level=10 xp=3679 kills_xp=3627`
  - `TELEMETRY persist saved digest=c36cea1f9ae1afbc1fc8333ce71f92bc schema=2 banked=488 provisions=0 seals=5 marks=3 sessions=17`
  - `TELEMETRY netplay seat=1 ticks=64834 desyncs=0 stalls=4811 stall_ms_max=591 reason=quit d=9 link_slow=false run_ms=1147818 stall_run_max=37 stall_worst_run=37`
- **Chain (A1-side, this link):** loaded `b3c37a09…` == log #41's
  saved ✓ · clean quit saved `c36cea1f…`, sessions 16→17 (+1, A6) ·
  post-quit save file md5 `716987ce2b1a723e1a4ea161d679e710`,
  play-path decode digest == `c36cea1f…`, **{level=10, xp=3679}
  carried to disk** ✓.
- **A-check partials (s1 side):** A3: ticks 64834 ≥ 36000 ✓ ·
  desyncs=0 ✓ · reason=quit ✓ · AUTOPILOT=0 ✓. A5 flow:
  kills_xp=3627 > 0 ✓ (state at cap: trivially true, xp-pin named;
  xp 644→3679 under the pin). A2 waits on the joiner's REAL launcher
  log FILE (harvest-note law — console captures carry no `loaded`
  line); ASK OUT to Junior's seat via checkpoint + owner chat.
- **Link-quality read vs §11 (BEFORE any question — window honored):**
  stalls 4811/64834 = **7.4%** (<14) · stall_ms_max **591** (<2500) —
  **NEITHER threshold met; the optional re-run is NOT licensed. The
  session STANDS.** (Exposure-night datum 9805 ms did not recur;
  stall_worst_run=37 ticks.)
- **Hosting-console tee:** none — `bin\host-coop.cmd` produces no tee
  by construction (spec A6: corroboration, never required).
- **Session-length note (A6):** host 64834 ticks (~18 sim-min); gross
  imbalance vs the joiner read at s2 harvest when both logs sit in
  the chain.
- **Deviations this session:** none — no sim/data/oracle edits inside
  the window (docs-only commits `709a337`/`9f0c491` landed BEFORE
  launch); no debrief contact between peers as of banking (owner
  reported "done" to the hub only).

## RITUAL SESSION 2 (empty)

## OWNER ANSWER SET (empty — 0/5)

## JUNIOR ANSWER SET (empty — 0/5)

## HELD material (accumulates; admitted only after 10/10)

- 2026-08-27 (owner, hub chat, minutes after ritual s1's clean quit,
  verbatim): "necesitamos más variedad, y mapas así subterraneos y que
  se conecten en ciclos redondos etc, más grandes, y largos, que haya
  algo interesante que farmear, algo que nos motive a ir a esos
  lugares, etc, qué sigue?" (+ reference image: four stacked
  underground floors -1..-4, loop topology — banked LOCAL
  `drafts/_refs/owner-underground-floors-ref-20260827.png` md5
  `3aa93d33…`; v20 input file
  `drafts/_v20-input-owner-underground-20260827.md`. Banked
  uncommented — spontaneous statement, dev neither probed nor
  replied on feel axes.)

- 2026-08-26 (owner, chat, post-exposure-session, verbatim): "listo,
  estuvo divertido, llegamos al final del juego muy rápido y hace falta
  contenido, cómo podemos empezar a avanzar con todo lo que tenemos?"
  (context: same session capped progression at 10 and breached seal 4;
  zone tour visible in the catchup lines.)
- 2026-08-26 (owner, pasted into the worldsmith seat mid-incident,
  verbatim): "aparecimos en un punto en donde no podiamos curarnos ni
  revivir a nadie, en lo que parece el 'depot' antes del dungeon 1."
  (Room is basement_1/2 — stationless by ratified design B2/B3; relayed
  by worldsmith triage mail, RECEIPTed s85.)
- 2026-08-26 session telemetry oddments for adjudication texture (from
  log #41 close lines, HELD): `d1_fired wipes=13`, `tributes=13
  regrown=15 floor_fired=10`, `arc rehomed=4 camp_visits=5`,
  `quay entries=16 kills=106 deaths=13`.

## Deviations (named as they occur)

- 2026-08-26: exposure evening carried a live crash + hotfix cycle
  (#40 crash → `e187266` → #41 clean). The fix touched NO frozen file
  (freeze-watch clean incl. the fix commit; watch list re-run post-push).
  Sim numbers, oracle wording, question sheet: untouched.
