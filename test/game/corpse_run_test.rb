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
end
