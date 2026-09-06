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

  # --- E0 (T0 BLOCKER a1): the begun skill is the resolved skill ---------
  #
  # begin_action advances the rotation at start; before E0 action_config
  # re-read the MERGED kit, so a cast that began as skill N reported and
  # resolved as skill N+1 (and ember_boss phase 2 [dash, beam] crashed on a
  # nil @dash_plan when the advanced index pointed at the dash). The begun
  # skill is observed INDEPENDENTLY of action_config — the windup length
  # actually counted (set from the begun cfg at begin_action) and the dash
  # plan's presence (reserved_tile) — because before the fix EVERY
  # action_config read (handler, windup poll, active poll) agreed on the
  # same wrong skill; only the physics of the cast told the truth.

  def drive_casts(kind, hp_pct:, ticks:, dist:)
    stage!(kind, dist:)
    boss = world.humans.find { |h| h.kit_name == kind }
    boss.load_hp!((boss.max_hp * hp_pct) / 100)
    input = scripted({})
    casts = []
    prev = :idle
    ticks.times do
      frozen = world.feel.hitstop?
      input.update(world.frame)
      world.tick(input)
      state = boss.attack_state
      if state == :windup && prev != :windup && boss.current_action == :attack
        casts << { reported_arc: boss.action_config[:arc],
                   reported_windup: boss.action_config[:windup_frames],
                   dash_planned: !boss.reserved_tile.nil?,
                   observed_windup: 1 }
      elsif state == :windup && prev == :windup && casts.any? && !frozen
        casts.last[:observed_windup] += 1
      elsif state == :active && prev == :windup && casts.any?
        casts.last[:resolved_arc] = boss.action_config[:arc]
        # Physical signal (reviewer MINOR 1): a spread launches boss-owned
        # projectiles at active entry; melee arcs must not — keeps the test
        # convicting even if a retune ever equalizes the phase's windups.
        casts.last[:projectile] = world.projectiles.any? { |p| p.owner.equal?(boss) }
      elsif state == :idle && casts.any?
        # Reviewer MINOR 2: the snapshot must DIE with the cast — idle
        # between casts means @action_cfg was cleared, not just masked.
        assert_nil boss.instance_variable_get(:@action_cfg),
                   "@action_cfg leaked past the cast that set it"
      end
      prev = state
    end
    [boss, casts]
  end

  def test_started_skill_equals_reported_and_resolved_skill_across_a_multi_skill_phase
    _boss, casts = drive_casts(:serpent_boss, hp_pct: 50, ticks: 400, dist: 3) # phase 2: [spread 30f, arc3 40f]
    resolved = casts.select { |c| c[:resolved_arc] }
    assert_operator resolved.length, :>=, 2, "staging: fewer than two casts reached active: #{casts}"
    resolved.each do |c|
      assert_equal c[:reported_windup], c[:observed_windup],
                   "the windup that RAN is not the reported skill's windup — " \
                   "the cast began as one skill and reports another: #{casts}"
      assert_equal c[:reported_arc], c[:resolved_arc],
                   "a cast changed skill between start and resolution: #{casts}"
      assert_equal c[:reported_arc] == "spread", c[:projectile],
                   "a spread must launch boss projectiles at active entry; a melee arc must not: #{casts}"
    end
    assert_operator resolved.map { |c| c[:reported_arc] }.uniq.length, :>=, 2,
                    "staging: the phase never rotated through a second skill: #{casts}"
  end

  def test_ember_boss_multi_skill_phase_survives_and_dashes_carry_a_plan
    # ember_boss phase 2 (hp <= 50) = [dash 26f, beam 44f]: with the
    # off-by-one the cast after a beam start read the dash cfg and
    # activate_action crashed the session on @dash_plan.duration (nil).
    boss, casts = drive_casts(:ember_boss, hp_pct: 45, ticks: 300, dist: 5)
    assert_operator casts.length, :>=, 2, "staging: the boss cast fewer than twice in 300 ticks: #{casts}"
    casts.each do |c|
      assert_equal c[:reported_windup], c[:observed_windup], "begun != reported: #{casts}" if c[:resolved_arc]
      assert_equal c[:reported_arc] == "dash", c[:dash_planned],
                   "a dash cast must plan its run at start; a non-dash cast must not: #{casts}"
    end
    assert casts.map { |c| c[:reported_arc] }.include?("beam"), "phase 2 must reach its beam: #{casts}"
    assert boss # the drive completing IS the crash-regression assert
  end
end
