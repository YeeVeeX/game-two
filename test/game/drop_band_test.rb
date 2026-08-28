require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v11 Q6 rider: spawn_drop stamps the gradient band index on the drop
# record (renderer-reads-the-record, the decay_frames pattern). Band is a
# function of tile, so the same-tile merge can never conflict on band.
class DropBandTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]

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

  def clear_field(world)
    world.humans.dup.each { |h| h.take_hit(damage: h.hp, attacker: world.possessed) until h.dead? }
    drive(world, scripted({}), 1)
    world.instance_variable_get(:@human_respawns)["district"].clear
    world.drops.clear
  end

  def kill_at(world, zone, tile)
    world.send(:add_human, zone, :rusher, tile)
    victim = world.humans.find { |c| c.tile == tile }
    victim.take_hit(damage: victim.hp, attacker: world.possessed) until victim.dead?
    drive(world, scripted({}), 1) # flush -> spawn_drop
    world.drops.find { |d| d[:tile] == tile }
  end

  def test_drop_records_carry_the_gradient_band_of_the_kill_tile
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    w.pack.living.each_with_index { |m, i| m.walker.teleport(1, 12 + i) }
    near = kill_at(w, "district", [11, 84])  # gate_distance 1  -> band 0
    mid  = kill_at(w, "district", [41, 45])  # gate_distance ~55 -> band 1
    deep = kill_at(w, "district", [42, 13])  # gate_distance 70+ -> band 2
    assert_equal 0, near[:band], "near-gate kill stamps band 0"
    assert_equal 1, mid[:band], "mid-district kill stamps band 1"
    assert_equal 2, deep[:band], "deep kill stamps band 2"
  end

  def test_nest_drops_stamp_band_zero
    w = Game::World.new(DATA, seed: 42)
    assert_equal "nest", w.zone_name
    drop = kill_at(w, "nest", [28, 2]) # no drop_gradient in the nest
    refute_nil drop
    assert_equal 0, drop[:band], "a zone without a gradient stamps band 0"
  end

  def test_same_tile_merge_keeps_band_and_first_clock
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    clear_field(w)
    w.pack.living.each_with_index { |m, i| m.walker.teleport(1, 1 + i) }
    tile = [35, 5]
    first = kill_at(w, "district", tile)
    clock = first[:frames_left]
    amount = first[:amount]
    drive(w, scripted({}), 30)
    merged = kill_at(w, "district", tile)
    assert_same first, merged, "same-tile kill merges into the first record"
    assert_equal 2, merged[:band], "merge keeps the band (same tile, same band)"
    assert_operator merged[:amount], :>, amount, "merge sums amounts"
    assert_operator merged[:frames_left], :<, clock,
                    "merge keeps the FIRST kill's decay clock (no reset)"
  end
end
