# CYCLE — game-two (one cycle lives here; AGENTS.md points at this file)

This file is STATE: rewritten at each grill, read by both seats every
session. The cycle's foundation is LAW and wins on disagreement. Previous
cycles: `git log --follow -- docs/CYCLE.md AGENTS.md`; v20/v21 verbatim in
`drafts/_v21-record-20260905.md`.

## v22 OPEN — ONE BODY + THE PRICED DEATH, built SERVER-READY (RATIFIED-G s131–s133, RATIFIED-J `195a01f`)

**Law:** `drafts/_v22-foundation-20260905.md` — 20 ledger rows; council pass
DONE s132; owner words s133 verbatim in §RATIFICATION. **Spec + tickets CUT
s133:** `docs/superpowers/specs/2026-09-05-v22-one-body-cycle.md` (council
review DONE, DeepSeek + Kimi, $0.04 — amendments marked `[council s133]`).
**Art lane charter:** `drafts/_v22-art-lane-charter-20260905.md` (+ its spark
`docs/sparkups/sparkup-art-lane-20260905.md`). **Vision (ratified):** the
genre's spine is priced loss on ONE avatar; v22 migrates to ONE BODY per player
by staged subtraction, prices that body's death (XP fine + XP debt, never
de-level; insurance at the bank; a death ledger card), gives it room to grow
(form swap, third form earned, steeper growth), keeps the other bodies as
PvE-only hired companions, adds TEMPLES (per-character home, SET HOME at any
hub), and re-works the totem (owner word s133). Every piece is built so the
v23 server runs it unchanged (foundation L20).

**Program (owner-sequenced s132):** **v23 ONE WORLD** (persistent online server
world, players decoupled, own temple, AWS host on the tailnet) · **v24 THE
REWARD** (Junior's SYSTEMS plan S4–S7) · **v25 RIVALS** (PvP, trade, chat).

**Owner words s133 (verbatim in the foundation §RATIFICATION s133):** assets
unblock "yes" · S1–S3 "I approve Junior's and your ideas as you both consider
best" (→ YES; S1 after T1, S2+S3 after the TWENTIETH's verdict) · A3 companion
brain "not sure, doesn't convince me" (→ default OFF, T2d optional) · tour
baseline "looks so much better … still looks like a dated game from the first
generations … why we aren't following up our lore" + **"A now"** (→ the sealed
visual bible in `game-two-lore` is the art lane's LAW; fiction stays out; SCALE
ticket first) · L11 "confirm" · totem "re-work … pulse every 3 seconds … 15hp
… scale with hp pool … augment the radio … by 2 tiles … more useful and
tactical during the battle" (→ ticket TS).

**Tickets (spec §3–§6; serial SIM lane; claim via CHECKPOINT `CLAIMED:`):**
- **T0** fresh-eyes review `restore/pre-mundo-vivo-20260904..HEAD` — 4 headless
  reviewers LAUNCHED s133 (`tmp/t0-review/`), findings →
  `drafts/_t0-review-20260905.md`.
- **A — ONE BODY:** **T1 DONE s136** (SCHEMA 3: `characters` keyed by PLAYER id
  — `data/player.local.json` uuid on first boot, `bot-<seed>` for bots; the ONE
  2→3 hop proven on a COPY of the owner's chain; HELLO carries `player_id`,
  protocol v4, digest v4; Junior's `bag/equipment/attributes/bank_items` ride
  as optional empty keys, his S2 hook = `party.host.bag <<` one line; council +
  fresh-eyes reviews landed — the fresh-eyes BLOCK found a real mid-veil
  round-trip hole, fixed + re-reviewed PASS; record
  `drafts/_v22-t1-record-20260906.md`. **Junior's `junior/premium-build` merge:
  S1 is LANDED on his branch (`3a7f6fc`), but the branch also carries S2+S3, whose
  landing is AFTER the TWENTIETH (owner's word s133) — his §13 names the three
  honest ways (wait / peer amendment / dark-ship switch); the branch stays
  ff-able and unlanded until one of them is spoken.**) · T2a Party/Character/ZoneState extraction
  (byte-inert; `Game::Party` exists — T2a GROWS it; **runs only after his merge or
  his `junior/e-tickets` cut lands — his `Game::Interact` extraction already
  moved the lines T2a would carve**) · T2b ONE BODY field rules
  + coop scalars (THE model change; TWENTIETH clock starts; T1's interim mirror
  rule retires here — the record's level/xp at T2b landing is GROUND TRUTH) ·
  T2c wall (14 rows + 18 scripts) + HUD grammar + full re-pin · T2d optional
  companion brain (owner line only).
- **B′ — TEMPLES:** T3′ (host-character home = the one NAMED coop interim).
- **C — THE PRICE:** T4 fine + debt (pure math) · T5 insurance · T6 ledger card
  · **TS totem re-work**.
- **D — POWER TO STAND ALONE:** T7 form swap + growth retune · T8 abilities
  (may slip).
- **T9** TWENTIETH declaration (delta = A + B′ + C + TS + D).
- **S1** (data-only) after T1 · **S2 + S3** after the TWENTIETH's verdict →
  TWENTY-FIRST (delta-triggered) closes v22.
- **E/F/WB:** **E0 DONE s134** (boss rotation snapshot; record
  `drafts/_v22-e0-record-20260906.md`) · **E1 DONE s135** (harness truth, nine
  pieces `03e38b1`..`d637dc6`; record `drafts/_v22-e1-record-20260906.md`:
  critic persona re-framed on the v22 presentation, pins + verdict log resolve
  to the MAIN clone from any worktree, SKIP_CRITIC/CHECKS refuse to pin, the
  red census manifests re-cut or retired, zone8_crossing re-authored on the
  seal-less DUNGEON 1, four ring rows → halo, `Renderer.build` gives the net
  gates art (partner halo's first capture), 11 new rows incl. the boss bar,
  three boss sentinels; wall 42 → 39 → **42**, rows 86 → **97**; the full
  re-pin sweep is HANDED to the next session) · **E1c DONE s137** (the ten red
  pins: 6 REPINNED — 4 with first-ever AFFIRMATIVE reads (challenge_reads ×2 =
  the L16 row CLOSED, impact_fx on floor1_run, lobber_reach under its recalibrated
  row) + Junior's basement_pocket/toll_pocket re-authors taken VERBATIM and
  verified on main's sim; 4 CONVICTED-AND-ROUTED with pixel/data proof, zone8's
  blue lines FIXED through the importer door; no sim/renderer code moved; the
  pin ledger now stamps DIRTY-JUDGED paths; record `drafts/_v22-e1c-record-20260906.md`) · F1 floors (L11 CLOSED both
  peers) · F2 2× city + arena INERT (owner "confirm" on D1/D8 still pending) ·
  WB-T7 · L16 debts · **E2 next** (sim correctness), then E3–E5 — T1 (schema
  3) is now unblocked: E1's job was to frame every gate it will run.
- **G — ART (REVAMP, parallel):** A0 WB-T7 · AB bible bridge (mail sent s133,
  spoke running) · **AS SCALE first** · A1 pipeline · AA authorship off the
  generator · A2 tile grammar · A3 uiux surfaces (spoke U RUNNING) · A4 re-pin
  per batch · A5 surfaces once.
- **H — ONE WORLD PREP:** the v23 grill spark at v22's close (spec §7 list).

**Spokes (triage `drafts/_v22-seat-spokes-triage-20260905.md` §2):** assets
art-direction HARVESTED s132 (commit unblocked by the owner's "yes" s133) ·
assets bible-bridge spoke RUNNING s133 · uiux A3 spec spoke RUNNING (8 fixtures
× 3 locales rendered; receipt pending).

**Junior (s133):** 13 commits landed while the hub talked (PREMIUM passes 7–11:
ally callouts, exit signage, minimap, pickup gleam + low-hp pulse, interact
prompt + colour-truth fix; A3 audit with play evidence
`drafts/_a3-ally-brain-audit-20260905.md`; tools tracked). All presentation +
docs; all inside T0's range. New for him: the spec (his S-tickets sequencing =
dev-of-record call, his line may amend), TS (his totem — his line on the
numbers welcome), the art charter (his Option-2 word honoured).

## Owner-pending (never nag)

Gabriel: FASE 7 city numbers ratified by L14 (D1 2×, D8 offset) — confirm (F2
waits on it) · A3 companion brain (default OFF; Junior's audit is the evidence
if he wants to look) · D-T1 legacy seed — IMPLEMENTED as the rec s136 (seed ONCE,
keyed by player id, claimed by the first newcomer; unclaimed marker is `false`,
not null — canonical vocabulary; one line reverses it) · fine/insurance/companion/totem NUMBERS (candidates land at their
tickets; his word on each row) · AS scale (judged on rendered tours when the
ticket runs) · audio-v12 ear-checks · worldsmith v2 grill · a third `extract
game-two` (gamesmith core-loops, $) — his call. Junior: his line on the spec's
S1–S3 sequencing, TS numbers, D-T1, L18/L19 (welcome, not gating).

## Named debts (foundation L16 + s133)

T0 findings (pending harvest) · `world.rb` 1782/1800 on main, 1726 on
Junior's branch after his `Game::Interact` extraction (→ T2a, AFTER his merge) ·
`vat_economy` 2 rows re-author (the `aoe_specials challenge_reads` half of this
debt CLOSED s137: two affirmative stagers) · WB-T7 · `basement_1` no
zone-specific gate row · `varekka_duel`/`burn_duel` re-author · basement_3 ·
`pool` · fiction kit nicknames in `tools/premium_art` comments + Junior's
SYSTEMS proposal §1.2 — docs-only rename, his files (T0 finding) ·
`rake pins` = **7 PINNED / 32 STALE / 4 FAILED after E1c (s137)** — the 32 STALE
are T2c's full re-pin (T1 moved sim paths right after the v22-e1 sweep); the
four FAILED each carry a routed conviction in the E1c record: basement_pocket
(low-hp pulse tints the controls strip — Junior's `65f52e5` fixes it, lands with
his merge), corpse_run (inherits floor1_run's affirmative impact read; ledger
waits for T2c), floor2_run (**E4**: district_two wall (118,66,38) vs wall_inner
(150,74,28) tints are one hue family — the coral contract needs a palette/texture
decision), grass_fixture_walk (vessel label `player 2` in blocker rust reads
~1.04–1.08:1 against the strip — Junior's colour surface: a lifted text variant).
zone8_crossing's blue lines were pre-swap water decor in `dungeon_1`'s sidecar —
removed through the importer door s137, re-pinned; its spark-on-pale-body contrast
note goes to Junior's fx · **breach-beat coverage hole:** no wall script stages
`seal_breached` (toll_pocket's SEALED half is affirmative; a basement_2 breach
stager is owed; drop-under-corpse = an owner sim question, Junior's `_doc`) ·
negative-control gate for the recalibrated fx/volley rows (`fx_enabled:false`,
never pinned) ·
record accretion / prune verb (T1 record §5) · `taunt_anchor` critic stalls
DIAGNOSED s137 as transport-side, not payload-shaped (no fix owed) · uiux mocks
rendered at S0 — a re-render at the chosen scale is owed by mail after AS.
