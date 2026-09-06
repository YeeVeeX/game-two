require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# S3 — statuses as DATA (balance/status.json) + consumables that CURE them
# through the sustain key: burn is a DOT the aura ignites (ticks x dmg_per /
# interval), antidote cures poison, ember_salve cures burn, the flask stays
# the fallback. Every rule is a pure function of sim state.
class StatusTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def idle = @idle ||= Core::ScriptedInput.new(frames: {})
  def world = @world ||= Game::World.new(DATA, seed: 7)

  def test_registry_declares_every_status_with_a_tint_and_burn_has_dot_numbers
    st = DATA["balance/status"]
    %i[poison burn stone seized chill].each do |k|
      assert st[k], "status.json: #{k} missing"
      assert_equal 3, st[k][:tint].length, "#{k}: tint rgb"
      assert st[k][:icon].is_a?(String)
    end
    b = st[:burn]
    assert b[:dot] && b[:ticks].positive? && b[:dmg_per].positive? && b[:interval_frames].positive?
  end

  def test_ignite_ticks_damage_on_the_cadence_refresh_extends_and_cure_stops_it
    w = world
    w.start_in("camp")
    body = w.possessed(1)
    foe = w.humans.first
    hp0 = body.hp
    body.ignite!(ticks: 3, dmg_per: 2, interval_frames: 10, by: foe)
    assert body.burning?
    assert_includes body.statuses, :burn
    9.times { body.tick_body }
    assert_equal hp0, body.hp, "no tick before the interval"
    body.tick_body
    assert_equal hp0 - 2, body.hp, "first tick at the interval"
    body.ignite!(ticks: 5, dmg_per: 2, interval_frames: 10, by: foe)
    assert_equal 5, body.burn_ticks, "refresh extends to the longer burn, never stacks damage"
    assert body.cure!(:burn)
    refute body.burning?
    refute body.cure!(:burn), "nothing to cure twice"
    hp1 = body.hp
    20.times { body.tick_body }
    assert_equal hp1, body.hp, "cured: no more ticks"
  end

  def test_sustain_uses_a_cure_from_the_bag_before_the_flask
    w = world
    w.start_in("camp")
    body = w.possessed(1)
    foe = w.humans.first
    w.bag.add!(:antidote, 1)
    w.bag.add!(:ember_salve, 1)
    body.poison!(ticks: 5, dmg_per: 1, interval_frames: 30, by: foe)
    body.ignite!(ticks: 5, dmg_per: 1, interval_frames: 30, by: foe)
    used = []
    w.bus.subscribe(:item_used) { |e| used << [e[:item], e[:status]] }
    prov = w.pack.provisions
    assert w.sustain(body), "sustain off the bank uses a cure"
    w.tick(idle)
    assert_equal [[:antidote, :poison]], used, "poison first (status order), antidote spent"
    refute body.poisoned?
    assert body.burning?, "the burn stays for the next press"
    assert_equal 0, w.bag.count(:antidote)
    assert_equal prov, w.pack.provisions, "the flask was NOT spent"
    assert w.sustain(body)
    w.tick(idle)
    assert_equal [:ember_salve, :burn], used.last
    refute body.burning?
    assert_equal 0, w.bag.count(:ember_salve)
  end

  def test_the_aura_ignites_the_body_it_burns
    w = world
    w.start_in("ember_1")
    bearer = w.humans.find { |h| h.kit[:aura] } or skip "no aura bearer in ember_1"
    body = w.possessed(1)
    body.walker.teleport(bearer.tile[0] + 1, bearer.tile[1])
    (bearer.kit[:aura][:period_frames] + 1).times { w.tick(idle) }
    assert body.burning?, "standing in the fire ignites the burn DOT"
  end
end
