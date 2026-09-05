# v22 FOUNDATION — ONE BODY + THE PRICED DEATH (grill record, 2026-09-05, s131)

STATUS: **RATIFIED-G (owner, hub chat s131) — council pass + spec + tickets
owed in the NEXT session (Rule 6 fresh-eyes before any ticket is cut);
RATIFIED-J async** (owner order 2026-08-22: development never gates on peer
availability; Junior's asks in §RATIFICATION, mailed same session). On the
council pass this doc is LAW for the cycle; `docs/CYCLE.md` carries the
one-cycle STATE and points here. Pattern of record:
`drafts/_v20-foundation-20260828.md`.

**License:** the NINETEENTH closed CUMPLIDO WITH NAMED ITEMS
(`drafts/_v20-fun-verify-verdict-20260904.md` §h): all freezes lifted; four
items named for this grill — (1) vertical legibility, (2) growth not felt
10→13 on both seats, (3) objective vacuum, (4) third body "not felt" (third
reading). v21 MUNDO VIVO on `main` (`476ee32`); Junior's PREMIUM v22 art
wave (`03259d0` `1ac9e9e` `7189be7` `58e6153` `41e1d95` `8551f10`) on
`main`, mechanically gated, not fresh-eyes reviewed.

**Vision (ratified):** the genre's spine — Tibia, Ultima Online, OSRS — is
PRICED LOSS on ONE avatar (`gamesmith/artifacts/synthesis/genre-dna.md` H2
"strongest element in the corpus"; every corpus game is one character, the
party is other players). game-two's three-body pack was the outlier and it
taxed exactly what the peers report missing: combat depth (one special per
body), an owner for death, legibility (three bars, a halo, a chevron). v22
migrates to ONE BODY by staged subtraction, puts a price on that body's
death, sells insurance at the bank, shows the ledger at the moment of loss,
and gives the body room to grow (forms, cooldown abilities, steeper growth).
Owner framing (verbatim, s131): "the player is just a lonely wolf in the
world, therefore needs to increase its power to survive alone or party up
with others to overcome the obstacles ... an extreme experience that
combines the best about Tibia and New World."

---

## Terms (defined once)

- **Body** — one kit-bearing creature (striker / blocker / lobber today).
  Under ONE BODY the player takes exactly one into the field.
- **Form** — the kit a body currently wears. **Form swap** = New World's
  weapon swap on a grid: one body, two forms, swapped mid-fight on a short
  cooldown; the third form is EARNED by progression.
- **Vat** — the home station that already regrows dead bodies for coin
  (`src/game/stations.rb`). Under ONE BODY it is where resting bodies wait
  and where companions are hired.
- **Companion** — a resting body hired for one outing, driven by today's
  ally AI. PvE-only (Guild Wars 1 rule).
- **Fine** — XP removed at death. `Progression#xp` is progress INTO the
  level (P3, never cumulative; invariant `xp < ΔE(level+1)`;
  `ΔE(L)=k·(L²−3L+4)`, k=40, cap 21 — `data/balance/progression.json`).
- **XP debt** — the part of a fine larger than current progress; owed
  before new kills count (City of Heroes' debt: death always costs, never
  regresses).
- **Insurance** — pre-paid, consumed-on-death reducer of the fine, additive
  and stackable (Tibia blessings, death-penalties shelf §1).
- **Death ledger card** — the surface that shows the price when paid.
- **TWENTIETH** — the next fun-verify, delta-triggered; A–D below are its delta.

## Rule 1 — risks and the chosen approach (written before the grill, amended after the pivot)

(a) **Difficulty retune is SIM-class in one move.** Every zone is tuned for
    three bodies in the field. Approach: companions optional (the field can
    still hold three if you pay), growth steepened via
    `tools/pacing_table.rb`, soaks + `rake perf` per zone, the TWENTIETH
    judges; the v20 "one gated piece" law is applied to the MODEL change as
    the piece, with one verdict.
(b) **Save schema.** `FACT_KEYS` (`src/game/save_state.rb`, `SCHEMA = 2`,
    exact-match) gains per-character facts. Approach: schema 3, one hop,
    refusal NAMED, proven on COPIES of both chains (L9); `--fresh` backup
    law intact.
(c) **Party persistence.** v18 law: the joiner never keeps the save. Under
    ONE BODY each seat's body is its character. Approach: per-seat character
    records INSIDE the host save (host-authoritative stays; identity = seat
    key from `data/netplay.json`). Lockstep identity unchanged.
(d) **Legibility.** Money and death were invisible on the tour. Approach:
    every new surface is a Rule 2 gate row + a named wall re-pin; the uiux
    seat specs the grammar ONCE (A3) before code.
(e) **Junior's shipped work.** His halo/HUD/gems target pack surfaces.
    Approach: reframe, not retire — gold halo = YOUR body, cyan = partner;
    HUD panel = your row + party rows; gems stay. Mailed for his word.
(f) **Breadth (the owner's named failure mode, PROGRAM RULE 2026-08-27).**
    Approach: the pivot is a subtraction that reuses vat, respawn, spectate,
    stations, kits, zones, netplay, saves; nothing is rewritten; PvP and
    rivals are SEQUENCED (v24), not opened now.

## Ledger (decision · evidence · word)

- [x] **L1 — Cycle identity: ONE BODY + THE PRICED DEATH.** Staged
      subtraction A→B→C→D (lanes below). Evidence: NINETEENTH §h ×4; genre-dna
      H1–H4; tour §Gaps. **Owner: "Approved"** (after the ONE BODY
      recommendation; framing above). Naming: Junior's "PREMIUM v22" = the
      art wave INSIDE v22; the cycle is v22 ONE BODY.
- [x] **L2 — What dies: answered by L1.** The character's death is the priced
      event; the wipe/single-death fork no longer exists.
- [x] **L3 — Progression: SHARED ACCOUNT LEVEL (across FORMS).** Level belongs
      to the player; all forms of one character share it (FFXIV-style
      simplicity; one-hop schema). Per-form levels rejected (three grinds).
      **Owner: "Approved."** _Open sub-row (recorded s131, council + owner
      next session):_ attribution BETWEEN two players in coop — rec =
      per-character progression inside the host save (Rule 1c) with
      party-shared kill XP (Tibia shared experience); the alternative (one
      world level shared by both seats, today's model) contradicts L6.
- [x] **L4 — Forms: SWAP ANYTIME, THIRD FORM EARNED.** Tab becomes form swap
      (cooldown, data-driven, `data/balance/forms.json`); the third form
      unlocks by progression (H1 irreversible-investment feel without locking
      a two-dev game). Permanent vocation rejected. **Owner: "Approved."**
- [x] **L5 — The fine: XP, TWO-REGIME, NO DE-LEVEL, XP DEBT.** Candidate
      numbers (shelf §6, decided at T1 with `pacing_table`): flat 10% of
      ΔE(level+1) below a protected level; formula above; remainder past
      current progress becomes XP DEBT (kills pay debt first); banked coin
      untouched (the bank is the safe place); carried coin still rides the
      corpse (existing). Insured: debt × (1 − 8%·n). **Owner: "Approved."**
- [x] **L6 — Coop death: INDIVIDUAL.** Your death sends you home
      (respawn timer + spectate = existing waiting-for-body path); the
      partner fights on. Shared wipe retired. **Owner: "Approved."**
- [x] **L7 — Companions: OPTIONAL, PRICED, WEAKER, PvE-ONLY.** Hire a resting
      body at the vat per outing (coin sink); companions take an XP cut so a
      human partner is strictly better (economics, not prohibition — GW1's
      henchmen lesson); companions never enter PvP space (GW1 Hero Battles
      removed 2009). Numbers → `data/balance/companions.json`. Junior's
      `595b3ab` ally brain (focus fire, flask below 30%, dodge the aimed
      telegraph, role play by attack arc; ships OFF under `threat.json`) IS
      the companion brain — merged, not replaced. **Owner:
      "the hireling/companion mechanic is a nice idea just like Guild Wars 1
      ... worries me how would that be balanced in PVP" → PvE-only rule.**
- [ ] **L8 — Insurance (numbers at T3).** Bought at the bank (third station
      verb, not a potion variant), N=3 stackable, 8% each additive, all
      consumed at death, price rides the level (k re-price table). Candidate
      until T3's gate.
- [x] **L9 — Save-chain law (carried).** Schema 3, one hop, backup before
      first write, refusal NAMED, proven on copies of BOTH peers' chains;
      per-seat character records inside the host save (Rule 1c). **ONE
      migration:** Junior's SYSTEMS proposal also names schema 3 (bag /
      equipment facts) — the next session's spec designs both fact sets in
      the SAME hop; two consecutive bumps are refused by this row.
- [ ] **L10 — The TWENTIETH.** Delta = A+B+C+D. Pre-registered rows:
      `deaths`, `xp_lost`, `xp_debt_paid`, `insured_deaths`,
      `insurance_bought/consumed`, `form_swaps`, `companion_hires`,
      `time_to_continue`; free-verdict re-asks growth A/B + "did dying cost
      something you felt". Declaration arms the freeze; ≤48 h window; bot
      logs never fun evidence. Wording frozen at declaration, not before.
- [ ] **L11 — Floors as visible truth (Q8b, lane F).** If the banner shows
      the floor ("ZONE 5 · -3") the 8 LEGACY rows in
      `authoring/world_graph_allowlist.json` become visible lies. Rec:
      nest → -1, slow_door → -2 or -3 (owner pick), retype/remove the camp
      east door; each fixed row leaves the allowlist (suite forces it).
      Junior ratifies (his floors). Owner word pending.
- [ ] **L12 — Art lane (presentation, owner-directed).** Baseline = the
      owner's one-line read of `captures/clips/tour_20260905_head_3e2bfb6.mp4`
      (rendered from `3e2bfb6` = Junior's HUD commit) — PENDING. References,
      palette, who draws, where tiles are authored (Option 1 LDtk bakes vs
      Option 2 engine dual-grid — brief §3.7; Junior's word, never decided
      against him). Assets seat commissioned (§Seats).
- [ ] **L13 — Totem COEXISTENCE word.** Pending; no work item.
- [x] **L14 — Junior's ideas MERGED (owner: "merge Junior's ideas into the
      best product you can build").** From `drafts/_junior-mundo-vivo-plan-20260905.md`
      §8 and the FASE 7 city proposal: **D6 training yard** → becomes the
      HUB 1 DUEL ARENA region (`intent: "arena"`, PvP-consent zone, hub stays
      safe outside it — v24's first PvP surface, drawn in the city); **D1 2×
      city + D8 offset (0,0)** adopted as the city ticket's numbers (Gabriel's
      save = history, never guinea pig); **D2 hive dungeon from ZONE 8**
      banked as v23 content (frontier gains purpose); **D3 guardian+final**
      boss rule kept; **D4 cap steps** superseded by soft caps later (L15);
      **D5** settled by execution (MUSGO A built, BOSS 1 in the vault);
      **D7** gate-decided (grid OFF stands); **D9** unchanged (no lore);
      **swap-spec 3 decisions** (D-HOLE reversal, retired internal seal +
      L9 migration, BOSS 1 never duplicated) ratified by this row — owner
      "Approved" covers the merge. PREMIUM v22 surfaces reframed (Rule 1e):
      drawn characters + dual-grid tiles + gems STAY; halo = you/partner;
      HUD = your row + party rows.
- [ ] **L15 — Sequenced, not opened (program rule):** v23 THE REWARD (drops
      with identity, trip ledger at the bank = Tibia's Hunt Analyser, goals
      board at the hub, floor read) — **its PLAN already exists: Junior's
      SYSTEMS proposal `drafts/_junior-premium-v22-systems-proposal-20260905.md`
      (`385f429`: items / bag / equipment / attributes / bank storage / vendors
      / drops / status; 7 gated tickets S1–S7; 5 decisions for both seats) —
      banked as v23's spec input, not parked. Whether S1–S3 ride v22's back
      half is a BOTH-SEATS line.** · v24 RIVALS (rival bots = the PLAYER'S
      verb set with a behavior table fitted from telemetry; duel arena;
      flags + skulls; PvP death priced lower with unfair-fight reduction) ·
      soft caps instead of cap 21 (New World DR shape). **Large-scale wars:
      OUT on this engine** — 16.6 ms tick budget, flow-field recompute 11 ms
      at 2× (D1); named trigger = server-authoritative sim (PARKING_LOT).
      **Owner: "Approved"** (the program).
- [x] **L16 — Debt ledger (banked):** MUNDO VIVO + PREMIUM v22 fresh-eyes
      review (T0) · `world.rb` 1767/1800 (extraction owed INTO the first
      touching ticket) · `vat_economy` 2 rows + `aoe_specials
      challenge_reads` re-author · WB-T7 cross-zone spawn GUI-safety · 8
      LEGACY floor rows (L11) · `basement_1` has no zone-specific gate row
      (`harness/gate_scope.json`) · `varekka_duel`/`burn_duel` re-author ·
      basement_3 · `pool` · audio ear-checks · SHARED-save first crossing ·
      worldsmith v2 grill.
- [x] **L17 — Rule 2 costs priced, not adjectived.** Pack-specific gate rows
      to re-author at the pivot (named now): `kits_distinct`,
      `possessed_readable`, `possession_ring_moves`, `special_pips_track`,
      `hud_three_bars`, `hud_level_strip_reads`, `carried_count_reads`,
      `edge_pip_reads`, `judgment_reads`, `taunt_convergence_reads`,
      `corpse_run_reads`, `wipe_reads`, `wipe_recap_reads`, `menu_stats_reads`
      — ~14 of 84. Wall scripts staging swaps/wipes re-author with them
      (`corpse_run`, `nest_advance`, `ledger_loop`, `mercy_floor`,
      `sustain_run`, `dash_strike_rip`). ONE full-wall re-pin at the end of
      lane A+B, a second at the end of the art lane; `rake pins` states the
      pin state before each.

## Lanes + staging (serial, one gated increment per re-session)

- **Lane A — ONE BODY (the first felt change):** body select at the vat
  (Tab → station verb, other bodies rest), companions hired (L7), ally
  followers leave the field, camera/HUD to one body + party rows, coop =
  one body per seat. Sim identity moves everywhere → full wall re-author +
  re-pin priced as the ticket's cost. Save schema 3 rides here (L9).
- **Lane B — YOUR DEATH IS YOURS:** individual death (L6), respawn at
  home, spectate partner, corpse run per body.
- **Lane C — THE PRICE:** `data/balance/death.json` fine + debt (L5) →
  insurance at the bank (L8) → death ledger card + insurance pip (Rule 2
  rows). Pure math + tests first, surfaces after the uiux spec (A3).
- **Lane D — POWER TO STAND ALONE:** form swap (L4) + growth retune +
  cooldown abilities (two per form, `data/balance/forms.json`); pacing
  table re-run; soaks per zone.
- **Lane E — DEBTS:** T0 review first; then L16 items as small tickets.
- **Lane F — FLOORS + CITY:** L11 floor truth; the 2× city with the arena
  region drawn (L14) — the arena is INERT until v24.
- **Lane G — ART (presentation, owner-directed, parallel):** charter
  `drafts/_v22-art-lane-charter-<date>.md` (written when L12's baseline
  lands); assets seat + uiux seat commissioned by mail (§Seats); death-cycle
  and one-body surfaces designed once in the new grammar.

Order: T0 → A → B → C → D → TWENTIETH declaration; E/F/G interleave at the
peers' word. First SIM delta ships at A (the model itself).

## Seats (owner: "orchestrate the ui/ux and assets seats")

- **game-two-uiux** (charter = its AGENTS.md): commission **A3 legibility
  spec for ONE BODY** — single-character HUD + party frame, death ledger
  card, insurance pip + bank rows, goals board, floor-in-banner, trip
  ledger grammar; evidence = tour obs-ids + frames; deliverable = spec +
  critique rubric by mail, take-or-leave. Mail staged this session.
- **game-two-assets**: commission **art direction pass** over PREMIUM v22
  (drawn characters 32x48 anchor (2,14), dual-grid tiles, gems) against the
  owner's tour baseline; palette/style bible proposal; Aseprite → atlas
  pipeline into the EXISTING `data/art/manifest.json` contract; input on the
  Option 1/2 tile fork. Mail staged this session.
- Integration lands ONLY through this repo's gates (family block law).

## Council pass (Rule 6) — OWED, next session Step 1

- [ ] DeepSeek adversarial pass over this FULL file inlined (never a summary)
- [ ] Kimi adversarial pass (same brief)
- [ ] every REFUTED item re-verified against primaries before any edit;
      amendments adopted/rejected with reasons, folded into the rows
- Budget ≤ ~$2; the spec is cut only after this pass.

## Budget/stop (Rule 7)

This session (s131) ends at: foundation RATIFIED-G + Junior ask mailed +
seat mails staged + `docs/CYCLE.md` + checkpoint + the next-session spark.
Spec + tickets + council ride the next session (genuine scope break: the
pivot replaced the grill's Q1–Q7 mid-session — Rule 5 re-plan).

## RATIFICATION

- **RATIFIED-G (owner, hub chat s131, verbatim, in sequence):** (1) ONE BODY
  pivot — **"Approved"** (framing quoted in §Vision); (2) L3/L4/L5/L6 four
  rows + companions (L7 PvE-only) + program v22/v23/v24 (L15) —
  **"Approved but also merge Junior's ideas into the best product you can
  build and also orchestrate the ui/ux and assets seats"** → L14 + §Seats.
  **RATIFIED-G COMPLETE 2026-09-05** for L1–L7, L9, L14–L17; L8/L10–L13
  are candidates awaiting their tickets / the tour baseline.
- **RATIFIED-J (async, mailed `drafts/_junior-v22-one-body-ask-20260905.md`):**
  the pivot itself (his tower loops + PREMIUM surfaces are the most touched)
  · the art-lane fork (Option 1 vs 2) · his floors (L11) · the arena in his
  city plan (L14) · AfterSave pre-flight (`where python`/`where ruby`) ·
  `.pyc` untracking notice (`735a37c`).
