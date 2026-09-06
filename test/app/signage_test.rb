require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "core/binding_map"
require "core/input"
require "game/world"
require "app/renderer"
require "app/key_table"

# Lane `signage` commit 1: the SIGNAGE block (interact verb/prompt, the way
# lock predicate, way breath, exit arrows, pressure outline) moved from
# renderer.rb into the App::Signage mixin BYTE-INERT. This test pins the
# wiring: the module exists, Renderer mixes it in, the three public names
# every caller uses (minimap.rb, map_artifact.rb, interact_prompt_test.rb)
# still answer on App::Renderer, the draws stay private, and `way_locked?`
# gets its own direct pure test on a real zone with `requires_level`
# (before this it was proven only indirectly through minimap_test).
class SignageTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def renderer
    App::Renderer.new(display: DATA["display"], strings: Core::Strings.new(DATA, locale: "en"),
                      bindings: Core::BindingMap.load(DATA, key_table: App::KEY_TABLE, local: false))
  end

  def world(zone) = Game::World.new(DATA, seed: 3).tap { |w| w.start_in(zone) }

  def ways(zone) = DATA["zones/#{zone}"][:transitions]

  def test_module_exists_and_is_mixed_into_the_renderer
    assert_kind_of Module, App::Signage
    assert_includes App::Renderer.ancestors, App::Signage
    assert_includes App::Renderer.singleton_class.ancestors, App::Signage::ClassMethods
    assert_equal %w[bank altar vat seal], App::Signage::INTERACT_STATIONS
    assert_same App::Signage::INTERACT_STATIONS, App::Renderer::INTERACT_STATIONS
  end

  def test_the_three_public_names_answer_exactly_as_before
    assert_respond_to App::Renderer, :interact_verb
    assert_respond_to App::Renderer, :way_locked?
    r = renderer
    assert_respond_to r, :interact_prompt_for
    assert_equal 2, App::Renderer.method(:interact_verb).arity
    assert_equal 3, App::Renderer.method(:way_locked?).arity
    assert_equal(-2, r.method(:interact_prompt_for).arity)
    # a caller with an explicit receiver (minimap.rb) still resolves
    w = world("nest")
    assert_equal "bank", App::Renderer.interact_verb(w.map, w.map.stations.find { |s| s[:type] == "bank" }[:at])
    assert_nil r.interact_prompt_for(w), "spawn tile: no verb, no prompt"
  end

  def test_the_draws_stay_private_on_the_renderer
    r = renderer
    %i[draw_way_breath draw_pressure_outline draw_exit_arrows draw_interact_prompt].each do |m|
      assert r.respond_to?(m, true), "#{m} must exist on the renderer"
      refute r.respond_to?(m), "#{m} must stay private (it was private before the extraction)"
    end
  end

  # Wall #4 (brasa3_run aura_ring_reads): the aura square's alpha falls off
  # with distance to the possessed; pure, so it is pinned here without Gosu.
  def test_aura_alpha_falls_off_with_distance_and_every_knob_is_a_display_row
    pct = ->(d) { App::Signage.aura_alpha_pct(d, near: 5, far: 12, far_pct: 0.5) }
    assert_equal 1.0, pct.call(0)
    assert_equal 1.0, pct.call(5), "full alpha up to `near`"
    assert_in_delta 0.75, pct.call(8.5), 1e-9, "linear between near and far"
    assert_equal 0.5, pct.call(12), "far_pct at `far`"
    assert_equal 0.5, pct.call(40), "never below far_pct: far squares stay visible, secondary"
    assert_equal 0.5, App::Signage.aura_alpha_pct(9, near: 12, far: 5, far_pct: 0.5), "degenerate far <= near -> far_pct"
    display = Core::DataStore.new(File.expand_path("../../data", __dir__))["display"]
    %i[aura_rgb aura_alpha_max aura_fill_alpha_max aura_line_px aura_contour_rgb aura_contour_alpha
       aura_near_tiles aura_far_tiles aura_far_alpha_pct].each { |k| assert display.key?(k), "display.json lacks #{k}" }
    assert_operator display[:aura_fill_alpha_max], :<, 64, "the fill stays translucent: the square never 'fills in' (gate row)"
    assert_operator display[:low_hp_band_w_pct], :<, 0.22, "the low-hp pulse is an EDGE bleed: narrower than the base vignette"
    assert_operator display[:low_hp_band_h_pct], :<, 0.28, "the low-hp pulse is an EDGE bleed: narrower than the base vignette"
    assert display[:low_hp_alpha_floor].between?(0, 1) && display[:low_hp_breath_floor].between?(0, 1), "floors are fractions"
    assert_operator display[:aura_bearer_dot_px], :<=, 8, "the bearer dot is a hint under the body, not a marker over it"
    assert_includes App::Renderer.private_instance_methods, :draw_aura, "draw_aura lives in Signage, private on the Renderer"
  end

  def test_way_locked_by_requires_level_opens_at_the_level
    w = world("dungeon_1")
    locked = ways("dungeon_1").find { |t| t[:requires_level] }
    free = ways("dungeon_1").find { |t| !t[:requires_level] && !t[:sealed] && !t[:requires_defeats] }
    assert locked && free, "dungeon_1 must carry one level-locked and one free way"
    assert w.progression.level < locked[:requires_level]
    assert App::Renderer.way_locked?(w, w.zone_name, locked)
    refute App::Renderer.way_locked?(w, w.zone_name, free)
    w.progression.load_progress!(level: locked[:requires_level], xp: 0)
    refute App::Renderer.way_locked?(w, w.zone_name, locked), "at the required level the way is walkable"
  end

  def test_way_locked_by_seal_and_by_boss_fact
    sealed = { at: [1, 1], sealed: true }
    w = world("basement_2")
    assert App::Renderer.way_locked?(w, w.zone_name, sealed)
    w.restore_breach!(w.zone_name, [1, 1])
    refute App::Renderer.way_locked?(w, w.zone_name, sealed), "a breached seal is walkable"
    fact = { at: [2, 2], requires_defeats: w.boss_1_defeats + 1 }
    assert App::Renderer.way_locked?(w, w.zone_name, fact)
    plain = { at: [3, 3] }
    assert_equal false, App::Renderer.way_locked?(w, w.zone_name, plain), "no lock key => false, never nil"
  end
end
