# Gudii backup deep-probe (Explore agent, 2026-08-11) + NotebookLM overview

Source folder: `C:/Users/gabri/knowledge/sources/Tibia Videos by Gudii-backup-2026-08-11`
NotebookLM notebook `540b80c7-e769-4ef5-81cb-302df4b9690e` ("Tibia Videos by
Gudii") = the SAME 98 sources; no saved notes; overview at the bottom. Read
via raw CDP on the owner's real Chrome (localhost:9222) — see memory
`browser-automation-google-auth-trap`.

## Inventory

98 markdown files (numbered 1-98) + 1 JSON index; 2.1 MB; all exported
2026-08-11 from NotebookLM; each file = full transcript of one Gudii YouTube
video (auto-captions or scripted narration; no per-line timestamps). Categories:
"[How to team hunt]" x12, solo Paladin/Knight/Monk ~20, "[Ultimate Bestiary
Guide]" 12+, quest guides ~15, "[Tibia Explained]" 6, "[Tibia Random Moments]"
5 (raw stream clips), "High levels play Tibia Iron Man" 7 episodes, misc
(finance tracking, tips, boss guides).

## Findings by theme (agent citations by file number)

### A. Pull/lure mechanics and their tension
- Core rhythm: the "pull" — EK runs ahead, aggros ~8 creatures (the game's
  target cap), brings them to a chosen spot, team nukes. EK counts creatures
  as they walk, stops at eight (f25). Over-pulling cascades danger onto mages
  (f12).
- Multi-vocation simultaneous lures converging on the EK's box (f4, Azzilon);
  the MS lure is hardest ("gets destroyed on the lure and on the setup").
- AGGRO IS FRAGILE (f21 — the key doc): challenge (exeta res) is the EK's only
  hold tool and is unreliable; creatures retarget on proximity, HP, taint
  debuffs, hardcoded priorities (some target druids); a teammate passing "for
  a fraction of a second" steals aggro. Result: high-level meta = EK goes
  FIRST-IN to grab aggro and LEAVES FIRST — a burst aggro-grabber, not a
  sustained tank.
- Fear mechanic (f15, f79): forced 3s run — into holes/monsters; players
  pre-place fire bombs as "speed bumps". One fear-chain misplacing the healer
  collapses the team.
- Lure radius (f4): creatures POOF if lured too far from spawn — spatial
  leash; you cannot kite forever.

### B. Death cost and behavior around it
- Explicit death-cost math (blessings, XP/skill loss) is ASSUMED knowledge —
  never broken down in these transcripts (gap!).
- Death avoidance dominates decisions: "if you were to get trapped, you could
  die pretty fast. So always be on the move" (f6); mages give up DPS to stay
  out of box range (f21); magic shield potions = panic button (f15).
- Near-deaths are the emotional peaks of the stream clips (f79: "I'm
  eight-boxed, I'm dead", team fragmentation, then elation of surviving).
- Iron Man (f28-34): potential death at level 30 is a disaster; whole hunts
  judged on "sustainability".

### C. Supply-burn economy
- Burn: potions (knights burn most), runes, arrows (diamond arrows = 450k/hr
  waste, f55), protective ring/amulet charges, imbuements amortized per hunt,
  XP boosts (meta-currency).
- What ENDS a hunt: supplies running out (f28 Iron Man refill trip; f42 monk
  "run out of supplies right at the 15 min mark"), stamina (~4h real-time XP
  gate), the 2-hour team-hunt convention (f38).
- f38 (30-day finance tracking, THE numbers doc): team loot 16kk/day vs
  supplies 8kk/day; knight's waste ~3.2kk per 2h hunt; base-loot profit only
  10kk over 21 team days — REAL profit came from rare drops (474kk split 4
  ways). Solo = more profit/hr (2.6kk) but "harder to maintain the
  discipline... team hunting is simply more enjoyable."
- Supply skill: mana management, avoiding overhealing, proactive (not
  emergency) spirit-potion use extends hunts (f77).

### D. Session/hunt shape
- Every hunt is a LAP — a fixed circuit of pulls timed so creatures respawn
  by the time you return. Missing creatures on return = overkilling (f83).
- Respawn: designated spawn squares; queued 30s-per-creature on shared
  points; some suppress while a player is on-screen (f83).
- Overkill = the design pressure: too strong for the spawn → add WORSE pulls,
  add floors, or move on; "trade peak experience for a lower more stable
  average" (f83).
- Tidal timer spawns (f15 Ebb and Flow): 2-minute water cycle locks/unlocks
  paths; team runs an external countdown; "be ready to abandon the pull to
  get back to the platform" — time pressure inside each pull.

### E. Why it's fun — monster-side adaptation seeds (inspiration, not copying)
1. Pull-size gambling: walk deeper to fill the cap vs leak creatures onto the
   squishy — maps to "how many threats do you pull before retreating".
2. Spatial leash/poof: prey escapes if chased too far from territory.
3. Aggro as contested resource: not "can I survive" but "can I keep their
   attention" — monster-side: keep the adventurer's attention while allies set up.
4. Supply depletion as session clock: hunts end by economics, not HP — maps
   directly to banked-loot/priced-sustain.
5. Respawn rhythm: lap cadence; overkill punishes over-efficiency — waves the
   player must intercept.
6. Environmental punctuation: fear/forced movement, timers, agony fields,
   chain damage — the clip-worthy moments.
7. Team separation emergencies: one displacement fragments the team; the fun
   is the regroup.

## Top-5 files for full designer read (A2 brainstorm inputs)
1. `21-Exeta res NEEDS a BUFF [Tibia Explained].md` — aggro/retarget rules,
   challenge unreliability, first-in/first-out EK meta. THE A2 doc.
2. `83-Tips for making more Experience [Tibia Tips].md` — overkill, respawn
   points, lap construction.
3. `38-I tracked my Tibia Finances for 30 days.md` — hard supply-burn numbers.
4. `15-Ebb and Flow [How to team hunt].md` — environment-as-pressure.
5. `79-The REAL Ebb n Flow Experience [Tibia Random Moments Ep 5].md` — raw
   feel of cascading failure + recovery.
(Honorable: f12 Darklight Core, f4 Azzilon, f77 Paladin fundamentals.)

## What the folder does NOT contain (gaps that stay gaps)
- Explicit death-cost math (blessings/XP loss); corpse/loot recovery runs
  (modern Tibia auto-blesses at high level); bank-trip/town logistics (hunts
  treated as atomic 2h blocks); retreat decision-making guides (only reactive
  clips); monster-AI internals (observed behavior only); PvP threat; new-player
  first-scary-hunt perspective; design theory (Gudii is a practitioner).

## NotebookLM generated overview (verbatim)

"The provided transcripts from the YouTube channel Tibia Videos by Gudii offer
a comprehensive collection of quest guides and hunting strategies for players
of the MMORPG Tibia. These sources detail a wide variety of content, ranging
from early-game leveling paths for paladins and knights to complex end-game
challenges like the Rotten Blood and Soul War areas. The guides break down
specific quest mechanics, such as the intricate 'A Pirate's Tail' and 'Bloody
Tusks,' while providing vocation-specific tips for optimal equipment and team
formations. Additionally, the text includes Bestiary instructions to help
players efficiently complete creature charms across different difficulty
tiers. Each segment focuses on maximizing experience gain and profit through
analyzed laps and boss strategies. Ultimately, these sources serve as a
technical roadmap for players navigating both legacy content and modern
updates."
