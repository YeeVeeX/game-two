# v14 spec adversarial review ledger (2026-08-14, local by design)

Spec: docs/superpowers/specs/2026-08-14-v14-legibility-design.md
Two legs, both completed BEFORE the spec commit (v13 order kept: Codex
first, fold immediately, panel reads the folded spec).

## Leg 1 — Codex cross-vendor (thread 01a00081-6521-79b1-a646-9556a868caa0)

Self-report "GPT-5 Codex @ high" (self-reports are family-level only —
registration pins openai.gpt-5.6-sol @ max on Bedrock; rollout file is the
identity authority). Overall **REJECT** with 4 REFUTED — every refutation
re-verified in-repo before folding; all folded:

1. **Q3 — pinned-tile starvation / player spawn suppression.** Today's
   defer-recompute can escape a camper via re-anchoring; a pure pin never
   re-rolls → permanent single-spawn suppression. FOLD (W5): materialize-
   defer holds ≤ `telegraph_defer_unpin_frames` (240, NEW threat key —
   recorded deviation from the plan's single-key claim), then unpins to
   today's recompute path. Also softened "byte-for-byte" → "today's
   semantics" (pin retries consume respawn-stream draws; tile values ride
   the new stream, W1).
2. **Q6 — my draft #19 amendment WEAKENED the check** ("nowhere else on
   the HUD" → "HUD bar area" would legalize a duplicate numeral in the
   strip). FOLD: assertion stays global; the parenthetical only
   classifies the strip and explicitly keeps a strip numeral a violation.
3. **Q8 — `first_special=0` sentinel collides with a frame-0 cast** (World
   starts at frame 0). FOLD: literal `never` sentinel in the v14 line
   (arc.first_frame keeps its legacy 0-sentinel for comparability —
   defect not inherited, not retrofitted).
4. **Q9 — vat_economy's tribute beat is ALREADY DEAD at HEAD.** VERIFIED:
   tmp/wall/vat_economy_v13_a1.log shows `tributes=0
   banked_spent{tribute=0}` in both gate replays while the v13 wall
   passed it ("did not bite" — that note was WRONG; the critic
   self-gated tribute_beat_reads). FOLD: vat_economy = pre-known
   re-pilot; and the STRUCTURAL fold below.
5. **Q10 (biggest-unthought risk) — the gate can green-light an absent
   headline feature**: vision_critic.py FORCES self-gating checks to
   pass, so respawn_telegraph.json could capture zero tells and still
   pass #46. FOLD: machine-checked mandatory-beat triage law — per-script
   EVENT manifests grepped from teed logs; missing staged event =
   re-pilot regardless of critic verdict; the dedicated script demands
   ≥2 `:respawn_telegraphed` + a non-self-gated #46 citation. (This is
   the memory `cross-vendor-catches-semantic-honesty` firing again — the
   Codex leg stays mandatory.)

Smaller folds: `respawn_tells` must use non-autovivifying `fetch`
(corpse_loads pure-reader law — the renderer would otherwise insert sim
keys); edge pips draw AFTER the strip (their clamp lands inside the strip
band; ally pips stay visible). CONFIRMED (evidence): Q1 RNG isolation
(only spawn_drop + scatter_pick consume @rng); Q2 pulse-as-sim-state
determinism (EventBus FIFO, captures in update()); Q4 Gosu z stable_sort
= call-order ties (gem source); Q5 kits/bindings/respawn 300; Q7 strings
wiring both paths.

## Leg 2 — Workflow panel wf_80a86046-6e8 (4 lenses → 3-refuter panels)

Envelope declared BEFORE launch (Rule 7): ~2.2-3.1M tokens, cap 45
agents, convergence = one find round + one refute round (v13 actual:
3.06M/52 — calibration memory applied).

RESULT: **0 raw findings across all 4 lenses** (determinism / sim /
presentation / process) — every finder did real work (100-110K tokens,
16-51 tool calls each, repo + spec reads; "empty list is a valid result"
was explicit in the prompt) and each returned clean. The refute round
never spawned. ACTUAL: 421K tokens / 4 agents — the envelope budgeted
for a findings×refuters tail that didn't materialize. Reading: the
Codex-first ordering (fold before the panel reads) converged this time
to full validation — v13's panel found 16 raw because it read a spec
with fewer folds pre-applied. The cross-vendor leg remains the one that
catches (5 folds here, incl. one live semantic-desync in the SHIPPED
wall: vat_economy tributes=0).

## Order of operations that worked (keep)

Codex leg FIRST, fold immediately, THEN the same-family panel reads the
folded spec. Two cycles of evidence now: the panel validates folds
instead of re-finding them; Codex catches what same-family finders miss
(memory cross-vendor-catches-semantic-honesty — fired AGAIN here on
vat_economy's dead tribute beat).
