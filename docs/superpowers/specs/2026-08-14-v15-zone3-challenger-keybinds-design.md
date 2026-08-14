# v15 — ZONE 3 + THE CHALLENGER + CONFIGURABLE KEYBINDS: The Low Quay, Varekka, the binding map

Scope authority: CLAUDE.md scope contract (debate closed 2026-08-14, owner
promoted all three increments via AskUserQuestion; the Challenger is the
owner's EXPLICIT call after six non-confirms). Design forks closed
2026-08-14 (owner via AskUserQuestion, all four on dev recommendation):
**(1) quay geography, NO stations below; (2) forced-approach seizure;
(3) bindings.json + gitignored local override; (4) names ratified**
(The Low Quay / Varekka / "ONE STANDS" / "THE FLESH IS CALLED").
Check amendments #14/#19/#42 RATIFIED at this session's opening (c361ba3
precedent closed).

Oracle: the THIRTEENTH blind ask — **did zone 3 feel like arriving
somewhere EARNED** + **did the Challenger SCARE you** (the first peak it
exists to create; the entrainment lane's eighth read rides inside it).

## Scope (three increments + lanes)

IN:
- **(a) Zone 3 — The Low Quay.** New zone `data/zones/low_quay.json`
  beyond the Slow Door: the corridor's first chamber under Silovun, an
  under-harbor hall with a central black channel. Densest field, richest
  gradient, ZERO stations (all value climbs home). Banner + locale
  strings.
- **(b) The Challenger — Varekka.** A unique named human (`challenger`
  kind) posted deep on the quay who force-taunts the player's possessed
  vessel: a 120f visible chant that, completed, SEIZES the named body —
  it walks to him against the player's will. Fairness ladder mandatory
  and built-in: visible tell, three counters (swap always works, damage
  interrupts the chant, his death ends everything). Dies once per
  session (no respawn). Three court-register beat lines.
- **(c) Configurable keybinds.** `data/bindings.json` (canonical) +
  `data/bindings.local.json` (optional, gitignored, per-machine) feed
  BOTH `Core::KeyboardInput` and the controls strip through one new
  `Core::BindingMap` — single source; the strip now shows primary AND
  secondary glyphs (the twelfth's owner lane, closed). Multiplayer-ready
  for v16 (per-machine config without repo conflicts).
- **Lanes:** ES/PT-BR locale strings for every new surface (authored
  here; owner ES pass + Junior PT-BR pass stay on the owner queue);
  docs/JUNIOR.md gains a "custom keys" section (PT-BR+EN); PARKING_LOT
  strikethroughs ride the close.

OUT (PARKING_LOT, unchanged): multiplayer spike etapa 1 (v16 LEAD);
dossier legs A/C/E; zone-3 sub-content beyond one chamber (deeper
chambers are future rungs); Varekka variants/phases; everything
long-parked.

All numbers in `data/`; zero balance constants in Ruby; checks ADD-ONLY
from 46 (→ 49). Suite stays green at every commit; full wall re-run
(comparability reset — decided here, see Harness).

## Design decisions (owner-fork outcomes + dev calls, numbered)

1. **Zone 3 = The Low Quay, stationless (owner fork 1).** One long
   under-harbor hall; a central channel band (wall tiles) with two
   bridge gaps creates lanes and chokepoints — geometry the Keyward's
   block grid never makes. NO bank/altar/vat below: banking a quay haul
   means climbing the stair and crossing the Keyward. Arrival is cheap;
   RETURNING CARRYING is the game (Tibia deep-hunt law; serves oracle
   half A directly).
2. **Seizure = forced approach (owner fork 2).** Chant 120f (the
   telegraph lead the player already reads) → the NAMED vessel walks
   toward Varekka for up to `duration_frames` (450, the blocker
   challenge mirror). While seized-and-possessed: movement + dodge are
   overridden, attack/special/mark/interact stay the player's. While
   seized-and-NOT-possessed (player swapped out): the body walks to him
   and stands adjacent, starting no NEW swings — already-committed
   actions resolve body-owned, as all actions do (Codex pass-2 wording
   fix: attacks never blocked Tab and keep resolving after possession
   moves). Counters: Tab swap ALWAYS works — now a BUILT exemption, not
   an assumption: today swap is refused while staggered or
   special-committed (world.rb:500-511), so a crew hit staggering the
   seized body would trap the player inside it, silently breaking the
   ratified fairness ladder (Codex pass-2 CONFIRMED defect). While the
   possessed is seized, swap bypasses the stagger and special-commit
   gates (TDD test: staggered seized body + Tab → swap succeeds). Any
   damage to Varekka during the chant interrupts it; Varekka's death or
   the seized body's death ends the seizure instantly. Seizure survives
   distance — he called; it comes.
3. **Chant targets the BODY, pinned at chant start.** A swap mid-chant
   does not re-aim the sentence (he spoke THAT body's making-name).
   Deterministic and fiction-exact.
4. **Varekka is unique per session.** `challenger` kit omits
   `respawn_frames` — `schedule_human_respawn` already handles a
   no-respawn kit (M2 review finding 2, latent until now, exercised at
   last). Killed = "THE TERM IS PAID"; a fresh World (restart)
   restores him. He drops a single fat drop (data).
5. **Binding map = names, one source (owner fork 3).**
   `data/bindings.json` maps action → ordered key-name array (first =
   primary). Optional `data/bindings.local.json` overrides per ACTION
   (whole-array replace, not element merge). `Core::BindingMap` owns
   the key-name → Gosu-constant table (platform mapping, not balance —
   the GLYPHS-constant precedent, now retired), resolves codes for
   `KeyboardInput`, and serves display glyphs to the strip. Unknown key
   name or unknown action in either file → raise at load with the valid
   list (fail loud at startup, never mid-session).
6. **Names are canon, ratified (owner fork 4).** Zone: **The Low Quay**
   (the *silov* — river-door — Silovun is named for: the under-quay
   where the barged dead land and enter the corridor; dark since the
   interdict; the Unpaid broke in to strip grave-goods from the landed
   dead — the gradient's in-fiction source continues). Challenger:
   **Varekka**, a Kadravai wardsman-captain — a struck name whose THIRD
   syllable is earned only by standing a night watch alone (§2.4): the
   name itself says "this one is different". He carries the suvrim's
   making-clauses, stripped from Silovun's audit-frozen roll-rooms, and
   pronounces them in the deep register: the flesh answers its name
   (the Dravessa precedent, §12.1 — she read the golems' enrollment
   clauses and they knelt). His tell IS pronunciation: "a name
   mispronounced is a door knocked on at the wrong house" — he must
   stand and say it slowly, exactly. Court lines (v12 UI-voice law:
   nothing on screen speaks for the Unpaid — these are the court's
   stamps): first engagement **"ONE STANDS"**; first chant **"THE FLESH
   IS CALLED"** (mirror of THE FLESH IS SPENT); his death **"THE TERM
   IS PAID"** (mirror of THE WAY IS PAID — the term-looter finally pays
   the term's price, the exact obscenity the v12 annex charges the
   Unpaid with. REPLACES the drafted "THE NAME IS STRUCK", which Codex
   pass-2 CONFIRMED as a canon violation: an ordinary death leaves the
   name with the living (bible §5.2); striking a name is Registry full
   liturgy or the Maw's second death — the court would be stamping a
   false theological event. Authored post-fork under the same veto
   window at the debrief — flag the swap to the owner explicitly).
7. **Difficulty stays pinned EXCEPT Varekka and his ground.** Existing
   kits, spawns, prices, telegraphs: untouched. The quay's density and
   Varekka's numbers are the increment's own tuning surface (all in
   data).

## Sim spec

### 1. Zone: `data/zones/low_quay.json`

- Footprint ~46×21. West end: the stair landing (arrival from
  slow_door). A central channel band (2 rows of wall tiles) runs
  east-west with TWO bridge gaps (3 tiles wide) — north lane, south
  lane, crossings. East end: the far landing, Varekka's post.
- `transitions`: `{ "at": [west landing tile], "to": "slow_door",
  "spawn": [7, 2] }` (back up the stair; NOT sealed — the way was paid
  at seal2). `data/zones/slow_door.json` gains the DOWN transition:
  `{ "at": [7, 1], "to": "low_quay", "spawn": [west landing] }`, also
  unsealed. Both new transitions carry no seal stations — zero new
  economy verbs.
- `enemy_spawns`: `rusher` ~22 spawns, `rusher_hater` ~7 (hater ratio
  ~1:3 vs the Keyward's 1:4 — wardsmen-heavy per the fork), spread
  along both lanes and past the bridges; `challenger` exactly 1, at the
  east landing. Exact tiles at TDD, judged by the critic + pilot.
- `drop_gradient`: `[[0, 3.0], [15, 3.5], [30, 4.0]]`,
  `gradient_anchor` DECLARED at the west landing (the v12
  arrival-order re-anchor trap's own remedy — never rely on the
  fallback for a new zone).
- `stations`: `[]` (fork 1). No seal, no bank, no vat, no altar.
- Palette: deep indigo-black floor (`[10, 10, 16]` family), slate-bone
  walls/colonnade, gold seams on the transition tiles only. Distinct at
  a glance from the Keyward's black-and-ochre and the Longrow's gray
  (checks §Harness). Exact RGB at TDD under the critic.
- `display_name`: "The Low Quay"; string overrides
  `zone.low_quay.display_name` in en/es/pt-br.

### 2. Challenger kind: `combat.json` `kits.challenger`

```
"challenger": {
  "max_hp": 140,
  "step_frames": 16,
  "aggro_tiles": 10,
  "drop_table": [8],
  "attack": { melee, modest: damage 15, windup 20, active 6,
              recovery 0, exhaust 66, arc "ring", knockback 1 },
  "seize": {
    "chant_frames": 120,
    "range_tiles": 7,
    "duration_frames": 450,
    "cooldown_frames": 600,
    "cause": "seized"
  }
```

Cooldown START (panel fold — the 4x pacing ambiguity): the cooldown
clock starts at SEIZURE END (`:seizure_ended`), not at chant
completion — concurrent clocks would let him re-chant ~150f after a
full seizure (relentless); sequential gives a full 600f of ordinary
wardsman between seizures (one-session pacing). On interrupt, the
cooldown starts at the interrupt (as already specified).

```
}
```

- NO `respawn_frames` key — unique per session (decision 4).
- His base attack is deliberately ordinary (a wardsman's swing, rusher
  family numbers) — the seize is the threat, not stats.
- All values above are OPENING numbers; the pilot + thirteenth verify
  tune them in data only.

### 3. Seize behavior (world + controllers)

- **Trigger** (world-side, tick_humans altitude — the taunt-pulse
  precedent): Varekka alive, not staggered, chant cooldown expired,
  possessed within `range_tiles` (Chebyshev; no LOS gate — the name
  needs no line of sight, and the counter set is already rich) →
  enter CHANT: he stops (movement + attack suppressed), a chant clock
  runs `chant_frames`; emit `:challenger_chant_started` with the pinned
  target body (the possessed AT THIS FRAME — decision 3).
- **Interrupt:** any damage to Varekka while chanting cancels the chant
  (emit `:chant_interrupted`), starts the full cooldown (interrupting
  BUYS the room 10 seconds — legible reward). Stagger/knockback effects
  ride the same path (damage implies them today).
- **Completion:** emit `:vessel_seized`; the pinned body (if alive AT
  CHANT-COMPLETION altitude) gains seized state: `seized_by` = Varekka,
  `seized_left` = `duration_frames`. If the pinned body died BEFORE
  completion in tick order, the sentence lands on nothing (no event
  beyond the chant's own; his cooldown runs). Same-frame race, defined
  (Codex pass-2): chant completion runs at human-tick altitude, before
  impacts/attacks/projectiles resolve — a body can legally receive
  `vessel_seized` and die later in the SAME frame; the death path then
  fires `seizure_ended why=:died` (a zero-frame seizure, both events
  real and ordered). Seizure end is IDEMPOTENT and exactly-once: state
  cleared on first end-cause, later causes find no state and emit
  nothing (arbitration for died-then-wiped same-flush sequences).
- **Seized movement:** each tick the seized body is due a step (its own
  kit cadence), it steps DOWNHILL on the EXISTING `flow_to(varekka)`
  moving-anchor cache (body-blocking respected — a crowd can stall the
  walk; the stall is mercy, recorded not fought). Forced steps route
  through `creature.step`, which refuses during windup/active attack
  states and stagger (creature.rb:98-99) — so ATTACKING WHILE SEIZED
  SLOWS THE DRAG (your swings plant your feet). Recorded as intended
  depth, not a bug: fighting back literally drags your feet (Codex
  fold 4 — the step-gate interaction made explicit). Possessed:
  directional input + dodge are ignored while seized;
  attack/special/mark/interact resolve normally (the hands are yours;
  the feet are his). Non-possessed seized body: AI tick replaced by the
  same approach; adjacent to Varekka it stands and waits (no swings —
  it answered its name).
- **End:** `seized_left` expiry, Varekka's death, or the body's death →
  emit `:seizure_ended` (payload carries why: expired/slain/died).
  Seizure does NOT break on distance (decision 2).
- **Lifecycle folds (self-review + Codex pass-2):** (i) `enter_zone`
  ends every active seizure and aborts a running chant
  (`seizure_ended why=:zone_left`) — the whole pack teleports through
  gates via `arrival_tiles`, so a seized body would otherwise cross
  zones with dangling state (the `@taunt_pulses`/`clear_mark!` clearing
  precedent, world.rb:785-790). (ii) The wipe clears chant + seizures
  AT `:nest_respawn` ENTRY (the wipe-detection moment), NOT inside
  `respawn_pack` — `:nest_respawn` bypasses `tick_world`, so a chant
  aborted only at respawn would FREEZE mid-count under the veil (Codex
  pass-2 CONFIRMED); `why=:wiped`. (iii) Chant and seize clocks tick
  inside `tick_world` — hitstop pauses them like every combat clock.
  (iv) Controller ordering pin (Codex pass-2 mask finding): input edge
  bookkeeping (`pressed?` history) runs UNCONDITIONALLY every tick;
  seizure vetoes only the resulting movement/dodge APPLICATION — a
  dodge pressed during seizure must not ghost-fire on expiry (the
  rearm-mask law extended). (v) Knockback contract: a knockback dash
  interrupts an in-flight seized step and WINS (creature.rb:177-184
  behavior unchanged); the seized walk resumes after settling —
  contractual and tested, not incidental. (vi) The wipe floor's
  possession snap onto a dead-then-revived vessel meets idempotent
  seizure end (the exactly-once law above) — no double
  `seizure_ended`.
- **Pathing cost (pre-answered):** the seized walk calls the EXISTING
  `flow_to(varekka)` moving-anchor cache (world.rb:303-311 — recomputes
  only when the anchor's tile changed, pruned on death, cleared on zone
  change). Zero new field machinery; the chase_step cost class the sim
  already pays.
- **First-engagement beat:** the first frame Varekka acquires the
  possessed as focus (per session) → emit `:challenger_engaged` (drives
  the "ONE STANDS" banner + telemetry).
- **EVENTS whitelist ADD (non-negotiable 4):** `challenger_engaged
  challenger_chant_started chant_interrupted vessel_seized
  seizure_ended` (5 new).
- **Taunt interplay (registered):** the player's blocker challenge can
  taunt Varekka — taunt binds his ATTENTION (focus), not his voice: a
  taunted Varekka still chants if the possessed is in range. Damage,
  not attention, is the interrupt (fairness ladder stays 3-countered).
  His seize and the blocker's challenge share no state.

### 4. Binding map: `src/core/binding_map.rb` (new, ~60 lines)

- `Core::BindingMap.load(data, key_table:, local:)` reads
  `data["bindings"]`, deep-merges `data["bindings.local"]` per action
  when `local: true` and the file exists (whole-array replace per
  action key).
- **Layer split (panel fold — HIGH):** `src/core/` is engine-agnostic
  today (zero Gosu references; test/core runs headless with integer
  key codes). So BindingMap does NOT own Gosu constants: it validates
  names, merges, and serves glyphs; the name → Gosu-constant
  `KEY_TABLE` lives in `src/app/` (where `BINDINGS` lives today) and is
  INJECTED into `BindingMap.load(key_table:)`. Tests inject a fake
  table (name → integer) — the input_test.rb FakeBackend precedent.
  window.rb gains ~3 lines, still far under the cap. Key-name set:
  "A"–"Z", "0"–"9", "Up/Down/Left/Right", "Space", "Tab",
  "LShift/RShift", "LCtrl/RCtrl", "LAlt", ";", ",", ".", "Enter" —
  extending it is a one-line PR. Unknown name/action → raise with the
  valid list at startup.
- **Post-merge collision check (panel fold):** after canonical+local
  merge, a physical key bound to MORE THAN ONE action raises with the
  key and both action names — Junior's most likely mistake (rebinding
  `mark` to a letter the canonical map already uses, e.g. "W" = up)
  would otherwise dual-fire silently every frame.
- **Startup-raise visibility (panel fold — HIGH):** both launchers
  redirect stdout+stderr to a temp log (`bin/play.cmd`:
  `> "%TEMP%\game_two_session_....log" 2>&1`), so a config raise would
  flash-and-close the window with the message buried in an
  obscure file — defeating "fail loud" exactly for the person it
  serves (Junior double-clicking play.cmd). Fold: on nonzero exit,
  `play.cmd` echoes the log path + tail and `pause`s; `bin/play`
  (bash) prints the log tail. Documented in JUNIOR.md's custom-keys
  section (rides TDD increment 2).
- Serves `codes` (action → [Gosu ids]) to `KeyboardInput` and
  `glyphs(action)` (→ ["J","Space"]) to the strip. `window.rb` loses
  the `BINDINGS` constant; `controls_overlay.rb` loses `GLYPHS` (its
  own comment promised exactly this: "a reverse-lookup earns its keep
  only when rebindable controls exist").
- `data/bindings.json` ships today's exact defaults (CLAUDE.md Controls
  section verbatim). `.gitignore` gains `data/bindings.local.json`.
- **Layout caveat (documented in the file header comment... no — JSON
  carries no comments: documented in docs/JUNIOR.md):** Gosu/SDL
  scancodes are POSITIONAL (the a0.5 spec's own F6 note) — on a
  non-US layout (Junior's ABNT2) the ";" physical position differs.
  The local override IS the remedy: rebind `mark` per machine. This is
  why fork 3 chose the override file, stated so Junior's first
  confusion has a written answer.
- Esc (quit) stays window-level, unbindable by design.
- Replays/pilot: `ScriptedInput` drives abstract actions — bindings
  never touch SIM determinism. But the STRIP renders glyphs from the
  map, so **the harness pins bindings canonical** (Codex pass-2 Q8
  catch): replay/pilot/gate construct `BindingMap` with the local
  override DISABLED (`local: false`) — otherwise a machine-local
  bindings.local.json changes every capture on that machine while
  `rake gate` (two runs, same machine) falsely passes, silently
  poisoning cross-machine comparability (Junior's wall runs, the v16
  replay-exchange path). The locale=en harness pin is the exact
  precedent (gate comparability law). Live play (`bin/play`) is the
  ONLY consumer of the local file.

### 5. Telemetry (thirteenth arbiters)

New summary lines (`telemetry.rb`):
- `quay{entries=N frames=N kills=N deaths=N banked_after_quay=N}` —
  entries/frames from `zone_entered`; kills/deaths while zone ==
  low_quay; banked_after_quay = banked events whose immediately
  preceding zone path included low_quay this trip (implementable as:
  bank while a `visited_quay_this_trip` flag is set; flag sets on quay
  entry, clears on bank/wipe).
- `varekka{engaged=0|1 chants=N interrupted=N seized=N swap_escapes=N
  slain=0|1 deaths_while_seized=N}` — swap_escapes counted from the
  EVENT SEQUENCE (a `possession_changed` arriving between
  `challenger_chant_started` and that chant's terminal event, or
  between `vessel_seized` and its `seizure_ended`), never by inspecting
  live chant/seize state at handler time — the bus flushes after the
  whole tick, so state inspection misses same-frame escapes (Codex
  pass-2 telemetry race).
- Existing lines (whirl, telegraphs_shown, span_thirds, q6_margins,
  d1b_fired, arc) continue untouched — cross-session comparability.

## Presentation spec (Rule 2 surface)

1. **The stair reads as DESCENT.** The slow_door → low_quay transition
   uses the existing gold transition grammar; the Low Quay banner
   ("The Low Quay", banner path, existing draw) + the palette shift
   (indigo-black + slate-bone) land the arrival in one frame. The quay
   reads as an under-harbor: the DRY channel band (slate-bone stone bed
   — the rites stopped, the water stopped) + bridge gaps are the zone's
   signature geometry — no new draw primitives.
2. **The chant is DEEP SATURATED BLUE.** Chant tell: an
   expanding-contracting hollow BLUE ring centered on Varekka for the
   full 120f (the taunt-pulse draw grammar, new color) + a small hollow
   blue square floating above the NAMED vessel (god-mark grammar, blue
   not pale-gold). Collision audit (panel-corrected — the draft's
   "virgin family" claim MISSED one blue already on screen): the
   proximity retarget cue is blue-PALE washed-out (180,210,250,
   renderer.rb:66). The chant family is therefore deep/saturated
   (60,100,220 family — high saturation, low value; exact RGB at TDD
   under the critic), separated from the cue by saturation and size
   (8px block vs body-scale ring). Everything else stays clear: taunt
   = rust square, respawn tell = teal-green ground, telegraph =
   red/yellow, volley = orange brackets, drops = magenta/gold,
   possession = white ring.
3. **Seizure state = blue underline** under the seized body — the exact
   mirror of the taunt's rust underline, inverted meaning the player
   already knows how to read: rust = "they are bound to come to you";
   blue = "your flesh is bound to go to him". Coexists legibly with the
   white possession ring (underline vs full-body outline).
4. **Varekka reads as a PERSON, not a variant.** Pale bone body (human
   family), but taller silhouette (1 extra pixel row scale via existing
   human draw params if cheap — else same body + permanent thin blue
   trim), and he is the ONLY human with a nameplate: "VAREKKA" in small
   bone type above him when on camera (banner-font path, tiny size).
   One new draw detail, justified: the increment IS "a named human".
5. **Court stamps in the banner slot** (existing banner path, existing
   timing keys): "ONE STANDS" on first engagement; "THE FLESH IS
   CALLED" on the first completed chant of the session; "THE TERM IS
   PAID" on his death. Gate-gold type like THE WAY IS PAID.
6. **Strip dual glyphs:** primary glyph bright (current GLYPH_RGB),
   "/" separator + secondary glyph at label tone (dim). Vessel name +
   6 pairs must fit 960px: if the pilot shows crowding, tune
   `overlay_font_size`/gaps (display keys) — never drop a pair.
7. Zero sim reads from the renderer (pure-reader law); all new visuals
   are pure functions of sim state (chant clock, seized_left,
   kit_first_possessed precedents).

## Human-facing surfaces (skill checklist applied)

All new player-visible text, en/es/pt-br (authored now; owner ES pass +
Junior PT-BR pass at their queue slots):

| key | en | es | pt-br |
|---|---|---|---|
| zone.low_quay.display_name | The Low Quay | El Muelle Bajo | O Cais Baixo |
| challenger.name | VAREKKA | VAREKKA | VAREKKA |
| challenger.stands.line | ONE STANDS | UNO SE PLANTA | UM SE PLANTA |
| challenger.called.line | THE FLESH IS CALLED | LA CARNE ES LLAMADA | A CARNE É CHAMADA |
| challenger.term.line | THE TERM IS PAID | EL PLAZO ESTÁ PAGADO | O PRAZO ESTÁ PAGO |

Register: court paperwork — declarative, stamped (v12 UI-voice law;
nothing speaks for the Unpaid; Varekka himself has no dialogue — his
voice is the chant RING, visual). Accuracy axis: every line states a
sim fact (engagement, completed chant, death). Presentation axis:
mirrors the existing stamp family (THE WAY IS PAID / THE FLESH IS
SPENT). The strip's glyph labels are data-driven and unchanged in
register. Language critique rides the wall's vision gate (banner
checks) — blocking at ship per Rules 2/6.

## Harness + gates

- **Comparability: FULL RESET, decided here.** The dual-glyph strip
  changes every frame of every script; the wall re-runs 14+1 entire
  (the v14 precedent). Old teed logs stay for reference; new run A =
  `_v15_a1`.
- **Stream canary (W1) — EXECUTABLE procedure (panel fold: the draft
  procedure could not run).** `rake gate` rm_rf's `_gate_a`/`_gate_b`
  BEFORE capturing (Rakefile:67) and only ever compares its own two
  fresh runs — pointing it at "the v14 gates" would DESTROY the v14
  reference and compare nothing (two CONFIRMED panel findings). The
  real procedure: (0) BEFORE the zone commit, at v14 HEAD, regenerate
  and preserve baselines: `SKIP_CRITIC=1 rake gate SCRIPT=...` for
  `world_loop` + `district_hunt`, then copy each `captures/<s>_gate_a`
  → `captures/<s>_v15_canary_ref` (captures/ is gitignored; the copies
  are local artifacts). (1) New tiny Rake task **`rake canary
  SCRIPT=<s> BASELINE=<dir>`** (rides TDD increment 1): ONE replay run
  into a fresh dir + per-frame md5 against BASELINE, nonzero exit on
  any mismatch — machine-checkable pass/fail. (2) AFTER the zone
  commit: run the canary for both scripts against their `_v15_canary_
  ref` dirs. Zone-add must not perturb foreign streams (an unvisited
  zone has nothing to tick or draw for); the canary PROVES it before 15
  scripts pile onto a wrong assumption. Canary failure = stop,
  diagnose, respec.
- **Manifest enforcement becomes MACHINE-CHECKED (Codex fold 2).** The
  v14 manifests were manual log-grep obligations recorded in the wall
  log — `rake gate` never read them (Codex verified: double replay +
  md5 + vision verdict only). v15 names the enforcement path: each
  script JSON gains a `"manifest"` key (event name → min count per
  double replay); new `harness/manifest_check.rb` + `rake manifest
  SCRIPT=<s> LOG=<teed log>` greps the teed `EVENT <name>` lines
  (world_scene.rb:33 format) against the script's own manifest and
  exits nonzero on any shortfall. The wall procedure runs it after
  every gate. The 14 existing scripts get their v14 wall-log manifests
  back-filled into their JSON (mechanical copy from the v14 table;
  moving_square/critic_reel stay det-only, no manifest key).
  `replay_runner.rb` must ignore the unknown key (verified at TDD).
- **New script: `harness/scripts/low_quay_run.json`** (pilot-authored
  post-TDD; `rake pilot NAME=quay1 SEED=7`; manifest REGISTERED AT
  AUTHORING TIME — in the script JSON, per the fold above). Staged beats: stair descent + Low
  Quay banner · quay wide shot (channel + both lanes + density) · ONE
  STANDS · chant tell (ring + named-vessel glyph) · chant INTERRUPTED
  (damage him mid-chant) · a completed seize + THE FLESH IS CALLED ·
  seized walk (two captures apart, approach visible) · swap-escape
  during seizure · Varekka slain + THE TERM IS PAID + fat drop ·
  climb-back carrying · bank at the Second Vigil.
  **Manifest:** `challenger_engaged ≥1 · challenger_chant_started ≥2 ·
  chant_interrupted ≥1 · vessel_seized ≥1 · seizure_ended ≥1 ·
  banked ≥1 · drop_picked_up ≥1` (counts per double replay: ×2).
- **Checks 46 → 49, ADD-ONLY:**
  - #47 `low_quay_reads`: "When a Low Quay frame is on camera, the zone
    reads as a dark under-harbor distinct at a glance from the Keyward
    (black-and-ochre blocks) and the Longrow (gray row): indigo-black
    floor, a central impassable channel band — a dry stone bed in
    slate-bone, crossed by two bridge gaps — and slate-bone colonnade;
    the banner 'The Low Quay' is legible when shown. If the replay
    never enters the Low Quay, pass with why='not exercised by this
    script'." (Panel-corrected wording: the draft said 'channel VOID',
    but wall tiles render in the zone's single wall color — slate-bone,
    LIGHTER than the floor — so a critic looking for darkness would
    fail an honest render. The fiction agrees: the rites stopped, the
    water stopped — the channel is DRY.)
  - #48 `challenger_tell_reads`: "When Varekka's chant is on camera, a
    deep-blue expanding hollow ring centers on ONE pale human and a
    small hollow blue square floats above exactly one pack vessel — the
    pair reads as 'he is calling THAT body', clearly distinct from the
    rust taunt square, the teal respawn tell, the red/yellow attack
    telegraph, the orange volley brackets, AND the small washed-out
    pale-blue retarget cue block (the chant family is deeper and more
    saturated, and body-scale rather than an 8px block). If no chant
    frame is present, pass with why='not exercised by this script'."
  - #49 `seizure_reads`: "When a seized vessel is on camera, it carries
    a thin blue underline (mirror of the rust taunt underline) and, in
    the court-stamp frames, the lines ONE STANDS / THE FLESH IS CALLED /
    THE TERM IS PAID are legible in the banner slot with banner-scale
    prominence. A seized body standing adjacent to Varekka doing nothing
    is the design, not broken AI. If neither a seized vessel nor a
    challenger stamp appears, pass with why='not exercised by this
    script'."
- **Wall order:** low_quay_run FIRST (early validation, the
  respawn_telegraph precedent), then the 14 in the v14 order. Retry
  law: 2 attempts, INFRA-only. Verdicts from teed logs
  `tmp/wall/<script>_v15_a1.log`, never task exit codes. Manifest law
  applies to ALL 15 (the v14 manifests table + the new row above).
  Re-pilot budget: 3-6 (the strip change is cosmetic-only for sim
  streams, but W1-class surprises get re-piloted, not argued with).
- **Perf:** `rake perf` after the wall — budget unchanged (16.6ms); the
  chant ring + underline are two rects; expect ≤ +0.02ms vs 0.341.

## Watched risks (pre-registered)

- **W1 — zone-add stream perturbation (RESTATED per Codex fold 1).**
  The original claim "only the current zone ticks" was OVERSTATED:
  non-current zones' drops, corpse loads, and expiry flashes DO tick
  every frame, and the drop/respawn PRNGs are global ordered streams,
  not per-zone. The honest basis for "no perturbation" is narrower: an
  UNVISITED zone contains zero drops, zero corpses, zero respawn
  records — nothing to tick, nothing to draw for — so adding
  `low_quay` to the zone table changes no existing stream until a
  script enters it (old scripts never do). The canary run proves the
  CONCLUSION empirically; the reasoning above is what it proves.
  Additionally (Codex fold 1b): `slow_door.json` gains its OWN explicit
  `gradient_anchor` — the reverse transition from low_quay changes
  slow_door's arrival list, and low_quay declaring an anchor protects
  only low_quay (the v12 trap's remedy must land on BOTH sides of a
  new edge). If the canary is dirty: the perturbation source is a bug
  by definition — fix the sim, don't re-pilot around it.
- **W2 — seized pathing stalls in crowds.** Flow-field approach
  respects body-blocking; a wall of pickers can stall the seized walk.
  Accepted (the stall is mercy); the pilot stages at least one clean
  seized walk for the critic. If stalls dominate live play, the
  thirteenth routes it.
- **W3 — swap-escape makes seizure free.** Tab always escapes the ECHO,
  but the abandoned body still walks to Varekka and waits under his
  swing among his crew — the cost is positional, possibly the body. If
  the thirteenth reads "no fear because swap trivializes", the lever is
  the abandoned-body cost (data: his damage, crew density), never
  removing the counter (fairness ladder is law).
- **W4 — strip overflow at 960px.** Dual glyphs lengthen the strip;
  display keys (font size 12→11, gaps) absorb it. #45/#12 catch
  regressions; the pilot's first capture verifies before the wall.
- **W5 — Varekka + stationless quay overtuned.** The wall can't feel
  fear; only the thirteenth arbitrates. All levers in data
  (density, his hp/damage/cooldown, gradient). Difficulty elsewhere
  stays pinned — any global softening is out of scope by law.
- **W6 — banner contention: RESOLVED BY BUILDING (Codex fold 3).** The
  deferral was wrong for LIVE play, not just gates: the player descends
  (zone banner, 150f), walks at Varekka, and first engagement can fire
  inside the banner window — losing "ONE STANDS", the increment's
  first-contact payload, silently. The banner slot becomes a small
  FIFO: an active banner plays out its frames; queued lines (cap
  `banner_queue_max: 2`, display key) follow in arrival order; further
  requests beyond the cap drop oldest-queued (never the active one).
  Sim-cosmetic state (the @banner_timer/@breach_line precedent),
  tick-locked, replay bit-equal. **Entry shape (panel fold —
  locale-at-render law):** `{text_key:, fallback:, color: :banner |
  :gold, frames_left:}` — zone banners enqueue
  `{text_key: "zone.<name>.display_name", fallback:
  map.display_name, color: :banner}`, stamps enqueue their string key
  with `color: :gold`. The RENDERER resolves `tr(text_key, fallback)`
  at draw time and dispatches BANNER vs BREACH_GOLD by `color:` —
  entries carry KEYS, never locale-baked text, so the harness
  locale=en pin keeps working. World exposes `active_banner` (first
  live entry), replacing the bare `banner?`. The pilot still stages a
  clean engagement for the critic; the queue is for live truth.

## TDD increments (each green + committed before the next)

1. **Zone file + transitions + canary FIRST** (low_quay.json +
   slow_door down-stair + slow_door explicit gradient_anchor + zone
   tests: transitions round-trip, anchors declared, no stations; canary
   runs ride this commit). ORDER IS LOAD-BEARING (Codex pass-2 Q8): the
   canary byte-compares captures against the v14 gates, so it must run
   BEFORE the strip changes every frame — bindings first would make the
   canary unpassable by construction.
2. **BindingMap + strip dual glyphs** (core + overlay + data/bindings
   .json + gitignore + tests: load/merge/raise paths, glyph pairs,
   overlay line content; harness constructs the map WITHOUT the local
   override — see the pinning law in Harness). Window/overlay constants
   deleted.
3. **Challenger kind + chant/interrupt** (combat.json + world chant
   state machine + events + tests: trigger gating, pin-at-start,
   interrupt-on-damage, cooldown).
4. **Seizure + controllers** (seized state on creature; Possessed/Ai
   controller overrides; end conditions; tests incl. swap-during-chant,
   swap-during-seizure, body-death, Varekka-death, crowd stall,
   seized-swap exemption under stagger AND under special-commit, and
   the two exactly-once tests the panel named:
   `zero_frame_seizure_emits_exactly_one_seizure_ended` (vessel_seized
   + body death in the SAME tick → one event, why=:died) and
   `seizure_end_idempotent_on_wipe` (seized body dies, then the wipe
   sweep runs → no second emission) — increment 6's telemetry COUNTS
   seizure_ended, so exactly-once is load-bearing upstream).
5. **Presentation** (chant ring, vessel glyph, underline, nameplate,
   court stamps, banner strings ×3 locales; renderer stays pure-reader;
   display keys in display.json). Headless test surface (panel fold —
   this increment had none named): (a) banner-queue content tests
   (entries enqueue with key/fallback/color, FIFO order, active plays
   out its frames, cap drops oldest-queued never the active one) —
   world-level, no Gosu; (b) display-keys presence/validity test for
   the new keys (chant ring RGB, underline RGB, nameplate size,
   banner_queue_max). Pixel truth stays gate-only (Rule 2).
6. **Telemetry lines + checks 46→49 + manifest machinery**
   (telemetry tests; gate_checks.json ADD-ONLY; harness/manifest_check
   .rb + rake task + back-fill of the 14 script manifests; and ADD THE
   5 NEW EVENTS to world_scene.rb's logged-event list — it is a
   HARDCODED list, not a whitelist subscribe (Codex pass-2 catch:
   without this the new manifest reports zero challenger events and
   the wall fails on a tooling gap, not a sim gap)). The manifest
   checker gets its own `test/harness/manifest_check_test.rb` (panel
   fold — the pilot_roundtrip_test precedent for harness tooling):
   (a) sufficient events pass, (b) one shortfall exits nonzero naming
   the missing event, (c) a script without a manifest key is SKIPPED
   not failed, (d) the parser handles world_scene.rb:33's exact
   `EVENT <name> frame=N ...` line format.

## Fun-verify protocol (THIRTEENTH — pre-registered, Spanish at the ask)

Blind: owner plays FIRST, no changelog. Harvest
`/tmp/game_two_session_<pid>.log` BEFORE any question. Preamble
verbatim: "si nunca usaste algo, decilo — esas preguntas se leen como
no-ejercitado, no como negativo".

Questions (ask exactly these, in Spanish — the twelfth's convention;
the exact Spanish phrasing lands in the debrief skeleton draft, a
session artifact, per the repo-artifacts-English law — panel fold):
1. HEADLINE A — the descent: when you crossed the Slow Door and went
   down, did arriving at the Low Quay feel like arriving somewhere
   EARNED — a place it cost you to open?
2. HEADLINE B — Varekka: did he scare you? When he chanted and your
   body walked to him on its own — did your body (your real one)
   react? (the eighth entrainment read, INSIDE the peak the Challenger
   exists to create)
3. Seizure fairness: did you see the chant coming? Did you know how to
   cut it (swap body / hit him / kill him)? Anything unfair about him?
4. The stationless quay: did the loaded climb home MATTER — did it
   feel like part of the hunt, or like an errand?
5. Keybinds: did the dual-key strip resolve what you asked for? Did
   you try your own bindings.local.json?
6. Names and stamps: "El Muelle Bajo", VAREKKA, "UNO SE PLANTA", "LA
   CARNE ES LLAMADA", "EL PLAZO ESTÁ PAGADO" — did they land? Does any
   ring false? (Debrief disclosure: the third stamp changed post-fork —
   it was "EL NOMBRE QUEDA TACHADO"; Codex refuted it on canon.)
7. Economy re-read: was the quay's loot worth the risk? Is the bank
   still FOR something?
8. Global guard: anything unfair outside Varekka?

Routing (mechanical):
- **Q1** arbitrates half A. `quay{entries}` >0 + "ganado" verbal → ZONE
  VALIDATED. "Otro distrito más" → identity lane (presentation dose:
  palette/geometry, no sim). entries=0 → unexercised, the ask reruns
  next session (no iteration from silence).
- **Q2 + Q3 arbitrate half B, together.** `varekka{seized}` >0 + body
  react + nothing-unfair → **CHALLENGER VALIDATED** (the six-non-confirm
  saga closes with its first positive read). Body react + `seized=0` +
  `chants>0` + nothing-unfair → **TELL VALIDATED** (panel fold — the
  skilled-player path: every chant interrupted, yet the THREAT alone
  entrained; the counters worked AND the fear worked. The verbal
  distinguishes whether the interrupt is too cheap — if the owner says
  the peak came from the RING, the design carried; if he says
  interrupting felt free, the interrupt cost is a Varekka-local data
  lever). Body react + unfair-verbal → fairness lane opens (tell/
  counter dose from Q3's specifics; Varekka-only levers). Flat +
  engaged=0 → UNEXERCISED (he was never met; preamble law — no design
  verdict). Flat + seized>0 → design problem: the dossier re-weighs at
  v16 with its first presentation-complete failure on record (the
  strongest possible evidence either way). Flat + engaged>0 +
  seized=0 → the tell alone did not entrain and the seize never
  landed: UNDER-EXERCISED, not failed — the fourteenth re-asks with
  the seize experienced (no dose from a half-met enemy).
- **Q4** stationless read: "parte de la cacería" → fork-1 shape
  VALIDATED. "Trámite" → route: single remittance chest fork RE-OPENS
  at v16 debate (the declined fork-1 option B, now with telemetry).
- **Q5** strip verdict: "resuelto" → the twelfth's lane CLOSES.
  Presentation complaints → display-keys dose. "Una tecla no anduvo /
  no reaccionó" → FUNCTIONAL input-bug lane (BindingMap/KeyboardInput
  unit altitude — Codex pass-2: replays cannot exercise the keyboard
  mapping, so live play is its only functional exercise; a broken-input
  answer is a bug report, never a display dose). "No lo probé" →
  unexercised (preamble law), re-ask rides the fourteenth.
- **Q6** any name "suena falsa" → owner names the replacement at the
  debrief from the bible (locale-file swap; banner text changes re-run
  the wall — state it honestly before accepting, the v14 Q4 law).
- **Q7** feeds the economy ledger (no new dose from one answer).
- **Q8** unfair-outside-Varekka → named lane with telemetry; "nada" →
  guard-scope stays closed-validated (fourth clean would be the streak).
- **Difficulty law:** any "too hard/unfair" answer routes to
  VAREKKA-LOCAL or QUAY-LOCAL data levers only; the pinned global
  difficulty does not move on any Q of this verify.

## Deliberately absent (recorded so review doesn't re-litigate)

- **No LOS/range break for an active seizure** — the counter set is
  swap/interrupt/kill; adding a fourth counter dilutes the fear the
  increment exists to create. Revisit only on a Q3 unfair verdict.
- **No Varekka phases/enrage/second form** — one man, one sentence,
  one death. Variants are parked.
- **No new station verbs in zone 3** — fork 1 chose the stationless
  shape; the chest option is recorded for the v16 debate if Q4 says
  "trámite".
- **No seal on the stair down** — the owner paid 150 twice; arrival is
  the payoff, not another toll (oracle half A depends on it).
- **No rebind UI in-game** — the binding map is a FILE by design
  (hobbyist + Junior workflow: edit JSON, restart). An in-game rebind
  screen is parked (would be its own increment with its own wall).
- **No PT-BR/ES review gate inside v15** — authored translations ship;
  owner/Junior passes stay queued (their lanes, their pace).

## Fiction annex (bible session record — names born before the spec)

The Low Quay: Silovun is "the gathered river-doors" — and the door the
name remembers is HERE: the under-quay where the Processional barges
land the quarter's dead at the corridor mouth. Since the interdict the
quay is dark — the rites stopped, the lawful wardens withdrew deeper,
the toll-gates stand unstaffed past a stair nobody living should
descend. The Unpaid broke through anyway: the landed dead lie in their
grave-goods — lamp-oil, toll-tokens, passage-scrolls priced from a
laborer's month to a noble's ransom — the densest untouched wealth in
the quarter, packed FOR the crossing. The gradient continues downward
because the theft does. (Attachment per §14.4: extends §9.7's upper
chambers + §5.3 grave-goods + the v12 annex's interdict; contradicts
nothing.)

Varekka: the crews' answer to the warden. A Kadravai wardsman-captain —
struck name, three syllables, the third earned alone in the dark
(§2.4) — who does not fear the stair. From Silovun's audit-frozen
roll-rooms the crews stole the vat-licenses of the court's own suvrim;
Varekka learned to say them. When the chant completes, the flesh
answers its name and walks to the voice — the Dravessa precedent
worked as a weapon (§12.1). The echo is not named (it HAS no name —
that is why it serves), so possession-swap always slips the sentence:
he seizes bodies, never the warden. His pronunciation must be exact —
slow, stood-still, interruptible — because a name mispronounced is a
door knocked on at the wrong house (§2, closing line). Humans never
fought back. Until one did.
