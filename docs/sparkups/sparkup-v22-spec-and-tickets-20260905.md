# Spark-up -- game-two session s133: v22 SPEC + TICKETS (server-ready), art charter, T0 review

Single fresh session, focused headroom. Order is fixed: (0) orient + harvest the two seat
spokes, (0b) ask the owner his open lines ONE AT A TIME in detail (his stated preference),
(1) spec + tickets cut on the RATIFIED foundation (council pass already done), (2) art charter
to the level the tour baseline allows, (3) T0 fresh-eyes review, (4) T1 only if headroom
remains and it is claimed first. Docs + review only until T1 is claimed: no src/ or data/
edits before that.

## 0. Provenance (owner words, verbatim, game-two hub chat)

- s131 (2026-09-05), on the pack vs one avatar: "the player is just a lonely wolf in the
  world, therefore needs to increase its power to survive alone or party up with others to
  overcome the obstacles, we can start migrating to a real MMORPG mechanics one step at a
  time" -> dev recommendation ONE BODY by staged subtraction -> "Approved". On the four design
  rows + companions PvE-only + program: "Approved but also merge Junior's ideas into the best
  product you can build and also orchestrate the ui/ux and assets seats".
- s132 (2026-09-05), asked where a dead player comes back in coop (the council found the
  one-zone engine makes "sends you home" impossible in coop): "decouple players, they should
  respawn on a temple or select their own place of respawn across the cities and points of
  interest of the world (don't overdo, follow a Tibia-like pattern), world should be
  persistant online as a server and each player writes their own story while they can also
  meet in the world and team up or fight against each other, trade, chat, etc" -> dev named
  the fork's cost and three options, recommended (a) = v22 ONE BODY built SERVER-READY now,
  v23 = ONE WORLD (the server fork) -> "Approved, proceed to design the next session spark-up
  prompt with clear directions, guidelines and instructions as you consider optimal for
  maximum quality results (quality over cost)".
- Standing: "cost is not a concern, quality over cost if its inside AWS"; "keep an eye on
  better art ... use the power of LDtk and Aseprite for a more modern and original look";
  pre-PREMIUM tour read: "it kinda looks better but sloppy, like it was not revised by the
  assets seat". Grid order (2026-08-29, recorded s132): "the grid in the game is less visible
  and each grid visually merged with each other ... so it looks more fluid but still holds
  the grid function".
- He asked (s132) to be walked through each open decision "sequentially in detail using
  /skill:human-facing-output for me to understand the context behind each decision and its
  impact" -- do that for every owner line this session needs (Step 0b).

## 1. Ground truth (read these SECTIONS at orient; cite by path; do not re-derive)

| Source | Read | Where |
|---|---|---|
| The LAW of the cycle (updated s132) | WHOLE file (~31KB): Terms, Rule 1 (a-f, c amended), L1-L20 (L18 ONE WORLD, L19 TEMPLES, L20 SERVER-READY laws), Lanes (A, B', C, D, E, F, G, H), Seats, Council (findings + reconciled disagreements), RATIFICATION (s131 + s132 verbatim, OPEN list) | `drafts/_v22-foundation-20260905.md` |
| Cycle state | whole file (short) | `docs/CYCLE.md` |
| Checkpoint | top entry (s132) + CLAIMED (must be none) | `docs/CHECKPOINT.md` |
| Seat-spokes triage + receipts | whole file; then the inbox | `drafts/_v22-seat-spokes-triage-20260905.md`; `~/.pi/agent/mail/game-two/inbox/from-uiux-a3-one-body-spec.md`, `from-assets-v22-art-direction.md` |
| Junior's ratification ask + his RECEIPTS (LANDED `195a01f`, harvested s132 into the foundation sec.RATIFICATION) | sec."RECEIPTS" (7 lines: pivot yes; tiles Option 2 now; floors nest -1 / slow_door -2 / camp east door removed; arena yes; pre-flight ok; .pyc noted; S1-S3 in v22's back half = HIS half of the both-seats line) | `drafts/_junior-v22-one-body-ask-20260905.md` |
| Junior's SYSTEMS proposal (v24 THE REWARD plan; one schema-3 hop shared with T1) | sec.1 data schemas, sec.4 save schema 3 + digest, sec.5 tickets S1-S7, sec.6 decisions P1-P5 | `drafts/_junior-premium-v22-systems-proposal-20260905.md` |
| Junior's MUNDO VIVO plan | sec.8 decisions D1-D9 (merged by L14) | `drafts/_junior-mundo-vivo-plan-20260905.md` |
| Previous spec shape (precedent) | one v20/v21 spec in the folder, skim for structure only | `docs/superpowers/specs/` |
| Code facts the spec cites (all verified s132) | `SaveState` SCHEMA=2, FACT_KEYS, MEMBER_KEYS (roster exact-match by index), `envelope_refusal` (schema 1 or 2), `upgrade_v1`, `apply!` pinned order + seat pointers (`src/game/save_state.rb`); `Progression#award/delta_e/load_progress!` Integer-only, invariant xp < delta_e(level+1) (`src/game/progression.rb`); `World#handle_seat_death`, `respawn_pack` (`@zone_name = @home_zone` moves THE WORLD), `assign_waiting_seats` (claims the first living uncontrolled body), `enter_zone` (whole pack teleports), `arrival_tiles_for(zone)` (`@arrivals` per zone), `digest_snapshot` (`level`/`xp` in world_fields; `pack.digest_fields` carries possessed.<seat>) (`src/game/world.rb`, 1776/1800); `Pack` (seat map, `wipe?` = no living member, `swap_next!`/`forced_swap!`) (`src/game/pack.rb`); stations verbs `bank/altar/vat/sustain` (`src/game/stations.rb`); `data/balance/{death,economy,progression,coop,combat}.json`; `src/net/fingerprint.rb` (`src/**/*.rb` + `data/**` + Gemfile.lock, EXCLUDED = bindings/prefs .local); `home_zone` save law = must be a hub zone (`home_refusal`) | repo |
| Wall + gate rows | L17 list (14 rows) vs `harness/gate_checks.json` (84 rows); 13 swap-pressing scripts named in L17; `harness/gate_scope.json`; `rake pins` (0 pins until a sweep); 42 scripts in `harness/scripts/`, 4 in `harness/retired/` | `harness/` |
| Tour footage (post-PREMIUM HUD, pre Fx/Light) | owner watches 4:13; his one-line read = art baseline (L12) | `captures/clips/tour_20260905_head_3e2bfb6.mp4` |
| Genre DNA + shelf | H1-H4, Earned A/B; death-penalties shelf sec.1 + sec.6 (Tibia blessings, XP loss formula, temples); Tibia sec.2.3/sec.4.4 | `C:/Users/gabri/workspace/gamesmith/artifacts/synthesis/genre-dna.md`; `C:/Users/gabri/Obsidian-Vault/03-Resources/game-research/death-penalties-stat-scaling-and-progression-balance.md`, `.../tibia-mechanics-lore-and-virtual-world.md` |
| Skills to read before acting | human-facing-output (Step 0b, before the first owner question); grill-and-ticket (before cutting tickets); seat-orchestration (harvest law, Step 0); council-consult (spec review, Step 1e); compact-checkpoint (before any /compact) | `C:/Users/gabri/.agents/skills/<name>/SKILL.md` |

Key state facts (verify live): `main` >= `d3a00c5` (Junior: PREMIUM pass 6) plus the s132 close
commit; Junior pushed SIX commits during s132 (`c6f5fcf` Fx, `064bd80` Light, `93cf9e6` dodge
roll, `0af8c67` idle glance + special silhouettes, `195a01f` his RECEIPTS, `d3a00c5` damage
numbers + boss bar) and may push more: `git fetch` before EVERY push, rebase, never rewrite his
files. The seat must be FREE
(`fleet`). Two headless spokes were RUNNING at s132 close (uiux `s132-uiux-a3`, assets
`s132-assets-art`; logs `/tmp/sibling-s132-*.log` are 0 bytes until exit -- buffered, NOT
dead); their receipts land in game-two's inbox.

## 2. Session flow

### Step 0 -- Orient + harvest (~15 min)
`fleet` -> `git pull` -> `git status` -> HEAD -> CHECKPOINT top -> push a CLAIMED line
(`CLAIMED: v22 spec + tickets + art charter + T0 -- <seat>, s133`). Read the foundation WHOLE.
Junior's RECEIPTS are already harvested (foundation sec.RATIFICATION); if NEW `RECEIPT: J-v22`
lines appeared since `195a01f`, append them verbatim (a "no" on the pivot is a genuine scope
break -> stop, surface to the owner).
Harvest the two spokes: `fleet` (lease gone = done), read each log tail + RECEIPT file, spot-
check artifacts against the mail's DoD (spec + rubric + 7 mocks / critique + bible + pipeline +
striker proof), record the RECEIPT lines in the triage doc sec.2, move the mails to
`~/.pi/agent/mail/game-two/done/`. A missing/failed receipt goes to the owner with the log
quoted (seat-orchestration skill: never a silent re-run; one relaunch only on infra failure).
If a spoke is STILL running, leave it, record RUNNING, harvest at close.

### Step 0b -- Owner lines, one at a time (human-facing-output skill; ~15 min of his time)
Read the skill's owner-facing recipe first. Then ask, in this order, ONE question per message,
each with: how it works today / what the plan assumed / what changes / the options / what it
costs / "what this means for you" -- and wait for his line before the next:
1. **Gabriel's half of the S1-S3 line (L15):** Junior said YES to his items S1-S3 (catalog +
   icons, bag + item drops, consumables + status) riding v22's BACK HALF (after lanes A-D ship)
   and "nada de S1 antes dela" -- nothing starts before Gabriel's line. Explain what S1-S3 add
   to the felt game, what they cost the wall and the schema (one hop, already merged into T1),
   and the alternative (open v24 THE REWARD with them). Yes / no / "after the TWENTIETH".
2. **A3 -- the companion brain flip** (`threat.json ally.enabled`, Junior's `595b3ab`, ships
   OFF): becomes its own gated piece inside T2 under the canary law (owner ratification +
   stream-diff audit + versioned canary rebank) instead of a side effect of the pivot. Also
   explain what companions ARE now (the same character's resting kits, no progression of their
   own, an XP cut on the hirer) and what turning the brain on changes in the field.
3. **Tour baseline (L12):** he watches `captures/clips/tour_20260905_head_3e2bfb6.mp4` (4:13,
   rendered at Junior's HUD commit; Fx/Light/dodge/glance/damage-number passes came after) and
   gives one line. Explain what the line triggers (the art charter A3-A5, the assets seat's
   critique target) and that a fresh tour is cheap to re-render if he prefers to judge the
   later passes too (`harness/make_tour.sh`, ~20 min detached, needs the GL fix from MEMORY if
   `Gosu.render` fails).
4. **L11 floor picks** -- Junior's LANDED (nest -1, slow_door -2, camp east door removed);
   ask only whether he confirms or overrides (his maps are Junior's; one line).
5. **Totem COEXISTENCE** (keep free / re-price / retire) -- only if he wants to decide now.
Every line lands verbatim in the foundation (RATIFICATION) the moment it arrives; none is
re-litigated. If he says "later" to any, record OPEN and move on -- never nag.

### Step 1 -- Spec + tickets (grill-and-ticket skill; ~60 min; the session's core deliverable)
`docs/superpowers/specs/<date>-v22-one-body-cycle.md`. Serial SIM tickets, one gated piece
each, CLAIMED shape, files touched, laws (restate L20 server-ready laws on EVERY ticket), gates,
DoD, fences, cost. Read Junior's SYSTEMS proposal sec.4-6 first: TWO merge points decided in
the spec: (1) ONE schema-3 hop carries T1's `characters` records AND his bag/equipment/
attributes/bank keys (his defaults = absent = empty; ours = derived from today's pack facts)
-- never two bumps (L9); (2) sequencing of his S1-S3 (catalog, bag + drops, use-item) inside
v22's back half vs opening v24 = a BOTH-SEATS line in the hub: Junior's half LANDED (yes, back
half, nothing before Gabriel's line); Gabriel's half is Step 0b question 1 -- the spec records
whichever lands and leaves S4-S7 for v24 THE REWARD. Starting shapes (refine, do not re-derive):

- **T0 -- Fresh-eyes review of `restore/pre-mundo-vivo-20260904..HEAD`** (MUNDO VIVO +
  PREMIUM v22 passes 1-4 + WB-T6 + hygiene). Headless reviewers by area at MAX thinking
  (quality over cost): (a) sim primitives + boss block + save migration (`src/game/`), (b)
  art layer + tileset + HUD + Fx + Light (`src/app/`, `tools/premium_art`, `tools/gen_*`),
  (c) LDtk tools + importer + normalizer + aftersave (`tools/*.py`, `authoring/`), (d)
  harness + gate rows + gate_scope + pins. Scrubbed prompts ("touch NOTHING, including seat
  mail; read only; findings as a numbered list with file:line and severity; final message =
  the list"), launched detached (MEMORY: powershell Start-Process, scrub PI_* env, judge by
  process/marker not log size, demand the findings as the LAST message). Findings banked
  `drafts/_t0-review-<date>.md`; blockers become tickets (T0 is NOT a revert vehicle).
  Pre-banked findings: fiction names in `tools/gen_premium_art.py:46`,
  `tools/premium_art/humanoid.py:348/558-564` ("Fio/Aro/Pomo") and in Junior's SYSTEMS
  proposal sec.1.2 -- standing order 2026-08-16 = none anywhere in code/data/docs -> docs-only
  rename to kit names (his files: ask him in the pt-br line, never rewrite them yourself);
  legacy internal `varekka` identifiers in telemetry/tests (pre-order oracle wording; owner's
  call).
- **T1 -- Save schema 3: per-PLAYER character records** (`characters` keyed by player
  identity, never seat: body held, forms unlocked, insurance count, xp_debt, level, xp,
  home_zone). Identity = a machine-local player file (shape decided here; precedent
  `data/bindings.local.json`: excluded from the fingerprint via `Fingerprint::EXCLUDED` AND
  listed in `DataStore::MACHINE_WRITTEN`; carried in HELLO so the host keys the guest's record
  by the guest's id). Migration 2->3 = ONE hop: seat-1/owner character derives from today's
  `progression` + `members`; Junior's keys default empty; schema 1 REFUSES NAMED ("save schema:
  1 unsupported (expected 3)"), `upgrade_v1` retires with its frozen key set. Refusal NAMED for
  anything else; proven on COPIES of both chains (Junior's by mail); `--fresh` backup law
  intact; `rake soak SEED_SAVE=1` green. `Character#digest_fields` per player enter
  `digest_snapshot` (test-pinned in `state_digest_test`). Pure persistence + digest, no
  surfaces. banked/provisions stay party-shared in v22 (council C8).
- **T2 -- ONE BODY in the field (lane A):** body select at the vat (station verb; Tab is
  retired from possession), resting bodies stay home, companions hired (L7,
  `data/balance/companions.json`: hire price, `xp_share_pct`, max hired), ally followers leave
  the field unless hired, coop = one body per seat. Roster/party object extraction from
  `world.rb` INTO this ticket (Crossing/Stations precedent) PLUS the `ZoneState` carve (L20.6:
  humans, corpses, projectiles, volleys, transients, flow cache per zone; World keeps ticking
  one zone). Laws: waiting seats never claim a companion (A2); `wipe?` = every PLAYER body dead;
  companion-brain flip = its own gated sub-piece under the canary law (A3, if the owner's line
  lands); `coop.json` seats=2 scalars re-derived or zeroed as a named piece. HUD to your row +
  party rows ONLY after the uiux A3 spec is harvested (else placeholder row with a named debt).
  Wall: the 14 L17 rows + 18 scripts re-authored; full-wall re-pin priced and run detached
  (~3.5 h); `rake pins` before/after.
- **T3' -- TEMPLES (lane B', L19):** TEMPLE station type in every hub zone's data (sidecar/
  LDtk per MAP_EDITING sec.1 -- the lawful edit path, never hand-edit `data/zones/**`); verb
  SET HOME (interact) writes the character's `home_zone`; solo death -> veil -> YOUR temple
  (today's respawn path, priced by T4); coop death = today's rule (spectate; both dead ->
  home) with one wrinkle: the two characters' homes may differ, so the world goes to seat 1's
  home in v22 -- NAMED interim, retired by v23 when players decouple. Strings en/es/pt-br
  (TEMPLE / TEMPLO / TEMPLO, SET HOME = functional verb, translated). Rule 2 rows:
  `temple_reads`, `home_set_cue`. `TELEMETRY home_set ...`.
- **T4 -- The fine (lane C1, pure):** `data/balance/death.json` fine table (two-regime,
  protected level, pct) + `Progression#fine!` (Integer math; order = fine from table ->
  insured reduction (100 - 8n)/100 -> debt = max(0, fine - xp), xp = max(0, xp - fine); level
  never decreases; `award` pays debt first) + tests + `TELEMETRY death_fine ...`. Numbers via
  `tools/pacing_table.rb` with the shelf's candidates (10% below protected, formula above;
  insured target 0.5-1.5% of lifetime, uninsured ~4-5%) -- present as CANDIDATES until the
  owner's word is on the row.
- **T5 -- Insurance at the bank (lane C2):** third station verb, N=3, 8% additive, consumed
  at death, price rides the BUYER's level; HUD pip; refusal cues; Rule 2 rows; strings
  en/es/pt-br (INSURANCE / SEGURO / SEGURO).
- **T6 -- Death ledger card (lane C3):** over the respawn veil per the uiux spec; rows do not
  depend on where you wake (solo temple now, decoupled temples in v23); Rule 2 row + wall
  re-pin of the death-staging scripts; prominence law.
- **T7 -- Form swap + growth retune (lane D1):** `data/balance/forms.json` (cooldown, third
  form unlock level), Tab = swap, pacing table re-run, soaks per zone, `rake perf`.
- **T8 -- Cooldown abilities (lane D2, two per form)** -- may slip to the back half.
- **T9 -- TWENTIETH declaration protocol** (delta = A + B' + C + D; pre-registered rows in L10
  + "did the companion earn its price?"; declaration arms the freeze; <= 48 h).
- **F1 -- Floors as visible truth (L11)** + **F2 -- 2x city with the arena region drawn,
  INERT** (L14; D1/D8 numbers; both peers' word).
- **WB-T7 -- cross-zone spawn GUI-safety** before any art-lane GUI session on pilot.ldtk.
- **H1 -- v23 ONE WORLD grill spark** (written at v22's close, NOT now): list the measured
  facts it needs and which v22 tickets produce them (tick budget per zone from `rake perf`,
  `ZoneState` boundaries from T2, snapshot size estimate from `digest_snapshot` groups, AWS
  host sizing, Tailscale join shape). Record the list in the spec's last section.
- **Art lane A0-A5** (charter written in Step 2).

Every ticket restates the L20 server-ready laws it touches and names its fresh-eyes reviewer
(a context that did not write it). Spec ship-gate (Rule 6, quality over cost): after the
draft, run ONE council consult (DeepSeek or Kimi, full spec inlined + the foundation's L18-L20
+ the code facts table; <= ~$1) asking for rows that violate a cited law, missing tickets,
and the ticket most likely to blow its budget; reconcile every REFUTED item against the
primary before editing; record the verdict in the spec's header. Commit the spec.

### Step 2 -- Art charter (only to the level the baseline allows)
`drafts/_v22-art-lane-charter-<date>.md`: the owner's baseline verbatim (if landed); the grid
order verbatim; A0 (WB-T7 precondition) * A1 Aseprite -> atlas pipeline into the LIVE manifest
contract (verify frame/anchor/cols from `data/art/manifest.json` first; take the assets
seat's pipeline receipt as input) * A2 tile fork CONDITIONAL on Junior's RECEIPT (Option 2
stays -> LDtk as authoring view only; Option 1 -> the S4 spike from the gamesmith brief
sec.3.7) -- Junior's word LANDED: Option 2 now, Option 1 for borders/props later, so A2 takes
the Option-2 branch and names the borders/props follow-up * A3 = the uiux spec's surfaces (from the harvested receipt) * A4 ONE full-wall
re-pin priced with `rake pins` state * A5 death-cycle + one-body + temple surfaces designed
once in the new grammar. Plus `docs/sparkups/sparkup-art-lane-<date>.md` for its own sessions.
If the baseline has not landed, write A0-A2 and leave A3-A5 as UNCHECKED placeholders
(record-first law: never fill evidence you do not have).

### Step 3 -- T0 review (review-only; no repo edits beyond the findings doc)
Launch the four area reviewers (Step 1's T0 shape) detached, in parallel, Rule 7 declared
(4 x one pass at the default model, ~$3-5 each, stop = findings list printed). While they run,
finish Steps 1-2. Harvest into `drafts/_t0-review-<date>.md` with severities; blockers ->
tickets in the spec (amend it, re-commit); the two pre-banked findings recorded as OPEN with
their owners.

### Step 4 -- T1 only if headroom remains
Claim it in the checkpoint FIRST (push the CLAIMED line), only if the spec is committed and
T0's findings are banked. T1 touches `src/game/save_state.rb`, `src/net/fingerprint.rb`,
`src/core/data_store.rb` (MACHINE_WRITTEN), tests, and a migration proof on COPIES of both
chains (Junior's chain arrives by mail -- if absent, prove on the owner's copy + a synthetic
v2 file and record the gap). Suite green via hooks; `rake soak SEED_SAVE=1`. If headroom is
short, stage T1's reviewer prompts and leave it CLAIMED-NEXT instead of half-done.

### Step 5 -- Close
`docs/CYCLE.md` updated (tickets as cut, owner-pending, RATIFIED-J state, spoke receipts).
CHECKPOINT entry (hashes AFTER push): es-CR line for Gabriel, pt-br line for Junior (tell him
about L18 ONE WORLD + L19 TEMPLES and ask for his line), spoke receipts state, CLAIMED ->
none. `git fetch` + rebase + push. `git status` clean except tmp/. If the owner asked for
another spark-up, write it and clipboard it (`cat file | clip`, ASCII only, prove with
`Get-Clipboard` in a .ps1 per MEMORY).

## 3. Definition of done

[ ] Spoke receipts harvested (or RUNNING/FAILED recorded with the log quoted) in the triage doc
[ ] Owner lines asked one at a time (S1-S3 half, A3, tour baseline, then L11/totem if he
    wants); each landed verbatim in the foundation or recorded OPEN
[ ] `docs/superpowers/specs/<date>-v22-one-body-cycle.md` with T0, T1, T2, T3', T4-T9, F1/F2,
    WB-T7, H1 list, art A0-A5 -- every ticket carries its L20 laws, gates, DoD, cost,
    reviewer; the two Junior merge points decided; council review recorded in its header
[ ] Art charter written to the level the baseline allows (record-first placeholders otherwise)
[ ] T0 findings doc banked with severities; blockers turned into tickets
[ ] T1 either claimed+shipped (suite green, proofs pasted) or CLAIMED-NEXT with prompts staged
[ ] `docs/CYCLE.md` + CHECKPOINT (both-peer lines), CLAIMED none, all pushed, clean tree

## 4. Laws that bind (restate in the spec; never soften)

- L20 SERVER-READY: characters keyed by PLAYER identity, never seat; no new rule assumes both
  players share a zone; the character record is the persistence unit; new surfaces read
  through `Character`/`Party` readers, never World internals; no new lockstep-only mechanism;
  `ZoneState` carve rides T2; NO server code in v22 (no sockets, no hosting) -- v23's grill.
- Data-driven: every tunable in `data/balance/*.json` (`death`, `forms`, `companions`,
  `progression`); ZERO code constants; Integer math through `Progression` (no Float).
- Save-chain L9: schema bump = one hop + backup-before-first-write + refusal NAMED; proven on
  copies of BOTH chains; `--fresh` backup law intact; schema 1 refuses named; the guest's
  character lives in the host save in v22 (joiner never keeps the save).
- SIM-class: the MODEL change (lane A) is the gated piece, judged by the TWENTIETH; every other
  lane one piece at a time; the companion-brain flip is its own canary piece. Bot logs never
  fun evidence.
- Rule 2 for every new surface: gate rows re-authored by name (L17: 14 rows, 18 scripts),
  full wall re-pin priced, `rake pins` states pin currency; language critique on placeholder
  strings (accuracy and presentation scored separately).
- Placeholders only, no lore: FORM, INSURANCE, XP LOST, XP DEBT, COMPANION, TEMPLE, SET HOME,
  player N. Fiction names anywhere in code/data/docs = a T0 finding (docs-only rename).
- Line caps: `window.rb` <= 300, `world.rb` <= 1800 (1776 now -> extraction INTO T2);
  events whitelisted in `EventBus::EVENTS` at first use.
- Coop lockstep identity: both seats compute identical facts; `data/**` is in the handshake
  fingerprint by construction (verified s132) -- the player file is the ONE new exclusion.
- Companions PvE-only (L7); PvP surfaces INERT until v25 (arena region drawn, no rules).
- LDtk laws (MAP_EDITING sec.4.1-4.5): pilot.ldtk canonical; GUI saves through the AfterSave
  loop; every IntGrid value declared; the 5 out-of-bounds spawns untouched until WB-T7; new
  station types (TEMPLE) enter through the importer, never hand-edited zone JSON.
- Owner overrides are law when they land; Junior's RECEIPT lines are law when they land;
  neither is re-litigated. Owner asks outrank agent process work.

## 5. Fences and stop conditions

- This session touches: drafts/, docs/ (spec, CYCLE, CHECKPOINT, sparkups), seat mail
  (game-two's own inbox/done only), tmp/. NOT src/, data/, harness/ -- except T1 if explicitly
  claimed after Steps 1-3.
- Never hand-edit `authoring/pilot.ldtk` or `data/zones/**`; never `/seat take` over a live
  session; never write into a sibling workspace tree (read tool / `git -C` only).
- Money: council <= ~$1 (spec review); T0 reviewers ~$3-5 each x 4, declared at launch;
  spokes already paid; the owner's AWS clearance covers it (declare, do not ask); external
  paid APIs = fresh-word stop. No Bedrock image spend this session (art is the assets seat's).
- Junior may push mid-session: fetch before every push, rebase, never rewrite his files; on any
  file overlap read his text first. His RECEIPT lines are law; his "no" on the pivot = scope
  break -> stop the spec, surface it.
- An owner word that reverses an L-row is a genuine scope break: record it verbatim, stop the
  affected ticket, surface it -- never route around. (s132 precedent: L6 -> L18/L19.)
- Context headroom: read the SECTIONS named; silent-on-pass; checkpoint to disk before any
  /compact (compact-checkpoint skill). Headless reviewers carry the load, not this context.
- Gate refusals are policy: state blast radius, ask.

## 6. Register

Working language English; the spec, foundation and checkpoint are read by both peers (Gabriel
es-CR, Junior pt-br) -- everyday gamer words in es/pt surfaces, never legal register. Owner
chat: plain register, define each term of art once (the foundation's sec.Terms is the
dictionary; TEMPLE, SET HOME, server-ready are new this cycle), one concrete example per
decision, close each consequential explanation with "what this means for you". Cite files by
path:section, keep every claim evidence-backed (pasted tool output, never "looks right"), never
present a shelf number as decided until the owner's word is on the row. Close with es-CR +
pt-br peer lines and one "For next time" if earned.
