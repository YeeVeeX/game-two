require_relative "../test_helper"
require "core/input"

class ScriptedInputTest < Minitest::Test
  def test_actions_follow_the_script_per_frame
    input = Core::ScriptedInput.new(frames: { "0" => ["right"], "1" => %w[right attack] })
    input.update(0)
    assert input.down?(:right)
    refute input.down?(:attack)
    input.update(1)
    assert input.down?(:attack)
    input.update(2)
    refute input.down?(:right)
  end

  def test_last_frame
    input = Core::ScriptedInput.new(frames: { "3" => ["left"], "10" => ["left"] })
    assert_equal 10, input.last_frame
  end
end

class KeyboardInputTest < Minitest::Test
  FakeBackend = Struct.new(:down_keys) do
    def button_down?(key) = down_keys.include?(key)
  end

  def test_maps_actions_through_bindings
    backend = FakeBackend.new([42])
    input = Core::KeyboardInput.new(backend:, bindings: { left: [41, 42], attack: [7] })
    assert input.down?(:left)
    refute input.down?(:attack)
    refute input.down?(:unbound)
  end
end
