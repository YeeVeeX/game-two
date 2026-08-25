require_relative "../test_helper"
require "json"
require "core/data_store"
require "core/input"
require "game/world"

# B1-T1 — the safe-zone law (v19 foundation row 6, RATIFIED-G + RATIFIED-J
# 2026-08-22; spec docs/superpowers/specs/2026-08-24-b1-safe-zones-design.md).
# Real World, real zone data, no mocks: add_human (the world's own seeding
# verb) places hostiles inside the live sanctuary and the guard is judged by
# events + state over real ticks.
#
# Geometry notes (why these tiles): camp arrivals are [1,5]/[18,5] and
# beachhead_tiles=4 — every pack placement here sits OUTSIDE the beachhead
# shadow, so acquisition would be LEGAL absent the safe flag (the guard is
# what refuses it, not an accident of arrival shielding). Camp is 20x11 and
# ally follow-AI always converges on the possessed, so the two uncontrolled
# allies are killed first (D4: pack-side verbs stay legal in sanctuaries;
# dead allies keep the tableau frozen and the assertions single-cause).
class SafeZoneTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def scripted = Core::ScriptedInput.new(frames: {})

  def drive(world, n)
    input = scripted
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def count_events(world, *names)
    counts = Hash.new(0)
    names.each { |n| world.bus.subscribe(n) { counts[n] += 1 } }
    counts
  end

  # Kill the uncontrolled allies through the real hit path (attacker must
  # be a live creature; the placed hostile serves). Uncontrolled pack
  # deaths leave corpses only — no forced swap, no wipe.
  def clear_allies!(world, attacker)
    world.pack.members.reject { |m| world.controlled?(m) }.each do |m|
      m.take_hit(damage: 999_999, attacker: attacker)
    end
    world.bus.process
  end

  # --- the ratified coverage list (data pin) -----------------------------

  def test_safe_coverage_is_exactly_camp_and_zone_7
    dir = File.expand_path("../../data/zones", __dir__)
    declared = Dir[File.join(dir, "*.json")].select do |p|
      JSON.parse(File.read(p))["safe"] == true
    end.map { |p| File.basename(p, ".json") }.sort
    assert_equal %w[camp zone_7], declared,
                 "the ratified B1 coverage list is BOTH hubs and nothing else " \
                 "(extending it is one data line on an owner word — re-pin here)"
  end

  # --- acquisition refused inside the sanctuary --------------------------

  def test_hostile_in_camp_never_acquires_pursues_or_damages
    world = Game::World.new(DATA)
    world.start_in("camp")
    rusher = world.send(:add_human, "camp", :rusher, [11, 3])
    clear_allies!(world, rusher)
    world.possessed.rebind(map: world.map, tile: [10, 3]) # ADJACENT to the hostile
    counts = count_events(world, :human_retargeted, :telegraph, :attack_hit)
    hp_before = world.possessed.hp
    drive(world, 300)
    assert_nil rusher.focus, "safe zone: acquisition must be refused"
    assert_equal 0, counts[:human_retargeted], "the nil write emits nothing"
    assert_equal 0, counts[:telegraph], "no windup can start without focus"
    assert_equal 0, counts[:attack_hit], "nobody swings in the frozen tableau"
    assert_equal hp_before, world.possessed.hp, "enemies never damage inside"
    assert_equal [11, 3], rusher.tile, "at home, unfocused: the hostile stands"
  end

  def test_displaced_hostile_in_camp_still_leash_walks_home
    world = Game::World.new(DATA)
    world.start_in("camp")
    rusher = world.send(:add_human, "camp", :rusher, [14, 2]) # home = [14, 2]
    clear_allies!(world, rusher)
    world.possessed.rebind(map: world.map, tile: [6, 3])
    rusher.rebind(map: world.map, tile: [14, 8]) # displaced 6 tiles, pack IN aggro range
    drive(world, 400) # linger (90) + 6 tiles at step 16 + tween slack
    assert_nil rusher.focus, "guard beats proximity the whole walk"
    assert_equal [14, 2], rusher.tile,
                 "dispersed, not invulnerable: the displaced human walked home"
    assert_equal rusher.max_hp, rusher.hp, "leash keeps hp (no heal, no harm)"
  end

  # --- the D3 reopen: chant-start is an acquisition verb -----------------

  def test_challenger_in_camp_never_starts_a_chant
    world = Game::World.new(DATA)
    world.start_in("camp")
    challenger = world.send(:add_human, "camp", :challenger, [12, 3])
    clear_allies!(world, challenger)
    world.possessed.rebind(map: world.map, tile: [10, 3]) # dist 2 <= seize range 7
    counts = count_events(world, :challenger_chant_started, :vessel_seized,
                          :human_retargeted)
    drive(world, 150)
    assert_equal 0, counts[:challenger_chant_started],
                 "chant-start pins a body WITHOUT focus — the sanctuary refusal " \
                 "must name it (D3 reopen, s71)"
    assert_equal 0, counts[:vessel_seized]
    assert_equal 0, counts[:human_retargeted]
    assert_nil challenger.focus
  end

  # --- zone-scoped, not global: district acquires normally ---------------

  def test_same_shape_in_district_acquires_normally
    world = Game::World.new(DATA)
    world.start_in("district")
    rusher = world.send(:add_human, "district", :rusher, [21, 13])
    clear_allies!(world, rusher)
    world.possessed.rebind(map: world.map, tile: [20, 13])
    counts = count_events(world, :human_retargeted)
    drive(world, 10)
    assert_equal world.possessed, rusher.focus,
                 "unsafe zone: the adjacent hostile acquires the pack"
    assert_operator counts[:human_retargeted], :>=, 1
  end

  def test_challenger_in_district_still_chants
    world = Game::World.new(DATA)
    world.start_in("district")
    challenger = world.send(:add_human, "district", :challenger, [22, 13])
    clear_allies!(world, challenger)
    world.possessed.rebind(map: world.map, tile: [20, 13])
    counts = count_events(world, :challenger_chant_started)
    drive(world, 40)
    assert_operator counts[:challenger_chant_started], :>=, 1,
                    "the refusal is zone-scoped: outside sanctuaries the " \
                    "challenger's verb is untouched"
  end
end
