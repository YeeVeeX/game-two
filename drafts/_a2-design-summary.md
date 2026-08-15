# A2 threat/pull economy — consolidated design summary (brainstorm output, 2026-08-11)

Status: threat-side decisions LOCKED via owner forks (two AskUserQuestion
batches + one refinement round). Economy-vision + human-tools sections OPEN
(council debate ktbbarae5 in flight; owner verdict pending). This file is the
design presentation for owner approval; the spec is written from it after the
last two calls close.

## Owner fork verdicts (locked)

| Fork | Verdict |
|---|---|
| Threat model | Priority targeting rules (Tibia-faithful, stateless) |
| Death cadence | Wipes rare+heavy; body attrition stays frequent |
| Corpse contest | Live corridor (no corpse-specific mechanic) |
| Depth | Minimal in-map gradient (data-level) |
| Lethality | Position pressure (engagement cap + followers) |
| Pull verb | Movement-based pulling (no new binding) |
| Attribution | A2 ships ALONE (dev call after owner "not sure"); D1b trigger pre-registered |
| Economy vision | INSCRIPTION WITHIN RITUAL (owner-locked; council synthesis; biology REJECTED) |
| Human counterplay tool | NONE in A2 (owner + unanimous council); Challenger beat pre-registered post-A2 |

## System design (threat side — all numbers in data/, zero constants in Ruby)

1. TARGETING (replaces nearest-only for humans). Evaluated at READABLE
   trigger moments, never per-tick randomness (Darklight learnability
   finding: predictable threat invites denser play):
   - Taunt hard lock stays absolute for its fuse (fun-verified; not eroded).
   - First-seen: a human keeps its initial target until an override fires.
   - Overrides: proximity pass-by (a closer pack body crosses within margin);
     lowest-HP switch (a pack body below pct within range); kit-hate (a
     data-tagged subset of existing rushers prefers the lobber — the
     "artillery-hater"; visible as a beeline, no new enemy kit).
2. POSITION PRESSURE. Two AI states: ENGAGED (attacks; soft cap ~8-12 in
   data) and PRESSURING (uncapped: follows, closes space, blocks escape
   routes, does NOT swing). Encirclement is the danger; per-hit damage stays
   bounded. Pressuring humans need a visible stance tell (render cue,
   capture-verifiable; fiction name pending — order form).
3. LEASH-WITH-NO-HEAL. Humans that lose contact for N seconds walk home via
   flow field KEEPING current HP (zone-flip = breather, never reset). Leash
   timer >> gate round-trip.
4. RESPAWN DISCIPLINE. Screen-block respawn: suppressed within radius/sight
   of the player; humans appear at designated spawn points, never walk into
   the last fight. Gate beachhead: small no-camp radius at arrival tiles
   unless the player attacks first. (Kills the measured gate meat-grinder.)
5. DEPTH GRADIENT. Spawn density + take richness scale with distance from
   the gate (per-band multipliers in zones data). Deeper = richer + denser.
6. MOVEMENT PULL. Aggro by line-of-sight/proximity (first-seen). Pull size =
   how deep you walk and what you let see you; you choose where to receive
   the fight. Emerges from 1+2 + aggro radius data; no new binding.
7. DEATH CADENCE TUNING. Wipes become escapable-therefore-fair (leash
   breathers, visible encirclement, bounded hits) => rarer; each wipe risks a
   larger carried pile organically (longer hunts, gradient). Attrition
   (3->2->1 spiral) stays as the moment-to-moment pressure; last-body-alive
   is the entrainment moment.
8. TANK-FIRST POSSESSION (bundled). Initial possessed body = blocker (pack
   order in data/balance/combat.json). Invalidates all 7 replay scripts —
   bundled here because A2 re-pilots everything anyway.

## Engineering notes

- Sim changes => FULL re-pilot of all 7 harness scripts (pilot protocol),
  then the 7-gate wall (determinism + critic) + perf smoke. Rule 2 blocking.
- New bus events registered when first used (non-negotiable 4); threat logic
  lives in src/game/ (AiController growth or a sibling), window.rb stays
  under the 300-line cap.
- New data: balance/threat.json (first_seen radius, override margins,
  lowhp pct, hate weights, engaged cap, pressure ring distance, leash
  seconds, beachhead radius, respawn block radius) + zones gradient bands.
- Vision checks: ADD ONLY (pressure-stance tell, gradient density read,
  leash walk-home legibility candidates); never weaken existing 31.

## Fun-verify (SIXTH) — pre-registered

Same 8 spec questions VERBATIM (unprimed), plus one addition: an
entrainment self-report ("did your body react — tense up, lean in — at any
moment? which?"). Routing pre-registered in the spec:
- Chore MOVED => A2 wins; next increment per scope debate (vision informs).
- Chore UNMOVED + threat FELT (contested recoveries, real danger) => D1b
  promotes automatically (owner pre-agreed pattern), shape per vision.
- Threat NOT FELT => A2 tuning iteration (threat texture, not presentation).

## Open sections (pending council + owner)

- ECONOMY VISION: biology rejected. Council evaluating: ritual/offering
  economy (Egyptian bible-native), war-materiel/territory, pack-capability,
  novel proposals. Owner picks direction; D1b design space follows it.
- HUMAN COUNTERPLAY TOOL: none-in-A2 vs challenger (taunt mirrored) vs
  fear-scatter. Council arguing scope + fairness; owner decides.
