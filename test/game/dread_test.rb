require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "core/event_bus"
require "game/world"
require "game/telemetry"

# v16 (d): the stakes knob — a seized body that DIES while seized loses
# its god-mark (the court's claim overrides the vat's; the inscription is
# the one thing the economy cannot refund). Ordering discipline (DeepSeek
# review fold): inscribed state is read AT the seizure-death moment,
# BEFORE corpse bookkeeping; the burn can never double-consume with the
# wipe path. Real World on the real zone chain (challenger_test staging).
class DreadTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]
  HITSTOP_SLACK = DATA["balance/combat"][:feel][:hitstop_frames_kill] + 4
  SEIZE = DATA["balance/combat"][:kits][:challenger][:seize]

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def seal1 = @seal1 ||= DATA["zones/district"][:stations].find { |s| s[:type] == "seal" }
  def seal2 = @seal2 ||= DATA["zones/district_two"][:stations].find { |s| s[:type] == "seal" }

  def descend!
    world.possessed.walker.teleport(29, 8)
    drive(world, scripted({}), 2)
    src = world.possessed
    src.walker.teleport(*seal1[:at])
    (world.pack.living - [src]).each_with_index { |m, i| m.walker.teleport(2, 2 + i) }
    world.pack.bank!(ECO[:breach_cost])
    assert world.interact(src)
    src.walker.teleport(*seal1[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    world.possessed.walker.teleport(19, 5)
    drive(world, scripted({}), 2)
    src = world.possessed
    src.walker.teleport(*seal2[:at])
    (world.pack.living - [src]).each_with_index { |m, i| m.walker.teleport(2, 2 + i) }
    world.pack.bank!(ECO[:breach_cost_2])
    assert world.interact(src)
    src.walker.teleport(*seal2[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    world.possessed.walker.teleport(7, 1)
    drive(world, scripted({}), 2)
    assert_equal "low_quay", world.zone_name
  end

  def challenger = world.humans.find { |h| h.kit_name == :challenger }

  def clear_crew!
    world.humans.reject { |h| h.kit_name == :challenger }.each do |h|
      h.take_hit(damage: 9_999, attacker: world.possessed)
    end
    drive(world, scripted({}), HITSTOP_SLACK * 2)
  end

  def collect(event)
    (@collected ||= {})[event] ||= [].tap do |log|
      world.bus.subscribe(event) { |e| log << e }
    end
  end

  def seize_possessed!
    descend!
    clear_crew!
    # FASE 6.1: BOSS 1's post is the MUSGO A vault [41,18]; allies park in
    # the entry hall, the possessed stands 3 tiles west inside the vault.
    (world.pack.living - [world.possessed]).each_with_index { |m, i| m.walker.teleport(5, 15 + i) }
    world.possessed.walker.teleport(38, 18)
    seized = collect(:vessel_seized)
    drive(world, scripted({}), SEIZE[:chant_frames] + 3)
    assert_equal 1, seized.length, "the chant completed into a seizure"
    world.possessed
  end

  def test_the_event_is_registered
    assert_includes Game::World::EVENTS, :inscription_burned
  end

  def test_the_data_switch_is_on
    assert DATA["balance/combat"][:kits][:challenger][:seizure_burns_inscription],
           "the stakes knob rides data, not code"
  end

  def test_seized_death_burns_the_inscription_exactly_once
    body = seize_possessed!
    body.inscribe_mark!
    burned = collect(:inscription_burned)
    tile = body.tile
    body.take_hit(damage: 9_999, attacker: challenger)
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_equal 1, burned.length, "the burn fires exactly once"
    assert_equal tile, burned.first[:at]
    refute body.marked?, "the god-mark is GONE — the court pierced the vat"
    assert world.seal_marks.any? { |m| m[:at] == tile },
           "MARK LOST presses its seal at the death tile"
  end

  def test_uninscribed_seized_death_burns_nothing
    body = seize_possessed!
    refute body.marked?
    burned = collect(:inscription_burned)
    marks_before = world.seal_marks.length
    body.take_hit(damage: 9_999, attacker: challenger)
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_empty burned, "no inscription, no burn"
    assert_equal marks_before, world.seal_marks.length
  end

  def test_inscribed_death_outside_seizure_burns_nothing
    descend!
    clear_crew!
    ally = (world.pack.living - [world.possessed]).first
    ally.inscribe_mark!
    burned = collect(:inscription_burned)
    ally.take_hit(damage: 9_999, attacker: challenger)
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_empty burned, "an unseized death is the vat's business, not the court's"
    assert ally.dead?
  end

  def test_burn_and_wipe_never_double_consume
    body = seize_possessed!
    body.inscribe_mark!
    burned = collect(:inscription_burned)
    consumed = collect(:mark_consumed)
    kept = collect(:vessel_kept)
    # Kill the WHOLE pack: the seized possessed dies while seized (burn)
    # and the wipe judgment follows. The burned mark must not revive it.
    world.pack.members.each { |m| m.take_hit(damage: 9_999, attacker: challenger) }
    600.times do
      break if world.states.current == :world && world.pack.living.any?
      input = scripted({})
      input.update(world.frame)
      world.tick(input)
    end
    assert_equal 1, burned.length
    assert_empty consumed, "the burned mark cannot ALSO be consumed by the judgment"
    assert_equal 1, kept.length,
                 "the floor judgment kept the vessel — revival came from the floor, not the mark"
  end

  def test_telemetry_varekka_line_gains_burns
    bus = Core::EventBus.new.register(*Game::World::EVENTS)
    telemetry = Game::Telemetry.new(bus)
    bus.emit(:inscription_burned, body: nil, at: [1, 1])
    bus.process
    line = telemetry.summary.lines.find { |l| l.start_with?("TELEMETRY varekka") }
    assert_match(/burns=1/, line)
  end
end
