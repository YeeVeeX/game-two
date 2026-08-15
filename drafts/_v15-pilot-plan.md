# v15 pilot plan — quay1 (harvested at goalcomp; execute/continue after compact)

Pilot LAUNCHED: `rake pilot NAME=quay1 SEED=7` (background task at goalcomp
time; if the window died, relaunch — same name resumes nothing, it starts
fresh; that is fine pre-export). Inbox: `tmp/pilot/quay1/inbox.txt`
(APPEND-ONLY via printf). Log: `tmp/pilot/quay1/log.txt`. Idle = frozen sim.

## Route (seed 7, all zone facts measured from data/zones/*.json)

1. Nest (First Vigil): spawn [14,8]; bank [12,8]; exit east [29,8] →
   district [1,13].
2. The Longrow: gradient 1.0/1.5/2.0 (anchor [1,13]); hunt to ~50 carried
   (buffer over 40), return, bank at NEST (camp is behind the seal).
   Capture: Longrow banner, a whirl clump, bank numeral.
3. Seal1 [41,13] price 40 (breach_cost) → capture sealed read + THE WAY IS
   PAID. Step [42,13] → camp [1,5].
4. Camp (Second Vigil, hub — REHOMES): bank [8,4]; capture banner. Exit
   east [19,5] → district_two [1,13].
5. The Keyward: gradient 2.0/2.5/3.0; hunt deep to ~160 banked total
   (round trips to camp bank as needed — carry risk vs trip cost).
   Capture: Keyward banner + deep fight + bank numeral.
6. Seal2 [41,13] price 150 (breach_cost_2) → capture + breach. Step
   [42,13] → slow_door [7,6].
7. Slow Door: capture landing/banner. Descend [7,1] → low_quay [2,4].
8. THE LOW QUAY beats (Varekka at [43,15]; crew: rushers deep at [41,13],
   [38,18],[35,14]; haters [42,18],[36,16],[43,4]):
   - Low Quay banner + wide shot (channel rows 9-10, bridges x14-16/x30-32)
   - approach east: ONE STANDS stamp (first pack contact)
   - clear the crew AROUND him first (whirl), then duel
   - chant tell capture (deep-blue ring + glyph above pinned vessel)
   - INTERRUPT one chant (hit him mid-chant) — capture
   - let a second chant COMPLETE: THE FLESH IS CALLED + seized underline
   - seized walk: two captures a few tiles apart
   - swap escape mid-seizure (Tab) — capture
   - kill him: THE TERM IS PAID + fat drop (8 x 4.0 = 32) — capture
   - grab drop (two-press rule if stacked)
9. Climb back CARRYING: [1,4] → slow_door [7,2]; [7,7] → district_two
   [40,13]; west to [0,13] → camp [18,5]; bank [8,4] — final capture.
10. `export low_quay_run` → harness/scripts/low_quay_run.json (out_dir
    rides the export; add the manifest key AFTER export — see below).

## Manifest to add to low_quay_run.json after export (per DOUBLE replay)

{"challenger_engaged": 2, "challenger_chant_started": 4,
 "chant_interrupted": 2, "vessel_seized": 2, "seizure_ended": 2,
 "seal_breached": 4, "banked": 4, "drop_picked_up": 2}

seal_breached ≥4 CLOSES the #41 coverage gap (zero wall scripts staged a
breach since v12 — recorded in the v14 wall log).

## Pilot doctrine pointers (do NOT re-derive — drafts/_v14-wall-log.md)

Per-kit step timing 13/16/19 f/tile (striker/lobber/blocker); melee =
`hold attack,<dir>`, ranged = tap-face then stationary; dodge dashes along
facing; `press interact` eaten by attack recovery (wait 15-20 first);
two-press rule on stacked tiles; goto aborts leave you standing — holds in
contested ground; `speed 20` + `wait N` to fast-forward; wait 25 after
swap; hitstop pauses the sim after kill bursts (drive ≥10 ticks before
asserting). Commands: hold/press/wait/goto [guard=N]/capture [label]/
state/speed/export/reset/quit.

## v15-specific staging notes

- Seized-and-possessed: direction+dodge DEAD, attack/special/mark/interact
  live, re-aim via held direction works. Tab always escapes (even
  staggered — built exemption).
- The seized body walks at ITS kit cadence to Varekka and stands adjacent;
  he will attack it. Cost is real — stage the swap-escape EARLY in a
  seizure if the body must survive.
- Interrupt = ANY damage to him mid-chant; cooldown 600f after interrupt
  or seizure end; he cannot re-chant DURING his own seizure.
- Chant range 7, chant 120f, seize 450f. His melee: 15 dmg, ring, kb 1.
- After wall: verdicts from tmp/wall/<script>_v15_a1.log teed logs +
  `rake manifest SCRIPT=... LOG=...` per script (NEW machine check).

## Wall plan (after script lands)

Full re-run, 15 scripts: low_quay_run FIRST, then v14 order (moving_square,
critic_reel, world_loop, district_hunt, loot_loop, corpse_run, threat_pull,
ledger_loop, vat_economy, specials_chain, taunt_anchor, aoe_specials,
nest_advance, respawn_telegraph). ONE window at a time; tee to
tmp/wall/<script>_v15_a1.log; retry law 2 attempts INFRA-only; re-pilot
budget 3-6; manifest check after every gate. Then perf + full suite.
