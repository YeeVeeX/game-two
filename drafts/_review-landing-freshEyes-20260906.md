# Landing review — `junior/premium-build` @ 193e148 → main (a41ca0c) · fresh eyes, read-only · 2026-09-06

**Verdict: WITH MINORS** — no blocker. Two MAJORs are law/durability findings that need a one-line
decision each before or at landing (E4 chroma proxy; `Bag.from_save` vs the save churn law); the rest
are doc/tool accuracy fixes. Scope = 15 non-e3 commits in `0522608..HEAD`; e3-lane commits only
spot-checked at their integration seams (Q5).

## Evidence (run once, headless)
- `bundle exec rake` → `1520 runs, 89411 assertions, 0 failures, 0 errors, 0 skips` (108.7 s).
- `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run` → `= ACTIVE bank?` cells:
  world_loop `e0b1f38f` **YES** · brasa2_run `3fd04895` **YES** · floor3_run `648810ff` **YES**.
- `ruby tools/manifest_census.rb` → `CENSUS 44 scripts in 62s - 1 FAIL: toll_pocket`
  (toll_pocket.json last touched 3b0fb8c, 0 commits in origin/main..HEAD → pre-existing red, not this branch).
- `wc -l`: window.rb **274** (≤300) · world.rb **1798** (≤1800, untouched in range: `git diff 0522608..HEAD -- src/game/` = bag.rb only) · renderer.rb **2124** (no cap; +25 named debt in BOARD).
- Canary bank / EventLog / src/net / src/core: `git diff 0522608..HEAD --stat` empty.
- Working-tree `harness/pins.json` + `drafts/_gate-verdicts.log` ignored (wall running); committed pins.json = 4 pins
  (blink_arrival@5a14a63, basement_pocket@282041c, town_gates@d557f67, ledger_loop@d557f67), origin/main = `[]`.

## Findings

| sev | file:line | finding | law / failure mode | one-line fix |
|---|---|---|---|---|
| MAJOR | test/game/zone_identity_data_test.rb:30-46,72 | The "CHROMA" clause is not a chroma measure: Euclidean RGB distance includes the grey axis. Decomposing wall−floor into grey + orthogonal components: ember_1/2/3 rgbdist 51.6/46.3/41.4 but orthogonal chroma only **17.7/16.3/14.7** — BRASA passes on VALUE (spread 23–29) relabelled as chroma. Counterexample that passes: pure grey wall [124,124,124] vs floor [100,100,100] → spread 24, rgbdist 41.6, zero hue → "legible by chroma". | data law amended on a proxy that does not measure what it names; silently lowers the value floor 40→20 for any near-grey pair | Compute chroma orthogonal to luma (e.g. `dist - |Δgrey|·√3` or YCbCr Cb/Cr distance) with its own floor, OR record BRASA honestly as a third clause "low-key value 20–40 + lava/glow carriers" |
| MAJOR | src/game/bag.rb:110-126 · drafts/_s1s3-landing-plan-20260906.md:30-32 | `from_save` raises when contents no longer fit `slots` or an id left the catalog, and the plan routes ArgumentError → **refuse the record**. save_state.rb:308-345 pins the opposite law for every other tunable ("a curve/cap retune must never brick a save": level/xp/hp/provisions all CLAMP with a `warn`). Lowering `economy.json bag_slots` or retiring an item would brick every save with a full bag. | save churn law (P3) vs strict validator; contradiction lands with T1 | Decide once: either clamp-with-warn (drop overflow / unknown ids, `warn "save: dropped …"`) like provisions, or amend the churn law for `bag` in CLASSIFICATION with a reason |
| MINOR | harness/scripts/blink_arrival.json:10-11 | Manifest floors are NOT "half of one gate run's observed counts" (commit 809af9a / `_doc`): one run = zone_entered 2, human_retargeted 9, telegraph 3, attack_hit 3 (census ×2 = 4/18/6/6); floors 1/4/2/1 ≈ a quarter of the DOUBLE count the checker compares against. Same for basement_pocket (6/6/6/2 vs floors 4/4/4/1 — inconsistent ratios). | prose-number law; a floor that is ¼ of measured is a weak flip guard and the doc misstates the rule | Set floors = observed single-run count (== half of the double count) or state the real ratio in `_doc` |
| MINOR | harness/scripts/blink_arrival.json:7 | `_doc` cites `tmp/_blink_probe4.rb` — a scratch file not in the repo; the shipped probe is `tools/blink_probe.rb`. | dangling provenance | Replace with `ruby tools/blink_probe.rb 23,23 "right:30-44" 100` |
| MINOR | tools/manifest_census.rb:27-30 | Census skips every non-`world` scenario, but `menu_tour.json` (scenario `menu`) carries a manifest `{zone_entered 2, attack_hit 5, actor_died 1}` and MenuScene builds a real World (harness/scenes/menu_scene.rb:26-46). "44 scripts" = 42 judged + 2 skipped; the commit says "42 world scripts" — one manifest-bearing script is invisible to the census. | tool claims to be "the manifest half of the wall" but omits a manifest | Treat `menu` like `world` (same World+apply_start path) or print `SKIP (has manifest!)` loudly |
| MINOR | harness/gate_checks.json:370 (interact_prompt_reads) vs src/app/renderer.rb:356-372, src/game/world.rb:1318-1320 | Row promises the prompt shows where `World#interact` acts. `interact_verb` returns `"seal"` for a seal whose way is already breached, but `interact_seal` returns false there (line 1320) — prompt shows, H does nothing. Also a drop/item/corpse on a non-station tile IS an interact target (world.rb:482-506) and gets no prompt. Minor because the row's literal text (station types + rope spot) is what the critic reads; the "iff verb" claim in renderer.rb:349-352 overstates. | promise the code does not keep (edge) | Renderer comment: "iff a station/rope DISPATCH exists on the tile (not iff it succeeds)"; optionally `return nil if station[:type]=="seal" && world.breached?(zone, station[:opens])` |
| MINOR | src/app/minimap.rb:82-85 | Zone-image fallbacks `[40,36,32]`, `[120,120,120]`, `[30,60,90]` and station magenta `[200,90,220]` are literals while the two NEW colors (way open/locked) went to display.json. Pre-range (d2f242a) — noted because b4 touched the same function and left them. | data-driven (numbers in data/*.json) | Move to `minimap_*_rgb` knobs next time the file is open (display_knobs_test then guards them) |
| MINOR | drafts/lanes/BOARD.md, drafts/lanes/README.md, docs/JUNIOR.md (new §) | Process law text landed in Portuguese; AGENTS.md "Working language English". Not blocking (drafts/docs), but the fence's machine row + README are read by every seat's agent. | seat law | Keep machine rows/README in English; pt-br is fine for the JUNIOR.md peer section |
| NOTE | harness/pins.json (committed) | blink_arrival pin `commit: 5a14a63` predates the script's own commit 809af9a (recorded from a dirty tree). `rake pins` will flag STALE anyway; ledger only. | pin provenance | none required; the wall re-pins |

## Answers

**1. E4 amendment.** Principled-in-intent (spec §E4 line 641-644 explicitly allows "a RECORDED law amendment
for the buried-rock value structure" — TOWER), but the CHROMA clause is fitted in effect: record line 60-61 says
"40/40/20 = the v20 budget reused, not fitted" while the units differ (luma vs RGB-Euclidean) and the narrowest
zone ember_3 clears by 1.4 (41.4 vs 40) and 2.9 (22.9 vs 20). Euclidean RGB is **not** a sound chroma proxy: it
mixes the grey axis in; for BRASA the orthogonal (hue) component is 14.7–17.7, so the pair is legible by VALUE
alone at a spread (23–29) the v20 law refused. TOWER (dungeon_2/3/4) genuinely is hue-carried: orthogonal chroma
83–100, spread −25..−31. Orientation pin: closes the silent flip for the 17 listed zones (test:86-97 asserts sign
per name, and `ZONES.sort == DARK+LIGHT` guards the lists), but ZONES is a hand list — a NEW `data/zones/*.json`
is not pulled in (tile_registry_test/gate_checks_audit_test glob the dir; this test does not), so a new zone
enters no identity row until someone adds it. Illegible-yet-passing pair: **wall [124,124,124] / floor
[100,100,100]** (achromatic, spread 24, rgbdist 41.6) passes "by chroma". Second class: red vs grey at equal luma
(spread ≥20 required, so equal-luma is excluded, but spread 20 + hue ≈ TOWER under deuteranopia collapses to a
~ΔL 25 read — not verified, flagged).

**2. S1 landing prep.** Canonical form stable: `to_save` merges by id, sorts by id string, string keys, Integer
qty (bag.rb:100-103; test bag_test.rb:122-136 proves order/split-independence + JSON round-trip). Layout is
derived: `add!` fills partials first so `used` is a function of contents (from_save round-trip keeps `used` and
`digest_string`, test:143-147). Types match save_state.rb's string-key `fetch` style (no `symbolize_names`).
`@pinned` is not saved — acceptable (display state) but undocumented in the plan. **Too strict**: see MAJOR 2 —
`bag_slots` shrinking or a catalog id retiring refuses the record, contrary to save_state.rb:308-345's clamp law.
Per-player/per-pack fact (plan §"Per-player vs per-pack") is stated correctly against spec §T1 (bag is a
CHARACTER key, default `[]`, host record carries the pack bag in v22, guest `[]`); the plan's "write into the
HOST's record" matches spec line 156-157. Optional-key law honored (`record.fetch("bag", [])`).

**3. manifest_census vs manifest_check.** Yes for `world` scripts: gate = two `replay_runner` runs teed into one
log (Rakefile:132-133, run_wall.sh:34-36), `manifest_check.rb:22-25` counts `^EVENT (\w+) frame=` over that log
and asserts `count >= min`; census counts one headless run and asserts `count*2 >= min` (census:44). Equivalence
holds iff both runs are identical — they are: seed from the script (`raw.fetch(:seed, 0)` in both
replay_runner.rb:45 and census:35), same `Harness.apply_start`, same `expand_script`, same EventLog curated list,
`world.frame`-indexed input (census:41 mirrors replay_runner.rb:86-88). Draw path emits no events. Verified on
blink_arrival: census 4/18/6/6 vs the commit's "byte-equal to the gate log". No script with a non-reproducible
count found; the only non-world manifest (`menu_tour`) is skipped, not miscounted (MINOR above).

**4. Wall scripts.** blink_arrival: minimal (90 ticks, one held key, 9 captures incl. the 0029/0030 adjacent
pair + 3 decay + gone). `_doc` capture law is accurate: replay_runner.rb:86-91 saves `frame_%04d` with `@frame`
AFTER `tick` (0-based) — probe's 1-based f31 = capture 0030 ✓, flash 10/8/5/2/0 at 30/32/35/38/40 ✓. Floors:
NOT half-of-observed (MINOR). basement_pocket: re-author is minimal in delta (kept 6 old captures, added `up`
900-918 = one tile at 19 f/tile, `interact` 922, +2 captures); census confirms drop_picked_up=2 (1/run).
gate_checks_audit_test: blink_arrival starts dungeon_3 → read by `tower_floor_reads` (gate_scope.json:39);
basement_pocket starts basement_1 → allowlisted `unread_start_zones` (gate_scope.json:45). Suite green confirms.

**5. E3 gate rows.** `minimap_reads` (gate_checks.json:346): "OPEN gold / LOCKED (level, seal or boss fact) cold
grey, same law as the floor signage" — matches `Renderer.way_locked?` renderer.rb:398-402 (sealed&&!breached ‖
requires_defeats ‖ requires_level) used by both minimap.rb:59 and the floor draw renderer.rb:515 ✓.
`interact_prompt_reads` (:370): station types bank/altar/vat/seal + rope spot, none beside a station or on a totem
— matches `interact_verb` renderer.rb:356-363 and `interact_station`'s totem no-op world.rb:516 ✓. Over-promise
(edge): breached seal still prompts; drop/corpse pickups don't (MINOR).

**6. E5 renames.** Test-only + comments: `git diff 0522608..HEAD -- src/game/` touches only bag.rb;
telemetry.rb:367 `"TELEMETRY varekka engaged=…"` oracle line unchanged; readers
(dread_test.rb:158, v15_telemetry_test.rb:21, telemetry_test.rb:52, manifest_check_test.rb:64) unchanged.
`git grep -i varekka` outside drafts/docs: 72 hits @0522608 → 30 @HEAD; all removals are `face_varekka!`/
`varekka` helper names in challenger_test/dread_test, renderer.rb:437 comment, python comments. `vision_critic.py
"Threketh"` also gone. Remaining: frozen oracle, retired canary bank names, PARKING_LOT — as the commit states.

**7. Tools.** lane_guard.rb v3: paths canonicalized (`\`→`/`, `.`/`..` refused, canon:36-41); BOM+CRLF stripped
(:47); `-z` git output; no clock/rand; fail-closed rc 2. Verified: `policy?("drafts/lanes/done/x.md")`=true,
`policy?("drafts/lanes/receipts/../BOARD.md")`=true, `policy_path?("drafts/lanes/done/e3-presentation.md")`=true
→ the new `done/` retire step stays integrator-only, and the overlap test (lane_guard_test.rb:141-163) only
parses top-level briefs so retired briefs no longer block owns. Only lane path to a policy file: none found;
`--trust` defaults to `main` where briefs do not yet exist → GitError rc 2 (fail-closed; hooks must pass
`--trust junior/premium-build` as BOARD says). Case: `seg_match?` downcases the pattern only (:80) — conservative
(refuses more). boss_probe/blink_probe: deterministic (script seed, no clock), read `@blink_cooldown`/
`@attack_state` via `instance_variable_get` (authoring aids, acceptable); boss_probe hardcodes 960×540/32 camera
(probe-only). blink_probe `blink_frames` counts one blink per frame (two same-frame blinks would merge; cosmetic).

**8. T1 collision forecast.** `git diff --name-only origin/main..HEAD` (96 files) touches of T1's set: **src/game/
world.rb** (11 hunks: requires/attrs @6-32, interact @479-531, digests @1033, bus subs @1492/1581 — S2 loot
wiring), **test/game/save_state_test.rb** (CLASSIFICATION: `loot_rng_draws`, `bag` group, burn/interval fields,
`item_drop` group), **test/net/state_digest_test.rb** (FACT_KEYS +`loot_rng_draws`, BAG_FIELDS, groups list),
plus `src/game/loot.rb`, `data/balance/economy.json`. NOT touched: `save_state.rb`, `src/net/protocol.rb`,
`src/app/cli.rb`. Collision hot-spots for his merge: (a) world.rb:32 attr block if T1 adds `characters`; (b)
save_state_test.rb CLASSIFICATION when T1 retires `members`/`progression`/`home_zone` rows next to the new `bag`
row; (c) state_digest_test.rb FACT_KEYS line (he retires keys, this branch adds one); (d) world.rb 1798/1800 —
T1's `apply!` bridge may need lines in world.rb → extraction owed (Crossing precedent).

## Verified claims
Suite 1520/0 · canaries YES×3 · census 43/44 with toll_pocket pre-existing · line caps hold · canary bank/EventLog
/net/core untouched · E4 changed no data pixel (79b0465 = test + 2 drafts) · E5 = tests/comments only ·
display.json diff = e3 knobs + safe_chip_y 138 · lane fence policy covers `done/` · blink capture law math ·
census ≡ manifest_check for world scripts · minimap/prompt rows vs code.

## Not verified
Rule 2 vision verdicts for blink_arrival/basement_pocket/town_gates/ledger_loop (no window allowed; pins taken on
trust) · deuteranopia read of TOWER red-vs-grey · that `harness/pins.json` working-tree changes match committed
provenance · Gabriel's `t1-schema3` actual diff (branch not fetched here) · toll_pocket red root cause beyond the
note's "pack never fights".
