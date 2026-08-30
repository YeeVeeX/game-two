require_relative "../test_helper"
require "core/data_store"

class ProgressionDataTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def test_every_zone_spawned_enemy_kit_has_kill_xp
    spawned_kits = DATA.keys.grep(/\Azones\//).flat_map do |key|
      DATA[key].fetch(:enemy_spawns, {}).keys
    end.uniq.sort
    priced_kits = DATA["balance/progression"][:kill_xp].keys

    missing = spawned_kits - priced_kits
    assert_empty missing,
                 "zone enemy_spawns missing kill_xp rows in progression.json: #{missing.inspect}"
  end

  # v20 T6b (L6): the deep-pays-more gradient is a data LAW, not a hope —
  # floor -2's kinds out-pay the surface minion ceiling (rusher_hater 25)
  # while the challenger stays the elite; both kinds are complete hostile
  # kits (the pure-data spawn path: World#add_human fetches by name, and
  # Progression#award_kill refuses any kind missing its row).
  def test_floor2_kinds_pay_deep_and_ship_complete_kits
    xp = DATA["balance/progression"][:kill_xp]
    assert_operator xp[:lurker], :>, xp[:rusher_hater], "deep minion must out-pay the surface ceiling"
    assert_operator xp[:warden], :>, xp[:lurker], "guardian pays a premium over the deep minion"
    assert_operator xp[:challenger], :>, xp[:warden], "the challenger stays the elite bounty"
    %i[lurker warden].each do |kind|
      kit = DATA["balance/combat"][:kits][kind]
      refute_nil kit, "combat.json ships no #{kind} kit"
      %i[max_hp step_frames aggro_tiles respawn_frames drop_table attack].each do |key|
        refute_nil kit[key], "#{kind} kit missing #{key}"
      end
      assert_equal "ring", kit.dig(:attack, :arc)
    end
    # the ambush/guardian behavior split lives in the numbers: short-aggro
    # fast-punish minion vs slow long-windup heavy — not a stat reskin.
    lurker = DATA["balance/combat"][:kits][:lurker]
    warden = DATA["balance/combat"][:kits][:warden]
    assert_operator lurker[:aggro_tiles], :<, 10, "lurker is an ambusher: sub-rusher aggro"
    assert_operator lurker.dig(:attack, :windup_frames), :<, 20, "lurker punishes faster than a rusher"
    assert_operator warden[:step_frames], :>, 16, "warden is the slow zoner"
    assert_operator warden.dig(:attack, :windup_frames), :>, 20, "warden telegraphs long"
  end

  # T4 (P10, lane 5): the ctor cannot see combat.json, so data coherence
  # lives here — every spell_growth kit must exist in combat.json and
  # carry the spell the table grows; every threshold must be reachable
  # (belt for the ctor's dead-row refusal).
  def test_spell_growth_rows_are_wired_to_real_kits_and_reachable_levels
    combat_kits = DATA["balance/combat"][:kits]
    cap = DATA["balance/progression"][:curve][:level_cap]
    table = DATA["balance/progression"][:spell_growth]
    refute_empty table, "P10 ships at least the lobber row"
    table.each do |kit_name, spells|
      kit = combat_kits[kit_name]
      refute_nil kit, "spell_growth names #{kit_name} but combat.json ships no such kit"
      refute_nil kit.dig(:special, :impact_distances),
                 "spell_growth grows #{kit_name}'s special impact_distances but the " \
                 "kit's special carries none (typo'd kit or wrong spell family)"
      spells.fetch(:special_impact_distances).each_key do |key|
        assert_operator Integer(key.to_s, 10), :<=, cap,
                        "#{kit_name} threshold #{key} exceeds level_cap #{cap}"
      end
    end
  end
end
