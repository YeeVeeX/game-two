# game-two

A grid ARPG in Ruby + Gosu where you play a pack of three bodies
(Tab swaps): hunt enemies through connected zones, bank the value you
collect, pay tolls to open gates, and survive BOSS 1 — the one enemy
that can seize your body back.

![ZONE 1 gameplay: three-body pack, HUD, stations, and post-fight tally](docs/assets/gameplay.png)

All player-visible names are deliberate placeholders (ZONE 1, HUB 1,
BOSS 1, player 1…): this repo carries mechanics and engine only — no
lore, no creative writing (owner order, 2026-08-16).

- **Play:** `bin\play.cmd` (Windows) or `bin/play` — add `es` / `pt-br`
  for Spanish/Portuguese. Always quit with Esc (it saves telemetry).
- **Co-op:** host with `bin\host-coop.cmd`; join with `bin\join-coop.cmd`
  after both machines join the same Tailscale network.
- **Setup:** Ruby 3.4.10 **with DevKit** (gosu compiles from source), then
  `bundle install`. Portuguese onboarding: [docs/JUNIOR.md](docs/JUNIOR.md).
- **The sim is 100% deterministic** — replays reproduce tick-for-tick;
  every visual ships through a double-replay md5 gate + a vision critic
  ("the wall"). Current cycle + laws: [AGENTS.md](AGENTS.md); history:
  [docs/CHECKPOINT.md](docs/CHECKPOINT.md).
- **Tests:** `bundle exec rake` (git hooks run it on every commit/push).
