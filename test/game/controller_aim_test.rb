require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Owner order 2026-08-20 (ear-check session, verbatim): "el movimiento de
# facing estacionario con ctrl+direccionales para poder apuntar bien los
# ataques con presición sin avanzar". Held :aim turns direction keys into
# pure facing — the body points, never steps. Everything else (attack from
# the new facing, dodge direction, seizure re-aim) rides the existing paths.
class ControllerAimTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  Held = Struct.new(:actions) do
    def down?(action) = actions.include?(action)
    def update(_frame) = nil
  end

  def drive(w, n, inputs:)
    n.times { w.tick(inputs) }
  end

  def test_aim_plus_direction_faces_without_stepping
    w = Game::World.new(DATA, seed: 7)
    body = w.possessed
    t0 = body.tile.dup
    body.face([0, 1]) # start facing down
    drive(w, 6, inputs: Held.new([:aim, :right]))
    assert_equal [1, 0], body.facing, "aim+right must turn the body right"
    assert_equal t0, body.tile, "aim held: the body must NOT advance"
    refute body.walker.moving?, "no tween may start under aim"
  end

  def test_direction_without_aim_still_walks
    w = Game::World.new(DATA, seed: 7)
    body = w.possessed
    t0 = body.tile.dup
    drive(w, 12, inputs: Held.new([:right]))
    refute_equal t0, body.tile, "plain direction keeps walking (regression pin)"
  end

  def test_attack_fires_from_the_aimed_facing
    w = Game::World.new(DATA, seed: 7)
    body = w.possessed
    body.face([0, 1])
    drive(w, 4, inputs: Held.new([:aim, :left]))
    assert_equal [-1, 0], body.facing
    drive(w, 2, inputs: Held.new([:aim, :left, :attack]))
    assert_includes %i[windup active], body.attack_state,
                    "attack starts while aiming"
    assert_equal [-1, 0], body.facing, "the swing keeps the aimed facing"
  end

  def test_aim_alone_changes_nothing
    w = Game::World.new(DATA, seed: 7)
    body = w.possessed
    body.face([0, 1])
    t0 = body.tile.dup
    drive(w, 6, inputs: Held.new([:aim]))
    assert_equal [0, 1], body.facing, "aim with no direction holds the last facing"
    assert_equal t0, body.tile
  end

  def test_bindings_carry_the_aim_action
    require "core/binding_map"
    require "app/key_table"
    map = Core::BindingMap.load(DATA, key_table: App::KEY_TABLE, local: false)
    assert_equal %w[LCtrl RCtrl], map.glyphs(:aim),
                 "data/bindings.json carries the aim row (ctrl family)"
  end
end
