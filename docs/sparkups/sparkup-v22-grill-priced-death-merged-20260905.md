# Spark-up -- game-two session: v22 GRILL "THE PRICED DEATH" (cycle foundation + first-wave tickets) with the ART LANE chartered alongside (LDtk + Aseprite, modern and original look)

MERGED EDITION (2026-09-05, s130 close-out): the hub's approved v22 spark below is kept verbatim;
every insertion from the WB-T6 session is tagged `[MERGE s130]` so you can tell the owner's
direction from the handoff facts. Nothing tagged overrides the owner's words; where the two
collide (cycle name, art-lane premise) the collision is NAMED for the grill, not resolved here.

## HANDOFF PREFACE [MERGE s130] -- facts the hub's draft could not see (read, then verify live)

1. **WB-T6 is CLOSED DONE** (s130, 2026-09-05). `main` = `735a37c` (or later). The s130 session
   held the seat only while its window was open; `fleet` should show game-two FREE. If it does not,
   the owner closes that window -- never `/seat take` over a live session.
   Record: `drafts/_wb-t6-ldtk-foundation-20260905.md` (findings table, review, follow-ons in its
   section 5). CHECKPOINT top = s130 entry, CLAIMED none.
2. **What WB-T6 left as LAW (docs/MAP_EDITING.md sections 4.1-4.5):** `tools/normalize_ldtk.py`
   (LDtk saves -> the builders' byte pin; `--check` runs in the suite); the AfterSave loop
   (`tools/ldtk_aftersave.py` registered in pilot.ldtk: Ctrl+S = normalize -> import into
   tmp/ldtk_out -> world-graph lint; window self-closes on success, stays open on refusal);
   `tools/lint_world_graph.rb` + `authoring/world_graph_allowlist.json` (14 floor-delta rows:
   6 INTENDED, 8 LEGACY; suite blocks NEW and stale rows); pilot.ldtk defs ergonomics (docs, regex,
   tags, layer selection/opacity). Two GUI-safety laws measured on the FIRST real GUI save:
   (a) undeclared IntGrid values are ZEROED by LDtk on load (924 cells lost, fixed + test-pinned);
   (b) a `spawn` Point outside the SOURCE level is invalid to LDtk and a level tidy NULLS it --
   five live cross-zone transitions are affected and must not be touched in the GUI until WB-T7.
3. **Junior shipped art mid-session under the label "PREMIUM v22"** (his seat, pushed 2026-09-05
   12:05-12:55 -03:00; no plan doc or CHECKPOINT entry yet -- he may still be pushing):
   `03259d0` drawn characters (20 kits, 32x48 frames, `tools/gen_premium_art.py` + `tools/premium_art/`
   -- procedural Python drawing, not Aseprite) . `1ac9e9e` world_loop gate verdicts . `7189be7`
   dual-grid material tiles (`App::Tileset`, `tools/gen_tileset.py`, `data/art/tiles.json`, 12 textures
   -- the gamesmith brief's OPTION 2, engine-side autotiles from the IntGrid, NOT the brief's
   recommended Option 1 "LDtk bakes, game draws"). Consequences for THIS session, all to be named
   at the grill, none pre-decided: (a) cycle-name collision -- the hub's v22 = "THE PRICED DEATH",
   Junior's "PREMIUM v22" = an art wave; one owner line settles it (e.g. the art wave becomes lane D
   of v22 under its own name); (b) the art lane's A2 premise (LDtk tileset + auto-layer rules over
   Terrain) now competes with a shipped engine-side dual-grid -- the brief's integration fork
   (section 3.7 table) is a PEERS' decision, Junior ratifies async; (c) Evidence pack A (the tour)
   was rendered BEFORE this art landed -- re-run `harness/make_tour.sh` on HEAD (detached, ~10 min)
   before asking Q9-Q11 so the owner judges the CURRENT look; (d) no fresh-eyes review is recorded
   for these commits either -> widen T0 to `restore/pre-mundo-vivo-20260904..HEAD` (MUNDO VIVO +
   PREMIUM v22), findings banked, not a revert vehicle.
4. **Pending / recommended from WB-T6, each with its landing spot in THIS session:**
   - WB-T7 (code ticket, NOT this session): cross-zone `spawn` GUI-safety -- `spawn` as an EntityRef
     with `allowOutOfLevelRef` (brief section 3.5) or a String "x,y"; importer `field_value` +
     builders + `test/fixtures/spike_district.ldtk` re-pin; emitted zone JSON byte-identical by
     construction. LANDS AS: art-lane charter row A0 (precondition for any GUI session on pilot.ldtk)
     and a first-wave ticket in the spec's WB column.
   - The 8 LEGACY floor rows (camp/nest/slow_door carry floor 0 beside their v20 neighbours;
     HUB 1's east door drops two floors through a plain gate). LANDS AS: a grill question (Q8b
     below) -- it becomes URGENT the moment A3's "ZONE 5 . -3" banner makes `floor` player-visible
     (today nothing in the sim or renderer reads `floor`). Fix path = hand-authored JSON + typed
     gates, Rule 2 + canary (`world_loop` traverses camp); each fixed row leaves the allowlist (the
     suite forces it).
   - Entity icons via LDtk's embedded `LdtkIcons` atlas: GUI-only, any peer's session; run
     `--check` + the D6 emission diff after. LANDS AS: art-lane row A2 sub-item (S1 leftovers).
   - Junior's machine pre-flight for the AfterSave command (`where python` / `where ruby` in cmd;
     pt-br section in docs/JUNIOR.md). LANDS AS: a RATIFIED-J async ask line.
   - Method notes: LDtk's log buffers until exit (judge saves by mtimes / `--check`, never ldtk.log);
     `python tools/normalize_ldtk.py --semantic-diff a b` prints a BY-SHAPE summary -- read it
     whenever a GUI save is suspected of changing meaning.
   - Python bytecode caches are now gitignored (`__pycache__/`, `*.pyc`); Junior's 4 tracked .pyc
     files were untracked in `735a37c` -- tell him in the pt-br close line.
5. **Gamesmith brief RECEIPT sent** (banked docs-only). The brief's S3 (enums) / S4 (tileset +
   rules) / S5 (layout) remain unopened sparks; S4 is the art lane's A2 and now depends on the
   Option 1 vs Option 2 decision above.

---

Class: JUDGED (owner-approved direction; the session's product is DESIGN -- a ratified cycle
foundation, a spec, cut tickets, and a chartered art lane -- not code). Target seat: game-two
(C:/Users/gabri/workspace/game-two, Gabriel's machine). You are a fresh dev-of-record session.
AGENTS.md is auto-injected and is ground truth; this spark never overrides it. Owner present LIVE
for the grill. FULL SEAT SYMMETRY: Junior ratifies async (pt-br line at close).

## 0. Provenance (owner words, verbatim, game-two hub chat 2026-09-05)

- The question that opened this: "what is our game lacking to be competetitive against our
  inspiration/influence games such as Tibia, Ultima or Oldschool Runescape?"
- The hub's answer (grounded in the KB shelf + gamesmith's cross-game synthesis; do not re-derive,
  verify by reading the cited files): the genre's spine is PRICED LOSS. game-two has (1) no price
  on death, (2) nothing to invest in beyond a level number, (3) no reward vocabulary. Recommended
  order: v22 = the priced death; then a minimal item layer (owner call); then goals via a
  bestiary/task shape; the legibility-first cohesion pass underneath all of it.
- Owner: "Approved, proceed to design the next session spark-up prompt with clear directions,
  guidelines and instructions as you consider optimal for maximum quality results (quality over
  cost), clipboard it for me so I can start the fresh new session with focused context headroom.
  But still keep an eye on better art since we are stuck in a very dated look and we need our game
  to use the power of LDtk and Aseprite for a more modern and original look"
- Standing spend word (same day, now in global AGENTS): "cost is not a concern, quality over cost if
  its inside AWS" -- declare estimates + stop conditions, never ask per run.
- Earlier the same day, watching the tour: "I kinda looks better but sloppy, like it was not revised
  by the assets seat" -- the art lane's reason to exist, in his words.
- [MERGE s130] Owner, s130 close: "for next session combine whenever stays pending or recommended
  from this session" -- the HANDOFF PREFACE above is that combination.

## 1. Hub facts you cannot see (read, then verify live)

- `main` is at or after `ad9238f` (s129: dev warp `bin/warp <zone> [locale] [level]` = start anywhere
  on a scratch save; `harness/make_tour.sh` = 2.5x area-tour MP4). MUNDO VIVO (v21) landed s128.
  A WB-T6 session (LDtk foundation wave: normalizer, AfterSave importer, world-graph lint) may have
  landed commits after that or may STILL HOLD the game-two seat -- `fleet` first (section 3 step 0).
  [MERGE s130] Superseded: WB-T6 CLOSED DONE, `main` >= `735a37c`; see the HANDOFF PREFACE.
- Evidence pack A -- fresh-eyes read of our own footage (gamesmith pipeline over a 12-minute
  real-time tour of all 15 areas, silent, 1 frame / 2 s; artifacts:
  `C:/Users/gabri/workspace/gamesmith/artifacts/games/game-two/recordings/tour-20260905/`
  `notes/notes-en.md`, `feel/observations.json`, `mechanics/observations.json`; extract at
  `../../extract/*.md`; tour MP4 `C:/Users/gabri/Videos/game-two/tour_20260905_2.5x.mp4`).
  [MERGE s130] This footage predates Junior's PREMIUM v22 art (preface item 3c): findings 1-3, 5, 7,
  8 are about surfaces his commits did not touch (HUD, loot glyphs, economy pop-ups, banner, goals)
  and stand; findings 4 and 6 (vertical read, hostile-vs-decor in the fire dungeon) must be
  re-checked on a fresh tour before they drive a decision.
  Hub-judged findings (reel-cut artifacts already discounted; sampling-artifact law applies):
  1. The HUD's core idea is invisible: three bars read as one character's HP/mana/stamina, never as
     three bodies + the possessed one (every segment).
  2. Loot does not read as loot: the magenta drop squares were guessed as markers/hazards/clutter in
     13 segments; the feel stage filed them as a readability defect.
  3. The economy is invisible: "-40" toll, "+2"/"1"/"0" bank pop-ups never read as money.
  4. Vertical legibility: across a 3-floor descent and a 4-floor tower the critic never knew it was
     going DOWN (independent witness to the NINETEENTH's lane-D item).
  5. Damage without a visible source (5 instances) -- ranged stingers + poison DOT; needs frame check.
  6. Hostile vs decorative ambiguity in the fire dungeon dress; needs frame check.
  7. Density + the zone banner occluding the play area exactly when a new floor bites.
  8. No goal-shaped surface in 12 minutes except "BOSS 1 DEFEATED".
  What worked cold: verb legend + Tab swap, telegraph grammar (gray->red ~0.2 s), hit feedback
  synced to the bar drop, boss nameplate/DEFEATED banner, SAFE tag, tile relief reads as elevation,
  enemy families distinct per area.
- Evidence pack B -- the verified shelf (read these SECTIONS, cite by path):
  `C:/Users/gabri/Obsidian-Vault/03-Resources/game-research/death-penalties-stat-scaling-and-progression-balance.md`
  section "6. For game-two" (the numbers: two-regime XP fine ~10% below a protected level, formula
  above; consumed-on-death insurance 8%/blessing, 3-5 stackable; mitigated death ~0.5-1.5% of
  lifetime progress, unmitigated ~4-5%; "percentage falls, absolute rises"; destroy only in-flight
  or INSURED banked progress -- never de-level uninsured; price death for the PARTY game, let solo
  insurance make solo survivable).
  `.../tibia-mechanics-lore-and-virtual-world.md` sections 2.3 (death penalty), 4.4 (blessings),
  7.1 (meaningful death = meaningful life), 7.6 (infinite progression without power creep).
  `.../crafting-loot-and-consumable-economies.md` section "For game-two" (consumption-on-use demand;
  flat loot rows + pity token when items ever promote).
  `.../rpg-xp-curves-and-leveling-formulas.md` (our curve k=40, cap 21 -- the fine must be computed
  through the live Progression object, never re-derived; precedent: save_state.rb P3 clamp law).
  `C:/Users/gabri/workspace/gamesmith/artifacts/synthesis/genre-dna.md` -- H1-H4 + earned A/B; the
  Tibia fork ("the priced death, the spine") and the OSRS fork ("graduated death tax").
- The NINETEENTH verdict (`drafts/_v20-fun-verify-verdict-20260904.md`) named for this grill:
  (1) vertical legibility (2) growth not felt 10->13 (3) objective vacuum (4) C3 third-body debt.
- Debts the hub knows: MUNDO VIVO merged with NO fresh-eyes review (Rule 6 unpaid); `world.rb`
  1767/1800 (extraction owed into the first material touch); `vat_economy` 2 rows +
  `aoe_specials challenge_reads` re-author; totem COEXISTENCE owner word; D1-D9 / swap-spec / city
  proposal ratifications pending (Junior's cycle) -- bank them in the foundation's debt ledger, do
  not solve them here.
  [MERGE s130] Add to the debt ledger: PREMIUM v22 commits unreviewed (T0 widened, preface 3d);
  WB-T7 cross-zone spawn GUI-safety; the 8 LEGACY floor rows (Q8b); `world.rb` unchanged by WB-T6
  (still 1767/1800).
- What is OUT of scope by AGENTS and stays so unless the owner promotes it IN THIS GRILL: items/
  equipment, >2 players, chat, character creation, in-game teleport/map, lore (standing order
  2026-08-16 -- placeholders only; the art lane changes pixels, never names).

## 2. The product of this session (Definition of Done)

[ ] `drafts/_v22-foundation-<date>.md` -- the cycle law: vision line, ledger rows (numbered L1..Ln,
    each = one binding decision with its touchstone), death-economy CANDIDATE numbers (all destined
    for `data/balance/death.json`, zero constants in code), interlocks, pre-registered telemetry,
    debt ledger, council amendments, RATIFIED-G verbatims. Shape precedent: `drafts/_v20-foundation-20260828.md`.
[ ] Council adversarial pass over the FULL foundation inlined (deepseek + kimi, one round each;
    starved reviewers fabricate -- inline everything; split >32K argv). Every REFUTED item re-verified,
    never deleted. Verdicts summarized in the foundation.
[ ] `docs/superpowers/specs/<date>-v22-priced-death-cycle.md` + first-wave tickets T0..Tn (grill-and-ticket
    skill: one ticket = one fresh session, CLAIMED line, closed DoD, fences, gates). T0 = the MUNDO VIVO
    post-merge fresh-eyes review (own session, headless/council over `restore/pre-mundo-vivo-20260904..
    restore/post-mundo-vivo-20260905`, findings banked, NOT a revert vehicle).
    [MERGE s130] T0 range widens to `restore/pre-mundo-vivo-20260904..HEAD` so Junior's PREMIUM v22
    commits get the same review. The ticket list gains WB-T7 (cross-zone spawn GUI-safety; the
    importer's `field_value` is the ONE place its semantics move; emissions byte-identical; fixture
    + builders re-pinned) -- sequenced BEFORE any art-lane GUI session on pilot.ldtk.
[ ] `drafts/_v22-art-lane-charter-<date>.md` -- the ART LANE (section 5) chartered with the owner's
    three direction answers verbatim, and its staged follow-on spark(s) written to
    `docs/sparkups/` (game-two) ready for clipboard.
    [MERGE s130] `docs/sparkups/` exists as of s130 (this file is its first entry). The charter must
    record the Option 1 / Option 2 decision (preface 3b) with Junior's verbatim when it arrives, and
    the reconciliation of the "PREMIUM v22" label with the cycle name (preface 3a).
[ ] AGENTS.md "Current cycle" section REPLACED: v22 OPEN (one cycle lives in this file; the v20/v21
    state text moves to `drafts/_v21-record-<date>.md` with the pointers it carried). Lanes listed with
    their classes (SIM-class one gated piece at a time; presentation lanes name their wall re-pin cost).
    [MERGE s130] Carry into the v21 record: the WB-T6 close pointer and the MAP_EDITING 4.1-4.5 laws
    (one line each; the docs stay the source).
[ ] `docs/CHECKPOINT.md` session entry (hashes AFTER push), CLAIMED -> none, es-CR + pt-br summary
    lines for both peers, Junior's async ratification asks listed (RATIFIED-J pending).
    [MERGE s130] RATIFIED-J asks to list: the art-lane fork (Option 1 vs 2), the cycle-name line,
    his AfterSave pre-flight (`where python` / `where ruby`), the .pyc untracking notice.
[ ] All pushes done; `git status` clean except tmp/. Nothing under `src/`, `data/`, `harness/` changed.

## 3. Session flow

0. Orient. `fleet`: if a LIVE game-two session (the WB-T6 dev of record) still holds the seat, do NOT
   write into the tree -- draft in `C:/Users/gabri/sparkups/v22/` and tell the owner in one line that
   landing waits for that session to close (he closes its window once it reports DONE / DONE-PENDING-GUI);
   never `/seat take` over a working session. `git pull`, `git status`, HEAD; CHECKPOINT top (CLAIMED
   must be none or WB-T6-closed); read AGENTS.md cycle section + the v20 foundation (shape) + the
   NINETEENTH verdict section h + Evidence packs A and B (sections listed, not whole files).
   Write CLAIMED: `CLAIMED: v22 GRILL (foundation+spec+art charter) <hash> (s<N>, date)`; open the
   foundation file with UNCHECKED placeholders (record-first; never pre-fill numbers as decided).
   [MERGE s130] Also: `git fetch` and READ Junior's commits since `d722d7e` (`git log --author=junior
   d722d7e..origin/main`) plus any new `drafts/_junior-*` or `drafts/_premium-art/*` before the grill
   -- his direction is a peer's, not a fact to route around. Kick off the fresh tour DETACHED at
   orient (`harness/make_tour.sh`, ~10 min; never under a bash-call timeout) so it is ready by Q9.
1. Rule 1 in the foundation (10-15 lines): the 2-3 biggest risks + chosen approach. Expected:
   (a) SAVE SCHEMA -- insurance count / lifetime-progress facts change `FACT_KEYS` (exact-match law,
   save_state.rb) -> schema 3 + one-hop upgrade (P8 precedent v1->v2); L9: the live chains are NEVER
   the guinea pig -- migration proven on COPIES (`saves/*.bak-*` exist on this machine; Junior's chain
   by his copy); (b) a fine that lands on a party game -- who pays on a wipe vs a single body's death,
   and how a joiner's seat is charged (lockstep identity: both seats compute identical facts);
   (c) LEGIBILITY -- the pipeline proved money is invisible; a price nobody can read is not a price.
   The death moment must be SHOWN (a death ledger: what was lost, what insurance saved) -- a Rule 2
   visual surface with its own gate row and wall cost; (d) scope creep toward items -- the grill asks
   ONCE whether minimal drops-with-identity promote into v22 or park for v23; the dev recommends PARK
   (one SIM piece per cycle law) and records the owner's word either way.
   [MERGE s130] (e) TWO ART DIRECTIONS IN FLIGHT -- Junior's engine-side dual-grid (shipped) vs the
   brief's LDtk-bakes path (recommended, unbuilt): a lane that builds both wastes a wall re-pin; the
   grill must leave ONE integration path chosen or explicitly staged (e.g. engine dual-grid for
   ground, LDtk rules for decoration), with Junior's ratification named as the gate.
2. THE GRILL (owner live; sensei mode: every question carries the dev's recommendation + touchstone;
   one question at a time; stop when answers stop changing the design; target 8-12 questions, <=45
   min). Minimum set:
   Q1 What dies: single body death (possession moves) vs pack wipe -- what event carries the price?
      Rec: the WIPE carries the fine (the party game's failure); a single death costs the corpse-run/
      respawn time it already costs (B4 mercy floor stays).
   Q2 What is lost: XP only (two-regime per the shelf) vs XP + banked coin fraction. Rec: XP fine with a
      protected band (levels 1-5 flat 10% of progress-to-next; above, formula through Progression);
      banked coin untouched (the bank is the safe place -- the shelf's "insured banked progress" rule).
   Q3 Can you de-level? Rec: NEVER uninsured (destroy in-flight progress only); insured runs may dip
      below the threshold ONLY if the owner wants Tibia's absolute-cost signature -- his call.
   Q4 Insurance: bought where, priced how, how many stack, consumed all-at-once on death? Rec: bought at
      the bank station (same UI as potions), N=3 stackable, 8% each additive, all consumed on the
      priced event; price rides the level (k re-price table via `tools/pacing_table.rb`).
   Q5 The read: what the player SEES at the priced moment. Rec: a death ledger card (placeholder
      register: "WIPE -- XP LOST 128 -- INSURANCE SAVED 41") + the bank shows insurance count as a HUD
      pip; both Rule 2 surfaces.
   Q6 Coop: who pays. Rec: the wipe fine applies to the shared progression identically on both seats
      (facts are host-authoritative; joiner sees the same ledger); no per-seat asymmetry in v22.
   Q7 Items: promote minimal drops-with-identity now or v23? (see Rule 1 d).
   Q8 The TWENTIETH fun-verify: delta-triggered -- the priced death IS the delta; pre-register the rows
      now (deaths, wipes, xp_lost, insured_wipes, insurance_bought/consumed, time-to-continue) and the
      free-verdict questions' shape (byte-identical re-asks of the A/B growth question + one new
      "did the descent feel like it cost something" instrument). Freeze arms at DECLARATION only.
   [MERGE s130] Q8b Floors as player-visible truth: if A3's banner shows the floor ("ZONE 5 . -3"),
      the 8 LEGACY rows in `authoring/world_graph_allowlist.json` become visible contradictions (HUB 1
      at 0 with a plain door into floor -2; ZONE 1 and ZONE 4 at the default 0 between -1/-2/-3
      neighbours). Rec: assign floors to nest (-1) and slow_door (-2 or -3, owner picks) in their
      hand-authored JSON and retype or remove the camp east door -- a Lane-F row inside v22's
      presentation lane, Rule 2 + canary, each fixed row removed from the allowlist. Owner's word
      recorded either way; Junior ratifies async (his floors).
   Q9-Q11 = the ART LANE direction questions (section 5) -- ask them in this grill, verbatim answers
   into the charter.
   [MERGE s130] Q9a (before Q9, after the fresh tour renders): the owner watches the NEW tour (Junior's
      drawn characters + dual-grid tiles) and says in one line whether "sloppy, not revised by the
      assets seat" still holds -- that line is the art lane's baseline verdict, verbatim.
   Optional: Q12 totem COEXISTENCE word (keep free / re-price / retire) -- owner-pending, one line.
3. Write the foundation: ledger rows from the answers; every number a CANDIDATE with its shelf citation
   and its data path; interlocks named (wipe/respawn + B4 knob, provisions, toll/breached seals, banked,
   home_zone, save schema, netplay facts, telemetry oracle wording); presentation surfaces named with
   their wall cost; debt ledger. Then the council pass (section 2), amendments adopted/rejected with
   reasons, RATIFIED-G: the owner's ratification words verbatim per row that changes the sim.
4. Cut the spec + tickets (grill-and-ticket skill; read it). Serial SIM tickets one gated piece each,
   e.g.: T0 MUNDO VIVO fresh-eyes review | T1 `data/balance/death.json` + Progression fine math +
   tests (pure, no surfaces) | T2 save schema 3 + migration on copies + `--fresh` law | T3 insurance
   at the bank (buy verb, HUD pip, telemetry) | T4 the death ledger card (Rule 2 gate row + wall
   re-pin priced) | T5 coop parity gate (netplay scene) | T6 TWENTIETH declaration protocol doc.
   Each ticket: files touched, laws bound (line caps -- world.rb extraction rides the first material
   touch; events registered; zero constants), gate(s), DoD checklist, fences, CLAIMED shape.
   [MERGE s130] Add the WB column: WB-T7 spawn GUI-safety (above) and, gated on Q9-Q11 + the fork
   decision, the S4 tileset/rules spike as the art lane's A2 ticket (its DoD from the gamesmith brief
   section 4, plus MAP_EDITING 4.4-4.5: `autoLayerTiles: null` bake law, every IntGrid value
   declared in the def, GUI saves only through the AfterSave loop).
5. Replace the AGENTS.md cycle section (v22 OPEN; lanes: A death economy (SIM) | B insurance + bank
   surfaces | C death ledger read (presentation) | D ART LANE (presentation, wall re-pin priced; owner-
   directed) | E debts | G TWENTIETH), move v20/v21 state to the record draft, checkpoint, push.
   [MERGE s130] Lane D's text names Junior's shipped art as its starting state, not as a debt.

## 4. Laws that bind the design (restate in the foundation; do not soften)

- Data-driven: every tunable in `data/balance/death.json` (and the k re-price table); ZERO constants
  in code. Math through the live `Progression` object (delta_e, level_cap) -- the P3 clamp precedent.
- Save-chain law L9: schema bump = one-hop upgrade + backup-before-first-write + strict decoder refusal
  NAMED; proven on copies of BOTH peers' chains before any live launch; `--fresh` backup law intact.
- SIM-class one gated piece at a time; the TWENTIETH fun-verify is delta-triggered (declaration arms
  the freeze; <=48 h window target; bot logs never fun evidence).
- Rule 2 for every new surface (death ledger card, insurance pip, bank rows) -- gate rows + the wall
  re-pin named as ticket cost; language critique on the placeholder strings (accuracy vs presentation).
- Placeholders only (no lore): "INSURANCE", "WIPE", "XP LOST", locale strings en/es/pt-br via
  `data/strings/*.json`.
- Line caps: `window.rb` <= 300 (269 now), `world.rb` <= 1800 (1767 now) -- the first material touch
  owes the extraction; events whitelisted in `EventBus::EVENTS` (define at first use).
- Coop: lockstep identity -- both seats compute identical facts; handshake fingerprint covers the new
  data file by construction (data digest) -- verify, do not assume.
- [MERGE s130] LDtk laws (docs/MAP_EDITING.md 4.1-4.5): pilot.ldtk canonical at every commit
  (`--check` in the suite); GUI saves only through the AfterSave loop; every IntGrid value declared in
  the Terrain def; the five out-of-bounds `spawn` transitions untouched in the GUI until WB-T7;
  `autoLayerTiles: null` for rule-bearing builder levels.

## 5. THE ART LANE (owner order, same breath as the approval -- chartered here, executed by its own
##    sessions; NOT dropped if the grill runs long: the charter + staged spark are DoD items)

Why: the owner's read ("better but sloppy, like it was not revised by the assets seat") + pipeline
findings 1-4 and 7. The look is procedural placeholders (tools/gen_placeholder_art.py: "the pipeline
proof, not the art") over v1 flat quads; three visual grammars on one screen; and the least legible
language carries the most important information (party HP, loot, money, depth). Direction: "use the
power of LDtk and Aseprite for a more modern and original look" (owner). Legibility first, palette
second -- the two are one pass.
[MERGE s130] State change since this paragraph was written: Junior's PREMIUM v22 replaced the
placeholder shapes with procedurally DRAWN characters (`tools/gen_premium_art.py`) and the flat
quads with dual-grid material tiles (`App::Tileset`). The look is no longer "placeholders over
quads"; whether it is "modern and original" is exactly Q9a. The lane's premise becomes: unify what
Junior shipped with a legibility grammar and an authored (Aseprite/LDtk) source of truth -- not
start over.

Ask the owner (Q9-Q11, verbatim answers into the charter):
  Q9  References: 3-5 games/artists whose LOOK he wants us near (and 2 he wants us far from). No
      lore, no names in-game -- this is pixels and palette only.
  Q10 Palette + mood: warm/cold, saturation, how dark the descent gets, one accent color for danger,
      one for reward. Pixel density: tiles stay 32 px with integer scaling (the shelf: nearest-neighbor
      + integer scale only -- `pixel-art-scaling-and-spritesheet-workflows.md` sections 2-3).
  Q11 Who draws: Gabriel in Aseprite (the FASE 1 atlas contract was written "pra arte do Gabriel
      encaixar depois"), the assets seat, or an AI-assisted pipeline (`ai-sprite-pixel-art-pipeline-2026.md`
      in the KB; frame-consistency law: no diffusion on animation frames without a cleanup pass).
  [MERGE s130] Q11b Where do TILES get authored: keep Junior's procedural `gen_tileset.py` textures as
      the source (Option 2, engine autotiles) or move to an authored LDtk tileset + rules (Option 1,
      brief 3.7) -- or stage: engine dual-grid for ground/liquids now, LDtk rules for edges/props/
      biomes later. Rec: do not decide against Junior in his absence -- record the owner's lean, mail
      Junior the fork with the brief's table, ratify async.

Charter rows (dev proposal, owner ratifies):
  [MERGE s130] A0 (precondition, code ticket WB-T7): cross-zone `spawn` GUI-safety. Until it lands,
     GUI sessions on pilot.ldtk may edit terrain and defs but never the five out-of-bounds transitions;
     every GUI save goes through the AfterSave loop (refusals are visible) and `--semantic-diff` BY
     SHAPE is read before committing.
  A1 Aseprite -> atlas pipeline: `aseprite -b <kit>.aseprite --sheet ... --data ... --sheet-type
     packed` (shelf section 6.2) into the EXISTING `data/art/manifest.json` contract (32x32 frames,
     facings x anims grid, md5 test-pinned) -- same grid, new PNG, zero code. Deterministic export
     script, sources under `art/aseprite/` (tracked), CI check = manifest md5 matches export.
     [MERGE s130] Verify the contract FIRST: `03259d0` rewrote `data/art/manifest.json` (32x48 frames,
     anchor 2,14, 16 columns) -- the "32x32 frames" above is stale; read the live manifest and
     `src/app/renderer.rb` before writing A1's numbers.
  A2 LDtk tileset + auto-layer RULES over Terrain (gamesmith brief `docs/ldtk-research-brief-2026-09-05.md`
     sections 3.7-3.8; the bake law: `autoLayerTiles: null` re-bakes on open, `[]` does not) = the S4
     spark, sequenced AFTER WB-T6 lands; importer gains tile-variant passthrough as a SAFE tile behavior
     (decorative variants ship freely per AGENTS). Wall/floor/water edge grammar from ONE tileset.
     [MERGE s130] WB-T6 has landed (the S0 precondition is met: normalizer + AfterSave loop live). A2 is
     now CONDITIONAL on Q11b -- if Option 2 stays, A2 shrinks to "LDtk as the authoring view of the
     same materials" (entity icons via the embedded LdtkIcons atlas, IntGrid value colors matching
     the game palette, the S1 leftovers) and the rules spike is parked with its trigger recorded.
  A3 Legibility spec (uiux seat, by mail, take-or-leave): party HUD that reads as three bodies + the
     possessed one; reward/economy glyph family (drop glyph, coin glyph on toll/bank pop-ups); depth
     affordances (floor number in the banner e.g. "ZONE 5 . -3", down/up glyphs on holes/stairs/ropes);
     banner-occlusion window at hostile-adjacent arrivals. Evidence pack = pipeline obs-ids + tour frames.
     [MERGE s130] Interlock: the floor-in-banner affordance requires Q8b's floor decisions FIRST --
     shipping "ZONE 4 . 0" between floors -2 and -3 would teach the player a lie.
  A4 Integration: ONE wall re-pin for the whole pass (priced once, ~3 h detached), Rule 2 gate rows
     rewritten where the surface moved (hurt flash, kits distinct, boss identification laws keep their
     color truth), vision critique against a KB-derived rubric (`hub kb query --domain uiux-design` +
     `art-fundamentals`), council taste pass (Claude's visual priors are template-flat).
     [MERGE s130] Junior already re-pinned `world_loop` for PREMIUM v22 (`1ac9e9e`, `7189be7`); the
     rest of the wall is at the v21 pins -- name the CURRENT pin state per script in the charter
     before pricing "one re-pin".
  A5 Sequencing vs the death cycle: A3's death-ledger card and insurance pip are v22 T3/T4 surfaces --
     design them ONCE in the new grammar, not twice. Everything else in the art lane rides its own
     sessions and never blocks the SIM tickets.
Deliverables of THIS session for the lane: the charter + `docs/sparkups/sparkup-art-lane-<date>.md`
(a spark for the art-direction session: Q9-Q11 answers inlined, A1-A5 as its ticket list, seats named,
wall cost named, fences: no lore, integer scale only, atlas contract unchanged).
[MERGE s130] Plus A0/WB-T7 as the first ticket in that spark's list, and a mail to Junior's seat with
the fork (Option 1 / Option 2 / staged) and the cycle-name question, RECEIPT requested.

## 6. Fences and stop conditions

- This session changes NO code and NO data: foundation, spec, tickets, charter, sparkups, AGENTS cycle
  section, checkpoint only. If a "quick fix" tempts you, it is a ticket.
- Never hand-edit `authoring/pilot.ldtk` or `data/zones/**`; never touch WB-T6's files if it is still
  open; never `/seat take` over a live working session.
- Money: council <= ~$2 (declare); no headless fan-out needed; if you spawn one, pass `--model` to a
  cheaper tier for mechanical lanes and declare from `~/.pi/agent/models.json` rates.
- Context headroom: read the SECTIONS named, not whole files; silent-on-pass tool output; if the limit
  nears, checkpoint the foundation to disk first (compact-checkpoint), then continue.
- Any gate refusal (hooks, seat-lease, rules-gate) is policy: state blast radius, ask; never route around.
- [MERGE s130] The fresh tour is the ONE allowed non-doc action (it writes under tmp/ and Videos/,
  never the repo); run it detached, never under a bash-call timeout; it needs no live seat conflict
  check beyond `tasklist` for ruby.exe (a running wall/gate would fight it for the GL context).
- [MERGE s130] Junior may push during the session (he did 3x during WB-T6): `git fetch` before every
  push, rebase, and never rewrite his files; on any overlap in AGENTS.md's cycle section, his text is
  read before yours is written.

## 7. Register

Working language English; the foundation, spec and checkpoint are read by both peers (Gabriel es-CR,
Junior pt-br) -- define each term of art once, cite files by path:section, keep every claim
evidence-backed, and never present a shelf number as decided until the owner's word is on the row.
Close with the two peer lines (es-CR, pt-br) and one "For next time" if earned.
