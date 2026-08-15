# v15 pilot progress — BOTH SCRIPTS EXPORTED, wall next

**Update 2026-08-15 (session 3, late). quay6/7/8/9 all CLOSED. Both v15
scripts are exported, manifested (measured counts), committed
(`85d0b70`), and the duel gate already ran green once. Remaining: wall
16/16 -> perf -> suite -> CHECKPOINT -> push -> THIRTEENTH verify ->
v16 debate.**

## What shipped this session (commits, in order)

- `c77b4f2` balance: duel kill-box cleared (retune #1 — 6 nest guards
  out of x>=39; finding: 5 chants / 0 interrupts / 0 damage across 8
  instrumented quay6 attempts).
- `2f76956` balance: retune #2 — retune #1 had piled 5 guards onto the
  NW entry funnel; moved to dead corners ([4,1],[6,2],[6,18],[4,19],
  h[3,17]). NB [4,1]/[6,2] are still near the ENTRY spawn — good enough
  (drip is fightable) but geometry worth rechecking at v16.
- `a8b28b1` balance: **Varekka hunts the whole quay — aggro 10->45.**
  The decisive design fix: ~28 attempts proved the pack always enters
  at ~130-150 total hp and every route to the nest costs more; the
  spec's own fiction (force-taunt, ONE STANDS) says HE comes to YOU.
  Duel now happens at the door; chant/seize/interrupt untouched.
- `87ee19b` harness: start param grows `zone` key (World#start_in via
  enter_zone; TDD x3) — focused duel scenes.
- `85d0b70` feat: **low_quay_run + varekka_duel** committed with
  measured manifests.

## The two scripts (what the wall now exercises)

- `low_quay_run` (seed 13, start banked 2000, run_until 8611, 10
  captures): marks x3, seal 40 + seal 150 IN-RUN (gap #41 closed), all
  zone banners incl. First Vigil re-entry, vat heal + nest regrow x2,
  wipes + judgment, corpse-run loot, drop pickups x5, banked x2 (camp
  6 + nest 5). Manifest: seal 4 / banked 4 / tribute 4 / inscribed 6 /
  drops 10 / corpse 2 / regrown 6 (x2 double).
- `varekka_duel` (seed 7, start banked 600 + zone low_quay, run_until
  2683, 5 capture frames): ONE STANDS stamp, chant ring LIVE (check
  48), landed seizure (FLESH IS CALLED + underline, check 49),
  seizure_ended why=zone_left, chant_interrupted x2, kill (THE TERM IS
  PAID), fat drop 24 picked up. Manifest: engaged 2 / chants 6 /
  interrupted 4 / seized 2 / ended 2 / drops 2. Duel gate ALREADY
  GREEN once: vision PASS (18 checks incl. 47/48/49), determinism 5/5
  byte-identical. The rake abort seen on that run was an INFRA flake
  (critic API): rerunning the critic standalone PASSED.

## Authoring lessons (pay-once knowledge, keep)

- **Fresh-world runs are deterministic puzzles, not lotteries** — same
  seed + same inputs = same death tile; seeds 11/12 died IDENTICALLY.
  Author TAS-style: `reset N` + verbatim prefix + bifurcate at the
  failure, freeze-read (`state`/`dump <name>`) between short legs.
  Captures/state/dump are 0-tick — inserting them never diverges a
  verbatim replay.
- **Input traps**: `press <dir>` MOVES (tween ~13-19f) and an attack
  pressed mid-tween or mid-exhaust is SWALLOWED silently. Working
  strike loop: step (goto, straight last 2 tiles for facing) -> wait
  25-40 -> press attack -> wait 20 -> verify via dump hp.
  `press <dir>` INTO an occupied tile turns facing without moving.
  Two `press swap` need `wait 25` between them.
- **Goto chains break on possession death** — the heir runs the REST
  of the chain from the wrong spot; repeat waypoints for resilience,
  and never chain through doors (the duplicate re-navigates in the new
  zone; door tile for Keyward->camp is [0,13], camp->Keyward [19,5],
  nest->district [29,8], district->nest [0,13], low_quay exit [1,4]).
- **A parked pack body blocks door tiles** (goto burns its 3000-tick
  guard); swap to it, `hold <dir>`, swap back.
- Chant law (world.rb): starts only with POSSESSED <=7 tiles, pins that
  body, any damage to Varekka interrupts (+600f cooldown), completion
  lands wherever the pin went (no range recheck), pinned-dead = lands
  on nothing; cooldown after landed seize starts at seizure END;
  swap moves YOU off the pin (bait pattern).
- Home advances (v12): after wall wipes, home may be NEST not camp.
  Vat regrow (12/body) rebuilds a dissolved pack; marks-less wipe
  dissolves unmarked bodies.

## Remaining sequence

1. Gate A (low_quay_run) — running in background, teed to
   tmp/wall/low_quay_run_v15_a1.log.
2. WALL 16/16: `bash tmp/run_wall.sh` (low_quay_run + varekka_duel
   first, then the v14 fourteen) + `rake manifest` per script; verdicts
   from teed logs; retry 2 INFRA-only.
3. `rake perf` + full `bundle exec rake`.
4. CHECKPOINT.md delta + fetch + push junior-tibia (NEVER main).
5. THIRTEENTH blind verify (SPANISH; owner plays FIRST, no changelog;
   harvest /tmp/game_two_session_<pid>.log BEFORE questions; spec
   pre-registered questions + routing; disclose THE TERM IS PAID name
   swap AND the three balance changes — kill-box clear, funnel
   un-pile, aggro 45 — owner may veto any).
6. v16 debate (multiplayer spike etapa 1 LEAD; check Junior clone).
