# Spark-up -- game-two ART LANE session: claim ONE ticket from the v22 art charter (AS first)

Single fresh session, one ticket, presentation-only. Charter = LAW for this lane:
`drafts/_v22-art-lane-charter-20260905.md` (read WHOLE; its §0 words are in force, its
§1 is the law of the lane, its §3 is the ticket list). Cycle law:
`drafts/_v22-foundation-20260905.md` (L12, L17, L20, §RATIFICATION s133 (3)/(3b)).
Spec pointer: `docs/superpowers/specs/2026-09-05-v22-one-body-cycle.md` §6.

## 0. Orient (10 min)
`fleet` (the game-two seat must be FREE or yours) -> `git pull` -> `git status` -> read
`docs/CYCLE.md` + the CHECKPOINT top entry -> read the charter WHOLE -> pick the FIRST
UNCHECKED ticket whose preconditions are met (AS unless the record says it landed; A0 is
a gate on GUI sessions only, not on AS) -> push a CLAIMED line
(`CLAIMED: art <ticket id> <goal> -- <seat>, s<N>`) BEFORE the first edit.

## 1. Laws that bind (never soften)
- Presentation-only: no sim rule, no save key, no netplay message. Proof for AS: canary
  banks UNCHANGED + `digest_snapshot` byte-identical across scales on `world_loop` and
  `floor3_run`. If a stream moves, STOP and fix the leak before anything else.
- Rule 2: every visual change = scripted replay + capture + vision critique BEFORE it
  ships (`rake gate SCRIPT=harness/scripts/<name>.json`); a wall re-pin per landed batch
  (`harness/run_wall.sh v22-art-<batch>` DETACHED via powershell Start-Process, ~3.5 h;
  never under a bash timeout; no source edits while it runs); `rake pins` before/after.
- Data-driven: sizes/knobs in `data/display.json`, `data/art/manifest.json`, zone
  emissions (through the importer); zero pixel constants in code.
- The sealed visual bible (lore repo, read-only) is the art LAW; fiction stays out
  (kit ids, ZONE N, BOSS 1). Never write into `game-two-lore` or `game-two-assets` trees;
  read tool / `git -C` / seat mail only.
- Line caps (`window.rb` <= 300, `world.rb` <= 1800); LDtk laws (MAP_EDITING §4.1-4.5).
- Both peers judge scale/taste on RENDERED tours, never on argument; the owner's line
  decides; record every line verbatim in the ticket record.

## 2. Ticket AS -- SCALE (if it is the one claimed)
1. Verify the live numbers first (prose-number law): capture size from a fresh
   `rake capture SCRIPT=harness/scripts/world_loop.json` frame; `frame_w/h/anchor/cols`
   from `data/art/manifest.json`; `tile_size` per zone emission; `display.json` knobs.
2. Build the S1 and S2 candidates as SCRATCH display configs (env/CLI override or a
   `tmp/` config the renderer can load -- never edit the live data first). Keep S0.
3. Sim-invariance gate: canary + digest identity across S0/S1/S2 (charter §3 AS).
4. Legibility measurement: longest reach in tiles from `data/balance/*.json` vs the
   visible half-width per candidate; table in the record.
5. Render the tour at S1 and S2 (`harness/make_tour.sh`, detached, ~20 min each; GL fix
   from MEMORY if `Gosu.render` fails). Paired frames S0/S2 -> vision critique with the
   uiux rubric (accuracy vs presentation, separate).
6. Both peers watch; one line each, verbatim in `drafts/_v22-as-scale-record-<date>.md`.
   The owner's line decides. If no line lands this session: record the two tours' paths
   + md5s, leave the decision OPEN, do NOT land a scale.
7. On a decision: land it as data + manifest contract; `rake gate` on `world_loop`,
   `floor3_run`, `menu_tour`; full-wall re-pin detached (A4 #1); pins pasted; fresh-eyes
   review (headless scrubbed pi on the diff) BEFORE push.

## 3. Other tickets (A1 / AA / A2 / A3 / A5) -- follow the charter's own rows; each has
its inputs, gate, done and cost there. A ticket whose input (assets or uiux receipt)
has not arrived is NOT claimable -- record the wait as its condition and pick the next.

## 4. Close
Ticket record in `drafts/`, charter row ticked with evidence (md5s, gate verdicts, pins),
CHECKPOINT entry (es-CR line for Gabriel, pt-br line for Junior), CLAIMED -> none,
`git fetch` + rebase + push, tree clean except tmp/.
