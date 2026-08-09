# game-two — Ruby+Gosu grid ARPG (monster flip)

Claude is the **dev of record** (design calls are Claude's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

v3 (2026-08-09): grid world v2 fun-verified; direction locked = **monster flip** — play a pack
of 3 creatures hunting humans in a collapsing modern city. Current increment = **A0 =
possession core ONLY** (spec: `docs/superpowers/specs/2026-08-09-a0-possession-core-design.md`;
binding review law: `drafts/_design-review-reconciliation.md`).

**IN scope until A0 is fun-verified:**
- **Actor/controller refactor** (kills the Player/Enemy dichotomy; factions; combat reads
  the attacker's kit, never a `[:player]` path)
- **3 hardcoded creature kits** (blocker / striker / lobber — spec-speak names) + Tab
  possession swap + forced-swap on possessed death; wipe → nest respawn
- **Exhaust** (per-creature, frame-quantized, swap-inert, data-driven) replacing free-swing;
  **per-attacker hit cadence** replacing blanket 30f invuln; hitstop scoped to possessed body
- **Husk-grade ally AI** (no gambits), **Rushers only** (melee humans, per-creature flow fields)
- **Two zones**: nest (hub) + one city district; existing grid/tween/feel layer carried
- **Determinism**: seeded PRNG in sim, swap lane + seed in harness schema, byte-identical
  capture gate kept; carried vision-critique fixes (facing notch, hurt-flash, telegraph
  color, wall brightness, corpses, lunge)
- Placeholder audio hooks only (NO MIDI, NO procedural SFX — owner order)

**OUT of scope — goes to PARKING_LOT.md, never to code:**
gambit engine + hot-reload, Shooters (ranged humans), pull economy / aggro caps, nest
advance / district progression, plus everything already parked (procedural dungeons,
corpse-run, stamina, loot, XP/skills, dialogue, status effects, crafting, weather, co-op,
quests, shops, inventory, multiple weapons).
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
  (world_loop.json covers the full loop; captures verified byte-identical across runs)

## Controls

WASD / arrows = move · J / Space = attack · K / Shift = dodge · Esc = quit
