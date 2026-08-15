# Pilot-mode adversarial review (2026-08-10) — main...HEAD on branch pilot-mode

Reviewer: code-reviewer agent (adversarial brief: attack determinism/round-trip,
inbox arithmetic, window-host lifecycle, GotoEngine aborts, purity, protocol).
Verdict: **no HIGH findings; the core determinism claim verified sound.**
"Recorded inputs, not engine decisions, are what replays, so even goto's refused
steps re-refuse identically in replay."

## Findings (ranked) and fold decisions

1. **MEDIUM — `draw` outside the FATAL/crash-export contract** (pilot.rb).
   `update` is rescued into handle_fatal (crash.json export) but `draw` is bare;
   idle mode draws every vsync, so a renderer raise loses the session with no
   export — exactly the bug class a pilot session exists to flush out.
   **FOLDED:** draw now rescues into handle_fatal.

2. **LOW-MED — `reset` reuses one capture dir; PNGs silently overwrite** at the
   same frame index across generations, so a log-driven MD5/vision comparison
   can judge the wrong image. **FOLDED:** a reset generation counter is baked
   into capture/replay/crash dir names (`<name>_r<gen>`).

3. **LOW-MED — hitstop round-trip test has a weak oracle**: the disjunction
   passes when the possessed merely took damage, and on_player_hit deliberately
   does NOT set hitstop, so the named invariant could go unexercised.
   **FOLDED:** the test now counts frames where `feel.hitstop?` was true during
   the recorded hold and requires > 0.

4. **LOW — equal-or-longer inbox rewrite is undetected** (truncation check is
   size < offset only); a stale offset mid-splices new content, worst case into
   an unintended-but-valid command. **FOLDED as documentation:** header now
   states equal-length rewrites are undetectable — the append-only contract is
   the real rule; truncation detection is a tripwire, not a boundary.

5. **LOW — no way to cancel an in-flight long command**: `wait 100000` at low
   speed pins the FIFO for minutes-to-~28min; a queued quit just waits; killing
   the process loses the recorder. **FOLDED:** `quit` now PREEMPTS — it clears
   the queue and the in-flight command — and always exports `last.json` before
   closing, so no session history is ever lost. Documented in the header.

6. **LOW — labeled duplicate captures at one frame**: both PNGs are written and
   CAPTURED-logged, but the export lists the frame once; a naive "every CAPTURED
   line has a replay twin" checker would misfire (pixels are identical — idle
   draw verified stateless). **FOLDED as documentation** in the header.

7. **INFO — `Integer(token, 10)` accepts `+5` / `1_000`**: grammar wider than
   docs imply, values still correct and non-negative. **NOT FOLDED** (no wrong
   behavior; not worth the code).

## Explicitly cleared by the reviewer (attacked, verified sound)

Capture K→K−1 indexing + filename parity with replay_runner (MD5 path holds);
boot/post-reset capture ERR; hold-range final-frame edges; hitstop frame
lockstep (@frame increments on the early-return path); goto diagonal synthesis
(flow field corner-cut rule is STRICTER than plan_dash, so controller and field
always agree on landings); intra-tick blocked-list drift; reset lifecycle
(queued commands materialize engines only in flight); goto-during-veil abort
ordering; reset 0 truthiness; inbox \r-only lines / split writes / byte
indexing; symbol→string→symbol JSON round-trip; the $stdout-assign-vs-reopen
mingw fix (ce1d2b1 correct); purity (no gosu in pilot_session, git diff
main -- src/ empty); protocol lines all documented (EVENT lines are
WorldScene's pre-existing vocabulary); no mocks below the layer under test.
