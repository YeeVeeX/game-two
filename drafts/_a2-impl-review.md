# A2 implementation adversarial review ledger (workflow wf_554c0d1c-303, 2026-08-12)

3-lens review (code-fit / spec-design / harness-tests) of the FULL a2-threat branch diff
(26 commits, 01fed5d..e1f6675, 216KB package), every finding adversarially verified by an
independent refuter. 4 agents (3 finders + 1 refuter), 479,296 subagent tokens, 0 errors.
Spec-review ledger (11 refuted findings, drafts/_a2-spec-review.md) was carried into every
prompt — none were re-raised.

VERDICT: 1 finding -> 1 REFUTED, 0 CONFIRMED. The branch ships as-is.

- code-fit lens: 0 findings (traced select_target/tick_human/pressure_step/leash_home,
  focus/partition/beachhead/flow_home/enter_zone snap/respawn suppression/gradient,
  creature threat state, pack initial_kit; no determinism, event-law, constants, or
  cross-zone-leak defects found).
- spec-design lens: 0 findings (S1-S6 all landed as specified; scope law clean: no economy
  code, no new bindings, no kits beyond rusher_hater, corpse paths untouched).
- harness-tests lens: 1 finding, refuted below (gate_checks ADD-ONLY verified; a2_fired
  bucketing correct; no weakened pins).

## Refuted (recorded so nothing re-raises it)

### [low/code-fit-of-telemetry]
CLAIM: Telemetry deepest_band reads the CURRENT zone's drop_gradient at summary-print time
(telemetry.rb:67), so quitting from the nest (e.g. Esc during the wipe-respawn window)
prints deepest_band=0 despite deep farming.
REFUTATION: The scenario is factually wrong about zone state: during :nest_respawn only the
timer ticks — @zone_name is NEVER reassigned during the 90-frame window (world.rb:105-110,
861); respawn_pack sets HOME_ZONE only after expiry. Esc during the window resolves the
DISTRICT map and computes the band correctly. The only reachable arm (quit within a step of
respawning in the nest) affects a cosmetic terminal-printed summary; @max_gate_distance
itself is accumulated correctly. Harness scripts (the verify instrument) always end in the
district and are immune.

## Deferred minors carried from task reviews (triaged: none block merge)

- Task 5: ring-hold test's on_ring||still_moving disjunction is weak only if all 16 ring
  tiles are occupied (impossible at pinned data values).
- Task 6: dead humans skip reset_leash! in the enter_zone snap — counter inert on dead
  bodies, matches the plan's own pseudo-code.
- Task 11: leash_walkback_reads passes as "not exercised" in threat_pull (camera-aggro
  tension caps static-frame legibility; the walk-home is verified live-in-motion at the
  fun-verify); specials_chain's taunt underline is structurally unexercisable there (both
  victims die during the pulse) and is actively exercised + passing in taunt_anchor.
