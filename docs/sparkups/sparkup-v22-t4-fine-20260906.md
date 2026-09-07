# Spark-up -- game-two session s139: T4 THE FINE (XP loss + XP debt, pure math + telemetry) -- or T2a if the deadlock broke

> SUPERSEDED as the s139 spark (00:52 the same night): the deadlock BROKE -- Junior dark-shipped S2+S3
> and fast-forwarded his branch onto main under AMENDMENT J-2, so s139 runs T2a
> (`sparkup-v22-t2a-extraction-20260906.md`). T4 is the ticket AFTER T2a (or s139's fallback if the
> merged main is red at orient); section 0's deadlock preamble is obsolete, sections 1-4 and 7-8 stand.

TS is DONE and pushed (s138, `4d59f6a..a57e80a`): the totem pulses every 3 s, reaches 4
tiles, heals max(15, 8 % of the body's own max_hp) as an Integer; `Stations` reads its
four rows strictly; world_loop's canary was REBANKED under the versioned protocol (three
inserted idle-pulse lines, nothing else moved; F67 bank preserved); the totem_pulse reel
was re-cut with its input stream untouched, its row recalibrated to what `draw_pulse_ring`
draws (a WAVE judged by REACH), gated AFFIRMATIVE twice and PINNED `a5b2b79`; district soak
PASS; fresh-eyes review PASS WITH MINORS with all 8 findings landed (pct 5 -> 8 was its
pick); motion critique: "HEARTBEAT -- passes". `rake pins` = 1 PINNED / 38 STALE (T2c) /
4 FAILED. `world.rb` 1782/1800. Records: `drafts/_v22-ts-record-20260906.md` (spine) and
`drafts/_v22-ts-review-20260906.md` (verbatim). The four totem rows are CANDIDATES until
the owner's word (CYCLE owner-pending; never nag).

## 0. Orient (15 min, before any edit) -- the deadlock test decides the ticket

1. `fleet` -- no other LIVE session on this seat (the "two sessions in one key" flag is
   two session files, not two processes; judge by node.exe count + the lease line).
2. `git fetch --all && git pull`. Then Junior FIRST:
   `git log --oneline origin/main..origin/junior/premium-build | head -20` -- at s138's
   close his branch was at `8ef5567` (84+ commits, NOT ff-able; merge-base `f609c31`; his
   newest work = wall #5 low-hp rim rows, no collision with anything below). Read any
   NEW note section: `git show origin/junior/premium-build:drafts/_junior-note-to-gabriel-20260906.md
   | sed -n '/^## 15/,$p'` (s138's pt-br line asked him to DARK-SHIP S2+S3 behind data
   switches with canaries YES x3 + deterministic digest + NO Float in balance data --
   his `status.json` carries `chill.step_frames_pct 0.3`). Check main too:
   `git log --oneline a57e80a..origin/main` (did anything land from his side?).
3. **The deadlock test (one line in the CHECKPOINT, then move):**
   - IF his dark-ship (or a peer amendment recorded in the hub chat) has LANDED ON MAIN
     -> this session is **T2a** (section 5 below; carve from HIS world.rb, 1726).
   - ELSE (default expectation) -> this session is **T4 THE FINE** (sections 1-4). Do not
     wait on him; do not merge his branch; do not re-argue the recommendation (it is in
     the TS record section 1 with its fallback: T2a runs on MAIN's world.rb if his receipt
     is not on his branch when T6 closes).
4. CHECKPOINT top: CLAIMED must be none; read the s138 entry whole (it carries the es-CR
   and pt-br lines already sent -- do not resend them).
5. Recompute live numbers (prose-number law): `rake pins` (expect 1/38/4) -
   `wc -l src/game/world.rb` (1782) - `ls harness/scripts | wc -l` (43) -
   `python -c "import json;print(json.load(open('data/balance/death.json')))"` (expect
   `insurance: {max_stacks: 3}` and NO `fine` block yet) - `bundle exec rake` count
   (1531 runs at s138 close).
6. Push the CLAIMED line FIRST (s56 law): `CLAIMED: T4 the fine (XP loss + XP debt,
   pure math + telemetry) -- Gabriel seat, s139.` (or the T2a line if the test flipped).
7. Rule 4: read every file before editing it. For T4 you WILL read:
   `docs/superpowers/specs/2026-09-05-v22-one-body-cycle.md` section 3 "### T4" WHOLE
   (LAW for the ticket) and "### T5" (to know what NOT to build);
   `drafts/_v22-foundation-20260905.md` L5 (the ORDER-IS-LAW wording, owner "Approved.")
   and L6/L19 (coop death is INDIVIDUAL; temples replace it -- interim note below);
   `src/game/progression.rb` whole (204 lines: `delta_e`, `award`, `load_progress!`, the
   projector-invariant law `xp < delta_e(level+1)` on exit); `src/game/character.rb`
   lines 1-60 (record keys: `xp_debt` and `insurance` ALREADY exist as record facts,
   default 0) and 270-300 (the T1 INTERIM live/mirror map: host = every live key, seated
   guest = level/xp MIRROR of the host, unseated = none); `src/game/save_state.rb`
   420-450 (where `Party` is projected at save time); `src/game/world.rb` 155-170
   (the `Party.new(live: { level: -> { @progression.level }, xp: ... })` construction)
   and 1620-1645 (`@bus.emit(:pack_wiped)` = the veil = today's death); `src/game/telemetry.rb`
   (summary rows; `totem_summary` is the row-shape precedent); `harness/event_log.rb`
   (the CURATED stream list -- a new event NOT on it never touches the canaries);
   `test/game/progression_test.rb`; `test/harness/sim_identity_canary_test.rb` header;
   `tools/pacing_table.rb` whole (delta_e/E(L) columns; T4 adds the fine columns here);
   `docs/design-corpus/death-economy-design.md`; and the KB note the spec cites:
   `hub kb query --domain game-research "death penalty xp loss protected level two-regime"`
   (vault note `death-penalties-stat-scaling-and-progression-balance`, sections 1 and 6 --
   the shelf targets: uninsured ~4-5 % of lifetime XP at level, insured 0.5-1.5 %, flat
   10 % of dE(level+1) below the protected level, a formula above). FLAGGED numbers never
   land in `data/` without re-verification.

## 1. Design table FIRST (record-first, no edit) -- `drafts/_v22-t4-record-<date>.md`

Open the record with: the spec section quoted, the foundation L5 verbatim, the interim
rule you choose (section 2 (1)), then the fine table computed by `tools/pacing_table.rb`
extended with fine columns (NOT a tmp script -- s138 review m5: the table that decides
candidate rows is a standing tool; the tool reads k / level_cap / kill_xp LIVE and uses the
real `Game::Progression#delta_e`, formula identity with the sim). Per level 1..cap: dE(L+1),
E(L) = sum dE(2..L) (lifetime XP at level), candidate fine uninsured, fine as % of E(L),
fine as % of dE(L+1), fine with 1/2/3 insurance stacks (pct_per_stack 8: `fine*(100-8n)/100`
Integer), kills-to-repay at the measured income band. Show the two regimes: below
`protected_level` a flat `below_pct` (10) of dE(level+1); above it the formula from the KB
note (state the formula and its params as the `above` block). Put the shelf targets beside
the candidate so the owner reads the gap. Two-line design intent: death costs progress you
can EARN BACK (debt, never a lost level); insurance (T5) buys a discount, never immunity.
Council pass, ONE, cheap (Kimi + DeepSeek via `council ask`, JSON to a file, read as utf-8;
brief inlines the FULL table + the KB note sections + the owner's L5 words; re-verify every
REFUTED claim before it moves a number) -- taste/shape critique of the formula only;
quality over cost. Candidate rows are CANDIDATES until the owner's word (CYCLE
owner-pending, never nag).

## 2. T4 pieces, in order (land whole; a half-landed SIM change is never pushed)

**(1) The interim death rule -- decide, record, do not over-build.** Spec: "applied at the
character's death (solo: at the veil; coop: at the seat's death), once per death". Pre-T2b
there is no per-character body: the pack is the shared body pool and the veil fires on
`pack_wiped`. Dev recommendation (verify against the T1 interim map before adopting): the
fine applies ONCE per `pack_wiped` to the LIVE `Progression` (the interim source of
level/xp), the host record receives it through the T1 live map, a seated guest MIRRORS it
(the interim rule already mirrors level/xp; extend the mirror with `xp_debt`); per-seat
death arrives with T2b (record the retirement there). Insurance stacks are read from the
host record (`insurance`, 0 until T5) so the insured branch is exercised by tests only.
Write the rule in the record + a one-paragraph comment at the hook; it is an INTERIM, named.

**(2) Data.** `data/balance/death.json` gains `fine: { protected_level, below_pct, above:
{ ...formula params... } }` and `insurance.pct_per_stack 8` (T5 adds the purchase; the fine
needs the discount now). Strict config (the TS `totem_config!` precedent): exactly the
expected keys, Integers only (no Float ever enters the balance path), missing / unknown /
Float refuses NAMED at boot. Comment row naming L5 + the spec.

**(3) Code.** `Progression`: `attr_reader :xp_debt` (live fact, starts 0; `load_progress!`
gains `xp_debt:` from the record with a default for the strict decoder's existing value);
`fine!(insurance_stacks:)` -- ORDER IS LAW: `fine = fine_table(level)` -> `fine = fine *
(100 - pct_per_stack * n) / 100` (Integer) -> `debt = [0, fine - xp].max` -> `xp = [0, xp -
fine].max` -> `@xp_debt += debt`; level NEVER decreases; returns a Struct/hash
`{level, fine, insured, debt, xp_after}` for the telemetry line; `award(amount)` pays debt
FIRST (`pay = [amount, @xp_debt].min; @xp_debt -= pay; amount -= pay`) then the existing
loop -- the exit invariant `xp < delta_e(level+1)` must hold after BOTH. Zero balance
constants in code. `world.rb`: ONE hunk at the wipe site -- call `fine!` with the host's
stacks, emit a registered `:death_fine` event (EventBus::EVENTS whitelist; NOT added to
`Harness::EventLog::EVENTS`, so the wall streams and the canaries never see it), plus the
`xp_debt: -> { @progression.xp_debt }` live key in the Party construction. Budget: world.rb
may grow by <= 6 lines (1782 -> <= 1788); if the design needs more, STOP and extract
(Crossing precedent) -- never cross 1800, and remember Junior's branch will rebase over this
hunk (keep it one contiguous block, name it in the record for his merge). `telemetry.rb`:
`TELEMETRY death_fine player=N level=L fine=F insured=n debt=D xp_after=X` per event (one
line per death, printed as it happens, like `TELEMETRY netplay ...`) + summary rows
`deaths`, `xp_lost`, `xp_debt_paid` (L10). `character.rb`/`save_state.rb`: the mirror
extension only; the record already carries `xp_debt` (schema 3, no hop). Junior's branch
touches `save_state.rb`, `save_state_test.rb` and `world.rb` (S1 bag sync) -- keep T4's
edits to ADDITIVE hunks away from his (`git diff origin/main origin/junior/premium-build
-- src/game/save_state.rb` shows his lines), and record the overlap for his merge.

**(4) Tests (convict math, every branch).** `test/game/progression_test.rb` (or a new
`fine_test.rb`): table rows at level 1, at `protected_level - 1` / `protected_level` /
`protected_level + 1`, at cap; the ORDER (a case where fine > xp produces debt and xp 0; a
case where fine <= xp produces no debt; insured 1/2/3 stacks reduce the fine BEFORE the
debt split -- assert the Integer arithmetic exactly); level never decreases (property over
1..cap with xp at 0, mid, and `delta_e(level+1) - 1`); `award` pays debt first (a kill
worth less than the debt leaves xp untouched; a kill worth more pays the debt then levels
if due); the NAMED invariant row: `xp < delta_e(level+1)` holds AFTER `fine!` and AFTER an
`award` that pays debt then levels -- property-style over the whole level range (council
s133 Kimi C5: proven, not asserted); strict config refusals named; `Integer` results
everywhere; the interim mirror carries `xp_debt` to the host record and the seated guest
(`Party` projection test); a save round-trip keeps `xp_debt` (existing save_state tests
extended, not rewritten). Telemetry test: the line shape with real numbers from a real
wipe staged headless (kill the pack through `take_hit`, tick to the veil).

**(5) Canary proof (spec: "the fine changes no RNG draw").** BEFORE any edit dump the
three ACTIVE streams (`tmp/ts/dump_streams.rb` is the recipe: copy it to `tmp/t4/`, it
resolves src/data relative to itself); AFTER the change dump again and `diff`. Expected:
byte-identical (none of world_loop / floor3_run / brasa2_run wipes, and `death_fine` is
off the curated list). If ANY stream moves: STOP, name why in the record, do not rebank
by reflex -- a moved stream here is a DEFECT until proven otherwise. Paste the identical
md5s.

**(6) Soak.** `N=1 TICKS=18000 ZONES=district rake soak` detached (bots die in district;
the s138 soak used the `tmp/ts/soak_wrapper.sh` + `powershell Start-Process` shape --
copy it). Judge by the checker verdict line + `grep "TELEMETRY death_fine" tmp/soak/<run>/ep1/*.log`
(at least one line, identical on host and joiner = the fine is digest-safe) + the summary
rows. The live save md5 must not move (quarantine law). Bots are never fun evidence.

**(7) No surface.** No HUD, no card (T6), no INSURE verb (T5), no player strings. No Rule 2
row is owed (nothing visual moved) -- say so; `rake pins` stays 1/38/4 unless a `data/`
commit flips totem_pulse STALE (it will: `death.json` is data -> expected, T2c owns it; do
NOT re-gate it).

## 3. Review (Rule 6) -- BEFORE the close push

Fresh-eyes headless scrubbed `pi -p` (`--thinking max -t read,bash`, PI_* unset, detached
worktree at the reviewed commit; `tmp/ts/review/run.sh` + `ask.txt` are the launch recipe
-- copy to `tmp/t4/review/`). The brief inlines: the spec T4 text, L5 verbatim, the pacing
table, the interim rule, the FULL diff, the canary diff (zero), the soak tail, and the TEST
OUTPUT FILES. **s138 lesson (global memory): the reviewer CANNOT run tests or headless sim
from its worktree while this seat is LIVE (seat-lease gate) -- never promise it; hand it
the dumps to re-derive from and ask it to re-derive the arithmetic by hand.** Math review
mandate: "every branch of `fine!` has a test row; prove the invariant rows prove what they
claim; name any Float, any RNG touch, any world.rb line beyond the hook". Demand the JSON
verdict as the LAST message. A BLOCK is landed, never argued down; the review verbatim goes
to `drafts/_v22-t4-review-<date>.md`; every landing gets its own commit BEFORE re-running
the affected gate (commit-then-gate is a law, not a habit).

## 4. Close (every session)

Ticket record `drafts/_v22-t4-record-<date>.md` (table + owner verbatim + interim rule +
canary identity + soak tail + review = its spine). CYCLE.md: T4 row -> DONE with the
candidate rows, owner-pending gains "T4 fine rows (protected_level / below_pct / above
params / pct_per_stack) -- his word closes them", debts recomputed (pins). CHECKPOINT s139
entry + CLAIMED -> none; es-CR line for Gabriel (what dying costs now, in gamer words: se
pierde XP, nunca un nivel; lo que no alcanza queda como deuda que las matanzas pagan
primero; el seguro del banco llega en T5; sus numeros son candidatos hasta su palabra) and
pt-br line for Junior (what T4 touched and the ONE world.rb hunk his rebase will meet; the
dark-ship recommendation stands as recorded -- do not restate it whole, point at the TS
record section 1; main's sha to re-merge = the close commit). `git fetch` + rebase + push.
Harvest seat mail (`~/.pi/agent/mail/game-two/inbox/`, empty at s138). Tree clean except
tmp/. Checkpoint to disk before any /compact.

## 5. IF the deadlock broke: T2a instead (read spec section 3 "### T2a" WHOLE first)

Only if his dark-ship or a recorded peer amendment is ON MAIN at orient. Then: pull main,
confirm `wc -l src/game/world.rb` (his 1726 + whatever landed), run the canary and the
suite on the merged tree BEFORE touching anything (his landing is his; a red here is his
receipt's problem -- STOP and mail him, do not fix his merge). T2a = byte-inert carve of
`Game::Party` / `Game::Character` (owning body/forms) / `Game::ZoneState` so `World` ticks
one `@zone_state`; `world.rb` net DOWN (target <= 1,500); gates = canary banks UNCHANGED
(no rebank -- a moved stream is a defect), `rake gate SKIP_CRITIC=1` on world_loop /
dash_strike_rip / floor3_run with `_gate_a` dirs byte-compared against a run from the
parent commit (MEMORY 2026-08-25: compare gate_a, never the plain out_dir), `rake perf`
p95 before/after pasted, `ZoneState#snapshot_estimate` reader. Fences: no behavior change,
no data edits; a needed behavior change STOPs and is named for T2b. Reviewer brief:
"prove every moved line moved unchanged; list any semantic drift" -- diff-only, hand it
the `git diff -M --stat` and the canary/gate outputs (it cannot run them, see section 3).

## 6. Optional -- ONLY after the ticket is landed whole (review included); each lands whole or is handed forward by name

- **(a) Negative control for the recalibrated rows (E1c review m1, still owed):** in a
  throwaway worktree with `data/display.json fx_enabled: false`, `rake gate
  SCRIPT=harness/scripts/floor1_run.json` and EXPECT `impact_fx_reads` FAIL (never
  pinned; the critic must judge). Paste the verdict line. If it PASSES with fx off, the row
  is not failable -> T2c row item.
- **(b) Critic reproducibility measurement (~$1):** `python harness/vision_critic.py
  --verdict captures/<reel>_gate_a --checks harness/gate_checks.json` TWICE more on three
  existing gate_a dirs (totem_pulse, aoe_specials, floor1_run); tabulate per-row flips
  across 3 verdicts; one table + a NAMED design note for T2c; no pins.
- **(c) The breach-beat stager** (`harness/scripts/seal_breach.json` on basement_2,
  toll_pocket untouched -- it is Junior's verbatim file): manifest `{zone_entered,
  seal_breached 1}` from observation; gate for the affirmative breach read; if the pack
  cannot reach the seal in sane staging, record WHY (headless probe) and hand it forward.

## 7. Fences and traps (live-verified where marked)

- **ONE GL replay at a time.** No soak while a gate runs; no bin/play. Probe headless first.
- **Multi-line scripts go in files via the WRITE tool, run by path.** Never bash heredocs
  for anything > ~10 KB or non-ASCII (they truncate mid-body and mojibake -- hit again
  s138), and the newest `rules-gate` (pi-setup `4ebbcb6`, may be installed by the time you
  run) BLOCKS stdin readers in bash (heredocs, `python -`, `node -`, bare `cat`) -- write
  the file, then `python tmp/t4/x.py`.
- **COMMIT-THEN-GATE for every pin; a `data/` commit flips earlier pins STALE** by the
  ledger's path rule (expected; T2c owns the full re-pin; say so, do not re-gate them).
- **CRLF:** main-tree files materialize CRLF (autocrlf) -- `sed -i 's/\r$//' <file>` before
  exact-text edits (git sees a no-op); the write tool for big payloads.
- **Integer law:** no Float ever touches xp / debt / level; the digest and schema 3 refuse
  Floats NAMED. Percent math = `(x * pct) / 100` Integer division, ORDER as L5 states.
- **world.rb <= 6 new lines, one hunk.** 1782/1800 on main; Junior's 1726 will rebase over
  it. If T4 needs more, STOP and extract into a plain object -- never a "just this once".
- **Junior's files stay his:** `fx.rb`, `light.rb`, `controls_overlay.rb`, `tileset.rb`,
  `hud.rb`, `renderer.rb`, the S1-S3 files, `drafts/lanes/**`, his `_doc`s. His `65f52e5`
  and the low-hp rim rows land with his merge, not by hand here.
- **Still-frame rows describe the FRAME, not the mechanic** (s138 M2) -- irrelevant for T4
  (no row), law for T2c and section 6.
- **Record-first:** evidence boxes UNCHECKED until output is pasted; every prose number is
  computed or pointed at (the table comes from the tool, never typed).
- **Never wait on the peer**: the deadlock recommendation and its fallback are recorded
  once (TS record section 1, CYCLE owner-pending); if Junior answers, harvest his line into
  the record and adjust the plan -- otherwise proceed.
- No fun-verify pending, no measurement freeze armed. Owner-pending items (D-T1, A3, FASE-7
  numbers, AS scale, TS rows) are never nagged; T4's rows join that list as CANDIDATES.
- Out of scope, named: T5 INSURE verb, T6 ledger card, any HUD/strings, T2c re-pin, E4
  palette, the vessel-label / low-hp strip / spark-contrast items (his surfaces), any edit
  to `data/zones/**` or `authoring/**`.

## 8. Rule 7 -- budget and stop conditions

Declared: suite runs (hooks) + 1 soak episode (no critic) + ONE council pass on the fine
table (~$0.05-0.20) + fresh-eyes review (~$1-5, default tier, ~25 min) -- all AWS-internal
and pre-cleared; optional section 6 adds <= 1 gate (a) + ~6 critic verdicts (b) + 1-2 gates
(c). Declare the actual count in the record. **Stop:** T4 landed whole (data + code + tests
+ canary identity + soak + telemetry + review + docs + push) with the fine rows recorded as
CANDIDATES; section 6 items are NAMED follow-ups if headroom ends. If the session threatens
mid-unit compaction after piece (3), finish through piece (5) (data + code + tests + canary)
or revert to the parent commit and hand the design table forward.

**Next ticket after T4:** T5 insurance at the bank (lane C2: the INSURE verb, `price` by
the buyer's level, `max_stacks 3`, `pct_per_stack 8`; a station verb = Rule 2 row + the
bank's cue) -- unless the deadlock broke, in which case T2a takes the slot and T5 follows.
