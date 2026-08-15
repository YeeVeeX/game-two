# v15.5 fun-verify skeleton — FOURTEENTH blind ask (prepared 2026-08-15)

**Protocol**: owner plays FIRST, no changelog shown. Harvest
`/tmp/game_two_session_<pid>.log` BEFORE any question. Ask in SPANISH.
Verdict lands verbatim in `drafts/_v15p5-fun-verify-<date>.md`.

**Oracle (BOTH halves unchanged from the thirteenth):** did the Low Quay
feel EARNED, and did Varekka SCARE him. Targets vs thirteenth telemetry:
quay frames >> 1137, chants > 0, deaths-per-entry down.

**Preamble (verbatim):** "Si nunca usaste algo, decilo — esas preguntas
se leen como no-ejercitado, no como negativo."

## Las 8 preguntas (español, exactas)

1. **TITULAR A — el descenso:** Cuando cruzaste la Puerta Tarda y
   bajaste, ¿llegar al Bajofondo se sintió como llegar a un lugar
   GANADO — un lugar que te costó abrir?
2. **TITULAR B — Varekka:** ¿Te asustó? Cuando cantó y tu cuerpo caminó
   solo hacia él — ¿tu cuerpo (el de verdad) reaccionó?
3. **Justicia de la toma:** ¿Viste venir el canto? ¿Sabías cómo
   cortarlo (cambiar de cuerpo / golpearlo / matarlo)? ¿Algo injusto
   en él?
4. **El muelle sin estaciones (re-ask):** ¿La subida cargada de vuelta
   IMPORTÓ — se sintió parte de la cacería, o como un trámite?
5. **La tina (el fix de v15.5):** ¿Encontraste la tina en la Puerta
   Tarda? ¿Curarte ahí antes de bajar cambió el muelle — de pared de
   impuestos a cacería?
6. **Nombres y sellos (re-ask del P6, set nuevo):** "El Bajofondo",
   "La Puerta Tarda", "La Rúa Larga", "El Cerrojal", "La Primera/
   Segunda Vela", "UNO SE ALZA", "ALGO HA DESPERTADO", "QUEDA PAGADO
   EL PASO", "QUEDA PAGADO EL PLAZO", "LA REENCARNACIÓN ES INMINENTE"
   — ¿aterrizaron en pantalla? ¿Alguno TODAVÍA suena falso?
7. **Economía:** ¿El botín del muelle valió el riesgo? ¿El banco sigue
   siendo PARA algo?
8. **Guardia global:** ¿Algo injusto fuera de Varekka?

Dropped from the thirteenth: keybind-functional Q (VALIDATED). Strip
legibility stays DEFERRED to resolution scaling (owner's routing) — do
not re-ask.

## Disclosures del debrief (DESPUÉS de las respuestas, nunca antes)

1. **Vat en slow_door** — data-only, tile [3,5], costos = claves de
   economía existentes (heal 2 / regrow 12). El pedido literal del
   owner; el muelle sigue sin estaciones (fork 1).
2. **Pase ES aplicado** — cada línea ratificada por el owner en sesión
   (2026-08-15), incl. DOS líneas ratificadas sobre objeción del dev
   (wipe "LA REENCARNACIÓN ES INMINENTE", canto "ALGO HA DESPERTADO");
   veredicto de la crítica de lenguaje (bloqueante) adjunto en
   `drafts/_es-language-critique-2026-08-15.md` — reportar honesto.
3. **Enmienda moving_square** — cláusula de alcance sintético en
   gate_checks.json (ratificada 2026-08-15); las 49 checks intactas.
4. **Muro**: determinism 16/16; retries standalone del crítico
   documentados en tmp/wall/*_v15p5_retry.log.
5. **Integridad del blind (honesto):** en la sesión de revisión
   adversarial (2026-08-15) el owner vio el tile de la tina [3,5] y los
   targets de telemetría (frames >> 1137, chants > 0) — el fourteenth
   es SEMI-ciego. Debilita la rama de descubrimiento de Q5 y modula la
   lectura de Q1; las preguntas de sensación siguen válidas. Registrar
   esta contaminación en el verdict, eje por eje donde aplique.

## Routing (mecánico — NO improvisar)

- Q1: quay.entries>0 + "ganado" → ZONE VALIDATED. "Otro distrito" →
  identity lane (presentación; la dosis la decide ESTE verdict).
  entries=0 → unexercised, re-ask.
- Q2+Q3 juntos: seized>0 + body-react + nada-injusto → CHALLENGER
  VALIDATED. body-react + seized=0 + chants>0 + nada-injusto → TELL
  VALIDATED. body-react + injusto → fairness lane (Varekka-only).
  Flat + engaged=0 → UNEXERCISED. Flat + seized>0 → design problem
  (dossier re-weighs v16). Flat + engaged>0 + seized=0 →
  UNDER-EXERCISED otra vez → root-cause session, no re-ask ciego.
- Q4: "parte de la cacería" → fork-1 VALIDATED; "trámite" → chest fork
  re-opens at v16.
- Q5 (la tina): usada + muelle cambió → TAX-WALL CLOSED (el root del
  thirteenth). Usada + sin cambio → healing-insufficiency lane (data
  levers only: vat position/costs). No encontrada → discoverability
  presentation lane (station cue dose) — NOT a balance lane.
- Q6: cualquier "falso" → re-ratificación de ESA línea en el debrief
  (swap de string es wall-safe: harness pinned locale=en). El verdict
  de la crítica ES se reporta acá, eje por eje.
- Q7: ledger only. Q8: "nada" → guard-scope 5th clean.
- Difficulty law: cualquier "injusto/difícil" → SOLO levers
  Varekka/quay-local (+ la tina de slow_door, que ya es v15.5).

## Telemetry to harvest (before questions)

- `quay{entries frames kills deaths banked_after}` — target frames >>
  1137, deaths/entry < 1.0
- `varekka{engaged chants interrupted seized swap_escapes slain
  deaths_while_seized ends{...}}` — target chants > 0
- slow_door vat tributes (station events in the session log) — did the
  fix get USED?
- `v14 telegraphs_shown`, span_thirds, keybind source
  (bindings.local present?)
