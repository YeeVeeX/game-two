# s47 — the wall re-author (T2's wake): five stale long-reel scripts re-staged at level 5

Session 47, 2026-08-23. Dev of record, hub seat. Ticket: s46's surfaced
defect — five long-reel wall scripts no longer complete their staged
stories under T2's ratified stat growth (attribution:
`drafts/_prog-t3-close-20260822.md` §Manifest-staleness; every miss
reproduces pre-T3 at `354f2b2`).

**Session-open fork (owner note honored):** T4 brief-cut was the named
alternate; recommendation on record was wall-first (the wall is the
ritual's regression net; every coming pacing retune re-breaks unstaged
long reels). No owner redirect arrived mid-session → wall executed.
T4 stays the s48 spark's alternate.

## The stat-stability law (established by this ticket)

Every re-authored reel stages `start.progression = {level: 5, xp: 0}`.
ΔE(6) = k·(36−18+4) = 40·22 = **880 XP** — no reel here banks more than
460 kills_xp, so a mid-reel level-up is arithmetically impossible and
the reels are stable against progression-pacing retunes (kill_xp / curve
moves cannot flip outcomes unless they bring a reel within reach of
880). Verified per script by headless run: `TELEMETRY progression
level=5 …` in every replay log is the byte proof (margins: vat 720 ·
quay 420 · corpse 540 · nest 635 · sustain 675). Level-5 stats are
IDENTITY-plus-integer-growth (dmg +32%, hp +24% over base), so fights
run faster than the old level-1 reels — every story was re-piloted, not
patched: probe B showed even the surviving legs diverge at L5 from the
first fight onward (drop tiles/timing shift), so input surgery was
rejected for all five.

## Per-script record (pilot → headless verify → full gate + manifest)

| script | old → new run_until | old story failure at HEAD | new staging | gate | manifest |
|---|---|---|---|---|---|
| vat_economy | 20213 → 4888 | all 4 rows dead: L1→2 crossing at f926, unplanned wipe f1750 ate the carried value; tribute/bank/inscribe never fire | `start.banked 30` (apply_start precedent — the farm prologue is not this script's concern); district farm + striker sacrifice → bank 6 → tribute 16 (regrow) → inscribe 8; fixtures/tally/tribute captures | PASS (8 caps ×2 byte-identical, critic PASS) | PASS: tribute_paid=2 body_regrown=2 banked=2 inscribed=2 drop_picked_up=6 |
| low_quay_run | 8611 → 4403 | economy loop diverges mid-reel (banked 0/4, drops 2/10, looted 0/2); L1→2 f1173, L2→3 f2821 | same `banked 2000` + L5; single-pass: inscribe ×3 → district dash (2 drops) → TOLL 1 → camp bank+tribute → d2 NORTH-LANE dash → TOLL 2 (150) → slow_door → ZONE 5: entry-pod farm, 3 rich drops, channel/banner captures; reel ENDS in the quay (no return leg) | PASS (14 caps ×2, critic PASS) | PASS: inscribed=6 seal_breached=4 banked=2 tribute_paid=2 drop_picked_up=10 zone_entered=12 |
| corpse_run | 10103 → 5020 | terminal bank beat gone (banked 0/1; reel wipes 7× unstaged) | farm 3 drops → carrier lobber dies loaded in the deep pod → full wipe (veil + floor-judgment captures) → kept vessel solo return → loot [22,19] → terminal bank. corpse term 5400 / grace 2700 gives the run-back comfortable margin | PASS (9 caps ×2, critic PASS) | PASS: corpse_loaded=2 pack_wiped=2 corpse_looted=2 banked=2 drop_picked_up=6 vessel_kept=2 |
| nest_advance | 13034 → 5013 | corpse sub-beat gone (loaded/looted 0/1 each) | bank-EARLY variant (differentiates from corpse_run): trip 1 farm → bank 5 → trip 2 deep march (running battle, 7 drops) → lobber dies carrying 10 → wipe → vessel loots → bank 10 (recovered) | PASS (see teed log) | PASS: banked=4 corpse_loaded=2 corpse_looted=2 pack_wiped=2 drop_picked_up=8 vessel_kept=2 |
| sustain_run | 11531 → 6799 | counts short (bought 4/10, banked 4/6) — wipe at f4201 bankrupts the buy chain | provisions loop: broke refusal at open → farm → bank 10 → buy ×2 → use afield → no_effect refusal → deep farm → wipe carrying 6 → recover corpse → bank 6 → buy #3 → final broke refusal (X-bar + R-A2 BUY-hint frame) | PASS (12 caps ×2, critic PASS) | PASS: provision_bought=6 provision_used=2 provision_refused=8 banked=4 drop_picked_up=16 pack_wiped=2 corpse_looted=2 |
| **wall total** | **63492 → 26123** ticks (−59%) | | | | |

Manifests are the TRUE staged counts of the new reels (floors per double
replay, exact — replays are deterministic). Rows dropped from the old
manifests (low_quay's corpse_looted/body_regrown; sustain's `none`
refusal kind) moved to scripts that stage them deterministically
(corpse_run/nest_advance own the corpse family; vat_economy owns
regrow) — no beat family lost wall coverage; seal_breached remains
low_quay_run's exclusive row (verified: only script carrying it).

## Sim-design news for the peers (not authoring debt — recorded, no code)

**ZONE 3 (district_two) is a hard wall for pedestrian crossings at
L5.** Four full-pack attempts died in its mid-band during re-piloting
(row-13 funnel pockets [21-25,11-16] + the NE respawn pod [33-37,4-6]).
What finally crossed: the north-lane detour (rows 3-5) INSIDE the fresh
window (before the first respawn wave thickens the pods) with no
fight-anchoring — the exact choreography the OLD (pre-T2, level-2)
reel used, mined from its input taps. Implication: T2's +32%/+24%
growth does NOT buy d2 walkability; the zone's danger is respawn-
pressure-dominated, not stat-dominated. Junior's L7-8 solo grind
(drafts/_junior-progressao-playtest-20260823.md) reads consistent:
his deep progress came at higher levels than 5. This is DATA for the
v19 geography/difficulty lanes (B4 mercy floor, B5 respawn scalar —
both ritual-frozen); no sim number moved this session.

**Respawn re-anchoring empties the shallow district.** After a pod is
cleared, `anchor=seed` waves rebuild DEEP-EAST first; a second-trip
farm in the west band finds nothing. Re-authored reels lean on the
deep march instead — which is why every reel now carries a wipe or a
near-wipe. The wall now exercises the death/recovery stack far more
densely than before (2 wipes → 5 across the wall; corpse beats ×3
scripts; floor-judgment ×3).

## Pilot-tooling debt observed (candidates for a later spark, zero code owed now)

1. **goto ally-block livelock**: GotoEngine waits forever when the
   downhill tile is held by an idle follow-formation ally (guard is the
   only out). Hit ~6×. Workaround: manual step-off before goto after
   any station stop. Candidate: allies yield to the possessed's
   reserved path, or GotoEngine sidesteps occupied downhill tiles.
2. **goto unreachable is silent-ish in batches**: queued gotos after an
   instant `unreachable` fail keep executing from the wrong tile; my
   nest/district confusion (na3 gen-1, ~1900 junk ticks) came from
   reading a truncated state line. Protocol fix adopted mid-session:
   always read ZONE in state polls; verify zone after every gate goto.
3. **press-edge merging**: two `press X` lines on adjacent frames read
   as one hold → one edge. `wait 8` separators required (hit on swap
   ×2, sustain ×1).
4. **Pilot throughput** is ~55 ticks/s wall-clock at speed 60 (update
   pump bound, sim itself ~0.45ms/tick) — long stagings cost real
   minutes; batch commands and poll sparsely.

## Ledger

- Suite: 1075 runs, 19079 assertions, 0F 0E 0S (full `bundle exec rake`,
  post-change) + hooks re-run it at commit.
- R-A2 telemetry intact in the new sustain reel: `TELEMETRY sustain
  bought=3 used=1 refused=4 reasons{at_cap=0 broke=3 none=0 no_effect=1
  seat_race=0}` in every replay log.
- Gates: 5/5 full `rake gate` (critic ON) + `rake manifest` PASS on
  teed s47 logs (`tmp/wall/*_s47.log`).
- Live save: `98fe75edb6d72deab18cd48eaa88bdaf` verified open,
  mid-session, close — untouched. No soak, no netplay surface moved,
  no sim/balance file touched (`git status`: exactly the five script
  JSONs + this drafts file + checkpoint).
- Canary bank: untouched (none of the five is banked — bank =
  world_loop/varekka/burn only).
- Budget: council 0, sub-agents 0 — as sparked.

## Owner-pending carry (untouched, never nagged)

ear-checks · T3 footstep/bed renders (water family needs a NEW mail) ·
coop S1 · SHARED-save first crossing · J-5 spike call · WorldSmith
proposal (INCOMING) · R-A2 escalation call. Junior's playtest bank
(`d687f3a`) additionally leaves: long-session drift signature → hub
classification = WATCH (data, not defect; perf ticket c8f37e7 stays
closed; re-check if a second seat reproduces it).
