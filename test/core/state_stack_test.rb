require_relative "../test_helper"
require "core/state_stack"

class StateStackTest < Minitest::Test
  TRANSITIONS = {
    boot: %i[arena],
    arena: %i[death],
    death: %i[arena]
  }.freeze

  def setup
    @stack = Core::StateStack.new(initial: :boot, transitions: TRANSITIONS)
  end

  def test_valid_transition
    @stack.transition_to(:arena)
    assert_equal :arena, @stack.current
    assert_equal :boot, @stack.previous
  end

  def test_invalid_transition_raises
    assert_raises(Core::StateStack::InvalidTransition) { @stack.transition_to(:death) }
    assert_equal :boot, @stack.current
  end

  def test_overlay_push_pop
    @stack.transition_to(:arena)
    @stack.push(:pause)
    assert_equal :pause, @stack.current
    assert @stack.overlay?
    assert_equal :arena, @stack.base
    @stack.pop
    assert_equal :arena, @stack.current
    refute @stack.overlay?
  end

  def test_hard_transition_validates_against_base_and_clears_overlays
    @stack.transition_to(:arena)
    @stack.push(:pause)
    @stack.transition_to(:death)
    assert_equal :death, @stack.current
    assert_equal 1, @stack.depth
  end

  def test_pop_never_removes_base
    @stack.pop
    assert_equal :boot, @stack.current
    assert_equal 1, @stack.depth
  end
end
