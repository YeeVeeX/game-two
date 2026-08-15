# Hostile systems-economist review — death-economy-design.md (dcrit-b)

**Date:** 2026-08-09 · **Reviewer stance:** break the economy; flag when uncertain.
**Artifact:** `C:\Users\gabri\workspace\game-two\docs\design-corpus\death-economy-design.md`
**Evidence:** research note `death-penalties-stat-scaling-and-progression-balance.md` (vault, game-research)
+ A0 spec `2026-08-09-a0-possession-core-design.md`. Both read in full. Supporting checks:
`data/balance/` contains only `combat.json`; world bible §13 hooks table confirmed (ten-day term,
looters-cursed rows).

---

## Q1 — Fine math, derivation honesty, 5% base

**VERDICT: ADVISORY** (arithmetic correct; derivation note misquotes the research band; base defensible)

**Arithmetic verified.** Artifact: "`base_fine`: **5%** of each creature's banked practice per wipe"
and "Insurance: **3 marks** available in the first slice, **−20% each**, additive (max −60% →
fully-insured wipe ≈ **2%**)." Check: 5% × (1 − 0.60) = 5% × 0.40 = **2.0%, exact** (the "≈" is
overcautious). Full slice ladder: 0/1/2/3 marks = 5.0 / 4.0 / 3.0 / 2.0%. End-state with the
promotion-analog (−30%): promo-only 3.5%, promo+1 mark 2.5%, promo+2 = 1.5%, promo+3 = 0.5%.
The Tibia additive-stack import is sound — the research reproduces the community numbers to the
digit (713,100 × (1 − 0.30 − 7×0.08) = 713,100 × 0.14 = 99,834, exact).

**Band check — slice MISSES the mitigated band.** Research target: "a mitigated death should cost
roughly **0.5–1.5%** of lifetime progress ... and an unmitigated one **~4–5%**". Slice
fully-insured = 2.0%, i.e. **33% above the band's top edge**. Unmitigated 5% sits at the band top
(fine). The artifact acknowledges the miss implicitly ("End-state adds a promotion-analog (−30%)
to *approach* the research target band"), so it is not hiding the number — but note the end-state
ladder skips the band's middle at full stack: promo+3 lands at 0.5% (the exact bottom edge, 90%
total mitigation vs Tibia's 86%), and the last mark alone moves 1.5% → 0.5% — a 3× jump. The
marginal value of the third mark under promotion is far larger than any other purchase; expect
players to treat 2-marks-under-promo as a trap tier.

**Derivation note is NOT honest about the band.** Artifact: "the research note's literal
8%-per-blessing priced a *seven*-blessing catalogue; with a 3-mark catalogue the per-mark share
rises to keep total mitigation in the recommended **24–60% band**." The research note recommends
no such band. Its actual slice recommendation: "blessing discount **8% per blessing** with 3–5
blessings available in the slice (**max ~24–40% mitigation**), leaving room for a
promotion-analogue at **−30%** later." The "24–60%" figure splices the research's slice floor
(24%) onto Tibia's *end-state* blessing stack (7×8% = 56%, rounded up to 60%). Under the
research's real slice band, max mitigation is 40% → fully-insured slice fine would be
5% × 0.60 = **3.0%**, not 2.0%. The artifact's marks are **2.5× the per-unit potency** the
research priced (20% vs 8%), justified by a band the research never stated. The SHAPE import
claim ("additive stack, consumed-on-death, recurring sink is the load-bearing import, not the
constants") is fair — but then the derivation note should not invoke a fabricated "recommended
band" as constant-level cover. Fix: either quote the real 24–40% band and accept 3.0%
fully-insured in-slice, or own the deviation explicitly.

**Is 5% base defensible?** Yes — and better-derived than the artifact says. Research: "If the
slice's death penalty is corpse-run gear drop *plus* an exp fine, **start each component at half
strength**" (Tibia's flat low-level fine is 10%). The artifact runs both components, so 5% = half
of 10% follows the research exactly; 5% also sits adjacent to Tibia's unmitigated level-100
reality (4.5%). The artifact never cites this derivation — it just asserts 5%. Cite it; it is the
strongest number in the doc.

**Minor:** "numbers = hypotheses in `data/balance/death.json`" — that file does not exist
(`data/balance/` holds only `combat.json`). Present-tense reference to an absent artifact;
acceptable for parked fuel, but the doc should say the file lands with D2.

---

## Q2 — Degenerate strategies: the three listed, plus unlisted exploits

**VERDICT: BLOCKING** (the doc's own #1 analysis rests on an unspecified mechanic; at least four
unlisted exploits, two of them stronger than anything listed)

### The listed three, walked

**Pack-parking** — artifact: "leave two bodies idle at the nest, solo with one — body-death then
force-swaps control home and the wipe (fine) never triggers. Self-limiting (1/3 combat power,
carried loot still drops) but it does dodge the fine forever."
Walkthrough exposes a hole underneath the analysis: **body revival short of a wipe is specified
NOWHERE** — not in this doc, not in the A0 spec. A0 only says "When all three die, the pack is
wiped and respawns at the nest." So after the solo body dies, the pack is 2-strong. Then what?
- If dead bodies **never revive until wipe**: the pack attrits 3→2→1→wipe and the fine is merely
  *delayed*, so "dodge the fine forever" is **false as written**.
- If bodies **revive free at the nest**: parking dodges the fine forever, AND every exploit below
  (die-to-deposit, free teleport) becomes an infinite loop, AND the revival price becomes the real
  anti-parking lever — currently undesigned.
Either way, the doc's flagship degenerate-strategy analysis is built on a mechanic that does not
exist. That is a blocking gap: the economy cannot be priced until "how does a 2-body pack become
3 again, and what does it cost" is answered. (Also note: "carried loot still drops" is weak
deterrence — with a 10-min term in a one-zone district, the player recovers it at leisure; see Q6.)

**Suicide fast-travel** — artifact: "Priced by the fine once past the protected floor; inside the
floor, walking distances are short anyway. Watch, don't pre-fix." Analysis holds *as far as it
goes*: in a ~40×23-tile district the walk home is under a minute, so nobody rational pays 2–5% of
banked practice to skip it. But the doc misses that **pack-parking makes suicide fast-travel
obsolete**: forced-swap "snaps to the nearest living pack creature" (A0), so with two bodies
parked at the nest, a single body-death teleports control home at **zero fine, zero insurance
burn** — strictly better than the priced wipe-teleport the doc watches for. The two listed
strategies compose into an unlisted, unpriced one (X1 below).

**Banking-cadence collapse** — artifact: "if the nest is seconds from the hunting ground, carried
risk never accumulates and law 2's heartbeat flatlines. District depth vs nest distance is the
real tuning lever." Correct diagnosis, but understated: at A0's actual scale (one district,
~40×23 tiles, nest an adjacent zone) the collapse is not a risk, it is the **near-certain default
state**. Everywhere is seconds from the nest. D1's fun-verify may fail the "banking cadence felt
like a decision" gate for *map-size* reasons while the design is fine — or worse, pass it because
the owner is charitable. Flag for D1: the gate needs cadence *numbers* (see Q6 telemetry), and a
fallback plan if the answer is "the district must grow before the heartbeat exists." Also: D1
runs "No fine, no insurance yet," so during the fun-verify suicide-travel and wipes are
completely free — cadence data captured in D1 is contaminated by free-death behavior and cannot
be trusted as an economy signal.

### Unlisted exploits

**X1 — Body-death as free teleport (pack-parking × forced-swap).** Park two at the nest, hunt
solo. Want to go home / end the session / escape a bad pull? Die on purpose. Forced-swap snaps
control to the nest instantly; the fine never fires (not a wipe); your loot waits on the corpse
under a 10-minute term you can trivially beat. The doc prices suicide fast-travel via the wipe
fine and never notices that its own listed parking strategy reduces that price to zero.

**X2 — Die-to-deposit (carried-load laundering via the mule).** Law 3: "Surviving pack members
loot own-pack corpses **instantly and free**." Combine with law 1 (body-death is cheap by design)
and the transfer verb the game otherwise lacks: possessed Striker hunts deep, loaded; Blocker
parked in a safe corner nearby. When the Striker is low-HP or the load is fat, walk to the
Blocker and **die next to it** — forced-swap to Blocker, loot the Striker's corpse instantly and
free, walk home, bank. Deliberate death is now the SAFEST banking route: it converts "escape
alive with the load under pressure" (the intended tension) into "suicide adjacent to your mule"
(riskless). Cost: one dead body — whose replacement cost is the unspecified revival mechanic
(see above). Worse: the doc's own candidate mitigation for pack-parking — "leash the ally AI to
the possessed body (they hunt together...)" — **guarantees the mule is always adjacent**, making
die-to-deposit easier, not harder. The proposed fix for exploit #1 is an enabler for exploit #2.
Mitigations to evaluate: loot-transfer channel time (not instant), corpses lootable only after
N seconds of no-combat, or own-death within X tiles of an idle ally flags the load "contested."

**X3 — Per-creature protected floor × parking = 2/3 of the pack permanently fine-immune.**
"`protected_floor`: practice below tier N ... pays **0%**" — the fine is per-creature ("each
creature's banked practice pays the fine"), so the floor reads as per-creature. Parked/mule
creatures never use skills, never gain practice, never cross the floor: even when a wipe DOES
fire, only the solo creature's practice pays. The floor turns pack-parking from "dodges the fine"
into "caps the fine at one-third exposure forever." The doc never states whether the floor is
per-creature, per-skill, or pack-aggregate — that ambiguity is itself exploit surface.

**X4 — Term clocks start at body death, not at wipe: the first-dead corpse is systematically
unrecoverable.** Law 3: "term clock starts at death"; wipe section: "Three corpses persist in the
district with their loads, term clocks running" — i.e. already-running clocks. Walkthrough: Blocker
dies at t=0 holding the day's loot; you fight on, Striker dies t=5:00; last body falls t=9:00
(wipe); veil + nest respawn + re-buying marks eats ~1:00; you re-enter at t=10:00 — the Blocker's
term expired while you were in the respawn flow, through no decision you could see mid-fight. The
always-lost tier silently taxes exactly the fights the game wants (long, attritional last stands)
hardest, and it taxes the FIRST death most — usually the front-line Blocker. Either refresh all
term clocks to a floor value at wipe (e.g. min(remaining, wipe_grace)) or surface per-corpse term
remaining on the HUD post-wipe. At minimum D1 must capture the death-to-wipe stagger distribution
(Q6).

**X5 (minor) — Below-floor play has no gold sink at all.** Below the floor: fine 0%, so marks are
worthless, so nothing is ever bought; loot faucet runs (D0) and the banked stash "is NEVER taxed
by anything" (law 2). A player farming below the floor accumulates currency with literally zero
sink, then crosses the floor rich enough to hold max marks indefinitely. Feeds directly into the
Q7 structural risk.

---

## Q3 — The deliberate deviation: no purchasable loot insurance

**VERDICT: ADVISORY** (core call defensible; the argument's premise fails at exactly one tier, and
a hybrid exists there that law 5 wrongly forecloses)

The artifact's argument: "Tibia's item drop is *permanent* loss, so insurance is mercy; ours is
*recoverable-by-run* loss, so insurance would delete the signature tension."

**Attack 1 — the premise is false at the term-expiry tier.** The artifact's own law 6 defines the
always-lost tier as "consumed insurance + anything that hit corpse-term expiry." Expired loot IS
permanent loss — Tibia-shaped, exactly the tier where the artifact's own logic says insurance is
mercy, not deleted tension. And per Q2/X4, expiry is not reliably a *skill* failure: the
first-dead corpse's clock runs through the tail of the fight and the respawn/re-buy flow, so
"Loot risk is mitigated by skill (bank often, run well), never by gold" (law 5) is untrue for the
component of loot risk the player cannot act on. The dichotomy "permanent → insure, recoverable
→ don't" is sound; the artifact just misapplies it by treating ALL loot loss as recoverable when
its own design contains a permanent tier.

**Attack 2 — the premise overstates the research.** The research note never characterizes Tibia's
item loss as permanent; it says only "On death you drop items; the chance depends on the number
of blessings acquired — the item-loss-chance-by-blessings table was lost in export." Tibia
corpses are lootable by anyone and decay — loss is *usually* permanent because of other players
and corpse decay, i.e. for exactly the reasons (PvP looting, term expiry) whose analog here is...
the corpse term. The cleaner statement of the artifact's real position: Tibia's recovery odds are
adversarial and low, ours are solo and high, so drop-chance insurance would be paying to skip a
walk. That version survives; the "permanent vs recoverable" version as written does not.

**The hybrid law 5 wrongly forecloses: term insurance.** A purchasable mark that extends or
freezes `corpse_term_frames` (or, stronger: one insured corpse's load survives expiry and waits
at the nest) insures ONLY the permanent tier while leaving the run 100% intact — you still must
walk back, humans still respawned, tension untouched. It also gives the below-floor player a
reason to visit the retail loop (partially patching Q2/X5) and converts X4's silent
stagger-expiry from an unfair loss into a priced choice. "Deliberately absent: any purchasable
loot insurance (rejected by law 5)" is scoped too wide; rescope law 5 to "no purchase can reduce
the drop or skip the run" and the signature tension is fully preserved. Second-choice hybrid
(closer to the research's "e.g. 100%/50%/25%/10%/0% container-drop chance" suggestion, weaker
here): a Grim-Dawn-style partial — an insured *fraction* auto-banks on wipe — but this genuinely
does dilute the run, so rejecting it is fine.

---

## Q4 — Two-tier structure: where does the tension actually concentrate?

**VERDICT: BLOCKING** (pressure profile is free / free / cliff, and the wipe fine inverts into a
voluntary pack-repair fee)

**The stakes ladder as designed.** Death 1: tempo (20f stagger), −1/3 combat power, load on a
10-min recoverable term. Death 2: same again. Death 3: the fine, three corpse runs, insurance
burn. Marginal economic cost by death: **~0, ~0, everything**. The artifact's fun thesis "losing
a body should sting" is not delivered by the economy — body-death stings only in tempo and
combat power, both of which A0 already had for free ("A0's death loop is structurally free," the
doc's own words). The only *new* body-death stake this doc adds is carried-load-at-risk, and Q2/X2
shows that stake is invertible into a banking convenience, while Q6 shows the 10-min term in a
~40×23 district makes recovery near-certain. Net: the two-tier structure as priced concentrates
ALL added tension on the last living body. That can be good drama (a climax), but it means the
doc's tier-1 design goal is unmet as specified — law 1's "only that body's carried load is at
risk" is a stake worth approximately zero at A0 scale.

**The inversion the doc never prices: the wipe is also the pack's only repair verb.** Neither
this doc nor the A0 spec specifies any way to revive a dead pack member short of wiping (see
Q2). Therefore a pack at 1/3 strength faces: keep hunting at one-third power, or *deliberately
wipe* — pay the fine, respawn at 3/3, run back for the corpses (trivial, per Q6). The fine is no
longer a deterrent; it is the **price of a full heal**. Concrete walkthrough: two bodies down,
their corpses looted already (own-pack looting is instant/free), last body carries nothing (just
banked). Wipe cost = 5% × (three creatures' banked practice) uninsured, 2% insured, **0% below
the protected floor** — vs the benefit of restoring 3× combat power and hunting throughput.
Early game (small practice totals, or below floor) the trade is free-to-trivial, so the dominant
line is: spend bodies aggressively, and when the pack is degraded, suicide the last body from a
loot-empty state. The doc watches "suicide fast-travel" but the real degenerate sibling is
**suicide pack-reset**, which is *more* attractive (it buys combat power, not just position) and
is unlisted. Any fix must price pack-restoration separately from position-reset — e.g. a
per-dead-body revival fee at the nest (which simultaneously fills the Q2 revival gap and gives
the below-floor economy its missing sink), or scale the fine by bodies-already-down so a
run-it-down wipe costs more than a fighting wipe.

**Secondary interaction, flag for D1 feel:** forced-swap "snaps to the nearest living pack
creature" (A0) — the all-stakes final stand is frequently in whichever body happened to stand
closest, e.g. a low-HP Lobber. Economy-neutral, but it decides whether the concentrated tension
reads as climax or as coin-flip. D1 capture should tag which kit was last-alive at each wipe.

---

## Q5 — "No death is free" vs the protected floor

**VERDICT: ADVISORY** (law 6 is contradicted by the doc's own floor; textual fix available, but the
behavioral consequence feeds two blocking findings)

Law 6 claims: "**No death is free; no death bricks you.** Always-lost tier: consumed insurance +
anything that hit corpse-term expiry." Same law, two sentences later: "below a protected practice
threshold the wipe fine is **zero**."

Walk the below-floor wipe: fine = 0% (floor). Consumed insurance = 0 (a rational below-floor
player buys no marks — they mitigate a fine of zero; nothing to consume). Corpse loads = fully
recoverable within a 10-minute term that is many times the district crossing time (Q6). Recover
all three inside the term and the wipe's total economic cost is **exactly zero** — the only
residue is tempo and walk time, which the doc itself classifies as no stake at all: "A0's death
loop is structurally free: possessed death → forced-swap (tempo loss), wipe → nest respawn (time
loss). Nothing is *owned*, so nothing is *at stake*." By the doc's own definition of free, the
below-floor recovered wipe is free. Law 6's first clause is false below the floor.

Why: the research's always-lost mechanism is *conditional on purchase* — "keep one always-lost
tier (Tibia's AoL + blessings are themselves consumed [9]) so no death is ever completely free" —
and purchase never happens below the floor. The other always-lost leg (term expiry) is
opt-out-by-walking at A0 scale. The floor itself is fine (canon-locked accessibility, Tibia's
post-Newhaven precedent is real); the *claim* is what's wrong. Fix: reword law 6 to "no
**priced-tier** death is free" and state openly that below the floor, death costs time only —
that is the accessibility trade, own it. Note the behavioral consequences are already counted
elsewhere: free below-floor wipes are the zero-cost regime for suicide pack-reset (Q4) and the
no-sink economy (Q2/X5, Q7).

**Adjacent trap worth its own line:** insurance marks are "pack-level, consumed on wipe ... (all
of them, regardless of count — Tibia's AoL rule)." A below-floor player who buys marks anyway
(new players buy insurance; that is what insurance UX trains) has them consumed on wipe for
**zero benefit** — the retail loop takes a newbie's money for nothing. Either block/warn mark
purchase below the floor, or don't consume marks when the fine is 0%.

---

## Q6 — Corpse term (10 min) vs district depth; D1 telemetry

**VERDICT: ADVISORY** (number is toothless at A0 scale and structurally wrong-shaped for growth;
explicitly a hypothesis behind a fun-verify, so tuning-tier — but D1 must capture the right data,
and one unspecified sim question changes the answer entirely)

Artifact: "`corpse_term_frames`: **36,000f (10 min)** per corpse, hypothesis. Term survives human
respawns; expiry destroys the load." Law 3: "Distance is the difficulty; humans have respawned;
you are re-armed but empty-handed."

**Is recovery realistically possible? Yes — trivially.** The district is ~40×23 tiles (A0
pathing note). Even at a slow 20 frames/tile, a full-length crossing is ~800f ≈ 13 s at 60fps;
call a fighting run-back with respawned Rushers 1–2 minutes to the far corner. The pack respawns
"re-armed" (kits are innate) at full combat power against A0's weakest enemy tier ("Melee mooks
at existing-husk grade"). A 10-minute term is roughly **5–10× a worst-case recovery**, so at A0
scale expiry essentially never fires from the run itself. The term only bites through two side
channels: (a) the Q2/X4 stagger — clocks start at *body death*, so a long attritional fight plus
the respawn/re-buy flow can burn most of the first corpse's term before the run even starts; and
(b) chained failure — wipe again mid-run and corpse #1's remaining term must now also cover a
second veil/respawn cycle plus a second fight; that is the actual death-spiral membrane and it is
invisible in the doc.

**District-depth interaction — the constant is the wrong shape.** 10 minutes is
district-size-invariant, but recovery time scales with district depth, and "nest advance /
district progression" is already queued (A0 spec, A1+ list). The same constant that is toothless
at 40×23 becomes a hard wall in a district 4× deeper with Shooters, with the X4 stagger consuming
the front of it. Recommendation the doc should carry: express the term as a *multiple of measured
recovery time* (e.g. term ≥ 3× median wipe-to-last-corpse recovery, floor 10 min), tuned per
district, not a global frame constant.

**Unspecified sim question that decides everything: does the term tick while the player is in the
nest zone?** The doc mandates "No wall-clock time anywhere in the term logic" and "all sim state,
all frame-quantized" — but nest and district are separate zones. If the district sim pauses while
the player is at the nest, the term freezes during shopping → waiting at the nest is free and the
term never pressures the respawn flow (also: deliberately idling at the nest becomes term-pause).
If it ticks, menu/retail time silently eats the first corpse's term (amplifies X4). Either choice
is defensible; not choosing is not. D1's `corpse_run.json` capture ("term-expire one corpse
deliberately") will encode one behavior by accident if this isn't decided first.

**D1 fun-verify telemetry (concrete, all derivable from the deterministic replay):**
1. Per-corpse stagger: `wipe_frame - body_death_frame` distribution (X4 exposure).
2. Respawn overhead: `district_reentry_frame - wipe_frame` (includes veil + nest time; split out
   retail time once D2 lands).
3. Per-corpse recovery margin: `term_remaining_at_loot / corpse_term_frames` — the tuning number.
   If median margin > 0.7, the term is set dressing; target something like 0.3–0.5 on the
   deepest corpse.
4. Recovery success rate by death order (first-dead vs last-dead corpse) — detects the X4 bias.
5. Flow-field distance nest→corpse at wipe time (depth exposure, for the term-as-multiple rule).
6. Banking cadence: frames between bank events; carried value at bank vs carried value at death
   (is the "bank now or push" decision real — the law 2 heartbeat, Q2 collapse check).
7. Second-wipe-during-recovery-run frequency (death-spiral membrane).
8. Which kit was last-alive at wipe (Q4 climax-vs-coin-flip check).
Plus the caveat from Q2: D1 has "No fine, no insurance yet," so all D1 death-frequency and
cadence numbers are upper bounds on recklessness, not economy signals.

---

## Q7 — Biggest unconsidered economic risk

**VERDICT: BLOCKING** — **the economy has exactly one sink, that sink saturates, and the signature
tension is denominated in the currency the sink is supposed to keep scarce.**

The doc's own words: insurance marks "are the death economy's recurring gold sink — the
consumed-on-wipe property is what makes them an economy instead of a checkbox." Singular sink,
and its throughput is wipes/hour × mark_cost — a rate the *player* controls and that **skill
drives toward zero**. Meanwhile the faucet (D0: "humans drop the currency") runs continuously
during all play, and law 2 guarantees the reservoir never drains: "The banked stash is NEVER
taxed by anything."

Steady state, walked: a competent player wipes rarely (that is the design goal — "The wipe is
*economic* (rare, priced)"). Income per hunt outgrows 3 × mark price within days, after which the
player holds max marks permanently and re-buys from petty cash. At that point:
- Insurance is exactly the **checkbox** the doc says the consumed-on-wipe property prevents —
  consumption without scarcity is a checkbox with a ritual attached.
- Marginal banked currency has **zero utility** — nothing else in any doc buys anything ("The
  retail loop (needs a currency)" names no second product; "Deliberately absent" rules out gear).
- Therefore marginal *carried* loot has zero utility — and carried loot is the entire stake of
  the tactical tier and the corpse run. "Push to recover the Blocker's load under pressure, or
  cut losses" is only a decision while the load is worth something. **The corpse run ends up
  guarding a worthless cargo**; the signature tension quietly dies of inflation, not of any
  exploit. Tibia never hits this state because death stays frequent at all levels, blessing
  prices scale with level, and the *real* sink is consumables — "loot and consumable waste are
  split by a party-hunt analyzer" (research §1); hunts can lose money. Game-two has no supplies,
  no repair, no scaling price, no second sink anywhere in the corpus.
- Compounding: mark price is **unspecified** while the fine is a % of banked practice — so the
  insured value grows with progression against a (presumably) flat price. Buying marks stops
  being a decision the moment 3 × mark_price < the expected practice-loss delta; for any flat
  price there is a progression point past which not-insuring is simply an error. A no-decision
  purchase is not an economy either.

The doc thought hard about players *dodging* the sink (parking, floor camping) and not at all
about players *out-earning* it — the second is the certain one; it happens to every player who
plays well. Fixes to evaluate at D2, in rough order of leverage: price marks as a % of the
practice they insure (self-scaling, Tibia-shaped); add the body-revival fee (also closes Q2's
revival gap and Q4's free pack-reset); make the term-insurance hybrid from Q3 a second
consumable; and give D0 a second faucet-side want (anything banked currency chases — nest
upgrades, gambit slots at A1 — so long as law 2's "never taxed" survives, spending must be the
drain).

---

## Summary

| Q | Verdict | One-line |
|---|---|---|
| Q1 | ADVISORY | Math exact (2.0%); derivation note cites a "24–60% band" the research never stated (real slice band 24–40% → 3.0%); 5% base is defensible and under-cited (half-strength rule). |
| Q2 | BLOCKING | Pack-parking analysis rests on an unspecified body-revival mechanic; unlisted exploits X1 (free teleport), X2 (die-to-deposit mule), X3 (per-creature floor immunity), X4 (term-stagger eats first corpse), X5 (no sink below floor). |
| Q3 | ADVISORY | "Recoverable-by-run" premise fails at the term-expiry tier (permanent loss, Tibia-shaped); term-extension insurance is a hybrid law 5 wrongly forecloses. |
| Q4 | BLOCKING | Stakes are ~0 / ~0 / everything; with no revival verb, the wipe fine inverts into a cheap full-pack repair fee → suicide pack-reset dominates. |
| Q5 | ADVISORY | Below-floor recovered wipe is exactly free by the doc's own definition — law 6's "no death is free" is false there; below-floor mark consumption is a newbie trap. |
| Q6 | ADVISORY | 10-min term ≈ 5–10× worst-case recovery at A0 scale (toothless); wrong-shaped constant for district growth; nest-tick behavior unspecified; 8-point telemetry list for D1. |
| Q7 | BLOCKING | Single sink saturates against a continuous faucet + never-taxed reservoir → insurance becomes a checkbox and the corpse run guards worthless cargo; mark price unspecified vs %-scaled fine. |

**Totals: 3 blocking / 4 advisory.**
