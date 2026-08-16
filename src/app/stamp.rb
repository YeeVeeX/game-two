module App
  # v16 (c): stamp delivery timing — PURE window math, no Gosu (App::Scale /
  # App::KillPop pattern; renderer is the only consumer). Factor endpoints
  # ride data/display.json: no easing-curve constants in code.
  module Stamp
    module_function

    # Scale-in: in_scale -> 1.0 linear over in_frames, then hold. The stamp
    # LANDS — big at first touch, settled through the dwell.
    def scale(age:, in_frames:, in_scale:)
      return 1.0 if in_frames <= 0 || age >= in_frames
      in_scale - (in_scale - 1.0) * age.fdiv(in_frames)
    end

    # Fade tail: full alpha through the dwell, ramp out over the final
    # third of the clock (the drop-decay/ledger grammar).
    def alpha(frames_left:, frames_total:)
      frac = frames_left.fdiv(frames_total)
      return 255 if frac >= 1 / 3.0
      (255 * frac * 3).clamp(0, 255).round
    end
  end
end
