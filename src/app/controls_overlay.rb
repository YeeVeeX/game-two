require "gosu"

module App
  # v14 controls overlay: a persistent quiet strip at the bottom edge —
  # the possessed vessel's canon name + key:verb pairs for the six actions.
  # Reference UI, not a combat element (alpha subdued vs HP bars and the
  # ledger tally). A one-time brighter pulse marks the first possession of
  # each body kind, derived from World#kit_first_possessed (sim-cosmetic
  # state) so the strip is a pure function of sim state — both gate
  # replays render it bit-equal. #draw is the only Gosu-touching method;
  # content resolution and pulse alpha are pure (tested headlessly).
  class ControlsOverlay
    # Strip order for the six teachable actions (movement stays off the
    # strip — v14 parked decision). Glyphs come from the injected
    # Core::BindingMap (v15: the promised reverse-lookup now that
    # rebindable controls exist) — ONE source feeds both KeyboardInput
    # and this strip. The fallback map only keeps a bare bindings-less
    # construct drawable (the VESSEL_FALLBACK precedent).
    ACTIONS = %i[attack dodge special mark interact swap].freeze
    GLYPH_FALLBACK = { attack: %w[J Space], dodge: %w[K LShift],
                       special: %w[L E], mark: [";", "Q"],
                       interact: %w[H F], swap: %w[Tab] }.freeze

    # EN fallbacks keep a bare strings-less construct drawable (the
    # draw_wipe_overlay precedent) — canonical text lives in data/strings.
    VESSEL_FALLBACK = { striker: "player 1", blocker: "player 2", lobber: "player 3" }.freeze
    VERB_FALLBACK = { striker: "spin", blocker: "shout", lobber: "lob" }.freeze
    LABEL_FALLBACK = { attack: "attack", dodge: "dodge", mark: "mark",
                       interact: "interact", swap: "swap" }.freeze

    # Kit identity colors (Renderer::KIT_BODY family) + quiet text tones.
    VESSEL_RGB = { striker: [235, 120, 40], blocker: [190, 80, 35],
                   lobber: [225, 170, 90] }.freeze
    GLYPH_RGB = [225, 218, 205].freeze # bright bone — the keys pop
    LABEL_RGB = [160, 152, 140].freeze # subdued — the verbs whisper
    BACKING_RGB = [10, 8, 12].freeze   # ledger-panel near-black family

    def initialize(display: {}, strings: nil, bindings: nil, local_seat: 1)
      @display = display
      @strings = strings
      @bindings = bindings
      # v17 renderer seam (Codex fold #7): the strip speaks for the LOCAL
      # seat's body — default 1 keeps single-player byte-identical.
      @local_seat = local_seat
    end

    # { vessel: "player 2", pairs: [{ glyphs: ["J", "Space"], label: "attack" },
    # ...] } — pairs in ACTIONS order, glyphs in binding order (primary
    # first; the twelfth's dual-keybind lane); the special slot always
    # speaks the kit's own verb.
    def vessel_line(world)
      kit = world.possessed(@local_seat).kit_name
      pairs = ACTIONS.map do |action|
        label =
          if action == :special
            tr("overlay.verb.#{kit}", VERB_FALLBACK[kit])
          else
            tr("overlay.#{action}", LABEL_FALLBACK[action])
          end
        glyphs = @bindings ? @bindings.glyphs(action) : GLYPH_FALLBACK[action]
        { glyphs:, label: }
      end
      { vessel: tr("overlay.vessel.#{kit}", VESSEL_FALLBACK[kit]), pairs: }
    end

    # Backing alpha now: resting, or lifted while the possessed kind is
    # inside its first-possession pulse window (linear decay back).
    def strip_alpha_now(world)
      rest = strip_alpha
      first = world.kit_first_possessed[world.possessed(@local_seat).kit_name]
      return rest unless first
      age = world.frame - first
      return rest if age >= pulse_frames
      (pulse_alpha - (pulse_alpha - rest) * age.fdiv(pulse_frames)).round
    end

    def draw(world)
      # v17 waiting-for-body: no body, no strip — the netplay overlay says
      # NO BODY — WAITING (guard never taken single-player: seat 1's
      # pointer survives even a wipe).
      return unless world.possessed(@local_seat)
      h = strip_height
      y = world.camera(@local_seat).view_h - h
      a = strip_alpha_now(world)
      Gosu.draw_rect(0, y, world.camera(@local_seat).view_w, h, Gosu::Color.new(a, *BACKING_RGB))
      line = vessel_line(world)
      kit = world.possessed(@local_seat).kit_name
      ty = y + y_pad
      x = x_start
      text_a = [a + 60, 255].min # text reads a notch above its backing
      vessel_col = Gosu::Color.new(text_a, *VESSEL_RGB.fetch(kit, GLYPH_RGB))
      font.draw_text(line[:vessel], x, ty, 0, 1, 1, vessel_col)
      x += font.text_width(line[:vessel]) + section_gap
      glyph_col = Gosu::Color.new(text_a, *GLYPH_RGB)
      label_col = Gosu::Color.new([text_a - 40, 60].max, *LABEL_RGB)
      line[:pairs].each do |pair|
        primary, *rest = pair[:glyphs]
        font.draw_text(primary, x, ty, 0, 1, 1, glyph_col)
        x += font.text_width(primary)
        # Secondary glyphs at label tone — visible but quieter (the
        # twelfth's ask: show BOTH options without shouting).
        rest.each do |g|
          font.draw_text("/#{g}", x, ty, 0, 1, 1, label_col)
          x += font.text_width("/#{g}")
        end
        x += glyph_gap
        font.draw_text(pair[:label], x, ty, 0, 1, 1, label_col)
        x += font.text_width(pair[:label]) + section_gap
      end
    end

    private

    def tr(key, fallback) = @strings ? @strings.t(key, fallback) : fallback

    def font = @font ||= Gosu::Font.new(font_size)

    def strip_height = @display.fetch(:overlay_strip_height, 28)
    def strip_alpha = @display.fetch(:overlay_strip_alpha, 140)
    def font_size = @display.fetch(:overlay_font_size, 12)
    def y_pad = @display.fetch(:overlay_y_pad, 6)
    def x_start = @display.fetch(:overlay_x_start, 32)
    def glyph_gap = @display.fetch(:overlay_glyph_gap, 8)
    def section_gap = @display.fetch(:overlay_section_gap, 20)
    def pulse_frames = @display.fetch(:overlay_pulse_frames, 45)
    def pulse_alpha = @display.fetch(:overlay_pulse_alpha, 230)
  end
end
