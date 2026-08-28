# Review — Junior's "A floresta como começo, a descida como prova" (2026-08-27)

**Delivery:** `_junior-proposta-reestruturacao-20260827.docx`, received via
owner relay from Downloads, banked at
`drafts/_junior-proposta-reestruturacao-20260827/` (docx md5
`ac870ddd45d468b38e5b8f47120bab1e`; extracted text
`027a7eef…`; images 1-5 `24409756…/80e916ad…/28fdbe0b…/5c60b091…/e52d2e46…`).
Reviewer: hub dev-of-record, s109. Status: **PASS as v20 grill input** —
banked now, EXECUTES nothing. Junior himself scoped it: "nada muda no jogo
antes do veredito do ritual e da decisão conjunta." Zero freeze conflict.

## What it proposes (faithful summary)

1. **The inversion:** player wakes in ZONE 8 (the forest); HUB 1 migrates
   INTO zone_8 as a base-camp near the well/services area. The world's two
   destinies visible in geography: east = existing dungeon_1 portal
   (explicitly UNTOUCHED), west = a NEW hole opening the descent.
2. **The descent:** three continuous floors, NO mid-checkpoint, reusing
   ZONE 2 (district) → ZONE 3 (district_two) → ZONE 5 (low_quay, boss
   lair). Deliberate: one expedition, not two short trips — "banco agora
   ou desço mais?" stretched vertical.
3. **Healing totem:** center of each floor, AoE heal pulsing on a fixed
   cadence (~15s starting suggestion, number explicitly deferred to
   balance). Center = the most contested ground → healing becomes
   territory you FIGHT FOR, not a retreat. Boss floor: totem = arena
   anchor. Registered alternative in the same family: scattered floor
   heal points; both can coexist.
4. **Visual identity:** the three floors re-themed as ONE dungeon —
   same palette family, darkening with depth (existing depth rule).
5. **Honest self-flags (his own):** world-graph restructuring = v20
   class · HOME move = heaviest call (mercy floor + respawn hang on it) ·
   AoE heal = new sim behavior, one gated piece at a time · no-checkpoint
   death = restart by design, floor sizes must respect it · reuse saves
   content, real cost = visual unification + transition rewiring · zero
   balance numbers in the proposal (positions and links only).

## Independent verification (claims vs repo ground truth)

| Claim | Verdict |
|---|---|
| ZONE 2/3/5 = district / district_two / low_quay | CONFIRMED (`data/zones/*.json` display_names) |
| zone_8 already has field services near the well | CONFIRMED — stations vat [16,25] + altar [18,25] (no bank; HUB 1 brings bank [8,4] + altar [12,4] + vat [10,6]) |
| dungeon_1 portal on zone_8's east edge, "intocado" | CONFIRMED — transition [63,19] → dungeon_1 [29,4] (s70 wire-in heritage) |
| HOME migration is structurally possible | CONFIRMED — better than he knew: `world.rb` already carries `@home_zone` that ADVANCES + a `home_rehomed` event (v12). The heaviest piece has an existing seam. |
| "4 ANDARES" (image1 annotation) | **DISCREPANCY** — text says TRÊS andares, three floor images delivered. Resolve with Junior (likely stale annotation or hole-mouth counted as floor 0). HOLD the question until ritual 10/10 banked (contamination hygiene; it is not urgent — the grill is verdict-gated anyway). |

## Design evaluation (touchstones, not taste)

**The inversion — STRONG.** Diagnosis is sharp and true: today's graph is
corridor-first and the biggest, most atmospheric map (zone_8, frontier
rung level 8) arrives at the END and arrives thin (its intake debt is a
recorded fact). Flipping it makes geography tell the truth: open = home,
down = danger-by-choice. Touchstones: Tibia's Rookgaard/Thais — you wake
on open ground and DESCEND into dungeons deliberately; KB shelf
(world-events note, verified 2026-08-16): players network-optimize into
ONE hub per world and **centrality drives hub adoption** — the camp
inside the forest at the well is exactly that centrality argument. And it
is v19's own blessed line taken to its conclusion: "a world with a real
geography of risk."

**Descent-as-expedition — STRONG, and it composes with standing law.**
No-bank-in-deep is KEPT design (v19 lane 2); the no-checkpoint call is
the same law verticalized. Tibia deep dungeons are the direct touchstone:
depth = commitment, the return trip is part of the risk. Wipe-on-floor-2
= restart is intentional and correct for expedition flavor — its real
constraints are (a) mercy floor B4 semantics hang on HOME, (b) floor
sizing, both named by Junior himself.

**The totem — the best idea in the doc.** It solves the problem his own
no-checkpoint call creates (sustain without a bank) by converting healing
from retreat-time (dead air) into the floor's focal fight. King-of-the-
hill control logic applied to sustain; pays in position and risk, not
coin — which keeps the field economy's "never free strategically" rule
intact. Convergence signal: this seat independently proposed healing
pillars (slate candidate 3) — two seats arriving at the same family from
different directions is the strongest design signal we get. KB shelf has
NO direct contested-healing prior (queried 2026-08-27, gap noted for the
research spoke if the grill wants it); nearest priors: Tibia risk/reward
tier differentiation + fixed-ratio reward schedules (predictable cadence
couples reward to genuine work — supports FIXED pulse rhythm over random).

## Risks the grill must eat (my adversarial rows — none block banking)

1. **Graph re-rooting is bigger than the doc draws.** ZONE 2/3/5 are
   today's ENTIRE introduction arc (camp ↔ district/district_two;
   low_quay → zone_7). Making them descent floors re-roots: spawn chain,
   `requires_defeats` ladder, BOSS 1's zone, the low_quay↔zone_7 joined-
   world edge, TOWN 1's role as deep-side anchor, wall scripts that start
   in those zones (`low_quay_run`, `varekka_duel`), and ZONE 1/4/6's
   place. The #1 grill question: **re-root or parallel loop?** The doc
   answers "floresta É o mundo" (re-root) but never draws where zone_7's
   family lands. Demand the full graph drawing at grill time.
2. **Save-chain continuity.** Spawn/HOME live in the save; strict decode
   refuses NAMED on schema drift. The ritual chain (sessions=17) must
   never be the migration guinea pig — migration law (or clean-break
   `--fresh` decision) is its own grill row.
3. **AoE pulse heal = new SIM-CLASS behavior** — one gated piece, own
   re-session, per standing law (Junior cites the law himself). Boss-
   arena totem also moves BOSS 1 fight balance — frozen numbers, correctly
   deferred.
4. **Visual unification of three zones = three full Rule 2 re-gates** +
   re-pins across the wall. Real cost, correctly named as the price of
   content reuse. Budget it in tickets, not adjectives.
5. **world.rb is at 1769/1800.** HOME migration + transition rewiring
   touch world.rb at the cap — the grill must budget the owed extraction
   (Crossing/Progression precedent) INTO the first ticket, not after.
6. **Pilot-four provenance:** district/district_two/low_quay/camp are
   importer emissions — every map change goes through authoring/pilot.ldtk
   → `tools/import_ldtk.rb`, never hand-edited JSON (provenance pin).

## Routing (now vs later)

- **NOW (this session, docs-only):** banked + this review + registered as
  v20 grill input. No reply to Junior on ritual-adjacent design until his
  10/10 ritual answers are banked (contamination guard: safe/deep
  geography is a ritual topic; his doc is design-direction, lawful to
  bank — but zero follow-up probing from our side until then).
- **POST-VERDICT:** this doc joins the v20 grill index (archaeology
  A-rows + underground ask + J-T4..T8 + THIS). Note the convergence:
  Junior's descent IS the "underground ask" made concrete — the grill
  can likely fuse them into one lane.
- **Never:** relitigate the freeze; touch data/zones/src on this before
  the verdict.

**Verdict: PASS (banked, grill-ready).** This is the strongest structural
proposal either seat has produced this cycle: correct self-scoping,
honest cost naming, and the totem turns its own biggest weakness into
its best mechanic. The grill's job is the graph drawing, the save
migration law, and ticket-sized costs — not whether the direction is
right.
