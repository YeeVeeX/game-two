# B1 safe-zones spec — fresh-eyes review receipt (s61, 2026-08-24)

Artifact: `docs/superpowers/specs/2026-08-24-b1-safe-zones-design.md`.
Reviewer: headless scrubbed pi (read-only brief, touch-nothing incl.
seat mail), rubric = two-way alignment against
`drafts/_v19-foundation-20260822.md` Lane-2 rows + receipt
spot-checks + trap list. Three rounds, same prompt each time:

- **Round 1 FAIL (blocking-1):** B1-T2's scope includes
  `harness/gate_checks.json` + appends to `drafts/_gate-verdicts.log`
  — BOTH in the 11-file staged J7-B set — yet only T1 carried a
  BLOCKED marker. Also caught: district→camp threshold receipt wrong
  ([42,13] sealed, spec said [40,13] — that coordinate was the ARRIVAL
  spawn, not the threshold). Fixed: both tickets now carry explicit
  BLOCKED-until-J7-B-push markers; threshold inventory corrected +
  seal/toll route law added (T2 script rides the free
  camp↔district_two east loop).
- **Round 2 FAIL (blocking-1):** grill finding 4 + D3 misattributed
  hostile acquisition to `tick_human`/controllers.rb:161 — :161 is the
  PACK-ALLY branch; real acquisition is `select_target`
  (controllers.rb:106-135) driven by `World#assign_human_focus`
  (world.rb:697-715). The spec-letter guard would have stopped verbs
  but NOT acquisition, failing T1's own integration test. Verified
  against source, confirmed correct. Fixed: D3 guard moved to
  `assign_human_focus` (skip + focus-nil in safe zones; leash
  walk-home deliberately preserved — no frozen-AI artifact),
  controllers.rb now expected untouched, test plan pins zero
  `:human_retargeted` AND the preserved walk-home branch.
- **Round 3 PASS-WITH-NITS (0 blocking, 29 receipts checked):**
  verdict JSON archived below. Nits closed in-tree: aggro-radius
  off-by-one (:113→:114), D5 inventory marked non-exhaustive (basement/
  dungeon returns into zone_7). Recorded-not-changed: T3's
  "playtest before ship → lane-close gate" reading stays explicitly
  flagged in-spec with the owner-override line; D2 + SAFE chip stay
  labeled derived machinery (recorded scope, not silent creep);
  verdicts-log append is critic-ON-only (T2's gates are critic-ON, so
  the BLOCKED rationale stands).

Round-3 verdict (verbatim):

```json
{"verdict":"PASS-WITH-NITS","blocking":[],"nits":["Receipt off-by-one: spec cites controllers.rb:113 for the aggro radius; the kit[:aggro_tiles] select is at :114 (:113 is the beachhead reject line of the same candidates chain)","D5 inbound-threshold inventory incomplete: basement_1.json:77, basement_2.json:77, and dungeon_1.json:114 all carry return transitions to zone_7 - three thresholds INTO safety omitted from the prose list; harmless because the marking rule is destination-derived and the spec orders the build session to re-read live transition tables, but the T2 script/checklist author must not trust the prose list as exhaustive","Ratified 'own capture + playtest before ship' is softened to 'T1/T2 merge on green gates, LANE closes on playtest' - explicitly flagged in-spec (T3) with a one-line owner-override path and justified by the 2026-08-22 never-gate-on-peer-availability order; acceptable but owners should sight the reading","D2 load-time refusal and the persistent SAFE chip exceed the ratified letter's literal wording - both are explicitly labeled as derived machinery (D2 from grill findings 1/2/6 + s34 seal-gating precedent; chip from the foundation-cited Tibia PZ-icon touchstone), zero balance or shipped-behavior delta, so recorded scope, not silent creep","Spec says 'every rake gate run appends to the verdicts log' - true only for critic-ON runs (vision_critic.py:226 does the append; SKIP_CRITIC=1 skips the critic); T2's owed gates are critic-ON so the BLOCKED rationale stands as written"],"receipts_checked":29,"receipts_wrong":["controllers.rb:113 (aggro radius) - actual aggro_tiles line is controllers.rb:114"]}
```
