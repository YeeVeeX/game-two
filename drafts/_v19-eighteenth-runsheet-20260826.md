# LA DECIMOCTAVA — hoja de ruta (v19: crecer en el mundo)

2026-08-26 · protocolo pre-registrado y CERRADO en la spec
(`docs/superpowers/specs/2026-08-26-v19-eighteenth-ritual.md`). Esta
hoja lleva SOLO la logística — **las preguntas NO están aquí a
propósito**: viven selladas en la spec y las administra el dev de cada
asiento, una por una, cuando toque. Ni Gabriel ni Junior las leen
antes (así la medición vale).

## Antes del ritual — una sesión normal de calentamiento (obligatoria)

Desde la última vez que jugaron (24 de agosto) entraron varias cosas
nuevas: zonas nuevas conectadas, dificultad por zona, zonas seguras
con borde visible, panel de STATS en el menú, y ajustes de respawn y
de la IA aliada. La regla: **cada uno juega al menos UNA sesión normal
con la versión actual ANTES de la sesión 1 del ritual** — para que la
primera impresión de lo nuevo no caiga dentro de la medición.

La forma más fácil: **una coop normal los dos** (el juego ya confirma
solo que ambos tienen la misma versión). Esa sesión también sirve para
el pendiente de audio si usted quiere escucharlo. Jugar solo también
cuenta.

## El ritual (dos sesiones coop, en días DISTINTOS — regla dura)

1. **Días distintos de calendario** (según el reloj de la máquina de
   Gabriel). Esta vez sí es en serio: la 17ª quedó con esa deuda y la
   18ª existe para pagarla. Si el dueño decide comprimir a un solo
   día, se anota en el chat ANTES de jugar — y esa parte de la
   medición se pierde, igual que la vez pasada.
2. **Antes de cada sesión: `git pull` en los DOS asientos.** Un
   asiento desactualizado queda rechazado en el saludo (la consola
   dice exactamente qué difiere).
3. **Declaren la sesión en el chat antes de abrir**: "sesión 1 del
   ritual" / "sesión 2 del ritual". Entre las dos sesiones se puede
   jugar normal — eso avanza el mundo y no daña nada; guarden esos
   logs también.
4. Gabriel hospeda (`bin\host-coop.cmd`), Junior entra
   (`bin\join-coop.cmd`). Cada sesión dura al menos 10 minutos de
   juego (ticks ≥ 36000) y termina por el menú: **Esc → SALIR / SAIR**
   — solo la salida limpia guarda el mundo. Nunca cierren la ventana a
   la fuerza.
5. **Cosecha ANTES de cualquier pregunta:** las cuatro líneas
   `TELEMETRY netplay ...` (2 sesiones × 2 asientos), TODAS las líneas
   `TELEMETRY persist ...` y `TELEMETRY progression ...`. Viven en el
   log de cada lanzamiento: `%TEMP%\game_two_session_*.log` (cmd) o
   `/tmp/game_two_session_*.log` (Git Bash) — guarden los ARCHIVOS.
6. **Al cerrar la sesión 2, primero las preguntas, después el
   comentario entre ustedes.** Cada dev le hace sus preguntas a su
   jugador, una por una, por separado, sin changelog ni contexto. Si
   hablan de las sesiones entre ustedes antes de responder, se anota
   como desviación — no se esconde. Las observaciones DURANTE las
   sesiones sí son bienvenidas cuando quieran (quedan guardadas
   aparte).

## Qué mide (para que nadie lo confunda con una demo)

- Los temas del ciclo, ya ratificados por ustedes dos en la
  fundación de v19: continuidad entre días, crecimiento del grupo,
  mapa del riesgo, dificultad, el tercer cuerpo, y veredicto libre.
  Sin énfasis en ninguno — las respuestas mandan.
- Nada de esto se responde con "el dev dice que funciona": lo deciden
  los logs + las respuestas de ustedes dos.

## Leyes que ya conocen (siguen igual)

- Una sesión corta (< 36000 ticks), un cierre no-limpio o un log
  perdido NO es un fallo: esa sesión SE REPITE, al paso del dueño.
- Si una sesión sale con MUCHO lag (el juego define el umbral por
  telemetría), ustedes PUEDEN repetirla — pero solo ANTES de que
  empiecen las preguntas; después de la primera pregunta, la sesión
  vale y el lag se anota al lado.
- Un crash = intento fallido, el mundo no se mueve, se repite.
- Los bots nunca cuentan como evidencia de diversión.
- Los números del juego (respawn, dificultad, precios, progresión)
  quedan CONGELADOS desde hoy hasta el veredicto — la palabra del
  dueño sigue siendo ley, pero se anota y se nombra su costo de
  medición.
