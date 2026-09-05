# WB-T6 — LDtk foundation wave (S0 normalizer + AfterSave importer · S2 world-graph lint · scriptable S1 defs ergonomics)

- Session: s130, Gabriel seat (fresh dev-of-record session), 2026-09-05. Start HEAD `ad9238f`.
- Spark: `tmp/wb-t6/spark.md` (hub-authored; owner approval verbatim in its §0). Class JUDGED.
- Ground truth cited, not re-derived: gamesmith `docs/ldtk-research-brief-2026-09-05.md` (git-blob md5 `be0289048b9a00b84265cdc2796d1285`), sections 0 / 2 / 3.1–3.3 / 3.7 (Builders row + Recommendation) / 3.8 / 4 / 6 / 7 read in full via the read tool; the 308-tip shelf (`2d35559a15f82f4216b724ef07ba6e78`) not opened.
- Fences honored: no `data/zones/**`, no `src/**`, no importer-semantics change, no builder change, no LDtk upgrade (pin 1.5.3), no Rule 2 visual move. `authoring/pilot.ldtk` edited by SCRIPT + normalizer only (defs, never levels).

## 0. Terms (defined once)

- **Canonical bytes** = the builders' byte-format pin: `(json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")` (`tools/build_tower_floor.py:83-88` refuses anything else).
- **Normalizer** = `tools/normalize_ldtk.py`: parse → re-dump as canonical bytes (values untouched by construction — it re-serializes, never edits).
- **AfterSave command** = an LDtk `customCommands` entry with `"when": "AfterSave"`; LDtk v1.5.3 runs it after every Ctrl+S via `ChildProcess.spawn(name, args, {cwd: <project dir>})` (CommandRunner.hx:77-93 per the brief) — split on spaces, no shell, cwd = `authoring/`.
- **Emission** = the zone JSON the importer writes (`tools/import_ldtk.rb`), never hand-edited (provenance pin `test/tools/pilot_authoring_test.rb`).
- **Floor delta** = `floor(to) − floor(here)` for a transition, floors being zone metadata (`floor`, default 0).

## 1. Rule 1 — risks and the chosen approach (written BEFORE building)

1. **LDtk's own tidy may change semantics, not just bytes.** A GUI save (the HUMAN STEP) can rewrite defaults, reorder keys, or add fields (appBuildId churn is expected). Detector: D6 — emit all 13 zones before ANY pilot.ldtk change (`tmp/ldtk_out.before`) and after every change; `diff -r` must be empty; the provenance test is the arbiter. Anything the importer reads changing after the GUI save = STOP and ask.
2. **Interpreter/PATH portability of the AfterSave command across two machines.** LDtk spawns without a shell, so the command's first token must be an executable name resolvable on the Windows PATH of the LDtk process (Explorer-launched → the USER/MACHINE PATH, not Git Bash's). On this machine `python` = `C:\Users\gabri\AppData\Local\Python\bin\python.exe` (3.14.2), `py` = the WindowsApps launcher. Choice: `python` (resolves here; the most plausible name on Junior's machine; `py` is Windows-only and a launcher, `python3` is the WindowsApps alias that may open the Store). The driver script itself prepends `C:\Ruby34-x64\bin` when it exists and otherwise relies on PATH, refusing NAMED when `ruby` cannot be found. JUNIOR.md records how he verifies (`where python` / `where ruby` in cmd).
3. **Lint findings on the live graph are mostly INTENDED or LEGACY design, not defects.** The floor-delta law is NEW today; the legacy hand-authored edges (camp/nest/slow_door at default floor 0) and the T5 world join (zone_7 ↔ low_quay) predate it. Approach: REPORT MODE FIRST, classify every row with the record it rests on, allowlist known rows with a reason, and let the test block only NEW violations (and stale allowlist entries).
4. (Found during orientation, changes the value claim, not the plan) `Game::Crossing.validated_arrivals` (`src/game/crossing.rb:24-43`) ALREADY enforces lint checks (1) `to` resolves and (2) `spawn` passable-in-target at every World boot (s31). The brief's gap statement ("neither the importer nor `check_passable!`") is literally true but the GAME does check it. The lint's contribution for (1)/(2) is authoring-time feedback (AfterSave, on `tmp/ldtk_out` + `data/zones`) before a boot; its NEW law is (3) floor delta; (4) reciprocity is informational.

Approach: D1 → D3 → D4 → D5, one-concern commits, hooks run the suite, push after each landed concern. The AfterSave driver (D2) rides D1's commit family since it is the normalizer's consumer.

## 2. Evidence (record-first: every box starts UNCHECKED; filled only from pasted output)

### D6 baseline (before any pilot.ldtk change)
- [x] `ruby tools/import_ldtk.rb authoring/pilot.ldtk --sidecars authoring --out tmp/ldtk_out.before` → rc=0, 13 files (`tmp/wb-t6/import_before.log`, 13 IMPORTED lines). `authoring/pilot.ldtk` md5 `88d52acc4da5572a1cbbf977ae2d2528` (worktree == `git show HEAD:` blob — the CRLF pin lives in the blob).

### D1 — tools/normalize_ldtk.py
- [x] `--check authoring/pilot.ldtk` → `canonical authoring/pilot.ldtk`, rc=0
- [x] fixture (`test/fixtures/spike_district.ldtk`, LDtk-resaved tabs+LF) → `NOT CANONICAL …: tab-indented (LDtk's own writer style; the pin is 2-space + CRLF) -- run: …`, rc=1 (one line)
- [x] normalize a COPY → `normalized`, md5 `69ccc83ac5354bfcdefa5ced2e7cac86`; second pass → `already canonical`, same md5 (idempotent); `--semantic-diff copy fixture` → `semantically equal`, rc=0; invalid input → `NORMALIZE REFUSED: …` rc=2
- [x] `test/tools/normalize_ldtk_test.rb`: 5 runs / 31 assertions / 0 failures (real `py -3.12`/`python` process; interpreter probe picks the first `--version` that exits 0 — the WindowsApps `python3` Store stub cannot be picked); skip path proven loud with CANDIDATES stubbed to a bogus name: `SKIP NormalizeLdtkTest: no Python interpreter found (tried: …)` ×5 on stderr
- [x] commit `b7c4d88` (hook suite 1425 runs / 0 failures), pushed

### D2 — tools/ldtk_aftersave.py + pilot.ldtk registration
- [x] driver run by hand via `cmd` from `authoring/` as cwd (`python ../tools/ldtk_aftersave.py ../authoring/pilot.ldtk`, the Windows PATH LDtk sees): `already canonical` · `import: exit 0` (13 IMPORTED) · `ok`, rc=0 (`tmp/wb-t6/aftersave_run1.log`; run2 after D3 adds `lint: exit 0`)
- [x] refusal paths: jsonVersion 1.4.0 copy → `normalized` then `IMPORT REFUSED: jsonVersion "1.4.0" != pinned "1.5.3"…` → `FAILED: import -- the window stays open so you can read why`, rc=1; `{ nope` → `NORMALIZE REFUSED: Expecting property name…`, rc=1
- [x] registration by script (`tmp/wb-t6/register_aftersave.py`, deleted at close): `customCommands` = `[{"command": "python ../tools/ldtk_aftersave.py ../authoring/pilot.ldtk", "when": "AfterSave"}]`, `backupOnSave` false→true, `backupLimit` 10, `backupRelPath` null→`"../tmp/ldtk-backups"`; `--check` canonical after; git diff = 8 insertions / 3 deletions, those keys only
- [x] D6 diff after this pilot.ldtk edit → `diff -r tmp/ldtk_out.before tmp/ldtk_out` empty
- [x] `test/tools/ldtk_aftersave_test.rb` (4 tests: registration pin · clean project → normalized + 13 emitted + exit 0 · importer refusal → exit 1 · unparseable → exit 1); with the normalizer file: 9 runs / 52 assertions / 0 failures
- [x] commit `80ee6b0` (hook suite 1429 / 0), pushed

### D3 — tools/lint_world_graph.rb + findings + allowlist + blocking test
- [x] report-mode run over `data/zones` (`ruby tools/lint_world_graph.rb --report`, `tmp/wb-t6/lint_report1.md`): `20 zones, 38 transitions — 14 hard finding(s) (0 allowlisted), 3 info, 14 NEW`; all 14 hard rows are check (3) floor-delta; checks (1)/(2) = 0 rows (agrees with boot law `Crossing.validated_arrivals`); table in §3 below
- [x] `authoring/world_graph_allowlist.json`: 14 rows, 6 `intended` + 8 `legacy`, each with reason + record; re-run → `14 allowlisted, 0 NEW, 0 stale`, rc=0; overlay run (`--zones data/zones --overlay tmp/ldtk_out`) identical
- [x] `test/tools/world_graph_lint_test.rb`: 11 runs / 101 assertions / 0 failures — live world blocks NEW + stale; (1)/(2) agree with boot; every `TRANSITION_TYPES` member has a delta row; synthetic graph fires target/spawn(wall)/spawn(bounds)/floor/return(D4 note); per-type delta law ±; loader refusal named; overlay replaces; CLI exit 0 / 1 (NEW row named) / 2 (unloadable)
- [x] commit `c35c44c` (hook suite 1440 / 0), pushed

### D4 — scriptable defs ergonomics on pilot.ldtk
- [x] one-off `tmp/wb-t6/defs_ergonomics.py` (deleted at close): `doc` on 5 entity defs + 15 field defs + 4 level fields; `regex` `/^[a-z][a-z0-9_]*$/g` on Transition.to / EnemySpawn.kind / Region.id; tags Station+Transition=`structure`, PackSpawn+EnemySpawn=`spawn`, Region=`region` (the Entities layer's pre-existing `excludedTags` `[triggerable, trigger]` do not collide); Entities `canSelectWhenInactive` true→false; Terrain `inactiveOpacity` 1→0.5; Station.opens `editorDisplayMode` NameAndValue→`PointStar` (same-zone target, the arrow is truthful; Transition.spawn stays NameAndValue — its cell lives in ANOTHER zone, an arrow would lie)
- [x] `--check` → canonical; git diff 45 insertions / 35 deletions, only the keys above (`git diff | grep -v doc` read in full)
- [x] D6: `ruby tools/import_ldtk.rb … --out tmp/ldtk_out.after` rc=0; `diff -r tmp/ldtk_out.before tmp/ldtk_out.after` EMPTY (13 zones); provenance test green inside the hook suite
- [x] commit `0455266` (hook suite 1440 / 0), pushed

### D5 — docs
- [x] `docs/MAP_EDITING.md` §3 floors bullet → LINT LAW; §4 pin line gains installer md5 + decline-updates; new §4.1 normalizer law · §4.2 AfterSave loop + backups · §4.3 ergonomics (+ what is NOT in the wave) · §4.4 `autoLayerTiles: null` builder rule
- [x] `docs/JUNIOR.md` pt-br section "Editar mapas no LDtk (WB-T6)": version pin + decline updates, the Ctrl+S loop, `where python` / `where ruby` checks, never text-edit, backups, hover docs
- [x] commit `8a6ea65` (docs + record + CLAIMED), pushed; review-fix commit `ee54fd6`; GUI-safety commit `771508d` (rebased over Junior's PREMIUM v22 `03259d0`/`1ac9e9e`, disjoint files), pushed

### HUMAN STEP — performed BY THE SESSION at the owner's word ("can you please perform those steps for me?"), GUI driven by `tmp/wb-t6/gui.ps1` (DPI-aware SetForegroundWindow via AttachThreadInput + SendKeys/SetCursorPos; screenshots = Rule 2 artifacts, banked in `drafts/_wb-t6-gui/`)
- [x] LDtk 1.5.3 launched on `authoring/pilot.ldtk` (install `C:\Users\gabri\AppData\Local\Programs\ldtk\LDtk.exe`, log `Version: 1.5.3-64bits (build 473703)`); no update banner (1.5.3 is the latest release)
- [x] **Save 1 (09:24):** Ctrl+S → LDtk wrote the file → trust dialog (`01-trust-dialog.png`: "This project wants to execute the following command automatically: python ../tools/ldtk_aftersave.py ../authoring/pilot.ldtk") → clicked ALLOW → settings.cfg now `projectTrusts: [{iid 00000000-a237-…, trusted: true}]` → AfterSave ran: `normalized` · `IMPORT REFUSED: level low_quay: IntGrid value 0 at [23,3] has no tile type (0 = void …)` · `lint: skipped` · `FAILED: import` · `Terminated with code 1` — **window STAYED OPEN** (`02-aftersave-refusal-stays-open.png`, also the owner's own paste). The designed refusal path, proven live on the first real GUI save.
- [x] Full semantic diff HEAD vs save 1 (`tmp/wb-t6/semdiff_full.py`, 1,102 paths): **924 `intGridCsv` cells 9/10/12 → 0** (low_quay 710, ember_1 44, ember_2 109, ember_3 61) — LDtk zeroes IntGrid values the Terrain def does not declare (def declared 1–8; registry has 1–14; MUNDO VIVO builders wrote 9/10/12 without the T6b declaration law) · **176 `__tags`** (instances mirror the D4 def tags; importer ignores) · **1 nulled Point:** `levels[10]`=ember_3 `[1,15] → ember_2 spawn {cx:60, cy:14} → null` (out of ember_3's 56x32 bounds; the 4 other out-of-bounds spawns survived — only the tidied level lost its point). `03-oob-spawn-value-required.png` = zone_7's low_quay transition rendering `spawn = <Value required>` before any save.
- [x] Save 1 DISCARDED: LDtk closed, `git checkout -- authoring/pilot.ldtk` (md5 back to `4705994c…`), saved copy kept at `tmp/wb-t6/pilot_gui_save1.ldtk`
- [x] Fix by script (`tmp/wb-t6/declare_intgrid_values.py`, deleted at close): Terrain def gains values 9–14 (moss/rubble/bones/lava_deco/puddle/roots), sorted, unique; `--check` canonical; D6 `diff -r` EMPTY; new pin `test_every_used_intgrid_value_is_declared_in_the_terrain_def` fails on HEAD's file (`Expected [9, 10, 12] to be empty`) and passes on the fix → commit `771508d`, suite 1442 / 0, pushed
- [x] **Save 2 (09:36):** relaunch → title `pilot @ zone_7` (NOT `[UNSAVED]` — the load tidy changed nothing this time) → Ctrl+S → log: `Backing up … tmp/ldtk-backups/…_09-36-24` · `Loading HTML template commandRunner` · `Saved "pilot.ldtk"` → **no window after 7 s** (`05-after-clean-save-no-window.png`) → `tmp/ldtk_out/*.json` rewritten 09:36:25 = the importer ran green → `--check` canonical → **`authoring/pilot.ldtk` md5 `8013727dc4f20ef76639a83a80e082c3` == HEAD blob** (LDtk's writer + normalizer reproduced our bytes exactly; `--semantic-diff` HEAD vs saved: `semantically equal`) → D6 `diff -r tmp/ldtk_out.before tmp/ldtk_out` EMPTY (13/13)
- [x] Hover check: clicking the town_1 Region shows the entity doc in its panel; hovering the `id` field's `?` shows the field doc tooltip "unique per zone, bare rec-form (^[a-z][a-z0-9_]*$)" (`04-field-doc-tooltip.png`). No edit made (title never went `[UNSAVED]`); LDtk closed via Alt+F4 (`Exiting.` logged)
- [x] post-GUI commit: **none owed** — the saved file is byte-identical to HEAD (the strongest S0 outcome: "byte-identical file or a semantic-diff of zero", brief §4 S0)
- [ ] optional GUI icons (embedded LdtkIcons TilesetDef): NOT done — needs a TilesetDef the app must create; stays a GUI item for a peer's own session

### Fresh-eyes review (Rule 6)
- [ ] council verdict (model, tokens, cost, FINAL line) + reconciliation

### Close
- [x] CHECKPOINT entry (s130) · CLAIMED → none · RECEIPT mailed to gamesmith (`~/.pi/agent/mail/gamesmith/inbox/from-game-two-receipt-ldtk-brief-wb-t6.md`) · one-off scripts deleted · `git status` clean except tmp/

## 3. Findings table (D3 report mode) — filled from the lint's own output

Source: `ruby tools/lint_world_graph.rb --report` at `c35c44c` over `data/zones` (20 zones, 38 transitions). 14 hard rows, ALL check (3) floor-delta — checks (1) target and (2) arrival cell fired on zero rows, which agrees with the boot law (`Game::Crossing.validated_arrivals`, src/game/crossing.rb:24-43). 3 info rows (4) return: the district→district_two hole (one-way by D4) and the two harness fixtures' exits. Classification: **INTENDED** = a record shows the row is the design (no action); **LEGACY** = the row predates the floor-delta law and awaits a peers' decision (the v20 Lane F graph drawing — `drafts/_v20-foundation-20260828.md` L2); none is a plain DEFECT (no crash, no stuck player — (1)/(2) are clean). Fix paths for the LEGACY rows are all hand-authored zones (`camp`, `nest`, `slow_door` carry the default floor 0 while their neighbours got v20 floors): `floor` is zone metadata no sim/renderer reads today, so re-flooring is not player-visible, but re-TYPING a gate (stairs/hole) is a graph + Rule 2 move with canary exposure (`world_loop` traverses camp). Both peers see this table in the hub.

Full reasons per row: `authoring/world_graph_allowlist.json` (this table truncates them).

| # | sev | check | zone | at | -> to | finding | class | reason (allowlist) |
|---|---|---|---|---|---|---|---|---|
| 1 | hard | floor | basement_2 | [10, 1] | basement_2 | rope_spot: floor -1 -> -1 (delta +0, rope_spot expects +1) | INTENDED | intra-zone rope: the BASEMENT 2 vault loop (sealed door [6,3] -> [9,3], rope back [10,1] -> [5,3]) stays on one floor by construction; a rope insid... |
| 2 | hard | floor | camp | [19, 5] | district_two | gate: floor 0 -> -2 (delta -2, plain gate expects +0) | LEGACY | HUB 1's east door predates the v20 descent: lane A/D gave ZONE 2 floor -1 and ZONE 3 floor -2 while camp stays 0; the recorded descent MOUTH is cam... |
| 3 | hard | floor | district | [0, 13] | nest | gate: floor -1 -> 0 (delta +1, plain gate expects +0) | LEGACY | ZONE 1 (nest, hand-authored wilderness spawn ground) carries the default floor 0 while ZONE 2 was rethemed to floor -1 (lane A, T1); nest's floor w... |
| 4 | info | return | district | [40, 0] | district_two | no district_two -> district transition exists (hole: one-way by law D4) | info | — |
| 5 | hard | floor | district_two | [0, 22] | camp | gate: floor -2 -> 0 (delta +2, plain gate expects +0) | LEGACY | return half of HUB 1's east door (see camp [19,5]) — same Lane F decision |
| 6 | hard | floor | district_two | [42, 13] | slow_door | gate: floor -2 -> 0 (delta +2, plain gate expects +0) | LEGACY | ZONE 4 (slow_door, the moss vault, hand-authored) sits BETWEEN floors -2 (ZONE 3) and -3 (ZONE 5) in the descent but carries the default floor 0. F... |
| 7 | hard | floor | grass_fixture | [24, 2] | district | gate: floor 0 -> -1 (delta -1, plain gate expects +0) | INTENDED | harness fixture zone (inbound-inert law); its outbound gate exists so a wall script can exit, no floor semantics |
| 8 | info | return | grass_fixture | [24, 2] | district | no district -> grass_fixture transition exists | info | — |
| 9 | hard | floor | low_quay | [1, 18] | slow_door | gate: floor -3 -> 0 (delta +3, plain gate expects +0) | LEGACY | return half of ZONE 4 <-> ZONE 5 (see slow_door [7,1]) — same floor-metadata gap |
| 10 | hard | floor | low_quay | [24, 34] | zone_7 | gate: floor -3 -> 0 (delta +3, plain gate expects +0) | INTENDED | return half of the T5 world join (see zone_7 [1,14]); requires_defeats: 1 outbound, plain edge gate by design |
| 11 | hard | floor | nest | [29, 8] | district | gate: floor 0 -> -1 (delta -1, plain gate expects +0) | LEGACY | return half of ZONE 1 <-> ZONE 2 (see district [0,13]) — same floor-metadata gap |
| 12 | hard | floor | slow_door | [7, 7] | district_two | gate: floor 0 -> -2 (delta -2, plain gate expects +0) | LEGACY | return half of ZONE 3 <-> ZONE 4 (see district_two [42,13]) — same floor-metadata gap |
| 13 | hard | floor | slow_door | [7, 1] | low_quay | gate: floor 0 -> -3 (delta -3, plain gate expects +0) | LEGACY | ZONE 4 -> ZONE 5 (floor 0 -> -3 through a plain gate): same slow_door floor-metadata gap (see district_two [42,13]) |
| 14 | hard | floor | wall_fixture | [24, 6] | district | gate: floor 0 -> -1 (delta -1, plain gate expects +0) | INTENDED | harness fixture zone (v20 T5 second wall class); its outbound gate exists so a wall script can exit, no floor semantics |
| 15 | info | return | wall_fixture | [24, 6] | district | no district -> wall_fixture transition exists | info | — |
| 16 | hard | floor | zone_7 | [1, 14] | low_quay | gate: floor 0 -> -3 (delta -3, plain gate expects +0) | INTENDED | the T5 world join (s68): ZONE 7 <-> ZONE 5 is a plain edge gate by design (requires_defeats outbound from ZONE 5, return free); low_quay's floor -3... |
| 17 | hard | floor | zone_8 | [63, 19] | dungeon_1 | gate: floor 0 -> -1 (delta -1, plain gate expects +0) | INTENDED | s70 wire-in: the frontier rope way (dungeon_1 -> zone_8, rope_spot, requires_level 8) returns through a free v1 EDGE GATE by the recorded pattern —... |


## 4. Review + reconciliation (Rule 6 — a context that did not write it)

Two DeepSeek V3.2 consults via `council ask deepseek` (adversarial brief, full source inlined, split to fit the ~32K argv cap): **A** = normalizer + AfterSave driver + their tests (6,875 in / 1,689 out tokens); **B** = lint + lint test + findings table (8,200 in / 1,277 out). Cost ≈ $0.01 total (well under the $0.50 budget). Raw: `tmp/wb-t6/review_{a,b}.md`. Both returned **FINAL: BLOCK**; every charge re-verified below — none deleted, two produced code fixes, one produced test hardening.

| # | Charge (reviewer) | Re-verification | Outcome |
|---|---|---|---|
| A-Q1 | CRLF replace could hit a `\n` inside a string value | CONFIRMED by the reviewer and by a live probe: `json.dumps` escapes control chars as two-char `\n`, only structural newlines are replaced | no change |
| A-Q2 | `describe_drift` "tab-indented" could mislabel a file with tabs INSIDE strings | REFUTED live: `json.loads(b'{"a": "x\ty"}')` → `Invalid control character` — a raw tab byte never reaches `describe_drift` (strict parse rejects it first) | comment added in code |
| A-Q4 | labelled REFUTED, but the reviewer's own trace concludes every exit path is correct | re-traced: normalize fail→1 · import fail→1 (lint skipped) · import ok + lint fail→1 · all ok→0 · lint file absent→0 with a named "skipped" line | no change (verdict label inconsistent with its evidence) |
| A-Q5 | the no-`--out` test might write the repo's `tmp/ldtk_out` | REFUTED: normalize fails first, `main` returns before the importer step (reviewer reached the same conclusion) | no change |
| A-Q6 | `python` may be unreliable on the other machine; `py` might be safer | UNCERTAIN, agreed — recorded as risk 2; `py` is the WindowsApps launcher (absent on a python.org install without the launcher option; also a Store stub target), `python` is the name every install method provides. JUNIOR.md carries `where python` / `where ruby` as the pre-flight | no change; documented |
| A-Q7 | Unicode: LDtk might `\u`-escape or use another normalization → "silent corruption" | REFUTED for semantics (live: `\u00e9`/surrogate-pair input round-trips to identical code points; NFC/NFD are different code points = different data, not a formatting concern). **BUT the probe surfaced a REAL trap the charge grazed:** printing a non-ASCII value to a cp1252 Windows console raises `UnicodeEncodeError` — `--semantic-diff` printed differing values with `ensure_ascii=False` | **FIXED:** display snippets use `json.dumps(a)` (ASCII-escaped) + `sys.stdout.reconfigure(errors="backslashreplace")` in both tools; test pins it (`caf\u00e9` + an emoji in a differing value) |
| B-Q1 | `EXPECTED_DELTA.fetch(type)` could `KeyError` on a Symbol type that TileMap lets through | REFUTED: `symbolize_names: true` symbolizes KEYS only; `validate_transition_type!` (src/core/tile_map.rb:139-144) refuses any type not in the String set. Still, a KeyError stack trace is a worse failure than a named refusal | **HARDENED:** `fetch` block raises `Refusal` naming the zone/tile/type; CLI rescues it (exit 2) |
| B-Q3 | `x = args.shift or refuse.call` precedence | reviewer traced it: assignment happens, `nil or refuse` exits 2 — intended | no change |
| B-Q4 | a `\|` in a message could break the `--report` Markdown table | no registry glyph or zone name can carry `\|` today (regex + tiles.json), but cheap to make true by construction | **FIXED:** table cells escape `\|` |
| B-Q5 | the CLI "new violation" test's cell (`first.at.x + 1`) might be passable by coincidence | agreed (it was) | **HARDENED:** the synthetic edge sits on district's ARRIVAL cell into camp — passable by boot law, asserted not already a transition tile |
| B-Q6 | `instance_variable_get(:@zones)` in a test is brittle | agreed | **FIXED:** public `zone_names` reader |
| B-Q7 | does allowlisting every pre-existing row neuter the lint? | design opinion; the contract is "block NEW + block STALE" so the list can only shrink or grow consciously; the LEGACY rows are resolved when the Lane F graph drawing lands (retype/re-floor/remove) and each fixed row is removed from the list (the suite forces it) | recorded (§5) |
| B-Q8 | overlay-only zones judged before the copy; relative default paths when cwd ≠ root | overlay intent is exactly "the world as it WOULD be" (the data/zones-only suite test judges the live state); the cwd point was real for a peer running the CLI by hand | **FIXED:** CLI defaults are repo-rooted (`File.expand_path("..", __dir__)`); test `test_cli_defaults_are_repo_rooted` runs it from a tmpdir |

Net: 4 code fixes (console safety ×2 tools, `Refusal` on a missing delta law, repo-rooted defaults, `\|` escaping), 2 test hardenings, 1 new test; suite re-run after the fixes: normalizer+aftersave 9 runs / 54 assertions / 0 failures, lint+aftersave 21 runs / 159 assertions / 0 failures. The reviewer's two BLOCK reasons (A: `python` portability + Unicode; B: Symbol KeyError) were one UNCERTAIN-by-nature risk (documented) and two REFUTED-with-evidence charges whose neighbourhoods still yielded real fixes — the review paid for itself on the cp1252 trap alone.

## 5. Open items / follow-ons

1. **WB-T7 (candidate, importer + builders re-pin): cross-zone `spawn` GUI-safety.** LDtk treats a Point outside the SOURCE level as invalid (renders `<ERR: Invalid field value>`, cannot be re-entered with the picker, a level tidy nulls it — ember_3 hit live). Five live transitions are affected (zone_7 [1,14]→low_quay [24,33] · basement_1 [4,3]→zone_7 [26,4] · basement_2 [4,3]→zone_7 [35,4] · dungeon_1 [29,7]→zone_8 [62,18] · ember_3 [1,15]→ember_2 [60,14]). Options: `spawn` as an EntityRef to the return Transition with `allowOutOfLevelRef` (brief §3.5, one click pairs both ends) or a String `"x,y"`; emitted zone JSON stays byte-identical by construction; builders + fixture + importer `field_value` re-pin in one ticket. Until then: MAP_EDITING §4.5 law 2 (never touch those five in the GUI).
2. **Lane F graph drawing resolves the 8 LEGACY allowlist rows** (camp/nest/slow_door floors vs their v20 neighbours) — each fixed row must leave `authoring/world_graph_allowlist.json` (the suite forces it). Peers' decision; record it in the hub.
3. **Entity icons via the embedded `LdtkIcons` atlas** — GUI-only (needs a TilesetDef the app creates); any peer's GUI session; importer-neutral; run `--check` + D6 after.
4. **Junior's machine pre-flight** for the AfterSave command: `where python` / `where ruby` in cmd (JUNIOR.md); if `python` does not resolve on his PATH the command string needs a one-line change (`py` or an absolute path) — a defs-only pilot.ldtk edit by script.
5. **LDtk log is buffered until exit** — judge a live AfterSave by the runner window / file mtimes / `--check`, not by `ldtk.log` (it showed nothing until `Exiting.`).
6. ~~The `--semantic-diff` cap hid the 1-of-1,102 nulled Point~~ **DONE in-ticket:** `--semantic-diff` now collects every path and prints a `BY SHAPE` summary (count × path shape × first example) under the capped detail list — `924 x intGridCsv[*]` and `1 x fieldInstances[*].__value` read side by side; pinned by `test_semantic_diff_summary_is_uncapped`.

## 6. Definition of done — final state

- [x] `tools/normalize_ldtk.py` + tests (check / idempotent / semantic-diff + shape summary), suite green
- [x] `tools/ldtk_aftersave.py` + `customCommands` + `backupOnSave` in pilot.ldtk; **the AfterSave window seen printing + self-closing on a clean save AND staying open on a refusal** (session-driven GUI, screenshots banked)
- [x] `tools/lint_world_graph.rb` + findings table (17 rows, every hard row classified) + allowlist with reasons + blocking test for NEW violations (+ stale rows)
- [x] D4 defs edits landed; D6 proves 13/13 emissions byte-identical before/after every pilot.ldtk edit AND after the GUI save; provenance test green
- [x] `docs/MAP_EDITING.md` §3/§4.1–4.5 + `docs/JUNIOR.md` updated; this record complete with real hashes; CHECKPOINT entry; RECEIPT mailed
- [x] fresh-eyes review recorded (2 DeepSeek consults, reconciled); all pushes done; `git status` clean except tmp/
- BONUS (found by the loop itself, fixed in-ticket): Terrain def IntGrid declarations 9–14 + the pin test; the cross-zone `spawn` Point hazard recorded as WB-T7
