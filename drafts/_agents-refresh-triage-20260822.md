# AGENTS.md family refresh — routing/triage (hub doc, s38-extended, 2026-08-22)

**Owner order (Gabriel, hub chat, 2026-08-22):** "update, enhance, refine or
redesign our agents.md as you consider optimal, this one and the related
workspaces" — following his same-day order: development never gates on peer
availability; dev proactively surfaces real recorded work items.

**Canonical family block:** `drafts/_family-block-20260822.md` — md5
`57f52cbc786c325330234f29f54655bf` (computed `tr -d '\r' | md5sum`). Every
spoke verifies the digest before applying; mismatch = STOP + FAILED receipt.
Block is byte-identical across all five repos (heading → last bullet);
BEGIN/END HTML markers sit OUTSIDE the canonical unit (lore carries no
markers — its block-to-EOF md5 self-check law needs the block bare and last).

**Budget (Rule 7):** 3 spokes × ONE pass each; stop condition = per-spoke DoD
(commit + RECEIPT printed at exit); ≤1 relaunch per spoke, only on clear
infrastructure failure (prompt-not-found class), never on quality grounds.
Council 0; no paid critics.

## Routes

| repo | seat state (fleet 09:38Z) | route | DoD summary | receipt |
|---|---|---|---|---|
| game-two | this session (hub) | direct | redesign: closed-cycle narrative → pointers; family block added; caps → non-negotiable 1 | DONE `e9048b4` |
| game-two-audio | FREE | spoke `agents-sync-audio` | family block swap (+markers) · stale parked-header fix (order lifted 2026-08-18) · M3/M4/M4b closed narratives → pointer stanzas (pinned facts kept verbatim) · rake green · commit+push | PENDING |
| game-two-lore | FREE | spoke `agents-sync-lore` | family block swap (bare, stays LAST) · recompute + update its pinned block md5 (`e0475698…` → new) · register-hygiene grep stays clean · commit+push | PENDING |
| gamesmith | FREE | spoke `agents-sync-gamesmith` | family block swap (+markers) · inbox mail untouched (round7b ask waits for an attended session) · commit+push | PENDING |
| game-two-assets | **HELD** (lease 01a0286b, pid 8004, heartbeat fresh) | seat mail `from-game-two-family-block-sync-20260822.md` | holder applies block swap inside its existing FAMILY-BLOCK markers + refreshes stale "v17 open" boundary line to the standing parking-lot gate | PENDING (mail sent) |

## Scope guards (every spoke prompt carries these)

- Touch ONLY the files the DoD names. Do NOT read, process, archive, or answer
  seat mail — inbox items wait for attended sessions.
- `git pull --ff-only` first; explicit-path commits; pull again before push.
- Family-block digest verified before any edit; STOP on mismatch.
- At close print `RECEIPT: <absolute artifact paths + commit hash>`.

## Harvest log

- game-two-audio spoke: **RECEIPT** `AGENTS.md @ ecfa12f` — block md5 verified, header LIFTED-fix landed (line 6), keep-list grep-verified (3 pinned facts + headroom/limiter law + 17-boxes + roles pin + 3 pointers), rake 91 runs green, 14,987→13,002 bytes, mail untouched (t3-cue-spec still pending).
- game-two-lore spoke: **RECEIPT** `AGENTS.md @ d5d4174` — block bare+last, pinned self-check md5 updated to measured `57f52cbc…` (= canonical), register grep 7 hits clean, nothing else touched; spoke pulled Junior's disjoint drafts commit (`650495a`) first.
- gamesmith spoke: **RECEIPT** `AGENTS.md @ 23b9398` — block swapped inside new markers, round7b inbox ask untouched, hooks passed.
- game-two-assets: mail staged (`from-game-two-family-block-sync-20260822.md`) — receipt PENDING at the holder's convenience.
- Hub spot-check 2026-08-22: family-block md5 `57f52cbc786c325330234f29f54655bf` identical across game-two + all three spoke repos; mail-dir audit clean (no spoke touched mail).
