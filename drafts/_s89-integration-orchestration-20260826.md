# s89 — sibling-integration orchestration (routing of record, 2026-08-26)

Owner approval: Gabriel, s89 hub chat, verbatim "Approved, proceed as you
consider optimal for best results" — direction delegated to the hub dev of
record for this pass. Freeze context: the EIGHTEENTH's hygiene is ARMED —
every route below is docs/spec-side only; NOTHING ships into game-two
surfaces before the verdict. This doc is the routing table the
seat-orchestration skill requires ON DISK before launch.

## Budget (Rule 7)

3 spokes × ONE pass each (uiux, audio, assets) · stop condition = each
spark's DoD (process exit + RECEIPT lines) · ≤1 relaunch per spoke, only on
clear infrastructure failure (prompt-not-found class), never on quality ·
1 `hub kb query` (spent, seed evidence for the Junior lane) · council 0 ·
gate critic 0 on game-two surfaces (uiux runs its OWN UI-GATE in its own
repo under its own law).

## Routes

| # | seat | channel | ask | input digests (md5) | DoD |
|---|------|---------|-----|---------------------|-----|
| 1 | game-two-uiux (FREE, 8h idle) | commission MAIL + headless spoke | (a) answer pending family-block mail; (b) Candidate-5 HUD reposition+shrink spec (their Spark menu: Spec draft + mocks + UI-GATE) | family-block mail `c2c23e7fc5ea4a31b8fb9c21a5be3af6` · commission mail md5 pinned inside the spark prompt · game-two slate blob @6aea1d0 `ea6af67eb524cfd98e8137ff3e094a54` · their vitals.md blob `a81be68a611bc6d1464c65f0cb903b06` · their z-order.md blob `d9932d965a2df94699d46459a45e5525` | spec of record in their docs/specs/ + handoff bank + RECEIPT mail to game-two inbox |
| 2 | game-two-audio (lease DEAD-stale at launch; takeover is the lease system's own designed behavior) | headless spoke — relaunched with PI_* env scrub (launch.sh path hit the env-poisoning trap; pid 16539) | answer pending family-block mail per its own receipt instructions; NOTHING else (T3 renders stay owner-paced — not in scope) | family-block mail `0d8992231b8b8809fa3aca24f64a630e` | RECEIPT mail to game-two inbox |
| 3 | game-two-assets — **HELD ALIVE at launch time (pid 11252, heartbeat 00:08) — NOT launched, policy: coordinate, never route around** | mails already sit in their inbox; spark stays staged at `C:/tmp/sparkups-stage/s89-assets.md` for if/when the seat frees (owner surfaced) | answer BOTH pending mails (family-block + E3a-T2 track delivery) per their own instructions; nothing else | family-block `35cacc91b322742483ce85a922155bd9` · t2-delivery `98fb30332c8a84023eb0251de7f5757b` | RECEIPT mail(s) to game-two inbox |
| — | game-two-lore | mail only — seat HELD (live lease at s89, fleet) | family-block receipt | already in their inbox | receipt lands whenever their session processes it; never launch into a held seat |

## Junior parallel lane (same pass, human seat — not a spoke)

Owner ask (s89): Junior wants assigned parallel work. Lane doc:
`drafts/_junior-parallel-lane-20260826.md` (tickets J-T1 dossier /
J-T2 blueprint / J-T3 next-up; freeze fences inside). Dispatched to
Junior as a pt-br agent prompt via the owner (clipboard). His tickets are
drafts-only — zero collision with the spokes (different repos) and zero
freeze surface.

## Harvest plan

- Monitor by heartbeat (`fleet`), never log size (`pi -p` buffers; 0 bytes
  = RUNNING). Logs: `/tmp/sibling-s89-<tag>.log`.
- On each exit: read log tail → verify RECEIPT paths exist → md5 mailed
  claims at THEIR blobs (`git -C <repo> show HEAD:<path> | md5sum`) →
  record receipt line HERE (append below) → game-two banking stays
  docs-only under the freeze.
- Failed/missing receipt → owner with the log quoted; never silent re-run.

## Smiths ruling (owner asked s89: "should those be managed by assets?")

- **imagesmith / gamesmith = cross-program TOOL seats, not game-two family**
  — imagesmith's inbox at s89 is entirely lore-program traffic (visual-bible
  chain, quarantined from this repo); uiux's charter names both as ITS
  critique partners. Each program mails them DIRECTLY (flat hub-and-spoke;
  no middle-manager hop through assets — bottleneck + failure mode).
- **assets' custody is ARTIFACTS, not seats**: any image/art artifact
  DESTINED FOR game-two enters only through assets' intake/QA gate (the
  parked "assets integration gated on pipeline maturity" law). Hub routes
  asks; assets gates game-two-bound deliverables; smiths serve by mail.
- **worldsmith: ZERO speculation** — standing owner order (AGENTS.md
  owner-pending list): the owner-authored proposal is INCOMING; no mail
  dir, no routes, no definitions until it lands. Recorded, not routed.
- No game-two routes owed to any smith at s89.

## Receipts (append at harvest)

- 2026-08-26 route #1a — uiux family-block receipt LANDED + VERIFIED:
  their commit `393e1b7` pushed; family block at their HEAD blob
  `993fb261a58066039285275be1047253` = ours (canonical sync, byte-exact);
  CLAUDE.md bare pointer `e7ffe48362bb9590a10aa47958dd5818` = claim. Their
  drift note RECORDED: the family-block Service-seats bullet's charter pin
  (`6ddeb630…`) reads as "charter as ratified 2026-08-24", not a live
  byte-identity check — queue that wording clarification for the NEXT
  family-block resync (no violation). Mail archived to done/.
- Route #1b (Candidate-5 spec commission): spoke alive, running.
- Route #2 (audio): relaunched pid 16539 (env-scrubbed), running.
- Route #3 (assets): waiting on seat — mails in place.
- 2026-08-26 route #2 — audio family-block receipt LANDED + VERIFIED:
  their commit `2dddf5c` pushed (master); family block at their HEAD blob
  `993fb261a58066039285275be1047253` = canonical (byte-exact); CLAUDE.md
  bare pointer `e7ffe48362bb9590a10aa47958dd5818` = claim; suite green
  their side (98 runs); T3 cue-spec fence respected (untouched, done/).
  Mail archived to done/. Route #2 CLOSED.

## agents-md-bootstrap ruling (owner asked s89)

Surveyed read-only: game-two + all four family seats + imagesmith +
gamesmith + worldsmith + bedrock-council ALL carry curated charters —
running a generator over curated law degrades it (slop injection); the
skill's own trigger is "projects that LACK AGENTS.md". Only true gap in
the workspace: `coop-harness` (dormant since 2026-07-27, superseded by
in-repo netplay `harness/net`) — bootstrap ON NEXT REAL TOUCH, not now
(no manufactured work). DECLINED everywhere; zero files generated.

## Worldsmith ruling (owner asked s89: a) v2 grill · b) intake · c) park)

NONE as offered — recorded ruling: (a) v2 grill DEFERRED with named
triggers (the eighteenth's verdict + game-two J-T1 dungeon dossier +
worldsmith's own T26 dossier all land first); (b) intake REFUSED under
the armed freeze (nothing wires into data/zones now; v1 cluster
vocabulary doesn't yet model the peers' dungeon/boss/city asks);
(c) park REFUSED (program ratified, healthy, $9.13 of $150).
ORDERED instead: **T26 — $0 maintenance-class v2 demand dossier** in
the worldsmith seat (reception analysis of live zone_8 "parece vazio"
+ gap table vs the hand-authored pilot four + demand→vocabulary map
from the owner's s89 content asks [spells · enemies · city hub ·
biomes · sub-areas · towers · cardinal-crossroads city topology +
city→dungeon→city spine (s89, banked in slate candidate 8)] + 2-4
pre-registered v2 hypotheses tagged
with confirming/killing inputs). Spark-up delivered via owner
clipboard (owner executes in that seat). AGENTS.md's stale "WorldSmith
proposal INCOMING — zero speculation" line corrected this commit (the
proposal landed weeks ago; v0+v1 shipped + ratified; this doc's own
§Smiths "zero speculation" line is superseded by this ruling).
Owner content asks banked: slate candidates 6-9 + method ruling
("one at a time with intensive testing/debugging") + E1 re-grade note.
