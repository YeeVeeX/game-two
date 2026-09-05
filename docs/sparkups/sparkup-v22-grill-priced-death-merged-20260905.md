# Spark-up -- game-two session: v22 GRILL "THE PRICED DEATH" + contract hygiene + art lane charter

Single-session launch: Phase 0 = mechanical housekeeping (AGENTS diet, pin ledger, stale-number
fix, gate-checks audit -- code+docs, ~45 min); Phase 1 = the owner-live grill + design deliverables
(foundation, spec, tickets, art charter -- docs only, ~60 min). Phase 0 commits and pushes BEFORE
Phase 1 starts so the grill writes to the new file structure.

## 0. Provenance (owner words, verbatim, game-two hub chat 2026-09-05)

- "what is our game lacking to be competetitive against our inspiration/influence games such as
  Tibia, Ultima or Oldschool Runescape?"
  Hub answer (grounded in KB + gamesmith synthesis): the genre's spine is PRICED LOSS. game-two has
  (1) no price on death, (2) nothing to invest in beyond a level number, (3) no reward vocabulary.
  Order: v22 = the priced death; then a minimal item layer; then goals; legibility underneath.
- "Approved, proceed to design the next session spark-up prompt with clear directions, guidelines
  and instructions as you consider optimal for maximum quality results (quality over cost),
  clipboard it for me so I can start the fresh new session with focused context headroom.
  But still keep an eye on better art since we are stuck in a very dated look and we need our game
  to use the power of LDtk and Aseprite for a more modern and original look"
- "I kinda looks better but sloppy, like it was not revised by the assets seat" (watching the tour)
- "cost is not a concern, quality over cost if its inside AWS" (standing spend word)
- "for next session combine whenever stays pending or recommended from this session" (s130 close)
- "merge everything as you consider optimal so it launches all with clear logistics from the next
  session on, I don't want to be juggling different sessions or prompts, you do it all for me"

## 1. Ground truth (read these SECTIONS at orient, cite by path -- do not re-derive)

| Source | What to read | Where |
|---|---|---|
| Repo state | HEAD, `git status`, CHECKPOINT top (CLAIMED must be none) | `docs/CHECKPOINT.md` top |
| v20 foundation (SHAPE precedent for the v22 foundation) | the ledger row format, interlocks, ratification shape | `drafts/_v20-foundation-20260828.md` |
| NINETEENTH verdict | section h: (1) vertical legibility (2) growth not felt 10-13 (3) objective vacuum (4) C3 third-body debt -- all named for this grill | `drafts/_v20-fun-verify-verdict-20260904.md` |
| Evidence pack A: tour footage critique | `notes/notes-en.md`, `feel/observations.json`, `mechanics/observations.json`; extract `../../extract/*.md` | `C:/Users/gabri/workspace/gamesmith/artifacts/games/game-two/recordings/tour-20260905/` |
| Evidence pack B: death penalty shelf | section "6. For game-two" | `C:/Users/gabri/Obsidian-Vault/03-Resources/game-research/death-penalties-stat-scaling-and-progression-balance.md` |
| Tibia mechanics | sections 2.3 (death penalty), 4.4 (blessings), 7.1 (meaningful death = meaningful life), 7.6 (infinite progression without power creep) | `.../tibia-mechanics-lore-and-virtual-world.md` |
| Consumable economies | section "For game-two" | `.../crafting-loot-and-consumable-economies.md` |
| XP curves | our curve k=40, cap 21 -- fine computed through live Progression, never re-derived | `.../rpg-xp-curves-and-leveling-formulas.md` |
| Genre DNA synthesis | H1-H4 + earned A/B; the Tibia fork and the OSRS fork | `C:/Users/gabri/workspace/gamesmith/artifacts/synthesis/genre-dna.md` |
| LDtk research brief | sections 3.5 (EntityRef), 3.7 table (Option 1 vs 2), 4 (spike order) | `C:/Users/gabri/workspace/gamesmith/docs/ldtk-research-brief-2026-09-05.md` |
| MAP_EDITING LDtk laws | sections 4.1-4.5 (normalizer, AfterSave, ergonomics, auto-layer bake, GUI-safety) | `docs/MAP_EDITING.md` |
| WB-T6 record | section 5 (follow-ons: WB-T7, LEGACY floors, entity icons, Junior pre-flight) | `drafts/_wb-t6-ldtk-foundation-20260905.md` |

**Key state facts** (verify live, do not assume):
- WB-T6 is CLOSED DONE (s130). `main` >= `b136652`. The seat should be FREE (`fleet`).
- Junior shipped "PREMIUM v22" art: `03259d0` drawn characters (32x48 frames, 20 kits, procedural
  Python) + `7189be7` dual-grid material tiles (engine-side autotiles = the brief's Option 2, NOT
  Option 1 "LDtk bakes") + `1ac9e9e` gate verdicts + `58e6153` possession halo/chevron. He may
  have pushed more since -- `git fetch` and `git log --author=junior d722d7e..origin/main` first.
  No plan doc or CHECKPOINT entry yet. His commits lack a fresh-eyes review (Rule 6).
- Evidence pack A (the tour) was rendered BEFORE Junior's art. Findings 1-3, 5, 7, 8 (HUD, loot
  glyphs, economy, damage source, density, goals) are about surfaces he did not touch and stand.
  Findings 4, 6 (vertical read, fire-dungeon decor) must be re-checked on a fresh tour of HEAD.
- Two naming collisions for the grill to settle in one line each: (a) the hub's v22 = "THE PRICED
  DEATH" vs Junior's "PREMIUM v22" = an art wave; (b) the art lane's A2 premise (LDtk tileset +
  rules) vs Junior's shipped engine-side dual-grid. Neither is pre-decided.
- AGENTS.md is 31KB (11KB = a stale "v20 OPEN" cycle section); wall has 42 scripts (docs say ~35);
  manifest is 32x48 frames (docs say 32x32). Phase 0 fixes these.
- Debts to bank in the foundation's ledger (do not solve here): MUNDO VIVO + PREMIUM v22 unreviewed;
  `world.rb` 1767/1800; `vat_economy` 2 rows + `aoe_specials challenge_reads` re-author; totem
  COEXISTENCE owner word; D1-D9 / swap-spec / city proposal ratifications (Junior's cycle); WB-T7
  cross-zone spawn GUI-safety; 8 LEGACY floor-delta allowlist rows.
- OUT of scope (AGENTS standing): items/equipment, >2 players, chat, character creation, in-game
  teleport/map, lore (placeholders only -- the art lane changes pixels, never names).

## 2. Session flow

### Step 0: Orient (~10 min)

`fleet` (seat must be FREE) -> `git pull` -> `git status` -> HEAD -> CHECKPOINT top -> read AGENTS
cycle section + the files in the table above (SECTIONS, not whole files). Read Junior's commits
since `d722d7e` plus any `drafts/_junior-*` or `drafts/_premium-art/*`. Write CLAIMED line. Open
the foundation file with UNCHECKED placeholders (record-first; never pre-fill). Kick off the fresh
tour DETACHED at orient (`harness/make_tour.sh`, ~10 min; never under a bash-call timeout) so it is
ready by Q9 -- it writes under tmp/ and Videos/, no seat conflict.

### Step 1: Phase 0 -- contract hygiene (~45 min, code+docs, commit+push before the grill)

The harness gates work; what costs time is state that lives only in prose. Four items, one commit
batch, suite green via hooks:

**P0-A. AGENTS.md diet.** Extract the ~11KB "Current cycle" section to `docs/CYCLE.md` (replaced
each cycle, like the foundation). AGENTS.md shrinks to ~15-20KB: the invariants, commands, layout,
environment, and a 3-line cycle pointer (`## Current cycle -- see docs/CYCLE.md`). `docs/CYCLE.md`
starts with a one-paragraph "v21 closed; v22 GRILL in progress" stub that Phase 1 step 5 replaces
with the real v22 content. The v20/v21 narrative moves to `drafts/_v21-record-<date>.md`. Carry the
WB-T6 close pointer and MAP_EDITING 4.1-4.5 laws (one line each; the docs stay the source).

**P0-B. `rake pins` + `harness/pins.json`.** A generated ledger: per wall script, the last-pinned
commit, date, and verdict. Implementation: `harness/run_wall.sh` already logs per-script rc to
`tmp/wall/<tag>/`; at the end of a sweep, it appends to `harness/pins.json` (one entry per script:
`{script, tag, commit, date, rc}`). `rake pins` reads this file and cross-references with
`git log --since=<oldest_pin_date> -- src/app src/game data/` to list scripts whose pin predates
a code change to their render path. First run: start with an EMPTY `harness/pins.json` (`[]`) and
let the next wall sweep populate it; until then the task prints "no pins recorded yet". Test: the
Rakefile task exists, loads the JSON, and does not crash on `[]`. ~80-120 lines Ruby + Rakefile.

**P0-C. Stale-number fix.** One-time grep-and-fix of the three factual claims that drifted:
"~35 scripts" -> 42 (in `docs/MAP_EDITING.md`); "32x32 frames" in art-lane references -> verify
the live `data/art/manifest.json` and cite the actual frame size; the "v20 OPEN" heading in
AGENTS.md (handled by P0-A's extraction). Rule to record in AGENTS or MAP_EDITING: a prose number
that can be computed from a file must be computed or pointed at, not hardcoded.

**P0-D. Gate-checks surface audit test.** `test/harness/gate_checks_audit_test.rb`: every check
row in `harness/gate_checks.json` that names a zone or surface has at least one wall script
(`harness/scripts/*.json`) that stages it; every wall script's `start.zone` appears in a check's
scope. Same class as the IntGrid-values trap (two sources that must agree but no test binding them).
~40-60 lines Ruby, no mocks.

Commit message shape: `chore: contract hygiene (v22 prep) -- AGENTS diet to docs/CYCLE.md, rake
pins ledger, stale-number fix, gate-checks audit test`. Push before proceeding to Phase 1.

### Step 2: Rule 1 in the foundation (10-15 lines, written BEFORE the grill)

The 2-3 biggest risks + chosen approach:
(a) SAVE SCHEMA -- insurance count / lifetime-progress facts change `FACT_KEYS` (exact-match law,
    save_state.rb) -> schema 3 + one-hop upgrade (P8 precedent v1->v2); L9: live chains are NEVER
    the guinea pig -- migration proven on COPIES.
(b) A fine that lands on a PARTY game -- who pays on a wipe vs a single body's death, how a
    joiner's seat is charged (lockstep identity: both seats compute identical facts).
(c) LEGIBILITY -- the pipeline proved money is invisible; a price nobody reads is not a price. The
    death moment must be SHOWN (a death ledger card) -- a Rule 2 surface with its own gate row.
(d) Scope creep toward items -- ask ONCE (Q7), dev recommends PARK (one SIM piece per cycle law).
(e) TWO ART DIRECTIONS IN FLIGHT -- Junior's engine-side dual-grid (shipped) vs the brief's
    LDtk-bakes path (recommended, unbuilt). Building both wastes a wall re-pin; the grill leaves
    ONE path chosen or explicitly staged, with Junior's ratification as the gate.

### Step 3: Phase 1 -- THE GRILL (owner live, ~45-60 min)

Sensei mode: every question carries the dev's recommendation + touchstone; one question at a time;
stop when answers stop changing the design; target 8-12 questions.

**Death economy:**
Q1 What dies: single body death (possession moves) vs pack wipe -- what carries the price?
   Rec: the WIPE (the party game's failure); a single death costs the corpse-run it already costs.
Q2 What is lost: XP only (two-regime per the shelf) vs XP + banked coin fraction.
   Rec: XP fine with a protected band (levels 1-5 flat 10% progress-to-next; above, formula through
   Progression); banked coin untouched (the bank is the safe place -- shelf "insured banked" rule).
Q3 Can you de-level? Rec: NEVER uninsured (destroy in-flight progress only); insured may dip below
   ONLY if the owner wants Tibia's absolute-cost signature -- his call.
Q4 Insurance: bought where, priced how, stack, consumed how?
   Rec: bought at bank (same UI as potions), N=3 stackable, 8% each additive, all consumed on the
   priced event; price rides the level (k re-price table via `tools/pacing_table.rb`).
Q5 The read: what the player SEES at the priced moment.
   Rec: a death ledger card ("WIPE -- XP LOST 128 -- INSURANCE SAVED 41") + bank shows insurance
   count as a HUD pip; both Rule 2 surfaces.
Q6 Coop: who pays. Rec: wipe fine on shared progression identically on both seats (host-
   authoritative facts; joiner sees the same ledger); no per-seat asymmetry in v22.
Q7 Items: promote minimal drops-with-identity now or v23? Rec: PARK (one SIM piece per cycle).

**Verification + floors:**
Q8 The TWENTIETH fun-verify: delta-triggered -- the priced death IS the delta. Pre-register rows
   (deaths, wipes, xp_lost, insured_wipes, insurance_bought/consumed, time-to-continue) and the
   free-verdict shape (re-ask A/B growth + "did the descent cost something"). Arms at declaration.
Q8b Floors as player-visible truth: if A3's banner shows the floor ("ZONE 5 . -3"), the 8 LEGACY
   rows in `authoring/world_graph_allowlist.json` become visible lies (HUB 1 at 0 with a plain door
   into floor -2; ZONE 1 and ZONE 4 at default 0 between -1/-2/-3 neighbours). Rec: assign floors
   to nest (-1) and slow_door (-2 or -3, owner picks) in their hand-authored JSON and retype/remove
   the camp east door -- a lane-F row inside v22's presentation lane, Rule 2 + canary. Each fixed
   row removed from the allowlist (suite forces it). Junior ratifies async (his floors).

**Art lane direction (ask AFTER the fresh tour renders -- Q9a first):**
Q9a Owner watches the NEW tour (Junior's drawn characters + dual-grid tiles) and says in one line
   whether "sloppy, not revised by the assets seat" still holds. That line = the art lane's baseline.
Q9 References: 3-5 games/artists whose LOOK he wants near (and 2 far from). Pixels + palette only.
Q10 Palette + mood: warm/cold, saturation, descent darkness, danger accent, reward accent. Tiles
   stay 32 px with integer scaling (nearest-neighbor + integer only -- the KB shelf).
Q11 Who draws: Gabriel in Aseprite, the assets seat, or an AI-assisted pipeline (KB
   `ai-sprite-pixel-art-pipeline-2026.md`; frame-consistency law: no diffusion on anim frames
   without cleanup).
Q11b Where do TILES get authored: keep Junior's procedural `gen_tileset.py` (Option 2, engine
   autotiles) or move to LDtk tileset + rules (Option 1, brief 3.7) -- or stage: engine dual-grid
   for ground/liquids now, LDtk rules for edges/props/biomes later. Rec: do not decide against
   Junior in his absence -- record the owner's lean, mail Junior the fork with the brief's table
   (section 3.7), ratify async.

**Optional:**
Q12 Totem COEXISTENCE word (keep free / re-price / retire) -- owner-pending, one line.

### Step 4: Write foundation + council + spec/tickets + art charter (~30-45 min)

**Foundation** (`drafts/_v22-foundation-<date>.md`): ledger rows from the answers (L1..Ln); every
number a CANDIDATE with its shelf citation and data path (`data/balance/death.json`); interlocks
(wipe/respawn + B4 knob, provisions, toll/breached seals, banked, home_zone, save schema, netplay
facts, telemetry oracle wording); presentation surfaces with wall cost; debt ledger. Shape
precedent: `drafts/_v20-foundation-20260828.md`.

**Council** (budget <= ~$2): adversarial pass over the FULL foundation inlined (deepseek + kimi,
one round each; starved reviewers fabricate -- inline everything; split >32K argv). Every REFUTED
item re-verified, never deleted. Amendments adopted/rejected with reasons in the foundation.

**RATIFIED-G**: owner's ratification words verbatim per row that changes the sim.

**Spec + tickets** (`docs/superpowers/specs/<date>-v22-priced-death-cycle.md`): serial SIM tickets,
one gated piece each (grill-and-ticket skill; read it before cutting). Suggested shape:
  T0 MUNDO VIVO + PREMIUM v22 fresh-eyes review (headless/council over
     `restore/pre-mundo-vivo-20260904..HEAD`, findings banked, NOT a revert vehicle)
  T1 `data/balance/death.json` + Progression fine math + tests (pure, no surfaces)
  T2 save schema 3 + migration on copies + `--fresh` law
  T3 insurance at the bank (buy verb, HUD pip, telemetry)
  T4 death ledger card (Rule 2 gate row + wall re-pin priced)
  T5 coop parity gate (netplay scene)
  T6 TWENTIETH declaration protocol doc
  WB-T7 cross-zone spawn GUI-safety (EntityRef `allowOutOfLevelRef` or String "x,y"; importer
     `field_value` + builders + fixture re-pin; emissions byte-identical) -- before any art-lane
     GUI session on pilot.ldtk
  WB-T8+ art-lane tickets gated on Q9-Q11 + the Option 1/2 fork decision
Each ticket: files touched, laws, gates, DoD, fences, CLAIMED shape.

**Art lane charter** (`drafts/_v22-art-lane-charter-<date>.md`): Q9-Q11 answers verbatim + rows:
  A0 (precondition, WB-T7): cross-zone `spawn` GUI-safety. Until it lands, GUI sessions on
     pilot.ldtk may edit terrain and defs but never the 5 out-of-bounds transitions; every GUI save
     through the AfterSave loop; `--semantic-diff` BY SHAPE before committing.
  A1 Aseprite -> atlas pipeline: deterministic export into the EXISTING `data/art/manifest.json`
     contract (verify the LIVE frame size + anchor from the manifest FIRST -- `03259d0` changed it).
     Sources under `art/aseprite/` (tracked); CI = manifest md5 matches export.
  A2 LDtk tileset + auto-layer rules (brief 3.7-3.8; S4 spark): CONDITIONAL on Q11b. If Option 2
     stays, A2 shrinks to "LDtk as the authoring view" (entity icons, IntGrid colors, S1 leftovers)
     and the rules spike parks with its trigger. If Option 1, the S4 spike's DoD (brief section 4).
     Either way: `autoLayerTiles: null` bake law (MAP_EDITING 4.4), every IntGrid value declared in
     the def (MAP_EDITING 4.5), GUI saves only through the AfterSave loop.
  A3 Legibility spec (uiux seat, by mail): party HUD as 3 bodies + possessed; reward/economy
     glyphs; depth affordances (floor in banner "ZONE 5 . -3" -- gated on Q8b's floor decisions);
     banner-occlusion window. Evidence = pipeline obs-ids + tour frames.
  A4 Integration: ONE wall re-pin for the whole pass (~3 h detached). Junior already re-pinned
     `world_loop` for PREMIUM v22; name the CURRENT pin state per script (use `rake pins` from
     Phase 0) before pricing the re-pin. Rule 2 gate rows rewritten where surfaces moved.
  A5 Death-cycle surfaces (T3/T4): design the death ledger card and insurance pip ONCE in the new
     grammar. Everything else in the art lane rides its own sessions, never blocks SIM tickets.

**Art-lane sparkup** (`docs/sparkups/sparkup-art-lane-<date>.md`): Q9-Q11 answers inlined, A0-A5
as tickets, seats named, wall cost named, fences (no lore, integer scale, atlas contract verified).
Plus a mail to Junior's seat with the Option 1/2 fork + cycle-name question, RECEIPT requested.

### Step 5: Replace AGENTS cycle + checkpoint + close

Write `docs/CYCLE.md` with the real v22 content (lanes: A death economy SIM | B insurance + bank
surfaces | C death ledger read presentation | D ART LANE presentation, wall re-pin priced, owner-
directed | E debts | G TWENTIETH). AGENTS.md's 3-line pointer stays unchanged from Phase 0.

CHECKPOINT entry (hashes AFTER push), CLAIMED -> none. Include:
- es-CR summary line for Gabriel
- pt-br summary line for Junior
- RATIFIED-J async asks: art-lane fork (Option 1 vs 2), cycle-name line, AfterSave pre-flight
  (`where python` / `where ruby` in cmd), .pyc untracking notice (`735a37c`).

Push. `git status` clean except tmp/.

## 3. Definition of done

[ ] Phase 0 landed + pushed: AGENTS.md < 20KB with cycle pointer to `docs/CYCLE.md`; `rake pins`
    exists + `harness/pins.json` schema; stale numbers fixed; gate-checks audit test green
[ ] `drafts/_v22-foundation-<date>.md` with ledger rows, candidates, interlocks, debt ledger,
    council amendments, RATIFIED-G verbatims
[ ] Council pass recorded (deepseek + kimi, REFUTED items re-verified, <= ~$2)
[ ] `docs/superpowers/specs/<date>-v22-priced-death-cycle.md` + tickets T0..WB-T8+
[ ] `drafts/_v22-art-lane-charter-<date>.md` with Q9-Q11 verbatims + A0-A5 + Option 1/2 decision
[ ] Art-lane sparkup in `docs/sparkups/` ready for clipboard
[ ] `docs/CYCLE.md` carries the v22 lanes; AGENTS.md points at it; v20/v21 state in drafts/
[ ] CHECKPOINT entry with both-peer lines + RATIFIED-J asks; CLAIMED none; all pushed; clean tree

## 4. Laws that bind the design (restate in the foundation; do not soften)

- Data-driven: every tunable in `data/balance/death.json` + k re-price table; ZERO code constants.
  Math through the live Progression object (delta_e, level_cap) -- P3 clamp precedent.
- Save-chain L9: schema bump = one-hop upgrade + backup-before-first-write + strict decoder refusal
  NAMED; proven on copies of BOTH peers' chains; `--fresh` backup law intact.
- SIM-class one gated piece at a time; TWENTIETH fun-verify delta-triggered (declaration arms the
  freeze; <=48 h window; bot logs never fun evidence).
- Rule 2 for every new surface (ledger card, insurance pip, bank rows) -- gate rows + wall re-pin
  named as ticket cost; language critique on placeholder strings (accuracy vs presentation).
- Placeholders only (no lore): "INSURANCE", "WIPE", "XP LOST"; locale strings en/es/pt-br via
  `data/strings/*.json`.
- Line caps: window.rb <= 300, world.rb <= 1800 -- first material touch owes extraction; events
  whitelisted in EventBus::EVENTS (define at first use).
- Coop lockstep identity: both seats compute identical facts; handshake fingerprint covers new data
  files by construction (data digest) -- verify, do not assume.
- LDtk laws (MAP_EDITING 4.1-4.5): pilot.ldtk canonical at every commit; GUI saves through the
  AfterSave loop; every IntGrid value declared in the Terrain def; the 5 out-of-bounds spawn
  transitions untouched in the GUI until WB-T7; `autoLayerTiles: null` for rule-bearing builders.

## 5. Fences and stop conditions

- Phase 0 touches: tools/ (rake pins), test/harness/ (audit), docs/ (AGENTS diet, CYCLE.md,
  MAP_EDITING number fix), harness/ (pins.json schema), Rakefile. NOT src/, data/zones, data/balance.
- Phase 1 touches: drafts/, docs/ (spec, CYCLE, CHECKPOINT, sparkups), AGENTS.md (pointer only).
  NOT src/, data/, harness/ code. If a "quick fix" tempts you, it is a ticket.
- Never hand-edit `authoring/pilot.ldtk` or `data/zones/**`; never `/seat take` over a live session.
- Money: council <= ~$2 declared; no headless fan-out needed; if spawned, pass `--model` cheaper
  tier, declare from `~/.pi/agent/models.json` rates.
- The fresh tour is the ONE allowed non-doc action (writes under tmp/ and Videos/); run detached,
  never under a bash-call timeout; needs no seat conflict beyond `tasklist` for ruby.exe.
- Junior may push during the session: `git fetch` before every push, rebase, never rewrite his
  files; on AGENTS.md overlap, read his text before writing yours.
- Context headroom: read SECTIONS named, not whole files; silent-on-pass; checkpoint to disk before
  compacting (compact-checkpoint skill).
- Gate refusals are policy: state blast radius, ask; never route around.

## 6. Register

Working language English; the foundation, spec and checkpoint are read by both peers (Gabriel
es-CR, Junior pt-br). Define each term of art once, cite files by path:section, keep every claim
evidence-backed, never present a shelf number as decided until the owner's word is on the row.
Close with es-CR + pt-br peer lines and one "For next time" if earned.
