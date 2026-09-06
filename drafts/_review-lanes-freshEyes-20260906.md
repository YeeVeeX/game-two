# Fresh-eyes review — ea8b5ab..5595c11 (review fixes + multi-agent lanes)
## Verdict: BLOCKED
The fence is self-modifiable and misses the source side of renames, so a lane can change/delete files outside its original ownership while the guard returns OK.

## Suite: 1484 runs, 87552 assertions, 0 failures, 0 errors, 0 skips · Canaries: world_loop `= ACTIVE bank? YES`; brasa2_run `= ACTIVE bank? YES`; floor3_run `= ACTIVE bank? YES`

## (A) Previous findings: 1..8

1. **CLOSED** — `test/game/save_state_test.rb:676-682` now explicitly classifies bag `slots`, `used`, and `contents` as `:session_only` and names the current loss-at-session-end debt.
2. **CLOSED** — `src/game/creature.rb:175-179` digests both `poison_interval` and `burn_interval`; `test/net/state_digest_test.rb:40-42` pins both in `CREATURE_FIELDS`; `test/game/save_state_test.rb:714-721` classifies both `:session_only`.
3. **CLOSED** — `data/balance/status.json:2,6-10` documents instant aura tick **plus** ignited DOT; `test/game/status_test.rb:76-89` asserts burning, configured tick count, and immediate HP loss. The test does not pin exact impact damage, but it does prove the stated two-part contract.
4. **PARTIAL** — runtime fall-through is real: false/nil from `pick_up_item` reaches station dispatch at `src/game/world.rb:489-511`. However, `test/game/bag_test.rb:86-101` asserts only `bag_full` and that the floor item remains; it has no station effect/event assertion, and its “station saw the press” claim is only a comment. **New regression risk:** the generalized fall-through also reaches corpse loads and ropes (`src/game/world.rb:492-517`), not only stations, so a full-bag refusal can loot a corpse or cross a rope on the same press.
5. **CLOSED** — `data/items.json:11-12` gives `ember_salve` only `cure: [burn]`; no `resist` remains in its use data.
6. **PARTIAL** — requested structural moves exist: status tint/icon keys are absent (`data/balance/status.json:3-20`), `art_burn_tint_rgb` and `bag_screen` exist (`data/display.json:176-177`), and loot uses strict economy fetches (`src/game/loot.rb:16-27`). But the previous finding covered hardcoded/defaulted presentation values broadly: `src/app/bag_screen.rb:12-15,27-34` retains duplicate layout constants and fallback defaults, while many panel dimensions/colors remain code literals (`src/app/bag_screen.rb:33-42,54-56`). Missing display rows are therefore still silently masked rather than strict.
7. **CLOSED** — `src/game/loot.rb:48-57` derives candidates from `@bag.stacks`, unique-sorts canonical ids, then resolves catalog entries; UI pin order (`@bag.sorted`) no longer selects the cure.
8. **CLOSED** — `src/app/bag_screen.rb:49-58` keeps the grid sourced solely from `bag.sorted` and draws provisions as a title-row chip, not a prepended virtual stack.

## (B) Fence findings (BLOCKER/MAJOR/MINOR)

| # | sev | file:line | finding | failure mode | one-line fix |
|---|---|---|---|---|---|
| 1 | BLOCKER | `drafts/lanes/s4-equipment.md:4-11`; `tools/lane_guard.rb:85-97` | Every lane owns its own authority brief, and the guard reads that mutable working-tree brief. | A lane adds any path to `owns` (and removes it from `never`) in the same staged change; the expanded policy authorizes itself, defeating both fences. | Load briefs from a trusted base/integrator ref and forbid lane edits to policy files; only the integrator may change briefs. |
| 2 | BLOCKER | `tools/lane_guard.rb:91-95` | Both staged and `--base` modes use `git diff --name-only`, which does not reliably fence both sides of a rename. | Renaming a forbidden/shared source to an owned destination can present only the owned new path, silently deleting the shared old path while passing. | Parse `git diff --name-status -z --find-renames` and check both old and new paths for copies/renames. |
| 3 | MAJOR | `tools/lane_guard.rb:82-96`; `drafts/_multiagent-lanes-design-20260906.md:46-54` | The tool enforces neither the configured branch nor the BOARD SIM TOKEN despite the design calling the protocol mechanical and collisions “impossible.” | A lane can run on the wrong branch or modify owned `src/game/**` without holding the token and still receive OK. | Check current branch against `branch:` and require an exact machine-readable token owner before allowing `src/game/**`. |
| 4 | MAJOR | `drafts/lanes/s4-equipment.md:41-42,49-50`; `drafts/lanes/BOARD.md:6-10` | Briefs require lanes to write receipts/PATCH REQUESTS to BOARD, but no lane owns BOARD. | The required handoff itself is refused (`drafts/lanes/BOARD.md` is outside `owns`), forcing either policy violation or no handoff. | Make BOARD integrator-written via a separate receipt artifact each lane owns, or add a safe append-only handoff command. |
| 5 | MAJOR | `tools/lane_guard.rb:89-95` | CLI parsing is fail-open: unknown/malformed modes fall back to staged files, `--files` may be empty, git exit status is ignored, and `--base` is shell-interpolated. | A typo/failing ref can check zero/unrelated staged paths and return OK; an untrusted ref can inject shell syntax. | Use strict option parsing, `Open3.capture3` argv form, require nonempty valid operands, and fail closed on git errors. |
| 6 | MINOR | `test/tools/lane_guard_test.rb:26-28,63-71` | The shared-file test omits `src/game/save_state.rb`, `data/strings/**`, and `data/art/**`, and it never checks pairwise `owns` overlap. | A future brief can own an omitted shared path or collide with another lane without failing the advertised tripwire. | Test the complete shared pattern set and pairwise pattern intersections (or concrete repository-path expansion). |
| 7 | MINOR | `tools/lane_guard.rb:28-48`; `drafts/_multiagent-lanes-design-20260906.md:43-45` | The “YAML” parser is a narrow ad-hoc format: UTF-8 BOM, YAML comments/quoting, and tab-indented keys are rejected or misread. | A normal YAML edit can crash/refuse unexpectedly; inline comments become literal path text. | Use safe YAML parsing with an explicit schema, or document/test the format as non-YAML and reject unsupported syntax clearly. |

No current pairwise overlap was found among shipped `owns` paths, and no listed shared path is currently in an `owns` list. `never` does override `owns` in `LaneGuard.check` (`tools/lane_guard.rb:72-77`). Backslashes normalize correctly (`tools/lane_guard.rb:56-65`). `*` is one segment; trailing `/` and `/**` are subtrees. Correctly, `data/balance/equipment/` does **not** match sibling file `data/balance/equipment.json`; the shipped s4 brief owns that file explicitly. A tracked symlink only grants ownership of the link path, not an external target's contents, so no additional repository-write bypass was demonstrated.

## Adversarial probes run

- `bundle exec ruby -Isrc -Itest test/tools/lane_guard_test.rb` → **PASS**, 5 runs / 79 assertions.
- `ruby tools/lane_guard.rb review --files tmp/review_probe.md src/game/world.rb` → **REFUSED**, `world.rb` forbidden.
- `ruby tools/lane_guard.rb s4-equipment --files src/game/equipment.rb src/app/equip/sub.rb data/balance/equipment/tier1.json data/balance/equipment.json src/game/world.rb` → **REFUSED**; owned exact file accepted, nested paths outside, `world.rb` forbidden.
- `ruby tools/lane_guard.rb s7-boss-tables --files 'data\balance\drops.json'` → **OK**, Windows separator normalization works.
- `ruby tools/lane_guard.rb s4-equipment --files drafts/lanes/s4-equipment.md` → **OK**, demonstrates mutable policy ownership.
- `ruby tools/lane_guard.rb s4-equipment --files drafts/lanes/BOARD.md` → **REFUSED**, demonstrates handoff contradiction.
- `ruby tools/lane_guard.rb s4-equipment --files` → **OK (0 files)**, demonstrates fail-open empty explicit mode.
- `bundle exec rake` → **PASS**, summary quoted above; run once.
- `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run` → all three `= ACTIVE bank? YES`.

## Not verified (headless limits)

No Gosu window, replay runner, gate, capture, map, wall, or visual critic was run. Bag chip/layout and burn/poison presentation were code/data-reviewed only. Rename bypass was established from the guard's `--name-only` implementation semantics, not by mutating the tracked worktree. The report is the only file written; no tracked or staged file was changed.

```acceptance-report
{
  "criteriaSatisfied": [
    {
      "id": "criterion-1",
      "status": "satisfied",
      "evidence": "Read-only review stayed within ea8b5ab^..5595c11; only tmp/review_lanes_freshEyes.md was written."
    },
    {
      "id": "criterion-2",
      "status": "satisfied",
      "evidence": "Report provides file:line evidence for all eight prior findings, seven fence findings, exact adversarial commands, suite summary, and canary cells."
    }
  ],
  "changedFiles": [
    "tmp/review_lanes_freshEyes.md"
  ],
  "testsAddedOrUpdated": [],
  "commandsRun": [
    {
      "command": "bundle exec rake",
      "result": "passed",
      "summary": "1484 runs, 87552 assertions, 0 failures, 0 errors, 0 skips"
    },
    {
      "command": "bundle exec ruby -Isrc -Itest test/tools/lane_guard_test.rb",
      "result": "passed",
      "summary": "5 runs, 79 assertions, 0 failures"
    },
    {
      "command": "ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run",
      "result": "passed",
      "summary": "ACTIVE bank? YES for all three scripts"
    },
    {
      "command": "ruby tools/lane_guard.rb review/s4-equipment/s7-boss-tables --files <adversarial paths>",
      "result": "passed",
      "summary": "Observed expected accepts/refusals plus policy-self-edit, BOARD, and empty-list weaknesses"
    }
  ],
  "validationOutput": [
    "Previous findings: CLOSED 1,2,3,5,7,8; PARTIAL 4,6",
    "Fence: 2 blockers, 3 majors, 2 minors",
    "No current owns overlap or shared-file ownership found"
  ],
  "residualRisks": [
    "No GL/visual validation due explicit headless-only constraint",
    "Rename bypass not staged in the tracked worktree"
  ],
  "noStagedFiles": true,
  "diffSummary": "Review-only report; no product source/data/test edits.",
  "reviewFindings": [
    "blocker: tools/lane_guard.rb:85-97 - mutable lane-owned briefs let a lane widen its own fence",
    "blocker: tools/lane_guard.rb:91-95 - name-only diff misses forbidden/shared rename sources"
  ],
  "manualNotes": "Verdict BLOCKED until both fence bypasses are fixed; finding A4's new test does not prove station dispatch."
}
```
