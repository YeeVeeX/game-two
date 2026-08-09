# A0/M2 — Kits + District Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans (inline). Steps use checkbox syntax.

**Goal:** Ship the rest of the approved A0 spec on top of fun-verified M1: three distinct kits
(Striker/Blocker/Lobber + tile projectile), Rushers, nest + district zones, 3-bar HUD +
exhaust pip, edge pips, carried critique fixes, district_hunt gate, perf smoke.

**Architecture:** Kits stay pure data (combat.json). Projectile = new tile-stepped sim object
owned by World, no friendly fire (Tibia-faithful), stops at walls and first hostile.
Knockback becomes ATTACKER-driven (kit identity: Blocker displaces, Striker doesn't).
Corpses = sim-side records rendered faded. Zones swap: nest (hub) + district; town/threketh
retire to `data/zones_retired/` (kept as reference, not loaded — World greps `zones/` keys).

**Tech Stack:** unchanged (Ruby 3.4.10, Gosu 1.4.6, minitest, Bedrock vision gate).

## Global Constraints

Same as M1 plan (PATH export, repo root anchoring, orchestrator cap, data-driven, registered
events, no mocks, tick-locked timebase, de-slop: player-visible strings are `# fiction-pending`
spec-speak — the world bible exists but integration is an owner call, PARKING_LOT).

---

### Task 1: Kit data v2 + attacker-driven knockback

**Files:** `data/balance/combat.json` (rewrite), `src/game/creature.rb` (take_hit signature),
`src/game/world.rb` (resolve_attacks passes attacker knockback), tests.

**Interfaces:**
- `[:pack][:members] = ["striker", "blocker", "lobber"]` (possessed starts striker).
- Kits: striker (hp 80, step 13f, dmg 25, exhaust 35f, arc "front1" = single facing tile,
  knockback 0, snappiest dodge), blocker (hp 160, step 19f, dmg 20, exhaust 60f, arc3,
  knockback 1, slow dodge), lobber (hp 60, step 16f, dmg 20, exhaust 60f, arc "projectile",
  range_tiles 6, projectile_frames_per_tile 4, no dodge? — keep dodge, slowest), rusher
  (human mook: hp 50, step 16f, aggro 12, dmg 12, windup 24f, exhaust 66f, ring,
  interrupt_on_hit false, respawn 300f, knockback 1), husk kit stays (retired zones reference).
- `Creature#take_hit(damage:, attacker:, knockback_tiles:, blocked:)` — knockback distance now
  a parameter (attacker's `[:attack][:knockback_tiles]`); `knockback_tiles_received` dies.
- New arc "front1": `attack_tiles` = `[front]` only. Arc "projectile": `attack_tiles` = `[]`.
- [ ] Data + code + update creature_test (knockback param; front1/projectile arcs) + run + commit.

### Task 2: Projectile (TDD)

**Files:** Create `src/game/projectile.rb`, `test/game/projectile_test.rb`; modify
`src/game/world.rb`, `src/game/controllers.rb`.

**Interfaces:**
- `Projectile.new(owner:, map:, tile:, dir:, damage:, range_tiles:, frames_per_tile:)` —
  readers `owner tile x y dir done?`. `tick(hostiles:)` → nil or the Creature hit.
  Tile-stepped: every frames_per_tile frames commits one tile; wall → done; hostile on the
  committed tile → return it (World applies take_hit), done. Linear pixel interp for draw.
  Passes through friendlies (no friendly fire).
- World: `@projectiles` per zone; `resolve_attacks` spawns on `arc == "projectile"`
  (attack_landed! same frame, dir = owner facing); `tick_projectiles` after resolve_attacks,
  creation order; cleared on zone change; `projectiles` reader for renderer/tests.
- AiController: `in_attack_range?` for projectile kits = 8-way aligned && dist <= range_tiles
  && wall-clear line (`view.line_clear?(from, to)` — World implements, walls only).
- Events: register `projectile_fired` when first used.
- [ ] Failing tests (flies straight, stops at wall, hits first hostile, passes over friendly,
  range cap, determinism) → implement → green → commit.

### Task 3: Zones — nest + district; retire town/threketh

**Files:** Create `data/zones/nest.json`, `data/zones/district.json`; move
`data/zones/{town,threketh}.json` → `data/zones_retired/`; `src/game/world.rb`
(HOME_ZONE = "nest"); rewrite geography-dependent tests.

**Interfaces:**
- nest: "The Nest" (fiction-pending), ~24x15, warm dark organic palette, WALLS BRIGHT
  (critique: 2-3x contrast), no enemies, pack_spawn row aligned with east gate → district.
- district: "District One" (fiction-pending), ~44x26 city blocks + streets, gray/concrete
  palette with bright walls, 5 rusher spawns, west gate → nest. Straight east walk from
  arrival reaches open street combat (tests + scripts depend on it).
- world_test: STEP = striker step_frames; enter_dungeon → enter_district; husk refs → rusher.
- [ ] Author zones + move files + retarget code/tests → `rake` green → commit.

### Task 4: Renderer v2 — kit identity, critique fixes, HUD, edge pips + corpses (sim)

**Files:** `src/app/renderer.rb` (rewrite), `src/game/world.rb` (corpse records),
`src/game/creature.rb` (nothing), tests for corpses.

**Interfaces:**
- Kit body colors: striker ember orange (M1 possessed), blocker deep rust/brown-orange,
  lobber pale amber; possessed = brightened + white ring (unchanged); allies dimmer.
- Facing notch: 6px darker rect on the facing edge of EVERY creature (critique fix).
- Attack lunge: draw offset only — windup: -3px opposite facing; active: +6px toward facing.
- Hurt-flash: pack flash = deep crimson (200,30,30), never white (critique). Human hurt stays
  light red. HURT_FLASH white constant dies.
- Telegraph: two-tone — red swell border + yellow core (static-frame distinct from gold gate).
- Corpses: World keeps per-zone `@corpses` (`{x:, y:, faction:, at_frame:}` capped 40/zone,
  fade over 600f then pruned); humans on death, pack members drawn dead-in-place from
  `pack.members` (dead? && world state :world). Renderer draws corpses under living.
- HUD: three stacked bars top-left (kit-colored, possessed bar wider + white edge +
  exhaust-ready pip square lighting when `exhaust_ready?`), dead members' bars dark.
- Edge pips: living off-viewport pack members → kit-colored 10px rect clamped to viewport
  border toward their world position.
- [ ] Corpse records TDD in world_test → renderer rewrite → `rake` green → live launch smoke
  → commit.

### Task 5: Harness — district_hunt.json + gate checks v2 + both gates PASS

**Files:** Create `harness/scripts/district_hunt.json`; rewrite `harness/scripts/world_loop.json`;
`git rm harness/scripts/possession_core.json` (subsumed); `harness/gate_checks.json` v2.

- district_hunt: possess all 3 (two scripted swaps), Lobber fires on-screen, forced swap,
  wipe, respawn in nest — captures pinned by scout run of EVENT log.
- world_loop: everyday regression in nest+district (walk, fight, one swap).
- gate_checks v2 adds: three kits visually distinct, projectile visible in flight, corpses
  persist in a post-kill frame, facing notch readable, 3-bar HUD + pip, telegraph≠gate.
  Keeps: actors_distinct, possessed_readable, no_render_garbage, wipe_reads, zones_distinct
  (nest vs district).
- [ ] Scout → pin → `rake gate` BOTH scripts PASS (blocking, iterate never weaken) → Read 2-3
  PNGs with own eyes → commit.

### Task 6: Perf smoke (review order 4)

**Files:** `Rakefile` (`perf` task), `CLAUDE.md` (commands).

- `rake perf`: headless sim, district headline scenario (enter district, 6600 ticks of
  pack-vs-rushers with projectiles), p50/p95/max per-tick ms, **abort if p95 >= 16.6** —
  measured on this machine, documented as machine-local.
- [ ] Implement → run (expect huge headroom; M1 measured p95 0.039ms) → commit.

### Task 7: Ship

- [ ] Full `rake` + both gates + `rake perf` (record numbers).
- [ ] Adversarial code-reviewer agent over `git diff main..HEAD`: projectile determinism +
  lifetime, corpse cap, zone retirement leaks, knockback param correctness, HUD reading dead
  bodies. Fix CONFIRMED findings, re-gate if sim changed.
- [ ] CHECKPOINT top section (measured numbers) → merge to main → owner report
  (what to feel-check: kit identities, Lobber possession, Rusher pressure, district).
