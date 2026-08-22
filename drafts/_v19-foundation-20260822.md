# v19 FOUNDATION — brainstorm 2026-08-22 (session 39)

**Status: CLOSED — DOUBLE-RATIFIED 2026-08-22.** Facilitated by the
dev of record; Gabriel live; Junior async (2026-08-22 order:
development never gates on peer availability). Every decision carries
RATIFIED-G (Gabriel, live 2026-08-22) and RATIFIED-J (Junior, same
day, verbatim "ratifico tudo" — all 28 rows, zero objections:
`drafts/_junior-ratificacao-v19-20260822.md`, commit `cbda479`).
Both marks in ⇒ the AGENTS cycle-section rewrite UNLOCKED (landed
s40). RATIFIED-J marks below were flipped mechanically at s40 from
the one "ratifico tudo" line — per-row verbatims are Gabriel's.

Inputs (all verified live at session open): agenda
`drafts/_v19-intake-docket-20260820.md` · prep
`drafts/_v19-brainstorm-prep-20260821.md` · ideas
`drafts/_junior-v19-ideas-20260819.md` · template
`drafts/_v18-foundation-20260817.md` · carried caveats
`drafts/_v18-fun-verify-verdict-20260820.md` (same-day spacing ·
symmetric audio novelty; triggered rows 3/6/9 are inputs here).

Job 0 (session 39 open): git up to date, no Junior commits ·
`saves/world.json` md5 `98fe75edb6d72deab18cd48eaa88bdaf` mtime
2026-08-20 15:51 (unmoved) · launcher logs 40, newest 2026-08-21
01:39 (unmoved) · seat-mail inbox EMPTY (assets RECEIPT still
pending). Zero deltas; nothing preempts.

## Vision line (the owners')

> "v18 made the world persist; v19 makes the characters grow into it —
> power you can feel accumulating, a world with a real geography of
> risk, allies that fight sensibly, a client that feels like a real
> game."

BLESSED by Gabriel live 2026-08-22 (verbatim: "I bless it, and ratify
the shape, but first request /council-consult on it for any insights,
recommendations, gaps, things we are missing or overlooking, etc") —
RATIFIED-G · RATIFIED-J.

## Lanes (ratified one candidate at a time)

### Lane 1 — PROGRESSION v1 (THE v19 headline) — RATIFIED-G 2026-08-22 · RATIFIED-J

**Owner verdict (verbatim, Gabriel, live): "proceed as you recommend"** —
ratifies the lane commit AND forks A1/A2/A3 as recommended.

Source: J-4 (ideas doc idea 4 + addendum + lobber extension `38a3ddb`);
answers the v18 verdict's shared correction (balance / "segue muito
dificil chegar no boss") and the owner's "more firepower/damage" vote.
Shelf: `rpg-xp-curves-and-leveling-formulas` ·
`death-penalties-stat-scaling-and-progression-balance` §6 ·
`damage-elements-and-combat-math` §6 (mechanism shapes only; FLAGGED
numbers re-verify before landing in data/).

**Staging:**
1. Grill/spec: XP curve pick + damage-formula stack + save schema v2
   (progression facts; schema-version bump rides the existing
   handshake-refusal law). Round-trip test lane FIRST (v17 digest-lane
   precedent).
2. Sim core: XP-on-kill → PACK-level → stats read by the new
   damage/HP formula (inside lockstep; digest covers determinism).
3. Presentation: XP/level surface (HUD) — NEW visual surface, own wall
   script + blocking Rule 2 gate; level-up moment is a feel beat
   (juice wall applies).
4. Per-spell growth hook, lobber E first — volley range
   `impact_distances` growth is data-shaped today; kit power-curve
   positioning (lobber = mid/late bloomer) recorded from the owner's
   es-CR extension.
5. Level-gated world: `requires_level` beside `requires_defeats`
   (same fact-gated transition shape, machinery shipped); gates
   authored via the WB lane where the world needs them.

**Gates owed:** suite via hooks · Rule 2 + wall for every new visible
surface · round-trip lane extension (schema v2) · `rake perf` (stat
formula sits in the hot path) · netplay gates untouched-green.

**world.rb extraction flag: OWED** — XP award + progression facts
touch `world.rb` at the 1,800 cap; extraction into a plain object
(Progression) per the Crossing precedent, s31.

### Lane 2 — WORLD GEOGRAPHY & ECONOMY (one lane, five rows) — RATIFIED-G 2026-08-22 · RATIFIED-J

**Owner verdict (verbatim, Gabriel, live): "approved as recommended,
proceed"** — ratifies the lane AND positions B1–B5 as recommended.

Source rows: J-2 (ideas doc idea 2) · finding B (`drafts/_junior-solo-
playtest-findings-20260820.md` ACHADO 2) · TOWN 1 v0 (`drafts/_junior-
primeira-travessia-20260821.md`) · verdict rows 9 (R-A4) + 3 (R-A1).
Shelf: `world-events-towns-and-folklore-mechanics` (radial danger
gradient — "safety at the depot tile"; VERIFIED Tibia presence-block
respawn + WoW population-threshold) · `tibia-mechanics-…` (protection
zones) · `mmo-economy-design-sinks-and-faucets` (vendor-anchor/hub
law) · `permadeath-systems-comparison` (carry-risk vs walk-back axis).

**Positions (all ratified under the one verdict line):**
- **B1 safe zones:** `safe: true` zone attribute (data-driven, sibling
  of `hub:`); v19 half = enemies never pursue/damage inside; PvP
  combat-lock half RECORDED for the >2-players future. Coverage: BOTH
  hubs (zone_7 + camp). Boundary made VISIBLE (unmarked safe borders =
  readability defect) — Rule 2 surface. Camp feel change acknowledged
  (soak fights=4) — own capture + playtest before ship.
- **B2 finding B:** no-bank-in-deep KEPT as design (interpretation a —
  walk-back/carry-risk IS the loop); geography answers the complaint:
  TOWN 1 = the deep-side anchor.
- **B3 TOWN 1 v1:** revive/vat station + existing bank + a
  progression-anchor slot (braids with Lane 1); authored via the
  shipped WB pipeline.
- **B4 mercy floor (R-A4):** context-gated per the owner's own hedge —
  session-open first regrow at the HOME hub guaranteed affordable
  (floor/discount); field/dungeon revival stays full-priced. Data-only
  (`economy.json`).
- **B5 respawn (R-A1):** stage 1 = ONE `coop.json` scalar + data-only
  re-session (pre-registered shape); presence-block respawn RECORDED
  as the stage-2 structural candidate if the scalar doesn't kill the
  complaint.
- **Stage 0 (already-recorded, rides first):** R-A2 sustain
  discoverability build — strings + renderer, Rule 2 + wall; price
  debate stays parked behind it (row 4's recorded order).

**Sequencing law (carried from the verdict):** ONE knob per
re-session; ALL Lane 2 data moves land BEFORE the v19 ritual stages
(the ritual re-freezes what it measures).

**Gates owed:** Rule 2 + wall for the safe-boundary visual and the
sustain-exposure surfaces · suite via hooks · zone-authoring through
the strict importer (WB laws) · data-only re-sessions per knob.

### Lane 3 — LIVING WORLD & AI (J-7 · finding A · row 6) — RATIFIED-G 2026-08-22 · RATIFIED-J

**Owner verdict (verbatim, Gabriel, live): "approved as recommended,
proceed"** — ratifies the lane AND C1/C2/C3 as recommended.

Source rows: J-7 (ideas doc idea 7, owner mid-ritual verbatim) ·
finding A (mechanism CONFIRMED `9a7dd98`: one AiController all
factions, controllers.rb:100) · verdict row 6 (R-A3, Junior R3
verbatim). Shelf: `living-world-simulation-and-npc-schedules`
(hot/warm/cold LOD; "timestamp on last-player-exit; on re-entry run
one catch-up function"). **Companion/ally AI = NAMED SHELF GAP — no
curated note exists; research debt RECORDED (C3).**

**Positions:**
- **C1 — J-7 = cold-tier catch-up, NOT background ticking.** Stamp
  tick on pack-leave; on re-entry advance walkers along their home
  path by elapsed ticks (one deterministic function, O(walkers), at
  transition — zero per-tick cost). Full living-sim ticking REFUSED
  this cycle on the perf prior (44 tps stall with one zone); recorded
  as a future rung.
- **C2 — ally engage rule: defensive default.** Ally acquisition
  gates on PROVOCATION (what attacks the pack / what the possessed
  engages), leash back to the possessed; `ally_flee_hp_pct` co-tuned
  beside it. One re-session measures it (Junior = primary witness).
- **C3 — stance verb (passive/defensive/aggressive): staged LATER
  rung, not v19-core.** Builds only if C2 proves insufficient in
  play. Research spoke (banking-only, bounded, one pass) dispatches
  on owner word when C3's spec approaches — debt recorded today,
  spoke NOT dispatched.

**Sequencing:** C2 lands after B5's re-session (separate knobs); C1
independent (different surface); all before the ritual stages.

**Gates owed:** suite via hooks · netplay gates re-run (catch-up +
engage rules are lockstep sim surface) · `rake perf` (transition-time
catch-up stays off the hot path) · re-session per sim change.

**world.rb extraction flag: LIKELY OWED** — zone-leave stamps +
catch-up touch world.rb at cap; extraction (e.g. ZoneClock/Homecoming
object) per the Crossing precedent if the touch is material.

### Lane 4 — PRESENTATION & LEGIBILITY (J-6 · J-3 · J-5 + fork family) — RATIFIED-G 2026-08-22 · RATIFIED-J

**Owner verdict (verbatim, Gabriel, live): "approved as recommended,
proceed"** — ratifies the lane, the J-3 scope fence, the J-5 spike
class, and fork classes D1/D2.

Source rows: J-6 (ideas doc idea 6, owner es-CR verbatim) · J-3 (idea
3 + banked CryoFall ref) · J-5 (idea 5 + banked refs) · forks
`c835c67` (projectile-visual sync) + lobber pass-through (finding doc
§ACHADO NOVO; projectile.rb:73 mechanism read). Shelf:
`game-ui-ux-patterns` (menu taxonomy + juice feedback) ·
`game-development-lifecycle-…` (juice checklist, priority order) ·
`warhaven-melee-combat-audit` (legibility failure stakes) ·
`technical-drawing-for-game-art` §2 + `classic-2d-mmo-terrain-…`
(projection vocabulary).

**Staging:**
1. **J-6 non-pausing menu (core):** StateStack state over a
   still-ticking world (death with menu open is possible; netplay-safe
   — idle input frames keep flowing) · per-bus volume + quick mute ·
   window scale presets + fullscreen · runtime locale switch · quit =
   existing clean-quit path + partner courtesy notice · link-status +
   session-ledger panels · read-only controls sheet (rebind stays
   parked). CLIENT PREFS in their own file — never the world save
   (save-stays-facts-only). Runtime bus-gain may need a small
   audio-lib API → mail the audio seat at spec time. **Sequencing law:
   ships BEFORE the v19 ritual runsheet freezes** (runsheet gets
   authored against the real Esc/quit path).
2. **J-3 as STATS PANEL v0:** Lane 1's presentation surface in the
   CryoFall register — stats/XP/level/spell-growth ONLY. Scope fence:
   inventory grid + paper-doll stay PARKED with the items cycle; the
   asset style signal stays routed to the assets seat.
3. **J-5 projection spike, owner-paced:** ONE throwaway worktree
   session — same replay captured flat · 3/4 · true iso, side by side;
   owner eyes pick; ADOPTION is a separate later decision. No gate
   owed (nothing ships). Combat-clean law non-negotiable in any
   register.
4. **Legibility family builds (from D1/D2):** lobber impact-tile
   telegraph + throw-sync visual alignment + the recorded E-skill
   telegraph candidate — renderer-only, each Rule-2-gated with wall
   debt.

**Gates owed:** Rule 2 + wall per new visible surface (menu, stats
panel, telegraphs) · suite via hooks · netplay gates untouched-green
(menu emits idle frames) · `window.rb` ≤ 300 cap — menu lives as its
own state module on the bus, never in the orchestrator.

## Forks closed (verdict verbatim per fork)

- **A1 — XP-levels vs skill-through-use:** XP-LEVELS for v19;
  skill-through-use PARKED (needs per-verb telemetry + a balance
  surface that doesn't exist; the owners' named touchstones (WoW/TES)
  are level-based; Tibia's model recorded as a future evolution).
  Verdict: "proceed as you recommend" — RATIFIED-G · RATIFIED-J.
- **A2 — progression carrier:** THE PACK (one carrier; the player IS
  the pack under Tab-possession — per-body leveling would punish the
  possession mechanic). Same verdict line — RATIFIED-G · RATIFIED-J.
- **A3 — death × XP:** death does NOT eat XP in v19 — failure stays
  priced in supplies + time (regrow fee, walk-back), per the recorded
  corpus line (rows R-A1/R-A4); mark stays carried-value insurance.
  Tibia-hard XP-loss RECORDED as a future valve if power outgrows the
  world. Same verdict line — RATIFIED-G · RATIFIED-J.
- **B1 — camp goes safe?:** YES — both hubs carry `safe: true`;
  boundary visible, Rule-2-gated; camp feel change gets its own
  capture + playtest. Verdict: "approved as recommended, proceed" —
  RATIFIED-G · RATIFIED-J.
- **B2 — deep-zone banking:** REFUSED as mechanic — no-bank-in-deep
  stays design; TOWN 1 anchors the deep side. Same verdict line —
  RATIFIED-G · RATIFIED-J.
- **B4 — mercy shape:** context-gated home-hub session-open floor,
  field stays priced. Same verdict line — RATIFIED-G · RATIFIED-J.
- **B5 — respawn fix shape:** scalar first, presence-block recorded as
  stage 2. Same verdict line — RATIFIED-G · RATIFIED-J.
- **C1 — J-7 walk-home shape:** cold-tier catch-up at re-entry;
  background zone-ticking REFUSED this cycle (perf prior). Verdict:
  "approved as recommended, proceed" — RATIFIED-G · RATIFIED-J.
- **C2 — ally engage rule:** defensive default (provocation-gated
  acquisition + leash + flee co-tune). Same verdict line — RATIFIED-G
  · RATIFIED-J.
- **C3 — stance verb:** later rung; shelf-gap research debt recorded,
  banking-only spoke on owner word at spec time — not dispatched at
  the brainstorm. Same verdict line — RATIFIED-G · RATIFIED-J.
- **D1 — projectile-visual sync (`c835c67`): class = PRESENTATION-
  ONLY.** Visual timing aligns to throw audio/impact; sim cadence
  change REFUSED (wrong layer for a legibility complaint). Verdict:
  "approved as recommended, proceed" — RATIFIED-G · RATIFIED-J.
- **D2 — lobber pass-through: class = PRESENTATION-FIRST.** Impact-
  tile telegraph ships (legibility family); sim hit-test change
  REFUSED this cycle unless the telegraph proves the hit-test itself
  wrong — evidence-gated, routed into Lane 1's combat-math grill.
  Same verdict line — RATIFIED-G · RATIFIED-J.

## Riders (accepted / routed)

- **E3(a) assets capture-contract: ACCEPTED — `queued-for-v19-intake`.**
  Owner verdict (verbatim, Gabriel, live, 2026-08-22): "yes please!
  Anything that benefit our development process, please go for it.
  Remember we also have a full AWS account with all sorts of services
  and cost is not a concern (quality over cost), we can leverange
  anything you recommend from our tech stack, including the research I
  am running on the /knowledge workspace as we speak, about something
  called 'WorldClaw' (more details soon!)" — RATIFIED-G · RATIFIED-J.
  Build shape: session-end recording bundle (commit + seed +
  preconditions + per-tick consumed masks + digest window; from the
  already-retained lockstep queues) + offline state-track re-execution
  on the existing replay runner. FENCE (rides the receipt): recording
  at session end only, never during play, zero per-tick cost on either
  seat. Sequenced after the four lanes' first ships. Doubles as OUR
  desync-forensics black box. RECEIPT mail to the assets seat
  dispatches in s40 (`RECEIPT: capture-contract = queued-for-v19-intake`).

## Owner notes recorded at the brainstorm (2026-08-22)

- Dev-process tooling posture (from the E3(a) verdict line): tooling
  that benefits the development process is welcome by default; quality
  over cost (matches standing global law). Full AWS account available;
  cost not a concern.
- **WorldClaw:** owner is running research in the /knowledge workspace
  — "more details soon". Provenance update (same morning): the source
  is a YouTube video JUNIOR sent Gabriel (Junior via WhatsApp, relayed
  verbatim by the owner: "¡Qué tuanis que el YouTube que te mandé pueda
  aportar algo al proyecto, mae!"). Name update (owner, same session):
  the inspired tool will be called **WorldSmith** ("you can imagine
  where I am going with it"). Post-close update (same chat,
  2026-08-22): Gabriel is AUTHORING the WorldSmith proposal himself
  (his WorldClaw ingestion done in /knowledge); repo to be shared
  soon; initial aim stated by the owner: "começar com 2D para o
  game-two". Junior's task 2 accordingly SHRUNK to a short discovery
  note (video link + 5-10 lines of his own reading — provenance stays
  his); the research half is Gabriel's. Still an INCOMING input for
  this repo — nothing built here until the proposal lands.
- **Junior task request (via WhatsApp, relayed by Gabriel 2026-08-22
  8:57 a.m., verbatim):** "A lo que me refería es a que le mandés a tu
  Claude Code(Mega brain) que traiga tareas para mi PC, para optimizar
  la codificación de las actualizaciones. … 'Mandale algunas tareas
  livianas a la PC de Júnior(🔴power ranger) con el fin de optimizar
  el servicio, si hace falta'. Por ahora no estoy haciendo nada, pura
  vida, solo estoy alineando las copys que se van a entregar." — REAL
  peer work request, answered same session: task 1 = the async
  ratification pass (flips RATIFIED-J marks; the 2026-08-22 order's
  exact mechanism), task 2 = WorldClaw intake write-up (he is the
  discoverer — provenance belongs to him), optional = solo play (human
  logs always bank). NO lane code dispatched to his seat before his
  own ratification lands — building on unratified ground is the
  refusal reason, recorded here.

## Parked / refused (one-line reasons)

- **E1 debug/mod menu → GM/admin-tool family: VALIDATED as direction,
  DEFERRED (not a v19 lane).** Owner verdict (verbatim, Gabriel, live,
  2026-08-22): "yes I agree we will need that system at some point,
  admins and game masters usually use those type of tools, including
  being able to teleport to any part of the map, unstuck players,
  reposition assets, etc. So I agree we need it, maybe now is too soon
  since there is not much to explore yet but we will get there" —
  RATIFIED-G · RATIFIED-J. Effect: the docket's "awaits Gabriel's
  validation" RESOLVES — need validated, timing deferred ("too soon,
  not much to explore yet"). No phase builds in v19 by default. When
  the owner calls it: F1 (harness+scratch, zero binary code) → F2
  (pilot keyboard + read-only debug HUD, env-gated, Rule 2 when
  armed) are the named first rungs per
  `drafts/_junior-debug-menu-proposal-20260820.md`; F3 (mutating
  verbs) keeps its guard — post-verdict + explicit owner promotion
  from PARKING_LOT. His GM framing ("reposition assets") joins this
  family with the WB lane's staged "live in-game god-mode editing"
  rung — ONE admin-tool track when called, not two. The evaluation's
  NUNCA list stands as law: no netplay mutation · never widen
  fingerprint EXCLUDED · never touch the real save · no god-branches
  in world.rb.
- **E2 ping remap → EARMARKED FOR CHAT, stays parked.** Owner verdict
  after listening (verbatim, Gabriel, live, 2026-08-22): "that sound
  could be good for a DM chat notification" — RATIFIED-G · RATIFIED-J.
  Effect: the item-pickup remap candidate CLOSES (superseded by the
  owner's re-route); `mui_ping_1200ms` (handoff/audio-v1 + signed
  fixture) is EARMARKED as the chat/DM notification cue and now
  travels WITH the parked in-game-chat item — whose trigger is
  unchanged (>2 players / owners' word; re-vote already recorded).
  NOT a promotion of chat — the parking-lot law stands; no audio work
  dispatched.
- **E3(b) turn-handling gating decision: DEFERRED.** Owner verdict
  (verbatim, Gabriel, live, 2026-08-22): "I agree with you, defer,
  maybe revisit later if needed" — RATIFIED-G · RATIFIED-J. Receipt
  reason (rides s40 mail): game feel stays untouched while asset
  integration is parked; re-decide after the J-5 projection pick,
  against real integration plans. Their own mail: "deferral is
  harmless." Effect assets-side: the settle-bob condition stays
  pending; zero pixels owed; nothing else moves.
- **E4 motif-strip authoring: DORMANT — no v19 work.** Owner verdict
  (verbatim, Gabriel, live, 2026-08-22): "I agree with the reasoning,
  and that is an asset conversation to pick up when it really hits us,
  proceed as you recommend" — RATIFIED-G · RATIFIED-J. The ticket's own
  perf trigger ("only if Junior's numbers stay high") EXPIRED with his
  good re-measure; wake conditions: perf regression on his seat as
  v19 adds zones/actors (perf gate watches), or an explicit owner
  aesthetics call — folded into the asset era, not a placeholder-art
  Rule 2 spend now.
- **E5 audio library increments (depth-aware duck · stereo stems +
  region-acoustics): STAY QUEUED on owner word.** Owner verdict
  (verbatim, Gabriel, live, 2026-08-22): "yeah leave audio queued for
  now, lets focus on the game development itself" — RATIFIED-G ·
  RATIFIED-J. Dispatch-on-evidence stands: duck routes off ear-check
  q3 if "sí"; stems/acoustics on owner word; both build in
  game-two-audio, never here.

## The v19 fun-verify ritual (the EIGHTEENTH — shape ratified; wording at spec)

**Status: shape RATIFIED-G 2026-08-22 · council gap-pass COMPLETE ·
adoptions owner-confirmed (verbatim: "approved as you recommend
optimal") · RATIFIED-J.** Question WORDING is deliberately absent here
and from all chat — it lands frozen at spec time (measurement hygiene;
the owners never see questions early).

1. **Feel thesis (what CUMPLIDO means):** both players, independently:
   growth was FELT (stronger than at v19 open; kills mattered beyond
   the moment) · boss-reach gap closed honestly (attainable-hard, not
   wall-hard) · session-open is not a chore · the third body stopped
   being a lemming · free verdict, always.
2. **Two coop sessions on the shared save, DIFFERENT calendar days —
   HARD rule, mechanically checked from log timestamps** (fixes v18
   caveat 1: same-night spacing left across-days continuity unproven).
   Owner compression = re-buying the caveat, recorded BEFORE sessions.
3. **Novelty quarantine (fixes v18 caveat 2):** no first-exposure
   sensory batch inside ritual sessions — every major new audio/visual
   surface gets ≥1 ordinary play session per seat BEFORE the ritual;
   checkable from logs (AUDIO sha / build fingerprint). Unavoidable
   asymmetry recorded before answers are read.
4. **Half A (mechanical, from banked bytes):** save chain intact both
   sessions · zero desyncs + clean quits + tick floor (36000) · ≥1
   strictly-positive progression fact carried and NAMED (level above
   start / level-gate crossed) · AUTOPILOT-free · day-gap check.
5. **Half B topics (wording at spec, never rehearsed):** growth-felt ·
   difficulty arc · geography of risk (safe/deep) · third-body
   behavior · continuity in its ACROSS-DAYS form (legal — v18 left
   exactly that unproven) · free verdict. One economy row is
   telemetry-only, NO question (the v18 verdict's recorded law: the
   owner's provisions question is burned; behavior measures it now).
6. **Routing rows pre-registered at spec:** every plausible bad answer
   gets its outcome written BEFORE the sessions (v18 discipline
   carried).
7. **Staging:** cycle end, after lanes ship. The moment wording
   freezes, the sim numbers it measures (progression pacing,
   difficulty, respawn, sustain) FREEZE for tuning — which is why
   Lanes 2/3 land their data moves early (recorded in their staging).

### Council pass (2026-08-22, owner-requested; ≤2 calls declared, 2 spent)

DeepSeek V3.2 + Qwen3-next, adversarial briefs; transcripts verbatim in
`drafts/_v19-ritual-council-20260822/` (brief + both JSONs). Neither
model drafted question wording (constraint held). Read-back reconciled
by the dev; owner confirmed: "approved as you recommend optimal".

**ADOPTED (amend the seven points, design-level):**
- **A-i (→point 2):** the day-gap check LICENSES the across-days
  question; it never itself proves continuity — only the answers are
  evidence (Half A = precondition, Half B = proof; stated, not
  implied).
- **A-ii (→point 3):** residual contextual novelty (old assets in new
  situations) is un-eliminable when the cycle ships new systems;
  standing reading rule pre-declared: **novelty discounts WARMTH,
  never CORRECTIONS** (v18's reading formalized as law).
- **A-iii (new admin law):** **capture-before-debrief** — answers are
  administered after session 2 BEFORE the two players debrief each
  other; any pre-answer peer contact about the sessions is NAMED as a
  deviation beside the answers. Mid-session observations stay welcome
  (banked as HELD material, v18 practice).
- **A-iv (→point 4):** progression proven by state AND flow: level
  above start AND kill-XP earned > 0 inside the ritual sessions;
  per-session tick counts recorded, gross session-length imbalance
  named beside the reading (not a fail condition).
- **A-v (→point 6):** routing rows are TOPIC-SCOPED (a growth negative
  routes to progression candidates, never generic "rebalance") and the
  spec PRE-DECLARES its kill conditions — which rows BLOCK the close
  (v18 discipline, explicit).

**REJECTED (reasons on the record):**
- 24h+ comms blackout between the owners (unworkable for two co-owners
  sharing daily life; capture-before-debrief + named deviations is the
  honest version).
- Per-feature A/B variants (wrong instrument — the ritual verifies the
  CYCLE as a felt whole; attribution comes from topic-scoped questions
  + routing rows + telemetry).
- "N=2 is epistemologically invalid" (the two verdicts ARE the
  population; we measure the owners' truth, not generalization).

**Deferred note:** "world shows elapsed time at session-open" → stays
with the recorded v18 row-2 candidate (session-open summary surface),
not a ritual change.

## Settled appendix (skipped rows, one line each)

- J-1 stationary facing: CLOSED 2026-08-21 — shipped `28017d8`, Junior
  re-test "FUNCIONA" (`drafts/_junior-pilot-walk-20260821.md`).
- Lag T4 vsync: ADJUDICATED s26 — REFUTED on the decisive 59 Hz seat;
  flag stays a diagnostic lever.
- Lag ~7% long-frame tail: CLOSED s32 — draw fix `dd8ff40`, re-measure
  verified (`drafts/_junior-remeasure-20260821.md`).
- Basement ambience: ANSWERED — design v0, nil-key silent (T4 rider 8).
- gamesmith R7 rows (T4/T6/T7/T8): evidence on named triggers only —
  none fired at this brainstorm unless a verdict below says otherwise.
- BOSS-1 dread: stays OPEN-FOR-EXPOSURE, zero code — first organic
  exposure banked (`drafts/_junior-primeira-travessia-20260821.md`).

## Ratification ledger

| # | Decision | Gabriel | Junior |
|---|---|---|---|
| 1 | Lane 1 PROGRESSION v1 = v19 headline, staged 1–5 as written | RATIFIED-G ("proceed as you recommend") | RATIFIED-J |
| 2 | Fork A1: XP-levels; skill-through-use parked | RATIFIED-G (same line) | RATIFIED-J |
| 3 | Fork A2: carrier = the pack | RATIFIED-G (same line) | RATIFIED-J |
| 4 | Fork A3: death never eats XP in v19 | RATIFIED-G (same line) | RATIFIED-J |
| 5 | Lane 2 WORLD GEOGRAPHY & ECONOMY committed, staged 0–5 as written | RATIFIED-G ("approved as recommended, proceed") | RATIFIED-J |
| 6 | B1: safe zones = both hubs, visible boundary | RATIFIED-G (same line) | RATIFIED-J |
| 7 | B2: no-bank-in-deep kept as design; TOWN 1 = deep anchor | RATIFIED-G (same line) | RATIFIED-J |
| 8 | B3: TOWN 1 v1 content (revive + progression anchor) | RATIFIED-G (same line) | RATIFIED-J |
| 9 | B4: mercy floor context-gated at home hub, session open | RATIFIED-G (same line) | RATIFIED-J |
| 10 | B5: respawn scalar first; presence-block = stage-2 candidate | RATIFIED-G (same line) | RATIFIED-J |
| 11 | Lane 3 LIVING WORLD & AI committed, staged as written | RATIFIED-G ("approved as recommended, proceed") | RATIFIED-J |
| 12 | C1: J-7 = cold catch-up; background ticking refused this cycle | RATIFIED-G (same line) | RATIFIED-J |
| 13 | C2: ally defensive-default engage rule + flee co-tune | RATIFIED-G (same line) | RATIFIED-J |
| 14 | C3: stance verb = later rung; research debt recorded, spoke on owner word | RATIFIED-G (same line) | RATIFIED-J |
| 15 | Lane 4 PRESENTATION & LEGIBILITY committed, staged as written | RATIFIED-G ("approved as recommended, proceed") | RATIFIED-J |
| 16 | J-3 scoped to STATS PANEL v0; inventory/paper-doll stay parked with items | RATIFIED-G (same line) | RATIFIED-J |
| 17 | J-5 = throwaway spike, owner-paced; adoption is a separate later decision | RATIFIED-G (same line) | RATIFIED-J |
| 18 | Fork D1: presentation-only; sim cadence refused | RATIFIED-G (same line) | RATIFIED-J |
| 19 | Fork D2: presentation-first; sim hit-test evidence-gated | RATIFIED-G (same line) | RATIFIED-J |
| 20 | E1 debug/GM-tool family: need VALIDATED, build DEFERRED ("too soon"); F1/F2 named first rungs on owner call; F3 guard stands | RATIFIED-G (verbatim in Parked section) | RATIFIED-J |
| 21 | E2 ping: earmarked chat-notification cue, travels with parked chat item; pickup-remap candidate closed | RATIFIED-G ("that sound could be good for a DM chat notification") | RATIFIED-J |
| 22 | E3(a) capture-contract = queued-for-v19-intake (fence: session-end only); receipt s40 | RATIFIED-G ("yes please! Anything that benefit our development process…") | RATIFIED-J |
| 23 | E3(b) turn-handling = DEFERRED; revisit after J-5 projection pick if needed | RATIFIED-G ("I agree with you, defer, maybe revisit later if needed") | RATIFIED-J |
| 24 | E4 motif strips = DORMANT; perf trigger expired; asset-era conversation | RATIFIED-G ("that is an asset conversation to pick up when it really hits us") | RATIFIED-J |
| 25 | E5 audio increments stay queued on owner word; focus = game dev | RATIFIED-G ("yeah leave audio queued for now, lets focus on the game development itself") | RATIFIED-J |
| 26 | Vision line blessed as drafted | RATIFIED-G ("I bless it, and ratify the shape…") | RATIFIED-J |
| 27 | Ritual shape (7 points) ratified; council gap-pass owner-requested before freeze | RATIFIED-G (same line) | RATIFIED-J |
| 28 | Council adoptions A-i…A-v + three rejections; ritual shape FROZEN at design level | RATIFIED-G ("approved as you recommend optimal") | RATIFIED-J |
