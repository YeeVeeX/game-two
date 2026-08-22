require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/state_digest"

# T2 sim-core integration against real Worlds: actor_died is the only XP
# income, the pack shares the level, stat growth reaches all damage shapes,
# and level/xp are digest truth.
class ProgressionIntegrationTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def world = Game::World.new(DATA, seed: 17)
  def idle = Core::ScriptedInput.new(frames: {})

  def kill(victim, by:)
    victim.take_hit(damage: victim.hp, attacker: by) until victim.dead?
  end

  def test_ally_kill_awards_pack_xp_levels_stats_and_emits_digest_truth
    w = world
    w.start_in("district")
    progression = w.progression
    amount = DATA["balance/progression"][:kill_xp][:rusher]
    progression.load_progress!(level: 1, xp: progression.delta_e(2) - amount)
    killer = w.pack.members.find { |member| !member.equal?(w.possessed) }
    victim = w.humans.find { |human| human.kit_name == :rusher }
    killer.take_hit(damage: 10, attacker: victim)
    before_stats = w.pack.members.to_h { |member| [member, [member.hp, member.max_hp]] }
    before_digest = Net::StateDigest.canonical(w.digest_snapshot)
    levels = []
    w.bus.subscribe(:level_up) { |event| levels << event[:level] }

    kill(victim, by: killer)
    w.tick(idle)

    assert_equal [2, 0, amount],
                 [progression.level, progression.xp, progression.kills_xp]
    assert_equal [2], levels, "one award crossing one boundary emits one final level"
    w.pack.members.each do |member|
      old_hp, old_max = before_stats.fetch(member)
      expected_max = progression.max_hp_for(member.kit[:max_hp])
      assert_equal expected_max, member.max_hp
      assert_equal old_hp + expected_max - old_max, member.hp,
                   "#{member.kit_name} must gain only the max-hp delta"
    end
    world_fields = w.digest_snapshot.to_h.fetch("world").to_h
    assert_equal 2, world_fields.fetch("level")
    assert_equal 0, world_fields.fetch("xp")
    refute_equal before_digest, Net::StateDigest.canonical(w.digest_snapshot)
  end

  def test_human_killer_does_not_feed_pack_progression
    w = world
    w.start_in("district")
    killer, victim = w.humans.first(2)

    kill(victim, by: killer)
    w.tick(idle)

    assert_equal [1, 0, 0],
                 [w.progression.level, w.progression.xp, w.progression.kills_xp]
  end

  def test_level_damage_reaches_melee_projectile_and_volley_at_launch
    w = world
    w.start_in("district")
    w.progression.load_progress!(level: 2, xp: 0)
    w.pack.sync_max_hp!(progression: w.progression)

    striker = w.pack.members.find { |member| member.kit_name == :striker }
    victim = w.humans.first
    melee = striker.kit[:attack]
    hp_before = victim.hp
    w.send(:apply_action_hit, striker, victim, melee)
    assert_equal hp_before - w.progression.damage_for(melee[:damage]), victim.hp

    lobber = w.pack.members.find { |member| member.kit_name == :lobber }
    projectile_cfg = lobber.kit[:attack]
    volley_cfg = lobber.kit[:special]
    w.send(:launch_projectile, lobber, projectile_cfg)
    w.send(:launch_volley, lobber, volley_cfg)
    projectile_damage = w.projectiles.last.damage
    impact_damage = w.impacts.last[:damage]
    assert_equal w.progression.damage_for(projectile_cfg[:damage]), projectile_damage
    assert_equal w.progression.damage_for(volley_cfg[:damage]), impact_damage

    enemy = w.humans.find { |human| !human.dead? }
    assert_equal enemy.kit[:attack][:damage],
                 w.send(:leveled_damage, enemy, enemy.kit[:attack]),
                 "enemy damage must never read pack level"

    w.progression.load_progress!(level: 3, xp: 0)
    assert_equal projectile_damage, w.projectiles.last.damage,
                 "in-flight projectiles keep launch-time damage"
    assert_equal impact_damage, w.impacts.last[:damage],
                 "delayed impacts keep launch-time damage"
  end
end
