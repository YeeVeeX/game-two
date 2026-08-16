# Junior-seat cross-machine counterpart — the seat-plumbing line (2026-08-16)

The owner's wall canary proved increment 2 (seat plumbing, `a367586`)
byte-identical to the pre-refactor baselines ON HIS MACHINE. Lockstep
rides on TWO machines producing the same sim — this is the second
machine's counterpart, run at `f2430f5` (increments 1-3 line).

## Headless path (the increment-1 digest lane, cross-machine)

`bundle exec rake` on Junior's machine: **569 runs / 9019 assertions /
0 failures** — count-identical to the owner seat's hook run. That
includes the THREE banked etapa-0 sim-identity canaries
(`test/harness/sim_identity_canary_test.rb`) passing here: the
`Net::EventSerial` extraction reproduces the banked EVENT streams on
a machine it was never written on.

## Live-window path (etapa-0 recipe, db2e83e protocol)

Two runs per script, real Gosu window/GL, stderr excluded, all six
`REPLAY_DONE`; digests vs the banked spike values:

| script | EVENT lines | run A == run B | vs banked |
|---|---|---|---|
| world_loop | 70 | `a4150c43669b9783e59cb6c39c322b67` | IDENTICAL |
| varekka_duel | 220 | `22dbad126c73753952574ff450e3419b` | IDENTICAL |
| burn_duel | 185 | `d148b8386001cdc8da44fe8472e46c72` | IDENTICAL |

PNG-level determinism at the same line (`SKIP_CRITIC=1 rake gate`):
world_loop 10, varekka_duel 5, burn_duel 6 captures byte-identical
across double replays. Raw logs: `tmp/etapa0-seatline/` (gitignored).

## Meaning for v17

The seat-plumbing refactor is sim-invisible on the second machine too —
live GL path included. First cross-machine identity signal ON the
netplay substrate line: when increment 5's fingerprint handshake lands,
both seats at this line already reproduce the same sim, so a future
desync artifact points at the netplay layer, not at machine skew.
