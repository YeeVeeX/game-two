# Fresh-eyes review — b40ab7f (lane_guard v3 + strict display rows) · branch junior/premium-build

## Verdict: WITH MINORS
All 7 carried items (F1–F4, B3, B6, B7) are CLOSED for their stated scope; 20 adversarial `--files`/schema probes all refused (rc 1/2, none rc 0). Three residual MINORs remain in the fence (receipts-dir ownership not pinned to `<lane>.md`, `SIM LANE` regex `\s*` spans newlines, case-insensitive FS not normalized) and two NOTEs in tests. Nothing blocks merge.

## Suite · Canaries
- `bundle exec rake` (once) → `1487 runs, 88742 assertions, 0 failures, 0 errors, 0 skips`
- `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run`:
  - `world_loop | e0b1f38f | = ACTIVE bank? YES`
  - `brasa2_run | 3fd04895 | = ACTIVE bank? YES`
  - `floor3_run | 648810ff | = ACTIVE bank? YES`

## (1) Previous items → status

| item | status | evidence |
|---|---|---|
| F1 policy? not canonical / wrong direction | **CLOSED** | `tools/lane_guard.rb:39-44` `canon` (\→/, squeeze //, strip ./, any ""/./.. segment → nil); `:81-92` `policy?` is segment-wise glob intersection on the PATTERN (`seg_match?` :71-75). Verified: `drafts/l*/x.md`, `*/lanes/x.md`, `drafts/`, `**`, `drafts/lanes/receipts*`, `receipts/x.md/../../BOARD.md` all raise BadBrief at parse (`test/tools/lane_guard_test.rb:51-54` + probes below). Concrete files: `policy_path?` `:107-109` on canonical path. Residual: case (finding 3). |
| F2 `--files` skipped branch check | **CLOSED** | `:173,190-196` branch check runs before `case mode`, in every mode; `--no-branch-check` announced in OK line `:208`. Probe: `review --trust HEAD --files tmp/review_probe.md` → rc 1 `REFUSED - on branch "junior/premium-build"`. Not covered by a test (main() untested; NOTE 5). |
| F3 permissive YAML/token schema | **CLOSED** | `:36` LANE_NAME charset; `:53-54` `branch == "lane/<lane>"`; `:64-68` `list!` = non-empty Array of non-empty Strings (5/true/nil/Hash/scalar all raise — probes below); `:150-155` `sim_lane` reads only `SIM LANE:`; `drafts/lanes/BOARD.md:4` `SIM LANE: NONE`; test `:85-88` proves `SIM TOKEN: Gabriel` grants nothing. Residual: finding 2. |
| F4 display rows with code fallbacks | **CLOSED** | Changed lines: `src/app/fx.rb:264-268` four `fetch(:fx_spark_*)` no default; `src/app/minimap.rb:40-43` `fetch(:minimap_size/scale/scale_max)` no default; `:125-126,132,134` `fetch(:minimap_dot_extra)[:boss/:hostile/:pack/:you]`; `src/app/renderer.rb:1714` `fetch(:exit_arrow_gap)`. All declared `data/display.json:177-185`; DataStore symbolizes keys (`src/core/data_store.rb:31`) so `[:boss]` resolves. `grep "fetch(:.*, "` over the changed hunks → 0 hits. (Pre-existing `exit_arrows/exit_arrow_margin/exit_arrow_max` fallbacks at `renderer.rb:1669,1675,1684` untouched — outside this commit's claim.) |
| B3 branch / SIM token | **CLOSED** | = F2 + F3 above. |
| B6 test gaps | **CLOSED (claimed scope)** | `test/tools/lane_guard_test.rb:91-100` R100/C075/M/D/T/U + spaced paths; `:44-58` scalar/branch/lane/policy schema; `:111-132` overlap walks probes + every `git ls-files` path (1073 tracked). CLI branch check / missing-ref / missing-BOARD still untested (NOTE 5). |
| B7 ad-hoc YAML / coercion | **CLOSED** | `:64-68` no `Array()` coercion; scalar `owns:`/`never:` raise (`test :45`; probe "never scalar" → BadBrief). |

## (2) Adversarial probes (all `--trust HEAD --no-branch-check`, lane `review` unless noted; `set -f` so the shell did not expand globs)

| # | `--files` operand(s) | result |
|---|---|---|
| 1 | `drafts/lanes/receipts/` | rc 1 `POLICY: drafts/lanes/receipts` |
| 2 | `drafts/lanes/receipts` (no slash) | rc 1 `POLICY: drafts/lanes/receipts` |
| 3 | `drafts/lanes/receipts/**` | rc 1 `OUTSIDE` (literal `**` file name, not in owns) |
| 4 | `drafts/lane*/receipts/x.md` | rc 1 `OUTSIDE` |
| 5 | `**/BOARD.md` | rc 1 `POLICY: drafts/lanes/BOARD.md` (Git Bash expanded it; `match?("**/BOARD.md", …)` is false anyway) |
| 6 | `Drafts/Lanes/BOARD.md` · `DRAFTS/LANES/review.md` | rc 1 `OUTSIDE` (refused, but for the wrong reason — finding 3) |
| 7 | `drafts/lanes/receipts/../../../tmp/x` · `receipts/x.md/../../BOARD.md` | rc 1 `MALFORMED (./.. segment)` |
| 8 | `drafts\lanes\BOARD.md` · `' drafts/lanes/BOARD.md '` | rc 1 `POLICY: drafts/lanes/BOARD.md` |
| 9 | `drafts/lanes/receipts/.hidden.md` · `receipts/review.md receipts/other-lane.md` | rc 1 `OUTSIDE` on the non-owned path |
| 10 | `/c/…/game-two/drafts/lanes/BOARD.md` · `C:\…\drafts\lanes\BOARD.md` | rc 1 `OUTSIDE` (absolute path never matches owns) |
| 11 | lane `receipts` → `receipts --files drafts/lanes/receipts/x.md` | rc 2 `git show HEAD:drafts/lanes/receipts.md … does not exist` (fail closed; a brief `lane: receipts` would parse — its file IS policy, its receipt lands at `receipts/receipts.md`, no collision) |
| 12 | `--files` (empty) · `--files --base HEAD` | rc 2 · rc 1 (`--base`, `HEAD` treated as OUTSIDE paths — fail closed) |
| 13 | `review --trust HEAD --files tmp/review_probe.md` (branch check ON) | rc 1 wrong-branch REFUSED |

Schema probes via `parse_brief` (flow and block lists): `owns: [a.rb, 5]` / `[a.rb, yes]` / `[a.rb, null]` / `{a: b}` / `never: src/game/world.rb` (scalar) / `branch:` missing / `branch: lane/X` / `lane: Gabriel` → all BadBrief. Block list `- a.rb\n- b.rb` → OK. `owns: ["drafts/lanes/receipts*"]`, `["*/lanes/x.md"]` → BadBrief (POLICY). `owns: ["**/BOARD.md"]` → parses but `match?("**/BOARD.md","drafts/lanes/BOARD.md")` is false and `policy_path?` refuses the concrete file first (`check` order :118 before :122) — no bypass. Default `--trust main` → rc 2 on this machine (`main` has no `drafts/lanes/`), fail closed.

## Findings

| sev | file:line | finding | law / failure mode | one-line fix |
|---|---|---|---|---|
| MINOR | `tools/lane_guard.rb:57-60,91` | A brief may own `drafts/lanes/receipts/` or `drafts/lanes/receipts` (both parse OK — probed). That lane can then write EVERY lane's receipt (forge `RECEIPT:` handoffs the integrator folds into BOARD). Overlap test `:126` probes `receipts/probe`, so it does not collide with `receipts/<other>.md` owns. | Design §2.2 "lane owns ITS receipt"; requires an integrator-authored brief on the trusted ref, hence MINOR. | In `parse_brief`, require any owns under `RECEIPTS_DIR` to equal exactly `"#{RECEIPTS_DIR}/#{lane}.md"`. |
| MINOR | `tools/lane_guard.rb:152` | `/^SIM LANE:\s*(\S+)\s*$/m` — `\s*` crosses newlines: `"SIM LANE:\n\nreview\n"` → `"review"` (probed). A BOARD with an emptied row followed by any bare token silently grants SIM to that token; two rows → first wins (`"s4-equipment\nSIM LANE: NONE"` → `"s4-equipment"`). | Fence reads a machine row that must be unambiguous. | Use `/^SIM LANE:[ \t]*(\S+)[ \t]*$/` and refuse (rc 2) when `scan` yields ≠ 1 row. |
| MINOR | `tools/lane_guard.rb:39-44,87-89,107-109` | `core.ignorecase = true` here; canon/policy?/policy_path? are case-sensitive. `Drafts/Lanes/BOARD.md` is refused today only because no owns is uppercase; `owns: ["Drafts/**"]` parses (probed) and `match?("Drafts/**","Drafts/Lanes/x.md")` is true while `policy_path?` is false → a policy file would be classified inside the fence. Git normally records the tracked spelling, so exploit needs a brief typo + an odd `--files` spelling. | Canonical-path law; case-insensitive FS. | Compare `f.downcase` against POLICY_DIR/RECEIPTS_DIR in `policy_path?` and lowercase segs in `policy?`. |
| NOTE | `tools/lane_guard.rb:66` | `&& v.length == v.length` is a tautology (dead clause; reads like an unfinished uniq check). | Correctness hygiene. | Drop it or make it `v.uniq.length == v.length`. |
| NOTE | `test/tools/lane_guard_test.rb:127` | `tracked` comes from a backtick `git ls-files`; if git is absent/fails the array is empty and the "every tracked file" claim silently degrades to probes-only. `main()` (branch check, missing trust ref/BOARD, `--files` empty) is exercised only by hand probes. | Test gap (B6 residue). | `refute_empty tracked`; add one `LaneGuard.main([...])` test for the wrong-branch rc 1. |

## Verified claims
- Canonicalization + MALFORMED refusal, policy-by-intersection at parse, branch check in every mode, `SIM LANE` machine row on BOARD (`drafts/lanes/BOARD.md:3-8`), strict list schema, `changed_paths` both-sides + spaces, overlap over all tracked files — all present as described and green in the suite.
- Presentation: the changed fetches are strict and declared; no sim state, wall-clock or RNG introduced; minimap/arrow/fx read-only from world/map/camera (unchanged from prior review).
- No `*.rb`/`data/**` change touches `src/game/**` in this commit (`git show --stat`).

## Not verified
- No Gosu window, gate, capture, wall, or map run; visual effect of `minimap_dot_extra`/`exit_arrow_gap` is code-read only (values identical to the prior literals: 1/2/1/2 and 8).
- Case-insensitive rename behaviour of git on this FS was not exercised (read-only review; no index writes).
- This report is the only file written.
