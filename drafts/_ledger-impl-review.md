# Fight-ledger impl review + flight notes (2026-08-11, session harvest)

## Adversarial impl review (code-reviewer agent over git diff main...HEAD, ~89K tokens)

Ran the ledger suite (20/20) + full rake (214/925) itself. TWO findings, both LOW,
both RECORDED not folded (dev-of-record dispositions below). Everything else traced
clean against the real bus/sim.

### Finding 1 — LOW: deadline-tick events are invisible to the window they belong to
tick_world order: controller/attacks emit (queue) BEFORE @fight_ledger.tick runs, but
events only flush at bus.process AFTER tick_world. A window whose quiet expires at
tick T+180 resolves BEFORE a same-tick pickup/kill flushes: the sweep prints +0 for a
fight whose loot was taken (pickup then lands window-less: never in any fight window;
leg still counts it). A last-frame kill can dissolve a graze window instead of
refreshing. Effective refresh window = 179 usable frames, not 180.
**Disposition: RECORDED, not folded.** The naive fix (tick ledger after bus.process)
would tick clocks during hitstop/veil - breaks the freeze doctrine; flush-side resolve
is a restructure. 1-in-180-frame boundary, display/telemetry only. Watch item: if the
fun-verify surfaces "the tally missed my sweep", this is the first suspect.

### Finding 2 — LOW/informational: cross-leg bank beats can misstate the bank moment
Spec-faithful first-acquisition accounting: pick 5, die carrying (strand A), pick 3,
bank -> beat +8/pip -5/=+8 while the bank received 3. Or: A expires next leg, bank 3
-> beat +3/dark -5/=-2 right after a successful +3 bank. Or: recover A, bank 5 ->
beat +0/=+0. Not a code defect (arithmetic matches declared leg semantics); flagged
because the ledger's purpose is "legible and FELT at the moment": cross-leg beats can
disagree with the felt bank. **Disposition: RECORDED as fun-verify interpretation aid
(Q5 answers about bank tallies must be read against this).**

### Traced clean (verified by the reviewer, kept as authority)
Wipe-ordering pin (FIFO within flush; World's actor_died handler queues corpse_loaded/
pack_wiped before the ledger's handlers run - test exercises it); resolve! reentrancy
(nils @window before emit; second force-resolve no-ops); zone_entered always queued
before same-tick accruing events (all emission sites sit after check_transition);
nil-deref paths guarded; factions exactly :pack/:human; renderer math (no div-zero,
correct Gosu::Color arg order, widths consistent, draw order as specced, zero balance
reads); empty bank impossible (interact requires carried.positive?); no events during
veil; window.rb untouched; payload key gained:; consumers index; no mocks.

## Pilot flight notes (session ledger, seed 0, 19,818 frames, 11 captures)

TELEMETRY d1_fired carrying_deaths=6 wipes=8 corpse_looted=3 carried_lost=2
banked_events=3 fights=20 recovery_fights=1 negative_fights=4

**Cadence ship gate: PASS, no retune.** Hunt stretch (frames 220-4316, enter ->
first bank): 3 beats / 1.14 min = 2.64 beats/min. Whole session: 20 / 5.5 min =
3.63 beats/min. Band 1-4. ledger_quiet_frames=180 stands.

Beats on camera (captures/pilot/ledger_r1/): act1 clean win +1 (frame_0591);
wipe recap over veil +4/pip -5/= -1 (frame_2017 + midveil frame_2037 proving the
freeze); gate-escape rich take +11 net +11 (escape_rich); bank leg tally +4/pip -5/
=+4 (frame_9297 - PROVES first-acquisition live: banked 11 but leg gained prints 4,
the recovered 7 correctly not double-counted); dark destroyed loss +1/dark -5/= -4
red (frame_11143 - both graced piles expired mid-window at 11057, unstaged); recovery
redemption pip-prefixed +4 opened_by=recovery (frame_19817; loot payload showed
term_left=742 - recovered 742 frames before expiry).

**Owned trim:** act 2's separate NON-wipe negative beat (carrier dies, forced-swap
survivor retreats) was never captured - three lives of attrition denied a 2-body
survivor at the staging moment. Its grammar (pip loss line + red negative net) is on
camera via the wipe recaps + dark-loss beat; its mechanics are unit-pinned
(test_recovery_opens_a_window..., stranded-fight negative net asserts). Recorded, not
hidden.

**Sim discoveries during the flight** (watch items, no action): the (10,12) respawn
conveyor makes any camp near a spawn an unquietable mega-window (H2's owned truth,
now measured); a knockback shove onto the gate tile force-resolved a window and
gated the pack mid-sweep (physical-gates law interacting with the ledger - honest);
mid-tween gate-tile loot works (tile commits at step start, one-tick interact window
before the gate fires - used deliberately for the (0,13) corpse).

## Vision-check repair (2026-08-11, this session)

taunt_convergence_reads FAILED twice consistently post-hardening on byte-identical
frames: the check's letter ("possessed white-ringed body is NOT the one being
swarmed") contradicts taunt_anchor's whole premise (possessed blocker SELF-ANCHORS
the swarm). Repaired the text: convergence must be on the blocker and not any other
pack body; self-anchor case explicitly legal; failure case = underlined humans
swarming a NON-blocker body. Discriminative content kept (underline requirement,
not-exercised hatch). Same class as D1's corpse_load_reads amendment (critic
correctly sees pixels, wrongly calls design a defect). loot_loop's
specials_distinct FAIL earlier the same wall was a one-off hatch inversion
(why-text matched the pass hatch verbatim) - passed on plain retry.
