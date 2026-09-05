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

**One cycle lives in `docs/CYCLE.md`** (pointer section below); specs in
`docs/superpowers/specs/`; verdict/telemetry narratives live in `drafts/`,
never here. Session-by-session state: `docs/CHECKPOINT.md` (top entry =
latest; a CLAIMED line at ticket start).

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
- **OWNER ORDER (2026-08-22, Gabriel): development never gates on the
  other peer's availability** — solo progress is the default (peer
  online = good, peer absent = keep moving, symmetric both ways); the
  dev of record proactively surfaces REAL recorded work items every
  session (never fabricated ones — the no-manufactured-J1 law stands).
  Peer ratifications land async in the hub chat.
- **OWNER ORDER (2026-08-27, Gabriel, ratified in hub chat): PROGRAM
  RULE — game-two is the SINGLE flagship.** Satellite repos work only
  on a concrete game-two pull (commission/mail), then go back to
  sleep; ZERO new repos/projects open; new project ideas get RECORDED
  with a named trigger (parking-lot pattern at program level), never
  opened. Nothing is deleted or closed by this rule; reversal = one
  owner line. (Context: the owner named breadth as his own failure
  mode — this rule makes the discipline mechanical, not memory.)
- **OWNER ORDER (2026-08-28, Gabriel): FULL SEAT SYMMETRY** — Junior's
  role = Gabriel's: equal leadership over the game's development; both
  peers edit, iterate, and create at will, any time, any surface.
  Supersedes the map-lane directs/executes split (2026-08-27): either
  peer directs, either executes. Mechanical law stays seat-agnostic
  and unchanged — lawful edit paths, hooks, gates, claims, and
  fresh-eyes reviews bind WHOEVER lands the work.
- **OWNER ORDER (2026-08-28, Gabriel; ritual-cadence REFORM — applies
  from the NINETEENTH fun-verify onward, never retro-grading the
  eighteenth):** fun-verifies are **DELTA-TRIGGERED, never cycle- or
  calendar-mandated** — one is owed only when unverified
  player-facing SIM change has accumulated since the last verdict,
  or a peer asks for one. **Nothing new ⇒ no ritual owed**; a cycle
  may then close on its mechanical gates + one free-verdict line per
  peer. The measurement freeze arms at DECLARATION (not staging) and
  the declaration→verdict window TARGETS ≤48h (the eighteenth's
  six-day staged freeze is the recorded failure this fixes). Item 2
  above — hygiene while a fun-verify IS pending — is unchanged.
  Precedent, same order ("count it as ritual this time"): the
  eighteenth's s2 = a solo session counted retroactively by owner
  word, compressions NAMED at adjudication per spec §12.4 (record:
  skeleton §RITUAL SESSION 2).
- Everything else is steerable at the owner's word: lane order, freezes,
  scope promotions. Less rigidity ≠ less order: one-concern commits,
  evidence banks, forks close at brainstorms (dev recommendation + owner
  veto, v13 precedent).

<!-- FAMILY-BLOCK BEGIN -->
## Workspace family (game-two program) — synced 2026-08-24

- **Peers:** Gabriel (owner-founder, es-CR) + Junior (co-creator,
  pt-br) co-direct the whole program with equal creative standing —
  design, code, audio/assets, ideas flow from BOTH; neither is the
  other's worker. Owner overrides are law and get RECORDED (one line)
  in the affected repo.
- **Never gate on peer availability (owner order 2026-08-22):** solo
  progress is the default in every repo — peer online = good, absent =
  keep moving, symmetric both ways; the dev of record proactively
  surfaces REAL recorded work items (never fabricated ones). Peer
  ratifications land async in the hub chat.
- **Hub-and-spoke:** the game-two dev chat is the HUB; work in this
  repo runs as bounded sessions under its own dev-of-record.
  Cross-repo asks travel by SEAT MAIL (`~/.pi/agent/mail/<repo>/`),
  digest-stamped (md5), answered with `RECEIPT:` lines. Deliveries
  INTO game-two obey game-two's intake rules (owner-approved +
  digest-grounded + docs-only banking).
- **Seat-lease law:** no session ever writes into a sibling workspace
  tree — read tool for reading, mail for asking, md5 as the
  byte-identity arbiter.
- **Service seats:** game-two-audio (audio increments on owner word) ·
  game-two-uiux (UI/UX spec/prototype/critique service + research
  lanes; owner-ordered genesis 2026-08-24, charter = its AGENTS.md,
  git-blob md5 `6ddeb63023b3884961f241a2091ed366`). Service seats
  never fork this repo's lanes — integration lands only through this
  seat, under this repo's gates; critique passes arrive by mail as
  take-or-leave evidence.
- **Sovereignty:** this block never overrides local law — this repo's
  own invariants win inside this repo.
- **Contract mirror:** AGENTS.md is ground truth; CLAUDE.md is a thin
  pointer to it so Claude sessions load the same contract (AGENTS.md
  wins on any disagreement).
<!-- FAMILY-BLOCK END -->

## Current cycle — see `docs/CYCLE.md`

**One cycle lives in `docs/CYCLE.md`** (STATE, rewritten each cycle; the
cycle's foundation `drafts/_vNN-foundation-<date>.md` is LAW and wins on
disagreement). Owner-pending items live there, never here. Previous cycles:
`git log --follow -- docs/CYCLE.md AGENTS.md`; v20/v21 verbatim in
`drafts/_v21-record-20260905.md`.

## Standing programs + laws (cycle-independent; the linked doc is the source)

- **Quality flywheel** (`drafts/_quality-flywheel-plan-20260819.md`):
  verified renderer/data fixes ONLY. **Sampling-artifact law:** critics see
  ~4% of frames — verify every critique claim against code + the exact PNGs
  before it becomes a work item; sim-touching candidates route to a lane.
- **World-builder pipeline** (LDtk → strict importer → zone JSON): every law
  is in `docs/MAP_EDITING.md` — §1 one lawful edit path per zone · §3
  transitions + seal GATING + floor-delta lint · §4.1 normalizer · §4.2
  AfterSave loop · §4.3 ergonomics · §4.4 `autoLayerTiles: null` · §4.5
  GUI-safety (declared IntGrid values; 5 out-of-bounds `spawn` rows untouched
  until WB-T7). WB-T6 record: `drafts/_wb-t6-ldtk-foundation-20260905.md`.
  SAFE tile behaviors ship freely; SIM-class ones route through a lane, ONE
  gated piece at a time.
- **Audio (M5a):** a PURE SINK (never sim/saves/netplay), OPTIONAL at boot
  (absent = one named line), owner originals only;
  `drafts/_m5a-verdict-20260818.md`.
- **Prose-number law (2026-09-05):** a number computable from a file is
  computed or pointed at, never hardcoded — wall size = `ls harness/scripts
  | wc -l`, frame size/anchor = `data/art/manifest.json`, verdict currency
  = `rake pins`.
- **Seats:** Gabriel's hub session + Junior's FULL PEER seat (pi via the
  shared LiteLLM gateway; CLAUDE.md = thin mirror), same laws for both: pull
  before push, hooks run the suite, gates block ships. Working language
  English; player surfaces es-CR / pt-br. Junior's machine + protocol:
  `docs/JUNIOR.md`.

**OUT of scope — goes to PARKING_LOT.md, never to code:**
always-online/server-authoritative world (named trigger recorded);
in-game world editing, map view, teleport; character creation/
appearance; item/equipment system; in-game chat/channels; >2 players;
assets integration (gated on game-two-assets pipeline maturity);
rollback/resync; open-internet play (Tailscale = trusted overlay
only); BOSS-1-dread iteration (OPEN-FOR-EXPOSURE — zero code owed);
all lore/creative writing (standing order above); in-game rebind UI.

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
skill. The v16 language/authorship pipeline is SUSPENDED with the lore
program (2026-08-16): placeholders + dictionary-word functional labels only.

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

1. **Line caps (enforced by `test/app/line_caps_test.rb`):**
   `src/app/window.rb` ≤ 300 — systems talk via the event bus or they
   don't ship (kethral/game.py hit 2,663 lines with a bus available);
   `src/game/world.rb` ≤ 1,800 — any material touch at the cap owes its
   own extraction into a plain object (Crossing precedent, s31).
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
- **Dev warp (owner order 2026-09-05):** `bin/warp <zone> [locale] [level]` / `bin\warp.cmd`
  — start in ANY zone at the level cap on a SCRATCH save (`tmp/dev/world.json`, regenerated
  per launch by `tools/dev_save.rb`: every seal open, BOSS 1 defeated, bank 9999, strict-
  decode verified). No args = zone list. The live save is never read or written:
  `--start-zone` on a human seat needs `--save <scratch>` (Cli) and refuses the persistence
  path by name (main.rb). Warp logs are `game_two_warp_*` — outside the fun-verify harvest
  glob; a warp is dev inspection, never fun evidence.
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
- **Soak:** `rake soak [N=episodes] [TICKS=min] [SEED=base]` — two seeded bots (real
  processes over loopback/Tailscale) play on a SCRATCH save under `tmp/soak/<run>/`;
  `soak/chain_check.rb` judges LOGS + exit codes only. Env extensions (`ZONES=`,
  `SEED_SAVE=1`, `SOAK_AUDIO=1`): `soak/run_soak.sh` header. Quarantine is mechanical
  (`--bot` in a save-owning seat refuses without `--save`; the run fails NAMED if the
  live save's md5 or the temp-dir log count moves). **A bot session is never oracle
  evidence** — fun-verify harvests judge human launcher logs only.
- **Flywheel clips + critique:** `harness/make_clip.sh harness/scripts/<name>.json
  [every_n] [out.mp4]` — deterministic MP4 from a wall script (env-gated VIDEO_EVERY;
  the wall never sets it; never run beside a live seat or soak). Critique:
  `python harness/self_eval.py tmp/clip_<…>/video ["<focus>"]` →
  `drafts/_self-eval/<clip>_critique.md` (spend rails ~$2-5/clip; sampling-artifact
  law applies — see Lane 2).
- `rake capture SCRIPT=harness/scripts/<name>.json` — deterministic replay + frame capture.
  One script per regression surface lives in `harness/scripts/` (the wall); trust the
  directory, not an inline list here (an inline list went stale once). Canonical entry
  points: `world_loop.json` (everyday loop), `floor2_run.json` + `floor3_run.json`
  (zone-start scripts use the `start.zone` param). Retired-pending-reauthor scripts
  live in `harness/retired/` (out of the wall, preserved for their re-author sessions).
- `harness/run_wall.sh [tag]` — full wall sweep: every script in `harness/scripts/`
  through gate + manifest, teed logs in `tmp/wall/`, nonzero exit if any script fails
  (~5 min/script — run DETACHED, never under a bash-call timeout). Each script's
  verdict is recorded as a PIN (`harness/pins.json`); `rake pins` lists PINNED / STALE
  (render or sim paths moved since) / FAILED / UNPINNED per script — a ledger, never a gate.
- `rake gate SCRIPT=harness/scripts/<name>.json` — the BLOCKING Rule 2 gate: double replay +
  md5 compare + structured vision verdict (exit nonzero on any failure). `SKIP_CRITIC=1` runs
  the determinism half only (iteration aid, not a shippable pass). Optional `CHECKS=<file>`
  swaps the checklist — default `harness/gate_checks.json`.
- **Netplay gates (v17):** `rake gate SCRIPT=harness/net/<netplay_session|netplay_desync|
  netplay_conn_lost>.json CHECKS=harness/net/gate_checks.json` — two real Worlds + two real
  Sessions over loopback inside the replay window (scene + determinism law:
  `harness/scenes/netplay_scene.rb` header). These live OUTSIDE `harness/scripts/` on
  purpose: the wall stays single-player.
- `rake map [SAVE=path] [OUT=dir] [PROBES=1]` — god-view v0: OFFLINE full-map PNG from
  data+save through the play-path strict decoder (refusal aborts NAMED; missing save =
  honest fresh state); filename carries digest provenance. `PROBES=1` renders staged
  facts + pixel asserts — this surface's gate is probes + vision critique
  (`harness/map_checks.json`), no replay half (decision 13).
- `rake perf` — perf smoke (machine-local): district scenario, aborts if p95 tick >= 16.6 ms.
- `rake pilot NAME=<n> SEED=<s>` — interactive pilot session: append commands
  (`printf 'cmd\n' >>`, NEVER Write) to `tmp/pilot/<n>/inbox.txt`, read `log.txt`; idle =
  frozen sim; `export` emits a standard replay script. Full protocol: harness/pilot.rb header.

## Enforcement (wired 2026-08-11 — script-enforced, not prompt-requested)

- **Git hooks gate commits and pushes**: `.git/hooks/pre-commit` and `pre-push` both run
  `bundle exec rake` (with the Ruby PATH baked in) — bundle exec pins the Gemfile.lock
  versions. A red suite blocks the commit — that's the point; fix the test, don't
  `--no-verify`. Hooks are untracked: to reinstall, each is 4 lines — `#!/bin/sh` +
  `PATH="/c/Ruby34-x64/bin:$PATH"` + `export PATH` + `exec bundle exec rake`.
- **swarmforge** (quality-gauntlet CLI) is configured via `swarmforge.toml`. Invoke with
  `PATH="/c/Users/gabri/workspace/swarm-forge/.venv/Scripts:$PATH" swarmforge <cmd> --repo .`
  — useful for `tdd-check src/game/<file>.rb` (WARN-only) and `handoff validate` for
  multi-agent handoff files.
- `rake gate` stays the Rule 2 blocking ship-gate (unchanged); hooks don't replace it.
- **Process artifacts are tracked**: `drafts/` (verdicts, reviews, calibration history)
  lives in git — commit at cycle close. Only `drafts/_tibia-videos/` (media corpus) stays
  ignored. The wall runner is `harness/run_wall.sh`, never a tmp/ scratch copy.
- **Orchestration (owner-adopted 2026-08-18)**: the dev-of-record chat is the HUB; sibling-
  repo fan-outs run as bounded headless sessions per the `seat-orchestration` skill
  (routes decided in a drafts/ triage doc FIRST, digest-stamped prompts, free seats only,
  one pass per spoke, `RECEIPT:` paths harvested back). Spokes surface exactly two things
  for humans: seat conflicts and failed receipts. Junior's agent-session protocol:
  docs/JUNIOR.md §"Sessões com agente".

## Controls

WASD / arrows = move · Ctrl (hold) + direction = stationary aim (face without
stepping; dodge stays live) · J / Space = attack · K / Shift = dodge · L / E = special ·
; / Q = mark · U / R = potion (buy at bank / use afield) · H / F = interact ·
Tab = swap possession · Esc = menu (non-pausing — the world keeps ticking;
quit via its QUIT row · J-6, s53)

Timebase: `Window#update` = exactly one sim tick (tick-locked; replays deterministic by tick
count). Under load the game slows rather than skips — the top-right overrun counter makes
that visible, so a sluggish playtest is a perf signal, not a balance signal.
