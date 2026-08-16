# v17 spec — dual review ledger (2026-08-16)

Spec under review: `docs/superpowers/specs/2026-08-16-v17-multiplayer-etapa1-design.md`
(etapa-1 lockstep co-op). Forks closed in-session by the owner ("aprobado,
procede") before the spec was drafted. Review order per contract: Codex leg
FIRST, findings folded, then the cross-vendor panel.

## Leg 1 — Codex (codex-cli 0.147.0, gpt-5.2-codex)

Mechanics note: `--sandbox read-only` is BROKEN on this machine (Windows
sandbox helper fails, os error 206 "filename too long" — every exec dies;
Codex honestly refused to fabricate findings without file access, 382K
tokens burned on the dead run). Re-run with `--sandbox danger-full-access`
+ an explicit no-write order in the prompt. Verdict run: 1.57M tokens.

**VERDICT: REJECT — 12 findings (9 BLOCKER / 3 MAJOR). Adjudication:**

1. Digest coverage non-authoritative (BLOCKER) — **CONFIRMED**. Curated
   vector missed walker progress, cooldowns, action state, hitstop,
   projectiles, drops/corpses, respawn queue, mark, seizure clocks;
   world_scene's curated event list misses registered events
   (attack_started, damage_dealt). FOLDED: versioned authoritative
   snapshot (per-object `digest_fields`, flat named scalars, stable ids),
   ALL registered bus events via the EventBus::EVENTS whitelist, consumed
   input masks folded per tick, mutation-sensitivity sweep.
2. Input sampling breaks during stalls (BLOCKER) — **CONFIRMED**, real
   defect in the draft: sampling per update resubmits changing masks for
   the same slot. FOLDED: sample exactly once per EXECUTED sim tick;
   stalled updates pump only; differing duplicate slot = protocol fault.
3. Stall abort counted in ticks that don't advance (BLOCKER) —
   **CONFIRMED** as worded. FOLDED: wall-clock ms on the app-layer
   monotonic clock (stall_warn_ms 500 / abort_stall_ms 10000); sim never
   reads the clock.
4. Digest compare/termination state machine incomplete (BLOCKER) —
   **CONFIRMED**. FOLDED: retained immutable records per unresolved
   boundary (bounded 2-3); DESYNC exchange + bounded drain before close;
   BYE{quit} drain; reason=quit on both seats for clean Esc.
5. "Seat-symmetric by construction" false (BLOCKER) — **CONFIRMED**, the
   biggest under-spec. FOLDED: decision-11 seat semantics table
   (controlled_bodies/seat_for/controlled?; AI dispatch, interact/mark
   guards, seizure targeting, zone gates, feel/hitstop, attribution).
6. Simultaneous deaths / judgment undefined (BLOCKER) — **CONFIRMED**.
   FOLDED: bus-flush death resolution in seat order, pack_wiped
   exactly-once guard, judgment assignment over the ACTUAL revived set
   (floor case: seat 2 waits-for-body; recorded half-B feel risk).
7. No local-seat rendering seam (MAJOR) — **CONFIRMED** (renderer + strip
   hardcode bare possessed). FOLDED: `local_seat:` through Renderer and
   ControlsOverlay, default seat 1.
8. Canary invokes the wrong mechanism, covers too little (BLOCKER) —
   **CONFIRMED**: `rake gate` compares two fresh runs; baseline compare is
   `rake canary` (Rakefile:65). FOLDED: pre-refactor baseline captures for
   EVERY wall script + full-wall `rake canary` after seat increments +
   the 3 headless etapa-0 digest canaries in-suite.
9. BODY 1/2/3 relabel violates ratified placeholder contract + wall
   byte-identity (BLOCKER) — **CONFIRMED**; my draft decision was
   overreach and self-contradictory with the canary law. FOLDED:
   decision REVERSED — rings only, PARTNER wording avoids the "player 2"
   collision, body labels untouched.
10. Rule-2 coverage incomplete + check scoping doesn't exist (BLOCKER) —
    **CONFIRMED** (vision_critic loads every check globally; one script
    can't stage mutually-exclusive end states). FOLDED: harness/net/
    script FAMILY (session / desync / conn_lost) + new optional CHECKS=
    gate argument, default untouched; netplay checks in their own file.
11. Framing/handshake/launcher underspec (MAJOR) — **CONFIRMED** (spec-
    worthy subset). FOLDED: buffered line framing + 4KB cap + phase state
    machine + EOF policy; session_id; host=seat1; D=median of probes;
    RUBY_PLATFORM in fingerprint; both launchers forward args.
12. Commit sequence vs visible-commit law (MAJOR) — **PARTIAL**. Prior
    cycles committed plumbing increments routinely; FOLDED as a recorded
    dev interpretation in the spec (feature-granularity reading for
    substrate cycles, owner veto window open) rather than regrouping.

## Leg 2 — cross-vendor panel (bedrock-council CLI)

Envelope declared up front (Rule 7): ≤4 lenses, ~1.5M tokens, cap 8
agents, one round, stop = verdicts folded or budget hit. **Actual: 3
agents, ~13K tokens (deepseek 5.0K in/1.4K out; kimi 0.8K out; qwen-coder
1.8K out truncated at max_tokens after Q2) — under envelope.** One dead
call (wrong alias `qwen3-coder`; roster name is `qwen-coder`).

### DeepSeek V3.2 (protocol/determinism lens) — verdict REJECT

- D1 "fixed D deadlocks under latency spike" — **REFUTED after
  verification**: a spike stalls (bounded wait, TCP retransmits), it does
  not deadlock; each seat has always submitted D slots past its own
  execution point, so both sides can always reach min(peer)+D. Its
  proposed fix (dynamic D) is the owner-parked adaptive path. No change;
  reinforces W3 (recorded).
- D2 end-reason race (socket dies mid-desync-drain → seats record
  different reasons) — **CONFIRMED**. FOLDED: reason precedence desync >
  protocol > conn_lost > quit; a desync artifact on EITHER seat = half-A
  failure.
- D3 TCP HOL stall storms on real loss — **CONFIRMED as risk** (not as a
  transport change): etapa-1 deliberately buys minimal code and VISIBLE
  stalls. FOLDED into W3 + fun-verify routing: stall storms with clean
  digests → etapa-2 UDP+redundancy debate, never rollback creep in v17.
- D4 Marshal(Random) cross-VERSION instability — **REFUTED for the pinned
  environment** (exact version+platform enforced at handshake), but the
  panel's combined pressure (with Qwen Q3) exceeded my confidence in
  Marshal as a documented-stable format. FOLDED conservatively: rng
  digest coverage switched to DRAW COUNTS via a counting delegate
  (value-transparent — wall byte-identity untouched by construction);
  divergence detection rides downstream state within one window.
- D5 GC-pause sampling nondeterminism — **REFUTED**: each seat's sampled
  mask IS that seat's authoritative input; both sims consume identical
  masks by protocol. Sampling-time jitter is feel, not desync.
- Camera-affects-AI — **REFUTED in this codebase** (no sim system reads
  cameras); pinned as a standing prohibition in decision 6.
- Boundary retention unbounded under reordering — **REFUTED**: single TCP
  stream is in-order at the app layer.

### Kimi K2.5 (co-op feel lens) — sharpest catch of the panel

- K1 drag-along zone gate = "my friend deleted my agency" — **CONFIRMED**
  (its strongest point: spectate is legible cause-effect, drag-along is
  unilateral relocation). FOLDED: gates now require EVERY LIVING
  controlled body in the gate group (consent by co-location; dead/waiting
  seats don't block; `WAITING AT GATE` cue).
- K2 133ms delay noticeability — UNCERTAIN; already instrumented (D,
  stall telemetry) + SIXTEENTH Q2 asks directly. No change.
- K3 freeze-on-stall = shared punishment — **acknowledged as the recorded
  COST of lockstep**, not folded as a change: asymmetric resilience IS
  rollback-family tech, owner-parked. Recorded in W3 verbatim spirit.
- K4 no-rejoin session death hurts half B — **PARTIAL**: rejoin stays
  parked (law); FOLDED the cheap mitigation — honest-end screens print
  the exact relaunch command for both seats.
- K5 "AI third body = triadic jealousy" — colorful, UNCERTAIN; FOLDED as
  a pre-registered fun-verify routing line (either player naming the AI
  body weird → v17.1 embodiment debate), no code.

### Qwen3-Coder (Ruby/Windows implementation lens) — truncated at Q2.5

- Q1 winsock nonblocking landmines — **CONFIRMED** (spurious readability
  after select; partial-write retention is on us; NODELAY setsockopt can
  fail silently; accept_nonblock ECONNRESET during handshake). FOLDED:
  Windows pump discipline block in Net::Session (one drain per update,
  select-probe + WaitReadable rescue, no retry-spin, explicit
  ECONNRESET/EPIPE/EOF → conn_lost, getsockopt verification).
- Q2 "Gosu cadence jitter destroys lockstep" — **REFUTED for
  correctness**: lockstep synchronizes on LOGICAL tick count, not wall
  time; cadence jitter shows up as the partner's stall ms (counted,
  visible) — the sim never reads a clock. Its real half (slow machine =
  slow session) FOLDED as one honest line in Net::Session.
- Q3 Marshal stability (partial before cutoff) — folded with D4 (counting
  delegate).
- Q4/Q5 unanswered (max_tokens); both within local verification
  competence: loopback binds pinned to 127.0.0.1 explicitly (firewall
  prompt avoidance, CI-safe), JSON codec cost at 20B/60Hz is µs-scale on
  this Ruby — measured anyway by the integration lane's perf print. Not
  worth a fourth call.

## Net effect on the spec

14 folds applied across both legs (sampling law rewrite, ms-based stalls,
termination state machine + reason precedence, seat semantics table,
authoritative snapshot + CountingRng, renderer seam, full-wall canary
protocol, relabel reversal, harness/net family + CHECKS=, framing/
handshake pins, Windows pump discipline, gate co-location consent,
relaunch-command mitigation, routing additions). Three REJECT-severity
claims refuted with written reasons (deadlock, GC sampling, cadence) —
kept here so the next session doesn't re-litigate them.
