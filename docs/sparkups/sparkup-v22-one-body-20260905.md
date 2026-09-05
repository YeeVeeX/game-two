# Spark-up -- game-two session: v22 ONE BODY -- council pass, spec + tickets, seat spokes, T0 review

Single fresh session, focused headroom. Order is fixed: (0) orient + harvest receipts,
(1) council pass over the RATIFIED foundation, (2) spec + tickets cut, (3) seat spokes
launched where receipts are missing, (4) art charter if the owner's tour baseline exists,
(5) start T0 (the fresh-eyes review debt) and, if headroom remains, T1. Docs + review only:
no src/ or data/ edits before T1 is claimed in a later session.

## 0. Provenance (owner words, verbatim, game-two hub chat 2026-09-05, s131)

- On the pack vs one avatar: "I think the team mechanics can start to migrate to an 'invite
  to party' and the player is just a lonely wolf in the world, therefore needs to increase
  its power to survive alone or party up with others to overcome the obstacles, we can start
  migrating to a real MMORPG mechanics one step at a time ... maybe that is limiting us and
  making combat too stale, stiff and simple, when in reality we are looking to an extreme
  experience that combines the best about Tibia and New World" -> dev recommendation ONE BODY
  (staged subtraction A->B->C->D) -> "Approved".
- On the four design rows (shared level across forms / form swap with third form earned /
  no de-level + XP debt / individual coop death) + companions PvE-only + program
  v22 -> v23 REWARD -> v24 RIVALS: "Approved but also merge Junior's ideas into the best
  product you can build and also orchestrate the ui/ux and assets seats, proceed to design
  the next session spark-up prompt".
- Standing: "cost is not a concern, quality over cost if its inside AWS"; "keep an eye on
  better art ... use the power of LDtk and Aseprite for a more modern and original look";
  pre-PREMIUM tour read: "it kinda looks better but sloppy, like it was not revised by the
  assets seat".
- On companions in PvP (his worry) and on "an in-game AI that learns from our gameplay ...
  even large scale wars": answered in the foundation L7 (GW1 rule: PvE-only) and L15
  (rival bots = the player's verb set + a behavior table fitted from telemetry; wars OUT on
  this engine, named trigger). Not re-opened here.

## 1. Ground truth (read these SECTIONS at orient; cite by path; do not re-derive)

| Source | Read | Where |
|---|---|---|
| The LAW of the cycle | whole file (~14KB): Terms, Rule 1, L1-L17, Lanes, Seats, Council (owed), RATIFICATION | `drafts/_v22-foundation-20260905.md` |
| Junior's ratification ask | sec."O que precisamos" (6 items) + any `RECEIPT: J-v22` lines he appended | `drafts/_junior-v22-one-body-ask-20260905.md` |
| Seat commissions (mailed s131) | both mails; check `~/.pi/agent/mail/game-two/inbox/` for `from-uiux-a3-one-body-spec.md` / `from-assets-v22-art-direction.md` | `~/.pi/agent/mail/game-two-uiux/inbox/from-game-two-a3-one-body-commission.md`, `~/.pi/agent/mail/game-two-assets/inbox/from-game-two-v22-art-direction-commission.md` |
| Cycle state | whole file (short) | `docs/CYCLE.md` |
| Checkpoint | top entry (s131) + CLAIMED (must be none) | `docs/CHECKPOINT.md` |
| v20 foundation | SHAPE precedent only (ledger rows, lanes, council block) | `drafts/_v20-foundation-20260828.md` |
| NINETEENTH verdict | sec.h (the four named items) | `drafts/_v20-fun-verify-verdict-20260904.md` |
| Junior's MUNDO VIVO plan | sec.8 decisions D1-D9 (merged by L14) | `drafts/_junior-mundo-vivo-plan-20260905.md` |
| Junior's SYSTEMS proposal (landed `385f429` during s131) | whole file: sec.1 data schemas, sec.4 save schema 3 + digest, sec.5 tickets S1-S7, sec.6 five decisions for both seats | `drafts/_junior-premium-v22-systems-proposal-20260905.md` |
| Junior's ally brain (landed `595b3ab`, ships OFF) | `data/balance/threat.json` ally/human blocks; `src/game/controllers.rb` ally brain; = the companion brain under L7 | repo |
| Code facts the spec cites | `SaveState` FACT_KEYS/SCHEMA/upgrade_v1 (`src/game/save_state.rb` ~L39-190); `Progression#award/delta_e` (`src/game/progression.rb`); `World#handle_seat_death` + `:nest_respawn` (`src/game/world.rb` ~L1600-1640, file at 1767/1800); `Pack` (`src/game/pack.rb`); stations verbs (`src/game/stations.rb`); `data/balance/{death,economy,progression,coop}.json`; `src/net/fingerprint.rb` (data/** in the handshake by construction) | repo |
| Wall + gate rows to re-author | L17 list (14 rows) vs `harness/gate_checks.json`; `harness/gate_scope.json`; `rake pins` (empty until a sweep) | `harness/` |
| Tour footage (post-PREMIUM HUD) | owner watches 4:13; his one-line read = art baseline (L12) | `captures/clips/tour_20260905_head_3e2bfb6.mp4` |
| Genre DNA + shelf | H1-H4, Earned A/B; death-penalties shelf sec.1 + sec.6; Tibia sec.2.3/sec.4.4 | `C:/Users/gabri/workspace/gamesmith/artifacts/synthesis/genre-dna.md`; `C:/Users/gabri/Obsidian-Vault/03-Resources/game-research/death-penalties-stat-scaling-and-progression-balance.md`, `.../tibia-mechanics-lore-and-virtual-world.md` |
| Skills to read before acting | grill-and-ticket (before cutting tickets); seat-orchestration (before launching spokes); council-consult (before the council pass); compact-checkpoint (before any /compact) | `C:/Users/gabri/.agents/skills/<name>/SKILL.md` |

Key state facts (verify live): `main` >= `385f429` (Junior: ally brain OFF + SYSTEMS
proposal) + the s131 close commit; Phase 0 hygiene
landed (AGENTS diet -> `docs/CYCLE.md`; `rake pins`; gate-scope audit). Junior pushed HUD +
gems (`41e1d95`, `8551f10`) and may push more: `git fetch` before every push, never rewrite
his files. The seat must be FREE (`fleet`). Tour rendered from a worktree at `3e2bfb6`
(`tmp/tour-wt`, disposable: `git worktree remove tmp/tour-wt`).

## 2. Session flow

### Step 0 -- Orient (~10 min)
`fleet` -> `git pull` -> `git status` -> HEAD -> CHECKPOINT top -> CLAIMED line pushed
(`CLAIMED: v22 spec + council + T0 review -- <seat>, s132`). Read the foundation whole.
Harvest: Junior's RECEIPT lines (append verbatim to the foundation sec.RATIFICATION as
RATIFIED-J rows -- his word is law when it lands; a "no" on the pivot is a genuine scope
break -> stop and surface to the owner, nothing else). Harvest seat RECEIPTs from
`~/.pi/agent/mail/game-two/inbox/` (digest-stamped; bank docs-only under `drafts/_intake-*`).
Ask the owner for the tour baseline line (L12) at the start so it can land while you work.

### Step 1 -- Council pass over the foundation (Rule 6; ~20 min; <= ~$2)
Read the council-consult skill. Two adversarial consults (DeepSeek V3.2, Kimi K2.5), each
with the FULL foundation inlined (never a summary; starved reviewers fabricate), plus the
code facts table above as ground truth. Ask for: rows that contradict a cited law, hidden
sim couplings the lanes miss (difficulty retune, coop XP attribution, save migration
edge cases, wall re-author cost), and the single biggest risk. Redirect each JSON to a
file, read as utf-8. Every REFUTED item is re-verified against the primary before any edit
(memory law). Amendments adopted/rejected with reasons into the foundation sec.Council;
sim-changing amendments get the owner's word in chat before ratification.

**Known open design row for the council (recorded s131, not yet decided):** progression
attribution in COOP. L3 "shared account level" = shared across FORMS of one character.
Between two players, rec = per-character progression (each seat's character carries its
own level/xp/debt/insurance inside the host save -- Rule 1c), with party-shared kill XP
(Tibia shared experience). The alternative (one world-level shared by both seats, today's
model) contradicts L6 "your death is yours" (one player's fine would hit the other).
Owner word owed; put it to him with the council's read.

### Step 2 -- Spec + tickets (grill-and-ticket skill; ~40 min)
`docs/superpowers/specs/2026-09-0X-v22-one-body-cycle.md`. Serial SIM tickets, one gated
piece each, CLAIMED shape, files touched, laws, gates, DoD, fences. **Two merge points with
Junior's SYSTEMS proposal, decided in the spec (never two schema bumps):** (1) T1's
per-character records and his sec.4 bag/equipment facts = ONE schema-3 hop, designed together;
(2) sequencing of his S1-S3 (catalog, bag + drops, use-item) -- inside v22's back half or
opening v23 -- is a BOTH-SEATS line in the hub; the spec records whichever lands, and
leaves S4-S7 as v23 THE REWARD. Starting shapes (the foundation's lanes; refine, do not
re-derive):

- **T0 -- Fresh-eyes review of `restore/pre-mundo-vivo-20260904..HEAD`** (MUNDO VIVO +
  PREMIUM v22 + WB-T6 + hygiene). Headless review by area (sim primitives + boss block;
  art layer + tileset + HUD; LDtk tools; harness), scrubbed reviewer prompts ("touch
  NOTHING, including seat mail"), findings banked `drafts/_t0-review-<date>.md`. NOT a
  revert vehicle: blockers become tickets. Two findings already banked s131: fiction names
  in code comments (`tools/gen_premium_art.py:46`, `tools/premium_art/humanoid.py:348/558-564`
  -- "Fio/Aro/Pomo"; standing order 2026-08-16 says none anywhere in code -> docs-only
  rename to kit names, zero pixels); legacy internal `varekka` identifiers in
  telemetry/tests (pre-order, oracle wording; owner's call whether internal names count).
- **T1 -- Save schema 3: per-character records** (`characters` keyed by seat identity;
  body held, forms unlocked, insurance, xp_debt, and -- if the coop row lands per-character
  -- level/xp). One hop from 2, refusal NAMED for anything else, proven on COPIES of both
  chains (Junior's chain by mail), `--fresh` backup law intact, `rake soak SEED_SAVE=1`
  green. Pure persistence, no surfaces.
- **T2 -- ONE BODY in the field (lane A):** body select at the vat (station verb; Tab is
  retired from possession), resting bodies stay home, companions hired (L7,
  `data/balance/companions.json`), ally followers leave the field unless hired, coop = one
  body per seat. `world.rb` extraction owed INTO this ticket (roster/party object -- the
  Crossing/Stations precedent). HUD to your row + party rows ONLY after the uiux A3 spec
  arrives (else placeholder row with a named debt). Wall: the 14 L17 rows + 6 scripts
  re-authored; full-wall re-pin priced and run detached; `rake pins` before/after.
- **T3 -- Your death is yours (lane B):** individual death -> respawn timer -> home;
  partner fights on (waiting-for-body spectate path); corpse run per body; events
  `:character_died`/`:character_respawned` whitelisted at first use; netplay scene proves
  identical facts on both seats; telemetry line.
- **T4 -- The fine (lane C1, pure):** `data/balance/death.json` fine table (two-regime,
  protected level, pct) + `Progression#fine!` (Integer math, clamps progress at 0,
  remainder -> `xp_debt`; kills pay debt first) + tests + `TELEMETRY death_fine ...`.
  Numbers via `tools/pacing_table.rb` with the shelf's candidates (10% below protected,
  formula above; insured target 0.5-1.5% of lifetime, uninsured ~4-5%).
- **T5 -- Insurance at the bank (lane C2):** third station verb, N=3, 8% additive,
  consumed at death, price rides the level; HUD pip; refusal cues; Rule 2 rows; strings
  en/es/pt-br (INSURANCE / SEGURO / SEGURO -- functional words only).
- **T6 -- Death ledger card (lane C3):** over the respawn veil per the uiux spec; Rule 2
  row + wall re-pin of the death-staging scripts; prominence law.
- **T7 -- Form swap + growth retune (lane D1):** `data/balance/forms.json` (cooldown,
  third form unlock), Tab = swap, pacing table re-run, soaks per zone, `rake perf`.
- **T8 -- Cooldown abilities (lane D2, two per form)** -- may slip to the back half.
- **T9 -- TWENTIETH declaration protocol** (delta = A-D; pre-registered rows in L10;
  declaration arms the freeze; <= 48 h).
- **F1 -- Floors as visible truth (L11)** + **F2 -- 2x city with the arena region drawn,
  INERT** (L14; D1/D8 numbers; both peers' word).
- **WB-T7 -- cross-zone spawn GUI-safety** before any art-lane GUI session on pilot.ldtk.
- **Art lane A0-A5** (charter written in Step 4).

### Step 3 -- Seat spokes (seat-orchestration skill; only where receipts are missing)
For each of uiux / assets with no RECEIPT in the inbox: triage doc in `drafts/` FIRST,
then launch ONE headless pi session into the FREE seat with the mailed commission as the
brief (digest-stamped: `md5sum` of the mail file), Rule 7 budget declared per spoke
(~$3-6 each at the default model; pass `--model` from `~/.pi/agent/models.json` rates if a
cheaper tier suffices for the mechanical parts), monitor by heartbeat not log size, harvest
`RECEIPT:` back. Spokes surface exactly two things for humans: seat conflicts and failed
receipts. Never write into a sibling tree; mail + read only.

### Step 4 -- Art charter (only after the owner's tour baseline line lands)
`drafts/_v22-art-lane-charter-<date>.md`: the baseline verbatim; A0 (WB-T7 precondition)
* A1 Aseprite -> atlas pipeline into the LIVE manifest contract (verify frame/anchor from
`data/art/manifest.json` first) * A2 tile fork CONDITIONAL on Junior's RECEIPT (Option 2
stays -> LDtk as authoring view only; Option 1 -> the S4 spike from the brief sec.4) * A3 =
the uiux spec's surfaces * A4 ONE full-wall re-pin priced with `rake pins` state * A5
death-cycle + one-body surfaces designed once in the new grammar. Plus
`docs/sparkups/sparkup-art-lane-<date>.md` for its own sessions. If the baseline has not
landed, write A0-A2 and leave A3-A5 as UNCHECKED placeholders (record-first).

### Step 5 -- Start T0 (the review debt), then T1 if headroom remains
T0 is review-only (no repo edits beyond the findings doc). T1 touches `src/game/save_state.rb`
+ tests + a migration proof on COPIES -- claim it in the checkpoint before the first edit
and only if the council pass and the spec are committed.

### Step 6 -- Close
`docs/CYCLE.md` updated (lanes as tickets, owner-pending, RATIFIED-J state). CHECKPOINT
entry (hashes AFTER push): es-CR line for Gabriel, pt-br line for Junior, RATIFIED-J
status, seat receipts state, CLAIMED -> none. Push. `git status` clean except tmp/.
Remove `tmp/tour-wt` worktree.

## 3. Definition of done

[ ] Council pass recorded in the foundation (2 consults, REFUTED items re-verified, <= ~$2)
[ ] Coop progression row decided with the owner's word (or recorded as the one open row)
[ ] `docs/superpowers/specs/<date>-v22-one-body-cycle.md` with T0-T9 + F1/F2 + WB-T7 + art A0-A5
[ ] Seat spokes launched or receipts harvested; triage doc in drafts/
[ ] Art charter written to the level the baseline allows
[ ] T0 findings doc banked (or T0 claimed for the next session with the reviewer prompts staged)
[ ] `docs/CYCLE.md` + CHECKPOINT (both-peer lines), CLAIMED none, all pushed, clean tree

## 4. Laws that bind (restate in the spec; never soften)

- Data-driven: every tunable in `data/balance/*.json` (`death`, `forms`, `companions`,
  `progression`); ZERO code constants; Integer math through `Progression` (no Float).
- Save-chain L9: schema bump = one hop + backup-before-first-write + refusal NAMED; proven
  on copies of BOTH chains; `--fresh` backup law intact; per-character records live in the
  host save (host-authoritative stays).
- SIM-class: the MODEL change (lane A) is the gated piece, judged by the TWENTIETH; every
  other lane one piece at a time. Bot logs never fun evidence.
- Rule 2 for every new surface: gate rows re-authored by name (L17), wall re-pin priced,
  `rake pins` states pin currency; language critique on placeholder strings.
- Placeholders only, no lore: FORM, INSURANCE, XP LOST, XP DEBT, COMPANION, player N.
- Line caps: `window.rb` <= 300, `world.rb` <= 1800 (1767 now -> extraction INTO T2);
  events whitelisted in `EventBus::EVENTS` at first use.
- Coop lockstep identity: both seats compute identical facts; `data/**` is in the
  handshake fingerprint by construction -- verify, do not assume.
- Companions PvE-only (L7); PvP surfaces INERT until v24 (arena region drawn, no rules).
- LDtk laws (MAP_EDITING sec.4.1-4.5): pilot.ldtk canonical; GUI saves through the AfterSave
  loop; every IntGrid value declared; the 5 out-of-bounds spawns untouched until WB-T7.
- Owner overrides are law when they land; Junior's RECEIPT lines are law when they land;
  neither is re-litigated.

## 5. Fences and stop conditions

- This session touches: drafts/, docs/ (spec, CYCLE, CHECKPOINT, sparkups), seat mail,
  tmp/. NOT src/, data/, harness/ -- except T1 if explicitly claimed after Steps 1-2.
- Never hand-edit `authoring/pilot.ldtk` or `data/zones/**`; never `/seat take` over a live
  session; never write into a sibling workspace tree.
- Money: council <= ~$2; spokes ~$3-6 each declared per launch; the owner's AWS clearance
  covers it (declare, do not ask); external paid APIs = fresh-word stop.
- Junior may push mid-session: fetch before every push, rebase, never rewrite his files;
  on any file overlap read his text first.
- A Junior "no" on the pivot, or an owner word that reverses a row, is a genuine scope
  break: record it, stop the spec, surface it -- never route around.
- Context headroom: read the SECTIONS named; silent-on-pass; checkpoint to disk before any
  /compact (compact-checkpoint skill).
- Gate refusals are policy: state blast radius, ask.

## 6. Register

Working language English; the spec, foundation and checkpoint are read by both peers
(Gabriel es-CR, Junior pt-br) -- everyday gamer words in es/pt surfaces, never legal
register. Define each term of art once (the foundation's sec.Terms is the dictionary), cite
files by path:section, keep every claim evidence-backed, never present a shelf number as
decided until the owner's word is on the row. Close with es-CR + pt-br peer lines and one
"For next time" if earned.
