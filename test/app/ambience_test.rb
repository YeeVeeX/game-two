require_relative "../test_helper"
require "core/data_store"
require "core/tile_map"
require "core/tile_registry"
require "game/world"
require "app/renderer"
require "app/ambience"

AMB_DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

# MUNDO VIVO FASE 2 — the living layer's contract, no GL context (no
# draw call here; geometry/selection are pure and that is what is pinned).
class AmbienceTest < Minitest::Test
  def registry = @registry ||= Core::TileRegistry.new(AMB_DATA["tiles"])
  def scene = @scene ||= App::Ambience.load(AMB_DATA, display: AMB_DATA["display"])
  def map(zone) = Core::TileMap.new(AMB_DATA["zones/#{zone}"])

  def test_presets_load_and_every_layer_is_wellformed
    presets = AMB_DATA["ambience"][:presets]
    refute_empty presets
    presets.each do |name, layers|
      refute_empty layers, "#{name}: empty preset"
      layers.each do |l|
        assert_includes %w[rect band tri spark], l[:shape].to_s, "#{name}: shape"
        assert_equal 3, l[:rgb].length, "#{name}: rgb"
        a0, a1 = l.fetch(:alpha, [40, 120])
        assert a0.between?(0, 255) && a1.between?(0, 255), "#{name}: alpha range"
        assert_operator l.fetch(:period, 60), :>=, 1, "#{name}: period"
      end
    end
  end

  def test_envelope_is_bounded_for_every_curve_and_phase
    %w[rise fall flat pulse].each do |curve|
      101.times do |i|
        e = App::Ambience.envelope(curve, i / 100.0)
        assert e.between?(-0.001, 1.001), "#{curve} @#{i}: #{e}"
      end
    end
  end

  def test_seed_is_stable_and_process_independent
    assert_equal App::Ambience.seed("zone_7", 3, 4), App::Ambience.seed("zone_7", 3, 4)
    refute_equal App::Ambience.seed("zone_7", 3, 4), App::Ambience.seed("zone_7", 4, 3)
    refute_equal App::Ambience.seed("zone_7", 3, 4), App::Ambience.seed("zone_8", 3, 4)
  end

  def test_sources_are_deterministic_and_reference_known_presets
    %w[zone_7 district_two zone_8 camp].each do |z|
      m = map(z)
      a = scene.sources(m, registry)
      b = App::Ambience.load(AMB_DATA, display: AMB_DATA["display"]).sources(m, registry)
      assert_equal a, b, "#{z}: sources differ between two loads (must be a pure function)"
      a.each do |(preset, tx, ty, _seed)|
        assert AMB_DATA["ambience"][:presets].key?(preset.to_sym), "#{z}: unknown preset #{preset}"
        assert tx.between?(0, m.cols - 1) && ty.between?(0, m.rows - 1), "#{z}: source off-map"
      end
    end
  end

  def test_pilot_zones_actually_breathe
    # lane G pilot: floor -2 submerged (bubbles + drips), the town's torches,
    # and the tiles.json door (every water tile shimmers, all zones).
    d2 = scene.sources(map("district_two"), registry).map(&:first).tally
    assert_operator d2.fetch("bubbles", 0), :>, 50, "floor -2 pilot: bubbles #{d2}"
    assert_operator d2.fetch("drips", 0), :>=, 3, "floor -2 pilot: drips #{d2}"
    z7 = scene.sources(map("zone_7"), registry).map(&:first).tally
    assert_equal 10, z7.fetch("torch_flicker", 0), "town torches (sidecar decor) #{z7}"
    assert_operator z7.fetch("water_shimmer", 0), :>, 0, "the well shimmers (tiles.json door) #{z7}"
  end

  # The gate law made concrete: sources must be identical across PROCESSES
  # (Ruby salts String#hash per process — a .hash anywhere in the seed path
  # flips frame_0000 between the two gate halves; caught live 2026-09-05).
  def test_sources_are_identical_across_processes
    here = scene.sources(map("district_two"), registry).first(40).inspect
    code = 'require "core/data_store"; require "core/tile_map"; require "core/tile_registry"; '            'require "game/world"; require "app/renderer"; require "app/ambience"; '            'd = Core::DataStore.new(ARGV[0]); r = Core::TileRegistry.new(d["tiles"]); '            'm = Core::TileMap.new(d["zones/district_two"]); '            'print App::Ambience.load(d, display: d["display"]).sources(m, r).first(40).inspect'
    other = IO.popen([RbConfig.ruby, "-I", File.expand_path("../../src", __dir__), "-e", code,
                      File.expand_path("../../data", __dir__)], &:read)
    assert_equal here, other, "ambience sources differ across processes (per-process hash salt leaked in)"
  end

  def test_display_switch_disables_the_layer
    off = App::Ambience.load(AMB_DATA, display: { ambience: false })
    refute off.enabled?
    assert scene.enabled?
  end

  def test_region_and_decor_riders_survive_tile_map_normalization
    m = map("district_two")
    r = m.regions.find { |x| x[:id] == "submerged_plain" }
    assert r, "pilot region missing (sidecar ambience_regions → importer)"
    assert_equal "bubbles", r[:ambience]
    assert_in_delta 0.10, r[:ambience_density], 0.0001
    t = map("zone_7").decor.select { |d| d[:kind] == "ambience" }
    assert_equal 10, t.length
    assert t.all? { |d| d[:preset] == "torch_flicker" }
  end
end
