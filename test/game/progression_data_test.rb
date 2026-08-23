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
