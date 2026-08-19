# LA DECIMOSÉPTIMA — hoja de ruta (v18: el mundo persistente)

2026-08-18 · protocolo pre-registrado y CERRADO en la spec
(`docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md`,
§Fun-verify). Esta hoja TRANSCRIBE — no cambia las preguntas, los
chequeos ni el ruteo.

## El ritual (dos sesiones REALES, en días DISTINTOS)

(**Enmienda 2026-08-18:** mismo día permitido — vea la sección al
final; todo lo demás de esta hoja queda igual.)

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
   se suman a la cadena y cuentan para el chequeo.
5. Cerrada la sesión 2 y cosechadas las líneas: haga las preguntas de
   abajo, POR SEPARADO a cada jugador, sin changelog ni contexto — las
   preguntas llegan vírgenes o no cuentan.

## Media A — PERSISTIÓ (chequeo mecánico; se cumplen TODAS o no pasa)

- **Cadena de digests:** el `persist loaded digest=...` de la sesión 2
  (asiento host) es IGUAL al último `persist saved digest=...` anterior
  en el log del host; y el `loaded ... source=handshake` de Junior
  coincide con el digest del host en LAS DOS sesiones.
- **`desyncs=0` y `reason=quit` en las cuatro líneas netplay**; ticks
  ≥ 36000 en cada sesión.
- **Algo que cruzó de una sesión a la otra, mayor que cero y
  NOMBRADO:** la línea persist de la sesión 2 muestra el estado
  acumulado (banked/seals/marks/sessions) igual al cierre de la sesión
  1 — al menos un dato > 0 mencionado en el resultado.

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

## Nota de ruteo (solo para quien evalúa; se lee DESPUÉS de las respuestas, nunca antes de las preguntas)

- Señal lateral ya registrada
  (`drafts/_junior-specials-chain-retry-20260818.md`): en su primera
  sesión Junior "não entendeu o que a provisão era" — cuenta, ya
  registrada, para la fila "sustain sin usar (`bought=0`) →
  discoverability primero" de la tabla de ruteo de la spec. No decide
  nada por sí sola; se lee junto con las respuestas, después.
- La decisión final se escribe en `drafts/` (precedente de nombre:
  `_v17-fun-verify-skeleton-20260816.md`); la tabla de ruteo de la
  spec dice qué abre cada resultado — nada nuevo arranca antes de esa
  decisión (regla del ciclo).

## Enmienda del dueño (2026-08-18, en vivo — registrada verbatim en el skeleton)

El dueño movió el ritual a MAÑANA y permitió las dos sesiones el MISMO
día ("we can do 2 sessions in a single day" — verbatim, en inglés, en
el chat del dev). Las preguntas NO cambian, con UNA variante de
premisa permitida: si las dos sesiones caen el mismo día, la pregunta
1 de Junior puede decir "Na segunda sessão, ..." en lugar de "No
segundo dia, ..." — misma sustancia, solo la premisa temporal; si se
usa, se anota junto a su respuesta.

Además: las sesiones de mañana corren sobre una build CON audio
(integración M5a, orden del dueño en vivo) y el dueño ordenó esa misma
noche que Junior TAMBIÉN tenga el sonido ("yo quiero que él tenga el
audio on y los assets que creamos ya en la versión de él para que lo
testee" — verbatim, en el chat del dev). Preparación del lado de
Junior: docs/JUNIOR.md §"Som no jogo" (clonar la librería de sonido al
lado de la carpeta del juego + `bundle install`). La consola de él dice
cuál salvedad aplica — `AUDIO on:` = sonido en las DOS máquinas (la
salvedad pasa a ser novedad simétrica: los dos oyen el material nuevo
durante el ritual); `AUDIO off`/`AUDIO refused` = su máquina sigue en
silencio y la salvedad original de asimetría queda tal cual. En los dos
casos la partida VALE y los chequeos de la Media A no cambian en nada.
