# v14 — LEGIBILITY/ONBOARDING: controls overlay + respawn telegraph + the First Vigil

Scope authority: CLAUDE.md scope contract (debate closed 2026-08-14, owner
accepted both dev recommendations via AskUserQuestion). Approved plan:
`~/.claude/plans/groovy-whistling-spring.md`; blueprint details:
`drafts/_v14-blueprint-notes.md`. Oracle: the TWELFTH blind ask — **did the
whirlwind FIRE and land as payoff** (B's first real verdict) **+ did spawns
stop feeling sudden**.

**Governance note:** unlike v13, ALL FOUR v14 forks were closed by the OWNER
directly (AskUserQuestion, 2026-08-14, each on dev recommendation) — no
delegated closures this cycle. The owner still ratifies the check #19/#42
wording amendments at the twelfth debrief (c361ba3 precedent).

## Why this is the increment

Eleventh verify: v13 WON ("Oportunidad para cobrar", third consecutive
headline) carried by the challenge ALONE — **the whirlwind never fired,
casts=0 in both sessions**. The build's strongest new tool was invisible.
Owner verbatim: *"necesitamos tener los controles en pantalla o algo así, si
no no me doy cuenta que hay habilidades nuevas"*. Q7 free-text named the
second wound: respawns land *"repentino y brusco"* — the player can't plan
around them. v14 ships NO new mechanics: it makes the existing game readable
(controls strip), plannable (respawn tell), and named from inside the fiction
(the pre-registered v12-annex rename batch). One presentation increment,
three owner-named pieces, ONE comparability reset (full 14-script wall
re-run). **Difficulty stays pinned — by construction, not by promise** (see
Sim spec 1: materialize tick unchanged, defer laws unchanged).

## Scope (one increment + two lanes)

IN: (a) on-screen controls overlay (persistent quiet strip + first-possession
pulse); (b) respawn telegraph on the HUMAN respawn path (growing ground mark,
~2s lead, tile pinned at tell time); (c) rename batch FULL (The Nest→The
First Vigil, District One→The Longrow, wipe line→"THE FLESH IS SPENT");
lane (d) drift instrument companion `span_thirds` + its missing tests;
lane (e) regrow-cadence investigation — **DOC ONLY**
(`drafts/_v14-regrow-cadence-investigation.md`), no numeric ship; v14
telemetry block (`telegraphs_shown`, `first_special_frame` per kit).

OUT (recorded in PARKING_LOT): zone 3 beyond the stair (v15 LEAD);
multiplayer spike etapa 1 (right after v14); the Challenger (FIFTH decline,
owner-only call); dossier legs A/C/E; any balance change (regrow dose is a
recorded negative result — the cadence lane is analysis, not numbers); pack
respawn telegraph (the wipe veil IS the pack's telegraph); movement keys on
the overlay (WASD/arrows are genre-literate; the strip teaches the six
actions); everything long-parked.

## Design forks — CLOSED BY OWNER (AskUserQuestion 2026-08-14, all on dev rec)

1. **Overlay = persistent quiet strip + one-time first-possession pulse** per
   body kind per session. The pulse SHIPS now (not deferred).
2. **Strip text = vessel canon name + key:verb lowercase pairs.** Vessel
   names from the bible annex: striker=**ithet**, blocker=**goret**,
   lobber=**hevet** (canon — identical across locales). Verbs are
   DESCRIPTORS, not names (de-slop legal: specials stay nameless; "spin/
   shout/lob" describe what the button does). Bible ability names can swap
   in later via locale files alone — zero code.
3. **Telegraph = growing ground mark**, ~2s lead (`telegraph_frames: 120`),
   tile pinned at tell time, **materialize tick UNCHANGED**.
4. **Rename batch = FULL** — the v12 fiction annex pre-registration ships
   verbatim (2026-08-13-v12-arc-purpose-design.md:425-431): The Nest→"The
   First Vigil", District One→"The Longrow" (Silovun's outer ward: one long
   processional row), wipe "THE HUNT ENDS"→"THE FLESH IS SPENT" (judgment
   register). Internal identifiers (zone key `nest`, `HOME_ZONE`,
   `:nest_respawn`, script names, `test/game/*` names) STAY — display
   strings only.

### Watched risks (pre-registered)

- **W1 — staged-beat desync (TOP WALL RISK).** The telegraph pins tiles 120f
  earlier AND moves scatter consumption to a dedicated RNG stream (Sim spec
  2). Consequence, stated honestly: **v13 replay scripts diverge wherever a
  kill happens** — respawn placement shifts (inherent: the tell must be
  true) and drop-roll values shift (the global stream no longer interleaves
  scatter picks). Drop tables are [1,1,2] so amounts move by small deltas,
  but seal/tribute beats that depend on exact banked totals can miss.
  Budget: 2-5 re-pilots; splice law (capture-frame edits only; ANY input
  edit = full re-pilot); recipes in `drafts/_v13-wall-log.md`.
- **W2 — overlay collides with the vision critic's HUD priors.** Every one
  of the 14 scripts' captures now carries a new bottom strip. Check #19
  (`carried_count_reads`: "appears nowhere else on the HUD") would read the
  strip as a violation → amended with a carve-out parenthetical (never
  weakened: the layout-shift clause and the HUD-bar-area assertion stand).
- **W3 — a deferred tell reads as a bug.** Materialize-time defer keeps the
  tell alive at full intensity with no human (honest: standing near a tell
  delays it — today's law re-pinned). Check #46's wording pre-empts this:
  full-intensity persistence while the player stands near is deferral, not
  a defect.
- **W4 — discovery may still not fire.** The strip TELLS the owner L/E
  exists; it cannot make the whirlwind land as payoff. If the twelfth reads
  "I saw it, cast it, and shrugged", that is B's REAL verdict (design), not
  presentation — the placement fork (v13 fork 2, dash mourning) re-opens at
  v15 with `whirl.hits` in hand. Pre-registered in routing Q1.
- **W5 — tell suppression bound (Codex fold, Q3).** Today's law already
  lets a player suppress a respawn indefinitely by covering the anchor's
  scatter tiles (defer-recompute retries forever while covered — see
  density_respawn_test defer cases); but today's recompute can ESCAPE to a
  re-formed anchor elsewhere, while a pinned tile never re-rolls — pure
  pinning would hand the player permanent single-spawn suppression. Fold:
  a materialize-deferred tell holds at full intensity for at most
  `telegraph_defer_unpin_frames` (240 = 2× the lead; NEW threat.json key —
  a deliberate addition beyond the plan's single-key claim, recorded
  here); past the bound the record UNPINS and falls back to today's
  recompute path (no tell — the pre-v14 baseline the owner already plays).
  Caps the divergence-from-today at 4 s of visible, player-caused holding.
  If the twelfth reads a vanished tell as a bug, the bound is the lever
  (data-only).

## Sim spec (all numbers in data/; zero balance constants in Ruby)

### 1. Respawn telegraph — split-phase release (world.rb, +~50 lines)

Today (v13): `respawn_due_humans` (world.rb:995, called at tick_world:441)
chooses the landing tile AT RELEASE via `respawn_target` (world.rb:1169) —
anchor cascade (pocket→seed→home) + `scatter_pick` — then defers while the
chosen tile is occupied / within `respawn_block_tiles` 12 of a pack body /
within `corpse_guard_tiles` 10 of a live load, RECOMPUTING next tick. The
spawn is invisible until the body exists — the "repentino" the owner named.

v14 splits the release into TELL and MATERIALIZE:

- **`telegraph_due_humans`** — new private method, called in `tick_world`
  immediately BEFORE `respawn_due_humans`. For each record in
  `@human_respawns[@zone_name]` that is unpinned AND inside the tell window
  (`at_frame − telegraph_frames ≤ frame < at_frame`): run TODAY'S EXACT
  cascade + defer rules (`respawn_target` + occupied/block/guard checks,
  same predicates, same order). Eligible → stamp `pinned_tile`/
  `pinned_anchor` into the record and emit **`:respawn_telegraphed`**
  {tile, kit_name, at_frame} (registered in `World::EVENTS`). Blocked →
  stay unpinned, retry next tick (pin-time deferral = today's release-time
  deferral, shifted 120f earlier). Already-pinned tiles of sibling records
  count as occupied at pin time — two tells can never share a tile.
- **`respawn_due_humans`** — for due records (`at_frame ≤ frame`):
  - **pinned**: re-run today's occupied/block/guard checks ON THE PINNED
    TILE. Clear → `add_human` there, emit `:human_respawned` with the
    pinned anchor. Blocked → defer, **tell persists** (frames_left clamps
    at 0 — full intensity holds until the tile clears) — bounded by W5:
    a record deferred past `telegraph_defer_unpin_frames` UNPINS (tell
    disappears) and takes the unpinned path below from then on. The tile
    never re-rolls WHILE told: a moving tell is a lie.
  - **unpinned** (veil resume; a pin that deferred through its whole
    window; or a W5 unpin): TODAY'S SEMANTICS — same code path as v13's
    release (choose at release, recompute on defer, no tell, materialize
    the tick a pick clears). "Semantics", not bytes: tile VALUES ride the
    new respawn stream (W1 owns that shift). This is what makes the
    `nest_respawn` veil interplay a non-event: tick_world doesn't run
    during the veil, so records whose window passed materialize on resume
    through the same path v13 used.
- **`respawn_tells`** — new public accessor (renderer/tests):
  `[{tile:, kit_name:, frames_left: max(at_frame − frame, 0), total:
  telegraph_frames}]` over pinned records of the current zone. Per-zone by
  construction (`@human_respawns` is zone-keyed); the renderer only ever
  sees the zone it draws. **Non-autovivifying read (Codex fold):**
  `@human_respawns` has a default-proc — the accessor uses
  `fetch(@zone_name) { [] }`, or the draw path inserts keys into sim
  state (the exact `corpse_loads` pure-reader law, world.rb:92).
- **Difficulty pinned by construction:** `at_frame` never changes;
  defer predicates are today's, evaluated at the same moments plus once
  more at pin time; spawn cadence, kit, and count are untouched. The only
  behavioral deltas are (i) the tile is chosen 120f earlier (field state
  2s younger when the anchor is computed) and (ii) a pinned tile no longer
  re-rolls on materialize-defer — both fairness-neutral, both required for
  the tell to be honest.
- `data/balance/threat.json` += `"telegraph_frames": 120` and
  `"telegraph_defer_unpin_frames": 240` (W5 bound). Law check: every
  human kit's `respawn_frames` is 300 > 120 (rusher/rusher_hater/husk,
  combat.json:131/150/170 — Codex-verified), so no record is born inside
  its own tell window in normal flow.

### 2. RNG stream isolation (VERIFIED REQUIRED at exploration)

`scatter_pick` (world.rb:1224-1235) consumes **`@rng` — the world-global
stream shared with `spawn_drop`'s drop rolls** (world.rb:687). Moving
consumption 120f earlier on the shared stream would re-interleave every
drop roll after the first respawn. Fix: respawns get their own derived
stream — `@respawn_rng = Random.new(seed ^ RESPAWN_STREAM_SALT)` (a fixed
salt constant; determinism plumbing, not balance) — and `scatter_pick`
(whose ONLY caller is `respawn_target`) draws from it. The stale comment on
`scatter_pick` ("moving it would shift the drop-roll stream") is rewritten:
that coupling is exactly what this severs. Replays stay fully deterministic
(same seed → same both streams). Honest cost recorded as W1: the @rng
drop-roll sequence still shifts vs v13 replays (scatter draws no longer
interleave), so old-script drop AMOUNTS move.

### 3. First-possession tracking (cosmetic sim state — determinism law)

The plan sketched pulse state living in the overlay ("render-only state").
**Deviation, reasoned:** Gosu draw calls are NOT tick-locked (draws can be
skipped under load; `Gosu.render` capture draws interleave with window
draws), so accumulating pulse state at draw time can differ between the two
gate replays → md5 mismatch → Rule 2 determinism failure. The state moves
sim-side as COSMETIC state the sim never reads (the `@taunt_pulses`
precedent): World gains `@kit_first_possessed = {kit_name => frame}`,
seeded with the initial kit at frame 0 and updated by a
`:possession_changed` self-subscription in `wire_events`
(`@kit_first_possessed[e[:to].kit_name] ||= @frame` — covers voluntary
swaps, forced death-swaps, and judgment snaps; first time per kind only).
Public reader `kit_first_possessed`. The overlay derives pulse alpha as a
pure function of `world.frame − world.kit_first_possessed[kit]` — bit-equal
across replays.

### 4. Rename batch (data-only, ~9 strings)

- `data/zones/nest.json` `display_name` → `"The First Vigil"`.
- `data/zones/district.json` `display_name` → `"The Longrow"`.
- `data/strings/en.json`: `wipe.line` → `"THE FLESH IS SPENT"`; add
  `zone.nest.display_name` = "The First Vigil" and
  `zone.district.display_name` = "The Longrow" (en overrides for
  consistency — the other three zones keep riding their JSON fallbacks).
- `data/strings/es.json`: `zone.nest` → "La Primera Vigilia";
  `zone.district` → "El Corredor"; `wipe.line` → "LA CARNE SE AGOTA"
  (owner ES pass at the twelfth debrief).
- `data/strings/pt-br.json`: `zone.nest` → "A Primeira Vigília";
  `zone.district` → "O Corredor"; `wipe.line` → "A CARNE SE ESGOTA"
  (Junior PT-BR pass later).
- Internal identifiers unchanged (fork 4). The renderer's bare-construct
  fallback literal in `draw_wipe_overlay` updates to the new line in the
  same commit (it must match en.json byte-for-byte — fallback law).

### 5. Drift companion — `span_thirds` (lane d; telemetry-only)

Planning verdict (recorded): the drift instrument's arithmetic is CORRECT —
the eleventh's all-k3 bucketing was session-shape sensitivity (a long
pre-combat/idle head compresses all kills into the last third of the
SESSION denominator). Companion metric: bucket the same `@kill_frames` over
the **first-kill→last-kill span**. Emitted ALONGSIDE the legacy segment
(comparability both directions; legacy field never moves):

```
TELEMETRY drift thirds{k1=N k2=N k3=N} pockets{p1=F p2=F p3=F}
          span_thirds{k1=N k2=N k3=N span=N}
```

(one line; `span` = last_kill_frame − first_kill_frame + 1; zero kills →
all-zero + span=0; single kill → k1=1, span=1). Tests pinned (TDD 2):
clustered-in-one-third, idle tail, pre-combat phase, single kill, zero
kills. No ratification needed — telemetry-only.

### 6. v14 telemetry block

- `telegraphs_shown` — subscribe `:respawn_telegraphed`, count.
- `first_special_frame` per kit — subscribe the EXISTING `:special_started`
  (payload `attacker:`; verified — v13's whirl counter already consumes
  it); record `@world.frame` first time per PACK kit (`attacker.faction ==
  :pack` guard so no future human special pollutes it). Discovery
  arbitration for the twelfth: overlay → earlier first casts vs v13
  baselines (whirl casts=0 = no baseline; any finite frame is a win).
- Summary line, format pinned (always prints):

```
TELEMETRY v14 telegraphs_shown=N first_special{striker=F blocker=F lobber=F}
```

(F = the sim frame of the kit's first cast, or the literal `never` when
that kit never cast — **Codex fold: a `0` sentinel collides with a
frame-0 cast** since World starts at frame 0; the existing
`arc.first_frame=0` sentinel carries the same latent collision and is
left as-is for cross-session comparability, but the NEW line doesn't
inherit the defect.)

### Perf

Telegraph: one extra pass over the zone's pending respawn records per tick
(list length ≤ humans killed and unrespawned — single digits) + the same
cascade work today's release does, run once per record either way (at pin
instead of at release; deferred pins retry like deferred releases always
did). Overlay: screen-space rect + ~7 short text draws per frame. Tells:
≤ pocket_cap 6 simultaneous ground marks. No new per-tick O(n²). Budget
unchanged: p95 < 16.6 ms (v13 baseline 0.252 ms).

## Presentation spec (Rule 2 surface)

### 1. Controls overlay — new `src/app/controls_overlay.rb` (~90 lines)

- **`App::ControlsOverlay`**, injected `display:`/`strings:` (Renderer
  pattern). Constructed BY Renderer (`renderer.rb` gains the require, one
  construct in `initialize`, one `@controls_overlay.draw(world)` call —
  the fight_ledger extraction precedent; window.rb untouched at 72 lines).
- **Strip:** full-width dark backing at the bottom edge
  (y = `view_height − overlay_strip_height`), subdued alpha
  (`overlay_strip_alpha` 140); content line: possessed vessel's canon name
  + six `key:verb` pairs in binding order:
  `ithet   J attack   K dodge   L spin   ; mark   H interact   Tab swap`
  (vessel name in the kit's body color, key glyphs bright, labels bone-
  subdued — reference UI, quieter than HP bars and ledger beats).
- **Key glyphs = static frozen map of PRIMARY bindings**
  ({attack:"J", dodge:"K", special:"L", mark:";", interact:"H",
  swap:"Tab"}) — matches `Window::BINDINGS` (window.rb:19-30) first
  entries; no reverse-lookup machinery (the map is 6 constants; if
  bindings ever become configurable, THAT increment builds the lookup).
- **Content updates on possession swap** — kit read from
  `world.possessed.kit_name` every draw; dead-possessed edge: the
  possessed reference always exists (forced swap/wipe handles death), so
  the strip always has a kit to describe.
- **First-possession pulse:** strip backing (and text) alpha lifts to
  `overlay_pulse_alpha` (230) and decays linearly back to resting over
  `overlay_pulse_frames` (45), driven by
  `world.frame − world.kit_first_possessed[kit]` (Sim spec 3 — pure
  function of sim state). Fires once per body KIND per session, including
  the initial body at frame 0 (deliberate: the session's first frames
  teach the first kit).
- **Draw order/z (deviation from the plan's "z≈18", reasoned):** the wipe
  veil draws at Gosu default z=0, so any z>0 text would poke through it
  (Gosu z-sorts stable, ties resolve by call order — DrawOpQueue
  stable_sort, Codex-verified in the gem source). The strip draws
  screen-space AFTER the translate block, inserted in `Renderer#draw`
  between `draw_hud` and `draw_edge_pips`, all primitives at default z
  (text passes z=0) — call order puts it above the world, under the
  veils, and the ledger beats (z=29-31) stay above everything. Blueprint
  beat 11 (veil over strip) comes free. **Edge pips draw AFTER the strip
  ON PURPOSE (Codex fold):** their bottom clamp (view_h−16) lands inside
  the strip band; drawn after, an off-screen ally's kit-colored pip stays
  visible ON the dark strip — ally state is never invisible (edge-pip
  law).
- **i18n law:** ALL player-visible overlay text lives in
  `data/strings/{en,es,pt-br}.json` — NOT display.json. Keys ×3 locales:
  - `overlay.vessel.{striker,blocker,lobber}` = ithet/goret/hevet
    (identical ×3 — canon names don't translate).
  - `overlay.{attack,dodge,mark,interact,swap}` = en attack/dodge/mark/
    interact/swap · es ataque/esquiva/marca/interactuar/cambio · pt-br
    ataque/esquiva/marca/interagir/trocar.
  - `overlay.verb.{striker,blocker,lobber}` = en spin/shout/lob · es
    girar/gritar/lanzar · pt-br girar/gritar/arremessar. (The special
    slot always shows the possessed kit's verb — no generic
    `overlay.special` key; dead data doesn't ship.)
  - Inline EN fallbacks in the overlay code keep a bare strings-less
    construct drawable (the `draw_wipe_overlay` precedent).
- **Layout numbers in `data/display.json`:** `overlay_strip_height` 28,
  `overlay_strip_alpha` 140, `overlay_font_size` 12, `overlay_y_pad` 6,
  `overlay_x_start` 32, `overlay_glyph_gap` 8, `overlay_section_gap` 20,
  `overlay_pulse_frames` 45, `overlay_pulse_alpha` 230.
- **Testability:** content resolution (`vessel name`, `pairs`, pulse
  alpha) is exposed as pure methods the test drives headlessly; `#draw`
  is the only Gosu-touching method; fonts memoize lazily so tests that
  never draw construct none.

### 2. Respawn tell — `Renderer#draw_respawn_tells` (+~25 lines)

- World-space, inside the translate block, inserted after
  `draw_expiry_flashes` and before the creature draw loops (ground marks
  sit UNDER bodies — a materializing human lands ON its tell).
- Reads `world.respawn_tells`. Progress = `1 − frames_left/total`. The
  mark GROWS + brightens: thin hollow outline (edge color) whose inner
  fill square scales with progress from ~4px to tile−8px; alpha ramps to
  `respawn_tell_max_alpha` with a subtle deterministic pulse
  (`frames_left × respawn_tell_pulse_speed` modulated — pure function of
  sim state, no wall-clock). At frames_left 0 (deferred materialize) the
  tell holds at full intensity — W3's honest persistence.
- **Palette: pale green-white family** — `respawn_tell_edge_rgb`
  [180,220,200], `respawn_tell_core_rgb` [220,240,230],
  `respawn_tell_max_alpha` 180, `respawn_tell_pulse_speed` 3 (all NEW
  display.json keys). Distinctness audit against every ground/overlay
  element it can co-occur with: volley brackets (orange, shrinking core),
  human attack telegraph (red edge/yellow core, ON a body), gate gold
  (solid, static), taunt pulse (rust, expanding outline), drops (magenta/
  rose/ember, filled), corpse pip (magenta hollow outline), expiry flash
  (dark), station cue (bright white-green ring, 1-frame-family pulse at a
  FIXTURE — the tell grows over 120f on open floor; the family overlap is
  accepted and the new script shows both in one shot for the critic).
- Zero sim reads from the renderer (pure-reader law); zero balance reads
  (frames_left/total ride the accessor like decay_frames ride drops).

### 3. Renames on camera

Zone banners render "The First Vigil" / "The Longrow" via the EXISTING
banner path (zone JSON display_name + en overrides); the wipe line renders
"THE FLESH IS SPENT" via the existing `tr("wipe.line", …)`. No new draw
code. Gate captures change text in EVERY script that shows a banner or a
wipe — absorbed by the one comparability reset (the wall re-run this spec
rides).

## Harness + gates

- **New script: `harness/scripts/respawn_telegraph.json`** (pilot-authored
  post-TDD; `rake pilot NAME=telegraph_v14`; ≤20 captures). Mandatory
  beats (blueprint, 12): (1) First Vigil banner + initial strip · (2)
  enter the Longrow, strip persists · (3) first kill (starts the 300f
  clock) · (4) tell appears ~kill+180, human NOT present · (5) tell grown
  · (6) materialization at the tell tile ~kill+300 · (7) multiple
  simultaneous tells · (8) tell + volley brackets same frame · (9) tell +
  human attack telegraph same frame · (10) Tab swap → strip changes +
  first-possession pulse frame · (11, optional) wipe veil over strip ·
  (12) post-wipe strip correct kit.
- **Checks 44 → 46, ADD-ONLY:**
  - **#45 `controls_overlay_reads`:** "A quiet strip at the bottom edge of
    the screen shows key glyphs paired with action labels for the
    currently possessed body. The strip updates when possession changes
    (a different vessel name/verb appears). A brief brighter pulse may
    accompany the first possession of a kind (allowed, not required).
    The strip reads as instructional reference, NOT as a combat element —
    its alpha is subdued relative to the HUD bars and the ledger tally.
    If the script never shows a living possessed body, pass with
    why='not exercised by this script'."
  - **#46 `respawn_telegraph_reads`:** "When a respawn tell is active (a
    pulsing ground indicator on a floor tile, pale green-white family),
    it reads as 'something is about to arrive HERE' — clearly distinct
    from the human attack telegraph (red-edge/yellow-core), volley impact
    brackets (orange), the gold gate tiles, and the taunt pulse (rust
    square). The tell grows or brightens over its visible lifetime and a
    human materializes at the tell tile at or after full intensity (a
    tell may legitimately HOLD at full intensity while the player stands
    near — deferral is honest waiting, not a defect). If no respawn tell
    frame is present, pass with why='not exercised by this script'."
  - **AMEND #19 `carried_count_reads`** (never weaken; owner ratifies;
    wording re-cut at the Codex fold — the draft parenthetical NARROWED
    the assertion to "the HUD bar area", which would have legalized a
    duplicate numeral in the strip): the "appears nowhere else on the
    HUD" assertion stays GLOBAL; the added parenthetical only classifies
    the strip: "(the bottom-edge controls strip shows key/action
    reference text only and is not a carried readout — a carried numeral
    appearing in the strip would still violate this check)". Layout-shift
    clause unchanged.
  - **AMEND #42 `new_ground_reads`** (rename consequence): "District One"
    → "The Longrow"; rest unchanged.
- **`world_scene.rb`** event-log list += `:respawn_telegraphed` (capture
  scripts aim at tells by frame).
- **Wall = 14 scripts** (13 existing + respawn_telegraph), FULL re-run
  (comparability reset), sequential, ONE window at a time; det+critic full
  gates (moving_square/critic_reel det-only per the v11 INFRA law); retry
  law 2 attempts INFRA-only; verdicts from `tmp/wall/*_v14_*.log` teed
  files, NEVER exit codes; `nest_advance` runs ~65 min with a long silent
  stretch (NOT frozen — do not kill).
- **Machine-checked mandatory beats (Codex fold, Q9/Q10 — structural):**
  self-gating checks are FORCED to pass when unexercised
  (vision_critic.py's self_gating set "must never decide the gate"), so
  the critic CANNOT catch a staged beat that silently died. New triage
  law: every staged script's teed log must show its mandatory EVENTS
  (per-script manifest in the wall log: vat_economy→`tribute_paid`,
  corpse_run→`corpse_looted`, ledger_loop→`banked`, aoe_specials→
  `special_started`×whirl+challenge, taunt_anchor→`taunted`, loot_loop→
  `drop_picked_up`+`banked`, threat_pull→`human_retargeted`,
  district_hunt→kills, specials_chain→`special_started`×3 kits,
  respawn_telegraph→`respawn_telegraphed`≥2 + `human_respawned`-at-tell).
  A missing staged event = semantic desync = RE-PILOT even when the
  critic passes. The dedicated respawn_telegraph gate additionally
  requires #46's verdict text to cite a VISIBLE tell (not self-gated).
- **vat_economy is a PRE-KNOWN re-pilot** (Codex catch, verified in
  tmp/wall/vat_economy_v13_a1.log: `tributes=0 banked_spent{tribute=0}`
  in BOTH gate replays — its tribute beat was already dead at v13, the
  critic self-gated past it, and the v13 wall log's "did not bite" note
  was WRONG; corrected in drafts/_v13-wall-log.md's successor). The
  regrow revert (9→12, `52314c9`) shifts its affordability again — it
  re-pilots regardless of v14's changes.
- Desync triage for the rest: W1 scripts with staged money-shots
  (aoe_specials, taunt_anchor, specials_chain, corpse_run, loot_loop,
  ledger_loop, threat_pull, district_hunt) checked beat-by-beat via the
  event manifests; splice law binds.
- Wall log SSoT: `drafts/_v14-wall-log.md` (provenance per gate). Then
  `rake perf` ALONE (p95 < 16.6 ms), then full `bundle exec rake`.
- Determinism laws re-affirmed: locale never enters the sim (harness pins
  en); the overlay reads sim state, never accumulates draw-side state
  (Sim spec 3); tells derive from the accessor, never from balance.

## TDD increments (each green + committed on `junior-tibia`; hooks run bundle exec rake)

1. **Rename batch** (data-only): zone display_names + en/es/pt-br updates
   + the wipe fallback literal. Existing strings/zone tests re-derive.
2. **Drift span_thirds + first_special_frame** + `v14_telemetry_test.rb`
   (span cases ×5 + first_special records-once + pack-faction guard).
3. **Telegraph sim**: `respawn_telegraph_test.rb` — pin fires at
   at_frame−120 + event emitted; materialize at UNCHANGED at_frame at the
   pinned tile; pin-time defer retries (blocked window start); materialize-
   time defer persists the tell (frames_left 0, tile held); **W5 unpin: a
   record deferred past telegraph_defer_unpin_frames drops its tell and
   materializes via the recompute path once clear**; accessor shape +
   non-autovivifying read (fetch law); unpinned-due records take today's
   path (veil resume law); two records never pin one tile; RNG stream
   isolation (a drop roll between pin and materialize does not move the
   pinned tile / a session with respawns keeps drop rolls off the respawn
   stream). Existing respawn tests (`density_respawn_test`,
   `threat_respawn_test`) re-derive expected tiles where the stream swap
   moves them — laws unchanged, seeds re-read.
4. **Telegraph render + v14 telemetry line**: `draw_respawn_tells` +
   display keys + `telegraphs_shown` + the pinned summary line (counters
   unit-tested; visuals gate-verified at the wall).
5. **Controls overlay**: `controls_overlay.rb` + `kit_first_possessed`
   sim-cosmetic state + strings ×3 + display keys +
   `controls_overlay_test.rb` (vessel+verb per kit ×3 kits, locale switch
   es, swap updates content, pulse once per kind incl. initial kit,
   pulse-alpha decay pure function).
6. **Harness integration**: gate_checks.json 46 + #19/#42 amendments +
   world_scene subscription. (The new script installs at the pilot step,
   before the wall.)

## Fun-verify (TWELFTH — BLIND; owner plays first, NO changelog)

Protocol unchanged (unique log per launch; harvest ALL telemetry from
`/tmp/game_two_session_<pid>.log` BEFORE any question; clean Esc flushes;
questions via AskUserQuestion in SPANISH). Preamble: "si nunca usaste algo,
decilo — esas preguntas se leen como no-ejercitado, no como negativo".
Owner may play `bin/play es` — locale never touches telemetry.

Questions (ask exactly these, in Spanish):

1. HEADLINE — discovery/payoff: this time, did you USE the striker's spin?
   When you burst a pile with it, did that land as an earned payoff — did
   the swarm become something you cash out?
2. Spawns: did enemy arrivals stop feeling sudden? Did you ever SEE a tell
   and plan around it (avoid it, camp it, retreat)?
3. The strip: did the bottom controls strip help you find your tools, or
   was it noise? Did you notice the brighter pulse on a new body?
4. The names: "The First Vigil", "The Longrow", "THE FLESH IS SPENT" — did
   the new names land? Any of them feel off?
5. Money/trips re-read: banked value — still FOR something? The trips —
   rhythm okay this time?
6. Drift re-read: did the field stay worth fighting deep into the session?
7. Fairness multi: anything unfair — respawns, camps, the tell itself?
8. Entrainment (SEVENTH read): scariest stretch — did your body react?

Routing (pre-registered):

- **Q1 = the headline half A.** `whirl.casts` + `hits` histogram arbitrate:
  casts>0 + fat 2-3+ tail + "payoff" verbal → **B VALIDATED** (v13's
  design finally judged, verdict recorded). Casts>0 + flat verbal → design
  problem, NOT presentation — placement fork re-opens at v15 (W4).
  Casts=0 AGAIN → presentation insufficient; `first_special{striker}` +
  Q3 decide whether the strip was unseen (overlay lane iterates) or seen-
  and-ignored (kit placement re-opens). This question is why v14 exists.
- **Q2 = the headline half B.** `telegraphs_shown` >0 + "planned around
  one" → telegraph VALIDATED, respawn ask closes. "Still sudden" with
  telegraphs_shown>0 → presentation dose (lead/size/palette — display
  keys, no sim change). Unfair-feeling tells (Q7 cross-read) → design
  investigation, difficulty stays pinned.
- **Q3** noise verdict → strip alpha/height dose (display keys only);
  "didn't notice the pulse" is FINE (pulse is allowed-not-required).
- **Q4** any name "off" → owner names the replacement from the bible at
  the debrief (locale files only, no wall — text-only swap rides the
  c361ba3 wording precedent... but a BANNER text change re-runs the wall:
  state it honestly at the debrief before accepting).
- **Q5** rides the reverted dose (regrow 12 restored at `52314c9`): the
  cadence lane doc (lane e) + q6_margins from THIS session feed the v15
  debate. No new dose from this answer alone.
- **Q6** → `span_thirds` curve attached to the structural decision
  REGARDLESS of the verbal answer (instrument-first law; legacy thirds
  kept for cross-session comparability).
- **Q7** camping/unfairness → named lane opens with telemetry attached;
  "nada injusto" → guard-scope stays closed-validated.
- **Q8** seventh read: body reacted → Challenger stays unpromoted (6th
  non-confirm; it remains the owner's explicit call only). Flat → the
  dossier re-weighs at v15 (presentation-complete build failing to
  entrain is the strongest evidence yet).
- **Check amendments:** owner ratifies #19 carve-out + #42 Longrow (+ the
  standing check-14 rewording) at this debrief — c361ba3 precedent.

## Deliberately absent (recorded so review doesn't re-litigate)

- **Pack/wipe respawn telegraph** — the veil + judgment IS the pack's
  respawn ceremony; only HUMAN spawns were named sudden.
- **Movement keys on the strip** — WASD/arrows are genre-literate; six
  actions are the teachable surface. Adding 4 more pairs makes the strip
  a manual, not a reference.
- **Contextual/timed hints, tutorial prompts, toggle key** — fork 1
  closed on the persistent quiet strip; a hide toggle is state the owner
  didn't ask for. Re-open only on a Q3 "noise" verdict.
- **Reverse-lookup of live bindings** — bindings are frozen constants
  (window.rb:19-30); the static glyph map is 6 entries. YAGNI until
  rebindable controls exist.
- **Telegraph on tile-recompute (re-roll at materialize-defer)** — a tell
  that JUMPS is a lie with extra steps; the pin holds (W3).
- **AI reactions to tells** (humans avoiding/defending spawn tiles) —
  sim behavior change; difficulty is pinned this cycle.
- **`overlay.special` generic string key** — dead data; the special slot
  always speaks the kit's verb.
- **Amazon Translate** — ~11 new short strings, authored (v13 precedent;
  owner authorized Translate, declined on quality).
- **Regrow-cadence NUMBERS** — the pricing dose is a recorded negative;
  lane e ships analysis for the v15 debate, not values.
- **Zone 3, multiplayer etapa 1, Challenger, dossier A/C/E** — scope
  contract OUT-list; v15 leads already named.
