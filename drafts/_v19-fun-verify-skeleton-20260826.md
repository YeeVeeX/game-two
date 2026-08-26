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
| Junior (joiner) | **PAID 2026-08-26** | same coop session — the v17 handshake refuses non-identical builds, so his seat ran `e187266` by construction (`NETPLAY handshake seat=1 d=9` in the host log); his own netplay line may arrive by mail (corroboration, not required for exposure) |

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
- Exposure ledger extension (spec §3): `e187266` (field-vat regrow beside
  the payer — crash fix) is a post-staging player-visible sim fix; its
  exposure was PAID the same evening by session #41 (both seats, 13
  tributes / 15 regrown in the close lines).

## Harvest checklist (fill at execution; BEFORE any question)

- [ ] Ritual session 1 declared in chat before launch
- [ ] Pre-launch save decode banked (session-1-open {level, xp} — A5 state needs it; the persist line carries no level)
- [ ] Session 1 host log banked (md5) — netplay + persist + progression lines verbatim; LAUNCH DATE recorded from the ORIGINAL file's ctime (copies lose it)
- [ ] Session 1 joiner log banked (md5, Junior pastes/commits)
- [ ] Session 1 hosting-console tee banked IF the launch path produced one (corroboration, never required — spec A6)
- [ ] Link-quality read BEFORE questions: stalls% + stall_ms_max vs spec §11 thresholds (≥14% / ≥2500ms) — re-run window closes at the first question
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

## RITUAL SESSION 1 (empty)

## RITUAL SESSION 2 (empty)

## OWNER ANSWER SET (empty — 0/5)

## JUNIOR ANSWER SET (empty — 0/5)

## HELD material (accumulates; admitted only after 10/10)

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
