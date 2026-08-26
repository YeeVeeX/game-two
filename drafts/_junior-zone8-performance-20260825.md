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
