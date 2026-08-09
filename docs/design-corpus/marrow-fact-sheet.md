# Marrow spec fact sheet (harvested from researcher agent, 2026-08-09)

Source: `.kiro/specs/marrow/requirements.md` + `design.md` (3,284 lines) in the old repo.
Extracted for the slice; numbers cited there by file:line. Survives compact — do not re-mine.

## Movement (marrow was pixel-based; owner has since ordered GRID-based — treat as feel reference only)
- Base 150 px/s; no momentum (stop within 1 frame); sprint 1.5x draining stamina 5/s
- Dodge: 80px over 0.25s, 20 stamina, 0.3s i-frames, 1.5s cooldown (floor 0.8s via skill)
- Stamina 100, regen 10/s after 0.5s delay; attacks cost 0 ("keep combat accessible")
- Camera lerp 0.1, clamps at zone bounds

## Combat
- Attack = single 0.4s state (4-frame anim); damage = weapon + skill bonus, min 1; starter sword 5 dmg / 50px / 0.4s
- Enemy->player: ceil(dmg * (1 - armor - defense%)), min 1
- Weapons: Sword 50px/0.4s; Axe 45px/0.6s hi-dmg; Spear 70px/0.5s; Dagger 30px/0.25s
- NO block/parry (armor = passive reduction only); no poise, just 0.3s DAMAGED state
- States: IDLE -> ATTACKING(0.4s)/DODGING(0.25s)/DAMAGED(0.3s) -> DEAD(1.5s fade)

## First enemy: Ravager
- 30 HP, 8 dmg, detect 250px, pursue 110 px/s chase-only, attack within 45px every 1.8s
- Telegraph was AUDIO-only 0.3s pre-impact (we made it visual — audio is placeholder by owner order)
- Death: loot after 0.8s (40% potion / 40% 10-20 gold / 15%+5% weapon)
- (Sentinel = enemy #2: 45HP, strafes 30%, enrages <50% HP — parked)

## Feel (implemented in game-two, verified fun by owner 2026-08-09)
- Hitstop: time_scale 0 for 2-3 frames — "highest-impact juice technique"
- Shake: intensity 2-5 by weapon weight, 0.08s; knockback 15-25px; enemy flash white 0.12s
- Explicit order: HitStop -> Shake -> Flash -> Knockback -> DamageNumber
- Death flow: drop gear as corpse -> fade 1.5s -> respawn Safe_Zone at 50% HP, lose 10% skill XP; corpse persists 10min
- Low-HP warning: red pulse every 1.5s below 25%

## Visual identity: NOT SPECIFIED in marrow (no palette/sprites/shape language).
Only: Safe_Zone brighter/warmer vs Danger_Zone; loot rarity glow white/green/blue/purple.
game-two's flat-rect identity is Claude's own (docs/SLICE_SPEC.md).

## Fun thesis (kept)
- "Warhaven-quality 2D combat... death hurts, choices matter" (req:14)
- "Every hit must feel impactful" (design:814)
- Pillars: risk/reward tension ("survival feels earned"); skills improve through use (no linear leveling)
