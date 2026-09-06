require_relative "../test_helper"
require_relative "../support/schema3_facts"
require "core/data_store"
require "core/input"
require "game/world"

# T4 typed-transition behaviors (world-builder D3/D4 + §THE GATE), through
# a REAL World over fixture ZONE DATA (the store below is a data fixture,
# not a mock — World, TileMap, TileRegistry, Pack all live). Laws pinned:
# rope spots never auto-fire and climb via the free interact under the
# gate-group consent law; holes/stairs keep the rest-on-tile law; sealed
# holes open through the EXISTING toll machinery (breached family, D11);
# requires_defeats reads the persisted boss counter (fact, not price).
class TypedTransitionsTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  # Data fixture: the real store plus injected pilot-shaped mini zones.
  # Store contract = [] + keys (DataStore's own surface).
  class FixtureStore
    def initialize(base, extra)
      @base = base
      @extra = extra
    end

    def [](key) = @extra.key?(key) ? @extra[key] : @base[key]
    def keys = (@base.keys + @extra.keys).uniq.sort
  end

  UPPER = {
    name: "upper", display_name: "UPPER", tile_size: 32,
    palette: { floor: [10, 10, 10], grid: [12, 12, 12], wall: [90, 90, 90],
               transition: [235, 190, 90], water: [30, 60, 90],
               water_drained: [50, 44, 30] },
    tiles: [
      "########",
      "#......#",
      "#.~~~..#",
      "#.~~~..#",
      "#.~~~..#",
      "#......#",
      "########"
    ],
    pack_spawn: [[1, 1], [2, 1], [3, 1]],
    enemy_spawns: {},
    stations: [
      { type: "seal", at: [1, 3], price: "breach_cost", opens: [3, 3], line: "TOLL PAID" }
    ],
    transitions: [
      { at: [3, 3], to: "lower", spawn: [2, 2], sealed: true, type: "hole" },
      { at: [5, 5], to: "lower", spawn: [1, 1], requires_defeats: 1 }
    ],
    water_drained_by: [3, 3]
  }.freeze

  LOWER = {
    name: "lower", display_name: "LOWER", tile_size: 32, floor: -1,
    palette: { floor: [8, 8, 8], grid: [10, 10, 10], wall: [80, 80, 80],
               transition: [235, 190, 90] },
    tiles: [
      "########",
      "#......#",
      "#......#",
      "#......#",
      "########"
    ],
    pack_spawn: [[1, 1], [2, 1], [3, 1]],
    enemy_spawns: {},
    stations: [],
    transitions: [
      { at: [5, 2], to: "upper", spawn: [5, 1], type: "rope_spot" },
      { at: [6, 1], to: "upper", spawn: [5, 1], type: "stairs_up" }
    ]
  }.freeze

  def store
    FixtureStore.new(DATA, "zones/upper" => Marshal.load(Marshal.dump(UPPER)),
                           "zones/lower" => Marshal.load(Marshal.dump(LOWER)))
  end

  def world(seats: 1, save: nil)
    w = Game::World.new(store, seats:, save:)
    w.start_in("upper") unless save
    w
  end

  def drive(w, n = 2)
    input = Core::ScriptedInput.new(frames: {})
    n.times do
      input.update(w.frame)
      w.tick(input)
    end
  end

  def park_allies_adjacent(w, tile)
    (w.pack.living - [w.possessed]).each_with_index do |m, i|
      m.walker.teleport(tile[0], tile[1] - 1 - i)
    end
  end

  # --- the well: sealed hole through the EXISTING toll machinery --------

  def test_sealed_hole_does_not_fire_until_the_toll_is_paid
    w = world
    w.possessed.walker.teleport(3, 3)
    park_allies_adjacent(w, [3, 3])
    drive(w)
    assert_equal "upper", w.zone_name, "a sealed hole is not a gate until breached"

    w.pack.bank!(DATA["balance/economy"][:breach_cost])
    w.possessed.walker.teleport(1, 3)
    assert w.interact(w.possessed), "the toll pays at the seal station"
    assert w.breached?("upper", [3, 3]), "the drain persists as a breached tuple (D11)"

    w.possessed.walker.teleport(3, 3)
    park_allies_adjacent(w, [3, 3])
    # The breach fires the strongest feel kick — drive past the hitstop
    # window (the seal_breach_test slack law) before expecting the fall.
    drive(w, DATA["balance/combat"][:feel][:hitstop_frames_kill] + 6)
    assert_equal "lower", w.zone_name, "falling commits after the breach"
    assert_equal [2, 2], w.possessed.tile, "the hole lands on its declared spawn"
  end

  def test_walking_the_water_ring_never_transitions
    w = world
    w.possessed.walker.teleport(2, 2) # water tile beside the hole
    drive(w)
    assert_equal "upper", w.zone_name, "water is walkable decor; only the hole tile is a way"
  end

  # --- rope spots: interact, never auto-fire ----------------------------

  def test_rope_spot_never_fires_on_rest
    w = world
    w.start_in("lower")
    w.possessed.walker.teleport(5, 2)
    park_allies_adjacent(w, [5, 2])
    drive(w, 30)
    assert_equal "lower", w.zone_name, "resting on a rope spot must not teleport (D4)"
  end

  def test_rope_spot_interacts_back_up
    w = world
    w.start_in("lower")
    w.possessed.walker.teleport(5, 2)
    park_allies_adjacent(w, [5, 2])
    assert w.interact(w.possessed), "the climb is a free interact"
    assert_equal "upper", w.zone_name
    assert_equal [5, 1], w.possessed.tile, "the rope lands on its declared spawn"
  end

  def test_rope_climb_respects_gate_group_consent
    w = world(seats: 2)
    w.start_in("lower")
    a = w.possessed(1)
    b = w.possessed(2)
    a.walker.teleport(5, 2)
    b.walker.teleport(1, 3) # far: consent by co-location fails
    refute w.interact(a), "a lone climber cannot strand the partner"
    assert_equal "lower", w.zone_name
    assert_equal [5, 2], w.gate_wait, "the blocked climb IS the waiting cue"
    b.walker.teleport(5, 1) # Chebyshev 1 of the rope tile
    assert w.interact(a)
    assert_equal "upper", w.zone_name
  end

  def test_stairs_stay_ordinary_two_way_gates
    w = world
    w.start_in("lower")
    w.possessed.walker.teleport(6, 1)
    park_allies_adjacent(w, [6, 1])
    drive(w)
    assert_equal "upper", w.zone_name, "stairs fire on rest like any gate (D3)"
  end

  # --- the boss gate: a fact, not a price (spec §THE GATE) ---------------

  def boss_facts(defeats)
    Schema3Facts.facts(DATA["balance/combat"][:pack][:members], defeats:, home: "upper", hp: 1)
  end

  def test_requires_defeats_blocks_while_the_counter_is_unmet
    w = world(save: boss_facts(0))
    w.possessed.walker.teleport(5, 5)
    park_allies_adjacent(w, [5, 5])
    drive(w)
    assert_equal "upper", w.zone_name, "the gate stays shut at boss_1_defeats=0"
  end

  def test_requires_defeats_opens_on_the_persisted_fact
    w = world(save: boss_facts(1))
    w.possessed.walker.teleport(5, 5)
    park_allies_adjacent(w, [5, 5])
    drive(w)
    assert_equal "lower", w.zone_name, "the persisted defeat opens the way"
  end
end
