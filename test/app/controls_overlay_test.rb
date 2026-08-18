require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "core/input"
require "core/binding_map"
require "game/world"
require "app/controls_overlay"
require "app/key_table"

# v14 controls overlay (spec Presentation 1): a quiet bottom strip naming
# the possessed vessel (placeholders: player 1/2/3) + key:verb pairs, with a
# one-time first-possession pulse per body kind. Content resolution and
# pulse alpha are PURE functions (draw is the only Gosu-touching method);
# the pulse derives from World's kit_first_possessed — sim-cosmetic state
# the sim never reads (taunt_pulses precedent) — so both gate replays see
# bit-equal strips.
class ControlsOverlayTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  DISPLAY = DATA["display"]

  Possessed = Struct.new(:kit_name)
  PackStub = Struct.new(:provisions)

  def world_stub(kit, frame: 0, first: nil, provisions: 0)
    w = Object.new
    class << w
      attr_accessor :frame, :kit_first_possessed, :pack
      attr_writer :possessed
      # The real World#possessed takes an optional seat (v17 seat map);
      # the stub mirrors the API — the overlay reads its local seat.
      def possessed(_seat = 1) = @possessed
    end
    w.possessed = Possessed.new(kit)
    w.frame = frame
    w.kit_first_possessed = first || { kit => 0 }
    w.pack = PackStub.new(provisions)
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
    assert_equal "player 1", striker[:vessel]
    assert_includes striker[:pairs], { glyphs: %w[L E], label: "spin" }
    blocker = o.vessel_line(world_stub(:blocker))
    assert_equal "player 2", blocker[:vessel]
    assert_includes blocker[:pairs], { glyphs: %w[L E], label: "shout" }
    lobber = o.vessel_line(world_stub(:lobber))
    assert_equal "player 3", lobber[:vessel]
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
    assert_equal "player 2", pairs[:vessel], "placeholder vessel names are locale-invariant"
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
    assert_equal "player 2", o.vessel_line(w)[:vessel]
    w.possessed = Possessed.new(:striker)
    assert_equal "player 1", o.vessel_line(w)[:vessel],
                 "the strip reads the possessed kit every draw"
  end

  # --- v18 sustain row + provisions counter (decision 7iii: the wall pin) ---

  def test_sustain_pair_joins_the_strip_only_with_provisions
    o = overlay
    zero = o.vessel_line(world_stub(:striker))[:pairs]
    refute zero.any? { |p| p[:label] == "provision" },
           "provisions=0 draws NOTHING — no sustain row (7iii)"
    some = o.vessel_line(world_stub(:striker, provisions: 2))[:pairs]
    assert_equal({ glyphs: %w[U R], label: "provision" }, some.last,
                 "the sustain row appears once a provision exists, U/R pair grammar")
    assert_equal zero.length + 1, some.length, "add-only — the six stay"
  end

  def test_provisions_counter_gated_and_localized
    o = overlay
    assert_nil o.provisions_line(world_stub(:striker)),
               "provisions=0 draws NOTHING — no counter (7iii)"
    assert_equal "PROVISION 2", o.provisions_line(world_stub(:striker, provisions: 2))
    es = overlay(locale: "es").provisions_line(world_stub(:striker, provisions: 1))
    assert_equal "PROVISIÓN 1", es, "the counter label translates (functional word)"
  end

  def test_sustain_glyphs_ride_the_canonical_binding_map
    map = Core::BindingMap.load(DATA, key_table: App::KEY_TABLE, local: false)
    assert_equal %w[U R], map.glyphs(:sustain),
                 "data/bindings.json carries the sustain row (decision 10)"
    o = App::ControlsOverlay.new(display: DISPLAY,
                                 strings: Core::Strings.new(DATA, locale: "en"),
                                 bindings: map)
    pairs = o.vessel_line(world_stub(:blocker, provisions: 1))[:pairs]
    assert_includes pairs, { glyphs: %w[U R], label: "provision" },
                    "one source feeds KeyboardInput and the strip (v15 law)"
  end

  def test_provisions_surfaces_absent_on_a_fresh_real_world
    w = Game::World.new(DATA, seed: 42)
    o = overlay
    assert_nil o.provisions_line(w), "fresh world: no counter (7iii, real World)"
    refute o.vessel_line(w)[:pairs].any? { |p| p[:label] == "provision" },
           "fresh world: no sustain row (7iii, real World)"
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
