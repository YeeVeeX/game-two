require_relative "../test_helper"
require "game/crossing"

# T5 (P9) unit lane: the level fact-gate in Crossing, callable-fed — the
# defeats seam verbatim (ctor-injected live reader, one sibling row in
# open?, AND composition) plus the unmet_level reason-reader (group_wait
# returned-cue contract: Crossing RETURNS the datum, World writes).
class CrossingTest < Minitest::Test
  def crossing(level: 1, breached: false, defeats: 0)
    Game::Crossing.new(zones: {},
                       breached: ->(_zone, _tile) { breached },
                       defeats: -> { defeats },
                       level: -> { level },
                       living: -> { 3 })
  end

  GATE = { at: [2, 2], to: "next", spawn: [1, 1], requires_level: 2 }.freeze

  def test_open_false_below_the_required_level
    refute crossing(level: 1).open?("z", GATE)
  end

  def test_open_true_at_the_required_level
    assert crossing(level: 2).open?("z", GATE)
  end

  def test_open_true_above_the_required_level
    assert crossing(level: 9).open?("z", GATE)
  end

  def test_open_reads_the_callable_live
    level = 1
    c = Game::Crossing.new(zones: {}, breached: ->(_z, _t) { false },
                           defeats: -> { 0 }, level: -> { level },
                           living: -> { 3 })
    refute c.open?("z", GATE)
    level = 2
    assert c.open?("z", GATE), "the gate reads the LIVE level, never a snapshot"
  end

  def test_sealed_and_level_compose_as_and
    both = { at: [2, 2], to: "next", spawn: [1, 1], sealed: true, requires_level: 2 }
    refute crossing(level: 9, breached: false).open?("z", both),
           "an unpaid toll shuts the way regardless of level"
    refute crossing(level: 1, breached: true).open?("z", both),
           "a breached way stays shut below the required level"
    assert crossing(level: 2, breached: true).open?("z", both)
  end

  def test_defeats_and_level_compose_as_and
    both = { at: [2, 2], to: "next", spawn: [1, 1], requires_defeats: 1, requires_level: 2 }
    refute crossing(level: 2, defeats: 0).open?("z", both)
    refute crossing(level: 1, defeats: 1).open?("z", both)
    assert crossing(level: 2, defeats: 1).open?("z", both)
  end

  def test_unmet_level_returns_the_required_level_when_unmet
    assert_equal 2, crossing(level: 1).unmet_level(GATE)
  end

  def test_unmet_level_nil_when_met
    assert_nil crossing(level: 2).unmet_level(GATE)
  end

  def test_unmet_level_nil_when_the_key_is_absent
    assert_nil crossing(level: 1).unmet_level(at: [2, 2], to: "next", spawn: [1, 1])
  end

  def test_unmet_level_reports_even_on_a_sealed_way
    # D1 pin: naming the level requirement is true information even on a
    # way that is ALSO sealed — the reader reports its own fact.
    both = { at: [2, 2], to: "next", spawn: [1, 1], sealed: true, requires_level: 4 }
    assert_equal 4, crossing(level: 1, breached: false).unmet_level(both)
  end
end
