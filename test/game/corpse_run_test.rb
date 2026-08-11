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
end
