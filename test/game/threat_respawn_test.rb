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
  #
  # The block-radius pin moved to density_respawn_test (v11): the landing
  # tile is now chosen at RELEASE time, so the defer law binds on the
  # CHOSEN tile — see test_respawn_defers_while_the_pack_covers_every_
  # scatter_tile for the suppression law under release-time anchoring.
  # BLOCK is still asserted sane in threat_data_test.

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
