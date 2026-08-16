require_relative "../test_helper"
require "core/event_bus"

class EventBusTest < Minitest::Test
  def setup
    @bus = Core::EventBus.new.register(:damage_dealt, :entity_died)
  end

  def test_emit_is_queued_until_process
    seen = []
    @bus.subscribe(:damage_dealt) { |e| seen << e[:amount] }
    @bus.emit(:damage_dealt, amount: 5)
    assert_empty seen
    @bus.process
    assert_equal [5], seen
  end

  def test_events_emitted_during_flush_run_in_same_flush
    order = []
    @bus.subscribe(:damage_dealt) do |_e|
      order << :damage
      @bus.emit(:entity_died, id: 1)
    end
    @bus.subscribe(:entity_died) { |_e| order << :died }
    @bus.emit(:damage_dealt, amount: 99)
    @bus.process
    assert_equal %i[damage died], order
  end

  def test_unknown_event_raises_on_emit_and_subscribe
    assert_raises(Core::EventBus::UnknownEvent) { @bus.emit(:typo_event) }
    assert_raises(Core::EventBus::UnknownEvent) { @bus.subscribe(:typo_event) {} }
  end

  # v17 digest lane: the whitelist is enumerable so Net::StateDigest can
  # subscribe to EVERY registered event (spec decision 6).
  def test_registered_types_lists_the_whitelist_in_registration_order
    assert_equal %i[damage_dealt entity_died], @bus.registered_types
    @bus.register(:later_event)
    assert_equal %i[damage_dealt entity_died later_event], @bus.registered_types
  end

  def test_unsubscribe_stops_delivery
    seen = []
    cb = @bus.subscribe(:damage_dealt) { |e| seen << e[:amount] }
    @bus.unsubscribe(:damage_dealt, cb)
    @bus.emit(:damage_dealt, amount: 1)
    @bus.process
    assert_empty seen
  end
end
