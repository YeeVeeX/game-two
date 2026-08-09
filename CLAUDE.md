# game-two — Ruby+Gosu rebuild of Kethral (2D action RPG)

Claude is the **dev of record** (design calls are Claude's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

v2 after the 2026-08-09 playtest: arena duel retired; grid world is the slice.

**IN scope until the slice is fun-verified:**
- **Tibia-style grid movement**: 32px tiles, tile-stepped with visual tween, body-blocking
- **Two hand-authored zones** (town = safe hub, Threketh = dungeon), gate-tile transitions,
  camera follow + zone banners
- Fight ONE enemy type (husk, flow-field chase), die, **respawn in town**
- One attack (3-tile arc) + dodge + feel (hitstop, shake, telegraph — validated fun, keep)
- Minimal HUD (health), Rule 2 harness
- Placeholder audio hooks only (NO MIDI, NO procedural SFX — owner order)

**OUT of scope — goes to PARKING_LOT.md, never to code:**
procedural/BSP dungeons, corpse-run gear drop, stamina, loot, XP/skills, dialogue, status
effects, crafting, weather, time-of-day, codex, bestiary, charms, co-op, NPC schedules,
quests, shops, inventory, multiple weapons, second enemy type, third zone.
**Nothing new starts until the current loop is fun-verified by the owner.**

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
  (world_loop.json covers the full loop; captures verified byte-identical across runs)

## Controls

WASD / arrows = move · J / Space = attack · K / Shift = dodge · Esc = quit
