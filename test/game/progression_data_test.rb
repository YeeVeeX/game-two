require_relative "../test_helper"
require "core/data_store"
require "game/progression"

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

  # v20 T7 (L6): floor -3's minion continues the gradient - stinger 65
  # sits above the -2 minion (lurker 40) and below the carried guardian
  # (warden 90); the challenger's elite air stays clean (no re-price, the
  # compress default). The kit is the game's first RANGED hostile: shape
  # asserts pin the projectile contract, and the hit-and-run split lives
  # in the numbers (fragile, interrupt-on-hit, zero knockback, sub-lobber
  # range so the player's own projectile kit out-reaches it).
  def test_floor3_kind_pays_deeper_and_ships_the_ranged_contract
    xp = DATA["balance/progression"][:kill_xp]
    assert_operator xp[:stinger], :>, xp[:lurker], "floor -3 minion out-pays floor -2's"
    assert_operator xp[:warden], :>, xp[:stinger], "the carried guardian keeps its premium"
    assert_operator xp[:challenger], :>, xp[:warden], "elite bounty untouched (no silent re-price)"
    kit = DATA["balance/combat"][:kits][:stinger]
    refute_nil kit, "combat.json ships no stinger kit"
    %i[max_hp step_frames aggro_tiles respawn_frames drop_table attack].each do |key|
      refute_nil kit[key], "stinger kit missing #{key}"
    end
    atk = kit[:attack]
    assert_equal "projectile", atk[:arc], "the abyss minion is the first ranged hostile"
    refute_nil atk[:range_tiles], "projectile kits declare range_tiles"
    refute_nil atk[:projectile_frames_per_tile], "projectile kits declare shot speed"
    lobber = DATA["balance/combat"][:kits][:lobber][:attack]
    assert_operator atk[:range_tiles], :<, lobber[:range_tiles],
                    "the player's lobber out-ranges the stinger (counter-snipe exists)"
    assert_operator atk[:projectile_frames_per_tile], :>, lobber[:projectile_frames_per_tile],
                    "stinger shots fly slower than the player's (dodgeable)"
    assert_equal 0, atk[:knockback_tiles], "ranged knockback is stunlock misery - forbidden"
    assert kit[:interrupt_on_hit], "melee cancels the sting (weak up close - the hit-and-run contract)"
    assert_operator kit[:max_hp], :<, DATA["balance/combat"][:kits][:lurker][:max_hp],
                    "reaching the stinger is decisive: fragile below the ambusher"
  end

  # v20 T7: shipped numbers through the real award path (T6b pattern).
  def test_floor3_kill_award_pays_through_the_shipped_file
    p = Game::Progression.new(config: DATA["balance/progression"])
    p.award_kill(:stinger)
    assert_equal 65, p.kills_xp, "stinger pays 65"
  end

  # v20 T6b: the shipped file pays the shipped numbers through the real
  # award path (award_kill refuses unknown kinds — the engine's own law).
  def test_floor2_kill_awards_pay_through_the_shipped_file
    p = Game::Progression.new(config: DATA["balance/progression"])
    p.award_kill(:lurker)
    assert_equal 40, p.kills_xp, "lurker pays 40"
    assert_equal 40, p.xp, "below dE(2)=80: no level yet"
    p.award_kill(:warden)
    assert_equal 130, p.kills_xp, "warden adds 90 on top"
    assert_equal 2, p.level, "130 XP crosses dE(2)=80"
    assert_equal 50, p.xp
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
