# T4 brief — lobber-E per-spell growth (P10, mid/late bloomer) — cut s48, executes s49

Ticket 4 of Progression v1. Spec:
`docs/superpowers/specs/2026-08-22-progression-v1.md` (P10; P5 composition
pin; P7 enemies-never-read-level; P13 determinism surface). Substrate:
T1 extraction (`drafts/_prog-t1-extraction-schema-v2.md`), T2 sim core
(`drafts/_prog-t2-close-20260822.md` — ctor left `spell_growth`
UNTOUCHED by design), T3 presentation (`drafts/_prog-t3-close-20260822.md`
— amendment 2: instrumented-authoring pattern for the new script;
amendment 0's re-author five landed in s47, all staged L5). The
spell-growth TABLE is ratified data shipped inert by T2:
`data/balance/progression.json → spell_growth.lobber.
special_impact_distances {"5": [2,3,4,5], "8": [2,3,4,5,6]}`. T4 wires
it. ZERO new numbers; any feel-driven retune is a later owner-worded
move under measurement hygiene, never this ticket.

Everything below was verified against live code this session (line
numbers at `afd979f`).

## The seam, as it exists today

- `world.rb:1030 launch_volley(attacker, cfg)` builds the impact record
  from `cfg[:impact_distances]` (kit config, combat.json lobber special
  `[2,3,4]`) via `volley_tiles` (1039: pure geometry, `break unless
  map.passable?` truncation) and `leveled_damage` (999: THE pattern —
  `return cfg[:damage] unless attacker.faction == :pack`, else
  `@progression.damage_for(...)`).
- `arc: "volley"` exists on exactly ONE kit in combat.json (lobber,
  line 113). Volley is lobber-exclusive today; the faction guard is
  still owed (P7 stays mechanical, not incidental).
- Impact records ALREADY fold into the netplay digest (world.rb:661,
  `impact.<i>` groups: owner/tiles/frames_left/damage) and are pinned
  by `test/net/state_digest_test.rb` (stages a live impact, asserts the
  group set). Renderer reads them via the `impacts` delegator
  (world.rb:177 → renderer.rb:145 `draw_impacts`: orange bracket +
  growing core per target tile during `delay_frames`). **Longer reach =
  more telegraph brackets on screen = a Rule 2 visual change.**
- `Creature#kit_name` exists (creature.rb:13) — the reader keys on it.
- `Progression.new(config: data["balance/progression"])` (world.rb:105)
  already receives `:spell_growth`; DataStore `symbolize_names: true`
  delivers threshold keys as `:"5"`/`:"8"` symbols (same
  symbol-number-key shape as the coop seats block, world.rb:67).
- `@impacts = []` resets at zone entry (world.rb:1139); `tick_impacts`
  is counted only in `tick_world` so hitstop pauses delayed impacts
  (comment law at 1052-1053).
- world.rb sits at **1795 / 1800** (cap inclusive,
  `test/app/line_caps_test.rb`).

## Decisions

### D1 — where the read happens: `volley_distances` helper in world.rb, beside `leveled_damage`; a `Volleys` extraction rides the ticket as commit A

The hook itself is leveled_damage's law, verbatim shape:

- Progression gains `special_impact_distances_for(kit_name, base:)` —
  it owns the table + floor-match and takes the base as an argument
  (damage_for precedent: Progression never reads combat.json; values
  in, values out; plain object stays plain).
- world.rb gains `volley_distances(attacker, cfg)`: return
  `cfg[:impact_distances]` unless `attacker.faction == :pack`, else the
  Progression reader keyed by `attacker.kit_name`. The faction guard
  lives in World next to leveled_damage so "level growth applies to
  pack only" has ONE home — both level laws sit adjacent at the same
  call site (P5/P7). Rejected alternative: growth inside
  `Creature#action_config` — creatures don't know the pack level (A2:
  the PACK levels; Progression lives on World).
- Distances take NO coop term: spec P10 is full-array replacement, "no
  arithmetic on arrays"; the live coop block touches enemy hp at spawn
  and respawn delay only (world.rb:1244/1716), never pack geometry.
  Composition pin stays: kit base → level growth → coop scalar, and
  distances stop at step 2 by ratified shape.

**Cap arithmetic forces the extraction.** The helper + call-site swap
is ~+5 gross; 1795 + 5 = 1800 = AT the cap. AGENTS.md non-negotiable 1:
a material touch at the cap owes its own extraction (Crossing
precedent, s31) — and eating the last 5 lines would dump the debt on
J-7 (the next ratified world.rb touch, Lane 3). The subsystem T4
touches IS the volley/impact family, so it pays: **`Game::Volleys`
plain object** (`src/game/volleys.rb`) owning records storage,
launch geometry (`volley_tiles` moves in), the delay tick + hit
resolution (callables for foes/blocked/hit-sink — Crossing/
FieldEconomy pattern), `clear!` (zone entry, Transients precedent),
and `digest_groups` (the `impact.<i>` fold moves in, FieldEconomy's
`@field.digest_groups` precedent). World keeps: construction, the
launch call with RESOLVED values (damage via leveled_damage, distances
via volley_distances — Volleys receives values, never kit configs or
progression), the tick call at the EXACT current position in
tick_world (hitstop pause law carried by call order, comment moves
with it), and the frozen delegator `def impacts = @volleys.records`
(renderer + digest-shape consumers untouched — Transients' frozen-API
precedent). Estimated world.rb: −34ish in A, +5 in B → lands ~1766,
headroom restored. Record shape (owner/tiles/frames_left/damage, live
owner reference) is FROZEN — renderer.rb reads `owner.kit[:special]
[:delay_frames]` (line 148) and must not change bytes this ticket.

### D2 — threshold semantics: floor-match, spec-ratified; implementation pins

P10's text already settles semantics ("the active array is the highest
threshold ≤ level; base array below the first threshold") — not
re-litigated. Implementation decisions:

- Ctor parses `spell_growth` ONCE: `config.fetch(:spell_growth)` (hard
  fetch — the key ships in the ratified file; `{}` is legal = no
  growth anywhere). Per kit: `special_impact_distances` hash whose
  symbol keys convert via `Integer(key.to_s)` into a sorted ascending
  array of `[threshold, distances]` pairs, frozen. Reader walks it:
  last pair with threshold ≤ `@level`, else base. Levels 1–4 return
  the base array by construction — byte-for-byte the kit config object
  (identity, not a copy) — which is what makes the below-threshold
  wall proof an md5 no-op (D4).
- Integer-only law: thresholds and every distance must be positive
  Integers (named refusals, kill_xp ctor style). No Float ever enters
  the balance path.
- **Threshold > level_cap refuses NAMED at construction.** A row that
  no reachable level can activate is dead data — a lie waiting for a
  cap retune. Balance-data precedent is refusal (curve/growth/kill_xp
  all refuse malformed shapes); if a future tuning drops the cap below
  8, the tuner deletes or re-keys the row CONSCIOUSLY. (Save data
  clamps+warns because players own saves; authors own balance files.)
- Arrays: non-empty, all positive Integers. Ascending order NOT
  enforced — `volley_tiles` is order-insensitive (`distances.max` +
  `include?`); legislate only what the mechanism needs. Duplicate
  entries are harmless to the geometry (upto iterates distances once).
- Unknown kit in the table (e.g. a typo'd "lober") is caught not by
  the ctor (it can't see combat.json) but by the data-coherence test
  lane (D8/T-5): every spell_growth kit must exist in combat.json and
  carry `special.impact_distances`.

### D3 — visual surface: ONE new wall script `lobber_reach.json`, staged L5, full critic-ON gate; one new global check with the standard escape

The Rule 2 artifact for "reach grew" is a capture showing the grown
telegraph chain + the impact landing at distance 5 — no existing reel
can carry it:

- specials_chain (the only reel with lobber casts, 2×) is unstaged →
  L1 → base array; its JOB in T4 is the negative control (byte-identity
  below threshold, D4). Re-staging it at L5 would repurpose a
  regression reel mid-life and move its baseline for no coverage gain.
- aoe_specials has 4 specials, ZERO lobber (grep-proven this session);
  ends L2 (T3 close) — never crosses 5.
- The five s47 L5-staged reels carry ZERO `special_started` (verified
  against the s47 teed gate logs, table in D4).

So T4 owes a dedicated script — the level_up_beat precedent exactly
(one script per regression surface; ~5 min/script standing sweep price
accepted when the 22nd landed; this is the 23rd). Shape for the s49
executor (authoring details are the pilot's, per T3 amendment 2 —
headless driver → pin frames → delete driver):

- `start.progression {"level": 5, "xp": 0}` (T3-B's param; L5 = the
  first threshold, the one players FEEL first, and the wall's staging
  convention — stat-stability law holds: ΔE(6)=880 unreachable
  in-reel, so pacing retunes can't flip the reel). The "8" row is
  selection logic, not a new code path — unit lanes pin it (D8);
  a second wall script would buy zero code-path coverage at +5
  min/sweep forever.
- Reel: possess the lobber (specials_chain has the swap choreography),
  open straight corridor ≥ 6 passable tiles (truncation law:
  `volley_tiles` breaks at walls — cast in open ground or the chain
  honestly shortens), enemy walked INTO the distance-5 bracket during
  the 40-frame delay (rusher step cadence 16f/tile — cast while it
  approaches ~7 tiles out; pilot tunes by trial). Captures: pre-cast /
  telegraph mid-delay (the 4-bracket chain [2..5] readable, HUD strip
  reading LEVEL 5 in the same frame) / impact frame (hit lands at the
  5th tile) / post. Manifest floors: `special_started` ≥ 1,
  `attack_hit` + `actor_died` per the authored kill.
- New check in `harness/gate_checks.json` (global list, judged on
  every reel — the escape wording carries the scoping, house style):
  id `lobber_reach_reads`, shape: "Where a Lobber volley telegraph is
  present AND the HUD level strip reads 5 or higher: the bracket chain
  spans FOUR contiguous tiles starting two ahead of the caster (not
  the three-tile base chain), and an impact resolves at the farthest
  bracket where a victim stands there. If no volley telegraph appears,
  or the HUD reads below LEVEL 5, pass with why='not exercised by this
  script'." Exact prose is the executor's (must self-scope from
  pixels: the T3 strip makes the level visible in-frame, which is what
  makes this check judgeable at all). Interaction with the five
  L5-staged reels is nil today (no casts) and correct tomorrow: a
  future L5 re-author that adds a lobber cast SHOULD show the grown
  chain; a wall-truncated cast routes around in the script, never
  weakens the check (T3 amendment 3's law).
- `volley_telegraph_distinct` (existing check) keeps judging telegraph
  IDENTITY; the new check judges EXTENT. No existing check text moves.

No strings/locale surface (telegraph is geometry; no new text) — the
human-facing-output gate has nothing to score beyond the vision
critique itself.

### D4 — wall debt: ZERO re-gates owed; the audit, mechanically

Audited this session against the CURRENT baseline logs (the five
`*_s47.log` re-author gates + newest `*_t3-hud.log`/`*_t5.log` for the
rest — `EVENT special_started` lines, attacker field):

| reel | specials | lobber casts | staged level | T4 exposure |
|---|---|---|---|---|
| specials_chain | 6 | **2** | 1 (unstaged) | below threshold → base array → NONE |
| aoe_specials | 4 | 0 | 1, ends L2 | no lobber cast → NONE |
| taunt_anchor | 2 | 0 | 1 | NONE |
| corpse_run · low_quay_run · nest_advance · sustain_run · vat_economy (s47, staged L5) | 0 each | 0 | 5 | no cast → NONE |
| other 14 (incl. varekka/burn/world_loop/level_up_beat) | 0 | 0 | 1–2 | NONE |

The spark's worry ("lobber-E growth at L5 CHANGES footprints in any
reel where the lobber casts") is real but EMPTY today: no reel casts a
lobber special at L5+. That is luck of the reels, so the ticket
converts it into proof, not assumption:

- **Negative controls (both commits):** double-capture md5 on
  `specials_chain` (lobber casts at L1 — proves below-threshold
  identity through the REAL volley path) + `world_loop` (the standing
  identity canary). SKIP_CRITIC lawful — the claim is byte identity
  (T1/commit-B precedent), not a visual pass.
- **Sim-identity canary bank:** ACTIVE md5s cover world_loop (L1) /
  varekka (L2) / burn (L2) — none reaches L5, none casts volleys
  (table above) → streams byte-identical by construction. **No
  versioned-bank protocol fires.** A canary red in s49 = a DEFECT in
  the extraction or the hook — fix, never rebank (T2 owner-decision
  law).
- **Netplay reels** (`harness/net/`): worlds start L1, growth
  unreachable; but commit A refactors the digest FOLD (impact groups
  move into `Volleys#digest_groups`) — so the **netplay session gate
  runs once at commit A** (two real Worlds over loopback = the live
  digest-identity oracle; suite's state_digest impact pins cover the
  byte form, the gate proves it end-to-end). Desync/conn_lost reels:
  not owed (no wire shape change; DIGEST_VERSION does not move — D7).
- Flywheel note (sampling-artifact law, T2-close amendment 3 family):
  clip/critique baselines stay valid — no current clip crosses L5
  with a lobber cast; the note travels so a future L5-staged clip
  isn't judged against a base-reach memory.

Net wall growth: 22 → 23 scripts. Re-gate list: **empty**. Identity
list: specials_chain + world_loop ×2 commits + netplay session ×1.

### D5 — telemetry: NO new field; reach is proven by artifacts, not the oracle line

The `TELEMETRY progression level= xp= kills_xp=` line is P12's ritual
Half-A oracle — its wording freezes at ritual staging, and the ritual
measures pacing/difficulty/respawn/sustain, not reach. A
`spell_growth=` field would carry ZERO information: active distances
are a pure function of level (already on the line) + the data file
(already under the netplay fingerprint, which hashes `data/**` —
fingerprint.rb law). Adding derived fields to a
soon-frozen oracle is churn against measurement hygiene with no new
byte of evidence. Reach evidence lives where Rule 2 puts it: gate
captures (telegraph chain + impact frame), EVENT rows
(special_started/attack_hit/actor_died in the reel log), digest impact
tiles (netplay), and the unit lanes. The soak `chain_check` regexes
stay untouched (T2's additive-only law not even exercised — nothing is
added).

### D6 — `requires_level`: OUT of T4

P9 is T5's entire body by the spec's own ticket cut: tile_map
load-time validation + crossing fact-gate + shut-way refusal cue +
fixture zone — different files (tile_map.rb, crossing.rb), its own
visual surface (cue = own script + full gate), its own session-sized
gate ladder. T4 and T5 share only the ratified data file and are
orderable independently after T2 (spec sequencing note; T5's fixture
primitive — the `progression` start param — shipped in T3-B, not
here). Bundling would double the gate surface of one session for zero
coupling gain. T4 ships volley growth ONLY.

### D7 — determinism/netplay: no DIGEST_VERSION bump, no handshake change

- Growth reads level + static data inside `World#tick` paths —
  lockstep-safe by construction (P13 pattern, same as leveled_damage).
- Digest byte FORM is unchanged: same `impact.<i>` groups, same rows;
  only VALUES differ when an L5+ lobber volley is live (more tiles in
  the tiles row). Values-only conditional change on a v2 digest = no
  version bump (the version law tracks byte FORM).
- Cross-seat data divergence (one seat edits progression.json) refuses
  at handshake TODAY — the sim fingerprint hashes `data/**`
  EOL-normalized. No new law owed.
- Save schema untouched: distances are derived, nothing new persists.
  Junior's L8 solo save simply reads the "8" row on his next launch
  (see owner-visible notes).

## Commit cut (one ticket, two one-concern commits — T2's A/B shape)

**A `refactor(world)` — Volleys carve, invisible by construction.**
`src/game/volleys.rb` (new: records, launch geometry, delay tick with
injected callables, clear!, digest_groups) · world.rb (launch_volley/
volley_tiles/tick_impacts/digest-fold OUT; ctor line, zone-entry
`clear!`, tick call at the exact current position, frozen `impacts`
delegator IN) · `test/game/volleys_test.rb` (unit: geometry truncation
at impassable, delay/tick law, record shape, clear!) · renderer.rb
UNTOUCHED (byte-frozen). Verify at A: suite via hook (state_digest
impact pins green) · double-capture md5 specials_chain + world_loop
(byte-identical, SKIP_CRITIC lawful) · netplay session gate (full) ·
world.rb line count DOWN (~1766-ish) + line_caps green · live save
md5 untouched.

**B `feat(progression)` — the P10 hook.**
progression.rb (ctor: spell_growth parse/validate/freeze per D2;
reader `special_impact_distances_for`) · world.rb (`volley_distances`
helper beside leveled_damage + launch call-site swap, ~+5) · test
lanes (D8) · `harness/scripts/lobber_reach.json` +
`lobber_reach_reads` check in gate_checks.json (D3). Verify at B:
suite via hook · progression unit + integration lanes green ·
double-capture md5 specials_chain + world_loop AGAIN (below-threshold
identity through the live hook) · **full critic-ON gate on
lobber_reach.json + manifest** · canary bank green (D4) · live save
md5 untouched · `data/**` diff EMPTY (git diff proves zero data
moves).

Fresh-eyes review (Rule 6) at close — scrubbed headless session over
diff + this brief + spec, read-only, "touch NOTHING including seat
mail" in the prompt (s46 lesson).

## Test debt (cut into B unless marked A)

1. (A) Volleys unit: truncation at walls, tile order fixed, delay
   decrement under the tick call, resolution + rejection, clear!,
   record shape frozen, digest_groups byte shape.
2. Progression unit — reader: L1..4 → base identity (same object),
   L5..7 → "5" row, L8..cap → "8" row, kit absent from table → base,
   empty spell_growth → base, cap interaction (L10 reads "8").
3. Progression unit — refusals NAMED: non-integer threshold key
   (`:"x"`), threshold 0/negative, threshold > level_cap, empty
   distances array, non-Integer/negative distance, non-Hash shapes.
4. Integration (progression_integration precedent, real sim): pack
   lobber at staged L5 launches a volley whose record tiles reach
   distance 5; at L1 tiles match base; enemy volley reads base at pack
   L5 IF a cheap honest seam exists (no enemy volley kit ships —
   construct via test kit data if the harness allows; otherwise the
   faction guard is covered by the world helper's unit-visible branch
   + specials_chain identity, and the lane is recorded as waived, not
   mocked).
5. Data coherence (progression_data precedent): every spell_growth kit
   exists in combat.json and carries `special.impact_distances`; every
   threshold ≤ level_cap (belt for the ctor law).
6. Line caps: world.rb strictly below 1795 post-A (assert the carve
   paid, not just ≤ 1800 — the suite cap stays 1800; the NUMBER lands
   in the close draft).

## Session budget + stop conditions (s49)

One session: 2 commits, ~6 lanes, 1 authored script (pilot +
throwaway driver), gates = 2×2 identity md5 pairs + 1 netplay session
+ 1 full critic gate + manifest. Council 0 (ratified design, shaping
executed). Sub-agents: the Rule 6 reviewer only. Stop EARLY on:
Job-0 defect-class delta · specials_chain md5 moving at EITHER commit
(that is the below-threshold law breaking — defect, stop, do not
rebaseline) · canary red · world.rb refusing to fit under 1795 post-A
(extraction shape wrong — stop and re-cut, don't shave) · owner
redirect.

## Owner-visible notes (for the peers, never nag)

- **Junior first-exposure flag:** his solo save is L8 — his next
  launch after T4 ships reads the "8" row: lobber E reaches SIX tiles
  (base 4). That is the mid/late-bloomer payoff landing as designed
  (owner's es-CR extension, ratified); it is also NORMAL exposure for
  fun-verify purposes (novelty quarantine wants first exposure OUTSIDE
  ritual sessions — this does that for his seat organically). Worth a
  one-line hub-chat heads-up at ship so the reach jump reads as
  feature, not bug.
- The FEEL claim (mid/late bloomer) is only provable in play; T4 ships
  the mechanism + Rule 2 legibility proof. The feel verdict belongs to
  the humans' sessions and, if it matters, the ritual's free verdict —
  no wording owed now (measurement hygiene).
- Shared save `98fe75ed…` (both L1 crossings pending) is untouched by
  T4; the pack reaches the thresholds by playing.

## Scope fence

Zero `data/**` moves (the table is ratified and already shipped; git
diff must prove emptiness) · renderer.rb byte-frozen · no strings/
locale keys · no TELEMETRY/soak-regex change · no save-schema touch ·
window.rb untouched · ritual wording UNWRITTEN · live save md5
before/mid/after · one-concern commits · the s45 brief-writer
precedent held: this session wrote ZERO code.
