# Adversarial contract-compliance review — death-economy-design.md (critic A)

Reviewed: `docs/design-corpus/death-economy-design.md` (2026-08-09)
Contracts: design-review-reconciliation.md (5 laws + standing owner directions) · A0 spec ·
PARKING_LOT.md · world-bible §5.3/§5.4/§13/§14.2/§14.3 · SLICE_SPEC.md STATUS header ·
CLAUDE.md scope contract v3. Repo state checked: `data/balance/` contains only combat.json
(no death.json); `harness/scripts/` has no corpse_run.json; controls are WASD/J/K/Tab/Esc
(no interact verb); harness input schema = `hold` lanes + `frames` + `seed`.

---

## Q1 — The 5 design laws (esp. law 1 A0-scope, law 3 determinism, laws 4-5 combat clocks)

**VERDICT: PASS** (two advisories, logged under Q7/roll-up as A7).

- **Law 1 (A0 = possession core ONLY):** honored. The artifact self-declares out of A0:
  artifact — "PARKED FUEL — docs-only. Nothing here starts until the owner fun-verifies the
  current loop and promotes an increment via the scope contract (PARKING_LOT rule)." Nothing
  in it is slated to ride into A0; the only A0 reference is descriptive ("already visual
  since A0"), matching the spec's carried critique fix "corpses persist (fade, don't
  vanish)". Scavenger humans, aggression scaling, promotion-analog all explicitly staged D3+
  or flagged "A2 pull-economy territory".
- **Law 3 (determinism):** honored on its face. Artifact — "Corpse entities, term clocks,
  carried/banked ledgers: all sim state, all frame-quantized, all serialized in replays…
  No wall-clock time anywhere in the term logic." `corpse_term_frames: 36,000f` is
  frame-quantized. Byte-identical gate extended to the new script. (But see Q2/A2: the
  section claims law-3 application while omitting a required input-schema growth.)
- **Laws 4-5 (combat clocks):** not touched, not contradicted. The new clocks introduced
  (corpse term clocks) are corpse-owned sim state — swap-inert by construction. The wipe
  economics fire strictly after the reconciliation's law-2 flow ("All three dead → veil →
  respawn at nest (unchanged). THEN the economy fires") — extends, doesn't alter.
- **Advisory (A7a):** the candidate mitigation "leash the ally AI to the possessed body"
  would, if promoted, break law 1's "ally AI at existing-husk grade" and the A0 spec's
  deliberate "No retreating, no coordination" husk design. The artifact does say "Decide
  with data, not upfront" — compliant as written, but the doc should mark that this
  particular candidate is a *spec change to ally AI*, not a balance knob.
- **Advisory (A7b):** the artifact spawns a new increment track (D0-D3) parallel to the
  reconciliation's A1-A3 queue ("Gambits/Shooters/pull economy/nest advance = A1-A3") and
  never states how the two tracks order. Two competing "next increment" queues is exactly
  the multi-increments-in-a-trenchcoat failure the review existed to stop. Not a violation
  (parking-lot items need no sequencing), but the promotion decision will need an explicit
  D-vs-A ordering call the doc pretends doesn't exist.

## Q2 — Contradictions with A0 spec decisions

**VERDICT: ADVISORY** (no contradiction found; one material omission).

- **Forced-swap semantics:** consistent. Artifact — "Forced-swap / ally-down flow unchanged
  from A0." Spec — "control snaps to the nearest living pack creature with a short
  action-lock stagger". No collision.
- **Wipe→nest flow:** consistent. Artifact — "All three dead → veil → respawn at nest
  (unchanged)." Spec — "Wipe (all three dead) → veil → pack respawns at nest." The artifact
  adds a post-respawn economy step, which extends rather than contradicts the spec's
  "world → nest_respawn" state machine.
- **Husk-grade ally AI:** no contradiction as written (see A7a above for the leash
  candidate).
- **Harness schema — THE OMISSION (A2):** the artifact's corpse recovery requires a player
  verb that does not exist anywhere: artifact — "lootable by surviving pack members (walk
  adjacent + interact)". Controls are "WASD / arrows = move · J / Space = attack ·
  K / Shift = dodge · Tab = swap possession · Esc = quit" — there is no interact input, no
  `interact`/`loot` lane in the harness schema (verified: scripts carry `hold` lanes +
  `frames` + `seed` only), and the A0 spec's schema growth covers only "a swap lane
  (`"swap"` in `hold`) + a `seed` field". Yet the artifact's determinism section — titled
  "law 3 of the review, applied" — specs `corpse_run.json` ("die loaded → wipe → run back →
  recover…") without declaring the input-lane growth its own script needs. Law 3's whole
  point (review: "Harness input schema must grow a possession lane with byte-identical
  regression kept") is that new verbs declare their harness lane up front. Either looting
  is adjacency-automatic (then say so — it changes the mid-hunt "push to recover" decision
  feel) or an interact lane must be in the D1 spec. Same gap applies to the D2 insurance
  purchase (a nest interaction needs an input path and UI; A0's HUD law is "Three HP bars…
  Nothing else"). ADVISORY because the doc is parked fuel, not a promoted spec — but its
  determinism section claims a compliance it doesn't fully deliver.

## Q3 — Bible canon (§5.3/§5.4/§13/§14.2)

### (a) Insurance mark vs canonical blessings/passage-scrolls — **VERDICT: PASS** (one advisory)

The mark's mechanical shape matches canon closely: bible — "temples sell blessings,
toll-credits inscribed on the strands in advance, **each absorbing a share of the loss**
before the gate takes the rest… The poor buy one cheap blessing; the rich walk in
quintuple-blessed." Artifact — "each cut the fine additively", "consumed on wipe". Additive
share-absorption, multi-stacking, consumed-per-passage: all canon-compatible. Better: the
artifact's law 5 ("No purchase can insure the loot") aligns WITH canon against the research
note — canonically blessings mitigate the Toll (practice), never item loss; items ride the
corpse-term. The seller question is properly deferred ("Who sells insurance to monsters is a
fiction question (order form)"), with §10.3 flagged but left to the bible session — correct
under §14.4's extension protocol.

- **Advisory (A6):** canon blessings are **per-soul strand inscriptions** ("inscribed on the
  strands"); the artifact's marks are "pack-level, consumed on wipe" while the fine hits
  "each creature's banked practice" — per-creature tax, pack-level mitigation. Reconcilable
  if the marks ride the possessing entity's strands (the wipe IS framed as "the
  player-entity's own Half-Passage"), but then whose practice do the gates eat — the
  entity's or the creatures'? The doc taxes creatures and insures the pack without noticing
  the strand-anatomy mismatch. Fiction-deferrable; should be an explicit order-form clause.

### (b) Term-expiry destroys loot vs the ten-day term — **VERDICT: PASS** (one advisory)

Canon: goods "remain yours **in the court's eyes** for a term (custom: ten days; looters
inside the term are cursed…, which has never once stopped them)". Canon term expiry ends the
LEGAL claim (goods become fair game for looters and "the wild dead"); it does not say goods
evaporate. Artifact: "expiry destroys the load (the abstract scavengers of the world)" —
destruction-as-abstraction of post-term scavenging, and the doc itself pre-reconciles it:
D3's "scavenger humans that loot corpses (turns term expiry from a timer into a visible
drama)" plus "looters-inside-the-term-are-cursed gives scavenger humans (D3) their fiction
for free". That is a legitimate mechanics-first abstraction under §13's rule ("mechanics may
be added freely; fiction may not be contradicted") — the fiction row to be ADDED can carry
it. **Advisory (A5):** ten days (human funerary *custom*, §5.3) vs `corpse_term_frames` =
"36,000f (10 min)" — a 1440x scale change. Canon-writable (custom ≠ cosmic law, and the pack
game adds its own row) but the doc never acknowledges the delta; the bible session should be
handed "why is the monster-side term minutes, not days" explicitly, or §13's existing
"ten-day term" row reads as contradicted rather than paralleled.

### (c) Accessibility floor — **VERDICT: BLOCKING (B1) — canon mis-citation**

The floor is honored mechanically (never bricked — good), but the doc claims canon support
for a mechanic canon textually contradicts. Artifact law 6: "Accessibility floor (**bible
canon** — the minimal rite is doctrinally *sufficient*): respawn is never blocked, the
uninsured fine is capped, and **below a protected practice threshold the wipe fine is
zero**." And order form item 5 asks the bible for "The protected floor — **the doctrine that
new/weak things pass free**."

Canon says the opposite about free passage, verbatim (§5.3): "**Nothing crosses any part of
the Undervault free — not even a soul turning back.**" and "The Toll is proportional, lawful,
**non-negotiable** — and prepayable." The canonical accessibility floor is a different
guarantee entirely: "the minimal rite (a drop of river-water, one spoken name, a crumb) is
doctrinally guaranteed *sufficient*, if not comfortable" — sufficiency of the RITE (you get
back, poverty never blocks the passage), not zero Toll. §13's blessing row confirms: "The
minimal rite is doctrinally guaranteed sufficient — the accessibility floor is canon" — in
the row about *reducing* death loss, never zeroing it.

Why BLOCKING and not advisory: the mis-citation propagates. D2's fine structure
(`protected_floor` pays 0%) is presented as canon-backed, and order form item 5 instructs the
bible session to author a free-passage doctrine — which would collide head-on with §5.3 and
arguably with §14.2's "The Debt never clears." Cheap fix, canon-native: the floor can be
fiction'd as a standing prepayment (canon's own device — e.g., a charity blessing that covers
the weak, "the poor buy one cheap blessing" scaled to doctrine), so the gate still takes its
fee and someone else pays. But the doc must stop asserting the zero-fine floor IS bible
canon, and item 5 must ask for a *prepayment/patronage* fiction, not a free-passage doctrine.

### (d) Permadeath lock — **VERDICT: PASS**

Artifact law 7: "Permadeath never. Canon-locked (§13): true annihilation is a court verdict
in story content only. No mechanic in this doc can invoke it." Matches §13 ("True
annihilation exists only as a *court verdict* in story content… Canon-locked.") and §14.2
("True permadeath is a verdict, never an accident."). "Deliberately absent" re-confirms.
Nothing in the doc (incl. term-expiry destruction — items, not souls) approaches the Maw.

## Q4 — PARKING_LOT promotion discipline / smuggled commitment

**VERDICT: PASS** (two advisories)

The discipline is honored in the letter and mostly in spirit. Artifact header: "PARKED FUEL —
docs-only. Nothing here starts until the owner fun-verifies the current loop and promotes an
increment via the scope contract (PARKING_LOT rule)." Staging header: "each behind its own
fun-verify; promotion via scope contract only." D2 honestly declares its parked dependency
("blocked on skill-through-use landing (practice must exist to be taxed)"). No code exists
(verified: no `data/balance/death.json`, no `harness/scripts/corpse_run.json` in the repo).
CLAUDE.md's OUT-of-scope list still parks "corpse-run, stamina, loot, XP/skills" — uncontradicted.

- **Advisory (A8) — present-tense phantom artifacts.** "numbers = hypotheses in
  `data/balance/death.json`" and "New capture script `harness/scripts/corpse_run.json`…
  The byte-identical gate extends to it **permanently**" read as existing/committed
  artifacts. Neither file exists. Naming future files is fine; present-tense "the gate
  extends to it permanently" is commitment language for an unpromoted increment. Same
  flavor: "this doc only fixes the interface: per-creature `carried[]`, nest `banked[]`" —
  pre-binding D0's data structures from a parked doc while claiming D0 "needs its own tiny
  design pass". Cheap fix: future-tense + "on D1 promotion".
- **Advisory (A3) — no PARKING_LOT cross-link.** The world-bible precedent got its own
  parking-lot entry ("docs-only — no code until fun-verify, then only via scope-contract
  update"); this doc realizes the parked item "Corpse-run gear drop (kethral's signature
  death tension — top candidate)" but PARKING_LOT.md carries no pointer to
  `death-economy-design.md`. A 4-stage roadmap living only in design-corpus, unreferenced
  from the lot it claims to obey, is how shadow roadmaps form. One appended line fixes it
  ("Append freely" is explicitly allowed).

## Q5 — De-slop: spec-speak only, fiction deferred to the order form?

**VERDICT: PASS** (one advisory)

The doc opens with its own naming-discipline clause and holds to it. Sweep of every name:
`carried`/`banked`, corpse container, corpse term, wipe, fine, insurance mark, protected
floor, Blocker, nest, district, D0-D3, pack-parking / suicide fast-travel /
banking-cadence-collapse — all internal spec-speak, none player-visible, and every
player-facing handle has an order-form item (wipe, mark, currency, term, floor, banking = 6
items). Reference-wall citations (Tibia AoL, post-Newhaven shield, Skyrim/Oblivion) are
touchstones, not names. "veil" is inherited verbatim from the A0 spec's wipe flow, not
introduced here.

- **Advisory (A9) — one pre-bound fiction name.** Artifact: "the run back IS the corpse
  run… Bible fiction slot: **'the walk of shame and iron.'**" That name is §5.3's fiction
  for the HUMAN-side errand ("Recovering your own corpse… is an ordinary, expected,
  dangerous errand of Suvarethi life: the walk of shame and iron"). The doc's own
  bible-binding section says the pack game "adds NEW rows when fiction binds" and that the
  monster-side reading "is the bible session's call" — yet here it pre-assigns the
  human-side name to the monster-side run instead of listing it as an order-form question.
  Not slop (it is bible-native), but it jumps the bible session's call, and "shame and iron"
  is human anthropology (gear = iron, shame = funerary social code) that may not survive
  translation to a possessing entity looting its own vessels. Should read "candidate,"
  and/or become order-form item 7.

## Q6 — "Designing for the A0 pack game, not the superseded hero slice" — is that reading correct?

**VERDICT: PASS**

Verified against the repo. SLICE_SPEC.md header: "**STATUS: fun-verified 2026-08-09 and
superseded.** The active spec is `docs/superpowers/specs/2026-08-09-a0-possession-core-design.md`
(monster flip, A0 = possession core). This file stays as the record of the shipped grid
slice." CLAUDE.md scope v3: "direction locked = **monster flip**". The parked item the doc
realizes ("Corpse-run gear drop (kethral's signature death tension)") was conceived
hero-side; the artifact correctly re-derives it monster-side (two-tier death, pack corpses,
entity-persistence) instead of porting the hero mechanic. The artifact's framing — "for the
game that exists **after the monster flip** — the A0 possession game — not for the superseded
hero slice" — is an accurate reading of repo state. One honest nit inside the PASS: the
parked promise is *gear* drop, and this design ships currency-only ("Equippable gear per
creature… deliberately absent"); D1's fun-verify is therefore testing a weaker loss-substrate
than the parked item names. The doc's container design being "gear-proof" covers the
mechanics, but the owner should know D1 tension is currency-tension, not gear-tension.

## Q7 — Biggest contract risk the author has NOT thought of

**VERDICT: BLOCKING (B2) — partial-pack death recovery is unspecified, and every possible
answer breaks either bible canon or the doc's own economy.**

The doc specs body-death and the full wipe exhaustively — and never says how a dead-but-not-
wiped creature comes back to life. Trace it: possessed/ally body dies → "its carried load
transfers to its corpse entity", forced-swap fires, hunt continues. If the remaining pack
then walks home WITHOUT wiping — the ordinary, most common outcome of a rough hunt — the doc
is silent. The A0 spec is equally silent ("When all three die, the pack is wiped and
respawns"; nothing on partial recovery). Every branch is a contract problem:

1. **Dead creature revives at the nest, no wipe, no fine** → a free resurrection. Canon §5.3,
   verbatim: "**Nothing crosses any part of the Undervault free — not even a soul turning
   back**… The Toll is proportional, lawful, non-negotiable." The doc's law 1 ("Body-death is
   *tactical* (frequent, cheap)") prices body-death at zero practice — defensible only if
   body-death is not a soul-passage at all. But the fine's own target contradicts that: it
   taxes "**each creature's** banked practice", and canon makes practice a *soul*-property
   ("Practice is a soul-property the khelet banks by doing — the strands record what the
   hands repeat — which is why the gates can tax it"). If each creature banks practice, each
   creature has strands, and each body-death→revival is an untolled Half-Passage — head-on
   canon collision. If instead the bodies are soulless vessels (the canon-native fix:
   provisional bodies "grown in the Silt Mothers' vat-gardens" — only the possessing entity
   is a soul, only the wipe is a passage), then **per-creature practice pools are canonically
   impossible** and D2's fine structure ("Each creature's banked practice pays the fine") is
   taxing something that can't exist. Either reading invalidates one of the doc's two tiers.
2. **Dead creature stays dead until the next full wipe** → pack-parking inverts: the doc's
   own degenerate-strategy note claims "body-death then force-swaps control home and the
   wipe (fine) never triggers… it does dodge the fine forever" — but a permanently-dead solo
   body means the strategy self-terminates at 0 living bodies, i.e. a wipe. The analysis as
   written assumes an unstated revival path. Worse, permanent-until-wipe attrition makes a
   2-body or 1-body pack the normal play state, which no fun-verify in D1/D2 covers, and
   drifts toward "death bricks you" — the doc's own law 6 ("no death bricks you").
3. **Voluntary revival verb at the nest (pay to re-grow a body?)** → a fourth economy no
   order-form item, no staging gate, and no law covers.

Why this is the biggest one: it sits at the seam of ALL the contracts at once — the fine's
target (canon strand-anatomy, §5.3), law 1's two-tier pricing, the pack-parking analysis,
law 6's no-bricking floor, and the A0 spec's respawn state machine — and no fiction order-form
item asks the bible session to resolve it (item 1 covers losing all three; nothing covers
losing one). Must be answered in the doc BEFORE D1 promotion, because `corpse_run.json`'s
scripted scenario ("die loaded → wipe → run back") conveniently only exercises the full-wipe
path — the capture script inherits the same blind spot.

**Secondary unthought risk (Advisory, A10):** D2's "retail loop" ("Insurance marks are
bought at the nest with the loot currency") is a shop plus a wallet — and "shops, inventory"
are their own parked Kethral items in PARKING_LOT.md, distinct from the corpse-run item this
doc promotes. D2's promotion therefore silently promotes up to three parked items at once
(corpse-run + skill-through-use [acknowledged] + shops/inventory [not acknowledged]). The
scope-contract update at D2 promotion needs to name all three.

---

## Roll-up

| ID | Verdict | Where | One-liner |
|---|---|---|---|
| B1 | BLOCKING | Q3c | "Below a protected threshold the wipe fine is zero" asserted as bible canon; §5.3 says "Nothing crosses any part of the Undervault free… non-negotiable." Canonical floor = minimal-rite sufficiency, not zero Toll. Order-form item 5 as written commissions canon-breaking fiction. |
| B2 | BLOCKING | Q7 | Partial-pack death recovery unspecified; free revival breaks §5.3's Toll, per-creature practice breaks strand-anatomy, stay-dead breaks pack-parking analysis + law 6. No order-form item covers it; corpse_run.json script shares the blind spot. |
| A2 | ADVISORY | Q2 | Corpse looting needs an interact verb + harness input lane that exist nowhere (controls, A0 schema growth = swap+seed only); determinism section claims "law 3 applied" without declaring it. |
| A3 | ADVISORY | Q4 | PARKING_LOT.md has no pointer to this doc — shadow-roadmap risk. |
| A5 | ADVISORY | Q3b | Ten-day canon term vs 10-min `corpse_term_frames` (1440x) never acknowledged; bible session needs the delta handed to it explicitly. |
| A6 | ADVISORY | Q3a | Marks are pack-level but the fine is per-creature; canon blessings are per-soul strand inscriptions. Whose strands carry the marks is undefined. |
| A7a | ADVISORY | Q1 | "Leash the ally AI" mitigation candidate is a husk-grade/law-1 spec change, not a balance knob — should be labeled as such. |
| A7b | ADVISORY | Q1 | D0-D3 track vs the reconciliation's A1-A3 queue: two parallel "next" queues with no ordering statement. |
| A8 | ADVISORY | Q4 | Present-tense commitment language for phantom artifacts (death.json, corpse_run.json "gate extends to it permanently", D0's `carried[]`/`banked[]` interface pre-bound). |
| A9 | ADVISORY | Q5 | "The walk of shame and iron" (human-side §5.3 fiction) pre-assigned to the monster-side run; should be an order-form question. |
| A10 | ADVISORY | Q7 | D2 retail silently promotes parked shops/inventory alongside corpse-run and skill-through-use. |

**Totals: 2 blocking / 9 advisory.** Q1 PASS · Q2 ADVISORY · Q3 a/b/d PASS, c BLOCKING ·
Q4 PASS · Q5 PASS · Q6 PASS · Q7 BLOCKING.
