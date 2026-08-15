# M2 adversarial review — in flight at goalcomp time (2026-08-09)

A code-reviewer agent is reviewing `git diff main..HEAD` on branch `a0-m2-kits-district`.
**If its result is lost to the compact: re-run it; do NOT merge without it.**

## What it was asked to hunt (re-run brief if dead)

1. Projectile lifecycle: leak across nest_respawn (enter_zone IS called in respawn_pack —
   verify clears `@projectiles`); dead-owner shots (`hostiles_for(p.owner)` on a corpse);
   first-tile-blocked fires.
2. Surround-slot determinism: `@slot_claims` rebuilt per tick, roster order; double-tick of
   one creature after mid-frame forced swap (possessed read AFTER swap in tick_world);
   cross-zone claim leaks (object-keyed).
3. Knockback param: every `take_hit` caller passes `knockback_tiles` where production needs
   it (default 0 = silent loss, not error).
4. Corpse records: pack corpse persists in district after nest respawn (intended?); FIFO cap.
5. Renderer: lunge offset consistency (ring/telegraph/notch), edge-pip clamp math, HUD dead
   bars.
6. district.json arrival tiles.
7. rake perf argv quoting.

## Already verified CLEAN by me (don't redo)

- `Hash.new(default).merge(...).freeze` keeps the default (renderer HUMAN_BODY safe) — probed
  live in ruby -e.
- District arrival tiles (1,12)(1,13)(1,14)(2,12)(2,13)(2,14)(0,13) all open floor; live
  probe: pack arrives on distinct passable tiles.
- 6s live launch smoke: window opens, no crash.

## When the verdict lands

Fold CONFIRMED findings (fix + regression test), re-run `rake` + BOTH gates + `rake perf` if
the sim changed, then merge `a0-m2-kits-district` → main (--no-ff) and hand the owner the
feel-check: kit identities (Striker/Blocker/Lobber), possessing the Lobber, Rusher pincer
pressure, District One. M1 precedent: 4 findings, 2 real (gate false-PASS, stagger bypass).
