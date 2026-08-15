# Gamesmith corpus — consequence-economics synthesis (workflow wf_de8ce8ad-579, 2026-08-11)

12 agents: 7 extractions -> synthesizer -> 3 adversarial critics (grounding=repair, completeness=pass, fit=repair) -> repaired synthesis (below).
Total: 1,443,710 subagent tokens, 220 tool calls. Extraction JSONs live in the run journal.

## FINAL (repaired) synthesis

```json
{
 "consensus_patterns": [
  {
   "pattern": "Death must cost something the player already invested time/resources acquiring -- consequence scales with accumulated carry",
   "games": [
    "tibia",
    "runescape",
    "new_world",
    "daggerfall"
   ],
   "evidence": "Tibia: XP + skill points + carried items lost from level 21+; blessings 9,600g each pre-purchased as insurance. RuneScape (testimony): historically lost almost everything; Wilderness dread drives retreat at 364k carried despite zero encounters. New World OR: all four carried match resources drop on death, lootable by enemies. Daggerfall: permadeath-mod player declined a vampire fight -- base game's save-reload made death meaningless, requiring a mod to create consequence. Warhaven is the negative proof: zero personal cost per death = 10-second rhythm break with no dread, flat 14-minute attendance."
  },
  {
   "pattern": "Sustain costs must make every second in the field an ongoing expenditure -- sessions should be able to run NEGATIVE",
   "games": [
    "tibia",
    "daggerfall",
    "new_world"
   ],
   "evidence": "Tibia: Hunt Analyser shows -7,959 / -18,749 / -47,270 gold sessions; potions decrement one-for-one (585 to 355 in one fight). Daggerfall: testimony 'adventuring is expensive -- tents, weapon repair, food, torches, arrows, bandages'; torches degrade, camping gear breaks permanently, food spoils. New World OR: potion packs cost 25 Azoth each from the same pool that feeds the 500-Azoth Brute stone -- every heal is Azoth not going toward the match-winning summon."
  },
  {
   "pattern": "Banking/securing must be a non-trivial deliberate act with opportunity cost -- NOT automatic",
   "games": [
    "tibia",
    "runescape",
    "new_world",
    "daggerfall"
   ],
   "evidence": "Tibia: physical travel back to town depot costs time (XP/h drops 33,746 to 32,059 during downtime) + boat fare. RuneScape: bank buildings require physical travel; Falador testimony -- players ran to the bank and died en route. New World OR: outpost Storage removes death-drop risk but INTRODUCES capture risk (enemy takes the outpost, gets your stored resources). Daggerfall: Bank of Daggerfall locked outside 8:00-15:00 hours; banking is time-gated."
  },
  {
   "pattern": "The value chain must terminate in meaningful sinks that feed back into play -- accumulated wealth must BUY something the player viscerally wants or needs",
   "games": [
    "tibia",
    "new_world",
    "daggerfall"
   ],
   "evidence": "Tibia: potions (per-minute survival), blessings (death insurance, 9,600g x6), imbuements (60,000g + materials for 20h enchant). New World OR: 500 Azoth buys a Brute Summoning Stone that visibly wins team fights (2-3k damage swings); resources build gates/turrets. Daggerfall: sustain consumables, spell purchases (1,188g), horse (3,000g aspirational), houses (580K-784K). Warhaven negative proof: zero sinks = score with no function, flat attendance."
  },
  {
   "pattern": "Pressure is primarily logistical/attrition-based rather than aggro/pull/leash-based -- the field bleeds you dry, it does not chase you out",
   "games": [
    "tibia",
    "daggerfall",
    "new_world"
   ],
   "evidence": "Tibia: NO aggro radius, leash, or respawn pressure observed in any recording; threat = pack density + spawn selection + poison persistence + supply exhaustion. Daggerfall: NO pull/leash system; pressure = material gating + quest deadlines + supply burn + light exhaustion. New World OR: PvE mobs are static encounters chosen by the player; pressure = Baroness timer + carry-risk escalation + scoring clock. Warhaven: pure symmetrical PvP, no PvE AI systems at all."
  },
  {
   "pattern": "Session shape is expedition-arc (stock, travel, hunt to exhaustion/death, extract and review) -- NOT flat attendance",
   "games": [
    "tibia",
    "daggerfall",
    "new_world"
   ],
   "evidence": "Tibia: stock potions -> boat to hunting ground -> hunt (potion stacks decrementing) -> return to depot and review Hunt Analyser P&L. Daggerfall: provision -> take contract -> travel (costs gold + days) -> dungeon crawl as endurance run -> extract at supply exhaustion or deadline. New World OR: opening split -> contest outposts -> farm PvE -> spend at armory/portal -> rotate on Baroness timer. RuneScape: player-paced hours-long grinds ending at supply/time/capacity limit."
  }
 ],
 "divergence_table": [
  {
   "dimension": "Death cost",
   "corpus": "Carried value drops/lost on death; insurance must be pre-purchased; death aborts the hunt entirely and costs travel time to resume",
   "game_two": "Carried value drops as a timed corpse container, but recovery is 2/2 uncontested -- no enemy disputes the corpse, no loss has ever occurred to timer or threat in any verify session",
   "severity": "critical"
  },
  {
   "dimension": "Sustain costs / session P&L",
   "corpus": "Every second in the field costs resources (potions, torches, food); sessions routinely run negative; the field bleeds you dry",
   "game_two": "Zero sustain costs exist. Bodies only refresh via wipes. No consumables, no supply burn, no per-minute expenditure. Sessions cannot run negative because there is no spend column",
   "severity": "critical"
  },
  {
   "dimension": "Sinks for banked value",
   "corpus": "Banked wealth feeds back into play: potions for next hunt, blessings for death insurance, imbuements for combat power, travel fees, aspirational property",
   "game_two": "Banked value has NO spend mechanic -- 'a number with no world-consequence is score.' Five fun-verifies confirm: Q4 'banked, wouldn't care', Q8 'wouldn't care' (four consecutive readings)",
   "severity": "critical"
  },
  {
   "dimension": "Banking as contested decision",
   "corpus": "Banking costs opportunity (XP/h drops during travel), money (boat fares), and carries travel risk; alternatively, banking introduces capture risk (New World). The bank-or-push decision is genuinely contested",
   "game_two": "Banking is a short walk to the hub with no cost, no danger en route (gate-camping aside, which is an AI flaw not a designed system), and no opportunity cost. Owner Q3 = 'still a chore' across five verifies",
   "severity": "critical"
  },
  {
   "dimension": "Pressure model (threat texture)",
   "corpus": "Attrition/logistical: pack density spike deaths (HP 1178 to 534 in 2s), supply exhaustion forcing extraction, timed objectives creating rotation urgency",
   "game_two": "AI targets nearest hostile with no aggro system, no leash, no scaling density, no extraction pressure. Gate-camping is emergent AI behavior (rushers never leash, idle at gates) but undesigned. 2/2 corpse recoveries uncontested; Q1 'standing in line'",
   "severity": "critical"
  },
  {
   "dimension": "Value legibility at moment of acquisition",
   "corpus": "RuneScape: every ground drop carries GE + HA price tags in real-time. Tibia: Hunt Analyser tracks accumulating value live. New World: resource counters visible in HUD with clear conversion rates to sinks",
   "game_two": "Post-fight ledger now VISIBLE and read as a payoff (Q1 positive, fifth verify). Legibility is SOLVED -- but a legible number without world-consequence remains score",
   "severity": "cosmetic"
  },
  {
   "dimension": "Session shape",
   "corpus": "Expedition arc: stock -> travel -> hunt to exhaustion/death -> bank and review. Sessions end from supply depletion, death, time budget, or capacity",
   "game_two": "Flat attendance: fight at gate -> wipe -> respawn at hub -> walk back -> fight at gate. 8 wipes in 5.5 sim-minutes in pilot flight. Sessions end from player choice only (Esc to quit). No supply depletion, no capacity, no extraction moment",
   "severity": "moderate"
  },
  {
   "dimension": "Corpse/death-cache contestation",
   "corpus": "Tibia: no corpse-recovery mechanic is evidenced -- death teleports to a distant spawn point and items are LOST (testimony only, no footage of items on ground); the cost is restarting the hunt from scratch (travel + re-provision), not recovering a death-site cache. New World: dropped resources lootable by ANY player including enemies (PvP context). Daggerfall: no corpse (reload). RuneScape: implied time-limited retrieval window (Swordfish x15 on ground near death site)",
   "game_two": "Corpse containers persist with a timed term (5400f) and grace (2700f) but nothing actively threatens them. Q5 'never noticed' the clock. 2/2 recoveries trivial. The spec's FR-043 NEEDS CLARIFICATION marker is exactly this gap",
   "severity": "moderate"
  }
 ],
 "implications_a2": "The corpus LICENSES for A2:\n\n1. ATTRITION AS THE THREAT MODEL, NOT AGGRO TABLES. Zero touchstone games show a threat/aggro/pull system. Tibia has no aggro radius, no leash, no respawn pressure -- creatures occupy fixed spawns and the player chooses which to challenge. Daggerfall enemies have no threat tables; the Hell Hound was observed FLEEING the player. RuneScape combat is player-initiated via context menu with no pursuit. New World's PvE is static encounters. The corpus universally says: pressure comes from DENSITY you walked into + RESOURCES running out, not from enemies that scale their attention.\n\n2. DENSITY-AS-CONSEQUENCE. Tibia's HP drops 1178 to 534 in two seconds in a crowded spawn -- the death is fast once the tipping point passes. The player's choice of hunting spot IS the risk decision. New World's carry-risk increases linearly with time since last bank/spend. Both are self-selected difficulty curves: you chose how deep to wade, and depth costs you faster.\n\n3. LEASH AS EXTRACTION AFFORDANCE. No corpus game traps the player. Tibia has no leash but also no pursuit (spawns are fixed). Daggerfall explicitly: 'retreat is always available -- the game never traps you.' This licenses A2's leash-with-no-heal shape (rushers that lose contact walk home but KEEP current HP) because the corpus says retreat must be possible -- but it does NOT license the inverse (enemies that chase indefinitely through zones).\n\n4. ACTIVE PURSUIT BEYOND INITIAL ENGAGEMENT RANGE (weakly licensed, one testimony). One corpus game has TESTIMONY of pursuit: Daggerfall's narrator describes fleeing a wraith that pursues through mountains as a material-gating flee trigger [say sergicio-crpg 00:16:03]. However this is: (a) testimony only, not footage-observed behavior; (b) specific to material-immune enemies that cannot be damaged, functioning as a retreat signal rather than a general aggro system; (c) contradicted by the same game showing the Hell Hound FLEEING the player. No corpus game demonstrates a general chase/pursuit system, and no pursuit with threat tables, range limits, or leash behavior is evidenced anywhere. The 'aggro soft-cap 8-12' from the parking lot has zero touchstone backing beyond this single flee-trigger testimony. It must be defended purely from game-two's gate-camping measurement and the 2/2 uncontested recovery finding.\n\n5. CONTESTING THE CORPSE (weakly licensed). New World is the sole evidence: death-drops are lootable by enemies. Tibia has no corpse-recovery mechanic at all -- death teleports to a distant spawn and items are simply lost. The synthesis spec's FR-043 NEEDS CLARIFICATION marker on scavenging is exactly this open space. The corpus says one game out of five made the death-drop contestable; the other four did not. This means A2 CAN contest the corpse but must not REQUIRE contestation as the primary pressure source -- it is a secondary signal confirmed by exactly one touchstone.\n\nThe corpus does NOT license for A2:\n\n1. AGGRO SYSTEMS. Zero evidence across 5 games and 8 videos for threat tables, aggro radii, taunt-as-threat-manipulation, per-hit threat accumulation, or any pull/leash mechanic designed as such. The owner's threat-accumulator shape and the original pull-density shape are BOTH corpus-unsupported. A2 must be defended from game-two's own diagnosed problems (the 2/2 uncontested recoveries, the gate-camping measurement, the taunt-fuse finding), not from citations.\n\n2. DYNAMIC SCALING. No corpus game escalates threat based on player behavior, time spent, or accumulated carry. All use fixed-density zones the player self-selects into. A2 cannot cite corpus support for 'the more you carry the more enemies appear' or similar reactive systems.\n\n3. RESPAWN PRESSURE. No corpus game uses respawn timing as a pressure lever (Tibia spawn timers are completely unobserved; Daggerfall creatures are static; New World PvE is static encounters). Game-two already has 300f rusher respawns creating the gate-meat-grinder -- this is an emergent consequence, not a designed pressure system, and the corpus cannot validate it as intentional threat.\n\nRECONCILIATION NOTE (owner's threat-accumulator vs pull-density): Both shapes are design inventions for this game. The corpus's strongest relevant pattern is 'hunting-spot selection is the core risk decision' (Tibia) -- meaning the player commits to a density level BEFORE engagement, not that enemies dynamically scale. This favors the PULL-DENSITY shape (player walks into pre-set threat levels) over the THREAT-ACCUMULATOR shape (enemies react to player behavior with scaling attention), but neither has citation support. This recommendation is brainstorm input, not a pre-decision; the owner's threat-accumulator feedback and the pull-density shape carry equal standing until reconciled live. The corpus cannot adjudicate between them (both are unsupported). The owner must reconcile these at the brainstorm with full awareness that this is novel design territory.\n\nDEV-OF-RECORD DECISIONS (shape chosen and defended -- not forks):\n\nA. LEASH HEAL: No-heal on leash return (owner's stated preference). Corpus-backed by RuneScape's Elvarg boss HP persistence at 76.7% between player deaths [bill-runescape 00:12:54-00:12:56] -- explicitly described as a 'patience/logistics check rather than a mechanical-skill check.' This is the closest corpus analog to 'enemies keep HP when player disengages.' Chip-farming is controlled by respawn context: the 300f rusher respawn means the neighborhood refills between leash cycles, so a damaged enemy inside a fresh pack is more dangerous than a healed enemy alone. Retreat costs CONTEXT without making damage disappear. If chip-farming surfaces as dominant strategy in the fun-verify, the respawn timer is the tuning lever (shorter = denser context on return), not adding a heal mechanic.\n\nB. AGGRO SOFT-CAP: Soft cap on ENGAGEMENT (max N attack), no cap on PRESENCE (others follow, close distance, do not swing). This creates visual threat density that signals the danger level (the player's can-I-die-here assessment, analogous to Tibia's hunting-spot evaluation) while keeping mechanical lethality bounded. IMPORTANT: spatial encirclement/path-blocking by non-attacking PvE enemies is NOVEL DESIGN with zero corpus evidence. The corpus backs only multi-enemy LETHAL DENSITY (Tibia HP 1178 to 534 in 2s from simultaneous attackers), not non-attacking spatial containment or path-blocking. This shape must be defended from game-two's own measured problems (gate-camping creating blocked corridors, 2/2 uncontested recoveries, Q1 'standing in line'), not citations. The mechanic is: AI state machine has 'engaged' (attacks, capped at N) and 'pressuring' (follows, blocks escape routes, does not attack, uncapped) states. Specific N value (parking lot says 8-12) set in data and tuned by measurement.\n\nC. DEATH CADENCE: Rarer-but-heavier (Tibia-faithful direction). Deaths should be session-notable events the player dreads, not a 40-second rhythm. The corpus clearly positions this: Tibia deaths are notable enough to skip a play day; game-two currently has 8 wipes in 5.5 sim-minutes. A2's leash/density system should reduce death frequency while increasing per-death cost (the pile is larger when you finally die because you hunted longer between deaths). The alternative (costlier-at-same-frequency: preserve the 40s rhythm, just make each wipe hurt more) preserves the current arcade cadence. PARKING_LOT line 217-218 states 'threat should make death rarer but heavier' -- adopted as the direction. Owner can object at the brainstorm if they prefer the alternative cadence.\n\nD. TANK-FIRST POSSESSION: Ships bundled with A2, not standalone (settled routing per PARKING_LOT lines 128-131). A2 re-pilots all 7 replay scripts anyway (new leash/threat behavior changes enemy movement patterns); re-piloting twice is pure waste. No owner decision needed.",
 "implications_pile": "WHAT THE CORPUS SAYS VALUE SHOULD BUY (sinks):\n\nThe corpus identifies three proven sink categories that make accumulated value functional:\n\n1. SUSTAIN (per-minute survival cost): Tibia potions decrement one-for-one every few seconds; sessions run -47,270 gold. Daggerfall: torches, food, water, camping gear all degrade/break/spoil. New World: potion packs cost 25 Azoth from the strategic pool. The sink is: STAYING IN THE FIELD costs resources from the same pool the field produces. The pile buys HUNT LENGTH.\n\n2. DEATH INSURANCE (pre-purchased): Tibia blessings at 9,600g each, six required, consumed on death. Buying them converts safe gold into protection for at-risk carry. The sink is: PREPARING FOR RISK costs the pile before risk is taken.\n\n3. POWER DURATION (decaying buffs): Tibia imbuements at 60,000g + materials for 20h timed enchant. Daggerfall weapon condition degrades through tiers. The sink is: COMBAT EFFECTIVENESS decays and must be re-purchased from the pile.\n\nWHICH SINK SHAPES FIT A MONSTER PACK WITH A VAT:\n\nGame-two's topology: player controls a 3-body pack (striker/blocker/lobber), bodies die and refresh only via wipes at the hub (the vat), banked value accumulates at the hub, economy is single-player with fixed NPC-equivalent pricing (no player market).\n\n1. VAT RE-GROWTH AS SUSTAIN SINK (D1b, already designed/parked): Bodies that die mid-hunt can be re-crewed at the hub for a PRICE from the banked pile. This is the synthesis spec's FR-032 category 1 (consumable restock) mapped onto the pack topology. The pile buys hunt length by replacing dead bodies. Fits cleanly: the vat is the pack's 'potion stack' -- each re-crew is a potion consumed, visible on the ledger. The parking-lot explicitly routes this: 'healing/re-growth PRICED in banked value so the banked pile buys hunt length.'\n\n2. PRICED INVOCATION AS FIELD SUSTAIN: The owner's healer/Navi kernel (portable AoE heal) routed as a PRICED invocation -- a bank-sink deployable in the field. Each heal costs banked value. This maps to Tibia's per-potion drain without requiring an inventory/potion UI. Fits: a single interact at the hub loads a charge; using it in the field draws down the pile.\n\n3. HUNT PREPARATION AS INSURANCE: Pre-purchasing something at the hub that mitigates the next wipe or extends the corpse term (insurance, per FR-041). Maps to Tibia blessings. Fits the vat topology: spend banked before departing so death costs less.\n\nWHAT DOES NOT FIT:\n\n- Decaying weapon buffs (no equipment system exists; kits are fixed)\n- Travel fees (the map is one continuous zone transition, no boats/NPCs)\n- Market/auction sinks (single-player, no player economy)\n- Aspirational property (no house/horse/endgame purchase -- session-only by owner decision)\n- Imbuements on specific gear slots (no gear system)\n\nTHE CRITICAL CONSTRAINT: Economy (D1b, spending banked) is explicitly PARKED in all branches until A2 is fun-verified. The pile's functional meaning cannot ship before threat does. A2 must make the pile feel AT-RISK (emotional weight) before D1b makes it SPEND (functional weight). The corpus confirms this ordering: Tibia's hunt runs negative BECAUSE you are burning potions WHILE at death risk -- sustain without threat is just a timer.",
 "corpus_gaps": [
  "Aggro/threat/pull/leash systems: ZERO touchstone evidence across 5 games and 8 videos for designed aggro mechanics. One testimony-only data point exists (Daggerfall wraith pursuit as a material-gating flee trigger), but no threat tables, aggro radii, pull mechanics, or leash behavior are demonstrated as designed systems. A2's entire design space (threat-accumulator, pull-density, aggro soft-cap 8-12, chaser cap, leash-with-no-heal) must be defended solely from game-two's own measured problems (gate-camping, 2/2 uncontested recoveries, flat session shape).",
  "Active corpse contestation by enemies: Only New World shows death-drops lootable by others (PvP context). No corpus game shows PvE enemies contesting a corpse recovery. FR-043's 'scavenging on expiry' has zero observed mechanic to cite -- it is pure novel design.",
  "Respawn timing as a designed pressure lever: No corpus game's respawn timer is observed or specified. Game-two's 300f rusher respawn creates emergent gate-camping but has no touchstone validation for its cadence or downstream effects.",
  "Multi-death spirals and bankruptcy states: No corpus game shows what happens when a player dies on the recovery run, or when they cannot afford to restock after a loss. The synthesis spec flags this as absent. Game-two must design its own floor/recovery path.",
  "Convenience-death prevention: No corpus game addresses why players would not suicide-to-town as free fast-travel when carrying nothing. Game-two's Q6 has been clean (zero convenience deaths across all verifies), but no corpus solution exists if it ever surfaces.",
  "Pack-based combat consequence: No corpus game uses a multi-body pack where individual body deaths create mid-hunt attrition while the player persists. The vat re-crew mechanic has no touchstone -- it is a topology-specific invention.",
  "The pull mechanic -- what draws the player deeper against rational interest in banking early: No corpus game demonstrates a greed lever or depth-reward curve that tempts over-extension. Tibia's XP/h optimization and spot selection are the closest analog but operate at session-planning scale, not moment-to-moment temptation.",
  "Inflation control over long play with fixed NPC prices: FR-030 commits fixed deterministic prices + unlimited creature drops = unbounded wealth accumulation. No corpus game with fixed prices shows how this is controlled long-term without a player economy to absorb excess."
 ],
 "fork_candidates": [
  {
   "id": "F1",
   "question": "Should A2's threat model be a PER-HUMAN THREAT ACCUMULATOR (enemies track per-body aggro that taunt caps) or a ZONE-DENSITY COMMITMENT model (player chooses how deep to wade into pre-set spawn clusters, density is the risk)?",
   "why_owner_level": "These produce fundamentally different games. The accumulator makes combat a tactical aggro-management puzzle (MMO tank fantasy). The density model makes ROUTE SELECTION the core risk decision (Tibia hunting-spot fantasy). Both solve the diagnosed problem (2/2 uncontested recoveries) but through incompatible mechanics. The owner already expressed both preferences at different times (threat-accumulator shape in the parking lot feedback; route/spot selection in the earlier Tibia-faithful framing).",
   "options": [
    {
     "label": "Per-human threat accumulator",
     "evidence": "Owner's parking-lot feedback picked this shape (taunt as threat CEILING). Preserves the fun-verified taunt hard-lock (300f). Maps to the EK-1037 Hunt Analyser's group-combat framing. BUT: zero corpus support for threat tables; requires inventing aggro decay, threat-per-hit, cap behavior from scratch; risks the Kethral complexity trap (invisible AI weighting the owner once rejected as 'an extra for later')."
    },
    {
     "label": "Zone-density commitment (spawn cluster depth)",
     "evidence": "Strongest corpus pattern: 'hunting-spot selection IS the core risk decision' (Tibia); 'every departure is a wager you wrote' (synthesis direction.md). Player commits to a density level by walking deeper. Simpler to implement (spatial, not per-entity state). BUT: requires map redesign for graduated depth (current map has one gate to one district); does not directly solve gate-camping (enemies are already AT the gate)."
    },
    {
     "label": "Hybrid: density zones with a local accumulator that triggers leash",
     "evidence": "Depth determines baseline threat; lingering/killing in one spot accumulates local heat that eventually leashes nearby enemies home (dispersal pressure). Solves gate-camping (heat at the gate forces the player to push deeper or retreat). Novel -- zero corpus support but addresses both diagnosed problems (flat density + gate-camping) simultaneously."
    }
   ],
   "recommendation": "The hybrid. Pure accumulator is corpus-unsupported and risks Kethral complexity. Pure density requires a map overhaul that is currently out of scope (A3 territory). The hybrid uses spatial depth as the primary risk selector (corpus-backed) and a simple local heat counter as the leash trigger (solves gate-camping from game-two's own measurement), while keeping taunt's hard-lock intact as the tactical layer within the chosen depth. This recommendation is brainstorm input, not a pre-decision; the owner's threat-accumulator feedback and the pull-density shape carry equal standing until reconciled live. The corpus cannot adjudicate between them (both are unsupported). But this is genuinely the owner's call -- it determines whether the game feels like an MMO tank sim or a Tibia-style expedition planner."
  },
  {
   "id": "F2",
   "question": "Should enemies CONTEST the corpse recovery (active threat during the run-back) or should the corpse be threatened only by a PASSIVE TIMER (current D1 design)?",
   "why_owner_level": "This determines the fundamental feeling of death. Active contest means the run-back is authored danger (New World model: enemies can loot your drop). Passive timer means the run-back is a logistics race against the clock (current D1, which produced 'too long/tedious' and 'standing in line'). The owner's Q1 'standing in line' and the secondary routing signal ('threat never contests the corpse') both point toward active contest -- but the owner also demoted A2 as 'an extra for later' earlier, suggesting complexity aversion.",
   "options": [
    {
     "label": "Active contest: enemies near the corpse site are drawn to it / guard it",
     "evidence": "New World: death-drops lootable by enemies. D1 secondary routing: '2/2 uncontested recoveries' diagnosed as a problem. Would make the run-back dangerous (Q2a 'in between, never in doubt' becomes 'in doubt'). BUT: only one corpus game does this (PvP context, not PvE); requires AI that treats corpses as objectives (novel design, no corpus backing)."
    },
    {
     "label": "Passive timer only (current D1 + accelerated decay)",
     "evidence": "Current D1 design: term 5400f, grace 2700f. Q5 'never noticed' means the timer is not felt. Could be tuned shorter to create urgency. Simpler -- no new AI behavior needed. BUT: five verifies have shown this does not generate dread; shortening it risks unfair losses without adding interesting decisions."
    },
    {
     "label": "Environmental decay: the corpse attracts scavengers on a delay (FR-043 'subject to decay/scavenging on expiry')",
     "evidence": "Synthesis spec FR-043 NEEDS CLARIFICATION marker explicitly names this space. Scavengers would be a visible clock (you see them approaching/consuming) rather than an invisible timer. Bridges the gap: more threatening than a number, less complex than full aggro-toward-corpse AI. BUT: zero corpus evidence for PvE scavenger mechanics; D3 in the parking lot ('scavengers + term-extension marks') is explicitly parked."
    },
    {
     "label": "No contest, but the RUN-BACK traverses live threat (enemies respawn between hub and corpse)",
     "evidence": "Gate-camping measurement: rushers idle at the gate, respawns walk toward last fight. If A2 ships with leash, the run-back naturally passes through re-formed threat. Contest emerges from the live world state rather than a corpse-specific mechanic. Cheapest implementation -- no new system, just A2's leash/respawn naturally creates the corridor danger."
    }
   ],
   "recommendation": "Option 4 (live threat on the corridor). It solves the 'standing in line' / 'never in doubt' findings without introducing a corpse-specific system. A2's leash/respawn behavior naturally re-populates the path between hub and death site. The corpse itself stays passive-timer, but the JOURNEY is dangerous. This is the cheapest probe of whether contest matters before committing to scavenger AI (D3). But the owner may want the more dramatic corpse-under-siege feeling -- that is taste."
  },
  {
   "id": "F3",
   "question": "[POST-A2 DESIGN SPACE -- deferred, no decision needed this session] Should the BANKED pile feed sustain costs DURING the hunt (mid-field spending: heals, re-crews draw from banked in real-time) or only AT THE HUB (you spend banked value on preparation before departing)?",
   "why_owner_level": "Economy is explicitly PARKED in ALL branches (locked decision #3) until A2 is fun-verified. PARKING_LOT line 219-220 acknowledges 'what does the pile buy, and when' as a legitimate brainstorm section per owner choice -- this fork is recorded for that future brainstorm, not for decision NOW. The options below are future territory to revisit only after A2's fun-verify result is known. Included here as forward-looking prep because the A2 spec must be designed with awareness of which sink topology it will eventually serve.",
   "options": [
    {
     "label": "Mid-field spending (pile drains live during combat)",
     "evidence": "Tibia: potions decrement one-for-one every few seconds, visible stack drain. The owner's healer kernel routed as 'portable bank-sink.' Makes the ledger's P&L column live -- the banked number ticks DOWN while hunting. Creates the negative-session possibility (FR-033: expeditions MUST be able to run negative). Requires a real-time drain UI; creates the 'what if I run out mid-fight' bankruptcy spiral question (corpus gap)."
    },
    {
     "label": "Hub-only spending (provision before departure)",
     "evidence": "Daggerfall: buy torches/food/water in town before adventuring. Parking lot: 're-crew AT THE HUB for a fee.' Simpler -- the pile only changes at the hub (bank adds, re-crew/prep subtracts). Each departure is a visible wager ('I had 47, I spent 12 on re-crew + insurance, I leave with 35 at risk'). Does not create mid-hunt drain; the field segment is still free once you leave (same 'no sustain cost' problem unless A2's threat alone is enough)."
    },
    {
     "label": "Both: hub preparation + a single mid-field priced ability (the healer invocation)",
     "evidence": "Owner's own routing: re-crew at hub (bodies) + priced invocation in field (heals). This layers: the hub spend is the expedition bet, the field spend is the emergency brake. Banked drains at two rates: large discrete chunks at hub, small ones mid-hunt. Creates the 'do I burn my last charge to survive this fight or save it for the next' decision."
    }
   ],
   "recommendation": "No recommendation issued -- this decision is deferred behind A2's fun-verify gate (locked decision #3). The options are recorded for the D1b brainstorm that triggers if/when A2 proves threat generates emotional weight for the pile. The owner's routing (hub re-crew + field healer invocation) points toward Option 3 but has not been tested against the alternative topologies."
  },
  {
   "id": "F4",
   "question": "Should A2 produce a DEPTH GRADIENT (deeper = richer drops + denser spawns, creating a greed-vs-safety curve) within the existing map, or stay FLAT DENSITY (the current single district with uniform spawn distribution)?",
   "why_owner_level": "This is the game's core spatial risk architecture. A depth gradient creates the 'bank or push deeper' decision the owner has been testing for five verifies -- the question only becomes real if deeper IS richer. Flat density means the bank-or-push question is purely about accumulated carry (time investment), not about choosing a harder zone for better rewards. The owner's A3 (nest advance / district progression) is parked and would deliver this -- but A2 might need a minimal gradient to make threat feel graduated rather than binary (safe hub vs. uniform danger).",
   "options": [
    {
     "label": "Minimal gradient within existing map (spawn density increases with distance from hub)",
     "evidence": "Current map has one gate separating hub from district. Could graduate density: sparse near gate, dense at far end. Cheapest implementation (data change to spawn positions). Creates 'how deep do I wade' without new zones. BUT: current map may be too small for meaningful graduation; A3 is parked."
    },
    {
     "label": "Stay flat, let A2's leash/accumulator create emergent difficulty scaling",
     "evidence": "If A2 introduces heat accumulation or aggro caps, staying in one area naturally gets harder over time. No map change needed. The gradient is temporal (how long you stay) not spatial (how far you go). BUT: 'bank or push deeper' has no spatial meaning -- it becomes 'bank or stay longer', which is already what produces the arcade feel."
    },
    {
     "label": "Defer entirely to A3 (multiple districts with escalating difficulty/rewards)",
     "evidence": "A3 is explicitly parked ('nest advance / district progression'). Full solution but blocked by scope contract. A2 ships without it; the gradient arrives later. Risk: A2's fun-verify may fail for the same reason D1 failed -- without graduated risk there is no real bank-or-push decision to test."
    }
   ],
   "recommendation": "Option 1 (minimal gradient within existing map). Five verifies have asked 'bank or push deeper' and gotten 'still a chore' partly because there IS no deeper -- the district is uniformly dangerous. A2 needs spatial graduation to make its threat model testable. A minimal data change (denser spawns at the far end of the existing district) gives the fun-verify a real 'deeper = richer + more dangerous' to test without requiring A3's full multi-district system. But the owner may see this as scope creep into A3 -- that is the fork."
  },
  {
   "id": "F5",
   "question": "When A2 ships, should the fun-verify test A2 ALONE (threat without economy) or should D1b (vat re-crew fees as the first sink) ship alongside it as a minimal bundle?",
   "why_owner_level": "The locked routing says 'Economy stays parked in ALL branches' and the owner explicitly parked D1b. PARKING_LOT line 219-220 acknowledges 'what does the pile buy, and when' as a legitimate brainstorm section per owner choice -- so presenting this fork here is the owner's own pre-registered open question, not a unilateral re-litigation of the lock. The risk: A2's fun-verify may produce a SIXTH 'still a chore' because threat makes death scary but the pile still has no function, and five clean single-variable verifies have demonstrated experimental separability, supporting one-at-a-time testing.",
   "options": [
    {
     "label": "A2 alone (one variable at a time, economy stays parked)",
     "evidence": "Every prior verify tested one variable and got a clean attributable result. D1 proved drama does not move the chore. Ledger proved legibility does not. If A2 (threat) alone also does not move it, that is a CLEAR signal that D1b (economy) is the actual answer. Bundling obscures attribution. Owner explicitly locked: 'economy parked in ALL branches.' Five clean single-variable verifies prove the variables ARE separable for experimental purposes."
    },
    {
     "label": "A2 + minimal D1b (vat re-crew at a fixed price) as a bundle",
     "evidence": "The corpus consensus is that threat and sustain-cost co-occur (Tibia potions drain WHILE at death risk). Threat without cost may still produce a free-death rhythm -- you lose the pile on a wipe, but since the pile buys nothing, losing it is losing nothing. Five verifies of 'still a chore' + 'wouldn't care' suggest the MEANING answer requires both variables active. Risk of a sixth failed verify is elevated without economy."
    }
   ],
   "recommendation": "A2 alone (Option 1). The owner's locked routing is explicit and has produced clean experimental results five times. If A2 fails, the attribution is unambiguous and D1b promotes with full evidence. Bundling risks the Kethral trap (shipping complexity before proving each layer). BUT: the A2 spec must pre-register this routing explicitly -- if the sixth verify returns 'still a chore' WITH genuine threat (wipes that cost time, contested recoveries, dread-inducing density), the pre-registered next step is D1b immediate promotion, not another iteration on threat. The reframe of this fork is: IF A2 fails, does D1b auto-promote (like A2 itself auto-promoted from the fifth verify) or does it require its own scope debate? The recommendation is auto-promote, pre-registered in the spec."
  }
 ]
}
```

## Critic issues (all applied or acknowledged by the repair pass)

```json
[
 {
  "verdict": "repair",
  "issues": [
   {
    "severity": "critical",
    "issue": "F9 recommends a presentation change (move banked total to hub-only display) explicitly framed as fixing 'arcade drift' -- a meaning concern. This is textbook 'iterate presentation as a meaning lever,' which LB-1 refuted and locked decision #2 prohibits ('do not iterate presentation further as a meaning lever'). The fifth verify proved: Q1 'landed as a payoff' validates the CURRENT form; changing where the total renders risks regressing that signal while pursuing a proven-dead direction. The ledger disposition is STAYS (locked #6) -- its current presentation form is the one that earned Q1's positive reading; altering it is not polish, it is re-litigating the refuted lever.",
    "fix": "Remove F9 entirely, or reframe it as a POST-D1b UX fork (only relevant once the pile actually buys something and display context matters for spend decisions). Under no circumstance present it as an A2-era fork or frame its purpose as addressing meaning/arcade-drift -- that path is closed by two refutations."
   },
   {
    "severity": "critical",
    "issue": "F8 presents 'bundle D1b with A2' as a live fork option, directly re-litigating locked decision #3 ('Economy stays PARKED in ALL branches -- D1b, spending-banked, potions, shops do not enter until A2 is fun-verified'). However, PARKING_LOT line 219-220 explicitly names 'what does the pile buy, and when' as a legitimate brainstorm section per owner choice. The contradiction: the scope contract says ALL-CAPS PARKED; the parking lot says it is an explicit open section. F8 must acknowledge this tension rather than presenting the bundle option generically. Its Option 2's argument ('the variables are not separable') also contradicts the measured experimental design -- five verifies successfully tested single variables with clean attributable results, demonstrating separability.",
    "fix": "Keep F8 but (a) cite the PARKING_LOT line 219-220 acknowledgment that this is a legitimate brainstorm section per owner choice (not a unilateral re-litigation), (b) remove the claim 'the variables are not separable' from Option 2's evidence -- five clean single-variable verifies prove they ARE separable, and (c) note that the fork's framing should be 'IF A2 fails, does D1b auto-promote or require its own verify' rather than 'should we bundle now' -- the latter is already answered by the lock."
   },
   {
    "severity": "moderate",
    "issue": "F6 presents tank-first possession timing as an open fork when locked decision #8 explicitly closes it: 'Tank-first possession ships WITH A2 (invalidates all 7 replay scripts, needs re-pilot).' The PARKING_LOT (line 128-131) records the dev-of-record routing: 'SHIP WITH A2 (or whichever next increment re-pilots anyway); do not ship standalone.' The recommendation aligns with the lock, but presenting a closed routing as an open fork wastes owner decision bandwidth on a settled question.",
    "fix": "Demote F6 from a fork candidate to a settled-routing note: 'Tank-first possession ships with A2 (locked -- A2 re-pilots all 7 scripts anyway; the cost of shipping standalone is pure waste). No owner decision needed.' Do not present it alongside genuine open forks."
   },
   {
    "severity": "moderate",
    "issue": "F3 pre-designs D1b economy sink shapes (mid-field vs hub-only spending) as a current fork candidate. Economy is explicitly PARKED in ALL branches (locked #3). While the fork acknowledges the park in its recommendation, presenting detailed spend-model options with evidence and a recommendation ('Option 3: both') pre-commits to a shape before A2 is even specified, let alone fun-verified. The PARKING_LOT's 'what does the pile buy' brainstorm section is legitimate forward-looking prep -- but F3 goes beyond prep into pre-design with a stated recommendation.",
    "fix": "Reframe F3 as brainstorm background material rather than a fork requiring an owner decision NOW. Move it to an appendix or mark it as 'post-A2 design space (deferred -- no decision needed this session).' Remove the recommendation; present the options as future territory to revisit only after A2's fun-verify result is known."
   },
   {
    "severity": "low",
    "issue": "F1's recommendation ('the hybrid') pre-leans toward one reconciliation outcome before the brainstorm, which locked decision #10 says must be 'RECONCILED at the A2 brainstorm, not chosen a priori.' The fork format inherently presents a recommendation, and it qualifies with 'genuinely the owner's call' -- but the RECONCILIATION NOTE in implications_a2 also pre-leans ('favors the PULL-DENSITY shape'). Together they create a gravity toward a specific answer before the brainstorm begins.",
    "fix": "No structural change needed, but add an explicit caveat to both F1's recommendation and the implications_a2 RECONCILIATION NOTE: 'This recommendation is brainstorm input, not a pre-decision; the owner's threat-accumulator feedback and the pull-density shape carry equal standing until reconciled live. The corpus cannot adjudicate between them (both are unsupported).'"
   }
  ]
 },
 {
  "verdict": "pass",
  "issues": [
   {
    "severity": "minor",
    "issue": "F6 (tank-first possession timing) is already resolved in PARKING_LOT.md line 127-131 ('SHIP WITH A2; do not ship standalone') -- presenting it as an open fork contradicts the dev-of-record role and wastes owner brainstorm attention. The owner's feedback is recorded and the dev already made the routing call.",
    "fix": "Cut F6 from the fork set entirely. Note in the brainstorm preamble that tank-first ships bundled with A2 per the existing routing."
   },
   {
    "severity": "minor",
    "issue": "F4 (leash heal), F7 (aggro soft-cap mechanics), and F9 (ledger running total display) are engineering/presentation decisions within the dev-of-record's authority per CLAUDE.md ('design calls are Claude's to make and defend; shape, trigger moment, and presentation are spec decisions'). The owner already stated 'no-heal' for F4, '8-12 cap' for F7, and the ledger disposition ('STAYS through A2') for F9. These should be dev decisions defended in the spec, not owner forks.",
    "fix": "Demote F4/F7/F9 from owner-facing forks to dev-of-record spec decisions. Present the chosen shape and rationale in the A2 spec rather than asking."
   },
   {
    "severity": "minor",
    "issue": "RuneScape Elvarg boss HP persistence (76.7% retained between player deaths, bill-runescape 00:12:54-00:12:56, explicitly noted as 'patience/logistics check rather than a mechanical-skill check' in the analyst inference) is never surfaced in the synthesis despite being the closest corpus analog to 'enemies keep HP when player disengages' -- directly relevant to F4's evidence base. The synthesis states F4 Option 1 has only 'owner's named preference' as evidence, which understates the corpus support.",
    "fix": "If F4 stays as a fork, add the RuneScape Elvarg citation under Option 1 evidence. If F4 is demoted to a dev decision per the above, cite it in the spec rationale for the no-heal shape."
   },
   {
    "severity": "minor",
    "issue": "No fork addresses the death CADENCE target: should A2 make death rarer-and-heavier (Tibia-faithful, where deaths are session-ending events the player dreads) or costlier-at-same-frequency (current 8-wipes-in-5.5-min rhythm preserved, each wipe costs more)? The PARKING_LOT states 'threat should make death rarer but heavier' as a given, but this has never been validated as an owner choice vs. the alternative. The corpus clearly poses this: Tibia deaths are notable enough to skip a play day; game-two deaths happen every 40 seconds.",
    "fix": "Either add this as a fork (owner-level taste decision between two valid games) or explicitly flag in the A2 spec preamble that 'rarer but heavier' is the assumed direction, citing the PARKING_LOT line and the corpus evidence, so the owner can object if they prefer the alternative."
   }
  ]
 },
 {
  "verdict": "repair",
  "issues": [
   {
    "severity": "critical",
    "issue": "F7 recommendation claims 'The encirclement closes escape routes (spatial pressure, corpus-backed from Tibia/Daggerfall density)' -- but spatial encirclement/path-blocking by PvE enemies has ZERO corpus evidence. Tibia shows 'surrounded by Bonebeasts dies' (LETHAL DAMAGE from multi-hit, not spatial blocking), and 'aggression flags block pathing' is PvP-only (bill-peor-seg014). Daggerfall states 'Pressure is LOGISTICAL and INFORMATIONAL, not tactical' with no spatial blocking observed. The corpus evidences DENSITY CAUSING SIMULTANEOUS DAMAGE, not enemies forming a spatial cordon that closes escape routes. The synthesis itself correctly states in implications_a2: 'AGGRO SYSTEMS. Zero evidence across 5 games and 8 videos for threat tables, aggro radii...' -- then contradicts itself by claiming corpus backing for an aggro-adjacent AI behavior in the F7 recommendation. The recommended Option 3 mechanic (enemies surround and 'pressure' without attacking, blocking paths) is entirely novel design with zero touchstone validation.",
    "fix": "Remove 'corpus-backed from Tibia/Daggerfall density' from the F7 recommendation. Replace with an honest framing: 'spatial encirclement is novel design (zero corpus evidence for PvE path-blocking); the corpus backs only multi-enemy LETHAL DENSITY (HP 1178 to 534 in 2s), not non-attacking spatial containment. This option must be defended from game-two's own measured problems (gate-camping, 2/2 uncontested recoveries), not citations.' The recommendation can still favor Option 3 on mechanical grounds -- just without the false corpus attribution."
   },
   {
    "severity": "critical",
    "issue": "Implications_a2 point 4 states 'No corpus game shows enemies chasing a player who disengages' -- but Daggerfall's design-judgment.md line 67 contains explicit testimony: 'the narrator describes exactly this dynamic -- fleeing a werewolf for lack of proper armament, and real terror when a wraith pursues -- as a signature of the tier system [say sergicio-crpg 00:16:03].' A wraith pursuing through mountains IS an enemy chasing after the player disengages. The blanket 'no corpus game shows' claim is false. This matters because the synthesis uses it to argue A2's 'active pursuit beyond initial engagement range' has zero license -- but it has exactly one testimony-based data point in Daggerfall (pursuit by material-immune enemies as a designed flee trigger).",
    "fix": "Amend point 4 to: 'One corpus game has TESTIMONY of pursuit (Daggerfall: wraith pursues through mountains as a material-gating flee trigger [say sergicio-crpg 00:16:03]) but this is: (a) testimony only, not footage-observed behavior; (b) specific to material-immune enemies that cannot be damaged, functioning as a retreat signal rather than a general aggro system; (c) contradicted by the same game showing the Hell Hound FLEEING the player. No corpus game demonstrates a general chase/pursuit system, and no pursuit with threat tables, range limits, or leash behavior is evidenced anywhere.' The distinction between one flee-trigger testimony and a designed aggro system remains valid -- but the blanket zero-evidence claim cannot stand."
   },
   {
    "severity": "moderate",
    "issue": "Divergence table row 'Corpse/death-cache contestation' states 'Tibia: no contest mechanism observed (recovery is travel-cost only)' -- implying Tibia has a corpse-recovery mechanic where the cost is travel. The Tibia corpus actually shows death RELOCATES to a distant spawn point (systems-map.md line 71: 'respawn placing the player in a distinct outdoor area far from the death site'). Items 'drop on death' is testimony-only (say bill-peor 00:03:44) and the corpus explicitly notes 'no footage shows a death with items on the ground.' There is NO evidence of a recoverable corpse or a return-to-death-site mechanic in Tibia. The 'recovery is travel-cost only' parenthetical fabricates a mechanic not evidenced in this corpus.",
    "fix": "Rewrite the Tibia entry in that divergence row to: 'Tibia: no corpse-recovery mechanic is evidenced. Death teleports to a distant spawn point and items are LOST (testimony only -- no footage of items on ground). The cost is restarting the hunt from scratch (travel + re-provision), not recovering a death-site cache. No contest mechanism exists because there is nothing to contest.' This corrects the false implication that Tibia has a corpse-run and makes the comparison to game-two's corpse containers more honest."
   },
   {
    "severity": "moderate",
    "issue": "F7 recommendation also claims 'It creates the Tibia visual dread (surrounded by a pack)' -- but the Tibia corpus does not evidence 'visual dread from being surrounded.' What is evidenced is: (1) rapid death from multi-hit density (HP 1178 to 534 in 2 seconds -- death is FAST, not slowly building dread); (2) PRE-HUNT dread from hunting-spot selection (vrynna evaluates every spot on a can-I-die-here axis). The emotional state 'dread from encirclement' is not sourced from any Tibia footage. Tibia's dread operates at the decision-to-enter-a-spot level, not at the mid-combat surrounded-feeling level. Attributing mid-combat encirclement dread to Tibia conflates two different emotional registers.",
    "fix": "Replace 'the Tibia visual dread (surrounded by a pack)' with 'visual threat density that signals the Tibia hunting-spot danger level (the player's can-I-die-here assessment).' The recommendation's mechanical logic (bounded lethality + visible threat) still works -- just cite it as what it is: a design invention that creates a visual analog to Tibia's pre-hunt risk reading, not a recreation of an observed Tibia mid-combat feeling."
   },
   {
    "severity": "low",
    "issue": "F9 Option 3 claims 'This mirrors Tibia's Hunt Analyser (live P&L during the hunt, bank balance only at the depot)' -- the corpus does not evidence that bank balance is viewable ONLY at the depot. Bank balances are observed (157,791 to 1,204,217 gold) but the corpus never specifies WHERE in the UI the player sees the bank balance -- it could be accessible from a menu anywhere, or only at the depot. The 'only at the depot' half of the mirror claim is unsupported interpretation.",
    "fix": "Soften to: 'This echoes the Tibia session shape where the Hunt Analyser provides live P&L during the hunt and the depot is the physical location where the at-risk-to-safe conversion happens.' Remove the claim about bank balance visibility being location-gated, since the corpus does not evidence that constraint."
   }
  ]
 }
]
```