require_relative "../test_helper"
require "core/data_store"
require "core/tile_map"
require "core/tile_registry"
require "game/world"
require "app/renderer"
require "app/tile_art"

TILE_ART_DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

# MUNDO VIVO FASE 3 — tile faces are a pure function of grid + registry +
# palette. Pinned on a synthetic 5x4 map (no GL) and on every live zone.
class TileArtTest < Minitest::Test
  def registry = @registry ||= Core::TileRegistry.new(TILE_ART_DATA["tiles"])

  def synth(tiles)
    Core::TileMap.new({ name: "synth", display_name: "TEST", tile_size: 32, tiles: tiles,
                        palette: { floor: [10, 10, 10], grid: [1, 1, 1], wall: [100, 60, 40],
                                   water: [20, 40, 80], transition: [1, 1, 1] },
                        transitions: [], stations: [], enemy_spawns: {},
                        pack_spawn: [[1, 1], [2, 1], [3, 1]] })
  end

  def by_kind(rects)
    rects.group_by do |(_, _, _, h, rgb, a)|
      if rgb == [0, 0, 0] && a == 70 then :shadow
      elsif h == App::TileArt::FACE_H then :face
      elsif h == App::TileArt::RIM_H && a == 255 then :rim
      else :foam
      end
    end
  end

  def test_wall_over_floor_gets_a_face_and_the_floor_a_shadow
    m = synth(["#####",
               "#...#",
               "#...#",
               "#####"])
    k = by_kind(App::TileArt.rects(m, registry))
    # top wall row (y=0) faces the floor below at x=1..3 → ONE merged face run
    assert_equal 1, k[:face].length, k.inspect
    assert_equal [32, 32 - App::TileArt::FACE_H, 96, App::TileArt::FACE_H], k[:face][0][0, 4]
    assert_equal [62, 37, 25], k[:face][0][4], "face = wall darkened (0.62)"
    # floor row y=1 under the wall → one merged shadow run
    assert_equal 1, k[:shadow].length
    assert_equal [32, 32, 96, App::TileArt::SHADOW_H], k[:shadow][0][0, 4]
    # bottom wall row (y=3) has floor ABOVE → rim
    assert_equal 1, k[:rim].length
    assert_equal [32, 96, 96, App::TileArt::RIM_H], k[:rim][0][0, 4]
  end

  def test_water_edges_get_foam_only_toward_walkable_ground
    m = synth(["#####",
               "#.~.#",
               "#~~~#",
               "#####"])
    foam = by_kind(App::TileArt.rects(m, registry))[:foam] || []
    refute_empty foam
    # the (2,1) water tile: floor left and right → 2 vertical seams; water below → none there
    left = foam.find { |r| r[0] == 64 && r[1] == 32 && r[2] == App::TileArt::FOAM_W }
    right = foam.find { |r| r[0] == 96 - App::TileArt::FOAM_W && r[1] == 32 && r[2] == App::TileArt::FOAM_W }
    assert left && right, "vertical foam seams toward the floor tiles: #{foam.inspect}"
    refute foam.any? { |r| r[1] == 64 - App::TileArt::FOAM_W && r[0] == 64 && r[3] == App::TileArt::FOAM_W },
           "no foam between two water tiles"
  end

  def test_interior_tiles_carry_nothing
    m = synth(["#####",
               "#...#",
               "#...#",
               "#...#",
               "#####"])
    rects = App::TileArt.rects(m, registry)
    # center floor tile (2,2) has floor on all sides: no rect starts inside it
    assert rects.none? { |(x, y, *)| x == 64 && y == 64 }, rects.inspect
  end

  def test_every_live_zone_builds_faces_deterministically_and_on_map
    TILE_ART_DATA.keys.grep(%r{^zones/}).each do |key|
      m = Core::TileMap.new(TILE_ART_DATA[key])
      a = App::TileArt.rects(m, registry)
      b = App::TileArt.rects(m, registry)
      assert_equal a, b, "#{key}: not a pure function"
      a.each do |(x, y, w, h, rgb, alpha)|
        assert x >= 0 && y >= 0 && x + w <= m.pixel_width && y + h <= m.pixel_height, "#{key}: rect off-map #{[x, y, w, h]}"
        assert_equal 3, rgb.length
        assert alpha.between?(1, 255)
      end
    end
  end

  def test_new_decorative_tile_types_are_registered_and_safe
    %w[moss rubble bones lava_deco puddle roots].each do |id|
      t = registry.type(id)
      assert t, "#{id} missing from data/tiles.json"
      assert_equal "floor", t["passability"], "#{id}: decorative types never change passability (SAFE class)"
    end
    assert_equal "moss_sway", registry.type("moss")["ambience"]
    assert_equal "lava_glow", registry.type("lava_deco")["ambience"]
    assert_equal "ripples", registry.type("puddle")["ambience"]
  end

  def test_camp_uses_moss_and_puddle_and_stays_walkable_where_it_was
    m = Core::TileMap.new(TILE_ART_DATA["zones/camp"])
    chars = m.used_chars
    assert_includes chars, "m"
    assert_includes chars, "p"
    m.rows.times do |ty|
      m.cols.times do |tx|
        next unless %w[m p].include?(m.char_at(tx, ty))
        assert m.passable?(tx, ty), "camp #{[tx, ty]}: decorative tile must stay passable"
      end
    end
    assert m.palette[:moss] && m.palette[:puddle], "camp palette must color the new refs"
  end
end
