# T2 close — sim core SHIPPED (s43 built A+B+C, s44 landed C + verify ladder)

Ticket 2 of Progression v1. Spec:
`docs/superpowers/specs/2026-08-22-progression-v1.md` (P2/P4/P5/P11/
P12/P13). Brief: `drafts/_prog-t2-sim-core.md`. s43 built and committed
A+B and staged C; s43 wrote no checkpoint — this draft + the s44
checkpoint entry are the s43/s44 record.

## Commits (all local until the s44 push; origin base `97964ed`)

- **A `10c176b` fix(save)** — bak_hint picks newest backup by MTIME
  (lexicographic `.max` sorted `.bak-schema1-*` above every date-stamped
  backup, `'s' > '2'`); `@v1_raw = nil` at the top of `load` (stale v1
  bytes can no longer fire a redundant schema1 backup on a later v2
  load). 2 new save_store lanes. Hook suite at A: 1047 runs / 0F.
- **B `84a9d7a` refactor(world)** — `Game::Transients` carve
  (`src/game/transients.rb`, plain object, no bus/IO): taunt_pulses +
  kill_pops + seal_marks storage, push verbs (phase formula + pop_frames
  config moved verbatim), TWO aging clocks with their distinct pause
  laws carried as comments (`tick_combat!` pauses under hitstop AND the
  wipe veil; `tick_banner_clock!` under hitstop only), `clear!` at
  zone entry. Renderer API frozen via world delegators. world.rb
  1797 → 1775. Unit test `test/game/transients_test.rb`. Hook suite at
  B: 1051 runs / 0F.
- **C `1fe5d8b` feat(progression)** — the P13 one-commit set (17 files):
  - `award_kill` wired in the actor_died handler (killer faction
    `:pack` — possessed OR ally feeds the pack, A2); challenger death
    feeds 120 XP beside `record_boss_1_defeat!`.
  - `:level_up` registered + emitted with ZERO subscribers (T3 owns the
    beat); payload `{level: Integer}` folds into the netplay digest.
  - `Pack#sync_max_hp!` + `Creature#grow_max_hp!` (P4: hp gains the
    DELTA, clamp floor 1, dead flesh keeps 0 and revives into the new
    ceiling; no full heal).
  - `leveled_damage` at the 3 resolution sites (apply_action_hit /
    launch_projectile / launch_volley); in-flight projectiles/impacts
    keep launch-time damage (a mid-flight level-up never retro-buffs).
  - Digest rows `["level", N], ["xp", N]` + `DIGEST_VERSION` 1 → 2.
  - save-apply REORDER: home → counters+progression → `sync_max_hp!` →
    member hp clamps against the LEVELED ceiling → banked/provisions →
    seats → breaches (P3 churn law; decision-4 header comment updated).
  - `TELEMETRY progression level= xp= kills_xp=` (P12, additive-only;
    soak chain_check regexes untouched — verified NETPLAY/PERSIST/
    FIGHTS patterns only).
  - Progression ctor Integer-forces `growth` + `kill_xp` shapes
    (named refusals; `spell_growth` untouched — T4).
  - New lanes: progression unit (award table/refusal/kills_xp-at-cap,
    damage/hp identity + truncation), progression_integration
    (kill → XP → level_up → stats → digest; human-killer no-feed;
    3-site damage + launch-time pin), progression_data zone coverage
    (every spawned kit has a kill_xp row), creature/pack growth lanes,
    save_state reorder lanes (level-5 round trip clamp-free;
    lowered-growth clamp warns), state_digest pins + mutation row,
    telemetry line pins, v14 duck grew `progression` (house pattern:
    ducks grow with the World duck-type — no respond_to? guard in
    telemetry, API drift stays loud).
  - `data/` UNTOUCHED (starters frozen — measurement hygiene; pacing
    table below demanded no retune, so NO Commit D exists).
  Hook suite at C: **1068 runs / 19034 assertions / 0F**.

## Commit B identity gate (s43, blocking pre-C — transcribed record)

Worktree @ `10c176b` (old) vs `84a9d7a` (new): `rake capture` md5 sets
IDENTICAL — world_loop 10/10 PNGs, varekka_duel 5/5 PNGs (both scripts
exercise pops/stamps/pulses). SKIP_CRITIC lawful (claim = byte
identity, not a visual pass).

## OWNER DECISION (Gabriel, s43 chat) — versioned canary bank, RECORDED

**The v17 etapa-0 EVENT-stream bank becomes `ETAPA0_HISTORY` (immutable,
provenance `drafts/_junior-etapa0-20260815.md`, never asserted against,
never deleted); the ACTIVE bank carries date + owner approval + the
ratified sim change that moved it (T2 progression, spec P2/P4/P5) + this
audit's location; a miss against ACTIVE stays a blocking DEFECT — fix
the change, never rebank — unless a new ratified sim change repeats this
exact protocol (owner approval + stream-diff audit + history
preserved).** Implemented in `test/harness/sim_identity_canary_test.rb`
(header law rewritten, 3 test methods assert ACTIVE only).

## Stream-diff audit (s44, blocking precondition for the rebank — PASS)

Instrument: headless driver (temp .rb, deleted) on both builds — old =
worktree @ `84a9d7a`, new = staged C — `bundle exec ruby -Itest -Isrc`,
`Headless.run_script` per script; new build also subscribed `:level_up`
and recorded the first fire. Old build reproduced all three banked v17
md5s exactly (proves the instrument + the machine).

| script | old md5 | new md5 | lines old→new | first :level_up (new) | first divergence |
|---|---|---|---|---|---|
| world_loop | `a4150c43…` | `a4150c43…` (UNCHANGED) | 70→70 | never (ends L1) | none — BYTE-IDENTICAL |
| varekka_duel | `22dbad12…` | `68fa69f6…` | 220→220 | frame 456 (L2) | line 161, frame 1050 |
| burn_duel | `d148b838…` | `fedf0452…` | 185→184 | frame 377 (L2) | line 131, frame 495 |

Explanation (every divergent line traced):

- **world_loop** byte-identical = level-1 identity proof (zero drift
  before any level-up; L1 growth terms are arithmetic identity).
- **varekka_duel**: exactly 2 divergent lines, both `human_leashed …
  hp=` on rusher13 (30→29) — ONE leveled lobber hit (attack 20→21 at
  L2, `(20*1*8)/100 = 1`); frames/order otherwise identical. Boundary
  kill at frame 456 byte-identical (prefix = lines 1–160).
- **burn_duel**: prefix byte-identical through line 130 (frame ~495,
  well past L2@377; boundary kill line 87 identical). Cascade: blocker
  survives the frame-495 rusher14 hit (L2 max_hp 160→169, hp += 9 at
  377) and dies at 522 to challenger29 instead; retarget/leash/respawn
  knock-ons shift (rusher18/19 aggro the longer-lived blocker;
  respawn_rng draws land on different tiles/frames); striker's death at
  558 stays byte-identical (independent damage clock); lobber kills
  rusher_hater22 at 573 (leveled damage) instead of dying to it at
  784 → **the old build's pack WIPE is AVERTED** — `fight_resolved`
  flips wiped=true→false, pack_deaths 3→2, SAME kills=8; net −1 line =
  the vanished `pack_wiped`.
- Event-type sets: world_loop + varekka IDENTICAL; burn_duel's new set
  lacks ONLY `pack_wiped` (the averted wipe above — no NEW type appears
  in any new stream). `grep -c level_up` = 0 across all six streams —
  `:level_up` is NOT in the curated EventLog list and was not added
  (T3 may revisit).

Criterion (c) deviation, called out honestly: the spark predicted
set-identity; burn_duel's set legitimately SHRANK by `pack_wiped`. The
protective intents (no `:level_up` leakage, no new machinery firing)
both hold; the disappearance is the ratified buff working — recorded
here, not routed around.

## Pacing table (P11 — `tmp/t2_pacing.rb`, NOT committed; no Commit D)

k=40 level_cap=10 kill_xp: husk=8 rusher=15 rusher_hater=25
challenger=120. Declared pace: 60 kills/hour (newest human log shows 19
kills over a 10,183-frame combat span ≈ 400/h burst — sustained
session pace is far lower; 60/h is the conservative declaration, per
the brief's default).

| L | ΔE(L) | cumXP | husk | rusher | hater | challenger | h/lvl@60k/h |
|---|---|---|---|---|---|---|---|
| 2 | 80 | 80 | 10 | 6 | 4 | 1 | 0.09 |
| 3 | 160 | 240 | 20 | 11 | 7 | 2 | 0.18 |
| 4 | 320 | 560 | 40 | 22 | 13 | 3 | 0.36 |
| 5 | 560 | 1120 | 70 | 38 | 23 | 5 | 0.62 |
| 6 | 880 | 2000 | 110 | 59 | 36 | 8 | 0.98 |
| 7 | 1280 | 3280 | 160 | 86 | 52 | 11 | 1.42 |
| 8 | 1760 | 5040 | 220 | 118 | 71 | 15 | 1.96 |
| 9 | 2320 | 7360 | 290 | 155 | 93 | 20 | 2.58 |
| 10 | 2960 | 10320 | 370 | 198 | 119 | 25 | 3.29 |

Sanity rows hold (ΔE(2)=80 → 6 rusher or 10 husk; challenger 120 alone
= L2 + 40 spill). Targets MET: single-digit kills to level 2 (6),
tens by mid-cap (38–59). Starters stay; they freeze only when the
ritual stages.

## Verify ladder (s44)

- Hook suite at C: 1068 runs / 0F (per-commit hooks at A/B: 1047/1051).
- `rake gate world_loop` (full, critic ON): **PASS** — 10 captures
  byte-identical across two runs, vision PASS.
- `rake gate varekka_duel` (full, critic ON): **PASS** — 5 captures
  byte-identical, vision PASS (frames moved lawfully; the gate proves
  within-build determinism + presentation, not old-frame equality).
- Netplay gates (digest v2 on the wire, both seats): **ALL PASS** —
  session 12 captures byte-identical + vision PASS; desync scene still
  CONVICTS (`h=end/desync j=end/desync` after the manufactured fork);
  conn_lost 4 captures + vision PASS. Version-field refusal naming
  stays suite-proven (fingerprint reads the live constant; the 7
  fixtures hardcoding digest_version: 1 are seat-consistent fakes,
  untouched as expected).
- `rake perf`: **PASS** — ticks=6990 p50=0.207ms p95=0.465ms
  max=3.337ms (<< 16.6ms; measured WITH the review sub-process live —
  robust pass).
- world.rb: **1790** lines (target ≤1795, hard 1800).
- Live save `saves/world.json`: `98fe75ed…` UNCHANGED (before + after).
- Fresh-eyes review (Rule 6): **PASS, 0 blockers, 3 NITs** (below).

## Fresh-eyes review (Rule 6, s44) — PASS

Headless scrubbed pi, read-only brief (`tmp/t2_review_brief.md` shape:
diff bundle 97964ed..HEAD + T2 brief + spec + owner decision quoted in
full + banked evidence inline). Verdict: **PASS / BLOCKERS: none**.
The reviewer independently re-verified the live-save md5 unchanged.
NITs (recorded, none blocking):

1. `save_state.rb` apply!: local `cap` assigned twice (level cap, then
   provision cap) — sequential-safe today; rename one (e.g.
   `level_cap`) on the file's next touch.
2. Adding `:level_up` to the wall EventLog in T3 moves varekka/burn
   ACTIVE canary md5s AGAIN and re-fires the FULL versioned-bank
   protocol (owner approval + stream-diff audit + history row) — the
   T3 decision must carry that cost explicitly (folded into amendment
   2 below).
3. `progression_data_test` greps only `enemy_spawns` (all current
   spawn paths trace there); a future spawn source outside it degrades
   the belt to the runtime refusal — broaden the sweep when such a
   source lands.

## T3 amendments (flagged for the T3 brief-cutter)

1. `:level_up` consumer + the level/XP HUD surface + kills_xp feel beat
   land in T3 (zero subscribers today by design).
2. EventLog curated-list call (add `:level_up` to the wall instrument?)
   DEFERRED to T3 — adding it moves the varekka/burn ACTIVE canary md5s
   AGAIN and re-fires the FULL versioned-bank protocol (owner approval
   + stream-diff audit + history row — review NIT 2); bundle it with
   T3's wall-script work, one decision carrying that cost.
3. Flywheel note (sampling-artifact law): pre-T2 clip/critique
   baselines are STALE wherever a replay crosses a level-up (varekka/
   burn class) — re-baseline before trusting old critiques there.
4. Cross-machine note: Junior's next hook run re-proves the ACTIVE bank
   on his machine. If HIS suite reds on the canary, that is the
   cross-machine sim-identity signal — SURFACE it, never rebank.
5. Telemetry duck law (house pattern, re-affirmed in C): test ducks
   grow with the World duck-type; never respond_to?-guard telemetry.

## Measurement hygiene

Ritual wording UNWRITTEN · zero sim numbers moved (data/ untouched
across A+B+C; pacing table demanded no retune) · bot logs never
fun-evidence · live save byte-identical.
