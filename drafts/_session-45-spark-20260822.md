# SPARK session 45 — cut the T3 BRIEF (presentation: HUD strip + level-up feel beat). Brief-writer NEVER implements.

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (v19 OPEN, four lanes), then the TOP entry of
`docs/CHECKPOINT.md` (s43+s44 — T2 SHIPPED), then
`docs/superpowers/specs/2026-08-22-progression-v1.md` (P4 feel beat,
P12, T3 ticket), then `drafts/_prog-t2-close-20260822.md` END TO END
(§T3 amendments + §Fresh-eyes review NITs are BINDING inputs), then
`drafts/_prog-t2-sim-core.md` for brief style (the house shape).
Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`.

## Job 0 — integrity gate

- `git fetch` → origin tip expected = the s44 docs commit (checkpoint +
  close draft + sparks) above `1fe5d8b`. Docs-only/disjoint peer deltas
  = GOOD (read, note, proceed); anything touching progression/HUD
  surfaces = classify before proceeding.
- Save `98fe75edb6d72deab18cd48eaa88bdaf` mtime 08-20 15:51 · launcher
  logs 40, newest 08-21 01:39 (`/tmp/game_two_session_*.log`) · mail
  inbox EMPTY · `drafts/_refs/` untracked by design.

## The job — ONE deliverable: `drafts/_prog-t3-presentation.md`

Grill-and-ticket stage 2 for T3 (spec T3 row): **level/XP HUD strip +
level-up feel beat (banner + pop)**. The brief-writer reads every file
region it names (read-before-edit is mechanical for the implementer;
give exact line anchors). Fold these BINDING inputs:

1. T2 close §T3 amendments 1–5: `:level_up` consumer + kills_xp HUD
   surface land here; EventLog `:level_up` decision carries the FULL
   versioned-bank cost (owner approval + stream-diff audit + history
   row — review NIT 2) — the brief must present it as an explicit
   decision with that price, not a default; flywheel staleness note;
   cross-machine canary note; telemetry duck law.
2. Review NIT 1 (save_state `cap` local shadow) — assign it to T3 ONLY
   if T3 touches save_state (unlikely); otherwise park it in the brief's
   out-of-scope list for the next save_state ticket.
3. Rule 2 law: HUD strip + feel beat are VISUAL surfaces — the brief
   owes a NEW wall script (committed with the ticket, wall debt paid
   same ticket), full gate critic ON, locale strings en/es-CR/pt-br
   (functional labels only, placeholder register, human-facing-output
   checklist), vision critique against the KB uiux rubric.
4. Cap laws: `window.rb` ≤ 300 (HUD lives in renderer files, event bus
   only); world.rb at 1790/1800 — T3 should NOT touch world.rb sim code
   (`:level_up` already emits; a renderer-side subscriber consumes it).
5. Feel beat precedent: kill_pops (transient render record, integer
   phase, digest-excluded) — now in `src/game/transients.rb`; a
   level-up beat that adds a transient goes THROUGH Transients, not new
   world.rb state.
6. Lane collision fence: J-6 non-pausing menu is a SEPARATE Lane-4 item
   (own state module); T3 must not absorb or block it.

Brief shape (house style): scope fence · commit plan (likely ONE
feat(hud) commit + wall script; feel beat same or second commit — you
decide and defend) · file/line anchors · new-test expectations ·
verify ladder (suite, gate, wall script, locale critique, live-save
hygiene, fresh-eyes review) · budget + stop. Sim numbers: NONE move in
T3 (measurement hygiene; presentation only).

## After the brief

Close draft not owed for a brief-cut; ONE checkpoint entry (top of
`docs/CHECKPOINT.md`, Job-0 baselines for s46) + s46 spark (T3
implementation) clipboarded. Commit docs + push (rebase over peer work,
never rewrite).

## Laws that bite

Brief-writer never implements (zero code edits) · live save untouched ·
ritual wording UNWRITTEN · owner-pending carry (never nag): ear-checks ·
audio T3 footstep/bed renders (water family needs a NEW mail) · coop S1
· SHARED-save first crossing · J-5 spike call · WorldSmith proposal
(INCOMING) · R-A2 escalation call (after the next real play session).

## Budget + stop

One session. Council 0 (design pinned by spec P4/P12 + T2 close).
Sub-agents: none (a brief cut needs no reviewer; the implementing
session gets the fresh-eyes gate). Stop when: brief committed →
checkpoint + s46 spark clipboarded → pushed. Stop EARLY on: defect-class
Job-0 delta, spec contradiction, owner redirect.
