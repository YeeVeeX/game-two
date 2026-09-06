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
#   - apply in PINNED order: home_zone -> counters/progression -> leveled
#     max hp -> member facts -> bank/provisions -> seat pointers over the
#     LIVING set -> restore_breach! (side-effect-free) -> enter_zone;
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

  # Schema 3 (v22 T1): the host character is keyed "bot-1" = the harness
  # default seat-1 id (`world(save:)` seats it); HOST is that key.
  HOST = "bot-1".freeze

  def host_record(level: 1, xp: 0, home: "nest", form: "striker")
    {
      "level" => level, "xp" => xp, "xp_debt" => 0, "insurance" => 0,
      "home_zone" => home, "form" => form,
      "forms" => {
        "striker" => { "hp" => 80, "inscribed" => false },
        "blocker" => { "hp" => 0, "inscribed" => true },
        "lobber" => { "hp" => 33, "inscribed" => false }
      },
      "bag" => [], "equipment" => {}, "attributes" => {}, "bank_items" => []
    }
  end

  def valid_facts
    {
      "banked" => 12, "provisions" => 1,
      "breached" => [["district", [42, 13]]],
      "counters" => { "boss_1_defeats" => 2, "sessions" => 5 },
      "characters" => { HOST => host_record }
    }
  end

  def host_of(facts) = facts["characters"][HOST]

  # Schema 2's facts shape — what every pre-v22 file on disk carries (the
  # owner's live save is one): shared progression + the members roster.
  def v2_facts
    {
      "banked" => 12, "provisions" => 1, "home_zone" => "nest",
      "breached" => [["district", [42, 13]]],
      "members" => [
        { "kit" => "striker", "hp" => 80, "inscribed" => false },
        { "kit" => "blocker", "hp" => 0, "inscribed" => true },
        { "kit" => "lobber", "hp" => 33, "inscribed" => false }
      ],
      "counters" => { "boss_1_defeats" => 2, "sessions" => 5 },
      "progression" => { "level" => 1, "xp" => 0 }
    }
  end

  def refusal(facts) = SS.refusal_for(facts, data: DATA)
  def v2_refusal(facts) = SS.v2_refusal_for(facts, data: DATA)

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
    assert_equal %w[banked breached characters counters provisions], f.keys.sort,
                 "a fresh world carries no migration block"
    assert_equal [HOST], f["characters"].keys, "the fresh host character, keyed by player id"
    host = host_of(f)
    assert_equal Game::Character::KEYS, host.keys.sort, "every record key is WRITTEN (optional ones at their defaults)"
    assert_equal %w[blocker lobber striker], host["forms"].keys.sort, "forms keyed by the roster kits"
    assert_equal %w[hp inscribed], host["forms"]["striker"].keys.sort
    assert_equal %w[boss_1_defeats sessions], f["counters"].keys.sort
    assert_equal [1, 0, 0, 0, "nest", "blocker"],
                 host.values_at("level", "xp", "xp_debt", "insurance", "home_zone", "form"),
                 "a fresh character: new_character.level, the initial hub, the initial possessed kit"
    assert_equal [[], {}, {}, []], host.values_at("bag", "equipment", "attributes", "bank_items"),
                 "Junior's keys ride EMPTY until S2 fills them"
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
      by_kit = host_of(f)["forms"]
      assert_equal MAXES[:striker], by_kit["striker"]["hp"], "marked striker revives"
      assert_equal 0, by_kit["blocker"]["hp"]
      assert_equal 0, by_kit["lobber"]["hp"]
      assert by_kit.values.none? { |m| m["inscribed"] }, "judgment consumes the mark"
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
    by_kit = host_of(f)["forms"]
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
    host_of(f)["home_zone"] = "camp"
    host_of(f)["form"] = "lobber"
    host_of(f)["forms"] = {
      "striker" => { "hp" => 0, "inscribed" => false },
      "blocker" => { "hp" => 0, "inscribed" => false },
      "lobber" => { "hp" => 22, "inscribed" => false }
    }
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
    host_of(f)["forms"]["striker"]["hp"] = 15 # striker also lives
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
    host_of(f)["form"] = "blocker"
    host_of(f)["forms"] = {
      "striker" => { "hp" => 80, "inscribed" => false },
      "blocker" => { "hp" => 120, "inscribed" => true },
      "lobber" => { "hp" => 60, "inscribed" => false }
    }
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
    host_of(f)["forms"]["striker"]["hp"] = 9999
    w = nil
    _, err = capture_io { w = world(save: f) }
    assert_match(/clamped striker hp 9999/, err)
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
      "progression.level" => {
        mutate: ->(w) { w.progression.load_progress!(level: 2, xp: 0) },
        read: ->(w) { w.progression.level }
      },
      "progression.xp" => {
        mutate: ->(w) { w.progression.award(1) },
        read: ->(w) { w.progression.xp }
      },
      "counters.boss_1_defeats" => {
        mutate: lambda { |w|
          w.start_in("low_quay")
          boss = w.humans.find { |h| h.kit[:seize] }
          kill(boss, by: w.possessed)
          drive(w, 1) # flush actor_died — the defeat stamp increments the counter
        },
        read: ->(w) { w.boss_1_defeats }
      },
      # v22 T1 character leaves. xp_debt/insurance have no sim writer yet
      # (T4/T5 own them) — staged through the record's plain writers.
      "character.xp_debt" => {
        mutate: ->(w) { w.party.host.xp_debt = 5 },
        read: ->(w) { w.party.host.xp_debt }
      },
      "character.insurance" => {
        mutate: ->(w) { w.party.host.insurance = 2 },
        read: ->(w) { w.party.host.insurance }
      },
      # form = the body seat 1 holds; the round-trip proves apply! RESUMES it
      # (a persisted fact the load path ignored could never round-trip).
      "character.form" => {
        mutate: ->(w) { w.pack.swap_next! },
        read: ->(w) { w.possessed(1).kit_name }
      },
      # Junior's S2 merge point: the bag persists by pushing into the host
      # record's own container — this leaf IS his one-line hook, proven.
      "character.bag" => {
        mutate: ->(w) { w.party.host.bag << { "id" => "flask_sap", "qty" => 2 } },
        read: ->(w) { w.party.host.bag }
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
    with_host = ->(over) { valid_facts.tap { |f| host_of(f).merge!(over) } }
    dead_forms = %w[striker blocker lobber].to_h { |k| [k, { "hp" => 0, "inscribed" => false }] }
    cases = {
      "not an object" => [[1, 2], /facts/],
      "extra key" => [valid_facts.merge("carried" => 5), /keys: unknown carried/],
      "missing key" => [valid_facts.tap { |f| f.delete("provisions") }, /keys: missing provisions/],
      "retired v2 key" => [valid_facts.merge("members" => []), /keys: unknown members/],
      "retired v2 progression" => [valid_facts.merge("progression" => { "level" => 1, "xp" => 0 }), /keys: unknown progression/],
      "retired v2 home_zone" => [valid_facts.merge("home_zone" => "nest"), /keys: unknown home_zone/],
      "symbol keys" => [valid_facts.transform_keys(&:to_sym), /keys/],
      "banked type" => [valid_facts.merge("banked" => "12"), /banked/],
      "banked range" => [valid_facts.merge("banked" => -1), /banked/],
      "provisions range" => [valid_facts.merge("provisions" => -2), /provisions/],
      "breached not array" => [valid_facts.merge("breached" => "x"), /breached/],
      "breached zone" => [valid_facts.merge("breached" => [["atlantis", [1, 2]]]), /breached/],
      "breached not a seal" => [valid_facts.merge("breached" => [["district", [1, 2]]]), /seal/],
      "breached malformed" => [valid_facts.merge("breached" => [["district"]]), /breached/],
      "breached tile floats" => [valid_facts.merge("breached" => [["district", [42.0, 13]]]), /breached/],
      "breached duplicate" => [valid_facts.merge("breached" => [["district", [42, 13]], ["district", [42, 13]]]), /duplicate/],
      "counters keys" => [valid_facts.merge("counters" => { "boss_1_defeats" => 1 }), /counters/],
      "counters type" => [valid_facts.merge("counters" => { "boss_1_defeats" => "x", "sessions" => 0 }), /counters/],
      "counters range" => [valid_facts.merge("counters" => { "boss_1_defeats" => -1, "sessions" => 0 }), /counters/],
      # characters: the map + one representative per Character.refusal family
      # (the exhaustive per-key table lives in character_test.rb)
      "characters not object" => [valid_facts.merge("characters" => []), /characters: not an object/],
      "characters empty" => [valid_facts.merge("characters" => {}), /characters: at least one character/],
      "character key not an id" => [valid_facts.merge("characters" => { "seat-1" => host_record }), /key "seat-1" is not a player id/],
      "character not object" => [valid_facts.merge("characters" => { HOST => 5 }), /characters\[bot-1\]: not an object/],
      "character unknown key" => [with_host.call("carried" => 1), /characters\[bot-1\]: unknown key\(s\) carried/],
      "character missing key" => [valid_facts.tap { |f| host_of(f).delete("form") }, /characters\[bot-1\]: missing key\(s\) form/],
      "home unknown" => [with_host.call("home_zone" => "atlantis"), /characters\[bot-1\]\.home_zone: unknown zone/],
      "home not hub" => [with_host.call("home_zone" => "district"), /characters\[bot-1\]\.home_zone: "district" is not a hub/],
      "home type" => [with_host.call("home_zone" => 3), /characters\[bot-1\]\.home_zone: must be a String/],
      "forms kit set" => [with_host.call("forms" => host_record["forms"].reject { |k, _| k == "lobber" }), /forms: kits must be exactly/],
      "form hp type" => [with_host.call("forms" => host_record["forms"].merge("striker" => { "hp" => 3.5, "inscribed" => false })), /forms\.striker\.hp/],
      "no living form" => [with_host.call("forms" => dead_forms), /no living form/],
      "form not a kit" => [with_host.call("form" => "husk"), /characters\[bot-1\]\.form: "husk" is not a roster kit/],
      "level zero" => [with_host.call("level" => 0), /characters\[bot-1\]\.level/],
      "level type" => [with_host.call("level" => 1.0), /characters\[bot-1\]\.level/],
      "xp negative" => [with_host.call("xp" => -1), /characters\[bot-1\]\.xp/],
      "xp_debt negative" => [with_host.call("xp_debt" => -1), /characters\[bot-1\]\.xp_debt/],
      "insurance over cap" => [with_host.call("insurance" => INSURANCE_CAP + 1), /characters\[bot-1\]\.insurance: must be an Integer in 0\.\.#{INSURANCE_CAP}/],
      "bag float leaf" => [with_host.call("bag" => [{ "qty" => 1.5 }]), /characters\[bot-1\]\.bag\[0\]\.qty: non-canonical leaf Float/],
      "second character bad" => [valid_facts.tap { |f| f["characters"]["bot-2"] = host_record.merge("xp" => -3) }, /characters\[bot-2\]\.xp/],
      # the optional migration block
      "migration not object" => [valid_facts.merge("migration" => 2), /migration: not an object/],
      "migration keys" => [valid_facts.merge("migration" => { "from_schema" => 2 }), /migration: keys must be exactly/],
      "migration from_schema" => [valid_facts.merge("migration" => MIGRATION.merge("from_schema" => 1)), /migration\.from_schema: must be 2/],
      "migration legacy level" => [valid_facts.merge("migration" => MIGRATION.merge("legacy_level" => 0)), /migration\.legacy_level/],
      "migration claimed_by shape" => [valid_facts.merge("migration" => MIGRATION.merge("legacy_seed_claimed_by" => 4)), /migration\.legacy_seed_claimed_by/]
    }
    cases.each do |label, (facts, pattern)|
      r = refusal(deep_dup(facts))
      refute_nil r, "#{label}: expected a named refusal"
      assert_match pattern, r, "#{label}: refusal must name the violation and its path"
    end
  end

  INSURANCE_CAP = DATA["balance/death"][:insurance][:max_stacks]
  MIGRATION = { "from_schema" => 2, "legacy_level" => 13, "legacy_seed_claimed_by" => false }.freeze

  def test_optional_keys_absent_equal_their_defaults_and_a_migration_block_is_optional
    f = valid_facts
    %w[bag equipment attributes bank_items].each { |k| host_of(f).delete(k) }
    assert_nil refusal(f), "absent optional keys = defaults (the optional-key law)"
    w = world(save: deep_dup(f))
    assert_equal [[], {}, {}, []], host_of(SS.facts(w)).values_at("bag", "equipment", "attributes", "bank_items"),
                 "the projector WRITES every key"
    assert_nil refusal(valid_facts.merge("migration" => MIGRATION))
    assert_nil refusal(valid_facts.merge("migration" => MIGRATION.merge("legacy_seed_claimed_by" => "bot-2")))
    w = world(save: valid_facts.merge("migration" => deep_dup(MIGRATION)))
    assert_equal MIGRATION, SS.facts(w)["migration"], "the block round-trips verbatim while the seed is unclaimed"
  end

  def test_envelope_refusal_names_schema_skew_and_shape
    f = valid_facts
    assert_nil SS.envelope_refusal(SS.envelope(f, saved_at_ms: 5), data: DATA)
    assert_match(/schema/, SS.envelope_refusal({ "schema" => 4, "saved_at_ms" => 5, "facts" => f }, data: DATA))
    assert_match(/schema/, SS.envelope_refusal({ "schema" => "3", "saved_at_ms" => 5, "facts" => f }, data: DATA))
    assert_match(/schema/, SS.envelope_refusal({ "saved_at_ms" => 5, "facts" => f }, data: DATA))
    assert_match(/envelope/, SS.envelope_refusal([], data: DATA))
    assert_match(/saved_at_ms/, SS.envelope_refusal({ "schema" => SS::SCHEMA, "saved_at_ms" => 1.5, "facts" => f }, data: DATA))
    assert_match(/facts/, SS.envelope_refusal({ "schema" => SS::SCHEMA, "saved_at_ms" => 5, "facts" => [] }, data: DATA))
  end

  # L9 (council s132): schema 1 refuses NAMED under schema 3 — the exact
  # text is the contract (no live v1 chain exists; the v1 lane is gone).
  def test_schema_1_refuses_named_with_the_pinned_text
    v1 = v2_facts.tap { |f| f.delete("progression") }
    assert_equal "save schema: 1 unsupported (expected 3)",
                 SS.envelope_refusal({ "schema" => 1, "saved_at_ms" => 5, "facts" => v1 }, data: DATA)
    refute SS.respond_to?(:upgrade_v1), "the v1 upgrade lane is deleted"
    refute SS.const_defined?(:V1_FACT_KEYS), "the frozen v1 key set is deleted with it"
  end

  # --- 7b. the 2 -> 3 migration lane (L9, pure half — IO in save_store_test) --

  def migrate(f = v2_facts, player_id: HOST) = SS.migrate_v2(f, player_id:, data: DATA)

  def test_v2_facts_validate_under_the_frozen_v2_rules_only
    assert_nil v2_refusal(v2_facts)
    assert_match(/keys: missing characters; unknown home_zone,members,progression/, refusal(v2_facts),
                 "v2 facts must NOT pass the schema-3 decoder")
    assert_match(/keys/, v2_refusal(valid_facts), "v3 facts must NOT pass the frozen v2 decoder")
    assert_match(/banked/, v2_refusal(v2_facts.merge("banked" => -1)),
                 "the v2 lane stays STRICT — shared refusals still bite")
    v2_cases = {
      "members not array" => [v2_facts.merge("members" => {}), /members/],
      "members short" => [v2_facts.tap { |f| f["members"] = f["members"].take(2) }, /roster/],
      "roster order" => [v2_facts.tap { |f| f["members"] = f["members"].reverse }, /roster/],
      "member keys" => [v2_facts.tap { |f| f["members"][0] = f["members"][0].merge("carried" => 1) }, /members\[0\]/],
      "hp type" => [v2_facts.tap { |f| f["members"][0] = f["members"][0].merge("hp" => 3.5) }, /hp/],
      "inscribed type" => [v2_facts.tap { |f| f["members"][0] = f["members"][0].merge("inscribed" => 1) }, /inscribed/],
      "no living member" => [v2_facts.tap { |f| f["members"].each { |m| m["hp"] = 0 } }, /living/],
      "home not hub" => [v2_facts.merge("home_zone" => "district"), /home_zone: "district" is not a hub/],
      "progression missing key" => [v2_facts.merge("progression" => { "level" => 1 }), /progression/],
      "level zero" => [v2_facts.merge("progression" => { "level" => 0, "xp" => 0 }), /level/],
      "xp type" => [v2_facts.merge("progression" => { "level" => 1, "xp" => "0" }), /xp/]
    }
    v2_cases.each do |label, (facts, pattern)|
      r = v2_refusal(deep_dup(facts))
      refute_nil r, "#{label}: expected a named v2 refusal"
      assert_match pattern, r, label
    end
  end

  def test_envelope_refusal_routes_schema_2_to_the_frozen_v2_rules
    assert_nil SS.envelope_refusal({ "schema" => 2, "saved_at_ms" => 5, "facts" => v2_facts }, data: DATA)
    assert_match(/keys/, SS.envelope_refusal(
      { "schema" => 2, "saved_at_ms" => 5, "facts" => valid_facts }, data: DATA
    ), "a schema-2 envelope carrying v3 facts must refuse")
  end

  def test_migrate_v2_derives_the_host_character_and_is_pure
    f = v2_facts
    before = deep_dup(f)
    m = migrate(f)
    assert_equal before, f, "migrate_v2 must not mutate its input"
    assert_equal %w[banked breached characters counters migration provisions], m.keys.sort
    assert_equal [12, 1, [["district", [42, 13]]], { "boss_1_defeats" => 2, "sessions" => 5 }],
                 m.values_at("banked", "provisions", "breached", "counters"), "shared facts carry over verbatim"
    assert_equal [HOST], m["characters"].keys, "keyed by the LOADING machine's player id"
    host = m["characters"][HOST]
    assert_equal Game::Character::KEYS, host.keys.sort
    assert_equal [1, 0, 0, 0, "nest"], host.values_at("level", "xp", "xp_debt", "insurance", "home_zone")
    assert_equal({ "striker" => { "hp" => 80, "inscribed" => false },
                   "blocker" => { "hp" => 0, "inscribed" => true },
                   "lobber" => { "hp" => 33, "inscribed" => false } }, host["forms"])
    assert_equal "striker", host["form"],
                 "the initial possessed kit (blocker) is dead -> the first living member, as the v2 pointer law resumed"
    assert_equal [[], {}, {}, []], host.values_at("bag", "equipment", "attributes", "bank_items")
    assert_equal({ "from_schema" => 2, "legacy_level" => 1, "legacy_seed_claimed_by" => false }, m["migration"])
    assert_nil refusal(m), "a migrated tree must be a valid schema-3 save"
    assert_raises(ArgumentError) { migrate(v2_facts, player_id: "seat-1") }
  end

  def test_migrate_v2_form_is_the_initial_possessed_kit_when_it_lives
    f = v2_facts
    f["members"][1]["hp"] = 50 # blocker (initial_possessed) lives
    assert_equal "blocker", migrate(f)["characters"][HOST]["form"]
  end

  def test_migrated_v2_round_trip_is_schema_3_byte_stable
    m = migrate(v2_facts)
    loaded = world(save: deep_dup(m))
    assert_equal bytes(m), world_bytes(loaded),
                 "v2 -> migrate -> apply -> project must round-trip byte-exact as schema 3"
    assert_equal 1, loaded.progression.level
    assert_equal :striker, loaded.possessed(1).kit_name, "seat 1 resumes the migrated form"
    assert member(loaded, :blocker).marked?, "the inscription crossed the hop"
  end

  # The owner's live chain, in shape: level 13 / xp 1740 / zone_7 home / 5
  # seals / 6 defeats (saves/world.json on 2026-09-06 — values, not bytes;
  # the byte proof runs on a COPY in the ticket record).
  def test_migrate_v2_of_a_lived_in_chain_shape
    f = v2_facts.merge(
      "banked" => 208, "home_zone" => "zone_7",
      "breached" => [["basement_2", [6, 3]], ["district", [42, 13]], ["district_two", [42, 13]], ["zone_7", [33, 14]]],
      "counters" => { "boss_1_defeats" => 6, "sessions" => 19 },
      "members" => [{ "kit" => "striker", "hp" => 137, "inscribed" => false },
                    { "kit" => "blocker", "hp" => 275, "inscribed" => false },
                    { "kit" => "lobber", "hp" => 103, "inscribed" => false }],
      "progression" => { "level" => 13, "xp" => 1740 }
    )
    assert_nil v2_refusal(f)
    m = migrate(f, player_id: HOST)
    host = m["characters"][HOST]
    assert_equal [13, 1740, "zone_7", "blocker"], host.values_at("level", "xp", "home_zone", "form")
    assert_equal 13, m["migration"]["legacy_level"]
    w = world(save: deep_dup(m))
    assert_equal bytes(m), world_bytes(w), "the owner's chain shape round-trips byte-exact"
    assert_equal [13, 1740, "zone_7", :blocker], [w.progression.level, w.progression.xp, w.home_zone, w.possessed(1).kit_name]
    assert_equal 275, member(w, :blocker).hp, "hp lands at the leveled max, no clamp"
  end

  # --- 7c. progression apply: clamps warn + proceed (P3's churn law) -------

  def progression_facts(level:, xp:)
    valid_facts.tap { |f| host_of(f).merge!("level" => level, "xp" => xp) }
  end

  def test_progression_facts_round_trip_through_apply
    f = progression_facts(level: 2, xp: 10)
    w = world(save: deep_dup(f))
    assert_equal [2, 10], [w.progression.level, w.progression.xp]
    assert_equal bytes(f), world_bytes(w)
  end

  def test_level_5_hp_round_trip_uses_the_leveled_max
    f = progression_facts(level: 5, xp: 10)
    progression = Game::Progression.new(config: DATA["balance/progression"])
    progression.load_progress!(level: 5, xp: 10)
    host_of(f)["forms"].each do |kit, form|
      form["hp"] = progression.max_hp_for(MAXES.fetch(kit.to_sym))
    end
    w = nil

    _, err = capture_io { w = world(save: deep_dup(f)) }

    refute_match(/clamped .* hp/, err,
                 "legitimate leveled hp must not false-clamp against level-1 max")
    assert_equal bytes(f), world_bytes(w)
  end

  def test_apply_clamps_hp_when_growth_was_lowered
    f = progression_facts(level: 5, xp: 10)
    progression = Game::Progression.new(config: DATA["balance/progression"])
    progression.load_progress!(level: 5, xp: 10)
    expected = progression.max_hp_for(MAXES[:striker])
    host_of(f)["forms"]["striker"]["hp"] = expected + 20
    w = nil

    _, err = capture_io { w = world(save: deep_dup(f)) }

    assert_equal expected, member(w, :striker).hp
    assert_equal expected, member(w, :striker).max_hp
    assert_match(/clamped striker hp/, err,
                 "a lower growth starter warns and proceeds at the new ceiling")
  end

  def test_apply_clamps_level_to_the_current_cap_warn_and_proceed
    cap = DATA["balance/progression"][:curve][:level_cap]
    w = nil
    _, err = capture_io { w = world(save: progression_facts(level: cap + 5, xp: 0)) }
    assert_equal cap, w.progression.level, "level clamps to the cap (cap-lowered law)"
    assert_match(/clamped level/, err, "the clamp must WARN, never silently rewrite")
  end

  def test_apply_clamps_xp_below_the_next_level_cost_warn_and_proceed
    ceiling = Game::Progression.new(config: DATA["balance/progression"]).delta_e(2)
    w = nil
    _, err = capture_io { w = world(save: progression_facts(level: 1, xp: ceiling + 40)) }
    assert_equal ceiling - 1, w.progression.xp, "xp clamps under ΔE(level+1) (curve-churn law)"
    assert_equal 1, w.progression.level
    assert_match(/clamped xp/, err)
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
      "zone_left_at" => :session_only, # J7-B stamp: dies with the zone positions it points at
      "swap_was_down" => :session_only, "rearm_needed" => :session_only,
      "corpse_serial" => :session_only, "rng_draws" => :session_only,
      "respawn_rng_draws" => :session_only, "hitstop" => :session_only,
      "boss_1_defeats" => :persisted, "sessions" => :persisted
    },
    # v22 T1: one group per character record (character.<player id>, sorted
    # id order). level/xp moved here from the world group; forms ride the
    # creature rows; Junior's keys are session-inert until S2 reads them.
    "character" => {
      "level" => :persisted, "xp" => :persisted, "xp_debt" => :persisted,
      "insurance" => :persisted, "form" => :persisted, "home_zone" => :persisted
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
      "pack_provoked" => :session_only, # C2: dies with the body/session, like the waiver
      "retarget_cause" => :session_only, "retarget_frames" => :session_only,
      "home_x" => :session_only, "home_y" => :session_only,
      "blink_cooldown" => :session_only, # FASE 4.3: a beat clock, dies with the session like seize_cooldown
      "boss_skill_index" => :session_only, # FASE 5: rotation pointer; a boss re-enters at skill 0 (phase = f(hp) anyway)
      # FASE 4.5 poison: a DOT in flight dies with the session (like iframes/hurt_frames)
      "poison_ticks" => :session_only, "poison_dmg" => :session_only,
      "poison_countdown" => :session_only, "poison_by" => :session_only
    },
    # Field records drop wholesale at the save boundary (decision 3c).
    "projectile" => :session_only_group, "impact" => :session_only_group,
    "drop" => :session_only_group, "load" => :session_only_group,
    "respawn" => :session_only_group,
    # v20 T4: totem cadence timers re-arm each session by design (L9 —
    # the totem is zone data; its countdown is never a save fact).
    "totem" => :session_only_group
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
    when /\Acharacter\./ then CLASSIFICATION["character"]
    when /\Apack\.\d+\z/, /\Ahuman\./ then CLASSIFICATION["creature"]
    when /\Aprojectile\./ then CLASSIFICATION["projectile"]
    when /\Aimpact\./ then CLASSIFICATION["impact"]
    when /\Adrop\./ then CLASSIFICATION["drop"]
    when /\Aload\./ then CLASSIFICATION["load"]
    when /\Arespawn\./ then CLASSIFICATION["respawn"]
    when /\Atotem\./ then CLASSIFICATION["totem"]
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
    assert_includes swept, "progression.level"
    assert_includes swept, "progression.xp"
    assert_includes swept, "character.xp_debt"
    assert_includes swept, "character.insurance"
    assert_includes swept, "character.form"
    assert_includes swept, "character.bag"    # Junior's S2 hook, proven
    # sessions: no in-sim mutation path exists yet (the save coordinator
    # bumps it at write — increment 2); its round-trip is pinned above.
  end
end
