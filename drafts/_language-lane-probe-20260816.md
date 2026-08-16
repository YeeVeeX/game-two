# Language lane, step 1 — the 3-probe register calibration package (2026-08-16, Junior seat)

> **Standing:** the lane is OWNER-GATED and this package changes NOTHING
> the player sees — `git diff` touches only `drafts/` + `docs/language-lane/`.
> No string ships, no line is re-worded, no owner override is touched.
> Standing authorization: the lane is item 1 of the ratified CHECKPOINT
> NEXT list (Junior also relayed the owner's go-ahead, as context, not
> as the basis). Prepared from the JUNIOR SEAT; every interpretation
> call below is proposed for owner veto at the pick (v13 precedent).
> Sequencing law honored: (a) scaling and (c) stamp delivery shipped
> and walled before this ran.

## What this is

The pre-registered opener of the v16 language lane (AGENTS.md; spec
scope bullet; CHECKPOINT NEXT 1): **3-probe register calibration on
captures — attested-notarial / plain / game-generic, owner picks
blind** — to learn what two consecutive set-level "suenan falsos"
verdicts point at BEFORE any candidate generation.

**Probe surface (dev call, veto-able):** the probes are three register
variants of the ONE line the lane is authorized to author today —
`stamp.mark_void` ES (EN fallback "THE MARK IS VOID" ships; ES/PT
deliberately absent). Grounds: the routing law grants grounded
candidates ONLY to owner-named lines + mark_void; no shipped line is
named yet (naming is the fifteenth's Q7); probing on mark_void means
the calibration never touches a ratified line or an owner override,
and the winning probe doubles as the leading mark_void candidate.

## The ask (owner, blind)

Look at the three captures — same replay, same frame, only the stamp
text differs. **¿Cuál lee VERDADERO in situ?** Answer with a letter;
naming shipped lines that still read false stays with the fifteenth's
Q7. (The ask is deliberately just that — no register hints, so the
pick stays diagnostic.)

- `docs/language-lane/probe-a.png`
- `docs/language-lane/probe-b.png`
- `docs/language-lane/probe-c.png`

Register-to-letter mapping is SEALED below (md5 published here so the
seal is provably pre-pick): `d3063da5278d0293a349df1d2e2c704e`.
A second-choice or an "all false / none lands" verdict is valid data —
say it.

## Scene provenance

- Script: `harness/scripts/burn_duel.json` (seed 7, low_quay, inscribed
  start) — the burn beat's designated exerciser, wall-gated 53/53.
- Beat: `vessel_seized` frame 479 → blocker dies seized frame 495 →
  `inscription_burned` at [24,6]. The seize stamp dwells first (stamp
  grammar: scale-in 12 + dwell 150 + fade), so the mark-void stamp
  lands after it: **frame_0700 sits inside the mark-void stamp's
  dwell** (fully scaled, fully opaque) in all three variants.
- Resolution: logical 960x540, 1:1 (captures are scale-blind by
  construction; live play integer-upscales this exact frame). View the
  PNGs fullscreen to approximate play scale.

## Mechanics (comparability untouched)

The harness pins captures to locale `en` (harness/scenes/world_scene.rb,
the v13 comparability law) — so each probe run temporarily edited the
`stamp.mark_void` VALUE in `data/strings/en.json` in the working tree,
ran `ruby -Isrc harness/replay_runner.rb harness/scripts/burn_duel.json
captures/probe_lane/<X>`, then restored via `git checkout` (tree
verified clean after each cycle). Strings are render-only; the sim,
seed, and inputs are identical across A/B/C — the pinned wall capture
dirs were never written to. To re-render any probe on the owner seat:
same temp edit, same command, any out_dir.

## Meaning brief — stamp.mark_void (for the pick and beyond)

- **Event:** a body dies WHILE SEIZED by Varekka and it carried a
  god-mark → the mark BURNS (`inscription_burned`); located stamp +
  floor seal pressed at the death tile.
- **Speaker:** the court's paperwork — declarative, stamped, settled.
  Stamps record what HAS been settled; the court never predicts
  (register laws: participial settled-state; exact naming — the court
  knows the name of everything it stamps; terseness; no futures).
- **Canon (HARD):** what is annulled is the MARK — the one-judgment
  enrollment the altar wrote for that body — never the NAME.
  "THE NAME IS STRUCK" was a confirmed canon violation (an ordinary
  death leaves the name with the living; striking a name is Registry
  full liturgy). Anything implying name-erasure, soul-loss,
  reincarnation, or permadeath is false.
- **Teaching:** this is the non-refundable loss (the dread-stakes
  knob) — the court's claim pierced the vat's.
- **Negative examples on record:** "THE NAME IS STRUCK" (canon);
  "LA REENCARNACIÓN ES INMINENTE"-class imported cosmology;
  "ALGO HA DESPERTADO"-class vague-menace slop; "es inminente"-class
  system-announcement future voice; dev translationese ("estacas
  no-reembolsables", "darles entrega").
- **Register anchors (ES):** the ratified crown pair QUEDA PAGADO EL
  PASO / QUEDA PAGADO EL PLAZO (notarial "queda + participio");
  slop-test 5s: El Cerrojal, La Puerta Tarda, ithet/goret/hevet.
- **Noun note (for ratification, not the pick):** the probes hold the
  subject constant as *la marca* (mirrors EN canon "THE MARK IS
  VOID"). Referent collision, same as EN: `overlay.mark` = *marcar* is
  the TARGET-mark action (marking an enemy), a different mark from the
  god-mark this stamp voids — EN ships the same collision ("mark" /
  "THE MARK IS VOID"). Alternatives if the owner
  wants them at ratification: *la inscripción* (the d1b altar verb),
  *el sello*. The god-mark's player-visible fiction name is still
  docs-bound — the line must carry the meaning without a canonized
  proper noun.

## After the pick

1. Owner answers with a letter (+ anything the probes taught about
   "falso"). Junior seat (or dev of record) unseals the mapping —
   anyone can verify the md5 above.
2. If the winning probe IS the mark_void line the owner wants: ratify
   it on the capture, land `stamp.mark_void` in `data/strings/es.json`
   (harness stays pinned en; gates untouched), and Junior post-edits
   the PT-BR from this brief + the ratified ES.
3. If the owner wants variations: grounded candidates in the WINNING
   register only, composed natively per the authorship law, re-rendered
   on this same frame for the on-capture pick.
4. Shipped-line re-wording stays gated on the owner NAMING lines
   (fifteenth Q7 routing law) — the calibration result then tells us
   which register the re-words are authored in.

---

## SEALED MAPPING — owner: do not read before answering

<br><br><br><br><br><br><br><br><br><br>

```
A=plain | B=attested-notarial | C=game-generic
```

- **A — plain:** LA MARCA YA NO VALE (words a tired person could say;
  exact subject; present state; no legalese)
- **B — attested-notarial:** QUEDA ANULADA LA MARCA (mirrors the crown
  pair's QUEDA + participio structurally; "queda anulada" is attested
  Spanish legal annulment formula; settled-state voice)
- **C — game-generic:** MARCA DESTRUIDA (the deliberate slop control:
  two-word system-message voice, ships in any game unchanged)

md5 check: `printf 'A=plain | B=attested-notarial | C=game-generic' |
md5sum` → `d3063da5278d0293a349df1d2e2c704e`.

---

## POSTSCRIPT — RACED, AND THE RACE IS THE RESULT (2026-08-16, pre-push)

Before this package pushed, the owner seat ran its OWN blind 3-probe
calibration and ratified `stamp.mark_void` ES at `a563b35`:
**QUEDA ANULADA LA MARCA — the exact line this package carried as
probe B.** Two calibrations prepared independently on two machines
(neither saw the other's candidates), same corpus laws, same winner.
The pick sections above are therefore SUPERSEDED — no owner action on
this package is needed. It stays in the record as independent-
convergence evidence for the notarial register: the grounding method
(QUEDA + participio mirror of the crown pair, "anulada" as the
attested annulment participle) reproduces across seats. The PT-BR
post-edit now proceeds from the owner's brief
(`drafts/_mark-void-ptbr-brief-20260816.md`) + the ratified ES —
Junior's call, recorded separately.
