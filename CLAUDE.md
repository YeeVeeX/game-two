# game-two — Ruby+Gosu grid ARPG (monster flip)

Claude is the **dev of record** (design calls are Claude's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

v12 (2026-08-13): **v11 density/re-massing SHIPPED + WON the ninth blind
verify** (merge `946c979`, wall 9/9, perf p95 0.284ms). First spontaneous
positive on record — owner, unprompted, before any question: *"I am
starting to love the core loop of the gameplay"* — plus *"it is actually
good that the game is difficult, I like the current level of it"*
(difficulty pinned RIGHT). Groups kept coming, depth pull BIT, deep drops
READ richer, money EARNED, **entrainment MOVED after three flat reads**
(the Challenger's trigger did NOT confirm a fourth time). Residue is
tuning-sized: stale "somewhere between" (drifts eventually), nest trips
STILL too often (third regression — lever is elsewhere), one corpse-run
camp (fairness, NOT difficulty). Verdict + telemetry + routing verbatim:
`drafts/_v11-fun-verify-20260813.md`. SCOPE DEBATE closed 2026-08-13
(owner via AskUserQuestion, dev recommendation accepted): **v12 =
ARC/PURPOSE (A3 nest advance + bible fiction pass).**

**IN scope — v12 promotes exactly ONE increment, arc/purpose, plus its
routed riders:**
- **Arc/purpose (the increment)**: the session must feel like it advances
  toward something. Lead shape candidates: **A3 nest advance** + **bible
  fiction pass** (the world bible exists — `docs/lore/world-bible.md`;
  the spec's fiction order form has handles awaiting names). Shape TBD at
  brainstorm — design forks close BEFORE the spec, owner via
  AskUserQuestion. Oracle: the owner's wishlist words (2026-08-12) —
  "advance toward something, progress, leveling, equipment, new enemies
  and zones, lore, cities"; the tenth ask's headline = did the session
  feel like it was GOING somewhere.
- **Ninth-routed tuning riders (authorized by the routing table, data
  lanes):** density VALUES iteration for the eventual-drift dose
  (pocket_cap / join_radius / cadence); corpse_guard/scatter fairness
  values for the Q7 camp (the guard today binds respawn anchors only —
  live wanderers unguarded; fairness fix, NEVER a global softening —
  difficulty is pinned right); Q6 nest-trip economy lever investigation
  (measured `term_left/term`-style margins BEFORE any retune — third
  regression proved the lever is elsewhere).
- **Brainstorm/spec is the NEXT session's first act**; nothing lands in
  code before the spec's owner forks close.
- All numbers in `data/`; zero balance constants in Ruby.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
The **Challenger**: DECLINED a THIRD time at this debate and its
entrainment trigger did NOT confirm at the ninth (body reacted) — dossier
stands, weaker; promotion stays the owner's explicit call, fairness
ladder mandatory. **Tibia AoE-specials dossier** (2026-08-13 deep
research): clump-payoff special, challenge-retarget special, elemental
fields — density's player-side payoff tools, parked as v13+ candidates
(see PARKING_LOT). **Q7 retarget-cue redesign** stays parked
(presentation). **"The Nest" rename**: still its own increment, but the
v12 bible pass UNBLOCKS it — re-raise at the v13 debate. Also parked:
restart persistence; quirks/history accumulation; practice fine +
insurance (D2); scavengers + term-extension marks (D3); D1 term/grace
retuning (margin-anchored 5400/2700 stand); A1 gambits, Shooters;
inventory grids, carry weight, rarity, new drop types; any THIRD kit
special or new binding; video-critic harness leg + gamesmith fun-verify
assist; plus everything already parked (procedural dungeons, stamina,
XP/skills, dialogue, status effects, crafting, weather, co-op, quests,
shops, multiple weapons).
**Nothing new starts until v12 is fun-verified by the owner (the TENTH
ask; headline = did the session feel like it advanced toward
something).**

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
