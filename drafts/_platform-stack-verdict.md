# Platform/stack verdict (owner side-question, 2026-08-11 — background agent digest)

Owner asked mid-A2: stay Ruby-only? add C#? migrate to unreal-mcp? and later: online play /
GameLift? Digest of the agent's answers (owner read them live; banked here for reference).

## Verdict: STAY on Ruby+Gosu — a migration now would hurt

- All six verify failures were DESIGN problems, never a platform ceiling. Perf uses <2% of
  the frame budget (p95 0.23-0.28ms vs 16.6ms with 15 humans).
- The verification harness (tick-lock, byte-identical replays, md5 gates, vision critique)
  IS the competitive advantage — Godot/Unity/Unreal inject their own frame timing and
  actor lifecycle that fight tick-determinism; Rule 2 enforcement would be lost overnight.
- Porting an unproven design = the largest possible scope explosion with zero player-felt
  change (fails the every-commit-is-felt law; Kethral breadth failure at engine scale).
- Unreal specifically: 3D-first, Paper2D an afterthought; unreal-mcp is editor automation
  tooling, not a game framework; determinism is not Unreal's design goal. Not for this game.

## Named triggers that change the answer

| Trigger | Then |
|---|---|
| A verify says "fun, I want others playing it" | Port the proven design to Godot 4 or MonoGame (2D-native, determinism-friendly), 4-8 weeks |
| Perf p95 approaches 10ms at designed counts | YJIT (needs rustc in devkit) -> profile -> C-extend hot path; rewrite is third resort |
| Presentation needs shaders/particles beyond Gosu | Swap the renderer behind src/app/ — the sim stays |
| Multiplayer becomes real | See below — Ruby serves phases 1-2; server language matters only at scale |

## Online play: not now, and the prep is already happening by accident

- Tick-locked deterministic sim + serializable inputs (the replay scripts) = exactly the
  deterministic-lockstep netcode model (RTS classics). The replay format IS the multiplayer
  input format; the md5 gates ARE desync-proofing.
- Phase ladder: (1) WebSocket relay + authoritative Ruby sim on one Fargate task (~$5-15/mo)
  -> (2) autoscaled tasks -> (3) ONLY THEN GameLift (matchmaking, fleets) -> (4) persistent
  async economy (DynamoDB). Cognito/DynamoDB/ECS already on the account cover phases 1-2.
- The single prep item with real value later: a HEADLESS sim mode (tick without Gosu/GL).
  Half-day task; not worth doing before the loop is proven fun.
- Ruby's real online weakness: one session per MRI process at scale — solved at phase 3 by
  transcribing the isolated sim to a faster server language, keeping Ruby+Gosu as client.

## Honest fragility (not cheerleading)

Gosu is a one-maintainer gem compiled from source here (devkit required on fresh machines);
no YJIT without rustc; distributing a Ruby game to end users is awkward (Ocra/Traveling
Ruby). None of it matters while the only player is the owner and the fun thesis is the
bottleneck. Prototype in the cheapest medium; port the proven thing.
