require_relative "../test_helper"
require "game/feel"

class FeelTest < Minitest::Test
  CFG = {
    hitstop_frames_hit: 3, hitstop_frames_kill: 8,
    shake_hit: 3.0, shake_player_hit: 6.0, shake_kill: 8.0,
    shake_decay: 0.85
  }.freeze

  def test_hitstop_counts_down
    feel = Game::Feel.new(CFG)
    feel.on_hit
    assert feel.hitstop?
    3.times { feel.tick }
    refute feel.hitstop?
  end

  def test_kill_hitstop_outlasts_hit_hitstop
    feel = Game::Feel.new(CFG)
    feel.on_hit
    feel.on_kill
    5.times { feel.tick }
    assert feel.hitstop?, "kill hitstop (8f) should still be running after 5 frames"
  end

  def test_shake_decays_to_zero
    feel = Game::Feel.new(CFG)
    feel.on_kill
    feel.tick
    refute_equal 0.0, feel.shake_x.abs + feel.shake_y.abs
    120.times { feel.tick }
    assert_equal 0.0, feel.shake_x
    assert_equal 0.0, feel.shake_y
  end

  def test_shake_is_deterministic
    a = Game::Feel.new(CFG)
    b = Game::Feel.new(CFG)
    [a, b].each(&:on_kill)
    10.times { a.tick }
    10.times { b.tick }
    assert_equal [a.shake_x, a.shake_y], [b.shake_x, b.shake_y]
  end
end
