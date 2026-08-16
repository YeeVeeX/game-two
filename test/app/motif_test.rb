require_relative "../test_helper"
require "app/motif"

# v16 (b): floor motif placement is PURE integer math from (tx, ty) —
# deterministic by construction (no RNG stream, no floats — the spec's
# own (tx*7 + ty*13) % 9 arithmetic law). Sparse ~1/9 so texture never
# reads as items (watched risk W5).
class MotifTest < Minitest::Test
  def rects(glyph: "ember", tx: 0, ty: 0)
    App::Motif.rects(glyph:, tx:, ty:, ts: 32)
  end

  def test_deterministic_same_tile_same_rects
    assert_equal rects(tx: 9, ty: 3), rects(tx: 9, ty: 3)
  end

  def test_density_is_about_one_in_nine
    placed = 0
    30.times { |ty| 30.times { |tx| placed += 1 unless rects(tx:, ty:).empty? } }
    assert_includes 90..110, placed, "~1/9 of 900 tiles carry the motif"
  end

  def test_off_pattern_tiles_are_empty
    refute_empty rects(tx: 0, ty: 0), "(0*7 + 0*13) % 9 == 0 places"
    assert_empty rects(tx: 1, ty: 0), "(1*7) % 9 != 0 stays bare floor"
  end

  def test_rects_are_integers_inside_the_tile
    30.times do |ty|
      30.times do |tx|
        rects(tx:, ty:).each do |x, y, w, h|
          [x, y, w, h].each { |v| assert_kind_of Integer, v }
          assert_operator x, :>=, tx * 32
          assert_operator y, :>=, ty * 32
          assert_operator x + w, :<=, tx * 32 + 32, "glyph bleeds right of its tile"
          assert_operator y + h, :<=, ty * 32 + 32, "glyph bleeds below its tile"
        end
      end
    end
  end

  def test_in_tile_offset_drifts_between_placed_tiles
    placed = []
    30.times do |ty|
      30.times do |tx|
        r = rects(tx:, ty:)
        placed << r.map { |x, y, w, h| [x - tx * 32, y - ty * 32, w, h] } unless r.empty?
      end
    end
    assert_operator placed.uniq.length, :>, 1,
                    "the phase drift keeps the pattern from reading as a printed grid"
  end

  def test_every_declared_glyph_draws_on_a_placed_tile
    App::Motif::GLYPHS.each_key do |g|
      refute_empty rects(glyph: g, tx: 0, ty: 0), "glyph #{g} renders"
    end
  end

  def test_unknown_glyph_fails_loud_with_the_valid_list
    err = assert_raises(ArgumentError) { rects(glyph: "swirl") }
    App::Motif::GLYPHS.each_key { |g| assert_includes err.message, g }
  end
end
