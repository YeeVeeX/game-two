# game-two — Ruby+Gosu grid ARPG (monster flip)

Claude is the **dev of record** (design calls are Claude's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

v15.5 (2026-08-15): **v15 BUILT + WALLED (16 scripts, determinism
16/16, zone-3 scripts landed, gap #41 closed) + THIRTEENTH verdict:
UNDER-EXERCISED, not lost.** Owner played 43 min, paid both seals,
34 fights — and lasted 19 SECONDS total across two Low Quay entries
(quay entries=2 frames=1137 deaths=2; varekka engaged=1 chants=0).
His P7+P8 named the same root the pilot's ~28 instrumented attempts
measured: **no healing at or before the quay = tax-wall**; every
headline read (P1 "otro distrito más", P2 "casi ni lo vi") is
downstream of that one fault. P6: ES strings "todos suenan falsos" —
owner invoked /human-facing-output. Three pilot-driven balance commits
RATIFIED at the debrief (kill-box `c77b4f2`, funnels `2f76956`,
**Varekka hunts the whole quay, aggro 10→45** `a8b28b1`). Verdict +
telemetry + routing verbatim: `drafts/_v15-fun-verify-20260815.md`.
v15.5 DEBATE CLOSED 2026-08-15 (owner via AskUserQuestion, dev
recommendation accepted): **v15.5 = MAKE v15 LIVABLE, then re-ask.**

**IN scope — v15.5 is a short cycle, three items + one amendment:**
- **(a) VAT in slow_door** (healing before the quay — the owner's
  literal ask; the quay itself stays STATIONLESS per fork 1).
  Data-only: `zones/slow_door.json` stations. Wall scripts re-run.
- **(b) Full ES human-facing-output pass** over names/stamps/banners
  with the bible (register: diegetic, terse, the fiction's voice —
  never translationese). Owner ratifies each replacement. Blocking at
  ship per Rules 2/6.
- **(c) FOURTEENTH blind ask** — both v15 oracle halves unchanged
  (Low Quay EARNED + Varekka SCARED), plus strip/stationless re-asks.
- **(d) moving_square check amendment** (formal wording; owner
  ratifies): synthetic render smoke exempt from world-conditioned
  checks OR determinism-only wall slot. Found via the run_wall.sh
  PIPESTATUS bug — it had been failing the critic since ≥v14, masked.
- P5 strip legibility: recorded, deferred by the owner to the
  resolution-scaling item (no dose now).
- All numbers in `data/`; zero balance constants in Ruby; checks
  ADD-ONLY from 49.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
**Multiplayer spike etapa 1** (v16 LEAD — starts AFTER the fourteenth;
Junior still hasn't cloned); zone-identity presentation dose (cannot
be judged from inside a meat grinder — fourteenth decides); the chest
fork (P4 unexercised); dossier legs A/C/E; everything long-parked.
**Nothing new starts until v15 is fun-verified livable (the FOURTEENTH
ask).**

## Previous scope contract (v15 — verify ran 2026-08-15, routed to v15.5)

v15 = ZONE 3 (The Low Quay) + THE CHALLENGER (Varekka) + CONFIGURABLE
KEYBINDS. Built + walled complete: `low_quay_run` (travel regression,
both seals in-run) + `varekka_duel` (duel regression: live ring, landed
seizure, chant_interrupted x2, THE TERM IS PAID, fat-drop pickup) via
the new `start.zone` harness param (`87ee19b`); TAS-style authoring
doctrine banked in memory + drafts/_v15-pilot-progress.md. THIRTEENTH
verdict: under-exercised (healing access), routed to v15.5 above. Spec:
`docs/superpowers/specs/2026-08-14-v15-zone3-challenger-keybinds-design.md`.

## Human-facing surfaces

- **Surfaces**: zone banners, wipe/victory lines, controls strip labels,
  overlay verb text, in-game locale strings (en/es/pt-br), error messages.
- **Audience**: hobbyist player (owner) + friend (Junior, PT-BR).
- **Register target**: converge to the fiction's register (diegetic, terse,
  New-Kingdom-Egypt-through-fantasy); never patronize.
- **Disclosure needs**: N/A (no AI-interaction surface in-game; single-
  player hobby project, not a commercial product).

Ship-gate: language critique (accuracy vs presentation, separate axes) is
blocking at ship per global Rules 2/6; checklist in the `human-facing-output`
skill.

## Previous scope contract (v14 — CLOSED 2026-08-14, WON the twelfth)

v14 (2026-08-14): legibility/onboarding — controls strip + respawn
telegraph + renames (First Vigil/Longrow/THE FLESH IS SPENT) + span_thirds
drift companion. Wall 14/14 (4 re-pilots vs W1 RNG shift; manifest law
caught 4 desyncs the critic missed 3 of). B VALIDATED (whirlwind fired
casts=2, "Sí, premio"), telegraph VALIDATED (268 shown, "Sí, planeé"),
strip VALIDATED ("Ayudó" + dual-keybind lane out). Lane e CLOSED (L0,
"ritmo ok"), drift CLOSED (span_thirds monotonic 102<113<134), guard-scope
CLOSED-VALIDATED (third clean), Challenger promoted to v15 (owner's
explicit call after 6 non-confirms). Spec:
`docs/superpowers/specs/2026-08-14-v14-legibility-design.md`.

## De-slop + comprobations (owner-set 2026-08-09)

- **Names come from INSIDE the fiction.** Slop test: could the name ship in another game
  unchanged? → then it is internal spec-speak only, never player-visible. The bible is being
  authored in a parallel session (New Kingdom Egypt corpus); the spec's "fiction order form"
  lists every handle awaiting a name. No fiction-flavored feature names in code or docs.
- **Reference wall:** every design idea cites a touchstone (Tibia research/footage in
  `drafts/`, the bible, Vlambeer juice). Serves none → PARKING_LOT.md.
- **Every commit changes what the player sees, hears, or feels.** A system that can't be
  felt in a capture doesn't merge.
- **Judge builds, not briefs.** Everything converges to a playable build + captured frames.

## Non-negotiables (from the Kethral post-mortem)

1. **Orchestrator cap:** `src/app/window.rb` ≤ ~300 lines. Systems talk via the event bus
   or they don't ship. (kethral/game.py hit 2,663 lines with a bus available.)
2. **Rule 2 is a blocking ship-gate:** every visual change is verified by scripted replay
   + frame capture + vision critique BEFORE it ships. Never eyeball loops.
3. **Data-driven:** all tunable values live in `data/**/*.json`. Zero balance constants in code.
4. **Events are registered:** `EventBus::EVENTS` whitelists known event symbols — emit/subscribe
   on an unknown symbol raises. Define events when first used, NOT upfront (Kethral defined
   ~80 upfront; breadth-thinking).
5. **Tests:** minitest, `rake` runs them. No mocks in integration tests — real files, real Gosu.

## Environment (verified live 2026-08-09)

- Ruby 3.4.10 at `C:\Ruby34-x64` — **not on Git Bash PATH by default**; use
  `export PATH="/c/Ruby34-x64/bin:$PATH"` per shell.
- **No YJIT**: RubyInstaller builds without it (needs rustc). PRISM interpreter only —
  accepted deviation, adequate at this scale. Revisit ONLY if profiling shows drops.
- Gosu 1.4.6. Capture API verified: `Gosu.render(w, h) { draws } → Gosu::Image#save(path)`
  works on this machine (produces real PNGs). `Gosu.render` needs a live GL context —
  run captures inside a real `Gosu::Window`, not headless.
- Old repo (READ-ONLY reference): `C:\Users\gabri\Documents.stale-20260413\coding_projects_main\Game On(e)`
- Gemfile.lock is committed; gosu pinned `= 1.4.6`. ⚠️ rubygems ships no prebuilt
  x64-mingw-ucrt binary for gosu 1.4.6 — it compiled from source here via the RubyInstaller
  devkit; a fresh machine needs MSYS2/devkit installed before `bundle install`.

## Layout

- `src/core/` — engine-agnostic: event bus, state stack, data store, input abstraction, tile map
- `src/game/` — the sim: world (zones/transitions), player, enemy, grid walker, flow field, camera, feel
- `src/app/` — Gosu-facing: window orchestrator (≤300 lines), rendering
- `data/` — all JSON configs (`balance/`, `zones/`, `display.json`)
- `harness/` — Rule 2 replay runner + input scripts
- `captures/` — frame captures (gitignored)
- `test/` — minitest; `rake` = run all

## Commands

- `rake` — run all tests
- `bin/play` (Git Bash) or `bin\play.cmd` (double-click / cmd) — launch the game
- `rake capture SCRIPT=harness/scripts/<name>.json` — deterministic replay + frame capture
  (world_loop.json = everyday regression loop; district_hunt.json = hunt regression;
  specials_chain.json = A0.5 specials chain; loot_loop.json = D0 loot loop;
  taunt_anchor.json = A0.6 taunt anchor; corpse_run.json = D1 corpse run;
  ledger_loop.json = fight-ledger beats)
- `rake gate SCRIPT=harness/scripts/<name>.json` — the BLOCKING Rule 2 gate: double replay +
  md5 compare + structured vision verdict (exit nonzero on any failure). `SKIP_CRITIC=1` runs
  the determinism half only (iteration aid, not a shippable pass).
- `rake perf` — perf smoke (machine-local): district scenario, aborts if p95 tick >= 16.6 ms.
- `rake pilot NAME=<n> SEED=<s>` — interactive pilot session: append commands
  (`printf 'cmd\n' >>`, NEVER Write) to `tmp/pilot/<n>/inbox.txt`, read `log.txt`; idle =
  frozen sim; `export` emits a standard replay script. Full protocol: harness/pilot.rb header.

## Enforcement (wired 2026-08-11 — script-enforced, not prompt-requested)

- **Git hooks gate commits and pushes**: `.git/hooks/pre-commit` and `pre-push` both run
  `bundle exec rake` (with the Ruby PATH baked in) — bundle exec pins the Gemfile.lock
  versions; unbundled `rake` drifted from the lock once (2026-08-11, caught by Codex review).
  A red suite blocks the commit — that's the point; fix the test, don't `--no-verify`.
  Hooks are untracked: to reinstall, each is 4 lines — `#!/bin/sh` +
  `PATH="/c/Ruby34-x64/bin:$PATH"` + `export PATH` + `exec bundle exec rake`.
- **swarmforge** (the quality-gauntlet CLI, `C:/Users/gabri/workspace/swarm-forge`) is
  configured for this repo via `swarmforge.toml`: `gauntlet` runs rake as its test stage,
  `tdd-check` knows `{stem}_test.rb`. Invoke with
  `PATH="/c/Users/gabri/workspace/swarm-forge/.venv/Scripts:$PATH" swarmforge <cmd> --repo .`
  — useful for `tdd-check src/game/<file>.rb` (WARN-only heuristic) and
  `handoff validate` when multi-agent sessions exchange handoff files.
- `rake gate` stays the Rule 2 blocking ship-gate (unchanged); hooks don't replace it.

## Controls

WASD / arrows = move · J / Space = attack · K / Shift = dodge · L / E = special ·
; / Q = mark · H / F = interact · Tab = swap possession · Esc = quit

Timebase: `Window#update` = exactly one sim tick (tick-locked; replays deterministic by tick
count). Under load the game slows rather than skips — the top-right overrun counter makes
that visible, so a sluggish playtest is a perf signal, not a balance signal.
