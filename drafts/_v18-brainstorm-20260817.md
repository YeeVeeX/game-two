# v18 brainstorm — persistence v1 + coop feel + god-view v0 (2026-08-17)

Session: v18 execution opener (spark `drafts/_v18-spark-20260817.md`).
Consumes `drafts/_v18-foundation-20260817.md` (ratified positions),
the SIXTEENTH verdict (`drafts/_v17-fun-verify-skeleton-20260816.md`),
PARKING_LOT (D0 history, 2026-08-11 sustain law, owner vision routing),
and the research shelf. Closes forks F1–F7. The spec is the product;
this file is the reasoning record.

## Evidence recap (banked, not re-derived)

- **Substrate:** sim deterministic + tick-locked; handshake pins
  version/ruby/platform/fingerprint/digest_version at HELLO and
  session_id/seed/d/digest_every at SESSION (`src/net/session.rb`);
  `StateDigest` folds events+inputs+snapshot per 60-tick window;
  `World#digest_snapshot` already enumerates every gameplay-affecting
  scalar — **the digest lane pre-built the persistence schema**.
- **Seed is per-session already** (`Random.new_seed & 0xffff_ffff`,
  src/main.rb) — "field re-seeds, facts persist" is the natural grain.
- **Wire cap:** `Protocol::MAX_LINE_BYTES = 4096` — a save payload must
  fit ONE line or refuse loudly. F1's arc-facts-only shape keeps the
  save under ~1KB *by design*; the cap is why full-world snapshots were
  never on the table for the wire path.
- **Shelf verdicts (VERIFIED tier):** Tibia model = world resets /
  character persists; **player presence at the spawn point blocks
  respawning** (TibiaWiki Respawn — we already carry
  `respawn_block_tiles: 12`); consumables ≈30% of daily currency
  removal, elastic/self-scaling (mmo-economy-design-sinks-and-faucets)
  — the posture for pricing sustain under persistent banked.
- **SIXTEENTH telemetry (owner seat, 25 sim-min, two-seat):**
  `banked_spent{inscribe=80 tribute=238}` — maintenance spend dominates
  3:1, the bank-run friction is MEASURED; `banks{n=15 mean=34 max=133}`,
  bank gap `mean_s=57`; `wipes=3` in 25 min two-seat vs the fifteenth's
  2 in 9 min solo (per-minute wipe rate roughly HALVED in coop —
  Junior's "não parece tão dificil" corroborated numerically);
  `deaths_while_seized=2, swap_escapes=0` (BOSS 1 still kills bodies);
  owner Q3a verbatim: respawn too fast to walk back after clearing a
  side; Q3b: no mid-hunt sustain, always back to the bank.

## Fork closures

### F1 — What persists (OWNER-LEVEL; recommendation recorded, veto open)

**RECOMMEND: character + economy + world ARC. Field re-seeds.**

Persists (the save's entire vocabulary — small by design):
- **Pack economy:** `banked`, `provisions` (new, F6).
- **Per-member character:** kit (roster identity), `hp` exact,
  alive/dead, `inscribed` flag, `carried` (unbanked value on the body).
- **World arc:** `breached` seals, `home_zone` (camp re-homes are FELT
  at next session start — the pack wakes where the arc moved it),
  cumulative fact counters (`boss_1_defeats`, `sessions`) for the
  oracle's carried-fact proof + the god-view header.

Does NOT persist (per-session, re-seeded): live humans/positions/HP,
drops, corpse loads, respawn queues, projectiles/impacts, possession
pointers, mark, all presentation state (already digest-excluded), the
session seed. BOSS 1 **respawns every session** (Tibia raid-boss
grain: the FIGHT is repeatable content; the DEFEAT persists as a
counter, not as an absence).

Defense: Tibia's shape verbatim — the world resets, the character
persists. A full-world snapshot is heavier (wire cap), brittle across
dev churn (every sim field rename = schema break), and worse for the
felt thesis (a frozen field is a museum, not a world). Arc-only is
thinner than the owner's ask (characters were named explicitly).

Two deliberate edges (recorded for Half B watching, not silently):
- **Dead stays dead across sessions.** Session 2 opens with the vat
  fee owed — the death economy continues, it doesn't reset. The
  one-vessel floor law guarantees ≥1 living at any quit boundary.
- **Field value does not survive the quit.** Drops + corpse loads are
  field state; quitting with value un-banked and un-carried destroys
  it. Consequence: **banking before quitting IS the save ritual** —
  the bank becomes the session's closing beat (deepens D1b instead of
  bypassing it). Tibia-honest: loot on the ground rots.

### F2 — Save custody + sync (DEV CALL)

**ONE host-authoritative save file, machine-local, gitignored;
transferred inside the handshake; the joiner never persists it.**

- Location `saves/world.json` (path in `data/persistence.json`;
  `saves/` gitignored — F-rejected: git-tracked saves = merge
  conflicts + save-scumming + pull friction; per-seat saves = drift).
- **Wire:** SESSION message gains `save_schema` + `save_digest` +
  `save` (the facts block, JSON-inline — fits the 4096 cap with ~3x
  headroom; an oversized save is a NAMED refusal at host start, never
  a mid-handshake wire fault).
- **Digest chain (the oracle's Half A arbiter):** at every save-write
  the writer prints `TELEMETRY persist saved digest=<md5> schema=N
  banked=B ...`; at every load `TELEMETRY persist loaded digest=<md5>
  ...`; the joiner prints the digest it received. Session 2's `loaded`
  line == session 1's `saved` line = the chain link, verbatim-
  comparable across both seats' logs.
- **Refusals (fingerprint-law grammar, name the field + the fix):**
  save schema ≠ build schema at load → refuse with `--fresh` hint +
  matching-build hint; handshake `save_schema` mismatch → refuse
  naming the field (belt-and-braces — the fingerprint already pins
  the code, and code pins the schema).
- Joiner applies the transferred facts to its World construction and
  **never writes the shared save** (custody never forks mid-coop).

### F3 — Banked persists (OWNER-LEVEL; recommendation recorded, veto open)

**RECOMMEND: YES.** D0's "session-only" clause was explicit: "a save
system with no fun-thesis need." The owner ask IS the fun-thesis
arriving. Inscription semantics shift with it: judgment now crosses
sessions (a mark bought today armors tomorrow's wipe).

Inflation risk, named and valved: banked accreting across sessions
with fixed-price sinks trends toward "money got easy" (the v10.1
recorded negative). The valve is F6 itself — provisions are the
elastic, self-scaling sink the shelf's economy note prescribes
(consumables ≈30% of removal in mature economies). Watch metric
pre-registered: `banked_end` across consecutive sessions in telemetry;
if it grows monotonically for 3+ sessions while tribute+provision
spend stays flat, the pricing debate re-opens (recorded, not auto).

### F4 — Solo advances the shared world (OWNER-LEVEL; nuance NAMED)

**RECOMMEND: YES, with custody honesty.** One canonical save, on the
host machine (the owner's). Owner solo play advances the world Junior
will join next — outpacing at 2-friend scale is the feature
("trabajar sobre el mismo mundo"), not a bug.

**The nuance the owner must see:** Junior playing SOLO on his machine
advances his OWN local world (his machine's save lineage), NOT the
shared one — merging two divergent world lines is a distributed-
systems fork (custody handoff / merge rules), which is exactly the
always-online architecture's domain, PARKED with its named trigger.
v1 semantics, stated flat: **the shared world lives on the owner's
machine; it advances when the owner plays (solo or hosting) or when
Junior joins him. Junior's solo = his own sandbox world.** If this
reads wrong to the owner, the alternative inside v18 scope is
coop-only persistence (thinner); custody handoff stays parked either way.

### F5 — Coop pacing shape (DEV CALL)

**Seat-count scalar block in `data/balance/coop.json`; seats=1 =
scalar 1.0 BY CONSTRUCTION (single-player wall untouched).**

Three knobs, all data, numbers finalized at spec from SIXTEENTH
telemetry:
- `respawn_delay_scale` (>1 at 2 seats): scales human
  `respawn_frames` at schedule time — buys the owner's walk-back time
  (Q3a verbatim). The existing presence-block (`respawn_block_tiles`)
  stays; delay is the knob that respects it.
- `human_hp_scale` (>1 at 2 seats): the difficulty knob for Junior's
  "não parece tão dificil" — same fights, longer; no AI change, no
  density change, no perf surprise. (Density scaling rejected for v1:
  more bodies = perf + chaos + respawn interactions; hp is the
  smallest honest knob.)
- **Third-body AI caution, seat-gated (seats ≥ 2):** uncontrolled
  pack body at hp < `ai_flee_hp_pct` disengages (no attack actions,
  moves toward its follow anchor) — Junior's "se matando por nada".
  Seat-gated so the single-player wall is untouched by construction;
  promoting it to single-player is a future comparability-reset
  decision (the quay-swarm attrition doctrine says solo wants it too
  — recorded, not smuggled).

### F6 — Sustain verb (DEV CALL; owner law 2026-08-11 binding)

**PROVISIONS: priced field charges bought at the bank, consumed
anywhere, pack-wide heal pulse. Never free, never regenerating.**

- **Buy:** new verb pressed ON the bank station = buy 1 charge for
  `provision_cost` banked (strawman 6 = 3 station-heals' worth;
  final at spec). Stock cap `provision_cap` (strawman 3) — a planning
  decision, not a tank.
- **Use:** same verb pressed anywhere else = consume 1 charge → heal
  pulse of `provision_heal` hp (strawman 30 — ~38% of the striker,
  ~19% of the blocker) to every LIVING member. The healer-fairy/Navi
  kernel folded exactly as the 2026-08-11 entry prescribes: a priced
  invocation, a portable bank-sink. Dead bodies untouched — the vat
  keeps its monopoly on regrowth (no battle-rez, law).
- **Price defense:** station heal is 2/body to FULL; a provision heals
  a fixed chunk at 3x the banked rate — the premium buys PORTABILITY,
  so the bank trip stays the efficient move and the provision buys
  hunt LENGTH (Tibia supply-burn touchstone, Gudii f38: sustain and
  cost are the same mechanic). Elastic sink for F3's inflation valve.
- **Input:** 11th action bit `sustain`, keys **U / R** (pair grammar:
  right-hand near JKL / left-hand near WASD, matching every existing
  pair). `Protocol::ACTIONS` grows → **protocol version 2** (the
  pinned law honored: mask change = version bump; skew = the existing
  named refusal + git pull hint). Existing replay scripts never press
  the bit → single-player wall byte-identical by construction.
- **Presentation (Rule 2 surfaces, all conditional):** provisions
  counter + strip row render ONLY when provisions > 0 (the
  waiting-seat-hides precedent) → every existing wall capture is
  byte-identical; a NEW exerciser script `sustain_run.json` + ADD-ONLY
  checks carries the gate. Strings en/es/pt-br are functional
  dictionary words (PROVISION / PROVISIÓN / PROVISÃO — Junior
  ratifies pt-br per his active-seat lane).
- **Netplay:** provisions are pack state; any seat's press consumes
  (seat-order law resolves same-tick races deterministically); new
  digest fields cover it.
- **Persists** (F1 character block) — banked value in portable form.

### F7 — God-view v0 scope (DEV CALL)

**Strictly offline: `rake map` → one PNG. Zero sim/netplay surface.**

- `rake map [SAVE=saves/world.json] [OUT=captures/map/world_<ts>.png]`
  — opens the capture window (Gosu.render needs a live GL context,
  AGENTS law), renders EVERY zone's full tile grid through the real
  renderer tile path (no second renderer to drift), composites a
  labeled grid: **ZONE 1..5, HUB 1** (placeholder law), seal stations
  stamped SEALED/OPEN from the save, home marker at `home_zone`,
  header strip `BANKED N · MARKS K · PROVISIONS P · BOSS 1 DEFEATS D`.
- **Rule 2 applies to the artifact:** own checks file
  (`harness/map_checks.json`), capture + vision critique BEFORE ship;
  lives OUTSIDE `harness/scripts/` (the wall stays single-player
  replay scripts — the harness/net isolation precedent).
- In-game map/teleport/editing: parked, staged (owner vision routing
  stands). This PNG is the honest seed of the editor era: the same
  facts block the editor will one day mutate, rendered read-only.

## Cross-fork laws (the spec pins these as tests)

1. **Wall byte-identity by construction, three ways:** replays/wall
   construct with `save: nil` ALWAYS (structural pin — the wall can
   never see a save); seats=1 scalars absent = 1.0; provisions=0
   renders nothing. Any slip = full comparability reset (expensive,
   known law) — so all three are TESTED constructions, not intentions.
2. **Session-boundary-only IO:** load at World construction, save at
   clean quit (Esc→drain), + solo quit. No mid-tick IO anywhere; the
   16.6ms p95 budget untouched. Crash = session progress lost
   (honest v1; autosave cadence is a parked knob).
3. **Save normalization law:** the save captures the pack AFTER the
   same normalization `enter_zone` already performs (transient combat
   state zeroed: stagger/iframes/chants/seizures/projectiles; wipe
   judgment resolved before capture). Loaded worlds start at the
   home-zone spawn — mid-field quit does not save mid-field.
4. **Load divergence IS a desync:** the loaded world feeds the same
   digest machinery; construction bugs fail at the first 60-tick
   boundary, LOUDLY, with the existing artifact machinery. Schema
   bugs refuse BEFORE the window opens, naming the field.
5. **No mocks:** persistence tests use real files (tmpdir), real
   save/load, real two-session loopback netplay sequences.

## Increment order (TDD next session — round-trip lane FIRST)

1. **`Game::SaveState` + the round-trip lane** (the safety net):
   serialize(world) → versioned facts; `World.new(..., save:)`
   applies at construction. Tests: canonical-bytes stability;
   save(apply(save)) == save idempotence; **THE LANE** — world A runs
   T scripted ticks (banks, deaths, seals) → save → two fresh worlds
   B1/B2 (same new seed, save applied) run K scripted ticks →
   digest_snapshot equal at construction AND boundary digests
   identical at every window; schema-mismatch refusal class;
   normalization law.
2. **Solo wiring:** load at launch, save at clean quit, `--fresh`,
   `TELEMETRY persist` lines, structural wall pin (save: nil).
3. **Handshake extension:** SESSION carries save_schema/digest/facts;
   joiner applies, never persists; refusal lanes; **two-session
   netplay integration test** (real files: pair runs + host saves →
   second pair loads + resumes; digest chain + carried fact asserted).
   Protocol v2 lands here (final vocabulary incl. the sustain bit —
   one bump for the whole cycle, suite pins the final shape).
4. **Coop feel:** `data/balance/coop.json` + seat-gated third-body
   caution; netplay-lane assertions; numbers from telemetry.
5. **Sustain:** verb + economy + conditional HUD + strings +
   `sustain_run.json` exerciser + ADD-ONLY checks + full Rule-2 gate.
6. **God-view v0:** rake map + map checks + critique artifact.
7. **Docs + close:** JUNIOR.md persistence section (PT-BR-first —
   pull-before-play is now schema-critical), AGENTS Commands,
   PARKING_LOT (custody-handoff entry), SEVENTEENTH pre-registration.

## Risks named (top 3)

1. **F4 custody semantics** — if the owner expected Junior's SOLO
   play to advance the shared world, v1 disappoints; named in the
   owner ask with the coop-only alternative + the parked trigger.
2. **Save normalization edges** (quit mid-veil / mid-seizure / value
   in the field) manufacturing session-2 first-boundary desyncs —
   mitigated by lane-first ordering + reusing enter_zone's exact
   normalization + the named field-value edge.
3. **Wall contamination** — three no-touch constructions must hold or
   a full comparability reset lands; all three are structural TESTS
   in increment 1/2/5, not review items.

## Post-review addendum (2026-08-17, same session — the SPEC supersedes
## this file where they differ)

Dual review landed: Codex REJECT (21 findings, 20 confirmed, 1 partial)
+ panel (9 folds, 2 refutations with source evidence). Fork-level
changes against the text above:
- **F1 amended — carried does NOT persist** (Codex #1: persist-carried
  + load-at-home = a risk-free loot teleport past the corpse-run).
  Value survives ONLY as banked; the defense: corpses already expire in
  ~90s in-session, so the quit boundary destroys nothing that would
  have survived anyway.
- **F6 cost strawman 6→5** (panel: steep premiums kill
  experimentation); tuning lever order pre-registered
  (discoverability → cost → heal).
- **Solo seed was FIXED at 0** (Codex #10 against window.rb:58) — the
  "seed is per-session already" claim above held only for netplay; the
  spec's decision 16 fixes solo.
- **Cross-fork law 3 above was WRONG** (enter_zone does NOT clear
  stagger/iframes/exhaust, and a mid-veil quit has zero living
  members): replaced by the spec's decision 3 — an explicit PURE
  projector that resolves judgment through the live rules and zeroes an
  enumerated transient list.
- Full adjudication + every folded law: `drafts/_v18-spec-review.md`
  and the spec's inline fold marks.
