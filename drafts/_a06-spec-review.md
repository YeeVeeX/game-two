# A0.6 blocker-taunt spec review — banked verdicts (2026-08-10)

Spec under review: docs/superpowers/specs/2026-08-10-a0.6-blocker-taunt.md @ 70509cf.
Structure: lens 0 = dev-of-record pre-verification (main session, code read directly);
lenses A/B/C = adversarial agents (code-fit, design, fun). Fold ledger at bottom.

## Lens 0 — dev-of-record pre-verification (code read in main session)

### 0.1 Ring-arc one-shot claim — spec wording WRONG, mechanism SAFE (MED)

The spec says the pulse fires "via the existing action_can_trigger?/action_triggered!
one-shot used by projectile/dash/volley". Verified: `resolve_tile_action`
(world.rb:268) has NO one-shot today — ring damage resolves EVERY active frame and
dedups per-victim via `action_can_hit?` (creature.rb:62). The one-shot pair EXISTS
(creature.rb:66-67) and is simply unused by the ring path. Consuming it for the taunt
pulse inside the ring branch is safe: `@action_triggered` has no other reader on ring
kits, `begin_action` resets it per cast (creature.rb:232), and ring damage keeps its
own per-victim dedup untouched. Amendment: spec must say "taunt CONSUMES the
(currently unused-on-ring) one-shot; ring damage resolution is per-victim-dedup and
unchanged" — not "used by the ring arc".

### 0.2 Cross-zone landmines — mostly moot BY CONSTRUCTION, one real leak (MED)

Humans tick only in the current zone (world.rb:207-208, `humans = @humans[@zone_name]`)
and the WHOLE pack transitions together (`enter_zone` rebinds every living member,
world.rb:449-451). So a ticking taunted human and the blocker body are always in the
same zone; flow_to/blocked_for/surround_slot never see a cross-zone anchor. Frozen
humans in an abandoned zone hold their remaining frames — existing timer law, fine.

The REAL leak: spec says the lock ends on "taunter's death" but implements that as
`taunted_target` returning nil while the taunter is dead. If the state is only GATED
(not cleared), a pack wipe → nest respawn → `revive!` resurrects the taunter, and a
frozen district human still holding frames re-acquires the lock when the pack walks
back in — a lock that "ended" un-ends. Amendment: taunter death must CLEAR the
victim's taunt state (zero frames at the release moment, i.e. check-and-clear inside
`taunted_target` or in the AI read path), not merely gate the getter. Test to add:
taunter dies → revives → previously-taunted human is NOT re-locked.

### 0.3 Hitstop/veil pause — spec claim HOLDS (verified)

`tick_body` is called only from `tick_world` (world.rb:207-208). Hitstop early-returns
before the state dispatch (world.rb:72-77) and `:nest_respawn` never calls `tick_body`.
A `@taunt_frames` decay in `tick_body` pauses under hitstop and the wipe veil exactly
like stagger. No amendment.

### 0.4 Swap-inertness — spec claim HOLDS (verified)

`Pack#swap_next!`/`forced_swap!` move a pointer only (pack.rb:34-50); `enter_zone`
rebinds walkers but never recreates Creature objects (world.rb:449-451,
creature.rb:203-205). `.equal?` identity of the taunter is stable across swap, gate,
and respawn. `taunted_target` is well-defined for possessed and husk taunter alike —
the AI reads the victim's state, never the possession pointer. No amendment.

### 0.5 Death-math pre-read (for lens C cross-check)

combat.json: blocker 160 HP; rusher 12 dmg, windup 20f, exhaust 66f, 5 spawns in
district (data/zones/district.json), respawn 300f. Slam: 30 dmg, knockback 2 tiles,
stagger 45f, exhaust 600f. Post-Slam, victims are 2 tiles out + 45f staggered
(rusher step_frames 16 → ~32f walk back) → first re-hit ≥ ~97f after cast; then one
hit-window per 66f. In the 300f lock, ~3-4 windows × up to 5 rushers × 12 = the
blocker CAN die inside its own taunt if it stands still as a husk. Whether that is
self-destruct or the intended trade (tank buys 5s, may fall, room turns on you) is
lens C's call — but the husk's post-swap behavior (lens B question 1) decides it.

### 0.6 Husk anchor behavior — pre-read (for lens B cross-check)

AiController#tick (controllers.rb:77-87): a pack husk with any hostile within
aggro_tiles (10) ENGAGES — it only `follow`s the possessed when nothing is in aggro
range. Post-swap, taunted rushers converge ON the blocker, so its nearest hostile is
adjacent or closing → the husk blocker stands and swings (arc3, knockback 1) rather
than trailing the striker. Drift is bounded: chase_step only fires when its target
is out of adjacency, and the taunted flow field re-anchors on the blocker's new tile.
The pincer should hold WITHOUT any AI change. Lens B verifies independently.

## Lens A — code-fit/determinism (agent report)

(pending — agent running)

## Lens B — design (agent report) — VERDICT: SOUND-WITH-FIXES

### B1 HIGH — the anchor WALKS; the spec never analyzed the taunter's own AI

Post-swap the husk blocker runs AiController#tick (controllers.rb:80-86), in priority:
1. **Mark-drag (the killer case):** a live pack mark makes the husk engage the marked
   target with NO distance gate (`marked ||` at :82) — and mark is the trained A0.5
   verb. Press `;` mid-carve and the anchor abandons its post, marching the whole
   taunted knot onto the tile the player just ordered his damage onto. The two
   order-verbs fight each other and taunt loses.
2. **Nearest-chase drift:** transient (~1-2s), toward humans; tolerable.
3. **Follow:** no human within 10 → husk follows the POSSESSED — walks the taunted
   train at the striker. Rare but the exact inversion of the fantasy.

Amendment (one targeting clause, not an AI overhaul): pack-side, a creature with
living taunt victims targets its nearest living taunt victim — above mark, no aggro
gate: "mark binds allies, taunt binds enemies, and your own taunt binds YOU." Gate
amendment: taunt_anchor.json must press mark during the taunt window or
taunt_convergence_reads can pass forever without exercising the verb interaction.

### B2 — Slam coupling: SHIP-AS-SPECCED (not fatal), two honesty notes

Coverage t=12..312 of a 600f cycle = 50% uptime, ~4.8s exposed. The off-beat has
counterplay (dodge/swap/kite) and expiry-snap-to-nearest makes it stakes, not
downtime. MED note: taunt fires on the one-shot regardless of victims — an air-Slam
at range 5 taunts the room WITHOUT wading in; the damage-coupling is optional, only
the exhaust-coupling is real. State it (a whiffed cast burning 600f is the real cost
model). LOW: the recorded decouple fallback contradicts the spec's own out-of-scope
("any second special or new binding") — reword to "same key, two clocks" (L always
pulses taunt on its own short exhaust; Slam damage rides 600f) or number-first.

### B3 MED — readability collisions the spec missed

1. **Telegraph flare kills the underline in exactly the modal frame:** the swell
   draws to y+SIZE+4 (renderer.rb:195-197) in hot red; a 3px rust underline at
   y+SIZE sits inside it — invisible precisely when the taunted human attacks.
   Fix: pin underline at y+SIZE+5 (clear of the swell); spec the offset so
   taunt_underline_reads asserts it.
2. **A rust circular ring reads as volley brackets in a static frame AND lies about
   Chebyshev range.** Fix: one continuous expanding SQUARE outline (range-honest,
   shape-distinct from volley's per-tile brackets). Keep rust hue (blocker body
   color = correct ownership semantics).
3. **Expiry unreadable:** lock-snap at frame 300 is the striker's most dangerous
   moment. Fix: underline alpha fades over the final third of duration_frames —
   grammar already taught by drop decay (renderer.rb:131-133).

### B4 LOW — record the silent calls

Gate-pull-in-miniature (taunt, step through gate, return → ≤300f bypass beeline) is
emergent depth, self-limiting, cite A2 inheritance. No line-of-sight (precedent:
mark is LoS-free; a shockwave through a wall is fiction-coherent) — write the
sentence. No leash, deliberately asymmetric with mark's 14 — write the sentence.

### B5 LOW — law nits

pulse ~20f needs a data home: put `pulse_frames` in the taunt block. "ANY kit
special carrying a taunt block pulses" overstates: pulse is generic, OBEDIENCE is
human-AI-only (pack husks ignore locks, possessed can't be compelled) — amend.

## Lens C — fun (agent report) — VERDICT: FUN-AT-RISK

### C1 HIGH — the map cannot stage the fantasy; median taunt provokes ONE rusher

district.json rusher spawns: (20,6),(35,5),(10,12),(30,18),(18,24) — closest pair
is Chebyshev 10; NO two spawns within one taunt radius (6). With aggro 10 you meet
rushers one at a time; a 3+ mob needs a deliberate multi-screen herd eating 12/66f
per rusher the whole walk. The median cast — what the owner will experience —
taunts one rusher that already targeted him. A verb no ordinary fight can showcase
fails "every commit changes what the player feels."
Amendment: add ONE clustered rusher trio to district.json as part of A0.6 (justified
by taunt_convergence_reads needing multiple humans in frame), placed away from
existing gate-script paths; re-verify existing replays still exercise their beats
(grep event logs, not just vision hatches).

### C2 MED — 50% uptime + respawn treadmill: the trough is the pre-A0.6 game

rusher respawn 300f puts kills made in the window back on the map DURING the trough,
un-taunted, while Slam is still ~230f from ready. Amendment: make the decouple
trigger measurable — "if fun-verify Q3 = too short OR ≥1 pack death occurs during a
taunt trough in a 3-pull, decouple onto ~360f own clock; never buff duration/HP."
Reword Q3 to ask about the GAP between taunts, not just the 5s.

### C3 MED — death-math: taunt is a FUSE, not a self-destruct — say so

Rusher hit windows post-Slam: first ≈ t=97, then every 66f → max 4 hits × 12 per
rusher per window. Fresh blocker unpeeled survives N≤3 (144 dmg); N=4 dies ≈
expiry; N=5 dies ≈ t=229. With the striker carving from t≈70, N=3 survives at ~50HP.
Survivability is CONDITIONAL on executing the swap-carve — good tension. But a dead
blocker = tankless until full wipe (pack members never respawn mid-run). Amendment:
one sentence naming the fuse as intended; add fun-verify Q4: "Did the blocker die
while taunting, and did that feel like your mistake or the game's?"

### C4 LOW (pro-spec) — the delta is real; pin it with a test

nearest = min_by [chebyshev, index] and roster order is [striker, blocker, lobber] —
EVERY distance tie goes to the striker today. The tank structurally loses ties to
the body you swapped to protect; taunt flips that. Amendment: add tie-break test —
rusher equidistant (d=1) to striker and blocker targets STRIKER un-taunted, BLOCKER
taunted (pins the delta against roster reorder).

### C5 LOW — 300f "matches the respawn beat" is numerology

The beat actually couples AGAINST the player (C2). Defensible derivations: 300f ≈
striker's 3-4-kill clearance of a median pull ≈ blocker's unpeeled N≤3 bound; 6
tiles = mark_range_tiles (the symmetry law). Also state: range 6 < aggro 10 means
taunt never ACQUIRES — it is purely re-target + lock; no pulling use case exists
(at melee ranges — B4's gate-pull works via the bypass, not acquisition).

### C6 — cheapest falsifying playtest (pre-implementation, zero code)

`rake pilot NAME=taunt_baseline SEED=11`: possess blocker, herd (10,12)'s rusher
toward (18,24), stand with both adjacent (frame F0), swap to striker, carve.
Measure: (a) retarget latency from striker's first attack_hit until a rusher hits
the STRIKER; (b) blocker HP at F0+300 (calibrates the 12/66f model).
FALSIFIED if latency > 240f (baseline already grants the carve window — re-scope).
CONFIRMED if ≤ ~90f (tie-break flips on contact — also quantifies "tank too weak").
The export doubles as the baseline half of taunt_anchor.json.

## Lens A — code-fit/determinism (agent report) — VERDICT: SOUND-WITH-FIXES

### A1 MED — taunter death only SUSPENDS the lock; pack-wipe revival RESURRECTS it

Confirms lens 0.2 independently with the full trace: `taunted_target` gating on
"taunter alive" never clears state; `:nest_respawn` freezes district humans with
frames intact; `respawn_pack` calls `revive!` on the SAME Creature objects
(identity preserved) → walking back through the gate re-locks humans the revived
blocker never re-taunted, bypassing the aggro gate from across the room. The spec's
own test ("taunter death releases the lock") as written would PASS while this ships.
Amendment: lazy clear — `taunted_target` zeroes `@taunted_by`/`@taunt_frames` when
it observes the taunter dead (lazy is the only option: victims in abandoned zones
don't tick). Adversarial test: taunt → wipe → respawn → re-enter → NOT taunted.

### A2 MED — "ANY kit special carrying a taunt block pulses" is false for 3 of 4 arcs

dash consumes the one-shot itself (world.rb:278-279); projectile/volley gate their
launch on it (world.rb:257,261). A taunt block on those arcs would silently never
pulse or race the launch for the flag. Amendment: reword to "any RING-ARC special
carrying a taunt block pulses; other arcs consume the one-shot for their launch."

### A3 LOW — pulse record zone-scoping unspecified

Corpses are per-zone; projectiles/impacts are CLEARED in enter_zone. A knockback
shove through a gate mid-pulse would render a ghost ring at old-zone coordinates.
Amendment: clear pulse records in enter_zone (projectile/impact precedent).

### A4 LOW — "~20f" pulse duration has no data home

Amendment (merged with B5): `pulse_frames` joins the taunt block in combat.json.

### A5 LOW — the hero sequence "Slam → swap" is swap-LOCKED for 16 frames

`special_committed?` (windup 12 + active 4) refuses Tab with no error, and
@swap_was_down then swallows the held key's rising edge. The pilot-authored gate
script will silently drop the swap unless it lands ≥16f after the Slam press.
Amendment: harness note + verify the export contains possession_changed.

### A — claims verified clean (no findings)

Ring one-shot mechanism SAFE as specced (flag unread on ring path today; consuming
it cannot affect ring damage's per-victim dedup). Windup→active flips in tick_body
BEFORE resolve_attacks the same tick, and pack iterates before humans — the pulse
always resolves before a same-tick killing blow. Cross-zone invariant holds (a
ticking victim is always co-zoned with a LIVING taunter; dead taunter → nil).
Hitstop/veil pause exact (matches lens 0.3). Swap-inertness exact (matches 0.4).
:taunted into World::EVENTS satisfies the event law. cfg[:taunt] guard correctly
excludes rusher/husk ring ATTACKS (no taunt block).

## Fold ledger (dev-of-record decisions)

| # | Finding | Decision |
|---|---|---|
| B1 HIGH | anchor walks (mark-drag/follow) | FOLD — new design decision 5: pack-side, a creature with living taunt victims targets its nearest living victim, above mark, no aggro gate ("your own taunt binds you"). Test + mark-press in gate script. |
| C1 HIGH | map can't stage the fantasy | FOLD — one clustered rusher trio in district.json (the single zone-data change), placed away from existing script paths; all 4 existing gates re-verified green before merge. Respawn-home nearest-spawn coupling checked. |
| A1/0.2 MED | death suspends, revival resurrects | FOLD — lazy clear in taunted_target; resurrection test added. |
| A2/B5 MED | genericity claim false | FOLD — reworded ring-arc-only; obedience is human-AI-only. |
| B2 MED | air-Slam honesty | FOLD — spec states the exhaust-coupling is the real cost model; whiffed cast burns 600f. |
| B2 LOW | fallback contradicts out-of-scope | FOLD — fallback reworded "same key, two clocks" (L pulses taunt on own short exhaust; Slam damage rides 600f) or number-first. |
| B3 MED | underline vs telegraph flare | FOLD — underline pinned at y+SIZE+5 (clear of +4 swell); offset asserted in vision check. |
| B3 MED | circle lies about Chebyshev | FOLD — expanding SQUARE outline, range-honest. |
| B3 MED | expiry unreadable | FOLD — underline alpha fades over final third (drop-decay grammar). |
| C2 MED | trough is the old game | FOLD — measurable decouple trigger written into spec; Q3 reworded to ask about the gap. |
| C3 MED | fuse undocumented | FOLD — fuse named as intended; Q4 added (blocker death: your mistake or the game's?). |
| A3 LOW | pulse ghost cross-zone | FOLD — cleared in enter_zone. |
| A4/B5 LOW | pulse_frames data home | FOLD — joins the taunt block. |
| A5 LOW | 16f swap lock | FOLD — harness note + possession_changed verification. |
| B4 LOW | silent calls unrecorded | FOLD — gate-pull, no-LoS, no-leash sentences added. |
| C4 LOW | tie-break delta | FOLD — tie-break test added (striker un-taunted / blocker taunted). |
| C5 LOW | 300f numerology | FOLD — derivation replaced (clearance bound + N≤3 bound; 6 = mark symmetry). |
| C6 | falsifying playtest | FOLD — baseline pilot flight (taunt_baseline) runs BEFORE taunt code; export seeds taunt_anchor.json. |

## Baseline falsifier RESULT (2026-08-10, pilot NAME=taunt_baseline SEED=11)

**Thesis CONFIRMED — retarget latency ≈ 14–17 frames** (bound: ≤90f confirms,
>240f falsifies). Five independent contacts mined from the event log: striker's
first attack_hit on an engaged rusher → that rusher's first hit ON the striker:
510→525 (15f), 851→865 (14f), 948→962 (14f), 1049→1064 (15f), 1262→1279 (17f).
The tie-break flip fires essentially on contact — the tank cannot hold aggro for
even one exchange. Also observed: possessed blocker wading solo took chip to
100–136 HP per sweep while the striker husk DIED in two of three runs (rushers
focus it on every tie). Quantifies the owner's "tank too weak" verbatim.
Export: tmp/pilot/taunt_baseline/baseline.json (run_until=1027) — seeds
taunt_anchor.json staging. District trio tiles verified passable: (30,18)
existing + (32,18) + (32,17); spec's candidate (31,20) is a WALL — corrected.
