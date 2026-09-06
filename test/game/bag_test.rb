require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "json"

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

  def test_a_full_bag_on_the_bank_tile_still_banks_but_never_loots_or_crosses
    w = Game::World.new(DATA, seed: 7)
    w.start_in("nest")
    me = w.possessed(1)
    bank = w.map.stations.find { |s| s[:type] == "bank" }
    me.walker.teleport(*bank[:at])
    me.pick_up(7) # carrying value to bank
    w.bag.slots.times { w.bag.add!(:blade_iron) }
    w.item_drops << { tile: me.tile.dup, id: :antidote, qty: 1, frames_left: 600, decay_frames: 600 }
    fulls = []
    banked = []
    w.bus.subscribe(:bag_full) { |e| fulls << e }
    w.bus.subscribe(:banked) { |e| banked << e }
    before = w.pack.banked
    w.interact(me)
    w.tick(Core::ScriptedInput.new(frames: {}))
    assert_equal 1, fulls.length, "the refusal is named"
    assert_equal 1, w.item_drops.length, "the item stays on the floor"
    assert_equal 1, banked.length, "the press REACHED the bank (proved by its event)"
    assert_equal before + 7, w.pack.banked, "and banked the carried value"
    # off a station, a refused pickup does NOT fall through to a corpse load or a rope
    w2 = Game::World.new(DATA, seed: 7)
    w2.start_in("nest")
    me2 = w2.possessed(1)
    w2.bag.slots.times { w2.bag.add!(:blade_iron) }
    w2.item_drops << { tile: me2.tile.dup, id: :antidote, qty: 1, frames_left: 600, decay_frames: 600 }
    # inject through the field's own store (corpse_loads(zone) returns a fresh [] for an unseen zone)
    loads = w2.instance_variable_get(:@field).instance_variable_get(:@corpse_loads)
    (loads[w2.zone_name] ||= []) << { tile: me2.tile.dup, id: 999_001, amount: 5, settle_left: 0, settle_alpha: 1.0, term_left: 100, term: 100 }
    assert_equal 1, w2.corpse_loads.length, "staging: the load is in the field"
    refute w2.interact(me2), "refused pickup: press consumed, nothing else fires"
    assert_equal 1, w2.corpse_loads.length, "the corpse load was NOT looted by a refused pickup"
  end

  # S1 landing (T1 schema 3, key `bag`, default `[]`): canonical, order-free, strict.
  def test_to_save_is_canonical_and_the_empty_bag_is_the_t1_default
    assert_equal [], bag.to_save, "spec §T1: `bag []` is the record default"
    a = bag(slots: 4)
    a.add!(:flask_sap, 12)      # two stacks (10 + 2)
    a.add!(:antidote, 1)
    b = bag(slots: 4)
    b.add!(:antidote, 1)
    b.add!(:flask_sap, 2)
    b.add!(:flask_sap, 10)      # same contents, other pickup order, other stack split
    expected = [{ "id" => "antidote", "qty" => 1 }, { "id" => "flask_sap", "qty" => 12 }]
    assert_equal expected, a.to_save
    assert_equal a.to_save, b.to_save, "layout is derived, never saved: same contents = same bytes"
    assert_equal JSON.generate(a.to_save), JSON.generate(JSON.parse(JSON.generate(a.to_save))), "JSON round-trip stable"
  end

  def test_from_save_round_trips_the_digest_raises_on_corruption_and_clamps_churn
    a = bag(slots: 4)
    a.add!(:flask_sap, 12)
    a.add!(:antidote, 1)
    back = Game::Bag.from_save(JSON.parse(JSON.generate(a.to_save)), catalog: CATALOG, slots: 4)
    assert_equal a.digest_string, back.digest_string, "digest survives save/load"
    assert_equal 12, back.count(:flask_sap)
    assert_equal 3, back.used, "12 flasks (stack 10) + 1 antidote = 3 stacks, laid out again by add!"
    assert_equal a.to_save, back.to_save
    # SHAPE = corruption -> ArgumentError -> the character validator refuses the record
    corrupt = ->(list) { Game::Bag.from_save(list, catalog: CATALOG, slots: 2) }
    assert_raises(ArgumentError) { corrupt.call("nope") }
    assert_raises(ArgumentError) { corrupt.call([{ "id" => "flask_sap" }]) }
    assert_raises(ArgumentError) { corrupt.call([{ "id" => "flask_sap", "qty" => 1.5 }]) }
    assert_raises(ArgumentError) { corrupt.call([{ "id" => :flask_sap, "qty" => 1 }]) }
    # VALUE drift = churn -> clamp with a printed line (P3 law: a retune never bricks a save)
    lines = []
    churn = ->(list, slots) { Game::Bag.from_save(list, catalog: CATALOG, slots:, on_drop: ->(m) { lines << m }) }
    b = churn.call([{ "id" => "sword_of_lore", "qty" => 1 }, { "id" => "flask_sap", "qty" => 3 }], 2)
    assert_equal [{ "id" => "flask_sap", "qty" => 3 }], b.to_save, "a retired item is dropped, the rest loads"
    b = churn.call([{ "id" => "flask_sap", "qty" => 21 }], 2)
    assert_equal 20, b.count(:flask_sap), "bag_slots lowered to 2 (x10): what fits stays, the rest is dropped"
    b = churn.call([{ "id" => "flask_sap", "qty" => 0 }, { "id" => "antidote", "qty" => 1 }, { "id" => "antidote", "qty" => 2 }], 4)
    assert_equal [{ "id" => "antidote", "qty" => 3 }], b.to_save, "qty 0 dropped; duplicates merged"
    assert_equal 4, lines.length, lines.inspect
    assert lines.all? { |l| l.start_with?("save: ") }, "every clamp prints a save: line, like level/xp/hp"
    assert_equal [], Game::Bag.from_save([], catalog: CATALOG, slots: 2).to_save
  end

  # S1 LANDED on T1 (2026-09-06): the bag rides the host character record.
  def test_bag_survives_save_and_load_through_the_host_character_record
    w = Game::World.new(DATA, seed: 3)
    w.bag.add!(:flask_sap, 12)
    w.bag.add!(:antidote, 2)
    facts = Game::SaveState.facts(w)
    assert_equal w.bag.to_save, facts["characters"].fetch(w.party.host_id).fetch("bag"),
                 "the host record carries the bag's canonical form"
    w2 = Game::World.new(DATA, seed: 99, save: facts)
    assert_equal w.bag.digest_string, w2.bag.digest_string, "contents survive the round trip"
    assert_equal w.bag.used, w2.bag.used, "layout is re-derived by add! in canonical order"
    assert_equal facts, Game::SaveState.facts(w2), "facts of a loaded world are the same facts (idempotent)"
    assert_equal [], Game::World.new(DATA, seed: 3).bag.to_save, "a fresh world starts with the empty record default"
  end

  def test_loot_stream_is_its_own_counter
    w = Game::World.new(DATA, seed: 7)
    snap = w.digest_snapshot.to_h
    assert snap["world"].to_h.key?("loot_rng_draws"), "the :loot stream is digested by draw count"
    assert_equal 0, snap["world"].to_h["loot_rng_draws"]
  end
end
