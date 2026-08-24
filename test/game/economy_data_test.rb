require_relative "../test_helper"
require "core/data_store"

# Economy data laws (spec §Data): prices positive, devotion cheaper than
# desperation. Values are hypotheses; these assertions pin the LAWS only.
class EconomyDataTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]

  def test_all_costs_positive
    assert ECO[:inscribe_cost].positive?
    assert ECO[:regrow_cost].positive?
    assert ECO[:heal_cost_per_body].positive?
    assert ECO[:retarget_cue_frames].positive?
  end

  def test_devotion_cheaper_than_desperation
    assert ECO[:inscribe_cost] < ECO[:regrow_cost],
           "inscribe_cost must be < regrow_cost (fiction law, spec §3)"
  end

  # B4 (foundation row 9): the mercy knob is an integer share of banked.
  # 100 = the guarantee takes everything they have; 0 = a free first
  # regrow (a valid owner retune); anything outside 0..100 would charge
  # money the pack doesn't have, breaking the guarantee itself.
  def test_mercy_floor_spend_pct_is_a_whole_share
    pct = ECO[:mercy_floor_spend_pct]
    assert pct.is_a?(Integer) && pct.between?(0, 100),
           "mercy_floor_spend_pct must be an integer 0..100 share of banked: #{pct.inspect}"
  end

  # The >= 3.0 floor was the v10.1 hypothesis — REFUTED at the eighth verify
  # (premium earned but not attributed; Q1 inflation fired) and reverted by
  # owner fork. The strictly-increasing SHAPE law survives it.
  def test_depth_gradient_steepens
    bands = DATA["zones/district"][:drop_gradient]
    refute_nil bands, "district must have a drop gradient"
    mults = bands.map(&:last)
    assert mults.each_cons(2).all? { |a, b| b > a }, "gradient strictly increasing: #{mults}"
  end
end
