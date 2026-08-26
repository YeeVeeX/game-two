require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/telemetry"

# v13 (D) challenge — the blocker's taunt evolved to a war-cry: radius 9,
# duration 450, telemetry cause :challenged (exeta amp res; the A0.6 ask's
# amp form). Spec: docs/superpowers/specs/2026-08-14-v13-aoe-specials-design.md §2.
# The lock MECHANISM (taunt!) is unchanged and stays covered by taunt_test;
# this file pins the evolution: numbers, cause plumbing, String->Symbol.
class ChallengeTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CHALLENGE = DATA["balance/combat"][:kits][:blocker][:special][:challenge]
  WINDUP = DATA["balance/combat"][:kits][:blocker][:special][:windup_frames]
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, n, input: scripted({}))
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    drive(world, STEP * 30, input: scripted(hold(:right, 0, STEP * 30 - 1)))
    assert_equal "district", world.zone_name
  end

  def possess_kit(world, kit_name)
    world.pack.members.length.times do
      return world.possessed if world.possessed.kit_name == kit_name
      world.pack.swap_next!
    end
    flunk "could not possess #{kit_name}"
  end

  def stage(world, blocker_at:, keep: 1)
    enter_district(world)
    blocker = possess_kit(world, :blocker)
    blocker.interrupt_action!
    blocker.walker.teleport(*blocker_at)
    (world.pack.living - [blocker]).each_with_index do |member, i|
      member.walker.teleport(2, 12 + i)
    end
    humans = world.humans.first(keep)
    world.humans.replace(humans)
    [blocker, humans]
  end

  def test_challenge_config_is_the_data_contract
    assert_equal 9, CHALLENGE[:range_tiles]
    assert_equal 450, CHALLENGE[:duration_frames]
    assert_equal "challenged", CHALLENGE[:cause]
  end

  def test_pulse_reaches_nine_and_spares_ten
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 2)
    inside, outside = humans
    inside.walker.teleport(21, 12)  # Chebyshev 9 — in
    outside.walker.teleport(22, 12) # Chebyshev 10 — out
    humans.each { |h| h.stagger!(600) }

    assert blocker.start_special(blocked: [])
    drive(world, WINDUP)
    assert_same blocker, inside.taunted_target
    assert_nil outside.taunted_target
  end

  def test_lock_lasts_challenge_duration
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 1)
    victim = humans.first
    victim.walker.teleport(15, 12)
    victim.stagger!(600)
    assert blocker.start_special(blocked: [])
    drive(world, WINDUP)
    assert_equal CHALLENGE[:duration_frames], victim.taunt_frames
  end

  # A challenge only RETARGETS a human focused ELSEWHERE (no focus change =
  # no event — semantic honesty). Stage a nearer decoy so the flip is real.
  def test_retarget_telemetry_reports_challenged_symbol
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 1)
    victim = humans.first
    victim.walker.teleport(16, 12)
    victim.stagger!(600)
    decoy = world.pack.members.find { |m| m.kit_name == :striker }
    decoy.walker.teleport(17, 12) # d=1: the victim acquires the decoy first
    victim.focus = nil # C2: drop the walk-era sticky focus; acquisition is the staging
    drive(world, 2)
    assert_same decoy, victim.focus, "staging: victim focused on the decoy"

    causes = []
    world.bus.subscribe(:human_retargeted) { |e| causes << e[:cause] }

    assert blocker.start_special(blocked: [])
    drive(world, WINDUP + 1) # pulse + the next assign_human_focus pass
    assert_includes causes, :challenged, "cause is the SYMBOL :challenged (String->Symbol at the data seam)"
  end

  def test_taunt_bang_default_cause_stays_taunt
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 1)
    victim = humans.first
    victim.taunt!(blocker, 100)
    assert_equal :taunt, victim.taunt_cause, "bare taunt! keeps the legacy cause"
    victim.taunt!(blocker, 100, cause: :challenged)
    assert_equal :challenged, victim.taunt_cause
  end

  def test_challenged_counts_on_the_a2_retarget_line
    telemetry = Game::Telemetry.new(world.bus, world:)
    blocker, humans = stage(world, blocker_at: [12, 12], keep: 1)
    victim = humans.first
    victim.walker.teleport(16, 12)
    victim.stagger!(600)
    decoy = world.pack.members.find { |m| m.kit_name == :striker }
    decoy.walker.teleport(17, 12)
    victim.focus = nil # C2: drop the walk-era sticky focus (same staging law as above)
    drive(world, 2)
    assert blocker.start_special(blocked: [])
    drive(world, WINDUP + 1)
    assert_match(/challenged=[1-9]/, telemetry.summary,
                 "a2 retargets line carries the challenged count")
  end
end
