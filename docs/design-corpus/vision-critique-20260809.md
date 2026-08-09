# Vision critique (20260809-090905)

Model: us.anthropic.claude-fable-5 on bedrock-runtime (voice-dev/us-east-1). Persona: Tibia veteran + game-feel designer.
Sources: captures\world_loop, captures\critic_reel

## Key moments critique

```json
```json
{
  "first_impressions": "Warm town, orange ember player, clean grid — I know instantly which square is me and I like that. But within ten seconds I'm asking two questions the game never answers: 'which way am I facing?' and 'is that gold tile on the wall a door or decoration?' The town is dead — four identical brown blocks, no NPC, no sign of life — so the first feeling is 'test level,' not 'town I'll respawn in and care about.' The dungeon transition (warm brown to cold blue) is genuinely nice color language though. That contrast shift is the best first-10-seconds moment.",
  "readability": [
    {
      "issue": "The player's hurt-flash turns it pale white — which is EXACTLY the husk's bone color. In frame_1158 and frame_1530 I genuinely cannot tell which square is me. During a swarm, the one moment I most need to find myself is the moment I look identical to the things killing me. I'd bet money this is what caused the death in frame_1790.",
      "severity": "high",
      "frame": "frame_1530",
      "fix": "Hurt-flash the player to deep red or pure black, never toward white/bone. Alternatively flash by scaling/shaking the square instead of recoloring it. Player identity must survive every state."
    },
    {
      "issue": "Dungeon walls vs floor is a squint test. The cold blue wall tiles are maybe 15% lighter than the near-black floor. In frame_0320 I had to hunt for the wall columns. Chokepoint combat is impossible to plan if you can't parse the chokepoints at a glance.",
      "severity": "high",
      "frame": "frame_0320",
      "fix": "Push wall value up hard — walls should be 2-3x brighter than floor, or give walls a 1px lighter top edge. Floor can stay moody; walls carry the tactical information."
    },
    {
      "issue": "Telegraph yellow (frame_0614) is nearly the same hue as the gold gate tile. First time I saw the flash I thought 'is that a door?' A telegraph must mean exactly one thing: DANGER, MOVE.",
      "severity": "high",
      "frame": "frame_0614",
      "fix": "Telegraphs should pulse red/magenta or invert to hot white-red. Reserve gold exclusively for exits. One color, one meaning."
    },
    {
      "issue": "The player has zero facing indicator. In frame_0717 white attack tiles appear above the player and I have no idea if I aimed there or the game did. Grid combat lives and dies on knowing your facing before you commit to a swing.",
      "severity": "high",
      "frame": "frame_0717",
      "fix": "A small notch, darker edge, or 4px triangle on the facing side of the player square. Costs nothing, fixes everything about attack legibility."
    },
    {
      "issue": "The gold gate is a single tile flush inside the wall, and in the dungeon (frame_0320) it's half-clipped at the screen edge. I could walk past the exit of the entire zone without noticing it.",
      "severity": "medium",
      "frame": "frame_0320",
      "fix": "Make gates 1x2 or give them a slow pulse/glow. Exits should breathe."
    },
    {
      "issue": "HP bar is a naked red rect floating in the void — no border, no ticks, no number. I can't tell 'low' from 'critical' and the bar doesn't even visually belong to the game.",
      "severity": "medium",
      "frame": "frame_1530",
      "fix": "1px border, dark backing at full width so max HP is always visible, and a color shift (red -> flashing) under 25%."
    }
  ],
  "tibia_feel": [
    {
      "gap": "No corpses, no loot. In frame_0717 the husk just... stops existing. In Tibia the corpse IS the reward loop — you kill, you open, you check. Here a kill leaves the world identical to before the fight, which makes combat feel like it never happened.",
      "severity": "high",
      "fix": "Leave a dark stain/corpse tile that persists 10-20 seconds. Even a placeholder gray rect you can step on. Later it holds loot."
    },
    {
      "gap": "No health bars over creatures. Every Tibia player reads the tiny green-to-red bar above a monster reflexively — it's how you decide 'commit or retreat.' These husks give me nothing; I don't know if I'm one hit from a kill or five.",
      "severity": "high",
      "fix": "4px bar above each husk while in combat. This is the single most Tibia-defining UI element and it's free with rects."
    },
    {
      "gap": "No visible attack exhaust rhythm. Old Tibia combat feel is the METRONOME — you know exactly when your next hit lands, and you dance steps around that beat. From these frames the swing (frame_0628) has no cooldown representation, so there's no beat to dance to.",
      "severity": "medium",
      "fix": "Tiny cooldown pip or dimming on the player square between swings. The dodge-step-between-hits dance needs a visible clock."
    },
    {
      "gap": "The chokepoints ARE here — those wall columns in Threketh are proper Tibia funnel geometry, and the 1-tile gaps would make great fighting positions — but the husks in frame_1530 converge diagonally-loose rather than stacking in a queue. Tibia monsters lining up in a corridor is the whole reason chokepoints matter.",
      "severity": "medium",
      "fix": "Make husk pathing prefer cardinal approaches and queue behind each other at chokes. Suddenly every 1-wide gap becomes a strategy."
    },
    {
      "gap": "Death sends me back to town with zero consequence shown. Tibia death HURTS — you lose things and the game makes sure you feel it. Frame_1880 is pixel-identical to frame_0001; the death might as well be a level select.",
      "severity": "low",
      "fix": "Even placeholder: a 'lost X embers' line on respawn, or the HP bar starting slightly reduced. Something must be different after dying."
    }
  ],
  "juice": [
    {
      "issue": "The hit-confirm in frame_0628 — white arc with the red-outlined tile marking the connected hit — is genuinely good and I want to say so. But it's the ONLY juice in the kill. No knockback offset on the husk, no particles, no corpse. The best frame in the set is 80% of the way to a great hit and stops.",
      "severity": "medium",
      "fix": "On hit: nudge the husk rect 4-6px away for 2 frames, flash it, and pop 3-4 tiny rect particles. Rects can be juicy; ask Nuclear Throne."
    },
    {
      "issue": "The YOU DIED screen (frame_1790) is a dimmed world and static red Helvetica. Death should be a PUNCH — this is a shrug. No screen shake implied, no red vignette, no slow fade.",
      "severity": "medium",
      "fix": "Hard 2-frame red flash on the killing blow, then desaturate over ~1s, then the text fades in oversized and settles. Make me sit in it."
    },
    {
      "issue": "Whiffed attacks (frame_0717) look identical to hits minus the red outline. A miss should feel airy and cheap so the hit feels heavy by contrast.",
      "severity": "low",
      "fix": "Whiff tiles at 40% alpha, half duration. Hits stay bright and linger a frame longer."
    },
    {
      "issue": "No trace of movement feel — no dust tick, no micro-scale squash on step. Static frames can't show interpolation, but they CAN show a residue tile or 1-frame stretch, and there's none.",
      "severity": "low",
      "fix": "A fading 20%-alpha ghost on the tile just vacated. Instantly communicates speed and direction in every screenshot."
    }
  ],
  "what_works": [
    "The color language is doing real work: warm town / cold dungeon is felt immediately, and ember-orange player on both palettes stays findable (until the hurt-flash betrays it).",
    "The hit-confirm red outline inside the swing arc (frame_0628) — that's a real game-feel decision, not an accident. Keep it.",
    "The HP bar damage-trail (the dark red remainder visible in frame_0717/frame_1530) — chunked, delayed damage display is proper juice already in the build.",
    "Threketh's layout has honest Tibia bones: vertical wall columns, 1-tile gaps, rooms that funnel. The geometry knows what game it wants to be.",
    "Zone name cards ('Threketh - The Entry Wound') give placeholder rects an identity. Good instinct."
  ],
  "top_3_changes": [
    "Fix the player hurt-flash so the player NEVER resembles a husk — this is actively killing players at the exact moment readability matters most.",
    "Add a facing indicator on the player square and re-color telegraphs away from gate-gold — combat is currently a guessing game about direction and danger, the two things grid combat must never leave ambiguous.",
    "Give kills consequence in the world: knockback nudge + flash + persistent corpse tile. Right now victory and nothing-happened look identical, and that's the difference between a combat loop and a screensaver."
  ]
}
```
```

## Motion reel critique

```json
```json
{
  "cadence_read": "Frames 0340–0370 show the player crossing roughly two tiles with perfectly uniform ~3px spacing per capture. That's a linear tween with zero acceleration curve — it reads as a soap bar gliding on ice, not a character stepping tiles. Old Tibia movement felt 'snappy' because the sprite committed to a tile and the walk offset eased into it; here there's no ease-out into the destination tile, no landing beat, no micro-pause between steps. The grid rhythm — the thing that makes tile movement feel like a drumbeat — is completely absent. It's technically smooth and emotionally dead. Also the player rect never changes AT ALL while moving: no bob, no lean, no facing indicator. From a still frame I cannot tell if this character is walking left, right, or standing still, and that's a readability failure the rectangle could solve for free.",
  "combat_motion": [
    {
      "issue": "The player has literally no attack animation. Frames 0620–0632: the white arc tiles appear, the husk flashes red, and the ember-orange rect does not move a single pixel. No lunge into the swing, no recoil, no anticipation frame. The attack feels like it comes from the UI, not from the character. This is the single biggest feel-killer in the reel.",
      "severity": "high",
      "fix": "2–3px lunge toward the attack direction on the swing frame, 1–2px recoil back over the next 3 frames. Even a rect can throw a punch."
    },
    {
      "issue": "The attack arc is a static 3-tile block that just SITS there. Frames 0620→0632 and 0710→0720 show the same three white tiles at near-identical brightness across 12+ frames. There's no sweep (left-to-right brightness rolling through the arc), no fast fade. Worse, frame 0720 shows the arc still glowing at full brightness with the enemy already dead and the player idle — is that hitbox live? A player can't tell active frames from afterimage.",
      "severity": "high",
      "fix": "Arc tiles spawn bright and decay to zero alpha over ~6 frames, staggered per tile to imply a sweep direction. Active window = bright, recovery = fading. Never leave a full-brightness hitbox on screen during idle."
    },
    {
      "issue": "Death is a pop. Between 0715 and 0720 the husk simply ceases to exist — no flash-to-white, no shrink, no scatter of pale fragments, no corpse tile. In Tibia even a rat left a body; here the kill, the most rewarding moment in the loop, has less visual weight than a single walk step.",
      "severity": "high",
      "fix": "3-frame death: flash white, scale down/shatter into 4–6 bone-colored particle rects, leave a dim splat tile for a few seconds. Rectangles can die dramatically."
    },
    {
      "issue": "Knockback teleports. Frame 0690 the husk is adjacent to the player; frame 0695 it's a full tile away, no in-between position captured despite the dense sampling. Hits shove the enemy instantly with no tween, so the impact reads as the enemy blinking away rather than being HIT.",
      "severity": "medium",
      "fix": "Fast ease-out tween on knockback (~4 frames, overshoot 2px and settle). The travel IS the impact."
    },
    {
      "issue": "The telegraph swell is doing its job — the husk brightens to yellow and visibly inflates a few pixels (0612→0620, 0705→0710) — but it's omnidirectional. A puffed-up yellow square tells me WHEN, not WHERE. In frames 0616–0624 the player is standing directly below it and has no idea if the diagonal is safe.",
      "severity": "medium",
      "fix": "Tint the tile(s) the husk will strike with a translucent yellow overlay during the swell. Grid combat lives and dies on threatened-tile clarity."
    },
    {
      "issue": "Hit feedback on the husk is a red tint (0628, 0690) and nothing else. No hitstop, no white-flash frame before the red, no visible screenshake in the impact frames. The red also risks reading as 'enraged/attacking' rather than 'hurt' since red is the universal danger color.",
      "severity": "medium",
      "fix": "1 frame flash-to-white, 2–3 frames of hitstop freezing both actors, 2px directional shake. White = hurt, keep red for enemy aggression states."
    }
  ],
  "animation_gaps": [
    {
      "gap": "No facing indicator on the player. Grid combat with directional attacks demands knowing which way you're pointed BEFORE you press attack. Every frame here, the player is an identical featureless square. Half the tension of Tibia chokepoint fights was orientation — here it doesn't exist visually.",
      "severity": "high",
      "fix": "A 4–6px notch, eye-dot, or brighter edge on the facing side of the player rect. Cheapest, highest-value pixel in the whole game."
    },
    {
      "gap": "Player attack recovery/exhaust is invisible. After the swing (0632, 0720) the player rect is indistinguishable from a fully-ready player. Veterans time their attacks around exhaust — there is no way to internalize the attack cooldown when the character shows nothing.",
      "severity": "high",
      "fix": "Dim the player rect slightly during recovery, or show a thin cooldown sliver under the rect that refills. The body should tell you when it's ready."
    },
    {
      "gap": "Telegraph → attack transition is ambiguous for the husk. It swells yellow (0612–0624), gets hit red (0628–0695), then is back to bone at 0700 and yellow again at 0705 — I genuinely can't tell if the hit CANCELLED its attack or merely delayed it. If getting hit interrupts telegraphs, that's a core combat rule the motion must state loudly.",
      "severity": "medium",
      "fix": "On interrupt: hard snap back to bone color with a brief desaturated 'stagger' frame (rect squashes 20% shorter). On non-interrupt: red flash layered OVER the sustained yellow."
    },
    {
      "gap": "Idle is a corpse. Standing still (0340 player pre-move, 0720 post-kill) the player is a static rect indistinguishable from a wall tile of a different color. An ember should breathe.",
      "severity": "low",
      "fix": "1px scale pulse or subtle brightness flicker on a ~1s cycle. Sells 'alive' and doubles as a visual heartbeat for game-running-vs-frozen."
    },
    {
      "gap": "Health bar damage (0690's dark chip segment) — actually good, the delayed drain ghost is reading clearly. But it's floating disconnected top-left while the fight happens center-screen; nothing at the point of impact tells me I took or dealt damage magnitude.",
      "severity": "low",
      "fix": "Keep the bar, add tiny rising damage-tick rects (not numbers, just pixel motes) at the hit location so eyes never have to leave the fight."
    }
  ],
  "top_3_changes": [
    "Give the player a body language vocabulary: facing notch + 2px attack lunge/recoil + recovery dim. Right now the protagonist is furniture that other things happen near.",
    "Make hits LAND: 1-frame white flash, 2–3 frame hitstop, tweened knockback, and a real death (flash → shatter → corpse tile). The kill in frame 0720 currently has zero payoff and it's the whole point of the loop.",
    "Replace linear walk tweens with ease-out-per-tile stepping (fast start, settle into the tile, brief beat). The grid should feel like a rhythm you play, not a conveyor belt you ride — that cadence is the entire soul of tile-based combat spacing."
  ]
}
```
```