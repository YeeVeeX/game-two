require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Tests for A2 respawn suppression (pack proximity) and depth-gradient drops.
class ThreatRespawnTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]
  RESPAWN = DATA["balance/combat"][:kits][:rusher][:respawn_frames]
  BLOCK = DATA["balance/threat"][:respawn_block_tiles]

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

  # --- respawn suppression (A2) -------------------------------------------

  def test_respawn_defers_while_a_pack_body_is_within_the_block_radius
    w = Game::World.new(DATA, seed: 42)
    enter_district(w)
    # Clear combat noise: isolate by killing all humans
    w.humans.dup.each { |h| h.take_hit(damage: h.hp, attacker: w.possessed) until h.dead? }
    drive(w, scripted({}), 1)  # flush bus -> respawns scheduled
    w.instance_variable_get(:@human_respawns)["district"].clear

    # Kill the [14, 12] rusher specifically by respawning a fresh one there
    spawn_tile = [14, 12]
    w.send(:add_human, "district", :rusher, spawn_tile)
    target = w.humans.find { |h| h.tile == spawn_tile }
    refute_nil target
    target.take_hit(damage: target.hp, attacker: w.possessed) until target.dead?
    drive(w, scripted({}), 1)  # flush -> schedules respawn at spawn_tile
    count_after_kill = w.humans.length

    # Park the pack 8 tiles from the spawn point (within block radius 12)
    park = [spawn_tile[0] - 8, spawn_tile[1]]  # [6, 12], distance=8
    w.pack.living.each_with_index do |m, i|
      m.walker.teleport(park[0], park[1] + i)
    end

    # Tick past respawn_frames: roster count unchanged (suppressed)
    drive(w, scripted({}), RESPAWN + 10)
    assert_equal count_after_kill, w.humans.length,
                 "respawn must defer while a pack body is within #{BLOCK} tiles of the spawn"

    # Move ALL pack members > block radius away (13 tiles from spawn)
    far = [spawn_tile[0] + 13, spawn_tile[1]]  # [27, 12], distance=13
    w.pack.living.each_with_index do |m, i|
      m.walker.teleport(far[0], far[1] + i)
    end

    # Tick once: the deferred respawn fires
    drive(w, scripted({}), 1)
    assert w.humans.any? { |h| h.tile == spawn_tile },
           "deferred respawn lands once all pack bodies are beyond the block radius"
  end

  # --- depth gradient drops (A2) ------------------------------------------

  def test_drop_amounts_scale_with_gate_distance_bands
    # Band 0: gate_distance < 14, multiplier 1.0
    # Band 2: gate_distance >= 28, multiplier 2.0
    # Separate worlds with the same seed ensure the drop roll lands at the
    # same RNG position — only one kill per world, so table-draw index matches.
    near_tile = [5, 13]   # gate_distance ~4 (band 0, mult 1.0)
    far_tile = [35, 5]    # gate_distance >= 28 (band 2, mult 2.0)

    3.times do |trial|
      seed = 200 + trial
      # --- Near world ---
      wn = Game::World.new(DATA, seed: seed)
      enter_district(wn)
      wn.humans.dup.each { |h| h.take_hit(damage: h.hp, attacker: wn.possessed) until h.dead? }
      drive(wn, scripted({}), 1)
      wn.instance_variable_get(:@human_respawns)["district"].clear
      wn.drops.clear
      wn.send(:add_human, "district", :rusher, near_tile)
      near_h = wn.humans.find { |h| h.tile == near_tile }
      near_h.take_hit(damage: near_h.hp, attacker: wn.possessed) until near_h.dead?
      drive(wn, scripted({}), 1)
      near_drop = wn.drops.find { |d| d[:tile] == near_tile }
      refute_nil near_drop, "near kill must produce a drop"
      near_amount = near_drop[:amount]

      # --- Far world (same seed, same actions to reach the same RNG state) ---
      wf = Game::World.new(DATA, seed: seed)
      enter_district(wf)
      wf.humans.dup.each { |h| h.take_hit(damage: h.hp, attacker: wf.possessed) until h.dead? }
      drive(wf, scripted({}), 1)
      wf.instance_variable_get(:@human_respawns)["district"].clear
      wf.drops.clear
      wf.send(:add_human, "district", :rusher, far_tile)
      far_h = wf.humans.find { |h| h.tile == far_tile }
      far_h.take_hit(damage: far_h.hp, attacker: wf.possessed) until far_h.dead?
      drive(wf, scripted({}), 1)
      far_drop = wf.drops.find { |d| d[:tile] == far_tile }
      refute_nil far_drop, "far kill must produce a drop"
      far_amount = far_drop[:amount]

      # Same RNG roll, but far uses multiplier 2.0
      assert_equal (near_amount * 2.0).round, far_amount,
                   "deep kill (gate_distance>=28) must yield 2x the base: " \
                   "near=#{near_amount} (×1.0), far=#{far_amount} (×2.0), seed=#{seed}"
    end
  end
end
