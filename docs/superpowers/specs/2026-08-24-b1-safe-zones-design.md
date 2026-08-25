# B1 — Safe zones (both hubs, visible boundary) — grill + spec (s61, 2026-08-24)

Lane 2 row 6 of the v19 foundation (`drafts/_v19-foundation-20260822.md`),
RATIFIED-G + RATIFIED-J under the one verdict line ("approved as
recommended, proceed"). This spec turns the ratified letter into build
tickets. Written ratification-neutral (s61: docs-only session while the
s59 canary-rebank line + varekka re-cut pick are both pending); B1-T1 and B1-T2 are both mechanically BLOCKED until the staged J7-B commits push:
the staged set includes `src/game/world.rb` (T1 scope), and ALSO
`harness/gate_checks.json` + `drafts/_gate-verdicts.log` (T2 scope —
every `rake gate` run appends to the verdicts log) — `git commit --
path` commits working-tree state, so any edit there would contaminate
the pending J7-B commits (fresh-eyes review s61, blocking-1: prose
sequencing alone fails under two-seat concurrency, s56 precedent).

## The ratified letter (what is already decided — never re-litigate)

- `safe: true` zone attribute, data-driven, **sibling of `hub:`**.
- v19 half = **enemies never pursue/damage inside**; the PvP
  combat-lock half stays RECORDED for the >2-players future.
- Coverage: **BOTH hubs = zone_7 + camp** (the positions row names
  exactly these two).
- Boundary made **VISIBLE** — "unmarked safe borders = readability
  defect"; Rule 2 surface.
- Camp feel change acknowledged (soak fights=4) — **own capture +
  playtest before ship**.
- Shelf touchstones (already cited by the foundation):
  `world-events-towns-and-folklore-mechanics` (radial danger gradient,
  "safety at the depot tile") · `tibia-mechanics-…` (protection zones)
  · `mmo-economy-design-sinks-and-faucets` (vendor-anchor/hub law).

## Grill findings — mechanical ground truth (verified live s61)

Problem, concretely: Junior's finding B is a player who could not KNOW
where safety begins — he ran home scared with a full stash because
nothing in the world marks the sanctuary edge. Today that sanctuary is
real but an **accident of data**, not a law:

1. **No hostile can currently exist inside any hub.** All three
   `hub: true` zones ship `enemy_spawns: {}` (camp, nest, zone_7 —
   checked all 13 zone files; only district/district_two/dungeon_1/
   gate_fixture/low_quay carry spawns). `World#seed_humans` seeds
   strictly from that key (world.rb:1195).
2. **Humans never cross transitions.** `check_transition`
   (world.rb:1043) fires for `controlled_bodies` only; the whole J7-B
   catch-up law exists because displaced humans walk home WITHIN their
   zone. No pursuit into camp is possible.
3. **`hub` is an anchor flag, not a sanctuary flag.** Since v12
   (`36d2b6f`): hub zones re-home wipe respawn + vat regrowth
   (world.rb:1157). `safe` is a genuinely independent axis — which is
   why the ratified coverage (camp + zone_7) differs from the
   `hub: true` set (nest stays unsafe: ZONE 1 is wilderness spawn
   ground carrying the anchor flag, not a settlement; the radial
   gradient touchstone puts safety at depot/settlement tiles).
4. **Acquisition and verbs live at TWO sites.** Hostile target
   selection is `AiController#select_target` (controllers.rb:106-135:
   taunt→anchor→hate→lowhp→sticky/proximity→nearest, aggro radius at
   :114), invoked from `World#assign_human_focus` (world.rb:697-715),
   which emits `:human_retargeted` + retarget cues and sets `h.focus`
   in the World tick. `AiController#tick_human` (controllers.rb:196)
   only CONSUMES focus: verbs (engage/pressure) when focus is live,
   leash walk-home otherwise. Humans branch out of `#tick` at :139 —
   the `bound || marked || nearest` chain at :161 is the PACK-ALLY
   branch, not the human path. Chanting is world-driven and needs an
   acquired target first; volleys are zone-local — no damage source
   exists that does not start from an acquired focus.
5. **Soak "camp fights=4" is a session-global counter, not in-camp
   combat.** `Telemetry` counts fights wherever they happen
   (telemetry.rb:33) and prints once per session (d1_fired,
   telemetry.rb:301-305); a camp-anchored episode's fights occur in
   adjacent zones the bot roams into. `soak/chain_check.rb` already
   exempts hubs from the combat requirement (hub-set derivation ~:21-27,
   enforcement ~:113).
6. **Strict-refusal precedent exists at zone load**: seal gating (s34,
   `abe04d6`) refuses NAMED at zone load. The tile registry
   cross-checks at load (world.rb:1164+). TileMap exposes zone
   attributes via `cfg.fetch(:hub, false)`-style reads
   (tile_map.rb:17,39).

So B1 is **invariant promotion**: take the sanctuary that exists by
accident, write it into law (data + refusal + runtime guard), and make
it VISIBLE. The alternative — visual marking with no law — paints
"SAFE" over a coincidence that the already-ratified v19 lanes
(tile-gated spawns are named SIM-CLASS candidates; TOWN 1 grows;
C2 retunes ally/threat AI) could silently falsify.

## Decisions

**D1 — data shape.** `"safe": true` lands top-level in
`data/zones/camp.json` + `data/zones/zone_7.json` (sibling of `hub`,
per the letter). `Core::TileMap` gains a `safe` reader,
`cfg.fetch(:safe, false)`, mirroring `hub`'s plumbing exactly. Nest
does NOT get the key — the coverage list is the ratified letter;
extending it is one data line + capture on a future owner word.

**D2 — the load invariant (the law's teeth).** A zone declaring
`safe: true` with non-empty `enemy_spawns` REFUSES NAMED at TileMap
construction (message names the zone + both keys). Precedent: seal
gating s34. This is the piece that protects the sanctuary from the
future: a tile-gated spawn table or TOWN 1 growth pass that touches a
safe zone collides LOUDLY at boot instead of silently shipping combat
into a marked sanctuary. Core-level (tile_map.rb), zero world.rb cost.
D2 is spec-level machinery derived from grill findings 1/2/6, not
ratified letter — it enforces the ratified behavior, never alters it.

**D3 — the runtime guard (the ratified verbs).** The guard lands at
the ACQUISITION site: `World#assign_human_focus` skips
`select_target` for every human while the active zone is safe and
nils any live focus (the nil assignment emits nothing — the retarget
emit fires only on a live target; law comment cites the foundation
row). With focus nil, `tick_human` falls through to its
leash/walk-home branch — so a hostile placed in a safe zone never
pursues and never damages, but still WALKS HOME if displaced (the
dispersed-not-invulnerable read stays honest; no frozen-AI artifact).
`controllers.rb` is expected UNTOUCHED — if the build finds a verb
path that runs without focus, that's a spec defect: reopen here, don't
patch ad-hoc. The owners ratified the BEHAVIOR ("enemies never
pursue/damage inside"), not just a data shape: runtime placement
mechanisms (waves, events, future C2 work) never pass the load-time
check, and this guard makes the ratified sentence unconditionally
true. Honestly testable without mocks: `add_human` (the world's own
seeding verb) can place a hostile in camp inside a real World.

**D4 — what is deliberately NOT built (non-goals, recorded):**
- No pack-side attack refusal in safe zones — no target can exist
  there today (findings 1+2 + D2), and a guard nothing can exercise is
  dead code. Tibia PZ blocks both directions, but its PZs contain
  attackable entities; ours cannot. The PvP combat-lock half is the
  foundation's own recorded >2-players deferral.
- No new balance values, no knob moves — B1 carries zero numbers in
  `data/balance/`. (Display constants in `display.json` are display
  vocabulary, not balance — existing house split.)
- No DIGEST_VERSION bump, no save schema change — `safe` is static
  zone data with zero per-tick state; the v17 build-identity
  fingerprint already covers `data/` divergence between seats. Recorded
  explicitly because J7-B's 2→3 bump is fresh precedent — do not
  cargo-cult one here.
- No region-scoped safety (safe REGIONS inside a bigger zone). The
  ratified shape is a zone attribute; region-grade safety is a future
  TOWN 1/WB question and would ride the region layer, not this ticket.

**D5 — the visible boundary (Rule 2 surface), two pieces:**
- **Threshold marking at doors, derived from DESTINATION safety.**
  Transitions carry `to:` — the renderer can mark any transition tile
  whose destination zone is safe (the "reach that door = safety" read
  from the DANGEROUS side — finding B's actual need), and mark
  safe-zone transition tiles leading to unsafe zones with the inverse
  cue (the "beyond this = danger" read from inside). Threshold
  treatment parameters (rgb/alpha, any pulse) live in `display.json`.
  Inventory today (s61 ground truth — build session re-reads the live
  transition tables): camp has 2 door tiles ([0,5]→district,
  [19,5]→district_two); zone_7 has 4 ([33,14]→dungeon_1 sealed hole,
  [26,3]/[35,3]→basements, [1,14]→low_quay). Thresholds INTO safety
  from the unsafe side: district_two [0,13] (FREE) · district [42,13]
  (SEALED behind the toll seal at [41,13]) · low_quay [44,19] (the
  ratified join). The T2 script's fresh-save round-trip must ride the
  FREE east loop (camp→district_two→camp); the district-side sealed
  threshold is gate-refused on a fresh save. The prose list above is
  NOT exhaustive — the basement/dungeon returns into zone_7 are also
  thresholds into safety (fresh-eyes nit-2); the marking rule is
  destination-derived, so the build derives the set from the live
  transition tables, never from this list.
- **Persistent SAFE chip while inside.** The zone banner is transient
  (`zone_banner_frames`), so it cannot carry a STATE — Tibia's PZ icon
  touchstone is a persistent indicator. A small text chip in the
  existing overlay vocabulary renders whenever the active zone is
  safe. Strings (functional dictionary words, locale files ×3):
  en `SAFE` · es `SEGURO` · pt-br `SEGURO` — final wording passes the
  human-facing-output check at build time; placement/font/alpha keys
  in `display.json` beside the overlay family.

**D6 — importer passthrough.** `tools/import_ldtk.rb` must not DROP
`safe` on a future zone_7 re-export: T1 verifies whether top-level
flags like `hub` survive the importer round-trip and adds `safe`
passthrough if missing (bounded: read the importer once; if flags are
wire-in-by-hand territory, record that in the ticket receipt and add
nothing).

## Tickets (one session each; spec is disposable once these exist)

### B1-T1 — the law: data + refusal + guard  [BLOCKED until the s59
J7-B staged commits push — touches world.rb]

- Files: `src/core/tile_map.rb` (safe reader + D2 refusal) ·
  `src/game/world.rb` (D3 guard in `assign_human_focus` — expected
  ~+4-6 lines against the 1800 cap, 1770 now) · `data/zones/camp.json`
  + `data/zones/zone_7.json` (the two `"safe": true` lines) ·
  `tools/import_ldtk.rb` (D6, only if
  needed) · tests below. `src/game/controllers.rb` expected untouched
  (D3).
- Tests (minitest, real files/real World, no mocks):
  - tile_map_test: safe reader default-false; D2 refusal NAMED
    (fixture cfg with safe+spawns).
  - integration (new `test/game/safe_zone_test.rb`): `add_human` into
    camp in a real World; N ticks with the pack adjacent ⇒ zero focus
    acquisition, zero `:human_retargeted`, zero telegraphs, zero pack
    damage; a displaced safe-zone human still leash-walks home (the
    deliberately preserved branch); same human in district acquires
    normally (the guard is zone-scoped, not global).
  - data pin: camp + zone_7 declare safe; nest does NOT (pins the
    ratified coverage list against drift).
- Verify: `bundle exec rake` green via hooks. Identity pairs (s58
  protocol, runnable): `rake capture SCRIPT=harness/scripts/<each>.json`
  at the pre-edit commit into a baseline dir vs post-edit re-capture,
  md5 per stream (`rake capture` writes no gate-verdict log) —
  pre-declare ZERO movement (no renderer change, shipped-data behavior
  delta = none by findings 1+2) — ALL pairs byte-identical expected,
  whatever count the wall directory holds that day; any mover = stop
  and explain before shipping.
- Done: suite green + pairs clean + one-concern commit with explicit
  paths.

### B1-T2 — the boundary: renderer + strings + wall  [after T1; ALSO
BLOCKED until the s59 J7-B staged commits push — touches
harness/gate_checks.json and appends to drafts/_gate-verdicts.log,
both in the staged set]

- Files: `src/app/renderer.rb` (threshold treatment + SAFE chip) ·
  `data/display.json` (threshold + chip keys) ·
  `data/strings/{en,es,pt-br}.json` (`safe.chip`) · NEW
  `harness/scripts/safe_boundary.json` (start camp: chip visible →
  east door to district_two → the safe-side threshold [0,13] reads
  from the unsafe side → free return to camp — the east loop, per D5's
  seal note) ·
  `harness/gate_checks.json` (+`safe_boundary_reads` row, honest
  "not exercised" clause per house style).
- Gates: `rake gate SCRIPT=harness/scripts/safe_boundary.json`
  critic-ON + manifest rows · FULL wall sweep DETACHED (never under a
  bash-call timeout; code frozen during the sweep; wall count = the
  directory's count that day — do not hardcode 26/27 here, the varekka
  re-cut may land first) · human-facing-output pass on the three
  strings · Rule 2 is blocking.
- world.rb expected UNTOUCHED in T2; if any world read is missing,
  that's a T1 defect — reopen T1, don't leak sim edits into the
  visual ticket.
- Done: gate green + wall green + strings pass + one-concern commit.

### B1-T3 — feel: captures + owner playtest  [lane-close gate,
owner-paced — never nag]

- Assemble the capture set from T2's gate artifacts + one flywheel
  clip (`harness/make_clip.sh harness/scripts/safe_boundary.json`);
  camp AND zone_7 both shown (zone_7's chip/thresholds can co-verify
  during the pending SHARED-save crossing if that lands first).
- Queue the playtest ask in the owner-pending carry (the foundation's
  own "own capture + playtest before ship" clause). Explicit
  dev-of-record reading of that clause (fresh-eyes s61, nit-3): T1/T2
  merge on green gates (gates decide); the B1 LANE closes only on the
  playtest word (owners decide feel) — consistent with never gating
  development on peer availability; owners can override the reading in
  one line.
- Done: captures banked in drafts/ + checkpoint row flips B1 to
  awaiting-playtest.

## T1 build reopen (s71, 2026-08-25 — D3's own clause exercised)

D3 predicted `controllers.rb` untouched and said: "if the build finds a
verb path that runs without focus, that's a spec defect: reopen here,
don't patch ad-hoc." The build found one — in world.rb, not
controllers.rb: **chant-start runs without focus.** Grill finding 4's
sentence "Chanting is world-driven and needs an acquired target first"
is wrong for the START of the chant: `World#tick_challengers` gates
chant-start on cooldown/idle/range only and pins the nearest CONTROLLED
body directly (`start_chant!`), never reading `focus`. A challenger
placed in a sanctuary would chant and seize with the D3 guard fully in
place.

Resolution (dev-of-record, ratified-letter-neutral): chant-start IS an
acquisition verb — it pins a body the way `select_target` pins a focus
— so the sanctuary refusal covers it explicitly: one guard line in
`tick_challengers` (`next if map.safe`, placed at the chant-START
branch only — cooldown ticking and in-flight chant machinery untouched;
no in-flight chant can exist in a safe active zone since humans never
cross and `enter_zone` aborts all chants). The ratified sentence
("enemies never pursue/damage inside") is unchanged — this is D2-grade
machinery that makes it unconditionally true. Pinned by
`safe_zone_test.rb` (camp challenger: zero chant/seize events; district
control: chants normally). controllers.rb remains untouched, as D3
expected.

T1 custody receipt (D6 answered): `safe` is LEVEL-FIELD custody in the
authoring project (the hub precedent, uid 203), never sidecar — the
sidecar refuses unknown keys by design (presentation/tuning only). The
importer passes it through and emits it directly after `hub`;
`import -> emit` stays a byte-stable fixpoint (pilot provenance pin
green). camp.json is hand-custody, edited directly.

## Sequencing

- T1 AND T2 unblock the moment the s59 ratify-push lands (same-day
  law); T2 additionally waits for T1.
- B1 carries no knob moves ⇒ the ONE-knob-per-re-session law is not
  triggered; still lands BEFORE the v19 ritual stages per the lane's
  sequencing law (the ritual re-freezes what it measures).
- No coordination hazard with the varekka re-cut lane (disjoint files)
  except the WALL COUNT — whichever ticket runs the full wall second
  simply sweeps whatever the directory holds.
