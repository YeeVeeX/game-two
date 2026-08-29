require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/telemetry"

# v20 T4 (foundation L4): the contested/cadenced heal totem on floor -1.
# Real files, no mocks — the authored district totem at [26,55] (mid
# bridge 3, beside Junior's own bridge guardian), numbers from
# data/balance/sustain.json (Rule 3). The pulse heals LIVING pack bodies
# within Chebyshev radius, clamped; dead untouched (vat monopoly law);
# fires on cadence regardless of range occupancy (discoverability law).
class TotemTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["balance/sustain"][:totem]
  TOTEM = [26, 55].freeze

  def world = @world ||= Game::World.new(DATA).tap { |w| w.start_in("district") }

  def pulses
    @pulses ||= [].tap do |log|
      world.bus.subscribe(:totem_pulse) { |e| log << e.payload.merge(frame: world.frame) }
    end
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  # The authored guardian contests the totem; tests that need a quiet
  # bridge remove him through the same take_hit path combat uses. Kills
  # kick hitstop (feel), and hitstop SKIPS tick_world — the cadence pause
  # law — so staging settles the feel clock before any cadence counting.
  # (While the pack HOLDS the bridge his respawn stays deferred:
  # respawn_block_tiles covers the whole radius-2 field.)
  def clear_guardian!
    guard = world.humans.find { |h| h.tile == [26, 54] }
    kill(guard, by: world.possessed) if guard
    settle!
  end

  def settle!
    world.bus.process
    world.tick(Core::NullInput.new) while world.feel.hitstop?
  end

  def test_authored_totem_station_is_on_the_district_bridge
    station = world.map.station_at(*TOTEM)
    refute_nil station, "district must carry the authored totem at #{TOTEM}"
    assert_equal "totem", station[:type]
  end

  def test_pulse_heals_in_radius_clamped_and_never_the_dead
    clear_guardian!
    body = world.possessed
    ally, other = (world.pack.members - [body]).first(2)
    body.walker.teleport(25, 55)   # Chebyshev 1 — in range, deep wound
    ally.walker.teleport(24, 55)   # Chebyshev 2 — in range, shallow wound
    other.walker.teleport(27, 55)  # in range but DEAD — vat monopoly
    body.take_hit(damage: 20, attacker: ally)
    ally.take_hit(damage: 4, attacker: body)
    kill(other, by: body)
    settle!
    hurt_hp = body.hp
    pulses
    (CFG[:cadence_ticks] - 1).times { world.tick(Core::NullInput.new) }
    assert_empty pulses, "no pulse may fire before the data cadence"
    world.tick(Core::NullInput.new)
    world.bus.process
    assert_equal 1, pulses.length, "the pulse fires exactly at cadence_ticks"
    assert_equal TOTEM, pulses.first[:at]
    assert_equal CFG[:radius], pulses.first[:range]
    assert_equal 2, pulses.first[:healed], "two living wounded bodies in range"
    assert_equal hurt_hp + CFG[:heal_amount], body.hp, "deep wound heals the full amount"
    assert_equal ally.max_hp, ally.hp, "shallow wound clamps at max_hp"
    assert other.dead?, "the pulse never revives (vat keeps its monopoly)"
    assert_equal 0, other.hp
  end

  def test_pulse_fires_empty_and_out_of_range_bodies_are_untouched
    clear_guardian!
    body = world.possessed
    ally, other = (world.pack.members - [body]).first(2)
    # The whole pack sits TOGETHER just outside the radius-2 field — a
    # split pack walks the map to regroup and drags rusher aggro onto the
    # bridge mid-wait (hit live cutting this test).
    body.walker.teleport(23, 55)  # Chebyshev 3 — OUT of the radius-2 field
    ally.walker.teleport(22, 55)  # Chebyshev 4
    other.walker.teleport(23, 54) # Chebyshev 3
    body.take_hit(damage: 20, attacker: ally)
    settle!
    hurt_hp = body.hp
    pulses
    CFG[:cadence_ticks].times { world.tick(Core::NullInput.new) }
    world.bus.process
    assert_equal 1, pulses.length, "the idle pulse still fires (discoverability law)"
    assert_equal 0, pulses.first[:healed]
    assert_equal hurt_hp, body.hp, "out-of-range body untouched"
  end

  def test_totem_timer_rides_the_digest_and_telemetry_counts_heals
    telemetry = Game::Telemetry.new(world.bus, world:)
    clear_guardian!
    body = world.possessed
    body.walker.teleport(26, 55) # ON the totem tile — Chebyshev 0
    body.take_hit(damage: 12, attacker: (world.pack.members - [body]).first)
    settle!
    2.times { world.tick(Core::NullInput.new) }
    group = world.digest_snapshot.find { |name, _| name == "totem.district.26.55" }
    refute_nil group, "totem timer is a gameplay-affecting countdown (digest law)"
    timer = group[1].to_h["timer"]
    assert_operator timer, :<, CFG[:cadence_ticks], "the armed timer counts down"
    (CFG[:cadence_ticks] - 2).times { world.tick(Core::NullInput.new) }
    world.bus.process
    assert_includes telemetry.summary, "TELEMETRY totem heals=1 pulses=1"
    rearmed = world.digest_snapshot.find { |name, _| name == "totem.district.26.55" }
    assert_equal CFG[:cadence_ticks], rearmed[1].to_h["timer"], "cadence re-arms after the pulse"
  end
end
