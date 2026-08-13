require_relative "../test_helper"
require "core/event_bus"
require "game/telemetry"

class TelemetryTest < Minitest::Test
  # All events Telemetry subscribes to (D1 + A2), for test bus registration.
  ALL_TELEMETRY_EVENTS = %i[
    corpse_loaded corpse_looted carried_lost pack_wiped banked fight_resolved
    human_retargeted human_leashed actor_died drop_spawned
    inscribed banked_spent mark_consumed body_dissolved body_regrown
    tribute_paid vessel_kept human_respawned
  ].freeze

  def test_counts_and_formats_the_session_line
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    t = Game::Telemetry.new(bus)
    2.times { bus.emit(:corpse_loaded, amount: 1) }
    bus.emit(:pack_wiped)
    bus.emit(:corpse_looted, amount: 1)
    bus.emit(:banked, amount: 3, banked: 3)
    bus.emit(:fight_resolved, opened_by: :combat, net: -4)
    bus.emit(:fight_resolved, opened_by: :recovery, net: 4)
    bus.process
    expected_d1 = "TELEMETRY d1_fired carrying_deaths=2 wipes=1 corpse_looted=1 " \
                  "carried_lost=0 banked_events=1 fights=2 recovery_fights=1 " \
                  "negative_fights=1"
    expected_a2 = "TELEMETRY a2_fired wipes=1 body_deaths=0 " \
                  "retargets{hate=0 lowhp=0 proximity=0 acquired=0} " \
                  "leashes=0 deepest_band=0 banked=1"
    expected_d1b = "TELEMETRY d1b_fired inscriptions=0 marks_consumed=0 " \
                   "dissolved=0 regrown=0 tributes=0 floor_fired=0 " \
                   "banked_spent{inscribe=0 tribute=0} banked_end=3"
    expected_q6 = "TELEMETRY q6_cadence banks{n=1 mean=3 max=3} " \
                  "kills_by_band{b0=0 b1=0 b2=0}"
    expected_density = "TELEMETRY density pockets{mean=0.0 max=0} " \
                       "arrivals{pocket=0 seed=0 home=0} singles_pct=0"
    assert_equal "#{expected_d1}\n#{expected_a2}\n#{expected_d1b}\n" \
                 "#{expected_q6}\n#{expected_density}",
                 t.summary
  end

  # --- A2 telemetry line ---

  def test_a2_counts_retargets_by_cause
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    t = Game::Telemetry.new(bus)
    bus.emit(:human_retargeted, actor: nil, from: nil, to: nil, cause: :hate)
    bus.emit(:human_retargeted, actor: nil, from: nil, to: nil, cause: :hate)
    bus.emit(:human_retargeted, actor: nil, from: nil, to: nil, cause: :lowhp)
    bus.emit(:human_retargeted, actor: nil, from: nil, to: nil, cause: :proximity)
    bus.emit(:human_retargeted, actor: nil, from: nil, to: nil, cause: :acquired)
    bus.emit(:human_retargeted, actor: nil, from: nil, to: nil, cause: :acquired)
    # :taunt and :sticky causes exist but are NOT counted in the a2 line
    bus.emit(:human_retargeted, actor: nil, from: nil, to: nil, cause: :taunt)
    bus.emit(:human_retargeted, actor: nil, from: nil, to: nil, cause: :sticky)
    bus.process
    assert_equal "TELEMETRY a2_fired wipes=0 body_deaths=0 " \
                 "retargets{hate=2 lowhp=1 proximity=1 acquired=2} " \
                 "leashes=0 deepest_band=0 banked=0", t.a2_summary
  end

  def test_a2_counts_leashes_and_body_deaths
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    victim = Struct.new(:faction).new(:pack)
    t = Game::Telemetry.new(bus)
    bus.emit(:human_leashed, actor: nil, tile: [5, 5], hp: 30)
    bus.emit(:human_leashed, actor: nil, tile: [10, 3], hp: 10)
    bus.emit(:actor_died, actor: victim, killer: nil, faction: :pack)
    bus.emit(:actor_died, actor: victim, killer: nil, faction: :pack)
    # human-faction death should NOT count as body_deaths
    human_victim = Struct.new(:faction).new(:human)
    bus.emit(:actor_died, actor: human_victim, killer: nil, faction: :human)
    bus.emit(:pack_wiped)
    bus.emit(:banked, amount: 5)
    bus.emit(:banked, amount: 3)
    bus.process
    assert_equal "TELEMETRY a2_fired wipes=1 body_deaths=2 " \
                 "retargets{hate=0 lowhp=0 proximity=0 acquired=0} " \
                 "leashes=2 deepest_band=0 banked=2", t.a2_summary
  end

  def test_a2_deepest_band_from_drop_spawned
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    # duck-type world: gate_distance(tile) and map.drop_gradient
    mock_map = Struct.new(:drop_gradient).new([[0, 1.0], [14, 1.5], [28, 2.0]])
    world_obj = Object.new
    world_obj.define_singleton_method(:gate_distance) { |tile| tile[0] + tile[1] }
    world_obj.define_singleton_method(:map) { mock_map }

    t = Game::Telemetry.new(bus, world: world_obj)
    bus.emit(:drop_spawned, tile: [5, 3], amount: 1)   # distance 8  -> band 0
    bus.emit(:drop_spawned, tile: [10, 6], amount: 1)  # distance 16 -> band 1
    bus.emit(:drop_spawned, tile: [20, 10], amount: 2) # distance 30 -> band 2
    bus.emit(:drop_spawned, tile: [7, 8], amount: 1)   # distance 15 -> band 1
    bus.process
    assert_equal "TELEMETRY a2_fired wipes=0 body_deaths=0 " \
                 "retargets{hate=0 lowhp=0 proximity=0 acquired=0} " \
                 "leashes=0 deepest_band=2 banked=0", t.a2_summary
  end

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

  # --- D1b telemetry line (FN-3) ---

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

  # --- Q6 cadence line (v10.1 retune oracle) ---

  def test_q6_line_tracks_bank_sizes_and_kills_by_band
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    mock_map = Struct.new(:drop_gradient).new([[0, 1.0], [14, 1.5], [28, 2.0]])
    world_obj = Object.new
    world_obj.define_singleton_method(:gate_distance) { |tile| tile[0] + tile[1] }
    world_obj.define_singleton_method(:map) { mock_map }
    t = Game::Telemetry.new(bus, world: world_obj)

    victim_b0 = Struct.new(:faction, :tile).new(:human, [5, 3])    # dist 8  -> band 0
    victim_b2 = Struct.new(:faction, :tile).new(:human, [20, 10])  # dist 30 -> band 2
    pack_body = Struct.new(:faction, :tile).new(:pack, [20, 10])   # ignored

    bus.emit(:actor_died, actor: victim_b0, killer: nil, faction: :human)
    bus.emit(:actor_died, actor: victim_b2, killer: nil, faction: :human)
    bus.emit(:actor_died, actor: victim_b2, killer: nil, faction: :human)
    bus.emit(:actor_died, actor: pack_body, killer: nil, faction: :pack)
    bus.emit(:banked, actor: nil, amount: 10, banked: 10)
    bus.emit(:banked, actor: nil, amount: 22, banked: 32)
    bus.process

    line = t.q6_summary
    assert_match(/TELEMETRY q6_cadence/, line)
    assert_match(/banks\{n=2 mean=16 max=22\}/, line)
    assert_match(/kills_by_band\{b0=1 b1=0 b2=2\}/, line)
  end

  def test_q6_line_with_no_world_shows_zero_bands
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    t = Game::Telemetry.new(bus)
    bus.emit(:banked, actor: nil, amount: 5, banked: 5)
    bus.process
    assert_match(/banks\{n=1 mean=5 max=5\}/, t.q6_summary)
    assert_match(/kills_by_band\{b0=0 b1=0 b2=0\}/, t.q6_summary)
  end

  def test_q6_line_appears_in_full_summary
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    t = Game::Telemetry.new(bus)
    bus.process
    assert_match(/q6_cadence/, t.summary)
  end

  # --- density line (v11 re-massing oracle) ---

  def test_density_line_counts_arrivals_and_samples_pockets
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    pockets = [%i[a b c], %i[d]]
    world_obj = Object.new
    world_obj.define_singleton_method(:density_pockets) { pockets }
    t = Game::Telemetry.new(bus, world: world_obj)
    bus.emit(:human_respawned, actor: nil, tile: [1, 1], anchor: :pocket)
    bus.emit(:human_respawned, actor: nil, tile: [2, 2], anchor: :pocket)
    bus.emit(:human_respawned, actor: nil, tile: [3, 3], anchor: :seed)
    bus.emit(:human_respawned, actor: nil, tile: [4, 4], anchor: :home)
    bus.process
    assert_equal "TELEMETRY density pockets{mean=2.0 max=3} " \
                 "arrivals{pocket=2 seed=1 home=1} singles_pct=50",
                 t.density_summary
  end

  # Zero arrivals: the line still prints, all-zero — its PRESENCE is the
  # subscriber-alive proof (spec: absence = broken subscriber, and a
  # zero-arrival session routes as unexercised, never as a defect).
  def test_density_line_zero_arrivals_still_prints_all_zero
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    t = Game::Telemetry.new(bus)
    bus.process
    assert_equal "TELEMETRY density pockets{mean=0.0 max=0} " \
                 "arrivals{pocket=0 seed=0 home=0} singles_pct=0",
                 t.density_summary
  end

  def test_density_arrivals_count_without_a_world
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    t = Game::Telemetry.new(bus)
    bus.emit(:human_respawned, actor: nil, tile: [1, 1], anchor: :seed)
    bus.process
    assert_match(/arrivals\{pocket=0 seed=1 home=0\}/, t.density_summary)
    assert_match(/pockets\{mean=0.0 max=0\}/, t.density_summary)
  end

  def test_density_line_appears_in_full_summary
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    t = Game::Telemetry.new(bus)
    bus.process
    assert_match(/TELEMETRY density/, t.summary)
  end
end
