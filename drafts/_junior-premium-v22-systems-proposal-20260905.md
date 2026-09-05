# PREMIUM v22 — SYSTEMS proposal (items · bag · equipment · attributes · bank · vendors · drops · status)

Junior seat, 2026-09-05 14:40. Direction (Junior, verbatim intent): "crie itens,
inventario, equipamentos, equipamentos do player, perfil de skill e atributos,
banco e tudo que tem em mmorpg, crie npc para comprar alguns equipamentos,
coloque drope nos monstros e configure em uma bag de forma inteligente,
adicione venenos, queimadura e coisas do tipo."

**Status: PROPOSAL.** Every piece below is a SIM change (save schema, digest,
protocol verbs) that lands in BOTH peers' saves. The v22 grill running today
asks the question directly (Q7 "items: promote minimal drops-with-identity now
or v23?", dev rec PARK) and the standing law is ONE gated SIM piece per cycle.
So: this document is the complete plan, cut into gated tickets, executable the
minute both seats say GO — nothing here touches `src/` until then. What DID
land today without a vote (presentation + OFF-by-default sim): drawn
characters, dual-grid tiles, possession halo, HUD panel, gem drops, ally brain
(enabled=false).

## 0. What already exists (build on it, never beside it)

| Have | Where | Reuse |
|---|---|---|
| Currency: `banked` (pack), carried value per body, drops (glean) with bands | `Game::Pack`, `World#drops` | COINS = banked. Drops stay the value channel; ITEM drops are a second record type on the same tile grammar |
| Consumable: provisions (flask) bought at the bank station, `sustain` verb | `Game::Stations#sustain` | the first item KIND; generalize to a stack in the bag |
| Stations: bank, seal, altar, vat, totem (interact verb, price sheet) | `Game::Stations`, `data/balance/economy.json` | VENDOR = a station type with a stock list |
| Progression: pack level + xp, `max_hp_for` | `Game::Progression` | ATTRIBUTES hang off the same level (points per level) |
| Save schema 2 + strict decoder + migrations | `Game::SaveState`, `App::SaveStore` | schema 3 adds `bag`, `equipment`, `attributes`, `bank` |
| Status: poison (DOT), burn (aura field), seized, petrified (stone), stagger | `Creature#poison!/burn!` | STATUS = data-registry of effects; icons already in the HUD (poison, seized) |
| Kits + boss block, skill rotations | `data/balance/combat.json` | EQUIPMENT modifies kit numbers through one resolver |

## 1. Data (zero constants in code — every number lives here)

### 1.1 `data/items.json` — the catalog
```json
{ "items": {
  "flask_sap":      { "kind": "consumable", "stack": 10, "slot": null, "price": 5,  "sell": 2,
                      "use": { "heal": 40 }, "icon": "flask", "tier": 0 },
  "antidote":       { "kind": "consumable", "stack": 5,  "price": 8,  "sell": 3,
                      "use": { "cure": ["poison"] }, "icon": "vial", "tier": 0 },
  "ember_salve":    { "kind": "consumable", "stack": 5,  "price": 12, "sell": 4,
                      "use": { "cure": ["burn"], "resist": { "burn": 600 } }, "icon": "jar", "tier": 1 },
  "blade_iron":     { "kind": "weapon", "slot": "hand", "for": ["striker"], "price": 60, "sell": 20,
                      "mods": { "damage": 4 }, "icon": "blade", "tier": 1 },
  "blade_shard":    { "kind": "weapon", "slot": "hand", "for": ["striker"], "price": 180, "sell": 60,
                      "mods": { "damage": 9, "crit_pct": 0.08 }, "icon": "blade", "tier": 2, "family": "serpent" },
  "shield_ring":    { "kind": "weapon", "slot": "hand", "for": ["blocker"], "price": 70, "sell": 24,
                      "mods": { "armor": 3, "knockback_tiles": 1 }, "icon": "shield", "tier": 1 },
  "sling_sinew":    { "kind": "weapon", "slot": "hand", "for": ["lobber"], "price": 65, "sell": 22,
                      "mods": { "damage": 3, "range_tiles": 1 }, "icon": "sling", "tier": 1 },
  "jerkin_root":    { "kind": "armor",  "slot": "body", "for": null, "price": 50, "sell": 16,
                      "mods": { "armor": 2, "max_hp": 10 }, "icon": "jerkin", "tier": 1, "family": "root" },
  "plate_basalt":   { "kind": "armor",  "slot": "body", "for": ["blocker"], "price": 220, "sell": 70,
                      "mods": { "armor": 6, "resist": { "burn": 0.5 } }, "icon": "plate", "tier": 2, "family": "ember" },
  "charm_moss":     { "kind": "trinket", "slot": "charm", "price": 90, "sell": 30,
                      "mods": { "resist": { "poison": 0.5 } }, "icon": "charm", "tier": 1, "family": "spore" },
  "charm_tide":     { "kind": "trinket", "slot": "charm", "price": 120, "sell": 40,
                      "mods": { "dodge_cooldown_pct": -0.2 }, "icon": "charm", "tier": 2, "family": "tide" },
  "shard_amethyst": { "kind": "material", "stack": 20, "price": 0, "sell": 6, "icon": "shard", "tier": 1 },
  "scale_marble":   { "kind": "material", "stack": 20, "sell": 9, "icon": "scale", "tier": 2 },
  "coal_living":    { "kind": "material", "stack": 20, "sell": 8, "icon": "coal", "tier": 2 },
  "cap_spore":      { "kind": "material", "stack": 20, "sell": 4, "icon": "cap", "tier": 1 },
  "bell_pink":      { "kind": "material", "stack": 20, "sell": 7, "icon": "bell", "tier": 1 }
}}
```
Names are FUNCTIONAL (player-visible strings live in `data/strings/*.json`:
`item.blade_iron.name = "IRON BLADE"`, pt-br "LÂMINA DE FERRO") — no lore names
in the repo (D9). Icons are one 16x16 sheet `data/art/items.png` (generator
`tools/gen_item_icons.py`, md5-pinned, same craft rules as the sprites).

### 1.2 Slots (per body): `hand` · `body` · `charm`. Three bodies × three slots
= 9 equipment cells. `for` restricts a weapon to a kit (Fio's blade never fits
Aro's hand); armor/charms are free unless `for` says otherwise.

### 1.3 `data/balance/attributes.json`
```json
{ "points_per_level": 1, "max_per_attribute": 20,
  "attributes": {
    "vigor":   { "per_point": { "max_hp": 6 } },
    "might":   { "per_point": { "damage": 1 } },
    "grit":    { "per_point": { "armor": 1 } },
    "pace":    { "per_point": { "dodge_cooldown_pct": -0.02, "step_frames_pct": -0.01 } },
    "focus":   { "per_point": { "special_exhaust_pct": -0.03 } } } }
```
Points are PACK-level (shared progression) but spent per BODY (the Trina are
three temperaments). Respec: at the altar, price in economy.json.

### 1.4 `data/balance/drops.json` — monster loot tables
```json
{ "tables": {
  "husk":       { "coin": [1, 3],  "rolls": 1, "entries": [["flask_sap", 0.06], ["jerkin_root", 0.01]] },
  "stinger":    { "coin": [2, 4],  "rolls": 1, "entries": [["bell_pink", 0.35]] },
  "warden":     { "coin": [6, 10], "rolls": 2, "entries": [["bell_pink", 0.8], ["charm_tide", 0.05]] },
  "serpent_a":  { "coin": [3, 6],  "rolls": 1, "entries": [["shard_amethyst", 0.4], ["antidote", 0.05]] },
  "serpent_b":  { "coin": [4, 7],  "rolls": 1, "entries": [["scale_marble", 0.4]] },
  "serpent_boss": { "coin": [40, 60], "rolls": 3, "entries": [["blade_shard", 0.5], ["scale_marble", 1.0], ["charm_tide", 0.25]] },
  "ember_a":    { "coin": [4, 8],  "rolls": 1, "entries": [["coal_living", 0.4], ["ember_salve", 0.06]] },
  "ember_boss": { "coin": [60, 90], "rolls": 3, "entries": [["plate_basalt", 0.5], ["coal_living", 1.0]] },
  "spore_a":    { "coin": [2, 5],  "rolls": 1, "entries": [["cap_spore", 0.45], ["antidote", 0.08]] },
  "challenger": { "coin": [30, 50], "rolls": 2, "entries": [["charm_moss", 0.6], ["jerkin_root", 0.4]] } } }
```
Rolls draw from the world's seeded RNG stream (a NEW named stream `:loot` so
existing streams keep their draw counts — the digest covers streams by draw
count; a new stream is additive). Coin rides the existing drop record (band by
depth as today); item drops are a second record `{tile, item, qty, frames_left}`
rendered as a small icon on the gem grammar (bobbing, sparkle).

### 1.5 Vendors: `data/zones/*.sidecar.json` station `{type:"vendor", at, stock:[ids], buys:["material","consumable",...]}`
— ZONE 7 (city) plaza: a general vendor (flasks, antidote, tier-1 weapons/armor)
— DUNGEON 1 mouth camp: a fence (buys materials, sells ember_salve after BRASA is reached)
Buying/selling = one protocol verb `:trade` with `{item, qty, dir}`; both seats
apply the same trade on the same tick (lockstep). Prices from the catalog ×
`economy.json vendor_markup` / `vendor_buyback`.

### 1.6 Bank: the existing bank station gains STORAGE — `bank: {items: [[id, qty]...]}`
in the save (cap `economy.json bank_slots`), deposit/withdraw through the same
`:trade` verb with `dir: :deposit|:withdraw`. Coins already bank.

### 1.7 Status registry `data/balance/status.json`
```json
{ "poison": { "dot": true, "icon": "drop_green", "cure": ["antidote"], "tint": [110, 220, 90] },
  "burn":   { "dot": true, "icon": "flame", "cure": ["ember_salve"], "tint": [255, 140, 40], "ticks": 180, "dmg_per": 3, "interval_frames": 30 },
  "stone":  { "dot": false, "icon": "stone", "tint": [200, 200, 210] },
  "seized": { "dot": false, "icon": "chain", "tint": [60, 100, 220] },
  "chill":  { "dot": false, "icon": "snow", "tint": [140, 200, 255], "step_frames_pct": 0.3 } }
```
Burn becomes a real DOT (today: aura field damage per tick) — ember_b's aura
APPLIES burn; standing in lava_deco applies burn; ember_salve cures. Chill is
the FROST family's hook (v23). Each status = one icon in the HUD row (done for
poison/seized) and a body tint pulse (done for poison).

## 2. Sim (one resolver, one verb, one record)

- `Game::Bag` — per pack: `slots` (cap `economy.json bag_slots`, 20), stacks by
  `stack`; `add!(id, qty) -> overflow`, `remove!`, `count`, `sorted` (kind →
  tier → name: "configure a bag de forma inteligente" = auto-sort + stack merge,
  consumables first, materials last, equipment in the middle; a `pin` list keeps
  the player's favorites in place).
- `Game::Equipment` — per body: `{hand, body, charm}` of item ids; `mods` sum.
- `Game::StatResolver` — kit base × (1 + pct mods) + flat mods, capped by
  `max_per_attribute`; `Creature#kit` already returns a MERGED view (boss block)
  — equipment/attributes merge in the same place. NOTHING else in the sim
  learns about items: damage/armor/max_hp/step_frames/cooldowns read the merged kit.
- Verbs (protocol, lockstep-safe): `:use_item {slot}` · `:equip {slot, body}` ·
  `:unequip {cell, body}` · `:trade {item, qty, dir}` · `:spend_point {attr, body}`.
  All routed like `sustain` today (`Game::Stations` precedent: one act per
  frame per seat, refusals named, events emitted for telemetry/manifest).
- Pickup: walking onto an item drop adds to the bag (overflow stays on the
  floor, banner "BAG FULL"); coin drops unchanged.
- Death: equipment stays on the body (the corpse carries it — the PRICED DEATH
  grill decides whether a wipe drops equipment: recommend NO, items are the
  insured layer; the fine is xp/coin).

## 3. Presentation

- Bag screen (Tab-hold or `I`): 4×5 grid of icons + qty, tooltip panel (name,
  kind, mods, price), three body columns with 3 slots each (drag = select+
  target on keyboard: pick slot, pick body). Attribute panel: 5 rows, +/−,
  points left. Bank: same grid mirrored (bag | bank).
- Vendor: stock list with prices, coins chip live, refusals in the banner slot.
- HUD: status icon row (done for 2), equipment silhouettes on the portrait
  (weapon glint) — small, optional.
- Item drops: icon on a gem base (done grammar).

## 4. Save (schema 3) + digest

`facts.bag = [[id, qty]...]`, `facts.equipment = {kit: {hand, body, charm}}`,
`facts.attributes = {kit: {vigor..focus}}`, `facts.bank = {items: [[id, qty]...]}`.
Migration 2→3: absent keys = empty (identity). CLASSIFICATION rows in
`test/game/save_state_test.rb`; digest fields per body (`equip_hash`,
`attr_points`) + pack (`bag_hash`) in `test/net/state_digest_test.rb
CREATURE_FIELDS`. Tested on COPIES of both peers' saves.

## 5. Tickets (one gated SIM piece each, in this order)

| # | Ticket | Gate |
|---|---|---|
| S1 | catalog + strings + icons (data only, no sim) | icon sheet md5 test, strings 3 locales |
| S2 | `Game::Bag` + coin/ITEM drop records + pickup + bag screen (read-only) | boot+combat test, `loot_loop` re-authored with item drops, canary rebank (new `:loot` stream is additive → prefix identity holds) |
| S3 | `:use_item` (flask migrates to the bag; `sustain` = use flask) + status registry + burn DOT + antidote/salve | poison/aura tests extended, HUD icons |
| S4 | equipment + StatResolver + `:equip/:unequip` + bag screen (interactive) | stat tests (every mod key), digest fields, save schema 3 |
| S5 | attributes + `:spend_point` + altar respec | progression tests |
| S6 | vendor station + `:trade` + bank storage | stations tests, sidecars for ZONE 7 + camp, economy rows |
| S7 | drops.json per kind, boss tables | drop_band tests, `tower4_run`/`brasa3_run` manifests gain `item_dropped` |

Each ticket: suite green → 2 gate scripts → commit. Full wall + canary rebank
protocol at the end (owner audit of the stream diff).

## 6. Decisions for BOTH peers (one line each)

- **P1** Items now (this plan) or v23 (grill Q7)? Dev rec: **S1–S3 now** (data +
  bag + consumables/status = the "minimal item layer" the owner named as step 2),
  S4–S7 after the priced-death lands.
- **P2** Equipment on death: stays on the corpse (rec) / drops / destroyed.
- **P3** Attribute points: pack-shared pool spent per body (rec) / per body earned.
- **P4** Vendor placement: ZONE 7 plaza + camp fence (rec) / every hub.
- **P5** Bag cap 20 + bank 40 (rec) / other.

## 7. What Junior can play TODAY (no vote needed)

- `data/balance/threat.json`: set `ally.enabled` and `human.enabled` to `true`
  locally → the ally brain (focus fire, drink, dodge, roles, specials) and
  coward husks. Do NOT commit that flip (canary law); tell me what you felt.
