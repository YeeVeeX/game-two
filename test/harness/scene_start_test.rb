require_relative "../test_helper"
require "json"
require "core/input"
require_relative "../../harness/support"
require_relative "../../harness/pilot_session"

# The v15 `start` script parameter: a focused-scene primitive (same class
# as `scenario`/`seed`) that lets a wall script begin with banked value so
# the gate replay exercises seals/Varekka without a two-hour farm prologue.
# It touches harness plumbing only — no game balance lives here.
class SceneStartTest < Minitest::Test
  def world
    data = Core::DataStore.new(File.expand_path("../../data", __dir__))
    Game::World.new(data, seed: 7)
  end

  def test_apply_start_banks_the_declared_amount
    w = world
    Harness.apply_start(w, { banked: 240 })
    assert_equal 240, w.pack.banked
  end

  def test_apply_start_with_nil_is_a_no_op
    w = world
    Harness.apply_start(w, nil)
    assert_equal 0, w.pack.banked
  end

  def test_apply_start_without_banked_key_is_a_no_op
    w = world
    Harness.apply_start(w, {})
    assert_equal 0, w.pack.banked
  end

  def test_apply_start_with_zone_relocates_the_pack_to_that_spawn
    w = world
    Harness.apply_start(w, { zone: "low_quay" })
    assert_equal "low_quay", w.zone_name
    spawn = w.map.pack_spawn
    assert_equal spawn.sort, w.pack.members.map(&:tile).sort
  end

  def test_apply_start_with_zone_and_banked_applies_both
    w = world
    Harness.apply_start(w, { banked: 240, zone: "low_quay" })
    assert_equal 240, w.pack.banked
    assert_equal "low_quay", w.zone_name
  end

  def test_apply_start_with_unknown_zone_raises
    w = world
    assert_raises(ArgumentError) { Harness.apply_start(w, { zone: "nowhere" }) }
  end

  # v16 (d): staging the burn beat — the Low Quay is stationless (owner
  # fork), so a duel scene cannot inscribe in-run; the start param carries
  # it (same body mutation the altar performs, harness plumbing only).
  def test_apply_start_with_inscribed_marks_the_possessed
    w = world
    Harness.apply_start(w, { zone: "low_quay", inscribed: true })
    assert w.possessed.marked?, "the possessed carries the god-mark at scene start"
  end

  def test_apply_start_without_inscribed_leaves_no_mark
    w = world
    Harness.apply_start(w, { zone: "low_quay" })
    refute w.possessed.marked?
  end

  def test_recorder_export_carries_start_through
    r = Harness::Pilot::Recorder.new
    r.record_frame([])
    script = r.to_script(seed: 7, width: 640, height: 360,
                         out_dir: "captures/x", start: { banked: 240 })
    assert_equal({ banked: 240 }, script[:start])
  end

  def test_recorder_export_omits_start_when_nil
    r = Harness::Pilot::Recorder.new
    r.record_frame([])
    script = r.to_script(seed: 7, width: 640, height: 360,
                         out_dir: "captures/x", start: nil)
    refute script.key?(:start)
  end
end
