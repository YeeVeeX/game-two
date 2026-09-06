require_relative "../test_helper"
require "app/player_file"
require "core/data_store"
require "net/fingerprint"
require "json"
require "tmpdir"
require "fileutils"
require "stringio"

# v22 T1 piece 1 — the player identity file. Real files in tmpdirs, the
# lenient-NAMED reader (never a brick), the twin law (MACHINE_WRITTEN +
# EXCLUDED + .gitignore, mechanically), and the deterministic bot id.
class PlayerFileTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)

  def with_path
    Dir.mktmpdir do |dir|
      yield File.join(dir, "data", "player.local.json"), dir
    end
  end

  def load(path, out: StringIO.new)
    file = App::PlayerFile.load(path, out:)
    [file, out.string]
  end

  def test_first_boot_creates_a_uuid_v4_file_and_names_it_once
    with_path do |path|
      file, printed = load(path)
      assert_match App::PlayerFile::UUID_V4, file.player_id
      assert_kind_of Integer, file.created_at_ms
      assert File.exist?(path), "the file is written on first boot"
      on_disk = JSON.parse(File.read(path))
      assert_equal({ "player_id" => file.player_id, "created_at_ms" => file.created_at_ms }, on_disk)
      assert_match(/player file: created/, printed)
      again, quiet = load(path)
      assert_equal file.player_id, again.player_id, "the id is stable across boots"
      assert_equal "", quiet, "a valid file loads silently"
    end
  end

  def test_two_machines_never_share_an_id
    with_path do |a|
      with_path do |b|
        refute_equal load(a).first.player_id, load(b).first.player_id
      end
    end
  end

  def test_corrupt_file_is_backed_up_regenerated_and_named
    with_path do |path|
      FileUtils.mkdir_p(File.dirname(path))
      File.binwrite(path, "{not json")
      file, printed = load(path)
      assert_match App::PlayerFile::UUID_V4, file.player_id
      baks = Dir["#{path}.corrupt-*"]
      assert_equal 1, baks.length, "the unreadable bytes survive beside the file"
      assert_equal "{not json", File.binread(baks.first)
      assert_match(/player file: .* unreadable \(invalid JSON\)/, printed)
      assert_match(/unseated records/, printed, "the line names the consequence")
      assert_equal file.player_id, JSON.parse(File.read(path))["player_id"]
    end
  end

  def test_foreign_id_shapes_regenerate_named
    ["bot-3", "not-a-uuid", "6ba7b810-9dad-11d1-80b4-00c04fd430c8", 7, nil].each do |bad|
      with_path do |path|
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.generate({ "player_id" => bad, "created_at_ms" => 1 }))
        file, printed = load(path)
        assert_match App::PlayerFile::UUID_V4, file.player_id
        refute_equal bad, file.player_id
        assert_match(/is not a uuid v4/, printed, "#{bad.inspect}: named")
        assert_equal 1, Dir["#{path}.corrupt-*"].length, "#{bad.inspect}: backed up"
      end
    end
  end

  def test_non_object_and_empty_files_are_named_distinctly
    with_path do |path|
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "[1,2]")
      _, printed = load(path)
      assert_match(/not an object/, printed)
      File.write(path, "")
      _, printed = load(path)
      assert_match(/empty file/, printed)
    end
  end

  def test_invalid_created_at_repairs_and_keeps_the_id
    with_path do |path|
      FileUtils.mkdir_p(File.dirname(path))
      id = "0f7e2c1a-4b3d-4c2e-9a1b-1234567890ab"
      File.write(path, JSON.generate({ "player_id" => id, "created_at_ms" => "yesterday" }))
      file, printed = load(path)
      assert_equal id, file.player_id, "a valid id is never thrown away"
      assert_match(/created_at_ms invalid .*repaired, id kept/, printed)
      assert_kind_of Integer, JSON.parse(File.read(path))["created_at_ms"]
      assert_empty Dir["#{path}.corrupt-*"], "a repair is not a corruption"
    end
  end

  def test_write_failure_is_named_never_raised
    Dir.mktmpdir do |dir|
      blocker = File.join(dir, "data")
      File.write(blocker, "a file where the directory should be")
      out = StringIO.new
      file = App::PlayerFile.load(File.join(blocker, "player.local.json"), out:)
      assert_match App::PlayerFile::UUID_V4, file.player_id
      assert_match(/player file: write failed/, out.string)
    end
  end

  def test_bot_id_is_deterministic_and_disjoint_from_a_uuid
    assert_equal "bot-7", App::PlayerFile.bot_id(7)
    assert_equal "bot-7", App::PlayerFile.bot_id("7")
    assert_equal App::PlayerFile.bot_id(4242), App::PlayerFile.bot_id(4242)
    refute_match App::PlayerFile::UUID_V4, App::PlayerFile.bot_id(7)
  end

  # --- the twin law (J6-B D9 / s55), mechanically -------------------------

  def test_player_local_is_machine_written_excluded_and_gitignored
    assert_includes Core::DataStore::MACHINE_WRITTEN, "player.local"
    assert_includes Net::Fingerprint::EXCLUDED, "data/player.local.json"
    ignored = File.read(File.join(ROOT, ".gitignore")).lines.map(&:strip)
    assert_includes ignored, "data/player.local.json"
    assert_equal "data/player.local.json",
                 App::PlayerFile::DEFAULT_PATH.sub("#{ROOT}/", "").tr("\\", "/")
  end

  def test_every_machine_written_key_has_its_fingerprint_twin
    Core::DataStore::MACHINE_WRITTEN.each do |key|
      assert_includes Net::Fingerprint::EXCLUDED, "data/#{key}.json",
                      "twin law: #{key} is machine-written but enters the handshake hash"
    end
  end

  def test_data_store_skips_the_player_file_and_fingerprint_ignores_it
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "data"))
      File.write(File.join(root, "data/x.json"), '{"a":1}')
      File.write(File.join(root, "Gemfile.lock"), "GEM\n")
      before = Net::Fingerprint.tree_md5(root)
      App::PlayerFile.load(File.join(root, "data/player.local.json"), out: StringIO.new)
      assert_equal ["x"], Core::DataStore.new(File.join(root, "data")).keys,
                   "a machine-written file never enters the data store"
      assert_equal before, Net::Fingerprint.tree_md5(root),
                   "the identity file never enters the handshake hash"
    end
  end
end
