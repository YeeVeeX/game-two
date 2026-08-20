# SPARK sesión 24 — AUDIO POLISH (dup-bug + ducking) → COOP Junior (protocolo v3) + cosecha T2

You are the dev of record in game-two (cwd `~/workspace/game-two`). Read
`AGENTS.md` FIRST (rule 8) — the live file beats this spark on any drift.
Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language
English; owner surfaces es-CR ustedeo (everyday gamer words — never the
foreclosure register). Quality over cost: council 0 default; Bedrock =
only what Rule-2 gate critics cost. Evidence-first on every fix: claims
are not evidence — file:line, log line, or UNVERIFIED tag.

## Program state (2026-08-20 session-23 close, origin/main `d3d853a` — verify live)

- v18 CLOSED · **v19 NOT open** (owners' brainstorm at their word). Session
  23 shipped: R-A2 bank hint + telemetry reasons (`e36a227`/`d31f579`) ·
  audio asks 5–9 end-to-end (batch v12: −4 dB percusivos, dodge 8→4,
  evolving 64 s calm loop, zone-change nuevo, throws con cola 1800 ms;
  sources banked `game-two-audio/handoff/audio-v12/`) · zone −4 dB
  (`dfd3838`) · **stationary aim** Ctrl+dirección (`28017d8`, protocol
  **VERSION 2→3**, bit 11 append-only).
- **Owner ear-check verdict (banked): "suena muy bien"** + two named bugs
  → THIS session's queue (his order). Ear-checks pending: dup fix +
  ducking (his next listen).
- **R-A2 measure (silent, NEVER prime the owners):** `sustain bought=0`
  still — harvest `TELEMETRY sustain` lines from every human session log
  into the record; never re-ask, never mention provisions unprompted.
- **Junior's seat banked (read before routing):**
  `drafts/_junior-solo-playtest-findings-20260820.md` + his own correction
  (`50edbd5`/`f4a331f`) — ally-AI verdict + bank-placement gap = v19
  brainstorm inputs, R-A3 stays FROZEN, zero code owed. His debug-menu
  proposal (`63d7b9d`) awaits Gabriel's validation — never nag.
- **Lag P0 context:** T1 shipped (always-on handshake/close lines +
  `GAME_FRAME_PROBE=1`). T2 runsheet:
  `drafts/_lag-probe-runsheet-20260820.md` (S0-J decisivo en la máquina de
  Junior — his seat ran a probe session but NO frame_probe lines banked
  yet; check `drafts/_junior-*` for new lag docs before routing). The coop
  session below DOUBLES as segment S1 if both seats run the flag.

## Job 0 — standing gate (~10 min; anything moved = classify in writing FIRST)

Baselines at staging: origin/main `d3d853a` · save `saves/world.json` md5
`98fe75edb6d72deab18cd48eaa88bdaf` mtime 08-20 15:51 (sessions=13
banked=7 provisions=0 seals=2) · launcher logs 76 across both temp
patterns · mail inbox EMPTY, done/=15 · tmp/soak newest `20260820-020422`
· untracked `drafts/_refs/` only. EXPECTED deltas: Junior docs-only
commits (his lane — read them first, rebase clean) · new launcher logs if
the owners played. `git pull --ff-only` FIRST. Single-instance guard
before any launch (separate call, judged by printed output). `--fresh`
NEVER. Background `bin/play` from pi's bash DIES silently — the working
launcher is `powershell Start-Process bin\play.cmd` (session-23
precedent, checkpoint).

## THE ORDER (owner-set at session-23 close; gate 0: any live owner order preempts)

### T-A — cue duplication/sync bug (evidence FIRST, fix behind it)

Owner verbatim: "algunos bugs de sincronización o duplicación de
triggering de los sonidos". Budget the grill ≥ the fix.

1. **Reproduce before reading solutions into it.** Suspect #1: multi-hit
   sim events fire one cue PER CONNECTION in the same tick (whirl/AoE hits
   N enemies → N `attack_hit` emits → N takes flam). Verify: grep the emit
   sites (`grep -n "emit(:attack_hit\|emit(:projectile_fired" src/game/`)
   — does one swing emit per target? Then count HEADLESSLY: real World +
   real bus, drive a multi-hit scenario (aoe_specials territory), subscribe
   and count same-tick same-event emissions; with the real library booted
   (`test/app/audio_bridge_test.rb` `lib_present?` pattern) count
   voices/cue requests per tick. Bank the numbers in the fix doc.
2. **Also his "sincronización" half:** check whether the SECOND+ take of a
   flam lands a tick later (bridge queue/rotor cadence) — that reads as
   desync-to-eye. Same evidence pass.
3. **Fix design (dev decides, with evidence):** presentation dedups,
   SIM NEVER changes (events are sim truth — never touch world emits for
   an audio symptom). Leading candidate: bridge-side same-event-family
   same-tick coalescing (fire ONE take per event family per tick;
   deterministic because it derives from the same event stream both seats
   see — replay/netplay-stable by construction). Verify the VariantRotor
   advance stays deterministic under coalescing (its tests + a
   netplay-gate run if the bridge path moved).
4. TDD (red first) · suite via hooks · zero wall debt (no pixels move) ·
   **fresh-eyes review BLOCKING** (scrubbed pi, diff + evidence doc,
   receipt in drafts/) · ear-check pends the owner.

### T-B — ducking/sidechain design (data-only if the schema holds)

Owner verbatim: "añadir algunos elementos que tengan sidechain/ducking …
se juntan muchos sonidos a la vez … tiende a acumularse o volverse
abrumante".

1. Read the duck semantics FIRST: per-cue `duck` blocks
   (`bus/duck_db/attack_frames/hold_frames/release_frames`) validated by
   `game-two-audio/src/gta/audio_data.rb` (`duck.hold_frames >=
   engine.tick_frames`, ONE pending fade slot per group — design within
   that law). Existing precedent: wipe + stingers duck `music` −12 dB.
2. Design SMALL and cite gate-proven values: percussive families
   (hit/dodge/throw/special) duck `music` a touch (−3…−6 dB, fast
   attack, short hold/release) so pile-ups make room instead of stacking;
   consider whether the `sfx` bus level itself earns −1…−2 dB (the
   accumulation complaint) — ONE lever at a time, named in the doc. The
   voice-pool caps (48 sfx) already bound the worst case — say so.
3. Data-only in `data/audio/cues.json` (+ buses if touched) → suite +
   `AudioData` load validation (in-repo bridge tests boot the real
   library) · no wall debt · ear-check pends the owner. If the design
   needs anything BEYOND the schema (real sidechain compression), STOP —
   that is a library increment: record it beside stereo-ambient/region-
   acoustics in the queue, ship only what data carries.

### T-C — coop con Junior (owner-paced; the session supports and harvests)

1. **Pre-flight (BEFORE any connect):** both seats `git pull` — protocol
   v3 refuses mixed builds NAMED (that is the designed failure, not a
   bug); single-instance guard BOTH machines; Tailscale up; Junior's
   specifics live in `docs/JUNIOR.md`.
2. Launch: host `bin/host-coop.cmd` this machine · Junior joins per his
   runbook. **Both seats set `GAME_FRAME_PROBE=1`** — the coop playtest
   doubles as lag segment S1 (runsheet §S1; owner-paced, never nag
   mid-play; bot logs are never oracle evidence — these are HUMAN logs).
3. **Harvest after (bytes, verbatim):** both seats' `NETPLAY handshake`
   (expect version 3) + `TELEMETRY netplay` close lines + `TELEMETRY
   frame_probe` + `AUDIO drift` + `TELEMETRY sustain` (silent R-A2
   harvest). Junior's lines arrive via his seat's drafts or pasted —
   verbatim means verbatim. Bank md5-identical into
   `drafts/_lag-t2-evidence/`.
4. **T3 forensics only if context allows** (≤85%): per the previous
   spark's route — S0-J prediction MATCHED/DIVERGED said explicitly, who
   limited the lockstep + what ate its frame, spike-class verdict, ONE T4
   ticket, never implement the fix in-session. Context tight → bank
   evidence + checkpoint, T3 opens session 25. Partial evidence = bank
   what exists, name what is missing, never synthesize.

## Laws that bite (short list)

- Deterministic gates decide; a failed gate/critique BLOCKS ship.
- Presentation never mutates sim; audio is a pure sink (never
  sim/saves/netplay state).
- Measure before tuning — no balance value moves; ducking/gain moves are
  the owner-ordered audio lane, cite his verbatim per change.
- Read-before-edit · one-concern commits, explicit paths · hooks run the
  suite · long jobs DETACHED (never under a bash-call timeout; a
  disrupted gate is judged by a standalone re-run).
- Two instances fork the save — guard every launch; phantom sessions get
  NAMED in the checkpoint if debugging ever launches the game.
- JSON edits are SURGICAL text ops (a json re-dump reflowed 650 lines
  once — session-23 lesson); heredocs never inline in bash — temp files.
- Junior's lane (`drafts/_junior-*`, his machine docs) is his — harvest,
  never edit. Owner overrides are law the moment they land — one line.
- Never write into `~/workspace/game-two-lore` or any held sibling seat.

## Budget + stop conditions

One attended session ~2.5–3 h, context guard 85% → compact-checkpoint
skill. Council 0; the only sub-agent is T-A's fresh-eyes reviewer (+
bounded banking spokes if any new owner renders land). **Stop when:** T-A
fixed behind evidence + review PASS · T-B shipped data-only (or honestly
recorded as library-increment) · T-C pre-flight done + harvest banked (+
T3 verdict only if context allowed) · checkpoint + owner queue es-CR
(~5 líneas) + push. **Stop early, honestly, if:** the dup-bug evidence
contradicts the suspect (re-plan in writing, never force it) · a gate
fails non-mechanically · the owners redirect (their word is the router).
