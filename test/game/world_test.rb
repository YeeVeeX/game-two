require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Integration tests against the REAL data files and the REAL sim — no mocks.
# All assertions are on TILES, not pixels (grid movement doctrine).
class WorldTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]
  EXHAUST = DATA["balance/combat"][:kits][:striker][:attack][:exhaust_frames]
  STAGGER = DATA["balance/combat"][:pack][:swap_stagger_frames]

  def world = @world ||= Game::World.new(DATA)

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

  def nearest_human(world)
    px, py = world.possessed.tile
    world.humans.reject(&:dead?).min_by { |h| [(h.tile[0] - px).abs, (h.tile[1] - py).abs].max }
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  # --- pack + possession -------------------------------------------------

  def test_pack_of_three_spawns_in_nest
    assert_equal 3, world.pack.members.length
    assert_equal world.map.pack_spawn.take(3).sort, world.pack.members.map(&:tile).sort
    assert_equal world.pack.members.first, world.possessed
    assert_empty world.humans
  end

  def test_tab_swaps_to_next_living
    a = world.possessed
    drive(world, scripted({ "0" => ["swap"] }), 1)
    refute_equal a, world.possessed, "Tab moves possession"
    refute world.possessed.staggered?, "voluntary swap has no stagger"
  end

  def test_held_swap_does_not_autorepeat
    swaps = 0
    world.bus.subscribe(:possession_changed) { swaps += 1 }
    drive(world, scripted(hold(:swap, 0, 29)), 30)
    assert_equal 1, swaps, "30 held frames = exactly one swap (rising edge)"
  end

  def test_forced_swap_on_possessed_death_with_stagger
    changes = []
    world.bus.subscribe(:possession_changed) { |e| changes << e }
    victim = world.possessed
    hunter = world.pack.members[1] # any creature works as attacker identity
    kill(victim, by: hunter)
    drive(world, scripted({}), 1) # flush bus
    assert_equal 1, changes.length
    assert changes.first[:forced]
    refute_equal victim, world.possessed
    assert world.possessed.staggered?, "forced swap pays the stagger (law 2)"
    assert_equal :world, world.states.current, "forced swap is NOT a state change"
  end

  def test_tab_refused_while_staggered_death_penalty_always_lands
    victim = world.possessed
    hunter = world.pack.members[1]
    kill(victim, by: hunter)
    drive(world, scripted({}), 1) # flush bus -> forced swap + stagger
    staggered_body = world.possessed
    assert staggered_body.staggered?
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 1)
    assert_equal staggered_body, world.possessed,
                 "Tab during forced-swap stagger must be refused (law 2: the beat lands)"
    # +10 slack: the kill's hitstop freezes tick_body, so the stagger clock
    # runs slower than wall ticks for its first ~8 frames.
    drive(world, scripted({}), STAGGER + 10)
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 1)
    refute_equal staggered_body, world.possessed, "Tab works again once the stagger expires"
  end

  def test_wipe_respawns_whole_pack_in_nest
    wiped = false
    world.bus.subscribe(:pack_wiped) { wiped = true }
    enter_district(world)
    hunter = world.humans.first
    world.pack.members.each { |m| kill(m, by: hunter) }
    drive(world, scripted({}), 1)
    assert wiped
    assert_equal :nest_respawn, world.states.current
    drive(world, scripted({}), DATA["balance/combat"][:respawn_frames] + 5)
    assert_equal :world, world.states.current
    assert_equal "nest", world.zone_name, "wipe sends the pack home"
    assert world.pack.members.all? { |m| m.hp == m.max_hp }, "everyone revives full"
  end

  # --- combat laws ---------------------------------------------------------

  def test_held_attack_swings_at_exhaust_pace
    starts = 0
    world.bus.subscribe(:attack_started) { starts += 1 }
    drive(world, scripted(hold(:attack, 0, EXHAUST * 3 - 1)), EXHAUST * 3)
    assert_equal 3, starts, "held attack = one swing per exhaust window, not per frame"
  end

  def test_swap_is_exhaust_inert
    a = world.possessed
    drive(world, scripted({ "0" => ["attack"] }), 1)
    refute a.exhaust_ready?, "a just paid its exhaust"
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 1)
    b = world.possessed
    assert b.exhaust_ready?, "b's own clock governs — swap transfers nothing (law 4)"
    refute a.exhaust_ready?, "a's clock keeps counting unpossessed"
  end

  def test_ally_ai_fights_humans
    enter_district(world)
    ally_kills = 0
    world.bus.subscribe(:actor_died) do |e|
      ally_kills += 1 if e[:faction] == :human && e[:killer].faction == :pack && !e[:killer].equal?(world.possessed)
    end
    # Possessed idles at the gate; allies must engage approaching rushers alone.
    drive(world, scripted({}), 9000)
    assert_operator ally_kills, :>=, 1, "unpossessed allies fight on their own (husk-grade AI)"
  end

  def test_hitstop_only_for_possessed_fights
    enter_district(world)
    # Swap away so the fighting happens between allies and rushers only.
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 1)
    hits_seen = 0
    stops_during_ally_hits = 0
    world.bus.subscribe(:attack_hit) do |e|
      unless [e[:attacker], e[:victim]].any? { |c| c.equal?(world.possessed) }
        hits_seen += 1
        stops_during_ally_hits += 1 if world.feel.hitstop?
      end
    end
    drive(world, scripted({}), 6000)
    assert_operator hits_seen, :>=, 1, "allies traded hits during the window"
    assert_equal 0, stops_during_ally_hits, "ally fights never freeze the world (law 5)"
  end

  # --- carried grid invariants (rewritten from v2 suite) -------------------

  def test_held_key_walks_tile_by_tile
    input = scripted(hold(:right, 0, STEP * 3 - 1))
    x0, y0 = world.possessed.tile
    drive(world, input, STEP * 3)
    assert_equal [x0 + 3, y0], world.possessed.tile
  end

  def test_zone_transition_moves_whole_pack
    enter_district(world)
    tiles = world.pack.living.map(&:tile)
    assert_equal tiles.uniq.length, tiles.length, "no shared tiles on arrival"
    tiles.each { |t| assert world.map.passable?(*t) }
    # The entry walk overshoots east past the arrival gate, so the return
    # needs the full width back (+1 step slack for the landing tween).
    back = scripted(hold(:left, world.frame, world.frame + STEP * 20 - 1))
    drive(world, back, STEP * 21)
    assert_equal "nest", world.zone_name
  end

  def test_rushers_hunt_the_nearest_pack_member_not_the_possessed
    enter_district(world)
    # The possessed walks north away from the gate; allies hold near it. The
    # rushers must engage whoever is nearest — assert SOME ally takes a hit
    # while the possessed keeps distance.
    ally_hit = false
    world.bus.subscribe(:attack_hit) do |e|
      ally_hit = true if e[:victim].faction == :pack && !e[:victim].equal?(world.possessed)
    end
    drive(world, scripted(hold(:up, world.frame, world.frame + STEP * 6 - 1)), STEP * 6)
    drive(world, scripted({}), 6000)
    assert ally_hit, "humans target nearest pack creature, not the camera"
  end

  def test_determinism_same_script_same_state_with_swaps
    script = hold(:right, 0, STEP * 20).merge(
      (STEP * 21).to_s => %w[swap],
      (STEP * 25).to_s => %w[attack],
      (STEP * 30).to_s => %w[swap]
    )
    states = [Game::World.new(DATA), Game::World.new(DATA)].map do |w|
      input = scripted(script)
      drive(w, input, 4000)
      [w.zone_name, w.frame,
       w.pack.members.map { |m| [m.tile, m.hp, m.x, m.y] },
       w.humans.map { |h| [h.tile, h.hp] }]
    end
    assert_equal states[0], states[1]
  end

  def test_body_blocking_no_two_creatures_share_a_tile
    enter_district(world)
    drive(world, scripted({}), 4000)
    tiles = world.actors.map(&:tile)
    assert_equal tiles.uniq.length, tiles.length,
                 "no two living creatures may occupy one tile: #{tiles}"
  end

  def test_corpses_persist_then_fade
    enter_district(world)
    target = nearest_human(world)
    at = target.tile
    kill(target, by: world.possessed)
    drive(world, scripted({}), 1)
    corpse = world.corpses.find { |c| c[:tile] == at }
    refute_nil corpse, "a kill leaves a corpse record where the body fell"
    assert_equal :human, corpse[:faction]
    drive(world, scripted({}), 700) # past the 600f fade
    assert_nil world.corpses.find { |c| c[:tile] == at }, "corpses prune after the fade window"
  end

  def test_human_respawns_after_kill
    enter_district(world)
    count = world.humans.length
    target = nearest_human(world)
    kill(target, by: world.possessed)
    drive(world, scripted({}), 1)
    assert_equal count - 1, world.humans.length
    drive(world, scripted({}), DATA["balance/combat"][:kits][:rusher][:respawn_frames] + 10)
    assert_equal count, world.humans.length
  end
end
