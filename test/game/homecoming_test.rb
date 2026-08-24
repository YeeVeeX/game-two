require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# J7-B (brief D4): the cold catch-up math — linger-then-walk on EXISTING
# knobs (leash_linger_frames + kit step_frames), pure and RNG-free.
# Placements come from Homecoming#catchup_placements; the World applies
# them at stamped re-entry (integration lanes: threat_leash_test).
class HomecomingTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  THREAT = DATA["balance/threat"]
  COMBAT = DATA["balance/combat"]
  LINGER = THREAT[:leash_linger_frames]
  RUSHER_STEP = COMBAT[:kits][:rusher][:step_frames]

  def scripted(frames) = Core::ScriptedInput.new(frames:)
  def idle = scripted({})

  def drive(world, n, input: idle)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def world(seed: 5)
    w = Game::World.new(DATA, seed:)
    w.start_in("district")
    w
  end

  def make_human(w, kit_name, tile, name: nil)
    kit = COMBAT[:kits].fetch(kit_name.to_sym)
    Game::Creature.new(bus: w.bus, kit:, kit_name: kit_name.to_sym,
                       map: w.map, tile:, faction: :human,
                       name: name || "test_#{kit_name}_#{tile.join('_')}")
  end

  # A district world with ONLY our staged rusher: home on a clear row,
  # frozen 4 straight tiles east of it (the flow-home walk is the west ray).
  HOME = [10, 5].freeze
  FROZEN = [14, 5].freeze

  def staged(seed: 5)
    w = world(seed:)
    w.humans.clear
    h = make_human(w, :rusher, HOME)
    h.walker.teleport(*FROZEN)
    w.humans << h
    [w, h]
  end

  def placements(w, elapsed)
    w.instance_variable_get(:@homecoming)
     .catchup_placements(w.humans, elapsed:)
  end

  # --- linger edge -------------------------------------------------------

  def test_elapsed_at_or_under_the_linger_moves_nobody
    w, h = staged
    [0, 1, LINGER - 1, LINGER].each do |elapsed|
      assert_equal FROZEN, placements(w, elapsed).fetch(h),
                   "elapsed=#{elapsed} must hold the frozen tile (linger spent first)"
    end
  end

  def test_first_step_lands_exactly_one_kit_step_past_the_linger
    w, h = staged
    just_short = LINGER + RUSHER_STEP - 1
    assert_equal FROZEN, placements(w, just_short).fetch(h),
                 "a partial step is no step (integer division)"
    assert_equal [13, 5], placements(w, LINGER + RUSHER_STEP).fetch(h)
  end

  # --- integer division --------------------------------------------------

  def test_tiles_advance_by_whole_kit_steps_only
    w, h = staged
    two_and_a_half = LINGER + (RUSHER_STEP * 5) / 2
    assert_equal [12, 5], placements(w, two_and_a_half).fetch(h),
                 "2.5 steps of walk_ticks advance exactly 2 tiles"
  end

  # --- clamp at home -----------------------------------------------------

  def test_a_long_absence_clamps_at_home_never_past_it
    w, h = staged
    assert_equal HOME, placements(w, LINGER + RUSHER_STEP * 400).fetch(h)
  end

  # --- stacking tie-break --------------------------------------------------

  def test_contested_tile_holds_one_step_short_in_roster_order
    w, first = staged
    second = make_human(w, :rusher, HOME, name: "test_rusher_second")
    second.walker.teleport(FROZEN[0] + 1, FROZEN[1]) # same row, one further out
    w.humans << second
    placed = placements(w, LINGER + RUSHER_STEP * 400)
    assert_equal HOME, placed.fetch(first), "roster order: first claims home"
    assert_equal [HOME[0] + 1, HOME[1]], placed.fetch(second),
                 "second holds one flow-step short of the contested home tile"
  end

  # --- dead and at-home humans get no placement --------------------------

  def test_dead_and_at_home_humans_are_skipped
    w, displaced = staged
    settled = make_human(w, :rusher, [20, 6], name: "test_rusher_home")
    corpse = make_human(w, :rusher, [24, 12], name: "test_rusher_dead")
    corpse.walker.teleport(26, 12)
    corpse.take_hit(damage: corpse.hp, attacker: w.possessed)
    w.humans << settled << corpse
    placed = placements(w, LINGER + RUSHER_STEP * 10)
    assert placed.key?(displaced)
    refute placed.key?(settled), "at-home humans have no catch-up entry"
    refute placed.key?(corpse), "dead humans stay where they fell"
  end

  # --- pure: zero rng ----------------------------------------------------

  def test_catchup_placements_draw_zero_rng
    w, _h = staged
    before = [w.rng.draws, w.respawn_rng.draws]
    placements(w, LINGER + RUSHER_STEP * 7)
    assert_equal before, [w.rng.draws, w.respawn_rng.draws],
                 "the catch-up must be RNG-free (D4)"
  end
end
