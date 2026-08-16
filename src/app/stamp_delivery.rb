module App
  # v16 (c): stamp delivery window math. PURE functions of the entry clock
  # (age / frames_left) — no RNG stream, no wall clock (the KillPop law).
  # Factor endpoints and window lengths ride data/display.json; nothing
  # here is a tunable. Renderer is the only consumer; the sim owns the
  # records (banner queue entries + world.seal_marks).
  module StampDelivery
    # Linear scale-in: `from` at age 0, `to` once the in-window closes.
    # Linear on purpose — easing curve constants in code would be balance.
    def self.scale_at(age:, in_frames:, from:, to:)
      return to if in_frames <= 0 || age >= in_frames
      from + (to - from) * age.fdiv(in_frames)
    end

    # Full presence through the dwell, linear alpha tail over fade_frames.
    def self.alpha_at(frames_left:, fade_frames:)
      return 255 if fade_frames <= 0 || frames_left >= fade_frames
      (255 * frames_left.fdiv(fade_frames)).round.clamp(0, 255)
    end
  end
end
