require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v16 (d): the court's claim overrides the vat's — a body that DIES while
# seized burns its god-mark (the one loss the economy cannot refund).
# Ordering discipline (spec, DeepSeek fold): inscribed state is read at
# the seizure-death moment in end_seizure, BEFORE corpse bookkeeping and
# long before the judgment reads marked? — burn and wipe-path consumption
# can never double-fire. Real World on the real quay, no mocks.
class InscriptionBurnTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def world = @world ||= Game::World.new(DATA)

  def drive(n)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def varekka
    @varekka ||= begin
      world.start_in("low_quay")
      world.humans.find { |h| h.kit_name == :challenger }
    end
  end

  def collect(event)
    [].tap { |log| world.bus.subscribe(event) { |e| log << e } }
  end

  def seize_and_kill!(body, inscribe: true)
    body.inscribe_mark! if inscribe
    body.seize!(varekka, varekka.kit[:seize][:duration_frames])
    body.take_hit(damage: 9_999, attacker: varekka)
  end

  def test_seized_death_burns_the_mark_and_stamps_the_floor
    varekka # stage the quay FIRST — start_in moves the pack
    body = world.possessed
    tile = body.tile
    burned = collect(:inscription_burned)
    seize_and_kill!(body)
    drive(2)
    refute body.marked?, "the god-mark burned"
    assert_equal 1, burned.length
    assert_equal tile, burned.first[:at]
    entry = world.send(:instance_variable_get, :@banner_queue)
                 .find { |b| b[:text_key] == "stamp.mark_void" }
    refute_nil entry, "THE MARK IS VOID stamps the court's act"
    assert_equal tile, entry[:at], "a located stamp — the floor is marked where it died"
    flash = world.expiry_flashes.find { |f| f[:tile] == tile }
    refute_nil flash, "the expiry-flash is the burn's UNCONDITIONAL channel " \
                      "(the stamp can queue or evict; the flash always lands)"
  end

  def test_uninscribed_seized_death_burns_nothing
    body = world.possessed
    burned = collect(:inscription_burned)
    seize_and_kill!(body, inscribe: false)
    drive(2)
    assert_empty burned
    assert_nil world.send(:instance_variable_get, :@banner_queue)
                    .find { |b| b[:text_key] == "stamp.mark_void" }
  end

  def test_unseized_death_never_burns
    body = world.possessed
    burned = collect(:inscription_burned)
    body.inscribe_mark!
    body.take_hit(damage: 9_999, attacker: varekka)
    drive(2)
    assert_empty burned
    assert body.marked?, "the mark rides the corpse to the judgment (D1b law)"
  end

  # The spec's never-burn list, path by path: only why=:died burns.
  def test_slaying_him_while_seized_never_burns
    body = world.possessed
    burned = collect(:inscription_burned)
    ended = collect(:seizure_ended)
    body.inscribe_mark!
    body.seize!(varekka, varekka.kit[:seize][:duration_frames])
    varekka.take_hit(damage: 9_999, attacker: body)
    drive(2)
    assert_equal [:slain], ended.map { |e| e[:why] }
    assert_empty burned
    assert body.marked?, "killing the court's man keeps your mark"
  end

  def test_leaving_the_zone_never_burns
    body = world.possessed
    burned = collect(:inscription_burned)
    ended = collect(:seizure_ended)
    body.inscribe_mark!
    body.seize!(varekka, varekka.kit[:seize][:duration_frames])
    world.start_in("nest")
    drive(1)
    assert_equal [:zone_left], ended.map { |e| e[:why] }
    assert_empty burned
    assert body.marked?
  end

  def test_the_wiped_sweep_never_burns
    body = world.possessed
    burned = collect(:inscription_burned)
    body.inscribe_mark!
    body.seize!(varekka, varekka.kit[:seize][:duration_frames])
    world.send(:end_seizure, body, :wiped)
    drive(1)
    assert_empty burned
    assert body.marked?
  end

  def test_expired_seizure_never_burns
    body = world.possessed
    burned = collect(:inscription_burned)
    ended = collect(:seizure_ended)
    body.inscribe_mark!
    body.seize!(varekka, 2)
    drive(5)
    assert_equal 1, ended.length
    assert_equal :expired, ended.first[:why]
    assert_empty burned
    assert body.marked?, "surviving the term keeps the mark"
  end

  def test_burn_and_judgment_never_double_consume
    body = world.possessed
    burned = collect(:inscription_burned)
    consumed = collect(:mark_consumed)
    kept = collect(:vessel_kept)
    body.inscribe_mark!
    body.seize!(varekka, varekka.kit[:seize][:duration_frames])
    # Kill the whole pack in one frame: burn (why=:died) and the wipe
    # judgment land in the same arc — the mark must be consumed ONCE.
    world.pack.living.each { |m| m.take_hit(damage: 9_999, attacker: varekka) }
    drive(DATA["balance/combat"][:respawn_frames] + 60)
    assert_equal 1, burned.length, "the burn fired exactly once"
    assert_empty consumed, "the judgment found no mark left to consume"
    assert_equal 1, kept.length,
                 "burned protection = the body only came back via the floor"
  end

  def test_data_declares_the_stakes_knob
    assert_equal true,
                 DATA["balance/combat"][:kits][:challenger][:seizure_burns_inscription]
  end

  def test_display_declares_the_dread_keys
    %i[writ_radius_tiles writ_out_alpha seized_body_alpha].each do |k|
      refute_nil DATA["display"][k], "display.json declares #{k}"
    end
  end
end
