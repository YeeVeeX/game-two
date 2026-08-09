require_relative "../test_helper"
require "core/data_store"
require "tmpdir"

class DataStoreTest < Minitest::Test
  def test_loads_json_tree_keyed_by_relative_path
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "balance"))
      File.write(File.join(dir, "balance", "combat.json"), '{"player": {"hp": 100}}')
      store = Core::DataStore.new(dir)
      assert_equal ["balance/combat"], store.keys
      assert_equal 100, store["balance/combat"][:player][:hp]
    end
  end

  def test_missing_key_raises_with_available_keys
    Dir.mktmpdir do |dir|
      store = Core::DataStore.new(dir)
      err = assert_raises(Core::DataStore::MissingKey) { store["nope"] }
      assert_match(/nope/, err.message)
    end
  end

  def test_missing_dir_raises
    assert_raises(ArgumentError) { Core::DataStore.new("/definitely/not/here") }
  end

  def test_real_data_dir_loads
    store = Core::DataStore.new(File.expand_path("../../data", __dir__))
    refute_empty store.keys
  end
end
