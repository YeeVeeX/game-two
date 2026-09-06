require_relative "../test_helper"
require "core/data_store"
require "game/world"
require "app/renderer"
require "app/minimap"

# v22 E3 b4 (T0 finding b4 / d12): the radar paints a way by the SAME
# predicate the floor signage and the exit arrows read (Renderer.way_locked?)
# — gold means WALKABLE (exit_signage law): OPEN way = the zone's transition
# gold, LOCKED way (level / seal / boss fact) = minimap_way_locked_rgb. The
# decision is pure (Minimap#way_color) and the baked zone image is keyed by
# (map, locked tiles) so a level-up / breach repaints once. Headless: no
# Gosu draw is exercised; real zones carry the locks (dungeon_1 requires_level
# 8, basement_2 a sealed way + a free rope_spot).
class MinimapTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  DISPLAY = DATA["display"]
  LOCKED = DISPLAY[:minimap_way_locked_rgb]

  def minimap = App::Minimap.new(display: DISPLAY, kit_body: App::Renderer::KIT_BODY)

  def world(zone) = Game::World.new(DATA, seed: 3).tap { |w| w.start_in(zone) }

  def ways(zone) = DATA["zones/#{zone}"][:transitions]

  def test_level_locked_way_is_grey_and_opens_at_the_required_level
    w = world("dungeon_1")
    m = minimap
    locked = ways("dungeon_1").find { |t| t[:requires_level] }
    free = ways("dungeon_1").find { |t| !t[:requires_level] }
    gold = w.map.palette[:transition]
    assert_operator w.progression.level, :<, locked[:requires_level], "fixture: the pack starts under the lock"
    assert_equal LOCKED, m.way_color(w.map, w, *locked[:at])
    assert_equal gold, m.way_color(w.map, w, *free[:at])
    w.progression.load_progress!(level: locked[:requires_level], xp: 0)
    assert_equal gold, m.way_color(w.map, w, *locked[:at]), "at the required level the way is walkable = gold"
  end

  def test_sealed_way_is_grey_until_breached_and_the_rope_spot_is_gold
    w = world("basement_2")
    m = minimap
    sealed = ways("basement_2").find { |t| t[:sealed] }
    rope = ways("basement_2").find { |t| t[:type] == "rope_spot" }
    assert_equal LOCKED, m.way_color(w.map, w, *sealed[:at])
    assert_equal w.map.palette[:transition], m.way_color(w.map, w, *rope[:at])
    w.restore_breach!("basement_2", sealed[:at])
    assert_equal w.map.palette[:transition], m.way_color(w.map, w, *sealed[:at])
  end

  def test_non_way_tiles_have_no_way_color
    w = world("nest")
    m = minimap
    bank = DATA["zones/nest"][:stations].find { |s| s[:type] == "bank" }
    assert_nil m.way_color(w.map, w, *bank[:at])
    assert_nil m.way_color(w.map, w, 1, 1)
  end

  def test_locked_and_open_colors_are_distinct_and_the_predicate_is_the_renderers
    w = world("dungeon_1")
    refute_equal LOCKED, w.map.palette[:transition]
    refute_equal LOCKED, DISPLAY[:minimap_way_open_rgb]
    m = minimap
    w.map.transitions.each do |t|
      expect = App::Renderer.way_locked?(w, w.zone_name, t) ? LOCKED : w.map.palette[:transition]
      assert_equal expect, m.way_color(w.map, w, *t[:at]), "way #{t[:at]} disagrees with Renderer.way_locked?"
    end
  end

  def test_zone_image_cache_is_keyed_by_the_lock_facts
    w = world("dungeon_1")
    m = minimap
    locked = ways("dungeon_1").find { |t| t[:requires_level] }
    before = m.locked_ways(w.map, w)
    assert_includes before, locked[:at]
    w.progression.load_progress!(level: locked[:requires_level], xp: 0)
    refute_equal before, m.locked_ways(w.map, w), "a level-up changes the image key (repaint once)"
  end
end
