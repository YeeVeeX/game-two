# J-T2 — DUNGEON 2 paper blueprint: "Antechamber ladder" (Junior seat, 2026-08-26)

Ticket: `drafts/_junior-parallel-lane-20260826.md` J-T2. Blueprints
candidate A from `drafts/_junior-dungeon-dossier-20260826.md` §4 (with
B's gradient trick folded into chamber 2, per the seat recommendation).
PAPER ONLY: no .ldtk, no data/, no numbers that belong to balance.
Indicative dims/coords are AUTHORING geometry (zone JSONs carry tile
grids by necessity — the T1-T5 precedent); spawn COUNTS, HP, damage and
every other tuning value stay out (freeze law + grill custody).

## Overview

- Working size: **~34×22** (dungeon_1 is 32×20 — same authoring class;
  one-session LDtk transcription post-verdict).
- Position in the graph: `zone_8 [~5,5] --rope (interact)--> DUNGEON 2
  entry hall`; return rope in the entry hall (posture = dossier fork 4;
  drawn FREE here, dungeon_1 precedent, one line to change).
- Palette family: zone_8's own (grass/dirt/water vocabulary exists), but
  VALUE-DARKER floor — the "you went under the frontier" read; exact
  palette at LDtk time. Zone law constants (floor dark, walls lighter,
  gold reserved for ways) untouched.
- Stations: NONE inside (B2 no-bank-in-deep; zone_8's vat+altar pair at
  [16-18,25] is the depot — the walk back IS the bank run).

## Room graph

```
zone_8 [~5,5]
   │ rope DOWN (interact)
   ▼
[R0 ENTRY HALL] ──door──> [R1 OUTER CHAMBER] ──door──> [R2 CLUMP CHAMBER]
 (rope back up)             (first contact)              (dense; corner bait)
                                                             │ side door
                                                             ▼
                        [R4 BOSS 2 ARENA] <==SEALED== [R3 SEAL ROOM]
                          (2-wide mouth)    (seal station; `opens` → R4 door)
```

Flow: descend → fight through R1/R2 → find R3 behind the densest room →
breach the seal → walk BACK through cleared space to the now-open R4
door → commit. The Zelda loop (explore → gate → acquire → recontextualize
→ boss) in five rooms; the ONE discoverable rule: **the deep room is the
objective, the boss is a paid choice.**

## Tile-grid sketch (schematic, 1 char ≈ 1 tile, ~34×22)

```
##################################
#R0......#R1..........#R2........#
#..~~....D............D......gg..#
#..~~....#............#..gg..gg..#
#...^....#....gg......#..gg......#
#........#............#......gg..#
####D#####............#..........#
#........#....gg......####D#######
#........#............#R3........#
#..R4....#............#..........#
#........####...#######....S.....#
#........#            #..........#
#........#            ############
#...B....#
#........#
#........#
####==####    == : SEALED door (opens from R3's station S)
#........#     D : open door (1-2 tiles)
#..hall..#     ^ : rope back up to zone_8
#........#     B : BOSS 2 anchor tile
##########    ~~ : water motif (SAFE-class decor, zone_8 family)
              gg : grass/moss decor pockets (SAFE-class)
```

(Schematic, not final tiles: room proportions and door positions are the
content; exact walls at LDtk transcription. R4's mouth is the ONE
2-tile-wide opening — block-cap law makes that width the difficulty
statement, no numbers needed.)

## Room-by-room intent

| Room | Read | Spawn posture (kits only, counts = grill) | Geometry job |
|---|---|---|---|
| R0 entry hall | safe-ish landing | none at the rope; light beyond | teach the exit exists; water motif = zone_8 continuity |
| R1 outer chamber | first contact | rusher family | wide room, no traps — the handshake |
| R2 clump chamber | the dungeon's fight | rusher + husk mix | corner bait pockets (lure-clump-burst geometry, AoE dossier p.2/5); densest room |
| R3 seal room | the discovery | husk guard posture | small; the station IS the furniture; entered from R2's side door |
| R4 boss arena | the commitment | BOSS 2 only | 2-wide sealed mouth; interior open (boss verb needs room); no adds at open — adds posture = grill |

Density gradient: `gradient_anchor` pointed at R2 (the B-candidate fold)
so the map itself climbs toward the clump chamber — proven dungeon_1
grammar.

## Sidecar-style table (SAFE-class only; SIM-class named as asks)

| Region | Floor | Tile classes | Footstep | Ambience |
|---|---|---|---|---|
| R0 | dungeon floor, value-darker | water decor edge (`~`) | stone | none (dungeon_1 precedent: silence under the frontier) |
| R1-R2 | same | grass/moss pockets (`gg`) | stone / dirt at pockets | none |
| R3 | same | bare + station | stone | none |
| R4 | same | bare (arena reads clean) | stone | none |

- All decorative variants + footstep materials = SAFE-class (ship-free
  law). Ambience deliberately none v1 — silence is the dungeon's read
  today; a bed is an audio-seat ask if ever wanted.
- **SIM-class asks (named, NOT designed):** none required by this
  blueprint. (No lava/water hazards, no tile-gated spawns — candidate A
  was picked partly because it needs zero SIM-class pieces.)

## Transitions table (paper)

| At (indicative) | To | Type | Gate | Note |
|---|---|---|---|---|
| zone_8 [~5,5] | D2 R0 | rope_spot (interact) | dossier fork 1 (grill) | s70 precedent verbatim |
| R0 [^] | zone_8 | rope_spot (interact) | free (drawn) | fork 4 may harden it |
| R3→R4 door [==] | R4 | sealed | seal station in R3, `opens` names it | s34 seal-gating law, shipped grammar |
| R0/R1, R1/R2, R2/R3 doors | — | open doorways | none | widths are the difficulty dial (block-cap law) |

## NEW pieces this blueprint asks of v20 (named only)

1. **BOSS 2 kit** (combat.json entry; verb ≠ seize — dossier fork 3).
2. **boss_2_defeats counter** IF fork 2/6 wants it (save-schema touch).
3. Nothing else: rooms, seals, doors, gradient, drops, floors, ropes are
   all shipped grammar (inventory in dossier §4).

## What J-T3 owes this blueprint (next-up, not started)

The zone_8 approach route: 1-2 authored pockets between the east arrival
[62,18] and the northwest entrance [~5,5] (s69 content-fill playbook), so
the walk to DUNGEON 2 reads as territory. The entrance pick here fixes
J-T3's anchor.

## Freeze-hygiene statement

Paper only. No .ldtk created or touched, no data/src edits, no balance
numbers (spawn kits named, counts deferred; door widths argued by law,
not tuned). Ritual spec §9 unread. LDtk transcription = post-verdict WB
pipeline, one session, either seat (T1-T5 precedent).
