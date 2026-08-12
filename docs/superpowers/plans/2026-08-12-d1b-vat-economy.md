# D1b Vat Economy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Banked value buys persistence (inscribe a body → it survives the
wipe) and readiness (tribute → heal + regrow), plus the Q6 legibility rider
and the dodge/deepest_band bug bundle.

**Architecture:** Two new station verbs dispatch from the existing
`World#interact` tail; the god-mark is creature-owned swap-inert state;
`respawn_pack` becomes the judgment (marked revive + burn, unmarked stay
dead, one-vessel floor); all prices/timers in `data/balance/economy.json`.

**Tech Stack:** Ruby 3.4.10 + Gosu 1.4.6, minitest, the repo's replay+critic
harness. Spec: `docs/superpowers/specs/2026-08-12-d1b-vat-economy-design.md`
(REVIEWED). Code facts: `drafts/_d1b-exploration-brief.md`.

## Global Constraints

- Every shell: `export PATH="/c/Ruby34-x64/bin:$PATH"` first.
- Branch: `d1b-vat` (create in Task 1). Merge `--no-ff` at the end. **NO
  git push ever** — the remote is the owner's to push.
- Zero balance constants in Ruby — every tunable lands in `data/**/*.json`.
  (Presentation colors are renderer constants by existing convention;
  timers/alphas go to display.json.)
- Events: add new symbols to `World::EVENTS` (world.rb:20-26) in the task
  that first emits them — emit/subscribe on unknown symbols raises.
- Tests: minitest, real `World` + real data files, NO mocks. Run a single
  file with `bundle exec ruby test/game/<file>.rb`; the pre-commit hook
  runs the full `bundle exec rake` (~13s) on every commit.
- D1 corpse/pile paths are UNTOUCHED law: piles, grace, terms, loot flow
  stay byte-identical. The judgment clears only UNLOADED pack corpse
  records (`container_id` records are pile markers — never delete).
- The existing interact guards (world.rb:265-266) and pickup-first
  two-press order are preserved verbatim; bank behavior byte-identical.
- All economy values are HYPOTHESES — Task 12 re-anchors them from
  measured EVENT-log banked amounts before the wall closes.
- Owner-locked design (PARKING_LOT §"v10 debate + design OUTCOMES") is not
  re-litigable in-flight: regrow-for-price + one-vessel floor, marks
  consumed by the judgment they survive, all-or-nothing tribute, three
  fixtures, station-only banked display.

---

### Task 1: Economy data file + World loads it

**Files:**
- Create: `data/balance/economy.json`
- Create: `test/game/economy_data_test.rb`
- Modify: `src/game/world.rb:34-40` (initialize reads the new key)

**Interfaces:**
- Produces: `data/balance/economy.json` with keys `inscribe_cost`,
  `regrow_cost`, `heal_cost_per_body`, `retarget_cue_frames`; `World`
  ivar `@economy` (all later tasks read `@economy[:key]`).

- [ ] **Step 0: Branch**

```bash
export PATH="/c/Ruby34-x64/bin:$PATH"
git checkout -b d1b-vat
```

- [ ] **Step 1: Write the failing test**

`test/game/economy_data_test.rb` (mirrors `threat_data_test.rb` — laws,
not exact values):

```ruby
require_relative "../test_helper"
require "core/data_store"

# Economy data laws (spec §Data): prices positive, devotion cheaper than
# desperation. Values are hypotheses; these assertions pin the LAWS only.
class EconomyDataTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]

  def test_all_costs_positive
    assert ECO[:inscribe_cost].positive?
    assert ECO[:regrow_cost].positive?
    assert ECO[:heal_cost_per_body].positive?
    assert ECO[:retarget_cue_frames].positive?
  end

  def test_devotion_cheaper_than_desperation
    assert ECO[:inscribe_cost] < ECO[:regrow_cost],
           "inscribe_cost must be < regrow_cost (fiction law, spec §3)"
  end
end
```

- [ ] **Step 2: Run it — expect FAIL**

Run: `bundle exec ruby test/game/economy_data_test.rb`
Expected: `MissingKey: no data loaded for "balance/economy"`

- [ ] **Step 3: Create the data file**

`data/balance/economy.json`:

```json
{
  "inscribe_cost": 8,
  "regrow_cost": 12,
  "heal_cost_per_body": 2,
  "retarget_cue_frames": 45
}
```

- [ ] **Step 4: Load it in World#initialize**

In `src/game/world.rb`, after `@threat = data["balance/threat"]` (line 39):

```ruby
      @economy = data["balance/economy"]
```

- [ ] **Step 5: Run the test — expect PASS, then full suite**

Run: `bundle exec ruby test/game/economy_data_test.rb` → PASS
Run: `bundle exec rake` → 0 failures

- [ ] **Step 6: Commit**

```bash
git add data/balance/economy.json test/game/economy_data_test.rb src/game/world.rb
git commit -m "feat(d1b): economy balance file + world load"
```

---

### Task 2: Pack#spend! and Pack#possess!

**Files:**
- Modify: `src/game/pack.rb`
- Test: `test/game/pack_test.rb` (append)

**Interfaces:**
- Consumes: nothing new.
- Produces: `Pack#spend!(amount) -> true/false` (false = insufficient, NO
  mutation); `Pack#possess!(member) -> member` (plain pointer move, no
  stagger — judgment-time possession snap; Task 6 uses it).

- [ ] **Step 1: Write the failing tests** (append inside `PackTest`)

```ruby
  def test_spend_subtracts_when_affordable
    pack.bank!(10)
    assert pack.spend!(7)
    assert_equal 3, pack.banked
  end

  def test_spend_refuses_without_mutation_when_insufficient
    pack.bank!(5)
    refute pack.spend!(6)
    assert_equal 5, pack.banked, "refusal must not mutate"
  end

  def test_possess_moves_pointer_without_stagger
    target = pack.members[2]
    assert_equal target, pack.possess!(target)
    assert_equal target, pack.possessed
    refute target.staggered?, "judgment snap is not a combat swap"
  end
```

- [ ] **Step 2: Run — expect FAIL** (`NoMethodError: spend!`)

Run: `bundle exec ruby test/game/pack_test.rb`

- [ ] **Step 3: Implement** (in `src/game/pack.rb`, after `bank!`)

```ruby
    # D1b sinks: the ONLY paths that reduce banked, all player-initiated at
    # stations (the never-taxed law holds — no system call sites exist).
    def spend!(amount)
      return false if amount > @banked
      @banked -= amount
      true
    end

    # Judgment-time pointer move (post-wipe possession snap): plain, no
    # stagger — revival is not a combat beat. Combat swaps keep using
    # swap_next!/forced_swap!.
    def possess!(target)
      @possessed = target
    end
```

- [ ] **Step 4: Run — expect PASS, then `bundle exec rake`**

- [ ] **Step 5: Commit**

```bash
git add src/game/pack.rb test/game/pack_test.rb
git commit -m "feat(d1b): Pack#spend! (refusal-safe) + Pack#possess!"
```

---

### Task 3: God-mark on Creature (survives revive!, burns explicitly)

**Files:**
- Modify: `src/game/creature.rb` (near carried, ~line 220; and `revive!`)
- Test: `test/game/creature_test.rb` (append)

**Interfaces:**
- Consumes: nothing new.
- Produces: `Creature#marked? -> bool`, `Creature#inscribe_mark!`,
  `Creature#burn_mark!`. Law: the mark is body-owned (swap-inert like
  carried/taunt, law 4) and `revive!` must NOT clear it — only
  `burn_mark!` does (Task 6 burns it at the judgment; vat regrowth in
  Task 5 preserves it).

- [ ] **Step 1: Write the failing tests** (append to `CreatureTest`,
  using that file's existing creature-construction helper — read its
  header and reuse the same `Game::Creature.new(...)` builder it defines)

```ruby
  def test_god_mark_lifecycle
    c = creature
    refute c.marked?
    c.inscribe_mark!
    assert c.marked?
    c.burn_mark!
    refute c.marked?
  end

  def test_god_mark_survives_revive
    c = creature
    c.inscribe_mark!
    c.take_hit(damage: c.hp, attacker: creature) until c.dead?
    c.revive!(map: c.walker.map, tile: [1, 1])
    assert c.marked?, "revive! must NOT clear the mark — only burn_mark! does"
  end
```

(If the helper in `creature_test.rb` is named differently, use its exact
name; if `walker.map` is not exposed, construct with the test's own MAP
constant: `c.revive!(map: MAP, tile: [1, 1])`.)

- [ ] **Step 2: Run — expect FAIL** (`NoMethodError: marked?`)

Run: `bundle exec ruby test/game/creature_test.rb`

- [ ] **Step 3: Implement** (in `src/game/creature.rb`, beside carried
  ~line 220; do NOT touch `revive!` — the mark simply isn't in its reset
  list, and the test pins that)

```ruby
    # D1b god-mark: body-owned and swap-inert (law 4) — it rides the BODY
    # like carried and taunt, never the possession pointer. Burned ONLY by
    # the judgment (World#respawn_pack); revive!/vat-regrowth preserve it.
    def marked? = !!@god_mark

    def inscribe_mark!
      @god_mark = true
    end

    def burn_mark!
      @god_mark = false
    end
```

- [ ] **Step 4: Run — expect PASS, then `bundle exec rake`**

- [ ] **Step 5: Commit**

```bash
git add src/game/creature.rb test/game/creature_test.rb
git commit -m "feat(d1b): creature god-mark, revive-proof, burn-explicit"
```

---

### Task 4: Nest fixtures + interact dispatch + the altar verb

**Files:**
- Modify: `data/zones/nest.json` (two stations + per-type palette)
- Modify: `src/game/world.rb` (EVENTS list; interact tail → dispatch;
  new private verbs; station cue state)
- Create: `test/game/economy_altar_test.rb`

**Interfaces:**
- Consumes: `@economy` (Task 1), `Pack#spend!` (Task 2),
  `Creature#marked?/inscribe_mark!` (Task 3).
- Produces: stations `"altar"` + `"vat"` in nest.json (vat verb body lands
  in Task 5 — this task stubs it as `false`); events `:inscribed`,
  `:banked_spent`; `World#station_cue -> {kind:, frames_left:} | nil`
  (renderer reads it in Task 7; kinds: `:inscribed`, `:tribute`,
  `:refused`); private `spend_banked(source, amount, sink)`.

- [ ] **Step 1: Write the failing tests**

`test/game/economy_altar_test.rb`:

```ruby
require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Altar verb through the REAL World + data (no mocks). The possessed banks
# by standing on a station and interacting; tests stage tiles directly.
class EconomyAltarTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]

  def world = @world ||= Game::World.new(DATA)

  def altar_tile
    world.map.stations.find { |s| s[:type] == "altar" }[:at]
  end

  def at_altar!
    world.possessed.walker.teleport(*altar_tile)
    world.possessed
  end

  def test_nest_declares_three_distinct_fixtures
    types = world.map.stations.map { |s| s[:type] }.sort
    assert_equal %w[altar bank vat], types
    tiles = world.map.stations.map { |s| s[:at] }
    assert_equal tiles.uniq.length, tiles.length
  end

  def test_inscribe_spends_and_marks
    world.pack.bank!(ECO[:inscribe_cost] + 3)
    src = at_altar!
    events = []
    world.bus.subscribe(:inscribed) { |e| events << e }
    assert world.interact(src)
    assert src.marked?
    assert_equal 3, world.pack.banked
    assert_equal 1, events.length
  end

  def test_inscribe_refuses_when_broke_without_mutation
    world.pack.bank!(ECO[:inscribe_cost] - 1)
    src = at_altar!
    refute world.interact(src)
    refute src.marked?
    assert_equal ECO[:inscribe_cost] - 1, world.pack.banked
    assert_equal :refused, world.station_cue[:kind]
  end

  def test_inscribe_refuses_double_mark_without_spending
    world.pack.bank!(ECO[:inscribe_cost] * 3)
    src = at_altar!
    assert world.interact(src)
    refute world.interact(src), "already marked"
    assert_equal ECO[:inscribe_cost] * 2, world.pack.banked
  end

  def test_banked_spent_event_carries_sink_and_balance
    world.pack.bank!(ECO[:inscribe_cost])
    spent = []
    world.bus.subscribe(:banked_spent) { |e| spent << e }
    world.interact(at_altar!)
    assert_equal 1, spent.length
    assert_equal :inscribe, spent.first[:sink]
    assert_equal 0, spent.first[:banked]
  end

  def test_bank_station_behavior_unchanged
    # Byte-compat pin: carried banks exactly as before at the bank fixture.
    bank_tile = world.map.stations.find { |s| s[:type] == "bank" }[:at]
    src = world.possessed
    src.walker.teleport(*bank_tile)
    src.pick_up(5)
    assert world.interact(src)
    assert_equal 5, world.pack.banked
    assert_equal 0, src.carried
  end
end
```

- [ ] **Step 2: Run — expect FAIL** (no altar station yet)

Run: `bundle exec ruby test/game/economy_altar_test.rb`

- [ ] **Step 3: Data — nest.json fixtures + per-type palette**

In `data/zones/nest.json`: replace the `"palette"` and `"stations"` blocks:

```json
  "palette": {
    "floor": [30, 22, 26],
    "grid": [40, 30, 34],
    "wall": [150, 96, 84],
    "transition": [235, 190, 90],
    "station": [185, 75, 205],
    "station_altar": [230, 215, 170],
    "station_vat": [90, 150, 60]
  },
```

```json
  "stations": [
    { "type": "bank", "at": [12, 8] },
    { "type": "altar", "at": [16, 8] },
    { "type": "vat", "at": [14, 10] }
  ],
```

(Both tiles are `.` floor on rows 8/10; bank west, altar east, vat south of
the spawn row — three compass-distinct fixtures. Positions are data
hypotheses; the `fixtures_distinct_read` gate check arbitrates.)

- [ ] **Step 4: World — events, dispatch, altar verb, cue state**

In `src/game/world.rb` EVENTS (line 20-26) append a line inside the `%i[]`:

```ruby
      inscribed banked_spent tribute_paid body_regrown body_dissolved mark_consumed vessel_kept
```

In `initialize` (near `@banner_timer = 0`): `@station_cue = nil`.

Add public reader alongside the other view readers (near line 77):

```ruby
    def station_cue = @station_cue
```

Replace the station tail of `interact` (world.rb:287-292):

```ruby
      station = map.station_at(*source.tile)
      return false unless station
      case station[:type]
      when "bank"  then interact_bank(source)
      when "altar" then interact_altar(source)
      when "vat"   then interact_vat(source)
      else false
      end
    end
```

Add the private verbs (near `respawn_pack`):

```ruby
    # --- D1b station verbs (the only banked sinks; spec §2-3) -----------

    def interact_bank(source)
      return false unless source.carried.positive?
      amount = source.drain_carried!
      @pack.bank!(amount)
      @bus.emit(:banked, actor: source, amount:, banked: @pack.banked)
      true
    end

    def interact_altar(source)
      return station_refuse! if source.marked?
      return station_refuse! unless spend_banked(source, @economy[:inscribe_cost], :inscribe)
      source.inscribe_mark!
      @bus.emit(:inscribed, body: source, cost: @economy[:inscribe_cost], banked: @pack.banked)
      station_cue!(:inscribed)
      true
    end

    def interact_vat(_source)
      false # Task 5
    end

    def spend_banked(source, amount, sink)
      return false unless @pack.spend!(amount)
      @bus.emit(:banked_spent, actor: source, amount:, sink:, banked: @pack.banked)
      true
    end

    def station_cue!(kind)
      @station_cue = { kind:, frames_left: @display[:station_cue_frames] }
      true
    end

    def station_refuse!
      station_cue!(:refused)
      false
    end
```

In `tick_world`, beside the banner timer decrement, add:

```ruby
      @station_cue = nil if @station_cue && (@station_cue[:frames_left] -= 1) <= 0
```

In `data/display.json` add: `"station_cue_frames": 30,`

(`interact_bank` is the EXACT code lifted from the old tail — the
`test_bank_station_behavior_unchanged` pin proves the move.)

- [ ] **Step 5: Run — expect PASS, then `bundle exec rake`**

- [ ] **Step 6: Commit**

```bash
git add data/zones/nest.json data/display.json src/game/world.rb test/game/economy_altar_test.rb
git commit -m "feat(d1b): three nest fixtures, interact dispatch, altar inscribe verb"
```

---

### Task 5: The vat tribute verb (all-or-nothing full maintenance)

**Files:**
- Modify: `src/game/world.rb` (replace the `interact_vat` stub)
- Modify: `src/game/creature.rb` (add `heal_full!`)
- Create: `test/game/economy_vat_test.rb`

**Interfaces:**
- Consumes: `spend_banked`/`station_refuse!`/`station_cue!` (Task 4),
  `Creature#marked?` (Task 3), `Creature#revive!` (existing).
- Produces: working tribute; `Creature#heal_full!` (hp → max, nothing
  else); events `:tribute_paid (cost:, regrown:, healed:, banked:)`,
  `:body_regrown (body:)`.

- [ ] **Step 1: Write the failing tests**

`test/game/economy_vat_test.rb`:

```ruby
require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

class EconomyVatTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]

  def world = @world ||= Game::World.new(DATA)

  def vat_tile = world.map.stations.find { |s| s[:type] == "vat" }[:at]

  def at_vat!
    world.possessed.walker.teleport(*vat_tile)
    world.possessed
  end

  def kill(creature)
    creature.take_hit(damage: creature.hp, attacker: world.possessed) until creature.dead?
  end

  def test_tribute_heals_wounded_and_regrows_dead_all_or_nothing
    ally = (world.pack.members - [world.possessed]).first
    other = (world.pack.members - [world.possessed, ally]).first
    kill(ally)                                     # 1 dead
    other.take_hit(damage: 10, attacker: ally)     # 1 wounded
    cost = ECO[:regrow_cost] + ECO[:heal_cost_per_body]
    world.pack.bank!(cost)
    regrown = []
    world.bus.subscribe(:body_regrown) { |e| regrown << e[:body] }
    assert world.interact(at_vat!)
    refute ally.dead?
    assert_equal ally.max_hp, ally.hp
    assert_equal other.max_hp, other.hp
    assert_equal 0, world.pack.banked
    assert_equal [ally], regrown
    home = Game::World::HOME_ZONE
    assert_equal world.map.pack_spawn[world.pack.members.index(ally)], ally.tile if world.zone_name == home
  end

  def test_tribute_refuses_when_short_without_any_mutation
    ally = (world.pack.members - [world.possessed]).first
    kill(ally)
    world.pack.bank!(ECO[:regrow_cost] - 1)
    refute world.interact(at_vat!)
    assert ally.dead?
    assert_equal ECO[:regrow_cost] - 1, world.pack.banked
    assert_equal :refused, world.station_cue[:kind]
  end

  def test_tribute_refuses_when_nothing_to_buy
    world.pack.bank!(50)
    refute world.interact(at_vat!), "full-HP full pack: cost zero = refusal"
    assert_equal 50, world.pack.banked
  end

  def test_regrowth_preserves_the_god_mark
    ally = (world.pack.members - [world.possessed]).first
    ally.inscribe_mark!
    kill(ally)
    world.pack.bank!(ECO[:regrow_cost])
    assert world.interact(at_vat!)
    assert ally.marked?, "vat regrowth preserves the mark (burn is judgment-only)"
  end

  def test_tribute_paid_event_shape
    ally = (world.pack.members - [world.possessed]).first
    kill(ally)
    world.pack.bank!(ECO[:regrow_cost])
    paid = []
    world.bus.subscribe(:tribute_paid) { |e| paid << e }
    world.interact(at_vat!)
    assert_equal [{ cost: ECO[:regrow_cost], regrown: 1, healed: 0, banked: 0 }],
                 paid.map { |e| e.slice(:cost, :regrown, :healed, :banked) }
  end
end
```

- [ ] **Step 2: Run — expect FAIL** (vat stub returns false)

Run: `bundle exec ruby test/game/economy_vat_test.rb`

- [ ] **Step 3: Implement**

`src/game/creature.rb`, beside `revive!`:

```ruby
    # Tribute heal (D1b): flesh only — clocks, exhaust, iframes, carried all
    # untouched (revive! is the full reset; this is not it).
    def heal_full!
      @hp = @max_hp
    end
```

`src/game/world.rb`, replace the stub:

```ruby
    # All-or-nothing full maintenance (spec §3): one price, one decision.
    # Regrowth is a hard rebind onto the home spawn tile (occupancy is soft:
    # only voluntary movement is blocked — same as respawn_pack).
    def interact_vat(source)
      dead = @pack.members.select(&:dead?)
      wounded = @pack.living.select { |m| m.hp < m.max_hp }
      cost = @economy[:regrow_cost] * dead.length +
             @economy[:heal_cost_per_body] * wounded.length
      return station_refuse! if cost.zero?
      return station_refuse! unless spend_banked(source, cost, :tribute)
      home = @zones.fetch(HOME_ZONE)
      dead.each do |m|
        m.revive!(map: home, tile: home.pack_spawn[@pack.members.index(m)])
        @bus.emit(:body_regrown, body: m)
      end
      wounded.each(&:heal_full!)
      @bus.emit(:tribute_paid, cost:, regrown: dead.length,
                healed: wounded.length, banked: @pack.banked)
      station_cue!(:tribute)
      true
    end
```

- [ ] **Step 4: Run — expect PASS, then `bundle exec rake`**

- [ ] **Step 5: Commit**

```bash
git add src/game/world.rb src/game/creature.rb test/game/economy_vat_test.rb
git commit -m "feat(d1b): vat tribute — all-or-nothing heal + regrow, mark-preserving"
```

---

### Task 6: The judgment — respawn_pack rewrite + floor + possession snap

**Files:**
- Modify: `src/game/world.rb:712-721` (`respawn_pack`) + two new privates
- Create: `test/game/economy_judgment_test.rb`

**Interfaces:**
- Consumes: `marked?/burn_mark!` (Task 3), `Pack#possess!` (Task 2).
- Produces: judgment semantics; events `:mark_consumed (body:)`,
  `:body_dissolved (body:)`, `:vessel_kept (body:)`; unloaded pack corpse
  records cleared at judgment.

- [ ] **Step 1: Write the failing tests**

`test/game/economy_judgment_test.rb`:

```ruby
require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# The wipe becomes the judgment (spec §4): marked revive + burn, unmarked
# stay dead, one-vessel floor. Driven through the REAL wipe path: kill all
# three, tick through the respawn timer.
class EconomyJudgmentTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  RESPAWN = DATA["balance/combat"][:respawn_frames]

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(n)
    input = scripted({})
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def wipe!
    killer = world.humans.first || world.possessed
    world.pack.members.each do |m|
      m.take_hit(damage: m.hp, attacker: killer) until m.dead?
    end
    drive(RESPAWN + 2)
  end

  def test_marked_survive_and_burn_unmarked_dissolve
    marked = world.possessed
    marked.inscribe_mark!
    consumed = []
    dissolved = []
    world.bus.subscribe(:mark_consumed) { |e| consumed << e[:body] }
    world.bus.subscribe(:body_dissolved) { |e| dissolved << e[:body] }
    wipe!
    refute marked.dead?
    refute marked.marked?, "the judgment consumes the mark"
    assert_equal [marked], consumed
    others = world.pack.members - [marked]
    assert others.all?(&:dead?), "unmarked stay dead (dissolved) until regrown"
    assert_equal others.sort_by { |m| world.pack.members.index(m) },
                 dissolved.sort_by { |m| world.pack.members.index(m) }
    assert_equal marked, world.pack.possessed
  end

  def test_floor_keeps_the_possessed_vessel_when_nothing_marked
    vessel = world.pack.possessed
    kept = []
    world.bus.subscribe(:vessel_kept) { |e| kept << e[:body] }
    wipe!
    assert_equal [vessel], kept
    refute vessel.dead?
    assert_equal vessel, world.pack.possessed
    assert_equal 2, world.pack.members.count(&:dead?)
  end

  def test_possession_snaps_when_the_possessed_dissolved
    marked = (world.pack.members - [world.possessed]).first
    marked.inscribe_mark!
    wipe!
    assert_equal marked, world.pack.possessed,
                 "possession snaps to the revived member"
    refute marked.staggered?, "judgment snap pays no stagger"
  end

  def test_banked_survives_the_judgment_untaxed
    world.pack.bank!(9)
    wipe!
    assert_equal 9, world.pack.banked
  end

  def test_judgment_clears_unloaded_pack_corpse_records_only
    # Stage: one unloaded pack corpse record + wipe. Loaded containers are
    # D1 pile markers and MUST survive (grace law).
    wipe!
    world.corpses.each do |c|
      assert c[:faction] != :pack || c[:container_id],
             "unloaded pack husks must be gone after the judgment"
    end
  end
end
```

- [ ] **Step 2: Run — expect FAIL** (today all three revive)

Run: `bundle exec ruby test/game/economy_judgment_test.rb`

- [ ] **Step 3: Implement** — replace `respawn_pack` (world.rb:712-721):

```ruby
    # The judgment (D1b, spec §4): marked flesh revives and the mark burns;
    # unmarked dissolves (stays dead-and-regrowable — dissolution IS the
    # absence of revival). Floor: a judgment that would leave nothing
    # returns the body possessed at the wipe — the gods keep you alive to
    # pay. Taunt-release sweep and HOME_ZONE re-entry unchanged (impl
    # review 1 law).
    def respawn_pack
      @humans.each_value { |list| list.each(&:release_taunt!) }
      @zone_name = HOME_ZONE
      vessel = @pack.possessed
      revived = []
      @pack.members.each_with_index do |m, i|
        if m.marked?
          m.revive!(map:, tile: map.pack_spawn[i])
          m.burn_mark!
          @bus.emit(:mark_consumed, body: m)
          revived << m
        else
          @bus.emit(:body_dissolved, body: m)
        end
      end
      if revived.empty?
        vessel.revive!(map:, tile: map.pack_spawn[@pack.members.index(vessel)])
        @bus.emit(:vessel_kept, body: vessel)
        revived << vessel
      end
      clear_unloaded_pack_husks
      snap_possession_after_judgment(revived)
      enter_zone(HOME_ZONE, map.pack_spawn)
      @bus.emit(:pack_respawned)
    end

    # Dissolved flesh leaves no field husk (spec §Presentation-5). Loaded
    # records are D1 pile markers under wipe grace — never touched.
    def clear_unloaded_pack_husks
      @corpses.each_value do |list|
        list.reject! { |c| c[:faction] == :pack && !c[:container_id] }
      end
    end

    def snap_possession_after_judgment(revived)
      return if revived.include?(@pack.possessed)
      from = @pack.possessed
      target = revived.min_by do |m|
        [tile_distance(m.tile, from.tile), @pack.members.index(m)]
      end
      @pack.possess!(target)
      @bus.emit(:possession_changed, from:, to: target, forced: true)
    end
```

(NB `enter_zone` places `[possessed] + living` — after the snap the
possessed is always living, so placement is well-formed; dissolved members
are dead and not placed, which is correct.)

- [ ] **Step 4: Run — expect PASS, then `bundle exec rake`**

The A2 regression oracle: `test/game/taunt_test.rb` and
`test/game/corpse_run_test.rb` must stay green UNTOUCHED. If
`corpse_run_test.rb` asserts three living bodies post-wipe, that test
legitimately changes meaning under v10 — REWRITE the specific assertion to
stage a marked pack (inscribe all three before the staged wipe), preserving
what it actually pins (the corpse-run flow). Do not weaken any other
assertion; record the rewrite in the commit message.

- [ ] **Step 5: Commit**

```bash
git add src/game/world.rb test/game/economy_judgment_test.rb test/game/corpse_run_test.rb
git commit -m "feat(d1b): the judgment — marked survive+burn, unmarked dissolve, one-vessel floor"
```

---

### Task 7: Presentation — glyph, fixture colors, cost readouts, cues

**Files:**
- Modify: `src/app/renderer.rb` (`draw_stations`, `draw_station_ledger`,
  `draw_creature`; new constants + `draw_station_cue`)
- Modify: `data/display.json` (already carries `station_cue_frames`)

**Interfaces:**
- Consumes: `station_cue` (Task 4), `marked?` (Task 3), station types
  (Task 4), `@economy` costs via a small World helper produced here:
  `World#station_price(station) -> Integer` (renderer never computes
  economy math itself).

No unit test (Gosu draw path — this repo verifies presentation at the
gate, Task 11/12). The task still ends with `bundle exec rake` green.

- [ ] **Step 1: World price helper** (public, beside `station_cue`):

```ruby
    # Renderer-facing price reader (renderer computes nothing): what THIS
    # station charges right now. Bank has no price (nil).
    def station_price(station)
      case station[:type]
      when "altar" then @economy[:inscribe_cost]
      when "vat"
        @economy[:regrow_cost] * @pack.members.count(&:dead?) +
          @economy[:heal_cost_per_body] * @pack.living.count { |m| m.hp < m.max_hp }
      end
    end
```

- [ ] **Step 2: Renderer — per-type fixture colors** (`draw_stations`,
  renderer.rb:205-215): resolve the fill from the palette by type:

```ruby
    def draw_stations(world)
      ts = world.map.tile_size
      world.map.stations.each do |s|
        tx, ty = s[:at]
        x = tx * ts
        y = ty * ts
        key = s[:type] == "bank" ? :station : :"station_#{s[:type]}"
        fill = world.map.palette[key] || world.map.palette[:station] || world.map.palette[:wall]
        Gosu.draw_rect(x + 2, y + 2, ts - 4, ts - 4, color(fill))
        Gosu.draw_rect(x + 8, y + 8, ts - 16, ts - 16, color(world.map.palette[:floor]))
      end
    end
```

- [ ] **Step 3: Renderer — cost readout + cue** (extend
  `draw_station_ledger`, renderer.rb:224-234): keep the banked numeral on
  the bank fixture exactly as-is; for altar/vat within
  `LEDGER_RADIUS_TILES`, draw the price the same way (numeral above the
  fixture) prefixed with `-`; when `world.station_cue` is live, flash the
  fixture nearest the possessed (success kinds draw a bright 1-tile pulse
  ring at the station tile; `:refused` draws a short dark-red X-bar).
  Colors are renderer constants:

```ruby
    CUE_OK = Gosu::Color.new(230, 240, 220, 150)
    CUE_REFUSED = Gosu::Color.new(230, 200, 60, 50)
    GOD_MARK = Gosu::Color.new(230, 235, 220, 170)
```

- [ ] **Step 4: Renderer — the god-mark glyph** (in `draw_creature`,
  after the possessed-ring block at renderer.rb:257-259, so it draws in
  BOTH the possessed and ally-dim paths):

```ruby
      if c.faction == :pack && c.marked?
        Gosu.draw_rect(x + SIZE / 2 - 4, y - 10, 8, 8, GOD_MARK)
        Gosu.draw_rect(x + SIZE / 2 - 2, y - 8, 4, 4, color(world.map.palette[:floor]))
      end
```

(A hollow pale-gold square floating above the body — distinct from the
possession ring [full-body outline], the magenta pip [tile-centered], and
the teal mark reticle [on humans]. The `god_mark_reads` check arbitrates.)

- [ ] **Step 5: Run `bundle exec rake` (green), launch `bin/play` for a
  10-second smoke (fixtures visible in the nest), commit**

```bash
git add src/app/renderer.rb src/game/world.rb
git commit -m "feat(d1b): fixture colors, price readouts, station cues, god-mark glyph"
```

---

### Task 8: Q6 rider — retarget cue + threshold retunes

**Files:**
- Modify: `src/game/creature.rb` (cue state + tick decrement)
- Modify: `src/game/world.rb:332-341` (`assign_human_focus` stamps the cue)
- Modify: `src/app/renderer.rb` (`draw_creature`: cue glyph)
- Modify: `data/balance/threat.json` (retunes)
- Test: `test/game/threat_targeting_test.rb` (append)

**Interfaces:**
- Consumes: `@economy[:retarget_cue_frames]` (Task 1).
- Produces: `Creature#retarget_cue!(cause, frames)`,
  `Creature#retarget_cue -> {cause:, frames_left:} | nil` (pure reader,
  taunted_target law), ticked down in the creature's own tick.

- [ ] **Step 1: Write the failing tests** (append to
  `threat_targeting_test.rb` — it already has `setup` entering the
  district, `drive(world, n)`, `THREAT`, and real `world.humans`):

```ruby
  def test_retarget_stamps_cause_cue_and_acquired_does_not
    h = @world.humans.reject(&:dead?).find { |x| x.kit_name == :rusher }
    # Park the pack inside h's aggro, deep in the district (away from the
    # beachhead). First acquisition = nearest = living.first (:acquired).
    @world.pack.living.each_with_index do |m, i|
      m.walker.teleport(h.tile[0] - 2, h.tile[1] + i)
    end
    drive(@world, 1)
    assert_nil h.retarget_cue, "first sight is :acquired — no cue"
    # Wound a NON-focused body below the lowhp threshold -> :lowhp switch.
    wounded = @world.pack.living.last
    dmg = (wounded.max_hp * (1 - THREAT[:lowhp_switch_pct])).to_i + 1
    wounded.take_hit(damage: dmg, attacker: h)
    drive(@world, 1)
    refute_nil h.retarget_cue
    assert_equal :lowhp, h.retarget_cue[:cause]
    assert h.retarget_cue[:frames_left].positive?
  end

  def test_retarget_cue_expires_by_ticking
    h = @world.humans.reject(&:dead?).first
    h.retarget_cue!(:lowhp, 5)
    assert_equal :lowhp, h.retarget_cue[:cause]
    drive(@world, 6)
    assert_nil h.retarget_cue
  end
```

(If the staged human ends up dead or hater-diverted in the first test,
pick a different `world.humans` entry / bump the teleport tiles — the
assertion meanings are fixed; staging tiles are the adjustable part.)

- [ ] **Step 2: Run — expect FAIL** (`NoMethodError: retarget_cue`)

- [ ] **Step 3: Implement**

`src/game/creature.rb` (beside the taunt block, same pure-reader law):

```ruby
    # Q6 rider: why-they-turned cue. Sim-owned timer (renderer READS it,
    # never mutates — taunted_target law); stamped by assign_human_focus,
    # decays in this body's own tick.
    def retarget_cue!(cause, frames)
      @retarget_cue_cause = cause
      @retarget_cue_frames = frames
    end

    def retarget_cue
      return nil unless @retarget_cue_frames&.positive?
      { cause: @retarget_cue_cause, frames_left: @retarget_cue_frames }
    end
```

In the creature's per-tick clock block (where `@hurt_frames` decrements —
find `@hurt_frames -= 1` and mirror it):

```ruby
      @retarget_cue_frames -= 1 if @retarget_cue_frames&.positive?
```

`src/game/world.rb` `assign_human_focus` (332-341) — inside the existing
`if target && !target.equal?(h.focus)` branch, after the emit:

```ruby
          h.retarget_cue!(cause, @economy[:retarget_cue_frames]) unless cause == :acquired
```

`src/app/renderer.rb` `draw_creature` — after the taunt underline line
(260), cause-colored 6px block above the human:

```ruby
      if c.faction == :human && (cue = c.retarget_cue)
        Gosu.draw_rect(x + SIZE / 2 - 3, y - 9, 6, 6, RETARGET_CUE.fetch(cue[:cause]))
      end
```

```ruby
    RETARGET_CUE = {
      hate: Gosu::Color.new(230, 150, 60, 40),
      lowhp: Gosu::Color.new(230, 220, 60, 60),
      proximity: Gosu::Color.new(230, 200, 200, 190),
    }.freeze
```

`data/balance/threat.json` retunes (hypotheses, spec §5):
`"lowhp_switch_pct": 0.35` → `0.25`;
`"proximity_switch_margin_tiles": 3` → `4`.

- [ ] **Step 4: Run the file, then `bundle exec rake`** — some existing
targeting tests may pin the OLD threshold values through staged HP; fix
the STAGING (wound depths / distances) to the new data values, never the
assertion meaning.

- [ ] **Step 5: Commit**

```bash
git add src/game/creature.rb src/game/world.rb src/app/renderer.rb data/balance/threat.json test/game/threat_targeting_test.rb
git commit -m "feat(d1b): retarget why-cue + Q6 threshold retunes (0.25 lowhp / 4-tile margin)"
```

---

### Task 9: Bug fix — dodge goes edge-triggered

**Files:**
- Modify: `src/game/controllers.rb:24-37`
- Test: `test/core/input_test.rb` or a new
  `test/game/controller_dodge_test.rb` (below)

**Interfaces:** none new — behavior fix. Held dodge must never suppress
walking; at most one dodge per press.

- [ ] **Step 1: Write the failing test**

`test/game/controller_dodge_test.rb` — through the REAL World (only
verified APIs: `World#tick`, `ScriptedInput`, the WorldTest hold pattern):

```ruby
require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# The sixth fun-verify's banked bug becomes the regression pin: holding
# dodge used to starve the walk branch (controllers.rb:33-37 was
# level-triggered) — the body only moved during the periodic dashes.
class ControllerDodgeTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def hold(actions, from, to)
    (from..to).to_h { |f| [f.to_s, actions.map(&:to_s)] }
  end

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def test_held_dodge_never_suppresses_walking
    world = Game::World.new(DATA)
    dodges = 0
    world.bus.subscribe(:dodged) { dodges += 1 }
    start_x = world.possessed.tile[0]
    input = Core::ScriptedInput.new(frames: hold(%i[dodge right], 0, 119))
    drive(world, input, 120)
    assert_equal 1, dodges, "one dodge per press — holding must not re-dash"
    dodge_tiles = world.possessed.kit[:dodge][:tiles]
    assert world.possessed.tile[0] - start_x > dodge_tiles,
           "the body kept WALKING after the dash — held Shift must not lock movement"
  end

  def test_release_and_repress_dodges_again
    world = Game::World.new(DATA)
    cd = world.possessed.kit[:dodge][:cooldown_frames]
    dodges = 0
    world.bus.subscribe(:dodged) { dodges += 1 }
    frames = hold(%i[dodge right], 0, 1)
             .merge(hold(%i[right], 2, cd + 1))
             .merge(hold(%i[dodge right], cd + 2, cd + 3))
    input = Core::ScriptedInput.new(frames:)
    drive(world, input, cd + 4)
    assert_equal 2, dodges, "a fresh press after cooldown dodges again"
  end
end
```

(The pack spawns in the open nest row 8 facing a long clear corridor east
— 120 frames of walk+dash stays well short of the [29,8] transition. If
the possessed kit has no dodge config, possess one that does via
`world.pack.swap_next!` before driving.)

- [ ] **Step 2: Run — expect FAIL** (dodges > 1 and/or dx stuck at dash
  length)

- [ ] **Step 3: Implement** — `src/game/controllers.rb`: compute the edge
  with the OTHERS (before the dead? return), then branch on it:

Line 26-28 block gains:

```ruby
      dodge_pressed = pressed?(input, :dodge)
```

Line 33 changes from `if down?(input, :dodge)` to:

```ruby
      if dodge_pressed
```

(That is the whole fix. `pressed?` already maintains per-action edge
state and respects the swap mask — dodge was always in `EDGE_TRIGGERED`.)

- [ ] **Step 4: Run — expect PASS, then `bundle exec rake`**

- [ ] **Step 5: Commit**

```bash
git add src/game/controllers.rb test/game/controller_dodge_test.rb
git commit -m "fix(d1b): dodge is edge-triggered — held Shift no longer locks movement"
```

---

### Task 10: Bug fix — deepest_band converts at event time

**Files:**
- Modify: `src/game/telemetry.rb:19, 38-42, 63-71`
- Test: `test/game/telemetry_test.rb` (append)

**Interfaces:**
- Produces: `Telemetry` stores `@max_band` (Integer, 0 default); the
  summary-time `deepest_band` conversion is deleted.

- [ ] **Step 1: Write the failing test** (append to `TelemetryTest` —
  mirrors its existing `test_a2_deepest_band_from_drop_spawned` duck-typed
  world, extended so the current map can be SWAPPED after the drop; this
  is the owner's quit-from-nest artifact pinned as a regression):

```ruby
  def test_deepest_band_is_stamped_at_drop_time_not_summary_time
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    district = Struct.new(:drop_gradient).new([[0, 1.0], [14, 1.5], [28, 2.0]])
    nest = Struct.new(:drop_gradient).new(nil)
    maps = { current: district }
    world_obj = Object.new
    world_obj.define_singleton_method(:gate_distance) { |tile| tile[0] + tile[1] }
    world_obj.define_singleton_method(:map) { maps[:current] }
    t = Game::Telemetry.new(bus, world: world_obj)
    bus.emit(:drop_spawned, tile: [20, 10], amount: 1) # distance 30 -> band 2
    bus.process
    maps[:current] = nest # the owner quits from the nest (gradient nil)
    assert_match(/deepest_band=2/, t.a2_summary)
  end
```

(The existing `test_a2_deepest_band_from_drop_spawned` must stay green
unchanged — at-kill conversion returns the same bands when the map never
changes.)

- [ ] **Step 2: Run — expect FAIL** (band reads 0 from the nest)

- [ ] **Step 3: Implement** — in `telemetry.rb`:

Replace `@max_gate_distance = 0` (line 19) with `@max_band = 0`.
Replace the `:drop_spawned` subscription (38-42):

```ruby
      bus.subscribe(:drop_spawned) do |e|
        next unless @world
        bands = @world.map.drop_gradient
        next unless bands
        d = @world.gate_distance(e[:tile])
        next if d == Float::INFINITY
        idx = bands.rindex { |(min, _)| d >= min }
        @max_band = idx if idx && idx > @max_band
      end
```

Replace the private `deepest_band` method (65-71):

```ruby
    def deepest_band = @max_band
```

- [ ] **Step 4: Run — expect PASS, then `bundle exec rake`**

- [ ] **Step 5: Commit**

```bash
git add src/game/telemetry.rb test/game/telemetry_test.rb
git commit -m "fix(d1b): deepest_band converts at drop time — nest-quit artifact pinned"
```

---

### Task 11: FN-3 telemetry line (d1b_fired)

**Files:**
- Modify: `src/game/telemetry.rb`
- Test: `test/game/telemetry_test.rb` (append)

**Interfaces:**
- Produces: `Telemetry#d1b_summary` appended to `#summary`, shaped:
  `TELEMETRY d1b_fired inscriptions= marks_consumed= dissolved= regrown=
  tributes= floor_fired= banked_spent{inscribe= tribute=} banked_end=`

- [ ] **Step 1: Write the failing test** (append to `TelemetryTest`; also
  extend its `ALL_TELEMETRY_EVENTS` constant with the D1b symbols —
  `inscribed banked_spent mark_consumed body_dissolved body_regrown
  tribute_paid vessel_kept` — the same way it lists the A2 events):

```ruby
  def test_d1b_line_counts_economy_events
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    t = Game::Telemetry.new(bus)
    bus.emit(:inscribed, body: nil, cost: 8, banked: 1)
    bus.emit(:mark_consumed, body: nil)
    2.times { bus.emit(:body_dissolved, body: nil) }
    bus.emit(:body_regrown, body: nil)
    bus.emit(:tribute_paid, cost: 12, regrown: 1, healed: 0, banked: 4)
    bus.emit(:vessel_kept, body: nil)
    bus.emit(:banked_spent, actor: nil, amount: 8, sink: :inscribe, banked: 1)
    bus.emit(:banked_spent, actor: nil, amount: 12, sink: :tribute, banked: 4)
    bus.process
    line = t.d1b_summary
    assert_match(/inscriptions=1/, line)
    assert_match(/marks_consumed=1/, line)
    assert_match(/dissolved=2/, line)
    assert_match(/regrown=1/, line)
    assert_match(/tributes=1/, line)
    assert_match(/floor_fired=1/, line)
    assert_match(/banked_spent\{inscribe=8 tribute=12\}/, line)
    assert_match(/banked_end=4/, line)
  end
```

- [ ] **Step 2: Run — expect FAIL** (`NoMethodError: d1b_summary`)

- [ ] **Step 3: Implement** — in `telemetry.rb` initialize:

```ruby
      D1B_EVENTS = %i[inscribed mark_consumed body_dissolved body_regrown
                      tribute_paid vessel_kept].freeze
```

```ruby
      # D1b subscriptions (FN-3): the meaning oracle — a session that never
      # spent must be machine-distinguishable from one that spent and felt
      # nothing.
      @spent = Hash.new(0)
      @banked_end = 0
      D1B_EVENTS.each { |ev| bus.subscribe(ev) { @counts[ev] += 1 } }
      bus.subscribe(:banked_spent) do |e|
        @spent[e[:sink]] += e[:amount]
        @banked_end = e[:banked]
      end
      bus.subscribe(:banked) { |e| @banked_end = e[:banked] }
```

(NB the existing D1 `:banked` count subscription stays; this adds a second
subscriber for the balance — the bus supports N subscribers per event.)

Append to `summary` (after `a2_summary`) and add:

```ruby
    def d1b_summary
      "TELEMETRY d1b_fired inscriptions=#{@counts[:inscribed]} " \
        "marks_consumed=#{@counts[:mark_consumed]} " \
        "dissolved=#{@counts[:body_dissolved]} regrown=#{@counts[:body_regrown]} " \
        "tributes=#{@counts[:tribute_paid]} floor_fired=#{@counts[:vessel_kept]} " \
        "banked_spent{inscribe=#{@spent[:inscribe]} tribute=#{@spent[:tribute]}} " \
        "banked_end=#{@banked_end}"
    end
```

- [ ] **Step 4: Run — expect PASS, then `bundle exec rake`**

- [ ] **Step 5: Commit**

```bash
git add src/game/telemetry.rb test/game/telemetry_test.rb
git commit -m "feat(d1b): d1b_fired telemetry line — the seventh verify's meaning oracle"
```

---

### Task 12: Price re-anchor + vat_economy pilot script + gate checks

**Files:**
- Create: `harness/scripts/vat_economy.json` (pilot-exported)
- Modify: `harness/gate_checks.json` (34 → 39, ADD-ONLY)
- Possibly modify: `data/balance/economy.json` (re-anchored values)

- [ ] **Step 1: Measure banked units/session.** The harness prints EVENT
  lines to STDOUT during a capture run (`harness/scenes/world_scene.rb:25`
  — `puts "EVENT #{ev} frame=... #{describe(e)}"`). Run the two everyday
  replays and grep the stream:

```bash
bundle exec rake capture SCRIPT=harness/scripts/world_loop.json 2>&1 | grep -a "EVENT banked"
bundle exec rake capture SCRIPT=harness/scripts/district_hunt.json 2>&1 | grep -a "EVENT banked"
```

(If `describe(e)` omits the `amount:` field, extend `describe` in
world_scene.rb to include it — one line, presentation-free.) Sum the
banked amounts per script. If a
regression-loop session banks materially more than ~24 units (3× the
inscribe hypothesis), scale all three costs proportionally in
`economy.json` (keep `inscribe_cost < regrow_cost`); if within range,
keep the hypotheses. Record the measured numbers in the commit message.

- [ ] **Step 2: Pilot the 9th script.** Follow the pilot protocol
  (`harness/pilot.rb` header; append to inbox with printf, NEVER Write):

```bash
bundle exec rake pilot NAME=vat SEED=7
```

Five acts (spec §Harness): (1) short district hunt + bank at the station;
(2) inscribe at the altar — glyph visible; (3) take wounds + lose one body,
return, tribute at the vat — regrowth + heal on camera; (4) push deep with
the marked body, wipe — marked survives (mark burns), unmarked dissolve;
(5) tribute away the remaining banked, wipe again broke + unmarked — the
floor keeps the possessed vessel. Export to
`harness/scripts/vat_economy.json`.

- [ ] **Step 3: Append the five checks** to `harness/gate_checks.json`
  (ADD-ONLY — existing 34 untouched; every check self-gates with a
  not-exercised clause per the mandatory-beat law):

```json
    { "id": "god_mark_reads", "check": "When a pack body carries the god-mark (a small hollow pale-gold square floating just above the body), it reads at a glance as a persistent blessing on THAT body — clearly distinct from the white possession ring (full-body outline), the teal mark reticle (on humans), and magenta drop/pip glyphs. If no marked body appears in this replay, pass with why='not exercised by this script'." },
    { "id": "fixtures_distinct_read", "check": "In nest frames showing the stations, the three fixtures read as three DIFFERENT interactable places (bank magenta-toned, altar pale bone-gold, vat green) — a stranger could point at which is which. None reads as a wall or the gold gate. If fewer than two fixtures appear, pass with why='not exercised by this script'." },
    { "id": "tribute_beat_reads", "check": "When a tribute fires at the vat (dead bodies regrow at the spawn tiles, wounded HP bars refill), the before/after frames read as a purchase: bodies that were missing/dead stand alive near the vat afterward, and the station cue pulse marks the transaction. Regrown bodies are persistent state — judge any post-tribute frame. If no tribute occurs in this replay, pass with why='not exercised by this script'." },
    { "id": "judgment_reads", "check": "POST-wipe return frames (first frames after the veil lifts) show the judgment: marked bodies stand at the nest spawn while dissolved bodies are ABSENT (their HP bars read dead/empty), or — in the floor case — exactly one kept vessel stands alone. The return must NOT show all three bodies alive after a wipe in which fewer than three were marked. If no wipe occurs in this replay, pass with why='not exercised by this script'." },
    { "id": "retarget_cue_reads", "check": "When a human switches targets mid-fight, a brief small block flashes above it, its color keyed to the cause (rust=kit-hate, yellow=wounded-prey, pale=proximity steal) — readable as 'it turned for a reason', distinct from the telegraph flare and hurt flash. If no retarget cue frame is present, pass with why='not exercised by this script'." }
```

- [ ] **Step 4: Gate the new script (blocking):**

```bash
bundle exec rake gate SCRIPT=harness/scripts/vat_economy.json
```

Exit nonzero = fix (re-pilot the missing beat or fix the render) and
re-gate. Never weaken a check.

- [ ] **Step 5: Commit**

```bash
git add harness/scripts/vat_economy.json harness/gate_checks.json data/balance/economy.json
git commit -m "feat(d1b): vat_economy gate script + 5 checks (34->39), prices re-anchored"
```

---

### Task 13: Re-pilot all 8 existing wall scripts + full 9-script wall

**Files:**
- Modify: all of `harness/scripts/{world_loop,district_hunt,specials_chain,
  loot_loop,taunt_anchor,corpse_run,ledger_loop,threat_pull}.json`
  (re-piloted streams)

The dodge edge-trigger (Task 9) changed input semantics for EVERY stream —
all 8 re-pilot, no exceptions (the tank-first lesson). **Every mandatory
beat re-stages** (memory `gate-critic-mandatory-beat-checks`): projectile
in flight, telegraph, possession swap, nest frames, specials, taunt pulse
+ underline + convergence, corpse-run pip, ledger tallies, pressure ring,
leash walkback, gradient depth comparison.

- [ ] **Step 1:** Re-pilot each script via `rake pilot`, export over the
  old JSON, keeping each script's staged beats (read each script's current
  acts from its JSON `meta`/comments and the gate verdicts log
  `drafts/_gate-verdicts.log` for what it must show).

- [ ] **Step 2:** Run the full wall — all NINE, each one blocking:

```bash
for s in world_loop district_hunt specials_chain loot_loop taunt_anchor corpse_run ledger_loop threat_pull vat_economy; do
  bundle exec rake gate SCRIPT=harness/scripts/$s.json || exit 1
done
```

Expected: 9/9 determinism (double replay + md5) AND 9/9 critic verdicts
green. Any red = fix and re-run that script's gate; artifacts decide, not
memory of a morning pass.

- [ ] **Step 3: Perf + suite:**

```bash
bundle exec rake perf   # p95 must stay < 16.6ms
bundle exec rake
```

- [ ] **Step 4: Commit**

```bash
git add harness/scripts/
git commit -m "harness(d1b): re-pilot all 8 wall scripts under edge-trigger dodge; 9/9 wall green"
```

---

### Task 14: Merge readiness

- [ ] `bundle exec rake` green, `rake perf` green, wall 9/9+9/9 logged in
  `drafts/_gate-verdicts.log`.
- [ ] Adversarial implementation review of the full branch diff (session
  protocol — workflow with declared budget; ledger to
  `drafts/_d1b-impl-review.md`); fold or refute every finding.
- [ ] Merge: `git checkout main && git merge --no-ff d1b-vat`. **NO push.**
- [ ] Update `docs/CHECKPOINT.md` (new top entry) and hand the owner the
  SEVENTH fun-verify per spec §Fun-verify — play-first law: the owner
  plays `bin/play` BEFORE any question batch; telemetry line banked first.

## Self-review notes (run at write time)

- Spec coverage: §1→T2, §2→T3+T4, §3→T5, §4→T6, §5→T8, §6→T9+T10,
  events/telemetry→T4-6+T11, data→T1+T4+T8+T12, presentation→T7,
  harness→T12+T13, fun-verify→T14 handoff. No gaps found.
- Check-id collision avoided: the new glyph check is `god_mark_reads`
  (existing `mark_glyph_readable` is the pack-mark reticle on humans).
- All test bodies are complete code against verified APIs (WorldTest
  drive/hold pattern, TelemetryTest duck-typed world, ThreatTargetingTest
  make_human/teleport staging). Where staging tiles might need adjustment
  (T8's live-human scenario), the adjustable part is named and the
  assertion meanings are fixed.
- The duck-typed world in the telemetry tests is that FILE's existing
  unit-test pattern — the no-mocks law binds integration tests; T4-T6/T9
  run the real World on real data.
