# D1b exploration brief — code facts for the implementation plan (2026-08-12)

Gathered pre-plan while the spec's adversarial review ran (wf_2ccd8520-4cd).
Every fact verified by Read in this session at HEAD `d65f9b9`. The plan binds
to THESE, not to memory.

## Input / dodge fix (spec §6 bug bundle)

- `PossessedController` (controllers.rb:11-68) ALREADY owns an edge-trigger
  mechanism: `pressed?(input, action)` (56-61, per-action previous-frame
  state) — used today by special/mark/interact (26-28).
- `EDGE_TRIGGERED = %i[attack dodge special mark interact]` (13) — that list
  is the SWAP-MASK list (rearm! masking), not tick semantics. Dodge is
  already in it.
- The bug: line 33 `if down?(input, :dodge)` — level-triggered; while held,
  the walk `elsif` (35-36) is starved. Fix candidate: `pressed?(input,
  :dodge)` — one word, uses the existing mechanism. Note: on the single
  press frame with a cooldown-refused dodge, walking is suppressed for that
  1 frame (same tie semantics as attack/special) — spec behavior allows it.
- `start_attack if down?` (42) is DELIBERATELY level-triggered (hold to keep
  swinging) — do not "fix" it by analogy.
- rearm! masking law (4-10): held movement survives swap, combat keys mask.
  Dodge switching to pressed? interacts fine (masking filters down?, and
  pressed? wraps down?).

## Interact / stations (spec §2-3)

- One shared interact path `World#interact` (world.rb:264-293): possessed-only
  (265), idle/unstaggered/alive gate (266), pickup-first (267-273), corpse
  load second (277-286), THEN station: `map.station_at(*source.tile)` with
  `station[:type] == "bank"` (287-291). Dispatch extension point = that tail.
- Bank emits `:banked (actor, amount:, banked:)` (291). `Pack#bank!` (pack.rb:24-26)
  just adds; comment carries the never-taxed law.
- Stations live in zone JSON: `nest.json` `"stations": [{"type": "bank",
  "at": [12, 8]}]`; palette has ONE shared `"station"` color (nest.json:10) —
  per-type colors are a data change the spec requires.
- `pack_spawn` = [[14,8],[13,8],[15,8]] (nest.json:31), indexed per member
  (world.rb:718 `pack_spawn[i]`).

## Pack / creature / wipe (spec §1, §4)

- `Pack` (pack.rb): `@banked` read-only attr; `bank!` adds; NO spend today.
  `living`, `wipe?`, `swap_next!` (roster-order), `forced_swap!`
  (nearest-Chebyshev from dead body, roster-index tiebreak, pays stagger).
- `Creature#revive!` (creature.rb:245-257): hp=max, clears action/exhaust/
  iframes/stagger/dodge_cooldown/hurt/carried, clear_taunt!, rebind(map:,
  tile:). THE only HP restore in the sim. NB revive! zeroes CARRIED — fine
  for wipe (carried already dropped as pile on death) — verify for vat
  regrowth (a dead body has no carried by then; death drained it).
- Creature-owned swap-inert state precedent for `god_mark`: carried
  (creature.rb:221-229), taunt (200-217, victim-owned, pure reader law).
- Wipe path: `tick` → respawn timer (world.rb:106-110) → `respawn_pack`
  (712-721): releases ALL zones' taunt locks first (713-716 — impl-review
  law), sets @zone_name = HOME_ZONE, revives each member at pack_spawn[i],
  `enter_zone(HOME_ZONE, map.pack_spawn)`, emits :pack_respawned.
- `World#actors` (78) REJECTS dead → dead pack bodies do not render as LIVE
  actors. ⚠️ CORRECTED by the spec review (wf_2ccd8520-4cd): dead bodies DO
  leave fading corpse RECORDS (`faction: actor.faction` at world.rb:788,
  CORPSE_FADE_FRAMES at world.rb:747) — the judgment must clear pack-faction
  corpse records (bulk filter) or let the fade finish; spec §Presentation-5
  now says so. Judgment's visual surface = nest spawn tiles + HP-bar row
  (renderer.rb:397-412, HP_DEAD fill).

## Events / telemetry (spec §Events)

- Registry: `World::EVENTS` (world.rb:20-26), `@bus.register(*EVENTS)` (41);
  unknown symbols raise (event law). Add the 7 new symbols there when first
  used.
- `Telemetry` (telemetry.rb): subscribes in initialize, counts in @counts
  hash; d1 line + a2 line patterns (45-61). FN-3 d1b line = same shape.
- deepest_band bug: accumulates max gate-DISTANCE at :drop_spawned (38-42),
  converts to band at summary time vs CURRENT zone (65-71). At-kill fix:
  look up `@world.map.drop_gradient` band inside the :drop_spawned handler
  (the event fires in the zone where the drop spawned — world.map is that
  zone at emission time), store max band INDEX.

## Renderer (spec §Presentation)

- Station-gated text precedent: banked total draws ONLY when possessed
  stands at the station (renderer.rb:217-230, reads world.possessed.tile) —
  the cost-readout pattern to extend per fixture type.
- Identity = color + silhouette; possessed brightened (renderer.rb:3);
  ALLY_DIM overlay (17). Mark glyph must survive both possessed-bright and
  ally-dim draw paths.
- HP bar row: renderer.rb:397-430 (kit-colored, possessed wider, HP_DEAD
  fill for dead) — candidate surface for a mark pip on the bar (spec asks
  glance-readability; bar pip + body glyph both read).
- Renderer reads sim, never mutates (taunted_target purity law,
  creature.rb:208-217).

## Data loading

- World reads config as `data["balance/combat"]`, `data["balance/death"]`,
  `data["balance/threat"]` (world.rb:36-39) — verify DataStore auto-loads
  any new `data/balance/economy.json` by path key (src/core/data_store.rb;
  expected: loads data/**/*.json by relative path, but CONFIRM at plan time).

## Threat retunes (spec §5)

- Keys live in `data/balance/threat.json` (threat.json read at world.rb:39):
  `proximity_switch_margin_tiles`, `lowhp_switch_pct` per A2 spec §Data.
- Retarget cue: humans tick in `tick_human`; hurt_frames-style timer
  precedent lives on Creature (`@hurt_frames`, decremented sim-side, read by
  renderer). `assign_human_focus` (world.rb:332-341) emits :human_retargeted
  with cause — the cue timer stamps there (sim-side), renderer reads.

## Open items for the plan's own exploration pass

- `enter_zone` full body (dead-member rebind semantics when the pack
  changes zone mid-session — regrowth-at-nest interacts if tribute fires
  right before a zone flip).
- DataStore key derivation (economy.json auto-load).
- Harness EVENT log: whether `:banked` amounts already print (pilot
  re-anchor step needs units/session; lens-3 of the review checks this).
- vat_economy.json two-wipe feasibility (staging both a marked and an
  unmarked wipe deterministically in one stream).
