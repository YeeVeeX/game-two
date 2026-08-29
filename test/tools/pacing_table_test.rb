require_relative "../test_helper"
require "open3"
require "rbconfig"
require "core/data_store"
require "game/progression"

# v20 T2: tools/pacing_table.rb is a STANDING script (foundation L5 —
# run on every curve/cap touch), so it gets a rot smoke: it must run
# clean against the live data file and its emitted arithmetic must match
# the real Progression formula. Formula-relative throughout — a k/cap
# retune must never break this file (progression_test.rb header law).
class PacingTableToolTest < Minitest::Test
  TOOL = File.expand_path("../../tools/pacing_table.rb", __dir__)
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def run_tool(env = {})
    Open3.capture3(env, RbConfig.ruby, TOOL)
  end

  def test_emits_live_curve_and_pin_from_the_shipped_file
    stdout, stderr, status = run_tool
    assert status.success?, "tool refused: #{stderr}"
    p = Game::Progression.new(config: DATA["balance/progression"])
    cap = p.level_cap
    k = DATA["balance/progression"][:curve][:k]
    assert_includes stdout, "k=#{k} cap=#{cap}"
    assert_includes stdout, "at-cap xp pin: dE(#{cap + 1}) - 1 = #{p.delta_e(cap + 1) - 1}",
                    "pin line must carry the projector-invariant value for the live curve"
    cum = (2..cap).sum { |l| p.delta_e(l) }
    assert_includes stdout, "cum to cap: E(#{cap}) = #{cum}"
  end

  def test_sweep_mode_prices_candidate_ks_with_the_formula
    stdout, _, status = run_tool({ "K_SWEEP" => "40,44" })
    assert status.success?
    cap = DATA["balance/progression"][:curve][:level_cap]
    # Assert INSIDE the sweep section only — live-k values also appear in
    # the main table above it, which would mute the live-k assertion
    # (review advisory, 2026-08-29).
    sweep = stdout.split("candidate-k dwell sweep").fetch(1) do
      flunk "sweep section missing from output"
    end
    [40, 44].each do |k|
      curve = DATA["balance/progression"][:curve].merge(k:)
      p = Game::Progression.new(config: DATA["balance/progression"].merge(curve:))
      assert_includes sweep, p.delta_e(cap).to_s,
                      "sweep must price dE(#{cap}) under candidate k=#{k}"
      assert_includes sweep, (p.delta_e(cap + 1) - 1).to_s,
                      "sweep must carry the pin under candidate k=#{k}"
    end
  end
end
