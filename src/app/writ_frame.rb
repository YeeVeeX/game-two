module App
  # v16 (d): writ-frame dim geometry — up to 4 rects covering the map
  # bounds MINUS the writ square, a pure function of (center, half,
  # bounds). The GLM review fold: a full-screen alpha veil reads as a GPU
  # glitch and threatens fairness — so the world OUTSIDE the writ darkens
  # hard while everything INSIDE stays untouched (check #53's wording:
  # ring and bodies read inside). Renderer is the only consumer.
  module WritFrame
    def self.dim_rects(cx:, cy:, half:, w:, h:)
      x0 = (cx - half).clamp(0, w)
      x1 = (cx + half).clamp(0, w)
      y0 = (cy - half).clamp(0, h)
      y1 = (cy + half).clamp(0, h)
      rects = []
      rects << [0, 0, w, y0] if y0.positive?
      rects << [0, y1, w, h - y1] if y1 < h
      rects << [0, y0, x0, y1 - y0] if x0.positive? && y1 > y0
      rects << [x1, y0, w - x1, y1 - y0] if x1 < w && y1 > y0
      rects
    end
  end
end
