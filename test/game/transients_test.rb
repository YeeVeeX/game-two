require_relative "../test_helper"
require "game/transients"

class TransientsTest < Minitest::Test
  def transients(pop_frames: 3) = Game::Transients.new(pop_frames:)

  def test_combat_clock_ages_pulses_and_pops_through_rejection
    records = transients(pop_frames: 2)
    records.taunt_pulse!(tile: [1, 2], pulse_frames: 2, range_tiles: 9)
    records.kill_pop!(tile: [3, 4], frame: 5)

    records.tick_combat!
    assert_equal 1, records.taunt_pulses.first[:frames_left]
    assert_equal 1, records.kill_pops.first[:frames_left]

    records.tick_combat!
    assert_empty records.taunt_pulses
    assert_empty records.kill_pops
  end

  def test_banner_clock_ages_only_seal_marks
    records = transients
    records.taunt_pulse!(tile: [1, 2], pulse_frames: 3, range_tiles: 9)
    records.level_up_pop!(tile: [3, 4], frame: 5)
    records.seal_mark!(at: [4, 5], frames: 1)

    records.tick_banner_clock!

    assert_equal 3, records.taunt_pulses.first[:frames_left]
    assert_equal 3, records.level_up_pops.first[:frames_left]
    assert_empty records.seal_marks
  end

  def test_clear_removes_every_record_kind
    records = transients
    records.taunt_pulse!(tile: [1, 2], pulse_frames: 3, range_tiles: 9)
    records.kill_pop!(tile: [3, 4], frame: 5)
    records.seal_mark!(at: [4, 5], frames: 6)
    records.level_up_pop!(tile: [6, 7], frame: 8)

    records.clear!

    assert_empty records.taunt_pulses
    assert_empty records.kill_pops
    assert_empty records.seal_marks
    assert_empty records.level_up_pops
  end

  def test_kill_pop_uses_configured_frames_and_deterministic_phase
    records = transients(pop_frames: 37)
    records.kill_pop!(tile: [4, 5], frame: 11)
    records.kill_pop!(tile: [4, 5], frame: 11)

    expected_phase = (4 * 31 + 5 * 17 + 11) % 997
    records.kill_pops.each do |pop|
      assert_equal 37, pop[:frames_left]
      assert_equal 37, pop[:pop_frames]
      assert_equal expected_phase, pop[:phase]
    end
  end

  # T3: the level-up pop mirrors the kill pop record exactly (same phase
  # seed, same configured lifetime) and ages on the COMBAT clock through
  # rejection — hitstop and the wipe veil pause it like any combat record.
  def test_level_up_pop_mirrors_kill_pop_shape_and_ages_through_rejection
    records = transients(pop_frames: 2)
    records.level_up_pop!(tile: [4, 5], frame: 11)

    pop = records.level_up_pops.first
    assert_equal [4, 5], pop[:tile]
    assert_equal 2, pop[:frames_left]
    assert_equal 2, pop[:pop_frames]
    assert_equal (4 * 31 + 5 * 17 + 11) % 997, pop[:phase]

    records.tick_combat!
    assert_equal 1, records.level_up_pops.first[:frames_left]
    records.tick_combat!
    assert_empty records.level_up_pops
  end
end
