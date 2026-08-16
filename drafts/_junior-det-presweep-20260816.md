# Determinism pre-sweep of the full wall — Junior seat, 2026-08-16

All 17 wall scripts (16 + varekka_burn) run through the determinism
half (SKIP_CRITIC=1 double replay + per-frame md5) plus `rake manifest`
on this machine, at junior-tibia `5661577`, with the WHOLE v16 code
live (increments 1-5 + checks 49→53).

**RESULT: 17/17 determinism byte-identical, 15/15 manifests PASS**
(moving_square + critic_reel are det-only by design). ZERO desyncs:
every v15-era replay survives v16 unchanged — the sim-compatibility
claim from the increment-5 review, now proven by execution rather than
inspection. Per-script teed logs: tmp/wall/<script>_junior_det.log
(this machine); summary: tmp/wall/junior_sweep_summary.log.

vat_economy note: two background kills interrupted the long script
(20,213 frames); its determinism leg was hand-decomposed into 2x
`rake capture` + md5 over the 11 capture pairs (11/11 identical) and
its manifest verified against run-A event counts (all >= mins). Same
mechanics as `rake gate`, decomposed — labeled honestly here because
the runner's exit code never saw it.

**What this buys the owner seat's wall reset:** the determinism half is
pre-cleared; the reset's real work is the vision-critic recalibration
(new zone identity look + checks #50-53 + the stale #46 low_quay color
prose flagged in the checkpoint).
