# SPARK session 41 — T1: Progression extraction + save schema v2 (the first v19 code)

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST (v19 is OPEN — foundation double-ratified,
four lanes), then the top of `docs/CHECKPOINT.md` (s40 = ratification
harvested, cycle opened, Lane 1 grilled), then the ticket brief
`drafts/_prog-t1-extraction-schema-v2.md` END TO END and its spec
`docs/superpowers/specs/2026-08-22-progression-v1.md` (decisions
P3/P8/P14 are T1's law). Ruby per shell:
`export PATH="/c/Ruby34-x64/bin:$PATH"`.

## Job 0 — harvest gate (baselines from s40 close)

`git pull --ff-only` FIRST. Baselines: origin tip `253498a` · save
`98fe75ed…` mtime 08-20 15:51 · launcher logs 40, newest 08-21 01:39
· game-two mail inbox EMPTY. Expected GOOD deltas: Junior's task-2
discovery note (his provenance — read, never rewrite), his play logs
(human logs always bank), an assets-seat reply to the s40 receipts
(read; nothing owed back by default). Defect-class deltas preempt
(classify + ask).

## The job — implement ticket T1 (one ticket, one session, this one)

Carve `Game::Progression` out of world.rb (AT its 1800 cap) + save
schema v2 with the one-hop v1 upgrade + the round-trip test lane
FIRST. NO behavior change a capture can see: level fixed at 1, no XP
awards, no stat growth, digest byte-form FROZEN (DIGEST_VERSION stays
1 until T2). The brief's four verify steps bind: suite green ·
`wc -l src/game/world.rb` strictly < 1800 · double-capture md5 on
world_loop · netplay_session gate. Fresh-eyes review before ship
(grill-and-ticket stage 4): headless scrubbed pi over the diff + the
brief; a failed review blocks (Rule 6). Verify output + review
verdict land in `drafts/_prog-t1-close-<date>.md`.

## Laws that bite today

- The LIVE save `saves/world.json` (`98fe75ed…`) is the owners'
  progress — tests run on fixtures only; never launch a save-owning
  seat during the ticket; the backup lane is proven on fixtures.
- Read-before-edit every file (world.rb regions named in the brief).
- One-concern commits; hooks run the suite; never `--no-verify`.
- Measurement hygiene: ritual question wording stays UNWRITTEN;
  R-A2 stays silent in logs.

## Budget + stop

One session. Council 0. Sub-agents: the fresh-eyes reviewer only
(read-only brief; touch NOTHING, including seat mail). Stop when:
harvest classified → T1 implemented → 4 verifies green → fresh-eyes
pass → close draft → commit, push, checkpoint, s42 spark clipboarded.
Stop early on owner redirect, defect-class delta, or if T1 outgrows
the session (checkpoint the partial honestly — never half-ship).
