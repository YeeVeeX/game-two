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
`drafts/`, never here. Session-by-session state: `docs/CHECKPOINT.md`
(top entry = latest).

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

## Current cycle — v20 OPEN (the DESCENT cycle; RATIFIED-G 2026-08-28)

**v20 = the content cycle.** Vision (ratified): "v19 made the
characters grow into the world; v20 gives that growth somewhere to
GO — a vertical geography of risk you descend on purpose, floors you
fight to hold, a level band with real headroom, and the first zones
the peers built together." Law of the cycle:
`drafts/_v20-foundation-20260828.md` — 14 ledger rows + 4 council
amendments (grilled live with the owner, s114; council pass:
1 DeepSeek consult, all four adopted + owner-approved).
**RATIFIED-G COMPLETE 2026-08-28** (verbatims in the foundation);
RATIFIED-J async pending (his forest-first destination = the
recorded lean at L2's own gated row; his L3 pick-or-pieces call
open). Lane D is CLOSED author-ratified 3/3 (Junior verbatims:
floor -1 2026-08-29 · floor -2 + floor -3 2026-08-30,
`drafts/_junior-floor{2,3}-ratification-20260830.md`). **The
NINETEENTH fun-verify is DECLARED 2026-08-30 (owner word s124)** —
freeze ARMED, window target ≤48h; protocol:
`docs/superpowers/specs/2026-08-30-v20-nineteenth-ritual.md`
(peers: don't read its §7). v19 record: CUMPLIDO — the EIGHTEENTH closed at 5/10 verdict
+ 10/10 addendum (K3 never fired, license FINAL), two named debts
carried into v20 lanes: `drafts/_v19-fun-verify-verdict-20260828.md`;
v19 foundation: `drafts/_v19-foundation-20260822.md`. This section is
STATE; the foundation is law — on disagreement the foundation wins.

**Spec + first-wave tickets (T1-T6):**
`docs/superpowers/specs/2026-08-28-v20-descent-cycle.md`. Serial
execution (owner method ruling s89), one ticket per fresh session,
CLAIMED line at start, ANY seat executes (FULL SEAT SYMMETRY).

**Lanes (staged; A→B→C→D serial, E anytime, F late-gated, G
post-verdict):**

1. **A — FLOOR 1 (first felt change):** ZONE 2 (district) rethemed
   to Junior's v2b "two spaces + 4 bridges" as descent floor -1
   (T1). Internal retheme is destination-independent; the descent
   MOUTH stays on the camp→district edge — the forest-first
   destination decision moves ONE transition row later (L2).
2. **B — PROGRESSION + POTIONS IDENTITY:** staged cap 10→12 + k
   re-price + `tools/pacing_table.rb` standing script (T2); potions =
   the provisions system given its true identity + discoverability
   (candidate 1 v1 + R-A2 strip escalation, full-wall re-pin priced;
   T3 — lands BEFORE lane C by law).
3. **C — TOTEM PILOT (first SIM delta; NINETEENTH's delta clock
   starts here):** Junior's contested/cadenced heal totem at floor
   -1's center, instrumented (totem-vs-potions telemetry,
   pre-registered priced-flip condition), world.rb extraction rides
   this ticket (T4).
4. **D — FLOORS -2/-3 + BAND STEPS:** district_two + low_quay
   rethemes (v3 MEDUSA grammar deepest — needs T5 second wall
   class), new creature kinds with own kill_xp rows (deep pays
   more), cap 13/15 unlock RIDING these floors.
5. **E — DEBTS (small, anytime):** B4 mercy-floor data-only knob
   (T6, verdict debt 1) · C3 stance-verb rung + flee/engage co-tune
   (verdict debt 2, own re-session, second wave).
6. **G — AMBIENCE (presentation, SAFE; recorded 2026-08-30):**
   animated region ambience, underwater-first pilot on floor -2 —
   peer direction (Junior) + owner concur, both verbatim in
   `drafts/_junior-floor2-ratification-20260830.md` §2. Two laws
   bind: tick-driven (never wall-clock) + affected wall manifests
   re-pinned as NAMED ticket cost. Executes POST-verdict of the
   NINETEENTH (data/zones sits in its freeze set).
7. **F — LATE, GATED:** destination/HOME single-row decision (graph
   drawing + save migration law L9 + cardinal sketch) · GM read-only
   rung (stretch; offline factory is this cycle's answer) · city
   start (deferred, blueprints keep banking).

**Key cycle laws:** save-chain never a migration guinea pig (L9) ·
world.rb extraction owed INTO the first touching ticket (L10, →T4) ·
cap never outruns content (L5) · SIM-class one gated piece at a time
· NINETEENTH fun-verify is delta-triggered (cadence reform; map
rethemes are presentation+graph, named beside the totem's sim delta).

**v19 riders carried:** E2 ping (with parked chat) · E3b
turn-handling (re-decide post-J-5—owner picked FLAT s93) · E4 motif
DORMANT · E5 audio increments on owner word · candidate 5 HUD
reposition banked with uiux spec · J-5 art-depth-on-flat candidate
banked.

**The EIGHTEENTH ritual (v19's) — CLOSED CUMPLIDO 2026-08-28** (5/10
verdict + 10/10 addendum, K3 never fired, license FINAL; two named
debts → v20 lanes B4/C3): `drafts/_v19-fun-verify-verdict-20260828.md`
— evidence + verbatim answers:
`drafts/_v19-fun-verify-skeleton-20260826.md`. All freezes lifted,
all quarantines spent. Bot-logs-never-fun-evidence: permanent law.
R-A2 strip escalation: executing as v20 T3 (owner-ratified at the
grill).

**Standing program — quality flywheel** (owner-directed 2026-08-19;
contract: `drafts/_quality-flywheel-plan-20260819.md`): soak
zone-coverage · deterministic clips + self-eval critique · verified
renderer/data fixes ONLY — **sampling-artifact law:** critics see ~4%
of frames, so every critique claim is verified against code + exact
frames (read the PNGs) before becoming a work item; sim-touching
candidates route to their v20 lane. Audio tuning on owner ask.

**Standing program — world-builder pipeline** (spec CLOSED:
`docs/superpowers/specs/2026-08-19-world-builder-pipeline.md`; grill
`drafts/_world-builder-grill-20260819.md`): the six-zone world is the
game's INTRODUCTION ARC; expansion grows outward via LDtk → strict
importer → zone JSON + hot-reload preview + floors + region layer +
tile-type registry. **T1–T5 ALL SHIPPED** — ZONE 7 (town hub, THE
WELL) + BASEMENT 1/2 + DUNGEON 1 authored and WIRED IN (tickets
`drafts/_wb-t*-*.md`; T5 record `drafts/_wb-t5-wirein-20260821.md`).
Live authoring laws:

- **The world is JOINED**: low_quay [44,19] ↔ zone_7 [1,14]
  (`requires_defeats: 1` outbound; the return is free); zone_7's deep
  ways gate by pack level (s68): basement_1 at 4, basement_2 at 5,
  dungeon_1 at 6 (composes with its seal) — returns free; dungeon_1's
  far-east rope way [29,4] ↔ zone_8 [63,19] (s70 wire-in:
  `requires_level: 8` outbound, the frontier rung; return = free v1
  edge gate). **INERT law:** grass_fixture inbound-inert; zone_8's
  intake debt is EXECUTED (s70 — record:
  `drafts/_worldsmith-v0-intake-20260823.md` §Wire-in debt).
- **Typed transitions**: rope = interact (gate-consent law),
  holes/stairs auto-fire. **Seal GATING law** (s34, `abe04d6`): a
  seal's `opens` must name a transition with TRUTHY `sealed` —
  unsealed or `requires_defeats`-only targets refuse NAMED at zone
  load (`drafts/_s34-seal-gating-20260821.md`).
- **SAFE tile behaviors** (decorative variants, footstep materials,
  region ambience) ship freely; **SIM-CLASS tile behaviors** (lava,
  water, tile-gated spawns) route through their v19 lane, ONE gated
  piece at a time. Live in-game god-mode editing stays a staged later
  rung (E1 family).
- First human crossing landed 2026-08-21 (Junior, his solo save:
  `drafts/_junior-primeira-travessia-20260821.md`); the SHARED-save
  crossing is still ahead.

**Audio (M5a SHIPPED 2026-08-18 — standing law):** audio is a PURE
SINK (never sim/saves/netplay), OPTIONAL at boot (absent/refused = one
named line, game runs silent), owner originals only. Verdict:
`drafts/_m5a-verdict-20260818.md`; asks 5–9 executed 2026-08-20
(sources banked: `game-two-audio/handoff/audio-v12/`). Queued on owner
word: stereo ambient stems + region-acoustics (library increments).

**Owner-pending (never nag):** ear-checks of the audio-v12 batch (ride
the next play session) · T3 footstep/bed renders (frozen cue-spec mail
in the audio seat's inbox — water family needs a NEW mail) · coop S1
invite (both seats READY) · the SHARED-save first crossing · the J-5
spike call · the worldsmith v2 grill (post-verdict + J-T1 + its T26
dossier — hub ruling s89; v0+v1 RATIFIED in its seat, zone_8 = its v0
export live since s70; intake stays freeze-gated).

**Seats:** Gabriel's hub session (this machine) + Junior's seat (his
machine, pi since 2026-08-23 via the shared LiteLLM gateway — AGENTS.md
auto-injects; CLAUDE.md stays a thin mirror for any stray Claude
session). Working language English; player surfaces es-CR / pt-br.
Junior's seat is a FULL PEER seat — code, design, creative direction,
playtesting, CI — under the same laws as every seat: pull before push,
hooks run the suite, gates block ships, handoffs via drafts/ +
`swarmforge handoff validate`. His machine specifics + pt-br surfaces
+ agent-session protocol: `docs/JUNIOR.md`.

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
  (~5 min/script — run DETACHED, never under a bash-call timeout).
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
