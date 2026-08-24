# J-7 COLD-TIER CATCH-UP — brief cut (s57, 2026-08-24)

Dev of record: hub seat. Docs-only session (zero code, zero data).
Claim: `CLAIMED: J-7 hub 2026-08-24` pushed at session open (`6f5975c`)
— modeling the s56 anti-race proposal. Precedent shape: the J-6 brief
(`drafts/_j6-menu-brief-20260823.md`); executing sessions implement
tickets, never re-litigate decisions — a decision found WRONG in code
is a stop condition, not a silent redesign.

Everything below is argued from a live code read this session
(world.rb 1786 measured, enter_zone / respawn machinery / digest /
save projector / controllers leash lane / grid walker all read) plus
the shelf note read verbatim.

## The foundation row this brief serves (verbatim scope)

`drafts/_v19-foundation-20260822.md` Lane 3, C1 (RATIFIED-G ·
RATIFIED-J, ledger row 12):

> **C1 — J-7 = cold-tier catch-up, NOT background ticking.** Stamp
> tick on pack-leave; on re-entry advance walkers along their home
> path by elapsed ticks (one deterministic function, O(walkers), at
> transition — zero per-tick cost). Full living-sim ticking REFUSED
> this cycle on the perf prior (44 tps stall with one zone); recorded
> as a future rung.

Owner provenance (ideas doc idea 7, verbatim): "enemies should not
teleport back to their spawn when the pack leaves the area, they
should follow the 'persisting world' principle by going back walking
regularly." world.rb extraction flag from the foundation: LIKELY OWED
— resolved below as ticket 1 (D1).

## What the code does today (the grill ground)

- **Frozen-zone law:** `tick_world` ticks only `humans[@zone_name]`;
  off-zone humans do not move, regen, or leash (world.rb:684ff).
- **The "teleport" the owner saw = snap-home at re-entry:**
  `enter_zone` rebinds every displaced living human in the ENTERED
  zone straight to `home_tile` with KEPT hp, emits `:human_leashed`,
  resets leash (world.rb:1136-1143, "frozen-zone law; recorded plan
  deviation 1"). Infinite-speed catch-up, in other words — J-7 makes
  it finite-speed.
- **Respawns already catch up by construction:** `@human_respawns`
  records key `at_frame` against the GLOBAL `@frame`; only the
  current zone's records process (telegraph/respawn_due_humans,
  world.rb:734-735, 1424, 1459), so a death timer that elapsed while
  the pack was away materializes on the first re-entry ticks (block/
  guard rules intact). Corpse/drop expiry: same global-frame math
  (`prune_caches`). **J-7 changes ZERO respawn/expiry machinery.**
- **Live walk-home lane (the model for the catch-up math):**
  controllers.rb `leash_home` — no focus for `leash_linger_frames`
  (threat.json: 90) → step downhill on `flow_home` field at the kit's
  `step_frames` (combat.json: 13–19 per kit), KEEPING hp
  ("Leash-with-no-heal, A2"). Home may be corpse-guard-shifted
  (`leash_home_tile`, v13 guard-scope).
- **Save facts are a closed vocabulary** (save_state.rb, schema 2):
  {banked, provisions, home_zone, breached, members, counters,
  progression} — no zone state, no frame, no enemy anything;
  everything else "dies at the session boundary by OMISSION",
  test-enforced by the transient zero-list in save_state_test.rb.
- **Digest already covers all zones' humans** (`digest_snapshot`
  walks `@humans.keys.sort`) + all respawn records + rng draws.
  `DIGEST_VERSION = 2` (src/net/state_digest.rb); the fingerprint
  carries it, so builds with different digest grammars refuse at
  handshake NAMED (v17 law).
- **Transitions are pack-atomic** (v15 whole-pack teleport +
  `group_wait` gate consent) — a zone leave/enter is ONE sim event at
  ONE tick, identical on both lockstep seats.

## Touchstones (queried this session, cited per de-slop law)

- Shelf `living-world-simulation-and-npc-schedules` (game-research,
  verified 2026-08-17), verbatim: **COLD tier = "0 Hz. Timestamp on
  last-player-exit; on re-entry run one catch-up function"**
  (mechanism-level, standard practice — Animal Crossing weeds /
  Fallout 4 settlement pattern). Law 4: "Catch-up math is free
  aliveness." game-two routing row: "Catch-up-on-load is the
  single-player sweet spot." Design law 5: clocks read the GAME
  clock, never wall-clock — our stamp is the sim tick, never
  `saved_at_ms`.
- Tibia persistent hunting grounds (idea 7's own touchstone):
  creatures return home regardless of player presence; walking back,
  not teleporting.
- No FLAGGED numbers are involved — J-7 lands ZERO new balance
  values (D11).

## Decisions

### D1 — world.rb extraction OPENS the lane: ticket 1 = Homecoming

world.rb = **1786/1800** (measured live). J-7's seams (stamp write +
catch-up call in `enter_zone`, digest row) all live in world.rb — a
material touch at the cap owes its extraction FIRST (foundation law,
Crossing s31 / Progression precedents).

**Extract the go-home policy cluster** — `flow_home`,
`leash_home_tile`, `shifted_home`, `ring_home`, `human_leashed!`
(world.rb:466-527, ~62 lines incl. comment law) plus, in ticket 2,
the enter_zone returning-humans block — into
`src/game/homecoming.rb`, a plain object (Crossing pattern: policy
object, World stays the only mutator; leash-emit decisions are
RETURNED, World emits). World keeps one-line delegates for
`flow_home` / `leash_home_tile` / `human_leashed!` so controllers'
view duck-type and every existing stub-view test stay byte-untouched
(threat_leash_test, guard_scope_test are the live consumers).
Estimated net: world.rb ≈ −50 → ~1736 after A, ~1744 after B — the
cap test is the binding law, estimates are not promises.

### D2 — The stamp: World transient, zone → leave-frame; NOT a save fact

`@zone_left_at[zone] = @frame`, written in `enter_zone` for the zone
being LEFT (before `@zone_name` reassigns), only when the zone
actually changes (same-zone re-entry writes nothing — D4's wipe
clause depends on this). Consumed (deleted) by the catch-up at
re-entry. Not in save facts: zone humans/positions already die at
the session boundary by omission, so a persisted stamp would point
at state that no longer exists. **No schema bump, no joiner-refusal
change, no v18 backup-law interaction** — save_state_test's transient
zero-list gains `zone_left_at` (the classification table is the
enforcement point).

### D3 — What advances, what already advances, what NEVER advances

- **NEW (J-7's whole delta):** positions of displaced LIVING humans
  in the re-entered zone — finite walk along the home path.
- **Already advancing by construction (documented + pinned, not
  built):** respawn `at_frame` maturation, corpse/drop expiry —
  global-frame math. J7-B adds a pinning test naming this so the law
  is explicit, and touches none of it.
- **Explicitly NOT advancing:** hp (leash-with-no-heal A2 + today's
  kept-hp snap-home — both precedents keep hp); XP/economy (nothing
  per-zone exists to advance; shelf's "shop restocks" has no shop
  system — out of scope, parked in-brief); AI state (focus dropped,
  taunts/transients cleared — today's law verbatim); leash
  guard-shift counterfactuals (catch-up walks to the PLAIN home tile;
  reconstructing corpse-guard shifts mid-absence would be fake
  precision — one-line honesty note in the code); across-session
  anything (D2).

### D4 — The advance function: pure, RNG-free, linger-then-walk

For each displaced living human in the re-entered zone, with
`elapsed = @frame − stamp`:

- `walk_ticks = max(0, elapsed − leash_linger_frames)` — the frozen
  human "would have" lingered first (leave-and-immediately-return
  reads as nobody moved: honest and cheap).
- `tiles = walk_ticks / kit step_frames` (integer division; both
  values are EXISTING data knobs — zero new balance constants).
- Advance `tiles` steps along the static flow-home field from the
  frozen tile toward `home_tile` (walls-only `blocked: []`; the field
  is the same `FlowField#downhill_from` the live leash uses); clamp
  at home.
- **Stacking tie-break:** process in roster order; a computed tile
  already taken by an earlier catch-up placement holds one step
  short (deterministic, no RNG).
- Place via `rebind` (tween cleared), focus nil, THEN pre-set the
  leash counter to the linger threshold (`resume_leash!`, a tiny
  Creature API) so a mid-path human resumes walking immediately —
  without it the human double-lingers, which the counterfactual
  never did. Digest already reads creature fields; determinism
  unaffected either way.
- **No-stamp path = today's snap-home VERBATIM** (first-ever entry:
  no-op; same-zone wipe respawn: humans snap home exactly as today —
  in-zone wipe feel is ritual-adjacent difficulty and J-7's mandate
  is CROSS-zone re-entry only).
- Draws ZERO rng (`rng_draws` digest field provably unmoved by a
  leave/re-enter with no combat).

### D5 — Determinism / netplay: inside lockstep, digest-covered, version-bumped

The catch-up runs inside `enter_zone` inside the tick — both seats
execute it at the same tick on identical state; there is NO
host-authoritative step (asking for one would admit the function
isn't pure). Belt: digest gains a world row
`["zone_left_at", sorted "zone:frame|…" string]` (the `breached`
row's exact pattern), so a stamp divergence desyncs LOUDLY instead
of silently. Digest grammar change ⇒ **`DIGEST_VERSION` 2 → 3** ⇒
mixed builds refuse at handshake with the differing field named
(existing fingerprint law — the compat story, no new machinery).
Replays: fresh-world deterministic by construction.

### D6 — Perf: zero per-tick cost, bounded transition cost

No per-tick hook anywhere (the REFUSED background ticking stays
refused; J7-B's `tick_world` diff is ZERO lines). Cost at re-entry
only: one FlowField BFS per unique home tile + O(path) steps per
displaced walker — the same order of work `enter_zone` already does
for cameras/gate fields. `rake perf` must stay green; the district
scenario doesn't cross zones, so any regression it shows would be
accidental coupling = investigate, never wave through.

### D7 — Rule 2 artifact: 26th wall script `zone_catchup.json`

The capture that proves catch-up in pixels: **district ↔ nest** is a
free round-trip edge pair (district[0,13]→nest, nest[29,8]→district;
no defeats/level/seal gates — verified from zone data this session).
Script shape: spawn → aggro a human off its home (pull it several
tiles along the chase) → cross to the neighbor zone → wait a scripted
tick count (long enough for linger + a few steps, short enough that
home isn't reached — computable exactly: 90 + k×step_frames) →
cross back → captures on the re-entry frames. The frames prove BOTH
halves: the human is NOT at its frozen chase tile (catch-up ran) and
NOT at home (finite speed — the snap-home teleport is dead). A
second later capture shows the residual walk finishing (free
legibility: the player can SEE them walking home, the owner's exact
ask). Gate critic-ON against `harness/gate_checks.json` defaults +
its own positional checks. Wall 25 → 26.

### D8 — Identity-pair belt + wall movement pre-declaration

- **J7-A (extraction): NOTHING moves.** world_loop + low_quay_run
  pairs 24/24 byte-identical, suite green unmodified, zero digest
  change, zero data change. Any moved byte = the refactor isn't pure
  = BLOCK.
- **J7-B (behavior): expectation is STILL 24/24** — snap-home only
  differs where a stamped zone is re-entered with displaced humans.
  At J7-B open the executing session READS both pair scripts and
  pre-declares in its worklog whether any leg re-enters a zone after
  displacing a human. If a pair moves anyway: R-A2 re-baseline law —
  every moved capture justified frame-by-frame (re-entry frames
  only), then full detached wall sweep (`harness/run_wall.sh`, never
  under a bash timeout) + re-baseline. Movement outside justified
  frames = BLOCK.
- Netplay gates ×3 critic-ON re-run at J7-B regardless (foundation:
  catch-up is lockstep sim surface; DIGEST_VERSION moves handshake
  bytes). This seat runs them (creds law, s54/s56 precedent).

### D9 — Telemetry: one line, pinned here, soak-minable

`TELEMETRY catchup zone=<name> elapsed=<ticks> advanced=<n>` emitted
at re-entry ONLY when a stamp was consumed and n > 0. Executing
session authors zero wording. Measurement hygiene: v18 verdict is
closed and the v19 ritual is not yet staged, so new TELEMETRY
wording is legal NOW and freezes with the runsheet at ritual staging
(this line is forensics/soak-mining, not a ritual oracle).

### D10 — Ritual-frozen knobs: J-7 adds NONE

J-7 lands zero new balance values and retunes zero existing ones —
it REUSES `leash_linger_frames` (threat.json) and per-kit
`step_frames` (combat.json). The sim numbers the pending ritual
measures (respawn pacing, difficulty, sustain) are untouched by
construction: no `at_frame` math moves, no spawn counts move, no hp
moves. What J-7 changes is the FELT result of leaving-and-returning
— a Lane 3 ratified build, sequenced before ritual staging exactly
so it gets ordinary play exposure first (novelty quarantine
satisfied naturally).

### D11 — Events + strings: nothing new

No new EventBus symbols (`:human_leashed` already carries the
returning-home meaning; catch-up placements emit it with today's
payload shape only where snap-home emitted it — the executing
session verifies emission parity in tests). No new player-visible
strings, no locale rows — a sim-feel feature. The Rule 2 gate rides
the new script's captures, not prose.

## Ticket cut (each sized to one session)

### J7-A — Homecoming extraction (pure refactor)

- Move the D1 cluster into `src/game/homecoming.rb` (plain object,
  callable readers per Crossing/PriceSheet pattern); World delegates
  keep the controllers' view contract byte-stable.
- Belt: suite green via hooks (threat_leash/guard_scope untouched
  and green) · pairs **24/24 byte-identical** · zero digest/data
  diff · world.rb line count RECORDED in the close (~1736 expected).
- Rule 2: no visual change — the identity pairs ARE the proof (no
  new capture surface, wall stays 25). One commit
  (`refactor(world)`).

### J7-B — stamp + cold catch-up (the sim change)

- `@zone_left_at` stamp on leave · catch-up in Homecoming per D4 ·
  no-stamp snap-home preserved verbatim · `resume_leash!` Creature
  API · digest row + **DIGEST_VERSION 2→3** · telemetry line (D9) ·
  save_state_test transient zero-list gains `zone_left_at`.
- Test lanes: `homecoming_test.rb` (advance math incl. linger edge,
  integer division, clamp-at-home, stacking tie-break, stamp
  consumed, rng_draws unmoved) · world integration (displace →
  leave → wait → re-enter placement; same-zone wipe still
  snap-homes; `:human_leashed` parity) · the D3 pinning test naming
  respawn/expiry global-frame catch-up as existing law.
- Gates: suite via hooks · NEW wall script `zone_catchup.json`
  critic-ON (D7) · pairs per D8 (pre-declared, R-A2 law on
  movement) · netplay gates ×3 critic-ON · `rake perf` · soak N=1
  (bots cross zones; chain + telemetry line sanity).
- Commits: one sim commit (`feat(world)`) + one harness commit
  (`test(harness)`) if the script lands separately — one concern
  each.

Two tickets total. J7-B is the heavy one (gates run detached —
budget the full session; the s56 ladder is the scale precedent).

## Wall-debt audit (why the 25 shipped scripts should not move)

Zone-start duel/fixture scripts never leave-and-return; loop scripts
are the only candidates and only if they re-enter a zone AFTER
displacing a human mid-chase — pre-checked at J7-B open per D8. The
new surface gets its own permanent script instead of bending an
existing one (menu_tour precedent).

## Line budget + stop conditions

- world.rb ≤ 1800 (cap test) — J7-A buys headroom BEFORE J7-B
  spends ~8; window.rb untouched (no app-layer change).
- STOP and re-brief (never improvise) on: any J7-A pair byte moving
  · a D4 assumption refuted in code (e.g. rebind/leash API can't
  hold the contract) · wall movement outside pre-declared frames ·
  digest bump surfacing any handshake path beyond the named
  fingerprint refusal · world.rb cap pressure past the estimates ·
  owner redirect.

## Banked amendments — carrier check (s56 rows)

- **gate_checks beat-row clause** ("next `harness/net/gate_checks.json`
  toucher adds a beat-row clause to `net_menu_panels_read`"): J7-B
  RE-RUNS the net gates but must not TOUCH that file; if any J-7
  change is forced into it, the beat-row clause comes due same
  commit — carried into both tickets' close checklists.
- **Volume rider** (audio RECEIPT outbound): not J-7's surface;
  carries in the checkpoint.
- **Register re-pin** (`hud.level`/`net.link_slow` mixed into
  invariant panels; Junior ask 2, unratified): strings-only,
  one-concern law keeps it OUT of J-7 tickets; lands as its own
  gated strings commit if/when ratified.
- **CLAIMED protocol** (Junior ask 3): modeled by this session's
  first action; ratification still his.
