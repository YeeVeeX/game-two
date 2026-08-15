# v13 spec adversarial review ledger (2026-08-14, local by design)

Spec: docs/superpowers/specs/2026-08-14-v13-aoe-specials-design.md
Two legs, both completed BEFORE the spec commit:

## Leg 1 — Codex cross-vendor (GPT-5.6 Sol @ max, Bedrock; thread 019fff2c-7eb1-7632-b915-189c8e468625)

Overall REJECT with 4 real catches, ALL FOLDED into the spec:
1. C2/Q2: refund hook — normal completion runs through interrupt_action!
   which clears @hit_victims; take_hit clears earlier. FOLD: refund at
   the active→recovery transition; interrupted spin refunds nothing.
2. C3/Q3 (three plumbing defects): JSON cause arrives as String
   (telemetry wants Symbols); cue stamping (world.rb:404) + cue palette
   (renderer.rb:62) exclude :challenged; renderer.rb:442 dereferences
   the renamed [:taunt] key. FOLD: "Plumbing folds" subsection, TDD inc 3.
3. Q6: challenge × engaged_cap_per_target=5 — excess attackers park in
   the passive pressure ring; whirlwind can farm the passive ring.
   FOLD: watched risk pre-registered, lever order exhaust→duration→radius,
   never the engaged cap; exhaust stays 600 (one-variable law).
4. Q7 (the miss): naive guard-steering oscillates against leash_home
   (steered human walks straight back to a home near the corpse).
   FOLD: REDESIGN — shifted leash-home destination outside the guard
   radius while the corpse exists; no per-tick steering.
Also: C5 byte-identity claim softened (same strings, not same PNGs);
C6 taunt_anchor upgraded to CERTAIN (pulse image at radius 9); C7
two-sided dose risk (cheaper tribute could raise trip frequency) →
gap_s arbiter added to Q5 routing.

## Leg 2 — Workflow wf_a23c3531-030 (4 lenses → 3-refuter panels)

Envelope declared: ~2.5M tokens / cap 40 agents. ACTUAL: 3.06M / 52
agents (16 deduped findings × 3 refuters outgrew the estimate ~22% —
recorded for the next calibration; memory workflow-review-token-calibration
still underquotes panel growth).

- 16 deduped findings → **1 CONFIRMED (2/3)**: check 14
  `specials_distinct` requires "Striker as a bright through-lane" and
  "three effects must not look like one" — the whirlwind rendering via
  the ring-else branch would be visually identical to the blocker ring
  (same SPECIAL_ACTIVE color, same 8-tile pattern). DOUBLE FOLD:
  (a) whirlwind renders in LUNGE_ACTIVE (striker's bright), presentation
  spec updated; (b) check 14 striker clause updates "through-lane" →
  "bright ring burst" (ADD-ONLY = never weaken, c361ba3 precedent),
  owner ratifies at the eleventh debrief.
- 15 killed with evidence — 11 were "spec already handles" (the Codex
  folds landed before the refuters read: right ordering), 2 fabricated
  quotes, 2 factual-but-no-rework (EVENTS count 34 not 28 — fixed in
  the spec anyway for honesty).

## Order of operations that worked (keep)

Codex leg FIRST, fold immediately, THEN the same-family panel reads the
folded spec — the panel then validates the folds instead of re-finding
them, and its unique catch (render identity) was one Codex missed.
Cross-vendor + cross-check remains mandatory (memory
cross-vendor-catches-semantic-honesty).
