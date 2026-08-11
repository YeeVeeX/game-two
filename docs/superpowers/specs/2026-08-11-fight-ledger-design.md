# The fight ledger (post-fight registration beat)

Status: DRAFT (pre 3-lens adversarial review). Scope contract v8 (2026-08-11):
owner locked "post-fight ledger now, A2 threat PRE-QUEUED" via AskUserQuestion —
if this increment's fun-verify does not move the chore, threat promotes
automatically. Approach and shape are dev-of-record calls per the project
contract; the owner verdict this spec answers is D1's fun-verify
(`drafts/_d1-fun-verify-20260811.md`).

Binding upstream: gamesmith synthesis **FR-024** (the registration beat),
**FR-033** (accounting must run negative and be shown honestly), **FR-025**
(screen-budget rule) — `workspace/gamesmith/artifacts/synthesis/rendered/spec.md`.
Corpus evidence: Tibia's Hunt Analyser converts every hunt into a live P&L
statement, and that statement is frequently NEGATIVE on-screen (-1,428/-1,536
mid-hunt; session ends -7,959 / -18,749 / -47,270) — "few games show the player
their own losing P&L in real time"
(`gamesmith/artifacts/games/tibia/extract/rendered/design-judgment.md` §48, §103;
`systems-map.md` §62). FR-024 deliberately TRANSFORMS that into a
**per-engagement beat, not an always-on overlay** — which is also exactly what
game-two's quiet-HUD law demands (the world HUD never carries the score;
renderer.rb station-ledger comment).

## Why this is the increment (the verdict chain)

Three fun-verifies say "bank or push deeper = still a chore" (D0 twice, D1 once).
D1's pre-registered routing sent the primary failure to **the pile lacks
meaning**: Q4 "banked, wouldn't care" is the D1 spec's own D1b/ledger routing
clause verbatim. D1 proved the loss MECHANISM works (2 carrying deaths, 2
recoveries, drama on camera) and still didn't move the verdict — drama cannot
price a stake the player doesn't value.

**The experiment this spec runs (LB-1):** does making each fight's outcome
LEGIBLE — a priced win, a priced loss, an honest zero — give the pile meaning,
without new threat and without new economy? Today a fight ends and nothing
registers: drops lie where they fell, the carried numeral drifts upward, losses
vanish into a corpse pip. The player is never TOLD what a fight paid or cost,
so the pile is an odometer, not income. Tibia's insight (design-judgment §103)
is that instrumentation itself teaches caring: the P&L statement is what turns
hunting from wandering into a wager.

**Owned honestly:** this is the third increment that tries to move the chore
without touching combat lethality. That is WHY v8 pre-queued threat: a clean
LB-1 failure auto-promotes A2 — the fun-verify below pre-registers that routing.

## Scope (one variable at a time)

**IN — one system, the fight ledger:**
1. **Engagement window** (sim-owned): opens on combat, accrues the fight's
   loot movements, resolves after a quiet period.
2. **Registration beat**: when a qualifying window resolves, a 2-3 line
   glyph+number tally renders for a fixed display window, then leaves.
3. **Wipe recap**: a wipe resolves the window immediately; the same beat
   renders on the wipe veil (zero special-case rendering — see below).
4. **`:fight_resolved` event** with pinned payload; telemetry line extended.

**OUT — recorded trims and deferrals:**
- No supply burn / upkeep costs (the corpus's negative-P&L DRIVER — that is
  economy, D1b territory; our negative comes from real D1 losses: stranded and
  destroyed piles).
- No session-level analyser panel, no persistent HUD element (FR-024's own
  transformation + quiet-HUD law).
- No per-hit floating text (anti-touchstone: Tibia's text feedback saturates —
  digest §6; FR-025. The beat is ONE readout per fight, screen-budgeted).
- No kill XP, no scoring, no combat grades — the ledger reads the LOOT ledger
  (yield/stranded/destroyed), plus a kill count line. Kin loss is NOT priced
  (fees are D1b); kin death drama is the forced-swap veil's job.
- Banked events do not render in the beat (the station numeral is that verb's
  feedback; double-printing violates screen budget).
- Off-window term expiry stays under-dramatized (dark flash only, as D1 built
  it). Recorded trim: the ledger registers losses that resolve DURING a fight;
  a pile that quietly expires two districts away is threat/scavenger (D3)
  territory, not this beat's.
- Q2b "too long / tedious" run-back is a non-goal: tedium is length WITHOUT
  danger; that is A2's problem (pre-queued), not legibility's.

## Sim spec

- **Ownership.** New `Game::FightLedger` (src/game/fight_ledger.rb), owned by
  World, subscribed on the bus (the `Game::Telemetry` pattern), ticked from
  `tick_world` — so the quiet clock and the beat's display clock FREEZE under
  hitstop and during the `:nest_respawn` veil, exactly like every D1 clock.
  Renderer reads `world.ledger_beat` as a pure reader (no draw-path mutation).
- **Window open/extend.** These events open a window (or refresh the quiet
  clock of an open one): `damage_dealt`, `actor_died`, `corpse_looted`.
  `corpse_looted` opens deliberately: an unopposed recovery is an engagement
  with the stakes even when bloodless — the run-back's redemption beat must
  fire (D1's Q1 "standing in line" was partly a legibility hole: regaining the
  pile never REGISTERED as regaining).
  `attack_started` (whiffs) and `drop_picked_up` do NOT open a window —
  ambient gleaning while travelling is not a fight.
- **Accrual while open** (amounts from event payloads, all already pinned):
  - `yield` += `drop_picked_up.amount` and `corpse_looted.amount`
  - `stranded` += `corpse_loaded.amount` (pile left your hands onto a corpse)
  - `destroyed` += `carried_lost.amount` (term expiry landing mid-fight)
  - `kills` += 1 per human `actor_died`; `pack_deaths` += 1 per pack death
  - `net = yield - stranded - destroyed`. Stranded-then-recovered in the same
    window nets to zero — correct: the fight ended with the pile back in hand.
- **Resolve.** When the quiet clock (`ledger_quiet_frames`) runs out: if the
  window QUALIFIES (`kills + pack_deaths > 0` or any of yield/stranded/
  destroyed nonzero), emit `:fight_resolved` and set the beat record;
  otherwise dissolve silently (a graze exchange with no consequence never
  prints — screen budget). A qualifying fight with zero yield prints "+0":
  FR-024's explicit-nothing case, on purpose.
- **Wipe.** `pack_wiped` resolves the open window immediately (the wipe IS the
  resolution; always qualifies — a wipe implies pack deaths). Because
  `tick_world` never runs during `:nest_respawn`, the beat's display clock is
  frozen for the whole veil and resumes on re-entry: the recap persists
  through the veil plus `ledger_beat_frames` of the run back's start, with
  ZERO special-case code. FR-033 lands here: the wipe recap is where the
  number goes honestly negative — the run back now has a number on it.
- **Zone transition.** `enter_zone` force-resolves an open window first
  (leaving the district ends the engagement by fiat; qualifies-or-dissolves by
  the same rule). Deterministic; no cross-zone windows.
- **Event** (registered on first use), payload pinned: `:fight_resolved`
  `(zone:, frames:, kills:, pack_deaths:, yield:, stranded:, destroyed:,
  net:, wiped:)`. `frames` = window open span (opens-to-resolve, sim frames).
  NB `yield` is the hash key; avoid bare `yield` in Ruby locals (keyword).
- **Beat record** read by the renderer: the resolved payload plus `beat_left:`;
  `beat_left` starts at `ledger_beat_frames`, decrements in `tick_world`, and
  the record clears at zero. A new resolve REPLACES a live beat (screen
  budget: never two tallies at once).
- **Data**: new `data/balance/ledger.json` —
  `{"ledger_quiet_frames": 180, "ledger_beat_frames": 150}`.
  Quiet = 3s: under the 300f rusher respawn so camp-fights resolve between
  waves; long enough that hitstop chains (frozen anyway) and brief chases
  don't split one fight. Beat = 2.5s display. Both are HYPOTHESES; Q5 below
  is their tuning signal. Zero balance constants in Ruby.

## Presentation spec (Rule 2 surface)

The beat is **glyphs + signed numbers, no words** — the game's own pictographic
grammar (filled square = pickup, corpse rect = body, colors carry meaning), so
nothing needs a fiction name to ship and nothing English can slop through.
Top-center, below the zone-banner line (banner y=48; beat starts y≈96),
`hud_font` scale, max three lines (FR-025 budget):

1. **Yield line** (always): filled magenta square glyph + `+N` in DROP_CORE —
   the fight's take, `+0` allowed and honest (FR-024's explicit nothing).
   Kill count as small human-corpse-colored notches after the number (kills
   are context, not currency).
2. **Loss line** (only when `stranded + destroyed > 0`): hollow magenta square
   glyph (the D1 pip — the pile-on-a-corpse symbol the player already knows) +
   `-N` in the wipe-red family. Destroyed amounts render in the same line
   (they are both "left your hands"; the corpse pip on the field says which
   kind).
3. **Net line** (only when a loss line exists): `= ±N`, bold, DROP_CORE when
   positive, wipe-red when negative. A clean win is ONE line; a costly win is
   three; a wipe recap is usually `+N / -M / = -K` — the honest negative.

During the wipe veil the recap renders in its same slot, above "THE HUNT ENDS"
(different screen regions, no collision). Layout constants live in the renderer
(the LEDGER_RADIUS_TILES precedent); timing/threshold numbers live in
`ledger.json`.

Fiction order form (bible session, parallel): the beat's eventual name (the
tally/reckoning moment) — new item; on-screen content is numeric/glyph only, so
nothing blocks on the bible.

## Harness + gates

- New gate script `ledger_loop.json`, authored VIA PILOT MODE (protocol:
  harness/pilot.rb header; printf-append, never Write): (act 1) a clean win —
  one-line `+N` beat on camera; (act 2) a carrier dies, fight resolves before
  recovery — three-line NEGATIVE beat on camera; (act 3) a wipe — veil recap
  frozen on camera; (act 4) the run-back recovery — redemption beat (`+N` via
  `corpse_looted` opening a window). ≤ 20 captures (critic sampler).
- APPENDED vision checks (26 → 29, existing never weaken, pass-true
  not-exercised hatches per the shared-checks-file law):
  1. `ledger_beat_reads` — after a fight resolves, a short glyph+number tally
     appears top-center and leaves; gains read distinct from losses by color;
     it never occludes the fight or the HUD bars.
  2. `ledger_negative_reads` — a fight that ended with the pile stranded shows
     a loss line and a NEGATIVE net, visually distinct from the win case.
  3. `wipe_recap_reads` — the wipe veil carries the fight's tally alongside
     the wipe line; the stranded number is legible during the veil.
- Tests (minitest, real World, no mocks): window opens on damage_dealt /
  actor_died / corpse_looted; NOT on attack_started or drop_picked_up;
  drop_picked_up accrues only into an open window; quiet-clock resolve emits
  `:fight_resolved` with the pinned payload; non-qualifying window dissolves
  silently; explicit-nothing beat (kill, zero yield) fires with `yield: 0`;
  stranded-then-recovered same window nets zero; negative net case; wipe
  resolves immediately with `wiped: true` and the beat survives the veil
  (beat_left frozen — the D1 veil-freeze test pattern); zone transition
  force-resolves; quiet + beat clocks freeze under hitstop; a second resolve
  replaces a live beat; telemetry line extension; determinism (same script,
  byte-identical).
- **Telemetry** (additive to the existing line — the D1 fields keep their
  meaning): `fights=<n> negative_fights=<n>` from `:fight_resolved` counts.
  Harness-computed from the event log at session end: net distribution,
  fights per session, negative-fight rate, beats-per-minute (screen-budget
  check against FR-025).
- `rake` + `rake perf` + ALL gates green (now 7 scripts); adversarial impl
  review; merge --no-ff, NO push.

## Fun-verify (owner questions, asked after ship — via AskUserQuestion)

**Preamble:** if no beat ever appeared, say so — that is a window-threshold bug
or a no-combat session, and the telemetry line will distinguish them.

1. When a fight ended and the tally appeared — did wins land as a payoff and
   losses sting, or was it wallpaper you stopped seeing?
2. After a NEGATIVE tally (red net): did it change what you did next — chase
   the pile, play safer, anything — or nothing?
3. Did "bank now or push deeper" change now that every fight prices itself?
   (The chore question, FOURTH ask — the one v8 exists to move.)
4. On the wipe screen: did the recap's stranded number change how the run back
   felt compared to D1's wipe (a mission with a number on it, or the same
   walk)?
5. Did you ever disengage or wait around just to make the tally appear?
   (Window-tuning signal for `ledger_quiet_frames`, not a system verdict.)
6. If your banked number were silently halved, would you care NOW? (Q4 of D1,
   re-asked verbatim — the direct meaning oracle.)

**Pre-registered routing (locked with scope v8 — do not re-derive after the
answers land):** Q1 wallpaper + Q6 still-wouldn't-care = LB-1 fails → **A2
threat AUTO-PROMOTES** (owner pre-authorized; legibility alone cannot price an
uncontested pile). Q6 cares + Q3 still-a-chore = meaning exists but the
decision lacks pressure → same routing, threat. Q5 yes = tune
`ledger_quiet_frames` from the measured beat cadence, not by feel. Banking
collapse or convenience-death exploits in Q2/telemetry = D1b's trigger (fees),
which stays parked otherwise. Economy/spending stays parked in ALL branches —
it enters only via D1b's own trigger, never as a routing default.

## Deliberately absent (recorded so review doesn't re-litigate)

Supply burn / upkeep (the corpus driver of negative P&L — D1b/economy);
session-end summary screen (no session boundary exists in the sim); persistent
analyser panel (FR-024 transformation + quiet-HUD law); per-hit floating
numbers (anti-touchstone, FR-025); pricing kin deaths (fees are D1b; the
forced-swap veil owns that drama); XP/score/grades (no progression system
exists — parked); ledger history/log (one live beat, screen budget); sound on
the beat (fiction-bound audio identity waits on the bible).
