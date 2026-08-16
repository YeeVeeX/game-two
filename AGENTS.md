# game-two — Ruby+Gosu grid ARPG (monster flip)

The dev agent is the **dev of record** (design calls are the dev's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

**One cycle lives in this file.** Previous cycles: `git log --follow -- AGENTS.md` +
specs in `docs/superpowers/specs/`; verdict/telemetry narratives live in
`drafts/`, never here.

**STANDING OWNER ORDER (2026-08-16) — NO LORE IN THIS REPO.** All lore,
fiction names, and creative writing are REMOVED from the project and repo
(preserved outside: `C:/Users/gabri/workspace/game-two-lore/`). Every
player-visible name/line is a generic placeholder: ZONE 1..5, HUB 1,
BOSS 1, player 1/2/3, TOLL PAID, BOSS 1 SPAWNED/DEFEATED, MARK LOST.
The v16 language lane is TERMINATED (no 3-probe, no grounded candidates,
no ES/PT authorship). This repo is mechanics + engine only; if creative
writing ever restarts, it restarts OUTSIDE this repo (from the archive
folder) — never here. Placeholder
changes are still Rule-2 visual changes (wall + recalibration apply).

v16 (2026-08-15, debate closed, owner ratified): **THE PRESENTATION/IDENTITY
CYCLE — give the simulation a face.** The FOURTEENTH verdict closed v15.5:
quay EARNED, tax-wall CLOSED, economy positive (first since D0), guard-scope
5th clean — and both failures are surface-family: Varekka fear = DESIGN
PROBLEM (fair + legible + affordable ≠ scary; seized=2, both tanked), ES
names false in situ (2nd consecutive; root cause = translationese
authorship). Verdict + routing: `drafts/_v15p5-fun-verify-20260815.md`.

**IN scope — five pieces, one comparability reset:**
- **(a) Resolution scaling** — render-only integer scaling; sim +
  capture pipeline untouched (wall stays byte-comparable). The substrate.
- **(b) Zone visual identity** — data-driven identity block per zone
  (palette / floor motif / light). A zone reads as a place without its
  banner.
- **(c) Stamp delivery** — court stamps land like stamps (scale-in /
  hold / dwell) at the new resolution. Delivery BEFORE re-wording.
- **(d) Varekka dread** — stakes knob (something non-refundable at risk
  while seized) + dread presentation (world dims during the chant). No
  audio (owner order stands). Forks close on dev recommendation; owner
  veto at the debrief (v13 precedent).
- **(e) Kill pop** — every kill lands visibly (the parked Vlambeer item).
- **Language lane** (owner-approved pipeline, runs AFTER the delivery
  dose): 3-probe register calibration → grounded candidates (attested
  notarial formulas + bible found-language, constrained mutation) →
  owner picks ON CAPTURES; re-word only lines the owner names.
- All palettes/numbers in `data/`; visual change = comparability reset →
  ONE full wall re-run + critic recalibration (Nest-rename law).

**Oracle (the FIFTEENTH ask):** does the Quay look like a place; did
Varekka scare you; do the stamps land.

**Seat:** dev of record = the main session (owner-declared 2026-08-15).
Working language: English (owner-ratified same day); player-facing ES/PT
only via the language pipeline — the dev never composes ES/PT alone.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
**Multiplayer etapa 1 → v17, behind TWO TRIGGERS (owner-ratified
2026-08-15):** (1) Junior demonstrably playing at etapa 0 (async replay
exchange — timezone-proof, `docs/JUNIOR.md`), (2) this cycle shipped.
**Trigger #1 evidence logged 2026-08-15:** Junior's FIRST session played
on his machine (pt-br, ~15.1k frames, 22 kills / 2 banks / 3
inscriptions; install clean; PT-BR read clean — zero lines named;
"divertida, quero mais"). Full telemetry + answers:
`drafts/_junior-first-session-20260815.md`. **Strict etapa-0 exchange
LOGGED same day** (`drafts/_junior-etapa0-20260815.md`): both canonical
replays reproduced on Junior's machine, per-frame md5 published for
owner-seat comparison — doubles as the multiplayer stage-1
cross-machine determinism spike. PT-BR post-edit pass ratified by
Junior (strip infinitives, A Rua Longa). Owner adjudicates the trigger
at the v17 debate.
Also out: new zones/enemies/systems beyond the dread-stakes knob; audio
(owner order); in-game rebind UI; the chest fork (Q4a validated it
closed); everything long-parked. **Nothing new starts until v16 is
fun-verified (the FIFTEENTH ask).**

## Human-facing surfaces

- **Surfaces**: zone banners, wipe/victory lines, controls strip labels,
  overlay verb text, in-game locale strings (en/es/pt-br), error messages.
- **Audience**: hobbyist player (owner) + friend (Junior, PT-BR).
- **Register target**: generic-videogame placeholder + functional UI
  (owner order 2026-08-16). No diegetic register, no fiction voice.
  Placeholder names are locale-invariant; only functional verbs translate.
- **Disclosure needs**: N/A (no AI-interaction surface in-game; single-
  player hobby project, not a commercial product).

Ship-gate: language critique (accuracy vs presentation, separate axes) is
blocking at ship per global Rules 2/6; checklist in the `human-facing-output`
skill.

**Authorship (superseded 2026-08-16): the language pipeline is
SUSPENDED with the lore program.** Player-facing text = placeholders +
dictionary-word functional labels only; anything beyond that is out of
scope for this repo. (Historical pipeline: see git history of this file.)

## De-slop + comprobations (owner-set 2026-08-09)

- **Names are placeholders (owner order 2026-08-16).** Player-visible names/lines are
  generic (ZONE N, BOSS 1, player N); internal identifiers are mechanical (striker,
  district, seal). No fiction names anywhere in code, data, or docs.
- **Reference wall:** every design idea cites a touchstone (Tibia research/footage in
  `drafts/`, Vlambeer juice). Serves none → PARKING_LOT.md.
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
- `rake capture SCRIPT=harness/scripts/<name>.json` — deterministic replay + frame capture.
  One script per regression surface lives in `harness/scripts/` (the wall); trust the
  directory, not an inline list here (an inline list went stale once). Canonical entry
  points: `world_loop.json` (everyday loop), `low_quay_run.json` + `varekka_duel.json`
  (v15 wall; zone-start scripts use the `start.zone` param).
- `harness/run_wall.sh [tag]` — full wall sweep: every script in `harness/scripts/`
  through gate + manifest, teed logs in `tmp/wall/`, nonzero exit if any script fails.
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
- **Process artifacts are tracked**: `drafts/` (verdicts, reviews, calibration history)
  lives in git — commit at cycle close. Only `drafts/_tibia-videos/` (media corpus) stays
  ignored. The wall runner is `harness/run_wall.sh`, never a tmp/ scratch copy.

## Controls

WASD / arrows = move · J / Space = attack · K / Shift = dodge · L / E = special ·
; / Q = mark · H / F = interact · Tab = swap possession · Esc = quit

Timebase: `Window#update` = exactly one sim tick (tick-locked; replays deterministic by tick
count). Under load the game slows rather than skips — the top-right overrun counter makes
that visible, so a sluggish playtest is a perf signal, not a balance signal.
