# Junior — v19 ideas intake (2026-08-19)

Banked per the v18 session-14 spark Job 6 (Itexo-style triage:
FOLD-NOW / BANK / PARK+trigger / ROUTE-SIBLING). **v19 does NOT open
this session** — these are brainstorm inputs for the cycle that starts
after the SEVENTEENTH adjudicates.

## Idea 1 — Tibia stationary facing (Ctrl + direction)

**Provenance:** relayed by the owner, live chat 2026-08-19 ~00:2x
(mid-ritual-night, between session-1 crash and re-run). Owner verbatim
(English):

> Junior had the idea to add the stationary facing direction change
> that Tibia uses, by holding ctrl and pressing a direction key (either
> AWSD or arrow keys) and the character should stuck in place during
> the time it holds ctrl and faces towards the side that it presses the
> direction on, what is the best approach?

**Triage: BANK (v19 brainstorm input).** Small, grid-native, cites a
real touchstone.

- **Touchstone (reference wall):** Tibia's Ctrl+arrow turn-in-place —
  a real Tibia control, same modifier shape Junior names.
- **What it serves mechanically:** facing is load-bearing here —
  projectile kits fire along facing lanes and `front_tile` reads
  facing for follow/yield logic. Today facing only changes by
  stepping; a free stationary turn = aim without committing a tile
  move (doorway holds, lobber lane re-aims, corner peeks). Real value,
  not chrome.
- **Recommended approach (next-spark shape, dev of record):**
  1. **Input layer** (`src/core/input`): a held FACE modifier (Ctrl)
     reroutes direction presses from MOVE intent to a new FACE intent.
     While held, no move intents are emitted — "stuck in place" falls
     out of intent generation, the sim never needs a modifier state.
  2. **Lockstep/replay safety:** FACE travels as one more intent in
     the per-tick input frame — additive, deterministic, replay
     scripts unaffected; netplay build identity already enforced by
     the same-commit fingerprint law.
  3. **Sim:** facing mutation without a move enqueue (grid-walker
     skip) — a few lines; facing already exists on creatures.
  4. **Bindings:** data-driven in the bindings file (bindings.json law
     stands — no rebind UI).
  5. **Feel pass:** instant turn per the juice wall; capture + Rule 2
     gate (visible facing change = visual surface).
- **Effort:** S. **Risks:** none structural; interplay with attack
  aiming is the point, watch balance in playtest.

## Idea 2 — safe zones vs battle zones (owner, 2026-08-19)

**Provenance:** owner, live chat 2026-08-19 mid-day (dev session 16,
post-power-cut). Owner verbatim (English):

> I just had an idea (nothing groundbreaking, more like a thought), we
> should separate battle areas from safe areas, so players can't
> attack or inflict damage to others while in a safe zone (like depots
> at temples in Tibia) so when the world opens up to more players
> later on or we add any specific mission/quest/NPC related task, we
> can also play with those definitions, what do you recommend? Maybe
> it is too soon for thinking about that but I just had that in my
> mind so I wanted to share so I don't forget

**Triage: BANK (v19 brainstorm input), with one pre-recorded design
trap.** Cites a real touchstone (Tibia protection zones — depots/
temples); serves the parked multiplayer-expansion and NPC/quest lanes.

- **Touchstone (reference wall):** Tibia PZ — two halves, and the
  second is the load-bearing one: (a) no damage resolves inside a
  protection zone; (b) **the combat lock** — a battle-flagged player
  CANNOT enter the PZ until the flag expires. Without (b), safe zones
  become the exploit (dive into the depot to drop aggro/escape
  retaliation). Any future spec must carry both halves.
- **Current-era fit:** co-op has NO player-to-player damage today, so
  the only feelable v18-era version would be "enemies never pursue/
  damage into safe areas" — that is a SIM change (lockstep/replay
  identity) = post-verdict by class. Nothing ships now.
- **Cheap shape when it lands (data-driven law):** zones already carry
  `hub: true`; `safe:` is the natural sibling attribute (zone-level
  first; per-tile only if a real need appears). Systems READ the flag
  (damage resolution, AI pursuit, later PvP/quest givers) — zero
  constants in code. Hubs nest/camp are the obvious first carriers —
  note today's soak observed camp DOES host combat (fights=4), so
  formalizing `safe` would visibly change camp's character: an owner
  fork at the brainstorm, not a default.
- **What it unlocks later (the owner's own framing):** PvP rules by
  area when >2 players unparks; NPC/quest/mission placement (parked
  Kethral lanes) gets a sanctioned "town" surface; composes with the
  banking ritual (banks live in hubs — "sanctuary" reading).
- **Effort when built:** S–M (flag + damage/pursuit gates + Rule 2
  visual language for the boundary — players must SEE where safety
  starts; unmarked safe borders are a readability defect, not a
  mystery).

## Idea 3 — CryoFall-style inventory/stats menu + asset style signal (owner, 2026-08-19)

**Provenance:** owner, live chat 2026-08-19 (~16:0x, world-builder
grill thread). Owner verbatim (English):

> a player inventory/stats menu like the one on cryofall would be a
> nice fit for our game I think, and the asset style is pretty
> charming on my opinion

**Reference screenshot (described + banked):** CryoFall in-game player
menu — paper-doll equipment panel (armor/device/implant slots with
charge LEDs), a SKILLS panel (8 icon rows with segmented tally-style
progress bars), a ~10×4 grid inventory with stack counts + hover
tooltip ("Copper ingot — …industry to electronics"), a 0–9 hotbar,
HP/stamina + food/water bars, quest tracker. Local untracked copy
(gamesmith-addenda precedent — never `git add`):
`drafts/_refs/wb-cryofall-inventory-stats.png` md5
`4cc2f26746646254edda7f282252379e`.

**Triage: BANK (v19 brainstorm input) — it attaches to the DECLARED
v19 lead.** The items/backpack cycle (PARKING_LOT, owner rider
2026-08-17) already carries the dependency chain; this idea is the UI/
UX touchstone for chain step (2) inventory/backpack UI and step (3)
equipment slots + stats layer. CryoFall is a strong-fit touchstone:
top-down 2D survival sim, grid world, legible survival UI.

- **What it decides early (worth carrying into the brainstorm):**
  paper-doll + grid + hotbar is a THREE-surface family, each its own
  Rule 2 wall scripts; skills-with-tally panel presumes a skill system
  (does NOT exist — own fork, Tibia skill-through-use is parked from
  Kethral); hotbar presumes usable items (chain step 1).
- **Style signal (routed to assets seat):** "the asset style is pretty
  charming" — recorded as an owner style-direction data point beside
  the earlier tile/material reference sheets; the assets seat consumes
  style direction, this repo stays placeholder-rect until the
  integration cycle.
- **Effort when built:** the UI alone M–L; rides the items cycle,
  never alone.

## Idea 4 — leveling/XP + skill/spell system + level-gated world (owner, 2026-08-19)

**Provenance:** owner, live chat 2026-08-19 (world-builder grill close,
mid-revisitability idea). Owner verbatim (English):

> oh true! We need to start thinking on a leveling up/experience and
> skill/spell system too! … just to enable the game areas to be
> re-visiteable and unlock different level zones/dungeons across the
> world like for example WoW does or other MMORPGs, even The Elder
> Scrolls do

**Triage: BANK (v19 brainstorm input) — likely THE headline debate of
the next cycle beside items/backpack.** Pre-banked evidence so the
brainstorm starts real, not from scratch:

- **Verified shelf note ready:** `rpg-xp-curves-and-leveling-formulas`
  (game-research KB, verified 2026-08-09) — XP curve shapes, death-
  penalty-as-XP-fraction framing, instrumentation advice. Query it at
  the debate, never re-derive.
- **Connects to banked intake idea 3** (CryoFall skills tally panel —
  presumes a skill system; now the owner names one) and to the parked
  Kethral lane (skill-through-use progression) and the v11 arc/purpose
  wishlist ("progress, leveling" — owner verbatim 2026-08-12).
- **Touchstones named:** WoW / MMORPGs / The Elder Scrolls (level-
  gated zones); Tibia's skill-through-use + no-level-cap model is the
  in-genre alternative (KB note `tibia-mechanics-lore-and-virtual-
  world` §4.1) — the brainstorm's first fork is Tibia-style
  use-based vs XP-level-based, and it interacts with possession
  (WHOSE level: the pack, the body, the player-soul?).
- **Level-gated zones = fact-gated transitions** — the machinery
  ships in the world-builder lane TODAY (boss_1_defeats gate, D12/
  well-drain pattern); a future `level ≥ N` gate is the same shape
  reading a progression fact. Zero pre-build owed.
- **Save impact:** progression facts grow the save vocabulary =
  schema-v2-class work; braids with items/backpack chain step 5.
- **Sim class, obviously** — nothing ships pre-verdict; measurement
  hygiene untouched.

## Idea 5 — projection + style preview: 3/4 vs isometric, grim-detail register (owner drops, 2026-08-19 mid-T1, hub chat)

- **Owner verbatim:** "this style of isometric pixel art which is
  simple but well detailed and beautifully designed looks even more
  appealing to my eye instead of the plain top view, how can we adapt
  something like it? Or at least run a small test/preview sometime to
  test it out, I really liked that example" + follow-ups: "it is
  almost the same movement set, 8 directions but in a different
  perspective" · "diamond sets of 4 squares + its diagonals, as of top
  down which is kinda like 'crosses' shape movement" · "we can adapt
  it to an even grimmer or 'realistic' view/detailed view such as HD
  Tibia, or RavenQuest/RavenDawn for that sort, but with the isometric
  perspective".
- **Refs banked:** `drafts/_refs/wb-gnomoria-iso-style.jpg` (md5
  `5c965f63de37a1465352ece6be736ffc`) + `drafts/_refs/
  wb-ravendawn-34-detail.png` (md5 `5215ea4966acbdcbd5b2e2a4b44e7ae0`)
  (untracked — gamesmith-addenda precedent). KEY read: the two refs
  use DIFFERENT projections — Gnomoria is true 2:1 iso; RavenDawn is
  Tibia-style 3/4 top-down (orthogonal ground grid + drawn wall/height
  faces + painterly materials). What the owner's eye tracks across
  both: material richness + visible height + lived-in detail.
  Gnomoria style notes: 3-face block shading · material palette
  families · 2-tone floor checker (== our grid modulation) · decor
  sprites · z-levels (rhymes with D3 floors).
- **Dev read (verified against code + refs):** THREE independent
  dials — projection (flat top-down now · 3/4-with-height · true 2:1
  iso) · fidelity (placeholder → chunky pixel → painterly HD) · tone
  (current palette is already grim-adjacent; the owner's register
  target fits the existing vibe). Sim untouched under ANY projection:
  8-dir movement already real (`grid_walker.rb:76` diagonal √2
  duration); grid cardinals ↔ screen diagonals under true iso (the
  owner's cross↔diamond rotation). Dev position (defended): 3/4 is
  the cost/beauty sweet spot (same camera/mapping, no depth-sort or
  occlusion rewrite, LDtk identical, ~80% of the RavenDawn feel);
  true iso is the big jump (occlusion decision + combat-legibility
  re-verify under Rule 2 + input-mapping fork world- vs
  screen-relative). Fidelity is an ASSET-ERA dial that applies to
  whichever projection wins. **Combat-clean law (non-negotiable in
  any register):** environment may go rich, but telegraphs/enemies/
  drops stay high-contrast — legibility beats texture (RavenDawn can
  afford density because its combat is slow tile-by-tile; ours is a
  fast ARPG).
- **Spike shape (updated):** T1-style throwaway session — worktree,
  placeholder geometry, deterministic captures of the SAME replay in
  all THREE projections side by side (flat · 3/4 front-faces · iso
  diamonds+prisms), input toggle for iso (world- vs screen-relative).
  Owner's eyes pick the projection BEFORE the asset era paints over
  it. No gate owed (nothing ships). god-view map stays top-down
  (truth artifact).
- **Class:** renderer-only preview = spikeable anytime as its own
  session (owner-paced); ADOPTION is a v19-brainstorm decision
  (braids with the asset era + the style board: CryoFall charm ·
  Gnomoria iso · RavenDawn/HD-Tibia grim painterly detail). Asset
  cost if painterly wins: every material needs painted variants +
  edge blends — the D7 registry's sprite-id seam carries it.

## Slot status

Nothing else arrived (no paste, no drafts file beyond this relay, no
Junior commit carrying ideas). Answers, when they arrive bundled with
ideas, get SPLIT per the spark (answers → skeleton, ideas → here).
