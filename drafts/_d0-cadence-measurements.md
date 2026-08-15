# D0 cadence measurements (2026-08-10, measured live — do not re-derive)

Method: path lengths via the sim's own `Game::FlowField` BFS (8-way) on the real zone JSONs;
seconds = tiles x step_frames / 60. Verified against a live-sim tap-step run for the nest leg
(198f measured vs 15 tiles x 13f = 195f predicted — tween quantization accounts for the delta).

## Geometry

- Nest: pack spawn [14,8] -> gate [29,8] = 15 tiles. Arrival tile [28,8] -> center = 14 tiles.
- District arrival: [1,13] (gate at [0,13] on row-13 corridor).

## District gate -> rusher spawns (tiles / striker 13f / blocker 19f)

| spawn | tiles | striker | blocker |
|---|---|---|---|
| [10,12] near | 9 | 2.0s | 2.8s |
| [20,6] | 22 | 4.8s | 7.0s |
| [18,24] | 22 | 4.8s | 7.0s |
| [30,18] | 31 | 6.7s | 9.8s |
| [35,5] far | 37 | 8.0s | 11.7s |
| far corner [42,24] | 45 | 9.8s | 14.2s |

## Bank round trips (spawn -> district gate -> nest center -> back)

- Nearest spawn [10,12]: 48 tiles = **10.4s striker / 15.2s blocker**
- Deepest spawn [35,5]: 104 tiles = **22.5s striker / 32.9s blocker**

## Verdict (challenge 2 of the D0 handoff)

Banking is NOT trivial at current map scale. 10-22s+ one-decision round trips vs a 300f (5s)
rusher respawn means the walk back re-crosses live pressure; the 9->45-tile spawn spread gives
a real depth-vs-risk gradient. D0 proceeds at current map scale. The A3-before-D1 question
stays open for the fun-verify: telemetry (frames between bank events) decides, not this table.

Caveat recorded honestly: these are unopposed straight-line walks. Under combat (surround,
knockback, forced swaps) real cadence is longer, never shorter — the floor is what matters
and the floor is already non-trivial.
