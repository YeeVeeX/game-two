require_relative "../test_helper"
require "core/data_store"
require "game/tier_sheet"

# s68 difficulty tier — TierSheet unit laws + the live data/balance/
# tiers.json law (economy_data_test pattern: shipped numbers are pinned
# so a retune is a conscious act, never a drive-by).
class TierSheetTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  ZONES = %w[alpha beta].freeze

  def sheet(rows)
    Game::TierSheet.new(config: { zones: rows }, zones: ZONES)
  end

  # --- identity law (the coop seats=1 precedent) -----------------------

  def test_a_zone_without_a_row_is_identity
    s = sheet({ alpha: { enemy_hp_pct: 100, enemy_dmg_pct: 75 } })
    assert_equal 50, s.hp_for("beta", 50)
    assert_equal 0, s.dmg_pct("beta")
  end

  def test_apply_never_touches_a_creature_outside_tiered_zones
    s = sheet({})
    creature = Object.new # would raise on ANY call — identity is structural
    s.apply!(creature, "alpha")
  end

  # --- Integer math (dmg_growth_pct grammar) ---------------------------

  def test_hp_for_adds_the_integer_pct_share
    s = sheet({ alpha: { enemy_hp_pct: 100, enemy_dmg_pct: 0 },
                beta: { enemy_hp_pct: 50, enemy_dmg_pct: 25 } })
    assert_equal 100, s.hp_for("alpha", 50)
    assert_equal 75, s.hp_for("beta", 50)
    assert_equal 90, s.hp_for("beta", 60)
  end

  def test_hp_for_floors_via_integer_division
    s = sheet({ alpha: { enemy_hp_pct: 25, enemy_dmg_pct: 0 } })
    # 50 + 50*25/100 = 50 + 12 (12.5 floors — no Float ever enters)
    assert_equal 62, s.hp_for("alpha", 50)
  end

  def test_zero_pct_row_is_numeric_identity
    s = sheet({ alpha: { enemy_hp_pct: 0, enemy_dmg_pct: 0 } })
    assert_equal 50, s.hp_for("alpha", 50)
    assert_equal 0, s.dmg_pct("alpha")
  end

  # --- refusals (NAMED, progression parser style) ----------------------

  def test_unknown_zone_refuses_named
    e = assert_raises(ArgumentError) do
      sheet({ ghost: { enemy_hp_pct: 10, enemy_dmg_pct: 10 } })
    end
    assert_match(/tiers zone "ghost": no such zone loaded/, e.message)
  end

  def test_missing_or_extra_row_keys_refuse
    e = assert_raises(ArgumentError) { sheet({ alpha: { enemy_hp_pct: 10 } }) }
    assert_match(/exactly enemy_hp_pct \+ enemy_dmg_pct/, e.message)
    e = assert_raises(ArgumentError) do
      sheet({ alpha: { enemy_hp_pct: 10, enemy_dmg_pct: 10, kill_xp_pct: 10 } })
    end
    assert_match(/exactly enemy_hp_pct \+ enemy_dmg_pct/, e.message)
  end

  def test_non_integer_or_negative_pcts_refuse
    [{ enemy_hp_pct: 1.5, enemy_dmg_pct: 0 },
     { enemy_hp_pct: -1, enemy_dmg_pct: 0 },
     { enemy_hp_pct: "50", enemy_dmg_pct: 0 }].each do |row|
      e = assert_raises(ArgumentError) { sheet({ alpha: row }) }
      assert_match(/must be a non-negative Integer/, e.message)
    end
  end

  def test_zones_table_must_be_a_hash
    e = assert_raises(ArgumentError) do
      Game::TierSheet.new(config: { zones: [] }, zones: ZONES)
    end
    assert_match(/must be a Hash of zone rows/, e.message)
  end

  # --- the live file (shipped s68 numbers — retunes are conscious) -----

  def test_live_tiers_data_law
    zones = DATA.keys.grep(%r{\Azones/}).map { |k| k.sub("zones/", "") }
    s = Game::TierSheet.new(config: DATA["balance/tiers"], zones: zones)
    { "basement_1" => [50, 25], "basement_2" => [50, 25],
      "dungeon_1" => [100, 75], "zone_8" => [150, 100] }.each do |zone, (hp, dmg)|
      assert_equal 100 + hp, s.hp_for(zone, 100), "#{zone} enemy_hp_pct"
      assert_equal dmg, s.dmg_pct(zone), "#{zone} enemy_dmg_pct"
    end
    # The ZONE-1 family stays trivial-at-8 BY DESIGN (zone-identity law):
    %w[district district_two low_quay nest].each do |zone|
      assert_equal 0, s.dmg_pct(zone), "#{zone} must carry no tier row"
    end
  end
end
