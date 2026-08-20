# CHECKPOINT — game-two (Ruby rebuild of Kethral)

## 2026-08-20 session 23 (hub) — **ROUTE P1 EXECUTED: R-A2 sustain discoverability SHIPPED behind every gate** (router: no owner lane open · zero T2 evidence on this machine — no frame_probe/handshake lines in 34/34 launcher logs, no new Junior lag docs → P1) · v19 still NOT open

**Two one-concern commits, hooks green each; fresh-eyes PASS; pushed.**
(1) `e36a227 (pre-rebase 0f62c7f)` telemetry: `TELEMETRY sustain` gains fixed-order
`reasons{at_cap broke none no_effect seat_race}` — ADD-ONLY behind the
pinned prefix (verdict row 4 sub-item; the SEVENTEENTH's two `refused=1`
were unreadable); chain_check regex-audited (no sustain pattern);
unknown-reason guard pinned by test after the review's LOW finding.
Proved live in the gate's own teed log:
`reasons{at_cap=1 broke=1 none=0 no_effect=1 seat_race=0}` byte-identical
across both replays. (2) `d31f579 (pre-rebase 4e53e0c)` renderer: the bank BUY hint
`U PROVISION -5` / `U PROVISIÓN -5` / `U SUPRIMENTOS -5` — speaks ONLY
when a buy would succeed (banked>=cost AND under cap), yields the y-32
slot to live receipts, proximity rides the ledger's radius-3 loop; ZERO
new string keys (glyph from the live BindingMap + ratified
`hud.provisions` + the altar/vat `-price` grammar); decision 7iii strip
gate UNTOUCHED. Grill spec + wall costing:
`drafts/_rA2-grill-spec-20260820.md` (verdict's literal "strip" surface
argued DOWN — camp/nest spawns sit Chebyshev-2 from their banks, so any
unconditional surface re-pins the whole wall; the affordability condition
makes spawn frames byte-identical).

**Wall cost MEASURED, not guessed:** one-replay md5 sweeps before/after
(`tmp/rA2_base` clean-HEAD worktree · `tmp/rA2_after`): 15/18 scripts
byte-identical; moved = low_quay_run(4fr)/nest_advance(4fr)/
vat_economy(1fr), every diff read frame-by-frame = solely the hint.
Gates: 4/4 rc=0 (moved set + sustain_run with 3 new hint-state captures
2429/2560/2585) + targeted critique 5/5 PASS
(`harness/sustain_hint_checks.json`) + language axes PASS (receipts:
`drafts/_rA2-verify-20260820.md`, review:
`drafts/_rA2-review-20260820.md`). Netplay gates argued not-owed (scene
banks at most 1 < cost 5). **Line-cap law fired mid-ticket** (world.rb
1806/1800) → `Game::PriceSheet` extracted (delegating code motion, call
sites untouched, 1795/1800). **Process trap hit + banked to project
memory:** the baseline sweep was contaminated by editing renderer source
mid-sweep (8/18 re-baselined from a `git worktree` at pre-change HEAD).

**The measure from here (burned-question law):** never re-ask the owners
about provisions — read `TELEMETRY sustain bought>0` + the reasons split
in FUTURE session lines; sustain SIM numbers stay frozen until then.
**Owner-pending unchanged:** audio asks 5–9 · v19 brainstorm · T2 probe
matrix owner-paced (S0-J decisive; S0-J2 done, never re-run).

## 2026-08-20 session 22 (hub) — **P0 LAG under grill-and-ticket: the limiter is NAMED from banked bytes (the JOINER seat, ~53.5 Hz both ritual sessions); T1 instrumentation SHIPPED behind the full battery; fresh-eyes PASS; T2 staged** · v19 still NOT open

**Grill ≥ implementation (declared up front; council 0, Bedrock = gate
critics only).** The banked evidence answered WHO before any code:
(1) stall semantics INVERTED from the forensics doc's reading —
`stalls=N` = updates THIS seat waited for the peer (`lockstep.rb:97-100`
ready? gates on the remote queue; correction section written, wrong
claims struck in place); (2) counter identity updates=ticks+stalls ⇒
host iterated +12.96%/+14.08% more than the joiner in the same run
windows — **the joiner's loop paced both sessions at ~53.5 Hz, the host
ran ~60.5 and WAITED**; (3) the `AUDIO drift` lines are a wall-clock
oracle (engine_pcm/48000, cadence 1800; both seats' independent clocks
agree 0.05%): shared rate s1 53.49 / s2 52.63 tps, s2 worst at the OPEN
(44.7 tps first 75 s); (4) host machine EXONERATED live — banked solo
human sessions 60.75-61.15 tps steady + tonight's two-run bot slope
probe 61.1 Hz (zero code); (5) D=8 COVERS the steady path (joiner stall
rate 0.18% — an undercover stalls BOTH seats; the spark's premise
falsified); (6) the 0.8-3.3 s spike class is SEPARATE, both directions
(TCP RTO backoff / DERP flap / machine hitch / title-bar drag —
undistinguishable today, T1a's coherent pair + T2 samplers
discriminate). Killed metrics recorded with reasons (remote-queue depth
aggregate, pump/sim split, per-tick histogram, audio-off segment).
Spec: `drafts/_lag-spec-20260820.md` · tickets:
`drafts/_lag-tickets-20260820.md` · forensics correction:
`drafts/_netplay-lag-forensics-20260819.md` §Correction.

**Shipped (3 commits, hooks green each; hashes post-rebase over Junior's
two docs commits):** `7629052` T1a — always-on
`NETPLAY handshake seat d link_slow rtt_ms` line at world birth (banks
the never-logged negotiated D + host probe RTTs; survives dirty deaths)
+ close-line gains `d link_slow run_ms stall_run_max stall_worst_run`
(per-seat update rate = (ticks+stalls)/run_ms — WHO in one subtraction
every session; the worst-run PAIR is coherent with stall_ms_max →
ms-per-stalled-update separates waiting-while-healthy ≈16.7 from
frozen-locally ≫16.7). Nothing new crosses the wire. T1b —
`GAME_FRAME_PROBE=1` → `App::FrameProbe` (pure, injected clock, upper
nearest-rank percentiles, over20/35/100 period census) bracketing
Window update/draw; flag-off = nil-checks only; one
`TELEMETRY frame_probe` line at close; solo AND session modes.
`f2420d0` review closure (integration presence assertion + two honest
comments).

**Battery (all PASS, evidence in tmp/lag/ + receipt):** rake ×3 ·
world_loop gate flag-off RC=0 · netplay gates ×3 RC=0 (scene shows the
new counters live: seat1 stall_worst_run=91 vs seat2 0) · perf p95
0.275 ms (sim tick is CHEAP — the budget lives in draw/pacing) ·
flag-ON soak N=1: SOAK PASS, desyncs=0 over 6120 ticks with the probe on
BOTH bot windows, and the lines already discriminate (both bot seats
period p50=31.6 ms, update 0.3 + draw 0.6 ⇒ two-occluded-window desktop
is PACING-bound — explains the known 2× soak wall-time; equal rates ⇒
stalls=0 both, the symmetric-limiter arithmetic confirmed live).
Loopback cannot reproduce the 165 ms path — recorded.

**Fresh-eyes review (scrubbed pi, diff+tickets only): round 1 FAIL
(ticketed integration-test change was skipped on a wrong prediction —
closed by f2420d0 + ticket amendment recording the verified reality),
round 2 PASS** — clock-leak trace CLEAN, flag-off zero-work CLEAN.
Receipt: `drafts/_lag-t1-review-20260820.md` (round-1 blocker, closures,
accepted lows). Review ran detached after a 600 s bash timeout killed
the first re-run attempt (the gate lesson generalizes to every long
subprocess).

**T2 STAGED, owner-paced (never nag):**
`drafts/_lag-probe-runsheet-20260820.md` — S0-J Junior SOLO flag-ON =
the decisive segment (is his machine ~53.5 alone?), S0-J2 display/power
facts, S1 coop baseline, S2 focus experiment (alive seat minimized
60 s), S3 role swap (guards: Gabriel save md5 unchanged; Junior scratch
save never merged), tailscale + netstat retransmit samplers per segment.
T3 (harvest verdict → ONE fix ticket) and T4 (the fix) are their own
sessions — never bundled with T1 (before/after law).

**Job 0 / standing-gate deltas, classified:** save md5 UNCHANGED
(`edfebf4…`, decode digest `b5cae357…` sessions=10) · launcher logs
STILL 34/34 (probes ran `ruby -Isrc` directly, logs under tmp/lag/ —
never bin/play) · mail done/ 11→12: the gamesmith NW-intro RECEIPT
landed and the REVIEWER triaged it into done/ (overreach beyond its
brief, harm nil — recorded; receipts belong there); its housekeeping ask
honored by THIS seat: `tmp/nw_intro/` reclaimed (106 MB; corpus is the
durable home, md5-verified pre-ingest). RECEIPT lines harvested (closes
the `from-game-two-nw-intro-video-ingest.md` dispatch): `RECEIPT:
gamesmith/docs/nw-aeternum-intro-reveal-grammar.md` (commit 25fe609, md5
b7c52ae3230d49fbda7596c221965deb — G1–G8 adjudicated: G1/G3–G6
confirmed, G2 sharpened, G7 audio = source-class gap, G8 refuted→refined;
+5 pattern cards) + `RECEIPT:
gamesmith/artifacts/games/new-world-aeternum-intro/` (29 segments, 353
mechanics + 101 feel obs; spend $12.64). Re-stamp check: NOTHING owed
(no game-two file cites the stale md5 `707220ce…`; live doc md5
`c324a646…` on any future re-cite) · `drafts/_gate-verdicts.log`
grew 4 PASS entries (tonight's gates) · tmp/soak newest
`20260820-020422` (the flag-ON episode) · **Junior's seat pushed TWO
docs-only commits mid-session (read, then rebased onto):** `40c137c` a
work-split OFFER to the hub (lane-based split, capability inventory of
his machine — suite/soak/clips run there TODAY, vision critic blocked on
dead AWS creds, LDtk GUI missing; candidate #1 = R-A3 with a file:line
diagnosis; 4 closed questions, "silêncio não é sim") + `38f27ee` R-A3
measurement attempt banked (soak PASS 2/2 his machine; finding = a GAP:
a2_fired has no per-body attribution; stopped at his own declared code
boundary). **The offer's answers are GABRIEL's to give, not this
seat's** — queued in the es-CR block below; note Recorte A dovetails
with T2 (his seat can orchestrate his segments).

**Para el chat (es-CR, ~5 líneas):** «Ya medimos el lag con los datos
que teníamos guardados: la señal dice que el asiento de Junior marcó el
paso (~53 fps) en las dos partidas y el host se quedó esperando — la
conexión estable aguanta bien, y los congelones de 1-3 s son otra cosa
aparte. El juego ya trae los contadores nuevos para confirmarlo en
vivo. Cuando puedan, 4 tandas de ~4 min con Junior (la clave: él jugando
SOLO con `GAME_FRAME_PROBE=1`); comandos en
`drafts/_lag-probe-runsheet-20260820.md`. Sin prisa — cuando les
calce.» Y aparte: el asiento de Junior mandó una oferta de reparto de
trabajo con 4 preguntas cerradas
(`drafts/_junior-work-split-offer-20260820.md` §6) — esas respuestas
son suyas, Gabriel.

**Next session resumes at:** T2 harvest when the owners run it (→ T3
verdict → ONE fix ticket) · P1-P6 priority list lives in the session-22
spark (P1 = R-A2 sustain discoverability) · v19 brainstorm at the
owners' word · audio asks 5-9 owner-pending.

**RATIFIED (owner, 2026-08-20, post-close):** Junior-offer answers —
Recorte A **SÍ** (his seat = P0 execution/measurement, zero source his
side) · R-A3 **CONGELADA** until the v19 brainstorm · world.rb touches =
**DIFF** if the lane is ever assigned · LDtk 1.5.3 GUI install **SÍ**
(tool ≠ lane). Answers doc for his seat:
`drafts/_hub-answers-work-split-20260820.md`. Coop-segment samplers
authorized under Recorte A. Next-session router spark:
`drafts/_post-t1-router-spark-20260820.md` (T3 if T2 evidence exists,
else P1).

## 2026-08-20 session 21 (hub, docs-only) — **ADJUDICATION: THE SEVENTEENTH IS CUMPLIDO — v18 CLOSES** · Half A 5/5 from bytes · Half B 8/8 read with both caveats · routing walked 9/9 (4 triggered) · post-verdict queue RECORDED · v19 NOT opened

**Verdict of record: `drafts/_v18-fun-verify-verdict-20260820.md`**
(v17 format precedent). Session was docs-only by law: no code, no data,
no sim numbers, no gates — the verdict is what UNLOCKS the frozen
numbers, it never touched them. Council 0, Bedrock $0, no fan-outs.

**Job 0 (compressed standing gate, quarantine INTACT):** logs 34/34
both temp patterns, newest `game_two_session_9048.log` (23:10:17) ·
save md5 `edfebf4accf0abf3aa86bb1170c62714` mtime 23:10 · strict decode
(pinned call shape) `digest=b5cae357290c01e464f49155bc7f9d13`
sessions=10 banked=7 provisions=0 breached=2 (district, district_two)
boss_1_defeats=1 notices=[] members hp 0/0/60 · `HEAD == origin/main ==
4b2147a`, 0 new Junior commits · mail done/=11 inbox EMPTY · tmp/soak
newest `20260819-120805` · gate-verdicts tail unchanged (T2 PASS) ·
untracked `drafts/_refs/` = the s18/s19 reference images (pre-existing).
Nothing moved since session 20 → no new chain links, anchor still
`b5cae357…`. Owner did not open the audio lane (asks 5–9 stay pending,
never nagged).

**HALF A — CUMPLIDA, 5/5 PASS, every line quoted from the banked log
FILES (md5s re-verified):** A1 chain host-side `9048:2 loaded
digest=3a518bcc…` == `8503:17 saved digest=3a518bcc…` **and no log of
any kind sits between 8503 (22:28:02) and 9048 (23:10:17)** — "latest
prior" proven mechanically, not assumed · A2 joiner `source=handshake`
== host BOTH sessions (`66784a92…` s1, `3a518bcc…` s2) · A3 desyncs=0 +
reason=quit on 4/4, ticks 74469/74470 and 36079/36079 (s2 cleared the
bar by 79 ticks — NAMED, not softened), `grep -c AUTOPILOT` = 0 in all
four · A4 carried facts NAMED `banked=5` + `seals=2` (both > 0; also
sessions=9, boss_1_defeats=1) — **the seals are the same object the
owner named felt-side ("no tener que abrir todos los peajes de
nuevo")** · A5 two distinct hosting consoles (215950 s1 / 225124 s2),
sessions 8→9→10. Full chain walk (12 logs, every `loaded` == a previous
`saved`; fork #2a/#2b + crash + idle all pre-named) in the verdict.

**HALF B — CUMPLIDA, 8/8 verbatim.** Both caveats attached BEFORE the
reading (same-day spacing ~23 min → the result is SAME-NIGHT
continuity, the across-days form stays unmeasured; symmetric audio
novelty read from both seats' own `AUDIO on … sha=15f03e0219d6` lines,
both sessions). HELD material admitted only after both sets (sustain
0/0/0 · 0/0/0 · 0/0/1 · 0/0/1; Junior's provisions + items/difficulty
notes; the owner's 7 mid-session observations, E/ctrl note, fragments;
lag forensics as context). **Reading:** the v18 thesis landed twice
independently (Junior "o mundo continuou"; owner "se sintió bien no
tener que abrir todos los peajes de nuevo") · both free verdicts
positive with the SAME correction (balance/variety) · the real friction
is the session OPENING (banked=5 vs `regrow_cost: 12` per dead body,
all-or-nothing vat) · provisions do not exist for the players yet
(bought=0 4/4, "cuales provisiones?") · respawn: P2 "no lo noté" vs
mid-session "the enemies spawn too fast" — contradiction recorded, and
tick-lock physics means stalls could only make spawns feel SLOWER, so
the report is not a lag artifact · AI third body named again by Junior
· lag is blocker-class but a v17-lane THROUGHPUT defect (desyncs=0),
not a v18 persistence defect.

**ROUTING — 9/9 rows walked, 0 invented, 0 softened. TRIGGERED (4):**
row 3 respawn friction → **R-A1** coop.json/pocket-cadence retune +
data-only re-session (corpus brief §2 first, one scalar per session) ·
row 4 sustain unused → **R-A2** discoverability FIRST (strip/HUD
exposure, Rule 2 + wall owed, locale trio), price debate second; the
owner's provisions question is BURNED for re-asking (explanation
delivered post-8/8) so the next measure is BEHAVIOR telemetry;
sub-item: log the refusal REASON · row 6 AI suicides → **R-A3** v18.1
embodiment/AI debate (must not be bundled with R-A1) · row 9
under-resourced open + friction → **R-A4** mercy-floor debate (the
owner asked for it himself: "hay que analizarlo y definirlo bien"; his
own hedge = maybe context-gated). **NOT TRIGGERED (5):** row 1
chain/desync (the only row that could have blocked the close) · row 2
"no continuó" · row 5 price valve (banked_end 20→20→20→20→12→5→7, not
monotone, real spend) · row 7 custody handoff · row 8 quit-timing
griefs (closest misses named).

**Docs closed this session:** skeleton telemetry slots FILLED verbatim +
Half A/B PENDING→resolved + gaps 1–8 CLOSED + adjudication pointer ·
AGENTS.md current-cycle block carries the ONE adjudication line (stale
Lane-1 / owner-pending text retired; intake count 2→7) · the verdict doc
is the narrative home (scope contract).

**NEXT-BRAINSTORM INPUTS (the humans', at their word — v19 is NOT open):**
1. **Lag instrumentation** — owner-named blocker, FIRST in the queue
   (`drafts/_netplay-lag-forensics-20260819.md` §Investigation shape:
   per-tick ms histogram + stall-cause tags behind an env flag + live
   `tailscale status` sampler; soak bots legal, tech lane).
2. **R-A2 sustain discoverability** → then the price debate.
3. **R-A1 respawn/coop pacing retune** (sim numbers now UNFROZEN).
4. **R-A4 mercy-floor-at-open debate** · 5. **R-A3 third-body AI debate**.
6. **Audio:** asks 5–9 (−4 dB percussive · dodge take curation ·
   zone-change render + ping repurpose to item-pickup · 32-bar evolving
   ambient · ranged-shot cue; MAQUETAS framing recorded) + the audio-lib
   **clock-anchor intake review** (`08676dc`).
7. **Flywheel findings R1–R7** (boss-banner camera seam · windup landing
   preview · palette/taxonomy asset-era · toast placement ·
   knockback/pursuit sim-class) + the **E-skill telegraph** candidate.
8. **World-builder T3/T4 lane order vs the lag item** (owner call).
9. **v19 intake pool: 7 ideas** (`drafts/_junior-v19-ideas-20260819.md`)
   + Junior's items/equipment reading of the difficulty gap.
10. **Corpus brief** (`docs/design-corpus/gamesmith/addenda/corpus-to-v18-evidence-brief-20260819.md`)
    — cited inside the R-A1/R-A2/R-A4 shapes; FLAGGED numbers never land
    in `data/` without re-verification.

**Owner queue (es-CR, entregada en el chat):** veredicto listo — la
DECIMOSÉPTIMA se cumplió y v18 CIERRA (las dos sesiones pasaron los
cuatro chequeos con los bytes en mano, y los dos dijeron por separado
que el mundo siguió) · lo que abre: los números congelados
(respawn/dificultad/provisiones) ya se pueden mover, y quedan anotados
9 items para el brainstorm — el lag va PRIMERO porque usted lo marcó
bloqueante · de su lado no queda nada pendiente del ritual: solo, cuando
quieran, el brainstorm de v19 (ustedes dos deciden el orden) y sus asks
de audio 5–9 cuando tenga calma.

**RESUME POINT:** the v19 brainstorm at the owners' word (dev proposes,
they decide the order) — or, if they name it first, the lag
instrumentation pass (item 1). Nothing else is owed.


## 2026-08-19/20 session 20 (hub, owner LIVE all night) — THE SEVENTEENTH RUNS: both ritual sessions + ANSWERS 8/8 banked · T2 importer+schema v2 SHIPPED all gates green · ninth EMPTY gate pre-ritual · adjudication = next fresh session

**Job 0: EMPTY (ninth, 21:10–21:16)** — re-check block in the skeleton
(`56440e4`); logs 31/31 newest 7461, save `8e94dcb8…`/s8 decode
`66784a92…`, Junior 0 past main, mail done/=7, answers 0/8 — then the
night moved. Audio-morning lane did NOT open (owner arrived asking for
the ritual instead; asks 5–8 remain owner-pending).

**T2 — world-builder importer + zone schema v2: SHIPPED, done-conditions
MET.** Commits: `3addeb8` schema v2 (TileMap v2 typed transitions +
`stairs_unlocked_by` hole-only (D4) + `floor:` + `regions:` (D9) +
`tile_types`; `Core::TileRegistry` v0 + `data/tiles.json` (D7, v0
wall law # ⇔ wall enforced); World cross-check wiring; +32 tests) ·
`a858227` importer `tools/import_ldtk.rb` (D2 sole door; EVERY T1
wrinkle a NAMED refusal: jsonVersion pin · realEditorValues tamper
tell · void/unknown IntGrid w/ cell coords · pivot/px/offset/worldXY
pins · identifierStyle+name shape · externalLevels · unknown
entity/field/layer · PackSpawn order law · tile overlap · unknown
transition target · sidecar contract · composed loader gate; emit =
canonical bytes, fixpoint test-enforced; fixture = REAL 1.5.3 vendor
bytes md5 `59363c…` + district sidecar; 41 tests, suite 908/0) ·
`.gitattributes` `*.ldtk -text` (v17 W6 EOL law) · spec amendments
D1/D2/D4 + findings addendum (worldX=-1 fold). **Verification: six
zones byte-identical (md5 sweep) · D12 sim-digest probe identical
(seeds 0/42 × 6000 ticks district combat) · canary ×2 byte-identical
vs PRE-change baselines · `rake gate` ×2 PASS (world_loop +
low_quay_run, receipts `tmp/t2_gates_receipt.txt` + gate-verdicts
log `fec8b06`).** T3 (safe tile behaviors) and T4 (pilot authoring)
wait post-verdict per lane order.

**THE SEVENTEENTH — the ritual RAN (owner-asked ~21:50; same-day pair
per amendment):**
- **Idle attempt 8444** (accidental close at hosting screen, ticks=0,
  world byte-unmoved) — classified, banked.
- **SESSION 1 (21:59→22:28):** host 74469 ticks · 0 desyncs · quit ·
  `66784a92`(s8)→`3a518bcc`(s9), disk verified; Junior seat-2
  `76fd4f0` verified (74470 ticks, handshake==host, **AUDIO ON →
  symmetric-novelty branch**). COMPLETE both seats.
- **SESSION 2 (22:51→23:10):** host 36079 ticks (bar+79) · 0 desyncs
  · quit · loads s1's close EXACTLY → `b5cae357`(s10), disk verified;
  owner ended ON the lag (verbatim HELD); Junior seat-2 `aba02af`
  verified (36079, handshake==`3a518bcc`, quit). COMPLETE both seats.
  **HALF A FULLY EVIDENCED** (4/4 netplay lines green, chain proven
  both sides, carried facts > 0).
- **ANSWERS 8/8 BANKED VERBATIM:** owner set 4/4 administered by THIS
  seat one-by-one (owner order "preguntame una por una" — amendment
  recorded; wording byte-virgin; R3 = the provisions counter-question
  recorded AS the answer; deviations named beside the set). Junior
  set 4/4 via his seat (`5f276ad`, Q1 same-day variant noted).
  **Post-8/8 the owed provisions/mark explanation was delivered
  (U/R sustain verb + altar wipe-insurance) — quarantine expired.**
- **Mode = FULL. Adjudication runs NEXT SESSION fresh** (r9 vehicle;
  T2-spark stop condition honored: bank + checkpoint → STOP). Caveats
  pre-attached: same-day spacing + symmetric audio novelty.
- **Owner live-drops banked along the way (`38a3ddb`…):** 7
  mid-session observations HELD verbatim · core-gameplay
  verdict-fragment ("me encanta … reactivo y conectado") · idea 7
  (enemies walk home) · idea 1 re-vote (ctrl facing) · idea 4
  addendum + lobber mid/late positioning · chat re-vote (parked,
  trigger widened "or some system") · M5a ask 9 (ranged-shot cue +
  MAQUETAS framing: library = mockup-tier by design, organic
  re-records = final-version lane) · E-skill classified from code
  (volley 35 dmg @ tiles 2/3/4 delayed 40f — legibility gap, NOT a
  defect; flywheel candidate post-verdict).
- **Lag = the night's defect star (`drafts/_netplay-lag-forensics-20260819.md`):**
  s1 host stalls 9807/13.2% max 1113 ms vs joiner 136 → HOST-side; s2
  stalls 5386/14.9% max **3341 ms** (spike-class; owner: "no se puede
  jugar" — severity = blocker, verbatim HELD); desyncs=0 all four
  lines (stalls ≠ divergence, told the owner); tailscale post-probe
  direct 165 ms CR↔BR; hypotheses ranked (DERP flap #0, focus
  throttle, host CPU) + instrumentation shape (stall-cause tags +
  tailscale sampler). **FIRST work item post-answers — still
  post-adjudication: it is code.**
- **Mail (done/=10):** assets family-block receipt (`258a62a`,
  md5==canonical — 4/4 family sync COMPLETE) · assets tile-era/style
  ack · audio v1.1 banked receipt (26/26 masters; 24→16 tie-policy
  note recorded in the M5a verdict — name it in any future
  re-conversion spark).

**Quarantine spot at close:** save md5 `edfebf4accf0abf3aa86bb1170c62714`
(mtime 23:10) decode `b5cae357290c01e464f49155bc7f9d13` sessions=10
banked=7 provisions=0 breached=2 boss_1_defeats=1 notices=[]; logs
34/34 both patterns (newest 9048 = ritual s2, CONSUMED/banked); Junior
tip = origin/main (his seat pushed `76fd4f0`/`aba02af`/`5f276ad`);
tmp/soak newest still `20260819-120805`; gate-verdicts tail = T2
spot-gate PASS entries (classified, `fec8b06`).

**RESUME POINT (fresh session): ADJUDICATION** — r9 Jobs 1–4 on the
spec's closed terms (Half-A table from the banked logs · Half-B all
eight verbatim + BOTH caveats + HELD side-signals AFTER · routing
table row-by-row · verdict → AGENTS.md line · v19 pool carry: 7 ideas
+ M5a deferred + flywheel findings + lag-first). Owner-pending: audio
asks 5–8 (mañana) · his 7 attack renders DONE · nothing else owed
from the humans — the ritual's player duties are COMPLETE.

## 2026-08-19 session 19 (hub, owner LIVE mid-session) — T1 LDtk spike: **GO** · wall receipt 18/18 · eighth EMPTY gate · owner drops banked (ZONE 7 reveal grammar + projection/style preview intake)

**Job 0:** wall `flywheel1-20260819` receipt CLOSED — **18/18 PASS,
zero failures** (`WALL SWEEP DONE 17:20:18 — 18 scripts, fails:
none`, tmp/wall_flywheel1.log; the s17 renderer fixes hold across the
full wall). Standing SEVENTEENTH gate: **EMPTY (eighth)** — dated
re-check block in the skeleton; logs 29/29 (newest `7196` consumed),
save md5 `30ff315dc36ee183c42eb040c08e6030` mtime 2026-08-18 22:36,
strict decode `digest=189a80723c87b90f27bc8436533d8cc1` sessions=6
banked=20 boss_1_defeats=1, Junior 0 past main (`junior/ci 057fb03`),
mail done/=7, answers 0/8. Quarantine RE-VERIFIED after the spike's
worktree walk: save md5+mtime unmoved.

**T1 — LDtk spike: GO** (findings:
`drafts/_ldtk-spike-findings-20260819.md`; T2 lands the pin into D1).
**LDtk 1.5.3 pinned** (pin on `jsonVersion` only — appBuildId churns
per resave, observed). Evidence tiers: schema both ways (generated
project loads+renders in the real GUI; LDtk re-saved through its own
writer) · round-trip semantic identity (throwaway importer → all 11
district keys equal, generated AND resaved bytes) · **in-game
byte-identity: 9/9 district_hunt frames md5-equal worktree-vs-real**
· pilot walk nest→district (ZONE 2 banner, 15 spawns at authored
tiles, combat live, clean quit; real save untouched; worktree
removed). 10 mapping wrinkles catalogued as T2 refusal cases — the
big one: **1.5.3 loads field values from `realEditorValues`, not
`__value`** (hit live). Sidecar contract proposed for non-spatial
scalars (T2 ratifies in D2 wording). UX read: pro-grade palette/
field editing, values render in-world; owner's own drawing session =
T4's true test.

**Owner drops (LIVE, banked — measurement hygiene untouched):**
1. **ZONE 7 reveal grammar** — New World Aeternum intro ingested
   (video verified frame-by-frame from 03:18; local
   tmp/nw_intro/) → `drafts/_zone7-reveal-intro-arc-20260819.md`:
   G1–G8 transferable grammar (color SCRIPT · overexposed threshold ·
   banner-at-vista · elevation==D3 floors · tension→release ·
   constriction earns opening · audio carries the cut · teach in quiet
   pockets) + owner chronology clarification RATIFIED (ours: BOSS 1
   BEFORE the reveal — reward-for-victory, Kakariko pattern). T4
   authoring implications listed; 2 renderer candidates RECORDED (not
   owed). Gamesmith mailed for full-pipeline treatment
   (`from-game-two-nw-intro-video-ingest.md`).
2. **Projection/style preview** — v19 intake **idea 5** (owner: iso
   "even more appealing", then "grimmer/realistic … HD Tibia/
   RavenDawn"): refs banked (`wb-gnomoria-iso-style.jpg` 5c965f63…,
   `wb-ravendawn-34-detail.png` 5215ea49… — KEY read: RavenDawn is
   3/4 top-down, NOT true iso; three independent dials
   projection/fidelity/tone). Spike shape: three projections side by
   side, same replay, owner's eyes pick; combat-clean law
   non-negotiable; sim untouched (8-dir already real,
   grid_walker.rb:76). Assets seat mailed the style signals.

**RESUME POINT:** T2 (importer + schema v2, FRESH session) with the
findings doc as input — D1 pin + sidecar wording land there.
**Session 19 grew a same-day AUDIO ARC after T1 closed (owner live,
all owner-directed):** ambient ear-check CLOSED ("me gusta como
suena!") = chain link #5 (log 6739, anchor → `9890bb5e…` s7) · the 7
attack renders EXECUTED same session in Reaper 7.79 (agent reascript
scaffolds: project + regions + MIDI gestures + matrix render; owner
VSTs; his anti-repetition takes: hit×4 dodge×8 wipe×4 throw×4 = 23
renders) → ingested sha-pinned + deterministic take rotation in the
bridge (`f228df8`, variants.json + VariantRotor, library untouched) ·
ambient v2: 3 owner drone variants → calm-family rotation, 1920-tick
cadence, bar crossfades (`3d20b93`) · ear-check 2 PASS ("se oye muy
bien!") = chain link #6 (log 7461, anchor → `66784a92…` sessions=8)
· 4 tuning asks banked for TOMORROW (M5a verdict asks 5–7 + ask 4
amended: ONE 32-bar evolving loop is the real intent — rotation is
tonight's interim) · near-miss recorded (owner cancelled a
fire-everything re-render with FX off; matrix rebound drone-only) ·
audio-seat provenance mail out (26 masters). Suite 835/0 at close.
Owner-pending now: the ritual when Junior is available · his 7
attack renders DONE · ear-check DONE · tomorrow's audio-tuning list
(asks 5–8). Never nag. The SEVENTEENTH still outranks everything the
moment its evidence appears.

## 2026-08-19 session 18 (hub, owner LIVE) — WORLD-BUILDER LANE opened, grilled, spec'd (D1–D12 + T1–T5), T1 spark staged; council consult folded; 3 sibling mails out; intake +2 ideas; ritual state UNTOUCHED

**Owner-directed day (same calendar day as session 17's flywheel
fixes; wall `flywheel1-20260819` still sweeping at close — 12/18 PASS,
zero failures; receipt harvest = next session's Job 0).** The owner
co-designed live in the hub chat; everything ratified is RECORDED:

- **Lane 3 opened (AGENTS.md `2471b5d`):** existing six-zone world =
  the game's INTRODUCTION ARC (owner framing); expansion via an
  authoring pipeline — LDtk front-end + strict importer + floors
  (typed transitions) + region layer + tile-type grammar (safe vs
  sim-class split). Live god-mode stays the staged later rung.
- **Grill CLOSED → spec CLOSED:**
  `docs/superpowers/specs/2026-08-19-world-builder-pipeline.md`
  (D1–D12 + tickets T1–T5; `fdc6c57` + amendment). Owner ratified:
  post-verdict merge law (D12) · one-way holes + same-day
  shortcut-unlock amendment (`stairs_unlocked_by` fact, D4) ·
  footsteps+ambience as first SAFE family (framed as polish; the
  aliveness bet = first hazard tile at the verdict gate, D8's
  10-minute rule) · pilot vision VERBATIM in the spec: ZONE 7
  (peaceful open zone) + TOWN 1 (houses/basements/depot-v0/slots) +
  THE WELL (drain = breach-family fact) → one-way hole → DUNGEON 1,
  gated on `boss_1_defeats ≥ 1` (Kakariko touchstone).
- **Council consult (2 asks, $0.01, receipts
  `tmp/council_ds_worldbuilder.json` / `tmp/council_qw_direction.json`,
  folds committed `f7120c5`):** 7 hardenings adopted (LDtk version
  PIN · wall-scales-by-SURFACE · no-cross-floor-effects law ·
  save-stays-facts-only · respawn-untouched-by-floors · no-runtime-
  variant-randomness · the 10-minute tile admission rule). REFUTEDs
  re-verified and named (audio-leak claim false — pure sink holds;
  "no juice" claim false — codebase disproves; hidden-instakill-tile
  pitch REJECTED on legibility law).
- **Sibling mails dispatched (informational, receipts expected):**
  assets (tile-sized modular sheets + per-tile material metadata
  constraint + owner style signals — CryoFall charm) · audio (two
  future cue families: footstep materials + region ambience; nothing
  owed) · lore (world grows, placeholder law unchanged). Assets
  repin receipt `from-game-two-assets-repin-1360b272` consumed →
  done/ (their baseline moved to `1360b27` clean).
- **Intake grew (equal peer standing):** idea 3 = CryoFall
  inventory/stats menu touchstone (+6 reference images banked
  untracked, md5s in the grill record) · idea 4 = leveling/XP +
  skill/spell system + level-gated world (WoW/TES framing; verified
  KB note `rpg-xp-curves-and-leveling-formulas` pre-staged; braids
  with items/backpack at the v19 brainstorm). PARKING_LOT banks:
  housing · dimensions/time · fishing family · live select-and-place
  god mode · ambient fauna · town system SLOTS.
- **Ritual state UNTOUCHED (measurement hygiene absolute):** anchor
  `189a8072…` (save md5 `30ff315d…`, sessions=6), answers 0/8,
  newest temp log `7196` CONSUMED, count 29/29. Nothing this lane
  ships touches the measured world until D12 fires post-verdict.

**RESUME POINT:** next dev session = **T1 spark**
`drafts/_wb-t1-ldtk-spike-spark-20260819.md` (wall receipt harvest +
compressed standing gate + LDtk spike → GO/NO-GO findings). Junior
pulls CURRENT main. Owner-pending unchanged (ambient ear-check · his
7 attack renders · the ritual when Junior is available) — never nag.
The SEVENTEENTH still outranks everything the moment its evidence
appears.

## 2026-08-19 v18 session 17 — SEVENTEENTH gate re-run (spark r9): EMPTY (seventh) — then flywheel job 1 EXECUTED: all 10 critique claims verified against code + exact frames, 3 renderer fixes SHIPPED behind the gate (+0 beat suppression · enemy strike tiles · possessed hurt vignette), 7 items RECORDED; wall sweep detached at close

**Mode: EMPTY at the gate (13:47–13:53, seventh — expected, ritual
owner-paced), then Job 6 owned the session per r9.** Gate findings
verbatim in the skeleton's seventh dated re-check block: launcher logs
29/29 (newest still `7196`, consumed), anchor `189a8072…` holds at
link #4 (save md5 `30ff315dc36ee183c42eb040c08e6030`, strict decode
sessions=6 banked=20 seals=2 marks=0), answers 0/8, Junior baseline
unchanged (`origin/main` == this seat's commits, `junior/ci` `057fb03`,
no drafts/paste), mail inbox EMPTY (done/ = 6 — assets family-sync
receipt still pending, their held seat), residue classified (trio
13:44 = `dde2039` hook rake; gate-verdicts log unchanged at gate time;
tmp/soak newest still `120805`). Re-verified at close (~15:3x):
logs/save/mail all still unmoved. Skeleton commit `37dc427`.

**Flywheel job 1 — critique verification pass (the sampling-artifact
law applied to all 10 claims; full table:
`drafts/_flywheel-verification-20260819.md`):**

- **EXISTS-SAMPLING-ARTIFACT:** #1 silent kills (kill pop verified
  live in frames v_001141/1143/1548/1551 — flash + shards + corpse +
  drop; the critique's cited windows were enemy MOVES, no deaths);
  #3 player attacks (SLASH found by pixel scan at v_001169/1170 —
  active=4 sim frames ≈ 7% catch rate at the critic's stride).
- **CONFIRMED-DEFECT (presentation):** #5 "+0" beats (mechanism:
  zone_entered force-resolve + kills-qualify + gained=0; economics
  INTENDED — the "-150" is `breach_cost_2`'s price tag; carried
  indicator already exists) — FIXED; #6 boss banner points at nothing
  (v_001497–1551) — RECORDED (R1, M effort, camera seam).
- **PARTIAL:** #2 damage attribution (telegraphs + crimson flicker +
  shake all EXIST; the real gap: `draw_attack` was pack-gated — enemy
  strikes rendered NOTHING) — gap FIXED, windup landing-preview
  RECORDED (R2, difficulty-adjacent); #8 zone-2 palette (contrast
  weak near tan walls, not "disappear") — RECORDED for the asset-era
  palette pass (R5); #9 taxonomy (grammar exists + walled) — RECORDED
  asset era (R6); #10 toast anchoring (the "toast" IS the designed
  player-anchored ledger panel; harm was the +0 instances — covered
  by fix 1) — placement question RECORDED for the brainstorm (R7).
- **SIM-CLASS, RECORDED (v19 pool, frozen while the ritual pends):**
  #4 knockback (EXISTS as attacker kit stat by design — blocker 1/2,
  striker special 1) (R3); #7 pursuit (partly the pressure-stance
  system working — outlines visible in v_004081–4130) (R4).

**Fixes SHIPPED (renderer-only, digest-blind; each own commit +
blocking Rule 2 gate on `low_quay_run`):**

1. `48cf0db` +0 beat suppression (`Renderer.silent_beat?` pure +
   6 tests; wipe recaps untouched). Gate: first run's critic FAILed
   `possession_ring_moves` on a FACTUALLY WRONG claim (frame_1457
   rings the rust blocker, frame_2750 the ember striker — verified by
   eye; the check had never failed in 434 logged runs; a pre-fix
   worktree replay proved only 3 frames changed, all +0-panel
   removals) → gate RE-RUN standalone: determinism 11/11 + vision
   PASS, the re-run critic naming the same two frames correctly.
   Critic nondeterminism, not a regression — the gate decided.
2. `abc9f53` possessed hurt vignette (thin crimson edge frame during
   the existing 8-frame hurt window; keys `hurt_vignette_px`/`_alpha`
   in display.json). Gate PASS.
3. `1360b27` enemy strike tiles (hostile-red flash on the enemy's
   action tiles, active window only; own pass after both body loops).
   Gate PASS.

**Re-check on the re-cut clip (deterministic,
`clip_low_quay_run_20260819-152230`, 4306 frames):** all three +0
sites CLEAN (v_000729/2492/3836) · "+6" control INTACT (v_001565) ·
strike tiles + vignette pixel-verified at the t=13.47 hit
(v_000404–407: strike px 68→1196, vignette spans exactly the 8-frame
hurt window; frame v_000405 shows attacker ring-strike + all-edge
vignette + body flicker in ONE frame). Table + receipts in the
verification doc (`4148f52`).

**Wall sweep `flywheel1-20260819` DETACHED at close** (18 scripts,
~90 min; log `tmp/wall_flywheel1.log`; renderer changes re-judge every
visual surface). Judge per memory law: per-script rc lines, re-run any
disrupted gate standalone. `drafts/_gate-verdicts.log` grew this
session from MY runs (4 gate runs + the wall) — self-classified, not
live-session evidence; commit it at a future close, never mid-wall.

**v19 intake:** nothing arrived (file stays at 2 ideas). Soak/side
lanes: no new runs, no mail. Bedrock spend: $0 (no re-critique — the
owner can ask for the scored comparison when he wants it).

**Quarantine spot (unchanged):** save md5
`30ff315dc36ee183c42eb040c08e6030`, digest `189a8072…`, sessions=6,
newest temp log `7196` (CONSUMED), count 29/29. Answers 0/8.

**RESUME POINT:** ritual session 1 RE-RUNS owner-paced — **Junior now
pulls ≥ `1360b27`** (three renderer commits moved tree content —
same-commit handshake law; host `loaded` must equal `189a8072…`).
Owner-pending (never nag): (a) ambient ear-check (his next solo
listen = chain link #5), (b) his 7 attack renders (spec staged),
(c) the ritual when Junior is available. Next dev session: harvest
the wall receipt first (`tmp/wall_flywheel1.log`), then the standing
gate per the r9 spark (or its successor).

## 2026-08-19 v18 session 16 — SEVENTEENTH gate re-run (spark r8): EMPTY (sixth) — then OWNER-DIRECTED PIVOT live: crash-class audit CLEAN + ritual-length soak PASS 3/3 + audio retune executed (asks 1+3) + attack-cue spec drafted (ask 2); ritual re-run still owner-paced

**Mode: EMPTY at the gate (08:20–08:24), then the owner redirected the
session live** (es, verbatim in the skeleton's owner-direction block):
"juega en automático mientras tanto … debemos seguir avanzando,
depurando y mejorando" + "no te cierres ni te limites, nosotros somos
dueños de este proyecto". The dev-side tuning freeze is LIFTED by owner
order (M5a-override precedent); measurement hygiene stands (questions
virgin, bot logs never evidence, verbatim harvest). Second half of the
session, all receipts committed:

- **Gate result (unchanged):** sixth EMPTY — 29/29 logs (newest `7196`
  CONSUMED), anchor `189a8072…` holds at link #4 (md5
  `30ff315dc36ee183c42eb040c08e6030`, strict decode sessions=6
  banked=20 seals=2 marks=0), answers 0/8, Junior tip `b155bcb`, mail
  empty, residue classified (trio 08:17 = `86c5748` hook rake;
  gate-verdicts log unchanged; no new soak pre-pivot). Commit `2786754`.
- **Crash-class audit CLEAN:** every `possessed` deref site checked
  (controls_overlay guard, save_state nil-by-design, renderer `&.`,
  world.rb `next unless body`, audio bridge reads only `world.frame`,
  netplay_overlay computes no_body) — the b6c110f site was the ONLY
  unguarded one. No sibling defects; nothing to fix.
- **Soak PASS 3/3 at ritual length** (`tmp/soak/20260819-084538`,
  N=3 TICKS=36000 SEED=20260819, autopilot exercises interact/swap/
  sustain — the crash-class path re-exercised on the fixed build):
  all six netplay lines desyncs=0 reason=quit ticks≥36116; bot save
  chain intact `fresh → 56913068 → 33ecfc93 → 40bc50e9` sessions 1→3;
  quarantine verified (real save md5 + temp-log count unmoved, guard
  clean before/after). Bot evidence — never oracle input.
- **Audio retune EXECUTED (owner asks 1+3, data-only, `d91281a`):**
  calm ambient → the owner's own `msfx_drone_4s` (unplaced render, 4 s
  = 2 bars bar-exact); stem gains 4.0→2.0 (−6.02 dB interim until his
  Reaper re-render). AudioData.load validated + suite green (the
  bridge test loads the edited tables through the real DLL). Owner
  ear-check PENDING his next session (listen-verdict precedent).
- **Attack/effects cue spec DRAFTED (ask 2):**
  `drafts/_audio-cue-spec-attacks-20260819.md` — 7-render Reaper list
  (es-CR) handed to the owner in chat + ready mapping rows
  (payload-blind, one cue per event, all events verified on the bus).
  Blocked only on his renders.
- **Ritual caveat addendum (skeleton owner-direction block):** the
  re-run now carries the retuned audio — rides the SAME pre-registered
  audio-novelty caveat; Junior's AUDIO line still decides the branch.
- **Gamesmith round-5/6 banking EXECUTED (owner-pasted spark-up,
  sibling-delivery rules satisfied):** threads doc copied
  byte-identical (addenda, untracked, md5 `a044f986…` verified) +
  provenance bullet; PARKING_LOT +2 entries (round-5 threads `34c9939`,
  round-6 pointer `4bebc37`); priming quarantine held (copy without
  consumption); RECEIPTs handed to the owner in chat. SEVENTEENTH
  observation for their round 7: pending, fired-rows none.
- **Deterministic clips CUT (flywheel lane 2 live):** VIDEO_EVERY
  bridge committed `1917cca`; moving_square smoke + world_loop (21 s)
  + varekka_duel (45 s) + low_quay_run (144 s) in `captures/clips/`
  (gitignored media).
- **First self-eval critique BANKED (≤$5 pilot, spend rails held):**
  `drafts/_self-eval/clip_low_quay_run_20260819-104223_critique.md` —
  readability 5 / juice 4 / fluidity 7 / loop 7; strengths (identity
  layer, hit-flash, death ledger, loop cadence) + 10 ranked issues
  with timestamps + a re-check list keyed to the SAME script.
  **Tool lesson (verified live): the critic saw ~160 of 4306 frames —
  brief effects escape it; its #1 finding ("kills evaporate silently")
  is at least partly sampling artifact — kill_pop EXISTS (5-frame
  flash, `data/display.json`). Law: every critique claim is VERIFIED
  against code + a dense clip before becoming a work item; renderer
  fixes (digest-blind) may ship this era under the owner's lift,
  sim-touching fixes (knockback/telegraph/pursuit AI) are v19-class.**
- **Zone-coverage soak run 1 (seeded, SOAK_AUDIO, one zone per
  episode): POWER CUT mid-EP4** (run `tmp/soak/20260819-105759`).
  Post-crash protocol: HEAD==origin, real save md5 `30ff315d…` intact,
  temp logs 29/29, no zombie processes. chain_check on the partial:
  **EP1 nest PASS (fights=0, hub-exempt by design) · EP2 district PASS
  (fights=4 wipes=1 carried_lost=1 sustain used=3 — first bot
  provision use ever) · EP3 district_two PASS (fights=2 wipes=2) · EP4
  camp FAIL named (no netplay line = the power cut, not the game)**.
  The coverage lane WORKS — first bot combat in soak history.
  Remaining zones (camp, low_quay, slow_door) relaunched fresh.
- **Assets audio-v1 exports delivery BANKED on hash (seat mail,
  post-cut):** seven sha256s verified bit-exact from this seat (assets
  `811031c`); ZERO in-tree change (same renders already pinned under
  `data/audio/files/`); LUFS report-only heads-up recorded (M5a
  verdict §Mails: calm/combat/stinger/ping below KB bands, drone in
  band — consistent with the owner's +12 dB/−6 dB asks); level
  questions route audio-repo/owner, game-two never compensates. Mail
  → done/.

**Quarantine spot (unchanged):** save md5
`30ff315dc36ee183c42eb040c08e6030`, digest `189a8072…`, sessions=6,
newest temp log `7196` (CONSUMED), count 29/29. Answers 0/8.

**RESUME POINT:** session 1 RE-RUNS owner-paced on the retuned build
(Junior pulls ≥ `d91281a` now — same-commit handshake law; host
`loaded` must equal `189a8072…`). Vehicle: r8 spark + this entry.
Owner-side pending: (a) ear-check of the new ambient (his next play,
any time), (b) the 7 Reaper renders (his pace — spec in the drafts
file), (c) the ritual when Junior is back.

## 2026-08-19 v18 session 15 — SEVENTEENTH gate re-run (spark r7): EMPTY (fifth) — expected (the crashed attempt closed 00:06 the same night; session-1 RE-RUN owner-paced); s14 wall verdicts banked (out-raced the close commit); cycle owner-paced

**Mode: EMPTY** (vehicle: r7 spark
`drafts/_v18-seventeenth-harvest-spark-r7-20260819.md` — still the
standing vehicle for the next gate). Gate ran 05:04–05:1x, hours after
the crashed session-1 attempt (00:06); zero new evidence is the
expected state, not a stall. Findings verbatim in the skeleton's fifth
dated re-check block:

- **Launcher logs:** 29/29 both temp-dir patterns, newest still
  `game_two_session_7196.log` 00:06 = the crashed attempt (CONSUMED
  s14); zero `AUTOPILOT` lines anywhere; only coop console remains the
  banked `20260818-234037` one.
- **Quarantine holds (link-#4 values — crash saved nothing):**
  `saves/world.json` md5 `30ff315dc36ee183c42eb040c08e6030` mtime
  22:36; strict decode (pinned shape) LOADED
  `digest=189a80723c87b90f27bc8436533d8cc1` sessions=6 banked=20
  seals=2 marks=0 boss_1_defeats=1 provisions=0 notices=[]. Ritual
  session-1 host `loaded` expectation stays `189a8072…`.
- **Junior side:** tip `b155bcb` (crash receipt, in main), nothing
  past main on any ref, no new draft, no paste. **Answers 0/8.** Seat
  mail inbox empty (done/ only) — no audio/assets receipts.
- **Residue classified:** `_gate-verdicts.log` +18 entries
  00:47:14→02:29:01 = the s14 PAID wall (17 in-sweep + the standalone
  low_quay re-gate PASS at 02:29:01; teed logs
  `tmp/wall/*_seventeenth-20260819.log`) — the entries out-raced the
  `6a3e1f3` close commit (02:31:11), committed THIS session as
  banking. Desync trio rewritten 02:31 = that commit's hook rake
  (`platform:"test"`, `dddd…`/`cccc…` verified in-file). tmp/soak:
  newest report = the s8 report itself (15:16:05.122993 — fractional
  boundary vs the ≤ 15:16:05 baseline wording, same file, consumed
  s8) — Job 5 empty.
- **v19 intake:** nothing arrived — `drafts/_junior-v19-ideas-20260819.md`
  stays at idea 1 (BANK).

**RESUME POINT:** unchanged from s14 — session 1 RE-RUNS owner-paced
(Junior pulls ≥ `b6c110f` first; host `loaded` must equal
`189a8072…`; both-seats AUDIO lines read VERBATIM at harvest —
Junior's line decides the Half-B caveat branch). Vehicle: the **r8
spark** (`drafts/_v18-seventeenth-harvest-spark-r8-20260819.md`,
supersedes r7; handed to the owner via clipboard). Priming quarantine
in force until all eight answers are in. Audio asks + Ctrl-facing idea
stay RECORDED lanes; `data/audio/**` frozen.

**Post-close addendum (same morning, hub chat):** two sibling
deliveries banked — (1) assets-seat reply (`7e9b252`): audio-v1 ingest
is their NEXT spark, no blocker; delivery contract (absolute paths +
sha256s, consume on hash) recorded in the M5a verdict doc §Mails; mail
moved to done/. (2) gamesmith corpus→v18 evidence brief (`112036a`,
owner-approved spark-up executed per its own rails): PARKING_LOT +2
entries (session-ledger shape + pointer), untracked addenda copy
md5-verified `23c64c85…` + provenance bullet; fork-evidence for
F1/F3/F5/F6/F7, consumed POST-adjudication at position-decision time,
priming-quarantined meanwhile. Seat-lease lesson recorded in the r8
spark: file-ops sourcing from a LIVE sibling tree trip the guard —
read tool → write tool + md5 arbiter.

## 2026-08-19 v18 session 14 — SEVENTEENTH gate (spark r6): PARTIAL — ritual session 1 ATTEMPT crashed BOTH seats (telemetry nil-possessed at :banked); fix SHIPPED `b6c110f` + wall PAID; three owner audio asks recorded; v19 intake OPENED; session 1 RE-RUNS owner-paced (vehicle: r7 spark)

**Mode: PARTIAL** (vehicle: r6 spark `drafts/_v18-seventeenth-harvest-spark-r6-20260819.md`).
Gate at 23:37 ran EMPTY as expected pre-ritual (28/28 logs, anchor
`189a8072…` held, answers 0/8, mail empty, no soak) — then the night
produced real evidence:

- **Live launch per protocol** (owner "procede por favor"): guard
  printed 0 · pull clean at `dfc7697` · detached host 23:40:37 (PID
  8692, console `tmp/coop_console_20260818-234037.log`). Junior joined
  — his handshake PASSED on the audio-on build.
- **CRASH ~00:06, BOTH seats, lockstep-symmetric:** `NoMethodError
  nil.hp` at `src/game/telemetry.rb:190` — the `:banked` margin
  sampler dereferenced `possessed` while seat 1 was WAITING FOR BODY
  (v17 decision 3) and a bank fired. Joiner: same line in HIS tick +
  rejoin retries died `IO::TimeoutError session.rb:143` (host dead —
  correct refusal); his receipt = commit `b155bcb` (logs stay on his
  machine, pointers there; he correctly shipped no fix). Host evidence
  banked md5-identical in `drafts/_v18-seventeenth-evidence/`:
  `game_two_session_7196.log` (`34cb7e3a…`) + console (`aae11808…`).
  **Classified: unclean attempt (`loaded` without `saved`), world
  UNMOVED — session 1 RE-RUNS, owner-paced.** Skeleton carries the
  full block; the attempt DID prove host loaded the anchor exactly +
  joiner digest-matched at handshake.
- **Fix (tripwire: small + mechanical, TDD red-green): `b6c110f`** —
  nil-guard in the sampler (fleshless seat samples hp=0.0), regression
  test reproduces the exact live trace; suite 811/17035; pushed.
  **Junior must pull ≥ `b6c110f` before rejoining** (same-commit
  handshake law) — relayed in the owner queue.
- **Wall debt PAID, tag `seventeenth-20260819`:** 17/18 PASS in-sweep;
  `low_quay_run` gate_rc=1 was a DISRUPTION (this session's 2400s
  bash-call timeout killed the vision critic mid-gate — `Command
  failed with status ()`; determinism 11/11 + manifest PASS already
  printed) → re-gated standalone: `GATE PASS`. Lesson appended to
  project memory (wall runs DETACHED, never under a call timeout;
  judge disrupted gates by re-running).
- **Three owner audio asks RECORDED** (verbatim,
  `drafts/_m5a-verdict-20260818.md` §post-close): smoother ambient ·
  attack/effect cues · main-theme instruments −6 dB. Frozen surface —
  audio lane, post-adjudication. "Too repetitive"/"too high"
  fragments + "it was fun" (crash report) HELD in the skeleton
  side-signals — pre-questions, enter only WITH the answer sets.
- **v19 intake OPENED:** `drafts/_junior-v19-ideas-20260819.md` —
  idea 1 (Tibia Ctrl+direction stationary facing, Junior via owner,
  owner "approved" the handling) triaged BANK with a next-spark shape
  (input-layer FACE intent, lockstep-additive, S effort). v19 stays
  CLOSED until adjudication.
- **Junior receipts processed:** `168f28d` (audio setup COMPLETE
  pre-ritual) + `b155bcb` (crash receipt). His seat proved `AUDIO on`
  capable at the attempt boot — the Half-B caveat branch still reads
  from his RE-RUN log at harvest, never assumed.

**Quarantine spot:** save md5 `30ff315dc36ee183c42eb040c08e6030`,
strict decode `digest=189a80723c87b90f27bc8436533d8cc1` sessions=6
banked=20 seals=2 marks=0 boss_1_defeats=1 (crash saves nothing —
anchor UNCHANGED at link #4); newest temp log
`game_two_session_7196.log` (00:06, CONSUMED); count 29/29 both
patterns. Answers 0/8.

**RESUME POINT:** session 1 RE-RUN owner-paced (Junior pulls ≥
`b6c110f` first — stale seat = named refusal; host session-1 `loaded`
expectation stays `189a8072…`). Vehicle for the next dev session: **r7
spark** `drafts/_v18-seventeenth-harvest-spark-r7-20260819.md` (also
handed to the owner via clipboard at his ask) — carries the crash-era
rules (unclean-attempt precedent, crash protocol, detached-wall law,
audio-asks freeze, v19 intake file). Priming quarantine in force until
all eight answers are in.

## 2026-08-18 v18 session 13 — SEVENTEENTH evidence gate re-run (spark r5): EMPTY (fourth) — expected by the calendar (ritual is TOMORROW); baseline-29 tally slip resolved NAMED (disk truth 28); cycle owner-paced

**Mode: EMPTY** (harvest vehicle: r5 spark
`drafts/_v18-seventeenth-harvest-spark-r5-20260819.md`, committed
`51814f3` at session-12 close — still the standing vehicle). Gate ran
22:47–22:56, nine minutes after the r5 commit; the owner-amended
ritual (same-day pair allowed) is scheduled for 2026-08-19, so zero
ritual evidence is the expected state, not a stall. Findings verbatim
in the skeleton's fourth dated re-check block:

- **Launcher logs:** 28/28 both temp-dir patterns, newest still
  `game_two_session_6240.log` 22:36 = solo chain link #4 (banked
  s12); zero `AUTOPILOT` lines in any launcher log. **Baseline slip
  resolved:** r5's "29 per temp dir" (from the s12 checkpoint)
  double-counted `6508` — link #1 was already inside s11's 23;
  23 + 5 new s12 logs = 28. All 28 classified, none missing, none
  unconsumed.
- **Quarantine holds (link-#4 values):** `saves/world.json` md5
  `30ff315dc36ee183c42eb040c08e6030` mtime 22:36; play-path strict
  decode (pinned call shape) LOADED
  `digest=189a80723c87b90f27bc8436533d8cc1` sessions=6 banked=20
  seals=2 marks=0 boss_1_defeats=1 — anchor exactly where link #4
  left it. Ritual session 1's host `loaded` expectation stays
  `189a8072…`.
- **Junior side:** no commit past `057fb03` (2026-08-16), no new
  `_junior-*` draft (newest 15:58 soak return, consumed s8), no
  paste. **Answers 0/8.** Seat mail inbox empty (done/ only) — no
  audio/assets receipts.
- **Residue classified, laws held:** desync trio rewritten 22:46 =
  the `51814f3` r5-spark commit's pre-push hook rake (commit
  22:45:51); `_gate-verdicts.log` unchanged since 17:11; tmp/soak
  reports all ≤15:16:05 — no overnight run (Job 5: nothing to read).

**Job 6 (v19 intake):** nothing arrived — slot stays open (banks
verbatim to `drafts/_junior-v19-ideas-<date>.md` + Itexo-style triage
when it lands; bundled-with-answers arrivals get SPLIT).

**Close:** docs-only; suite green via commit hooks. No code, no wall
owed. Skeleton gained the dated session-13 re-check block (incl. the
audio-era log rules note for the harvest); adjudication still EMPTY,
gaps 1–8 unchanged; oracle surface untouched.

**RESUME POINT:** ritual TOMORROW (2026-08-19, same-day pair allowed):
owner hosts, Junior joins (pull first — his seat prints `AUDIO off`,
plays silent); host session-1 `loaded` must equal `189a8072…`. When
both sessions + all eight answers exist, the FULL harvest runs the r5
spark. Sessions without answers = PARTIAL: bank verbatim + hand the
owner run-sheet POINTERS (wording stays virgin). Owner asks to play
mid-session → r5's live-launch protocol (single-instance guard FIRST
in a separate call judged by printed output, no `--fresh`, detached
launch, judge by the log at close, priming quarantine while answers
pend).

**Addendum (same night, ~23:00 — owner order live in chat): Junior's
seat goes AUDIO ON for the ritual.** Owner verbatim (es): "yo quiero
que él tenga el audio on y los assets que creamos ya en la versión de
él para que lo testee" — recorded as owner amendment 2 in the skeleton
(caveat 2 amended: symmetric novelty if his boot lands; original
asymmetry stands if his console prints `AUDIO off/refused` — his log's
AUDIO line decides at harvest, never assumed). No game-two code change
(the bridge boots audio on every human seat; only the sibling library
checkout was missing on his machine). Shipped: JUNIOR.md §"Som no
jogo" (pt-br setup: clone `game-two-audio` beside the game +
`bundle install`; ffi prebuilt in the lock); runsheet amendment
paragraph updated (both-seats sound, which-caveat-applies rule);
AGENTS.md scope line "host-only sound" → both-seats-by-order. Both
repos verified PUBLIC (no access grant). **Origin bootability PROVEN:**
fresh `--depth 1` clone of audio origin/master (`c1123af`) booted the
bridge noDevice — `AUDIO on: device=0 sha=15f03e0219d6` + clean
teardown, verbatim in the skeleton. Receipt mailed to
`mail/game-two-audio/from-game-two-junior-audio-distribution.md` (their
no-second-copy law holds: Junior gets a checkout of THEIR repo; DLL
never copied into game-two). Oracle surface: TELEMETRY/bin/play*/
questions/`data/**` untouched; JUNIOR.md + runsheet + AGENTS.md edits
are the owner-ordered amendment, recorded NAMED here and in the
skeleton. **Junior's side NOW PENDING: the one-time audio setup before
tomorrow's ritual (owner relays; steps in his doc).** Ritual-morning
contingency (recorded here, relayed in the queue): `origin/junior-tibia`
is DELETED — if Junior's local branch still tracks it, his `git pull`/
`join-coop.cmd` pull fails → fix is `git switch main` + `git pull`
(ten seconds, no doc needed). JUNIOR.md's collaboration section still
says clone `-b junior-tibia` / never-push-main — STALE since the
mainline promotion; recorded as post-adjudication cleanup (frozen
surface, not tonight's order). **Timing shift (~23:05, owner live):
"en vez de mañana que sea hoy" — the ritual runs TONIGHT; Junior
waiting; owner relayed the corrected setup message himself. Sessions
may straddle midnight — the spacing caveat reads spacing, not the
calendar line. Next vehicle: r6 spark
(`drafts/_v18-seventeenth-harvest-spark-r6-20260819.md`).**

## 2026-08-18 v18 session 12 — M5a AUDIO INTEGRATION SHIPPED same night (owner override + owner-originals order); ritual moved to TOMORROW (same-day pair allowed); four solo chain links banked; anchor now 189a8072

**Owner overrides (both verbatim in the skeleton + runsheet):** (1)
"integrate the audio now", ritual → tomorrow, "2 sessions in a single
day" (spec oracle amended; Half-B caveats pre-registered: same-day
spacing + audio novelty/asymmetry; Junior Q1 premise variant authorized).
(2) "replace all possible placeholder audios ... only use the intended
originally created ones" — executed same night.

**M5a shipped (commits `822a7a5`…`1443325`+, all pushed):** audio bridge
+ boot seam per contract §3 (SDL dummy at process entry; ONE engine;
vendor-sha law at boot; optional — absent/mismatch/bot = named line +
silent game; Junior's seat unchanged); PURE SINK proven mechanically
(StateDigest windows identical with/without audio); table custody moved
GAME-SIDE (`data/audio/`), owner-approved v1 six-event mapping +
data-driven music derivation (`state_events`); ALL SEVEN owner Reaper
renders sha-verified → 24→16-bit converted → manifest-pinned — ZERO
placeholder tones in the runtime path; +12 dB owner pass (gain 4.0).
Owner listen verdicts (4, verbatim in `drafts/_m5a-verdict-20260818.md`):
ear-check PASS · tones = "generic placeholder" FAIL · "too low ...
12+dB" · **"acceptable for now"** = M5a verdict of record. Suite 810
runs / 17031 assertions green; wall not run — REASONED: no wall script
executes App::Window/main.rb/cli.rb (harness has its own runner; header
law), no visual surface touched; determinism evidence = the pure-sink
digest test.

**Incident (recorded NAMED, skeleton links #2a/#2b):** double-launch —
$?-after-a-pipe masked a failed pre-launch tasklist; two instances, both
clean-quit, chain forked at `602e94bb…`, survivor `822b2e98…`, no fact
loss. Fix: single-instance check judged by printed output.

**Chain (all logs md5-banked in `drafts/_v18-seventeenth-evidence/`):**
#2a orphaned `38f1bc62…` · #2b `602e94bb→822b2e98` (sessions=4) · #3
`822b2e98→c4b8df2b` (5) · #4 `c4b8df2b→189a8072` (6). **Ritual session
1 host `loaded` expectation = `189a80723c87b90f27bc8436533d8cc1`**; save
md5 `30ff315dc36ee183c42eb040c08e6030`. Scratch-save drift run
(`game_two_session_5949.log`, fresh sessions=1 on tmp — NOT a chain
link). Newest temp log `game_two_session_6240.log`; count 23+6=29.

**Clock drift (contract §3 item, CLOSED as measured):** ≈800 frames/s
linear, replicated 2× (−48000/−49920 @ 90 s) — anchor fix flagged to
the audio seat WITH numbers (their custody; re-anchor clause
load-bearing). Audible impact: none named.

**Mails:** assets status ask (LUFS lane = recorded debt) · audio
cue-spec r2 (custody change + drift numbers; r1 cue ask WITHDRAWN) ·
audio listen-verdict (4 verbatims). Deferred, recorded in the verdict
doc: LUFS lane · anchor fix · drone/swarmpip placement · spatial
payloads · 44-row iteration · level tuning.

**RESUME POINT:** ritual TOMORROW (same-day pair allowed): owner hosts,
Junior joins (pull first — his seat prints `AUDIO off`, plays silent);
harvest per the r4 spark; host session-1 `loaded` must equal
`189a8072…`; adjudication carries the pre-registered caveats. v19 still
closed until the SEVENTEENTH adjudicates (M5a was the one owner-ordered
exception).

## 2026-08-18 v18 session 11 — SEVENTEENTH evidence gate re-run (spark r4): EMPTY (third) — nothing new past solo link #1; AUDIO ORDER LIFTED handled docs-only (integration QUEUED behind the SEVENTEENTH); cycle owner-paced

**Mode: EMPTY** (harvest vehicle: r4 spark
`drafts/_v18-seventeenth-harvest-spark-r4-20260818.md`, committed
`74fb3b8` — still the standing vehicle for the next re-run). Full
inventory 21:24–21:33, findings verbatim in the skeleton's third dated
re-check block:

- **Launcher logs:** 23/23 both temp dirs (== r4 baseline), newest
  still `game_two_session_6508.log` 18:00:31 = solo chain link #1
  (banked session 9); zero `AUTOPILOT` lines in any launcher log —
  zero ritual sessions, zero new solo links.
- **Quarantine holds (post-link values):** `saves/world.json` md5
  `213076c540cc9eed846172748aae2e10` mtime 18:00:31; play-path strict
  decode (pinned call shape) LOADED
  `digest=602e94bbf7d417d845c73e3702fd4675` sessions=3 banked=20
  seals=2 marks=3 boss_1_defeats=1 — anchor exactly where link #1 left
  it. Ritual session 1's host `loaded` expectation stays `602e94bb…`.
- **Junior side:** no commit past the 2026-08-16 `origin/junior/ci`
  tip (`057fb03`), no new `_junior-*` draft (newest 15:58 soak return,
  consumed s8), no paste. **Answers 0/8.**
- **Residue classified, laws held:** desync trio rewritten
  21:21:52–21:22:01 (`platform:"test"`/`dddd…` verified in-file) =
  the `74fb3b8` r4-spark commit's pre-push hook rake (commit
  21:21:17); `_gate-verdicts.log` unchanged since 17:11.

**Seat mail (game-two-audio): AUDIO ORDER LIFTED — handled, docs-only.**
Trail verified live before acting: owner verbatim "audio order lifted"
at game-two-audio `drafts/_m4-owner-scores.md:148` (md5
`d740e9ad1377947e413f370e8522bb1b`), commit `69b73ec`; readiness-doc
TREE md5 `8b45b82ecea03419a9a3cfa27d4e695d` == the mail's declared
foreign-edit state (committed version at `69b73ec` stays authoritative
for the future session). **Ask 1 DONE:** AGENTS.md OUT-list entry +
orchestration line updated (lift recorded, still out of v18);
PARKING_LOT.md gained the queued-integration entry — **named trigger:
the SEVENTEENTH adjudicates** (the owner lifted the audio ban, not the
nothing-new-starts law). **Ask 2 (bounded integration session) NOT
started — queued.** Receipt mailed to `mail/game-two-audio/`; inbox
mail moved to `done/`. Oracle surface untouched by all of it.

**Job 5 (soak side harvest):** no `tmp/soak/*/report.txt` newer than
15:16:05 (session-8's own validation) — the overnight one-liner still
hasn't been run. Nothing to read, no tripwire, no code touched.

**Job 6 (v19 intake):** nothing arrived (no paste, no drafts file, no
commit) — slot stays open; banks verbatim to
`drafts/_junior-v19-ideas-<date>.md` + Itexo-style triage when it
lands; bundled-with-answers arrivals get SPLIT (answers → skeleton,
ideas → intake).

**Close:** docs-only; suite green via commit hooks (tally in the
commit run). No code, no wall owed. Skeleton gained the dated
session-11 re-check block; adjudication still EMPTY, gaps 1–8
unchanged; oracle surface untouched.

**RESUME POINT:** unchanged — ritual sessions owner-paced; when both
sessions + all eight answers exist, the FULL harvest runs the r4 spark
(`drafts/_v18-seventeenth-harvest-spark-r4-20260818.md`). Sessions
without answers = PARTIAL: bank verbatim + hand the owner the
run-sheet POINTERS for the asking step (wording stays virgin). Owner
asks to play mid-session → r4's live-launch protocol (no `--fresh`,
detached launch, judge by the log at close, priming quarantine while
answers are pending). Junior's side: nothing pending. FIRST item after
adjudication closes: the audio integration session (PARKING_LOT
trigger, owner-paced) alongside whatever the routing walk records.

## 2026-08-18 v18 session 10 — SEVENTEENTH evidence gate re-run (spark r3): EMPTY — nothing new past solo link #1; PARTIAL/STANDBY holds, cycle owner-paced

**Mode: EMPTY** (harvest vehicle: r3 spark
`drafts/_v18-seventeenth-harvest-spark-r3-20260818.md`, committed
`0aaa986` at session-9 close — still the standing vehicle for the next
re-run). Full inventory 20:39–20:43, findings verbatim in the
skeleton's new dated re-check block:

- **Launcher logs:** 23/23 both temp dirs (== r3 baseline), newest
  still `game_two_session_6508.log` 18:00:31 = solo chain link #1
  (banked session 9); zero `AUTOPILOT` lines in any launcher log —
  zero ritual sessions, zero new solo links.
- **Quarantine holds (post-link values):** `saves/world.json` md5
  `213076c540cc9eed846172748aae2e10` mtime 18:00:31; play-path strict
  decode LOADED `digest=602e94bbf7d417d845c73e3702fd4675` sessions=3
  banked=20 seals=2 marks=3 boss_1_defeats=1 — the moving anchor sits
  exactly where link #1 left it (every save move has its matching
  banked log; no anomaly). Ritual session 1's host `loaded`
  expectation stays `602e94bb…`.
- **Junior side:** no commit past the 2026-08-16 `origin/junior/ci`
  tip (`057fb03`, ancestor of main), no new `_junior-*` draft (newest
  15:58 soak return, consumed s8), no paste. **Answers 0/8.**
- **Residue classified, laws held:** desync trio rewritten 20:38:06–09
  (`platform:"test"` fingerprints) = the `0aaa986` spark commit's
  pre-commit/pre-push hook rake (commit 20:37:34);
  `_gate-verdicts.log` unchanged since 17:11.

**Job 5 (soak side harvest):** no `tmp/soak/*/report.txt` newer than
15:16:05 (session-8's own validation) — the overnight one-liner still
hasn't been run. Nothing to read, no tripwire, no code touched.

**Job 6 (v19 intake):** nothing arrived (no paste, no drafts file, no
commit) — slot stays open; banks verbatim to
`drafts/_junior-v19-ideas-<date>.md` + Itexo-style triage when it
lands; bundled-with-answers arrivals get SPLIT (answers → skeleton,
ideas → intake).

**Close:** docs-only; suite green 804 runs / 17005 assertions, 0
failures. No code, no wall owed. Skeleton gained the dated session-10
re-check block; adjudication still EMPTY, gaps 1–8 unchanged; oracle
surface untouched.

**RESUME POINT:** unchanged — ritual sessions owner-paced; when both
sessions + all eight answers exist, the FULL harvest runs the r4
spark (`drafts/_v18-seventeenth-harvest-spark-r4-20260818.md` —
supersedes r3 with the s10-close baselines, the residue-correlation
baseline and the pinned strict-decode call shape). Sessions without
answers = PARTIAL: bank verbatim + hand the
owner the run-sheet POINTERS for the asking step (wording stays
virgin). Owner asks to play mid-session → r4's live-launch protocol
(no `--fresh`, detached launch, judge by the log at close, priming
quarantine while answers are pending). Junior's side: nothing pending.

## 2026-08-18 v18 session 9 — SEVENTEENTH evidence gate re-run: EMPTY (no ritual evidence, 0/8 answers, no v19 list, no new soak runs); PARTIAL/STANDBY holds, cycle owner-paced

**Mode: EMPTY** (spark banked + committed:
`drafts/_v18-seventeenth-harvest-spark-r2-20260818.md` — supersedes
`7224819` as the harvest vehicle; folds the soak-era residue laws and
the bot-disqualification law: any log with an `AUTOPILOT seed=` line is
never session evidence). Full inventory 17:22–17:33, findings verbatim
in the skeleton's new re-check block:

- **Launcher logs:** 22/22 both temp dirs (count == session-8 close),
  newest still 2026-08-17 11:15 `ticks=0` idle host; zero `AUTOPILOT`
  lines in any launcher log — nothing to classify, zero SEVENTEENTH
  sessions played.
- **Quarantine holds:** `saves/world.json` md5
  `a249aec13c9af947c93641a63b2d77ea` == session-8 close; play-path
  strict decode (real `Core::DataStore` + `App::SaveStore#load`)
  LOADED `digest=d63fd8ea72551208fc03bf7e4b1b65cd` sessions=2 banked=0
  — chain anchor untouched.
- **Junior side:** no commit past `766cfa2` (origin/junior/ci still
  2026-08-16), no new `_junior-*` draft (newest 15:58 soak return,
  consumed s8), no paste. **Answers 0/8.**
- **Residue classified, laws held:** tmp/netplay desync artifacts
  17:10–17:13 = net-gates close run (`20260818-171110`, real
  fingerprint inside the gate window) + `766cfa2` pre-push hook rake
  (17:13:18); tmp/soak all ≤15:16 = session-8's own validation.

**Job 5 (soak side harvest):** no new `tmp/soak/*/report.txt` since
session-8 close — the overnight command hasn't been run. Nothing to
read, no tripwire, no code touched.

**Job 6 (v19 intake):** Junior's ideas list still not arrived — slot
stays open (banks verbatim to `drafts/_junior-v19-ideas-<date>.md` +
Itexo-style triage when it lands; if it arrives bundled with his ritual
answers, SPLIT: answers → skeleton verbatim, ideas → intake).

**Close:** docs-only; suite green 804 runs / 17005 assertions, 0
failures. No code, no wall owed. Skeleton gained the dated re-check
block (gate-result section); adjudication still EMPTY, gaps 1–8
unchanged; oracle surface untouched.

**RESUME POINT:** ritual sessions owner-paced; when both sessions + all
eight answers exist, the FULL harvest re-runs the r3 spark
(`drafts/_v18-seventeenth-harvest-spark-r3-20260818.md` — supersedes r2
with the post-solo-link baselines + the live-launch protocol). Sessions
without answers = PARTIAL: bank verbatim + hand the owner the run-sheet
POINTERS for the asking step (wording stays virgin). Junior's side:
nothing pending.

**Addendum (same day, 18:00 — owner solo session #1, world advanced):**
owner asked live; dev seat launched `bin/play es` (no `--fresh`), owner
played and Esc-quit. Log `game_two_session_6508.log` (HUMAN — no
`AUTOPILOT` line; full md5-identical copy tracked in
`drafts/_v18-seventeenth-evidence/`): `loaded d63fd8ea… sessions=2` →
`saved 602e94bb… banked=20 seals=2 marks=3 sessions=3`; disk
strict-decode matches the saved digest byte-exact (boss_1_defeats=1).
Save md5 now `213076c540cc9eed846172748aae2e10` — the `a249aec…`
quarantine value is superseded by legitimate owner play, NOT a breach.
First real chain link banked in the skeleton; ritual session 1's host
`loaded` should now equal `602e94bb…` (unless more solo play moves it
first). Still zero ritual sessions, 0/8 answers — gaps 1–8 unchanged.

## 2026-08-18 v18 session 8 — autonomous coop soak SHIPPED (bot+orchestrator+checker); loopback 2×36000 green, cross-machine Tailscale episode green BOTH seats; SEVENTEENTH untouched (soak ≠ oracle)

**Evidence gate (Job 0):** no ritual evidence (newest launcher log in
both temp dirs still 2026-08-17 11:15 `ticks=0`; no Junior commit past
`621fa5b` at session start; owner silent), no v19 list — spark
continued. Baseline green ×4 (suite 761, net gates 3/3, perf p95
0.207ms, wall deferred to close). `saves/world.json` md5
`a249aec13c9af947c93641a63b2d77ea` recorded for the quarantine proof.

**Built (TDD, one concern per commit):** `3b52e38` cli (`--save`
override + `--bot [seed]` + `--bot-ticks`; D3 refusal named, exit 1,
proven live; `--join --save` refuses; absent flags leave parse shapes
byte-identical) · `394cd2e` `App::Autopilot` (pure (seed, tick)→actions
on the core input seam; RNG only at burst boundaries; all 11 action
bits on fixed cadences; banner = episode replay identity) · `bf72045`
wiring (window swaps keyboard→bot at the same seam, quits via the Esc
path at quit_tick, never holds an end screen; real-loopback session
test pins desync-free bot masks) · `9f115c5` soak infra (`rake soak`,
`soak/run_soak.sh` + `soak/chain_check.rb`, 18 fixture-log tests;
host_only/join_only seams; mechanical breach checks: real-save md5 +
temp-log count) · fixes found by running it: `c355cb2` stdout
unbuffered under --bot only (a fuse-killed seat left an EMPTY log),
`ff0be73` single-side heartbeat noise, JOIN_WAIT_S join race. Suite
761→804 runs / 17005 assertions.

**Validation (Job 3):** canary 1×1800 PASS · smoke 3×7200 PASS (chain
`fresh→56913068→e4c89c27→2d2982b1`, sessions 1→3) · ritual-floor burst
2×36000 PASS (ticks 36120/36123 + 36120/36118, desyncs=0 all four
seats, chain sessions 1→2). **Accidental crash-lane proof:** a real
power cut killed burst #1 mid-EP2 — EP1's save survived intact,
parseable, no torn write (decision 14's integrity law held on real
hardware); commits/working tree unharmed, burst re-run green.

**Cross-machine (Job 4, Junior's seat LIVE):** runsheet
`drafts/_v18-soak-runsheet-junior-20260818.md` (pt-br, md5
`78601600…`) + seat-addressed note (consumed — receipt `f9192fd`, note
removed at close). Episode over real Tailscale (DERP relay ~200ms, no
direct path — the known CGNAT trap): MY seat `SOAK PASS` host_only
36120 ticks desyncs=0 stalls=3703 stall_ms_max=522 (well under the 45s
abort) · HIS seat `SOAK PASS` join_only 36121 ticks desyncs=0 stalls=0
(his draft `_junior-soak-20260818.md`, verbatim logs). Zero divergence
across machines through real jitter. His attempt-1 connect-timeout =
D7 scheduling fail, correctly re-run after a fresh "listo".

**Recorded, not fixed (routing law):** joiner seat prints only at
CLOSE, so a joiner heartbeat can't distinguish playing/hung mid-episode
(the fuse covers; project memory line added — judge in-flight soaks by
nothing) · bot `sustain refused=27` = expected dumb-bot noise · bots
never co-locate at gates, so soak coverage = ZONE 1 only (accepted:
zone transitions are wall-covered deterministically; netplay/persist
endurance is zone-agnostic) · never edit a script a live run is
executing (bash misparse killed the checker mid-run; salvaged by
running chain_check manually — memory line added).

**Close gates:** wall tag `soak-20260818` — 18 scripts, 17 in-sweep
PASS + `ledger_loop` `tribute_beat_reads` FAIL adjudicated critic
variance by standalone retry PASS (`0d9433a` precedent; no sim/render
file moved this session; both verdicts in `drafts/_gate-verdicts.log`)
· suite 804 green · perf p95 0.213ms · net gates 3/3. **Quarantine
proof at close:** `saves/world.json` md5 unchanged
(`a249aec13c9af947c93641a63b2d77ea`), temp dirs virgin (newest
`game_two_session_*.log` still 2026-08-17 11:15, count 22 — zero soak
leakage).

**The law, restated:** soak green ≠ oracle progress. Bots never
adjudicate; `AUTOPILOT`-tagged logs and `tmp/soak/**` are never
session evidence (skeleton residue-trap line added). The SEVENTEENTH
still requires two REAL human sessions on different days + both
players' verbatim answers.

**v19 intake slot (Job 5):** Junior's ideas list did NOT arrive — slot
stays open; when it lands it banks verbatim + triages Itexo-style.
Nothing new starts until the SEVENTEENTH adjudicates.

**Overnight soak, either seat (one command, Git Bash):**
`export PATH="/c/Ruby34-x64/bin:$PATH" && N=40 TICKS=36000 rake soak`
(~7h, ~40 episodes; report in `tmp/soak/<run>/report.txt`).

**RESUME POINT:** unchanged — ritual sessions owner-paced; when both
sessions + answers exist, the FULL harvest re-runs spark `7224819`.
Junior's side: nothing pending.

## 2026-08-18 v18 session 7 — interlude (Junior away): baseline green ×4, burst-legibility rubric LANDED, owner map artifact, solo sheet; SEVENTEENTH still PARTIAL/STANDBY

**Evidence gate (Job 0):** nothing new at session start — newest
`game_two_session_*.log` in both temp dirs still 2026-08-17 11:15
(`ticks=0` idle host, verbatim = the skeleton's banked line); no new
solo logs → nothing to bank, skeleton untouched (Job 4 empty).
Mid-session pull brought Junior's `621fa5b` (11:00) — agent-sessions
ratification WITH amendment (session start also reads CHECKPOINT top;
two agent-proposed rules declined, recorded in
`drafts/_junior-agent-rules-amendment-20260818.md`). NOT ritual
evidence; consumed. It IS his seat's first push to `main` → bridge
plan executed: `junior-tibia` deleted local+origin (ancestor-verified
`origin/junior-tibia` ⊂ `main` first).

**Baseline (all four surfaces, promoted mainline):** suite 761 runs /
13889 assertions green · wall 18/18 tag `interlude-20260818` (17 via
runner; the dev-shell 2h timeout clipped the runner mid-critic on the
last script, orphaned procs killed, `world_loop` completed standalone
with the runner's exact commands — log complete in `tmp/wall/`) ·
netplay gates 3/3 GATE PASS (vision + determinism) · perf p95 0.194ms
(budget 16.6).

**Rubric line LANDED (Job 1, green-or-revert → GREEN, `948024c`):**
`burst_legibility_budget` appended to `harness/gate_checks.json` (57th
check; triage 2.9 FOLD-NOW rubric candidate, Itexo addendum 2.9,
era-tagged 2019; wipe veil + writ-frame explicitly exempt). Full wall
re-run tag `interlude-rubric-20260818`: 18/18 with the new line PASS
everywhere, exercised non-vacuously on 10 scripts (striker burst,
kill-pop shards, pulses). One FAIL in-sweep: `nest_advance`
`ledger_negative_reads` — an EXISTING check, net-zero edge
(frame_10310 wipe tally `+6 / -6 / = +0` magenta; morning baseline
PASSED the same byte-identical frame calling +0 "arithmetically and
chromatically consistent"). Adjudicated critic variance per the
`0d9433a` precedent: standalone retry PASS ("net +0 correctly
subtracts the hollow -6, sign and color agree"); both verdicts in
`drafts/_gate-verdicts.log`. RECORDED, not fixed (existing checks
frozen): `ledger_negative_reads` doesn't define the net==0 case —
candidate one-phrase clarification post-ritual.

**God-view artifact (Job 2):** map gate first — probes 5/5 + critique
6/6 (`harness/map_checks.json`, `tmp/map_gate_critic.log`; critic
globs `frame_*.png`, probe artifact copied beside itself per the 3c
pattern). Then the owner's map:
`captures/map/world_d63fd8ea_1787076228.png` (876×408) — filename
digest8 == play-path strict-decode digest
`d63fd8ea72551208fc03bf7e4b1b65cd` == the skeleton's chain anchor;
sessions=2; header BANKED 0 · MARKS 0 · PROVISIONS 0 · BOSS 1 DEFEATS
0; ZONE 1 · HOME marked. `saves/` untouched (read-only path; NOTE:
`src/map_main.rb` takes ENV vars, not argv — bare `OUT=… PROBES=1`
args are silently ignored).

**Solo sheet (Job 3):** `drafts/_v18-solo-sheet-20260818.md` — es-CR
ustedeo, 10 lines, everyday gamer words; every claim verified against
`src/main.rb` / `src/app/window.rb` / `bin/play.cmd` this session;
language critique accuracy + presentation both PASS. Ritual surfaces
(run sheet, JUNIOR.md, skeleton adjudication) untouched.

**Junior (when he pulls):** nothing owed from your seat this session —
your `621fa5b` amendment is adopted as written; `junior-tibia` is
retired, `main` is the only branch now.

**RESUME POINT:** unchanged — ritual sessions owner-paced; when both
sessions + answers exist, the FULL harvest re-runs spark `7224819`.
Nothing new starts.

## 2026-08-18 v18 session 6 — Itexo corpus intake + triage (docs-only); SEVENTEENTH re-checked = still PARTIAL/STANDBY

**Mainline:** evidence gate re-run this session — NOTHING NEW (newest
launcher log still 2026-08-17 11:15 `ticks=0`; no Junior paste/commit
past `0873c31`; no answers). STANDBY holds, cycle stays owner-paced;
session-5 skeleton untouched (no evidence = nothing to adjudicate).

**Intake (owner-approved spark, gamesmith Itexo addendum):**
- Addendum copied to `docs/design-corpus/gamesmith/addenda/` — md5
  `cabd71a8…` verified byte-identical to source, `git check-ignore`
  confirmed untracked (drop's `*` gitignore); `_PROVENANCE.md` stub
  written (post-GATE-4 product, sealed drop undisturbed).
- Triage table `drafts/_itexo-intake-triage-20260818.md`: every 2.1–2.11
  section + recommendation 1–9 dispositioned (FOLD-NOW as evidence-input
  semantics only — build phase CLOSED; BANK = BOSS-1 exposure notes;
  PARK with triggers; ROUTE-SIBLING). Two overrules of the spark's
  pre-triage, reasons in the draft: 2.6 minted-marker ≠ SEVENTEENTH
  carried fact (arbiter CLOSED + in flight → PARK v19); 2.7 rate/ETA
  not oracle-serving (→ PARK).
- PARKING_LOT: new §"Itexo corpus triage" (minted marker, gate grammar
  + generational rider, rate+ETA readout, ledger-attacker v19 flag) +
  corpus cite added to the v19 item/backpack rider (2.8).
- Sibling banking sessions launched headless from this seat (pi -p, one
  per free sibling seat, digest-stamped prompts): game-two-lore,
  game-two-assets, game-two-audio. ALL THREE closed same session — md5
  gates passed, DoDs met, receipts + hub quarantine spot-check recorded
  in the triage draft §Route receipts. (Windows trap hit + memorized:
  write-tool `/tmp` = `C:\tmp`, bash `/tmp` = `%TEMP%`.)
- **Orchestration pattern ADOPTED (owner, this session):** hub-and-spoke
  codified — new `seat-orchestration` skill (launch.sh/status.sh +
  receipts protocol; canonical copy pushed to pi-setup `fda1ae8`),
  AGENTS.md §Enforcement orchestration block, docs/JUNIOR.md §"Sessões
  com agente" (pt-br + en mirror — additive; Junior's ratification lane
  may amend his wording).
- Assets seat mail `from-game-two-assets-v7-repins-banked.md` read —
  explicit "no action needed" (v7 banked, repins verified); consumed.

**Resume point:** unchanged from session 5 — the ritual sessions are
the only mainline work left; FULL harvest re-runs the session-5 spark.

## 2026-08-18 v18 session 5 — the SEVENTEENTH: PARTIAL (ritual not yet played; skeleton banked STANDBY; mainline promoted)

**Mode (spark `7224819`, evidence gate):** PARTIAL. No ritual evidence
exists — newest launcher logs 2026-08-17 11:15, all `ticks=0` idle
host attempts; no Junior-side paste/file/commit (his latest =
`0873c31`); no answers; owner confirmed live "nothing on my end for
now". Expected shape: the run sheet only opened at `90c75e6` (02:09
same night) and the ritual needs two DIFFERENT days. Banked what
exists, named the gaps, stopped — no adjudication.

**Skeleton:** `drafts/_v18-fun-verify-skeleton-20260818.md` (v17
naming precedent) — STANDBY: ritual restated, telemetry slots empty,
Half A checks + Half B questions PENDING, routing = spec pointer
(CLOSED, not restated — drift risk), gaps named (8 items).

**Forensics banked there (attributions machine-verified):**
(1) `saves/world.json` (sessions=2, banked=0, saved 17:12:50 Aug 17)
= dev e2e loopback smoke (`tmp/e2e_host.log`/`e2e_join.log`, 2434/2431
ticks), NOT ritual play; chain anchor digest `d63fd8ea…`
integrity-checked live through the game's own strict-decode path (==
the logged `saved digest`); the `.bak` = the 15:29:04 `--fresh`
backup-law artifact. Ritual session 1 will open from `sessions=2`.
(2) `tmp/netplay/` desync artifacts: 3× SUITE residue (manifest
`platform: "test"`, fingerprint `dddd…` — regenerate on every hook
rake run; proven live: the 02:53 pre-push run rewrote all three, same
session ids) + 1× `netplay_desync` GATE residue (run 20260817-175509,
`_gate-verdicts.log:67704`; `diverge_at_tick: 40` → tick-60 digest
compare). None is live-session evidence; future harvests judge by
session LOGS only. (3) `sessions` counter = +1 per clean-quit save
(`save_store.rb:156`).

**Mainline promotion (owner ask mid-session; zero file changes):**
`main` fast-forwarded `fff5e18..7224819` (clean ancestor verified, 183
commits, content byte-identical); this checkout now on `main` tracking
`origin/main`; CI already triggers on both branches (`ci.yml:13`).
BRIDGE until Junior runs `git switch main`: every push from this seat
updates BOTH `main` and `junior-tibia` (handshake fingerprint =
same-commit law, so either branch stays safe meanwhile); after his
first push to `main`, delete `junior-tibia`. All old feature branches
verified fully merged (`--no-merged` empty) — prune later. JUNIOR.md
"branch = main" one-liner → next docs spark (no-changes law).

No code/data/harness/strings moved. AGENTS.md untouched (PARTIAL = no
decision line). pt-br lane stays CLOSED; side-signal stays HELD.

**RESUME POINT:** when both ritual sessions + all answers exist →
rerun spark `7224819`'s FULL path: harvest into the skeleton's slots →
four Half A checks (quoted lines) → Half B verbatim → walk EVERY
routing row → decide + AGENTS.md status line + owner queue. Nothing
new starts (owner-paced; scope contract).

## 2026-08-18 register cleanup (owner order — foreclosure-case legal jargon out of live human surfaces; docs-only, `90c75e6` + this commit)

**Owner order (same day as increment 8):** his knowledgebase had
unintentionally carried a personal foreclosure case (quarantined
system-wide 2026-08-16); its notarial/judicial register had drifted
into our es/pt human-facing text. Audit run over data/strings (CLEAN —
zero legal terms), src/ + data (CLEAN), and the live docs: every real
hit was in THIS session's increment-8 prose. Cleaned in place:
`docs/JUNIOR.md` ("o contrato, sem letra miúda" → "como funciona, sem
pegadinha"; "custódia do save" → "o save mora com o host"; "a cadeia
MOSTRA" → "o histórico MOSTRA"; EN mirror "custody contract / no save
custody" → "who keeps the save / never keeps the save"), the
SEVENTEENTH run sheet (árbitro → chequeo; cadena de evidencia → la
cadena + el chequeo; hecho citado en el veredicto → dato mencionado en
el resultado; adjudicador/adjudicación → quien evalúa / esa decisión;
contrato de alcance → regla del ciclo), and my AGENTS.md Commands
bullet ("no save custody" → "never keeps the save").

**Kept, on purpose:** (1) the spec-closed question lines — "4.
Veredicto libre." / "4. Veredicto livre." — panel-checked de-primed
wording, pre-registered; changing them re-opens that loop — FLAGGED to
the owner for a one-word override if he wants it; (2) English internal
process vocabulary and spec cross-reference names (fork F2 "save
custody", "Half A arbiter", "custody handoff" in PARKING_LOT — quoted
spec terms) — renaming those means reopening the CLOSED spec and
rewriting history, not a register fix; (3) archival entries below this
one stay as written (evidence, never rewritten). KB re-probed live:
the only foreclosure hit is the quarantine law itself
(game-research/es-match-register … note, verified 2026-08-16) — the
vault layers stay clean; the drift vector was output register, and the
fix is the standing audit-your-own-output rule now backed by a project
memory line. Es/pt human surfaces use everyday gamer words from here
on — this includes owner-queue messages.

## 2026-08-18 v18 TDD session 4 (increment 8 GREEN — docs + close; BUILD PHASE CLOSED, increments 0–8; cycle WAITING on the SEVENTEENTH)

**Increment 8 — docs + close (DOCS-ONLY; spec item 8; no code/data/
harness file moved — assets-seat pins untouched by construction):**
`docs/JUNIOR.md` gains the v18 persistence/custody section (PT-BR first
+ EN mirror, after the v17 co-op section, file voice kept): the custody
contract in player terms (the shared world lives on the HOST's machine;
Junior solo = HIS own world on HIS machine; only joining advances the
shared one — F2/F4 verbatim; joiner never persists), the `--fresh`
notice (backup `.bak-<ts>`, host prints `persist fresh source=fresh`,
`sessions=` restarts low; `--join --fresh` refuses — no custody),
pull-is-schema-critical (v2 HELLO refusal names `protocol version` +
git-pull hint), save location + never-hand-edit + `TELEMETRY persist`
continuity proof (session-log path named), and sustain in HIS ratified
vocabulary (SUPRIMENTOS family, U/R, buy-at-bank/use-anywhere, 7iii
vanish-at-zero). **The PT-BR section is FLAGGED for Junior's
ratification** (strings-flow precedent — his lane, never blocked on
him). The stale "16º veredito" close of the v17 co-op section updated
to every-verify wording (both halves) — smallest faithful fix, recorded
here. `AGENTS.md` Commands only: Persistence (v18) bullet
(`saves/world.json` custody + `--fresh` composition + backup law +
`data/balance/coop.json` pointer) + `rake map [SAVE=] [OUT=] [PROBES=1]`
line (decision 13). `PARKING_LOT.md`: custody-handoff = smallest delta
on the EXISTING AWS-staging stage-2 candidate artifact (named "custody
handoff" + the SEVENTEENTH routing cross-ref) — no duplicate entry (the
stage-2 wording already carried the trigger). Run sheet:
`drafts/_v18-seventeenth-runsheet-20260818.md` — owner half es-CR
ustedeo (ritual: two REAL sessions, DIFFERENT days, ≥10 sim-min /
≥36000 ticks, Esc exit; harvest all four `TELEMETRY netplay` + every
`TELEMETRY persist` line BEFORE any question; solo between sessions
allowed, its persist lines join the chain), spec questions transcribed
VERBATIM (es owner / pt-br Junior — de-primed wording untouched), Half
A arbiter restated (digest chain + desyncs=0/reason=quit ×4 + one named
strictly-positive carried fact), routing-context footnote (Junior's
discoverability side-signal → "sustain unused → discoverability first"
row; adjudicator reads AFTER verdicts).

**Docs-found observations (RECORDED, not fixed — docs-only law):**
(1) Spec-prose imprecision: "Junior sees source=fresh" — in code the
joiner prints NO persist line when the host's world is fresh (null save
skips the refusal ladder AND the loaded line, `src/main.rb` guard); the
joiner-side fresh signal is the ABSENT `loaded` line that session + the
reset `sessions=` counter on later handshake loads. JUNIOR.md documents
the REAL behavior. Candidate one-liner if the SEVENTEENTH surfaces it
as a felt gap: joiner prints `persist fresh source=handshake` on a null
save — post-adjudication only. (2) Launcher filter gap: `bin/play` +
`bin/play.cmd` echo only `TELEMETRY netplay`/desync/relaunch on a clean
end — `TELEMETRY persist` lines live ONLY in the session log
(`%TEMP%\game_two_session_*.log` / `/tmp/game_two_session_*.log`). Not
blocking (the logs are the pre-registered backup; the run sheet points
the harvest there); candidate one-line findstr/grep addition after the
SEVENTEENTH.

**State: v18 BUILD PHASE CLOSED — increments 0–8 all green + pushed.**
Suite 761 runs / 13889 assertions green at close (Job 0 re-verified
live); 18 canary baselines banked; wall 18 scripts. Cycle state =
WAITING on the SEVENTEENTH (owner-paced; the owner queue fired at
session close: two sessions on different days per the run sheet).
**Nothing new starts until it adjudicates** (scope contract).

**RESUME POINT (next session):** harvest per the run sheet → adjudicate
per the spec's pre-registered §Fun-verify routing table → verdict
skeleton in drafts/ (naming precedent: `_v18-fun-verify-skeleton-
<date>.md` after `_v17-fun-verify-skeleton-20260816.md`). Junior: pull
— the JUNIOR.md pt-br persistence section awaits his ratification (the
sustain strings themselves are already his, `a51b06e`).

## 2026-08-18 v18 TDD session 3c (increment 7 GREEN — god-view v0: rake map + probes + critique PASSED; next = increment 8: docs + close, then the SEVENTEENTH)

**Increment 7 — god-view v0 (decision 13, lane 6):** `rake map [SAVE=]
[OUT=] [PROBES=1]` → `src/map_main.rb` (entry point beside main.rb)
opens a real 320×180 GL window (Gosu.render law), constructs
`World(data, seed: 0, save: facts)` through the SAME strict-decode path
as play (App::SaveStore load; refusal aborts NAMED; missing file =
honest fresh zero-state), composes ONE PNG via `App::MapArtifact` and
closes. Artifact: header `BANKED N · MARKS K · PROVISIONS P · BOSS 1
DEFEATS D` → six zone panels in a labeled grid sorted by display label
(HUB 1, ZONE 1..5 — strings table, en pinned), full tile grids at 6px/
tile with colors resolved EXACTLY as the renderer resolves them (zone
`palette` floor/wall/transition/station ladder + `Renderer::SEAL_SLAB`
for sealed ways — no second color table; structural lanes pin the
source), SEALED/OPEN text stamps per seal-gated way from the save,
possession-white frame + `· HOME` suffix on the home panel, filename
`world_<digest8>_<ts>.png` where digest8 = the world's OWN facts digest.
Content resolution (layout/cell_rgb/stamps/header/filename) is PURE —
7 headless lanes in test/app/map_artifact_test.rb; `#compose` is the
only Gosu-touching method.

**Micro-decisions recorded (increment 7):** (1) GL pixel probes live in
the TASK (`PROBES=1` renders STAGED facts — non-default home camp, one
breach, marks/counters nonzero — then asserts breached≠sealed cell +
breached==gate-gold + home-marker-on-home + no-marker-elsewhere +
header-present) rather than in minitest: Junior's CI runs `rake` on a
headless runner, and a suite that opens GL windows would kill it — the
map gate is `rake map PROBES=1` + the critique, per decision 13's "no
replay half". (2) The map tool moved OUT of harness/ to `src/map_main.rb`
when the decision-7i wall pins fired (harness sources are save-BLIND by
structural test; the map tool is save-aware BY SPEC — it is an app entry
point, not a wall surface; the pin stays fully intact, zero exemptions).
(3) `World#zone_maps` reader added (read-only @zones view) — the
composite renders all zones from the same TileMap objects the renderer
draws; no sim system iterates it (sweep-proven inert). (4) The critic
globs `frame_*.png`, so the gate copies the provenance-named artifact to
`frame_0000.png` beside itself — same bytes, both names kept.

**MEASURED evidence (increment 7):** suite 761 green (13889 assertions;
+7 map lanes); `rake map PROBES=1` — MAP PROBES PASS 5/5; vision
critique on the staged artifact PASS 6/6 (`harness/map_checks.json`:
all-zones/grids-distinct/stamps/home-marker/header/no-garbage — real
critic); artifact `captures/map/world_2f56ab53_*.png` 876×408; full
canary sweep 18/18 byte-identical post-world.rb-reader
(`tmp/canary_sweep_v18_inc7.log`, DONE 01:25:38); perf p95 0.194ms
(budget 16.6).

**NEXT — increment 8: docs + close:** JUNIOR.md persistence/custody
section PT-BR-first (player-terms custody contract: the shared world
lives on the host's machine, Junior solo = his own world, only joining
advances the shared one — panel Kimi-Q6; the `--fresh` notice: host
fresh → sessions counter resets, joiner sees source=fresh; pull cadence
is schema-critical — stale seat refuses NAMED at HELLO); AGENTS.md
Commands block (rake map / --fresh composition / saves/ / coop block);
PARKING_LOT custody-handoff entry under the always-online trigger;
SEVENTEENTH protocol confirm (two sessions, different days, ≥10 sim-min
each, Half A digest-chain + Half B de-primed questions — pre-registered
in the spec); pt-br sustain strings still FLAGGED for Junior. Then the
cycle WAITS on the two-day fun-verify — nothing new starts (scope
contract).

## 2026-08-18 v18 TDD session 3b (increment 6 GREEN — sustain presentation + THE Rule-2 gate PASSED with the real critic; next = increment 7: god-view v0 / rake map)

**Increment 6 — sustain presentation (decisions 10 + 7iii + presentation
spec):** `data/bindings.json` gains `"sustain": ["U", "R"]` (pair grammar;
KEY_TABLE already covered A–Z; BindingMap flows it to KeyboardInput AND
the strip — one source, v15 law). ControlsOverlay: the sustain pair joins
`vessel_line` ONLY when `world.pack.provisions > 0` (appended after swap)
and a `provisions_line` counter ("PROVISION N") right-aligns on the strip
under the SAME condition — provisions=0 draws NOTHING (7iii, the wall
pin; pure-content lanes + a real-World lane in controls_overlay_test).
Station cues: `Renderer#station_cue_text` (public, pure) resolves text
for the provision kinds ONLY — `:provision_bought`/`:provision_used`
draw the OK ring + a localized line at y-32 (one row CLEAR of the
station-ledger line at y-18 — a pilot capture caught the bank-count
collision); every pre-v18 kind stays byte-exact (station_cue_text_test
pins nil). Strings ×3 locales: `overlay.sustain`
(provision/provisión/provisão), `hud.provisions`, `cue.provision_bought`
/ `_used` / `_refused` — functional dictionary words, flat register;
**pt-br values FLAGGED for Junior's ratification** (PROVISÃO /
PROVISÃO COMPRADA / PROVISÃO USADA / RECUSADO — his lane, not blocked).

**Refusal-cue deviation (recorded):** increment 5 shipped sustain
refusals on the shared `:refused` cue kind — the pilot reel showed the
X-bar is INVISIBLE when the presser stands on the refusing tile (bodies
draw after cues at z=0; true of every station refusal since D1b).
Smallest walled-safe fix: sustain refusals moved to their OWN cue kind
`:provision_refused` (world.rb one-liner; cue kinds are digest-excluded
presentation) drawing the X-bar at z=9 — ABOVE the body — plus a REFUSED
text line; the walled `:refused` draw is UNTOUCHED (add-only by
construction, sweep-proven). The pre-existing under-body X-bar on
altar/vat/seal refusals is NAMED here as a known cosmetic debt — fixing
it moves walled bytes, so it waits for a deliberate re-bank cycle.

**The wall exerciser** `harness/scripts/sustain_run.json` (11531 ticks,
seed 7, 8 captures) was authored through `rake pilot` (NAME=sustain,
reset-once; export) and JOINS the wall by directory law: broke refusal
at tick 61 (banked 0) → earn → buy×2 (counter + strip row appear) →
clamp-heal use → full-hp refusal (charge kept) → wounded mid-swarm →
second use (counter 2→1→0, row vanishes — 7iii live in-capture) →
earn → buy×3 → at-cap refusal. Manifest pins the beats:
provision_bought≥10 / used≥4 / refused≥6 per double replay (the three
provision events joined `Harness::EventLog::EVENTS` — no walled script
fires them, sim-identity md5s pinned green). Checks ADD-ONLY in
gate_checks.json (53→56): provisions_counter_reads /
sustain_success_cue_reads / sustain_refusal_cue_reads.

**MEASURED evidence (increment 6):** suite 754 green (13871 assertions);
FULL `rake gate SCRIPT=harness/scripts/sustain_run.json` PASS —
determinism 8/8 byte-identical + REAL vision critic 56/56 (new checks:
counter/pair vanish at zero ✓, cue texts read ✓, X-over-body + REFUSED
"unmistakable" ✓); `rake manifest` PASS (bought=10 used=4 refused=6);
18th baseline banked (`tmp/canary_baseline/sustain_run/`, from gate_a);
full sweep 18/18 byte-identical (`tmp/canary_sweep_v18_inc6.log`, DONE
22:18:38 — the 17 pre-v18 baselines untouched: the 7iii proof); perf
p95 0.215ms (budget 16.6). Human-facing text: accuracy axis — labels
name exactly the mechanic (bought/used/refused, count); presentation
axis — critic-verified readable; register — placeholder-functional per
standing order; language critique satisfied at the gate.

**NEXT — increment 7: god-view v0 (decision 13, lane 6, ONLY with room
to finish the critique):** `rake map [SAVE=] [OUT=]` — capture window
(GL law), every zone's grid from the SAME palette data the renderer
reads (structural test pins the source), one PNG: labeled zone grid
(ZONE 1..5, HUB 1), station glyphs, SEALED/OPEN stamps from the save,
home marker, header `BANKED N · MARKS K · PROVISIONS P · BOSS 1 DEFEATS
D`, filename `world_<digest8>_<ts>.png`; landmark pixel probes +
`harness/map_checks.json`; gate = capture + critique (no replay half);
NOT sim-touching (sweep only if src/game or harness-loaded files move).
Then 8: docs + close (JUNIOR.md custody PT-BR-first + --fresh notice,
AGENTS.md Commands, PARKING_LOT custody-handoff, SEVENTEENTH confirm).
Junior: pull — pt-br sustain strings await his ratification; protocol
v2 + bindings row land here (stale seat refuses at HELLO naming
“protocol version”).

## 2026-08-18 v18 TDD session 3 (increment 5 GREEN — the sustain verb, sim half; next = increment 6: sustain presentation + THE Rule-2 gate)

**Increment 5 — sustain sim (decisions 9/15 + Codex #16; lane 5 =
test/game/sustain_test.rb, 10 lanes):** numbers were already in
`data/balance/economy.json` (cost 5 / cap 3 / heal 30 — landed with
increment 1; no JSON edit this increment). `Pack#buy_provision!(cost:,
cap:)` / `use_provision!(heal:)` — guarded, pure state (no bus, no world
knowledge): refusal symbol or nil; buy spends through the existing
`spend!` INSIDE the verb (guard+mutation atomic in Pack; player-initiated
at the bank — the never-taxed law holds); use consumes ONE charge and
heals every LIVING member via the new `Creature#heal!` (clamped at
max_hp, dead untouched — flesh-only like heal_full!). `:sustain` joined
`PossessedController::ACTIONS` + `EDGE_TRIGGERED` (swap-rearm law rides
the existing mask; protocol v2 bit 10 was already riding since increment
3, unbound until increment 6's bindings row). World's sustain path
(`World#sustain`, the controller's view API beside `interact`): ONE
`map.station_at` lookup — on the bank BUYS, anywhere else USES;
refusals (at_cap / broke / none / no_effect / seat_race) emit
`:provision_refused` + the existing `:refused` cue at the PRESSER's tile
and spend NOTHING. Events registered: `:provision_bought` /
`:provision_used` / `:provision_refused` (Rule 4). `TELEMETRY sustain
bought=N used=N refused=N` joined `Telemetry#summary` (guarded
subscriptions — subscriber-alive law, line prints zeros on pre-v18
buses; telemetry_test's full-summary pin extended).

**Micro-decisions recorded (increment 5):** (1) **seizure × sustain =
hands-verb**: a seized body MAY buy/use — the seized branch suppresses
feet and keeps hands (interact precedent), tested in the lane. (2) The
seat-race latch `@sustain_done` is a PER-TICK transient reset in
`tick_world` beside `@slot_claims`, never digest state (its only read is
intra-tick; frame monotonicity makes a cross-tick read impossible — the
classification table stays untouched, provisions was already PERSISTED).
(3) The buy emits `:banked_spent` with `sink: :provision` from the
sustain path (banked_end tracking rides it; the d1b line still prints
inscribe/tribute only — sustain has its own line). (4) Success cue kinds
`:provision_bought`/`:provision_used` ride the existing generic OK pulse
until increment 6 gives them labels; refusal reuses `:refused`. (5)
Sustain mirrors interact's action gate (controlled? / dead / staggered /
mid-action = silent false, exactly like interact — the universal action
law, not an economy refusal; the five economy refusals always cue). (6)
The save_state mutation sweep now stages provisions through the REAL buy
verb (closes increment-1 micro-decision 2); rich_world keeps
`load_provisions!` as its staging shortcut (noted, same family as its
`bank!(200)`).

**MEASURED evidence (increment 5):** suite 747 green (13823 assertions;
+10 lanes over increment 4's 737); full canary sweep 17/17
byte-identical (`tmp/canary_sweep_v18_inc5.log`, DONE 20:49:13 — the
W3 proof: sim-touching increment, no walled script presses sustain);
perf p95 0.178ms (budget 16.6).

**NEXT — increment 6: sustain presentation + THE Rule-2 gate (7iii +
decision 10 + presentation spec):** `data/bindings.json` gains
`"sustain": ["U", "R"]` (pair grammar; strip label derives from the
binding map — v15 law); provisions counter + strip sustain row render
ONLY when provisions > 0 (7iii — the wall-safety pin, structural test);
strings en/es (dev) + pt-br (land + FLAG for Junior); cue labels for
buy/use on the existing station-cue channel; new wall exerciser
`harness/scripts/sustain_run.json` (buy 2 → walk out → damage → use
both → over-cap + broke + full-hp refusals, captures at each beat) +
ADD-ONLY checks in `harness/gate_checks.json`; FULL `rake gate` with the
REAL critic (blocking); after PASS bank
`tmp/canary_baseline/sustain_run/` (sweep goes to 18) and re-run the
sweep — the other 17 byte-identical. Then 7: rake map (decision 13,
lane 6); 8: docs + close (JUNIOR.md custody PT-BR-first + --fresh
notice, AGENTS.md Commands, PARKING_LOT custody-handoff, SEVENTEENTH
confirm). Canary baselines: `tmp/canary_baseline/` (17 dirs; re-bank
protocol `tmp/bank_canary_v18_resume.sh` if tmp/ cleaned). Junior: pull
— his PT-BR lane (PROVISÃO + cue verbs) opens at increment 6.

## 2026-08-17 v18 TDD session 2 (increments 3+4 GREEN — protocol v2 + SESSION save transfer + THE TWO-SESSION LANE + live loopback E2E; coop feel: seat scalars + third-body caution; next = increment 5: sustain sim)

**Protocol v2, ONE bump for the cycle (spec decision 8):** `VERSION = 2`;
`ACTIONS` appends `:sustain` at bit 10 (existing ten bits unmoved — the
BIT rides now, the verb is increment 5; unbound actions read false on
every input source so the bit stays 0); SESSION vocabulary grows
`save_schema`/`save_digest`/`save` as REQUIRED keys (null for a fresh
world — JSON null keeps the key present); BYE gains an OPTIONAL `detail`
field (link_slow precedent). Suite pins the FINAL v2 vocabulary: a
VERSION==2 pin, the 11-action order pin (mask 2047), the SESSION
required-keys pin, INPUT ≤40B at bits=2047.

**SESSION save transfer (decisions 5/6, both refutations built on):**
the save rides Params — `Session.host(save_facts:, save_canonical:,
save_digest:, save_schema:)` transmits the canonical facts STRING
exactly as loaded (never re-serialized past the pinned canonicalizer;
the host carries the tree it VALIDATED at load and never re-parses its
own wire bytes); `Session.join(save_schema:, save_validator:)` keeps Net
game-agnostic (main.rb injects `SaveState.refusal_for` — the SAME strict
decoder as file loads). Joiner ladder in `save_refusal`, order PINNED:
schema (W7: names the git-pull fix) → md5 over the RECEIVED string
BEFORE parsing (QW-Q4: a parse→re-serialize can never enter the verdict)
→ parse → strict decode; any rung = BYE{reason, detail} + conclude
:protocol + finish (params never known → main.rb aborts pre-window,
exit 1, the bindings-error precedent). Params.save_digest joiner-side is
RECOMPUTED from received bytes (never an echo); both Worlds construct
`World.new(…, seats: 2, save: params.save)` at the attach barrier
(window.rb — the frozen-snapshot refutation as built design).

**Refusal taxonomy (decision 6b):** `REFUSAL_REASONS = fingerprint |
save_schema | save_digest | save_invalid` — `handle_bye` records the
peer's `detail` (fallback `peer refused: <reason>`) for ALL of them, so
BOTH seats print the SAME named refusal and exit 1; status 2 stays
link-fault-only (RC-matrix rows extended in cli_test — launchers never
rehost on a refusal).

**Host launch order (decision 6c) in main.rb:** [--fresh backup →]
load → strict decode (console refusal, exit 1, pre-listen) → persist
`loaded … source=file` / `fresh` line → wire preflight
`Session.session_wire_refusal` — the ACTUAL `Protocol.encode(:session)`
line with the real canonical string + real digest (worst-case stand-ins
for the bounded handshake fields: session_id 8-hex, seed 0xffffffff,
d=delay.max, link_slow=true) vs `wire_budget_bytes` 3072, refused NAMED
before the socket opens (encode Oversize rescues into the same named
family) → listen. Host owns a SaveCoordinator (owner: true); the joiner
gets NONE and prints `loaded … source=handshake` after the pre-window
pump. `Window#close` re-ordered: session end resolves FIRST (X-button
quits), then the coordinator gates on `@session.reason` — the
increment-2 solo-only `reason: :quit` hardcode is dead (the spark's
named TRAP); desync/conn_lost/protocol write NOTHING (lane-tested).
`--fresh` now COMPOSES with `--host` as an order-free modifier (spark
order overriding the session's own earlier solo-only lean): backup law
fires at the custody seat before the load; `--join --fresh` refuses
(no custody); usage string updated.

**THE LANE (test/net/netplay_persistence_test.rb, lane 3):** two real
session PAIRS over real loopback in one process, per-seat tmpdir save
roots, fake clock. Pair 1 (fresh, save=null) runs 300+ ticks with
scripted fights; carried facts staged by IDENTICAL API mutations on both
sims at an ASSERTED-equal tick (bank 75 + restore_breach! — the
divergence test proves one-sided pokes desync; symmetric staging held:
desyncs=0, digest logs identical); host coordinator writes the REAL file
at quit (sessions=1 stamped AT the write). Pair 2 loads the file,
preflights, transfers: joiner's RECOMPUTED digest == host's file-load
digest == pair-1's saved digest VERBATIM (the chain), carried fact
banked₂start == banked₁end on BOTH constructed worlds, breach open on
both, `digest_snapshot` equal at construction, 600+ further ticks
desyncs=0 with identical digest streams; pair 2 ends by JOINER quit →
host concludes :quit and writes sessions=2 (the DS-Q4 refutation as a
test); joiner save root asserted EMPTY after both sessions; host root
carries exactly world.json. Negative custody lane: a REAL mid-run
divergence (one-sided poke) → reason=desync → coordinator writes
NOTHING, no file exists. v1-peer lane: HELLO version skew refuses NAMED
(“protocol version”) with exit 1 on both seats. session_test grows the
unit half: transfer + fresh-null + schema-skew/tampered/unparseable/
invalid-facts ladders (same text on BOTH seats each time) + preflight
lanes incl. the W4 tripwire — worst-case facts derived FROM DATA (every
seal in data/zones + 2^31-1 counters) fit the budget.

**MEASURED evidence:** suite 723 green (13562 assertions; was 706);
netplay gates 3/3 PASS WITH critic (session/desync/conn_lost —
determinism half byte-identical, 12/4/4 captures); full canary sweep
17/17 byte-identical post-increment (`tmp/canary_sweep_v18_inc3.log`,
DONE 17:10:52 — protocol/net/app-layer change, sim untouched; run
anyway per spark); perf p95 0.223ms (budget 16.6); LIVE two-seat
loopback E2E on real windows (PostMessage Esc by PID): host loaded
`digest=5691…d624df source=file` (session-1's solo chain digest — the
chain crossed the solo→netplay boundary), joiner printed the SAME
digest `source=handshake`, JOINER-initiated Esc → both seats
`reason=quit desyncs=0` (ticks 2431/2434 — BYE-in-flight skew, SIXTEENTH
precedent), host wrote `saved digest=d63f… sessions=2` (file verified),
joiner wrote nothing.

**Micro-decisions recorded (smallest faithful deviations):** (1) the
preflight uses worst-case stand-ins for handshake-derived SESSION fields
(session_id/seed/d/link_slow are bounded and tiny; the SAVE is the only
unbounded field and rides verbatim) — the “ACTUAL encoded line” law is
satisfied on the field that matters. (2) `save_validator` is an injected
lambda (Net stays game-agnostic; StateDigest world: precedent) rather
than session.rb requiring game/save_state. (3) The host passes
`save_facts` (its validated tree) alongside the canonical string — it
never parses its own wire bytes; symmetry with the joiner is guaranteed
by the digest law, and a live mismatch would surface at the first digest
window. (4) `--fresh` composition implemented as order-free flag
extraction (“--host --fresh 5000” legal); `--join --fresh` is a named
usage error. (5) Lane-3 staging mutates BOTH sims at an asserted-equal
tick instead of scripting station walks (the netplay staging law from
project memory; input-driven banking stays lane-1/wall territory).

**Increment 4 — coop feel (decisions 11/12 + 7ii; lane 4 =
test/game/coop_feel_test.rb, 12 lanes):** `data/balance/coop.json`
`{"seats":{"2":{respawn_delay_scale 2.0, human_hp_scale 1.25,
ally_flee_hp_pct 0.35}}}` — the "1" key ABSENT by design and
test-pinned: `World#initialize` reads `@coop = coop[:seats][:"#{seats}"]`
once; seats=1 ⇒ nil block ⇒ ZERO scalar arithmetic anywhere (7ii — the
post-increment canary sweep is the structural proof). Scalars: human hp
at SPAWN inside `add_human` via new `Creature#scale_max_hp!` (explicit
`.round` Integer; ceiling rescales and fills; the BOSS flows through the
same path — every human spawn does); respawn relief at SCHEDULE time in
`schedule_human_respawn` (`(respawn_frames × scale).round` — owner Q3a's
walk-back). Third-body caution in AiController at the PINNED precedence:
seizure (unchanged, first) → flee → mark/aggro/target selection — an
UNCONTROLLED pack body with hp < pct×max starts NO new swings, ignores
the mark/taunt/aggro classes wholesale, and moves toward the follow
anchor; committed in-flight actions FINISH body-owned (controllers only
issue NEW verbs); the threshold rides `World#ally_flee_hp_pct` (nil at
seats=1 — the guard never evaluates; the transient Float compare is the
lowhp_switch_pct precedent). Lane pins: scaled-Integer units (boss
included) + seats=1 identity on both scalars + strict `<` threshold
(hp==pct×max FIGHTS) + fleeing-ignores-mark + seized-doesn't-flee
(answers the seizer's voice) + committed-swing-finishes-then-no-new-
swings + seats=1-never-flees + two-sim digest identity with the block
ACTIVE + knob-set pin (a deleted knob or a materialized "1" block fails
the data-contract test).

**MEASURED evidence (increment 4):** suite 737 green (13781 assertions;
+14 over increment 3's 723); full canary sweep 17/17 byte-identical
(`tmp/canary_sweep_v18_inc4.log`, DONE 17:52:56 — THE 7ii proof:
sim-touching change, walled line untouched); netplay gates re-run 3/3
PASS with critic (the coop block ACTIVE in both scene worlds —
determinism halves byte-identical); perf p95 0.202ms (budget 16.6).

**NEXT — increment 5: sustain sim** (spec decision 9 + 15, lane 5,
headless; SIM-TOUCHING — canary sweep + perf after): provisions as pack
state (`Pack#provisions` digest field exists since increment 1) +
`data/balance/economy.json` gains provision_cost 5 / provision_cap 3 /
provision_heal 30 + the EDGE-TRIGGERED sustain verb (joins
`EDGE_TRIGGERED` + swap-rearm law; bit 10 already rides the v2 mask,
unbound until increment 6's bindings row): press ON the bank station
buys via `spend!`, elsewhere consumes 1 charge and heals every LIVING
member `provision_heal` clamped (dead untouched — the vat's monopoly);
REFUSALS cue + spend nothing: at-cap / broke / zero charges /
ZERO-EFFECTIVE (all living at full hp); same-tick seat race =
first-success-per-tick in seat order (deterministic both machines);
`TELEMETRY sustain bought/used/refused`; events registered (Rule 4).
Then 6: sustain presentation + `sustain_run.json` + FULL Rule-2 gate
(blocking; ADD-ONLY checks); 7: rake map (decision 13, lane 6); 8: docs
+ close (JUNIOR.md custody contract PT-BR-first incl. the --fresh
notice, AGENTS.md Commands: rake map / --fresh / saves/ / coop block,
PARKING_LOT custody-handoff entry, SEVENTEENTH protocol confirm).
Canary baselines: `tmp/canary_baseline/` (17 dirs) — if tmp/ was
cleaned, re-bank BEFORE any sim change
(`tmp/bank_canary_v18_resume.sh` protocol). Junior: pull — protocol v2
+ the coop block land here; a stale seat refuses at HELLO naming
“protocol version”; his PT-BR lane (PROVISÃO + cues) opens at
increment 6.

## 2026-08-17 v18 TDD session 1 (increments 0-2 GREEN + PUSHED — canary baselines banked, SaveState + THE ROUND-TRIP LANE, persistence IO + solo wiring; next = increment 3: protocol v2 + SESSION save transfer)

**Increment 0 — baselines banked BEFORE any sim change:** one capture
replay per wall script into `tmp/canary_baseline/<script>/` — 17 dirs,
172 PNGs, manifest.md5 (machine-local, gitignored; v17 protocol). The
fresh bank is byte-identical to the archived v17 close-state baselines
(`tmp/canary_baseline_v17s1/`, manifest diff empty) — the sim entered
v18 exactly where v17 left it. A power cut killed the first banking run
mid-script; the resume protocol (skip dirs whose PNG count == the
script's captures length, redo partials) is
`tmp/bank_canary_v18_resume.sh`.

**Increment 1 — `Game::SaveState` + the round-trip lane (`5994eaf`):**
facts vocabulary exactly per spec decision 1 (banked, provisions,
home_zone, breached sorted, members kit/hp/inscribed roster order,
counters boss_1_defeats/sessions; `alive` DERIVED, never stored);
pinned canonicalizer (recursive key sort, String keys only,
Integer/String/Boolean + ASCII leaves, else EncodeError); PURE
projector (veil-tick quits resolve judgment through the live rules —
marked revives + mark consumed, floor keeps the wipe vessel; carried
never folds; ≥1-living asserted as ProjectionBug; serialize-twice
byte-identical, digest_snapshot + rng draws untouched); strict decoder
`refusal_for(facts, data:)` + `envelope_refusal` (named refusals:
schema/keys/roster/zone/hub/seal-tuple/type/range/duplicate);
`World.new(data, seed:, seats:, save:)` applies in the PINNED order
(home → member facts w/ hp clamp+log → seat pointers over the LIVING
set in seat order → `restore_breach!` idempotent + side-effect-free →
enter_zone at the loaded home's spawn). Pack#provisions + World
counters ride `digest_snapshot` (coverage pins extended). Test book:
test/game/save_state_test.rb — the LANE (lived-in world A → facts →
B1/B2 on a new seed: equal snapshots at construction + 4 byte-identical
StateDigest windows over 240 scripted ticks), idempotence,
every-veil-tick projector sweep (marked + floor variants),
persisted-leaf mutation sweep (real verbs only), clamp lanes (hp→kit
max, provisions→cap), apply-order lane (camp home + only the third
member alive; seats=2 → seat 2 waits), classification-exhaustiveness
table (W1 tripwire: every digest field = PERSISTED | SESSION_ONLY |
DERIVED or the test fails), pinned-seed field-reseed regression (seeds
1/2, 4-kill drop sequences diverge — decision 16's world half).

**Extract-on-touch fired mid-increment (recorded deviation):** wiring
SaveState pushed world.rb to 1841 > the 1800 line-cap gate — the
2026-08-15 process-debt review pre-named "drops/corpses" as the seam,
so the field-value economy (drops, corpse records, corpse loads,
expiry flashes, wipe grace, digest groups) moved VERBATIM into
`Game::FieldEconomy` (plain object, explicit call order, zero bus
subscriptions; zone/frame/multiplier/band passed as parameters — pure
lookups, rng order untouched). world.rb 1714.
`Game::World::CORPSE_FADE_FRAMES` stays addressable (renderer + tests);
one test moved to the public seam (`w.field_economy.spawn_corpse_load`).

**Increment 2 — persistence IO + solo wiring (this commit):**
`data/persistence.json` (save_path saves/world.json — gitignored —,
wire_budget_bytes 3072, backup_on_fresh); `App::SaveStore` (atomic:
same-dir .tmp → flush+fsync → close → rename-replace with 3×50ms
bounded retry → NAMED WriteError with .tmp intact; the written envelope
EMBEDS the canonical facts bytes verbatim, so every printed digest is
recomputed from bytes actually on disk/applied — never an echo;
unparseable/truncated/schema-skew → named refusals with newest-.bak
recovery hint; orphan-.tmp named at the next load; `backup_fresh!`
moves the save to `.bak-<ts>` BEFORE a fresh session's first write);
`App::SaveCoordinator` (writes IFF owner ∧ reason=:quit, exactly once;
desync/conn_lost/protocol/non-owner/double-close write NOTHING;
`sessions` increments AT THE WRITE, facts-level — the sim never bumps
it); solo main.rb: load + strict-decode BEFORE the window (refusal =
console abort exit 1, the bindings-error precedent), per-session seed
via `App::Cli.new_seed` (decision 16 — the fixed-seed-0 solo field is
dead; the host path shares the derivation), `--fresh` flag (solo lane;
usage updated), `TELEMETRY persist saved/loaded/fresh` lines +
`TELEMETRY session seed=N`; Window takes seed:/save:/saver: and closes
through the coordinator. Wall pins: test/harness/wall_pin_test.rb
(harness sources never reference persistence; harness World
constructions never pass save:). Canary sweep promoted from tmp/
scratch to `harness/run_canary.sh` + run_canary_test.rb (the
run_wall.sh lesson: load-bearing enforcement is tracked + tested).

**MEASURED evidence:** suite 706 green at hooks (13.4K assertions);
full-wall canary sweep 17/17 byte-identical after increment 1 AND after
increment 2 (harness/run_canary.sh; logs tmp/canary_sweep_v18*.log);
perf p95 0.192ms / 0.209ms (budget 16.6); LIVE solo E2E (real window,
Esc via tmp/post_esc.ps1 PostMessage): launch 1 `persist fresh` →
`saved digest=5691… sessions=1`; launch 2 `persist loaded digest=5691…
source=file` == launch 1's saved digest VERBATIM (the chain link),
fresh seed per launch (1469885794 → 1494427101), quit → `saved …
sessions=2`; `--fresh` backs up to `.bak-<ts>` and restarts the chain
at sessions=1. Exit status 0 on all three launches.

**Micro-decisions recorded (smallest faithful deviations):** (1) the
decoder refuses a 0-living save (`roster: no living member`) — the
load-side mirror of the projector's one-vessel assert; a tampered
all-dead save would otherwise softlock a loaded seat. (2) Lane 1's
"buys provisions" staging uses the `Pack#load_provisions!` apply-seam —
the sustain VERB is increment 5's; provisions state + digest + clamp +
round-trip are fully live now. (3) `refusal_for` carries `data:`
(validation needs zones/roster); the envelope-level schema check is
`envelope_refusal` — both halves of spec decision 6a. (4) `--fresh` is
solo-only until host custody lands (increment 3). (5) The fresh line
prints `TELEMETRY persist fresh schema=1 source=fresh` (no digest —
the chain starts at the first `saved`).

**NEXT SESSION — increment 3 (spec order, read the spec first):**
protocol v2, ONE bump for the cycle (decision 8: 11-bit mask with
:sustain — the BIT rides now, the verb is increment 5; the suite pins
the FINAL v2 vocabulary); SESSION grows save_schema/save_digest/save
(canonical facts STRING on the wire — the joiner digests RECEIVED
bytes BEFORE parsing, decision 5); host loads+validates before
listening + wire preflight of the ACTUAL encoded SESSION line vs
wire_budget_bytes (decision 6c); joiner strict-decodes during the
pre-window pump (no window on refusal); BYE vocabulary grows
save_schema/save_digest/save_invalid with refusal text for ALL refusal
reasons on BOTH seats, exit 1 (decision 6b — session.rb:357's
fingerprint-only detail is what gets widened); host SaveCoordinator
wiring (owner = host; the joiner NEVER writes); lane 3 two-session
netplay test with PER-SEAT tmp save roots (fresh→save→resume chain
over real loopback, carried fact asserted, joiner root EMPTY; refusal
lanes: schema skew / tampered facts / malformed pre-pump / oversize /
v1 peer); netplay gates re-run (`rake gate SCRIPT=harness/net/…
CHECKS=harness/net/gate_checks.json`); RC-matrix re-verified (refusals
exit 1 — launchers must NOT rehost). Then increments 4-8 per spec.
Canary baselines live in `tmp/canary_baseline/` — if tmp/ was cleaned,
re-bank from a sim-identical line FIRST, then sweep with
`harness/run_canary.sh` after every sim-touching increment. Junior:
pull — increments 1-2 landed; his PT-BR lane (PROVISÃO + cues) opens
at increment 6.

## 2026-08-17 late (v18 SPEC COMMITTED + FULLY RATIFIED — forks closed, dual review folded, veto window CLOSED "aprobado"; TDD opens next session, ROUND-TRIP LANE FIRST)

**Session product:** brainstorm → seven forks closed → spec + dual
review, per the spark. Spec:
`docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md`.
Reasoning record: `drafts/_v18-brainstorm-20260817.md` (+ post-review
addendum). Review ledger: `drafts/_v18-spec-review.md`.

**Forks:** F2/F5/F6/F7 = dev calls (host-authoritative save transferred
in SESSION; coop.json seat scalars; PROVISIONS priced sustain on an
11th input bit = protocol v2; god-view = offline `rake map` PNG).
F1/F3/F4 = owner-level — **RATIFIED IN-SESSION, veto window CLOSED**
(two owner messages: "en general todo ok" with two riders, then
"aprobado" delegating architecture timing to dev recommendation).
Riders routed to PARKING_LOT §"Owner ratification riders", zero v18
scope growth: (1) backpack/equipment + carried persistence = ITEM
CYCLE, v19 lead candidate with the dependency chain declared (loot
identity → inventory UI → equipment/stats → position persistence +
logout rules → schema v2) + RavenDawn/RavenQuest shelf research OWED
before that debate; (2) AWS = staged path (v18.1 S3 backup → cloud
custody → server-authoritative), timing delegated, named promotion
artifacts recorded: F1 what persists (characters + banked
+ arc; carried does NOT — Codex exploit kill), F3 banked persists
(re-opens D0 with the fun-thesis arrived), F4 solo advances the shared
world (custody honesty: the shared world lives on the OWNER's machine;
Junior solo = his own world — accepted by the owner).

**Dual review both legs done:** Codex REJECT → 21 findings, 20
CONFIRMED + folded (highlights: carried-persistence exploit; solo seed
was FIXED at 0 — window.rb:58; enter_zone does NOT normalize what the
draft claimed → explicit PURE projector; BYE refusal plumbing only
carried "fingerprint" — session.rb:357; save gating on clean quit only;
edge-triggered sustain; float-poisoning via absent-block scalar math).
Panel (deepseek/kimi/qwen-coder, 3×1 round ≈ 5.3K tokens, envelope
held): 9 folds (pinned canonicalizer — Ruby JSON doesn't sort;
exact-bytes wire digest — joiner digests RECEIVED string before parse;
projector purity; rename-failure lane + best-effort durability
disclosure; provisions cost 6→5 + lever order; de-primed Half B
questions; mercy-floor routing row; JUNIOR.md custody contract) + 2
REFUTATIONS with source evidence (peer-quit lands reason=:quit both
seats via BYE_REASONS; no stale-snapshot race — world constructs at the
READY→START barrier from Params frozen at launch). Do not re-litigate
either refutation.

**NEXT SESSION (TDD, spec order — read the spec first):** increment 0
bank canary baselines for all 17 wall scripts BEFORE any sim change →
increment 1 `Game::SaveState` + THE ROUND-TRIP LANE (pure projector,
strict decoder, mutation sweep, veil-tick sweep — the safety net; v17
digest-lane-first precedent) → increments 2-8 per spec. Spec is FINAL
(ratified twice); no owner input owed until the SEVENTEENTH's session 1.
Junior: pull — spec + drafts
landed; his lane this cycle = PT-BR strings (PROVISÃO + cues) +
JUNIOR.md custody section ratification + the SEVENTEENTH's session 2.

## 2026-08-17 (v17 CLOSED — SIXTEENTH CUMPLIDO; v18 ratified + founded; next session = v18 brainstorm → forks → spec)

**MEASURED:** junior-tibia green through the v18 contract commit; suite
650/9322 at hooks. The REAL owner+Junior session ran 2026-08-17 morning:
89575/89577 ticks (~25 sim-min), **desyncs=0 both seats**, reason=quit
both, BOSS 1 slain in co-op. VERDICT: **the SIXTEENTH is CUMPLIDO, both
halves** — `drafts/_v17-fun-verify-skeleton-20260816.md` (owner: "muy
divertido"; Junior: "muito bom jogo"). Same-day launcher bug found+fixed
(`15509d3`): cmd closes ( ) blocks at the first `)` inside echo text —
host-coop rehosted on EVERY status (owner couldn't Esc out), join-coop's
rejoin was dead code; both rewritten as goto dispatch, RC-matrix + live
Esc E2E verified. Seat-1 telemetry recovered from `%TEMP%` session logs
(play.cmd writes one per launch — that recovery saved Half A).

**v18 RATIFIED (owner 2026-08-17, "yes approved"): THE PERSISTENT WORLD
CYCLE — etapa 1.** Scope contract rewritten in AGENTS.md; foundation =
`drafts/_v18-foundation-20260817.md` (three lanes: coop feel + priced
sustain · persistence v1 host-authoritative save · god-view v0 offline
map; seven forks F1-F7 with dev positions; SEVENTEENTH oracle shape).
Owner vision drop routed in PARKING_LOT.md §"Owner vision drop" —
always-online PARKED with named trigger, accepted by owner.

**Next session (spark: `drafts/_v18-spark-20260817.md`):** brainstorm
against the foundation → close F1-F7 (batch owner-level F1/F3/F4) →
spec + dual review → stop. TDD after the spec, save/load round-trip
lane FIRST. Junior's seat: pull — the join-coop fix + Half A/B verdict
landed; his rejoin loop only exists post-`15509d3`.

## 2026-08-16 late (SIXTEENTH night support pt 2: tailnet LIVE, W6 fired + FIXED `10b6138`, handshake PROVEN cross-machine — real session still owed)

**MEASURED:** junior-tibia at `10b6138` (fix(net): fingerprint
EOL-normalized — suite 645/9315 green at hooks, all three netplay gates
re-PASS with critic). Both machines on ONE tailnet: gabo-desktop
**100.127.52.49** (this, moralgabriel@gmail.com — tailnet SWITCHED from
YeeVeeX@github tonight, revert = `tailscale switch yeeveex.github`) +
desktop-gu3bmkt 100.71.34.81 (Junior, user PPX approved). TSMP/ICMP
in-tunnel pongs both proven; direct path, no DERP.

**W6 fired for real at the first cross-machine join and is FIXED:**
refusal named `sim fingerprint` with both seats on clean 6f700d6 — root
cause: tree_md5 hashed raw bytes and EOL flavor differs per clone (my
Gemfile.lock w/crlf; autocrlf rewrites elsewhere). `10b6138` normalizes
EOLs in the fingerprint (TDD: failing CRLF-vs-LF test first). After the
fix the handshake CLOSED and lockstep RAN cross-machine:
`TELEMETRY netplay seat=1 ticks=81 desyncs=0 stalls=745
stall_ms_max=10014 reason=conn_lost` — 81 shared ticks, zero desyncs,
then the peer went silent (their side also agent-driven tonight; their
crash/exit UNEXPLAINED, their %TEMP% session log requested and pending).
Second connect died pre-handshake (ticks=0). No live desync artifact
exists. Full narrative: `drafts/_sixteenth-relay-pack-20260816.md`.

**The SIXTEENTH itself remains VIRGIN and owed:** no 10-min session, no
questions asked (owner asleep; his seat was agent-piloted only for
coordination + shakedown — pre-cleared). Next session inherits: (1)
their crash log → explain the two conn_losts; (2) the real owner+Junior
session per the skeleton (both pull ≥ 10b6138; owner double-clicks
Desktop `JUGAR COOP (host).cmd`; join 100.127.52.49; ≥10 sim-min; Esc
both; harvest both lines BEFORE questions); (3) adjudicate per
`drafts/_v17-fun-verify-skeleton-20260816.md` (note: skeleton's IP/steps
pre-date the tailnet switch — the join IP is now 100.127.52.49 and the
invite/approval steps are DONE).

## 2026-08-16 (v17 close-out session: SIXTEENTH = STANDBY — no evidence yet; prep relayed, skeleton banked, nothing new started)

**ADJUDICATED MECHANICALLY: no SIXTEENTH evidence exists.** No
`TELEMETRY netplay` lines pasted by either seat, no Junior telemetry in
drafts/, no new commits on junior-tibia (pull clean at `d4efa21`). The
four `tmp/netplay/desync_*.json` files were adjudicated as BUILD-DAY
residue, not live-session artifacts: two carry `platform:"test"` +
suite-fake fingerprints (`cccc…`/`dddd…`), one is the gate-manufactured
tick-60 desync (netplay_desync diverges at tick 40 by design), one is
the frame-key staging trap hit (tick 300, 18:35, recorded in session 3).
All four are `seat:2` = the in-process harness seat. Quarantined to
`tmp/netplay/build-residue-20260816/` so any artifact appearing in
`tmp/netplay/` from here on IS live-session evidence, unmistakably.

**Live blocker found (verified, not guessed):** Junior's machine is NOT
on the tailnet — `tailscale status` shows only mmh-gw (100.127.147.29,
this machine) + an offline iPhone. The owner's invite is the first
domino; everything else (JUNIOR.md ritual, launchers, TELEMETRY harvest
lines in both bin/play variants) is verified wired.

**Banked:** `drafts/_v17-fun-verify-skeleton-20260816.md` — v16-skeleton
precedent: session ritual, contamination disclosure (owner clean on all
netplay surfaces; Junior text-contaminated by label authorship, clean on
live feel), verbatim telemetry slots for BOTH seats, Half A arbiter
(desyncs=0 both ∧ reason=quit both ∧ ticks ≥ 36000), Half B questions
(es / pt-br, separate, no changelog), pre-registered routing verbatim.
Verdict section empty until both seats' lines are pasted.

**Prep relayed to owner (es):** invite → Junior accepts + `git pull` →
owner hosts `bin/play es --host`, passes 100.127.147.29 → Junior
`bin\play.cmd pt-br --join 100.127.147.29` → ≥10 sim-min (ticks ≥
36000) → BOTH exit by Esc → harvest BOTH TELEMETRY lines BEFORE any
question → questions separately (exact text in the skeleton). STANDBY.

**NEXT session:** evidence arrives → adjudicate per the skeleton (job 1
of the close-out SPARK); desync artifact → job 2 (both artifacts, diff,
name the field); start failure → job 3 (W6 lane). Nothing new starts
until the SIXTEENTH is adjudicated.

**SAME-NIGHT UPDATE (owner asleep, dev at his wheel by order — "he
already knows"):** full night-support log in
`drafts/_sixteenth-relay-pack-20260816.md`. Facts: invite link generated
from the owner's admin console + sent to Junior over the owner's
WhatsApp (CDP, disclosed as dev); "Approval is required" is ON — approve
in Users when he signs up; firewall verified NO-change (Tailscale-In
covers 100.127.147.29, Ruby has Allow rules); bind+accept over the
tailnet IP tested OK; `bin/host-coop.cmd` + Desktop `JUGAR COOP
(host).cmd` shipped + check-mode tested (pull --ff-only, live IP print +
clipboard). Dev line: tonight = SHAKEDOWN only (link/W3/W6 proof,
dev-piloted seat 1 mostly idle, disclosed to Junior); the 4 questions
stay VIRGIN; shakedown telemetry never upgrades to SIXTEENTH Half A (the
real session is owner+Junior). A desync tonight = job-2 work item, fully
valid.

## 2026-08-16 (v17 TDD session 3: increments 7-8 GREEN + PUSHED — app integration, Rule-2 netplay surfaces all gated, docs; v17 BUILD COMPLETE → the SIXTEENTH is next)

**MEASURED: increment 7 = `e0c2769` pushed (suite 644/9313 green at the
hook, perf p95 0.341 ms), all THREE netplay gates PASS with the critic
(session 13/13, desync 13/13, conn_lost 13/13 checks; determinism halves
byte-identical across double replays OVER REAL LOOPBACK TCP), full-wall
`rake canary` 17/17 byte-identical run TWICE (after the renderer edits,
re-proven after everything). Junior mid-session: PT-BR netplay labels
RATIFIED (`ae4e960`, "ta legal assim", DESSINCRONIA kept) — shipped
strings are the ratified table verbatim.**

**Increment 7 shipped:** `App::Cli` (locale-aware launchers forward args;
--host [port] / --join ip[:port]; refusal + usage errors abort nonzero at
the console — joiner refusals resolve PRE-window via a bounded pre-pump in
main.rb); Window session mode (≈30 lines: monotonic-ms clock owned by the
app, attach-on-params, Esc → quit! + drain, end screens hold until Esc,
TELEMETRY + desync path + relaunch printed at close; window.rb = 129
lines); `App::NetplayOverlay` (pure `flags` resolution headless-tested
against REAL loopback sessions + Gosu draw: HOSTING+PORT / CONNECTING… /
stall `WAITING FOR PARTNER`+ms top-center / LINK SLOW y=88 while
ticks<net_banner_frames / `WAITING AT GATE` y=130 / `NO BODY — WAITING` /
DESYNC+artifact-path and CONN LOST full-veil screens); partner ring =
cyan `partner_ring_rgb` [80,200,220] in display.json (decision 10 — rings
only, body labels + ALLY_DIM untouched); waiting-seat nil-guards
(stagger veil, station ledger, controls strip hides — all unreachable
single-player, canary-proven); `World#gate_wait` cue feed (recomputed per
non-hitstop tick inside check_transition); Session hardening (quit! with
no wire ends immediately — Esc on HOSTING; `sever!` fault-injection seam;
port cached at bind; telemetry stall_ms_max rounded); netplay strings
en/es/pt-br (es mine, pt-br = Junior's ratified Part B).

**The Rule-2 vehicle:** `harness/scenes/netplay_scene.rb` — two REAL
Worlds + two REAL Sessions over loopback inside the replay window,
seat-1 view through the REAL Renderer + NetplayOverlay; now_ms = frame ×
16.67 (pure function of tick — the determinism law); fault keys:
join_at/handshake_stride (slow probes → clamped D + LINK SLOW,
deterministic), freeze windows (stall), sever_at, quit_at, and TICK-KEYED
sim pokes. Scripts in `harness/net/` (run_wall's glob never sees them):
netplay_session (hosting→connecting→LINK SLOW→rings in motion→stall→
gate-wait→no-body→clean quit, 12 captures), netplay_desync (divergence at
tick 40 → DESYNC AT TICK 60 exactly), netplay_conn_lost (sever → CONN
LOST). `rake gate` grew optional `CHECKS=` (default untouched — wall
behavior identical); netplay checks ADD-ONLY in
`harness/net/gate_checks.json` (13 checks, not-exercised clauses for the
mutually-exclusive endings).

**One trap hit + fixed live (recorded in the scene header):** staging
pokes keyed by SCENE FRAME landed at different SIM TICKS in the two
worlds (they run ~D apart) and manufactured a real desync at the next
boundary — caught by the first timing run's digest counters. Fix:
sim-mutating pokes (teleports, kills) are keyed by WORLD TICK and applied
to each world as ITS OWN tick count crosses the key; only wire/app pokes
(sever/quit) stay frame-keyed.

**Dev calls on record (within closed design):** (a) reason=protocol
shares the CONNECTION LOST screen — TELEMETRY stays honest with
reason=protocol (trusted seats; a wire speaking wrong reads as a broken
link); (b) host-side refusal ends via screen + console detail after
close, joiner-side refusal = console + nonzero with NO window (spec's
bindings-error precedent read strictly for the seat that must act);
(c) WAITING AT GATE is a screen-space top-center cue (the blocked gate is
under the player's own body — context unambiguous); (d) the waiting
seat's controls strip hides entirely (no body, no instruments — the
overlay carries the state); (e) partner body keeps ALLY_DIM under its
cyan ring (rings-only law read minimally).

**Increment 8 shipped:** JUNIOR.md netplay section PT-BR-first (folded
from Junior's live-verified handoff `d1d7542` — Tailscale 1.102.2 direct
download, logged-out-until-invite, pull-before-play ritual, what-you-see
table, Esc + TELEMETRY harvest) + EN mirror; AGENTS.md Commands (netplay
launch + gate family + CHECKS=) + reference-wall pointer to the
systemic-worlds research shelf (adopted this session: VERIFIED/CORRECTED
may land in specs/data with citation, FLAGGED never without
re-verification); PARKING_LOT etapa-2 netcode entry (UDP+redundancy,
adaptive D, rejoin/rollback, host migration — with pre-registered
routing).

**NEXT — the SIXTEENTH ask (protocol pre-registered, spec §Fun-verify;
PREP ONLY, never run by a dev session):** owner sends Junior the tailnet
invite; Junior accepts + `git pull`; owner hosts `bin/play es --host`,
passes his 100.x IP; Junior joins `bin\play.cmd pt-br --join <ip>`;
≥10 sim-minutes (≥36000 ticks), exit by Esc BOTH seats. Harvest BOTH
`TELEMETRY netplay` lines BEFORE any question (Junior pastes his —
drafts/ or relay). Half A arbiter: desyncs=0 both AND reason=quit both
AND ticks ≥ 36000. Half B: the 4 pre-registered questions per seat,
asked separately, no changelog shown. Routing pre-registered in the spec
(desyncs>0 → digest-diff work item; stall storms + clean digests →
etapa-2 UDP debate; "paralelo" → v17.1 embodiment presentation debate).
If a desync artifact appears on either seat: BOTH tmp/netplay/ artifacts
are the work item ("bank the diff, don't average it").

## 2026-08-16 (v17 TDD session 2: increments 4-6 GREEN + PUSHED — Lockstep, Fingerprint/Wire/Session, two-sim integration lane; wall untouched by construction)

**MEASURED: junior-tibia `8d0902d` pushed (pull clean both ends — no
Junior commits today), suite 625/9274 green (hook-run at every commit),
perf p95 0.289 ms, netplay integration lane 0.314 ms/tick (two sims +
wire, one process — 25x under the 8 ms ceiling), diff f2430f5..HEAD
touches ONLY data/netplay.json + src/net/ + test/net/ (no src/game, no
src/app, no harness/scripts → no wall re-run owed; the three headless
canaries ride `rake` and are green).**

**Increment 4 — `Net::Lockstep` (`b223038`), pure scheduler + `data/
netplay.json` (Rule 3: port 43117, delay {4,12,8,3}, digest_every 60,
stall_warn 500 ms, abort 10000 ms, drain 2000 ms, probes 5):** per-seat
queues, ticks 0..D-1 by-definition empties; sampling law MECHANICAL —
submit_local exactly once per executed tick, raises on double-submit,
on submit-while-stalled ("samples NOTHING"), and advance!-before-submit
(W4's ordering sin); duplicate slot differing = Protocol::Fault,
identical = idempotent (pre-D slots included: nonzero mask for slot <D
faults); stall ledger in CALLER-FED wall ms (total/run/max-run +
stall_ms_max, warn/abort verdicts returned never acted); boundary
retention ceil((D+RTT_ticks)/N)+1 enforced BOTH maps (local windows
awaiting peer + peer md5s awaiting local — overflow = cadence fault);
desync compare machine latches (ready? false forever, drain traffic
ignored not faulted), late/bursty schedules tested; latch_desync!(t)
for peer-declared halts counts desyncs on both seats; derive_delay =
clamp(ceil(median/2/16.67)+jitter, 4,12), median not mean (outlier
test), probe failure → default 8, above-clamp → LINK SLOW flag. 27
tests.

**Increment 5 — Fingerprint + Wire + Session (`0907b0a`):**
`Net::Fingerprint` (sorted relpath:content-md5 over src/**/*.rb +
data/** + Gemfile.lock, bindings.local.json EXCLUDED; mismatch print
NAMES each differing field + `git pull` hint). `Net::Wire` (Qwen fold
pinned: ONE drain per pump — select(0) probe + read_nonblock
`exception: false` [same discipline as the WaitReadable rescue, no
exception cost], EOF/ECONNRESET/EPIPE → dead_reason, Oversize
mid-stream → dead (conn_lost taxonomy), partial writes retained,
NODELAY getsockopt-verified). `Net::Session`: phase machine
LISTEN→HELLO→PROBE→SESSION→READY→RUN→END with per-phase ALLOWED table +
role guards (out-of-phase = fault); host=seat 1, session_id =
seed^epoch hex, sequential probes host-measured, D via derive_delay,
SESSION carries d/digest_every/link_slow (optional field — pinned
vocabulary untouched); READY→START barrier gates on BOTH callers'
attach(world); run loop = pump→sample→submit→send INPUT→advance→
fold_input→world.tick→boundary digest exchange; termination machine =
DESYNC exchange + bounded drain / BYE{quit} drain / reason precedence
desync>protocol>conn_lost>quit; desync artifact
tmp/netplay/desync_<sid>_tick<B>.json (manifest+snapshot+lines);
TELEMETRY line exposed (printed by the app at increment 7). Handshake
timeout: any post-connect pre-RUN phase stuck >abort_stall_ms =
conn_lost; :listen EXEMPT (hosting waits indefinitely). Tests over REAL
127.0.0.1 (port 0 ephemeral): happy path (D=4 from 10 ms fake-clock
rounds), D derivation (100 ms→6), LINK SLOW both seats, barrier holds
until both attach, fingerprint/version refusal naming the field on BOTH
seats, clean quit both-reason=quit, raw-socket peer faults (out-of-
phase INPUT, garbage JSON), silent-peer timeout, listen-alone never
times out. 12+8+6 tests (session/fingerprint/wire).

**Increment 6 — the etapa-1 lane (`8d0902d`,
test/net/netplay_integration_test.rb):** two REAL Worlds (seed from
handshake, seats: 2) + two REAL Sessions over loopback in one process,
scripted seat inputs, synchronous alternating pumps, fake ms clock.
(1) HOLD: 3000 ticks, zero desyncs, tick counts equal, 50/50 window
md5s identical, boundaries compared live, both quit at the same tick →
TELEMETRY identical modulo seat, zero stalls; perf print + ≤8 ms
assert. (2) DIVERGENCE: `wh.pack.bank!(1)` at tick ~32 → desync at
boundary 60 exactly, both reason=desync, desyncs=1 both, artifact
written (both seats' write paths exercised; same file in-process),
snapshot+manifest+differing md5s verified. (3) STALL: freeze seat 2's
pump → host warns (stall_warning_ms overlay feed) then aborts at
10000 ms fake-wall → conn_lost; thawed seat discovers BYE/EOF →
conn_lost BOTH ends.

**One trap hit + fixed mid-increment-5:** the joiner has no way to know
probes ended except SESSION itself — ALLOWED[:probe] must include
:session or the handshake protocol-faults on its own happy path (caught
by the first live loopback run; fix = allow + transition in
handle_session).

**Session-2 dev decisions on record (within closed design):** (a)
rtt_ticks for the retention bound = D on BOTH seats (D already embeds
half-RTT + jitter; bound reads identically both sides); (b) submit-
while-stalled raises (the spec's "samples NOTHING" made mechanical, not
just conventional); (c) Wire uses `exception: false` nonblocking calls
(identical semantics to the pinned WaitReadable rescue, cheaper); (d)
Session exposes telemetry_line/stall_warning_ms/refusal — PRINTING is
increment 7's job (window/CLI); (e) BYE{conn_lost} best-effort sent on
stall-abort so the frozen peer can print honestly on thaw.

**NEXT SESSION — increment 7 (app integration + Rule-2 surfaces), NOT
started here on purpose (never start the Rule-2 loop without room to
finish it green):** CLI `bin/play [locale] --host [port] / --join
<ip[:port]>` (BOTH launchers forward args past the locale), src/main.rb
parse, Window session mode (sample→submit→pump→advance?→tick ≈30 lines,
cap law; print TELEMETRY at close beside the sim summary; wire
Process.clock_gettime(:MONOTONIC)*1000 as now_ms; Esc → session.quit!),
presentation states (HOSTING—WAITING FOR PARTNER +port / CONNECTING… /
stall overlay `WAITING FOR PARTNER`+ms via session.stall_warning_ms /
LINK SLOW banner via session.link_slow / DESYNC AT TICK N—SESSION ENDED
+ report path / CONNECTION LOST—SESSION ENDED / NO BODY—WAITING /
WAITING AT GATE cue), partner ring (second color in display.json,
decision 10 — rings only, PARTNER wording), then the harness/net script
family (netplay scenario: two Worlds + two Sessions in the replay
window, seat-1 view; netplay_session / netplay_desync /
netplay_conn_lost) + the CHECKS= gate argument (default untouched —
netplay checks in their own file, ADD-ONLY) + full gates (Rule 2
BLOCKING: capture + critique per state). Window/renderer changes =
Rule-2 visual changes; if src/game or the renderer is touched, the
three headless canaries + full-wall `rake canary` (baselines
tmp/canary_baseline/, machine-local — RE-BANK from a sim-identical line
first if tmp/ was cleaned). Then increment 8 (JUNIOR.md netplay section
PT-BR-first, AGENTS commands note, PARKING_LOT: UDP/adaptive-D/rejoin,
checkpoint) → the SIXTEENTH ask (protocol pre-registered in the spec
§Fun-verify; owner hosts, Junior joins over Tailscale, ≥10 sim-min,
telemetry harvested from BOTH seats BEFORE questions).

## 2026-08-16 (v17 TDD session 1: increments 1-3 GREEN + PUSHED — digest lane, seat plumbing, protocol; full-wall canary 17/17 byte-identical)

**Increment 1 — DIGEST LANE (`155c059`):** `Net::EventSerial` extracted
from WorldScene#describe (ONE serialization for wall EVENT lines + the
netplay digest); `Harness::EventLog` (curated list, world_scene consumes
it); `Net::StateDigest` (folds EVERY registered bus event via new
`EventBus#registered_types`, input masks via fold_input, canonical
snapshot at each window boundary; Window records retain lines+snapshot
for the decision-8 artifact); `digest_fields` on Creature/Pack/
Projectile/Feel + `World#digest_snapshot` (flat named scalars, stable
ids, presentation excluded); `Core::CountingRng` wraps both seeded
streams (value-transparent; draw counts in the digest — panel fold).
Suite: decision-6 coverage pins + scalar-leaf guard + schema flip sweep
+ live-mutation battery + THREE banked etapa-0 canaries headless in the
default suite (test/harness/sim_identity_canary_test.rb, <2 s).
**Evidence:** live `rake capture` world_loop EVENT md5 =
`a4150c43669b9783e59cb6c39c322b67` (banked value, byte-exact).

**Baselines banked BEFORE seat plumbing:** one replay per wall script
into `tmp/canary_baseline/<script>/` (17 dirs, 172 PNGs, manifest.md5).
MACHINE-LOCAL and gitignored — if tmp/ is ever cleaned, re-bank from a
sim-identical line before the next sim-touching increment.

**Increment 2 — SEAT PLUMBING (`a367586`):** Pack seat map (per-seat
pointers, bare arity = seat 1, partner exclusion, waiting = nil, wipe
keeps the dead vessel pointer); World `seats:` kwarg + `tick({seat =>
input})` (bare input wraps); per-seat controllers/swap-edge/rearm/
last-damaged/cameras (decision 5, same call site); decision-11
semantics: `controlled_bodies`/`seat_for`/`controlled?`, AI drives
uncontrolled bodies (+ nearest-controlled follow anchor), verb guards
take any seat's own body, mark last-write-wins + any-seat leash,
seizure targets nearest controlled body, **zone gates = co-location
consent** (trigger body ON the gate tile, every other living controlled
body within Chebyshev 1; dead/waiting don't block), pack_wiped
exactly-once (same-flush double death), judgment assigns seats over the
ACTUAL revived set in seat order (floor: seat 1 takes the vessel, seat
2 waits), vat regrow auto-repossesses waiting seats (roster order,
from: nil event), renderer+overlay `local_seat:` seam (default 1).
17-test battery in test/game/seats_test.rb.
**BLOCKING evidence: full-wall `rake canary` 17/17 scripts, every
capture byte-identical to the pre-refactor baselines; suite 559 green;
perf p95 0.280 ms.** One trap hit + fixed mid-increment: adding a
`!dead?` filter to validate_mark broke single-seat byte-identity (the
old law measured from a mid-flush dead pointer body) — reverted;
single-seat identity means preserving even the weird edges.

**Increment 3 — PROTOCOL (`6510223`):** `Net::Protocol` (version 1,
PINNED 10-bit action order — change = version bump; message vocabulary
with required-field shapes; encode/decode; Fault→protocol vs
Oversize-mid-stream→conn_lost taxonomy), `Net::SampledInput` (frozen
mask, no live-source reference — sampling law by construction),
`Net::FrameBuffer` (split/coalesced/partial reassembly, unterminated
>4096 raises). INPUT line pinned ≤40 B. Phase enforcement deliberately
deferred to Session (increment 5).

**State: junior-tibia `6510223` pushed (pull was clean at every push —
no Junior commits today), suite 569/9019 green (hook-run), wall canary
17/17, perf p95 0.280 ms, tree clean except tmp/.**

**NEXT SESSION (spec order — read the spec first, increments 4-8):**
(1) **Increment 4 — `Net::Lockstep`** pure scheduler (NO I/O): per-seat
input queues, delay D, empty inputs for ticks < D, `ready?(t)`,
submit-once-per-executed-tick + duplicate-slot fault (differing mask =
protocol fault), stall counters (total/current-run/max-run),
warn/abort thresholds in WALL ms (app-layer clock — the sim never reads
clocks), digest boundary bookkeeping + retention bound
ceil((D+RTT_ticks)/N)+1, desync compare state machine; **create
`data/netplay.json`** (Rule 3: port 43117, delay {4,12,8,3},
digest_every 60, stall_warn_ms 500, abort_stall_ms 10000,
drain_timeout_ms 2000, probe_count 5). (2) Increment 5 — Fingerprint
(bindings.local.json excluded) + wire + Session handshake over real
127.0.0.1 loopback (Windows pump discipline block: one drain per
update, WaitReadable rescue, NODELAY getsockopt verify). (3) Increment
6 — two-sim integration lane (hold/divergence/stall/handshake, ~3k
ticks, no threads). (4) Increments 7-8 per spec (Rule-2 surfaces +
harness/net family + CHECKS= gate arg; docs/close). The three headless
canaries + full-wall `rake canary` re-run after ANY increment that
touches src/game or the renderer.


## 2026-08-16 (v17 SPEC COMMITTED: five forks closed with the owner in-session; dual review folded — TDD opens next session, DIGEST LANE FIRST)

**Owner in-session closed ALL FIVE forks on dev recommendation
("aprobado, procede"):** (1) embodiment = SHARED PACK (two seats, two
possession pointers, AI drives the third body); (2) delay-based lockstep,
D fixed per session from a handshake RTT probe (clamp 4..12, default 8),
TCP_NODELAY stdlib, no threads; (3) host/join + verified manifest
(sim fingerprint excl. bindings.local.json; mismatch refuses with the
exact diff); (4) desync = state+event digest every 60 ticks, detect
LOUDLY, end honestly, artifact on both seats; (5) stall warn 500 ms /
abort 10 s wall-clock, LINK SLOW honesty. Also answered the owner's
GameLift question on the record (client needs no AWS account — the real
reasons are no-Ruby-SDK, lockstep needs no server, and it replaces only
the already-solved part; owner satisfied, path unchanged).

**Spec committed `7a21e84`:**
`docs/superpowers/specs/2026-08-16-v17-multiplayer-etapa1-design.md` +
review ledger `drafts/_v17-spec-review.md`. **Codex leg REJECT → 12
findings, 10 confirmed + folded** (authoritative digest snapshot w/
mutation-sensitivity sweep; sample-once-per-EXECUTED-tick law; ms-based
stall abort; termination state machine + reason precedence; decision-11
seat-semantics table for every bare-`possessed` call site; renderer
`local_seat:` seam; full-wall `rake canary` baseline protocol; BODY-
relabel REVERSED — rings only, PARTNER wording; harness/net script
family + CHECKS= gate arg; framing/handshake pins). **Panel (declared
≤4 lenses/1.5M; actual 3 agents ~13K tokens):** DeepSeek (end-reason
precedence fold + CountingRng replaces Marshal-bytes in the digest),
Kimi (zone gates now need EVERY living controlled body co-located —
consent by geometry; relaunch-hint mitigation), Qwen (Windows winsock
pump discipline). Three REJECT-grade claims REFUTED with written
reasons in the ledger (lockstep deadlock, GC sampling, Gosu cadence) —
don't re-litigate. Codex `--sandbox read-only` is BROKEN on this
machine (os error 206); use `--sandbox danger-full-access` + no-write
prompt order.

**State: junior-tibia `7a21e84` pushed (synced), suite 527/2329 green
(hook-run), tree clean, wall untouched.** Junior's seat landed
`drafts/_junior-sessions-3-4-20260816.md` mid-session: seal-1 economy
wall, "não consigo é muito difícil", recorded-only, routing condition
MET → onboarding/curve is NEXT-DEBATE material (not v17 scope; note:
co-op with the owner is itself a live hypothesis against that wall).

**NEXT SESSION (TDD, spec order — read the spec first):** increment 1
DIGEST LANE FIRST (shared event-serialization helper + StateDigest +
mutation sweep + headless canaries vs the three banked etapa-0 md5s),
THEN bank full-wall canary baselines BEFORE any seat plumbing; then
increments 2-8 per spec. Coordinate Junior via drafts + handoff
validate (pull before push — his seat is ACTIVE today). SIXTEENTH ask
protocol is pre-registered in the spec §Fun-verify.

## 2026-08-16 (v17 DEBATE CLOSED: MULTIPLAYER ETAPA 1 — owner ratified; brainstorm opens next session)

**Owner ratified at the debate (verbatim "ok procede como recomiendes, lo
apruebo"): v17 = multiplayer etapa 1** — live lockstep co-op with Junior
over Tailscale, on the dev recommendation. Both triggers adjudicated
CUMPLIDOS: #1 Junior at etapa 0 (first session + strict exchange + his
own sim-identity re-run on the placeholder line, 3/3 digests, `b7beb85`);
#2 v16 shipped (wall 17/17 + fifteenth partial win). **Scope contract
REWRITTEN in AGENTS.md** (v16 text retired to git history per the
one-cycle law): IN = etapa 1 + named design forks (embodiment,
tick-sync/input-delay, bootstrap, desync-detect-loudly policy, latency
budget) + digest instrumentation + two-sims-one-process netplay test
lane + Rule-2 on new UI; OUT = >2 players, rollback/resync, open
internet, voice, dread iteration (open-for-exposure), all lore
(standing order). Oracle = the SIXTEENTH ask, two halves: session HELD
(digest counters both seats) + felt like playing TOGETHER (both players
asked separately). PARKING_LOT updated (dread-exposure rider, v16
leftovers, repo-hygiene notes: junior/ci deletion is Junior's call,
main sync is the owner's).

**State at close: junior-tibia synced 0/0, suite 527/2329 green, wall
17/17 (tag placeholders), perf p95 0.365ms, tree clean.**

**NEXT SESSION (v17 execution opens — in order):** (1) brainstorm → the
five forks close on dev recommendation + owner veto (v13 precedent) —
read first: PARKING_LOT multiplayer section + both etapa-0 drafts
(`_junior-etapa0-20260815.md`, `_junior-etapa0-20260816.md`) + JUNIOR.md;
(2) spec `2026-08-XX-v17-multiplayer-etapa1-design.md` + dual review
(Codex first, then panel — Rule-7 envelope declared); (3) TDD increments
(digest lane first — it is the safety net everything else stands on);
(4) coordinate Junior's seat via drafts + handoff validate (he is active:
CI, PT-BR labels, playtests); (5) SIXTEENTH ask = first real two-seat
session. Owner queue: nothing pending — Junior heads-up already sent
(clipboard note), lore archive shared.

## 2026-08-16 (FIFTEENTH ran — v16 closes PARTIAL WIN; v17 debate OPEN at close)

**FIFTEENTH ask (session 36749, es, ~9 min sim):** 17 fights / 2 wipes /
9 banks (max 68) / seal1 breached / ZONE 3 entered (58 kills) / 6
inscriptions / 10 tributos. Owner declined per-question granularity;
global verdict verbatim: "se siente bien" + "todo bien, lo disfruté" —
first unprompted positive global in verify history; ZERO negatives named
→ no routing lane fires. **Q2/Q3 (BOSS 1 dread) UNEXERCISED** (seal2
never breached, ZONE 5 = 0 frames, engaged=0; ledger precedent) — the
dread half stays OPEN-FOR-EXPOSURE: fully built + walled, self-answers
whenever a session crosses seal2. **v16 CLOSES: PARTIAL WIN** (verdict +
telemetry verbatim: `drafts/_v16-fun-verify-skeleton-20260816.md`).
Placeholders drew zero complaints in play.

**Session also closed earlier today (same seat):** lore removal order
executed end-to-end (see entry below), wall 17/17, three check
amendments RATIFIED in-session, lore archive shared
(github.com/YeeVeeX/game-two-lore, private, Junior invited, skills
in-repo), PT-BR heads-up note delivered to owner's clipboard.

**NEXT: v17 debate** — triggers at adjudication: #1 Junior at etapa 0
(evidence logged 2026-08-15; strict spike closed db2e83e on sim-identity
digests — placeholder batch touches no sim events, spike stands), #2 v16
shipped (wall 17/17 + fifteenth partial-win, owner ordered continue).
Dev recommendation ON RECORD: v17 = multiplayer etapa 1
(lockstep-over-Tailscale staged path, banked research in PARKING_LOT);
dread-exposure rides free (no code); language program stays dead (owner
order). Scope contract rewrite rides the debate close.

## 2026-08-16 (OWNER ORDER: LORE REMOVED — placeholders only; FULL WALL OWED before push)

**Owner order (this session): remove ALL lore/names/creative writing from
project+repo; leave generic placeholders (zone1/hub1/boss1/player1...);
creative writing separates from this repo completely.** Context: the
bible-rework session died honestly — phase-0 taste battery: EVERY control
read dumb (QUEDA stamps "forzado", ratified zone names "falso", flesh
lines "macabro"; only Vessic god names scored "fuerte"); phase-1 frames
(3 notarial re-skins — dev miss, all contained PAGADO) rejected; phase-1b
divergent seeds (jauría/ronda/apuesta) rejected ("C se oye mejor" at
best); owner then named the root: the project hardcoded a mold and lore
was eating game time. Order executed same session.

**Executed:** creative writing EXPORTED to
`C:/Users/gabri/workspace/game-two-lore/` (bible, 13 lore drafts,
threketh.json, writ cover) then git rm'd. Strings en/es/pt-br →
placeholders: ZONE 1 (nest), ZONE 2 (district), HUB 1 (camp), ZONE 3
(district_two), ZONE 4 (slow_door), ZONE 5 (low_quay), BOSS 1 (challenger),
BOSS 1 SPAWNED / BOSS 1 DEFEATED / MARK LOST / TOLL PAID, vessels player
1/2/3 — names locale-invariant; functional verbs keep ratified
translations. Zone JSON display_names + station lines swapped; code
fallbacks (world.rb ×3, renderer nameplate, controls_overlay
VESSEL_FALLBACK); gate_checks.json recalibrated (7 checks de-lored);
tests updated (strings_test REWRITTEN — locale-precedence proofs moved to
verb keys; placeholder locale-invariance test added); README rewritten;
AGENTS.md standing order + register target + de-slop law amended;
PARKING_LOT (external lore home + optional internal-id sweep).
**Suite 527/2329 green. world_loop FULL gate smoke PASS (det 10/10 +
vision on recalibrated checks).**

**Kept (dev calls, on record):** internal mechanical ids (zone ids, event
names, kit names, harness script filenames incl. varekka_duel.json) —
player-invisible + replay/wall-load-bearing; renamed only on explicit
owner ask (parked). Engineering history (specs, verdicts, wall logs)
stays — records, not creative writing. wipe.line + challenger.called.line
stay ABSENT (textless beats). v16's language-lane NEXT item is DEAD; the
FIFTEENTH-ask protocol needs re-registration against placeholder surfaces.

**OWED before push (Rules 2/6 — DO NOT push junior-tibia until green):**
FULL wall re-run (`harness/run_wall.sh placeholders`) — this one
comparability reset also carries the 2026-08-16 text-removal debt
(varekka_duel / burn_duel / corpse_run / nest_advance / vat_economy reels
changed pixels). Expect identity-check arbitration on renamed banners;
W2 variance protocol; zone-start scripts need `captures/pilot/`;
nest_advance ~65 min; ONE window at a time; then `rake perf` + full
`bundle exec rake`. After green: pull-before-push (Junior's seat active).

**WALL RESET COMPLETE (tag `placeholders`, teed logs tmp/wall/*_placeholders*.log):**
**17/17** — 14 in-sweep PASS + 3 standalone: aoe_specials + respawn_telegraph
= W2 judgment variance (flipped on projectile_visible's CONTRADICTORY
leftover clause; both PASS standalone unamended), low_quay_run = REAL
reproduced fail → adjudicated BY EYE on frame_8610: bank tally `+5 / -6
(hollow) / = +5` is CORRECT SIM DESIGN (fight_ledger.rb bank! excludes
outstanding stranded value from the bank net — including it would
double-count across legs when corpses are recovered); the CHECK was
over-general (authored on fight beats; v14's exercised case "hollow -7 →
red -7 net" was a fight beat). Sim untouched.
**THREE check amendments applied — RATIFIED by the owner IN-SESSION
(2026-08-16, "procede como tu recomiendes, yo lo apruebo"; explained on
the record: repo/file scope, the frame_8610 adjudication, the coin-flip
clauses):** (1) ledger_negative_reads
split by tally kind — fight/wipe nets include stranded+destroyed (must
read negative with a loss line); bank nets exclude outstanding pip
(positive `= +N` beside hollow -N is CORRECT; sign/color disagreement
fails); (2) projectile_visible + (3) corpses_persist: contradictory
"mark pass=false with why='not exercised'" leftover clauses DELETED
(coin-flip generators — both flips this sweep landed on #2). All three
affected scripts re-gated on amended prose: PASS + manifests (aoe 8/8,
respawn 9/9, low_quay 11/11 byte-identical).
**PERF PASS p95 0.365ms; suite 527/2329 green; pushed junior-tibia.**
The placeholder surfaces read clean through the critic everywhere
exercised (TOLL PAID banner, ZONE N banners, player 1/2/3 strip, BOSS 1
stamps in duel scripts).

**NEXT:** (1) FIFTEENTH blind ask — protocol re-registered mechanically
against placeholder surfaces: same pre-registered questions/arbiters,
wording swaps only (Varekka→BOSS 1, the Quay→ZONE 5; oracle halves
unchanged: zone identity by look, boss dread, stamp delivery — all three
surfaces are visual and survived the text removal); (3) v17 debate
(multiplayer triggers: #1 evidence logged, #2 = v16 shipped — pending
the fifteenth). Owner queue: tell Junior the language lane moved to the
shared game-two-lore repo (private, he's invited; skills ship in-repo).

## 2026-08-15 (v16 WALLED 17/17 + TWO-SEAT RACE RESOLVED + v17 trigger #1 evidence — language lane + FIFTEENTH next)

**2026-08-16 addendum (owner-approved actions):** repo flipped **PUBLIC**
(owner call, this repo only; pre-flip secrets scan clean — no
credentials anywhere in history-visible files). Junior's CI PR #1
MERGED (`f68d7cb`); **first green Actions run verified**
(31935705779: gosu compiled on ubuntu, xvfb suite 526/2324 green,
~2.5 min). The 3-5s insta-fail root cause was NOT settings: August's
2000 free private-repo minutes were exhausted by portfolio-spine —
visibility flip removed the quota gate (public = free standard
runners). Junior's 5 follow-up commits pulled (trigger evidence #2,
proposals doc, md5 re-run, det pre-sweep, line-caps test — suite
carries it). Etapa-0 md5 verdict: 0/21 PNG bytes match cross-machine
(EXPECTED — fonts/encoder are machine-local); protocol corrected in
the draft to sim-identity evidence (telemetry lines + event-log
digest); Junior seat re-publishes, then the stage-1 spike closes.
Cosmetic: actions/checkout@v4 Node-20 deprecation annotation —
non-blocking, bump to v5 whenever convenient.

**MEASURED: junior-tibia `0ce2fd4` PUSHED (synced 0/0), suite 524/2322
green, 17 scripts, 53 checks, wall 17/17, perf p95 0.260ms.**

**WALL RESET COMPLETE (tag v16, teed logs tmp/wall/*_v16*.log, trail in
drafts/_gate-verdicts.log):** 16/17 in-sweep PASS; ONE real fail —
low_quay_run #51: the breach writ line predated the stamp grammar
(rendered flat while banner-slot stamps landed with rules+scale-in — the
critic caught my own increment-3 deviation as broken court ceremony).
Fix `5cb3138`: breach_line carries frames_total, renders through the
shared draw_stamp_line; capture 1442 added (straddles the 1430 arrival;
station seal mark beside the body). a2 standalone: GATE PASS
(determinism 11 byte-identical x2, 53/53 vision — #51 saw "rules +
settles smaller between 1430 and 1442") + MANIFEST PASS. Identity
recalibration held: #50 + reworded low_quay_reads/new_ground_reads all
PASS on the new look. Mid-sweep code-change audit: every pre-fix script
self-gated on stamp_delivery — no superseded verdicts.

**TWO-SEAT RACE (found at push): a parallel agent session on Junior's
machine executed the same checkpoint NEXT list** (9 commits, BRT
timezone, Co-Authored-By Claude) — same spec, same increments 3-5,
convergent designs, explicitly deferring wall/recalibration to this
seat. RESOLVED `0ce2fd4` (dev-of-record call, owner veto at the
debrief): owner-seat wall-verified line survives; their unique work
cherry-picked — **v17 trigger #1 evidence** (`3ae272f`: Junior's first
session, pt-br, ~15.1k frames, install clean, PT-BR zero lines named,
"divertida, quero mais"), **Junior-ratified PT-BR post-edit pass**
(`5d4c85b`: strip infinitives atacar/esquivar/marcar, O Corredor → A
Rua Longa; mark_void PT-BR correctly deferred to pipeline), README +
cover (`77ed763`). Their full line preserved in the merge's second
parent. **CAVEAT: their etapa-0 per-frame md5s were computed against
THEIR tree — the strict cross-machine determinism spike must re-run
against THIS line before it counts (v17 debate item).**

**NEXT (in order):**
1. **Language lane (OWNER-GATED)** — 3-probe register calibration ON
   CAPTURES (attested-notarial / plain / game-generic, owner picks
   blind) → grounded candidates ONLY for owner-named lines + ES for
   stamp.mark_void (EN fallback ships today) → on-capture ratification
   → Junior post-edits PT-BR (he's ACTIVE now — first session logged).
2. **FIFTEENTH blind ask** (spec §Fun-verify pre-registered; `bin/play
   es`; harvest telemetry BEFORE questions; arbiters: varekka
   interrupted + swap_escapes > 0, burns, quay dwell vs fourteenth).
   Owner also ratifies at the debrief: three check-prose
   recalibrations + the breach-mark-at-station deviation + the
   two-seat resolution.
3. **v17 debate** — multiplayer triggers: #1 evidence logged (owner
   adjudicates; strict md5 exchange re-run owed against this line),
   #2 = v16 shipped (pending the fifteenth).

## 2026-08-15 (v16 increments 3-5 SHIPPED: stamps + zone identity + dread — WALL RESET next)

**MEASURED: junior-tibia `7b452df` (7 commits ahead of the increment-2
checkpoint, NOT yet pushed), suite 524/2309 green (hook-run at every
commit), 17 wall scripts (+burn_duel), 53 checks (ADD-ONLY from 49),
perf p95 0.175ms, burn_duel FULL gate 53/53 + manifest PASS.**

**Shipped, TDD, each green+committed:** (c) stamp delivery `2f81c30` —
`App::Stamp` pure timing (scale-in endpoints in data / dwell /
final-third fade), acta rule pair, located stamps press floor SEAL MARKS
(world.seal_marks, banner clock, hitstop pauses, zone entry clears);
LIVE DEVIATION recorded: breach mark lands at the STATION, not the
opened way — gold-on-gold cannot read (capture-verified frame 1430).
(b) zone identity `7b7b407` — `App::ZoneIdentity` pure policy (motif =
integer (tx*7+ty*13+seed)%9 placement, 4 glyphs; decor =
stain/brazier/edge authored landmarks; ambient tint), six palettes
redesigned (First Vigil ash+ember, Longrow clay/ochre, Keyward cold
slate — brass retired, Second Vigil warm gray + 4 braziers, Slow Door
dusk violet, Low Quay drowned green-black + channel-lip edges + stains),
luminance contracts unit-tested (wall>floor spread ≥40, motif between,
ambient ≤24). (d) dread `804fdff` — seizure_burns_inscription data
switch: seized death burns the god-mark BEFORE corpse bookkeeping
(DeepSeek ordering fold by construction; burn+wipe double-consume
impossible — tested), :inscription_burned registered, THE MARK IS VOID
located stamp, telemetry varekka gains burns=N; writ-frame (App::Writ
pure bands, GLM fold) + seized body weight (chant-blue darkening).
Checks 49→53 `050fb87..` + burn_duel exerciser `7b452df`.

**THREE check-prose recalibrations AWAIT OWNER RATIFICATION at the
fifteenth debrief** (spec pre-registers critic recalibration;
Nest-rename law; amendment precedent #14/#19/#42): low_quay_reads
(indigo-black → drowned green-black + landmarks), new_ground_reads
(Keyward black-and-ochre → cold slate-and-indigo; camp ember-brazier
prose), seizure_reads (additive: body-scale blue darkening). ES/PT for
stamp.mark_void deliberately absent (EN fallback) — the language lane
authors it.

**Pilot doctrine banked (4 burn attempts, ~40 min):** the quay swarm
kills uncontrolled allies within ~600f EVERY time — a burn scene cannot
protect them; burn4 stopped trying and let the wipe close the scene
(the script's honest tail). `goto guard=N` is a TICK BUDGET, not enemy
proximity (two aborted attempts misread it). The pin-survives-swap
mechanism (challenger_test \"the pinned FLESH answers\") is the way to
stage an ally-burn WITH survivors — unused this time, banked for future
scenes. start.inscribed + world_scene inscription_burned logging are
the two harness pieces that made the scene stageable at all (burn1's
sim fired the burn SILENTLY — no logger line, no manifest).

**NEXT (in order):**
1. **WALL FULL RE-RUN** — comparability reset, all 17 scripts:
   `harness/run_wall.sh v16` (teed logs tmp/wall/, nonzero exit on any
   fail). Expect: identity-check arbitration on the recalibrated prose;
   W2 variance protocol (standalone retry before believing a FAIL, real
   fails reproduce); zone-start scripts need `captures/pilot/` present;
   nest_advance is the ~65-min monster; ONE window at a time (never
   concurrent gates). Then `rake perf` alone + full `bundle exec rake`.
2. **Language lane (OWNER-GATED)** — 3-probe register calibration ON
   CAPTURES (attested-notarial / plain / game-generic, owner picks
   blind) → grounded candidates ONLY for owner-named lines + the new
   stamp.mark_void ES/PT → on-capture ratification. Junior post-edits
   PT-BR when active.
3. Push junior-tibia → **FIFTEENTH blind ask** (protocol + routing
   pre-registered in the spec §Fun-verify; `bin/play es`, telemetry
   harvest BEFORE questions — arbiters: varekka interrupted +
   swap_escapes > 0, burns, quay dwell vs fourteenth).
4. v17 debate (multiplayer triggers: Junior playing at etapa 0 + v16
   shipped).

## 2026-08-15 (v16 increments 1-2 SHIPPED: scaling + kill pop — increment 3 next; Junior cloning)

**MEASURED: junior-tibia `2375335` synced 0/0 with origin, suite 474/2031
green (hook-run at every commit), window.rb 84/300.**

**Shipped, TDD, each green+pushed:** (a) resolution scaling `c43a0f0` —
`App::Scale` pure policy + window wiring, `window_scale: "auto"` in
display.json, harness pinned by construction (structural test), **canary
proof: 10 captures byte-identical to the pre-change baseline**; (e) kill
pop `21d3c9d` — `world.kill_pops` transient records (taunt_pulses
pattern), `App::KillPop` integer shard geometry, flash-primary renderer
draw, keys in combat.json feel + display.json.

**Two traps hit + banked:** (1) the possessed's kill hitstop PAUSES pops
— the spec's own law; the test burns `hitstop_frames_kill` before
measuring (HITSTOP_SLACK precedent). (2) Suite-green ≠ game-runs: the
renderer used `App::KillPop` without requiring it; test load-order masked
it; the world_loop replay CRASHED at frame 643 and the determinism gate
caught it (v15 chant-crash class). Fix: explicit require; the gate is the
backstop for require hygiene.

**Owner feel-check (informal, NO protocol):** ~220 kills / 22 fights /
5 wipes / 10 banks / seal 1 paid at the new scale with pops live. No
impressions volunteered; open question stands.

**Junior: CLONING NOW (first engagement).** JUNIOR.md clone snippet fixed
same day (`6b75f51` — bare clone landed on main, which runs behind; now
`-b junior-tibia`). When his window opens: `bin\play.cmd pt-br`, report
install errors verbatim + PT-BR lines that read wrong. First working
session = **v17 trigger #1, log it in the scope contract**.

**NEXT (fresh session, spec order — read the spec first:**
`docs/superpowers/specs/2026-08-15-v16-presentation-identity-design.md`**):**
increment 3 stamp delivery (display keys + stamp path in draw_banner +
floor seal marks for located stamps + timing tests) → 4 zone identity
(6 palette redesigns + motif/ambient/decor channels + fallback
byte-identity test) → 5 dread (inscription burn sim + writ-frame +
seized weight; burn ordering tests per review fold) → language lane
(3-probe calibration with the owner ON CAPTURES, grounded candidates for
named lines only) → WALL full re-run (comparability reset; expect critic
recalibration on identity checks, INFRA-flake retry protocol applies) →
perf → FIFTEENTH blind ask (protocol + routing pre-registered in the
spec) → v17 debate (multiplayer triggers check).

## 2026-08-15 (FOURTEENTH WON on livability + v16 SCOPED: presentation/identity — multiplayer deferred to v17 behind triggers)

**FOURTEENTH blind verify (semi-blind — contamination disclosed, skeleton
item 5):** owner session 1902617848, ~22 min / 44 fights / 5 wipes / 18
banks (max 261 banked out of the quay). Quay entries 2→5, frames
1137→6061 (5.3x), kills 4→52 — **ZONE VALIDATED** ("ganado"), **TAX-WALL
CLOSED** (Q5a), fork-1 validated (Q4a "parte de la cacería"), **economy
arc CLOSED POSITIVE** (first since D0), guard-scope 5th clean. Varekka:
chants=2, seized=2, deaths_while_seized=2, interrupted=0, slain=1 — Q2b
flat + seized>0 → **DESIGN PROBLEM per pre-registered routing**
(fair + legible + affordable ≠ scary; seizure threatens a body and bodies
are refundable). Q6c: ES names STILL false in situ (2nd consecutive) +
owner meta-finding: the dev's own conversational ES reads forced —
translationese authorship is the bug, not the word choices. Verdict +
routing: `drafts/_v15p5-fun-verify-20260815.md`.

**Ratified same day (owner):** working language = English. Language
pipeline = meaning brief → grounded candidates (attested notarial
formulas + bible found-language, constrained mutation; LLM composes
natively, never translates) → owner picks ON CAPTURES → Junior post-edits
PT-BR when active. Amazon Translate = docs/errors drafts + optional
back-translation sanity only. Council (Kimi) adversarial pass folded:
3-probe register calibration opens the lane (attested-notarial vs plain
vs game-generic, owner picks blind); back-translation QA demoted.

**v16 DEBATE CLOSED (owner ratified): the presentation/identity cycle.**
(a) resolution scaling — render-only, capture pipeline untouched;
(b) zone visual identity — data-driven identity block per zone;
(c) stamp delivery; (d) Varekka dread — non-refundable stakes knob +
dread presentation, no audio; (e) kill pop. Language lane runs after the
delivery dose. ONE comparability reset (Nest-rename law): full wall
re-run + critic recalibration. Oracle for the FIFTEENTH: does the Quay
look like a place / did Varekka scare you / do the stamps land.
**Multiplayer etapa 1 → v17 behind TWO TRIGGERS:** Junior playing at
etapa 0 (async — timezone-proof) + v16 shipped.

**Also this session (process — owner-commissioned adversarial review):**
drafts/ + wall runner now TRACKED in git (harness/run_wall.sh: pipefail +
PIPESTATUS, dynamic glob, 5 guard tests); CLAUDE.md → AGENTS.md
(one-cycle scope rule; history via `git log --follow -- AGENTS.md`);
process debt filed in PARKING_LOT. Review:
`drafts/_adversarial-review-20260815.md`. Full gate re-verified from the
new seat's own hands (world_loop, critic included: PASS).

**NEXT (v16 execution order):** dev closes forks with recommendations
recorded (dread-stakes shape, zone palette direction, scale default —
owner veto at debrief, v13 precedent) → spec
(`2026-08-15-v16-presentation-identity-design.md`) + dual review → TDD
increments: (a) scaling FIRST → (e) kill pop → (c) stamps → (b) zone
identity → (d) dread → language lane (3-probe + grounded candidates) →
pilots as needed → WALL full re-run (comparability reset) → perf →
FIFTEENTH blind ask (es) → v17 debate (multiplayer trigger check).
**Owner queue:** nudge Junior (etapa 0 is the together-play channel NOW);
be available for the 3-probe calibration + capture ratifications when the
language lane opens.

## 2026-08-15 (v15.5 BUILT + WALLED: vat in slow_door, ES pass ratified line-by-line, THREE check amendments, bible de-slop — FOURTEENTH verify next)

**MEASURED: suite 451/1961 green, perf p95 0.252ms, wall 16/16
(determinism 16/16 byte-identical in-sweep; vision 11/16 direct + 2
variance retries + 3 amended standalone PASSes — trail below), 49
checks (ADD-ONLY held: 5 owner-ratified rewordings + 1 scope clause,
zero deletions).**

**(a) VAT in slow_door [3,5]** — data-only. Verified before commit:
stations never block (tile_map passability is tile-glyph-only,
`check_passable!` guards placement) and interact is exact-tile
(`world.rb:461`), so no replay could touch [3,5] — wall determinism
16/16 confirmed it.

**(b) ES pass — owner ratified EVERY line via AskUserQuestion (es):**
court-stamp performative register (the v15 spec's own "court's stamps"
law → Spanish notarial "QUEDA + participio"): QUEDA PAGADO EL PASO /
QUEDA PAGADO EL PLAZO, UNO SE ALZA; zones La Primera/Segunda Vela, La
Rúa Larga, El Cerrojal, El Bajofondo, La Puerta Tarda; strip actions
atacar/esquivar/marcar/usar/cambiar (kit verbs kept). **TWO OWNER
OVERRIDES over dev objection, on record:** wipe.line "LA REENCARNACIÓN
ES INMINENTE" (theology mismatch flagged — no reincarnation in canon)
and challenger.called.line "ALGO HA DESPERTADO" (accuracy + slop test
flagged). Blocking language critique (4-agent workflow, axes separate):
ACCURACY PASS | REGISTER PASS | SLOP PASS at set level; the two
overrides scored worst (1-2), honest scores in
`drafts/_es-language-critique-2026-08-15.md`. Ship decision on them is
the owner's recorded call. Tests updated to ratified canon (strings +
controls_overlay). Harness stays pinned locale=en — gates untouched.

**(c) THREE check amendments ratified (precedent #14/#19/#42):**
1. Synthetic-probe scope clause (gate_checks.json "scope" field +
   2-line critic prepend) — moving_square had been failing 13
   world-conditioned checks since ≥v14, masked by the rc bug; now
   PASSES standalone.
2. Ensemble-trio self-gate clauses — kits_distinct (no clause),
   possessed_readable (INVERTED pre-v14 clause "mark pass=false"),
   possession_ring_moves (two contradictory clauses). Evidence:
   varekka_duel is a one-body focused scene by design; frame_0149
   SHOWS 2+ pack bodies yet the critic coin-flipped 2 PASS / 3 FAIL
   over identical pixels. Ensemble reads stay genuinely proven by the
   11 multi-body scripts.
3. whirlwind_reads one-shot clause — dense diag (frames 1278→1292,
   tmp/aoe_diag.json) proved the burst KILLS its taunted victim
   between 1280→1281; a survivor-reaction frame does not exist. Check
   now accepts kill-evidence across the reel. Feel gap (no death pop)
   parked in PARKING_LOT.md.

**(d) BIBLE de-slop enrichment (owner mid-session ask):** 21-agent
workflow (1.38M tokens) harvested lyrics-hub craft (dual-register
streams, causal withholding, found-language, sensory anchors,
plain-speech anchors), audited 15 named tics ("which is why" ×18+,
"not X but Y" ×16+, epigram-per-section, register flatness), 10/15
edits survived 3-lens adversarial verify (canon-lock / slop / variety;
kills all by "withholding over asserting") and are APPLIED to
`docs/lore/world-bible.md`. Proposal + kill list:
`drafts/_bible-enrichment-2026-08-15.md`.

**Wall trail (verdicts from teed logs, never runner rc):** in-sweep 11
direct vision PASS + 16/16 determinism + 16/16 manifests; critic_reel
and low_quay_run passed on ONE standalone retry each (judgment
variance — low_quay_run's 3rd lifetime reproduction); moving_square /
varekka_duel / aoe_specials passed standalone on amended checks (logs:
tmp/wall/*_v15p5_{a1,retry,amended}.log). Gotchas banked: zone-3
scripts' out_dir lives under `captures/pilot/` (standalone retries
need it); the replay script key is `"captures"`, NOT `capture_frames`.

**Junior clone traffic:** gh api shows 1 unique clone on 2026-08-13
(the day the collaborator was added) — ambiguous; ask Junior directly
at the v16 debate.

**NEXT: FOURTEENTH blind verify** — owner plays `bin/play es` FIRST,
no changelog; harvest `/tmp/game_two_session_<pid>.log` BEFORE
questions; skeleton `drafts/_v15p5-fun-verify-skeleton.md` (Q5 = the
vat, Q6 = new ES set in situ; keybind Q dropped); targets vs
thirteenth: quay frames >> 1137, chants > 0. Then v16 debate
(multiplayer spike etapa 1 LEAD).

## 2026-08-15 (v15 CYCLE COMPLETE: thirteenth verdict UNDER-EXERCISED, routing ratified, v15.5 scoped — healing + ES pass + amendment + fourteenth)

**MEASURED at goalcomp: junior-tibia HEAD `055aba0`, 298 commits, 0
ahead of origin (pushed), suite 451/1961 green (re-run at write time),
16 wall scripts, 49 checks, 16 teed wall logs.**

**THIRTEENTH BLIND VERIFY — ran 2026-08-15, verdict UNDER-EXERCISED
(not lost).** Owner session pid 16132: ~43 min, 34 fights, 8 wipes,
15 banks, BOTH seals paid — and **19 seconds total across two Low Quay
entries** (quay entries=2 frames=1137 deaths=2; varekka engaged=1
chants=0 — he crossed toward the owner, who died before one chant).
P7+P8 named the root the pilot's ~28 attempts had measured: **no
healing at or before the quay = tax-wall**; P1 "otro distrito más" and
P2 "casi ni lo vi" are downstream of it. P6: ES strings "todos suenan
falsos" — owner invoked /human-facing-output. P5 strip: functional,
legibility deferred by owner to resolution scaling. Debrief: ALL
disclosures approved (3 balance commits ratified incl. aggro 10→45;
moving_square amendment approved in principle). Verdict + telemetry +
routing verbatim: `drafts/_v15-fun-verify-20260815.md`.

**v15.5 DEBATE CLOSED (owner accepted dev recommendation): make v15
livable, then re-ask.** Scope in CLAUDE.md. Operating detail (vat tile
choice [3,5] off the door column, ES pass mechanics, amendment shapes,
fourteenth protocol): `drafts/_v15p5-plan.md` — READ FIRST next
session. Wall-integrity carry-forwards (PIPESTATUS pattern, critic
INFRA-flake retry protocol) are in that plan too.

**NEXT sequence:** (1) vat in slow_door (data-only, verify no replay
paths [3,5]) → wall 16 re-run; (2) ES pass via human-facing-output
skill, owner ratifies each name via AskUserQuestion; (3) moving_square
amendment text → owner ratification; (4) FOURTEENTH blind ask (same
oracle halves); (5) then v16 = multiplayer spike etapa 1 (Junior still
has NOT cloned — nudge).

## 2026-08-15 (v15 BUILT + WALLED: both zone-3 scripts exported and gate-green, wall 16/16 determinism, three pilot-driven balance commits — THIRTEENTH verify next)

**MEASURED: suite 451/1961 green, perf p95 0.335ms, 16 wall scripts
(+low_quay_run +varekka_duel), 49 checks (ADD-ONLY held), wall
determinism 16/16 byte-identical, vision 15/16 direct PASS (see
moving_square note).**

**Session commits, in order:** `c77b4f2` duel kill-box cleared (pilot
finding: 5 chants / 0 interrupts / 0 damage across 8 instrumented
attempts — guard density nullified the fairness ladder); `2f76956`
funnel guards un-piled (retune #1 had made the entries worse);
`a8b28b1` **Varekka hunts the whole quay (aggro 10→45)** — ~28
attempts proved the duel unreachable by travel (pack enters at
~130-150hp, every route costs more); the spec's own fiction (he
force-taunts, ONE STANDS) says HE comes to YOU — duel now happens at
the door, chant/seize/interrupt untouched; `87ee19b` start param grows
`zone` key (TDD x3) — focused duel scenes; `85d0b70` both scripts +
measured manifests.

**The two scripts:** `low_quay_run` (travel regression: both seals
in-run — gap #41 CLOSED — all banners, vat heal + regrow, corpse-run,
banked x2; manifest 7 keys measured) and `varekka_duel` (duel
regression via start zone: ONE STANDS, live chant ring [check 48],
landed seizure + FLESH IS CALLED + underline [check 49],
seizure_ended why=zone_left, chant_interrupted x2, THE TERM IS PAID
kill, fat-drop pickup; manifest 6 keys measured). Authored TAS-style —
fresh-world runs are deterministic puzzles (seeds 11/12 died on the
IDENTICAL tile+frame); scouting run then take run; traps banked in
memory + drafts/_v15-pilot-progress.md.

**Wall integrity findings (owner disclosure at the debrief):**
(1) run_wall.sh read `$?` after a pipe — gate_rc was tee's rc, ALWAYS
0; fixed with PIPESTATUS (tmp/, untracked). Verdicts were re-read from
the teed logs: 15/16 vision PASS direct (aoe_specials + low_quay_run
passed on standalone INFRA retry — critic API flake, 2 confirmed
reproductions). (2) **moving_square has been FAILING the vision critic
since at least the v14 wall (13 red checks on 2026-08-13, masked by
the same rc bug)** — structural, not a v15 regression: it is the
synthetic render smoke (a red square in a void, no map/HUD/strip by
design) and the world-conditioned checks cannot apply to it. Its
determinism is green (3/3 byte-identical) and its look is unchanged
across 12 walls. ROUTED: check-amendment proposal to the owner
(synthetic-scenario exemption or determinism-only wall slot) — checks
are ADD-ONLY and amendments are the owner's to ratify (precedent
#14/#19/#42).

**NEXT:** push junior-tibia → THIRTEENTH blind verify (SPANISH, owner
plays FIRST no changelog, telemetry harvest BEFORE questions; 8
questions + routing pre-registered in the spec; skeleton with exact ES
phrasing in drafts/_v15-fun-verify-skeleton.md; disclosures: TERM IS
PAID name swap, the three balance commits — owner may veto — and the
moving_square finding) → v16 debate (multiplayer spike etapa 1 LEAD;
check Junior clone first).

**MEASURED: junior-tibia HEAD `1037576`, 290 commits, ahead 7 of origin,
suite 448/1930 green, 14 scripts (+low_quay_run pending from the LIVE
quay6 pilot), 49 checks.**

**The economy lesson, honestly:** the original plan (pilot farms 190
for both seals) was INVIABLE — no v14 script ever farmed a coin (that
is exactly coverage gap #41), and ~2h of pilot grind produced banked 21
across 9 wipes. Fix was structural, not heroic: **`51fa9c0` adds the
`start` script param** ({"banked": N} on the script JSON, same class as
scenario/seed; Harness.apply_start via the audited pack.bank! path;
pilot START env; export carries it; TDD x5). Wall scripts are focused
regression scenes — the gate exercises seals/Varekka, not the grind.

**Pilot value proven:** `1037576` fixes a SHIP-STOPPER the pilot found
live — Creature#chant_left reader missing, so the renderer CRASHED the
first time Varekka's chant entered the camera. The thirteenth verify
would have died at its climax. TDD'd + suite green.

**quay6 session state (LIVE window — do not quit/reset):** seed 7,
START 600; both seals breached IN the history (40 @1093, 150 @5913);
challenger_engaged + chant_started + vessel_seized + seizure_ended
(:died) all in the log; Varekka alive at 140hp (damage accumulates —
attrition wins); 10 good captures incl. one_stands/flesh_called/
seized_underline. Remaining: interrupt beat + ring capture, kill →
THE TERM IS PAID + fat drop, 2 banks (camp + nest), export, manifest
from MEASURED log counts. Full state + play doctrine (marks insurance,
lobber-for-crossings, single-batch rule, deterministic inbox replay):
`drafts/_v15-pilot-progress.md` — READ FIRST.

**Then:** wall 15 (tmp/run_wall.sh) + rake manifest each + perf + suite
→ CHECKPOINT + push junior-tibia → THIRTEENTH blind verify (Spanish;
telemetry harvest FIRST; spec questions incl. TELL VALIDATED branch +
the TERM IS PAID disclosure) → v16 debate (multiplayer etapa 1 LEAD).

## 2026-08-14 (v15 BUILT: ratify+bible+forks+spec+dual review+TDD 6/6 — pilot quay1 IN FLIGHT, wall next)

**MEASURED: branch junior-tibia HEAD `b431b34`, 287 commits, ahead 5 of
origin, tree clean (drafts untracked by design), 14 scripts (+1 pending:
low_quay_run from the quay1 pilot), 49 checks (ADD-ONLY from 46), suite
442/1918 green (hook-run at every commit), perf p95 0.336ms, canary
PASS x2 (world_loop 10/10 + district_hunt 9/9 byte-identical vs true
v14 gate captures — W1 closed empirically).**

**Done this session, in order:** (1) #14/#19/#42 check amendments
RATIFIED (owner, opening act — c361ba3 precedent closed). (2) Bible
session named zone 3 = **The Low Quay** (the silov Silovun is named
for; dark since the interdict) and the Challenger = **Varekka**
(Kadravai wardsman-captain, earned third syllable; speaks the suvrim's
stolen vat-clauses — Dravessa precedent SS12.1; fairness ladder canon-
derived: pronunciation is stillness). (3) Owner closed 4 forks: quay
stationless + forced-approach seizure + bindings.json+local override +
names ratified. (4) Spec + DUAL REVIEW: Codex 2 passes (pass 1 died at
a session cut, 4 findings recovered from the rollout FILE; pass 2
REJECT: swap-while-seized defect CONFIRMED in today's code, THE NAME
IS STRUCK canon violation -> **THE TERM IS PAID**, canary-order defect,
bindings.local cross-machine poison) + 145-agent panel (16/45 confirmed
-> ALL folded; envelope declared 3.0M/45, actual 8.39M/145 — recorded,
calibration memory updated). Review ledger verbatim:
`drafts/_v15-spec-review.md`. Spec commit `5bf1762`. (5) TDD 6/6 green
commits: zone+canary `4455cd9` -> keybinds `acd6fee` -> chant+seizure
`ae5a24d` -> presentation+telemetry+manifests `b431b34`. Live catches:
exactly-once guard swallowed :expired (keyed on active? at zero frames
— fixed on raw seizer presence); hitstop ate test drives (clear_crew
burns it now).

**IN FLIGHT at goalcomp: pilot quay1** (`rake pilot NAME=quay1 SEED=7`,
window idle = frozen). Route + beats + manifest + doctrine pointers:
`drafts/_v15-pilot-plan.md` (read it FIRST after compact; if the window
died, relaunch fresh — nothing exported yet). The script must pay BOTH
seals in-run (fresh world per replay) — this also closes the #41
seal-breach coverage gap (zero wall scripts staged a breach since v12).

**NEXT:** finish pilot -> export low_quay_run + add manifest key ->
WALL full re-run 15 scripts (low_quay_run FIRST, then v14 order; teed
logs tmp/wall/<s>_v15_a1.log; rake manifest after every gate; re-pilot
budget 3-6) -> perf + full suite -> CHECKPOINT + PARKING_LOT (already
has the v15 parked section) -> fetch -> push junior-tibia -> THIRTEENTH
blind verify (SPANISH ask; oracle = did the Low Quay feel EARNED + did
Varekka SCARE you; harvest /tmp/game_two_session_<pid>.log BEFORE
questions; questions + routing pre-registered in the spec, incl. the
TELL VALIDATED branch and the acta-swap disclosure) -> v16 debate
(multiplayer spike etapa 1 = LEAD; check Junior clone status first).

**Owner queue:** ES locale pass (now also: UNO SE PLANTA / LA CARNE ES
LLAMADA / EL PLAZO ESTA PAGADO / El Muelle Bajo); Junior PT-BR pass
(UM SE PLANTA / O PRAZO ESTA PAGO / O Cais Baixo + the new JUNIOR.md
custom-keys section); nudge Junior to clone.

## 2026-08-14 (v14 WON the twelfth + v15 DEBATE CLOSED — cycle complete, v15 brainstorm next)

**MEASURED: branch junior-tibia HEAD `35992e7`, 281 commits, tree clean,
synced 0/0 with origin (pushed; Junior still zero pushes), 14 scripts,
46 checks, suite 395/1601 green (hook-run at both closing commits).**

**TWELFTH BLIND VERIFY — v14 WON, FOURTH consecutive win (v11 density,
v12 arc, v13 specials, v14 legibility).** Owner session pid 44448:
75305 frames (~21 min), 50 fights, 18 banks, 8 wipes. BOTH oracle halves
positive on first read:
- **B VALIDATED**: whirl casts=2, hits{1=1,2=1}, kills=2 + "Sí, premio" —
  v13's design finally judged; the casts=0→2 delta is PRESENTATION alone.
- **Telegraph VALIDATED**: telegraphs_shown=268 + "Sí, planeé" — the
  respawn ask CLOSES, zero iteration.
- **Strip VALIDATED**: "Ayudó" + owner free-text lane: dual keybinds
  (strip shows J/K/L/;/H/Tab, owner uses Space/Shift/E/Q/F) —
  "debemos especificar".
- Q5 "ritmo ok" → **lane e CLOSED (L0)**; Q6 + span_thirds{102<113<134}
  monotonic → **drift CLOSED**; Q7 "Nada injusto" (3rd clean) →
  guard-scope stays closed-validated; Q8 body reacted (4th consecutive).
Full verdict + telemetry + routing verbatim:
`drafts/_v14-fun-verify-20260814.md`.

**v15 DEBATE CLOSED (owner via AskUserQuestion): v15 = ZONE 3 + THE
CHALLENGER + CONFIGURABLE KEYBINDS** — three increments, biggest scope
to date. Challenger PROMOTED on the owner's EXPLICIT call (6 non-confirms
on record; fairness ladder mandatory). Zone 3 = the arc's next rung
(seal2 paid twice). Keybinds = binding map in data/ (JSON), strip reads
per-player config, multiplayer-ready. Multiplayer spike = v16 LEAD.
Scope contract rewritten (CLAUDE.md `35992e7`) incl. NEW **Human-facing
surfaces section** — the `human-facing-output` skill (owner-directed
this session) is wired: every v15 text surface (zone-3 banner, Challenger
tell text, keybind labels, locale strings) gets the 10-principle
checklist + language critique blocking at ship per Rules 2/6.

**NEXT SESSION (v15 execution, in order):** (1) owner-queue opening act:
ratify #19/#42 + check-14 rewording (deferred at the twelfth — the owner
answered about bindings instead). (2) Bible session names zone 3 + the
Challenger BEFORE the spec (fiction order form; First Vigil precedent).
(3) Brainstorm → design forks via AskUserQuestion (zone-3 composition,
Challenger tell/counter shape, binding-map format) → spec → dual review
(Codex FIRST then panel, Rule-7 envelope declared) → TDD → pilot(s) →
wall 14+N → perf → close → THIRTEENTH blind verify (Spanish; oracle =
zone 3 feels earned + the Challenger scared you).

**Owner queue:** ratify amendments (above); ES locale pass still open
(girar/gritar/lanzar, LA CARNE SE AGOTA, La Primera Vigilia, El
Corredor); Junior PT-BR pass later; nudge Junior to clone (docs/JUNIOR.md
live; zone 3 will give him a richer first play).

## 2026-08-14 (v14 WALLED 14/14 + perf + suite — TWELFTH blind verify next)

**MEASURED: branch junior-tibia HEAD `20ddcff` pre-close (this commit makes
280), 279 commits, ahead 9 of origin, 14 scripts, 46 checks, suite
395/1601 green (bundle exec, 0 failures), perf p95 0.341ms (v13: 0.252 —
the overlay+tell draw cost, 48× under the 16.6 budget).**

**WALL 14/14 PASS** — 10 scripts a1 + FOUR re-pilot replacements (budget
was 2-5): the W1 respawn-RNG-stream isolation moved the world under every
old script's recorded inputs, and the NEW MANIFEST LAW (Codex fold)
caught FOUR semantic desyncs — **the critic passed 3 of the 4** (only
nest_advance also tripped vision, later, on capture selection):
- vat_economy a1 FAIL (pre-known + WIDER: inscribed also died) → pilot
  vat6 (20.2K frames) → **PASS a2** w/ manifest COMPLETE; tribute_beat_
  reads exercised on a REAL tribute first time since v12.
- corpse_run a1 FAIL (corpse_looted=0, banked=0; corpse_run_reads
  self-gated IN ITS OWN SCRIPT while the critic passed) → pilot cr2 →
  **PASS a2** (wipe_recap over veil verified; corpse_run_reads still
  sampling-dependent — honest note in the wall log).
- ledger_loop a1 FAIL (corpse_loaded=0) → pilot ll2 (4.4K frames,
  fastest — bank EARLY while the pack lives) → **PASS a2**; splices
  exercised ledger_negative_reads ("hollow -7 → red -7 net") for real.
- nest_advance a1 FAIL (banked=0, corpse_looted=0 — the owner SAW the
  divergence live: "solo te veo dando vueltas en El Nido") → pilot na2
  (13K frames, 2 banks/2 trips) → a2 vision FAIL (4 mandatory-beat
  checks needed the FULL PACK in frame; all captures were solo-vessel —
  memory `gate-critic-mandatory-beat-checks` verbatim) → splice-legal
  early captures → **PASS a3**.

**Hard-won pilot doctrine BANKED in the wall log** (per-kit step timing
13/16/19 f/tile — four grab failures from one bug; ranged tap-face vs
melee attack+direction; dodge dashes along facing; volley delay-lead;
the corpse-container RATCHET — value re-containers at each death-carrying
with fresh 5400 term, only drops decay; two-press stacked recoveries;
speed 20 fast-forward). ~30 deaths of tuition across vat6/cr2/ll2/na2.

**This close commit:** 4 replaced harness/scripts/*.json + PARKING_LOT
(rename SHIPPED strikethroughs + "Parked by the v14 spec" section) +
this delta. Untracked by design: _v14-wall-log.md (gate table + doctrine),
_v14-fun-verify-20260814.md (questions + routing VERBATIM, ready).

**NEXT:** fetch origin → push junior-tibia (NEVER main) → **TWELFTH
BLIND verify** (owner plays FIRST no changelog; harvest /tmp/game_two_
session_<pid>.log BEFORE questions; AskUserQuestion in SPANISH; oracle =
did the whirlwind FIRE and land as payoff + did spawns stop feeling
sudden; arbiters whirl.casts+hits, first_special{striker},
telegraphs_shown, span_thirds; preamble: unexercised reads as
unexercised) → v15 debate (zone 3 stair LEAD, multiplayer spike etapa 1,
Challenger owner-only 6th, B placement re-read WITH controls) → THEN the
scope contract v15 rewrite rides the debate outcome.

**Owner queue:** unchanged (ratify #19/#42 + check-14 rewording at the
debrief; ES locale pass; Junior PT-BR pass; nudge Junior to clone).

## 2026-08-14 (v14 BUILT: spec+dual review+TDD 6/6+pilot+gate 1/14 — WALL next)

**MEASURED: branch junior-tibia HEAD `d23c090`, 278 commits, tree clean
except drafts (untracked by design), ahead 8 of origin (push rides the
close step), 14 replay scripts, 46 checks (ADD-ONLY from 44), suite
395/1601 green (hook-run at every commit + measured now).** v14 committed
DIRECTLY on junior-tibia (no side branch — deviation from the v13
side-branch pattern, recorded; close step = fetch + push, no merge).

**Done this session:** spec `554fd6e` (dual review BEFORE commit: Codex
REJECT → 7 folds ALL applied — W5 unpin bound `telegraph_defer_unpin_
frames: 240` NEW threat key, #19 amendment re-cut non-narrowing,
`never` sentinel, machine-checked wall manifests, vat_economy exposed as
ALREADY-desynced at v13 (tributes=0 in its teed gate logs — the v13 wall
log's "did not bite" note was WRONG); panel wf_80a86046 4 lenses → 0
findings, 421K/4 agents vs 2.2-3.1M/45 declared). TDD 1-6 green commits
`0179e55..19d082b` (rename batch + span_thirds/first_special + telegraph
sim w/ dedicated respawn RNG stream + tell render + controls overlay w/
sim-cosmetic kit_first_possessed + checks 46). Pilot tg1 (r1 recon + r2
export, seed 7) → `harness/scripts/respawn_telegraph.json` `d23c090`,
**gate PASS a1** (det 9/9; #45+#46 EXERCISED verbatim in verdict). Lane e
doc: drafts/_v14-regrow-cadence-investigation.md (L0-L3 levers, v15).

**Artifacts (drafts/, untracked):** _v14-spec-review.md (both review legs
verbatim), _v14-wall-log.md (SSoT: measured per-script event MANIFESTS —
new triage law; pilot doctrine incl. the 12-tile-block/13-14-visible-band
geometry + deferral-as-camera-control; respawn_telegraph provenance +
honest deviations: camera-edge delivery, no volley+tell beat, no wipe
beats in-script), _v14-regrow-cadence-investigation.md.

**NEXT (execution order):** WALL remaining 13 scripts sequential ONE
window (order + manifests in _v14-wall-log.md; verdicts from
tmp/wall/*_v14_a*.log teed files NEVER exit codes; vat_economy =
PRE-KNOWN re-pilot, its manifest needs tribute_paid+body_regrown;
nest_advance ~65min NOT frozen; splice law; budget 2-5 re-pilots) →
rake perf ALONE → full bundle exec rake → CHECKPOINT + CLAUDE.md scope
v15 rewrite + PARKING_LOT → fetch origin → push junior-tibia (NEVER
main) → TWELFTH blind verify (Spanish protocol, harvest
/tmp/game_two_session_<pid>.log BEFORE questions; skeleton to write:
drafts/_v14-fun-verify-20260814.md from spec questions+routing verbatim;
oracle = whirlwind FIRED + spawns stopped feeling sudden) → v15 debate
(zone 3 stair LEAD, multiplayer spike etapa 1, Challenger owner-only
6th, B placement re-read WITH controls).

**Owner queue:** ratify #19/#42 amendments + standing check-14 rewording
at the twelfth debrief; ES locale pass (overlay verbs girar/gritar/
lanzar + LA CARNE SE AGOTA + La Primera Vigilia/El Corredor); Junior
PT-BR pass later; nudge Junior to clone (docs/JUNIOR.md live).

## 2026-08-14 (v14 PLANNED: forks closed + plan APPROVED — execution starts at spec)

**MEASURED: branch junior-tibia HEAD `7eeec1b`, 269 commits, tree clean, synced
0/0 with origin (Junior: still zero pushes), 13 replay scripts, 44 checks,
suite 369/1486 green at HEAD (hook-run at 7eeec1b).** Planning session ran the
full brainstorm arc in plan mode: 3 Explore agents + 1 Plan agent (envelope
declared 450K, actual ~372K subagent tokens), owner closed ALL FOUR v14 forks
via AskUserQuestion (all on dev rec), plan APPROVED via ExitPlanMode.

**Forks closed (owner, 2026-08-14):** (1) overlay = persistent quiet strip +
one-time first-possession pulse; (2) strip text = vessel canon names
(ithet/goret/hevet) + key:verb lowercase pairs; (3) telegraph = growing ground
mark, ~2s lead, tile pinned at tell time, materialize tick UNCHANGED
(difficulty pinned by construction); (4) rename batch = FULL (The Nest→The
First Vigil, District One→The Longrow, wipe line→"THE FLESH IS SPENT" — the
v12-annex pre-registered batch).

**Key planning verdicts:** drift instrument = NOT defective (q6 bands are
SPATIAL, thirds are TEMPORAL; all-k3 = session shape) but session-shape
sensitive → lane ships `span_thirds` companion + missing tests, legacy field
kept. Human-respawn path is the sudden one (tile chosen at release,
world.rb:995-1015) → split-phase telegraph design. Rename blast radius = ~9
display strings; internal identifiers stay. Check plan: ADD-ONLY 44→46
(+controls_overlay_reads, +respawn_telegraph_reads) + #19/#42 wording
amendments (owner ratifies at twelfth). TOP WALL RISK: telegraph pin shifts
world evolution vs v13 replays → staged-beat scripts may desync → budget 2-5
re-pilots; wall becomes 14 scripts (new respawn_telegraph.json).

**Artifacts:** approved plan =
`C:\Users\gabri\.claude\plans\groovy-whistling-spring.md` (READ FIRST on
revival); blueprint details = `drafts/_v14-blueprint-notes.md` (check wording
drafts, locale tables, script beats, data keys, telemetry sketch). Nothing in
flight (all 4 agents harvested).

**NEXT (execution order):** spec at
docs/superpowers/specs/2026-08-14-v14-legibility-design.md → Codex leg FIRST +
fold → workflow panel (envelope: 4 finders × 110K + findings × 165K ≈
2.2-3.1M, cap 45) → spec commit → TDD increments 1-6 (rename / span_thirds /
telegraph sim / telegraph render+telemetry / overlay / harness) → pilot
respawn_telegraph → WALL 14 sequential (ONE window at a time; verdicts from
tmp/wall/*_v14_*.log teed files) → perf → full rake → CHECKPOINT + scope v15
rewrite + PARKING_LOT → fetch → merge --no-ff INTO junior-tibia + PUSH →
TWELFTH blind verify (Spanish protocol; harvest logs BEFORE questions) → v15
debate (leads: zone 3 stair, multiplayer spike etapa 1, Challenger 6th look
owner-only, B placement re-read WITH controls).

## 2026-08-14 (ELEVENTH VERIFY: v13 WINS — third consecutive headline; v14 DEBATE CLOSED = legibility/onboarding)

**Owner verdict (AskUserQuestion en español, verbatim in
drafts/_v13-fun-verify-20260814.md): Q1 "Oportunidad para cobrar" → v13
WINS** — third consecutive headline win, carried by the CHALLENGE alone
(23 casts / 71 retargets / carrying_deaths 21→2 vs tenth). **The
whirlwind NEVER FIRED (casts=0 both sessions) → UNEXERCISED, not judged**
(ledger precedent). Owner named the fix verbatim: on-screen controls.
Q7 free-text: respawn timer/delay ask. Telemetry (two clean-Esc
sessions, harvested BEFORE questions): session 2 = 19 fights, 11 banks
(mean 33 max 67), BOTH seals paid again, 68 Keyward kills, economy
churned (11 tributes / 3 inscriptions / 168 spent).

**Routing fired:** guard-scope steering CLOSED VALIDATED (Q7 "nada
injusto", no camping). Maintenance dose REVERTED per the pre-registered
gap arbiter (83s→47s + trips-still-often = backfired; `52314c9` pushed).
Drift curve FLAGGED SUSPECT (all 186 kills bucketed k3 vs breach at
95612 — verify the instrument at v14 before the structural decision).
Challenger 5th non-confirm. **v14 DEBATE CLOSED (owner, both picks on
dev recommendation): v14 = LEGIBILITY/ONBOARDING** — on-screen controls
+ respawn telegraph + The Nest rename riding ONE comparability reset
(full wall re-run); lanes = drift-instrument verification + regrow-
cadence investigation. Oracle: the TWELFTH ask = did the whirlwind FIRE
and land as payoff. Scope contract rewritten; PARKING_LOT updated.
**v14 brainstorm/spec = next session's first act** (forks: overlay
design, telegraph shape, the new Nest name from the bible/owner).

Junior status at debrief: zero pushes/PRs yet; junior-tibia carries
everything (`52314c9`), main untouched (solo backup line).

## 2026-08-14 (v13 BUILT + WALLED in one autonomous session — ELEVENTH blind verify NEXT)

**MEASURED: branch `v13-aoe` at `d6c3192` + this checkpoint, 266 commits,
suite 369/1486 green (hook-run every commit), perf p95 0.252ms (budget
16.6), checks 44 (ADD-ONLY from 42), 13 replay scripts, WALL 13/13 PASS
(zero re-pilots of old scripts; aoe_specials a2 after one splice-legal
capture retime).** Owner delegated the whole cycle mid-session
("continúa de manera autónoma"): forks closed on dev recommendation
(fork table in the spec §Design forks — owner may veto at debrief),
spec `0edf31d` reviewed by Codex (REJECT → 4 folds: refund anchor,
challenged-cause plumbing ×3, shifted leash-home redesign, challenge ×
engaged-cap watched risk) + 52-agent workflow (1 CONFIRMED → whirlwind
render identity + check-14 rewording; envelope declared 2.5M/40, actual
3.06M/52 — recorded). TDD 5/5 green commits. Review ledger:
`drafts/_v13-spec-review.md`; wall SSoT: `drafts/_v13-wall-log.md`.

**Owner directives absorbed mid-session (all live):** Spanish sessions;
`junior-tibia` = collaborative line (PUSHED — main/junior-tibia synced at
fff5e18, v13-aoe branch pushed at every green); i18n en/es/pt-br SHIPPED
(authored translations, harness pinned en, `bin/play es|pt-br`);
`docs/JUNIOR.md` onboarding; multiplayer = lockstep-over-Tailscale staged
path (GameLift REJECTED, Junior has no AWS) recorded as v14 lead in
PARKING_LOT + memory `multiplayer-shared-play-path`.

**NEXT: merge v13-aoe --no-ff INTO junior-tibia + push (NOT main — owner:
main is the solo backup line), then the ELEVENTH BLIND verify** (owner
plays `bin/play` — or `bin/play es` — FIRST, no changelog; harvest
/tmp/game_two_session_<pid>.log BEFORE questions; skeleton + routing:
`drafts/_v13-fun-verify-20260814.md`; headline = did density become YOUR
weapon; whirl.hits histogram arbitrates). Then the v14 debate (leads:
zone 3 stair, Nest rename, multiplayer staged path, Challenger 5th look).

## 2026-08-14 (GOALCOMP #4 — session wrap; v12 cycle CLOSED end-to-end; fresh chat starts v13)

**MEASURED: 257 commits, main HEAD `a5163d8`, tree clean, 69 ahead of
origin (NEVER push), 12 replay scripts, 42 checks, suite 335/1386 green
(hook-run at every commit today), perf p95 0.337ms.** Nothing in flight —
no pilots, no background gates, no agents. The whole v12 cycle (spec →
TDD → wall 10/10 → merge `4703d3d` → tenth verify WON → v13 debate
closed) completed in this session's arc.

**Read-first for the v13 session:** this file's two 2026-08-14 entries +
CLAUDE.md scope contract (v13 = AoE specials B+D + three routed lanes) +
`drafts/_tibia-aoe-research-20260813.md` (the dossier) +
`drafts/_v12-fun-verify-20260813.md` (verdict/routing/telemetry) +
`drafts/_v12-wall-log.md` (gate provenance + pilot doctrine, incl. vat5b
flight notes). **First act = v13 brainstorm** (superpowers:brainstorming),
design forks close via AskUserQuestion BEFORE the spec: kit placement
(which body gets B, which gets D — or one body both), pip costs, binding
(L/E exists; "any THIRD special or new binding" was a v12 OUT — v13
promotes exactly these two), clump-payoff formula shape, challenge
duration/radius, and how the three lanes land (maintenance pricing DATA;
drift structural DESIGN; guard-scope DESIGN).

## 2026-08-14 (v13 DEBATE CLOSED: AoE specials B+D; c361ba3 RATIFIED — v12 cycle COMPLETE)

**Debate closed via AskUserQuestion, all three dev recommendations
accepted:** (1) **v13 = Tibia AoE specials B+D** — clump-payoff special +
challenge-retarget special (dossier `drafts/_tibia-aoe-research-20260813.md`);
oracle = the ELEVENTH ask: did density become your weapon. (2) The three
tenth-routed items **ride v13 as lanes** (maintenance-economics DATA lane,
drift-structural DESIGN investigation, guard-scope DESIGN item). (3) The
c361ba3 check amendment is **RATIFIED** (self-gate wording stands, 42
checks). Scope contract rewritten in CLAUDE.md; PARKING_LOT updated
(Challenger 4th decline, A/C/E parked, zone-3 stair + Nest rename = v14
leads). **v13 brainstorm/spec is the NEXT session's first act** — design
forks (kit placement, pip costs, bindings) close before the spec.

## 2026-08-14 (TENTH VERIFY: v12 WINS — headline MOVED; v13 debate next)

**Owner verdict (AskUserQuestion, verbatim in
drafts/_v12-fun-verify-20260813.md): Q1 "Advancing toward something" →
v12 WINS** — second consecutive headline win. Breach = "earned payoff,
toll worth it"; Keyward = "arrived somewhere new"; body reacted (Q8).
Telemetry (two clean-Esc sessions harvested BEFORE questions): session 2
paid BOTH seals (breach fired=2, seal2_breached=1, first @109160),
240 Keyward kills, 17 camp visits, 29 inscriptions / 21 tributes /
banked_spent 634 / banked_end 280 — the economy CHURNED.

**Routed to the v13 debate:** (1) Q5 named lever — trips are
MAINTENANCE-FORCED (pure=0 of 19 banks, dead 1.3 + wounded 1.7 at bank
time): the lever is maintenance economics, not trip distance. (2) Q6
drift "Mixed" after dose iteration TWO → structural lever. (3) Q7
corpse-run camping at guard 10 → values lane exhausted, guard-scope
un-parks as a design item (fairness only — owner also answered "nothing
unfair"; difficulty stays pinned). (4) Q8 reacted → Challenger stays
unpromoted (4th non-confirm). Q4 "just a shorter walk" recorded, no lane.

## 2026-08-13 (v12 MERGED — wall 10/10, perf 0.337ms, suite 335/1386; TENTH blind verify NEXT)

**MEASURED: 254 commits, main HEAD `4703d3d` (merge --no-ff of v12-arc,
NOT pushed — 55+ ahead of origin by design), suite 335/1,386 green (hook +
standalone), perf p95 0.337ms (budget 16.6), checks 42, 12 replay scripts.**

**WALL COMPLETE — 10/10 gameplay gates PASS** (+ moving_square/critic_reel
det-only): world_loop, district_hunt, specials_chain, loot_loop,
taunt_anchor, corpse_run, threat_pull, **ledger_loop (a2 — g-frames retimed
into a confirmed 15f flight window + carried>0 HUD frames)**, **vat_economy
(vat5b re-pilot, 42/42 first try — inscribe/god-mark/judgment/tribute-regrow
on camera)**, **nest_advance (a3 — +kits-at-spawn frame 15 + carried frame
1000; a2's check patch had cleared 4 of 6)**. All sequential, ONE window at
a time. Verdicts: tmp/wall/*.log; provenance: drafts/_v12-wall-log.md
(includes vat5b flight notes — 5 deaths' worth of new pilot doctrine:
never goto/hold toward enemy mass, lane chokes, leash-return 1v1s,
deliberate-wipe-as-free-heal).

**NEXT ACT = TENTH BLIND FUN-VERIFY** (owner plays bin/play FIRST, no
changelog). Skeleton ready: drafts/_v12-fun-verify-20260813.md — protocol,
questions 1-8 + routing VERBATIM from the spec, telemetry harvest slots
(session logs land at /tmp/game_two_session_<pid>.log). Harvest BEFORE
questions. Then the v13 debate (leads: Tibia AoE dossier B+D, Challenger
3rd decline, Nest rename unblocked) → scope/PARKING_LOT/CHECKPOINT.

**Owner queue (unchanged + one addition):** RATIFY the c361ba3 check
amendment (surface at the tenth debrief — cost: per-script forcing gone);
council MCP deepseek-r1 us. prefix; council-via-mmh-gateway; optional
bin/install-hooks; Junior never pushes main (PRs from junior-tibia).

## 2026-08-13 (GOALCOMP #3 mid-v12 — wall 7/10 gameplay gates PASS; 3 owed; perf PASS)

**MEASURED: 251 commits, HEAD `c361ba3` + this checkpoint, suite 335/1,386
green (hook-run twice today), checks 42, 12 replay scripts installed, perf
p95 0.343ms (budget 16.6).** Wall SSoT = drafts/_v12-wall-log.md — READ IT
FIRST; it has the gate table, splice law, pilot doctrine, and the one
remaining re-pilot recipe.

**Gates PASS (7):** world_loop, district_hunt, specials_chain, loot_loop,
taunt_anchor, **corpse_run (42/42)**, **threat_pull (a2 same-captures)** —
plus moving_square/critic_reel det-only. **OWED (3):** ledger_loop a2
(a1 real-fail: same-offset g-frames read as HUD + carried numeral),
vat_economy re-pilot (v11 script desyncs under v12 density; vat4/vat5
attempts died; recipe in wall log), nest_advance a2 (~35 min double
replay; a1 = 36 PASS + 6 fail, 4 of them structural "not exercised").

**nest_advance ARC COMPLETE end-to-end in-sim (pilot nest1 r6):** banked
43 → toll 40 paid at the seal (`seal_breached`, `banked_spent sink=breach`)
→ The Second Vigil (`home_rehomed` LIVE, camp bank/vat work) → The Keyward
(denser field, D2 kill+drop) → camp back-door into deep D1 (11-body
garrison on camera + band-2 ember drop). seal2_price beat DROPPED (13
failed runs — not load-bearing for any check; recorded as tenth-ask
routing data: the Keyward stretch reads brutally hard solo, as priced).

**⚠ OWNER MUST RATIFY: check-wording amendment** (`c361ba3`): 4 generic
checks (possession_ring_moves, projectile_visible, telegraph_reads,
corpses_persist) gained self-gate clauses because two had INVERTED hatches
("mark pass=false if not exercised") that structurally fail any script
lacking a swap/shot — nest_advance (blocker-solo) hit it. Count stays 42,
nothing removed, the 5 v11 scripts still prove those beats for real; the
cost is losing the per-script forcing function. Detail + revert path in
the wall log. **⚠ GATE LAW ADDITION: one gate at a time** — I ran 3
concurrently (+1 stale), ~8 Gosu windows flooded the desktop, owner closed
them → all 3 runs INFRA-void ("capture counts differ" = interrupted
replay, not a verdict, no attempt consumed). Also: read verdicts from the
teed tmp/wall/*.log, never task exit codes (`tee|tail` masks rake's exit).

**Next sequence:** vat5b re-pilot → ledger_loop a2 + vat_economy +
nest_advance a2 gates SEQUENTIALLY (warn owner: windows will open) → perf
ALONE re-run → full rake → merge --no-ff NO push → CHECKPOINT → TENTH
blind verify (telemetry harvested first — nest1's arc/q6_margins lines
already captured in the wall log) → v13 debate.

## 2026-08-13 (GOALCOMP #2 mid-v12 — TDD 5/5 COMPLETE; wall mid-flight, pilot LIVE)

**All five v12 increments green-committed on `v12-arc`:** seal+camp
`f7ff543` · re-homing `36d2b6f` · Keyward+Slow Door `69287db` · telemetry+
checks `5f29598` · riders `706742c`. **MEASURED: 249 commits, HEAD
`706742c` + this checkpoint, suite 335 runs / 1,386 assertions green
(hook-run), checks 42 (add-only #41/#42), 11 replay scripts + nest_advance
in-pilot.** Cross-zone determinism pinned (breach chain, 4 zones, respawn
cycle). Rider values live: join 4 / cap 6 / corpse_guard 10.

**Wall (drafts/_v12-wall-log.md = the SSoT — READ IT before touching any
gate):** PASS world_loop, district_hunt, specials_chain, loot_loop,
taunt_anchor (+ moving_square/critic_reel det-only, the v11 law).
corpse_run RE-PILOTED + INSTALLED (pilot corpse4: ring bracket, spaced
shots, depth pair, pip/veil/judgment/loot/bank — 17 captures) — its gate
OWED. ledger_loop + vat_economy = REAL desyncs -> re-pilots OWED (recipes
in the wall log; reuse v11 inboxes + corpse4 fixes). threat_pull = 4
INFRA critic errors, ROOT CAUSE FIXED (vision_critic.py verdict call
8000->16_000 maxTokens, committed here) — attempt 1 OWED. **nest_advance
pilot nest1 LIVE (window open, sim frozen): seed 0, generation r5, banked
22/40, lobber-only; hunt doctrine + resume protocol + acts 2-5 capture
plan all in the wall log Phase 2 section.** After wall: perf ALONE ->
full rake -> merge --no-ff (NO push) -> CHECKPOINT -> TENTH blind verify
(spec questions/routing verbatim) -> v13 debate.

**Session side-events:** owner shared the repo with `juniormaciel10`
(collaborator, write) + branch `junior-tibia` — assessed + ledgered
(re-additions 2026-08-13 addendum 2); no branch protection possible on
the free plan; convention agreed = Junior never pushes main.

## 2026-08-13 (GOALCOMP mid-v12 — spec committed + increment 1 of 5 green; TDD continues)

**v12 pipeline state: brainstorm DONE -> 7 owner forks CLOSED (all on dev
recommendation: breach chain / banked toll / second seal priced high / D1
stays live / FULL Suvareth adoption / court's-collectors identity / new
surfaces born named) -> spec WRITTEN + adversarially REVIEWED + COMMITTED
`c373116` -> TDD increment 1/5 green `f7ff543`.** Review: 49-agent 4-lens
workflow `wf_c93e43ff-7cb` (code-fit/design-fun/harness-verifiability/
canon-compliance), 3.92M tokens, 12 deduped findings **0 confirmed** (all
majority-refuted with file:line evidence), 6 cap-dropped hand-dispositioned,
4 hardening folds (district_two pack_spawn; gradient_anchor validation;
beachhead named as second desync candidate; annex names tightened to
direct canon patterns — ulwir/goret/ithet, savrim precedent). Ledger:
`drafts/_v12-spec-review.md` (local, gitignored by design).

**MEASURED now: branch `v12-arc` at `f7ff543`, 244 commits, tree clean,
suite 315 runs / 1,288 assertions green (hook-run at commit), checks 40,
11 replay scripts.** Increment 1 shipped: gradient_anchor law (the
sorted-zone-keys band-flip trap — watched fail, then pinned), seal station
+ sealed transition in District One's deep east ([41,13]/[42,13], toll 40),
breach beat (strongest feel kick + "THE WAY IS PAID" gate-gold line +
slab-to-gold flip), camp.json = "The Second Vigil" (hub, full station kit).
New test file `test/game/seal_breach_test.rb` (13 runs). Trap for the next
increments: the breach kick's 8 hitstop frames pause transitions/clocks —
tests need HITSTOP_SLACK.

**Remaining increments 2-5 + wall plan + traps: `drafts/_v12-implementation-notes.md`**
(2 = hub re-homing; 3 = The Keyward + The Slow Door + seal2 @150; 4 = arc +
q6_margins telemetry + world_scene events + checks 40->42; 5 = rider values
join_radius 4 / pocket_cap 6 / corpse_guard 10). Then: wall (11 scripts
triage + pilot-authored nest_advance.json -> 10 gates) -> perf ALONE ->
full rake -> merge --no-ff (NO push) -> TENTH blind verify (questions +
routing pre-registered IN the spec; harvest arc/density/q6_cadence/
q6_margins BEFORE questions) -> v13 debate via AskUserQuestion.

## 2026-08-13 (GOALCOMP — v11 goal COMPLETE end to end; v12 staged for a fresh session)

Goal closed this session: wall 9/9 → perf 0.284ms → suite green → merge
`946c979` (NOT pushed) → BLIND ninth verify (verdict
`drafts/_v11-fun-verify-20260813.md`) → debate → v12 scope committed.
**MEASURED now: main at `e350289`, 241 commits, tree clean, 53 commits
ahead of origin (never push), suite 302 runs / 1,238 assertions green
(hook-run at `e350289`), checks 40, 11 replay scripts.** Nothing in
flight; both owner session logs harvested. New harvest file:
`drafts/_tibia-aoe-research-20260813.md` (the AoE dossier PARKING_LOT
points at — was context-only). New memory: `pilot-staging-traps`
(interact is a press; wait 25 after swap before special; force-kill loses
buffered telemetry). **Next session's first act: v12 ARC/PURPOSE
brainstorm** (superpowers:brainstorming) — shape candidates for A3 nest
advance + bible fiction pass; design forks close via owner
AskUserQuestion BEFORE the spec; then spec → TDD branch → wall → perf →
merge → TENTH blind verify (headline: did the session advance toward
something).

## 2026-08-13 (V12 SCOPED: ARC/PURPOSE) — debate closed via AskUserQuestion; scope contract rewritten; goal COMPLETE

**v12 debate held and closed** (owner picked the dev recommendation over
tuning-first and the Challenger): **v12 = ARC/PURPOSE — A3 nest advance +
bible fiction pass**, with the ninth-routed tuning as riders (density
drift dose, corpse_guard fairness — never a global softening, Q6
nest-trip lever behind measured margins). Challenger = THIRD decline,
trigger unconfirmed at ninth. New parked: the Tibia AoE-specials dossier
(clump-payoff + challenge-retarget as v13+ candidates); Q3
structural-economy branch closed unfired; drop-legibility lane closed
validated. Scope contract rewritten in CLAUDE.md; PARKING_LOT updated.
**Next session's first act: v12 brainstorm — design forks close via
owner AskUserQuestion BEFORE the spec.** The tenth ask's headline: did
the session feel like it advanced toward something.

## 2026-08-13 (NINTH VERIFY: v11 WINS with tuning residue) — first spontaneous "love the core loop"; entrainment MOVED after three flats; scope debate next

**BLIND ninth fun-verify DONE** (protocol held: play-first, no changelog,
two sessions on unique logs, telemetry harvested before questions;
verdict + telemetry + routing verbatim in
`drafts/_v11-fun-verify-20260813.md`). **Unprompted, before any
question: "I am starting to love the core loop of the gameplay."** And
during write-up: **"it is actually good that the game is difficult, I
like the current level of it"** — difficulty pinned RIGHT; the Q7 item
is a fairness fix, never a global softening.

Answers: Q1 stale "somewhere between" (better, drifts eventually) · Q2
groups KEPT COMING · Q3 depth pull BIT · Q4 deep drops READ richer · Q5
money EARNED (guard restored) · Q6 nest trips STILL too often (third
regression — lever is elsewhere) · Q7 corpse run CAMPED once · **Q8 body
REACTED — first entrainment movement in four reads; the Challenger's
trigger did NOT confirm a fourth time.** Telemetry: re-massing fired
dominantly (arrivals pocket 113 + seed 56 + home 0 across two sessions;
singles_pct 55→29; pockets.max 14; session 2 ran 22 fights / 9 banks
mean 19 max 38 / b2=79 deep kills / 5 inscriptions / 7 tributes).

**Routing applied verbatim:** Q1-residue → density VALUES iteration
(data only) · Q3 structural-economy branch CLOSES unfired · Q4 rider
VALIDATED (legibility lane closes) · Q6 → economy-lever candidate AT the
debate · Q7 → corpse_guard/scatter values iteration (guard today binds
respawn anchors only — live wanderers unguarded; no watched-spawn, so
NOT a defer bug) · Q8 → Challenger dossier NOT strengthened.

Next: scope debate via AskUserQuestion (arc/purpose v12 = A3 + bible,
owner wishlist, field now dense enough to carry purpose — vs Challenger
(weakened trigger) vs tuning-first) → v12 scope rewrite + PARKING_LOT +
CHECKPOINT committed.

## 2026-08-13 (V11 MERGED) — wall 9/9 + perf + suite green; merged --no-ff to main (NOT pushed); ninth blind verify is next

**v11 wall COMPLETE 9/9** (phase 1: 6/6, one taunt_anchor critic-INFRA
retry; phase 2 re-pilots: corpse_run a1 / threat_pull a2 / vat_economy a1
— threat_pull a1 was critic INFRA, empty model output, det 20/20 both).
Determinism passed every attempt for every script. **The new
`deep_drop_band_reads` check is EXERCISED-PASS** — critic verbatim: "The
glowing ember-gold square in 4392 reads visibly richer than the small
magenta drops" (two staged band-2 kills, q6 line b2=2). Re-pilot evidence
+ techniques: `drafts/_v11-wall-log.md` phase 2 (window-split negative
net; swap-stagger eats special presses — `wait 25` before casting; the
re-massed deep field mobbed two walk-ins — the mass IS the hazard now).

**MEASURED at this checkpoint: main at merge `946c979` (--no-ff, NOT
pushed), branch commit `2fde4ef`; suite 302 runs / 1,238 assertions, 0
failures (hook-run at commit); perf p95 0.284 ms vs 16.6 budget (prior
0.224 — density bookkeeping cost negligible); checks 40.** Density
telemetry across the three new streams: pocket arrivals dominant
(13/6/36), seed path live (vat 3), home fallback never used; singles_pct
61/76/41.

Next: **BLIND ninth fun-verify** (owner plays `bin/play` FIRST, no
changelog; unique log `/tmp/game_two_session_$$.log`; harvest density +
q6_cadence BEFORE questions; questions 1-8 + pre-registered routing
VERBATIM from the spec) → verdict `drafts/_v11-fun-verify-<date>.md` →
next scope debate (Challenger, trigger 3-4x, vs arc/purpose v12 vs
whatever the verify routes).

## 2026-08-13 (RESUME STAGED) — resume plan approved; no execution yet; wall still 6/9

Resume session opened on the goal below; **nothing executed** — this delta
only records the staging. Plan-mode pass re-verified prerequisites on disk:
all 9 `/tmp/q6_revert_wall_<s>.log` (beat-inventory source for the three
re-pilots — volatile, re-verify after any reboot), phase-1 `/tmp/v11_wall_*`
logs + summary, `tmp/v11_wall_asis.sh`, pilot protocol + d1b techniques.
**Approved resume plan: `C:\Users\gabri\.claude\plans\greedy-waddling-cherny.md`**
(operational detail for steps 3a→7; the committed spec stays SSoT for
mechanism/verify/routing). MEASURED now: `v11-density` at `36e24ff`,
234 commits, tree clean. Next act = step 3a re-pilots (vat_economy 7,
corpse_run 7, threat_pull 42 — threat_pull must stage the band-2 drop).

## 2026-08-13 (V11 BUILT + WALL 6/9) — implementation green on `v11-density`; phase-1 wall 6/6; three re-pilots remain

**v11 IMPLEMENTED (plan steps 1-2 DONE), all TDD, hooks enforced:** spec
committed `f11a643` (adversarially reviewed pre-commit, 9 findings folded
— ledger `drafts/_v11-spec-review.md`); release-time anchored respawns
`7470c2b` (records carry {kit_name, fallback_tile, at_frame}; tile chosen
at RELEASE: pocket join double-min / seed farthest-from-pack / home;
defer laws re-pinned on the CHOSEN tile + NEW corpse guard;
`:human_respawned{actor,tile,anchor}`; add_human returns the creature);
drop-band rider + density telemetry + checks 39→40 `42c22e6` (band
stamped on drop records; renderer 10/14 magenta / 16 rose / 18
ember+glow; density line with pinned zero-arrivals form; check #20
template broadened, `deep_drop_band_reads` added); harness logs the new
event `55751dd`. **MEASURED at this goalcomp: branch `v11-density` at
`55751dd`, 233 commits, tree clean, suite 302 runs / 1,238 assertions
green (run now), checks 40.**

**Wall (step 3) in progress — triage split it 6 as-is / 3 re-pilot
(`drafts/_v11-wall-log.md` carries the full map + evidence):**
- **PHASE 1 COMPLETE 6/6** (loot_loop, world_loop, specials_chain,
  taunt_anchor, district_hunt, ledger_loop — official double replay +
  md5 + critic on 40 checks). Only retry: taunt_anchor A1, explicitly
  labeled critic INFRA (malformed verdict JSON), det 10/10; A2 clean.
- **Mechanism proven in-stream**: density telemetry fired in all 9
  triage replays — vat_economy `pockets{mean=6.0 max=5} arrivals{
  pocket=13 seed=0 home=0}`; district_hunt seed path live (seed=4);
  singles_pct falls with session length (86→62→53).
- **PHASE 2 PENDING: re-pilot vat_economy / corpse_run / threat_pull**
  (their story beats died with the respawn law — tribute/loot/pickup
  chains whiff). Beat inventories per script are in the wall log; the
  threat_pull re-pilot MUST stage a deep kill so a band-2 ember drop is
  on camera (no current stream has b2>0 — the new check must be SEEN
  passing, not not-exercised).

Next sequence: 3 re-pilots (`rake pilot`, printf-append inbox, export,
re-stage ALL mandatory beats) → gate each (2-attempt INFRA retry) →
`rake perf` ALONE (p95 < 16.6 ms) → full rake → merge `--no-ff` to main
(NO push) → CHECKPOINT → BLIND ninth fun-verify (unique log
`/tmp/game_two_session_$$.log`, harvest density + q6_cadence BEFORE
questions; questions + routing live IN the spec) → next scope debate
(Challenger trigger triple-confirmed vs arc/purpose v12 vs verify
routing).

## 2026-08-13 (STEP 0 DONE) — revert wall RE-RUN COMPLETE 9/9+9/9; v11 spec written + adversarially reviewed (commit next)

**Revert wall re-proof (v11 step 0): WALL COMPLETE 9/9 determinism + 9/9
critic** on main `2de5be2` (the reverted 2.0-gradient build), chain
00:51:52–02:10:34. Eight gates passed attempt 1; taunt_anchor passed
attempt 2 after an attempt-1 critic-judgment flake (`projectile_visible`,
det 10/10 byte-identical, vision 38/39; same shot beat passed in prior
walls + last 11 verdicts of that check were passes — evidence unchanged,
NOT verdict-shopped). q6_cadence fired in-wall: banks{n=4 mean=13 max=24}
kills_by_band{b0=12 b1=18 b2=6}. Map appended to `drafts/_q6-wall-log.md`
(dead chain-1 recorded as INFRA). **The reverted build is Rule-2 valid;
v11 code may begin.**

**v11 spec WRITTEN + REVIEWED (step 1, committing this session):**
`docs/superpowers/specs/2026-08-13-v11-density-remassing-design.md` —
carries the three closed forks verbatim, release-time anchoring mechanism,
threat.json `density` block, corpse-guard fairness rule (refined to
always-on while a live load exists — recorded dev call), pinned density
telemetry format incl. zero-arrivals case, band rider with 10<14<16<18
size ladder, ninth-verify questions + routing IN the spec. Adversarial
3-lens review `wf_2e56306e-27f` (45 agents, 2.50M tokens): 14 findings,
**9 confirmed → all folded in** (add_human return-value trap, double-min
pocket scoring, empty-pack seed guard, RNG tick-phase ordering pinned,
band-1 16px, check #20 template amendment, zero-sample telemetry, defer
test isolation), 5 refuted — ledger `drafts/_v11-spec-review.md`.

Next: spec commit → TDD on branch `v11-density` (plan step 2) → wall with
re-pilots (desyncs expected; checks 39→40) → perf → merge --no-ff (NO
push) → BLIND ninth fun-verify → next scope debate.

## 2026-08-13 (PLAN APPROVED) — v11 forks CLOSED + execution plan approved; revert wall confirmed DEAD (INFRA) — re-run is step 0

**v11 design forks CLOSED by owner via AskUserQuestion (before the spec, as
the debate ordered): (1) core shape = RE-MASS TOWARD CLUSTERS — respawn
tile chosen at RELEASE time; joins the nearest surviving pocket below a
data cap; all capped/field empty → seed a NEW pocket at the kit's spawn
tile farthest from the pack; home fallback. (2) depth bias = NEUTRAL (v11
tests one hypothesis: a dense field fixes stale; bias stays a later data
knob). (3) Q6 legibility rider = band tint + size/glow by band, NO pickup
fanfare.** Full mechanism, data schema (threat.json `density` block:
join_radius 3 / pocket_cap 5 / scatter_radius 2 / corpse_guard 6),
`:human_respawned` event, density telemetry oracle, TDD order, wall plan
(checks 39→40 with a band-2-drop check), ninth-verify pre-registration and
next-debate brief are in the **APPROVED PLAN:
`C:\Users\gabri\.claude\plans\agile-greeting-bengio.md`** — the execution
SSoT until step 1 commits the spec into the repo
(`docs/superpowers/specs/2026-08-13-v11-density-remassing-design.md`).

**Revert wall: the in-flight chain is DEAD, classified INFRA** (summary log
holds one START line 19:39:22; the vat_economy per-script log cuts
mid-replay ~frame 15.5K; no ruby/rake process alive). Step 0 = re-run the
full 9-gate chain on the reverted build BEFORE any v11 code; 9/9 + 9/9
required; append the map to `drafts/_q6-wall-log.md` noting the dead chain.

**MEASURED at this goalcomp: main 227 commits at `d6615f5`, tree clean,
suite 285 runs / 1,178 assertions, 0 failures (run now, 12.8 s), checks 39.**

Next sequence = plan steps 0–7: wall re-run → spec commit → TDD on branch
`v11-density` → full wall with re-pilots (replays WILL desync — expected)
→ perf alone → merge --no-ff (NO push) → BLIND ninth fun-verify (unique
session log per launch) → next scope debate.

## 2026-08-12 (DEBATE CLOSED) — v11 = DENSITY/RE-MASSING promoted; 3.5× REVERTED to 2.0; Challenger declined 2nd time (trigger triple-confirmed)

**Owner forked via AskUserQuestion (brief `drafts/_scope-debate-v11.md`):
v11 = hunting-ground density/re-massing** (his own code-confirmed
diagnosis: 1:1 home-tile respawns + 12-tile block → clumping decays →
"boring and stale after a few rounds"). Q6 drop-legibility rides as
polish. **Brainstorm/spec is the NEXT session's first act** — design
forks close before the spec; the increment MAY touch the threat layer
(it owns respawn; the v10.1 freeze is lifted by promotion). **3.5×
band-2 reverted to 2.0 same session** (pins + shape-law floor updated;
strictly-increasing law kept) — v10.1 stands as a recorded negative
result. Challenger dossier stands for the next debate; arc/purpose
wishlist (progression/leveling/equipment/zones/lore/cities, owner
verbatim) = likely v12. Scope contract rewritten to v11; PARKING_LOT
updated (tank-first stale entry fixed — it SHIPPED with A2; v11
outcomes section added; video-critic/gamesmith harness idea parked with
dossier, owner ask). **Rule-2 note: the revert build's wall re-proof
was IN FLIGHT when this was written** (9-gate chain on `6283264`,
digits-only deltas, twice-proven class — but the gate is blocking, so it
runs): harvest `/tmp/q6_revert_wall_summary.log` (per-script
`/tmp/q6_revert_wall_<script>.log`) BEFORE any v11 code; if the chain
died, re-run it (INFRA → retry gate; real FAIL → fix forward per
`drafts/_d1b-wall-log.md`); append the map to `drafts/_q6-wall-log.md`.
MEASURED at goalcomp: main 226 commits at `6283264`, tree clean, suite
285 runs / 1,178 assertions green, checks 39.

## 2026-08-12 (EIGHTH VERIFY LANDED) — retune NEGATIVE: Q6 still collapsed, BOTH guards regressed; density-decay diagnosis owner-confirmed; scope debate in flight

**EIGHTH fun-verify VERDICT (blind held — owner played with no changelog;
full record `drafts/_q6-retune-fun-verify-20260812.md`): the v10.1 retune
did NOT move its oracle.** Q6 "still always-bank"; depth premium felt
"uniform" (3.5× earned but not attributed); Q7 "still arbitrary"
(REGRESSED — read-time exhausted, cue redesign opens as presentation item
per routing); Q1 guard "money got easy" (D1's written inflation risk
FIRED); Q5 guard "back to the nest too often" (regressed from seventh's
win); never wiped (judgment unexercised); entrainment flat THIRD
consecutive (Challenger trigger third confirmation). Free-form: "feels
good" moment-to-moment + wishlist = purpose/arc (progress, leveling,
equipment, zones, lore, cities). ⚠ Session telemetry LOST (dev error:
double-launch clobbered the log — unique log names per launch from now
on); felt answers were the oracle; q6_cadence integration stands on replay
evidence. Routing applied verbatim; the collapsed-Q6 telemetry fork was
unresolvable → BOTH branches (legibility + structural) carry to the
debate.

**Owner post-verify evidence, code-grounded same session:** "first pull has
a good amount of enemies, then respawns are a smaller part, too easy to
clean up; boring and stale after a few rounds; core system and combat feel
good." Verified mechanism: 1:1 respawns +300f at HOME spawn tiles +
respawn_block_tiles 12 → opening masses all 15 once, steady state =
scattered singles; count conserved, CLUMPING decays. Upstream of Q5/Q6/Q1/
entrainment. Density/re-massing = new debate candidate.

**NEXT: scope debate (brief `drafts/_scope-debate-v11.md`, updated with all
of the above), owner forks via AskUserQuestion; then scope v11 rewrite +
PARKING_LOT updates + CHECKPOINT + commit. Promoted increment's
brainstorm/spec = NEXT session.**

## 2026-08-12 (MERGED) — v10.1 Q6 retune SHIPPED to main; eighth fun-verify is next (BLIND — no changelog to the owner before they play)

**MEASURED: main at merge commit `ba4e0ad` (--no-ff, NOT pushed), 223
commits, tree clean except gitignored drafts. Suite 285 runs / 1,179
assertions, 0 failures (run post-merge). Perf smoke ALONE: p95 0.224 ms /
max 3.207 ms over 6,990 ticks (budget 16.6 ms). Checks 39, ADD-ONLY law
intact (gate_checks.json untouched).**

**v10.1 = 5 commits on `q6-retune`, all hook-verified green:** q6_cadence
telemetry oracle `88e3adb` (subscriber-side, 3 TDD tests + exact-string
update; line fires end-to-end in replay: banks{n=4 mean=15 max=32}
kills_by_band{b0=12 b1=18 b2=6}); band-2 drop multiplier 2.0→3.5 `48b140f`
(ONE sim number; 3 pins updated — world_test:871 passed by collision, a
rolled 4 sat in the old [2,4] list — + gradient shape-law test); cue 45→75
`b4f806d`; critic hardening `de29069` (EventStreamError → retry tuple —
wall round 1 died to a mid-stream Bedrock 500); threat_pull re-aim
`0138119` (captures +604/+607).

**Wall COMPLETE 9/9 determinism + 9/9 critic.** Round provenance:
vat_economy, ledger_loop, loot_loop, district_hunt, world_loop, corpse_run
round 2 (round 1 = vat INFRA death, mid-stream 500); threat_pull,
specials_chain, taunt_anchor round 3 (threat_pull round 2 was the wall's
one REAL check-FAIL: projectile_visible — capture 598 catches the 594 shot
1 tile into a 19-frame flight, 2 pre-retune flakes on record, and the
75-frame cue added a rust block to that exact frame; fix = ADD mid-flight
captures 604/607, no evidence frame moved. Round-3 pass cited 0598 itself
— the additions stand as redundancy). Full map: `drafts/_q6-wall-log.md`.
Zero re-pilots; d1b_fired line unchanged; unit prices unchanged.

**NEXT SEQUENCE (plan Tasks 7-8, plan is SSoT:
`docs/superpowers/plans/2026-08-12-q6-retune-eighth-verify.md`):**
(1) EIGHTH fun-verify — BLIND handoff (no changelog; the depth premium
must be FELT). Owner plays `bin/play` FIRST; harvest ALL telemetry incl.
q6_cadence from the session log BEFORE questions; questions + routing
table in the plan §Task 7, apply verbatim; preamble: no wipe → judgment
reads unexercised, not negative. Verdict →
`drafts/_q6-retune-fun-verify-<date>.md` + CHECKPOINT delta + commit.
(2) Scope debate: fold verify results into `drafts/_scope-debate-v11.md`
(static sections pre-drafted: Challenger dossier, judgment-rarity tension,
rivals with blockers), owner forks via AskUserQuestion, then scope v11 +
PARKING_LOT updates (tank-first entry STALE — shipped with A2; new
video-critic/gamesmith harness entry added this session, owner ask) +
CHECKPOINT + commit. Owner queue unchanged.

## 2026-08-12 (PLAN APPROVED) — v10.1 Q6 retune plan owner-approved; execution is the next session

**MEASURED: main at 216 commits, HEAD `1da0249` + the committed plan, tree
otherwise clean. Nothing executed yet — plan only.**

**The plan (owner-approved via plan mode, adversarially reviewed):
`docs/superpowers/plans/2026-08-12-q6-retune-eighth-verify.md`. READ IT
FIRST next session — it is self-contained (verified facts, design
decisions D1-D5 with rejected alternatives, file map, TDD task steps with
real code, pre-registered eighth-verify questions + routing table, scope
debate brief skeleton).** One-line summary: restore the Q6 dilemma via
district.json band-2 drop multiplier 2.0→3.5 (ONE sim number; shallow
untouched → staged replay spends stay affordable by construction) + Q7 cue
read-time 45→75 (zero behavior change → zero wall drift) + a q6_cadence
telemetry oracle (subscriber-side only: bank sizes + kills-by-band) →
full 9-script wall (zero re-aims expected) → merge --no-ff → BLIND eighth
fun-verify (no changelog in the handoff — the premium must be felt) →
Challenger scope debate (trigger double-confirmed; declined once at v10;
fairness ladder mandatory) → scope v11 + PARKING_LOT updates (tank-first
entry is STALE — it shipped with A2: combat.json initial_possessed=blocker).

**Key exploration facts banked in the plan** (3 Explore agents + 1 Plan
agent, all landed): gradient lives at district.json:48; 3 tests pin the
old values (world_test 1205/871, threat_respawn 116) and update in the
same commit; no test pins cue 45; :banked already carries amount;
gradient_depth_reads checks density not amounts; "deeper pays more" is a
declared corpus gap — license = Tibia hunt-spot choice + Gudii f38 + the
A2 own-diagnosed-problem precedent.

## 2026-08-12 (MERGED) — D1b vat economy SHIPPED to main; seventh fun-verify handed to the owner

**MEASURED: main at merge commit `402ba1c` (--no-ff, NOT pushed — pushing
is the owner's action), 214 commits, tree clean. Suite 281 runs/1,164
assertions, 0 failures (run post-merge). Perf smoke ALONE: p95 0.225 ms /
max 3.223 ms over 6,990 ticks (budget 16.6 ms). Checks 39, ADD-ONLY law
intact.**

**Wall COMPLETE on the post-fix build — official 9/9 determinism + 9/9
vision critic.** Round provenance: world_loop, district_hunt,
specials_chain, taunt_anchor, ledger_loop, threat_pull round 1;
loot_loop round 2 (critic cited re-aimed frame 0716); corpse_run +
vat_economy round 3 (corpse det 14/14, vat det 20/20; vat critic clean
through the hardened 6-attempt path; retarget_cue_reads self-gated
pass-with-not-exercised — the valid form). Determinism passed EVERY round
for every script. Full round log: `drafts/_d1b-wall-log.md`.

**v10 = 14/14 tasks + impl review folded** (`drafts/_d1b-impl-review.md`:
Workflow 1 finding refuted; Codex cross-vendor 3 confirmed→fixed `5a9229c`,
1 refuted — never re-raise any of the 12 spec + 4 impl findings).

**SEVENTH fun-verify VERDICT (same day, post-merge; full record
`drafts/_d1b-fun-verify-20260812.md`): D1b VALID — Q1 (meaning) MOVED on
the seventh ask, first positive ever.** Owner played (play-first law held;
telemetry harvested from the session log: 1 inscription + 3 tributes,
2 regrown, banked_end=23, wipes=0 → judgment/floor unexercised per
preamble). Q2 pact "a bet"; Q5 hunts run longer (owner's repetitive
complaint RESOLVED); Q8 prices right; Q7 "better, not fixed";
entrainment still flat. **Q6 REGRESSED: dilemma collapsed into
always-bank.** Pre-registered routing applied verbatim: (1) Q1 moved →
D1b WINS, next increment = SCOPE DEBATE (Challenger = standing queued
candidate, promotion the owner's explicit call); (2) Q6 → economy retune
with the dilemma as oracle, data-only, A2 threat untouched; (3) Q7 →
threshold iteration (data), cue redesign stays parked. Retune insight
recorded in the verdict file: collapse is cadence not unit-price (Q8
clean) — carried must be worth holding in the field again. Owner queue
unchanged: council MCP deepseek-r1 `us.` prefix; council-via-mmh-gateway +
when-to-council update (own session); optional tracked bin/install-hooks.

## 2026-08-12 (endgame goalcomp) — D1b: 14/14 tasks executed, impl review FOLDED (3 Codex fixes), wall re-proof round 3 in flight

**MEASURED: branch `d1b-vat` 212 commits at `7455257` (main 194 untouched),
suite 281 runs/1,164 assertions green (hook-verified per commit), checks 39
(ADD-ONLY law intact — critic hardening touched vision_critic.py, never
gate_checks.json). Tree clean.**

**Impl review (Task 14) DONE — fold-or-refute complete, ledger
`drafts/_d1b-impl-review.md`:** Workflow wf_2241b722-775 (3 finders +
1 refuter, 380,375 of ~1.0M declared subagent tokens): 1 finding, REFUTED.
Codex cross-vendor (GPT-5.6 Sol): 4 blockers -> 3 CONFIRMED by direct code
re-verification, fixed TDD in `5a9229c` (floor vessel no longer emits
:body_dissolved; unkeyed retargets clear stale cues via
Creature#clear_retarget_cue!; station cue carries at: its transaction
tile); 1 REFUTED (vat atomicity unreachable). Same-family finders missed
all 3 — memory `cross-vendor-catches-semantic-honesty` written; keep the
Codex leg mandatory on merge gates.

**Wall re-proof (F2/F4 are pixel-visible, so the pre-fix official passes
were invalidated; pre-fix build DID reach 9/9+9/9 first — sweep b7r5qae5o
8/9 + vat rake-gate exit-0, det 20/20, vision 39/39):** Round 1 post-fix
sweep 7/9 PASS; loot_loop + corpse_run failed projectile_visible only
(critic variance on marginal specks; det green), vat truncation only
(det 20/20). Re-aims (`7455257`): loot +471/+716, corpse +423/+499.
Round 2: loot_loop official EXIT=0 (critic cited frame 0716). corpse hit a
SELF-CONTRADICTORY verdict (pass=false + not-exercised why on self-gating
specials_distinct); vat truncated again. Critic hardened in `7455257`
(attempts 6, contradiction voids verdict); standalone vat probe
PROBE_EXIT=0 through the new path. **ROUND 3 IN FLIGHT at goalcomp:
corpse_run + vat_economy official gates (task bw6p8vhu0 ->
/tmp/wall3_*.log; summary /tmp/wall_sweep_summary.log appends "WALL3 <s>
EXIT=" + "ROUND3 DONE"). Determinism has passed EVERY round for every
script.** Full round log: `drafts/_d1b-wall-log.md`.

**NEXT SEQUENCE:** harvest round 3 (EXIT=0 both -> wall complete
7 round-1 + loot round-2 + these two = 9/9+9/9; truncation/contradiction
repeats -> retry the gate, NEVER re-pilot; a real check-FAIL -> read the
verdict, fix forward) -> `rake perf` ALONE -> full `rake` -> merge
`--no-ff` d1b-vat into main, NO push -> CHECKPOINT top entry with final
numbers -> hand the owner the SEVENTH fun-verify verbatim from spec
§Fun-verify (play-first law; d1b_fired telemetry banked first; Q1 meaning
headline; routing pre-registered).

## 2026-08-12 (mid-execution goalcomp) — D1b EXECUTION: tasks 1-12 DONE, wall 8/9 official + vat critic retry in flight

**MEASURED at goalcomp: branch `d1b-vat` 14 commits at `283fbbc` (main 194,
untouched), suite 280 runs/1,159 assertions green (hook-verified per
commit), checks 34→39 ADD-ONLY.** Working tree carries the 5 re-piloted
wall scripts UNCOMMITTED (Task 13's commit awaits the vat critic). Full
wall evidence + re-pilot technique log + Task-12 deviations:
`drafts/_d1b-wall-log.md` (the goalcomp harvest — READ IT before resuming).

**Tasks 1-11 (TDD, commits `91b1d5d..c8f9206`):** economy.json (8/12/2/45
kept — measured re-anchor: world_loop banks 2/session, district_hunt 0,
far under the ~24 scale-up rule) · Pack#spend!/possess! · god-mark ·
3 fixtures + altar verb (bank byte-identical pinned) · vat tribute ·
the judgment + floor + snap · presentation · Q6 rider · dodge edge-trigger
(one-word `pressed?` fix proven by a failing test: held Shift re-dashed) ·
deepest_band at drop time · d1b_fired telemetry. Two extra fixes the wall
caught: cue palette ARGB trap `88a4d65` (proximity was body-camouflaged,
lowhp red-not-yellow — plan colors deviated deliberately, critic
arbitrated) and cause=:taunt cue-stamp crash `283fbbc` (whitelist
hate/lowhp/proximity + regression test).

**Task 12 (`e75c295`):** vat_economy.json — 19,238-frame 5-act pilot
(seed 7), 20 curated captures, all economy beats on camera (inscribe,
2 tributes incl 2-body regrow, judgment mark-burn, floor vessel).
Staging deviation recorded: act-5 tribute fired AFTER the floor wipe
(epilogue). vision_critic verdict retries 2→4 (Bedrock truncations).

**Task 13 (wall): official sweep 8/9 PASS + vat_economy INFRA-only fail**
(verdict JSON truncated 4/4; determinism 20/20 byte-identical passed; the
same artifacts passed 39/39 earlier). The "dodge invalidates every stream"
claim was WRONG — zero scripts held dodge; real divergence = the judgment
(wipe scripts) + threat retunes; world_loop/loot_loop/threat_pull kept
their original streams. Re-piloted: specials_chain, taunt_anchor,
corpse_run, district_hunt, ledger_loop (ledger loss-tally beat not staged
after 3 attempts — self-gates honestly; render path untouched by D1b).

**NEXT SEQUENCE:** vat critic retry (in flight at goalcomp, task
bpbzr8l42 → /tmp/vat_critic_retry.log) → official vat gate exit-0 →
commit Task 13 → `rake perf` alone → full rake → Task 14 impl review
(Workflow ~1.0M declared: 3 finders ~110K + ≤12 refuters ~55K; PLUS one
Codex cross-vendor pass on the branch diff; ledger →
`drafts/_d1b-impl-review.md`) → merge `--no-ff`, NO push → checkpoint →
SEVENTH fun-verify (play-first law; Q1 meaning headline; routing
pre-registered in spec §Fun-verify).

## 2026-08-12 — v10 SCOPE DEBATE CLOSED + D1b SPEC (REVIEWED) + PLAN SHIPPED; next session EXECUTES

**Docs-only session — zero src/data changes; tests still 250/1,056 (each
commit hook-verified), checks 34, wall untouched.** Commits this session:
`867be8d` v10 scope → `fc10bef` fork ledger → `d65f9b9` spec →
`79d7d14` spec REVIEWED → plan + this checkpoint.

**Scope debate closed (owner via AskUserQuestion): v10 = D1b INSCRIPTION +
PRICED FLESH, Q6 legibility rider RIDES.** The load-bearing code fact that
shaped it: `Creature#revive!` is the sim's ONLY heal and fires ONLY on
wipe-respawn → the free wipe was the de-facto heal + body-recovery button
(deliberate wipes degenerate-optimal); inscription making wipes destructive
REQUIRES the priced valve. Design forks (owner): dissolution =
regrow-for-price + ONE-VESSEL FLOOR (possessed-at-wipe returns free);
marks CONSUMED by the judgment they survive. Dev calls (owner-approved
design): three nest fixtures (bank/altar/vat, no menus), tribute =
all-or-nothing full maintenance, banked stays station-only. Ledger:
PARKING_LOT §"v10 debate + design OUTCOMES".

**Spec:** `docs/superpowers/specs/2026-08-12-d1b-vat-economy-design.md`
(REVIEWED + OWNER-APPROVED). Adversarial review wf_2ccd8520-4cd: 3 lenses,
15 agents, **12 findings → 12 REFUTED, 0 confirmed** (2 clarity folds);
ledger `drafts/_d1b-spec-review.md`. ⚠️ Rule-7 note: declared ≤600K,
actual 999K subagent tokens — overrun recorded there. **Plan:**
`docs/superpowers/plans/2026-08-12-d1b-vat-economy.md` (14 tasks, TDD,
branch `d1b-vat`, code-fact-bound via `drafts/_d1b-exploration-brief.md`).
Bug bundle rides as Tasks 9-10 (dodge edge-trigger — the fix is
`pressed?`, the mechanism controllers.rb:56-61 already owns; deepest_band
at-drop-time). New check ids avoid the `mark_glyph_readable` collision
(that's the pack-mark reticle): `god_mark_reads` etc., 34→39 ADD-ONLY.
Corpse-husk law pinned in review: judgment clears only UNLOADED pack
records — `container_id` records are D1 pile markers, never deleted.

**NEXT SESSION — EXECUTION GREENLIT (owner, 2026-08-12: "proceed,
greenlit and approved"; goalcomp'd same day at 193 commits / HEAD
`fe39ce7` / tree clean):** execute the plan task-by-task
(subagent-driven recommended, as A2; inline executing-plans fallback),
9-script wall with ALL mandatory beats re-staged (dodge fix invalidates
every stream), impl review (budget per memory
`workflow-review-token-calibration`: ~110K/finder + ~55K/refuter), merge
--no-ff, NO push (private remote `YeeVeeX/game-two` exists since
2026-08-12 — pushing is the owner's action; fresh clones start ungated
until the 4-line hook recipe reinstalls — optional idea banked: tracked
`bin/install-hooks` next harness touch), then the SEVENTH fun-verify per
spec §Fun-verify (play-first law; Q1-meaning is the headline; routing
pre-registered).

## 2026-08-12 — A2 THREAT/PULL ECONOMY SHIPPED: merge `e3759c3`, 8-gate wall green, impl review clean; SIXTH fun-verify handed to the owner

**Executed the approved plan end-to-end** (subagent-driven, 13 tasks TDD on
branch `a2-threat`, 26 branch commits): priority targeting chain (taunt →
anchor → kit-hate → lowest-HP → sticky-first-seen w/ 3-tile steal margin) ·
engaged cap 5/target + uncapped pressuring ring (never swings, hollow-outline
cue) · leash-with-no-heal (walk home in-zone, snap-home on zone entry —
recorded deviation) · respawn suppression (12 tiles) + per-human beachhead
waiver (4 tiles) · depth gradient (district 7→15 spawns incl 3 `rusher_hater`,
drops ×1.0/1.5/2.0 by gate-distance band; the measured [10,12] grinder spawn
REMOVED) · tank-first possession (`initial_possessed: blocker`, cycle order
unchanged). New events `:human_retargeted`/`:human_leashed`; `a2_fired`
telemetry line (event-log-only).

**MEASURED at merge:** main at 186 commits, HEAD `e3759c3`, tree clean. Tests
250 runs/1,056 assertions green (now hook-enforced: pre-commit/pre-push run
`bundle exec rake` — owner's parallel session wired gauntlet + hooks, commits
`35d4923`/`fd6dc16`/`a2051be` ride this merge). Checks 31→34 (ADD-ONLY). Wall
**8/8 determinism + 8/8 critic** (verdicts `drafts/_gate-verdicts.log`
20260812-001305..010452; every wall script re-piloted under A2 + new
`threat_pull.json` 4-act script). Perf p95 0.232ms @15 humans (budget 16.6).
Impl review CLEAN (workflow wf_554c0d1c-303: 3 lenses, 1 finding, 1 refuted —
`drafts/_a2-impl-review.md`). Two task-level fix rounds on record: hater
body-color → HUMAN_BODY (tell = beeline, not color); re-piloted captures had
dropped mandatory beats (projectile/telegraph/swap/nest frames) — restaged, and
the "passed this morning" claim was refuted from artifacts (memory:
gate-critic-mandatory-beat-checks).

**SIXTH FUN-VERIFY LANDED (same day): VALID — Q3 MOVED. A2 WINS.** Full
verdict: `drafts/_a2-fun-verify-20260812.md`. First positive chore answer in
six verifies ("bank now or push deeper" = "It changed — real dilemma"). Threat
felt end-to-end: box "Felt it — and ran", run-back "In doubt at least once",
breather "Real option, felt fair". Behavioral: banked_events=3, wipes=1 (vs
6-8 baseline), one carrying-death pile ABANDONED in the field (corpse_looted=0
— recoveries are no longer free). Owner overall: "feels good."
**Routing applied (pre-registered):** next increment = SCOPE DEBATE (v10) with
D1b-inscription QUEUED as candidate. Signals recorded, not promoted: Q6
"read as randomness" → margin/threshold + legibility tuning; Q5 no-body-peaks
→ the Challenger trigger condition MET (its own future increment); Q8 "still
wouldn't care" → banked meaning still awaits D1b. Owner evidence for the
debate: NO healing → hunts end early → repetitive (parked priced-sustain /
pile-buys territory). **BUG banked w/ root cause:** held-Shift dodge locks
movement (controllers.rb:33-37 — level-triggered dodge branch starves the walk
branch; one-line fix but invalidates all 8 replay streams → bundle with the
next sim increment). Also: a2_fired `deepest_band` converts at summary time →
reads 0 when quitting from the nest (natural session end) — fix at-kill-time,
same bundle. NO code before the v10 debate closes.

**In-flight resolved:** gamesmith `tibia/psykik-starter` COMPLETE (all 6
stages done, notes-en.md on disk). Owner queue unchanged: council deepseek-r1
`us.` prefix; council-via-mmh-gateway + when-to-council update (own session).

## 2026-08-11 (night) — A2 BRAINSTORM CLOSED + SPEC (REVISED) + PLAN SHIPPED; next session EXECUTES the plan

**Docs-only session — zero src/data changes; tests still 215/935, checks 31,
main at the plan commit** (`85de477` v9 scope → `2465902` brainstorm outcomes
→ `2ff9fbb` spec → `51ae93c` spec REVISED → plan commit, this delta same
commit). Tree otherwise clean; drafts (gitignored) carry the evidence.

**All NINE forks closed** (three AskUserQuestion rounds + council debate;
ledger: PARKING_LOT §"A2 brainstorm OUTCOMES"): priority targeting · wipes
rare+heavy w/ attrition · live corridor · minimal in-map gradient · position
pressure · movement pulls · A2 ships ALONE (dev call; D1b trigger
pre-registered) · **economy vision = INSCRIPTION WITHIN RITUAL** (owner-locked
from the kimi/glm council synthesis after REJECTING the nest-biology thesis —
solar-vs-chthonic diagnosis; `drafts/_council-economy-verdict.md`) · human
counterplay NONE in A2 (Challenger beat pre-registered).

**Spec:** `docs/superpowers/specs/2026-08-11-a2-threat-pull-economy-design.md`
— REVISED after a 15-agent 3-lens adversarial workflow (12 findings: 11
refuted, 1 confirmed-low folded; `drafts/_a2-spec-review.md`). **Plan:**
`docs/superpowers/plans/2026-08-11-a2-threat-pull-economy.md` (13 tasks,
1,057 lines, TDD, code-fact-bound via exploration brief; branch `a2-threat`).
**OWNER APPROVED spec + plan + execution 2026-08-11 ("approved proceed")** —
the review gate is CLEARED; measured state at approval: 158 commits, HEAD
`0bf6912`, tree clean, 31 checks, 47 drafts.

**NEXT SESSION (greenlit):** execute the plan task-by-task (subagent-driven
per the accepted recommendation; inline executing-plans as fallback),
8-script wall, merge --no-ff NO push, checkpoint, then the SIXTH fun-verify
per spec §Fun-verify (telemetry line first, 8 questions verbatim in two
batches + entrainment probe; routing pre-registered incl. D1b auto-promotion
as the inscription economy on "chore unmoved + threat felt").

**Gamesmith (background, verified):** `tibia/gudii-ruins` + `tibia/gudii-monk`
COMPLETE (notes-en.md on disk; mechanics cap fix `8ab67c3` + ~5 Bedrock
ServiceUnavailable retries). `tibia/psykik-starter` (owner-pasted beginner
guide, transcript banked `drafts/_psykik-newplayer-transcript.md`) ingesting
in background — verify its manifest next session. extract/synthesize regen
still DEFERRED (GATE-4 owner flow). Owner queue (from this session): council
MCP deepseek-r1 id needs `us.` prefix; council-through-mmh-gateway upgrade
(seats grok-4.3) + when-to-council skill update — own session.

## 2026-08-11 (evening) — EVIDENCE-GATHERING SESSION: Tibia corpus deep-read banked; A2 brainstorm is NEXT (v9 scope rewrite first)

Same-day follow-on to the fifth verify (below). Owner chose (AskUserQuestion):
**talk design first** + **fold "what does the pile buy, and when" into the A2
brainstorm as an explicit section** (A2 stays first, as locked). Owner also
rejected my 20-question sweep counter-offer implicitly by approving the plan:
the fork set will be ~8-12 GENUINE owner-level forks, batched, evidence-cited,
presented BEFORE the A2 spec.

**Evidence banked this session (all in `drafts/`, gitignored; index in
PARKING_LOT §"A2 brainstorm evidence inputs"):**
- `_gudii-backup-probe.md` — deep-probe of the 98-transcript Gudii corpus
  (aggro fragility f21, laps/respawn/overkill f83, supply finances f38,
  environment pressure f15/f79; top-5 reads; explicit absence list). The
  owner's NotebookLM notebook = the SAME 98 sources (overview banked; read via
  CDP on the real Chrome — see memory `browser-automation-google-auth-trap`).
  Owner then directed ACTIVE chat mining of the notebook → subagent driving
  the chat over CDP with 8 gap-targeted questions, harvest to
  `drafts/_notebooklm-harvest.md` (**IN FLIGHT when written** — if missing
  post-compact, re-run: recipe + questions are in the harvest file header or
  re-derive from the probe's absence list).
- `_gudii-ruins-transcript.md` + `_gudii-monk-transcript.md` — two
  owner-picked videos, transcripts verbatim (team-hunt pull choreography;
  solo progression economics).
- `_gamesmith-consequence-synthesis.md` — 12-agent workflow re-read of the
  5-game corpus with the consequence-economics lens. **IN FLIGHT when
  written** (run `wf_de8ce8ad-579`: 7/7 extractions + synthesis DONE, critics
  running) — if the draft is missing post-compact, the synthesis JSON is in
  the run's journal.jsonl; resume via scriptPath+resumeFromRunId.

**IN FLIGHT (background, survives this session):** gamesmith ingestion of
`tibia/gudii-ruins` (623.95s, downloaded; mechanics stage FAILED on the 8000
output cap — known failure mode; cap raised to 16000, gamesmith commit
`8ab67c3`, pipeline resumed from cache) then `tibia/gudii-monk` (queued) —
bash task b2gr5flwf; verify per-recording manifest.json stages done. ⚠️
gamesmith `extract --force`/`synthesize --force` regen DEFERRED deliberately
(rewrites docs game-two FRs cite; GATE-4 owner flow) — an explicit reviewed
step later, not silent absorption.

**NEXT SESSION (order locked):** (1) scope contract → v9 in CLAUDE.md (A2 in,
ledger STAYS, economy parked except the pile-buys brainstorm section); (2) A2
brainstorm (superpowers:brainstorming) consuming the PARKING_LOT evidence
index; (3) owner forks via batched AskUserQuestion BEFORE the spec; (4) spec →
plan per project convention. No A2 code before an approved spec+plan.

## 2026-08-11 — FIFTH FUN-VERIFY LANDED: VALID, LB-1 REFUTED — **A2 PROMOTED (the v8 pre-queue fired)**; scope v9 + A2 brainstorm are NEXT

**The verify (full doc: `drafts/_ledger-fun-verify2-20260811.md`):** owner
played one fuller session on merge `42b54d6` (telemetry: 15 fights, 6 wipes,
**5 banks — the first voluntary banks in any verify session**, 1 negative
fight) and answered all 8 spec questions via AskUserQuestion (two batches).
**Q1 "landed as a payoff"** — first positive signal in five verifies; the
presentation iteration fixed visibility, so the verify is VALID as a meaning
test. **Q3 "still a chore" (FIFTH ask) on a VISIBLE ledger → the v8 owner
lock fired: A2 threat/pull economy PROMOTES AUTOMATICALLY** (supersedes the
2026-08-10 demotion; no new scope debate). LB-1 refuted cleanly: the tally
lands as a moment-payoff but creates zero meaning (Q4 same walk, Q5 "banked
anyway — tally meant little", Q7 "wouldn't notice", Q8 "wouldn't care").
Drama (D1) → no; legibility (ledger) → no; the remaining lever is
consequence. **Ledger disposition: STAYS through A2** (Q1 positive, per the
pre-registered disposition clause). Q6 "some I couldn't read" = polish signal
only (likely the n=1 loss line and/or bank reconciliation lines) — quarantines
nothing; recorded for a later pass, NOT a presentation re-route.

**Owner vision check (same session, answered in conversation + verdict doc):**
"is the bank/point system arcade drift?" — the verify then MEASURED the
intuition: a well-presented number with no world-consequence is score. The
roadmap answer is A2 (threat) + D1b (banked feeds the vat), never more juice.

**NEXT SESSION (in order, none of it done yet):** (1) **scope contract → v9
in CLAUDE.md FIRST** — A2 threat/pull economy IN, everything else stays
parked, ledger recorded as STAYS; (2) A2 brainstorm folding PARKING_LOT's A2
shape notes (owner threat-accumulator vs original pull-density — reconcile;
leash-with-no-heal, gate beachhead, chaser cap; aggro soft-cap 8-12 + density
costs; corpus caveat: zero touchstone evidence for aggro systems — defend A2
from game-two's own diagnosed problems) + tank-first possession feedback;
(3) spec → plan → implement → 7-gate wall → SIXTH fun-verify. Economy (D1b,
spending banked) stays parked in all branches.

## 2026-08-11 — LEDGER PRESENTATION SHIPPED (merge `42b54d6`); FIFTH fun-verify is the ONLY remaining step

**State (measured):** `main` at merge `42b54d6` (149 commits; branch
`ledger-presentation`, 6 commits, merged `--no-ff`, NOT pushed — no remote).
**215 tests / 935 assertions green.** Perf p50 0.019 / p95 0.100 / max 4.386 ms
(budget 16.6). **ALL SEVEN gates green with the critic** (31 vision checks —
count reconciled: the harvest's "32 measured" was wrong, the file had 30, now
31 with `ledger_prominence` added). Determinism 7/7 first try (99 captures
byte-identical). Critic wall 7/7; one INFRA flake (corpse_run, empty model
output — not a check FAIL) passed on plain retry. Ledger verdicts substantive:
prominence = "large bold type on contrast panels, dominating center screen";
pop frame 579, negative grammar 11131, veil recap 2017 all PASS with reasons.

**What shipped (render-only; sim untouched, all 7 replay streams valid):**
beat tally rebuilt — centered dark panel block above the avatar
(`ledger_block_y` 160), 42pt net / 26pt lines / 20-32px glyphs, entrance pop
1.35→1.0 (sqrt ease, 10f) + additive arrival flash (6f), exit keeps the
final-third fade; wipe recaps at `ledger_wipe_y` 340 below THE HUNT ENDS. Six
data keys in `data/display.json`; zero constants in Ruby. Spec + plan:
`docs/superpowers/{specs,plans}/2026-08-11-ledger-presentation*`.

**Three evidence-driven amendments to the approved plan (all capture-proven,
recorded in the spec):** (1) wipe beats get NO flash — `beat_left` freezes all
veil long, so the age-driven flash sat at full alpha ~90 frames and washed the
recap to an unreadable beige blob (frame 2017 pre/post proof); (2) solo take
lines promote to the 42pt font — a lone +N (the most common beat) was the
quietest, inverting err-loud; (3) flash peak is a data key
(`ledger_flash_alpha` 120) — at 200 the age-0 flash whited out the magenta
glyph identity (frame 3995 proof). Plus: `ledger_wipe_y` 310→340 (frozen full
pop overlapped the wipe title persistently), and the three added captures
re-aimed 594/2020/11146 → 579/2110/11131 (headless probe: resolves fire at
576/2017+veil/11128 — the plan's "beats start at old capture frames"
assumption was false).

**Owner vision check (mid-session, answered in conversation):** asked whether
the bank/ledger work is drifting arcade. Position taken (dev of record):
mechanically the game is consequence-RPG (world-anchored value, corpse debt);
the real arcade-by-omission hole is that BANKED value does nothing — which is
the known pile-lacks-meaning finding, roadmapped as D1b (banked feeds the vat)
and A2 (threat economy), both correctly parked behind triggers. Drift guard on
record: if a VISIBLE ledger still reads as a chore, the answer is A2
(world-consequence), never more juice.

**NEXT: the FIFTH fun-verify is the ONLY remaining step.** Owner plays
(`bin/play`), capture the TELEMETRY line, then the spec's 8 questions VERBATIM
via AskUserQuestion in TWO batches (Q1-Q4, Q5-Q8), verdict + LOCKED v8 routing
banked in `drafts/_ledger-fun-verify2-20260811.md`, checkpoint updated, STOP.
Routing (locked, owner 2026-08-11): Q3 "still a chore" on a VISIBLE ledger →
A2 promotes AUTOMATICALLY (scope contract to v9 FIRST; fold PARKING_LOT A2
notes + tank-first + hub rename into its brainstorm; ledger disposition per
Q1/Q2/Q5/Q7 BEFORE the A2 spec; no A2 implementation in the verdict session).
Q6 couldn't-read AGAIN → presentation is not the layer; reward-salience
research is the pre-authorized contingency. Q1/Q2/Q5/Q7 any real signal →
ledger STAYS through A2; wallpaper + wouldn't-miss → REMOVED before A2.
Economy parked in ALL branches.

## 2026-08-11 — LEDGER FUN-VERIFY LANDED: INVALID AS MEANING TEST — total visibility failure; presentation iteration is NEXT

**PLAN APPROVED (2026-08-11, plan mode; zero code written yet — main clean at
`1de852d`, 141 commits):** "louder, closer, animated — render-only". Full plan:
`C:\Users\gabri\.claude\plans\happy-exploring-hinton.md` (tasks 0-10); context
harvest (verbatim check drafts + renderer code sketches + pinned exploration
facts): `drafts/_ledger-presentation-harvest.md`. Load-bearing constraints
discovered in exploration: RENDER-ONLY (a resolve-punch hitstop is a SIM change
that desyncs the 7 replay streams — rejected); screen-center IS player-anchored
(camera); FR-025 bans saturation not prominence; capture indices are
determinism-neutral. Next session: execute tasks 0-10 (branch
`ledger-presentation` → spec/plan docs → display.json keys → renderer rewrite →
checks retarget+add → captures +3 → data asserts → visual iteration → 7-gate
wall → merge --no-ff NO push → checkpoint → FIFTH fun-verify, same 8 questions
verbatim, unprimed).

**The verdict (full doc: `drafts/_ledger-fun-verify-20260811.md`):** owner played
two sessions (telemetry: 4 fights, 1 negative fight, 2 wipes — the system FIRED,
no threshold bug) and answered all 8 spec questions via AskUserQuestion (two
batches). Result: **Q6 escape-valve at maximum — "never saw any of it."** Q1/Q2/Q4
all "never noticed"; Q5 zero-exposure (banked_events=0 both sessions); Q7
"wouldn't notice" (quarantined — can't miss the unseen); Q8 control "wouldn't
care" (unchanged from D1; control did its job). Per the LOCKED v8 routing:
(1) Q6 quarantines all meaning answers → **presentation iteration FIRST, meaning
verdict WAITS**; (2) Q3 = "not sure / didn't register", NOT "still a chore" →
**A2 did NOT auto-promote; it stays PRE-QUEUED** behind the next VALID fun-verify
(v8 owner lock binds that one: visible ledger + unmoved chore → A2 promotes
automatically); (3) ledger disposition (stays/removed) NOT decidable this round;
(4) D1b trigger did not fire (zero banking = disengagement, not exploit).

**Behavioral evidence (recorded):** two sessions, ZERO voluntary banks, ZERO
corpse recoveries (wiped twice, never ran back). Consistent with pile-lacks-
meaning + threat-never-contests, but quarantined as verdict input.

**NEXT INCREMENT (defined, not started): ledger presentation iteration.** Make
the beat impossible to miss — candidate levers in the verdict doc (player-anchored
/ center toast, scale-in + flash, bigger net line, recap contrast; no audio exists
in the build, visual juice is the lever). Diagnosis hypotheses H-vis1/2/3 in the
doc; the strongest: even the veil recap (forced 90-frame pause) went unnoticed
twice — size/placement/contrast, not timing. Then RE-RUN the exact 8-question
verify (FIFTH chore ask). Vision checks may be ADDED, never weakened; rendering
changes re-run the full 7-script wall. Scope: this is iteration on the SHIPPED v8
increment (spec §fun-verify pre-registers it), not new scope — the scope contract
stays v8 until that verify lands.

## 2026-08-11 — FIGHT LEDGER SHIPPED (merge `677b2ac`); awaiting owner fun-verify

**State (measured):** `main` at merge `677b2ac` (138 commits; branch `fight-ledger`,
10 commits, merged `--no-ff`, NOT pushed — no remote). **214 tests / 925 assertions
green.** Perf: p50 0.019 / p95 0.096 / max 4.288 ms (budget 16.6). **ALL SEVEN gates
green with the critic** (30 vision checks): world_loop, district_hunt, loot_loop,
specials_chain, taunt_anchor, corpse_run, ledger_loop (15 captures byte-identical;
final run all-PASS incl. the 4 new ledger checks). Wall history: loot_loop
specials_distinct FAIL = hatch-inversion flake (passed on retry); taunt_convergence
FAILED 2x consistently → check REPAIRED (self-anchor legal — D1 corpse_load_reads
precedent); two Bedrock internalServerException INFRA deaths retried; ledger_loop
needed 4 added event-proven captures (257/283/1076/13036) because the SHARED checks
file demands ring-swap/projectile/telegraph on camera in every script (pass=false
hatches).

**NEXT: the fun-verify is the ONLY remaining step.** Owner plays (`bin/play`),
capture the TELEMETRY line (fights= recovery_fights= negative_fights= distinguish
threshold-bug from no-combat), then the spec's 8 questions via AskUserQuestion in
TWO batches (Q1-Q4, Q5-Q8), verdict + PRE-REGISTERED routing banked in
`drafts/_ledger-fun-verify-20260811.md`, checkpoint updated, STOP. Routing (locked,
spec §fun-verify): Q3 (chore, FOURTH ask) alone promotes A2 (owner pre-authorized);
Q6 can't-read → presentation iteration first; Q1/Q2/Q5/Q7 decide ledger disposition
(any signal = stays through A2; wallpaper + wouldn't-miss = removed before A2);
Q4 same-walk consistent with LB-1; Q8 = labeled control. Read Q5 answers against
impl-review finding 2 (cross-leg bank beats — drafts/_ledger-impl-review.md).

**Done this session (plan tasks 4-9):** Task 4 wipe-recap tests (`96610ab` — ordering
pin, field-truth snapshot pip, veil freeze, dissolve-never-stomps, gate-staged
qualifying replace, hitstop freeze; the plan's replace test was strengthened: QUIET
180 > BEAT 150 means only FORCE resolves can catch a live beat). Task 5 bank-tally
tests (`6177496`). Task 6 telemetry fights/recovery/negative + byte-exact test rewrite
+ world_scene log line (`bafb7e5`). Task 7 renderer beat over the veil (`b39a824`),
all 6 old scripts SKIP_CRITIC byte-deterministic with beats rendering. Task 8 pilot
flight (`de75291`): ledger_loop.json = 19,818 frames seed 0, 11 captures, all five
beat kinds on camera; **CADENCE SHIP GATE PASS — hunt stretch 2.64 beats/min, session
3.63, band 1-4; quiet=180 stands, no retune.** Flight telemetry: fights=20
recovery_fights=1 negative_fights=4 wipes=8 carried_lost=2 banked=3. **Owned trim:**
act 2's separate non-wipe negative-beat capture (attrition denied a 2-body survivor
3x); grammar on camera via recaps + dark-loss beat, mechanics unit-pinned. Task 9
checks 26→30 appended + CLAUDE.md bullet (this commit).

**Impl review DONE (harvested: `drafts/_ledger-impl-review.md`):** 2 LOW findings,
both RECORDED not folded — (1) deadline-tick boundary: same-tick events flush after
the ledger ticks, so a pickup on the exact quiet-expiry frame misses its window
(fix would break the hitstop/veil freeze doctrine; watch item); (2) cross-leg bank
beats can misstate the felt bank moment (spec-faithful; read Q5 answers against it).
Big traced-clean list in the draft.

**Vision-critic incidents (full detail in the draft):** loot_loop `specials_distinct`
FAIL = one-off hatch inversion, passed on plain retry; taunt_anchor
`taunt_convergence_reads` FAILED TWICE consistently on byte-identical frames → check
text REPAIRED (self-anchor cast explicitly legal; failure case sharpened to
swarm-on-NON-blocker; discriminative content kept — the D1 corpse_load_reads
precedent). First wall run: rake + perf + world_loop/district_hunt/loot_loop/
specials_chain green WITH critic; ledger_loop byte-deterministic (2x 19,818-frame
replays identical).

**IN FLIGHT when written:** wall resume `taunt_anchor → corpse_run → ledger_loop`
with the repaired check, log `/tmp/full_wall4.log` (bg task; if dead after compact,
re-run those three `rake gate SCRIPT=harness/scripts/<s>.json` — critic flake rules:
pixel-verify FAILs, retry INFRA).

**Next sequence:** (1) confirm the 3 in-flight gates green — that completes Task 9's
wall (rake/perf/4 gates already green this session); (2) Task 10: findings already
reviewed + recorded (no folds → no re-gate needed beyond the running wall), merge
`--no-ff` to main, NO push; (3) checkpoint the merge hash; (4) fun-verify: offer
bin/play, capture the TELEMETRY line (fights= fields), ask the spec's 8 questions
via AskUserQuestion in TWO batches, bank verdict + PRE-REGISTERED routing (spec
§fun-verify; Q3 alone promotes A2 — owner pre-authorized) in drafts/, update
checkpoint, STOP.

## 2026-08-11 — FIGHT LEDGER: v8 locked, spec REVISED, plan tasks 1-3/10 done

**State (measured):** branch `fight-ledger` at `a09a466` (128 commits; main at
`8fe83b1`). **206 tests / 873 assertions green.** Working tree clean.

**Done this session:** D1 fun-verify banked (drama alone did NOT move the chore —
third ask); **scope v8 locked by owner via AskUserQuestion: post-fight ledger now,
A2 threat PRE-QUEUED** (auto-promotes on a failed ledger fun-verify — supersedes
the demotion when triggered; `0b553ea`). Spec DRAFT (`7e3d92c`) → 3-lens
adversarial review (direct Agent fan-out, ~287K tokens; Workflow skipped — it died
18/18 on this shape for D1) → **REVISED (`251b248`): 24 findings folded, 3
rejected** — verdicts + fold ledger in `drafts/_ledger-spec-review.md`. Key folds:
pickups REFRESH windows (3 independent derivations); pilot-measured cadence ship
gate 1-4 beats/min replaces the false between-waves arithmetic; **bank-leg tally
added** (fun-lens H2 + owner-supplied EK-1037 Hunt Analyser screenshot,
`drafts/_tibia-hunt-analyser-ek1037.md` — green-as-earned framing); kill notches
CUT; loss grammar split pip=out-there vs dark=gone; routing repaired (Q3 alone
promotes A2; legibility escape-valve; 8 questions, 2 batches). Plan written
(`8fe83b1`, 10 TDD tasks, code pre-written; self-review caught 5 staging bugs).

**Implementation (plan tasks 1-3 of 10 committed):** `data/balance/ledger.json`
(quiet 180 / beat 150) + interlock assertion quiet<settle (`4c21db7`);
`Game::FightLedger` — engagement window, `:fight_resolved` (payload: zone,
span_frames, opened_by, kills, pack_deaths, gained, stranded, destroyed, net,
wiped), beat record {kind, gained, pip_amount, dark_amount, net, recovery,
beat_left, beat_frames}, leg accumulator, World wiring AFTER wire_events (the
M6 ordering pin) (`22eb8b5`); 11 integration tests (`a09a466`).

**Execution learnings (already in test comments/commits):** drain_hitstop must
flush ONE tick before checking (hitstop starts at next flush); enter_district
aggros a rusher → en-route skirmish windows (quiesce_ledger idiom); respawn
cycles re-refresh windows (bounded drives); settle waits → mutate the clock (D1
idiom); nest gate is row 8 only.

**Next sequence:** plan tasks 4-10 IN ORDER (`docs/superpowers/plans/2026-08-11-fight-ledger.md`):
4 wipe recap tests · 5 bank tally tests · 6 telemetry (+telemetry_test REWRITE,
world_scene log line) · 7 renderer (beat AFTER wipe overlay — M1) + early
SKIP_CRITIC determinism re-check of all 6 old scripts · 8 pilot flight →
ledger_loop.json (5 acts) + CADENCE GATE 1-4 beats/min (retune quiet from
measurement) · 9 vision checks 26→30 + full 7-gate wall · 10 impl review → fold
→ re-gate → merge --no-ff (NO push) → checkpoint → fun-verify (8 questions via
AskUserQuestion, TWO batches; routing pre-registered in spec — Q3 alone is the
A2 promotion oracle; STOP after the verdict).

**In flight when written:** nothing.

## 2026-08-11 — D1 CORPSE RUN SHIPPED; awaiting owner fun-verify

**State (measured):** `main` at merge `95ae894` (119 commits; branch `d1-corpse-run`,
10 commits, merged `--no-ff`, NOT pushed). **194 tests / 811 assertions green.**
Perf smoke: p50 0.019 ms / p95 0.101 ms / max 4.4 ms (budget 16.6). **ALL SIX gates
green** — determinism + vision — twice: once pre-fold, once after the impl-review
folds (corpse_run: 17 captures byte-identical, 26/26 vision checks).

**Shipped (plan tasks 1-10, TDD, one commit each):** `data/balance/death.json`
(term 5400 / settle 300 / grace 2700 / flash 45 / pip alpha 0.4 — margin-anchored
hypotheses, NOT the death-doc's 10-min floor; spec records the conflict); corpse
containers on carrying pack deaths (serial-linked to cosmetic corpses, prune/cap
exempt while loaded — CF-1); per-zone term/settle clocks (veil-frozen, tick
everywhere); expiry → `carried_lost` (amount, tile, zone) + per-zone dark flash;
interact priority drop→corpse→bank (settle-gated, full transfer, death order on
stacks); wipe grace tops terms to the floor; renderer pip (hollow magenta outline,
tile-anchored, dim-while-settling, snap-on-lootable) + held corpses + expiry flash;
`Game::Telemetry` d1_fired line wired into play/replay/pilot.

**corpse_run.json (6th gate): pilot-authored, seed 0, run_until 9924, 17 captures.**
The flight's own telemetry: carrying_deaths=6 wipes=3 corpse_looted=5 carried_lost=1
banked_events=1 — every D1 beat fired live, incl. a drop-on-loaded-corpse concentric
frame (a rusher died ON the corpse tile), a genuine dim-pip frame, a graced container
(640f left → 2700 at wipe #3), and an off-camera expiry in an abandoned zone. Best
unscripted beat: at frame 7028 the recoverer looted a container and died the same
tick — the dying-breath loot merged the pile into a fresh container on the same tile
(now a recorded watch-list item: dying-breath term refresh).

**Deviations from the plan, owned:**
1. The plan's verbatim check wording (`pass=false` when not exercised) would have
   failed the five existing gates — the checks file is SHARED and the critic fails
   the gate on any false. Spec's own "pass-true hatches" line wins; discriminative
   content kept. `corpse_load_reads` also encodes CF-3's pip-beside-corpse offset
   after the critic (correctly) saw the knockback displacement and (wrongly) called
   it a defect.
2. **Stacked-tile case is NOT on camera** — the dying-breath loot consumed the first
   container in the same frame its looter died. Unit tests pin stacking + death-order
   loot; the vision checks don't require a stacked frame. Accepted trim.
3. Five plan-test staging bugs fixed (recorded in commits): AI walks a freed body off
   the stack tile during the swap drive; the flash-window arithmetic ate the per-zone
   flash assert; wipe drive ticks the term once; `revive!` moves a dead carrier's
   tile; long settle waits need `isolate_humans`.
4. Vision critic: 5 malformed-JSON verdicts (26 prose whys broke JSON) → verdict
   prompt hardened (short quote-free whys, exactly-once ids). Two hallucinated FAILs
   pixel-verified before dismissal (specials LUNGE_ACTIVE wash misread as white hurt
   flash; pip offset = CF-3 design).

**Impl review (drafts/_d1-impl-review.md, gitignored):** 5 findings — folded:
`corpse_looted` now carries term_left/term (the spec's margin oracle was otherwise
unmeasurable — frame math lies across hitstop/veil/grace); `leave_corpse` returns
the record it kept and the stamp uses that identity (cap-flood clobber, latent);
non-autovivifying public readers (draw-path pure-reader law). Spec notes: exact-
wipe-tick expiry legally dodges grace; dying-breath term refresh on the watch list.
8 seed suspicions traced clean.

**FUN-VERIFY VERDICT (2026-08-11, same day — full answers + routing in
`drafts/_d1-fun-verify-20260811.md`):** system FIRED (owner session:
carrying_deaths=2 wipes=2 corpse_looted=2 carried_lost=0 banked=1) and the
drama-alone experiment came back **NO**: settle = "standing in line", run back =
"in between" danger + "too long/tedious", Q3 = **"still a chore" (third ask)**,
Q4 = "banked, wouldn't care" (the spec's own D1b/ledger routing clause verbatim),
Q5 = clock never noticed (term-tuning signal, NOT actioned — no measured margins),
Q6 = no convenience deaths. Primary route: **the pile lacks meaning → ledger/D1b.**
Secondary: **threat never contests the corpse** (2/2 recoveries, 0 losses) — second
fun-verify pointing at threat since the owner demoted A2. Dev-of-record
recommendation: post-fight ledger next (pre-queued candidate); A2 re-promotion is
the owner's call with the evidence now on file; D1b's trigger did NOT fire.

**In flight when written:** nothing.

## 2026-08-11 — D1 SPEC REVISED + PLAN WRITTEN; next: implement on branch

**State (measured):** `main` clean at `1725d2a` (107 commits), 173 tests / 689
assertions green (5.1s), no branch open. Five world gate scripts on disk
(world_loop, district_hunt, loot_loop, specials_chain, taunt_anchor);
corpse_run.json will be the sixth, authored via pilot in plan task 9.

**What happened:** the D1 spec review Workflow DIED (3 lens agents stalled on
all 6 attempts each, 1.49M subagent tokens, zero results — journal had 18
starts / 0 results). Fell back per the user-scope ladder to a direct 3-agent
fan-out (code-fit, design, fun), verify stage done inline by the dev of record.
**21 findings, all folded** into the spec (now REVISED, 257 lines, `5f18e96`);
verbatim reports + fold ledger banked in `drafts/_d1-spec-review.md` (246
lines). Implementation plan written via writing-plans: 10 TDD tasks, 972 lines,
`docs/superpowers/plans/2026-08-11-d1-corpse-run.md` (`1725d2a`).

**The three load-bearing folds:**
1. **CF-1 (HIGH, confirmed by direct read):** the DRAFT's presentation was
   impossible — cosmetic corpses are pruned at 600f / cap-evicted / fade-anchored,
   all long before a container's term. Fix: monotonic serial links container to
   corpse record; linked records exempt from prune+cap; sim re-anchors at_frame
   at loot/expiry (renderer stays a pure reader).
2. **Term adjudication (FN-3/FN-6 vs DS-2):** the death-economy doc
   SELF-CONTRADICTS (its 3x-recovery rule fixes margin at 0.67; its 10-min floor
   at measured scale forces ~0.95; its own set-dressing line is >0.7). Spec now
   binds to the doc's measurable MARGIN TARGET (0.3-0.5): term 36000->5400 (90s),
   grace 18000->2700 (45s) — hypotheses, reset from measured wipe_to_last_loot_s.
3. **FN-1 (attribution):** at owner-verified-trivial threat, D1 may fire 0-2x
   per session — so fun-verify gets an "N/A never fired" branch + a TELEMETRY
   d1_fired line printed by bin/play on close (new Game::Telemetry, plan task 8),
   so a third "still a chore" cannot be misbooked against the wrong system.

**Also folded:** pip = hollow magenta outline (drops are filled — concentric
collision case), tile-anchored (knockback kills offset the corpse rect), dim
while settling, snaps on lootable; per-zone expiry flashes (taunt-pulse flat
array is zone-unsafe); pinned event payloads; grace rationale corrected (veil
freezes terms — it covers the RUN BACK); settle deviation from doc law 3 owned
(flat clock PERMITS mid-melee looting — Q1 needs it; 300f == rusher respawn is
a designed alignment); watch list completed (suicide fast-travel, grace-refresh);
fun-verify restructured to 6 questions.

**Next sequence (all greenlit — owner said "approved proceed"):** branch
`d1-corpse-run` -> execute plan tasks 1-10 in order (data -> sim -> renderer ->
telemetry -> pilot-authored corpse_run.json + 3 appended checks (23->26) ->
impl review -> merge --no-ff, NO push) -> deliver the 6-question fun-verify +
the owner's TELEMETRY line.

**In flight when written:** nothing. All three review agents landed and are
banked; no background tasks running.

**Owner queue:** none until the build ships — then the D1 fun-verify (the
spec's 6 questions; Q3 is the chore question, third ask).

---

## 2026-08-10 — A0.6 TAUNT SHIPPED; owner queue: taunt + D0 fun-verify

**State (measured):** `main` clean at merge `38064ac` (102 commits), 173 tests /
689 assertions green post-merge. `rake perf`: PASS (p95 0.057ms). All FIVE gate
scripts vision+determinism PASS on the branch pre-merge (world_loop,
specials_chain, taunt_anchor NEW, district_hunt, loot_loop) — determinism halves
byte-identical on every one.

**What shipped:** blocker's Slam now taunts — every living human within 6 tiles
gets a victim-owned 300f lock (`Creature#taunt!`/`taunted_target`, decays in
`tick_body`) forcing them onto the blocker's body, bypassing the aggro gate.
Pack-side anchor rule: a husk holding live taunt victims targets them above mark
(spec review B1 HIGH — the intended play hands the anchor to AI, and AI walks).
Presentation: rust underline (offset y+SIZE+9, clear of both the telegraph swell
AND the mark reticle) + one expanding hollow rust square pulse (Chebyshev-honest,
not a circle). District gained a 3-rusher cluster at [30,18]/[32,18]/[32,17] —
spec review C1 HIGH: the old map had no two spawns within one taunt radius, so
the median cast could never showcase the verb. `taunt_anchor.json` gate script,
authored via pilot mode's first real dogfood; 3 appended vision checks (20→23,
never weakened).

**Review chain (both folded, both banked):**
`drafts/_a06-spec-review.md` — 3-lens adversarial spec review (code-fit, design,
fun), 18 findings, 0 fatal. Load-bearing: death is a RELEASE not a suspension
(revival was resurrecting locks); the ring arc's one-shot flag was unused and
safe to consume; the anchor-walks HIGH; the map-can't-stage-the-fantasy HIGH.
**Baseline falsifier ran BEFORE any taunt code**: a pilot flight measured
retarget latency at 14-17f (bound was ≤90f to confirm) — the nearest-tie-break
flips onto the striker essentially on contact, quantifying "tank too weak" as a
number before writing a line of sim code.
`drafts/_a06-impl-review.md` — adversarial code-reviewer pass on the diff, one
CONFIRMED bug live-reproduced: the lazy taunt-clear lived only inside a reader
that organic play never calls between a wipe and a revival, so revived taunters
resurrected old locks; worse, the renderer's draw-path read could fire that
clear at wall-clock rate (nondeterministic sim mutation). Fixed: the reader is
now pure, clearing is sim-owned (tick_body dead-check + an all-zones respawn
sweep). Separately, the GATE (not code review) caught a real presentation bug:
a human that is both marked and taunted crowded the mark reticle and the taunt
underline into one 8px band — pixel-verified before fixing, offset moved to
y+SIZE+9.

**Owner queue — TWO fun-verify tracks, ask both:**

*A0.6 taunt (new):*
1. Does possessing the blocker now feel like playing a TANK — did Slam-then-swap
   become a move you *wanted* to make?
2. Did fights get stickier in a good way (enemies committed to the anchor) or an
   annoying way (too locked, no counterplay)?
3. How did the RHYTHM feel — 5 seconds of lock, then ~5 seconds where the room
   unlocks before Slam is back: is the gap between taunts too long, too short,
   or the interesting part?
4. Did the blocker die while taunting — and did that feel like your mistake or
   the game's?

*D0 loot loop (re-verify, now unblocked — same 3 questions as before the taunt
detour):* does banking now feel like it's defending something, or still a
chore? Per `drafts/_gamesmith-touchstone-digest.md`, the working hypothesis is
that D0 lacks PRESSURE on the carry (no supply burn, cheap death) — taunt was
shipped first specifically so sticky fights could be evaluated before any D0
number changes. **NO blind D0 tuning** — the decision (PARKING_LOT.md) is that a
tuning pass waits until this re-verify lands.

**Next candidate track (owner call, not pre-decided):** A2 pull economy / aggro
soft-caps is the design successor to taunt's raw lock (per spec's out-of-scope
list) — but nothing starts until BOTH fun-verifies above are in.

## 2026-08-10 (earlier) — A0.6 TAUNT PROMOTED, SPEC DRAFTED; spec review is NEXT

**State (measured):** `main` at `fc11e9c` (90 commits), 158 tests / 632 assertions
green. One uncommitted edit: touchstone-tension note folded into the taunt spec
(commit it first thing). Pilot mode SHIPPED (entry below). Owner answered the
fun-verify Q&A: **D0 "bank or push deeper" = "No, just a chore"**; progression/
variety = "Not sure"; **A0.6 blocker taunt PROMOTED** (scope contract v5, commit
`230de6e`). Decision recorded in PARKING_LOT.md: NO blind D0 tuning — taunt first
(sticky fights are upstream of carry risk), re-run the D0 fun-verify after A0.6.

**Spec state:** draft committed at
`docs/superpowers/specs/2026-08-10-a0.6-blocker-taunt.md` (`fc11e9c`). Core calls:
taunt rides Slam's active entry via the action_can_trigger? one-shot (no new key,
one-special rail intact); victim-owned 300f lock (`taunt!`/`taunted_target` on
Creature, decays in tick_body); taunted humans bypass the aggro_tiles gate (mark
precedent); rust underline + expanding cast ring tells; `taunt_anchor.json` gate
script to be authored VIA PILOT MODE (first real dogfood); 3 appended vision checks
(20 never weaken); data block `blocker.special.taunt {range_tiles: 6,
duration_frames: 300}`. ⚠️ Known tension folded into the spec: real exeta res is
spammable, our coupled version is ~1/10s — ship coupled first, decouple onto its own
clock ONLY if fun-verify says starved.

**Spec review status:** a 3-lens adversarial critique workflow was started then
KILLED mid-run (owner interrupt; no usable output — journal shows agents started,
none returned text). **Re-run as a direct Agent fan-out** (workflow-failure fallback
ladder), lenses: code-fit/determinism (attack the ring-arc trigger path — ring does
NOT use action_can_trigger? today, verify adding it is safe; cross-zone
taunted_target landmines in flow_to/blocked_for), design (Slam-coupling cadence,
does husk-AI blocker WALK OUT of the pincer post-swap), fun (does taunt just make
the 160HP blocker die faster? cheapest falsifying playtest). Fold → commit spec
REVISED → then implement.

**New research asset:** `drafts/_gamesmith-touchstone-digest.md` — distilled
gamesmith corpus (Tibia FULL extract + 4 notes-depth games). Load-bearing: Tibia's
bank loop works because supplies make sessions run NEGATIVE and death has teeth —
D0's chore verdict is missing pressure, not missing UI. Cite extracts, don't recall.

**Owner queue:** none blocking. (D0 re-verify happens after A0.6 ships.)

## 2026-08-10 (earlier) — PILOT MODE SHIPPED; owner queue: D0 fun-verify + taunt call

**State (measured):** `main` clean at merge `ccfa6e1` (87 commits), 158 tests / 632
assertions green post-merge. All FOUR gate scripts vision+determinism PASS on the
pilot-mode branch (replay path verified untouched between the gate run and merge).
Zero `src/` changes (`git diff main -- src/` was empty at merge — TOOLING scope held).

**What shipped:** `harness/support.rb` (expand_script + save_opaque extracted,
gosu-free), `harness/pilot_session.rb` (pure core: Parser whitelisting controller
ACTIONS + swap, Inbox via binary size+pread with truncation tripwire, Recorder
exporting hold-ranges-only with capture K→K−1 indexing, PilotInput, state/dump
serializers, GotoEngine with unreachable/zone_changed/possession_changed/pack_wiped/
guard aborts), `harness/pilot.rb` (thin window host: assigned-$stdout log — IO#reopen
takes an EXCLUSIVE handle on mingw, found live —, FIFO one-in-flight, speed cap 60,
quit preempts in-flight commands and always exports last.json, reset generation-tags
capture dirs, draw+update both under the FATAL/crash.json contract), 59 new tests
(29 pure + 7 integration + folds). `rake pilot NAME=<n> SEED=<s>`; commands doc in
CLAUDE.md + pilot.rb header.

**Acceptance proof (live, no mocks):** session `first-flight` flew the full D0 loop
via inbox appends (goto rusher → kill → drop → pickup → gate → bank, STATE banked=1);
window minimized during `wait 600` still advanced exactly 600 frames; both gate
crossings aborted goto with `zone_changed`; exported script replayed via rake capture
reproduced `banked frame=723 amount=1` and **both capture PNGs MD5 byte-identical**
(b60c33ba…, e4d2cc81…). Transcript: `drafts/_pilot-first-flight.md`.

**Adversarial review:** 7 findings, 0 HIGH (core determinism claim verified sound);
all folded or documented — ledger in `drafts/_pilot-review.md`.

**Owner queue (unchanged, now unblocked):** (1) D0 fun-verify — play the loot loop,
answer the 3 questions in the D0 entry below; (2) A0.6 blocker-taunt promotion
decision (PARKING_LOT.md — recommended next track, NOT started).

## 2026-08-10 (earlier) — PILOT MODE APPROVED + PLANNED; implementation is NEXT

**State (measured):** `main` clean at `1216d14` (78 commits), 122 tests / 475
assertions green. D0 merged and awaiting owner fun-verify (entry below). Owner
approved **pilot mode** ("yes I approve the upgrade, proceed as you consider best")
— a file-driven interactive harness so the dev of record can play/inspect/capture the
real game. Plan mode was used; the plan is **approved and committed** at
`docs/superpowers/plans/2026-08-10-pilot-mode.md` (copied from the approved plan file;
a Plan agent pressure-tested the design — 11 findings, 2 HIGH: goto zone-safety,
capture frame off-by-one — ALL folded into the committed plan).

**Pilot mode in one line:** commands appended to `tmp/pilot/<NAME>/inbox.txt` drive
the REAL sim+renderer in a real Gosu window (`hold/press/wait/goto/capture/state/dump/
speed/export/reset/quit`); output streams to `log.txt`; idle = frozen sim; every
session exports to the standard replay-script format, replayable via rake capture/gate.
Scope class: TOOLING (zero src/ changes; game scope contract untouched). Branch
`pilot-mode`, adversarial review, merge --no-ff, NO push.

**Task sequence (from the committed plan, execute in order):** (1) extract
`harness/support.rb` (expand_script + save_opaque; gate byte-identity proof) → (2)
pure tests first for parser/inbox/recorder/capture-indexing → (3) implement
`pilot_session.rb` → (4) headless round-trip + goto tests against the REAL World
(incl. hitstop-spanning hold; goto aborts) → (5) `pilot.rb` window host + rake pilot
task → (6) live verification: fly the D0 loop via inbox, export, MD5 pilot-PNG vs
replay-PNG byte-identical (THE acceptance bar), bank transcript to
`drafts/_pilot-first-flight.md` → (7) adversarial review → fold → 4 gates green →
merge. All invariants and folded findings are IN the plan file — read it first.

**Also pending from this session:** owner fun-verify of D0 (3 questions in the entry
below); blocker-taunt candidate parked in PARKING_LOT.md.

## 2026-08-10 (later) — D0 SHIPPED; AWAITING OWNER FUN-VERIFY

**State (measured):** `main` clean at merge `386d1e4` (75 commits), 122 tests / 475
assertions green, `rake perf` PASS (p95 0.039–0.040 ms across runs). All FOUR gate
scripts (`loot_loop` NEW, `world_loop`, `specials_chain`, `district_hunt`) byte-identical
across double replays + vision-pass against the grown 20-check list (3 appended,
pass-true hatches; existing 17 untouched). `src/core/input.rb` byte-identical to
pre-D0; window.rb 62 lines.

**What shipped (D0 = three promoted things):** interact verb (H/F, edge-triggered
across BOTH swap kinds incl. the swap-tick press, one shared `World#interact` path,
pickup-before-bank); currency substrate (rusher `drop_table [1,1,2]` rolled from the
seeded sim PRNG — its first consumer; tile drops with 1800f all-zone decay pausing
under hitstop/veil; **no-reset merge clock** — spec-review finding 3 killed the
immortal-floor-stash exploit; per-creature swap-inert `carried` that VANISHES on death;
pack-owned `banked` wipe-safe by construction, session-only); carry HUD (magenta
numeral on possessed bar only — teal was TAKEN by the mark glyph, docs had it wrong;
banked numeral only within 3 tiles of the data-defined nest bank station [12,8]).

**Reviews (both banked, both folded):** spec review
`drafts/_d0-spec-review-reconciliation.md` (REJECT→folded: hatch polarity, hue
collision, merge clock, gate-tile drops, decay_frames field); impl review
`drafts/_d0-implementation-review.md` (ACCEPT + 2 low: swap-tick mask test added —
sabotage-verified to fail without the mask — and ledger-radius doc sync). Two mid-gate
render fixes from the vision critic: ledger radius 2→3 (tween-vs-tile-commit), and
telegraphing humans keep a body inlay (two adjacent flares read as Volley tiles).

**Owner queue (in order):**
1. **Fun-verify D0** — `bin/play`, hunt, pick up (H/F), carry, bank at the hollow
   magenta fixture west of spawn. The three questions are in the session report.
2. Owner asked mid-session for a blocker taunt ("exeta res") — recorded in
   PARKING_LOT.md as top next-track candidate; needs promotion via scope contract
   before any code.

**Next after fun-verify:** owner picks ONE track — recommendation banked in the session
report (A0.6 blocker taunt micro-increment), alternatives D1 corpse-run / A1 gambits /
A3 only if cadence collapsed.

## 2026-08-10 — A0.5 SHIPPED + FUN-VERIFIED; D0 (loot loop) PROMOTED — spec is NEXT

**State (measured):** `main` clean at merge `157af7b` (65 commits), 96 tests / 372
assertions green, `rake perf` PASS (p50 0.009 / p95 0.038 ms). All three gate scripts
last measured deterministic with 17/17 vision checks (`world_loop`, `district_hunt`,
`specials_chain`). A0.5 implementation review: `drafts/_a05-implementation-review.md`
(ACCEPT, 3 findings folded).

**Owner verdict on A0.5 (verbatim): "yeah it feels good, now needs more variety and
progression sense."** → Owner promoted **D0 — the thin loot loop** from
`docs/design-corpus/death-economy-design.md` (D0 staging section is the binding fuel).
A1 gambits explicitly NOT bundled — parked behind D0's own fun-verify.

**D0 loop:** kill Rusher → deterministic tile drop → pick up (new interact verb,
edge-triggered across swaps) → carry on one body (per-creature, swap-inert) → bank at a
data-defined Nest station → banked total permanently safe. D0 death rule: carried value
on a dying body VANISHES (corpse containers are D1). Quiet HUD: carried on possessed
bar; banked visible only at the station.

**Cadence measured (challenge 2 resolved — see `drafts/_d0-cadence-measurements.md`):**
bank round trips 10.4s (nearest spawn, striker) to 32.9s (deepest, blocker) vs 5s rusher
respawn — banking is NOT trivial at current map scale; D0 proceeds without A3. Fun-verify
telemetry (frames between bank events) re-adjudicates.

**Next sequence:** D0 spec (resolve 6 design challenges: progression-signal honesty,
cadence [done], one-increment-vs-split, seeded determinism, ownership/zone lifecycle,
scope-contract v4 + this checkpoint) → adversarial spec review → fold →
writing-plans → commit plan → branch `d0-loot-loop` → test-first build order (drops →
interact → carried ledger → bank station → HUD/telemetry → `loot_loop.json` + appended
vision checks; never weaken the 17) → rake + perf + FOUR gates → impl-diff adversarial
review (`drafts/_d0-implementation-review.md`) → fold → re-gate → merge `--no-ff`, no
push → owner fun-verify: "bank-now-or-push-deeper a real decision? banked total
progression or bookkeeping? drops change your route?"

**Standing rails:** grok-voice-consult for EVERY player-facing name/label (bible
adjudicates; `loot`/`glean`/`bank`/`interact` stay spec-speak unless fiction-binding
approves); no gear/XP/inventory/corpse-recovery/fees/insurance/shops/districts; zero
balance constants in Ruby; window.rb ≤300; `core/input.rb` untouched unless live code
proves otherwise; events registered on first use; session-persistence decision must be
explicit in the spec (no smuggled save system).

## 2026-08-09 (late — A0.5 SPEC REVIEW-FOLDED) — implementation plan is NEXT

**M2.1 fun-verified by owner ("feels better now, yeah")** → new directive: "add some spells
and methods of teamwork." Brainstormed (direction Qs answered by owner: kit specials + one
pack command · big-moment ~10s cadence · focus-target mark), specced, and dual-reviewed.

**State (measured):** `main` at `85accc8` (54 commits), tree has only `docs/lore/` +
`drafts/` untracked (by design), 65 tests / 180 assertions green.

**Spec (REVISED, review folded): `docs/superpowers/specs/2026-08-09-a0.5-kit-specials-pack-mark-design.md`.**
Slam (blocker: ring control, interrupt override) / Volley (lobber: 3 delayed impact tiles) /
Lunge (striker: damaging dash-through) on a SECOND swap-inert per-creature exhaust —
STAGGERED 600/720/480f. Pack mark: one key, allies converge, leash 14t bounds it.
PROVENANCE LAW: voluntary Tab refused mid-special windup/active. Build order: action
spine + Slam (probe) → provenance → Lunge (plan_dash) → Volley (owner+frames_left) →
mark → harness/HUD close.

**Review record:** Codex REJECT on draft (8 findings) + Fable-lane review (agent stalled
2x at stream level; lanes driven by dev-of-record, all findings code-verified). 14 total
findings folded; reconciliation lives at `drafts/_a05-review-reconciliation.md`.

**Also this cycle:** `grok-voice-consult` skill (workspace scope, mmh gateway route
grok-4.3, reasoning=high temp=1.0, ledgered) — use for ALL player-facing text/names/lore
consults. Death-economy pointer folded into PARKING_LOT (`1874304`). Parallel knowledge
session shipped death-economy design (`c293420`) + world bible (`b027453`, merged).

**Next sequence:** writing-plans skill over the revised spec → implementation plan →
branch `a0.5-specials-mark` → execute per build order (test-per-fix, commit-per-task) →
rake+perf+3 gates (new `specials_chain.json`) → impl-diff adversarial review → fold →
merge --no-ff → owner fun-verify: "cast→swap→cast: situational or rote? allies a weapon
you aim?"

## 2026-08-09 (M2.1 SHIPPED) — feel repair merged; owner replay is NEXT

**State (measured):** `main` at merge `0c2f9ba`, 65 tests / 180 assertions green on main,
`rake perf` PASS on main (p50 0.007 / p95 0.038 ms), both `rake gate` scripts PASS
post-review-fold on the identical tree (world_loop 8/8 byte-identical + 13/13 vision;
district_hunt 10/10 + 13/13 — dash-through stayed deterministic). Branch
`a0-m2.1-feel-repair` merged `--no-ff`, kept for reference. The world bible (`b027453`,
committed by the parallel knowledge session onto this branch) merged along with it —
docs-only, per PARKING_LOT.

**All five fixes shipped as planned** (one commit each, test per fix):
rusher 16f/10t + pack aggro 10 + blocker dmg 25 (`6700e75`) · received hits shake-only
(`f1391e7`) · held movement survives Tab (`6bc26dd`) · dodge passes through bodies
(`1cb566c`) · adjacent lobber opens range (`8f1df1a`) · capture re-aims (`bcb1d86`).

**Adversarial review verdict (landed + folded, commit `4f22ef6`):** 3 findings.
1. **VERIFIED, fixed:** cornered AI lobber deadlocked (map corner: no neighbor increases
   distance -> stood motionless and died, probe-confirmed). retreat_step now falls back to
   an equal-distance side-step along the wall. Regression test corners it live.
2. **VERIFIED, fixed:** law-5 test excused ANY pack-death frame, not just forced-swap
   frames; now reconciles suspect frames against `possession_changed(forced)` post-hoc.
3. **PREEXISTING, parked:** player step/dodge cut diagonal wall corners the AI's
   FlowField#open? forbids — guaranteed-escape exploit, NOT introduced by M2.1. Parked in
   PARKING_LOT (fix changes movement feel -> owner verdict first).

**Owner replay axes:** kit identities / Lobber possession / pincer pressure / District One
+ explicitly: **"does dodge feel like an escape now?"** If more offensive depth is still
wanted after this plays well -> A1/A0.5 conversation (spec first), not code.

## 2026-08-09 (M2 feel-check FAILED) — M2.1 feel-repair is the active work

**Owner verdict on M2 (verbatim): "game feels slugish now, dash/doge is not very useful and
instead the character gets stuck and the teammates now feel dumb and weak, the enemies are too
hard if the player doesn't have spells or more stronger combos to chain."** M1 was "feels
really good" → this is a regression M2 introduced, NOT missing content. **No spells / no new
systems** (Kethral trap); diagnose → tune → re-verify. The pincer AI was owner-ordered and stays.

**State (measured):** `main` at `44c1cef` (37 commits), clean but `docs/lore/` untracked by
design, 58 tests / 158 assertions green. M2 IS merged — M2.1 fixes forward on a new branch
(`a0-m2.1-feel-repair`), do not revert.

> [knowledge-session note 2026-08-09 ~18:15: `docs/lore/` is no longer untracked — the
> world bible passed its 5-input critic gate and is committed as `b027453` on
> `a0-m2.1-feel-repair` (single-file commit, no M2.1 files touched). New mechanics-research
> map at `drafts/_mechanics-research-map.md` (4 vault notes → parked systems). Docs-only;
> no gameplay relevance to the feel-repair.]

**Full diagnosis + work order: `drafts/_m2.1-feel-repair-plan.md`** (code-traced root causes,
priority order, per-fix tests, verification invariants). One-line summary of the six calls:
1. Dodge no-ops when first tile is occupied (grid_walker commit stops before blocked tiles;
   the pincer fills exactly those tiles) → dodge dashes THROUGH bodies, lands on first free
   tile in range; walls still stop; refuse if no free tile.
2. Hitstop fires per RECEIVED hit — 5 pincering rushers freeze 15-25% of wall time
   ("sluggish"; perf measured innocent) → hitstop only on possessed's DEALT hits/kills;
   received keeps flash+shake.
3. rearm! masks held MOVEMENT after every Tab (micro-stall per swap) → unmask movement,
   keep attack/dodge edge-triggered (law 2 intent preserved).
4. Rushers outrun 2/3 kits + out-aggro all (14f/12t vs 13-19f/8-9t) → rusher 16f/10t;
   difficulty comes from surround geometry, not footspeed.
5. Allies weak/passive: pack aggro → 10; blocker dmg 20→25 (2-shots a rusher); lobber
   adjacent-inert fix PROMOTED from A1: step-away micro-rule (~6 lines) in AiController.
6. "Spells/combos" → swap IS the combo system, currently masked by 1-5. Re-verify after
   repair; more offensive depth = A1/A0.5 owner call, PARKING_LOT for now.

**Next sequence:** branch `a0-m2.1-feel-repair` → execute plan order 1-5 (data tune, feel,
controller, dodge-through, lobber step-away; test per fix) → `rake` + `rake perf` + BOTH
gates (re-aim district_hunt capture frames from event log — rusher speed change shifts all
timings; never weaken checks) → adversarial review over diff (NEVER merge unreviewed) →
fold → merge --no-ff → owner re-check: same 4 axes + "does dodge feel like an escape now?"

## 2026-08-09 (M2 SHIPPED) — review folded, merged to main; owner feel-check is NEXT

**State (measured):** `main` at merge `6e1d432`, 58 tests / 158 assertions green,
`rake perf` PASS on main (p50 0.007 / p95 0.039 / max 1.48 ms), both `rake gate` scripts
PASS pre-merge on the identical tree (district_hunt 10/10 byte-identical + 13/13 vision;
world_loop 8/8 + 13/13). Branch `a0-m2-kits-district` merged `--no-ff`, kept for reference.

**Adversarial review verdict (landed + folded, commit `e76bb44`):** 3 findings.
1. **MEDIUM, fixed:** human respawn ignored occupancy — body parked on the spawn tile at
   the respawn frame stacked two creatures on one tile (probe-confirmed live). Respawns now
   DEFER while the tile is occupied, retry each tick. Regression test camps the spawn.
2. **LOW latent, fixed:** a kit without `respawn_frames` never left the humans roster on
   death (renderer would draw its ghost forever). Roster delete now precedes the early
   return. Regression test runs a mutated no-respawn kit through a real kill.
3. **LOW, OWNED as design:** knockback through a gate transits the whole pack — gates are
   physical terrain (Tibia-flavored); documented at `check_transition`, not special-cased.
Reviewer's husk-AI note (adjacent AI lobber is inert, needs dist>=2) → PARKING_LOT under A1
gambits with the expected playtest symptom ("my lobber just stands there").

**NEXT: owner feel-check on main** — kit identities (Striker/Blocker/Lobber), possessing
the Lobber, Rusher pincer pressure, District One. From the reaction → A1 planning
(gambit engine + hot-reload is first candidate; A1–A3 queue in PARKING_LOT.md).

## 2026-08-09 (knowledge session) — world bible ON DISK, critique panel PENDING

**Scope: the mythology pipeline only — does not touch M2 state below.** Bible at
`docs/lore/world-bible.md`: 17,801 words, all 14 sections verified present. **UNGATED:
the 3-critic panel (originality/IP, consistency+hooks, craft) + revision pass have NOT
run** — treat names as provisional until then; file deliberately left uncommitted.
Research canon behind it: 4 `game-research/` vault notes (17,876 words total), indexed +
retrieval-smoke-tested via `hub kb reindex`; all four grep-clean of the corpus's
poisoned files (adversarial capture sweep found 2 misattributed captures, an essay-mill
pair, and a provenance-free AI synthesis — verdicts encoded in knowledge repo `5b3c206`).
Full recovery map + critic-prompt invariants: `drafts/_egypt-mythology-pipeline-state.md`.

## 2026-08-09 (latest) — M2 BUILT: kits + district + surround AI; review in flight

**State (measured):** branch `a0-m2-kits-district`, 56 tests / 148 assertions green, both
`rake gate` scripts PASS (district_hunt 10/10 byte-identical + 13/13 vision checks;
world_loop 8/8 + 13/13), `rake perf` PASS (p50 0.007 / p95 0.035 / max 1.35 ms per tick).

**What M2 adds:** three kits with real identity — Striker (fast, single-tile precision, no
knockback), Blocker (160hp wall, arc3 + knockback, uninterruptible windup), Lobber (6-tile
tile-stepped projectile, no friendly fire) vs Rushers in District One; nest = new hub;
town/threketh retired to data/zones_retired/. Renderer v2 carries ALL the vision-critique
fixes (facing notch, crimson-never-white pack flash, two-tone telegraph ≠ gate gold, attack
lunge, persistent fading corpses) + 3-bar kit-colored HUD with exhaust pip + edge pips for
off-screen kin. Knockback is now the ATTACKER's stat (kit identity).

**Owner directive mid-build (verbatim): enemies "should try to trap/surround the players...
right now enemies seem to be following each other, make them more aggressive."** Shipped as
slot-claim pincer AI: converging attackers each claim a DISTINCT adjacent tile of their
target (deterministic roster order, rebuilt per tick) and approach greedily with flow-field
fallback; rusher step 16→14, windup 24→20. Asserted by test (≥2 distinct sides during the
assault) and visible in gate frames.

**In flight when written:** adversarial code-reviewer over the M2 diff — brief + already-done
verification + fold-in procedure harvested to `drafts/_m2-review-inflight.md` (if the verdict
is lost, RE-RUN the review; do NOT merge without it). After merge: owner feel-check (kit
identities, Lobber possession, Rusher pincer pressure, district). NB `docs/lore/` is
deliberately untracked (bible ungated — see the knowledge-session section above).

## 2026-08-09 (later night) — M1 FUN-VERIFIED; M2 underway

**Owner verdict on M1 (verbatim): "feels really good!"** — possession core validated: Tab swap,
forced-swap sting, exhaust rhythm, wipe loop. No complaints logged; exhaust 45f stands until
playtest says otherwise. M2 (rest of the approved A0 spec) started same session: three kits
(Striker/Blocker/Lobber + projectile), Rushers, nest + district zones, 3-bar HUD + exhaust pip,
edge pips, carried critique fixes, perf smoke, district_hunt.json.
**Fiction note:** the world bible landed (`docs/lore/world-bible.md`, Egyptian×Fantasy,
deliberately NOT integrated — owner call pending per PARKING_LOT). M2 ships spec-speak
placeholders; no fake fiction names (de-slop rule).

## 2026-08-09 (night) — M1 POSSESSION CORE SHIPPED; owner feel-check queued

**State (measured):** branch `a0-m1-possession`, 11 commits over main, 48 tests / 128
assertions green, BOTH `rake gate` scripts PASS (possession_core.json 10/10 captures
byte-identical + 9/9 vision checks; world_loop.json 10/10 + 9/9). Player/Enemy classes
DELETED; Creature/Pack/controllers replace them. Orchestrator: window.rb ~60 lines.

**What M1 is:** the pack of 3 (shared prowler kit) in the existing two zones vs the existing
husks. Tab = voluntary swap (no stagger, edge-triggered inputs — held keys never leak into
the new body). Possessed death = forced swap to nearest survivor + 20f stagger + red veil
beat. All three dead = wipe → "THE HUNT ENDS" veil → pack respawns in town. Exhaust (45f,
data-driven) paces held-attack — the held-space barrier complaint is fixed by rhythm, not
input denial. Blanket 30f invuln REMOVED (per-attacker cadence paces damage; dodge i-frames
stay). Hitstop scoped to possessed fights only. Humans target the NEAREST pack creature,
not the camera.

**Deviations logged while implementing (all in committed messages):**
- `interrupt_on_hit` is a kit flag (husk windup uninterruptible, like the old game's husk) —
  without it 3-creature DPS stun-locked every husk and the loop never showed a telegraph.
- Allies yield the possessed's front tile (found by the suite: an ally body-blocking your own
  walk path broke zone transit).
- Exhaust 45f baseline + husk exhaust 81f (= its old 30+6+45 cadence, so husk feel unchanged).

**Phase 0 (review orders, all landed):** `rake gate` = double replay + md5 compare + Bedrock
vision verdict, ALL blocking (exit nonzero; verified both directions incl. a corrupted-byte
negative test). Gemfile.lock committed, gosu pinned = 1.4.6. Design corpus promoted to
`docs/design-corpus/`. YJIT decision text corrected. Timebase documented tick-locked with an
on-screen overrun counter.

**Owner feel-check (the M1 gate):** run `bin\play.cmd` — (1) Tab-swap mid-fight: does
relocating under pressure feel good? (2) forced swap when your body dies: does the sting +
stagger read? (3) held-space attack: barrier gone, rhythm there? (4) wipe → town: does losing
the whole pack land? React + report; M2's plan gets written from the reaction.

**M2 queue (next plan, after feel-check):** three kits (Blocker/Striker/Lobber + projectile),
Rushers, nest + district zones, 3-bar HUD + exhaust pip, edge pips, carried critique fixes,
perf smoke p95 < 16.6 ms, district_hunt.json. Fiction binding when the Egypt-corpus bible
lands (order form in the spec).

**Adversarial review (landed + folded in):** 4 findings, all fixed pre-merge — (1) vision gate
could false-PASS on partial/empty model output → checklist-coverage validation added (missing
or unknown check ids = infra error, exit 2); (2) forced-swap stagger was bypassable by an
instant Tab → Tab refused while possessed is staggered (+ regression test); (3) dead husks
land same-frame posthumous hits → kept deliberately, documented as the simultaneous-trade
call in resolve_attacks; (4) respawned humans reused live names, corrupting the harness event
log → monotonic per-zone serials.

**Known honest-signal flake:** the `telegraph_reads` vision check is borderline — telegraph
yellow ≈ gate gold (identical frames flipped PASS/FAIL between gate runs). The check stays;
the COLOR is the bug, and it's already in M2's carried critique fixes.

**Perf (measured, informal):** 6,600-tick sim run incl. dungeon combat: p50 0.007 ms /
p95 0.039 ms / max 2.63 ms per tick — ~2 orders of magnitude under the 16.6 ms budget.
The formal p95 perf smoke still gates M2 (district + Rushers is the load case).

**In flight when written:** nothing — review landed, fixes verified, both gates re-run green.

## 2026-08-09 (evening) — grid v2 fun-verified; monster-flip designed, reviewed, and CUT DOWN

**State (measured):** 6 commits, 31 tests / 82 assertions green, grid world v2 SHIPPED and
owner-verified: *"so much better now feels very good"* — grid movement + hub-and-spoke validated.
One live complaint: held-space attack = impenetrable barrier (fix designed, see below).

**Direction locked this session (owner + evidence):**
1. **Monster flip:** play as a pack of 3 creatures hunting HUMANS in a collapsing modern city.
   Owner locked: full flip · gambit rules (JSON IF/THEN) · pack of 3 (blocker/puller/ranged) ·
   combat-core-first sequencing · world = hybrid "advance by breaking districts, re-home the nest".
2. **DE-SLOP RULE (owner, verbatim-critical):** "The Pack"/"The Advancing Nest" framing rejected
   as AI-slop. Names must come from INSIDE the fiction. Slop test: could the name ship in another
   game unchanged? → then it's internal spec-speak only. Proposed grounding: owner's own Kethral
   mythos (Sondrekh wound, Kurmasi conlang, Kelvor/Grashk/Ashvorgravi ecology) — same world,
   other side of the wound; humans farm = the modern city it opens under. **OWNER CALL PENDING.**
3. **Anti-rabbit-hole comprobations (standing):** reference wall (Tibia research+footage /
   Kethral bible / Vlambeer juice — idea serves none → parking lot); "every commit must change
   what the player sees, hears, or feels" (Kethral V2's own rule, now enforced); judge builds
   not briefs. → fold into CLAUDE.md with the spec.

**Dual adversarial review (Codex@high + Fable@max) both REJECTED Increment A as one increment.**
Full reconciliation + binding design law: `docs/design-corpus/design-review-reconciliation.md` (READ IT —
it contains the A0 cut, the 5 design laws incl. per-attacker invuln replacing blanket 30f,
determinism spec, swap-inert exhaust, forced-swap death, and the single-protagonist-stack risk).

**Evidence corpus (promoted to `docs/design-corpus/` 2026-08-09, tracked in git; bulky video
dumps stay gitignored in drafts/, do NOT re-generate):**
`tibia-research.md` (11 verified findings, 105 agents) · `drafts/_tibia-videos/*_analysis.md`
(3 video briefs via adapted Foreman pipeline; harness/video_analyst.py + vision_critic.py are
the tools) · `vision-critique-20260809.md` (Tibia-veteran critique of our captures; top fixes:
facing notch, hurt-flash never white, telegraph≠gate color, wall brightness, corpses persist,
ease-out tween) · `kethral-feature-map.md` · `design-review-reconciliation.md` ·
`marrow-fact-sheet.md`.

**Next sequence:**
1. Owner call on fiction grounding (Kethral mythos vs new bible) — then write the ONE-PAGE spec
   for **A0 = possession core only** (actor/controller refactor, 3 hardcoded kits, Tab swap,
   husk-grade ally AI, Rushers only, one district, exhaust as 45f data-driven hypothesis,
   per-attacker hit cooldowns, forced-swap death, determinism spec) in the chosen fiction.
2. writing-plans → implement A0 → Rule 2 gate (incl. critique fixes) → ship to owner.
3. A1+ (gambits w/ hot-reload, Shooters, pull economy w/ aggro cap, nest advance) each behind
   its own fun-verify.

**In flight when written:** nothing — all reviews landed and harvested.

## 2026-08-09 (playtest verdict) — slice is fun; direction pivot ordered

**Owner playtested slice v1. Verbatim reaction:** *"simple, fun yeah, there is no grid-based
movement yet like tibia and still misses the whole features of the first and second versions
of Kethral pygames, kethral arena is not what I intend."*

Parsed into direction (dev-of-record reading):
1. **Feel layer validated** — hitstop/shake/telegraph/dodge loop reads as fun. Keep it.
2. **Movement pivot: grid-based, Tibia-like tile stepping** — replaces free 8-way float.
   (Consistent with marrow's own thesis: "Tibia-style freedom".)
3. **The arena duel is NOT the game.** The intent is the fuller shape of the earlier
   Kethral pygame versions — world/zones/features, not a one-room duel.

**State (measured 2026-08-09):** 4 commits, 26 tests / 59 assertions green, 10 captures
byte-identical across runs, orchestrator 42/300 lines. Old-repo version dirs (py counts):
`prototype/` 57, `kethral/` 211, `kethral_v2/` 27, `project/` 2 — "first and second
versions" most plausibly = `prototype/` and `kethral/`; **confirm by mining, not assuming**
(`kethral_v2/` exists and was never mentioned in the handoff — check what it is).

**Next sequence:**
1. Mine `prototype/`, `kethral/`, `kethral_v2/` -> feature map of what "the whole features"
   means (movement model, world/zone structure, the game's actual shape). Write findings to
   `docs/design-corpus/kethral-feature-map.md` (originally drafts/, promoted 2026-08-09).
2. Design + implement grid movement (tile stepping) behind the existing input seam; replay
   scripts/tests move to tile assertions. Feel layer stays.
3. Rewrite SLICE_SPEC v2 around the real intent (world shape, not arena). Scope contract in
   CLAUDE.md updated to match — arena-only IN-list is now obsolete.
4. Ship next playable increment, Rule 2-gated.

**Harvested to drafts/ (gitignored, survive compact):** `_marrow-fact-sheet.md` (mined spec
numbers — do not re-mine), `_session-handoff-20260809.md` (original rationale).
**In flight when written:** nothing.

## 2026-08-09 (later) — vertical slice SHIPPED, awaiting owner playtest

- Env: Ruby 3.4.10 (`C:\Ruby34-x64`, no YJIT — RubyInstaller builds without it; accepted),
  Gosu 1.4.6. Capture API verified live: `Gosu.render` → `Image#save` works in-window.
- Shipped (commits `8f787de`, `2efe4c6`): core skeleton (event bus/state stack/data store/
  input seam), Rule 2 harness (replay + capture, byte-identical across runs, opaque-alpha
  fix), slice spec (docs/SLICE_SPEC.md), full loop: move/attack/dodge/die/respawn vs one
  husk with hitstop/shake/telegraph/hurt-flash. 26 tests green. Frames vision-checked.
- **Owner queue: run `bin\play.cmd`, playtest the loop, report. DONE WHEN owner calls it fun.**
- Balance deviation from spec: husk aggro 220→600 (one-room duel needs pressure).

## 2026-08-09 — project born; pre-compact checkpoint

**State (measured, not recalled):**
- Repo: `C:\Users\gabri\workspace\game-two`, `git init -b main` done, **0 commits** before this one.
- Files: `drafts/_session-handoff-20260809.md` (full session rationale — READ IT FIRST),
  this checkpoint. No code yet.
- Old repo (reference, read-only): `C:\Users\gabri\Documents.stale-20260413\coding_projects_main\Game On(e)`
  — 211 .py files under `kethral/`, Phases 1–17 done, its WORKSPACE_STATUS.md self-reports
  1,364 passing tests (claim dated 2026-04-02, not re-verified).

**Decisions locked this session (rationale in the handoff draft — don't relitigate):**
1. **Ruby + Gosu**, CRuby 3.4. DragonRuby and Ruby2D rejected. [Corrected 2026-08-09: the
   installed RubyInstaller 3.4.10 has NO YJIT (needs rustc at build time) — PRISM interpreter
   only. Perf is asserted by measurement, not by this decision text: M2 gate carries a perf
   smoke (p95 update < 16.6 ms) per the third review.]
2. **Audio = placeholder only.** Owner explicitly dropped the MIDI/procedural-SFX experiment.
3. **Claude is the dev of record; owner is the tester.** Design calls are Claude's to make.
4. **Better-this-time doctrine** (from Kethral post-mortem): scope enforced via project
   CLAUDE.md + PARKING_LOT.md; orchestrator ≤ ~300 lines; Rule 2 verification harness is
   Phase 0; depth-before-breadth — nothing new until the current loop is fun-verified.
5. **Budget rule (owner, 2026-08-09):** zero paid purchases/subscriptions outside AWS —
   free/OSS tooling only (seals Gosu-over-DragonRuby). Everything inside AWS is unlimited
   (Bedrock image gen for sprites, vision critique, etc.).

**Next sequence (in order):**
1. Verify environment: `ruby -v` (need 3.1+; install via RubyInstaller+devkit if absent),
   `gem install gosu`, smoke-test an empty Gosu window opens on this machine.
2. Scaffold: project CLAUDE.md (scope contract + non-negotiables), Gemfile, rakefile,
   `src/` skeleton (event bus, state machine, data-driven JSON loader — port the *pattern*
   from kethral/core, not the code), minitest harness, PARKING_LOT.md, .gitignore.
3. Phase 0 (blocking): deterministic replay + frame capture (`Gosu.render` → `Image#save`,
   VERIFY API against current docs first) + vision critique loop, proven on a moving square.
4. Distill `.kiro/specs/marrow/` + kethral phase docs into a 1-page vertical-slice spec
   (Claude's own design — improve, don't transcribe).
5. First playable loop: move → fight one enemy → die → respawn. Ship to owner to test.

**Owner queue:**
- Launch next session in `~/workspace/game-two` (this session's cwd was stuck in the old repo).
- Playtest builds when Claude ships them; react + report. No design homework.

**In flight when written:** nothing — no background agents pending.
