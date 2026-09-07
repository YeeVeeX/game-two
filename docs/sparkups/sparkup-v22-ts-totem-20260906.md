# Spark-up -- game-two session s138: TS TOTEM RE-WORK (owner-ordered s133; one gated SIM piece) + the deadlock note to Junior

E1c is DONE and pushed (s137, `f609c31..2450ecb`, 9 commits): the ten red pins are
7 REPINNED (four first-ever AFFIRMATIVE reads: `challenge_reads` on both stagers = the
L16 row CLOSED, `impact_fx_reads`/`damage_numbers_read` on floor1_run, `lobber_reach_reads`
under a tier-aware row), 4 CONVICTED-AND-ROUTED with pixel/data proof, 1 INFRA diagnosed;
Junior's basement_pocket/toll_pocket re-authors were taken VERBATIM and verified on main's
sim; zone8's blue lines were pre-swap water decor, removed through the sidecar -> importer
door. Fresh-eyes review BLOCKed with two real findings, both landed: `lobber_reach_reads`
now states the volley chain by LEVEL TIER from `progression.json`, and `harness/pins.rb`
stamps DIRTY-JUDGED paths so a pin can never silently claim a tree that did not hold what
the gate read. `rake pins` = 7 PINNED / 32 STALE (T2c) / 4 FAILED (each red carries a routed
conviction). Record: `drafts/_v22-e1c-record-20260906.md`; review verbatim
`drafts/_v22-e1c-review-20260906.md`.

## Why TS now, and not T2a (read this before deciding anything)

The spec order says T2a next, but T2a is DEADLOCKED and the deadlock is circular:
- T2a carves `world.rb` (Party/Character/ZoneState); Junior's `junior/premium-build` (now
  ~70 commits over main, ff-able) already extracted `Game::Interact` (world.rb 1800 -> 1726)
  and its S2 loot wiring is interwoven with world.rb -- carving on main FIRST hands his
  merge a rebase over moved code (his own words in `drafts/_junior-note-to-gabriel-20260906.md`
  section 14: "risky (S2's loot wiring is interwoven with world.rb and the renderer surfaces)").
- His branch cannot land: it carries S2+S3, whose landing the owner sequenced AFTER the
  TWENTIETH (his section 13 corrects his earlier "ff is yours" line and names three honest
  ways: (a) WAIT for the TWENTIETH, (b) PEER AMENDMENT of the sequencing, (c) DARK-SHIP --
  data switches `economy.json item_drops_enabled`, `status.json burn.enabled`, bag screen
  inert, "~20 lines + tests + canaries, one session, only on a word").
- The TWENTIETH's delta = T2a..T8. So: his branch waits for the TWENTIETH, the TWENTIETH
  waits for T2a, T2a waits for his branch. Nobody can wait this out.

**Decision for s138 (dev of record, argued, one line reverses it):** the SIM lane runs
**TS -- the totem re-work the owner ordered verbatim in s133** ("re-work, 15 seconds its too
much ... pulse every 3 seconds ... 15hp is good and scale with hp pool ... augment the radio
... by 2 tiles ... more useful and tactical during the battle"), pending four sessions
behind agent-sequenced work. It is (1) an OWNER ask (outranks agent process by standing
order), (2) collision-FREE: its code lives in `src/game/stations.rb` `tick_totems!` +
`data/balance/sustain.json` + `data/display.json` -- verified `git diff --name-only
origin/main origin/junior/premium-build` touches none of them, and world.rb (1782/1800) is
not touched at all, (3) part of the TWENTIETH's delta regardless of order, (4) sized at
1/2-1 session by the spec. The deadlock itself is broken by a DECISION Junior or the owner
must speak; s138 sends the recommendation ONCE (section 1) and never waits on it. **Even if
his merge has landed at open, TS still runs first** -- T2a becomes s139's spark with a clean
surface.

Spec text (LAW for this ticket): `docs/superpowers/specs/2026-09-05-v22-one-body-cycle.md`
section 3, "### TS -- Totem re-work" (read it whole before the design table).

## 0. Orient (15 min, before any edit)

1. `fleet` -- no other LIVE session on this seat.
2. `git fetch --all && git pull`. Read Junior's activity FIRST: `git log --oneline
   origin/main..origin/junior/premium-build | head -30` (did anything land on main? did he
   cut `junior/e-tickets`? did he dark-ship?) and his note's newest sections: `git show
   origin/junior/premium-build:drafts/_junior-note-to-gabriel-20260906.md | sed -n '/^## 13/,$p'`
   (section 15+ may exist -- he writes mid-session and reads the CHECKPOINT). If his branch
   LANDED on main: TS still first (above); note it in the CHECKPOINT and T2a is s139's spark.
   If he asks something of this seat in a new section, answer it in the pt-br line, docs-only.
3. CHECKPOINT top: CLAIMED must be none; read the s137 entry whole (its pt-br line already
   gave him main's sha `2450ecb` to re-merge, two `_doc` corrections in his verbatim files,
   and the T2a wait).
4. Recompute live numbers (prose-number law): `rake pins` (expect 7 PINNED / 32 STALE /
   4 FAILED) - `ls harness/scripts | wc -l` (43) - `wc -l src/game/world.rb` (1782) -
   `python -c "import json;print(json.load(open('data/balance/sustain.json'))['totem'])"`
   (expect `cadence_ticks 900, radius 2, heal_amount 10`) - `grep totem_pulse_frames
   data/display.json` (40).
5. Push the CLAIMED line FIRST (s56 law): `CLAIMED: TS totem re-work (cadence 3 s,
   radius +2, heal scales with hp pool) -- Gabriel seat, s138.`
6. Rule 4: read every file before editing it. Files you WILL read: `src/game/stations.rb`
   (tick_totems!, digest_groups), `data/balance/sustain.json`, `data/display.json`
   (`totem_pulse_frames`), `test/game/totem_test.rb` (its staging assumes the radius-2
   field -- line 35 comment; positions must derive from CFG[:radius], not hardcode),
   `test/game/sustain_test.rb`, `test/harness/sim_identity_canary_test.rb` (the
   versioned-bank protocol in its header + the ACTIVE bank: world_loop / floor3_run /
   brasa2_run; T7_RETIREMENT = the preserved-outgoing-bank precedent),
   `harness/scripts/totem_pulse.json` (district, run_until 4582, 10 captures cut to the
   900-cadence; manifest `totem_pulse 10, fight_resolved 10, attack_hit 20`), the
   `totem_pulse_reads` row in `harness/gate_checks.json`, `src/game/telemetry.rb` ~298
   (`TELEMETRY totem heals=N pulses=M`), `src/game/world.rb` 1565-1568 (the
   `:totem_pulse` subscription -> `@transients.totem_pulse!(pulse_frames:
   @display[:totem_pulse_frames], ...)`) -- READ ONLY, do not edit world.rb.

## 1. The deadlock note to Junior (send ONCE, docs-only, then never wait on it)

Write it as section "For Junior" in the CHECKPOINT s138 entry (pt-br) AND as ONE English
paragraph in the E1c/TS record, both pointing at his section 13. Content, in this order:
- Agree with his section 13: no ff without one of the three ways; nobody on this seat
  merges his branch.
- The dev-of-record RECOMMENDATION is (c) DARK-SHIP, by his hand on his branch: the two
  data switches + bag screen inert, with the proof that matters -- canaries YES x3 with the
  switches OFF (byte-identical EVENT streams vs main = truly dark), digest lines constant
  with an empty bag, one fresh-eyes review; then the ff is one command and T2a starts the
  next session on HIS world.rb (1726, Interact extracted). Reason: it keeps the owner's
  TWENTIETH sequencing in what the owner PLAYS (S2/S3 off in the ritual build) while
  unblocking the whole SIM lane; (a) deadlocks; (b) needs the owner's or a peer's line.
- If the owner prefers (b), one line in the hub chat is enough; record it in AGENTS/CYCLE
  as a ruling the moment it lands.
- Say plainly that s138 is running TS on `stations.rb` + `sustain.json` + `display.json`
  -- none of his files -- and that the totem is his design (v20 T4): his line on the
  numbers is welcome, not gating.

## 2. TS pieces, ONE commit each (spec order; land whole or hand forward NAMED)

**(1) Design table FIRST (record-first, no edit).** Open `drafts/_v22-ts-record-<date>.md`
with the owner's verbatim words, then a totem-vs-potion table computed by a tmp script
(never hardcoded prose numbers): hp per minute a body standing in the radius receives
under {cadence 900, heal 10} vs {cadence 180, heal max(15, 5% max_hp)} at max_hp 60 / 160
/ 265 / 300 (today's kit pools -- read them from `data/balance/combat.json` kits +
`progression.rb` growth at levels 1/5/12), against the potion economy
(`economy.json provision_heal 30 / provision_cost 5 / provision_cap 3`) and the totem
telemetry the s136 soak/wall logs carry (`grep "TELEMETRY totem" tmp/wall/*.log`).
State the candidate rows: `cadence_ticks 180`, `radius 4`, `heal_min 15`,
`heal_pct_max_hp 5` (the spec's shape; ~15 hp at a ~300 pool), and ONE sentence on the
design intent: a POSITION you hold, countered by knockback -- not a free heal. Junior's
line may amend; the owner's word on the rows closes them (CYCLE owner-pending, never nag).

**(2) Data + code.** `data/balance/sustain.json totem`: replace `heal_amount` by
`heal_min` + `heal_pct_max_hp`, set `cadence_ticks 180`, `radius 4` (comment row naming
s133 + the spec). `src/game/stations.rb tick_totems!`: `heal = [heal_min,
m.max_hp * pct / 100].max` as an INTEGER (integer arithmetic only -- the digest and the
canary are byte laws; no Float ever touches hp), per healed body (its own `max_hp` = the
pool the owner named; under ONE BODY that IS the character's pool -- L20 (4)). Zero balance
constants in code (Rule 3): every number read from the hash; a missing key refuses NAMED
at boot (strict fetch, `Stations#initialize`), not a silent default. `digest_groups`
unchanged in shape (timers only). Consider `totem_pulse_frames` (display.json, 40): at
180 ticks the ring is visible 40/180 frames -- judge on the reel (piece 5), and if the
heartbeat reads as flicker the DISPLAY row is the lever (data), never code.

**(3) Tests (convict on physics, not self-report).** `totem_test.rb`: cadence exactly
`CFG[:cadence_ticks]`; heal on a small pool = `heal_min` (15 > 5% of 60), on a large pool
= pct (5% of 400 = 20 > 15) -- both positions derived from CFG[:radius] (in-range at
radius, out-of-range at radius+1); clamped at max_hp; dead untouched; Integer result
(`assert_kind_of Integer`); a `heal_amount` key left in data refuses NAMED (strict).
`sustain_test.rb` still green. Run the two files first, then the suite.

**(4) Canary audit -- the versioned-bank protocol, in full, BEFORE the gate.** The change
is INTENDED and owner-ratified (s133 verbatim is the approval), but the protocol's other
two legs are still owed: (i) an old-vs-new stream-diff audit and (ii) the outgoing bank
preserved immutable. Mechanics: BEFORE touching data/code, dump the three ACTIVE streams
headless (`Headless.run_script` lines -> `tmp/ts/old/<script>.events`); AFTER the change,
dump again and `diff`. Expected: world_loop / floor3_run / brasa2_run carried ZERO
`totem_pulse` events in the v22-e1 sweep (district is the only totem zone; world_loop's
district leg never reached 900 ticks) -- at 180 ticks world_loop MAY now pulse. Three
outcomes, each recorded: streams identical (no rebank; paste the identical md5s and the
zero-diff) - divergence explained line by line from the first `totem_pulse` (rebank:
move the ACTIVE hashes into a preserved constant with a header paragraph quoting the s133
order, like T7_RETIREMENT; new ACTIVE hashes from the post-change run) - divergence
BEFORE any totem effect or in a non-totem line (a DEFECT in the change; stop and fix).
Byte-exact prefix identity up to the first totem effect is the test of a clean change.

**(5) The reel + row (Rule 2).** `harness/scripts/totem_pulse.json`: probe the new pulse
frames headless (E1c's `tmp/e1c/probe_manifest.rb` pattern -- copy it to `tmp/ts/`;
tmp is not tracked and may be gone: the recipe is `Headless.run_script` + EventLog frames
+ possessed tile at captures), then re-cut captures to sit INSIDE pulses with a pack body
in the radius-4 ring (a PAIR of frames a few ticks apart for the expanding ring -- the
s137 lesson: a single capture of an expanding effect reads "not exercised", a pair reads
affirmative; ring life = `totem_pulse_frames` 40) and one capture showing a body healed
(numeral `+N` green, `damage_numbers_read`). Manifest re-cut to OBSERVED counts
(`totem_pulse` will be ~5x). Read the `totem_pulse_reads` row against the new geometry:
if it needs "reaches about four tiles" or a heartbeat clause, recalibrate it to what the
code draws and then gate the STRONG member affirmatively (never relax to green; the
2026-08-26 lesson). Zero collision: Junior did not touch this script or row.

**(6) Gates.** `bundle exec rake` (hooks) - `rake gate SCRIPT=harness/scripts/totem_pulse.json`
DETACHED, COMMIT-THEN-GATE (s137 law: the pin's commit must hold the judged content;
`harness/pins.rb` now prints DIRTY-JUDGED if you forget -- if you see it, re-gate after
committing, do not record). Expect `totem_pulse_reads` AFFIRMATIVE + `damage_numbers_read`
affirmative on the heal numeral. Then `rake soak N=1 ZONES=district` (env name per
`soak/run_soak.sh` header; scratch save; judge by the checker's verdict line + `TELEMETRY
totem heals=` on the bot logs -- bots are never fun evidence, this is a crash/chain
check). Re-pin with `ruby harness/pins.rb record --script totem_pulse --tag v22-ts
--commit <head> --gate-rc 0 --manifest-rc 0` only on gate_rc=0 AND manifest_rc=0.

**(7) Telemetry + strings.** `TELEMETRY totem heals=N pulses=M` keeps its wording (no
fun-verify is pending, but the TWENTIETH re-reads the totem-vs-potions rows -- do not
rename the oracle). No player-visible strings change (the totem has no label).

## 3. Optional -- ONLY after TS is landed whole (review included); each lands whole or is
handed forward by name

- **(a) Critic reproducibility measurement (harness, zero GL, ~$1).** s137 saw the critic
  read the SAME byte-identical taunt_anchor frames "affirmative" once and "not exercised"
  once. Re-run `python harness/vision_critic.py --verdict captures/<reel>_gate_a --checks
  harness/gate_checks.json` TWO more times on three existing gate_a dirs (taunt_anchor's
  `captures/pilot/taunt2_r1_replay_gate_a`, aoe_specials, floor1_run) and tabulate per-row
  flips (pass<->fail and affirmative<->"not exercised") across 3 verdicts. Output = one
  table in the record + a NAMED design note for T2c ("affirmative reads need k-of-n" or
  "early/bright staging suffices"), no gate policy change this session. Do NOT record pins.
- **(b) Negative control for the recalibrated rows (review m1).** In a throwaway worktree
  with `data/display.json fx_enabled: false`, `rake gate SCRIPT=harness/scripts/floor1_run.json`
  and EXPECT `impact_fx_reads` FAIL (never pinned -- SKIP_CRITIC is not this; the critic
  must judge). Paste the verdict line. If it PASSES with fx off, the row is not failable
  and that is a T2c row item.
- **(c) The breach-beat stager (harness-only, new file, zero collision).** No wall script
  stages `seal_breached`; `seal_breach_reads`' BREACH half (TOLL PAID, slab -> gold) has zero
  coverage. Author `harness/scripts/seal_breach.json` on basement_2 (toll_pocket's start:
  `[3,5]`, banked 60, seal at `[6,2]`, price 40; keep toll_pocket.json untouched -- it is
  Junior's verbatim file) with the pilot/tuner pattern; manifest `{zone_entered, seal_breached
  1}` from observation; `gate_scope.json` unchanged (basement_2 already scoped). Gate for the
  affirmative breach read. If the pack cannot reach the seal in sane staging, record WHY
  (headless probe) and hand it forward.

## 4. Review (Rule 6) -- BEFORE the close push

Fresh-eyes headless scrubbed `pi -p` on the TS diff + record (detached worktree at the
reviewed commit, PI_* unset, `--thinking max --tools read,bash`, brief inlines the owner's
verbatim words, the design table, the canary audit diff, the gate verdict lines; demand the
JSON verdict as the LAST message; ~$1). s137's shape: `tmp/e1c/review/run.sh` + `ask.txt`
are the launch recipe if tmp survived (else the E1 record section "Review" describes it).
A BLOCK is landed, never argued down; disagreements are answered in writing. Council is NOT
needed unless the heal formula's shape becomes a taste argument (then one cheap pass).

## 5. Fences and traps (live-verified where marked)

- **ONE GL replay at a time.** No soak while a gate runs; no bin/play. Probe headless first.
- **COMMIT-THEN-GATE for every re-pin** (s137, project MEMORY): a pin recorded on a dirty
  judged path is stamped DIRTY-JUDGED -- treat that as "re-gate after committing".
- **A `data/` commit flips every earlier pin STALE by the ledger's path rule** (s137: the
  dungeon_1 decor fix cost five re-gates). TS changes data by design; the 7 current pins
  WILL go STALE -- expected, T2c's full re-pin owns them. Do NOT re-gate them; say so.
- **world.rb is 1782/1800 and Junior's Interact extraction lives on his branch** -- TS must
  not add a line to world.rb; if the design needs one, STOP and record why (it does not: the
  heal lives in `Stations#tick_totems!`).
- **Junior's files stay his:** `fx.rb`, `light.rb`, `controls_overlay.rb`, `tileset.rb`,
  `hud.rb`, `renderer.rb`, the S1-S3 files, his `_doc`s in basement_pocket/toll_pocket;
  `drafts/lanes/**`. If the totem ring's LOOK (not its duration row) needs work, route it.
- **Integer law:** `heal` must be an Integer computed with integer ops; a Float in hp poisons
  the digest and the save (schema 3 canonical-leaf law refuses Floats NAMED).
- **Never relax a row to green it**; recalibrations state what the code promises and are
  followed by an affirmative gate on the strong member.
- **Record-first:** evidence boxes UNCHECKED until output is pasted (s134-s137 all caught
  pre-filled evidence live). Every number in prose is computed or pointed at.
- **CRLF:** main-tree files may materialize CRLF (autocrlf) -- `sed -i 's/\r$//' <file>`
  before exact-text edits; the write tool for big payloads (bash heredocs cut past ~10KB).
- **Critic levers:** `CRITIC_MAX_TOKENS=24000` for long reels; non-streaming wire is the
  default; judge a slow critic by process CPU time (~1 s CPU for minutes = waiting on Bedrock,
  normal), never by wall time; a 0-byte headless-pi log is buffered output, not a dead child.
- No fun-verify pending, no measurement freeze armed. Owner-pending items (D-T1, A3, FASE-7
  numbers, AS scale) are never nagged; the TS rows join that list as CANDIDATES.
- Out of scope, named: T2a (deadlocked -- section 1), the full re-pin (T2c), E4 coral palette
  (Junior's E4 record), the low-hp strip tint / vessel label / spark contrast (his surfaces,
  routed in s137), any edit to `data/zones/**` or `authoring/**`.

## 6. Rule 7 -- budget and stop conditions

Declared: 1-2 totem_pulse gates + 1 soak episode (no critic) + fresh-eyes ~$1; optional
section 3 adds ~6 critic verdicts (a) + 1 gate (b) + 1-2 gates (c), all AWS-internal and
pre-cleared -- declare the count in the record. **Stop:** TS landed whole (data + code +
tests + canary audit/rebank + reel/row + gate + soak + review + docs + push) with the owner's
numbers recorded as CANDIDATES and Junior's deadlock note sent; section 3 items are
NAMED follow-ups if headroom ends. A half-landed SIM change is NEVER pushed: if the session
threatens mid-unit compaction after piece (2), finish through piece (4) (data + code +
tests + canary) or revert to the parent commit and hand the design table forward.

## 7. Close (every session)

Ticket record `drafts/_v22-ts-record-<date>.md` (design table + owner verbatim + canary
audit + gate/soak lines = its spine). CYCLE.md: TS row -> DONE with the candidate numbers,
owner-pending gains "TS rows (cadence/radius/heal_min/pct) -- his word closes them",
named debts: pins STALE count recomputed. CHECKPOINT s138 entry + CLAIMED -> none; es-CR
line for Gabriel (what the totem does now, in gamer words: pulsa cada 3 s, alcanza 4
casillas, cura 15 o el 5% de tu vida -- lo que sea mayor; sus numeros son candidatos hasta
tu palabra) and pt-br line for Junior (the deadlock recommendation of section 1, main's
sha to re-merge, that TS touched none of his files, his line on the totem numbers welcome).
`git fetch` + rebase + push. Harvest any new seat mail into the triage doc. Tree clean
except tmp/. Checkpoint to disk before any /compact.

**Next ticket after TS:** T2a IF Junior's branch (or the dark-ship) is on main -- carve from
HIS world.rb; else the next collision-free owner-adjacent piece: T4 "the fine" pure math on
the T1 character record (spec section 3 T4) -- decide at s139's orient with the same
deadlock test.
