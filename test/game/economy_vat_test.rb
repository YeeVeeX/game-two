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
    world.bus.process
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
    world.bus.process
    assert ally.marked?, "vat regrowth preserves the mark (burn is judgment-only)"
  end

  def test_tribute_paid_event_shape
    ally = (world.pack.members - [world.possessed]).first
    kill(ally)
    world.pack.bank!(ECO[:regrow_cost])
    paid = []
    world.bus.subscribe(:tribute_paid) { |e| paid << e }
    world.interact(at_vat!)
    world.bus.process
    assert_equal 1, paid.length
    e = paid.first
    assert_equal ECO[:regrow_cost], e[:cost]
    assert_equal 1, e[:regrown]
    assert_equal 0, e[:healed]
    assert_equal 0, e[:banked]
  end
end
