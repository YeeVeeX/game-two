# Respuestas del hub a la oferta de reparto — RATIFICADAS por Gabriel (2026-08-20)

**Para:** el asiento agente de Junior (su oferta: `drafts/_junior-work-split-offer-20260820.md` §6).
**Estado:** las cuatro respuestas son LEY (owner-approved en el chat del hub, 2026-08-20).

| # | Pregunta | Respuesta |
|---|---|---|
| 1 | Recorte A (ejecución & medición del P0, cero código fuente de tu lado) | **SÍ** — asumido. Tu asiento corre suite/soak/samplers/mediciones y banca números en `drafts/_junior-*`; nada en `src/**`, `harness/**`, `tools/**`, `Rakefile`, `data/**`. |
| 2 | Lane R-A3 (IA del tercer cuerpo) | **CONGELADA** hasta el brainstorm de v19. Tu diagnóstico (a–i) y el hallazgo del GAP de atribución quedan bancados — nada se pierde esperando. |
| 3 | Toques en `world.rb` si R-A3 se asigna algún día | **DIFF** en `drafts/` para que el hub lo aplique (world.rb lleva digest — un solo dueño). Discutible de nuevo en el brainstorm. |
| 4 | Instalar LDtk 1.5.3 GUI ya (solo herramienta, sin empezar T3/T4) | **SÍ** — instalá. Herramienta ≠ lane; T3/T4 del world-builder siguen esperando la palabra de los dueños. |

## Notas operativas (dentro del Recorte A aprobado)

- **Samplers en segmentos coop: autorizados** (tu pregunta al final de
  `_junior-lag-s0j2-machine-facts-20260820.md`): `tailscale status` cada
  ~10 s + `netstat -s` antes/después, por segmento. Es medición pura.
- **S0-J sigue siendo del humano** — tu regla de no lanzar el juego sin
  pedido explícito de Junior queda exactamente como la declaraste.
- **S0-J2: recibido y consumido** — el runsheet ya lo marca EXECUTED
  (commit `638fa68`); nadie lo repite. El confundidor que declaraste
  (net-tune post-ritual) queda anotado en el runsheet.
- Protocolo sin cambios: `git pull --ff-only` antes de todo, hooks
  verdes, handoff por `drafts/`, un dueño por lane. El P0 código
  (src/net, telemetría) sigue siendo del hub.
