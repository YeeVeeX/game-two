# CHECKPOINT — game-two (Ruby rebuild of Kethral)

## 2026-08-10 (latest) — PILOT MODE APPROVED + PLANNED; implementation is NEXT

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
