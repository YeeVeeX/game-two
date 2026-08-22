# SPARK session 43 — implement T2 (Progression sim core) per the brief

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (v19 OPEN, four lanes), then the top of
`docs/CHECKPOINT.md` (s42 = T2 brief cut; R-A2 premise corrected),
then the BRIEF `drafts/_prog-t2-sim-core.md` END TO END — it is the
execution artifact and carries file-line detail, commit plan, verify
steps, and the done condition. Spec backstop:
`docs/superpowers/specs/2026-08-22-progression-v1.md`
(P2/P4/P5/P11/P12/P13 + the cap law) and
`drafts/_prog-t1-close-20260822.md` §T2-amendments. Ruby per shell:
`export PATH="/c/Ruby34-x64/bin:$PATH"`.

## Job 0 — harvest gate (baselines from s42 close)

`git pull --ff-only` FIRST. Baselines: origin tip `e067c95` + the s42
checkpoint commit above it (this session's own dispatch artifact) ·
save `98fe75ed…` mtime 08-20 15:51 · launcher logs 40, newest 08-21
01:39 · game-two mail inbox EMPTY. Expected GOOD deltas: Junior play
logs / peer commits (read + rebase over, never rewrite); a human
post-T1 launch auto-upgrades the save to v2 WITH a schema1 backup —
verify backup exists + TELEMETRY shows schema=2, then it's GOOD.
Defect-class deltas preempt (classify + ask).

## Job 1 — execute the brief (grill-and-ticket stage 3)

Three commits, in order, each through the hooks (suite green, never
`--no-verify`):

- **A** `fix(save)`: bak_hint mtime pick + @v1_raw hygiene + tests.
- **B** `refactor(world)`: carve `Game::Transients` (cosmetic records)
  — BLOCKING old-vs-new worktree byte identity (world_loop +
  varekka_duel) before C starts.
- **C** `feat(progression)`: award_kill on actor_died → :level_up →
  stats live · digest rows + DIGEST_VERSION 1→2 (ONE commit, P13) ·
  `TELEMETRY progression level= xp= kills_xp=` line · shape pins +
  data test · save-apply reorder (leveled max before hp clamp).
- **D (only if the pacing table demands):** starter retune with the
  table in the commit message.

Then the verify ladder exactly as the brief lists it: full gates on
world_loop + varekka_duel (critic ON) · all three netplay gates ·
`rake perf` · world.rb ≤ 1795 target · pacing table into the close
draft · live-save md5 unchanged · fresh-eyes review (headless scrubbed
pi, read-only, touch NOTHING including seat mail) · close draft
`drafts/_prog-t2-close-<date>.md` + checkpoint + s44 spark. Gates run
DETACHED (~5 min/script), never under a bash-call timeout.

## Laws that bite today

- The LIVE save `saves/world.json` is the owners' progress — fixtures
  only; never launch a save-owning seat.
- Read-before-edit every file (the brief's line refs are a map, not a
  substitute). One-concern commits.
- Measurement hygiene: ritual wording UNWRITTEN; k/cap/kill_xp/growth
  are tunable starters until the ritual stages — they move ONLY via
  the pacing script's table (P11).
- T2 ships NO visual surface (HUD/feel beat = T3): `:level_up` has
  zero subscribers; persist line + soak oracle untouched.

## Budget + stop

One session. Council 0 (design pinned by spec + brief). Sub-agents:
the Rule 6 reviewer only. Stop when: harvest classified → A+B+C green
+ gated + pushed → close draft + checkpoint + s44 spark clipboarded.
Context tight: A and B are independently shippable; stop BEFORE C
rather than half-ship the P13 one-commit set. Stop early on owner
redirect, defect-class delta, or spec contradiction (surface, never
invent).
