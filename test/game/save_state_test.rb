require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/save_state"
require "net/state_digest"

# v18 increment 1 — Game::SaveState + THE ROUND-TRIP LANE (spec test lanes
# 1+7, the safety net everything else stands on). Real worlds, real data,
# no mocks. Laws under test (spec decisions 1/3/4/5/6a):
#   - pinned canonicalizer: recursive key sort, pinned separators,
#     Integer/String/Boolean + ASCII-only leaves, anything else RAISES;
#   - facts(world) is a PURE projector: pending judgment resolves through
#     the live rules, carried does NOT persist, >=1 living asserted,
#     serialize twice = identical bytes AND digest_snapshot untouched;
#   - strict decoder refusal_for: named refusals, never a crash;
#   - apply in PINNED order: home_zone -> member facts -> seat pointers
#     over the LIVING set -> restore_breach! (side-effect-free) ->
#     enter_zone;
#   - the LANE: facts from a lived-in world A applied to fresh worlds
#     B1/B2 (same NEW seed) => equal digest_snapshot at construction AND
#     byte-identical StateDigest windows for K further scripted ticks;
#   - classification exhaustiveness (lane 7, W1's tripwire): every
#     digest_snapshot field is classified PERSISTED / SESSION-ONLY /
#     DERIVED in the table below; a new field fails until classified.
class SaveStateTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]
  SEAL_PRICE = ECO[:breach_cost]
  MAXES = DATA["balance/combat"][:kits].transform_values { |k| k[:max_hp] }
  CAMP_SPAWN = DATA["zones/camp"][:pack_spawn]
  VEIL_FRAMES = DATA["balance/combat"][:respawn_frames]

  SS = Game::SaveState

  def world(seed: 7, seats: 1, save: nil)
    Game::World.new(DATA, seed:, seats:, save:)
  end

  def idle = @idle ||= Core::ScriptedInput.new(frames: {})

  def drive(w, n, input: idle)
    n.times do
      input.update(w.frame)
      w.tick(input)
    end
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  def member(w, kit) = w.pack.members.find { |m| m.kit_name == kit }

  def bytes(facts) = SS.canonical_bytes(facts)
  def world_bytes(w) = bytes(SS.facts(w))
  def snap(w) = Net::StateDigest.canonical(w.digest_snapshot)
  def deep_dup(obj) = Marshal.load(Marshal.dump(obj))

  # A lived-in world: banked value, a REAL seal breach (station verb, toll
  # spent), an inscription, a dead ally, provisions in the pack pool.
  # Staging uses walker.teleport + real verbs (the seal_breach_test
  # pattern); every interaction goes through the public sim surface.
  def rich_world(seed: 42, seats: 1)
    w = world(seed:, seats:)
    drive(w, 5)
    w.pack.bank!(200) # the interact_bank verb, minus the walk (D1b law)
    w.pack.load_provisions!(2)
    member(w, :striker).inscribe_mark!
    # Real breach: walk the nest gate, stand on the district seal, pay.
    w.possessed.walker.teleport(29, 8)
    drive(w, 2)
    raise "staging: expected district" unless w.zone_name == "district"
    (w.pack.living - [w.possessed]).each_with_index do |m, i|
      m.walker.teleport(2, 2 + i)
    end
    w.possessed.walker.teleport(41, 13)
    raise "staging: breach refused" unless w.interact(w.possessed)
    drive(w, 30) # ride out the breach hitstop; humans move — lived-in state
    kill(member(w, :lobber), by: w.humans.first)
    drive(w, 2) # flush the death (corpse + possible swap bookkeeping)
    w
  end

  def valid_facts
    {
      "banked" => 12, "provisions" => 1, "home_zone" => "nest",
      "breached" => [["district", [42, 13]]],
      "members" => [
        { "kit" => "striker", "hp" => 80, "inscribed" => false },
        { "kit" => "blocker", "hp" => 0, "inscribed" => true },
        { "kit" => "lobber", "hp" => 33, "inscribed" => false }
      ],
      "counters" => { "boss_1_defeats" => 2, "sessions" => 5 }
    }
  end

  def refusal(facts) = SS.refusal_for(facts, data: DATA)

  # --- 1. the pinned canonicalizer ---------------------------------------

  def test_canonical_bytes_sorts_keys_recursively_with_pinned_separators
    tree = { "b" => [1, 2], "a" => { "z" => true, "m" => "x" } }
    assert_equal '{"a":{"m":"x","z":true},"b":[1,2]}', SS.canonical_bytes(tree)
  end

  def test_canonical_bytes_is_insertion_order_independent
    a = { "x" => 1, "y" => { "b" => 2, "a" => 3 } }
    b = { "y" => { "a" => 3, "b" => 2 }, "x" => 1 }
    assert_equal SS.canonical_bytes(a), SS.canonical_bytes(b)
  end

  def test_canonical_bytes_raises_on_non_canonical_leaves
    [{ "f" => 1.5 },                    # Float — the digest leaf-type law
     { "s" => "café" },                 # non-ASCII string
     { "n" => nil },                    # nil is not in the vocabulary
     { "sym" => :oops },                # Symbol leaf
     { sym_key: 1 }].each do |tree|     # Symbol key — string keys only
      assert_raises(SS::EncodeError, "expected raise for #{tree.inspect}") do
        SS.canonical_bytes(tree)
      end
    end
  end

  def test_digest_is_md5_of_canonical_facts_bytes
    f = valid_facts
    assert_equal Digest::MD5.hexdigest(SS.canonical_bytes(f)), SS.digest(f)
  end

  def test_envelope_wraps_facts_without_entering_the_digest
    f = valid_facts
    env = SS.envelope(f, saved_at_ms: 1234)
    assert_equal({ "schema" => SS::SCHEMA, "saved_at_ms" => 1234, "facts" => f }, env)
    assert_equal SS.digest(f), SS.digest(env["facts"]) # digest = facts only
  end

  # --- 2. facts: shape + purity ------------------------------------------

  def test_facts_shape_exact_keys_and_roster_order
    f = SS.facts(world)
    assert_equal %w[banked breached counters home_zone members provisions], f.keys.sort
    assert_equal %w[striker blocker lobber], f["members"].map { |m| m["kit"] }
    assert_equal %w[boss_1_defeats sessions], f["counters"].keys.sort
    assert_nil refusal(f)
  end

  def test_facts_is_pure_serialize_twice_identical_bytes_world_untouched
    w = rich_world
    before_snap = snap(w)
    before_draws = [w.rng.draws, w.respawn_rng.draws]
    b1 = world_bytes(w)
    b2 = world_bytes(w)
    assert_equal b1, b2, "serialize twice must produce identical bytes"
    assert_equal before_snap, snap(w), "facts() mutated the live world"
    assert_equal before_draws, [w.rng.draws, w.respawn_rng.draws],
                 "facts() touched an RNG stream"
  end

  def test_facts_carried_value_does_not_fold_anywhere
    w = world
    w.possessed.pick_up(50)
    f = SS.facts(w)
    assert_equal 0, f["banked"], "carried must not fold into banked (bank it or lose it)"
    loaded = world(save: f)
    assert_equal [0, 0, 0], loaded.pack.members.map(&:carried)
  end

  def test_facts_raises_when_no_member_would_live
    w = world
    w.pack.members.each { |m| kill(m, by: w.pack.members.first) }
    # Mid-flush all-dead in :world state — a violated invariant is a
    # surfaced BUG, never a save (spec decision 3).
    assert_raises(SS::ProjectionBug) { SS.facts(w) }
  end

  # --- 3. THE ROUND-TRIP LANE (spec lane 1, the safety net) ---------------

  def test_round_trip_lane_digest_equal_at_construction_and_for_k_ticks
    a = rich_world(seed: 42)
    facts = SS.facts(a)
    b1 = world(seed: 4242, save: deep_dup(facts))
    b2 = world(seed: 4242, save: deep_dup(facts))
    assert_equal snap(b1), snap(b2), "digest_snapshot must match at construction"
    assert_equal bytes(facts), world_bytes(b1), "loaded facts must round-trip byte-exact"

    k = 240
    frames = {}
    (0...k).each do |f|
      acts = []
      acts << (f < 80 ? :right : :down) if f < 160
      acts << :attack if (f % 45).zero?
      frames[f] = acts
    end
    windows = [b1, b2].map do |b|
      sd = Net::StateDigest.new(world: b, every: 60)
      input = Core::ScriptedInput.new(frames: deep_dup(frames))
      seen = []
      k.times do
        input.update(b.frame)
        b.tick(input)
        (win = sd.after_tick) && seen << win.md5
      end
      seen
    end
    assert_equal 4, windows[0].length, "expected 4 StateDigest windows in #{k} ticks"
    assert_equal windows[0], windows[1],
                 "StateDigest boundary windows diverged on identical loaded worlds"
  end

  def test_round_trip_idempotence_facts_of_applied_facts_equal
    a = rich_world(seed: 42)
    f = SS.facts(a)
    loaded = world(seed: 977, save: deep_dup(f))
    assert_equal bytes(f), world_bytes(loaded),
                 "facts(apply(facts(w))) must equal facts(w) byte-exact"
  end

  def test_loaded_world_starts_at_home_zone_spawn
    a = rich_world(seed: 42) # ends mid-district; home is still nest
    assert_equal "district", a.zone_name
    loaded = world(save: SS.facts(a))
    assert_equal "nest", loaded.zone_name
    assert_equal DATA["zones/nest"][:pack_spawn][0], loaded.possessed.tile
  end

  # --- 4. the projector: judgment resolves at every veil tick -------------

  def wipe!(w, order: %i[lobber striker blocker])
    order.each do |kit|
      m = member(w, kit)
      kill(m, by: (w.pack.members - [m]).first)
      drive(w, 1) # flush: forced swap / wipe transition
    end
    raise "staging: expected the wipe veil" unless w.states.current == :nest_respawn
  end

  def test_projector_sweep_marked_member_revives_at_every_veil_tick
    w = rich_world(seed: 42) # striker is inscribed
    wipe!(w)
    ticks = 0
    while w.states.current == :nest_respawn
      before = snap(w)
      f = SS.facts(w)
      assert_equal before, snap(w), "veil-tick projector mutated the world (tick #{ticks})"
      assert_nil refusal(f), "veil-tick facts must be a legal save (tick #{ticks})"
      by_kit = f["members"].to_h { |m| [m["kit"], m] }
      assert_equal MAXES[:striker], by_kit["striker"]["hp"], "marked striker revives"
      assert_equal 0, by_kit["blocker"]["hp"]
      assert_equal 0, by_kit["lobber"]["hp"]
      assert f["members"].none? { |m| m["inscribed"] }, "judgment consumes the mark"
      ticks += 1
      w.tick(idle)
    end
    assert_operator ticks, :>=, VEIL_FRAMES - 1, "sweep must cover the whole veil"
    # The live judgment must land exactly where the projector said it would.
    assert_equal bytes(SS.facts(w)),
                 bytes(SS.facts(world(seed: 1, save: SS.facts(w)))),
                 "post-judgment facts must still round-trip"
    refute member(w, :striker).dead?, "the marked striker revived through the live rules"
    refute member(w, :striker).marked?, "the live judgment burned the mark"
  end

  def test_projector_floor_keeps_the_wipe_vessel_when_nothing_is_marked
    w = world(seed: 9)
    w.pack.bank!(30)
    # No marks anywhere. Kill allies first, the possessed (blocker) last:
    # the seat pointer stays on the dead blocker — the wipe vessel.
    wipe!(w, order: %i[lobber striker blocker])
    f = SS.facts(w)
    by_kit = f["members"].to_h { |m| [m["kit"], m] }
    assert_equal MAXES[:blocker], by_kit["blocker"]["hp"],
                 "the one-vessel floor keeps the wipe vessel"
    assert_equal 0, by_kit["striker"]["hp"]
    assert_equal 0, by_kit["lobber"]["hp"]
    assert_nil refusal(f)
    assert_equal 30, f["banked"], "banked survives the wipe untouched (never-taxed law)"
  end

  # --- 5. apply: pinned order, seats, silence, clamps ---------------------

  def third_member_facts
    f = valid_facts
    f["home_zone"] = "camp"
    f["members"] = [
      { "kit" => "striker", "hp" => 0, "inscribed" => false },
      { "kit" => "blocker", "hp" => 0, "inscribed" => false },
      { "kit" => "lobber", "hp" => 22, "inscribed" => false }
    ]
    f
  end

  def test_apply_order_non_default_home_and_only_the_third_member_alive
    w = world(save: third_member_facts)
    assert_equal "camp", w.zone_name
    assert_equal "camp", w.home_zone
    lobber = member(w, :lobber)
    assert_equal lobber, w.possessed(1), "seat 1 lands on the living flesh"
    assert_equal CAMP_SPAWN[0], lobber.tile, "the living body takes the home spawn"
    assert_equal 22, lobber.hp
    assert member(w, :striker).dead?
    assert member(w, :blocker).dead?
    assert w.breached?("district", [42, 13])
  end

  def test_apply_seats_2_with_one_living_body_seat_2_waits
    w = world(seats: 2, save: third_member_facts)
    assert_equal :lobber, w.possessed(1).kit_name
    assert_nil w.possessed(2), "seat 2 waits when only one body lives (floor rule)"
  end

  def test_apply_seats_2_with_two_living_bodies_both_seats_hold_flesh
    f = third_member_facts
    f["members"][0]["hp"] = 15 # striker also lives
    w = world(seats: 2, save: f)
    held = [w.possessed(1), w.possessed(2)]
    refute held.any?(&:nil?), "two living bodies must seat both players"
    assert_equal %i[lobber striker], held.map(&:kit_name).sort_by(&:to_s)
    refute held[0].equal?(held[1])
    assert held.none?(&:dead?), "seat pointers must land on LIVING flesh"
  end

  def test_apply_restores_breaches_silently_no_spend_no_presentation
    f = valid_facts
    w = world(save: f)
    assert w.breached?("district", [42, 13])
    assert_equal f["banked"], w.pack.banked, "restore must never re-spend the toll"
    assert_nil w.breach_line, "restore must fire no breach banner"
    assert_nil w.station_cue
    assert_empty w.seal_marks
    refute w.feel.hitstop?, "restore must not kick feel"
  end

  def test_restore_breach_is_idempotent
    w = world
    w.restore_breach!("district", [42, 13])
    w.restore_breach!("district", [42, 13])
    assert_equal [["district", [42, 13]]], w.breached_tuples
  end

  def test_loaded_inscription_armors_the_next_wipe
    f = valid_facts
    f["members"] = [
      { "kit" => "striker", "hp" => 80, "inscribed" => false },
      { "kit" => "blocker", "hp" => 120, "inscribed" => true },
      { "kit" => "lobber", "hp" => 60, "inscribed" => false }
    ]
    w = world(save: f)
    assert member(w, :blocker).marked?, "inscription crosses the session boundary (F3)"
    wipe!(w, order: %i[lobber striker blocker])
    drive(w, VEIL_FRAMES + 2)
    assert_equal :world, w.states.current
    refute member(w, :blocker).dead?, "the loaded mark revived its body"
    refute member(w, :blocker).marked?, "the judgment consumed the loaded mark"
    assert member(w, :striker).dead?
  end

  def test_apply_clamps_hp_to_the_kits_current_max
    f = valid_facts
    f["members"][0]["hp"] = 9999
    w = world(save: f)
    assert_equal MAXES[:striker], member(w, :striker).hp,
                 "hp clamps to the kit's CURRENT max (balance churn law)"
  end

  def test_apply_clamps_provisions_to_the_cap
    f = valid_facts
    f["provisions"] = 99
    w = world(save: f)
    assert_equal ECO[:provision_cap], w.pack.provisions
  end

  # --- 6. persisted-leaf mutation sweep (Codex fold #18) ------------------

  def mutation_leaves
    {
      "banked" => {
        mutate: ->(w) { w.pack.bank!(7) },
        read: ->(w) { w.pack.banked }
      },
      "provisions" => {
        # Staged through the REAL buy verb (v18 increment 5 closes the
        # increment-1 deviation): fund the exact cost, stand on the nest
        # bank, one sustain press. banked nets to its pre-value, so the
        # byte change this leaf proves is provisions' own.
        mutate: lambda { |w|
          w.pack.bank!(ECO[:provision_cost])
          w.possessed.walker.teleport(12, 8) # the nest bank station
          raise "staging: buy refused" unless w.sustain(w.possessed)
        },
        read: ->(w) { w.pack.provisions }
      },
      "home_zone" => {
        mutate: ->(w) { w.start_in("camp") }, # hub entry re-homes (v12 law)
        read: ->(w) { w.home_zone }
      },
      "breached" => {
        mutate: ->(w) { w.restore_breach!("district", [42, 13]) },
        read: ->(w) { w.breached_tuples }
      },
      "member.hp" => {
        mutate: ->(w) { member(w, :striker).take_hit(damage: 5, attacker: member(w, :blocker)) },
        read: ->(w) { member(w, :striker).hp }
      },
      "member.inscribed" => {
        mutate: ->(w) { member(w, :blocker).inscribe_mark! },
        read: ->(w) { member(w, :blocker).marked? }
      },
      "counters.boss_1_defeats" => {
        mutate: lambda { |w|
          w.start_in("low_quay")
          boss = w.humans.find { |h| h.kit[:seize] }
          kill(boss, by: w.possessed)
          drive(w, 1) # flush actor_died — the defeat stamp increments the counter
        },
        read: ->(w) { w.boss_1_defeats }
      }
    }
  end

  def test_persisted_leaf_mutation_sweep_bytes_change_and_values_round_trip
    mutation_leaves.each do |name, leaf|
      w = world(seed: 11)
      before = world_bytes(w)
      leaf[:mutate].call(w)
      facts = SS.facts(w)
      after = bytes(facts)
      refute_equal before, after, "#{name}: mutation did not change canonical bytes"
      loaded = world(seed: 999, save: deep_dup(facts))
      assert_equal leaf[:read].call(w), leaf[:read].call(loaded),
                   "#{name}: value did not survive the round-trip"
      assert_equal after, world_bytes(loaded), "#{name}: facts did not round-trip byte-exact"
    end
  end

  def test_sessions_counter_round_trips_through_apply
    f = valid_facts
    f["counters"]["sessions"] = 3
    w = world(save: f)
    assert_equal 3, w.sessions
    assert_equal 3, SS.facts(w)["counters"]["sessions"]
    f0 = deep_dup(f)
    f0["counters"]["sessions"] = 0
    refute_equal bytes(f0), bytes(f), "sessions must be digest-visible"
  end

  # v18 decision 16 (the solo seed law): "field re-seeds, facts persist"
  # on every path. Same facts + different seeds = byte-identical persisted
  # layer, re-rolled field. Seeds 1/2 are a PINNED divergent pair: the
  # 4-kill drop sequence differs ([1,1,2,2] vs [1,1,2,3] — verified live,
  # deterministic forever).
  def test_same_facts_different_seeds_reseed_the_field
    f = valid_facts
    w1 = world(seed: 1, save: deep_dup(f))
    w2 = world(seed: 2, save: deep_dup(f))
    assert_equal world_bytes(w1), world_bytes(w2),
                 "persisted facts must be seed-independent"
    draws = [w1, w2].map do |w|
      w.start_in("district")
      w.humans.take(4).map do |victim|
        kill(victim, by: w.possessed)
        drive(w, 1) # flush: the drop roll consumes the sim stream
        w.drops.find { |d| d[:tile] == victim.tile }[:amount]
      end
    end
    refute_equal draws[0], draws[1],
                 "different session seeds must re-roll the field (got #{draws.inspect})"
  end

  # --- 7. strict decoder: named refusals, never a crash -------------------

  def test_refusal_for_valid_facts_is_nil
    assert_nil refusal(valid_facts)
    assert_nil refusal(SS.facts(rich_world))
  end

  def test_refusals_are_named_never_raised
    cases = {
      "not an object" => [[1, 2], /facts/],
      "extra key" => [valid_facts.merge("carried" => 5), /keys/],
      "missing key" => [valid_facts.tap { |f| f.delete("provisions") }, /keys/],
      "symbol keys" => [valid_facts.transform_keys(&:to_sym), /keys/],
      "banked type" => [valid_facts.merge("banked" => "12"), /banked/],
      "banked range" => [valid_facts.merge("banked" => -1), /banked/],
      "provisions range" => [valid_facts.merge("provisions" => -2), /provisions/],
      "home unknown" => [valid_facts.merge("home_zone" => "atlantis"), /home_zone/],
      "home not hub" => [valid_facts.merge("home_zone" => "district"), /hub/],
      "home type" => [valid_facts.merge("home_zone" => 3), /home_zone/],
      "breached not array" => [valid_facts.merge("breached" => "x"), /breached/],
      "breached zone" => [valid_facts.merge("breached" => [["atlantis", [1, 2]]]), /breached/],
      "breached not a seal" => [valid_facts.merge("breached" => [["district", [1, 2]]]), /seal/],
      "breached malformed" => [valid_facts.merge("breached" => [["district"]]), /breached/],
      "breached tile floats" => [valid_facts.merge("breached" => [["district", [42.0, 13]]]), /breached/],
      "breached duplicate" => [valid_facts.merge("breached" => [["district", [42, 13]], ["district", [42, 13]]]), /duplicate/],
      "members not array" => [valid_facts.merge("members" => {}), /members/],
      "members short" => [valid_facts.tap { |f| f["members"] = f["members"].take(2) }, /roster/],
      "roster order" => [valid_facts.tap { |f| f["members"] = f["members"].reverse }, /roster/],
      "duplicate kit" => [valid_facts.tap { |f| f["members"][1] = f["members"][0] }, /roster/],
      "member keys" => [valid_facts.tap { |f| f["members"][0] = f["members"][0].merge("carried" => 1) }, /members\[0\]/],
      "hp type" => [valid_facts.tap { |f| f["members"][0] = f["members"][0].merge("hp" => 3.5) }, /hp/],
      "hp range" => [valid_facts.tap { |f| f["members"][0] = f["members"][0].merge("hp" => -5) }, /hp/],
      "inscribed type" => [valid_facts.tap { |f| f["members"][0] = f["members"][0].merge("inscribed" => 1) }, /inscribed/],
      "no living member" => [valid_facts.tap { |f| f["members"].each { |m| m["hp"] = 0 } }, /living/],
      "counters keys" => [valid_facts.merge("counters" => { "boss_1_defeats" => 1 }), /counters/],
      "counters type" => [valid_facts.merge("counters" => { "boss_1_defeats" => "x", "sessions" => 0 }), /counters/],
      "counters range" => [valid_facts.merge("counters" => { "boss_1_defeats" => -1, "sessions" => 0 }), /counters/]
    }
    cases.each do |label, (facts, pattern)|
      r = refusal(deep_dup(facts))
      refute_nil r, "#{label}: expected a named refusal"
      assert_match pattern, r, "#{label}: refusal must name the violation"
    end
  end

  def test_envelope_refusal_names_schema_skew_and_shape
    f = valid_facts
    assert_nil SS.envelope_refusal(SS.envelope(f, saved_at_ms: 5), data: DATA)
    assert_match(/schema/, SS.envelope_refusal({ "schema" => 2, "saved_at_ms" => 5, "facts" => f }, data: DATA))
    assert_match(/schema/, SS.envelope_refusal({ "saved_at_ms" => 5, "facts" => f }, data: DATA))
    assert_match(/envelope/, SS.envelope_refusal([], data: DATA))
    assert_match(/saved_at_ms/, SS.envelope_refusal({ "schema" => 1, "saved_at_ms" => 1.5, "facts" => f }, data: DATA))
    assert_match(/facts/, SS.envelope_refusal({ "schema" => 1, "saved_at_ms" => 5, "facts" => [] }, data: DATA))
  end

  # --- 8. classification exhaustiveness (lane 7, W1's tripwire) -----------

  # EVERY digest_snapshot field is classified here. PERSISTED must appear
  # in the facts vocabulary (the mutation sweep proves the round-trip);
  # DERIVED persists via another leaf (named); SESSION_ONLY dies at the
  # boundary (decision 3's transient zero-list + field-record drop —
  # this table IS that enumerated list, test-enforced).
  CLASSIFICATION = {
    "world" => {
      "frame" => :session_only, "zone" => :session_only, "state" => :session_only,
      "respawn_timer" => :session_only, "home_zone" => :persisted,
      "breached" => :persisted, "last_damaged" => :session_only,
      "swap_was_down" => :session_only, "rearm_needed" => :session_only,
      "corpse_serial" => :session_only, "rng_draws" => :session_only,
      "respawn_rng_draws" => :session_only, "hitstop" => :session_only,
      "boss_1_defeats" => :persisted, "sessions" => :persisted
    },
    "pack" => {
      "banked" => :persisted, "provisions" => :persisted,
      "mark" => :session_only, "possessed.N" => :session_only
    },
    # pack.N + human.zone.name share the creature schema. hp/kind persist
    # (members roster law); marked IS the persisted inscribed flag; alive
    # derives from hp > 0 (never stored — contradictions unrepresentable).
    "creature" => {
      "kind" => :persisted, "hp" => :persisted, "marked" => :persisted,
      "alive" => :derived,
      "tile_x" => :session_only, "tile_y" => :session_only,
      "px" => :session_only, "py" => :session_only,
      "tween_left" => :session_only, "tween_total" => :session_only,
      "reserved_x" => :session_only, "reserved_y" => :session_only,
      "facing_x" => :session_only, "facing_y" => :session_only,
      "stagger" => :session_only, "exhaust" => :session_only,
      "special_exhaust" => :session_only, "iframes" => :session_only,
      "dodge_cooldown" => :session_only, "hurt_frames" => :session_only,
      "action" => :session_only, "action_state" => :session_only,
      "action_frames" => :session_only, "action_triggered" => :session_only,
      "hit_victims" => :session_only, "dash_landing" => :session_only,
      "dash_crossed" => :session_only, "dash_duration" => :session_only,
      "carried" => :session_only, # bank it or lose it (F1, Codex #1)
      "seized_by" => :session_only, "seized_frames" => :session_only,
      "chant_left" => :session_only, "chant_target" => :session_only,
      "chant_hp" => :session_only, "seize_cooldown" => :session_only,
      "engaged" => :session_only, "focus" => :session_only,
      "taunted_by" => :session_only, "taunt_frames" => :session_only,
      "taunt_cause" => :session_only, "leash_frames" => :session_only,
      "beachhead_waived" => :session_only,
      "retarget_cause" => :session_only, "retarget_frames" => :session_only,
      "home_x" => :session_only, "home_y" => :session_only
    },
    # Field records drop wholesale at the save boundary (decision 3c).
    "projectile" => :session_only_group, "impact" => :session_only_group,
    "drop" => :session_only_group, "load" => :session_only_group,
    "respawn" => :session_only_group
  }.freeze

  # Stages every digest group family (the state_digest_test staging
  # pattern): a human kill (drop + respawn record), a carrying pack death
  # (corpse load), a volley (impact) and a projectile in flight.
  def all_groups_world
    w = world(seed: 3)
    w.start_in("district")
    lobber = w.pack.members.find { |m| m.kit_name == :lobber }
    w.pack.swap_next! until w.possessed.equal?(lobber)
    lobber.walker.teleport(20, 4)
    (w.pack.members - [lobber]).each_with_index { |m, i| m.walker.teleport(2, 2 + i) }
    victim = w.humans.reject(&:dead?).first
    kill(victim, by: lobber)
    carrier = (w.pack.members - [lobber]).first
    carrier.pick_up(9)
    kill(carrier, by: lobber)
    drive(w, 1) # flush deaths: drop + respawn record + corpse load
    lobber.face([1, 0])
    lobber.start_special(blocked: []) || raise("staging: volley refused")
    drive_until(w, 200, "volley impact") { w.impacts.any? }
    drive_until(w, 200, "lobber idle after volley") { lobber.attack_state == :idle }
    lobber.start_attack || raise("staging: projectile attack refused")
    drive_until(w, 200, "projectile in flight") { w.projectiles.any? }
    raise "staging: impact gone before projectile flew" if w.impacts.empty?
    w
  end

  def drive_until(w, cap, what)
    cap.times do
      return if yield
      w.tick(idle)
    end
    raise "staging: #{what} not reached within #{cap} ticks"
  end

  def classification_for(group)
    case group
    when "world", "pack" then CLASSIFICATION[group]
    when /\Apack\.\d+\z/, /\Ahuman\./ then CLASSIFICATION["creature"]
    when /\Aprojectile\./ then CLASSIFICATION["projectile"]
    when /\Aimpact\./ then CLASSIFICATION["impact"]
    when /\Adrop\./ then CLASSIFICATION["drop"]
    when /\Aload\./ then CLASSIFICATION["load"]
    when /\Arespawn\./ then CLASSIFICATION["respawn"]
    end
  end

  def test_every_digest_field_is_classified_persisted_or_session_only
    snap = all_groups_world.digest_snapshot
    families_seen = []
    snap.each do |group, fields|
      table = classification_for(group)
      refute_nil table, "digest group #{group}: no classification family — " \
                        "classify it PERSISTED or SESSION-ONLY (W1 tripwire)"
      families_seen << table
      next if table == :session_only_group
      fields.each do |name, _|
        key = group == "pack" && name =~ /\Apossessed\.\d+\z/ ? "possessed.N" : name
        assert table.key?(key),
               "NEW digest field #{group}.#{name} is unclassified — add it to " \
               "CLASSIFICATION as :persisted (+ facts + mutation sweep) or :session_only (W1)"
      end
    end
    %w[projectile impact drop load respawn].each do |fam|
      assert_includes families_seen, CLASSIFICATION[fam],
                      "staging lost the #{fam} group — the tripwire no longer sees it"
    end
  end

  def test_every_persisted_classification_is_swept
    swept = mutation_leaves.keys
    assert_includes swept, "banked"
    assert_includes swept, "provisions"
    assert_includes swept, "home_zone"
    assert_includes swept, "breached"
    assert_includes swept, "member.hp"          # creature hp
    assert_includes swept, "member.inscribed"   # creature marked
    assert_includes swept, "counters.boss_1_defeats"
    # sessions: no in-sim mutation path exists yet (the save coordinator
    # bumps it at write — increment 2); its round-trip is pinned above.
  end
end
