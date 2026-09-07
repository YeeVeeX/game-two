require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/telemetry"

# v20 T4 (foundation L4): the contested/cadenced heal totem on floor -1;
# v22 TS (owner word s133): cadence 3 s, radius +2, heal scales with the
# healed body's OWN hp pool. Real files, no mocks — the authored district
# totem at [26,55] (mid bridge 3, beside Junior's own bridge guardian),
# numbers from data/balance/sustain.json (Rule 3): every staged position
# derives from CFG[:radius] (in range AT the radius, out at radius + 1
# along the bridge planks), every expected heal from the same max(heal_min,
# max_hp * pct / 100) Integer arithmetic the pulse applies. The pulse heals
# LIVING pack bodies within Chebyshev radius, clamped; dead untouched (vat
# monopoly law); fires on cadence regardless of range occupancy
# (discoverability law).
class TotemTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["balance/sustain"][:totem]
  LEVEL_CAP = DATA["balance/progression"][:curve][:level_cap]
  TOTEM = [26, 55].freeze
  R = CFG[:radius]

  def world = @world ||= Game::World.new(DATA).tap { |w| w.start_in("district") }

  def pulses
    @pulses ||= [].tap do |log|
      world.bus.subscribe(:totem_pulse) { |e| log << e.payload.merge(frame: world.frame) }
    end
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  # The authored guardian contests the totem; tests that need a quiet
  # bridge remove him through the same take_hit path combat uses. Kills
  # kick hitstop (feel), and hitstop SKIPS tick_world — the cadence pause
  # law — so staging settles the feel clock before any cadence counting.
  # (While the pack HOLDS the bridge his respawn stays deferred:
  # threat.json respawn_block_tiles (12) covers the whole radius field.)
  def clear_guardian!
    guard = world.humans.find { |h| h.tile == [26, 54] }
    kill(guard, by: world.possessed) if guard
    settle!
  end

  def settle!
    world.bus.process
    world.tick(Core::NullInput.new) while world.feel.hitstop?
  end

  # Bridge 3's ENDS are contested by design (rusher spawns at [13,50] and
  # [38,48] sit within aggro_tiles of x 22 / x 30 — probed live cutting
  # the TS tests: a body parked at the radius edge for a whole cadence eats
  # a rusher hit at ~f169 and the hp arithmetic lies). Staging law: the
  # pack waits at the bridge CENTER (outside every spawn's aggro), then
  # takes its assertion tiles LATE ticks before the pulse — no rusher can
  # path there in time. The guard below convicts any hit that lands anyway
  # (re-stage; never read hp through a fight).
  LATE = 20
  CENTER = [[25, 55], [24, 55], [27, 55]].freeze

  def hits_on_pack
    @hits ||= [].tap do |log|
      world.bus.subscribe(:attack_hit) { |e| log << [world.frame, e[:attacker].name, e[:victim].name] if world.pack.members.include?(e[:victim]) }
    end
  end

  # Ticks a whole cadence: (cadence - LATE) at the center, then each body
  # on its own assertion tile for the last LATE ticks. Returns after the
  # pulse tick with the bus drained.
  def dwell_then_place!(placements)
    hits_on_pack
    (CFG[:cadence_ticks] - LATE).times { world.tick(Core::NullInput.new) }
    placements.each { |body, (x, y)| body.walker.teleport(x, y) }
    LATE.times { world.tick(Core::NullInput.new) }
    world.bus.process
    assert_empty hits_on_pack, "staging: a human hit the pack during the cadence — re-stage"
  end

  # The TS formula, computed HERE from data (never read back from the
  # code under test): Integer division, floor at heal_min.
  def expected_heal(max_hp) = [CFG[:heal_min], (max_hp * CFG[:heal_pct_max_hp]) / 100].max

  def test_authored_totem_station_is_on_the_district_bridge
    station = world.map.station_at(*TOTEM)
    refute_nil station, "district must carry the authored totem at #{TOTEM}"
    assert_equal "totem", station[:type]
  end

  def test_data_rows_are_the_ts_shape
    assert_equal %i[cadence_ticks heal_min heal_pct_max_hp radius], CFG.keys.sort,
                 "sustain.json totem carries exactly the TS rows (heal_amount retired)"
    CFG.each_value { |v| assert_kind_of Integer, v, "no Float ever enters the balance path" }
    assert_equal 180, CFG[:cadence_ticks], "owner word s133: pulse every 3 s at the 60-tick second"
  end

  def test_pulse_heals_in_radius_clamped_and_never_the_dead
    clear_guardian!
    body = world.possessed
    ally, other = (world.pack.members - [body]).first(2)
    [body, ally, other].zip(CENTER) { |m, (x, y)| m.walker.teleport(x, y) }
    body.take_hit(damage: 40, attacker: ally)
    ally.take_hit(damage: 4, attacker: body)
    kill(other, by: body)
    settle!
    hurt_hp = body.hp
    heal = expected_heal(body.max_hp)
    assert_equal CFG[:heal_min], heal, "a level-1 pool (#{body.max_hp}) heals the floor, not the pct"
    assert_operator hurt_hp + heal, :<, body.max_hp, "staging: the deep wound must not clamp"
    pulses
    hits_on_pack
    (CFG[:cadence_ticks] - LATE).times { world.tick(Core::NullInput.new) }
    body.walker.teleport(TOTEM[0] - R, TOTEM[1])   # Chebyshev R — in range AT the edge, deep wound
    ally.walker.teleport(TOTEM[0] - 1, TOTEM[1])   # Chebyshev 1 — in range, shallow wound
    other.walker.teleport(TOTEM[0] + 1, TOTEM[1])  # in range but DEAD — vat monopoly
    (LATE - 1).times { world.tick(Core::NullInput.new) }
    world.bus.process
    assert_empty pulses, "no pulse may fire before the data cadence"
    world.tick(Core::NullInput.new)
    world.bus.process
    assert_empty hits_on_pack, "staging: a human hit the pack during the cadence — re-stage"
    assert_equal 1, pulses.length, "the pulse fires exactly at cadence_ticks"
    assert_equal TOTEM, pulses.first[:at]
    assert_equal CFG[:radius], pulses.first[:range]
    assert_equal 2, pulses.first[:healed], "two living wounded bodies in range"
    assert_equal hurt_hp + heal, body.hp, "deep wound heals exactly max(heal_min, pct) of ITS pool"
    assert_kind_of Integer, body.hp
    assert_equal ally.max_hp, ally.hp, "shallow wound clamps at max_hp"
    assert other.dead?, "the pulse never revives (vat keeps its monopoly)"
    assert_equal 0, other.hp
  end

  def test_heal_scales_with_the_healed_bodys_own_pool
    clear_guardian!
    # Stage the pack at the level cap through the same seam the harness and
    # the save use (load_progress! + sync_max_hp!): the biggest pool in the
    # game must reach the pct branch or the scale-with-pool row is dead data.
    world.progression.load_progress!(level: LEVEL_CAP, xp: 0)
    world.pack.sync_max_hp!(progression: world.progression)
    big = world.pack.living.max_by(&:max_hp)
    small = world.pack.living.min_by(&:max_hp)
    refute_equal big, small
    assert_operator expected_heal(big.max_hp), :>, CFG[:heal_min],
                    "no pool in the game (largest #{big.max_hp} at L#{LEVEL_CAP}) beats heal_min " \
                    "#{CFG[:heal_min]} at pct #{CFG[:heal_pct_max_hp]} — the scale-with-pool row is dead"
    big.walker.teleport(TOTEM[0], TOTEM[1])       # Chebyshev 0
    small.walker.teleport(TOTEM[0] - 1, TOTEM[1]) # Chebyshev 1
    (world.pack.living - [big, small]).each { |m| m.walker.teleport(TOTEM[0] + 1, TOTEM[1]) }
    big.take_hit(damage: big.max_hp / 2, attacker: small)
    small.take_hit(damage: small.max_hp / 2, attacker: big)
    settle!
    big_hurt = big.hp
    small_hurt = small.hp
    CFG[:cadence_ticks].times { world.tick(Core::NullInput.new) }
    world.bus.process
    assert_equal big_hurt + expected_heal(big.max_hp), big.hp,
                 "the large pool (#{big.max_hp}) heals its pct share"
    assert_equal small_hurt + expected_heal(small.max_hp), small.hp,
                 "the small pool (#{small.max_hp}) heals its own max(heal_min, pct) — never the big body's"
    refute_equal expected_heal(big.max_hp), expected_heal(small.max_hp),
                 "the two pools must land on DIFFERENT heals for this test to prove scaling"
    [big, small].each { |m| assert_kind_of Integer, m.hp }
  end

  def test_pulse_fires_empty_and_out_of_range_bodies_are_untouched
    clear_guardian!
    body = world.possessed
    ally, other = (world.pack.members - [body]).first(2)
    [body, ally, other].zip(CENTER) { |m, (x, y)| m.walker.teleport(x, y) }
    body.take_hit(damage: 20, attacker: ally)
    settle!
    hurt_hp = body.hp
    pulses
    # The whole pack sits TOGETHER just outside the radius field, on the
    # bridge planks (a split pack walks the map to regroup and drags
    # rusher aggro onto the bridge mid-wait — hit live cutting this test).
    dwell_then_place!({ body => [TOTEM[0] - R - 1, TOTEM[1]],       # Chebyshev R+1 — OUT
                        ally => [TOTEM[0] - R - 2, TOTEM[1]],       # Chebyshev R+2
                        other => [TOTEM[0] - R - 1, TOTEM[1] - 1] }) # Chebyshev R+1
    assert_equal 1, pulses.length, "the idle pulse still fires (discoverability law)"
    assert_equal 0, pulses.first[:healed]
    assert_equal hurt_hp, body.hp, "out-of-range body untouched"
  end

  def test_totem_timer_rides_the_digest_and_telemetry_counts_heals
    telemetry = Game::Telemetry.new(world.bus, world:)
    clear_guardian!
    body = world.possessed
    body.walker.teleport(*TOTEM) # ON the totem tile — Chebyshev 0
    body.take_hit(damage: 12, attacker: (world.pack.members - [body]).first)
    settle!
    2.times { world.tick(Core::NullInput.new) }
    group = world.digest_snapshot.find { |name, _| name == "totem.district.26.55" }
    refute_nil group, "totem timer is a gameplay-affecting countdown (digest law)"
    timer = group[1].to_h["timer"]
    assert_operator timer, :<, CFG[:cadence_ticks], "the armed timer counts down"
    (CFG[:cadence_ticks] - 2).times { world.tick(Core::NullInput.new) }
    world.bus.process
    assert_includes telemetry.summary, "TELEMETRY totem heals=1 pulses=1"
    rearmed = world.digest_snapshot.find { |name, _| name == "totem.district.26.55" }
    assert_equal CFG[:cadence_ticks], rearmed[1].to_h["timer"], "cadence re-arms after the pulse"
  end

  # Strict data (Rule 3 + no silent default): the sim refuses NAMED at boot
  # when the totem block is missing a row, carries an unknown one (the
  # retired heal_amount), or holds a non-Integer. Real World deps, only the
  # sustain block is swapped.
  def test_totem_config_refuses_missing_unknown_and_float_rows_named
    w = world
    build = lambda do |totem|
      Game::Stations.new(bus: w.bus, pack: w.pack, economy: DATA["balance/economy"],
                         sustain_cfg: { totem: }, price_sheet: nil,
                         zone: -> { "district" }, map: -> { w.map },
                         cue: ->(*) {}, refuse: ->(*) {}, regrow_binding: ->(*) {},
                         consume_mercy: ->(*) {}, assign_seats: -> {})
    end
    assert_kind_of Game::Stations, build.call(CFG), "the live rows construct"
    legacy = { cadence_ticks: 900, radius: 2, heal_amount: 10 }
    err = assert_raises(ArgumentError) { build.call(legacy) }
    assert_match(/heal_amount/, err.message, "the retired key is named")
    assert_match(/heal_min/, err.message, "the missing keys are named")
    err = assert_raises(ArgumentError) { build.call(CFG.merge(heal_pct_max_hp: 5.0)) }
    assert_match(/heal_pct_max_hp/, err.message, "a Float row is refused by name")
    err = assert_raises(ArgumentError) { build.call(CFG.merge(radius: 0)) }
    assert_match(/radius/, err.message, "a non-positive row is refused by name")
    err = assert_raises(ArgumentError) { build.call(nil) }
    assert_match(/totem block missing/, err.message)
  end
end
