require_relative "../test_helper"
require "json"
require "core/input"
require_relative "../../harness/support"
require_relative "../../harness/pilot_session"

# The v15 `start` script parameter: a focused-scene primitive (same class
# as `scenario`/`seed`) that lets a wall script begin with banked value so
# the gate replay exercises seals/boss without a two-hour farm prologue.
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

  # v20 T3 (s116 named debt): a focused scene BEGINS in the named zone —
  # the destination banner must be active at frame 0. Pre-fix the boot
  # (home) banner dwelt over the destination's ground for its full clock
  # (dash_strike_rip QUIRK-RED twice, wall record §7).
  def test_apply_start_with_zone_shows_the_destination_banner_at_frame_zero
    w = world
    Harness.apply_start(w, { zone: "district" })
    banner = w.active_banner
    refute_nil banner, "arrival still announces itself"
    assert_equal "zone.district.display_name", banner[:text_key],
                 "the DESTINATION banner is active at frame 0 — never the stale boot banner"
  end

  def test_apply_start_without_zone_keeps_the_boot_banner
    w = world
    Harness.apply_start(w, { banked: 240 })
    assert_equal "zone.nest.display_name", w.active_banner[:text_key],
                 "no zone jump — the home arrival banner stands untouched"
  end

  def test_apply_start_with_unknown_zone_raises
    w = world
    assert_raises(ArgumentError) { Harness.apply_start(w, { zone: "nowhere" }) }
  end

  # E1.9 (s135): `at` places the pack at a named walkable tile AFTER the zone
  # jump, so a boss sentinel can stage the boss's OWN beats (nameplate, phase
  # pips, boss bar, the phase-2 rotation E0 fixed) without crossing a zone
  # that wipes the pack before the dais - measured live: ember_3 collapses at
  # [20,16] on the way to [49,15] at the level cap.
  def test_apply_start_with_at_places_the_pack_next_to_a_named_tile
    w = world
    Harness.apply_start(w, { zone: "ember_3", at: [46, 15] })
    tiles = w.pack.members.map(&:tile)
    assert_includes tiles, [46, 15], "a pack body stands on the named tile"
    assert_equal w.pack.members.length, tiles.uniq.length, "no two bodies share a tile"
    tiles.each do |(tx, ty)|
      assert w.map.passable?(tx, ty), "body placed on an impassable tile #{[tx, ty].inspect}"
      assert_operator [(tx - 46).abs, (ty - 15).abs].max, :<=, 1, "bodies stay adjacent to the named tile"
    end
  end

  def test_apply_start_with_at_refuses_named_when_the_tile_has_no_room
    w = world
    err = assert_raises(ArgumentError) { Harness.apply_start(w, { zone: "ember_3", at: [0, 0] }) }
    assert_match(/start\.at \[0, 0\].*passable/, err.message)
  end

  def test_apply_start_without_at_keeps_the_zone_spawn
    w = world
    Harness.apply_start(w, { zone: "ember_3" })
    assert_equal w.map.pack_spawn.sort, w.pack.members.map(&:tile).sort
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

  # T3 (and T5's fixture primitive): the progression start param stages
  # level+xp through the SaveState seam (load_progress! → sync_max_hp!,
  # the P3 order) so a wall script can sit one kill from a boundary
  # without a farm prologue.
  def test_apply_start_with_progression_stages_level_xp_and_grown_ceilings
    w = world
    Harness.apply_start(w, { progression: { level: 3, xp: 5 } })
    assert_equal 3, w.progression.level
    assert_equal 5, w.progression.xp
    w.pack.members.each do |m|
      assert_equal w.progression.max_hp_for(m.kit[:max_hp]), m.max_hp,
                   "#{m.kit_name} ceiling must be synced to the staged level"
    end
  end

  def test_apply_start_progression_missing_fields_default_to_level_one
    w = world
    Harness.apply_start(w, { progression: { xp: 79 } })
    assert_equal 1, w.progression.level
    assert_equal 79, w.progression.xp
    base = w.pack.members.first
    assert_equal base.kit[:max_hp], base.max_hp, "level 1 is identity"
  end

  def test_apply_start_without_progression_key_is_a_no_op
    w = world
    Harness.apply_start(w, {})
    assert_equal [1, 0], [w.progression.level, w.progression.xp]
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
