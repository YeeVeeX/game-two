# D2 — volley hit-test vs moving bodies: evidence + decision + ship (s66)

**Lane:** v19 Lane 4 rider — "sim hit-test evidence-gated (D2)"
(foundation `drafts/_v19-foundation-20260822.md`). This doc is the
evidence the gate asked for, the decision record, and the ship receipt.

## Evidence

1. **Owner report (live coop S1, 2026-08-24, verbatim es-CR):**
   > "el ataque del botón E/L del lobber aún no hace daño solamente se
   > ve la animación"
2. **Code facts (structural, read s66):** `grid_walker.rb` commits the
   logical tile at step START (`commit_dash`: `@tile_x, @tile_y =
   plan.landing`) while the body tweens 16-17 frames; `volleys.rb`
   resolved impacts by `foe.tile == tile`. A foe visually ON an impact
   tile while tweening off it is logically GONE → whiff with the blast
   drawn on the body. Volley delay (40f) + walking enemies (step ~16f)
   ⇒ the window covers most of a moving foe's time.
3. **Deterministic repro (red test before the fix):**
   `test_resolution_hits_a_foe_mid_step_off_an_impact_tile` — victim
   commits [4,1]→[4,2] mid-delay; old rule: hp untouched (whiff);
   assertion demanded the hit. Failed exactly as reported.

## Decision (owner pick, live in chat s66)

Options put to the owner: (a) global dual-tile occupancy for ALL tile
hit-tests — refused for blast radius (ritual-frozen difficulty would
move everywhere); **(b) volley-scoped occupancy — PICKED** ("vamos por
el volley de una vez"); (c) presentation-only telegraph — rejected as
sole response (verb stays broken).

## What shipped (scope b, exactly)

- `grid_walker.rb`: tracks the departure tile per step/dash;
  `covers?(tx, ty)` = landing from commit + departure while the tween
  flies; settled = exactly its tile. Teleport carries no phantom
  departure. Combat range / collision / AI untouched (still committed
  tile). `creature.rb` deliberately untouched (assets seat re-pinned it
  today — `a41c17b`, mail in done/).
- `volleys.rb`: impact resolution reads `foe.walker.covers?(*tile)`;
  one victim per tile stays law; NEW: one hit per victim per record (a
  body spanning two impact tiles mid-step is struck once — dedup).
- Tests: 4 new volley resolution tests (mid-step hit · finished-leave
  miss · no double-hit · dedup never starves a second tile) + 4 walker
  `covers?` tests (settled/mid-step/teleport/interrupted-dash).

## Verification belt

- volleys 13/13 · grid_walker 9/9 · world 65/65 · state_digest 9/9 ·
  progression_integration 5/5 (digest row shape untouched).
- **Sim identity canary: UNMOVED — 3/3 pass** (the pinned replays never
  stage a mid-step foe on an impact tile at resolve frame). No rebank,
  no ratification owed.
- Rule 2 gate: `world_loop.json` PASS (10 captures byte-identical ×2 +
  vision verdict green). No wall script stages the fixed case yet —
  **the volley-vs-mover wall script rides the varekka re-cut ticket**
  (line 2 = option (a), next session), recorded here so it isn't lost.

## Balance note (measurement hygiene)

No number moved: damage, distances, delay, exhaust all untouched. The
change makes the special LAND where the eye already says it should —
completing designed intent (35 dmg / 720f exhaust was never meant to
whiff structurally). Progression-pacing / difficulty freezes for the
EIGHTEENTH remain virgin.
