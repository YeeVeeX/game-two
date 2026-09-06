require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "core/binding_map"
require "core/input"
require "game/world"
require "app/renderer"
require "app/key_table"

# v22 E3 b3 (T0 finding b3): the INTERACT prompt appears IFF `World#interact`
# would do something on the possessed's OWN tile — a station type that
# `interact_station` dispatches (bank/altar/vat/seal) or a `rope_spot` way
# (`interact_rope`). Beside a station H does nothing (no prompt); a totem is
# the dispatch's deliberate no-op (no prompt). Decision extracted to pure
# methods (`Renderer.interact_verb`, `Renderer#interact_prompt_for`); the
# draw is Gosu-only. The sim is never touched — the map is the single truth
# this mirrors (world.rb interact / interact_station / interact_rope).
class InteractPromptTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def renderer(bindings: Core::BindingMap.load(DATA, key_table: App::KEY_TABLE, local: false))
    App::Renderer.new(display: DATA["display"], strings: Core::Strings.new(DATA, locale: "en"), bindings:)
  end

  def map(zone) = Core::TileMap.new(DATA["zones/#{zone}"])

  def station(zone, type) = DATA["zones/#{zone}"][:stations].find { |s| s[:type] == type }[:at]

  def test_verb_on_every_dispatched_station_type_on_the_own_tile
    nest = map("nest")
    assert_equal "bank", App::Renderer.interact_verb(nest, station("nest", "bank"))
    assert_equal "altar", App::Renderer.interact_verb(nest, station("nest", "altar"))
    assert_equal "vat", App::Renderer.interact_verb(nest, station("nest", "vat"))
    assert_equal "seal", App::Renderer.interact_verb(map("basement_2"), station("basement_2", "seal"))
  end

  def test_no_verb_beside_a_station
    nest = map("nest")
    bx, by = station("nest", "bank")
    [[1, 0], [-1, 0], [0, 1], [0, -1]].each do |dx, dy|
      assert_nil App::Renderer.interact_verb(nest, [bx + dx, by + dy]), "adjacent (#{dx},#{dy}) must not prompt"
    end
  end

  def test_totem_is_the_dispatch_no_op_and_never_prompts
    assert_nil App::Renderer.interact_verb(map("district"), station("district", "totem"))
  end

  def test_rope_spot_is_an_interact_and_prompts
    b2 = map("basement_2")
    rope = DATA["zones/basement_2"][:transitions].find { |t| t[:type] == "rope_spot" }
    assert_equal "rope_spot", App::Renderer.interact_verb(b2, rope[:at])
    stairs = DATA["zones/basement_2"][:transitions].find { |t| t[:type] == "stairs_up" }
    assert_nil App::Renderer.interact_verb(b2, stairs[:at]), "a rest-on-tile way is not an interact"
  end

  def test_empty_tile_has_no_verb
    assert_nil App::Renderer.interact_verb(map("nest"), [2, 2])
  end

  def test_prompt_for_reads_the_real_world_and_the_bound_glyph
    w = Game::World.new(DATA, seed: 7)
    r = renderer
    me = w.possessed
    assert_nil r.interact_prompt_for(w), "spawn tile: no verb, no prompt"
    me.walker.teleport(*station("nest", "bank"))
    glyph = Core::BindingMap.load(DATA, key_table: App::KEY_TABLE, local: false).glyphs(:interact).first
    assert_equal({ verb: "bank", key: glyph }, r.interact_prompt_for(w))
    bare = App::Renderer.new(display: DATA["display"])
    assert_equal({ verb: "bank", key: "H" }, bare.interact_prompt_for(w), "bindings-less construct falls back to H")
  end

  def test_prompt_respects_the_display_switch_and_a_dead_body
    w = Game::World.new(DATA, seed: 7)
    w.possessed.walker.teleport(*station("nest", "bank"))
    off = App::Renderer.new(display: DATA["display"].merge(interact_prompt: false))
    assert_nil off.interact_prompt_for(w)
    r = renderer
    assert r.interact_prompt_for(w)
    w.possessed.load_hp!(0)
    assert_nil r.interact_prompt_for(w), "a dead body has no verb"
  end
end
