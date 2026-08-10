# Death economy — corpse run, the wipe tax, and insurance (design fuel)

**Date:** 2026-08-09 (rev. same day after 3-critic adversarial panel — reports in
`drafts/_dcrit-{a,b,c}.md`, adjudication in `drafts/_dcrit-adjudication.md`) ·
**Status:** PARKED FUEL — docs-only. Nothing here starts until the owner fun-verifies the
current loop and promotes an increment via the scope contract (PARKING_LOT rule). This doc
realizes the parked item "Corpse-run gear drop (kethral's signature death tension)" for the
game that exists **after the monster flip** — the A0 possession game — not for the superseded
hero slice. (Honest delta: the parked promise says *gear* drop; this design ships
currency-tension, not gear-tension — equippable gear doesn't exist and stays out of scope.
The owner should know D1 tests the weaker substrate.) Binding upstream: the 5 design laws
(`design-review-reconciliation.md`), the A0 spec
(`docs/superpowers/specs/2026-08-09-a0-possession-core-design.md`), world bible §5/§13
(`docs/lore/world-bible.md`), and the research note
`death-penalties-stat-scaling-and-progression-balance` (vault, game-research domain).

**Ordering vs the A1–A3 queue:** D0–D3 is a *parallel candidate track*, not a replacement.
The reconciliation's A1 (gambits) / A1+ (Shooters) / A2 (pull economy) / A3 (nest advance)
queue still stands. Which track goes next after a fun-verify is an explicit owner call at
promotion time; nothing here presumes D0 outranks A1.

## Naming discipline (de-slop rule, owner-set)

Every name below is **internal spec-speak**, never player-visible. Fiction binds later via the
order form at the end, answered from inside the bible. Slop test applies: a name that could
ship in another game unchanged stays spec-speak.

## The problem

A0's death loop is structurally free: possessed death → forced-swap (tempo loss), wipe → nest
respawn (time loss). Nothing is *owned*, so nothing is *at stake*. Kethral's signature tension —
the walk back to your own corpse — needs three substrates the pack game doesn't have yet: things
to carry (loot), things to bank (stash), and things to lose (practice and bodies). This doc
designs the end-state economy, then stages it so each piece lands behind its own fun-verify.

**Fun thesis:** *losing a body should sting; losing the pack should cost; going back should be
the tensest walk in the game.* Death prices the hunt without ever bricking it.

## The soul model (the load-bearing decision; canon-derived)

**The possessing entity is the only soul in the pack. The three creatures are soulless
vessels.** Canon-native reading: provisional bodies in the bible are vat-grown by the Silt
Mothers (§5.3, §10) precisely so that a soul can wear flesh it didn't die in; the pack's
bodies are that device, monster-side. Everything downstream follows:

- **Practice belongs to the entity**, banked per kit-discipline (Blocker-work, Striker-work,
  Lobber-work), not per creature. Canon requires this: "practice is a soul-property the
  khelet banks by doing" (§5.3) — vessels have no strands to bank on. Design consequence:
  there are no per-creature practice pools to hide from the fine (kills the parked-mule
  floor-immunity exploit, panel finding B-X3).
- **Body-death is not a soul passage.** The entity never enters the corridor when a vessel
  dies — it moves to another vessel (forced-swap). No Toll is owed, so body-death carrying no
  practice fine is canon-clean. Only the **wipe** — all vessels gone, the entity itself
  unhoused — is the entity's own Half-Passage, and only the wipe meets the gates.
- **Insurance marks are inscribed on the entity's strands** (canon shape: blessings are
  per-soul strand inscriptions, §5.3), mitigating the entity's fine. One soul, one fine, one
  mark ledger — no pack-vs-creature mismatch.
- **Dead vessels re-grow at the nest for a body fee** (paid in the loot currency). This is
  the revival verb the A0 spec leaves unspecified, and it is deliberately a *purchase*, not
  a timer: it prices body-death (tier-1 sting), it is the economy's second recurring sink,
  and it puts a price on every die-on-purpose line (teleport-home, die-to-deposit — see
  degenerate strategies). Fee = flat per vessel in the slice, `body_fee` hypothesis; if the
  pack can't pay, the vessel re-grows free after a long timer (`destitution_frames`) — fees
  price convenience, they never brick (law 6).
- **Anti-run-it-down invariant:** a wipe always costs the fine PLUS all outstanding body
  fees (the nest re-grows the full pack; the gates tax the passage; the vats still charge).
  Letting the pack attrit to a deliberate wipe is therefore never cheaper than paying
  piecemeal — the "wipe as discount full-heal" inversion (finding B-Q4) cannot dominate.

## Design laws for death (derived from research + bible canon)

1. **Two-tier death.** Body-death is *tactical* (frequent, cheap-but-priced): that body's
   carried load goes to its corpse, and re-growing the vessel costs a body fee. The wipe is
   *economic* (rare, priced): the practice fine + all body fees + three corpses to run back
   for. Rationale: pack bodies die routinely — a banked-practice fine per body-death would
   tax normal play into misery. Research rule: destroy only in-flight progress, or banked
   progress that is *insurable* (Skyrim-safe vs Oblivion-exploit).
2. **Carried vs banked.** Loot exists in exactly two states: `carried` (on a creature, at
   risk) and `banked` (at the nest, permanently safe). Banking is the safety verb; the
   decision "bank now or push deeper" is the loop's heartbeat. The banked stash is NEVER
   taxed — but it is *spent* (body fees, marks): spending is the drain, taxing never is.
3. **The corpse is a container.** A dead pack body persists where it fell (already visual
   since A0) holding its carried load. Term-limited: after `corpse_term_frames` the load
   decays — gone. Surviving pack members loot own-pack corpses by the interact verb —
   but only after `loot_settle_frames` out of combat (a corpse mid-melee is not a bank
   window; this also blunts die-to-deposit, below). After a wipe, all three corpses hold
   their loads out in the district: the run back from the nest IS the corpse run. Distance
   is the difficulty; humans have respawned; you are re-armed but empty-handed.
4. **The wipe fine taxes the entity's practice; insurance mitigates it.** On wipe, the
   entity loses a percentage of banked practice across its disciplines. Insurance marks —
   bought at the nest, strand-inscribed, consumed on any *priced* wipe — each cut the fine
   additively (Tibia's proven shape: `loss = base_fine × (1 − Σ mitigations)`,
   community-verified to the digit). When patronage pays the fine (below the floor), marks
   are NOT consumed — insurance never burns for zero benefit (newbie-trap guard).
5. **No purchase may reduce the drop or skip the run.** Deliberate deviation from the
   research note (which recommended blessing-dependent item-drop chance): Tibia's recovery
   odds are adversarial and low (other players, corpse decay), so drop insurance is mercy;
   ours are solo and high, so drop insurance would be paying to skip a walk. The run itself
   stays purchase-proof. (A *term-extension* mark — insuring only the expiry tier, which IS
   permanent loss — does not violate this law and is a D3 candidate, not slice scope.)
6. **No priced-tier death is free; no death ever bricks you.** Always-lost tier on any
   priced wipe: consumed insurance + body fees + anything past corpse-term expiry. Below
   the patronage line (see fine section), death costs time and fees only — that is the
   accessibility trade and we own it openly. Respawn is never blocked; the uninsured fine
   is capped; destitution never stalls the pack (free slow re-growth floor).
7. **Permadeath never.** Canon-locked (§13): true annihilation is a court verdict in story
   content only. No mechanic in this doc can invoke it.

## Interaction substrate (new to the possession game — the hands and eyes)

The A0 game has no pickup, no interact, no carry state, no quantity display (HUD law:
"Three HP bars + exhaust pip. Nothing else"). This economy quietly requires all of it, so
it is budgeted here explicitly (panel findings A-A2, C-Q7):

- **Interact verb** (one key): pick up drops, loot own-pack corpses, use nest stations
  (bank, vat, mark vendor). New harness input lane (`"interact"` in `hold`) with the same
  law-4 semantics as everything else: creature-owned, swap-inert, **edge-triggered after a
  swap** (a held interact never ghost-fires across a forced-swap).
- **Carry HUD**: carried-count element on the possessed bar (D0 ships it, with its own
  vision-critique line). Banked total visible only at the nest station — the world HUD
  stays quiet.
- **Corpse legibility**: three player-readable corpse states — loaded / looted-empty /
  expired — visually distinct in capture (vision-critique line, D1).
- The bill splits: D0 pays for the verb + lane + pickup + bank + carry HUD; D1 reuses the
  same verb for corpse-loot and adds the corpse states. If D0's design pass finds the
  verb + HUD alone is a meaningful increment, believe it and split a D0a.

## End-state mechanics

### Body-death (tactical tier)
- Possessed or ally body dies → its carried load transfers to its corpse entity. Forced-swap /
  ally-down flow unchanged from A0.
- Corpse entity: sim-owned, tile-anchored, lootable via interact by surviving pack members
  after `loot_settle_frames` out of combat; term clock starts at death.
- The dead vessel re-grows at the nest for `body_fee` (paid from banked currency, at the
  nest) or free after `destitution_frames`.
- Mid-hunt decision created: push to recover the Blocker's load under pressure, or cut losses.

### The wipe (economic tier)
- All three dead → veil → respawn at nest (unchanged). THEN the economy fires:
  - The entity's banked practice pays the fine (below) — unless patronage covers it.
  - All three body fees come due (banked currency; destitution floor applies).
  - Insurance marks are consumed iff the fine was priced (all of them, regardless of count —
    Tibia's AoL rule).
  - Three corpses persist in the district with their loads. **Wipe grace:** at the wipe
    frame, every corpse's remaining term resets to at least `wipe_grace_frames` — the
    first-dead corpse must not expire during the veil/respawn flow the player cannot act in
    (panel finding B-X4).
- The corpse run: re-enter the district, reach each corpse inside its term, loot your own
  dead. (Fiction slot: order form item 7.)

### The fine (numbers = hypotheses, to live in `data/balance/death.json` when D2 promotes)
- `base_fine`: **5%** of the entity's banked practice per priced wipe. Derivation (research):
  corpse-run + fine together → start each component at half strength; Tibia's flat low-level
  fine is 10%, so 5% — which also sits next to Tibia's unmitigated level-100 reality (4.5%).
- **Patronage line** (the accessibility floor, canon-corrected): below total-practice tier N,
  a patron covers the fine — the gate is always paid, never waived (§5.3: "Nothing crosses
  any part of the Undervault free"; the Toll is "non-negotiable"; canon's own device is that
  someone *else* can pay — "the poor buy one cheap blessing" scaled to doctrine). Mechanically
  identical to a zero fine for the player; canonically a payment on another's account. Keys
  on the entity's TOTAL practice — there are no per-creature pools to camp.
- Insurance: **3 marks** in the first slice, **−20% each**, additive (max −60% → fully-insured
  wipe = 2.0%). Derivation honesty (panel-corrected): the research's actual slice band is
  3–5 blessings at 8% = **24–40% max mitigation**, which would put fully-insured at 3.0%;
  we deliberately exceed it to 60% because our sink count is lower and body fees add a
  second cost channel the research's model didn't have. The research's target *feel* band —
  mitigated ~0.5–1.5%, unmitigated ~4–5% of lifetime progress — is the end-state target; the
  slice's 2.0% floor overshoots it and closes toward it when a promotion-analog lands (D3).
  The SHAPE (additive stack, consumed-on-death, recurring sink) is the load-bearing import.
- **Mark price scales**: priced as a small % of the practice it insures, not a flat sum —
  self-scaling like Tibia's level-priced blessings, so buying marks stays a decision instead
  of becoming petty cash (panel finding B-Q7).
- Emotional signature to preserve at end-state: percentage falls with progression, absolute
  cost rises (the research's "respected, not hated" criterion). A flat % is acceptable for a
  low-cap slice; revisit the curve when practice totals span an order of magnitude.
- `corpse_term_frames`: shaped as a *multiple of measured recovery*, not a bare constant —
  target **term ≥ 3× median wipe-to-last-corpse recovery time**, floor 10 minutes
  (36,000f). At A0 district scale (~40×23) 10 minutes is deliberately generous; it tightens
  by measurement as districts deepen, never by feel. **Term ticks on global sim frames,
  including while the player is in the nest zone** — nest time is real time; idling at the
  nest is not a term-pause (decided now so `corpse_run.json` doesn't encode an accident).

### The retail loop (needs a currency)
- Two recurring sinks: **body fees** (per vessel death) and **insurance marks** (consumed on
  priced wipes). Sinks scale with recklessness and progression respectively — a competent
  player's currency still exits through fees; a progressing player's through mark prices.
- If banked currency still accumulates past both sinks (likely — faucet runs all play),
  the fix is a second *want*, not a tax (law 2): parked candidates — nest upgrades, gambit
  slots (A1 synergy). Named here so D2's fun-verify watches for saturation; not designed.
- Who sells any of this to monsters is a fiction question (order form) — mechanically these
  are nest interactables, nothing more.

## Known degenerate strategies (open risks, for fun-verify to adjudicate)

- **Pack-parking:** leave two bodies idle at the nest, solo with one. Now self-defeating
  rather than merely self-limiting: the solo body's every death costs a body fee, the pack
  fights at 1/3 power, and the patronage line can't be camped (entity-total practice). If
  playtest still shows abuse, the candidate mitigations are: leash the ally AI to the
  possessed body — **flagged: that is a spec change to A0's husk-grade ally AI (law 1), not
  a balance knob** — or scale human aggression to living-pack-size (A2 pull-economy
  territory). Decide with data, not upfront.
- **Body-death as free teleport** (die on purpose to snap control to a nest-parked body):
  priced by the body fee + the abandoned carried load. Watch whether the fee is enough;
  the counter-lever is fee size, not new rules.
- **Die-to-deposit** (suicide adjacent to a parked mule so it loots your load "safely"):
  blunted three ways — `loot_settle_frames` (no instant mid-combat looting), the body fee
  (deliberate death is never free), and the leash-mitigation *not* existing (allies parked
  at the nest are far away by definition). If playtest still shows it, escalate settle time
  before inventing rules.
- **Suicide fast-travel** (wipe-as-teleport home): priced by fine + 3 body fees past the
  patronage line; inside it, fees still apply and walking distances are short anyway.
  Watch, don't pre-fix (Tibia lives with this).
- **Banking-cadence collapse:** at A0's actual scale (one district, ~40×23, nest adjacent)
  "everywhere is seconds from the nest" is the *default state*, not a tail risk — D0's
  cadence gate may fail for map-size reasons while the design is sound. D0's fun-verify
  must capture cadence numbers (telemetry below), and the honest fallback is "the district
  must grow before the heartbeat exists" — that is an A3-track answer, not a D-track patch.

## Staging (each behind its own fun-verify; promotion via scope contract only)

**D0 — loot loop (the substrate).** Now designed here, not deferred:
- **Currency**: one fungible drop (spec-speak: *glean*). Rushers drop 0–N on death
  (`drop_table` hypothesis); drops are tile entities with a decay timer.
- **Pickup**: interact verb on the drop's tile (substrate section above: new input lane).
- **Carry**: per-creature `carried` total; visible on the possessed HUD (carry HUD line).
- **Bank**: interact at the nest bank station moves carried → banked. Banked is spend-only.
- **Death, pre-D1**: carried loot on a dying body simply VANISHES in D0 (research-approved
  in-flight loss, independently testable) — corpse containers are D1's whole point.
- **Gate**: rake green · loot-loop capture byte-identical · vision critique (drops, carry
  HUD legible) · **owner reports "bank now or push deeper" felt like a decision** (the
  cadence clause lives HERE, not in D1). Telemetry: frames between bank events; carried
  value at bank vs at death.
- D0 promotes THREE things at once and the scope-contract update must name them: the
  interact verb, the currency/loot substrate, and the carry HUD. If that reads as two
  increments (verb+HUD vs loot), split D0a/D0b.

**D1 — the corpse-run slice (THE fun-verify target).** Corpse containers + own-corpse
recovery + body fees + wipe leaves three loaded corpses + wipe grace + term expiry. No
practice fine, no insurance yet — D1 tests whether the run back is tense *before* the
economy prices it. (Caveat for reading D1 data: with no fine, death-frequency and cadence
numbers are upper bounds on recklessness, not economy signals.)
- **Gate**: rake green · `corpse_run.json` byte-identical across two runs · vision critique
  passes (three corpse states legible; carry HUD stable) · owner wipes, runs back, recovers,
  and calls the tension fun.
- **Script shape** (panel-corrected): first act = one body dies loaded and a *survivor*
  loots it mid-hunt (the tactical tier must be exercised, not just the wipe path); then the
  wipe sequence; then recovery; then one deliberate term-expiry. One stacked-corpse wipe
  (2+ corpses on adjacent/same tiles) for loot-target determinism. Every assertion-bearing
  moment happens on-camera for the possessed viewport (A0 camera law); the deliberate
  expiry of a distant corpse is asserted via event, and the doc says so here so the script
  author doesn't guess.
- **Telemetry** (all derivable from the deterministic replay; full list in
  `drafts/_dcrit-b.md` Q6): per-corpse stagger (death-to-wipe), respawn overhead, per-corpse
  recovery margin (`term_remaining_at_loot / term` — target ~0.3–0.5 on the deepest corpse;
  >0.7 median means the term is set dressing), recovery rate by death order, second-wipe-
  during-run frequency, which kit was last alive at wipe (climax-vs-coin-flip check).

**D2 — the wipe fine + insurance retail.** Blocked on skill-through-use — which is itself
parked with NO design doc and no slot on the A1–A3 ladder, so D2 is several fun-verifies
away at minimum, and may be forever-away: **if skill-through-use never lands, D2 dies with
it — acceptable, because D1 carries the signature tension alone.** The fine stays
practice-denominated even so: re-basing onto the loot currency would tax the banked stash
(law 2 violation) and collapse insurance into rate arithmetic ("pay X currency to avoid Y
currency"). D2's promotion touches THREE parked items and the scope-contract update must
name all of them: corpse-run economics, skill-through-use, and shops/inventory (the mark
vendor is a shop; the carry ledger is an inventory).
- **Gate**: fine math reproduced exactly by a unit oracle · patronage line + mark
  purchase→consume cycle in capture (including the not-consumed-under-patronage case) ·
  owner reports the fine stings but reads as fair.

**D3 — end-state extras (park until D2 proves out).** Promotion-analog (mitigation shape
only — no tuned constant until it has a design) · term-extension mark (the one insurance
law 5 permits) · scavenger humans that loot corpses (turns term expiry from a timer into
visible drama; fiction free — looters-inside-the-term-are-cursed is already canon) · fine
curve vs practice scale · second currency want (nest upgrades / gambit slots).

## Determinism & harness (law 3 of the review, applied)

Corpse entities, term clocks, wipe-grace resets, carried/banked ledgers, body-fee state:
all sim state, all frame-quantized, all serialized in replays. Harness input schema grows
an **interact lane** (D0) — same edge-trigger-after-swap semantics as the swap lane. New
capture scripts `loot_loop.json` (D0) and `corpse_run.json` (D1), candidates for the
permanent regression set on their increments' promotion. No wall-clock time anywhere in
term or fee logic; the term ticks on global sim frames across zones (decided above).

## Bible binding (amend by adding, never editing)

The §13 hooks table already carries the human-side rows (Toll, blessings, corpse ten-day
term, echo-reeling). The pack game adds NEW rows when fiction binds — candidates: *the
vessel economy* (vat-grown bodies, the body fee — §5.3/§10's Silt Mothers are the canon
hook), *pack wipe as the entity's Half-Passage*, *carried-vs-banked* (what gleaning and
hoarding mean to the pack), *monster-side insurance retail* (§10.3's banned-and-buried are
the obvious hook, but that is the bible session's call). Canon constraints inherited: the
Toll is never waived (patronage, not exemption); permadeath is verdict-only;
looters-inside-the-term-are-cursed gives scavenger humans (D3) their fiction for free.
**Handed to the bible session explicitly:** the human funerary term is ten *days* (§5.3
custom); the pack game's term is ~ten *minutes*. Write the monster-side reading as its own
row (different law for unhallowed dead? vermin-scale custom?) so the two terms read as
parallel customs, not a contradiction.

## Fiction order form (for the bible session — name from INSIDE the fiction)

1. **The wipe** — what it means that the possessing entity loses all three bodies and
   persists; its own Half-Passage. (Extends A0 order-form item 3.)
2. **The vessels and the vat** — what the three bodies are such that they are soulless,
   re-growable, and fee-priced; who or what re-grows them at the nest. (Silt-Mother-shaped
   canon hook, monster-side.)
3. **The insurance mark** — who sells monsters mercy against the Toll, and what the mark
   physically is. (Ask it that way — not as "the blessing analog.")
4. **The currency** — what humans carry that the pack wants (gleaning fiction).
5. **The corpse term** — why a dead vessel holds its goods for a while and then doesn't;
   AND the ten-days-vs-ten-minutes delta above.
6. **The patronage line** — who pays the gate for small souls, and why. (NOT a free-passage
   doctrine — the Toll is never waived; commission a patron.)
7. **The corpse run itself** — what the walk back is called and what it means for a
   possessing entity to loot its own dead vessels. (Candidate, human-side, NOT pre-assigned:
   §5.3's "walk of shame and iron" — the bible session decides if it translates.)
8. **Term expiry, on screen** — what the player sees when a corpse's term lapses (ships in
   D1, long before D3's scavengers animate it).
9. **Banking at the nest** — the rite/act that makes stashed goods safe.

## Deliberately absent

Equippable gear per creature (out of scope; if it ever lands, the corpse container is the
natural home) · PvP looting rules (no PvP) · any practice-fine on body-death (rejected by
law 1 + soul model) · any purchase that reduces the drop or skips the run (law 5; the
term-extension mark is D3's one permitted exception) · permadeath (canon-locked).
