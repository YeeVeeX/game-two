# Parking lot — ideas go here, never to code

Rule: nothing below starts until the current loop is fun-verified by the owner.
Append freely; promoting an item requires updating the scope contract in AGENTS.md first.

## Parked from Kethral (proven-built once, deliberately not rebuilt yet)

- Procedural dungeon generation
- Branching dialogue / NPC trust / factions
- Status effects, crafting, charms, bestiary, codex
- Weather + time-of-day systems, NPC schedules
- Quests, shops, inventory, hotbar
- Multiple weapons / damage triangle
- Local co-op
- MIDI engine / procedural SFX (dropped by owner order — do not revive)

## New ideas (this project)

- **Video-critic harness leg + gamesmith-assisted fun-verify (owner ask 2026-08-12,
  mid-v10.1-wall).** Owner: why screenshots only — gamesmith exists for video. Dev-of-record
  shape: (a) an ADVISORY video leg on the gate — ffmpeg a reel around a beat, video-capable
  critic judges temporal properties (cue read-time, juice, motion legibility) that stills
  can't; NEVER replaces the deterministic leg (md5 needs frames; video encode isn't
  bit-stable) or the 39-check calibrated history (substrate swap = comparability reset,
  same law as the Nest rename); (b) gamesmith ingesting the OWNER's session recording as
  fun-verify evidence beside telemetry (its actual wheelhouse — footage → observations).
  Costs to weigh at promotion: Bedrock spend per gate multiplies; critic variance on video
  is higher than the already-hardened still path. Harness increment, own wall implications.

- YJIT via self-built Ruby (only if profiling ever shows frame drops)
- Diagonal corner-cutting asymmetry (M2.1 review finding, preexisting): GridWalker
  step/dash check only destination passability, so the PLAYER can move diagonally through
  a two-wall pinch that FlowField#open? forbids the AI. Guaranteed-escape exploit if the
  owner ever notices it; the fix (orthogonal-neighbor check in commit/commit_through)
  changes movement feel, so it waits for an owner verdict rather than shipping silently.

## World mythology — ADOPTED at v12 (2026-08-13, owner fork: full adoption)

- `docs/lore/world-bible.md` — standalone Egyptian×Fantasy world bible (Tibia-method: original
  pantheon, every creature family traced to the mythology, gods withdrawn but omnipresent).
  ~~Deliberately NOT bound (owner call 2026-08-09) — integration is a future decision.~~
  **INTEGRATION DECIDED at the v12 forks (2026-08-13): game-two IS a place in Suvareth**
  (the city Silovun, a defaulted funerary quarter under interdict; the pack = the court's
  collectors). The full order-form answers live in the v12 spec's fiction annex
  (`docs/superpowers/specs/2026-08-13-v12-arc-purpose-design.md`); v12 renders only
  born-named NEW surfaces — existing banners/wipe-line renames remain the v13 increment.
  Research canon behind it: 4 `game-research/` vault notes (egyptian-cosmology,
  egyptian-death-afterlife, akhenaten-amarna, new-kingdom-power — query via
  `hub kb query --domain game-research`). Its gameplay-hooks appendix maps lore → parked
  systems (corpse-run, respawn, skill-through-use, factions, bestiary). Unblocks the
  "fiction-bound audio/visual identity pass" below.

## Queued from the feature map (drafts/_kethral-feature-map.md) — next candidates post fun-verify

- Corpse-run gear drop (kethral's signature death tension — top candidate) — **now fully
  designed**: `docs/design-corpus/death-economy-design.md` (3-critic panel gated, D0-D3
  staging, soul model). D-track is PARALLEL to A1-A3; ordering = owner call at promotion.
  **D0 PROMOTED 2026-08-10** (owner call; scope contract v4) — D1 corpse containers /
  body fees, D2 wipe fine + insurance, D3 extras remain parked behind D0's fun-verify.

## Parked by the D0 spec (2026-08-10 — decided against, not deferred by accident)

- Carry friction (slowdown while carrying, bank fees, drop weight) — cadence was MEASURED
  non-trivial (`drafts/_d0-cadence-measurements.md`); artificial friction only returns if
  telemetry proves cadence collapsed, and A3 (bigger districts) outranks it even then.
- Ally auto-pickup / drop magnetism — kills the "which body holds the value" decision.
- Sub-pile pickup / stack limits — inventory-grid territory.
- Restart persistence for the banked total — a save system with no fun-thesis need;
  banked is session-only by decision (D0 spec challenge 5).
- Third zone tier (Vonash) + BSP-generated dungeon layouts (fixed seed, learnable geography)
- Room names on first visit ("The Entry Wound" style — cheap atmosphere)
- Stamina economy, loot drops, skill-through-use progression

## Owner playtest feedback awaiting promotion (recorded 2026-08-10, mid-D0)

- **Blocker taunt — SHIPPED 2026-08-10 (merge `38064ac`; owner call via structured
  Q&A; scope contract v5).** Original ask verbatim: "the tank is too weak, and should
  get more aggro from the enemies or have an exeta res-like spell to pull aggro."
  Dev-of-record analysis that carried into the spec: the sim has NO aggro system —
  humans target the nearest hostile (`AiController#nearest`), so "more aggro" would
  mean inventing invisible threat weighting; the readable, Tibia-faithful fix is a
  TAUNT VERB (symmetry with the shipped mark: mark orders allies onto one target,
  taunt orders enemies onto one body). Spec: `docs/superpowers/specs/2026-08-10-a0.6-blocker-taunt.md`
  (REVISED). Fun-verify questions pending owner in CHECKPOINT.md.

## D0 fun-verify verdict (owner, 2026-08-10 — recorded, NOT yet acted on)

- **"Bank now or push deeper" = "No, just a chore."** Progression/variety question:
  "Not sure" (inconclusive). D0's substrate works (all mechanics verified); the FUN
  failed. Dev-of-record read: stakes are too low because combat itself carries no
  threat texture — rushers die trivially, nothing endangers the carry, so banking is
  errand-running. Taunt (A0.6) is upstream of this: sticky, controllable fights are
  what make a carried pile feel at risk. **Decision: do NOT tune D0 blind now**
  (drop amounts / decay pressure / station placement wait); re-run the D0 fun-verify
  AFTER A0.6 ships and only then tune with fresh signal.
  **RE-VERIFY LANDED 2026-08-10 (post-taunt): "still a chore."** Taunt fixed combat
  feel, not carry stakes — as its own spec predicted. Revised diagnosis: D0's loss
  moment is a SILENT NOTHING (harshest possible rule — vanish — yet unfelt: no drama,
  no decision, no recovery). Fix promoted: **D1 corpse run** (scope contract v7,
  spec `2026-08-10-d1-corpse-run-design.md`). **D1b (body fees + vat re-growth) split
  out and PARKED** — the tension slice ships alone, one variable at a time; fees
  return with the economy/ledger increment. The post-fight ledger (Tibia Hunt
  Analyser beat, gamesmith FR-024) is the NEXT candidate after D1's fun-verify —
  it is the stakes' readout, so it waits for stakes to exist.
  **D1 fun-verify LANDED 2026-08-11: "still a chore" (THIRD ask).** The corpse
  run fired (owner session: 2 carrying deaths, 2 wipes, 2 recoveries, 0 losses)
  and read cleanly, but drama alone did not move the verdict. Pre-registered
  routing: primary = the pile lacks meaning (Q4 "banked, wouldn't care" = the
  spec's D1b/ledger clause verbatim); secondary = threat never contests the
  corpse. **Post-fight ledger PROMOTED (scope v8, owner lock via
  AskUserQuestion); A2 threat PRE-QUEUED** — promotes automatically if the
  ledger's fun-verify does not move the chore. Full verdict + routing:
  `drafts/_d1-fun-verify-20260811.md`.
  **LEDGER fun-verify LANDED 2026-08-11: INVALID as a meaning test — Q6
  escape-valve at maximum ("never saw any of it"; Q1/Q2/Q4 "never noticed",
  while telemetry proves the system fired: 4 fights, 1 loss beat, 2 wipe
  recaps).** Per the locked routing: presentation iteration FIRST, meaning
  verdict WAITS; Q3 was "not sure", NOT "still a chore" → **A2 did NOT
  auto-promote, stays pre-queued behind the next VALID verify** (visible
  ledger + unmoved chore → promotes automatically). Behavioral note: two
  sessions, zero banks, zero corpse recoveries. Next: make the beat
  impossible to miss, re-run the same 8 questions (FIFTH chore ask). Full
  verdict + diagnosis: `drafts/_ledger-fun-verify-20260811.md`.
  **FIFTH fun-verify LANDED 2026-08-11 (loud presentation, merge `42b54d6`):
  VALID — Q1 "landed as a payoff" (first positive in five verifies) proves
  visibility fixed; Q3 "still a chore" (FIFTH ask) on a VISIBLE ledger →
  the v8 pre-queue FIRED: A2 PROMOTES AUTOMATICALLY.** LB-1 refuted:
  legibility alone does not price the pile (Q4 same walk, Q5 tally meant
  little, Q7 wouldn't notice, Q8 wouldn't care). Ledger disposition:
  **STAYS through A2** (Q1 positive, per the disposition clause). Q6 "some
  couldn't read" = polish signal only (loss line n=1 / bank lines),
  quarantines nothing. Behavioral first: banked_events=5 (0 in all prior
  sessions). Economy still parked. Full verdict + routing:
  `drafts/_ledger-fun-verify2-20260811.md`.

## Owner playtest feedback (recorded 2026-08-11, mid-ledger-fun-verify — parked, NOT promoted)

- ~~**"The tank should be the main character to be selected in the party…"**~~
  **SHIPPED WITH A2 (2026-08-12): `combat.json` initial_possessed=blocker** — the
  entry below is kept for the reasoning record only. Dev-of-record read at the
  time: initial possession should start on the BLOCKER, not the striker;
  corroborated by the ledger pilot flight (blocker survived every stretch, striker
  died first in nearly every life). It rode A2's re-pilot exactly as planned
  (flipping the possessed body desyncs pilot-authored replay streams — never
  standalone). Stale "SHIP WITH A2" wording caught + fixed at the v11 debate.

## Owner design questions (recorded 2026-08-11, mid-ledger-ship — answered, parked, NOT promoted)

- **Sustain (potions / healer / heals): route through D1b as the SPEND side of the
  ledger, never as a free cooldown.** Owner observation (correct, and measured: the
  ledger pilot flight logged 8 wipes in 5.5 sim-minutes; bodies only refresh via
  wipes, so hunts bleed out monotonically): hunts can't hold longer periods without
  sustain. The touchstone agrees — the EK-1037 Hunt Analyser's 59-minute hunt exists
  BECAUSE of its 311k supply burn; sustain and cost are the same mechanic. Dev-of-record
  shape when D1b promotes: healing/re-growth PRICED in banked value (the vat), so the
  banked pile buys hunt length — this is what finally makes the pile mean something,
  closing the loop the ledger instruments. Owner's healer-fairy/Navi kernel (invokable
  periodic AoE heal) folds in as a PRICED invocation (a portable bank-sink), not a free
  cooldown — free sustain lengthens hunts by weakening death (D1) and deleting the
  P&L's cost column (FR-024). No healer kit (4th body), no inventory potions (grids
  parked), no battle-rez.
- **Reviving teammates: mid-hunt re-crew AT THE HUB for a fee (D1b vat re-growth),
  not in the field.** Wipes already revive (the vat); the gap is dead-ally attrition
  mid-hunt (flight evidence: long last-body death-spirals). A paid hub re-crew gives
  the walk back a purpose beyond banking (Q2 "in between" gets a decision), keeps
  death meaningful, costs banked value. Field revival stays out.
- **Gate-camping / entrance-stacking: real, measured, and A2's problem.** Flight
  evidence: aggroed rushers never leash — chasers that lose the player IDLE at the
  gate; respawns walk back toward the last fight; the west gate re-formed a meat
  grinder every life, and re-entry at the arrival tile was spawn-adjacent ambush.
  Shape notes for A2 (this is pull-economy/aggro territory): (a) leash-with-no-heal —
  rushers that lose contact for N seconds walk home; they KEEP current HP, so
  zone-flipping is a breather, never a reset (the owner's named exploit); leash timer
  >> gate round-trip; (b) gate beachhead — small no-camp radius around arrival tiles
  unless attacked; (c) chaser cap ties into A2's aggro soft-cap. Do NOT ship as a
  standalone fix — it reshapes threat, which is exactly the variable A2 owns.
- ~~**"The Nest" rename — SECOND owner complaint on record (2026-08-11; first was
  earlier).**~~ **SHIPPED IN v14 (2026-08-14): The Nest → "The First Vigil", District
  One → "The Longrow", wipe line → "THE FLESH IS SPENT" (×3 locales), riding the v14
  comparability reset exactly as this entry prescribed** (rename + one full wall
  re-run). Kept for the record: the name was fiction-pending spec-speak that leaked
  player-visible; the fix waited for the bible + a cheap reset moment, as designed.

## A1+ queue (cut from Increment A by the 2026-08-09 dual review — each behind its own fun-verify)

- A1: gambit engine (JSON IF/THEN ally rules) + dev hot-reload keybind for iteration
  - ~~Adjacent-lobber inertness~~ CLOSED in M2.1 (owner verdict "teammates feel dumb"
    promoted the minimal fix): husk-grade retreat_step in AiController — adjacent
    projectile kit steps away to open range, then fires. FULL kiting/retreat behavior
    (hold range while repositioning, flee at low HP) remains gambit territory here.
- A1+: Shooters (ranged humans — needs per-attacker cadence proven first)
- A2: pull economy with aggro soft-cap (8-12) + density costs (review: without the cap it is
  monotonically exploitable). **Promoted v6 then DEMOTED same day (2026-08-10), zero code
  written** — owner pullback: "more complex aggro system is nice to have but seems more like
  an extra for later." Shape notes banked for whenever it returns: (a) owner picked a
  per-human threat-accumulator shape (taunt as threat CEILING, preserving the fun-verified
  hard lock) over this entry's original pull-density shape — reconcile the two at promotion;
  (b) gamesmith corpus has ZERO touchstone evidence for threat/aggro systems in any of the
  5 games (Tibia's only "pull" concept is over-pull as route-risk) — A2 must be defended
  from game-two's own diagnosed problems (the taunt-fuse finding, spec decision 6), not
  cited evidence. ~~PRE-QUEUED 2026-08-11 (scope v8 owner lock)~~ → **PROMOTED
  2026-08-11: the pre-queue FIRED on the fifth fun-verify (Q3 "still a chore" on a
  VISIBLE ledger — Q1 "landed as a payoff" proves visibility). LEAVES THE LOT; scope
  v9 rewrite is the next session's first act, then the A2 brainstorm (fold in the
  shape notes above + tank-first possession + gate-camping notes; reconcile
  threat-accumulator vs pull-density). Four converging signals now on file (D0
  dev-read, taunt not moving the chore, D1's 2/2 uncontested recoveries, ledger
  legibility refuted as the meaning lever).** Verdict:
  `drafts/_ledger-fun-verify2-20260811.md`.
- A3: nest advance / district progression (break districts, re-home the nest)
- Fiction-bound audio/visual identity pass (waits on the bible)

## A2 brainstorm evidence inputs (banked 2026-08-11, evidence-gathering session — consume, don't re-derive)

- **Gudii transcript corpus**: `C:/Users/gabri/knowledge/sources/Tibia Videos by
  Gudii-backup-2026-08-11` — 98 full transcripts. Deep-probe report:
  `drafts/_gudii-backup-probe.md`. Top-5 designer reads: f21 (aggro/exeta res —
  THE A2 doc), f83 (laps/respawn/overkill), f38 (30-day supply finances), f15
  (environment-as-pressure), f79 (cascading-failure feel). The owner's
  NotebookLM notebook `540b80c7-...` = the SAME 98 sources (ask satisfied;
  no saved notes; overview banked in the probe draft).
- **Two owner-picked Gudii videos**, transcripts banked verbatim
  (`drafts/_gudii-ruins-transcript.md`, `drafts/_gudii-monk-transcript.md`),
  gamesmith ingestion as `tibia/gudii-ruins` + `tibia/gudii-monk` (per-recording
  artifacts under `workspace/gamesmith/artifacts/games/tibia/recordings/`).
  ⚠️ gamesmith `extract tibia --force` + `synthesize --force` regeneration is
  DEFERRED (it rewrites the docs game-two FRs cite; gamesmith GATE-4 owner flow
  applies) — queued as an explicit reviewed step, not silent absorption.
- **Cross-corpus consequence-economics synthesis** (12-agent workflow
  `wf_de8ce8ad-579`): harvest at `drafts/_gamesmith-consequence-synthesis.md`
  (or resume from the run id if it died mid-flight).
- **Standing observations to fold in**: wipe cadence (6 wipes/session, free
  respawn = arcade "lives" feel — threat should make death rarer but heavier);
  the pure-A2 vs minimal-D1b-hook fork ("what does the pile buy, and when" is
  an explicit brainstorm section per owner choice); owner fork set presented
  via batched AskUserQuestion BEFORE the spec (curated from the workflow's
  fork_candidates, ~8-12 genuine owner-level forks, not 20 generic).

## A2 brainstorm OUTCOMES (2026-08-11 — all nine forks closed; consume, don't re-open)

Fork verdicts (owner via AskUserQuestion unless noted): **threat model** =
priority targeting rules (stateless, Tibia-faithful: first-seen + proximity /
lowest-HP / kit-hate overrides; taunt hard lock untouched); **death cadence** =
wipes rare+heavy, body attrition stays frequent (the 3->2->1 spiral is the
tension ramp); **corpse contest** = live corridor (no corpse-specific
mechanic); **depth** = minimal in-map gradient (data-level); **lethality** =
position pressure (engaged cap ~8-12 + uncapped pressuring followers);
**pull verb** = movement-based (no new binding); **attribution** = A2 ships
ALONE (dev call after owner "not sure"; D1b trigger pre-registered in the
spec); **economy vision** = **INSCRIPTION WITHIN RITUAL** (owner-locked from
the council synthesis: banked value buys persistence-through-judgment — spend
to inscribe a body with a god-mark; inscribed bodies survive the vat on a
wipe; unmarked dissolve; devotional framing, gods as creditors. The
nest-growth BIOLOGY thesis was REJECTED — council diagnosis: chthonic/immanent
vs the fiction's solar/transcendent sacred logic. D1b's design space now aims
at inscription; session-only persistence first, restart persistence stays
parked); **human counterplay** = NONE in A2 (owner + unanimous council).

- **Human counterplay tools — PARKED with a named trigger**: the "Challenger"
  (a NAMED human who force-taunts the player's possessed body — "humans never
  fought back, until one did") ships in its own post-A2 increment with a
  mandatory fairness ladder (visible tell + counters); fear-like scatter
  recorded as the alternative shape (council preferred it IF forced: herd
  management, environmental). Trigger: sixth verify says threat is felt but
  fights lack scary peaks.
- Evidence artifacts this decides from: `drafts/_council-economy-verdict.md`
  (debate transcript + dev synthesis), `drafts/_economy-vision-nest-growth.md`
  (REJECTED thesis, kept for the three-loops analysis),
  `drafts/_a2-design-summary.md` (consolidated design),
  `drafts/_gudii-studio-digest.md` (retention/aggro deltas),
  `drafts/_notebooklm-harvest.md` incl. owner-run chat extension.

## v10 debate + design OUTCOMES (2026-08-12 — all four forks closed; consume, don't re-open)

Scope debate (owner via AskUserQuestion, post-sixth-verify): **increment** =
D1b **inscription + priced flesh** (pure-inscription, sustain-first, and
Challenger declined). Rationale on record: `Creature#revive!` is the sim's
ONLY heal and fires ONLY on wipe-respawn, so the free wipe was the de-facto
heal + body-recovery button — inscription making wipes destructive REQUIRES
the priced valve (owner evidence: "no healing → hunts end early →
repetitive"; touchstone: Tibia supply finances, Gudii f38). **Q6 rider** =
rides v10 (retarget margin/lowhp threshold tuning + a why-they-turned cue).

Design forks (owner via AskUserQuestion): **dissolution** = regrow-for-price
with a one-vessel floor — the vat always returns the body possessed at the
wipe when nothing else survives ("the gods keep you alive to pay";
gone-for-session declined as run-ending). **Mark duration** = consumed by
the judgment it survives — one wipe per inscription, so banked can never
re-become pure score mid-session (endures-the-session declined for the Q8
relapse).

Dev calls recorded at the design gate (owner approved the consolidated
design): three separate fixtures in the nest (bank/altar/vat — spatial
verbs, no menus), tribute = ONE all-or-nothing full-maintenance verb (heal
wounded + regrow dead; closes the deliberate-wipe loop completely),
inscription targets the possessed body standing at the altar, banked stays
visible at the station only (deliberate D0 choice kept).

Spec: `docs/superpowers/specs/2026-08-12-d1b-vat-economy-design.md`. The
Challenger's trigger condition is MET + RECORDED (sixth verify: threat felt,
entrainment flat) — promotion stays the owner's explicit call, fairness
ladder mandatory.

## v11 debate OUTCOMES (2026-08-12, post-eighth-verify — consume, don't re-open)

Owner forks via AskUserQuestion (brief: `drafts/_scope-debate-v11.md`;
verdict: `drafts/_q6-retune-fun-verify-20260812.md`):

- **v11 = DENSITY / RE-MASSING promoted** (hunting-ground pressure). The
  owner's code-confirmed diagnosis: 1:1 respawns at HOME tiles + 12-tile
  block = clumping decays after the opening pull → "too easy to clean up…
  boring and stale after a few rounds". Q6 drop-legibility rides as polish.
  Brainstorm/spec = next session; design forks close before the spec.
- **3.5× band-2 multiplier REVERTED to 2.0** (owner fork): the v10.1 retune
  is a recorded NEGATIVE result — premium earned but not attributed; Q1
  "money got easy" + Q5 "back to nest too often" regressed. The shape-law
  test keeps strictly-increasing, drops the >= 3.0 hypothesis floor. Any
  future premium returns WITH a dense field to read against.
- **Challenger DECLINED (second time)** with trigger TRIPLE-confirmed
  (entrainment flat 6th/7th/8th). Dossier stands in the debate brief;
  standing clause unchanged (owner's explicit call, fairness ladder
  mandatory, scatter alternative on record).
- **Arc/purpose wishlist recorded (owner, verbatim 2026-08-12):** "more
  purpose in the gameplay… move or advance toward something, progress,
  leveling, equipment, new enemies and zones, lore, cities" — the likely
  v12 debate; A3 + bible fiction pass are its lead candidates.
- **Q7 cue redesign = parked presentation item** (two tuning passes — 45→75
  read-time + earlier threshold round — did not move "still arbitrary";
  the cue itself misreads; next attempt is a redesign, not a retune).

## Parked at the v12 debate (2026-08-13 — ninth verify: v11 won; v12 = arc/purpose)

- **The Challenger — THIRD decline.** Its entrainment trigger did NOT confirm at the
  ninth (body reacted for the first time in four reads — density alone delivered it).
  Dossier stands in `drafts/_scope-debate-v11.md`, weaker than at either prior decline;
  promotion remains the owner's explicit call, fairness ladder mandatory.
- **Tibia AoE-specials dossier (deep research, 2026-08-13).** Full report in the
  research task output; design seeds extracted: (B) clump-payoff special — an AoE whose
  efficiency scales with target count, the player-side cash-out for v11's density
  (lure→clump→burst, the Gudii loop); (D) challenge-retarget special —
  `exeta amp res`-style forced retarget to the possessed (`cause=challenged`), the tool
  the deep-carry problem keeps asking for; (A/C/E) elemental fields / resistances / DoT
  kite-tax — bigger, needs a resistance data layer. All wait behind arc/purpose; v13+
  candidates. Touchstone: Tibia team-hunt meta (knight holds, shooters volley).
- **Q3 structural-economy branch (banking rides heal trips) — CLOSED UNFIRED.** Carried
  since the eighth as an unfalsified hypothesis; the ninth's Q3 "yes, and it bit" ends
  it without promotion.
- **Drop-legibility escalation lane — CLOSED VALIDATED.** Ninth Q4 "yes, clearly":
  the band tint/size/glow rider works; no parked presentation item needed.

## Parked at the v13 debate (2026-08-14 — tenth verify: v12 WON; v13 = AoE specials B+D)

- **The Challenger — FOURTH decline.** Q8 body reacted again (fifth read; second
  consecutive confirm) — density+arc carry entrainment without it. Dossier stands,
  weaker with each read; promotion remains the owner's explicit call, fairness ladder
  mandatory.
- **Dossier legs A/C/E (elemental fields / resistance profiles / DoT kite-tax).**
  B+D promoted WITHOUT the elemental data layer; A needs C, C is a per-kit data layer,
  E is flavor on top. Re-raise only if B+D's verify routes toward "specials need
  variety" — otherwise these wait for a dedicated elemental increment.
- **Zone 3 — beyond the stair.** seal2_breached=1 at the tenth: the owner PAID the 150
  stretch and saw the sealed stair + beat line (the deliberate v13 hook from the v12
  spec). The arc ladder's next rung is designed-to-exist but unbuilt — lead v14
  candidate alongside the Nest rename.
- ~~**"The Nest" rename — not chosen at this debate.**~~ **Chosen at the v14 debate,
  SHIPPED IN v14** (First Vigil / Longrow / THE FLESH IS SPENT — see the 2026-08-11
  entry above).
- **Q4 Second Vigil "just a shorter walk" — recorded, no lane.** Re-homing is
  infrastructure; its meaning rode the headline (which moved). If a future verify
  routes camp-meaning again, the answer is probably fiction/stakes at the camp, not
  mechanics.
- **UN-parked into v13 lanes (leaving this file):** guard-scope live-wanderer
  avoidance (Q7 values lane exhausted at guard 10 — now a v13 DESIGN item);
  maintenance-economics lever (q6_margins named it: pure=0/19 banks, dead 1.3 +
  wounded 1.7 at bank time — trips are maintenance-forced); drift structural lever
  (two dose iterations both partial-missed — no third blind dose, design
  investigation with ninth+tenth data).

## Promoted OUT of the lot at the v15 debate (2026-08-14 — twelfth verify: v14 WON)

- ~~**The Challenger**~~ → **PROMOTED TO v15** (owner's EXPLICIT call after SIX
  non-confirms, four consecutive body-reacts). Enters WITH zone 3, fairness
  ladder mandatory. First human who fights back.
- ~~**Zone 3 beyond the stair**~~ → **PROMOTED TO v15** (v15 = zone 3 + Challenger
  + configurable keybinds). Four consecutive arc wins, owner paid seal2 twice.
- **Multiplayer spike etapa 1 — ~~v16 LEAD~~ deferred to v17 at the v16 debate
  (owner-ratified 2026-08-15), behind TWO TRIGGERS:** (1) Junior demonstrably
  playing at etapa 0 (async replay exchange through the repo — timezone-proof,
  docs/JUNIOR.md), (2) the v16 presentation cycle shipped (first impression =
  a game with a face). Owner's own argument sealed it: very different time
  zones make real-time lockstep the worst-fit payoff; async challenge races
  (same seed, compare telemetry, swap replays) are the together-play channel
  NOW. Full staged path in the directives section below + memory
  `multiplayer-shared-play-path`.
- **Guard-scope live-wanderer steering — CLOSED VALIDATED** (third consecutive
  clean read: eleventh + twelfth both "Nada injusto").
- **Maintenance PRICING dose — CLOSED (L0 wins).** Twelfth Q5 "ritmo ok" with
  regrow 12 restored. The pre-registered arbiter fired: L0, nothing ships.
  The regrow-cadence investigation (`drafts/_v14-regrow-cadence-investigation.md`)
  is the record; the pricing lever family is permanently recorded-negative.
- **B placement fork — CLOSED VALIDATED.** Twelfth Q1 "Sí, premio" with
  casts=2 + hit histogram fat tail. The whirlwind fired on its current placement
  and landed as payoff. Fork does not re-open.
- **Drift structural lever — CLOSED.** span_thirds{102<113<134} monotonically
  increasing at the twelfth — first real measurement, validates the field.

## Parked by the v14 spec (2026-08-14 — decided against, not deferred by accident)

Full rationale in the spec's "Deliberately absent" section
(`docs/superpowers/specs/2026-08-14-v14-legibility-design.md`) — re-open only on the
named triggers:

- **Contextual/timed hints, tutorial prompts, strip hide-toggle** — fork 1 closed on
  the persistent quiet strip. Re-open ONLY on a twelfth-Q3 "noise" verdict.
- **Movement keys on the strip** — WASD/arrows are genre-literate; six actions are
  the teachable surface (more = a manual, not a reference).
- **Pack/wipe respawn telegraph** — the veil + judgment IS the pack's respawn
  ceremony; only HUMAN spawns were named sudden.
- **Telegraph on tile-recompute** (re-roll at materialize-defer) — a tell that JUMPS
  is a lie with extra steps; the pin holds (W3), W5 unpin escapes camping instead.
- **AI reactions to tells** (humans avoiding/defending spawn tiles) — sim behavior
  change; difficulty is pinned by construction this cycle.
- **Reverse-lookup of live bindings / `overlay.special` generic key** — YAGNI until
  rebindable controls exist; the special slot always speaks the kit's verb.

## Owner directives recorded mid-v13 (2026-08-14) — roadmap items, not v13 code

- **Multiplayer / shared play with Junior (v14 LEAD).** Owner ask verbatim shape:
  "GameLift y demás… para que Junior y yo podamos compartir la experiencia dentro
  del juego"; decision explicitly delegated to the dev. **Dev ruling: GameLift
  REJECTED** — dedicated-server fleet hosting for compiled builds, no Ruby SDK,
  wrong altitude for a 2-player hobby co-op, and Junior has NO AWS account (hard
  constraint, owner-stated). **Chosen path: deterministic lockstep over Tailscale**
  — the tick-locked sim + proven replay determinism is exactly lockstep's
  precondition; Tailscale already runs on the owner's machine; Junior joins via a
  free client + invite link (zero AWS, zero port forwarding). Staged: (0) replay
  exchange through the repo (near-free today — documented in docs/JUNIOR.md);
  (1) cross-machine determinism spike (same seed+inputs on both PCs → identical
  states; risks: exact Ruby 3.4.10, float ops, hash-iteration order); (2) 2P
  possession co-op — each player possesses a different body of the SAME pack
  (born from the fiction: two souls, one pack). Latency BR↔US ~120-180 ms is
  playable for PvE lockstep with input delay. Full reasoning in project memory
  `multiplayer-shared-play-path`.
- **Localization + collaboration directives shipped INTO v13** (not parked): i18n
  en/es/pt-br lane, docs/JUNIOR.md onboarding, junior-tibia collaborative branch
  model. Recorded in the scope contract (CLAUDE.md) and the v13 spec.

## Parked by the v15 spec (2026-08-14 — decided against, not deferred by accident)

Full rationale in the spec's "Deliberately absent" section
(`docs/superpowers/specs/2026-08-14-v15-zone3-challenger-keybinds-design.md`) — re-open
only on the named triggers:

- **LOS/range break as a fourth seizure counter** — the set is swap/interrupt/kill;
  a fourth counter dilutes the fear the increment exists to create. Re-open ONLY on a
  thirteenth-Q3 unfair verdict.
- **Varekka phases / enrage / second form** — one man, one sentence, one death.
- **Zone-3 remittance chest** (fork-1 option B, owner-declined) — RE-OPENS at the v16
  debate if thirteenth-Q4 reads the climb-back as "trámite" instead of part of the hunt.
- **Seal/toll on the stair down** — the owner paid 150 twice; arrival is the payoff,
  not another toll (oracle half A depends on it).
- **In-game rebind UI** — the binding map is a FILE by design (hobbyist + Junior
  git-pull workflow); a rebind screen is its own increment with its own wall.
- **Deeper chambers below the Low Quay** — future arc rungs; one chamber is v15's.
- ~~**Whirlwind kill pop (death juice)**~~ **PROMOTED TO v16 (2026-08-15,
  item e — the fourteenth's debate).** Original finding kept for the record:
  a one-shot kill deletes the victim between
  frames with zero death effect on the tile (found via the aoe_specials dense diag,
  2026-08-15: victim alive+underlined at 1280, gone at 1281). Vlambeer touchstone:
  kills should POP. Check 42 was amended to accept kill-evidence; the underlying
  feel gap is content for a juice cycle, not a check problem.

## Process debt (adversarial review 2026-08-15 — drafts/_adversarial-review-20260815.md)

Infra items, not game features; each needs a maintenance window, not a cycle.

- **en.json key backfill** — ~100 renderer `t()` fallback literals are the de-facto en
  locale; move them byte-identical into `data/strings/en.json` during the v15.5(b) ES
  pass (same surface, one review). Literals stay as emergency fallback only.
- **Telemetry retirement rule** — when a cycle's verdict closes a lane, its counters
  leave `Telemetry` (or move under a retired section). 429 lines and growing without it.
- **world.rb growth cap** — line-cap test beside the orchestrator cap (world.rb is 1,522;
  cap ~1,800) + extract-on-touch: the next cycle that materially edits a subsystem
  (drops/corpses are the cleanest seam) moves it to a plain object with explicit call
  order. NO bus-mediation inside the sim (determinism + debuggability).
- **Check-set amendment policy** — codify what v15.5(d) does ad hoc: ADD-ONLY stays the
  default; exemptions/retirements need an owner-ratified entry in a checks changelog.
- **Headless CI** — GitHub Actions running the pure-sim majority of the suite
  (GL-dependent tests skip loudly). Catches machine-local rot; the wall stays local.
- **README.md** — ten lines + one capture, for humans landing on the repo (Junior
  clones for the multiplayer era).
- ~~**v16 recommendation ON RECORD (owner decides at the fourteenth)**~~
  **FIRED at the v16 debate (2026-08-15): owner ratified the
  presentation/identity cycle; multiplayer → v17 behind triggers.**

## Parked by the 2026-08-16 owner order (lore removal)

- **Creative-writing program — SEPARATED from this repo.** Bible, language
  pipeline artifacts, and the bible-rework session live at
  `C:/Users/gabri/workspace/game-two-lore/` (also in git history pre-removal).
  If fiction ever returns, it gets its own repo and pipeline; this repo
  stays placeholders-only (AGENTS.md standing order).
- **Internal-id de-lore sweep (optional).** Zone ids (`slow_door`,
  `low_quay`), harness script filenames (`varekka_duel.json`,
  `low_quay_run.json`), event names (`seal_breached`, `inscribed`,
  `tribute_paid`, `vessel_seized`) and telemetry keys (`varekka`) remain
  lore-flavored but are player-invisible and replay/wall-load-bearing.
  Rename only on explicit owner ask; costs a full wall + manifest churn.
- **Owner addendum (2026-08-16, post-removal): Junior's language work is
  KEPT on purpose** — "guarda lo que él trabajó de lenguaje, igual nos va
  a servir." Lives in the external archive (now a git repo with README +
  state-of-play: `../game-two-lore`, commit 374d3e2) under
  `junior-language-lane/` (3-probe package + ratified PT-BR mark_void),
  plus game-two history via merge `00d63bb` second parent.

## Parked at the v17 debate close (2026-08-16)

- **Etapa-2 netcode candidates (spec §Deliberately absent — recorded here so
  promotion day starts from the file, not from memory):** UDP + input
  redundancy (first candidate if the SIXTEENTH shows stall storms with clean
  digests — pre-registered routing); adaptive/renegotiated D (a desync mine
  in etapa 1; only behind its own determinism proof); mid-session
  rejoin/resync + rollback family (owner-parked — lockstep's shared-punishment
  stall cost is the recorded price, W3/K3); host migration; >2 seats;
  spectators; open-internet play (Tailscale = trusted overlay only).

- **BOSS-1 dread iteration — OPEN-FOR-EXPOSURE, zero code owed.** Stakes +
  presentation shipped and walled in v16; the fifteenth never crossed
  seal2. Self-answers the first time any session (owner or Junior) reaches
  ZONE 5 and meets BOSS 1: harvest varekka{interrupted, swap_escapes,
  burns} + ask Q2/Q3 from the fifteenth skeleton. Only becomes a WORK item
  if that exposure reads flat AND behavior didn't change (pre-registered
  routing: park-for-redesign, not iteration).
- **v16 leftovers that stay parked:** font-native hi-res text (Q5 lever,
  no complaint yet); sprites/art (own cycle + pipeline); whirlwind feel
  gap (striker first_special=never AGAIN this session — watch it at v17
  playtests, promote only if a verdict names it).
- **Repo hygiene, other seats' moves:** origin/junior/ci is 100% integrated
  (0 unique commits) — deletion is Junior's call, his branch. origin/main
  runs 3 days behind BY DESIGN (owner's solo backup line) — syncing it is
  the owner's move, never the dev seat's.

## Systemic-worlds research shelf (banked 2026-08-16, knowledge-session evidence drop — consume, don't re-derive)

- **Five verified vault notes now cover the systemic-world design space** (NPC
  schedules/sim-LOD, economy sinks-faucets, damage/elements/combat math,
  crafting/loot/pity, world events/towns/folklore-mechanics), each with a
  "For game-two" section mapped onto entries in this file. Consumption
  workflow, trust tiers (VERIFIED/CORRECTED/FLAGGED — folklore never lands in
  `data/`), and the spec pipeline codified from the death-economy precedent:
  `docs/design-corpus/systemic-worlds-research-shelf.md`. Query via
  `hub kb query --domain game-research "<topic>"`.
- Backing corpus: `knowledge/sources/rpg-systemic-worlds-research-2026-08`
  (adversarially verified 2026-08-16, per-file verdict tables; ~50 VERIFIED /
  ~31 CORRECTED / ~43 FLAGGED / 2 REMOVED — two invented GDC talks caught).
  Notable for future cycles: the v11 arc/purpose wishlist (progress, leveling,
  equipment, new enemies/zones, cities) maps almost 1:1 onto these notes; the
  corpus is MMO-first, so it also feeds the post-v17 multiplayer era.
- **NOT a promotion.** Zero code owed; v17 scope untouched. This is the A2
  evidence-inputs pattern: pointers banked so promotion day starts from
  verified touchstones instead of re-research.
