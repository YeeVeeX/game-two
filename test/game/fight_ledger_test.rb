require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Fight-ledger integration tests — REAL data, REAL sim, no mocks.
# Helpers mirror corpse_run_test.rb (same staging idiom).
class FightLedgerTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  LEDGER = DATA["balance/ledger"]
  DEATH = DATA["balance/death"]
  QUIET = DATA["balance/ledger"][:ledger_quiet_frames]
  BEAT = DATA["balance/ledger"][:ledger_beat_frames]
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

  def isolate_humans(world, count = 2)
    kept = world.humans.first(count)
    world.humans.replace(kept)
    kept.each_with_index do |h, i|
      h.walker.teleport(40, 23 + i)
      h.stagger!(30_000)
    end
  end

  # Kills BY the possessed trigger hitstop at the next flush, and hitstop
  # freezes the quiet clock — drain it before counting drive frames (D1
  # lesson: frozen clocks silently eat drive budgets).
  def drain_hitstop(world)
    drive(world, scripted({}), 1) while world.feel.hitstop?
  end

  # Capture :fight_resolved payloads for the whole test.
  def resolved_events(world)
    @resolved ||= [].tap do |list|
      world.bus.subscribe(:fight_resolved) { |e| list << e.payload.dup }
    end
  end

  # Open a combat window without hitstop: hurt (never kill) a parked human.
  def poke(world)
    h = world.humans.reject(&:dead?).first
    h.take_hit(damage: 1, attacker: world.possessed)
    drive(world, scripted({}), 1)
  end

  # Kill a drop-carrying human and pick its drop up (opens a window too).
  def stage_pickup(world)
    kill(nearest_human(world), by: world.possessed)
    drive(world, scripted({}), 1)
    tile = world.drops.first[:tile]
    world.possessed.walker.teleport(*tile)
    drive(world, scripted({}), 1)
    press_interact(world)
  end

  # Carrier dies loaded as an ALLY death (no wipe): pickup, swap off, kill.
  def stage_loaded_death(world)
    stage_pickup(world)
    carrier = world.possessed
    amount = carrier.carried
    assert_operator amount, :>, 0
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 2)
    refute_equal carrier, world.possessed
    kill(carrier, by: world.humans.reject(&:dead?).first)
    drive(world, scripted({}), 2)
    [carrier, amount]
  end

  # --- data invariants (review M5-design: the interlock is load-bearing) ---

  def test_ledger_balance_invariants
    assert_operator LEDGER[:ledger_quiet_frames], :<, DEATH[:loot_settle_frames],
                    "quiet >= settle silently kills the mid-fight negative beat (spec M5)"
    %i[ledger_quiet_frames ledger_beat_frames].each do |k|
      assert_operator LEDGER[k], :>, 0, "#{k} must be a positive frame count"
    end
  end
end
