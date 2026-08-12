# D1b — The vat economy (inscription + priced flesh + Q6 legibility rider)

Status: REVIEWED (2026-08-12, 3-lens adversarial workflow `wf_2ccd8520-4cd`
— code-fit / design-economy / harness-verifiability, 15 agents, every
finding independently refuted-or-confirmed: **12 findings, 12 REFUTED, 0
confirmed**; two refuted-but-useful clarity folds applied [§3 placement
wording, §Presentation-5 post-wipe capture timing]; ledger:
`drafts/_d1b-spec-review.md`). Pending: owner spec gate. All four
design-shaping forks closed by the owner via two AskUserQuestion rounds on
2026-08-12 (fork ledger: PARKING_LOT §"v10 debate + design OUTCOMES"); the
economy VISION was locked 2026-08-11 (inscription-within-ritual, kimi/glm
council synthesis — `drafts/_council-economy-verdict.md`). Promoted by the
SIXTH fun-verify (Q3 moved → A2 wins → scope debate → owner pick; scope
contract v10, commit `867be8d`). Fun thesis under test, verbatim: **"banked
value must buy something the player already almost loves — persistence
through judgment, and the readiness of the flesh."**

Binding upstream: scope v10 (CLAUDE.md); `drafts/_a2-fun-verify-20260812.md`
(verdict + routing); `drafts/_council-economy-verdict.md` (vision + dread
caveats); PARKING_LOT §"A2 brainstorm OUTCOMES" (economy lock) + §"v10
debate + design OUTCOMES" (fork ledger). Touchstone grounding: Egyptian
name-as-soul (*ren*) and erasure-as-damnation — the bible corpus is New
Kingdom/Amarna, so name-erasure is the period's own damnation (council Q1);
Tibia's recurring supply drain as the economy that keeps hunts consequential
(Gudii corpus f38, supply finances); "gods as creditors, never love" (kimi's
ritual frame — the debt never settles). Anti-touchstone, recorded: the
war-materiel shop, pack progression, and debt-spreadsheet directions were
REJECTED at the council debate; nothing below is a shop.

## Why this is the increment (the meaning diagnosis, six verifies deep)

Q8 has now answered "banked wouldn't matter" six times — banked is pure
score. Q5: wipes are rare (cadence landed) but weightless ("no body
reaction"). Owner free-text evidence: "no healing → hunts end early → turns
repetitive." Measured root cause (code brief): `Creature#revive!`
(creature.rb:245) is the ONLY HP-restore in the sim and fires ONLY from
`respawn_pack` (world.rb:712), which fires ONLY on the wipe timer
(world.rb:106-110) — and `Pack#bank!`'s own law says banked is never taxed.
So the free wipe was simultaneously the heal button and the body-recovery
button: once the pack is worn to 1-2 bodies, deliberately wiping is strictly
optimal (full pack, full HP, banked intact, cost = one walk). The sixth
verify's telemetry fits (body_deaths=3, wipes=1, one pile abandoned).

This increment makes every one of those flows priced: the wipe becomes
purely the judgment event (marked flesh survives, unmarked dissolves), and
readiness becomes a purchase (tribute). Banked stops being score because it
is now the only thing standing between the pack and the vat.

## Scope (one economy: two sinks, one currency; riders recorded)

**IN — five mechanisms + two riders:**
1. Spend plumbing: `Pack#spend!` (banked is spent ONLY by player-initiated
   station verbs — the never-taxed law survives).
2. The altar — inscribe the possessed body with a god-mark (the meaning
   sink; mark consumed by the judgment it survives).
3. The vat — tribute: one all-or-nothing full-maintenance verb (heal every
   wounded body + regrow every dead body; the recurring sink).
4. Wipe resolution rewrite: marked bodies revive (mark burns), unmarked
   dissolve (stay dead until regrown), one-vessel floor (the body possessed
   at the wipe always returns when nothing else would).
5. Q6 legibility rider: retarget threshold retune (data) + a why-they-turned
   cue (presentation).
6. RIDER (bug bundle, both invalidate all replay streams): held-dodge
   movement lock fix (controllers.rb:33-37, edge-trigger) + `deepest_band`
   at-kill conversion (telemetry.rb:65-71).

**OUT — recorded (do not re-litigate):**
- Restart persistence (session-only stands — D0 law; the vat forgets at
  quit). Quirks/history accumulation on inscribed bodies — the persistence
  SUBSTRATE beyond survival arrives with skill-through-use (parked); in this
  increment a mark buys survival and identity (name + glyph), nothing else.
- In-field healing of any kind (the owner's named A2 rule stands: leash and
  breather bank no free healing; ALL flesh restoration happens at the vat).
- Partial tribute, per-HP pricing, dynamic/scaling prices, haggling — the
  tribute is one legible all-or-nothing transaction.
- The Challenger (trigger MET + RECORDED at the sixth verify; promotion is
  the owner's explicit call, fairness ladder mandatory). No new enemy kits,
  no Shooters, no scavengers (D3), no new bindings (H/F interact is reused),
  no term/grace retune, no economy HUD (banked stays station-only — the D0
  quiet-HUD choice is kept deliberately; field uncertainty about the war
  chest is Tibia-depot texture).

## Sim spec (all numbers in data/, zero constants in Ruby — values below are
## HYPOTHESES, reset by pilot + telemetry, never by feel)

### 1. Spend plumbing

`Pack#spend!(amount)` — subtracts from `@banked`, refuses (returns false,
no mutation) if `amount > @banked`. Law extended, not broken: banked is
NEVER taxed involuntarily; every spend is a player-initiated station verb.
One registered event carries every spend: `:banked_spent` (actor, amount,
sink ∈ {inscribe, tribute}, banked) — mirrors the retarget-cause pattern so
telemetry gets sinks for free.

### 2. The altar (inscribe — the meaning sink)

- New station `{"type": "altar"}` in `data/zones/nest.json`, placed so the
  three fixtures (bank/altar/vat) are distinct on camera (positions are zone
  data; palette gains per-type station colors — today all stations share one
  color, nest.json:10).
- `World#interact` dispatch extends by station type. The D0 interaction laws
  are preserved verbatim: pickup-first two-press rule, possessed-only,
  idle-only (world.rb:264-266). Bank behavior byte-identical.
- Inscribe: possessed body standing at the altar, `inscribe_cost` banked.
  Refusals (distinct cue, no mutation): already marked · insufficient banked.
  Success: the body gains a god-mark — creature-owned state (law 4:
  swap-inert, rides the BODY like carried and taunt), visible glyph
  (display.json keys), `:inscribed` event.
- Mark lifecycle: burns ONLY at wipe-revival (§4). Ordinary death does not
  consume it (a marked corpse regrown at the vat keeps its mark); voluntary
  re-inscription of a marked body is refused (no stacking, no top-ups).
- Fiction: internal handle `god_mark` everywhere; the player-visible name
  waits on the bible (fiction order form, §Presentation).

### 3. The vat (tribute — the recurring sink)

- New station `{"type": "vat"}` in nest.json.
- Tribute cost = `regrow_cost` × dead members + `heal_cost_per_body` ×
  wounded members (wounded = living below max_hp). All-or-nothing: if
  banked < cost → refused (cue); if cost = 0 → refused (nothing to buy).
  The gods do not do partial mercy — one price, one decision, legible.
- On pay: every dead member regrows — `revive!` onto its `pack_spawn` tile
  in the nest. Placement is a hard rebind (revive! checks no occupancy,
  exactly like respawn_pack today; transient tile-sharing is legal — only
  voluntary movement is blocked). If implementation wants a courtesy
  fallback, the FlowField::STEPS first-free-tile idiom is the pattern.
  Every wounded member heals to max. Regrowth pulls flesh home:
  a body that died in the district stands at the nest spawn (the field husk
  is inert fiction; the pile it dropped is untouched D1 law). Events:
  `:body_regrown` per body, one `:tribute_paid` (cost, regrown, healed,
  banked).
- Tank-first note: possession never moves on tribute (regrowth is not a
  swap).
- Price law (fiction-derived, asserted in data-load tests):
  `inscribe_cost < regrow_cost` — devotion is cheaper than desperation.

### 4. Wipe resolution (the judgment) + the floor

`respawn_pack` (world.rb:712-721) is rewritten. On wipe-respawn:
- Marked members revive at their spawn tiles; the mark BURNS
  (`:mark_consumed` per body) — one judgment per inscription, so banked can
  never re-become pure score mid-session (the fork's rationale).
- Unmarked members DISSOLVE: they are NOT revived — mechanically they remain
  dead-and-regrowable (no new state; dissolution IS the absence of revival),
  `:body_dissolved` per body. The wipe veil shows it (§Presentation).
- **The floor**: if judgment would leave zero living members, the vat
  returns exactly ONE — the body possessed at the wipe moment
  (`:vessel_kept`). The gods keep you alive to pay. Deterministic, no
  randomness.
- Possession: if the possessed body dissolved, control snaps to a revived
  member by the existing forced-swap rule (nearest-Chebyshev from the old
  body, roster-index tiebreak); the floor case trivially possesses the kept
  vessel.
- Untouched laws, verified by regression: taunt release sweep before revival
  (world.rb:713-716), `wipe_grace_frames` pile grace, banked never taxed by
  the wipe, `:pack_respawned` still emitted, HOME_ZONE re-entry unchanged.

### 5. Q6 legibility rider (fairness valve tuning)

- Data retunes (hypotheses; the sixth verify's 11-of-14 lowhp retargets say
  the wounded-prey rule fires too often to read as intent):
  `lowhp_switch_pct` 0.35 → 0.25 (rarer, more meaningful),
  `proximity_switch_margin_tiles` 3 → 4 (pass-by steals rarer).
- Why-they-turned cue: on retarget, the human carries a sim-owned cue timer
  (`retarget_cue_frames`, decremented in its tick — the hurt_frames
  pattern; the renderer READS it, never mutates: taunted_target purity law).
  Overhead glyph keyed by cause — hate / lowhp / proximity get distinct
  display.json keys; `acquired` gets NO cue (first sight is not a turn).

### 6. Bug bundle (rides because both invalidate all replay streams)

- **Held-dodge movement lock** (owner-reported, root cause banked at the
  sixth verify): dodge in `PlayerController#tick` is level-triggered — while
  Shift is held the dodge branch swallows every tick on cooldown-refusal and
  the walk `elsif` never runs (controllers.rb:33-37). Fix: dodge becomes
  EDGE-TRIGGERED (fires on press, at most one dodge per press; a held key
  never suppresses walking). Exact edge-detection mechanism (input
  abstraction vs controller-local previous-frame state) is a plan-time
  code-fact decision; the BEHAVIOR above is the spec.
- **`deepest_band` summary-time artifact** (residual arm of the impl
  review's refuted finding — it fired first try because quitting from the
  nest after banking is the natural session end): Telemetry currently
  accumulates max gate-DISTANCE and converts to a band index at
  summary-print time against the CURRENT zone's gradient (telemetry.rb:40-41,
  65-71). Fix: convert at event time — on `:drop_spawned`, look up the band
  in the zone the drop spawned in and accumulate the max band INDEX;
  zones with no gradient contribute nothing. Summary prints the stored max.

### Events + telemetry

- New registered events (world.rb EVENTS, defined on first use, unknown
  symbols still raise): `:banked_spent` · `:inscribed` · `:mark_consumed` ·
  `:body_dissolved` · `:body_regrown` · `:tribute_paid` · `:vessel_kept`.
- New telemetry line (FN-3, event-log-only like a2_fired):
  `TELEMETRY d1b_fired inscriptions= marks_consumed= dissolved= regrown=
  tributes= floor_fired= banked_spent{inscribe= tribute=} banked_end=`
  — the meaning oracle for the seventh verify: a session that never spent
  must be machine-distinguishable from one that spent and felt nothing.

### Data (new keys, hypothesis values)

`data/balance/economy.json` (NEW file):
`{"inscribe_cost": 8, "regrow_cost": 12, "heal_cost_per_body": 2,
"retarget_cue_frames": 45}`
Anchors: drops are 1-2 units (combat.json drop_table [1,1,2]) × gradient
×1.0/1.5/2.0 (district.json), so a mid-depth kill banks ~2-3 — inscribing
is a HUNT-scale commitment (~3-4 deep kills), regrowing a body costs more
than the mark that would have saved it, healing is cheap enough that
skipping it is negligence, not thrift. **Pilot re-anchors all four values
from replay EVENT-log banked amounts before the verify** (the current
telemetry counts events, not units — the pilot measures units/session
first).
Plus: `threat.json` retunes (§5) · `nest.json` altar + vat stations +
per-type station palette · `display.json` mark glyph, retarget cue glyphs,
station cost readouts, refusal/success cue keys.
Perf: negligible (station dispatch O(1); no per-tick economy work; one cue
timer per human). `rake perf` re-run anyway (current p95 0.232ms vs 16.6
budget; the wall re-proves it).

## Presentation spec (Rule 2 surface)

All render-only reads of sim state; no draw-path mutation.
1. **The god-mark** — a marked body carries a visible glyph, readable at
   gameplay camera scale, present in every zone.
2. **Three fixtures** — bank, altar, vat are visually distinct at a glance
   (per-type palette; a stranger can point at which is which).
3. **Cost legibility** — standing possessed at the altar/vat shows the
   price (and the tribute breakdown) the same way banked shows at the bank
   station today (renderer.rb:217-230 pattern); nothing persistent, quiet
   HUD preserved.
4. **Spend beats** — inscribe success reads (glyph ignition), tribute reads
   (bodies regrow at the spawn tiles + wounds close), refusals read as
   refusals (distinct cue, not silence, not success).
5. **The judgment** — as the veil lifts, the return is legible: marked
   bodies come back (glyph burning away), dissolved bodies visibly do NOT,
   the kept vessel reads as kept. The `judgment_reads` capture is POST-wipe
   (first frames after the veil), never mid-veil. Dissolved flesh leaves NO
   field husk (the vat took it) — dead pack bodies DO leave fading corpse
   records today (world.rb:788, CORPSE_FADE_FRAMES); judgment clears
   pack-faction records (or lets the fade finish — plan-time call), the
   field must be clean either way.
6. **Why-they-turned** — the retarget cue glyph (§5) reads at a glance and
   dies quickly (no HUD residue).
Fiction order form (player-visible names await the bible; spec-speak stays
internal): the god-mark · the altar · the vat (fixture name) · the tribute
verb · the dissolve term · the kept vessel (floor) · plus A2 carryovers
already listed there (pressuring stance, hate-variant, walk-home, depth
bands, beachhead) and (post-D1b) the Challenger.

## Harness + gates

- New gate script `vat_economy.json` (the 9th wall script), pilot-authored,
  five acts: (1) hunt + bank at the station; (2) inscribe at the altar —
  glyph on camera; (3) tribute at the vat with wounded + dead flesh —
  regrowth and healing on camera; (4) wipe with one marked + rest unmarked —
  marked survives (mark burns), unmarked dissolve; (5) second wipe, zero
  marks, empty pockets — the floor keeps the possessed vessel.
- ALL EIGHT existing wall scripts re-piloted (the dodge edge-trigger changes
  input semantics for every stream; the tank-first lesson applies) →
  9-script wall: double replay + md5 + critic, ALL blocking (Rule 2).
  **Every mandatory beat re-staged** — projectile, telegraph, swap, nest
  frames (memory: gate-critic-mandatory-beat-checks; "passed this morning"
  claims are refuted from artifacts, not trusted).
- APPENDED vision checks (34 → 39, ADD-ONLY, existing never weaken):
  1) `mark_glyph_reads` — a marked body is distinguishable at a glance;
  2) `fixtures_distinct_read` — bank/altar/vat tell apart on one frame;
  3) `tribute_beat_reads` — regrown bodies appear + heal visible;
  4) `judgment_reads` — post-wipe return shows survivors vs dissolved
     (and, in the floor act, the kept vessel);
  5) `retarget_cue_reads` — the why-they-turned glyph is visible and
     cause-distinct.
- Tests (minitest, real World, no mocks): `spend!` refusal/floor;
  interact dispatch preserves pickup-first + possessed-only + idle-only and
  bank byte-compatibility; inscribe cost/no-double-mark/insufficient-refusal;
  mark rides the body through Tab swap and death (law 4); tribute cost
  formula, all-or-nothing (insufficient = zero mutation), regrow-at-spawn
  with occupied-tile defer, heal-to-max, zero-need refusal, mark preserved
  through vat regrowth; wipe: marked revive + burn, unmarked stay dead,
  floor determinism (possessed vessel), possession snap when the possessed
  dissolved, taunt-release sweep + grace laws untouched; dodge edge-trigger
  (held key walks; one dodge per press; cooldown refusal falls through to
  walking — the sixth verify's bug becomes the regression test); deepest_band
  at-kill (quit-from-nest scenario pinned); data-load assertions
  (`inscribe_cost < regrow_cost`, all costs positive, cue frames positive);
  determinism (byte-identical double replay).
- `rake` + `rake perf` + 9-gate wall green; adversarial impl review; merge
  `--no-ff`; NO push (a private remote exists since 2026-08-12 — pushing is
  the owner's action, never the dev's).

## Fun-verify (SEVENTH — owner questions, AFTER playing, two batches;
## play-first law: no questions before the session)

**Preamble:** if you never wiped, the judgment never fired — say so and
we read Q2-Q4 as unexercised, not negative.

1. **The meaning question (Q8 rerun, SEVENTH ask, headline):** if your
   banked number were silently halved, would you care now? What did you
   spend on, and did any spend feel like a real decision?
2. **The pact:** did inscribing a body before a deep push change how the
   push felt? Did "name your dead before they die" land as a bet — or as a
   checkbox?
3. **The judgment:** when the wipe came, did marked-survives /
   unmarked-dissolves read on camera — and did the dissolve sting?
4. **The floor:** if you ever wiped broke and unmarked — did the kept
   vessel read as the gods keeping you (mercy or mockery both count), or
   did it read as a bug?
5. **Hunt length (your evidence, follow-up):** with tribute healing between
   hunts, did hunts stop ending early? Did the repetitive feeling move?
6. **The dilemma (Q3 rerun):** does "bank now or push deeper" still bite
   now that banked buys marks and flesh — or did the economy collapse it
   (e.g., always-bank-to-afford-tribute)?
7. **Fairness valve (Q6 rerun):** do target switches read as intent now —
   did the turn-cue + rarer switches fix the randomness read?
8. **Price feel:** any price that felt arbitrary, punitive, or exploitable?
   (Tunes economy.json; does not quarantine Q1.)
Entrainment probe continues: on the last-body stretch, did your body react?

**Pre-registered routing (locked here — do not re-derive):**
- **Q1 moved** (banked matters) → D1b wins; next increment = scope debate.
  The Challenger is the standing queued candidate (trigger already MET +
  RECORDED) — promotion remains the owner's call at that debate.
- **Q1 unmoved but spends FIRED** (telemetry: inscriptions + tributes > 0)
  → price/meaning tuning iteration (economy.json data only), NOT new scope.
- **Spends NEVER FIRED** (zero inscriptions + tributes in telemetry) → the
  economy is invisible, not unloved — fixture/cost legibility iteration
  (presentation), the ledger arc's lesson (LB-1) applied before any
  redesign.
- **Q5 unmoved** (hunts still end early with tribute affordable) → heal
  pricing retune first; if a second verify still reports it, in-field
  sustain opens as its OWN debate candidate — recorded, not promoted.
- **Q7 regressed/unmoved** (fairness valve) → threshold iteration continues
  (data); cue redesign parked unless the cue itself misreads.
- **Q6 REGRESSED** (the dilemma collapsed) → economy retune with the
  dilemma as the oracle; the A2 threat layer is NOT touched (it verified).
- **Q4 "read as a bug"** → floor presentation iteration (the mechanic
  stands; the read failed).

## Deliberately absent (recorded so review doesn't re-litigate)

Restart persistence (D0 law; the vat forgets at quit) · quirks/history/
stat-growth on inscribed bodies (substrate parked with skill-through-use;
a mark buys survival + identity only) · in-field healing (owner's named
rule) · partial tribute / per-HP pricing / dynamic prices · any shop,
inventory, or catalog UI · economy HUD (banked stays station-only) · the
Challenger (met trigger recorded; owner's call) · scavengers (D3) · new
bindings (H/F reused) · new enemy kits · term/grace retune (parked until
measured margins) · mark stacking or top-ups · buying marks for humans,
zones, or anything that is not pack flesh (the economy prices the pack,
nothing else).
