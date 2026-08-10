# D0 — Thin loot loop (spec)

**Date:** 2026-08-10 · **Status:** REVISED after adversarial review (code-verifying
reviewer, verdict REJECT on draft: 2 HIGH / 1 MEDIUM / 2 LOW findings, ALL folded into
the text below; the reviewer confirmed the determinism, ownership, tick-ordering, and
swap-masking claims against code. Reconciliation record:
`drafts/_d0-spec-review-reconciliation.md`) · **Predecessor:**
A0.5 kit specials + pack mark (`2026-08-09-a0.5-kit-specials-pack-mark-design.md`,
fun-verified through merge `157af7b`). **Binding upstream:** the 5 design laws
(`docs/design-corpus/design-review-reconciliation.md`), the death-economy design
(`docs/design-corpus/death-economy-design.md` — D0 staging section is this spec's
contract), the A0/A0.5 combat laws, the de-slop rule, and the measured cadence table
(`drafts/_d0-cadence-measurements.md`).

## Why this increment (owner directive, 2026-08-10)

Owner verdict after fun-verifying A0.5: *"yeah it feels good, now needs more variety and
progression sense."* Owner promoted **D0, the thin loot loop** — explicitly NOT bundled
with A1 gambits. The loop under test: kill a Rusher → a deterministic drop appears on its
tile → decide to pick it up → the value rides ONE body at risk → decide when to walk it
home → bank it at the Nest station → the banked total is permanently safe within the run.

**Fun thesis:** *the walk back is a decision, not a commute.* Carried value converts every
"one more fight" into a wager, and the banked number is the run's memory — the first thing
in this game that death cannot take.

D0 promotes **three things at once** (death-economy doc, named as required): the
**interact verb**, the **currency/loot substrate**, and the **carry HUD**.

## Naming discipline (de-slop rule, owner-set)

*Glean* (the currency), *drop*, *carried*, *banked*, *bank station*, *interact* are
**internal spec-speak**, never player-visible. **D0 ships zero new player-facing
strings** — the station is a fixture + numeral, the carry HUD is a numeral, and no new
label/line/name renders (A0.5 precedent: no copy surface → the grok-voice-consult has
nothing to adjudicate this increment; it fires when the bible session binds the order-form
items). The fiction order form additions are at the end.

## Reference wall

- **Tibia loot-and-bank** — the hunt's profit is only real once it reaches the depot; the
  walk home with a full bag is the game's signature tension
  (`docs/design-corpus/tibia-research.md`). D0 imports the carried/banked split exactly.
- **Death-economy design laws 1–2** (`death-economy-design.md`) — carried vs banked as the
  only two loot states; banking as the safety verb; the banked stash is never taxed.
- **Vlambeer** — every kill pays visibly (drop appears on the kill tile, on camera, same
  tick as the corpse). No dry kills: the drop table's minimum is 1, variance comes from
  the occasional bonus, not from droughts.
- **Risk-of-Rain-style pickup-by-deliberate-act** (transformed): value on the floor is a
  choice, not a magnet — possessed-only, interact-only pickup keeps "which body holds the
  value" a decision.

## The six design challenges — resolved

### 1. Progression-sense honesty (+ the owner gate)

**Honest statement: in D0 the banked total has no spend.** Body fees are D1, insurance
marks are D2 — so banked is, mechanically, a score. What D0 actually tests is whether
**accumulation with carry-risk** produces progression-sense on its own: the number
survives wipes, only ever grows, and every unit in it was walked home under threat.

The gate owns this honestly: fun-verify question 2 asks *"did the banked total feel like
progression, or just bookkeeping?"* — and **"bookkeeping" is an acceptable verdict**, not
a D0 failure. It routes forward to D1 (corpse-run stakes and the first spends), never to a
D0 re-tune that inflates drop rates to fake a signal. The banked number is deliberately
quiet (visible only at the station) so any progression-sense the owner reports comes from
meaning, not from a persistent score ticker begging for attention.

### 2. Cadence — measured, not assumed (RESOLVED pre-spec)

Measured 2026-08-10 with the sim's own `FlowField` BFS on the real zone JSONs
(`drafts/_d0-cadence-measurements.md`): bank round trips run **10.4 s (nearest spawn,
striker) to 32.9 s (deepest spawn, blocker)** against a 300-frame (5 s) rusher respawn,
over a 9→45-tile spawn-depth spread. Banking is NOT trivial at current map scale; the
walk home re-crosses live pressure and deeper hunting means longer, riskier returns.
**D0 proceeds with no map growth (no silent A3) and no artificial friction** (no carry
slowdown, no bank fee, no drop weight — none are needed and all are parked). The caveat
is recorded in the measurement file: those are unopposed floors; combat only lengthens
them. The fun-verify telemetry (frames between banked events, from the replay/event log)
re-adjudicates with real numbers.

### 3. One increment, not D0a/D0b

**One vertical increment.** The death-economy doc licenses a split if the bill "reads as
two increments"; it does not. An interact verb with nothing to pick up is unfeelable (a
key that does nothing in a capture — violates "every commit changes what the player sees,
hears, or feels"); drops with no bank is a decision loop with no second half (pick up —
then what?). The smallest FEELABLE unit is the whole loop, and the whole loop is small:
one entity type, one verb, two ledger fields, two HUD numerals. Sized against A0.5:
strictly smaller (no state-machine refactor; the interact verb reuses the shipped
edge-trigger machinery verbatim).

### 4. Determinism under the replay seed

- **Drop counts come from the seeded sim PRNG** (`World#@rng`, `Random.new(seed)` —
  plumbed since A0, unused until now; D0 is its first consumer). Roll shape:
  `table[@rng.rand(table.length)]` over a data-defined integer table — weighted variance
  with no floats.
- **Call-order determinism:** rolls happen inside the `:actor_died` bus handler
  (`World#wire_events`), and the bus processes events in emit order, which is fixed
  iteration order — so the PRNG consumption sequence is identical across replays with the
  same seed + script. Standing rule recorded here: **every future `@rng` consumer must be
  driven by sim events or fixed-order sim iteration** — never by render/frame-skew state.
- **Decay is a `frames_left` countdown decremented in `tick_world`** — the Volley-impact
  pattern (A0.5 review finding F2), NEVER an absolute frame, because hitstop advances
  `@frame` while freezing the sim. Decay therefore pauses during hitstop and during the
  wipe veil by construction, deterministically.
- No wall-clock anywhere; the interact lane replays through the existing
  `expand_script` hold/frames machinery with zero `core/input.rb` changes
  (`ScriptedInput` passes arbitrary action symbols — verified A0.5 pattern).

### 5. Ownership + lifecycle — exact

| State | Owner | Death of that body | Wipe | Zone transition | App restart |
|---|---|---|---|---|---|
| **Drop** (on floor) | Sim, per-zone list | — | persists, keeps decaying | persists, keeps decaying | gone |
| **Carried** | Creature (`@carried`), swap-inert | **VANISHES** (`:carried_lost`) | vanishes per body | rides the creature through the gate | gone |
| **Banked** | Pack (`@banked`) | untouched | **untouched — the point** | untouched | gone (session-only) |

- **Drops** live in a per-zone hash (`@drops`, same shape as `@humans`/`@corpses`); the
  `drops` accessor exposes the current zone's list (renderer draws only what's present).
  **Decay ticks across ALL zones every `tick_world`** — nest time is real time, matching
  the corpse-term decision already recorded in the death-economy doc ("decided now so the
  capture script doesn't encode an accident"). Leaving drops behind to bank is a real
  cost. Drops are deliberately NOT cleared by `enter_zone` — they are world state, not
  combat effects; `@projectiles`/`@impacts` clearing is unchanged.
- **Drop placement:** the victim's `tile` at `:actor_died` processing time — the same
  read `leave_corpse` uses, so the drop always sits on the corpse. **Merge rule
  (review finding 3):** a new drop on an occupied tile merges into the existing drop —
  amounts sum, but the decay clock does **NOT** reset: the pile keeps the FIRST kill's
  clock. A reset clock + the 5 s rusher respawn would make any camped tile an immortal
  zero-risk stash (kill onto the pile every ~6 s, refresh forever), and floor-hoarding
  dominates the carry wager D0 exists to measure. With the older clock, floor storage is
  hard-bounded at one decay window from the first kill. One drop entity per tile,
  always — deterministic pickup target by construction.
- **Gate-tile drops are accepted losses** (review finding 4): humans can die on a
  transition tile; the possessed resting there transitions the same tick, so in live
  play the drop rots. (A frame-perfect scripted interact CAN grab it — controller runs
  before `check_transition` — deterministic either way.) Rare, self-punishing for
  fighting on the doorstep, no special case in code.
- **Carried vanish-on-death** (D0 death rule; corpse containers are D1's whole point):
  the World's `:actor_died` handler, for pack members with `carried > 0`, emits
  `:carried_lost {actor, amount}` and zeroes the creature's carried. `revive!` also
  zeroes it (belt + suspenders; the wipe already cost it).
- **Banked lives on `Pack`** — the Pack object is created once in `spawn_pack` and
  survives `respawn_pack` (only members revive), so banked is wipe-safe **by
  construction**, not by a copy-restore dance.
- **Session-only persistence — decided, not smuggled:** banked dies with the process.
  The progression signal under test is *within-run* accumulation surviving death/wipe;
  restart-persistence would add a save system (new file format, load path, versioning)
  that serves no fun-thesis need and is explicitly out of scope. If the D1+ economy ever
  needs cross-run banking, it arrives as its own reviewed increment.

### 6. Scope contract v4 + checkpoint

Checkpoint entry landed 2026-08-10 (`c3ced8d`). CLAUDE.md scope contract updates to v4
in the same change set as this spec: current increment = D0, naming the three promoted
things (interact verb, currency substrate, carry HUD); OUT-list gains explicit D1/D2
exclusions (corpse containers, body fees, wipe fines, insurance). Controls/commands
lines update when the implementation lands them.

## Mechanics

All numbers are **hypotheses** → `data/**/*.json` (zero constants in code,
non-negotiable #3).

### The drop (one fungible type — spec-speak *glean*)

- `kits.rusher.drop_table: [1, 1, 2]` — on death, roll one index from the seeded sim
  PRNG; the value is the drop amount. Kits without a `drop_table` drop nothing (husk has
  none; pack creatures never drop — no friendly farming loop).
- Minimum 1 (every kill pays — Vlambeer; a 0-drop reads as a bug, not variance); the
  occasional 2 is the variable-reward beat. The table is data — reweighting is a JSON
  edit.
- Drop entity: `{tile:, amount:, frames_left:, decay_frames:}` — a plain hash, the
  impacts/corpses pattern. The fourth field carries the decay TOTAL so the renderer can
  compute the fade fraction without an owner backref or a balance read (review finding
  5 — `draw_impacts` derives its total from `impact[:owner]`, which drops don't have).
  `drops.decay_frames: 1800` (30 s — enough to finish the local fight and sweep, roughly
  one deep round trip; combined with the no-reset merge rule, not enough to treat the
  floor as storage).
- Decay end: entity removed, `:drop_decayed {tile:, amount:}` emitted (harness aims at
  it; the loss is a real event, not a silent GC).

### The interact verb (one key, one lane, one path)

- **`H / F`** (right-hand home row / left-hand home row — the shipped mirrored-pairs
  scheme). `BINDINGS` +1 line (61→62, cap safe). Harness lane `"interact"` — schema
  change is additive, `expand_script` handles it as-is.
- Joins `PossessedController::ACTIONS` and **`EDGE_TRIGGERED`** — masked by `rearm!` on
  BOTH voluntary and forced swaps, rising-edge detected by the existing `pressed?`
  machinery. A held interact never ghost-fires across a swap (law-4 semantics, verbatim
  from special/mark).
- Controller wiring mirrors mark exactly: `view.interact(creature)` guarded by
  `respond_to?` so existing nil-view tests stay green.
- **`World#interact(source)`** — the single shared interaction path:
  1. Refuse unless `source.equal?(possessed)` (possessed-only; allies never pick up —
     "which body holds the value" must stay a player decision).
  2. Refuse if dead, staggered, or `attack_state != :idle` (consistent with every other
     verb; no banking mid-Slam).
  3. **Pickup first:** a drop on the possessed's tile → creature's carried += amount,
     drop removed, `:drop_picked_up {actor, amount, carried}`. Whole pile, always
     (sub-pile pickup is inventory-grid territory — OUT).
  4. **Else bank:** possessed on the bank-station tile AND `carried > 0` → pack banked
     += carried, carried = 0, `:banked {actor, amount, banked}`.
  5. Else: silent no-op (refusal has no error feel — same doctrine as special-on-cooldown).
  Pickup-before-bank priority is decided now for the drop-on-station edge case (can't
  occur with current spawns — nest has no humans — but tests need the rule).

### The bank station (data-defined)

- `data/zones/nest.json` gains `"stations": [{ "type": "bank", "at": [12, 8] }]` and a
  `station` palette entry. `[12, 8]`: on the corridor row two tiles west of pack spawn —
  discoverable on every walk-out, but NOT on the gate path (banking is a small deliberate
  stop, and respawn never lands you already standing on it).
- `Core::TileMap` parses + validates stations (passable tile or `BadMap`), exposes
  `station_at(tx, ty)`. World reads it through the map — zero station knowledge outside
  data.
- Render: a distinct fixture rectangle (palette-driven) + the **banked total as a
  numeral floating above the station, drawn only while the possessed is within 3
  tiles** (3, not 2 — the walker commits the tile at step START while the pixel tween
  trails, so a body that LOOKS adjacent can already read as 3 tiles away; impl-review
  finding 2 synced this number). Quiet-HUD law: banked is visible at the station,
  nowhere else.

### Carry HUD (the third promoted thing)

- The possessed bar (and only it) gains a carried-count numeral in a reserved slot right
  of the special pip (x≈332 in the shipped layout). Rendered only when `carried > 0`
  (quiet); the slot is reserved so layout never shifts (stable dimensions across
  swap/death — the element follows possession like the wide bar + white edge already do).
- Amends the HUD law: "Three HP bars + exhaust pip + special pip per bar **+ carried
  numeral on the possessed bar**. Nothing else."

### Drops on screen

Small centered square in a hue nothing else owns: **magenta/violet band** (review
finding 2 — the draft claimed teal was free and the mark was magenta; the CODE says
otherwise: `MARK_GLYPH = Gosu::Color.new(255, 75, 235, 205)` renders r75/g235/b205 =
**teal**. The shipped teal mark passed 17 vision checks, so code is intent and the A0.5
docs' "magenta" was a doc error — recorded here, not silently). A full hue scan of
`renderer.rb` constants: pale bone (humans), orange family (pack), white (ring/slash),
crimson/red-yellow (hurt/telegraph), cyan (windup), green-cyan (lunge/mark), pale warm
(projectile/volley), gold (gates). Magenta/violet is genuinely unclaimed. Size steps
with amount (1 vs 2+ readable at a glance); alpha ramps down over the last third of
`frames_left` against `decay_frames` (decay is visible, like corpse fade). Vision check
below.

## Telemetry (events ARE the telemetry — no new persistence)

Five new event symbols, registered on first use (non-negotiable #4): `drop_spawned`,
`drop_picked_up`, `drop_decayed`, `banked`, `carried_lost`. The harness `WorldScene`
already logs every subscribed event with its frame number — frames-between-banks, amount
banked, and carried-lost-on-death all fall out of the replay log with zero new
infrastructure. The fun-verify reads: median frames between `banked` events, banked
amount distribution, `carried_lost` totals vs `banked` totals (the risk-realization
ratio).

## Determinism & harness (Rule 2, blocking as always)

- New gate script **`harness/scripts/loot_loop.json`** (seed 20260810, event-log-aimed
  captures). Required beats, in order, all on-camera for the possessed viewport (A0
  camera law): (1) kill → drop appears on the corpse tile; (2) interact pickup + carried
  numeral appears; (3) carry through the gate into the nest; (4) bank at the station —
  numeral moves from bar to station display; (5) re-enter district, pick up again, die
  carrying → forced swap + `carried_lost` (the vanish is asserted by event + the numeral
  absence on the new body's bar); (6) one drop decays — asserted via `drop_decayed`
  event, on-camera if the script route allows it cheaply. **Plus (7), review finding 1:
  the script must also satisfy the EXISTING fail-polarity checks** — `possessed_readable`
  / `possession_ring_moves` / `corpses_persist` fall out of beats 1–5, but
  `projectile_visible` does not (rushers are melee): the route must include one
  possessed-lobber shot with a capture aimed at the shot in flight.
- Existing `world_loop.json`, `district_hunt.json`, `specials_chain.json` stay untouched
  as regression gates. Blocking gate set for the merge: **all four** double-replay +
  MD5 + vision.
- **Three vision checks APPENDED** (17→20, never weakening the existing 17). **Hatch
  polarity is load-bearing (review finding 1):** `rake gate` runs ONE shared checklist
  (`Rakefile` hardcodes `--checks harness/gate_checks.json`) against every script, and
  the three existing scripts have no interact lane — so all three new checks MUST carry
  the pass-true escape hatch ("if this replay never exercises X, pass with
  why='not exercised'", the `specials_distinct` precedent), NOT the fail-polarity hatch
  (`possession_ring_moves` style), or the existing regression gates become unsatisfiable
  the moment the checks land. `loot_loop.json` is the script that exercises all three
  for real.
  - `drops_read_as_pickups` — glean drops read as desirable pickups, distinct from
    corpses, projectiles, telegraphs, the mark glyph, and gate tiles; a near-expiry drop
    visibly fading counts as decay legibility if present. No drops in replay → pass with
    why='not exercised'.
  - `carried_count_reads` — when the possessed carries, a numeral reads on the possessed
    bar only; layout identical to non-carrying frames otherwise. No carrying in replay →
    pass with why='not exercised'.
  - `bank_station_reads` — the nest fixture reads as a distinct interactable place, and
    the banked numeral is legible when the possessed is near it. Station never visited →
    pass with why='not exercised'.
- `rake perf` stays blocking; drop decay + interact checks are O(drops) per tick, drops
  are capped by faucet rate × decay window (worst case ~a dozen live entities).

## Quantitative scope rails (checkable numbers, not vibes)

**1** new sim entity type (drop) · **1** new input lane (interact) · **1** new creature
field (`carried`) · **1** new pack field (`banked`) · **1** data-defined station type ·
**5** new event symbols · **2** new HUD elements (carried numeral, station banked
numeral) · **3** appended vision checks · **0** new human kinds · **0** meters · **0**
persistence files · **0** new player-facing strings. Anything exceeding a rail goes to
PARKING_LOT, not to code.

Verified bill: `core/input.rb` ZERO changes · `window.rb` +1 binding line ·
`controllers.rb` ~+6 lines (lane + wiring) · `creature.rb` ~+10 (carried field) ·
`pack.rb` ~+8 (banked) · `world.rb` ~+70 (drops, interact, wiring, events) ·
`tile_map.rb` ~+12 (stations) · `renderer.rb` ~+55 (~340 total; the ≤300 cap is on
window.rb) · `combat.json` + `nest.json` + gate checks + new script. No state-machine
changes; no AI changes.

## Build order (kill-cheap)

1. **Drop substrate** (data `drop_table` + seeded roll in the `:actor_died` handler +
   tile entity + merge + all-zone decay + `drop_spawned`/`drop_decayed`): already
   feelable — kills leave a glowing pile that rots. The PRNG's first consumer is the
   riskiest determinism item; prove double-replay identity here.
2. **Interact verb end-to-end** (lane + `EDGE_TRIGGERED` + controller wiring +
   `World#interact` pickup path + `drop_picked_up`): the edge-across-forced-swap
   semantics are the second-riskiest item; test both swap kinds before anything else
   lands on the verb.
3. **Carried ledger + vanish-on-death** (`carried` field, `:carried_lost`, `revive!`
   zeroing, swap-inertness tests).
4. **Bank station** (nest.json stations + TileMap parse/validate + bank path +
   `Pack#banked` + `:banked` + wipe-survival test).
5. **HUD + renderer** (drops, station fixture, carried numeral, station numeral) +
   `WorldScene` event subscriptions.
6. **`loot_loop.json` + 3 appended vision checks** + full gate set.

Each step: test-first, commit-per-task, suite green before the next.

## Edge cases (decided now so tests don't guess)

- **Held interact across forced swap:** masked by `rearm!` via the deferred
  `@rearm_needed` path — must not ghost-pickup/ghost-bank from the new body. (Test both
  swap kinds.)
- **Interact while staggered / mid-action / dead:** refused (rule above).
- **Interact on empty tile:** silent no-op, no event.
- **Bank with carried = 0:** no-op, no `:banked` event (no zero-amount telemetry noise).
- **Drop on the station tile:** pickup first, bank on the next press.
- **Two kills, same tile:** merge — amounts sum, pile keeps the FIRST kill's clock
  (no reset; review finding 3 — a resetting clock is an immortal floor stash).
- **Kill during hitstop:** impossible (sim frozen), but decay explicitly pauses during
  hitstop — `frames_left` only decrements in `tick_world`.
- **Drop under a standing creature:** legal; drops don't block movement or spawning
  (they are not actors — respawn deferral ignores them). Pickup just requires standing
  on it.
- **Possessed dies same tick as pickup:** event order within the tick is fixed
  (controller acts before `resolve_attacks`); pickup lands, then death vanishes it —
  deterministic and correct (the value was briefly his; death took it).
- **Wipe with district drops live:** drops persist and keep rotting through the veil?
  No — the veil pauses `tick_world`, so decay pauses too (deterministic; ~90 frames of
  grace nobody will notice, consistent with hitstop semantics).
- **Zone transition while carrying:** carried rides the creature (creature-owned;
  `rebind` doesn't touch it; `enter_zone` doesn't either).
- **Knockback-into-death placement:** drop uses the victim's tile at event-processing
  time — always the corpse tile, coherent on screen.

## Risks (named up front, per Rule 1)

1. **Bookkeeping risk** — banked has no spend in D0, so the progression signal may not
   materialize. Owned openly (challenge 1): "bookkeeping" is a legitimate verdict that
   routes to D1, and the gate question asks it straight.
2. **Risk-free hoarding / over-banking tedium** — post-A0.5 pack power may make the
   carry walk safe enough that banking is a chore, not a wager; or a cautious owner
   banks every 1–2 glean and feels no tension. Telemetry watches both (frames between
   banks; carried-at-bank vs carried-at-death). The worst structural variant — camping a
   respawn and refreshing a floor pile forever — is closed by the no-reset merge rule
   (review finding 3). The counter-lever for the rest, if it bites, is drop-table/decay
   tuning or human pressure (A2 territory) — never artificial friction.
3. **Legibility noise** — drops add a fourth tile-entity family to combat frames
   (telegraphs, impacts, corpses, drops). The distinct-hue rule + vision check
   `drops_read_as_pickups` gate it; if frames get muddy the fix is visual, not
   mechanical.

## Deliberately absent (PARKING_LOT or negative space, not code)

Corpse containers / own-corpse looting (D1) · body fees, wipe fines, insurance (D1/D2) ·
sub-pile pickup, inventory grids, stack limits, carry weight (inventory territory —
parked) · ally auto-pickup / drop magnetism (kills the decision) · restart persistence
(challenge 5) · drop types beyond one fungible unit, rarity, affixes · spending banked
on ANYTHING (D1+) · new human kinds, new zones · gambits (A1).

## Ship gate

`rake` green · `rake perf` green (p95 < 16.6 ms) · all FOUR gate scripts byte-identical
+ vision-pass (existing 17 + the 3 new checks) · structural checks (window.rb ≤ 300, no
balance constants in Ruby, `core/input.rb` untouched) · implementation-diff adversarial
review folded pre-merge · **owner fun-verify, exactly:** (1) *"Did bank now or push
deeper feel like a real decision?"* (2) *"Did the banked total feel like progression, or
just bookkeeping?"* (3) *"Did drops change your route and risk choices enough to add
variety?"*

---

## Fiction order form (additions for the bible session — name from INSIDE the fiction)

Extends the death-economy form (items 4 and 9 there already cover the currency and the
banking rite). D0 adds:

1. **The drop, on screen** — what a human sheds at death that the pack wants; its look
   is currently a placeholder teal square awaiting the fiction's answer.
2. **The bank station, as an object** — what physically stands in the nest that makes
   carried things safe (the death-economy form asks what the *rite* is; this asks what
   the *fixture* is — the thing the renderer draws).
3. **The carried state** — what it means for one body of the pack to hold the take
   (informs any future carry VFX; no copy ships in D0).
