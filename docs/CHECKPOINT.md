# CHECKPOINT — game-two (Ruby rebuild of Kethral)

## 2026-08-12 (latest, MERGED) — D1b vat economy SHIPPED to main; seventh fun-verify handed to the owner

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
