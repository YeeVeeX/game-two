# LA DECIMOSÉPTIMA — hoja de ruta (v18: el mundo persistente)

2026-08-18 · protocolo pre-registrado y CERRADO en la spec
(`docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md`,
§Fun-verify). Esta hoja TRANSCRIBE — no rediseña preguntas, árbitro ni
ruteo.

## El ritual (dos sesiones REALES, en días DISTINTOS)

1. **Antes de cada sesión:** `git pull` en los DOS asientos (un asiento
   desactualizado queda RECHAZADO en el saludo — la consola nombra el
   campo exacto y sugiere el fix). Usted hospeda (`bin\host-coop.cmd`),
   Junior entra (`bin\join-coop.cmd`).
2. **Cada sesión dura al menos 10 minutos de juego** (ticks ≥ 36000 en
   la telemetría) y termina con **Esc** — con que UNO salga con Esc,
   los dos asientos registran la salida limpia (`reason=quit`). Nunca
   cierren la ventana a la fuerza: solo la salida limpia guarda el
   mundo.
3. **Coseche ANTES de cualquier pregunta:** las cuatro líneas
   `TELEMETRY netplay ...` (2 sesiones × 2 asientos — la consola las
   muestra al cierre) y TODAS las líneas `TELEMETRY persist ...`. Las
   persist viven en el log de cada lanzamiento:
   `%TEMP%\game_two_session_*.log` (cmd) o
   `/tmp/game_two_session_*.log` (Git Bash) — guarde esos archivos (el
   respaldo que salvó a la DECIMOSEXTA).
4. **Entre las dos sesiones usted PUEDE jugar solo** — eso avanza el
   mundo (así se diseñó); guarde también esos logs: sus líneas persist
   se suman a la cadena de evidencia.
5. Cerrada la sesión 2 y cosechadas las líneas: haga las preguntas de
   abajo, POR SEPARADO a cada jugador, sin changelog ni contexto — las
   preguntas llegan vírgenes o no cuentan.

## Media A — PERSISTIÓ (árbitro mecánico; se cumplen TODAS o no pasa)

- **Cadena de digests:** el `persist loaded digest=...` de la sesión 2
  (asiento host) es IGUAL al último `persist saved digest=...` anterior
  en el log del host; y el `loaded ... source=handshake` de Junior
  coincide con el digest del host en LAS DOS sesiones.
- **`desyncs=0` y `reason=quit` en las cuatro líneas netplay**; ticks
  ≥ 36000 en cada sesión.
- **Un hecho acarreado, estrictamente positivo y NOMBRADO:** la línea
  persist de la sesión 2 muestra el estado acumulado
  (banked/seals/marks/sessions) igual al cierre de la sesión 1 — al
  menos un hecho > 0 citado en el veredicto.

## Media B — SE SINTIÓ (por separado, preguntas VERBATIM de la spec)

**Para usted (es):**

1. Al volver hoy, ¿sintieron que retomaban donde habían parado, o que
   era una partida nueva?
2. ¿Cómo se sintió el respawn de los enemigos esta vez?
3. ¿Usaste las provisiones? ¿Cómo cambió la cacería? ¿El precio?
4. Veredicto libre.

**Para Junior (pt-br):**

1. No segundo dia, pareceu que vocês tinham voltado pra onde pararam,
   ou que era uma partida nova?
2. Em dupla, como sentiu a dificuldade dessa vez?
3. O terceiro corpo (a IA) — como se comportou?
4. Veredicto livre.

## Nota de ruteo (solo el adjudicador; se lee DESPUÉS de los veredictos, nunca antes de las preguntas)

- Señal lateral ya registrada
  (`drafts/_junior-specials-chain-retry-20260818.md`): en su primera
  sesión Junior "não entendeu o que a provisão era" — evidencia
  pre-registrada para la fila "sustain sin usar (`bought=0`) →
  discoverability primero" de la tabla de ruteo de la spec. No es
  veredicto; se pondera junto con las respuestas, después.
- El veredicto se arma en `drafts/` (precedente de nombre:
  `_v17-fun-verify-skeleton-20260816.md`); la tabla de ruteo de la
  spec decide qué abre cada resultado — nada nuevo arranca antes de la
  adjudicación (contrato de alcance).
