# Egypt mythology pipeline — COMPLETE (2026-08-09, ~18:0x)

**FINAL: bible committed `b027453`** (branch a0-m2.1-feel-repair, single-file commit,
17,894 words) after all 29 panel fixes applied + independently grep-verified (banned
names all 0; Slipwoven 5 / Kadvakh 1 / dral-w 2 / Royal Rolls 2). Goal MET and cleared.
This file is now historical; the live work is the terrain+progression corpora pipeline
(see knowledge/.scratch/*-sweep.md + INDEX.md changelog).

# Original harvest below (pre-compact)

Session: "knowledge". Everything below is measured, not recalled. This file is the recovery
map if the session compacts mid-pipeline.

## Deliverable chain (approach A, owner-approved)

1. DONE — corpus registered + committed (knowledge repo `5b3c206`): freshness.yaml, INDEX.md,
   catalog-overrides.yaml (trust tiers), catalog + raw FTS rebuilt, `kb.py doctor` clean.
2. DONE — adversarial capture review (owner-ordered, 3 agents). Verdicts BURNED INTO
   knowledge/sources/INDEX.md + freshness.yaml + catalog-overrides.yaml:
   - Anchors: 19 (full Assmann, abridged 2005 ed), 10 (complete thesis), 49 (Getty chapter).
   - NEVER-CITE: 44 (HNS review chrome, ZERO book text), 12 (body = unrelated Foroughi paper),
     38+50 (verbatim-duplicate essay mills), 32 (provenance-free AI synthesis).
   - 33 = FRAGMENT (Intro + Afterlife/Akh/Amulets/Amun/Anubis only; Aten entry cut mid-sentence).
   - 16 stubs; manifest itself clean (51/51).
3. DONE — 4 vault notes in game-research/ (egyptian-cosmology-theology-and-maat 4553w,
   egyptian-death-afterlife-and-the-book-of-the-dead 4610w,
   akhenaten-amarna-and-the-limits-of-religious-revolution 4532w,
   new-kingdom-power-temple-economy-and-empire 4181w). All grep-verified ZERO banned tags
   ([12]|[32]|[38]|[44]|[50]). Two were decontaminated post-hoc (agents re-grounded or cut
   every bad cite; fabrications caught: war-dog units, military scribal dept, 40-deben bride
   price misread, "whole city in a decade"). `hub kb reindex` done (+4 files, 91 chunks);
   retrieval smoke-tested.
4. ON DISK, UNGATED — world bible at workspace/game-two/docs/lore/world-bible.md:
   17,801 words, all 14 sections present (verified by grep of ## headers at 15:23).
   Incremental author agent was finishing its final message when this harvest was written.
   In flight when written — if its completion notification carries the deity-name list,
   harvest it; if dead, the file is still complete on disk.
5. IN PROGRESS (updated post-compact, ~16:30) — critic panel:
   - CRAFT: DONE, FAIL, report banked at drafts/_critic-craft.md. 4 blocking: Dekharu FLAT
     (fix drafted in report), Hezreth FLAT (fix drafted), Khelat->Khela doctrine rename,
     Gorvakk->Kadvakk rename. ~12 advisory.
   - ORIGINALITY: DONE, FAIL, report banked at drafts/_critic-originality.md. 2 blocking:
     "the Marrowless" -> "the Slipwoven" (4 sites incl. a §14.3 mystery line), "Amarna" in
     §6 design note -> reword. ALL 6 Tibia beats DIVERGENT. "husk-less" already gone (the
     author agent's condensation removed it; bible now 17,228w/619 lines, NOT 17,801 —
     author kept editing post-goalcomp until TaskStopped; ALL line numbers across reports
     are offset-suspect: revision agent must locate by grep/quote, never line number).
   - CONSISTENCY (split in half after 2 full-scope stalls):
     - Critic A: DONE, FAIL — 1 blocking (the §4.3/§14.3 "two cults (§10)" endgame ref
       resolves to no actual §10 cult) + 15 advisory. Banked:
       drafts/_critic-consistency-a.md. Parked systems: 5/5 core COVERED (skill-through-
       use weakest, passes via §13 inference); monster-respawn WEAK, player-influx
       MISSING (both advisory, both get one §13 row). 18 load-bearing entities verified,
       date math checked 3x clean.
     - Critic B (timeline/contradictions): STILL RUNNING at 16:23; scratch file
       drafts/_critic-consistency-b.md has the full timeline extraction (coheres: 286yr
       ✓, Vakhur ~3000yr ✓ loose) but Checks 2-3 still TBD; last write 15:57. If it
       stalls, partial coverage noted in the revision brief's PENDING INPUT section.
   - CODEX CROSS-VENDOR REVIEW: DONE (GPT-5.6 Sol). Adjudicated verdicts banked:
     drafts/_codex-review-adjudicated.md. NEW blockers accepted: root `ren` is the real
     Egyptian soul-word in the §2.2 root table (rename -> `dral`, 2 sites); "the
     Marrowless" literal replace would miss 2/4 sites (use bare-token replace);
     Kadvakk violates §2 derivation (use Kadvakh); Khelat->Khela rename CANCELLED
     (canonize the pun instead); both god-interior drafts corrected to avoid resolving
     locked canon. Overruled: Slipwoven-not-Vessic (fix = legalize epithet register),
     Savra rename (derivation exists via Sildra pattern). Confirmed clean cross-vendor:
     banned-name inventory, Ossel/Suvan, 5/6 beats DIVERGENT.
   - PRE-REVISION SNAPSHOT taken (Codex process blocker):
     drafts/_world-bible-pre-revision.md, sha256 e07f9dce..., byte-identical at 16:1x.
   - ⚠ COMMIT HYGIENE (Codex, verified live): the parallel M2 session is ACTIVELY
     editing the repo (M PARKING_LOT.md, M src/game/world.rb appeared between my checks).
     Final commit: `git add docs/lore/world-bible.md` ONLY, verify
     `git diff --cached --name-only` = exactly that path. Never -A/-u.
   THEN one revision agent executes drafts/_revision-brief.md (the consolidated
   execution list: 8 blocking B1-B8, 14 advisory A1-A14, do-not-do list, verification
   greps with expected counts). Locate by quote, one Edit per fix, incremental.
6. NOT RUN — final wrap: grep bible for banned names = zero; commit game-two docs/lore/
   (tree otherwise clean — parallel session committed its harness files in fa8e389);
   report. Memory (hub-kb note + MEMORY.md) already updated with 215/5195 baseline.

## Critic panel prompts — reconstruct from these invariants

- Originality: no Tibia nouns (Fardos/Zathroth/Tibiasula/Banor/...), no real Egyptian god
  names or trivial respellings, no Kethral names (Solthrekan/Threketh/husk/Vonash/Marrow),
  no D&D/Warhammer/ES/WoW collisions; too-close plot beats = blocking (esp. Tibia's
  murdered-harmony-goddess -> elements beat; bible's divine murder must diverge in motive/
  consequence/result). Reference: game-research/tibia-mechanics-lore-and-virtual-world.md
  section 3 (CORRECTED 2026-08-09: orcs/cyclopes were Brog's hordes, not defenders).
- Consistency: every parked system (corpse-run, respawn, skill-through-use, factions,
  bestiary, hub-and-spoke zones) needs an in-fiction explanation; timeline math; naming-
  language self-compliance; dangling references.
- Craft: mythic prose numinous not wiki; pantheon has wants/wounds/grudges; Heresy Age =
  best story in the book; confusable names; lists wearing prose costumes.

## Known hazards (cost hours already — do not re-derive)

- Workflow tool died on stream-stalls (6 attempts x 4 pipelines); Agent-tool fan-out is the
  working fallback (ladder rule). Single-shot 10k+-word compositions stall the watchdog:
  the WORKING recipe is write-incrementally (Write section 1, then one Edit per section).
- 7 miner digests preserved at knowledge/.scratch/egypt-digests/*.md (magic, amarna,
  assmann-1, assmann-2, state, botd, theology) — future note work reuses these, never re-mines.
- game-two PARKING_LOT.md already carries the world-mythology entry (docs-only rule).
- game-two has UNCOMMITTED files from a prior session (docs/design-increment-a.html,
  harness/critic_reel.json, video_analyst.py, vision_critic.py) — NOT mine; commit bible
  separately or leave them be.

## Owner queue

- Playtest fun-verify of grid slice still the gate for ANY lore touching code.
- Optional: re-capture Tutankhamun's Armies (real book) to restore military depth in the
  new-kingdom-power note (inline drop-notice marks the spot).
