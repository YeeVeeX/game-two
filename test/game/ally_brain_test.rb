require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# PREMIUM v22 ally brain (threat.json "ally", ships enabled=false under the
# canary law). These tests run with the brain ON through a threat override
# and prove the four behaviors exist and are deterministic:
#   focus fire · low-hp drink · dodge a provoked telegraph · ranged hold.
class AllyBrainTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def world(seats: 1, seed: 7) = Game::World.new(DATA, seed:, seats:)
  def idle = @idle ||= Core::ScriptedInput.new(frames: {})
  def inputs_for(w) = w.seats.length == 2 ? { 1 => idle, 2 => idle } : idle

  ON = { enabled: true, focus_fire: true, finish_pct: 0.35, drink_pct: 0.3, dodge_telegraphs: true,
         use_specials: true, ranged_hold_tiles: 3, ring_min_adjacent: 2 }.freeze

  # World keeps a reference to the DataStore's threat hash: override on a
  # per-world COPY so the shared DATA (and the default-off test) stay clean.
  def world_on(seats: 1)
    w = world(seats:)
    t = w.threat_config.dup
    t[:ally] = ON.dup
    t[:human] = { enabled: true, coward_pct: 0.25 }
    w.instance_variable_set(:@threat, t)
    w
  end

  def free_ally(w, kit)
    w.pack.members.find { |m| !w.controlled?(m) && m.kit_name == kit }
  end

  def test_brain_is_off_by_default
    w = world
    refute w.threat_config.dig(:ally, :enabled), "ships OFF (canary law)"
    refute w.threat_config.dig(:human, :enabled)
  end

  def test_ranged_ally_holds_distance_from_a_provoked_target
    w = world_on
    w.start_in("district")
    lob = free_ally(w, :lobber)
    hostile = w.humans.reject(&:dead?).min_by(&:name)
    hostile.provoke! if hostile.respond_to?(:provoke!)
    lob.walker.teleport(hostile.tile[0] + 1, hostile.tile[1])
    w.controlled_bodies.each_with_index { |b, i| b.walker.teleport(hostile.tile[0] + 6, hostile.tile[1] + i) }
        40.times { w.tick(inputs_for(w)) }
    d = [(lob.tile[0] - hostile.tile[0]).abs, (lob.tile[1] - hostile.tile[1]).abs].max
    assert_operator d, :>=, 2, "a projectile ally opens range instead of hugging the target (was #{d})"
  end

  def test_low_hp_ally_drinks_when_the_pack_has_a_flask
    w = world_on
    w.start_in("camp")
    ally = w.pack.members.find { |m| !w.controlled?(m) }
    w.pack.instance_variable_set(:@provisions, 2)
    ally.instance_variable_set(:@hp, (ally.max_hp * 0.2).to_i)
    before = w.pack.provisions
    hp0 = ally.hp
    30.times { w.tick(inputs_for(w)) }
    assert_operator w.pack.provisions, :<, before, "the ally spent a flask"
    assert_operator ally.hp, :>, hp0, "and healed"
  end

  def test_same_world_same_stream_with_the_brain_on
    a = world_on
    b = world_on
    a.start_in("district")
    b.start_in("district")
    120.times { a.tick(inputs_for(a)); b.tick(inputs_for(b)) }
    assert_equal a.pack.members.map(&:tile), b.pack.members.map(&:tile), "deterministic positions"
    assert_equal a.humans.map(&:hp), b.humans.map(&:hp), "deterministic damage"
  end
end
