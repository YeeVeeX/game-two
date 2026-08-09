# Vertical slice spec — one page, one loop

**Fun thesis (inherited from marrow, kept):** *every hit must feel impactful.* Combat is
state-driven with extensive visual feedback. Death hurts; survival feels earned. The slice
is fun when trading hits with one husk has weight, dying feels fair (telegraphs are
readable), and respawning makes you want one more run.

## The loop

Move → close on the husk → attack (3 hits kills it) → get hit (7 hits kill you) →
die → fall overlay → respawn → husk resets. One arena room, no doors.

## Verbs (all frame data lives in `data/balance/combat.json` — code has zero constants)

| Verb | Design |
|---|---|
| Move | 8-way, instant start/stop (no momentum — marrow's call, kept), normalized diagonals, 4px/f |
| Attack | windup 6f → active 4f → recovery 10f; hits once per swing; 48px reach box in facing direction |
| Dodge | 80px burst over 15f, 18f i-frames, 50f cooldown. THE defense verb — no block, no parry |
| Die/respawn | hp 0 → 90f fall overlay → respawn at spawn, full hp, arena resets |

## Enemy: the husk

HP 60 (3 player hits), chase-only AI (no strafing), aggro at 600px — in a one-room arena
duel the husk hunts on sight; a passive enemy kills the loop's pressure.
Attack: **30f visual telegraph** (flashes yellow, swells) → 6f active → 45f cooldown.
Deviation from marrow logged: its telegraph was a 0.3s *audio* cue; audio is placeholder
by owner order, so telegraph is visual and longer (0.5s) to stay readable.

## Feel (the actual product — sequence on every hit, marrow's order kept)

hitstop (3f, 8f on kill) → screen shake (deterministic sin/cos, decay 0.85/f) →
hurt-flash on the victim → knockback → HP bar reacts. Player gets 30f post-hit i-frames
(deviation from marrow: prevents stunlock; marrow had none and its enemies fired slower).

## Visual identity (marrow specified none — this is mine)

Chunky flat-rect minimalism, dark arena (#0F0F19 floor, faint grid), shapes read by
silhouette + motion: player = ember orange, husk = pale bone, telegraph = hot yellow,
attack = white slash box. 960×540 window, fixed camera + shake. No sprites in the slice —
feel first; art direction can replace rects later without touching the sim.

## Deliberately absent (parked, not forgotten)

Stamina, gear-drop-on-death, loot, XP loss, sprint, second enemy, rooms — PARKING_LOT.md.

## Ship gate

`rake` green + `rake capture SCRIPT=harness/scripts/arena_loop.json` reproduces the whole
loop deterministically (byte-identical PNGs across runs) + vision critique passes on the
captured frames + owner says "fun".
