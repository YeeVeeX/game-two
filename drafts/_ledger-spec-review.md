# Fight-ledger spec — 3-lens adversarial review, verdicts + fold ledger (2026-08-11)

Run as a direct 3-agent fan-out (code-fit = code-reviewer tier; design, fun = general
tier), per the user-scope Workflow-failure ladder (D1's review Workflow died 18/18 on
this exact shape 2026-08-10). Envelope declared: 3 agents, one report each; actual
~287K subagent tokens. Verdicts assigned by the dev of record. Full reports live in
the session task transcripts; this file banks the findings + dispositions.

Mid-review the owner supplied live evidence: a level-1037 EK Hunt Analyser screenshot
(59 min, Loot 1,558k / Supplies 311k / **Balance +1,247k GREEN**) + the decision-stack
quote — banked at `drafts/_tibia-hunt-analyser-ek1037.md`, folded as framing.

## CODE-FIT (no HIGH; 3 MEDIUM, 4 LOW; big verified-clean list)

| # | Finding | Verdict | Fold |
|---|---|---|---|
| M1 | Wipe recap drawn before `draw_wipe_overlay` is buried under alpha-170 veil; "zero special-case rendering" claim false | CONFIRMED | Beat draws AFTER the wipe overlay (before stagger veil); spec now owns the ordering — claim narrowed to "zero special-case STATE" |
| M2 | `zone:` stale on zone-transition force-resolve (`@zone_name` already destination at flush) | CONFIRMED | Window captures zone at OPEN; never reads zone_name at resolve |
| M3 | `carried_lost` accrual unfiltered across zones (latent: nest spawns nothing today) | CONFIRMED (latent) | Window-scale accrual filtered on `carried_lost.zone == window.zone` (= design M1) |
| L1 | `frames:` ambiguous vs frozen-clock doctrine (@frame advances in hitstop/veil) | CONFIRMED | Payload renamed `span_frames:`, counted in ticked (tick_world) frames |
| L2 | telemetry_test asserts byte-exact string; "purely additive" claim breaks it | CONFIRMED | Test update named explicitly in the spec test list (no substring weakening) |
| L3 | `:yield` key one idiom from a syntax error (kwarg/pattern-match destructuring) | CONFIRMED | Key RENAMED `gained:` — kills the keyword hazard class outright |
| L4 | Beat record omits its display total (sibling records all carry theirs) | CONFIRMED | `beat_frames:` added to the record |

Verified clean (kept as build authority): bus supports subscriber-emits-mid-flush,
FIFO within one flush; hitstop cannot extend a frozen window; veil freeze mechanism;
no wipe/enter_zone double-resolve; ALL payloads exist as claimed (incl. actor_died
faction, carried_lost zone); DataStore autoloads `balance/ledger`; tick seam clean;
window.rb cap safe; replays are pure re-simulation; beat geometry clear at 960x540.
Flush-order proof: within the actor_died handler, corpse_loaded is emitted before
pack_wiped -> same-flush append order guarantees corpse_loaded accrues first (pins
design M6).

## DESIGN (4 HIGH, 6 MEDIUM, 4 LOW)

| # | Finding | Verdict | Fold |
|---|---|---|---|
| H1 | FR-024 cited whole while the common-case beat is a bare loot line (no spend -> no delta; net line suppressed without losses) — borrowed P&L authority | CONFIRMED | Citations re-cut: common case = FR-024's yield half + FR-031 (itemized drops, zero outcomes); delta half lands at loss beats/wipe/bank and FULL delta deferred to D1b. Header's borrowed negative magnitudes trimmed; owner screenshot folded: the instrument is honest BOTH directions, green-as-earned is the mastery readout. LB-1 restated accordingly |
| H2 | "Camp-fights resolve between waves" arithmetically false (staggered respawns ~120f < quiet 180f -> mega-window until disengage) | CONFIRMED | False justification line DELETED. Owned instead: a sustained camp IS one engagement, aggregated at disengage — honest per-engagement accounting. Boundary value pre-registered as pilot-MEASURED: beats-per-minute band 1-4/min over the hunt loop is a SHIP gate; quiet_frames tuned from measurement pre-fun-verify, never by feel (= fun HIGH-3) |
| H3 | Yield counts in-window gleans, not the fight's take; "+0 with kill notches then silent pocketing" teaches mistrust | CONFIRMED (= fun HIGH-1 + dev seed) | `drop_picked_up` REFRESHES an open window (never opens). Trade recorded: deliberately abandoned take prints +0 honestly ("you left it"); drop decay already prices abandonment. FR-024 "explicit nothing" rewritten: true zero-drops needs future content (rushers always pay); today's +0 = abandonment, honest |
| H4 | Routing can't distinguish "meant nothing" from "was badly built" — presentation defect could fire the A2 promotion | CONFIRMED | Fun-verify restructured: legibility escape-valve question added; "couldn't parse" routes to presentation iteration, NOT A2. Q3 (chore) alone is the promotion oracle |
| M1 | Cross-zone carried_lost contradiction with own OUT trim | = code-fit M3 | folded there |
| M2 | Hollow pip pricing `destroyed` inverts D1's taught grammar at the permanent-loss moment | CONFIRMED | Loss grammar split: pip glyph = stranded (out there, recoverable); dark-flash-family mark = destroyed (gone). Red reserved for negative nets/destroyed |
| M3 | Kill notches: untaught grammar, zero touchstone, corpus anti-evidence (§104 tally-framing critique), prices kills by position | CONFIRMED | Kill notches CUT. Kills stay in payload + telemetry only. (Overrules fun MED-1's add-pack-death-notches: see below) |
| M4 | Forced resolve can stomp a live negative beat; wipe recap prices only window B while the field holds two piles | PARTIAL | Recap fix ACCEPTED: wipe recap's pip line = SNAPSHOT of all live containers at wipe (field truth, the number Q4 rides on). Stomp-merge machinery REJECTED (recorded): dissolve never stomps (only qualifying resolves replace); the remaining 150f stomp window is rare, info persists in telemetry — screen budget wins |
| M5 | quiet<settle interlock is load-bearing, cross-file, unstated; Q5 tuning could silently kill the mid-fight negative beat. Header negativity borrowed | CONFIRMED | Data-load assertion test `ledger_quiet_frames < loot_settle_frames` + recorded rationale; Q5 tuning must respect or CONSCIOUSLY break it (mode change, recorded). Header trim in H1 fold |
| M6 | Wipe recap "always qualifies" rides unpinned event ordering | CONFIRMED | Ordering pinned in spec + test: wipe-tick corpse_loaded accrues before the pack_wiped resolve (flush-order proof in code-fit clean list) |
| L1 | `frames:` unit-as-name | = code-fit L1 | `span_frames:` |
| L2 | Stranded-then-recovered prints gross churn (+45/-40/=+5) unowned | CONFIRMED | OWNED in spec: fight-level gained INCLUDES recoveries (the churn print is the honest arc); leg-level (bank tally) counts FIRST acquisition only. Both conventions pinned |
| L3 | Redemption beat = second hypothesis inside LB-1, attribution muddied | CONFIRMED | Telemetry splits windows by opening class (combat vs recovery); fun-verify asks the moments separately |
| L4 | Force-resolved beat renders in a zone it isn't about | ACCEPTED-AS-IS | Recorded: once-per-gate-escape, pip referent off-zone; watch item, no code |

Checked clean (design): quiet-HUD law compliant (beat never shows the SCORE; timed,
self-clearing; FR-024's exact transformation); no parked-item smuggling; de-slop
compliant; non-negotiables 3/4 hold; gate arithmetic consistent.

## FUN (3 HIGH, 5 MEDIUM, 4 LOW + verdict prediction)

| # | Finding | Verdict | Fold |
|---|---|---|---|
| H1 | Instrument undercounts; false +0s; enshrined by the test list | = design H3 | folded there (refresh-not-open) |
| H2 | Amplitude: legibility tested only at +2 noise; bank-leg reconciliation (the touchstone's actual moment) excluded | CONFIRMED (owner screenshot corroborates: the session P&L IS the felt readout) | Bank-leg tally ADDED: on `banked`, print net-since-last-bank in the same 3-line grammar (replaces any live beat). Leg accounting pinned: gained = first-acquisition drop pickups; destroyed = all expiries since last bank (all zones at leg scale); outstanding stranded = live-container snapshot on the pip line, excluded from net. Resets on bank. Same system, same variable, second granularity — attribution guarded by L3's telemetry split + per-moment fun-verify questions |
| H3 | Cadence habituation guaranteed by 180f<300f framing; measurable pre-ship | CONFIRMED | = design H2 fold: pilot-measured beats/min band 1-4/min as SHIP gate |
| M1 | Casualty fight prints identical to clean win (pack_deaths accrues, never renders) | PARTIAL — REJECTED as render change | Beat stays a LOOT instrument (kin are not currency; design M3's pricing-by-position argument cuts both ways). Kin-death registration remains the forced-swap veil's job. RECORDED as watch item: if fun-verify says casualty fights read false-clean, that routes to fees (D1b pricing kin), not to this beat |
| M2 | Cry-wolf negative: "-N" prints seconds before an in-doubt-free recovery; branch A/B inconsistency | RESOLVED VIA GRAMMAR | Pip -N means "out there" (true, calm), not alarm; redemption beat closes the arc pip-prefixed. Red never appears for recoverable state. Suppress-while-recoverable logic REJECTED (would create piles that never print anywhere) |
| M3 | Routing hole at the likeliest verdict (split); ledger disposition unstated for the A2 handoff | CONFIRMED | Routing restated: Q3 chore -> A2 promotes, full stop; other answers decide ATTRIBUTION + ledger disposition (any-signal = beat stays for A2's increment; wallpaper + wouldn't-miss = beat removed before A2 ships, recorded) |
| M4 | Q6 is a pre-answered control; Q1 double-barreled | CONFIRMED | Q6 kept, LABELED carryover control; "would you miss it if it stopped printing" added as the LB-1 instrument oracle; Q1 split wins/losses |
| M5 | Redemption beat prints in ordinary-win grammar — spends its identity | CONFIRMED | Recovery-opened window's yield line is pip-prefixed (recovered, not earned) |
| L1 | Wipe recap changes second 3 of the run back, not minute 2 — predict Q4 "same walk" | CONFIRMED | Pre-registered: Q4 "same walk" is consistent with LB-1 and feeds A2's case, not the beat's indictment |
| L2 | `destroyed` accrual experientially dead this build | CONFIRMED | Kept (cheap, correct); not cited as a felt channel in the ship narrative |
| L3 | Q5 gaming = positive signal; corrupted only if H1 unfixed | CONFIRMED | H1 fixed; Q5 reading stands |
| L4 | The 3 vision checks can't catch the true contaminants (wrong numbers, cadence) | CONFIRMED | Cadence = harness ship gate (not a vision check); numbers = unit tests on the FIXED accrual; vision checks stay legibility-scoped. 4th check added for the bank tally (26->30) |

Fun verdict prediction (recorded, pre-registered): ~55% clean NO -> A2 promotes;
~35% split; ~10% YES. The build's value survives all three IF the contaminants are
folded out — which this fold does.

## Cross-lens convergence (why this fold is trusted)

- dev seed == fun H1 == design H3 (three independent derivations of refresh-not-open)
- fun H3 == design H2 (opposite failure modes, same fix: measured cadence gate)
- code-fit M3 == design M1 (zone filter)
- owner evidence == fun H2 (bank reconciliation is the felt moment)
- design M3 vs fun M1 adjudicated on the reference wall: NO notch grammar at all

## Dispositions summary

ACCEPTED: 24 findings folded into the REVISED spec. REJECTED (recorded): stomp-merge
machinery (M4-design, partial), suppress-stranded-while-recoverable (fun M2 shape),
pack-death notches (fun M1 render half). Every rejection carries its reason above.
