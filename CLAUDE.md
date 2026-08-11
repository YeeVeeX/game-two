# game-two — Ruby+Gosu grid ARPG (monster flip)

Claude is the **dev of record** (design calls are Claude's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

v8 (2026-08-11): D1 corpse run SHIPPED (merge `95ae894`, all six gates green)
and fun-verified same day — the drama-alone experiment returned **NO**: settle
= "standing in line", run back = "in between" danger + "too long/tedious",
**"bank or push deeper" = "still a chore" (third ask)**, "banked, wouldn't
care", corpse clock never noticed, no convenience deaths. Telemetry: the system
FIRED (2 carrying deaths, 2 wipes, 2 recoveries, 0 losses). Routing
(pre-registered in the D1 spec): primary = **the pile lacks meaning** (Q4 is
the spec's D1b/ledger clause verbatim); secondary = **threat never contests the
corpse** (2/2 recoveries). Full verdict: `drafts/_d1-fun-verify-20260811.md`.
**Owner locked v8 (AskUserQuestion 2026-08-11): post-fight ledger now, A2
threat PRE-QUEUED** — if the ledger's fun-verify does not move the chore, A2
promotes AUTOMATICALLY (owner pre-authorized; no new scope debate — that
promotion supersedes the 2026-08-10 demotion when triggered).

**IN scope until the ledger is fun-verified — v8 promotes exactly ONE thing,
the post-fight ledger:**
- **Post-fight ledger**: make each fight's gains and losses legible and FELT at
  the moment they resolve (Tibia Hunt Analyser beat; gamesmith FR-024). The
  cheapest probe of "the pile lacks meaning." Shape, trigger moment, and
  presentation are spec decisions (dev of record); all numbers in `data/`.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
A2 threat/pull economy (**PRE-QUEUED — promotes automatically on a failed
ledger fun-verify**; shape notes in PARKING_LOT.md); body fees + vat re-growth
(D1b — its trigger did NOT fire: no banking collapse, no convenience deaths);
practice fine + insurance (D2, blocked on skill-through-use); scavengers +
term-extension marks (D3); D1 term/grace retuning (margin-anchored 5400/2700
stand until measured `term_left/term` margins exist — Q5 "never noticed" is a
recorded signal, not a license); A1 gambits, Shooters, A3 nest advance;
inventory grids, carry weight, rarity, new drop types, spending banked, restart
persistence; any THIRD kit special or new binding; plus everything already
parked (procedural dungeons, stamina, XP/skills, dialogue, status effects,
crafting, weather, co-op, quests, shops, multiple weapons).
**Nothing new starts until the current loop is fun-verified by the owner.**

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
  taunt_anchor.json = A0.6 taunt anchor; corpse_run.json = D1 corpse run)
- `rake gate SCRIPT=harness/scripts/<name>.json` — the BLOCKING Rule 2 gate: double replay +
  md5 compare + structured vision verdict (exit nonzero on any failure). `SKIP_CRITIC=1` runs
  the determinism half only (iteration aid, not a shippable pass).
- `rake perf` — perf smoke (machine-local): district scenario, aborts if p95 tick >= 16.6 ms.
- `rake pilot NAME=<n> SEED=<s>` — interactive pilot session: append commands
  (`printf 'cmd\n' >>`, NEVER Write) to `tmp/pilot/<n>/inbox.txt`, read `log.txt`; idle =
  frozen sim; `export` emits a standard replay script. Full protocol: harness/pilot.rb header.

## Controls

WASD / arrows = move · J / Space = attack · K / Shift = dodge · L / E = special ·
; / Q = mark · H / F = interact · Tab = swap possession · Esc = quit

Timebase: `Window#update` = exactly one sim tick (tick-locked; replays deterministic by tick
count). Under load the game slows rather than skips — the top-right overrun counter makes
that visible, so a sluggish playtest is a perf signal, not a balance signal.
