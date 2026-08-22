# game-two — Ruby+Gosu grid ARPG (monster flip)

Two human PEERS own and direct this project together — **Gabriel** (owner-founder,
es-CR) and **Junior** (co-creator, pt-br). Both play, both report, both contribute
with full creative freedom: design, code, audio/assets, ideas — neither is the
other's worker. Each seat's agent is the **dev of record for its session**: it
proposes, defends (touchstones, never rubber-stamps), and executes; it logs
reasoning and ships testable builds without asking permission for design calls.
Vision disagreements get settled by the humans in chat; ratifications land in the
hub chat and get RECORDED here or in the checkpoint.

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

## Operating model (owner-set 2026-08-19 — "no te cierres ni te limites")

- Gabriel + Junior DIRECT the project as peers (creative vision,
  priorities, what gets built next); ideas and contributions flow from
  BOTH seats with equal standing — intake, triage, and banking treat them
  identically. The dev of record PROPOSES, DEFENDS, and EXECUTES
  (design calls argued with touchstones, never rubber-stamped). Owner
  overrides are LAW the moment they land in chat — recorded in ONE line
  (here or the checkpoint), never re-litigated (precedents: M5a 2026-08-18,
  flywheel 2026-08-19).
- TWO things never relax, under any override:
  1. **Deterministic quality gates** — suite green via hooks; every visual
     change through the blocking Rule 2 gate; wall owed when visual
     surfaces move; bots/critics advise, gates decide.
  2. **Measurement hygiene while a fun-verify is pending** — ritual
     questions virgin, TELEMETRY oracle wording + runsheet + JUNIOR.md
     frozen, bot logs never fun-evidence, verbatim means verbatim, and the
     SIM numbers the pending ritual measures (respawn/difficulty/sustain)
     wait for its verdict.
- Everything else is steerable at the owner's word: lane order, freezes,
  scope promotions. Less rigidity ≠ less order: one-concern commits,
  evidence banks, forks close at brainstorms (dev recommendation + owner
  veto, v13 precedent).

## Current cycle — v18 (persistent world, etapa 1) + the quality flywheel

**v18 state:** all three lanes SHIPPED (coop feel · persistence v1 ·
god-view v0; foundation `drafts/_v18-foundation-20260817.md`; forks F1–F7
closed 2026-08-17).

**ADJUDICATED 2026-08-20 — the SEVENTEENTH is CUMPLIDO, v18 CLOSES**
(Half A 5/5 from banked bytes · Half B 8/8, both seats independently
reported the world continued · routing rows 3/4/6/9 TRIGGERED as
RECORDED items, rows 1/2/5/7/8 not · caveats named: same-day spacing +
symmetric audio novelty · lag = owner-named blocker, FIRST in the
post-verdict queue): `drafts/_v18-fun-verify-verdict-20260820.md`. v19
opens at the owners' brainstorm, not here.

**Lane 2 — quality flywheel (owner-directed 2026-08-19; contract:
`drafts/_quality-flywheel-plan-20260819.md`):** soak zone-coverage (all
six zones, seeded scratch saves, bot audio) · deterministic clips +
self-eval critique · verified renderer/data fixes ONLY (sampling-artifact
law: every critique claim verified against code + exact frames before
becoming a work item; sim-touching candidates = v19-class, RECORDED) ·
audio tuning on owner ask (drone ambient + −6 dB shipped `d91281a`;
attack-cue spec staged: `drafts/_audio-cue-spec-attacks-20260819.md`).

**Lane 3 — world-builder pipeline (owner-directed 2026-08-19, ratified
in chat — "Approved, I agree"):** the existing six-zone world is the
game's INTRODUCTION ARC (owner framing — the "tutorial dungeon");
expansion grows outward from it through an authoring pipeline: external
pro editor front-end (LDtk lead, Tiled fallback) + strict importer to
zone JSON + hot-reload preview loop + floors (typed transitions:
stairs/holes/rope; zones ARE floors) + region data layer + tile-type
registry (tile grammar: render + footstep audio + behavior hooks).
SAFE behaviors (decorative variants, footstep materials, region
ambience) ship in this era; SIM-CLASS tile behaviors (lava, water,
tile-gated spawns) are post-verdict increments, one gated piece at a
time. Live in-game god-mode editing stays the staged later rung (2026-
08-17 vision-drop staging unchanged). Spec CLOSED:
`docs/superpowers/specs/2026-08-19-world-builder-pipeline.md` (grill
record `drafts/_world-builder-grill-20260819.md`). Ticket state: T1 GO
(s19) · T2 importer+schema v2 (s20) · T3 safe behaviors SHIPPED (s26)
· **T4 pilot authoring SHIPPED (s27)** — ZONE 7 (town hub, THE WELL) +
BASEMENT 1/2 + DUNGEON 1 authored in LDtk through the importer ·
**T5 wire-in SHIPPED (s28, 2026-08-21) — D12 COMPLETE, THE WORLD IS
JOINED**: the ratified edge pair low_quay [44,19] ↔ zone_7 [1,14]
(`requires_defeats: 1` — the owners' EARNED `boss_1_defeats: 1` in the
shared save opens it on their next play; the return is free). zone_7
side authored through the door (provenance pin re-emitted); INERT law
amended to NAME the completion (basements/dungeon_1 inert both ways;
grass_fixture inbound-inert — its T3 outbound dev edge predates T5);
`multi_floor_descent.json` joined the wall (rope +
stairs both ways + town render + the LOCKED slab on camera + the
mechanical refusal). FULL WALL PASS 21/21. Ticket:
`drafts/_wb-t5-wirein-20260821.md`. Same session: the frame-tail
trigger FIRED (Junior's banked numbers) → draw diagnosed + the
merged-static-runs render fix shipped (`dd8ff40`, captures
byte-identical to pre-change baselines) — **re-measure VERIFIED on the
decisive seat 2026-08-21 (draw p95 15.3→8.5 ms, over20 16.8%→5.15%,
"muito mais leve"): frame-tail row CLOSED**
(`drafts/_junior-remeasure-20260821.md`). Typed transitions live (rope = interact under the
gate-consent law, holes/stairs auto-fire). **First human crossing
LANDED 2026-08-21** (Junior, his solo live save; varekka slain, town
walked, clean quit — `drafts/_junior-primeira-travessia-20260821.md`);
the shared-save crossing is still ahead.

**Owner-pending (never nag):** EAR-CHECKS of the audio-v12 batch
(evolving calm loop · zone-change · tailed throws · ask-5 levels) — ride
his next play session · the v19 brainstorm at the owners' word.

**Audio (M5a, SHIPPED 2026-08-18):** pure sink (never sim/saves/netplay),
OPTIONAL at boot (absent/refused = one named line, game runs silent),
owner originals only. Verdict + deferred lanes:
`drafts/_m5a-verdict-20260818.md`. **Asks 5–9 EXECUTED 2026-08-20**
(cue −4 dB · dodge curation 8→4 · evolving 64 s calm loop, rotation
dormant · new zone-change render, ping remap PARKED with v19 · throws
with baked 1800 ms tails); sources banked in
`game-two-audio/handoff/audio-v12/`. Queued on owner word: stereo
ambient stems + region-acoustics (dry cues + engine reverb) — library
increments. Cycle history (v17 close, M5a story, ritual amendments):
checkpoint + `git log --follow -- AGENTS.md`.

**Seats:** Gabriel's hub session (this machine) + Junior's seat (his machine,
Claude — CLAUDE.md points his sessions at this same contract). Working
language: English; player surfaces es-CR / pt-br. Junior's seat is a FULL PEER
seat — code, design, creative direction, playtesting, CI — under the same laws
as every seat: pull before push, hooks run the suite, gates block ships,
handoffs via drafts/ + `swarmforge handoff validate`. His machine specifics +
pt-br surfaces + agent-session protocol: `docs/JUNIOR.md`.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
always-online/server-authoritative world (named trigger recorded);
in-game world editing, map view, teleport; character creation/
appearance; item/equipment system; in-game chat/channels; >2 players;
assets integration (gated on game-two-assets pipeline maturity);
rollback/resync; open-internet play (Tailscale = trusted overlay
only); BOSS-1-dread iteration (OPEN-FOR-EXPOSURE — zero code owed);
all lore/creative writing (standing order above); in-game rebind UI.
v19 intake (7 ideas banked): `drafts/_junior-v19-ideas-20260819.md` —
v19 opens at the post-verdict brainstorm, not before.

## Human-facing surfaces

- **Surfaces**: zone banners, wipe/victory lines, controls strip labels,
  overlay verb text, in-game locale strings (en/es/pt-br), error messages.
- **Audience**: the two peers themselves (Gabriel es-CR, Junior pt-br) — a
  hobby project played by its makers.
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
- **Soak (v18 session 8; zone coverage 2026-08-19):** `rake soak [N=episodes]
  [TICKS=min] [SEED=base]` — two seeded bots (host+joiner, real processes over
  loopback/Tailscale) play N episodes on a SCRATCH save under `tmp/soak/<run>/`;
  `soak/chain_check.rb` judges LOGS + exit codes only (reason=quit, desyncs=0,
  ticks≥target, digest chain, sessions +1). Env extensions (run_soak.sh header):
  `ZONES=a,b,c` = episode i starts both seats in zones[(i-1)%len] (bot-gated
  `--start-zone`; chain_check asserts START_ZONE both seats + combat outside
  hubs) · `SEED_SAVE=1` = pre-seed the scratch save (banked=60, provisions=3 —
  real sustain buys) · `SOAK_AUDIO=1` = bots boot the real mixer in noDevice
  mode. Quarantine is mechanical: `--bot` in a save-owning seat refuses without
  `--save`, and the run fails NAMED if `saves/world.json`'s md5 or the temp-dir
  log count moves. **A bot session is never oracle evidence** — fun-verify
  harvests judge human launcher logs only.
- **Flywheel clips + critique (2026-08-19):** `harness/make_clip.sh
  harness/scripts/<name>.json [every_n] [out.mp4]` — deterministic MP4 from a
  wall script (env-gated VIDEO_EVERY frame dump; the wall never sets it — gate
  behavior byte-identical; never run beside a live seat or soak). Critique:
  `python harness/self_eval.py tmp/clip_<…>/video ["<focus>"]` →
  `drafts/_self-eval/<clip>_critique.md` (structure-vs-asset persona, spend
  rails ~$2-5/clip). **Sampling-artifact law:** critics see ~4% of frames —
  every claim is verified against code + exact frames (read the PNGs) before
  it becomes a work item.
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
  humans manage everything through that one chat. Sibling-repo fan-outs (lore / assets — banking-only
  while their standing orders hold; audio — order LIFTED 2026-08-18, integration queued
  behind the SEVENTEENTH) run as bounded headless sessions
  per the `seat-orchestration` skill: routes decided in a drafts/ triage doc FIRST,
  prompts digest-stamped (md5), free seats only, one pass per spoke, `RECEIPT:` paths
  harvested back into the routing doc. Spokes surface exactly two things for humans: seat
  conflicts and failed receipts. Junior's agent-session protocol: docs/JUNIOR.md
  §"Sessões com agente".

## Controls

WASD / arrows = move · Ctrl (hold) + direction = stationary aim (face without
stepping; dodge stays live) · J / Space = attack · K / Shift = dodge · L / E = special ·
; / Q = mark · U / R = provision (buy at bank / use afield) · H / F = interact ·
Tab = swap possession · Esc = quit

Timebase: `Window#update` = exactly one sim tick (tick-locked; replays deterministic by tick
count). Under load the game slows rather than skips — the top-right overrun counter makes
that visible, so a sluggish playtest is a perf signal, not a balance signal.
