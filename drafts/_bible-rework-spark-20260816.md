# SPARK: Bible rework from scratch (owner-commissioned 2026-08-16)

You are the dev of record in game-two (read AGENTS.md first — it is ground
truth). This session's mandate, in the owner's words: **"lets re-work the
bible from scratch, lore sounds dumb as it is right now."** The current
bible is `docs/lore/world-bible.md`. This is a LORE session, not a code
session: do not touch src/, data/balance, or the harness except where this
brief says so.

## What triggered this (evidence, not vibes)

- The fourteenth verdict: ES names read false in situ, twice running; root
  cause named as translationese authorship (verdict:
  `drafts/_v15p5-fun-verify-20260815.md`).
- 2026-08-16 language lane: the owner picked the notarial register blind
  (QUEDA ANULADA LA MARCA over plain/generic — he LIKES the court's
  voice; QUEDA PAGADO EL PASO/EL PLAZO are "the set's crown" per
  `drafts/_es-language-critique-2026-08-15.md`). Then he rejected EVERY
  candidate for the two failed lines across TWO noun families: first
  carne ("LA CARNE sounds totally dumb... a hole we have been carrying
  since the conception of this project"), then the vessel/clay family
  (vasija/barro/cuerpo — "all sound dumb"). Then: rework the bible.
- Standing order executed already: wipe.line + challenger.called.line are
  REMOVED from all locales (commit "lore(owner order)"); those beats play
  textless until the new bible speaks. Do not re-add text to them without
  owner ratification.

## The method (do NOT skip phase 0)

**Phase 0 — taste extraction, ~10 min of owner time, FIRST.** "Sounds
dumb" is a symptom. Do not write one word of new lore before diagnosing
what reads dumb TO HIM. Show him 6-10 short REAL excerpts spanning the
current bible's registers (pantheon prose, Vessic names, court formulas,
zone names, the flesh/vessel body-language, the Egyptian frame) plus 2-3
in-game lines, one at a time, and ask for a gut verdict each (dumb / fine
/ good, one optional word why). Include the KNOWN-liked items (QUEDA
stamps, VAREKKA, ithet/goret/hevet?) as controls. Map the pattern before
proposing anything. Hypotheses to test, not assume: (a) the body-horror
noun family is the problem, not the court register; (b) the
Egyptian-fantasy skin is the problem; (c) EN-first authorship is the
problem and ES should be co-primary (owner and Junior both PLAY in
es/pt-br); (d) the density/portentousness of the prose is the problem.

**Phase 1 — frame pitches.** From the phase-0 map, 2-3 sharply DIFFERENT
one-page bible directions. Each pitch: the world in five sentences, the
court's voice (2 sample stamps), the death/respawn liturgy (what replaces
the removed wipe line, or whether silence stays), what the pack IS, five
zone names — ES and EN both, ES composed natively (never translated).
Owner picks one, on rendered captures for any in-game line (the probe
pattern from 2026-08-16 works: render candidates in situ, blind labels).

**Phase 2 — rewrite** the bible from the picked frame. Method precedent:
the de-slop laws in AGENTS.md + the craft harvest in
`drafts/_bible-enrichment-2026-08-15.md` (withholding over asserting,
found-language, sensory anchors; kill "which is why"/"not X but Y" tics).
Keep it SHORTER than the current bible. Every name passes the slop test
(could it ship in another game unchanged? then it dies).

**Phase 3 — the rename batch, ONE comparability reset.** The new bible
renames player-visible surfaces (zones, challenger, stamps, kit names as
decided) → strings en/es/pt-br (pipeline law: owner ratifies ES on
captures; Junior post-edits PT-BR from briefs — the dev NEVER composes
es/pt alone), check-prose amendments (checks quote lines: #51, seizure_reads,
low_quay_reads, new_ground_reads), then the FULL wall re-gate + critic
recalibration (Nest-rename law). COMPARABILITY DEBT ALREADY OWED and
riding this same reset: the 2026-08-16 text removal changed pixels in
varekka_duel / burn_duel / corpse_run / nest_advance / vat_economy reels.
The FIFTEENTH fun-verify waits for this batch (one re-ask, not two) —
its protocol is pre-registered in
`docs/superpowers/specs/2026-08-15-v16-presentation-identity-design.md`.

## Guardrails

- Owner is the taste authority; you are the craftsman. Debate, then defer.
- Budget: phase 0 + phase 1 fit in ONE session with the owner present;
  stop after the pitch pick — the rewrite is its own session. If the
  owner is absent mid-phase, checkpoint to drafts and stop.
- Working language English; ES surfaces composed natively by the LLM and
  ratified by the owner ON CAPTURES; PT-BR goes to Junior via brief
  (precedent: `drafts/_mark-void-ptbr-brief-20260816.md`).
- Log the whole arc in drafts/ (tracked); AGENTS.md scope contract gets
  rewritten only at the v17 debate, but note this session in
  docs/CHECKPOINT.md at close.
- git: never push main; junior-tibia is shared — pull before push; Junior's
  seat is active and pushes too.
