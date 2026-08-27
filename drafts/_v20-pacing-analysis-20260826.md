# v20 pacing analysis — hours-per-level under the live curve (drafts-only, 2026-08-26 s91)

STATUS: **GRILL INPUT — measured arithmetic only, zero design decisions.**
Owner word s91 ("go with the drafts-only pacing analysis"). Freeze intact:
every file below read-only; `progression.json` stays frozen until the
eighteenth's verdict (spec §12.4). Hygiene posture: this doc carries NO
feel claims and NO tuning recommendations — feel readings belong to the
ritual (growth-felt is a sealed question topic); the grill re-prices the
curve AFTER the verdict rows land. Pre-registered lineage: the slate's
cycle-pace datum (`drafts/_v20-candidate-slate-20260826.md` §Cycle-pace)
named this exact work item; this doc executes it early so the grill
opens loaded.

Instrumentation law (KB: `game-research/rpg-xp-curves-and-leveling-formulas.md`,
verified 2026-08-09, quoted via the s86 slate KB pass): "invert E(L),
plug in an XP-income-per-hour assumption, read off hours-per-level — run
it on every tuning change; it is the difference between designing pacing
and discovering it." This doc replaces the assumption with MEASURED
rates from the three human sessions that consumed the curve.

## 1. The shipped machinery (all cited, read-only)

- Formula (`src/game/progression.rb` `delta_e`): **ΔE(L) = k·(L² − 3L + 4)**
  = XP cost of going level L−1 → L. `data/balance/progression.json`:
  k=40, level_cap=10.
- `xp` = progress INTO the current level, never cumulative
  (progression.rb header, P3). At cap, `award` pins xp at
  ΔE(cap+1)−1 = **3679** (projector-invariant law).
- `kills_xp` = session-scoped earned-XP counter, counts even at cap
  (P2/P12) — the earn-rate oracle used below.
- Kill XP is **kind-flat** (`kill_xp`): husk 8 · rusher 15 ·
  rusher_hater 25 · challenger 120. Zone tiers (`tiers.json`) scale
  difficulty, never reward.
- Stat growth per level (integer): dmg +8%/level of base, hp +6%/level.
- Live `requires_level` rungs: zone_7 deep ways 4 / 5 / 6(+seal) ·
  dungeon_1→zone_8 rope 8.

## 2. Measured datapoints — the three human sessions that ate the curve

Chain-verified before use: earned XP across the three sessions =
5125 + 1770 + 4069 = **10964 = cumulative E(10) 10320 + the 644
overflow** in the live save (`level=10 xp=644`) — byte-consistent
end-to-end, no unexplained XP.

| Session | Log (numeric %TEMP% pattern) | Ticks | Sim-min | kills_xp | XP/sim-hour |
|---|---|---|---|---|---|
| coop S1, fresh 1→8 (2026-08-24) | `…315846283.log` | 138956 (netplay line) | 38.6 | 5125 | **7967** |
| owner solo s67, L8 dwell (2026-08-24) | `…58186.log` | 18000–19799 (AUDIO drift oracle: cadence 1800, last stamp tick=18000, teardown before next; 60tps confirmed: engine_pcm/48000 = 299.1s at tick 18000) | ~5.2 | 1770 | **~19300–21200** |
| coop exposure #41, 8→cap (2026-08-26) | `…282671153.log` | 80513 (netplay line) | 22.4 | 4069 | **10916** |

Caveats named once: rates are session-aggregate INCLUDING deaths/wipes
(#41 carried wipes=13) · coop sessions run the seats=2 pacing block
(`coop.json`) so coop and solo rates are not directly comparable · the
solo session is a short high-level pocket-farm sample (81 kills,
~21.6 xp/kill avg — hater-heavy mix), honest upper bound, not a
session-length representative. Bot/soak logs EXCLUDED by law.

**Working band: ~8,000–20,000 XP/sim-hour** (low = fresh coop tour,
high = level-8 solo pocket play).

## 3. The curve, priced in time

ΔE / cumulative (k=40; L11+ = extension arithmetic under the LIVE k,
computed for grill reference only — cap is 10):

| L | ΔE(L) | cum E(L) | | L | ΔE(L) | cum E(L) |
|---|---|---|---|---|---|---|
| 2 | 80 | 80 | | 9 | 2320 | 7360 |
| 3 | 160 | 240 | | 10 | 2960 | **10320** |
| 4 | 320 | **560** | | 11 | 3680 | 14000 |
| 5 | 560 | **1120** | | 12 | 4480 | 18480 |
| 6 | 880 | **2000** | | 13 | 5360 | 23840 |
| 7 | 1280 | 3280 | | 14 | 6320 | 30160 |
| 8 | 1760 | **5040** | | 15 | 7360 | 37520 |

(Bold cum = a live `requires_level` rung sits at that level.)

Hours to reach (fresh start, at the measured band edges):

| Milestone | cum XP | at 20k xp/h | at 8k xp/h |
|---|---|---|---|
| L4 (first deep rung) | 560 | ~2 min | ~4 min |
| L5 (basement_2 rung) | 1120 | ~3 min | ~8 min |
| L6 (dungeon_1 rung) | 2000 | ~6 min | ~15 min |
| L8 (zone_8 frontier rung) | 5040 | ~15 min | ~38 min |
| L10 (cap) | 10320 | **~31 min** | **~1.3 h** |
| L12 (extension math) | 18480 | ~55 min | ~2.3 h |
| L15 (extension math) | 37520 | ~1.9 h | ~4.7 h |

Per-level dwell near and past the cap: L9→10 costs 9–22 min;
L10→11 would cost 11–28 min; L14→15 would cost 22–55 min (band edges).

## 4. Mechanical observations (facts, not calls)

1. **The whole shipped curve = 0.5–1.3 measured sim-hours.** It was
   priced for the six-zone introduction arc and performed exactly that
   way: three ordinary sessions consumed it (owner verbatim already
   banked in the slate: "llegamos al final del juego muy rápido").
2. **A cap-15 extension under the live k adds 27,200 XP = 2.6× the
   entire current curve** (~1.4–3.4 additional sim-hours at the band).
   Whether that dwell is content-covered is a v20 content question, not
   a k question alone — the grill owns the coupling.
3. **Deep zones currently pay LESS per kill against HARDER fights:**
   husk (basements/dungeon spawn class) = 8 XP vs surface rusher = 15,
   while `tiers.json` raises deep difficulty 50–150%. Reward is
   kind-flat by design; the risk↔reward gradient the shelf's
   radial-danger touchstone describes (distance = both risk AND yield)
   is not yet mirrored in XP. Recorded as arithmetic, not as a defect —
   drop economy and banked-value flow are the OTHER deep rewards and
   sit outside this doc's scope.
4. **Kills-per-level scale:** at the measured ~21.6 xp/kill mix, L9→10
   costs ~137 kills; the KB note's cross-game anchor ("~10 kills at L2,
   ~40–60 by L15") is FLAGGED-class and cross-game kill cadence differs
   by an order of magnitude — comparison recorded, not load-bearing.
5. **The three-session chain is a complete, clean natural experiment:**
   fresh→8 (coop tour), 8-dwell (solo farm), 8→cap (coop endgame) — the
   band edges come from real play styles, not synthetic assumptions.

## 5. Open questions FOR THE GRILL (questions, not answers)

- Re-price k vs raise cap vs both — against which target
  hours-per-level per band? (The verdict's R-G rows, if fired, carry
  the feel data this doc deliberately does not.)
- Do new creature kinds (slate candidate 7, BOSS 2 kit) get kill_xp
  rows that restore a deep-pays-more gradient, or does deep yield stay
  drop/banked-value-shaped (observation 3)?
- BOSS 2 XP: challenger=120 is the only boss-class row; is boss XP a
  pacing lever or ceremonial (defeat counters already gate)?
- Does the L8→cap dwell band (9–22 min/level) match the serial-content
  cadence the method ruling implies ("one at a time with intensive
  testing"), or does v20 content want longer dwell at its frontier?
- Instrumentation: promote this doc's math to a standing script at the
  grill (the KB note's "run it on every tuning change") — tooling is
  post-verdict work, this doc is its paper prototype.

## Provenance + hygiene statement

Read-only inputs: `data/balance/progression.json` ·
`src/game/progression.rb` · `data/zones/*` rung values (via AGENTS.md
live-law lines) · three human launcher logs (numeric %TEMP% pattern,
close-line telemetry only) · `saves/world.json` decode facts as banked
in the skeleton (not re-decoded — zero launches this session). Zero
files edited outside this draft; zero KB numbers landed anywhere near
`data/`; bot logs excluded; no peer was asked anything. Feel readings:
NONE here — the ritual owns them (spec §7/§9 untouched).
