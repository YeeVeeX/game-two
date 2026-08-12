# game-two — Ruby+Gosu grid ARPG (monster flip)

Claude is the **dev of record** (design calls are Claude's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

v10 (2026-08-12): A2 SHIPPED (merge `e3759c3`, 8-gate wall green) and the
SIXTH fun-verify landed VALID the same day: **Q3 "bank now or push deeper" =
"It changed — real dilemma" — the chore MOVED on the sixth ask, first
positive in six. A2 WINS.** Threat felt end-to-end (box "Felt it — and ran",
run-back "In doubt at least once", breather "Real option, felt fair"); wipes
1/session (vs 6-8 baseline); one pile abandoned in the field. Remaining
negatives: Q8 banked still pure score, Q5 wipes weightless, Q6 retargets
"read as randomness", owner free-text "no healing → hunts end early →
repetitive". SCOPE DEBATE closed 2026-08-12 (owner forks via
AskUserQuestion): **v10 = D1b inscription + priced flesh; Q6 rider rides.**
Full verdict: `drafts/_a2-fun-verify-20260812.md`.

**IN scope — v10 promotes exactly ONE increment, the D1b economy (two
spends, one currency), plus its riders:**
- **Inscription (the meaning sink)**: spend banked to inscribe a body with a
  god-mark; on a wipe, inscribed bodies survive the vat, unmarked dissolve.
  Session-only persistence (restart persistence stays parked). Economy
  vision owner-locked 2026-08-11 (inscription-within-ritual, council
  synthesis; `drafts/_council-economy-verdict.md`); player-visible names
  come from the bible (fiction order form in the spec). Targets Q8 (sixth
  consecutive "banked wouldn't matter") + Q5 (wipes weightless).
- **Priced flesh (the recurring sink)**: spend banked at the nest to restore
  the pack's flesh. No in-field healing. Rationale (code fact + owner
  evidence, debate 2026-08-12): `Creature#revive!` is the sim's ONLY heal
  and fires ONLY on wipe-respawn → the free wipe was the de-facto heal and
  body-recovery button; inscription making wipes destructive REQUIRES the
  priced valve. Touchstone: Tibia supply finances (Gudii f38).
- **Q6 legibility rider**: retarget margin/threshold tuning
  (`proximity_switch_margin_tiles`, `lowhp_switch_pct` — data) + a brief
  why-they-turned cue (retarget-cause telemetry already carries the reason).
- **Bug bundle (rides any sim change, never standalone)**: held-Shift dodge
  locks movement (controllers.rb:33-37 — level-triggered dodge starves the
  walk branch) and a2_fired `deepest_band` converts at summary time (reads
  0 when quitting from the nest) → convert at kill time. Both invalidate
  all 8 replay streams — that is why they ride this increment.
- Design forks close BEFORE the spec (owner via AskUserQuestion); all
  numbers in `data/`.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
The **Challenger** (named human who taunts back): trigger condition MET +
RECORDED at the sixth verify (threat felt, entrainment flat) — promotion
stays the owner's explicit call, fairness ladder mandatory. Also parked:
restart persistence; quirks/history accumulation beyond the session;
practice fine + insurance (D2, blocked on skill-through-use); scavengers +
term-extension marks (D3); D1 term/grace retuning (margin-anchored 5400/2700
stand until measured `term_left/term` margins exist); A1 gambits, Shooters,
A3 nest advance; inventory grids, carry weight, rarity, new drop types; any
THIRD kit special or new binding; "The Nest" rename (post-bible, its own
increment — two owner complaints on record); plus everything already parked
(procedural dungeons, stamina, XP/skills, dialogue, status effects,
crafting, weather, co-op, quests, shops, multiple weapons).
**Nothing new starts until v10 is fun-verified by the owner (the SEVENTH
ask; Q8 is the headline question).**

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
