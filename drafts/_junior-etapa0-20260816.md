# Etapa 0 — sim-identity re-run at the PLACEHOLDER line (2026-08-16, Junior seat)

The owner checkpoint's explicit ask: the strict spike "must re-run
against THIS line before it counts (v17 debate item)". The de-lore
(`7cfd10d`) was a comparability reset; the digests below re-run the
db2e83e recipe on Junior's machine at the CURRENT line.

## Build + machine

- junior-tibia HEAD `7ad0144` (post-ratification; sim surface identical
  to the placeholder-wall line `0b3c5d8` — `git diff 0b3c5d8..HEAD --
  src data harness bin` is empty; diff vs the spike line `f68d7cb` is
  render/banner-only by inspection)
- Windows 10 Enterprise LTSC 2021, ruby 3.4.10 +PRISM [x64-mingw-ucrt]
  (exact pin match), gosu 1.4.6
- Suite at this line on this machine: 527 runs / 2329 assertions /
  0 failures (matches the owner-seat count)

## Recipe (unchanged from the SPIKE CLOSED protocol, db2e83e)

Two runs per script (A==B proves the instrument), stderr excluded,
each run ends `REPLAY_DONE`:

```
bundle exec rake capture SCRIPT=harness/scripts/<s>.json > tmp/etapa0-20260816/<s>_ev{A,B}.log 2>/dev/null
grep '^EVENT ' <log> | tr -d '\r' | md5sum
```

## Results — 3/3 IDENTICAL to the published spike digests

| script | EVENT lines | run A == run B | vs spike (`f68d7cb`) |
|---|---|---|---|
| world_loop | 70 | `a4150c43669b9783e59cb6c39c322b67` | IDENTICAL |
| varekka_duel | 220 | `22dbad126c73753952574ff450e3419b` | IDENTICAL |
| burn_duel | 185 | `d148b8386001cdc8da44fe8472e46c72` | IDENTICAL |

TELEMETRY blocks: diff-clean against the published blocks in
`_junior-etapa0-20260815.md` (12 lines per script, byte-for-byte).

Also at this line, on this machine (2026-08-16): `SKIP_CRITIC=1 rake
gate` PASS on world_loop (10 captures byte-identical), low_quay_run
(11), varekka_duel (5); placeholder surfaces render correctly by eye
(ZONE 2 banner, player 1/2 strip labels, +2 bank stamp — world_loop
gate frames 0300/1248).

## Conclusion

The de-lore is PROVEN sim-invisible on this seat, not inferred: same
seed+inputs at the placeholder line reproduce the exact EVENT streams
the SPIKE CLOSED verdict banked. The stage-1 cross-machine determinism
evidence for v17 trigger #1 now stands ON the line that ships. Raw
logs retained at `tmp/etapa0-20260816/` (gitignored, audit trail).
