# Lag P0 — tickets (2026-08-20)

Cut from `drafts/_lag-spec-20260820.md` (the spec is disposable; these
are the durable artifact). One ticket = one session-sized unit with its
own runnable verify. T1a+T1b run in THIS session (two one-concern
commits); T2 staged; T3/T4 later sessions.

## T1a — always-on lockstep telemetry: handshake line + close-line extension

- **Goal:** bank the numbers every future session needs for WHO + spike
  shape: negotiated d / link_slow / host RTT probes at world birth;
  run_ms + stall_run_max + coherent worst-run pair at close.
- **Files:** `src/net/lockstep.rb` (stall_worst_run pair, counter math
  only) · `src/net/session.rb` (run-phase timestamps; telemetry_line
  fields; handshake_line composer; rtts reader) · `src/app/window.rb`
  (print handshake line at world birth — Session never prints, existing
  law) · tests: `test/net/lockstep_test.rb`, `test/net/session_test.rb`
  (anchored regex extends), `test/net/netplay_integration_test.rb`
  (AMENDED post-review 2026-08-20: the masked-equality assertion SURVIVES
  — both seats quit at the same fake-clock t, so the new fields are
  cross-seat equal by construction and the equality now covers them; an
  explicit presence assertion was added instead of the planned
  conversion).
- **Line shapes (pinned):**
  `NETPLAY handshake seat=1 d=8 link_slow=false rtt_ms=82,84,86,90,88`
  (joiner: `rtt_ms=-`); telemetry_line appends
  ` d=8 link_slow=false run_ms=1392231 stall_run_max=214 stall_worst_run=201`.
- **Laws:** nothing new crosses the wire; no clock read added to the
  stall path (elapsed already computed); zeros/`-` pre-attach; drain
  excluded from run_ms.
- **Verify:** `rake` green · netplay gates ×3 PASS · chain_check regex
  compatibility exercised by the T1-battery soak episode.
- **Done when:** all verify output recorded in the session log + both
  new line shapes visible in a soak episode log.

## T1b — env-gated frame probe (App::FrameProbe + Window brackets)

- **Goal:** name WHAT eats a seat's frame (update vs draw vs neither =
  pacing/display), solo AND session modes, zero cost when off.
- **Files:** `src/app/frame_probe.rb` (NEW — pure aggregator: samples in,
  percentiles/census line out; no Gosu, no clock) · `src/app/window.rb`
  (env check at init; `@frame_probe&.` brackets in update/draw; line at
  close) · `test/app/frame_probe_test.rb` (NEW — fixed-input math).
- **Flag:** `GAME_FRAME_PROBE` set = on (any value — the SOAK_AUDIO
  precedent; docs always write `=1`). Read once at Window init.
- **Line shape (pinned):** `TELEMETRY frame_probe frames=N
  period{p50=… p90=… p99=… max=…} update{p50=… p95=… max=…}
  draw{p50=… p95=… max=…} over20=N over35=N over100=N` (period = ms
  between consecutive update-begins; over* census on period).
- **Laws:** OFF = nil-checks only (no clock read, no allocation); ON =
  4 CLOCK_MONOTONIC float-ms reads/frame, values never flow back into
  sim/wire/digest/draw; harness replay window NEVER wired (scope note in
  spec §determinism).
- **Verify:** `rake` green · `rake perf` p95 unchanged class ·
  world_loop gate PASS (flag off by construction) · flag-ON soak episode
  N=1: chain_check PASS + sane frame_probe lines both seats.
- **Done when:** verify output recorded; frame_probe line parses by eye
  against the pinned shape; OFF-path grep shows no clock call outside
  the `@frame_probe&.` guards.

## T2 — probe matrix (STAGED, owner-paced; zero code; ~20 min total)

- **Goal:** the numbers only real machines/path can give. Segments (each
  ~4 min, Esc between, own close lines; both seats SAME commit):
  S0-J Junior solo flag-ON (decisive: is his machine ~53.5 Hz alone?) +
  S0-J2 display/power facts · S1 coop baseline flag-ON · S2 coop with
  the alive seat minimized 60 s (note the minute) · S3 role swap
  (Junior hosts; guards: Gabriel's `saves/world.json` md5 unchanged
  after — the joiner never writes; Junior's scratch save never merged).
  All segments: `tailscale status` sampled ~10 s + `netstat -s` TCP
  retransmit delta before/after, both seats.
- **Deliverable now:** runsheet `drafts/_lag-probe-runsheet-20260820.md`
  (exact commands es-CR/pt-br) — STAGE ONLY, never nag.
- **Done when:** runsheet exists with every command copy-pasteable and
  the S3 md5 guard spelled out.

## T3 — harvest + verdict (own session, after T2 runs)

- **Goal:** answer in writing "which seat limited the lockstep, and what
  ate its frame"; correct/extend the forensics doc; emit exactly ONE
  fix ticket (data or code) with its own verify.
- **Inputs:** T2 segment logs (md5-banked in a dated evidence dir),
  T1a/T1b lines, samplers.
- **Done when:** the verdict paragraph names the seat + the eater with
  numbers, and T4 exists as one ticket.

## T4 — the fix (own session, NEVER bundled with T1)

- Whatever T3 names. Own gates, own before/after telemetry comparison
  (the reason T1 and T4 never share a commit).

## Battery status (fill during this session)

- [x] rake green (T1a) — 913 runs 0F 0E (commit hook re-run)
- [x] rake green (T1b) — 919 runs 0F 0E (commit hook re-run)
- [x] wall gate world_loop PASS (flag off) — tmp/lag/gate_world_loop.log RC=0
- [x] netplay gates ×3 PASS — tmp/lag/gate_net_{session,desync,conn_lost}.log all RC=0; scene shows the new fields live (seat1 stall_worst_run=91 vs seat2 0), determinism half byte-identical
- [x] rake perf PASS — p50 0.186 / p95 0.275 / max 2.914 ms (sim tick is CHEAP — the frame budget lives in draw/pacing, not sim, on this machine)
- [x] soak N=1 TICKS=6000 flag-ON: SOAK PASS RC=0, desyncs=0 both seats over 6120 ticks with the probe ON both App::Windows (the two-seat mechanical determinism proof); lines sane — and already teaching: both bot seats period p50=31.6 ms with update 0.3 + draw 0.6 ms (two occluded windows on one desktop = PACING-bound, ≈ the known 2× soak wall-time); equal rates ⇒ stalls=0 BOTH seats (symmetric-limiter arithmetic confirmed live); loopback rtt_ms=32,30,… = probe RTT includes update-loop quantization (honest — that IS what D must cover). Loopback cannot reproduce a 165 ms cross-continent path — the diagnosis still needs T2.
- [ ] fresh-eyes review receipt: `drafts/_lag-t1-review-20260820.md`
