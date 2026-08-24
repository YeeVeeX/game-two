require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# s68 difficulty tier through a REAL World on the LIVE data (owner datum
# s67: "a partir de nivel 8 ... muy fácil"). Laws pinned: the tier lands
# at the ONE spawn seam (seed + respawn + coop composition, boss
# excluded by data); enemy damage reads the stamped pct at the
# leveled_damage seam; the pack NEVER tiers; the zone_7 deep gates
# (4/5/6) refuse below level and cross at level on live zone data.
class ZoneTierTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def world(seats: 1)
    Game::World.new(DATA, seats: seats)
  end

  def drive(w, n = 2)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(w.frame)
      w.tick(input)
    end
  end

  def humans_in(w, zone) = w.instance_variable_get(:@humans)[zone]

  # --- seed-time stats (live data: dungeon_1 100/75, district identity) --

  def test_dungeon_1_seeds_tiered_enemies
    w = world
    humans_in(w, "dungeon_1").each do |h|
      assert_equal 100, h.max_hp, "#{h.name}: rusher-family base 50 + 100%"
      assert_equal 75, h.tier_dmg_pct
    end
  end

  def test_district_and_the_boss_zone_stay_identity
    w = world
    humans_in(w, "district").each do |h|
      assert_equal 50, h.max_hp
      assert_equal 0, h.tier_dmg_pct
    end
    boss = humans_in(w, "low_quay").find { |h| h.kit_name == :challenger }
    assert_equal 140, boss.max_hp, "varekka difficulty is the re-cut's business"
    assert_equal 0, boss.tier_dmg_pct
  end

  # --- the damage seam ---------------------------------------------------

  def test_tiered_enemy_damage_reads_the_stamped_pct
    w = world
    tiered = humans_in(w, "dungeon_1").first
    plain = humans_in(w, "district").first
    assert_equal 21, w.send(:leveled_damage, tiered, tiered.kit[:attack]),
                 "12 + 12*75/100 = 21 (Integer division)"
    assert_equal 12, w.send(:leveled_damage, plain, plain.kit[:attack])
  end

  def test_the_pack_never_tiers
    w = world
    w.start_in("dungeon_1")
    striker = w.pack.members.find { |m| m.kit_name == :striker }
    assert_equal 80, striker.max_hp, "tiers are enemy-only; pack growth is P5"
    assert_equal 0, striker.tier_dmg_pct
  end

  # --- respawn re-stamps (respawn IS add_human) ----------------------------

  def test_the_respawn_seam_stamps_the_tier
    # respawn_due_humans releases EVERY body through add_human (the same
    # call this drives) — release choreography itself is
    # density_respawn_test's business; the tier law is the seam's.
    w = world
    reborn = w.send(:add_human, "dungeon_1", :rusher, [5, 5])
    assert_equal 100, reborn.max_hp
    assert_equal 75, reborn.tier_dmg_pct
    plain = w.send(:add_human, "district", :rusher, [5, 5])
    assert_equal 50, plain.max_hp
    assert_equal 0, plain.tier_dmg_pct
  end

  # --- coop composition (kit base -> tier Integer -> coop Float .round) ---

  def test_coop_scalar_composes_after_the_tier
    w = world(seats: 2)
    scale = DATA["balance/coop"][:seats][:"2"][:human_hp_scale]
    tiered = humans_in(w, "dungeon_1").first
    plain = humans_in(w, "district").first
    assert_equal (100 * scale).round, tiered.max_hp, "tier THEN coop"
    assert_equal (50 * scale).round, plain.max_hp
  end

  # --- the zone_7 deep gates on live data (4 / 5 / 6) ----------------------

  def test_the_town_gate_ladder_is_the_shipped_data
    gates = DATA["zones/zone_7"][:transitions].to_h do |t|
      [t[:to], t[:requires_level]]
    end
    assert_equal 4, gates["basement_1"]
    assert_equal 5, gates["basement_2"]
    assert_equal 6, gates["dungeon_1"]
    assert_nil gates["low_quay"], "the return stays free"
  end

  def test_below_level_the_basement_way_refuses_and_speaks
    w = world
    w.start_in("zone_7")
    w.possessed.walker.teleport(26, 3)
    drive(w)
    assert_equal "zone_7", w.zone_name, "level 1 pack stays out"
    cue = w.station_cue
    assert_equal :level_required, cue[:kind]
    assert_equal 4, cue[:n]
  end

  def test_at_level_the_basement_way_crosses
    w = world
    w.progression.load_progress!(level: 4, xp: 0)
    w.start_in("zone_7")
    w.possessed.walker.teleport(26, 3)
    drive(w)
    assert_equal "basement_1", w.zone_name
    assert_equal [4, 4], w.possessed.tile, "the declared spawn"
  end

  def test_the_sealed_dungeon_hole_names_its_level_fact_even_sealed
    w = world # fresh: seal unbreached AND level 1 < 6
    w.start_in("zone_7")
    w.possessed.walker.teleport(33, 14)
    drive(w)
    assert_equal "zone_7", w.zone_name
    assert_equal 6, w.station_cue[:n],
                 "the cue names its own fact regardless of siblings (P9)"
  end

  def test_at_level_the_sealed_hole_goes_silent_but_stays_shut
    w = world
    w.progression.load_progress!(level: 8, xp: 0)
    w.start_in("zone_7")
    w.possessed.walker.teleport(33, 14)
    drive(w)
    assert_equal "zone_7", w.zone_name, "the seal still holds"
    assert_nil w.station_cue,
               "level met: no cue — seal refusals stay silent (defeats parity)"
  end
end
