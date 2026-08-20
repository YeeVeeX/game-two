# SPARK sesión 25 — INTAKE gamesmith R7B → T4 vsync-release (spike gated) → DOCKET v19

You are the dev of record in game-two (cwd `~/workspace/game-two`). Read
`AGENTS.md` FIRST (rule 8) — the live file beats this spark on any drift.
Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language
English; owner surfaces es-CR ustedeo (everyday gamer words — never the
foreclosure register). Quality over cost: council 0 default; the only paid
calls are the gamesmith intake's Kimi text gate (≤$0.20, its spark's law)
and any Rule-2 gate critics. Evidence-first: claims are not evidence —
file:line, log line, or UNVERIFIED tag.

## Program state (2026-08-20 session-24 close — verify live)

- v18 CLOSED · **v19 NOT open** (owners' brainstorm at their word). Session
  24 shipped the owner's audio queue: **dup fix** (`aa02624`, one take per
  event family per tick, rotor never advances on coalesced events) ·
  **−4 dB percussive music duck** (`3d79787`, data-only, 13 rows, release
  9600 aligned) · fresh-eyes FAIL adjudicated (`drafts/_audio-polish-
  review-20260820.md` + grill §6: release half FIXED in data; **depth-lift
  collision** −12→−4 inside a stinger window = RECORDED library increment,
  build only on owner word) · T3 lag verdict from banked bytes
  (`drafts/_lag-t3-verdict-20260820.md`).
- **EAR-CHECKS pending (owner's next listen, never nag):** ¿se acabó la
  duplicación? · ¿la música respira sin abrumar? · en pelea densa con
  aviso de BOSS/sello, ¿la música vuelve a subir demasiado pronto? (sí →
  the recorded library increment, never a data tweak) · plus the audio-v12
  batch items (calm loop · zone-change · tails · ask-5 levels).
- **Coop with Junior = lag segment S1** (owner-paced): both seats pull ≥
  `f5b4356` FIRST (protocol v3 refuses mixed builds NAMED — designed
  failure) · `GAME_FRAME_PROBE=1` both seats · harvest checklist + bank:
  `drafts/_lag-t2-evidence/README.md`. Junior's debug-menu proposal
  (`63d7b9d`) still awaits Gabriel's validation — never nag.
- **R-A2 measure (silent, NEVER prime the owners):** `sustain bought=0`
  still. Harvest `TELEMETRY sustain` + any `frame_probe`/handshake lines
  from every NEW human launcher log into the record; never re-ask, never
  mention provisions unprompted.
- **Assets seat answered (session 24):** gating-decision = DEFERRED
  (v19-class, recorded); capture-contract = queued-for-v19-intake. Receipt
  sent; their inbox owes us nothing.

## Job 0 — standing gate (~10 min; anything moved = classify in writing FIRST)

Baselines at staging: origin/main `aee0c10` + EXPECTED docs-only delta
(this spark's own commit + the gamesmith-spark bank — classify at gate 0,
same as session 24 did) · save `saves/world.json` md5
`98fe75edb6d72deab18cd48eaa88bdaf` mtime 08-20 15:51 (sessions=13
banked=7 provisions=0 seals=2) · launcher logs 76 across both temp
patterns (38×2) · seat mail inbox EMPTY, done/=16 · tmp/soak newest
`20260820-020422` · untracked `drafts/_refs/` only. EXPECTED deltas:
Junior docs-only commits (his lane — read before rebasing) · new launcher
logs if the owners played (harvest silently, route ear-check verdicts as
owner lane). `git pull --ff-only` FIRST. Single-instance guard before any
launch (separate call, judged by printed output). `--fresh` NEVER.
Background `bin/play` from pi's bash DIES silently — the working launcher
is `powershell Start-Process bin\play.cmd`.

## GATE 0 OVERRIDE — any live owner order preempts this whole queue

Owner ear-check verdicts arriving mid-session are LAW: bank verbatim,
route per the checkpoint's three pending questions, and if the third
(stinger overlap) fails his ear, the depth-aware-duck library increment
becomes the next owner-approved lane — grill it in game-two-audio, never
as a game-two data tweak. A live coop session = S1: support, harvest
verbatim per `drafts/_lag-t2-evidence/README.md`, bank md5-stamped.

## THE ORDER (dev-of-record sequencing; each job = one-concern commits)

### J1 — gamesmith Round-7B intake (bounded, self-contained, ~30-45 min)

Execute `drafts/_gamesmith-round7-intake-spark-20260820.md` EXACTLY as
written — it is the law for this job (banked verbatim from the gamesmith
seat; its hard stops preempt). Notes from the hub seat, already verified
at banking: Round-5 addendum md5 ✓, both PARKING anchors present; the
"design-time queue" in its preflight shipped in session 24 — "active
queue unchanged" means THIS spark's queue. Its preflight demands a CLEAN
tree: run J1 FIRST, before any J2 edit dirties the tree. Its Kimi text
gate (accuracy vs presentation, separate axes) is blocking per its own
budget. Fire the receipt mail + `RECEIPT:` line, then continue.

### J2 — T4: vsync-release spike (the ONE lag ticket; investigate → gate → ship-or-record)

Contract: `drafts/_lag-t3-verdict-20260820.md` §4. The limiter is
Junior's seat (59 Hz vsync ceiling + 6.8% in-process tail); T4 attacks
ONLY the ceiling. Laws: env-gated `GAME_VSYNC_OFF` (absent = byte-
identical behavior — the SOAK_AUDIO/GAME_FRAME_PROBE precedent) ·
window/app layer ONLY, the tick-locked timebase law untouched (one
update = one sim tick) · the tail is OUT of scope · never both levers.

1. **Investigate FIRST (≤45 min, evidence in the ticket doc):** how does
   Gosu 1.4.6 set swap interval on this machine? Read the installed gem
   source (`gem which gosu`, its C/ext layer) + SDL2 surface. Candidate
   routes, cheapest first: (a) SDL env hints Gosu/SDL already honor at
   window creation (test empirically — `SDL_RENDER_VSYNC`/driver hints;
   prove with frame_probe, not docs) · (b) FFI `SDL_GL_SetSwapInterval(0)`
   against the already-loaded SDL2 DLL after window creation (ffi gem is
   already a dependency; the GL context must be current on the calling
   thread — verify) · (c) anything needing a Gosu rebuild/patch → **STOP:
   record findings + options in `drafts/_lag-t4-vsync-20260820.md`, ship
   nothing** (rebuild toolchain risk is owner-level).
2. **Local A/B oracle without touching the save:** the sim-owning seat
   refuses `--bot` without `--save` — use a bot seat on a SCRATCH save
   (`--bot --save tmp/t4/world.json`, fresh dir) with `GAME_FRAME_PROBE=1`,
   flag OFF then ON, ≥2 min each, same seed. Bot lines are fine here —
   this is a mechanical perf A/B, not fun/oracle evidence; say so in the
   doc. Success shape: period p50 drops off the vsync wall (~16.6-16.9 →
   update-interval-paced) with draw/update p50 unchanged. If the flag
   changes nothing measurable on THIS machine (already ~60.7-61.2 tps
   solo), that is still a shippable result IF the mechanism is proven to
   set the interval (log line `VSYNC off (swap_interval=0)` at boot) —
   the decisive oracle is Junior's machine.
3. **Ship shape (if route (a)/(b) proves out):** flag read at one site,
   `nil` = zero cost (frame_probe precedent) · one named boot line when
   active · TDD the plumbing where testable (flag parse/log line; the GL
   call itself is machine-behavior, covered by the A/B lines) · suite via
   hooks · **canary gate**: `rake gate SCRIPT=harness/net/netplay_session.json
   CHECKS=harness/net/gate_checks.json` with the flag ABSENT — byte-
   identical expected (the wall never sets it) · **fresh-eyes review
   BLOCKING** (scrubbed pi, diff + ticket doc, receipt in drafts/) ·
   stage Junior's re-run instructions in the ticket doc (pt-br two-liner:
   pull + `GAME_VSYNC_OFF=1 GAME_FRAME_PROBE=1 bin/play pt-br`, solo,
   ~4 min, Esc, paste frame_probe) — his S0-J re-run is owner-paced,
   NEVER nag.
4. One commit (`feat(app): env-gated vsync release …`) + ticket doc
   commit. If STOPPED at (c): the findings doc IS the deliverable.

### J3 — v19 intake docket (docs-only index; the brainstorm's agenda page)

Create `drafts/_v19-intake-docket-20260820.md`: ONE row per banked
candidate — columns `Candidate | Source (doc/commit) | Class
(sim/presentation/data/library/process) | Status/named trigger`. Rows to
sweep (verify each pointer live, add any this list missed): Junior's 7
ideas (`_junior-v19-ideas-20260819.md`) · his solo findings (ally
acquisition gating + bank-placement gap, `_junior-solo-playtest-
findings-20260820.md` + correction) · debug-menu proposal (`63d7b9d`,
awaits Gabriel) · ping/item-pickup remap (PARKED with v19) ·
projectile-audio sync (`c835c67` PARKING, fork a/b) · gamesmith R7
dispositions (post-J1 triage rows, triggers only) · assets v12
capture-contract + turn-handling gating row (deferred, session-24
receipt) · depth-aware-duck library increment (grill §6) · stereo-ambient
+ region-acoustics (queued on owner word) · lag T4 result + tail ticket ·
BOSS-1-dread (OPEN-FOR-EXPOSURE, zero code owed) · R-A2 sustain measure
state. LAW: pointers + one-line summaries only, dev recommendations only
where the source doc already records one — the docket ADDS no new
opinions, promotes nothing, and does not open v19. One commit.

## Laws that bite (short list)

- Deterministic gates decide; a failed gate/critique BLOCKS ship — never
  downgraded. Presentation never mutates sim; audio stays a pure sink.
- Read-before-edit · one-concern commits, explicit paths (never `git add
  -A`) · hooks run the suite (~55 s/commit — normal) · long jobs DETACHED
  (nohup + poll; never under a bash-call timeout — a killed gate is
  judged by a standalone re-run).
- Two instances fork the save — guard every launch in a separate call
  judged by printed output; bot seats need `--save` scratch; phantom
  sessions get NAMED if anything launches the game.
- JSON edits are SURGICAL text ops (a re-dump reflowed 650 lines once);
  multi-line scripts go in temp files, never inline heredocs.
- Junior's lane (`drafts/_junior-*`, his machine docs) is his — harvest,
  never edit. Owner overrides are law the moment they land — one line,
  never re-litigated. No lore anywhere (standing order).
- Cross-repo: read siblings freely, write ONLY via seat mail receipts;
  never write into game-two-lore or any held seat.
- Verbatim means verbatim: owner/Junior quotes and telemetry lines bank
  byte-exact; partial evidence = bank what exists + name what is missing.

## Budget + stop conditions

One attended session ~2.5-3 h, context guard 85% → compact-checkpoint
skill. Council 0 beyond J1's Kimi gate; sub-agents: J2's fresh-eyes
reviewer only. **Stop when:** J1 receipt fired · J2 shipped behind canary
gate + review PASS (or honestly STOPPED with the findings doc) · J3
docket committed · checkpoint + owner queue es-CR (~5 líneas) + push.
**Stop early, honestly, if:** J1 hits any of its hard stops (report,
skip to J2 — its tree-clean rule still binds J2's start) · J2's
investigation contradicts the T3 mechanism (re-plan in writing) · a gate
fails non-mechanically · the owners redirect (their word is the router).
