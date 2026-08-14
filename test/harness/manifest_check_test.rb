require_relative "../test_helper"
require "json"
require "tmpdir"
require "game/world"
require_relative "../../harness/manifest_check"

# v15 manifest checker (panel fold: harness tooling gets tests — the
# pilot_roundtrip precedent). Its correctness is load-bearing for the
# wall: a parsing bug means false passes (missed desyncs) or false fails.
class ManifestCheckTest < Minitest::Test
  def with_files(script_hash, log_text)
    Dir.mktmpdir do |dir|
      script = File.join(dir, "s.json")
      log = File.join(dir, "g.log")
      File.write(script, JSON.generate(script_hash))
      File.write(log, log_text)
      yield script, log
    end
  end

  LOG = <<~LOG
    ruby -Isrc harness/replay_runner.rb x
    EVENT banked frame=100 amount=4
    EVENT drop_picked_up frame=120 amount=2
    EVENT banked frame=900 amount=2
    captured captures/x/frame_0100.png
    EVENT vessel_seized frame=1200 body=goret
    REPLAY_DONE
  LOG

  def test_sufficient_events_pass
    with_files({ "manifest" => { "banked" => 2, "vessel_seized" => 1 } }, LOG) do |s, l|
      status, detail = Harness::ManifestCheck.run(s, l)
      assert_equal :pass, status
      assert_includes detail, "banked=2"
    end
  end

  def test_shortfall_fails_naming_the_event
    with_files({ "manifest" => { "banked" => 3 } }, LOG) do |s, l|
      status, detail = Harness::ManifestCheck.run(s, l)
      assert_equal :fail, status
      assert_match(/banked: want >=3.*got 2/, detail.first)
    end
  end

  def test_missing_event_counts_as_zero
    with_files({ "manifest" => { "tribute_paid" => 1 } }, LOG) do |s, l|
      status, detail = Harness::ManifestCheck.run(s, l)
      assert_equal :fail, status
      assert_match(/tribute_paid: want >=1.*got 0/, detail.first)
    end
  end

  def test_script_without_manifest_is_skipped_not_failed
    with_files({ "frames" => {} }, LOG) do |s, l|
      status, = Harness::ManifestCheck.run(s, l)
      assert_equal :skip, status
    end
  end

  def test_parser_matches_the_world_scene_line_format_only
    # A telemetry line mentioning an event name must not count as the event.
    noisy = LOG + "TELEMETRY varekka seized=9 vessel_seized=9\nEVENTS banked frame=1\n"
    with_files({ "manifest" => { "vessel_seized" => 2 } }, noisy) do |s, l|
      status, detail = Harness::ManifestCheck.run(s, l)
      assert_equal :fail, status, "only real EVENT lines count"
      assert_match(/got 1/, detail.first)
    end
  end

  def test_every_shipped_script_manifest_names_registered_events
    events = Game::World::EVENTS.map(&:to_s)
    Dir[File.expand_path("../../harness/scripts/*.json", __dir__)].each do |path|
      manifest = JSON.parse(File.read(path))["manifest"]
      next unless manifest
      manifest.each_key do |ev|
        assert_includes events, ev,
                        "#{File.basename(path)} manifest names unregistered event #{ev}"
      end
    end
  end
end
