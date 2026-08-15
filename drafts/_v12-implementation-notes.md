# v12 implementation notes — working state harvest (2026-08-13, mid-TDD)

Committed spec is SSoT: `docs/superpowers/specs/2026-08-13-v12-arc-purpose-design.md`
(review ledger: `drafts/_v12-spec-review.md` — 49 agents, 12 findings 0 confirmed,
6 cap-dropped hand-dispositioned, 4 folds applied). This file carries ONLY the
increment-order working notes that lived in session context.

## Increment plan (5 green commits on v12-arc; 1 is DONE)

1. **DONE `f7ff543`** — gradient_anchor + seal + breach + camp zone + presentation.
   Tests: `test/game/seal_breach_test.rb` (13 runs). Suite 315/1288 green at commit.
2. **Re-homing**: `@home_zone` replaces the four `HOME_ZONE` use sites (world.rb:
   initialize's enter_zone stays initial-home; enter_zone sets home on entering a
   `hub` zone when changed + emits `:home_rehomed {zone:}` (EVENTS += it);
   respawn_pack re-enters `@home_zone`; interact_vat regrows into
   `@zones.fetch(@home_zone)` pack_spawns). KEEP the `HOME_ZONE` constant as the
   initial value — `test/game/economy_vat_test.rb:39` reads it. nest.json gains
   `"hub": true`. Existing wipe pins stay true (they never enter camp).
   New tests: rehome emits once, not on re-entry; wipe respawn lands at camp
   pack_spawns; vat regrow targets camp after re-home; nest-only session
   behaves exactly as today.
3. **The Keyward + The Slow Door**: `district_two.json` — 44x26 NEW block layout
   (tighter alleys deeper), rusher x16 + rusher_hater x4, `drop_gradient
   [[0,2.0],[14,2.5],[28,3.0]]`, `gradient_anchor [1,13]`, 3 pack_spawn near the
   west gate, palette black-and-ochre (Vaultwarden colors), transitions:
   `[0,13] -> camp (spawn [18,5])`; seal2 station `{"type":"seal","at":[41,13],
   "price":"breach_cost_2","opens":[42,13],"line":"THE WAY IS PAID"}` + sealed
   transition `[42,13] -> slow_door (spawn [7,6])`. camp.json ADDS forward
   transition `[19,5] -> district_two (spawn [1,13])` (tile row 5 already open
   at col 19 by design). `slow_door.json` ~14x9, EMPTY (no spawns/stations),
   banner "The Slow Door", 3 pack_spawn (validation furniture), transition
   `[7,7] -> district_two (spawn [40,13])`, near-black palette + one warm
   accent. economy.json gains `"breach_cost_2": 150`.
4. **Telemetry + harness + checks**: TELEMETRY `arc` + `q6_margins` lines —
   formats verbatim in the spec (zero-case always prints, subscriber-alive
   law). `harness/scenes/world_scene.rb` event log list += `seal_breached`,
   `home_rehomed`. `harness/gate_checks.json` APPEND #41 `seal_breach_reads` +
   #42 `new_ground_reads` (wording in spec Harness section; 40 -> 42 add-only).
5. **Riders (data)**: threat.json density: join_radius 3->4, pocket_cap 5->6,
   corpse_guard_tiles 6->10 (scatter + cadence UNTOUCHED — difficulty pinned).

## Traps already hit (do not re-derive)

- **Breach feel kick = 8 hitstop frames**: hitstop pauses transitions, respawn
  countdowns, and cosmetic clocks (banner law). Post-breach test drives need
  `HITSTOP_SLACK` (see seal_breach_test.rb) or they flake.
- **drafts/_* is GITIGNORED** — review ledgers/verdicts stay local by design;
  the committed record is spec + CHECKPOINT.
- **gradient trap is REAL and covered**: DataStore keys are SORTED, camp sorts
  before nest; without gradient_anchor the district band map flips. Pinned by
  `test_district_band_map_pinned_despite_new_zone_arrivals` (watched fail).
- **world_test.rb pin updated** (meaning change IS the increment):
  `test_district_arrival_tiles_cover_both_doors` (was nest-only arrival).

## Wall plan (after increment 5)

- 11 existing scripts on disk (9 gameplay wall + moving_square + critic_reel);
  new `nest_advance.json` pilot-authored (act list in spec) -> 10-gate wall.
- Triage ALL: expected desync sources = rider values (anchor shifts) + the
  camp-side beachhead over [38,12] (acquisition changes pre-waiver). Zone adds
  otherwise behavior-neutral (verified reasoning in spec Harness section).
- Checks 42; #41/#42 exercised by nest_advance; Slow Door stays unstaged
  (150-toll grind), covered by unit tests + not-exercised hatches.
- Perf: `rake perf` ALONE first (scenario = district one, unchanged baseline).

## Tenth verify (pre-registered in spec — do not re-derive)

Questions 1-8 + routing table live in the spec's Fun-verify section verbatim.
Harvest telemetry BEFORE questions: arc, density, q6_cadence, q6_margins.
