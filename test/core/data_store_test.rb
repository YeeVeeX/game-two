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

  # J6-B D9 (s55 probe): a crash-corrupt machine-written prefs file must
  # never brick boot — the eager loader skips it by exact key; its owner
  # (App::Prefs) reads the file directly with a lenient-NAMED decode.
  def test_machine_written_prefs_file_is_exempt_from_eager_parse
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "prefs.local.json"), "garbage{{{not json")
      File.write(File.join(dir, "display.json"), '{"locale": "en"}')
      store = Core::DataStore.new(dir)
      assert_equal ["display"], store.keys, "prefs.local never enters the store"
    end
  end

  def test_prefs_exemption_is_unconditional_not_corruption_gated
    # s55 review NIT: a VALID prefs.local.json stays out too — pins the
    # skip against a rescue-only-on-corrupt refactor that would silently
    # grow a second reader of prefs (App::Prefs owns that file).
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "prefs.local.json"), '{"locale": "es"}')
      store = Core::DataStore.new(dir)
      assert_equal [], store.keys, "valid prefs.local never enters the store either"
    end
  end

  def test_nested_same_named_files_keep_the_loud_abort
    # s55 review NIT: the exemption is exact-key (root-level prefs.local
    # only) — pins against a future basename-match refactor.
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "zones"))
      File.write(File.join(dir, "zones", "prefs.local.json"), "garbage{{{not json")
      assert_raises(JSON::ParserError) { Core::DataStore.new(dir) }
    end
  end

  def test_hand_edited_configs_keep_the_loud_parse_abort
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "bindings.local.json"), "garbage{{{not json")
      assert_raises(JSON::ParserError, "a hand-edited typo must abort loudly (bindings' law)") do
        Core::DataStore.new(dir)
      end
    end
  end

  def test_real_data_dir_loads
    store = Core::DataStore.new(File.expand_path("../../data", __dir__))
    refute_empty store.keys
  end
end
