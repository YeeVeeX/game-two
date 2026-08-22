# SPARK session 42 — cut T2's brief (sim core), then Lane-2 stage 0 if room

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (v19 OPEN, four lanes), then the top of
`docs/CHECKPOINT.md` (s41 = T1 shipped: Progression carved, schema v2
+ upgrade lane live), then the spec
`docs/superpowers/specs/2026-08-22-progression-v1.md` END TO END and
the T1 close draft `drafts/_prog-t1-close-20260822.md` (§T2-amendments
binds T2's brief). Ruby per shell:
`export PATH="/c/Ruby34-x64/bin:$PATH"`.

## Job 0 — harvest gate (baselines from s41 close)

`git pull --ff-only` FIRST. Baselines: origin tip `3ef273f` · save
`98fe75ed…` mtime 08-20 15:51 · launcher logs 40, newest 08-21 01:39
· game-two mail inbox EMPTY. Expected GOOD deltas: Junior play logs
(human logs always bank; a post-T1 launch auto-upgrades the save to
v2 WITH a schema1 backup — that save moving is EXPECTED then, verify
the backup exists + TELEMETRY shows schema=2), assets-seat replies.
Defect-class deltas preempt (classify + ask).

## Job 1 — cut ticket T2's brief (grill-and-ticket stage 2; NO implementation)

T2 = sim core: XP-on-kill → level → stats live (P2/P4/P5), digest
rows + DIGEST_VERSION 1→2 one commit (P13), TELEMETRY level line
(P12), pacing script + starter numbers (P11), perf gate (damage_for
is per-hit). Fold in ALL five §T2-amendments from the T1 close draft
(bak_hint fix, @v1_raw hygiene, data-shape pins, award_kill wrapper +
:level_up event, loaded-line nuance = recorded only). Brief carries
file-line detail (read the live files — world.rb actor_died region,
progression.rb, state_digest, telemetry surfaces), verify steps
(suite + netplay gates + perf + wall re-baseline ONLY if a visual
moved — T2 should have NO visual surface; HUD is T3), and the
done-condition. Land it as `drafts/_prog-t2-sim-core.md`, one docs
commit. The brief-writer never implements: T2 lands s43.

## Job 2 — ONLY if the session has room: Lane-2 stage 0 (R-A2)

Sustain discoverability (foundation B-lane rider, strings+renderer):
surface the provision verb where the owners keep missing it. Its OWN
one-concern commit, full Rule 2 gate + wall script (visual change =
wall debt paid same ticket), locale strings en/es-CR/pt-br functional
labels only. R-A2 stays SILENT in logs (`bought=0` law — no new
telemetry). Drop honestly if context is tight — never half-ship a
gated surface.

## Laws that bite today

- The LIVE save `saves/world.json` is the owners' progress — fixtures
  only; never launch a save-owning seat.
- Read-before-edit every file. One-concern commits; hooks run the
  suite; never `--no-verify`.
- Measurement hygiene: ritual wording UNWRITTEN; the SIM numbers the
  ritual measures freeze at staging — T2's starter constants are
  tunable until then, but land them via the pacing script's table.

## Budget + stop

One session. Council 0. Sub-agents 0 (brief-cutting is hub work; the
fresh-eyes reviewer belongs to s43's implementation). Stop when:
harvest classified → T2 brief landed + committed → (optional) R-A2
shipped through its gate → checkpoint → s43 spark clipboarded. Stop
early on owner redirect or defect-class delta.
