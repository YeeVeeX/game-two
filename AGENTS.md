# game-two — Ruby+Gosu grid ARPG (monster flip)

The dev agent is the **dev of record** (design calls are the dev's to make and defend); owner is the
**tester** (plays builds, reacts, reports). Log reasoning, ship testable builds, don't ask
permission for design decisions.

## Scope contract (the #1 Kethral failure was ignoring this — it is enforced here)

**One cycle lives in this file.** Previous cycles: `git log --follow -- AGENTS.md` +
specs in `docs/superpowers/specs/`; verdict/telemetry narratives live in
`drafts/`, never here.

**STANDING OWNER ORDER (2026-08-16) — NO LORE IN THIS REPO.** All lore,
fiction names, and creative writing are REMOVED from the project and repo
(preserved outside: `C:/Users/gabri/workspace/game-two-lore/`). Every
player-visible name/line is a generic placeholder: ZONE 1..5, HUB 1,
BOSS 1, player 1/2/3, TOLL PAID, BOSS 1 SPAWNED/DEFEATED, MARK LOST.
The v16 language lane is TERMINATED (no 3-probe, no grounded candidates,
no ES/PT authorship). This repo is mechanics + engine only; if creative
writing ever restarts, it restarts OUTSIDE this repo (from the archive
folder) — never here. Placeholder
changes are still Rule-2 visual changes (wall + recalibration apply).

v18 (2026-08-17, owner ratified — "yes approved"): **THE PERSISTENT
WORLD CYCLE — etapa 1.** v17 closed the same day: the SIXTEENTH
adjudicated **CUMPLIDO** on both halves (Half A: 89575/89577 ticks,
desyncs=0 both seats, reason=quit both; Half B: "juntos" sí/sim asked
separately, verdicts "muy divertido"/"muito bom jogo"; verdict file
`drafts/_v16-fun-verify-skeleton-20260816.md`'s successor
`drafts/_v17-fun-verify-skeleton-20260816.md`). Owner vision drop
(persistent shared world, editor/god view, character persistence)
routed in PARKING_LOT.md; always-online = architecture fork, PARKED
with a named trigger (different-time play or a third player).

**IN scope (three lanes, one increment — foundation:
`drafts/_v18-foundation-20260817.md`):**
- **Coop feel** — respawn/pacing/difficulty made seat-count aware
  (SIXTEENTH Q3a + Junior's "não parece tão dificil" + AI third-body
  suicides = one item); **priced mid-hunt sustain** (owner law
  2026-08-11: spend banked value, portable, never a free cooldown).
- **Persistence v1** — world+character state survives sessions:
  host-authoritative save, transferred + digest-checked at the
  handshake (fingerprint-law extension); save/load round-trips the
  deterministic sim; schema-versioned, mismatch = named refusal.
  Re-opens D0's "banked session-only" BY OWNER ASK.
- **God-view v0** — OFFLINE full-map artifact only (rake task → PNG
  from data+save; Rule 2 applies to the artifact). In-game map/
  teleport/editing stay parked.
- **Design forks close at the brainstorm** (dev recommendation + owner
  veto, v13 precedent): F1 what persists · F2 save custody · F3 banked
  persists · F4 solo advances the shared world · F5 pacing shape ·
  F6 sustain verb · F7 god-view scope — positions in the foundation.

**Oracle (the SEVENTEENTH ask, two halves):** (A) PERSISTED — two real
sessions on different days, session 2 provably resumes the same world
(save digest chain + zero desyncs across both + a carried fact in
telemetry); (B) FELT — both players asked separately: did the world
feel continued, did the respawn/sustain frictions disappear.

**Seat:** dev of record = the main session. Working language: English.
Junior's seat is ACTIVE (CI, PT-BR functional labels, playtesting) —
pull before push, always; parallel-session handoffs via drafts/ +
`swarmforge handoff validate`.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
always-online/server-authoritative world (named trigger recorded);
in-game world editing, map view, teleport; character creation/
appearance; item/equipment system; in-game chat/channels; >2 players;
assets integration (gated on game-two-assets pipeline maturity);
rollback/resync; open-internet play (Tailscale = trusted overlay
only); BOSS-1-dread iteration (OPEN-FOR-EXPOSURE — zero code owed);
all lore/creative writing (standing order above); audio (owner order);
in-game rebind UI.
**Nothing new starts until v18 is fun-verified (the SEVENTEENTH ask).**

## Human-facing surfaces

- **Surfaces**: zone banners, wipe/victory lines, controls strip labels,
  overlay verb text, in-game locale strings (en/es/pt-br), error messages.
- **Audience**: hobbyist player (owner) + friend (Junior, PT-BR).
- **Register target**: generic-videogame placeholder + functional UI
  (owner order 2026-08-16). No diegetic register, no fiction voice.
  Placeholder names are locale-invariant; only functional verbs translate.
- **Disclosure needs**: N/A (no AI-interaction surface in-game; single-
  player hobby project, not a commercial product).

Ship-gate: language critique (accuracy vs presentation, separate axes) is
blocking at ship per global Rules 2/6; checklist in the `human-facing-output`
skill.

**Authorship (superseded 2026-08-16): the language pipeline is
SUSPENDED with the lore program.** Player-facing text = placeholders +
dictionary-word functional labels only; anything beyond that is out of
scope for this repo. (Historical pipeline: see git history of this file.)

## De-slop + comprobations (owner-set 2026-08-09)

- **Names are placeholders (owner order 2026-08-16).** Player-visible names/lines are
  generic (ZONE N, BOSS 1, player N); internal identifiers are mechanical (striker,
  district, seal). No fiction names anywhere in code, data, or docs.
- **Reference wall:** every design idea cites a touchstone (Tibia research/footage in
  `drafts/`, Vlambeer juice) — for systemic-design topics query the verified shelf FIRST:
  `hub kb query --domain game-research "<topic>"` (tiers + pipeline:
  `docs/design-corpus/systemic-worlds-research-shelf.md`; FLAGGED numbers never land in
  `data/` without re-verification). Serves none → PARKING_LOT.md.
- **Every commit changes what the player sees, hears, or feels.** A system that can't be
  felt in a capture doesn't merge.
- **Judge builds, not briefs.** Everything converges to a playable build + captured frames.

## Non-negotiables (from the Kethral post-mortem)

1. **Orchestrator cap:** `src/app/window.rb` ≤ ~300 lines. Systems talk via the event bus
   or they don't ship. (kethral/game.py hit 2,663 lines with a bus available.)
2. **Rule 2 is a blocking ship-gate:** every visual change is verified by scripted replay
   + frame capture + vision critique BEFORE it ships. Never eyeball loops.
3. **Data-driven:** all tunable values live in `data/**/*.json`. Zero balance constants in code.
4. **Events are registered:** `EventBus::EVENTS` whitelists known event symbols — emit/subscribe
   on an unknown symbol raises. Define events when first used, NOT upfront (Kethral defined
   ~80 upfront; breadth-thinking).
5. **Tests:** minitest, `rake` runs them. No mocks in integration tests — real files, real Gosu.

## Environment (verified live 2026-08-09)

- Ruby 3.4.10 at `C:\Ruby34-x64` — **not on Git Bash PATH by default**; use
  `export PATH="/c/Ruby34-x64/bin:$PATH"` per shell.
- **No YJIT**: RubyInstaller builds without it (needs rustc). PRISM interpreter only —
  accepted deviation, adequate at this scale. Revisit ONLY if profiling shows drops.
- Gosu 1.4.6. Capture API verified: `Gosu.render(w, h) { draws } → Gosu::Image#save(path)`
  works on this machine (produces real PNGs). `Gosu.render` needs a live GL context —
  run captures inside a real `Gosu::Window`, not headless.
- Old repo (READ-ONLY reference): `C:\Users\gabri\Documents.stale-20260413\coding_projects_main\Game On(e)`
- Gemfile.lock is committed; gosu pinned `= 1.4.6`. ⚠️ rubygems ships no prebuilt
  x64-mingw-ucrt binary for gosu 1.4.6 — it compiled from source here via the RubyInstaller
  devkit; a fresh machine needs MSYS2/devkit installed before `bundle install`.

## Layout

- `src/core/` — engine-agnostic: event bus, state stack, data store, input abstraction, tile map
- `src/game/` — the sim: world (zones/transitions), player, enemy, grid walker, flow field, camera, feel
- `src/app/` — Gosu-facing: window orchestrator (≤300 lines), rendering
- `data/` — all JSON configs (`balance/`, `zones/`, `display.json`)
- `harness/` — Rule 2 replay runner + input scripts
- `soak/` — autonomous two-seat soak: orchestrator + log/chain checker (never under
  `harness/` — the wall stays single-player and persistence-blind)
- `captures/` — frame captures (gitignored)
- `test/` — minitest; `rake` = run all

## Commands

- `rake` — run all tests
- `bin/play` (Git Bash) or `bin\play.cmd` (double-click / cmd) — launch the game
- **Netplay (v17):** `bin/play [locale] --host [port]` / `bin/play [locale] --join
  <ip[:port]>` — lockstep co-op over Tailscale (port defaults from `data/netplay.json`;
  handshake refusal prints the differing field and exits nonzero). Esc = clean quit
  (both seats print `TELEMETRY netplay ...` + the relaunch command). Exit statuses
  (`App::Cli.exit_status`): 0 clean end · 1 crash/refusal · 2 link fault — the coop
  launchers (`bin/host-coop.cmd`, `bin/join-coop.cmd`) auto-rehost/rejoin ONLY on 2.
- **Persistence (v18):** the shared world lives in `saves/world.json` — host-authoritative,
  gitignored, written at clean quit ONLY (never hand-edit; strict decode refuses NAMED).
  `--fresh` = start over, composes with solo and `--host` (the existing save moves to
  `.bak-<ts>` FIRST — the backup law); `--join --fresh` refuses (the joiner never keeps
  the save). Coop pacing scalars: `data/balance/coop.json` (per-seat-count block; seats=1 =
  no block = no arithmetic).
- **Soak (v18 session 8):** `rake soak [N=episodes] [TICKS=min] [SEED=base]` — two
  seeded bots (host+joiner, real processes over loopback/Tailscale) play N episodes on a
  SCRATCH save under `tmp/soak/<run>/`; `soak/chain_check.rb` judges LOGS + exit codes
  only (reason=quit, desyncs=0, ticks≥target, digest chain, sessions +1). Quarantine is
  mechanical: `--bot` in a save-owning seat refuses without `--save`, and the run fails
  NAMED if `saves/world.json`'s md5 or the temp-dir log count moves. **A bot session is
  never oracle evidence** — fun-verify harvests judge human launcher logs only.
- `rake capture SCRIPT=harness/scripts/<name>.json` — deterministic replay + frame capture.
  One script per regression surface lives in `harness/scripts/` (the wall); trust the
  directory, not an inline list here (an inline list went stale once). Canonical entry
  points: `world_loop.json` (everyday loop), `low_quay_run.json` + `varekka_duel.json`
  (v15 wall; zone-start scripts use the `start.zone` param).
- `harness/run_wall.sh [tag]` — full wall sweep: every script in `harness/scripts/`
  through gate + manifest, teed logs in `tmp/wall/`, nonzero exit if any script fails.
- `rake gate SCRIPT=harness/scripts/<name>.json` — the BLOCKING Rule 2 gate: double replay +
  md5 compare + structured vision verdict (exit nonzero on any failure). `SKIP_CRITIC=1` runs
  the determinism half only (iteration aid, not a shippable pass). Optional `CHECKS=<file>`
  swaps the checklist — default `harness/gate_checks.json`, wall behavior untouched.
- **Netplay gates (v17):** `rake gate SCRIPT=harness/net/<netplay_session|netplay_desync|
  netplay_conn_lost>.json CHECKS=harness/net/gate_checks.json` — two real Worlds + two real
  Sessions over loopback inside the replay window (scene: `harness/scenes/netplay_scene.rb`;
  now_ms is a pure function of the frame — determinism law in the scene header). These live
  OUTSIDE `harness/scripts/` on purpose: the wall stays single-player.
- `rake map [SAVE=path] [OUT=dir] [PROBES=1]` — god-view v0: OFFLINE full-map PNG from
  data+save through the play-path strict decoder (refusal aborts NAMED; missing save =
  honest fresh state); filename carries digest provenance (`world_<digest8>_<ts>.png`).
  `PROBES=1` renders staged facts + pixel asserts — this surface's gate is probes +
  vision critique (`harness/map_checks.json`), no replay half (decision 13).
- `rake perf` — perf smoke (machine-local): district scenario, aborts if p95 tick >= 16.6 ms.
- `rake pilot NAME=<n> SEED=<s>` — interactive pilot session: append commands
  (`printf 'cmd\n' >>`, NEVER Write) to `tmp/pilot/<n>/inbox.txt`, read `log.txt`; idle =
  frozen sim; `export` emits a standard replay script. Full protocol: harness/pilot.rb header.

## Enforcement (wired 2026-08-11 — script-enforced, not prompt-requested)

- **Git hooks gate commits and pushes**: `.git/hooks/pre-commit` and `pre-push` both run
  `bundle exec rake` (with the Ruby PATH baked in) — bundle exec pins the Gemfile.lock
  versions; unbundled `rake` drifted from the lock once (2026-08-11, caught by Codex review).
  A red suite blocks the commit — that's the point; fix the test, don't `--no-verify`.
  Hooks are untracked: to reinstall, each is 4 lines — `#!/bin/sh` +
  `PATH="/c/Ruby34-x64/bin:$PATH"` + `export PATH` + `exec bundle exec rake`.
- **swarmforge** (the quality-gauntlet CLI, `C:/Users/gabri/workspace/swarm-forge`) is
  configured for this repo via `swarmforge.toml`: `gauntlet` runs rake as its test stage,
  `tdd-check` knows `{stem}_test.rb`. Invoke with
  `PATH="/c/Users/gabri/workspace/swarm-forge/.venv/Scripts:$PATH" swarmforge <cmd> --repo .`
  — useful for `tdd-check src/game/<file>.rb` (WARN-only heuristic) and
  `handoff validate` when multi-agent sessions exchange handoff files.
- `rake gate` stays the Rule 2 blocking ship-gate (unchanged); hooks don't replace it.
- **Process artifacts are tracked**: `drafts/` (verdicts, reviews, calibration history)
  lives in git — commit at cycle close. Only `drafts/_tibia-videos/` (media corpus) stays
  ignored. The wall runner is `harness/run_wall.sh`, never a tmp/ scratch copy.
- **Orchestration (owner-adopted 2026-08-18)**: the dev-of-record chat is the HUB — the
  humans manage everything through that one chat. Sibling-repo fan-outs (lore / assets /
  audio — banking-only while their standing orders hold) run as bounded headless sessions
  per the `seat-orchestration` skill: routes decided in a drafts/ triage doc FIRST,
  prompts digest-stamped (md5), free seats only, one pass per spoke, `RECEIPT:` paths
  harvested back into the routing doc. Spokes surface exactly two things for humans: seat
  conflicts and failed receipts. Junior's agent-session protocol: docs/JUNIOR.md
  §"Sessões com agente".

## Controls

WASD / arrows = move · J / Space = attack · K / Shift = dodge · L / E = special ·
; / Q = mark · H / F = interact · Tab = swap possession · Esc = quit

Timebase: `Window#update` = exactly one sim tick (tick-locked; replays deterministic by tick
count). Under load the game slows rather than skips — the top-right overrun counter makes
that visible, so a sluggish playtest is a perf signal, not a balance signal.
