# The fight ledger (post-fight registration beat + bank-leg tally)

Status: REVISED (2026-08-11, post 3-lens adversarial review — code-fit, design, fun;
run as a direct Agent fan-out per the Workflow-failure ladder. 24 findings folded, 3
rejected with reasons; verdicts + fold ledger: `drafts/_ledger-spec-review.md`).
Scope contract v8: owner locked "post-fight ledger now, A2 threat PRE-QUEUED" via
AskUserQuestion — if this increment's fun-verify does not move the chore, threat
promotes automatically. Mid-review the owner supplied live corpus evidence (a
level-1037 EK Hunt Analyser: Loot 1,558k / Supplies 311k / Balance +1,247k GREEN in
59 min) + the decision-stack quote — banked at
`drafts/_tibia-hunt-analyser-ek1037.md` and folded into the framing below.

Binding upstream, cited honestly (review H1): the COMMON-case beat implements
**FR-024's itemized-yield half** plus **FR-031** (itemized per-kill drops, genuine
zero outcomes); the **spend-vs-yield delta** half lands only where losses exist (loss
beats, the wipe recap, the bank tally), and the FULL delta — supply burn, the
corpus's negative-P&L driver — is explicitly deferred to D1b. **FR-033** (accounting
must run negative, shown honestly) lands at the wipe recap and bank tally. **FR-025**
(screen budget) binds the presentation. Sources:
`workspace/gamesmith/artifacts/synthesis/rendered/spec.md`;
`gamesmith/artifacts/games/tibia/extract/rendered/design-judgment.md` §103
("instrumentation itself teaches caring"), §72; `systems-map.md` §62. The owner's
screenshot corrects the extract sample: the analyser is not a loss-teller — it is an
honest scale that balanced, skilled play BEATS. Green is the mastery readout
(Challenge/Submission, §103's praise line); red must be possible and honest, not
common.

## Why this is the increment (the verdict chain)

Three fun-verifies say "bank or push deeper = still a chore" (D0 twice, D1 once).
D1's pre-registered routing sent the primary failure to **the pile lacks meaning**:
Q4 "banked, wouldn't care" is the D1 spec's own D1b/ledger routing clause verbatim.
D1 proved the loss MECHANISM works and still didn't move the verdict — drama cannot
price a stake the player doesn't value.

**The experiment this spec runs (LB-1, restated post-review):** does making each
fight's outcome legible — an itemized take, an honest loss, an earned green — give
the pile meaning, without new threat and without new economy? Today a fight ends and
nothing registers; the carried numeral is an odometer, not income.

**The altitude line (owner quote, 2026-08-11):** Tibia's number is magic because it
is downstream of a decision stack the player owns (spec, equipment, spot, pull,
combo). game-two currently feeds its number almost no player-owned variables. **The
ledger is the instrument, not the magic** — it is what will make A2/A3's variables
felt when they arrive. LB-1 tests whether the instrument alone moves anything; a NO
means "nothing to grade yet," which is exactly the case v8 pre-registered for
promoting threat. Owned honestly: this is the third increment aimed at the chore
without touching combat lethality.

## Scope (one variable at a time)

**IN — one accounting system, three resolution moments:**
1. **Engagement window** (sim-owned): opens on combat or recovery, accrues the
   fight's loot movements, resolves after a quiet period.
2. **Registration beat**: a qualifying window resolves into a 1-3 line
   glyph+number tally for a fixed display window, then leaves.
3. **Wipe recap**: a wipe resolves the window immediately; the beat renders on the
   wipe veil, its stranded line showing the FIELD truth (snapshot of all live
   containers).
4. **Bank-leg tally** (review fun-H2 + owner evidence): banking prints the leg's
   reconciliation — net since last bank — in the same grammar. The touchstone's
   actual felt moment (the session P&L) at the granularity our sim owns (the leg).
5. **`:fight_resolved` event** with pinned payload; telemetry line extended.

**OUT — recorded trims and deferrals:**
- No supply burn / upkeep (D1b territory — the full FR-024 delta arrives with it).
- No session-level analyser panel, no persistent HUD element (FR-024's own
  transformation + quiet-HUD law).
- No per-hit floating text (anti-touchstone: digest §6; FR-025).
- **No kill notches, no kill line** (review design-M3: untaught grammar, zero
  touchstone, corpus anti-evidence — design-judgment §104's tally-framing critique;
  and rendering kills inside the currency beat prices them by position). Kills stay
  in payload + telemetry.
- **Kin deaths do not render in the beat** (review fun-M1, rejected as render
  change): the beat is a LOOT instrument; kin are not currency. Kin-death drama is
  the forced-swap veil's job. WATCH ITEM, recorded: if the fun-verify says
  casualty fights read false-clean, that routes to D1b (pricing kin = fees), not
  to this beat.
- Banked amount itself never renders in a fight beat (station numeral is that
  verb's feedback); the bank-leg tally prints the LEG's delta, not the total.
- Off-window term expiry in an abandoned zone stays under-dramatized at FIGHT
  scale (window accrual is zone-filtered — review M3/M1); it IS counted at LEG
  scale (the bank tally's destroyed line, all zones — losing a pile two districts
  away is the leg's loss).
- Q2b "too long / tedious" run-back is a non-goal: tedium is length WITHOUT
  danger — A2's problem (pre-queued), not legibility's.

## Sim spec

- **Ownership.** New `Game::FightLedger` (src/game/fight_ledger.rb), owned by
  World, subscribed on the bus (the `Game::Telemetry` pattern), ticked from
  `tick_world` — quiet clock, beat display clock, and leg accumulator all FREEZE
  under hitstop and during the `:nest_respawn` veil, like every D1 clock.
  Renderer reads `world.ledger_beat` as a pure reader.
- **Window open/extend/refresh.** `damage_dealt`, `actor_died`, and
  `corpse_looted` open a window (or refresh an open one). `corpse_looted` opens
  deliberately: an unopposed recovery is an engagement with the stakes — the
  redemption beat must fire. **`drop_picked_up` REFRESHES an open window but
  never opens one** (review H3/fun-H1/dev seed — the kill-then-sweep rhythm must
  stay one engagement, or the tally undercounts and teaches mistrust; ambient
  gleaning while travelling still opens nothing). `attack_started` (whiffs)
  touches nothing. Trade recorded: a take deliberately abandoned prints +0 with
  the fight — honest ("you left it"), and drop decay already prices abandonment.
- **Zone discipline (review M2/M3-codefit, M1-design).** The window captures its
  zone at OPEN and never reads `world.zone_name` at resolve (stale on
  transitions — the emit flushes after `@zone_name` is reassigned). Window-scale
  `carried_lost` accrual is filtered on `event.zone == window.zone`.
- **Accrual while open** (amounts from pinned payloads, all verified present):
  - `gained` += `drop_picked_up.amount` and `corpse_looted.amount` — the key is
    `gained:`, NOT `yield:` (review L3-codefit: kills the Ruby-keyword hazard
    class). Fight-level `gained` INCLUDES recoveries: the stranded-then-recovered
    churn print (`+45 / -40 / = +5`) is the honest arc of that fight (review
    L2-design, owned).
  - `stranded` += `corpse_loaded.amount` · `destroyed` += `carried_lost.amount`
    (window's zone only) · `kills` / `pack_deaths` from `actor_died.faction`
    (payload + telemetry only — never rendered).
  - `net = gained - stranded - destroyed`.
- **Resolve.** When the quiet clock (`ledger_quiet_frames`) runs out: if the
  window qualifies (`kills + pack_deaths > 0` or any loot movement), emit
  `:fight_resolved` and set the beat record; otherwise dissolve silently.
  **A dissolve NEVER replaces a live beat** (review M4-design: a graze-exchange
  gate-escape must not stomp a negative beat with nothing). A qualifying resolve
  replaces any live beat (screen budget: one tally). Stomp residue accepted +
  recorded: a rare qualifying force-resolve inside another beat's 150f display
  can truncate it; the information persists in telemetry — merge machinery
  rejected.
- **Engagement boundary, owned honestly (review H2-design/fun-H3).** A sustained
  camp near spawn points IS one engagement — staggered 300f respawns re-arrive
  under any plausible quiet value, and the aggregate beat at disengage is honest
  per-engagement accounting, not a failure. The 180f starting value is a
  HYPOTHESIS with a pre-registered MEASURED gate: the pilot flight must produce
  a beats-per-minute figure inside **1-4 beats/min** over a realistic hunt loop,
  and at least one distinct beat per staged act; `ledger_quiet_frames` is tuned
  from that measurement BEFORE the fun-verify, never by feel. (The false
  "resolves between waves" justification is deleted — 180<300 was never the
  binding arithmetic.)
- **Interlock, asserted (review M5-design):** `ledger_quiet_frames <
  loot_settle_frames` — the mid-fight negative beat (carrier dies, fight
  resolves before recovery is even permitted) exists only under this cross-file
  invariant. Pinned by a data-load assertion test like D1's `grace <= term`.
  Q5-driven tuning must respect it or consciously break it (mode change,
  recorded at that time).
- **Wipe.** `pack_wiped` resolves the open window immediately; always qualifies.
  **Ordering pinned (review M6-design):** the wipe-tick `corpse_loaded` emissions
  accrue BEFORE the `pack_wiped` resolve — guaranteed by same-flush FIFO append
  order (corpse_loaded is emitted earlier in the same actor_died handler chain);
  pinned by test. **The recap's stranded line is a SNAPSHOT of all live
  containers at wipe** (review M4-design fold) — the field truth the run back is
  about, not just this window's accrual; `gained`/`destroyed` stay
  window-accrued. Because `tick_world` never runs during `:nest_respawn`,
  `beat_left` freezes for the whole veil and resumes on re-entry — the recap
  persists through the veil + `ledger_beat_frames` of the run back's start with
  zero special-case STATE (one owned draw-order decision, see Presentation).
- **Zone transition.** `enter_zone` force-resolves an open window first
  (qualifies-or-dissolves by the same rule; dissolves never stomp). The beat may
  render one screen into the new zone with an off-zone pip referent —
  accepted + recorded (review L4-design), once-per-gate-escape, watch item.
- **Leg accumulator (bank tally).** Continuous between `banked` events, frozen
  with the other clocks: `leg_gained` += `drop_picked_up.amount` only
  (FIRST-acquisition convention — recoveries re-acquire value already counted;
  review L2-design), `leg_destroyed` += `carried_lost.amount` (ALL zones — at
  leg scale every expiry is the leg's loss), `leg_net = leg_gained -
  leg_destroyed`. On `banked`: emit nothing new (banked already exists), set the
  bank-tally beat (replaces any live beat), reset the accumulator. The tally's
  pip line shows outstanding stranded value (live-container snapshot, excluded
  from net — "you are leaving -N on the field").
- **Event** (registered on first use), payload pinned: `:fight_resolved`
  `(zone:, span_frames:, opened_by:, kills:, pack_deaths:, gained:, stranded:,
  destroyed:, net:, wiped:)`. `span_frames` counts TICKED frames
  (open-to-resolve, tick_world ticks — review L1-codefit: @frame advances during
  hitstop/veil and would lie). `opened_by:` = `:combat` | `:recovery` (review
  L3-design: attribution split for telemetry + fun-verify). Payload consumers
  must not kwarg-destructure (`Event#[]` / `.payload` indexing only — existing
  idiom everywhere).
- **Beat record** read by the renderer: the resolved payload plus `beat_left:`
  and `beat_frames:` (review L4-codefit — every timed visual carries its total;
  drops carry decay_frames, loads carry term), plus `kind:` = `:fight` |
  `:wipe` | `:bank` and the bank/wipe extras (outstanding-stranded snapshot).
- **Data**: new `data/balance/ledger.json` —
  `{"ledger_quiet_frames": 180, "ledger_beat_frames": 150}`. Both hypotheses;
  quiet is gated by the measured cadence band above. Zero balance constants in
  Ruby.

## Presentation spec (Rule 2 surface)

Glyphs + signed numbers, no words — the game's taught grammar only (review
design-M2/M3): filled magenta square = acquired value, hollow magenta square (the
D1 pip) = pile-on-a-corpse RECOVERABLE, dark-flash-family square = DESTROYED (the
expiry flash taught it), colors carry sign. Top-center below the banner line
(banner y=48, beat starts y≈96), `hud_font` scale, max three lines (FR-025):

1. **Take line** (always): filled square + `+N` in DROP_CORE. `+0` is legal and
   honest (an abandoned take — rushers always pay, so a true zero needs future
   content; review H3 rewrote FR-024's "explicit nothing" honestly). A
   RECOVERY-OPENED window's take line is pip-prefixed (hollow pip before the
   filled square): recovered, not earned (review fun-M5 — the redemption beat
   spends its own identity otherwise).
2. **Loss line** (only when `stranded + destroyed > 0`): hollow pip + `-N` for
   stranded (out there — calm, true, matches the field state); dark square +
   `-M` for destroyed (gone). The two marks may co-occur. Red is never used for
   recoverable state (review fun-M2's cry-wolf, resolved via grammar, not
   suppression).
3. **Net line** (only when a loss line exists): `= ±N`, bold; DROP_CORE positive,
   wipe-red negative.

**Wipe recap** (`kind: :wipe`): same slot, same grammar; loss line uses the
live-container SNAPSHOT (field truth); renders during the veil. **Draw order
pinned (review M1-codefit): the beat draws AFTER `draw_wipe_overlay`** (and before
`draw_stagger_veil`) — the alpha-170 veil would bury a beat drawn in the banner
slot; this is the one owned ordering decision, replacing the DRAFT's false
"zero special-case rendering" claim.

**Bank tally** (`kind: :bank`): same slot, same grammar, at the moment of banking:
take line = leg gained; loss line = pip outstanding-stranded + dark leg-destroyed;
net line = leg net. This is the leg's reconciliation — the owner's screenshot
moment (+1,247k after costs) at our scale.

Layout constants live in the renderer (LEDGER_RADIUS_TILES precedent);
timing/threshold numbers in `ledger.json`. Fiction order form: the beat/tally's
eventual name — one new item; the on-screen surface is numeric/glyph and blocks
on nothing.

## Harness + gates

- New gate script `ledger_loop.json`, authored VIA PILOT MODE: (act 1) a clean
  win — one-line `+N` beat; (act 2) a carrier dies and the fight resolves before
  recovery — negative beat with the pip loss line (the quiet<settle interlock on
  camera); (act 3) a wipe — veil recap with snapshot stranded line, frozen
  through the veil; (act 4) the run-back recovery — pip-prefixed redemption
  beat; (act 5) a banking — the leg tally. ≤ 20 captures.
- **Cadence ship gate (review H2/fun-H3, pre-registered):** the pilot flight's
  measured beats-per-minute over the realistic hunt segment must land in
  **1-4/min**, else `ledger_quiet_frames` is retuned from the measured
  inter-event gaps and the flight re-run — BEFORE the fun-verify. Recorded in
  the checkpoint with the measured number.
- APPENDED vision checks (26 → 30, existing never weaken, pass-true
  not-exercised hatches):
  1. `ledger_beat_reads` — post-fight tally appears top-center and leaves;
     gains distinct from losses by color; never occludes the fight or HUD.
  2. `ledger_negative_reads` — a stranded-loss fight shows the pip loss line
     and a negative net, visually distinct from the win case.
  3. `wipe_recap_reads` — the wipe veil carries the tally legibly (drawn OVER
     the veil), stranded number readable alongside the wipe line.
  4. `bank_tally_reads` — banking prints the leg reconciliation at the
     station moment, distinct from a fight beat's context.
- Tests (minitest, real World, no mocks): window opens on damage_dealt /
  actor_died / corpse_looted; NOT on attack_started / drop_picked_up;
  drop_picked_up REFRESHES an open window (kill-sweep stays one beat) but never
  opens; quiet resolve emits `:fight_resolved` with the pinned payload
  (`gained:` key, `span_frames:` in ticked frames, `opened_by:`); non-qualifying
  dissolve is silent AND never replaces a live beat; explicit-abandonment beat
  (kill, no pickup → `gained: 0`); stranded-then-recovered same window nets zero
  (churn payload `+45/-40/=+5` shape); negative net case; **zone captured at
  open** (transition force-resolve reports the ORIGIN zone); **carried_lost
  zone filter** (off-zone expiry does not enter the window; DOES enter the leg
  accumulator); wipe resolves immediately with `wiped: true`, **wipe-tick
  corpse_loaded accrues before the resolve** (ordering pin), recap carries the
  live-container snapshot, beat survives the veil (beat_left frozen — D1
  veil-freeze pattern); zone transition force-resolves; quiet + beat clocks
  freeze under hitstop (the leg accumulator is event-driven — no clock);
  a qualifying resolve replaces a live beat;
  **data assertion `ledger_quiet_frames < loot_settle_frames`**; leg
  accumulator: first-acquisition convention (recovery adds nothing at leg
  scale), all-zones destroyed, outstanding snapshot on bank, reset on bank;
  **telemetry_test summary-string update named here** (review L2-codefit:
  byte-exact assert is rewritten, not weakened to substring); determinism (same
  script, byte-identical).
- **Telemetry** (additive fields; D1 fields keep meaning):
  `fights=<n> recovery_fights=<n> negative_fights=<n>` from `:fight_resolved`
  (`opened_by` split — review L3-design). Harness-computed at session end: net
  distribution, beats/min (the cadence gate's number), fights per session.
- `rake` + `rake perf` + ALL gates green (now 7 scripts); adversarial impl
  review; merge --no-ff, NO push.

## Fun-verify (owner questions, after ship — via AskUserQuestion, two batches)

**Preamble:** if no tally ever appeared, say so — telemetry distinguishes a
threshold bug from a no-combat session.

1. **Fight beats — wins:** when a won fight's tally appeared, did it land as a
   payoff, or was it wallpaper you stopped seeing?
2. **Fight beats — losses:** when a tally showed a loss line (pip "out there" /
   dark "gone"), did it sting or change your next move — or nothing?
3. **The chore question (FOURTH ask, verbatim):** did "bank now or push deeper"
   change now that every fight prices itself?
4. **Wipe recap:** did the recap's stranded number change how the run back felt
   compared to D1's wipe — a mission with a number on it, or the same walk?
5. **Bank tally:** did the leg reconciliation at the bank mean anything — did
   you ever bank BECAUSE you wanted to see the leg close out?
6. **Legibility escape-valve (review H4-design):** was there ever a tally you
   couldn't read or didn't understand? (A yes routes to presentation iteration,
   NOT to any meaning verdict.)
7. **The instrument oracle (review fun-M4):** if the tallies stopped printing
   tomorrow, would you notice and miss them?
8. **Carryover control (labeled — review fun-M4):** if your banked number were
   silently halved, would you care now? (D1's Q4 verbatim; this build does not
   manipulate banked, so this is a control reading, not the oracle.)

**Pre-registered routing (locked with scope v8 — do not re-derive after the
answers land):**
- **Q3 alone is the A2 promotion oracle.** Q3 "still a chore" → A2 threat
  promotes, full stop (owner pre-authorized).
- Q6 "couldn't read it" quarantines the affected answers → presentation
  iteration first; the meaning verdict waits (review H4 — a badly built beat
  must not masquerade as a meaning result).
- Q1/Q2/Q5/Q7 decide ATTRIBUTION and the ledger's DISPOSITION at the A2
  handoff (review fun-M3): any real signal (Q7 yes, or Q1/Q2/Q5 any positive)
  → the ledger STAYS through A2's increment; wallpaper + wouldn't-miss → the
  ledger is REMOVED before A2 ships (one variable at a time cuts both ways),
  recorded either way.
- Q4 "same walk" is pre-registered as CONSISTENT with LB-1 and feeds A2's case
  (review fun-L1 — a number at second 3 does not fix minute 2; that is
  threat's territory).
- Q5-as-boundary-gaming (waiting out the quiet clock) = tuning signal for
  `ledger_quiet_frames` under the M5 interlock, not a system verdict; it is
  ALSO caring-about-the-number evidence (review fun-L3).
- Banking collapse or convenience-death exploits in telemetry = D1b's trigger
  (fees), which stays parked otherwise. Economy/spending stays parked in ALL
  branches — it enters only via D1b's own trigger.

## Deliberately absent (recorded so review doesn't re-litigate)

Supply burn / upkeep (D1b — the full FR-024 delta arrives with it); session-end
summary (no session boundary in the sim; the LEG is the granularity our sim
owns); persistent analyser panel; per-hit floating numbers; kill notches / kill
line (design-M3: no touchstone, corpus anti-evidence §104); kin-death rendering
in the beat (fun-M1 rejected: loot instrument, veil owns kin drama — WATCH
ITEM → D1b if casualty fights read false-clean); stomp-merge machinery
(design-M4 rejected: dissolves never stomp, rare qualifying stomps accepted);
suppress-stranded-while-recoverable logic (fun-M2 rejected: grammar
distinguishes instead — suppression creates losses that never print); pricing
kin (D1b); XP/score/grades; ledger history/log; sound on the beat (fiction-bound
audio waits on the bible).
