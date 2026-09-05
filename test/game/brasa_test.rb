require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "core/tile_map"
require "game/world"

# MUNDO VIVO FASE 6.7 — BRASA (DUNGEON 5/6/7, ember family, BOSS 4). Built
# by tools/build_brasa.py from peer-approved geometry; these pin the laws:
# mouth in ZONE 7's south meadow (rung 13), stairs both ways (rungs 15/17
# down, free up), arrivals one tile from doors, clears climb above the
# tower's bottom (L6), the maze room holds the GUARDIAN, the hall's dais
# holds BOSS 4 and nothing descends further.
class BrasaTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  XP = DATA["balance/progression"][:kill_xp]

  def map(z) = Core::TileMap.new(DATA["zones/#{z}"])

  def clear_xp(zone)
    Game::World.new(DATA).tap { |w| w.start_in(zone) }.humans.map(&:kit_name).tally.sum { |k, n| XP[k] * n }
  end

  def test_three_floors_declare_shape_and_labels
    [["ember_1", "DUNGEON 5", -1], ["ember_2", "DUNGEON 6", -2], ["ember_3", "DUNGEON 7", -3]].each do |z, label, fl|
      m = map(z)
      assert_equal label, m.display_name, "placeholder law (strings table carries the label too)"
      assert_equal fl, m.floor
      refute m.hub
      refute m.safe
    end
  end

  def test_the_mouth_is_in_zone_7s_south_meadow_at_the_frontier_plus_one_rung
    mouth = map("zone_7").transitions.find { |t| t[:to] == "ember_1" }
    refute_nil mouth
    assert_equal "hole", mouth[:type], "falling in commits (the dungeon_1 hole grammar)"
    assert_equal 13, mouth[:requires_level], "BRASA opens above the tower's last rung (12)"
    assert map("zone_7").passable?(*mouth[:at])
    assert map("ember_1").passable?(*mouth[:spawn])
    back = map("ember_1").transitions.find { |t| t[:to] == "zone_7" }
    assert_equal "rope_spot", back[:type], "climbing out is the interact verb"
    assert_nil back[:requires_level], "the way back is free"
    assert map("zone_7").passable?(*back[:spawn])
    refute_equal mouth[:at], back[:spawn], "the rope lands beside the hole, never on it"
  end

  def test_stairs_chain_with_climbing_rungs_and_free_returns
    [["ember_1", "ember_2", 15], ["ember_2", "ember_3", 17]].each do |from, to, rung|
      down = map(from).transitions.find { |t| t[:to] == to }
      refute_nil down, "#{from}: no stairs down"
      assert_equal "stairs_down", down[:type]
      assert_equal rung, down[:requires_level]
      assert map(to).passable?(*down[:spawn])
      up = map(to).transitions.find { |t| t[:to] == from }
      refute_nil up
      assert_equal "stairs_up", up[:type]
      assert_nil up[:requires_level]
      assert map(from).passable?(*up[:spawn])
      refute_equal down[:at], up[:spawn], "return lands beside the stairs, not on them"
    end
    assert_nil map("ember_3").transitions.find { |t| t[:type] == "stairs_down" }, "the forge heart is the bottom"
  end

  def test_fauna_is_the_ember_family_and_clears_climb_above_the_tower
    tower_bottom = clear_xp("dungeon_4")
    clears = %w[ember_1 ember_2 ember_3].map { |z| clear_xp(z) }
    assert_operator clears[0], :>, tower_bottom, "BRASA's first floor out-pays the tower's bottom (deeper dungeon pays more)"
    assert_equal clears, clears.sort, "monotonic inside BRASA (L6)"
    %w[ember_1 ember_2 ember_3].each do |z|
      kinds = Game::World.new(DATA).tap { |w| w.start_in(z) }.humans.map(&:kit_name).uniq
      assert kinds.all? { |k| k.to_s.start_with?("ember") }, "#{z}: one dungeon, one family (#{kinds})"
    end
  end

  def test_the_maze_holds_a_guardian_and_the_hall_holds_boss_4_on_the_dais
    w2 = Game::World.new(DATA).tap { |w| w.start_in("ember_2") }
    guardian = w2.humans.find { |h| h.tile == [54, 13] }
    refute_nil guardian, "the maze's boss room is occupied"
    assert_equal :ember_d, guardian.kit_name, "guardian = the elite beam caster (D3: guardian + final)"
    w3 = Game::World.new(DATA).tap { |w| w.start_in("ember_3") }
    boss = w3.humans.find { |h| h.kit_name == :ember_boss }
    refute_nil boss
    assert_equal [49, 15], boss.tile, "BOSS 4 on the dais"
    assert boss.boss? && boss.boss_phase_count == 3
  end

  def test_lava_and_rubble_dress_the_floors_without_touching_passability
    %w[ember_1 ember_2 ember_3].each do |z|
      m = map(z)
      assert_includes m.used_chars, "L", "#{z}: lava pools dress the basalt"
      m.rows.times do |ty|
        m.cols.times do |tx|
          next unless %w[L r].include?(m.char_at(tx, ty))
          assert m.passable?(tx, ty), "#{z} #{[tx, ty]}: decorative tiles stay passable (SAFE class)"
        end
      end
    end
  end

  def test_falling_into_brasa_lands_beside_the_rope_and_stays
    w = Game::World.new(DATA)
    w.start_in("zone_7")
    w.instance_variable_get(:@progression).instance_variable_set(:@level, 13)
    body = w.possessed
    (w.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(5 + i, 23) }
    body.walker.teleport(6, 24)
    input = Core::ScriptedInput.new(frames: {})
    6.times { input.update(w.frame); w.tick(input) }
    assert_equal "ember_1", w.zone_name
    6.times { input.update(w.frame); w.tick(input) }
    assert_equal "ember_1", w.zone_name, "no ping-pong"
  end
end
