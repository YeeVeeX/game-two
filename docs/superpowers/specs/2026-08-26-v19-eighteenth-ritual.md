# v19 fun-verify — THE EIGHTEENTH ritual (spec: shape transcribed, wording FROZEN)

Status: **STAGED 2026-08-26 (s82)** — question wording lands frozen at
this commit; measurement hygiene is ARMED from this commit until the
verdict. Shape provenance (this spec TRANSCRIBES, it does not
re-decide): `drafts/_v19-foundation-20260822.md` §"The v19 fun-verify
ritual" (7 points, RATIFIED-G + RATIFIED-J) + its council pass
(adoptions A-i…A-v, transcripts `drafts/_v19-ritual-council-20260822/`).
Precedent instrument: the SEVENTEENTH
(`docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md`
§Fun-verify; verdict `drafts/_v18-fun-verify-verdict-20260820.md`).

Execution is OWNER-PACED (both peers' calendar reality). Staging
commits nothing about when the sessions run.

> **DO NOT READ §9 (frozen questions) if you are Gabriel or Junior.**
> The questions are administered one-by-one at capture time by each
> seat's dev. Reading them early weakens the instrument (the
> foundation's own law: "the owners never see questions early").
> Everything else in this spec is open to both peers.

---

## 1. Feel thesis — what CUMPLIDO means (foundation point 1, verbatim transcription)

Both players, independently: growth was FELT (stronger than at v19
open; kills mattered beyond the moment) · boss-reach gap closed
honestly (attainable-hard, not wall-hard) · session-open is not a
chore · the third body stopped being a lemming · free verdict, always.

Adjudication mapping (pre-registered): growth-felt, difficulty-arc,
third-body each have their own question topic (§7). "Session-open is
not a chore" has NO question of its own — it reads from the
across-days answers (v18 precedent: session-open friction poured into
exactly that answer), the free verdicts, HELD material, and the
persist/economy bytes at session opens (mercy-floor context:
`economy.json regrow_cost=12`, `mercy_floor_spend_pct=100`).

**CUMPLIDO clause arithmetic (pre-registered — review-gate fix B/M2,
never re-litigated at adjudication):** the five thesis clauses do not
all block. BLOCKING clauses: growth-felt (K3) and — as the inherited
floor — across-days continuity (K4). ROUTED-DEBT clauses: boss-reach,
third-body, session-open — a fired negative row (R-D1/R-T1/R-SO)
means that clause is NOT MET; the verdict must carry it IN ITS
HEADLINE as a named debt with its routed lane, and the close is then
"CUMPLIDO with named debts" (v18 precedent: closed with balance as
the loudest recorded item). This split is the foundation's own
design: the C3 stance-verb rung exists exactly for "the ritual says
C2 insufficient" — the foundation anticipates the ritual REPORTING a
failed third-body clause without voiding the cycle.

## 2. Preconditions (all satisfied at staging — verified this session)

- ALL sim numbers the ritual measures are in and stable: respawn
  `coop.json respawn_delay_scale=3.0` (s79) · difficulty
  `human_hp_scale=1.25` + `tiers.json` zone tiers (s68) · sustain
  economy (R-A2 shipped s40-era, reasons{} instrumented) · ally
  `ally_flee_hp_pct=0.5` + defensive-default engage (s80) ·
  progression `progression.json` (k=40, cap 10, kill_xp table).
- J-6 non-pausing menu SHIPPED (s53–56) — the runsheet-freeze
  precondition of foundation Lane 4. Quit = Esc → menu → SALIR/SAIR
  (clean quit, `reason=quit`).
- All four lanes have first ships (s81 close note: sequence-unblocked).

## 3. Novelty quarantine — exposure ledger + requirement (foundation point 3 + adoption A-ii)

**Ledger of player-visible surfaces shipped since each seat's last
ordinary session (both seats last played 2026-08-24: coop S1 + owner
solo s67):**

| Ship | Surface class |
|---|---|
| s68 difficulty tiers + `requires_level` deep gates | sim-feel + gate refusals |
| s69 basement_1/2 + dungeon_1 interior fill | world content |
| s70 zone_8 wire-in (rope way, level-8 gate) | world content |
| s71 safe-zone law (hub sanctuary, refusal teeth) | sim-feel + cues |
| s72 B1-T2 visible boundary + SAFE chip · shake −50% | visual |
| s74 J-3 STATS panel (menu row) | visual/UI |
| s75 refusal-cue cream-on-chip · economy-numeral halo | visual |
| s77 five uiux deltas (breach anchor · strip labels · downed-bar hairline · nameplate halo · glyph outlines) | visual |
| s79 respawn 3.0 · s80 C2 defensive-default + flee 0.5 | sim-feel (measured objects — exposure rides along) |

**Requirement (checkable):** each seat gets ≥1 ORDINARY play session
on a build at or past the s82 STAGING COMMIT (the commit that lands
this spec — hash recorded in the s82 checkpoint entry and the
skeleton; one floor, both documents) BEFORE
ritual session 1. Recommended vehicle: **coop part 2** — one session
exposes both seats at once, the handshake mechanically proves build
identity, and it pays the standing focus-A/B item; the owner-pending
audio-v12 ear-check may ride it (owner-initiated audio lane, never
bundled with ritual questions — v18 links #5/#6 precedent). Solo
exposure per seat is equally legal (launcher-log date + that
machine's checked-out commit). Solo-exposure evidence is honestly
WEAKER than the coop handshake: a solo launcher log carries no build
identity (fingerprints live only in the netplay hello), so the
machine's `git rev-parse HEAD` is recorded into the skeleton at
exposure time, dev-attested — named as the weaker form.

- Same-calendar-day exposure + ritual session 1: LEGAL, but named
  beside the warmth readings (novelty barely faded).
- Residual contextual novelty is un-eliminable (A-ii, standing law):
  **novelty discounts WARMTH, never CORRECTIONS.**
- Any NEW player-visible surface shipped after this staging extends
  this ledger and owes its own pre-ritual exposure — prefer shipping
  none until the verdict (owner override = law, recorded).

## 4. The two sessions (foundation points 2 + 4 + adoption A-i)

1. Two COOP sessions on the SHARED save (`saves/world.json`,
   host-authoritative). Owner hosts (`bin\host-coop.cmd`), Junior
   joins (`bin\join-coop.cmd`). `git pull` both seats before each
   session (handshake refuses stale builds and names the field).
2. Each ritual session is DECLARED in chat before launch ("ritual
   session 1/2"). Ordinary play between sessions stays legal — it
   advances the world and its logs join the chain (v18 F4 law).
3. Each session ≥ 36000 ticks (10 sim-min; historical sessions ran
   2–7× that) and ends by the menu quit (Esc → SALIR/SAIR). Only a
   clean quit saves the world.
4. **DIFFERENT calendar days — HARD rule** (fixes v18 caveat 1).
   Clock law (pre-declared): a session's date = the HOST machine's
   local calendar date **at session LAUNCH**, read from the ORIGINAL
   launcher-log file's creation time (the log body's first line
   carries no timestamp — verified; md5-banked COPIES do not preserve
   ctime, so the date is recorded verbatim into the skeleton AT
   BANKING, corroborated by the chat declaration timestamps — a
   midnight-straddling session keeps its launch date; council-pass +
   review-gate fix, s82). The CR clock decides;
   Junior's BR dates are recorded beside but never decide (CR/BR
   timezones differ by 3h — one clock or the rule is ambiguous).
   Owner compression to same-day
   = re-buying the v18 caveat, must be RECORDED IN CHAT BEFORE the
   sessions, and it forfeits the across-days reading (K2 §10 does not
   fire only because the compression was pre-recorded; the across-days
   topic then reads WEAKENED exactly as v18's did).
5. The day-gap check LICENSES the across-days question; it never
   itself proves continuity — Half A is the precondition, Half B is
   the proof (A-i, verbatim law).
6. Ritual launches use the standard launchers with NO env extras
   (no `GAME_BUNDLE_DUMP`, no probes) — the instrument runs the
   plain game.

## 5. Half A — PERSISTED + PROGRESSED (mechanical; from banked bytes only)

Harvest BEFORE any question: all four `TELEMETRY netplay` lines
(2 sessions × 2 seats), every `TELEMETRY persist` line, every
`TELEMETRY progression` line, every `TELEMETRY sustain` line, both
hosting consoles where the launch path produced them (A6 —
`bin\host-coop.cmd` produces none; consoles are corroboration, never
required). Launcher logs: `%TEMP%\game_two_session_*.log` /
`/tmp/game_two_session_*.log` — save the FILES (md5-banked copies in
the skeleton's evidence dir).

| # | Check | PASS condition (byte-exact) |
|---|---|---|
| A1 | Host digest chain | session 2's `persist loaded digest=` == the latest prior `persist saved digest=` in mtime order, with NO launcher log in the gap unaccounted |
| A2 | Joiner entered the host's world | joiner `loaded … source=handshake` digest == host `loaded … source=file` digest, BOTH sessions |
| A3 | Clean lockstep, real length | all 4 netplay lines: `desyncs=0` + `reason=quit`; ticks ≥ 36000 each session; `grep -c AUTOPILOT` = 0 in every ritual file |
| A4 | Day gap (HARD) | host-clock calendar dates **at launch** (original-file ctime, recorded at banking) of session 1 and session 2 DIFFER (unless a pre-recorded owner compression exists — then named, across-days reading forfeited) |
| A5 | Progression: state AND flow (A-iv) | see ladder below |
| A6 | Separate launches | two distinct launcher session logs (one per launch by construction), mtime-ordered, `sessions` counter +1 per session; hosting-console tees banked IF the launch path produced them (dev-launched sessions tee to tmp/; `bin\host-coop.cmd` does not tee — consoles are corroboration, never required); per-session tick counts recorded, gross session-length imbalance NAMED beside the reading (not a fail condition) |

**A5 — the level+kill-XP byte proof (pre-registered semantics; the
baseline is the CYCLE's start, not the ritual's):**

The thesis pairs "stronger than at v19 OPEN" (state) with "kills
mattered beyond the moment" (flow) — A-iv's "level above start" reads
against the cycle baseline: progression shipped injecting `{level 1,
xp 0}` into pre-progression saves (`save_store.rb` strict-decode
seam). A ritual-window reading (level must move BETWEEN ritual
sessions) was considered and REJECTED at staging (council pass, s82):
it would make Half A a dice roll on where the XP curve sits at ritual
open (reaching level N costs `ΔE(N) = 40·(N²−3N+4)`: ΔE(9)=2320 ·
ΔE(10)=2960, cap 10), measuring the CURVE, not the cycle.

- **State (all three from bytes):** (a) pack level > 1 at session 1
  open AND session 2 close (save decodes + `TELEMETRY progression`
  lines) — accumulated growth is real and persisted; (b) the
  progression facts CARRIED: session 2's opening `{level, xp}` == the
  LATEST PRIOR close's values in the chain, mtime-ordered with no log
  unaccounted (same form as A1 — review-gate fix B2: ordinary play
  between the ritual sessions is legal and legitimately moves these
  values; the check is chain-continuity of the progression facts,
  never s1==s2 identity); (c) any level
  REGRESSION across any chain boundary = a K1-class persistence
  failure.
  At `level_cap` (10) the state reads trivially true and the xp-pin
  (`award` pins xp at ceiling−1) is named — noted, no special case
  needed under the cycle-baseline reading.
- **Flow (required, both sessions):** `TELEMETRY progression …
  kills_xp=N` with N > 0 in each session's close lines. `kills_xp`
  is session-scoped by construction (`progression.rb` zeroes it per
  launch; the save carries only `{level, xp}`) — it is the
  in-session XP-flow proof. kills_xp=0 in a ≥36000-tick coop session
  means the measured system was not exercised → that session RE-RUNS
  (shortfall class, §11).
- **Named beside the reading (never a check):** whether a level
  boundary was crossed INSIDE the ritual window, with the gap
  arithmetic printed (XP needed at ritual open vs earned) — a real
  pacing datum for the growth-felt reading; and any `requires_level`
  gate crossed in-session (a bonus nameable progression fact,
  foundation point 4's second form).

Chain-walk law (v18): every `loaded` must equal a previous `saved` or
be classified (fresh/crash/idle); unexplained save moves are a K1
failure, not a footnote.

## 6. Half B — FELT (administration protocol)

- **Capture-before-debrief (A-iii, admin law):** answers are
  administered after session 2 ends and BEFORE the two players
  debrief each other. Any pre-answer peer contact about the sessions
  is NAMED as a deviation beside the answers. Mid-session
  observations stay welcome — banked as HELD material.
- **Scheduling (review-gate round 2 — the window is bounded, not
  open):** administration triggers AT session-2 close — the hub seat
  administers the owner in that same sitting, and the hub chat pings
  Junior's seat to administer his five in the same window. TARGET:
  all ten answers banked the same day session 2 closes, before the
  peers' next shared conversation about the game. Every hour between
  close and 10/10 is exposure — the schedule exists to shrink it.
- **Contamination reading rule (pre-registered — contamination gets a
  law, not improvisation):** a pre-answer peer contact about the
  sessions discounts the INDEPENDENCE of the later answer, on the
  novelty-law axis (discounts warmth and convergence, never
  corrections). Mechanically: K3 fires on ANY seat, so contamination
  cannot manufacture or spare it; K4 requires BOTH seats
  INDEPENDENTLY — a second "partida nueva" vote given AFTER known
  contact cannot COMPLETE K4 (it downgrades to R-C1, recorded), only
  two pre-contact votes kill. Against-interest content (corrections,
  named pains) keeps full weight in every case.
- Each seat's dev administers its own player's questions, one-by-one
  (v18 owner order "preguntame una por una" is now the default),
  each question pasted BYTE-VIRGIN from §9, in the player's language
  (es-CR / pt-br), zero commentary or changelog between Q and A, no
  reactions, next question only after the previous answer.
- Counter-questions are recorded AS the answer; nothing is explained
  until all TEN answers are banked (v18 quarantine law — the owed
  explanations deliver after 10/10).
- Answers banked VERBATIM in the skeleton — never scored,
  paraphrased, or register-cleaned.
- HELD material (mid-session observations, sustain lines, forensics)
  is admitted only AFTER 10/10 — order is part of the protocol's
  validity.
- The runsheet (`drafts/_v19-eighteenth-runsheet-20260826.md`)
  carries logistics ONLY — the questions deliberately do not appear
  in it (tightened from v18: the owner-facing sheet no longer
  contains what the owner must not rehearse).

## 7. Question topics + seat assignment (foundation point 5; wording in §9)

| Topic | Seat | Instrument lineage |
|---|---|---|
| Across-days continuity | BOTH | v18 P1, now in its designed two-day form (the v18 caveat retirement — this A/B is the load-bearing repeat) |
| Growth-felt (headline) | BOTH | NEW instrument, forced-alternative form on the CYCLE horizon ("desde que empezaron en este mundo" — council fix: change-presupposing form was leading; review-gate fix B1: a ritual-window horizon re-imported the curve dice-roll that A5's baseline fix removed and made "igual" a false K3 at cap) |
| Geography of risk (safe/deep) | Owner | NEW instrument, TWO probes (legibility, then behavior — split at council pass to keep one probe per question) |
| Difficulty arc (boss-reach) | Junior | v18 P2 byte-identical re-ask (his baseline: "um pouco mais melhor mas segue muito dificil chegar no boss") |
| Third-body behavior | Junior | v18 P3 byte-identical re-ask (his baseline: "a IA morre muito, fica correndo pra dentro dos inimigos") |
| Free verdict | BOTH | tradition, byte-identical |

Owner: 5 questions · Junior: 5 — symmetric. Two reviewer objections
were REFUTED at staging and are recorded here so adjudication doesn't
re-litigate them: (1) "terceiro corpo = dev jargon" — kept anyway:
it is v18's byte-identical administered instrument and already
produced a fluent answer; changing it breaks the A/B; (2) "no
explicit boss-reach probe" — deliberate: boss-reach emerged UNPROMPTED
from this exact instrument in v18; naming the boss in the question
would hand Junior his old frame (leading). The arc reads from pt-3's
answer + zones-reached telemetry.
The economy/sustain row is TELEMETRY-ONLY, NO question — the owner's
provisions question is BURNED (v18 verdict row 4: post-8/8
explanation delivered; behavior measures it now).

## 8. Telemetry-only economy row (pre-declared reading)

Read the four ritual `TELEMETRY sustain bought=B used=U refused=R
reasons{…}` lines (HELD until 10/10):

- B=0 AND U=0 on all four → discoverability STILL failed → the
  recorded R-A2 strip ESCALATION (full-wall re-pin, priced — a
  standing owner-word decision) becomes ELIGIBLE; owner word decides.
- Any B>0 or U>0 → the R-A2 bank-hint ship landed; escalation stays
  parked. `reasons{…}` texture recorded either way.
- This row never blocks the close in either direction.

## 9. THE FROZEN QUESTIONS — administered at capture, one-by-one

> **Peers: stop reading. Devs: paste byte-virgin, one at a time.**

**Owner (es-CR), in this order:**

1. Al volver el segundo día, ¿sintieron que retomaban donde habían
   parado, o que era una partida nueva?
2. Comparado con cuando empezaron en este mundo, ¿la fuerza del
   grupo se siente igual o diferente? ¿Por qué?
3. Moviéndose por el mundo, ¿qué tanto se nota dónde es seguro y
   dónde es peligroso?
4. ¿El peligro de las zonas les cambia cómo juegan?
5. Veredicto libre.

**Junior (pt-br), in this order:**

1. No segundo dia, pareceu que vocês tinham voltado pra onde pararam,
   ou que era uma partida nova?
2. Comparado com quando vocês começaram nesse mundo, a força do
   grupo parece a mesma ou diferente? Por quê?
3. Em dupla, como sentiu a dificuldade dessa vez?
4. O terceiro corpo (a IA) — como se comportou?
5. Veredicto livre.

Premise note (pre-registered): if the owner compresses to same-day
(§4.4), each P1 premise amends "el segundo día"/"No segundo dia" →
"al volver a la segunda sesión"/"Na segunda sessão" (v18's authorized
variant), noted beside the answer; the across-days reading is then
forfeited as §4.4 says.

## 10. Routing rows (topic-scoped, A-v) + PRE-DECLARED KILL CONDITIONS

**Kill conditions — these BLOCK the close (NOT-CUMPLIDO), everything
else records:**

- **K1 (mechanical):** A1/A2 chain or handshake mismatch, any desync
  on the four lines, or an unexplained save move → save/netplay
  divergence work item; ritual re-runs after the fix.
- **K2 (day gap):** same host-clock calendar date WITHOUT a
  pre-recorded owner compression → the sessions stand as ordinary
  play; ritual re-runs. (With pre-recorded compression: not a kill;
  across-days reading forfeited, v18 caveat re-bought.)
- **K3 (growth thesis):** ANY seat answers growth-felt negative or
  null ("igual", no felt change, or weaker) → the v19 headline failed
  — the thesis requires BOTH players, independently, to have FELT it
  (council-pass fix, s82: a both-negative bar contradicted the
  ratified wording) → close BLOCKED; routes to progression candidates
  (curve k · kill_xp table · growth pcts · level-up moment
  presentation), then re-ritual. Null gloss (pre-registered): an
  answer with NO affirmative growth content — including a pure
  counter-question or incomprehension, banked as the answer per §6 —
  reads NULL and fires K3 (the v18 P3 precedent: not knowing what the
  topic is IS the topic failing).
- **K4 (continuity regression):** BOTH seats answer "partida nueva /
  partida nova" with a clean chain → the v18 thesis regressed →
  close BLOCKED; session-open/history presentation + persistence
  work item, then re-ritual. K4 completion requires both votes
  INDEPENDENT — §6's contamination rule: a post-contact second vote
  downgrades K4 to R-C1.

**Recorded rows (trigger → pre-registered outcome; none blocks):**

- **R-G1 (growth felt but hedged/qualified — "diferente, pero apenas"
  / growth named weaker than hoped; or the ritual window crossed no
  level boundary per A5's named arithmetic):** progression-pacing
  candidate RECORDED (k=40 curve height at L8–10 · kill_xp table ·
  dmg/hp growth pcts · level-up feedback juice) — post-verdict, owner
  priority, ONE knob per re-session.
- **R-G2 (growth felt but "only numbers"):** level-up moment
  legibility candidate (presentation lane), recorded.
- **R-D1 (Junior: still too hard to reach the boss):** difficulty
  candidates recorded (tiers.json zone pcts · coop `human_hp_scale` ·
  boss-approach design), read WITH the session telemetry (zones
  actually reached); ONE knob per re-session.
- **R-D2 (Junior: too easy now):** reverse tier candidate, recorded.
- **R-T1 (third body still suicides/lemmings):** C2 judged
  INSUFFICIENT → the C3 stance-verb rung UNLOCKS (the foundation's
  own later-rung trigger) + `ally_flee_hp_pct`/engage co-tune
  candidate; its own re-session.
- **R-T2 (third body now too passive / won't help):** the OTHER
  direction of C2 — engage-rule scope retune candidate (provocation
  breadth), recorded.
- **R-GEO1 (owner can't tell safe from dangerous — es-3 reads
  illegible):** B1 boundary legibility follow-up — folds into the
  standing owner-paced B1-T3 feel item, recorded.
- **R-GEO2 (legible but inert or resented — es-4 reads "no cambia
  nada" or "safe zones make it boring/pointless"):**
  sanctuary-scope design debate, recorded, never auto-built.
- **R-SO (session-open named a chore again — in P1s, free verdicts,
  or HELD):** B4 mercy-floor revisit (context gate / spend pct),
  data-only candidate, recorded.
- **R-C1 (ONE seat "partida nueva"):** session-open summary/history
  surface candidate (v18 row-2 lineage + the council's deferred
  "world shows elapsed time" note rides here), recorded.
- **R-E (economy):** §8's pre-declared reading.
- Free-verdict signals with no row: brainstorm inputs with evidence
  attached — **no rows invented, no rows softened** (v18 law).

## 11. Shortfall law (v18, carried verbatim in substance)

A session under 36000 ticks, a non-quit `reason=`, a lost log, an
AUTOPILOT line, or kills_xp=0 is NOT a routing failure — that session
RE-RUNS, owner-paced. Never waive a check, never fudge a pass. A
crash = unclean attempt (`loaded` without `saved`), world unmoved,
named, re-run (v18 crash-night precedent).

**Link-quality shortfall (pre-declared, review-gate addition — the
v18 lag lesson):** if any seat's netplay line shows stalls ≥ 14% of
ticks OR `stall_ms_max` ≥ 2500 (calibrated on the two points we own:
v18 s1 host 13.2%/1113ms was played through and enjoyed; v18 s2 host
14.9%/3341ms was quit as unplayable), the peers MAY declare that
session a link-shortfall re-run — **only BEFORE any question is
administered**. Once answers begin, the session STANDS and the stall
profile becomes a NAMED confound quoted beside every Half-B reading
(it never waives a kill condition — the caveat law: confounds
discount warmth, never corrections).

## 12. Hygiene — ARMED from the staging commit until the verdict

1. **Ritual questions virgin:** §9 unread by peers, unrehearsed, no
   topic coaching in either direction.
2. **Frozen instruments:** this spec §9 · the runsheet · docs/JUNIOR.md
   — byte-frozen at the staging commit (git blob md5s recorded in the
   s82 checkpoint entry; the skeleton re-verifies at execution open).
3. **Frozen oracle wording:** `src/app/save_store.rb` persist_line
   vocabulary · `src/game/save_state.rb` (SCHEMA · `digest` ·
   `canonical_bytes` — the arbiter behind every digest compare;
   review-gate fix M1) · the netplay close line
   (`src/net/session.rb`) · the
   whole `src/game/telemetry.rb` close-summary wording (progression +
   sustain lines included) · the AUTOPILOT marker
   (`src/app/autopilot.rb`). No edits, INCLUDING
   add-only extensions, until the verdict (v18's reasons{} extension
   landed post-verdict — that is the pattern).
4. **Frozen sim numbers (the measured set):** `data/balance/coop.json`
   · `progression.json` · `tiers.json` · `economy.json` ·
   `combat.json` (stats + respawn_frames) · `threat.json` ·
   `death.json` (corpse/wipe cadence — the death-recovery loop the
   difficulty and session-open readings touch; review-gate round 2) ·
   zone `requires_level`/`requires_defeats` values. The third-body
   measured BEHAVIOR also freezes at the CODE seams (review-gate
   round 2): `src/game/creature.rb` provocation state ·
   `src/game/aggro.rb` acquisition — no mid-window edits absent a
   recorded owner order. Untouched until the
   verdict. Owner override stays law — recorded in one line, and its
   measurement consequence named at adjudication.
5. **Bot logs are never fun-evidence** (soak stays legal; a `--bot`
   seat still refuses a save-owning launch without `--save`).
6. **Legal during the window:** E3a T1–T3 (fenced off live play; T3's
   netplay-gate re-runs are harness-only) · J-5 spike (throwaway
   worktree) · soak/flywheel (bot law) · docs — PROVIDED rules 3–4
   files stay untouched. Player-visible visual/audio ships are
   DISCOURAGED (each extends the exposure ledger, §3) and stay under
   the usual Rule 2 gates if the owner orders one.
7. **Verbatim means verbatim:** answers, owner orders, and deviations
   bank uncut.

## 13. Adjudication

Runs in a FRESH session (never the session that administered
questions), on this spec's closed terms only: Half-A table quoted
from banked bytes → caveats attach BEFORE the reading → ten answers
verbatim → HELD material admitted → every routing row walked
(triggered or not, no row invented) → kill conditions checked first →
free verdict, always. Pre-registered reading law (named at staging,
not discovered later): the two sessions are SERIALLY DEPENDENT by
design — session 2 inherits session 1's world because persistence is
the object; Half B is therefore a verdict on the CYCLE as a felt
whole, never two independent samples (per-feature independence was
explicitly rejected at the shape council pass). Verdict doc:
`drafts/_v19-fun-verify-verdict-<date>.md`. The evidence bank +
anchors live in `drafts/_v19-fun-verify-skeleton-20260826.md` (the
skeleton opens with staging baselines; execution re-verifies them at
session-1 launch).

What the verdict unlocks on CUMPLIDO: the frozen sim numbers (§12.4)
become tunable again; triggered rows enter the owners' priority
queue; v19 closes on the foundation's terms. On NOT-CUMPLIDO: the
kill condition's pre-registered route executes, then re-ritual.
