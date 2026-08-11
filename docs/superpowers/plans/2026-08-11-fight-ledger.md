# Fight Ledger Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the fight ledger (spec `docs/superpowers/specs/2026-08-11-fight-ledger-design.md`, REVISED): an engagement window that resolves fights into a glyph+number registration beat, a wipe recap on the veil, and a bank-leg tally — sim-owned, Rule-2 gated, fun-verify ready.

**Architecture:** New `Game::FightLedger` owned by `Game::World`, subscribed on the event bus (the `Game::Telemetry` pattern), ticked from `tick_world` so hitstop/veil freeze its clocks. Renderer pure-reads a beat record. All tunables in `data/balance/ledger.json`.

**Tech Stack:** Ruby 3.4.10 (`export PATH="/c/Ruby34-x64/bin:$PATH"` per shell), Gosu 1.4.6, minitest via `rake`, Rule-2 harness (`rake capture` / `rake gate` / `rake pilot`).

## Global Constraints

- Branch: `fight-ledger` off main (create in Task 1). Merge `--no-ff`, **NO push** — no remote exists.
- `src/app/window.rb` ≤ ~300 lines (currently 71 — this plan changes it by ZERO lines).
- Zero balance constants in Ruby; all numbers in `data/balance/ledger.json`.
- Events registered in `World::EVENTS` or emit raises. New event: `:fight_resolved`.
- No mocks — real `Game::World`, real data, real Gosu in harness.
- Existing vision checks NEVER weaken; the 4 new checks are APPENDED (26 → 30) with pass-true not-exercised hatches.
- Payload key is `gained:` (NEVER `yield:` — Ruby keyword hazard, review L3-codefit). Payload consumers index `e[:key]`; no kwarg destructuring.
- Cross-file invariant (asserted by test): `ledger_quiet_frames < loot_settle_frames`.
- Cadence ship gate: pilot-measured beats-per-minute in **1–4/min** over the realistic hunt segment, retune `ledger_quiet_frames` from measurement if out of band (Task 8), BEFORE the fun-verify.
- Vision critic flakes: pixel-verify before believing a FAIL; retry INFRA errors (verdict prompt already hardened 2026-08-11).
- Commit after every task; message prefix `feat(ledger):` / `test(ledger):` as fits.

**Staging lessons carried from D1 (cost hours — respect them):**
- AI walks freed bodies off tiles during swap-drive frames — teleport AFTER the swap, before the kill.
- `revive!` moves a dead carrier's tile — capture tiles BEFORE wipes.
- The wipe drive frame ticks clocks once — assert `before - 1` where relevant.
- Long idle waits get the pack killed — use `isolate_humans`.
- `kill(creature, by:)` via direct `take_hit` avoids hitstop; possessed kills trigger hitstop (use for freeze tests, avoid elsewhere).

---

### Task 1: Branch + `data/balance/ledger.json` + invariant tests

**Files:**
- Create: `data/balance/ledger.json`
- Create: `test/game/fight_ledger_test.rb`

**Interfaces:**
- Produces: `DATA["balance/ledger"]` → `{ledger_quiet_frames: 180, ledger_beat_frames: 150}` (DataStore autoloads by path — zero registration, the `balance/death` precedent). Test helpers every later task appends to.

- [ ] **Step 1: Branch**

```bash
cd /c/Users/gabri/workspace/game-two && git checkout -b fight-ledger
```

- [ ] **Step 2: Write the failing test file (helpers + invariants)**

Create `test/game/fight_ledger_test.rb`:

```ruby
require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Fight-ledger integration tests — REAL data, REAL sim, no mocks.
# Helpers mirror corpse_run_test.rb (same staging idiom).
class FightLedgerTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  LEDGER = DATA["balance/ledger"]
  DEATH = DATA["balance/death"]
  QUIET = DATA["balance/ledger"][:ledger_quiet_frames]
  BEAT = DATA["balance/ledger"][:ledger_beat_frames]
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

  def isolate_humans(world, count = 2)
    kept = world.humans.first(count)
    world.humans.replace(kept)
    kept.each_with_index do |h, i|
      h.walker.teleport(40, 23 + i)
      h.stagger!(30_000)
    end
  end

  # Kills BY the possessed trigger hitstop at the next flush, and hitstop
  # freezes the quiet clock — drain it before counting drive frames (D1
  # lesson: frozen clocks silently eat drive budgets).
  def drain_hitstop(world)
    drive(world, scripted({}), 1) while world.feel.hitstop?
  end

  # Capture :fight_resolved payloads for the whole test.
  def resolved_events(world)
    @resolved ||= [].tap do |list|
      world.bus.subscribe(:fight_resolved) { |e| list << e.payload.dup }
    end
  end

  # Open a combat window without hitstop: hurt (never kill) a parked human.
  def poke(world)
    h = world.humans.reject(&:dead?).first
    h.take_hit(damage: 1, attacker: world.possessed)
    drive(world, scripted({}), 1)
  end

  # Kill a drop-carrying human and pick its drop up (opens a window too).
  def stage_pickup(world)
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 1)
    tile = world.drops.first[:tile]
    world.possessed.walker.teleport(*tile)
    drive(world, scripted({}), 1)
    press_interact(world)
  end

  # Carrier dies loaded as an ALLY death (no wipe): pickup, swap off, kill.
  def stage_loaded_death(world)
    stage_pickup(world)
    carrier = world.possessed
    amount = carrier.carried
    assert_operator amount, :>, 0
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    refute_equal carrier, world.possessed
    kill(carrier, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    [carrier, amount]
  end

  # --- data invariants (review M5-design: the interlock is load-bearing) ---

  def test_ledger_balance_invariants
    assert_operator LEDGER[:ledger_quiet_frames], :<, DEATH[:loot_settle_frames],
                    "quiet >= settle silently kills the mid-fight negative beat (spec M5)"
    %i[ledger_quiet_frames ledger_beat_frames].each do |k|
      assert_operator LEDGER[k], :>, 0, "#{k} must be a positive frame count"
    end
  end
end
```

- [ ] **Step 3: Run to verify it fails on the missing file**

```bash
export PATH="/c/Ruby34-x64/bin:$PATH" && ruby -Ilib -Isrc -Itest test/game/fight_ledger_test.rb
```
Expected: FAIL/ERROR — `balance/ledger` missing from the DataStore.

- [ ] **Step 4: Create the data file**

`data/balance/ledger.json`:

```json
{
  "ledger_quiet_frames": 180,
  "ledger_beat_frames": 150
}
```

- [ ] **Step 5: Run the test — invariants pass**

```bash
ruby -Ilib -Isrc -Itest test/game/fight_ledger_test.rb
```
Expected: 1 runs, PASS. Then `rake` — all 195 green.

- [ ] **Step 6: Commit**

```bash
git add data/balance/ledger.json test/game/fight_ledger_test.rb
git commit -m "feat(ledger): balance file + quiet<settle interlock assertion"
```

---

### Task 2: `Game::FightLedger` core — window lifecycle + World wiring

**Files:**
- Create: `src/game/fight_ledger.rb`
- Modify: `src/game/world.rb` (EVENTS line 22-23; require block line 1-10; initialize after `wire_events` line 62; tick_world tail line 247; readers near line 78)
- Test: `test/game/fight_ledger_test.rb` (append)

**Interfaces:**
- Consumes: `data["balance/ledger"]`, bus events `damage_dealt`, `actor_died` (payload `actor:, killer:, faction:`).
- Produces: `Game::FightLedger.new(bus, world:, config:)` with `#tick` and `#beat`; `World#ledger_beat`; `World#total_stranded`; event `:fight_resolved` with payload `(zone:, span_frames:, opened_by:, kills:, pack_deaths:, gained:, stranded:, destroyed:, net:, wiped:)`. Beat record `{kind:, gained:, pip_amount:, dark_amount:, net:, recovery:, beat_left:, beat_frames:}` — later tasks (renderer, telemetry) rely on these EXACT names.

- [ ] **Step 1: Append failing tests**

```ruby
  # --- window lifecycle (Task 2) ---

  def test_window_opens_on_damage_and_resolves_after_quiet
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    poke(world)                          # damage_dealt opens (flush this frame)
    drive(world, scripted({}), QUIET - 30)
    assert_empty events
    kill(world.humans.reject(&:dead?).first, by: world.possessed) # refresh + qualify
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    assert_equal 1, events.length
    e = events.first
    assert_equal "district", e[:zone]
    assert_equal :combat, e[:opened_by]
    assert_equal 1, e[:kills]
    refute e[:wiped]
    assert_equal :fight, world.ledger_beat[:kind]
  end
  # (The kill at QUIET-30 also PROVES refresh: the window outlived its
  # original deadline.)

  def test_kill_without_pickup_prints_honest_zero
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    assert_equal 1, events.length
    assert_equal 1, events.first[:kills]
    assert_equal 0, events.first[:gained], "abandonment prints +0 (spec H3 trade)"
  end

  def test_graze_only_window_dissolves_silently
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    poke(world)                          # damage, but no kill and no loot
    drive(world, scripted({}), QUIET + 2)
    assert_empty events, "a pure graze exchange must dissolve, not print"
    assert_nil world.ledger_beat
  end

  def test_beat_clears_after_beat_frames
    enter_district(world)
    isolate_humans(world)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    refute_nil world.ledger_beat
    drive(world, scripted({}), BEAT + 1)
    assert_nil world.ledger_beat
  end

  def test_span_frames_counts_ticked_frames_not_at_frame
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    e = events.first
    # window opened at the kill's flush; span counts TICKED frames only —
    # the drained hitstop frames advanced @frame but not the span.
    assert_operator e[:span_frames], :>=, QUIET
    assert_operator e[:span_frames], :<=, QUIET + 8
  end
```

- [ ] **Step 2: Run — fails (`fight_ledger.rb` absent, `:fight_resolved` unregistered)**

- [ ] **Step 3: Implement**

Create `src/game/fight_ledger.rb`:

```ruby
module Game
  # Sim-owned fight accounting (fight-ledger spec 2026-08-11): an engagement
  # window opens on combat or recovery, accrues the fight's loot movements,
  # and resolves after a quiet period into a registration beat the renderer
  # pure-reads. A leg accumulator reconciles at each banking. Clocks tick
  # only from tick_world, so hitstop and the wipe veil freeze them like
  # every D1 clock. MUST be constructed AFTER wire_events: World's
  # actor_died handler queues corpse_loaded/pack_wiped ahead of this
  # object's handlers in the same flush (the wipe-ordering pin).
  class FightLedger
    attr_reader :beat

    def initialize(bus, world:, config:)
      @bus = bus
      @world = world
      @quiet_frames = config[:ledger_quiet_frames]
      @beat_frames = config[:ledger_beat_frames]
      @window = nil
      @beat = nil
      @leg_gained = 0
      @leg_destroyed = 0
      wire
    end

    def tick
      if @beat
        @beat[:beat_left] -= 1
        @beat = nil unless @beat[:beat_left].positive?
      end
      return unless @window
      @window[:span] += 1
      @window[:quiet_left] -= 1
      resolve! if @window[:quiet_left] <= 0
    end

    private

    def wire
      @bus.subscribe(:damage_dealt) { open_or_refresh(:combat) }
      @bus.subscribe(:actor_died) do |e|
        open_or_refresh(:combat)
        if e[:faction] == :human
          @window[:kills] += 1
        else
          @window[:pack_deaths] += 1
        end
      end
      @bus.subscribe(:corpse_looted) do |e|
        open_or_refresh(:recovery)
        @window[:gained] += e[:amount]
      end
      @bus.subscribe(:drop_picked_up) do |e|
        @leg_gained += e[:amount] # leg counts FIRST acquisition, always
        next unless @window      # refreshes but NEVER opens (spec H3)
        @window[:quiet_left] = @quiet_frames
        @window[:gained] += e[:amount]
      end
      @bus.subscribe(:corpse_loaded) do |e|
        @window[:stranded] += e[:amount] if @window
      end
      @bus.subscribe(:carried_lost) do |e|
        @leg_destroyed += e[:amount] # at leg scale every expiry is a loss
        @window[:destroyed] += e[:amount] if @window && e[:zone] == @window[:zone]
      end
      @bus.subscribe(:pack_wiped) { resolve!(wiped: true) }
      @bus.subscribe(:zone_entered) { resolve! } # force-resolve on transition
      @bus.subscribe(:banked) { bank! }
    end

    def open_or_refresh(kind)
      if @window
        @window[:quiet_left] = @quiet_frames
      else
        # zone captured at OPEN — @zone_name is already the destination by
        # the time a transition's events flush (review M2-codefit).
        @window = { zone: @world.zone_name, opened_by: kind, span: 0,
                    quiet_left: @quiet_frames, gained: 0, stranded: 0,
                    destroyed: 0, kills: 0, pack_deaths: 0 }
      end
    end

    def resolve!(wiped: false)
      w = @window
      @window = nil
      return unless w
      qualifies = wiped || (w[:kills] + w[:pack_deaths]).positive? ||
                  (w[:gained] + w[:stranded] + w[:destroyed]).positive?
      return unless qualifies # dissolve — never stomps a live beat
      net = w[:gained] - w[:stranded] - w[:destroyed]
      @bus.emit(:fight_resolved, zone: w[:zone], span_frames: w[:span],
                opened_by: w[:opened_by], kills: w[:kills],
                pack_deaths: w[:pack_deaths], gained: w[:gained],
                stranded: w[:stranded], destroyed: w[:destroyed],
                net:, wiped:)
      # The WIPE recap's pip line is the FIELD truth (all live containers),
      # not this window's accrual (review M4-design). Its displayed net is
      # the field-truth net; the event payload keeps window semantics.
      pip = wiped ? @world.total_stranded : w[:stranded]
      @beat = { kind: wiped ? :wipe : :fight, gained: w[:gained],
                pip_amount: pip, dark_amount: w[:destroyed],
                net: w[:gained] - pip - w[:destroyed],
                recovery: w[:opened_by] == :recovery,
                beat_left: @beat_frames, beat_frames: @beat_frames }
    end

    def bank!
      @beat = { kind: :bank, gained: @leg_gained,
                pip_amount: @world.total_stranded, # outstanding, NOT in net
                dark_amount: @leg_destroyed,
                net: @leg_gained - @leg_destroyed, recovery: false,
                beat_left: @beat_frames, beat_frames: @beat_frames }
      @leg_gained = 0
      @leg_destroyed = 0
    end
  end
end
```

Modify `src/game/world.rb` — four edits:

1. Require (after `require "game/flow_field"`):
```ruby
require "game/fight_ledger"
```
2. EVENTS (line 22-23):
```ruby
      drop_spawned drop_picked_up drop_decayed banked carried_lost taunted
      corpse_loaded corpse_looted fight_resolved
```
3. In `initialize`, REPLACE the two lines `wire_events` / `enter_zone(HOME_ZONE, map.pack_spawn)` with:
```ruby
    wire_events
    # Constructed after wire_events ON PURPOSE: World's actor_died handler
    # must queue corpse_loaded/pack_wiped ahead of the ledger's handlers in
    # the same flush (the wipe-ordering pin, spec M6).
    @fight_ledger = FightLedger.new(@bus, world: self,
                                    config: data["balance/ledger"])
    enter_zone(HOME_ZONE, map.pack_spawn)
```
4. Readers (after the `expiry_flashes` reader, line ~78) and the tick seam:
```ruby
    def ledger_beat = @fight_ledger.beat
    def total_stranded = @corpse_loads.values.sum { |list| list.sum { |c| c[:amount] } }
```
and in `tick_world`'s tail, after `tick_expiry_flashes`:
```ruby
      tick_expiry_flashes
      @fight_ledger.tick
```

- [ ] **Step 4: Run the ledger tests, then the full suite**

```bash
ruby -Ilib -Isrc -Itest test/game/fight_ledger_test.rb && rake
```
Expected: all green (existing suites unaffected — the ledger only observes).

- [ ] **Step 5: Commit**

```bash
git add src/game/fight_ledger.rb src/game/world.rb test/game/fight_ledger_test.rb
git commit -m "feat(ledger): engagement window + fight_resolved + beat record"
```

---

### Task 3: Accrual correctness — refresh, recovery, zones, churn, negative

**Files:**
- Modify: `test/game/fight_ledger_test.rb` (append only — implementation shipped in Task 2; this task PROVES it and catches regressions red)

**Interfaces:**
- Consumes: Task 2's event payload and helpers verbatim.

- [ ] **Step 1: Append the tests**

```ruby
  # --- accrual correctness (Task 3) ---

  def test_pickup_refreshes_an_open_window_and_counts
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    kill(nearest_human(world), by: world.possessed) # opens + drop spawns
    drive(world, scripted({}), QUIET - 30)          # near deadline...
    tile = world.drops.first[:tile]
    amount = world.drops.first[:amount]
    world.possessed.walker.teleport(*tile)
    press_interact(world)                            # ...sweep refreshes
    drive(world, scripted({}), QUIET - 30)
    assert_empty events, "pickup must refresh the quiet clock (spec H3)"
    drive(world, scripted({}), 40)
    assert_equal 1, events.length
    assert_equal amount, events.first[:gained], "the sweep is the fight's take"
  end

  def test_pickup_outside_any_window_opens_nothing
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    kill(nearest_human(world), by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)            # fight resolves, +0
    assert_equal 1, events.length
    tile = world.drops.first[:tile]
    world.possessed.walker.teleport(*tile)
    press_interact(world)                            # ambient glean
    drive(world, scripted({}), QUIET + 2)
    assert_equal 1, events.length, "ambient gleaning must not open a window"
  end

  def test_recovery_opens_a_window_and_marks_the_beat
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world, 1)
    _carrier, amount = stage_loaded_death(world)
    drive(world, scripted({}), QUIET + 2)            # death fight resolves
    assert_equal 1, events.length
    assert_equal amount, events.first[:stranded]
    assert_equal(-amount, events.first[:net], "stranded fight is negative")
    assert_equal amount, world.ledger_beat[:pip_amount]
    # wait out the settle, then loot: a bloodless recovery engagement
    load = world.corpse_loads.first
    drive(world, scripted({}), load[:settle_left] + 1)
    world.possessed.walker.teleport(*load[:tile])
    press_interact(world)
    drive(world, scripted({}), QUIET + 2)
    assert_equal 2, events.length
    e = events.last
    assert_equal :recovery, e[:opened_by]
    assert_equal amount, e[:gained]
    assert world.ledger_beat[:recovery], "redemption beat carries the pip prefix"
  end

  def test_stranded_then_recovered_same_window_nets_zero
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world, 1)
    _carrier, amount = stage_loaded_death(world)
    load = world.corpse_loads.first
    # keep the window alive through the settle with periodic grazes
    (load[:settle_left] / 100 + 1).times do
      poke(world)
      drive(world, scripted({}), 100)
    end
    assert world.corpse_loads.first[:settle_left] <= 0
    world.possessed.walker.teleport(*load[:tile])
    press_interact(world)                            # loot IN-window
    drive(world, scripted({}), QUIET + 2)
    assert_equal 1, events.length
    e = events.first
    assert_equal amount, e[:stranded]
    assert_operator e[:gained], :>=, amount          # recovery + any pickups
    assert_equal e[:gained] - e[:stranded], e[:net], "churn nets honestly"
  end

  def test_carried_lost_is_zone_filtered_for_the_window_but_not_the_leg
    events = resolved_events(world)
    # Make a container IN THE NEST (carrier killed at home by direct hits).
    enter_district(world)
    isolate_humans(world, 1)
    stage_pickup(world)
    # walk back to the nest through the west gate
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 30 - 1)), STEP * 30)
    assert_equal "nest", world.zone_name
    carrier = world.possessed
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    kill(carrier, by: world.pack.possessed) # attacker identity irrelevant
    drive(world, scripted({}), 2)
    nest_load = world.corpse_loads("nest").first
    refute_nil nest_load
    # Go fight in the district; expire the nest container mid-window.
    drive(world, scripted(hold(:right, world.frame, world.frame + STEP * 30 - 1)), STEP * 30)
    assert_equal "district", world.zone_name
    events.clear
    poke(world)
    nest_load[:term_left] = 5
    drive(world, scripted({}), 10)                   # expiry fires off-zone
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    e = events.last
    assert_equal 0, e[:destroyed], "off-zone expiry must not enter the window"
  end

  def test_zone_transition_force_resolves_with_the_origin_zone
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    # Stage NEXT TO the gate so the retreat fits inside the quiet window —
    # a 30-tile walk would let the window quiet-resolve mid-walk and the
    # test would pass without exercising the force-resolve at all.
    world.possessed.walker.teleport(3, 13)
    drive(world, scripted({}), 1)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 6 - 1)), STEP * 6)
    assert_equal "nest", world.zone_name
    assert_equal 1, events.length
    assert_equal "district", events.first[:zone], "zone captured at OPEN (review M2)"
  end
```

- [ ] **Step 2: Run — all must pass against Task 2's implementation**

```bash
ruby -Ilib -Isrc -Itest test/game/fight_ledger_test.rb
```
If any fails, the DEFECT IS IN TASK 2's CODE (or the staging hit a D1 lesson — check the swap/teleport notes). Fix `fight_ledger.rb`, never weaken an assertion.

- [ ] **Step 3: Full suite + commit**

```bash
rake && git add test/game/fight_ledger_test.rb src/game/fight_ledger.rb && git commit -m "test(ledger): accrual correctness - refresh, recovery, zones, churn"
```

---

### Task 4: Wipe recap + replacement discipline

**Files:**
- Modify: `test/game/fight_ledger_test.rb` (append)

**Interfaces:**
- Consumes: `World#total_stranded`, the `:wipe` beat record shape, `@balance[:respawn_frames]` veil length.

- [ ] **Step 1: Append the tests**

```ruby
  # --- wipe recap + replacement (Task 4) ---

  def wipe_pack(world)
    (world.pack.living - [world.possessed]).each do |ally|
      kill(ally, by: world.humans.reject(&:dead?).first || world.possessed)
    end
    kill(world.possessed, by: world.humans.reject(&:dead?).first || world.pack.members.first)
    drive(world, scripted({}), 1)
  end

  def test_wipe_resolves_immediately_with_field_truth_snapshot
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world, 1)
    _carrier, amount = stage_loaded_death(world)     # container 1 (pre-wipe)
    drive(world, scripted({}), QUIET + 2)            # that fight resolves
    events.clear
    stage_pickup(world)                              # possessed carries again
    carrying = world.possessed.carried
    assert_operator carrying, :>, 0
    wipe_pack(world)                                 # dying possessed strands #2
    e = events.last
    refute_nil e
    assert e[:wiped]
    assert_equal carrying, e[:stranded], "wipe-tick corpse_loaded accrued BEFORE the resolve (ordering pin, spec M6)"
    beat = world.ledger_beat
    assert_equal :wipe, beat[:kind]
    assert_equal amount + carrying, beat[:pip_amount], "recap pip = ALL live containers (field truth, review M4)"
    assert_equal world.total_stranded, beat[:pip_amount]
  end

  def test_wipe_recap_survives_the_veil_frozen
    enter_district(world)
    isolate_humans(world, 1)
    stage_pickup(world)
    wipe_pack(world)
    beat_left_at_wipe = world.ledger_beat[:beat_left]
    drive(world, scripted({}), 40)                   # deep inside the veil
    assert_equal :nest_respawn, world.states.current
    assert_equal beat_left_at_wipe, world.ledger_beat[:beat_left],
                 "beat_left must freeze during nest_respawn (tick_world never runs)"
  end

  def test_dissolve_never_stomps_a_live_beat
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)            # beat is live (150f budget)
    live_beat = world.ledger_beat
    refute_nil live_beat
    # Gate-adjacent staging: the whole poke-and-exit must finish well inside
    # the beat's 150-frame display budget or the assert races the clear.
    world.possessed.walker.teleport(2, 13)
    drive(world, scripted({}), 1)
    poke(world)                                      # graze-only window...
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 5 - 1)), STEP * 5)
    assert_equal "nest", world.zone_name             # ...force-resolved: dissolves
    assert_equal 1, events.length
    assert_same live_beat, world.ledger_beat, "a dissolve must never replace a live beat (review M4)"
  end

  def test_qualifying_resolve_replaces_a_live_beat
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    first_beat = world.ledger_beat
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)
    drive(world, scripted({}), QUIET + 2)
    assert_equal 2, events.length
    refute_same first_beat, world.ledger_beat
  end

  def test_quiet_clock_freezes_under_hitstop
    events = resolved_events(world)
    enter_district(world)
    isolate_humans(world)
    poke(world)
    # a possessed kill triggers hitstop (feel.on_kill) while also refreshing
    kill(world.humans.reject(&:dead?).first, by: world.possessed)
    drain_hitstop(world)                 # frozen frames: clock must not move
    drive(world, scripted({}), QUIET - 1)
    assert_empty events, "hitstop frames must not count against the quiet clock"
    drive(world, scripted({}), 3)
    assert_equal 1, events.length
  end
```

- [ ] **Step 2: Run; fix `fight_ledger.rb` on any red (assertions never weaken)**

- [ ] **Step 3: Full suite + commit**

```bash
rake && git add test/game/fight_ledger_test.rb src/game/fight_ledger.rb && git commit -m "test(ledger): wipe recap snapshot, veil freeze, replacement discipline"
```

---

### Task 5: Leg accumulator + bank tally

**Files:**
- Modify: `test/game/fight_ledger_test.rb` (append)

**Interfaces:**
- Consumes: the `:bank` beat record shape from Task 2.

- [ ] **Step 1: Append the tests**

```ruby
  # --- bank-leg tally (Task 5) ---

  def bank!(world)
    station = world.map.stations.find { |s| s[:type] == "bank" }
    world.possessed.walker.teleport(*station[:at])
    press_interact(world)
  end

  def test_bank_tally_reconciles_the_leg_and_resets
    enter_district(world)
    isolate_humans(world)
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 1)
    tile = world.drops.first[:tile]
    amount = world.drops.first[:amount]
    world.possessed.walker.teleport(*tile)
    press_interact(world)
    # walk home and bank
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 30 - 1)), STEP * 30)
    assert_equal "nest", world.zone_name
    bank!(world)
    beat = world.ledger_beat
    assert_equal :bank, beat[:kind]
    assert_equal amount, beat[:gained], "leg gained = first-acquisition pickups"
    assert_equal 0, beat[:dark_amount]
    assert_equal amount, beat[:net]
    # a second immediate bank has nothing to bank (carried is 0), so stage
    # another pickup round-trip and verify the accumulator was RESET
    drive(world, scripted(hold(:right, world.frame, world.frame + STEP * 30 - 1)), STEP * 30)
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 1)
    tile2 = world.drops.first[:tile]
    amount2 = world.drops.first[:amount]
    world.possessed.walker.teleport(*tile2)
    press_interact(world)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 30 - 1)), STEP * 30)
    bank!(world)
    assert_equal amount2, world.ledger_beat[:gained], "leg reset on bank"
  end

  def test_recovery_does_not_double_count_into_the_leg
    enter_district(world)
    isolate_humans(world, 1)
    _carrier, amount = stage_loaded_death(world)
    load = world.corpse_loads.first
    drive(world, scripted({}), load[:settle_left] + 1)
    world.possessed.walker.teleport(*load[:tile])
    press_interact(world)                            # recovery re-acquires
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 30 - 1)), STEP * 30)
    bank!(world)
    assert_equal amount, world.ledger_beat[:gained],
                 "corpse_looted must NOT feed leg_gained (first-acquisition convention)"
  end

  def test_bank_tally_shows_outstanding_stranded_excluded_from_net
    enter_district(world)
    isolate_humans(world, 2)                         # TWO kills staged below
    stage_pickup(world)                              # possessed carries A
    kill(world.humans.reject(&:dead?).first, by: world.possessed) # drop B
    drain_hitstop(world)
    drive(world, scripted({}), 1)
    b_tile = world.drops.first[:tile]
    b_amount = world.drops.first[:amount]
    carrier = world.possessed
    a_amount = carrier.carried
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    kill(carrier, by: world.possessed)               # A stranded (ally death)
    drive(world, scripted({}), 2)
    world.possessed.walker.teleport(*b_tile)
    press_interact(world)                            # B picked up
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 30 - 1)), STEP * 30)
    bank!(world)
    beat = world.ledger_beat
    assert_equal :bank, beat[:kind]
    assert_equal a_amount + b_amount, beat[:gained]
    assert_equal a_amount, beat[:pip_amount], "outstanding stranded on the pip line"
    assert_equal a_amount + b_amount, beat[:net], "outstanding EXCLUDED from leg net"
  end
```

- [ ] **Step 2: Run; fix on red; full suite; commit**

```bash
rake && git add test/game/fight_ledger_test.rb src/game/fight_ledger.rb && git commit -m "test(ledger): bank-leg tally - first acquisition, reset, outstanding pip"
```

---

### Task 6: Telemetry extension

**Files:**
- Modify: `src/game/telemetry.rb`
- Modify: `test/game/telemetry_test.rb` (the byte-exact assert is REWRITTEN — named in the spec; never weakened to a substring match)
- Modify: `harness/scenes/world_scene.rb:19-23` (add `fight_resolved` to the logged event list)

**Interfaces:**
- Consumes: `:fight_resolved` payload keys `opened_by:`, `net:`.
- Produces: summary line `"... banked_events=N fights=N recovery_fights=N negative_fights=N"` — the pilot/gate analysis in Task 8 parses `fights=` from it.

- [ ] **Step 1: Rewrite the telemetry test (failing)**

Replace the body of `test/game/telemetry_test.rb`:

```ruby
require_relative "../test_helper"
require "core/event_bus"
require "game/telemetry"

class TelemetryTest < Minitest::Test
  def test_counts_and_formats_the_session_line
    bus = Core::EventBus.new.register(:corpse_loaded, :corpse_looted,
                                      :carried_lost, :pack_wiped, :banked,
                                      :fight_resolved)
    t = Game::Telemetry.new(bus)
    2.times { bus.emit(:corpse_loaded, amount: 1) }
    bus.emit(:pack_wiped)
    bus.emit(:corpse_looted, amount: 1)
    bus.emit(:banked, amount: 3)
    bus.emit(:fight_resolved, opened_by: :combat, net: -4)
    bus.emit(:fight_resolved, opened_by: :recovery, net: 4)
    bus.process
    assert_equal "TELEMETRY d1_fired carrying_deaths=2 wipes=1 corpse_looted=1 " \
                 "carried_lost=0 banked_events=1 fights=2 recovery_fights=1 " \
                 "negative_fights=1", t.summary
  end
end
```

- [ ] **Step 2: Run — fails on the missing fields**

- [ ] **Step 3: Implement**

`src/game/telemetry.rb` becomes:

```ruby
module Game
  # Fun-verify instrumentation: D1 corpse-run counts (spec FN-1) plus the
  # fight-ledger counts (LB-1). Counts only; per-event metrics derive from
  # the harness EVENT log lines.
  class Telemetry
    EVENTS = %i[corpse_loaded corpse_looted carried_lost pack_wiped banked].freeze

    def initialize(bus)
      @counts = Hash.new(0)
      EVENTS.each { |ev| bus.subscribe(ev) { @counts[ev] += 1 } }
      bus.subscribe(:fight_resolved) do |e|
        @counts[:fights] += 1
        @counts[:recovery_fights] += 1 if e[:opened_by] == :recovery
        @counts[:negative_fights] += 1 if e[:net].negative?
      end
    end

    def summary
      "TELEMETRY d1_fired carrying_deaths=#{@counts[:corpse_loaded]} " \
        "wipes=#{@counts[:pack_wiped]} corpse_looted=#{@counts[:corpse_looted]} " \
        "carried_lost=#{@counts[:carried_lost]} banked_events=#{@counts[:banked]} " \
        "fights=#{@counts[:fights]} recovery_fights=#{@counts[:recovery_fights]} " \
        "negative_fights=#{@counts[:negative_fights]}"
    end
  end
end
```

`harness/scenes/world_scene.rb` — add `fight_resolved` to the subscribed log list (payload is scalar-only, `describe` handles it):

```ruby
        %i[telegraph attack_hit actor_died dodged possession_changed
           pack_wiped pack_respawned zone_entered projectile_fired
           special_started pack_mark_set drop_spawned drop_picked_up
           drop_decayed banked carried_lost taunted
           corpse_loaded corpse_looted fight_resolved].each do |ev|
```

- [ ] **Step 4: Full suite + commit**

```bash
rake && git add src/game/telemetry.rb test/game/telemetry_test.rb harness/scenes/world_scene.rb
git commit -m "feat(ledger): telemetry fights/recovery/negative counts + harness log line"
```

---

### Task 7: Renderer — the beat, drawn over the veil

**Files:**
- Modify: `src/app/renderer.rb` (constants block ~line 38; `draw` lines 59-64; new methods after `draw_stagger_veil` ~line 425)

**Interfaces:**
- Consumes: `world.ledger_beat` record `{kind:, gained:, pip_amount:, dark_amount:, net:, recovery:, beat_left:, beat_frames:}`.
- Produces: the Rule-2 surface Tasks 8-9 capture. Layout constants are code-side (the `LEDGER_RADIUS_TILES` precedent); NO balance reads.

- [ ] **Step 1: Add constants (after `STAGGER_VEIL`)**

```ruby
    LEDGER_NEG    = Gosu::Color.new(255, 200, 40, 40)  # wipe-red family
    LEDGER_DARK   = Gosu::Color.new(255, 26, 13, 30)   # expiry-flash family
    LEDGER_BEAT_Y = 96                                  # below the banner line
```

- [ ] **Step 2: Pin the draw order (replace lines 61-63 of `draw`)**

```ruby
      draw_banner(world) if world.banner?
      draw_wipe_overlay(world) if world.states.current == :nest_respawn
      # AFTER the wipe overlay BY DESIGN: the alpha-170 veil would bury the
      # recap, and the recap legible through the veil is the point (spec:
      # one owned draw-order decision; review M1-codefit).
      draw_ledger_beat(world)
      draw_stagger_veil(world) if world.possessed.staggered?
```

- [ ] **Step 3: Implement the beat drawing (after `draw_stagger_veil`)**

```ruby
    # Registration beat (fight-ledger spec): 1-3 glyph+number lines, timed,
    # top-center. Glyph grammar is the game's own: filled square = acquired
    # value, hollow pip = pile-on-a-corpse (recoverable, calm), dark square
    # = destroyed (gone). No words — nothing blocks on the bible. Alpha
    # fades over the final third of beat_left (the drop-decay grammar).
    # Pure reader: everything needed rides the beat record.
    def draw_ledger_beat(world)
      beat = world.ledger_beat
      return unless beat
      frac = beat[:beat_left].fdiv(beat[:beat_frames])
      a = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
      cx = view_width(world) / 2
      y = LEDGER_BEAT_Y
      y = draw_beat_take(beat, cx, y, a)
      return unless (beat[:pip_amount] + beat[:dark_amount]).positive?
      y = draw_beat_losses(beat, cx, y, a)
      draw_beat_net(beat, cx, y, a)
    end

    def draw_beat_take(beat, cx, y, a)
      col = fade(DROP_CORE, a)
      text = "+#{beat[:gained]}"
      w = 16 + hud_font.text_width(text) + (beat[:recovery] ? 16 : 0)
      x = cx - w / 2
      x = draw_hollow_pip(x, y + 2, 10, fade(DROP_CORE, a)) + 6 if beat[:recovery]
      Gosu.draw_rect(x, y + 2, 10, 10, col)
      hud_font.draw_text(text, x + 16, y, 30, 1, 1, col)
      y + 18
    end

    def draw_beat_losses(beat, cx, y, a)
      parts = []
      parts << [:pip, "-#{beat[:pip_amount]}"] if beat[:pip_amount].positive?
      parts << [:dark, "-#{beat[:dark_amount]}"] if beat[:dark_amount].positive?
      w = parts.sum { |(_, t)| 16 + hud_font.text_width(t) + 10 } - 10
      x = cx - w / 2
      parts.each do |(kind, text)|
        if kind == :pip
          draw_hollow_pip(x, y + 2, 10, fade(DROP_CORE, a))
          hud_font.draw_text(text, x + 16, y, 30, 1, 1, fade(BANNER, a))
        else
          Gosu.draw_rect(x - 1, y + 1, 12, 12, fade(LEDGER_NEG, a))
          Gosu.draw_rect(x, y + 2, 10, 10, fade(LEDGER_DARK, a))
          hud_font.draw_text(text, x + 16, y, 30, 1, 1, fade(LEDGER_NEG, a))
        end
        x += 16 + hud_font.text_width(text) + 10
      end
      y + 18
    end

    def draw_beat_net(beat, cx, y, a)
      col = beat[:net].negative? ? fade(LEDGER_NEG, a) : fade(DROP_CORE, a)
      text = "= #{beat[:net].negative? ? '' : '+'}#{beat[:net]}"
      ledger_font.draw_text(text, cx - ledger_font.text_width(text) / 2, y, 30, 1, 1, col)
    end

    def draw_hollow_pip(x, y, size, col)
      t = 2
      Gosu.draw_rect(x, y, size, t, col)
      Gosu.draw_rect(x, y + size - t, size, t, col)
      Gosu.draw_rect(x, y, t, size, col)
      Gosu.draw_rect(x + size - t, y, t, size, col)
      x + size
    end

    def fade(color, a)
      Gosu::Color.new((color.alpha * a / 255.0).round, color.red, color.green, color.blue)
    end

    def ledger_font = @ledger_font ||= Gosu::Font.new(16, bold: true)
```

- [ ] **Step 4: Full suite green, then EARLY determinism re-check of every existing gate script (beats now render inside old replays — catch surprises before the pilot task)**

```bash
rake && for s in world_loop district_hunt loot_loop specials_chain taunt_anchor corpse_run; do
  SKIP_CRITIC=1 rake gate SCRIPT=harness/scripts/$s.json || echo "DETERMINISM FAIL: $s"
done
```
Expected: all six MD5-deterministic. (Vision verdicts come later — Task 9 runs the full wall.)

- [ ] **Step 5: Commit**

```bash
git add src/app/renderer.rb
git commit -m "feat(ledger): registration beat rendering - glyph grammar, drawn over the veil"
```

---

### Task 8: Pilot flight — author `ledger_loop.json` + the cadence ship gate

**Files:**
- Create: `harness/scripts/ledger_loop.json` (via pilot EXPORT — never hand-written)
- Possibly modify: `data/balance/ledger.json` (quiet retune from measurement)

**Interfaces:**
- Consumes: pilot protocol (FULL protocol: `harness/pilot.rb` header — read it before starting), Task 6's `fights=` telemetry field.
- Produces: the 7th gate script; the measured beats-per-minute number for the checkpoint.

- [ ] **Step 1: Start a pilot session**

```bash
export PATH="/c/Ruby34-x64/bin:$PATH" && rake pilot NAME=ledger SEED=0
```
Drive via `printf 'cmd\n' >> tmp/pilot/ledger/inbox.txt` (NEVER the Write tool — byte-offset reader), read `tmp/pilot/ledger/log.txt`.

- [ ] **Step 2: Fly the five acts (captures ≤ 20 total, aim by log frames)**

1. **Act 1 — clean win:** enter district, kill 1-2 rushers, sweep drops, disengage; capture the one-line `+N` beat.
2. **Act 2 — negative beat:** die carrying (swap off, let carrier fall), retreat out of aggro, wait out the quiet; capture the pip loss line + red net.
3. **Act 3 — wipe recap:** re-engage carrying, wipe; capture the recap ON the veil (snapshot pip number legible).
4. **Act 4 — redemption:** run back, wait settle, loot; capture the pip-prefixed take line.
5. **Act 5 — bank tally:** walk home, bank; capture the `:bank` beat at the station.

- [ ] **Step 3: Measure the cadence gate**

From the pilot log, over the realistic hunting stretch (act 1 + surrounding play, NOT idle waits): `beats_per_min = fight_resolved_count / (stretch_frames / 3600.0)`. **SHIP GATE: 1 ≤ beats/min ≤ 4.** If out of band: retune `ledger_quiet_frames` from the measured inter-event gaps (log timestamps), re-run the flight, re-measure. Record the final number for the checkpoint.

- [ ] **Step 4: Export and verify**

```bash
printf 'export ledger_loop\n' >> tmp/pilot/ledger/inbox.txt
# then quit the pilot and re-run deterministically:
rake capture SCRIPT=harness/scripts/ledger_loop.json
SKIP_CRITIC=1 rake gate SCRIPT=harness/scripts/ledger_loop.json
```
Expected: byte-identical double replay.

- [ ] **Step 5: Commit**

```bash
git add harness/scripts/ledger_loop.json data/balance/ledger.json
git commit -m "feat(ledger): pilot-authored ledger_loop gate script + measured cadence"
```

---

### Task 9: Vision checks 26 → 30 + the full wall

**Files:**
- Modify: `harness/gate_checks.json` (APPEND 4 — existing 26 untouched)
- Modify: `CLAUDE.md` (Commands bullet: add `ledger_loop.json = fight-ledger beats`)

- [ ] **Step 1: Append the checks (pass-true hatches — the checks file is SHARED across all 7 scripts)**

```json
    {
      "id": "ledger_beat_reads",
      "check": "After combat ends, a short glyph+number tally may appear top-center (small filled magenta square + a +N number; optionally loss and net lines under it) and later disappears. It must read as a compact readout, never occlude the HUD bars (top-left) or the fight, and gains (magenta) must read distinct from losses (a hollow outline glyph with -N, or a dark red-edged square with -N). If no tally appears in these frames, pass with why='not exercised by this script'."
    },
    {
      "id": "ledger_negative_reads",
      "check": "When a tally shows a loss line (hollow magenta outline glyph + -N, meaning a pile waits on a corpse; or a dark red-edged square + -N, meaning destroyed) its net line ('= -N') reads clearly NEGATIVE (red family), visually distinct from an all-positive tally. If no tally with a loss line appears, pass with why='not exercised by this script'."
    },
    {
      "id": "wipe_recap_reads",
      "check": "During the wipe veil (dark overlay + the large wipe line), the tally renders OVER the veil and stays legible - its numbers readable against the darkened field. The hollow-outline loss number is the value waiting on corpses out in the world. If no wipe with a live tally appears, pass with why='not exercised by this script'."
    },
    {
      "id": "bank_tally_reads",
      "check": "When the pack banks at the station, a tally may appear top-center reading as a trip reconciliation: a +N take, optionally a hollow-outline -N (value still out on corpses) and a net line. It must be distinguishable from mid-fight tallies by context (station present, no combat). If no banking tally appears, pass with why='not exercised by this script'."
    }
```

- [ ] **Step 2: CLAUDE.md Commands bullet** — extend the capture list: `ledger_loop.json = fight-ledger beats`.

- [ ] **Step 3: Run the FULL wall (blocking)**

```bash
set -o pipefail
export PATH="/c/Ruby34-x64/bin:$PATH"
rake && rake perf && \
for s in world_loop district_hunt loot_loop specials_chain taunt_anchor corpse_run ledger_loop; do
  rake gate SCRIPT=harness/scripts/$s.json || exit 1
done
```
Expected: everything green. Critic discipline: pixel-verify any FAIL before believing it; retry INFRA (malformed-JSON) errors.

- [ ] **Step 4: Commit**

```bash
git add harness/gate_checks.json CLAUDE.md
git commit -m "feat(ledger): 4 appended vision checks (26->30) + command doc"
```

---

### Task 10: Merge readiness

- [ ] **Step 1:** Adversarial implementation review (code-reviewer agent over `git diff main`, seeded with: subscriber-order fragility, the beat-record two-nets convention, leg accounting edge cases, force-resolve reentrancy, renderer alpha math). Fold or record every finding; re-run `rake` + the full wall after any fold.
- [ ] **Step 2:** `git checkout main && git merge --no-ff fight-ledger` — NO push.
- [ ] **Step 3:** Checkpoint delta in `docs/CHECKPOINT.md` with MEASURED numbers (`git rev-list --count HEAD`, test/assert counts from `rake`, perf p95, beats/min from Task 8, gate tally) + fun-verify handoff.
