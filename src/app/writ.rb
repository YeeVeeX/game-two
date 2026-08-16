module App
  # v16 (d): writ-frame geometry — PURE window math, no Gosu (GLM review
  # fold: a full-screen alpha veil reads as a GPU glitch and threatens
  # fairness; the court draws its writ AROUND the chanter instead). Four
  # darkening bands tile the view MINUS the writ square; a thin border
  # marks the writ itself. Integer in, integer out.
  module Writ
    module_function

    # -> { out: [[x,y,w,h],...], border: [[x,y,w,h]x4] } — out bands are
    # clamped to the view and never overlap the square's visible interior.
    def rects(cx:, cy:, radius:, view_w:, view_h:, border: 2)
      left = cx - radius
      top = cy - radius
      side = radius * 2
      right = left + side
      bottom = top + side
      vt = top.clamp(0, view_h)
      vb = bottom.clamp(0, view_h)
      vl = left.clamp(0, view_w)
      vr = right.clamp(0, view_w)
      out = []
      out << [0, 0, view_w, vt] if vt.positive?
      out << [0, vb, view_w, view_h - vb] if vb < view_h
      out << [0, vt, vl, vb - vt] if vl.positive? && (vb - vt).positive?
      out << [vr, vt, view_w - vr, vb - vt] if vr < view_w && (vb - vt).positive?
      frame = [
        [left, top, side, border],
        [left, bottom - border, side, border],
        [left, top, border, side],
        [right - border, top, border, side],
      ]
      { out:, border: frame }
    end
  end
end
