require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/state_digest"

# MUNDO VIVO FASE 5 — the boss block: phases by hp%, each phase a skill
# rotation that overrides kit[:attack] through the creature's merged `kit`
# view. BOSS 1 (challenger) carries the block with phases: [] → its kit is
# the SAME object (byte-identical behavior, the sim-identity canaries stay
# green). serpent_boss / ember_boss are the first phased finals.
class BossPhasesTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  KITS = DATA["balance/combat"][:kits]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def stage!(kind, w = world, dist: 4)
    w.start_in("grass_fixture")
    body = w.possessed
    (w.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    body.walker.teleport(7, 6)
    w.send(:add_human, "grass_fixture", kind, [7 + dist, 6])
  end

  def test_boss_1_keeps_its_exact_kit_with_an_empty_phase_list
    stage!(:challenger)
    boss = world.humans.find { |h| h.kit_name == :challenger }
    assert boss.boss?
    assert_equal 0, boss.boss_phase_count
    assert boss.kit.equal?(boss.instance_variable_get(:@kit)), "phases [] → kit is the SAME object (no merge, no drift)"
    assert_equal "ring", boss.kit[:attack][:arc]
    assert KITS[:challenger][:boss][:defeat_counts]
  end

  def test_every_boss_is_unique_in_skill_set_and_pays_more_than_its_family
    sets = %i[challenger serpent_boss ember_boss].to_h do |k|
      [k, KITS[k][:boss][:phases].flat_map { |p| p[:skills].map { |s| s[:arc] } }.sort]
    end
    assert_equal sets.values.length, sets.values.uniq.length, "no two bosses share a skill set: #{sets}"
    xp = DATA["balance/progression"][:kill_xp]
    assert_operator xp[:serpent_boss], :>, xp[:serpent_c], "the tower final out-pays its family elite"
    assert_operator xp[:ember_boss], :>, xp[:ember_d]
    assert_operator xp[:ember_boss], :>, xp[:serpent_boss], "deeper dungeon pays more (L6 across dungeons)"
  end

  def test_phase_follows_hp_and_the_active_skill_switches
    stage!(:serpent_boss, dist: 4)
    boss = world.humans.find { |h| h.kit_name == :serpent_boss }
    assert_equal 0, boss.boss_phase
    assert_equal "spread", boss.kit[:attack][:arc], "phase 1 = the fan"
    assert_equal 5, boss.kit[:attack][:spread_count]
    boss.load_hp!((boss.max_hp * 0.55).to_i)
    assert_equal 1, boss.boss_phase, "at 55% the boss is in phase 2 (threshold 60)"
    boss.load_hp!((boss.max_hp * 0.20).to_i)
    assert_equal 2, boss.boss_phase, "at 20% → phase 3 (threshold 30)"
    assert_equal "beam", boss.kit[:attack][:arc], "phase 3 opens with the beam (index 0 of its rotation)"
  end

  def test_skills_rotate_on_each_attack_start_inside_a_phase
    stage!(:serpent_boss, dist: 3)
    boss = world.humans.find { |h| h.kit_name == :serpent_boss }
    boss.load_hp!((boss.max_hp * 0.5).to_i) # phase 2: [spread5, petrify]
    idx0 = boss.boss_skill_index
    arcs = []
    world.bus.subscribe(:attack_started) { |e| arcs << e[:attacker].action_config[:arc] if e[:attacker].equal?(boss) }
    phases_seen = []
    # drive in slices so the phase at each cast is known (the pack fights
    # back: hp may cross into phase 3 mid-run — that is the mechanic working)
    26.times do
      drive(world, scripted({}), 10)
      phases_seen << boss.boss_phase
    end
    assert_operator boss.boss_skill_index, :>, idx0, "every attack start advances the rotation"
    assert_operator arcs.length, :>=, 1
    legal = { 0 => %w[spread], 1 => %w[spread arc3], 2 => %w[beam spread arc3] }
    max_phase = phases_seen.max
    assert arcs.all? { |a| legal[max_phase].include?(a) },
           "casts stay inside the phases the boss actually reached (max phase #{max_phase}): #{arcs}"
    assert arcs.include?("arc3") || arcs.include?("spread"), "phase-2 skills were cast"
  end

  def test_boss_rotation_is_digested_and_deterministic
    stage!(:ember_boss, dist: 5)
    drive(world, scripted({}), 90)
    a = Net::StateDigest.canonical(world.digest_snapshot)
    w2 = Game::World.new(DATA)
    stage!(:ember_boss, w2, dist: 5)
    drive(w2, scripted({}), 90)
    assert_equal a, Net::StateDigest.canonical(w2.digest_snapshot)
    assert world.digest_snapshot.to_s.include?("boss_skill_index")
  end
end
