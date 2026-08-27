# J-T1 — Dungeon + boss ladder dossier (Junior seat, 2026-08-26)

Ticket: `drafts/_junior-parallel-lane-20260826.md` J-T1 (assigned s89).
Brief: my own v20 input (`drafts/_junior-v20-input-20260826.md`) — item 2
"falta novos dungeons com boss" + item 4 "zone_8 parece vazio pelo seu
tamanho". Drafts-only under the armed freeze: NO balance numbers, no
data/src edits, placeholder names only (DUNGEON 2 / BOSS 2). Every claim
cites a source; hub-KB seed numbers are FLAGGED-class (shape only, per
the shelf's trust-tier law — `systemic-worlds-research-shelf.md`).

## 1. The live graph, and where the ladder stops today

Read from `data/zones/*.json` this session (transitions verbatim):

```
nest — district — camp — district_two — slow_door — low_quay ——(def 1)—— zone_7
                                            (BOSS 1 @ low_quay [43,15])    |
              zone_7 —(lvl 4)→ basement_1                                  |
              zone_7 —(lvl 5)→ basement_2 (interior sealed door)           |
              zone_7 —(lvl 6 + seal)→ dungeon_1 —(rope, lvl 8)→ zone_8     |
                                                                 └──(rope, free return)
```

- The rungs climb cleanly: def-1 → lvl 4 → lvl 5 → lvl 6+seal → lvl 8 —
  a radial danger gradient where DISTANCE is the gate (hub KB seed 2,
  s89: "true open worlds gate by geography, not level-scaling").
- **The ladder's top rung leads nowhere.** zone_8 (64×40 — the biggest
  map in the game) has ONE transition (back to dungeon_1), TWO stations
  (vat [16,25], altar [18,25]) and **zero enemy_spawns**. The lvl-8
  frontier is an empty reward. This is the mechanical root of my item 4:
  the emptiness isn't palette or size — it's that nothing lives there
  and nothing is beyond it.
- The only boss is BOSS 1 (`challenger` kit, low_quay [43,15]), MID-ladder:
  his defeat counter (`boss_1_defeats`, progression.rb:120) gates the
  low_quay→zone_7 crossing — the game's summit currently has no fight.
  My item 2 in one line: the pack at cap has nowhere to spend its power.

## 2. What a dungeon IS here (touchstones, mechanics only)

- **Tibia, Pits of Inferno:** multi-level dungeon delving as endgame
  identity (hub KB seed 3, s89) — hunt zones feed dungeons; dungeons end
  in named bosses. Our basements/dungeon_1 are the small version; the
  frontier deserves the full shape.
- **Zelda OoT "puzzle box":** a dungeon is a holistic machine, not a
  linear room string — loop: exploration → gating → acquisition →
  recontextualization → boss (hub KB seed 1, s89). Our grammar for
  "acquisition → recontextualization" is the SEAL: find the seal station
  deep in the dungeon, breach it, the boss door opens (seal-gating law,
  s34: `opens` must name a TRUTHY `sealed` transition — shipped, tested).
- **"Dungeon = house; boss = house owner; ONE rule you only discover by
  playing"** (hub KB seed 5, s89 — mechanics concept only, no fiction):
  each candidate below names its one discoverable rule. This is the
  cheapest depth we can buy: geometry + spawn placement teaching a rule,
  zero new systems.
- **BDO endgame circuits** (hub KB seed 4, s89): what a boss room adds ON
  TOP of circuit-grinding — the farmable loop and the commitment fight
  are different appetites; a good dungeon serves both.
- **Chokepoint law** (`docs/design-corpus/tibia-research.md`, block-cap
  finding, HIGH): a defender blocks at most 2; the manual itself teaches
  positioning so ≤2 enemies reach you. Corridor/door width IS the
  difficulty dial that costs zero balance numbers — our blocker already
  plays this game (body-block finding: occupied tile = hard-blocking).
- **Lure-clump-burst** (`drafts/_tibia-aoe-research-20260813.md`,
  principles 2/5/6): corner and corridor geometry converts density into
  AoE payoff — dungeon room shapes should deliberately offer clump
  corners; this is also the natural stage for the striker-whirl growth
  fork (my input item 5 + slate candidate 2b — noted, NOT designed here).
- **The decision stack** (`drafts/_tibia-hunt-analyser-ek1037.md`,
  reading 4, owner verbatim): "place of hunt (monster variety/type)" is
  one of the variables that make Tibia's P&L magic. DUNGEON 2 adds a
  real "place of hunt" choice at the top of the ladder — today the cap
  has none.

## 3. Site: the DUNGEON 2 entrance belongs in zone_8's far reaches

- Arrival into zone_8 is at [62,18] (east edge); the walked band today
  is the south (stations at [16-18,25], pack fixture spawn [12,26]).
  The NORTH half + NORTHWEST quadrant are pure dead air (the map is
  1148 grass / 656 water / 468 dirt tiles with nothing to do).
- Entrance pick: **far northwest quadrant** (indicative: around [5,5];
  exact tile at LDtk time, post-verdict). Crossing the whole empty north
  to reach it converts the emptiness my item 4 complained about into
  APPROACH — the radial-gradient seed (KB 2) applied inside one map.
- Typed transition: `rope_spot` DOWN (interact = gate-consent law, the
  s70 dungeon_1→zone_8 precedent verbatim). Return posture is a fork
  (see §6) — dungeon_1's return is free; a one-way-cheap descent is the
  Tibia-PoI-flavored alternative.
- Pairing with J-T3 (zone_8 density pass, next-up): the approach route
  north wants 1-2 authored pockets ON the way — the s69 content-fill
  playbook — so the walk reads as territory, not corridor. Named here,
  designed there.

## 4. Three DUNGEON 2 shape candidates

All three use ONLY shipped grammar unless a line is marked **NEW (v20
ask)**. Shipped grammar inventory (read from data/ + specs this session):
per-kit enemy_spawns · sealed transitions + seal stations (`opens`) ·
interior sealed doors (basement_2 [6,3] self-loop precedent, s69) ·
`requires_level` / `requires_defeats` (reads `boss_1_defeats`) · typed
transitions (rope=interact; holes/stairs auto-fire) · floors
(dungeon_1 `floor` key; `multi_floor_descent` wall script proves the
render) · `gradient_anchor` (dungeon_1 density gradient) · stations ·
drop tables · challenger kit (seize mechanic).

### Candidate A — "Antechamber ladder" (linear + seal; safest build)

- Room graph: entry hall (rope up) → chamber 1 → chamber 2 (dense,
  clump corner) → seal room (seal station) → BOSS 2 arena (behind a
  SEALED door the station opens).
- The Zelda loop lands intact: explore (chambers) → gate (sealed boss
  door) → acquisition (find the seal) → recontextualize (walk back
  through cleared rooms to the now-open door) → boss.
- **One discoverable rule:** the seal station sits BEHIND the densest
  room — you learn that the deep room is the real objective and the
  boss is a PAID choice, not a wall. (Discovered, never told.)
- Boss arena posture: door mouth 2 tiles wide (block-cap law: the
  blocker can hold it); arena interior open enough for the challenger
  seize threat to matter.
- Asks: **zero new systems.** BOSS 2 itself is the only NEW piece — see
  §5.

### Candidate B — "The drowned loop" (circuit ring + committed center)

- Room graph: a ring of 3-4 rooms circling a central sealed chamber;
  the ring is the farmable circuit (BDO seed 4: respawn-cadence
  rotation), the center holds BOSS 2 behind the seal.
- `gradient_anchor` pointed at the center makes density climb toward
  the middle — the geometry says "the middle is the point" without a
  single string.
- **One discoverable rule:** the ring can be run forever; the center is
  ONE commitment. Two appetites, one map (circuit-grinders vs
  boss-hunters — the BDO/Tibia split).
- Water motif ('~' tiles already in zone_8's palette) as the SAFE-class
  visual identity: drowned ring, dry center. Decorative only.
- Asks: zero new systems; slightly more authoring surface than A
  (4-5 rooms vs 4).

### Candidate C — "The vertical throat" (multi-floor descent)

- Room graph: 3 small stacked floors; holes/stairs AUTO-FIRE downward
  (typed-transition law), one rope back up placed INSIDE the boss floor.
- **One discoverable rule:** down is cheap, up is earned — you commit by
  falling; the exit is on the far side of the fight. (Tibia PoI
  verticality, KB seed 3; the corpse-run TENSION shape without the
  parked gear-drop system.)
- Floors are proven grammar (`multi_floor_descent` script), but this
  candidate leans hardest on one-way flow, which we have never shipped
  as a player experience — highest feel risk of the three.
- Asks: zero new systems; highest playtest uncertainty.

**Seat recommendation (defended, not decided):** A as the blueprint
(fewest unknowns, every beat is a shipped precedent — T1-T5/s69 proved
this authoring costs one session), with B's gradient_anchor trick folded
into A's chamber 2 and C's verticality banked as DUNGEON 3 vocabulary.
J-T2 blueprints A.

## 5. BOSS 2 — what is honestly NEW

- A second boss demands a second boss KIT (`data/balance/combat.json`
  entry — **NEW, v20 ask, named only; zero numbers here**). Reusing the
  `challenger` kit at a new spawn would read as BOSS 1 again (kit =
  identity: seize verb, nameplate, defeat counter all hang off it).
- Which verb makes BOSS 2 distinct is a v20 grill question, not this
  doc's. Constraint worth carrying: BOSS 1's identity is SEIZE (body
  theft); BOSS 2 should threaten a DIFFERENT resource. (Fork, §6.)
- Counter plumbing: `boss_1_defeats` is hardwired (progression.rb:120,
  save schema row). A `boss_2_defeats` sibling = **NEW (v20 ask)** —
  save-schema touch, named for the grill, absolutely not freeze-lawful
  now.
- Drop posture: challenger already has a `drop_table`; BOSS 2 reuses
  that grammar. My v20 input already flags the parked corpse-run
  gear-drop as a natural boss-room pairing WHEN its own cycle comes —
  pointer only.

## 6. Open forks for the v20 grill (questions, not answers)

1. **Entrance rung:** does DUNGEON 2's rope carry a `requires_level`
   above 8, a `requires_defeats` (BOSS 1 ≥ 1 — making the ladder
   strictly sequential), both, or neither (pure geography, KB seed 2)?
   Value choice is the grill's; the mechanisms all exist.
2. **BOSS 2 respawn posture:** BOSS 1 today is a zone spawn like any
   other. Does BOSS 2 respawn on zone re-entry, once per session, or
   gate behind its own defeat counter? (B5's presence-block stage-2
   vocabulary is adjacent — owner's lane.)
3. **BOSS 2 verb:** seize is taken. What does the second boss threaten —
   position (arena control), the carried value, the seal itself? Grill
   debate; touches the striker-identity lane (slate candidate 2).
4. **Return posture:** free return (dungeon_1 precedent) vs C's earned
   exit — feel question, rides the ritual's verdict climate.
5. **Stations inside:** zone_8 already holds vat+altar OUTSIDE the
   entrance (the "base camp" read). Does DUNGEON 2 stay station-less
   (B2 no-bank-in-deep law, basements precedent — owner "depot" verbatim
   banked s85) with the zone_8 pair as its depot? My read: yes, and the
   geometry already says so — but it's the grill's call.
6. **BOSS 1 relationship:** does defeating BOSS 2 feed anything back
   down the ladder (e.g. a low_quay/zone_7 cue), or is the frontier
   self-contained this cycle?

## 7. Freeze-hygiene statement

Written under the armed freeze: no `data/**` or `src/**` edits, no
balance numbers anywhere in this doc (density stated qualitatively;
rungs named as mechanisms with values deferred), ritual spec §9 unread,
no peer-feel survey conducted — my own recorded impressions (v20 input
doc) are the only feel source cited. LDtk untouched; transcription is
post-verdict WB-pipeline work (T1-T5 precedent: one session, either
seat).
