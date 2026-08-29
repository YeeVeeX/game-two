# v20 T2 — Progression band step 1: cap 12 + k re-price + standing pacing script (2026-08-29)

Ticket: `docs/superpowers/specs/2026-08-28-v20-descent-cycle.md` §T2 ·
law: foundation L5 (`drafts/_v20-foundation-20260828.md`) · blueprint:
`drafts/_v20-pacing-analysis-20260826.md` · CLAIMED `4df350b`
(Gabriel's seat, 2026-08-29). Spark correction honored: the live save
sits AT THE PIN — progression `{level: 10, xp: 3679}` (verified below;
the spec row's `xp=644` was a stale snapshot) → hard floor **k ≥ 40**
(3679 must stay < ΔE(11) = 92k). Mechanism precision (review advisory
4): at k < 40 the decoder would not REFUSE — SaveState's curve-churn
law CLAMPS xp to ΔE(11)−1 with a warning (`save_state.rb`), silently
destroying the owners' banked pin progress; the floor protects pin
INTEGRITY, not decodability.

## What shipped

- `data/balance/progression.json`: `level_cap` **10 → 12**, `k` **40
  (unchanged — table-backed, rationale below)**. kill_xp rows, growth
  pcts, spell_growth: UNTOUCHED (L5 first-ship law).
- `tools/pacing_table.rb` (NEW, standing): reads the live file through
  `Core::DataStore` and prices ΔE via the real `Game::Progression`
  (formula identity — the tool cannot drift from the sim). Emits
  per-level ΔE / cumulative / minutes-at-band / kills-per-kind, the
  at-cap pin, and a candidate-k dwell sweep (`K_SWEEP=`, composes with
  `CAP=` / `K=` / `RATES=`). Header carries the standing law: RUN ON
  EVERY CURVE/CAP TOUCH, output pasted into the touching ticket's
  record.
- Tests: `test_shipped_data_pins_capped_xp_just_under_the_next_ceiling`
  (progression_test.rb — shipped-file award-to-cap pin smoke,
  formula-relative, never a literal) · `test/tools/pacing_table_test.rb`
  (standing-script rot smoke: live-curve pin line + sweep pricing match
  the real formula).

## The table (live file after landing: k=40 cap=12)

```
  L  dE(L)  cumE(L)  min@8000  min@20000  husk-kills  rusher-kills  rusher_hater-kills  challenger-kills
--------------------------------------------------------------------------------------------------------
  2     80       80       0.6        0.2          10             6                   4                 1
  3    160      240       1.2        0.5          20            11                   7                 2
  4    320      560       2.4        1.0          40            22                  13                 3
  5    560     1120       4.2        1.7          70            38                  23                 5
  6    880     2000       6.6        2.6         110            59                  36                 8
  7   1280     3280       9.6        3.8         160            86                  52                11
  8   1760     5040      13.2        5.3         220           118                  71                15
  9   2320     7360      17.4        7.0         290           155                  93                20
 10   2960    10320      22.2        8.9         370           198                 119                25
 11   3680    14000      27.6       11.0         460           246                 148                31
 12   4480    18480      33.6       13.4         560           299                 180                38
13+   5360    23840      40.2       16.1         670           358                 215                45
14+   6320    30160      47.4       19.0         790           422                 253                53

cum to cap: E(12) = 18480
at-cap xp pin: dE(13) - 1 = 5359 (projector invariant — award pins overflow xp just under the next ceiling)
```

Cross-check against the blueprint doc §3: every ΔE and cumulative row
byte-matches (80…4480, E(10)=10320, E(11)=14000, E(12)=18480, extension
rows 5360/6320). The tool IS the doc's arithmetic, mechanized.

## Candidate-k sweep (CAP=12, RATES=8000,10916,20000)

10916 = the measured coop-endgame rate (blueprint §2, exposure #41,
8→cap with wipes) — the closest analog to how the descent band will
actually be played; 8000/20000 = the band edges (fresh-coop tour /
solo pocket-farm honest upper bound).

```
 k  dE(10->11)  min@8000  min@10916  min@20000  dE(11->12)  min@8000  min@10916  min@20000   pin
------------------------------------------------------------------------------------------------
40        3680      27.6       20.2       11.0        4480      33.6       24.6       13.4  5359
44        4048      30.4       22.2       12.1        4928      37.0       27.1       14.8  5895
48        4416      33.1       24.3       13.2        5376      40.3       29.5       16.1  6431
52        4784      35.9       26.3       14.4        5824      43.7       32.0       17.5  6967
56        5152      38.6       28.3       15.5        6272      47.0       34.5       18.8  7503
```

## k decision: 40 UNCHANGED (dev-of-record call per L5)

1. At the representative measured rate (10916), k=40 puts BOTH new
   steps centrally in the L5 target: L10→11 = 20.2 min, L11→12 =
   24.6 min (target ~15-30 each). The band edges poke out
   symmetrically (11-13 min at the pocket-farm upper bound, 33.6 at
   the fresh-coop floor) — no k closes that: the band is wider than
   the target, so edge excursions only MOVE with k, and every raise
   pushes L11→12 past 30 min at the measured coop rate the shared
   save actually plays (k=52 already breaks 30 at 10916).
2. k=40 satisfies the live-save hard floor exactly (3679 < 3680,
   headroom 1 — decode-proven below) and keeps the verified intro-arc
   pacing (L2→10 = 31 min–1.3 h measured) untouched for fresh saves;
   a raise re-prices an arc three human sessions already consumed and
   the owner ratified numbers beside (L5 evidence row carried k=40's
   extension arithmetic at the grill).
3. k unchanged ⇒ zero sim drift ⇒ the cap step ships as the PURE felt
   change of this ticket, with no re-gate tax (phase-5 audit below).

Felt note for the owners: the live save sits at the OLD pin = ΔE(11)−1,
so the FIRST kill after this update levels the pack 10→11 instantly —
a designed consequence of the projector-invariant pin, not a bug. Then
L11→12 costs 4480 (~20-34 min at measured rates) and the bar pins at
5359.

## Pin math re-verified (cap 12)

ΔE(13) = k·(13²−3·13+4) = 134k → pin = 134k−1 = **5359** at k=40.
Verified three ways: the tool's footer (above) · the shipped-file
award-to-cap smoke (suite) · hand arithmetic here. Projector-invariant
law holds: xp < ΔE(level+1) on every award exit.

## Copy-decode proof (L9 — live file never touched)

Live save md5 BEFORE: `1d71e34f9abf60a7d7ffe180fe0d55e0` → copy to
`tmp/t2_save_probe/world.json` (md5 identical). Probe
(`tmp/t2_probe.rb`, deleted after banking) drove the SAME path main.rb
uses — `App::SaveStore#load` (strict decoder) → `Game::World.new`
(SaveState.apply! inside) — under the landed cap-12 file:

```
decoded facts progression: {"level" => 10, "xp" => 3679}
facts digest: 1c2c35ed0fd6730583ca969e13102a27
stderr during World construction: (empty)
PROBE PASS: copy decodes Loaded under cap 12 — level=10 xp=3679 intact, zero clamp warnings, no normalization side-effect
probe rc=0
```

Copy md5 after probe: unchanged. Live save md5 AFTER (end of session):
`1d71e34f9abf60a7d7ffe180fe0d55e0` — byte-identical.

## Phase-5 sim-drift audit: owed re-gate set EMPTY

k unchanged ⇒ every ΔE row below the cap is byte-identical; the only
behavior surface this ticket moves is at level ≥ 10 (the award loop's
`@level < @level_cap` bound + the pin/`MAX` display). Verified
MECHANICALLY, not asserted: across all 36 fresh wall-bank logs
(`tmp/wall/*_v20-t1.log`), grep of every `TELEMETRY progression
level=` line shows max level = **8** (zone8_crossing); the two
mid-reel level-ups (floor1_run, level_up_beat) are 1→2; the canary
trio (world_loop/varekka/burn) sits at L1 throughout. No reel can
observe the cap change ⇒ zero re-gates owed, no rebank, no
`_gate-verdicts.log` entries this ticket. Suite (incl. sim-identity
canary test) green on the shipped values: 1319 runs 0F.

## Fresh-eyes review (Rule 6)

Headless scrubbed pi session over the full brief (spec §T2 + record +
feat diff inline, 19KB; read-only, no-seat-mail law in the prompt).
**Verdict: PASS, zero blocking, four advisories.** Verbatim:

```json
{"verdict":"PASS","blocking":[],"advisories":[{"item":"Sweep test weak discriminator for the live k","why":"test_sweep_mode_prices_candidate_ks asserts delta_e(cap).to_s appears in stdout; for k=40 that value (4480) also appears in the main table printed before the sweep, so the k=40 half of the assertion cannot fail independently — only the k=44 check (4928) actually discriminates the sweep block. Consider asserting on the sweep row shape or a non-live candidate only."},{"item":"tmp/t2_save_probe/world.json still on disk","why":"the record says the probe SCRIPT was deleted, but the live-save copy remains in tmp/; harmless (gitignored) yet a stray byte-identical world.json near the tree is exactly the kind of artifact the fork-chain lesson warns about — delete it at session close."},{"item":"Suite/tool not executed by this reviewer","why":"seat-lease (LIVE holder 01a04c89) blocks ruby/test-runner commands from this session; verification here is static (formula re-derivation, code reads, mechanical wall-log grep reproduced) plus the pre-commit hook having run bundle exec rake at 8a8dfe9. No discrepancy found, but the 1319-runs-0F claim is hook-implied, not reviewer-reproduced."},{"item":"'Hard floor' mechanism framing","why":"at k<40 the save would not refuse — SaveState CLAMPS xp with a warning (losing the pinned xp). The floor is real (pin integrity), but the record's refusal-adjacent framing could mislead a future retune; the clamp comment in save_state.rb is the actual law."}],"summary":"The diff conforms to spec T2 on every axis: cap 10→12 landed as a one-line data change; the k decision is genuinely table-backed (sweep re-derived by hand, and the record's claim that no k fits both band edges is mathematically provable since the band ratio 2.5 exceeds the target ratio 2); the standing script reads all balance values live through DataStore and the real Progression object (zero constants, formula identity verified against src/game/progression.rb); the pin arithmetic (5359 = 134·40−1) checks three independent ways; the copy-decode proof is consistent with the decoder code (level 10 ≤ 12, xp 3679 < 3680, headroom exactly 1) and the live save md5 is unchanged right now. Hard laws hold: kill_xp/growth/spell_growth/rungs/schema/world.rb untouched. The phase-5 replay-inertness audit is sound and was mechanically reproduced by this reviewer (36 wall logs, max level 8; all three cap-reading render surfaces gate on level ≥ cap, and k-unchanged means ΔE is byte-identical below cap). Tests are formula-relative with no pinned literals. Advisories only: a weak discriminator in the sweep test's live-k assertion, a leftover save copy in tmp/, reviewer execution blocked by the held seat (static verification substituted), and a framing nit on the k-floor mechanism."}
```

**Advisory dispositions (all executed this session):** (1) sweep test
now splits the output and asserts inside the sweep section only, plus
pin-per-candidate rows — both candidates discriminate; (2)
`tmp/t2_save_probe/` deleted at session close, after the final live-md5
check below; (3) statement of scope, no action — suite evidence is the
pre-commit hook run banked in `tmp/t2_feat_commit.log` (1321 runs 0F)
plus this seat's attended `bundle exec rake` (1319 runs 0F pre-test-add);
(4) framing corrected in the header of this record (clamp, not refusal).

## Out of scope, confirmed untouched

kill_xp rows · requires_level rungs · growth pcts · save schema ·
`src/game/world.rb` · cap 13/15 (ride lane D's floors, L5) · T3
potions identity (own spark) · standing wall reds (11 C2-QUEUED +
threat_pull + zone_catchup + dash_strike_rip quirk — named debts of
other sessions).
