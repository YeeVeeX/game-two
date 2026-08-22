# T1 close — Progression extraction + save schema v2 + round-trip lane (session 41, 2026-08-22)

Ticket: `drafts/_prog-t1-extraction-schema-v2.md` · spec
`docs/superpowers/specs/2026-08-22-progression-v1.md` (P3/P8/P14).
One session, one concern, as cut. **All four verify steps green;
fresh-eyes review PASS (0 blockers). SHIPPED.**

## What landed

- `src/game/progression.rb` (NEW) — `Game::Progression` plain object
  (Crossing/FieldEconomy/PriceSheet pattern): level, xp, ΔE curve math
  (`delta_e`, `award` — pure, ZERO callers in src/ until T2),
  `record_boss_1_defeat!`, `load_counters!`/`load_progress!` seams;
  curve constants Integer-forced at construction (named refusal).
- `src/game/world.rb` carve — `@boss_1_defeats`/`@sessions` ivars,
  `load_counters!`, the :1627 increment and the digest rows all moved
  behind Progression; World keeps construction + two delegated readers
  + the crossing callable rewire (`-> { @progression.boss_1_defeats }`;
  crossing.rb itself untouched, as the brief predicted). **1800 → 1797.**
- `src/game/save_state.rb` — SCHEMA=2; FACT_KEYS + "progression";
  `V1_FACT_KEYS` frozen; shared `facts_refusal` body + 4-direction
  `progression_refusal`; projector emits `{level, xp}`; pure
  `upgrade_v1`; apply! clamps level→cap and xp→ΔE(level+1)−1
  (warn+proceed, curve read via the live Progression object).
- `src/app/save_store.rb` — schema-1 load = one-hop upgrade + NAMED
  notice; ORIGINAL bytes back up to `.bak-schema1-<ts>` at the FIRST
  v2 write (COPY, not rename — write-time so read-only consumers like
  `rake map` stay side-effect-free and a session that never saves
  leaves the v1 file untouched).
- `data/balance/progression.json` (NEW) — spec shape sketch verbatim;
  only `:curve` is read in T1.
- `src/map_main.rb` PROBE_FACTS + 7 test fixture trees gained the
  mandatory `progression` key; persist-line tests retargeted
  schema=1→2; skew test 2→3. Soak oracle unaffected (chain_check
  regex is `schema=\d+`).

## Verify (recorded outputs)

1. **Suite:** `bundle exec rake` → **1045 runs, 18917 assertions, 0
   failures, 0 errors, 0 skips** (includes line_caps + both new lanes).
2. **Line cap:** `wc -l src/game/world.rb` → **1797** (< 1800 strictly).
3. **Byte-identical rendering (world_loop.json):** run A vs run B →
   `CAPTURE_MD5_IDENTICAL frames=10`; **plus** old-build baseline
   (worktree @ `a85e88c`, pre-change) vs new → `OLD_VS_NEW_IDENTICAL
   frames=10` — no behavior a capture can see, proven against the true
   pre-change build, not just run-to-run.
4. **Netplay gate:** `rake gate SCRIPT=harness/net/netplay_session.json
   CHECKS=harness/net/gate_checks.json` → rc=0, "GATE determinism: 12
   captures byte-identical across two runs", "GATE vision: PASS",
   **GATE PASS** (digest byte-form unmoved; DIGEST_VERSION still 1).

**Fixture proof on the owners' real byte-shape** (tmp copy; live file
never opened for write): live `saves/world.json` md5
`98fe75edb6d72deab18cd48eaa88bdaf` (341 B, schema 1) → copy loads with
the upgrade notice, progression={level 1, xp 0}, banked=7, sessions=13
intact; first write creates exactly ONE `.bak-schema1-<ts>` whose md5
EQUALS the original; rewritten file schema=2; reload silent; live file
md5 unchanged after the whole proof.

## Round-trip test names (the new lane)

save_state_test: `test_v1_facts_validate_under_the_frozen_v1_rules_only`
· `test_envelope_refusal_routes_schema_1_to_the_v1_rules` ·
`test_upgrade_v1_injects_fresh_progression_and_is_pure` ·
`test_v1_upgrade_round_trip_is_v2_byte_stable` ·
`test_progression_facts_round_trip_through_apply` ·
`test_apply_clamps_level_to_the_current_cap_warn_and_proceed` ·
`test_apply_clamps_xp_below_the_next_level_cost_warn_and_proceed` ·
11 new refusal-table rows (pass AND fail directions).
save_store_test: `test_schema_1_file_loads_upgraded_with_a_named_notice`
· `test_first_write_after_v1_load_backs_up_the_original_bytes_exactly_once`
· `test_v1_load_and_coordinator_quit_lands_v2_plus_backup`.
progression_test: 13 pure-unit runs (curve rows, award boundaries, cap
pin, load seams, Integer refusals).

## Fresh-eyes review (Rule 6 gate)

Headless scrubbed pi over the diff bundle + brief + spec (read-only,
mail-untouched). **VERDICT: PASS — 0 blockers, 3 NITs** (receipt
content preserved here; raw at tmp/t1_review/receipt_raw.md until tmp
cleanup). Two-way alignment table complete in both directions; scope
audit found no creep; defect hunt covered load paths, crash windows,
clamp off-by-ones, Integer discipline, test honesty — all clean.

## T2 brief amendments (flagged per the brief's done-clause)

1. **[NIT→T2] bak_hint ordering:** `Dir[…].max` is lexicographic, so
   `.bak-schema1-*` sorts above newer date-stamped `.bak-*` files in
   the corrupted-save recovery hint (`'s' > '2'`). Wording-only. Fix
   in T2's save_state/store touch: mtime-max or exclude schema1 from
   the hint glob.
2. **[NIT→T2] @v1_raw hygiene:** not cleared on a later v2 load;
   backup fires before canonical_bytes could raise. Worst case = a
   redundant backup holding genuine v1 bytes (never loss). Clear on
   non-v1 loads while in the file.
3. **[NIT→T2] data shapes unpinned:** growth/kill_xp/spell_growth in
   progression.json are parse-pinned only; T2's readers must land
   shape assertions when they start reading them.
4. **API note:** T1 shipped `Progression#award(amount)` (pure); T2
   adds the `award_kill(kit_name)` wrapper reading the kill_xp table
   (P2/P14 signature) + the `:level_up` bus event + digest rows
   `["level", N], ["xp", N]` + DIGEST_VERSION 1→2 in one commit (P13).
5. **Disclosure nuance (recorded, not a defect):** on a just-upgraded
   v1 file the loaded persist line prints `schema=2` (the facts as
   loaded) while the file on disk is still schema 1 until first write;
   the upgrade notice directly above discloses this. Wording revisit
   only if a human trips on it.

## Measurement hygiene

Ritual wording still UNWRITTEN · no sim number moved (k/cap are
skeleton constants NOTHING reads for behavior until T2) · R-A2 silent
· bot logs never fun-evidence. Live save untouched (md5 verified
before and after).
