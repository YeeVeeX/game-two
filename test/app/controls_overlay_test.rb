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
    assert_equal %w[J K L ; H Tab U], pairs.map { |p| p[:glyphs].first },
                 "primary glyphs, ACTIONS order + the always-on sustain pair (v20 T3)"
    assert_equal ["Space", "LShift", "E", "Q", "F", nil, "R"],
                 pairs.map { |p| p[:glyphs][1] },
                 "secondary glyphs visible (the twelfth's dual-keybind lane); swap has none"
    assert_equal %w[attack dodge shout mark interact swap potion], pairs.map { |p| p[:label] }
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

  # --- v20 T3 sustain row + potions counter (R-A2 escalation: ALWAYS-ON,
  # supersedes v18 decision 7iii — the eighteenth measured bought=0 with
  # the bank hint live; the pair and counter now teach at every count) ---

  def test_sustain_pair_is_always_on_the_strip
    o = overlay
    zero = o.vessel_line(world_stub(:striker))[:pairs]
    assert_equal({ glyphs: %w[U R], label: "potion" }, zero.last,
                 "provisions=0 STILL shows the sustain row — always-on (v20 T3)")
    some = o.vessel_line(world_stub(:striker, provisions: 2))[:pairs]
    assert_equal({ glyphs: %w[U R], label: "potion" }, some.last,
                 "the sustain row holds with stock, U/R pair grammar")
    assert_equal zero.length, some.length,
                 "stock never changes the strip's shape — seven pairs at every count"
  end

  def test_potions_counter_always_on_and_localized
    o = overlay
    assert_equal "POTION 0", o.provisions_line(world_stub(:striker)),
                 "zero stock READS as POTION 0 — the empty counter is the buy motivation"
    assert_equal "POTION 2", o.provisions_line(world_stub(:striker, provisions: 2))
    es = overlay(locale: "es").provisions_line(world_stub(:striker, provisions: 1))
    assert_equal "POCIÓN 1", es, "the counter label translates (functional word)"
    pt = overlay(locale: "pt-br").provisions_line(world_stub(:striker))
    assert_equal "POÇÃO 0", pt, "pt-br speaks the potion word too"
  end

  def test_sustain_glyphs_ride_the_canonical_binding_map
    map = Core::BindingMap.load(DATA, key_table: App::KEY_TABLE, local: false)
    assert_equal %w[U R], map.glyphs(:sustain),
                 "data/bindings.json carries the sustain row (decision 10)"
    o = App::ControlsOverlay.new(display: DISPLAY,
                                 strings: Core::Strings.new(DATA, locale: "en"),
                                 bindings: map)
    pairs = o.vessel_line(world_stub(:blocker, provisions: 1))[:pairs]
    assert_includes pairs, { glyphs: %w[U R], label: "potion" },
                    "one source feeds KeyboardInput and the strip (v15 law)"
  end

  def test_sustain_pair_survives_a_partial_injected_map
    map = Core::BindingMap.new(
      { attack: %w[J], dodge: %w[K], special: %w[L], mark: [";"],
        interact: %w[H], swap: %w[Tab] },
      key_table: { "J" => 1, "K" => 2, "L" => 3, ";" => 4, "H" => 5, "Tab" => 6 }
    )
    o = App::ControlsOverlay.new(display: DISPLAY,
                                 strings: Core::Strings.new(DATA, locale: "en"),
                                 bindings: map)
    pairs = o.vessel_line(world_stub(:blocker))[:pairs]
    assert_equal({ glyphs: %w[U R], label: "potion" }, pairs.last,
                 "a map without :sustain falls back to canonical glyphs — the always-on row never draws glyph-less")
  end

  def test_potions_surfaces_present_on_a_fresh_real_world
    w = Game::World.new(DATA, seed: 42)
    o = overlay
    assert_equal "POTION 0", o.provisions_line(w),
                 "fresh world: the counter reads POTION 0 (always-on, real World)"
    assert(o.vessel_line(w)[:pairs].any? { |p| p[:label] == "potion" },
           "fresh world: the sustain row is on the strip before the first buy")
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
