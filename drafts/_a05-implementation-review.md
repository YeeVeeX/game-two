# A0.5 Implementation-Diff Adversarial Review

**Range:** `main...a0.5-specials-mark`
**Date:** 2026-08-10
**Verdict:** ACCEPT - all findings folded and re-verified

## Findings

### F1 - HIGH - Death now cancels uninterruptible active attacks

`Creature#take_hit` unconditionally calls `interrupt_action!` when the victim dies.
That erases an active rusher attack even though rushers have
`interrupt_on_hit: false`, contradicting the deterministic simultaneous-trade
contract documented in `World#resolve_attacks`.

Live reproduction:

```text
before_kill: [:active, :attack, true]
after_kill:  [:idle, nil, false]
interrupt_on_hit: false
```

Exact `World#resolve_attacks` reproduction:

```text
rusher_dead: true
rusher_action_after_death: [:idle, nil]
striker_hp: [80, 80]
```

The A0.5 forced-death rule only requires a dying body's **special** to be
cancelled. Preserve an uninterruptible basic attack already active in the
current resolution snapshot, while still cancelling specials on death.

Required proof: an integration test where a pack attack kills an active rusher
earlier in actor order and the rusher's already-active attack still lands in the
same `resolve_attacks` call. Keep the existing forced-death special cancellation
test green.

### F2 - MEDIUM - Volley renders a phantom local melee arc

`Creature#action_tiles` handles `ring`, `front1`, and `projectile`, then treats
every other arc as `arc3`. A live Lobber Volley therefore reports three adjacent
melee tiles during its windup/active state:

```text
origin: [15, 8]
arc: "volley"
rendered_action_tiles: [[16, 8], [16, 9], [16, 7]]
```

`Renderer#draw_attack` draws those tiles in addition to the delayed three-tile
impact telegraph. Volley should have no caster-local action tiles; its only
target telegraph is the World-owned impact entity.

Required proof: a Creature test asserting `action_tiles == []` for a Volley
special, while the existing World impact-geometry tests remain green.

### F3 - LOW - Ready special pips omit the planned white center

The committed implementation plan specifies a stable 10x10 kit-colored special
pip with a white center when ready. `Renderer#draw_hud` currently draws only the
solid kit-colored 10x10 square. The live ready-state capture confirms the center
indicator is absent.

Add the small white center only when a living body's special is ready. Spent and
dead pips remain fully dark. Re-run the special-pip visual gate after the change.

## Folded Resolutions

- **F1 resolved:** death now cancels a special, while an
  `interrupt_on_hit: false` basic attack already active remains eligible in the
  current deterministic resolution snapshot. The simultaneous-trade regression,
  forced-death special cancellation, and Slam override tests all pass.
- **F2 resolved:** `volley` joins `projectile` as remote-only action geometry;
  `Creature#action_tiles` returns no caster-local tiles.
- **F3 resolved:** every ready special pip now has a kit-colored 10x10 body with
  a centered white 4x4 readiness cue; spent and dead states remain dark.

## Verification

- `rake`: 96 runs, 372 assertions, 0 failures, 0 errors, 0 skips.
- `rake perf`: p95 0.038 ms, below the blocking 16.6 ms budget.
- `specials_chain`: 12 byte-identical captures, all 17 vision checks PASS.
- `world_loop`: 8 byte-identical captures, all 17 vision checks PASS.
- `district_hunt`: 10 byte-identical captures, all 17 vision checks PASS.
