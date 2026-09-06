# v22 spec — ONE BODY + THE PRICED DEATH, built SERVER-READY (2026-09-05, s133)

STATUS: CUT at s133 on the RATIFIED foundation (`drafts/_v22-foundation-20260905.md`,
L1–L20, council pass s132, owner words s131/s132/s133 verbatim in its §RATIFICATION;
Junior RATIFIED-J `195a01f`). The foundation is LAW and wins on disagreement; this file
details its lanes into tickets. Tickets are the durable artifact (grill-and-ticket law):
each runs in its OWN fresh session, claims via a CHECKPOINT `CLAIMED:` line at start
(s56 law), any seat may execute any ticket (FULL SEAT SYMMETRY, owner order 2026-08-28),
and ships only after a fresh-eyes review by a context that did not write it (Rule 6).

**Council review of this spec (Rule 6, ≤ ~$1):** DONE s133 — DeepSeek V3.2 + Kimi K2.5,
$0.04; verdicts reconciled in §9; adopted amendments carry `[council s133]` in the ticket
text (T1 migration block + deterministic guest creation + `bank_items` per character,
T2a estimate reader, T2b/T2c/T2d split, T3′ host-character wording, T4 invariant row,
§7 two grill items).

**Owner words that shaped this cut (s133, verbatim in the foundation §RATIFICATION s133):**
(0) assets unblock "yes" · (1) S1–S3: "I approve Junior's and your ideas as you both
consider best" → YES, sequenced by the devs (§4 S-tickets) · (2) A3: "not sure, doesn't
convince me" → default OFF, evidence first · (3) tour baseline: "looks so much better
… still looks like a dated game from the first generations … the size of each asset
or the zoom in of the camera … why we aren't following up our lore" + (3b) "A now" →
the sealed visual bible crosses as ART DIRECTION, fiction stays out, the art lane is a
REVAMP with a SCALE ticket first · (4) L11 "confirm" · (5) L13 totem "re-work, 15
seconds its too much, I would make it pulse every 3 seconds and heal more, like 30hp
and scale by level/hp pool".

## 0. Decisions carried (pointers, not repeats) + the two Junior merge points

- Vision, terms, Rule 1 risks, L1–L20, council amendments A2/A3, lanes A/B′/C/D/E/F/G/H,
  seats: foundation. Non-goals: AGENTS.md "OUT of scope" + foundation L15/L18 (no
  server code in v22; PvP INERT until v25; large-scale wars OUT).
- **Merge point 1 — ONE schema-3 hop (L9).** T1's `characters` records AND Junior's
  bag / equipment / attributes / bank-storage keys enter the save in the SAME bump.
  His keys default to EMPTY (absent = identity, his §4); ours derive from today's
  `progression` + `members` + `home_zone`. Two consecutive bumps are refused by L9;
  a v22 ticket that needs a new fact after T1 lands adds it INSIDE schema 3 as an
  optional key with a default, never as schema 4 (T1 §"optional-key law").
- **Merge point 2 — S1–S3 sequencing (BOTH-SEATS line, CLOSED s133).** Junior: yes,
  back half, "nada de S1 antes dela" (`195a01f`). Gabriel: delegated to both devs.
  Dev of record: **S1 any time after T1** (data-only) · **S2 + S3 after the
  TWENTIETH's VERDICT** as v22's tail, each a gated SIM piece, judged by a
  delta-triggered TWENTY-FIRST. Junior's line may amend the sequencing (peer). S4–S7
  = v24 THE REWARD. Detail §4.
- **Verification strategy (every ticket):** suite green via hooks (every commit) ·
  blocking Rule 2 gate per visual change · canary versioned-rebank for INTENDED sim
  changes (`test/harness/sim_identity_canary_test.rb` header protocol) · migration
  proofs on COPIES only · soak for anything touching zones/saves/netplay · telemetry
  oracles for SIM pieces · fresh-eyes review receipt before push. No mocks in
  integration tests. Every tunable in `data/**/*.json`.

## 1. Standing constraints (bite every ticket; restated, never softened)

**L20 SERVER-READY laws** (each ticket names which ones it touches and how):
1. Characters are keyed by PLAYER identity, never seat; seats map to characters at
   session start.
2. No new rule assumes both players share a zone (party-shared XP = "living characters
   in the SAME zone", evaluated per zone).
3. The character record (schema 3 `characters`) is the persistence unit — the server's
   account row later.
4. New surfaces read through a narrow `Character` / `Party` reader, never World
   internals — a thin client can feed the same reader.
5. No new lockstep-only mechanism beyond what exists.
6. The `world.rb` extraction owed at T2 carves a per-zone `ZoneState` (humans, corpses,
   projectiles, volleys, transients, flow cache); World keeps ticking ONE zone in v22.
7. Nothing in v22 opens the server (no sockets, no hosting) — v23's grill.

**Repo laws:** data-driven (zero balance constants in code; Integer math through
`Progression`, no Float in sim rules) · save-chain L9 (one hop, backup before first
write, refusal NAMED, proven on COPIES of both chains, `--fresh` backup law intact,
schema 1 refuses NAMED, the guest's character lives in the host save in v22) · SIM-class
= one gated piece at a time, the MODEL change (T2b) judged by the TWENTIETH, bot logs
never fun evidence · Rule 2 for every new surface (gate rows re-authored BY NAME, full
wall re-pin priced, `rake pins` before/after, language critique on strings with
accuracy and presentation scored separately) · placeholders only, no lore (FORM,
INSURANCE, XP LOST, XP DEBT, COMPANION, HIRE, TEMPLE, SET HOME, player N; fiction names
in code/data/docs = a T0 finding) · line caps (`window.rb` ≤ 300, now 270; `world.rb`
≤ 1800, now 1776 → extraction INTO T2a) · events whitelisted in `EventBus::EVENTS` at
first use · coop lockstep identity (both seats compute identical facts; `data/**` is in
the handshake fingerprint by construction — the player file is the ONE new exclusion) ·
companions PvE-only (L7); PvP surfaces INERT until v25 · LDtk laws (MAP_EDITING §4.1–4.5:
`pilot.ldtk` canonical, GUI saves through AfterSave, every IntGrid value declared, the 5
out-of-bounds spawns untouched until WB-T7, new station types enter through the
importer, never hand-edited zone JSON) · owner overrides and Junior's RECEIPT lines are
law when they land, never re-litigated; owner asks outrank agent process work.

**Live numbers this spec was cut against (verify at each ticket's start; the
prose-number law says compute, never trust):** `harness/scripts` = 42 (`harness/retired`
= 4) · `harness/gate_checks.json` = 86 rows (85 `exit_signage_reads`, 86
`minimap_reads` landed by Junior s133) · `rake pins` = 0 pins ("no pins recorded yet")
· `world.rb` 1776 · `window.rb` 270 · hubs = `camp`, `nest`, `zone_7` (`hub: true`) ·
HELLO = `version ruby platform fingerprint digest_version` (`src/net/protocol.rb`) ·
`SaveState::SCHEMA = 2`, `FACT_KEYS = banked breached counters home_zone members
progression provisions`, `MEMBER_KEYS = hp inscribed kit` · `DataStore::MACHINE_WRITTEN
= ["prefs.local"]`, `Fingerprint::EXCLUDED = ["data/bindings.local.json",
"data/prefs.local.json"]` (TWIN LAW: a machine-written file lands in BOTH) ·
`coop.json` seats=2: `respawn_delay_scale 3.0`, `human_hp_scale 1.25`,
`ally_flee_hp_pct 0.5` · `sustain.json totem`: `cadence_ticks 900`, `radius 2`,
`heal_amount 10` · `threat.json ally.enabled false` (drink_pct 0.45, ring_min_adjacent 1
since `d626550`).

## 2. Ticket template (every ticket below carries these; a missing row = not cut)

Goal · Files in scope · L20 touched (restated for the ticket) · Gates (Rule 2 rows by
name, canary protocol, soak) · Verify (runnable commands) · Done (explicit) · Fences
(what it must NOT touch) · Cost (sessions, wall hours, $ for reviewers) · Reviewer (a
context that did not write it: headless scrubbed pi by default; `council` for
irreversible or taste-heavy tickets) · CLAIMED shape: `CLAIMED: <ticket id> <one-line
goal> — <seat>, s<N>` pushed to `docs/CHECKPOINT.md` BEFORE the first edit, `git fetch`
first (s56 law).

Size guard: one ticket = one fresh session at ~60–70% of the window. A ticket that
threatens mid-unit compaction lands its suite-green core first and moves the rest to a
named follow-up in the same commit message — never half-done on `main`.

## 3. Tickets — serial SIM lane (order: T0 → T1 → T2a → T2b → T2c → [T2d] → T3′ → T4 → T5 → T6 → TS → T7 → T8 → T9)

### T0 — Fresh-eyes review of `restore/pre-mundo-vivo-20260904..HEAD` (lane E; review-only; launched s133)

- **Goal:** the Rule 6 debt on MUNDO VIVO + PREMIUM v22 passes 1–11 + WB-T6 + hygiene
  + Junior's A3 audit tooling, none of it fresh-eyes reviewed. Four headless reviewers
  by area, MAX thinking, read-only: (a) sim primitives + boss block + save/progression
  (`src/game/`, `src/core/`, `src/net/`) · (b) art layer (`src/app/`: renderer,
  tileset, fx, light, hud, minimap, controls_overlay; `tools/premium_art/`,
  `tools/gen_*.py`; `data/art/manifest.json`) · (c) LDtk tools + importer + normalizer
  + AfterSave (`tools/*.py`, `tools/import_ldtk.rb`, `authoring/`,
  `docs/MAP_EDITING.md`) · (d) harness + gate rows + gate_scope + pins + canary +
  wall runner (`harness/`, `test/harness/`).
- **Prompt law:** "touch NOTHING, including seat mail; read only; findings as a
  numbered list with file:line, severity (BLOCKER / MAJOR / MINOR / NIT), and the law
  or test each violates; final message = the list and nothing after it" (MEMORY: pi -p
  prints only the LAST message). Launched detached (powershell Start-Process, PI_*
  scrubbed), judged by process/marker, never by log size.
- **Pre-banked findings (recorded OPEN with owners):** fiction kit nicknames in
  `tools/gen_premium_art.py` and `tools/premium_art/humanoid.py` comments (grep
  `Fio|Aro|Pomo`) and in Junior's SYSTEMS proposal §1.2 — standing order 2026-08-16 →
  docs-only rename to kit names; HIS files → asked in the pt-br checkpoint line, never
  rewritten by this seat · legacy internal `varekka` identifiers in telemetry/tests
  (pre-order oracle wording; owner's call, one line).
- **Files:** `drafts/_t0-review-20260905.md` (findings, severities, owners) — nothing
  else. T0 is NOT a revert vehicle: BLOCKERs become tickets in this spec (amend §3/§5,
  re-commit), MAJORs enter lane E as small tickets, MINOR/NIT bank as a list.
- **Verify:** four receipts present (or FAILED recorded with the log quoted; one
  relaunch only on infra failure); every BLOCKER re-verified against the primary
  before it becomes a ticket (sampling-artifact law: reviewers misread too).
- **Done:** findings doc committed + spec amended for BLOCKERs + owners named for the
  two pre-banked items.
- **Cost:** 4 × one pass at the default model, ~$3–5 each (Rule 7 declared at launch;
  stop = findings list printed). **Reviewer:** the four are the reviewers; the dev of
  record only harvests.

### T1 — Save schema 3: per-PLAYER character records + the player identity file (lane A; pure persistence + digest; no surfaces)

- **Goal:** `SaveState::SCHEMA = 3`. `facts` gains `characters` — a map keyed by
  **player id** (never seat) → record `{ level, xp, xp_debt, insurance, home_zone,
  form, forms: { <kit>: { hp, inscribed } }, bag, equipment, attributes }` (the last
  three = Junior's keys, EMPTY defaults: `bag []`, `equipment {}`, `attributes {}`).
  Party-shared facts stay at the top level in v22 (council C8): `banked`, `breached`,
  `counters`, `provisions`. Junior's `bank_items []` lives INSIDE the character record
  _[council s133: both reviewers — the server's model is a per-character depot; the key
  is empty until v24, so placing it per character costs nothing now and saves a v23
  move]_; `banked`/`provisions` stay shared in v22 by C8, and "how the server splits a
  coin bank two players earned together" is a NAMED v23 grill item (§7). `members` and top-level `home_zone` and `progression` are RETIRED from
  `FACT_KEYS` (they become the host character's `forms`, `home_zone`, `level/xp`).
  Integer-only everywhere (`Progression` invariant `xp < ΔE(level+1)` holds per
  character; `xp_debt ≥ 0`; `insurance ∈ 0..death.json max_stacks`; `home_zone` must be
  a hub — `home_refusal` moves into the character validator).
- **Identity file:** `data/player.local.json` — MACHINE-written on first boot
  (`{ "player_id": "<uuid v4>", "created_at_ms": <int> }`), read by its own
  lenient-NAMED reader (corrupt file → regenerated with a printed line, never a brick;
  App::Prefs precedent), listed in `DataStore::MACHINE_WRITTEN` AND
  `Net::Fingerprint::EXCLUDED` (twin law; gitignored). Display label stays "player N"
  by seat (owner placeholder order) — the id is never shown. Bots (`--bot`) and harness
  scenes use a deterministic id from their seed so replays stay byte-identical.
- **HELLO:** `Protocol::MESSAGES[:hello]` gains `player_id`; `Fingerprint.mismatch`
  compares the five build fields ONLY (identity is not a build fact). The host keys the
  guest's record by the received id; a guest id equal to the host's id refuses NAMED
  ("player id collision: both seats share one player file").
- **Migration 2→3 (ONE hop):** the host character derives from `progression` (level,
  xp) + `members` (forms with hp/inscribed; `form` = the kit the seat-1 pointer held) +
  `home_zone`; `xp_debt 0`, `insurance 0`; Junior's keys empty. The hop also writes a
  `migration` block `{ from_schema: 2, legacy_level: L, legacy_seed_claimed_by: null }`
  (optional key; absent in fresh worlds). A `--fresh` world has nothing to migrate: the
  host character is created NEW at `progression.json new_character.level` and no
  `migration` block exists _[council s133, Kimi Q5]_. Guest characters are created at
  session start, DETERMINISTICALLY ON BOTH SEATS, from HELLO (the guest's id) + the
  SESSION facts (the host's save string, which already travels in v18's `save` field) —
  so both digests carry the same `characters` map from tick 0 _[council s133, both Q5]_.
  **DECISION D-T1 (both peers, one line each; rec in bold):** **legacy seed ONCE, keyed
  by player id** — a new character created while `migration.legacy_seed_claimed_by` is
  null copies `migration.legacy_level` (the v2 world level was earned by both seats;
  NINETEENTH evidence) and the block records THAT player's id; every later new character
  starts at `new_character.level` (default 1) _[council s133, Kimi C7: the earlier
  "first guest" + `counters` flag was seat-order shaped and party-shared — REFUTED,
  fixed: the claim is a per-player fact in a migration-only block]_. Alternative: every
  guest starts at 1. Schema 1 files REFUSE NAMED
  ("save schema: 1 unsupported (expected 3)"); `upgrade_v1` and `V1_FACT_KEYS` are
  deleted (no live v1 chain exists — both peers' saves are v2). Anything else refuses
  NAMED with the offending key/path in the text.
- **Optional-key law (post-T1):** any later v22 fact enters schema 3 as an optional
  key with a documented default (validator accepts absent = default); the
  CLASSIFICATION rows in `test/game/save_state_test.rb` pin every key's status
  (required / optional-default / retired-refused).
- **Bridge to today's World:** T1 ships BEFORE T2b, so `apply!` must rebuild today's
  three-body pack from the host character's `forms` (lossless for one character) and
  keep `progression` fed from `characters[host]`; the seat pointers stay as today.
  The guest's record EXISTS on both seats (created at session start, above) and is
  written into the host save at clean quit, but in the T1 stage the field still runs
  today's shared pack: the guest's `level/xp` are READ-ONLY mirrors of the host
  character's until T2b drives them (rule written in `Character` and test-pinned so the
  digests agree) _[council s133, both Q5/Q6: the interim between T1 and T2b is now a
  named rule, not undefined behavior]_.
- **Digest:** `Character#digest_fields` (level, xp, xp_debt, insurance, form, home_zone)
  per character in **sorted player-id string order** (UUID v4 for humans, `bot-<seed>`
  for bots/harness — disjoint formats, no collision, deterministic order on both seats)
  enter `World#digest_snapshot`; test-pinned in `test/net/state_digest_test.rb`.
- **L20 touched:** (1) keyed by player id, seats map to characters at session start ·
  (3) the character record is the persistence unit · (5) HELLO carries identity, no
  new lockstep mechanism · (7) no server code — the file is local, the id travels only
  in today's handshake.
- **Files:** `src/game/save_state.rb` · `src/game/character.rb` (new, plain object +
  validator) · `src/game/progression.rb` (per-character feed) · `src/core/data_store.rb`
  (MACHINE_WRITTEN) · `src/net/fingerprint.rb` (EXCLUDED) · `src/net/protocol.rb` +
  `src/net/session.rb` (HELLO field) · `src/app/player_file.rb` (new; reader/writer) ·
  `src/game/world.rb` (apply!/digest only — net lines ≤ 0; the extraction is T2a's) ·
  `data/balance/progression.json` (`new_character`) · `.gitignore` · tests:
  save_state, state_digest, fingerprint, protocol/session handshake, player_file.
- **Gates:** suite green (hooks) · migration proof on COPIES of BOTH chains (Gabriel's
  `saves/world.json` copy + Junior's chain by seat mail; if his copy is absent, prove on
  the owner's copy + a synthetic v2 file and RECORD the gap) · `--fresh` backup law
  proven on a copy (`.bak-<ts>` appears FIRST) · a v1 synthetic file refuses NAMED ·
  `rake soak SEED_SAVE=1 N=1` green (two real processes, scratch save, chain_check) ·
  `rake gate SCRIPT=harness/net/netplay_session.json CHECKS=harness/net/gate_checks.json`
  (HELLO shape changed) · canary UNCHANGED (no rebank: T1 changes no sim decision).
- **Verify:** `bundle exec rake` · `ruby tools/dev_save.rb` regenerates a scratch save
  under schema 3 · migration proofs pasted (before/after `facts` diff + refusal texts) ·
  `rake soak SEED_SAVE=1` output tail · netplay gate verdict.
- **Done:** all gates green + proofs pasted in the ticket record
  (`drafts/_v22-t1-record-<date>.md`) + fresh-eyes receipt + push.
- **Fences:** no surfaces, no HUD, no field behavior; never the live save (copies only,
  `--save <scratch>` for every launch); `data/zones/**` untouched.
- **Cost:** 1 session · reviewer ~$5 · council ≤ $1 (irreversible for save files:
  migration path reviewed by council + headless).
- **Reviewer:** headless scrubbed pi on the diff + this ticket + `council` (DeepSeek or
  Kimi) on the migration/refusal table.

### T2a — Party / Character / ZoneState extraction (lane A; pure refactor; byte-inert)

- **Goal:** carve, with ZERO behavior change: `Game::Party` (seat → character map,
  `wipe?`, possession pointers, waiting-seat assignment — from `Pack` +
  `World#assign_waiting_seats` / `handle_seat_death` / `respawn_pack`), `Game::Character`
  (from T1, now owning its body/forms in the field), and `Game::ZoneState` (humans,
  corpses, projectiles, volleys, transients, flow cache, arrivals — everything
  `enter_zone` swaps today) so `World` ticks `@zone_state` instead of a dozen ivars.
  `world.rb` net lines DOWN (target ≤ 1,500), `Pack` shrinks to a shim or retires.
- **L20 touched:** (4) readers exist now (`Party`/`Character` expose what HUD/ledger
  will read; nothing reads World internals after this) · (6) the ZoneState carve IS
  this ticket; World keeps ticking one zone.
- **Files:** `src/game/world.rb` · `src/game/pack.rb` · `src/game/party.rb` (new) ·
  `src/game/zone_state.rb` (new) · `src/game/character.rb` · tests moved/added for the
  new objects; `test/app/line_caps_test.rb` cap unchanged (the cap is the law, not the
  target) · `ZoneState#snapshot_estimate` (a debug reader that returns the byte size of
  the zone's serialized state — lane H's measurement, no wire format) _[council s133,
  DeepSeek Q2]_.
- **Gates (the refactor's proof):** canary banks UNCHANGED (`sim_identity_canary_test`
  green with the ACTIVE bank, no rebank) · `rake gate SKIP_CRITIC=1` on `world_loop`,
  `dash_strike_rip`, `floor3_run` (double replay + md5) · manifests of those three
  byte-identical to a pre-change run from the same commit's parent (compare `_gate_a`
  dirs, MEMORY 2026-08-25) · `rake perf` p95 unchanged ± noise (report both numbers).
- **Verify:** `bundle exec rake` · `rake perf` · the three gates · `wc -l
  src/game/world.rb` before/after pasted.
- **Done:** suite + canary + gates green, line count pasted, receipt, push.
- **Fences:** no new behavior, no data edits, no HUD, no strings; if a behavior change
  is found necessary, STOP and move it to T2b by name.
- **Cost:** 1 session · reviewer ~$5. **Reviewer:** headless scrubbed pi (diff-only
  review: "prove every moved line moved unchanged; list any semantic drift").

### T2b — ONE BODY in the field (lane A; THE model change; the TWENTIETH's piece) _[council s133: both reviewers named T2b the budget-breaker → split into T2b field rules · T2c wall + HUD · T2d optional A3]_

- **Goal:** each PLAYER takes exactly one body (their character's current `form`) into
  the field; resting forms wait at the vat; `Tab` is RETIRED from possession
  (`swap`/`forced_swap` paths go); the vat gains **SELECT FORM** (choose which kit goes
  out; free) and **HIRE** (a resting form walks beside you as a COMPANION for one
  outing, driven by today's follow AI — see A3 below); companions leave the field at
  the next hub visit or death (no regrow debt beyond `economy.json regrow_cost`); ally
  followers otherwise LEAVE the field; coop = one body per seat, each seat its own
  character (T1's records driven). `data/balance/companions.json`: `hire_cost` (by
  hirer level, table), `xp_share_pct` (the hirer's kill income × this, Integer), `max_hired`
  (2), `leave_on_hub true` — CANDIDATES via `tools/pacing_table.rb` until a peer's word
  is on the row. Laws: waiting seats never claim a companion (A2); `Party#wipe?` =
  every PLAYER body dead; companions alone never hold the field; death of a hired
  companion costs the hirer nothing but the hire (L7: it has no progression).
- **Coop scalars piece (named, inside T2b, its own commit):** `coop.json` seats=2 (`human_hp_scale
  1.25`, `respawn_delay_scale 3.0`, `ally_flee_hp_pct 0.5`) were tuned for 2 humans + 1
  follower vs 1 human + 2 followers; T2b re-derives them from the pacing table for 1–2
  player bodies + 0–2 companions or ZEROES the block, recorded as its own commit.
- **HUD in T2b:** the MINIMUM that keeps the gate rows honest — today's panel minus the
  two absent bars, party rows as plain text. The grammar (uiux A3) is T2c's.
- **Wall in T2b:** only the scripts the field change BREAKS outright are re-authored
  here (the 13 that press `swap` must at least replay to completion); their rows and
  the full re-pin are T2c's. T2b's own gates run on the four scripts named below.
- **Telemetry:** `TELEMETRY form_selected kit=…` · `companion_hired kit=… cost=…` ·
  `companion_left reason=…` · per-character `level/xp` lines keyed by player label
  (player 1/2), never by id.
- **L20 touched:** (1) seats → characters at session start (guest record driven) ·
  (2) party-shared XP evaluated as "living player bodies in the same zone" — this IS
  L20(2)'s own wording, not a new shared-zone assumption _[council s133: DeepSeek's
  Q1 flag REFUTED against the foundation text; the predicate is written per zone]_ ·
  (4) HUD reads `Party`/`Character` only · (5) no new lockstep mechanism (one input
  word per seat as today) · (6) World ticks `ZoneState` (T2a) · (7) no server.
- **Files:** `src/game/party.rb` · `src/game/character.rb` · `src/game/stations.rb`
  (vat verbs) · `src/game/world.rb` (field rules; stays ≤ 1,800 with T2a's headroom) ·
  `src/app/hud.rb` (minimum) · `src/app/controls_overlay.rb` (Tab label retired) ·
  `data/balance/companions.json` (new) · `data/balance/coop.json` ·
  `data/strings/{en,es,pt-br}.json` (SELECT FORM / ELEGIR FORMA / ESCOLHER FORMA;
  HIRE / CONTRATAR / CONTRATAR; COMPANION / COMPAÑERO / COMPANHEIRO — candidates, language
  critique at the gate) · the 13 `swap` scripts (replay-to-completion re-author) ·
  `harness/scenes/netplay_scene.rb` (one body per seat) · tests.
- **Gates:** suite · canary rebank (versioned; stream diff audited and pasted) ·
  `rake gate` on `world_loop`, `vat_economy`, `dash_strike_rip`, `corpse_run` (rows as
  they stand; a row that can no longer be judged is marked `[T2c re-author]` in the
  verdict, never deleted) · netplay gates ×3 (`harness/net/*.json`) · `rake soak N=2
  SEED_SAVE=1` (two seats, one body each) · `rake perf` · language critique.
- **Verify:** the commands above; the stream-diff audit pasted.
- **Done:** all gates green + receipt + push; the TWENTIETH's delta clock STARTS here
  (first SIM delta). T2c claims next.
- **Fences:** no fine/insurance math (T4/T5), no temples (T3′), no form swap in the
  field (T7); `ally.enabled` untouched (T2d); never the live save.
- **Cost:** 1 session (a second only if the field rules themselves overflow — then the
  companion HIRE verb is the piece that moves to the second) · reviewer ~$5 · council
  ≤ $1 (taste + model change).
- **Reviewer:** headless scrubbed pi on the diff + `council` on the field rules
  (two-way alignment: every A2/L7 law has a check; every check traces to a law).

### T2c — ONE BODY wall + HUD grammar (lane A; Rule 2 debt of T2b, paid before T3′)

- **Goal:** (1) re-author the 14 rows by name (`kits_distinct`, `possessed_readable`,
  `possession_ring_moves`, `special_pips_track`, `hud_three_bars`,
  `hud_level_strip_reads`, `carried_count_reads`, `edge_pip_reads`, `judgment_reads`,
  `taunt_convergence_reads`, `corpse_run_reads`, `wipe_reads`, `wipe_recap_reads`,
  `menu_stats_reads`) to their one-body meaning; (2) re-author the 18 scripts' HEADERS
  and staging (13 `swap` pressers: `aoe_specials dash_strike_rip level_up_beat
  lobber_reach lobber_volley loot_loop respawn_telegraph specials_chain taunt_anchor
  threat_pull toll_pocket vat_economy world_loop`; 5 wipe/corpse stagers: `corpse_run
  nest_advance ledger_loop mercy_floor sustain_run`) so each stages what its name says
  under one body; (3) HUD grammar: YOUR row (form glyph, hp, xp bar with debt shading,
  insurance pip slots) + party rows per the uiux A3 spec (harvested receipt; if still
  absent: placeholder + NAMED debt); (4) ONE full-wall re-pin DETACHED
  (`harness/run_wall.sh v22-t2c`, 42 scripts × ~5 min ≈ 3.5 h; never under a bash
  timeout); `rake pins` pasted before (0) and after.
- **L20 touched:** (4) the HUD reads `Party`/`Character` only. **Files:**
  `harness/gate_checks.json` · `harness/scripts/*` (18) · `src/app/hud.rb` ·
  `src/app/renderer.rb` · strings · tests. **Gates:** suite · `rake gate` on
  `world_loop` + `ledger_loop` with the new rows · full-wall rc=0 · language critique on
  HUD labels. **Done:** wall sweep rc=0 + pins listed + receipt + push. **Fences:** no
  sim change (a needed one goes back to a named T2b follow-up). **Cost:** 1 session +
  3.5 h detached · reviewer ~$5. **Reviewer:** headless scrubbed pi + a vision-critique
  context on the re-pinned frames.

### T2d — Companion brain flip (OPTIONAL; lane A; runs ONLY on an owner line)

- **State:** `threat.json ally.enabled false` stands (owner s133: "not sure, doesn't
  convince me"). Evidence on disk: Junior's audit `drafts/_a3-ally-brain-audit-20260905.md`
  (4 sessions: OFF 1 fight/1 death · ON silent 2 wipes · ON + callouts 11 fights, 0
  wipes, BOSS 1; canary stream diffs OFF vs ON per script via `tools/a3_stream_diff.rb`;
  one NAMED finding: ranged-hold stalemate in `brasa2_run`, two fix candidates, none
  applied). The owner re-asks himself; nobody nags.
- **If his line lands:** one gated commit under the canary law (owner ratification +
  stream-diff audit re-run + versioned canary rebank) with the stalemate fix as a named
  follow-up commit; L10 gains "did the companion earn its price?"; companions (T2b) use
  the ON brain. **Files:** `data/balance/threat.json` · canary banks · (fix)
  `src/game/threat*.rb`. **Cost:** ½ session. **Reviewer:** headless scrubbed pi on the
  stream diff.

### T3′ — TEMPLES (lane B′, L19)

- **Goal:** station type `temple` in every hub zone (`camp`, `nest`, `zone_7`) through
  the lawful edit path per zone (MAP_EDITING §1 — LDtk + sidecar for pilot zones, the
  recorded path otherwise; never hand-edited `data/zones/**`; the importer learns the
  type). Verb **SET HOME** (interact, `H/F`) writes `characters[me].home_zone = zone`
  (hub-only validator) and emits `:home_set`. Solo death → veil → wake at YOUR temple
  (today's `respawn_pack` path re-pointed at the character's `home_zone`; the fine is
  T4's). Coop death = TODAY's rule (spectate; both dead → home) with one NAMED interim:
  two characters' homes may differ, so the world goes to the **HOST character's** home
  in v22 — keyed to the role the v18 persistence law already defines (host-authoritative
  save), not to a seat number; the SAME behavior today, since the host is seat 1
  _[council s133: both reviewers flagged "seat 1's home" as a new seat-coupled rule
  under L20(2); it stays the ONE named interim (foundation L6 note + L19) and its
  retirement is now an explicit v23 grill item, §7]_. Cue at the temple tile: name
  plate TEMPLE + the verb prompt (Junior's interact bubble `a18b40b` carries it).
- **Strings (candidates; language critique at the gate, accuracy vs presentation):**
  TEMPLE / TEMPLO / TEMPLO · SET HOME / FIJAR HOGAR / DEFINIR CASA · cue line HOME SET /
  HOGAR FIJADO / CASA DEFINIDA. Everyday gamer words, never legal register.
- **Telemetry:** `TELEMETRY home_set player=N zone=…` · respawn line gains `home=…`.
- **L20 touched:** (1)(3) `home_zone` is a character fact · (2) the interim is NAMED as
  the one rule that still assumes a shared zone (recorded here, retired by v23) · (4)
  the cue reads `Character#home_zone` · (7) no server.
- **Files:** `authoring/pilot.ldtk` + sidecars (via GUI/AfterSave or the normalizer —
  never a hand edit) · `tools/import_ldtk.rb` (station type) · `data/zones/{camp,nest,
  zone_7}.json` (EMISSIONS) · `src/game/stations.rb` · `src/game/world.rb` (respawn
  target) · `src/app/renderer.rb` (plate) · strings · `harness/scripts/temple_reads.json`
  (new) · `harness/gate_checks.json` rows `temple_reads`, `home_set_cue` · tests
  (importer, stations, respawn target, save validator).
- **Gates:** suite (importer fixpoint + provenance) · `rake gate` on `temple_reads` +
  `nest_advance` (solo death → home) · canary: station added = INTENDED change →
  versioned rebank if any stream moves (a hub station should not; prove) · `rake soak
  N=1 SEED_SAVE=1` crossing a hub · language critique.
- **Done:** gates green + receipt + push.
- **Fences:** no coop respawn code (L6 note: none in v22) · no points-of-interest
  placement (owner names them later, one line each) · WB-T7 precondition if the GUI is
  used on `pilot.ldtk` (else the normalizer path).
- **Cost:** 1 session · reviewer ~$5. **Reviewer:** headless scrubbed pi.

### T4 — The fine: XP loss + XP debt (lane C1; pure math + telemetry)

- **Goal:** `data/balance/death.json` gains `fine`: `{ protected_level, below_pct,
  above: { … formula params … } }` — CANDIDATES from `tools/pacing_table.rb` with the
  shelf's targets (uninsured ≈ 4–5 % of lifetime XP at level; insured 0.5–1.5 %; flat
  10 % of ΔE(level+1) below the protected level; formula above —
  `death-penalties-stat-scaling-and-progression-balance.md` §1/§6) presented as
  candidates until the owner's word is on the row. `Progression#fine!(level, xp,
  insurance_stacks)` — Integer math, ORDER IS LAW (L5): `fine = table(level)` → `fine =
  fine × (100 − pct_per_stack·n) / 100` → `debt = max(0, fine − xp)`, `xp = max(0, xp −
  fine)`; level never decreases; `award` pays debt first; insurance never touches debt
  directly. Applied at the character's death (solo: at the veil; coop: at the seat's
  death), once per death.
- **Telemetry:** `TELEMETRY death_fine player=N level=L fine=F insured=n debt=D
  xp_after=X` · L10 rows `deaths`, `xp_lost`, `xp_debt_paid` counted here.
- **L20 touched:** (1)(3) per-character facts · (4) nothing reads World internals ·
  (5)(7) none.
- **Files:** `data/balance/death.json` · `src/game/progression.rb` · `src/game/character.rb`
  · `src/game/world.rb` (death hook only) · `tools/pacing_table.rb` (fine columns) ·
  `test/game/progression_test.rb` (table rows, order, invariants, debt payment; an
  explicit row proves `xp < ΔE(level+1)` holds AFTER `fine!` and AFTER an `award` that
  pays debt then levels — property-style over the whole level range 1..cap) ·
  telemetry test _[council s133, Kimi C5: "complete" was asserted, not proven — the
  proof is now a named test row]_.
- **Gates:** suite · canary: the fine changes no RNG draw (prove: streams identical; if
  a stream moves, STOP and name why) · `rake soak N=1` (deaths happen; telemetry lines
  present) · no Rule 2 row (no surface yet — T6).
- **Done:** suite green + pacing table pasted + soak tail pasted + receipt + push.
- **Fences:** no surface, no insurance purchase (T5), no card (T6).
- **Cost:** 1 session · reviewer ~$5. **Reviewer:** headless scrubbed pi (math review:
  every branch of `fine!` has a test row).

### T5 — Insurance at the bank (lane C2)

- **Goal:** third bank verb **INSURE** (`death.json insurance`: `max_stacks 3`,
  `pct_per_stack 8`, `price` table by the BUYER's level — k re-price shape; candidates)
  → `characters[me].insurance += 1` up to the cap; refusals NAMED (cap reached, banked
  short); consumed at death by T4's order. HUD pip row (0–3) on YOUR row (reads
  `Character#insurance`). Strings: INSURANCE / SEGURO / SEGURO · INSURED / ASEGURADO /
  SEGURADO · refusal lines (candidates; critique).
- **Telemetry:** `insurance_bought player=N stacks=n cost=c` · `insurance_consumed
  player=N stacks=n` (L10 rows).
- **L20 touched:** (1)(3) character fact · (4) pip reads `Character` · (5) the verb is
  one input word like `sustain` today.
- **Files:** `data/balance/death.json` · `src/game/stations.rb` · `src/game/character.rb`
  · `src/app/hud.rb` · strings · `harness/scripts/bank_insurance.json` (new) ·
  `harness/gate_checks.json` rows `insurance_pip_reads`, `insurance_refusal_reads` ·
  tests.
- **Gates:** suite · canary (bank verb adds no RNG; prove) · `rake gate` on
  `bank_insurance` + `ledger_loop` · language critique.
- **Done:** gates green + receipt + push. **Fences:** no card (T6); the price table is a
  candidate row. **Cost:** 1 session · reviewer ~$5. **Reviewer:** headless scrubbed pi.

### T6 — Death ledger card (lane C3; the surface)

- **Goal:** over the respawn veil, the card: XP LOST n · XP DEBT n · INSURANCE USED n/3 ·
  coins on the corpse (existing fact) · the CONTINUE prompt; rows do NOT depend on where
  you wake (solo temple now, decoupled temples in v23). Grammar = the uiux A3 spec's
  `ob_death_card` (harvested receipt) or a placeholder card with a named debt.
  Prominence law: the card is the loudest thing on screen for its window; nothing else
  animates over it. Strings en/es/pt-br (candidates; critique).
- **L20 touched:** (4) the card reads `Character` + the death record only.
- **Files:** `src/app/renderer.rb` (or a new `src/app/death_card.rb`) · strings ·
  `harness/scripts/death_card.json` (new; stages a death) · gate rows
  `death_card_reads`, `death_card_prominence` · re-author of the death-staging scripts'
  rows (`wipe_reads`, `wipe_recap_reads` → their one-body successors) · tests.
- **Gates:** suite · `rake gate` on `death_card` + `corpse_run` + `mercy_floor` ·
  language critique · one wall re-pin of the death-staging scripts (5) detached.
- **Done:** gates green + receipt + push. **Cost:** 1 session · reviewer ~$5.
  **Reviewer:** headless scrubbed pi + a vision critique context on the frames.

### TS — Totem re-work (owner word s133, L13; lane C's sustain economy; one gated SIM piece)

- **Goal:** `data/balance/sustain.json totem`: `cadence_ticks 900 → 180` (3 s at the
  60-tick second), `radius 2 → 4` (Chebyshev tiles, today's measure — owner s133:
  "augment the radio of the healing wave of the totem by 2 tiles"), and a heal that
  scales with the character's hp pool: `heal = max(heal_min, max_hp × heal_pct_max_hp /
  100)` (Integer) with `heal_min 15` (owner: "15hp is good and scale with hp pool of
  the player") and `heal_pct_max_hp` ≈ 5 as the dev's recommended shape (≈ 15 hp at
  today's ~300 mid-level pool); numbers via `tools/pacing_table.rb` against the potion
  economy (`economy.json provision_heal 30 / provision_cost 5`) and the totem-vs-potions
  telemetry, CANDIDATES until his word is on the row; Junior's line welcome (his
  totem). Design intent (owner): "totems are a bit more useful and tactical during the
  battle" — a POSITION you hold, not a free heal; the counter is monsters that push you
  out of the radius (knockback exists). Rule 2 row `totem_pulse_reads` (the faster,
  wider pulse must read as a heartbeat with a visible edge, not flicker).
- **L20 touched:** (4) the pulse reads `Character#max_hp` through the reader · nothing
  else.
- **Files:** `data/balance/sustain.json` · `src/game/stations.rb` (`tick_totems!`
  scaling) · `harness/scripts/totem_pulse.json` (new or re-author of the district
  script that passes the totem) · gate row · tests (cadence, scaling, Integer).
- **Gates:** suite · canary: INTENDED change → versioned rebank (heals move hp → streams
  move) · `rake gate` on the totem script · `rake soak N=1 ZONES=district`.
- **Done:** gates green + receipt + push; TWENTIETH re-reads the totem-vs-potions rows.
- **Cost:** ½–1 session · reviewer ~$5. **Reviewer:** headless scrubbed pi.

### T7 — Form swap + growth retune (lane D1)

- **Goal:** `data/balance/forms.json`: `swap_cooldown_frames`, `third_form_level`,
  `swap_windup_frames`; `Tab` = SWAP FORM in the field (the body changes kit on the
  spot; hp carries as a fraction of max — Integer; specials' exhaust carries); the third
  form unlocks at `third_form_level` (before that the vat offers two). Growth retune:
  `progression.json` k / `dmg_growth_pct` / `hp_growth_pct` re-derived with the pacing
  table for ONE body (NINETEENTH item 2 "growth not felt 10→13") — candidates. HUD:
  form glyph + cooldown arc on YOUR row. Strings: FORM / FORMA / FORMA · SWAP / CAMBIAR
  / TROCAR.
- **L20 touched:** (1)(3) `form`, `forms` are character facts · (4) HUD reads the
  reader · (5) swap is one input word.
- **Files:** `data/balance/forms.json` (new) · `data/balance/progression.json` ·
  `src/game/character.rb` · `src/game/world.rb` (swap rule) · `src/app/hud.rb` ·
  `src/app/controls_overlay.rb` (Tab label returns as SWAP) · strings · scripts
  `form_swap.json` (new) + re-author of `level_up_beat` · gate rows `form_swap_reads`,
  `form_cooldown_reads` · tests.
- **Gates:** suite · canary rebank (INTENDED) · `rake gate` on `form_swap` +
  `level_up_beat` · `rake soak N=2` per zone family (tower, ember, moss) · `rake perf`
  · language critique.
- **Done:** gates green + pacing table pasted + receipt + push.
- **Cost:** 1–2 sessions · reviewer ~$5. **Reviewer:** headless scrubbed pi.

### T8 — Cooldown abilities, two per form (lane D2; may slip to the back half)

- **Goal:** `forms.json abilities`: per form two cooldown abilities on `L/E` + a second
  key (data: cooldown, cost, effect keyed to existing sim verbs — dash / ring / volley
  families; no new damage types). HUD: two pips per form. Everything data-driven; the
  sim gains ONE generic "ability" verb, not two per kit.
- **L20 touched:** (4)(5) as T7. **Files:** `forms.json` · `src/game/abilities.rb` (new,
  plain object) · `world.rb` hook · HUD · strings · script `abilities_chain.json` ·
  rows · tests. **Gates:** suite · canary rebank · gate · soak · perf. **Cost:** 1–2
  sessions. **Reviewer:** headless scrubbed pi. **Slip rule:** if T7 + TS + T6 have not
  closed by the time T8 would claim, T8 moves AFTER the TWENTIETH and the declaration
  names it absent.

### T9 — TWENTIETH declaration protocol (L10)

- **Goal:** delta = A (T2b) + B′ (T3′) + C (T4–T6) + TS + D (T7, T8 if landed).
  Pre-registered rows (L10): `deaths`, `xp_lost`, `xp_debt_paid`, `insured_deaths`,
  `insurance_bought/consumed`, `form_swaps`, `companion_hires`, `time_to_continue`,
  `totem_heals` vs `potions_used`; free-verdict re-asks growth A/B + "did dying cost
  something you felt" + (if A3 flipped) "did the companion earn its price?". Wording
  frozen AT declaration, not before; declaration arms the measurement freeze; window
  targets ≤ 48 h; bot logs never fun evidence; runsheet + JUNIOR.md frozen for the
  window; verdict adjudicated from a fresh session.
- **Files:** `drafts/_v22-twentieth-declaration-<date>.md` · runsheet · `docs/JUNIOR.md`
  (frozen copy) · CYCLE.md. **Cost:** ½ session + the two play sessions.
  **Reviewer:** the adjudicating fresh session.

## 4. Junior's S-tickets inside v22 (merge point 2; his design, his file — `drafts/_junior-premium-v22-systems-proposal-20260905.md` §5)

- **S1 — catalog + strings + icons (data only, no sim):** may claim any time after T1
  lands. `data/items.json` (functional ids; player-visible names in
  `data/strings/*.json`, no lore — D9) · 16×16 icon sheet through the assets seat's
  Aseprite pipeline (A1) or `tools/gen_item_icons.py`, md5-pinned · 3 locales. Gate:
  icon md5 test + strings test + language critique. No canary, no wall. Cost ½ session.
- **S2 — `Game::Bag` + item drop records + pickup + read-only bag screen:** claims
  ONLY after the TWENTIETH's verdict is banked. New RNG stream `:loot` (additive; prefix
  identity holds), `loot_loop` re-authored, canary rebank, bag cap = P5 (20) unless a
  peer overrides. Death: items stay in the bag in v22 (Junior's P2 rec: equipment on
  the corpse is S4/v24 — nothing drops in v22). Rule 2 rows for the drop icon + BAG FULL
  cue. Cost 1–2 sessions.
- **S3 — `:use_item` + status registry + burn DOT + antidote/salve:** after S2. The
  flask migrates to the bag (`sustain` = use flask); `status.json`; HUD status icons.
  Canary rebank; poison/aura tests extended. Cost 1–2 sessions.
- **TWENTY-FIRST:** delta-triggered by S2 + S3 (player-facing SIM change); short, its
  rows pre-registered at its declaration (`items_dropped`, `items_picked`, `bag_full`,
  `cures_used`). v22 closes on its verdict.
- Each S-ticket restates the L20 laws it touches ((3) bag/equipment/attributes are
  CHARACTER facts, `bank_items` party-shared; (4) the bag screen reads `Character`)
  and names its reviewer at claim. S4–S7 + P2–P4 = v24 THE REWARD.

## 5. Lanes E / F / WB — small tickets

- **F1 — Floors as visible truth (L11, CLOSED both peers):** banner shows the floor
  ("ZONE 5 · -3"); `authoring/world_graph_allowlist.json` LEGACY rows fixed through
  the LDtk → importer path: nest → −1, slow_door → −2, camp east door REMOVED; each
  fixed row leaves the allowlist (count before/after pasted; the suite forces it).
  Files: `pilot.ldtk`/sidecars (lawful path) · emissions · banner renderer · gate row
  `floor_banner_reads` (the uiux `ob_floor_banner` mock is the grammar input) · tests.
  Gates: suite (allowlist + provenance) · `rake gate` on `floor3_run` + `nest_advance`
  · canary: transitions retyped/removed = INTENDED → versioned rebank if streams move.
  Cost ½–1 session. Reviewer: headless.
- **F2 — 2× city with the ARENA region drawn, INERT (L14):** D1 2× + D8 offset (0,0)
  numbers — owner-pending "confirm" in CYCLE.md; the ticket claims only after both
  peers' word (Junior's D1/D8 are his; the owner's confirm is recorded or the ticket
  waits). `intent: "arena"` region in `zone_7` with NO rules (v25 opens PvP). Files:
  LDtk + importer (region type) + emissions + `rake map` check. Gates: suite · `rake
  map PROBES=1` · `rake gate` on `world_loop` · soak crossing. Cost 1–2 sessions.
  Reviewer: headless.
- **WB-T7 — cross-zone spawn GUI-safety:** the 5 out-of-bounds `spawn` rows
  (MAP_EDITING §4.5) become GUI-safe (Point fields inside their source level, or a
  declared cross-zone entity) BEFORE any art-lane or T3′ GUI session on `pilot.ldtk`;
  test-pinned. Files: `tools/*.py` normalizer/importer · `pilot.ldtk` via the
  normalizer · MAP_EDITING §4.5. Gates: suite (fixpoint) · `rake gate` on one script
  per touched zone. Cost ½–1 session. Reviewer: headless.
- **E-tickets from T0 (s133; `drafts/_t0-review-20260905.md` §6 is the source; 64
  findings, 1 BLOCKER / 22 MAJOR):**
  - **E0 — boss rotation snapshot fix (BLOCKER a1):** `Creature#begin_action` snapshots
    the begun skill (`@action_cfg = kit.fetch(kind)`) and `action_config` returns it, so
    the started arc == the resolved arc across a multi-skill phase (today: off by one;
    ember_boss phase 1 `[dash, beam]` can crash on `@dash_plan.duration` nil). Tests: started
    == resolved per cast; ember_boss driven to phase 2 in `grass_fixture`. Canary: a fix
    that moves streams → INTENDED versioned rebank. Junior authored the boss block (told
    in the pt-br line; either seat executes). Cost ½ session; headless reviewer.
  - **E1 — harness truth (BEFORE T1's first gate; it frames every later gate):** rewrite
    the critic PERSONA (`harness/vision_critic.py:72-77` still describes flat-rect art) ·
    pins + verdict log written to the MAIN clone's ledger from any worktree (`run_wall.sh
    --pins`, `pins.json` is `[]` today because the 064bd80 sweep ran in a pruned worktree)
    · `SKIP_CRITIC=1` / exported `CHECKS` refuse to record a pin · the 7 census manifests
    (`level_gate loot_loop nest_advance threat_pull vat_economy zone8_crossing
    zone_catchup`) re-cut to observed counts or retired so the runner's rc means
    something again (Rule 6) · `zone8_crossing` re-authored on the seal-less DUNGEON 1 +
    `gate_scope.json` fixed · four rows off the retired white ring → halo grammar ·
    `netplay_scene.rb` wires art/ambience/tileset via ONE `Renderer.build` factory (the
    partner halo gets its first capture) · gate rows for PREMIUM passes 3–11 + petrify /
    blink / aura · one boss sentinel per boss (BOSS 1 chant/seizure/writ, BOSS 2 / BOSS 4
    phases) + a boss-bar row. Cost 1–2 sessions (+ one detached sweep to re-pin);
    headless reviewer + a vision context on the new rows.
  - **E2 — sim correctness:** `revive!` clears poison (a2) · strict `fetch` for balance
    keys, KeyError names kit/key (a4) · `--start-zone` host-authoritative in `Params` or
    refused on a human `--join` (b6: today a desync, not a refusal) · ally-brain focus-fire
    dead branch + coward / dodge / ring / dash tests (a3/a6) — **precondition of T2d**.
    Cost 1 session; headless reviewer.
  - **E3 — presentation truth:** interact prompt only where a verb exists on the tile
    (b3) · minimap ways drawn live and coloured by `way_locked?` (b4/d12) · every
    `@display.fetch(:k` key written into `display.json` + an existence test (b5) · SAFE
    chip `safe_chip_y` 98 → 138 (uiux F-A3-1, hub-confirmed on the tour frame). Junior's
    surfaces → his line first, either seat executes. Rule 2 gates on the touched scripts.
    Cost 1 session; headless + vision reviewer.
  - **E4 — zone identity for the six new zones** (`dungeon_2/3/4`, `ember_1/2/3` fail the
    identity contract when added to `zone_identity_data_test`): sidecar palettes
    re-authored through the importer, or a RECORDED law amendment for the buried-rock
    value structure. Junior's maps → his call. Cost ½–1 session.
  - **E5 — no-lore renames (docs-only):** `gen_premium_art.py:46`, `premium_art/humanoid.py`
    comments (Junior's files — asked, never rewritten by the other seat), `face_varekka!`
    in two tests, `renderer.rb:1479` comment, `vision_critic.py:225` "Threketh", rows
    "MEDUSA TOWER / BRASA / MUSGO", script names `brasa*_run` / `tower*_run` (rename =
    one commit; pins/scope follow). Owner line owed on `TELEMETRY varekka` (frozen oracle
    wording) and on MEDUSA/MUSGO/BRASA as theme words vs fiction.
  - **Inputs, not tickets:** a11 extraction seams → T2a · c3 (36 duplicate LDtk iids) +
    c6 (the five OOB spawns named) → WB-T7 · b16 (kit colours in three places →
    `data/art/kits.json`) → art lane AB/AA · d14/d15/d16 → E1 follow-ups.
- **E-tickets (foundation L16, after T0):** `vat_economy` 2 rows + `aoe_specials
  challenge_reads` re-author · `basement_1` zone-specific gate row · `varekka_duel` /
  `burn_duel` re-author (from `harness/retired/`) · `basement_3` · `pool` · audio
  ear-checks (owner) · SHARED-save first crossing · worldsmith v2 grill. Cut as
  claimed, one per session, headless reviewer each.

## 6. Lane G — ART (owner-directed REVAMP; parallel; presentation-only)

Charter: `drafts/_v22-art-lane-charter-20260905.md` (this session). Law of the lane =
the SEALED visual bible `game-two-lore/drafts/visual-storyboard/concept/
biblia-visual-v10-20260828.md|.png` (md5 `10e0d81ebbc650a48a8c82ce72a7b370`) for
forms, palette, light, composition — owner word "A now"; fiction stays out (kit ids,
ZONE N, BOSS 1). Tickets (each a presentation ticket with a Rule 2 gate + a wall
re-pin per landed atlas batch): **A0** WB-T7 precondition · **AS — SCALE** (logical
resolution + tile px + frame size decided ONCE from the storyboard's proportions;
judged by both peers on a scratch tour at the new scale; the number that governs
everything = the character's share of screen height, today 48/540 ≈ 9 %, modern class
13–18 %) · **A1** Aseprite → atlas pipeline adopted into the LIVE manifest contract
(assets receipt, 0-px striker proof) · **A2** tile fork = Option 2 now (engine
dual-grid), Option 1 for borders/props later (Junior `195a01f`) — the split grammar
from the assets receipt · **A3** the uiux A3 surfaces (harvested receipt) · **A4** ONE
full-wall re-pin per atlas batch (`rake pins` before/after) · **A5** death-cycle +
one-body + temple surfaces drawn once in the new grammar. Never blocks lanes A–D or
the TWENTIETH; every atlas byte change re-pins md5s + L17 rows (priced in the charter).

## 7. Lane H — v23 ONE WORLD grill input (written at v22's CLOSE, not now; the list it must carry)

Measured facts the v23 grill needs and which v22 tickets produce them: tick budget per
zone under one body (`rake perf` p95 per zone family — T2b, T7) · `ZoneState`
boundaries and their serialized size (T2a; a `ZoneState#snapshot_estimate` debug print
is allowed, no wire format) · `digest_snapshot` group sizes as the join-in-progress
snapshot estimate (T1, T2b) · per-character record size and count (T1) · the coop
interim's exact rule text to retire (T3′: "the world goes to the HOST character's home"
→ v23: each character wakes at its OWN temple, no shared-world wake rule; the grill must
specify it, not hope it) · how the server splits `banked`/`provisions` two players earned
together (v22 keeps them party-shared by C8; `bank_items` is already per character) ·
empty-zone freeze + catch-up law as it
exists today (World header) · AWS host sizing (a t4g.small-class instance on the
tailnet; `hub kb query --domain aws-cloud` at the grill) · Tailscale join shape (today's
`--join <ip[:port]>`; the server address replaces the host ip) · the wall's
server+client-in-one-process harness lane (netplay scene precedent
`harness/scenes/netplay_scene.rb`). Spark file: `docs/sparkups/sparkup-v23-one-world-grill-<date>.md`.

## 8. Review law (grill-and-ticket stage 4) + budget (Rule 7)

- Every ticket's reviewer is a context that did not write it: headless scrubbed pi
  (`env -u PI_CODING_AGENT -u PI_SESSION_FILE -u PI_SESSION_ID pi -p …`, launched
  detached; receipt = a file beside the ticket record) — plus `council` for T1
  (irreversible for save files) and T2b (the model change). Two-way alignment: every
  law/requirement has a check, every check traces to a requirement; gaps both ways
  reported. A failed review BLOCKS the push (Rule 6).
- Budget per ticket: reviewer ~$3–5 · council ≤ $1 · wall sweeps ~3.5 h detached
  (T2c, T6-partial, one per art batch). Cycle total (rough): ~14–17 sessions on the
  SIM lane + S1–S3 tail 3–4 + art lane parallel; three to four full wall sweeps.
- Stop conditions: a peer's "no" on a ratified row = scope break → stop the ticket,
  surface it · a gate refusal = policy → blast radius stated, ask · `world.rb` at the
  cap = extraction first · any Float in a sim rule = fix before commit.

## 9. Council review of this spec (Rule 6) — record-first

- [x] Reviewer + model: DeepSeek V3.2 + Kimi K2.5 via the s132 file-driver
      (`tmp/council_s133/council_ask_file.py`, same code path as `council ask`; brief =
      this file verbatim + L18–L20 + owner words + 8 claims + 6 questions, 52,002
      bytes, md5 `70f64c4bb7e75c57361d507185f47478`). Spend: DeepSeek in 15,483 / out
      1,839 tokens $0.0051 · Kimi in 14,797 / out 5,070 tokens $0.0343 — **$0.04 of the
      ≤ $1 budget**. Raw: `tmp/council_s133/out_{deepseek,kimi}.json` (scratch; this
      table is the record).
- [x] Asked: rows that violate a cited law · missing tickets · the ticket most likely
      to blow its budget · the two Junior merge points' soundness.
- [x] Verdict (reconciled against the primary; adopted items marked `[council s133]`
      in the ticket text):
      - **C1 C2 C3 C4 C6 C8 CONFIRMED by both** (Kimi C6 UNCERTAIN on whether the
        rationale is stated — it is, in §0 merge point 2 and the foundation
        §RATIFICATION s133 (1)).
      - **Kimi C5 REFUTED** ("no proof fine+award preserves `xp < ΔE(level+1)`") —
        the math preserves it (xp only decreases in `fine!`; `award` reuses the
        level-up loop) but the spec ASSERTED completeness → ADOPTED as an explicit
        property test row in T4.
      - **Kimi C7 REFUTED** (legacy seed "first guest" = seat-order shaped;
        `counters` flag = party-shared) — correct under L20(1)/(3) → ADOPTED: the
        claim is a per-player fact in a migration-only block
        (`migration.legacy_seed_claimed_by`), D-T1 rec unchanged in substance.
      - **Q1 DeepSeek "T2b party-shared XP violates L20(2)" — REFUTED against the
        foundation: L20(2)'s own text defines party-shared XP as "living characters in
        the SAME zone, evaluated per zone"; the row quotes the law. No edit beyond a
        note.**
      - **Q1 both: "seat 1's home" interim is a NEW seat-coupled rule** — agreed in
        part: the interim itself is foundation law (L6 note + L19, owner word); the
        SEAT wording was mine → ADOPTED: keyed to the HOST character (the v18
        persistence role), same behavior; retirement made an explicit v23 grill item
        (§7). Kimi's L20(1) flag on the "player N" label REFUTED: the label is the
        owner's placeholder order (presentation), records stay id-keyed.
      - **Q2 missing:** JUNIOR.md freeze (already in T9 files) · `ZoneState#
        snapshot_estimate` → ADOPTED into T2a files · telemetry oracles (every SIM
        ticket names its lines) · Kimi's five: guest activation (= T2b's "records
        driven" + the new T1 interim rule), migration proof (= T1 gate), A3 decision
        (→ T2d, optional), HUD harvest (→ T2c + the hub's harvest law), TWENTIETH
        adjudication (= T9 "fresh session"). No new ticket beyond T2c/T2d.
      - **Q3 both: T2b blows its budget** → ADOPTED: split into T2b (field rules +
        coop scalars, 1 session) · T2c (14 rows + 18 scripts + HUD grammar + full-wall
        re-pin) · T2d (optional A3). Order line updated.
      - **Q4 both: `bank_items` belongs to the character** → ADOPTED (empty until v24;
        free to place now); `banked`/`provisions` stay shared by C8 with the server
        split named in §7.
      - **Q5 both:** guest record before T2b (→ ADOPTED: deterministic creation on
        both seats at session start + read-only mirror rule) · digest ordering (→
        ADOPTED: sorted id strings, disjoint formats) · `--fresh` with no v2 facts (→
        ADOPTED: fresh = new host character, no migration block) · bot id collision
        (disjoint format, no change) · Kimi's cross-version `home_zone` divergence —
        REFUTED: the fingerprint refuses mixed builds before any tick.
      - **Q6:** DeepSeek = the T1→T2b interim (now a named rule) · Kimi = the host-home
        interim as "a hope not a plan" → ADOPTED into §7 as a grill requirement.
