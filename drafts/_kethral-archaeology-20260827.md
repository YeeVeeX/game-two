# Kethral archaeology — dossier (s105, 2026-08-27)

**Status:** GRILL INPUT for the v20 grill (verdict-gated). Docs-only; zero code,
zero data. Source (READ-ONLY archive):
`C:\Users\gabri\Documents.stale-20260413\coding_projects_main\Game On(e)\` —
mined `.kiro/steering/*` · `.kiro/specs/marrow/requirements.md` (31 reqs/420 AC) ·
`prototype/REDESIGN_BLUEPRINT_V1.md` + `TIBIA_ALIGNMENT_ADDENDUM.md` (61-source
Tibia dive) + V16/V17 changelogs · `kethral/KETHRAL_V2_GAP_ANALYSIS.md` ·
`WORKSPACE_STATUS.md` · `kethral_v2/` relics. Lore stays archived; mechanics only.

**Hygiene fence:** rows marked [POST-VERDICT] touch frozen ritual topics
(difficulty · third-body · safe/deep geography) or sim numbers — banked here
UNCOMMENTED; no grill promotion and nothing ships before the ritual verdict.

## A. Mechanics/feel worth stealing (numbered for grill citation)

- **A1 — Breathing cycle (world-state rhythm).** Multi-day world cycle
  (contract/stable/expand/surge): spawn-density scalar + loot bonus + zones
  sealing/opening by phase + a FORECAST consultable at the hub. Adds the TIME
  dimension to v19's geography-of-risk (space); data shape fits zone JSON + J-7
  stamp/advance machinery. Blueprint §7.1. [POST-VERDICT — sim + difficulty]
- **A2 — Wards/blessings (death-penalty insurance).** Purchasable, consumed on
  death, stacking, capped (~40% relief) — priced so a full set exceeds the
  wallet, forcing wards-vs-provisions tension in ONE currency. Direct Tibia DNA;
  a natural bank/toll economy sink. Addendum §2. [POST-VERDICT — economy sim]
- **A3 — Bestiary collection meta.** Per-creature kill thresholds unlock stages
  (observed→studied→mastered) revealing facts and granting small per-family
  passives — "every kill means something beyond XP"; horizontal complement to
  pack-level. `requires_defeats` already counts kills; v1 could be stats-panel
  rows only (J-3 family, presentation-first). Addendum §3.
- **A4 — Voluntary hazard escalation.** Player opts into permanent per-save
  difficulty rungs for +loot/XP (Tibia Primal Ordeal shape). Prestige-by-choice;
  composes with mercy floor (opt-in hard, never forced hard). Addendum §6.3.
  [POST-VERDICT — difficulty is THE frozen topic]
- **A5 — Wealth attracts threat.** Carrying unbanked value spawns/pulls hunters
  (blueprint: hunters at 5+/10+ items). Maps onto no-bank-in-deep (B2/B3):
  deep-side accumulation raises pull instead of inventory items. Elegant
  risk/reward, zero UI. Blueprint §2.5. [POST-VERDICT — threat sim]
- **A6 — Momentum meter (flow feedback).** Hidden multiplier that fills on
  skilled play (kills, dodge-through, back-attack), decays idle, RESETS when
  hit; levels drive escalating presentation juice (trails, glow, tone) more than
  damage. Feel-lane; presentation-heavy fits Rule 2. Gap analysis IMP-02.
- **A7 — Death teaches.** Death screen names the killer + venture stats + one
  bestiary-sourced tactical fact; death always advances that creature's entry
  ("lost gear, gained knowledge"). Cheap legibility: wipe line + one fact row.
  Gap analysis IMP-04/POLISH-03.
- **A8 — Reward-rarity feedback ladder.** Rarity tier = escalating, SCHEDULED
  juice (particles→chime→zoom→flash→slowmo). Items are parked, but the ladder
  principle applies to any reward event (level-up, boss defeat, gate unlock).
  Gap analysis IMP-05.
- **A9 — Ambient co-venturers.** Prototype shipped AI adventurers that explore/
  fight/flee/rest independently and DON'T interact with the player — pure
  world-alive signal with personality scalars. Living-world lane C candidate.
  `prototype/entities/ai_adventurer.py`. [POST-VERDICT — third-body topic]
- **A10 — Enemy AI archetypes as state machines.** Concrete graphs: aggressive
  (frenzy under 30% HP), hit-and-run (dash→retreat→reposition), ambush
  (stealth→stalk→vulnerable-on-miss), guardian (front-block→counter; flanking
  beats it). Enemy variety is v20's natural combat growth axis. Gap analysis
  IMP-01/GAP-01 (encounter composition: mix archetypes per room).
- **A11 — Environmental interactables.** "Every room 1–3 interactables;
  knowledge-as-power": breakable veins (AoE), droppable ceiling traps, hazard
  push-targets. SIM-CLASS tile behaviors — one gated piece at a time per the
  standing WB law. Gap analysis IMP-03.
- **A12 — First-30-minutes journey map.** Minute-by-minute onboarding script
  (first fight alone in a corridor → second room teaches spacing → first
  push-or-return DECIDE moment ~10:00). The six-zone intro arc deserves this
  artifact; directs zone tuning without touching sim. Gap analysis POLISH-01.
- **A13 — Venture prestige stats.** Venture count + survival rate as visible
  stats ("142 ventures, 89% survival"). Save already tracks sessions; J-3 rows.
  Addendum §9.2.
- **A14 — BoF IV visual identity (depth through lighting).** Directional tile
  shading, elliptical entity ground shadows, sparkle VFX at light sources, warm
  multiplicative lighting — cheap depth wins for a flat-placeholder renderer,
  each Rule-2-gateable. ALSO direct J-5 fork input: the BoF4 finding was "depth
  through lighting/layering, not projection angle." Steering REFERENCE_GAMES.
- **A15 — Audio-first combat (LAW CONFLICT — flagged, not proposed).**
  Audio-parry (act on a sound-only cue) makes hearing sim-required — VIOLATES
  the M5a audio-pure-sink law. Lawful weak form only: audio telegraphs MIRRORING
  visual ones, zone audio identity, low-HP pulse — all sink-side. Reopening the
  strong form is owner-only. Blueprint §4.4, requirements §9.
- **A16 — Interaction priority tiers.** 5-tier exact-tile-first priority fixed
  overlapping-interactable bugs; cheap hardening for the H/F verb as
  interactables densify. V17 changelog phase 2.

## B. What the focused builds did better (process steals)

- **B1 — Ship-features-first won.** The 57-file prototype shipped a music
  evolution engine (5-phase, essence-preserved, 25+ min before repetition),
  breathing cycle, song system, AI adventurers — playable increments over
  architecture. The 211-file kethral built 9 managers + "54 files/~20K lines
  dormant infrastructure" (Phase 20) and never reached its vertical slice.
- **B2 — The self-critique doc is the best artifact.** KETHRAL_V2_GAP_ANALYSIS
  reads like a council pass: named gaps, each with a concrete fix. Its two named
  indie failure modes — repetitive combat, punishing-but-uneducational death —
  are standing tests for every v20 combat/death decision.
- **B3 — The owner's process DNA predates game-two.** Session-resilient
  steering docs, scope-protection file, parking lot, spec-before-code, 1,364
  green tests in the prototype era. game-two's laws are the hardened
  descendants — the archaeology CONFIRMS the operating model.

## C. Tunings as FLAGGED refs (never into data/ without re-verification)

- Venture 15–30 min; full session 45–90 min (prepare→1-2 ventures→invest).
- Dodge: 10 i-frames (~0.167s), 1.5s cooldown; exhaustion stun 2.0s at
  stamina-zero.
- Telegraphs 0.4–0.8s; parry window = last 0.2–0.35s scaled by enemy speed.
- Stagger: 3 hits → 0.5s stagger (+25% damage taken), counter resets after 2s.
- Cycle phases: 0.5×/1.0×/1.5×/2.5× density; +0%/+0%/+15%/+30% loot.
- Hazard rungs: ~+15% HP/+10% dmg per rung, +4% loot per rung.
- Wards: 5 stacking × 8% relief = 40% cap; full set ~150% of base wallet.
- Bestiary: easy 1/25/100 · hard 1/50/250 · boss 1/3/5 kills per stage.
- Corpse persist 10 real min (spec) / 3 in-game days (blueprint); loot despawn
  2 min; low-HP warning <25% pulsing 1.5–2s.
- Momentum: 5 levels, 0.3/s decay, reset-on-hit · trust tiers 0/5/15/30/50.

## D. What NOT to repeat (with live counterexamples in the archive)

- **D1 — Orchestrator bloat despite a bus.** kethral/game.py hit 2,663 lines
  WITH EventBus + 9 managers available — WORKSPACE_STATUS brags about the size.
  Line-cap law origin confirmed; keep the caps hard.
- **D2 — Rebuilds that start at the renderer die there.** kethral_v2 (attempt
  3) is 378 lines of game + diag files fighting DirtySprite pixel bugs — dead
  before gameplay. Antibody = "every commit changes what the player sees,
  hears, or feels."
- **D3 — No single source of truth for state.** 22 phases + V13/V16/V17 names +
  3 codebases in one repo; status docs disagree (1,364 vs 1,531 tests). The
  one-cycle-in-AGENTS.md + checkpoint discipline is the fix; keep it.
- **D4 — Spec churn mid-flight.** Requirements grew 29→31 and an addendum
  promoted deferred features while the build ran; the 12-week slice never
  shipped. Freeze specs at CLOSED; new wants go to the next grill.
- **D5 — Platform-hop as procrastination.** A full Godot migration prompt was
  authored while the pygame build "approached" its slice; the s104 Ruby ruling
  already closed this door — this fossil is its precedent.
- **D6 — Lore integration as a dev phase.** V17 spent a phase wiring 20 lore
  elements while core feel bugs queued. The no-lore order stands.

## E. Settled forks — archaeology must NOT reopen (cite, don't relitigate)

- Use-based skills (Marrow pillar 2) → v19 A1 ratified XP-levels, not use-based.
- Death eats XP (10% loss) → v19 A3 ratified death NEVER eats XP.
- Gear-drop-on-death / weight inventory → no item system; mark/toll is the
  ratified death cost. Banks only behind the PARKING_LOT items trigger.
- Menus pause the world (Marrow req 20.8) → J-6 ratified the non-pausing menu.
- Godot/engine migration → s104 pure-Ruby ruling.

**Recommended grill posture (dev of record):** strongest v20 pulls are A1+A5
(risk gains a time axis and a wealth axis — pure geography-of-risk growth),
A3+A7+A13 (kills/deaths/ventures all feed visible meaning — cheap, mostly
presentation), and A10 (enemy variety, the thinnest current axis). A14 rides
the J-5 call. Everything sim-touching waits for the verdict.
