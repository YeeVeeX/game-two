require_relative "../test_helper"
require "core/counting_rng"

# Value transparency is the whole contract (panel fold, spec decision 6):
# the wrapped stream must return EXACTLY the naked stream's values — the
# wall stays untouched by construction — while draws counts every call.
class CountingRngTest < Minitest::Test
  def test_rand_returns_the_naked_streams_values_for_every_arity
    naked = Random.new(99)
    counted = Core::CountingRng.new(Random.new(99))
    20.times { assert_equal naked.rand(1000), counted.rand(1000) }
    5.times { assert_equal naked.rand, counted.rand }
    5.times { assert_equal naked.rand(3..17), counted.rand(3..17) }
    5.times { assert_equal naked.rand(2.5), counted.rand(2.5) }
  end

  def test_draws_counts_every_call
    rng = Core::CountingRng.new(Random.new(1))
    assert_equal 0, rng.draws
    7.times { rng.rand(10) }
    rng.rand
    assert_equal 8, rng.draws
  end
end
