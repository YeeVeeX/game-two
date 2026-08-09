# CHECKPOINT — game-two (Ruby rebuild of Kethral)

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

**In flight when written:** adversarial code-reviewer over the M2 diff — findings fold in
before merge to main. After merge: owner feel-check (kit identities, Lobber possession,
Rusher pincer pressure, district).

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
