# v15.5 operating plan (harvested at goalcomp, 2026-08-15)

Scope contract: CLAUDE.md (owner-closed at the thirteenth debrief).
Verdict + routing verbatim: `drafts/_v15-fun-verify-20260815.md`.
Authoring doctrine (TAS, input traps): `drafts/_v15-pilot-progress.md`
+ memory `pilot-staging-traps` (10 traps now).

## (a) VAT in slow_door — data-only, but mind the replays

- `data/zones/slow_door.json` `stations: []` today. Add
  `{"type": "vat", "at": [3, 5]}`.
- Grid is 14x9; doors at [7,7] (->Keyward) and [7,1] (->low_quay);
  arrival spawns [7,6] and [7,2]; pillars at x=3-4 and x=9-10 on y=3.
  **[3,5] is off the x=7 door-to-door column every existing replay
  walks** — chosen so low_quay_run/varekka_duel trajectories cannot
  touch it. If a station BLOCKS its tile in this engine, verify no
  wall replay ever paths through [3,5] before committing (they
  shouldn't — both scripts go straight down/up x=7).
- Vat costs are existing economy keys (heal 2, regrow 12) — zero new
  balance constants.
- After the edit: full wall re-run (16 scripts). Determinism should
  hold everywhere (sim untouched if the tile is off-path); the
  slow_door_landing captures gain a green fixture — critic re-judges,
  fixtures_distinct check even benefits.
- Check if any test asserts slow_door stations empty (grep
  slow_door in test/) — none known.

## (b) ES human-facing-output pass — owner: "todos suenan falsos"

- Strings live in `data/strings/{en,es,pt-br}.json`. The pass targets
  ES ONLY this cycle (PT-BR is Junior's queued pass).
- MUST invoke the `human-facing-output` skill (owner invoked it by
  name at the thirteenth). Register: diegetic, terse, the fiction's
  voice — never translationese. Source material: the bible (New
  Kingdom Egypt corpus) — names come from INSIDE the fiction.
- Current ES lines the owner saw and rejected wholesale: "El Muelle
  Bajo", "UNO SE PLANTA", "LA CARNE ES LLAMADA", "EL PLAZO ESTA
  PAGADO" (+ zone banners, overlay verbs).
- **Owner ratifies EVERY replacement** (his P6 answer) — draft the
  candidates, present via AskUserQuestion in Spanish, apply only the
  ratified set.
- Wall comparability is SAFE: the harness pins locale=en (v13 gate
  law), so ES string changes cannot touch gate captures.
- Language critique is BLOCKING at ship (Rules 2/6).

## (c) moving_square check amendment — owner approved in principle

- Finding: synthetic render smoke (red square in void, no map/HUD by
  design) judged by world-conditioned checks; failing since >=v14,
  masked by the run_wall.sh `$?`-after-pipe bug (fixed: PIPESTATUS,
  tmp/run_wall.sh — UNTRACKED, re-fix if tmp/ is ever cleaned).
- Two candidate shapes (owner picks wording at ratification):
  1. Exemption clause on world-conditioned checks ("synthetic
     scenario frames are exempt") — touches gate_checks.json text
     (amendment, ADD-ONLY law respected via ratified rewording,
     precedent #14/#19/#42).
  2. Wall slot becomes determinism-only for moving_square
     (SKIP_CRITIC=1 in the runner, documented) — zero check edits
     but weakens the "no SKIP_CRITIC shippable pass" law; needs the
     owner to amend that law explicitly.
  Dev recommendation: shape 1.

## (d) FOURTEENTH blind ask

- Same protocol as the thirteenth (skeleton reusable:
  `drafts/_v15-fun-verify-skeleton.md` — update Qs: both oracle
  halves unchanged; drop keybind-functional Q (validated), keep
  strip-legibility as deferred; re-ask stationless-quay Q4).
- The telemetry arbiters: quay{entries,frames,deaths},
  varekka{engaged,chants,interrupted,seized}. Target state vs the
  thirteenth: frames >> 1137, chants > 0.

## Wall integrity notes (carry forward)

- run_wall.sh rc bug is FIXED in tmp/ but the pattern matters: NEVER
  trust `$?` after a pipe; use PIPESTATUS[0]; verdicts come from teed
  logs + drafts/_gate-verdicts.log.
- Critic INFRA flake pattern: in-rake critic leg sometimes fails
  (status 1) while standalone re-run PASSES — 2 confirmed
  reproductions (aoe_specials, low_quay_run). Retry standalone before
  believing a FAIL; a real FAIL reproduces (moving_square did, 2/2).

## Owner queue (unchanged + new)

- Nudge Junior to clone (STILL not cloned as of the thirteenth).
- Junior PT-BR pass + JUNIOR.md custom-keys section.
- Resolution scaling (owner deferred strip legibility to it) — parked,
  not v15.5.
