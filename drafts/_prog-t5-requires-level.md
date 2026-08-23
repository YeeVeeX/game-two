# T5 brief — `requires_level` machinery (P9, full sibling of `requires_defeats`) — cut s50, executes s51

Ticket 5 of Progression v1 — the spec's LAST Lane-1 ticket. Spec:
`docs/superpowers/specs/2026-08-22-progression-v1.md` (P9 body; P14
extraction law; verification-strategy row "gate-refusal cue (T5) —
own wall script committed"; ticket row "T5 — tile_map validation +
crossing gate + refusal cue + fixture zone; cue = visual surface →
own script + gate"). Substrate: T1 extraction (Progression object +
Crossing callable rewire), T2 sim core (level digest rows, `:level_up`
event), T3 presentation (HUD level strip + `start.progression` staging
primitive), T4 close amendments (`drafts/_prog-t4-close-20260823.md`
— verdicts in D6 below). Scope, verbatim intent: `requires_level` as
a FULL SIBLING of `requires_defeats` end to end — load-time
validation, one more fact-gate line in `open?` reading a live
`level:` callable, shut-way cue = the defeats surface PLUS the
required level named (`LEVEL 3 REQUIRED` register). WHERE gates go in
the real world belongs to the WB lane / owners; this ticket ships
machinery + a test fixture zone only. ZERO new sim numbers.

Everything below was verified against live code this session (line
numbers at `75627d8`).

## The seam, as it exists today

- **crossing.rb:49-55** ctor takes `zones:` + THREE live callables —
  `breached:`, `defeats:`, `living:` (the PriceSheet callable
  pattern, named in the comment at :46-48). **:60-64** `open?` is the
  ONE fact-gate seam: sealed branch, then
  `return false if t[:requires_defeats] && @defeats.call < t[:requires_defeats]`.
  **:66-80** `group_wait` pins the returned-cue contract: "the
  waiting cue is RETURNED, written by the caller" (:8-10 — World
  stays the only mutator).
- **world.rb:125-127** wires it:
  `defeats: -> { @progression.boss_1_defeats }` — the verbatim seam
  T5 copies. **:1085-1094** `check_transition` fires for a stationary
  controlled body ON the tile, EVERY non-hitstop tick (rope_spot
  carve-out :1091-1093; ropes reach `cross_through` via the interact
  verb — "ONE crossing grammar", :1097). **:1098-1107**
  `cross_through`: `return false unless @crossing.open?(...)` at
  :1099 — **an unmet defeats gate refuses SILENTLY today**; the only
  player-visible signal is the passive shut slab.
- **renderer.rb:246-249** `way_locked?` — the slab condition, reads
  `world.boss_1_defeats` directly; **:303-310** draws the dark slab +
  thin gold seam ("gold means walkable, never a shut way").
  **:950** the HUD path already reads `prog = world.progression`
  (public reader — harness/support.rb:33 uses it too), so a level
  branch in `way_locked?` needs NO new World delegator.
- **Cue channels live today:** station cue (world.rb:87, :283 clock,
  :1317-1319 `station_cue!` → `{kind:, at:, frames_left:}` — 30f,
  display.json:17) drawn at renderer.rb:559-599 — the
  `:provision_refused` branch (:569-581) is the house REFUSAL
  grammar: X-bar + text at y−32, z 9/10 (presser-stands-on-tile
  z-order lesson already paid); banner FIFO (world.rb:86, cap 2 at
  :881-884, zone banners 150f); `@gate_wait` (world.rb:89, :288 —
  recomputed per tick) is drawn ONLY by netplay_overlay.rb:48/:70 —
  no solo draw path exists for it.
- **Numbers-in-text idiom:** netplay_overlay.rb:61-62 —
  `tr("net.desync", ...).sub("<N>", n.to_s)` — locale rows carry the
  `<N>` placeholder in all three files (verified es/pt keep `<N>`);
  numerals never enter the flat K/V tables (T3 decision 5).
- **tile_map.rb:118-142** `validate_transition_type!` — the
  `requires_defeats` block at :127-131 is the refusal style to
  mirror (`Integer >= 1`, named message). :228-249 s34 seal-gating:
  seals only open `sealed: true` ways — a requires_level-only way
  already refuses as a seal target with NO new code (the law reads
  `t[:sealed]` only).
- **map_artifact.rb:99-106** `seal_stamps` — the god view stamps
  SEALED/OPEN for `t[:sealed] || t[:requires_defeats]` ways via
  `way_locked?`; a sibling gate must join the select or the map lies.
- **Load path traps (both verified live):** world.rb:1181 load_zones
  GLOBS `data/zones/*` — a new file auto-loads at every boot;
  :1186-1189 records the v12 re-anchor trap (a new zone contributing
  arrivals to an anchor-less zone silently re-anchors its gate
  field); world.rb:436-440 `beachhead_shields?` consumes
  `arrivals[@zone_name]` as an ACQUISITION SHIELD — any new arrival
  tile contributed INTO a ratified zone changes that zone's sim.
  Zones without declared `gradient_anchor`: basement_1, basement_2,
  camp, grass_fixture, nest (grep this session).
- **Fixture precedents:** `grass_fixture.json` = hand-authored
  minimal zone in data/zones with a wall script
  (`grass_fixture_walk.json` — 1 of today's 23); zone_edge_validation
  / typed_transitions tests inject mini zones over the REAL store via
  the FixtureStore idiom (no shipped data needed for test lanes);
  `level_up_beat.json` stages `{"progression": {"level": 1, "xp": 79}}`
  — the near-threshold one-kill-levels staging idiom.
- **Curve facts for staging:** ΔE(2) = k·(4−6+4) = 80 at k=40
  (progression.rb:56-58, progression.json); husk kill_xp = 8; husk
  kit exists (combat.json:178). Camera clamps safely on undersized
  zones (camera.rb:31-32 `[world_w − view_w, 0].max`) but a
  zone smaller than the 960×540 view (display.json:3-4) letterboxes
  against void — a `no_render_garbage` false-fail hazard.
- world.rb sits at **1775 / 1800**; crossing.rb 91, tile_map.rb 271,
  renderer.rb 1265 (only window.rb/world.rb are capped —
  test/app/line_caps_test.rb).

## Decisions

### D1 — callable threading: ctor-injected `level:` callable, the defeats seam verbatim

Crossing gains a fourth callable: `level:` — wired
`level: -> { @progression.level }` beside the defeats lambda at
world.rb:126. `open?` gains ONE line, the sibling row:

```ruby
return false if t[:requires_level] && @level.call < t[:requires_level]
```

**Rejected: `open?` argument.** No caller passes live state today
(world.rb:1099 passes zone_name + t only); every live fact Crossing
reads — breach state, boss counter, living count — rides a ctor
callable. Threading level per-call would give ONE fact a different
road than its sibling: the exact divergent-second-grammar P9 forbids.
Ordering pin: the level row lands AFTER the defeats row — gates
compose as independent ANDs (the s34 comment at tile_map.rb:225-227
already legislates AND semantics; "toll bypasses the boss gate" is
recorded there as a sim change, not a validator relaxation — same law
applies to level).

Refusal REASON stays in Crossing too: a second tiny reader

```ruby
# nil unless the level gate is the unmet fact; else the required level
def unmet_level(t)
  rl = t[:requires_level]
  rl && @level.call < rl ? rl : nil
end
```

— the group_wait contract shape (Crossing RETURNS the cue datum,
World writes; :8-10). Rejected: making `open?` return reason enums (a
predicate's boolean contract, house style) and re-reading
`t[:requires_level]` in World (the fact-gate would live in two files
— drift). `unmet_level` reports its own fact regardless of a
co-existing seal — naming the level requirement is true information
even on a way that is also sealed; recorded, exercised in lane 2. No
ratified or fixture zone composes them.

### D2 — the Rule 2 artifact: shipped INERT fixture zone + 24th wall script, full critic-ON gate; the zone is SELF-LINKED (both live interference traps dodged by construction)

**The headline is not a fork.** The spec's verification strategy
names "gate-refusal cue (T5) … with its own wall script committed
(wall debt paid in the same ticket)" and the ticket row repeats it
("cue = visual surface → own script + gate") — ratified text, not
re-litigated (T4-D2 precedent). Fork (a) "unit-tested, never
captured" is therefore REFUSED on the spec's own words — and it loses
on merits too: the cue + slab become player-visible pixels the day
the WB lane authors the first real level gate, and THAT lane gates
zone DATA, not renderer code; the wall must hold these pixels before
data can reach them. What remains genuinely open is the MECHANISM,
and it has three candidates:

- **(c) runtime staging into an existing zone — REFUSED.** The solo
  replay runner has no scene hook (scenes are the netplay harness's
  device), and poking `requires_level` into a loaded ratified map
  would bypass the load-time validator THIS TICKET SHIPS while making
  captures lie about shipped data (a district baseline showing a gate
  district.json does not carry). Fixture-by-mutation is the wrong
  kind of clever.
- **(a′) fixture zone in test lanes only, no shipped zone — REFUSED**
  (needed for lanes, insufficient for the wall): FixtureStore
  injection covers unit/integration, but `rake capture` runs the real
  data root — no shipped zone, no reel.
- **(b) shipped fixture zone + start.zone script — ADOPTED**, the
  `grass_fixture` + `grass_fixture_walk.json` precedent exactly.

**The zone: `data/zones/gate_fixture.json`** (mechanical id;
display_name **"TEST 1"** — generic register, reads dev on sight).
Pinned shape, each pin argued:

- **Its one transition points at ITSELF** (`to: "gate_fixture"`,
  spawn = an interior tile away from the gate). This is the load-time
  interference kill: `validated_arrivals` (crossing.rb:26-45) then
  appends the fixture's spawn to `arrivals[gate_fixture]` ONLY —
  every ratified zone's arrival list keeps its exact members and
  order, so `beachhead_shields?` (world.rb:436-440) and the
  anchor-fallback trap (world.rb:1186-1189; camp/nest/basements have
  NO declared anchor) are untouched **by construction**, not by
  audit. A crossing into camp/district was the tempting alternative;
  it would append a live arrival tile into a ratified zone's shield
  set — a sim change in shipped space for zero coverage gain
  (`enter_zone`/`arrival_tiles` are ratified machinery proven by
  every zone-start reel; T5's only new sim line is in `open?`).
  Self-crossing still exercises the FULL new path end to end:
  open? refusal → open? pass → group_wait → arrival_tiles →
  enter_zone (banner refire + `zone_entered` re-emit + pack
  relocation — all in the log + pixels).
- `requires_level: 2` on that transition; NO seal, NO
  requires_defeats, NO stations, NO regions needed; `floor` absent
  (defaults 0, tile_map.rb:51 — grass_fixture precedent).
- **≥ 31×18 tiles** (view is 30×16.9 at display.json 960×540) — the
  camera clamp is safe on smaller (camera.rb:31-32) but letterbox
  void behind the map risks `no_render_garbage` false-fails; size
  past the view and the question never opens.
- One `"husk"` enemy spawn (enemy_spawns shape `{kit: [[x,y]]}`,
  seed_humans world.rb glob — verified), placed a few tiles off the
  gate line. Gate tile ≥ 2 rows below the top wall so the y−32 cue
  text row stays on-map (a REAL-world authoring hazard too — banked
  as a WB note in the close: edge-row level gates put the cue text
  offscreen).
- Locale rows ×3 files: `zone.gate_fixture.display_name` = "TEST 1"
  locale-invariant (strings_parity_test enforces the three-file law
  mechanically).

**The reel: `harness/scripts/level_gate.json`** (24th script — wall
grows 23 → 24, ~5 min/sweep forever, priced and declared; the 22nd
and 23rd paid the same toll for their surfaces). Staging:
`start: {zone: "gate_fixture", progression: {level: 1, xp: 72}}` —
72 = ΔE(2) − husk kill_xp = 80 − 8, the level_up_beat near-threshold
idiom: ONE husk kill levels the pack mid-reel, so the gate is watched
OPENING LIVE (level moves in sim, not staged past the threshold —
strictly stronger than a two-script L1/L2 pair, and one script
cheaper). Beat: walk onto the gate tile, dwell ~40f (cue + slab +
HUD "LEVEL 1" in frame) → step off, kill the husk (`:level_up` stamp
fires — existing surface) → approach the gate with it visibly GOLD in
frame (way_locked? flips the tile the frame level hits 2) → step on →
self-crossing fires (banner refire, pack snaps to the spawn cluster).
Captures pinned by the pilot at: cue-dwell frame / open-way approach
frame / post-cross frame. Manifest floors = true counts from the
authored log (T4 law): `level_up` 1, `actor_died` 1, `zone_entered`
as logged (self-cross re-emit proven in the event stream). Retune
exposure recorded honestly: the reel's beat depends on ΔE(2)=80 and
husk kill_xp=8 — sim numbers, unfrozen until ritual staging; a k or
kill_xp retune re-authors this reel (s47 re-author precedent), never
blocks the retune.

**New check in `harness/gate_checks.json`** (62nd; flat `{id, check}`
rows, global list with the standard self-scope + escape — T4's
`lobber_reach_reads` pattern): id **`level_gate_reads`**, shape: where
the pack stands at a dark-slab way and a "LEVEL N REQUIRED" line
shows above it, the named N exceeds the HUD level strip's reading and
the way draws the shut slab (dark, thin gold seam — never gold);
where a later frame shows the HUD at or above N, that same way draws
open gold with no requirement line. Absent both, pass with
why='not exercised by this script'. Exact prose is the executor's,
self-scoped from pixels (the T3 HUD strip is what makes it judgeable
— same trick as lobber_reach). `sustain_refusal_cue_reads` keeps
judging the provision X-bar; no existing check text moves.

**The map artifact moves and its gate rides:** the god view gains a
12th panel (TEST 1) and `seal_stamps` (map_artifact.rb:100-106) gains
`|| t[:requires_level]` so the level gate stamps SEALED/OPEN like its
sibling (the select reads `way_locked?`, which D3 extends — one
condition source, the comment law at renderer.rb:241-243). The wb-t5
wire-in re-ran the "eleven-panel map gate" when zones were added —
same precedent: `rake map PROBES=1` + map_checks critique once at
commit B. No replay half (decision 13).

### D3 — cue surface: the station-cue channel, new kind `:level_required` — gate-wait and banner REFUSED

The refusal cue rides `station_cue!` (world.rb:1317-1319) with a new
kind, drawn by the `:provision_refused` grammar (renderer.rb:569-581
— X-bar on the stood-on tile at z 9, text line at y−32 z 10; the
"refusal must never read as nothing" law, v18 decision 9, and the
presser-stands z-order lesson both already paid). Write point: in
`cross_through`, on the refused branch —

```ruby
unless @crossing.open?(@zone_name, t)
  if (n = @crossing.unmet_level(t))
    station_cue!(:level_required, t[:at], n: n)
  end
  return false
end
```

`station_cue!` gains an optional `n: nil` kwarg folded into the
record; all seven existing callers (:624 :630 :1257 :1280 :1305
:1323 :1335) are untouched. `check_transition` re-fires every stationary tick
(:1085-1094), so the cue REWRITES per tick while standing — alive on
the tile, 30f dwell (display.json `station_cue_frames`) after
stepping off; the gate_wait recompute-per-tick law (:285-288), on the
existing cue channel. Deterministic per tick → replay-identical.
Digest-safe by standing law: station cues are named in the
presentation-exclusion list (world.rb:639-640). A level-gated ROPE
cues on interact-press through the same cross_through — sibling for
free; the fixture uses a plain auto-fire gate.

- **gate_wait channel REFUSED:** netplay_overlay is its ONLY draw
  path (netplay_overlay.rb:48/:70) — solo captures (the wall renders
  locale "en", solo) would show NOTHING; building a solo draw for
  gate_wait = a new surface for no reason when the refusal grammar
  exists.
- **Banner queue REFUSED:** FIFO cap 2 with eviction (:881-884) under
  a 150f zone banner means the refusal can queue BEHIND the zone
  banner or evict — timing-coupled capture frames; and banners are
  zone-wide announcements ("places announce, courts judge",
  renderer.rb:980-984) while this is a tile-local fact. Collision
  with zone banners is impossible for the adopted channel BY
  GEOMETRY: tile-anchored y−32 text vs top-center y=48 banner — no
  dwell/priority tuning needed, which is exactly what the spark's
  worry reduces to.
- Slab half: `way_locked?` (renderer.rb:246-249) gains the sibling
  branch reading `world.progression.level` (the :950 read path — no
  new delegator; ONE condition source shared by draw + map, comment
  law at :241-243). The defeats gate itself stays cue-less this
  ticket — P9 names the level in THE LEVEL GATE's cue; retrofitting
  defeats with text is unratified scope (recorded as a future parity
  candidate, nothing more).

### D4 — locale keys: pinned here, s51 copies (authors zero prose)

`data/strings/{en,es,pt-br}.json` gain ONE cue row each (+ the zone
row from D2). `<N>` substitutes at draw (`.sub("<N>", cue[:n].to_s)`,
the net.desync idiom, netplay_overlay.rb:61-62) — numerals never
enter the tables (T3 decision 5).

| key | en | es | pt-br |
|---|---|---|---|
| `cue.level_required` | `LEVEL <N> REQUIRED` | `NIVEL <N> REQUERIDO` | `NÍVEL <N> NECESSÁRIO` |
| `zone.gate_fixture.display_name` | `TEST 1` | `TEST 1` | `TEST 1` |

Register: terse functional ALL-CAPS, noun-first passive — parallel to
the shipped refusal row (`REFUSED` / `RECHAZADO` / `RECUSADO`) and
the P9 placeholder verbatim (`LEVEL 3 REQUIRED` at N=3). Renderer
fallback: `CUE_TEXT_FALLBACK` (renderer.rb:187-189) gains
`level_required: "LEVEL <N> REQUIRED"` (strings-less construct law).
strings_parity_test enforces three-file key parity mechanically. The
EXECUTE session owes the Rules 2/6 language critique on the gate's
vision verdict (accuracy + presentation axes); with strings pinned
here, its authoring surface is nil — the critique judges the RENDER
(legibility, collision, register in-frame).

### D5 — netplay / digest / save / telemetry: NOTHING moves — argued, not asserted

- **Digest:** `level` and `xp` rows ship since T2 (world.rb:658);
  `open?`'s new line is a pure function of a digest-covered fact +
  static zone data — cross-seat divergence is impossible without a
  digest divergence already refusing. The cue is presentation,
  digest-EXCLUDED by the standing law (world.rb:639-640). Digest byte
  FORM untouched → **no DIGEST_VERSION move** (the version law tracks
  form; T4-D7 precedent).
- **Netplay gates NOT owed:** no wire shape change, no digest fold
  moved (T4 re-gated because the impact fold RELOCATED; T5 relocates
  nothing). The data/ additions move the sim fingerprint — that is
  the fingerprint doing its job (hashes data/** EOL-normalized;
  both seats on one commit = one fingerprint; standing law, no new
  machinery).
- **Save schema untouched:** `requires_level` is ZONE data read at
  crossing time; the gate reads the LIVE pack level through the
  callable — nothing new persists, nothing decodes. (Contrast
  breach facts: those persist because tolls SPEND; a level gate
  spends nothing.)
- **TELEMETRY untouched:** the P12 close line stays frozen-shaped for
  the pending ritual (level already on it; a gate-refusal count would
  be a new field against measurement hygiene for zero oracle value).
  **No new bus event either** — non-negotiable 4 defines events at
  first USE and nothing consumes a `:crossing_refused`; evidence
  lives in captures + the cue record lanes + EVENT rows the reel
  already emits (`level_up`, `zone_entered`). Soak regexes untouched;
  the fixture is inbound-unreachable so bots can never enter it.
- **Perf not owed:** validation is boot-only; `open?` runs on
  stood-on-transition ticks; `way_locked?` gains one hash read per
  transition per frame (transitions per zone ≤ ~6).

### D6 — T4 amendments: where each rides (one paragraph, one verdict, each)

1. **`lobber_reach_reads` "four or more" — DORMANT.** The amendment's
   own trigger is "whenever the check text next moves lawfully"; T5
   ADDS a sibling row to gate_checks.json and moves no existing
   wording — adding a row is coverage, not recalibration (T4 added
   the 61st row without touching the other 60). No L8 lobber reel
   exists today (level_gate stages L1→2; lobber never casts in it),
   so the false-fail window stays empty. Verdict: stays banked.
2. **Duplicate-threshold uniqueness (`"5"`+`"05"`) — DEFER.** Its
   home is "whichever ticket next touches the Progression ctor or the
   data-coherence lane"; T5 touches NEITHER file — the level gate
   lives in zone data (tile_map) and Crossing, progression.rb is
   read-only through two existing readers. Lane 1 ends with T5, so
   the close must RE-BANK this amendment explicitly for the next
   progression.json/ctor toucher (likely the ritual-stage numbers
   freeze or a pacing retune). Verdict: defer, carrier named in the
   close draft.
3. **Authoring shelf (d8-flip press rule, hate-peel) — RIDES as
   reference only.** The level_gate reel kills one husk in an empty
   room — no timed-impact staging needed; the notes travel to the
   pilot session unused unless approach timing surprises. Verdict:
   cite, expect no use.
4. **Pixel canary bank pre-T3-stale — CARRIED, no action.** T5's
   identity proofs are md5 pairs + the suite's event-stream bank (the
   real canary, T4-D4 law). Rebanking stays owner-word protocol.
   Verdict: inherited note repeated in the close, nothing else.

### D7 — world.rb line arithmetic: fits WITHOUT an extraction; J-7 flagged

Gross adds to world.rb: ctor callable line (+1, commit A);
cross_through refused-branch rewrite (1 line becomes ~6: +5) +
`station_cue!` kwarg (signature + record edit in place, +0..1) — all
commit B. 1775 + ~7 → **lands ≤ 1783**, headroom ≥ 17 under the 1800
cap. Non-negotiable 1 binds a MATERIAL TOUCH AT THE CAP — 1775 is not
at the cap and +7 is the smallest lawful touch (the cue write cannot
live in Crossing: Crossing never mutates, :8-10). No carve owed; a
speculative extraction here would be breadth-work outside the ticket.
**Flag for the NEXT world.rb brief-cutter (J-7, Lane 3):** ~17 lines
is one small feature from the wall — J-7's brief must open with the
extraction question, Crossing/Volleys precedent. crossing.rb ~+9
(→ ~100), tile_map.rb ~+5 (→ ~276), renderer.rb ~+11 (→ ~1276),
map_artifact.rb +0..1 — none capped.

## Commit cut (two one-concern commits — T4's A/B shape)

**A `feat(crossing)` — the gate exists; sim truth only, zero pixels,
zero data/ moves.**
`src/core/tile_map.rb` (validate_transition_type! gains the
requires_level block mirroring :127-131) · `src/game/crossing.rb`
(ctor `level:`, open? sibling line, `unmet_level`) ·
`src/game/world.rb` (ctor wire :126 region, +1 line) · test lanes 1-3
(FixtureStore-injected zones — no shipped fixture yet). The refusal
is SILENT at A (defeats parity — exactly today's behavior for its
sibling). Verify at A: suite via hook (new lanes green, event-stream
canary green) · double-capture md5 identity pair on `world_loop` +
`low_quay_run` (SKIP_CRITIC lawful — byte-identity claim; low_quay
chosen as the nearest neighbor: it carries the live defeats gate +
seal surface) · line counts (world ≤ 1776) · live save md5 untouched
· `git diff data/` EMPTY.

**B `feat(presentation)` — the refusal speaks; every pixel + every
declared data move.**
`src/game/world.rb` (cross_through cue write + station_cue! `n:`
kwarg) · `src/app/renderer.rb` (way_locked? sibling branch ·
`:level_required` draw branch beside :provision_refused · `<N>` sub ·
CUE_TEXT_FALLBACK row) · `src/app/map_artifact.rb` (seal_stamps
select + requires_level) · `data/zones/gate_fixture.json` (D2 pins) ·
`data/strings/{en,es,pt-br}.json` (D4 rows verbatim) ·
`harness/scripts/level_gate.json` (pilot-authored; throwaway driver
deleted, T3 amendment 2) · `harness/gate_checks.json`
(`level_gate_reads`) · test lanes 4-6. Verify at B: suite via hook ·
**full critic-ON `rake gate SCRIPT=harness/scripts/level_gate.json` +
manifest** (language critique rides the vision verdict — D4) ·
`rake map PROBES=1` + map_checks critique (12th panel + level-gate
stamps — D2) · identity pair AGAIN (world_loop + low_quay_run md5 ×2
— proves the fixture's boot-load + the locale/kwarg/renderer touches
moved zero ratified pixels) · `git diff data/` matches EXACTLY the
four files above, nothing else · live save md5 untouched · world.rb
≤ 1783 + line_caps green.

Fresh-eyes review (Rule 6) at close — scrubbed headless session over
diff + this brief + spec, read-only, "touch NOTHING including seat
mail" in the prompt (s46 lesson).

## Wall-debt audit (D2/D3 code touches existing reels? — mechanically, ZERO re-gates)

The changed code paths, per reel exposure at `75627d8`:

| touch | fires when | ratified-world exposure |
|---|---|---|
| tile_map validation | `requires_level` key present at load | `grep -rn requires_level data/zones/` = **0 matches** (this session) → dead branch for all 11 zones |
| open? sibling line | standing on a transition WITH the key | same 0 matches → unreachable |
| cross_through refused branch | open? false | reels that stand on SHUT ways hit `unmet_level` → nil → `return false` — byte-path identical to today |
| way_locked? branch | per-transition draw | `t[:requires_level]` nil in every ratified zone → boolean unchanged → same pixels |
| station_cue! `n:` kwarg | every station cue | record gains `n: nil` — presentation record, digest-excluded (world.rb:639), no reader iterates keys |
| locale +2 keys/file | key lookups | additive; no existing lookup changes |
| gate_fixture.json boot-load | every boot | self-linked: contributes arrivals ONLY to itself → beachhead sets + anchor fallbacks of all 11 ratified zones keep exact membership AND order (relative sort order of existing zones unchanged by an insertion) |

Every row lands on "no ratified pixel or sim byte moves" — and the
two identity pairs (A and B) convert that argument into md5 proof at
both commits, T4-D4's assumption→bytes discipline. Re-gate list:
**empty**. New-gate list: level_gate (full critic) + map gate, both
at B. Netplay gates: not owed (D5). The 23 existing baselines,
including the five s47 L5-staged reels and the three cue-bearing
reels (sustain_run, vat_economy — provision cues; low_quay_run —
seal), stay untouched by construction.

## Test debt (numbered; A = commit A, else B)

1. (A) tile_map unit, mirroring :136-150: `requires_level` parses on
   any transition · refuses 0 / negative / non-Integer / Float NAMED
   (`requires_level must be an Integer >= 1`) · co-exists with
   `requires_defeats` on one transition (both validate) · a seal
   `opens` naming a requires_level-ONLY way still refuses via s34
   (existing message — belt proving the sibling composes, zero new
   validator code).
2. (A) crossing unit: `open?` false below / true at / true above the
   required level (callable-fed) · sealed+level compose as AND ·
   `unmet_level` → N when unmet, nil when met, nil when key absent,
   N even when the way is ALSO sealed (D1 pin).
3. (A) world integration (zone_edge_validation FixtureStore idiom,
   real World over injected zones): cross_through below level →
   refuses, pack tiles unchanged, `station_cue` NOT set (A is
   silent!) · at level → `zone_entered` emitted, pack relocated ·
   live path: `award_kill` to the threshold then cross_through
   succeeds (the reel's beat, headless).
4. (B) world/renderer cue lanes: refused cross_through sets
   `{kind: :level_required, at: gate_tile, n: 2}` · per-tick rewrite
   pins frames_left · `station_cue_text` resolves the key and the
   `<N>` sub renders "LEVEL 2 REQUIRED" (strings + fallback both) ·
   `way_locked?` truth table over level (locked below, open at).
5. (B) map_artifact lane (mirror :120): a requires_level transition
   stamps SEALED below / OPEN at level through seal_stamps.
6. (B) strings parity: automatic (existing strings_parity_test) —
   the two new keys land in all three files or the suite is red.
7. Line caps: existing test green; world.rb landing number recorded
   in the close draft (D7 arithmetic honesty).

## Session budget + stop conditions (s51)

One session: 2 commits · 7 lanes · 1 hand-authored fixture zone · 1
pilot-authored reel (throwaway driver, deleted) · gates = 2 identity
md5 pairs + 1 full critic gate + manifest + 1 map gate. Council 0
(design ratified; this brief argues from live code). Sub-agents: the
Rule 6 reviewer only. Stop EARLY on: Job-0 defect-class delta ·
either identity pair md5 moving at either commit (= the
zero-interference law breaking — a DEFECT, stop, never rebaseline) ·
event-stream canary red · the fixture zone refusing to validate
minimal (validator gap — name it, park it, stop) · world.rb refusing
to fit ≤ 1790 (arithmetic wrong — stop and re-cut, don't shave) · the
cue text colliding with any HUD element in the authored captures
(re-place the gate tile southward and re-author, one retry; second
collision = stop, surface the layout question) · owner redirect (a
Lane-2 B-knob re-session order preempts — data moves land before the
ritual stages).

## Owner-visible notes (for the peers, never nag)

- The god-view map gains a 12th panel, **TEST 1** — a dev island for
  the level-gate wall proof, self-linked, unreachable in play. Rename
  or relocation is an owner word away; machinery doesn't care.
- First REAL level gate placement (which way, which level) is a WB
  lane / owner decision — the machinery ships dark until then. When
  it lands: edge-row gates put the refusal text offscreen (cue draws
  at y−32 above the tile) — authoring note banked for the WB checklist.
- Ritual wording stays UNWRITTEN; nothing in T5 touches the frozen
  TELEMETRY shape or any sim number the pending ritual measures.

## Scope fence

data/ moves = EXACTLY four declared files (zone + three strings), all
in commit B, `git diff data/` audited against this list · zero
`data/balance/**` moves · no TELEMETRY/soak-regex/event-registry
change · no save-schema touch · no DIGEST_VERSION move · window.rb
untouched · renderer touched ONLY at the three D3 sites · ritual
wording UNWRITTEN · live save md5 open/mid/close · one-concern
commits · the s45/s48 brief-writer precedent held: this session wrote
ZERO code.
