# s90 — fresh-eyes review of Junior's J-T1 dossier + J-T2 blueprint (2026-08-26)

Reviewer: hub seat, session 90 — a context that did NOT author the
deliverables (Rule 6 satisfied; his seat wrote them, this seat verified
them). Targets at `88f3ba4`, confirmed byte-unchanged through `bc4ba45`
(`git diff 88f3ba4..HEAD -- <targets>` empty):

- `drafts/_junior-dungeon-dossier-20260826.md` (J-T1)
- `drafts/_junior-dungeon2-blueprint-20260826.md` (J-T2)
- `drafts/_junior-parallel-handoff-20260826.md` (handoff)

## VERDICT: PASS — accepted as v20 grill input, no corrections owed

**J-T1 is hereby VERIFIED** (this satisfies one of the three recorded
worldsmith-v2-grill triggers: verdict + **J-T1-verified** + T26).
Fence audit was already stat-clean at s89; this review judged CONTENT.

## (a) Citation spot-check — every claim verified against its named source

All data claims re-read live from `data/` + `src/` this session:

| Claim (dossier/blueprint) | Verified against | Result |
|---|---|---|
| zone_8 = 64×40, ONE transition, zero enemy_spawns, vat [16,25] + altar [18,25] | data/zones/zone_8.json | EXACT (`enemy_spawns: {}`, single transition [63,19]→dungeon_1) |
| zone_8 tile mix 1148 grass / 656 water / 468 dirt | tile-count script over zone_8.json | EXACT (g=1148, ~=656, ,=468; also #=281, w=7 unmentioned — fine) |
| Arrival into zone_8 at [62,18] east edge | dungeon_1.json rope [29,4] `spawn: [62,18]` | EXACT (AGENTS.md's "[63,19]" is the zone-side gate tile; both true) |
| Pack fixture spawn [12,26] | zone_8.json `pack_spawn` [[12,26],[13,26],[14,26]] | EXACT (first tile named) |
| Ladder rungs def-1 → lvl 4 → lvl 5 → lvl 6+seal → lvl 8, free returns | low_quay/zone_7/dungeon_1 JSONs | EXACT (all gate values + sealed flag + free returns confirmed) |
| BOSS 1 = challenger @ low_quay [43,15], the ONLY boss | grep challenger across all zone JSONs | EXACT (single spawn in the game) |
| `boss_1_defeats` progression.rb:120 | src/game/progression.rb | EXACT (`record_boss_1_defeat!` sits at line 120) |
| basement_2 [6,3] interior sealed self-loop precedent | basement_2.json | EXACT (`{"at":[6,3],"to":"basement_2","sealed":true}`) |
| dungeon_1 32×20, floor key, gradient_anchor | dungeon_1.json | EXACT (floor=-1, gradient_anchor [15,3]) |
| challenger drop_table + seize | data/balance/combat.json | EXACT |
| Graph chain nest→district→camp→district_two→slow_door→low_quay | five zone JSONs | EXACT |
| `multi_floor_descent` wall script proves floors render | harness/scripts/ | EXISTS |
| rusher / husk / challenger kit names | combat.json kits | ALL LIVE (husk ships in basements + dungeon_1 — blueprint's kit list is 100% shipped grammar; NEW-asks list stays honest: only BOSS 2 kit + optional counter) |
| Block-cap law "defender blocks at most 2, manual teaches ≤2 reach you", HIGH | docs/design-corpus/tibia-research.md lines 21-25 | FAITHFUL (verbatim manual quotes + hard-blocking body-block finding, both [high]) |
| Lure-clump-burst corner geometry | drafts/_tibia-aoe-research-20260813.md solo-meta + principles | SUPPORTED (corner/corridor clump mechanics verbatim in the solo-meta loop; principles 2/5 carry density→payoff) |
| Hunt-analyser reading 4 owner verbatim "place of hunt (monster variety/type)" | drafts/_tibia-hunt-analyser-ek1037.md item 4 | EXACT (inside the owner design-philosophy quote; "decision stack" framing is the file's own) |
| Hub KB seeds 1-5 quoted in the lane doc | drafts/_junior-parallel-lane-20260826.md lines 46-70 | ALL FIVE PRESENT, attributions match, FLAGGED-class discipline stated |
| His v20 input items 2/4/5 as the only feel source | drafts/_junior-v20-input-20260826.md | MATCH (item 4 "parece vazio no mapa novo pelo seu tamanho" verbatim; item 5 correctly left hygiene-banked, untouched) |

**One cosmetic nit (no action owed, recorded for calibration):** dossier
§2 cites AoE "principles 2/5/6" for the corner-geometry claim; principle
6 is the DoT/chase line — the corner substance lives in the solo-meta
section + principles 2/5 (which the blueprint itself cites correctly as
"p.2/5"). Substance fully supported; the principle-number list is one
digit generous.

## (b) Hygiene scan — CLEAN

- No ritual-topic probing: zero growth-felt / difficulty-feel /
  third-body / safe-deep questioning of any peer. Only feel source =
  his OWN pre-banked v20 input (recorded before assignment — lawful).
  Fork 4 correctly DEFERS the return-posture feel question to the
  verdict climate instead of asking anyone now.
- No balance numbers: spawn counts, HP, damage all absent/deferred;
  numbers present are coords/dims (authoring geometry, T1-T5 class) and
  the 2-wide door mouth argued from the block-cap LAW, not tuned.
- Placeholder law held: DUNGEON 2 / BOSS 2 everywhere; Tibia/Zelda/BDO
  names appear only as touchstone citations; seed 5's source explicitly
  stripped to mechanics-only with the placeholder law restated.
- Freeze fences held: docs-only delivery (git-verified), data/zones
  read-only, pilot.ldtk untouched, import_ldtk not run, §9 unread
  (stated; nothing in the text contradicts it).

## (c) Grill-readiness — STRONG

- The ladder maps to the live graph EXACTLY (every gate value verified
  above) and names the real mechanical gap: the lvl-8 rung tops out in
  an empty 64×40 zone; the only boss is mid-ladder. "The pack at cap
  has nowhere to spend its power" is byte-true (level cap 10 reached
  pre-ritual, log #41).
- Three candidates are concrete: each has a room graph, ONE
  discoverable rule, a shipped-grammar inventory vs NEW-asks split, and
  a risk posture. The recommendation (A + B's gradient fold, C banked
  as DUNGEON 3 vocabulary) is defended with build-risk reasoning, not
  taste.
- The blueprint is SAFE-class only, verified: water/grass = decor,
  gradient_anchor = shipped dungeon_1 grammar, zero SIM-class asks; the
  NEW list is honest and minimal (BOSS 2 kit + optional
  `boss_2_defeats` save-schema touch, both correctly flagged
  not-freeze-lawful).
- The six open forks are genuine grill questions whose MECHANISMS all
  exist today — the grill picks values, not machinery.

## (d) Convergence cross-pin — candidate 8 ↔ J-T1/J-T2 (grill input)

The owner's s89 macro-topology (slate candidate 8, verbatim): "East: to
the final Area Dungeon that connects to the next city." The live graph
already flows west→east: intro arc (west/start, exactly as the owner's
sketch anchors it) → zone_7 → dungeon_1's far-EAST rope → zone_8.
J-T2's DUNGEON 2 at zone_8's frontier is therefore the natural FIRST
INSTANCE of the spine's "dungeon" link — Junior's east-dungeon ask and
the owner's city→dungeon→city spine converge on the same map edge
without either knowing it.

Concrete consequence for the grill (recorded here, decided there):
dossier fork 6 ("does the frontier feed back, or self-contained this
cycle") gains a THIRD option — **DUNGEON 2's far side connects ONWARD
to CITY 1**, making it the passage-dungeon of the candidate-8 spine
(Tibia precedent already banked in the slate: mainland cities chained
by dangerous passages). If the grill picks the spine, J-T2's blueprint
needs one added transition stub on R4's far side — a one-line paper
amendment, no redesign. Fork 1 (entrance rung) then reads as the
spine's difficulty-band boundary.

Also convergent, no action owed: candidate 7 (enemy roster) supplies
what R1/R2's kit-mix wants long-term; candidate 9 rung (ii) sub-areas =
J-T3's exact playbook; J-T3's anchor is now FIXED by this blueprint
(east arrival [62,18] → NW entrance [~5,5] approach route).

## Consequences + parked rows

- CLAIMED line (checkpoint top) cleared this session — J-T1/J-T2
  delivered, reviewed, accepted. J-T3 stays NEXT-UP on owner word
  (per the lane doc; do not start it for him).
- Issues routed to Junior: NONE (the §a nit is calibration-grade, not
  worth a mail; it rides this note).
- **PARKED receipt row for the routing doc** (blob-stability law: the
  routing doc's content is digest-pinned until worldsmith's T26 receipt
  lands; append this row there ONLY after that):
  > 2026-08-26 Junior parallel lane — J-T1 + J-T2 + handoff DELIVERED
  > same-night (`4dd1cfc` claim + `88f3ba4` delivery, 392 lines,
  > docs-only) and REVIEWED s90: PASS, zero corrections
  > (`drafts/_s90-junior-jt1-jt2-review-20260826.md`). J-T1 = VERIFIED
  > (worldsmith v2 grill trigger 2 of 3 satisfied). Lane receipt CLOSED;
  > J-T3 next-up on owner word.
