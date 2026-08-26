require_relative "../test_helper"
require "stringio"
require "tmpdir"
require "app/prefs"

class PrefsTest < Minitest::Test
  def with_path
    Dir.mktmpdir { |dir| yield File.join(dir, "prefs.local.json") }
  end

  def test_missing_file_uses_byte_identity_defaults
    with_path do |path|
      prefs = App::Prefs.load(path)
      assert_nil prefs.locale
      assert_nil prefs.window_scale
      refute prefs.fullscreen
      refute File.exist?(path), "loading defaults must not create machine state"
    end
  end

  def test_round_trip_writes_whole_file
    with_path do |path|
      prefs = App::Prefs.load(path)
      prefs.locale = "pt-br"
      prefs.window_scale = 2
      prefs.fullscreen = true
      loaded = App::Prefs.load(path)
      assert_equal "pt-br", loaded.locale
      assert_equal 2, loaded.window_scale
      assert loaded.fullscreen
      assert_equal({ locale: "pt-br", window_scale: 2, fullscreen: true }, loaded.to_h)
    end
  end

  def test_audio_volume_and_mute_round_trip
    with_path do |path|
      prefs = App::Prefs.load(path)
      prefs.volume_db = ["music", -12.0]
      prefs.muted = true
      loaded = App::Prefs.load(path)
      assert_equal({ "music" => -12.0 }, loaded.volumes_db)
      assert loaded.muted
      assert_equal(-12.0, JSON.parse(File.read(path)).dig("volumes_db", "music"))
    end
  end

  def test_bad_audio_values_degrade_by_entry
    with_path do |path|
      File.write(path, JSON.generate(volumes_db: { music: -6, sfx: -99, ui: "loud" },
                                     muted: "yes"))
      out = StringIO.new
      prefs = App::Prefs.load(path, out:)
      assert_equal({ "music" => -6.0 }, prefs.volumes_db)
      refute prefs.muted
      assert_includes out.string, "invalid volumes_db.sfx=-99"
      assert_includes out.string, 'invalid volumes_db.ui="loud"'
      assert_includes out.string, 'invalid muted="yes"'
    end
  end

  def test_bad_values_degrade_by_key_and_name_each_problem
    with_path do |path|
      File.write(path, JSON.generate(locale: "fr", window_scale: 9, fullscreen: "yes"))
      out = StringIO.new
      prefs = App::Prefs.load(path, out:)
      assert_nil prefs.locale
      assert_nil prefs.window_scale
      refute prefs.fullscreen
      assert_includes out.string, "invalid locale=\"fr\""
      assert_includes out.string, "invalid window_scale=9"
      assert_includes out.string, "invalid fullscreen=\"yes\""
    end
  end

  def test_invalid_json_degrades_named_and_self_heals_on_write
    with_path do |path|
      File.write(path, "{broken")
      out = StringIO.new
      prefs = App::Prefs.load(path, out:)
      assert_includes out.string, "prefs: invalid JSON"
      prefs.locale = "es"
      assert_equal "es", JSON.parse(File.read(path))["locale"]
    end
  end
end
