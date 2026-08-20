# SPARK: post-verdict item 1 — LAG INSTRUMENTATION (v18 closed; owner-named blocker)

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (rule 8) — the live file beats this spark on any
drift. Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`.
Working language English; owner surfaces es-CR ustedeo (everyday gamer
words — the foreclosure-register audit applies to your own es/pt).

**Where the project stands (2026-08-20, HEAD `2b566a0`):** v18 CLOSED —
the SEVENTEENTH is CUMPLIDO (`drafts/_v18-fun-verify-verdict-20260820.md`).
The fun-verify measurement freeze is **LIFTED**: sim numbers
(respawn/difficulty/sustain) are movable again, and coop sessions no
longer carry oracle hygiene. Two things did NOT relax: deterministic
quality gates, and "a bot session is never fun-evidence". **v19 is NOT
open** — that brainstorm is the two owners', at their word.

**What this session is:** post-verdict queue item **1 — the lag**, the
owner's named blocker ("demasiado lag, no se puede jugar con tanta
desincronización", ended ritual session 2 on it). Scope: **measure
first, fix nothing blind.** Ship telemetry that names WHO limits the
lockstep and WHAT eats the frame, prove it costs nothing when off, then
harvest real numbers. No pacing/tuning values move this session (that
is a separate, later increment). Quality over cost: the lever is
THOROUGHNESS — every claim re-derived from code or bytes, every gate
run, no eyeballing — not spend (council 0 default; Bedrock only what
the gates' vision critic costs).

## The correction you inherit (verified 2026-08-20 from code — RE-VERIFY, do not trust this prose)

`drafts/_netplay-lag-forensics-20260819.md` concludes "the starvation is
HOST-side (this machine), not the link and not his seat". **The code
says the opposite reading is the right one:**

- `src/net/lockstep.rb:92` `ready?(t)` = `@queues[1].key?(t) &&
  @queues[2].key?(t)`; the header states local is present by
  construction ⇒ **`ready?` gates on the PEER's input.**
- `src/net/session.rb:472-495` `run_tick`: the `else` branch (peer input
  missing) is the ONLY caller of `record_stall` (`lockstep.rb:150`).
- ⇒ `stalls=N` means **this seat waited N updates for the OTHER seat's
  input.** Host s1 `stalls=9807` vs joiner `stalls=136` therefore says
  the host was the seat left WAITING; the low-stall seat is the
  **limiter** (its inputs arrived late / it ran slower), i.e. suspicion
  moves to Junior's seat and the BR→CR direction, not host CPU.
- Already closed as a suspect: Nagle — `src/net/wire.rb:21-23` sets
  TCP_NODELAY and re-reads it with `getsockopt`, raising if it did not
  stick.
- Live hypothesis worth arithmetic: `data/netplay.json` delay window vs
  a 165 ms RTT (at 60 tps, D ticks ≈ D×16.7 ms of cover). If the
  negotiated D under-covers one-way latency + jitter, every tick stalls
  by construction — and a direct↔DERP flap changes the requirement
  mid-session.

Job 1 is to re-verify all of that from the files yourself and correct
the doc. If your reading disagrees with mine, **your verified reading
wins** — say so explicitly and re-plan.

## Read first, in order

1. `AGENTS.md` — whole file (lanes, red lines, out-of-scope).
2. `docs/CHECKPOINT.md` — TOP entry only (session 21: verdict, the 10
   brainstorm inputs, resume point).
3. `drafts/_v18-fun-verify-verdict-20260820.md` — §post-verdict queue +
   the four TRIGGERED rows (R-A1…R-A4). Context for what this item must
   NOT absorb.
4. `drafts/_netplay-lag-forensics-20260819.md` — whole file (the doc you
   will correct + its measured priors).
5. Code, in this order: `src/net/lockstep.rb` (whole — the sampling and
   stall laws live in the header) · `src/net/session.rb` §run_tick and
   the update pump (~lines 190-215, 460-540) · `src/net/wire.rb` ·
   `data/netplay.json` · `src/game/telemetry.rb` (how TELEMETRY lines
   are built and pinned — your new line follows that family).
6. `soak/run_soak.sh` header + `soak/chain_check.rb` (bot legality,
   quarantine mechanics, env extensions).
7. Evidence bytes for the four ritual lines:
   `drafts/_v18-seventeenth-evidence/game_two_session_{8503,2874720530,9048,63472464}.log`.
8. `docs/JUNIOR.md` §"Sessões com agente" — only if you reach the coop
   harvest (Job 5); his seat must run the SAME commit (handshake law).
9. Project memory traps (auto-injected): `$?` after a pipe lies · judge
   by printed output · never edit a script a live run is executing ·
   never run gates under a bash-call timeout (detach + poll) · two
   concurrent instances fork the save.

## Job 0 — standing gate (~10 min; anything moved = classify FIRST, in writing)

Baselines at session-21 close (2026-08-20, HEAD `2b566a0`):
launcher logs **34/34** both temp patterns, newest
`game_two_session_9048.log` (2026-08-19 23:10:17, CONSUMED) · save md5
`edfebf4accf0abf3aa86bb1170c62714` mtime 23:10, play-path strict decode
(pinned shape `App::SaveStore.new(path:).load(data:
Core::DataStore.new("data"))`) `digest=b5cae357290c01e464f49155bc7f9d13`
sessions=10 banked=7 provisions=0 breached=2 boss_1_defeats=1
notices=[] · `HEAD == origin/main`, Junior 0 commits past main · mail
`~/.pi/agent/mail/game-two/done/`=11, inbox EMPTY · `tmp/soak` newest
`20260819-120805` · `drafts/_gate-verdicts.log` tail = T2 PASS entries ·
untracked `drafts/_refs/` = s18/s19 reference images (by design).
The save is no longer a quarantine object (the ritual is closed) — but
it is still the shared world: `--fresh` NEVER, and any launch you make
is single-instance-guarded in a SEPARATE call judged by printed output.

## Job 1 — re-derive the stall semantics, then CORRECT the forensics doc (docs-only, one commit)

Steps: read `lockstep.rb` + `session.rb#run_tick` and write down, with
`file:line` citations, (a) what increments `stalls`, (b) what
`stall_ms_max` measures, (c) which seat's clock it is, (d) whether both
seats can stall on the same tick. Then compute the arithmetic the doc
never did: ticks vs wall-clock per session (s1 74469 ticks / ~28 min;
s2 36079 / ~19 min), implied tps, stall rate, and what D from
`data/netplay.json` covers in ms at 60 tps versus the measured 165 ms
RTT.

**DoD:** the forensics doc carries a `## Correction (2026-08-20)`
section with the citations, the re-ranked hypotheses (limiter-seat
first, D-adequacy/path-flap second, host CPU demoted with its reason),
and the arithmetic — plus one sentence naming what the current
telemetry CANNOT distinguish (that sentence is the spec for Job 2).
Wrong claims get struck through in place, never silently deleted.

## Job 2 — design the instrumentation BEFORE writing it (spec block, ~30 min)

Write the design into the forensics doc (or a sibling drafts spec) and
argue each choice. Non-negotiables the design must satisfy:

1. **Env-gated, OFF by default; zero per-tick work when off** (no
   allocation, no clock read). The wall never sets the flag.
2. **No timing value may reach `digest_snapshot`, the wire, or any sim
   field.** Wall-clock reads are nondeterministic — one leak is an
   instant desync. Samples live in a side buffer, aggregate at close.
3. **Log-only output** (no new visible surface ⇒ no Rule 2 wall debt
   this session). If you WANT an on-screen readout, it is a separate
   increment with a gate + wall.
4. Line shape follows the pinned `TELEMETRY <name> k=v …` family, one
   line per seat at close, machine-readable by `soak/chain_check.rb`.

Recommended content (defend or replace, do not silently drop):
**remote input queue depth** per update (`max(remote queue keys) −
tick` — the direct answer to "who is the limiter": depth pinned near 0
= the peer is limiting) · **stall-run histogram** (buckets of
consecutive stalled updates + max) · **local frame budget breakdown**
(sim ms / render ms / socket-pump ms, and audio-bridge ms if it is
cheaply separable) · counts, percentiles, and max per bucket. Plus an
EXTERNAL `tailscale status` sampler script beside the session (never
in-game, never a game dependency) that timestamps direct-vs-relay.

**DoD:** a spec block naming the flag, the fields, the emission point,
the aggregation math, the tests to write (TDD list), and the exact
verification commands for Job 3.

## Job 3 — implement TDD + prove it costs nothing (the gate wall)

Red-green, smallest seams: a PURE aggregator class (histogram/percentile
math, unit-tested with fixed inputs, zero Gosu), plus minimal wiring in
the update pump behind the flag. Suite green via hooks.

**Verification, all of it, by printed output:**
- `rake` green (hooks enforce it on commit anyway).
- **Wall byte-identity with the flag OFF:** `rake gate
  SCRIPT=harness/scripts/world_loop.json` PASS (double replay + md5
  compare + critic). Run detached, never under a bash timeout.
- **Netplay gates with the flag OFF and ON:** all three of
  `harness/net/{netplay_session,netplay_desync,netplay_conn_lost}.json`
  with `CHECKS=harness/net/gate_checks.json`. Flag-ON PASS is the proof
  that no timing value entered the digest.
- `rake perf` — p95 unchanged and < 16.6 ms.
- One commit, one concern; the flag name and default recorded in the
  doc.

## Job 4 — repro with bots (loopback), and state plainly what loopback cannot prove

`rake soak N=1 TICKS=…` with the flag on (bots are legal here — tech
lane, never fun-evidence). Expect near-zero stalls on loopback: the run
proves the instrumentation EMITS sane, chain-check-compatible numbers,
not that the diagnosis is right. Bank the receipt path and write the
one-paragraph honest limit ("loopback cannot reproduce a 165 ms
cross-continent path; the diagnosis needs the coop harvest").

**DoD:** soak receipt + chain_check PASS + the limits paragraph.

## Job 5 — coop harvest (owner-paced; only with Junior available)

If (and only if) the owner asks for a session: both seats on the SAME
commit (handshake law — Junior pulls current main first), flag ON both
sides, ~10 min, Esc quit. Then harvest both `TELEMETRY` lines + both
sampler logs and answer ONE question in writing: **which seat limited
the lockstep, and what ate its frame?** Bank the logs md5-identical in
a dated evidence dir. If he is not available, leave Job 5 staged with
the exact launcher commands and STOP — never nag.

## Job 6 — only if the numbers indict a value (separate increment, not this one)

If (and only if) the harvested numbers name D/`data/netplay.json` (or
any tunable) as the cause: that change is its OWN commit with its own
gates and its own re-session. Never bundle a tuning change into the
instrumentation commit — that destroys the before/after comparison.

## Job 7 — owner-initiated lanes (preempt everything above, at his word only)

- **Audio asks 5–9** (`drafts/_m5a-verdict-20260818.md` §Ear-check 2 +
  ask 9): −4 dB percussive · dodge take curation · zone-change render +
  ping repurpose · 32-bar evolving ambient · ranged-shot cue. Runs
  first if he opens it; context guard 40%.
- **The v19 brainstorm.** If the owners open it, you are the dev of
  record at the table: bring the 10 recorded inputs from the checkpoint
  (lag first, R-A1…R-A4, flywheel R1–R7, T3/T4 order, the 7 intake
  ideas, corpus brief), propose ONE recommended order with reasons, and
  defend it with touchstones — then execute their call. Do NOT open v19
  yourself.

## Laws that bite

- **Measure before tuning.** No pacing/balance/netplay value moves in
  this session's commits.
- **Determinism is the ship-gate:** flag OFF ⇒ byte-identical replays;
  flag ON ⇒ netplay gates still PASS. A timing read that touches the
  digest or the wire is a desync bug, not a feature.
- **Claims are not evidence** — every hypothesis in the doc carries a
  `file:line`, a log line, or an explicit UNVERIFIED tag.
- Read-before-edit · one-concern commits with explicit paths (never
  `git add -A`) · hooks run the suite · `git pull --ff-only` before
  push · rebase docs-only Junior commits after reading them.
- Gate runs detached (~5 min each; a bash timeout killed a critic once
  and produced a false negative) — poll by process count and judge
  disrupted gates by a standalone re-run.
- Bots advise; gates decide; a bot log is never fun-evidence.
- Owner overrides are law the moment they land in chat — record in ONE
  line, never re-litigate.

## Budget + stop conditions

One attended session, ~2–3 h. Council 0 by default (ONE consult allowed
only if Job 1's reading and the code genuinely contradict each other);
Bedrock spend = the gates' vision critic only; no fan-outs, no
sub-agents. **Stop when:** forensics correction committed + instrumentation
shipped behind gates (wall + 3 netplay + perf green) + soak receipt +
Job 5 staged or harvested → checkpoint + owner queue es-CR (~5 líneas)
→ push → STOP. **Stop early and report honestly if:** the code reading
kills the design premise (re-plan, do not force), a gate fails and the
fix is not small and mechanical, or the owner redirects (his word is
law).
