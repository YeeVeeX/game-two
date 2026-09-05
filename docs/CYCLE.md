# CYCLE — game-two (one cycle lives here; AGENTS.md points at this file)

This file is STATE: rewritten at each grill, read by both seats every
session. The cycle's foundation is LAW and wins on disagreement. Previous
cycles: `git log --follow -- docs/CYCLE.md AGENTS.md`; v20/v21 verbatim in
`drafts/_v21-record-20260905.md`.

## v22 OPEN — ONE BODY + THE PRICED DEATH, built SERVER-READY (RATIFIED-G s131 + s132)

**Law:** `drafts/_v22-foundation-20260905.md` — 20 ledger rows; council pass
DONE s132 (§Council); spec + tickets are cut by the NEXT session from
`docs/sparkups/sparkup-v22-spec-and-tickets-20260905.md`. **Vision
(ratified):** the genre's spine is priced loss on ONE avatar; v22 migrates to
ONE BODY per player by staged subtraction, prices that body's death (XP fine +
XP debt, never de-level; insurance at the bank; a death ledger card), gives it
room to grow (form swap, third form earned, steeper growth), keeps the other
bodies as PvE-only hired companions, and adds TEMPLES (per-character home,
SET HOME at any hub — Tibia pattern). Every piece is built so the v23 server
runs it unchanged (foundation L20).

**Program (owner-sequenced s132):** **v23 ONE WORLD** — the persistent online
server world (players decoupled, wake at their own temple, meet/team up in one
world; AWS host on the tailnet) · **v24 THE REWARD** (Junior's SYSTEMS plan:
items/bag/equipment/vendors/drops) · **v25 RIVALS** (PvP, trade, chat on the
server). Large-scale wars stay OUT until the server world is measured.

**Owner words (verbatim):** s131 "the player is just a lonely wolf in the
world, therefore needs to increase its power to survive alone or party up
with others" · "Approved" (pivot) · s132 "decouple players, they should
respawn on a temple or select their own place of respawn across the cities
and points of interest of the world (don't overdo, follow a Tibia-like
pattern), world should be persistant online as a server and each player
writes their own story while they can also meet in the world and team up or
fight against each other, trade, chat, etc" · "Approved" (sequence a: content
now server-ready, server next).

**Council pass (s132, DeepSeek + Kimi, $0.03):** L6's "sends you home" hit
the one-zone engine (BLOCKER → resolved by the owner's ONE WORLD word: coop
individual death moves to v23; v22 coop death = today's rule, named interim);
waiting seats must never claim a companion; wall cost = 18 re-authors + 42
re-pins; coop scalars re-derive; per-character facts enter the lockstep
digest; schema 1 refuses named under schema 3. Details: foundation §Council.

**Junior (RATIFIED-J LANDED `195a01f`, s132, verbatim in the foundation
§RATIFICATION):** pivot YES (3 forms = the 3 kits) · tiles Option 2 now, 1
for borders/props later · floors nest −1 / slow_door −2 / camp east door
removed · arena YES · AfterSave pre-flight green · `.pyc` noted · **S1–S3 in
v22's back half: YES — his half of the both-seats line; Gabriel's half
owed** ("nada de S1 antes dela"). **New for him (s132):** the ONE WORLD
program (L18) and the temples (L19) — his line welcome, not gating.
**Landed by Junior s132 (merged, disjoint):**
`c6f5fcf` App::Fx (hit spark, death burst, dust, squash, corpse dead-frame,
portrait breathe) · `064bd80` App::Light (fire glows, vignette, kill punch,
level-up flash) · `93cf9e6` dodge roll pose · `0af8c67` idle glance + special
silhouettes (atlases 22 cols) · `d3a00c5` floating damage numbers, wounded hp
bars, boss bar. All presentation-only, gated; all inside T0's review range.

**Lanes (serial SIM; E/F/G/H interleave):**
- **T0** fresh-eyes review `restore/pre-mundo-vivo-20260904..HEAD` (Rule 6
  debt) — first, review-only.
- **A — ONE BODY** (T1 schema 3 per-PLAYER character records · T2 body
  select at the vat + companions + one body per seat + the `ZoneState`
  extraction from `world.rb`; 14 gate rows + 18 scripts re-authored; full
  wall re-pin priced).
- **B′ — TEMPLES** (T3′ per-character `home_zone` + SET HOME station verb at
  every hub; solo death → your temple; coop = today's rule, interim).
- **C — THE PRICE** (T4 fine + debt math · T5 insurance at the bank · T6
  death ledger card).
- **D — POWER TO STAND ALONE** (T7 form swap + growth retune · T8 cooldown
  abilities).
- **E — DEBTS** (foundation L16). **F — FLOORS + CITY** (F1 L11 · F2 2× city,
  arena drawn INERT). **G — ART** (charter owed once the tour baseline lands;
  uiux + assets spokes launched s132: **assets HARVESTED** (critique 6/10 · 5/10,
  style bible, Aseprite pipeline with a 0-px striker proof, tile-fork input =
  split grammar; commit blocked on one owner line, see owner-pending), **uiux
  RUNNING** — receipt to
  `~/.pi/agent/mail/game-two/inbox/`). **H — ONE WORLD PREP** (docs + spikes
  only; the v23 grill spark is written at v22's close).
- **TWENTIETH fun-verify:** delta = A + B′ + C + D; pre-registered rows in
  L10; declaration arms the freeze; ≤48 h window; bot logs never fun evidence.

**Next session spark:** `docs/sparkups/sparkup-v22-spec-and-tickets-20260905.md`
(owner asks at start → spoke harvest → spec + tickets server-ready → art
charter → T0 review → T1 if headroom).

## Owner-pending (never nag)

Gabriel: **assets seat: "retire `ring_expand_rect` (ring → halo)"** — one line
that unblocks the staged art-direction commit in `game-two-assets` (triage doc
§2) · **his half of the S1–S3 line** (Junior's items in v22's back half:
yes/no) · A3 companion-brain flip as a gated piece (one line) · the tour
baseline line (L12) · L11 floor picks (Junior's landed; confirm or override) ·
totem COEXISTENCE word · FASE 7 city
numbers ratified by L14 (D1 2×, D8 offset) — confirm · audio-v12 ear-checks ·
worldsmith v2 grill · a third `extract game-two` (gamesmith core-loops, $)
— his call. Junior: his read of L18/L19 (welcome, not gating).

## Named debts (banked in the foundation L16)

MUNDO VIVO + PREMIUM v22 (passes 1–4) unreviewed (T0) · `world.rb` 1776/1800
(→ `ZoneState` extraction in T2) · `vat_economy` 2 rows + `aoe_specials
challenge_reads` re-author · WB-T7 · 8 LEGACY floor rows · `basement_1` no
zone-specific gate row · `varekka_duel`/`burn_duel` re-author · basement_3 ·
`pool` · fiction names in `tools/premium_art` comments + Junior's SYSTEMS
proposal §1.2 ("Fio/Aro") — docs-only rename, his file (T0 finding).
