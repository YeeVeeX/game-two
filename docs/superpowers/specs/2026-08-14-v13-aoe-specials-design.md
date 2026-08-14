# v13 — TIBIA AOE SPECIALS (B+D): clump-payoff + challenge-retarget

Scope authority: CLAUDE.md scope contract (debate closed 2026-08-14, owner
accepted all three dev recommendations). Dossier:
`drafts/_tibia-aoe-research-20260813.md` (legs B+D only; A/C/E parked).
Oracle: the ELEVENTH blind ask — **did density become YOUR weapon**.

**Fork closure note (governance):** the owner delegated fork closure
mid-session 2026-08-14 ("continúa de manera autónoma") — every fork below
is closed on dev recommendation, DOCUMENTED for owner veto at the eleventh
debrief. Additionally three owner directives arrived mid-session and are
IN scope by owner order: (1) localization ES/EN/PT-BR, (2) collaboration
with Junior on `junior-tibia` (branch model change: junior-tibia =
collaborative line, pushed; main = solo backup), (3) shared-play roadmap
decision recorded (lockstep-over-Tailscale staged path; GameLift rejected;
v14 lead — NOT in v13 code).

## Why this is the increment

v11 built the dense field; v12 gave it an arc. Tenth verify: headline
moved twice, but the swarm is still only a THREAT — the owner died 21
times carrying 58–144 value, and q6_margins proved trips are
maintenance-forced. B+D is the player-side cash-out of density (Tibia
team-hunt meta: the knight challenges the pile, the damage role bursts
it). Density stops being weather and becomes ammunition.

## Scope (one increment + three routed lanes + two owner-directive lanes)

IN: (B) clump-payoff whirlwind on the striker; (D) challenge on the
blocker (taunt evolved); maintenance-economics data dose; drift
instrumentation (structural DECISION deferred to v14 with data); guard-
scope live-wanderer steering (fairness only); i18n locale layer
(en/es/pt-br) + Junior onboarding doc. OUT (recorded in PARKING_LOT):
elemental legs A/C/E; the Challenger (4th decline); zone 3 beyond the
stair; Nest rename; any netcode/multiplayer code (v14 staged path);
AI-cast specials; new bindings; player-visible special names; Amazon
Translate pipeline (authored translations at this string count); a third
blind drift dose.

## Design forks — closed on dev recommendation (owner veto at debrief)

1. **Kit placement: B → striker, D → blocker.** The blocker IS the
   owner-requested exeta body (A0.6 verbatim: "an exeta res-like spell to
   pull aggro"); challenge is its `amp` evolution — same verb, war-cry
   scale. The striker gets the melee cash-out (Tibia `exori` shape:
   AoE around self). The lobber — the body that dies carrying — is the
   one D PROTECTS, not the one casting: the swap dance (Tab → challenge
   → Tab back) is the possession identity working as designed. Lobber
   volley untouched.
2. **B replaces the striker dash** (scope law: one special per kit, L/E
   binding, no third special). WATCHED RISK, pre-registered as eleventh
   Q4: the dash was the striker's gap-closer/escape; the whirlwind's
   radial knockback is the new escape valve. If the owner mourns the
   dash, v14 re-opens placement — the whirlwind mechanism survives
   either way.
3. **Cost model: exhaust-frames only.** Exhaust is the game's single
   cadence gate (creature law 1); no banked/economy cost on specials —
   coupling combat cadence to the economy would muddy both. Costs live
   in `data/balance/combat.json`.
4. **Clump formula: flat per-target damage + exhaust refund per extra
   target.** `damage: 30` per victim; `refund_frames_per_extra_hit: 120`
   off the `exhaust_frames: 480` clock, floor 0 (hit 1 → 480; 2 → 360;
   3 → 240; 4 → 120; 5+ → ~0, spin again). Density literally powers
   cadence — the formula the oracle question asks about. Single-target
   use is deliberately punished (30 dmg vs the dash's 50): seek clumps.
5. **Challenge numbers: radius 9, duration 450, cause `challenged`.**
   Up from taunt's 6/300. Radius 9 ≈ the aggro bubble (aggro_tiles 10)
   — a room-scale shout, not a bump. 450 frames = 7.5 s: swap stagger
   (20) + post-swap wait (25) + reposition + whirlwind windup (6) fits
   with margin. Victims get the existing retarget cue with the new
   cause; beachhead waiver rides taunt! unchanged.
6. **Lanes (see own sections):** maintenance dose = tribute dead-price
   `regrow_cost` 12→9 (data-only); drift = instrument now, decide at
   v14 (two blind doses failed; the missing ingredient is measurement,
   not a third guess); guard-scope = idle-wanderer steering off the
   newest player corpse, engaged humans untouched (fairness, never
   difficulty — difficulty stays pinned by owner verdict).
7. **i18n: authored translations, no Amazon Translate.** ~8 player-
   visible strings exist (4-5 zone names, breach line, wipe line).
   Machine-translating canon is the exact slop the de-slop rule names;
   the dev authors ES/PT-BR in bible register, owner reviews ES at the
   debrief, Junior reviews PT-BR. Translate pipeline re-opens if the
   string count ever passes ~50. (Owner authorized Translate — declined
   on quality, not cost.)
8. **Locale mechanics: display-only, harness-pinned.** `data/display.json`
   gains `"locale": "en"`; `GAME_LOCALE` env var overrides (bin/play
   flag). THE LAW: the replay/gate harness FORCES locale `en` regardless
   of config — translated text must never touch gate captures
   (comparability reset law, same as the Nest rename). At locale `en`
   the fallback chain returns today's exact strings. (Precision, Codex
   fold: "same strings" is the claim — gate determinism is same-run
   double-replay md5, which locale never touches; check SEMANTICS are
   what stay comparable, not v12 PNG bytes.)

## Sim spec (all numbers in data/, zero balance constants in Ruby)

### 1. (B) Striker whirlwind — `data/balance/combat.json` striker.special

```json
"special": {
  "damage": 30,
  "windup_frames": 6,
  "active_frames": 4,
  "recovery_frames": 8,
  "exhaust_frames": 480,
  "arc": "ring",
  "knockback_tiles": 1,
  "refund_frames_per_extra_hit": 120
}
```

- Arc `ring` reuses the blocker's tile resolution
  (`world.rb resolve_tile_action`, action_tiles = 8 neighbors). No new
  resolution machinery.
- Refund: applied at the **active→recovery transition** (the one moment
  `@hit_victims` is complete and not yet cleared — Codex fold: normal
  completion runs through `interrupt_action!` which CLEARS the list, and
  `take_hit` can clear it earlier). Count distinct victims at that
  instant; `special_exhaust` -= `refund * (hits - 1)`, floored at 0.
  An interrupted spin (windup or active — striker `interrupt_on_hit`)
  refunds NOTHING: exhaust burnt, dash precedent. "Don't get hit
  mid-spin" is a readable rule. Creature-owned, swap-inert.
- Knockback 1 radial (each victim pushed along its own offset from the
  striker) — the escape valve that replaces the dash, and the Vlambeer
  read: the pile POPS outward.
- No stagger (control is the blocker's identity, damage is the striker's).
- Dash plan machinery (`@dash_plan`) stays in code for the arc grammar
  (dead config path) — removing it is refactor noise v13 doesn't need.

### 2. (D) Blocker challenge — `data/balance/combat.json` blocker.special

Ring damage/knockback/stagger UNCHANGED (30 / 2 / 45 — the slam identity
that A0.6 fun-verified). The `taunt` sub-config is RENAMED and evolved:

```json
"challenge": {
  "range_tiles": 9,
  "duration_frames": 450,
  "pulse_frames": 20,
  "cause": "challenged"
}
```

- `resolve_taunt_pulse` (world.rb:473) reads the `challenge` block;
  `Creature#taunt!` gains a `cause:` param (default `:taunt` for
  backward compat in tests), stored victim-side.
- `AiController#select_target` returns `[bound, stored_cause]` instead
  of the literal `:taunt` — `:human_retargeted` telemetry then reports
  `challenged` with zero new plumbing (world.rb:399 already emits the
  cause it gets).
- ~~Victims fire the existing `retarget_cue!` with cause `challenged`~~
  **AMENDED at TDD:** the cue system deliberately EXCLUDES taunt-family
  causes ("taunt/anchor turns carry their own tells" —
  world.rb assign_human_focus). Challenge tells RIDE the fun-verified
  A0.6 grammar: rust underline on victims + the expanding pulse (now
  radius-9 sized, free from `range_tiles`). The cue's else-branch still
  invalidates stale cues on a challenged turn — no new palette entry.
- Internal naming: `taunt!`/`taunted_target` method names STAY (the
  mechanism is a taunt lock); only the kit config key renames to
  `challenge`. Player-visible names: NONE (de-slop: dash/volley/ring
  have none today; B and D ship equally nameless).
- **Plumbing folds (Codex cross-vendor review, 2026-08-14):** (a) the
  JSON `"cause"` arrives as a String — `.to_sym` at config read; the
  telemetry cause whitelist (telemetry.rb:13) gains `:challenged`;
  (b) the retarget-cue stamping path (world.rb:404) and the cue palette
  (renderer.rb:62) must both admit the `challenged` cause or the cue
  silently never draws; (c) renderer.rb:442 dereferences
  `kit[:special][:taunt]` for the possessed underline — update to the
  `challenge` key in the same commit or the HUD crashes.
- **Watched risk (pre-registered, Codex Q6): challenge × engaged cap.**
  `engaged_cap_per_target: 5` means a radius-9 challenge parks every
  attacker beyond 5 in the passive pressure ring — the blocker never
  faces more than 5 swings, and the striker can whirlwind a passive
  ring for near-free refunds. This is ALSO the design intent (Tibia:
  exeta + volley the pile), so v13 ships today's fun-verified exhaust
  (600, one-variable law) and does NOT pre-nerf. Routing: if the
  eleventh reads "too easy" anywhere (Q1 verbatim, difficulty remarks,
  wipes collapsing vs tenth's 14), the challenge lever order is
  exhaust up → duration down → radius down, never the engaged cap
  (that's the fairness mechanism).

### 3. Maintenance-economics dose — `data/balance/economy.json`

`regrow_cost` 12 → 9. Rationale from q6_margins (tenth): 1.3 dead +
1.7 wounded at bank time → mandatory spend ≈ 1.3×12 + 1.7×2 = 19/trip;
at 9 it drops to ≈ 15 (−21%). The dominant term is the dead-body price,
so it is the lever; wounded price (2) and inscribe (8) unchanged — one
variable per dose. Coupled effect stated for the record: D should CUT
attrition (fewer carrier deaths → fewer dead at bank), so the dose and
the mechanic push the same direction; the eleventh Q5 re-read judges the
sum, and telemetry (q6_margins) attributes it. **Two-sided risk (Codex
fold): maintenance is player-triggered, so a cheaper tribute lowers the
affordability threshold and could INCREASE trip frequency.** q6_margins
`gap` (seconds between banks; tenth baseline mean 83 s) is the arbiter:
gap up = dose worked; gap down with Q5 "still too often" = dose
backfired, revert to 12 and the lever moves to regrow cadence at v14.

### 4. Guard-scope live-wanderer steering (fairness only)

Problem (tenth Q7, second occurrence at guard 10): respawns respect
`corpse_guard_tiles` but LIVE wanderers may loiter on the corpse.

**Design (REDESIGNED at the Codex fold — the naive steering-step rule
oscillates):** `leash_home` walks every no-focus human toward its
`home_tile`; a human steered one tile off a home that sits inside the
guard radius walks straight back — steer/leash oscillation, plus
leash-state churn across replays. Fix at the DESTINATION instead: while
a pack corpse exists, a human whose `home_tile` lies within
`corpse_guard_tiles` (reused, 10) of the NEWEST pack corpse leashes to a
**shifted home** — the nearest walkable tile outside the guard radius
along the home→away-from-corpse ray (fixed STEPS order tiebreak =
deterministic). Corpse gone → true home restores. One rule, no per-tick
steering, no oscillation. Humans WITH focus are untouched (leash only
runs no-focus) — this cannot soften a fight. No new numbers. Telemetry:
`steered` = count of leash arrivals at a shifted home (a2 line).

### 5. i18n locale layer

- `data/strings/en.json`, `data/strings/es.json`, `data/strings/pt-br.json`
  — flat key → text maps. Keys: `zone.<name>.display_name` per zone,
  `breach.line`, `wipe.line`.
- New `Core::Strings` (or `Game::Strings`) resolver:
  `t(key, fallback)` → locale text, else fallback (the current EN
  literal from zone JSON / en.json). Locale from `GAME_LOCALE` env var,
  else `display.json "locale"`, else `en`.
- Renderer's hardcoded `"THE HUNT ENDS"` moves to `strings/en.json`
  (`wipe.line`) — kills the last hardcoded player-visible literal
  (fiction-pending note resolved: the line is now data the bible pass
  can retitle without code).
- Zone JSONs keep `display_name` (canonical EN + fallback) — zone
  identity stays in the zone file.
- Harness: the replay runner sets locale `en` explicitly before window
  construction. Gates never see translated text.
- Authored translations (bible register, owner/Junior review):
  - The Second Vigil → ES "La Segunda Vigilia" / PT "A Segunda Vigília"
  - The Keyward → ES "El Guardallaves" / PT "O Guarda-Chaves"
  - The Slow Door → ES "La Puerta Lenta" / PT "A Porta Lenta"
  - The Nest → ES "El Nido" / PT "O Ninho" (rename still parked; the
    translation tracks whatever EN says)
  - THE WAY IS PAID → ES "EL PASO ESTÁ PAGADO" / PT "A PASSAGEM ESTÁ PAGA"
  - THE HUNT ENDS → ES "LA CACERÍA TERMINA" / PT "A CAÇADA TERMINA"
  - District One → ES "Distrito Uno" / PT "Distrito Um"
  (all five zone display_names verified against data/zones/ 2026-08-14).
- `bin/play` accepts a locale arg (`bin/play es`) → exports GAME_LOCALE.
  Junior runs `bin/play pt-br`. Zero AWS anywhere in the player path.

### 6. Junior onboarding (docs, no sim code)

`docs/JUNIOR.md`, PT-BR first + EN mirror: RubyInstaller 3.4.10 WITH
MSYS2/devkit (gosu 1.4.6 compiles from source — the Gemfile.lock trap,
stated loudly), `bundle install`, `bin/play pt-br`, controls table,
branch convention (never push main; junior-tibia is the shared line;
PRs welcome), replay exchange how-to (rake capture + harness scripts =
"watch each other's runs" stage 0 of the shared-play roadmap).

### 7. Events

- ~~`+:special_cast`~~ **AMENDED at TDD: no new event.** `:special_started`
  already exists with payload `attacker:` (begin_action emits it) —
  telemetry derives kit/kind from the attacker. Defining a duplicate
  would violate the event law's spirit. `:attack_hit` payload gains
  `kind:` + `landed:` (stamped at EMIT time — sim-exact even if the
  action state transitions before the bus processes).
- `:human_retargeted` gains cause value `challenged` (existing event,
  new cause symbol in the telemetry whitelist).

### 8. Telemetry (subscriber-side; harvested BEFORE the eleventh's questions)

New `v13` line + drift instrumentation, formats pinned here:

```
v13: whirl{casts=N hits{1=N 2=N 3=N 4=N 5plus=N} kills=N}
     challenge{casts=N retargets=N}
a2:  retargets{... challenged=N}                    (existing line, new key)
a2 (leash event): steered flag -> steered episodes counted per lane test
drift: thirds{k1=N k2=N k3=N} pockets{p1=F p2=F p3=F}
```

(AMENDED at TDD: `refund_zero_casts` dropped — redundant, 5+ hits always
floors the refund, so `hits.5plus` IS that count.)

- `whirl.hits` histogram = the oracle's hard number: a fat 3+/cast tail
  means density became ammunition; a 1-spike means B is being used as a
  worse dash.
- `challenge.casts` × `d1.carrying_deaths` (existing) = D's story: casts
  up + carrying deaths down (tenth baseline: 21) is the win condition.
- `drift.thirds` = session split in sim-frame thirds (tick-locked, so
  frames ARE time); kills and mean pocket size per third. The v14 structural decision reads this curve
  (ninth+tenth said "drifts at the end" — this measures WHERE and HOW
  MUCH, replacing guess three).

### Perf

Whirlwind = 8-tile iteration (existing ring path); challenge = one
radius-9 hostiles scan per cast (player-triggered, not per-tick);
steering = one Chebyshev check per idle human per step. No new per-tick
O(n²). Budget unchanged: p95 < 16.6 ms (baseline 0.337).

## Presentation spec (Rule 2 surface)

- **Whirlwind:** victims pop radially (knockback 1 all 8 directions);
  per-victim hit flash + the existing kill hitstop stacking on
  multi-kills (crescendo comes free from feel.json); no new HUD element.
  The special-ready pip (HUD, existing) is the refund's readout — a
  clump-hit visibly re-arms it.
  **Render identity (workflow-review CONFIRMED fold): the whirlwind's
  ring tiles draw in the striker's LUNGE_ACTIVE bright color, NOT the
  shared SPECIAL_ACTIVE** — renderer.rb's dash branch owns that color
  today; the ring-else branch would make striker and blocker specials
  visually identical (same color, same 8-tile pattern), failing check
  14's "three specials must not look like one" clause. Three specials
  stay three visuals: striker = bright ring burst, blocker = warm ring
  + taunt pulse, lobber = volley line.
- **Challenge:** the blocker's ring flash renders at challenge radius
  (one frame-family pulse, reuse ring visual scaled); every victim shows
  the existing retarget cue glyph. Readability law: a challenged room
  visibly TURNS.
- **i18n:** locale es/pt-br renders translated banner/breach/wipe lines;
  en renders today's exact strings (unchanged draw calls).

## Harness + gates

- **New script: `aoe_specials.json`** (pilot-authored post-TDD; pilot
  doctrine from `drafts/_v12-wall-log.md` applies — hold-into-body,
  lane chokes, never goto toward mass). Mandatory beats: a challenge
  cast with ≥3 victims' cues on camera; a whirlwind into a ≥3 clump
  (radial pop frame); the re-armed special pip after a clump hit
  (refund readable); a carrying escape (challenge → carrier walks out).
- **Checks 42 → 44, ADD-ONLY:**
  - `whirlwind_reads`: "A striker burst shows multiple adjacent victims
    reacting in the same frame (flash/knockback outward) — the spin
    reads as one area hit, not serial pokes. If no whirlwind is
    exercised in this script, pass."
  - `challenge_reads`: "After a blocker challenge pulse, humans in the
    room visibly turn toward the blocker (facing/cue glyphs) within the
    cue window. If no challenge is exercised in this script, pass."
  (Self-gate clauses per the ratified c361ba3 wording; the new script
  exercises both for real.)
- **Check 14 (`specials_distinct`) wording UPDATE (workflow-review
  CONFIRMED finding):** its text names "Striker as a bright
  through-lane" — true of the dash, false of the whirlwind. Per the
  established ADD-ONLY reading ("existing never weaken" — c361ba3
  precedent: text follows behavior, count never drops, gates never get
  easier), the striker clause updates to "a bright ring burst" in the
  same commit that ships the whirlwind. Count stays 42 (+2 new = 44).
  Surfaced for owner ratification at the eleventh debrief alongside the
  fork table.
- **Known wall cost (MEASURED 2026-08-14, not guessed): exactly two
  scripts press `special`** — `specials_chain` (4 casts: dash→whirlwind
  movement delta = CERTAIN desync) and `taunt_anchor` (1 cast: CERTAIN —
  even with identical victims, the radius-9 pulse image changes captured
  pixels; Codex fold). No other script casts a
  special, so B/D cannot desync them. The regrow 12→9 dose changes
  `vat_economy`'s post-tribute banked numeral (its tribute is the final
  beat, nothing scripted follows — HUD-value change only; verify at
  triage). Re-pilot budget: 2 re-pilots + the new `aoe_specials` pilot. The regrow 12→9 dose changes HUD numerals in `vat_economy`
  (banked totals) — checks read presence, not values; verify at triage.
- Wall = 13 scripts total (12 existing + aoe_specials), sequential, ONE
  window at a time, verdicts from tmp/wall/*.log only.
- Determinism law: locale must not enter the sim. Strings resolve at
  RENDER time only; replays/gates pin `en`.

## TDD increments (each green-committed on `v13-aoe`)

1. **i18n layer**: Strings resolver + data/strings/*.json + wipe-line
   extraction + bin/play locale arg + harness pin + JUNIOR.md. Tests:
   fallback chain, en byte-identity (same string out), locale switch.
2. **(B) whirlwind**: striker special config swap + ring arc on striker
   + refund-on-completion. Tests: multi-victim damage, refund math
   (1/2/5 victims), floor 0, swap-inertness, single-target punishment.
3. **(D) challenge**: config rename+numbers, taunt! cause param,
   select_target stored-cause return, cue cause, :special_cast event.
   Tests: radius 9 collection, duration 450 expiry, cause telemetry,
   beachhead waiver intact, old-taunt tests updated to challenge key.
4. **Lanes**: regrow dose (data), guard-scope steering + steered
   counter. Tests: idle-only steering (engaged human NEVER steered),
   determinism (fixed STEPS order), corpse recency.
5. **Telemetry + checks**: v13/drift lines, a2 line extension,
   gate_checks 44, aoe_specials script installs after pilot.

## Fun-verify (ELEVENTH — BLIND; owner plays first, NO changelog)

Protocol unchanged (unique log per launch, harvest ALL telemetry before
any question, clean Esc flushes; preamble: "if you never used the new
specials, say so — those questions read as unexercised, not negative").
Owner may play in Spanish (`bin/play es`) — locale is display-only and
does not touch telemetry.

Questions (ask exactly these):

1. HEADLINE: when the field swarmed thick this time, did the swarm read
   as OPPORTUNITY — something you could cash out — or still as weather
   to survive?
2. The spin: standing inside a pile and bursting it — did that land as
   an earned payoff? Did you find yourself HERDING enemies into clumps
   on purpose?
3. The shout: when you got mobbed — especially carrying — did the
   blocker's challenge give you a real out? Did the swap dance (Tab →
   shout → Tab) feel like a plan or a chore?
4. The lost dash (watched risk): did you miss the striker's dash?
5. Money re-read: did banked value feel FOR something? The trips —
   still too often, or did the rhythm change?
6. Drift re-read: did the field stay worth fighting deep into the
   session?
7. Fairness: any respawn or camp feel unfair? Corpse camping again?
8. Entrainment (SIXTH read): scariest stretch — did your body react?

Routing (pre-registered):

- Q1 = the headline. Moves ("opportunity") → v13 WINS → v14 debate
  (leads: zone 3, Nest rename, multiplayer staged path). Doesn't move →
  the whirl.hits histogram arbitrates: fat tail + flat verdict = feel
  problem (presentation lane); 1-spike = design problem (placement fork
  re-opens, dash question weighs in).
- Q2 payoff + herding → no lane. Payoff-without-herding → the lure loop
  isn't priced; candidate lever = refund shape, NOT damage.
- Q3 real-out → carrying_deaths delta corroborates; chore → swap-dance
  friction lane (stagger/wait numbers), not challenge numbers.
- Q4 missed-dash → placement fork re-opens at v14 (mechanism keeps).
- Q5 → q6_margins attributes: mandatory-spend share down + trips still
  "too often" = distance/purpose lever (v14); spend share unchanged =
  dose too small (second dose allowed, same variable).
- Q6 → drift.thirds curve attached to the v14 structural decision
  REGARDLESS of the verbal answer (instrument-first law).
- Q7 camping again despite steering → guard lane escalates to a design
  investigation with the steering telemetry; "nothing unfair" →
  steering closes VALIDATED.
- Q8 sixth read: body reacted → Challenger stays unpromoted (5th
  non-confirm). Flat → dossier re-weighs at v14 (density+arc+specials
  all failed to entrain = the trigger's necessity finally has
  evidence).

## Deliberately absent (recorded so review doesn't re-litigate)

- Elemental fields/resistances/DoT (A/C/E) — parked, needs the C data
  layer; re-raise only if the eleventh routes "specials need variety".
- AI-cast specials — possessed-only tools, Tibia-faithful (the knight is
  a PLAYER).
- New bindings / third specials — scope law from the v12 OUT-list.
- Player-visible special names — de-slop; dash/volley shipped nameless.
- Amazon Translate — authored beats machine at 8 strings; documented
  above.
- Netcode/GameLift/lockstep code — v14 staged path, recorded in
  PARKING_LOT + memory; nothing in v13 code.
- A third blind drift dose — instrument-first; the structural decision
  is v14's with the drift.thirds curve in hand.
- Challenge on a non-blocker body / challenge-at-range — the blocker is
  the exeta body by owner ask lineage (A0.6); range challenge is a
  different (lobber-kit) design, parked with the elemental legs.
