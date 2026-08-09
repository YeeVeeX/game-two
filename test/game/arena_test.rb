require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/arena"

# Integration tests against the REAL data files and the REAL sim — no mocks.
class ArenaTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def arena = @arena ||= Game::Arena.new(DATA)

  def run_frames(arena, input, n)
    n.times { arena.tick(input) }
  end

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def husk_distance(arena)
    px, py = arena.player.center
    ex, ey = arena.enemy.center
    Math.hypot(ex - px, ey - py)
  end

  # Drives input.update from the arena's own frame counter.
  def drive(arena, input, n)
    n.times do
      input.update(arena.frame)
      arena.tick(input)
    end
  end

  def test_player_moves_right_under_held_input
    input = scripted(hold(:right, 0, 29))
    x0 = arena.player.x
    drive(arena, input, 30)
    assert_operator arena.player.x, :>, x0 + 100
  end

  def test_full_kill_loop_three_hits_kill_the_husk
    # Stand in reach: park the enemy next to the player by walking right until
    # the husk (chase AI) closes in, then attack three times.
    input = scripted({})
    drive(arena, input, 320) # husk aggros and walks into attack range (480px at 1.6px/f)
    px, py = arena.player.center
    ex, ey = arena.enemy.center
    assert_operator Math.hypot(ex - px, ey - py), :<, 120, "husk should have closed distance"

    # Play it like a player would: wait for the husk to be in reach, swing,
    # repeat. Knockback sends it flying, so it has to walk back between hits.
    attacks = 0
    guard = 0
    idle = scripted({})
    until arena.enemy.dead? || guard > 2000
      if husk_distance(arena) > 50
        drive(arena, idle, 1)
        guard += 1
      else
        dir = (arena.enemy.center[0] - arena.player.center[0]).positive? ? :right : :left
        swing = scripted({ arena.frame.to_s => [dir.to_s, "attack"] })
        attacks += 1
        drive(arena, swing, 25) # windup 6 + active 4 + recovery 10 + slack
        guard += 25
      end
    end
    assert arena.enemy.dead?, "husk should die"
    assert_operator attacks, :<=, 6, "3 clean hits kill; allow a few whiffs/interrupts"
  end

  def test_husk_kills_idle_player_and_player_respawns
    input = scripted({})
    death_seen = false
    hp_at_respawn = nil
    arena.bus.subscribe(:player_died) { death_seen = true }
    arena.bus.subscribe(:player_respawned) { hp_at_respawn ||= arena.player.hp }

    drive(arena, input, 3000)
    assert death_seen, "an idle player should eventually die to the husk"
    refute_nil hp_at_respawn, "player should respawn after the death timer"
    assert_equal arena.player.max_hp, hp_at_respawn, "respawn restores full hp"
    assert_equal :arena, arena.states.current
  end

  def test_determinism_same_script_same_state
    a = Game::Arena.new(DATA)
    b = Game::Arena.new(DATA)
    script = hold(:right, 0, 120).merge("60" => %w[right attack])
    2.times do |i|
      arena_i = i.zero? ? a : b
      input = scripted(script)
      drive(arena_i, input, 300)
    end
    assert_equal [a.player.x, a.player.y, a.player.hp], [b.player.x, b.player.y, b.player.hp]
    assert_equal [a.enemy.x, a.enemy.y, a.enemy.hp], [b.enemy.x, b.enemy.y, b.enemy.hp]
  end

  def test_dodge_grants_iframes
    input = scripted({ "0" => ["dodge"] })
    drive(arena, input, 1)
    assert arena.player.invulnerable?
    refute arena.player.take_hit(damage: 10, from_x: 0, from_y: 0)
    assert_equal arena.player.max_hp, arena.player.hp
  end

  def test_husk_respawns_after_kill
    # Kill the husk via direct hits (sim-level, not input-level: this test is
    # about the respawn wiring, not the attack mechanics).
    px, py = arena.player.center
    3.times { arena.enemy.take_hit(damage: 25, knockback: 0.0, from_x: px, from_y: py) }
    assert arena.enemy.dead?
    input = scripted({})
    drive(arena, input, DATA["balance/combat"][:enemies][:husk][:respawn_frames] + 10)
    refute arena.enemy.dead?, "a fresh husk should have spawned"
  end
end
