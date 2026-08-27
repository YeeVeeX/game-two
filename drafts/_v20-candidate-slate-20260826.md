# v20 candidate slate — sustain-in-battle + striker identity (peer intake, 2026-08-26)

STATUS: **CANDIDATES ONLY — nothing here ships before the eighteenth's
verdict** (armed hygiene, spec §12; sim numbers + measured seams frozen).
This doc BANKS the peers' live brainstorm the evening the exposure
session landed, so the post-verdict v20 foundation grill opens loaded.
Both seats contributed with equal standing (operating model law); every
idea attributed, verbatim where it matters. Owner retention context —
the reason this slate exists (Gabriel, chat, verbatim): "I don't want
Junior or me to get bored and leave the project."

## Why this lane (evidence, from tonight's banked bytes — log #41)

- Cycle pace: `progression level=10 xp=644 kills_xp=4069` — LEVEL CAP
  reached in one evening; seal 4 breached; whole graph toured
  (catchup lines). Owner verbatim: "llegamos al final del juego muy
  rápido y hace falta contenido."
- Battle sustain: `sustain bought=0 used=0 refused=2 reasons{none=2}` —
  the shipped sustain verb went UNDISCOVERED again (R-A2's telemetry
  row measures exactly this at the ritual — no coaching before then).
- Heal geography: owner verbatims banked as HELD (skeleton): heal spots
  "muy escasos y espaciados"; the basement "depot" no-heal pocket.
- Striker feel: Gabriel: "de momento el Striker no hace nada
  impresionante". Bytes agree: `whirl{casts=18 hits{1=6 2=1 3=0 4=0
  5plus=0} kills=1}` — 18 casts, one multi-hit, one kill, all night.
  `first_special{striker=9221 blocker=2218 lobber=54887}`.

## Candidate 1 — POTIONS + INVENTORY (the headline; peer-convergent)

- Origin: Gabriel ("o potions"); Junior endorses ("más rápida y
  directa, sin modificar demasiado el juego").
- Shape: promote the parked item/equipment system with inventory +
  item drops + potions as the FIRST item class; widens the existing
  paid-consumable sustain lineage rather than replacing it.
- Touchstones: Tibia hunt-consumable economy (verified shelf:
  `crafting-loot-and-consumable-economies` — consumables burned per
  hunt, time-online as tradable good; `tibia-mechanics-…` vocation
  sustain). Witcher-3 toxicity budget = the anti-farming counterweight
  if potion variety grows.
- Fence: overlaps the shipped verb whose discoverability the ritual
  measures — design AFTER the verdict reads R-A2's row.

## Candidate 2 — STRIKER IDENTITY / GROWTH (new lane, both peers)

- Origin: Junior ("transformar al Striker en un druida que cure con
  magia AoE… no es necesario crear otro personaje"); Gabriel endorses
  the premise + asks what is planned at higher level.
- Honest state of the plan (recorded v19 design): the per-spell GROWTH
  experiment went to the LOBBER only (lobber-E mid/late bloomer);
  striker/blocker have flat integer stat growth. NOTHING
  striker-specific is scheduled — this gap is real and now named.
- Shapes for the v20 table (one gets grilled, not all):
  a. Junior's druid: striker's kit becomes melee/support hybrid with an
     AoE heal verb (active, possessed — heals as PLAYER SKILL, and in
     coop a human can pilot the healer role). Cost: the pack loses its
     pure-melee damage identity — composition debate owed.
  b. Whirl growth: extend the lobber per-spell-growth pattern to the
     striker — the whirl's radius/effect grows with level so the AoE
     actually lands multi-hit at high level (bytes above show it
     almost never does today).
  c. Hybrid a+b: high-level whirl heals allies inside its ring while
     damaging enemies — one verb, both jobs, very legible.
- Principle carried from the dev-side verdict (chat, tonight): heal
  belongs on a POSSESSABLE body as an active verb, not on a second
  autonomous AI (the third body's AI is itself an open measured
  question — v18 P3 → C2 → R-T1/R-T2 pending; companion-AI shelf gap
  recorded). Junior's "no new character" call and this principle agree.

## Candidate 3 — HEALING PILLARS / LIFE FOUNTAINS (geography sustain)

- Origin: Junior ("fuentes de vida en los mapas… Pilares de cura que
  cura a cada 30sec"), reference image supplied (banked LOCAL:
  `drafts/_refs/junior-heal-pillars-ref-20260826.png`, md5
  `9eeae681b215f65683afb9eca4e8ada1` — pixel standing stones w/ green
  rune rings; sits naturally beside the game's seal/stone visual
  language).
- Shape options, strongest → weakest against the ratified economy law
  ("never free, never regenerating" — banked value becoming hunt
  endurance IS the v18/v19 economy thesis):
  a. PRICED pillar: activate with banked value — a vat's little sibling
     placed deep (tolls the heal, keeps the sink).
  b. CONTESTED/CADENCED pillar: free but slow (Junior's 30s), placed as
     a tactical anchor — fight FOR the ground, not a free regen field.
  c. Ubiquitous free fountains — pushed back: deflates provisions AND
     death pressure (the measured difficulty object).
- Touchstones: Zelda fairy fountains (the peers' shared frame),
  MOBA fountain/shrine control as positional play; NOT a Tibia
  mechanic (Tibia sustain is consumables — candidate 1's lane).
- Also answers the banked geography pain (depot pocket, "escasos y
  espaciados") WITHOUT new systems: pillar placement is WB-pipeline
  zone authoring once the piece exists.

## Candidate 4 — PRICED AUTO-COMPANION (the fairy, kept honest)

- Origin: Gabriel (Navi/Tatl auto-heal fairy). Dev verdict (chat):
  free periodic regen contradicts the ratified sustain law; the PRICED
  version — a companion that carries charges you bought and auto-casts
  under an hp threshold — is a clean accessibility layer over the
  existing consumable economy (Zelda's real heal there is the bottled
  fairy: a consumable). Cheap tier, zero new economy.

## Candidate 5 — HUD REPOSITION + SHRINK (lower-left vitals; presentation lane)

- Origin: Gabriel (s89 chat, 2026-08-26, verbatim): "Sometimes it
  covers some important elements in the screen while playing" — asks
  for the hp bars + status block moved to the lower-left and smaller.
  Presentation/legibility complaint, NOT a ritual-topic feel statement
  (hygiene-clean to bank).
- Measured truth (live, renderer.rb `draw_hud` + safe chip): the pack
  status block owns roughly **x 30–342, y 14–116 top-left** — 3 hp
  bars (y 16+i·20, possessed w 260 / others 200, h 14), pips at fixed
  x 300/314, carried numeral x 332, LEVEL strip at `hud_level_y` 78,
  SAFE chip at y 98. Bar/pip layout is UNKEYED (hardcoded literals);
  only level strip + safe chip + down-outline carry display.json keys.
- uiux state checked (s89): **no reposition shipped or specced** —
  their `docs/specs/vitals.md` records the current top-left geometry
  as measured truth; all adoptions to date are contrast/legibility
  deltas (C1/D2/C6/N-family), never a layout move. Their R26 residual
  explicitly warns some literals cannot follow a re-layout — a
  reposition is a spec job, not a nudge.
- Design constraints already known: controls strip owns the bottom
  band (`y = view_h - h`) — lower-left placement must clear it; edge
  pips deliberately clamp into that band (uiux z-order S-05); smaller
  bars must re-clear the **3:1 non-text contrast floor over the NEW
  backgrounds** (uiux SC 1.4.11 arithmetic — the same math that
  caught the 1.04:1 down-state); quiet-HUD law (layout never shifts)
  carries to the new anchor.
- Execution shape (post-verdict): commission the uiux seat for a
  reposition+shrink spec (collision + contrast analysis — exactly
  their charter; mail vehicle) → implement with ALL layout literals
  promoted to display.json keys (data-driven layout, makes future
  moves cheap) → Rule 2 gate + **full-wall re-pin priced (~35
  scripts, ~3h detached)** + uiux mirror-refresh wave (their
  vitals/coverage pins go stale).
- Fence: player-visible ship — DISCOURAGED under the armed freeze
  (extends exposure ledger §3; both seats re-owe ordinary sessions
  before ritual s1). The verdict is the unlock; owner override =
  recorded, cost named. Folds naturally with the "looks too simple"
  presentation-lane pointer below if v20 promotes that family.

## Candidate 6 — SPELL BREADTH ("más contenido y spells")

- Origin: Gabriel (s89 chat, verbatim): "Pronto necesitamos: más
  contenido y spells".
- Shape: grow per-kit verb lists beyond the single special. The
  per-spell growth LANE already exists (lobber-E precedent); candidate
  2's shapes (b)/(c) are its striker instances — this row is the
  GENERAL ask.
- Touchstone: Tibia vocation spell ladders — spells gate by level and
  vocation, bought in town (`tibia-mechanics-lore-and-virtual-world`,
  verified 2026-04-10); composes with our live `requires_level` rungs
  + bank economy (buy spells with banked value = a new sink, the
  scale-with-faucet law applies).
- Fence: balance data frozen until the verdict. Real design cost the
  grill must price: the CONTROLS SURFACE is full — more verbs need a
  spell-select/loadout layer (input design, J-6 menu family), not just
  data rows.

## Candidate 7 — ENEMY ROSTER ("más tipos de enemies")

- Origin: Gabriel (s89 chat, verbatim): "más tipos de enemies".
- Shape: new creature KINDS with distinct behaviors (not stat reskins);
  creature-family identity per area — each biome/dungeon reads by its
  fauna.
- Touchstone: Tibia's bestiary IS its risk geography — the
  rats→rotworms→dragons ladder maps zones to threat
  (`tibia-mechanics-…` verified 2026-04-10; shelf risk-geography
  thread). Our tiers.json vocabulary is the carrier.
- Cross: J-T1 dungeon populations + BOSS 2 want exactly this; candidate
  9's biomes want fauna to read by.
- Fence: creature.rb/aggro.rb are FROZEN measured seams (C2) until the
  verdict; all shapes post-verdict, one gated piece at a time.

## Candidate 8 — MAIN CITY HUB ("un 'Thais'")

- Origin: Gabriel (s89 chat, verbatim): "un 'Thais' (una ciudad
  principal como 'hub' para los jugadores)".
- Current truth: HUB 1 + zone_7's town are hamlet-scale service stops;
  the ask is a CITY-scale anchor — services + social gravity + the
  place that feels like HOME.
- Touchstones: Tibia Thais — temple respawn + depot + shops as the
  player-gravity anchor (`tibia-mechanics-…` verified 2026-04-10);
  towns as event anchors (`world-events-towns-and-folklore-mechanics`
  verified 2026-08-16).
- Routes for the grill: grow zone_7 into the city · author CITY 1 via
  WB pipeline (T1-T5 proven) · worldsmith v2 town/city archetype (T26
  hypothesis). Placeholder law: in-game name stays generic (CITY 1 /
  TOWN 2); "Thais" lives only as touchstone citation.
- Fence: home-hub context is load-bearing (mercy floor B4 gates on
  home-hub, safe zones B1) — relocating "home" is a design decision
  the grill prices, not a map edit.
- **Macro-topology sketch (owner, s89, verbatim):** "connect our
  'Thais' to different zones per cardinal direction, for example:
  north: to Desert, South: to Mountains, East: to the final Area
  Dungeon that connects to the next city, west: starting area." Read
  as law-shaped: the city is a CARDINAL CROSSROADS; the world spine
  grows city → dungeon → next city; the existing six-zone intro arc
  anchors as the WEST/starting spoke — nothing discarded, the intro
  stays the intro.
- Dev read on the sketch (banked for the grill): (i) cardinal spokes =
  worldsmith v1's hub_spoke CLUSTER archetype with exit pins as
  generation inputs — the topology is expressible at cluster level
  TODAY; strongest capability↔demand match yet (routed to T26 §C).
  (ii) city→dungeon→city is the macro-progression skeleton: each city
  ring a difficulty band, the connecting dungeon its rung — composes
  with live `requires_level` rungs + the radial danger gradient
  (`world-events-…` verified 2026-08-16) + J-T1's ladder; Tibia
  precedent: mainland cities chained by dangerous passages.
  (iii) cardinal legibility is a navigation win — players give
  directions by compass memory; pairs with the banner/landmark
  discipline; the in-game map stays parked (E1 family).
  (iv) desert + mountains = candidate 9's first two NAMED biomes
  (cross-pinned there).

## Candidate 9 — WORLD BREADTH: biomes · sub-areas · vertical-up ("towers")

- Origin: Gabriel (s89 chat, verbatim): "more biomes/different areas,
  sub areas, top areas (towers, etc)".
- Shape, three rungs: (i) biome palettes + region identity (SAFE-class
  tile/ambience vocabulary — the WB region layer + tile-type registry
  already carry it; cheapest rung, ships freely even mid-cycle by
  standing law); (ii) sub-areas = gated pockets (the zone_8 carve
  pattern — J-T3's exact playbook); (iii) UPWARD floors (towers) — we
  have downward verticality live (basements, holes, stairs); UP should
  ride the same floor system but needs importer/renderer verification —
  a NEW axis question, routed to worldsmith T26 + WB pipeline.
- First two NAMED biomes: desert (north spoke) + mountains (south
  spoke) — the owner's s89 topology sketch (candidate 8).
- Touchstone: Tibia's seamless z-axis world (+7 above ground to -8
  below — towers, mountains, dungeons on one grid;
  `tibia-mechanics-…` verified 2026-04-10).
- Fence: SIM-class tile behaviors (lava/water/tile-gated spawns) stay
  one-gated-piece-at-a-time — now owner-re-ratified (method ruling
  below).

## s89 additions — method ruling · E1 re-grade · grill framing

- **OWNER METHOD RULING (s89, recorded, verbatim): "one at a time with
  intensive testing/debugging"** — v20 executes content SERIALLY, one
  gated increment per re-session. This owner-ratifies the standing
  ONE-knob law + Rule 2 wall for the whole content cycle. Lane order
  inside v20 = grill output; the serial method is now law regardless.
- **E1 GM-tools re-grade (owner asked "when" — s89):** stays
  VALIDATED-DEFERRED through the freeze, but the v20 grill MUST
  re-grade E1 on its merits instead of auto-deferring (owner interest
  recorded twice now). Dev posture for the grill: the OFFLINE factory
  (LDtk + strict importer + hot-reload preview + `rake map`) covers
  authoring throughput today; live in-game god-mode editing touches
  sim/save/netplay determinism (a mutating editor inside lockstep coop
  is a desync machine unless designed as its own lane) — honest
  earliest: a READ-ONLY first rung (GM map view / inspect / teleport
  family, parked siblings) as a v20 stretch rider IF the grill promotes
  it; mutating world-edit = v21-class.
- **Grill framing (dev add, s89):** the peers' banked asks (potions,
  striker, pillars, dungeons+bosses, zone_8 fill, spells, enemies,
  city, biomes, towers) make v20 unambiguously THE CONTENT CYCLE — so
  the grill's real question is FACTORY THROUGHPUT under quality gates:
  size every lane against authoring capacity (WB pipeline + worldsmith
  + serial gating), not against appetite. Cross-input: eighteenth
  verdict rows + J-T1 dossier + worldsmith T26 dossier all land before
  the grill opens.

## Non-candidates recorded from the same conversation

- Fourth pack sibling (autonomous AI healer): both the peer table
  (Junior: "no es necesario crear otro personaje") and the dev
  principle point away while the third body's verdict rows are open.
  3→4 pack size touches seats/wipe/gate co-location — if ever revived,
  it is its own foundation-level debate.
- "Game still looks too simple" (Gabriel): presentation lane pointer —
  J-5 projection spike (owner-paced), uiux critique service, assets
  integration (parked on assets pipeline maturity). v20 may promote.

## KB evidence pass (s86, 2026-08-26 — docs-only, freeze intact)

Verified-shelf pulls per candidate (`hub kb query --domain game-research`;
vault paths + `last_verified` cited). Tier vocabulary carried: **verified**
= re-fetched primary source; *synthesis/illustrative/datamine* numbers are
FLAGGED-class — they never land in `data/` without re-verification
(AGENTS.md reference-wall law). Zero code/data touched; this section is
grill input for the post-verdict v20 foundation.

### Candidate 1 — potions + inventory

- `game-research/crafting-loot-and-consumable-economies.md` (verified
  2026-08-16):
  - Framing law: items exist to create REPEAT demand — "repeat demand
    needs one of: consumption on use (potions/runes/ammo), timers, or
    degradation." Potions = consumption-on-use, the same lineage as the
    shipped provision verb — the slate's "widens, not replaces" claim is
    now shelf-backed.
  - **Verified** (Tibia rune economy): town prep time converts to field
    combat power; the note's own game-two routing says it — "let
    PREPARATION time convert to combat power, so town time feeds field
    time." Maps onto the existing bank-buy geography (U/R verb).
  - Witcher-3 toxicity budget (*mechanism verified-common, numbers
    illustrative*): caps potion spam if variety grows; its recorded
    failure (one-and-done crafting killed herb demand) doesn't apply —
    game-two has no crafting, purchase stays recurring by construction.
  - Loot shape when drops promote: **flat independent rolls** (Tibia,
    mechanism verified) — trivially tunable, recommended over nested
    treasure classes for small teams. Any rare chase gets token pity
    (law: "pure RNG statistically guarantees a subset of players get
    nothing until they quit"; Genshin 0.6%/hard-pity-90 verified).
  - If enhancement ever rides along: bounded-failure shape day one —
    materials burn, the item never breaks (the anti-BDO rule, corpus
    recommendation).
- `game-research/mmo-economy-design-sinks-and-faucets.md` (verified
  2026-08-17):
  - "Sinks must scale with active faucets, not historical wealth" +
    "fixed-cost sinks become punitive under deflation" (New World
    deflation case, press+official-verified). game-two's banked-value
    faucet is kill-driven — potion prices get reviewed against CURRENT
    earning rate at the grill, not set-and-forget (the flat
    `regrow_cost=12` rides the same post-verdict review).
  - Sink-architecture percentages (consumables ~30% of daily removal,
    etc.) are *synthesis* tier ("starting tuning posture") —
    FLAGGED-class.

### Candidate 2 — striker identity

- `game-research/death-penalties-stat-scaling-and-progression-balance.md`
  (verified 2026-08-09) §5 niche protection:
  - The law: "protect the signature, share the edges" — signature
    ability mechanically exclusive, versatility at increased cost. The
    counterweight in the same source: "hard niches make the party
    hostage to one missing role ('we really need a healer')."
  - Tibia team-hunt economics (25-year live proof): the druid heals
    every attack turn "trading their own safety for the tank's"; every
    role blurs at the edges (sorcerers = secondary healers via runes,
    druids out-damage on the right spawn). Heal as an ACTIVE VERB on a
    body that also fights is the proven shape — agrees with the banked
    dev principle (heal on a possessable body, not a second AI).
- `game-research/tibia-mechanics-lore-and-virtual-world.md` (verified
  2026-04-10): "Druids: irreplaceable healers in team hunts; MOST
  party-dependent" — the recorded caution against shape (a) pure-druid
  conversion: most-party-dependent is the wrong identity for a 3-body
  pack where any body must hold up solo when possessed. Tibia's own
  NEWEST vocation (Monk: "melee/support hybrid — fist fighting +
  mystical powers, expected to shift meta") is the closest live
  exemplar of shape (c) hybrid.
- Hybrid cost calibration: New World dual-stat math (*datamine tier,
  patch-bound — pattern evidence only*): hybrids paid ~2% raw damage
  for flexibility — "visible, not punitive" is the target if the whirl
  gains a heal job.
- Evidence-ranked: **(c) hybrid strongest** (signature stays melee-AoE,
  heal shares the edge) · (b) whirl growth already has the lobber-E
  precedent lane, no new evidence needed · (a) carries the hostage +
  solo-viability risk on the shelf's own numbers. Grill decides.

### Candidate 3 — healing pillars

- `game-research/zelda-franchise-lore-design-and-mechanics.md` (verified
  2026-04-10): the actual Great Fairy Network shape — SIX fountains in
  all of Hyrule, hidden (bombable walls, behind ice), access-gated
  (emblem + song), each a meaningful reward. The peers' shared
  touchstone, read precisely, argues **scarce + gated + earned** — not
  ambient regen furniture. Supports the (a)/(b) placement posture: few,
  deep, fought-for.
- `game-research/death-penalties-…` (verified 2026-08-09): "the death
  penalty is a social technology… only exists when failure is expensive
  enough" — heal geography deflates death pressure (a measured
  difficulty object). Free-ubiquitous (c) contradicts the ratified
  economy law AND the shelf; (a) priced = a geographic sink (the
  scale-with-faucet law above applies to its price); (b)
  contested/cadenced = positional play with no economy bypass if the
  cadence stays slow.
- Placement note (docs-only): the banked depot pain (basement_1/2
  stationless BY RATIFIED DESIGN B2/B3) is the natural first (a)-pillar
  site — a PRICED pillar preserves no-free-sustain-in-deep while
  answering "escasos y espaciados." WB-pipeline zone authoring once the
  piece exists; nothing moves before the verdict.

### Candidate 4 — priced auto-fairy

- Rides candidate 1's evidence wholesale: charges = potions with an
  auto-cast UX layer (consumption-on-use, repeat demand, scale-with-
  faucet pricing). No independent shelf lane exists (the Zelda note
  carries fountains, not bottled fairies — the dev-verdict chat claim
  stands as chat reasoning, unshelved).
- Fence sharpened: auto-cast BYPASSES verb discovery — the exact thing
  the R-A2 ritual row measures. Design strictly after the verdict reads
  that row.

### Cycle-pace datum (the "muy rápido" pain, quantified)

- `game-research/rpg-xp-curves-and-leveling-formulas.md` (verified
  2026-08-09) carries the SHIPPED formula (`k·(L²−3L+4)`, k=40, cap 10 —
  `data/balance/progression.json`, read-only): total curve cost 1→10 =
  **10,320 XP**. Log #41 alone: `kills_xp=4069` — **~39% of the entire
  curve in one session** at endgame kill rates. The curve was priced
  for the six-zone introduction arc; v20 content growth re-prices it.
- The note's instrumentation law: "invert E(L), plug in an
  XP-income-per-hour assumption, read off hours-per-level — run it on
  every tuning change; it is the difference between designing pacing
  and discovering it." → v20 grill work item: an hours-per-level script
  against curve constants + the kill_xp table BEFORE any cap raise
  (post-verdict; progression.json frozen now).
- Sane-pacing anchor (*synthesis* tier, FLAGGED-class): "~10 kills at
  L2, ~40–60 by L15."

## Process (unchanged, restated once)

Ritual: exposure PAID both seats (2026-08-26) → s1 + s2 on different
host-clock days (owner-compressible, recorded, one reading weakens) →
10 answers → fresh-session verdict → freeze LIFTS → v20 foundation
grill opens WITH THIS SLATE + the verdict's routed rows (R-G1/R-D1/
R-T1/R-GEO/R-SO/R-E readings feed the same table). One ritual per
cycle — v20 ships content for its whole span before its own bookend.
