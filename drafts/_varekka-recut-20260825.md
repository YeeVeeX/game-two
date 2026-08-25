# varekka_duel re-cut (option a) + lobber_volley wall script — s73, 2026-08-25

**Ratification chain:** s60 STOP evidence
(`drafts/_varekka-repilot-rebrief-20260824.md`) → owner options → s66
line 2 (Junior's pick, lunch-window record in
`drafts/_coop-s1-20260824.md`): **(a) re-cut the script + manifest to
what honest play under the current laws actually produces** — numbers
are the dev-of-record's proposal, gates decide capture identity, this
record makes it lawful. Executed s73 (Gabriel's seat). This ticket also
owed the lobber-volley wall script (s66 canary note: no pinned replay
casts specials).

## What shipped

1. `harness/scripts/varekka_duel.json` — NEW input stream (seed 7,
   start unchanged: low_quay, banked 600, run_until 2682). Manifest
   re-cut per DOUBLE replay: `challenger_engaged 2 ·
   challenger_chant_started 2 · vessel_seized 2 · seizure_ended 2 ·
   drop_picked_up 10` (per run: 1/1/1/1/5). Gate PASS (7 captures
   byte-identical ×2 runs + vision 60/60) + MANIFEST PASS
   (`tmp/gate_varekka_recut2.log`).
2. `harness/scripts/lobber_volley.json` — NEW wall script (district,
   seed 11, run_until 1432; wall 34→35). Manifest per double:
   `special_started 4 · attack_hit 106 · actor_died 34 ·
   drop_picked_up 2`. Gate PASS + MANIFEST PASS
   (`tmp/gate_lobber_volley.log`). No new gate_checks row — existing
   rows exercised and judged live: `volley_telegraph_distinct`,
   `specials_distinct`, `burst_legibility_budget`, `kill_pop_reads`,
   `special_pips_track`.
3. Canary REBANK #2: ACTIVE varekka `31c699cb…` → `bf35628a…`;
   outgoing bank preserved as `S59_HISTORY`
   (test/harness/sim_identity_canary_test.rb; one-line record in
   `drafts/_j7b-canary-rebank-20260824.md` §s73). world_loop +
   burn_duel hashes untouched — suite green 1245/22642.

## The honest varekka profile — and the delta from the s60 sketch

The s60 option-(a) sketch estimated per run: 2 chants = 1 interrupt +
1 completion + boss kill + drop pickup. **Seventeen interactive pilot
generations (tmp/pilot/vk3, this session; drive log preserved) proved
that sketch still over-reads what current laws allow.** The shipped
profile is what honest play reproducibly earns: **one chant that
COMPLETES (pin = the possessed body, decision 11), a real seizure with
an honest end (`why=died` — the 39hp lobber vessel), five drop
pickups, and the pack surviving the wave + retreat** — no interrupt,
no boss kill.

Why the richer profile is not honestly drivable (each confirmed
live, generations cited):

- **Ally autonomy has no steering verb** (s60 finding 1, unchanged —
  the ratified Lane-3 C2/C3 gap): any free ally within aggro 10
  auto-attacks the boss. A completion cycle with a live free ally gets
  interrupted by ally fire (vk3-2, vk3-8); an interrupt cycle with a
  live free ally becomes a trade-lock that kills the boss in ~360f
  (27dmg blocker swings; vk3-2: 140→32 before any second chant).
- **Interrupt + completion compete for scarce bodies.** The only
  deterministic completion is a ZERO-free-ally pack (the pin body +
  nothing else alive/free). After the vessel dies, one body remains —
  and the interrupt window is 120f against the boss's post-shed
  behavior:
- **Boss home-deafness (new law finding, vk3-15/16/17):** after his
  focus sheds (beachhead shield), he leashes home and does NOT
  re-acquire from range — parked at [43,15] for 400+ frames with an
  acquirable pack body standing in the open at distance 37 (aggro_tiles
  45 notwithstanding; re-acquire empirically needs ~10-12 proximity).
  Reaching him means crossing the south/east wake fields — a 5-8-body
  swarm the surviving body cannot honestly beat (vk3-3/5/13/14 all
  died to exactly that pressure).
- **The chant timing law (discovered vk3-11):** the chant fires the
  first eligible tick — cooldown-0 + nearest controlled ≤7 — INCLUDING
  mid-walk. On these rails that is frame ~2010 (seizure-1 ends 1402 +
  600 cooldown + ~8 pathing). Every dash-to-interrupt at ring 5-7
  through the contested mid-field lost to walls (pillars [8,3]/[14,6]),
  chewer body-blocks, or knockback shoves (vk3-9/10/11/12 — four
  documented misses, one by ONE frame).

The interrupt beat and the boss-kill beat are RECORDED as re-earnable
the session Lane-3 C2 (ally defensive-default) ships a steering verb —
the exact unlock s60 finding 1 named. Until then, a manifest demanding
them demands the exploit back or demands luck; both are dishonest.

**What the wall still exercises (all judged live, gate PASS):** the
boss's full remaining grammar — SPAWNED stamp (capture 320, gold rule
pair judged), chant ring + floating square tell (1180), writ-frame
darkening (1180), seized underline + body darkening (1300),
vessel-death beat (1360), the shield-edge sweep kill-pops (1565), the
wave + hoover + carried numeral (930, 2620). The reel is a complete
honest story: wave → hoover → the boss calls and takes a vessel → the
pack escapes, regroups, and loots.

## lobber_volley — base volley cast grammar (the s66 canary gap)

Story (seed 11 district): swap to lobber at 0 → WHIFF cast at 20
(telegraph 35 + empty-tile impact 61 on camera — the base 3-tile
chain at L1-2, visually distinct from lobber_reach's L5 4-tile) →
mid-field brawl context (1080) → corridor cast THROUGH the pack
blocker's bracket tile (1180 — pack-immunity + the D2 covers-fix on
camera) → **volley impact-hit lands on rusher8** (1204,
`attack_hit attacker=lobber` via the delayed record) → aftermath +
corpse field (1290) → drop pickup + carried numeral (1330).
Design note: bracket range (2-4) sits entirely inside human aggro
(10), so a resting target can never be volleyed cold, and a glued
chaser (13f steps vs lobber 16f) never re-enters brackets — honest
volley hits come from approach-crossing or brawl-adjacent targets.
That is the verb's real grammar and the reel shows it.

## Blast-radius call (recorded)

Script-only ticket: `git status` at close = 2 wall scripts + the
canary test + this drafts family. ZERO src/ or data/ changes — the
full wall sweep is NOT owed (spark law: judge by blast radius). The
two changed slots were themselves gated critic-ON + manifest, twice
for varekka (capture re-plan 155→320 to put the SPAWNED stamp on
camera). Suite 1245/22642 green (assertion delta +6 = wall-directory
iteration picking up script 35).

## Artifacts

- Pilot campaign: `tmp/pilot/vk3/` (17 generations, log.txt 1.9MB) ·
  `tmp/pilot/lv1/` (2 generations).
- Gates: `tmp/gate_varekka_recut.log` / `tmp/gate_varekka_recut2.log`
  / `tmp/gate_lobber_volley.log`; suite `tmp/suite_s73.log`.
- Headless verifies: `tmp/vk_verify.rb` / `tmp/lv_verify.rb` (double
  identity + event counts through the banked etapa-0 instrument path).
