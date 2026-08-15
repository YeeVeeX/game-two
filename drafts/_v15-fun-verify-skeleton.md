# v15 fun-verify skeleton — THIRTEENTH blind ask (prepared 2026-08-15)

**Protocol**: owner plays FIRST, no changelog shown. Harvest
`/tmp/game_two_session_<pid>.log` BEFORE any question. Ask in SPANISH.
Verdict lands verbatim in `drafts/_v15-fun-verify-<date>.md`.

**Preamble (verbatim):** "Si nunca usaste algo, decilo — esas preguntas
se leen como no-ejercitado, no como negativo."

## Las 8 preguntas (español, exactas)

1. **TITULAR A — el descenso:** Cuando cruzaste la Puerta Lenta y
   bajaste, ¿llegar al Muelle Bajo se sintió como llegar a un lugar
   GANADO — un lugar que te costó abrir?
2. **TITULAR B — Varekka:** ¿Te asustó? Cuando cantó y tu cuerpo caminó
   solo hacia él — ¿tu cuerpo (el de verdad) reaccionó?
3. **Justicia de la toma:** ¿Viste venir el canto? ¿Sabías cómo
   cortarlo (cambiar de cuerpo / golpearlo / matarlo)? ¿Algo injusto
   en él?
4. **El muelle sin estaciones:** ¿La subida cargada de vuelta IMPORTÓ —
   se sintió parte de la cacería, o como un trámite?
5. **Teclas:** ¿La franja con teclas dobles resolvió lo que pediste?
   ¿Probaste tu propio bindings.local.json?
6. **Nombres y sellos:** "El Muelle Bajo", VAREKKA, "UNO SE PLANTA",
   "LA CARNE ES LLAMADA", "EL PLAZO ESTÁ PAGADO" — ¿aterrizaron?
   ¿Alguno suena falso?
7. **Economía:** ¿El botín del muelle valió el riesgo? ¿El banco sigue
   siendo PARA algo?
8. **Guardia global:** ¿Algo injusto fuera de Varekka?

## Disclosures del debrief (DESPUÉS de las respuestas, nunca antes)

1. **El sello 3 cambió post-fork**: era "EL NOMBRE QUEDA TACHADO";
   Codex lo refutó por canon → "THE TERM IS PAID / EL PLAZO ESTÁ
   PAGADO".
2. **Tres cambios de balance del pilot (todos dentro de la ley "pinned
   EXCEPT Varekka + his ground"; el owner puede vetar cualquiera):**
   - kill-box del duelo despejado (6 spawns fuera de x>=39) `c77b4f2`
   - guardias des-apilados de los embudos de entrada `2f76956`
   - **Varekka caza todo el muelle (aggro 10→45)** — el duelo viene a
     tu puerta; el approach-gauntlet hasta su esquina era matemática
     imposible (~28 intentos instrumentados, 0 daño). `a8b28b1`

## Routing (del spec, mecánico — NO improvisar)

- Q1: quay.entries>0 + "ganado" → ZONE VALIDATED. "Otro distrito" →
  identity lane (presentación). entries=0 → unexercised, re-ask.
- Q2+Q3 juntos: seized>0 + body-react + nada-injusto → CHALLENGER
  VALIDATED. body-react + seized=0 + chants>0 + nada-injusto → TELL
  VALIDATED (¿el pico vino del ANILLO o interrumpir fue gratis? →
  verbal decide si hay data-lever). body-react + injusto → fairness
  lane (Varekka-only). Flat + engaged=0 → UNEXERCISED. Flat +
  seized>0 → design problem (dossier re-weighs v16). Flat + engaged>0
  + seized=0 → UNDER-EXERCISED (fourteenth re-asks).
- Q4: "parte de la cacería" → fork-1 VALIDATED; "trámite" → chest fork
  re-opens at v16.
- Q5: "resuelto" → lane CLOSES; presentación → display dose; "tecla no
  anduvo" → FUNCTIONAL input-bug lane; "no probé" → unexercised.
- Q6: nombre falso → owner lo renombra del bible en el debrief (banner
  swap re-corre la muralla — decirlo honesto).
- Q7: ledger only. Q8: "nada" → guard-scope 4th clean.
- Difficulty law: cualquier "injusto/difícil" → SOLO levers
  Varekka/quay-local.

## Telemetry to harvest (before questions)

- `quay{entries frames kills deaths banked_after}`
- `varekka{engaged chants interrupted seized swap_escapes slain
  deaths_while_seized ends{...}}`
- `v14 telegraphs_shown`, span_thirds, whirl casts, keybind source
  (bindings.local present?)
