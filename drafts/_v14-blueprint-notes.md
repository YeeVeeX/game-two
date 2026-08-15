# v14 blueprint notes (harvested 2026-08-14 from planning session — feed the SPEC)

Companion to the APPROVED plan at
`C:\Users\gabri\.claude\plans\groovy-whistling-spring.md` (read that first).
These are the Plan-agent blueprint details too bulky for the plan file, with the
main-loop review corrections ALREADY APPLIED (verbs live in strings not display.json;
vessel keys added; pulse ships now; re-pilot risk owned).

## Gate check wording DRAFTS (finalize in spec; ADD-ONLY 44→46)

### NEW #45 controls_overlay_reads
"A quiet strip at the bottom edge of the screen shows key glyphs paired with action
labels for the currently possessed body. The strip updates when possession changes (a
different vessel name/verb appears). A brief brighter pulse may accompany the first
possession of a kind (allowed, not required). The strip reads as instructional
reference, NOT as a combat element — its alpha is subdued relative to the HUD bars and
the ledger tally. If the script never shows a living possessed body, pass with
why='not exercised by this script'."

### NEW #46 respawn_telegraph_reads
"When a respawn tell is active (a pulsing ground indicator on a floor tile, pale
green-white family), it reads as 'something is about to arrive HERE' — clearly distinct
from the human attack telegraph (red-edge/yellow-core), volley impact brackets (orange),
the gold gate tiles, and the taunt pulse (rust square). The tell grows or brightens over
its visible lifetime and a human materializes at the tell tile within a few frames of
the tell reaching full intensity. If no respawn tell frame is present, pass with
why='not exercised by this script'."

### AMEND #19 carried_count_reads (never weaken; owner ratifies at twelfth)
Add parenthetical to "appears nowhere else on the HUD": "...appears nowhere else on the
HUD bar area (the bottom-edge controls strip is a separate instructional element, not
the HUD)". Layout-shift clause unchanged.

### AMEND #42 new_ground_reads (only because Longrow ships)
Replace "District One" with "The Longrow"; rest unchanged.

## Locale final states (rename batch + overlay; en fallbacks in zone JSONs change too)

- data/zones/nest.json:3 display_name "The Nest" -> "The First Vigil"
- data/zones/district.json display_name "District One" -> "The Longrow"
- en.json: wipe.line -> "THE FLESH IS SPENT"; add zone.nest/zone.district overrides for
  consistency; overlay.{attack,dodge,special,mark,interact,swap} = attack/dodge/special/
  mark/interact/swap; overlay.vessel.{striker,blocker,lobber} = ithet/goret/hevet;
  overlay.verb.{striker,blocker,lobber} = spin/shout/lob (final wording at spec).
- es.json: zone.nest "La Primera Vigilia"; zone.district "El Corredor" (was "Distrito
  Uno"); wipe.line "LA CARNE SE AGOTA"; overlay ataque/esquiva/especial/marca/
  interactuar/cambio; verbs girar/gritar/lanzar. OWNER ES PASS at debrief.
- pt-br.json: zone.nest "A Primeira Vigília"; zone.district "O Corredor"; wipe.line
  "A CARNE SE ESGOTA"; overlay ataque/esquiva/especial/marca/interagir/trocar; verbs
  girar/gritar/arremessar. JUNIOR PT-BR PASS later.
- Vessel mapping (bible annex): striker=ithet, blocker=goret, lobber=hevet.

## New data keys

display.json: overlay_strip_height 28, overlay_strip_alpha 140, overlay_font_size 12,
overlay_y_pad 6, overlay_x_start 32, overlay_glyph_gap 8, overlay_section_gap 20,
respawn_tell_edge_rgb [180,220,200], respawn_tell_core_rgb [220,240,230],
respawn_tell_max_alpha 180, respawn_tell_pulse_speed 3.
threat.json: telegraph_frames 120.
(Overlay TEXT lives in strings ×3 locales, NOT display.json — i18n law.)

## Telegraph sim notes (world.rb)

- telegraph_due_humans runs in tick BEFORE respawn_due_humans (insertion near
  world.rb:441). Pin via EXISTING respawn_target cascade (1169-1185) + defer rules
  (block 12 / corpse_guard 10 / occupancy). Record gains pinned_tile/pinned_anchor;
  emit :respawn_telegraphed {tile, kit_name, at_frame} (register in World::EVENTS 20-28).
- Materialize at UNCHANGED at_frame re-running today's block+occupancy; blocked -> defer,
  tell persists (plannable: standing near a tell delays it — today's law).
- respawn_frames 300 > telegraph_frames 120 -> no record born past its tell window in
  normal flow. nest_respawn veil: tick_world paused -> stale records materialize
  instantly on resume = today's behavior (pinned). Tells are per-zone (queue keyed by
  zone). Multiple tells render independently (pocket_cap 6 max plausible).
- RNG: if scatter_pick consumes a world-global PRNG, isolate a respawn-derived stream
  (verify at TDD inc 3).

## New script respawn_telegraph.json — mandatory beats (pilot-authored, ≤20 captures)

1 nest baseline: "The First Vigil" banner + strip (initial kit) · 2 enter district
(strip persists) · 3 first kill (starts the 300f clock) · 4 tell appears (~kill+180) —
human NOT present · 5 tell grown (brighter/larger) · 6 materialization at tell tile
(~kill+300) · 7 multiple simultaneous tells · 8 tell + volley brackets same frame
(distinctness) · 9 tell + human attack telegraph same frame · 10 Tab swap -> strip
changes + FIRST-POSSESSION PULSE frame · 11 (optional) wipe veil over strip · 12
post-wipe: strip correct kit. Pilot protocol: rake pilot NAME=telegraph_v14, aim by
event log, export, trim.

## v14 telemetry sketch

telegraphs_shown (subscribe :respawn_telegraphed); first_special_frame per kit
(subscribe the v13 specials event — VERIFY exact name at TDD, likely :special_started);
summary line: "TELEMETRY v14 telegraphs_shown=N first_special{striker=F blocker=F
lobber=F}". Discovery arbitration: earlier first casts vs v13 baselines.

## Size/pressure notes

controls_overlay.rb NEW ~90 lines (renderer.rb 744 -> ~776 with tells+hookup; do NOT
inline the overlay there). window.rb 72 -> 73 (require only). world.rb +~45.
telemetry.rb +~23. Tests: v14_telemetry_test.rb (~60), respawn_telegraph_test.rb (~80),
controls_overlay_test.rb (~40). Total ~190 prod + ~200 test lines.

## Fork variance (all closed, but swaps stay cheap)

pulse = one method body in ControlsOverlay; text = strings values; tell shape =
display.json + one render branch; rename batch = data edits + #42 amendment.
