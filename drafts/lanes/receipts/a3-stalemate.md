# Receipt — lane `a3-stalemate` (branch `lane/a3-stalemate`, forked from `junior/premium-build` @ 8034192)

RECEIPT: a3-stalemate 97ce289 READY ranged-hold stalemate rule (data-gated, brain-ON only) + synthetic test; brain OFF byte-identical (3/3 canaries YES); audit §4 mechanism CORRECTED (see FINDING)

(97ce289 = the last CODE commit: de14fac rule + data + test, 97ce289 review fixes. The receipt commit itself follows it on the branch; `git log lane/a3-stalemate` shows all three.)

## What changed (owns only)

- `src/game/controllers.rb` (572 -> 628 lines; brief cap ~620 — +8, extraction candidate below)
  - `ally_engage` projectile branch: `:259` `stalled = stalemate?(...)`; `:273-278`
    `elsif stalled && advance_step(..., floor: [hold - stalemate_advance_tiles, 2].max) -> nil`
    `elsif !stalled || !aligned? -> align_step` (stalled AT the floor and on the shot line = HOLD; off-axis
    = still lines up — review finding 1). Sits between `dist > hold + 1 -> chase_step` and the old
    `align_step`. Retreat / shoot / chase unchanged.
  - `tick` `:187` `@stall&.delete(creature.name) if ally_cfg` in the free-ally `follow` branch (brain ON
    only, `ally_cfg` nil when OFF): disengaging drops the stall memory (review finding 2). The `follow`
    call itself is untouched.
  - `:314-326 stalemate?(creature, target, view, cfg)`: returns false unless `cfg[:stalemate_frames]`;
    `@stall[creature.name] = {target:, tile:, frames:}` — reset when the target object changes, the
    target's tile changes, or the target is in this ally's attack range; else `frames += 1`;
    true at `frames >= stalemate_frames`. Tick-driven (one +1 per ally tick reaching the ranged
    branch), no `Time`/`rand`, fixed order; derived from sim state so NOT a digest field (a second
    World fed the same ticks rebuilds it — netplay-safe by construction, same law as `@flow_cache`).
  - `:332-350 advance_step(creature, target, view, floor:)`: fixed `FlowField::STEPS` order; picks the
    free passable neighbor with the lowest Chebyshev distance `d` s.t. `floor <= d < dist`; tie-break
    prefers a tile on the shot line (row/col/diagonal); `face` + `step`. Never below `floor`
    (= hold - advance_tiles, min 2), so it never triggers `retreat_step` (dist < hold - 1) next tick.
- `data/balance/threat.json` `ally` block: `"stalemate_frames": 180`, `"stalemate_advance_tiles": 1`
  (`enabled` stays `false`).
- `test/game/ally_stalemate_test.rb` (new, 9 tests / 25 assertions).

Not touched (integrator guardrails): `chase_step`, the flow-field hostile step, `leash_home`, the free-ally
`follow` branch (it runs with the brain OFF too), `world.rb` (1798/1800, 0 lines), `creature.rb`, `aggro.rb`.

## How the rule works (candidate (a), audit §5)

A ranged free ally with the brain ON holds `ranged_hold_tiles` (3) and lines up its shot. If the
FOCUSED target stands on the same tile for `stalemate_frames` consecutive ally ticks while out of the
ally's own attack range (blocked line / short range / hold band), the ally stops "aligning" and
closes ONE tile toward it, down to `hold - stalemate_advance_tiles` (floor 2 — a projectile kit never
hugs). A target step, a new target, or the target entering range resets the count. Outside the
stalemate every decision is identical to the pre-lane brain (proved by `test_moving_target_keeps_the_old_hold_behavior`).

Why the old rule stalls (traced, `tmp/a3_dbg.rb`, range-1 kit, room, ember @[5,3], lobber @[2,3]):
`align_step` (`controllers.rb:355-374`) has no "stand still" mode — it picks the FARTHEST aligned free
neighbor, so at dist 3 it steps to dist 4, at dist 4 (= hold+1, not > hold+1 so no chase) it steps
back to dist 3: `rule=false: [[0,[1,3]],[16,[2,3]],[32,[1,3]],[48,[2,3]],[64,[1,3]]]` forever.
With the rule: `rule=true: [[0,[1,3]],[16,[2,3]],[32,[3,3]]]` — advance at the first free tick past
N, then hold at dist 2.

## PROPOSED numbers (owner's call — flagged, not decided)

- `ally.stalemate_frames = 180` (3 s at 60 fps; the brief's suggestion). Alternatives: 120 (2 s, snappier)
  / 240 (4 s, more patient). Only reachable with `ally.enabled: true`.
- `ally.stalemate_advance_tiles = 1` (hold 3 -> floor 2). 0 would disable the advance without deleting
  the key; 2 collapses to the floor of 2 anyway with hold 3.

## Tests (`test/game/ally_stalemate_test.rb`)

- `test_data_carries_the_stalemate_keys_with_the_brain_off` — data keys present, `enabled: false`.
- `test_stalled_out_of_range_target_pulls_the_ranged_ally_one_tile_closer` — DoD 3 (i): first reach of
  [3,3] is at tick >= N, dist >= 3 before N, holds at [3,3] after, final dist 2 = floor.
- `test_without_the_rule_the_ally_wiggles_in_the_hold_band_forever` — the pre-lane pocket, documented.
- `test_moving_target_keeps_the_old_hold_behavior` — DoD 3 (ii): target teleports every tick; tiles
  byte-identical with/without the rule; count never reaches N.
- `test_target_step_resets_the_stall_count` — reset on target step.
- `test_stalled_at_the_floor_still_lines_the_shot_up` — review finding 1: off-axis at the floor -> [2,3]
  (align) -> [3,3] (advance) -> holds; never frozen.
- `test_disengaging_clears_the_stall_count` — review finding 2: `clear_provocation!` -> follow branch ->
  `@stall["lobber"]` nil.
- `test_same_ticks_same_stream` — determinism (two controllers, same ticks, same memory).
- `test_brain_off_never_reaches_the_rule` — DoD 3 (iii): `ally_config` nil, `@stall` never allocated.

Synthetic by design (integrator word): the rule cannot fire in brasa2_run (see FINDING) — the test is
not bent toward that script. The View is a plain object over REAL `Creature`/`TileMap`/`FlowField`
(the `threat_targeting_test` pattern), no mocks.

## Evidence (verbatim)

- Suite: `1510 runs, 89162 assertions, 0 failures, 0 errors, 0 skips` (`bundle exec rake`; de14fac: `1508 runs, 89156 assertions, 0 failures`).
- Lane test: `9 runs, 25 assertions, 0 failures, 0 errors, 0 skips`.
- Canaries (`ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run`, after the change):
  ```
  | script | OFF md5 | = ACTIVE bank? | ON md5 | lines OFF -> ON | first divergent line |
  | world_loop | `e0b1f38f` | YES | `6850a028` | 42 -> 43 | 11 of 42 |
  | brasa2_run | `3fd04895` | YES | `7445f630` | 82 -> 255 | 18 of 82 |
  | floor3_run | `648810ff` | YES | `e14bafe4` | 155 -> 260 | 4 of 155 |
  ```
  OFF = ACTIVE bank x3 (DoD 4). ON md5s are ALSO unchanged vs the audit §3 table (`6850a028` /
  `7445f630` / `e14bafe4`): the rule never fires in the three canaries even with the brain ON.
- Fence (before each of the 3 commits): `lane_guard a3-stalemate: OK (3 path(s) inside the fence; brief @ junior/premium-build)` rc 0 · `OK (2 path(s) ...)` rc 0 · `OK (1 path(s) ...)` rc 0.

## FINDING (corrected mechanism) — audit §4 symptom is real, its reading is not

Headless trace, brasa2_run brain ON (`tmp/a3_probe.rb` / `tmp/a3_probe2.rb`, NOT committed — tmp/ is
outside owns; both are 20-line scripts over `test/support/headless_script` + `Harness.apply_start`):

```
f=690 zone=ember_2 lobfree@[8, 11] mv=false focus= poss=blocker@[8, 13] | ember_a9@[7, 2] hp=65 focus= prov=false leash=75 home=[13, 4] d=9 aggro=8 lc=false | ember_a13@[8, 4] hp=65 focus=lobber prov=false leash=0 home=[17, 8] d=7 aggro=8 lc=false
f=710 zone=ember_2 lobfree@[8, 11] mv=false focus= poss=blocker@[8, 13] | ember_a9@[7, 3] hp=65 focus=lobber prov=false leash=0 home=[13, 4] d=8 aggro=8 lc=false | ember_a13@[8, 4] hp=65 focus=lobber prov=false leash=0 home=[17, 8] d=7 aggro=8 lc=false
f=880 zone=ember_2 lobfree@[8, 11] mv=false focus= poss=blocker@[8, 13] | ember_a9@[7, 2] hp=65 focus=lobber prov=false leash=0 home=[13, 4] d=9 aggro=8 lc=false | ember_a13@[9, 5] hp=65 focus=lobber prov=false leash=0 home=[17, 8] d=6 aggro=8 lc=false
f=970 zone=ember_2 lobfree@[8, 11] mv=false focus= poss=blocker@[8, 13] | ember_a9@[7, 3] hp=65 focus= prov=false leash=90 home=[13, 4] d=8 aggro=8 lc=false | ember_a13@[8, 5] hp=65 focus=lobber prov=false leash=0 home=[17, 8] d=6 aggro=8 lc=false
f=980 zone=ember_2 lobfree@[8, 11] mv=false focus= poss=blocker@[8, 13] | ember_a9@[7, 3] hp=65 focus=lobber prov=false leash=0 home=[13, 4] d=8 aggro=8 lc=false | ember_a13@[8, 4] hp=65 focus=lobber prov=false leash=0 home=[17, 8] d=7 aggro=8 lc=false
```
(`lobfree` = not controlled; `d` = Chebyshev ember->lobber; `lc` = `line_clear?`; `prov` = `pack_provoked?`.)
Map rows 3..12 around x=7..9 (ember_2, `tmp/a3_map.rb`): row 6 `#..#..#######..#..#######..` — a wall
runs under [7..12,5]; the ember pocket [7..12,4..5] exits only west via [7,3]/[8,3] -> row 2.

1. **The lobber is NOT in ranged hold.** `lob@[8,11] focus=nil` from f≈400 to the end; `ember_a9/a13
   prov=false` throughout (no hit ever landed either way, `attack_hit` stream confirms). In
   `AiController#tick` (`controllers.rb:170`) `pick_provoked` -> `provoked_hostiles` (`:391`) is EMPTY,
   so `target` is nil and the lobber takes the free-ally `elsif free_ally -> follow(anchor)` branch
   (`:186-188`, `follow` `:548-555`): it trails the possessed blocker, idle at [8,13] since f≈180.
   `ally_engage` is never entered => DoD-1's rule cannot fire here (by design of C2's defensive default).
2. **The humans' ping-pong is `chase_step` greedy slot step vs flow field** (`controllers.rb:595-611`):
   from [8,5] the greedy step toward the surround slot (`:599-605`, clamp toward [8,11]) is [8,6] = WALL
   -> refused -> flow-field fallback (`:607-610`) steps UP toward the real path (row 2, west, down x=4..5,
   east along row 13 — ~15 tiles); next tick from [8,4] the greedy step [8,5] SUCCEEDS again. Result:
   `ember_a13@[8,4]<->[8,5]` for 700+ frames (probe lines f=690..1400, every sample).
3. **The leash cadence is a range-edge flicker, not a re-acquire of a shooter:** the flow fallback drifts
   ember_a9 to [7,2] = Chebyshev 9 > `ember_a.aggro_tiles` 8 (`select_target` `:118`) -> `focus=nil`
   (`aggro.rb:65`) -> `tick_leash` x90 (`threat.leash_linger_frames`) -> `leash_home` emits once at
   `leash_frames == 90` (`homecoming.rb:82`) -> walks home along row 2 -> re-enters range at [7,3]/[8,3]
   (d=8) -> `acquired` one frame later -> greedy/flow ping-pong -> drift -> repeat. That is the §4
   "every ~280 frames, hp frozen" line. Brain OFF differs only in where the pack ends up (blocker
   @[11,9]): the same embers get stuck at [8,3]/[8,4]/[9,4] against the same wall but stay inside range 8,
   so no leash — the OFF stream's 0 leashes hides the same pathing pocket.

### Named candidates for the owner (NOT applied — each is a sim change)

- **(c) hostile `chase_step` tie-break vs flow** (`controllers.rb:599-605`): refuse the greedy slot step
  when the flow field says the slot tile is farther (in field distance) than the current tile, or
  skip greedy when the last greedy step was undone by the flow step (needs 1 field of memory).
  Runs with the brain OFF -> canary law: owner's word + versioned rebank of the three canaries.
- **(d) free ally with no target, hostiles stuck within X tiles -> engage** (brain ON only): in `tick`
  (`:170`) when `pick_provoked` returns nil, let `ally_cfg` allow acquiring an UNPROVOKED hostile that
  has kept `focus == <a pack body>` for `ally.engage_stuck_frames` inside `ally.engage_stuck_tiles`
  (the ember stares at the lobber for 700 frames). Gated by `cfg[:enabled]` => OFF path byte-identical;
  would let DoD-1's rule then fire — but NOT produce a shot here: row 6 is wall for x=7..12 (map dump
  above), so no tile in the lobber's room has `line_clear?` to [8,4]/[8,5]; the lobber would advance to
  the floor and stall at the wall too. The real unblock in brasa2 is (c) (the embers can path around:
  row 2 -> x=4..5 -> row 13, ~15 tiles) or the player moving. (d) still matters where the geometry allows
  a shot (a stuck hostile in an open room).
- Not a candidate: (b) "ember leash-and-forget" from §4 — it would treat the symptom (leash count) and
  leave both embers stuck at the wall.

## PATCH REQUESTS (outside owns)

- none required for this lane. Optional, docs-only: `drafts/_a3-ally-brain-audit-20260905.md` §4
  paragraph "Mechanism: the lobber holds 3 tiles and lines up its shot" -> replace by FINDING 1-3 above
  (Junior's file; his call).
- Debt line for BOARD (integrator): `controllers.rb` 628 > ~620 — candidate extraction: the PREMIUM ally
  brain block (`ally_config`..`advance_step`, `:199-350`) into `src/game/ally_brain.rb` as a plain
  module mixed into `AiController` (byte-inert). Not done here (scope).

## Helpers

- `scout` (subagent, async, fresh context, model gpt-5.6-sol): mapped `ally_engage`/`align_step`/
  `chase_step`/`leash_home`/`ally_config`, `aggro.rb` focus assignment, the `human_leashed` chain
  (`leash_home` -> `World#human_leashed!` -> `Homecoming#leash_emission` emit-once at
  `leash_frames == linger`), Creature fields, audit §4 cadence verbatim. Matched my own reading.
- `reviewer` (subagent, async, fresh, fable-5.1-thinking) on de14fac: PASS WITH MINORS — see REVIEW below.

## REVIEW

Fresh-eyes review of de14fac (fable-5.1-thinking; its session had no shell, read the tree only):
VERDICT: PASS WITH MINORS. Findings and what I did (97ce289):
1. MAJOR `ally_engage`: at `dist == floor`, `stalled` stays true, `advance_step` finds nothing and
   `align_step` was never reached -> an OFF-AXIS ally at the floor froze. CONFIRMED by trace (lobber
   @[3,4], stall pre-set: `[[0,[3,4]]]` for 60 ticks). FIXED: advance || (align unless stalled-and-aligned)
   -> `[[0,[2,3]],[23,[3,3]]]`; the reviewer's literal suggestion (plain fallthrough to align_step) would
   have re-created the wiggle at the floor ([3,3]<->[2,3]), hence the `aligned?` guard. Test added.
2. MINOR stale `@stall` entry survives disengagement (re-acquire on the same tile could advance on tick 1).
   FIXED: `:187` delete in the free-ally follow branch (brain ON only). Test added.
3. MINOR count grows while the ally is mid-step / retreating; `in_attack_range?` evaluated twice per tick.
   ACCEPTED as-is (brief: "how many frames the TARGET stood still"; cost only). Documented here.
4. MINOR data footgun: hold >= 4 with `stalemate_advance_tiles >= hold - 1` -> floor 2 < retreat threshold
   -> advance/retreat ping-pong. Shipped 3/1 safe. NOT changed (owner's numbers; note for whoever retunes:
   keep `stalemate_advance_tiles <= 1` or `hold - advance >= hold - 1`). Could become a data lint later.
5. NIT ternary precedence in `advance_step` -> parenthesized.
6. NIT 625 (now 628) lines vs ~620 -> extraction candidate recorded above (not this lane's scope).
Verified OK by the reviewer: OFF-path unreachability (single `ally_engage` call site behind
`ally_cfg && free_ally`; `@stall` allocated only in `stalemate?`), determinism/netplay (name-keyed, no
Hash iteration, identity only as a reset trigger, both seats rebuild from zero), reset conditions and
no off-by-one, data-driven numbers, no lore names, test coverage of DoD 3 (i)-(iii), no mocks.
