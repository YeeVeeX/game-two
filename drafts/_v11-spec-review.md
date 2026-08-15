# v11 spec review ledger — adversarial 3-lens workflow (2026-08-13)

Workflow `wf_2e56306e-27f`: 3 finders (code-fit / design-fun /
harness-verifiability, each capped at 5 findings) → 3 adversarial refuters
per finding (code-truth / design-intent / materiality lenses, default
refuted-if-uncertain, majority ≥2 kills). 45 agents, 2,504,270 subagent
tokens, 492 tool uses, 15.2 min — inside the declared Rule-7 envelope
(~25-35 agents realistic / ~2-3.5M tokens). 14 findings judged:
**9 CONFIRMED (all folded into the spec), 5 refuted.**

Spec under review: `docs/superpowers/specs/2026-08-13-v11-density-remassing-design.md`
(reviewed pre-commit; fixes applied before the first commit, so the
committed spec is the post-review text).

## Confirmed (spec fix applied for each)

| # | Sev | Lens | Finding | Fix applied |
|---|-----|------|---------|-------------|
| 1 | high | code-fit | `add_human` returns the humans ARRAY (`Array#<<` returns self), not the creature — the spec's `:human_respawned actor:` emit would silently carry the whole roster | §4 now mandates changing `add_human` to return the creature explicitly (safe: both existing callers discard the return) |
| 2 | med | code-fit | "the kit's home spawn tile" undefined for multi-spawn kits (rusher has 12); record carries no death tile to disambiguate | §1 step 2 is now a double-minimum: smallest Chebyshev over pocket-members × the kit's FULL enemy_spawns list; tie-break lowest roster index |
| 3 | med | code-fit | Seed anchor undefined when `pack.living` is empty — achievable: last body dies in `resolve_attacks` same-tick, wipe transition lands later at bus-process | §1 step 3 edge guard: empty pack.living → fall through to home fallback |
| 4 | low | code-fit | RNG-ordering parenthetical inverted ("second consumer after drop rolls") — scatter fires in tick_world BEFORE bus-process drop rolls | §1 step 4 rewritten: scatter-then-drops per tick, ordering pinned as load-bearing (moving it shifts the drop-roll stream and breaks seeded replays) |
| 5 | high | design-fun | Band 1 at 14px is SIZE-identical to a stacked band-0 drop — hue alone would carry 40% of the map's kills | Band 1 → 16px; ladder 10 < 14 < 16 < 18, size primary channel, color reinforcement; band-1-reads-between clause folded into check #40 (goal pins ONE new check) |
| 6 | high | harness | Existing check #20 `drops_read_as_pickups` describes drops as "small magenta/violet squares" — gold band-2 drops make the template false and verdicts unreliable | Harness section prescribes the #20 recognition-template amendment (requirements unchanged — ADD-ONLY binds requirements; the parenthetical broadens to track the render) |
| 7 | med | harness | Density telemetry line divides by zero at zero arrivals; zero-sample output unpinned | Zero-arrivals case pinned (mean=0.0 max=0 counts 0 singles_pct=0; line PRESENCE = subscriber-alive proof; routes as "unexercised", never mechanism defect); zero-arrivals format added to the test list |
| 8 | med | harness | Same RNG-ordering misstatement from the harness lens (tick-phase placement) | Same §1 step 4 fix as #4 |
| 9 | low | harness | Block-radius defer test loses isolation under release-time tiles (must predict the chosen tile through the anchor algorithm) | Test-list note: constrain world state to a single possible anchor outcome; park pack within block_radius − scatter_radius so ALL scatter candidates suppress regardless of RNG |

## Refuted (recorded so implementation doesn't re-litigate)

- **band1_size_collision (code-fit, low)** — refuted as misquoting the
  spec's tiered legibility standard; nonetheless the design-fun twin (#5)
  CONFIRMED the underlying 14px collision and the fix landed. Net: fixed.
- **pocket-growth-vs-lap (design-fun, med)** — "cap 5 unreachable in
  steady state" mismodeled respawn timing: each kill schedules
  independently at its own death+300f; group kills produce group releases.
- **join-ignores-block (design-fun, med)** — "spin-deferrals on blocked
  pockets" self-resolves via aggro (a pocket 2 tiles from the pack is
  fighting, not spinning); the proposed skip-blocked-pockets fix would
  actively hurt re-massing.
- **telemetry-spatial-blindspot (design-fun, med)** — wrong spawn counts
  (claimed 2+6+7, actual 2+5+8); pockets form from LIVING positions, not
  static spawn geometry; the ninth verify's felt questions cover spatial
  staleness.
- **routing-q1-q5-compound (design-fun, low)** — the routing table's
  branches compose per-question; the compound outcome routes to the debate
  with both facts carried.

## Residue for implementation (non-finding notes worth keeping)

- `spawn_drop`'s "first consumer" comment (world.rb:580) becomes stale once
  the scatter pick lands — update it in the same commit (refuter note on
  finding #4).
- The gate-tile/band-2 gold-family concern was dismissed on geometry (28+
  tiles separation exceeds any viewport) — if a future zone ever puts a
  gate deep in a gradient, re-check.
