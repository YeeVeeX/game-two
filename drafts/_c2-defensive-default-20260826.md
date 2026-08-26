# C2 — ally defensive-default engage rule + flee co-tune (s80, foundation Lane 3 row 13)

**Ratified design (v19 foundation, RATIFIED-G + RATIFIED-J 2026-08-22):**
"Ally acquisition gates on PROVOCATION (what attacks the pack / what the
possessed engages), leash back to the possessed; `ally_flee_hp_pct`
co-tuned beside it. One re-session measures it (Junior = primary
witness)."

**Junior R3 verbatim it answers:** "a IA morre muito, fica correndo pra
dentro dos inimigos" (s1 body_deaths=28/wipes=9 · s2 20/6).

**Touchstone (reference wall):** the defensive companion default is the
genre-standard shape — WoW pet Defensive stance (engage what attacks
you or your master), Tibia summons (defend the summoner, never
initiate). Offensive-default companions read as suicidal in every
touchstone lineage; that is exactly the R3 complaint. KB shelf query
run s80 (`hub kb query --domain game-research`): no curated
companion-AI note — the NAMED SHELF GAP stands recorded for C3's spec
time (foundation law: spoke NOT dispatched now).

## The mechanism (before → after)

Before (offensive default): a free pack body targets
`nearest(hostiles)` gated only by `kit[:aggro_tiles]` — any human
inside 10 tiles gets charged, unprovoked. That branch shadows the
follow branch; "fica correndo pra dentro dos inimigos" is this line.

After (defensive default): the ACQUISITION class filters to PROVOKED
humans only. The bind classes are untouched: taunt-bind (a human
challenge on the ally — none exist in data today), anchor (victims of
the ally's own past challenge), and the mark (explicit player order)
still bypass both the filter and the range gate, exactly as today.
Nothing to engage → the existing follow-the-possessed branch (the
"leash back to the possessed" of the ratified row — already live,
now reachable).

## Provocation: one flag, one choke point, four stamps

`@pack_provoked` on the human Creature — mirrors `@beachhead_waived`
exactly (body-scoped bool, digest-joined, dies with the body; respawn
builds a NEW Creature via `add_human`, so an echo returns unprovoked
by construction).

**Set (all inside existing sites):**
1. `take_hit` human←pack → `provoke!` on self ("what the possessed
   engages"; every damage arc funnels here — melee/dash via
   `apply_action_hit`, projectiles via `tick_projectiles`, volleys via
   `volleys.rb:68` — verified s80).
2. `take_hit` pack←human → `attacker.provoke!` ("what attacks the
   pack"). Pack-wide by design: the foundation language is pack-scoped,
   and allies defending ANY pack body is the point.
3. `resolve_taunt_pulse` victims → provoked (a possessed challenge is
   an engage order — the pack picked this fight; without it the
   anchor-bound blocker fights alone while its packmates watch).
4. Challenger chant-start + `seize!` landing → provoked (seizure is
   the hardest aggression in data; provoking at chant START is what
   lets free allies help interrupt — the interrupt is the designed
   counterplay, and it must not be possessed-only).

**Clear:**
- `leash_home` past the linger gate → `clear_provocation!` (a human
  that disengaged and walks home is forgiven; re-aggression re-stamps
  at take_hit — "dispersed, not invulnerable" symmetry).
- Zone re-entry human loop (beside the existing `h.focus = nil`) →
  fresh slate when the pack returns, same law as focus.
- Death: free (new Creature).

**Deliberately NOT stamping:** human focus acquisition (a human
WALKING at the pack is not yet an attack — humans acquire by proximity,
so focus-as-provocation would collapse the defensive default back to
offensive at human-aggro radii). The first CONNECTED aggression stamps.
A dodged/iframed swing lands before the guard and does not stamp —
thin edge, accepted (AI allies never dodge; a possessed body's answer
is the player's call anyway).

## Scope pins

- **Seat-independent.** The engage rule is faction AI law (solo free
  allies suicide identically today); nothing in the ratified row
  seat-gates it. The flee threshold keeps its existing seats≥2 gate
  untouched (`world.rb` reads it from the coop block; seats=1 = no
  block = guard never evaluates — v18 decision 12 shape, not touched).
- **Human-side AI untouched.** `Aggro#assign_focus!` (humans acquiring
  pack bodies) is not this ticket; humans stay the aggressors.
- **Sim-only.** No visual surface rides this (no telegraph, no HUD
  delta) → no Rule 2 gate owed; 0 critic calls declared. Owed instead:
  suite via hooks, all three netplay gates (lockstep sim surface),
  `rake perf`.
- **No new event** (EventBus law: define when first consumed — no
  consumer exists; the digest carries the flag for desync forensics).
- **No save schema change** (humans are session-local, never persisted).
- **XP pacing awareness:** allies initiating less = marginally fewer
  ambient kills. The eighteenth ritual measures progression pacing
  wholesale; no data compensation now (one change per re-session).

## Flee co-tune: 0.35 → 0.5 (`data/balance/coop.json` seats=2)

The complaint is "morre muito" — the flee fires too late to save the
body. The window between the flee floor and death, measured in typical
tiered husk hits (dmg 15 base; basement +25%=18, dungeon +75%=26,
zone_8 +100%=30), pack leveled per the zone's own `requires_level`
gate (hp growth 6%/level):

| body (hp at gate level) | floor @0.35 | hits of runway | floor @0.5 | runway |
|---|---|---|---|---|
| lobber, dungeon L6 (78) | 27 | 1.04 | 39 | 1.5 |
| striker, dungeon L6 (104) | 36 | 1.4 | 52 | 2.0 |
| lobber, zone_8 L8 (84) | 29 | 0.97 | 42 | 1.4 |
| striker, zone_8 L8 (113) | 39 | 1.3 | 56 | 1.9 |
| blocker, dungeon L6 (208) | 72 | 2.8 | 104 | 4.0 |

At 0.35 the squishy bodies start fleeing INSIDE the one-hit kill
window at frontier tiers (lobber zone_8: 0.97 hits — it can be at
full flee-trigger hp and still die to the next connect). That is
mechanically the R3 complaint. 0.5 buys ~2 hits of escape runway for
the squishy bodies and is the legible round step ("half health =
disengage" — the B5 ladder-legibility precedent). Not higher: the
defensive default already halves exposure (allies only fight fights
the pack picked); pushing the floor past 0.5 turns allies into
followers that abandon provoked fights they should finish.

Composition note: the flee compare is transient Float on leveled
`max_hp` (lowhp_switch_pct precedent) — nothing scaled is stored; the
knob edit is data-only inside the existing seats=2 block.

## Verification plan

- New `test/game/provocation_test.rb` (real World, no mocks): core
  refusal (unprovoked-in-range → no swing, follow converges) ·
  human-hits-pack provokes · pack-hits-human provokes · selectivity
  (provoked-far beats unprovoked-near) · taunt-pulse provokes · chant
  + seize provoke · leash clears · zone re-entry clears · respawn
  returns unprovoked · seats=1 parity (rule applies, flee guard still
  seat-gated).
- `digest_fields` + `CREATURE_FIELDS` coverage pin (W1: sim state
  without digest membership is the watched desync-blindness risk);
  mutation sensitivity comes free from the schema-leaf sweep.
- Touched stagings: `coop_feel_test#flee_stage` (provokes its hostile
  — flee tests test FLEE, not acquisition), world_test mark-clear
  segment + adjacent-lobber staging (explicit provocation), keeping
  `test_ally_ai_fights_humans` UNTOUCHED as the integration proof that
  rusher-initiated aggression still produces ally kills under the
  defensive default.
- Netplay gates ×3 + `rake perf` + full suite via hooks.

## Session verdict (s80 close)

- Shipped: provocation law (creature.rb take_hit/taunt! stamps +
  flag/accessors/digest; controllers.rb provoked-only acquisition +
  leash forgiveness; world.rb chant/seize stamps + zone-enter clear —
  ~11 lines at existing choke points) · coop.json seats=2
  `ally_flee_hp_pct` 0.35 → 0.5 · 12-test `provocation_test.rb`.
- Suite: **1287/23104 0F** (was 1275; +12 provocation lanes) — 5
  staging repairs audited to mechanism (walk-era sticky focus ×4,
  release-geometry pin ×1), digest classification :session_only,
  digest coverage pin.
- Canary: 3 streams moved → versioned-bank protocol EXECUTED in full
  (`drafts/_c2-canary-rebank-20260826.md`): worktree-pinned old streams
  reproduce the ACTIVE bank exactly, prefix identity to each first
  effect, every divergent line classed, outgoing bank preserved as
  S73_HISTORY, new bank double-replay deterministic. burn_duel now ends
  pack_wiped under its fixed choreography — ritual watch item.
- Perf: PASS `p50=0.401ms p95=0.628ms` (tmp/s80_perf.log).
- Netplay gates: recorded in the s80 checkpoint entry (run at close).
- world.rb extraction judgment: **NOT owed** — 1742/1800; the touch is
  choke-point stamps only, the POLICY lives in controllers.rb (engage
  filter) + creature.rb (flag law). The Crossing material-touch bar
  (whole subsystem landing in world.rb) is not met.
