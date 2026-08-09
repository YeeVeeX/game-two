# Increment A design — dual adversarial review reconciliation (2026-08-09)

Reviewers: **Codex (GPT-5 Codex @ high, different vendor, via MCP)** and **Fable @ max (direct
agent, cross-examining Codex's verdicts against the code)**. Both returned REJECT-as-one-increment.
Design doc under review: docs/design-increment-a.html. This file is the surviving record — the
raw verdicts lived only in task outputs.

## Convergent verdicts (both reviewers, verified against code by me)

1. **"Possession swap is nearly free" — REFUTED.** World is structurally single-player: camera,
   flow field, transitions, death state machine, attack resolution (asymmetric player-vs-enemies,
   damage read from `[:player][:attack][:damage]` in World, not from the attacker), and the event
   vocabulary (`player_died`...) all assume one protagonist. Needs an actor/controller/faction
   refactor. Fable's sharpest addition: unpossessed pack members are neither Player nor Enemy —
   the dichotomy itself is the blocker.
2. **Scope — 3-4 increments in a trenchcoat.** (i) actor/possession core, (ii) gambit engine
   (verbs like `human_in_choke`/`guard_spitter` hide spatial classification + targeting + pathing),
   (iii) exhaust x3 kits, (iv) human AI + squad economy + district (+ nest re-homing). Predecessor
   died of exactly this.
3. **0.75s exhaust is a tuning hypothesis, not research.** Verified numbers: ~2s melee beat,
   ~2s aggressive / ~1s non-aggressive group exhaust, 1s ranged cadence. 0.75s = my derivative
   recommendation. Kiting dominance undeterminable without human step rate + projectile model.
4. **Possessed-death hole is load-bearing.** Wipe vs forced-swap vs revive determines the risk
   model, the World state-machine refactor, and whether ally preservation is the real health bar.
5. **Pull economy monotonically exploitable.** Infinite pull nodes + body-blocked queues +
   density-scaling AoE = biggest-blob-always-wins. My own team-hunt analysis recommended an 8-12
   aggro soft-cap + density costs; design dropped it.

## Where they DISAGREED (the signal)

- **Barrier exploit (Codex: "renamed, not fixed"; Fable: PARTIAL).** Fable: Brute-holds-the-choke
  is *faithfully Tibia* — the manual itself endorses body-blocking; the actual bug is the blanket
  30f post-hit invuln (combat.json:19), which collapses any synchronized volley to one hit and
  makes BOTH ranged pressure and density toothless. **Fix the invuln model, keep the Brute.**
- **Gambit editor gap (Codex: validation gap; Fable: PARTIAL).** Gap is real (DataStore loads
  once; iteration = quit/relaunch) but a ~20-line dev hot-reload keybind closes it, and the honest
  fun target for the first pack increment is "hunting WITH a pack on shipped default gambits,"
  not "programming the pack" — authorship is its own later increment.

## What Fable found that Codex missed

- **(a) Determinism/Rule 2 threats.** Tibia's exhaust is wall-clock (`OTSYS_TIME()`) — copying
  that pattern (or `Gosu.milliseconds` think ticks) kills byte-identical replays. Everything must
  be frame-quantized (think=60f, exhaust=45f). Tibia AI is RNG-saturated (dance step, chance-rolled
  attacks) — needs ONE seeded PRNG stream, deterministic actor order, seed recorded in replay
  script. Harness input schema must grow a possession lane with byte-identical regression kept.
- **(b) Swap landmines incl. an exploit.** Buffered inputs must be creature-owned or a buffered
  attack ghost-fires from the new body; level-triggered held keys apply to the new body next frame
  (held dodge burns the new body's cooldown); worst: **swap-cycling as exhaust-cancel** — 3 bodies
  with independent clocks = rotate possession on the beat for ~3x swing rate at one tile.
  Rule: exhaust + buffers creature-owned and swap-inert; post-swap inputs edge-triggered (re-press).
- **(c) The single-protagonist stack (biggest unnamed risk).** Hitstop freezes the WHOLE world off
  bus events — autonomous pack combat would make a permanent slideshow, or be weightless if
  excluded. Camera follows one body → gambit payoff resolves off-screen → Rule 2 can't verify
  what the viewport can't see. One-BFS-per-zone pathing inverts into per-target fields for many
  humans on no-YJIT Ruby. Feel, camera, verification, and pathing are ALL architecturally
  single-protagonist — deeper cut than "World has one @player".

## Design law that came out of this (binding for the spec)

1. **A0 = possession core ONLY**: actor/controller refactor, 3 hardcoded kits, Tab swap, ally AI
   at existing-husk grade (NO gambit engine), Rushers only, fixed spawns, one district.
   Fun-verify "being the pack" before "programming the pack". Gambits/Shooters/pull economy/nest
   advance = A1-A3, each behind its own fun-verify.
2. **Possessed death = forced-swap** to a survivor (with vulnerability beat); full wipe = death
   state → nest. Decided now; shapes the refactor.
3. **Determinism spec before any AI code**: frame-quantized ticks, seeded PRNG in the sim, seed in
   replay scripts, deterministic iteration order, possession lane in harness schema, existing
   byte-identical replay kept as permanent regression gate.
4. **Exhaust + input buffers creature-owned and swap-inert; edge-triggered post-swap.**
5. **Per-attacker hit cooldowns replace blanket 30f invuln; hitstop scoped to the possessed
   body's fights.** One change defangs: statue immunity, volley collapse, pull-economy monotony,
   and the world-freeze slideshow.

## Also standing (owner direction, same session)

- De-slop rule: no feature-names-as-fiction ("The Pack", "The Advancing Nest" rejected by owner).
  Names come from INSIDE the fiction. Slop test: "could this name ship in any other game
  unchanged?" → if yes, it's internal spec-speak only.
- Proposed grounding: the Kethral mythos the owner already built (Sondrekh wound, Kurmasi conlang,
  Kelvor/Grashk/Ashvorgravi/Drenthal ecology) — same world, other side of the wound. AWAITING
  OWNER CALL (alternative: new fiction from a new bible, same method).
- Reference wall (every idea cites a touchstone: Tibia footage/research, Kethral bible,
  Vlambeer juice — serves none → parking lot).
- Kethral V2's own rule, now enforced here: "every commit must change what the player sees,
  hears, or feels" — a system that can't be felt in a capture doesn't merge.
- Judge builds, not briefs: everything converges to playable build + captured frames.
