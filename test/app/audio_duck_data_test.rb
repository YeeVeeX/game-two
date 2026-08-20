require_relative "../test_helper"
require "json"

# Owner-ordered pile-up relief stays a data-only, single-lever policy:
# percussive cues make brief room in music; the approved SFX bus stays put.
class AudioDuckDataTest < Minitest::Test
  CUES_PATH = File.expand_path("../../data/audio/cues.json", __dir__)
  SHORT_MUSIC_DUCK = {
    "bus" => "music",
    "duck_db" => -4.0,
    "attack_frames" => 800,
    "hold_frames" => 2400,
    # release matches the -12 dB dramatic ducks ON PURPOSE: the engine
    # overwrites the bus's release_frames on every duck event
    # (game-two-audio audio_system.rb apply_duck), so a mismatched value
    # would let a stray hit shorten a stinger/wipe release mid-episode.
    "release_frames" => 9600
  }.freeze

  def table = @table ||= JSON.parse(File.read(CUES_PATH))

  def percussive_cues
    table.fetch("cues").select do |_id, cue|
      event = cue.fetch("event")
      event == "special_started" ||
        event.start_with?("attack_hit__", "dodged__", "projectile_fired__")
    end
  end

  def test_every_percussive_take_has_the_same_short_music_duck
    assert_equal 13, percussive_cues.length
    percussive_cues.each do |id, cue|
      assert_equal SHORT_MUSIC_DUCK, cue["duck"], "#{id} duck drifted"
    end
  end

  def test_every_music_duck_shares_one_release_length
    releases = table.fetch("cues").values.filter_map { |cue| cue.dig("duck", "release_frames") }
    assert_equal [9600], releases.uniq,
                 "mixed release lengths on one bus fight over the engine's single release slot"
  end

  def test_sfx_bus_level_remains_the_approved_value
    assert_equal(-10.0, table.dig("buses", "sfx", "volume_db"))
  end
end
