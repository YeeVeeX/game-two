# Family contract sync — canonical block + routing (2026-08-19)

Owner ask (es, hub chat): harmonize AGENTS.md/CLAUDE.md across the
workspace family (audio, assets, lore, gamesmith) for congruence and
interconnection. Recon (read-only): audio/assets/gamesmith have
AGENTS.md but NO CLAUDE.md; lore has CLAUDE.md but NO AGENTS.md.

Route (seat-orchestration pattern): each sibling's OWN dev-of-record
applies the change in its tree — this seat only mails the canonical
block + per-repo ask + RECEIPT format. Mails are $0; headless spokes
only on owner go (free seats only).

## THE CANONICAL FAMILY BLOCK (apply VERBATIM; md5 of the block text
## between the BEGIN/END markers, LF line endings: see mails)

<!-- FAMILY-BLOCK BEGIN -->
## Workspace family (game-two program) — synced 2026-08-19

- **Peers:** Gabriel (owner-founder, es-CR) + Junior (co-creator,
  pt-br) co-direct the whole program with equal creative standing —
  design, code, audio/assets, ideas flow from BOTH; neither is the
  other's worker. Owner overrides are law and get RECORDED (one line)
  in the affected repo.
- **Hub-and-spoke:** the game-two dev chat is the HUB; work in this
  repo runs as bounded sessions under its own dev-of-record.
  Cross-repo asks travel by SEAT MAIL (`~/.pi/agent/mail/<repo>/`),
  digest-stamped (md5), answered with `RECEIPT:` lines. Deliveries
  INTO game-two obey game-two's intake rules (owner-approved +
  digest-grounded + docs-only banking).
- **Seat-lease law:** no session ever writes into a sibling workspace
  tree — read tool for reading, mail for asking, md5 as the
  byte-identity arbiter.
- **Sovereignty:** this block never overrides local law — this repo's
  own invariants win inside this repo.
- **Contract mirror:** AGENTS.md is ground truth; CLAUDE.md is a thin
  pointer to it so Claude sessions load the same contract (AGENTS.md
  wins on any disagreement).
<!-- FAMILY-BLOCK END -->

## Per-repo asks (mailed 2026-08-19)

| repo | ask |
|---|---|
| game-two-audio | append block to AGENTS.md + add thin CLAUDE.md pointer |
| game-two-assets | same |
| gamesmith | same (block placement THEIR choice — money rails untouched) |
| game-two-lore | INVERT to standard shape: create AGENTS.md as ground truth (preserving the standing orders + quarantines verbatim), demote CLAUDE.md to the thin pointer, add the block. Repo stays DORMANT (standing order) — this is contract hygiene only, zero program restart. |

## CLAUDE.md pointer template (offered in the mails)

    # CLAUDE.md — read AGENTS.md first
    **AGENTS.md is the single ground truth for this repo.** This file
    exists only so Claude sessions load the same contract as every
    other agent; if they ever disagree, AGENTS.md wins. Start of every
    session: (1) read AGENTS.md fully; (2) `git pull` before working
    and before every push.

## Receipts (harvested 2026-08-19, spokes family-audio/gamesmith/lore + assets by mail)

- [x] game-two-audio: `RECEIPT: family-block applied md5=e047569834a75e4073834ebf9705d715 repo=game-two-audio commit=d3bd03121bbd0cddcc7faea99deb5186f4a77d18 claude_md=created | drift=none`
- [x] game-two-assets: `RECEIPT: family-block applied md5=e047569834a75e4073834ebf9705d715 repo=game-two-assets commit=258a62a claude_md=created | drift=none` (arrived by mail 2026-08-19 ~22:1x, consumed session 20; md5 == canonical; their note: a sibling session's uncommitted AGENTS.md pointer line excluded via staged-blob surgery, pushed AGENTS.md = HEAD + family block only, pre-push gauntlet green — 4/4 family sync COMPLETE)
- [x] gamesmith: `RECEIPT: family-block applied md5=e047569834a75e4073834ebf9705d715 repo=gamesmith commit=e13de13 claude_md=created | drift=none`
- [x] game-two-lore: `RECEIPT: family-block applied md5=e047569834a75e4073834ebf9705d715 repo=game-two-lore commit=bd45462 claude_md=demoted-to-pointer | drift=none`

Spot-check (hub, read-only): audio + lore applied blocks re-extracted and
md5-verified == canonical. Spokes: 3/3 one-pass, drift=none, budgets held
(docs-only, $0).

## Adjacent assessment — portfolio-spine (2026-08-19, owner ask)

Scanned read-only: bootstrap NOT needed (model-shape AGENTS.md + CLAUDE.md
already a pointer — it pioneered the pattern we rolled out today); the
game-two family block does NOT apply (personal multi-project infrastructure,
sovereign contract). Leverage route = register the family's DOC surfaces as
sync sources through ITS own human-confirmed loop (AI-proposes law: preview
uploads nothing, only the owner's approve moves bytes). Owner card staged:
`drafts/_portfolio-spine-onboarding-20260819.md` (commands + include_globs;
lore excluded while dormant; Junior-as-reports-reader = owner call).
