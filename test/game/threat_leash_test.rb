require_relative "../test_helper"
require "core/data_store"
require "core/event_bus"
require "core/input"
require "core/tile_map"
require "game/world"

# A2 leash-with-no-heal: a human with nothing in aggro range for the linger
# walks home KEEPING its HP. On zone re-entry (J7-B): a STAMPED re-entry
# advances displaced humans finitely along their home paths (cold catch-up,
# linger-then-walk on existing knobs); the no-stamp paths (first entry,
# same-zone wipe respawn) keep the original snap-home verbatim.
class ThreatLeashTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  THREAT = DATA["balance/threat"]
  COMBAT = DATA["balance/combat"]
  STEP_FRAMES = COMBAT[:kits][:rusher][:step_frames]
  LINGER = THREAT[:leash_linger_frames]

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, n, input: scripted({}))
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    step = COMBAT[:kits][:striker][:step_frames]
    drive(world, step * 30, input: scripted((0..step * 30 - 1).to_h { |f| [f.to_s, ["right"]] }))
    assert_equal "district", world.zone_name
  end

  def make_human(world, kit_name, tile)
    kit = COMBAT[:kits].fetch(kit_name.to_sym)
    Game::Creature.new(bus: world.bus, kit: kit, kit_name: kit_name.to_sym,
                       map: world.map, tile: tile, faction: :human, name: "test_#{kit_name}_#{tile}")
  end

  # --- leash walk-home -----------------------------------------------------------

  def test_idle_humans_walk_home_after_the_linger_and_keep_their_hp
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    w.humans.clear

    # Place a rusher away from its home tile, damage it to 20 hp
    home = [6, 12]
    rusher = make_human(w, :rusher, home)
    w.humans << rusher
    assert_equal home, rusher.home_tile

    # Move it off home (teleport to a tile ~4 away)
    off_home = [10, 12]
    rusher.walker.teleport(*off_home)
    assert_equal off_home, rusher.tile

    # Damage to 20 hp
    damage = rusher.hp - 20
    rusher.take_hit(damage: damage, attacker: w.possessed, knockback_tiles: 0, blocked: [])
    assert_equal 20, rusher.hp

    # Park the pack FAR away so nothing is in aggro (d > aggro_tiles)
    aggro = rusher.kit[:aggro_tiles]
    w.pack.members.each_with_index { |m, i| m.walker.teleport(40, 1 + i) }

    # Tick past the linger + enough frames for the walk home (~4 tiles * step_frames per tile + some margin)
    walk_budget = (off_home[0] - home[0]).abs * STEP_FRAMES + STEP_FRAMES * 2
    drive(w, LINGER + walk_budget)

    # The rusher must be home with hp UNCHANGED (no heal)
    assert_equal home, rusher.tile, "rusher should have walked home"
    assert_equal 20, rusher.hp, "hp must be kept (no heal)"
  end

  # --- emit-once per episode -----------------------------------------------------

  def test_human_leashed_emits_once_per_episode
    w = Game::World.new(DATA, seed: 7)
    enter_district(w)
    w.humans.clear

    home = [6, 12]
    rusher = make_human(w, :rusher, home)
    w.humans << rusher
    rusher.walker.teleport(8, 12)

    # Park pack far away
    w.pack.members.each_with_index { |m, i| m.walker.teleport(40, 1 + i) }

    events = []
    w.bus.subscribe(:human_leashed) { |e| events << e }

    # Tick past the linger + walk time (2 tiles worth)
    walk_budget = 2 * STEP_FRAMES + STEP_FRAMES
    drive(w, LINGER + walk_budget)

    assert_equal 1, events.length,
                 "human_leashed must fire exactly once per leash episode"
    assert_equal rusher, events.first[:actor]
  end

  # --- re-engage on pack return ---------------------------------------------------

  def test_returning_humans_reengage_when_the_pack_comes_back_in_range
    w = Game::World.new(DATA, seed: 13)
    enter_district(w)
    w.humans.clear

    home = [6, 12]
    rusher = make_human(w, :rusher, home)
    w.humans << rusher
    rusher.walker.teleport(8, 12)

    # Park pack far away
    w.pack.members.each_with_index { |m, i| m.walker.teleport(40, 1 + i) }

    # Tick past linger to start the walk home
    drive(w, LINGER + STEP_FRAMES)

    # Now move the pack back into aggro range of the rusher
    aggro = rusher.kit[:aggro_tiles]
    w.pack.members.first.walker.teleport(home[0] + 1, home[1])

    # Tick a few frames for focus assignment to kick in
    drive(w, 3)

    # The rusher should have a focus now (re-engaged)
    refute_nil rusher.focus, "returning human must re-engage when pack comes back in range"
    # And the leash counter resets (next tick_human resets on live target path)
    # Tick one more to let reset_leash! fire
    drive(w, 1)
    assert_equal 0, rusher.leash_frames, "leash resets on re-engage"
  end

  # --- cross-zone snap ------------------------------------------------------------

  def test_zone_reentry_snaps_absent_zone_humans_home_with_kept_hp
    w = Game::World.new(DATA, seed: 99)
    enter_district(w)

    # Clear all humans; place a single controlled rusher far from the gate path
    # so it survives the round trip without engaging the pack.
    w.humans.clear
    home = [16, 12]
    rusher = make_human(w, :rusher, home)
    w.humans << rusher
    assert_equal home, rusher.home_tile

    # Teleport off home and damage
    off_home = [19, 12]
    rusher.walker.teleport(*off_home)
    damage = rusher.hp - 25
    rusher.take_hit(damage: damage, attacker: w.possessed, knockback_tiles: 0, blocked: [])
    assert_equal 25, rusher.hp
    refute_equal home, rusher.tile, "rusher must be off home before zone exit"

    # Walk pack to the gate (at [0,13]) — far from the rusher at [16,12]
    gate = w.map.transitions.first[:at]
    guard = 0
    while w.zone_name == "district" && guard < 3000
      if w.possessed.walker.moving?
        drive(w, 1)
      else
        dx = (gate[0] - w.possessed.tile[0]).clamp(-1, 1)
        dy = (gate[1] - w.possessed.tile[1]).clamp(-1, 1)
        keys = []
        keys << (dx.positive? ? "right" : "left") unless dx.zero?
        keys << (dy.positive? ? "down" : "up") unless dy.zero?
        drive(w, 1, input: scripted({ w.frame.to_s => keys }))
      end
      guard += 1
    end
    assert_equal "nest", w.zone_name, "must have transitioned to nest"

    # Dwell in nest past the linger + the full walk budget: whether the
    # re-entry path snaps or catch-up-walks (J7-B stamp), enough elapsed
    # time CLAMPS the placement at home — the law under test.
    drive(w, LINGER + 5 * STEP_FRAMES)

    # Now walk back to the district
    nest_gate = w.map.transitions.find { |t| t[:to] == "district" }
    skip "no nest->district transition" unless nest_gate
    gate_at = nest_gate[:at]

    guard = 0
    while w.zone_name == "nest" && guard < 3000
      if w.possessed.walker.moving?
        drive(w, 1)
      else
        dx = (gate_at[0] - w.possessed.tile[0]).clamp(-1, 1)
        dy = (gate_at[1] - w.possessed.tile[1]).clamp(-1, 1)
        keys = []
        keys << (dx.positive? ? "right" : "left") unless dx.zero?
        keys << (dy.positive? ? "down" : "up") unless dy.zero?
        drive(w, 1, input: scripted({ w.frame.to_s => keys }))
      end
      guard += 1
    end
    assert_equal "district", w.zone_name, "must have returned to district"

    # Find the rusher in the district roster (it was snapped on re-entry)
    snapped = w.humans.find { |h| h.equal?(rusher) }
    refute_nil snapped, "rusher must still be in the zone roster"
    assert_equal home, snapped.tile,
                 "rusher must be snapped to home_tile on zone re-entry"
    assert_equal 25, snapped.hp,
                 "hp must be KEPT (no heal) on zone snap"
  end

  # --- J7-B: stamped re-entry = finite catch-up ------------------------------

  # Stage a displaced rusher and cross district->nest with teleport-shortened
  # travel (the rusher must still be mid-linger at the leave tick, so the
  # frozen displacement is exact). Returns [world, rusher, leave_frames].
  def displaced_round_trip_setup(seed:)
    w = Game::World.new(DATA, seed:)
    enter_district(w)
    w.humans.clear
    home = [6, 12]
    rusher = make_human(w, :rusher, home)
    rusher.walker.teleport(10, 12)
    w.humans << rusher
    # Pack beside the gate: the crossing lands within a handful of ticks.
    w.possessed.walker.teleport(1, 13)
    (w.pack.members - [w.possessed]).each_with_index { |m, i| m.walker.teleport(2, 12 + 2 * i) }
    frames = { nest: nil, district: nil }
    w.bus.subscribe(:zone_entered) { |e| frames[e[:zone].to_sym] = w.frame }
    guard = 0
    while w.zone_name == "district" && guard < 200
      drive(w, 1, input: scripted({ w.frame.to_s => ["left"] }))
      guard += 1
    end
    assert_equal "nest", w.zone_name, "staging: crossing must land"
    [w, rusher, frames]
  end

  def return_to_district(w, frames)
    w.possessed.walker.teleport(28, 8)
    (w.pack.members - [w.possessed]).each_with_index { |m, i| m.walker.teleport(20, 8 + i) }
    guard = 0
    while w.zone_name == "nest" && guard < 200
      drive(w, 1, input: scripted({ w.frame.to_s => ["right"] }))
      guard += 1
    end
    assert_equal "district", w.zone_name, "staging: return crossing must land"
    frames
  end

  def test_stamped_reentry_places_displaced_humans_mid_path_not_snapped
    w, rusher, frames = displaced_round_trip_setup(seed: 21)
    damage = rusher.hp - 30
    rusher.take_hit(damage:, attacker: w.possessed, knockback_tiles: 0, blocked: [])
    leashed = []
    w.bus.subscribe(:human_leashed) { |e| leashed << e }
    # Wait long enough for a 2-tile catch-up walk, well short of the full 4.
    drive(w, LINGER + 2 * STEP_FRAMES)
    out, = capture_io { return_to_district(w, frames) }
    elapsed = frames[:district] - frames[:nest]
    tiles = [(elapsed - LINGER), 0].max / STEP_FRAMES
    # D9: the telemetry line is pinned wording — suite-enforced byte-exact.
    assert_includes out, "TELEMETRY catchup zone=district elapsed=#{elapsed} advanced=1\n"
    assert_operator tiles, :>=, 1, "staging: the wait must buy at least one tile"
    assert_operator tiles, :<=, 3, "staging: the wait must leave the walk unfinished"
    assert_equal [10 - tiles, 12], rusher.tile,
                 "displaced human advances exactly (elapsed - linger) / step_frames tiles"
    refute_equal [10, 12], rusher.tile, "catch-up ran (not at the frozen chase tile)"
    refute_equal [6, 12], rusher.tile, "finite speed (not at home) - the teleport is dead"
    assert_equal 30, rusher.hp, "hp is KEPT across the catch-up"
    assert_equal LINGER, rusher.leash_frames,
                 "resume_leash! pre-sets the linger (no double-linger)"
    assert_nil rusher.focus
    # D11 payload parity: same event, same shape as the snap-home emission.
    assert_equal 1, leashed.length, "one :human_leashed per advanced human"
    assert_equal %i[actor tile hp], leashed.first.payload.keys
    assert_equal rusher, leashed.first[:actor]
    assert_equal rusher.tile, leashed.first[:tile]
    assert_equal 30, leashed.first[:hp]
    # D2: the stamp is CONSUMED - the world digest row carries only nest.
    row = w.digest_snapshot.to_h.fetch("world").to_h.fetch("zone_left_at")
    assert_match(/\Anest:\d+\z/, row, "district stamp consumed; nest stamped at leave")
  end

  def test_short_absence_moves_nobody_and_emits_nothing
    w, rusher, frames = displaced_round_trip_setup(seed: 22)
    leashed = []
    w.bus.subscribe(:human_leashed) { |e| leashed << e }
    drive(w, 10) # well under the linger
    return_to_district(w, frames)
    elapsed = frames[:district] - frames[:nest]
    assert_operator elapsed, :<=, LINGER, "staging: absence must fit inside the linger"
    assert_equal [10, 12], rusher.tile,
                 "leave-and-immediately-return reads as nobody moved"
    assert_empty leashed, "no movement, no :human_leashed"
    assert_equal LINGER, rusher.leash_frames, "the walk still resumes without re-lingering"
  end

  def test_same_zone_wipe_respawn_still_snap_homes
    w = Game::World.new(DATA, seed: 23)
    enter_district(w)
    w.load_home!("district") # same-zone wipe: home IS the wipe zone
    w.humans.clear
    home = [16, 12]
    rusher = make_human(w, :rusher, home)
    rusher.walker.teleport(19, 12)
    w.humans << rusher
    w.pack.members.each { |m| m.take_hit(damage: m.hp, attacker: rusher, blocked: []) }
    drive(w, 1) # flush deaths -> wipe veil
    guard = 0
    while w.zone_name != "district" || w.humans.none? { |h| h.equal?(rusher) } ||
          w.states.current != :world
      drive(w, 1)
      guard += 1
      flunk "staging: wipe respawn never landed" if guard > 2000
    end
    assert_equal home, rusher.tile,
                 "no stamp (same-zone wipe) = today's snap-home VERBATIM"
    assert_equal 0, rusher.leash_frames, "snap path keeps reset_leash!"
  end
end
