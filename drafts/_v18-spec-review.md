# v18 spec — dual review ledger (2026-08-17)

Spec under review: `docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md`
(persistence v1 + coop feel + god-view v0). Forks closed this session on dev
recommendation (F1/F3/F4 owner-level — veto window open until TDD). Review
order per contract: Codex leg FIRST, findings folded, then the cross-vendor
panel. Panel envelope declared up front (Rule 7): 3 lenses × 1 round,
≤1600 completion tokens each, ≤25K total, no follow-ups.

## Leg 1 — Codex (codex-cli 0.147.0, `--sandbox danger-full-access` +
## no-write prompt order; 1.98M tokens; raw: tmp/codex_v18_review_out.txt)

**VERDICT: REJECT — 21 findings (9 BLOCKER / 12 MAJOR). Adjudication: 20
CONFIRMED + folded, 1 PARTIALLY confirmed. Zero refuted — the draft's
persistence section was under-specified in exactly the ways a determinism
substrate punishes.**

1. carried persists + load-at-home = risk-free loot teleport (BLOCKER) —
   **CONFIRMED, design hole.** FOLDED: carried does NOT persist; value
   survives only as banked (F1 amended; "bank it or lose it" is now the
   save ritual, exact). The alternative fix (save only at stations) was
   REJECTED and recorded in Deliberately absent: quit must stay available
   anywhere; pressure belongs on value, not on the quit button.
2. saved_at_ms breaks serialize idempotence (BLOCKER) — **CONFIRMED.**
   FOLDED: facts/envelope split (decision 1); digest + idempotence law
   over canonical FACTS only.
3. digest over envelope vs facts-only transfer; genesis undefined
   (BLOCKER) — **CONFIRMED.** FOLDED: digest = md5(canonical facts);
   joiner RECOMPUTES from received bytes (echo-trust banned); fresh world
   = `source=fresh`, no digest, chain starts at first `saved` line
   (decision 5).
4. enter_zone does NOT clear stagger/iframes/exhaust/action state; quit
   during wipe veil = zero living → serializer assert (BLOCKER) —
   **CONFIRMED; the draft's normalization claim was FALSE.** FOLDED:
   explicit save-boundary projector (decision 3): judgment resolves
   through the LIVE rules first (marks consumed, floor applies), then an
   enumerated transient-zero list; every-veil-tick quit sweep in lane 1.
5. construction binds home/seats before facts (wrong spawn, seats on
   dead bodies) (BLOCKER) — **CONFIRMED.** FOLDED: decision 4 pins apply
   ORDER: home_zone → member facts → seat pointers over the LIVING set →
   restore_breach! → enter_zone. Test: non-default home + only third
   member alive.
6. live seal path re-spends banked at restore + fires tick-0
   presentation (BLOCKER) — **CONFIRMED.** FOLDED: `restore_breach!`
   idempotent + side-effect-free; live interact = spend + emit + restore.
7. joiner applies save post-window; malformed facts crash in-window
   (BLOCKER) — **CONFIRMED.** FOLDED: strict decoder runs during the
   joiner pre-window pump; refusal = console + exit 1, no window
   (decision 6a; bindings-error precedent).
8. BYE refusal detail only for "fingerprint"; save refusals become
   generic protocol + exit 0 (BLOCKER) — **CONFIRMED against
   session.rb:357.** FOLDED: BYE vocabulary + refusal text for ALL
   refusal reasons on BOTH seats, exit 1; RC-matrix re-verified
   (decision 6b).
9. validation too shallow (types/ranges/duplicates/floats; alive vs hp
   contradictions) (BLOCKER) — **CONFIRMED.** FOLDED: strict decoder
   (decision 6a); `alive` DERIVED from hp>0, removed from schema
   (decision 1).
10. solo path is FIXED seed 0 — "every session re-seeds" was false for
    solo (MAJOR) — **CONFIRMED against window.rb:58.** FOLDED: decision
    16 (per-session solo seed in main.rb + two-launch regression);
    Foundations corrected.
11. save must gate on clean quit; negative termination lanes absent
    (MAJOR) — **CONFIRMED.** FOLDED: idempotent save coordinator, host ∧
    reason=quit only; desync/conn_lost/refusal/double-close write
    NOTHING (decision 2 + lane 2).
12. W4 measured facts bytes, not the ENCODED SESSION line (MAJOR) —
    **CONFIRMED.** FOLDED: wire preflight on the actual
    Protocol.encode(:session,...) bytes before listening (decision 6c).
13. atomic-write sequence under-specified for Windows (MAJOR) —
    **CONFIRMED.** FOLDED: decision 14 pins same-dir tmp → flush+fsync →
    close → replace, with fault tests pinning the property (crash lanes,
    consecutive writes, --fresh backup races).
14. absent-block scalar arithmetic can float-poison the digest
    (300→300.0) (MAJOR) — **CONFIRMED.** FOLDED: decision 7ii/11 —
    absent block = NO arithmetic evaluates; present block = explicit
    `.round` Integers.
15. bare `rake canary` doesn't exist as invoked; no banked all-17
    baseline (MAJOR) — **CONFIRMED (task takes SCRIPT+BASELINE).**
    FOLDED: increment 0 banks fresh baselines for all 17 scripts; canary
    SWEEP after every sim-touching increment (decision 7).
16. sustain not edge-triggered; held key drains pool; same-tick double
    consume (MAJOR) — **CONFIRMED (EDGE_TRIGGERED list excludes it by
    default).** FOLDED: decision 9 — edge-triggered + swap-rearm,
    zero-effective refuse, first-success-per-tick seat law.
17. flee precedence undefined vs seizure/mark/committed actions (MAJOR)
    — **CONFIRMED.** FOLDED: decision 12 pins precedence (seizure →
    flee → mark/aggro; committed actions finish).
18. classification labels don't prove round-trip (MAJOR) — **CONFIRMED.**
    FOLDED: persisted-leaf mutation sweep (lane 1): mutate → bytes
    change → apply → exact restore.
19. single-process two-session lane can't see joiner writes (MAJOR) —
    **CONFIRMED.** FOLDED: per-seat tmp save roots; joiner root asserted
    EMPTY (lane 3).
20. evolution rules only covered hp (MAJOR) — **CONFIRMED.** FOLDED:
    decision 4's clamp+log vs refuse-named table (provisions cap, seal
    tuples vs zone data, home_zone validity, roster order).
21. palette-data sharing can't catch geometry/placement errors in the
    map (MAJOR) — **PARTIALLY CONFIRMED.** The vision critique IS the
    geometry judge (Rule 2), but deterministic landmark probes are cheap
    insurance. FOLDED: decision 13 gains pixel probes (sealed≠breached
    cell, home marker present); full renderer factoring NOT adopted —
    the map is a data-driven composite, not a camera view; the critique
    + probes carry it.

## Leg 2 — cross-vendor panel (bedrock-council; envelope: 3 lenses ×
## 1 round, ≤1600 completion tokens each, ≤25K total)

Lenses: DeepSeek (determinism/state-machine adversarial), Kimi (game
design/feel + es/pt-br oracle register), Qwen-Coder (Windows IO + wire
protocol). Actual spend: 3 calls, ~2.6K in / ~2.7K out tokens — well
inside the envelope. Raw JSON: tmp/panel_{deepseek,kimi,qwen}_out.txt
(tmp/ is ephemeral; every actionable verdict is adjudicated inline
here).

### DeepSeek (deepseek.v3.2) — 5 questions

- **Q1 construction-order divergence: UNCERTAIN** → adjudicated COVERED:
  apply order is pinned (spec decision 4), breached applies in the
  facts' sorted order, both seats parse IDENTICAL wire bytes; Ruby
  hashes preserve insertion order deterministically for identical
  documents. No fold beyond decision 4's existing order pin.
- **Q2 projector observer-effect (judgment consuming RNG at save time):
  HOLE → CONFIRMED as a purity requirement.** FOLDED (decision 3): the
  projector is PURE — non-mutating, RNG-untouched; possible because
  nothing RNG-dependent (positions/scatter) is in the facts vocabulary;
  serialize-twice + digest_snapshot-untouched tests added (lane 1).
- **Q3 canonical-JSON underspecified (Ruby doesn't sort keys): HOLE →
  CONFIRMED**, converges with Qwen Q3/Q4. FOLDED (decisions 1/5): OUR
  pinned canonicalizer (recursive key sort, pinned separators,
  Integer/String/Boolean + ASCII-only, raise otherwise); wire carries
  the canonical STRING and the joiner digests received bytes before
  parsing.
- **Q4 quit-only save gating too strict (peer-quit reason): HOLE →
  REFUTED against source.** session.rb BYE_REASONS maps a peer's
  BYE{quit} to :quit on the RECEIVING seat — either seat's Esc lands
  reason=:quit on both; the host saves in both cases. Clarified in
  decision 2 + a joiner-initiated-quit lane in lane 2 so the property
  stays pinned.
- **Q5 unthought risk (truncated save mid-write; zone-data versioning)**
  → atomic writes + refuse-named already covered it (decisions 14/4;
  the reviewer saw only the law summary, not the spec — prompt
  artifact); the NEW fold: unparseable/truncated FILE = NAMED refusal
  with .bak/.tmp recovery hints (decision 6a).

### Kimi (moonshotai.kimi-k2.5) — 6 questions, all FLAWED/UNCERTAIN

- **Q1 bank-it-or-lose-it = session-end tax: PARTIALLY CONFIRMED.**
  Design kept — the decisive counter (written into F1): field value is
  ALREADY ~90s-transient in-session (corpse_term_frames 5400); the quit
  boundary meets the existing decay law, adds nothing harsher. The
  session-close "bank before you leave" cue stays a pre-registered
  routing row, not pre-built.
- **Q2 dead-stays-dead = chore-tax risk (cites the project's own 5
  chore verdicts): PARTIALLY CONFIRMED.** Design kept (Tibia model; the
  worst case — 1 living body, banked below the regrow fee — is the
  corpse-run comeback arc, and the nest is tuned for it). FOLDED as a
  pre-registered routing row: under-resourced opening + chore reading
  → mercy-floor debate (recorded, never auto-built).
- **Q3 provisions premium kills experimentation ("price isn't the
  friction; interface is"): PARTIALLY CONFIRMED.** Its telemetry
  reading was wrong (provisions don't exist yet — 238 is STATION
  spend), but the trial-cost point stands. FOLDED: cost strawman 6→5;
  tuning-lever order pre-registered (discoverability → cost → heal);
  auto-consume REJECTED (deletes the owner-ratified invocation
  decision; zero-effective refuse already prevents waste).
- **Q4 coop knobs pull against each other; flee "mis-signed":
  PARTIALLY CONFIRMED.** Its replacement (fight-to-death + 10s respawn)
  is substrate-impossible (pack bodies regrow at the vat, not on
  timers). The real fold: the knob-interaction law written into
  decision 12 — three knobs pull three named axes, Half B arbitrates
  each seat's own friction, retune order pinned (respawn_delay → hp →
  flee).
- **Q5 fun-verify questions leading (MISMO priming; quoting Junior's
  complaint back at him): CONFIRMED.** FOLDED: Half B rewritten —
  neutral temporal frame, both alternatives weighted, open-form
  respawn/AI questions; kimi's structural rewrites adapted, not copied
  verbatim.
- **Q6 unthought risk ("persistence boundary between players
  unstated"): PARTIALLY CONFIRMED.** The spec DOES define custody
  (F2/F4) — the gap is the PLAYER-FACING contract. FOLDED: increment 8
  requires JUNIOR.md to state it in player terms (shared world lives on
  the host; Junior solo = his own world; joining advances the shared
  one).

### Qwen-Coder (qwen.qwen3-coder-next) — 5 questions

- **Q1 rename-over-existing fails EACCES/EBUSY on open targets: HOLE →
  CONFIRMED.** FOLDED (decision 14): bounded retry (3×50ms) → NAMED
  error with .tmp intact; orphan-.tmp detection at next launch;
  open-handle fault test (lane 2).
- **Q2 no directory fsync on NTFS — durability best-effort: CONFIRMED
  as documentation.** FOLDED (decision 14): integrity guaranteed,
  last-write durability explicitly best-effort, accepted + recorded for
  a hobby save.
- **Q3 JSON-in-JSON escaping/nesting: HOLE → CONFIRMED** (with Q4).
  FOLDED (decision 5/8): the save travels as the canonical STRING field;
  budget preflight uses the ACTUAL encoded line (already Codex #12).
- **Q4 parse→re-serialize digest trap: HOLE → CONFIRMED, the sharpest
  infra fold.** FOLDED (decision 5): joiner digests the EXACT received
  bytes before parsing; file loads go through the one pinned
  canonicalizer.
- **Q5 stale-snapshot race (host mutates facts between encode and
  accept): REFUTED against source.** The host World does not exist
  until attach at the READY→START barrier (window.rb:84,
  session.rb:125-127); facts are disk-loaded at launch, frozen in
  Params, and BOTH worlds construct from that same frozen snapshot. No
  mutation window exists.

### Panel summary

9 folds (projector purity, pinned canonicalizer, exact-bytes wire
digest, unparseable-file refusal, rename-failure lane, durability
disclosure, provisions cost + lever order, de-primed Half B wording,
mercy-floor routing row + JUNIOR.md custody contract + knob-interaction
law), 2 refutations with source evidence (peer-quit reason; stale-
snapshot race), 0 unresolved. The spec at commit reflects every fold;
findings that misread the substrate are recorded with the evidence so
they are not re-litigated at TDD.
