# D1 spec adversarial review — 3-lens fallback fan-out (2026-08-11)

Provenance: the Workflow run (wf_bff43574-53c) died — all 3 lens agents stalled on
all 6 attempts (1.49M subagent tokens, zero results; journal has 18 `started` lines,
0 `result` lines). Per the user-scope workflow-failure ladder, re-run as direct
Agent fan-out with the same briefs; verify stage folded into the main loop (dev of
record screens code-fit HIGHs against the code directly).

Spec under review: docs/superpowers/specs/2026-08-10-d1-corpse-run-design.md (DRAFT,
committed 5255d93). Binding authority: docs/design-corpus/death-economy-design.md.

Lens status:
- FUN lens: LANDED (below, verbatim).
- CODE-FIT lens: in flight when this file was written — if the fold happened, its
  report is appended below; if this line still says in-flight, harvest from the
  task notification before applying anything.
- DESIGN lens: in flight when this file was written — same rule.

---

## FUN lens report (verbatim)

### FN-1 [HIGH] D1's trigger — death-while-carrying — almost never fires at the threat level the owner has already twice verified as absent

**Evidence:** The owner's recorded D0 verdicts (PARKING_LOT.md lines 70-88): "rushers die trivially, nothing endangers the carry, so banking is errand-running", re-confirmed post-taunt ("still a chore"). The numbers agree (data/balance/combat.json): rusher damage 12, full attack cycle 20+6+66 = 92f (~1.53s per swing) with a 20-frame telegraph; hits-to-kill = lobber 5 (>=7.7s of standing in melee), striker 7 (>=10.7s), blocker 14 (>=21.4s), against dodges with 12-18 iframes. Only 7 rushers exist (data/zones/district.json). A wipe requires all three bodies to die. In a 10-15 min first session the realistic D1 event count is: carrying-deaths 0-2 (mostly AI-driven ally deaths), wipes 0-1 only if the owner deliberately overpulls, expiries 0, grace effects 0. No value in death.json can raise this rate — the firing condition lives entirely in combat threat, which is out of D1's scope.
**Failure:** The owner plays 10 minutes, never (or once, incidentally) sees a corpse container, answers "still a chore," and the corpse mechanic gets convicted for a crime combat tuning committed.
**Fold:** (a) Add to the fun-verify preamble: "If you never died while carrying, answer questions 1-4 'N/A — never fired' — that N/A is itself the headline result and indicts threat, not the corpse system." (b) Telemetry: have the pilot/session log print at exit `d1_fired: carrying_deaths=<n> wipes=<n> corpse_looted=<n> carried_lost=<n>` (all four events already exist in the spec's event list; this is a count line, not a system). A zero-fire session is then machine-distinguishable from a fired-but-flat one.

### FN-2 [HIGH] The "tensest walk in the game" is a measured 7-21 second contested-but-trivial stroll — a map-scale ceiling the binding doc already assigned to A3, guaranteeing misattribution if uninstrumented

**Evidence:** Measured geometry (drafts/_d0-cadence-measurements.md + data/zones/nest.json + district.json + step_frames in combat.json): wipe veil = 90f = 1.5s (respawn_frames, confirmed in src/game/world.rb:637); nest spawn->gate = 15 tiles; gate->death tiles = 9-45 tiles. Total wipe->corpse: near corpse ~6.7s (striker) / 9.1s (blocker); deepest spawn ~12.8s / 18.0s; absolute far corner ~14.5s / 20.5s. The cadence file's own caveat says combat inflates these — call it 15-45s opposed. Rusher respawn is 300f = 5s, so the route is always fully repopulated — but repopulated with enemies the owner has verified are trivial. The binding doc names this exactly (death-economy-design.md, "Banking-cadence collapse"): "'everywhere is seconds from the nest' is the default state... the honest fallback is 'the district must grow before the heartbeat exists' — that is an A3-track answer, not a D-track patch."
**Failure:** Fun-verify Q2 comes back "a formality," and there is no way to tell whether the corpse run failed or the 15-second map did — D1 gets folded or re-tuned when the correct verdict was "promote A3."
**Fold:** Split Q2 into two questions: "2a. Did the run back feel dangerous — could you have lost the recovery?" and "2b. Did it feel long enough to dread, or was it over before dread could start?" (2a=no indicts threat, 2b=short indicts map scale, both-yes-but-still-flat indicts the mechanic). Telemetry: log `wipe_to_last_loot_s=<n> contacts_en_route=<n>` per recovery (both derivable from existing events + human-contact frames in the deterministic replay).

### FN-3 [HIGH] Term, grace, pip fade, and expiry flash are all mathematically invisible — the permanent-loss tier is fiction at these numbers

**Evidence:** Term = 36,000f (600s), grace = 18,000f (300s), fade = final third = last 200s (spec lines 77-79, 99-101, 112-114). Measured recovery (FN-2) = 7-21s unopposed, <=45s opposed. Implied recovery margin = (600-45)/600 ~ 0.93-0.99 against the binding doc's own telemetry target of 0.3-0.5, with its own verdict line: ">0.7 median means the term is set dressing" (death-economy-design.md D1 telemetry). The fade begins 400s after death — ~9x later than the last plausible loot. Grace (300s) is ~15x the worst-case unopposed run-back (20.5s); it can never bind. The spec's "deliberately generous... tightens by measurement, never by feel" defense fails its own doc: an unbinding term means the fun-verify measures nothing about loss — there is no measurement to tighten from, only a confirmed zero.
**Failure:** The owner never sees a fade, an expiry, or a grace save; "term expiry is the permanent loss" exists only in the spec text; fun-verify Q3 is answered about a threat that provably cannot mature inside a session.
**Fold:** Data-only, in death.json: `corpse_term_frames` 36000 -> 5400 (90s — anchored to grammar the player already owns: exactly 3x the drop decay_frames 1800, and 18 rusher-respawn waves; against a 30-45s opposed recovery it yields margin 0.50-0.67 — at the doc's target boundary instead of 2x past set-dressing) and `wipe_grace_frames` 18000 -> 2700 (45s ~ 2.2x worst-case unopposed run-back, still covers veil + walk with slack). Note the inversion guard: grace must stay <= term, which the current pair satisfies but any term cut below 18,000f without cutting grace would violate — record `grace <= term` as an assertion in the death.json load path test.

### FN-4 [MED] With D1b fees parked, glean has zero sinks — the pile the corpse protects is a scoreboard number, and "sting" presupposes the pile matters

**Evidence:** The binding doc's own honesty note: "this design ships currency-tension, not gear-tension... D1 tests the weaker substrate" (death-economy-design.md header) — and that was written when D1 still included body fees. The spec then split fees out (D1b, "Deliberately absent"), leaving banked glean spend-less and session-only (restart persistence parked, PARKING_LOT.md line 52). Volume check: drop_table [1,1,2] -> E ~ 1.33/rusher x 7 spawns ~ 9 glean per full map clear (combat.json); a typical corpse holds 2-9 units of a currency with no use.
**Failure:** The owner recovers the corpse flawlessly and feels nothing, because losing it would also have felt like nothing — and the "no sting" verdict lands on the corpse mechanic instead of on the empty currency.
**Fold:** Add fun-verify Q5: "Forget the corpse — did the pile itself matter? If your banked number were silently halved, would you care?" (a "no" routes the failure to D1b/the ledger increment, not D1). Telemetry: log `carried_at_death=<n>` on every corpse_loaded so sting-size is on record next to the sting verdict.

### FN-5 [MED] A settle-blocked interact press has no feedback — 5 seconds where the game's taught grammar says "press = result" and the press silently does nothing

**Evidence:** Spec settle rule (lines 80-84): while settle_left > 0, "interact on the tile skips the container" — with no drop present, the press falls through to nothing. The presentation spec (lines 104-124) defines three states (loaded/looted/expired) but no settling sub-state and no denied-press cue. D0 taught the opposite grammar with the same key: drop pickup is instant. 300f = 5s is long enough for 3+ denied presses mid-fight.
**Failure:** The owner runs to the fallen packmate, hammers H, nothing happens — reads as "the button is broken," not "the corpse is settling"; the mechanic's one mid-fight moment lands as a UI bug. Worse, with trivial rushers the settle is undefended dead time, so the tactical tier reads as: wait 5s, press H — literally Q1's "errand with extra steps."
**Fold:** Presentation-spec edit, data-driven, no new system: the loaded pip renders at reduced alpha (new death.json key `settle_pip_alpha`, hypothesis 0.4) while settle_left > 0 and snaps to full alpha on lootable — the snap IS the "ready" tell; extend vision check 2 to "...and a settling corpse reads distinct from a lootable one." Optionally one dim pulse on a denied press (`settle_deny_flash_frames`, reusing the expiry-flash cosmetic precedent).

### FN-6 [MED] The spec inherits a self-contradictory term-sizing rule from the binding doc: "term >= 3x median recovery" algebraically forbids the doc's own 0.3-0.5 margin target

**Evidence:** death-economy-design.md fine-section: "target term >= 3x median wipe-to-last-corpse recovery time, floor 10 minutes." Margin = 1 - recovery/term, so term = 3x recovery fixes margin at 0.67 — above the entire 0.3-0.5 target band and brushing the 0.7 set-dressing line; hitting 0.3-0.5 requires term = 1.4-2x recovery. The 10-minute floor at measured scale (FN-3) then forces ~0.95. The spec (line 77-79) adopts the floor verbatim without flagging the conflict.
**Failure:** First telemetry run comes back margin ~0.95, the doc says "set dressing," the doc also says the term is correctly sized — the tuning loop has no consistent oracle and the argument gets re-litigated at fold time.
**Fold:** One sentence in the spec's Term paragraph: "Anchor conflict recorded: the doc's 3x-multiple and its 0.3-0.5 margin target are mutually exclusive; D1 binds to the MARGIN TARGET (0.3-0.5 on the deepest corpse), and corpse_term_frames is a hypothesis to be reset from the first session's measured wipe_to_last_loot_s."

### FN-7 [LOW] The only expiry a session will ever contain is scripted off-camera, and the on-screen tell is a 0.33s flash — the loss tier has no witnessed presentation at all

**Evidence:** Gate act 4 asserts the deliberate expiry "via event (off-camera allowed)" (spec lines 128-133; doc's script-shape paragraph says the same). expiry_flash_frames = 20 (spec line 101) = 0.33s at 60fps, on a tile that is by construction away from the action. Per FN-1/FN-3, the owner will organically witness zero expiries.
**Failure:** The one moment that defines "permanent loss" has never been seen by a human when D1 ships; the fun-verify cannot report on a beat that has no witnessed rendering.
**Fold:** expiry_flash_frames 20 -> 45 (0.75s, still cosmetic-record scale); add fun-verify Q6: "Did any corpse's clock ever influence a decision — did you ever notice one running out?" ("never noticed" = term-tuning signal, recorded as such, not mechanic failure).

### FN-8 [LOW] Fun-verify Q1 promises a "walk" the tactical tier doesn't contain — after a possessed death the survivor is already standing on the corpse

**Evidence:** Possessed death -> forced-swap to a surviving packmate (spec line 91, A0 flow); the pack fights together, so the "going back for it" distance in the tactical tier is 0-5 tiles. The only actual walk is the post-wipe run (Q2's territory). Q1 as worded (spec line 156-158) asks the owner to rate a walk that lasts under 2 seconds.
**Failure:** The owner answers Q1 "not tense" about a 5-tile shuffle, and the answer contaminates the thesis question it shares wording with.
**Fold:** Reword Q1 to the tier's real tension: "A packmate died carrying mid-fight — did protecting/waiting out the settling corpse while deciding 'loot now or finish the fight' feel tense, or like standing in line?" Reserve "tensest walk" language exclusively for Q2.

## FUN lens verdict (verbatim)

D1 as specced cannot reliably move the "still a chore" verdict at current map scale: its trigger fires ~0-2 times per session against owner-verified-trivial threat, its recovery is a 7-21s stroll, and every clock in the apparatus (600s term, 300s grace, 200s fade) is 10-30x too slack to ever bind, so the sting the thesis promises has no mathematical room to occur. The single highest-leverage data change is corpse_term_frames 36000 -> 5400 with wipe_grace_frames 18000 -> 2700, which moves implied recovery margin from ~0.95 (set dressing by the binding doc's own line) to ~0.5-0.67 and makes the fade/expiry grammar witnessable inside one session. The fun-verify must instrument carrying_deaths / wipes / wipe_to_last_loot_s / contacts_en_route / carried_at_death and add the N/A-never-fired branch plus the split Q2a/Q2b wording, so a flat verdict is attributable to map scale (A3's problem) or threat absence (combat's problem) instead of being booked, for a third time, against the one mechanic actually on trial.

---

## CODE-FIT lens report (verbatim; HIGHs verified inline by dev of record — note at end)

### CF-1 [HIGH] Confirmed: the cosmetic corpse record is killed or blanked by four independent paths long before its container's term ends — as written, the run back arrives to a bare tile

**Evidence:**
- src/game/world.rb:587-588 — CORPSE_FADE_FRAMES = 600, CORPSE_CAP = 40.
- src/game/world.rb:565 (prune_caches) — corpses.reject! on age > CORPSE_FADE_FRAMES: hard-deletes the record at age 600, container lives 36,000.
- src/game/world.rb:590-594 (leave_corpse) — list.shift if list.length > CORPSE_CAP: evicts the oldest record unconditionally.
- Re-entry ordering: check_transition (world.rb:218) runs before prune_caches (world.rb:225) in the same tick_world, and corpses/prune_caches operate on @corpses[@zone_name] (world.rb:68) — so the very tick the player steps back into the district, every corpse older than 600 frames is pruned, before one frame of that zone renders.
- src/app/renderer.rb:180-186 — alpha = (140 * (1 - age/600)).clamp(0,140): even a surviving record draws at alpha 0 past age 600.
- Clock skew: @frame advances during hitstop (world.rb:73-79) and the veil (world.rb:98) while the container's term_left (counter-based, per spec) pauses — corpse age and term drift permanently apart.

**Failure:** (a) Post-wipe run back: veil 90f + walk back easily exceeds 600f -> district prunes all pack corpses on entry; containers exist but state-1 "loaded corpse at full strength + pip" has nothing to draw on. (b) Same-zone farming: body dies loaded, player keeps hunting; humans respawn every 300f (combat.json:129); 40 subsequent kills shift-evict the loaded corpse mid-fight while its container has 9 minutes left.

**Fold:** Add to the sim spec: a corpse record linked to a live container is EXEMPT from both the prune_caches age-reject and the CORPSE_CAP eviction (evict oldest unprotected; protected count is bounded by deaths-with-carry per term window). The link must be a unique monotonic corpse serial id stored on both records — the spec's corpse_at_frame (tile+frame) key can collide: blocked_for excludes already-dead actors mid-resolve_attacks (world.rb:65, 107-111), so two same-frame knockback deaths can land two corpses on one tile at one frame. Renderer keys "full-strength + pip" off that same link.

### CF-2 [MED] "Looted: fade starts from that frame" / "Expired: fade continues" is impossible from the existing fade anchor — both states snap to invisible

**Evidence:** src/app/renderer.rb:181-182 computes fade solely from world.frame - c[:at_frame]. A corpse held at full strength while loaded (spec state 1) past 600 frames has an anchor-derived alpha of 0 the instant the loaded exemption lifts.

**Failure:** Loot a corpse 30 seconds after the death: pip disappears AND the whole body vanishes on the same frame — states 2 and 3 never exist as fades; the blocking corpse_states_distinct vision check fails by construction.

**Fold:** Spec must state: at :corpse_looted and at term expiry, the sim rewrites the linked corpse record's at_frame to the current frame (event-time, sim-owned mutation — renderer stays a pure reader, matching the taunted_target pure-reader law at creature.rb:200-205). Accept that at_frame fade doesn't pause in hitstop (pre-existing cosmetic behavior).

### CF-3 [MED] Knockback kills — i.e. every standard human kill — draw the corpse one tile away from the container's interact tile

**Evidence:** src/game/creature.rb:171-183 — take_hit runs knock_away_from before emitting actor_died, even on the killing blow. src/game/grid_walker.rb:78-86 — commit_dash commits tile_x/tile_y to the landing immediately; px/py tween later. So at handler time (world.rb:609-624) actor.tile = knocked landing but actor.x/y = pre-knock pixels, and leave_corpse (world.rb:590-594) snapshots both. Renderer draws the corpse at c[:x], c[:y] (renderer.rb:184). Both human kits carry knockback_tiles: 1 (combat.json:138 rusher, :156 husk).

**Failure:** Pack body dies to a husk swing: container spawns at actor.tile (landing), corpse body renders at the pre-knock spot. The spec's pip "centered on the corpse" points the player at a tile where interact finds nothing; the recoverable tile is the adjacent one. Drops don't have this bug because they render tile-centered from d[:tile] (renderer.rb:129-141).

**Fold:** Anchor the glean pip to the CONTAINER'S TILE (tile-centered, exactly the drop draw pattern), not the corpse rect; note the corpse-rect offset as accepted existing cosmetics. (Alternative — snapshotting post-knock coordinates in leave_corpse — changes existing corpse visuals for all kills; out of D1 scope.)

### CF-4 [MED] The expiry flash's "cosmetic record precedent" (taunt pulses) is a global, zone-unfiltered, enter_zone-cleared list — expiries fire in ALL zones

**Evidence:** @taunt_pulses is one flat array (world.rb:50), cleared on enter_zone (world.rb:474), and drawn with NO zone filter (renderer.rb:302-317) — safe today only because pulses are created in and die with the current zone. Term expiry, per spec, happens in every zone every tick (the tick_drops law, world.rb:387-396).

**Failure:** A container expires in the abandoned district while the player stands in the nest -> flash record lands in a global list -> a dark flash renders at that tile IN THE NEST (wrong zone's floor flashes).

**Fold:** Spec the flash storage as PER-ZONE (the @drops/@corpses Hash.new pattern), ticked for all zones in tick_world, rendered for the current zone only; per-zone storage also removes any need to clear it in enter_zone.

### CF-5 [LOW] :corpse_looted payload is self-inconsistent inside the spec; the carried_lost re-point is otherwise safe

**Evidence:** Spec line 89 says :corpse_looted (actor, amount, carried); lines 96-98 say (actor, tile, amount, carried). Current carried_lost emits (actor:, amount:) (world.rb:616); the spec's expiry payload (amount, tile, zone) drops actor — verified safe: Event#[] returns nil on missing keys (event_bus.rb:16-18), the only subscribers are the two D0 tests asserting e[:amount] only (world_test.rb:1058-1062, 1074) and the harness logger, which serializes whatever keys arrive (harness/scenes/world_scene.rb:18-23, 32-34).

**Failure:** Gate scripts and tests written against one payload shape fail against the implemented other.

**Fold:** Pick one payload per event and state it once — recommend :corpse_looted (actor, tile, amount, carried) and carried_lost (amount, tile, zone), noting explicitly that actor is dropped from carried_lost because the body may be revived by expiry time.

### CF-6 [LOW] The wipe-grace rationale mis-states the mechanics: terms cannot expire during the veil, and the veil is 90 frames

**Evidence:** During :nest_respawn tick_world never runs (world.rb:83-92), so per the spec's own tick_drops-pattern design the term counters are frozen for the whole veil; respawn_frames: 90 (combat.json:12) = 1.5 s. Spec lines 43-45 justify wipe_grace_frames = 18000 with "the first-dead corpse must not expire during the veil the player cannot act in (panel finding B-X4)."

**Failure:** None mechanical — the grace is genuinely needed — but a data value whose recorded rationale is wrong invites a future mis-tune ("the veil is 90 frames, shrink the grace"). The scope contract's own law is that the data file must not encode an accident.

**Fold:** Reword: the grace covers the RUN BACK (nest->district travel plus re-fight time after the first-dead corpse has been draining all fight); add the test "term does not tick during nest_respawn" to pin the veil pause (the drops precedent test to mirror: test_drops_decay_across_zones, world_test.rb:904-917).

### CF-7 [NONE] Pre-seeded suspicion CONFIRMED at full described severity (it is CF-1); all remaining spec claims about the code verified accurate

- tick_drops pattern: ticks all zones every sim frame (world.rb:387-396); hitstop pauses it (early return, world.rb:74-79); the veil pauses it (nest_respawn skips tick_world, world.rb:83-92). Spec's pause claims match reality exactly.
- enter_zone clears only @flow_cache/@projectiles/@impacts/@taunt_pulses/mark/@last_damaged_target (world.rb:468-476) — per-zone hashes (@drops, @corpses) survive; @corpse_loads as a per-zone hash survives as claimed.
- respawn_pack touches only humans' release_taunt! + revive + enter_zone (world.rb:532-541) — nothing clears a per-zone container list; revive! zeroing carried (creature.rb:242) is safe because carried drains into the container at death, before revival.
- Interact priority: current order is drop-pickup -> bank with early return (world.rb:179-195); inserting corpse-loot between composes with the two-press rule (precedent test world_test.rb:1133-1143). Settle-skip fall-through to bank is unreachable today (stations exist only in the nest — data/zones/nest.json:33; the district has none — and the nest has zero enemy spawns, nest.json:32), but spec should still pin "skip = fall through" for determinism.
- Events: carried_lost registered (world.rb:22) and emitted only at world.rb:616; :corpse_loaded/:corpse_looted are new. Registration law satisfied by extending World::EVENTS.
- D0 tests to flip exist where claimed: test_carried_vanishes_when_the_body_dies (world_test.rb:1051-1065, incl. the explicit "no corpse container in D0" assertion at :1064) and test_ally_death_also_vanishes_its_carried (:1067-1079). test_banked_survives_the_wipe (:1118-1131) stays valid under D1.
- Stacking: one-drop-per-tile merging is a drops-only rule (world.rb:403-416) and constrains nothing about containers; append-order find gives creation-order looting, and settle ordering follows creation order automatically.
- Renderer purity: drops carry frames_left/decay_frames on the record and the renderer pure-reads them (renderer.rb:129-141) — the container's term_left/term pip fade fits this pattern via a corpse_loads accessor with zero sim reads from draw.

---

## DESIGN lens report (summary — full text in the task transcript; findings + fidelity ledger)

### DS-1 [HIGH] D1-minus-fees doesn't soften the carry risk — it deletes it, and Q3 cannot tell "decision energized" from "decision removed"
Doc law 2 makes bank-or-push the loop's heartbeat; doc's D1 keeps death priced via fees.
Spec trims fees -> a carried pile is NEVER permanently at risk (carrier lives = bank it;
carrier dies = 10-min-safe container). Death becomes the SAFEST outcome for a carry;
rational play stops banking. Q3 accepts "chore gone because decision gone" as a pass.
**Fold:** (1) state the inversion outright in "Why" ("D1 removes the permanent
single-death loss entirely; the experiment is whether drama alone moves the verdict —
banking collapse = D1b's trigger, not a D1 tuning knob"); (2) restore the doc's D1
telemetry block (un-recorded trim!) + banked-event cadence vs D0 baseline; (3) fun-verify:
"Did you still bother banking? If not, did you miss it?"

### DS-2 [HIGH] The clocks cannot tick out at this scale — wipe_grace 18000 is a spec-invented number that pre-answers Q2's "clock pressure" with "none"
Doc gives grace NO value (B-X4's veil is 90f); 5 min is spec-invented; margin on a 5-min
grace ~ 0.9+ vs the doc's 0.3-0.5 target. Q2 bundles clock-pressure (arithmetically absent)
with human-pressure (on record as trivial) -> "formality" answer unreadable.
**Fold (reviewer pick):** measured grace ~ 2x median wipe-to-last-corpse recovery;
pre-register interpretations. [Dev-of-record adjudication below overrides the "term floor
is doc-locked" half of this finding via FN-6's proven self-contradiction.]

### DS-3 [MED] Presentation collides with HEAD's corpse lifecycle (independent rediscovery of CF-1/CF-2 — merged with those folds)

### DS-4 [MED] Glean pip is pixel-identical to a free drop exactly in the drop-on-corpse case the spec itself creates; corpse_load_reads never stages that frame
Drop = 10px filled magenta square tile-centered (renderer.rb:129-141); spec pip = same
color/geometry/center; drop-on-corpse renders CONCENTRIC. **Fold:** pip becomes a HOLLOW
magenta outline square (taunt-pulse precedent: outline = state, filled = pickup); gate
script must include one drop-on-loaded-corpse frame; check wording amended.

### DS-5 [MED] Spec quotes "a corpse mid-melee is not a bank window" while shipping semantics where it IS one after 5s — own the deviation from doc law 3 (out-of-combat gate)
Q4's mid-fight decision EXISTS only because of the deviation. Also: loot_settle_frames
(300) == rusher respawn_frames (300) — loot window opens exactly as reinforcements land;
currently an unrecorded cross-file accident. **Fold:** ownership sentence + designed-
alignment note + settle-open-to-loot telemetry.

### DS-6 [MED] "The doc pre-approved it" overstates — doc approved recoverable-replacing-vanished inside a FEE-PRICED D1; the NET softening is this spec's own trim
**Fold:** rewrite the cite honestly (containers approved; fee trim and therefore net
softening = this spec's recorded call; variable under test is drama, not price).

### DS-7 [LOW] Watch list incomplete: add suicide fast-travel (doc-listed) + grace-refresh (spec-new: deliberate wipe EXTENDS loot clocks); note pack-parking/die-to-teleport-home are structurally dead (enter_zone moves the whole pack)

### DS fidelity ledger (doc D1 staging -> spec): all implemented or recorded-trimmed EXCEPT
- **Telemetry block (margin target 0.3-0.5, per-corpse stagger, second-wipe frequency): MISSING — the only un-recorded trim.** Restored by fold.
- Doc's data-reading caveat (no fine => death-frequency = recklessness upper bound): absent — one-line restore.
- "Wipe leaves three loaded corpses" -> spec's "at least two" is a consequence of the no-re-growth trim; deserves one explicit line.
- Settle: implemented-with-changed-semantics (flat clock vs out-of-combat) — must be owned (DS-5).

---

## Dev-of-record verification note (inline verify stage, replaces the dead workflow's verify agents)

CF-1 CONFIRMED by direct read: prune_caches reject at world.rb:562-566; unconditional
shift-evict at world.rb:590-594; renderer fade anchored solely to at_frame with
clamp-to-0 at renderer.rb:179-186; @frame increments during hitstop early-return at
world.rb:73-79 (clock-skew claim real). CF-2 confirmed by the same renderer read.
CF-4 confirmed: @taunt_pulses flat + unfiltered reader (world.rb:50, :71). CF-6
confirmed: :nest_respawn branch never calls tick_world (world.rb:83-92). CF-3
mechanism consistent with leave_corpse snapshotting both tile and x/y
(world.rb:590-594); fold (pip anchored to container tile) is correct regardless of
tween timing details. All folds accepted.

---

## FOLD LEDGER (dev-of-record adjudication, 2026-08-11 — what went into the REVISED spec)

Cross-lens conflicts adjudicated:

1. **TERM SIZING (FN-3/FN-6 vs DS-2).** DS-2 called the 10-min term floor "doc-locked."
   Overruled: FN-6 PROVES the doc self-contradicts (term = 3x recovery fixes margin at
   0.67; the 10-min floor at measured scale forces ~0.95 — both above the doc's own
   ">0.7 = set dressing" line). When the authority contradicts itself the spec must
   pick an anchor and record the conflict. Anchor chosen = the MARGIN TARGET
   (0.3-0.5), because it is the measurable oracle the doc's own telemetry defines.
   Values: corpse_term_frames 36000 -> 5400 (90s = 3x drop decay_frames, 18 rusher
   waves); wipe_grace_frames 18000 -> 2700 (45s ~ 2.2x worst-case unopposed run-back).
   Both recorded as HYPOTHESES to be reset from measured wipe_to_last_loot_s. This
   also makes fade telegraph + expiry witnessable in one session (FN-3, FN-7) and
   makes the grace floor genuinely load-bearing.
2. **PIP TREATMENT (DS-4 + CF-3 + FN-5 merged).** Pip = HOLLOW magenta outline square
   (DS-4: filled = pickup, outline = state), TILE-CENTERED on the container's tile
   (CF-3: corpse rect can sit a tile away after knockback kills), at settle_pip_alpha
   (0.4) while settling, snapping to full when lootable (FN-5: the snap is the ready
   tell). FN-5's optional deny-flash SKIPPED — the dim pip already signals not-ready
   before the press; one variable at a time.
3. **DS-3 = CF-1/CF-2** (independent rediscovery) — single fold: container<->corpse
   serial link, prune/cap exemption while linked, at_frame re-anchor + link clear at
   loot/expiry (sim-owned, event-time; renderer + prune read the link flag only).

All other folds accepted as proposed: CF-4 (per-zone flash), CF-5 (pinned payloads:
:corpse_looted (actor, tile, amount, carried); carried_lost (amount, tile, zone)),
CF-6 (grace rationale reworded to run-back + veil-freeze test), DS-1 (inversion owned
+ telemetry restored + banking question), DS-5 (settle deviation owned + 300==300
designed-alignment note), DS-6 (honest cite), DS-7 (watch list completed), FN-1
(N/A-never-fired preamble + d1_fired count line), FN-2 (Q2 split 2a/2b +
wipe_to_last_loot_s + contacts_en_route), FN-4 (pile-mattering question merged with
DS-1's banking question), FN-6 (anchor-conflict sentence), FN-7 (expiry_flash_frames
20 -> 45 + clock-noticed question), FN-8 (Q1 reworded to the mid-fight decision;
"tensest walk" reserved for Q2).

Fun-verify restructured to 6 questions + N/A preamble (was 4).
death.json gains settle_pip_alpha (0.4); grace <= term pinned by a data-load test.
