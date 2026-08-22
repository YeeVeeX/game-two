# T2 brief — sim core: XP-on-kill → level → stats live (cut s42, lands s43)

Ticket 2 of Progression v1. Spec:
`docs/superpowers/specs/2026-08-22-progression-v1.md` (P2/P4/P5/P11/
P12/P13 + P14's cap law). Binding amendments: T1 close draft
`drafts/_prog-t1-close-20260822.md` §T2-amendments (all five folded in
below). Brief-writer (s42) never implements; the implementing session
reads spec + this brief + every named file region before editing
(read-before-edit is mechanical).

**One session, three commits, in this order:**

- **Commit A** — `fix(save): T1 review NITs — bak_hint mtime pick, @v1_raw hygiene`
- **Commit B** — `refactor(world): carve Transients (cosmetic records) — cap headroom for T2`
- **Commit C** — `feat(progression): T2 sim core — kill XP, level-up stats, digest v2, telemetry`

P13 law: digest rows + DIGEST_VERSION 1→2 + the award hook land in ONE
commit (C). The carve is a SEPARATE commit so byte-identity is provable
while behavior is still identical. An optional Commit D (starter-number
retune) exists ONLY if the pacing table demands it — table pasted into
its commit message (P11).

## Scope fence

- **NO visual surface.** HUD strip, level-up banner/pop (the P4 feel
  beat) are T3. `:level_up` is emitted with ZERO subscribers in T2.
- **NO spell growth** (T4): `spell_growth` in progression.json stays
  parse-pinned, unvalidated, unread (amendment 3 covers only what T2
  reads: `growth` + `kill_xp`).
- **NO `requires_level`** (T5). **NO persist-line change**: the
  `TELEMETRY persist` vocabulary and soak `chain_check.rb` regexes are
  frozen — level rides the NEW telemetry line only (P12).
- **Sim numbers are unfrozen starters** until the ritual stages
  (measurement hygiene); they move only via the pacing table.
- Live save `saves/world.json` (`98fe75edb6d72deab18cd48eaa88bdaf`,
  341 B) is the owners' progress — fixtures/copies only, never launch a
  save-owning seat. md5 before/after the session must match.

## Commit A — T1 review NITs (src/app/save_store.rb + save_store_test)

1. **bak_hint** (`save_store.rb` `def bak_hint`, bottom of file):
   `Dir["#{@path}.bak-*"].max` is lexicographic, so
   `.bak-schema1-<ts>` sorts above every date-stamped `.bak-<ts>`
   (`'s' > '2'`) and the corrupted-save recovery hint names the wrong
   "newest" backup. Fix: pick by mtime —
   `Dir["#{@path}.bak-*"].max_by { |f| File.mtime(f) }`. Wording
   unchanged.
2. **@v1_raw hygiene** (`def load`): set once in the `schema == 1`
   branch, never cleared on a later v2 load through the same store →
   a stale backup fires holding genuine v1 bytes (redundant, never
   loss). Fix: clear `@v1_raw = nil` at the top of `load` (before the
   Fresh return), so only the CURRENT file's schema decides.
3. Tests (`test/app/save_store_test.rb`): (a) hint names the
   mtime-newest backup even when a `.bak-schema1-*` name sorts higher;
   (b) v1 load → v2 reload → write produces ZERO schema1 backups.
4. Amendment 5 (loaded-line `schema=2` on a not-yet-rewritten v1 file)
   is RECORDED, no code — revisit wording only if a human trips.

## Commit B — Transients carve (the P14/cap law: world.rb is AT 1797/1800)

Commit C adds ~+13 net lines to world.rb; the cap law ("any material
touch at the cap owes its own extraction into a plain object") assigns
this carve. Extract the **cosmetic transient records** — the three
digest-EXCLUDED, renderer-read arrays — into
`src/game/transients.rb` (`Game::Transients`, plain object, no bus, no
IO; Crossing/FieldEconomy pattern).

Owns (world.rb line refs, current build `c33c17f`):

- `@taunt_pulses` / `@kill_pops` / `@seal_marks` storage (:105-107),
  zone-entry reset (:1148-1150 → one `clear!`).
- Push verbs: `taunt_pulse!(tile:, pulse_frames:, range_tiles:)`
  (from :982-983), `kill_pop!(tile:, frame:)` (from :1615-1617 — the
  phase formula `(x*31 + y*17 + frame) % 997` and `pop_frames` config
  move in verbatim; construct with
  `pop_frames: @balance[:feel][:pop_frames]`, freeing :108),
  `seal_mark!(at:, frames:)` (from `mark_seal!` :899-901).
- **Two aging verbs — the pause laws differ and must survive:**
  `tick_combat!` (pulses + pops; called from tick_world :722-723,
  paused by hitstop AND the wipe veil) and `tick_banner_clock!`
  (seal marks; called from the non-hitstop banner branch :278-279 —
  hitstop skips it, veil does not). Carry both laws as comments.
- World keeps delegator readers `taunt_pulses`/`kill_pops`/
  `seal_marks` (:194-196) — the renderer API is FROZEN, renderer
  untouched.

Delete `tick_taunt_pulses`/`tick_kill_pops` (:986-998 incl. comments).
Digest: these records were never digested (cosmetic law) — nothing
moves in the snapshot. New unit test `test/game/transients_test.rb`
(aging to zero + rejection, clear!, phase determinism, pop_frames from
config). Existing `kill_pop_test` / `seal_mark_test` / `taunt_test`
stay green through the world API.

**Verify (blocking, before Commit C starts):** old-vs-new byte
identity — worktree at the pre-carve commit vs new build,
`rake capture` on `harness/scripts/world_loop.json` AND
`harness/scripts/varekka_duel.json` (both exercise pops/stamps/pulses),
md5 sets IDENTICAL (T1 close's OLD_VS_NEW pattern). SKIP_CRITIC lawful
here: the claim is byte-identity, not a visual pass. Expected line
count after carve: ~1775-1780 (hard gate stays ≤1800 via
line_caps_test; target ≤1795 AFTER Commit C).

## Commit C — sim core

### 1. Progression (src/game/progression.rb — no line cap)

Constructor additions (T1 validated only `:curve`; same Integer-forced
named-refusal style):

- `growth = config.fetch(:growth)` → `@dmg_growth_pct`,
  `@hp_growth_pct`: Integers >= 0, else named refusal.
- `@kill_xp = config.fetch(:kill_xp)`: every value a POSITIVE Integer,
  else named refusal (keys are Symbols — DataStore
  `symbolize_names: true`; Creature `kit_name` is a Symbol at both
  construction sites, world.rb :1249/:1264 — types align by
  construction).
- `spell_growth`: NOT read, NOT validated (T4).

New API:

```ruby
attr_reader :kills_xp   # XP EARNED this session (pre-cap-pin amounts;
                        # init 0, never persisted, never digested — P12)
def damage_for(base) = base + (base * (@level - 1) * @dmg_growth_pct) / 100
def max_hp_for(base)  = base + (base * (@level - 1) * @hp_growth_pct) / 100
def award_kill(kit_name)          # P2/P14 wrapper around pure award
  amount = @kill_xp.fetch(kit_name) { raise ArgumentError, "no kill_xp for kit #{kit_name.inspect} in data/balance/progression.json" }
  @kills_xp += amount             # earned semantics: counts even when award pins at cap
  award(amount)
end
```

Integer division IS the law (coop-scalar precedent, world.rb:61-64: no
Float ever enters the balance path). Level 1 = identity (`(L-1) = 0`)
— a fresh session computes kit-base numbers exactly.

### 2. World award hook (src/game/world.rb :1619 region, the actor_died handler)

Inside the existing `if e[:faction] == :human` branch (single
actor_died emit site is creature.rb:233 — payload actor/killer/faction;
killer is always a Creature):

```ruby
# P2: ANY pack-member kill feeds the pack (A2) — possessed or ally.
if e[:killer]&.faction == :pack &&
   @progression.award_kill(e[:actor].kit_name) == :level_up
  @pack.sync_max_hp!(progression: @progression) # P4: hp gains the delta
  @bus.emit(:level_up, level: @progression.level)
end
```

- Runs inside `@bus.process` inside `World#tick` → lockstep-safe by
  construction (P13); nested emit is legal (FIFO same-flush append).
- Register `:level_up` by appending to an existing `EVENTS` line
  (world.rb :29-39) — payload `{level: Integer}` serializes clean
  through EventSerial and folds into the digest lines on both seats
  (desired: level-ups are sim truth). Zero subscribers in T2.
- Challenger death feeds XP (kill_xp 120) alongside
  `record_boss_1_defeat!` — both fire.

### 3. Damage growth at the three resolution sites (world.rb)

New private helper (P5 order pin as comment: kit base → level growth
(Integer) → coop scalar — today NO coop scalar touches pack damage/hp
(coop.json is enemy-side: human_hp_scale/respawn_delay_scale/
ally_flee_hp_pct), so composition is structural, not live; enemies
read NO level term, P7):

```ruby
def leveled_damage(attacker, cfg)
  return cfg[:damage] unless attacker.faction == :pack
  @progression.damage_for(cfg[:damage])
end
```

Swap `cfg[:damage]` → `leveled_damage(attacker, cfg)` at exactly:
`apply_action_hit` (:1014), `launch_projectile` (:1031),
`launch_volley` (:1044). Stored damage on in-flight projectiles/
impacts (:1070/:1090) stays launch-time — a level-up mid-flight does
not retro-buff; deterministic, pin as comment. Covers attack AND
special (both read `action_config`).

### 4. Max-hp growth (pack.rb + creature.rb — no caps; pack 146, creature 516 lines)

- `Creature#grow_max_hp!(delta)` (beside `scale_max_hp!`, :391):
  `@max_hp += delta`; living flesh gains the delta
  (`@hp = (@hp + delta).clamp(1, @max_hp)` unless dead) — dead flesh
  keeps hp 0 and revives into the new ceiling (revive!/heal_full!
  already read `@max_hp`). No full heal — P4 (free sustain would fight
  D1b + the B4 lane). The clamp floor makes a negative delta (growth
  retune between sessions) unable to kill — the save-robustness law.
- `Pack#sync_max_hp!(progression:)`: for each member,
  `m.grow_max_hp!(progression.max_hp_for(m.kit[:max_hp]) - m.max_hp)`
  — idempotent re-sync to the current level; handles multi-level
  awards (delta computed from live max); kit bases stay in combat.json
  untouched (P5).
- Invariant this preserves: pack `@max_hp` is ALWAYS
  `max_hp_for(kit base)` at the current level — construction is
  level-1 identity, the only other mutator is this verb.
  `scale_max_hp!` remains humans-only (add_human :1254).

### 5. Save-apply order (src/game/save_state.rb — apply!, :270-344)

Progression facts currently load LAST; member hp clamps at the TOP
against un-leveled max → a legitimate level-5 save would false-clamp.
Reorder apply! to: **home → counters + progression (clamp level→cap,
xp→ΔE(level+1)−1, `load_progress!`) → `world.pack.sync_max_hp!` →
members (hp clamp now against LEVELED max) → banked/provisions →
seats → breaches.** Update the decision-4 pinned-order comment (file
header) with the amendment + why (the P3 churn law needs the real
ceiling before hp clamps). Projector untouched — `project_members`
reads live `m.max_hp` (already leveled), so v2 round trips stay
byte-stable at any level.

### 6. Digest v2 (world.rb :654 + src/net/state_digest.rb :20 — SAME COMMIT as the hook)

- `digest_snapshot` world_fields gains
  `["level", @progression.level], ["xp", @progression.xp]` beside the
  boss_1_defeats/sessions row (P13 pins these exact rows).
- `DIGEST_VERSION = 1` → `2`. Handshake refusal already names the
  field (fingerprint.rb LABELS `digest version`; HELLO builds from the
  live constant) — no fingerprint code change. Test fixtures
  hardcoding `digest_version: 1` (7 files) are seat-vs-seat consistent
  fakes — expected untouched; fingerprint_test:93 asserts the live
  constant. Confirm with the suite, not by editing fixtures.
- `test/net/state_digest_test.rb`: pinned world-field list (:21) gains
  `level xp`; mutation-sensitivity sweep gains progression mutations
  (`world.progression.load_progress!(level: 2, xp: 5)` flips the
  canonical form).

### 7. Telemetry (src/game/telemetry.rb — P12)

`summary` (:300-317) gains a final line via `progression_summary`:

```
TELEMETRY progression level=%d xp=%d kills_xp=%d
```

Read `@world.progression` (level/xp/kills_xp); no-world fallback = all
zeros (the established `@world ? x : 0` pattern — level=0 is an honest
impossible value). Prints at window close in BOTH solo and netplay
paths (window.rb :194 `puts @telemetry.summary`) — the ritual's
"kill-XP earned > 0" proof reads it from human launcher logs.
`telemetry_test` summary-shape pins updated. Soak `chain_check.rb`
greps only its own patterns — additive line is safe (verified: NETPLAY/
PERSIST/FIGHTS regexes only).

### 8. Data test (new test/game/progression_data_test.rb)

Every kit named in any `data/zones/*.json` `enemy_spawns` has a
`kill_xp` row (today: rusher, rusher_hater, challenger — all covered;
husk spawns nowhere yet but its row is lawful). A future WB kit
without a row fails the SUITE, not the owners' session; the
`award_kill` named fetch is the belt-and-braces runtime refusal.

### 9. Pacing script (P11 — tmp/, NOT shipped, NOT committed)

~20 lines reading `data/balance/progression.json`: per level 2..cap —
ΔE(L), cumulative XP, on-level kills-to-level per kit
(`ceil(ΔE / kill_xp)`), hours-per-level under a DECLARED kills/hour
assumption (parameter; derive the default from the newest human
launcher logs' kill counts if trivially greppable, else declare e.g.
60/h in the table header). Targets (spec): single-digit kills to
level 2; tens by mid-cap. Paste the full table into the T2 close
draft; starters move only via Commit D with the table in its message.
Sanity rows for the starter constants: ΔE(2)=80 → 6 rusher kills or
10 husk; challenger alone (120) = level 2 + 40 spill.

## Verify (s43, in order — silent-on-pass, verbose-on-fail)

1. Hooks run `bundle exec rake` per commit (baseline 1045 runs / 0F —
   grows with new lanes). Never `--no-verify`.
2. Commit B gate: OLD_VS_NEW byte identity, world_loop + varekka_duel
   (pattern above) — blocking before C.
3. After C: `rake gate SCRIPT=harness/scripts/world_loop.json` and
   `SCRIPT=harness/scripts/varekka_duel.json` — FULL gate, critic ON
   (kill-timing/stat changes move frames legitimately; the gate is
   within-build double-replay + vision, so it proves determinism +
   presentation sanity, not old-frame equality). Run DETACHED
   (~5 min/script; never under a bash-call timeout — project memory).
4. Netplay gates, all three:
   `rake gate SCRIPT=harness/net/netplay_{session,desync,conn_lost}.json
   CHECKS=harness/net/gate_checks.json` — digest v2 on the wire both
   seats; desync scene still convicts; version field named on refusal
   stays suite-proven. Detached, sequential.
5. `rake perf` — p95 tick < 16.6 ms (damage_for is per-hit; max_hp_for
   is level-up/apply-time only).
6. `wc -l src/game/world.rb` ≤ 1795 target (≤1800 hard).
7. Live-save hygiene: `md5sum saves/world.json` unchanged
   (`98fe75ed…`); no launcher run from this seat.
8. Fresh-eyes review (Rule 6): headless scrubbed pi over diff bundle +
   this brief + spec — read-only, **touch NOTHING including seat
   mail** (s41 lesson); verdict + nits into the close draft.
9. Close draft `drafts/_prog-t2-close-<date>.md` (verify outputs +
   pacing table + any new amendments for T3), checkpoint entry, s44
   spark. Push.

New-test expectations (name-level): progression_test (award_kill
table/refusal/kills_xp-at-cap, damage_for/max_hp_for identity +
truncation rows), creature grow_max_hp! (living delta / dead ceiling /
clamp floor), pack sync_max_hp! (multi-level, idempotent),
world-level kill→XP→level_up integration (drive via load_progress! to
a boundary, one kill, assert event + stats + digest flip), save-apply
reorder lane (level-5 hp round trip clamp-free; lowered-growth clamp
warns), transients unit, data coverage, telemetry line, save_store
NITs.

## Done condition

All nine verifies green; three (or four) commits pushed; no visual
surface moved (T3 owes the HUD + feel beat and will consume
`:level_up` + `kills_xp`); T3/T4/T5 unblocked with zero re-derivation
(this brief + close draft carry the state). Recorded risk for the
flywheel program: pre-T2 clip/critique baselines are stale where
replays cross a level-up boundary (sampling-artifact law applies) — a
note in the close draft, no T2 action.

## Budget + stop

One session. Council 0 (design pinned by ratified spec + this brief).
Sub-agents: the Rule 6 reviewer only. If context tightens: land
committed work honestly (A and B are independently shippable), stop
before C rather than half-ship the P13 one-commit set; genuine scope
break or spec contradiction → stop and surface, never invent.
