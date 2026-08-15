# D1b spec adversarial review ledger (workflow wf_2ccd8520-4cd, 2026-08-12)

3-lens review (code-fit / design-economy / harness-verifiability) of
`docs/superpowers/specs/2026-08-12-d1b-vat-economy-design.md` at commit
`d65f9b9`, every finding adversarially verified by an independent refuter.
15 agents (3 finders + 12 refuters), 999,435 subagent tokens, 0 errors.
⚠️ Rule-7 note: the declared envelope was ≤600K; actual ~1M (finders ~110K
each, refuters 40-65K each). Overrun recorded, convergence condition held
exactly (one find round + one verify round, 12/12 versed).

VERDICT: 12 findings → 12 REFUTED, 0 CONFIRMED. Spec ships to the owner
gate with two refuted-but-useful clarity folds (§3 placement wording;
§Presentation-5 post-wipe capture timing) — folds tighten language, change
no design decision.

Owner-locked forks were declared out of bounds to finders (increment
choice, regrow+floor, consumed marks, all-or-nothing tribute, three
fixtures, station-only banked); no finder attempted to re-litigate them.

## Refuted (recorded so nothing re-raises them)

### [high/harness] judgment_reads is beat-dependent mid-veil
CLAIM: During the 90-frame veil all pack members are dead and undrawn, so
the check is flaky or impossible without a "judgment presentation phase".
REFUTATION: The check's own text says "POST-wipe return" — capture happens
after respawn_pack fires (marked revive → drawn; dissolved stay dead → not
drawn). "During the wipe veil" was dramatic framing; now tightened in the
spec to "as the veil lifts" + an explicit post-wipe capture note.

### [medium/code-fit] "existing deterministic defer pattern" mismatch
CLAIM: No existing function does immediate occupied-tile fallback; the only
defer (respawn_due_humans) is next-tick retry — wrong for a synchronous verb.
REFUTATION: Spec said "pattern" (the FlowField::STEPS first-free idiom, used
6+ places), not a function. Stronger: revive!/rebind is a hard teleport with
NO occupancy check — respawn_pack already places without checks; transient
tile-sharing is legal (only voluntary `step` is blocked). FOLDED: §3 now
states the hard-rebind fact and demotes the fallback to a courtesy option.

### [medium/design] budget-threshold deliberate-wipe incentive
CLAIM: At banked slightly below tribute cost while wounded, deliberately
wiping is optimal (floor revives possessed at full HP free, banked intact).
REFUTATION: Execution cost exceeds savings — the nest has zero enemies, so
a deliberate wipe means walking out, dying on purpose (time + carried pile
lost), and the floor returns ONE body of three; the other two now cost
regrow_cost each. Saves at most heal_cost_per_body ≈ 2 at the exact edge.
Not a dominant strategy; the seventh verify's Q8 price question watches it.

### [design] thesis overstates closure — floor is a free heal
CLAIM: "every one of those flows priced" is false: the floor heals free.
REFUTATION: The thesis prices the DIAGNOSED flow (full pack + full HP +
banked intact for a walk). The floor returns one body of three — the wipe
still destroys unmarked flesh. Mercy-floor ≠ free reset.

### [harness] tribute_beat_reads has no specified transient
CLAIM: Like the ledger tally, the beat needs a timed transient to capture.
REFUTATION: Tribute is a persistent physical state change — regrown bodies
STAY alive at spawn tiles; wounds stay closed. Any post-tribute frame shows
it; nothing fades.

### [harness] 5-act vat_economy.json two-wipe staging infeasible
CLAIM: Act 5's "zero marks, empty pockets" state can't be reached after act 4.
REFUTATION: "Empty pockets" describes the state AT the floor wipe, not a
spend ban between acts — the natural sequence tributes away the balance
after act 4 (which itself stages the regrow beat), then wipes broke.

### [harness] retarget_cue_reads is timing-fragile
CLAIM: A 45-frame cue is a flaky capture target across re-pilots.
REFUTATION: Checks are global with self-gating clauses (the mandatory-beat
system); the pilot authors capture timing deliberately — same class as the
existing telegraph/projectile beats that already gate green.

### [code-fit] forced-swap stagger persists into gameplay
CLAIM: Post-wipe possession snap pays forced_swap! stagger during a dead state.
REFUTATION: Timing wrong — respawn_pack runs after the transition to :world;
and the floor case possesses the kept vessel directly (no swap). Plan pins
the possession-snap mechanism explicitly anyway.

### [code-fit] dissolved bodies' corpse-record cleanup unspecified
CLAIM: Spec leaves pack corpse husks ambiguous (dual semantics).
REFUTATION: Bulk faction filter suffices (corpse records carry
`faction: actor.faction`, world.rb:788); vat-case husks fade naturally
(CORPSE_FADE_FRAMES, world.rb:747). Spec explicitly deferred the mechanism
as a plan-time code fact. FOLDED: §Presentation-5 now names the corpse-record
fact + the clear-or-fade options.

### [low/design] Q1 can't distinguish surplus-comfort from indifference
CLAIM: Telemetry lacks banked_min; "wouldn't care" conflates rich-and-bored
with meaning-failed.
REFUTATION: Every :banked_spent/:tribute_paid event carries the post-spend
balance — the banked timeline (incl. minimum) is derivable from the EVENT
log the pilot already re-anchors prices from. Summary line serves binary
routing only.

### [low/harness] FN-3 "meaning oracle" overclaims three-branch routing
CLAIM: Only spent-vs-never-spent is machine-routable; wording implies more.
REFUTATION: The spec's own sentence scopes the oracle to exactly that
boundary; routing lines parenthesize which branches are telemetry-gated vs
owner-answer-gated.

### [low/harness] "idle-only" could be misread as movement-idle
CLAIM: An implementor might add a !moving? guard and break bank-while-walking.
REFUTATION: "Preserved verbatim" + "byte-identical" + exact line citations
forbid touching the guards; "idle" is the code's own `:idle` attack_state
vocabulary; the controller architecturally interleaves step + interact on
one frame.

## Artifacts

Full structured output: the workflow journal
(`~/.claude/projects/C--Users-gabri-workspace-game-two/f706a62a-.../subagents/workflows/wf_2ccd8520-4cd/journal.jsonl`)
carries each agent's complete return; the assembled result also landed at
the Temp task output (transient). This ledger is the durable record.
