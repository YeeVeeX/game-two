# Lag P0 — T2 evidence bank (created 2026-08-20, session 24)

Byte-verbatim harvest per `drafts/_lag-probe-runsheet-20260820.md`. One file
per segment per seat; every banked file carries its md5 in this index.
Partial evidence stays partial — nothing here is synthesized.

## Segment status

| Segment | Status | Where the bytes live |
|---|---|---|
| S0-J2 (Junior machine facts) | EXECUTED (his seat, 2026-08-20) | `drafts/_junior-lag-s0j2-machine-facts-20260820.md` |
| S0-J (Junior solo, decisive) | EXECUTED (his seat, 2026-08-20) — prediction MATCHED | `drafts/_junior-s0j-frame-probe-20260820.md`; verbatim line mirrored below |
| S1 (coop baseline, flag ON both seats) | PENDING — owner-paced coop session | to land here as `s1_<seat>.log` + md5 |
| S2 (focus experiment) | PENDING | — |
| S3 (role swap) | PENDING | — |

## S0-J verbatim mirror (source: Junior's draft, committed `9fbad4a`)

```
TELEMETRY frame_probe frames=127506 period{p50=16.8 p90=17.5 p99=42.8 max=1335.1}
  update{p50=0.8 p95=3.4 max=160.7} draw{p50=3.1 p95=7.1 max=355.3}
  over20=8643 over35=2012 over100=72
```

Log named by his seat: `%TEMP%\game_two_session_836781.log` (8030 B, HIS
machine — the raw file was never transferred; the draft is the banked copy).

## S1 harvest checklist (when the owners play)

Both seats launch with `GAME_FRAME_PROBE=1` (host `bin/play es --host`,
Junior per his runbook). After Esc, bank per seat, verbatim:

- `NETPLAY handshake ...` (expect `version 3`)
- `TELEMETRY netplay ...` close line
- `TELEMETRY frame_probe ...`
- `AUDIO drift ...` (last 5 lines suffice)
- `TELEMETRY sustain ...` (silent R-A2 harvest — never prompt the owners)

Junior's lines arrive via his seat's drafts or pasted in chat — verbatim
means verbatim; md5 every banked file into this index.
