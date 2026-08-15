# A0.5 spec — dual adversarial review reconciliation (2026-08-09, in progress)

Codex verdict: **REJECT (not implementation-ready)** — 8 findings. Fable 5 @ max review
IN FLIGHT at write time. This file banks Codex's findings + my own code verification so the
fold survives a compact. Fold target: the spec itself, revision in place.

## Codex findings, my verification, and dispositions (draft until Fable lands)

**F1 (Q1) Shared attack_state does NOT compose cleanly — VERIFIED.**
`advance_attack_state` hardcodes `@kit[:attack][:active_frames]`; `attack_can_hit?` is one
boolean per swing; `World#resolve_attacks` always reads `attacker.kit[:attack][:damage]` and
`[:arc]`. A special riding the same state machine would resolve as a basic attack and could
hit only ONE victim total (Slam needs 8). → Spec must specify a generalized `current_action`
(kind: :attack | :special) with action-owned frame data + per-victim hit registry;
resolve_attacks reads the ACTION's numbers, not kit[:attack]. ACCEPT.

**F2 (Q2) Volley absolute impact_frame breaks under hitstop — VERIFIED.**
`World#tick` hitstop path: `@feel.tick; @bus.process; @frame += 1; return` — sim frozen,
frame counter advances. Absolute impact_frame + `==` skips; `>=` fires early in sim time.
Projectile precedent: countdown decremented only inside tick_world (paused correctly).
→ Volley impacts carry `frames_left` decremented in tick_world (a tick_impacts step in the
tick order, before resolve_attacks), and keep a live `owner` reference (needed for take_hit
attribution, kill credit, hitstop check). ACCEPT.

**F3 (Q3) Mark changes WHEN, not just WHO — VERIFIED (spec text was wrong).**
AiController gates engage on aggro_tiles; override bypasses that gate and disables follow.
No leash/timeout = allies parked indefinitely by a surviving distant target; unreachable
target = flow field returns no step (stand still). → Mark gets a leash: valid only while
target is within `mark_leash_tiles` (hypothesis 14) of the POSSESSED; outside → mark clears
(allies revert to follow). Honest spec text: mark overrides target SELECTION and the aggro
gate inside the leash. ACCEPT.

**F4 (Q4) Lunge "reuses commit_through" is false as stated — VERIFIED.**
commit_through returns boolean, records only furthest-free landing, no crossed-tile list;
diagonal cost ×sqrt(2); i-frames live in dodge (which requires idle attack_state + burns
dodge cooldown — Lunge must NOT double-dip). → GridWalker gains ONE authoritative
`plan_dash(dx, dy, max_tiles, blocked, through:)` returning {landing, crossed, tiles} used
by BOTH dodge and Lunge (single scan = no divergence); Lunge i-frames granted by the special
action itself (creature-owned timer, same @iframes field), dodge cooldown untouched. ACCEPT.

**F5 (Q5) Numbers don't make Slam special; triple-cast burst-then-drought — PARTIAL ACCEPT.**
Slam 30 vs blocker basic 25: not a special by damage — but Slam's identity is CONTROL
(8-tile knockback+stagger), so raise stagger to sell it (30f -> 45f hypothesis) and leave
damage; identity over DPS. Lunge 50 one-shot confirmed good. Volley 35: geometry concern
(40f delay vs 16f rusher step = targets move 2.5 tiles before impact) — Volley aims where
humans WILL be only if cast reactively; sell it as area denial on the surround ring
(rushers converging ON the pack walk INTO it). Keep numbers as hypotheses, note the
geometry risk in spec, let fun-verify judge. Burst-then-drought: see F8 — the provenance
law also rate-limits the triple-cast; additionally swap_stagger stays 0 for voluntary
(A0 spec knob exists if degenerate).

**F6 (Q6) Semicolon layout risk — VERIFIED KB_SEMICOLON exists; keep L/E + ;/Q (Q already
the alternate), note rebindability is data-driven via BINDINGS map. ACCEPT (minor).**

**F7 (Q7) Mark is NOT the riskiest-cheapest probe — ACCEPT.**
Mark normally exercises nothing (allies follow within 2 tiles of possessed; mark_range 6;
ally aggro 10 — marked targets usually already in aggro). The REAL risky item is the
generalized action spine (F1). → Build order flips: 1. action spine + Slam (the probe),
2. Lunge, 3. Volley, 4. mark (with leash), 5. harness/HUD closes.

**F8 (Q8, the miss) Action provenance across voluntary swaps — ACCEPT, needs a LAW.**
Spec encourages cast->Tab but only specifies forced-swap cancellation. A special mid-windup
left behind by a voluntary Tab becomes an ally action (hitstop attribution flips, camera
leaves, feel goes weightless; "last damaged" for mark also contaminated).
→ New law: **a voluntary Tab is REFUSED while the possessed is mid-special (windup/active)**
— mirrors the stagger-refusal precedent (handle_swap already refuses while staggered).
Recovery frames don't block. This makes cast->swap a commitment beat (cast COMPLETES, then
you swap), kills the off-camera weightless case, keeps the chain rhythm (windup is 6-12f),
and answers F5's five-tick triple-cast (each cast must finish its windup+active before Tab).
Forced swap still cancels (death costs the cast).

## Verified-clean (Codex confirmed, no change)
- Surround slots + retreat_step structurally unaffected by mark.
- Zone-transition clearing synchronous in enter_zone = sufficient.
- BINDINGS map accepts arbitrary key arrays; window.rb 59 lines, renderer 222 (room ok).

## Fable-side review (agent stalled TWICE at stream level — lanes completed by the main
## session per the workflow-failure ladder; all findings code-verified directly)

**FA (fun thesis) Synchronized 600f cooldowns = rotation homework — ACCEPT, redesign.**
After a chain, all three specials return simultaneously → optimal play is the same
L-Tab-L-Tab-L block every 10s. Fix: STAGGERED exhausts — Lunge 480f / Slam 600f /
Volley 720f (hypotheses). The chain never fully re-synchronizes, "which special is up"
becomes situational, and shorter-exhaust-on-faster-kit reinforces kit identity.

**FB (wipe/revive) Spec silent on special clock at revive!; mark/impacts across wipe —
ACCEPT.** `Creature#revive!` resets exhaust/iframes/stagger/dodge_cooldown — the special
clock must join that list (reset to READY: wipe already costs the run; nobody wipes to
refresh a 10s cooldown). `respawn_pack` calls `enter_zone`, and `enter_zone` already
resets `@projectiles` — ONE hook point clears Volley impacts + mark for BOTH transition
and wipe. Verified real; spec must name it.

**FC (harness/input wiring) GOOD NEWS — verified: core/input.rb needs ZERO changes**
(ScriptedInput symbolizes arbitrary action strings; expand_script passes them through;
replay_runner untouched). Files that DO change: window.rb BINDINGS (+2 lines, 59→61,
cap safe), controllers.rb (ACTIONS + EDGE_TRIGGERED + tick wiring), creature.rb,
world.rb, renderer.rb, combat.json. Mark wiring: PossessedController#tick already
receives a `view` param (currently `_view`, unused — tests pass nil) → mark flows
through `view.set_mark`, guard on view presence.

**FD (renderer bill) ~+70 lines → renderer ~290 (no cap on renderer; window.rb cap
safe). Visual channel for Volley telegraph: pack-orange tile marker (danger-to-HUMANS),
distinct from human telegraph (red/yellow) and gate gold by hue family — legible at
existing tile scale (critic already discriminates same-size telegraph).**

**FE (AI-vs-special) Slam stagger does NOT stop an in-flight windup — VERIFIED HOLE.**
`stagger!` blocks NEW verbs only; `advance_attack_state` keeps running and rusher
`interrupt_on_hit: false` means the telegraphed hit lands THROUGH the Slam. That
half-falsifies Slam's control identity. Fix (design call): Slam explicitly interrupts
windups (attack_state → idle) on every human hit, overriding interrupt_on_hit — that
override is the special's identity. Knockback-onto-spawn-tile safe (respawn defers on
occupied). Surround slots rebuilt per tick — safe.

**FF (determinism fine-grain) Slam multi-victim: resolve in RING order; victim N's
knockback changes victim N+1's blocked list — order-dependent but deterministic (fixed
iteration). Volley same. ACCEPTABLE, note in spec.**

**FG (residual) Q on AZERTY moves (minor, note only). Tests passing `nil` view to
controller tick must survive mark wiring (guard).**

## Fold status: ALL dispositions above folded into the spec rewrite (this session).
## Next: goalcomp with owner's adapted context-restore text.
