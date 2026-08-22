# s34 — seal GATING law: a seal's `opens` must name a `sealed: true` way (grilled, verdict TIGHTEN, shipped) (2026-08-21/22)

**Commit:** `abe04d6` `feat: refuse seals whose opens names an unsealed
transition at zone load` (src/core/tile_map.rb + test/core/tile_map_test.rb,
one concern; amended once pre-push per review nits, pushed same session,
pre-push suite green). Suite **1018 → 1022** (4 new tests,
message-asserted + composition control), 0 failures. Work crossed
midnight — session dated 2026-08-21, commit timestamp 08-22 01:42; the
filename matches the pushed commit's pointer.

## Provenance

s33 fresh-eyes review nit 1, RECORDED once in
`drafts/_s33-seal-opens-20260821.md` §Review receipt + §Scope refusals.
The s31 once-recorded-promotion precedent did NOT apply directly — the
nit carried an open design question ("is a seal onto a
`requires_defeats` fact-gated unsealed way legal authoring?"), so the
s34 spark ordered a GRILL first, with NO-SHIP a legitimate outcome.

## The grill (evidence per claim)

**Breach-fact readers — the complete set** (grep + read, this session):

1. `Crossing#open?` — src/game/crossing.rb:63-67: `return false if
   t[:sealed] && !@breached.call(zone_name, t[:at])` then `return false
   if t[:requires_defeats] && @defeats.call < t[:requires_defeats]`.
   Two INDEPENDENT AND-legs; the breach fact feeds ONLY the sealed leg.
2. `Renderer.way_locked?` — src/app/renderer.rb:245-248: same two legs,
   slab render (gold = walkable law).
3. `Renderer.water_drained?` — src/app/renderer.rb:255-257: breach fact
   at `map.water_drained_by` flips water tiles to the drained ref.
   **Sealed-INDEPENDENT** (tile alias) — the one reader outside the
   sealed flag; render-only by construction (comment at :250-254,
   "passability untouched"). Map artifact rides the same condition
   (map_artifact.rb:84-86).
4. `PriceSheet` price_sheet.rb:29 — breached seal shows no price
   (display).
5. `interact_seal` world.rb:1320-1338 — the writer: `breached?` early
   return → `spend_banked` → `restore_breach!` (world.rb:229-231, keys
   `[zone, [x, y]]`) → banner/mark/feel/event.
6. SaveState save_state.rb:162-178 — restore-side cross-check: a
   breached tuple must be some seal's `opens` in a known zone (NOT
   transition-checked — the fact restores legally forever).

**(a) Must the way carry `sealed: true` exactly?** TRUTHY sealed — the
exact read consumers 1-2 make (`t[:sealed]` truthiness, never key
presence; `sealed: false` — a hand-edit shape, the importer drops falsy
sealed at tools/import_ldtk.rb:306 — reads unsealed and must refuse the
same). `requires_defeats` CO-EXISTING is legal: both AND-legs read
their own facts (a way needing toll AND boss count is coherent; no
shipped seal composes them yet, the control test pins legality).

**(b) Seal onto a fact-gated (`requires_defeats`) unsealed way —
meaningful or bug?** BUG under current mechanics. The fact never enters
the requires_defeats leg (reader 1-2): the toll burns banked
(world.rb:1324 `spend_banked`), TOLL PAID prints, the slab STAYS until
the boss counter clears, and the inert fact persists (breached_tuples
world.rb:236) + restores legally (reader 6 accepts it — it IS a seal's
opens). Worse than a no-op: a visible lie. A "toll bypasses the boss
gate" design would need OR semantics in `open?` — a SIM change,
v19-class, refused here in writing; the validator relaxes WITH that
mechanics change if it ever lands.

**(c) Seal onto `stairs_unlocked_by` machinery — reachable?** NO.
`stairs_unlocked_by` has ZERO consumers (grep src/ excluding tests:
only the shape validator tile_map.rb:132-139 + importer passthrough) —
staged v2 schema. Its value is a String fact NAME; seal breach facts
key `[zone, [x, y]]` tuples. Different namespaces, no bridge in code.
When its consumer lands (post-verdict sim-class), THAT change owns its
validation.

**The one expressible pattern the tighten refuses:** a drain-only seal —
`opens` naming an UNSEALED transition whose tile aliases
`water_drained_by` (reader 3 fires, the well drains, no way opens).
Refused BY DESIGN: not shipped, not spec'd (the world-builder spec's
drained state rides zone_7's SEALED hole — opens [33,14], `sealed:
true`, `water_drained_by: [33,14]`, one fact two honest meanings), and
register-drifty (the v12 seal law: "pay the toll... and the way opens —
opening the way IS the arc's payoff", world.rb:1316-1319 comment). The
honest authoring for toll-drains-well is zone_7's exact composition.

## Verdict: TIGHTEN

A seal onto a way that never reads the breach is always-a-bug today:
burned toll + visible lie + permanent inert save fact. Zero shipped
data trips; the check is one truthiness read matching the consumers;
any future relaxation is one line riding its own mechanics change.

## Pre-scan (BEFORE code — blast-radius honesty)

- Throwaway script over `data/zones/*.json` (run twice, deleted):
  district [41,13]→[42,13] `sealed: true` · district_two
  [41,13]→[42,13] `sealed: true` · zone_7 [31,14]→[33,14] `sealed:
  true` — **3/3 LEGAL, 0 trips**.
- Inline fixtures read: map_artifact_test.rb WELL_ZONE (opens [3,3] →
  sealed hole) LEGAL · typed_transitions_test.rb UPPER (same shape)
  LEGAL · tile_map_test.rb s33 legal control already `sealed: true`
  LEGAL · spike_district.ldtk seal opens {42,13} → Transition
  __grid [42,13] `sealed: true` LEGAL (the sealed:false transition is
  the nest gate at [0,13], no seal names it).
- Every other seal-touching test pulls from real DATA zones. Predicted
  zero trips; suite confirmed (1022/0/0) — **no defect branch**.

## What shipped

`validate_seal_opens!` semantic tail split (tile_map.rb): resolve
`transition_at(*opens)` — nil keeps the s33 refusal (`"names no
transition (the toll would open nothing)"`); present-but-unsealed adds
the s34 refusal: `"seal at [x, y]: opens [3, 3] names an unsealed
transition (only a sealed: true way reads the breach — the toll would
open nothing)"`. Distinct grep-able messages, BadMap house class. Law
comment names reader 3 (water_drained?) and the refused-by-design
drain-only pattern. Shape/bounds branches byte-identical. Core-only:
world.rb untouched (1800/1800), runtime untouched, importer untouched
(validate_emitted! round-trip composes the law — s33 finding
unchanged). No visual surface moves → **no Rule-2 gate owed**.

## Tests (tile_map_test.rb, s34 block)

Unsealed (key absent) · `sealed: false` (hand-edit shape; comment
corrected per review nit 4 — the importer never emits it) ·
`requires_defeats`-only (question (b) pinned as a test) — all
message-asserted; composition control (sealed: true + requires_defeats
stays valid — question (a)'s co-existence law pinned). s33 legal
control unchanged (base case).

## Review receipt (Rule 6 — scrubbed read-only sub-session, pre-push)

**PASS-WITH-NITS** (tmp/s34_review_out.txt — banked here, tmp is
ephemeral). Reviewer verified: validator does what the message claims
(shape→bounds→nil→unsealed, truthiness matching crossing.rb:59 +
renderer.rb:246) · independence of the two AND-legs · 3/3 shipped seals
+ all fixtures comply (re-verified against `546769f~1` — zero test
churn because the s33 control was already sealed:true) · harness/soak
construct no seal fixtures · importer round-trip composes the law ·
old saves stay valid (save_state cross-check keys opens, which didn't
move) · stairs_unlocked_by consumer-free. Coverage judged sufficient;
messages judged distinct/grep-able/honest.

Findings + disposition (all narrative, none blocking):

1. **water_drained? is a sealed-independent breach reader** — the
   original message's "consumed ONLY through sealed" was false as
   worded and the drain-only refusal deserved naming. **FIXED pre-push**
   (commit message rewritten + law comment names reader 3; `546769f` →
   `abe04d6`, code logic unchanged).
2. **Dangling ticket pointer** — this file didn't exist at review time.
   **RESOLVED** by this docs commit (the s33 precedent).
3. **Stale line ref in message** (crossing.rb:64 vs :58-59). **FIXED**
   — amended message uses method names only.
4. **Test comment misattributed `sealed: false` to the LDtk emitter**
   (importer drops falsy sealed, import_ldtk.rb:306). **FIXED** —
   comment now names the hand-edit path.
5. Untested-but-coherent corner noted, no test demanded: a truthy-string
   `sealed: "false"` hand-edit passes AND reads sealed to consumers —
   validator and consumers agree, no silent divergence.

Amendment discipline: nits 1/3/4 fixed by `git commit --amend` BEFORE
push (commit was local-only); pre-commit + pre-push hooks each re-ran
the suite green (1022/0/0). Mail dir audited after the sub-session:
inbox 0 / done 22 / audio T3 cue-spec untouched — clean.

## Scope refusals (RECORDED, never built this session)

- **OR-gate semantics** ("toll bypasses boss") — sim change in
  `Crossing#open?`, v19-class; the validator moves WITH it.
- **Drain-only seals** (unsealed way + water_drained_by alias) —
  refused authoring space by design; if wanted, it arrives as a
  mechanics+register change, not a validator relaxation.
- **`sealed` value-shape validation** (e.g. refuse truthy strings) —
  different law; consumers and validator currently agree on
  truthiness, no divergence to close.
- **Runtime `interact_seal` / breach / save semantics** — untouched,
  load-time law only.
- **Importer changes** — none owed (round-trip composes; s33 finding).
- **world.rb** — untouched by design (1800/1800).
