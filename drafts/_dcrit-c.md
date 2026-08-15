# Design critique C — scope / staging / testability (YAGNI lead)

**Artifact:** `docs/design-corpus/death-economy-design.md` · **Date:** 2026-08-09
**Posture:** default-cut. Context held: A0 spec (not yet fun-verified, M2.1 in flight),
PARKING_LOT.md, design-review-reconciliation.md ("judge builds, not briefs").

---

## Q1 — Staging order & the D0/D1 boundary

**VERDICT: BLOCKING** (one blocking finding, one advisory).

**BLOCKING — D1 is named "THE fun-verify target" while its substrate is vaporware.**
The doc's own words: D0 is "**loot loop (prerequisite, NOT this doc)**" and "Needs its own
tiny design pass; this doc only fixes the interface: per-creature `carried[]`, nest
`banked[]`." So the staging ladder's first rung has no design anywhere in the repo — not
here, not in PARKING_LOT (which lists only "Stamina economy, loot drops, skill-through-use
progression" as a one-liner). D1 is *not* testable as scoped, because without D0 the corpse
containers are empty and the fun thesis ("losing a body should sting") is unfeelable — an
empty corpse run tests pathfinding, not tension.

Worse, the doc smears D0's fun question into D1's gate: "**D1's fun-verify must include
'banking cadence felt like a decision.'**" Banking cadence is the D0 loop ("bank now or
push deeper" — law 2's "heartbeat") and exists the moment D0 lands, before any corpse
exists. Assigning it to D1's gate means D1 is secretly verifying two increments at once —
exactly the "increments in a trenchcoat" failure the reconciliation doc rejected.

**Should D0/D1 merge?** No — their fun questions are genuinely different (D0: "does
banking cadence feel like a decision"; D1: "is the run back tense"), and the repo
discipline is one question per fun-verify. Keep them separate, but:

**Concrete fix (blocking):** add the "tiny design pass" for D0 *to this doc* — it is ~10
lines and the doc already owns the interface: (1) the currency entity + drop rule,
(2) the pickup verb (see Q7 — this is not free), (3) the bank verb at the nest,
(4) **what happens to carried loot on death BEFORE D1 exists** — vanish (research-approved
in-flight loss, independently testable) is the obvious pre-D1 answer, and the doc must say
it, because D0 must be shippable and fun-verifiable alone; (5) D0's own gate, which is
where "banking cadence felt like a decision" belongs. Move that clause out of D1's gate.

**ADVISORY — is D1 too big?** Borderline-acceptable. D1 = corpse containers + own-corpse
recovery + wipe leaves three loaded corpses + term expiry, one fun question ("owner wipes,
runs back, recovers, and calls the tension fun") — that is one verifiable feeling, so it
passes. Term expiry is the marginal item; I probed cutting it, but it doubles as corpse GC
(without a term, corpse entities accumulate forever) and it is the deadline that makes the
run a *run*. Keep it in D1. The real D1 bloat risk is hidden, not listed — see Q7.

---

## Q2 — D1 ship gate vs the repo standard; `corpse_run.json` sufficiency

**VERDICT: ADVISORY.**

**Gate structure: SOUND.** D1's gate — "`rake` green · `corpse_run.json` capture
byte-identical across two runs · vision critique passes (corpse entities legible: distinct
from live actors and from decor) · owner wipes, runs back, recovers, and calls the tension
fun" — is a faithful instance of the A0 four-part standard (rake / byte-identical / vision
critique / owner fun call). No structural gap.

**Script sufficiency: three holes.**

1. **The tactical tier is never exercised.** The script is "die loaded → wipe → run back →
   recover → term-expire one corpse deliberately" — it goes straight to wipe. But D1's own
   mechanics section stakes a mid-hunt decision: "push to recover the Blocker's load under
   pressure, or cut losses" and "Surviving pack members loot own-pack corpses instantly
   and free." Nothing in the script asserts a *survivor* looting a packmate's corpse
   mid-hunt (carried[] transfer to a living creature, not just wipe-recovery). Fix: the
   script's first act should be one body dying loaded, a survivor looting it, THEN the
   wipe sequence.
2. **Vision critique scope is one state short.** "corpse entities legible: distinct from
   live actors and from decor" covers corpse-vs-world, but D1 introduces *three* corpse
   states the player must read at a glance: loaded / looted-empty / expired. If a loaded
   corpse is not visually distinct from a looted one, the corpse run has no legible
   target and the term expiry is invisible drama. Fix: add "loaded vs looted vs expired
   distinguishable in capture" to the critique checklist.
3. **The A0 camera law isn't restated.** A0's rule: "what the harness must verify, the
   viewport must show" (off-screen events asserted via events, not captures). A deliberate
   term-expiry of a *distant* corpse will resolve off-screen. The doc must say which side
   of that line each corpse_run.json assertion sits on — on-camera capture or event
   assertion — or the script author will guess.

Minor: no stacked-corpse case (a wipe in a choke can drop 2-3 corpses on adjacent or
identical tiles; loot-target ambiguity is a determinism question). One scripted stacked
wipe would close it.

---

## Q3 — YAGNI sweep

**VERDICT: ADVISORY** (nothing here blocks; several things should shrink).

| Item | Quote | Call |
|---|---|---|
| Promotion-analog | "End-state adds a promotion-analog (−30%) to approach the research target band" | **CUT the constant, keep the one-line D3 mention.** A tuned number (−30%) for a system that exists nowhere (no promotion design, no parking-lot entry) is fake precision. D3's bare "promotion-analog" line is the right amount of ink; the fine section's parenthetical is not. |
| Scavenger humans | "scavenger humans that loot corpses (turns term expiry from a timer into a visible drama)" | **KEEP-AS-PARKED.** Correctly caged in D3, one line, and the bible note ("looters-inside-the-term-are-cursed gives scavenger humans (D3) their fiction for free") is a genuine cheap-win observation, not scope. |
| Fine curve discussion | "A flat % is acceptable for a low-cap slice; revisit the curve when practice totals span an order of magnitude." | **KEEP** — this paragraph is itself a YAGNI clause (flat now, curve later, with a stated trigger). Deleting it would invite someone to build the curve early. The "Emotional signature to preserve" sentence is the useful part. |
| Derivation note (8%-per-blessing → −20%/mark) | "the research note's literal 8%-per-blessing priced a *seven*-blessing catalogue…" | **KEEP.** Prevents a future session from re-importing the raw research constant wrong. Cheap insurance, already marked "the SHAPE… is the load-bearing import, not the constants." |
| Gear-proofing claim | "if charms/trinkets ever land, corpses carry them with zero new rules — the container design is gear-proof" | **CUT the claim, keep the exclusion.** "Zero new rules" is an unverifiable promise about an undesigned system: gear implies equipped-vs-carried state, and whether an *equipped* trinket enters `carried[]` on death is absolutely a new rule. Excluding gear is right; certifying forward-compatibility is slop. Replace with "Equippable gear per creature (out of scope; if it ever lands, the corpse container is the natural home)." |
| Retail loop detail | "Insurance marks are bought at the nest with the loot currency and are the death economy's recurring gold sink — the consumed-on-wipe property is what makes them an economy instead of a checkbox." | **KEEP.** Two sentences, and the consumed-on-wipe insight is load-bearing law-4 design, not detail. Selling fiction correctly deferred to the order form. |
| Insurance constants (3 marks, −20% each) | "3 marks… −20% each, additive (max −60%…)" | **KEEP-AS-PARKED.** D2 hypotheses explicitly labeled as such; harmless while D2 is blocked. |
| Pack-parking mitigations | "leash the ally AI… or scale human aggression to living-pack-size (A2 pull-economy territory). Decide with data, not upfront." | **KEEP.** Model YAGNI posture: names the risk, refuses to pre-fix. |

Net: two cuts (a number and a boast), zero structural removals. The doc is leaner than
most; its bloat is in *false-precision*, not sections.

---

## Q4 — Dependency honesty on D2

**VERDICT: ADVISORY** (honesty gap, cheap to close).

The doc says: "**D2 — the wipe fine + insurance retail: blocked on skill-through-use
landing (practice must exist to be taxed).**" Checked against PARKING_LOT.md:
skill-through-use appears exactly once, as one third of a one-line entry — "Stamina
economy, loot drops, skill-through-use progression" — in the feature-map queue. No design
doc, no increment slot, not even in the A1+ ladder (which runs A1 gambits → A1+ Shooters →
A2 pull economy → A3 nest advance). So the true distance to D2 is: M2.1 fun-verify →
(some subset of A1–A3) → skill-through-use *design* → skill-through-use *build + its own
fun-verify* → D0 → D1 → D2. The doc's "blocked on … landing" is technically true and
rhetorically misleading — "landing" implies a thing in flight; nothing is in flight.

**Should the fine be re-based onto something that exists sooner?** The only earlier
candidate is the D0 loot currency — and the doc should *name and reject* it rather than
stay silent, because the rejection is principled twice over: (1) a currency fine taxes the
banked stash, and law 2 is absolute ("The banked stash is NEVER taxed by anything" —
banking is the safety verb; taxing it kills the heartbeat); (2) insurance is *bought* with
currency, so a currency-denominated fine degenerates into rate arithmetic ("pay X currency
to avoid Y currency"), deleting the cross-resource texture that makes the fine sting.

**Concrete fix:** amend D2's line to something like: "blocked on skill-through-use, which
is itself parked with no design doc — D2 is several fun-verifies away at minimum. The fine
stays practice-denominated even so: re-basing onto the loot currency would tax the banked
stash (law 2 violation) and collapse insurance into rate arithmetic. If skill-through-use
never lands, D2 dies with it — acceptable, because D1 carries the signature tension alone."
That last clause is the real honesty win: the doc already proves the corpse run doesn't
need the fine (that's the whole point of D1's "no fine, no insurance yet"), so it should
say out loud that D2 is optional-forever, not merely delayed.

---

## Q5 — Disguised implementation

**VERDICT: SOUND** (with one advisory trim).

The determinism/harness section names `harness/scripts/corpse_run.json`,
`data/balance/death.json`, and schema-shaped state ("carried/banked ledgers: all sim
state, all frame-quantized, all serialized in replays"). Is that premature for parked
fuel? **No — in this repo it is the design.** The reconciliation doc made determinism a
binding law ("Determinism spec before any AI code"; byte-identical replays as permanent
gate), and the A0 spec set the precedent of naming its capture script
(`district_hunt.json`) and balance file (`data/balance/creatures.json`) at design time.
"No wall-clock time anywhere in the term logic" is exactly the constraint class the
Fable review flagged (Tibia's `OTSYS_TIME()` exhaust would kill replays) — stating it in
the design doc is what prevents the implementer from copying the reference game's
pattern. Naming the *contract* (what is sim state, what serializes, what the capture
must show) is design; it prescribes no data structures, no classes, no algorithms.

Two genuinely borderline items, both tolerable:
- `carried[]` / `banked[]` array notation in D0 — this is interface-fixing, which the
  doc explicitly claims as its job ("this doc only fixes the interface"). Fine.
- "Corpse entity: sim-owned, tile-anchored" — architecture words, but they encode design
  decisions (corpses obey determinism; corpses occupy tiles so distance-is-difficulty
  works). Fine.

**ADVISORY trim:** "The byte-identical gate extends to it permanently" is a process
commitment the doc doesn't own — permanent-gate status belongs to the reconciliation
doc and the scope contract. Soften to "candidate for the permanent regression set" or
drop; one line.

---

## Q6 — Fiction order form slop test (6 items)

**VERDICT: SOUND** (one advisory addition).

Testing each item description: real fiction question the bible can answer, vs mechanics
question in disguise.

1. **The wipe** — "what it means that the possessing entity loses all three bodies and
   persists… this extends it to what losing everything is." PASS. Pure meaning question;
   correctly chains off A0 order-form item 3. The bible has machinery waiting (§5.3
   Half-Passage / echo-reeling, already cited in the doc's bible-binding section).
2. **The insurance mark** — "the blessing/passage-scroll analog sold to monsters; who
   sells it and what it physically is." PASS, and the best question on the form — the
   bible's funerary pipeline already answers the human side ("mortuary insurance guilds
   for the poor," §10.1 Vaultwardens), and "who serves monsters" is a genuinely
   generative gap the doc spotted (§10.3 banned-and-buried hook). One quibble: "the
   blessing/passage-scroll analog" leaks spec-vocabulary into the question — ask the
   bible session "who sells monsters mercy against the Toll," not the mechanical
   analogy. Cosmetic.
3. **The currency** — "what humans carry that the pack wants (gleaning fiction)." PASS.
   Worldbuilding (what do monsters value?), not mechanics.
4. **The corpse term** — "why a dead body holds its goods for a while and then doesn't."
   PASS. The bible canonized the human-side answer (the ten-day term, §5.3; river-kin
   "enforce the ten-day term") — this asks for the pack-side reading. Real question.
5. **The protected floor** — "the doctrine that new/weak things pass free." PASS —
   *borderline*. "Doctrine that X" is a fiction question shaped exactly like its
   mechanic (newbie shield → doctrine). But the accessibility floor ("the minimal rite
   is doctrinally sufficient") already exists as bible canon, so this binds to existing
   fiction rather than laundering a mechanic. Keep; watch the answer for slop.
6. **Banking at the nest** — "the rite/act that makes stashed goods safe." PASS. Same
   shape as 5 but genuinely open (nothing in the bible yet says what a *monster nest's*
   sanctity is).

**Missing item (ADVISORY):** **corpse-term expiry as a player-visible event.** The doc
narrates it in fiction voice twice — "the abstract scavengers of the world" (fine
section) and the load "decays — gone" (law 3) — and D1 ships it player-visible: a corpse
the player is racing toward loses its load on screen. Item 4 asks *why* the term exists;
nothing asks what expiry *looks like*, and that ships in D1, long before scavenger
humans (D3) animate it. Add item 7. Second, weaker gap: the corpse run itself carries an
inline fiction slot — "the walk of shame and iron" — a name candidate living *outside*
the order form; fold it into item 1 or the form loses its claim to be the single binding
surface.

---

## Q7 — Biggest unthought-of scope risk

**VERDICT: ADVISORY** (blocking-grade the day D0/D1 promote; they are not promoting
today).

**The doc prices an economy on top of a carry/loot interaction layer that A0 does not
have — and never budgets it.** The A0 possession game has NO pickup verb, NO
adjacent-interact verb, NO carry state, and NO quantity display anywhere: the A0 spec's
HUD is "Three HP bars (possessed one highlighted) + exhaust-ready pip on the possessed
bar. Nothing else," its input model is move/attack/dodge/Tab, and its zones contain no
interactable entities. The death-economy doc quietly assumes all of it: "lootable by
surviving pack members (walk adjacent + interact)" — *interact is a new input verb with
harness-schema impact*. The A0 determinism spec had to grow a "swap lane" for Tab; loot
needs the same treatment, and neither this doc's determinism section nor the
corpse_run.json sketch mentions an interact lane. Likewise "banked at the nest" implies
a nest interactable, and law 2's "bank now or push deeper" heartbeat is only a decision
if the player can SEE what they're carrying — carried/banked totals need HUD, which
means renderer + vision-critique surface, exactly where M2.1 is currently repairing feel
regressions. The D1 gate's "corpse entities legible" covers the corpse sprite and
nothing else in this new input/UI layer.

Why this is the *biggest* risk: it is the trenchcoat pattern one layer below the
staging. D0+D1's real bill is: new input verb (+ harness lane + swap-inert /
edge-trigger semantics per the A0 combat laws — what happens to a held interact across
a forced-swap?), two interactable entity types (corpse, nest bank), carry-quantity HUD,
and 3+ new corpse visual states — before the first container ever fills. The doc
budgeted the sim (containers, terms, ledgers — cheap, deterministic) and forgot the
*hands and eyes*. That is also where the fun lives: "the tensest walk in the game" is
made of what the player sees and presses, and the repo's own law says "every commit must
change what the player sees, hears, or feels."

**Concrete fix:** add an "Interaction substrate (new to the possession game)" subsection
under staging: name the interact verb, assign it a harness input lane, state its
swap/edge-trigger semantics, put the carried-count HUD element in D0's scope with its
own vision-critique line, and split the bill explicitly between D0 (pickup + bank + HUD)
and D1 (corpse-loot reusing the same verb). If that subsection makes D0 look like two
increments — believe it; the interact verb + HUD may deserve to be D0a.

---

## Summary

| Q | Verdict | One-liner |
|---|---|---|
| Q1 | **BLOCKING** | D0 is undesigned vaporware yet D1 (which needs it) is "THE fun-verify target"; banking-cadence clause sits in the wrong gate. Fix: write D0's ten-line design here; move the clause to D0's gate. |
| Q2 | ADVISORY | Gate structure matches the repo standard; corpse_run.json misses the tactical-tier survivor-loot, the 3-state corpse legibility, and the on-camera/event split. |
| Q3 | ADVISORY | Cut two things: the −30% promotion-analog constant and the "gear-proof / zero new rules" boast. Everything else earns its ink. |
| Q4 | ADVISORY | "Blocked on skill-through-use landing" undersells the distance (parked, no design doc, not even on the A1–A3 ladder). Say D2 may be forever-away; name-and-reject the currency-fine re-base (law 2 violation). |
| Q5 | SOUND | Naming scripts/schemas is this repo's design idiom (A0 precedent + determinism law). Trim the "extends… permanently" gate-grant. |
| Q6 | SOUND | All 6 items pass the slop test. Add item 7: what corpse-term expiry looks like (ships in D1); fold "the walk of shame and iron" into the form. |
| Q7 | ADVISORY | Unbudgeted interaction substrate: interact verb + harness lane + carry HUD + nest interactable — the hands-and-eyes layer under D0/D1 that nothing prices. |

**Count: 1 blocking / 6 advisory.** Q7 is the advisory to take most seriously — it
converts to blocking the day the owner promotes D0/D1.
