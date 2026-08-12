# v10.1 — Q6 Economy Retune + Eighth Fun-Verify + Scope Debate — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
> **First act next session:** copy this plan to `docs/superpowers/plans/2026-08-12-q6-retune-eighth-verify.md` (plan mode forbade repo writes when it was authored).

**Goal:** Restore the "bank now or push deeper" dilemma (Q6, collapsed into always-bank at the seventh fun-verify) via a one-number depth-premium retune with the dilemma as the oracle, validate with the eighth fun-verify, then hold the scope debate (Challenger = standing candidate) on a healthy economy.

**Architecture:** Data-only balance change (district.json band-2 drop multiplier) + a subscriber-side telemetry oracle (bank sizes + kills-by-band) + a Q7 cue read-time bump (economy.json). Zero husk-behavior change → zero replay drift → the full Rule-2 wall re-proves with no re-aims expected. A2 threat layer untouched (pre-registered routing).

**Tech Stack:** Ruby 3.4.10 + Gosu 1.4.6, minitest, JSON balance data, harness replay gates (`rake gate` = double-replay md5 + 39-check Bedrock vision verdict).

## Context (why)

Seventh fun-verify (2026-08-12, post-merge `402ba1c`; record `drafts/_d1b-fun-verify-20260812.md`): Q1 meaning MOVED (first positive in seven asks — D1b wins), Q5 hunts-run-longer MOVED, **but Q6 REGRESSED: the dilemma collapsed into always-bank** (tribute makes banked always-wanted-liquid; banking rides every heal trip free — bank/altar/vat share one nest room). Q7 "better, not fixed"; Q8 "prices felt right" → the collapse is cadence, not unit price. Pre-registered routing (spec §Fun-verify, applied verbatim): economy retune with the dilemma as oracle, A2 threat untouched; Q7 threshold-lane iteration continues; after validation, next increment = scope debate.

Diagnosis (measured): the existing depth gradient (`district.json` `drop_gradient` [[0,1.0],[14,1.5],[28,2.0]]) pays only ~+1.3/kill at max depth vs a 12–16 tribute bill — the push-deeper side has no felt premium, so returning early costs nothing. Fix: make band 2 pay unmistakably (reward pairs with the A2 threat already thickest there), without touching shallow income (protects Q5/Q8 and replay affordability).

## Global Constraints (owner-locked; violating any is a plan defect)

- Economy vision = inscription-within-ritual; nothing is a shop (council synthesis, owner-locked 2026-08-11).
- Session-only persistence; no in-field healing; tribute stays ONE all-or-nothing transaction; banked stays station-only (no economy HUD).
- **A2 threat layer NOT touched**: threat.json values (margin 4, lowhp 0.25, caps, leash) all stand.
- **Unit prices stand per Q8**: inscribe_cost 8 / regrow_cost 12 / heal_cost_per_body 2 unchanged.
- Data-only sim change; zero balance constants in Ruby; telemetry/instrumentation code is allowed (d1b_fired precedent).
- Vision checks ADD-ONLY (39 now), never weaken. No new player-visible names (bible increment pending).
- Touchstone note (reference wall): "deeper pays more" is a DECLARED corpus gap (`drafts/_gamesmith-consequence-synthesis.md`); license = Tibia hunt-spot risk/reward + Gudii f38 (real profit from deep rare drops) + density-as-consequence + the A2 precedent (defended from game-two's own diagnosed problem). The gradient itself shipped in A2 — this only steepens an already-cited system.
- `export PATH="/c/Ruby34-x64/bin:$PATH"` per shell. Pre-commit/pre-push hooks run `bundle exec rake`. **NO git push ever.** Red suite = fix, never `--no-verify`.
- Rule 7: wall = 9 sequential `rake gate` runs (~15–20 min each, Bedrock); retry gates for INFRA (truncation/self-contradiction — the hardened critic voids those itself, 6 attempts), NEVER re-pilot for infra; re-pilot only for missing beats.

## Design decisions (adversarially reviewed by a Plan agent; all confirmed)

| # | Decision | Rejected alternatives |
|---|---|---|
| D1 | ONE sim number: district.json band-2 multiplier **2.0 → 3.5**. Band-2 rolls [1,1,2]→[4,4,7] (EV 5.0 = 3.75× band-0; Ruby Float#round = half-away-from-zero, verified). Multipliers only ≥ current → every staged replay spend stays affordable BY CONSTRUCTION (no refusal/re-pilot risk). Income inflation ~+24% at a 40/40/20 kill split — Q1 guard rides the verify. | Shallow nerf [[0,0.5],…] (refusal/re-pilot risk + Q5/Q8 regression); drop_table widen (inflates all bands); price hikes (Q8). |
| D2 | Q7 pass = read-TIME only: economy.json **retarget_cue_frames 45 → 75**. Switches already rare (11 in 5 fights; lowhp fired 0×); thresholds tuned last round; zero behavior change → zero wall drift. No test pins 45 (verified). | Threshold changes (drift across all 9 scripts, thresholds are A2-adjacent). |
| D3 | Telemetry oracle: new line `TELEMETRY q6_cadence banks{n= mean= max=} kills_by_band{b0= b1= b2=}`. Subscriber-side only — `:banked` already carries `amount` (= trip yield, since banking drains all carried); kills from `:actor_died` where faction==:human (tile valid at emit, creature.rb:185; payload carries faction — telemetry already reads it). Both events already registered. d1b_fired unchanged (cross-session comparability). | New event/payload emission in world.rb (unnecessary). |
| D4 | Blind verify: handoff carries NO changelog — the depth premium must be FELT, not announced. Play-first law; telemetry harvested from the session log. | Plan agent's "WHAT CHANGED" preamble (primes the subject). |
| D5 | Sequence: branch `q6-retune` → telemetry (TDD) → gradient → cue → wall (fail-fast order) → perf ALONE → full rake → merge --no-ff → verify → debate. | Working on main directly (D1b used a branch; merge gate discipline). |

## File map

- Modify: `src/game/telemetry.rb` (Q6 subscribers + q6_summary + summary line)
- Modify: `test/game/telemetry_test.rb` (3 new tests + update exact-string summary test)
- Modify: `data/zones/district.json:48` (one multiplier)
- Modify: `test/game/world_test.rb:1205` (pins gradient array), `:871` (pins deep amounts [2,4]→[4,7])
- Modify: `test/game/threat_respawn_test.rb:115-118` (+comments 76-81) (pins near×2.0==far)
- Modify: `test/game/economy_data_test.rb` (add gradient shape-law test)
- Modify: `data/balance/economy.json` (retarget_cue_frames)
- Modify (post-verify): `docs/CHECKPOINT.md`, `PARKING_LOT.md`, `CLAUDE.md` scope v11, new `drafts/_q6-retune-fun-verify-<date>.md`, `drafts/_scope-debate-v11.md`

---

### Task 0: Revival + branch

- [ ] Rule 8: Read project CLAUDE.md, docs/CHECKPOINT.md top entry, `drafts/_d1b-fun-verify-20260812.md`.
- [ ] Copy this plan to `docs/superpowers/plans/2026-08-12-q6-retune-eighth-verify.md`; commit it with the first task's commit.
- [ ] `git checkout -b q6-retune` from main (`git log --oneline -1` should show `1da0249` checkpoint or later; tree clean).

### Task 1: Q6 telemetry oracle (TDD)

**Files:** Modify `test/game/telemetry_test.rb`, `src/game/telemetry.rb`.
**Interfaces:** Produces `Telemetry#q6_summary → String` ("TELEMETRY q6_cadence banks{n=N mean=M max=X} kills_by_band{b0=A b1=B b2=C}"); `#summary` gains it as a 4th line. Consumes existing `:banked {actor, amount, banked}` and `:actor_died {actor, faction}` events (both already in the registered event set and already subscribed).

- [ ] **Step 1: Write 3 failing tests** (match the file's existing pattern — bus.register(*ALL_TELEMETRY_EVENTS), duck-typed world with `define_singleton_method(:gate_distance)` + `Struct.new(:drop_gradient)` map, emit → `bus.process` → assert on summary):

```ruby
def test_q6_line_tracks_bank_sizes_and_kills_by_band
  bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
  mock_map = Struct.new(:drop_gradient).new([[0, 1.0], [14, 1.5], [28, 2.0]])
  world_obj = Object.new
  world_obj.define_singleton_method(:gate_distance) { |tile| tile[0] + tile[1] }
  world_obj.define_singleton_method(:map) { mock_map }
  t = Game::Telemetry.new(bus, world: world_obj)

  victim_b0 = Struct.new(:faction, :tile).new(:human, [5, 3])    # dist 8  -> band 0
  victim_b2 = Struct.new(:faction, :tile).new(:human, [20, 10])  # dist 30 -> band 2
  pack_body = Struct.new(:faction, :tile).new(:pack, [20, 10])   # ignored

  bus.emit(:actor_died, actor: victim_b0, faction: :human)
  bus.emit(:actor_died, actor: victim_b2, faction: :human)
  bus.emit(:actor_died, actor: victim_b2, faction: :human)
  bus.emit(:actor_died, actor: pack_body, faction: :pack)
  bus.emit(:banked, actor: nil, amount: 10, banked: 10)
  bus.emit(:banked, actor: nil, amount: 22, banked: 32)
  bus.process

  line = t.q6_summary
  assert_match(/TELEMETRY q6_cadence/, line)
  assert_match(/banks\{n=2 mean=16 max=22\}/, line)
  assert_match(/kills_by_band\{b0=1 b1=0 b2=2\}/, line)
end

def test_q6_line_with_no_world_shows_zero_bands
  bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
  t = Game::Telemetry.new(bus)
  bus.emit(:banked, actor: nil, amount: 5, banked: 5)
  bus.process
  assert_match(/banks\{n=1 mean=5 max=5\}/, t.q6_summary)
  assert_match(/kills_by_band\{b0=0 b1=0 b2=0\}/, t.q6_summary)
end

def test_q6_line_appears_in_full_summary
  bus = Core::EventBus.new.register(*ALL_TELEMETRY_EVENTS)
  t = Game::Telemetry.new(bus)
  bus.process
  assert_match(/q6_cadence/, t.summary)
end
```

NB the `:actor_died` emit signature: mirror whatever payload keys the file's EXISTING body_deaths test uses (read it first — read-before-edit; telemetry reads `e[:faction]`).

- [ ] **Step 2: Run to verify they fail** — `bundle exec ruby -Itest test/game/telemetry_test.rb` → expect NoMethodError `q6_summary` / assertion misses.
- [ ] **Step 3: Implement** in `src/game/telemetry.rb` initialize (beside the existing subscribers):

```ruby
@bank_amounts = []
@kills_by_band = [0, 0, 0]
bus.subscribe(:banked) { |e| @bank_amounts << e[:amount] }
bus.subscribe(:actor_died) do |e|
  next unless e[:faction] == :human && @world
  bands = @world.map.drop_gradient
  next unless bands
  d = @world.gate_distance(e[:actor].tile)
  idx = bands.rindex { |(min, _)| d >= min }
  @kills_by_band[idx] += 1 if idx
end
```

and:

```ruby
def q6_summary
  n = @bank_amounts.length
  mean = n.positive? ? (@bank_amounts.sum / n.to_f).round : 0
  "TELEMETRY q6_cadence banks{n=#{n} mean=#{mean} max=#{@bank_amounts.max || 0}} " \
    "kills_by_band{b0=#{@kills_by_band[0]} b1=#{@kills_by_band[1]} b2=#{@kills_by_band[2]}}"
end
```

`summary` gains `\n#{q6_summary}` as its final line.

- [ ] **Step 4: Fix the exact-string summary test** — `test_counts_and_formats_the_session_line` (asserts the full summary verbatim) gains the 4th line; derive the expected q6 values from the events that test already emits (read it, don't guess).
- [ ] **Step 5: Full suite green** — `bundle exec rake` (281+3 runs expected).
- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat(telemetry): q6_cadence oracle — bank sizes + kills by depth band"`.

### Task 2: Depth-premium retune (data + pinned tests, ONE commit)

**Files:** Modify `data/zones/district.json`, `test/game/world_test.rb`, `test/game/threat_respawn_test.rb`, `test/game/economy_data_test.rb`.

- [ ] **Step 1: Flip the number** — district.json line 48: `"drop_gradient": [[0, 1.0], [14, 1.5], [28, 3.5]]`.
- [ ] **Step 2: Run suite to see exactly the 3 expected failures** — world_test.rb:1205 (literal array), world_test.rb:871 (deep amounts), threat_respawn_test.rb:116 (near×2.0==far). Any OTHER failure = unexpected coupling → stop and investigate before proceeding.
- [ ] **Step 3: Update the pins** — :1205 expects the new array; :871 `assert_includes [4, 7], drop[:amount]` (band-2 rolls from [1,1,2]×3.5 rounded); threat_respawn `assert_equal (near_amount * 3.5).round, far_amount` + fix the ×2.0 comments (lines ~76-81).
- [ ] **Step 4: Add the shape law** to economy_data_test.rb (pins the LAW, not the hypothesis value):

```ruby
def test_depth_gradient_steepens
  bands = DATA["zones/district"][:drop_gradient]
  refute_nil bands, "district must have a drop gradient"
  mults = bands.map(&:last)
  assert mults.each_cons(2).all? { |a, b| b > a }, "gradient strictly increasing: #{mults}"
  assert mults.last >= 3.0, "band-2 premium >= 3.0x sustains the Q6 dilemma (v10.1 retune)"
end
```

(Match the file's actual DATA-access idiom — read it first.)
- [ ] **Step 5: Suite green, commit** — `data(economy): band-2 drop multiplier 2.0 -> 3.5 — depth premium is the Q6 lever`.

### Task 3: Q7 cue read-time (data)

- [ ] **Step 1:** economy.json: `"retarget_cue_frames": 75` (was 45; ~1.25 s). No test pins 45 (verified — economy_data_test asserts positive? only).
- [ ] **Step 2:** Suite green, commit — `data(cue): retarget cue 45 -> 75 frames — Q7 read-time second pass`.

### Task 4: Rule-2 wall (official, fail-fast order)

Expected: zero re-aims — no husk-behavior change; only HUD digits and cue duration differ; the 7 number-sensitive checks gate on format/prominence, not digits; `gradient_depth_reads` checks enemy density, not drop amounts (verified). Determinism is within-run double-replay — data changes cannot break it.

- [ ] Run sequentially, economy-heavy first (surprises surface in the first ~40 min): vat_economy → ledger_loop → loot_loop → district_hunt → world_loop → corpse_run → threat_pull → specials_chain → taunt_anchor, each via `bundle exec rake gate SCRIPT=harness/scripts/<s>.json` (background task + log per script is fine; harvest EXIT codes).
- [ ] INFRA failure (verdict truncation / self-contradiction — the hardened critic retries 6× and voids contradictions itself): retry the gate. Real check-FAIL: read `drafts/_gate-verdicts.log`, fix forward; captures re-aimable post-hoc from EVENT-log frames (technique in `drafts/_d1b-wall-log.md`); re-pilot ONLY for a genuinely missing beat.
- [ ] Log the wall map (script → round → EXIT) into `drafts/_q6-wall-log.md` as it lands.

### Task 5: Perf + suite

- [ ] `bundle exec rake perf` ALONE (no parallel load) — budget p95 < 16.6 ms (D1b baseline 0.225 ms; data-only cannot regress it — treat a surprise as a real signal).
- [ ] `bundle exec rake` full suite green.

### Task 6: Merge + checkpoint

- [ ] `git checkout main && git merge --no-ff q6-retune -m "merge: v10.1 Q6 depth-premium retune + cue read-time + q6_cadence oracle"` — **NO push.**
- [ ] CHECKPOINT.md new top entry with MEASURED numbers (`git rev-list --count HEAD`, suite line, wall map with round provenance, perf p95).

### Task 7: Eighth fun-verify (blind — no changelog in the handoff)

- [ ] Owner plays `bin/play` FIRST (play-first law). Harvest all TELEMETRY lines from the session log (incl. the new q6_cadence) before any question.
- [ ] Preamble: if you never wiped, the judgment never fired — Q6' (judgment) reads unexercised, not negative.
- [ ] Questions (via AskUserQuestion, two batches, in this order):
  1. **Q6 rerun (HEADLINE):** bank now or push deeper — did it bite this session? Name one moment you chose to keep pushing with a pile instead of walking back (or chose to walk back and felt the cost).
  2. **Depth premium:** did anywhere in the district feel worth pushing TO — did kills somewhere feel richer than kills elsewhere?
  3. **Q7 rerun:** when a human turned on you, could you read WHY (the colored flash) this time?
  4. **Q1 GUARD:** if your banked number were silently halved, would you still care — or did money get easy enough that spends stopped being decisions?
  5. **Q5 GUARD:** did hunts still run long, or did anything push you back to the nest too often again?
  6. **Conditional (only if wiped):** did the judgment land — marked-survives / unmarked-dissolves — and did it sting?
  7. **Entrainment probe (canonical wording):** on the thinnest stretch — fewest bodies, deepest push — did your body react (lean, breath, grip), or stay flat?
- [ ] **Pre-registered routing (locked here — apply verbatim, do not re-derive):**

| Outcome | Route |
|---|---|
| Q6 restored + Q1/Q5 guards hold | Economy healthy → proceed to the scope debate (same session). |
| Q6 restored + Q1 regressed (inflation) | Band-2 value down (3.5 → ~3.0), premium SHAPE kept; data-only iteration; guards re-verified. |
| Q6 still collapsed + telemetry deep-kill share UP | Premium exists but isn't felt → legibility candidate (drop/pickup presentation) goes to the debate as evidence. |
| Q6 still collapsed + deep-kill share UNCHANGED | Structural (banking rides heal trips free) → mechanism candidates go TO THE DEBATE, never unilaterally to code. |
| Q7 still arbitrary | Cue redesign opens as its own presentation item (the "cue itself misreads" branch). |
| Entrainment flat again | Third consecutive flat — strengthens the Challenger case at the debate (its recorded trigger). |

- [ ] Record verdict in `drafts/_q6-retune-fun-verify-<date>.md` + CHECKPOINT delta + commit.

### Task 8: Scope debate (owner forks via AskUserQuestion)

- [ ] Write `drafts/_scope-debate-v11.md` brief BEFORE asking. Contents:
  - **Challenger dossier:** shape = named human who force-taunts the possessed ("humans never fought back — until one did"); trigger MET+RECORDED (sixth verify) and entrainment flat again at seventh (+eighth result); **fairness ladder mandatory** (visible tell + counters); scatter = council-preferred alternative shape (herd management, environmental, fails gracefully); DECLINED once at v10; NO fiction name — bible naming (docs/lore/world-bible.md, Vessic) rides the increment if promoted.
  - **The judgment-rarity tension:** D1b works so well wipes are rare → the marked-survives drama almost never fires; the Challenger is one candidate vehicle for rare-but-heavy wipes; surfacing this is the debate's job, not a pre-decision.
  - **Rival candidates with blockers:** A3 nest advance/district progression; D3 scavengers + term-extension marks; A1 gambits; A1+ Shooters (needs per-attacker cadence); D2 fine+insurance (BLOCKED on skill-through-use); Nest rename + fiction pass (bible EXISTS; two owner complaints on record; invalidates every gate capture → its own increment); diagonal corner-cut fix (changes movement feel — owner verdict required); economy iteration 2 (if the verify routed there).
  - Eighth-verify results folded in as evidence.
- [ ] Fork via AskUserQuestion (curated owner-level options + Other; promotion is the OWNER's explicit call, per the standing Challenger clause).
- [ ] Close-out: CLAUDE.md scope contract v11 rewrite; PARKING_LOT.md updates (promoted item leaves the lot; **fix the stale tank-first entry — it SHIPPED with A2**, combat.json initial_possessed=blocker); CHECKPOINT delta; commit. The promoted increment's brainstorm/spec is the NEXT session's work, not this one's.

## Verification (end-to-end)

1. Suite: `bundle exec rake` green at every commit (hooks enforce).
2. Wall: 9/9 official `rake gate` exit-0 on the post-retune build (determinism + 39-check vision), wall map recorded with round provenance.
3. Perf: p95 < 16.6 ms measured alone.
4. Behavioral oracle: q6_cadence line present in a real session log (owner's verify session IS the integration test — no mocks).
5. The felt oracle: eighth fun-verify Q6 answer, routed by the pre-registered table above.

## Budget (Rule 7)

Wall ≈ 9 × 15–20 min Bedrock-bound (~3 h wall-clock, fail-fast ordered); retries per the INFRA rules. Coding ≈ 30–40 min. No multi-agent fan-out planned for execution; if a review fan-out is ever wanted pre-merge, it re-declares its own envelope (D1b calibration: ~110K/finder, ~55K/refuter; Codex cross-vendor leg mandatory on merge gates per memory).
