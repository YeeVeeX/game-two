GOAL: Finish shipping the FIGHT LEDGER (scope v8) end-to-end: execute plan tasks 4-10 in order, all gates green, merge --no-ff to main, then deliver the 8-question fun-verify via AskUserQuestion and STOP - the verdict decides what is next (A2 threat AUTO-PROMOTES on a failed verdict, owner pre-authorized).

STATUS: v8 locked (owner pick: ledger now, threat pre-queued). Spec REVISED after 3-lens review (24 folds, 3 rejected): docs/superpowers/specs/2026-08-11-fight-ledger-design.md. Plan: docs/superpowers/plans/2026-08-11-fight-ledger.md (10 TDD tasks, code pre-written). Branch fight-ledger at a09a466 (128 commits), tasks 1-3 DONE: ledger.json + interlock test; Game::FightLedger (window, :fight_resolved, beat record, leg accumulator, World wiring AFTER wire_events = ordering pin); 11 integration tests. 206 tests / 873 assertions green. NO remote - never push.

READ FIRST (Rule 8): CLAUDE.md, docs/CHECKPOINT.md top entry, the spec, the plan (tasks 4-10), drafts/_ledger-spec-review.md (fold ledger), drafts/_tibia-hunt-analyser-ek1037.md (owner evidence: green-as-earned).

NEXT SEQUENCE (plan tasks, IN ORDER, commit each):
4. Wipe recap tests: immediate resolve, ordering pin (stranded accrues first), snapshot pip, veil freeze, dissolve-never-stomps, replace rule, hitstop freeze.
5. Bank tally tests: leg gained = first-acquisition pickups only, destroyed all-zones, outstanding snapshot on pip line excluded from net, reset on bank.
6. Telemetry: fights/recovery_fights/negative_fights appended; telemetry_test REWRITTEN byte-exact (never substring); world_scene.rb logs fight_resolved.
7. Renderer: draw_ledger_beat AFTER draw_wipe_overlay (M1 - veil buries it otherwise); glyphs = filled square gained / hollow pip stranded / dark+red-edge destroyed; net line bold, red when negative; recovery beat pip-prefixed. Then SKIP_CRITIC=1 determinism re-check of all 6 old scripts (beats now render in old replays).
8. Pilot flight (protocol: harness/pilot.rb header; printf-append to inbox, NEVER Write; captures <= 20): author ledger_loop.json, 5 acts (clean win / negative beat / wipe recap on veil / redemption / bank tally). CADENCE SHIP GATE: measured 1-4 beats/min over the hunt stretch, else retune ledger_quiet_frames from measured gaps and re-fly.
9. Vision checks 26->30 APPENDED (pass-true not-exercised hatches; texts in plan task 9) + CLAUDE.md commands bullet + FULL WALL: rake, rake perf, all 7 gates (set -o pipefail; exit nonzero fails).
10. Impl review (code-reviewer agent, seeds in plan task 10) -> fold -> re-gate -> merge --no-ff, NO push -> checkpoint delta with MEASURED numbers.
THEN: fun-verify - owner plays (offer bin/play launch, capture TELEMETRY line incl. fights= fields), ask the spec's 8 questions via AskUserQuestion in TWO batches, bank verdict + routing in drafts/, update checkpoint, STOP.

PRE-REGISTERED ROUTING (locked, do not re-derive): Q3 chore alone -> A2 promotes. Q6 cant-read -> presentation iteration first, meaning verdict waits. Q1/Q2/Q5/Q7 decide attribution + ledger disposition (any signal = stays through A2; wallpaper + wouldnt-miss = removed before A2). Q8 banked-halved is a LABELED CONTROL. Q4 same-walk is consistent with LB-1, feeds A2.

STANDING RULES: export PATH="/c/Ruby34-x64/bin:$PATH" per shell. Zero balance constants in Ruby; window.rb <= 300 lines; events registered or emit raises; no mocks; existing vision checks never weaken. Payload key is gained: never yield:. Interlock quiet < settle is load-bearing (asserted). Critic flakes: pixel-verify before believing FAIL, retry INFRA. Test staging lessons live in fight_ledger_test.rb comments: drain_hitstop flushes one tick first; quiesce_ledger before exact counts; mutate clocks instead of outwaiting respawn cycles; bounded drives when respawn skirmish may refresh.

DONE WHEN: merged on main, all 7 gates + rake + perf green, checkpoint updated, fun-verify verdict banked via AskUserQuestion. STOP after the verdict.
