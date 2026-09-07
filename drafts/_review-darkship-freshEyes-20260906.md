# Fresh-eyes review — DARK-SHIP `c4a908d` + `b9f61f5` on `junior/premium-build` (vs `origin/main d4bb6e4`)

**Verdict: MERGEABLE (dark) WITH MINORS** — the OFF path is complete for the SIM (no S2/S3 *sim* change is reachable with the keys off; EVENT streams reproduce the receipt), digest is seat-deterministic, no Float can enter the record. One test the commit claims is DEAD (never runs), and the receipt's method line records a worktree run that main's seat-lease debt already flagged. Neither blocks a dark landing.

**Suite (run once, headless):** `1595 runs, 90468 assertions, 0 failures, 0 errors, 0 skips` RC=0.
**Canaries (`ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run`, keys OFF):** world_loop `f023e3dd` **YES** · brasa2_run `3fd04895` **YES** · floor3_run `648810ff` **YES** (the ON column differs at lines 11/18/4 — the switch is real).
**Census `--md5` spot check (4 scripts):** world_loop `f023e3dd6d5f…` · sustain_run `f704aaac…` · brasa1_run `7a6acbc8…` · vat_economy `747e2749…` — all four equal the receipt's per-script md5s (drafts/_darkship-receipt-20260906.md).

## Findings

| sev | file:line | finding | law / failure mode | one-line fix |
|---|---|---|---|---|
| MAJOR | test/game/status_test.rb:100-116 | `test_dark_ship_burn_off_means_the_aura_ticks_but_never_ignites` is defined AFTER the class's `end` (line 100) → top-level method, **never collected by Minitest** (`-v` lists 4 StatusTest runs, `-n <name>` = 0 runs). The commit message claims "tests assert … OFF path" for burn; only the drops OFF path (bag_test.rb:24-34) is actually tested. | Tests law (non-negotiable 5) / false confidence: the burn OFF gate at world.rb:1004 has no red-able test. | Move the `end` at line 100 below the method (indent inside the class); also `body.walker.teleport(*bearer.tile)` puts the body ON the bearer's tile — fine for Chebyshev 0 but use `tile[0]+1` like line 90 for symmetry. |
| MINOR | drafts/_darkship-receipt-20260906.md:4 | Method line says the main-side md5s were produced "in a detached worktree at origin/main". Gabriel's s138 (CHECKPOINT.md:16) already named "seat-lease vs worktree reviewers" as a debt; the receipt inherits it. The numbers themselves reproduce (4/4 spot-checked on the branch side), so it is a process note, not a proof gap. | Seat-lease law (AGENTS.md family block) | One line in the receipt naming the exception (or re-produce main's side via `git stash`-free `git show origin/main:` into a tmp dir next time). |
| MINOR | src/game/loot.rb:25-28, src/game/world.rb:193 | `load_bag!` is NOT gated by `items_enabled?`: a `characters[*].bag` record with contents is loaded even when OFF, and `use_cure_item` (world.rb:487 → loot.rb:71) would then consume an antidote on a poisoned body with the chip hidden (hud.rb:215) — an invisible sim effect. Unreachable from main's saves today (no schema-3 hop has shipped, `bag` default `[]`, character.rb:38) and from any fresh/canary world, so residual only for a save written while ON then flipped OFF. | Fallback law / dark = "plays like main" | Either gate `use_cure_item` on `items_enabled?` (one line, world.rb:487) or record the residual in the receipt ("OFF after ON is not a supported flip"). |
| MINOR | tools/manifest_census.rb:57 | `stream << l << "\n"` where `"\n"` is a literal newline inside the string (lines 57-58 as committed: `"` + newline + `"`). Works, but reads like a truncated line. | readability only (no law) | `stream << l << "\n"`. |
| NIT | data/balance/status.json:2-5 | `_doc` became an Array; world.rb:87 rejects `:_doc` by key so it never reaches `@status_cfg` — fine. | — | none |

## 1. Completeness of the OFF path (economy `item_drops_enabled=false`, status `burn.enabled=false`)

Gated directly (reads the key):
- `Loot#roll_item_drops` loot.rb:39 `return unless items_enabled?` → `FieldEconomy#spawn_item_drops` (field_economy.rb:131-146, emits `:item_dropped`) never runs; `@loot_rng.draws` stays 0 (world.rb:522 digest leaf constant).
- `World#tick_auras` world.rb:1004 `… if b && b.fetch(:enabled)` → `Creature#ignite!` (creature.rb:392) never runs. The instant `foe.burn!` (world.rb:1001) and `:aura_burn` emit (1005) are main's behaviour (main world.rb:1036).
- HUD BAG chip hud.rb:215 `world.items_enabled?`.
- Window bag toggle window.rb:228 `@world.items_enabled?` → `@renderer.bag_open` can never become true → renderer.rb:253 `BagScreen#draw` unreachable.

Unreachable because the trigger never fires (no direct gate):
- `Loot#pick_up_item` loot.rb:48-59 (called from interact.rb:21): `item_drops` is always empty → returns nil → `:item_picked_up` / `:bag_full` never emit → fx.rb:60-81 callouts inert; `refused_pickup_fallthrough` loot.rb:64 unreachable.
- `Loot#use_cure_item` loot.rb:71-84 (world.rb:487): fresh bag empty → the `.find` yields nil for every status → returns false → falls to `@stations.sustain` exactly as main (sustain.rb:96). Residual: a non-empty loaded bag (finding 3).
- `Creature#tick_burn` creature.rb:403 guarded by `burning?` (`@burn_ticks` starts 0, only `ignite!` raises it) → no-op; `statuses` creature.rb:438 returns only `:poison` (main behaviour); `cure!` only via `use_cure_item`.
- `FieldEconomy#tick_item_drops!` field_economy.rb:148 (world.rb:1439): iterates empty lists.
- renderer.rb:210 `draw_item_drops` iterates empty list; renderer.rb:1314 / hud.rb:126 burn flicker/badge need `burning?` → never.
- Digest: `bag` group (world.rb:528, bag.rb:95 → `slots=20, used=0, contents=""`) and `loot_rng_draws` 0 are constant extra leaves; no `item_drop.*` groups (field_economy.rb:214-221 iterate empty).

Still live / observable with keys OFF (all NON-sim): the `I`/`B` keys are consumed by `button_down` only when enabled (window.rb:228), so they fall to `super` as on main; `data/bindings.json:15` `"bag": ["I","B"]` is a new key in the handshake fingerprint (fingerprint.rb:41) together with `status.json` (new file), `drops.json`, `items.json`, `economy.json` — a branch seat cannot coop with a main seat (refused NAMED at HELLO). That is the intended behaviour, but it is the one player-visible difference: **mixed-tree coop refuses**. Strings `hud.bag`/`bag.*` (en.json:60-64) exist but are drawn nowhere when OFF. Nothing S2/S3 is observable in solo play with keys OFF.

## 2. EVENT-stream proof

`tools/manifest_census.rb --md5` (lines 47-57) hashes exactly the lines `Harness::EventLog.attach` yields = `Net::EventSerial.line(ev, frame, payload)` for the **curated** `EventLog::EVENTS` list (harness/event_log.rb:11-23), per world script, same seed/`apply_start`/`expand_script` as the gate. 42/42 equal is a strong proof that every curated moment (attack_hit, actor_died, drop_*, banked, provision_*, totem_pulse, zone_entered…) lands on the same frame with the same payload, i.e. the sim trajectory is identical wherever the wall looks.

What it does NOT catch (named residual):
- Events outside the curated list — `item_dropped`, `item_picked_up`, `bag_full`, `item_used`, `aura_burn`, `damage_dealt`, `blinked`, `attack_started`. For S2/S3 this is mitigated by reasoning (§1: emitters gated/unreachable) and indirectly: an un-gated DOT or item roll would move `damage_dealt`→hp→`actor_died` frames or `loot_rng_draws` and hence downstream curated lines.
- Digest-only differences: the extra `bag` group and `loot_rng_draws` leaf are by design not "equal to main" (Gabriel's correction); netplay between mixed trees is refused earlier by the fingerprint anyway.
- Presentation/telemetry: HUD layout, `TELEMETRY` lines, callouts, bag strings, `draw_item_drops` call, z-order changes elsewhere on the branch (controls_overlay.rb) — outside a sim-stream proof by construction; those are Rule-2 wall territory (the branch's wall #5 pins, not this commit).
- Non-world scenarios (`menu_tour`, `moving_square`) are skipped (census line 30-38) — stated in the receipt.
- The comparison ran at main `d4bb6e4`; any later main commit re-opens the question (receipt is sha-stamped, good).

## 3. Digest between two seats (keys OFF)

`World#digest_snapshot` world.rb:511-541: `bag` group = `Bag#digest_fields` bag.rb:95 (`slots` from economy.json, `used`, `contents` string) — both seats construct `Game::Bag.new` from the same `data` (loot.rb:33) and the same host record (world.rb:193; joiner receives the host's save) → identical. `item_drop.*` groups field_economy.rb:214-221 iterate `@item_drops` keys — empty on both. `loot_rng_draws` 0 both. Seat-local inputs: `@bag_codes` (window.rb:104) and `bag_open` (renderer.rb:196) live in App only; nothing from `display.json`/`bindings.json` enters `digest_snapshot` (grep: no `@display`/`bindings` reference in world.rb digest code). test/net/state_digest_test.rb:122-125 stages a floor item + bag item directly (bypassing the switch) and pins group order (`…character.N bag pack.N …`, :138 and :177) — so the group layout is tested regardless of the key. Deterministic by construction; the soak in Gabriel's s138 predates this commit (not re-run; see Not verified).

## 4. Float leaves

`git grep` over `data/balance/*.json`: 12 Float leaves — combat.json:766-769 (`shake_*`, feel only), coop.json:4-6 (scalars applied to Integers via rounding paths, balance-only), death.json:6 (`settle_pip_alpha`, presentation), threat.json:3/20/21/29 (AI pcts). data/items.json:16/24/26/28 (`crit_pct`, `resist`, `dodge_cooldown_pct` — catalog mods, S4-era, read by nothing in the record path); data/balance/drops.json probabilities (compared to `rng.rand`, field_economy.rb:136). None reaches `characters[<id>]`: the record projector is `Character#to_h` character.rb:99 (`bag` = `Bag#to_save` bag.rb:102-105 → `{"id"=>String,"qty"=>Integer}` only; `equipment`/`attributes` stay `{}` defaults, character.rb:38) and `SaveState.project` save_state.rb:77 syncs only that; `Character.canonical_refusal` character.rb:193-208 refuses any Float NAMED. `chill.step_frames_pct` readers: `git grep step_frames_pct` on HEAD and origin/main over src/test/tools → **0 hits** → dead, removal is behaviour-free. status.json now holds only Integers/Booleans/Strings.

## 5. Turning the keys ON

Pure data: `items_enabled?` = `@economy.fetch(:item_drops_enabled)` (loot.rb:23, strict — a missing key raises KeyError at first death/HUD draw, not silently OFF); burn = `b.fetch(:enabled)` world.rb:1004 (strict). No code default anywhere (grep `:enabled` → only these two + controllers.rb A3 unrelated). `Core::DataStore` (data_store.rb:26-39) parses every file once per instance with no global cache; the tests' `Core::DataStore.new(...)` + in-place mutation (bag_test.rb:18-22, status_test.rb:18-22) touches only that instance — `DATA` constants in other test files are separate instances → no cross-suite leak. ON path tests: bag_test.rb:84-130 (rolls + pickup + full-bag) and status_test.rb:84-99 (aura → DOT) pass with the fresh store (12 + 4 runs green). Caveat: the burn OFF test is dead (finding 1) — the ON/OFF pair is asymmetric.

## 6. T2a readiness

`wc -l src/game/world.rb` = **1728** (main 1782; Gabriel's note said 1726/1727 — prose-number law: current is 1728). Moved out of World on the branch: `Game::Interact` (interact.rb: `interact`, `interact_station`, `interact_rope`, `interact_seal`, 84 lines) and `Game::Loot` (loot.rb: catalog/bag/drop tables/`:loot` RNG, `pick_up_item`, `use_cure_item`, 86 lines); net world.rb diff vs main = +24/−78. T2a collision surface (spec §T2a: Party/Character/ZoneState carve of humans/corpses/projectiles/volleys/flow cache/`enter_zone` ivars; `Pack` → shim): the branch adds to those regions only `init_loot!` (world.rb:86), `@status_cfg` (87), `load_bag!` after `build_party` (193 — T2a's Character owning "its body/forms" must keep the bag hand-off), `item_drops`/`attr_reader :bag, :catalog` (233-234), the digest `bag` group placement after `@party.digest_groups` (528 — ZoneState must preserve group order pinned by state_digest_test.rb:138/177), `tick_item_drops!` inside `prune_caches` (1439 — per-zone state, a ZoneState candidate), `roll_item_drops` in the `:actor_died` handler (1529). None of these is in Pack/`assign_waiting_seats`/`handle_seat_death`/`respawn_pack`, so T2a's cut lines are additive-adjacent, not overlapping — provided T2a starts from this world.rb (the branch's Interact extraction already took the lines T2a would otherwise move).

## 7. Landing readiness

`git log --oneline origin/main..HEAD | wc -l` = **89**. `git merge-base HEAD origin/main` = `d4bb6e4b…` = `origin/main` → **fast-forward is possible** (Junior merged main at 35336a3). Files touched by both the branch (`origin/main...HEAD`) and Gabriel's TS/E1c range (`f609c31..origin/main`): `drafts/_gate-verdicts.log`, `harness/gate_checks.json`, `harness/pins.json` — all three already resolved in merge 35336a3 (its message: "pins.json union (his 64 + mine 126), nothing else collided"); no src/data/test intersection.

## Verified
- Suite once (1595/0/0), canaries ×3 YES, census `--md5` on 4 scripts = receipt, dead test (0 runs by name), `step_frames_pct` zero readers on both trees, ff-ability, file intersection, fingerprint covers `data/**` (fingerprint.rb:41), DataStore non-caching.

## Not verified
- The 38 remaining receipt md5s and the main-side run (would need a second tree; worktrees disallowed here).
- Two-seat soak with keys OFF at `b9f61f5` (no window/soak in this lane) — digest determinism argued from code + state_digest_test only.
- Rule 2 wall on the OFF build (HUD without the BAG chip is a Rule-2 visual change vs the branch's own pins — the wall #5 pins were taken WITH the chip; `rake pins` STALE expected for HUD reels). Not a main-regression (main never had the chip) but the branch's pins ledger will move.
- `rake perf` not run.
