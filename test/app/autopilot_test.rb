require_relative "../test_helper"
require "app/autopilot"
require "net/protocol"

# v18 session-8 soak (brief D1/D2): the seeded test driver behind --bot.
# A PURE input source on the existing seam (update(tick)/down?(action));
# held actions are a pure function of (seed, sampled tick sequence) so a
# soak episode is re-runnable from its banner line. Deliberately dumb —
# these tests pin determinism, legality, liveness, and the quit contract,
# NEVER behavior quality (tuning bot realism is out of scope by law).
class AutopilotTest < Minitest::Test
  def sample(seed:, ticks:, quit_tick: 36_000)
    bot = App::Autopilot.new(seed:, quit_tick:)
    (0...ticks).map do |t|
      bot.update(t)
      Net::Protocol::ACTIONS.select { |a| bot.down?(a) }
    end
  end

  def test_same_seed_same_first_n_presses
    assert_equal sample(seed: 7, ticks: 900), sample(seed: 7, ticks: 900)
  end

  def test_different_seeds_diverge
    refute_equal sample(seed: 7, ticks: 900), sample(seed: 8, ticks: 900)
  end

  def test_emits_only_legal_actions
    bot = App::Autopilot.new(seed: 3, quit_tick: 36_000)
    illegal = %i[quit escape jump menu confirm]
    600.times do |t|
      bot.update(t)
      illegal.each { |a| refute bot.down?(a), "bot held illegal action #{a}" }
    end
  end

  def test_bot_actually_plays_moves_and_fights
    held = sample(seed: 11, ticks: 1200).flatten
    assert held.any? { |a| %i[left right up down].include?(a) }, "bot never moved"
    assert_includes held, :attack, "bot never attacked"
  end

  def test_movement_persists_across_ticks_not_white_noise
    frames = sample(seed: 5, ticks: 1200).map { |a| a & %i[left right up down] }
    changes = frames.each_cons(2).count { |a, b| a != b }
    assert_operator changes, :<, 200,
                    "direction set changed #{changes}x in 1200 ticks — no persistence"
  end

  def test_quit_contract_at_target_tick
    bot = App::Autopilot.new(seed: 1, quit_tick: 500)
    refute bot.quit?(0)
    refute bot.quit?(499)
    assert bot.quit?(500)
    assert bot.quit?(501)
  end

  def test_default_quit_tick_is_the_ritual_floor
    assert_equal 36_000, App::Autopilot::DEFAULT_QUIT_TICK
    assert App::Autopilot.new(seed: 1).quit?(36_000)
  end

  def test_banner_pins_seed_and_quit_tick
    bot = App::Autopilot.new(seed: 42, quit_tick: 7200)
    assert_equal "AUTOPILOT seed=42 quit_tick=7200", bot.banner
  end

  # The sampling law tolerance: a stalled seat re-samples ticks
  # non-consecutively (lockstep stalls hold the tick); update must be a
  # function of the tick argument, never of call count.
  def test_repeated_update_at_same_tick_is_stable
    bot = App::Autopilot.new(seed: 9, quit_tick: 36_000)
    bot.update(100)
    first = Net::Protocol::ACTIONS.select { |a| bot.down?(a) }
    bot.update(100)
    assert_equal first, Net::Protocol::ACTIONS.select { |a| bot.down?(a) }
  end
end
