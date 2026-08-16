require_relative "../test_helper"
require "core/event_bus"
require "game/world"
require "game/telemetry"

# v15 telemetry: the thirteenth's arbiters. swap_escapes is EVENT-ORDERED
# (panel race fold) — these tests drive the bus directly (queue order IS
# the contract) with minimal actor stand-ins at the unit altitude.
class V15TelemetryTest < Minitest::Test
  Actor = Struct.new(:kit, :faction) do
    def equal?(other) = super
  end

  def bus
    @bus ||= Core::EventBus.new.register(*Game::World::EVENTS)
  end

  def telemetry = @telemetry ||= Game::Telemetry.new(bus)

  def line
    telemetry.summary.lines.find { |l| l.start_with?("TELEMETRY varekka") }
  end

  def quay_line
    telemetry.summary.lines.find { |l| l.start_with?("TELEMETRY quay") }
  end

  def test_swap_escape_counts_between_chant_start_and_terminal
    telemetry
    body = Actor.new({}, :pack)
    bus.emit(:challenger_chant_started, actor: nil, body:)
    bus.emit(:possession_changed, from: body, to: nil, forced: false)
    bus.emit(:chant_interrupted, actor: nil)
    bus.emit(:possession_changed, from: nil, to: nil, forced: false)
    bus.process
    assert_match(/chants=1 interrupted=1 .*swap_escapes=1/, line,
                 "the swap INSIDE the chant window counts; the one after does not")
  end

  def test_forced_swap_is_not_an_escape
    telemetry
    body = Actor.new({}, :pack)
    bus.emit(:vessel_seized, actor: nil, body:, frames: 450)
    bus.emit(:possession_changed, from: body, to: nil, forced: true)
    bus.emit(:seizure_ended, body:, why: :died)
    bus.process
    assert_match(/seized=1 swap_escapes=0/, line)
    assert_match(/ends\{expired=0 slain=0 died=1/, line)
  end

  def test_slain_and_deaths_while_seized
    telemetry
    varekka = Actor.new({ seize: { chant_frames: 120 } }, :human)
    body = Actor.new({}, :pack)
    bus.emit(:vessel_seized, actor: varekka, body:, frames: 450)
    bus.emit(:actor_died, actor: body, killer: varekka, faction: :pack)
    bus.emit(:seizure_ended, body:, why: :died)
    bus.emit(:actor_died, actor: varekka, killer: body, faction: :human)
    bus.process
    assert_match(/slain=1 deaths_while_seized=1/, line)
  end

  # v16 (d): burns arbitrate the fifteenth's stakes question.
  def test_inscription_burns_count_on_the_varekka_line
    telemetry
    assert_match(/burns=0/, line)
    bus.emit(:inscription_burned, body: Actor.new({}, :pack), at: [4, 3])
    bus.process
    assert_match(/deaths_while_seized=0 burns=1 ends\{/, line)
  end

  def test_quay_trip_flags_bank_after_descent
    telemetry
    bus.emit(:zone_entered, zone: "low_quay")
    bus.emit(:zone_entered, zone: "district_two")
    bus.emit(:banked, actor: nil, amount: 37, banked: 37)
    bus.emit(:banked, actor: nil, amount: 5, banked: 42)
    bus.process
    assert_match(/entries=1/, quay_line)
    assert_match(/banked_after\{events=1 amount=37\}/, quay_line,
                 "only the first bank after a quay trip counts; the flag clears")
  end

  def test_wipe_clears_the_quay_trip_flag
    telemetry
    bus.emit(:zone_entered, zone: "low_quay")
    bus.emit(:pack_wiped)
    bus.emit(:banked, actor: nil, amount: 9, banked: 9)
    bus.process
    assert_match(/banked_after\{events=0 amount=0\}/, quay_line)
  end
end
