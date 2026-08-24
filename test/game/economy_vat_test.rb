require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/price_sheet"

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

  # B4 rewrite: a fresh world opens AT the home vat (HOME_ZONE = nest), so
  # the old short-refusal scenario is exactly the mercy context now — the
  # unconditional-refusal law survives at FIELD vats (slow_door: has a vat,
  # not a hub, so entering it never rehomes and mercy never applies).
  def test_tribute_refuses_when_short_at_a_field_vat_without_any_mutation
    world.start_in("slow_door")
    ally = (world.pack.members - [world.possessed]).first
    kill(ally)
    world.pack.bank!(ECO[:regrow_cost] - 1)
    refute world.interact(at_vat!)
    assert ally.dead?
    assert_equal ECO[:regrow_cost] - 1, world.pack.banked
    assert_equal :refused, world.station_cue[:kind]
  end

  def test_mercy_first_home_regrow_charges_only_what_the_pack_has
    ally = (world.pack.members - [world.possessed]).first
    kill(ally)
    world.pack.bank!(5) # < regrow_cost: pre-B4 this refused (the session-open farm pain)
    assert world.interact(at_vat!), "session-open first regrow at home must never refuse on money"
    world.bus.process
    refute ally.dead?
    assert_equal 0, world.pack.banked, "mercy at pct=100 takes everything they have, no more"
    assert_equal :tribute, world.station_cue[:kind]
  end

  def test_mercy_is_consumed_by_the_sessions_first_regrow
    ally = (world.pack.members - [world.possessed]).first
    kill(ally)
    world.pack.bank!(5)
    assert world.interact(at_vat!)
    world.bus.process
    kill(ally)
    world.pack.bank!(3)
    refute world.interact(at_vat!), "mercy is once per session — the second short regrow refuses"
    assert ally.dead?
    assert_equal 3, world.pack.banked
    assert_equal :refused, world.station_cue[:kind]
  end

  def test_mercy_does_not_discount_an_affordable_tribute
    ally = (world.pack.members - [world.possessed]).first
    kill(ally)
    world.pack.bank!(ECO[:regrow_cost] + 7)
    assert world.interact(at_vat!)
    world.bus.process
    assert_equal 7, world.pack.banked,
                 "an affordable first regrow pays FULL price — mercy is a floor, not a discount"
  end

  def test_mercy_ignores_a_heal_only_shortfall
    other = (world.pack.members - [world.possessed]).first
    other.take_hit(damage: 10, attacker: world.possessed)
    world.pack.bank!(ECO[:heal_cost_per_body] - 1)
    refute world.interact(at_vat!), "no dead bodies = no mercy — a short heal-only tribute refuses"
    assert_equal ECO[:heal_cost_per_body] - 1, world.pack.banked
  end

  def test_station_price_quotes_the_mercy_price_at_home_when_short
    ally = (world.pack.members - [world.possessed]).first
    kill(ally)
    world.pack.bank!(5)
    vat = world.map.stations.find { |s| s[:type] == "vat" }
    assert_equal 5, world.station_price(vat),
                 "the hint must show what the vat will actually charge (quote = charge, one source)"
  end

  def test_mercy_floor_spend_pct_knob_scales_the_clamp
    sheet = Game::PriceSheet.new(
      economy: { regrow_cost: 12, heal_cost_per_body: 2, mercy_floor_spend_pct: 50 },
      pack: world.pack, breached: ->(_z, _o) { false }, mercy: ->(_z) { true }
    )
    ally = (world.pack.members - [world.possessed]).first
    kill(ally)
    world.pack.bank!(9)
    quote = sheet.vat_quote("camp")
    assert quote[:mercy]
    assert_equal 4, quote[:cost], "pct=50 of banked 9 = 4 (integer floor) — the data knob scales mercy's bite"
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
