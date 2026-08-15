module App
  # v16 (a): integer window upscale. PURE math — no Gosu dependency — so the
  # policy unit-tests headless. The game window opens at view*factor and ONE
  # Gosu.scale(factor) wraps the draw; logical coordinates and the capture
  # pipeline (harness renders at script dims) never see the factor.
  module Scale
    # setting: "auto" | Integer | nil (from data/display.json window_scale).
    #   Integer      -> clamped to >= 1 (explicit pin wins over screen math).
    #   "auto"       -> largest integer k with view*k inside the SCREEN dims
    #                   (full resolution, not the work area — a 1080p taskbar
    #                   setup must still earn 2x), min 1.
    #   nil / other  -> 1 (fallback law: configs without the key keep the
    #                   pre-v16 window exactly).
    def self.factor(setting, view_w:, view_h:, screen_w:, screen_h:)
      case setting
      when Integer then [setting, 1].max
      when "auto" then [[screen_w / view_w, screen_h / view_h].min, 1].max
      else 1
      end
    end
  end
end
