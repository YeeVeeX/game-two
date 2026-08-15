# D0 spec — adversarial review reconciliation (2026-08-10)

Reviewer: code-reviewer agent (Fable lane), instructed to REJECT by verifying every
spec claim against the actual code. Verdict on draft: **REJECT — 2 HIGH / 1 MEDIUM /
2 LOW**, core architecture confirmed sound (determinism, ownership, tick ordering,
swap masking all verified TRUE against code). All findings folded into the spec and
plan same day. Dispositions:

## Finding 1 (HIGH) — vision-check hatch polarity breaks the 3 existing gates. ACCEPTED.

`rake gate` runs ONE shared checklist (`Rakefile` hardcodes `--checks
harness/gate_checks.json`) for every script, and the critic's default for a
not-demonstrated check is FAIL. The draft's three new checks used the fail-polarity
hatch ("mark pass=false with why='not exercised'"), which `world_loop`/`district_hunt`/
`specials_chain` can never satisfy (no interact lane) — the spec's own "all four
scripts vision-pass" gate was unsatisfiable as written. **Fold:** all three new checks
use the pass-true hatch (`specials_distinct` precedent); `loot_loop.json` is the script
that exercises them for real. Sub-item also folded: `loot_loop.json` must satisfy the
EXISTING fail-polarity checks, and `projectile_visible` doesn't fall out of the beats
(rushers are melee) — the script gains a required possessed-lobber shot beat.

## Finding 2 (HIGH) — the hue scan was false: the mark is TEAL, not magenta. ACCEPTED.

`MARK_GLYPH = Gosu::Color.new(255, 75, 235, 205)` = r75/g235/b205 = teal/green-cyan —
exactly the band the draft picked for drops (and the companion plan's DROP_CORE was
within Δ≈10/channel of it). The A0.5 docs said "magenta"; the CODE ships teal and
passed 17 vision checks — code is intent, doc error recorded in the spec. **Fold:**
drops move to the genuinely unclaimed **magenta/violet band**; full constants scan
recorded in the spec; `drops_read_as_pickups` adds the mark glyph to its distinctness
list.

## Finding 3 (MEDIUM) — merge-clock reset = immortal floor stash. ACCEPTED.

Reset-to-full + 5 s rusher respawn lets a camper refresh a pile forever (kill onto the
tile every ~6 s), and drops persist through wipes — a zero-risk stash that dominates
the carry wager D0 exists to measure. **Fold:** merge keeps the FIRST kill's clock
(amounts sum, clock never resets). Floor storage is now hard-bounded at one decay
window from the first kill. Plan test flipped to assert no-reset.

## Finding 4 (LOW) — gate-tile drops unreachable and unspecced. ACCEPTED (as decision).

Humans can die on a transition tile; the possessed resting there transitions the same
tick. **Fold:** spec records "gate-tile drops are accepted losses" — rare,
self-punishing for doorstep fights, no code special case. (Frame-perfect scripted
pickup remains possible and deterministic — controller runs before check_transition.)

## Finding 5 (LOW) — fade render can't derive the decay total. ACCEPTED.

The draft entity `{tile, amount, frames_left}` can't yield a fade fraction without an
owner backref (the `draw_impacts` trick) or a renderer balance read. **Fold:** entity
gains a fourth field `decay_frames:` carried per drop. (The plan already had it —
spec text brought in line.)

## Confirmed-true claims (no action; recorded so the impl review doesn't re-litigate)

EventBus strict-FIFO + fixed emit order → PRNG rolls deterministic; @rng has zero
consumers today. Hitstop branch + :nest_respawn branch both skip tick_world → decay
pauses under both. Nest-time-ticks-district-drops vs veil-pause is coherent (veil ≈
wipe grace B-X4). Pickup-then-death same tick: controller precedes resolution;
carried_lost includes the just-picked amount. Pack constructed once → banked wipe-safe
by construction. rebind touches only @walker → carried rides transitions. Deferred
rearm! runs before controller.tick on the new body → no ghost-fire window. Station
[12,8] passable, off the spawn→gate path, no auto-fire path exists. Fonts already in
byte-compared captures (banner precedent). HUD x≈332 clear. ScriptedInput passes
arbitrary symbols → zero core/input.rb changes. Telemetry events cover the D0-staging
contract. respawn_due_humans occupancy = actors only → drops can't block spawns.
window.rb 61+1 lines. A rendered digit is not a name → de-slop rule satisfied.
