# Ticket T1 — Progression extraction + save schema v2 + round-trip lane

Lane 1 / Progression v1, ticket 1 of 5. Spec (the map, read first):
`docs/superpowers/specs/2026-08-22-progression-v1.md` — decisions
P3/P8/P14 are this ticket's law. One fresh session; NO other lane
work rides along.

## Goal

Carve `Game::Progression` out of world.rb (which sits AT its 1800
cap) and land save schema v2 with the one-hop v1 upgrade — WITHOUT
changing any behavior a capture can see. Level stays 1, xp stays 0,
no stat growth applies, no XP awards. This ticket buys the headroom
and the persistence rails; T2 turns the system on.

## In scope (files)

- `src/game/progression.rb` (NEW) — plain object, the Crossing/
  FieldEconomy/PriceSheet extraction pattern (constructor takes data
  + collaborators; World stays the only sim mutator; no bus
  subscription inside — World calls it).
- `src/game/world.rb` — carve: `@boss_1_defeats`/`@sessions` ivars,
  `load_counters!`, the increment at ~:1627, digest rows at ~:656
  move BEHIND Progression readers. World gains: one `@progression`
  construction + delegated readers (`boss_1_defeats`, `sessions`
  attr_readers become delegations). Net line count MUST end < 1800.
- `src/game/crossing.rb` — `defeats:` callable rewires to
  `-> { @progression.boss_1_defeats }` at the construction site in
  world.rb (crossing.rb itself likely untouched — verify).
- `src/game/save_state.rb` — SCHEMA = 2; FACT_KEYS + "progression";
  PROGRESSION_KEYS = %w[level xp]; projector emits
  `{"level" => world.progression.level, "xp" => world.progression.xp}`;
  refusal_for gains progression_refusal (named refusals: not an
  object, wrong keys, level not Integer >= 1, xp not Integer >= 0);
  apply! clamps: level > cap → cap (warn), xp >= ΔE(level+1) →
  ΔE(level+1) − 1 (warn) — the hp-clamp law verbatim (curve read via
  the Progression object, NOT reimplemented in save_state).
  envelope_refusal: schema 2 current; schema 1 routes to the upgrade
  lane; anything else refuses NAMED (existing message shape).
- **v1 upgrade lane** (where the load path lives — follow the current
  strict-decode call sites, likely src/main.rb / the save
  coordinator): schema 1 envelope → v1 strict validation (existing
  FACT_KEYS frozen as V1_FACT_KEYS) → inject
  `"progression" => {"level" => 1, "xp" => 0}` → proceed as v2.
  BEFORE the first v2 WRITE over a file that was schema 1: copy the
  original bytes to `world.json.bak-schema1-<ts>` (the --fresh
  backup-law pattern, same timestamp format). Joiner path untouched
  (never keeps a save).
- `data/balance/progression.json` (NEW) — the spec's shape sketch,
  skeleton values (curve k/cap + growth pcts + kill_xp + spell_growth
  present so the shape is round-trip-tested; NOTHING reads growth/
  kill_xp until T2).
- Tests: `test/game/progression_test.rb` (curve math: ΔE values,
  level-from-award boundaries — pure unit), extend
  `test/game/save_state_test.rb` (or sibling) with the ROUND-TRIP
  LANE: v1 fixture → upgrade → apply → project → encode = v2
  byte-stable; v2 → v2 identity; EVERY new refusal direction (pass
  AND fail); clamp directions warn+proceed; backup file created
  exactly once with original bytes (md5 equal). Counter behavior
  (defeats increment, sessions bump, digest rows) covered by existing
  tests — they must stay green UNCHANGED (that is the refactor
  proof).

## Out of scope (T2+ — do not touch)

XP awards (`actor_died` untouched beyond the counter-line move) ·
stat growth application · digest_snapshot NEW rows / DIGEST_VERSION
(byte form must NOT change this ticket) · TELEMETRY line · HUD ·
requires_level · lobber growth reader wiring · any data value tuning.

## Laws that bite

- Read every file before editing (Rule 4); world.rb regions to read:
  init (~40–135), actor_died handler (~1600–1680), digest_snapshot
  (~633–660), load_counters!, save write path.
- Digest byte-form FROZEN this ticket: `["boss_1_defeats", N],
  ["sessions", N]` rows keep exact names/positions (read through
  Progression). Netplay gates prove it if in doubt.
- Canonicalizer leaves: Integer/String(ASCII)/Boolean only — level/xp
  are Integers by refusal.
- The LIVE save `saves/world.json` (md5 `98fe75ed…`) is the owners'
  progress: tests run on fixtures under tmp/ or test/fixtures — NEVER
  point a test at saves/. Do not launch a save-owning seat during
  this ticket (fork law).
- Hooks run the suite on commit; a red suite blocks — fix, never
  --no-verify.

## Verify (run, record output in the ticket-close draft)

1. `rake` — full suite green (includes line_caps_test proving
   world.rb < 1800 and the new round-trip lane).
2. `wc -l src/game/world.rb` — paste the number (strictly < 1800).
3. Byte-identical rendering:
   `rake capture SCRIPT=harness/scripts/world_loop.json` twice,
   md5 the frame sets, compare (no visual surface moved — any delta
   = STOP, escalate to full gate + investigate).
4. `rake gate SCRIPT=harness/net/netplay_session.json
   CHECKS=harness/net/gate_checks.json` — digest byte-form unmoved
   proof (cheap insurance; the two-World scene catches a snapshot
   drift immediately).

## Done when

All four verify steps pass and are recorded in
`drafts/_prog-t1-close-<date>.md` (with the world.rb line count and
the round-trip test names), commit lands with the conventional
message, push clean. The close draft flags anything discovered that
should amend T2's brief.
