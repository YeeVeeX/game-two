# v18 FOUNDATION — THE PERSISTENT WORLD CYCLE, etapa 1 (2026-08-17)

Ratified by the owner 2026-08-17 ("yes approved"), same message that
closed the SIXTEENTH (v17 CUMPLIDO — verdict in
`drafts/_v17-fun-verify-skeleton-20260816.md`). This file is the
grounded plan the v18 opening session builds from: evidence pointers,
design forks with dev starting positions, staging, risks. The brainstorm
session closes the forks and writes the spec; nothing here is code yet.

## Why this cycle (the owner's vision, routed)

Owner vision drop 2026-08-17 (full routing in PARKING_LOT.md §"Owner
vision drop"): persistent shared world he and Junior "work on and expand
from", god/admin editor view, character persistence, livelier world.
Plus the SIXTEENTH's two Q3 frictions (respawn-too-fast-to-walk-back;
no mid-hunt sustain) corroborated by Junior's two signals (coop feels
easier; AI third body suicides).

Architectural honesty already delivered to the owner and accepted:
**always-online = server-authoritative = an architecture fork, PARKED
with a named trigger** (different-time play or a third player becomes
real). Persistence v1 delivers the felt vision on the lockstep
substrate: same world every session, progress accretes, host carries
the save.

## The three lanes (one increment, one wall, one fun-verify)

1. **Coop feel** — respawn/pacing/difficulty seat-count aware; priced
   mid-hunt sustain (design shape pre-decided 2026-08-11: spend banked
   value, portable, NEVER a free cooldown); third-body AI attrition tune
   (Junior's "se matando por nada").
2. **Persistence v1** — world+character state survives sessions.
   Host-authoritative save, wired into the session handshake beside the
   fingerprint; save/load round-trips the deterministic sim exactly.
3. **God-view v0** — OFFLINE full-map artifact (rake task rendering the
   whole world from data+save; `Gosu.render` capture machinery exists).
   Zero sim/netplay surface. The honest seed of the owner's editor
   vision; in-game map/teleport/editing all wait (parked, staged).

## Design forks for the brainstorm (dev starting positions — close per
## v13 precedent: recommendation + owner veto; batch the owner-level ones)

- **F1 What persists (owner-level):** characters (pack composition,
  inscriptions), banked value, world ARC state (seals broken, tolls
  paid, BOSS 1 defeated, camp re-homes). NOT live monster positions/HP
  — the field re-seeds each session (Tibia model: world resets, the
  character persists). Alternative shapes: full-world snapshot
  (heavier, brittle across dev churn) / arc-only (thinner than the ask).
- **F2 Save custody + sync (dev call):** ONE host-authoritative save
  file; joiner receives it over the wire at session start, save digest
  rides the handshake (fingerprint-law extension). Rejected starting
  positions: git-tracked save (merge conflicts, save-scumming, pull
  friction), per-seat saves (drift mine).
- **F3 Banked persists? (owner-level, re-opens D0 "session-only"):**
  YES — the owner's ask is the fun-thesis D0 was waiting for; banked +
  inscriptions ARE progression until an item system exists. Inscription
  semantics shift: judgment now persists across sessions.
- **F4 Solo play advances the shared world? (owner-level):** YES — one
  world save; whoever plays advances it. At 2-player-friends scale
  outpacing is the feature ("trabajar sobre el mismo mundo"), not a
  bug. Alternative: coop-only persistence (safer, thinner).
- **F5 Coop pacing shape (dev call):** data-driven seat-count scaling
  (respawn delay, density targets) in `data/balance/`; numbers at spec
  from telemetry (SIXTEENTH session log = the baseline evidence).
- **F6 Sustain verb (dev call):** priced field charge bought at the
  bank station (a counter beside banked — no inventory system);
  alternatives: channel-drain, healer-invocation (the parked
  fairy/Navi kernel). Owner law stands: priced in banked value.
- **F7 God-view v0 scope (dev call):** strictly offline this cycle
  (rake task → PNG). Any in-game surface promotes only via a future
  debate.

## Oracle (the SEVENTEENTH ask, two halves — pre-registered shape,
## final wording at spec)

- **Half A (PERSISTED):** two real owner+Junior sessions on different
  days, session 2 RESUMES the same world. Mechanical arbiter: save
  digest chain (session 2 loads exactly what session 1 wrote, both
  seats agree via handshake) + zero desyncs across BOTH sessions +
  at least one persisted fact provably carried (banked total /
  inscription / seal state in telemetry).
- **Half B (FELT):** both players asked separately, questions virgin:
  did the world feel CONTINUED (yours, accreting)? did the two Q3
  frictions disappear (respawn pressure, sustain)? free verdict.

## Laws that bite (inherited + new)

- Save/load must round-trip determinism: loaded state feeds the same
  digest machinery; a load divergence IS a desync — caught loudly at
  the first boundary. Dedicated round-trip test lane FIRST (the v17
  "digest lane first" precedent).
- Save carries a schema version; a version/digest mismatch at handshake
  is a NAMED refusal (exit 1), never a crash — Junior pulls often;
  saves either survive dev churn or refuse honestly.
- Persistence touches session boundaries only — the 16.6ms p95 tick
  budget is untouchable; no mid-tick IO.
- The single-player wall stays untouched; new capture surfaces (map
  artifact) get their own checks. Rule 2 applies to the map PNG
  (capture + critique — it is a human-facing visual).
- No mocks in persistence tests: real files, real save/load, real
  two-session sequences in the netplay lane.
- Placeholder text law stands (no lore; ZONE N / HUB 1 / BOSS 1).
- Every commit changes what the player sees or feels; balance numbers
  live in `data/**/*.json`.

## Evidence inputs (consume, don't re-derive)

- SIXTEENTH verdict + telemetry both seats:
  `drafts/_v17-fun-verify-skeleton-20260816.md`; session logs
  `tmp/netplay/owner_seat_session_20260817.log` (host) + Junior's in
  `drafts/_junior-sixteenth-shakedown-20260817.md`.
- Sustain pre-decision (2026-08-11) + healer-fairy kernel + hub re-crew
  notes: PARKING_LOT.md §"Owner design questions (2026-08-11)".
- D0 "banked session-only" decision being re-opened: PARKING_LOT.md
  §"Parked by the D0 spec" + inscription economy outcomes
  §"A2 brainstorm OUTCOMES" (economy vision = inscription within ritual).
- Systemic-worlds research shelf (persistence/economy/world-events
  notes, MMO-first corpus): `hub kb query --domain game-research`;
  workflow doc `docs/design-corpus/systemic-worlds-research-shelf.md`.
- Netplay substrate: `src/net/session.rb` (handshake pins, fingerprint
  law, drain machine), `src/net/state_digest.rb`, netplay gates under
  `harness/net/`.
- Launcher post-mortem (cmd parser law, goto-dispatch pattern):
  `drafts/_junior-sixteenth-shakedown-20260817.md` §Launcher post-mortem.

## Out of scope (PARKING_LOT.md carries every trigger)

Always-online server; in-game world editing + teleport; character
creation/appearance; item/equipment system; chat/channels; >2 players;
assets integration (gated on game-two-assets pipeline maturity);
rollback/resync; open-internet play.
