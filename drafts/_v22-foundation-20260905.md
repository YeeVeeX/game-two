# v22 FOUNDATION — ONE BODY + THE PRICED DEATH (grill record, 2026-09-05, s131)

STATUS: **RATIFIED-G (owner, hub chat s131) — COUNCIL PASS DONE s132; OWNER WORD
s132 (§RATIFICATION, verbatim): players DECOUPLED, temples / chosen respawn
(Tibia-like), the world PERSISTENT ONLINE AS A SERVER — sequenced by his
"Approved": v22 = ONE BODY built SERVER-READY (L19–L20), v23 = ONE WORLD
(L18, the server fork, own grill). Spec + tickets are cut in the NEXT session
on THIS file (`docs/superpowers/specs/2026-09-0X-v22-one-body-cycle.md`);
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
    the piece, with one verdict. _[council s132]_ the `coop.json` seats=2
    scalars (`human_hp_scale 1.25`, `respawn_delay_scale 3.0`) were tuned
    for 2 humans + 1 follower vs 1 human + 2 followers; T2 re-derives (or
    zeroes) the block as a named piece before the TWENTIETH.
(b) **Save schema.** `FACT_KEYS` (`src/game/save_state.rb`, `SCHEMA = 2`,
    exact-match) gains per-character facts. Approach: schema 3, one hop,
    refusal NAMED, proven on COPIES of both chains (L9); `--fresh` backup
    law intact.
(c) **Party persistence.** v18 law: the joiner never keeps the save. Under
    ONE BODY each seat's body is its character. Approach: per-seat character
    records INSIDE the host save (host-authoritative stays; identity = seat
    key from `data/netplay.json`). Lockstep identity unchanged.
    _[owner word s132 — SUPERSEDED in one respect:]_ records are keyed by
    **PLAYER identity, never seat number** (a machine-local player file,
    excluded from the fingerprint like `bindings.local.json`, sent in HELLO;
    exact shape = the spec's T1). The guest's record still lives in the
    host's save in v22 (joiner-never-keeps stands); v23's server holds every
    character by the same id — that is what "server-ready" means here.
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
      world level shared by both seats, today's model) contradicts L6's
      OWNERSHIP principle (one player's fine would reduce the other's
      progress) — not L6's text, which carries no progression rule
      _[council s132: both reviewers back per-character; owner line owed]_.
      **CLOSED s132 — owner: "each player writes their own story" →
      per-character, keyed by player identity (Rule 1c).**
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
      _[council s132, wording fix — the ORDER is law:]_ `fine = table(level)`;
      `fine = fine × (100 − 8·n) / 100` (Integer) when n insurance stacks are
      held; THEN `debt = max(0, fine − xp)`, `xp = max(0, xp − fine)`;
      insurance never touches debt directly; level never decreases.
- [x] **L6 — Coop death: INDIVIDUAL.** Your death sends you home
      (respawn timer + spectate = existing waiting-for-body path); the
      partner fights on. Shared wipe retired. **Owner: "Approved."**
      _[council s132 — BLOCKER found, amendment A1 PENDING OWNER WORD:]_ the
      World ticks ONE zone (`enter_zone`, `respawn_pack` move the whole
      world), so "home" is literal only in SOLO (the `:nest_respawn` veil,
      now priced). In COOP the dead seat spectates for `death.json`
      `coop_respawn_frames`, then respawns at the current zone's arrival
      tile (`arrival_tiles_for`), fine already paid; both dead = solo path.
      **RESOLVED s132 by owner word — A1 REJECTED (throwaway):** the real
      answer is DECOUPLED players waking at their own temple, which needs
      the v23 server world (L18). In v22: the PRICE is individual (each
      character pays its own fine, L5/L19) and SOLO death = veil → home
      temple; COOP death keeps TODAY'S rule (waiting-for-body spectate; both
      dead → home) as a NAMED interim that v23 retires. No coop-respawn code
      is written in v22.
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
      _[council s132:]_ companions have NO progression of their own (they
      are the same character's resting kits at the shared level); the XP
      cut = the hiring character's kill income × `companions.json`
      `xp_share_pct`. Amendment A3 (pending owner word): the
      `threat.json` `ally.enabled` flip that gives companions this brain is
      its OWN gated piece inside T2 under the canary law (`595b3ab`), never
      an implicit side effect of the pivot; waiting seats never claim a
      companion (A2, implementation law in T2).
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
      _[council s132:]_ schema 1 files REFUSE NAMED under schema 3 ("save
      schema: 1 unsupported (expected 3)") — no live v1 chain exists (both
      peers' saves are v2); `upgrade_v1` retires with its frozen key set.
- [ ] **L10 — The TWENTIETH.** Delta = A+B′+C+D (B′ = temples, L19; the
      individual-coop-death piece moved to v23). Pre-registered rows:
      `deaths`, `xp_lost`, `xp_debt_paid`, `insured_deaths`,
      `insurance_bought/consumed`, `form_swaps`, `companion_hires`,
      `time_to_continue`; free-verdict re-asks growth A/B + "did dying cost
      something you felt" _[council s132: + "did the companion earn its
      price?" (A3)]_. Declaration arms the freeze; ≤48 h window; bot
      logs never fun evidence. Wording frozen at declaration, not before.
- [ ] **L11 — Floors as visible truth (Q8b, lane F).** If the banner shows
      the floor ("ZONE 5 · -3") the 8 LEGACY rows in
      `authoring/world_graph_allowlist.json` become visible lies. Rec:
      nest → -1, slow_door → -2 or -3 (owner pick), retype/remove the camp
      east door; each fixed row leaves the allowlist (suite forces it).
      Junior ratifies (his floors). Owner word pending. **Junior's picks
      LANDED `195a01f`: nest −1 · slow_door −2 (−3 is the moss) · camp east
      door REMOVED** — F1 builds these unless the owner says otherwise.
      **Owner "confirm" s133 → CLOSED (both peers).**
- [ ] **L12 — Art lane (presentation, owner-directed).** Baseline = the
      owner's one-line read of `captures/clips/tour_20260905_head_3e2bfb6.mp4`
      (rendered from `3e2bfb6` = Junior's HUD commit) — PENDING. References,
      palette, who draws, where tiles are authored (Option 1 LDtk bakes vs
      Option 2 engine dual-grid — brief §3.7; Junior's word, never decided
      against him). **Junior's word LANDED `195a01f`: Option 2 now, Option 1
      for borders/props later.** Assets seat commissioned (§Seats).
      **BASELINE LANDED s133 (verbatim §RATIFICATION (3)) + owner word "A
      now" (3b): the sealed visual bible in `game-two-lore` is the art
      lane's LAW (forms/palette/light/composition); fiction stays out; the
      lane is a REVAMP — scale ticket first, authorship off the generator,
      tile grammar, then the v22 surfaces. Charter:
      `drafts/_v22-art-lane-charter-20260905.md`.**
- [x] **L13 — Totem: RE-WORK (owner word s133).** "pulse every 3 seconds and
      heal more, like 30hp and scale by level/hp pool" → ticket TS (spec),
      data-driven in `sustain.json`, one gated SIM piece, judged at the
      TWENTIETH. Detail §RATIFICATION s133 (5).
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
      **RE-SEQUENCED s132 by owner word (L18):** **v23 = ONE WORLD** (the
      server fork) · **v24 = THE REWARD** (Junior's SYSTEMS plan, unchanged
      in content) · **v25 = RIVALS** (PvP, trade, chat — "fight against each
      other, trade, chat" ride the server, where they are sane). Large-scale
      wars stay OUT until the server world exists and is measured. Whether
      S1–S3 ride v22's back half stays a BOTH-SEATS line. **CLOSED s133 by
      owner delegation ("as you both consider best") — YES: S1 after T1
      (data-only), S2 + S3 after the TWENTIETH's verdict as v22's tail,
      TWENTY-FIRST delta-triggered; detail §RATIFICATION s133 (1).**
- [x] **L18 — ONE WORLD (v23): the persistent online server world.** Owner
      word s132 (verbatim): "decouple players, they should respawn on a
      temple or select their own place of respawn across the cities and
      points of interest of the world (don't overdo, follow a Tibia-like
      pattern), world should be persistant online as a server and each
      player writes their own story while they can also meet in the world
      and team up or fight against each other, trade, chat, etc" → dev
      recommendation (a) — v22 ONE BODY built server-ready, v23 = the fork
      — **Owner: "Approved".** This PROMOTES the parked always-online item
      (PARKING_LOT, trigger "cuando tú lo decidas y lo recomiendes" fired by
      recommendation + owner word); nothing is deleted. Shape (grilled in
      v23's own foundation, not here): server-authoritative sim (one
      always-on process owns the world; clients send inputs, draw the
      server's state — Tibia's model; the desync class and the owner-side
      CGNAT wart disappear by construction) · multi-zone World (every zone
      with a player ticks; empty zones frozen + catch-up, today's law) · full
      zone-state snapshot + join-in-progress · server-side persistence of
      per-player characters · host = a small AWS instance ON THE TAILNET
      (trusted overlay stays; ~$15–20/month, inside-AWS spend: declared,
      not asked). Honest cost: the largest fork the project can take — on
      the order of 10–20 sessions before both peers log in; the wall gains a
      server+client-in-one-process harness lane (netplay scene precedent).
      The cheaper "shared world in turns" (cloud save custody) was offered
      and NOT chosen.
- [x] **L19 — TEMPLES (v22, lane B′ — replaces individual coop death).**
      Tibia pattern, "don't overdo": every HUB zone has a TEMPLE station; a
      character's `home_zone` is a per-character fact; SET HOME = the temple's
      station verb (interact); death → wake at YOUR home temple (solo: the
      veil, priced). Placement = hubs only in v22; "points of interest" =
      named by the owner later, one line each, never free placement.
      `home_zone` already exists (per world, hub-only, save-validated) — this
      row moves it into the character record and adds the verb; T3 (coop
      individual death) is CANCELLED as a v22 ticket. Coop interim: L6 note.
- [x] **L20 — SERVER-READY laws (bind every v22 ticket; the spec restates
      them):** (1) characters are keyed by PLAYER identity, never seat; seats
      map to characters at session start (Rule 1c). (2) No new rule assumes
      both players share a zone — party-shared XP = "living characters in the
      SAME zone", evaluated per zone. (3) The character record (schema 3
      `characters`) is the persistence unit — the server's account row later.
      (4) New surfaces (HUD row, ledger card, insurance pip) read through a
      narrow `Character`/`Party` reader, never World internals — a thin
      client can feed the same reader. (5) No new lockstep-only mechanism
      beyond what exists. (6) The `world.rb` extraction owed at T2 carves a
      per-zone state object (`ZoneState`: humans, corpses, projectiles,
      volleys, transients, flow cache) — the FIRST multi-zone step; World
      keeps ticking one zone in v22. (7) Nothing in v22 opens the server
      itself (no sockets, no hosting) — that is v23's grill.
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
      pin state before each. _[council s132, count corrected by grep:]_ 13
      scripts press `swap` (`aoe_specials dash_strike_rip level_up_beat
      lobber_reach lobber_volley loot_loop respawn_telegraph specials_chain
      taunt_anchor threat_pull toll_pocket vat_economy world_loop`) + 5
      wipe/corpse stagers = **18 re-authors**; all 42 scripts re-pin
      (~3.5 h detached per sweep).

## Lanes + staging (serial, one gated increment per re-session)

- **Lane A — ONE BODY (the first felt change):** body select at the vat
  (Tab → station verb, other bodies rest), companions hired (L7), ally
  followers leave the field, camera/HUD to one body + party rows, coop =
  one body per seat. Sim identity moves everywhere → full wall re-author +
  re-pin priced as the ticket's cost. Save schema 3 rides here (L9).
- **Lane B′ — TEMPLES (L19; replaces "YOUR DEATH IS YOURS" as a v22
  lane):** per-character `home_zone` + TEMPLE station verb SET HOME at every
  hub; solo death → veil → YOUR temple, priced. Coop death = today's rule,
  named interim (L6 note). Individual coop death/respawn = v23 (L18).
- **Lane C — THE PRICE:** `data/balance/death.json` fine + debt (L5) →
  insurance at the bank (L8) → death ledger card + insurance pip (Rule 2
  rows). Pure math + tests first, surfaces after the uiux spec (A3).
- **Lane D — POWER TO STAND ALONE:** form swap (L4) + growth retune +
  cooldown abilities (two per form, `data/balance/forms.json`); pacing
  table re-run; soaks per zone.
- **Lane E — DEBTS:** T0 review first; then L16 items as small tickets.
- **Lane F — FLOORS + CITY:** L11 floor truth; the 2× city with the arena
  region drawn (L14) — the arena is INERT until v25.
- **Lane G — ART (presentation, owner-directed, parallel):** charter
  `drafts/_v22-art-lane-charter-<date>.md` (written when L12's baseline
  lands); assets seat + uiux seat commissioned by mail (§Seats); death-cycle
  and one-body surfaces designed once in the new grammar.
- **Lane H — ONE WORLD PREP (v23 grill input, docs + spikes only):** the
  `ZoneState` extraction (L20.6) rides T2; a v23 grill spark is written at
  v22's close with the measured facts it needs (tick budget per zone, zone
  snapshot size, join-in-progress shape, AWS host sizing). No server code
  in v22 (L20.7).

Order: T0 → A → B′ → C → D → TWENTIETH declaration; E/F/G/H interleave at
the peers' word. First SIM delta ships at A (the model itself).

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

## Council pass (Rule 6) — DONE 2026-09-05 s132 (Gabriel seat)

- [x] DeepSeek V3.2 adversarial pass over this FULL file inlined + code facts
      (`tmp/council_s132/brief.md` md5 `b16c7c528144d34c0188659483299e4f`,
      39,533 bytes; in 11,445 / out 2,083 tokens, $0.004)
- [x] Kimi K2.5, same brief (in 10,953 / out 3,591 tokens, $0.025)
- [x] every REFUTED item re-verified against primaries (below). Total spend
      $0.03 of the ≤ ~$2 budget. Raw JSON: `tmp/council_s132/out_{deepseek,kimi}.json`
      (scratch; the verdict table here is the record).

**Findings both reviewers CONFIRMED (dev claims C4–C7 in the brief):**

1. **L6 has a hidden zone coupling — BLOCKER.** The World simulates ONE
   current zone (`World#enter_zone`: "the whole pack teleports through
   gates"; `respawn_pack`: `@zone_name = @home_zone` moves THE WORLD). "Your
   death sends you home ... the partner fights on" cannot be literal in
   coop. **Amendment A1 (sim-changing → owner word owed, see
   §RATIFICATION):** SOLO death = the existing `:nest_respawn` veil → home,
   now priced (today's wipe path). COOP death = the dead seat spectates for
   a data-driven timer (`death.json` `coop_respawn_frames`), then its body
   respawns at the CURRENT zone's arrival tile (`World#arrival_tiles_for` —
   already exists per zone, no new structure; Kimi's "needs a new spawn
   point" attack REFUTED on `@arrivals = Crossing.validated_arrivals`), fine
   already paid at death; BOTH seats dead = the solo path. Kimi's
   alternative (wait for the partner's next gate crossing, no timer) is
   REJECTED: unbounded spectate is the recorded waiting-for-body feel risk
   (`world.rb` "recorded half-B feel risk"); the timer bounds it.
2. **`assign_waiting_seats` would auto-possess a hired companion** ("first
   living uncontrolled body in ROSTER order") — a dead player would
   "become" the hireling. **Amendment A2 (implementation law, into T2):**
   the roster/party object distinguishes player characters from companions;
   waiting seats never claim a companion; `Pack#wipe?` = every PLAYER body
   dead (companions alone never hold the field).
3. **L17 undercounts the wall.** 13 wall scripts press `swap` (Tab):
   `aoe_specials dash_strike_rip level_up_beat lobber_reach lobber_volley
   loot_loop respawn_telegraph specials_chain taunt_anchor threat_pull
   toll_pocket vat_economy world_loop` — all 13 RE-AUTHOR (Tab's meaning
   changes) plus the 5 wipe/corpse stagers named before (`corpse_run
   nest_advance ledger_loop mercy_floor sustain_run`) = 18 re-authors; every
   one of the 42 scripts RE-PINS (one body in the field diverges every
   replay). ~5 min/script → ~3.5 h detached per full sweep, two sweeps in
   the cycle. **Adopted into L17.**
4. **Coop scalars need re-derivation** (`coop.json` seats=2:
   `human_hp_scale 1.25`, `respawn_delay_scale 3.0` were tuned for 2 humans
   + 1 follower vs 1 human + 2 followers; the field becomes 1–2 player
   bodies + 0–2 companions). **Adopted into Rule 1(a):** T2 re-derives the
   seats=2 block from the pacing table (or zeroes it) as a named piece; the
   TWENTIETH judges.
5. **Per-character records must enter the per-tick digest** (today
   `digest_snapshot` carries one `level`/`xp` pair in `world_fields`).
   **Adopted into T1:** `Character#digest_fields` (level, xp, xp_debt,
   insurance, form, body) per seat, test-pinned in `state_digest_test`.

**Disagreements reconciled against primaries:**

- DeepSeek REFUTED C3 ("L5 says flat 10% of ΔE, not pure Progression
  math") — misread: the 10% is a `death.json` TABLE input; `Progression#fine!`
  applies it in Integer math. Claim stands; L5's wording gets the split
  spelled out (below).
- Kimi CONFIRMED the L5/L8 wording clash ("debt × (1 − 8%·n)" vs "reducer
  of the fine"). **Adopted, non-sim (L5 wording):** insured fine =
  `fine × (100 − 8·n) / 100` (Integer), THEN `debt = max(0, fine − xp)`,
  `xp = max(0, xp − fine)`; insurance never touches debt directly.
- Kimi UNCERTAIN on L3's "contradicts L6": fair — L6's text carries no
  progression rule. **Clarified (L3):** a shared world level makes one
  player's fine reduce the OTHER's progress — it contradicts L6's ownership
  principle, not its text.
- Both: **coop progression = per-character** inside the host save with
  party-shared kill XP (recorded as the council's read for the owner;
  §RATIFICATION). Kimi's coupling: do companions take XP? **Answer (L7
  clarification):** companions have NO progression (they are the same
  character's resting kits); the hiring character's kill income is
  multiplied by `companions.json` `xp_share_pct`. Both: **schema 1 saves →
  REFUSED NAMED** under schema 3 ("save schema: 1 unsupported (expected
  3)"); no live v1 chain exists (both peers' saves are v2); chaining 1→2→3
  would ship an untested path. **Adopted into L9/T1.**
- Kimi's biggest unnamed risk: **the companion brain is a sim-changing
  assumption dressed as reuse** — `595b3ab` ships OFF, was tuned for
  3-body pack coordination, and no fun-verify row targets companion feel.
  **Amendment A3 (adopted, gating):** the `threat.json` `ally.enabled` flip
  is its OWN gated piece inside T2 under the canary law (owner ratification
  + stream-diff audit + versioned canary rebank, as `595b3ab`'s message
  says); L10 gains the free-verdict re-ask "did the companion earn its
  price?". PvE-only stays structural (no PvP space exists until v24).
- DeepSeek's difficulty MAJOR ("companions optional may not compensate") —
  agreed as a RISK, not a defect: Rule 1(a) already routes it to the
  TWENTIETH with soaks + `rake perf` as mechanical gates; item 4 above adds
  the coop-scalar piece.

**Owner-word owed before ratification (sim-changing):** A1 (coop respawn
location) · the coop progression row (per-character, council-backed) · A3
(companion-brain flip as a gated piece — a process amendment; owner word
confirms). Recorded in §RATIFICATION as OPEN until his line lands.

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
  **LANDED `195a01f` (Junior, 2026-09-05 15:50 -0300, "aceito as
  recomendações"; verbatim, harvested s132):**
  `RECEIPT: J-v22 1 sim. As 3 FORMAS = os 3 kits atuais (Fio/Aro/Pomo): zero arte perdida, os 3 especiais ficam, a terceira forma se ganha (D). Torre e BRASA re-afinam pra um corpo; companheiros cobrem o buraco enquanto isso, como previsto.`
  `RECEIPT: J-v22 2 opção 2 agora (dual-grid no engine, gen_tileset.py), opção 1 pra bordas/props depois.`
  `RECEIPT: J-v22 3 nest -1 · slow_door -2 (antessala da descida; o -3 é o musgo) · porta leste do camp: remover.`
  `RECEIPT: J-v22 4 sim — o pátio de treino (D6) vira a ARENA DE DUELO; o hub segue safe fora dela.`
  `RECEIPT: J-v22 5 ok — pré-voo rodado 2026-09-05 15:47 no cmd: where python → C:\Users\q\AppData\Local\Programs\Python\Python314\python.exe (Python 3.14.7); where ruby → C:\Ruby34-x64\bin\ruby.exe. A linha do comando resolve como está.`
  `RECEIPT: J-v22 6 ciente.`
  `RECEIPT: J-v22 L15 S1–S3 (catálogo+ícones · bolsa+drops de item · consumíveis+status) na segunda metade do v22: SIM — a metade do Junior da linha dos dois; S4–S7 no v23. Aguarda a linha do Gabriel; nada de S1 antes dela.`
  **Effect:** the pivot is RATIFIED by both peers (L1 complete); tile fork =
  Option 2 now, Option 1 for borders/props later (L12 art charter A2 takes
  the Option-2 branch); L11 floors = nest −1, slow_door −2, camp east door
  REMOVED (his maps — owner word still welcome, not gating); arena yes (L14);
  AfterSave pre-flight green on his machine; S1–S3 in v22's back half is
  Junior's half of the BOTH-SEATS line — **Gabriel's half owed** (his
  "S4–S7 no v23" predates the s132 re-sequence: content unchanged, that
  cycle is now v24 THE REWARD). The kit nicknames in receipt 1 are his
  words in his file (verbatim law); code/data/docs authored here stay on
  kit names (T0 finding, docs-only).
- **RATIFIED-G s132 (owner, hub chat, verbatim, in sequence):** asked A1
  (coop respawn location) in detail → **"decouple players, they should
  respawn on a temple or select their own place of respawn across the cities
  and points of interest of the world (don't overdo, follow a Tibia-like
  pattern), world should be persistant online as a server and each player
  writes their own story while they can also meet in the world and team up
  or fight against each other, trade, chat, etc"** → dev named the fork's
  cost + three options (a: content now server-ready, server next · b: server
  first · c: shared world in turns) and recommended (a) → **"Approved,
  proceed to design the next session spark-up prompt ..."** → L18 (ONE
  WORLD = v23), L19 (TEMPLES), L20 (server-ready laws), L15 re-sequenced,
  L3 sub-row CLOSED per-character/per-player, L6 A1 REJECTED, T3 CANCELLED.
- **RATIFIED-G s133 (owner, hub chat, verbatim, in sequence; asked one at a
  time per his s132 request):** (0) assets seat unblock — asked "Do I record
  'retire `ring_expand_rect` (ring → halo)' as your word so the assets seat
  can commit and push?" → **"yes"** (2026-09-05). Effect: the assets seat
  applies the four `sha256_lf` pin pairs its `pin_drift.py` printed, commits
  the 44 staged art-direction files, pushes detached (its pre-push gauntlet
  ~3.5 h); carried to it by seat mail from this session. (1) **Gabriel's half
  of the S1–S3 line (L15)** — asked yes / no / after the TWENTIETH → **"I
  approve Junior's and your ideas as you both consider best"** (2026-09-05).
  Effect: the BOTH-SEATS line is CLOSED as YES by delegation — S1–S3 ride
  v22 (Junior's half `195a01f` + the owner's approval); the SEQUENCING is
  the devs' call and the dev of record sets it here, Junior's line may amend
  it (peer, not worker): **S1** (catalog + strings + icons; data only, no
  sim) may land any time after T1 — it never touches the TWENTIETH's delta;
  **S2 + S3** (SIM-class: bag + item drops + pickup; use-item + status
  registry + burn DOT) start only AFTER the TWENTIETH's VERDICT, as v22's
  tail, each its own gated piece with canary rebank + `loot_loop` re-author,
  judged by a delta-triggered TWENTY-FIRST (ritual reform 2026-08-28: SIM
  change accumulated ⇒ ritual owed). Why this order and not "inside the
  TWENTIETH's delta": the TWENTIETH must answer L1's one question (did ONE
  BODY + priced death + temples + growth work) — an item loop landing in the
  same delta confounds "growth felt" (items ARE growth) with lane D's retune,
  and S2's canary rebank cannot run inside the measurement freeze anyway.
  Junior's P5 (bag 20) is S2's number unless a peer overrides; P2–P4 and
  S4–S7 stay v24 THE REWARD. (2) **A3 companion-brain flip** — asked A (gated
  piece in T2) / B (stays OFF), with the dev recommending A → **"not sure,
  doesn't convince me"** (2026-09-05). Effect: **OPEN, default OFF** —
  `threat.json ally.enabled` stays false through v22 unless a later owner
  line lands; T2 carries the flip only as an OPTIONAL sub-piece behind an
  evidence step (two scripted clips of one encounter, brain OFF vs ON, from
  the flywheel clip tool — dev inspection, never fun evidence) that the
  owner watches before any decision. The dev's argument was a brief; the
  project's law is "judge builds, not briefs" — the owner applied it. Not
  re-asked. (3) **Tour baseline (L12)** — he watched
  `captures/clips/tour_20260905_head_3e2bfb6.mp4` in session → verbatim:
  **"to be honest it looks so much better tan before, a lot. But still
  doesn't meet modern quality expectations, still looks like a dated game
  from the first generations. How to get an style closer to our vision? I
  know many things would need to be revamped such as the size of each asset
  or the zoom in of the camera to make things look bigger, plus many other
  animations, maps, assets, I just don't understand why we aren't following
  up our lore or whatever, what are we doing wrong that should be done
  differently?
  C:\Users\gabri\workspace\game-two-lore\drafts\visual-storyboard"**
  (2026-09-05). Effect: L12 baseline LANDED; the pointer names the SEALED
  visual bible (`game-two-lore/drafts/visual-storyboard/concept/
  biblia-visual-v10-20260828.md`, "ley vigente", sealed by the owner
  2026-08-28 "me parece bien, adelante") — a visual direction game-two's art
  never received (dev diagnosis + the one question it raises: §RATIFICATION
  s133 (3b), asked in session). (3b) **Art direction crosses the wall** —
  dev diagnosis given in session (three causes: the NO-LORE wall also kept
  the sealed visual bible out of game-two, so the assets seat derived a
  second bible from Junior's sprites; every sprite is drawn by a Python
  generator whose ceiling is first-generation by construction; scale —
  960×540 logical, 32-px tiles, 30×17 tiles on screen, a 48-px character =
  9% of screen height vs 13–18% in the modern pixel-ARPG class). Asked A
  (art direction crosses, fiction stays out) / B (reopen lore in the game,
  reverses the 2026-08-16 order) → **"A now"** (2026-09-05). Effect: the
  sealed visual bible (`biblia-visual-v10-20260828.md|.png`, md5
  `10e0d81ebbc650a48a8c82ce72a7b370`) is the art lane's LAW for forms,
  palette, light and composition; the assets seat's 40-colour bible becomes
  SUBORDINATE (derived from the sealed one, never beside it); the standing
  NO-LORE order's TEXT is intact — no fiction name or story line enters
  code/data/docs/screens (kits stay striker/blocker/lobber; ZONE N / BOSS 1
  stay). The art charter (lane G) is re-scoped as a REVAMP anchored to the
  sealed bible: a SCALE ticket first (logical resolution + tile px + frame
  size decided once from the storyboard's proportions, judged by both peers
  on a scratch tour, presentation-only), then authorship off the generator
  (Bedrock concept → Aseprite at native size → atlas via the assets seat's
  pipeline), then tile grammar (texture, wall depth, baked shadow; the grid
  order rides here), then one-body / death / temple surfaces. Runs parallel
  to lanes A–D; never blocks the TWENTIETH; one full wall re-pin per landed
  atlas batch. (4) **L11 floor picks** — asked confirm / override of
  Junior's landed picks (nest −1 · slow_door −2 · camp east door removed) →
  **"confirm"** (2026-09-05). Effect: L11 CLOSED by both peers; F1 builds
  these numbers through the LDtk → importer path; each fixed row leaves
  `authoring/world_graph_allowlist.json`. (5) **L13 totem** — asked keep free
  / re-price / retire / later (dev rec: keep free through v22) → **"re-work,
  15 seconds its too much, I would make it pulse every 3 seconds and heal
  more, like 30hp and scale by level/hp pool"** (2026-09-05). Effect: L13 =
  RE-WORK, an owner design word that OVERRIDES the dev rec (recorded, not
  re-litigated). SIM-class → its own gated piece in the spec (ticket TS,
  lane C's sustain economy): `data/balance/sustain.json` gains the cadence
  (3 s = 180 ticks at the 60-tick second; today 900) and a heal that scales
  with the character's hp pool (shape candidate: a percentage of max hp with
  a floor near 30 hp at today's mid-level pool — numbers via
  `tools/pacing_table.rb`, CANDIDATES until his word is on the row); Rule 2
  row for the pulse cue; existing totem-vs-potions TELEMETRY re-read at the
  TWENTIETH. Junior built the totem — his line on the numbers welcome, not
  gating.
- **OPEN after s133 (never nagged; a later owner line lands here verbatim):**
  (1) **A3 companion-brain flip** — "not sure, doesn't convince me" → default
  OFF; evidence step (two clips) precedes any re-ask, owner-initiated. All
  other s132 OPEN items CLOSED s133: S1–S3 half (delegated, YES), tour
  baseline (landed) + art direction crossing ("A now"), L11 ("confirm"), L13
  ("re-work" + numbers). Still owner-pending elsewhere (CYCLE.md): FASE 7
  city numbers (D1 2×, D8 offset) confirm · audio-v12 ear-checks · worldsmith
  v2 grill · a third gamesmith `extract` ($).
