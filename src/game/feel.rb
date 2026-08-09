module Game
  # Game feel: hitstop + screen shake. Deterministic — shake phase advances by
  # frame count (sin/cos), no randomness, so replays are byte-identical.
  class Feel
    attr_reader :shake_x, :shake_y

    def initialize(cfg)
      @cfg = cfg
      @hitstop = 0
      @shake_amp = 0.0
      @shake_phase = 0
      @shake_x = 0.0
      @shake_y = 0.0
    end

    def hitstop? = @hitstop.positive?

    def on_hit
      @hitstop = [@hitstop, @cfg[:hitstop_frames_hit]].max
      @shake_amp = [@shake_amp, @cfg[:shake_hit]].max
    end

    # Receiving a hit shakes but never freezes: hitstop sells the possessed's
    # OWN impact (on_hit/on_kill); freezing on incoming hits turns a pincer
    # into a slideshow (M2.1 fix 2).
    def on_player_hit
      @shake_amp = [@shake_amp, @cfg[:shake_player_hit]].max
    end

    def on_kill
      @hitstop = [@hitstop, @cfg[:hitstop_frames_kill]].max
      @shake_amp = [@shake_amp, @cfg[:shake_kill]].max
    end

    def tick
      @hitstop -= 1 if @hitstop.positive?
      @shake_phase += 1
      if @shake_amp > 0.05
        @shake_x = Math.sin(@shake_phase * 2.7) * @shake_amp
        @shake_y = Math.cos(@shake_phase * 3.1) * @shake_amp
        @shake_amp *= @cfg[:shake_decay]
      else
        @shake_x = 0.0
        @shake_y = 0.0
      end
    end
  end
end
