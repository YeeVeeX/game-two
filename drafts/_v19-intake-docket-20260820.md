# v19 intake docket — the brainstorm's agenda page (2026-08-20, session 25)

**LAW of this doc:** pointers + one-line summaries ONLY. Dev
recommendations appear ONLY where the source doc already records one. The
docket ADDS no new opinions, promotes nothing, and does NOT open v19 —
v19 opens at the owners' brainstorm, at their word. Every pointer below
was verified live this session.

| Candidate | Source (doc/commit) | Class | Status / named trigger |
|---|---|---|---|
| J-1 Tibia stationary facing (Ctrl+direction) | `drafts/_junior-v19-ideas-20260819.md` idea 1 | sim (input+protocol) | **Already SHIPPED v18-era** (`28017d8`, protocol v3 + wall script); Junior's later "segue desativado" = his seat pre-pull (mixed builds refuse NAMED). Row kept for intake completeness. |
| J-2 safe zones vs battle zones | ideas doc idea 2 (owner, 2026-08-19) | sim | BANKED; one pre-recorded design note in source. Brainstorm input. |
| J-3 CryoFall-style inventory/stats menu + asset style signal | ideas doc idea 3 (owner) | presentation | BANKED; attaches to the DECLARED asset-direction lane per source. |
| J-4 leveling/XP + skills/spells + level-gated world | ideas doc idea 4 (owner) + `38a3ddb` addendum (lobber extension) | sim | BANKED; source records it as "likely THE headline debate" of v19. |
| J-5 projection + style preview (3/4 vs isometric, grim-detail register) | ideas doc idea 5 (owner drops) | presentation | BANKED. |
| J-6 non-pausing client menu | ideas doc idea 6 (owner drop) | presentation/app | BANKED. |
| J-7 enemies WALK home instead of teleport on zone-leave | ideas doc idea 7 (owner) + verdict cross-ref | sim | BANKED; v18 verdict notes it interacts with routing row 3's respawn measure. |
| Junior solo finding A — ally-AI acquisition gating (allies charge when minion enters THEIR vision) | `drafts/_junior-solo-playtest-findings-20260820.md` ACHADO 1 + his same-night CORREÇÃO (verbatim, allies-as-purchasable-resource reading RESTORED) | sim (AI) | Seat reading marked as reading, not verdict; telemetry-corroborated. Ties verdict row 6. Design debate at brainstorm. |
| Junior solo finding B — no bank in deep zones (walk-back to deposit) | same doc, ACHADO 2 (zone-data verified read-only; `TELEMETRY quay` already measured it) | data (zone layout) / design | TWO legitimate interpretations recorded in source — the choice is design, not a bug fix. Brainstorm decides. |
| Debug/mod menu | `63d7b9d` (Junior proposal + full evaluation banked) | process/tooling | **Awaits Gabriel's validation** (his framing: idea is not law). Never nag. |
| Ping / item-pickup remap | audio-v12 batch record (checkpoint session 23: zone_ping row LEFT the table; ping file+fixture stay banked) | presentation (audio data) | PARKED WITH v19 explicitly. |
| Projectile-visual sync to throw audio (syncopated pairs) | `c835c67` (PARKING bank) | fork a: presentation-only · fork b: sim-class cadence | Source records the fork; "v19 brainstorm names the fork". |
| gamesmith R7 — T4 front events evidence | `drafts/_gamesmith-round7-intake-triage-20260820.md` | evidence (no class — banking) | Trigger: owner-opened world/front-event design debate asks for it. |
| gamesmith R7 — T6 replay-sweep method for a screen-event budget | same triage | evidence/method | Trigger: a named target-renderer surface needs a numeric event budget (its own replay captures produce the number). |
| gamesmith R7 — T7 register/diagnose/steer instrumentation taxonomy | same triage | evidence | Trigger: owners explicitly open an instrumentation/overlay decision. |
| gamesmith R7 — T8 extraction-wager map | same triage | evidence | Trigger: owner-opened death/economy/session-loop debate asks for the full map. |
| Assets v12 — capture-contract (input-log/bundle + state-track emitters, both game-side) | mail `~/.pi/agent/mail/game-two/done/from-game-two-assets-v12-replay-capture-design.md` (their `4c3bc35`; design md5 `0a87985625a069f574b391219cb5e8e3`) | process/harness | Queued-for-v19-intake by the assets seat; zero-overhead law adopted from S0-J2. |
| Assets v12 — turn-handling gating decision | same mail (gating-decision ask) | process | DEFERRED as v19-class at session 24; sequencing is the owners'. |
| Depth-aware duck (−12→−4 lift inside a stinger window) | `drafts/_audio-polish-grill-20260820.md` §6 + `drafts/_audio-polish-review-20260820.md` | library (game-two-audio) | RECORDED library increment — build ONLY on owner word; ear-check question 3 (¿la música vuelve a subir demasiado pronto?) routes to it if his answer is sí. |
| Stereo ambient stems + region-acoustics (dry cues + engine reverb) | `drafts/_m5a-verdict-20260818.md` deferred lanes + AGENTS M5a block | library (game-two-audio) | Queued on owner word. |
| Lag T4 — vsync release result | `drafts/_lag-t4-vsync-20260820.md` (`0a8af6c` env-gated, canary PASS, fresh-eyes PASS) | app/presentation (pacing) | SHIPPED behind `GAME_VSYNC_OFF`; decisive oracle = Junior's S0-J re-run, owner-paced (pt-br two-liner staged in ticket §4). |
| Lag — the 6.8% in-process draw tail | `drafts/_lag-t3-verdict-20260820.md` §4 | app/perf | SEPARATE later ticket ONLY if the owners still feel lag after the ceiling experiment — never both levers at once. |
| BOSS-1 dread iteration | PARKING_LOT.md ("OPEN-FOR-EXPOSURE, zero code owed") | design/exposure | Waits on a player reaching ZONE 5 organically; harvest varekka telemetry then. |
| R-A2 sustain measure (silent) | v18 verdict row 4 + T2 evidence README | measurement | OPEN — `sustain bought=0` on every banked HUMAN log through today (this session's T4 bot lines are excluded by law); harvest silently, never prime the owners. Row 4 records "discoverability first, price debate parked behind it". |
| v18 verdict row 3 — respawn friction → coop.json retune | `drafts/_v18-fun-verify-verdict-20260820.md` row 3 (TRIGGERED) | data | Pre-registered RECORDED outcome; retune is a v19-era debate (two knobs / one re-session note in verdict). |
| v18 verdict row 6 — AI suicides → embodiment/AI debate | same verdict, row 6 (TRIGGERED; Junior R3 verbatim) | sim (AI) | RECORDED debate item; overlaps Junior solo finding A. |
| v18 verdict row 9 — session 2 opens under-resourced | same verdict, row 9 (TRIGGERED) | sim (economy) | RECORDED debate item; verdict cross-references idea 7 + row 3 interaction. |

Rows 1/2/5/7/8 of the v18 verdict: NOT TRIGGERED (recorded, no docket row
owed). The world-builder pipeline is an ACTIVE owner-directed lane, not
v19 intake — its open merge-timing grill question stays in
`drafts/_world-builder-grill-20260819.md`.
