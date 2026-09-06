require_relative "../test_helper"
require "core/data_store"
require "core/event_bus"
require "core/tile_map"
require "game/world"

# A3 ranged-hold STALEMATE rule (drafts/_a3-ally-brain-audit-20260905.md §4,
# candidate (a); lane a3-stalemate): a projectile ally whose focused target
# has stood on the same tile for `ally.stalemate_frames` ticks OUT of the
# ally's attack range closes the gap by one step, never under
# `ranged_hold_tiles - stalemate_advance_tiles` (floored at 2). SYNTHETIC
# scenario, headless: real Creatures + real TileMap/FlowField behind the
# AiController view duck-type (threat_targeting_test pattern). The brain is
# switched ON in THIS file's cfg only — data/balance/threat.json keeps
# `enabled: false` (canary law).
#
# Geometry: open room, ember standing at [5,3], lobber at [2,3] = Chebyshev 3
# (= hold). A range-1 copy of the lobber kit (in memory; combat.json is not
# touched) makes the target unreachable from the hold band — the pocket the
# audit names. Old rule: align_step picks the FARTHEST aligned neighbor, so
# the ally wiggles [2,3] <-> [1,3] forever (traced). Stall rule: at
# stalemate_frames it steps to [3,3] (dist 2 = floor) and holds.
class AllyStalemateTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  KITS = DATA["balance/combat"][:kits]
  SHORT_LOBBER = KITS[:lobber].merge(attack: KITS[:lobber][:attack].merge(range_tiles: 1)).freeze

  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["#########", "#.......#", "#.......#", "#.......#", "#.......#", "#.......#", "#########"],
    pack_spawn: [[1, 1], [2, 1], [3, 1]]
  )

  N = 5 # stall threshold for the test (data proposes 180 = 3 s; see receipt)
  ON = { enabled: true, focus_fire: true, finish_pct: 0.35, drink_pct: 0.45, dodge_telegraphs: true,
         use_specials: true, ranged_hold_tiles: 3, ring_min_adjacent: 1,
         stalemate_frames: N, stalemate_advance_tiles: 1 }.freeze
  OLD = ON.reject { |k, _| k == :stalemate_frames }.freeze # brain ON, rule absent = pre-lane behavior
  OFF = DATA["balance/threat"][:ally].freeze

  # The controller's view contract, minimal and real (no mocks: live
  # Creatures, live TileMap, live FlowField). line_clear? = World's ray.
  class View
    attr_reader :map, :threat_config, :possessed

    def initialize(map:, ally:, pack:, humans:)
      @map = map
      @threat_config = DATA["balance/threat"].merge(ally:)
      @pack = pack
      @humans = humans
      @possessed = pack.first
    end

    def hostiles_for(c) = c.faction == :pack ? @humans.reject(&:dead?) : @pack.reject(&:dead?)
    def blocked_for(c) = (@pack + @humans).reject { |a| a.equal?(c) }.flat_map { |a| [a.tile, a.reserved_tile] }.compact.uniq
    def controlled?(c) = c.equal?(@possessed)
    def controlled_bodies = [@possessed]

    def line_clear?(from, to)
      dx = (to[0] - from[0]).clamp(-1, 1)
      dy = (to[1] - from[1]).clamp(-1, 1)
      cx, cy = from
      loop do
        cx += dx
        cy += dy
        return true if [cx, cy] == to
        return false unless @map.passable?(cx, cy)
      end
    end

    def flow_to(anchor)
      @flow ||= {}
      e = (@flow[anchor] ||= { field: Game::FlowField.new(@map), tile: nil })
      if e[:tile] != anchor.tile
        e[:field].recompute!(anchor.tile)
        e[:tile] = anchor.tile
      end
      e[:field]
    end
  end

  def creature(kit, kit_name, tile, faction, name)
    Game::Creature.new(bus: Core::EventBus.new, kit:, kit_name:, map: MAP, tile:, faction:, name:)
  end

  def scenario(ally_cfg)
    blocker = creature(KITS[:blocker], :blocker, [1, 1], :pack, "blocker")
    lob = creature(SHORT_LOBBER, :lobber, [2, 3], :pack, "lobber")
    ember = creature(KITS[:ember_a], :ember_a, [5, 3], :human, "ember_a1")
    ember.provoke!
    view = View.new(map: MAP, ally: ally_cfg, pack: [blocker, lob], humans: [ember])
    [Game::AiController.new, lob, ember, view]
  end

  def cheb(a, b) = [(a.tile[0] - b.tile[0]).abs, (a.tile[1] - b.tile[1]).abs].max
  def stall(ai) = ai.instance_variable_get(:@stall)

  # One sim tick for the ally: the controller's decision, then the body clocks.
  def engage_tick(ai, lob, ember, view)
    ai.ally_engage(lob, ember, view, ai.ally_config(view))
    lob.tick_body
    ember.tick_body
    lob.tile
  end

  def test_data_carries_the_stalemate_keys_with_the_brain_off
    refute OFF[:enabled], "threat.json ships the brain OFF (canary law)"
    assert_equal 180, OFF[:stalemate_frames], "proposal: 3 s at 60 fps (owner's number)"
    assert_equal 1, OFF[:stalemate_advance_tiles]
  end

  # (i) target still for N ticks + out of range -> the ally steps ONE tile
  # toward it (the first free tick after the count reaches N) and holds.
  def test_stalled_out_of_range_target_pulls_the_ranged_ally_one_tile_closer
    ai, lob, ember, view = scenario(ON)
    refute ai.send(:in_attack_range?, lob, ember, view), "range 1 from the hold band: the target cannot be reached"
    trail = Array.new(70) { engage_tick(ai, lob, ember, view) }
    first = trail.index([3, 3])
    refute_nil first, "the ally advanced to [3,3]"
    assert_operator first, :>=, N, "never before the stall threshold"
    assert_operator trail.first(N).map { |t| (5 - t[0]).abs }.min, :>=, 3, "old hold band (>= 3) until the threshold"
    assert trail[first..].all? { |t| t == [3, 3] }, "and holds there (no wiggle back)"
    assert_equal 2, cheb(lob, ember), "floor = hold 3 - advance 1 = 2: a projectile kit never hugs its target"
  end

  # The same ticks WITHOUT the rule = the pre-lane wiggle (documents the pocket).
  def test_without_the_rule_the_ally_wiggles_in_the_hold_band_forever
    ai, lob, ember, view = scenario(OLD)
    trail = Array.new(70) { engage_tick(ai, lob, ember, view) }
    assert_equal [[1, 3], [2, 3]], trail.uniq.sort, "align_step ping-pong, never closer than 3"
    assert_nil stall(ai), "no stalemate_frames in cfg -> the rule is inert and allocates nothing"
  end

  # (ii) a target that keeps moving never stalls: decisions identical to the old rule.
  def test_moving_target_keeps_the_old_hold_behavior
    with_rule = scenario(ON)
    without = scenario(OLD)
    a = []
    b = []
    (N * 6).times do |i|
      [[with_rule, a], [without, b]].each do |(ai, lob, ember, view), log|
        ember.walker.teleport(5, 3 + (i % 2)) # a step every tick: never on the same tile twice
        log << engage_tick(ai, lob, ember, view)
      end
    end
    assert_equal b, a, "moving target: byte-identical tiles with and without the rule"
    assert_operator stall(with_rule[0])["lobber"][:frames], :<, N, "the count never reaches the threshold"
  end

  # A target step RESETS the count (it is a stall, not a timer).
  def test_target_step_resets_the_stall_count
    ai, lob, ember, view = scenario(ON)
    (N - 1).times { engage_tick(ai, lob, ember, view) }
    assert_equal N - 1, stall(ai)["lobber"][:frames]
    ember.walker.teleport(5, 4)
    engage_tick(ai, lob, ember, view)
    assert_equal 1, stall(ai)["lobber"][:frames], "count restarts on the tick the target moved"
  end

  # Review finding 1: stalled AT the floor but off the shot line -> the ally
  # still lines the shot up (align_step) instead of freezing; once aligned at
  # the floor it HOLDS (no wiggle back out).
  def test_stalled_at_the_floor_still_lines_the_shot_up
    ai, lob, ember, view = scenario(ON)
    lob.walker.teleport(3, 4) # dist 2 = floor, dx 2 / dy 1 = not aligned
    ai.instance_variable_set(:@stall, { "lobber" => { target: ember, tile: ember.tile, frames: N } })
    trail = Array.new(60) { engage_tick(ai, lob, ember, view) }
    refute_equal [[3, 4]], trail.uniq, "a stalled off-axis ally at the floor does not freeze"
    assert_equal [[2, 3], [3, 3]], trail.uniq, "align_step lines it up ([2,3]), the stall then closes to the floor ([3,3])"
    assert ai.send(:aligned?, lob, ember), "it ends on the shot line"
    assert trail.last(20).all? { |t| t == [3, 3] }, "and holds there"
  end

  # Review finding 2: disengaging (target out of aggro range -> follow branch)
  # drops the stall memory; a later re-acquire starts the count from scratch.
  def test_disengaging_clears_the_stall_count
    ai, lob, ember, view = scenario(ON)
    (N - 1).times { engage_tick(ai, lob, ember, view) }
    assert_equal N - 1, stall(ai)["lobber"][:frames]
    ember.clear_provocation! # C2: an unprovoked human is no target -> the free ally follows
    ai.tick(lob, view)
    assert_nil stall(ai)["lobber"], "no fight this tick -> no stall memory for this ally"
  end

  # Determinism: two controllers, same ticks -> same tiles and same memory.
  def test_same_ticks_same_stream
    x = scenario(ON)
    y = scenario(ON)
    trail_x = Array.new(40) { engage_tick(*x) }
    trail_y = Array.new(40) { engage_tick(*y) }
    assert_equal trail_x, trail_y
    assert_equal stall(x[0])["lobber"].except(:target), stall(y[0])["lobber"].except(:target)
  end

  # (iii) brain OFF (shipped data): ally_config is nil, the rule is unreachable,
  # no memory is allocated — the OFF path is untouched (canaries prove the bytes).
  def test_brain_off_never_reaches_the_rule
    ai, lob, ember, view = scenario(OFF)
    assert_nil ai.ally_config(view)
    40.times { ai.tick(lob, view); lob.tick_body; ember.tick_body }
    assert_nil stall(ai), "no stall memory on the OFF path"
  end
end
