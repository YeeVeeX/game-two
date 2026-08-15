# v16 — THE PRESENTATION/IDENTITY CYCLE: scaling, zone identity, stamp delivery, dread, kill pop

Scope authority: AGENTS.md scope contract (debate closed 2026-08-15, owner
ratified; multiplayer → v17 behind two triggers). Design forks closed on
DEV RECOMMENDATION (v13 precedent — owner may veto any at the fifteenth
debrief): **(1) integer window scaling, harness pinned 1; (2) hue-family
zone palettes + motif + ambient, value structure constant; (3) dread
stakes = inscription burns on seized death.**

Oracle: the FIFTEENTH blind ask — **does each zone LOOK like a place**
(recognizable without its banner) + **did Varekka scare you** (the
re-weighed dossier's second chance) + **do the stamps land**.

Evidence base: fourteenth verdict (`drafts/_v15p5-fun-verify-20260815.md`)
— Q2b flat despite seized=2 (fair+legible+affordable ≠ scary), Q6c names
false in situ, P5 legibility deferred to this cycle. Kimi localization
critique folded (3-probe calibration; grounded candidates).

## Scope (five pieces + the language lane)

IN:
- **(a) Resolution scaling** — `display.json window_scale: "auto"|integer`.
  Window opens at 960k×540k; ONE `Gosu.scale(k)` wraps the draw. Sim,
  logical coordinates, and the capture pipeline are untouched — harness
  pins scale=1 (same law as pinned locale). Auto = largest integer fit
  within the SCREEN dimensions (full res — work-area fit would refuse 2x
  on 1080p taskbar setups; live deviation from the draft, recorded), min 1.
- **(b) Zone visual identity** — palette redesign per zone (data-only on
  the existing `palette` slot) + two NEW data-driven renderer channels:
  `motif` (sparse deterministic floor pattern, per-zone glyph) and
  `ambient` (post-map alpha tint). Hue carries identity; value structure
  stays constant (floor dark / wall light / gold = walkable — legibility
  law unchanged).
- **(c) Stamp delivery** — court stamps land like stamps: scale-in over
  `stamp_in_frames`, dwell, fade tail; a top+bottom rule pair (the acta
  look). Zone banners keep a calmer entrance (they are places, not
  judgments). All timing/geometry in `display.json`.
- **(d) Varekka dread** — sim: `seizure_burns_inscription: true` in
  `balance/combat.json challenger` — if the seized body DIES while
  seized, its god-mark BURNS (the court's claim overrides the vat's;
  fiction: he speaks the suvrim's stolen clauses). Burn beat: stamp
  `THE MARK IS VOID` + existing expiry-flash visual on the body tile.
  Presentation: dread veil — world dims/desaturates while a chant runs
  (`chant_veil_alpha`), seized body renders with heavy visual weight
  (existing seized underline + darkened body). No audio (owner order).
- **(e) Kill pop** — deaths POP: a one-shot burst of 6 deterministic
  rect-shards (angle = f(tile, frame) — pure function, no RNG stream) +
  corpse flash frame + existing kill hitstop. Keys in `combat.json feel`.
- **Language lane** (owner-approved pipeline; runs AFTER (a)+(c) ship):
  3-probe register calibration on captures (attested-notarial / plain /
  game-generic, owner picks blind) → grounded candidates for lines the
  owner NAMES as false (attested formulas + bible, constrained mutation)
  → on-capture ratification. Dev never composes ES/PT alone.

OUT (PARKING_LOT): sprites/art-asset identity pass (rects remain the
medium — identity via palette/motif/light this cycle); font-native hi-res
text (escalation lever ONLY if the fifteenth still reads small); audio;
new zones/enemies/systems beyond (d); minimap; in-game rebind UI.

All palettes/numbers in `data/`; zero balance constants in Ruby; checks
ADD-ONLY 49 → 53. Full wall re-run at close (comparability reset, the
Nest-rename law) + critic recalibration against the new look.

## Design decisions (numbered, each with rationale)

1. **Integer scaling, logical frame untouched (fork 1).** The complaint
   is SIZE ("casi no se entienden las letras"), not texture quality.
   Integer upscale solves size; keeping captures at 960×540 preserves
   the determinism half byte-for-byte and spares 49 checks' pixel-size
   prose from a substrate rewrite. Fractional scales forbidden (shimmer);
   `window_scale` accepts "auto" or an integer ≥1. Harness/replays pin 1.
   `Gosu.scale` verified present on this machine's Gosu 1.4.6 (module
   function, block form scopes the transform — review claim refuted live).
   Escalation lever recorded: font-native scaled text (crisper), only if
   the fifteenth still reads small.
2. **Hue families + LANDMARKS, constant legibility contracts (fork 2,
   amended per GLM review).** Identity rides HUE + VALUE spread + a few
   authored LANDMARKS; legibility contracts hold (wall lighter than
   floor, gold = walkable ONLY — review caught the brazier-gold conflict:
   Second Vigil accents are EMBER ORANGE/RED, never gold). Hue-only
   shifts at dark values were judged insufficient ("monitor gamma error")
   — so the identity block adds a `decor` channel: per-zone AUTHORED
   landmark features (2×2/3×3-tile stains, channel-edge highlights,
   brazier rects), render-only, never blocking, placed in zone data —
   silhouette identity without touching passability or replays. Palette
   directions (tuned at TDD behind captures): First Vigil = ash + ember
   warmth; The Longrow = sun-baked clay/ochre; The Keyward = cold
   slate/indigo; Second Vigil = warm gray + ember accents; The Slow Door
   = dusk violet; The Low Quay = drowned green-black (already the
   darkest floor — push the spread wider). Motif glyphs stay as sparse
   texture (~1/9 tiles), INTEGER arithmetic only ((tx*7+ty*13)%9-style;
   no floats in placement).
3. **Stakes = inscription burn (fork 3).** The fourteenth's diagnosis:
   seizure threatens a body, and bodies are refundable (28 regrows,
   banked_end 258) — so he tanked both seizures. The inscription is the
   one thing the economy CANNOT refund (it survives judgment; that is
   its entire meaning) — burning it on seized death makes Varekka the
   only entity that pierces the vat's protection. Data-only switch +
   one beat. Alternatives rejected: banked tithe drain (money is
   refundable by definition — same bug), permanent body loss
   (run-ending; the gone-for-session precedent declined it).
4. **Stamps ≠ banners — and located stamps land IN the world (amended
   per GLM review: screen-space scale-in alone reads "achievement
   popup").** Court stamps keep the screen banner for TEXT (floor text
   at 32px is illegible) but any stamp with a tile locus (seal breach,
   mark void, term paid) ALSO lands a floor SEAL MARK at the event tile:
   a rect frame + inner glyph in stamp gold, dwells with the banner,
   fades — the act visibly happens IN the world. Zone banners keep a
   quiet fade (places announce, courts JUDGE). Prevents ceremony
   inflation — if everything stamps, nothing does.
5. **Kill pop is deterministic by construction.** Shard angles/lengths
   derive from (tile, frame) — no RNG stream, no replay divergence, same
   law as Feel's sin/cos shake.
6. **Language lane sequencing.** Delivery before re-wording (Q6c may be
   half delivery); probes before candidates (learn what "falso" points
   at); re-word ONLY owner-named lines (Q6 routing law from the
   fourteenth).

## Sim spec (only (d) touches the sim)

- `challenger.seizure_burns_inscription: true` (data). In
  `end_seizure(body, :died)`: if the body was inscribed → consume the
  mark (existing mark-consumption path), emit `:inscription_burned
  {body:, at:}` (bus event, registered on first use), enqueue stamp
  `stamp.mark_void` (locale key; EN "THE MARK IS VOID"; ES/PT via the
  pipeline). **Ordering discipline (DeepSeek review fold, TDD-enforced):**
  inscribed state is read AT the seizure-death moment, BEFORE corpse
  bookkeeping touches the body; deaths process in stable array order
  (the sim iterates arrays, never hashes) — tests: burn fires exactly
  once; uninscribed seized death burns nothing; wipe-path mark
  consumption and burn can never double-consume. Telemetry: `varekka`
  line gains `burns=N`.
- Everything else is render-only. Tick order, RNG streams, walker,
  camera: untouched. Determinism invariant: same inputs → same frames,
  verified by the wall's double-replay md5 as always.

## Presentation spec (Rule 2 surface — every item lands in a capture)

- Scaling: window 960k×540k; `Gosu.scale(k) { renderer.draw(world) }` in
  Window#draw only. HUD/strip/banners live in logical space (unchanged).
- Zone identity: `palette` gains optional `motif_rgb` + `motif` (glyph
  name) + `ambient_rgba`. Renderer: motif rects after grid, ambient quad
  after map, both before actors. Fallback: absent keys = current look
  (any zone without an identity block renders exactly as today — old
  captures of unmodified zones stay valid).
- Stamp delivery: display keys `stamp_in_frames: 12`, `stamp_rule_pad`,
  `stamp_rule_rgb`; scale eases 1.6→1.0 over the in-window (linear, no
  easing curve constants in code — factor endpoints in data). Banner
  (zone) keeps current fade; stamp queue behavior (FIFO, max 2) unchanged.
- Dread: **the WRIT-FRAME** (GLM review fold — a full-screen alpha veil
  reads as a GPU glitch and threatens fairness): while a chant runs, a
  square ritual frame centered on Varekka (side `writ_radius_tiles*2`,
  thin chant-blue border) is drawn; the world OUTSIDE the frame darkens
  hard (`writ_out_alpha: 140`), INSIDE stays fully readable — the court
  draws its writ around you; dread + the fairness ladder both served.
  Veil state is a pure per-frame reader of chant-active (no stored
  state: nothing to flicker or stick; `abort_all_chants!` already fires
  on zone transition — DeepSeek edge cases covered by construction).
  Seized body: darkened toward chant-ring blue.
- Kill pop (re-weighted per GLM review — flash is the primary channel):
  corpse FLASH 5 frames solid bright (the check target) + 8 radial
  shards 3-4px (secondary, motion read) + existing kill hitstop. Shards
  age by SIM frame (hitstop pauses them like all impacts — world.rb
  already gates on hitstop; deterministic by construction), geometry =
  integer f(tile, frame_of_death), `pop_frames: 14`.

## Harness + gates

- **Scale pinning**: replay_runner never reads `window_scale` (captures
  call `Gosu.render(960, 540)` directly — already logical). A test pins
  this: harness window dimensions are scale-independent.
- **Comparability reset**: palettes/motifs/stamps/pop change nearly every
  frame → ALL 16 scripts re-gate against the new look; critic
  recalibration expected on identity checks. Determinism (md5 double-run)
  must hold — render changes are pure functions of world state.
- **Checks ADD-ONLY 49 → 53**: #50 `zone_identity_reads` (two different
  zones in a reel are distinguishable by palette/landmark alone — judged
  on low_quay_run which crosses 4 zones); #51 `stamp_delivery_reads`
  (scale-in visible across consecutive frames + rule pair + floor seal
  mark on located stamps); #52 `kill_pop_reads` (death frame shows the
  corpse flash — flash is the target, shards secondary; kill-evidence
  clause carried from #42's amendment); #53 `writ_frame_reads` (chant
  frames show the frame + outside-darkening while ring AND bodies stay
  readable inside — fairness wording built in). **varekka_duel re-pilot
  stages an inscribed seized death** so the burn beat is exercised on
  camera (manifest gains `inscription_burned >= 1`) — DeepSeek's
  script-dependence finding answered: the beat gets a designated
  exerciser, same law as checks 48/49.
- Perf: `rake perf` after the veil/motif (full-screen quads + per-tile
  motif rects are the only new draw cost; budget unchanged 16.6ms).

## Watched risks (pre-registered)

- **W1 — scaled-window text metrics**: Gosu::Font metrics are
  scale-independent (logical space) but SUBPIXEL positioning under
  Gosu.scale can shimmer on odd scales. Mitigation: integer scales only.
- **W2 — critic drift on recalibration**: 4 new checks + a new global
  look may re-trigger the ensemble-variance flake (v15.5 pattern).
  Protocol carried: standalone retry before believing a FAIL; real fails
  reproduce.
- **W3 — writ-frame vs legibility**: outside-darkening must never hide
  an approaching threat crossing INTO the writ. #53's wording enforces
  "ring and bodies read"; alpha lives in data for tuning.
- **W4 — inscription burn feels bad, not scary**: possible verdict:
  punished, not frightened. Pre-registered routing at the fifteenth: Q3
  "lo evité/interrumpí" (behavior change) = stakes WORK even if Q2 stays
  flat → next lever is presentation-of-threat, not more cost. Q2 scared →
  CHALLENGER VALIDATED, dossier closes.
- **W5 — motif noise**: sparse motifs must not read as items/drops.
  Density capped (~1/9 tiles), no gold hues (gold = walkable, reserved).
- **W6 — the possessed must survive the repaint (GLM review)**: the
  white possession ring + facing notch are the game's primary anchor;
  every identity channel (palettes, landmarks, writ-frame, flashes) is
  judged against possessed readability — the existing
  `possessed_readable` check re-arbitrates on the new look across all
  scripts; any conflict resolves in the ring's favor.

## TDD increments (each green + committed before the next)

1. **(a) scaling** — display key + Window scale math + harness pin test.
2. **(e) kill pop** — feel keys + deterministic shard function (unit:
   same tile+frame → same shards) + renderer draw + corpse flash.
3. **(c) stamp delivery** — display keys + banner rework (stamp path) +
   timing unit tests (in/dwell/fade window math).
4. **(b) zone identity** — 6 palette redesigns (data) + motif + ambient
   channels + fallback tests (absent identity block = byte-identical
   draw of today's look on a probe zone).
5. **(d) dread** — burn sim (+ event + telemetry + stamp) with tests
   (burns only when seized AND dies; uninscribed body burns nothing) +
   veil + seized weight.
6. **Language lane** (owner-gated): 3-probe calibration → grounded
   candidates for named lines → on-capture ratification → strings land
   (harness pinned en; gates untouched).
7. **Wall reset**: all 16 scripts re-gated + manifests; perf; suite.

## Fun-verify protocol (FIFTEENTH — pre-registered; plain Spanish at the ask)

Protocol unchanged: owner plays `bin/play es` first, no changelog;
telemetry harvested before questions; verdict verbatim to drafts.

1. **TITULAR A — identidad:** entrando a cada zona (el Bajofondo sobre
   todo), ¿se VE como un lugar propio — lo reconocés sin leer el banner?
2. **TITULAR B — Varekka:** ¿esta vez te asustó? ¿tu cuerpo reaccionó?
3. **La marca quemada:** si perdiste una inscripción con él, ¿cambió cómo
   jugás a su alrededor (lo evitás, cortás el canto, cambiás de cuerpo)?
4. **Los sellos:** ¿aterrizan ahora — se sienten como actos del tribunal?
5. **Legibilidad:** con la nueva resolución, ¿se lee todo? ¿algo sigue
   chico?
6. **Las muertes:** ¿se sienten — golpean?
7. **Nombres (después de la calibración):** ¿alguno TODAVÍA suena falso?
   ¿cuáles?
8. **Global:** ¿algo injusto?

Routing (mechanical): Q1 "otro distrito" → identity dose insufficient →
landmark/geometry lever (NOT more palette). Q2 scared → CHALLENGER
VALIDATED, dossier closes. Q2 flat + burns>0 + Q3 behavior-change →
stakes work, fear is presentation → threat-presentation lever. Q2 flat +
Q3 flat → challenger rework PARKS (fundamental redesign, not iteration).
Q5 "algo chico" → font-native scaling escalation. Q7 named lines →
grounded re-word THOSE only. Q8 anything → fairness lane per difficulty
law. Telemetry arbiters: varekka{interrupted + swap_escapes} > 0 (counters
finally USED = fear behavior), burns, quay dwell vs fourteenth.

## Deliberately absent (recorded so review doesn't re-litigate)

- **Sprites/art assets** — a different medium, its own cycle + pipeline;
  this cycle proves how far palette/motif/light/juice carry rects.
- **Font-native hi-res text** — escalation lever behind Q5, not default.
- **Audio** — owner order stands (placeholder hooks only).
- **Varekka phases/variants, new counters** — one man, one sentence, one
  death (v15 law); only his STAKES and PRESENCE change here.
- **Minimap / fast travel / quest markers** — navigation IS the game
  (Tibia law); identity should make zones navigable by look instead.
