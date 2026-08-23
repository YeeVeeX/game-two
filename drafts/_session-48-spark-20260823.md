# Session 48 spark — T4 brief cut: lobber-E per-spell growth (P10, mid/late bloomer)

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST, then the TOP entry of `docs/CHECKPOINT.md`
(s47 — wall re-author complete, 5/5 gates), then the progression spec
`docs/superpowers/specs/2026-08-22-progression-v1.md` §P10 + the T2/T3
close drafts for the shipped substrate (`drafts/_prog-t2-*.md`,
`drafts/_prog-t3-close-20260822.md`). Ruby per shell:
`export PATH="/c/Ruby34-x64/bin:$PATH"`.

**This is a BRIEF session (grill-and-ticket stage 2): write
`drafts/_prog-t4-lobber-growth.md`, ZERO code.** s49 executes. The
brief-writer reads everything, decides shape, defends decisions, and
cuts the wall/test debt list. Spell-growth data already lives in
`data/balance/progression.json` (`spell_growth.lobber.
special_impact_distances`: level 5 → +[2..5], level 8 → +[2..6]) —
shipped INERT by T2 (nothing reads it yet). T4 wires it.

## Job 0 — integrity gate

- `git fetch` → origin tip expected = the s47 docs commit above
  `0da0347` (scripts batch). Docs-only/disjoint peer deltas = GOOD;
  anything touching harness/scripts/ or sim = classify before
  proceeding.
- Save `98fe75edb6d72deab18cd48eaa88bdaf` mtime 08-20 15:51 · launcher
  logs 40, newest 08-21 01:39 · mail inbox EMPTY (two assets receipts
  in done/) · `drafts/_refs/` untracked.

## Brief must settle (argue each with touchstones, not vibes)

1. **Where the read happens**: lobber special resolve currently takes
   its impact distances from kit config — the seam for
   `Progression#special_impact_distances_for(kit)` (or equivalent)
   must keep Rule 3 (zero balance constants in code) and the
   world.rb ≤1800 cap (current 1795 — budget the touch; if it can't
   fit, name the extraction that rides the ticket, Crossing
   precedent).
2. **Threshold semantics**: `{"5": [...], "8": [...]}` — floor-match
   (highest key ≤ level) vs exact-match; what levels 1-4 read (base
   kit unchanged); integer-only law.
3. **Visual surface**: longer volley reach IS a Rule 2 visual change —
   which wall script proves it (aoe_specials straddles levels
   post-T2; the new stat-stable reels stage L5 — is a new
   `lobber_reach.json` script owed, or does an existing reel at the
   right level carry it?). Every visual claim = capture + critic.
4. **Wall debt**: the five s47 reels are L5-staged — lobber-E growth
   at L5 CHANGES lobber volley footprints in any reel where the
   lobber casts. Audit which s47/older reels have lobber
   special_started; cut the re-gate list into the ticket (the
   stat-stability law bounds the blast radius — that was its point).
5. **Telemetry**: does the progression TELEMETRY line grow a
   spell-growth field, or is reach proven by EventLog volley rows?
   (Measurement hygiene: the ritual's sim numbers stay frozen —
   reach data is presentation-lane evidence, argue why.)
6. **requires_level**: P10's sibling (`requires_level` beside
   `requires_defeats` on transitions) — in or out of T4's cut? Defend
   the boundary (T5 exists).

## Laws that bite

Ritual wording UNWRITTEN · live save untouched, md5 before/after ·
brief = ZERO code (the s45 precedent: brief-writer wrote nothing) ·
one-concern commits · sim numbers in `data/` move ONLY as the spec
already ratified (the spell_growth table is ratified data — wiring it
is the ticket; no NEW numbers) · owner-pending carry (never nag):
ear-checks · audio footstep/bed renders · coop S1 · SHARED-save first
crossing · J-5 spike call · WorldSmith proposal · R-A2 escalation call.

## After

Brief in `drafts/_prog-t4-lobber-growth.md` (decision record + ticket
cut + wall-debt list) · ONE checkpoint entry (Job-0 baselines for s49)
· s49 spark (T4 execute) clipboarded · commit docs + push (rebase over
peer work, never rewrite).

## Budget + stop

One session, brief only. Council 0 (design was ratified at the v19
foundation; this is shaping, not re-litigating). Sub-agents 0. Stop
EARLY on: defect-class Job-0 delta, a spec contradiction that needs an
owner call (name it, park it, stop), owner redirect.
