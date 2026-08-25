require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "core/binding_map"
require "core/input"
require "app/key_table"
require "tmpdir"
require "app/menu"
require "app/prefs"

# J-6 ticket A lane 1 (brief drafts/_j6-menu-brief-20260823.md): the menu
# machine's pure state resolution + the route contract the wall-debt audit
# leans on (closed -> the SAME input object; open -> NullInput). Driven by
# REAL Core::ScriptedInput — the exact source the Rule 2 reel uses, so the
# edge semantics tested here are the edge semantics the gate replays.
class MenuTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def menu(bindings: nil)
    App::Menu.new(display: DATA["display"],
                  strings: Core::Strings.new(DATA, locale: "en"),
                  bindings:)
  end

  # Drive a menu through a frame schedule: { frame => [actions] }. Runs a
  # few frames past the last press so releases register (the window ticks
  # every frame; a helper that stopped ON the press would pin @prev down).
  # Returns the last non-nil action the machine emitted.
  def drive(m, frames, until_frame: nil)
    input = Core::ScriptedInput.new(frames: frames)
    last = nil
    (0..(until_frame || (frames.keys.max || 0) + 8)).each do |f|
      input.update(f)
      action = m.tick(input)
      last = action if action
    end
    [last, input]
  end

  def test_route_closed_returns_the_same_object
    m = menu
    input = Core::ScriptedInput.new(frames: {})
    assert_same input, m.route(input),
                "closed menu must route the IDENTICAL object — the wall's " \
                "byte-path identity leans on this (brief D1)"
  end

  def test_route_open_returns_a_null_input
    m = menu
    _, input = drive(m, { 0 => ["menu"] })
    assert m.open?
    routed = m.route(input)
    refute_same input, routed
    refute routed.down?(:attack), "routed input while open must hold nothing"
    assert_same routed, m.route(input),
                "the menu holds ONE NullInput instance (brief D1)"
  end

  def test_menu_edge_toggles_open_then_closed
    m = menu
    refute m.open?
    drive(m, { 0 => ["menu"] })
    assert m.open?, "menu edge opens"
    drive(m, { 0 => ["menu"] }) # fresh script: fresh edge
    refute m.open?, "menu edge on :root closes"
  end

  def test_held_key_is_one_edge_no_bounce
    m = menu
    drive(m, (0..30).to_h { |f| [f, ["menu"]] })
    assert m.open?, "a 31-frame hold is ONE edge — opens once, never bounces"
  end

  def test_closed_menu_is_inert_to_other_actions
    m = menu
    drive(m, { 0 => %w[attack up down], 10 => %w[attack] })
    refute m.open?, "attack/nav edges while closed change nothing"
    assert_nil m.draw_model
  end

  def test_cursor_clamps_at_bounds
    m = menu
    drive(m, { 0 => ["menu"], 8 => ["up"], 16 => ["up"] })
    assert_equal 0, cursor_of(m), "up at the top row stays clamped"
    drive(m, { 0 => ["down"], 8 => ["down"], 16 => ["down"], 24 => ["down"], 32 => ["down"] })
    assert_equal 4, cursor_of(m), "down at the bottom row stays clamped"
  end

  def test_quit_select_returns_quit
    m = menu
    last, = drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["down"],
                       24 => ["down"], 32 => ["down"], 40 => ["attack"] })
    assert_equal :quit, last, "QUIT row select returns :quit (the window owns the rest — D3)"
    assert m.open?, "the menu stays open — during a netplay drain it never re-ticks"
  end

  def test_resume_select_closes
    m = menu
    last, = drive(m, { 0 => ["menu"], 8 => ["attack"] })
    assert_nil last
    refute m.open?, "RESUME closes the menu"
  end

  def test_controls_transitions_and_back
    m = menu
    drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["down"], 24 => ["attack"] })
    assert_equal :controls, m.draw_model[:screen]
    drive(m, { 0 => ["menu"] })
    assert_equal :root, m.draw_model[:screen], "menu edge backs out of the sheet"
    drive(m, { 0 => ["menu"] })
    refute m.open?
  end

  def test_stats_transitions_and_back
    m = menu
    drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["attack"] })
    model = m.draw_model
    assert_equal :stats, model[:screen], "row 2 opens the J-3 stats screen"
    assert_equal "STATS", model[:title]
    assert_equal "ESC: CLOSE", model[:hint]
    drive(m, { 0 => ["menu"] })
    assert_equal :root, m.draw_model[:screen], "menu edge backs out of stats"
    drive(m, { 0 => ["menu"] })
    refute m.open?
  end

  def test_nav_edges_are_inert_on_the_stats_screen
    m = menu
    drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["attack"], 24 => ["down"], 32 => ["attack"] })
    assert_equal :stats, m.draw_model[:screen],
                 "attack/nav on the stats screen select nothing (menu edge is the only exit)"
  end

  def test_nav_edges_are_inert_on_the_controls_sheet
    m = menu
    drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["down"], 24 => ["attack"],
               32 => ["down"], 40 => ["attack"] })
    assert_equal :controls, m.draw_model[:screen],
                 "attack/nav on the sheet select nothing (menu edge is the only exit)"
  end

  def test_cursor_resets_on_reopen
    m = menu
    drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["menu"], 24 => ["menu"] })
    assert m.open?
    assert_equal 0, cursor_of(m), "every open starts on RESUME (deterministic reopen)"
  end

  def test_tick_returns_nil_on_every_non_quit_path
    m = menu
    last, = drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["up"], 24 => ["attack"] })
    assert_nil last, "RESUME/nav/open ticks return nil — :quit is the only verb"
  end

  def test_never_holds_a_world_ref
    m = menu
    drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["attack"], 24 => ["menu"] })
    vars = m.instance_variables
    refute_includes vars, :@world,
                    "the menu reads NOTHING from world (brief D7 — presentation lane)"
    ctor_params = App::Menu.instance_method(:initialize).parameters.map(&:last)
    refute_includes ctor_params, :world, "no world enters at the ctor either"
  end

  def test_root_draw_model_rows_and_selection
    m = menu
    drive(m, { 0 => ["menu"], 8 => ["down"] })
    model = m.draw_model
    assert_equal :root, model[:screen]
    assert_equal "MENU", model[:title]
    assert_equal "ESC: CLOSE", model[:hint]
    assert_equal %w[RESUME STATS CONTROLS SETTINGS QUIT], model[:rows].map { |r| r[:label] }
    assert_equal [false, true, false, false, false], model[:rows].map { |r| r[:selected] },
                 "exactly the cursor row reads selected"
  end

  def test_resume_confirm_is_swallowed_for_one_route
    m = menu
    _, input = drive(m, { 0 => ["menu"], 8 => ["attack"] }, until_frame: 8)
    refute m.open?
    refute_same input, m.route(input), "RESUME confirm must not leak attack to world"
    assert_same input, m.route(input), "only the close frame is swallowed"
  end

  def test_settings_changes_callbacks_and_values
    Dir.mktmpdir do |dir|
      calls = []
      strings = Core::Strings.new(DATA, locale: "en")
      prefs = App::Prefs.load(File.join(dir, "prefs.local.json"))
      # Callbacks mirror the window wiring: locale switches the ONE shared
      # resolver (brief D10); scale/fullscreen just record the ask here.
      m = App::Menu.new(display: DATA["display"], strings:, prefs:,
                        on_locale: ->(v) { calls << [:locale, v]; strings.switch!(DATA, v) },
                        on_scale: ->(v) { calls << [:scale, v] },
                        on_fullscreen: ->(v) { calls << [:fullscreen, v] })
      drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["down"], 24 => ["down"], 32 => ["attack"] })
      assert_equal :settings, m.draw_model[:screen]
      drive(m, { 0 => ["right"], 8 => ["down"], 16 => ["right"],
                 24 => ["down"], 32 => ["attack"] })
      assert_equal [[:locale, "es"], [:scale, 1], [:fullscreen, true]], calls
      assert_equal ["IDIOMA: ES", "ESCALA DE VENTANA: 1X", "PANTALLA COMPLETA: ON"],
                   m.draw_model[:rows].map { |r| r[:label] },
                   "settings rows re-render from the SWITCHED table + live prefs"
      loaded = App::Prefs.load(File.join(dir, "prefs.local.json"))
      assert_equal({ locale: "es", window_scale: 1, fullscreen: true }, loaded.to_h,
                   "every change commits to the machine-local prefs file")
    end
  end

  def test_settings_nav_alone_changes_nothing
    Dir.mktmpdir do |dir|
      calls = []
      prefs = App::Prefs.load(File.join(dir, "prefs.local.json"))
      m = App::Menu.new(display: DATA["display"], strings: Core::Strings.new(DATA, locale: "en"),
                        prefs:, on_locale: ->(v) { calls << v }, on_scale: ->(v) { calls << v },
                        on_fullscreen: ->(v) { calls << v })
      drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["down"], 24 => ["down"], 32 => ["attack"],
                 40 => ["down"], 48 => ["up"], 56 => ["menu"] })
      assert_equal :root, m.draw_model[:screen], "menu edge backs out of settings"
      assert_empty calls, "nav-only settings visit fires no callback (reel-safety law)"
      refute File.exist?(File.join(dir, "prefs.local.json")),
             "no change means no machine state written"
    end
  end

  def test_controls_sheet_speaks_the_canonical_binding_map
    map = Core::BindingMap.load(DATA, key_table: App::KEY_TABLE, local: false)
    assert_equal %w[Escape], map.glyphs(:menu),
                 "data/bindings.json carries the menu row (brief D2)"
    m = menu(bindings: map)
    drive(m, { 0 => ["menu"], 8 => ["down"], 16 => ["down"], 24 => ["attack"] })
    model = m.draw_model
    labels = model[:rows].map { |r| r[:label] }
    assert_includes labels, "MOVE", "movement rows INCLUDED on the sheet (D5)"
    assert_includes labels, "AIM"
    menu_row = model[:rows].find { |r| r[:label] == "MENU" }
    assert_equal [%w[Escape]], menu_row[:glyphs],
                 "the sheet self-documents the Esc binding from the ONE map"
    move_row = model[:rows].find { |r| r[:label] == "MOVE" }
    assert_equal [%w[Up W], %w[Down S], %w[Left A], %w[Right D]], move_row[:glyphs]
  end

  private

  def cursor_of(m)
    m.draw_model[:rows].index { |r| r[:selected] }
  end
end
