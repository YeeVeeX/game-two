require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# MUNDO VIVO FASE 4.2 — `petrify`: a LONG, telegraphed windup whose hit
# staggers the victim for a long window (the serpent family's signature).
# Data-only on the sim side (stagger_frames already flows through
# apply_action_hit; `petrify: true` is the renderer's read flag). Boot+
# combat proof on a real World before any zone places the kind.
class PetrifyTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  KIT = DATA["balance/combat"][:kits][:serpent_b]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def stage!
    world.start_in("grass_fixture")
    body = world.possessed
    (world.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    body.walker.teleport(6, 6)
    world.send(:add_human, "grass_fixture", :serpent_b, [7, 6]) # adjacent: melee arc3
  end

  def test_kit_shape_is_a_petrifier
    a = KIT[:attack]
    assert a[:petrify], "renderer read flag"
    assert_operator a[:windup_frames], :>=, 40, "petrify is LONG-telegraphed (dodgeable by design)"
    assert_operator a[:stagger_frames], :>=, 60, "the freeze is the payload, not the damage"
    assert_operator a[:damage], :<, DATA["balance/combat"][:kits][:warden][:attack][:damage],
                    "hits softer than the medusa elite — control, not burst"
    xp = DATA["balance/progression"][:kill_xp]
    assert xp[:serpent_a] < xp[:serpent_b] && xp[:serpent_b] < xp[:warden], "L6 gradient inside the family"
  end

  def test_the_hit_freezes_the_victim_for_the_stagger_window
    caster = stage!
    body = world.possessed
    drive(world, scripted({}), KIT[:attack][:windup_frames] + KIT[:attack][:active_frames] + 2)
    assert body.staggered?, "landed petrify = staggered victim"
    assert_operator body.stagger, :>=, KIT[:attack][:stagger_frames] - (KIT[:attack][:active_frames] + 2)
    assert caster.faction == :human
    # frozen: a move press does nothing while staggered
    tile0 = body.tile
    drive(world, scripted((0..10).to_h { |f| [world.frame + f, [:left]] }), 10)
    assert_equal tile0, body.tile, "petrified bodies cannot step"
  end

  def test_the_windup_is_readable_as_petrify_before_it_lands
    caster = stage!
    drive(world, scripted({}), 6)
    assert caster.telegraphing?, "long windup: the tell is visible for frames before the freeze"
    assert caster.action_config[:petrify], "the renderer switches to the stone telegraph on this flag"
  end
end
