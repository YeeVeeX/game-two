# Codex cross-vendor review — adjudicated (2026-08-09)

Codex (GPT-5.6 Sol pinned, self-reports "GPT-5 Codex" per never-trust-self-report) reviewed
the bible + both banked critic reports. Verdicts below re-verified by me against the file.
This file = the delta the revision agent must apply ON TOP of the three critic reports.

## ACCEPTED — new blocking findings (Codex was right)

1. **Root `ren` must be renamed (2 sites: §2.2 root table ~L53, §14.1.3 ~L583).**
   `ren` is the verbatim real Egyptian term for the name-component of the soul — in a book
   whose OWN rule §14.1.5 prohibits real mythological names incl. soundalikes, and where the
   name-strand concept exists (nakh). If one design-note "Amarna" counts as blocking, a real
   Egyptian soul-word sitting in the canonical root table counts. Fix: rename the reserved
   root to a clean Vessic-legal syllable — proposal **`dral`** (dr- is a permitted onset,
   no collision: grep first). Keep the mystery mechanics identical ("forbidden root;
   reserved, unglossed, against a future need").
2. **"the Marrowless" locator trap.** Literal replace of "the Marrowless" hits only 2 of 4
   sites (L410 "Marrowless country", L414 "Marrowless brotherhoods" lack the article).
   Fix: replace_all on the bare token `Marrowless` -> `Slipwoven` (4 sites), then grep
   `Marrow` = 0.
3. **"Kadvakk" violates §2 derivation** (kad + vakh does not yield -vakk; no sandhi rule).
   Fix: use **`Kadvakh`** instead ("war-shout" — clean derivation, perfect for a
   drill-sergeant boss; kh-final is attested in canon by the strand-name `nakh` and
   `nakh-tekh`). Grep Kadvakh = 0 collisions first. (Note Gorvakk itself was underivable —
   the rename fixes two rule violations at once.)
4. **Commit hygiene is now load-bearing: THE PARALLEL M2 SESSION IS ACTIVELY EDITING THE
   REPO.** My 16:0x status showed the tree clean except ?? docs/lore/; Codex's later status
   shows `M PARKING_LOT.md` + `M src/game/world.rb` — another session's live edits.
   The final commit must stage EXACTLY `docs/lore/world-bible.md`
   (`git add docs/lore/world-bible.md` then verify `git diff --cached --name-only` = that
   one path) — never `git add -A`/`-u`.
5. **No pre-revision baseline exists** (bible is untracked -> revision delta is un-diffable).
   Fix: copy the file to `drafts/_world-bible-pre-revision.md` BEFORE the revision agent
   touches it; after revision, diff the two and eyeball the semantic delta before commit.

## MODIFIED — plan changes Codex forced

6. **Khelat -> Khela rename is CANCELLED.** Codex found three problems: (a) "Khela" keeps
   the stressed khel- so the spoken collision with `khelet` only shrinks; (b) the -a affix
   means "source/wellspring" so the doctrine's gloss changes from "the lone ember" (which
   is load-bearing: Khelat is the §2.3 affix-table EXAMPLE for -et/-at, L65) to
   "ember-source"; (c) possible existing-game name collision on "Khela" (unverified, but
   with (a)+(b) it tips). REPLACEMENT FIX = the craft critic's zero-rename alternative,
   upgraded: canonize the pun. The khelet (your soul's ember-strand) and the Khelat (the
   sky's lone ember) share the khel root — one sentence in §6.6: the King's preachers
   LEANED on the near-homophony ("the fire in you and the fire above are one word"), which
   gives the heresy its recruitment pitch and turns the collision into rhetoric. Plus a
   style rule in §14.1: player-facing spoken lines prefer the epithet "the Lone-Ember
   creed" over "the Khelat" where a khelet is in scope.
7. **Hezreth interior must be phrased "never addressed ALONE".** Codex caught that flat
   "can never be addressed" contradicts L202 (Hezreth'Savra "invoked as one being") and his
   existing cult (L180). Fix framing: a prayer said to Hezreth BY HIMSELF arrives as a
   prayer to no one; only inside the compound does he exist in a mouth — which is exactly
   why he permits a knot both cults resent. Revision agent must read the cult's rites text
   and keep it consistent (wordless rites are fine).
8. **Dekharu interior must not adjudicate the Weighing.** Codex caught that calling
   gag-clauses "lawful cheating" implies the court measures the LIFE (resolving §14.2's
   permanently locked ambiguity, L596). Fix framing: his wound stays "does not know what
   his own instrument measures"; his grudge becomes that mortals play his instrument as a
   game while he cannot even rule whether playing it is against the rules — because he does
   not know what the rules measure. No word may imply either reading is correct.

## REJECTED — Codex findings I overrule (with reasons)

9. **"Slipwoven is not Vessic-derived, violates §14.1.1"** — over-strict. Canon practice
   already uses English translated epithets as race/faction names throughout (the
   Unfinished, the Molded, the Frayed, Silt Mothers, Free Reeds, Markfolk, Nine-Pines...).
   §14.1.1 as written conflicts with half the book, not just Slipwoven. Fix is to LEGALIZE
   existing practice: add one clause to §14.1.1 — common-register translated epithets are
   canon-legal; Vessic is required for true proper nouns (gods, cities, persons, doctrines).
   "SlipWoven the song title" is not a name-protection concern. The Vessic alternative
   "Veshai" is REJECTED because it would be the 7th ves- proper noun (craft critic's
   cluster warning).
10. **"Savra fails full-derivation + Ra echo"** — partially over-strict. The §2.3 -a affix
    example is *Sildra* (sil + intrusive liquid + a), so Savra (sav + r + a) follows the
    exact canonical example pattern; the derivation exists. The -ra echo stays ADVISORY
    (originality critic concurs). Cheap hardening while we're in §2.3 anyway: one clause
    documenting the intrusive liquid before -a (covers Sildra, Savra, Zolvah). No rename.

## CONFIRMED CLEAN by Codex (cross-vendor corroboration)

- Banned-name inventory complete: Marrow=4, husk=0, Amarna=1, all other 45 terms 0 hits
  at word boundaries (eaten/stratum/crisis false positives excluded).
- Ossel/Osiris (distance 4) and Suvan/Suon cleared as non-transparent.
- Beat divergence: 5 of 6 beats independently ruled DIVERGENT with quotes. 6th
  (player-arrival) ruled UNCERTAIN — the bible may lack an explicit player-arrival premise
  entirely (searches for portal/other-world = 0). NOT a Tibia-proximity problem (opposite:
  maximal distance), but feeds consistency critic A's parked-system #8 check — if A also
  finds it weak/missing, revision adds one in-fiction sentence (souls seep up from the
  Unsaid; shrine-binding = registration) WITHOUT any other-world conceit.
