require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v16 (c) decision 4: located stamps (seal breach, mark void, term paid)
# ALSO land a floor SEAL MARK at the event tile. The mark lands the frame
# its banner ACTIVATES — mark and stamp share one clock from birth
# (adversarial review: an enqueue-time anchor drained marks behind a
# queued stamp), hitstop pauses both, an evicted queued stamp never
# stamps the floor. The renderer is a pure reader.
class SealMarkTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  DISPLAY = DATA["display"]
  ECO = DATA["balance/economy"]
  TOTAL = DISPLAY[:stamp_banner_frames]

  def world = @world ||= Game::World.new(DATA)

  def drive(n)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  # Drain whatever banner is active so the NEXT queue entry activates.
  def activate_next!
    drive(world.active_banner[:frames_left] + 1)
  end

  def test_located_stamp_lands_when_its_banner_activates
    world.send(:enqueue_stamp, "challenger.term.line", "THE TERM IS PAID", at: [4, 3])
    assert_empty world.seal_marks, "a QUEUED stamp has not landed yet"
    activate_next! # the zone banner plays out; the stamp takes the slot
    assert_equal "challenger.term.line", world.active_banner[:text_key]
    mark = world.seal_marks.find { |m| m[:tile] == [4, 3] }
    refute_nil mark, "the mark lands the frame its stamp activates"
    assert_equal world.active_banner[:frames_left], mark[:frames_left],
                 "mark and stamp share one clock (dwells with the banner)"
    assert_equal TOTAL, mark[:total]
  end

  def test_unlocated_stamp_leaves_no_floor_mark
    world.send(:enqueue_stamp, "challenger.stands.line", "ONE STANDS")
    activate_next!
    assert_equal "challenger.stands.line", world.active_banner[:text_key]
    assert_empty world.seal_marks
  end

  def test_evicted_queued_stamp_never_lands_an_orphan_mark
    world.send(:enqueue_stamp, "stamp.a", "A", at: [4, 3]) # queued, located
    world.send(:enqueue_stamp, "stamp.b", "B")
    world.send(:enqueue_stamp, "stamp.c", "C")             # cap evicts stamp.a
    13.times do
      drive(50) # samples every 50f — a 150f orphan could not hide between
      assert_empty world.seal_marks, "an evicted stamp never stamps the floor"
    end
  end

  def test_mark_ticks_with_its_stamp_and_expires
    world.send(:enqueue_stamp, "stamp.probe", "PROBE", at: [4, 3])
    activate_next!
    drive(3)
    assert_equal TOTAL - 4, world.seal_marks.first[:frames_left]
    assert_equal world.active_banner[:frames_left],
                 world.seal_marks.first[:frames_left], "lockstep holds mid-dwell"
    drive(TOTAL)
    assert_empty world.seal_marks
  end

  # Kills the total-drift mutant (review finding): age = total - frames_left
  # must ADVANCE — total is the fixed window, never ticked.
  def test_delivery_clock_ages_and_total_stays_fixed
    world.send(:enqueue_stamp, "stamp.probe", "PROBE", at: [4, 3])
    activate_next!
    entry = world.active_banner
    mark = world.seal_marks.first
    drive(5)
    assert_equal TOTAL, entry[:total], "entry total never ticks"
    assert_equal TOTAL, mark[:total], "mark total never ticks"
    assert_equal TOTAL - 6, entry[:frames_left], "age advances against total"
  end

  def test_marks_read_in_their_own_zone_only
    world.send(:enqueue_stamp, "stamp.probe", "PROBE", at: [4, 3])
    activate_next! # mark lands in the nest
    refute_empty world.seal_marks
    world.start_in("district")
    assert_empty world.seal_marks, "a nest mark never draws district coordinates"
    world.start_in("nest")
    refute_empty world.seal_marks, "the writ still dwells back home"
  end

  def test_seal_breach_stamps_the_station_tile_on_the_writ_window
    seal = DATA["zones/district"][:stations].find { |s| s[:type] == "seal" }
    world.possessed.walker.teleport(29, 8)
    drive(2)
    assert_equal "district", world.zone_name
    src = world.possessed
    src.walker.teleport(*seal[:at])
    (world.pack.living - [src]).each_with_index { |m, i| m.walker.teleport(2, 2 + i) }
    world.pack.bank!(ECO[:breach_cost])
    assert world.interact(src)
    mark = world.seal_marks.find { |m| m[:tile] == seal[:at] }
    refute_nil mark, "the breach is a located stamp — the court marks the seal"
    assert_equal DISPLAY[:breach_banner_frames], mark[:total],
                 "the breach mark rides the writ line's own window"
    # The breach kick hitstops the sim; hitstop pauses the mark clock like
    # every cosmetic clock (the banner law).
    hitstop = DATA["balance/combat"][:feel][:hitstop_frames_kill]
    drive(hitstop)
    assert_equal mark[:total], mark[:frames_left], "hitstop holds the mark"
    drive(2)
    assert_equal mark[:total] - 2, mark[:frames_left]
  end

  def test_banner_entries_carry_their_total_for_the_delivery_clock
    entry = world.active_banner
    refute_nil entry
    assert_equal entry[:frames_left], entry[:total],
                 "a fresh entry opens with its full window recorded"
  end

  def test_display_declares_the_stamp_delivery_keys
    %i[stamp_in_frames stamp_scale_from stamp_scale_to stamp_fade_frames
       stamp_rule_pad stamp_rule_rgb seal_mark_glyph_px].each do |k|
      refute_nil DISPLAY[k], "display.json declares #{k}"
    end
  end
end
