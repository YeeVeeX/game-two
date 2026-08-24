# Difficulty tier — depth means danger (s68, 2026-08-24)

Owner datum (banked s67, verbatim): "a partir de nivel 8 siento que se
está empezando a volver muy fácil esta zona" — level 8 in 3 sessions on
the shared save, deep zones trivial. Ladder slot: owner-ratified s67
(B4 → THIS → content-fill + ZONE 8 → B1-T1 → varekka re-cut → J-3).
Council frame (Kimi Q4, `tmp/council_kimi_s67.json`, banked — no new
spend): PRIMARY = `requires_level` deep-gating · SUPPORT = per-zone
enemy stat tiers · NEVER global scaling (zone-identity law: ZONE 1
trivial at level 8 is CORRECT — the deep must bite instead).

ONE knob per re-session: this ticket is the depth-danger knob, two
composing halves (gates + tiers), both landing BEFORE ritual staging
freezes the sim numbers (measurement hygiene re-arms at staging).

## Ground facts (verified live this session)

- **Gate machinery ALL SHIPPED (progression v1, P9/T5):** tile_map
  parses `requires_level` (Integer >= 1, refuses NAMED) · Crossing#open?
  refuses on an independent AND branch (composes with `sealed` +
  `requires_defeats`) · Crossing#unmet_level feeds the "LEVEL <N>
  REQUIRED" cue (fires even on a way that is ALSO sealed — "the cue
  names its own fact regardless of siblings") · renderer way_locked?
  draws the shut slab · god-view map shows it · wall script
  `level_gate.json` + `level_gate_reads` checklist row already exist.
  Zero new mechanism — this ticket is DATA plus one seam.
- **Stat seam:** every enemy — seed, respawn, boss — flows through
  `World#add_human(zone, kit_name, tile)` (verified: seed_humans
  L1219, respawn_due_humans L1489/L1501). Coop precedent lives there
  (v18 decision 11: scale at SPAWN). Damage resolves at ONE seam,
  `World#leveled_damage` — "enemies never read a level term" today.
- **Spawn rosters:** district 12r+3rh · district_two 16r+4rh ·
  low_quay 22r+7rh+challenger · dungeon_1 **4r+1rh only** ·
  basement_1/2 **EMPTY** (no spawns, no stations — the owner's "no
  había nada interesante" is literal) · zone_7/nest/camp/slow_door
  empty · zone_8 empty (unwired).
- **Canary zones:** world_loop=nest · varekka_duel/burn_duel=low_quay ·
  vat_economy=home. None touch the deep family. The challenger (boss)
  spawns in low_quay ONLY — untouched by any tier row.
- **Importer gap (found live):** `tools/import_ldtk.rb` ENTITY_FIELDS
  whitelists Transition optionals `sealed/type/stairs_unlocked_by/
  requires_defeats` — `requires_level` is MISSING. Unknown identifiers
  refuse; a future LDtk re-export of a gated zone would refuse (or a
  sidecar-authored gate would silently vanish from the round-trip).
  The rider below closes it — the WB pipeline stays round-trip-faithful.

## Design

### A. Level gates (PRIMARY) — zone JSON transitions, shipped shape

| Way | Gate | Why this number |
|---|---|---|
| zone_7 [26,3] → basement_1 | `requires_level: 4` | first "come back later" landmark off the town hub (cum. XP 1120) |
| zone_7 [35,3] → basement_2 | `requires_level: 5` | second cellar steps once more (cum. 2000) |
| zone_7 [33,14] → dungeon_1 | `requires_level: 6` | the real dungeon; composes with its live `sealed` (independent AND) (cum. 3280) |
| zone_8 inbound (at wire-in) | `requires_level: 8` | the current frontier — RECORDED here, LANDS with the wire-in ticket's transition data |

Laws honored:
- **No retroactive lock:** every gate ≤ 8 = the live shared-save level;
  the owners bounce off nothing they have already walked. Fresh saves
  (and Junior's solo save, if below the gates) see locked ways on
  content they have NOT walked — that is the intended legibility
  ("players see unreachable space and anticipate return"). Travels in
  the async ratification note.
- Gates go on the INBOUND (deep-facing) way only; returns stay free
  (low_quay↔zone_7 `requires_defeats` precedent).
- Curve context (k=40, cap 10): cum. XP to L4/5/6/8 = 1120/2000/3280/
  5040. The owner earned 5125 kills_xp reaching L8.

### B. Stat tiers (SUPPORT) — new `data/balance/tiers.json`

```json
{ "zones": {
    "basement_1": { "enemy_hp_pct": 50,  "enemy_dmg_pct": 25 },
    "basement_2": { "enemy_hp_pct": 50,  "enemy_dmg_pct": 25 },
    "dungeon_1":  { "enemy_hp_pct": 100, "enemy_dmg_pct": 75 },
    "zone_8":     { "enemy_hp_pct": 150, "enemy_dmg_pct": 100 } } }
```

- Grammar = `dmg_growth_pct` house style: value = base + base·pct/100,
  **Integer division, no Float ever enters the balance path**.
- **Absent zone = identity = ZERO arithmetic** (coop seats=1 precedent;
  the canaries hold by construction, not by luck).
- Validation at World construction (progression parser style, refusals
  NAMED): every key names a LOADED zone (typo honesty — zone_8 IS
  loaded, merely unreachable, so its row is legal dormant data that
  goes live at wire-in); pcts Integer >= 0. Spawnless zones (basements
  today) are legal: content-fill lands INTO a pre-declared tier.
- Magnitude math at pack L8 (striker dmg 39 · blocker 39 · lobber 31;
  HP 113/227/85): dungeon_1 rusher 50→100 HP (1–2 striker hits → 3),
  dmg 12→21 (lobber dies in 4 rusher hits, not 8; blocker 11, not 19).
  Basements milder (75 HP / 15 dmg) as pre-fill cellars. zone_8
  (125 HP / 24 dmg rushers) = the L8+ frontier, dormant until wired.
- **kill_xp UNTOUCHED** (kit-keyed, stays). Recorded fork, argued: a
  tiered kill paying base XP is risk-without-XP-reward — accepted
  BECAUSE (a) one-knob law: XP pacing is a ritual-measured progression
  number, its freeze is the point; (b) the deep's reward story is the
  CONTENT-FILL ticket (stations/toll pockets/extraction — banked Kimi
  menu). If the ritual verdict says deep grinding feels unrewarding,
  the escalation is a data-only `kill_xp_pct` tier field, own
  ratification, never silent.
- Boss untouched (low_quay carries no tier row) — varekka difficulty
  is the re-cut ticket's business, not this knob's.

### C. Implementation shape (world.rb at 1793/1800 — the touch OWES its object)

- **`Game::TierSheet`** (new plain object, PriceSheet/Crossing
  pattern): construction parses+validates `data["balance/tiers"]`
  against the loaded zone list; readers `hp_for(zone, base)` /
  `dmg_pct(zone)` — Integer in, Integer out, identity when the zone
  has no row. World wiring stays ≤ +5 lines net.
- `World#add_human`: tier applies at SPAWN (coop precedent, one seam =
  seed + respawn + boss): HP via `creature.tier_max_hp!(pct)` BEFORE
  the coop scalar — **composition pin extends: kit base → zone tier
  (Integer) → coop scalar (Float, explicit .round)** — and the damage
  pct stamps on the body (`tier_damage!(pct)`, rides the life like
  home_tile; respawn re-stamps because respawn IS add_human).
- `World#leveled_damage`: the non-pack branch returns
  `base + base·tier_dmg_pct/100` off the attacker's stamped pct
  (0 = today's line exactly). Volleys/projectiles inherit — they
  store this result at launch.
- Digest: stamped pct is config-derived static per-life — the max_hp
  precedent (max_hp is not digested either); no digest_fields change,
  W1 satisfied by precedent.
- **Importer rider:** `requires_level` joins ENTITY_FIELDS Transition
  optionals + pass-through (composes the loader's Integer >= 1
  refusal — the `requires_defeats` comment's exact pattern).
- Pack never reads tiers; enemies never read level. Two disjoint
  growth laws, one damage seam.

### D. Proof obligations

1. Suite: tiers data-law test (economy_data_test pattern) · TierSheet
   unit laws (identity/refusals/math) · add_human tier+coop
   composition on a synthetic zone · respawn re-stamp · live-data law:
   zone_7→dungeon_1 refuses at L<6 even breached, opens at 6 ·
   importer round-trip carries requires_level.
2. **Canaries must hold** (world_loop `a4150c43…` · varekka_duel
   `31c699cb…` · burn_duel `fedf0452…`): untiered+ungated zones,
   identity by construction — any movement = DEFECT, never rebank.
3. **vat_economy headless md5 `61d768b8cc079c611a73098d90a89de7`**
   byte-identical pre/post (baseline re-verified live this session,
   135 lines).
4. **Rule 2 (blocking):** NEW wall script `town_gates.json` — fresh
   L1 pack starts in zone_7, walks to the basement_1 way (LEVEL 4
   REQUIRED refusal) then toward the dungeon_1 way (sealed + LEVEL 6
   line) — the zone_7 gate surface's regression script (wall 28→29;
   `level_gate_reads` already judges the grammar). PLUS re-gate
   `multi_floor_descent.json` (dungeon_1's reel moves if its fight
   timing moves — tiered rushers).
5. Difficulty numbers land BEFORE ritual staging (this ticket IS the
   pre-staging window); post-staging retunes wait for the verdict.

### What does NOT move

District/district_two/low_quay/nest (ZONE 1 family trivial-at-8 =
CORRECT) · boss stats · kill_xp · pack growth (P5) · spell growth
(P10) · save schema (gates read live level; nothing persists) ·
netplay (tier math is construction-deterministic on both seats).
