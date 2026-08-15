# Critic pass A — gameplay hooks & cross-references (world-bible.md)

Source: `docs/lore/world-bible.md` (619 lines, 14 sections) + `PARKING_LOT.md`.
Findings located by quoted text + approximate line (file may drift).

## Verdict: FAIL (1 blocking, 15 advisory)

Blocking: the §4.3/§14.3 "two cults (§10)" that dream of re-opening death's door — the stated endgame stakes — resolve to no cult actually described in §10. One-clause fix in §10.3. Everything else is advisory; parked-system coverage is otherwise strong (5/5 core systems genuinely fictionalized; 2 of the 3 soft systems thin).

## Check 1 — parked systems

| System | Status | Quote (grep-able) | Note |
|---|---|---|---|
| 1. Corpse-run / gear drop | COVERED | "Where you fell, it lies — with everything it wore and carried, because objects are knotted to bodies, not echoes" (§5.3, ~L246) | Full in-fiction engine: flesh-anchor, ten-day looter term, "the walk of shame and iron" named as an ordinary errand. §13 row (~L551) closes the loop incl. PvP looting as sacrilege. |
| 2. Respawn / return from death | COVERED | "the echo is reeled, disoriented and diminished, to the last shrine holding its binding-word" (§5.3, ~L242) | Half-Passage + knot-shrines + Re-knotting + Silt Mother vat-grown provisional bodies (§10.2). Respawn-location logic and travel-back both fictionalized (§13 "at the speed of grief"). |
| 3. Skill-through-use progression | WEAK-COVERED (passes, note the inference) | "skill sinks toward ignorance... the gatekeepers have *eaten a share of your practice*" (§5.3, ~L244); §13: "The gates can *eat* practice, therefore practice is a measurable soul-property that grows by doing" (~L555) | The positive half (skill GROWS by use) is only derived by inference in the §13 appendix; the lore body (§5, §11) explains loss and licensing but never states in-fiction WHY doing a thing increases practice. Genuine explanation exists via the appendix, so not blocking — but the weakest of the five. |
| 4. Factions | COVERED | "Factions map to reputation tracks: three licensed super-temples... three forbidden tracks (heresy/horror/crime) each with a defensible grievance" (§10 design note, ~L461) | §10 is a full faction economy: licensed temples, secular counterweights, three banned cults each with in-fiction motive + grievance. Reputation = enrollment standing, fictionally grounded in §10.1. |
| 5. Bestiary (family-by-family) | COVERED | "Sixteen families. Each entry: origin → temperament → example creatures" (§8 header, ~L350) | Counted: exactly 16 families, matching the claim. 15/16 carry an explicit origin sentence tracing to a god/age/catastrophe per Law III. Family 15 ("Heresy-remnants — the Lantern King's leavings") is the outlier: title + stratum only, NO origin/temperament prose — the origin is recoverable from §6.6 but the entry breaks its own "origin → temperament → examples" format. Minor. Family 16 is tagged "(outside the ages)" yet §8's rule demands "no family without an origin in §3–§6" — satisfied via the Rimsea in §5.1, but the tag reads as self-contradiction at a glance. |
| 6. Hub-and-spoke zones / tiers | COVERED (advisory note) | "Hub-and-spoke geography: Sildarun as starter hub (river = road)... Undervault as the vertical region everything connects to" (§9 design note, ~L420) | Seven regions + vertical Undervault; in-fiction difficulty gradient exists (Weave thins toward the rim, order thickest at the river core). Advisory: tier ordering (starter → endgame) lives only in design-note voice; no in-fiction reason a NEW character stays out of the Scarps beyond common sense. Acceptable altitude for a bible. |
| 7. Monster respawn (repopulation) | WEAK — ADVISORY | "The Unsaid's raw newness enters the world only up through the Undervault... spring rises out of graves" (§3.2, ~L124) | Renewal-through-death gives a general engine for repopulation, and elementals/wights are persistent-not-repopulating by nature. But the bible never states why a cleared spawn refills — e.g. do slain Vakhur re-muster? Do cinder-beasts re-fall? §13 covers spawn *placement* (strata) but has no respawn row. One sentence in §13 would close it. |
| 8. Why player characters keep arriving | MISSING — ADVISORY (per brief: 6-8 advisory) | "a closed world receives no new souls, no renewal — only a slow going-stale" (§3.2, ~L110) is the nearest hook | No in-fiction account of the adventurer influx: §7.1 gives "player-flavor" per culture and §9.1 names the starter hub, but nothing explains why fresh keepers/heroes continually appear. The new-souls-through-the-Undervault pipeline is an obvious one-row fix for §13; currently unwritten. |

## Check 2 — dangling refs

### 2a. Section cross-refs (all § pointers swept via grep)

- **BLOCKING — "the explicit dream of at least two cults (§10)"** (§4.3 OVET entry, ~L200). No cult in §10 is described as dreaming of re-opening death's door / knotting Ovet's aspect back out of Ulveth. §10.3's three banned factions want other things (Emberites: free the Ember; rim-cults: dissolution into the Unsaid; Free Gleaning: necromantic labor-credit). §14.3 compounds it: "the cults that dream of re-opening death's door never receive a definitive yes or no" — same phantom cults. This is the stated implicit stakes of the ENDGAME, so it is load-bearing. The Free Reeds "keep Ovet's old open-door rites" (§7.1/§9.4) but are a culture, not a §10 cult, and the ref explicitly points at §10. Fix: one clause in §10.3 naming the door-dream (e.g. a Vaultwarden heterodoxy + a Free Reeds mystery-lodge), or repoint the ref.
- "§10–11" (§5.5 ghouls, ~L262) — RESOLVES: §10.3 Free Gleaning + §11.4 necromancy counts. OK.
- "§7–8" (§4.1 Kadrash's Vakhur, ~L165) — RESOLVES: §7.2 + §8 family 2. OK.
- "§9.5–9.7" (§13 endgame raid row, ~L567) — RESOLVES: all three targets carry the claimed content (deep archive / middle chambers / Rim). OK.
- "§3–§6" origins rule (§8 header ~L350, §14.4 ~L616) — RESOLVES: every family's stratum tag maps into §3–§6 (family 16 via the Rimsea, which is §5.1 — see advisory below). OK.
- "used exactly once in recorded history (§6)" (glottal blasphemy, §2.1 ~L36) — RESOLVES: Khel'Suvan, §6.6. OK.
- "(§10)" on the vat-grown provisional bodies (§5.3 ~L242) — RESOLVES: §10.2 Silt Mothers "growers of provisional bodies in the vat-gardens of Sur-Sildra". OK.
- ADVISORY — §13 festival row (~L564) cites "Festival calendar (§4, §10)" but lists the **Processional Month**, which is introduced only in §9.1 (~L394). Cosmetic pointer error.
- ADVISORY — family 16 is tagged "*(outside the ages)*" while §8's own header mandates "no family without an origin in §3–§6"; the Rimsea origin is §5.1, not §3–§6's ages. Reads as self-contradiction; fix the header rule to "§3–§6 or §5.1" or retag.

### 2b. Numbered indices

- "bestiary family 15" (§9.5 threats, ~L410) — RESOLVES: family 15 Heresy-remnants exists and matches (lamp-wights, cast-stone erasers, the Un-Signed). OK.
- "Sixteen families" (§8 ~L350) vs §13 "sixteen families (§8)" (~L561) — counted 16 numbered entries. OK.
- Twelve chambers / twelve pieces / twelve night-hours — consistent across §3.2, §5.1, §5.4 (tally-shelf 11th, court 12th), §9.7 (1–4 municipal, 5–9 wild, 10–12 court). Kammat "of the Ninth Hour" sits correctly in the middle chambers. Fourth-Chamber gate-hound sits correctly in the municipal range. OK.
- Nakhotess Folios: "eleven recoverable; the twelfth in the deep archive; the thirteenth never written" (§12.7 ~L536) — §14.3's "thirteenth Nakhotess folio's blank page" matches. OK.
- The Complement: "eleven sailors... looking for their twelfth" (fam 16 ~L382) vs §12.2 "brought back the Complement's twelfth sailor" — consistent. OK.
- Date math: AS 3207 present − AS 2921 restoration = 286 ✓ matches "Two hundred eighty-six years" in §6.7, §9.5, AND §10.3 (three independent statements, all agree). OK.

### 2c. Load-bearing entities — introduction check (18 verified)

All checked by grep for first-mention vs use. RESOLVED (properly introduced before/with a forward pointer): **Shuttered Lantern** ("the Shuttered Lantern is the template", §14.4 → introduced §4.3 ~L202); **Dravessan Concord** (§6.7 intro → used §10.1); **Great Processing** (§6.6 intro → §8 fam 5, §9.7); **zol-knot** (§4.2, explicitly "load-bearing for §5" → §5.2, §8 fam 13); **the Veskha/Maw** (§5.4); **Ithves** (§3.3 → §4.2 entry); **savrim** (§4.1 → §6.4); **dekhim** (§4.1 → §7.1, §8 fam 12, §9.3); **cord-hags** (§4.2 → §6.5); **hollow twins** (§4.2 → §8 fam 13); **Rolls of Names** (§4.1); **binding-word** (§5.3 → §13); **Khelvassa** (§2.3 gloss + §6.6 → §9.5, §12.1, §12.5); **Dravessa** (§6.6 → §12.1); **the Un-Signed** (§8 fam 15 → §9.5, §12.7); **Grey Bride** (§8 fam 5 → §11.3, §13); **Emberites** (§6.6 with explicit "(§10)" pointer → §10.3); **Moonwake + the Shuttering** (§4.3 → §13 festival row). Boss-row names (Vessakhel, Composted King, Landfall) all trace to their §8 entries. **Zero dangling entities found** — the one dangling reference is the §10 "two cults" pointer in 2a, which is a content gap in the target, not a missing introduction.

- COSMETIC — "the blade Nakhoro had made him" (§3.2, ~L112): Kadrash's god-killing blade is never named and never reappears (not among §12 artifacts). Likely deliberate mystery, but it is the murder weapon of the founding event; consider a §14.3 lock or one legend line.

## Check 3 — naming compliance (ADVISORY only; collisions out of scope)

Spot-checked 20+ prominent nouns from §4/§8/§9/§12 against §2.2 roots + §2.3 affixes.

**Compliant (derivation exists as stated):** Suvareth, Ulveth, Hezreth, Mureth (root+-eth); Tekhur, Havir, Vakhur (agent -ir/-ur); Gorai, Kadravai (-ai folk); Khelvassa (-vassa); Khelat, savret, and the five strand-names suvet/khelet/havra/nakh/dekhat (-et/-at, -a); Sildarun, Dekharu(n) (-un); Sildra, Savra (-a source); Suvakhelan/Khel'Suvan (theophoric -an; the glottal is the in-fiction blasphemy, correctly so); Suvan (suv+-an, glossed in §6.5); Nakhotess (female twin of glossed *Nakhotet*); Kammat and Ossel (listed in §2.4); Ithves (ith+ves, "the Last Unsaying" — exact); Gorvakk (gor+vakh, doubled consonant per struck-name rule); Ovet/Suvet/Nakhet petition names (root+-et as §7.2 states). The system demonstrably works for the large majority of the canon.

**Findings (all ADVISORY):**
1. **§2-internal contradiction:** §2.1 says "Words never end in **h** or a cluster" — but §2.3 defines affix "-a / -ah" with canonical example *Zolvah* (~L49, L61), and h is listed as a plain consonant. Either exempt word-final -ah as a digraph in §2.1 or respell. Same tension: bare root "vakh" used as a standalone creature word ("**vakh levy**", §8 fam 2) if kh does not count as single-consonant kh.
2. **Unglossed root *hev*:** §11.2 "Deep-register mana is called **breath** (*hev*)" (~L482) — *hev* is not in §2.2, violating §14.1 rule 1's own standard ("New roots may be added only by writing them into §2.2... in the same change that first uses them"). One-row table fix.
3. **Systematic but undefined suffix -im:** *dekhim*, *savrim*, *kadrim* (§4.1, three separate god-entries) share an evident creature/plural suffix absent from §2.3. Add it — it is already de-facto canon.
4. **Nakhoro / Khelsurat / Vessakhel — underivable second elements:** *Nakhoro*'s "-oro", *Khelsurat*'s "-surat" (khel+? — *sur* is not a root; Suvakhelan IV's name suggests suv+khel but Khelsurat's does not decompose), and dragon *Vessakhel* (ves+?+khel — the doubled-s spelling matches **Vesse** the Unsaid, itself an unglossed extension of root *ves*). None decompose cleanly under §2.2. These are the three most prominent mythic names in the book; either gloss the missing elements (oro, sur/surat, Vesse) into §2.2 or note them as pre-Vessic archaisms.
5. **Vesse itself** (§3.1, ~L92) — the primordial Unsaid's proper name is a form of *ves* with no stated derivation for the -se; used again in §5.1 ("the sea beyond the last charted water is Vesse"). Same fix as 4.
6. **Culture-register names are self-consistently exempt:** Markfolk (*Halden* ← khel-dan is glossed; *Bralda, Hodrim, Tessa, Uvebrand* are covered by the "worn down" erosion rule) and Free Reeds (*Virel, Ionna, Auvess, Melor* — "liquid, vowel-forward" is the stated rule, though none decompose to roots). §2.4 grants these patterns, so compliant — but note §14.1 rule 1's blanket "every proper noun derives from §2" is really "derives from §2.2 roots OR matches a §2.4 culture pattern"; wording could be tightened.
7. **Dravessa** — dra? + vessa? Neither *dra* alone nor a -vessa affix reading (throne-city, §2.3) fits a human general's name; closest is drum-name style but she is Sildaruni. Prominent (Concord is named for her); worth an explicit derivation.

