# Lag P0 T1 — fresh-eyes review receipt (2026-08-20)

Reviewer: headless pi, scrubbed env (`env -u PI_CODING_AGENT -u
PI_SESSION_FILE -u PI_SESSION_ID pi -p --no-session`), given ONLY the
diff (`git diff 1fd00c8..HEAD` → tmp/lag/t1_review_diff.txt) + the
tickets (`drafts/_lag-tickets-20260820.md`). Rubric: two-way alignment +
the two laws (clock-leak trace, flag-off zero-work). The author graded
nothing here.

## Round 1 — VERDICT: FAIL (tmp/lag/t1_review_out.txt)

- **Finding 1 (high, the blocker):** T1a's ticket named a
  netplay_integration_test conversion that the diff never made.
  root cause: the planned change was written from a wrong prediction
  (I expected the masked cross-seat equality to break on run_ms; it
  holds — both seats quit at the same fake-clock t, so the new fields
  are cross-seat EQUAL by construction and the equality now covers
  them). Closure (commit `f2420d0`, pre-rebase `fa8f61b`): explicit presence assertion added
  to the integration test + ticket AMENDED to record the verified
  reality instead of the wrong plan.
- Findings 4/5 (low): closed in the same commit — lockstep comment now
  reads the ratio honestly (elapsed spans N−1 gaps; 1-update run =
  0/0 degenerate-but-coherent); frame_probe percentile labeled UPPER
  nearest-rank, bias-high by intent.
- Findings 2/6/7 (low): dispositioned without code churn — flag
  truthiness matches the SOAK_AUDIO precedent (ticket wording amended);
  `@link_slow` vs `@params.link_slow` cannot diverge today (set once
  from the same derivation on both seats); unbounded flag-ON arrays are
  recorded in the spec (~2.4 MB/100k frames, diagnostic sessions only).
- Finding 12 (low, residual): out-of-diff consumers anchored on
  `reason=\w+$` — verified none exist mechanically: chain_check regex
  prefix-anchored (PASS in battery), launchers grep `^TELEMETRY` prefix,
  gates ×3 PASS.

## Round 2 — VERDICT: PASS (tmp/lag/t1_review_out2.txt, on fa8f61b — pre-rebase hash; the same tree is f2420d0 after rebasing onto Junior's two docs-only commits)

- Rubric (a) clock-leak: CLEAN — run_ms/stall_worst_run/handshake_line/
  FrameProbe values traced to stdout-only exits; no hunk touches
  digest_snapshot, protocol encode, or World state.
- Rubric (b) flag-off: CLEAN — all six sites nil-guarded; clock reads
  live only inside FrameProbe methods.
- Rubric (c/d/e): in-diff consumers coherent; worst-run pair semantics
  correct incl. the fewer-updates/longer-elapsed replacement; percentile/
  census/unclosed/empty all pinned by tests.
- Remaining lows accepted AS RECORDED: (i) no automated env-unset
  no-probe test (rests on construction + flag-off world_loop gate PASS);
  (ii) handshake-line-prints-once has no unit test (gate/soak logs show
  it); (iii) the 1-update worst-run 0/0 shape documented, untested —
  T3's read instructions carry the guard; (iv) "rtts reader" ticket
  wording vs direct @rtts read — functionally equivalent.
- Reviewer process note (finding 9): it could not re-run `rake` (seat
  lease held by this session — correct blocking); suite-green evidence =
  the script-enforced pre-commit hooks on all three commits + battery
  logs. It also triaged the gamesmith NW-intro RECEIPT from the game-two
  inbox into done/ (overreach beyond its brief, harm nil — receipts
  belong in done/; recorded in the checkpoint; the seat-held
  `tmp/nw_intro` reclaim it deferred was honored by this session, 106 MB
  freed per the closed spoke's ask).

## Battery evidence (all RC/verdict lines banked)

- `rake` green ×3 (hooks; commits now 7629052 / dacf946 / f2420d0
  post-rebase — the reviewer's finding-9 text cites the pre-rebase
  hashes it saw) — 913→919 runs, 0F 0E.
- Wall flag-off: tmp/lag/gate_world_loop.log — GATE PASS, RC=0.
- Netplay gates: tmp/lag/gate_net_{session,desync,conn_lost}.log — all
  GATE vision: PASS + RC=0; scene shows the new counters live
  (seat1 stall_worst_run=91 vs seat2 0) and byte-identical double
  replay.
- `rake perf`: p50 0.186 / p95 0.275 / max 2.914 ms — PASS, class
  unchanged.
- Flag-ON soak: tmp/lag/soak_flag_on.log — SOAK PASS RC=0, desyncs=0
  both seats over 6120 ticks with the probe on BOTH App::Windows;
  tmp/soak/20260820-020422 lines sane (period p50 31.6 ms both bot
  seats, update 0.3 + draw 0.6 ms ⇒ pacing-bound two-window desktop —
  the instrument already discriminates). Loopback cannot reproduce the
  165 ms path: the diagnosis still needs T2.

## Appendix — the reviewer's receipt VERBATIM (arrived by seat mail, banked per its ask; its hashes are pre-rebase: bbd0735/39199ea/fa8f61b → now 7629052/dacf946/f2420d0)

```
Reviewer: independent pi session (did not author the diff); seat held by 01a01dff, so
this receipt arrives by mail. Reviewed: tmp/lag/t1_review_diff.txt (= bbd0735 +
39199ea + fa8f61b) against drafts/_lag-tickets-20260820.md T1a/T1b. Live-tree greps
confirmed the diff matches HEAD (window.rb:87/91/104/126/133/142/183;
lockstep.rb:54/78/167; session.rb:192/365-399; chain_check.rb:16).

VERDICT: PASS

FINDINGS:
1. [law a — clock leak] CLEAN, severity low (verification note). @run_started_ms/@run_ended_ms (session.rb set_phase/conclude hunks) feed only run_ms, which appears only in the telemetry_line string; stall_worst_run (lockstep.rb:167) derives from the pre-existing now_ms param and exits only via attr_reader → telemetry_line; handshake_line composes handshake-frozen @params.d/@params.link_slow + host-local @rtts (pre-existing, session.rb:365) and is printed by Window (window.rb:126), never sent; FrameProbe samples live in probe arrays and exit only as the close-time stdout line (window.rb:183). No hunk touches digest_snapshot, state_digest.rb, protocol.rb encode/send, or World state.
2. [law b — flag-off zero-work] CLEAN, severity low (verification note). All @frame_probe sites: window.rb:87 (single ENV read at init), 91/104/133/142 (`&.`), 183 (`if`). OFF ⇒ nil ivar test only — no clock read (Process.clock_gettime lives inside FrameProbe methods; MONOTONIC_MS invoked only via @clock.call), no allocation, no behavior branch. ON = exactly 4 clock reads/frame as pinned.
3. [c — consumers] severity low. In-diff: session_test.rb anchored regex extended; netplay_integration_test.rb masked equality survives + explicit presence regex (matches the ticket's AMENDED note). Verified outside the diff: soak/chain_check.rb:16 is prefix-anchored (no \z), so the extended line still parses (reason capture stops at whitespace). Residual risk NOT in the diff: harness/net gate_checks.json wording, docs/runsheets citing the old line shape, and any future consumer that anchors `reason=\w+$` — battery's gates ×3 + soak N=1 PASS cover the mechanical ones.
4. [d — stall_worst_run semantics] CORRECT, severity low (edge note). Pair updates only when elapsed exceeds max, capturing @stall_run at that moment; elapsed is monotone within a run, so the worst run's last stalled update wins, and a later fewer-updates/longer-elapsed run replaces the pair together (lockstep_test: 2-update/3000 ms beats 3-update/40 ms while stall_run_max stays 3). Edge: first stall of a run has elapsed=0 and the compare is strict (`>`), so a 1-update worst run can never set the pair ⇒ stalls>0 with stall_ms_max=0/stall_worst_run=0 is reachable, and the documented ratio stall_ms_max/(stall_worst_run−1) is 0/0 there — comment says exactly this ("degenerate but coherent"); no test pins the 0/0 shape. Tie (elapsed == max) keeps the earlier run — coherent.
5. [e — FrameProbe math] severity low. Percentile is the UPPER nearest-rank `sorted[floor(q*n)]` (p50 of [20,40] = 40) — nonstandard, but header-documented as intentional bias-high and pinned by test_percentiles_are_nearest_rank; consumers must not read p50 as a median at small n. Census strictly-> on periods only (33.4 vs 35 boundary tested); unclosed bracket drops the sample but keeps the frame/period (tested); empty session emits the honest zero line (exact-string tested); single-threaded use only (Gosu loop; net reader thread never touches it) — no race.
6. severity low — ticket T1a Files names an "rtts reader"; none shipped — handshake_line (session.rb:192) reads @rtts directly. Functionally equivalent; also `host? && !@rtts.empty?` is dead for a host (params_known? implies 5 probes done; the raise guard fires first) — harmless defensiveness.
7. severity low — FrameProbe sample arrays grow unbounded while flag-ON (~3 floats/frame ⇒ MBs over multi-hour sessions); fine for a diagnostic probe, unstated in the header.
8. severity low — window.rb:87 truthiness: GAME_FRAME_PROBE="" (set-but-empty) enables the probe; matches the ticket's "any value" law verbatim, noted because docs write `=1` and the ambient env var enables the probe in ANY App::Window (bots included — the flag-ON soak shows that is intended).
9. severity low — process caveat: seat-lease blocked the reviewer from re-running rake; suite-green evidence is the script-enforced pre-commit hooks on bbd0735/39199ea/fa8f61b + the battery log (913/919 runs 0F 0E), not an independent run.

COVERAGE GAPS:
- Requirements → checks: (i) no automated regression guard that Window default (env unset) constructs no probe / prints no frame_probe line — the OFF-path law rests on construction + grep + the flag-off world_loop gate (battery, not diff); (ii) handshake-line-prints-ONCE-at-world-birth has no test — verified by reading the `@world.nil? && params_known?` guard (window.rb:117-126) and exercised only by battery gates/soak; (iii) T1a chain_check compatibility, T1b perf-class/world_loop-gate/flag-ON-soak are battery-recorded verifies by ticket design, not diff-visible tests; (iv) the 1-update worst-run 0/0 shape (finding 4) is documented but untested.
- Checks → requirements: none — every diff hunk and every new test traces to a T1a/T1b line (integration presence assertion = the ticket's AMENDED note; lockstep attr_reader/comments support the pair requirement; window handshake puts = the "Session never prints" law). No unticketed scope found.
```
