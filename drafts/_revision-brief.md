# Revision brief — world-bible.md (2026-08-09)

Consolidated from 4 critic reports + Codex cross-vendor review. This is the EXECUTION LIST;
rationale lives in drafts/_critic-{craft,originality,consistency-a}.md and
drafts/_codex-review-adjudicated.md. Pre-revision snapshot (do not touch):
drafts/_world-bible-pre-revision.md.

RULES FOR THE REVISION AGENT:
- Locate every edit by QUOTED TEXT (grep first), never by line number — the file drifted
  under every critic.
- Edit incrementally: one Edit call per fix. Never batch composition.
- Nothing here changes canon SUBSTANCE except where explicitly stated. §14.2 immutables and
  §14.3 locked mysteries are radioactive: no fix may resolve or lean on any of them.
- §6.6 and §12.5 are one story (the Lantern King arc) — if you touch one, re-read the other.

## PART 1 — BLOCKING (must all land)

B1. RENAME: bare token `Marrowless` -> `Slipwoven` at ALL 4 sites (§7.3 definition, §9.5
    "Marrowless country", §9.6 "Marrowless brotherhoods", §14.3 mystery line). Two sites
    LACK the article "the" — replace the bare token. Then verify: grep -c 'Marrow' = 0.

B2. REWORD: the one "Amarna" (§6 design note, "the Amarna-transmutation") -> "the
    heretic-king-age transmutation". Verify grep Amarna = 0.

B3. RENAME: root `ren` -> `dral` at both sites (§2.2 root table row "ren — forbidden root;
    see canon rules"; §14.1.3 "The root `ren` is forbidden"). Mechanics identical
    (reserved, unglossed, endgame lock). Verify grep -w ren = 0 (watch false positives:
    only the root-word sites change; there are no others — pre-verified).

B4. RENAME: `Gorvakk` -> `Kadvakh` (1 site, §8 family 2). kad "war" + vakh "shout" — clean
    §2.2 derivation. Verify grep Gorvakk = 0.

B5. CANCELLED-RENAME REPLACEMENT (Khelat stays Khelat): canonize the khelet/Khelat
    near-homophony instead. In §6.6, at the passage describing the Khelat doctrine's
    spread, add ONE sentence: the King's preachers leaned on the near-homophony — the fire
    in you (khelet) and the fire above (Khelat) are one word, said the sermons — which is
    why the creed outran argument. In §14.1 naming rules, add a style clause: in
    player-facing SPOKEN lines, prefer "the Lone-Ember creed" for the doctrine where a
    khelet (soul-strand) is in scope, to keep the pun on the page and out of the ear.

B6. DEKHARU INTERIOR (§4.1 entry): add 2-3 sentences. His wound: he does not know what his
    own instrument measures — the life or the preparation — and is the only being who
    cannot shrug at the question; the god of exactness cannot calibrate himself. His
    grudge: mortals treat his Level as a game to be played (passage-scrolls, purchased
    blessings, gag-clauses) and he cannot even rule whether playing it is cheating,
    because he does not know what the rules measure. His want: one weighing, just one,
    that balances with nothing purchased on either pan — he has never seen it happen.
    ⚠ CONSTRAINT: no word may imply the court measures the life OR the preparation —
    §14.2's Weighing ambiguity is permanently locked. Do not use the phrase "lawful
    cheating" as a settled ruling.

B7. HEZRETH INTERIOR (§4.1 entry + one echo at the Hezreth'Savra passage): add 1-2
    sentences. His wound: the only god never spoken can never be addressed ALONE — a
    prayer said to Hezreth by himself arrives as a prayer to no one; the confessor of the
    world has never once been heard in his own name. His want: the compound
    Hezreth'Savra is the closest he has come to existing in a mouth — the veiled god's
    single vanity, and the reason he permits a knot both cults resent.
    ⚠ CONSTRAINT: must not contradict the existing "invoked as one being" compound line or
    his cult's existence (wordless rites are consistent; being addressed-alone-in-words is
    the thing he lacks).

B8. DANGLING ENDGAME REF (consistency-A blocking): §4.3 Ovet entry says re-opening death's
    door is "the explicit dream of at least two cults (§10)" and §14.3 echoes "the cults
    that dream of re-opening death's door", but NO §10 cult holds that dream. Fix in
    §10.3 with one clause each on two existing groups (do NOT invent a new faction
    wholesale): (a) give the rim-cults' inner circle the door-dream reading (dissolution
    into the Unsaid is easier if the door is open), and (b) add a named heterodox lodge
    inside an existing institution — e.g. a Free Reeds mystery-lodge keeping Ovet's
    open-door rites (the culture hook already exists in §7.1/§9.4) — that the Vaultwardens
    watch. Keep both to one sentence each; the mystery (§14.3: they never get a yes or no)
    must stay open.

B9. NIGHT-HOUR ARITHMETIC (consistency-B B1): three claims cannot all hold — (i) twelve
    night-hours map 1:1 to the twelve chambers (§5.1), (ii) the Ember touches Ulveth's
    heart at MIDNIGHT in the DEEPEST chamber (§3.3, §5.1), (iii) the ascent completes by
    dawn. If 1:1 holds, chamber 12 lands at hour 12, adjacent to dawn — not midnight.
    RECOMMENDED FIX (keeps all downstream users intact — "Kammat of the Ninth Hour" §12.6
    and §13's night-hour keying both survive): make the twelve hours count the DESCENT
    only, and redefine midnight liturgically, not arithmetically — in Suvareth, "midnight"
    is the name of the twelfth hour, the hour of the touching, however long the dark has
    run; the ascent is counted in no hours at all, because dawn is not a schedule but a
    victory (this is why no two dawns fall alike). Implement as: §5.1 one-clause amendment
    at the hour↔chamber sentence + adjust "Midnight, when..." to "Midnight — the twelfth
    hour, the hour of the touching —"; §3.3 same adjustment where "at midnight, in the
    deepest chamber" occurs. ALSO fix §3.3's route ordering (outer dark is listed AFTER
    the twelve chambers yet crossed BEFORE the deepest): reorder the itinerary to western
    stair -> outer dark (where Ithves strikes) -> the twelve chambers -> the touching ->
    eastern stair. Reconciles consistency-B advisory A3 (Ithves harries from the outer
    dark into the middle chambers — §9.7 stays valid).

B10. KINGDOMS SPAN (consistency-B B2): §6.5 header says AS 600-2890 (= 2,290 years) but
    body says "Two thousand years of mortal history proper". Fix the body: "Twenty-three
    centuries of mortal history proper". Do not move the boundaries (other dates depend).

B11. NAKHORO'S CREATURES FIELD (consistency-B B3): §4.1 Nakhoro "Creatures: none living"
    contradicts the fae/Unfinished being his living discarded phrasings (§3.1, §6.1, §8
    family 3). Fix the field: "none he acknowledges — the fae are his discarded drafts,
    alive and unclaimed (§7-8); every written ward, rune, and golem-word traces to him."

B12. ERASURE-GOLEM COUNTERMAND (consistency-B B4): §9.5 "orders no one can countermand —
    their countermand was written in the Rolls the King sequestered" contradicts §12.1
    where Dravessa countermanded golems at the gates by reading exactly those clauses.
    Fix §9.5 scope: "orders no one living has the clauses to countermand — Dravessa's
    reading covered only the gate-cohort; the clauses for the rest lie sequestered in the
    deep archive, and recovering them is a canonical epic." (Strengthens the quest hook;
    §12.1 untouched.)

## PART 2 — HIGH-VALUE ADVISORY (apply all; they are cheap and load-bearing)

A1. §14.1.1 REGISTER CLAUSE (legalizes existing practice, unblocks B1): amend rule 1 to
    state that common-register translated epithets (the Unfinished, the Molded, the
    Frayed, the Slipwoven, Silt Mothers, Free Reeds...) are canon-legal for peoples,
    orders, and creatures; Vessic derivation is required for true proper nouns (gods,
    cities, persons, doctrines, artifacts). Also fold in consistency-A finding 6: the rule
    should read "derives from §2.2 roots OR matches a §2.4 culture pattern OR is a
    common-register epithet".

A2. §2.3 INTRUSIVE-LIQUID CLAUSE: one sentence documenting the euphonic liquid before -a
    (sil-d-ra -> Sildra, sav-r-a -> Savra, zol-v-ah -> Zolvah). Hardens Savra against the
    -ra-echo reading via explicit derivation.

A3. §2.1 WORD-FINAL -h FIX (consistency-A finding 1): "Words never end in h or a cluster"
    contradicts Zolvah and standalone vakh. Amend: kh and the -ah of the source-affix are
    single sounds (digraphs), not h-finals; the ban is on bare h.

A4. UNGLOSSED ROOTS (consistency-A findings 2-5): add to §2.2: `hev` = breath, hidden
    wind (used §11.2). Add affix to §2.3: `-im` = swarm/host, creatures-of (dekhim,
    savrim, kadrim). Add ONE line at the end of §2.2 marking `oro`, `sur`, `Vesse`,
    `Dravessa`'s dra- as pre-Vessic archaisms surviving from the Saying, decomposable by
    no living grammar — scholars argue (this keeps the three most mythic names legal
    without inventing glosses).

A5. "ROLLS ROYAL" -> "Royal Rolls" (originality advisory: unintended trademark pun on
    a load-bearing institution). Pre-measured: exactly 2 sites (~L290, ~L300); "Royal
    Rolls" currently 0. Sweep both; adjust surrounding article as grammar needs.

A6. BESTIARY FORMAT (consistency-A): family 15 (Heresy-remnants) lacks its origin ->
    temperament prose — add the one-line origin (the Lantern King's leavings: erasure-
    golems still executing sequestered orders, lamp-wights keeping a dead watch; see §6.6)
    + a temperament word. Family 16's "(outside the ages)" tag vs the §8 header rule:
    amend the header to "an origin in §3-§6 (or the Rim, §5.1)".

A7. MONSTER-RESPAWN ROW (consistency-A check-1 #7): add one row to the §13 table:
    repopulation = the Undervault's renewal engine (new souls and raw newness seep upward;
    the wild strata re-fill "as graves grow spring") — one sentence, no new canon.

A8. PLAYER-INFLUX ROW (consistency-A check-1 #8 + Codex Q3 beat 6): add one row to §13:
    why new keepers keep arriving = every generation the Undervault lets more souls up
    than the last (the Fray eats at the rim; the world recruits); shrine-binding at a
    knot-shrine is how a soul enrolls as a keeper. NO other-world/portal conceit — souls
    are native, from the Unsaid, as §3.2 already establishes.

A9. SKILL-GROWTH SENTENCE (consistency-A check-1 #3, weakest of the five core systems):
    in §5.3 where the gates "eat a share of your practice", add the positive half in-line:
    practice is a soul-property the khelet banks by doing — the strands record what the
    hands repeat — which is why the gates can tax it. One sentence, closes the inference
    gap §13 currently papers over.

A10. FESTIVAL POINTER (consistency-A cosmetic): §13 festival row cites "(§4, §10)" but the
    Processional Month is introduced in §9.1 — fix pointer to "(§4, §9-§10)".

A11. MOLDED PETITION-NAME COLLISIONS (craft advisory, canonize-don't-rename): §2.4's
    petition-name examples include "Ovet" and "Suvet" which are identical to the dead
    god's name and the flesh-strand. Add the craft critic's free-lore line: the Registry
    once granted a construct the name Ovet — the Vaultwardens' objection is a standing
    docket item; the Molded consider the precedent sacred. (One sentence in §2.4 or §7.2.)

A12. VESSIC/VESSE NOTE (craft advisory): one clause where Vessic is defined: scholars
    dislike that the tongue's name shares its root with the Unsaid; the Registry's answer
    is that all leftover speech borders on silence. PLUS §14.1 sweep rule: no new ves-
    proper nouns without a distinctive second syllable (cluster is 6 deep).

A13. HERESY-AGE MEGA-SENTENCES (craft): split the two 5+-semicolon sentences in §6.6 into
    shorter sentences. CUT NOTHING; reorder nothing; the content is the book's best.

A14. NAKHOTET/NAKHOTESS (craft minor): in §2.4, either swap the example Nakhotet for
    another theophoric, or add ", the name the folk-heroine Nakhotess bore small" — one
    clause tying them deliberately.

A15. "RESURRECTION-EPIC" MISLABEL (consistency-B A1): §12.6's Kammat Clause quest seed is
    labeled "the canonical resurrection-epic" but §5's system permits no return after the
    corridor completes — the seed's own precedent ends "passed lit" (vindicated, not
    alive). Rename to "the canonical vindication-epic". Do NOT add a return path to §5
    (that would strain the locked Weighing ambiguity).

A16. "SPEED OF GRIEF" ATTRIBUTION (consistency-B A2): §5.2 gives the idiom to the sinking
    tally; §13's respawn row gives it to the shrine-ward echo. Fix the §13 row to reuse
    §5.3's actual language ("the echo is reeled, disoriented and diminished, to the last
    shrine holding its binding-word") and drop the borrowed idiom there.

A17. HAVIR LOCK WORDING (consistency-B A4): §14.3's "his origin is folklore, not physics"
    is strained by §4.2's system-text claim "he has no original to unsay". Reword the
    §14.3 lock to "his origin appears only inside the creation tellings, never as system
    text" AND soften §4.2 to "they say he has no original to unsay". Two small edits.

## PART 3 — DO NOT DO

- Do NOT rename Khelat, Savra, Khelvassa, Khelsurat, Ossel, Suvan (adjudicated: keep).
- Do NOT touch §14.2 immutables or resolve any §14.3 mystery.
- Do NOT recast §4.1's Domain:/Personality: template into portrait prose this round
  (craft advisory deferred — big diff, risks canon drift; owner can request it later).
- Do NOT trim §5.3/§7.2/§10.1 flab this round (deferred with the same reasoning).
- Do NOT edit any file except docs/lore/world-bible.md.

## VERIFICATION (after all edits, run and report)

1. grep -c for each: Marrow, husk, Amarna, Kethral, Solthrekan, Threketh, Vonash,
   Gorvakk, "Rolls Royal", -w ren  => ALL 0.
2. grep -c Slipwoven = 4; Kadvakh = 1; dral = 2; "Royal Rolls" = 2.
   (Note: B5's epithet "the Lone-Ember creed" is derivable from the existing §2.3 gloss
   "the lone ember" — 2 lowercase sites pre-exist and stay; the capitalized epithet is new.)
3. grep -c '^## ' = 15 (14 sections + title line format unchanged).
4. Word count: report before/after (expect net +300..500 words from interiors + rows,
   minus nothing).
5. Confirm §14.2/§14.3 blocks byte-identical EXCEPT the Marrowless->Slipwoven line and
   the ren->dral line (quote any other diff for review, do not silently accept).

## INPUT STATUS: COMPLETE

All five inputs landed and are merged above: originality (2 blockers -> B1-B2), craft
(4 blockers -> B4-B7 as modified by Codex; Khelat rename cancelled -> B5), consistency-A
(1 blocker -> B8), consistency-B (4 blockers -> B9-B12), Codex cross-vendor (ren -> B3,
process fixes). Final tally: 12 blocking, 17 advisory. Everything else in critic reports
was either verified-consistent, adjudicated-keep, or deferred (see PART 3).
