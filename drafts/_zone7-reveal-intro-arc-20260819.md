# ZONE 7 reveal — owner vision drop + New World intro analysis (2026-08-19)

**Owner verbatim (hub chat, mid-T1 session):** "acerca de la parte de
Salir del primer boss (tutorial dungeon) al mundo abierto para despues
poder accesar a la ciudad, y mostrar lo mas bello del juego en esa
parte posible, como hace New World Aeternum en su intro/tutorial:
https://youtu.be/vhXrgH1JtT4 (starting from min 03:18)".

**Owner clarification (same chat, minutes later, verbatim):** "la
manera en que lo expliqué para el juego nuestro es un poco como al
revés a como lo muestra el video … el 'boss' … aparece un poco después
de que ya se mostró el mundo … en sentido cronológico es al revés a lo
que mencioné pero tú acomodalo a como calce mejor a nuestro juego."
→ Adaptation RATIFIED as dev's call. **Adapted chronology (ours):**
tutorial dungeon (constriction) → BOSS 1 (major tension) → ZONE 7
reveal (the REWARD beat) → TOWN 1 (safety) → THE WELL → DUNGEON 1
(the next darkness — New World's red-cavern role). New World needs
reveal-before-antagonist for narrative reasons we don't have
(NO-LORE); ours reads as reward-for-victory — the Zelda
dungeon-clear pattern (Kakariko touchstone already in the spec), and
it stacks victory-relief + openness + beauty + safety into one
sequence. Grammar G1–G8 below transfers beat-for-beat; only the boss
position swaps.

Status: **design guidance BANKED for T4 (pilot content authoring) +
D12 wire-in composition.** No spec change this session (T1 spark
freeze); propose as one amendment line under §Pilot content at the
next spec-touching ticket. No code owed now. NO-LORE order holds: we
take COMPOSITION only — zero narrative/VO/fiction from the reference.

Evidence: video ingested locally (tmp/nw_intro/video.webm, 588s,
frames sampled 1/6s from 03:18 → end, 5 contact sheets read frame by
frame). Gamesmith mailed for full-pipeline treatment (their pace).

## What the video actually does (03:18 → end, verified frame-by-frame)

1. **03:18–04:00 — constriction + hue journey:** swim through BURNING
   RED wreck water → red mist → emerge in TEAL grotto pools. The
   "washed clean" beat: same verb (swim), two hue worlds.
2. **04:00–04:54 — ascent + discovery:** mossy stairs UP → dark
   doorway → giant stone-face reveal (teal mystery) → first combat →
   SUNLIT GOLDEN clearing with chest + UI teaching beats (inventory,
   potions) in the quiet pocket AFTER combat, never during.
3. **04:54–06:00 — the reveal:** skill-tree beat → god-ray jungle
   path → mini-boss on corrupted stairs (tension) → **blown-out WHITE
   light doorway** (you cannot see through it; light pours in) →
   **WIDE VISTA: island panorama + title card at the exact peak-beauty
   frame**.
4. **06:30–09:42 — re-descent + rebirth + safety:** cliff stairs DOWN
   → RED corrupted cavern → boss (red arena, teal floor — complements)
   → death/rebirth (blue) → wake on CALM BEACH (soft green daylight) →
   meet people → quiet camp dialogue. Safety = the arc's last beat.

## The transferable grammar (what we copy, in our engine's terms)

- **G1 — Color SCRIPT, not just dark→light.** Each beat owns ONE hue
  family; beats change by hue CUT: red → teal → green-gold → white →
  blue → red → soft green. Our per-zone authored palettes do exactly
  this. Pilot sequence should be color-scripted end to end: tutorial
  dungeon (dark warm) → threshold (hot/bright) → ZONE 7 (green-gold,
  luminous) → TOWN 1 (warm safe) → THE WELL/DUNGEON 1 (dark again,
  depth-darkened per D3).
- **G2 — The overexposed threshold.** The doorway BEFORE the vista is
  blown-out white — anticipation via light, not geometry. 2D
  equivalent candidates (renderer-only, each gate-able, NONE promised
  this era): hot-lit short corridor before the ZONE 7 transition
  (authored palette — free today); vignette lift / brief bloom-white
  fade on crossing (v19-class renderer idea, RECORDED).
- **G3 — Banner at the vista.** Their title card lands at peak
  beauty. Our zone banner ("ZONE 7") IS that surface — free; the
  authored spawn point makes the banner land ON the reveal frame.
- **G4 — Elevation storytelling == D3 floors.** Stairs UP before the
  reveal (vista from high ground), DOWN into danger. Our
  stairs_up/stairs_down + depth-darkened palettes align 1:1. DUNGEON 1
  descent inherits the "red cavern" contrast role.
- **G5 — Tension→release alternation.** Combat beat immediately
  BEFORE the reveal; safety immediately AFTER the boss. For us:
  BOSS 1 (existing arc) = tension; ZONE 7 threat-free-by-data = the
  exhale. The spec's composition already encodes this — the video
  validates it.
- **G6 — Constriction earns the opening.** ~2.5 min of tight
  corridors/stairs before the wide shot. Tutorial dungeon's tight
  rooms ARE the setup; ZONE 7's authored openness is the payoff.
  Author the exit corridor DELIBERATELY tight/short.
- **G7 — Audio carries half the cut.** Their music swells at the
  vista. Our beat: dungeon drone → threshold → ZONE 7 region ambience
  + grass footsteps (the ratified first SAFE family, D8) — the T3
  cue-spec should name "first entry into ZONE 7" as its flagship
  moment.
- **G8 — UI teaching in quiet pockets** (future note for the v19
  leveling/skills braid): teach AFTER combat in golden safety, never
  mid-fight.

## T4 authoring implications (concrete, when its session opens)

1. Exit-of-boss corridor: short, tight, hot-lit at the far end (G2/G6).
2. ZONE 7 entry spawn placed so frame 1 composes: open field + TOWN 1
   silhouette across it + path leading in (G3; LDtk makes this a
   drag-and-look job — T1 verified the editor renders field values
   and entities in-world while authoring).
3. ZONE 7 palette: brightest surface in the game so far (G1);
   region ambience + grass footsteps from entry tile one (G7).
4. TOWN 1 palette one step WARMER than ZONE 7 (safety reads as
   warmth, per their beach-camp ending).
5. DUNGEON 1: hardest hue cut available (G4) — depth palette darkens,
   ambience swaps.

## Candidates RECORDED (not owed): camera pull-back on first ZONE 7
entry; bloom-white transition flash. Both renderer-only, both wait
for their own gated increment post-verdict. No sim touch anywhere in
this note.
