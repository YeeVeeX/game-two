# game-two — Ruby+Gosu grid ARPG (monster flip)

Claude is the **dev of record** (design calls are Claude's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

v11 (2026-08-12): v10 D1b SHIPPED + VALID (Q1 meaning moved, seventh
verify); v10.1 Q6 retune SHIPPED (merge `ba4e0ad`, wall 9/9+9/9) but the
EIGHTH fun-verify (blind) landed **NEGATIVE: Q6 still always-bank, depth
felt uniform, Q1 "money got easy" + Q5 "back to nest too often" both
regressed, Q7 still arbitrary, entrainment flat THIRD time** — the 3.5×
premium was earned but never attributed, and it was **REVERTED to 2.0 by
owner fork** (a recorded negative result: one number was not the lever).
Same session the owner diagnosed the real upstream problem, code-confirmed:
**density decay** — the opening pull masses all 15 district humans once;
1:1 respawns land at HOME spawn tiles (+300f, respawn_block 12) so steady
state is scattered singles, "too easy to clean up… boring and stale after
a few rounds, but the core system and combat feels good." SCOPE DEBATE
closed 2026-08-12 (owner forks via AskUserQuestion): **v11 = DENSITY /
RE-MASSING (hunting-ground pressure).** Full records:
`drafts/_q6-retune-fun-verify-20260812.md`, `drafts/_scope-debate-v11.md`.

**IN scope — v11 promotes exactly ONE increment, hunting-ground density,
plus its riders:**
- **Density / re-massing (the increment)**: after the opening pull, the
  district must keep offering GROUPED threat — respawn scheduling that
  re-masses (shape TBD at brainstorm: re-mass toward clusters, wave pulses,
  density floors per region — design forks close BEFORE the spec, owner via
  AskUserQuestion). Oracle: the owner's own words — a session must NOT get
  "boring and stale after a few rounds"; entrainment and Q6-depth re-read
  behind it. Touchstones: Tibia grounds stay dense (Gudii f83
  laps/respawn), density-as-consequence (consequence synthesis), A2 shape
  note "respawns walk back toward the last fight". This increment MAY touch
  the threat layer (it owns respawn) — the v10.1 "A2 untouched" freeze is
  lifted by this promotion, values still all in data/.
- **Q6 drop-legibility rider**: deep drops must READ as place (drop/pickup
  presentation) — rides as polish, never standalone; the eighth verify
  proved an unfelt premium degrades into inflation.
- **Brainstorm/spec is the NEXT session's first act** (per the debate
  close); nothing lands in code before the spec's owner forks close.
- All numbers in `data/`; zero balance constants in Ruby.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
The **Challenger** (named human who taunts back): DECLINED a SECOND time at
this debate with its trigger TRIPLE-confirmed (entrainment flat at sixth,
seventh, eighth) — dossier stands in `drafts/_scope-debate-v11.md`;
promotion stays the owner's explicit call, fairness ladder mandatory.
**The arc/purpose layer** (owner wishlist on record 2026-08-12: "advance
toward something, progress, leveling, equipment, new enemies and zones,
lore, cities") = the likely v12 debate — A3 nest advance + bible fiction
pass are its lead candidates; it waits for a dense field to give purpose
TO. **Q7 cue redesign** opens as its own parked presentation item (two
tuning passes exhausted; the cue itself misreads). Also parked: restart
persistence; quirks/history accumulation beyond the session; practice fine
+ insurance (D2, blocked on skill-through-use); scavengers +
term-extension marks (D3); D1 term/grace retuning (margin-anchored
5400/2700 stand until measured `term_left/term` margins exist); A1
gambits, Shooters; inventory grids, carry weight, rarity, new drop types;
any THIRD kit special or new binding; "The Nest" rename (post-bible, its
own increment — two owner complaints on record); video-critic harness leg
+ gamesmith fun-verify assist (owner ask, parked with dossier); plus
everything already parked (procedural dungeons, stamina, XP/skills,
dialogue, status effects, crafting, weather, co-op, quests, shops,
multiple weapons).
**Nothing new starts until v11 is fun-verified by the owner (the NINTH
ask; the headline question is the owner's own oracle: does a session stay
alive past "a few rounds", and did the field ever feel worth pushing
deeper into).**

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
