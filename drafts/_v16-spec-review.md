# v16 spec review ledger (2026-08-15 — dual council review BEFORE spec commit)

Budget declared: 2 calls, one round, no follow-ups. Reviewers: DeepSeek V3.2
(code-fit/determinism) + GLM-5 (visual design, different aesthetic priors).
Full responses in session; adjudication below. House law: every finding
verified locally before folding — reviewer claims are hypotheses, not facts.

## DeepSeek (code-fit) — 7 findings, adjudicated

1. "Gosu.scale doesn't exist in 1.4.x" — **REFUTED LIVE**:
   `ruby -e "require 'gosu'; Gosu.respond_to?(:scale)"` → true (module
   function, block form). Spec notes the live verification.
2. Captures can't leak window_scale — REFUTED (agrees with spec; harness
   renders at fixed 960×540).
3. Kill-pop nondeterminism under hitstop — UNCERTAIN → **CLOSED BY
   CONSTRUCTION**: world.tick gates on hitstop (verified world.rb:165);
   shards age by sim frame. Spec now says so explicitly.
4. Veil flicker/stick edge cases — **FOLDED**: veil is a pure per-frame
   reader (no stored state); `abort_all_chants!` on transition already
   exists. Superseded by the writ-frame redesign anyway.
5. Inscription-burn ordering vs corpse bookkeeping — **FOLDED**: ordering
   discipline added to sim spec + TDD tests (read inscribed at death
   moment; stable array iteration; no double-consumption).
6. New checks script-dependent — **FOLDED**: varekka_duel re-pilot stages
   an inscribed seized death; manifest gains `inscription_burned >= 1`.
7. Float math in motif placement / invalid palette values — **FOLDED**:
   integer-arithmetic-only placement written into decision 2.

## GLM (visual design) — 6 findings, adjudicated

1. Hue-only shifts at dark values read as "gamma error"; geometry needed —
   **PARTIALLY FOLDED**: zone layout changes are sim-affecting (replay
   blast radius — rejected), but the identity block gains an authored
   `decor` LANDMARK channel (render-only, non-blocking) + wider
   value/saturation spread. Landmark-silhouette identity without touching
   passability.
2. Brazier GOLD conflicts with gold=walkable law — **CONFIRMED, FOLDED**:
   Second Vigil accents are ember orange/red. (Spec's own W5 already
   reserved gold; decision 2 contradicted it — review caught the
   contradiction.)
3. Screen-space scale-in reads "achievement popup" — **FOLDED (hybrid)**:
   located stamps also land a floor SEAL MARK at the event tile; text
   stays in the screen banner (floor text illegible at 32px).
4. Alpha-90 full-screen veil reads as GPU glitch — **FOLDED (redesign)**:
   the WRIT-FRAME — square ritual frame centered on Varekka, outside
   darkened hard, inside fully readable. Better dread AND better fairness.
5. 6 tiny shards invisible; flash is the channel that matters — **FOLDED
   (re-weighted)**: corpse flash 5f solid = primary + check target;
   8 shards 3-4px kept as secondary motion read.
6. "Player avatar is a ghost" — **PARTIALLY REFUTED** (possessed already
   has the white ring + facing notch — reviewer lacked that context) but
   the preservation risk is real → **W6 added**: every identity channel
   is judged against possessed readability; conflicts resolve in the
   ring's favor.

## Net effect

Two design-grade upgrades (writ-frame, floor seal marks), one contradiction
caught (gold), one channel added (landmarks), four hardening folds, two
refutations (one by live API check). The spec that ships is materially
better than the draft — the review earned its budget.
