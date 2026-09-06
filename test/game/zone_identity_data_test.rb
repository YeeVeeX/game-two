require_relative "../test_helper"
require "core/data_store"
require "core/tile_map"

# v16 (b): every REACHABLE real zone carries an identity block, and every
# block honors the legibility contracts the spec pins: value structure
# legible (v20: wall LIGHTER than floor, wide spread; E4 2026-09-06: by value
# OR by chroma, orientation named per zone - see the amendment note below), motif subtle
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
             zone_7 basement_1 basement_2 dungeon_1 zone_8
             dungeon_2 dungeon_3 dungeon_4 ember_1 ember_2 ember_3].freeze

  def luma((r, g, b)) = 0.299 * r + 0.587 * g + 0.114 * b
  # Chroma channel of the legibility contract (E4 amendment, 2026-09-06; the landing
  # review's MAJOR 1 corrected the MEASURE): the component of (wall - floor)
  # ORTHOGONAL to the grey axis. Plain RGB distance was wrong here - it carries the
  # grey (value) axis too, so an achromatic pair with |spread| 24 read as "legible
  # by chroma" (reviewer's counterexample [124,124,124] / [100,100,100], tested below).
  def chroma_dist(a, b)
    d = a.zip(b).map { |x, y| x - y }
    Math.sqrt([d.sum { |v| v * v } - (d.sum**2) / 3.0, 0.0].max)
  end

  # E4 LAW AMENDMENT (v22 ticket E4, drafts/_v22-e4-record-20260906.md + its
  # CORRECTION section). The v20 contract said "wall LIGHTER than floor, luma
  # spread >= 40" - true for the pilot's dark-floor zones and for the ratified
  # low_quay<->zone_7 edge, but a VALUE-ONLY, ONE-ORIENTATION law. The MUNDO VIVO
  # package (played and ratified, sealed visual bible = law) added two families:
  #   TOWER (dungeon_2/3/4): LIGHT stone floor, DARK buried-rock red wall - the
  #     value structure is INVERTED on purpose (spread -25..-31) and the read is
  #     carried by HUE (grey vs red: orthogonal chroma 83..100).
  #   BRASA (ember_1/2/3): a LOW-KEY fire-lit cave, both surfaces dark (spread
  #     +23..+29 the right way round, orthogonal chroma only 15..18): the flat
  #     palette alone is a WEAK read; in play the lava tiles (`lava_deco`) and
  #     the fire glow pools (src/app/light.rb) carry it. Named, not hidden.
  # What the contract protects is LEGIBILITY of wall vs floor in the flat
  # (no-texture) fallback. A zone passes by ONE of three NAMED clauses (each
  # prints its numbers on failure):
  #   (value)   |luma spread| >= 40                              - the v20 law, orientation-free
  #   (chroma)  orthogonal chroma >= 40 AND |luma spread| >= 20  - hue carries it (TOWER)
  #   (low-key) 20 <= |luma spread| < 40 AND floor luma <= 30 AND the palette
  #             carries a light source (`lava_deco`)             - BRASA: a recorded
  #             exception with its CARRIER named; the owner's numbers may retune it
  # and the motif reads as FLOOR TEXTURE when its luma sits between floor and
  # wall, nearer the floor - in either orientation.
  VALUE_SPREAD_MIN = 40
  CHROMA_DIST_MIN = 40
  CHROMA_VALUE_MIN = 20
  LOW_KEY_SPREAD_MIN = 20
  LOW_KEY_FLOOR_LUMA_MAX = 30
  LOW_KEY_CARRIERS = %i[lava_deco].freeze

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

  # -> [legible?, why]. Pure; the counterexample test below feeds it hand pairs.
  def legible?(pal)
    spread = (luma(pal[:wall]) - luma(pal[:floor])).abs
    chroma = chroma_dist(pal[:wall], pal[:floor])
    by_value = spread >= VALUE_SPREAD_MIN
    by_chroma = chroma >= CHROMA_DIST_MIN && spread >= CHROMA_VALUE_MIN
    low_key = spread >= LOW_KEY_SPREAD_MIN && spread < VALUE_SPREAD_MIN &&
              luma(pal[:floor]) <= LOW_KEY_FLOOR_LUMA_MAX && LOW_KEY_CARRIERS.any? { |k| pal.key?(k) }
    why = "|luma spread| #{spread.round(1)} (value needs >= #{VALUE_SPREAD_MIN}); orthogonal chroma " \
          "#{chroma.round(1)} (chroma needs >= #{CHROMA_DIST_MIN} with |spread| >= #{CHROMA_VALUE_MIN}); " \
          "low-key needs #{LOW_KEY_SPREAD_MIN} <= |spread| < #{VALUE_SPREAD_MIN}, floor luma <= " \
          "#{LOW_KEY_FLOOR_LUMA_MAX} (is #{luma(pal[:floor]).round(1)}) and a carrier key #{LOW_KEY_CARRIERS.inspect}"
    [by_value || by_chroma || low_key, why]
  end

  def test_value_structure_wall_and_floor_are_legible_by_value_chroma_or_named_low_key
    each_zone do |name, cfg|
      ok, why = legible?(cfg[:palette])
      assert ok, "#{name}: wall/floor not legible in the flat fallback - #{why}"
    end
  end

  def test_the_landing_reviews_achromatic_counterexample_is_refused
    # 2026-09-06 landing review MAJOR 1: this pair passed the OLD "chroma" clause
    # (RGB distance 41.6) with ZERO hue. Spread 24, floor luma 100, no carrier.
    ok, why = legible?({ wall: [124, 124, 124], floor: [100, 100, 100] })
    refute ok, "an achromatic near-grey pair must never read as legible: #{why}"
    ok, = legible?({ wall: [124, 124, 124], floor: [100, 100, 100], lava_deco: [255, 90, 20] })
    refute ok, "a carrier does not rescue a LIGHT floor - low-key is a dark-cave clause"
    assert legible?({ wall: [148, 49, 30], floor: [104, 104, 108] })[0], "TOWER passes by chroma (dungeon_3 numbers)"
    assert legible?({ wall: [70, 46, 40], floor: [28, 22, 22], lava_deco: [255, 90, 20] })[0],
           "BRASA passes by the NAMED low-key clause (ember_1 numbers)"
    refute legible?({ wall: [70, 46, 40], floor: [28, 22, 22] })[0],
           "without its carrier BRASA's flat palette is refused - the exception is named, not silent"
  end

  # The identity rows read a HAND list (ZONES): a new data/zones/*.json would be
  # judged by nobody (landing review, answer 1). Every zone file is either under
  # the contract or NAMED here as not-yet-contracted; moving one across is a decision.
  UNCONTRACTED_ZONES = %w[gate_fixture grass_fixture wall_fixture].freeze

  def test_every_zone_file_is_under_contract_or_named_uncontracted
    files = Dir[File.expand_path("../../data/zones/*.json", __dir__)].map { |f| File.basename(f, ".json") }.sort
    assert_equal files, (ZONES + UNCONTRACTED_ZONES).sort,
                 "unlisted: #{(files - ZONES - UNCONTRACTED_ZONES).inspect} / listed but missing: #{(ZONES + UNCONTRACTED_ZONES - files).inspect}"
  end

  # The v20 pilot zones and the ratified edge keep the ORIGINAL orientation:
  # amending the law for the tower must not silently let a dark-floor zone
  # flip. Pinned by name so a re-author of one of these is a decision, not a drift.
  DARK_FLOOR_ZONES = %w[nest district district_two camp slow_door low_quay
                        zone_7 basement_1 basement_2 dungeon_1 zone_8 ember_1 ember_2 ember_3].freeze
  LIGHT_FLOOR_ZONES = %w[dungeon_2 dungeon_3 dungeon_4].freeze

  def test_value_orientation_is_a_named_choice_per_zone
    assert_equal ZONES.sort, (DARK_FLOOR_ZONES + LIGHT_FLOOR_ZONES).sort, "every zone names its orientation"
    each_zone do |name, cfg|
      pal = cfg[:palette]
      spread = luma(pal[:wall]) - luma(pal[:floor])
      if LIGHT_FLOOR_ZONES.include?(name)
        assert_operator spread, :<, 0, "#{name}: TOWER law - light stone floor, dark buried-rock wall"
      else
        assert_operator spread, :>, 0, "#{name}: pilot law - dark floor, lighter wall"
      end
    end
  end

  def test_motif_sits_between_floor_and_wall_nearer_the_floor
    each_zone do |name, cfg|
      pal = cfg[:palette]
      m = luma(pal[:motif_rgb])
      f = luma(pal[:floor])
      w = luma(pal[:wall])
      lo, hi = [f, w].minmax
      # orientation-free (E4): on a dark floor the motif is a lighter speckle,
      # on the tower's light stone it is a darker one - both read as texture.
      assert_operator m, :>, lo, "#{name}: motif outside the floor..wall band (below)"
      assert_operator m, :<, hi, "#{name}: motif outside the floor..wall band (above)"
      assert_operator (m - f).abs, :<, (w - m).abs,
                      "#{name}: motif louder than texture — nearer the wall than the floor; it must read as floor, not items"
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
