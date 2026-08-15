require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "core/input"
require "core/binding_map"
require "game/world"
require "app/controls_overlay"

# v14 controls overlay (spec Presentation 1): a quiet bottom strip naming
# the possessed vessel (canon: ithet/goret/hevet) + key:verb pairs, with a
# one-time first-possession pulse per body kind. Content resolution and
# pulse alpha are PURE functions (draw is the only Gosu-touching method);
# the pulse derives from World's kit_first_possessed — sim-cosmetic state
# the sim never reads (taunt_pulses precedent) — so both gate replays see
# bit-equal strips.
class ControlsOverlayTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  DISPLAY = DATA["display"]

  Possessed = Struct.new(:kit_name)

  def world_stub(kit, frame: 0, first: nil)
    w = Object.new
    class << w
      attr_accessor :possessed, :frame, :kit_first_possessed
    end
    w.possessed = Possessed.new(kit)
    w.frame = frame
    w.kit_first_possessed = first || { kit => 0 }
    w
  end

  def overlay(locale: "en")
    App::ControlsOverlay.new(display: DISPLAY,
                             strings: Core::Strings.new(DATA, locale: locale))
  end

  # --- content -------------------------------------------------------------

  def test_vessel_and_verb_per_kit
    o = overlay
    striker = o.vessel_line(world_stub(:striker))
    assert_equal "ithet", striker[:vessel]
    assert_includes striker[:pairs], { glyphs: %w[L E], label: "spin" }
    blocker = o.vessel_line(world_stub(:blocker))
    assert_equal "goret", blocker[:vessel]
    assert_includes blocker[:pairs], { glyphs: %w[L E], label: "shout" }
    lobber = o.vessel_line(world_stub(:lobber))
    assert_equal "hevet", lobber[:vessel]
    assert_includes lobber[:pairs], { glyphs: %w[L E], label: "lob" }
  end

  def test_pairs_follow_action_order_with_dual_glyphs
    pairs = overlay.vessel_line(world_stub(:blocker))[:pairs]
    assert_equal %w[J K L ; H Tab], pairs.map { |p| p[:glyphs].first },
                 "primary glyphs, ACTIONS order"
    assert_equal ["Space", "LShift", "E", "Q", "F", nil],
                 pairs.map { |p| p[:glyphs][1] },
                 "secondary glyphs visible (the twelfth's dual-keybind lane); swap has none"
    assert_equal %w[attack dodge shout mark interact swap], pairs.map { |p| p[:label] }
  end

  def test_locale_switch_translates_labels_not_vessel_names
    pairs = overlay(locale: "es").vessel_line(world_stub(:blocker))
    assert_equal "goret", pairs[:vessel], "canon vessel names do not translate"
    assert_includes pairs[:pairs], { glyphs: %w[J Space], label: "atacar" }
    assert_includes pairs[:pairs], { glyphs: %w[L E], label: "gritar" }
    assert_includes pairs[:pairs], { glyphs: %w[Tab], label: "cambiar" }
  end

  # v15: the strip and KeyboardInput share ONE source — a rebound map is
  # what the strip shows, byte-for-byte.
  def test_strip_glyphs_ride_the_injected_binding_map
    table = { "X" => 1, "Y" => 2, "J" => 3, "K" => 4, "L" => 5, ";" => 6,
              "H" => 7, "Tab" => 8, "Space" => 9, "LShift" => 10, "E" => 11,
              "Q" => 12, "F" => 13 }
    map = Core::BindingMap.new(
      { attack: %w[X Y], dodge: %w[K], special: %w[L], mark: [";"],
        interact: %w[H], swap: %w[Tab] }, key_table: table
    )
    o = App::ControlsOverlay.new(display: DISPLAY,
                                 strings: Core::Strings.new(DATA, locale: "en"),
                                 bindings: map)
    pairs = o.vessel_line(world_stub(:blocker))[:pairs]
    assert_includes pairs, { glyphs: %w[X Y], label: "attack" },
                    "a rebound key shows on the strip — single source"
  end

  def test_content_updates_on_possession_swap
    o = overlay
    w = world_stub(:blocker)
    assert_equal "goret", o.vessel_line(w)[:vessel]
    w.possessed = Possessed.new(:striker)
    assert_equal "ithet", o.vessel_line(w)[:vessel],
                 "the strip reads the possessed kit every draw"
  end

  # --- pulse ---------------------------------------------------------------

  def test_pulse_alpha_decays_from_pulse_to_resting
    o = overlay
    rest = DISPLAY[:overlay_strip_alpha]
    peak = DISPLAY[:overlay_pulse_alpha]
    frames = DISPLAY[:overlay_pulse_frames]
    assert_equal peak, o.strip_alpha_now(world_stub(:blocker, frame: 0)),
                 "first frame of a first possession pulses at peak"
    mid = o.strip_alpha_now(world_stub(:blocker, frame: frames / 2))
    assert mid < peak && mid > rest, "decay passes between peak and rest (got #{mid})"
    assert_equal rest, o.strip_alpha_now(world_stub(:blocker, frame: frames + 1)),
                 "past the pulse window the strip rests"
  end

  def test_pulse_only_for_unseen_kinds
    o = overlay
    rest = DISPLAY[:overlay_strip_alpha]
    # blocker first seen long ago; striker just now — striker pulses,
    # returning to blocker later does NOT re-pulse.
    w = world_stub(:striker, frame: 1000, first: { blocker: 0, striker: 1000 })
    assert_equal DISPLAY[:overlay_pulse_alpha], o.strip_alpha_now(w)
    w.possessed = Possessed.new(:blocker)
    assert_equal rest, o.strip_alpha_now(w), "a seen kind never re-pulses"
  end

  # --- the sim side (real World, no mocks) ----------------------------------

  def test_world_registers_first_possession_per_kind_once
    w = Game::World.new(DATA, seed: 42)
    assert_equal({ blocker: 0 }, w.kit_first_possessed,
                 "the initial body counts as first-possessed at frame 0")
    # Swaps spaced past swap_stagger_frames (20) — a still-staggered body
    # refuses the swap (law 2).
    input = Core::ScriptedInput.new(frames: { 5 => [:swap], 40 => [:swap], 75 => [:swap] })
    90.times do
      input.update(w.frame)
      w.tick(input)
    end
    seen = w.kit_first_possessed
    assert_equal %i[blocker lobber striker].sort, seen.keys.sort,
                 "cycling possession registers each kind"
    assert_equal 0, seen[:blocker], "returning to the initial kind never re-registers"
    assert seen[:lobber].positive? && seen[:striker].positive?
    assert seen[:lobber] != seen[:striker]
  end
end
