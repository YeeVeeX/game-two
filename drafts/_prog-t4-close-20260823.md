# T4 CLOSE — lobber-E per-spell growth (P10) SHIPPED — s49, 2026-08-23

Ticket: `drafts/_prog-t4-lobber-growth.md` (s48 brief — decisions D1–D7
all HELD, zero deviations of substance; one authoring-shape deviation
recorded below). Spec: P10/P5/P7/P13. Two one-concern commits on
`139d812`:

- **A `4ffc5f1` refactor(world):** `Game::Volleys` plain object carved
  (records, launch geometry, delay tick + hit resolution via injected
  callables, `clear!`, `digest_groups`) + `test/game/volleys_test.rb`
  (9 lanes). world.rb 1795 → **1764** (headroom restored; renderer.rb
  BYTE-frozen, frozen `impacts` delegator, tick call at the exact old
  position, hitstop comment moved with it).
- **B `61f65fe` feat(progression):** ctor parses/validates/freezes
  `spell_growth` (D2 pins: hard fetch, `{}` legal, base-10 Integer
  thresholds, threshold>level_cap refuses NAMED "dead row", non-empty
  positive-Integer arrays, unknown spell keys refuse); reader
  `special_impact_distances_for(kit_name, base:)` floor-match, L1–4 =
  base by IDENTITY; world `volley_distances` beside `leveled_damage`
  (P7 faction guard, both level laws one home) + launch swap; test
  lanes 2–5; NEW wall script `lobber_reach.json` (23rd) +
  `lobber_reach_reads` check. world.rb lands **1775** (< 1795 ✓, suite
  cap stays 1800 per brief lane 6).

## Wall-script authoring (the instrumented-run record)

Pilot session (seed 11, staged `{level:5, xp:0}` + `start.zone
district`), 4 takes; the throwaway driver (tmp/pilot/t4) DELETED per
T3 amendment 2. What the takes taught, banked for future authoring:

- **Ally kill-steal is the dominant staging hazard**: the striker
  (step 15, aggro 8) intercepted and killed THREE consecutive
  hate-locked approachers mid-corridor (takes 2–4); its knockback also
  broke one otherwise-perfect walk-in (blocker shove at d6 displaced
  the victim off the d5 timeline — first cast whiffed empty, lawful
  in-reel).
- **The beat that shipped**: east-cluster wave triggered at (32,23),
  retreat to (22–23,23); `rusher_hater27` hate-peeled off the blocker
  brawl (`human_retargeted cause=hate` ×2 in-reel — the mechanic's
  first wall exposure), walked the open row-23 boulevard; press at its
  FRESH d8 tile-flip (16f/tile occupancy window makes ±8f poll jitter
  safe: impact = press+51 lands 48–64f after the d8 flip = inside the
  d5 window); volley (46 dmg at L5) killed the 17hp victim ON the
  farthest bracket.
- **Byte proof in-reel**: `special_started frame=2560` → `attack_hit
  frame=2610 attacker=lobber` (= 2560+10 windup+40 delay, exact) →
  `actor_died frame=2610 killer=lobber` → `drop_spawned tile=[28,23]`
  = caster (23,23) + 5. `TELEMETRY progression level=5 xp=380
  kills_xp=380` in every replay log.
- **Deviation from the brief's beat sketch (authoring latitude,
  recorded)**: the victim was softened by the ally brawl (17hp at
  cast) rather than arriving fresh, so the d5 impact IS the kill —
  strictly stronger evidence than the brief's hit-then-finish shape.
  The 2 in-reel `special_started` (one whiff + the beat) both render
  4-bracket chains; captures [2555, 2585, 2605, 2609, 2610, 2660];
  manifest floors = true counts {special_started 2, attack_hit 63,
  actor_died 23} per replay.

## Verify ladder (all green)

- Suite via hook: baseline 1075 → post-A **1084** → post-B **1097**
  runs, 0F (sim-identity canary bank — world_loop/varekka/burn event
  streams — green inside it, both commits; ACTIVE md5s untouched).
- **Below-threshold identity, both commits**: SKIP_CRITIC double
  replays byte-identical (14 specials_chain + 10 world_loop frames)
  AND all 24 frames byte-identical vs a `139d812` pre-carve WORKTREE
  (tmp/wt-precarve, removed at close) — post-A and AGAIN post-B
  through the live hook. specials_chain md5 never moved (the stop
  condition never fired).
- Stale-bank note: `rake canary` vs `tmp/canary_baseline/` FAILS on
  frame_0029 for specials_chain — **pre-dates T4** (identical fail at
  the 139d812 worktree; that pixel bank is pre-T3-HUD). D4's "canary
  bank" = the EVENT-STREAM bank in the suite, which is green. The
  pixel-bank staleness is inherited debt, not T4's.
- **Netplay session gate (critic ON) at A: PASS** — 12 captures
  byte-identical ×2, vision PASS (the digest impact-fold move proven
  end-to-end over loopback). Desync/conn_lost not owed (D7: no wire
  shape change, DIGEST_VERSION untouched).
- **Full critic-ON gate on lobber_reach.json: PASS** + `MANIFEST
  PASS: special_started=4 attack_hit=126 actor_died=46` (teed log =
  2 runs). First gate run FAILED on `special_pips_track` — verified
  against code + exact pixels per the sampling-artifact law and
  REFUTED: pip at (319,63) reads (255,255,255) ready pre-cast
  (f2555) → (50,20,30) spent mid-delay (f2585, f2609); exhaust set in
  `start_special` (creature.rb:173). Critic hallucination; re-gate
  PASS with the same frames. Evidence stands here; nothing rebanked,
  nothing weakened.
- Live save `98fe75edb6d72deab18cd48eaa88bdaf` byte-identical open →
  mid → close. `git diff data/` EMPTY. Mail inbox untouched (audited
  post-review).
- **Fresh-eyes review (Rule 6): PASS, 0 blockers, 4 NITs** — scrubbed
  headless pi over diff+brief+spec, read-only, seat mail untouched
  (its `ruby -c` was seat-lease-blocked and it correctly did not
  route around). Independently verified: renderer 0-byte diff, digest
  fold byte-equivalence + all seven old `@impacts` references
  accounted, D2 pin-by-pin, P7 guard, D5/D7 fence greps, lanes 1–6
  honest (lane 4's enemy half judged "beats the waive clause" — real
  creature through the real launch), world.rb 1775, check wording
  judgeable from pixels.

## Scope-fence audit

Zero `data/**` moves ✓ · renderer.rb byte-frozen ✓ · no
strings/locale keys ✓ · no TELEMETRY field (D5) ✓ · no
DIGEST_VERSION bump (D7) ✓ · no soak-regex change ✓ · no save-schema
touch ✓ · window.rb untouched ✓ · ritual wording UNWRITTEN ✓ ·
one-concern commits ✓ · council 0, sub-agents 1 (the Rule 6 reviewer
only) ✓.

## Amendments for T5 / next brief-cutters

1. **(reviewer NIT, dormant)** `lobber_reach_reads` says "spans FOUR
   contiguous tiles" — a future L8+ staged reel shows FIVE and a
   literal critic could false-fail. Amend to "four or more" whenever
   the check text next moves lawfully (recalibration precedent, T3
   NIT 1). No L8 reel exists today.
2. **(reviewer NIT)** duplicate-parse threshold keys (`"5"` + `"05"`)
   refuse nowhere; deterministic winner via sort order, cross-seat
   identical — silent ambiguity only. A one-line uniqueness assert
   belongs to whichever ticket next touches the ctor or the
   data-coherence lane.
3. **Authoring shelf**: the d8-fresh-flip press rule (impact lands
   3f into the d5 occupancy window; tolerates ±13f staleness) and the
   hate-peel staging trick (`cause=hate` retarget is the only
   deterministic approach-line in a live district) are reusable for
   any future timed-impact reel.
4. The pixel canary bank (`tmp/canary_baseline/`) is stale since
   T3's HUD strip for HUD-bearing reels; if a future session wants
   pixel canaries again it owes a re-bank from a sim-identical line
   (owner-word protocol), or keeps trusting the event-stream bank.

## Owner-visible (never nag)

- **Junior's L8 solo save reads the "8" row on his next launch:
  lobber E reach 4 → 6 tiles.** Feature, not bug — the mid/late
  bloomer landing as ratified; organic first exposure outside ritual
  sessions (novelty quarantine satisfied for his seat).
- The shared save (both L1) is untouched; the pack earns the
  thresholds by playing.
- The FEEL verdict (mid/late bloomer) stays with the humans'
  sessions / the ritual's free verdict — no wording owed now.
