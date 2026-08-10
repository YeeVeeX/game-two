require_relative "../test_helper"
require "json"
require "core/data_store"
require "core/input"
require "game/world"
require_relative "../../harness/support"
require_relative "../../harness/pilot_session"

# The design's central claim, headless: a pilot session driven through
# PilotInput+Recorder exports a script that replays a FRESH same-seed World
# into the exact same state. Real data, real World, no mocks.
class PilotRoundtripTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  SEED = 20_260_810

  def fresh_world(seed: SEED) = Game::World.new(DATA, seed:)

  def pilot_over(world)
    input = Harness::Pilot::PilotInput.new
    recorder = Harness::Pilot::Recorder.new
    [input, recorder]
  end

  def advance(world, input, recorder, actions, ticks)
    ticks.times { Harness::Pilot.advance(world, input, recorder, actions) }
  end

  def goto!(world, input, recorder, dest, guard: 3000)
    engine = Harness::Pilot::GotoEngine.new(world, dest, guard:)
    loop do
      result = engine.step
      return result unless result[:status] == :walking
      Harness::Pilot.advance(world, input, recorder, result[:actions])
    end
  end

  def replay(script)
    raw = JSON.parse(JSON.generate(script), symbolize_names: true)
    world = fresh_world(seed: raw[:seed])
    input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
    raw[:run_until].times do
      input.update(world.frame)
      world.tick(input)
    end
    world
  end

  def signature(world)
    { frame: world.frame, zone: world.zone_name, tile: world.possessed.tile,
      hp: world.possessed.hp, carried: world.possessed.carried,
      banked: world.pack.banked,
      humans: world.humans.map { |h| [h.name, h.tile, h.hp] } }
  end

  def test_hold_press_session_round_trips_exactly
    live = fresh_world
    input, recorder = pilot_over(live)
    advance(live, input, recorder, [:right], 40)
    advance(live, input, recorder, [:attack], 1)
    advance(live, input, recorder, [], 20)
    advance(live, input, recorder, %i[up right], 30)
    advance(live, input, recorder, [:swap], 1)
    advance(live, input, recorder, [], 30)

    script = recorder.to_script(seed: SEED, width: 960, height: 540, out_dir: "captures/rt")
    assert_equal signature(live), signature(replay(script))
  end

  def test_goto_walks_to_the_bank_station_and_round_trips
    live = fresh_world
    input, recorder = pilot_over(live)
    result = goto!(live, input, recorder, [12, 8])
    assert_equal :arrived, result[:status]
    assert_equal [12, 8], live.possessed.tile

    script = recorder.to_script(seed: SEED, width: 960, height: 540, out_dir: "captures/rt")
    assert_equal signature(live), signature(replay(script))
  end

  # Holds spanning hitstop frames replay identically: the sim skips input on
  # those ticks in BOTH runs, and @frame advances on every path.
  def test_hold_spanning_hitstop_round_trips
    live = fresh_world
    input, recorder = pilot_over(live)
    goto!(live, input, recorder, [28, 8]) # face the gate approach, wall at [29,8] side
    result = goto!(live, input, recorder, [29, 8])
    # [29,8] is the district gate — arriving there flips zones mid-goto.
    assert_equal :zone_changed, result[:status] if result[:status] != :arrived

    # In the district: walk at the nearest rusher and swing while moving so
    # hitstop from the hit lands INSIDE the recorded hold.
    engine_target = live.humans.min_by { |h| (h.tile[0] - live.possessed.tile[0]).abs }
    goto_result = goto!(live, input, recorder,
                        [engine_target.tile[0] - 1, engine_target.tile[1]], guard: 3000)
    assert_equal :arrived, goto_result[:status]
    120.times { Harness::Pilot.advance(live, input, recorder, %i[right attack]) }
    assert live.feel.hitstop? || live.humans.any? { |h| h.hp < h.max_hp } || live.possessed.hp < live.possessed.max_hp,
           "the brawl must have actually engaged for this test to bite"

    script = recorder.to_script(seed: SEED, width: 960, height: 540, out_dir: "captures/rt")
    assert_equal signature(live), signature(replay(script))
  end

  def test_goto_unreachable_wall_fails_fast
    live = fresh_world
    input, recorder = pilot_over(live)
    result = goto!(live, input, recorder, [0, 0]) # corner wall tile
    assert_equal :unreachable, result[:status]
    assert_equal 0, recorder.frame_count, "fail-fast burns zero sim frames"
  end

  def test_goto_zone_change_aborts
    live = fresh_world
    input, recorder = pilot_over(live)
    # Dest beyond the gate: the flow field is zone-local, so the gate tile
    # [29,8] is on the path only when the dest IS the gate; crossing it
    # mid-walk aborts. Force the cross by walking onto the gate directly,
    # then goto again inside the new zone snapshotting the OLD zone... the
    # honest case: goto [29,8] arrives, and the NEXT tick the sim transitions.
    goto!(live, input, recorder, [28, 8])
    engine = Harness::Pilot::GotoEngine.new(live, [29, 8], guard: 3000)
    result = nil
    loop do
      result = engine.step
      break unless result[:status] == :walking
      Harness::Pilot.advance(live, input, recorder, result[:actions])
    end
    # Stepping onto the gate tile transitions the zone within the same tick
    # (check_transition runs after movement) — the engine must report it.
    assert_equal :zone_changed, result[:status]
    assert_equal "district", live.zone_name
  end

  def test_goto_possession_change_aborts
    live = fresh_world
    input, recorder = pilot_over(live)
    engine = Harness::Pilot::GotoEngine.new(live, [20, 8], guard: 3000)
    first = engine.step
    assert_equal :walking, first[:status]
    Harness::Pilot.advance(live, input, recorder, first[:actions])
    live.possessed.take_hit(damage: 9999, attacker: live.pack.members.last)
    live.bus.process # forced swap happens at bus-process time
    result = engine.step
    assert_equal :possession_changed, result[:status]
  end

  def test_goto_guard_bounds_livelock
    live = fresh_world
    input, recorder = pilot_over(live)
    result = goto!(live, input, recorder, [20, 6], guard: 3)
    assert_equal :guard, result[:status]
    assert result[:tile], "guard reports the tile reached"
  end
end
