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
