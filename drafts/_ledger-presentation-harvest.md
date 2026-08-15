# Ledger presentation iteration — context harvest (2026-08-11, pre-compact)

Approved plan (full): `C:\Users\gabri\.claude\plans\happy-exploring-hinton.md`.
This file banks the Plan-agent verbatim drafts + code sketches that existed only
in conversation context. ADAPT at implementation time (read-before-edit rules).

## Verbatim check-text drafts (gate_checks.json — adapt, never weaken)

ledger_beat_reads (RETARGET):
"After combat ends, a large glyph+number tally appears center-screen above the
player avatar on a dark contrast panel (filled magenta square + a +N number in
large bold type; optionally loss and net lines under it) and later fades out.
It must be one of the most visually prominent on-screen elements during its
display - comparable in scale to the zone banner or wipe text. Gains (magenta)
must read distinct from losses (a hollow outline glyph with -N, or a dark
red-edged square with -N). If no tally appears in these frames, pass with
why='not exercised by this script'."

bank_tally_reads (RETARGET):
"When the pack banks at the station, a tally appears center-screen above the
player avatar on a dark contrast panel, reading as a trip reconciliation: a +N
take in large bold type, optionally a hollow-outline -N (value still out on
corpses) and a net line. It must be visually prominent - large type on a panel,
comparable to the zone banner. It must be distinguishable from mid-fight
tallies by context (station present, no combat). If no banking tally appears,
pass with why='not exercised by this script'."

ledger_prominence (NEW):
"When a fight tally or bank tally is on screen, it reads as one of the TWO OR
THREE most visually prominent elements in the frame - its type size and dark
panel make it impossible to miss, comparable in visual weight to the 64pt wipe
text or the zone banner. A player focused on the center of the screen CANNOT
fail to notice it. The tally must NOT read as a small footnote, marginal
annotation, or debug overlay. If no tally appears in these frames, pass with
why='not exercised by this script'."

(wipe_recap_reads + ledger_negative_reads are position-agnostic — no retarget.)

## Renderer code sketches (Plan agent; adapt to file idiom)

- Pop scale: `age = beat[:beat_frames] - beat[:beat_left]`;
  `scale = age < pop_frames ? 1.35 - 0.35 * (age.fdiv(pop_frames) ** 0.5) : 1.0`
- Panel: measure lines first (widths via font.text_width, heights 26/26/42,
  +6 line gaps, pad 24x14), scale panel dims with pop, center on cx;
  `Gosu.draw_rect(panel_x, panel_y, panel_w, panel_h,
  Gosu::Color.new((panel_alpha * a / 255.0).round, 10, 6, 12), 29)`
- Flash: `if age < flash_frames` additive rect over panel, alpha
  `(200 * (1.0 - age.fdiv(flash_frames))).round`, warm white (255,240,220), z=31,
  mode :additive — `Gosu.draw_rect(x,y,w,h,c,z,mode)` supports it.
- Lines drawn scaled around block center: y_offset from center * scale;
  font.draw_text(text, x, y, 30, scale, scale, col). Fonts CREATED at target
  size (42/26 bold) — blur only during >1.0 overshoot (intentional, ~10f).
- draw_hollow_pip_v2(x, y, size, col): thickness `[3, (size*0.15).round].max`.
- Net text: `"= #{net.negative? ? '' : '+'}#{net}"` — LEDGER_NEG when negative,
  DROP_CORE otherwise. Recovery pip-prefix on take line preserved.
- Remove dead LEDGER_BEAT_Y. Keep hud_font/ledger_font (other consumers:
  draw_station_ledger, draw_hud).
- Renderer plumbing: `def initialize(display: {})`; call sites window.rb:41
  (`Renderer.new(display:)` — local `display` holds data["display"]) and
  harness/scenes/world_scene.rb:18 (`App::Renderer.new(display: data["display"])`).
  Accessors: `def pop_frames = @display.fetch(:ledger_pop_frames, 10)` etc.
  VERIFY DataStore key type (symbol vs string) at edit time.

## Test sketch (fight_ledger_test data-assert idiom)

pop_frames > 0 and < ledger_beat_frames; flash_frames > 0 and <= pop_frames;
ledger_block_y > 80 (clears HUD bars ~y<=56); ledger_wipe_y > 294 (below
"THE HUNT ENDS" y=230 + 64pt). Follow the existing quiet<settle assert idiom.

## Facts pinned during exploration (do not re-derive)

- gate_checks.json measured 32 checks (checkpoint said 30 — reconcile in task 5).
- 9 script files exist; the SHIP WALL is 7 (world_loop, district_hunt,
  loot_loop, specials_chain, taunt_anchor, corpse_run, ledger_loop);
  critic_reel.json + moving_square.json are non-wall extras.
- view_width(world) = world.camera.view_w (renderer:502) — view dims come via
  camera; new ledger keys go via Renderer kwarg, NOT world/camera.
- Captures are determinism-neutral (runner renders without ticking); critic
  MAX_IMAGES=20, ledger_loop goes 15→18 captures (594, 2020, 11146 added).
- Vision critic: all frames in ONE request, subjective game-feel persona,
  model us.anthropic.claude-fable-5 on bedrock-runtime.
- Renderer has NO unit tests — vision gate only.
- Wipe recap persists past the veil into run-back start (beat clock frozen
  during veil) — at y=310 mid-screen, INTENDED (mission number).
- Stagger veil draws after beat in call order but z=0 vs text z=30 — beat
  stays visible during stagger (accepted).
