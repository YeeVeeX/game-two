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

  def test_depth_gradient_steepens
    bands = DATA["zones/district"][:drop_gradient]
    refute_nil bands, "district must have a drop gradient"
    mults = bands.map(&:last)
    assert mults.each_cons(2).all? { |a, b| b > a }, "gradient strictly increasing: #{mults}"
    assert mults.last >= 3.0, "band-2 premium >= 3.0x sustains the Q6 dilemma (v10.1 retune)"
  end
end
