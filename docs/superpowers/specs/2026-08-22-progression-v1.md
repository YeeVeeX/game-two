# Progression v1 — design spec (2026-08-22, grill s40)

Owner-ratified Lane 1 (v19 headline; foundation
`drafts/_v19-foundation-20260822.md` rows 1–4, double-ratified
2026-08-22). Answers the v18 verdict's shared correction ("segue muito
dificil chegar no boss") and the owner's more-firepower vote. Working
language English; every player-visible string is a generic placeholder
(standing order 2026-08-16). Tickets at the end are the durable
execution artifact; one ticket = one fresh session.

## Ratified frame (from the foundation — not re-litigated here)

- **A1:** XP-levels, not skill-through-use (parked with its telemetry
  debt; touchstones WoW/TES are level-based).
- **A2:** carrier = THE PACK — one level, one XP total; the player IS
  the pack under Tab-possession; per-body leveling would punish the
  possession mechanic. In netplay both seats share the pack level
  (inside lockstep, digest-covered).
- **A3:** death never eats XP in v19 — failure stays priced in
  supplies + time. Tibia-hard XP loss recorded as a future valve.
- Staging 1–5 (grill → sim core → HUD → lobber-E growth →
  `requires_level`), gates owed, and the world.rb extraction flag are
  the foundation's text; this spec refines them into decisions.

## Shelf re-verification (Rule: FLAGGED numbers never land in data/)

Read in full this session (all `status: active`, `decay_class: slow`):

- `rpg-xp-curves-and-leveling-formulas` (verified 2026-08-09) — the
  level-curve formulas used below are transcription-verified; the
  note's ⚠️ LOST-IN-CAPTURE flags hit only Tibia skill/vocation
  constant tables and spell-multiplier tables, none of which v19 uses
  (skill-through-use is parked, A1). §6's concrete starting shape is
  adopted (P1).
- `damage-elements-and-combat-math` (verified 2026-08-17, per-claim
  adversarial pass 2026-08-16) — §6 recommended stack adopted in
  integer form (P5); its variance band and K-curve REFUSED/DEFERRED
  for v19 with reasons (P6/P7).
- `death-penalties-stat-scaling-and-progression-balance` §6 — consistent
  with A3 (no XP component in death this cycle); its blessing-economy
  material stays with the parked future valve.

## Decisions

**P1 — XP curve: polynomial ΔE, Tibia-family, data-driven.**
Per-level cost `ΔE(L) = k·(L² − 3L + 4)` (XP to go from level L−1 to
L), the shelf note §6's reskin of Tibia's verified quadratic
(`50L² − 150L + 200 = 50·(L² − 3L + 4)`). Exponentials REFUSED for a
low-cap slice (they exist to stretch uncapped tails; under a cap the
last levels read as arbitrary walls). Starting constants — SIM
NUMBERS, unfrozen until the ritual stages, tuned via the pacing
script (P11): `k = 40`, `level_cap = 10`. All constants live in
`data/balance/progression.json`; zero curve math hardcoded (Rule 3).
The −3L term keeps levels 2–4 near-free (onboarding); the cap keeps
the boss-reach gap the curve's business end.

**P2 — award rule: kill XP on `actor_died`, killer faction == :pack.**
Hooked in the existing `actor_died` handler (world.rb:1604 region) —
the one place deaths already resolve (defeat counter precedent). ANY
pack-member kill feeds the pack (A2) — possessed OR ally: the third
body contributing XP is part of the lemming fix's feel story. Kill XP
is per-enemy-kit, data-driven (`kill_xp` table in progression.json:
husk lowest, rusher low, rusher_hater mid, challenger = boss-sized).
No XP from any other source in v19 (no quest/discovery/damage XP —
single income keeps the pacing model one-dimensional and auditable).

**P3 — facts shape: `level` + `xp` (progress INTO current level).**
NOT cumulative XP: level is the fact, xp is progress toward the next.
Rationale = the save-robustness law already in save_state.rb (hp
clamps when kit max changes — "balance churn must not brick saves"):
if level derived from cumulative XP, any curve retune would silently
re-level every save. With level-as-fact, retunes only reprice FUTURE
levels; at apply-time `xp` clamps to `ΔE(level+1) − 1` (warn, exactly
like the hp clamp) and `level` clamps to the cap if the cap lowered.

**P4 — level-up effect: max stats rise; hp gains the DELTA; no full
heal.** Full heal on level-up REFUSED — free sustain would fight the
provisions economy (D1b) and the mercy-floor lane (B4). `max_hp` and
damage recompute from level; current hp += (new_max − old_max). The
level-up moment is a FEEL BEAT (stage-3 ticket): banner stamp + pop
via the kill_pops precedent (transient render record, integer phase,
digest-excluded presentation).

**P5 — stat formula: linear-in-level INTEGER growth, per-kit bases.**
Adapted from the damage-note §6 stack ("never square stats"), integer
form (the coop-scalar law: no Float ever enters the balance path —
world.rb:61-63 precedent):

```
damage(kit, L)  = base + (base * (L−1) * dmg_growth_pct) / 100   # Integer division
max_hp(kit, L)  = base + (base * (L−1) * hp_growth_pct)  / 100
```

Bases stay in combat.json kits (unchanged); growth percents live in
progression.json (per-stat, possibly per-kit later — one shared pair
to start). Pinned evaluation order where coop composes:
**kit base → level growth (integer) → coop scalar (.round)** — one
order, both seats, digest-proven. Enemy kits read NO level term
(P7).

**P6 — variance band: REFUSED for v19.** The shelf recommends a
0.85–1.00 roll; this game is a deterministic lockstep ARPG where
dodge/positioning IS the variance. A damage roll would consume RNG
per hit (digest churn, wall-baseline churn, replay noise) and buy
zero legibility. Recorded as a future candidate only if flat damage
reads as monotony in a ritual.

**P7 — no enemy-side level scaling; K-curve mitigation DEFERRED.**
The world stays fixed; the PLAYER grows — that closes the boss-reach
gap honestly (attainable-hard, not treadmill). Deeper zones get
harder via WB authoring (stronger kits placed deeper), never via
level-scaled stats. K-curve armor waits for an equipment era (no
armor stat exists; items are parked).

**P8 — save schema v2 + one-hop upgrade lane (backup law).**
`SaveState::SCHEMA = 2`; facts gain one key:
`"progression" => {"level" => Integer >= 1, "xp" => Integer >= 0}`
(canonicalizer-legal leaves; FACT_KEYS/refusal_for extended with the
same named-refusal style). Schema 1 saves get a ONE-HOP UPGRADE, not
a refusal — the owners' live shared save (`98fe75ed…`, their first
crossings) must never be eaten by a version bump: decode v1 strictly
under v1 rules, inject `progression = {level: 1, xp: 0}`, and BACK UP
the v1 file to `world.json.bak-schema1-<ts>` before the first v2
write (the --fresh backup-law pattern). Anything else refuses NAMED
(`save schema: N unsupported…` stays). The joiner never keeps a save
(v18 law) — upgrade logic is host/solo-side only by construction.

**P9 — `requires_level` transition gate, machinery-only.** Sibling of
`requires_defeats` end to end: tile_map.rb load-time validation
(positive Integer, refuse NAMED), crossing.rb `open?` one more
fact-gate line reading a live `level:` callable, same shut-way
refusal cue surface as an unmet defeats gate PLUS the required level
named in the cue (placeholder register: `LEVEL 3 REQUIRED`). Zone
authoring (WHERE gates go) belongs to the WB lane / owners; Lane 1
ships the machinery + a test fixture zone only.

**P10 — per-spell growth, lobber E first.** progression.json carries
a per-kit spell-growth table keyed by level thresholds; v19 ships ONE
entry: lobber special `impact_distances` gains reach with level
(data-shaped today: `[2,3,4]`), positioning lobber as the mid/late
bloomer (owner's es-CR extension, ratified). Shape:
`{"lobber": {"special_impact_distances": {"5": [2,3,4,5], "8": [2,3,4,5,6]}}}`
— full-array replacement per threshold (no arithmetic on arrays; the
active array is the highest threshold ≤ level; base array below the
first threshold). Numbers are sim-unfrozen starters.

**P11 — pacing is designed, not discovered.** A ~20-line script
(`tmp/`, not shipped) tabulates: cumulative XP per level, on-level
kills-to-level for each enemy kit, and hours-per-level under a
kills/hour assumption (Aversa method, shelf §2/§6). Target for the
slice: single-digit kills to level 2; tens by mid-cap. Runs on every
constant retune; output pasted into the tuning commit message or
draft.

**P12 — observability (ritual Half A owes bytes).** The session
TELEMETRY close line gains `level=N xp=N kills_xp=N` (kills_xp =
XP earned THIS session — the ritual's "kill-XP earned > 0 inside the
ritual sessions" proof reads it straight from human launcher logs).
Log-only, close-time, both solo and netplay paths.

**P13 — determinism/netplay surface.** XP award + level-up run INSIDE
`World#tick` (bus handler) — lockstep-safe by construction.
`digest_snapshot` gains `["level", N], ["xp", N]` rows;
`DIGEST_VERSION` bumps 1 → 2 in the same commit (the byte form
changed; handshake refuses cross-version sessions NAMED — the
existing law). New bus event `:level_up` registered when first used
(non-negotiable 4). Netplay gates re-run in the sim-core ticket; solo
wall scripts re-baseline only where visuals change (T3/T5).

**P14 — world.rb extraction: `Progression` plain object (ticket 1,
the Crossing/FieldEconomy/PriceSheet pattern).** world.rb sits AT
1800/1800 — headroom must be CARVED before any progression line
lands. `Game::Progression` owns: level, xp, curve math + award
(`award_kill(kit_name) → :level_up | nil`), stat readers
(`damage_for(kit, base)`, `max_hp_for(kit, base)`, spell-growth
reader), AND absorbs the existing persisted growth counters
(`boss_1_defeats`, `sessions` + their load/increment plumbing) — one
home for every persistent growth fact. World keeps ~6 lines of
wiring: construct, delegate readers, one award call in `actor_died`,
digest rows. Crossing's `defeats:` callable and save facts read
through it. Net world.rb line count must go DOWN in ticket 1.

## Non-goals (v19)

Skill-through-use (A1, parked) · XP loss on death (A3; future valve) ·
items/equipment/K-curve armor (parked era) · enemy level scaling (P7)
· damage variance (P6) · non-kill XP income (P2) · respec/attribute
allocation (no attributes exist) · per-body levels (A2) · stance verb
(C3, Lane 3's later rung) · zone gate AUTHORING beyond the test
fixture (WB lane).

## data/balance/progression.json (shape sketch, ticket-1 skeleton + ticket-2 numbers)

```json
{
  "curve": { "k": 40, "level_cap": 10 },
  "growth": { "dmg_growth_pct": 8, "hp_growth_pct": 6 },
  "kill_xp": { "husk": 8, "rusher": 15, "rusher_hater": 25, "challenger": 120 },
  "spell_growth": { "lobber": { "special_impact_distances": { "5": [2,3,4,5], "8": [2,3,4,5,6] } } }
}
```

All values above are STARTERS for the pacing script, not commitments;
they freeze only when the ritual stages (measurement hygiene).

## Verification strategy (per-ticket verify steps bind; this is the map)

- Suite via hooks every commit; `test/app/line_caps_test.rb` enforces
  P14's cap arithmetic mechanically.
- **Round-trip lane FIRST** (v17 digest-lane precedent): v1→v2 upgrade
  round trip (decode → apply → project → re-encode = byte-stable v2),
  v2→v2 identity, every new refusal direction exercised (bad
  progression type/keys, negative xp, level 0, level>cap clamp+warn,
  xp≥ΔE clamp+warn), backup-file creation proven.
- `rake gate` (full, critic included) for every visual surface: HUD
  (T3), level-up beat (T3), gate-refusal cue (T5) — each with its own
  wall script committed (wall debt paid in the same ticket).
- Netplay gates (`harness/net/*.json`) re-run in T2 (digest rows +
  DIGEST_VERSION moved) — refusal path must name the version field.
- `rake perf` in T2 (stat reads sit in the hot path; damage_for is
  per-hit, max_hp_for at spawn/level-up only).
- No-visual-change tickets (T1) prove byte-identical rendering:
  `rake capture` on `world_loop.json` twice + md5 compare (SKIP_CRITIC
  determinism only — lawful because no visual surface moves; any
  visual delta escalates to the full gate).

## Tickets (durable artifact; one ticket = one fresh session)

- **T1 — Progression extraction + save schema v2 + round-trip lane.**
  Files: `src/game/progression.rb` (new), `src/game/world.rb` (carve),
  `src/game/save_state.rb`, `src/game/crossing.rb` (callable rewire),
  `data/balance/progression.json` (skeleton), tests (round-trip lane,
  progression unit, line-caps green). NO XP awarded yet, NO stat
  growth applied (level fixed at 1 end-to-end this ticket), NO visual
  change. Verify: `rake` + double-capture md5 on world_loop + line
  count of world.rb strictly < 1800. Full brief:
  `drafts/_prog-t1-extraction-schema-v2.md`.
- **T2 — sim core:** XP-on-kill → level → stats live (P2/P4/P5),
  digest rows + DIGEST_VERSION 2 (P13), TELEMETRY line (P12), pacing
  script run + numbers landed (P11). Netplay gates + perf gate.
- **T3 — presentation:** level/XP HUD strip + level-up feel beat
  (banner + pop). New wall script + full Rule 2 gate; locale strings
  (en/es-CR/pt-br functional labels only).
- **T4 — lobber-E growth hook (P10):** spell-growth reader wired into
  volley config resolution; capture proving reach change at threshold.
- **T5 — `requires_level` machinery (P9):** tile_map validation +
  crossing gate + refusal cue + fixture zone; cue = visual surface →
  own script + gate.

T2–T5 briefs get cut one at a time as their sessions open (this spec
is the map; briefs carry file-line detail per the grill-and-ticket
law). Sequencing: T1 → T2 → T3 strictly; T4/T5 orderable after T2 by
session availability. Lane-2 stage 0 (R-A2) and B-knob re-sessions
interleave freely — different files, different knobs, one knob per
re-session.
