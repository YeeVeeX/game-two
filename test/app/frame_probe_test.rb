require_relative "../test_helper"
require "app/frame_probe"

# Lag P0 T1b (2026-08-20): the env-gated frame-budget probe's PURE math —
# fixed clock scripts in, exact percentiles/censuses/line out. No Gosu,
# no real clock (the clock is injected; Window wires the monotonic one).
class FrameProbeTest < Minitest::Test
  # A scripted clock: each call returns the next value.
  def clock(*values)
    seq = values.flatten.each
    -> { seq.next }
  end

  def test_empty_probe_emits_an_honest_zero_line
    probe = App::FrameProbe.new(clock: clock)
    assert_equal "TELEMETRY frame_probe frames=0 " \
                 "period{p50=0.0 p90=0.0 p99=0.0 max=0.0} " \
                 "update{p50=0.0 p95=0.0 max=0.0} " \
                 "draw{p50=0.0 p95=0.0 max=0.0} " \
                 "over20=0 over35=0 over100=0",
                 probe.line
  end

  def test_periods_come_from_consecutive_update_begins_and_updates_from_the_brackets
    # Three frames at t=0/20/60; update costs 5/8/2 ms. Periods: 20, 40.
    probe = App::FrameProbe.new(clock: clock(
      0, 5,      # frame 1: begin 0, end 5
      20, 28,    # frame 2: begin 20, end 28 (period 20)
      60, 62     # frame 3: begin 60, end 62 (period 40)
    ))
    3.times do
      probe.update_begin
      probe.update_end
    end
    line = probe.line
    assert_match(/frames=3 /, line)
    assert_match(/period\{p50=40\.0 p90=40\.0 p99=40\.0 max=40\.0\}/, line,
                 "two periods 20/40: nearest-rank p50 of [20,40] = 40")
    assert_match(/update\{p50=5\.0 p95=8\.0 max=8\.0\}/, line)
    assert_match(/over20=1 over35=1 over100=0/, line,
                 "census counts periods STRICTLY over each threshold; 40 > both 20 and 35")
  end

  def test_draw_brackets_aggregate_independently
    probe = App::FrameProbe.new(clock: clock(0, 3, 10, 17))
    2.times do
      probe.draw_begin
      probe.draw_end
    end
    assert_match(/draw\{p50=7\.0 p95=7\.0 max=7\.0\}/, probe.line,
                 "draw samples [3,7]: nearest-rank p50 of n=2 = sorted[1] = 7")
    assert_match(/frames=0 /, probe.line, "draws alone are not frames")
  end

  def test_census_thresholds_catch_the_spike_shapes
    # Periods: 16.7 (healthy), 33.4 (vsync-miss double), 3341 (freeze).
    probe = App::FrameProbe.new(clock: clock(
      0, 1, 16.7, 17.7, 50.1, 51, 3391.1, 3392
    ))
    4.times do
      probe.update_begin
      probe.update_end
    end
    assert_match(/over20=2 over35=1 over100=1/, probe.line,
                 "periods 16.7/33.4/3341.0: 33.4 and 3341 pass 20; only 3341 passes 35 and 100")
  end

  def test_begin_without_end_is_tolerated_the_last_frame_dies_mid_update
    probe = App::FrameProbe.new(clock: clock(0, 5, 20))
    probe.update_begin
    probe.update_end
    probe.update_begin # close() prints mid-frame; no update_end ever comes
    assert_match(/frames=2 /, probe.line)
    assert_match(/update\{p50=5\.0 p95=5\.0 max=5\.0\}/, probe.line,
                 "the unclosed bracket contributes no update sample")
  end

  def test_percentiles_are_nearest_rank_on_the_sorted_samples
    # 10 updates of 1..10 ms at fixed 10 ms periods.
    times = []
    t = 0.0
    (1..10).each do |cost|
      times << t << (t + cost)
      t += 10
    end
    probe = App::FrameProbe.new(clock: clock(times))
    10.times do
      probe.update_begin
      probe.update_end
    end
    assert_match(/update\{p50=6\.0 p95=10\.0 max=10\.0\}/, probe.line,
                 "nearest-rank: sorted[floor(0.5*10)]=sorted[5]=6, sorted[floor(0.95*10)]=sorted[9]=10")
  end
end
