# game-two — Ruby+Gosu grid ARPG (monster flip)

Claude is the **dev of record** (design calls are Claude's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

v13 (2026-08-14): **v12 arc/purpose SHIPPED + WON the tenth blind verify**
(merge `4703d3d`, wall 10/10, perf p95 0.337ms, suite 335/1386). Headline
verbatim: **"Advancing toward something"** — SECOND consecutive win.
Breach = "earned payoff, toll worth it"; Keyward = "arrived somewhere
new"; body reacted (Q8, fifth read). Telemetry: the owner paid BOTH seals
(incl. the 150 stretch), 240 Keyward kills, 29 inscriptions / 21 tributes
/ 634 banked spent. Residue ROUTED (not tuning-sized this time): trips
are MAINTENANCE-FORCED (q6_margins: pure=0 of 19 banks, dead 1.3 +
wounded 1.7 at bank — the lever is maintenance economics, not distance);
drift "Mixed" after dose iteration TWO → structural lever; corpse-run
camp at guard 10 → values lane EXHAUSTED, guard-scope un-parked. Q4
Second Vigil = "just a shorter walk" (recorded, no lane — rides the
headline). Verdict + telemetry + routing verbatim:
`drafts/_v12-fun-verify-20260813.md`. **c361ba3 check amendment RATIFIED
by the owner at this debrief** (self-gate wording stands; checks 42).
SCOPE DEBATE closed 2026-08-14 (owner via AskUserQuestion, all three dev
recommendations accepted): **v13 = TIBIA AOE SPECIALS (B+D).**

**IN scope — v13 promotes exactly ONE increment, the AoE-specials pair,
plus the three routed lanes:**
- **The increment — dossier legs B+D ONLY**
  (`drafts/_tibia-aoe-research-20260813.md`): **(B) clump-payoff
  special** — AoE whose efficiency scales with target count; the
  player-side cash-out of v11 density; and **(D) challenge-retarget
  special** — forced retarget of humans in radius to the possessed
  (`cause=challenged`), Tibia `exeta amp res`; directly answers the
  mobbed-while-carrying death pattern (owner's tenth session: 21
  carrying-deaths hauling 58-144 value). Kit placement, pip costs,
  bindings = design forks at brainstorm, owner closes BEFORE the spec.
  Oracle: the ELEVENTH ask's headline = did density become YOUR weapon —
  did the clump/challenge specials make the swarm feel like payoff.
- **Tenth-routed lanes (authorized by the routing table):**
  maintenance-economics lever (tribute/inscribe pricing + regrow cadence
  — DATA lane; q6_margins named it: trips are maintenance-forced);
  drift structural lever (DESIGN investigation with ninth+tenth data side
  by side — two value doses both partial-missed, no third blind dose);
  guard-scope live-wanderer avoidance (DESIGN item, un-parked by Q7 —
  fairness only, NEVER a global softening; difficulty stays pinned:
  the owner answered "nothing unfair" alongside the camping report).
- **Brainstorm/spec is the NEXT session's first act**; nothing lands in
  code before the spec's owner forks close. *(2026-08-14: the owner
  delegated fork closure mid-session — "continúa de manera autónoma";
  forks closed on dev recommendation, documented in the spec for owner
  veto at the eleventh debrief.)*
- **Owner-directive additions (2026-08-14, mid-session, IN scope by owner
  order):** (a) **i18n lane** — locales en/es/pt-br, authored translations
  (no Amazon Translate at ~8 strings), harness pins locale=en (gate
  comparability law); (b) **Junior onboarding doc** (`docs/JUNIOR.md`,
  PT-BR+EN — Junior has NO AWS account; everything he touches must be
  git-pull simple); (c) **branch model change**: `junior-tibia` = the
  collaborative line (work lands there, pushed regularly — supersedes
  "never push"); `main` = solo/backup line, untouched.
- All numbers in `data/`; zero balance constants in Ruby.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
**Multiplayer/shared play** (owner ask 2026-08-14, decision delegated to
dev): GameLift REJECTED (dedicated-server fleets, no Ruby SDK, overkill
for 2P co-op; Junior has no AWS). Chosen path = deterministic lockstep
over Tailscale, staged: (0) replay exchange via the repo, (1) v14
cross-machine determinism spike, (2) 2P possession co-op (each player
possesses a body of the SAME pack). v14 lead; ZERO netcode in v13.
The **Challenger**: FOURTH decline (Q8 body reacted again — density+arc
carry entrainment); dossier stands, weaker still; promotion stays the
owner's explicit call, fairness ladder mandatory. **Dossier legs A/C/E**
(elemental fields, resistance profiles, DoT kite-tax): parked — B+D ship
without the elemental data layer. **Zone 3 beyond the stair**: seal2
opened onto the sealed stair (the hook is LIVE and the owner reached it)
— v14 arc candidate. **"The Nest" rename**: unblocked by the bible pass,
not chosen at this debate — re-raise at the v14 debate. **Q7
retarget-cue redesign** stays parked (presentation). Also parked:
restart persistence; quirks/history accumulation; practice fine +
insurance (D2); scavengers + term-extension marks (D3); D1 term/grace
retuning; A1 gambits, Shooters; inventory grids, carry weight, rarity,
new drop types; video-critic harness leg + gamesmith fun-verify assist;
plus everything already parked (procedural dungeons, stamina, XP/skills,
dialogue, status effects, crafting, weather, co-op, quests, shops,
multiple weapons).
**Nothing new starts until v13 is fun-verified by the owner (the
ELEVENTH ask; headline = did density become your weapon).**

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
