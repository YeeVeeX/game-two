require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# D1 corpse-run integration tests — REAL data, REAL sim, no mocks.
# Helpers mirror world_test.rb (same staging idiom).
class CorpseRunTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  DEATH = DATA["balance/death"]
  STEP = DATA["balance/combat"][:kits][:striker][:step_frames]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_district(world)
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    assert_equal "district", world.zone_name
  end

  def nearest_human(world)
    px, py = world.possessed.tile
    world.humans.reject(&:dead?).min_by { |h| [(h.tile[0] - px).abs, (h.tile[1] - py).abs].max }
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  def press_interact(world)
    drive(world, scripted({}), 1) while world.feel.hitstop?
    drive(world, scripted({ world.frame.to_s => ["interact"] }), 1)
    drive(world, scripted({}), 1)
  end

  def stage_drop_under_possessed(world)
    enter_district(world)
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 1)
    tile = world.drops.first[:tile]
    world.possessed.walker.teleport(*tile)
    drive(world, scripted({}), 1)
  end

  # Pick up a drop, swap OFF the carrier (so its death is an ally death,
  # not a possessed death), kill it by a human (no hitstop). Returns the
  # dead carrier and what it carried.
  def stage_loaded_death(world)
    stage_drop_under_possessed(world)
    press_interact(world)
    carrier = world.possessed
    amount = carrier.carried
    assert_operator amount, :>, 0
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    refute_equal carrier, world.possessed
    kill(carrier, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    [carrier, amount]
  end

  def load_at(world, tile, zone: nil)
    list = zone ? world.corpse_loads(zone) : world.corpse_loads
    list.find { |c| c[:tile] == tile }
  end

  # world_test idiom: keep `count` humans, parked far away and staggered —
  # long waits must not get the survivor killed mid-test.
  def isolate_humans(world, count = 2)
    kept = world.humans.first(count)
    world.humans.replace(kept)
    kept.each_with_index do |h, i|
      h.walker.teleport(40, 23 + i)
      h.stagger!(30_000)
    end
  end

  # --- data invariants (review FN-3: grace <= term or the top-up truncates) --

  def test_death_balance_invariants
    assert_operator DEATH[:wipe_grace_frames], :<=, DEATH[:corpse_term_frames]
    %i[corpse_term_frames loot_settle_frames wipe_grace_frames
       expiry_flash_frames].each do |k|
      assert_operator DEATH[k], :>, 0, "#{k} must be a positive frame count"
    end
    assert_operator DEATH[:settle_pip_alpha], :>, 0
    assert_operator DEATH[:settle_pip_alpha], :<=, 1
  end

  # --- container creation (D1 replaces the D0 vanish) ----------------------

  def test_death_with_carry_creates_container_not_vanish
    lost = []
    loaded = []
    world.bus.subscribe(:carried_lost) { |e| lost << e }
    world.bus.subscribe(:corpse_loaded) { |e| loaded << e }
    carrier, amount = stage_loaded_death(world)
    assert_equal 0, carrier.carried, "carried drains into the container"
    assert_empty lost, "no carried_lost on death — that is expiry's event now"
    c = load_at(world, carrier.tile)
    refute_nil c, "container sits on the death tile"
    assert_equal amount, c[:amount]
    assert_equal DEATH[:corpse_term_frames], c[:term]
    assert_equal [amount], loaded.map { |e| e[:amount] }
    assert_equal [carrier.tile], loaded.map { |e| e[:tile] }
  end

  def test_death_without_carry_creates_no_container
    enter_district(world)
    victim = world.pack.living.reject { |m| m.equal?(world.possessed) }.first
    assert_equal 0, victim.carried
    kill(victim, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    assert_empty world.corpse_loads
  end

  def test_humans_never_create_containers
    enter_district(world)
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 2)
    assert_empty world.corpse_loads
  end

  def test_corpse_record_is_linked_to_its_container
    carrier, _amount = stage_loaded_death(world)
    c = load_at(world, carrier.tile)
    rec = world.corpses.find { |r| r[:container_id] == c[:id] }
    refute_nil rec, "the cosmetic corpse carries the container's serial"
  end

  def test_stacked_deaths_make_two_containers_with_distinct_ids
    carrier, amount = stage_loaded_death(world)
    second = world.possessed
    second.pick_up(2)
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    # teleport AFTER the swap drive: the freed body is AI-driven and would
    # walk off the stack tile during those frames
    second.walker.teleport(*carrier.tile)
    kill(second, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    loads = world.corpse_loads.select { |c| c[:tile] == carrier.tile }
    assert_equal 2, loads.length, "no merging — one container per body"
    assert_equal [amount, 2], loads.map { |c| c[:amount] }, "creation order kept"
    refute_equal loads[0][:id], loads[1][:id]
  end

  # --- clocks: term ticks everywhere, veil freezes, expiry destroys --------

  def test_term_ticks_in_abandoned_zones
    carrier, _ = stage_loaded_death(world)
    before = load_at(world, carrier.tile)[:term_left]
    # walk the pack home through the west gate (carry_home idiom)
    world.possessed.walker.teleport(1, 13)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 4)), STEP * 4)
    assert_equal "nest", world.zone_name
    drive(world, scripted({}), 100)
    after = load_at(world, carrier.tile, zone: "district")[:term_left]
    assert_operator after, :<, before - 90, "nest time is real time (tick_drops law)"
  end

  def test_term_is_frozen_during_the_wipe_veil
    carrier, _ = stage_loaded_death(world)
    killer = world.humans.reject(&:dead?).first
    world.pack.living.each { |m| kill(m, by: killer) }
    drive(world, scripted({}), 1)
    assert_equal :nest_respawn, world.states.current
    frozen = load_at(world, carrier.tile, zone: "district")[:term_left]
    drive(world, scripted({}), 50) # deep inside the 90f veil
    assert_equal frozen, load_at(world, carrier.tile, zone: "district")[:term_left],
                 "tick_world never runs during nest_respawn — terms freeze (review CF-6)"
  end

  def test_expiry_destroys_load_emits_and_flashes
    lost = []
    world.bus.subscribe(:carried_lost) { |e| lost << e }
    carrier, amount = stage_loaded_death(world)
    c = load_at(world, carrier.tile)
    c[:term_left] = 3 # direct record mutation — the drops-test idiom
    drive(world, scripted({}), 5)
    assert_nil load_at(world, carrier.tile), "container removed at expiry"
    assert_equal [{ amount:, tile: carrier.tile, zone: "district" }],
                 lost.map { |e| { amount: e[:amount], tile: e[:tile], zone: e[:zone] } }
    flash = world.expiry_flashes.find { |f| f[:tile] == carrier.tile }
    refute_nil flash, "expiry leaves a flash record in ITS zone"
    rec = world.corpses.find { |r| r[:tile] == carrier.tile && r[:faction] == :pack }
    assert_nil rec[:container_id], "link cleared at expiry"
    # expiry landed mid-drive (term_left hit 0 on the 3rd of 5 ticks) — the
    # re-anchor is "recent", not "this exact frame"
    assert_in_delta world.frame, rec[:at_frame], 5, "fade re-anchored at the expiry"
  end

  def test_expiry_flash_is_per_zone
    carrier, _ = stage_loaded_death(world)
    world.possessed.walker.teleport(1, 13)
    drive(world, scripted(hold(:left, world.frame, world.frame + STEP * 4)), STEP * 4)
    assert_equal "nest", world.zone_name
    # mutate AFTER arriving so the expiry lands inside the drive below and the
    # 45f flash is still alive at the assertions (walk frames would eat it)
    load_at(world, carrier.tile, zone: "district")[:term_left] = 10
    drive(world, scripted({}), 20)
    assert_empty world.expiry_flashes, "the nest floor never flashes for a district expiry (review CF-4)"
    refute_empty world.expiry_flashes("district")
  end

  # --- linked corpses outlive the cosmetic lifecycle (review CF-1) ---------

  def test_linked_corpse_survives_the_fade_prune
    carrier, _ = stage_loaded_death(world)
    drive(world, scripted({}), Game::World::CORPSE_FADE_FRAMES + 20)
    rec = world.corpses.find { |r| r[:container_id] }
    refute_nil rec, "a loaded corpse is exempt from prune_caches (review CF-1)"
    assert_equal carrier.tile, rec[:tile]
  end

  def test_cap_evicts_oldest_unlinked_never_the_linked
    carrier, _ = stage_loaded_death(world)
    linked_id = load_at(world, carrier.tile)[:id]
    # make the linked record the OLDEST so eviction actually reaches it
    world.corpses.reject! { |r| !r[:container_id] }
    45.times { |i| world.corpses << { tile: [1, 1], x: 32, y: 32, faction: :human, at_frame: world.frame } }
    # trigger one real leave_corpse (any death) to run the cap logic
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 2)
    assert world.corpses.any? { |r| r[:container_id] == linked_id },
           "cap eviction skips linked records (review CF-1)"
  end

  def test_cap_flood_of_linked_records_never_clobbers_a_foreign_link
    enter_district(world)
    world.corpses.replace((1..45).map do |i|
      { tile: [1, 1], x: 32, y: 32, faction: :pack, at_frame: world.frame,
        container_id: 1000 + i }
    end)
    victim = world.pack.living.reject { |m| m.equal?(world.possessed) }.first
    victim.pick_up(3)
    kill(victim, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    container = world.corpse_loads.find { |c| c[:tile] == victim.tile }
    refute_nil container, "container spawns even when its cosmetic record was evicted"
    refute world.corpses.any? { |r| r[:container_id] == container[:id] },
           "the fresh record was the eviction victim - no stamp, no foreign clobber (review fold 3)"
    assert_equal 45, world.corpses.count { |r| r[:container_id] }, "foreign links untouched"
  end

  def test_released_corpse_fades_then_prunes_normally
    carrier, _ = stage_loaded_death(world)
    c = load_at(world, carrier.tile)
    c[:term_left] = 3
    drive(world, scripted({}), 5) # expire -> link cleared, at_frame re-anchored
    drive(world, scripted({}), Game::World::CORPSE_FADE_FRAMES + 5)
    assert_nil world.corpses.find { |r| r[:tile] == carrier.tile && r[:faction] == :pack },
               "after release the normal fade + prune lifecycle resumes"
  end

  # --- recovery: settle gates, then full transfer, creation order ----------

  def test_settle_blocks_then_admits_the_loot
    looted = []
    world.bus.subscribe(:corpse_looted) { |e| looted << e }
    carrier, amount = stage_loaded_death(world)
    world.possessed.walker.teleport(*carrier.tile)
    press_interact(world)
    assert_equal 0, world.possessed.carried, "settling corpse refuses the press"
    assert_empty looted
    drive(world, scripted({}), DEATH[:loot_settle_frames])
    press_interact(world)
    assert_equal amount, world.possessed.carried, "full amount, no partials"
    assert_nil load_at(world, carrier.tile), "container consumed"
    assert_equal [{ amount:, carried: amount, tile: carrier.tile }],
                 looted.map { |e| { amount: e[:amount], carried: e[:carried], tile: e[:tile] } }
    # margin oracle (impl review fold 2): term_left/term ride the event so the
    # spec's recovery margin is computable offline - frame math lies whenever
    # hitstop, the veil freeze, or a wipe-grace rewrite intervened
    assert_operator looted.first[:term_left], :>, 0
    assert_equal DEATH[:corpse_term_frames], looted.first[:term]
    rec = world.corpses.find { |r| r[:tile] == carrier.tile && r[:faction] == :pack }
    assert_nil rec[:container_id], "loot releases the corpse link"
  end

  def test_interact_priority_drop_then_corpse
    carrier, amount = stage_loaded_death(world)
    drive(world, scripted({}), DEATH[:loot_settle_frames])
    world.drops << { tile: carrier.tile.dup, amount: 5, frames_left: 1800, decay_frames: 1800 }
    world.possessed.walker.teleport(*carrier.tile)
    press_interact(world)
    assert_equal 5, world.possessed.carried, "drop wins the first press (two-press rule)"
    press_interact(world)
    assert_equal 5 + amount, world.possessed.carried, "corpse loots on the second"
  end

  def test_stacked_containers_loot_in_death_order
    carrier, amount = stage_loaded_death(world)
    second = world.possessed
    second.pick_up(2)
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    # teleport AFTER the swap drive: the freed body is AI-driven and would
    # walk off the stack tile during those frames
    second.walker.teleport(*carrier.tile)
    kill(second, by: world.humans.reject(&:dead?).first)
    isolate_humans(world, 0) # the survivor must outlive the settle wait
    drive(world, scripted({}), DEATH[:loot_settle_frames] + 5)
    world.possessed.walker.teleport(*carrier.tile)
    press_interact(world)
    assert_equal amount, world.possessed.carried, "oldest container first"
    press_interact(world)
    assert_equal amount + 2, world.possessed.carried
  end

  # --- wipe: grace top-up, containers survive the run back -----------------

  def wipe_pack(world)
    killer = world.humans.reject(&:dead?).first
    world.pack.living.each { |m| kill(m, by: killer) }
    drive(world, scripted({}), 1)
    assert_equal :nest_respawn, world.states.current
  end

  def test_wipe_grace_tops_up_short_terms_only
    carrier, _ = stage_loaded_death(world)
    short = load_at(world, carrier.tile)
    short[:term_left] = 100
    wipe_pack(world)
    assert_equal DEATH[:wipe_grace_frames], short[:term_left],
                 "short term topped to the grace floor"
  end

  def test_wipe_grace_leaves_long_terms_alone
    carrier, _ = stage_loaded_death(world)
    long = load_at(world, carrier.tile)
    before = long[:term_left]
    assert_operator before, :>, DEATH[:wipe_grace_frames]
    wipe_pack(world)
    # -1: wipe_pack's single drive frame ticks the clock once before the
    # state flips — the grace itself must not touch a long term
    assert_equal before - 1, long[:term_left]
  end

  def test_containers_survive_the_pack_respawn
    carrier, amount = stage_loaded_death(world)
    death_tile = carrier.tile # revive! moves the creature — capture pre-wipe
    wipe_pack(world)
    drive(world, scripted({}), DATA["balance/combat"][:respawn_frames] + 2)
    assert_equal :world, world.states.current
    assert_equal "nest", world.zone_name
    c = load_at(world, death_tile, zone: "district")
    refute_nil c, "the container IS the point of the run back"
    assert_equal amount, c[:amount]
  end
end
