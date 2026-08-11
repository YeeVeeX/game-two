# A2 — Threat/pull economy (priority targeting + position pressure + leash + gradient)

Status: REVISED (2026-08-11, post 3-lens adversarial review — code-fit /
design / fun workflow, 12 findings each adversarially verified: 11 REFUTED,
1 confirmed-low folded [the touchstone-coverage qualification below]; ledger:
`drafts/_a2-spec-review.md`). All nine design
forks closed by the owner via three AskUserQuestion rounds + one council debate
(kimi/glm, 2 rounds — `drafts/_council-economy-verdict.md`); fork ledger in
PARKING_LOT §"A2 brainstorm OUTCOMES". Promoted by the FIFTH fun-verify (Q3
"still a chore" on a VISIBLE ledger → the v8 pre-queue fired; scope contract
v9, commit `85de477`). Fun thesis under test, verbatim: **"threat must contest
what the player does — the position they hold, the corpse they run back to,
the walk they bank through."**

Binding upstream: scope v9 (CLAUDE.md); `drafts/_ledger-fun-verify2-20260811.md`
(routing); `drafts/_a2-design-summary.md` (consolidated brainstorm design);
evidence index in PARKING_LOT §"A2 brainstorm evidence inputs". Touchstone
grounding: the 98-transcript Gudii corpus documents Tibia's full aggro layer
(f21 + NotebookLM harvest Q1: first-seen, proximity resets, lowest-HP priority,
vocation-hate, challenge, 8-box, poof-leash, screen-block respawn) — grounding
that covers the targeting chain (§1), the leash (§3), the respawn discipline
(§4), and the engaged-cap DERIVATION of §2 (the 8-box), superseding the
12-agent synthesis's "zero aggro evidence" caveat (true only of its 8-video
base). **The pressuring ring's non-attacking spatial containment (§2) is NOVEL
design with no corpus precedent** (the synthesis's own critic flagged this) —
it is defended from game-two's measured problems (2/2 uncontested recoveries,
the gate-camp corridor, Q1 "standing in line"), not citations. Learnability law
(Darklight Core finding, `drafts/_gudii-studio-digest.md`): predictable threat
invites denser play; chaos caps it — every behavior below is rule-driven and
tell-visible, no randomness.

## Why this is the increment (the chore diagnosis, five verifies deep)

Drama (D1) did not move the chore. Legibility (ledger) did not. The remaining
lever is consequence: nothing contests anything — 2/2 + 2/2 uncontested corpse
recoveries, an undesigned gate meat-grinder, 6-8 free-respawn wipes/session
(arcade lives), a dead walk to the bank. Measured root cause of the grinder
(code brief): rusher spawn `[10,12]` sits 9 tiles from the district arrival
`[1,13]`/`[2,13]` — inside the 10-tile aggro gate — on a 300f respawn timer
(`data/zones/district.json:41`, `data/balance/combat.json:129`), and humans
have no home, no leash, and nothing to do without a target (they stand still:
`src/game/controllers.rb:77-91`).

## Scope (one variable: threat; economy ships NOTHING here)

**IN — six mechanisms + one bundled data change:**
1. Priority targeting for humans (first-seen stickiness + three overrides).
2. Position pressure: engaged cap per target + uncapped PRESSURING followers.
3. Leash-with-no-heal: humans with nothing in range walk home, keeping HP.
4. Respawn discipline: screen-block suppression + gate beachhead.
5. Depth gradient: denser spawns + richer takes farther from the gate (data).
6. Live-corridor corpse contest: NO corpse-specific code — the run-back gets
   dangerous because 3+4 re-populate the path (zero changes to corpse paths;
   verified orthogonal, world.rb:436-451, 684-692).
7. BUNDLED: tank-first initial possession (owner feedback 2026-08-10).

**OUT — recorded (do not re-litigate):**
- Economy/D1b: ZERO spend code. The pile's meaning is now LOCKED (inscription
  within ritual — persistence through judgment; PARKING_LOT outcomes) but it
  ships as D1b behind this increment's verify. The vision doc exists so the
  pile is no longer unexplained; that was the owner's actual complaint.
- Human counterplay tools (owner + unanimous council): no Challenger, no
  fear-scatter. Pre-registered future beat: a NAMED Challenger human who
  taunts back — "humans never fought back, until one did" — its own
  increment, fairness ladder mandatory (visible tell + counters). Trigger:
  sixth verify says threat is FELT but fights lack scary peaks.
- No new enemy kits (the hate-tagged rusher is a data variant of the same
  kit: same body, same stats, one new field). No Shooters (A1+). No new
  bindings (scope law). No LOS/vision system (distance rules only). No
  walk-in respawn animation (materialize-at-point stays — Tibia-faithful).
- No scavengers (D3), no term/grace retune (parked until measured margins),
  no D1 corpse changes of any kind.

## Sim spec (all numbers in data/, zero constants in Ruby — values below are
## HYPOTHESES, reset by pilot + telemetry, never by feel)

### 1. Priority targeting (humans only; allies unchanged)

Today (controllers.rb:74-91) every creature runs: taunt → anchor → mark →
nearest-Chebyshev, re-evaluated every tick — targets flap by distance. New
HUMAN selection chain, in order (allies keep their current chain; mark is
ally-only already):

1. **Taunt hard lock** — unchanged, absolute for its 300f fuse (fun-verified;
   the taunted_target purity law stands).
2. **Anchor rule** — unchanged (A0.6).
3. **Kit-hate** — a hate-tagged human targets the pack body named by its
   kit's `hate` field (the lobber) whenever that body is within its
   `aggro_tiles`. Visible as a beeline; the artillery-hater teaches "protect
   the artillery" (the Tibia druid-hate beat).
4. **Lowest-HP switch** — if any pack body within `aggro_tiles` is below
   `lowhp_switch_pct` of max HP, target it (wounded prey; NotebookLM Q1's
   priority targeting).
5. **Focus stickiness (first-seen)** — humans gain a `@focus` ref: the first
   target acquired holds until (a) it dies/leaves aggro range, (b) a
   strictly-closer pack body undercuts it by `proximity_switch_margin_tiles`
   (the pass-by steal — hysteresis makes switches rare and explainable), or
   (c) rule 3/4 fires. Initial acquisition = nearest (current rule).

Determinism: same inputs → same chain result (min_by with roster-index
tiebreak preserved). Retarget causes are telemetry (see events).

### 2. Position pressure (engaged cap + pressuring ring)

Humans sharing a focus target are partitioned each tick, deterministic
(sort by Chebyshev distance, roster-index tiebreak):
- The nearest `engaged_cap_per_target` are **:engaged** — behave exactly as
  today (chase, surround, attack).
- The remainder are **:pressuring** — path toward standoff tiles at
  `pressure_ring_tiles` from the target, do NOT attack, DO occupy tiles
  (they body-block escape routes — the encirclement dread). Ring-slot
  choice is deterministic: each pressuring human targets the nearest free
  ring tile, ties broken by roster index. Grid geometry bounds melee at 8
  adjacent; the cap keeps lethality bounded below that while the ring makes
  density VISIBLE (the can-I-die-here read).
- **Anchor delta, recorded:** the parking-lot shape note said "aggro
  soft-cap 8-12" as a global notion (Tibia's 8-box, a 4-player party). This
  spec binds the cap PER TARGET (hypothesis 5) because our pack is 3 bodies
  and the 8-box is per-tile geometry — a global cap would let one body
  absorb the whole allowance. Same intent, corrected topology; the number
  is a data hypothesis either way.
- Stance is render-readable: pressuring humans draw with a distinct cue
  (display.json keys; capture-verifiable; name on the fiction order form).
  Renderer reads state only — no draw-path sim mutation (taunted_target law).
- Escapability law (cadence fork): the ring is porous by design — dodge and
  the two kit specials still break it; a wipe means the player let the box
  close. Per-hit damage is NOT raised anywhere in this increment.

### 3. Leash-with-no-heal (walk home)

- `Creature` gains `@home_tile`, stamped at spawn and at respawn (friction 1:
  no home exists today; `schedule_human_respawn` already computes the nearest
  spawn point — the same point becomes the stamp).
- A human with NO pack body within `aggro_tiles` for `leash_linger_frames`
  enters **:returning**: walks home via a flow field anchored on its home
  tile, KEEPING current HP (no-heal — the owner's named rule; RuneScape
  Elvarg HP-persistence is the corpus analog). Home tiles never move, so
  home fields are computed once per zone load and never invalidated (cache
  infra exists, world.rb:162-170).
- Returning humans re-engage normally if a pack body enters `aggro_tiles`
  (a leashed human is dispersed, not invulnerable). Zone-flip therefore =
  a breather that dissolves the camp but banks no free healing; re-entry
  meets spread-out, damaged-but-alive humans — never a reset.

### 4. Respawn discipline (the grinder fix)

- **Screen-block suppression**: `respawn_due_humans` (world.rb:620-632) gains
  a check — a respawn whose spawn point lies within
  `respawn_block_tiles` of any pack body is DEFERRED (the existing
  occupied-tile defer pattern). Tibia-documented (creatures never respawn
  on-screen); creates the lap rhythm: farm a pocket dry, move on, it
  refills behind you.
- **Gate beachhead**: humans do not ACQUIRE a target (rules 3-5) while that
  target stands within `beachhead_tiles` of an arrival tile. Waiver is
  PER-HUMAN: a human damaged or taunted by the pack ignores the beachhead
  for the rest of its life (attacking from the doormat waives the
  protection you're abusing; the rest of the zone stays calm). Arrival
  stops being a spawn-adjacent ambush.

### 5. Depth gradient (minimal, in-map, data-level)

- A distance-from-gate field is computed once at zone load (FlowField
  anchored on the gate tile — infra exists, flow_field.rb:17-37).
- **Density**: district spawn points grow ~7 → ~14 (data/zones/district.json)
  placed in bands — sparse near the gate (this ALSO starves the grinder),
  dense at the far end. The spawn-point count IS the density budget
  (friction 10 — no new spawn system).
- **Richness**: `spawn_drop` applies a position multiplier from the dead
  human's distance-from-gate band: zone data key `drop_gradient` (list of
  [min_distance, multiplier]). Deeper = richer + denser = the published
  risk/reward tier the owner's own notebook session surfaced (spawn
  rankings), giving "bank or push DEEPER" a literal deeper for the first
  time in six verifies.

### 6. Tank-first possession (bundled)

- `data/balance/combat.json` pack gains `"initial_possessed": "blocker"` —
  a separate field, NOT a member-array reorder (reordering changes Tab
  cycling; friction 8). `Pack#initialize` reads it, fetch-default to
  `members.first`. Invalidates every replay stream — bundled here because
  A2 re-pilots everything anyway.

### Events + telemetry

- New registered events (world.rb EVENTS, registered on first use):
  `:human_leashed` (actor, tile, hp) · `:human_retargeted` (actor, from,
  to, cause ∈ {hate, lowhp, proximity, acquired}) — the retarget-cause
  telemetry is the fairness oracle for verify Q6.
- Harness-computed telemetry (event log, zero sim additions): wipes + body
  deaths per session (cadence vs the 6-8 baseline) · retarget counts by
  cause · leash events per life · deepest band reached per life ·
  `carried_at_death` · contacts_en_route per recovery (D1 oracle — the
  live-corridor contest measure; five verifies of 0 contested is the
  baseline to beat) · banked events (vs the fifth verify's 5).

### Data (new keys, hypothesis values)

`data/balance/threat.json` (new file):
`{"proximity_switch_margin_tiles": 3, "lowhp_switch_pct": 0.35,
"engaged_cap_per_target": 5, "pressure_ring_tiles": 2,
"leash_linger_frames": 90, "respawn_block_tiles": 12, "beachhead_tiles": 4}`
Plus: `combat.json` — hate-variant rusher entry (`"hate": "lobber"`) on a
subset of spawn points, pack `initial_possessed`; `zones/district.json` —
banded spawn points + `drop_gradient`; `display.json` — pressuring-stance
cue keys. Perf: humans ~2x (7→14), AI stays O(humans × pack); home + gate
fields are static per zone load. `rake perf` re-run (current p95 0.100ms vs
16.6 budget — headroom is enormous, but the wall re-proves it).

## Presentation spec (Rule 2 surface)

Three new player-readable states, all render-only reads of sim state:
1. **Pressuring stance** — a pressuring human is visibly distinct from an
   engaged one (the ring reads as a closing box, not lag).
2. **Leash walk-home** — a returning human reads as disengaging (back
   turned, path away), distinct from idle and from chase.
3. **Depth** — the deep district reads denser on camera (band placement
   does this physically; no new HUD, quiet-HUD law).
No HUD changes. Fiction order form (names await the bible; spec-speak stays
internal): the pressuring stance, the hate-tagged rusher variant, the leash
walk-home behavior, district depth-band names, the beachhead, and (D1b,
pre-listed) inscription/god-mark; (post-A2) the Challenger.

## Harness + gates

- New gate script `threat_pull.json`, pilot-authored: (act 1) beachhead
  arrival + first pull sized by walking (2-3 humans); (act 2) deep-band
  overpull — cap + pressuring ring on camera, escape through the ring;
  (act 3) leash breather — disengage, humans walk home, re-entry meets
  dispersed damaged humans; (act 4) a carrying death deep + contested
  run-back (live corridor on camera).
- ALL SEVEN existing wall scripts re-piloted (tank-first + new AI invalidate
  every stream) + the new script → 8-script wall: double replay + md5 +
  critic, ALL blocking (Rule 2).
- APPENDED vision checks (31 → 34, existing never weaken): 1)
  `pressure_ring_reads` — pressuring humans visibly distinct from engaged,
  ring reads as encirclement; 2) `leash_walkback_reads` — returning humans
  read as disengaging, not pathfinding-broken; 3) `gradient_depth_reads` —
  deep frames read denser than gate frames.
- Tests (minitest, real World, no mocks): hate/lowhp/proximity/sticky chain
  unit-through-World; taunt + anchor precedence preserved (taunt_test.rb
  untouched-green is the regression oracle); engaged/pressuring partition
  determinism + cap boundary; pressuring never attacks; leash stamps home,
  keeps HP, re-engages; respawn suppression defers within radius and fires
  beyond it; beachhead blocks acquisition and is waived by player attack;
  gradient multiplier bands; `initial_possessed` fetch-default; data-load
  assertions (margin > 0, cap ≥ 1, beachhead < aggro_tiles, grace laws
  untouched); determinism (byte-identical double replay). Existing
  `test_rushers_hunt_the_nearest_pack_member_not_the_possessed`
  (world_test.rb:656) is REWRITTEN to the new chain (it pins the old law).
- `rake` + perf + 8-gate wall green; adversarial impl review; merge --no-ff,
  NO push.

## Fun-verify (SIXTH — owner questions, after ship, two AskUserQuestion batches)

**Preamble:** if you never went deeper than the first band, say so — the
gradient never fired and Q1/Q3 read against a flat district.

1. **Pull sizing:** did choosing how many humans to wake — by how deep you
   walked and what you let see you — feel like a decision you were making?
2. **The box:** when followers closed around you without attacking, did you
   feel the box closing? Did you ever run BECAUSE of it?
3. **The chore question (SIXTH ask):** did "bank now or push deeper" change
   now that deeper is denser and richer, and the walk back is contested?
4. **The run-back:** after a carrying death or wipe, was the recovery ever
   in doubt — did the corridor fight back this time?
5. **Wipe weight + entrainment:** were your wipes rarer? On the last-body
   stretch, did your body react — tense up, lean forward? When?
6. **Fairness valve:** did humans switching targets (onto the lobber, onto
   the wounded) read as intelligence or as randomness? Any switch that felt
   cheap? (Tunes margins/thresholds; does NOT quarantine Q3 — unlike the
   ledger's invisibility, a rough edge here degrades fairness, not
   visibility of the experiment.)
7. **The breather:** did disengaging (leaving the district, breaking
   contact) feel like a real option? Did their kept HP on return feel fair?
8. **Carryover control (verbatim):** if your banked number were silently
   halved, would you care now? (Control reading — this build still does not
   spend banked.)

**Pre-registered routing (locked at the brainstorm — do not re-derive):**
- **Q3 moved** → A2 wins; ledger disposition already locked (STAYS); next
  increment is a scope debate with D1b-inscription as the queued candidate.
- **Q3 unmoved + threat FELT** (any real positive on Q2/Q4/Q5) → **D1b
  promotes AUTOMATICALLY** (the same owner-locked pattern that promoted A2),
  shaped as the inscription economy (PARKING_LOT outcomes; session-only
  persistence first). No new scope debate.
- **Threat NOT felt** (Q2/Q4/Q5 all dead) → A2 tuning iteration (thresholds,
  density, cap — data only), NOT new scope, NOT presentation.
- Threat felt but fights lack scary PEAKS → the Challenger increment's
  named trigger fires (human counterplay, fairness ladder mandatory).
- Q6 "randomness/cheap" → margin/threshold tuning signal, recorded.
- Banking collapse or convenience-death telemetry → D1b's trigger fires as
  before (fees/inscription re-price death).

## Deliberately absent (recorded so review doesn't re-litigate)

Economy code of any kind (D1b — vision LOCKED as inscription-within-ritual,
shape doc `drafts/_council-economy-verdict.md`); Challenger / fear-scatter
(post-A2, trigger named); scavengers (D3); Shooters (A1+); new bindings; new
enemy kits; LOS/vision systems; dynamic threat scaling with carry (corpus
anti-license: no touchstone escalates on player wealth); respawn walk-in
animation; corpse-system changes (live corridor is emergent, by design);
term/grace retune (parked until measured margins); any per-tick randomness
in targeting (learnability law).
