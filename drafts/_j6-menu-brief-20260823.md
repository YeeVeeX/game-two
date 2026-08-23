# J-6 NON-PAUSING MENU — brief cut (s52, 2026-08-23)

Lane 4 headliner, RATIFIED-G + RATIFIED-J (foundation
`drafts/_v19-foundation-20260822.md` §Lane 4, staging row 1 — the LAW;
on disagreement the foundation wins). Sequencing law, foundation
verbatim: **"ships BEFORE the v19 ritual runsheet freezes"** (the
runsheet gets authored against the real Esc/quit path). This brief =
the ticket cut; the writing session shipped ZERO code (brief-writer
precedent s45/s48/s50). All line numbers at `fbc15f1`.

**The T5-close D7 flag, answered up front: J-6 touches world.rb ZERO
times.** The menu reads world/session through EXISTING public readers
only (ticket C names them); no world.rb line moves in any J-6 ticket.
The extraction question stays armed for J-7's brief-cutter (~14 lines
headroom, untouched by this lane).

## The foundation row this brief serves (verbatim scope)

> StateStack state over a still-ticking world (death with menu open is
> possible; netplay-safe — idle input frames keep flowing) · per-bus
> volume + quick mute · window scale presets + fullscreen · runtime
> locale switch · quit = existing clean-quit path + partner courtesy
> notice · link-status + session-ledger panels · read-only controls
> sheet (rebind stays parked). CLIENT PREFS in their own file — never
> the world save (save-stays-facts-only). Runtime bus-gain may need a
> small audio-lib API → mail the audio seat at spec time.

Gates owed (foundation): Rule 2 + wall per new visible surface · suite
via hooks · netplay gates untouched-green (menu emits idle frames) ·
window.rb ≤ 300 — menu is its own state module, never inline in the
orchestrator.

## Decisions (each argued from live code read this session)

### D1 — Seam: app-layer module at the ONE input seam; route, don't pause

`App::Menu` (new file `src/app/menu.rb`). Window calls, both modes:

```ruby
action = @menu.tick(@input)     # menu consumes input while open
world_input = @menu.route(@input) # open? -> NULL_INPUT : input (same object)
```

Solo: `@world.tick(world_input)` (window.rb:107-108 seam). Netplay:
`@session.update(now, world_input)` (window.rb:140) — `run_tick`
samples whatever source it is handed once per EXECUTED tick
(session.rb `input.update(t)` + `Protocol.mask(input)`), so an open
menu sends mask 0: **idle input frames keep flowing**, lockstep never
notices (foundation's netplay-safe clause, satisfied at the existing
seam). `Core::NullInput` already exists (input.rb:31-34) —
deterministic, stateless; the menu holds one instance.

- **REJECTED — menu in World's StateStack** (world.rb:294 `@states`):
  that stack is lockstep sim state; a menu there enters replays and
  the netplay digest. The foundation demands a STILL-TICKING world
  under the menu — the world must never know the menu exists.
  (`Core::StateStack` stays available to the menu module internally if
  its two-screen machine wants it; v1's :root/:controls fits a plain
  symbol — module-internal choice, no law either way.)
- **REJECTED — Gosu button_down-driven menu:** ReplayWindow forwards
  no key events (replay_runner.rb) — an event-driven menu is
  unscriptable, killing the Rule 2 artifact. Poll + edge-detect over
  the abstract input instead (D2).

### D2 — Open/close verb: `:menu` abstract action, bound to Escape

- `data/bindings.json` + `"menu": ["Escape"]` (one row).
  `App::KEY_TABLE` + `t["Escape"] = Gosu::KB_ESCAPE` (key_table.rb's
  own "one-entry addition" invitation; Escape is absent today —
  verified by grep). BindingMap validates it like any action;
  one-key-one-action holds (Esc owns nothing else).
- Edge detection lives INSIDE `Menu#tick` (prev-frame down? snapshot
  per action) — the SAME seam works for live `KeyboardInput` (via the
  binding) and `ScriptedInput` (scripts name `menu` rows directly),
  so the harness opens the menu exactly the way a player does. No
  routing logic ever duplicates into the scene (drift-proof by
  construction).
- **`Net::Protocol::ACTIONS` UNTOUCHED** (protocol.rb:30 — PINNED,
  append-only, version-bumped). `:menu` never crosses the wire; it is
  local presentation. The world never reads `:menu` either.
- `Window#button_down(Esc)` SHRINKS to exactly two kept behaviors:
  session ended → `close` (end-screen law, window.rb:183 "the state
  must be READABLE"), and session-with-no-world (HOSTING/CONNECTING)
  → `request_quit` (hosting-cancel flow, main.rb "Esc cancels").
  While playing, Esc falls through — the binding + Menu#tick own it.
  While `@quitting` (BYE drain ≤ drain_timeout_ms) the menu does not
  tick (window guard) — no reopen during a drain.
- **Esc semantics change on purpose:** Esc = menu; QUIT = a menu row
  (D3). This is the ratified reason J-6 precedes the runsheet freeze.
  AGENTS.md Controls row updates in the same commit (ticket A2), and
  the ship-close surfaces the change to both peers (es-CR/pt-br note).
  Bots and soak never touch Esc (`autopilot_watch` calls
  request_quit/close directly, window.rb:160-175) — chain_check and
  the TELEMETRY shapes cannot move.

### D3 — Quit row = the existing clean-quit path, moved not rebuilt

`Menu#tick` returns `:quit`; the window handler is the OLD
button_down body verbatim: `@session && !@session.ended?` →
`request_quit` (BYE{quit} drain, both seats land reason=:quit, host
save writes at ended), else `close` (solo clean quit — the save write
IS this path, window.rb:195-201). Zero new quit machinery; exit
statuses, launcher relaunch logic, and save custody untouched.

### D4 — Draw: own module, topmost, veil that PROVES the world ticks

`Window#draw` gains one line: `@menu.draw` after `@netplay&.draw`
inside the `Gosu.scale` block (logical 960×540 space — menu is
scale-blind like every surface). Veil is SEMI-transparent by design:
the world must read behind the panel (the non-pausing story told in
one frame). NetplayOverlay's VEIL_ALPHA=235 is the END-screen tone —
the menu defaults lighter (~150). ALL geometry/tone keys land in
`data/display.json` as `menu_*` (Rule 3 — zero constants in code),
with fetch-fallback defaults per the ControlsOverlay precedent
(:146-155). Rendering uses Gosu primitives + Gosu::Font directly
(NetplayOverlay pattern); #draw is the only Gosu-touching method —
state resolution stays pure and headless-testable.

### D5 — Menu machine v1: :root / :controls, edge-only nav

Rows: RESUME · CONTROLS · QUIT. up/down edges move the cursor,
attack edge selects, menu edge closes (:root) or backs out
(:controls). RESUME = close. CONTROLS = read-only sheet rendering
`BindingMap#glyphs` for every action (binding_map.rb:66) with
translated labels — movement/aim/menu rows INCLUDED (the v14 "movement
stays off the strip" parking governs the STRIP, not a dedicated
sheet). Rebind stays parked (foundation). Key-repeat REFUSED v1: a
3-row menu needs no autorepeat; reel authors keep presses ≥8 frames
apart (the edge-merge pilot trap, MEMORY 2026-08-23).

### D6 — Rule 2 artifact: 25th wall script `menu_tour.json` over TEST 1

New scene `harness/scenes/menu_scene.rb` = WorldScene's construction
(locale "en" pin + canonical bindings, world_scene.rb:26-33) + one
`App::Menu` + the SAME two-line routing from D1. replay_runner
SCENES + `"menu"` row (+require). Script: `scenario: "menu"`,
`start.zone = gate_fixture` — the self-linked TEST 1 zone dodges both
live-interference traps BY CONSTRUCTION and carries a husk at [27,4]
with 12-tile Chebyshev aggro (T5 D2 precedent + close's husk note).

Beat sheet (captures):
1. pre-open — world normal, HUD full;
2. menu open — root rows + cursor + world visible behind the veil;
3. **~180f later, menu STILL open** — the husk has closed
   distance / HP has dropped: the still-ticking proof in pixels
   ("death with menu open is possible" proven by its precondition —
   damage lands while the menu is up);
4. controls sheet;
5. menu closed — world normal, the damage PERSISTS.

Checks: `harness/gate_checks.json` + `menu_reads` (panel legible,
rows named, world reads behind the veil) + `menu_world_ticks` (across
the two menu-open captures the world state visibly advances) — both
SELF-SCOPING ("no menu panel anywhere in the reel → pass
not-exercised", the level_gate_reads precedent) so the other 24
scripts stay green by the checks' own text; count row updates
(7ab5612 law). Script lives in `harness/scripts/` → run_wall.sh
sweeps it (trust-the-directory law). Wall 24 → 25 (~5 min/script
toll, priced again). Manifest floors = TRUE counts from the authored
log (T5-close governing clause; no invented floors).

Reel authoring: pilot stages the WORLD half (walk near the husk),
then hand-splice `menu`/nav action rows — the pilot has no window and
cannot drive the menu; presses ≥8f apart; never `goto` onto anything
after combat (livelock trap, MEMORY).

### D7 — world.rb: zero touches (the flag's answer)

Ticket A reads NOTHING from world (panel is self-contained; the scene
reads world only to construct/tick it — existing API). Ticket C reads
`world.ledger_beat` (:191) and pack/progression HUD readers that
ALREADY exist for the renderer. Any J-6 change that seems to need a
world.rb line is a STOP condition (re-argue the cut, never grow the
god-file from a presentation lane).

### D8 — No new events, no bus subscription in v1

The foundation's "own state module on the bus" is honored as: own
module at the architecture level the bus law protects — never inline
in the orchestrator (the cap's real demand). v1 uses direct read-only
polling (Renderer/ControlsOverlay/AudioBridge precedent).
`EventBus::EVENTS` UNTOUCHED (define events when first used — the
menu uses none; Kethral breadth-thinking law). EventLog curated list,
soak regexes, TELEMETRY, DIGEST_VERSION, save schema: all untouched
by construction — any pressure on one is a STOP.

### D9 — Client prefs (ticket B): `data/prefs.local.json`, machine-written, lenient-named

Placement mirrors `data/bindings.local.json` (DataStore auto-loads
when present; .gitignore +1 row). Schema v1 — every key OPTIONAL,
absent = today's behavior byte-identical:

```json
{ "locale": "pt-br", "window_scale": 2, "fullscreen": false,
  "volumes_db": { "master": -6.0, "music": -3.0, "sfx": 0.0, "ui": 0.0 },
  "muted": false }
```

Decode: bad type/unknown value → ONE named console line + that key's
default (the AudioBridge absent/refused precedent) — NOT BindingMap's
raise. The distinction argued: bindings are HAND-edited (a typo needs
a loud abort that reaches the person who typed it); prefs are
MACHINE-written (a crash-corrupt file must not brick boot — named
line, defaults, self-heals on next write). Writes: whole-file
`File.write` on each change-commit (hundreds of bytes; menu-rate, not
tick-rate). NEVER the world save (foundation: save-stays-facts-only);
`saves/` custody, SaveStore, and the digest chain untouched. New
module `src/app/prefs.rb`, pure load/validate/write — unit-tested
headless in tmp.

### D10 — Locale precedence with prefs: env > pref > display.json

Window composes `ENV["GAME_LOCALE"] || prefs.locale` into Strings'
EXPLICIT param (strings.rb ctor: param > env > display) — the
launcher argument stays king per-launch (Junior's `bin/play pt` beats
a stale pref), the pref beats the repo default. Runtime switch:
`Core::Strings#switch!(data, locale)` mutates @locale/@table — ONE
shared instance (window.rb:78 constructs once; NetplayOverlay,
Renderer, Menu all hold it) so every surface flips next frame. Sim
never reads strings (strings.rb law comment) — replay/netplay-blind.

### D11 — Captures stay locale-en: the reel never commits a switch

The check-comparability law (world_scene.rb:26-28: "translated text
never enters a capture") stands. The LANGUAGE row appears in the reel
with value EN; the SWITCH is proven by unit tests (switch! swaps
tables; the menu action calls it) and the pinned es/pt strings ride
the ship-gate language critique (T5 D4 precedent). A mid-reel es
frame would poison every downstream check — REFUSED.

### D12 — Scale presets + fullscreen (ticket B): live apply, pref-persisted

Gosu 1.4.6 exposes runtime `width=`, `height=`, `fullscreen=`
(verified live this session on the installed gem). Presets
`["auto", 1, 2, 3]` in display.json (`menu_scale_presets`). Apply =
window-owned lambda handed to the menu at ctor (menu stays
Gosu-window-blind): `self.width/height = view*k; @scale = k`, k from
the existing `App::Scale.factor` math for "auto"; fullscreen =
`self.fullscreen=`. HONEST LIMIT, named: physical window dims are
OS-level — captures are scale-blind BY LAW (window.rb v16 comment:
harness renders at script dims), so the gate proves the ROWS render;
the apply path is pure-math unit tests + a manual observation note at
ship (exactly how v16 (a) shipped the boot-time scale).

### D13 — Audio rows: feature-detected; the library ask MAILS TODAY

Live read: `GTA::AudioSystem` exposes NO runtime volume API (public
surface: handle_event/update/active_voices/music_pending?/
clock_anchor/destroy/config) — while `group_set_volume` already
exists below it (command_io.rb:131, native.rb:64) and boot-time
`volume_db` proves the graph supports it (audio_system.rb:184-185).
The ask (mailed s52, `~/.pi/agent/mail/game-two-audio/
from-game-two-j6-volume-api.md`, digest-stamped, cites this brief):
public `set_bus_volume(bus_id, db)` (clamped, control-thread, applied
via the existing command path) + `bus_ids` reader. Buses today:
master + {music, sfx, ui} (cues.json vocabulary). Pure-sink law
holds: volume flows IN, nothing flows back.

Game-side: volume rows render ONLY when
`@audio.respond_to?(:set_bus_volume)`-class detection passes (Null
bridge / absent library / old library = rows absent — silence is
already the law). QUICK MUTE = master floor toggle through the same
API, restoring the prior value. Boot-apply: prefs volumes applied
once after `AUDIO on`. **Never patch the library from this repo**
(seat-lease law). API not landed when B executes → volume rows DEFER
to C (or a rider) with a named line in B's close — never a blocker.

### D14 — Netplay (ticket C): courtesy notice + link/ledger panels

**Live gap found this session:** on reason=:quit the NON-initiating
seat holds a FROZEN world with NO line — netplay_overlay.rb:34-40
maps :quit to screen nil ("the window is closing honestly" is true
only for the seat that pressed Esc; the peer's window stays open —
window.rb:141 closes only when `ended? && @quitting`). The initiator
never draws a post-end frame (update closes before draw), so:
`flags` maps quit-ended → `:partner_left` screen unconditionally —
only the abandoned seat ever renders it. One new locale row ×3 (net
vocabulary kept: es COMPAÑERO/SESIÓN TERMINADA, pt PARCEIRO/SESSÃO
ENCERRADA — pinned below).

Menu panels, session mode only (all EXISTING readers): link-status =
seat/ticks/d/link_slow/stall_ms_max/desyncs/stalls (session.rb
attr_readers + lockstep counters + params); session-ledger =
`world.ledger_beat` + pack level/XP readers the HUD already uses +
session run span. Rule 2: netplay_session's end frames MOVE (the
notice) → its checks text updates in the SAME commit; all three net
gates re-run (harness/net/, outside the wall — the wall stays
single-player). Solo wall untouched by construction (overlay and
panels draw only when a session exists).

### D15 — J-3 stays OUT

Stats panel v0 is its own ratified lane item (foundation staging row
2, CryoFall register, own brief). The menu reserves NO tab for it —
J-3's cutter decides its surface (YAGNI; a reserved dead tab would be
speculative UI).

## Ticket cut (each sized to one session)

### J6-A — chassis (s53): menu module + wiring + the 25th wall script

Commit A1 `feat(menu)` — INERT half: `src/app/menu.rb` (module: state,
edge tracker, route contract, rows, pure draw-model) + unit tests +
`key_table.rb` +Escape + `bindings.json` +menu row. Nothing constructs
Menu in live code yet; identity holds trivially (belt: pairs anyway).

Commit A2 `feat(presentation)` — VISIBLE half: window wiring (D1-D4,
±~20 net lines), `menu_scene.rb` + replay_runner registry,
`menu_tour.json` (25th script), gate_checks +2 (+count row), display
`menu_*` keys, strings ×3 (pinned below), AGENTS.md Controls row.

Test lanes: (1) menu unit — closed→route returns the SAME object,
open→NULL; Esc edge toggles; nav bounds; QUIT select returns :quit;
:controls transitions; never holds a world ref. (2) bindings/key-table
roster updates (additive). (3) line caps auto (window ≤300).
(4) manifest floors true-count.

Ladder (in order): suite via hooks · identity pairs world_loop +
low_quay_run, SKIP_CRITIC double-replay + md5 vs a PRE-CHANGE
`fbc15f1` baseline captured before any edit, at A1 AND A2 (24/24
byte-identical or stop) · menu_tour full critic-ON gate + manifest ·
soak N=1 belt (real processes over the refactored window seam; bots
never open the menu — proves route() is inert for the idle path) ·
Rule 6 review · language critique rides the gate verdict.

### J6-B — prefs + settings rows

`src/app/prefs.rb` (new) + .gitignore row + menu :settings screen
(LANGUAGE cycle en/es/pt-br via Strings#switch! · WINDOW SCALE presets
· FULLSCREEN · volume/mute rows IF D13's API landed, else deferred
named) + display `menu_scale_presets` + strings rows ×3 + boot-apply
(locale/scale into existing ctor params; volumes post-AUDIO-on).
Lanes: prefs round-trip + degradation-named tests · switch! table
swap · preset math · menu settings unit. Ladder: suite · pairs ·
menu_tour re-gate (settings beats added to the SAME script) · manual
scale/fullscreen observation note (D12 honest limit).

### J6-C — netplay: courtesy notice + link/ledger panels

netplay_overlay :partner_left + `net.partner_left` ×3 + menu panels
(D14 readers) + harness/net checks text update. Ladder: suite · the
three net gates (updated checks named in the close) · pairs (belt) ·
soak N=1.

## Pinned strings (the executing sessions author ZERO prose)

Ticket A (`menu.*`, three files, VERBATIM):
- `menu.title`: `MENU` / `MENÚ` / `MENU`
- `menu.resume`: `RESUME` / `CONTINUAR` / `CONTINUAR`
- `menu.controls`: `CONTROLS` / `CONTROLES` / `CONTROLES`
- `menu.quit`: `QUIT` / `SALIR` / `SAIR`
- `menu.hint`: `ESC: CLOSE` / `ESC: CERRAR` / `ESC: FECHAR`
- sheet labels: REUSE `overlay.attack/dodge/mark/interact/swap/
  sustain` + verb rows; NEW `menu.label.move`: `MOVE`/`MOVER`/`MOVER`
  · `menu.label.aim`: `AIM`/`APUNTAR`/`MIRAR` · `menu.label.special`:
  `SPECIAL`/`ESPECIAL`/`ESPECIAL` · `menu.label.menu`:
  `MENU`/`MENÚ`/`MENU`

Ticket B: `menu.settings`: `SETTINGS`/`AJUSTES`/`OPÇÕES` ·
`menu.language`: `LANGUAGE`/`IDIOMA`/`IDIOMA` · `menu.scale`:
`WINDOW SCALE`/`ESCALA DE VENTANA`/`ESCALA DA JANELA` ·
`menu.fullscreen`: `FULLSCREEN`/`PANTALLA COMPLETA`/`TELA CHEIA` ·
`menu.volume`: `VOLUME`/`VOLUMEN`/`VOLUME` · `menu.mute`:
`MUTE`/`SILENCIO`/`MUDO` · values `ON`/`OFF`/`AUTO` + locale codes
`EN`/`ES`/`PT-BR` locale-invariant (placeholder register law).

Ticket C: `net.partner_left`: `PARTNER LEFT — SESSION ENDED` /
`EL COMPAÑERO SALIÓ — SESIÓN TERMINADA` /
`O PARCEIRO SAIU — SESSÃO ENCERRADA` (existing net vocabulary kept).

## Wall-debt audit (why the 24 shipped scripts cannot move)

No existing script names `menu` → the edge never fires → `route`
returns the SAME input object → world byte-path identical. Shared-file
deltas, each argued: bindings.json row (ScriptedInput is
bindings-blind; KeyboardInput never exists in the harness) ·
KEY_TABLE entry (KeyboardInput-only) · display.json `menu_*` keys
(unread by any shipped draw path) · gate_checks +2 (self-scoping
not-exercised) · window.rb (the harness never constructs App::Window
— window.rb:33 law comment) · SCENES registry row (old scripts name
their own scenarios). PROOF, not argument: identity pairs at every
commit vs pre-change baseline. Netplay gates: scenes construct
Sessions directly (never App::Window), so A/B owe them nothing by
mechanism; C re-runs all three because IT moves their pixels. Full
wall sweep not owed unless an identity pair breaks (T5 precedent).

## Line budget + stop conditions

- window.rb 217 today → est ≤240 at A · ≤265 at B · ≤280 at C; hard
  cap 300 (test-enforced). Breach of an ESTIMATE = honesty row in the
  close (T5 precedent); pressure on 300 = STOP, extract.
- STOP: any identity-pair movement (find the leak, never re-baseline)
  · any world.rb / `data/balance/**` / TELEMETRY / EventBus registry /
  Protocol.ACTIONS / save-schema / soak-regex touch · gate FAIL after
  ONE verified-fix re-gate (bank it) · audio API absent at B (defer
  volume rows named, never inline-patch the library) · scope refusing
  to fit a session (cut a rider, never a fatter session).
- Laws carried verbatim: ritual wording UNWRITTEN · live save
  untouched (md5 open/mid/close) · one-concern commits ·
  sampling-artifact law on every critic verdict · gates DETACHED,
  never under a bash-call timeout · never edit src/ while a
  capture/gate/sweep runs.

## Banked amendments — carrier check (T5 close)

- **Cue-silence guard (next cross_through toucher):** J-6 never
  touches cross_through — NOT the carrier; stays banked.
- **Duplicate spell_growth threshold keys (next Progression-ctor /
  progression.json toucher):** untouched here — NOT the carrier.
- **EventLog curation flag:** untouched (D8) — stays a future
  decision.
- **WB edge-row/X-bar notes:** carried into D6's reel guidance.
