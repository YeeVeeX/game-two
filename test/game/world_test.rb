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

  def possess_kit(world, kit_name)
    world.pack.members.length.times do
      return world.possessed if world.possessed.kit_name == kit_name
      world.pack.swap_next!
    end
    flunk "could not possess #{kit_name}"
  end

  # Tap-steps the possessed toward dest one tile at a time (waits out tweens
  # and hitstop). Combat can shove it around; the loop just keeps correcting.
  def navigate_to(world, dest, guard: 3000)
    steps = 0
    until world.possessed.tile == dest || steps >= guard
      if world.possessed.walker.moving?
        drive(world, scripted({}), 1)
      else
        dx = (dest[0] - world.possessed.tile[0]).clamp(-1, 1)
        dy = (dest[1] - world.possessed.tile[1]).clamp(-1, 1)
        keys = []
        keys << (dx.positive? ? "right" : "left") unless dx.zero?
        keys << (dy.positive? ? "down" : "up") unless dy.zero?
        drive(world, scripted({ world.frame.to_s => keys }), 1)
      end
      steps += 1
    end
    assert_equal dest, world.possessed.tile, "navigation failed to reach #{dest}"
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

  def test_blocker_slam_hits_ring_and_interrupts_in_flight_rusher_windups
    enter_district(world)
    blocker = possess_kit(world, :blocker)
    blocker.interrupt_action!
    blocker.walker.teleport(12, 12)
    (world.pack.living - [blocker]).each_with_index do |member, i|
      member.walker.teleport(2, 12 + i)
    end
    a, b = world.humans.first(2)
    world.humans.replace([a, b])
    a.walker.teleport(11, 12)
    b.walker.teleport(13, 12)
    a.face([1, 0])
    b.face([-1, 0])
    assert a.start_attack
    assert b.start_attack
    assert_equal :windup, a.attack_state
    assert_equal :windup, b.attack_state

    assert blocker.start_special(blocked: world.blocked_for(blocker))
    blocker.kit[:special][:windup_frames].times { drive(world, scripted({}), 1) }

    assert_equal 20, a.hp
    assert_equal 20, b.hp
    assert a.staggered?
    assert b.staggered?
    assert_equal :idle, a.attack_state, "Slam overrides rusher interrupt_on_hit=false"
    assert_equal :idle, b.attack_state, "every ring victim has its windup canceled"
    assert_equal [9, 12], a.tile
    assert_equal [15, 12], b.tile
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

  # M2.1 fix 5: a projectile kit hugging its target was INERT (needs dist>=2).
  # Husk-grade repair: step away to open range, then fire.
  def test_adjacent_lobber_ally_opens_range_then_fires
    enter_district(world)
    lobber = world.pack.members.find { |m| m.kit_name == :lobber }
    refute_equal lobber, world.possessed, "lobber runs on AI in this scenario"
    target = world.humans.reject(&:dead?).first
    lobber.walker.teleport(target.tile[0] - 1, target.tile[1]) # adjacent = inert before the fix
    cheb = ->(a, b) { [(a[0] - b[0]).abs, (a[1] - b[1]).abs].max }
    fired = false
    opened = false
    world.bus.subscribe(:attack_started) { |e| fired ||= e[:attacker].equal?(lobber) }
    # The rusher counter-chases at similar footspeed, so distance at any fixed
    # frame is racy - assert range EVER opened, then that the lobber fired.
    900.times do
      break if fired
      drive(world, scripted({}), 1)
      opened ||= cheb.call(lobber.tile, target.tile) >= 2
    end
    assert opened, "adjacent lobber steps AWAY to open firing range"
    assert fired, "once range is open, the lobber fires"
  end

  # Review finding (M2.1): a CORNERED projectile kit (no neighbor increases
  # distance) must not freeze in place - it side-steps along the wall at
  # equal distance instead of standing motionless while it dies.
  def test_cornered_lobber_still_moves
    enter_district(world)
    lobber = world.pack.members.find { |m| m.kit_name == :lobber }
    refute_equal lobber, world.possessed, "lobber runs on AI in this scenario"
    hunter = world.humans.reject(&:dead?).first
    lobber.walker.teleport(1, 1)      # district map corner (walls at x=0, y=0)
    hunter.walker.teleport(2, 2)      # diagonal-adjacent: nothing increases distance
    moved = false
    40.times do
      drive(world, scripted({}), 1)
      moved ||= lobber.tile != [1, 1]
    end
    assert moved, "cornered lobber side-steps along the wall instead of deadlocking"
  end

  def test_hitstop_only_for_possessed_fights
    enter_district(world)
    # Swap away so the fighting happens between allies and rushers only.
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 1)
    hits_seen = 0
    suspect_frames = []
    forced_frames = []
    # A possessed death legitimately freezes (forced swap = on_kill); ally
    # hits in the SAME bus flush see that freeze. Excuse exactly the
    # forced-swap frames (an unpossessed ally's death must NOT be excused;
    # review tightening). possession_changed is emitted mid-flush and
    # processed AFTER same-frame hits, so reconcile post-hoc by frame.
    world.bus.subscribe(:possession_changed) do |e|
      forced_frames << world.frame if e[:forced]
    end
    world.bus.subscribe(:attack_hit) do |e|
      unless [e[:attacker], e[:victim]].any? { |c| c.equal?(world.possessed) }
        hits_seen += 1
        suspect_frames << world.frame if world.feel.hitstop?
      end
    end
    drive(world, scripted({}), 6000)
    assert_operator hits_seen, :>=, 1, "allies traded hits during the window"
    violations = suspect_frames - forced_frames
    assert_empty violations, "ally fights never freeze the world (law 5)"
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
    # This test isolates TRANSITIONS; clear the wave so the surround AI
    # can't body-block the return. Combat may have knocked the possessed off
    # the gate row, so NAVIGATE to the gate instead of assuming a straight walk.
    world.humans.dup.each { |h| kill(h, by: world.possessed) }
    gate = world.map.transitions.first[:at]
    guard = 0
    while world.zone_name == "district" && guard < 3000
      if world.possessed.walker.moving?
        drive(world, scripted({}), 1)
      else
        dx = (gate[0] - world.possessed.tile[0]).clamp(-1, 1)
        dy = (gate[1] - world.possessed.tile[1]).clamp(-1, 1)
        keys = []
        keys << (dx.positive? ? "right" : "left") unless dx.zero?
        keys << (dy.positive? ? "down" : "up") unless dy.zero?
        drive(world, scripted({ world.frame.to_s => keys }), 1)
      end
      guard += 1
    end
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

  def test_rushers_surround_instead_of_queuing
    enter_district(world)
    # Sample DURING the assault (the wave wipes an idle pack, so a post-hoc
    # check would see an empty street): record, each tick, the adjacency
    # geometry around the most-pressured pack member.
    best_sides = 0
    queued = false
    idle = scripted({})
    2500.times do
      idle.update(world.frame)
      world.tick(idle)
      break if world.states.current != :world
      world.pack.living.each do |m|
        dirs = adjacent_dirs(m)
        next if dirs.length < 2
        best_sides = [best_sides, dirs.uniq.length].max
        queued ||= dirs.uniq.length < dirs.length
      end
      break if best_sides >= 3
    end
    assert_operator best_sides, :>=, 2,
                    "converging rushers must pressure a body from >=2 distinct sides (pincer, not queue)"
  end

  def adjacent_dirs(member)
    tx, ty = member.tile
    world.humans.reject(&:dead?)
         .select { |h| [(h.tile[0] - tx).abs, (h.tile[1] - ty).abs].max <= 1 }
         .map { |h| [(h.tile[0] - tx).clamp(-1, 1), (h.tile[1] - ty).clamp(-1, 1)] }
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
    refute_includes world.corpses, corpse, "the original corpse prunes after the fade window"
  end

  def test_human_respawns_after_kill
    enter_district(world)
    count = world.humans.length
    target = nearest_human(world)
    kill(target, by: world.possessed)
    drive(world, scripted({}), 1)
    assert_equal count - 1, world.humans.length
    # Allies may kill more rushers during the wait (their respawns land later),
    # so assert the killed human's respawn by fresh-body identity, not headcount.
    roster_after_kill = world.humans.dup
    due = DATA["balance/combat"][:kits][:rusher][:respawn_frames]
    drive(world, scripted({}), due - 10)
    assert world.humans.all? { |h| roster_after_kill.include?(h) },
           "no respawn before the window elapses"
    drive(world, scripted({}), 20)
    assert world.humans.any? { |h| !roster_after_kill.include?(h) },
           "the killed human respawns as a fresh body after respawn_frames"
  end

  # M2 review finding 1: a respawn due while a body stands on its spawn tile
  # must DEFER, not stack two creatures on one tile.
  def test_respawn_defers_while_spawn_tile_occupied
    enter_district(world)
    world.humans.dup.each { |h| kill(h, by: world.possessed) }
    death_frame = world.frame
    drive(world, scripted({}), 1) # flush bus -> respawns scheduled
    camped = [10, 12] # a rusher home spawn (data/zones/district.json)
    navigate_to(world, camped)
    due = death_frame + DATA["balance/combat"][:kits][:rusher][:respawn_frames]
    drive(world, scripted({}), due + 5 - world.frame)
    assert world.humans.none? { |h| h.tile == camped },
           "respawn onto an occupied tile must defer, not stack"
    tiles = world.actors.map(&:tile)
    assert_equal tiles.uniq.length, tiles.length, "no stacking anywhere: #{tiles}"
    # Step off the spawn: the deferred respawn lands as soon as the tile frees.
    drive(world, scripted({ world.frame.to_s => ["right"] }), 3)
    assert world.humans.any? { |h| h.tile == camped },
           "deferred respawn lands once the spawn tile is free"
  end

  # M2 review finding 2: a kit WITHOUT respawn_frames must still leave the
  # roster on death — otherwise the renderer draws its ghost forever.
  def test_kit_without_respawn_frames_still_leaves_roster_on_death
    data = DATA.keys.to_h { |k| [k, DATA[k]] }
    balance = Marshal.load(Marshal.dump(data["balance/combat"]))
    balance[:kits][:rusher].delete(:respawn_frames)
    data = data.merge("balance/combat" => balance)
    w = Game::World.new(data)
    enter_district(w)
    count = w.humans.length
    target = nearest_human(w)
    kill(target, by: w.possessed)
    drive(w, scripted({}), 1)
    assert_equal count - 1, w.humans.length, "no-respawn kits leave the roster on death"
    refute_includes w.humans, target
    # The world stays live (allies keep hunting), so assert no ADDITIONS —
    # the roster may only shrink when nothing respawns.
    roster_before = w.humans.dup
    drive(w, scripted({}), 400)
    assert w.humans.all? { |h| roster_before.include?(h) }, "nothing ever respawns"
  end
end
