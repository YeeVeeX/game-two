require_relative "../test_helper"
require "core/event_bus"
require "game/telemetry"

class TelemetryTest < Minitest::Test
  # All events Telemetry subscribes to (D1 + A2), for test bus registration.
  ALL_TELEMETRY_EVENTS = %i[
    corpse_loaded corpse_looted carried_lost pack_wiped banked fight_resolved
    human_retargeted human_leashed actor_died drop_spawned
  ].freeze

  def test_counts_and_formats_the_session_line
    bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
    t = Game::Telemetry.new(bus)
    2.times { bus.emit(:corpse_loaded, amount: 1) }
    bus.emit(:pack_wiped)
    bus.emit(:corpse_looted, amount: 1)
    bus.emit(:banked, amount: 3)
    bus.emit(:fight_resolved, opened_by: :combat, net: -4)
    bus.emit(:fight_resolved, opened_by: :recovery, net: 4)
    bus.process
    expected_d1 = "TELEMETRY d1_fired carrying_deaths=2 wipes=1 corpse_looted=1 " \
                  "carried_lost=0 banked_events=1 fights=2 recovery_fights=1 " \
                  "negative_fights=1"
    expected_a2 = "TELEMETRY a2_fired wipes=1 body_deaths=0 " \
                  "retargets{hate=0 lowhp=0 proximity=0 acquired=0} " \
                  "leashes=0 deepest_band=0 banked=1"
    assert_equal "#{expected_d1}\n#{expected_a2}", t.summary
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
end
