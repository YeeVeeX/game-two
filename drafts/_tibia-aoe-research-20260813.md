# Tibia AoE-rune research dossier (deep-research harvest, 2026-08-13)

Harvested at goalcomp from the research agent's final report (the task
output path in Temp is volatile). PARKING_LOT's v12-debate section points
here. All of this is PARKED - v13+ candidates behind arc/purpose.

## Mechanics (Tibia ground truth)

- Four elemental volley runes (Avalanche/GFB/Thunderstorm/Stone Shower):
  same 5x5 cross/diamond footprint (13 tiles), interchangeable except
  element; players carry the element the spawn is weak to. Explosion =
  3x3 cross; SD = single-target nuke.
- Field/bomb/wall runes lay persistent elemental terrain (~45s): bomb 3x3,
  wall 1x5, field 1x1. Monsters PATH AROUND fields they are not immune to
  - the core crowd-control mechanic; immune ones walk through. Fields
  apply conditions on step (burn 2-3 ticks, poison many low ticks).

## Solo meta - the lure-clump-burst loop (the Gudii f83 pattern)

1. LURE: run the spawn at full speed, aggro 8-15 into a chase train.
2. CLUMP: corner/corridor geometry stacks followers (they path to the
   tile-you-were-on; a diagonal step around a corner piles 5+ into 2x2).
3. BURST: 2-4 area runes into the pile; loot in one pass at lap end.
- Bomb usage: seal corridors behind you; safe-zone the burst dead-end;
  element-sort mixed-immunity groups; L-shaped walls fake a corner.
- DoT fields as kite tax: lay on the running route, chasers tick every lap.

## Team meta (Knight+Druid+Sorc+Pally)

- Knight blocks on a tight tile; `exeta res` = forced single-target aggro
  ~6s; `exeta amp res` = AoE challenge. Shooters stand 3-5 back and
  synchronize volleys ("3,2,1,rune") so the spike kills the whole pile.
  Druid drops bombs behind the knight + mass-heals. Party rotates rooms
  at respawn cadence.

## Extracted design principles

1. Element-resistance as ROUTING, not damage scaling (fields sort packs).
2. Lure-then-burst is the skill ceiling: more gathered = multiplicative
   payoff; the limit is lure-phase survivability.
3. Field runes = player-authored temporary level geometry.
4. Aggro tools exist so damage roles can exist (challenge enables volley).
5. Clumping converts density into payoff - the meta needs dense spawns.
6. DoT makes the chase phase productive, not dead time.

## game-two design seeds (v13+ candidates, behind arc/purpose)

- **(B) Clump-payoff special** - AoE whose efficiency scales with target
  count (e.g. striker whirlwind: X per enemy hit, flat pip cost). The
  player-side cash-out for v11's density. LEAD candidate with (D).
- **(D) Challenge-retarget special** - `exeta amp res` equivalent: forced
  retarget of all humans in radius to the possessed
  (`:human_retargeted cause=challenged`), ignoring proximity/lowhp/hate
  for N seconds. Directly answers the deep-carry death pattern (lobber
  mobbed while carrying) seen in the v11 pilots.
- **(A) Elemental tile-hazard special** (lobber kit fit): 2-3 tile zone,
  ~10s; enemies path around weakness, through resistance. Needs (C).
- **(C) Resistance profile per human kit** - the data layer A/E need;
  turns field element choice into a pack-sorting decision.
- **(E) DoT kite-tax field** - low per-tick, visible particles, ticks
  while chasers cross it; turn-and-burst the weakened group.
- **(F) Element-as-presentation** - zero-cost prep, PARTIALLY DONE: the
  drop-band ember/gold ladder already seeds the warm=rich visual language.

## Executive read for the roadmap

v11 built the dense field (the problem AoE pays off). The minimal viable
player-side payoff = (B) + (D); (A)/(C)/(E) add elemental depth on top.
All wait for the v12 fun-verify and the v13 debate.
