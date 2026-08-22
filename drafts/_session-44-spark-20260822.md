# SPARK session 44 -- finish T2: Commit C + owner-approved canary rebank -> verify ladder -> close + push

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (v19 OPEN, four lanes), then the TOP entry of
`docs/CHECKPOINT.md` (s42 -- NOTE: s43 wrote NO checkpoint entry; this
spark + the local git state ARE the s43 record), then the BRIEF
`drafts/_prog-t2-sim-core.md` END TO END (execution artifact), then
the spec `docs/superpowers/specs/2026-08-22-progression-v1.md`
(P2/P4/P5/P11/P12/P13 + cap law) and
`drafts/_prog-t1-close-20260822.md` section T2-amendments.
Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`.

## S43 inheritance (all LOCAL, nothing pushed)

- **Commit A SHIPPED** `10c176b` `fix(save)`: bak_hint mtime pick +
  `@v1_raw` cleared at the top of load + 2 tests. Hook suite
  1047 runs / 0F.
- **Commit B SHIPPED** `84a9d7a` `refactor(world)`: `Game::Transients`
  carve (`src/game/transients.rb` + unit test; world.rb 1797 -> 1775;
  combat clock vs banner clock keep their distinct pause laws;
  renderer API frozen via delegators). Hook suite 1051 runs / 0F.
  The brief's BLOCKING pre-C identity gate is DONE and recorded:
  worktree @ `10c176b` (old) vs `84a9d7a` (new), `rake capture` md5
  sets IDENTICAL -- world_loop 10/10 PNGs, varekka_duel 5/5 PNGs.
  Transcribe this evidence into the close draft; do NOT re-run it.
- **Commit C is STAGED in the working tree** (index == worktree,
  15 files), hook-blocked by exactly 3 known red lanes (Job 1).
  Content already in place: award_kill in the actor_died handler
  (killer faction :pack) -> `:level_up` registered + emitted (ZERO
  subscribers) -> `Pack#sync_max_hp!` + `Creature#grow_max_hp!` (P4:
  hp gains the delta, clamp floor 1, dead flesh keeps 0) *
  `leveled_damage` at the 3 resolution sites, launch-time damage
  pinned on in-flight projectiles/impacts * digest rows level/xp +
  `DIGEST_VERSION` 1 -> 2 * save-apply REORDER (counters+progression
  -> sync leveled max -> member hp clamps against the LEVELED
  ceiling) * `TELEMETRY progression level= xp= kills_xp=` line (P12,
  additive-only; chain_check regexes untouched) * growth/kill_xp
  shape pins Integer-forced in the Progression ctor (spell_growth
  untouched, T4) * new tests: progression unit rows (award_kill
  table/refusal/kills_xp-at-cap, damage/hp identity + truncation),
  progression_integration (kill -> XP -> level_up -> stats -> digest;
  human-killer no-feed; 3-site damage + launch-time pin),
  progression_data zone-coverage, creature grow lanes, pack sync
  lanes, save_state reorder lanes (level-5 round trip clamp-free +
  lowered-growth clamp warns), state_digest pins + mutation row,
  telemetry line pins. `data/balance/progression.json` UNTOUCHED
  (starter numbers frozen -- measurement hygiene).

Staged C set (verify EXACTLY this at open; `git stash list` empty):
M src/game/{creature,pack,progression,save_state,telemetry,world}.rb
M src/net/state_digest.rb
M test/game/{creature,pack,progression,save_state,telemetry}_test.rb
M test/net/state_digest_test.rb
A test/game/progression_data_test.rb
A test/game/progression_integration_test.rb

## OWNER DECISION (Gabriel, s43 chat) -- versioned canary bank. RECORD IT.

T2 legitimately moves 2 of the 3 banked etapa-0 EVENT-stream md5s in
`test/harness/sim_identity_canary_test.rb`: stat growth compresses
kill timing after the first level-up. The owner APPROVED a VERSIONED
bank:
- The v17 etapa-0 hashes become an IMMUTABLE HISTORY constant
  (provenance `drafts/_junior-etapa0-20260815.md`, cross-machine 3/3)
  -- preserved forever, never asserted against, never deleted.
- The ACTIVE bank records: date, owner approval, the ratified sim
  change that moved it (T2 progression, spec P2/P4/P5), and where the
  audit lives (the T2 close draft).
- The law KEEPS ITS TEETH (rewrite the file header to say so): a miss
  against the ACTIVE bank stays a blocking DEFECT -- fix the change,
  never rebank -- UNLESS a new ratified sim change repeats this exact
  protocol (owner approval + stream-diff audit + history preserved).
Record the decision as ONE line in the close draft AND the checkpoint.

s43 measured (your suite re-measures these live -- cross-check only):
- world_loop   a4150c43669b9783e59cb6c39c322b67  UNCHANGED (ends L1, xp 45)
- varekka_duel 68fa69f6e23f0ae39361eec2fbc8c5d1  was 22dbad12... (L3, kills_xp 240)
- burn_duel    fedf0452fc35b62850895016710abdea  was d148b838... (L2, kills_xp 140)
If YOUR measurement differs from these, STOP and surface
(nondeterminism or a foreign delta -- never bank an unreproduced
number).

## Job 0 -- integrity + delta gate (FETCH, not pull: local is ahead 2 with staged work)

- `git fetch` -> origin/main expected `97964ed`. If it moved: READ the
  new commits (read-only), classify -- docs-only / disjoint-file peer
  work = GOOD (rebase at push time, AFTER C is committed; never
  rewrite peer commits); anything touching T2's files = defect-class
  -> stop + surface.
- Local: HEAD `84a9d7a`, branch ahead 2, staged set exactly as listed.
- Live save `saves/world.json` md5 `98fe75edb6d72deab18cd48eaa88bdaf`
  (341 B, mtime 08-20 15:51) * launcher logs 40, newest 08-21 01:39
  (`/tmp/game_two_session_*.log`) * mail inbox EMPTY * untracked
  `drafts/_refs/` = 8 reference images, untracked by design *
  `tmp/t2_identity/` = s43 identity-gate evidence (disposable; the
  numbers above are the record).

## Job 1 -- flip the 3 red lanes, then land C as ONE commit (P13)

Read-before-edit is mechanical: READ every file before touching it.

1. `test/game/v14_telemetry_test.rb` (~line 131) -- its duck world
   lacks `.progression`; `Telemetry#progression_summary` reads
   `@world&.progression`. Fix the TEST duck (singleton `progression`
   returning nil; nil renders the honest zeros) -- house pattern:
   ducks grow with the World duck-type. Do NOT respond_to?-guard
   telemetry (it would hide real API drift). Any other red summary
   consumer gets the same treatment.
2. `test/harness/sim_identity_canary_test.rb` -- implement the
   versioned bank per the owner decision (history constant + ACTIVE
   bank + header-law rewrite). Keep the 3 test methods asserting the
   ACTIVE bank only.
3. **STREAM-DIFF AUDIT (blocking precondition for the rebank).**
   `git worktree add --detach tmp/t2_audit/old 84a9d7a`, then run the
   headless driver on BOTH builds for all 3 scripts and diff the
   EVENT streams. Driver shape (STAGE AS A TEMP .rb FILE, run,
   delete -- never inline heredocs): from each build's root,
   `bundle exec ruby -Itest -Isrc <tmpfile>.rb` requiring
   "support/headless_script", calling
   `Headless.run_script("harness/scripts/<n>.json", data_dir: "data")`
   for world_loop/varekka_duel/burn_duel, writing `r.lines` to
   `tmp/t2_audit/<build>/<n>.events` and printing `r.md5`. The
   `-Isrc` flag is REQUIRED (-Itest alone LoadErrors). On the NEW
   build also subscribe `world.bus.subscribe(:level_up)` in the temp
   driver and record the frame of the FIRST `:level_up` per script.
   PASS criteria:
   (a) world_loop streams byte-identical across builds (proves
       level-1 identity: zero drift before any level-up);
   (b) for varekka_duel and burn_duel, the old stream is a byte-exact
       PREFIX match up to the new build's first `:level_up` frame --
       divergence begins only AFTER it (level-1 damage is identity,
       so the boundary kill itself must match);
   (c) every divergent line traces to leveled damage (kill-timing
       compression and its knock-on drop/respawn/attack_hit shifts);
       the SET of event types (`grep -oE '^EVENT [a-z_]+' | sort -u`)
       is IDENTICAL across builds -- `:level_up` is NOT in
       harness/event_log.rb's curated list and must NOT be added in
       T2 (T3 owns the level-up beat and may revisit).
   Paste first-divergence frames + line counts + a 3-5 line
   explanation into the close draft. ANY unexplained line = STOP and
   surface: that is a real sim-identity break hiding under an
   approved rebank. `git worktree remove` when done.
4. `git add` the two test files + commit EVERYTHING as ONE commit
   through the hooks (P13: digest rows + version bump + award hook +
   the canary consequence ride together):
   `feat(progression): T2 sim core - kill XP, level-up stats, digest v2, telemetry`
   Expected suite ~1068+ runs / 0F (B baseline 1051 + C lanes).
   Never `--no-verify`.

## Job 2 -- verify ladder (in order; silent-on-pass, verbose-on-fail)

1. Full Rule 2 gates, critic ON (frames move lawfully; the gate is
   within-build double replay + vision, not old-frame equality):
   `rake gate SCRIPT=harness/scripts/world_loop.json` then
   `...varekka_duel.json` -- run DETACHED (nohup + poll by process
   count / log tail, ~5 min/script; NEVER under a bash-call timeout
   -- project memory: a timeout once killed the critic mid-gate and
   forged a false negative).
2. All three netplay gates, detached, sequential:
   `rake gate SCRIPT=harness/net/netplay_{session,desync,conn_lost}.json
   CHECKS=harness/net/gate_checks.json` -- digest v2 on the wire both
   seats; the desync scene must still convict; refusal naming the
   `digest version` field stays suite-proven (fingerprint reads the
   live constant; the 7 fixtures hardcoding digest_version: 1 are
   seat-consistent fakes -- expected untouched).
3. `rake perf` -- p95 tick < 16.6 ms (damage_for is per-hit Integer
   math; max_hp_for runs only at level-up/apply time).
4. `wc -l src/game/world.rb` -- 1790 at s43 close; target <= 1795,
   hard cap 1800.
5. P11 pacing script (tmp/, NOT committed): per level 2..cap -- dE(L),
   cumulative XP, kills-to-level per kit (ceil), hours-per-level under
   a DECLARED kills/hour (derive from the newest human launcher logs
   if trivially greppable, else declare 60/h in the table header).
   Sanity rows: dE(2)=80 -> 6 rusher or 10 husk; challenger 120 alone
   = L2 + 40 spill. FULL table -> close draft. **Commit D ONLY if the
   table demands a retune** (targets: single-digit kills to level 2,
   tens by mid-cap; starters move only via D, table pasted in its
   commit message).
6. Live-save hygiene: `md5sum saves/world.json` unchanged
   (`98fe75ed...`); never launch a save-owning seat; fixtures only.
7. Fresh-eyes review (Rule 6, BLOCKING): headless SCRUBBED pi
   (`env -u PI_CODING_AGENT -u PI_SESSION_FILE -u PI_SESSION_ID pi -p`),
   READ-ONLY brief, **touch NOTHING including seat mail** (s41
   lesson). Scope: diff `97964ed..HEAD` (A+B+C) + the T2 brief + the
   spec + the canary owner decision QUOTED IN FULL in the review
   brief (a starved reviewer false-BLOCKs -- global memory
   2026-08-21). Verdict + nits -> close draft. A failed review blocks
   the push.
8. Close draft `drafts/_prog-t2-close-<date>.md`: A/B/C records with
   hook counts + s43's OLD_VS_NEW evidence (from this spark) *
   stream-diff audit * pacing table * the canary owner-decision line *
   T3 amendments, at minimum: `:level_up` consumer + kills_xp HUD
   surface land in T3; EventLog curated-list call deferred to T3; the
   brief's flywheel note (pre-T2 clip/critique baselines are stale
   where replays cross a level-up -- sampling-artifact law);
   cross-machine note: Junior's next hook run re-proves the new bank
   on his machine -- if HIS suite reds on the canary, that is the
   cross-machine sim-identity signal: surface, never rebank.
9. Checkpoint entry covering s43+s44 (ONE entry at the top of
   `docs/CHECKPOINT.md`, with Job-0 baselines for s45) + s45 spark
   (next move: CUT THE T3 BRIEF -- presentation: level/XP HUD strip +
   level-up feel beat, new wall script + full gate + locale labels;
   brief-writer never implements; carry the owner-pending list,
   never nag). Clipboard the s45 spark.
10. Push: if origin moved, rebase local commits over peer work (never
    rewrite theirs); the pre-push hook reruns the suite. Push
    A+B+C(+D) together, gates green FIRST -- never push an ungated
    sim/visual change.

## Laws that bite today

- The live save is the owners' progress -- fixtures/copies only.
- Measurement hygiene: ritual wording UNWRITTEN; k/cap/kill_xp/growth
  move ONLY via Commit D's pasted table.
- NO visual surface in T2 (HUD/feel = T3); `:level_up` keeps zero
  subscribers; persist-line vocabulary + soak chain_check regexes
  frozen.
- One-concern commits; read-before-edit; `drafts/_refs/` stays
  untracked; other sessions may share the cwd -- touch only T2 files.

## Budget + stop

One session. Council 0 (design pinned by spec + brief + recorded
owner decision). Sub-agents: the Rule 6 reviewer ONLY. Stop when:
C committed -> ladder green -> close draft + checkpoint + s45 spark
clipboarded -> pushed. Stop EARLY on: unexplained stream-diff line,
defect-class Job-0 delta, spec contradiction, owner redirect. C is
atomic -- never split the P13 set. If context tightens mid-ladder:
land committed work, write an honest checkpoint naming exactly which
ladder rungs remain, hand the rest to s45 -- never push ungated.
