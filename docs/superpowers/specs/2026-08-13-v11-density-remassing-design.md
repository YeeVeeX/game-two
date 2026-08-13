# v11 — Density / re-massing (hunting-ground pressure) + Q6 drop-legibility rider

Status: forks CLOSED by the owner via AskUserQuestion on 2026-08-13, BEFORE
this spec, as the 2026-08-12 scope debate ordered. REVIEWED 2026-08-13:
3-lens adversarial workflow `wf_2e56306e-27f` (code-fit / design-fun /
harness-verifiability; 45 agents, 2.50M tokens; 14 findings, 9 CONFIRMED by
majority-refuter vote and folded in below, 5 refuted — ledger:
`drafts/_v11-spec-review.md`). Execution plan of record:
`C:\Users\gabri\.claude\plans\agile-greeting-bengio.md` (this spec supersedes
it as SSoT once committed). Promoted at the 2026-08-12 scope debate
(`drafts/_scope-debate-v11.md`) off the owner's own code-confirmed diagnosis.
Fun thesis under test, verbatim from the owner: a session must NOT get
**"boring and stale after a few rounds"** — the district must keep offering
GROUPED threat after the opening pull.

**The three closed forks (owner picks, verbatim):**
1. **Core shape = RE-MASS TOWARD CLUSTERS.** Respawn tile chosen at RELEASE
   time; the respawn joins the nearest surviving pocket below `pocket_cap`;
   all pockets capped / field empty → SEED a new pocket at the kit's spawn
   tile farthest from the pack; home fallback.
2. **Depth bias = NEUTRAL.** Anchor scoring by proximity/pocket size only.
   v11 tests ONE hypothesis: a dense field fixes stale. Depth bias stays
   available as a later data knob.
3. **Q6 legibility rider = band tint + size/glow by band, NO pickup
   fanfare.** Deep drops must READ as place.

Binding upstream: scope v11 (CLAUDE.md); `drafts/_q6-retune-fun-verify-20260812.md`
(eighth verdict + density diagnosis); `drafts/_scope-debate-v11.md` (debate
close + Challenger dossier). Touchstones: Tibia hunting grounds stay DENSE —
Gudii corpus f83 (laps/respawn: you lap the spawn and it is full again);
density-as-consequence (consequence synthesis); A2's own shape note
anticipated this ("respawns walk back toward the last fight"); the eighth
verify proved an unfelt premium degrades into inflation (the rider's
rationale). Anti-touchstone: wave spawners with on-screen pop-in — respawns
must never materialize where the player can watch them appear (the defer
rules are the fairness law).

## Why this is the increment (the density-decay diagnosis, code-confirmed)

Owner, post-eighth-verify, verbatim: "only on the first pull (when the game
starts) there are a good amount of enemies, but then the respawns are just a
smaller part of the enemies and too easy to clean up. game gets boring and
stale after a few rounds, but the core system and combat feels good for now."

Measured mechanism (world.rb:997-1004, 855-871; combat.json
`respawn_frames: 300`; threat.json `respawn_block_tiles: 12`): every kill
schedules a 1:1 respawn at +300 frames at the kit's nearest HOME spawn tile
(chosen at DEATH time), deferred while the pack is within 12 tiles. Net: the
opening walk-in masses all 15 district humans once (an unrepeatable peak);
steady state delivers scattered SINGLES walking back from home tiles. Count
is conserved; **clumping decays**. This is upstream of most of the eighth
verify: a thinning field ends hunts early (Q5), prevents sustained deep
pushes (Q6/depth "uniform"), makes cleanup income free (Q1), and never
re-masses a scary group (entrainment flat, third consecutive).

## Scope (one increment + one rider; riders never stand alone)

**IN:**
1. Release-time anchored respawns (re-mass toward clusters) — the increment.
2. Corpse-guard fairness rule (dev call, on record): re-massed pockets must
   not camp the D1 run-back.
3. `data/balance/threat.json` `density` block — all numbers in data.
4. New registered event `:human_respawned` + density telemetry oracle.
5. Q6 drop-legibility rider: band stamped on drop records, renderer keys
   tint/size/glow per band. NO pickup fanfare (fork 3).

**OUT — recorded (do not re-litigate):**
Depth-biased anchor scoring (fork 2: later data knob) · wave pulses /
density floors per region (rival shapes, declined at the fork) · the
Challenger (trigger triple-confirmed, declined twice — next debate's
standing candidate, fairness ladder mandatory) · arc/purpose layer (likely
v12 debate: A3 + bible; owner wishlist on record) · Q7 cue redesign (parked
presentation item) · pickup fanfare of any kind · new kits, zones, verbs,
bindings · pack-side respawn changes (`respawn_pack` untouched) ·
term/grace retune · anything already in PARKING_LOT.

## Sim spec (all numbers in data/, zero balance constants in Ruby)

### 1. Release-time anchored respawns (world.rb)

`schedule_human_respawn` records `{kit_name, at_frame}` ONLY — no tile. The
tile is chosen at RELEASE time in `respawn_due_humans`, so the respawn
re-masses toward the field as it IS when due, not as it was at death. The
roster-delete-first law (M2 review finding 2) is untouched.

Anchor selection per due record (deterministic, order-stable):
1. **Pockets** = connected groups of living humans in the current zone
   within `join_radius_tiles` of each other (chain/transitive distance,
   Chebyshev — the `tile_distance` law). Exposed as a public reader
   (`World#density_pockets`) — the respawn path, telemetry, and tests all
   read the same computation.
2. **Join**: eligible pocket = size < `pocket_cap`. Pick the eligible
   pocket whose nearest member has the smallest Chebyshev distance to ANY
   of the kit's `enemy_spawns` tiles (double-minimum over pocket-members ×
   spawn-tiles — the record carries no death tile, so the kit's FULL spawn
   list is the reference; neutral depth, fork 2); tie-break lowest roster
   index (stable). Anchor tile = that nearest member's tile. → anchor
   kind `:pocket`.
3. **Seed**: no eligible pocket (all capped, or field empty) → anchor at
   the `enemy_spawns[kit]` tile farthest (Chebyshev) from the nearest
   living pack member; tie-break lowest index in the zone-data spawn list.
   Crowds re-form where you aren't. → anchor kind `:seed`. Edge guard: if
   `pack.living` is EMPTY at evaluation time (achievable — the last pack
   body can die in `resolve_attacks` earlier in the same `tick_world`,
   before the wipe transition lands at bus-process), fall through directly
   to the home fallback (step 5); "where you aren't" has no referent.
4. **Spawn tile** = seeded-RNG pick among walkable, unoccupied tiles within
   `scatter_radius_tiles` of the anchor (candidate list built in sorted
   tile order — RNG consumption stays replay-deterministic; the pick fires
   in `tick_world` BEFORE drop rolls, which fire later during bus-process
   via `spawn_drop`. Moving the scatter pick after bus-process would shift
   the drop-roll stream and break every seeded replay containing a kill —
   the ordering is load-bearing, pinned here).
5. **Home fallback**: kit has no `enemy_spawns` entry in the zone, or the
   scatter neighborhood has zero passable unoccupied tiles → the kit's
   nearest home spawn tile, exactly today's behavior. → anchor kind `:home`.

### 2. Defer rules (all retry next tick; deferral recomputes the anchor,
### which re-masses better, not worse)

A due respawn DEFERS while ANY of:
- chosen tile occupied (today's rule);
- any living pack body within `respawn_block_tiles` of the chosen tile
  (today's A2 suppression — spawns freeze near the hunting pack);
- **corpse guard (NEW fairness rule, dev call):** chosen tile within
  `corpse_guard_tiles` of any live corpse load in the zone. Spec
  refinement over the plan's "while wipe grace is active" wording: the
  guard binds whenever a live corpse load exists — simpler (no wipe-state
  flag), strictly fairer (covers a far-away solo body death too), and
  term-bounded so it can never starve respawns (the load expires, the
  guard lifts). The D1 run-back must never arrive at a re-massed pocket
  camping the pile.

### 3. Data schema (starting values — hypotheses, tunable, never sacred)

`data/balance/threat.json` gains:
```json
"density": {
  "join_radius_tiles": 3,
  "pocket_cap": 5,
  "scatter_radius_tiles": 2,
  "corpse_guard_tiles": 6
}
```
Anchors for the values: `join_radius_tiles 3` — one screen-quarter apart
still reads as one group; `pocket_cap 5` = `engaged_cap_per_target` (a
full engagement ring) so a pocket saturates the cap exactly; overflow
seeds a SECOND pocket instead of a 15-blob (the degenerate end-state the
cap exists to prevent); `scatter_radius_tiles 2` — arrivals read as
joining, not stacking; `corpse_guard_tiles 6` — half the block radius:
the pile stays reachable without suppressing the whole field.

### 4. Events

`:human_respawned` `{actor, tile, anchor}` (anchor ∈ :pocket|:seed|:home)
joins `World::EVENTS` (world.rb:20 whitelist — defined on first use, unknown
symbols still raise). Emitted from `respawn_due_humans` on successful add.
⚠ `add_human` must be CHANGED to return the creature it builds — today its
last expression is `@humans[zone] << Creature.new(...)` and `Array#<<`
returns the ARRAY, not the appended element (spec-review finding, both
existing callers discard the return): assign the Creature to a local,
append, return it explicitly. Emitting `actor:` from the unchanged return
value would silently put the whole roster array in the event payload.

### 5. Density telemetry oracle (subscriber-side, the q6_cadence pattern)

Telemetry subscribes to `:human_respawned`: counts arrivals by anchor kind,
and at each arrival samples `world.density_pockets` — accumulating pocket
count per sample, max pocket size ever seen, and singleton share. One
summary line (format pinned here; the ninth verify harvests it BEFORE
questions):

```
TELEMETRY density pockets{mean=M.M max=N} arrivals{pocket=A seed=B home=C} singles_pct=P
```

`mean` = mean pocket COUNT per sample, one decimal; `max` = largest pocket
size seen; `singles_pct` = 100 × (size-1 pockets across samples / all
pockets across samples), integer. **Zero-arrivals case pinned** (session too
short for any respawn to release): the line still prints, with `mean=0.0
max=0`, all arrival counts 0, `singles_pct=0` (the `|| 0` q6 precedent) —
the line's PRESENCE with all-zero counts is the subscriber-alive proof;
absence means the subscriber is broken. A zero-arrival session routes as
"unexercised" (too short), never as a mechanism defect. A session with
`home` dominating arrivals or `singles_pct` near 100 is
machine-distinguishable from one where re-massing fired — the collapsed-Q6
lesson (an unresolvable fork when telemetry dies) never repeats.

### Rider: drop legibility (band tint + size/glow — fork 3)

- `spawn_drop` stamps `band:` (gradient band index of the victim's tile;
  a `gradient_band(tile)` helper alongside `gradient_multiplier`) on the
  drop record — the renderer-reads-the-record pattern (`decay_frames`
  precedent). Band is a function of tile, so the same-tile merge (which
  keeps the first kill's clock) can never conflict on band. Zones without
  a gradient stamp band 0 — the nest is pixel-unchanged.
- `Renderer#draw_drops` keys size + palette by band (presentational
  constants stay in the renderer, per the existing 10/14px precedent).
  SIZE is the primary channel, color the reinforcement (spec-review
  finding: a 14px band 1 would be size-identical to a stacked band-0
  drop, leaving hue alone to carry 40% of the map's kills):
  - band 0: today's magenta, 10/14px by amount — byte-identical to now;
  - band 1: warm rose, 16px (above every band-0 size);
  - band 2: ember/gold, 18px + glow ring + brighter core.
  The ladder reads 10 < 14 < 16 < 18 with band boundaries at 14→16→18.
- Decay-fade behavior (alpha over the final third) is band-independent and
  unchanged. NO pickup fanfare — the drop reads as place while it lies
  there; picking it up stays quiet (fork 3, verbatim).

### Perf

Pocket computation is O(n²) Chebyshev over ≤15 humans, only on release
ticks and telemetry samples — noise against the 16.6 ms budget (current
p95 0.224 ms). `rake perf` re-proves it ALONE before the full suite.

## Presentation spec (Rule 2 surface)

1. **Deep drops read as place** — a band-2 drop (ember/gold, larger, glow)
   is instantly distinguishable from a band-0 drop (small magenta) in one
   frame; band 1 sits legibly between. The nest and near-gate district are
   pixel-unchanged.
2. **Re-massing is felt, never watched** — no spawn pop-in on screen. The
   defer rules (block radius) are the existing guarantee; the corpse guard
   extends it to the run-back. There is deliberately NO new spawn VFX: the
   field being dense again when you lap back IS the presentation
   (Tibia touchstone).
3. Fiction order form: nothing new. Pockets/re-massing are systemic (no
   player-visible handle); band tints are presentation, not names. The
   bible owes this increment nothing.

## Harness + gates

- **Replays WILL desync — expected** (respawn tiles change for every stream
  with a kill). Re-pilot affected scripts via `rake pilot`, re-staging ALL
  mandatory beats (memory: gate-critic-mandatory-beat-checks; "passed
  earlier" claims are refuted from artifacts, not trusted), export, then
  the full official 9-gate wall: double replay + md5 + critic, ALL
  blocking (Rule 2). Provenance map → `drafts/_v11-wall-log.md`.
- **Vision checks ADD-ONLY 39 → 40.** New check `deep_drop_band_reads`:
  when a deep-district drop is on camera, it reads visibly RICHER than a
  near-gate drop — larger, ember/gold, glowing vs small magenta; a
  stranger could point at which is worth more. Secondary clause folded
  into the SAME check (goal pins one new check): when a band-1 drop
  (warm rose, 16px) is also present, it reads BETWEEN the two — visibly
  bigger/warmer than band-0 magenta, visibly smaller/quieter than band-2
  gold. If no band-2 drop frame, pass with why='not exercised by this
  script'. Staged on whichever script pilots a deep kill (loot_loop or
  district_hunt).
- **Check #20 recognition-template amendment, prescribed here**
  (spec-review finding: `drops_read_as_pickups` describes drops as "small
  magenta/violet squares" — band-tinted drops would make the template
  false and the verdicts unreliable). The requirement clauses do NOT
  weaken (ADD-ONLY law binds requirements); only the recognition
  parenthetical broadens to track the render truthfully: "(small
  magenta/violet squares near the gate; larger warm-rose or ember-gold
  glowing squares deeper in the district)". Distinction-from-gate clause
  unchanged — a band-2 drop and the gate cannot share a frame at
  gameplay zoom (28+ tiles apart), and size/glow distinguish them anyway.
- Tests (minitest, real World, no mocks):
  - `density_pockets`: chain grouping at exactly join radius, radius+1
    splits, empty field, dead humans excluded.
  - Release-time anchoring: join picks nearest-to-home eligible pocket;
    cap overflow → seed; seed picks farthest-from-pack spawn tile; empty
    field seeds; home fallback (no spawns entry / no free scatter tile);
    scatter tile within radius, walkable, unoccupied.
  - Defer rules: occupied tile; block radius (existing law re-pinned on
    the CHOSEN tile — isolation technique: constrain world state to a
    single possible anchor outcome, e.g. one living human = one pocket
    with a known anchor, and park the pack within
    `block_radius − scatter_radius` of it so EVERY possible scatter tile
    is suppressed regardless of RNG); corpse guard with a live load,
    lifting on loot/expiry; deferral retries and recomputes next tick.
  - Determinism: same seed → same respawn tiles; double-run equality.
  - `:human_respawned` payloads carry the right anchor kind.
  - Band stamping: band by tile per gradient; nest stamps 0; merge keeps
    band + first clock (existing law re-pinned).
  - Telemetry: arrivals by kind, pocket sampling, exact line format,
    zero-arrivals format (all-zero line still prints — subscriber-alive
    proof).
  - **Existing home-tile respawn pins UPDATE — the meaning change IS the
    increment, not collateral** (schedule records no tile; release
    chooses).
- `rake perf` ALONE (p95 < 16.6 ms), then full `rake`. Merge `--no-ff`;
  **NO push — ever** (owner's action, never the dev's). CHECKPOINT with
  measured numbers.

## Fun-verify (NINTH — BLIND; owner plays first, NO changelog in the handoff)

Session protocol (the eighth's telemetry died to a log clobber — law now):
**unique log per launch** (`/tmp/game_two_session_$$.log`), never relaunch
while a session window is open, harvest ALL telemetry (density + q6_cadence)
BEFORE any question is asked.

**Preamble:** if you never pushed past the first pull or never wiped, say
so — those questions read as unexercised, not negative.

1. **The stale oracle (HEADLINE — the owner's own words, eighth verify):**
   did the session stay alive past "a few rounds" this time? Was the field
   still worth fighting after the opening pull, or did it thin into
   cleanup again?
2. **Grouped threat:** after the opening pull, did you keep running into
   GROUPS — fights that needed positioning — or only scattered singles?
3. **Depth pull (Q6 re-read):** did any part of the district feel worth
   pushing INTO? Did "bank now or push deeper" bite at any point?
4. **Deep loot as place (rider):** did the richer drops deeper in visibly
   READ as richer — did you ever notice a drop and think "that's a deep
   one"?
5. **Q1 GUARD (regressed at eighth; the revert should restore it):** did
   money feel easy again, or did income feel earned?
6. **Q5 GUARD (regressed at eighth):** were you back at the nest too
   often, or did hunts run long enough?
7. **Fairness probe:** did any respawn ever feel unfair — a group camping
   your corpse run, enemies appearing where you were looking, a spawn
   materializing on screen?
8. **Entrainment probe (FOURTH consecutive read):** on the scariest
   stretch — a re-massed group, a thin-HP escape — did your body react?

**Pre-registered routing (locked here — do not re-derive at the verify):**
- **Stale oracle MOVED** (session stayed alive) → v11 wins; next increment
  = scope debate (Challenger, its trigger by then 3-4× confirmed, vs
  arc/purpose v12 — A3 + bible — vs whatever else this verify routes).
- **Stale UNMOVED + telemetry shows re-massing FIRED** (pocket ≫ home
  arrivals, singles_pct well below 100, pockets.max ≥ 3) → density VALUES
  iteration (data only: pocket_cap / join_radius / respawn cadence), NOT
  new scope — the mechanism works, the dose is wrong.
- **Stale UNMOVED + telemetry shows re-massing NEVER fired** (home/seed
  dominate, singles_pct ≈ 100) → mechanism defect; fix as a BUG on this
  increment, not a new debate.
- **Q3 unmoved with a dense field confirmed** → the structural economy
  branch (banking rides heal trips free — carried from the eighth,
  unfalsified) goes to the debate as a candidate; never unilaterally to
  code.
- **Q4 "still uniform"** → band tint judged exhausted (two lanes tried:
  numbers at v10.1, presentation here); drop legibility escalates to its
  own parked presentation item alongside Q7's cue.
- **Q5/Q6 guards still regressed with a dense field** → economy iteration
  candidate at the debate (the gradient revert plus density was the
  hypothesis; a third guard regression means the lever is elsewhere).
- **Fairness complaint (Q7 here)** → corpse_guard / scatter / block values
  iteration (data); if a spawn was WATCHED appearing, that is a defer-rule
  bug — fix forward.
- **Entrainment flat FOURTH time** → the Challenger's trigger,
  fourth confirmation — strengthens its dossier at the debate (promotion
  stays the owner's explicit call, fairness ladder mandatory).

Verdict → `drafts/_v11-fun-verify-<date>.md` + CHECKPOINT + commit, routing
applied verbatim.

## Deliberately absent (recorded so review doesn't re-litigate)

Depth-biased anchors (fork 2 keeps it a knob) · wave pulses / density
floors (declined shapes) · spawn VFX / pop-in of any kind · pickup fanfare
(fork 3) · respawn-count changes (1:1 conservation stands; density is
about WHERE, not HOW MANY) · respawn-delay retune (300f stands this
increment; cadence is a later data knob) · pack respawn changes · the
Challenger · arc/purpose (v12 debate) · Q7 cue redesign (parked) · Nest
rename (post-bible) · everything already in PARKING_LOT.
