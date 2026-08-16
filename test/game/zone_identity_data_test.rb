require_relative "../test_helper"
require "core/data_store"
require "core/tile_map"
require "app/motif"

# v16 (b): the zone-identity data contract. Hue carries identity; the
# VALUE structure is law (wall reads lighter than floor everywhere), the
# ambient is a tint and never a veil, the motif is subordinate texture,
# and gold stays reserved for walkable markers (no identity channel may
# claim it — the review-caught brazier-gold conflict, encoded).
class ZoneIdentityDataTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ZONES = %w[nest camp district district_two slow_door low_quay].freeze

  # Integer relative-luminance proxy (BT.709 weights x10000).
  def lum((r, g, b)) = 2126 * r + 7152 * g + 722 * b

  def each_zone(&) = ZONES.each { |z| yield z, DATA["zones/#{z}"] }

  def test_every_zone_declares_the_identity_block
    each_zone do |z, cfg|
      p = cfg[:palette]
      refute_nil p[:motif], "#{z} names a motif glyph"
      refute_nil p[:motif_rgb], "#{z} colors its motif"
      refute_nil p[:ambient_rgba], "#{z} declares its light"
    end
  end

  def test_motif_glyphs_are_real_and_families_read_distinct
    each_zone do |z, cfg|
      assert_includes App::Motif::GLYPHS.keys, cfg[:palette][:motif], z
    end
    glyphs = ZONES.map { |z| DATA["zones/#{z}"][:palette][:motif] }
    assert_operator glyphs.uniq.length, :>=, 4,
                    "zone families read distinct (the two vigils may share)"
  end

  def test_wall_reads_lighter_than_floor_everywhere
    each_zone do |z, cfg|
      p = cfg[:palette]
      assert_operator lum(p[:wall]), :>, lum(p[:floor]) * 2,
                      "#{z}: the wall/floor value law holds with margin"
    end
  end

  def test_motif_is_subordinate_texture_never_structure
    each_zone do |z, cfg|
      p = cfg[:palette]
      assert_operator lum(p[:motif_rgb]), :<, lum(p[:wall]),
                      "#{z}: motif stays darker than the wall"
    end
  end

  def test_ambient_is_a_tint_never_a_veil
    each_zone do |z, cfg|
      alpha = cfg[:palette][:ambient_rgba][3]
      assert_includes 8..40, alpha, "#{z}: ambient alpha stays a tint"
    end
  end

  def test_every_zone_authors_at_least_one_landmark
    each_zone do |z, cfg|
      map = Core::TileMap.new(cfg) # BadMap would raise on a bad rect
      refute_empty map.decor, "#{z} authors at least one landmark"
    end
  end

  def test_gold_stays_reserved_for_walkable_markers
    gold = [235, 190, 90]
    each_zone do |z, cfg|
      p = cfg[:palette]
      candidates = [p[:wall], p[:motif_rgb]] +
                   Core::TileMap.new(cfg).decor.map { |d| d[:rgb] }
      candidates.each do |rgb|
        dist = rgb.zip(gold).sum { |a, b| (a - b).abs }
        assert_operator dist, :>, 90,
                        "#{z}: #{rgb.inspect} sits too close to gate gold"
      end
    end
  end
end
