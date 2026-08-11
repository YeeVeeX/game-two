# D1 — The corpse run (corpse containers + own-corpse recovery)

Status: REVISED (2026-08-11, post 3-lens adversarial review — code-fit, design, fun;
run as a direct Agent fan-out after the review Workflow died on stalls. 21 findings;
verdicts + fold ledger: `drafts/_d1-spec-review.md`). Owner-directed 2026-08-10:
*"pull back and not add more complicated things if we haven't polished the core game
essence/loop… what is something fundamental?"* — approach choice delegated to the dev
of record. A2 (threat system) explicitly demoted by the owner — scope contract v7.

Binding upstream: `docs/design-corpus/death-economy-design.md` (3-critic-gated
2026-08-09). This spec implements its "D1 — the corpse-run slice" staging against the
code as it exists post-A0.6, with recorded trims AND one recorded anchor conflict
(see Term below — the doc's term-sizing rules are mutually inconsistent at current
map scale; this spec binds to the doc's measurable margin target). Fun thesis under
test, verbatim: *"losing a body should sting; going back should be the tensest walk
in the game."*

## Why this is the fundamental increment (the chore diagnosis)

D0's fun-verify failed twice ("bank or push deeper = a chore"), including once AFTER
taunt shipped. The diagnosis on file: the carry has no felt stakes. D0's death rule
is already maximally harsh — carried value VANISHES — so the missing thing is not
harshness, it is **drama and agency**: loss today is a silent number change. The
corpse run converts that exact moment into the game's signature sequence: the pile
is THERE, the clock is running, the humans have respawned — go get it back.

**The inversion, owned (review DS-1):** D1-without-fees does not merely soften the
single-death loss — it REMOVES the permanent single-death loss entirely (a carried
pile converts to a recoverable container; only term expiry destroys it). The
experiment D1 runs is whether drama alone moves the chore verdict. If banking
collapses because a corpse is a good-enough bank, that is **D1b's trigger** (fees
re-price death), not a D1 tuning knob — the telemetry below instruments exactly
that.

Corpus evidence (cite, never recall): DNA-1 "loss-and-recovery cycles with personal
stakes" is the strongest element in the gamesmith corpus — confirmed in 4 of 5
games, "the load-bearing wall" (`docs/design-corpus/gamesmith/genre-dna.md` §DNA-1).
Cite honesty (review DS-6): the death-economy doc pre-approved corpse containers
REPLACING the vanish; the doc's own D1 kept death priced via body fees. The fee trim
— and therefore the NET softening — is this spec's call (recorded under OUT),
accepted because the variable under test is drama, not price.

## Scope (one variable at a time)

**IN — the gated D1 staging, minus fees:**
1. **Corpse containers**: a pack body that dies carrying transfers its load to a
   sim-owned container at its death tile (replaces the D0 vanish + carried_lost).
2. **Own-corpse recovery**: surviving pack members loot the container via the
   existing interact verb, after a settle delay.
3. **Term expiry**: containers decay on a global clock; expiry destroys the load
   (the permanent-loss tier — this is where carried_lost moves).
4. **Wipe grace**: at pack wipe, every container's remaining term is topped up to
   at least the grace floor, so the run back is always possible.

**OUT — recorded trims and deferrals:**
- **Body fees + vat re-growth (D1b, parked)**: the tension thesis doesn't need
  them; they return with the ledger/economy increment. Consequences accepted:
  dead vessels stay dead until wipe (current rule) — so a wipe leaves AT LEAST TWO
  loaded corpses, not the doc's three (the act-1 body stays dead); and the doc's
  fee-priced degenerate strategies stay unpriced. Watch list (complete per review
  DS-7): die-to-teleport, die-to-deposit (blunted by settle only), **suicide
  fast-travel** (wipe-as-teleport — priced only by a 90f veil + walking back
  empty), **grace-refresh** (spec-new: a deliberate wipe tops every container back
  to the grace floor — real only because grace is now a meaningful fraction of
  term; watch it next to the grace constant). Pack-parking and
  die-to-teleport-HOME are structurally dead in this sim: `enter_zone` moves the
  whole living pack through every gate — no mules can exist.
- No practice fine, no insurance (D2 — blocked on skill-through-use, unchanged).
- No scavengers, no term-extension marks (D3, unchanged).
- No new HUD elements (carry HUD already exists; quiet-HUD law).
- No new input (interact is the verb).
- Data-reading caveat carried from the doc: with no fine, death frequency in
  telemetry is an upper bound on recklessness, not a cost signal.

## Sim spec

- **Container creation.** In the `actor_died` path (world.rb wire_events), a
  pack-faction body with `carried > 0` drains its carried into a new container
  record in the per-zone list `@corpse_loads[zone]`:
  `{id:, tile:, amount:, term_left:, term:, settle_left:}` where `id` is a
  **monotonic serial** (world-owned counter). The D0 branch (emit `carried_lost` +
  vanish) is REPLACED for pack deaths. Humans never carry; nothing changes for
  them.
- **Corpse link (review CF-1/CF-2/DS-3 — the lifecycle collision fix).** The
  handler stamps the freshly created cosmetic corpse record (`leave_corpse` has
  already run) with `container_id: id`. While a corpse record carries a live link:
  it is **exempt from the `prune_caches` age-reject and from the `CORPSE_CAP`
  eviction** (cap evicts the oldest UNLINKED record; linked records may exceed the
  cap — their count is bounded by containers alive). At loot and at expiry the sim,
  in the same event-time mutation, **clears the link and re-anchors the record's
  `at_frame` to the current frame** — so the existing fade begins fresh from that
  moment. Renderer and prune read only the link flag: pure readers, no draw-path
  sim mutation (the taunted_target law). NB the serial link exists because
  tile+frame keys can collide — two same-frame knockback deaths can land two
  corpses on one tile.
- **Same-tile stacking.** A second death on an occupied tile creates a SECOND
  container (no merging — containers are identity-bearing: one body's load, its
  own clock). Loot order on a stacked tile = creation order (deterministic).
- **Term.** `term_left` ticks down **every sim frame in every zone** — exactly the
  existing `tick_drops` pattern (verified: ticks all zones, world.rb:387-396;
  hitstop pauses it via the early return; the veil pauses it because
  `:nest_respawn` never calls tick_world — pinned by a new test). At zero: the
  load is destroyed, `carried_lost` emits, the container is removed, the corpse
  link clears.
  **Term value — anchor conflict recorded (review FN-6):** the doc's "term >= 3x
  median recovery, floor 10 min" and its own margin target (0.3-0.5, ">0.7 median
  = set dressing") are mutually exclusive — 3x fixes margin at 0.67, and the
  10-min floor at measured map scale forces ~0.95. D1 binds to the **margin
  target**, the doc's measurable oracle. `corpse_term_frames = 5400` (90s — 3x the
  drop decay grammar the player already owns, 18 rusher-respawn waves; against the
  measured 30-45s opposed recovery it yields margin ~0.5-0.67). A HYPOTHESIS, to
  be reset from the first measured `wipe_to_last_loot_s`, never by feel.
- **Settle.** `settle_left` starts at `loot_settle_frames = 300` (5s) and ticks
  like the term. While positive, interact on the tile skips the container (skip =
  deterministic fall-through to the next interact priority).
  **Deviation from doc law 3, owned (review DS-5):** the doc gates looting on
  out-of-combat; we gate on a flat per-container clock, which deliberately PERMITS
  mid-melee looting after the settle — fun-verify Q1's decision requires it.
  Weaker die-to-deposit blunting accepted (see OUT). Designed alignment, recorded:
  `loot_settle_frames` (300) == rusher `respawn_frames` (300) — the loot window
  opens exactly as reinforcements can land; tune them together.
- **Recovery.** Interact priority becomes: drop pickup → **corpse loot** → bank
  (a drop on a corpse tile takes two presses — same deterministic two-press rule
  D0 set for drop-on-station). Looting moves the FULL amount into the interactor's
  `carried` (no partial loots), removes the container, clears + re-anchors the
  corpse link, emits `:corpse_looted`. Possessed-only, same as all interaction.
- **Wipe.** `handle_possessed_death` → pack_wiped path gains: every container in
  every zone gets `term_left = [term_left, wipe_grace_frames].max`,
  `wipe_grace_frames = 2700` (45s ≈ 2.2x the worst-case unopposed run-back —
  measured, per the doc's tighten-by-measurement rule; hypothesis like the term).
  **Grace rationale (corrected per review CF-6):** the grace covers the RUN BACK —
  travel plus re-fighting through respawned humans after the first-dead corpse has
  been draining all fight. It is NOT about the veil: terms are frozen during
  `:nest_respawn` (tick_world never runs) and the veil is only 90 frames.
  Invariant: `grace <= term`, pinned by a data-load assertion test. Containers
  survive the respawn sweep (they are the POINT of the run back).
- **Events** (registered on first use), payloads pinned (review CF-5):
  `:corpse_loaded` (actor, tile, amount) · `:corpse_looted` (actor, tile, amount,
  carried) · `carried_lost` re-pointed to term expiry with payload (amount, tile,
  zone) — `actor` deliberately dropped: the body may have been revived by expiry
  time. Gate scripts aim at all three.
- **Expiry flash storage (review CF-4):** per-zone (`@drops`/`@corpses` Hash.new
  pattern), ticked for all zones in tick_world, RENDERED for the current zone only
  — the taunt-pulse flat-array precedent is zone-unsafe for events that fire in
  abandoned zones. Per-zone storage also needs no enter_zone clearing.
- **Data**: new `data/balance/death.json` —
  `{"corpse_term_frames": 5400, "loot_settle_frames": 300,
  "wipe_grace_frames": 2700, "expiry_flash_frames": 45, "settle_pip_alpha": 0.4}`.
  Zero balance constants in Ruby.

## Presentation spec (Rule 2 surface)

Three player-readable corpse states, built ON the existing corpse rendering via the
container link:

1. **Loaded** — the linked pack corpse body draws at full strength (the link
   exempts it from fade/prune/cap, so "no fade while loaded" actually holds — the
   DRAFT spec's version was killed by four code paths, review CF-1). The **glean
   pip** is a **hollow magenta outline square, tile-centered on the CONTAINER's
   tile** — outline-not-filled because a free drop is a filled magenta square and
   the two render concentric in the spec's own drop-on-corpse case (review DS-4:
   filled = pickup, outline = state, the taunt-pulse grammar); tile-centered
   because knockback kills can leave the corpse RECT a tile away from the interact
   tile (review CF-3). While settling, the pip renders at `settle_pip_alpha` and
   **snaps to full alpha the frame the container becomes lootable** — the snap is
   the ready tell; a denied press over a dim pip reads as "not yet," not "broken"
   (review FN-5). The pip's alpha then fades over the term's final third (last
   30s — now actually witnessable in a session).
2. **Looted-empty** — pip gone; the corpse's fade starts from the loot frame (the
   sim re-anchored `at_frame`; without that, a body looted after 10s would snap
   from full strength to invisible — review CF-2).
3. **Expired** — pip gone at `carried_lost`; fade starts from the expiry frame;
   one brief dark flash on the tile (`expiry_flash_frames = 45` — 0.75s; the
   DRAFT's 20f was sub-perceptual for the one moment that defines permanent loss,
   review FN-7).

No HUD change. Fiction order form: "the corpse run", "term expiry on screen", and
"what a loaded vessel-corpse is" are items 5/7/8 on the death-economy doc's order
form — names await the bible, spec-speak stays internal.

## Harness + gates

- New gate script `corpse_run.json`, authored VIA PILOT MODE: (act 1) one body
  dies loaded and a SURVIVOR loots it mid-hunt — the settle wait + loot-or-fight
  decision on camera, INCLUDING one frame with a free drop sitting on a loaded
  corpse tile (the concentric case, review DS-4); (act 2) the wipe with at least
  two loaded corpses, one stacked-tile case; (act 3) the run back and recovery
  inside the term; (act 4) one deliberate term-expiry asserted via event
  (off-camera allowed — but at 90s term the expiry flash is also stageable on
  camera if the pilot flight finds a clean angle).
- APPENDED vision checks (23 → 26, existing never weaken, pass-true hatches):
  1. `corpse_load_reads` — a loaded pack corpse carries the hollow magenta glean
     pip, distinct from free drops (filled), the bank station, and looted/expired
     corpses — INCLUDING when a free drop occupies the same tile as a loaded
     corpse.
  2. `corpse_states_distinct` — loaded / looted-empty / expired read as three
     different states across the replay, and a settling (dim-pip) corpse reads
     distinct from a lootable (full-pip) one.
  3. `corpse_run_reads` — post-wipe frames read as a purposeful return: the pack
     re-entering the district while loaded corpses with pips await.
- **Telemetry (restored from the doc — its only un-recorded trim, review DS-1;
  harness-computed from the event log at session end, zero sim additions):**
  `d1_fired: carrying_deaths=<n> wipes=<n> corpse_looted=<n> carried_lost=<n>` ·
  per-recovery `wipe_to_last_loot_s` + `contacts_en_route` · per-corpse recovery
  margin (`term_left_at_loot / term`, target 0.3-0.5) · `carried_at_death` per
  container · settle-open-to-loot frames · banked-event cadence vs the D0
  baseline in `drafts/_d0-cadence-measurements.md` (banking-collapse detector —
  D1b's trigger).
- Tests (minitest, real World, no mocks): death-with-carry creates container +
  emits corpse_loaded; death-without-carry creates none; humans never create
  containers; **linked corpse survives prune_caches past CORPSE_FADE_FRAMES; cap
  evicts oldest UNLINKED, linked records survive a 40-kill flood; fade re-anchors
  at loot and at expiry; term does not tick during nest_respawn (veil freeze);
  grace <= term data assertion; expiry flash records are per-zone (nest floor
  never flashes for a district expiry)**; settle gate refuses interact then
  admits it; loot transfers full amount + removes container + emits; interact
  priority drop→corpse→bank on a stacked tile; term ticks in abandoned zones (the
  tick_drops law); expiry destroys load + emits carried_lost + container removed;
  wipe grace tops up short terms and leaves long terms alone; containers survive
  pack respawn; stacked containers loot in death order; determinism (same script,
  byte-identical). Existing D0 tests updated: the carried-vanishes assertions
  (world_test.rb:1051-1079) become container assertions;
  test_banked_survives_the_wipe stays valid.
- `rake` + perf + ALL gates green (now 6 scripts); adversarial impl review;
  merge --no-ff, NO push.

## Fun-verify (owner questions, asked after ship)

**Preamble (review FN-1):** if you never died while carrying, answer Q1-Q6 "N/A —
never fired." That N/A is itself the headline result: it indicts combat threat
(nothing endangers the carry), not the corpse system — and the telemetry line will
say the same from the event counts.

1. A packmate died carrying mid-fight — did protecting the settling corpse while
   deciding "loot now or finish the fight" feel tense, or like standing in line?
2. After a full wipe: (a) did the run back feel DANGEROUS — could you have lost
   the recovery? (b) did it feel LONG enough to dread, or was it over before
   dread could start? (2a=no indicts threat; 2b=short indicts map scale — that is
   A3's problem, not this mechanic's.)
3. Did "bank now or push deeper" change now that deeper means your pile can end
   up on a corpse out there? (The D0 chore question, third ask — this is the one
   D1 exists to move.)
4. Did you still bother banking at all? If your banked number were silently
   halved, would you care? (A "didn't bank / wouldn't care" routes the failure to
   D1b/the ledger — the pile itself lacks meaning — not to the corpse run.)
5. Did any corpse's clock ever influence a decision — did you notice one running
   out? ("Never noticed" = term-tuning signal, recorded as such.)
6. Did you ever deliberately die or wipe because it was CONVENIENT (teleport home,
   refresh a clock)? (Watch-list probe — a yes is D1b's trigger, not a bug.)

## Deliberately absent (recorded so review doesn't re-litigate)

Body fees / vat re-growth (D1b — parked WITH its panel-gated design); partial
looting; container merging; carry friction (decided against at D0, unchanged); any
purchase affecting the drop or the run (law 5); scavengers (D3); permadeath
(canon-locked, never); FN-5's optional denied-press flash (the dim pip already
carries the signal — one variable at a time).
