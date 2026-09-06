require_relative "../test_helper"
require "core/data_store"
require "core/binding_map"

# v15 increment 2: the rebindable-controls seam. BindingMap is engine-
# agnostic (panel fold: src/core has zero Gosu references) — the platform
# key table is INJECTED, so these tests run headless with integer codes
# (the input_test FakeBackend precedent).
class BindingMapTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  # Fake platform table: name -> integer. Superset of what data uses.
  FAKE_TABLE = {
    "A" => 1, "D" => 2, "W" => 3, "S" => 4, "J" => 5, "K" => 6, "L" => 7,
    ";" => 8, "H" => 9, "Q" => 10, "E" => 11, "F" => 12, "Space" => 13,
    "Tab" => 14, "LShift" => 15, "Up" => 16, "Down" => 17, "Left" => 18,
    "Right" => 19, "X" => 20, "U" => 21, "R" => 22, "LCtrl" => 23, "I" => 26, "B" => 27, # S2: bag key
    "RCtrl" => 24, "Escape" => 25
  }.freeze

  def fake_data(bindings, local: nil)
    d = { "bindings" => bindings }
    d["bindings.local"] = local if local
    stub = Object.new
    stub.define_singleton_method(:[]) { |k| d.fetch(k) }
    stub.define_singleton_method(:keys) { d.keys.sort }
    stub
  end

  # --- canonical load --------------------------------------------------------

  def test_loads_the_shipped_canonical_map
    map = Core::BindingMap.load(DATA, key_table: FAKE_TABLE, local: false)
    assert_equal %w[J Space], map.glyphs(:attack)
    assert_equal [5, 13], map.codes[:attack]
    assert_equal %w[Tab], map.glyphs(:swap)
    assert_equal %w[U R], map.glyphs(:sustain), "v18 decision 10: the sustain pair"
    assert_equal %w[LCtrl RCtrl], map.glyphs(:aim), "stationary aim (owner order 2026-08-20)"
    assert_equal %w[Escape], map.glyphs(:menu), "J-6 brief D2: the menu row"
    assert_equal 14, map.actions.length,
                 "seven combat actions + four directions + aim + menu + bag (S2, UI-only toggle)"
    assert_equal %w[I B], map.glyphs(:bag), "S2: the bag screen key"
  end

  def test_codes_resolve_through_the_injected_table_only
    map = Core::BindingMap.load(
      fake_data({ attack: ["X"] }), key_table: FAKE_TABLE, local: false
    )
    assert_equal [20], map.codes[:attack]
  end

  # --- local override (per-machine; whole-array replace per action) ---------

  def test_local_override_replaces_the_whole_action_array
    map = Core::BindingMap.load(
      fake_data({ attack: %w[J Space], dodge: %w[K] }, local: { attack: ["X"] }),
      key_table: FAKE_TABLE, local: true
    )
    assert_equal ["X"], map.glyphs(:attack), "whole-array replace, not element merge"
    assert_equal %w[K], map.glyphs(:dodge), "untouched actions keep canonical keys"
  end

  def test_local_false_ignores_the_local_file
    map = Core::BindingMap.load(
      fake_data({ attack: %w[J] }, local: { attack: ["X"] }),
      key_table: FAKE_TABLE, local: false
    )
    assert_equal %w[J], map.glyphs(:attack), "harness pins canonical (gate comparability law)"
  end

  # --- fail-loud validation --------------------------------------------------

  def test_unknown_key_name_raises_with_the_valid_list
    err = assert_raises(Core::BindingMap::BadBinding) do
      Core::BindingMap.load(fake_data({ attack: ["Zz"] }), key_table: FAKE_TABLE, local: false)
    end
    assert_match(/Zz/, err.message)
    assert_match(/Space/, err.message, "the message lists valid names")
  end

  def test_unknown_action_in_local_raises
    err = assert_raises(Core::BindingMap::BadBinding) do
      Core::BindingMap.load(
        fake_data({ attack: %w[J] }, local: { fly: ["X"] }),
        key_table: FAKE_TABLE, local: true
      )
    end
    assert_match(/fly/, err.message)
  end

  def test_cross_action_key_collision_raises
    err = assert_raises(Core::BindingMap::BadBinding) do
      Core::BindingMap.load(
        fake_data({ up: %w[Up W], mark: %w[W] }), key_table: FAKE_TABLE, local: false
      )
    end
    assert_match(/W/, err.message)
    assert_match(/up/, err.message)
    assert_match(/mark/, err.message, "the collision names BOTH actions")
  end

  def test_empty_action_array_raises
    assert_raises(Core::BindingMap::BadBinding) do
      Core::BindingMap.load(fake_data({ attack: [] }), key_table: FAKE_TABLE, local: false)
    end
  end

  # --- the shipped data itself ----------------------------------------------

  def test_shipped_canonical_map_has_no_collisions_and_known_names
    table = Core::BindingMap.load(DATA, key_table: FAKE_TABLE, local: false)
    table.actions.each { |a| refute_empty table.glyphs(a) }
  end
end
