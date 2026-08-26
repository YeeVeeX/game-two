# Junior — ZONE 8 human performance telemetry (2026-08-25)

Seat: Junior, Windows 10 laptop (59 Hz display, Intel HD Graphics 3000).
Build under test: `d6af2b5` (before the later s74–s76 pulls). Human-controlled
ZONE 8 preview, pt-br, audio on, `GAME_FRAME_PROBE=1`, isolated scratch save.
No enemies exist in ZONE 8, so this is render/traversal evidence, not combat
performance evidence.

## Long run (decisive sample)

Source log:
`%TEMP%/game_two_zone8_telemetry_20260825161716.log`

Verbatim frame line:

`TELEMETRY frame_probe frames=48409 period{p50=16.8 p90=33.3 p99=45.2 max=171.4} update{p50=0.3 p95=0.6 max=65.1} draw{p50=9.4 p95=14.9 max=130.5} over20=5954 over35=676 over100=6`

Derived census:

- period >20 ms: 5,954 / 48,408 intervals = **12.30%**;
- period >35 ms: 676 / 48,408 = **1.40%**;
- period >100 ms: 6 / 48,408 = **0.012%**;
- median cadence 16.8 ms (~59.5 Hz), matching this seat's known 59 Hz ceiling;
- update p95 0.6 ms versus draw p95 14.9 ms: ordinary tail is draw-dominant;
- maxima show rare spikes in both layers (update 65.1 ms, draw 130.5 ms), with
  total period max 171.4 ms.

Audio teardown was clean (`dropped_cues=0`). Traversal exercised grass, dirt,
water and wood footstep materials. No fights, deaths, specials, XP or economy
activity occurred by construction.

## Short warm-up run (supporting, not pooled)

Earlier independent ZONE 8 sample:

`TELEMETRY frame_probe frames=3112 period{p50=17.0 p90=37.8 p99=104.2 max=335.7} update{p50=0.3 p95=0.8 max=100.2} draw{p50=10.2 p95=25.3 max=304.8} over20=1125 over35=358 over100=38`

This short run had a much worse tail and is kept separate rather than averaged
into the long sample (warm-up/startup sensitivity is plausible but unproven).

## Bounded conclusion

Junior's report of visible stutter is corroborated. The long run sustains the
59 Hz median but has a measurable doubled-frame tail; normal work remains
mostly render-bound on this machine. This evidence does **not** prove a ZONE 8
regression without a same-build, same-seat comparison run in camp, and it does
not justify a tuning/code change by itself. Recommended next measurement:
repeat `GAME_FRAME_PROBE=1` in camp for a comparable traversal duration, then
compare period and draw distributions.

## Follow-up: camp comparison + isolated A/B

### Human camp run (same seat/build family)

Source: `%TEMP%/game_two_camp_telemetry_20260825230940.log`.
The player began in camp and then traversed combat zones, so this is a broad
normal-world comparator rather than a camp-only sample:

`TELEMETRY frame_probe frames=22742 period{p50=16.7 p90=17.3 p99=41.0 max=661.7} update{p50=1.2 p95=6.4 max=159.2} draw{p50=2.3 p95=4.6 max=175.6} over20=1036 over35=333 over100=13`

Against the long ZONE 8 human run, ordinary-tail differences are clear:

- ZONE 8 period p90 33.3 ms vs normal-world 17.3 ms;
- ZONE 8 draw p95 14.9 ms vs normal-world 4.6 ms;
- period >20 ms: ZONE 8 12.30% vs normal-world 4.56%;
- period >35 ms is effectively tied (1.40% vs 1.46%); rare maxima are noisy
  in both and do not identify the cause.

### Isolated fixed-start A/B (diagnostic support)

To remove gameplay/enemy/audio differences, the same build ran a stationary,
audio-off, empty-input bot at fixed starts, alternating order, 600 target
world ticks per lane. This is diagnostic performance evidence only (not human
fun evidence). Two complete camp runs and one complete ZONE 8 run:

- camp A: period p50/p90 `16.9/18.0`, draw p50/p95 `2.7/5.4` ms;
- ZONE 8 A: period p50/p90 `33.4/50.1`, draw p50/p95 `16.4/35.7` ms;
- camp B: period p50/p90 `16.9/25.4`, draw p50/p95 `2.5/5.8` ms.

A second ZONE 8 run degraded severely under the same target and yielded only
421 probe frames before the world reached its 600-tick quit point (period
p50 33.9, draw p95 64.8 ms); it is retained as thermal/order sensitivity,
not pooled with the completed triplet.

## Updated verdict

The ZONE 8 performance issue is **confirmed and zone-specific on Junior's
machine**: its median draw cost is roughly 6× camp in the isolated complete
runs (16.4 vs 2.5–2.7 ms), and its median frame period falls into the doubled-
vblank ~33 ms mode while camp holds ~16.9 ms. The sim update remains cheap.
This supports a dedicated render-performance ticket for ZONE 8; it does not
select the implementation fix. First investigation should census static map
primitive count/visible-area work against camp before changing visuals.
