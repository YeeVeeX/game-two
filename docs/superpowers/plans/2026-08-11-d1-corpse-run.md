# D1 Corpse Run Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A pack body that dies carrying leaves its load in a recoverable corpse
container (term-limited, settle-gated, wipe-graced) instead of vanishing it —
the D1 tension slice from `docs/superpowers/specs/2026-08-10-d1-corpse-run-design.md`
(REVISED — the spec is the authority; this plan is its execution order).

**Architecture:** All sim state lives in `Game::World` as per-zone record lists
(`@corpse_loads`, `@expiry_flashes` — the existing `@drops`/`@corpses` pattern),
ticked inside `tick_world` (so hitstop + wipe veil pause them), linked to the
existing cosmetic corpse records by a monotonic serial. Renderer stays a pure
reader. All numbers in new `data/balance/death.json`.

**Tech Stack:** Ruby 3.4.10 + Gosu 1.4.6, minitest, the existing Rule-2 gate
harness (replay + MD5 + vision critic) and pilot mode.

## Global Constraints

- Branch: `d1-corpse-run` off main. Merge `--no-ff` at the end. **NO push.**
- Every shell needs `export PATH="/c/Ruby34-x64/bin:$PATH"` first.
- `src/app/window.rb` stays ≤ ~300 lines (task 8 adds ~8; it is at 63).
- Zero balance constants in Ruby — every tunable in `data/balance/death.json`.
- New events registered in `World::EVENTS` or emit raises.
- No mocks: tests use the REAL `Game::World` + REAL `data/` (world_test.rb idiom).
- Existing vision checks are append-only — 23 → 26, never edit the 23.
- Event payloads are PINNED by the spec (review CF-5): `:corpse_loaded`
  (actor, tile, amount) · `:corpse_looted` (actor, tile, amount, carried) ·
  `carried_lost` (amount, tile, zone).
- Data values are hypotheses bound to the margin oracle (term 5400, settle 300,
  grace 2700, flash 45, settle_pip_alpha 0.4) — do not "correct" them back to
  the death-economy doc's 10-min floor; the spec records why (anchor conflict).

---

### Task 1: data/balance/death.json + invariant test

**Files:**
- Create: `data/balance/death.json`
- Test: `test/game/corpse_run_test.rb` (new file, grows through tasks 1-6)

**Interfaces:**
- Produces: `DATA["balance/death"]` with symbol keys `:corpse_term_frames`,
  `:loot_settle_frames`, `:wipe_grace_frames`, `:expiry_flash_frames`,
  `:settle_pip_alpha` (DataStore symbolizes keys — same as `balance/combat`).

- [ ] **Step 1: Write the failing test** — new file `test/game/corpse_run_test.rb`:

```ruby
require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# D1 corpse-run integration tests — REAL data, REAL sim, no mocks.
# Helpers mirror world_test.rb (same staging idiom).
class CorpseRunTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  DEATH = DATA["balance/death"]
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    assert_equal "district", world.zone_name
  end

  def nearest_human(world)
    px, py = world.possessed.tile
    world.humans.reject(&:dead?).min_by { |h| [(h.tile[0] - px).abs, (h.tile[1] - py).abs].max }
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  def press_interact(world)
    drive(world, scripted({}), 1) while world.feel.hitstop?
    drive(world, scripted({ world.frame.to_s => ["interact"] }), 1)
    drive(world, scripted({}), 1)
  end

  def stage_drop_under_possessed(world)
    enter_district(world)
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 1)
    tile = world.drops.first[:tile]
    world.possessed.walker.teleport(*tile)
    drive(world, scripted({}), 1)
  end

  # Pick up a drop, swap OFF the carrier (so its death is an ally death,
  # not a possessed death), kill it by a human (no hitstop). Returns the
  # dead carrier and what it carried.
  def stage_loaded_death(world)
    stage_drop_under_possessed(world)
    press_interact(world)
    carrier = world.possessed
    amount = carrier.carried
    assert_operator amount, :>, 0
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    refute_equal carrier, world.possessed
    kill(carrier, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    [carrier, amount]
  end

  def load_at(world, tile, zone: nil)
    list = zone ? world.corpse_loads(zone) : world.corpse_loads
    list.find { |c| c[:tile] == tile }
  end

  # --- data invariants (review FN-3: grace <= term or the top-up truncates) --

  def test_death_balance_invariants
    assert_operator DEATH[:wipe_grace_frames], :<=, DEATH[:corpse_term_frames]
    %i[corpse_term_frames loot_settle_frames wipe_grace_frames
       expiry_flash_frames].each do |k|
      assert_operator DEATH[k], :>, 0, "#{k} must be a positive frame count"
    end
    assert_operator DEATH[:settle_pip_alpha], :>, 0
    assert_operator DEATH[:settle_pip_alpha], :<=, 1
  end
end
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `ruby -Isrc -Itest test/game/corpse_run_test.rb`
Expected: FAIL/ERROR — `data/balance/death.json` does not exist.

- [ ] **Step 3: Create the data file**

```json
{
  "corpse_term_frames": 5400,
  "loot_settle_frames": 300,
  "wipe_grace_frames": 2700,
  "expiry_flash_frames": 45,
  "settle_pip_alpha": 0.4
}
```

- [ ] **Step 4: Run the test — invariant test passes** (the helpers referencing
  `world.corpse_loads` are not exercised yet; only `test_death_balance_invariants`
  runs green).

- [ ] **Step 5: Commit** — `git add data/balance/death.json test/game/corpse_run_test.rb && git commit -m "feat(d1): death.json balance file + invariant test"`

---

### Task 2: container creation on death (replaces the D0 vanish)

**Files:**
- Modify: `src/game/world.rb` — EVENTS (line ~19-23), `initialize` (~31-59),
  the `actor_died` handler (~609-625), new `spawn_corpse_load` private method,
  new public accessor `corpse_loads`.
- Modify: `test/game/world_test.rb:1049-1079` (flip the two D0 vanish tests).
- Test: `test/game/corpse_run_test.rb`

**Interfaces:**
- Produces: `World#corpse_loads(zone = @zone_name)` → array of
  `{id:, tile:, amount:, term_left:, term:, settle_left:, settle_alpha:}`;
  cosmetic corpse records gain `container_id:` when created loaded; event
  `:corpse_loaded` (actor, tile, amount). Serial counter `@corpse_serial`.
- Consumes: `DEATH` keys from task 1; `Creature#drain_carried!` (creature.rb:213).

- [ ] **Step 1: Write the failing tests** — append to `corpse_run_test.rb`:

```ruby
  # --- container creation (D1 replaces the D0 vanish) ----------------------

  def test_death_with_carry_creates_container_not_vanish
    lost = []
    loaded = []
    world.bus.subscribe(:carried_lost) { |e| lost << e }
    world.bus.subscribe(:corpse_loaded) { |e| loaded << e }
    carrier, amount = stage_loaded_death(world)
    assert_equal 0, carrier.carried, "carried drains into the container"
    assert_empty lost, "no carried_lost on death — that is expiry's event now"
    c = load_at(world, carrier.tile)
    refute_nil c, "container sits on the death tile"
    assert_equal amount, c[:amount]
    assert_equal DEATH[:corpse_term_frames], c[:term]
    assert_equal [amount], loaded.map { |e| e[:amount] }
    assert_equal [carrier.tile], loaded.map { |e| e[:tile] }
  end

  def test_death_without_carry_creates_no_container
    enter_district(world)
    victim = world.pack.living.reject { |m| m.equal?(world.possessed) }.first
    assert_equal 0, victim.carried
    kill(victim, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    assert_empty world.corpse_loads
  end

  def test_humans_never_create_containers
    enter_district(world)
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 2)
    assert_empty world.corpse_loads
  end

  def test_corpse_record_is_linked_to_its_container
    carrier, _amount = stage_loaded_death(world)
    c = load_at(world, carrier.tile)
    rec = world.corpses.find { |r| r[:container_id] == c[:id] }
    refute_nil rec, "the cosmetic corpse carries the container's serial"
  end

  def test_stacked_deaths_make_two_containers_with_distinct_ids
    carrier, amount = stage_loaded_death(world)
    second = world.possessed
    second.pick_up(2)
    second.walker.teleport(*carrier.tile)
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    kill(second, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    loads = world.corpse_loads.select { |c| c[:tile] == carrier.tile }
    assert_equal 2, loads.length, "no merging — one container per body"
    assert_equal [amount, 2], loads.map { |c| c[:amount] }, "creation order kept"
    refute_equal loads[0][:id], loads[1][:id]
  end
```

- [ ] **Step 2: Run — expect FAIL** (`corpse_loads` undefined / `:corpse_loaded`
  unregistered).

- [ ] **Step 3: Implement in `src/game/world.rb`:**

(a) EVENTS whitelist — append two symbols:

```ruby
      drop_spawned drop_picked_up drop_decayed banked carried_lost taunted
      corpse_loaded corpse_looted
```

(b) `initialize` — after `@balance = data["balance/combat"]` add
`@death = data["balance/death"]`; alongside `@drops` init add:

```ruby
      @corpse_loads = Hash.new { |h, k| h[k] = [] }
      @expiry_flashes = Hash.new { |h, k| h[k] = [] }
      @corpse_serial = 0
```

(c) Public accessors next to `def drops` (zone arg so tests and the abandoned-
zone assertions can read other zones; renderer calls it bare):

```ruby
    def corpse_loads(zone = @zone_name) = @corpse_loads[zone]
    def expiry_flashes(zone = @zone_name) = @expiry_flashes[zone]
```

(d) In `wire_events`' `:actor_died` handler, REPLACE the D0 branch
(world.rb:612-617, the comment + `if` block emitting `carried_lost`) with:

```ruby
        # D1: a dying pack body's carried value transfers to a container on
        # its corpse. Term expiry is the permanent-loss tier now.
        spawn_corpse_load(e[:actor]) if e[:actor].faction == :pack && e[:actor].carried.positive?
```

(e) New private method (near `leave_corpse`). NB `leave_corpse` has already
run for this actor inside the same handler, so `corpses.last` IS its record:

```ruby
    # The container is sim truth; the serial links it to the cosmetic corpse
    # record so the renderer/prune can hold the body at full strength while
    # loaded (tile+frame is not a key — two same-frame knockback deaths can
    # share a tile). settle_alpha rides the record like decay_frames rides
    # drops: the renderer reads no balance.
    def spawn_corpse_load(actor)
      @corpse_serial += 1
      term = @death[:corpse_term_frames]
      record = { id: @corpse_serial, tile: actor.tile, amount: actor.drain_carried!,
                 term_left: term, term:, settle_left: @death[:loot_settle_frames],
                 settle_alpha: @death[:settle_pip_alpha] }
      @corpse_loads[@zone_name] << record
      corpses.last[:container_id] = @corpse_serial
      @bus.emit(:corpse_loaded, actor:, tile: record[:tile], amount: record[:amount])
    end
```

- [ ] **Step 4: Flip the two D0 tests in `test/game/world_test.rb`** — replace
`test_carried_vanishes_when_the_body_dies` (1051-1065) and
`test_ally_death_also_vanishes_its_carried` (1067-1079) with:

```ruby
  def test_death_with_carry_leaves_a_container_d1
    stage_drop_under_possessed(world)
    press_interact(world)
    carrier = world.possessed
    amount = carrier.carried
    assert_operator amount, :>, 0
    lost = []
    world.bus.subscribe(:carried_lost) { |e| lost << e }
    kill(carrier, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    assert_equal 0, carrier.carried, "carried drains into the container (D1)"
    assert_empty lost, "carried_lost moved to term expiry"
    container = world.corpse_loads.find { |c| c[:tile] == carrier.tile }
    refute_nil container, "the pile is ON the corpse now — D1's whole point"
    assert_equal amount, container[:amount]
    assert_equal 0, world.possessed.carried, "the new body inherits nothing"
  end

  def test_ally_death_also_leaves_its_container
    stage_drop_under_possessed(world)
    press_interact(world)
    carrier = world.possessed
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    refute_equal carrier, world.possessed
    kill(carrier, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    assert_equal 0, carrier.carried
    assert_equal 1, world.corpse_loads.count { |c| c[:tile] == carrier.tile }
  end
```

Also update the section comment at world_test.rb:1049 to
`# --- carried transfers to a corpse container on death (D1) ---`.

- [ ] **Step 5: Run the full suite** — `rake`. Expected: all green (the flipped
D0 tests + the five new ones).

- [ ] **Step 6: Commit** — `git commit -am "feat(d1): corpse containers spawn on carrying pack deaths"`

---

### Task 3: term + settle clocks, expiry, per-zone flashes, link release

**Files:**
- Modify: `src/game/world.rb` — `tick_world` (~199-226), new private methods
  `tick_corpse_loads`, `tick_expiry_flashes`, `release_corpse_record`.
- Test: `test/game/corpse_run_test.rb`

**Interfaces:**
- Produces: `release_corpse_record(zone, container_id)` (private — clears the
  link + re-anchors `at_frame`; task 5 reuses it at loot); expiry emits
  `carried_lost` (amount, tile, zone) and pushes
  `{tile:, frames_left:, frames:}` onto `@expiry_flashes[zone]`.

- [ ] **Step 1: Write the failing tests:**

```ruby
  # --- clocks: term ticks everywhere, veil freezes, expiry destroys --------

  def test_term_ticks_in_abandoned_zones
    carrier, _ = stage_loaded_death(world)
    before = load_at(world, carrier.tile)[:term_left]
    # walk the pack home through the west gate (carry_home idiom)
    world.possessed.walker.teleport(1, 13)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 4)), STEP * 4)
    assert_equal "nest", world.zone_name
    drive(world, scripted({}), 100)
    after = load_at(world, carrier.tile, zone: "district")[:term_left]
    assert_operator after, :<, before - 90, "nest time is real time (tick_drops law)"
  end

  def test_term_is_frozen_during_the_wipe_veil
    carrier, _ = stage_loaded_death(world)
    killer = world.humans.reject(&:dead?).first
    world.pack.living.each { |m| kill(m, by: killer) }
    drive(world, scripted({}), 1)
    assert_equal :nest_respawn, world.states.current
    frozen = load_at(world, carrier.tile, zone: "district")[:term_left]
    drive(world, scripted({}), 50) # deep inside the 90f veil
    assert_equal frozen, load_at(world, carrier.tile, zone: "district")[:term_left],
                 "tick_world never runs during nest_respawn — terms freeze (review CF-6)"
  end

  def test_expiry_destroys_load_emits_and_flashes
    lost = []
    world.bus.subscribe(:carried_lost) { |e| lost << e }
    carrier, amount = stage_loaded_death(world)
    c = load_at(world, carrier.tile)
    c[:term_left] = 3 # direct record mutation — the drops-test idiom
    drive(world, scripted({}), 5)
    assert_nil load_at(world, carrier.tile), "container removed at expiry"
    assert_equal [{ amount:, tile: carrier.tile, zone: "district" }],
                 lost.map { |e| { amount: e[:amount], tile: e[:tile], zone: e[:zone] } }
    flash = world.expiry_flashes.find { |f| f[:tile] == carrier.tile }
    refute_nil flash, "expiry leaves a flash record in ITS zone"
    rec = world.corpses.find { |r| r[:tile] == carrier.tile && r[:faction] == :pack }
    assert_nil rec[:container_id], "link cleared at expiry"
    # expiry landed mid-drive (term_left hit 0 on the 3rd of 5 ticks) — the
    # re-anchor is "recent", not "this exact frame"
    assert_in_delta world.frame, rec[:at_frame], 5, "fade re-anchored at the expiry"
  end

  def test_expiry_flash_is_per_zone
    carrier, _ = stage_loaded_death(world)
    load_at(world, carrier.tile)[:term_left] = 200
    world.possessed.walker.teleport(1, 13)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 4)), STEP * 4)
    assert_equal "nest", world.zone_name
    drive(world, scripted({}), 250)
    assert_empty world.expiry_flashes, "the nest floor never flashes for a district expiry (review CF-4)"
    refute_empty world.expiry_flashes("district")
  end
```

- [ ] **Step 2: Run — expect FAIL** (clocks never tick).

- [ ] **Step 3: Implement.** In `tick_world`, after `tick_drops` (world.rb:223):

```ruby
      tick_drops
      tick_corpse_loads
      tick_expiry_flashes
```

New private methods (next to `tick_drops`):

```ruby
    # Corpse-load clocks tick in EVERY zone (the tick_drops law: nest time is
    # real time). Counted only in tick_world, so hitstop and the wipe veil
    # pause them deterministically. At term zero the load is destroyed —
    # carried_lost is EXPIRY's event in D1 (actor deliberately absent: the
    # body may be long revived).
    def tick_corpse_loads
      @corpse_loads.each do |zone, list|
        list.each do |c|
          c[:settle_left] -= 1 if c[:settle_left].positive?
          c[:term_left] -= 1
        end
        list.reject! do |c|
          next false if c[:term_left].positive?
          @bus.emit(:carried_lost, amount: c[:amount], tile: c[:tile], zone:)
          release_corpse_record(zone, c[:id])
          @expiry_flashes[zone] << { tile: c[:tile], frames_left: @death[:expiry_flash_frames],
                                     frames: @death[:expiry_flash_frames] }
          true
        end
      end
    end

    def tick_expiry_flashes
      @expiry_flashes.each_value do |list|
        list.each { |f| f[:frames_left] -= 1 }
        list.reject! { |f| f[:frames_left] <= 0 }
      end
    end

    # Sim-owned, event-time (loot + expiry): clear the container link and
    # re-anchor the fade, so a body held at full strength starts fading NOW
    # instead of snapping to invisible (review CF-2). Pure readers everywhere
    # else — the renderer never mutates (taunted_target law).
    def release_corpse_record(zone, container_id)
      rec = @corpses[zone].find { |c| c[:container_id] == container_id }
      return unless rec
      rec.delete(:container_id)
      rec[:at_frame] = @frame
    end
```

- [ ] **Step 4: Run the suite** — `rake`. Expected: green.
- [ ] **Step 5: Commit** — `git commit -am "feat(d1): term/settle clocks, expiry -> carried_lost, per-zone flashes"`

---

### Task 4: corpse-record protection (prune + cap exemptions)

**Files:**
- Modify: `src/game/world.rb` — `prune_caches` (~562-566), `leave_corpse` (~590-595).
- Test: `test/game/corpse_run_test.rb`

- [ ] **Step 1: Write the failing tests:**

```ruby
  # --- linked corpses outlive the cosmetic lifecycle (review CF-1) ---------

  def test_linked_corpse_survives_the_fade_prune
    carrier, _ = stage_loaded_death(world)
    drive(world, scripted({}), Game::World::CORPSE_FADE_FRAMES + 20)
    rec = world.corpses.find { |r| r[:container_id] }
    refute_nil rec, "a loaded corpse is exempt from prune_caches (review CF-1)"
    assert_equal carrier.tile, rec[:tile]
  end

  def test_cap_evicts_oldest_unlinked_never_the_linked
    carrier, _ = stage_loaded_death(world)
    linked_id = load_at(world, carrier.tile)[:id]
    45.times { |i| world.corpses << { tile: [1, 1], x: 32, y: 32, faction: :human, at_frame: world.frame } }
    # trigger one real leave_corpse (any death) to run the cap logic
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 2)
    assert world.corpses.any? { |r| r[:container_id] == linked_id },
           "cap eviction skips linked records (review CF-1)"
  end

  def test_released_corpse_fades_then_prunes_normally
    carrier, _ = stage_loaded_death(world)
    c = load_at(world, carrier.tile)
    c[:term_left] = 3
    drive(world, scripted({}), 5) # expire -> link cleared, at_frame re-anchored
    drive(world, scripted({}), Game::World::CORPSE_FADE_FRAMES + 5)
    assert_nil world.corpses.find { |r| r[:tile] == carrier.tile && r[:faction] == :pack },
               "after release the normal fade + prune lifecycle resumes"
  end
```

- [ ] **Step 2: Run — expect FAIL** (prune deletes the linked record).

- [ ] **Step 3: Implement.** `prune_caches` line 565 becomes:

```ruby
      corpses.reject! { |c| !c[:container_id] && @frame - c[:at_frame] > CORPSE_FADE_FRAMES }
```

`leave_corpse` cap line becomes evict-oldest-UNLINKED (linked records may
exceed the cap — bounded by containers alive):

```ruby
    def leave_corpse(actor)
      list = corpses
      list << { tile: actor.tile, x: actor.x, y: actor.y,
                faction: actor.faction, at_frame: @frame }
      return if list.length <= CORPSE_CAP
      evict = list.index { |c| !c[:container_id] }
      list.delete_at(evict) if evict
    end
```

- [ ] **Step 4: Run the suite** — `rake`. Expected: green.
- [ ] **Step 5: Commit** — `git commit -am "feat(d1): linked corpses exempt from prune/cap (CF-1)"`

---

### Task 5: recovery — interact priority drop → corpse → bank

**Files:**
- Modify: `src/game/world.rb` — `interact` (~179-195).
- Test: `test/game/corpse_run_test.rb`

**Interfaces:**
- Consumes: `release_corpse_record` (task 3), `Creature#pick_up` (creature.rb:211).
- Produces: `:corpse_looted` (actor, tile, amount, carried).

- [ ] **Step 1: Write the failing tests:**

```ruby
  # --- recovery: settle gates, then full transfer, creation order ----------

  def test_settle_blocks_then_admits_the_loot
    looted = []
    world.bus.subscribe(:corpse_looted) { |e| looted << e }
    carrier, amount = stage_loaded_death(world)
    world.possessed.walker.teleport(*carrier.tile)
    press_interact(world)
    assert_equal 0, world.possessed.carried, "settling corpse refuses the press"
    assert_empty looted
    drive(world, scripted({}), DEATH[:loot_settle_frames])
    press_interact(world)
    assert_equal amount, world.possessed.carried, "full amount, no partials"
    assert_nil load_at(world, carrier.tile), "container consumed"
    assert_equal [{ amount:, carried: amount, tile: carrier.tile }],
                 looted.map { |e| { amount: e[:amount], carried: e[:carried], tile: e[:tile] } }
    rec = world.corpses.find { |r| r[:tile] == carrier.tile && r[:faction] == :pack }
    assert_nil rec[:container_id], "loot releases the corpse link"
  end

  def test_interact_priority_drop_then_corpse
    carrier, amount = stage_loaded_death(world)
    drive(world, scripted({}), DEATH[:loot_settle_frames])
    world.drops << { tile: carrier.tile.dup, amount: 5, frames_left: 1800, decay_frames: 1800 }
    world.possessed.walker.teleport(*carrier.tile)
    press_interact(world)
    assert_equal 5, world.possessed.carried, "drop wins the first press (two-press rule)"
    press_interact(world)
    assert_equal 5 + amount, world.possessed.carried, "corpse loots on the second"
  end

  def test_stacked_containers_loot_in_death_order
    carrier, amount = stage_loaded_death(world)
    second = world.possessed
    second.pick_up(2)
    second.walker.teleport(*carrier.tile)
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    kill(second, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), DEATH[:loot_settle_frames] + 5)
    world.possessed.walker.teleport(*carrier.tile)
    press_interact(world)
    assert_equal amount, world.possessed.carried, "oldest container first"
    press_interact(world)
    assert_equal amount + 2, world.possessed.carried
  end
```

- [ ] **Step 2: Run — expect FAIL** (interact skips containers entirely).

- [ ] **Step 3: Implement.** In `interact`, between the drop branch and the
station lookup (after world.rb:188), insert:

```ruby
      # D1 recovery: settle-gated, full transfer, creation order on stacked
      # tiles (a settling container falls through — deterministic skip). A
      # drop on the tile won the press above: the D0 two-press rule extended.
      load = corpse_loads.find { |c| c[:tile] == source.tile && c[:settle_left] <= 0 }
      if load
        corpse_loads.delete(load)
        release_corpse_record(@zone_name, load[:id])
        source.pick_up(load[:amount])
        @bus.emit(:corpse_looted, actor: source, tile: load[:tile],
                  amount: load[:amount], carried: source.carried)
        return true
      end
```

- [ ] **Step 4: Run the suite** — `rake`. Expected: green (including the D0
`test_drop_on_station_tile_pickup_wins_then_bank`, untouched — no container in
its stage).
- [ ] **Step 5: Commit** — `git commit -am "feat(d1): own-corpse recovery via interact (drop -> corpse -> bank)"`

---

### Task 6: wipe grace + containers survive the respawn

**Files:**
- Modify: `src/game/world.rb` — `handle_possessed_death` (~628-640).
- Test: `test/game/corpse_run_test.rb`

- [ ] **Step 1: Write the failing tests:**

```ruby
  # --- wipe: grace top-up, containers survive the run back -----------------

  def wipe_pack(world)
    killer = world.humans.reject(&:dead?).first
    world.pack.living.each { |m| kill(m, by: killer) }
    drive(world, scripted({}), 1)
    assert_equal :nest_respawn, world.states.current
  end

  def test_wipe_grace_tops_up_short_terms_only
    carrier, _ = stage_loaded_death(world)
    short = load_at(world, carrier.tile)
    short[:term_left] = 100
    wipe_pack(world)
    assert_equal DEATH[:wipe_grace_frames], short[:term_left],
                 "short term topped to the grace floor"
  end

  def test_wipe_grace_leaves_long_terms_alone
    carrier, _ = stage_loaded_death(world)
    long = load_at(world, carrier.tile)
    before = long[:term_left]
    assert_operator before, :>, DEATH[:wipe_grace_frames]
    wipe_pack(world)
    assert_equal before, long[:term_left]
  end

  def test_containers_survive_the_pack_respawn
    carrier, amount = stage_loaded_death(world)
    wipe_pack(world)
    drive(world, scripted({}), DATA["balance/combat"][:respawn_frames] + 2)
    assert_equal :world, world.states.current
    assert_equal "nest", world.zone_name
    c = load_at(world, carrier.tile, zone: "district")
    refute_nil c, "the container IS the point of the run back"
    assert_equal amount, c[:amount]
  end
```

- [ ] **Step 2: Run — expect FAIL** (no grace top-up).

- [ ] **Step 3: Implement.** In `handle_possessed_death`, the wipe branch:

```ruby
      else
        @bus.emit(:pack_wiped)
        # D1 wipe grace: the run back must always be possible — every
        # container's remaining term rises to at least the grace floor.
        # (The grace covers the RUN BACK, not the veil: terms are frozen
        # during nest_respawn and the veil is only 90 frames — review CF-6.)
        grace = @death[:wipe_grace_frames]
        @corpse_loads.each_value do |list|
          list.each { |c| c[:term_left] = [c[:term_left], grace].max }
        end
        @respawn_timer = @balance[:respawn_frames]
        @states.transition_to(:nest_respawn)
      end
```

- [ ] **Step 4: Run the suite** — `rake`. Expected: green.
- [ ] **Step 5: Commit** — `git commit -am "feat(d1): wipe grace tops container terms to the floor"`

---

### Task 7: renderer — glean pip, held corpses, expiry flash

**Files:**
- Modify: `src/app/renderer.rb` — `draw` dispatch (~42-62), `draw_corpses`
  (~179-187), new `draw_corpse_loads` + `draw_expiry_flashes`.
- Test: Rule 2 gates are the test surface (task 9); `rake` must stay green.

**Interfaces:**
- Consumes: `world.corpse_loads` / `world.expiry_flashes` (current zone, pure
  reads); record fields from tasks 2-3 (`term_left`, `term`, `settle_left`,
  `settle_alpha`, `frames_left`, `frames`, `container_id`).

- [ ] **Step 1: Implement.** In `draw`, after `draw_drops(world)` insert:

```ruby
        draw_corpse_loads(world)
        draw_expiry_flashes(world)
```

`draw_corpses` holds linked bodies at full strength (review CF-1/CF-2):

```ruby
    def draw_corpses(world)
      world.corpses.each do |c|
        alpha =
          if c[:container_id]
            140 # loaded: held at full strength while the container lives
          else
            age = world.frame - c[:at_frame]
            (140 * (1.0 - age.fdiv(Game::World::CORPSE_FADE_FRAMES))).clamp(0, 140).round
          end
        base = c[:faction] == :human ? [140, 135, 125] : [150, 80, 40]
        Gosu.draw_rect(c[:x] + 4, c[:y] + 10, SIZE - 8, SIZE - 14,
                       Gosu::Color.new(alpha, *base))
      end
    end
```

New draw methods (after `draw_drops`):

```ruby
    # Glean pip (D1): hollow magenta OUTLINE on the CONTAINER's tile —
    # outline because a free drop is a filled square and the two render
    # concentric when a drop sits on a loaded corpse (review DS-4);
    # tile-anchored because a knockback kill can leave the corpse rect a
    # tile away from the interact tile (review CF-3). Dim while settling,
    # snapping to full on lootable (the ready tell, review FN-5); fades
    # over the term's final third like drops and the taunt underline.
    def draw_corpse_loads(world)
      ts = world.map.tile_size
      world.corpse_loads.each do |c|
        frac = c[:term_left].fdiv(c[:term])
        alpha = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
        alpha = (alpha * c[:settle_alpha]).round if c[:settle_left].positive?
        col = Gosu::Color.new(alpha, DROP_CORE.red, DROP_CORE.green, DROP_CORE.blue)
        size = 16
        t = 3
        x = c[:tile][0] * ts + (ts - size) / 2.0
        y = c[:tile][1] * ts + (ts - size) / 2.0
        Gosu.draw_rect(x, y, size, t, col)
        Gosu.draw_rect(x, y + size - t, size, t, col)
        Gosu.draw_rect(x, y, t, size, col)
        Gosu.draw_rect(x + size - t, y, t, size, col)
      end
    end

    # Term expiry read as an EVENT, not a disappearance: one brief dark
    # flash on the tile (per-zone records; only the current zone draws).
    def draw_expiry_flashes(world)
      ts = world.map.tile_size
      world.expiry_flashes.each do |f|
        a = (200 * f[:frames_left].fdiv(f[:frames])).round
        tx, ty = f[:tile]
        Gosu.draw_rect(tx * ts, ty * ts, ts, ts, Gosu::Color.new(a, 12, 6, 14))
      end
    end
```

- [ ] **Step 2: Run `rake`** — green (renderer is exercised by harness, not
unit tests). Quick smoke: `SKIP_CRITIC=1 rake gate SCRIPT=harness/scripts/world_loop.json`
must still pass byte-identical (no sim change in this task).
- [ ] **Step 3: Commit** — `git commit -am "feat(d1): glean pip, held corpses, expiry flash rendering"`

---

### Task 8: telemetry (review FN-1/DS-1 — the attribution instrument)

**Files:**
- Create: `src/game/telemetry.rb`
- Test: `test/game/telemetry_test.rb`
- Modify: `src/app/window.rb` (63 lines — stays far under cap),
  `harness/scenes/world_scene.rb`, `harness/replay_runner.rb` (~49-59),
  `harness/pilot.rb` (the `:quit` command execution — locate with
  `grep -n "quit" harness/pilot.rb`; print the summary line before `close!`).

**Interfaces:**
- Produces: `Game::Telemetry.new(bus)` + `#summary` → one `TELEMETRY d1_fired ...`
  line. Per-recovery metrics (wipe_to_last_loot_s, margins, contacts_en_route)
  are DERIVED offline from the existing EVENT log lines (frames are logged;
  margin = 1 - (loot_frame - load_frame)/term) — no extra sim state, by design.

- [ ] **Step 1: Write the failing test** — `test/game/telemetry_test.rb`:

```ruby
require_relative "../test_helper"
require "core/event_bus"
require "game/telemetry"

class TelemetryTest < Minitest::Test
  def test_counts_and_formats_the_d1_line
    bus = Core::EventBus.new.register(:corpse_loaded, :corpse_looted,
                                      :carried_lost, :pack_wiped, :banked)
    t = Game::Telemetry.new(bus)
    2.times { bus.emit(:corpse_loaded, amount: 1) }
    bus.emit(:pack_wiped)
    bus.emit(:corpse_looted, amount: 1)
    bus.emit(:banked, amount: 3)
    bus.process
    assert_equal "TELEMETRY d1_fired carrying_deaths=2 wipes=1 corpse_looted=1 " \
                 "carried_lost=0 banked_events=1", t.summary
  end
end
```

- [ ] **Step 2: Run — expect FAIL** (no telemetry.rb).

- [ ] **Step 3: Implement `src/game/telemetry.rb`:**

```ruby
module Game
  # D1 fun-verify instrumentation (spec review FN-1): a session that never
  # fired the corpse run must be machine-distinguishable from one that fired
  # and fell flat — "N/A never fired" indicts combat threat, not the corpse
  # system. Counts only; the per-recovery metrics derive from EVENT log lines.
  class Telemetry
    EVENTS = %i[corpse_loaded corpse_looted carried_lost pack_wiped banked].freeze

    def initialize(bus)
      @counts = Hash.new(0)
      EVENTS.each { |ev| bus.subscribe(ev) { @counts[ev] += 1 } }
    end

    def summary
      "TELEMETRY d1_fired carrying_deaths=#{@counts[:corpse_loaded]} " \
        "wipes=#{@counts[:pack_wiped]} corpse_looted=#{@counts[:corpse_looted]} " \
        "carried_lost=#{@counts[:carried_lost]} banked_events=#{@counts[:banked]}"
    end
  end
end
```

- [ ] **Step 4: Wire it.**
  - `window.rb`: `require "game/telemetry"`; in `initialize`,
    `@telemetry = Game::Telemetry.new(@world.bus)`; add
    ```ruby
    def close
      puts @telemetry.summary
      super
    end
    ```
    (the owner's `bin/play` session prints the line to the launching shell on
    Esc/close — the one session fun-verify actually needs).
  - `world_scene.rb`: add `corpse_loaded corpse_looted` to the subscribe list
    (EVENT lines feed the offline metrics); `@telemetry = Game::Telemetry.new(@world.bus)`;
    add `def summary = @telemetry.summary`.
  - `replay_runner.rb` `update`: before `close if @frame >= @run_until` becomes
    ```ruby
    if @frame >= @run_until
      puts @scene.summary if @scene.respond_to?(:summary)
      close
    end
    ```
  - `pilot.rb`: in the `:quit` execution branch, `puts @scene.summary if @scene.respond_to?(:summary)`
    before `close!` (same line in the crash-rescue path is optional — skip).

- [ ] **Step 5: Run the suite** — `rake`. Expected: green.
- [ ] **Step 6: Commit** — `git commit -am "feat(d1): TELEMETRY d1_fired line in play/replay/pilot (FN-1)"`

---

### Task 9: gate checks + pilot-authored corpse_run.json + full gate wall

**Files:**
- Modify: `harness/gate_checks.json` (23 → 26, APPEND only)
- Create: `harness/scripts/corpse_run.json` (via pilot mode — never hand-typed)
- Modify: `CLAUDE.md` (Commands bullet: add corpse_run.json to the script list)

- [ ] **Step 1: Append the three checks** to `gate_checks.json` `checks` array
(spec wording, verbatim):

```json
{
  "id": "corpse_load_reads",
  "check": "A loaded pack corpse carries a hollow magenta OUTLINE pip centered on its tile, distinct from free drops (small FILLED magenta squares), the bank station, and looted/expired corpses (no pip) - INCLUDING in any frame where a free drop occupies the same tile as a loaded corpse (filled square inside a hollow outline = two objects). If no loaded corpse appears, mark pass=false with why='not exercised by this script'."
},
{
  "id": "corpse_states_distinct",
  "check": "Across the replay's frames, loaded (full-strength body + pip), looted-empty (no pip, body fading), and expired (no pip, body fading, or a brief dark tile flash) pack corpses read as three DIFFERENT states, and a settling corpse (dim pip) reads distinct from a lootable one (full pip). Judge only the states the frames actually show; if fewer than two states appear, mark pass=false with why='not exercised by this script'."
},
{
  "id": "corpse_run_reads",
  "check": "When post-wipe frames are present, they read as a purposeful RETURN: the pack re-entering the district while at least one loaded corpse with a pip awaits. Do not infer a corpse run from mere walking; require a visible pip in the district frames. If the script has no wipe-and-return, mark pass=false with why='not exercised by this script'."
}
```

- [ ] **Step 2: Author `corpse_run.json` VIA PILOT MODE** (protocol:
`harness/pilot.rb` header; commands appended with `printf 'cmd\n' >> tmp/pilot/d1/inbox.txt`,
NEVER the Write tool):
  1. `rake pilot NAME=d1 SEED=0` in the background.
  2. Act 1 — walk into the district, kill a rusher, pick up its drop, swap off
     the carrier, get the carrier killed while the fight is live, wait out the
     settle ON CAMERA (capture the dim pip), have the survivor loot it
     (capture the full pip + the loot). Stage one frame with a fresh drop on
     the loaded corpse tile (kill a rusher adjacent first — its drop lands on
     the corpse tile only if it died there; if geometry refuses, kill a second
     rusher ON the corpse tile). Capture.
  3. Act 2 — load two bodies (both carrying), die on the same tile with one of
     them for the stacked case, then wipe. Captures at wipe.
  4. Act 3 — run back from the nest, capture the district entry (pips visible),
     recover both containers. Captures.
  5. Act 4 — leave one container un-looted with `term_left` short enough to
     expire before `run_until` (arrange in-flight: die carrying LATE, set
     run_until past its expiry; the event log asserts `carried_lost`). If the
     expiry lands on camera, capture the flash.
  6. `export corpse_run` → copy to `harness/scripts/corpse_run.json`.
  7. Remember the swap lockout: 16f after a Slam press; and captures export as
     frame K-1.
- [ ] **Step 3: Run the new gate** — `rake gate SCRIPT=harness/scripts/corpse_run.json`.
  Iterate with `SKIP_CRITIC=1` first; the full critic run is the shippable pass.
  Expect critic flakiness (INFRA JSON errors, hallucinated FAILs) — pixel-verify
  before believing a FAIL is real; retry INFRA errors.
- [ ] **Step 4: Run the FULL wall** — `rake` (all tests), `rake perf`, then all
  SIX gates: world_loop, district_hunt, specials_chain, loot_loop, taunt_anchor,
  corpse_run. loot_loop asserts D0 economy beats — if it asserted a
  carried-vanish event line, re-aim it at the container events (check its
  event expectations before assuming).
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(d1): corpse_run gate script + 3 appended vision checks"`

---

### Task 10: adversarial impl review, fold, merge

- [ ] **Step 1:** Adversarial review of `main...HEAD` (3-lens or code-reviewer
  agent; findings to `drafts/_d1-impl-review.md`). Seed suspicions: the
  `corpses.last` link stamp (handler ordering), settle/`term_left` tick
  interleavings at exactly 0, cap-eviction when ALL records are linked,
  determinism of `release_corpse_record` under stacked same-tile containers,
  loot_loop.json regression.
- [ ] **Step 2:** Fold CONFIRMED findings; re-run `rake` + the six gates.
- [ ] **Step 3:** Merge: `git checkout main && git merge --no-ff d1-corpse-run`.
  **NO push.** Checkpoint delta in `docs/CHECKPOINT.md` (measured numbers).
- [ ] **Step 4:** Deliver the fun-verify handoff — the spec's 6 questions + the
  N/A-never-fired preamble, plus the owner's session TELEMETRY line
  (they read it off the shell after closing the window).

## Self-review notes (spec coverage checked 2026-08-11)

- Spec sim requirements → tasks 2-6; presentation → task 7; telemetry → task 8;
  harness/gates → task 9; review+merge → task 10. Data → task 1.
- Determinism: no new wall-clock reads anywhere; all clocks tick in tick_world;
  the double-replay MD5 gate covers byte-identity (spec's determinism test).
- Type consistency: container record fields (`id/tile/amount/term_left/term/
  settle_left/settle_alpha`) and flash fields (`tile/frames_left/frames`) are
  identical across tasks 2, 3, 5, 7. `corpse_loads(zone)` signature identical
  in tasks 2 (def), 3/5/6 (tests), 7 (renderer, bare call).
- Known non-goals repeated from the spec: no denied-press flash, no partial
  loots, no container merging, no HUD, no new input.
