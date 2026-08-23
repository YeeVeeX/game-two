# T5 CLOSE — `requires_level` machinery (P9) shipped — s51, 2026-08-23

Brief executed end-to-end: `drafts/_prog-t5-requires-level.md` (md5
`5d33312e…`, the binding ticket). **Lane 1 of Progression v1 ends
here** — P9 was the spec's last Lane-1 ticket.

## Commits (one concern each)

- **A `891511f` feat(crossing)** — sim truth only: tile_map
  `requires_level` validation (mirrors the defeats block, named
  refusal), Crossing gains the fourth ctor callable
  `level: -> { @progression.level }` + the `open?` sibling row (AFTER
  the defeats row — independent ANDs) + `unmet_level(t)` reason-reader
  (returned-cue contract; reports its own fact even on a sealed way),
  world ctor wire (+1 line). Refusal SILENT at A (defeats parity).
  Test lanes 1–3: tile_map unit (parse/refuse batch/coexist/s34
  seal-target belt), new `crossing_test.rb` (callable-fed truth table,
  AND composition, unmet_level contract incl. live-callable re-read),
  new `level_gate_test.rb` (real World over an injected SELF-LINKED
  fixture: refused-unmoved, at-level cross + `zone_entered` re-emit +
  relocation, live award_kill path). Suite 1097 → 1115.
- **B `c037709` feat(presentation)** — the refusal speaks:
  `cross_through` refused-branch cue write (`:level_required`, way
  tile, `n:`) + `station_cue!` optional `n: nil` kwarg (all SEVEN
  existing callers untouched — verified by grep + identity pair);
  renderer at EXACTLY the three D3 sites (way_locked? sibling branch ·
  `:level_required` draw beside `:provision_refused` with the draw-site
  `<N>` sub · CUE_TEXT_FALLBACK row); map_artifact `seal_stamps` gains
  `|| t[:requires_level]`; `data/zones/gate_fixture.json` (TEST 1,
  34×20, self-linked, one husk at [27,4], gate [12,10]
  `requires_level: 2`); locale rows ×3 VERBATIM from brief D4;
  `harness/scripts/level_gate.json` (24th wall script) +
  `level_gate_reads` (62nd check); map_checks Eleven→Twelve; test
  lanes 4–6 + roster-tracking updates. Suite 1115 → 1122.

## Ship evidence (all PASS)

- **Identity pairs (the zero-interference proof), BOTH commits:**
  world_loop (10) + low_quay_run (14) double-replayed via
  `SKIP_CRITIC=1 rake gate` (determinism PASS ×4) and every frame
  md5-compared against a `9d39280` pre-change baseline captured before
  any edit — **24/24 byte-identical at A and again at B.** The
  fixture's boot-load, the locale keys, the kwarg, and the renderer
  branches moved zero ratified pixels, as the brief's wall-debt audit
  argued.
- **level_gate full critic-ON gate: PASS** (5 captures byte-identical
  across runs + 62-check vision verdict green; the Rules 2/6 language
  critique rode the verdict — `level_gate_reads` judged "LEVEL 2
  REQUIRED shows over a dark gold-seam slab at HUD level 1, then reads
  open gold at level 2"). **Manifest PASS** (floors ×2 in the teed
  double-run log: actor_died 2, attack_hit 10, zone_entered 6).
- **Map gate: probes 11/11 PASS + critique 7/7 PASS** — twelve panels
  named, TEST 1's SEALED stamp explicitly read (critic artifact staged
  as `frame_0000.png` copy for the critic's glob — invocation note for
  the next map-gate runner).
- **Suite via hooks** at both commits (silent-on-pass). world.rb
  landing number: **1786** (cap 1800; see honesty row below). Live
  save md5 `98fe75ed…` verified open/mid/close. `git diff data/` = the
  four declared files EXACTLY.

## Sampling-artifact law exercised (three critic FAILs, each verified against code + exact PNGs)

1. **`zone_identity_reads` FAIL (gate run 1) — REFUTED.** Claim: "TEST
   1 shares palette with the starting zone." The reel never leaves
   gate_fixture (self-link) — the check's own text says single-zone
   reels pass not-exercised; the critic misread two same-name banners
   as two zones. Re-gate: PASS ("stays inside one test arena palette;
   not exercised").
2. **`level_gate_reads` FAIL (gate run 1) — CONFIRMED, fixed by
   evidence, nothing weakened.** Claim: "no thin gold seam." Geometry
   verified: the seam is 2px at `ts/2−1` (renderer :311); the refusal
   X-bar's vertical is 4px at `ts/2−2`, z9 (:592) — the cue lawfully
   COVERS the seam whenever it lives, and the body covers everything
   while standing. Fix: the reel gained a pre-touch capture (frame 330
   — virgin slab + seam, no cue) and the check text now names the
   legitimate-cover rule (the lobber_reach "body covers its bracket"
   precedent) while DEMANDING at least one cue-less frame show the
   full slab+seam grammar — strictly stronger. Re-gate: PASS.
3. **`map_zone_grids_read` FAIL (map critique run 1) — REFUTED
   (variance).** Claim: ZONE 3/5 break the warm-family expectation.
   T5 touched neither palette (`git diff 9d39280 -- …district_two…
   low_quay…` EMPTY); the wb-t4/t5 map gates passed this check over
   these exact panels. Immediate re-run on the IDENTICAL PNG: PASS
   7/7. Note for future calibration (not moved this ticket): the
   check's "original surface zones stay warm clay/bone" phrase
   under-describes the authored cool identities of ZONE 3/5 — a
   variance-prone claim that predates T5.

## Deviations from the brief, argued

- **world.rb landed 1786, not ≤1783** (D7 honesty; stop bound 1790
  never approached). The estimate priced code, not the house-style law
  comments on the refused branch + kwarg; comments were tightened once
  and kept — shaving them to hit a projection would trade legibility
  for arithmetic. **J-7's brief-cutter now has ~14 lines of headroom —
  the extraction question is MANDATORY at its brief** (D7 flag
  re-armed, Crossing/Volleys precedent).
- **Manifest carries no `level_up` floor.** Brief said "level_up 1";
  live code disagrees: `harness/event_log.rb`'s curated list never
  carried `:level_up` (T2 shipped the bus event; the wall log,
  level_up_beat.json included, never logged it — adding it would move
  the etapa-0 canary streams, an explicit stop condition). The brief's
  governing clause "manifest floors = true counts from the authored
  log" resolves the contradiction: floors = {actor_died 1, attack_hit
  5, zone_entered 3} per single run. The level-up is proven by pixels
  (HUD 1→2, growth, gold way) + `actor_died`. Flagged as a NOTE for a
  future EventLog curation decision — never patched unilaterally.
- **`map_checks.json` "Eleven"→"Twelve (+TEST 1)"** — not in the
  brief's four-file data list (it's harness/, and the brief's own D2
  demands the 12th panel pass this gate); the count row has ALWAYS
  tracked the roster (`7ab5612` moved Six→Eleven).
- **Roster-tracking test updates** (not enumerated by the brief, forced
  by the shipped zone): tile_map_test zone count 11→12 + a TEST-1
  self-link/requires_level shape assertion; map_artifact_test label
  list + TEST 1; WELL_ZONE gained a third (level-gated) transition to
  host lane 5. All additive.
- **Reel beats:** the level-up stamp banner expired (150f) before the
  open-approach capture (882) — the approach frame carries HUD LEVEL 2
  + the gold way instead; `level_up_beat.json` (23rd script) remains
  the stamp's own reel. Beat shape otherwise as pinned: cue-dwell 383,
  refused-slab 409 (step-off dwell — slab + X-bar + text + HUD 1 in
  ONE frame), pre-touch 330, crossed 984.

## Authoring notes banked

- **WB checklist (edge-row gates):** the refusal text draws at y−32
  above the way tile — a gate on an edge row puts the line offscreen;
  TEST 1 placed its gate at row 10. ALSO: the cue's X-bar covers the
  slab seam while the cue lives (finding 2 above) — real-world gate
  placements should expect the seam to read only pre-approach.
- **Pilot shelf (T4's d8-flip/hate-peel: UNUSED,** as predicted).
  Fresh traps hit instead: (a) `goto` onto the gate tile after a fight
  livelocked 3000f (ally-occupied downhill, the recorded MEMORY trap)
  — killed r1, drove the respawned husk into a striker death; r2 used
  manual holds for the final approach; (b) `hold left 62` = 4 steps,
  not 3 (step commits at window start) — walked THROUGH the gate
  without resting (moving bodies never trigger); one step back
  crossed. Both banked for the next reel author.
- **Map-gate invocation:** the critic globs `frame_*.png`; copy the
  `world_*.png` artifact to `frame_0000.png` in a scratch dir.

## T4 amendment #2 RE-BANKED (Lane 1 ends — carrier renamed)

**Duplicate-threshold uniqueness (`"5"`+`"05"` in spell_growth rows):**
parse_growth_rows accepts both silently (last-sorted wins). Home:
**whichever ticket next touches the Progression ctor or
data/balance/progression.json** — likely the ritual-stage numbers
freeze or a pacing retune (Lane 2). This line is the bank; the next
brief-cutter for those files owes a verdict on it.

## Owner-visible (for the peers, never nag)

- The god-view map now shows a 12th panel, **TEST 1** — a dev island
  proving the new level-gate machinery; self-linked, unreachable in
  play. Rename/relocation is one owner word; the machinery doesn't
  care. First REAL level-gate placement (which way, which level)
  remains a WB-lane/owner decision — the machinery ships dark until
  then.
- The wall is now **24 scripts** (~5 min each per full sweep — priced
  when the 22nd and 23rd paid the same toll).

## Rule 6 review

Scrubbed read-only headless session over diff + brief + spec ("touch
NOTHING, including seat mail"); mail dir audited before (0) and after
(0) it exited. **VERDICT: PASS-WITH-NITS — 0 blockers, 2 nits** (full
text: the session log; substance below):

1. **NIT — no standing world-level cue-silence guard for
   sealed/defeats-only ways** (the commit-A silence pin was replaced at
   B by design; today the guard is unmet_level's unit contract + the
   identity pair). BANKED for the next cross_through/cue toucher: one
   integration assert that a refused sealed-or-defeats way leaves
   `station_cue` nil. Reviewer scoped it "next toucher, not this ship."
2. **NIT — husk placement wording drift:** D2 said "a few tiles off
   the gate line"; shipped [27,4] sits across the room from gate
   [12,10] — chosen so the husk's aggro (12 tiles, Chebyshev) can NEVER
   reach the pack during the cue-dwell beat (a brawl mid-dwell would
   dirty the artifact frame). Letter of the pin holds; recorded.

Deviations (a)–(d) above were each independently verified LAWFUL by
the reviewer (map_checks precedent re-checked against `7ab5612`; the
EventLog curation fence re-read at source; roster updates additive;
the D7 landing number attributed to law comments in the diff).
