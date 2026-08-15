# v12 spec adversarial review — ledger (2026-08-13)

Workflow `wf_c93e43ff-7cb`: 4 lenses (code-fit / design-fun /
harness-verifiability / **canon-compliance** — new this cycle, the annex
must survive the bible's own naming law) × 3 independent finders → dedup
(cap 12) → 3-angle majority refutation per finding
(spec-and-code-evidence / project-laws-and-precedent /
practical-consequence; default-refute-if-uncertain; ≥2 refuted kills).

**Declared envelope: ≤49 agents, ~3.5M tokens. Spent: 49/49 agents, 0
errors, 3.92M tokens, 34 min.** Raw findings: 24 across 12 finders →
12 deduped (+6 dropped at the cap, dispositioned by hand below).

## Verdict: 12 deduped findings, 0 CONFIRMED — all majority-refuted

| # | sev | ×dup | finding | refutation core |
|---|-----|------|---------|-----------------|
| 0 | high | 8 | Camp-side arrival creates beachhead bubble at the seal → safe-farming + desync + design contradiction | `waive_beachhead!` fires permanently on first pack attack (creature.rb:179) — no farm cycle exists; beachhead blocks ACQUISITION only; spec §2 declares the door-grace intended; D2 (2.0–3.0×) strictly out-earns the [40,13] pocket; desync claim already covered by verified-not-trusted triage. **Fold taken anyway (see below): triage clause names beachhead as a second candidate mechanism.** |
| 1 | high | 2 | draw_map can't render sealed-vs-breached (no world access) | Renderer.draw(world) HAS world; sealed-slab drawing lands in a world-aware pass (draw_stations idiom); draw_map's signature is internal, not a contract. |
| 2 | high | 3 | ulwir/goret/ithet-class coinages carried unlicensed consonant insertions | Docs-bound names, nil shipped consequence; bible calls euphony "a rule of the mouth". **Fold taken anyway: derivations tightened to direct canon patterns** (see below) — the finding was refuted on consequence, not on grammar-hygiene, and the hygiene was worth having. |
| 3 | med | 2 | Slow Door (150 for an empty room) lacks an anticlimax verify/routing | Q1/Q2/Q3 + arc telemetry (`seal2_breached`) cover it; seal2 is stretch-by-design and rarely reached blind; routing's residual clause carries any sour read to the debate. |
| 4 | med | 2 | Check #42 bundles two zone judgments | v11 precedent: `deep_drop_band_reads` bundles clauses with per-clause hatches; #42 carries the same either/or hatch. |
| 5 | med | 1 | breach_cost=40 derivation arithmetic ("one tribute"=16, "two good trips"=38) | "Good" ≠ mean (mean 19, max 38 — two above-mean trips reach 40); "over one tribute" names the decision TYPE; finding self-classified as prose-preference. |
| 6 | med | 0 | Banner system can't show the breach line without contract change | Spec deliberately distinguishes "existing banner path" (zone banners) from "the banner slot" (a screen position) — the breach line is specced as NEW presentation. |
| 7 | med | 0 | Camp-door D1 farming dominates D2 | Distance math wrong both sides (D2's bank is 1 tile inside its gate via camp); only 2-3 enemies near the door pocket; D2 minimum multiplier = D1 maximum. |
| 8 | med | 0 | breach_cost_2=150 lacks D2 net-income math / unreachable | Maintenance costs are FIXED absolutes, not income-proportional; D2 at 2.0–3.0× yields ~35 gross/trip → 150 is reachable-greedy, per the fork's own wording. |
| 9 | med | 0 | Slow-Door "not-exercised hatch" cites a check that doesn't exist | The sentence describes the gate OUTCOME (no check fails on an unstaged zone); #42's hatch covers absent zones by wording. |
| 10 | med | 0 | Act-1 pilot economy blows the 20-capture budget | Captures are explicit single-frame commands, decoupled from sim length (vat_economy ran 12,797 frames under 20 captures). |
| 11 | med | 0 | suvrim mis-cites the euphonic rule (-a/-ah scope) | Word is legal via §2.1 `vr` onset; nil consequence. **Fold taken anyway: citation corrected to the savrim precedent.** |

## Dropped at the dedup cap (6) — hand disposition (no-silent-caps law)

1. **district_two omits pack_spawn → TileMap validation crash** — REAL.
   **FOLDED**: spec §3 now pins 3 pack_spawn tiles (validation
   furniture; pack arrives by transition).
2. **validate! doesn't check gradient_anchor passability** — REAL
   hardening. **FOLDED**: spec §0 extends the transitions/stations
   validation law to the anchor.
3. Q5 money-purpose attribution overdetermined (arc + riders both move
   it) — TRUE as analysis, not actionable: Q5's routing reads the
   q6_margins data, which separates the channels. Dismissed.
4. corpse_guard 6→10 calibrated against pre-camp corpse-run geometry —
   corpse runs continue from camp into D2 under the same guard; the
   value is judged at the tenth either way. Dismissed.
5. Seal station fires refuse-cues in existing east-end scripts — no
   existing script interacts at [41,13]; refuse-cue requires standing ON
   the station tile; triage catches any exception. Dismissed.
6. "The Slow Door" narrows a whole-Undervault term to one zone banner —
   metonymy at the threshold ("every grave is a door onto its
   threshold"); the landing IS the slow door's mouth. Dismissed; the
   v13 bible amendment can arbitrate if the parallel bible session
   objects.

## Folds applied to the spec (4)

1. §3: district_two `pack_spawn` pinned (cap-drop #1).
2. §0: `gradient_anchor` passability validation + test (cap-drop #2).
3. Harness triage: beachhead expansion named as a second candidate
   desync mechanism, with the [38,12]-inside-radius example (finding 0's
   salvageable nugget — 8 finders raised it; the triage wording now
   matches what the wall will actually check).
4. Annex derivation hygiene (findings 2 + 11): ulvir→**ulwir** (the
   seamwir agent pattern), gorvet→**goret**, kadvet→**ithet** (bare
   root + -et, the Khelat/Suvet pattern — also clears the
   kadet≈"cadet" slop-adjacency), suvrim citation → the **savrim**
   precedent + §2.1 vr onset. No unlicensed consonant insertions remain
   in any coined name.

## Reading the 0-confirmed result honestly

The spec was written against freshly-read code with the two structural
traps (gradient flip on sorted zone keys; HOME_ZONE's four use sites)
caught pre-spec — the finders re-found the same terrain and the refuters
held. The refutations were evidence-grade (file:line mechanics, existing
telemetry, script frame-counts), not dismissals. The real review value
landed in the cap-dropped hardening items and the canon-hygiene folds —
and in eight independent finders converging on the beachhead question,
which the wall triage now names explicitly.
