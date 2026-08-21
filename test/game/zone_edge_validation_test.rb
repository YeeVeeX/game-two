require_relative "../test_helper"
require "core/data_store"
require "game/world"

# s31 edge-validation law (s30 gate-pin review, finding 6): every zone
# edge is validated at WORLD LOAD — an unknown destination zone, a
# malformed spawn, or an impassable spawn tile refuses NAMED at
# construction (message carries the full source/at/to/spawn tuple),
# never a crossing-time KeyError or a silent in-wall placement. Real
# World over fixture ZONE DATA (the store is a data fixture, not a
# mock); the REAL data/zones ride along in every construction here, so
# the live world passes this law by construction on every suite run.
class ZoneEdgeValidationTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  # Data fixture: the real store plus injected mini zones (the
  # typed_transitions idiom). Store contract = [] + keys.
  class FixtureStore
    def initialize(base, extra)
      @base = base
      @extra = extra
    end

    def [](key) = @extra.key?(key) ? @extra[key] : @base[key]
    def keys = (@base.keys + @extra.keys).uniq.sort
  end

  ZONE = {
    display_name: "EDGE", tile_size: 32,
    palette: { floor: [10, 10, 10], grid: [12, 12, 12], wall: [90, 90, 90],
               transition: [235, 190, 90] },
    tiles: [
      "#######",
      "#.....#",
      "#.....#",
      "#.....#",
      "#######"
    ],
    pack_spawn: [[1, 1], [2, 1], [3, 1]],
    enemy_spawns: {},
    stations: [],
    transitions: []
  }.freeze

  # A two-zone pair where edge_a carries the transition under test.
  # edge_b stays edge-free — the property under test is a's OUTBOUND pair.
  def world_with(transitions)
    a = Marshal.load(Marshal.dump(ZONE))
    a[:name] = "edge_a"
    a[:transitions] = transitions
    b = Marshal.load(Marshal.dump(ZONE))
    b[:name] = "edge_b"
    store = FixtureStore.new(DATA, "zones/edge_a" => a, "zones/edge_b" => b)
    Game::World.new(store)
  end

  def test_unknown_destination_zone_refuses_named_at_load
    err = assert_raises(ArgumentError) do
      world_with([{ at: [5, 3], to: "edge_zzz", spawn: [1, 1] }])
    end
    assert_match(/zone edge edge_a \[5, 3\] -> edge_zzz: unknown destination zone "edge_zzz"/,
                 err.message, "the refusal names the full edge tuple")
  end

  def test_impassable_spawn_refuses_named_at_load
    err = assert_raises(ArgumentError) do
      world_with([{ at: [5, 3], to: "edge_b", spawn: [0, 0] }])
    end
    assert_match(/zone edge edge_a \[5, 3\] -> edge_b: spawn \[0, 0\] impassable in edge_b/,
                 err.message, "a wall spawn refuses with the tuple, never ships a player in-wall")
  end

  def test_out_of_bounds_spawn_refuses_as_impassable
    err = assert_raises(ArgumentError) do
      world_with([{ at: [5, 3], to: "edge_b", spawn: [99, 1] }])
    end
    assert_match(/spawn \[99, 1\] impassable in edge_b/, err.message,
                 "out of bounds is impassable by the passable? boundary law")
  end

  def test_malformed_spawn_refuses_named_at_load
    err = assert_raises(ArgumentError) do
      world_with([{ at: [5, 3], to: "edge_b" }])
    end
    assert_match(/zone edge edge_a \[5, 3\] -> edge_b: spawn must be an \[x, y\] tile \(got nil\)/,
                 err.message, "an absent spawn refuses NAMED, not an arity crash")
  end

  def test_legal_edge_pair_constructs_clean
    w = world_with([{ at: [5, 3], to: "edge_b", spawn: [1, 1] }])
    w.start_in("edge_a")
    assert_equal "edge_a", w.zone_name, "a legal pair boots — validation is refusal-only"
  end
end
