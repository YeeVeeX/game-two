# Lag P0 — T3 forensics verdict (2026-08-20, session 24)

Written from BANKED evidence only: Junior's S0-J draft (`_junior-s0j-frame-probe-20260820.md`,
commit `9fbad4a`), his machine facts (`_junior-lag-s0j2-machine-facts-20260820.md`),
the T2 runsheet's recorded ritual forensics (`_lag-probe-runsheet-20260820.md`
§"What is already known"), and the v18 verdict's owner-named blocker. S1/S2/S3
have NOT run — every claim below names its segment; the pending segments
CONFIRM or REFINE, they do not gate this verdict's core answer.

## 1. S0-J prediction: MATCHED (said explicitly)

Pre-registered (runsheet §S0-J2, commit `638fa68`): period p50 ≈ 16.9 ms
(59 Hz ceiling) with a ~33.9 ms vsync-miss mode. Measured (his seat, solo,
`GAME_FRAME_PROBE=1`, 127,506 frames):

```
TELEMETRY frame_probe frames=127506 period{p50=16.8 p90=17.5 p99=42.8 max=1335.1}
  update{p50=0.8 p95=3.4 max=160.7} draw{p50=3.1 p95=7.1 max=355.3}
  over20=8643 over35=2012 over100=72
```

p50 error 0.15 ms against the 59 Hz prediction; the miss-mode showed as a
tail (p99 42.8, over35=2012) rather than a clean 33.9 bimode — matched in
form, refined in shape.

## 2. WHO limited the lockstep: Junior's seat, structurally

- His machine ALONE averages ~53.5 Hz with zero netplay: 59 Hz vsync ceiling
  minus a 6.8% long-frame tail (over20 = 8643/127506 = 6.8%; 1.6% > 35 ms;
  72 frames > 100 ms). This is the S0-J decisive answer.
- Ritual forensics already showed the joiner pacing both sessions at ~53.5 Hz
  while the host ran ~60.5 and waited (banked counter arithmetic +
  independent AUDIO drift oracles, 0.05% agreement).
- His network path measured GOOD from his own seat's probes (direct route,
  easy NAT) — the network is not the limiter.
- Gabriel's machine runs 60.7–61.2 tps solo, rock-steady (runsheet, recorded).

**Verdict: in lockstep the slower seat paces both; the pacing seat is
Junior's, and the cause is machine-structural (display + tail), not link,
not config, not hosting duties.** S3 (role swap) would confirm direction by
flipping roles — expected outcome: asymmetry does NOT flip.

## 3. WHAT eats its frame

- NOT saturation: update p50 0.8 ms + draw p50 3.1 ms ≈ 3.9 ms of work in a
  16.8 ms period — the loop idles ~77% of the median frame waiting on the
  59 Hz swap.
- The average is eaten by (a) the structural 59 Hz ceiling (−1.7% vs the
  60 tps target) and (b) the 6.8% long-frame tail.
- The tail is IN-PROCESS: draw max 355 ms and update max 160 ms inside a
  1,335 ms worst period — second-class stalls born in the client process on
  2011-era HD Graphics 3000, corroborating the host-side forensic record of
  0.8–3.3 s waits from the other end of the wire.

**Spike-class verdict: in-process (draw-dominant), client-side, on the
limited seat.** S2 (focus experiment) still owes the "worse when one seat is
backgrounded" correlate — that refinement stays open, it does not change the
class.

## 4. ONE T4 ticket (named, NOT implemented — spark law)

**T4: vsync-release experiment on the limited seat.** Env-gated, default
OFF, machine-local, zero sim/law change: let the app request swap-interval 0
(no vsync) so the loop paces on Gosu's own update interval instead of the
59 Hz display, then re-run S0-J on Junior's machine with the flag ON and
compare frame_probe lines (success = period p50 ≈ 16.7 with the ceiling
gone; the tail is expressly OUT of this ticket's scope). Rationale: it is
the cheapest reversible intervention that attacks the structural half of the
measured loss; the tick-locked timebase law is untouched (one update = one
tick, unchanged); tearing risk is why it ships env-gated for A/B listening.
The 6.8% tail (draw spikes) is a SEPARATE later ticket only if the owners
still feel lag after the ceiling experiment — never both levers at once.

## 5. Open segments (never nag; owner-paced)

S1 (coop baseline, flag ON both seats — doubles as the next coop playtest),
S2 (focus), S3 (role swap + save-md5 guard). Harvest checklist:
`drafts/_lag-t2-evidence/README.md`. Both seats must pull `f5b4356`+ before
the coop session — protocol v3 refuses mixed builds NAMED (designed failure).
