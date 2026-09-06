# v22 ART LANE CHARTER — the REVAMP toward the sealed visual bible (2026-09-05, s133)

STATUS: WRITTEN at s133 on the owner's tour baseline + "A now" word (foundation
§RATIFICATION s133 (3)/(3b); L12 baseline LANDED). Lane G of the v22 foundation; spec
pointer `docs/superpowers/specs/2026-09-05-v22-one-body-cycle.md` §6. Presentation-only:
nothing here touches the sim, saves, or netplay; every landed atlas batch pays its Rule 2
gate + a wall re-pin. Runs PARALLEL to lanes A–D; never blocks the TWENTIETH.
Record-first: sections marked UNCHECKED carry no evidence yet and say so.

## 0. The words this lane answers to (verbatim, in force)

- **Baseline (owner, s133, after watching `captures/clips/tour_20260905_head_3e2bfb6.mp4`):**
  "to be honest it looks so much better tan before, a lot. But still doesn't meet modern
  quality expectations, still looks like a dated game from the first generations. How to
  get an style closer to our vision? I know many things would need to be revamped such
  as the size of each asset or the zoom in of the camera to make things look bigger,
  plus many other animations, maps, assets, I just don't understand why we aren't
  following up our lore or whatever, what are we doing wrong that should be done
  differently? C:\Users\gabri\workspace\game-two-lore\drafts\visual-storyboard"
- **Direction crosses the wall (owner, s133):** asked A (art direction crosses, fiction
  stays out) / B (reopen lore in the game) → **"A now"**. Effect: the SEALED visual bible
  is this lane's LAW for forms, palette, light and composition; no fiction name or story
  line enters code/data/docs/screens (kits stay `striker` / `blocker` / `lobber`; ZONE N,
  BOSS 1; standing order 2026-08-16 intact in its text).
- **Grid order (owner, 2026-08-29, recorded s132 triage doc §0):** "I would like that the
  grid in the game is less visible and each grid visually merged with each other when
  we start to add textures and assets into the game, so it looks more fluid but still
  holds the grid function" → the logic grid stays byte-authoritative; only the RENDER
  layer blends; functional reads (walkable / wall / hazard / station) never blur.
- **Style anchor (owner, 2026-08-25, `game-two-lore/drafts/visual-storyboard/bloques/
  bloque1-alcance-estilo-20260827.md` §Hecho 3):** of the pixel references — "this is
  the style I want for our game".
- **Junior (RECEIPT J-v22 2, `195a01f`):** tiles "opção 2 agora (dual-grid no engine,
  gen_tileset.py), opção 1 pra bordas/props depois".
- **Standing:** "keep an eye on better art … use the power of LDtk and Aseprite for a
  more modern and original look"; "cost is not a concern, quality over cost if its inside
  AWS"; Bedrock image spend is the assets seat's (declared, not asked).

## 1. Law of the lane — the sealed visual bible

- **Source of truth:** `C:/Users/gabri/workspace/game-two-lore/drafts/visual-storyboard/
  concept/biblia-visual-v10-20260828.md` + `.png` (2200×18070, md5
  `10e0d81ebbc650a48a8c82ce72a7b370`; "Ley vigente — todo concepto artístico se
  condiciona a este documento", sealed by the owner 2026-08-28 "me parece bien,
  adelante"). Sheets it binds: `hoja-striker`, `hoja-blocker`, `hoja-lobber`,
  `hoja-boss1`, `hoja-bestias`, `hoja-criatura`, `hoja-bosque-abierto`,
  `hoja-entorno-militar`, `hoja-piedras` (all `concept/*-2026082x.md|.png`); the family
  composite `gen/_familia-tres-hermanos-20260828.png` (2780×900).
- **What crosses (art direction):** silhouettes and form law per kit (the slender
  thrower = `lobber`; the massive rooted guardian = `blocker`; the lean fighter =
  `striker`; the quadruped with the cyan edge = BOSS 1), the palette family (greens
  ~135°, bark browns, ONE glowing core per character brighter than the eyes, lavender as
  the world's flower, "0 cyan 0 red" on player kits — cyan is the boss's), the light
  law (rim light + core glow + ground shadow), the ground grammar (dense mossy
  flagstones with variation, dark value range, ruins with glyph panels), the
  colour-blind measurements (deutan boundary checks in `gen/_medicion-*`).
- **What does NOT cross (fiction):** every proper name, the sibling framing as story,
  the comic pages, any diegetic line. The charter refers to bible subjects by ROLE and
  maps them to kit ids; the assets seat's deliverables carry kit ids only.
- **Subordination:** the assets seat's 40-colour bible (`game-two-assets/docs/
  v22-style-bible.md`, staged) is RE-DERIVED from the sealed bible (a palette extracted
  from the hojas, not from Junior's current sprites) — it becomes the working swatch
  file, never a second law. Its 10 ranked fixes stay valid as CRITIQUE (they describe
  today's sprites) and are re-ranked against the sealed bible.
- **Reading law for game-two seats:** the lore repo is read-only from here (read tool /
  `git -C`); nothing from game-two is ever written there; art files that cross come as
  PNG/Aseprite deliverables through the assets seat's pipeline and land under
  `data/art/` via game-two's gates (family block: integration only through this seat).

## 2. Diagnosis the tickets answer (evidence, not adjectives)

| # | Cause | Evidence | Answered by |
|---|---|---|---|
| 1 | The NO-LORE wall also walled off the art direction; the s131 assets commission asked for a NEW bible | s131 §Seats commission text; assets receipt (bible derived from current sprites); the sealed bible never cited in game-two before s133 | §1 (law), AB (bridge) |
| 2 | Every sprite is drawn by a Python generator (`tools/gen_premium_art.py`, `tools/premium_art/*.py`: ellipses/rects/shading passes) | the files; `data/art/manifest.json` kits point at generated atlases | A1 (pipeline), AA (authorship) |
| 3 | Scale: 960×540 logical (tour frame `tmp/s133/tour_75s.png` measured 960×540), 32-px tiles → 30×17 tiles on screen; character 32×48 → 48/540 = 8.9 % of screen height (modern pixel-ARPG class 13–18 %: Sea of Stars, Eastward, Hyper Light Drifter) | frame + manifest `frame_w 32 frame_h 48 anchor [2,14]` | AS (scale) |
| 4 | Flat ground: one repeated dark cross motif on flat green; walls as flat blobs; the flagstone texture re-draws a 16-px mortar grid (vs the grid order) | tour frame; assets critique finding | A2 (tile grammar) |
| 5 | Palette drift: 283 body colours, no master palette; pack + ember families share the 13–25° hue band; the player's hood shares hue+value with wall tints (ZONE 2, dungeons) | assets critique (accuracy 6/10 · presentation 5/10) | AA + A2 |
| 6 | No light model beyond Junior's fire glows/vignette (`064bd80`) | `src/app/light.rb` | A2/A5 (baked shadow + rim/core glow in sprites) |

## 3. Tickets (order: A0 → AB → AS → A1 → AA → A2 → A3 → A4 → A5; A4 repeats per batch)

### A0 — WB-T7 precondition (spec §5)
The 5 out-of-bounds `spawn` rows in `authoring/pilot.ldtk` become GUI-safe BEFORE any
art-lane GUI session touches `pilot.ldtk` (MAP_EDITING §4.5). Not an art ticket; a gate on
the lane. Done = the spec's WB-T7 ticket closed. UNCHECKED.

### AB — Bible bridge (docs-only; this charter + one assets mail)
- **Goal:** the assets seat receives the sealed bible as LAW by mail (path + md5 + the
  "what crosses / what doesn't" list above), re-derives its swatch file from the hojas,
  re-ranks its 10 fixes, and answers with a RECEIPT naming the derived palette's md5.
- **Done:** mail sent from this session (`~/.pi/agent/mail/game-two-assets/inbox/
  from-game-two-v22-bible-is-law.md`, digest-stamped) + receipt harvested into the
  triage doc. Cost: 0 game-two code. UNCHECKED (mail staged at s133 close).

### AS — SCALE (the first game-two ticket; presentation-only; both peers judge)
- **Goal:** decide ONCE: logical resolution × tile px × frame size, from the storyboard's
  proportions. The governing number = the character's share of screen height (today
  8.9 %). Candidates to TEST, not to argue:
  | id | logical | tile px | frame | tiles on screen | char height | note |
  |---|---|---|---|---|---|---|
  | S0 (today) | 960×540 | 32 | 32×48 | 30×16.9 | 8.9 % | baseline |
  | S1 | 640×360 | 32 | 32×48 | 20×11.25 | 13.3 % | cheapest: no redraw, integer 3× on 1080p; sprites stay 32×48 (detail ceiling unchanged) |
  | **S2** | 960×540 | 48 | 48×72 | 20×11.25 | 13.3 % | same framing as S1, 2.25× the pixels per sprite = room for the bible's density; every atlas redrawn (they are anyway); HUD grid unchanged |
  | S3 | 960×540 | 64 | 64×96 | 15×8.4 | 17.8 % | tightest; telegraph legibility risk |
- **Dev recommendation to test first: S2**, with S1 as the control (same framing,
  different detail ceiling) — the peers watch both on the SAME scripted tour.
- **What it touches:** `data/display.json` (logical size / tile px knobs — today
  `window_scale auto`; the tile size is a zone fact `tile_size` in `data/zones/*.json`
  emissions → the importer/normalizer carries a scale, never a hand edit), `src/game/
  camera.rb` (view extents in tiles; camera is excluded from the digest by law), `src/app/
  tileset.rb`, `src/app/renderer.rb` (anchors from the manifest), `src/app/hud.rb` +
  `minimap.rb` (layout at the new tile px), `data/art/manifest.json` (frame_w/h, anchor,
  cols — the pipeline reads them live), harness capture size (`harness/` renderer +
  every script's frame md5 → full re-pin).
- **Sim invariance proof (the ticket's first gate):** the zoom changes what you SEE, not
  what the sim computes — canary banks UNCHANGED (no rebank) and `digest_snapshot`
  byte-identical across S0/S1/S2 on `world_loop` + `floor3_run`. If a stream moves, the
  camera leaked into the sim → STOP, fix, then continue.
- **Legibility measurement (data, not taste):** longest telegraph/ranged reach in tiles
  from `data/balance/*.json` (`threat.json ranged_hold_tiles 3`, lobber
  `special_impact_distances` up to 6, boss reach) vs the visible half-width at each
  candidate (S1/S2: 10 tiles; S3: 7.5) — a threat that can hit you from off-screen is a
  design change and is recorded, not hidden.
- **Judgement:** `harness/make_tour.sh` rendered at S1 and S2 (scratch display config,
  ~20 min each, detached; the GL fix from MEMORY 2026-09-05 if `Gosu.render` fails), both
  peers watch, one line each; the owner's line decides (his words in §0 name the ask).
  A vision critique of paired frames (S0 vs S2) rides the uiux rubric for the SCALE
  read only (accuracy vs presentation scored separately).
- **Done:** the chosen scale lands as data + the manifest contract; `rake gate` on
  `world_loop`, `floor3_run`, `menu_tour` PASS; full-wall re-pin DETACHED (A4 #1);
  `rake pins` before (0) / after pasted; both peers' lines verbatim in the ticket record
  `drafts/_v22-as-scale-record-<date>.md`. Cost: 1 session + 2 tours + 1 sweep (~4.5 h
  detached). Reviewer: headless scrubbed pi (presentation diff) + the two human lines.
- UNCHECKED until claimed.

### A1 — Aseprite → atlas pipeline into the LIVE manifest contract (assets receipt as input)
- **Input (harvested s132, triage doc §2):** `game-two-assets` staged `tools/
  aseprite_atlas.py` + 2 Lua scripts + 18 tests; `export` validates the grid vs the
  manifest and derives `left` = mirror(`right`) for 3-facing sources; `check` = file
  md5 == manifest md5 AND size == cols·fw × rows·fh; **striker proof: export md5 ==
  manifest pin `3e22b626…`, manifest diff NONE, 0 px diff**; encoder fingerprint note
  (`pil 12.3.0 zlib 1.3.1.zlib-ng`) — the PNG encoder is part of a byte-hash contract.
  Its open items (§8 of its doc): where sources live in game-two; `check` in `rake
  gate`; `--write-manifest` by hand only (an md5 change is an art change → L17 re-pin).
- **Decisions (dev of record; peers may amend):** sources live at `data/art/aseprite/
  <kit>.aseprite` beside the atlases (plain git, ~35 KB each today) · `check` runs as
  ONE line inside `rake gate` and as a minitest row (manifest md5 + dims + encoder
  fingerprint pin) · `--write-manifest` by hand only · the tool reads frame_w/h, anchor,
  cols from the manifest (verified: "the tool refuses other sizes") so AS's new contract
  needs no tool change beyond the encoder pin.
- **Precondition:** the assets commit is UNBLOCKED by the owner's "yes" (s133 (0)):
  it applies its pin pairs, commits, pushes (its pre-push gauntlet ~3.5 h) — then game-two
  copies the tool through the family path (mail + md5), never by editing its tree.
- **Done:** `rake gate` runs `check`; a minitest pins the encoder fingerprint; the
  striker round trip reproduced INSIDE game-two at 0 px. Cost: ½ session. Reviewer:
  headless. UNCHECKED.

### AA — Authorship moves off the generator (assets seat; per kit; PvE creatures after)
- **Goal:** each kit atlas (striker, blocker, lobber, then BOSS 1, then the monster
  families) is AUTHORED at the AS frame size to the sealed bible's form law: Bedrock
  Stable Image Ultra concept passes (the assets seat's spend, declared per batch) →
  Aseprite cleanup at native pixels (palette from AB's derived swatches; outline/shadow/
  hurt law from the style bible; core glow brighter than eyes; 0 cyan 0 red on player
  kits) → `export` → atlas + manifest md5 by hand → mail to game-two with the md5 →
  game-two lands it through `rake gate` on the kit's strongest script + A4 re-pin.
  `tools/gen_premium_art.py` stays as a PLACEHOLDER tool (fixtures, missing kits), never
  the source of a shipped atlas again. Anim set = the manifest's (idle 20 frames incl.
  glance, walk 6, windup 2, active 2, hurt 1, dead 1, dodge 2, special windup/active) —
  extra frames only through a manifest change priced with the re-pin.
- **Order:** striker (the owner's most-seen body under ONE BODY) → lobber → blocker →
  BOSS 1 → hostiles by zone in TWENTIETH order (tower, moss, ember).
- **Gate per atlas:** `check` green · `rake gate` on `kits_distinct`'s script
  (`ledger_loop`) + the kit's special script (`dash_strike_rip` / `lobber_volley` /
  `aoe_specials`) · vision critique with the deutan measurement (bible law) · re-pin
  (A4). Cost: ~1 assets session per kit + ½ game-two session per landing. UNCHECKED.

### A2 — Tile grammar (Option 2 now; borders/props via LDtk rules later — Junior's word)
- **Goal:** `tools/gen_tileset.py` / `src/app/tileset.rb` (engine dual-grid) render the
  bible's ground: dense mossy flagstone with 4+ variants per material, dark value range,
  wall depth (2-tile-tall faces with cast shadow + ambient occlusion where wall meets
  floor), the mortar grid GONE (grid order), material transitions blended at the
  dual-grid seam — while the logic grid stays byte-authoritative (walkable/wall/hazard/
  station reads never blur; `possessed_readable` and the hazard rows are the affirmative
  gates). Borders/props (glyph panels, lavender clumps, roots, fallen trunks) come LATER
  as LDtk auto-layer rules (Option 1 for "bordas/props" per Junior) — WB-T7 first.
- **Inputs:** the bible's `hoja-bosque-abierto`, `hoja-entorno-militar`, `hoja-piedras`;
  the assets tile-fork input (`docs/v22-tile-fork-input.md`: split grammar); the
  critique's "1-wide dual-grid walls read as pills" + "mortar grid" findings.
- **Gate:** `rake gate` on `world_loop`, `floor3_run`, `brasa2_run` (three materials) +
  the zone-specific rows in `harness/gate_scope.json` · a NEW row `grid_reads_as_surface`
  ("the floor reads as one continuous surface with variation; tile edges are not
  visible as a lattice; walkable vs wall stays unambiguous") — written with the
  affirmative strong member staged (MEMORY 2026-08-26) · A4 re-pin. Cost: 1–2 sessions
  (assets tileset + game-two landing). UNCHECKED.

### A3 — The uiux A3 surfaces (HUD row + party rows, death card, insurance pip + bank rows, vat hire, form swap, floor banner, goals board)
- **Input:** spoke U `s132-uiux-a3` (RUNNING at s133; 8 fixtures × 3 locales rendered in
  its tree: `ob_hud_party`, `ob_death_card`, `ob_bank_insurance`, `ob_bank_refused`,
  `ob_vat_hire`, `ob_form_swap`, `ob_floor_banner`, `ob_goals_board`; its UI-GATE critic
  was running at 13:38). Receipt lands in `~/.pi/agent/mail/game-two/inbox/
  from-uiux-a3-one-body-spec.md`; harvest law = triage doc §2.
- **Effect when harvested:** its spec + rubric become the grammar for T2c (HUD), T5
  (pip), T6 (card), T7 (form glyph), F1 (floor banner); its rubric rows enter
  `gate_checks.json` by name as each ticket lands. Redrawn in the AS scale + AB palette
  (the mocks were rendered at S0 — a re-render at the chosen scale is owed by mail).
- [ ] UNCHECKED — receipt not harvested at charter time (RUNNING). _(fill: receipt line,
  md5, spot-check vs the mail's DoD: spec + rubric + 7 mocks)_

### A4 — Full-wall re-pin per landed atlas/scale batch
- One sweep per batch (`harness/run_wall.sh v22-art-<batch>`, 42 scripts × ~5 min ≈ 3.5 h,
  DETACHED, never under a bash timeout; code edits frozen during the sweep — MEMORY
  2026-08-20). `rake pins` pasted before and after every batch; state at charter time:
  **0 pins** ("no pins recorded yet", 42 wall scripts). Batches foreseen: #1 AS scale ·
  #2 striker+lobber+blocker atlases · #3 tile grammar · #4 BOSS 1 + hostiles · #5 A5
  surfaces. Byte-identity readings across commits are NOT code-change verdicts for
  mid-scale-in text frames (MEMORY 2026-08-25). UNCHECKED per batch.

### A5 — Death-cycle + one-body + temple surfaces designed once in the new grammar
- The respawn veil + death ledger card (T6), the temple plate + SET HOME cue (T3′), the
  insurance pip and bank rows (T5), the vat SELECT FORM / HIRE rows (T2b/T2c), the form
  swap glyph (T7) — drawn ONCE at the AS scale in the AB palette to the uiux A3 grammar,
  never first at S0 and again later. Depends on AS + AB + A3 + the owning SIM ticket.
- [ ] UNCHECKED — placeholders until A3 lands and AS is decided.

## 4. Costs and fences

- Money: Bedrock image passes are the assets seat's (declared per batch, inside-AWS
  clearance); game-two spends reviewer/critic dollars only (~$3–5 per gate critique).
  Time: AS 1 session + 4.5 h detached · A1 ½ · AA ~1 assets session per kit (6–8 kits)
  + ½ game-two per landing · A2 1–2 · A3 harvest ½ · A5 1–2 · A4 ≈ 3.5 h × 5 sweeps.
- Never: hand-edit `data/zones/**` or `pilot.ldtk`; write into the lore or assets trees
  (read tool / `git -C` / mail only); land an atlas without `check` + gate + re-pin; ship
  a fiction name in any file; run a sweep beside a live seat or soak; edit source while a
  sweep runs.
- A batch that fails its vision gate does not ship (Rule 6); the finding goes back to the
  assets seat by mail with the frames.

## 5. Spark for the lane's own sessions

`docs/sparkups/sparkup-art-lane-20260905.md` — self-contained: reads this charter,
claims ONE ticket (AS first), fences, verify, close.
