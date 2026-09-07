# Spark-up -- game-two session s139: T2a PARTY / CHARACTER / ZONESTATE EXTRACTION (byte-inert carve of world.rb) -- the deadlock BROKE, T2a is unblocked

State at s138's close (all pushed): TS DONE (`4d59f6a..a57e80a`; record `drafts/_v22-ts-record-20260906.md`,
review verbatim `drafts/_v22-ts-review-20260906.md`): the totem pulses every 3 s, reaches 4 tiles, heals
max(15, 8 % of the body's own max_hp) Integer; rows are CANDIDATES until the owner's word (CYCLE
owner-pending, never nag). THEN, at 00:52, Junior DARK-SHIPPED S2+S3 (option c, exactly as s138
recommended) and fast-forwarded `junior/premium-build` onto main by his own hand under his peer
AMENDMENT J-2 ("S2+S3 may land on main DARK; the TWENTIETH decides WHEN the two switches turn on") --
`a57e80a..c8c51aa`, 92 commits, pure ff. His receipts (note sections 15-17 of
`drafts/_junior-note-to-gabriel-20260906.md`, `drafts/_darkship-receipt-20260906.md`,
`drafts/_review-darkship-freshEyes-20260906.md`): switches OFF by data (`economy.json item_drops_enabled
false`, `status.json burn.enabled false`), `ruby tools/manifest_census.rb --md5` = 42/42 world-script
EVENT streams IDENTICAL to `d4bb6e4`, canaries YES x3, suite 1596/0, fresh-eyes MERGEABLE dark. Main now
has `Game::Interact`, `Game::Loot`, `Game::Bag`, `ItemCatalog`, his tools (`manifest_census.rb`,
`wall_triage.rb`, `gate_batch.sh`, `boss_probe.rb`), the E3/E4/E5 presentation, and `world.rb` at
**1728/1800**. He launched WALL #6 detached on HIS machine at main's head (44 scripts, ~3.5 h) to re-pin
the OFF build; that harvest (pins.json + verdicts) is HIS and will land later -- T2a records NO pins
(SKIP_CRITIC gates refuse to pin by law), so there is no collision. The T2a fallback ("carve main's
1782 world.rb") is void: **T2a starts on HIS world.rb (1728), which IS main.** His section 15 mapped the
surface: his additions in T2a's regions are ADJACENT, not overlapping (`init_loot!`, `@status_cfg`,
`load_bag!` after `build_party`).

Spec text (LAW for this ticket): `docs/superpowers/specs/2026-09-05-v22-one-body-cycle.md` section 3
"### T2a" -- read it WHOLE before the plan; then "### T2b" (to know what NOT to build here) and the
AMENDMENT J-2 paragraph (Merge point 2). Cost line: 1 session, reviewer ~$5, diff-only review.

## 0. Orient (15 min, before any edit)

1. `fleet` -- no other LIVE session on this seat (two session FILES in one key is normal; judge by
   node.exe count + the lease line).
2. `git fetch --all && git pull`. Junior first: `git log --oneline c8c51aa..origin/main` (did his wall
   #6 harvest land? pins/verdicts only = fine; anything in `src/` = read it before carving) and his
   note past section 17: `sed -n '/^## 18/,$p' drafts/_junior-note-to-gabriel-20260906.md`. He works
   in SHORT branches from main now (his section 17) -- `git branch -r | grep junior` shows them; a live short
   branch touching `world.rb`/`pack.rb`/`character.rb` is a collision to coordinate by CHECKPOINT line
   BEFORE carving, never after.
3. **Prove the merged main is green on THIS machine before touching it** (his receipts are his; a red
   here is a receipt problem -> STOP, record, mail him -- never fix his merge by hand): `bundle exec
   rake` (expect ~1596 runs / 0 failures; the s138 close was 1531 -- the +65 are his), then
   `bundle exec ruby -Itest -Isrc test/harness/sim_identity_canary_test.rb` (3/3 with the ACTIVE bank:
   world_loop `f023e3dd...`, floor3_run `648810ff...`, brasa2_run `3fd04895...`).
4. CHECKPOINT top: CLAIMED must be none; read the s138 entry whole (its pt-br line asked for the
   dark-ship -- he did it; the es-CR line already told the owner what the totem does).
5. Recompute live numbers (prose-number law): `wc -l src/game/world.rb src/game/pack.rb
   src/game/character.rb` (1728 / 155 / 327 at spark time) - `rake pins` (his harvest may have moved
   it; at spark time 1 PINNED / 38 STALE / 4 FAILED on the pre-ff ledger) - `ls harness/scripts | wc -l`
   (43) - `ruby tools/manifest_census.rb --md5 > tmp/t2a/census_before.txt` (~60 s headless; the
   42/42 md5 baseline of the UNCHANGED tree -- this file is the ticket's byte-inert oracle) -
   `rake perf` once, paste p95 (the before number).
6. Push the CLAIMED line FIRST (s56 law): `CLAIMED: T2a Party/Character/ZoneState extraction (byte-inert
   carve of world.rb 1728 -> <= 1500) -- Gabriel seat, s139.`
7. Rule 4: read before edit. You WILL read: `src/game/world.rb` WHOLE (1728 lines -- yes, whole; you are
   about to move a third of it; note `enter_zone` ~1069, `respawn_pack` ~1288, `handle_seat_death`
   ~1566, `assign_waiting_seats` ~1608, `digest_snapshot` ~512, `tick_world` ~552, the Party
   construction ~155-170, `init_loot!` / `load_bag!` = his adjacent lines); `src/game/pack.rb` (155);
   `src/game/character.rb` WHOLE (`Game::Character` line 29, `Game::Party` line 220 -- T2a GROWS it, it
   does not start it); `src/game/interact.rb`, `loot.rb`, `bag.rb` (his; read to not break their
   World seams); `src/game/field_economy.rb` header (per-zone corpses/drops already live in a plain
   object -- the ZoneState precedent); `src/game/transients.rb`, `volleys.rb`, `flow_field.rb` headers;
   `src/game/save_state.rb` 400-489 (Party projection + `sync_max_hp!`); `test/app/line_caps_test.rb`;
   `test/game/pack_test.rb` (if present) + every test that constructs `Pack`/`Party` directly
   (`grep -rln 'Pack.new\|Party.new' test/`); `harness/scenes/netplay_scene.rb` header (two Worlds in
   one process -- ivars you move must stay per-World); `tools/manifest_census.rb` header (the `--md5`
   oracle); `drafts/_v22-t1-record-20260906.md` section on Party/Character (the T1 interim live/mirror
   rule that T2a must carry unchanged).

## 1. The plan is STAGED and each stage is independently shippable (headroom law)

T2a is one ticket but three carves; the s133 council named T2b the budget-breaker, not T2a -- still,
a 1728-line file does not move in one sitting without risk. Land it as **stages, one commit each,
every commit byte-inert-proven** (suite green via hooks + canary 3/3 + `manifest_census --md5` 42/42
identical to `tmp/t2a/census_before.txt`). If headroom ends after a stage, the rest is handed forward
NAMED (T2a-2) with the census file preserved -- a half-moved carve is NEVER pushed; a whole stage is.

**Stage 1 -- `Game::Party` owns the seats.** Move into `src/game/party.rb` (new file; `Party` leaves
`character.rb`, which keeps `Character`): the seat -> character map, `wipe?`, possession pointers,
waiting-seat assignment -- from `Pack` + `World#assign_waiting_seats` / `handle_seat_death` /
`respawn_pack`. `Pack` shrinks to a shim (delegations) or retires; every `Pack.new` in tests moves
with it. World's call sites become one-line delegations. The T1 interim live/mirror map
(`character.rb` ~278-295) moves UNCHANGED in behaviour (a projection test pins host = live keys,
guest = level/xp mirror, unseated = none, before and after).

**Stage 2 -- `Game::ZoneState` owns what `enter_zone` swaps.** New `src/game/zone_state.rb`: humans,
corpses (already per-zone in FieldEconomy -- keep the seam, do not duplicate), projectiles, volleys,
transients, flow cache, arrivals, `zone_left_at` -- exactly the ivar set `enter_zone` (~1069) touches
today (`awk '/def enter_zone/,/^    end$/' src/game/world.rb | grep -o '@[a-z_]*' | sort -u` lists
them; classify each: per-zone -> ZoneState, per-World -> stays). World ticks `@zone_state` instead of
a dozen ivars; readers (`humans`, `projectiles`, `totem_pulses`, ...) delegate. `ZoneState#snapshot_
estimate` = a debug reader returning the byte size of the zone's serialized state (lane H's
measurement; NO wire format, no persistence -- council s133 DeepSeek Q2). **Digest law:**
`digest_snapshot` (~512) must emit the SAME group names in the SAME order -- pin the group-name
list in a test BEFORE moving (a real World, two zones), and keep it green; the netplay digest folds
every registered event, so an ivar move that changes emission order is a desync on the wire.

**Stage 3 -- `Game::Character` owns its body/forms in the field.** The character's `form`/`forms`
(T1 record) become the reader the HUD/ledger will use (L20 (4): nothing reads World internals after
this); today the body is a `Pack` member -- expose `Character#body` / `#forms` through Party without
changing who ticks what. If stage 3 needs ANY behaviour change (who is possessed on wipe, form on
respawn), STOP: that is T2b, name it in the record, ship stages 1-2.

Target: `world.rb` net DOWN to <= 1,500 (paste `wc -l` before/after every stage); `line_caps_test` cap
stays 1800 (the cap is the law, not the target). Zero data edits, zero strings, zero HUD.

## 2. The byte-inert proof (every stage, then once whole)

- `bundle exec rake` (hooks) and the canary file alone -- ACTIVE bank UNCHANGED (a moved stream is a
  DEFECT, never a rebank; there is no ratified sim change in this ticket).
- `ruby tools/manifest_census.rb --md5 > tmp/t2a/census_after_<stage>.txt && diff
  tmp/t2a/census_before.txt tmp/t2a/census_after_<stage>.txt` -> EMPTY. 42/42 curated EVENT streams
  identical is the strongest headless proof this repo has (Junior's dark-ship precedent, section 15).
- Whole-ticket, GL (detached, one window at a time, COMMIT first): `rake gate SKIP_CRITIC=1
  SCRIPT=harness/scripts/<world_loop|dash_strike_rip|floor3_run>.json` -- double replay + md5 each;
  then the `_gate_a` dirs of those three BYTE-COMPARED against the same gates run from a `git
  worktree` pinned to the PARENT commit of the first carve (MEMORY 2026-08-20/25: baseline from a
  worktree so live edits cannot contaminate it; compare `_gate_a`, never the plain out_dir). Paste the
  `cmp`/md5 lines per frame set. SKIP_CRITIC gates never pin -- record NOTHING in `harness/pins.json`
  (Junior's wall #6 harvest owns that file this week).
- `rake perf` after: p95 tick within noise of the before number (paste both).
- Netplay sanity once at the end (two real Worlds + Sessions over loopback inside the replay window):
  `rake gate SCRIPT=harness/net/netplay_session.json CHECKS=harness/net/gate_checks.json` -- the
  digest-order law above is what this proves in practice.

## 3. Review (Rule 6) -- BEFORE the close push

Fresh-eyes headless scrubbed `pi -p` (`--thinking max -t read,bash`, PI_* unset, detached worktree at
the reviewed commit; launch recipe `tmp/ts/review/run.sh` + `ask.txt` -> copy to `tmp/t2a/review/`).
Mandate (spec): **"prove every moved line moved unchanged; list any semantic drift"** -- hand it `git
diff -M --stat`, the per-file `git diff -M --color-moved=dimmed-zebra` dumps, the census diff (empty),
the canary output, the gate md5 lines, the perf numbers, `wc -l` before/after. **s138 lesson (global
MEMORY): the reviewer CANNOT run tests or headless sim from its worktree while this seat is LIVE
(seat-lease gate) -- never promise it; hand it the dumps and ask for a re-derivation by reading.**
Demand the JSON verdict as the LAST message. A BLOCK is landed, never argued down; verbatim to
`drafts/_v22-t2a-review-<date>.md`; every landing = its own commit, then the affected proof re-run.
Council is NOT needed (refactor, not taste) unless a reviewer names a design fork (then one cheap pass).

## 4. Close (every session)

Ticket record `drafts/_v22-t2a-record-<date>.md` (stage table with before/after `wc -l`, the census
diff, canary + gate + perf lines, the review = its spine; record-first: evidence boxes UNCHECKED until
pasted). CYCLE.md: T2a row -> DONE (or T2a stages 1-2 DONE + T2a-2 NAMED), the deadlock text -> RESOLVED
by J-2 + Junior's ff (one line; the recommendation and the fallback are history now), debts recomputed
(pins per `rake pins`), `world.rb` line count. CHECKPOINT s139 entry + CLAIMED -> none; es-CR line for
Gabriel (nothing changed in play; the code moved so the ONE BODY change (T2b) can land in a file that
fits; S2/S3 are on main but OFF until the TWENTIETH -- Junior's J-2) and pt-br line for Junior
(agradece o dark-ship + ff; the exact regions T2a moved so his short branches rebase clean; what stage
3 deferred to T2b; main's sha to re-merge = the close commit; his wall #6 harvest owns pins.json).
`git fetch` + rebase + push. Harvest seat mail. Tree clean except tmp/. Checkpoint before any /compact.

## 5. IF the merged main is RED at orient (step 3) or a live short branch of his holds world.rb

Do NOT carve on a tree you cannot prove green, and do NOT carve under a live collision. Record the
fact (one CHECKPOINT line, one pt-br line to Junior naming the failing test or the branch), then run
**T4 THE FINE** instead -- its spark is already written: `docs/sparkups/sparkup-v22-t4-fine-20260906.md` (its
section 0 deadlock preamble is obsolete; sections 1-4 and 7-8 are the T4 plan: `death.json fine` block + `insurance.pct_per_stack 8`, `Progression#fine!` with ORDER IS LAW
(L5), `award` pays debt first, the interim rule "fine once per `pack_wiped` on the live Progression,
host record + guest mirror", `tools/pacing_table.rb` fine columns + one council pass, canary identity
(no rebank), soak with `TELEMETRY death_fine` lines, world.rb <= 6 new lines in ONE hunk, math review
with dumps). T4 is otherwise the NEXT ticket after T2a.

## 6. Optional -- ONLY after the ticket is landed whole (review included); each lands whole or is handed forward by name

- **(a) Negative control for the recalibrated rows (E1c review m1, still owed):** throwaway worktree
  with `data/display.json fx_enabled: false`, `rake gate SCRIPT=harness/scripts/floor1_run.json`,
  EXPECT `impact_fx_reads` FAIL (never pinned). If it PASSES with fx off -> T2c row item.
- **(b) Critic reproducibility (~$1):** `python harness/vision_critic.py --verdict captures/<reel>_gate_a
  --checks harness/gate_checks.json` twice more on totem_pulse / aoe_specials / floor1_run gate_a
  dirs; tabulate per-row flips across 3 verdicts; one table + a NAMED T2c design note; no pins.
- **(c) The breach-beat stager** (`harness/scripts/seal_breach.json` on basement_2; toll_pocket stays
  Junior's verbatim file): manifest from observation, gate for the affirmative breach read, or record
  WHY the pack cannot reach the seal and hand it forward.

## 7. Fences and traps (live-verified where marked)

- **Byte-inert means byte-inert:** no data edits, no strings, no HUD, no behaviour. A behaviour change
  found necessary STOPs and is named for T2b in the record. A moved stream/canary is a DEFECT here.
- **ONE GL replay at a time.** No soak while a gate runs; no bin/play; Junior's wall #6 runs on HIS
  machine, not this one -- but his HARVEST commits (pins.json, `_gate-verdicts.log`) may land mid-
  session: `git pull --rebase` before every push; those files are unions and you never write them.
- **Freeze code while a detached replay runs** (MEMORY 2026-08-20: mid-sweep edits contaminated
  baselines) -- carve, commit, THEN launch the three gates; touch nothing in `src/` until they finish.
- **Multi-line scripts go in files via the WRITE tool, run by path.** Bash heredocs truncate past ~10 KB
  and mojibake non-ASCII (hit again s138), and the newest `rules-gate` (pi-setup `4ebbcb6`, possibly
  installed by the time you run) BLOCKS stdin readers in bash (heredocs, `python -`, `node -`, bare
  `cat`) -- write `tmp/t2a/x.rb`, then `bundle exec ruby tmp/t2a/x.rb`.
- **CRLF:** main-tree files materialize CRLF (autocrlf) -- `sed -i 's/\r$//' <file>` before exact-text
  edits (git sees a no-op). Moving hundreds of lines: prefer `git mv`-style whole-method moves and
  `git diff -M --color-moved` to prove identity; never retype a moved line.
- **Two Worlds in one process** (netplay scene, harness): anything you move to `ZoneState`/`Party`
  stays an instance per World -- no class-level state, no constants that hold mutable zone data.
- **Digest group names + order are a wire law** -- pin them in a test before the move.
- **line_caps_test:** the cap stays 1800; the target <= 1500 is a target. `renderer.rb` cap is 2000
  (Junior's E3 landed it at 1990) -- T2a never touches `src/app/**`.
- **Junior's files stay his:** `src/app/**` (fx, light, hud, renderer, signage, controls_overlay,
  bag_screen), `interact.rb` / `loot.rb` / `bag.rb` / `item_catalog.rb` (read them; move a seam only
  if the carve forces it, and name it in the pt-br line), `drafts/lanes/**`, `tools/premium_art/**`,
  `harness/pins.json` + `drafts/_gate-verdicts.log` this week (wall #6 harvest).
- **Record-first:** evidence boxes UNCHECKED until output is pasted; every prose number computed or
  pointed at (`wc -l`, the census diff, `rake perf` lines).
- **Never wait on the peer:** his ff is done; if he asks something in a new section, answer docs-only
  in the pt-br line and keep carving.
- No fun-verify pending, no measurement freeze armed. Owner-pending items (D-T1, A3, FASE-7 numbers,
  AS scale, TS rows, the TWENTIETH's switch-on) are never nagged.
- Out of scope, named: T2b (ONE BODY field rules -- THE model change, its own session), T2c (wall +
  HUD grammar + the full re-pin), T4-T6 (lane C), E4 palette, any `data/**` or `authoring/**` edit,
  turning `item_drops_enabled`/`burn.enabled` ON (the TWENTIETH's word, J-2).

## 8. Rule 7 -- budget and stop conditions

Declared: suite runs (hooks) per stage + 3 SKIP_CRITIC gates x 2 (change + parent-worktree baseline,
no critic = $0) + 1 netplay gate (no critic) + 1 `rake perf` pair + fresh-eyes review (~$1-5, default
tier, ~25 min); optional section 6 adds <= 1 critic gate (a) + ~6 critic verdicts (b) + 1-2 gates (c),
all AWS-internal and pre-cleared. Declare the actual count in the record. **Stop:** T2a landed whole
(three stages, census 42/42 identical, canary 3/3, three gates byte-identical to the parent baseline,
perf within noise, review, docs, push) -- OR stages 1-2 landed whole with stage 3 NAMED as T2a-2. If
the session threatens mid-stage compaction, finish the stage (code + tests + census + canary) or
revert to the stage's parent commit; the census baseline file and the stage table are handed forward.

**Next ticket after T2a:** T2b ONE BODY field rules (THE model change; the TWENTIETH's clock starts;
council s133 split it from T2c/T2d -- read the spec section whole and re-grill the risks at open) --
with T4 THE FINE (lane C, pure math) as the collision-free alternative if T2b's grill needs the owner's
word first.
