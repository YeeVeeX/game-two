require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# The sixth fun-verify's banked bug becomes the regression pin: holding
# dodge used to starve the walk branch (controllers.rb:33-37 was
# level-triggered) — the body only moved during the periodic dashes.
class ControllerDodgeTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def hold(actions, from, to)
    (from..to).to_h { |f| [f.to_s, actions.map(&:to_s)] }
  end

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def clear_path(world)
    (world.pack.living - [world.possessed]).each_with_index do |m, i|
      m.walker.teleport(2, 2 + i)
    end
  end

  def test_held_dodge_never_suppresses_walking
    world = Game::World.new(DATA)
    clear_path(world)
    dodges = 0
    world.bus.subscribe(:dodged) { dodges += 1 }
    start_x = world.possessed.tile[0]
    input = Core::ScriptedInput.new(frames: hold(%i[dodge right], 0, 119))
    drive(world, input, 120)
    assert_equal 1, dodges, "one dodge per press — holding must not re-dash"
    dodge_tiles = world.possessed.kit[:dodge][:tiles]
    assert world.possessed.tile[0] - start_x > dodge_tiles,
           "the body kept WALKING after the dash — held Shift must not lock movement"
  end

  def test_release_and_repress_dodges_again
    world = Game::World.new(DATA)
    clear_path(world)
    cd = world.possessed.kit[:dodge][:cooldown_frames]
    dodges = 0
    world.bus.subscribe(:dodged) { dodges += 1 }
    frames = hold(%i[dodge right], 0, 1)
             .merge(hold(%i[right], 2, cd + 1))
             .merge(hold(%i[dodge right], cd + 2, cd + 3))
    input = Core::ScriptedInput.new(frames:)
    drive(world, input, cd + 4)
    assert_equal 2, dodges, "a fresh press after cooldown dodges again"
  end
end
