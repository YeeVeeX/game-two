# Gamesmith → game-two touchstone digest (2026-08-10)

What the gamesmith pipeline (workspace/gamesmith) has extracted so far, distilled to
what serves game-two's design. Gamesmith reverse-engineers design docs from gameplay
footage; its artifacts are evidence-graded (visual / commentary / inference, with
timestamps). This digest is the game-two-facing index — cite it on the reference
wall, Read the source artifact when a decision needs the evidence.

## Corpus state (measured 2026-08-10)

| Game | Pipeline depth | Source recordings |
|---|---|---|
| **Tibia** | FULL: notes + mechanics + feel + **rendered extracts** (core-loops.md, mechanics-inventory.md) | vrynna-60d (60-day challenge, 2026 client), bill-peor (2026 client), fyng-creator (dev interview + archival) |
| RuneScape (OSRS) | notes + transcripts | bill-runescape (first-timer retrospective) |
| Daggerfall | notes + transcripts | sergicio-crpg (video essay) |
| New World | notes + transcripts | deityvengy-combat (raw combat, no narration) |
| Warhaven | notes + transcripts | reborn-gella-tdm (TDM match) |

Only Tibia has reached the extract stage — and Tibia is our prime touchstone, so the
deep artifact and our need line up. Paths:
- `workspace/gamesmith/artifacts/games/tibia/extract/rendered/core-loops.md`
- `workspace/gamesmith/artifacts/games/tibia/extract/rendered/mechanics-inventory.md`
- per-recording: `artifacts/games/<game>/recordings/<rec>/notes/notes-en.md`
- Tibia feel pass: `artifacts/games/tibia/recordings/bill-peor/feel/observations.json`

## The load-bearing extraction: WHY Tibia's bank loop is not a chore

This is the direct answer to the D0 fun-verify verdict ("bank now or push deeper =
a chore"). Tibia's session loop (Stock → Travel → Hunt → Bank) stays tense because
every leg carries a REAL cost the player is trying to beat:

1. **Supplies erode profit — sessions can run NEGATIVE.** The Hunt Analyser shows
   live net balance; observed -1,428→-1,536 mid-hunt and session ends at -7,959 /
   -18,749 / -47,270. The player is *paying* to hunt (potions) and betting the loot
   beats the burn. D0 has no supply burn: hunting is free, so banking defends
   nothing. [core-loops §2; vrynna notes seg 5]
2. **Death is the loop's teeth.** Full-loss at launch, softened over years into a
   layered insurance market (blessings 9,600g/instance, premium, store upsell ON the
   death dialog). Testimony: a death was punishing enough the creator skipped a play
   day. Our D-track staging (D1 corpse containers, D2 wipe fines/insurance) is
   exactly this arc — and the extract confirms the insurance market only matters
   because the underlying loss is real. [core-loops §3; mechanics "Death, Blessings & Risk"]
3. **The carry itself is the stake.** Item-drop-on-death past level 21 (testimony),
   blessing pilgrimage as pre-hunt ritual. D0's carried-vanishes-on-death is the
   right primitive; what's missing is PRESSURE on the carrier (our rushers don't
   threaten the walk home).
4. **Hunt-spot choice is a researched decision** ("too strong I'd suffer, too weak
   no gain") — risk/reward selection is the session's strategic layer. Maps to A2
   pull economy / A3 district progression, not to D0.
5. **The tank verb we're building.** exeta res (knight challenge) is cast
   *repeatedly* in-fight as the knight's party role; exhaustion (~global cooldown,
   observed ~0.6s+) gates tempo but taunt is effectively always available when
   needed. ⚠️ Spec tension: our draft folds taunt into Slam (600f ≈ 10s exhaust) —
   Tibia's knight can re-taunt every beat. If playtest says the taunt window feels
   starved, the touchstone points at decoupling or shortening the clock.
6. **Feedback style is the anti-touchstone.** Tibia's hit feedback is TEXT (floating
   numbers, log lines) that visibly degrades readability in dense pulls; the feel
   pass found flash+number in the same frame as the swing. We deliberately went
   Vlambeer (hitstop, flash, shake) — keep citing Tibia for LOOPS and ECONOMY, never
   for combat feedback.

## Secondary touchstones (notes-only depth, use when relevant)

- **OSRS:** quest-driven onboarding; hover-only nameplates; NPC-vs-NPC ambient
  combat (a *simulated* world, not player-reactive — relevant to our AI-vs-AI
  district fights); the 100k-gift-to-newbie episode = emergent generosity as
  retention.
- **Daggerfall:** use-based skill growth ("Your Medical skill improved" — the
  parked skill-through-use item); environmental state (wetness/cold) as cheap
  atmosphere verbs.
- **New World:** stacked labeled DoT debuffs; consent-based dueling layered over
  open-world objectives. Mostly out-of-scope for us.
- **Warhaven:** ticket-pool TDM structure; per-match role rosters. Out-of-scope.

## How to use this doc

Reference-wall citations in specs should point at the rendered extracts with their
section names (they carry timestamped evidence). When a design argument needs the
raw evidence chain, Read the source file — do NOT re-derive Tibia claims from
memory; the extracts are evidence-graded and the memory is not.
