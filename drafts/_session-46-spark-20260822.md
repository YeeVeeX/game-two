# SPARK session 46 — execute the T3 brief (presentation: HUD strip + level-up feel beat). TWO commits, full wall sweep.

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (v19 OPEN, four lanes), then the TOP entry of
`docs/CHECKPOINT.md` (s45 — T3 brief cut), then the brief
`drafts/_prog-t3-presentation.md` END TO END (it is the ticket — scope
fence, decisions 1-5, anchors, ladder all bind), then
`docs/superpowers/specs/2026-08-22-progression-v1.md` (P4/P12, T3 row)
and `drafts/_prog-t2-close-20260822.md` §T3 amendments for context.
Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`.

## Job 0 — integrity gate

- `git fetch` → origin tip expected = the s45 docs commit (T3 brief +
  checkpoint + this spark) above `91fdc00`. Docs-only/disjoint peer
  deltas = GOOD (read, note, proceed); anything touching progression/
  HUD/renderer surfaces = classify before proceeding.
- Save `98fe75edb6d72deab18cd48eaa88bdaf` mtime 08-20 15:51 · launcher
  logs 40, newest 08-21 01:39 (`/tmp/game_two_session_*.log`) · mail
  inbox EMPTY · `drafts/_refs/` untracked by design.

## The job

Implement the T3 brief exactly:

- **Commit A `feat(hud)`** — level/XP strip in `draw_hud` + display
  keys + `hud.level` strings ×3 + `hud_level_strip_reads` check +
  strings-parity test.
- **Commit B `feat(feel)`** — Transients `level_up_pops` + world.rb
  pushes (net ≤ +6, final ≤ 1796 — STOP if it won't fit) + banner
  suffix + `draw_level_pops` + `stamp.level_up` strings ×3 + harness
  `progression` start param + `harness/scripts/level_up_beat.json` +
  `level_up_beat_reads` check.
- Read EVERY file region the brief names before editing
  (read-before-edit is mechanical). The brief's line anchors were
  verified on `91fdc00` — re-verify against live files.

## Laws that bite

Decision 1 stands: `:level_up` does NOT enter `harness/event_log.rb`
(the versioned-bank price is recorded in the brief — re-litigating it
needs owner word) · zero sim-number moves (measurement hygiene; new
display/strings keys are lawful) · zero window.rb lines (J-6 is a
separate Lane-4 item) · save_state.rb untouched (NIT 1 stays parked) ·
live save untouched, md5 before/after · ritual wording UNWRITTEN ·
code FROZEN during the wall sweep · owner-pending carry (never nag):
ear-checks · audio footstep/bed renders · coop S1 · SHARED-save first
crossing · J-5 spike call · WorldSmith proposal · R-A2 escalation call.

## Verify ladder (the brief's §Verify binds — run it in order)

Suite per commit via hooks → post-A SKIP_CRITIC world_loop (iteration
aid) → post-B full gate on `level_up_beat.json` (critic ON) + telemetry
grep → FULL `harness/run_wall.sh t3-hud` DETACHED (~2h, all ~22
scripts; never under a bash-call timeout) → netplay gates ×3 →
KB-rubric vision critique (`hub kb query --domain uiux-design`) →
locale critique en/es-CR/pt-br (blocking) → `rake perf` → caps
(world.rb ≤ 1796, window.rb 217) → live-save md5 → Rule 6 fresh-eyes
review (read-only, touch NOTHING including seat mail).

## After

Close draft `drafts/_prog-t3-close-<date>.md` (gate + critique
verdicts, world.rb arithmetic, T4/T5 amendments) · ONE checkpoint
entry (Job-0 baselines for s47) · s47 spark (T4 lobber-E growth or T5
requires_level — pick by session availability, spec sequencing allows
either) clipboarded · commit docs + push (rebase over peer work, never
rewrite).

## Budget + stop

One session. Council 0. Sub-agents: the Rule 6 reviewer only. Start
the detached sweep right after Commit B goes green; run reviewer +
locale critique during it. If context tightens: ship A alone with its
full ladder, hand B to the next session. Stop EARLY on: defect-class
Job-0 delta, world.rb not fitting ≤ 1796, the same gate check failing
twice for the same reason, spec contradiction, owner redirect.
