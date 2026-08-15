# v15 spec dual review — ledger (2026-08-14)

Artifact under review:
`docs/superpowers/specs/2026-08-14-v15-zone3-challenger-keybinds-design.md`
(pre-commit; folds land in the spec BEFORE the spec commit, per the v13/v14
process).

Order: Codex FIRST (cross-vendor, danger-full-access, smoke-tested file
read), folds applied, THEN the workflow panel (Rule-7 envelope declared
below) over the folded spec.

## Rule-7 envelope (panel leg, declared before launch)

- Budget: ~3.0M output tokens (calibration memory: ~110K/finder +
  ~55K/refuter under the Opus-4.6@1M subagent config; v13 actual ran 3.06M
  over a 2.5M declaration — this declaration absorbs that overrun).
- Cap: 45 agents (finders + refuters + synthesis).
- Convergence: ONE find round (finder pool over declared dimensions) →
  dedup (inline, main loop) → 3 refuters per surviving finding
  (kill at ≥2 refute) → done. No loop-until-dry (spec review, not bug
  hunt; the wall is the empirical gate downstream).
- Done means: every deduped finding carries CONFIRMED/REFUTED + the spec
  folds for CONFIRMED are applied and listed here.

## Codex leg

- Smoke test: PASS (real file read, 476 lines returned; threadId
  01a00224-467f-7ae1-9ef0-a4d4b54cece8).
- Model identity (from rollout file, never the banner):
  `openai.gpt-5.6-sol` on `amazon-bedrock` — the pinned config.
- **Pass 1 (rollout 01a00226-0e1e-…): DIED MID-REVIEW** (session
  restart killed the MCP task after ~5 progress messages; no final
  verdict). Its confirmed findings, all FOLDED into the spec:
  1. **C1 overstated** — non-current zones DO tick drops/corpse-loads/
     expiry-flashes; drop/respawn PRNGs are global streams. Fold:
     W1 restated on the narrow honest basis (an unvisited zone has
     nothing to tick/draw); canary stays the empirical gate.
  2. **slow_door anchor hole** — low_quay's declared anchor protects
     only low_quay; the reverse transition mutates slow_door's arrival
     list and slow_door has no explicit anchor. Fold: slow_door.json
     gains `gradient_anchor` too (both sides of every new edge).
  3. **Manifest law was manual** — rake gate never read manifests
     (double replay + md5 + vision only; v14 manifests were wall-log
     grep obligations). Fold: manifests move into script JSON +
     `harness/manifest_check.rb` + `rake manifest` in the wall
     procedure; 14 scripts back-filled.
  4. **Banner race is live-play real** (not just staging) — ONE STANDS
     could be eaten by the zone banner at first contact. Fold: banner
     slot becomes a small FIFO (`banner_queue_max: 2` display key),
     W6 resolved by building.
  Also sharpened: seized steps route through creature.step's
  windup/active/stagger gates → attacking while seized slows the drag
  (folded as intended depth); flow_to moving-anchor cache confirmed as
  the right machinery (matches self-review).
- Self-review folds applied BEFORE Codex pass 1 (recorded for honesty):
  seizure lifecycle (enter_zone + respawn_pack clear seizures/chants,
  hitstop pauses clocks — the release_taunt! precedent) + ABNT2
  positional-scancode note on the binding map.
- **Pass 2 (threadId 01a00257-998f-…): LANDED — overall REJECT, all
  findings reconciled and folded.** Verbatim verdicts:
  - Q3 lifecycle: **swap-while-seized DEFECT CONFIRMED** (handle_swap
    refuses under stagger/special-commit, world.rb:500-511 —
    re-verified by us line-exact; the ratified "Tab always works" was
    false in today's code) → FOLDED: seized swap exemption, scoped to
    seized-only so law 2's forced-swap stagger hole stays closed.
    Completion-frame death race CONFIRMED → FOLDED (zero-frame seizure
    legal, idempotent exactly-once end). :nest_respawn chant freeze
    CONFIRMED → FOLDED (abort at :nest_respawn entry). Mask
    bookkeeping UNCERTAIN → FOLDED as controller-ordering pin.
    Knockback carry-through CONFIRMED → FOLDED contractual. Abandoned-
    body "no swings" wording REFUTED-as-written → FOLDED ("no NEW
    swings"). Wipe-floor double-end UNCERTAIN → FOLDED (idempotent).
    Damage-free stagger on Varekka REFUTED (impossible today) — no
    fold.
  - Q7 fiction: Varekka REFUTED (legal — phonology, struck-name
    pattern, earned third syllable; no canon collision). Low Quay
    REFUTED (legal attachment). ONE STANDS / THE FLESH IS CALLED
    REFUTED (register-consistent, speak ABOUT not FOR). **THE NAME IS
    STRUCK: CANON VIOLATION CONFIRMED** (ordinary death leaves the
    name with the living, bible §5.2; striking = Registry full liturgy
    or the Maw) → FOLDED: replaced with "THE TERM IS PAID" (mirror of
    THE WAY IS PAID; the term-looter finally pays the term's price) —
    ES "EL PLAZO ESTÁ PAGADO" / PT "O PRAZO ESTÁ PAGO"; owner gets the
    swap flagged explicitly at the debrief (post-ratification change).
  - Q8 biggest risks: **canary-order defect CONFIRMED** (strip change
    before canary = unpassable by construction) → FOLDED: TDD
    reordered, zone first. **bindings.local poisons cross-machine
    comparability** → FOLDED: harness pins canonical bindings
    (locale=en precedent). **world_scene event logger is a HARDCODED
    list** (re-verified: world_scene.rb:24-33) → FOLDED into increment
    6 (add the 5 events). **Keybind functional route missing** →
    FOLDED: Q5 routing gains a functional-bug branch; unit tests are
    the functional coverage.
- Reconciliation note: every CONFIRMED/REFUTED verdict above that
  governs design was re-verified in-repo before folding (handle_swap,
  world_scene list, taunt pattern, flow_to cache, self_gating
  derivation, actor_died pipeline).
- Independent self-verification with line evidence (done while Codex
  ran): Q2 no-respawn pipeline CLEAN (actor_died→leave_corpse+
  spawn_drop+schedule_human_respawn returns-unless-delay; drop 8×4.0
  gradient ≈ 32 at the east landing); Q5 no other hardcoded keys
  (window.rb only + Esc by design; input_test fake is backend-agnostic);
  Q6 self_gating is DERIVED from "pass with why=" in check text
  (vision_critic.py:180) — #47-#49 texts carry it, no Python change.

## Panel leg (run wf_2af3302b-dc6 — LANDED, all folds applied)

- 10/10 finders returned → 45 raw findings → 45 deduped → 3-lens
  refutation (spec-already-handles / evidence-check / materiality,
  kill at ≥2 refute) → **16 CONFIRMED / 29 killed with reasons**.
- **Rule-7 honesty: the declared envelope was BLOWN.** Declared ~3.0M
  tokens / cap 45 agents; actual **8.39M tokens / 145 agents** (10
  finders + 135 refuters; the script enforced no cap and 45 surviving
  findings × 3 lenses outgrew the estimate). Convergence criterion
  held (one round, every finding verdicted, zero agent errors).
  Calibration memory updated: panel growth is driven by FINDING COUNT
  (finders were capped at 8 findings each and hit ~4.5 avg); next
  declaration must budget finders × maxFindings × 3 refuters as the
  agent ceiling, and the script must ENFORCE the declared cap (slice
  the deduped list) instead of hoping.
- CONFIRMED → FOLDED (all 16):
  1-2. [high×2, wall-process] Canary as drafted could not execute —
    `rake gate` rm_rf's `_gate_a/_gate_b` BEFORE capturing
    (Rakefile:67) and only compares its own two fresh runs. FOLD: new
    `rake canary SCRIPT= BASELINE=` task + baseline preservation
    procedure (regenerate at v14 HEAD, copy to `_v15_canary_ref`).
  3. [high, architecture] KEY_TABLE with Gosu constants in src/core/
    breaks the engine-agnostic layer (0 Gosu refs in core today).
    FOLD: table lives in src/app/, INJECTED into BindingMap.
  4. [high, input] Startup raise invisible — both launchers redirect
    stdout+stderr to a temp log; Junior's double-click would
    flash-and-close. FOLD: launchers echo log tail + pause on nonzero
    exit.
  5. [high, fun-verify] Routing deadlock: body-react + seized=0 +
    chants>0 (skilled interrupt play) had no branch. FOLD: TELL
    VALIDATED branch + under-exercised branch.
  6. [med] Banner FIFO entry shape unspecified → FOLD: keys-not-text
    entries {text_key, fallback, color, frames_left} (locale-at-render
    law preserved).
  7. [med] Seize cooldown start ambiguous (4x pacing swing) → FOLD:
    starts at SEIZURE END.
  8. [med] "Blue is virgin" was FALSE — proximity retarget cue is
    pale-blue (180,210,250). FOLD: chant = deep saturated blue
    (60,100,220 family); #48 lists the cue.
  9. [med] #47 "channel void" contradicted slate-bone wall rendering →
    FOLD: DRY channel wording (fiction agrees: the water stopped).
  10. [med] No cross-action key-collision check post-merge → FOLD:
    raise naming key + actions.
  11. [med] Idempotent seizure_ended lacked named tests → FOLD: two
    exactly-once tests named in increment 4.
  12. [med] manifest_check.rb lacked a test file → FOLD:
    test/harness/manifest_check_test.rb, 4 cases.
  13. [low] PT-BR "UM SE ERGUE" = rising, not standing firm → FOLD:
    "UM SE PLANTA".
  14. [low] Spanish question text in a repo artifact violated the
    language law → FOLD: questions rewritten in English,
    Spanish-at-ask directive (twelfth convention).
  15. [low] Increment 5 had no headless test surface → FOLD:
    banner-queue content tests + display-keys test.
  16. [low] (dup of 5, folded together).
- Notable kills (recorded so nobody re-litigates): god-mark/seized
  glyph position collision (spec's "blue not pale-gold" is the
  override), Varekka one-cooldown kill (OPENING numbers + thirteenth
  arbitrates), manifest tee mechanism (wall procedure owns the tee),
  entrainment-series conflation (deliberate, line-cited), FIFO scope
  legality (fold-work precedent).

## Verdict

Dual review COMPLETE: Codex (2 passes, 4+10 findings folded) + panel
(16/45 confirmed, folded). The spec commit carries this ledger's
state; TDD starts at increment 1 (zone + canary).
