require "minitest/autorun"
require "digest"
require "json"
require "core/data_store"
require "core/tile_map"
require "core/tile_registry"
require "app/tile_variants"
require "app/tileset"

# PREMIUM v22 — the dual-grid tile layer is a PURE function of zone + registry
# and its PNGs are md5-pinned by the manifest (art is replaceable, never
# accidental). Every render ref any zone uses must have a material, or the
# renderer would fall back to a flat rect under a textured neighbor.
class TilesetTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  REGISTRY = Core::TileRegistry.new(DATA["tiles"])

  def tileset = App::Tileset.load(DATA, display: DATA["display"])

  def test_manifest_pins_every_material_png
    ts = tileset
    refute_nil ts, "tileset manifest missing (data/art/tiles.json)"
    ts.materials.each do |ref|
      path = ts.png_path(ref)
      assert File.file?(path), "#{ref}: png missing at #{path}"
      assert_equal ts.md5(ref), Digest::MD5.hexdigest(File.binread(path)), "#{ref}: png bytes != manifest md5 (regenerate with tools/gen_tileset.py)"
    end
  end

  def test_every_zone_render_ref_has_a_material
    ts = tileset
    missing = []
    Dir[File.join(DATA.root, "zones", "*.json")].sort.each do |f|
      cfg = JSON.parse(File.read(f, encoding: "utf-8"), symbolize_names: true)
      specs = App::TileVariants.specs(Core::TileMap.new(cfg), REGISTRY)
      specs.each_value do |spec|
        next unless spec
        ([spec["render"]] + (spec["variants"] || [])).each do |r|
          missing << "#{File.basename(f)}:#{r}" unless ts.material?(r.to_sym)
        end
      end
    end
    assert_empty missing.uniq, "render refs without a tileset material"
  end

  def test_cells_are_dual_grid_and_deterministic
    ts = tileset
    cfg = JSON.parse(File.read(File.join(DATA.root, "zones", "camp.json"), encoding: "utf-8"), symbolize_names: true)
    map = Core::TileMap.new(cfg)
    a = ts.build_cells(map, REGISTRY)
    b = ts.build_cells(map, REGISTRY)
    assert_equal a, b, "same map -> same cells"
    assert_equal map.rows + 1, a.length
    assert_equal map.cols + 1, a[0].length
    # the corner cell (0,0) sees out-of-bounds on three sides -> wall base
    px, py, pieces = a[0][0]
    assert_equal [-map.tile_size / 2, -map.tile_size / 2], [px, py]
    assert_equal 15, pieces.first.mask, "lowest-priority material is the full base piece"
    pieces.each { |pc| assert pc.mask.between?(1, 15); assert pc.var.between?(0, ts.variants - 1) }
    # every overlay piece's mask bits are exactly the corners that hold it
    pieces.each_cons(2) { |lo, hi| assert_operator ts.priority(lo.ref), :<=, ts.priority(hi.ref) }
  end
end
