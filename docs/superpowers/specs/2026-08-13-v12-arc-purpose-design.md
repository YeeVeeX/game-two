# v12 — ARC/PURPOSE: A3 nest advance (breach chain) + bible fiction pass

Status: forks CLOSED by the owner via AskUserQuestion on 2026-08-13, BEFORE
this spec, as the v12 scope debate ordered (seven forks, all closed on the
dev recommendation — verbatim below). REVIEWED 2026-08-13: 4-lens
adversarial workflow `wf_c93e43ff-7cb` (code-fit / design-fun /
harness-verifiability / canon-compliance; 49 agents, 3.92M tokens; 12
deduped findings, **0 confirmed** — all killed by 3-angle majority
refutation; 6 more dropped at the dedup cap were dispositioned by hand: 2
folded as hardening, 4 dismissed — ledger: `drafts/_v12-spec-review.md`).
Review folds landed: district_two pack_spawn pinned, gradient_anchor
validation, beachhead named as a second candidate desync mechanism, annex
derivations tightened to direct canon patterns (ulwir/goret/ithet/savrim
precedent). Promoted at the 2026-08-13 scope debate off the ninth verify
(v11 WON: first spontaneous "I am starting to love the core loop";
difficulty pinned RIGHT). Fun thesis under test,
verbatim from the owner's wishlist (2026-08-12): the session must
**"advance toward something — progress, leveling, equipment, new enemies
and zones, lore, cities."** Leveling/equipment stay parked; v12 delivers
advance through GROUND and FICTION. The tenth ask's headline: **did the
session feel like it advanced toward something.**

**The seven closed forks (owner picks, verbatim):**
1. **Advance shape = BREACH CHAIN.** A sealed threshold deep in District
   One (band-2 territory). Opening it unlocks a forward camp + District
   Two beyond. The goal sits in the dangerous place — the advance is a
   journey, not a menu.
2. **Breach price = BANKED TOLL**, paid standing AT the seal. Money
   finally buys progress, not just maintenance; the deep walk to pay is
   the risk.
3. **Session end = SECOND SEAL in District Two, priced as a stretch** —
   reachable only in a long, greedy session. The horizon never runs out.
4. **District One STAYS LIVE after the breach.** No quieting, no thinning
   — the loop the owner loves is untouched; the breach opens the way
   DEEPER, it does not clean the rear.
5. **Canon = FULL ADOPTION.** Game-two IS a place in Suvareth
   (`docs/lore/world-bible.md`); the bible's §13 gameplay-hooks table is
   the live lore–mechanics contract; §14 canon rules bind all names.
6. **Pack identity = THE COURT'S COLLECTORS** (fiction annex below).
7. **Fiction dose = NEW SURFACES BORN NAMED.** Everything v12 creates
   ships fiction-named; existing banners ("The Nest", "District One"),
   station cues, and the wipe line stay UNTOUCHED (the rename is v13 law
   — capture/check comparability).

Binding upstream: scope v12 (CLAUDE.md, rewritten at the 2026-08-13
debate); `drafts/_v11-fun-verify-20260813.md` (ninth verdict + routing —
the riders' authorization); `docs/lore/world-bible.md` (First Canon
Edition); the accumulated fiction order form (A0 §form items 1-8, A0.5,
D0, death-economy items 1-9, D1, A2, ledger, D1b — answered in the annex).
Touchstones: Tibia's hub-and-spoke depth ladder (deeper spawn, richer
loot, farther depot — the reason a hunt "goes somewhere"); Tibia depot
towns as forward anchors; the bible §13 rows "Hub-and-spoke zone design"
and "Banking, stash, and currency"; Vlambeer loudness for the breach beat.
Anti-touchstone: quest-log/objective-marker progression (the arc must be
GROUND, readable by walking, not UI bookkeeping); XP bars (leveling is
parked — advance is place, not stats).

## Why this is the increment

The ninth verify's owner wishlist is explicit ("advance toward something")
and the field can now carry it: density keeps the ground alive (v11 won),
the economy has real sinks (D1b), depth bites (ninth Q3). What no system
gives is a DESTINATION: banked value buys only maintenance, and the map
ends where it began. v12 gives the session a horizon — a paid door, new
ground behind it, the hub advancing with you — and gives the fiction its
integration decision (the bible was written FOR these mechanics; every
shipped system already has a canon slot waiting).

## Scope (one increment + fiction pass + three routed riders)

**IN:**
1. The breach chain: seal fixture in District One, banked toll, forward
   camp (hub), District Two, second seal, landing zone — the increment.
2. Hub re-homing: wipe respawn + vat regrowth anchor to the last hub
   entered. Session-only.
3. `gradient_anchor` zone key (load-bearing correctness fix — see Sim §0).
4. Bible fiction pass: full order-form answers in the annex (docs-bound)
   + four born-named player-visible surfaces (camp banner, District Two
   banner, landing banner, breach line).
5. New registered events `:seal_breached`, `:home_rehomed`; arc telemetry
   + q6_margins telemetry.
6. Riders (ninth-verify routed, data lanes): density drift dose
   (join_radius, pocket_cap), corpse-guard fairness value, Q6 margin
   MEASUREMENT (no Q6 retune this increment — measure first).

**OUT — recorded (do not re-litigate):**
Leveling/XP/skills, equipment/inventory (parked; the wishlist words v12
deliberately does not deliver — recorded at the forks) · new enemy kits or
AI (same kits only — enemy variety would confound the arc test; a values
variant is v13+ candidate territory) · restart persistence (the arc resets
with the session; parked by D0 decision) · renaming "The Nest"/"District
One"/the wipe line/station cues (v13, its own increment + wall) · Q6
economy retune (measurement only this increment; the lever gets named by
data first) · respawn cadence changes (difficulty-adjacent; difficulty is
pinned RIGHT — the dose rider touches grouping values only) · live-wanderer
corpse-guard scope change (values first; scope only if values fail —
declined-for-now, on record) · the Challenger (third decline) · Tibia
AoE-specials dossier (v13+ candidates) · Q7 cue redesign (parked
presentation) · procedural zone generation (handcrafted zones only) ·
anything already in PARKING_LOT.

## Sim spec (all numbers in data/, zero balance constants in Ruby)

### 0. `gradient_anchor` (correctness fix, load-bearing — lands FIRST)

`load_zones` (world.rb:727-733) anchors each zone's gate field on
`tiles.first` of its ARRIVALS list, whose order follows zone iteration
order. Adding `camp.json` re-orders District One's arrivals and would
silently flip its `gate_distance` anchor to the east gate — inverting the
entire drop gradient, band telemetry, and beachhead reads. Fix: zone JSON
gains an explicit `"gradient_anchor": [x, y]` consumed by the gate-field
build; fallback = first arrival (today's behavior, zones without the key
byte-identical). `district.json` pins `[1, 13]` (the nest-side arrival —
today's truth); `district_two.json` pins `[1, 13]` (its camp-side
arrival). `TileMap#validate!` checks the anchor tile is passable (the
transitions/stations law extended — review fold). Regression test:
district's band map is IDENTICAL before/after the new zones load.

### 1. The seal (District One)

- New station `{"type": "seal", "at": [41, 13], "price": "breach_cost",
  "opens": [42, 13], "line": "THE WAY IS PAID"}` in `district.json`.
  [41,13] and [42,13] are passable interior tiles today (row 13 corridor,
  east end) — NO tile edits, so District One pathing is byte-identical.
  gate_distance([42,13]) ≈ 41 ≥ 28 → band-2 territory: the seal lives past
  the richest drops, at the quarter's deep end.
- New transition `{"at": [42, 13], "to": "camp", "spawn": [1, 5],
  "sealed": true}` in `district.json`. `check_transition` skips a sealed
  transition until the World records it breached. Transitions only ever
  fire for the possessed (existing law) — humans walk the tile freely.
- Interact (H) on the seal station (the existing two-press station path):
  - already breached → return false, no cue (the fixture is spent; its
    price line also stops rendering — station_price returns nil).
  - `pack.banked < price` → `station_refuse!` (the inscribe-refusal idiom;
    the dark-red X-bar).
  - else: `spend_banked(source, price, :breach)` (rides the existing
    `:banked_spent` event with a new sink symbol), mark the `opens` tile
    breached, emit `:seal_breached {zone:, tile:, cost:}`, fire the breach
    presentation (Presentation §2), `station_cue!(:breached, ...)`.
- Breach state: `World#breached?(zone, tile)` — a Hash keyed
  `[zone, tile]`, session-scoped, NOT reset by wipes (wipes never close
  the door — that is the arc) and reset only by restart (new World).
- `station_price` gains `when "seal"`: `@economy[station[:price].to_sym]`,
  nil once breached — the existing `draw_station_ledger` then shows the
  toll ("-40") to any player who walks near, which is the discovery
  mechanism: no quest text, the door and its price ARE the signpost.
- The seal consumes no RNG — the breach cannot shift any seeded stream.

### 2. Forward camp + hub re-homing

- New zone `data/zones/camp.json` — small safe hub (~20×11, no
  enemy_spawns): stations bank/altar/vat (nest's fixture kit), 3
  pack_spawn tiles, `"hub": true`, `display_name` "The Second Vigil"
  (annex §camp), transitions `[0,5] → district (spawn [40,13])` and
  `[19,5] → district_two (spawn [1,13])`. Camp-side arrival into district
  lands at [40,13] — one tile shy of the seal station, breathing room, no
  transition ping-pong.
- `Core::TileMap` gains `hub` reader (`cfg.fetch(:hub, false)`);
  `nest.json` gains `"hub": true`.
- World replaces the hardcoded `HOME_ZONE` uses with `@home_zone`
  (initialized `"nest"` — the constant survives as the initial value; its
  own comment has awaited this increment since A0):
  - `enter_zone` sets `@home_zone = name` when the entered zone is a hub
    and it differs from the current home; emits `:home_rehomed {zone:}`.
  - `respawn_pack` re-enters `@home_zone` (wipe respawn at the camp once
    reached — the arc survives death; that is what makes it an advance).
  - `interact_vat` regrows into `@zones.fetch(@home_zone)` pack_spawn
    tiles (regrowth pulls flesh home — D1b law, home now movable).
- Restart → new World → home = nest (session-only by fork; restart
  persistence stays parked).
- Beachhead: district's arrivals now include the camp-side spawn —
  `beachhead_shields?` covers both gates by existing code. Correct and
  intended (arrival is not an ambush at either door).

### 3. District Two

- New zone `data/zones/district_two.json`: 44×26 scale, NEW block layout
  (distinct silhouette — tighter alleys deeper), `display_name`
  "The Keyward" (annex §d2), palette shifted black-and-ochre (the
  Vaultwarden precinct's colors — the fiction drives the paint; floor
  darker, walls ochre against District One's cool slate).
- Same kits ONLY: `rusher` ×16, `rusher_hater` ×4 (denser than District
  One's 12+3; one-variable law — the arc is the variable under test, so
  the enemies are the enemies you know). 3 `pack_spawn` tiles near the
  camp-side gate (TileMap validation requires them in every zone —
  review fold; they are validation furniture, the pack arrives by
  transition).
- `drop_gradient: [[0, 2.0], [14, 2.5], [28, 3.0]]` — richer everywhere
  than District One, same three band INDICES (the render ladder
  magenta→rose→ember stays per-zone consistent; cross-zone value is read
  from the ZONE — banner, palette, density — not from drop pixels; the
  Tibia read: a richer town, not a richer sprite). `gradient_anchor:
  [1, 13]`.
- Transitions: `[0,13] → camp (spawn [18,5])`; second seal station
  `{"type": "seal", "at": [41,13], "price": "breach_cost_2", "opens":
  [42,13], "line": "THE WAY IS PAID"}` + sealed transition `[42,13] →
  slow_door (spawn [7,6])`.
- District Two humans do not tick until the zone is entered (existing
  current-zone law); its respawn queue freezes when the player leaves
  (frozen-zone law) — both unchanged, now load-bearing for perf.

### 4. The landing (behind the second seal)

- New zone `data/zones/slow_door.json`: tiny (~14×9), EMPTY — no
  enemy_spawns, no stations, 3 pack_spawn tiles (TileMap validation),
  `display_name` "The Slow Door" (canon-verbatim: the Undervault, "a door
  remade as a dwelling — a slow door"), one transition back
  `[7,7] → district_two (spawn [40,13])` (one tile shy of the seal
  station — the district-side breathing-room rule), palette near-black
  with one warm accent. Paying breach_cost_2 buys ARRIVAL: the corridor mouth
  under the chapter-house, silent, waiting. What lies down the stair is
  v13's to sell (recorded in Deliberately Absent). The stretch seal pays
  off in fiction-weight, telemetry (`seal2_breached`), and the debate —
  not in more field.

### 5. Events

`:seal_breached {zone:, tile:, cost:}` and `:home_rehomed {zone:}` join
`World::EVENTS` (world.rb:20 whitelist — defined on first use, unknown
symbols still raise). `:banked_spent` gains the `:breach` sink symbol
(payload shape unchanged).

### 6. Telemetry (subscriber-side, the density-line pattern; formats
### pinned here — the tenth verify harvests BEFORE questions)

**Arc line** (new): subscribes `:seal_breached`, `:home_rehomed`,
`:zone_entered`, `:banked_spent`.

```
TELEMETRY arc breach{fired=N first_frame=F banked_after=B} rehomed=R camp_visits=C d2{entered=E kills=K} seal2_breached=S
```

`fired` counts seal breaches (0-2); `first_frame` = frame of the first
breach (0 when none); `banked_after` = banked remaining after the first
breach (the dose read: how much cushion the toll left); `rehomed` counts
home changes; `camp_visits` counts `:zone_entered` for camp; `d2.entered`
0/1, `d2.kills` = kills while the current zone is district_two;
`seal2_breached` 0/1. Zero case pinned: the line ALWAYS prints, all-zero
(`fired=0 first_frame=0 banked_after=0 ...`) — presence is the
subscriber-alive proof; a zero-arc session routes as "unexercised", never
as mechanism defect (v11 law).

**Q6 margins line** (new — the ninth's Q6 routing: MEASURE before any
retune; the lever gets named by data): at each `:banked` event, sample
{amount, possessed hp fraction, dead count, wounded count, frames since
last bank}; classify a trip "pure" when dead=0 and wounded=0 (banking
with nothing to maintain — the carry-anxiety signal).

```
TELEMETRY q6_margins banks{n=N pure=P} amount{mean=A max=M} hp{mean=H.HH} dead{mean=D.D} wounded{mean=W.W} gap{mean_s=G}
```

`hp.mean` two decimals; `dead/wounded` one decimal; `gap.mean_s` = mean
seconds (frames/60, integer) between consecutive banks. Zero case: all
zeros, line always prints. Hypothesis separation the debate will read:
high `pure` share + high `hp.mean` → trips are anxiety, the lever is
carry-side; low `hp.mean` or high `dead.mean` → trips are maintenance,
the lever is sustain economics; short `gap.mean_s` with small `amount.mean`
→ cadence, the lever is trip size.

### 7. Riders (data commits, judged at the tenth verify)

`data/balance/threat.json` `density` block:
- `join_radius_tiles` 3 → **4** — looser chaining: late-session survivors
  two-plus tiles apart still count (and join as) one pocket; the drift
  toward scattered singles slows.
- `pocket_cap` 5 → **6** — one over the engagement ring
  (`engaged_cap_per_target` 5): a full pocket now includes one PRESSURING
  member, so a "full" group reads bigger than the ring it fights with.
- `corpse_guard_tiles` 6 → **10** — pockets FORM far enough from a live
  load that ordinary wander doesn't drift onto it (the ninth's Q7 camp:
  the guard binds respawn anchors; 10 keeps formation outside typical
  drift while staying under `respawn_block_tiles` 12, so the guard can
  never out-suppress the block law). Fairness values only — nothing
  softens: counts, damage, cadence untouched (difficulty is pinned RIGHT,
  owner verbatim).
- `scatter_radius_tiles` 2 and respawn cadence (300f) UNTOUCHED — cadence
  moves concurrent-alive pressure, which is difficulty-adjacent.

`data/balance/economy.json` gains:
- `"breach_cost": 40` — derivation from ninth telemetry: session 2 banked
  9 trips, mean 19, while spending 152 on maintenance; two good trips ≈
  the toll, so a mid-session player who wants the door can have it by
  choosing it over one tribute — a real decision, not a grind wall. The
  dose risk is pre-registered (verify routing: unreached breach → dose or
  discovery defect, fix-forward).
- `"breach_cost_2": 150` — the stretch: near session 2's entire gross.
  Post-breach economics run 2.0-3.0× in the Keyward, so a long greedy
  session can true it — barely (fork 3, verbatim: "reachable only in a
  long, greedy session").

`data/display.json` gains `"breach_banner_frames": 150` (the breach
line's hold, ~2.5s).

### Perf

Three new zones cost nothing while not current (only the current zone's
humans tick; drops/corpse clocks in other zones are integer decrements).
District Two's 20 humans raise the current-zone ceiling from 15:
density_pockets O(n²) on release ticks = 400 Chebyshev pairs — noise
against 16.6ms (current p95 0.284ms). `rake perf` re-proves ALONE before
the suite; the perf scenario stays District One (unchanged baseline), and
a D2 hunt in any pilot flight watches the overrun counter.

## Fiction annex — the bible pass (full adoption, the court's collectors)

This annex is the integration decision PARKING_LOT deferred on 2026-08-09:
game-two is canonically IN Suvareth. Binding rules: bible §14.1 naming
(every proper noun derives from §2; translated epithets legal for peoples,
orders, creatures, and places — canon's own style: the Whisper Roads,
Hollow-Anvil; no god deep-names; no mortal glottals; no `dral`; slop test
on everything). Extension protocol §14.4: everything below ATTACHES to
existing canon (Silt-Mother vat-craft, Vaultwarden deputation, the
funerary pipeline, the Scarred Present's Great Processing backlog) —
nothing parallel-invented. The bible is amended by ADDING (its own rule);
nothing below contradicts the First Canon.

**The place.** The game is set in **Silovun** ("the gathered river-doors";
sil + ov + -un, §2.2/§2.3), a Kingdoms-stratum funerary port on the lower
Sil, downstream of Sur-Sildra — a city whose whole wealth was
tomb-endowments and passage-services. Stratum reads per §6: Kingdoms
masonry, Heresy-voids on the oldest walls, Scarred-Present repairs.

**The collapse (A0 item 6).** In AS 3205 Silovun's great perpetual
endowment DEFAULTED (canon device, §10.1: endowments "can default,
orphaning the dead they feed") and the post-Heresy triple-certification
deadlock froze the estate in audit. The offerings stopped; the rites
stopped; Law I did what Law I does — the quarter began to fray. Its dead
went unfed, the wild dead rose, and the district was EVACUATED and placed
under **funerary interdict**: by writ of the court below, the whole
quarter is a corpse inside its term. This is the collapse on screen — not
war, not monsters: maintenance withdrawn. "The world holds because
someone holds it," and here, someone stopped.

**The humans (A0 item 5).** Term-looters — salvage crews stripping an
interdicted quarter, cursed by every funerary code and stopped by none
(canon verbatim, §5.3). Collectively **the Unpaid** — people taking from
the term without paying the term's price, the one obscenity in a world
where everything crossing pays. Annex role-names (docs-bound; no kit text
renders yet): the rusher = a **picker**; the rusher_hater = a
**wardsman** (the crew's hired guard — the variant that hates the pack on
sight because fighting it is his wage).

**The pack, possession, and the entity (A0 items 1-3; death-economy soul
model, canon-sealed).** The court answers interdict-breaking with the
curse the codes promise — given teeth. The player is an **ulwir** (ul +
-wir, "one who works the under" — the *seamwir* agent pattern, §2.3's
own example): an unbound echo out of the Great Processing backlog —
corpse gone, name gone, a diagnosable ghost — offered the court's dry
mercy in the eleventh-chamber idiom: *serve as the interdict's warden,
and the service pays your Toll.* The dead arrive below as creditors; an
ulwir is a creditor working the debt DOWN from the field. The three
bodies are **suvrim** ("the holding-host"; suv + -im on the *savrim*
precedent — canon itself builds sav + -im that way, and §2.1 permits the
vr onset): soulless provisional flesh, vat-grown by Silt-Mother craft
under Vaultwarden license (§5.3's provisional bodies, monster-side —
exactly the device the death-economy doc reserved), made to HOLD a
rider. Possession is anchorage: the echo rides one vessel at a time;
body-death merely unseats it (the swap); losing all three is the knot
slipping entirely (the wipe) — and the court re-seats its warden,
because the debt is not done. Kit-pattern names (docs-bound; each a bare
root + -et, the Khelat/Suvet pattern — no inserted consonants, review
fold): the blocker vessel is a **goret** ("lone bulk", gor + -et); the
striker an **ithet** ("small ending", ith + -et — the vessel whose one
work is the finishing stroke); the lobber a **hevet** ("small breath",
hev + -et — the vessel that works at the distance of a thrown word).

**The stations (A0 item 4; D0 items 1-3; D1b items; death-economy items
2-9).** The hub is the court's field-station — a **vigil** (the Vigilant's
register: a kept light in a dark quarter; Hezreth'Savra patronage, "bright
work in dark places"). The bank fixture is the **remittance chest**:
banking is not saving, it is REMITTING gleaned value to the court —
which is why the pile only counts once it is in the chest (D0's
carried/banked split, now doctrine). The drop is **toll-shavings**: the
grave-goods and prepaid toll-credit the Unpaid strip from the quarter's
dead, in scrap form — the pack gleans it BACK (which is why deeper,
older, richer streets shed more: the gradient is the quarter's burial
wealth). The altar performs **enrollment**: the god-mark inscribes a
vessel into the court's rolls for ONE judgment, and the judgment consumes
it (D1b's mark-burn, verbatim). The vat is the **field vat-garden**
(Silt-Mother craft); tribute is the full-maintenance rite — one price,
one decision, because the gods do not do partial mercy (D1b law,
canon-toned). The corpse term inside an interdicted quarter runs on
PROCESSION time, not calendar time — the writ audits at the speed of
grief (death-economy item 5's ten-days-vs-90-seconds delta, answered).
The corpse run is the warden's **recovery walk** — the monster-side twin
of the canon "walk of shame and iron" (§5.3), and the reason looting your
own dead vessel is lawful: the flesh is the court's property and you are
the court's officer.

**A0.5 items (specials, mark, pip — docs-bound).** The mark is a **writ
of seizure**: the echo NAMES its quarry in the deep register and the
host converges — name-magic as pack coordination (Law II working).
Specials are each vessel's one great saying — the goret's ground-shaking
stand, the ithet's killing sentence, the hevet's rained word — and the
special-ready pip is banked khelet-heat (§5.2): the vessel's ember
holding enough charge to spend. Names stay docs-bound until a text
surface exists.

**A2/ledger items (docs-bound).** Pressuring stance = the ring of
claimants (creditors crowd, only so many collect at once — Dekharu's
arithmetic on a street corner). The leash walk-home = the Unpaid know
exactly how far the interdict's warden will be followed. Depth bands =
the quarter's wards, priced by how far past the living street the writ
runs. The beachhead = the door-tile's grace: arrival is not an ambush,
even for a curse. The fight-ledger tally = the **reckoning** — the writ
register made visible.

**The four surfaces that RENDER in v12 (born named):**
1. Camp banner: **"The Second Vigil"** — the court's light advances one
   post deeper. (And it names the ladder: at the v13 rename, the nest
   becomes the First Vigil — the arc was always vigil to vigil.)
2. District Two banner: **"The Keyward"** — Silovun's Vaultwarden
   precinct: chapter-house, roll-rooms, blessing-vendors; keys at the
   throat (§4.1). The richest pickings in the quarter, which is why the
   Unpaid push deep and why the gradient pays 2-3×.
3. Landing banner: **"The Slow Door"** — canon-verbatim (§3.2): the
   corridor mouth beneath the chapter-house. The stair down is v13's.
4. Breach line: **"THE WAY IS PAID"** — the writ register (§3.2: every
   funerary rite is drafted like a writ; §5.3: passage services the
   Debt). UI voice (A0 item 8) is hereby ANSWERED: banners and beat
   lines speak as the court's paperwork speaks — declarative, stamped,
   paid or unpaid. Nothing on screen ever speaks for the Unpaid.

**Named-but-not-applied (v13 rename batch, recorded so nothing is lost):**
"The Nest" → **The First Vigil** · "District One" → **The Longrow**
(Silovun's outer ward: one long processional row from river-gate to
seal — and the name the banner check will re-calibrate against) · wipe
line "THE HUNT ENDS" → **"THE FLESH IS SPENT"** (judgment register — the
vessels dissolve; the echo does not die, it is re-seated). These ship
ONLY with v13's rename increment + full wall re-run.

**PARKING_LOT update (rides the spec commit):** the world-mythology entry
flips from "integration is a future decision" to "ADOPTED at v12
(2026-08-13, owner fork)".

## Presentation spec (Rule 2 surface)

1. **The seal reads sealed, then open, in one frame each.** Sealed: the
   transition tile draws as a dark slab with a thin gold seam (near-wall
   weight — deliberately NOT the gold gate square: gold = walkable, and a
   sealed door is not walkable grammar). The seal station beside it draws
   in its own palette key (`station_seal`, ochre family) with the
   existing station fixture grammar, and shows its price ("-40") through
   the existing station-ledger path when approached. Breached: the slab
   flips to the standard gold transition read — the way IS open, same
   grammar as every gate the player knows.
2. **The breach is LOUD (Vlambeer):** on `:seal_breached` — screen shake
   (the feel kit's existing strongest kick), the seal's station cue ring,
   and the breach line "THE WAY IS PAID" centered in the banner slot in
   gate-gold for `breach_banner_frames`. One beat, three channels, no
   pop-in anywhere.
3. **Camp and Keyward read as ARRIVING somewhere:** banners render their
   born names through the existing banner path; the Keyward's
   black-and-ochre palette makes new ground read in one frame without a
   single new draw primitive; the camp is small, warm-lit (palette), and
   station-dense — safety reads as furniture, not as text.
4. **The landing reads as threshold, not reward:** near-black, empty,
   named. Silence is the presentation.
5. Existing surfaces byte-identical: nest, District One (minus the two
   new fixtures at its deep east end), HUD, wipe line, station cues.

## Harness + gates

- **Replays: existing streams desync via the rider values**
  (join_radius/pocket_cap change pocket composition → anchor choices;
  corpse_guard 10 changes deferral timing near loads) **and, candidate
  second mechanism, the camp-side beachhead** (the new arrival at
  [40,13] extends acquisition-shielding over the deep east — e.g. the
  rusher spawn at [38,12] sits inside its radius; any stream whose pack
  crossed that neighborhood pre-waiver can shift — review fold, 8
  finders). Zone additions are otherwise behavior-neutral for District
  One streams (no tile edits; gradient_anchor pins the band map; seal
  fixtures sit past every scripted path at the corridor's east end; new
  zones never tick unentered) — and the whole claim is VERIFIED, not
  trusted: triage replays all 11 existing scripts and re-pilots whatever
  actually desyncs,
  re-staging ALL mandatory beats (memory: gate-critic-mandatory-beat-
  checks). Provenance map → `drafts/_v12-wall-log.md`.
- **New gate script `nest_advance.json`, pilot-authored** (memory:
  pilot-staging-traps — interact is a PRESS; wait 25 after swap before
  special; ≤20 captures; ACTIVE window; clean Esc): (act 1) hunt +
  bank toward the toll — the "-40" price on camera at the seal; (act 2)
  the breach — pay on camera: slab flip + cue + breach line in one
  captured beat; (act 3) through the door — camp banner + stations on
  camera; (act 4) the Keyward — banner + ochre palette + denser field +
  one kill's richer drop on camera; (act 5) the second seal's "-150" on
  camera. The Slow Door is NOT staged (150 toll in a pilot flight is a
  grind, not a beat) — its checks pass on the 'not exercised by this
  script' hatch; unit tests own the transition.
- **Vision checks ADD-ONLY 40 → 42:**
  - #41 `seal_breach_reads`: when the seal is on camera sealed, it reads
    as a shut, priced door (dark slab + seam + station + visible price —
    a stranger could say "locked, costs money"); when the breach beat is
    on camera, the way visibly opens (slab → gold) and the line "THE WAY
    IS PAID" is legible; if no breach frame, pass with why='not exercised
    by this script'.
  - #42 `new_ground_reads`: when a camp or Keyward banner frame is on
    camera, the banner text is legible and the zone reads distinct from
    District One at a glance (camp: safe/station-dense/warm; Keyward:
    ochre palette + denser field); if neither zone appears, pass with
    why='not exercised by this script'.
- Tests (minitest, real World, no mocks):
  - gradient_anchor: district band map identical pre/post new zones;
    fallback (no key) = first arrival (today's behavior pinned).
  - Seal: refuse under-toll (cue :refused, no spend); pay exactly price
    (banked_spent sink=:breach, :seal_breached payload, breached? flips);
    idempotent (second press no-op, no cue, price nil); sealed transition
    refuses pre-breach, fires post-breach; breach survives a wipe;
    fresh World → sealed again.
  - Re-homing: entering camp emits :home_rehomed once (re-entry emits
    nothing); wipe respawn lands at camp pack_spawns; vat regrow targets
    camp tiles after re-home; nest-only session behaves byte-identically
    to today (no rehome, no event).
  - District Two: loads, seeds 20 humans, gradient bands/multipliers,
    both transitions; slow_door loads + returns.
  - Telemetry: arc + q6_margins exact line formats, zero cases (all-zero
    lines still print), d2.kills counts only district_two kills, pure-trip
    classification.
  - Determinism: double-run equality on a stream that breaches, re-homes,
    and crosses all four zones.
  - Existing pins that encode "respawn at nest" UPDATE where the meaning
    change IS the increment (re-homing) — never silently.
- `rake perf` ALONE (p95 < 16.6 ms), then full `rake`. Merge `--no-ff`;
  **NO push — ever.** CHECKPOINT with measured numbers.

## Fun-verify (TENTH — BLIND; owner plays first, NO changelog)

Protocol (ninth's law): unique log per launch (the launcher enforces it),
never relaunch over an open session, harvest ALL telemetry (arc, density,
q6_cadence, q6_margins) BEFORE any question; only clean Esc exits flush.

**Preamble:** if you never found the sealed door, or never paid it, say
so — those questions read as unexercised, not negative.

1. **The arc (HEADLINE — the owner's own wishlist words):** did the
   session feel like it was ADVANCING toward something — going somewhere —
   or was it another lap of the same ground?
2. **The breach:** when you paid the seal and the way opened — did that
   land as an earned payoff? Was the toll worth wanting?
3. **New ground:** did the Keyward feel like ARRIVING somewhere new and
   worth reaching — or just more district?
4. **The re-home:** respawning and banking at the Second Vigil after the
   breach — did that feel like progress you'd defend, or just a shorter
   walk?
5. **Money purpose (Q6 re-read):** did banked value feel like it was FOR
   something this time? And the nest trips — still too often, or did the
   camp/toll change the rhythm?
6. **Q1 guard (drift dose re-read):** did the field stay worth fighting
   deep into the session, or did it still drift toward cleanup
   eventually?
7. **Fairness probe (Q7 re-read):** any respawn feel unfair — a group
   camping your corpse run, spawns where you were looking?
8. **Entrainment (FIFTH read):** on the scariest stretch — deep in the
   Keyward, thin HP, a fat carry — did your body react?

**Pre-registered routing (locked here — do not re-derive at the verify):**
- **Q1 MOVED** (session advanced) → v12 wins; next = scope debate (v13
  leads: Tibia AoE-specials dossier, the Challenger [third decline,
  weakened dossier], the Nest rename [now unblocked — the annex carries
  the names], plus whatever this verify routes).
- **Q1 UNMOVED + arc telemetry shows breach never fired** (`fired=0`) →
  dose or discovery defect (toll too dear for a mid-session, or the door
  too hidden) — fix-forward on THIS increment (breach_cost value /
  signpost lane), not new scope, not a debate item.
- **Q1 UNMOVED + breach FIRED** → the arc shape itself under-delivers —
  goes to the debate as a candidate (the honest negative: ground alone
  didn't read as purpose).
- **Q2 flat with breach fired** → beat presentation lane (values/
  presentation, data + renderer only).
- **Q3 "just more district"** → Keyward differentiation lane (palette/
  layout/density values — enemy VARIETY goes to the debate as v13
  evidence, per the same-kits law).
- **Q4 "just a shorter walk"** → recorded, no lane (re-homing is
  infrastructure; its meaning rides Q1).
- **Q5 money purpose moved but trips still "too often"** → q6_margins
  names the lever (pure-trip share vs maintenance share vs gap) → the
  NAMED lever goes to the debate. No blind retune (third regression law).
- **Q6 drift still felt** → second density VALUES iteration with the
  ninth+tenth data side by side; if two dose iterations both miss, the
  lever is structural → debate.
- **Q7 camped again at guard 10** → the values lane is EXHAUSTED;
  guard-scope (live-wanderer avoidance) un-parks as a design item at the
  debate — still never a global softening.
- **Q8 body reacted again** → density+arc are carrying entrainment; the
  Challenger's dossier stays unpromoted-by-default. Flat → one datapoint
  after a move, noise-vs-signal argued at the debate, dossier unchanged.

Verdict → `drafts/_v12-fun-verify-<date>.md` + CHECKPOINT + commit,
routing applied verbatim.

## Deliberately absent (recorded so review doesn't re-litigate)

Leveling/XP/equipment (parked; the wishlist words v12 does not deliver —
said out loud at the forks) · new enemy kits/AI/variants (same-kits law;
the Keyward's difference is ground, density, wealth) · anything behind
the Slow Door (the stair down is v13's to sell — the landing is a
threshold on purpose) · restart persistence (arc resets with the session)
· quest text, objectives UI, minimap, markers (the ground is the
signpost; the price is the quest) · respawn cadence retune (difficulty-
adjacent) · Q6 economy retune (measurement first — the margins line
exists so the ELEVENTH conversation starts from data) · corpse-guard
scope change (values first) · seal re-lock / toll refunds / partial
payment (one price, one decision — station law) · multiple simultaneous
hubs with player choice (home = last hub entered, period) · renames of
any existing surface (v13) · the Challenger · AoE specials (dossier
parked) · everything already in PARKING_LOT.
