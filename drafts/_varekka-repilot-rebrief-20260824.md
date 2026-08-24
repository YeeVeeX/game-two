# varekka_duel re-pilot — STOP-AND-RE-BRIEF evidence (s60, 2026-08-24)

**Status: the s59 brief's own stop condition fired.** "If the duel proves
unpilotable under the new law (boss + room never separable), STOP and
re-brief with the owner: the manifest numbers themselves may need a
ratified re-cut — that is a design decision, not a session call."
Six interactive pilot generations (`rake pilot NAME=varekka2 SEED=7`,
full drive log `tmp/pilot/varekka2/log.txt`, captures
`captures/pilot/varekka2_r1..r6/`) could not re-earn the shipped
manifest honestly. Zero source/data/harness files were touched; the
staged J7-B tree is byte-identical to s59's.

## The manifest under re-earn (per single run; script declares per double)

engaged 1 · chants 3 · interrupts 2 · seizures 1 · seizure_ends 1 ·
drop pickups 1. The old stream earned exactly this profile — but its
mid-duel 1-frame slow_door bounce (dead teleport-reset) deleted the
room AND cut the 450-frame seizure to 79 frames (`why=zone_left`),
compressing the whole 3-chant arc into door-adjacent bursts. The
manifest's pacing *encodes the exploit*.

## The structural finding (why honest re-earn keeps collapsing)

Three ratified/existing systems interact against the 3-chant arc:

1. **Ally autonomy has no steering verb.** Allies auto-engage any
   hostile within aggro 10 (`AiController#tick`: bound || marked ||
   nearest) and solo-seat flee is disabled by design (v18 d12,
   seats=1). There is NO way to hold an ally off the boss except
   possession (one body at a time), a marked decoy (needs a live
   human ≤6 of the possessed — the door area is empty after the
   wave), or >10 distance (impossible: FOLLOW_DISTANCE 2 glues
   allies to the possessed while the chant needs the pin ≤7, and
   7+2 ≤ 10). **This is exactly the gap the ratified Lane-3 C2
   (ally defensive-default) / C3 (stance verb) work names.**
2. **The boss's hp budget cannot survive his own arc.** 140 hp;
   every chant-interrupt costs ≥20 (that IS the interrupt); between
   chants his cooldown (600f) must burn while he is a live nearest-
   hostile beside bodies that auto-attack him (~0.5 hp/f leakage in
   any trade-lock). Measured: gen-4 walked him 140→92 in one
   interrupt cycle, then uncontrolled ally fire killed him mid-leash;
   gen-6 (textbook cycle-1, interrupt landed in-band at +90f) still
   reached 92 hp with 2 chants owed.
3. **No in-zone sustain.** low_quay has no stations; hp is one-way.
   The wave phase (data-fixed under seed 7 — rushers 11/10/0/1/2/14
   + strays) costs the pack ~striker every generation (died at
   ~568 in 5/6 gens — its 80hp/13f-step chase AI face-tanks the
   arrival trickle). The surviving 2-body pack must then bank 3
   chant cycles ≈ 2400+ frames of boss proximity on a fixed pool.

Honest tools verified live this session (all work, none suffice
together): beachhead shield as de-aggro sanctuary (humans cannot
acquire bodies ≤~4 of the gate; chasers linger 90 then leash home —
burns his cooldown safely), equal/faster-speed kiting (lobber 16f =
boss 16f, striker 13f), lag-trick pin control (possessed walks west,
19f blocker lags east ⇒ pin=blocker at ring-7), seized-hands law
(possessed-seized body may still fire), marked-decoy ally binding,
running-pin completion (chant has no completion range check).

## Per-generation ledger (drive log has the full beat trail)

- gen-1: chant-1 completed on a 20hp striker pin (nearest-controlled
  law) → seized body died; south field woke; retreat mis-executed
  (swap-onto-gate-tile fired the transition; group_wait stalls under
  melee) → blocker+striker dead, unsalvageable.
- gen-2/3: wave-phase ally-chase spirals (kills pull allies east one
  tile at a time; wake lines: east ≈ col 14, south ≈ row 12 + the
  two channel bridges cols 14-16/30-32); pulls woke 3-13 mobs.
- gen-4: clean interrupt cycle-1, then during the peel the free
  ally lobber shot the leashing boss 92→0 (`killer=lobber`,
  frame 1252). Boss dead at 1 chant.
- gen-5: pin landed on the 27hp lobber mid-improvisation; interposed
  awakened bodies ate the interrupt shot; seized → lobber lost.
- gen-6 (pre-planned drill, speed discipline): cycle-1 textbook —
  chant 829 pin=possessed-lobber, interrupt 919 (in-band, both
  sources); trade-lock peel still cost lobber (boss retargeted the
  slower trailing body mid-retreat) → solo blocker cannot both
  interrupt (no ranged verb; 6-step walk-in = 122f > 120f window)
  and survive a completion hold with the remaining budget.
  Close telemetry: `engaged=1 chants=1 interrupted=1 seized=0`.

## Options for the owners (design decision, not a session call)

a) **RE-CUT the manifest to honest pacing — RECOMMENDED.** Per
   double replay: `engaged 2 · chants 4 · interrupted 2 · seized 2 ·
   ended 2 · drops 2` (i.e. per run: 2 chants = 1 interrupt + 1
   completion, seizure ends by expired/died/slain — all honest).
   Every check family the wall cares about stays exercised (chant
   ring + writ frame, interrupt beat, seizure underline + hold,
   SPAWNED/DEFEATED stamps, kill pop, drop pickup, carried readout).
   Evidence it is drivable: gen-1 banked a completion at 747; gen-6
   banked an interrupt at 919; one run needs each ONCE, and the
   boss budget then closes comfortably (140 − ~20 interrupt − ~40
   leak ⇒ ~80 into the hold; kill after expiry).
b) Keep 3 chants, cut interrupts to 1 — still hostage to finding 1;
   not recommended.
c) **Defer the re-pilot until Lane-3 C2 ships** (ally defensive-
   default + flee co-tune — the missing steering wheel). The slot
   stays RED; wall keeps running the other 25 + zone_catchup.
   Honest but leaves a RED slot for a full lane.
d) Drop the seizure rows (completion not required) — loses the
   seizure/writ visual exercise from the wall. Not recommended.

If (a) is ratified: the s60 drill card (in the drive log and this
doc) is the choreography — wave at the corner → shield dissolution →
cycle-1 interrupt (possessed-lobber shot) → shield/leash cooldown
burn → cycle-2 completion via lag-trick pin + running pin → hold →
expiry → mark + kill → DEFEATED stamp + drop pickup → gate exit.
Estimated ~4500-5500 frames; captures at engage stamp, chant writ,
seized hold, leash walkback, kill pop/stamp, carried, exit.

## Interim state (no gate/manifest run this session — nothing shipped)

- `harness/scripts/varekka_duel.json` unchanged (still the stale
  choreography); slot stays **RED**; canary ACTIVE hash for it stays
  `31c699cb…` (the s59 rebank, ratification still pending).
- The re-cut, when ratified, lands as: re-pilot under the drill card
  → export → new script + manifest rows → canary REBANK #2 (audit +
  preserved history + the owner line that ratified the re-cut) →
  gate critic-ON + manifest → full wall.
