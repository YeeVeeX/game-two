require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "core/tile_map"
require "game/world"

# MUNDO VIVO FASE 6.3+ — the MEDUSA TOWER floors (dungeon_2..). Every floor
# pins the SAME laws (tools/build_tower_floor.py builds them): everything
# walkable inside the ring, arrival one tile from every door, the FORCED
# LOOP (real path >= 1.8x Manhattan — Junior's law from the Tibia tower),
# fauna = serpent family within the tier rule, clear > the floor above
# (L6), stairs wired both ways with the level gate on the way DOWN.
class TowerFloorTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  XP = DATA["balance/progression"][:kill_xp]

  FLOORS = {
    "dungeon_2" => { above: "dungeon_1", above_exit: [33, 25], door_up: [28, 44], stairs_down: [33, 22], req: 8,
                     fauna: { stinger: 8, warden: 4, serpent_a: 10, serpent_b: 5 } },
    "dungeon_3" => { above: "dungeon_2", above_exit: [33, 22], door_up: [26, 44], stairs_down: [34, 27], req: 10,
                     fauna: { stinger: 6, warden: 4, serpent_a: 8, serpent_b: 8, serpent_c: 4 } },
    # the FUNDO: the C pattern's stairs tile is BOSS 2's arena side — the
    # tower ends here (no dungeon_5; the "stairs" tile stays a plain floor)
    "dungeon_4" => { above: "dungeon_3", above_exit: [34, 27], door_up: [26, 44], stairs_down: [14, 36], req: 12,
                     fauna: { warden: 4, serpent_a: 6, serpent_b: 8, serpent_c: 8, serpent_boss: 1 } }
  }.freeze

  def map(z) = Core::TileMap.new(DATA["zones/#{z}"])

  def bfs(m, start)
    dist = { start => 0 }
    q = [start]
    until q.empty?
      x, y = q.shift
      [[1, 0], [-1, 0], [0, 1], [0, -1]].each do |dx, dy|
        n = [x + dx, y + dy]
        next unless n[0].between?(0, m.cols - 1) && n[1].between?(0, m.rows - 1)
        next if !m.passable?(*n) || dist.key?(n)
        dist[n] = dist[[x, y]] + 1
        q << n
      end
    end
    dist
  end

  def clear_xp(zone)
    Game::World.new(DATA).tap { |w| w.start_in(zone) }.humans.map(&:kit_name).tally.sum { |k, n| XP[k] * n }
  end

  def test_floors_declare_shape_and_depth
    FLOORS.each do |z, f|
      m = map(z)
      n = z.split("_").last.to_i
      assert_equal "DUNGEON #{n}", m.display_name, "placeholder law"
      assert_equal(-n, m.floor, "the tower descends: floor -n")
      refute m.hub
      refute m.safe
      assert_equal 52, m.cols
      assert_equal 52, m.rows
    end
  end

  def test_everything_walkable_is_inside_the_ring_and_reachable
    FLOORS.each do |z, f|
      m = map(z)
      dist = bfs(m, m.pack_spawn.first)
      walkable = (0...m.rows).flat_map { |y| (0...m.cols).map { |x| [x, y] } }.select { |t| m.passable?(*t) }
      assert_equal walkable.length, dist.length, "#{z}: orphan walkable tiles outside the reachable disc"
      # the rock outside the tower is the SECOND wall class (never bare :wall)
      corner = m.char_at(1, 1)
      assert_equal "%", corner, "#{z}: outside the ring is rock (wall_inner)"
    end
  end

  def test_the_forced_loop_holds_from_arrival_to_the_stairs_down
    FLOORS.each do |z, f|
      m = map(z)
      dist = bfs(m, m.pack_spawn.first)
      real = dist.fetch(f[:stairs_down], nil)
      refute_nil real, "#{z}: stairs-down tile unreachable"
      manhattan = (f[:stairs_down][0] - f[:door_up][0]).abs + (f[:stairs_down][1] - f[:door_up][1]).abs
      assert_operator real.fdiv(manhattan), :>=, 1.8,
                      "#{z}: the volta must be forced (real #{real} vs manhattan #{manhattan}) — Junior's Tibia-tower law"
    end
  end

  def test_stairs_are_wired_both_ways_with_the_level_gate_going_down
    FLOORS.each do |z, f|
      up = map(z).transitions.find { |t| t[:to] == f[:above] }
      refute_nil up, "#{z}: no stairs up"
      assert_equal f[:door_up], up[:at]
      assert_equal "stairs_up", up[:type]
      assert_nil up[:requires_level], "the way back up is free"
      down = map(f[:above]).transitions.find { |t| t[:to] == z }
      refute_nil down, "#{f[:above]}: no stairs down to #{z}"
      assert_equal f[:above_exit], down[:at]
      assert_equal "stairs_down", down[:type]
      assert_equal f[:req], down[:requires_level], "the way down is the priced rung"
      # arrivals sit ONE tile from the door (ping-pong law) and are passable
      m = map(z)
      assert m.passable?(*down[:spawn]), "#{z}: arrival must be walkable"
      refute_equal f[:door_up], down[:spawn], "#{z}: arrival must not BE the door"
      assert_equal 1, (down[:spawn][0] - f[:door_up][0]).abs + (down[:spawn][1] - f[:door_up][1]).abs
      am = map(f[:above])
      assert am.passable?(*up[:spawn]), "#{f[:above]}: return arrival must be walkable"
      refute_equal f[:above_exit], up[:spawn]
    end
  end

  def test_fauna_is_the_serpent_family_and_the_clear_out_pays_the_floor_above
    FLOORS.each do |z, f|
      w = Game::World.new(DATA)
      w.start_in(z)
      assert_equal f[:fauna], w.humans.map(&:kit_name).tally, "#{z}: authored census"
      assert_operator clear_xp(z), :>, clear_xp(f[:above]), "#{z}: deeper pays more (L6 at the clear grain)"
    end
  end

  def test_descending_from_the_medusa_lands_beside_the_stairs_up
    w = Game::World.new(DATA)
    w.start_in("dungeon_1")
    w.instance_variable_get(:@progression).instance_variable_set(:@level, 8)
    body = w.possessed
    (w.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(32 + i, 24) }
    body.walker.teleport(33, 25)
    input = Core::ScriptedInput.new(frames: {})
    6.times { input.update(w.frame); w.tick(input) }
    assert_equal "dungeon_2", w.zone_name, "the center hole is now the tower's stairs"
    assert_equal [29, 44], body.tile, "arrival one tile inside the door (no ping-pong)"
    6.times { input.update(w.frame); w.tick(input) }
    assert_equal "dungeon_2", w.zone_name, "…and the pack STAYS (the door did not fire back)"
  end

  def test_cap_rides_the_floors
    # 15 -> 18 rode the tower (one step per floor); 18 -> 21 rides BRASA
    # (FASE 6.7) — plan §6, L5: the cap never outruns content.
    assert_equal 21, DATA["balance/progression"][:curve][:level_cap]
  end

  def test_the_tower_bottom_holds_boss_2_and_no_further_stairs
    m = map("dungeon_4")
    assert_nil m.transitions.find { |t| t[:type] == "stairs_down" }, "the FUNDO has no way further down"
    w = Game::World.new(DATA)
    w.start_in("dungeon_4")
    boss = w.humans.find { |h| h.kit_name == :serpent_boss }
    refute_nil boss, "BOSS 2 guards the bottom"
    assert boss.boss? && boss.boss_phase_count == 3
    dist = bfs(m, m.pack_spawn.first)
    assert_operator dist.fetch(boss.tile), :>=, 40, "BOSS 2 sits at the far end of the forced loop"
  end

  def test_the_frontier_and_tower_rungs_climb_monotonically
    reqs = FLOORS.map { |z, f| f[:req] }
    assert_equal reqs.sort, reqs, "8 -> 10 -> 12: deeper floors price higher"
    assert_operator reqs.first, :>=, 8, "the tower's first rung is the frontier's (zone_8 rope = 8)"
  end
end
