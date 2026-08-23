require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v15 banner FIFO (panel fold W6): zone banners + court stamps share one
# queued slot — entries carry KEYS (locale resolves at draw), the active
# entry always plays out, nothing is eaten, the cap drops oldest-QUEUED.
class BannerQueueTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  DISPLAY = DATA["display"]

  def world = @world ||= Game::World.new(DATA)

  def drive(n)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def test_zone_entry_enqueues_keys_not_baked_text
    entry = world.active_banner
    refute_nil entry
    assert_equal "zone.nest.display_name", entry[:text_key],
                 "entries carry KEYS — locale resolves at draw (comparability law)"
    assert_equal "ZONE 1", entry[:fallback]
    assert_equal :banner, entry[:color]
  end

  def test_fifo_stamps_play_after_the_active_banner_nothing_eaten
    world.send(:enqueue_stamp, "challenger.stands.line", "BOSS 1 SPAWNED")
    assert_equal :banner, world.active_banner[:color], "the active entry is never displaced"
    drive(world.active_banner[:frames_left] + 1)
    entry = world.active_banner
    assert_equal "challenger.stands.line", entry[:text_key], "the stamp waited its turn"
    assert_equal :gold, entry[:color]
    drive(DISPLAY[:stamp_banner_frames] + 1)
    assert_nil world.active_banner, "the queue drains"
  end

  def test_cap_drops_oldest_queued_never_the_active
    %w[s1 s2 s3 s4].each { |s| world.send(:enqueue_stamp, "stamp.#{s}", s) }
    assert_equal "zone.nest.display_name", world.active_banner[:text_key]
    drive(world.active_banner[:frames_left] + 1)
    assert_equal "stamp.s3", world.active_banner[:text_key],
                 "s1/s2 (oldest queued) yielded to the cap"
    drive(DISPLAY[:stamp_banner_frames] + 1)
    assert_equal "stamp.s4", world.active_banner[:text_key]
  end

  # T3 (decision 5): entries carry an optional locale-invariant suffix,
  # appended after translation at draw — numerals never enter the flat
  # K/V string tables. Suffix-less entries carry nil (existing paths
  # untouched by construction).
  def test_stamp_suffix_persists_in_the_entry_and_zone_banners_carry_nil
    assert_nil world.active_banner[:suffix], "zone banners carry no suffix"
    world.send(:enqueue_stamp, "stamp.level_up", "LEVEL", suffix: " 2")
    drive(world.active_banner[:frames_left] + 1)
    entry = world.active_banner
    assert_equal "stamp.level_up", entry[:text_key]
    assert_equal " 2", entry[:suffix], "the suffix rides the queue intact"
    assert_equal :gold, entry[:color]
  end

  def test_display_declares_the_new_keys
    %i[chant_ring_rgb chant_ring_cycle_frames seized_underline_rgb
       nameplate_font_size stamp_banner_frames banner_queue_max].each do |k|
      refute_nil DISPLAY[k], "display.json declares #{k}"
    end
  end
end
