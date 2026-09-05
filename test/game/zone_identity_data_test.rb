require_relative "../test_helper"
require "core/data_store"
require "core/tile_map"

# v16 (b): every REACHABLE real zone carries an identity block, and every
# block honors the legibility contracts the spec pins: value structure
# constant (wall reads LIGHTER than floor, wide spread), motif subtle
# (between floor and wall, closer to floor), ambient faint, no gold hues
# off the transition channel (gold = walkable, reserved — W5).
# T5 (2026-08-21): the four pilot zones joined the live graph through the
# ratified low_quay<->zone_7 edge — real zones now, same contracts (T4
# authored them to these laws; a palette failure here is an AUTHORING
# finding — fix in the sidecar + re-import, never relax the check).
# grass_fixture stays out: unreachable dev fixture.
# zone_8 joined at the s70 wire-in (2026-08-24, the worldsmith-intake debt
# executed): its identity dose landed WITH the dungeon_1 way, same commit —
# the forest reads dark ground / pale treeline under the same laws.
class ZoneIdentityDataTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  AMBIENCE_PRESETS = DATA["ambience"][:presets].keys.map(&:to_s).freeze
  ZONES = %w[nest district district_two camp slow_door low_quay
             zone_7 basement_1 basement_2 dungeon_1 zone_8].freeze

  def luma((r, g, b)) = 0.299 * r + 0.587 * g + 0.114 * b

  def each_zone
    ZONES.each { |z| yield z, DATA["zones/#{z}"] }
  end

  def test_every_zone_carries_the_identity_dose
    each_zone do |name, cfg|
      pal = cfg[:palette]
      refute_nil pal[:motif], "#{name}: motif glyph missing"
      refute_nil pal[:motif_rgb], "#{name}: motif_rgb missing"
      refute_nil pal[:ambient_rgba], "#{name}: ambient_rgba missing"
    end
  end

  def test_value_structure_holds_wall_light_floor_dark_wide_spread
    each_zone do |name, cfg|
      pal = cfg[:palette]
      spread = luma(pal[:wall]) - luma(pal[:floor])
      assert_operator spread, :>=, 40,
                      "#{name}: wall/floor luma spread #{spread.round(1)} too narrow"
    end
  end

  def test_motif_sits_between_floor_and_wall_nearer_the_floor
    each_zone do |name, cfg|
      pal = cfg[:palette]
      m = luma(pal[:motif_rgb])
      f = luma(pal[:floor])
      w = luma(pal[:wall])
      assert_operator m, :>, f, "#{name}: motif darker than floor (invisible)"
      assert_operator m, :<, (f + w) / 2.0,
                      "#{name}: motif louder than texture — it must read as floor, not items"
    end
  end

  def test_ambient_is_a_faint_tint
    each_zone do |name, cfg|
      alpha = cfg[:palette][:ambient_rgba][3]
      assert_operator alpha, :<=, 24, "#{name}: ambient alpha #{alpha} washes the scene"
      assert_operator alpha, :>, 0, "#{name}: dead ambient key"
    end
  end

  def test_decor_entries_are_wellformed_and_on_map
    each_zone do |name, cfg|
      map = Core::TileMap.new(cfg)
      map.decor.each do |d|
        tx, ty = d[:at]
        w = d.fetch(:w, 1)
        h = d.fetch(:h, 1)
        assert tx >= 0 && ty >= 0 && tx + w <= map.cols && ty + h <= map.rows,
               "#{name}: decor #{d[:kind]} at #{d[:at]} spans off-map"
        if d[:kind] == "ambience"
          # FASE 2 point source: carries a preset, not a color (App::Ambience
          # animates it; the preset must exist or the point is dead data).
          assert AMBIENCE_PRESETS.include?(d[:preset].to_s),
                 "#{name}: decor ambience at #{d[:at]} names unknown preset #{d[:preset].inspect}"
        else
          assert_equal 3, d[:rgb].length, "#{name}: decor rgb malformed"
          assert d[:alpha].is_a?(Integer), "#{name}: decor alpha malformed"
        end
      end
    end
  end

  # The quay is the oracle's focus ("does the Quay look like a place") —
  # it must carry authored landmarks, not just palette.
  def test_the_low_quay_carries_landmarks
    map = Core::TileMap.new(DATA["zones/low_quay"])
    kinds = map.decor.map { |d| d[:kind] }
    assert_includes kinds, "edge", "the quay's channel lips are its silhouette"
    assert_includes kinds, "stain", "drowned floor patches ground the read"
  end

  def test_ember_accents_stay_off_gold
    # Gold [235,190,90] has green/red ~0.81; embers must burn RED-dominant
    # (green/red < 0.65) so nothing warm competes with the walkable channel.
    each_zone do |name, cfg|
      map = Core::TileMap.new(cfg)
      map.decor.select { |d| d[:kind] == "brazier" }.each do |d|
        r, g, = d[:rgb]
        assert_operator g.fdiv(r), :<, 0.65,
                        "#{name}: brazier at #{d[:at]} reads gold, not ember"
      end
    end
  end
end
