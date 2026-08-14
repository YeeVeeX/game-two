require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v14 respawn telegraph: split-phase human respawn (spec
# 2026-08-14-v14-legibility-design.md, Sim spec 1-2). The tile is PINNED
# at at_frame - telegraph_frames via today's exact cascade + defer rules
# and a :respawn_telegraphed tell fires; materialize happens at the
# UNCHANGED at_frame on the pinned tile (difficulty pinned by
# construction). Respawn scatter draws from a dedicated stream so the
# 120f-earlier consumption cannot reorder the drop-roll stream.
class RespawnTelegraphTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]
  RESPAWN = DATA["balance/combat"][:kits][:rusher][:respawn_frames]
  LEAD = DATA["balance/threat"][:telegraph_frames]
  UNPIN = DATA["balance/threat"][:telegraph_defer_unpin_frames]
  DENSITY = DATA["balance/threat"][:density]

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    assert_equal "district", world.zone_name
  end

  def chebyshev((ax, ay), (bx, by)) = [(bx - ax).abs, (by - ay).abs].max

  def clear_field(world)
    world.humans.dup.each { |h| h.take_hit(damage: h.hp, attacker: world.possessed) until h.dead? }
    drive(world, scripted({}), 1)
    world.instance_variable_get(:@human_respawns)["district"].clear
  end

  def park_pack(world, tiles)
    world.pack.living.each_with_index { |m, i| m.walker.teleport(*tiles[i]) }
  end

  FAR_PARK = [[1, 1], [1, 2], [1, 3]].freeze

  def stage_human(world, tile, kit: :rusher)
    world.send(:add_human, "district", kit, tile)
    h = world.humans.find { |c| c.tile == tile }
    h.stagger!(30_000)
    h
  end

  def schedule_one_respawn(world, tile: [20, 12])
    world.send(:add_human, "district", :rusher, tile)
    victim = world.humans.find { |c| c.tile == tile }
    victim.take_hit(damage: victim.hp, attacker: world.possessed) until victim.dead?
    drive(world, scripted({}), 1)
    world.instance_variable_get(:@human_respawns)["district"].last
  end

  def record_events(world, type)
    events = []
    world.bus.subscribe(type) { |e| events << e }
    events
  end

  def staged_world(seed: 42)
    w = Game::World.new(DATA, seed:)
    enter_district(w)
    clear_field(w)
    stage_human(w, [40, 23]) # a pocket anchor the cascade will pick
    w
  end

  # Drive to the exact tick in which the world processes `frame` (the tick
  # whose in-tick @frame equals it): after driving, world.frame == frame+1.
  def drive_through(world, frame)
    drive(world, scripted({}), frame + 1 - world.frame)
  end

  # --- pin + tell ----------------------------------------------------------

  def test_pin_fires_exactly_at_lead_and_emits_the_tell
    w = staged_world
    tells = record_events(w, :respawn_telegraphed)
    record = schedule_one_respawn(w)
    park_pack(w, FAR_PARK)
    drive_through(w, record[:at_frame] - LEAD - 1)
    assert_empty tells, "no tell before the window opens"
    assert_empty w.respawn_tells
    drive(w, scripted({}), 1) # the at_frame - LEAD tick
    assert_equal 1, tells.length, "the tell fires the tick the window opens"
    assert_equal :rusher, tells.first[:kit_name]
    assert_equal record[:at_frame], tells.first[:at_frame]
    tell = w.respawn_tells.first
    refute_nil tell
    assert_equal tells.first[:tile], tell[:tile]
    assert_equal LEAD, tell[:total]
    assert_in_delta LEAD, tell[:frames_left], 1
    assert chebyshev(tell[:tile], [40, 23]) <= DENSITY[:scatter_radius_tiles],
           "pin runs today's cascade: the tell sits on the pocket"
  end

  def test_materialize_at_unchanged_at_frame_on_the_pinned_tile
    w = staged_world
    tells = record_events(w, :respawn_telegraphed)
    spawns = record_events(w, :human_respawned)
    record = schedule_one_respawn(w)
    park_pack(w, FAR_PARK)
    count = w.humans.length
    drive_through(w, record[:at_frame] - 1)
    assert_equal 1, tells.length
    assert_equal count, w.humans.length, "the tell precedes the body"
    drive(w, scripted({}), 1) # the at_frame tick — today's exact release tick
    assert_equal count + 1, w.humans.length, "materialize tick UNCHANGED"
    assert_equal 1, spawns.length
    assert_equal tells.first[:tile], spawns.first[:tile],
                 "the human materializes exactly where the tell stood"
    assert_equal :pocket, spawns.first[:anchor]
    assert_empty w.respawn_tells, "a materialized tell is gone"
  end

  # --- defer laws ----------------------------------------------------------

  def test_pin_defers_while_the_window_start_is_blocked_then_lands
    w = staged_world
    tells = record_events(w, :respawn_telegraphed)
    record = schedule_one_respawn(w)
    # Cover every scatter tile of the anchor through the window start.
    park_pack(w, [[34, 21], [34, 22], [34, 23]])
    w.pack.living.each { |m| m.stagger!(30_000) }
    drive_through(w, record[:at_frame] - LEAD + 30)
    assert_empty tells, "pin-time defer: blocked window start pins nothing"
    park_pack(w, FAR_PARK)
    drive(w, scripted({}), 3)
    assert_equal 1, tells.length, "pin retries and lands once clear"
    assert w.frame < record[:at_frame], "still inside the window"
  end

  def test_materialize_defer_persists_the_tell_at_full_intensity
    w = staged_world
    tells = record_events(w, :respawn_telegraphed)
    record = schedule_one_respawn(w)
    park_pack(w, FAR_PARK)
    drive_through(w, record[:at_frame] - LEAD)
    assert_equal 1, tells.length
    pinned = tells.first[:tile]
    # Park a body ON the pinned tile before the due tick: occupied -> defer.
    w.pack.living.each { |m| m.stagger!(30_000) }
    park_pack(w, [pinned, [1, 2], [1, 3]])
    count = w.humans.length
    drive_through(w, record[:at_frame] + 30)
    assert_equal count, w.humans.length, "occupied pinned tile defers"
    tell = w.respawn_tells.first
    refute_nil tell, "the tell PERSISTS through a materialize defer"
    assert_equal pinned, tell[:tile], "the pinned tile never re-rolls while told"
    assert_equal 0, tell[:frames_left], "held at full intensity"
    park_pack(w, FAR_PARK)
    drive(w, scripted({}), 3)
    assert_equal count + 1, w.humans.length, "lands once clear"
    assert_equal pinned, w.humans.last.tile
  end

  def test_w5_unpin_after_the_defer_bound_falls_back_to_recompute
    w = staged_world
    tells = record_events(w, :respawn_telegraphed)
    record = schedule_one_respawn(w)
    park_pack(w, FAR_PARK)
    drive_through(w, record[:at_frame] - LEAD)
    pinned = tells.first[:tile]
    w.pack.living.each { |m| m.stagger!(60_000) }
    park_pack(w, [pinned, [1, 2], [1, 3]])
    count = w.humans.length
    drive_through(w, record[:at_frame] + UNPIN + 2)
    assert_equal count, w.humans.length
    assert_empty w.respawn_tells,
                 "past the bound the record unpins — the held tell disappears (W5)"
    park_pack(w, FAR_PARK)
    drive(w, scripted({}), 3)
    assert_equal count + 1, w.humans.length,
                 "unpinned record materializes via today's recompute path"
    assert_equal 1, tells.length, "no second tell after the W5 unpin"
  end

  # --- today's-path fallbacks ---------------------------------------------

  def test_unpinned_due_record_takes_todays_path_with_no_tell
    # The veil-resume shape: a record already past due and never pinned
    # (tick_world did not run during its window) releases through the
    # v13 path — instant materialize, no telegraph.
    w = staged_world
    tells = record_events(w, :respawn_telegraphed)
    w.instance_variable_get(:@human_respawns)["district"] <<
      { kit_name: :rusher, at_frame: 0 }
    park_pack(w, FAR_PARK)
    count = w.humans.length
    # A few ticks, not one: clear_field's kill burst leaves residual
    # hitstop and tick_world (where releases run) is paused under it.
    drive(w, scripted({}), 10)
    assert_equal count + 1, w.humans.length, "instant release on resume"
    assert_empty tells, "no tell for an unpinned due record"
  end

  # --- multiple records ----------------------------------------------------

  def test_two_records_never_pin_the_same_tile
    w = staged_world
    tells = record_events(w, :respawn_telegraphed)
    schedule_one_respawn(w, tile: [20, 12])
    schedule_one_respawn(w, tile: [22, 12])
    park_pack(w, FAR_PARK)
    records = w.instance_variable_get(:@human_respawns)["district"]
    drive_through(w, records.map { |r| r[:at_frame] }.max - LEAD + 2)
    assert_equal 2, tells.length, "both records pinned inside the window"
    assert_equal 2, w.respawn_tells.length
    refute_equal tells[0][:tile], tells[1][:tile],
                 "sibling pins count as occupied — two tells never share a tile"
    drive_through(w, records.map { |r| r[:at_frame] }.max + 1)
    tiles = w.actors.map(&:tile)
    assert_equal tiles.uniq.length, tiles.length
  end

  # --- RNG stream isolation -------------------------------------------------

  def test_pin_tile_ignores_drop_stream_consumption
    tiles = [false, true].map do |burn|
      w = Game::World.new(DATA, seed: 7)
      enter_district(w)
      clear_field(w)
      stage_human(w, [40, 23])
      stage_human(w, [40, 24])
      tells = record_events(w, :respawn_telegraphed)
      schedule_one_respawn(w)
      park_pack(w, FAR_PARK)
      # Burn the DROP stream mid-window: under the v13 shared stream this
      # moved the scatter pick; the dedicated respawn stream must not care.
      5.times { w.rng.rand(1000) } if burn
      drive(w, scripted({}), RESPAWN + 10)
      refute_empty tells
      tells.first[:tile]
    end
    assert_equal tiles[0], tiles[1],
                 "respawn scatter draws from its own stream (drop rolls cannot move a tell)"
  end

  # --- accessor purity ------------------------------------------------------

  def test_respawn_tells_never_inserts_zone_keys
    w = Game::World.new(DATA, seed: 42) # fresh, in the nest, no kills
    keys_before = w.instance_variable_get(:@human_respawns).keys.dup
    assert_equal [], w.respawn_tells
    assert_equal keys_before, w.instance_variable_get(:@human_respawns).keys,
                 "the accessor is a pure reader (corpse_loads fetch law)"
  end
end
