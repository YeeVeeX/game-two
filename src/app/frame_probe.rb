module App
  # Lag P0 T1b (2026-08-20, spec drafts/_lag-spec-20260820.md): env-gated
  # frame-budget probe. Window constructs one ONLY when GAME_FRAME_PROBE=1
  # and brackets update/draw with it; OFF = the ivar stays nil and every
  # site is a `&.` nil-check — zero clock reads, zero allocation, zero
  # behavior branch. Values NEVER flow back into sim, wire, digest, or
  # draw: samples aggregate here and leave as ONE close-time log line.
  #
  # Pure math: the clock is injected (Window wires CLOCK_MONOTONIC float
  # ms; tests feed scripts). period = ms between consecutive update-begins
  # (the loop pace — vsync-miss doubling reads as a 33 ms mode);
  # update/draw = bracket costs. Percentiles are nearest-rank on the
  # sorted samples: sorted[floor(q*n)] clamped. over20/35/100 census on
  # period STRICTLY greater (spike shapes: doubled vblank / dropped
  # frames / freezes). An unclosed bracket (close() prints mid-frame)
  # contributes nothing.
  class FrameProbe
    MONOTONIC_MS = -> { Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond) }

    def initialize(clock: MONOTONIC_MS)
      @clock = clock
      @periods = []
      @updates = []
      @draws = []
      @frames = 0
      @update_t0 = nil
      @draw_t0 = nil
      @last_begin = nil
    end

    def update_begin
      now = @clock.call
      @frames += 1
      @periods << (now - @last_begin) if @last_begin
      @last_begin = now
      @update_t0 = now
    end

    def update_end
      return if @update_t0.nil?
      @updates << (@clock.call - @update_t0)
      @update_t0 = nil
    end

    def draw_begin
      @draw_t0 = @clock.call
    end

    def draw_end
      return if @draw_t0.nil?
      @draws << (@clock.call - @draw_t0)
      @draw_t0 = nil
    end

    def line
      "TELEMETRY frame_probe frames=#{@frames} " \
        "period{#{stats(@periods, %w[p50 p90 p99])}} " \
        "update{#{stats(@updates, %w[p50 p95])}} " \
        "draw{#{stats(@draws, %w[p50 p95])}} " \
        "over20=#{census(20)} over35=#{census(35)} over100=#{census(100)}"
    end

    private

    QUANTILE = { "p50" => 0.5, "p90" => 0.9, "p95" => 0.95, "p99" => 0.99 }.freeze

    def stats(samples, quantiles)
      sorted = samples.sort
      parts = quantiles.map do |q|
        "#{q}=#{fmt(percentile(sorted, QUANTILE.fetch(q)))}"
      end
      parts << "max=#{fmt(sorted.last || 0.0)}"
      parts.join(" ")
    end

    def percentile(sorted, q)
      return 0.0 if sorted.empty?
      sorted[[(q * sorted.length).floor, sorted.length - 1].min]
    end

    def census(threshold_ms)
      @periods.count { |p| p > threshold_ms }
    end

    def fmt(ms)
      format("%.1f", ms)
    end
  end
end
