# Fresh-eyes review — a13e5bf (fence hardening + A4/A6 + 3 wall fixes)

## Verdict: WITH MINORS
The original fence bypasses are blocked in normal staged/base operation, but explicit-file mode still skips branch identity, policy-pattern analysis is not canonical, and the presentation changes retain code fallbacks/literals contrary to the stated data-only criterion.

## Suite · Canaries

- `bundle exec rake` (once) → **PASS**: `1486 runs, 87637 assertions, 0 failures, 0 errors, 0 skips`.
- `bundle exec ruby -Isrc -Itest test/tools/lane_guard_test.rb` → **PASS**: `7 runs, 159 assertions, 0 failures, 0 errors, 0 skips`.
- `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run`:
  - `world_loop | = ACTIVE bank? | YES`
  - `brasa2_run | = ACTIVE bank? | YES`
  - `floor3_run | = ACTIVE bank? | YES`

## Closure table B1..B7, A4, A6

| item | verdict | evidence |
|---|---|---|
| B1 self-modifiable brief | **CLOSED** | Brief is read through argv-form `git show <trust>:drafts/lanes/<lane>.md` (`tools/lane_guard.rb:116-119,140-146`), while actual `drafts/lanes/*.md` changes are classified POLICY before ownership (`:34,76-89`). Missing trusted brief returns rc 2 (`:140-145`; probes below). |
| B2 rename source unfenced | **CLOSED** | Diff uses `--name-status -z -M -C` (`tools/lane_guard.rb:156-160`); `changed_paths` takes both operands for every `R*`/`C*` status (`:92-107`). Spaces survive NUL parsing; `M/A/D/T/U` take one path. Test covers R100, M, D (`test/tools/lane_guard_test.rb:68-75`), though C/T/U and spaces remain unpinned. |
| B3 branch/SIM token | **PARTIAL** | Staged/base branch equality is enforced (`tools/lane_guard.rb:161-167`) and owned `src/game/**` requires exact lane/token equality (`:75-89`). However `--files` deliberately skips branch identity (`:25,161`), so the same CLI can print OK on `junior/premium-build`; token parsing accepts the first word of either a lane or human name (`:110-114`) with no namespace/schema validation. Current `SIM TOKEN: Gabriel ...` correctly refuses lane `s4-equipment`. |
| B4 BOARD handoff | **CLOSED** | Lane owns its receipt, not BOARD (`drafts/lanes/review.md:4-12`), and instructions route handoff/PATCH REQUEST there (`drafts/lanes/review.md:38-51`); BOARD states integrator-only (`drafts/lanes/BOARD.md:1-8`). |
| B5 fail-open CLI | **CLOSED** | Empty `--files`, missing refs/briefs, unknown options, and git failures produce rc 2 (`tools/lane_guard.rb:122-145,153-160,181-183`); `Open3.capture3` uses an argv vector (`:116-119`) and worked under Windows Ruby. |
| B6 test gaps | **PARTIAL** | Shared probes were expanded and shipped briefs are checked (`test/tools/lane_guard_test.rb:23-27,87-105`), but pairwise overlap is tested through one synthesized exemplar per pattern (`:99-104`), not pattern intersection/repository expansion; C/T/U, spaced paths, branch CLI, missing trusted ref/BOARD, and scalar schema are untested. |
| B7 ad-hoc YAML | **PARTIAL** | Real `YAML.safe_load`, BOM and CRLF support close the parser complaint (`tools/lane_guard.rb:37-50`; `test/tools/lane_guard_test.rb:32-38`). Schema remains permissive: `owns: src/x.rb` is silently coerced to `['src/x.rb']` by `Array(...)` (`:44-45`), and `branch` need not be a nonempty string. |
| A4 refused pickup | **CLOSED** | `false` from item pickup returns directly to station-only dispatch (`src/game/world.rb:489-491`; `src/game/loot.rb:46-52`), so corpse/rope code at `world.rb:493-507,522-525` cannot run. Test proves `:banked`, value transfer, retained floor item, and retained corpse load (`test/game/bag_test.rb:86-117`). Existing coin→station regression remains pinned (`test/game/world_test.rb:1224-1233`); no focused coin→item→station three-press test was found, but control flow remains coin (`world.rb:482-488`) then item (`:489-491`) then station (`:506-507`). |
| A6 bag defaults | **PARTIAL** | Grid layout is now strict (`src/app/bag_screen.rb:23-27`) and declared in `data/display.json:182`. The broader finding remains: panel arithmetic/colors still embed presentation values (`bag_screen.rb:29-38`) rather than drawing all presentation numbers from display data. |

## New findings

| # | sev | file:line | finding | failure mode | one-line fix |
|---|---|---|---|---|---|
| 1 | MINOR | `tools/lane_guard.rb:53-59,63-72` | `policy?` compares uncanonical strings and checks pattern-vs-policy in the wrong direction for general glob coverage. `drafts/l*/x.md` can cover a policy path yet returns false; `./drafts/lanes/x.md`, doubled separators and `receipts/../` also return false. | Today real git paths are canonical and `check` independently refuses concrete policy files, so probes refused; future broad owns/policy additions or non-git callers can make this brittle. | Canonicalize repo-relative paths (reject `.`/`..`/empty segments) and test whether an owns glob intersects any policy glob, not whether the policy glob matches the pattern text. |
| 2 | MINOR | `tools/lane_guard.rb:25,153-167` | `--files` bypasses branch checking by design. | On the checked-out non-lane branch, `review --files tmp/review_probe.md` returns OK, so using this advertised mode as a pre-commit substitute defeats identity fencing. | Make branch checking default in every mode; add an explicitly named test-only override if required. |
| 3 | MINOR | `tools/lane_guard.rb:41-50,110-114` | YAML/token schemas accept ambiguous scalar/string identities. | Scalar `owns`, missing/empty `branch`, or a lane named like a human can pass parsing; `SIM TOKEN: Gabriel (T1...)` yields holder `Gabriel` without distinguishing person from lane. | Require arrays of nonempty strings, exact `branch: lane/<lane>`, and a machine row such as `SIM LANE: <lane|NONE>` separate from human attribution. |
| 4 | MINOR | `src/app/fx.rb:263-267`; `src/app/minimap.rb:30-43,123-132`; `src/app/renderer.rb:1702-1716` | The three wall fixes are presentation-only and deterministic, but not “all numbers from display.json”: spark colors and minimap scale have code fallbacks; dot offsets/sizes and arrow `8` are literals. | Missing/malformed display rows silently preserve a second code authority, contrary to the requested strict data contract. | Use strict fetches for added rows and move the new dot/arrow sizing constants into `display.json`. |

The wall fixes do not write sim state: FX only records/render-subscribed presentation state and ages by `world.frame` (`src/app/fx.rb:37-45,102-146`); minimap reads map/body/camera state (`src/app/minimap.rb:91-132`); arrows read world/map/camera and draw (`src/app/renderer.rb:1685-1732`). No wall-clock or random source was introduced. Minimap is tick-free; arrows are a deterministic function of current sim state; FX uses `world.frame`.

## Probes run (command → rc/verdict)

- `ruby tools/lane_guard.rb review --trust HEAD --files tmp/review_probe.md` → **rc 0**, OK on the wrong branch (finding 2).
- `ruby tools/lane_guard.rb review --trust HEAD --files drafts/lanes/review.md` → **rc 1**, POLICY.
- `ruby tools/lane_guard.rb review --trust HEAD --files drafts/lanes/receipts/../review.md` → **rc 1**, OUTSIDE.
- `ruby tools/lane_guard.rb review --trust HEAD --files ./drafts/lanes/review.md` → **rc 1**, OUTSIDE.
- `ruby tools/lane_guard.rb review --trust HEAD --files drafts//lanes/review.md` → **rc 1**, OUTSIDE.
- `ruby tools/lane_guard.rb review --trust HEAD --files 'drafts/l*/review.md'` → **rc 1**, expanded by Git Bash to the concrete POLICY path.
- `ruby tools/lane_guard.rb s4-equipment --trust HEAD --files src/game/equipment.rb` → **rc 1**, SIM TOKEN holder is `Gabriel`.
- `ruby tools/lane_guard.rb review --trust HEAD --files` → **rc 2**, empty explicit list fails closed.
- `ruby tools/lane_guard.rb review --trust DOES_NOT_EXIST --files tmp/review_probe.md` → **rc 2**, bad ref fails closed.
- `ruby tools/lane_guard.rb review --trust <root-commit> --files tmp/review_probe.md` → **rc 2**, trusted ref lacking brief fails closed.
- `ruby tools/lane_guard.rb review --trust HEAD --bogus` → **rc 2**, unknown option fails closed.
- `ruby tools/lane_guard.rb review --trust HEAD --base HEAD` → **rc 1**, wrong branch refused.

Direct pure-function probes: `policy?('drafts/l*/x.md')`, `policy?('./drafts/lanes/x.md')`, `policy?('drafts//lanes/x.md')`, and `policy?('drafts/lanes/receipts/../s4-equipment.md')` all returned false; `parse_brief` accepted scalar `owns: src/x.rb`; synthetic `changed_paths` correctly returned both R100/C75 paths plus single T/U paths with spaces intact.

## Not verified

No Gosu window, replay runner, capture, gate, map, wall, or visual critic was run. Visual appearance/edge placement was code-reviewed only. No adversarial tracked rename/copy was created because the review was read-only; parsing was tested with synthetic NUL status data. The report is the only file written.
