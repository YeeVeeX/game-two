# varekka_burn — pilot provenance + doctrine (2026-08-16, Junior seat)

New wall script `harness/scripts/varekka_burn.json` (17th): the burn
beat's DESIGNATED EXERCISER (spec v16 d — "an inscribed seized death on
camera", manifest `inscription_burned >= 2` over the double replay).

**Deviation from the spec letter, recorded:** the spec said "varekka_duel
re-pilot". The existing varekka_duel remains SIM-VALID (increment-5
review probed every wall script headless: zero seizures-deaths, burn
branch unexercised, replays byte-identical), so instead of re-piloting a
proven scene the burn got its own focused script — less risk, one more
exerciser, ADD-ONLY in spirit. varekka_duel keeps owning interrupts +
THE TERM IS PAID + fat drop; varekka_burn owns chant→writ→seize→
seized-death→burn→THE MARK IS VOID.

## Scene (seed 7, start: banked 600 + zone low_quay + inscribed [striker])

`start.inscribed` is NEW harness plumbing (this commit,
harness/support.rb + scene_start_test x3): the burn needs an inscribed
body in a stationless zone — same primitive class as start.banked (skip
the altar prologue, not the economy).

Beats on camera (captures [200, 1599, 1670, 1703, 1850, 2098]):
- 200: ONE STANDS stamp (engagement fired frame 144 during the opening
  brawl — splice-legal capture, stamp window 144-294)
- 1599: chant mid-window — chant ring + THE WRIT-FRAME both in frame
  (check #53's shot: outside dimmed, inside readable, nameplate crisp)
- 1670: seizure live — THE FLESH IS CALLED + seized body darkened w/
  blue underline (checks #49/#51 evidence)
- 1703: the seized death frame — kill pop flash + expiry-flash (burn's
  unconditional channel)
- 1850: THE MARK IS VOID active with rule pair + floor SEAL MARK at
  [11,1] (checks #51 + the burn beat)
- 2098: aftermath (survivor holds the beachhead)

Event line (single run): engaged@144, chant_started@1526 (body=striker),
vessel_seized@1646, striker dies seized @1703 (killer=rusher_hater28 —
crew participation), inscription_burned@1703 at [11,1],
seizure_ended why=died @1703.

**Gate (this machine, no AWS): determinism 6/6 byte-identical across
double replay; MANIFEST PASS (engaged=2 chant_started=2 vessel_seized=2
inscription_burned=2 seizure_ended=2). Vision leg OWED at the wall
reset (critic runs on the owner seat).**

## Doctrine banked (pay-once knowledge)

- **The beachhead shields the door camp — and that includes Varekka.**
  Bodies within the arrival beachhead (~4 tiles of the zone spawn) are
  invisible to un-waivered humans; Varekka LEASHES home mid-approach if
  the pack hides there (observed live: he reversed at [35,11]). Bait
  from OUTSIDE the beachhead ([10,3] worked); the beachhead is the
  retreat pocket AFTER the scene, not the stage.
- **The chant pins the body, not the position** (doctrine confirmed):
  kiting the possessed away mid-chant does not save it — the seizure
  lands wherever the pin went. Use the chant window to steer the DEATH
  SPOT, not to escape.
- **Crew kills count for the burn**: why=:died gates on the body dying
  while seized, killer irrelevant — a 20hp pre-damaged victim dies to
  chip damage well inside the 450f window; Varekka alone needs the
  victim at ≤75hp (5 hits × 15 in the post-walk window).
- **The AI striker suicides into the opening wave** — swap to it early
  (its pre-damage is USEFUL: aim ~20-40hp at chant time) and park it
  outside ally aggro tangles until the bait.
- MARK VOID timing: enqueued at death, ACTIVATES when FLESH IS CALLED
  drains (~150f later + hitstop pauses) — capture the void stamp ~150f
  after the death, not at it.
