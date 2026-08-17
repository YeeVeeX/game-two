# v18 — THE PERSISTENT WORLD CYCLE, etapa 1: persistence v1 + coop feel + god-view v0

Date: 2026-08-17. Cycle ratified by the owner 2026-08-17 ("yes approved") on
the foundation `drafts/_v18-foundation-20260817.md`; forks F1–F7 closed this
session per the v13 precedent (dev recommendation + owner veto). F2/F5/F6/F7
are dev calls, defended below. F1/F3/F4 are owner-level: recommendations
recorded and PROCEEDED ON per the absent-owner clause; the owner's veto
window stays open until TDD opens — a veto amends this spec, not the code.
Working language: English. Player-facing text: placeholders + functional
dictionary words only (standing order 2026-08-16). Brainstorm record:
`drafts/_v18-brainstorm-20260817.md`. Review ledger:
`drafts/_v18-spec-review.md` (Codex REJECT → 21 findings, 20 confirmed +
folded; panel: DeepSeek/Kimi/Qwen-Coder — 9 folds, 2 refutations with
source evidence; all folds marked inline below).

**Oracle (the SEVENTEENTH ask, two halves):** (A) PERSISTED — two real
owner+Junior sessions on DIFFERENT days; session 2 provably resumes the same
world (save digest chain + zero desyncs across both sessions + a carried
fact in telemetry). (B) FELT — both players asked separately: did the world
feel CONTINUED (yours, accreting)? did each seat's named Q3 friction
disappear (owner: respawn walk-back + sustain; Junior: difficulty + AI
third-body suicides)? Free verdict. Protocol pre-registered in §Fun-verify.

## Foundations (banked facts this design stands on)

- Sim deterministic + tick-locked; `World#digest_snapshot` already
  enumerates every gameplay-affecting scalar with stable ids — the digest
  lane pre-built the persistence vocabulary. `StateDigest` windows every 60
  ticks; a divergence fails loudly with a two-seat artifact.
- Seeding TODAY (Codex fold #10): netplay hosts pick a fresh seed per
  session (`Random.new_seed & 0xffff_ffff`, src/main.rb) but the SOLO path
  constructs `World.new(data)` = fixed seed 0 (src/app/window.rb) — every
  solo session replays the same field. v18 fixes this: solo launches
  generate a per-session seed too ("field re-seeds, facts persist" becomes
  true on every path; two-launch regression test).
- Handshake phases LISTEN→HELLO→PROBE→SESSION→READY→RUN→END with per-phase
  ALLOWED tables; HELLO refusals NAME the differing field (fingerprint law,
  EOL-normalized per `10b6138`). SESSION carries session_id/seed/d/
  digest_every — the save rides here. BYE refusal plumbing currently
  carries detail ONLY for reason="fingerprint" (session.rb:357) — extended
  by decision 6.
- Wire cap `Protocol::MAX_LINE_BYTES = 4096`. INPUT masks are a pinned
  10-bit order; changing the mask = protocol version bump (pinned law).
- Shelf verdicts (VERIFIED): Tibia = world resets, character persists;
  player presence at spawn blocks respawn (we carry
  `respawn_block_tiles: 12`); consumables ≈30% of currency removal,
  elastic (the sinks-faucets posture for F3's inflation valve).
- SIXTEENTH telemetry (owner seat, ~25 sim-min two-seat):
  `banked_spent{inscribe=80 tribute=238}` (maintenance spend dominates 3:1 —
  the bank-run friction is measured), `banks{n=15 mean=34 max=133}`, bank
  gap `mean_s=57`, wipes=3/25min two-seat vs 2/9min solo (per-minute wipe
  rate ~halved in coop). Owner Q3 verbatim + Junior's two signals: the
  coop-feel lane's evidence base.

## Fork verdicts (closed 2026-08-17)

**RATIFIED by the owner 2026-08-17 ("en general todo ok") with two
riders, both routed to PARKING_LOT §"Owner ratification riders" — NOT
v18 scope growth:** (1) equipped/carried persistence via a
Tibia/RavenDawn-style backpack → the ITEM CYCLE, now v19 lead candidate
(carried-persistence inside v18 stays rejected — the Codex #1 exploit;
the real fix is position persistence + logout rules, which belong WITH
the item cycle); (2) "the server should live on AWS, not my machine" →
the staged AWS path (S3 backup → cloud custody → server-authoritative),
trigger recorded HALF-FIRED. The SEVENTEENTH still gates everything new.

- **F1 What persists (owner-level, recommendation):** pack economy
  (banked, provisions) + per-member character (kit, exact hp — alive is
  DERIVED as hp > 0, never stored; inscribed flag) + world arc (breached
  seals, home_zone, cumulative counters boss_1_defeats/sessions).
  **Carried does NOT persist** (Codex fold #1: persisting carried while
  every load starts at home would make quit a risk-free loot teleport —
  the corpse-run tension deleted by a menu). The save ritual is exact:
  **value survives a session ONLY as banked value.** Field state does NOT
  persist (humans, drops, corpse loads, respawn queues, projectiles,
  possession, mark, presentation); BOSS 1 respawns every session — the
  fight is repeatable, the defeat accrues as a counter. Recorded edges:
  dead flesh stays dead across sessions (the vat fee carries over — the
  death economy continues, it doesn't reset; the mercy-floor watch in
  §Fun-verify routing carries the panel's chore-tax worry); and quit
  destroys NO value that would otherwise have survived — field value is
  ALREADY transient in-session (corpses expire in ~90s,
  `corpse_term_frames: 5400`), so the session boundary only meets the
  existing decay law, it does not add a harsher one (panel Kimi-Q1
  defense).
- **F2 Save custody (dev call):** ONE host-authoritative machine-local
  file `saves/world.json` (gitignored); transferred to the joiner inside
  SESSION; the joiner NEVER persists the shared world. Rejected:
  git-tracked saves (conflicts, save-scumming, pull friction), per-seat
  saves (drift mine).
- **F3 Banked persists (owner-level, recommendation): YES.** D0's
  "session-only" was explicitly "a save system with no fun-thesis need" —
  the owner ask is that thesis arriving. Inscription semantics now cross
  sessions (a mark bought today armors tomorrow's wipe). Inflation valve =
  F6 (elastic consumable sink); watch metric pre-registered in §Fun-verify.
- **F4 Solo advances the shared world (owner-level, recommendation): YES,
  with custody honesty.** The shared world lives on the owner's machine; it
  advances when the owner plays (solo or hosting) or when Junior JOINS him.
  Junior solo on his own machine = his own separate local world — merging
  divergent world lines is the always-online architecture's domain (parked,
  named trigger). Alternative if vetoed: coop-only persistence (thinner).
- **F5 Coop pacing (dev call):** per-seat-count scalar block in
  `data/balance/coop.json`; seats=1 = no block = NO arithmetic at all
  (decision 11). Knobs: `respawn_delay_scale` (walk-back time, owner Q3a),
  `human_hp_scale` (difficulty, Junior's signal), `ally_flee_hp_pct`
  (third-body caution, seat-gated). Density scaling rejected for v1
  (perf + chaos + respawn interactions; hp is the smallest honest knob).
- **F6 Sustain verb (dev call, owner law 2026-08-11 binding):**
  PROVISIONS — field charges bought at the bank station for banked value,
  carried as a pack counter (cap), consumed anywhere via a new verb for a
  pack-wide heal pulse. Never free, never regenerating, no drops. The
  healer-fairy kernel folded exactly as the parked entry prescribes: a
  priced, portable bank-sink. Rejected: channel-drain (banked is visible
  at the station only — D0 choice kept), free cooldown (design regression
  by law).
- **F7 God-view v0 (dev call):** strictly offline — `rake map` renders the
  whole world from data+save into one PNG. Zero sim/netplay surface.
  In-game map/teleport/editing promote only via a future debate (owner
  vision routing stands).

## Design decisions (numbered; the laws reviews should attack)

1. **Save vocabulary = FACTS, not snapshot; facts/envelope split (Codex
   folds #1 #2 #9; panel folds DS-Q3/QW-Q3 — the canonicalizer is OURS
   and pinned; Ruby's JSON.generate does not sort).** `facts` is the pure, digested, idempotent state:
   `{banked, provisions, home_zone, breached: [[zone,[x,y]]...sorted],
   members: [{kit, hp, inscribed}... roster order], counters:
   {boss_1_defeats, sessions}}`. The FILE wraps it in an envelope:
   `{schema: 1, saved_at_ms, facts}` — envelope metadata is NEVER
   digested. Canonical bytes = OUR pinned canonicalizer over `facts`
   alone: recursive key sort, pinned separators, leaves
   Integer/String/Boolean only, strings ASCII-only — a float or
   non-ASCII string anywhere = encoder RAISE (the digest leaf-type law
   applied to saves). `alive` is derived
   (hp > 0), never stored — contradictions unrepresentable. Nothing
   enters `facts` without a schema bump.
2. **Session-boundary IO law + save gating (Codex fold #11; panel DS-Q4
   adjudicated against source).** Load happens at World construction
   (`World.new(..., save: facts)`); save happens through ONE idempotent
   coordinator that writes IFF the seat owns the save (solo player, or
   netplay HOST) AND the session ended clean (`reason=:quit` / solo
   Esc). **Either seat's clean Esc lands `reason=:quit` on BOTH seats**
   (BYE{quit} concludes :quit on the receiving seat — session.rb
   BYE_REASONS, verified), so the host saves whichever seat quits
   first; the joiner-initiated-quit save lane is tested. Desync,
   conn_lost, protocol fault, refusal, or a crash mid-run write NOTHING — a diverged world is
   suspect state and must never poison the save. Repeated close
   callbacks write once. No mid-tick IO anywhere; the 16.6ms p95 budget
   is untouched by construction.
3. **Save-boundary projector (Codex fold #4 — replaces the "enter_zone
   normalization" claim, which was FALSE: enter_zone clears
   seizures/chants/field records but NOT stagger/iframes/exhaust/action
   state, and a quit during the wipe veil has zero living members).**
   `SaveState.serialize` runs an explicit projector: (a) if a wipe is
   pending (respawn veil in flight), judgment RESOLVES FIRST through the
   live rules — inscription consumption, dissolution, one-vessel floor —
   exactly what the veil's end would do; (b) per-member transients zero:
   stagger, iframes, hurt_frames, exhaust, special_exhaust,
   dodge_cooldown, action/attack-state/state_frames/action_triggered,
   hit_victims, dash_plan, seized_by/seized_frames, chant state,
   seize_cooldown, focus; (c) field records drop (projectiles, impacts,
   drops, corpse loads, respawn queues); (d) carried value does NOT fold
   anywhere (F1 — bank it or lose it). After the projector, ≥1 living
   member holds by the one-vessel floor (asserted; a violation is a
   surfaced BUG, not a save). A loaded world starts at the `home_zone`
   spawn. Test lane sweeps a quit at EVERY tick of the veil window.
   **The projector is PURE — it never mutates the live world and never
   touches an RNG stream (panel DS-Q2 fold):** post-judgment membership
   is computed from the deterministic judgment rules alone (inscription
   survival, dissolution, the floor); nothing RNG-dependent (positions,
   scatter) is in the facts vocabulary, so no draw is ever needed.
   Tested: serialize twice = identical bytes, and `digest_snapshot`
   before == after serialize.
4. **Apply is construction with PINNED ORDER (Codex folds #5 #6 #20).**
   Facts apply during `World.new` in this order: home_zone set → member
   facts onto the roster (matched by kit, roster order) → pack seat
   pointers assigned over the LIVING set (the judgment floor rule: seat 1
   takes the vessel, seat 2 waits if only one lives) → breached seals
   restored via `restore_breach!` — a new idempotent, side-effect-free
   path (opens the way; NO spend, NO events, NO hitstop/cues/marks; the
   live interact_seal path becomes spend + emit + restore_breach!) →
   initial `enter_zone(home_zone)`. Per-field evolution rules (balance
   churn must not brick saves, corrupt saves must not crash):
   **clamp+log** — hp to the kit's current max_hp, provisions to
   provision_cap; **refuse-named** — schema ≠ SCHEMA, kit set/order ≠
   build roster, home_zone unknown or not a hub-capable start, seal
   tuple not a seal station in that zone's data, any type/range/
   duplicate violation. Test: non-default home + only the third member
   alive → seats land on living flesh at the right spawn.
5. **Digest chain law (oracle Half A's arbiter; Codex fold #3; panel
   QW-Q4 fold — exact bytes on the wire, no re-serialization parity
   assumptions).** The save digest = md5 over canonical FACTS bytes
   (envelope excluded), produced by the pinned canonicalizer (decision
   1). **On the wire the save travels AS the canonical string** (a
   string field, not a nested object): the joiner digests the RECEIVED
   bytes BEFORE parsing — a parse→re-serialize round-trip can never
   enter the verdict. File loads re-canonicalize through the same
   pinned function (identical trees by the fingerprint law). Every
   save-write prints `TELEMETRY persist saved digest=<md5>
   schema=N banked=B provisions=P seals=S marks=M sessions=K`; every
   load prints `TELEMETRY persist loaded digest=<md5> ...
   source=file|handshake`, where the printer RECOMPUTES the md5 from the
   bytes it actually applied — a loaded digest can never be an echo. A
   fresh world prints `source=fresh` with no digest (the chain starts at
   the first `saved` line). Session 2's `loaded` digest == session 1's
   `saved` digest = the chain link, comparable verbatim across seats.
6. **Refusal grammar (fingerprint-law extension; Codex folds #7 #8 #9
   #12).** (a) STRICT DECODER: `SaveState.refusal_for(facts)` validates
   exact keys, Integer types, ranges (hp ≥ 0, counters ≥ 0), no
   duplicate kits/seals, seal tuples against zone data, home_zone
   validity — returns the NAMED refusal or nil; **an unparseable or
   truncated save FILE is itself a NAMED refusal** (never a raw JSON
   crash), with recovery hints (.bak-<ts> if present; an orphan `.tmp`
   newer than the save is named); both load paths run it
   BEFORE any window opens (host/solo at launch; **joiner during the
   pre-window pump** — params carry the facts, validation is pure, a
   refusal prints to console and exits 1, the bindings-error precedent).
   (b) BYE vocabulary grows `save_schema` / `save_digest` /
   `save_invalid`; `handle_bye` records refusal text for ALL refusal
   reasons (not just "fingerprint"), so BOTH seats print the same named
   refusal and exit 1 (`App::Cli.exit_status` law: refusal ⇒ 1; status 2
   stays link-fault-only so the coop launchers never rehost on a
   refusal — RC-matrix test extended). (c) WIRE PREFLIGHT: at host
   start, the ACTUAL encoded SESSION line (`Protocol.encode(:session,
   ...)` with the real canonical save string) must fit
   `wire_budget_bytes` (3072) —
   refuse NAMED at the console before listening; never a mid-handshake
   Oversize fault. (d) Joiner digests the RECEIVED canonical string
   (decision 5); mismatch vs the host's declared digest = BYE
   save_digest.
7. **Wall no-touch by construction, three pins (all structural TESTS;
   Codex folds #14 #15).** (i) Replay/harness/pilot construct with
   `save: nil` and never write — structural test on the harness path;
   (ii) seats=1 → the coop block is NOT READ and no scalar arithmetic
   executes (absent block = early return, so no 300→300.0 Float can
   ever enter the digest; scaled values under seats≥2 are explicitly
   `.round`ed Integers); (iii) provisions=0 renders NOTHING (no counter,
   no strip row). Baseline protocol: BEFORE the first sim-touching
   increment, bank fresh canary baselines for all 17 wall scripts
   (tmp/canary_baseline/, machine-local — the v17 protocol; `rake
   canary` takes SCRIPT+BASELINE per script, swept by the wall runner
   loop), and re-sweep after every sim-touching increment.
8. **Protocol version 2, ONE bump for the cycle (Codex fold #12 rides
   6c).** v2 = 11-bit mask (`ACTIONS + :sustain`) + SESSION gains
   `save_schema`/`save_digest`/`save` (canonical facts, or null for a
   fresh world). The version constant flips in the first netplay
   increment; the suite pins the FINAL v2 vocabulary so a second silent
   bump cannot happen. INPUT stays ≤40B (11 bits fit). Version skew =
   the existing named refusal + git pull hint.
9. **Sustain economy law (Codex fold #16; panel Kimi-Q3 fold).** All
   numbers in `data/balance/economy.json`: `provision_cost: 5`,
   `provision_cap: 3`, `provision_heal: 30` (strawmen; tuning = JSON
   edit, never code; cost lowered 6→5 on the panel's premium-kills-
   experimentation critique — station heal stays several times more
   efficient per banked; the premium buys portability, not parity).
   **Tuning lever order pre-registered:** discoverability (strip
   exposure) → cost → heal — a "sustain unused" verdict walks that
   ladder in order, never re-designs the verb first.
   The verb is EDGE-TRIGGERED (joins `EDGE_TRIGGERED` in controllers +
   the swap-rearm law — a held key buys/uses exactly once). Buy: sustain
   press ON the bank station, spends banked via the existing `spend!`
   path (never-taxed law holds). Use: sustain press anywhere else
   consumes 1 charge and heals every LIVING member `provision_heal`
   (clamped at max_hp; dead untouched — the vat keeps its regrowth
   monopoly). REFUSALS (cue, no silent eat, no spend): at cap, broke,
   zero charges, or ZERO-EFFECTIVE heal (all living at full hp — a
   charge can never burn for nothing). Same-tick seat races: seat-order
   law — the FIRST successful sustain action per tick wins; the second
   seat's press refuses that tick (deterministic on both machines).
   Pricing posture: station heal (2/body, to full) stays the efficient
   move; provisions buy hunt LENGTH at a portability premium (Tibia
   supply-burn touchstone; elastic sink for F3).
10. **Sustain input.** `bindings.json` gains `"sustain": ["U", "R"]`
    (pair grammar: right hand near JKL / left hand near WASD, matching
    every existing pair). Bindings stay a file (rebind UI parked).
11. **Seat scalars (Codex fold #14).** `data/balance/coop.json`:
    `{"seats": {"2": {"respawn_delay_scale": 2.0, "human_hp_scale": 1.25,
    "ally_flee_hp_pct": 0.35}}}`. respawn_delay_scale multiplies the
    kit's `respawn_frames` at schedule time, result `.round`ed to
    Integer (owner Q3a: 300f→600f buys the cross-zone walk-back; the
    presence-block law stays untouched). human_hp_scale applies at human
    spawn (`(max_hp × scale).round`). Absent seat-count key = the block
    never evaluates (decision 7ii).
12. **Third-body caution, seat-gated, precedence PINNED (Codex fold
    #17).** With seats ≥ 2 only: an UNCONTROLLED living pack body with
    hp < ally_flee_hp_pct × max_hp disengages. Precedence in
    AiController: forced-seizure handling first (unchanged) → flee check
    → mark/aggro/target selection (a fleeing body ignores the mark) →
    committed in-flight actions FINISH (flee never interrupts an
    executing swing — matches the action-state machine). Fleeing = no
    new attack actions + move toward the follow anchor. Single-player
    behavior untouched by construction (the guard never evaluates at
    seats=1); promoting it to solo is a recorded future
    comparability-reset decision, not smuggled here.
    **Knob-interaction law (panel Kimi-Q4, named not dodged):** the
    three knobs pull DIFFERENT axes on purpose — delay×2.0 eases PACING
    (the owner's walk-back), hp×1.25 carries DIFFICULTY (Junior's ask),
    flee cuts WASTEFUL attrition (Junior's AI-suicide note); net
    difficulty is not claimed neutral. The SEVENTEENTH's Half B asks
    each seat about ITS OWN friction, which arbitrates each knob
    separately; retune order on a mixed verdict: respawn_delay → hp →
    flee threshold (all JSON edits).
13. **Map artifact (Rule-2 surface with its own checks; Codex fold
    #21).** `rake map [SAVE=] [OUT=]` opens the capture window (GL law),
    renders every zone's full tile grid from the SAME palette/identity
    data the renderer reads (data/zones + display.json — a structural
    test pins map colors to the renderer's palette table; no second
    color source), composites one PNG: zones in a labeled grid (ZONE
    1..5, HUB 1), station glyphs, seal stations stamped SEALED/OPEN from
    the save, home marker at home_zone, header strip
    `BANKED N · MARKS K · PROVISIONS P · BOSS 1 DEFEATS D`. Deterministic
    LANDMARK ASSERTS ride the test lane (pixel probes: a breached seal
    cell differs from a sealed one; the home marker sits in home_zone's
    cell; header strip present) — the vision critique judges the rest.
    Output filename carries digest provenance: `world_<digest8>_<ts>.png`.
    Checks live in `harness/map_checks.json`; the gate for this surface
    is capture + critique (no replay half — there is no sim).
14. **Atomic save writes, Windows-safe (Codex fold #13; panel QW-Q1/Q2
    folds).** Sequence: write `<path>.tmp` in the SAME directory →
    flush + fsync → CLOSE → replace onto `<path>` (MRI-on-Windows
    rename-over-existing is verified by a fault test in the suite; if
    the platform refuses, the implementation uses the tested replace
    idiom — the TEST pins the property, not the syscall). **Replace-
    failure lane** (target open elsewhere — a second instance, editor,
    AV scan): bounded retry (3 × 50ms) then a NAMED console error with
    the intact `.tmp` path — progress is never silently lost, and the
    next launch names an orphan `.tmp` newer than the save (decision
    6a). **Durability is best-effort BY DESIGN** (no directory fsync
    exists on Windows/Ruby): the crash lanes guarantee INTEGRITY (the
    old save is never corrupted), not last-write durability against a
    power cut — recorded, accepted for a hobby save. Fault lanes: crash
    before rename leaves the old save intact; open-handle replace
    failure; consecutive writes; `--fresh` backs up an existing save to
    `world.json.bak-<ts>` BEFORE its first write (the irreversibility
    guard), and a crash between backup and write still leaves the .bak
    recoverable.
15. **Provisions are pack state.** `Pack#provisions` beside `@banked`;
    digest_fields extend (`provisions` scalar). Persisted (F1). Any
    seat's sustain press acts on the shared pool under decision 9's
    first-success-per-tick law.
16. **Solo seed law (Codex fold #10).** Solo launches generate a
    per-session seed in main.rb (same derivation as hosting) and pass it
    through Window to World; the seed prints in the session summary for
    reproducibility. Two-launch regression test: different seeds,
    different fields, SAME persisted facts applied to both.

## Sim spec (src/game/)

- `Game::SaveState` (new, ~150 lines): `SCHEMA = 1`;
  `facts(world) → Hash` (projector, decision 3; pure + idempotent);
  `canonical_bytes(facts) → String` (sorted-key JSON, Integer-leaf law);
  `digest(facts) → md5 hex`; `envelope(facts) → Hash` (schema +
  saved_at_ms wrapper, decision 1); `refusal_for(facts) → String|nil`
  (strict decoder, decision 6a); `apply!(world, facts)` invoked by World
  construction in decision 4's pinned order.
- `World.new(data, seed:, seats:, save: nil)` — facts applied during
  construction (decision 4). `World#save_facts` delegates to SaveState.
  `restore_breach!` (decision 4) shared by live breach + apply.
- `Pack`: `@provisions` (+ digest field), guarded `buy_provision!` /
  `use_provision!` (cap, broke, none, zero-effective) — pure state; verb
  wiring in World's sustain path (decision 9).
- World sustain path: edge-triggered press → on bank station ? buy :
  use; emits `:provision_bought` / `:provision_used` / refusal station
  cues (events registered — Rule 4). `TELEMETRY sustain bought=N used=N
  refused=N`.
- World counters: `boss_1_defeats` increments at the BOSS 1 defeat
  stamp; `sessions` increments at each save-write.
- AiController: decision 12's flee guard at its pinned precedence slot.
- Humans: `(respawn_frames × respawn_delay_scale).round` at schedule
  time; `(max_hp × human_hp_scale).round` at spawn — both only when a
  seats block exists (decision 7ii).

## Persistence + netplay spec (src/net/, src/app/, src/main.rb)

- `data/persistence.json`: `{"save_path": "saves/world.json",
  "wire_budget_bytes": 3072, "backup_on_fresh": true}`.
- Solo launch: per-session seed (decision 16); load facts → strict
  decoder refusals abort pre-window exit 1; the save coordinator
  (decision 2) writes at clean quit only + prints the persist line.
  `--fresh` skips the load (+ backup law).
- Host launch: loads + validates facts BEFORE listening (console
  refusals); wire preflight (decision 6c) before the socket opens;
  SESSION carries schema/digest/facts; the coordinator writes at clean
  quit only.
- Joiner: receives facts in SESSION, validates with the SAME strict
  decoder during the pre-window pump (decision 6a — no window on a
  refused save), recomputes the digest from received bytes (decision
  6d), prints `loaded ... source=handshake`, applies at attach, NEVER
  writes the shared save.
- `Net::Protocol` v2 (decision 8). `Session::Params` grows `save`
  (facts-or-nil) + `save_digest` + `save_schema`. `handle_bye` refusal
  taxonomy extended (decision 6b).
- Coop launchers (`bin/host-coop.cmd` / `join-coop.cmd`): untouched —
  refusals exit 1 and correctly do NOT rehost/rejoin (status-2 law;
  RC-matrix test re-run with the new refusal reasons).

## Presentation spec (Rule-2 surfaces — every state lands in a capture)

- **Provisions counter**: renders ONLY when provisions > 0 (decision
  7iii) — small counter beside the controls strip, placeholder-
  functional text. Strip gains a sustain row under the same condition.
  Buy/use/refuse cues reuse the existing station-cue channel.
- **Strings**: en (dev) + es (dev) + pt-br (Junior ratifies — his active
  lane): PROVISION/PROVISIÓN/PROVISÃO + buy/use/refuse cue verbs.
  Placeholder names stay locale-invariant.
- **Map PNG** (decision 13): its own checks + critique before ship.
- **New wall exerciser** `harness/scripts/sustain_run.json`: buy 2 at
  the bank, walk out, take damage, use both, attempt over-cap buy +
  broke buy + full-hp use (refusal cues) — captures at each beat; checks
  ADD-ONLY in gate_checks.json. Existing 17 scripts: byte-identical by
  construction (decision 7), verified by the canary sweep after every
  sim-touching increment.
- No new netplay overlay states (persistence refusals resolve pre-window
  or as console text; the DESYNC/CONN LOST family is unchanged).

## Test lane (no mocks — real files, real worlds, real sockets)

1. **Round-trip lane (FIRST, the safety net):** world A runs T scripted
   ticks (banks value, breaches a seal, kills a body, buys provisions) →
   `facts` → apply to fresh worlds B1/B2 (same new-session seed) →
   B1/B2 `digest_snapshot` equal at construction AND `StateDigest`
   windows byte-identical for K further scripted ticks. Plus:
   facts(apply(facts(w))) == facts(w) idempotence (envelope excluded —
   Codex fold #2); canonical-bytes stability + Integer-leaf raise;
   **projector sweep** — quit at EVERY tick of a wipe veil serializes
   legally (judgment resolved, marks consumed, ≥1 living; Codex fold
   #4); **persisted-leaf mutation sweep** (Codex fold #18) — mutate
   every PERSISTED leaf in a live world, assert canonical bytes CHANGE
   and the applied world restores that exact value (labels prove
   nothing; round-trips do); refusal_for lanes (schema/roster/zone/
   types/ranges/duplicates/seal-tuples); clamp lanes (hp, provisions);
   apply-order lane (non-default home + only third member alive —
   decision 4's test); **serialize-purity lane** (panel DS-Q2: facts()
   twice = identical bytes, digest_snapshot untouched).
2. **Persistence IO:** real tmpdir files — atomic replace fault lanes
   (crash-before-rename keeps old save; consecutive writes; Windows
   rename-over-existing pinned by test — Codex fold #13; **open-handle
   replace failure → bounded retry → named error with .tmp intact;
   orphan-.tmp detection at next launch — panel QW-Q1**), --fresh backup
   (+ crash-between lanes), digest provenance (persist lines recompute
   from actual bytes), **save-coordinator negative lanes** (Codex fold
   #11): desync / conn_lost / protocol fault / refusal / double-close
   write NOTHING; solo clean quit writes ONCE; **joiner-initiated clean
   quit still saves on the host (reason=:quit both seats — panel
   DS-Q4)**; unparseable/truncated file loads refuse NAMED.
3. **Two-session netplay lane (extends netplay_integration_test):**
   PER-SEAT tmp save roots (Codex fold #19). Session pair 1 (fresh
   world) over real loopback, scripted inputs bank value + breach, host
   writes a REAL save at quit → session pair 2 constructed from that
   file, SESSION transfers the canonical string, joiner digests the
   RECEIVED bytes (never a re-serialization — panel QW-Q4), both
   seats' loaded digests == the saved digest, K ticks zero desyncs,
   carried fact asserted (banked₂start == banked₁end), **joiner save
   root asserted EMPTY** after both sessions. Refusal lanes: schema
   skew (BYE save_schema, refusal text + exit 1 on BOTH seats — Codex
   fold #8), tampered facts (BYE save_digest), malformed facts refuse
   during pre-pump with NO window (Codex fold #7), oversize facts
   (host-start refusal, encoded-line preflight — Codex fold #12),
   protocol v1 peer (version refusal).
4. **Coop feel:** scalar application units (respawn frames + hp are
   Integers at seats=2; NOTHING evaluates at seats=1 — decision 7ii's
   pin); flee precedence lanes (seized ally doesn't flee mid-seizure;
   fleeing ally ignores mark; committed swing finishes — Codex fold
   #17); two-sim lane digest identity with the coop block active.
5. **Sustain:** edge-trigger + swap-rearm lanes (held key = one action;
   Codex fold #16); buy/use/refuse guards incl. zero-effective; heal
   clamp; same-tick two-seat race (first-success law, deterministic);
   digest coverage (provisions in the mutation sweep); wall pin
   (provisions=0 draws nothing — structural).
6. **Map:** rake map produces a PNG (real GL window, harness law);
   structural palette-source test; landmark pixel probes (sealed vs
   breached cell differs, home marker present — Codex fold #21); checks
   file + critique run.
7. **Schema classification exhaustiveness (W1's tripwire):** every
   group/field in `digest_snapshot` is classified PERSISTED or
   SESSION-ONLY in one table in save_state_test.rb; a new digest field
   fails the test until classified. The mutation sweep (lane 1) proves
   the PERSISTED side actually round-trips.

## Watched risks (pre-registered)

- **W1 silent non-persistence** — new sim state reaches the digest but
  not the save. Tripwire: classification test + persisted-leaf mutation
  sweep (lanes 1+7).
- **W2 projector miss** — a transient survives into the save and
  desyncs session 2 at the first boundary. Caught by lanes 1/3; the
  desync artifact names the field (existing machinery).
- **W3 wall contamination** — any of the three pins slips. Structural
  tests + the canary sweep after every sim-touching increment (baselines
  banked FIRST — decision 7).
- **W4 save growth vs wire cap** — the ENCODED SESSION line approaches
  MAX_LINE_BYTES. Preflight at host start + budget test on the encoded
  worst-case line (all seals, max counters).
- **W5 --fresh data loss** — backup rename law + fault tests.
- **W6 balance/data churn vs saves** — clamp+log vs refuse-named table
  (decision 4); roster/zone/seal renames = NAMED refusal, never a crash;
  schema bumps stay cheap and honest, migrations absent by design.
- **W7 version skew mid-rollout** — Junior pulls late; every refusal
  names the field + the fix on BOTH seats (decision 6b widens the
  existing machinery beyond "fingerprint").

## TDD increments (each green + committed before the next)

0. **Baseline banking:** fresh canary baselines for all 17 wall scripts
   (tmp/canary_baseline/, the v17 protocol) — BEFORE any sim change.
1. `Game::SaveState` + round-trip lane (pure sim; lanes 1+7; projector,
   strict decoder, mutation sweep).
2. Persistence IO + solo wiring + solo seed fix (decision 16) + --fresh
   + persist telemetry + save coordinator + wall pin (lane 2; canary
   sweep — src/game + window touched).
3. Protocol v2 + SESSION save transfer + refusal taxonomy + wire
   preflight + two-session netplay lane (lane 3; netplay gates re-run:
   `rake gate SCRIPT=harness/net/... CHECKS=harness/net/gate_checks.json`;
   RC-matrix re-verified).
4. Coop feel: coop.json + scalars + third-body caution at pinned
   precedence (lane 4; canary sweep; netplay gates).
5. Sustain sim: provisions + edge-triggered verb + economy + digest +
   telemetry (lane 5 headless; canary sweep).
6. Sustain presentation: counter + strip row + strings + station cues +
   `sustain_run.json` + ADD-ONLY checks + FULL Rule-2 gate (blocking).
7. God-view v0: rake map + landmark probes + map_checks.json + critique
   artifact (lane 6).
8. Docs + close: JUNIOR.md persistence section (PT-BR-first — pull
   cadence is now schema-critical; **must state the custody contract in
   player terms: the shared world lives on the host's machine, Junior
   solo = his own world, only joining advances the shared one — panel
   Kimi-Q6 fold; and the `--fresh` notice: if the host starts fresh,
   the chain shows it — sessions counter resets, Junior sees
   source=fresh**), AGENTS.md Commands (rake map,
   --fresh, saves/), PARKING_LOT (custody-handoff entry under the
   always-online trigger), checkpoint, SEVENTEENTH protocol confirmed.

Perf after any sim-touching increment: `rake perf` (p95 < 16.6ms,
historically ~0.3ms — persistence adds ZERO per-tick work by decision 2).

## Fun-verify protocol (SEVENTEENTH — pre-registered)

**Ritual:** two real owner+Junior sessions on DIFFERENT days, each ≥10
sim-min (ticks ≥ 36000), both seats exit by Esc, both seats' `TELEMETRY
netplay` + `TELEMETRY persist` lines harvested BEFORE any question (the
launchers print them; %TEMP% session logs are the backup — the SIXTEENTH's
recovery precedent). Between the sessions the owner MAY play solo (F4 —
it advances the world; his persist lines join the chain evidence).

**Half A (PERSISTED) — mechanical arbiter, ALL of:**
- Digest chain: session 2's `persist loaded digest` == the latest prior
  `persist saved digest` (host log), and the joiner's `loaded ...
  source=handshake` digest matches the host's on BOTH sessions.
- `desyncs=0` + `reason=quit` on all four netplay lines (2 sessions × 2
  seats); ticks ≥ 36000 each session.
- Carried fact: session 2's persist line shows the accreted state
  (banked/seals/marks/sessions) matching session 1's close — at least
  one strictly-positive carried fact named in the verdict.

**Half B (FELT) — asked separately, no changelog, questions virgin.**
Wording de-primed per the panel's leading-question critique (Kimi-Q5:
no capitalized MISMO/MESMO steering, both alternatives weighted, no
quoting a player's old complaint back at him):
- Owner (es): 1. Al volver hoy, ¿sintieron que retomaban donde habían
  parado, o que era una partida nueva? 2. ¿Cómo se sintió el respawn de
  los enemigos esta vez? 3. ¿Usaste las provisiones? ¿Cómo cambió la
  cacería? ¿El precio? 4. Veredicto libre.
- Junior (pt-br): 1. No segundo dia, pareceu que vocês tinham voltado
  pra onde pararam, ou que era uma partida nova? 2. Em dupla, como
  sentiu a dificuldade dessa vez? 3. O terceiro corpo (a IA) — como se
  comportou? 4. Veredicto livre.

**Routing (pre-registered — closed here, do not re-litigate):**
- Chain digest mismatch or any session-2 desync → save/load divergence
  work item (round-trip lane extension; artifacts banked, diff named).
- "No continuó" with a CLEAN chain → session-start presentation item
  (the world doesn't SHOW its history; candidate: surface the map
  artifact / a session-open summary — recorded, not auto-built).
- Respawn friction persists → coop.json retune, data-only re-session.
- Sustain unused (`sustain bought=0`) → discoverability first (strip
  exposure), then price debate.
- Sustain named cheap/free OR banked_end grows monotonically 3+
  sessions with flat spend → pricing debate re-opens (F3 valve).
- AI suicides still named → v18.1 embodiment/AI debate item, recorded.
- Junior asks for HIS solo play to advance the shared world → custody
  handoff = the always-online trigger family (PARKING_LOT).
- Quit-timing griefs (value stranded in the field at quit) named →
  recorded as EVIDENCE for the item-cycle promotion (backpack +
  position persistence + logout rules — the owner's 2026-08-17 rider,
  PARKING_LOT §riders); plus the session-close "bank before you leave"
  cue as the cheap v18-era mitigation. The v18 mechanic itself does not
  re-open (the exploit stands until position persistence exists).
- Session 2 opens under-resourced (dead bodies + banked below the
  regrow fee) AND the opening reads as chore → mercy-floor debate
  (e.g., a first-open regrow discount) — recorded, not auto-built
  (panel Kimi-Q2 watch; the comeback-arc reading gets its fair test
  first).

## Deliberately absent (recorded so review doesn't re-litigate)

- **Autosave / crash recovery** — clean-quit save only; a crash loses the
  session (v1 honesty; cadence is a data knob for a future cycle).
- **Save migrations** — refusal + `--fresh` instead; machinery returns
  only when schema churn measurably bites (W6 records the expectation).
- **Multiple slots / named worlds** — one world file; `--fresh` backs up.
- **Joiner-side persistence, custody handoff, world-line merge** — the
  always-online fork's domain, parked with its named trigger.
- **In-game map / teleport / world editing** — staged behind the offline
  artifact (owner vision routing).
- **Field-state persistence** (humans/drops/corpses/carried) — re-seed
  law (F1); carried persistence rejected as a loot-teleport exploit
  (Codex #1).
- **Field regrowth / battle-rez** — the vat's monopoly stands.
- **Density scaling for coop** — hp scale first (smallest honest knob).
- **Single-player third-body caution** — future comparability-reset
  decision, recorded in the brainstorm.
- **Provision drops/pickups/regen** — provisions exist only via banked
  spend at the bank (owner law 2026-08-11).
- **In-game rebind UI** — bindings.json law stands (sustain = U/R).
- **Save-at-station-only** (Codex #1's alternative fix) — rejected in
  favor of dropping carried from the save: quit must stay available
  anywhere (a hobby session ends when life calls), and the bank ritual
  emerges from value pressure, not from a quit gate.
