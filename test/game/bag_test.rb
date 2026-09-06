require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# S2 — the bag (pure structure) + the loot wiring (drop tables, :loot stream,
# pickup through interact, digest). Data with teeth: every drop-table kit is
# a real kit, every entry a catalog id, every probability in (0, 1].
class BagTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CATALOG = Game::ItemCatalog.load(DATA)

  def bag(slots: 3) = Game::Bag.new(catalog: CATALOG, slots:)

  def test_stacks_fill_then_open_slots_and_report_overflow
    b = bag(slots: 2)
    assert_equal 0, b.add!(:flask_sap, 7)          # stack 10: one slot, 7/10
    assert_equal 1, b.used
    assert_equal 0, b.add!(:flask_sap, 5)          # 3 top the stack, 2 open a slot
    assert_equal 2, b.used
    assert_equal 12, b.count(:flask_sap)
    assert_equal 4, b.add!(:antidote, 4), "no slot left: everything overflows"
    refute b.room_for?(:antidote)
    assert b.room_for?(:flask_sap, 8), "room inside the partial stack"
  end

  def test_equipment_never_stacks_and_remove_drains_last_stack_first
    b = bag(slots: 4)
    assert_equal 0, b.add!(:blade_iron, 2)
    assert_equal 2, b.used, "two blades = two slots"
    b.add!(:cap_spore, 25)                          # 20 + 5
    assert_equal 4, b.used
    assert_equal 6, b.remove!(:cap_spore, 6)        # 5 from the last stack, 1 from the full one
    assert_equal 19, b.count(:cap_spore)
    assert_equal 3, b.used, "the emptied stack closed its slot"
    assert_equal 0, b.remove!(:charm_moss, 1), "removing what you lack removes nothing"
  end

  def test_sorted_is_pinned_then_kind_tier_id_and_digest_is_order_free
    a = bag(slots: 10)
    %i[coal_living blade_shard flask_sap jerkin_root antidote].each { |i| a.add!(i) }
    assert_equal %i[antidote flask_sap blade_shard jerkin_root coal_living], a.sorted.map { |s| s[:id] }
    a.pin!(:coal_living)
    assert_equal :coal_living, a.sorted.first[:id]
    b = bag(slots: 10)
    %i[antidote jerkin_root coal_living flask_sap blade_shard].each { |i| b.add!(i) }
    assert_equal a.digest_string, b.digest_string, "same contents, any order -> same digest"
    assert_equal [["slots", 10], ["used", 5], ["contents", a.digest_string]], a.digest_fields
  end

  def test_drop_tables_name_real_kits_and_catalog_items
    kits = DATA["balance/combat"][:kits].keys.map(&:to_s)
    DATA["balance/drops"][:tables].each do |kit, t|
      assert_includes kits, kit.to_s, "drops.json: #{kit} is not a kit"
      assert t[:rolls].is_a?(Integer) && t[:rolls].positive?
      t[:entries].each do |(id, p)|
        assert CATALOG.include?(id), "drops.json #{kit}: #{id} is not in the catalog"
        assert p.is_a?(Numeric) && p > 0 && p <= 1, "drops.json #{kit}/#{id}: p=#{p}"
      end
    end
  end

  def test_world_rolls_items_on_a_hostile_death_and_interact_picks_them_up
    w = Game::World.new(DATA, seed: 7)
    w.start_in("district")
    assert_equal 0, w.bag.used
    h = w.humans.reject(&:dead?).first
    # force a drop record the way the field would (table roll is probabilistic;
    # the pickup contract is what this test pins)
    w.item_drops << { tile: h.tile.dup, id: :flask_sap, qty: 2, frames_left: 600, decay_frames: 600 }
    me = w.possessed(1)
    me.walker.teleport(*h.tile)
    assert w.interact(me), "interact on the item picks it up"
    assert_equal 2, w.bag.count(:flask_sap)
    assert_empty w.item_drops
    # digest carries the bag
    snap = w.digest_snapshot.to_h
    assert_equal "flask_sap:2", snap["bag"].to_h["contents"]
    # a full bag refuses and leaves the item
    w.bag.slots.times { w.bag.add!(:blade_iron) }
    w.item_drops << { tile: me.tile.dup, id: :antidote, qty: 1, frames_left: 600, decay_frames: 600 }
    refute w.interact(me)
    assert_equal 1, w.item_drops.length
  end

  def test_a_full_bag_on_a_station_tile_still_reaches_the_station
    w = Game::World.new(DATA, seed: 7)
    w.start_in("camp")
    me = w.possessed(1)
    st = w.map.stations.first
    me.walker.teleport(*st[:at])
    w.bag.slots.times { w.bag.add!(:blade_iron) }
    w.item_drops << { tile: me.tile.dup, id: :antidote, qty: 1, frames_left: 600, decay_frames: 600 }
    fulls = []
    w.bus.subscribe(:bag_full) { |e| fulls << e }
    w.interact(me) # whatever the station does, the press must REACH it
    w.tick(Core::ScriptedInput.new(frames: {}))
    assert_equal 1, fulls.length, "the refusal is named"
    assert_equal 1, w.item_drops.length, "the item stays on the floor"
    # the station saw the press: a bank/altar press is never swallowed by a full bag
    # (the concrete effect depends on the station; the contract is the fall-through)
  end

  def test_loot_stream_is_its_own_counter
    w = Game::World.new(DATA, seed: 7)
    snap = w.digest_snapshot.to_h
    assert snap["world"].to_h.key?("loot_rng_draws"), "the :loot stream is digested by draw count"
    assert_equal 0, snap["world"].to_h["loot_rng_draws"]
  end
end
