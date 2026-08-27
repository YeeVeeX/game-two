# Junior parallel lane — dungeon/boss dossier + DUNGEON 2 blueprint (assigned s89, 2026-08-26)

Owner assignment (Gabriel, s89 hub chat): Junior asked for parallel work.
These tickets are HIS OWN headline items from `drafts/_junior-v20-input-20260826.md`
(item 2 "falta novos dungeons com boss", item 4 "zone_8 parece vazio…pelo
seu tamanho") promoted into a concrete lane. Drafts-only by design — fully
lawful under the armed freeze. The hub seat will NOT build these meanwhile
(they are claimed to the Junior seat by this doc; CLAIMED discipline below).

## Laws for this lane (armed freeze — until the eighteenth's verdict)

1. Files you may create/edit: `drafts/_junior-*.md` + ONE `CLAIMED:` line
   at the top entry of `docs/CHECKPOINT.md`. NOTHING else: no
   `data/balance/**`, no `data/zones/**`, no `src/**`, no harness/spec/
   runsheet/JUNIOR.md edits.
2. NEVER edit `authoring/pilot.ldtk` and NEVER run `tools/import_ldtk.rb`
   into data/ — the provenance test pins the emission to EXACTLY the four
   pilot zones; a fifth level = red suite = your commit is blocked.
3. NEVER read `docs/superpowers/specs/2026-08-26-v19-eighteenth-ritual.md`
   §9 (sealed ritual questions — reading them voids the measurement).
4. This is CONTENT design, not feel measurement: do not survey or debate
   the peers' feelings about difficulty/boss-reach (ritual topics stay
   virgin until after the ten answers). Your own design writing is lawful
   and welcome.
5. Kit-balance (your input item 5) stays BANKED — not actionable before
   the verdict; do not let it leak into this lane as numbers.
6. Two-seat law (s56 lesson): `git pull --rebase` before starting AND
   before pushing; push the `CLAIMED: J-T1 Junior seat <date>` checkpoint
   line when you START, not when you finish.

## J-T1 — Dungeon + boss ladder touchstone dossier

Deliverable: `drafts/_junior-dungeon-dossier-<date>.md`, committed + pushed.

Turn "novos dungeons com boss" into a grill-ready packet. Every design
claim cites a source (reference-wall law). Sources, all in-repo:

- `docs/design-corpus/systemic-worlds-research-shelf.md` (tier vocabulary
  lives here — FLAGGED-class numbers never land in data/)
- `docs/design-corpus/tibia-research.md`
- `drafts/_tibia-aoe-research-20260813.md`
- `drafts/_tibia-hunt-analyser-ek1037.md` (+ .png)
- `drafts/_mechanics-research-map.md`
- `drafts/_junior-v20-input-20260826.md` (your own words = the brief)

Seed evidence pulled from the hub KB at s89 (retrieval snippets — cite as
"hub KB seed, s89"; treat numbers as FLAGGED-class):

1. Zelda OoT "puzzle box": dungeons as holistic machines, not linear room
   strings — loop: exploration → gating → item acquisition →
   recontextualization → boss (`zelda-franchise-lore-design-and-mechanics`).
2. Radial danger gradient: "true open worlds gate by geography, not
   level-scaling" — distance IS the level gate
   (`world-events-towns-and-folklore-mechanics`). Our `requires_level`
   rungs + deep-side geography already ride this; DUNGEON 2 extends it.
3. Tibia Pits of Inferno: multi-level dungeon delving as endgame identity
   (`tibia-mechanics-lore-and-virtual-world`) — your Tibia instinct is the
   shelf's, too.
4. BDO endgame loop: precise circuits in high-end zones
   (`black-desert-online-economy-combat-and-progression`) — what a boss
   room adds ON TOP of circuit-grinding.
5. "Dungeon = house; boss = house owner; the house has ONE rule you only
   discover by playing" (`mesoamerican-ballgame-underworld-structure-…`) —
   take the MECHANICS concept only (one discoverable rule per dungeon);
   placeholder law: no fiction, names stay DUNGEON 2 / BOSS 2.

Required content:

a. The ladder mapped onto OUR live graph: which zone(s) feed DUNGEON 2;
   zone_8's far reaches as the natural site (your item 4 — its emptiness
   becomes anticipation; the s70 rope-way precedent for the entrance).
b. 2–3 DUNGEON 2 shape candidates: room graph, typed transitions
   (rope = interact, holes/stairs auto-fire), seal placement if any
   (seal gating law: `opens` must name a TRUTHY `sealed` transition),
   boss-arena posture, and each candidate's ONE discoverable rule.
c. Per candidate: what it asks of systems we ALREADY have (spawns, seals,
   `requires_defeats`/`requires_level`, tile classes) vs what would be NEW
   (v20 lane asks, named only — SIM-class pieces like tile-gated spawns
   get named, never designed-in here). NO balance numbers anywhere.
d. Open forks for the v20 grill (entrance gating rung? boss respawn
   posture? relationship to BOSS 1's defeat counter?) — questions, not
   answers.

## J-T2 — DUNGEON 2 paper blueprint (strongest candidate)

Deliverable: section in the dossier or its own `drafts/_junior-dungeon2-blueprint-<date>.md`.

- Tile-grid sketch (ASCII grid or table): rooms, corridors, transitions
  (typed), boss room, entry point from zone_8.
- Sidecar-style table (regions, floor changes, tile classes) — SAFE-class
  behaviors only (decorative variants, footstep materials, ambience);
  SIM-class (lava/water/tile-gated spawns) named as asks, not authored.
- NO .ldtk edits in this ticket. LDtk transcription happens post-verdict
  via the WB pipeline (one session, either seat — T1–T5 precedent).
  Optional stretch ONLY if you want LDtk practice: a NEW file
  `authoring/dungeon_2_draft.ldtk` — never pilot.ldtk, never imported.

## J-T3 — NEXT-UP (not yet assigned)

zone_8 density-pocket sketch (your item 4): the s69 content-fill playbook
(pockets, landmarks, interior doors) as a paper pass over zone_8's dead
air, pairing with the DUNGEON 2 entrance pick. Starts only after J-T1/J-T2
close or on owner word.

## Session close (per docs/JUNIOR.md protocol)

Suite green (`bundle exec rake` — the hooks run it on commit/push), short
handoff note `drafts/_junior-<topic>-<date>.md` (what's done, what's left,
where the evidence lives), `git pull --rebase`, push.
