require_relative "../test_helper"
require "json"
require "tmpdir"
require "core/input"
require_relative "../../harness/support"
require_relative "../../harness/pilot_session"

# Pure pilot-session tests: parser table, inbox file edges, recorder
# round-trip, capture indexing. Real files (mktmpdir), no gosu, no mocks.
class PilotParserTest < Minitest::Test
  def parse(line) = Harness::Pilot::Parser.parse(line)

  def test_whitelist_is_controller_actions_plus_swap
    assert_equal Game::PossessedController::ACTIONS + [:swap], Harness::Pilot::ACTIONS
  end

  def test_hold_single_action
    assert_equal({ cmd: :hold, actions: [:right], frames: 30 }, parse("hold right 30"))
  end

  def test_hold_multiple_actions_dedups
    assert_equal({ cmd: :hold, actions: %i[right attack], frames: 12 },
                 parse("hold right,attack,right 12"))
  end

  def test_press_normalizes_to_one_frame_hold
    assert_equal({ cmd: :hold, actions: [:attack], frames: 1 }, parse("press attack"))
  end

  def test_press_swap_is_legal
    assert_equal({ cmd: :hold, actions: [:swap], frames: 1 }, parse("press swap"))
  end

  def test_wait_normalizes_to_empty_hold
    assert_equal({ cmd: :hold, actions: [], frames: 600 }, parse("wait 600"))
  end

  def test_goto_defaults_guard
    assert_equal({ cmd: :goto, tile: [12, 8], guard: 3000 }, parse("goto 12 8"))
  end

  def test_goto_explicit_guard
    assert_equal({ cmd: :goto, tile: [3, 4], guard: 500 }, parse("goto 3 4 guard=500"))
  end

  def test_capture_with_and_without_label
    assert_equal({ cmd: :capture, label: nil }, parse("capture"))
    assert_equal({ cmd: :capture, label: "bank" }, parse("capture bank"))
  end

  def test_state_dump_speed_export_reset_quit
    assert_equal({ cmd: :state }, parse("state"))
    assert_equal({ cmd: :dump, name: "rusher0" }, parse("dump rusher0"))
    assert_equal({ cmd: :speed, value: 30 }, parse("speed 30"))
    assert_equal({ cmd: :export, name: nil }, parse("export"))
    assert_equal({ cmd: :export, name: "smoke" }, parse("export smoke"))
    assert_equal({ cmd: :reset, seed: nil }, parse("reset"))
    assert_equal({ cmd: :reset, seed: 42 }, parse("reset 42"))
    assert_equal({ cmd: :quit }, parse("quit"))
  end

  def test_blank_line_parses_to_nil
    assert_nil parse("")
    assert_nil parse("   ")
  end

  def test_unknown_command_errs
    assert parse("fly 3")[:err]
  end

  def test_unknown_action_errs
    assert parse("hold fly 3")[:err]
    assert parse("press teleport")[:err]
  end

  def test_bad_frames_err
    assert parse("hold right abc")[:err]
    assert parse("hold right 0")[:err]
    assert parse("hold right -5")[:err]
    assert parse("hold right")[:err]
    assert parse("wait 100001")[:err], "frames above MAX_FRAMES refuse"
    refute parse("wait 100000")[:err]
  end

  def test_speed_out_of_range_errs
    assert parse("speed 0")[:err]
    assert parse("speed 61")[:err]
    assert parse("speed abc")[:err]
    refute parse("speed 1")[:err]
    refute parse("speed 60")[:err]
  end

  def test_goto_arity_and_coord_errors
    assert parse("goto 12")[:err]
    assert parse("goto a b")[:err]
    assert parse("goto -1 5")[:err]
    assert parse("goto 1 2 3")[:err]
  end

  def test_dump_requires_name_and_capture_label_is_filename_safe
    assert parse("dump")[:err]
    assert parse("capture ../evil")[:err]
    assert parse("export a/b")[:err]
  end

  def test_extra_tokens_err
    assert parse("state now")[:err]
    assert parse("quit please")[:err]
  end
end

class PilotInboxTest < Minitest::Test
  def with_inbox
    Dir.mktmpdir do |dir|
      path = File.join(dir, "inbox.txt")
      yield path, Harness::Pilot::Inbox.new(path)
    end
  end

  def append(path, text) = File.open(path, "ab") { |f| f.write(text) }

  def test_missing_file_polls_empty
    with_inbox do |_path, inbox|
      assert_equal({ lines: [], truncated: false }, inbox.poll)
    end
  end

  def test_partial_line_held_until_newline
    with_inbox do |path, inbox|
      append(path, "hold ri")
      assert_equal [], inbox.poll[:lines]
      append(path, "ght 5\n")
      assert_equal ["hold right 5"], inbox.poll[:lines]
    end
  end

  def test_two_lines_in_one_append
    with_inbox do |path, inbox|
      append(path, "hold right 30\npress attack\n")
      assert_equal ["hold right 30", "press attack"], inbox.poll[:lines]
      assert_equal [], inbox.poll[:lines], "consumed lines never repeat"
    end
  end

  def test_crlf_stripped
    with_inbox do |path, inbox|
      append(path, "wait 5\r\n")
      assert_equal ["wait 5"], inbox.poll[:lines]
    end
  end

  def test_truncation_resets_offset_and_flags
    with_inbox do |path, inbox|
      append(path, "hold right 30\n")
      assert_equal ["hold right 30"], inbox.poll[:lines]
      File.open(path, "wb") { |f| f.write("quit\n") } # shorter rewrite
      result = inbox.poll
      assert result[:truncated], "size < offset must flag truncation"
      assert_equal ["quit"], result[:lines], "reset to 0 re-reads new content"
    end
  end
end

class PilotRecorderTest < Minitest::Test
  def test_hold_ranges_only_with_singletons_as_ranges
    rec = Harness::Pilot::Recorder.new
    [[:right], %i[right attack], [:right], [], [:attack]].each { |a| rec.record_frame(a) }
    script = rec.to_script(seed: 7, width: 960, height: 540, out_dir: "captures/x")
    assert_equal "world", script[:scenario]
    assert_equal 7, script[:seed]
    assert_equal 960, script[:width]
    assert_equal 540, script[:height]
    assert_equal "captures/x", script[:out_dir]
    assert_equal 5, script[:run_until]
    assert_equal({ right: [[0, 2]], attack: [[1, 1], [4, 4]] }, script[:hold])
    refute script.key?(:frames), "one representation: hold ranges only"
  end

  def test_capture_at_zero_frames_refuses
    rec = Harness::Pilot::Recorder.new
    assert_nil rec.note_capture, "a boot capture has no replay representation"
  end

  def test_capture_after_n_frames_exports_n_minus_1
    rec = Harness::Pilot::Recorder.new
    3.times { rec.record_frame([]) }
    assert_equal 2, rec.note_capture
    rec.record_frame([:attack])
    assert_equal 3, rec.note_capture
    assert_equal [2, 3], rec.to_script(seed: 0, width: 1, height: 1, out_dir: "x")[:captures]
  end

  def test_duplicate_capture_frame_recorded_once
    rec = Harness::Pilot::Recorder.new
    rec.record_frame([])
    2.times { rec.note_capture }
    assert_equal [0], rec.to_script(seed: 0, width: 1, height: 1, out_dir: "x")[:captures]
  end

  def test_round_trip_through_expand_script_and_scripted_input
    rec = Harness::Pilot::Recorder.new
    pattern = [[:right], %i[right attack], [], [:up], %i[up swap], [:attack], []]
    pattern.each { |a| rec.record_frame(a) }
    script = rec.to_script(seed: 0, width: 960, height: 540, out_dir: "x")
    # Faithful to rake capture: through JSON text, symbolized, expanded.
    raw = JSON.parse(JSON.generate(script), symbolize_names: true)
    input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
    pattern.each_with_index do |actions, f|
      input.update(f)
      Harness::Pilot::ACTIONS.each do |a|
        assert_equal actions.include?(a), input.down?(a), "frame #{f} action #{a}"
      end
    end
    assert_equal pattern.length, raw[:run_until]
  end
end

class PilotInputTest < Minitest::Test
  def test_scripted_input_duck
    input = Harness::Pilot::PilotInput.new
    refute input.down?(:right)
    input.set(%i[right attack])
    input.update(99) # ScriptedInput duck: harmless no-op
    assert input.down?(:right)
    assert input.down?(:attack)
    refute input.down?(:dodge)
    input.set([])
    refute input.down?(:right)
  end
end
