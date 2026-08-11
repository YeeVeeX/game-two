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
