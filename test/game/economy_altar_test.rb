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
    world.bus.process
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
    assert_equal altar_tile, world.station_cue[:at],
                 "the cue pins the transaction's own fixture tile"
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
    world.bus.process
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
