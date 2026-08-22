require_relative "../test_helper"
require "core/data_store"
require "game/progression"

# Lane 1 T1/T2 (spec P1-P5/P14): the Progression plain object — curve,
# kill awards, stat growth, cap behavior, load seams. Pure unit lane:
# boundary cases run on SYNTHETIC configs (sim numbers stay unfrozen —
# a k/cap retune must never break this file); the shipped data file gets
# one wiring smoke against the formula, never a pinned literal.
class ProgressionTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def config(k: 50, level_cap: 4, dmg_growth_pct: 8, hp_growth_pct: 6,
             kill_xp: { rusher: 25 })
    {
      curve: { k:, level_cap: },
      growth: { dmg_growth_pct:, hp_growth_pct: },
      kill_xp:
    }
  end

  def prog(**kwargs) = Game::Progression.new(config: config(**kwargs))

  # --- construction + config law ------------------------------------------

  def test_fresh_progression_is_level_1_xp_0_session_xp_0_counters_0
    p = prog
    assert_equal [1, 0, 0, 0, 0],
                 [p.level, p.xp, p.kills_xp, p.boss_1_defeats, p.sessions]
  end

  def test_non_integer_curve_constants_refuse_named_at_construction
    [{ k: 50.0, level_cap: 4 }, { k: 50, level_cap: "4" },
     { k: 0, level_cap: 4 }, { k: 50, level_cap: 0 }].each do |curve|
      err = assert_raises(ArgumentError, "expected refusal for #{curve.inspect}") do
        Game::Progression.new(config: config.merge(curve:))
      end
      assert_match(/progression curve/, err.message)
    end
  end

  def test_growth_requires_named_non_negative_integers
    [{ dmg_growth_pct: 8.0, hp_growth_pct: 6 },
     { dmg_growth_pct: 8, hp_growth_pct: -1 },
     { dmg_growth_pct: 8 }].each do |growth|
      err = assert_raises(ArgumentError, "expected refusal for #{growth.inspect}") do
        Game::Progression.new(config: config.merge(growth:))
      end
      assert_match(/progression growth/, err.message)
    end
  end

  def test_kill_xp_requires_symbol_keys_and_positive_integer_amounts
    [{ rusher: 0 }, { rusher: 2.5 }, { "rusher" => 25 }].each do |kill_xp|
      err = assert_raises(ArgumentError, "expected refusal for #{kill_xp.inspect}") do
        Game::Progression.new(config: config.merge(kill_xp:))
      end
      assert_match(/progression kill_xp/, err.message)
    end
  end

  def test_shipped_data_file_wires_the_formula
    curve = DATA["balance/progression"][:curve]
    p = Game::Progression.new(config: DATA["balance/progression"])
    assert_equal curve[:level_cap], p.level_cap
    # ΔE(L) = k·(L² − 3L + 4), spot-checked at L=2 and L=cap against the
    # shipped k — transcription of the formula, not a frozen sim number.
    assert_equal curve[:k] * 2, p.delta_e(2)
    cap = curve[:level_cap]
    assert_equal curve[:k] * (cap * cap - 3 * cap + 4), p.delta_e(cap)
    assert_equal %i[dmg_growth_pct hp_growth_pct],
                 DATA["balance/progression"][:growth].keys.sort
    assert DATA["balance/progression"][:kill_xp].all? { |kit, amount|
      kit.is_a?(Symbol) && amount.is_a?(Integer) && amount.positive?
    }
  end

  # --- P1 curve values (synthetic k=50: the shelf note's Tibia row) --------

  def test_delta_e_quadratic_values
    p = prog(k: 50)
    assert_equal 100, p.delta_e(2)  # 50·(4−6+4)
    assert_equal 200, p.delta_e(3)  # 50·(9−9+4)
    assert_equal 400, p.delta_e(4)  # 50·(16−12+4)
    assert_equal 700, p.delta_e(5)  # 50·(25−15+4)
  end

  # --- award boundaries (P3: xp is progress INTO the current level) --------

  def test_award_below_the_boundary_accrues_no_level
    p = prog
    assert_nil p.award(99)
    assert_equal [1, 99], [p.level, p.xp]
  end

  def test_award_at_the_exact_boundary_levels_with_zero_leftover
    p = prog
    p.award(99)
    assert_equal :level_up, p.award(1)
    assert_equal [2, 0], [p.level, p.xp]
  end

  def test_award_carries_the_remainder_into_the_new_level
    p = prog
    assert_equal :level_up, p.award(130)
    assert_equal [2, 30], [p.level, p.xp]
  end

  def test_one_award_can_land_multiple_levels
    p = prog
    assert_equal :level_up, p.award(100 + 200 + 5) # ΔE(2)+ΔE(3)+5
    assert_equal [3, 5], [p.level, p.xp]
  end

  def test_award_stops_one_short_of_the_next_boundary
    p = prog
    assert_equal :level_up, p.award(100 + 199)
    assert_equal [2, 199], [p.level, p.xp], "199 < ΔE(3)=200 must not level"
  end

  # --- kill table + stat growth (P2/P5) ------------------------------------

  def test_award_kill_reads_the_table_and_tracks_session_earned_xp
    p = prog(kill_xp: { rusher: 100 })
    assert_equal :level_up, p.award_kill(:rusher)
    assert_equal [2, 0, 100], [p.level, p.xp, p.kills_xp]
  end

  def test_award_kill_refuses_an_unpriced_kit_named
    err = assert_raises(ArgumentError) { prog.award_kill(:future_kit) }
    assert_match(/no kill_xp for kit :future_kit/, err.message)
    assert_match(/progression\.json/, err.message)
  end

  def test_kills_xp_counts_earned_amount_even_when_cap_pins_the_bar
    p = prog(level_cap: 2, kill_xp: { rusher: 25 })
    p.load_progress!(level: 2, xp: 0)
    assert_nil p.award_kill(:rusher)
    assert_equal [2, 25], [p.level, p.kills_xp]
  end

  def test_damage_and_max_hp_are_level_1_identity_then_integer_truncation
    p = prog(dmg_growth_pct: 8, hp_growth_pct: 6)
    assert_equal 25, p.damage_for(25)
    assert_equal 33, p.max_hp_for(33)
    p.load_progress!(level: 2, xp: 0)
    assert_equal 27, p.damage_for(25), "25 * 8% truncates to +2"
    assert_equal 34, p.max_hp_for(33), "33 * 6% truncates to +1"
  end

  # --- cap behavior + the projector-invariant law ---------------------------

  def total_to_cap(p, cap) = (2..cap).sum { |l| p.delta_e(l) }

  def test_award_never_levels_past_the_cap
    p = prog(level_cap: 4)
    assert_equal :level_up, p.award(total_to_cap(p, 4))
    assert_equal [4, 0], [p.level, p.xp]
    assert_nil p.award(10_000), "a capped award must not report :level_up"
    assert_equal 4, p.level
  end

  def test_xp_always_ends_below_the_next_level_ceiling
    p = prog(level_cap: 4)
    p.award(total_to_cap(p, 4) + 10_000)
    assert_equal 4, p.level
    assert_operator p.xp, :<, p.delta_e(5),
                    "projector invariant: a mid-session save must reload " \
                    "without clamp warnings (xp < ΔE(level+1) always)"
  end

  # --- counters + load seams -------------------------------------------------

  def test_record_boss_1_defeat_increments
    p = prog
    p.record_boss_1_defeat!
    p.record_boss_1_defeat!
    assert_equal 2, p.boss_1_defeats
  end

  def test_load_seams_restore_persisted_facts
    p = prog
    p.load_counters!(boss_1_defeats: 3, sessions: 7)
    p.load_progress!(level: 2, xp: 55)
    assert_equal [3, 7, 2, 55], [p.boss_1_defeats, p.sessions, p.level, p.xp]
  end
end
