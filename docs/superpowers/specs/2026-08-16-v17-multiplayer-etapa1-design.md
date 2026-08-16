# v17 — THE MULTIPLAYER CYCLE, etapa 1: live lockstep co-op (two seats, one deterministic sim)

Date: 2026-08-16. Owner ratified the cycle at the debate close ("ok procede
como recomiendes, lo apruebo"); all five design forks closed this session on
dev recommendation with owner approval ("aprobado, procede"). Working
language: English. Player-facing text: placeholders + functional verbs only
(standing order 2026-08-16).

**Oracle (the SIXTEENTH ask, two halves):** (A) did a real session with
Junior HOLD — arbiter = netplay digest counters on BOTH seats (desyncs=0,
honest end); (B) did it feel like playing TOGETHER — both players asked
separately, pre-registered questions below.

## Foundations (banked facts this design stands on)

- The sim is tick-locked: `Window#update` = exactly one tick; under load it
  slows, never skips. Sim p95 0.365 ms against a 16.6 ms budget.
- The sim reads no wall clock (grep-verified: zero `Time`/`milliseconds` in
  `src/game` + `src/core`); all randomness flows from two seeded streams
  (`@rng`, `@respawn_rng = seed ^ SALT`).
- Cross-machine sim-identity is PROVEN twice (etapa 0): same seed+inputs on
  two PCs → identical EVENT-stream digests, 3/3 scripts, re-confirmed on the
  placeholder line (`drafts/_junior-etapa0-20260815.md`, `-20260816.md`).
  Pixel-file identity is machine-local and is NOT the invariant.
- `Core::ScriptedInput` proves inputs-by-tick drive the entire sim — the
  input abstraction is the lockstep seam, already load-bearing for Rule 2.
- Link estimate BR↔US over Tailscale: RTT ~120-180 ms (banked at v13).
  Tailscale = trusted overlay, host+join only; open internet OUT of scope.

## Fork verdicts (closed 2026-08-16, dev recommendation + owner approval)

1. **Embodiment = SHARED PACK.** Two humans possess two different bodies of
   the SAME 3-body pack; AI drives the rest. Possession is already a pointer
   (`Pack#possess!`); the second player is a second pointer + input stream.
   Same fights, same bank, same stakes — serves oracle half B directly.
   Rejected: second pack (doubles actors, invalidates every balance
   intuition + telemetry lane), seat-swap (not simultaneous — fails half B
   by construction).
2. **Tick-sync = delay-based lockstep, fixed D per session.** Local input
   sampled at tick T is scheduled for T+D and sent immediately; tick T
   executes only when both seats' inputs for T are present, else the sim
   STALLS (0 ticks that update, counted, visible). D is negotiated ONCE at
   handshake from a measured RTT probe and never changes mid-session
   (adaptive D = a desync mine; parked). Transport = TCP with TCP_NODELAY
   over Tailscale (Ruby stdlib, minimal surface); UDP+redundancy parked as
   an etapa-2 latency optimization.
3. **Bootstrap = host/join + verified manifest.** Host listens on its
   tailnet IP; joiner connects. Handshake exchanges protocol version, Ruby
   version, sim fingerprint, seed (host picks), D, digest cadence N. Any
   mismatch = refuse to start and print exactly what differs (the
   bindings.local.json error philosophy). READY→START barrier; ticks
   0..D-1 consume empty inputs for both seats by definition.
4. **Desync policy = detect LOUDLY, end honestly.** State+event digest
   every N ticks, exchanged over the same connection, compared when both
   sides hold the pair. Mismatch = freeze, DESYNC screen, desync report
   written on both seats, session ENDS. No rollback, no resync, no rejoin
   (etapa 2+ material, parked). The desync counter on both seats' summary
   lines is oracle half A's arbiter.
5. **Latency budget + abort.** D = clamp(ceil(median_RTT_ms/2 / 16.67) +
   jitter_margin(3), 4, 12) ticks, median over probe_count=5 RTT probes;
   probe failure → default 8. Computed D above the clamp → start anyway
   with a loud LINK SLOW warning (trusted seats decide). Abort (Codex fold
   #3 — stall time is WALL time, ticks don't advance during a stall):
   continuous stall > abort_stall_ms (10000) on the app-layer monotonic
   clock, or socket death, = CONNECTION LOST, honest end with summary.
   Stall counters report stalled updates + elapsed ms; the sim never reads
   the clock. `rake perf` stays single-player; netplay overhead is
   measured in the two-sim lane.

## Design decisions (numbered; the laws reviews should attack)

1. **Sampling law (Codex fold #2).** In netplay mode the LOCAL keyboard is
   sampled into a 10-bit action mask (`left right up down attack dodge
   special mark interact swap` — bit order pinned in `Net::PROTOCOL`)
   exactly ONCE per EXECUTED sim tick: executing tick T samples and submits
   the mask for slot T+D, then never again for that slot. A stalled update
   executes zero ticks and therefore samples NOTHING — it only pumps the
   socket (re-sampling per update would let peers consume different values
   for the same slot). A received duplicate slot with a differing mask is a
   protocol fault ⇒ session ends (reason=protocol). BOTH sims consume
   frozen masks (`Net::SampledInput`, ScriptedInput semantics); live
   `KeyboardInput#down?` re-reads hardware mid-tick and must never reach
   the sim in a lockstep session. Single-player path keeps live reads
   (unchanged). Deadlock-free by construction: each seat has always
   submitted D slots beyond its own execution point.
2. **Seat-order law.** The sim consumes seats in PINNED order — seat 1 then
   seat 2 — on both machines. Iterating "local seat first" would diverge
   the machines. Every per-seat loop in World is ordered by seat id.
3. **Same-tick swap arbitration.** Seat 1's Tab resolves before seat 2's
   (seat order); `swap_next!(seat)` skips the body possessed by the other
   seat; `forced_swap!(seat)` picks the nearest living body EXCLUDING the
   partner's; if none exists the seat enters WAITING-FOR-BODY (spectate:
   camera follows the partner; inputs ignored; auto-repossess at the first
   revive/regrow, roster order). Death resolution at bus-process time
   iterates seats in seat order, exclusion-aware; `pack_wiped` fires
   EXACTLY once per wipe (guarded on the state transition — two controlled
   bodies dying the same flush must not double-emit or double-transition,
   Codex fold #6). Judgment assigns seats over the ACTUAL revived set in
   seat order (the one-vessel floor can revive a single body: seat 1 takes
   it, seat 2 waits-for-body until regrow/next judgment — honest, recorded
   as a half-B feel risk).
4. **One pack mark, last write wins.** Both seats can set the mark (it
   steers the one AI body); no per-seat marks. Both seats can fire shared
   economy verbs (bank/tribute/inscribe) — trusted-friend co-op, no
   anti-grief mechanics.
5. **Per-seat cameras INSIDE World.** `World#tick` today ticks the camera
   between `tick_world` and `bus.process` — moving that call after
   `bus.process` (app layer) would change captured frames on forced-swap
   ticks (bus-process moves possession). So World owns `cameras[seat]`,
   ticked at today's exact call site with each seat's possessed center;
   the renderer draws through the LOCAL seat's camera. Single-seat path
   constructs only camera 1 → byte-identical by construction. Cameras are
   presentation state: excluded from the digest vector.
6. **Digest = ALL events + consumed inputs + authoritative state snapshot,
   every N ticks (Codex fold #1).** Rolling digest per window folds:
   (a) EVERY registered bus event (`EventBus::EVENTS` whitelist is the
   subscription source — not world_scene's curated list, which misses
   registered events), serialized through ONE shared helper extracted from
   `WorldScene#describe` (world_scene re-uses the helper so its EVENT lines
   stay byte-identical — the proven cross-machine serialization);
   (b) the consumed input masks per executed tick (catches input-delivery
   divergence at the source); (c) at the boundary, a VERSIONED canonical
   state snapshot (`digest_version` in the handshake): arrays only, stable
   actor ids (roster index for pack, spawn-order id for humans), covering
   every gameplay-affecting field — frame, zone id, state-stack top,
   banked, hitstop counter, per-pack-member (id, tile, reserved_tile,
   walker progress, hp, alive, stagger, exhaust/cooldown clocks, action
   state+frames, seized_by, marked?, carried value), possession map
   (seat→id), pack mark target id, per-human (id, kind, tile,
   reserved_tile, hp, action state, taunt/leash/retarget state, chant
   state), projectiles (pos, dir, ttl), drops/corpses (tile, value, decay
   clocks), respawn queue + telegraphs (tile, countdown), and the DRAW
   COUNTS of both rng streams (panel fold, DeepSeek+Qwen: raw
   Marshal.dump(Random) bytes are not a documented-stable serialization —
   instead each stream is wrapped in a trivial counting delegate
   (`CountingRng`: rand → count+=1, delegate — returns the SAME values, so
   wall byte-identity is untouched by construction). A diverged rng
   manifests at its next draw through positions/drops/spawns already in
   the snapshot, so detection lag is at most one window — same class as
   every other field.) Each object serializes
   itself (`digest_fields` — a FLAT array of named scalars; the
   mutation-sensitivity sweep enumerates those names and flips each
   through the same schema, so an uncovered name cannot hide).
   Presentation clocks (banners, stamps, pops, cameras) are excluded —
   they feed no sim branch (verified: no sim system reads a camera; the
   spec pins that as a standing prohibition). A MUTATION-SENSITIVITY test
   drives the snapshot: flipping any single covered field must flip the
   digest (catches accidental omissions structurally).
7. **No threads.** All socket I/O is nonblocking on the main loop
   (`read_nonblock` + drained writes), in live play AND in tests. A thread
   is its own flake/desync source; etapa 1 ships without one.
8. **Desync artifact + termination state machine (Codex fold #4).** The
   sim runs ahead of digest comparison (compare happens when both sides
   hold a boundary's pair), so every UNRESOLVED boundary retains an
   immutable record (boundary tick, snapshot, window event lines) until
   its peer digest arrives and matches — bounded by construction to
   ceil((D + RTT_ticks)/N) + 1 boundaries (2-3 in practice). On mismatch:
   halt tick admission, send DESYNC{tick}, keep pumping until the peer's
   DESYNC/ack or a 2 s drain timeout, and only then write
   `tmp/netplay/desync_<session_id>_tick<B>.json` (manifest, boundary
   tick, own+peer digest, retained snapshot, window event lines) on BOTH
   seats and end. Clean quit: Esc sends BYE{quit}, drains for ack with the
   same bounded timeout, then closes; BOTH seats record reason=quit
   (initiator and receiver — the oracle needs no initiator distinction).
   When end causes RACE (e.g. socket dies mid-desync-drain — DeepSeek
   fold), reason precedence is desync > protocol > conn_lost > quit, and
   the oracle reads a desync artifact on EITHER seat as half-A failure
   regardless of the peer's recorded reason. After any honest end the app
   prints the exact relaunch command for both seats (re-host/re-join
   friction is emotional cost — Kimi fold — minimized within the no-rejoin
   law). Junior shares his artifact; the diff is the work item ("bank the
   diff, don't average it" — etapa-0 doctrine).
9. **Netplay layer lives OUTSIDE the sim.** New `src/net/` (protocol,
   sampled input, lockstep scheduler, digest, wire, session). The sim bus
   stays sim-pure: no netplay events in `EventBus::EVENTS`; the session
   counts its own stalls/desyncs and prints its own TELEMETRY line. Window
   orchestration cost ≤ ~30 lines (cap law).
10. **Seat identity is RINGS ONLY — no body relabel (Codex fold #9,
    REVERSES the draft's BODY 1/2/3 decision).** The ratified placeholder
    set (AGENTS standing order) names the bodies "player 1/2/3"; renaming
    them would amend an owner-ratified contract AND churn every banked
    wall capture — directly at war with this cycle's byte-identity canary
    law. So: body labels stay untouched; seat identity is carried by the
    partner ring (distinct color, `display.json`) and netplay text avoids
    the collision entirely by using PARTNER wording (`WAITING FOR
    PARTNER`, never `WAITING FOR PLAYER 2`). If the owner ever orders a
    body relabel, it is its own increment with its own recalibration
    window.
11. **Seat semantics table (Codex fold #5 — the bare-`possessed` call
    sites get explicit two-seat rules).** World gains `controlled_bodies`
    (seat-ordered), `seat_for(creature)`, `controlled?(creature)`; the
    rules, pinned: AI dispatch drives every living body NOT controlled;
    interact/mark/special guards accept the acting SEAT's own body
    (`source.equal?(possessed)` generalizes to `seat's body`); BOSS-1
    seizure targets the NEAREST controlled body (Chebyshev, tie → lower
    roster index — deterministic); zone gates require EVERY LIVING
    controlled body standing in the gate group before the transition
    fires (panel fold, Kimi: unilateral drag-along reads as "my friend
    deleted my agency" — co-location is the cheapest consent mechanism;
    dead/waiting seats don't block; the blocked gate shows a functional
    cue, `WAITING AT GATE`); fight/ledger
    attribution stays pack-level (already pack-scoped); hitstop stays
    global sim state (both seats' kills pause both machines identically);
    camera shake remains world-owned and deterministic (identical on both
    machines, applied through whichever camera renders);
    `kit_first_possessed` pulses on first possession by ANY seat (accepted
    cosmetic simplification).

## Sim spec (seat plumbing — byte-identity is the contract)

- `World#tick(inputs)` accepts `{1 => input}` (or a bare input, wrapped) —
  single-seat calls behave EXACTLY as today. Two-seat: per-seat controller,
  per-seat `@swap_was_down`, per-seat rearm on possession change, seat-order
  law everywhere. `World#possessed` (bare) stays = seat 1's body (existing
  call sites unchanged); `possessed(seat)` added.
- `Pack` gains the seat map: `possessed(seat)`, `possess!(seat, body)`,
  `swap_next!(seat)`, `forced_swap!(seat)` with partner exclusion; bare
  arity = seat 1 (back-compat).
- Seizure, stagger, hitstop, stamps, pops: keyed on creatures, with the
  seat rules of decision 11 closing every singular call site (mark/
  interact guards, AI dispatch, seizure targeting, zone gates, death
  handling). The seized-Tab exemption applies per seat.
- **Renderer seam (Codex fold #7):** `local_seat:` flows through Renderer
  AND ControlsOverlay (default seat 1 — single-player byte-identical by
  default); HUD anchor, possession ring, stagger veil, station ledger,
  edge pips, and the strip all read the LOCAL seat's body; the partner
  ring reads the other seat's.
- **Canary (blocking, Codex fold #8 — the mechanism is `rake canary`,
  which compares fresh captures against a PRESERVED BASELINE dir; `rake
  gate` only compares two fresh runs):** BEFORE the seat refactor, bank
  local baseline captures for EVERY wall script (one replay each into
  `tmp/canary_baseline/<script>/`); after each seat-plumbing increment,
  `rake canary SCRIPT=<s> BASELINE=...` across the full set — byte
  identity means every banked wall verdict still stands (v16-scaling
  precedent); ANY divergence is a broken refactor: fix, never
  recalibrate. Fast in-suite leg: headless world_loop / varekka_duel /
  burn_duel event-stream digests equal the banked etapa-0 md5s
  (`a4150c…`, `22dbad…`, `d148b8…`) — a minitest drives the world
  through each script's inputs WITHOUT Gosu render (<2 s each).

## Netplay spec (src/net/)

- `Net::PROTOCOL`: version=1, action bit order, digest_version, line-JSON
  framing — every message ONE newline-terminated JSON line, max 4096
  bytes; reads are buffered (split/coalesced lines handled), writes retain
  partial buffers across pumps; EOF or oversize mid-frame ⇒ conn_lost.
  Messages: HELLO, PROBE/PROBE_ACK ×probe_count, SESSION, READY, START,
  INPUT{t,bits}, DIGEST{t,md5}, DESYNC{t}, BYE{reason}. A message outside
  its phase (state machine: LISTEN→HELLO→PROBE→SESSION→READY→RUN→END) is
  a protocol fault ⇒ honest end. ~20 B/tick ⇒ ~1.2 KB/s — debuggability
  beats binary at this scale.
- `Net::Fingerprint`: md5 over sorted (relpath, content-md5) of
  `src/**/*.rb` + `data/**` (EXCLUDING `data/bindings.local.json` —
  display-only, legitimately per-machine) + `Gemfile.lock` + RUBY_VERSION +
  RUBY_PLATFORM + protocol version + digest_version. Mismatch print names
  the differing field and hints `git pull` (the error reaches the person
  who must act).
- Handshake pins: host = seat 1 always; session_id = host-generated
  (seed ⊕ epoch, human-readable in artifacts); D derives from the MEDIAN
  of probe_count RTTs, host decides, SESSION carries it.
- `Net::Lockstep` (pure, no I/O): per-seat input queues, delay D, empty
  inputs for ticks < D, `ready?(t)`, stall counters (total, current run,
  max run), digest boundary bookkeeping, desync compare state machine.
- `Net::Session`: owns socket + Lockstep + StateDigest; `pump` (drain
  reads, flush writes), `submit_local(mask)` (once per executed tick),
  `advance?` → inputs for the current tick or a stall verdict; runs the
  termination state machine of decision 8; emits end states (:quit,
  :desync, :conn_lost, :protocol) and writes the desync artifact.
  **Windows pump discipline (Qwen fold):** exactly ONE drain attempt per
  update — `IO.select` zero-timeout probe, then `read_nonblock` rescuing
  `IO::WaitReadable` (spurious winsock readability is real), never a
  retry-spin inside update; `Errno::ECONNRESET`/`EPIPE`/EOF → conn_lost
  explicitly; partial writes retained in an outbound buffer across pumps;
  TCP_NODELAY verified via getsockopt after set (setsockopt can fail
  silently); `accept_nonblock` guarded the same way during LISTEN.
  Session pacing truth: lockstep runs BOTH machines at the slower seat's
  effective update rate — a slow machine shows up as the partner's stall
  time, visible in telemetry, and that is the honest signal.
  Summary line: `TELEMETRY netplay seat=N ticks=N desyncs=N stalls=N
  stall_ms_max=N reason=<quit|desync|conn_lost|protocol>` printed at close
  beside the sim summary.
- `data/netplay.json` (Rule 3 — zero constants in code): port 43117,
  delay {min 4, max 12, default 8, jitter_margin_ticks 3}, digest_every 60,
  stall_warn_ms 500, abort_stall_ms 10000, drain_timeout_ms 2000,
  probe_count 5.
- CLI: `bin/play [locale] --host [port]` / `bin/play [locale] --join
  <ip[:port]>` — BOTH launchers (`bin/play` and `bin/play.cmd`) forward
  all args past the locale (`"$@"` / `%*`); `src/main.rb` parses (window
  mode unchanged when no flag).

## Presentation spec (Rule-2 surfaces — every state lands in a capture)

Placeholder/functional text only; names locale-invariant; functional verbs
get es/pt-br dictionary translations in `data/strings/`.

1. Pre-session: `HOSTING — WAITING FOR PARTNER` (+port) / `CONNECTING…`
   full-screen states. Handshake refusal prints to console and exits
   nonzero (bindings-error precedent; no window state needed).
2. Partner ring: the partner seat's body carries a visually distinct ring
   (second color in `display.json`), readable against every zone palette;
   the local ring stays as-is. Body labels untouched (decision 10).
3. Stall overlay: after `stall_warn_ms` of continuous stall,
   `WAITING FOR PARTNER` + elapsed ms, top-center; the overrun counter
   stays untouched. LINK SLOW banner at session start when D clamped.
4. Desync screen: `DESYNC AT TICK <N> — SESSION ENDED` + report path.
5. Connection lost: `CONNECTION LOST — SESSION ENDED`.
6. Waiting-for-body: `NO BODY — WAITING` while spectating the partner.

Capture vehicle (Codex fold #10 — the states are mutually exclusive, so
ONE script cannot stage them all): a `harness/net/` FAMILY driven by a new
"netplay" scenario — TWO real Worlds + TWO real Sessions over loopback TCP
inside the replay window process, seat-1 view rendered; script keys stage
seat-2 inputs and fault injection:
- `netplay_session.json` — hosting/connecting beats, partner ring in
  motion, stall window (scripted pump freeze → WAITING FOR PARTNER),
  waiting-for-body beat, clean end;
- `netplay_desync.json` — forced divergence at a scripted tick → DESYNC
  screen;
- `netplay_conn_lost.json` — scripted peer death → CONNECTION LOST.
Gated via `rake gate SCRIPT=harness/net/<s>.json CHECKS=harness/net/
gate_checks.json` — the gate task grows an optional CHECKS= argument
(default: existing `harness/gate_checks.json`, wall behavior untouched —
the critic currently applies every check globally, so netplay checks MUST
live in their own file or the world-conditioned checks would misfire on
netplay frames, the moving_square lesson). Netplay checks are authored
ADD-ONLY in the new file. The scripts live OUTSIDE `harness/scripts/` on
purpose: run_wall's glob never sees them — **the wall stays single-player
and untouched.**

## Test lane (no mocks — real worlds, real sockets)

- Unit: protocol codec round-trip + framing (split/coalesced/oversize
  lines, partial writes, phase violations); SampledInput mask semantics;
  Lockstep (delay window, once-per-executed-tick submission, duplicate-slot
  fault, ready/stall, warn/abort thresholds, boundary retention bounds,
  desync state machine under late/bursty/reordered-delivery schedules);
  Fingerprint (local-bindings exclusion; content sensitivity); StateDigest
  determinism + sensitivity + the MUTATION-SENSITIVITY sweep of decision 6
  (every covered field, flipped, flips the digest).
- Integration (THE etapa-1 test): two Worlds + two Sessions over real
  loopback TCP in one process, scripted inputs on both seats, synchronous
  pumps (no threads), ~3k ticks: zero desyncs, digest streams identical,
  final TELEMETRY identical, then clean end. Divergence injection (poke one
  world's creature hp mid-run) ⇒ desync at the NEXT boundary, both ends
  reason=desync, artifacts written. Stall test: freeze one pump past
  abort_stall_ms ⇒ CONNECTION LOST both ends. Handshake tests: happy
  path, fingerprint mismatch refusal, probe→D derivation, START barrier.
  Perf print: measured per-tick overhead of session+digest (informational;
  generous ceiling assert ≤ 8 ms for BOTH sims + wire in-process). All
  test sockets bind 127.0.0.1 explicitly (avoids the Windows firewall
  prompt; CI-safe on ubuntu/xvfb — the lane is Gosu-free).
- Canary suite (sim spec above) rides the default `rake` run.

## Watched risks (pre-registered)

- **W1 Snapshot coverage drift.** New sim state added in a later cycle
  and forgotten in `digest_fields` = silent desync blindness. Mitigation:
  the mutation-sensitivity sweep is generated from the snapshot schema,
  and the desync artifact carries the full snapshot (a miss is
  diagnosable). RNG divergence is caught via draw counts + downstream
  state, never via Marshal bytes (panel fold).
- **W2 Seat-refactor byte-identity.** The full-wall `rake canary`
  baselines + the three headless digest canaries are blocking; a miss is
  a defect, never a recalibration.
- **W3 Real link worse than the estimate** (DERP relay fallback, wifi
  jitter) ⇒ stall-fest — and a lockstep stall FREEZES BOTH seats (the
  shared-punishment cost, recorded at the panel: in lockstep there is no
  asymmetric resilience without entering rollback-family tech, which is
  owner-parked). Mitigation: probe-derived D, LINK SLOW honesty, stall
  telemetry to diagnose; pre-registered routing: stall storms with clean
  digests at the SIXTEENTH → the answer is UDP+redundancy / etapa-2
  netcode debate, a higher-D re-session meanwhile — NEVER rollback creep
  inside v17.
- **W4 Sim-visible timing assumptions in app glue** (e.g. sampling after
  world.tick instead of before submit). The two-sim lane + canary catch
  ordering sins; the sampling law is the review's attack surface.
- **W5 window.rb cap pressure.** Session logic lives in src/net; the
  window adds sample→submit→pump→advance?→tick(≈30 lines). Cap test stands.
- **W6 Stale-line joins.** Junior on an old commit ⇒ fingerprint refusal
  with actionable print; JUNIOR.md gains the pull-before-play ritual.

## TDD increments (each green + committed before the next)

1. **Digest lane FIRST** (the safety net): shared event-serialization
   helper extracted (world_scene consumes it; EVENT lines byte-identical),
   `Net::StateDigest` + per-object `digest_fields` + mutation-sensitivity
   sweep, headless script-driver test helper + the three banked-digest
   canaries. THEN bank the full-wall canary baselines (one replay per wall
   script into tmp/, pre-refactor).
2. Seat plumbing: Pack seat map + World per-seat tick + the decision-11
   seat semantics + swap/death arbitration + waiting-for-body + judgment
   assignment + per-seat cameras + renderer/overlay `local_seat:` seam.
   Full-wall `rake canary` + headless digests stay green (blocking).
3. `Net::PROTOCOL` + SampledInput + codec.
4. `Net::Lockstep` pure scheduler (delay/stall/abort/desync bookkeeping).
5. `Net::Fingerprint` + wire + `Net::Session` handshake over loopback.
6. Two-sim integration lane (hold / divergence / stall / handshake tests).
7. App integration: CLI + launcher arg forwarding + Window session mode +
   all presentation states + partner ring ⇒ the harness/net script family
   + CHECKS= gate argument + gates (Rule 2, blocking) + netplay TELEMETRY
   line.
8. Docs + close: JUNIOR.md netplay section (PT-BR first: Tailscale install,
   invite, `--join`), AGENTS commands note, PARKING_LOT (UDP, adaptive D,
   rejoin), checkpoint. Suite + perf green throughout (hooks).

Commit-law note (recorded dev interpretation, Codex #12): increments 1-6
are substrate for ONE player-facing feature; each commits green as a safe
checkpoint on the shared line, and the cycle's visible payoff lands with
increments 7-8 + the live session. The "every commit changes what the
player sees/hears/feels" law is read at feature granularity for substrate
cycles — as prior cycles read it for telemetry/rename plumbing. Owner veto
window open as with every dev call.

## Fun-verify protocol (SIXTEENTH — pre-registered)

Session: owner hosts, Junior joins over Tailscale, ≥10 sim-minutes,
exit by Esc. Evidence harvested BEFORE questions, from BOTH seats: the
netplay TELEMETRY lines (Junior pastes his — drafts/ or message relay).

- **Half A (HELD)** — arbiter, mechanical: desyncs=0 on both seats AND
  reason=quit on both AND session_ticks ≥ 36000. Stall stats recorded
  (informational, feed half B's reading). Any desync ⇒ half A fails and
  the two desync artifacts become the next work item.
- **Half B (TOGETHER)** — both players asked SEPARATELY, no changelog
  shown. Owner (es): (1) ¿Se sintió como jugar JUNTOS, o como jugar en
  paralelo? (2) ¿Sentiste la espera/latencia? ¿Molestó? (3) ¿Algo se
  sintió injusto o roto? (4) veredicto global libre. Junior (pt-br,
  mirrored): (1) Pareceu jogar JUNTOS ou em paralelo? (2) Sentiu atraso/
  espera? Incomodou? (3) Algo pareceu injusto ou quebrado? (4) veredicto
  livre.
- **Routing, pre-registered:** desyncs>0 → digest-diff work item (etapa-1
  scope). Stalls felt + link diagnosis → D/link tuning re-session, never
  rollback; stall STORMS with clean digests → etapa-2 netcode debate
  (UDP+redundancy first candidate). "Paralelo, no juntos" with a clean
  hold → embodiment presentation debate at v17.1 (shared-goal cues), not
  auto-code. Latency named unfair → check D derivation before touching
  the sim. Either player naming the AI third body as weird/in-the-way →
  v17.1 embodiment debate item (Kimi watch), recorded not auto-built.

## Deliberately absent (recorded so review doesn't re-litigate)

Rollback/resync/mid-session rejoin (etapa 2+); adaptive/renegotiated D;
UDP + input redundancy; host migration; pause/resume; >2 seats;
spectators; chat/voice; open-internet play; matchmaking/lobbies beyond
host+join; per-seat marks; stealing the partner's body via Tab; split
local co-op; body relabels (BODY 1/2/3 considered and REVERSED at the
Codex fold — rings only); cross-locale string sync (each machine renders
its own locale — display-only); netplay entries in the wall
(single-player law); threads in the netplay layer.
