# T3 brief — presentation: level/XP HUD strip + level-up feel beat (cut s45, lands s46)

Ticket 3 of Progression v1. Spec:
`docs/superpowers/specs/2026-08-22-progression-v1.md` (P4 feel beat,
P12 observability, T3 row). Binding inputs, all folded below: T2 close
`drafts/_prog-t2-close-20260822.md` §T3-amendments 1–5 + §Fresh-eyes
review NITs. Brief-writer (s45) never implements; the implementing
session reads spec + this brief + EVERY named file region before
editing (read-before-edit is mechanical). Line anchors were verified
live on `91fdc00` (world.rb 1790, window.rb 217, renderer.rb 1224).

**One session, TWO commits, in this order:**

- **Commit A** — `feat(hud): level/XP strip — pack level + progress beside the vitals`
- **Commit B** — `feat(feel): level-up beat — gold stamp + pack pops, wall script`

Defense of the split (spark left it open): A is renderer-only (zero
world.rb risk, zero new records); B carries the world.rb-at-cap touch,
the Transients verb, the harness param, and the new wall script. A red
B never holds the strip hostage; each commit changes what the player
sees (de-slop law); hooks run the suite at both. ONE full wall sweep
after B pays the Rule 2 debt for both surfaces — nothing pushes before
that sweep is green, so Rule 2's "verified BEFORE it ships" holds for
A too (mid-ticket SKIP_CRITIC runs are iteration aids, never evidence).

## Scope fence

- **ZERO sim-number moves.** No `data/balance/*` value changes
  (measurement hygiene — the pending ritual measures progression
  pacing). New PRESENTATION keys in `data/display.json` and new locale
  strings are lawful and expected. `progression.json` untouched.
- **ZERO window.rb lines.** The strip renders in `Renderer#draw_hud`,
  the beat through world state the renderer already reads. J-6
  (non-pausing menu, own state module) is a SEPARATE Lane-4 item — T3
  must not absorb, pre-build, or block it.
- **world.rb: presentation pushes ONLY, net ≤ +6 lines, final
  ≤ 1796** (hard cap 1800, `test/app/line_caps_test.rb`). No new ivars,
  no new sim state in world.rb (the beat's records live in Transients —
  T2 close input 5). Can't fit? STOP and surface an extraction
  decision — never silently carve inside a presentation ticket.
- **kills_xp stays telemetry-only.** Amendment 1's "kills_xp" surface
  shipped in T2 as the `TELEMETRY progression` line; the strip shows
  level + xp-into-level. No session-XP HUD readout (quiet-HUD; exact
  numbers belong to J-3 STATS PANEL v0, a separate Lane-4 item).
- **No save_state.rb touch.** Review NIT 1 (`apply!` local `cap`
  assigned twice — sequential-safe) is PARKED: the next ticket that
  opens save_state.rb owes the rename (likely a future save-schema
  ticket; T5 touches tile_map/crossing, not save_state).
- **No audio.** The beat ships silent; a level-up cue rides E5 (audio
  increments on owner word), never this ticket.
- Live save `saves/world.json` (`98fe75edb6d72deab18cd48eaa88bdaf`,
  341 B, mtime 08-20 15:51) is the owners' progress — md5 before/after
  must match; never launch a save-owning seat from this session.

## Decision 1 — `:level_up` is NOT added to the wall EventLog (the priced call, amendments 2 + NIT 2)

The explicit decision the T2 close demands, with its full cost on the
table: adding `:level_up` to `harness/event_log.rb` EVENTS would move
the varekka_duel + burn_duel ACTIVE sim-identity canary md5s
(`test/harness/sim_identity_canary_test.rb` — both scripts cross L2)
and re-fire the FULL versioned-bank protocol: **owner approval + a
fresh old-vs-new stream-diff audit + a history row** (the s43 owner
decision — fix-never-rebank unless this exact protocol repeats).

**T3 does not pay it, for three reasons:**

1. **Zero need.** The wall-script author finds the level-up frame with
   a throwaway instrumented driver (the T2 stream-diff pattern:
   headless run, subscribe `:level_up`, print the frame, delete the
   file). The gate judges FRAMES; the byte proof of the level-up in
   every replay log is the `TELEMETRY progression level=2 …` summary
   line WorldScene already prints (`replay_runner.rb` `puts
   @scene.summary`).
2. **Canary silence is a feature.** Amendment 4: Junior's next hook
   run re-proves the ACTIVE bank on his machine. T3 changing zero
   event streams keeps that cross-machine signal clean — a red canary
   on his seat stays unambiguous (SURFACE it, never rebank).
3. It would put an owner-approval dependency inside an otherwise
   self-contained presentation ticket.

RECORDED: any future ticket that wants `:level_up` in wall logs pays
the full protocol above. This brief's decision is the "one decision
carrying that cost" amendment 2 asked for.

## Decision 2 — wiring shape: world-side push at the emit site (why "renderer-side subscriber" cannot be literal)

Physics, verified this session: the harness NEVER constructs
`App::Window` (window.rb header law; `harness/replay_runner.rb`
builds `Scenes::WorldScene` = real World + real Renderer). Anything
wired in window.rb is invisible to every capture — Rule 2 could never
gate it. And the Renderer is a stateless pure reader (locale resolves
at draw; no clock, no records — the comparability law), while a beat
needs a SIM clock with pause laws. That is exactly what
`Game::Transients` is (the kill_pops precedent the spark names).

So the beat lands as: **records in Transients + pushes from world.rb's
EXISTING `:level_up` branch** (actor_died handler — the same inline
shape as the kill_pop push at world.rb:1604). The `:level_up` bus
event stays emitted with zero subscribers — it remains the netplay
digest/audit surface and the future consumer seam. No new world.rb
sim state; net ≤ +6 presentation-push lines (arithmetic in Commit B).

## Decision 3 — strip design (Commit A)

Top-left, inside `draw_hud`, directly under the three hp bars (bars:
y = 16/36/56, h 14 — region ends ~y 72; strip at y 78). One line:
translated label + level numeral + a thin gold progress bar. Bar-only
progress — NO raw xp numerals (quiet-HUD: numeral churn shifts
nothing; J-3 owns detail). Rejected alternatives: bottom-edge ARPG XP
bar (our bottom edge is the verb strip — `controls_overlay_reads`
pins it as verbs + provision counter; a 960px bar would dominate the
quiet HUD) and strip-embedded text (crowds the binding glyphs).

- Label: `"#{tr('hud.level', 'LEVEL')} #{prog.level}"` in `hud_font`
  (14px) at x 32, stamp-gold. Reserved slot: bar starts at fixed
  x 140; widest label "NIVEL 10" fits with room (layout never shifts).
- Bar: back rect + fill rect, x 140, y+4, w 200, h 6. Fill =
  `(bw * prog.xp) / prog.delta_e(prog.level + 1)` — Integer division
  (`level_cap`, `delta_e` are public readers on Progression).
- **Cap display decision:** at `level == level_cap` draw the fill
  FULL (xp pins at ceiling−1 by the award invariant — a 99% bar
  forever would read "almost there"; full reads "done"). No MAX
  string in v1 — recorded, J-3 can add one.
- Colors: label + fill in the stamp-gold family
  (`[200, 160, 80]` / seal `[235, 190, 90]`), back a warm dark — must
  NOT read as a fourth kit hp bar (kit bars are ember/rust/amber and
  14px tall; the 6px gold bar + attached label is the separation).
  The vision critic arbitrates (RETARGET_CUE palette precedent).
- All placement/color keys via `@display.fetch(:key, default)` +
  explicit entries in `data/display.json` (house style: fetch
  defaults keep a bare Renderer drawable). Suggested keys:
  `hud_level_y` 78 · `hud_level_bar_x` 140 · `hud_level_bar_w` 200 ·
  `hud_level_bar_h` 6 · `hud_level_rgb` [200,160,80] ·
  `hud_level_back_rgb` [45,32,22].
- `world.progression` is a public reader (world.rb:46-47); always
  present (T1) — no nil guard.

## Decision 4 — beat shape (Commit B)

Two channels, both already in the house grammar:

1. **Gold stamp banner** — `enqueue_stamp` (world.rb:888-893) with a
   NEW locale key + the level numeral: "LEVEL 2" / "NIVEL 2" /
   "NÍVEL 2". Gold = the court-stamp register (scale-in LAND + rule
   pair, `stamp_delivery_reads` already judges the grammar). Screen
   -only — `at: nil` (no floor seal: the level-up is a PACK fact; the
   pops carry the world-located half). Numeral via the suffix
   mechanism (Decision 5).
2. **Gold shard pops on every LIVING pack member's tile** — the pack
   is the carrier (A2); the bodies that grew, pop. Dead flesh (hp 0,
   kept by P4) does not. New Transients record type `level_up_pops`,
   same `(tile*31/17 + frame) % 997` phase seed, same `pop_frames`
   clock (14, combat.json feel — REUSED, zero new balance data), aged
   by `tick_combat!` (hitstop + wipe-veil pause, like kill pops).
   Renderer draws shards via the existing pure `App::KillPop.shards`
   geometry, gold (`level_pop_shard_rgb` [235,190,90]), **NO white
   flash** (white = spawn/holy, `hurt_flash_not_white` law family;
   the victim tile's kill pop keeps the white flash — the two pops
   co-fire on the boundary kill at DIFFERENT tiles, and color is
   what separates them).

## Decision 5 — banner suffix (locale-invariant numeral tail)

Banner entries carry `text_key` + `fallback`; the renderer resolves
the key at draw (`tr`) — a static table cannot say "LEVEL **2**".
Smallest lawful mechanism: entries gain an optional `suffix` (a
locale-invariant string, default nil), appended AFTER translation in
`draw_banner`. Rejected: printf-style templates in locale files
(machinery for one numeral; keeps data/strings flat K/V) and a
numberless "LEVEL UP" stamp (the new level IS the payoff — Tibia's
advancement line names it; noun-numeral order holds in en/es/pt-br).

## Commit A — the strip

1. **`src/app/renderer.rb` `draw_hud` (:898-924):** append the strip
   block (~12 lines) after the member loop, per Decision 3. Method
   comment: quiet-HUD law + J-3 pointer. No draw-order change —
   `draw_hud` already sits above the writ veil, below the strip/pips.
2. **`data/display.json`:** the six keys (Decision 3), beside the
   existing hud/overlay keys.
3. **`data/strings/{en,es,pt-br}.json`** (41 keys each, parity
   verified this session): add `hud.level` — en `LEVEL`, es `NIVEL`,
   pt-br `NÍVEL` (functional label, translates; numerals invariant —
   register per AGENTS Human-facing surfaces).
4. **`harness/gate_checks.json`** (58 checks): add
   `hud_level_strip_reads` — wording to the effect of: *"Beneath the
   three kit hp bars a LEVEL label with a thin gold progress bar
   reads top-left in every frame showing the HUD; at level 1 with no
   XP the bar may be empty but its dark backing still frames it; the
   fill never overflows the backing; the strip never reads as a
   fourth hp bar."* Always-exercised once shipped (the strip is
   standing HUD, like `hud_three_bars`).
5. **Interplay flag:** read `hud_three_bars` before gating — its
   wording ("three stacked kit-colored bars") does not forbid the
   strip, and the strip is neither stacked-with nor kit-colored. If
   the critic still conflates them, fix the VISUAL separation first;
   amend check wording only for genuine ambiguity, recorded in the
   close draft (recalibration, not check-weakening).

New tests (A): `test/core/strings_parity_test.rb` — en/es/pt-br key
sets identical (guards every future key add; parity is only
hand-verified today). Draw code itself is gate-verified, not
unit-tested (house pattern: pure-math modules get units, draw methods
get critics).

## Commit B — the beat

### 1. `src/game/transients.rb` (58 lines, no cap)

- `@level_up_pops = []` in initialize; `attr_reader` grows.
- `level_up_pop!(tile:, frame:)` — same record shape as `kill_pop!`
  (:21-25): `{ tile:, frames_left: @pop_frames, pop_frames:
  @pop_frames, phase: (tile[0]*31 + tile[1]*17 + frame) % 997 }`.
- `tick_combat!` (:33-36) ages it (comment: level pops pause with
  combat records — hitstop AND wipe veil); `clear!` (:43-47) clears it
  (zone entry drops stale pops with everything else).

### 2. `src/game/world.rb` (1790 → ≤ 1796; every touch is a presentation push)

- `enqueue_banner` (:879-884): signature gains `suffix: nil`; the
  entry hash gains `suffix:,` (fits the existing wrap — target 0/+1
  net).
- `enqueue_stamp` (:888-893): signature gains `suffix: nil`,
  forwarded to `enqueue_banner` (0/+1 net).
- actor_died handler, the EXISTING `:level_up` branch (:1606-1611),
  after the `@bus.emit(:level_up, …)` line (+3 net):

  ```ruby
  enqueue_stamp("stamp.level_up", "LEVEL",
                suffix: " #{@progression.level}")
  @pack.living.each { |m| @transients.level_up_pop!(tile: m.tile, frame: @frame) }
  ```

  (Multi-level single kill emits once and stamps once with the FINAL
  level — correct by construction, `award` loops internally.)
- Delegator `def level_up_pops = @transients.level_up_pops` beside
  :192-194 (+1 net).
- Arithmetic: +4 to +6 net → 1794-1796. Verify with `wc -l`; over
  1796 → stop per the fence.

### 3. `src/app/renderer.rb`

- `draw_banner` (:947-959): after `text = tr(…)`, add
  `text = "#{text}#{entry[:suffix]}" if entry[:suffix]` (+1). Both
  banner paths (bone + gold stamp) inherit it; `draw_breach_line`
  passes no suffix — untouched.
- New `draw_level_pops(world)` (~11 lines) beside `draw_kill_pops`
  (:862-877): shards-only via `App::KillPop.shards`, color
  `@display.fetch(:level_pop_shard_rgb, [235, 190, 90])`, reading
  `world.level_up_pops`. Call it right after `draw_kill_pops` inside
  the camera-translate block in `draw` (:96-125).
- `data/display.json`: `level_pop_shard_rgb`.

### 4. Strings ×3

`stamp.level_up` — en `LEVEL`, es `NIVEL`, pt-br `NÍVEL` (the suffix
carries " N"; rendered: "LEVEL 2" / "NIVEL 2" / "NÍVEL 2" — flat
declarative, the TOLL PAID / BOSS 1 DEFEATED register; parity test
from Commit A now enforces the three-way add).

### 5. Harness: `progression` start param (`harness/support.rb` :24-35)

`apply_start` gains (~+5 lines, before the zone move):

```ruby
if (prog = start[:progression])
  world.progression.load_progress!(level: prog.fetch(:level, 1), xp: prog.fetch(:xp, 0))
  world.pack.sync_max_hp!(progression: world.progression)
end
```

Same seam SaveState.apply! uses (load_progress! → sync — the P3
order), harness plumbing only, no game code reads it (the `banked`
precedent, comment carries the law). T5's `requires_level` fixture
will need staged levels — this param is its primitive too.
`test/harness/scene_start_test.rb` gains lanes.

### 6. The wall script — `harness/scripts/level_up_beat.json`

Recipe (author at implementation, values pinned by an instrumented
authoring run):

- `"scenario": "world"`, 960×540, pinned seed, `start` = a combat
  zone + `"progression": {"level": 1, "xp": 79}` — ΔE(2)=80, so ONE
  rusher kill (15 xp) levels to 2 with xp 14. One kill = the beat
  frame ALSO carries the victim's white-flash kill pop — the exact
  co-occurrence `level_up_beat_reads` must judge.
- Zone: implementer's pick (nest per world_loop's shape, or district)
  — constraint: the kill lands before ~frame 800 (short script) and
  NOT within ~150 frames of zone entry (the zone banner's dwell —
  banner FIFO cap 2 would queue the stamp behind it, shifting capture
  frames; lawful but capture-hostile).
- Authoring instrumentation: temp headless driver (T2 stream-diff
  pattern — `Headless.run_script`-style, subscribe `:level_up`, print
  the frame; delete the file). Then pin `captures`: pre-kill frame
  (strip L1 + near-full bar 79/80), beat+2 and beat+8 (stamp scale-in
  12f window + both pop families live, pop_frames 14), beat+80
  (mid-dwell stamp), beat+170 (post-dwell: strip "LEVEL 2" + bar
  ~14/160). `run_until` ≈ beat+180. ~5-6 captures (wall cost:
  ~5 min/script — this ADDS one script to every future sweep;
  standing price, accepted by the ticket).
- `manifest`: pin the kill (`actor_died` + friends) per
  `harness/manifest_check.rb` semantics — READ the checker before
  writing the block (exact-count vs floor).
- Byte proof in the same run's log: `TELEMETRY progression level=2
  xp=14 kills_xp=15` (grep it in verify — Decision 1's no-EventLog
  stance leans on this line).

### 7. `harness/gate_checks.json`: add `level_up_beat_reads`

Wording to the effect of: *"Where consecutive frames straddle a
level-up: a gate-gold stamp reading LEVEL <N> lands with the rule-pair
stamp grammar, gold shards fly outward from each living pack body's
tile, and these gold pops read distinctly from the white-flash kill
pop at the victim tile. The HUD strip's level numeral is higher and
its bar shorter in the post-dwell frame than pre-kill. If the reel
contains no level-up, pass with why='not exercised by this script'."*
(The escape keeps all 21 existing scripts green on it.)

## New-test expectations (name-level)

- `transients_test`: level_up_pop! lanes — record shape + phase
  determinism, aging via tick_combat! to zero + rejection, clear!
  drops them, pop_frames from config.
- `banner_queue_test`: suffix persists in the entry; suffix-less
  entries carry nil (existing lanes untouched).
- World integration (beside T2's progression_integration pattern):
  stage the boundary via `load_progress!`, one pack kill → banner
  queue holds `stamp.level_up` entry with suffix " 2" + gold color;
  `level_up_pops` has one record per LIVING member at their tiles;
  dead member excluded; kill pop still present at the victim tile.
- `scene_start_test`: progression param stages level+xp AND syncs max
  hp (level>1 lane proves grown ceiling); absent key = no-op; the
  existing banked/zone lanes untouched.
- `strings_parity_test` (Commit A): three-way key-set identity.
- Untouched-by-assertion: sim_identity_canary (T3 moves NO event
  stream — the suite proves it stays green), line_caps.
- Duck law (amendment 5): if any new test double of World appears,
  grow the duck (`progression`, `level_up_pops`) — never
  respond_to?-guard presentation reads.

## Verify ladder (s46, in order — silent-on-pass, verbose-on-fail)

1. Hooks run `bundle exec rake` at each commit (baseline 1068 runs /
   0F, grows). Never `--no-verify`.
2. After A (iteration aid, NOT ship evidence): `SKIP_CRITIC=1 rake
   gate SCRIPT=harness/scripts/world_loop.json` — determinism + a
   look at the strip frames.
3. After B: authoring run → pin the script → full `rake gate
   SCRIPT=harness/scripts/level_up_beat.json` (critic ON). Grep its
   replay log for `TELEMETRY progression level=2` + manifest pass.
4. **Full wall sweep** `harness/run_wall.sh t3-hud` — the strip moves
   EVERY world capture, so the wall debt is ALL scripts (22 × ~5 min
   ≈ 2h). DETACHED (nohup + poll by process count + per-script rc
   lines — never under a bash-call timeout; project memory). **Code
   frozen from sweep start to sweep end** (mid-sweep edits
   contaminated 8/18 baselines once — project memory).
5. Netplay gates, all three (HUD pixels moved in their captures):
   `rake gate SCRIPT=harness/net/netplay_{session,desync,conn_lost}
   .json CHECKS=harness/net/gate_checks.json` — detached, sequential.
6. Targeted KB-rubric critique (the spark's Rule 2 vision half, R-A2
   precedent): `hub kb query --domain uiux-design` for HUD/progress
   -bar legibility → derive the rubric → vision-critique the strip +
   beat captures against it. Verdict lines into the close draft.
7. Locale/language critique (BLOCKING, human-facing-output checklist):
   the two keys × three locales + suffix grammar — accuracy and
   presentation scored separately; es-CR/pt-br read by the checklist,
   not by vibes.
8. `rake perf` — T3 adds zero sim cost (draw-side only); run it
   anyway, p95 < 16.6 ms.
9. Caps: `wc -l src/game/world.rb` ≤ 1796 (hard 1800); window.rb
   untouched at 217; suite's line_caps green.
10. Live-save hygiene: `md5sum saves/world.json` =
    `98fe75edb6d72deab18cd48eaa88bdaf` before AND after.
11. Fresh-eyes review (Rule 6): headless scrubbed pi over the diff
    bundle + this brief + spec — read-only, **touch NOTHING including
    seat mail** (s41 lesson). The review may run DURING the wall
    sweep (both are read-only over frozen code).
12. Close draft `drafts/_prog-t3-close-<date>.md` (gate verdicts,
    critique verdicts, world.rb arithmetic, any T4/T5 amendments) +
    checkpoint entry + next spark. Push (rebase over peer work).

## Notes for the implementer (recorded, no action unless triggered)

- **Flywheel staleness (amendment 3, widened):** the strip appears in
  every frame — ALL pre-T3 clip/critique baselines are stale for any
  HUD-region claim, not just level-crossing replays. Re-baseline
  before trusting old critiques there.
- **Cross-machine canary (amendment 4):** T3 leaves the ACTIVE bank
  untouched by construction (Decision 1). If Junior's hook run reds
  the canary anyway, that is the cross-machine sim-identity signal —
  SURFACE it, never rebank.
- **Banner FIFO collision:** a level-up during another banner's dwell
  queues the stamp (active entry never dropped, cap 2) — the beat
  DELAYS, never vanishes. Lawful; only the wall script routes around
  it (capture determinism).
- **Burst legibility:** the beat co-fires with a kill pop + hitstop
  shake by construction; `burst_legibility_budget` already judges
  that moment. Mitigation is in the design (different tiles, gold vs
  white, no second flash) — if the critic still flags it, tune
  `level_pop_shard_rgb`/size, not the check.
- **Owner-pending carry (never nag):** ear-checks · audio T3
  footstep/bed renders (water family needs a NEW mail) · coop S1 ·
  SHARED-save first crossing · J-5 spike call · WorldSmith proposal
  (INCOMING) · R-A2 escalation call (after the next real play
  session).

## Done condition

Both commits pushed together after the full ladder; the beat and strip
each proven by captured frames + critic verdicts (never eyeballed);
wall grown by one script with its debt paid; locale surfaces critiqued
in all three languages; world.rb ≤ 1796; live save byte-identical;
T4/T5 unblocked (T5 inherits the `progression` start param; the next
save_state ticket inherits NIT 1; the EventLog decision is recorded
with its price).

## Budget + stop

One session. Council 0 (design pinned by spec P4/P12 + T2 close + this
brief; the gate critic + KB-rubric critique are the taste gates).
Sub-agents: the Rule 6 reviewer only. Wall-clock plan: start the ~2h
detached sweep immediately after Commit B's suite is green, run the
reviewer + locale critique during it. If context tightens: A is
independently shippable (its own full-ladder pass), stop before B
rather than half-ship the beat. Stop EARLY on: world.rb refusing to
fit ≤ 1796 (extraction decision goes to the humans), the same gate
check failing twice for the same reason (surface, don't thrash),
spec contradiction, owner redirect.
