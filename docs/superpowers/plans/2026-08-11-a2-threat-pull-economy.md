# A2 Threat/Pull Economy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Humans become threat that contests position, corpse recovery, and the
walk to the bank: priority targeting, an engaged-cap + pressuring ring, leash
with no heal, respawn discipline, a depth gradient, and tank-first possession.

**Architecture:** All new decision state lives on `Creature` (the `@taunted_by`
precedent); the target-selection chain lives in `AiController#select_target`;
the World runs two new zone-scoped passes in `tick_world` (focus assignment,
pressure partition) before the human AI loop; every tunable is a data key. Sim
changes invalidate all replay streams — re-pilot is the second-to-last task.

**Tech Stack:** Ruby 3.4.10 + Gosu 1.4.6, minitest, the harness gate wall.

**Spec:** `docs/superpowers/specs/2026-08-11-a2-threat-pull-economy-design.md`
(REVISED, adversarial-review-gated). Read it before starting.

## Global Constraints

- Every shell: `export PATH="/c/Ruby34-x64/bin:$PATH"` (Ruby not on Git Bash PATH).
- Zero balance constants in Ruby — every number lands in `data/balance/threat.json`,
  `data/balance/combat.json`, `data/zones/district.json`, or `data/display.json`.
- `src/app/window.rb` stays ≤ 300 lines (currently 71 — do not add logic there).
- New bus events are added to `World::EVENTS` when first used: exactly
  `:human_retargeted` and `:human_leashed` in this plan.
- Vision checks are ADD-ONLY (31 → 34). Existing checks never weaken.
- NO new input bindings, NO new enemy kits beyond the `rusher_hater` data
  variant, NO economy/spend code (D1b), NO corpse-system changes.
- Renderer methods are pure readers — never mutate sim state from draw.
- Replays are tick-deterministic: fixed iteration orders, roster-index
  tiebreaks, no wall-clock, no un-seeded randomness.
- Commits: small, prefixed (`feat(threat):`, `test:`, `data:`, `docs:`);
  NEVER push (no remote). Merge is `--no-ff` at the end, on branch `a2-threat`.
- Recorded plan-level deviations (consistent with spec intent, cite in commit
  messages): (1) cross-zone leash resolves as SNAP-HOME on zone entry (only
  the current zone's humans tick — the frozen-zone law; in-zone leash walks
  visibly); (2) the pressure partition's cap applies to taunt-bound humans
  too (taunt locks ATTENTION — targeting — not the right to swing).

---

### Task 0: Branch + threat data file + data-load assertions

**Files:**
- Create: `data/balance/threat.json`
- Modify: `data/balance/combat.json` (pack `initial_possessed` is Task 8 — NOT here)
- Test: `test/game/threat_data_test.rb`

**Interfaces:**
- Produces: `data["balance/threat"]` with keys `:proximity_switch_margin_tiles`,
  `:lowhp_switch_pct`, `:engaged_cap_per_target`, `:pressure_ring_tiles`,
  `:leash_linger_frames`, `:respawn_block_tiles`, `:beachhead_tiles` — every
  later task fetches from this hash via `World#threat_config`.

- [ ] **Step 1: Branch**

```bash
git checkout -b a2-threat
```

- [ ] **Step 2: Write the failing test**

```ruby
# test/game/threat_data_test.rb
require "test_helper"

class ThreatDataTest < Minitest::Test
  def setup
    @threat = load_data["balance/threat"] # same helper world_test uses to build World data
  end

  def test_threat_keys_exist_and_are_sane
    assert @threat[:proximity_switch_margin_tiles] >= 1
    assert @threat[:lowhp_switch_pct].between?(0.05, 0.9)
    assert @threat[:engaged_cap_per_target] >= 1
    assert @threat[:pressure_ring_tiles] >= 2, "ring must sit outside melee adjacency"
    assert @threat[:leash_linger_frames] >= 1
    assert @threat[:respawn_block_tiles] > 10, "suppression must exceed rusher aggro_tiles (10)"
    assert @threat[:beachhead_tiles] < 10, "beachhead must sit inside aggro_tiles or it never binds"
  end
end
```

(Adopt the exact data-loading helper `test/game/world_test.rb` uses — read its
setup first; if it builds a data hash by reading `data/**/*.json`, reuse that
method. Do not invent a new loader.)

- [ ] **Step 3: Run to verify it fails** — Run: `rake`. Expected: FAIL/ERROR
  (missing `balance/threat` key).

- [ ] **Step 4: Create the data file**

```json
{
  "proximity_switch_margin_tiles": 3,
  "lowhp_switch_pct": 0.35,
  "engaged_cap_per_target": 5,
  "pressure_ring_tiles": 2,
  "leash_linger_frames": 90,
  "respawn_block_tiles": 12,
  "beachhead_tiles": 4
}
```

- [ ] **Step 5: Run `rake`** — Expected: PASS (all existing tests still green).

- [ ] **Step 6: Commit**

```bash
git add data/balance/threat.json test/game/threat_data_test.rb
git commit -m "data(threat): A2 tunables + load assertions"
```

---

### Task 1: Creature threat state (home, focus, leash counter, beachhead waiver)

**Files:**
- Modify: `src/game/creature.rb` (initialize ~17-43, take_hit ~171, taunt! ~191)
- Test: `test/game/creature_test.rb` (append)

**Interfaces:**
- Produces: `Creature#home_tile` (frozen [x,y], stamped at construction),
  `Creature#focus` / `#focus=` (creature ref or nil), `Creature#leash_frames`,
  `#tick_leash` (+1), `#reset_leash!` (0), `Creature#beachhead_waived?`,
  `#waive_beachhead!`. Waiver auto-sets on any LANDED pack-faction hit and on
  `taunt!`. All later tasks consume these exact names.

- [ ] **Step 1: Write the failing tests** (append to creature_test.rb; mirror
  its existing construction helper for a bus/kit/map)

```ruby
def test_home_tile_is_stamped_at_construction
  c = build_creature(tile: [5, 5], faction: :human)
  c.step(1, 0, blocked: [])
  60.times { c.tick_body }
  assert_equal [5, 5], c.home_tile
end

def test_leash_counter_ticks_and_resets
  c = build_creature(faction: :human)
  3.times { c.tick_leash }
  assert_equal 3, c.leash_frames
  c.reset_leash!
  assert_equal 0, c.leash_frames
end

def test_landed_pack_hit_waives_beachhead
  h = build_creature(faction: :human)
  p = build_creature(faction: :pack)
  refute h.beachhead_waived?
  h.take_hit(damage: 1, attacker: p)
  assert h.beachhead_waived?
end

def test_taunt_waives_beachhead
  h = build_creature(faction: :human)
  p = build_creature(faction: :pack)
  h.taunt!(p, 300)
  assert h.beachhead_waived?
end
```

- [ ] **Step 2: Run `rake`** — Expected: FAIL (no method `home_tile`).

- [ ] **Step 3: Implement** — in `Creature#initialize` (after `@taunt_frames = 0`):

```ruby
@home_tile = tile.dup.freeze # threat home: where this body belongs (A2 leash)
@focus = nil
@leash_frames = 0
@beachhead_waived = false
```

Add to the `attr_reader` list: `:home_tile, :leash_frames`. Add
`attr_accessor :focus` on its own line (focus is World-assigned each tick).
Add the verbs near `taunt!`:

```ruby
def tick_leash = @leash_frames += 1
def reset_leash! = @leash_frames = 0
def beachhead_waived? = @beachhead_waived
def waive_beachhead! = @beachhead_waived = true
```

In `take_hit`, after the `return false if iframes? || dead?` guard:

```ruby
waive_beachhead! if @faction == :human && attacker.faction == :pack
```

In `taunt!`, add `waive_beachhead!` as the last line.

- [ ] **Step 4: Run `rake`** — Expected: PASS.

- [ ] **Step 5: Commit** — `git commit -m "feat(threat): creature threat state - home, focus, leash, beachhead waiver"`

---

### Task 2: Arrival tiles + gate-distance fields at zone load

**Files:**
- Modify: `src/game/world.rb` (`load_zones` ~566, new readers near `flow_to` ~162)
- Modify: `src/core/tile_map.rb` (expose `drop_gradient`)
- Modify: `data/zones/district.json` (add `drop_gradient` key ONLY — spawns move in Task 7)
- Test: `test/game/world_test.rb` (append)

**Interfaces:**
- Produces: `World#arrival_tiles_for(zone)` → array of [x,y] (transition spawns
  pointing INTO that zone, collected from every OTHER zone's transitions);
  `World#gate_distance(tile)` → Integer BFS distance from the current zone's
  first arrival tile (Float::INFINITY when the zone has none);
  `TileMap#drop_gradient` → array of `[min_distance, multiplier]` pairs or nil.

- [ ] **Step 1: Failing tests**

```ruby
def test_district_arrival_tile_comes_from_nest_transition
  assert_equal [[1, 13]], @world.arrival_tiles_for("district")
  assert_equal [[28, 8]], @world.arrival_tiles_for("nest")
end

def test_gate_distance_is_bfs_from_the_arrival_tile
  enter_district(@world) # existing helper pattern in this file for walking through the gate
  assert_equal 0, @world.gate_distance([1, 13])
  assert_operator @world.gate_distance([35, 5]), :>=, 30
end
```

- [ ] **Step 2: Run `rake`** — Expected: FAIL (no method).

- [ ] **Step 3: Implement** — in `TileMap`: add `:drop_gradient` to `attr_reader`
  and `@drop_gradient = cfg.fetch(:drop_gradient, nil)` in initialize. In
  `data/zones/district.json` add (top level):

```json
"drop_gradient": [[0, 1.0], [14, 1.5], [28, 2.0]]
```

In `World#load_zones`, after zones are built:

```ruby
@arrivals = Hash.new { |h, k| h[k] = [] }
@zones.each_value do |zmap|
  zmap.transitions.each { |t| @arrivals[t[:to]] << t[:spawn] }
end
@gate_fields = {}
@arrivals.each do |zone, tiles|
  next if tiles.empty?
  f = FlowField.new(@zones.fetch(zone))
  f.recompute!(tiles.first)
  @gate_fields[zone] = f
end
```

Public readers (near `flow_to`):

```ruby
def arrival_tiles_for(zone) = @arrivals.fetch(zone) { [] }

def gate_distance(tile)
  field = @gate_fields[@zone_name]
  field ? field.distance(*tile) : Float::INFINITY
end
```

- [ ] **Step 4: Run `rake`** — Expected: PASS.

- [ ] **Step 5: Commit** — `git commit -m "feat(threat): arrival tiles + gate-distance fields at zone load"`

---

### Task 3: Priority targeting chain + focus assignment + :human_retargeted

**Files:**
- Modify: `src/game/controllers.rb` (`AiController`), `src/game/world.rb`
  (`EVENTS`, `tick_world` ~229-259, new `assign_human_focus`, `threat_config`)
- Modify: `data/balance/combat.json` (add `rusher_hater` kit)
- Test: `test/game/threat_targeting_test.rb` (new), `test/game/world_test.rb:656` (rewrite)

**Interfaces:**
- Consumes: Task 1's `focus`, Task 0's `threat_config`.
- Produces: `AiController#select_target(creature, view)` → `[target_or_nil,
  cause_symbol]` with causes `:taunt, :anchor, :hate, :lowhp, :proximity,
  :sticky, :acquired`; `World#assign_human_focus` (pass 1);
  `World#threat_config` → the threat hash; event `:human_retargeted`
  (actor:, from:, to:, cause:) emitted only when the focus CHANGES to a
  non-nil target. Task 5's partition groups by `Creature#focus`.

- [ ] **Step 1: Add the `rusher_hater` kit to `data/balance/combat.json`** —
  copy the whole `rusher` block under a new key `rusher_hater` and add one
  field `"hate": "lobber"`. (A kit-parity test in Step 2 pins the copy against
  drift.)

- [ ] **Step 2: Failing tests** (`test/game/threat_targeting_test.rb` — build
  worlds via the world_test helper; place humans/pack bodies by rebinding
  tiles, the established pattern)

```ruby
def test_hater_kit_is_rusher_plus_hate_field_only
  kits = load_data["balance/combat"][:kits]
  assert_equal "lobber", kits[:rusher_hater][:hate]
  assert_equal kits[:rusher], kits[:rusher_hater].reject { |k, _| k == :hate }
end

def test_first_seen_focus_is_sticky_within_margin
  # striker at distance 4, lobber at distance 3 (closer by 1 < margin 3): focus holds
  ...place rusher, assign striker as focus, move lobber 1 tile nearer...
  target, cause = @ai.select_target(rusher, @world)
  assert_equal [striker, :sticky], [target, cause]
end

def test_proximity_steal_fires_at_the_margin
  # lobber closer by exactly proximity_switch_margin_tiles: steal
  target, cause = @ai.select_target(rusher, @world)
  assert_equal [lobber, :proximity], [target, cause]
end

def test_lowhp_override_targets_the_wounded_body
  striker_hp_below_35_percent
  target, cause = @ai.select_target(rusher, @world)
  assert_equal [striker, :lowhp], [target, cause]
end

def test_hater_beelines_the_lobber_inside_aggro
  target, cause = @ai.select_target(hater, @world)
  assert_equal [lobber, :hate], [target, cause]
end

def test_taunt_outranks_everything
  hater.taunt!(blocker, 300)
  target, cause = @ai.select_target(hater, @world)
  assert_equal [blocker, :taunt], [target, cause]
end

def test_retarget_event_fires_on_change_with_cause
  events = []
  @world.bus.subscribe(:human_retargeted) { |e| events << e }
  ...tick world so a lowhp switch occurs...
  assert_equal :lowhp, events.last[:cause]
end
```

- [ ] **Step 3: Run `rake`** — Expected: FAIL.

- [ ] **Step 4: Implement `select_target`** in `AiController` (public, above
  `private`; `nearest`/`chebyshev` already exist):

```ruby
# A2 human chain: taunt -> anchor -> kit-hate -> lowest-HP -> sticky focus
# (proximity-margin steal) -> nearest acquisition. Stateless rules, readable
# switches (learnability law): every cause is telemetry.
def select_target(creature, view)
  bound = creature.taunted_target
  return [bound, :taunt] if bound
  anchor = anchor_victim_for(creature, view)
  return [anchor, :anchor] if anchor
  threat = view.threat_config
  candidates = view.hostiles_for(creature)
                   .reject { |h| view.beachhead_shields?(creature, h) }
                   .select { |h| chebyshev(creature.tile, h.tile) <= creature.kit[:aggro_tiles] }
  return [nil, nil] if candidates.empty?
  if (hated = creature.kit[:hate])
    hit = candidates.find { |h| h.kit_name == hated.to_sym }
    return [hit, :hate] if hit
  end
  low = candidates.select { |h| h.hp < h.max_hp * threat[:lowhp_switch_pct] }
  unless low.empty?
    return [nearest(creature, low), :lowhp]
  end
  focus = creature.focus
  if focus && !focus.dead? && candidates.include?(focus)
    steal = nearest(creature, candidates)
    if !steal.equal?(focus) &&
       chebyshev(creature.tile, focus.tile) - chebyshev(creature.tile, steal.tile) >=
       threat[:proximity_switch_margin_tiles]
      return [steal, :proximity]
    end
    return [focus, :sticky]
  end
  [nearest(creature, candidates), :acquired]
end
```

(`beachhead_shields?` arrives in Task 4 — until then add the World stub
`def beachhead_shields?(_h, _t) = false` in this task so tests run.)

- [ ] **Step 5: Wire World pass 1** — add `:human_retargeted` and
  `:human_leashed` to `EVENTS` (both now — one EVENTS edit). Add
  `@threat = data["balance/threat"]` in initialize (near `@death`) and
  `def threat_config = @threat` near the view API. In `tick_world`, replace
  the human loop:

```ruby
assign_human_focus
humans.each { |h| emit_telegraph_edge(h); @ai.tick(h, self) }
```

with pass 1 above it:

```ruby
def assign_human_focus
  humans.each do |h|
    next if h.dead?
    target, cause = @ai.select_target(h, self)
    if target && !target.equal?(h.focus)
      @bus.emit(:human_retargeted, actor: h, from: h.focus, to: target, cause:)
    end
    h.focus = target
  end
end
```

- [ ] **Step 6: Make `AiController#tick` consume focus for humans** — replace
  the body's selection for the human path only:

```ruby
def tick(creature, view)
  return if creature.dead?
  return tick_human(creature, view) if creature.faction == :human
  bound = creature.taunted_target || anchor_victim_for(creature, view)
  marked = marked_target_for(creature, view)
  target = bound || marked || nearest(creature, view.hostiles_for(creature))
  if target && (bound || marked || chebyshev(creature.tile, target.tile) <= creature.kit[:aggro_tiles])
    engage(creature, target, view)
  elsif creature.faction == :pack && !view.possessed.equal?(creature)
    follow(creature, view.possessed, view)
  end
end

def tick_human(creature, view)
  target = creature.focus
  if target && !target.dead?
    creature.reset_leash!
    engage(creature, target, view) # pressure roles split this in Task 5
  else
    creature.tick_leash # leash behavior lands in Task 6
  end
end
```

- [ ] **Step 7: Rewrite `world_test.rb:656`**
  (`test_rushers_hunt_the_nearest_pack_member_not_the_possessed`) — it pins
  the OLD per-tick-nearest law. New pin: first-seen stickiness —

```ruby
def test_rushers_keep_their_first_seen_target_inside_the_margin
  # rusher acquires the striker (nearest at acquisition); the blocker then
  # closes to 1 tile nearer (inside proximity_switch_margin_tiles): the
  # rusher stays on the striker — targets no longer flap by distance.
  ...
end
```

- [ ] **Step 8: Run `rake`** — Expected: PASS, including all taunt_test.rb
  (the taunt/anchor regression oracle — if any taunt test fails, the chain
  order is wrong; taunt is rule 1).

- [ ] **Step 9: Commit** — `git commit -m "feat(threat): priority targeting chain + focus pass + human_retargeted"`

---

### Task 4: Gate beachhead (acquisition shield + waiver)

**Files:**
- Modify: `src/game/world.rb` (replace the Task 3 stub)
- Test: `test/game/threat_targeting_test.rb` (append)

**Interfaces:**
- Consumes: Task 2's `arrival_tiles_for`, Task 1's `beachhead_waived?`,
  Task 0's `threat_config`.
- Produces: `World#beachhead_shields?(human, target)` → true when the target
  stands within `beachhead_tiles` of any arrival tile of the current zone AND
  the human is not waived.

- [ ] **Step 1: Failing tests**

```ruby
def test_unwaived_humans_cannot_acquire_a_target_on_the_doormat
  # pack at [2,13] (within beachhead_tiles 4 of arrival [1,13]); rusher within aggro
  target, = @ai.select_target(rusher, @world)
  assert_nil target
end

def test_attacking_from_the_doormat_waives_that_human_only
  rusher.take_hit(damage: 1, attacker: striker)
  target, = @ai.select_target(rusher, @world)
  assert_equal striker, target
  other_target, = @ai.select_target(other_rusher, @world)
  assert_nil other_target
end

def test_taunt_binds_through_the_beachhead
  rusher.taunt!(blocker, 300)
  target, cause = @ai.select_target(rusher, @world)
  assert_equal [blocker, :taunt], [target, cause]
end
```

- [ ] **Step 2: Run `rake`** — FAIL (stub returns false everywhere; first test fails).

- [ ] **Step 3: Implement** (replaces the stub):

```ruby
# Beachhead (A2): arrival is not an ambush. Blocks ACQUISITION only —
# taunt/anchor bind first in the chain, and a human the pack has attacked
# is waived for life (you don't get the doormat's protection while
# swinging from it).
def beachhead_shields?(human, target)
  return false if human.beachhead_waived?
  radius = @threat[:beachhead_tiles]
  arrival_tiles_for(@zone_name).any? { |a| tile_distance(target.tile, a) <= radius }
end
```

- [ ] **Step 4: Run `rake`** — PASS.
- [ ] **Step 5: Commit** — `git commit -m "feat(threat): gate beachhead - acquisition shield with per-human waiver"`

---

### Task 5: Engaged cap + pressuring ring

**Files:**
- Modify: `src/game/world.rb` (`tick_world`, new `partition_pressure`,
  `pressure_role`, `pressure_slot`), `src/game/controllers.rb` (`tick_human`,
  new `pressure_step`)
- Test: `test/game/threat_pressure_test.rb` (new)

**Interfaces:**
- Consumes: Task 3's focus pass.
- Produces: `World#pressure_role(creature)` → `:engaged` | `:pressuring`
  (fetch-default `:engaged` — the renderer reads this in Task 9);
  `World#pressure_slot(attacker, target)` → ring tile or nil.

- [ ] **Step 1: Failing tests**

```ruby
def test_partition_caps_engaged_at_the_data_value_and_is_deterministic
  # 7 rushers all focused on the blocker; cap 5: nearest 5 engaged,
  # 2 pressuring, ties broken by roster order — assert exact membership twice
  # (two fresh worlds, same seed) for determinism.
end

def test_pressuring_humans_never_start_attacks
  # force a pressuring human adjacent to its target for 120 ticks:
  # attack_started never fires from it.
end

def test_pressuring_humans_hold_ring_distance
  # after 300 ticks, every pressuring human sits at pressure_ring_tiles
  # (Chebyshev) from the target, or is still moving toward a free ring tile.
end

def test_engaged_slot_refills_when_an_engaged_human_dies
  # kill one engaged human; next tick a pressuring one is promoted.
end
```

- [ ] **Step 2: Run `rake`** — FAIL.

- [ ] **Step 3: Implement World partition** — call `partition_pressure` in
  `tick_world` immediately after `assign_human_focus`; reset
  `@pressure_claims = {}` next to `@slot_claims = {}`:

```ruby
# A2 position pressure: per focus-target, the nearest engaged_cap_per_target
# humans fight; the rest PRESSURE (follow, block, never swing). Sorting is
# (distance, roster index) — deterministic. Taunt-bound humans partition
# like everyone else: taunt locks attention, not the right to swing.
def partition_pressure
  cap = @threat[:engaged_cap_per_target]
  @pressure_roles = {}
  humans.reject(&:dead?).group_by(&:focus).each do |target, group|
    next unless target
    group.each_with_index
         .sort_by { |h, i| [tile_distance(h.tile, target.tile), i] }
         .each_with_index { |(h, _), rank| @pressure_roles[h] = rank < cap ? :engaged : :pressuring }
  end
end

def pressure_role(creature) = (@pressure_roles || {}).fetch(creature, :engaged)

# Ring slots mirror surround_slot one ring further out: the Chebyshev ring at
# pressure_ring_tiles, claimed per target per tick, fixed perimeter order.
def pressure_slot(attacker, target)
  claims = (@pressure_claims[target] ||= {})
  already = claims.find { |_, who| who.equal?(attacker) }
  return already[0] if already
  r = @threat[:pressure_ring_tiles]
  tx, ty = target.tile
  ring = (-r..r).flat_map { |d| [[tx + d, ty - r], [tx + d, ty + r], [tx - r, ty + d], [tx + r, ty + d]] }
                .uniq
  slot = ring.find { |t| map.passable?(*t) && !claims.key?(t) }
  claims[slot] = attacker if slot
  slot
end
```

- [ ] **Step 4: Implement the controller side** — in `tick_human`, replace the
  `engage(...)` line:

```ruby
case view.pressure_role(creature)
when :pressuring then pressure_step(creature, target, view)
else engage(creature, target, view)
end
```

and add (near `chase_step`):

```ruby
# Pressuring: close space, claim a ring tile, body-block — never swing.
# The ring is porous by design (dodge and specials cross it): escapable
# is what makes wipes fair (spec cadence law).
def pressure_step(creature, target, view)
  return if creature.moving?
  slot = view.pressure_slot(creature, target)
  return unless slot && slot != creature.tile
  blocked = view.blocked_for(creature)
  dx = (slot[0] - creature.tile[0]).clamp(-1, 1)
  dy = (slot[1] - creature.tile[1]).clamp(-1, 1)
  if creature.step(dx, dy, blocked:)
    creature.face([dx, dy])
  else
    dir = view.flow_to(target).downhill_from(*creature.tile, blocked:)
    if dir
      creature.face(dir)
      creature.step(dir[0], dir[1], blocked:)
    end
  end
end
```

- [ ] **Step 5: Run `rake`** — PASS.
- [ ] **Step 6: Commit** — `git commit -m "feat(threat): engaged cap + pressuring ring - bounded lethality, visible box"`

---

### Task 6: Leash with no heal (+ :human_leashed, cross-zone snap)

**Files:**
- Modify: `src/game/controllers.rb` (`tick_human` leash branch),
  `src/game/world.rb` (`flow_home`, `human_leashed!`, `enter_zone` snap +
  `@home_fields` clear)
- Test: `test/game/threat_leash_test.rb` (new)

**Interfaces:**
- Consumes: Task 1's `home_tile`/`leash_frames`, Task 0's `leash_linger_frames`.
- Produces: `World#flow_home(creature)` (home-tile-anchored field, cached per
  home tile, cleared on zone change); `World#human_leashed!(creature)` (emits
  `:human_leashed` once per leash episode); the enter-zone snap.

- [ ] **Step 1: Failing tests**

```ruby
def test_idle_humans_walk_home_after_the_linger_and_keep_their_hp
  # damage a rusher to 20 hp, move the pack out of aggro, tick past
  # leash_linger_frames + walk time: rusher back at home_tile, hp still 20.
end

def test_human_leashed_emits_once_per_episode
end

def test_returning_humans_reengage_when_the_pack_comes_back_in_range
end

def test_zone_reentry_snaps_absent_zone_humans_home_with_kept_hp
  # damage a gate rusher, walk the pack to the nest, walk back:
  # the rusher sits at home_tile with the damaged hp.
end
```

- [ ] **Step 2: Run `rake`** — FAIL.

- [ ] **Step 3: Implement** — controller `tick_human` else-branch becomes:

```ruby
else
  creature.tick_leash
  leash_home(creature, view)
end
```

with:

```ruby
# Leash-with-no-heal (A2): nothing in aggro for the linger -> walk home,
# KEEPING hp. A returning human re-engages the moment focus reappears
# (dispersed, not invulnerable).
def leash_home(creature, view)
  return if creature.leash_frames < view.threat_config[:leash_linger_frames]
  return if creature.tile == creature.home_tile
  view.human_leashed!(creature) if view.respond_to?(:human_leashed!)
  return if creature.moving?
  blocked = view.blocked_for(creature)
  dir = view.flow_home(creature).downhill_from(*creature.tile, blocked:)
  return unless dir
  creature.face(dir)
  creature.step(dir[0], dir[1], blocked:)
end
```

World side (near `flow_to`):

```ruby
# Home fields are keyed by TILE and never invalidated inside a zone —
# homes don't move. Cleared with the flow cache on zone change.
def flow_home(creature)
  @home_fields ||= {}
  @home_fields[creature.home_tile] ||= FlowField.new(map).tap { |f| f.recompute!(creature.home_tile) }
end

# One :human_leashed per episode: the flag arms on emit, disarms when the
# human regains a focus (reset_leash! call sites) — track via leash_frames
# equality: emit exactly when the counter crosses the linger threshold.
def human_leashed!(creature)
  return unless creature.leash_frames == @threat[:leash_linger_frames]
  @bus.emit(:human_leashed, actor: creature, tile: creature.tile, hp: creature.hp)
end
```

(NB the equality check makes the emit fire on exactly one tick per episode —
no extra state. `tick_leash` runs before `leash_home` each tick, so the
counter passes through the threshold exactly once per episode.)

In `enter_zone`, after `@flow_cache = {}`: add `@home_fields = {}` and the
snap (before members rebind):

```ruby
# Cross-zone leash resolves as snap-home: only the current zone ticks, so
# "they walked home while you were away" lands as relocation with KEPT hp
# (frozen-zone law; recorded plan deviation 1).
@humans[name].each do |h|
  next if h.dead? || h.focus
  if h.tile != h.home_tile
    h.rebind(map: @zones.fetch(name), tile: h.home_tile)
    @bus.emit(:human_leashed, actor: h, tile: h.home_tile, hp: h.hp)
  end
  h.reset_leash!
end
```

(Also clear each entered-zone human's `focus` to nil first — the pack just
left/arrived; stale cross-zone refs must not survive: `h.focus = nil` before
the branch.)

- [ ] **Step 4: Run `rake`** — PASS (existing enter-zone tests must stay green;
  if a test pinned humans keeping mid-zone positions across transitions, read
  it and update ONLY if it pinned the old undesigned behavior).

- [ ] **Step 5: Commit** — `git commit -m "feat(threat): leash with no heal - walk home in zone, snap on reentry"`

---

### Task 7: Respawn suppression + depth gradient (spawns, richness)

**Files:**
- Modify: `src/game/world.rb` (`respawn_due_humans` ~620, `spawn_drop` ~476)
- Modify: `data/zones/district.json` (`enemy_spawns` re-banded)
- Test: `test/game/threat_respawn_test.rb` (new), `test/game/world_test.rb`
  respawn tests (extend, keep green)

**Interfaces:**
- Consumes: Task 2's `gate_distance` + `drop_gradient`, Task 0's
  `respawn_block_tiles`.
- Produces: suppressed respawns; gradient-multiplied drops. No new methods
  consumed later.

- [ ] **Step 1: Failing tests**

```ruby
def test_respawn_defers_while_a_pack_body_is_within_the_block_radius
  # kill the [14,12] rusher, park the pack 8 tiles from the spawn point,
  # tick past respawn_frames: roster count unchanged; walk away 13 tiles,
  # tick once: rusher back.
end

def test_drop_amounts_scale_with_gate_distance_bands
  # kill a rusher at gate_distance < 14 -> base amount; force a kill at
  # distance >= 28 -> amount == (base * 2.0).round. Use seed control the
  # way world_test's drop tests already do.
end
```

- [ ] **Step 2: Run `rake`** — FAIL.

- [ ] **Step 3: Implement suppression** — in `respawn_due_humans`, extend the
  defer condition:

```ruby
block = @threat[:respawn_block_tiles]
pack_tiles = @pack.living.map(&:tile)
ready.each do |r|
  if occupied.include?(r[:tile]) ||
     pack_tiles.any? { |t| tile_distance(t, r[:tile]) <= block }
    deferred << r
  else
    ...
```

- [ ] **Step 4: Implement gradient richness** — in `spawn_drop`, replace the
  amount line:

```ruby
amount = (table[@rng.rand(table.length)] * gradient_multiplier(victim.tile)).round
```

with the helper (near `tile_distance`):

```ruby
# Deeper = richer (A2 gradient): multiplier bands over gate distance,
# from zone data. Zones without a gradient (nest) multiply by 1.
def gradient_multiplier(tile)
  bands = map.drop_gradient
  return 1.0 unless bands
  d = gate_distance(tile)
  bands.reverse.find { |(min, _)| d >= min }&.last || 1.0
end
```

- [ ] **Step 5: Re-band the district spawns** — replace `enemy_spawns` in
  `data/zones/district.json` with (all tiles verified passable on open rows;
  near band sparse + outside arrival aggro, deep band dense; 3 haters mid/deep):

```json
"enemy_spawns": {
  "rusher": [[14, 12], [12, 19], [20, 6], [24, 12], [18, 24], [28, 5],
             [30, 18], [26, 23], [35, 5], [38, 12], [33, 13], [40, 19]],
  "rusher_hater": [[22, 18], [36, 23], [41, 6]]
}
```

(The old `[10, 12]` point — 9 tiles from arrival, inside aggro 10, the
measured grinder root — is deliberately gone; the nearest spawn is now
`[14, 12]` at distance 13.)

- [ ] **Step 6: Run `rake`** — PASS. Also run `rake perf` — Expected: p95 well
  under 16.6 ms with 15 humans (baseline was 0.100 ms with 7).

- [ ] **Step 7: Commit** — `git commit -m "feat(threat): respawn suppression + depth gradient - banded spawns, richer deeper"`

---

### Task 8: Tank-first initial possession (bundled owner feedback)

**Files:**
- Modify: `src/game/pack.rb`, `src/game/world.rb` (`spawn_pack` ~593),
  `data/balance/combat.json` (pack block)
- Test: `test/game/pack_test.rb` (append)

**Interfaces:**
- Produces: `Pack.new(members:, stagger_frames:, initial_kit: nil)` — finds the
  member whose `kit_name` matches, falls back to `members.first`. Tab cycle
  order unchanged (the members array is NOT reordered).

- [ ] **Step 1: Failing test**

```ruby
def test_initial_possession_honors_initial_kit_without_reordering_the_cycle
  pack = Game::Pack.new(members: [striker, blocker, lobber],
                        stagger_frames: 20, initial_kit: "blocker")
  assert_equal blocker, pack.possessed
  pack.swap_next!
  assert_equal lobber, pack.possessed, "cycle order still follows the members array"
end
```

- [ ] **Step 2: Run `rake`** — FAIL (unknown keyword).

- [ ] **Step 3: Implement** — Pack:

```ruby
def initialize(members:, stagger_frames:, initial_kit: nil)
  @members = members
  @possessed = members.find { |m| m.kit_name.to_s == initial_kit.to_s } || members.first
  ...
```

World `spawn_pack`: `Pack.new(members:, stagger_frames: cfg[:swap_stagger_frames], initial_kit: cfg[:initial_possessed])`.
Data: add `"initial_possessed": "blocker"` to the pack block in combat.json.

- [ ] **Step 4: Run `rake`** — expect SOME world/harness-adjacent tests to
  fail IF they assumed striker-first possession. Read each failure: update
  only assertions that pinned "possessed == striker at spawn" as incidental
  setup (change to `world.possessed` accessors); any test that pinned it as a
  LAW is a spec conflict — stop and flag.

- [ ] **Step 5: Run `rake`** — PASS after updates.
- [ ] **Step 6: Commit** — `git commit -m "feat(threat): tank-first initial possession via initial_possessed data key"`

---

### Task 9: Pressuring stance render cue (Rule 2 surface)

**Files:**
- Modify: `src/app/renderer.rb` (`draw_creature` ~251, constants block),
  `data/display.json`
- Test: `test/game/threat_pressure_test.rb` (append a display-key assertion)

**Interfaces:**
- Consumes: Task 5's `World#pressure_role` (pure read; fetch-default
  `:engaged` guarantees draw-safety before the first tick).
- Produces: the on-camera tell the new vision checks aim at.

- [ ] **Step 1: Failing test** (data assertion — visual verification is the
  gate wall's job, Task 11):

```ruby
def test_pressure_display_keys_exist
  display = load_data["display"]
  assert display[:pressure_outline_alpha].between?(60, 220)
end
```

- [ ] **Step 2: Add data** — `data/display.json`: `"pressure_outline_alpha": 140`.

- [ ] **Step 3: Implement the cue** — in `draw_creature`, after the taunt
  underline line:

```ruby
draw_pressure_outline(c, x, y, world) if c.faction == :human &&
                                          world.pressure_role(c) == :pressuring
```

New method (follow the hollow-outline grammar — outline = state, filled =
pickup; 4 thin rects like draw_hollow_pip):

```ruby
# Pressuring stance (A2): a thin hollow outline — present, encircling,
# not swinging. Distinct from the telegraph's FILLED swell and the taunt
# underline. Outline = state (the glean-pip grammar).
def draw_pressure_outline(c, x, y, world)
  # @pressure_alpha = @display.fetch(:pressure_outline_alpha, 140) in initialize
  col = Gosu::Color.new(@pressure_alpha, HUMAN_BODY.red, HUMAN_BODY.green, HUMAN_BODY.blue)
  t = 2
  Gosu.draw_rect(x - 4, y - 4, SIZE + 8, t, col)
  Gosu.draw_rect(x - 4, y + SIZE + 2, SIZE + 8, t, col)
  Gosu.draw_rect(x - 4, y - 4, t, SIZE + 8, col)
  Gosu.draw_rect(x + SIZE + 2, y - 4, t, SIZE + 8, col)
end
```

Also add `KIT_BODY[:rusher_hater] = KIT_BODY[:rusher]` alongside the KIT_BODY
constant definitions (the hater's tell is its beeline, not its color — a
missing key would KeyError the first hater draw).

- [ ] **Step 4: Run `rake`, then `bin/play` briefly** — sanity-only (the real
  verification is Task 11's wall; do NOT eyeball-iterate — Rule 2).

- [ ] **Step 5: Commit** — `git commit -m "feat(threat): pressuring stance outline cue + display keys"`

---

### Task 10: Telemetry summary line (harness-computed)

**Files:**
- Modify: `harness/` telemetry reporter (find the existing D1 telemetry code —
  grep `d1_fired` under `harness/`; extend the same event-log summarizer)
- Test: run a headless script and inspect the printed line

**Interfaces:**
- Consumes: events `:human_retargeted`, `:human_leashed`, plus existing
  `:pack_wiped`, `:actor_died`, `:banked`, `:corpse_looted`.
- Produces: an `a2_fired:` summary line — wipes, body deaths, retarget counts
  by cause, leash count, deepest gate_distance reached, contacts_en_route per
  recovery (reuse the D1 computation), banked events.

- [ ] **Step 1: Read the existing telemetry summarizer** (the D1 `d1_fired`
  line) and extend it with the A2 line in the same pattern — counts come from
  the event log only, zero sim additions:

```
a2_fired: wipes=<n> body_deaths=<n> retargets{hate=<n> lowhp=<n> proximity=<n> acquired=<n>} leashes=<n> deepest_band=<n> banked=<n>
```

- [ ] **Step 2: Verify** — `rake capture SCRIPT=harness/scripts/world_loop.json`
  prints the line with plausible zeros/counts.

- [ ] **Step 3: Commit** — `git commit -m "feat(threat): a2_fired telemetry line from the event log"`

---

### Task 11: Re-pilot all scripts + threat_pull.json + vision checks + the wall

**Files:**
- Modify: every `harness/scripts/*.json` gate script (re-piloted recordings)
- Create: `harness/scripts/threat_pull.json`
- Modify: `harness/gate_checks.json` (31 → 34, ADD ONLY)

**Interfaces:** none — this is the Rule 2 ship-gate.

- [ ] **Step 1: Add the three vision checks** to `harness/gate_checks.json`
  (follow the existing check-object shape exactly — read two neighbors first):
  `pressure_ring_reads` (pressuring humans visibly distinct from engaged;
  the group reads as encirclement, not lag), `leash_walkback_reads`
  (returning humans read as disengaging — walking away, not broken),
  `gradient_depth_reads` (deep-district frames read denser than gate frames).

- [ ] **Step 2: Re-pilot the seven wall scripts** via `rake pilot NAME=<n>
  SEED=<s>` (protocol: harness/pilot.rb header; append commands with
  `printf 'cmd\n' >>`, NEVER Write). Tank-first + new AI invalidate every
  stream. Preserve each script's DRAMATIC INTENT (world_loop = everyday loop,
  district_hunt = hunt, specials_chain = both specials, loot_loop = D0 loop,
  taunt_anchor = taunt beats, corpse_run = D1 acts 1-4, ledger_loop = ledger
  beats incl. a loss line and a wipe recap) — re-stage each beat under the
  new threat; re-aim capture frames from the pilot log, never by arithmetic
  from the old scripts (the ledger-presentation lesson).

- [ ] **Step 3: Author `threat_pull.json`** via pilot: (act 1) beachhead
  arrival + a walked pull of 2-3; (act 2) deep-band overpull — cap + ring on
  camera, escape through the ring; (act 3) leash breather — disengage, walk-
  home on camera, re-entry meets dispersed damaged humans; (act 4) a carrying
  death deep + contested run-back.

- [ ] **Step 4: The wall** — for each of the EIGHT scripts:
  `rake gate SCRIPT=harness/scripts/<name>.json` (double replay + md5 +
  critic; SKIP_CRITIC=1 first while iterating staging, then the FULL gate —
  a SKIP_CRITIC pass is not shippable). Plus `rake perf` and full `rake`.
  Expected: 8/8 determinism, 8/8 critic, perf green. A corpse_run-style
  INFRA flake (empty critic output) retries plainly once before counting as
  a failure.

- [ ] **Step 5: Commit** — `git commit -m "harness: re-pilot 7 walls + threat_pull script + 3 vision checks (31->34)"`

---

### Task 12: Adversarial impl review + merge + checkpoint

- [ ] **Step 1:** Run the house adversarial implementation review on the
  branch diff (same 3-lens pattern as the spec review; findings folded or
  refuted on record in `drafts/_a2-impl-review.md`).
- [ ] **Step 2:** `git checkout main && git merge --no-ff a2-threat` — NO push.
- [ ] **Step 3:** Checkpoint delta in `docs/CHECKPOINT.md` (measured numbers:
  test count, checks count, gate results, perf p95) + hand the owner the
  SIXTH fun-verify per the spec §Fun-verify (8 questions VERBATIM, two
  AskUserQuestion batches, telemetry line captured first, routing
  pre-registered — including D1b auto-promotion on "chore unmoved + threat
  felt", shaped as the inscription economy).

---

## Self-review (run before handoff)

1. **Spec coverage:** §1 targeting → Task 3; §2 pressure → Task 5 (+9 cue);
   §3 leash → Task 6; §4 respawn discipline → Tasks 4+7; §5 gradient → Tasks
   2+7; §6 tank-first → Task 8; events/telemetry → Tasks 3+6+10; presentation
   → Task 9; harness/gates → Task 11; fun-verify → Task 12. Live corridor =
   no task by design (emergent; spec §6 IN-list item 6).
2. **Type consistency:** `select_target` returns `[target, cause]` everywhere;
   `pressure_role` defaults `:engaged`; `threat_config` is the only threat-data
   accessor; `initial_kit:` keyword matches Pack/World/data.
3. **No placeholders:** every code step is concrete; the three tests written
   as intent-comments (partition determinism, ring hold, snap-home) name exact
   setups and assertions to write against helpers that exist in the named test
   files — the implementer reads those helpers first (read-before-edit).
