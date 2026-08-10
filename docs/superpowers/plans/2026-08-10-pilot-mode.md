# Pilot mode — file-driven interactive harness (game-two)

## Context

The dev of record (Claude) verifies the game only through pre-authored replay scripts:
write JSON → run → read event log → adjust → rerun. Fine for gates, slow for
*exploration* — aiming loot_loop.json at D0's beats took ~6 blind iterations. The owner
approved (2026-08-10) **pilot mode**: a command-driven interactive session against the
REAL sim + renderer + Gosu window, so Claude can play, inspect state, and capture
frames on demand — with every session deterministic and exportable to the existing
replay-script format (a session that reproduces a bug becomes a regression script
mechanically).

OS-level input injection was rejected (timing-flaky, kills determinism). Transport is
file-based: Claude appends command lines to an inbox file; the pilot window polls it
each `update()`; all output streams to a log file Claude reads/greps.

**Scope class: tooling** (like `vision_critic.py`) — zero `src/` changes, zero game
scope impact. Branch `pilot-mode`, adversarial review, merge `--no-ff`, NO push.

Design was pressure-tested by a Plan agent (11 findings: 2 HIGH, 5 MED, 4 LOW — all
folded below; the hitstop/frame-lockstep reasoning and the state-serializer accessor
inventory were verified against code; gosu requires cleanly headless and `IO#pread`
works on this mingw Ruby build — both runtime-verified).

## Design (final, findings folded)

**Files**
- `harness/support.rb` NEW — `Harness.expand_script` + `Harness.save_opaque(image,
  path)` moved from replay_runner; NO top-level gosu require (Gosu touched only at
  call time) so tests load it headless. replay_runner delegates; behavior
  byte-identical.
- `harness/pilot_session.rb` NEW, PURE (requires json, core/input, game/controllers,
  game/flow_field only): `Parser` (action whitelist =
  `Game::PossessedController::ACTIONS + [:swap]` — required, not duplicated) ·
  `Inbox` (binary-mode `File.size` vs offset + `IO#pread`; only complete
  `\n`-terminated lines; size<offset → reset to 0 + `ERR inbox truncated`; ENOENT →
  empty; strip `\r`) · `Recorder` (per-frame action sets; `to_script(seed:, width:,
  height:, out_dir:)` emits hold-ranges-ONLY (singletons as `[f,f]`, no `frames`
  dict — one representation, exact round-trip), captures, `run_until`) · `PilotInput`
  (ScriptedInput duck: `update(frame)`, `down?(action)`) · `state_hash(world)` +
  `dump_hash(creature)` serializers · `GotoEngine` (own FlowField on `world.map`;
  `recompute!(dest)` then fail-fast `distance == INFINITY → unreachable`; per-step
  `downhill_from(tile, blocked: world.blocked_for(possessed))`; waits out
  `walker.moving?`/hitstop; nil-downhill while body-blocked → empty frame + retry,
  guard bounds livelock; aborts: `zone_changed` (zone_name snapshot),
  `possession_changed` (`.equal?` identity snapshot), `pack_wiped`
  (`states.current == :nest_respawn`), `guard` (reports tile reached)).
- `harness/pilot.rb` NEW — thin `PilotWindow < Gosu::Window`, sized from
  `data/display.json` (960×540 — exports must replay at the same resolution). Owns its
  log: `$stdout.reopen(log, "a")` + `$stdout.sync = true` + `$stderr` folded in
  (shell-agnostic; rake task needs no redirect). Commands queue FIFO, ONE in flight;
  sim-consuming commands advance ≤`speed` ticks per update (default 10, **cap 60** —
  unbounded update() stalls the Windows message pump); **ACK on completion** carrying
  the reached frame. Idle = frozen sim (no tick, keep drawing — renderer verified
  wall-clock-free). `rescue StandardError` in update → `FATAL` + backtrace to log +
  auto-export `crash.json` + `close!` (the input history is most valuable at the crash).
  Header comment documents the append-only contract: `printf 'cmd\n' >> inbox.txt`,
  never the Write tool.
- `test/harness/pilot_session_test.rb` (+ `pilot_roundtrip_test.rb`) NEW — pure, real
  files (`Dir.mktmpdir`) + real `Game::World` from real `data/`, no gosu, no mocks.
- `Rakefile` — `task :pilot` (`NAME=session SEED=0` via ENV, read by pilot.rb itself).
- `CLAUDE.md` — one Commands bullet.

**Protocol** (all lines in `tmp/pilot/<NAME>/log.txt`; inbox `tmp/pilot/<NAME>/inbox.txt`)
`READY name=<n> seed=<s> frame=0` · `ACK <cmd> frame=<n>` (on completion) ·
`ERR <msg>` (never crash) · `STATE <json>` · `DUMP <json>` ·
`CAPTURED <path> frame=<n>` · `EXPORTED <path> run_until=<n>` ·
`GOTO_OK tile=<t> frame=<n>` / `GOTO_FAILED reason=<r> tile=<t>` · `FATAL <err>`.

**Commands**
`hold <a[,a]> <frames>` · `press <a[,a]>` (=hold 1) · `wait <frames>` ·
`goto <tx> <ty> [guard=3000]` (synthesized inputs recorded like typed ones) ·
`capture [label]` (`Gosu.render`+`save_opaque` → `captures/pilot/<NAME>/`; **requires
world.frame ≥ 1** — a boot capture has no replay representation, ERR with "wait 1
first"; exported capture frame = `world.frame − 1` — replay_runner captures AFTER the
tick that consumed input frame N) · `state` · `dump <creature-name>` (full detail:
tile/hp/facing/moving?/attack_state/current_action/stagger/dodge_cooldown/
exhaust_ready?/special_ready?/iframes?/carried/reserved_tile — all existing public
readers) · `speed <1..60>` · `export [name]` (scenario "world" + seed + width/height +
out_dir + hold ranges + captures + run_until — replayable via `rake capture`/`rake
gate` unchanged) · `reset [seed]` (fresh WorldScene + recorder in-process, re-READY —
saves a window relaunch per experiment) · `quit` (`close!`).

**Load-bearing invariants (verified in code)**
- `World#tick` increments `@frame` on every path (hitstop early-return, `:world`,
  `:nest_respawn`) → pilot tick count and runner frame counter stay in lockstep.
- Hitstop ticks never query input → recorded holds on those frames replay identically.
- Serializer accessors all exist (World/Pack/Creature); serialize `kit_name`, never
  `kit` (that's the whole config hash).
- Gosu keeps calling update() when unfocused/minimized (no pause-on-blur).

## Tasks (test-first for pure parts; commit per task on branch `pilot-mode`)

1. **Extract `harness/support.rb`** (expand_script + save_opaque; replay_runner
   delegates). Verify: `rake` green + `SKIP_CRITIC=1 rake gate
   SCRIPT=harness/scripts/district_hunt.json` byte-identical.
2. **Pure tests first** (`pilot_session_test.rb`): parser table incl. ERR cases
   (unknown cmd/action, bad frames, speed out of 1..60, goto arity); inbox edge cases
   (partial line, two-lines-one-append, truncation reset, ENOENT, CRLF); recorder
   round-trip through `Harness.expand_script` + `Core::ScriptedInput` walk; capture
   indexing (after N frames → exports N−1; at 0 frames → ERR). Run: fail.
3. **Implement `pilot_session.rb`** → Task-2 tests green.
4. **Round-trip + goto integration tests against the REAL World, headless**
   (`pilot_roundtrip_test.rb`): drive a real seeded World through PilotInput+Recorder
   (hold/press/goto across the nest), export, rebuild `ScriptedInput` from the export,
   drive a FRESH same-seed World, assert final tile/frame/zone equal. Hitstop case:
   stage a hit so hitstop frames fall inside a recorded hold. Goto aborts: wall dest →
   `unreachable`; kill possessed mid-goto → `possession_changed`. Run: green.
5. **`harness/pilot.rb` window host + rake task** (thin interpreter — every decision
   beyond Gosu calls lives in tested pilot_session).
6. **Live verification** (the no-mocks acceptance): boot via `rake pilot`
   (background), then via inbox: `state` → JSON sane · `goto`/`hold attack`/`capture`
   through the D0 loop (kill → pickup H/F → gate → bank at [12,8]) with `state`
   asserting banked > 0 · minimize window during `wait 600` → frames still advance ·
   goto crossing a gate → `GOTO_FAILED reason=zone_changed` · `export smoke` + `quit`,
   then `rake capture` on the export and **MD5-compare the pilot PNG vs the replay PNG
   at the same frame — byte-identical is the acceptance bar** (the design's central
   claim). Bank transcript → `drafts/_pilot-first-flight.md`.
7. **Review + merge**: adversarial review of `main...HEAD` → `drafts/_pilot-review.md`
   → fold → `rake` + all four existing gates green (support.rb is the only shared-path
   touch) → merge `--no-ff`, no push → checkpoint delta.

## Verification (blocking)

- `rake` green including the two new test files.
- Four existing gate scripts byte-identical + vision-pass post-refactor (Rule 2).
- Task-6 live proof: real window, real inputs, pilot capture byte-equals replay
  capture of the exported script.
- Structural: `git diff main -- src/` empty; no balance constants; window.rb untouched.

## Explicitly out (YAGNI)

stdin REPL (no TTY to hold) · sockets · event-history/state-diff commands (log + grep
already serve both) · rewind/save-states · any `src/` hook.
