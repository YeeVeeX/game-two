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
      base = DATA["balance/combat"][:kits][h.kit_name][:max_hp]
      assert_equal base + base * 100 / 100, h.max_hp,
                   "#{h.name}: kit base #{base} + 100% (Integer tier law)"
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
    assert_equal 140, boss.max_hp, "BOSS 1 (challenger) difficulty is the re-cut's business"
    assert_equal 0, boss.tier_dmg_pct
  end

  # --- the damage seam ---------------------------------------------------

  def test_tiered_enemy_damage_reads_the_stamped_pct
    w = world
    tiered = humans_in(w, "dungeon_1").first
    plain = humans_in(w, "district").first
    # FASE 6.1 swap: dungeon_1's roster is the medusa fauna (stinger/warden) —
    # the law reads the STAMPED pct against the kit's own base, whatever kind
    # stands first (stinger 14 -> 14 + 14*75/100 = 24, Integer division).
    tb = tiered.kit[:attack][:damage]
    assert_equal tb + (tb * 75) / 100, w.send(:leveled_damage, tiered, tiered.kit[:attack]),
                 "base + base*75/100 (Integer division) for the tiered zone"
    pb = plain.kit[:attack][:damage]
    assert_equal pb, w.send(:leveled_damage, plain, plain.kit[:attack])
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
    tier_hp = DATA["balance/tiers"][:zones][:dungeon_1][:enemy_hp_pct]
    base_t = DATA["balance/combat"][:kits][tiered.kit_name][:max_hp]
    base_p = DATA["balance/combat"][:kits][plain.kit_name][:max_hp]
    tiered_base = base_t + (base_t * tier_hp) / 100 # the tier law is ADDITIVE (base + base*pct/100)
    assert_equal (tiered_base * scale).round, tiered.max_hp, "tier THEN coop"
    assert_equal (base_p * scale).round, plain.max_hp
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
