require "gosu"

module App
  # v17 netplay presentation (spec Presentation spec — every state below
  # lands in a gated capture). Screen-space only, drawn AFTER the world
  # renderer; placeholder/functional text via Core::Strings (names
  # locale-invariant, verbs translate — standing order 2026-08-16).
  # Pure state resolution lives in #flags (headless-tested against REAL
  # sessions); #draw is the only Gosu-touching method.
  class NetplayOverlay
    # z 22/23 (2026-09-06): the END veil + its text sit ABOVE the HUD (19-21) and the
    # controls strip (z 19 since 65f52e5). Before, the strip (z 0) sat under the veil by
    # call order; at z 19 it surfaced over the end screen (fixes review §8b).
    BONE = [225, 215, 190].freeze          # Renderer::BANNER family
    DIM  = [160, 152, 140].freeze          # ControlsOverlay label tone
    BG   = [12, 10, 14].freeze             # ledger-panel near-black family
    VEIL_ALPHA = 235                       # end screens: the state IS the frame

    def initialize(display: {}, strings: nil, view_w: 960, view_h: 540)
      @display = display
      @strings = strings
      @view_w = view_w
      @view_h = view_h
    end

    # session + world -> what the frame must say. Exactly one full-screen
    # :screen at a time (states are mutually exclusive by session phase);
    # the run-time cues (stall/link_slow/no_body/gate_wait) can stack.
    # reason=quit maps to :partner_left UNCONDITIONALLY (J6-C, brief D14):
    # the initiating seat's window closes before it ever draws a post-end
    # frame, so only the ABANDONED seat renders the courtesy notice — the
    # frozen world it holds finally says why.
    # reason=protocol shares the CONNECTION LOST screen (trusted seats: a
    # wire speaking wrong is a broken link; TELEMETRY stays honest with
    # reason=protocol — the artifact of record, decision 8).
    def flags(session, world)
      f = { screen: nil, stall_ms: nil, link_slow: false, no_body: false, gate_wait: nil }
      return f unless session
      if session.ended?
        f[:screen] =
          case session.reason
          when :desync then :desync
          when :conn_lost, :protocol then :conn_lost
          when :quit then :partner_left
          end
        return f
      end
      unless session.running?
        f[:screen] = session.phase == :listen ? :hosting : :connecting
        return f
      end
      f[:stall_ms] = session.stall_warning_ms
      f[:link_slow] = session.link_slow && session.ticks < net_banner_frames
      f[:no_body] = !world.nil? && world.possessed(session.seat).nil?
      f[:gate_wait] = world&.gate_wait
      f
    end

    def draw(session, world)
      f = flags(session, world)
      case f[:screen]
      when :hosting
        screen_state(tr("net.hosting", "HOSTING — WAITING FOR PARTNER"),
                     sub: "#{tr('net.port', 'PORT')} #{session.port}", opaque: true)
      when :connecting
        screen_state(tr("net.connecting", "CONNECTING…"), opaque: true)
      when :desync
        line = tr("net.desync", "DESYNC AT TICK <N> — SESSION ENDED")
               .sub("<N>", session.lockstep&.desync&.tick.to_s)
        screen_state(line, sub: session.artifact_path)
      when :conn_lost
        screen_state(tr("net.conn_lost", "CONNECTION LOST — SESSION ENDED"))
      when :partner_left
        screen_state(tr("net.partner_left", "PARTNER LEFT — SESSION ENDED"))
      else
        draw_cue(tr("net.stall", "WAITING FOR PARTNER") + " #{f[:stall_ms].round} ms",
                 info_font, 16) if f[:stall_ms]
        draw_cue(tr("net.link_slow", "LINK SLOW"), state_font, 88) if f[:link_slow]
        draw_cue(tr("net.gate_wait", "WAITING AT GATE"), info_font, 130) if f[:gate_wait]
        if f[:no_body]
          draw_cue(tr("net.no_body", "NO BODY — WAITING"), state_font, @view_h / 2 - 60)
        end
      end
    end

    private

    # Full-screen state: opaque near-black pre-session (nothing exists
    # behind), heavy veil on end screens (the frozen world stays a ghost —
    # the freeze IS the message, the line explains it).
    def screen_state(line, sub: nil, opaque: false)
      Gosu.draw_rect(0, 0, @view_w, @view_h,
                     Gosu::Color.new(opaque ? 255 : VEIL_ALPHA, *BG), 22)
      f = state_font
      y = @view_h / 2 - 40
      f.draw_text(line, (@view_w - f.text_width(line)) / 2, y, 23, 1, 1,
                  Gosu::Color.new(255, *BONE))
      return unless sub
      i = info_font
      i.draw_text(sub, (@view_w - i.text_width(sub)) / 2, y + 44, 23, 1, 1,
                  Gosu::Color.new(255, *DIM))
    end

    def draw_cue(text, font, y)
      font.draw_text(text, (@view_w - font.text_width(text)) / 2, y, 23, 1, 1,
                     Gosu::Color.new(255, *BONE))
    end

    def tr(key, fallback) = @strings ? @strings.t(key, fallback) : fallback
    def net_banner_frames = @display.fetch(:net_banner_frames)
    def state_font = @state_font ||= Gosu::Font.new(28, bold: true)
    def info_font = @info_font ||= Gosu::Font.new(14)
  end
end
