require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# T5 (P9) integration lane: the level gate end to end through a REAL
# World over an injected self-linked fixture zone (the shipped
# gate_fixture shape — arrivals touch only the fixture itself, so every
# ratified zone's beachhead/anchor geometry is untouched by
# construction). Laws pinned: an unmet requires_level refuses the
# crossing with the pack unmoved; the refusal SPEAKS on the station-cue
# channel (kind :level_required at the way tile with the required N,
# rewritten per stationary tick — commit B, D3); at level
# the same way crosses (zone_entered re-emit + pack relocation); the
# live path levels mid-session through award_kill and the gate opens
# without any reconstruction.
class LevelGateTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  class FixtureStore
    def initialize(base, extra)
      @base = base
      @extra = extra
    end

    def [](key) = @extra.key?(key) ? @extra[key] : @base[key]
    def keys = (@base.keys + @extra.keys).uniq.sort
  end

  ZONE = {
    name: "gate_fx", display_name: "GATE FX", tile_size: 32,
    palette: { floor: [10, 10, 10], grid: [12, 12, 12], wall: [90, 90, 90],
               transition: [235, 190, 90] },
    tiles: [
      "########",
      "#......#",
      "#......#",
      "#......#",
      "#......#",
      "########"
    ],
    pack_spawn: [[1, 1], [2, 1], [3, 1]],
    enemy_spawns: {},
    stations: [],
    transitions: [
      { at: [3, 3], to: "gate_fx", spawn: [6, 1], requires_level: 2 }
    ]
  }.freeze

  def world
    store = FixtureStore.new(DATA, "zones/gate_fx" => Marshal.load(Marshal.dump(ZONE)))
    w = Game::World.new(store)
    w.start_in("gate_fx")
    w
  end

  def drive(w, n = 2)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(w.frame)
      w.tick(input)
    end
  end

  def test_below_level_the_crossing_refuses_with_the_pack_unmoved
    w = world
    w.possessed.walker.teleport(3, 3)
    tiles_before = w.pack.living.map(&:tile)
    drive(w)
    assert_equal "gate_fx", w.zone_name
    assert_equal [3, 3], w.possessed.tile, "the refused pack stays put"
    assert_equal tiles_before, w.pack.living.map(&:tile)
  end

  def test_the_refusal_speaks_on_the_station_cue_channel
    # Commit B (D3): the level refusal rides the station-cue channel —
    # kind :level_required, pinned at the way tile, carrying the
    # required level for the renderer's <N> sub.
    w = world
    w.possessed.walker.teleport(3, 3)
    drive(w)
    cue = w.station_cue
    refute_nil cue, "an unmet level gate must never read as nothing (D3)"
    assert_equal :level_required, cue[:kind]
    assert_equal [3, 3], cue[:at], "the cue pins the way tile"
    assert_equal 2, cue[:n], "the cue carries the required level for the <N> sub"
  end

  def test_the_cue_rewrites_every_stationary_tick
    w = world
    w.possessed.walker.teleport(3, 3)
    drive(w)
    full = DATA["display"][:station_cue_frames]
    assert_equal full, w.station_cue[:frames_left],
                 "standing on the gate re-pins the cue at full dwell " \
                 "(the gate_wait recompute law on the cue channel)"
    drive(w, 5)
    assert_equal full, w.station_cue[:frames_left]
  end

  def test_the_cue_expires_after_stepping_off
    w = world
    w.possessed.walker.teleport(3, 3)
    drive(w)
    w.possessed.walker.teleport(1, 1) # off the way; no rewrite source left
    drive(w, DATA["display"][:station_cue_frames] + 1)
    assert_nil w.station_cue, "off the tile the cue dwells out like any station cue"
  end

  def test_at_level_the_way_crosses_and_relocates_the_pack
    w = world
    w.progression.load_progress!(level: 2, xp: 0)
    drive(w) # flush the queued boot/start_in events before listening
    entered = []
    w.bus.subscribe(:zone_entered) { |e| entered << e[:zone] }
    w.possessed.walker.teleport(3, 3)
    drive(w)
    assert_equal ["gate_fx"], entered, "the self-crossing re-emits zone_entered"
    assert_equal [6, 1], w.possessed.tile, "the pack lands on the declared spawn"
    assert_nil w.station_cue, "an open way writes no refusal cue"
  end

  def test_the_live_path_levels_mid_session_and_the_gate_opens
    w = world
    w.progression.load_progress!(
      level: 1, xp: w.progression.delta_e(2) - DATA["balance/progression"][:kill_xp][:husk]
    )
    w.possessed.walker.teleport(3, 3)
    drive(w)
    assert_equal [3, 3], w.possessed.tile, "one kill short: still shut"
    assert_equal :level_up, w.progression.award_kill(:husk),
                 "the reel's beat: ONE husk kill crosses the threshold"
    drive(w)
    assert_equal [6, 1], w.possessed.tile,
                 "the same standing body crosses the frame the level lands"
  end
end
