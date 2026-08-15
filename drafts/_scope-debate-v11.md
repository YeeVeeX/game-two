# Scope debate — v11 increment (2026-08-12, post-eighth-fun-verify)

> **DEBATE HELD 2026-08-12 — owner forked via AskUserQuestion:**
> **v11 = DENSITY / RE-MASSING** (hunting-ground pressure; Q6
> drop-legibility rides as polish; brainstorm/spec = next session's work).
> **3.5× band-2 multiplier REVERTED to 2.0** (rollback of the refuted
> retune; shape-law's >= 3.0 floor dropped, strictly-increasing law kept).
> The Challenger is DECLINED a SECOND time with its trigger
> triple-confirmed — the dossier below stands for the next debate. A3/arc
> (progression, leveling, equipment, lore, cities — the owner's wishlist)
> recorded as the likely v12 conversation.

Per the standing Challenger clause (A2 brainstorm, PARKING_LOT): promotion is
the OWNER's explicit call, taken here via AskUserQuestion after this brief.

## The Challenger dossier (standing candidate)

**Shape.** A NAMED human who force-taunts the player's possessed body —
"humans never fought back — until one did." The counterplay mirror of the
owner's own taunt verb (taunt orders enemies onto one body; the Challenger
turns that verb around). Recorded at the A2 brainstorm as the ONLY human
counterplay tool that survived the council, and parked with a named trigger.

**Trigger status: MET, twice-confirmed.**
- Sixth verify (A2): threat felt end-to-end, entrainment FLAT — the recorded
  trigger ("threat is felt but fights lack scary peaks") fired and was
  RECORDED at the time.
- Seventh verify (D1b): entrainment flat AGAIN (no somatic tell; caveat on
  record: no wipe/thin-stretch of A2 severity that session).
- Eighth verify: see evidence section below.

**Declined once.** At the v10 scope debate the owner chose D1b inscription +
priced flesh over the Challenger. A second decline is a legitimate outcome;
the dossier exists so the choice is made with the trigger history visible.

**Fairness ladder: MANDATORY if promoted.** Visible tell + counters — the
force-taunt must be readable before it lands and answerable after (the same
fairness law A2's cue work serves). A Challenger that yanks possession
control with no tell is the Kethral unfairness failure re-shipped.

**Alternative shape on record: fear-like scatter** (council-preferred IF
counterplay is forced): the named human scatters the pack instead of
force-taunting the possessed — herd management, environmental, fails
gracefully (a scatter that misreads costs positioning, not control).

**No fiction name yet.** The bible EXISTS (`docs/lore/world-bible.md`,
Vessic naming tongue, "names not derivable from this section are not
canon") — if promoted, the Challenger's name comes from a Vessic derivation
as part of the increment, not from spec-speak.

## The judgment-rarity tension (surfaced for the debate, not pre-decided)

D1b works so well that wipes are rare (seventh verify: wipes=0; Q5 "hunts run
longer" is the owner's own resolved complaint). But the judgment —
marked-survives / unmarked-dissolves, the system D1b exists for — only fires
on a wipe. The drama D1b bought almost never plays. The seventh verdict
recorded this verbatim: "Cheap-wipe → priced-wipe worked so well the priced
part is almost never exercised. Not a defect; a thing the next increment
should know."

The Challenger is one candidate vehicle for rare-but-heavy wipes: a scary
peak that can actually kill a healthy pack, making the inscription bet cash
out. That is an argument FOR promotion — but a threat-side increment right
after two economy increments is also a cadence question the owner should
weigh, not inherit.

## Rival candidates (each with its blocker stated)

| Candidate | What it is | Blocker / caveat |
|---|---|---|
| A3 nest advance | District progression — break districts, re-home the nest | Biggest scope of the list; new zone content + transitions; no fun-verify signal demands it yet |
| D3 scavengers + term-extension marks | Field pressure on unbanked piles + mark economy depth | Parked BEHIND the economy being healthy; touches the same economy just retuned |
| A1 gambits | JSON IF/THEN ally rules + hot-reload | Ally-brain scope; fifth-verify signal was about meaning, not ally IQ |
| A1+ Shooters | Ranged humans | BLOCKED: needs per-attacker cadence proven first |
| D2 fine + insurance | Wipe fine + insurance economy | BLOCKED on skill-through-use (parked) |
| Nest rename + fiction pass | Bible-derived names player-visible (zone banner first) | Bible EXISTS; TWO owner complaints on record; invalidates every gate capture (banner text in frames) → its own increment with a full wall re-run |
| Diagonal corner-cut fix | GridWalker orthogonal-neighbor check | Changes movement FEEL — owner verdict required by the parked entry itself |
| Economy iteration 2 | Another Q6/Q1 data pass | Only if the eighth verify routes there (see routing table in the plan) |

## Eighth-verify evidence (LANDED 2026-08-12 — full record `drafts/_q6-retune-fun-verify-20260812.md`)

- **Q6 (headline): "Still always-bank" — COLLAPSED.** The 3.5× premium was
  earned but not attributed (depth felt "uniform").
- **Q1 guard: "Money got easy" — REGRESSED** (D1's written inflation risk
  fired). **Q5 guard: "Back to the nest too often" — REGRESSED.**
- **Q7: "Still arbitrary" — REGRESSED**; routing: cue redesign opens as its
  own presentation item (read-time lane exhausted after two passes).
- **Entrainment: FLAT — THIRD consecutive** → the Challenger's recorded
  trigger, third confirmation.
- Telemetry LOST (dev double-launch clobbered the log) → the collapsed-Q6
  fork (deep-kill share UP vs UNCHANGED) unresolvable; BOTH branches carry
  here: legibility (deep drops don't read as place) AND structural (banking
  rides heal trips free).
- Free-form: "feels good" moment-to-moment; named gap = ARC ("purpose…
  advance toward something, progress, leveling, equipment, new enemies and
  zones, lore, cities").

## NEW: the density-decay diagnosis (owner-observed, code-confirmed)

Owner, post-verify: "first pull has a good amount of enemies, then respawns
are a smaller part, too easy to clean up; boring and stale after a few
rounds; core system and combat feel good."

Verified mechanism (world.rb:995-1003, 852-870; combat.json respawn_frames
300; threat.json respawn_block_tiles 12): kills respawn 1:1 after 5 s at
their HOME spawn tile, never near the pack → the opening walk-in masses all
15 district humans ONCE; steady state delivers scattered singles. Count is
conserved; **clumping decays**. This is upstream of most of the verify:
a thinning field ends hunts (Q5), blocks sustained deep pushes (Q6/depth),
makes cleanup income free (Q1), and never re-masses a scary group
(entrainment). Touchstone: Tibia hunting grounds stay DENSE — Gudii f83
(laps/respawn: you lap the spawn and it is full again); density-as-
consequence is cited in the consequence synthesis. A2's own shape notes
anticipated this ("respawns walk back toward the last fight").

## Dev-of-record recommendation (one pick, argued — the call is the owner's)

**Promote the density/re-massing increment (hunting-ground pressure).**
Reasons: (1) it is the owner's freshest concrete complaint, code-diagnosed,
felt in-session ("boring and stale after a few rounds"); (2) it is UPSTREAM
of both failed oracles — Q6's push-deeper needs a populated deep field, and
entrainment needs massed threat to ever spike; (3) it is small-scope
(respawn scheduling + data — no new verbs, no new zones); (4) every rival
lands better on a dense field (the Challenger arriving into a live crowd,
depth legibility with something to read against, A3's bigger map with
pressure worth escaping). The Q6 economy iteration should RIDE it as
data-tuning + drop-legibility polish, not stand alone — retuning an economy
over a decaying field is what v10.1 just proved doesn't move. The arc/
purpose wishlist (A3, bible, progression) is real and is the likely v12 —
it deserves a dense, scary substrate to give purpose TO.

Counter-argument honestly stated: the Challenger's trigger is now
triple-confirmed and waiting again risks a fourth flat entrainment read.
If the owner wants the scary peak NOW, density can ride as the Challenger's
substrate prep instead — bigger increment, same direction.
