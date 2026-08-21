# VERDICT (2026-08-20): THE SEVENTEENTH IS CUMPLIDO — v18 CLOSES

Adjudication of the v18 fun-verify (the SEVENTEENTH ask) on the spec's
CLOSED terms: `docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md`
§Fun-verify — the four Half-A checks + the pre-registered routing
table, nothing else. Vehicle: harvest spark r9
(`drafts/_v18-seventeenth-harvest-spark-r9-20260819.md` §Jobs 1–4).
Working file: `drafts/_v18-fun-verify-skeleton-20260818.md`. Mode at
open: **FULL** (both ritual sessions banked both seats, answers 8/8
verbatim). Format follows the v17 precedent
(`drafts/_v17-fun-verify-skeleton-20260816.md` §VERDICT).

**Decision, in one line: Half A CUMPLIDA (4/4 checks PASS from banked
bytes) · Half B CUMPLIDA (8/8 answers, virgin wording, both seats
independently answered "the world continued") · four routing rows
TRIGGERED, all of them pre-registered RECORDED outcomes, none a
save-integrity or thesis failure ⇒ v18 (persistent world, etapa 1)
CLOSES.** What this unlocks: the frozen SIM numbers (respawn /
difficulty / sustain) are measurable again, and the post-verdict queue
below becomes eligible — priority is the owners' at the v19
brainstorm. What it does NOT mean: the game is problem-free — the lag
is blocker-class by the owner's own severity call and sits FIRST in
the queue.

This session was docs-only by law: no code, no data, no sim numbers,
no gates. The verdict unlocks the frozen numbers; it never touched
them.

---

## Job 0 — standing gate re-verified at adjudication open (2026-08-20, quarantine INTACT)

Every session-20-close baseline re-measured before reading anything:

| Baseline | Session-20 close | Measured now | State |
|---|---|---|---|
| Launcher logs (both temp patterns) | 34 / 34, newest `game_two_session_9048.log` | 34 / 34, newest `game_two_session_9048.log` (2026-08-19 23:10:17) | unmoved |
| `saves/world.json` md5 | `edfebf4accf0abf3aa86bb1170c62714` (mtime 23:10) | `edfebf4accf0abf3aa86bb1170c62714` (mtime 23:10) | unmoved |
| Play-path strict decode (pinned call shape `App::SaveStore.new(path:).load(data: Core::DataStore.new("data"))`) | `digest=b5cae357290c01e464f49155bc7f9d13` sessions=10 banked=7 provisions=0 breached=2 boss_1_defeats=1 notices=[] | identical, verbatim: `facts={"banked" => 7, "breached" => [["district", [42, 13]], ["district_two", [42, 13]]], "counters" => {"boss_1_defeats" => 1, "sessions" => 10}, "home_zone" => "camp", "members" => [{"hp" => 0, …"striker"}, {"hp" => 0, …"blocker"}, {"hp" => 60, …"lobber"}], "provisions" => 0}` digest `b5cae357…` notices=[] | unmoved |
| Junior tip vs `origin/main` | equal | `HEAD == origin/main == 4b2147a` (the s21 spark commit), 0 commits from his machine since `3b9821b` | no new Junior commits to read |
| Seat mail | done/=11, inbox EMPTY | done/=11, inbox absent/empty | unmoved |
| `tmp/soak` newest | `20260819-120805` | `20260819-120805` | no new soak |
| `_gate-verdicts.log` tail | T2 spot-gate PASS entries (`fec8b06`) | tail still a `"verdict": "PASS"` block, unchanged | unmoved |
| Untracked `drafts/_refs/` | 8 world-builder reference images (s18/s19, untracked by design) | same 8 files, mtimes ≤ 2026-08-19 17:45 | classified, pre-existing |

No new solo logs, so no new chain links: the anchor stays exactly
where ritual session 2 left it (`b5cae357…`, sessions=10). The owner
did not open the audio lane (asks 5–9 remain owner-pending, never
nagged).

---

## Half A (PERSISTED) — mechanical arbiter, the four checks

Spec wording, verbatim (three bullets), walked as the r9 spark's four
checks + its separate-launch clause. **Every line below was read out of
the banked log FILES, not out of any prose.** Evidence bank:
`drafts/_v18-seventeenth-evidence/`, md5s re-verified this session.

| File (banked copy) | md5 (re-measured) | Seat / session |
|---|---|---|
| `game_two_session_8503.log` | `01e2bbd15051b0374bdc7b27d595c5a0` | host (seat 1), session 1 |
| `game_two_session_2874720530.log` | `78c684d654648ca2b55a0a012e2582bf` | joiner (seat 2), session 1 |
| `game_two_session_9048.log` | `570457dcd11118c540490d1c31e8f27c` | host (seat 1), session 2 |
| `game_two_session_63472464.log` | `8931b524183792964213afdf65c18792` | joiner (seat 2), session 2 |

### A1 — Digest chain, host side (spec: "session 2's `persist loaded digest` == the latest prior `persist saved digest`") — **PASS**

```
8503:17  TELEMETRY persist saved  digest=3a518bccf2b324f9fb1211ed2f7529f0 schema=1 banked=5 provisions=0 seals=2 marks=0 sessions=9
9048:2   TELEMETRY persist loaded digest=3a518bccf2b324f9fb1211ed2f7529f0 schema=1 banked=5 provisions=0 seals=2 marks=0 sessions=9 source=file
```

Byte-identical digest, and every field on the two lines matches
(banked/provisions/seals/marks/sessions). **"Latest prior" verified
mechanically, not assumed:** the mtime-ordered launcher-log listing
puts `game_two_session_8503.log` (2026-08-19 22:28:02) immediately
before `game_two_session_9048.log` (23:10:17) — **no log of any kind
sits between them**, so no solo play could have moved the world in the
gap. Save file `mtime 23:10` + md5 `edfebf4a…` closes the loop on disk.

### A2 — Joiner handshake digest == host, BOTH sessions (spec, same bullet) — **PASS**

Session 1:
```
8503:2           loaded digest=66784a92f268776eeb917efb655449c6 … sessions=8 source=file
2874720530:2     loaded digest=66784a92f268776eeb917efb655449c6 … sessions=8 source=handshake
```
Session 2:
```
9048:2           loaded digest=3a518bccf2b324f9fb1211ed2f7529f0 … sessions=9 source=file
63472464:2       loaded digest=3a518bccf2b324f9fb1211ed2f7529f0 … sessions=9 source=handshake
```
Host `source=file` vs joiner `source=handshake` on the same digest,
both nights — the joiner entered the host's world, both times.

### A3 — `desyncs=0` + `reason=quit` on all four netplay lines, ticks ≥ 36000 each session, AUTOPILOT-free — **PASS**

```
8503:18        TELEMETRY netplay seat=1 ticks=74469 desyncs=0 stalls=9807 stall_ms_max=1113 reason=quit
2874720530:16  TELEMETRY netplay seat=2 ticks=74470 desyncs=0 stalls=136  stall_ms_max=1059 reason=quit
9048:18        TELEMETRY netplay seat=1 ticks=36079 desyncs=0 stalls=5386 stall_ms_max=3341 reason=quit
63472464:16    TELEMETRY netplay seat=2 ticks=36079 desyncs=0 stalls=268  stall_ms_max=843  reason=quit
```

- desyncs=0 on 4/4 · reason=quit on 4/4 (clean Esc both seats both
  sessions).
- Session 1: 74469 / 74470 ticks (2.07× the 36000 floor). Session 2:
  36079 / 36079 — **cleared by 79 ticks (~1.3 s)**; named, not
  softened: the bar was met, not met comfortably, and the owner ended
  that session on the lag.
- `grep -c AUTOPILOT` = **0** in all four files (bot-disqualification
  law: nothing to disqualify).
- Stalls are recorded here as context only — they are not part of any
  check, and desyncs=0 says lockstep never diverged (see the lag
  section below).

### A4 — At least one strictly-positive carried fact, NAMED (spec: "carried fact … matching session 1's close") — **PASS**

Session 2's `loaded` line carries, verbatim: `banked=5` · `seals=2` ·
`sessions=9`; the save decode adds `boss_1_defeats=1` and
`breached=[["district",[42,13]],["district_two",[42,13]]]`.

**Named carried facts (all > 0): `banked=5` and `seals=2`.** The
seals are the load-bearing one: the two breached zone tolls stayed
open across the session boundary — and that is the exact object the
owner named unprompted in his Half-B answer ("se sintió bien no tener
que abrir todos los peajes de nuevo"). Mechanical arbiter and felt
answer point at the SAME persisted fact. `sessions` 8 → 9 → 10 also
increments once per clean-quit save, matching two launches exactly.

### A5 — Separate launches, session 2 loads session 1's close (r9 spark check 3) — **PASS**

Two distinct hosting consoles banked, each carrying its own launch
timestamp and its own netplay line:

```
coop_console_20260819-215950.log:  TELEMETRY netplay seat=1 ticks=74469 … reason=quit   (session 1)
coop_console_20260819-225124.log:  TELEMETRY netplay seat=1 ticks=36079 … reason=quit   (session 2)
```

Plus, banked and classified: `coop_console_20260819-215128.log`
(`ticks=0`, the accidental close at the hosting screen — not a
session, world byte-unmoved). Two separate processes, ~23 min apart,
`sessions` counter 8→9→10.

**⇒ HALF A: CUMPLIDA. 5/5 rows PASS (the spec's three bullets + the
spark's launch-separation clause), every one quoted from bytes.**

### Chain walk (diagnostic context — welcome, decides nothing)

Full `loaded → saved` walk from the live launcher logs in mtime order
(digests truncated to 8):

```
6508  d63fd8ea → 602e94bb  (solo link #1, banked 0→20, sessions 2→3)
5861  602e94bb → 38f1bc62  (link #2a — ORPHANED by the named double-launch incident)
5847  602e94bb → 822b2e98  (link #2b — SURVIVOR, sessions 3→4)
5949  fresh    → f27c6073  (scratch, source=fresh — classified, not the world chain)
6087  822b2e98 → c4b8df2b  (link #3, sessions 4→5)
6240  c4b8df2b → 189a8072  (link #4, sessions 5→6)
7196  189a8072 → (no saved) (crashed session-1 ATTEMPT — world unmoved, classified)
6739  189a8072 → 9890bb5e  (link #5, ambient ear-check, sessions 6→7)
7461  9890bb5e → 66784a92  (link #6, cue/rotation ear-check, sessions 7→8; banked 20→12)
8444  66784a92 → (no saved) (idle hosting-screen close — world unmoved, classified)
8503  66784a92 → 3a518bcc  (RITUAL SESSION 1, sessions 8→9, banked 12→5)
9048  3a518bcc → b5cae357  (RITUAL SESSION 2, sessions 9→10, banked 5→7)
```

Every `loaded` equals a previous `saved`; the single fork (#2a/#2b) is
the pre-named dev double-launch, and the two `loaded`-without-`saved`
entries are the pre-named crash and the idle close. No unexplained
save move exists anywhere in the chain.

---

## Half B (FELT) — 8/8 answers, protocol satisfied

### The caveats attach BEFORE the reading (pre-registered, mechanical — not judgment)

1. **Same-day spacing (owner amendment 2026-08-18, "we can do 2
   sessions in a single day").** The two sessions ran 22:28 → 22:51
   the SAME night, ~23 minutes apart. Half A is untouched (it is
   mechanical). Effect on Half B: the "coming back later / next day"
   reading is WEAKENED — what the answers can prove is *session 2
   entered the world session 1 left and both players recognized it*,
   not *the world still felt continuous after a day away*. The
   across-days form of the question is NOT evidenced by this ritual.
2. **Symmetric audio novelty (owner amendment 2 + fallback branch).**
   Which branch applied was read from the seats' own logs, never
   assumed: `AUDIO on: device=1 sha=15f03e0219d6` on the host and
   `AUDIO on: device=1 sha=15f03e0219d6 lib=C:/Users/jr/Desktop/projeto-game-two/game-two-audio`
   on the joiner, BOTH sessions ⇒ **symmetric-novelty branch**. Effect:
   the free-verdict positives are audio-colored (first coop exposure
   to the owner-original library, retuned that same day) — read as
   directionally valid, not clean-room. Topic answers (continuity,
   respawn, provisions, AI, difficulty) are mechanically unaffected.

### The eight answers, VERBATIM

**Owner (es-CR, 2026-08-19 ~23:2x, administered one-by-one by this
seat at his order "preguntame una por una", wording byte-virgin from
the frozen runsheet) — banked `f749dc8`:**

- **P1 — "Al volver hoy, ¿sintieron que retomaban donde habían parado,
  o que era una partida nueva?"**
  > cada vez que entrabamos había que revivir a los compañeros, siempre aparecía solamente yo (seguramente por ser el host) pero siempre debía matar algunos enemigos antes de poder revivir a mis compañeros, pero obviamente tambien dependía de mi dinero (lo cual no creo que debería al iniciar una sesión) bueno aunque pensandolo bien tambien es una mecánica interesante, pero solamente en ciertos momentos o dungeos, no sé, hay que analizarlo y definirlo bien, pero sí en general para responder a tu pregunta: se sintió bien no tener que abrir todos los peajes de nuevo

- **P2 — "¿Cómo se sintió el respawn de los enemigos esta vez?"**
  > la verdad no lo noté o no le puse atención

- **P3 — "¿Usaste las provisiones? ¿Cómo cambió la cacería? ¿El
  precio?"** (counter-question recorded AS the answer; explanation
  deferred until 8/8 — quarantine held)
  > cuales provisiones? Te refieres a los 3 recuadros del inicio o de los "nidos" o "velos" para poder curarse y ponerse el cuadrito en la cabeza que aun no entiendo muy bien para que es? es como un tipo de blessing para no perder una vida? algo así?

- **P4 — "Veredicto libre."**
  > me gusta mucho el core del juego, solamente necesita cierto balanceo y variedad, aparte de los fixes mencionados hace un rato

**Junior (pt-br, 2026-08-20, administered one-by-one by his seat under
the owner's relayed order, byte-virgin wording) — banked `5f276ad`
(`drafts/_junior-answer-set-20260820.md`):**

- **P1 — "Na segunda sessão, pareceu que vocês tinham voltado pra onde
  pararam, ou que era uma partida nova?"** (authorized same-day
  premise variant USED — "Na segunda sessão" for "No segundo dia";
  noted beside the answer as the amendment requires)
  > pareceu que voltamos de onde paramos, o mundo continuou

- **P2 — "Em dupla, como sentiu a dificuldade dessa vez?"**
  > um pouco mais melhor mas segue muito dificil chegar no boss

- **P3 — "O terceiro corpo (a IA) — como se comportou?"**
  > a IA morre muito, fica correndo pra dentro dos inimigos

- **P4 — "Veredicto livre."**
  > o jogo está muito bom, mas precisa balancear a dificuldade ou conceder alguma vantagem aos herois

### Protocol deviations, named beside the sets (carried into the reading)

- Owner set: (a) the answers were given in the same chat that carried
  the night's logistics/tech clarifications (lag telemetry facts,
  E-skill mechanics) — the "no changelog, no context" law held for the
  QUESTIONS' wording, but session-night context existed around them;
  (b) R3 is a clarifying counter-question — nothing was explained in
  reply (quarantine held; the owed provisions/mark explanation was
  delivered only AFTER 8/8); (c) R4's "los fixes mencionados hace un
  rato" points back at his own mid-session observation list, banked
  earlier the same night.
- Junior set: a repo-watch tick landed between P1 and R1 (pull
  reporting, zero contact with the questions' subject) — named, no
  content contamination.
- Neither set was scored, paraphrased, or register-cleaned. Both
  administrations were one-by-one with zero commentary between Q and A.

### HELD material — admitted ONLY now (order is part of the protocol's validity)

- **Sustain telemetry, all four ritual lines:** `bought=0 used=0
  refused=0` (s1 host), `bought=0 used=0 refused=0` (s1 joiner),
  `bought=0 used=0 refused=1` (s2 host), `bought=0 used=0 refused=1`
  (s2 joiner). Solo-link context: `refused=4` on link #1, zeros on
  #2a/#2b/#3/#4/#5, `refused=1` on link #6.
- **Junior's pre-registered provisions signal**
  (`drafts/_junior-specials-chain-retry-20260818.md`): in his first
  sustain session he "não entendeu o que a provisão era".
- **Junior's post-answer side-signal** (`3b9821b`,
  `drafts/_junior-note-difficulty-items-20260820.md`, filed AFTER his
  4/4): "eu acredito que a parte da dificuldade vai ser resolvida
  quando entrar o update dos itens e equipamentos" — his opinion,
  explicitly not law, Gabriel's approval required.
- **Owner mid-session observations (7, DURING session 1, volunteered,
  verbatim EN):** more firepower/level-up (1) · "there is lag" (2) ·
  in-game chat or some system (3) · the E skill "doesn't inflict
  damage nor heal" (4) · "the lag usually intesifies when only 1 of us
  is alive" (5) · **"the enemies spawn too fast" (6)** · nice-to-have:
  enemies should walk home instead of teleporting (7).
- **Owner post-session E/ctrl note (~22:40):** the lobber's E "se
  siente debil", "al rato tiende a aburrir el gameplay de ese
  personaje", plus the stationary-facing re-vote.
- **Owner fragments (volunteered, never asked):** "en general el core
  gameplay me encanta, se siente muy reactivo y conectado el cuerpo a
  la acción, emocionante, ni si quiera me puedo imaginar lo que va a
  ser cuando sea más avanzado/maduro" (post session 1) · "it crashed
  for some reason but it was fun" (crash night) · at session 2's
  close: "listo, demasiado lag, no se puede jugar con tanta
  desincronización" · audio notes ("too repetitive", "6db lower",
  "sintéticos … maquetas").
- **Lag forensics as CONTEXT** (`drafts/_netplay-lag-forensics-20260819.md`):
  host stalls 9807 (13.2%) max 1113 ms vs joiner 136 in s1; host 5386
  (14.9%) max **3341 ms** in s2 — host-side starvation, spike-class in
  s2; `desyncs=0` on all four lines, so what the owner felt as
  "desincronización" was STALL, never divergence; post-session
  `tailscale ping` direct, 165 ms CR↔BR.

### The reading

1. **The v18 thesis landed — and it landed twice, independently.** Two
   players, asked separately, in different languages, both said the
   world continued: Junior flatly ("pareceu que voltamos de onde
   paramos, o mundo continuou"), the owner via the mechanic he
   noticed ("se sintió bien no tener que abrir todos los peajes de
   nuevo"). The felt answer names the same object the mechanical
   arbiter carried (`seals=2`). That is the strongest form of
   agreement this protocol can produce — capped only by caveat 1: it
   proves same-night continuity, not across-days continuity.
2. **Both free verdicts are positive with the SAME correction.** Owner:
   "me gusta mucho el core del juego, solamente necesita cierto
   balanceo y variedad". Junior: "o jogo está muito bom, mas precisa
   balancear a dificuldade ou conceder alguma vantagem aos herois".
   Independently authored, convergent shape: core good, balance owed.
   Caveat 2 (audio novelty) discounts the warmth of the positives but
   not the correction — novelty does not manufacture a balance
   complaint.
3. **The session opening is where the friction actually lives.** The
   owner's P1 answer spends most of its length not on continuity but
   on the re-entry ritual: dead companions, only the host embodied,
   kills required before he could pay, and the objection "lo cual no
   creo que debería al iniciar una sesión" — followed by his own hedge
   that it is "una mecánica interesante … en ciertos momentos o
   dungeos" and "hay que analizarlo y definirlo bien". Mechanically
   confirmed: session 2 opened `banked=5` while `data/balance/economy.json`
   prices the vat at `regrow_cost: 12` per dead body (all-or-nothing,
   `world.rb#interact_vat`: `12 × dead + 2 × wounded`) — two dead
   bodies would have cost 24 with 5 in the bank. He had to farm before
   the world would give his pack back. Routing row 9 territory.
4. **Provisions do not exist for the players yet.** `bought=0` on all
   four ritual lines; the owner's P3 is "cuales provisiones?"; Junior
   had already failed to learn what one was from the game. A priced
   sink nobody can find is not a pricing question — it is a
   discoverability question, exactly as the routing table pre-ordered.
   (The two `refused=1` events in session 2 are consistent with
   someone pressing U/R and getting nothing: with `provisions=0` and
   banked ≥ 5 the refusal set narrows to `none` (pressed away from a
   bank) or `broke` at press time — the refusal REASON is not in the
   telemetry line, which is itself a recordable instrumentation gap.)
5. **Respawn: the direct answer and the mid-session note disagree, and
   both are his.** P2 = "la verdad no lo noté o no le puse atención";
   mid-session observation 6 = "the enemies spawn too fast". The
   contradiction is recorded as-is, no averaging. One physical note
   protects the "too fast" reading from being a lag artifact: the game
   is tick-locked, so host stalls make spawns arrive SLOWER in wall
   time, never faster — the report cannot have been inflated by the
   stalls.
6. **The AI third body is named, again, by the seat that watches it
   most.** Junior's R3: "a IA morre muito, fica correndo pra dentro
   dos inimigos". Session telemetry is consistent (s1 `body_deaths=28`
   / `wipes=9`; s2 `body_deaths=20` / `wipes=6`).
7. **Difficulty: "um pouco mais melhor mas segue muito dificil chegar
   no boss".** The "mais melhor" is a readback on v18's coop pacing
   block (`data/balance/coop.json` seats=2: `respawn_delay_scale 2.0`,
   `human_hp_scale 1.25`, `ally_flee_hp_pct 0.35`) — it moved the
   needle without closing the gap. There is no pre-registered routing
   row for "still too hard"; it is recorded below as an unmapped
   signal, not squeezed into a row.
8. **The lag is the night's loudest pain and it is NOT a v18 defect.**
   The owner ended session 2 on it ("no se puede jugar con tanta
   desincronización") — and desyncs=0 on all four lines says lockstep
   held; the failure mode is host-side throughput (spikes to 3.3 s).
   It did not break a single Half-A check, and both players still
   answered the felt half positively THROUGH it. It is the first
   post-verdict work item by the owner's own severity call, in the v17
   netplay lane, not the v18 persistence lane.

**⇒ HALF B: CUMPLIDA** — 8/8 answers collected under the protocol
(virgin wording, separate administration, verbatim banking, deviations
named), read with both pre-registered caveats attached and all HELD
material admitted only afterwards.

---

## Routing table — EVERY row walked (spec §Fun-verify, quoted verbatim)

**Row 1 — "Chain digest mismatch or any session-2 desync → save/load
divergence work item (round-trip lane extension; artifacts banked,
diff named)."**
**NOT TRIGGERED.** `9048:2 loaded digest=3a518bcc…` == `8503:17 saved
digest=3a518bcc…` (byte-identical, all fields); `desyncs=0` on
`9048:18` and `63472464:16`. This was the only row that could have
blocked v18 from closing.

**Row 2 — "'No continuó' with a CLEAN chain → session-start
presentation item (the world doesn't SHOW its history; candidate:
surface the map artifact / a session-open summary — recorded, not
auto-built)."**
**NOT TRIGGERED.** Junior: "pareceu que voltamos de onde paramos, o
mundo continuou". Owner: "se sintió bien no tener que abrir todos los
peajes de nuevo". Neither player reported a new game. (Honest
footnote, no row invented: what they NOTICED was the tolls; nobody
mentioned banked/seal counters or a history surface, so the
presentation candidate is neither triggered nor refuted — the
same-night spacing means the durable form of this question is still
unmeasured, and it will be measurable free at the next multi-day
coop pair.)

**Row 3 — "Respawn friction persists → coop.json retune, data-only
re-session."**
**TRIGGERED** — by the HELD mid-session observation 6, owner verbatim
DURING session 1: "the enemies spawn too fast". Named beside it, not
averaged: his direct P2 answer was "la verdad no lo noté o no le puse
atención". Corroborating telemetry: s1 `arrivals{pocket=88 seed=28
home=0}` with `density pockets{mean=3.7 max=17}` over 74469 ticks; s2
`arrivals{pocket=83 seed=5}` over 36079 ticks (≈ same pocket arrivals
in half the time).
→ **RECORDED item R-A1 (data-only, sim-class — now unfrozen by this
verdict):** re-tune `data/balance/coop.json` seats=2 respawn pacing
(and/or the district pocket cadence), then a data-only re-session to
re-measure. Next-spark shape: read the corpus brief §2 FIRST
(`docs/design-corpus/gamesmith/addenda/corpus-to-v18-evidence-brief-20260819.md`
— "pricing failed attempts in supplies plus walk-back time while
progression stays untouched"; it explicitly cannot settle game-two's
per-seat numbers, so the SIXTEENTH/SEVENTEENTH telemetry stays the
baseline) · change ONE scalar per re-session · `rake perf` + suite via
hooks · no visual surface moves, so no wall debt. Owner-priority call
at the brainstorm.

**Row 4 — "Sustain unused (`sustain bought=0`) → discoverability first
(strip exposure), then price debate."**
**TRIGGERED, hard.** `bought=0` on 4/4 ritual sustain lines; owner P3
"cuales provisiones?"; Junior's pre-registered "não entendeu o que a
provisão era"; two `refused=1` events in session 2 (reason not
logged).
→ **RECORDED item R-A2 (presentation FIRST, price debate second — the
row's own ordering):** expose the sustain verb where the player already
looks (controls strip / HUD stock, the existing `hud.provisions` +
`overlay.sustain` surfaces; pt-br strings already ratified as
SUPRIMENTOS). Next-spark shape: strings + renderer only (sim-blind) ·
Rule 2 blocking gate + wall debt owed (it is a visible surface) ·
locale trio en/es/pt-br · cite corpus brief §1 for the shape (Tibia's
sustain is legible because the spend is visible per second — carried
stock + draining balance), not for numbers. **Measurement note: the
owner's provisions question is BURNED for re-asking** — the owed
explanation was delivered to him after 8/8 (quarantine expired by its
own terms), so the next measure of this row is BEHAVIOR (`sustain
bought/used` telemetry in a later session), never a re-ask. A
sub-item worth its own line: log the refusal REASON
(`at_cap/broke/none/no_effect/seat_race` already exist in
`world.rb#sustain`) in the `TELEMETRY sustain` line, so a future
`refused=N` is readable.

**Row 5 — "Sustain named cheap/free OR banked_end grows monotonically
3+ sessions with flat spend → pricing debate re-opens (F3 valve)."**
**NOT TRIGGERED**, both clauses, by arithmetic. Nobody named the price
at all (they did not know the item existed). `banked_end` trajectory
across the banked chain: 20 → 20 → 20 → 20 → 12 → **5** → 7 — it FELL
with real spend (s1 `banked_spent{inscribe=72 tribute=190}`, s2
`{inscribe=48 tribute=148}`), the opposite of monotone growth with
flat spend. Price debate stays parked behind row 4's ordering.

**Row 6 — "AI suicides still named → v18.1 embodiment/AI debate item,
recorded."**
**TRIGGERED.** Junior R3 verbatim: "a IA morre muito, fica correndo
pra dentro dos inimigos".
→ **RECORDED item R-A3 (debate, not a build):** v18.1-class
embodiment/AI item — the third body's engage rule (it charges into
contact) versus the ally-flee scalar that already exists
(`coop.json ally_flee_hp_pct 0.35`). Next-spark shape: a brainstorm
fork with two named candidates (tune the existing flee/engage
thresholds = data-only; or an AI stance verb = sim-class, v19) —
recorded only, nothing auto-built, and it must not be bundled with
row 3's retune (two knobs, one re-session, or the measurement is
mud).

**Row 7 — "Junior asks for HIS solo play to advance the shared world →
custody handoff = the always-online trigger family (PARKING_LOT)."**
**NOT TRIGGERED.** No such ask exists in his answer set, either
ritual-session file, his post-answer note, or his v19 intake ideas.
The always-online trigger stays unfired.

**Row 8 — "Quit-timing griefs (value stranded in the field at quit)
named → recorded as EVIDENCE for the item-cycle promotion (backpack +
position persistence + logout rules — the owner's 2026-08-17 rider,
PARKING_LOT §riders); plus the session-close 'bank before you leave'
cue as the cheap v18-era mitigation. The v18 mechanic itself does not
re-open."**
**NOT TRIGGERED.** No player named stranded value at quit. Closest
misses, recorded so a future harvest is not tempted: s1 telemetry
`carried_lost=1` / `corpse_looted=11` (in-session losses, the designed
re-seed law — not a quit grief), and session 2 closed with `banked=7`,
i.e. value WAS banked before the exit. The owner ended on lag, not on
loss.

**Row 9 — "Session 2 opens under-resourced (dead bodies + banked below
the regrow fee) AND the opening reads as chore → mercy-floor debate
(e.g., a first-open regrow discount) — recorded, not auto-built (panel
Kimi-Q2 watch; the comeback-arc reading gets its fair test first)."**
**TRIGGERED.** Clause 1 (under-resourced) is proven from bytes:
`9048:2 loaded … banked=5` versus `regrow_cost: 12` per dead body
(all-or-nothing vat: `12 × dead + 2 × wounded`). Clause 2 (the opening
reads as friction) is the owner's own P1: "siempre debía matar algunos
enemigos antes de poder revivir a mis compañeros, pero obviamente
tambien dependía de mi dinero (lo cual no creo que debería al iniciar
una sesión)" — and he asked for exactly this row's outcome in the same
breath: "hay que analizarlo y definirlo bien". Named limitation, no
softening: the dead-bodies-at-open state is testified by the player
and matches the session-2-close decode (`members hp = 0, 0, 60`), but
the session-1-close save bytes were legitimately overwritten at 23:10,
so the opening member array itself is not re-readable. `marks=0` at
session-2 open also means they opened with zero wipe insurance.
→ **RECORDED item R-A4 (debate, recorded — explicitly not
auto-built):** mercy-floor at session open (candidates: first-open
regrow discount · a floor that guarantees the first regrow ·
scaling the fee by how the last session ended), read AGAINST the
comeback-arc reading the row protects and against the owner's own
hedge that the ritual is "interesante … en ciertos momentos o
dungeos" (i.e. maybe the right answer is context-gated, not global).
Next-spark shape: brainstorm fork with the owner's verbatim on the
table + corpus brief §2 (failure priced in supplies and time, never in
progression) as the touchstone; data-only if it ships.

**Row tally: 9 rows walked · 4 TRIGGERED (3, 4, 6, 9) · 5 NOT
TRIGGERED (1, 2, 5, 7, 8) · 0 rows invented · 0 rows softened.** Every
triggered row's pre-registered outcome is "recorded" or "data-only
retune" — none of them contradicts shipping v18.

---

## Signals with NO pre-registered row (recorded as brainstorm inputs — no rows invented)

The routing table is CLOSED, so these do not become rows; they enter
the v19 brainstorm as inputs with their evidence attached.

1. **Lag / host-side stall spikes** — owner-named blocker; already the
   FIRST post-verdict work item (`drafts/_netplay-lag-forensics-20260819.md`
   §Investigation shape: per-tick ms histogram + stall-cause tags
   behind an env flag + a live `tailscale status` sampler; soak bots
   are legal here — tech lane, never fun-evidence).
2. **Difficulty gap to BOSS 1** (Junior R2 + his items/equipment
   reading, `3b9821b`) — progression-class; the item/backpack chain is
   already the declared v19 LEAD, and intake ideas 3/4 sit on it.
   Owner approval required by Junior's own framing.
3. **Progression/firepower and level-up** (owner mid-session 1) —
   intake idea 4 material.
4. **E-skill (lobber volley) legibility + "se siente debil"** —
   classified from code, no defect: 35 dmg on tiles 2/3/4 after 40
   frames, no telegraph on the impact tiles. Renderer-only flywheel
   candidate (Rule-2-gated) + the potency/range-growth half is intake
   idea 4.
5. **Enemies teleporting home on zone-leave** (owner mid-session 7) —
   intake idea 7, sim-class, interacts with row 3's respawn measure.
6. **In-game chat "or some system"** (owner mid-session 3) — PARKED
   with the widened trigger (PARKING_LOT), re-vote already recorded.
7. **Sustain refusal reason not logged** — instrumentation sub-item of
   R-A2.
8. **Hosting-wait log spam** (~90 `AUDIO drift` lines per session at
   tick 0) — cosmetic logging item from the forensics doc.
9. **Audio asks 5–9 + the "maquetas" program framing** — owner-initiated
   lane, `drafts/_m5a-verdict-20260818.md` §Ear-check 2 / ask 9.

---

## The decision

**THE SEVENTEENTH IS CUMPLIDO. v18 (persistent world, etapa 1)
CLOSES.**

- **Half A: CUMPLIDA** — 5/5 rows PASS, every line quoted from banked
  bytes: chain `3a518bcc…` exact host-side with no log in the gap ·
  joiner handshake == host both sessions · desyncs=0 + reason=quit on
  4/4 with ticks 74469/74470 and 36079/36079 (bar cleared, by 79 on
  session 2 — named) · AUTOPILOT-free 4/4 · carried facts NAMED
  `banked=5` and `seals=2` (> 0) · two distinct launches, sessions
  8→9→10.
- **Half B: CUMPLIDA** — 8/8 verbatim under protocol; both seats
  independently reported that the world continued; both free verdicts
  positive with a shared correction (balance); four routing rows
  triggered, all pre-registered recorded outcomes.
- **What would have blocked the close and did not fire:** a failed
  Half-A check, routing row 1 (chain mismatch / session-2 desync), or
  routing row 2 ("no continuó" — the cycle's thesis failing to land).
- **The caveats' effect, plainly:** (1) same-day spacing caps the
  continuity result at *same-night* continuity — the across-days form
  is unproven and will be measured for free at the next multi-day
  coop pair, owed to nobody; (2) symmetric audio novelty tints the
  warmth of both free verdicts — the balance corrections inside them
  are untainted, and no mechanical answer depends on audio. Neither
  caveat was waived, averaged, or traded against a check.
- **Honest close, not a victory lap:** the cycle's ask is answered,
  the lag is blocker-class for the next play session, and the balance
  correction both players wrote is the loudest thing in the evidence.

## Post-verdict queue — RECORDED, not started (priority is the owners')

| # | Item | Class | Source |
|---|---|---|---|
| 1 | Lag instrumentation (stall-cause tags + tailscale sampler, bots legal) | tech, owner-named blocker | forensics doc §Investigation shape |
| 2 | R-A2 sustain discoverability (strip/HUD exposure, Rule 2 + wall) → then price debate | presentation, then debate | routing row 4 |
| 3 | R-A1 respawn/coop pacing retune + data-only re-session | data (sim-class, now unfrozen) | routing row 3 |
| 4 | R-A4 mercy-floor-at-open debate | debate (recorded) | routing row 9 |
| 5 | R-A3 third-body AI embodiment debate | debate (recorded) | routing row 6 |
| 6 | Audio: asks 5–9 (−4 dB percussive · dodge take curation · zone-change render + ping repurpose · 32-bar evolving ambient · ranged-shot cue) + audio-lib clock-anchor intake review (`08676dc`) | owner-initiated lane | M5a verdict |
| 7 | Flywheel findings R1–R7 (boss banner camera seam · windup landing preview · palette/taxonomy asset-era · toast placement · knockback/pursuit sim-class) + E-skill telegraph candidate | presentation / v19 pool | s17 flywheel + forensics |
| 8 | World-builder T3 (safe tile behaviors) / T4 (pilot authoring) lane order versus the lag item | lane-order question | AGENTS.md lane 3 |
| 9 | v19 intake pool: 7 banked ideas (`drafts/_junior-v19-ideas-20260819.md`) + Junior's items/difficulty reading | brainstorm inputs | intake |

**v19 does NOT open here.** The brainstorm is the two owners', at
their word, carrying the inputs above.

## Post-verdict world note (2026-08-21, session 28 — T5 wire-in)

The world this ritual measured was the SIX-ZONE world. On 2026-08-21 —
AFTER this adjudication closed (2026-08-20) and after the owner ratified
the T4 pilot walk ("Aprobado") — WB T5 wired ONE boss-gated edge into it:
low_quay [44,19] ↔ zone_7 [1,14] (`requires_defeats: 1`; commit
`371aedd`). Every number above predates that edge; none of the SIM
quantities the ritual measured (respawn/difficulty/sustain pacing)
moved before its close, and the authored content beyond the gate ships
threat-free (zone_7) or conservative (dungeon_1) with zero balance-file
changes. Future readings of this verdict cover the six-zone arc only —
the expanded world is post-verdict content under the D12 completion
recorded in AGENTS.md lane 3.
