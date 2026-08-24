# Flywheel verify — world_loop critique vs code + exact frames (s62, 2026-08-24)

Standing-program rung (quality flywheel, owner-directed 2026-08-19).
Clip: `captures/clips/world_loop_20260824-051415.mp4` (625 frames,
every=2, seed 42, run on the s62 working tree = origin `f16e275` +
the staged J7-B set — world_loop was one of s59's 24/25 byte-identical
streams, so the clip represents both trees). Critique:
`drafts/_self-eval/clip_world_loop_20260824-051415_critique.md`
(2 batches, 37/625 frames after phash dedup ≈ 6% sampling).

**Sampling-artifact law applied:** every claim below was verified
against code (file:line) + exact PNGs (`tmp/clip_world_loop_20260824-051415/video/v_NNNNNN.png`,
v = t×30). Verdicts: REFUTED (feedback exists, sampling missed it) ·
CONFIRMED (real, banked) · ROUTED (lane-owned / ritual-frozen).
Zero code/data changes this session (ratification-neutral law: any
`rake gate` run appends to staged `drafts/_gate-verdicts.log`).

## Refuted claims (the feedback exists — phash dedup + 0.14s+ gaps ate 2-8-frame beats)

1. **"Attacks are invisible" — REFUTED.** Pack: windup/active strike
   tiles + body lunge (renderer.rb:714-752, `lunge_offset` -3/+6px).
   Hostiles: `draw_enemy_strike` own pass (renderer.rb:110-118, the
   2026-08-19 flywheel fix — LIVE) + pre-strike telegraph flare
   (edge+core+body, renderer.rb:662-668). Frame proof: v_000230
   (t=7.67, 0.13s before the critic's sampled 7.80) shows a full 3×3
   enemy strike-tile pattern ON the possessed; v_000404 shows two
   simultaneous telegraph flares. The critic's neighbor frame missed
   the active window; claim held only under sampling.
2. **"Deaths are despawns" — REFUTED.** `kill_pop!` at victim tile
   (world.rb:1580), 14 sim frames (combat.json pop_frames), 5-frame
   white flash + shard scatter (renderer.rb:885-900, display.json
   kill_pop_*), plus persistent corpses + drops. `kill_pop_reads` is
   a STANDING wall check row (gate critic verifies every sweep). The
   critique's cited kills (t≈11.4, 13.1-13.8) were bottom-viewport-
   clipped companion kills or inter-sample — XP sliver jumps confirm
   kill timing between sampled frames.
3. **"Player damage has no on-field feedback; red vignette fires on
   attack (inverted convention)" — REFUTED both halves.** Damage-taken
   feedback: crimson edge vignette while `hurt?` (renderer.rb:1093-1113,
   8-sim-frame window), body crimson flicker (body_color :690-698),
   `shake_player_hit` (feel.rb:32). Frame proof: v_000230 carries the
   full edge vignette DURING the enemy strike. The t=13.77 "red flash
   on spin" (v_000413): the ring burst is the striker special's
   LUNGE_ACTIVE tile family; the red screen edges in the same frame
   are the hurt vignette CO-FIRING because the possessed took a hit
   mid-spin inside the cluster — semantics are correct (red = damage
   taken), the critic conflated two simultaneous events.
4. **"Damage numbers near-invisible / possibly not firing" — REFUTED
   (category error).** No damage-number system exists. The "tiny
   dark-purple digits" are STATION LEDGER balances over station tiles
   (draw_station_ledger renderer.rb:530+): v_000587 bank shows carried
   -8 debt context; v_000620 shows the bank flipped to "2" after the
   deposit. A damage-number system would be a NEW design decision
   (v19 Lane 4 material), not a fix.
5. **"Telegraph possibly <0.4s, undodgeable" — REFUTED by data.**
   threat.json `telegraph_frames: 120` = 2.0s windup (6-9 tile-steps
   at 13-19f/step). Static telegraph frames phash-dedup into 1-2 kept
   samples — the critic saw only its tail.
6. **"Pickup toasts sit dead-center 4+ seconds" — REFUTED on both
   numbers.** The card is the fight-ledger beat (renderer.rb:1115+),
   150 frames = 2.5s (ledger.json), block y=160 (upper third, not
   center), pop-in + final-third fade, `ledger_beat_reads` wall-gated.
   The critic's 4.3s window spans TWO consecutive beats (drop pickup
   → bank deposit) plus the ZONE 1 banner — each surface individually
   bounded by design.
7. **"Player blind to off-screen companion HP pressure" — REFUTED as
   stated.** All three pack HP bars render permanently top-left
   (draw_hud renderer.rb:937+); off-screen allies show kit-colored
   edge pips clamped toward true position (draw_edge_pips :980-993,
   visible v_000000 right edge / v_000230-234 left edge). Residual
   nugget banked below (B).

## Confirmed — banked candidates (no code this session)

- **A. Hostile/floor palette adjacency (bone-white enemies beside tan
  platforms).** Real perceptual observation: v_000404 [685,330] enemy
  half-reads as terrain against the platform band. Candidate: push
  hostile body color out of the floor band. Cost when landed:
  display.json is assets-repo PINNED (re-pin mail owed) + Rule 2 gate
  + full-wall recalibration — bank for the assets-era
  silhouette/palette pass (the critique's own asset-lane #2), or a
  single placeholder-era display.json move on owner word.
- **B. Edge pips carry position but no HP state.** Small Lane-4
  presentation candidate (a 2px HP tick under the pip). Low priority:
  the permanent HUD bars already carry pack HP; the pip's job is
  direction. Bank only.
- **C. Asset-era leverage list** (critique §asset-era: wind-up frames,
  silhouettes, death burst, hit bundle, telegraph fill, number
  restyle, pip art, pickup icons) — genuinely aligned with the parked
  assets lane; carried as-is for game-two-assets era planning.

## Routed (not actionable now — lane/ritual ownership)

- **D. "Enemy passivity" + "one-spin cluster clears" + approach/aggro
  pacing** → difficulty/threat numbers (threat.json families) are
  EIGHTEENTH-ritual-scoped (progression pacing / difficulty freeze at
  spec staging; measurement hygiene law) AND v19 Lane 2/3 territory.
  Recorded verbatim, zero knob moves. Note the frames themselves
  show the cluster died progressively across v_394-413 (allies +
  basics + spin), not to one input — the one-button read was itself
  partly a sampling artifact.

## Verified-good (keep, amplify — matches critique's keep-list)

Telegraph language (flare + 3×3 strike tiles + 2s windup) · possession
swap legibility (ring + HUD rewrite) · traversal/transition fluidity
(7/10 from the critic — highest score) · XP sliver + carried counter
ticks · station ledger loop (deposit beat + balance flip, v_620) ·
respawn tells (green frame, v_000416 top-right) · banner FIFO.

## Next-clip re-check list (trimmed to the REAL items)

1. If A lands: hostile body separable from floor band at a glance in
   the same district frames.
2. If B lands: pip HP tick readable at v_000230-class moments.
3. Ritual-post: re-run this exact script; the D observations
   (approach pacing, cluster kill cadence) become measurable against
   whatever the verdict unfreezes.

## Meta (flywheel calibration, carried forward)

The critic re-flagged FIVE surfaces that exist and are wall-gated
(kill pops, hurt vignette, enemy strikes, ledger beat, edge pips) —
all shipped as fixes from the FIRST critique (low_quay 08-19) or
earlier. At 37/625 frames, 2-8-frame beats are statistically
invisible and phash dedup specifically deletes static-surface dwell
(telegraphs, toasts). Standing calibration for future clip verdicts:
severity-major claims about ABSENT feedback are presumed sampling
artifacts until frame-verified; claims about DURATION/PACING need
data-file cites; the critique's value concentrates in perceptual
adjacency reads (A) and keep-lists, which sampling cannot fake.
