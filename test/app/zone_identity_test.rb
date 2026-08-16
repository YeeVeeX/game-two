require_relative "../test_helper"
require "core/tile_map"
require "app/zone_identity"

# v16 (b): zone identity is PURE policy — motif placement is integer
# arithmetic on the tile grid ((tx*7+ty*13+seed)%9 style, no floats, no
# RNG), decor is authored data, ambient is a flat post-map tint. Absent
# keys = empty output = today's look (fallback law).
class ZoneIdentityTest < Minitest::Test
  BASE = {
    tile_size: 32,
    display_name: "Probe",
    tiles: [
      "########",
      "#......#",
      "#......#",
      "#......#",
      "########",
    ],
    pack_spawn: [[1, 1], [2, 1], [3, 1]],
    palette: { floor: [10, 10, 10], grid: [20, 20, 20], wall: [100, 100, 100],
               transition: [235, 190, 90] },
  }.freeze

  def map_with(palette_extra = {}, decor: nil)
    cfg = Marshal.load(Marshal.dump(BASE))
    cfg[:palette].merge!(palette_extra)
    cfg[:decor] = decor if decor
    Core::TileMap.new(cfg)
  end

  # --- fallback (the comparability law) ---------------------------------

  def test_absent_motif_key_yields_no_rects
    assert_empty App::ZoneIdentity.motif_rects(map_with)
  end

  def test_absent_decor_yields_no_rects
    assert_empty App::ZoneIdentity.decor_rects(map_with)
  end

  def test_absent_ambient_yields_nil
    assert_nil App::ZoneIdentity.ambient(map_with)
  end

  # --- motif -------------------------------------------------------------

  def motif_map(glyph = "chip", seed: 0)
    map_with({ motif: glyph, motif_rgb: [40, 40, 40], motif_seed: seed })
  end

  def test_motif_rects_are_deterministic_integer_geometry
    a = App::ZoneIdentity.motif_rects(motif_map)
    b = App::ZoneIdentity.motif_rects(motif_map)
    assert_equal a, b, "same map -> same rects (replay law)"
    refute_empty a
    a.flatten.each { |v| assert_kind_of Integer, v }
  end

  def test_motif_lands_only_on_passable_tiles_at_sparse_density
    map = motif_map
    eligible = []
    map.rows.times do |ty|
      map.cols.times do |tx|
        eligible << [tx, ty] if map.passable?(tx, ty) && ((tx * 7 + ty * 13) % 9).zero?
      end
    end
    rects = App::ZoneIdentity.motif_rects(map)
    tiles_hit = rects.map { |(x, y, _, _)| [x / 32, y / 32] }.uniq
    assert_equal eligible.sort, tiles_hit.sort,
                 "one glyph per eligible passable tile, nothing else"
  end

  def test_motif_seed_shifts_the_pattern
    refute_equal App::ZoneIdentity.motif_rects(motif_map),
                 App::ZoneIdentity.motif_rects(motif_map(seed: 3))
  end

  def test_motif_rects_stay_inside_their_tile
    App::ZoneIdentity.motif_rects(motif_map).each do |(x, y, w, h)|
      tx = x / 32
      ty = y / 32
      assert_operator x, :>=, tx * 32
      assert_operator y, :>=, ty * 32
      assert_operator x + w, :<=, tx * 32 + 32
      assert_operator y + h, :<=, ty * 32 + 32
    end
  end

  def test_every_glyph_vocabulary_entry_renders
    App::ZoneIdentity::GLYPHS.each do |g|
      refute_empty App::ZoneIdentity.motif_rects(motif_map(g)), "glyph #{g} drew nothing"
    end
  end

  def test_unknown_glyph_raises
    assert_raises(ArgumentError) { App::ZoneIdentity.motif_rects(motif_map("swoosh")) }
  end

  # --- decor -------------------------------------------------------------

  def test_stain_spans_its_tile_rect
    map = map_with({}, decor: [{ kind: "stain", at: [2, 2], w: 3, h: 2,
                                 rgb: [30, 60, 50], alpha: 70 }])
    rects = App::ZoneIdentity.decor_rects(map)
    assert_equal 1, rects.length
    x, y, w, h, rgb, alpha = rects.first
    assert_equal [2 * 32, 2 * 32, 3 * 32, 2 * 32], [x, y, w, h]
    assert_equal [30, 60, 50], rgb
    assert_equal 70, alpha
  end

  def test_brazier_is_a_base_plus_ember_core
    map = map_with({}, decor: [{ kind: "brazier", at: [1, 0],
                                 rgb: [235, 120, 40], alpha: 255 }])
    rects = App::ZoneIdentity.decor_rects(map)
    assert_equal 2, rects.length, "base + core"
    core = rects.last
    assert_equal [235, 120, 40], core[4], "the ember core carries the authored rgb"
    assert_operator core[2], :<, rects.first[2], "core is smaller than base"
  end

  def test_edge_is_a_thin_strip_along_the_tile_top
    map = map_with({}, decor: [{ kind: "edge", at: [1, 4], w: 6,
                                 rgb: [130, 170, 150], alpha: 90 }])
    rects = App::ZoneIdentity.decor_rects(map)
    assert_equal 1, rects.length
    x, y, w, h, = rects.first
    assert_equal [1 * 32, 4 * 32, 6 * 32], [x, y, w]
    assert_operator h, :<=, 4, "a lip highlight, not a bar"
  end

  def test_unknown_decor_kind_raises
    map = map_with({}, decor: [{ kind: "fountain", at: [2, 2], rgb: [1, 2, 3], alpha: 9 }])
    assert_raises(ArgumentError) { App::ZoneIdentity.decor_rects(map) }
  end

  # --- ambient -----------------------------------------------------------

  def test_ambient_passes_the_rgba_through
    map = map_with({ ambient_rgba: [40, 160, 120, 14] })
    assert_equal [40, 160, 120, 14], App::ZoneIdentity.ambient(map)
  end
end
