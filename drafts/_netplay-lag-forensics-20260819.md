# Netplay lag forensics + E-skill classification — 2026-08-19 (ritual session 1 evening)

Tech lane (NOT fun-evidence; the feel-halves of these reports are HELD
in the skeleton until the eight answers land). Owner reports, live coop
(verbatim in the skeleton §side-signals): **(2)** "there is lag",
**(5)** "the lag usually intesifies when only 1 of us is alive",
**(4)** "the E key skill on the ranged character doesn't inflict
damage nor heal".

## Lag — measured priors (host log 8503, banked)

- `TELEMETRY netplay seat=1 ticks=74469 desyncs=0 stalls=9807
  stall_ms_max=1113 reason=quit` — **13.2% of ticks stalled; worst
  stall 1.11 s**; ~28 min wall for 74469 ticks ≈ **44 tps average vs
  60 nominal** (tick-locked slowdown, not skips — by design).
- `AUDIO drift` telemetry corroborates: engine PCM runs ahead of
  tick-expected PCM by ~151 s at tick 73800 (the sink consumes wall
  time; the sim doesn't) — a clean independent clock for "sim ran
  slower than real time". The tick=0 spam block = the hosting-wait
  screen (audio live, lockstep not started); harmless, but ~90 lines
  of log noise per session — cosmetic logging item, post-verdict.
- Zero desyncs across all of it: lockstep held; this is a THROUGHPUT
  problem, never a correctness one.

## Hypotheses for the "worse when 1 alive" correlate (5) — UNVERIFIED, for the investigation session

1. **Delay-queue stall coupling (prime suspect):** lockstep delay
   min=4/max=12 (data/netplay.json); any hitch on either seat stalls
   both. With one player dead, the SPECTATING seat's window may lose
   focus/frame-pump priority (idle-window precedent from soak
   forensics: hidden windows starve the input pump) — Windows
   throttles unfocused windows.
2. **Sim load:** a lone survivor kiting a whole zone = max humans
   alive+pursuing (flow fields per anchor, surround/pressure claims
   rebuilt per tick, density pockets over the full roster). The perf
   smoke (`rake perf`) covers the district scenario single-seat —
   NOT the "28 humans + netplay + audio + one seat dead" profile.
3. **Audio callback pressure** under many simultaneous combat cues
   (mixer runs on the audio thread; pure sink, but CPU is shared).

## Investigation shape (post-verdict, or earlier if the owner names it a blocker)

- Instrument: per-tick ms histogram + stall-cause tag (net-wait vs
  sim-ms vs render-ms) behind an env flag (pure telemetry, wall-safe);
  reproduce with the soak bots (2 seats, one bot idling dead) — bots
  are legal here (tech lane, not fun-evidence).
- The overrun counter already proves sluggish ≠ balance (AGENTS.md
  timebase law); the fix lane depends on which bucket dominates.
- **Frozen until the verdict:** netplay delay numbers, tick rate, any
  sim pacing value (measurement hygiene — the ritual measures them).

## E-skill (lobber special) — classified from code+data, NO defect found

`data/balance/combat.json` lobber.special = **volley**: damage=35,
`impact_distances=[2,3,4]`, `delay_frames=40`, windup 10 — i.e. three
impact tiles along FACING at distances 2/3/4, landing **~0.7 s after
cast**, wall-blocked (`volley_tiles` stops at impassable).

- **It DOES damage by data** — but: point-blank (<2 tiles) it hits
  NOTHING (dead zone by design); the delayed impacts land where the
  target WAS; walls truncate the lane silently.
- **It never heals** — correct: no heal exists in the kit (the owner's
  "nor heal" expectation likely transferred from the vat/provision
  verbs).
- **Classification: legibility gap, not a zero-damage bug.** The cast
  telegraphs nothing on the impact tiles during the 40-frame delay →
  a whiff and a hit LOOK identical at cast time. Renderer-only
  candidate (impact-tile telegraph decal, kill-pop-class): flywheel
  lane, Rule-2-gated, sim-blind — POST-VERDICT (visual change wall +
  the pending ritual's second session argue against moving any visual
  surface tonight). The potency/range-growth half of the owner's note
  is intake idea 4 material (spell progression); the mid/late-game
  positioning quote is banked there verbatim.
- Cross-ref: critique issue #3 (attack visuals) already names this
  surface class; fold this into that verification row when the
  flywheel session runs.
