# D1 — The corpse run (corpse containers + own-corpse recovery)

Status: DRAFT (pre-review). Owner-directed 2026-08-10: *"pull back and not add more
complicated things if we haven't polished the core game essence/loop… what is
something fundamental?"* — with approach choice delegated to the dev of record.
A2 (threat system) explicitly demoted by the owner as "nice to have, an extra for
later" — recorded in scope contract v7.

Binding upstream: `docs/design-corpus/death-economy-design.md` (3-critic-gated
2026-08-09 — THE design authority for this slice; this spec implements its "D1 —
the corpse-run slice" staging against the code as it exists post-A0.6, with one
recorded trim). Fun thesis under test, verbatim from that doc: *"losing a body
should sting; going back should be the tensest walk in the game."*

## Why this is the fundamental increment (the chore diagnosis)

D0's fun-verify failed twice ("bank or push deeper = a chore"), including once
AFTER taunt shipped. The diagnosis on file (checkpoint + gamesmith digest): the
carry has no felt stakes. But D0's death rule is already maximally harsh —
carried value VANISHES on death — so the missing thing is not harshness, it is
**drama and agency**: loss today is a silent number change. Nothing to see,
nothing to decide, nothing to do about it. The corpse run converts that exact
moment into the game's signature sequence: the pile is THERE, the clock is
running, the humans have respawned — go get it back.

Corpus evidence (cite, never recall): DNA-1 "loss-and-recovery cycles with
personal stakes" is the strongest element in the gamesmith corpus — confirmed in
4 of 5 games, "the load-bearing wall" (`docs/design-corpus/gamesmith/genre-dna.md`
§DNA-1). Tibia's bank loop stays tense because loss is real and recovery is a
run (`drafts/_gamesmith-touchstone-digest.md` §2-3). Note D1 makes a single
death SOFTER than D0 (recoverable instead of vanished) while making it FELT —
that trade is deliberate and the death-economy doc pre-approved it.

## Scope (one variable at a time)

**IN — exactly the gated D1 staging, minus fees:**
1. **Corpse containers**: a pack body that dies carrying transfers its load to a
   sim-owned container at its death tile (replaces the D0 vanish + carried_lost).
2. **Own-corpse recovery**: surviving pack members loot the container via the
   existing interact verb, after a settle delay.
3. **Term expiry**: containers decay on a global clock; expiry destroys the load
   (the permanent-loss tier — this is where carried_lost moves).
4. **Wipe grace**: at pack wipe, every container's remaining term is topped up to
   at least the grace floor — the first-dead corpse must not expire during the
   veil the player cannot act in (panel finding B-X4).

**OUT — recorded trims and deferrals:**
- **Body fees + vat re-growth (D1b, parked)**: the tension thesis doesn't need
  them; they are the economy's sink and return with the ledger/economy increment.
  Consequence accepted: dead vessels stay dead until wipe (current rule), and
  the doc's fee-priced degenerate strategies (die-to-teleport, die-to-deposit)
  remain unpriced — the settle delay blunts die-to-deposit, and the rest are
  optimizer exploits a solo fun-verify won't meet. Watch, don't pre-fix.
- No practice fine, no insurance (D2 — blocked on skill-through-use, unchanged).
- No scavengers, no term-extension marks (D3, unchanged).
- No new HUD elements (carry HUD already exists; quiet-HUD law).
- No new input (interact is the verb).

## Sim spec

- **Container creation.** In the `actor_died` path (world.rb wire_events), a
  pack-faction body with `carried > 0` drains its carried into a new container
  record in the per-zone list `@corpse_loads[zone]`:
  `{tile:, amount:, term_left:, term:, settle_left:, corpse_at_frame:}`.
  The D0 branch (emit `carried_lost` + vanish) is REPLACED for pack deaths.
  Humans never carry; nothing changes for them. The existing cosmetic corpse
  record still spawns (renderer alignment below).
- **Same-tile stacking.** A second death on an occupied tile creates a SECOND
  container (no merging — unlike drops, containers are identity-bearing: each
  is one body's load with its own clock). Loot order on a stacked tile =
  creation order (deterministic).
- **Term.** `term_left` ticks down **every sim frame in every zone** — exactly
  the existing `tick_drops` pattern (nest time is real time; the death-economy
  doc decided this explicitly so the data file doesn't encode an accident).
  Hitstop/veil pause it the same way they pause drops (counted in tick_world).
  At zero: the load is destroyed, `carried_lost` emits (amount, tile, zone),
  the container is removed. Term value: `corpse_term_frames = 36_000` (10 min —
  the doc's floor; deliberately generous at current district scale, tightens by
  measurement when districts deepen, never by feel).
- **Settle.** `settle_left` starts at `loot_settle_frames = 300` (5s hypothesis)
  and ticks down like the term. While positive, interact on the tile skips the
  container (a corpse mid-melee is not a bank window; this is the doc's
  die-to-deposit blunting, implemented as a flat per-container clock instead of
  a combat-state machine — deterministic, no new state tracking).
- **Recovery.** Interact priority becomes: drop pickup → **corpse loot** → bank
  (a drop sitting on a corpse tile takes two presses — same deterministic
  two-press rule D0 set for drop-on-station). Looting moves the FULL amount
  into the interactor's `carried` (no partial loots), removes the container,
  emits `:corpse_looted` (actor, amount, carried). Possessed-only, same as all
  interaction (which body carries the recovered pile is a player decision).
- **Wipe.** `handle_possessed_death` → pack_wiped path gains: every container in
  every zone gets `term_left = [term_left, wipe_grace_frames].max` with
  `wipe_grace_frames = 18_000` (5 min). Containers survive the respawn sweep
  (they are the POINT of the run back); the taunt sweep precedent clears locks,
  not loads.
- **Events** (registered on first use): `:corpse_loaded` (actor, tile, amount),
  `:corpse_looted` (actor, tile, amount, carried), and the existing
  `carried_lost` re-pointed to term expiry. Gate scripts aim at all three.
- **Data**: new `data/balance/death.json` —
  `{"corpse_term_frames": 36000, "loot_settle_frames": 300,
  "wipe_grace_frames": 18000, "expiry_flash_frames": 20}`.
  Zero balance constants in Ruby.

## Presentation spec (Rule 2 surface)

Three player-readable corpse states (the gated doc's D1 vision requirement),
built ON the existing corpse rendering, not beside it:

1. **Loaded** — the pack corpse body draws at full strength (no fade while a
   live container sits on its tile) with a **glean pip**: the drop-magenta core
   square centered on the corpse. Magenta = "value here" is grammar the player
   already knows from drops. The pip's alpha fades over the term's final third —
   the same expiry-telegraph grammar drops and the taunt underline already
   taught.
2. **Looted-empty** — pip gone; the corpse starts the existing fade from that
   frame.
3. **Expired** — pip gone at `carried_lost`; corpse fade continues; one brief
   (data-driven `expiry_flash_frames`, cosmetic record precedent) dark flash on
   the tile so an on-screen expiry reads as an event, not a disappearance.

No HUD change. Fiction order form: "the corpse run", "term expiry on screen",
and "what a loaded vessel-corpse is" are already items 5/7/8 on the
death-economy doc's order form — names await the bible, spec-speak stays
internal.

## Harness + gates

- New gate script `corpse_run.json`, authored VIA PILOT MODE, following the
  panel-corrected script shape from the death-economy doc: (act 1) one body
  dies loaded and a SURVIVOR loots it mid-hunt — the tactical tier on camera;
  (act 2) the wipe with at least two loaded corpses, one stacked-tile case;
  (act 3) the run back and recovery inside the term; (act 4) one deliberate
  term-expiry asserted via event (off-camera allowed, the doc says so).
- APPENDED vision checks (23 → 26, existing never weaken, pass-true hatches):
  1. `corpse_load_reads` — a loaded pack corpse carries the magenta glean pip,
     distinct from free drops, the bank station, and looted/expired corpses.
  2. `corpse_states_distinct` — loaded / looted-empty / expired corpses read as
     three different states across the replay's frames.
  3. `corpse_run_reads` — post-wipe frames read as a purposeful return: the
     pack re-entering the district while loaded corpses with pips await.
- Tests (minitest, real World, no mocks): death-with-carry creates container +
  emits corpse_loaded; death-without-carry creates none; humans never create
  containers; settle gate refuses interact then admits it; loot transfers full
  amount + removes container + emits; interact priority drop→corpse→bank on a
  stacked tile; term ticks in abandoned zones (the tick_drops law); expiry
  destroys load + emits carried_lost + container removed; wipe grace tops up
  short terms and leaves long terms alone; containers survive pack respawn
  (not swept); stacked containers loot in death order; determinism (same
  script, byte-identical). Existing D0 tests updated: the carried-vanishes
  assertions become container assertions.
- `rake` + perf + ALL gates green (now 6 scripts); adversarial impl review;
  merge --no-ff, NO push.

## Fun-verify (owner questions, asked after ship)

1. You died carrying and the pile stayed on your corpse — did going back for it
   feel like the tensest walk in the game, or like an errand with extra steps?
2. After a full wipe: did the run back from the nest feel like a RUN (clock
   pressure, respawned humans) or a formality?
3. Did "bank now or push deeper" change now that deeper means your pile can end
   up on a corpse out there? (The D0 chore question, third ask — this is the
   one D1 exists to move.)
4. Did you ever choose to loot a fallen packmate's corpse mid-fight vs finishing
   the fight first — and was that a real decision?

## Deliberately absent (recorded so review doesn't re-litigate)

Body fees / vat re-growth (D1b — parked WITH its panel-gated design, returns
with the economy increment); partial looting; container merging; carry
friction (decided against at D0, unchanged); any purchase affecting the drop or
the run (law 5); scavengers (D3); permadeath (canon-locked, never).
