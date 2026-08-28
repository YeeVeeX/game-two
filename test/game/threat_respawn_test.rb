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

  # --- global-frame catch-up (J-7 brief D3: EXISTING law, pinned) ----------

  # Respawn maturation is @frame arithmetic BY CONSTRUCTION: the record's
  # at_frame is global, and only the CURRENT zone's records process, so a
  # timer that elapsed while the pack was away materializes on the first
  # re-entry ticks. J-7's cold catch-up (zone_left_at) touches NONE of
  # this machinery — this pin names the law so a future change that makes
  # respawns re-arm at re-entry fails loudly.
  def test_respawn_timers_mature_against_the_global_frame_while_the_zone_is_frozen
    w = Game::World.new(DATA, seed: 31)
    enter_district(w)
    respawned = []
    w.bus.subscribe(:human_respawned) { |e| respawned << [e[:actor].kit_name, w.frame] }
    # Kill one rusher far from the gate; its respawn record starts aging.
    victim = w.humans.find { |h| h.kit_name == :rusher }
    victim.take_hit(damage: victim.hp, attacker: w.possessed)
    drive(w, scripted({}), 1) # flush: roster delete + respawn record
    death_frame = w.frame
    # Leave for nest and stay away past the full respawn delay.
    w.possessed.walker.teleport(1, 13)
    (w.pack.members - [w.possessed]).each_with_index { |m, i| m.walker.teleport(2, 12 + 2 * i) }
    guard = 0
    while w.zone_name == "district" && guard < 200
      drive(w, scripted({ w.frame.to_s => ["left"] }), 1)
      guard += 1
    end
    assert_equal "nest", w.zone_name, "staging: crossing must land"
    drive(w, scripted({}), RESPAWN + 200)
    assert_empty respawned, "a frozen zone's records never process while away"
    # Return; the elapsed timer was PAID during the absence.
    w.possessed.walker.teleport(28, 8)
    (w.pack.members - [w.possessed]).each_with_index { |m, i| m.walker.teleport(20, 8 + i) }
    guard = 0
    while w.zone_name == "nest" && guard < 200
      drive(w, scripted({ w.frame.to_s => ["right"] }), 1)
      guard += 1
    end
    assert_equal "district", w.zone_name, "staging: return crossing must land"
    # C2: ally motion no longer scatters the pack toward hostiles, so the
    # inherited release geometry moved — pin it explicitly instead: pack in
    # the far NW corner, living humans clustered east; the chosen tile then
    # sits clear of the pack-block (12) and corpse-guard (10) radii. The
    # SUBJECT (global-frame maturation) is untouched.
    w.possessed.walker.teleport(1, 1)
    (w.pack.members - [w.possessed]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    w.humans.reject(&:dead?).each_with_index { |h, i| h.walker.teleport(25 + i, 5) }
    drive(w, scripted({}), 60) # release checks re-run at re-entry; give them a beat
    assert_equal 1, respawned.length,
                 "a matured record materializes on the first re-entry ticks " \
                 "(catch-up by construction — the timer never re-arms)"
    assert_operator respawned.first[1] - death_frame, :>=, RESPAWN,
                    "the delay was served in global frames, not re-entry frames"
  end

  # --- depth gradient drops (A2) ------------------------------------------

  def test_drop_amounts_scale_with_gate_distance_bands
    # Band 0: gate_distance < 35, multiplier 1.0
    # Band 2: gate_distance >= 70, multiplier 2.0
    # Separate worlds with the same seed ensure the drop roll lands at the
    # same RNG position — only one kill per world, so table-draw index matches.
    near_tile = [11, 84]  # gate_distance 1 (band 0, mult 1.0)
    far_tile = [42, 13]   # gate_distance >= 70 (band 2, mult 2.0)

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
                   "deep kill (gate_distance>=70) must yield 2x the base: " \
                   "near=#{near_amount} (×1.0), far=#{far_amount} (×2.0), seed=#{seed}"
    end
  end
end
