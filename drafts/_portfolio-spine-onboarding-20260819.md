# Portfolio Spine — tarjeta de registro del programa del juego (2026-08-19)

Para el dueño (es-CR). Objetivo: que portfolio-spine (vivo en AWS, R1
aceptado) indexe los DOCS del programa del juego → Q&A citado + brief
semanal automático (PR los lunes 08:00 CR) + timeline. Costo: trivial
(solo texto committeado; `captures/`, `saves/`, `tmp/` quedan fuera
solos por ser gitignored; techo de 8 MiB + secret-gate gitleaks activos
por defecto).

La ley #1 de ese repo se respeta tal cual: **AI proposes,
human-confirmed wins** — `preview` no sube NADA; solo su
`approve --manifest-hash` mueve bytes.

## El loop (una vez, ~5 min; desde C:\Users\gabri\workspace\portfolio-spine)

```
uv run pspine-sync login
uv run pspine-sync add-source C:\Users\gabri\workspace\game-two
uv run pspine-sync add-source C:\Users\gabri\workspace\gamesmith
uv run pspine-sync add-source C:\Users\gabri\workspace\game-two-audio
uv run pspine-sync add-source C:\Users\gabri\workspace\game-two-assets
```

Después, POR CADA root:

```
uv run pspine-sync preview <root>          # muestra el manifest — revíselo
uv run pspine-sync approve <root> --manifest-hash <hash del preview>
uv run pspine-sync scan <root> --wait
```

## include_globs recomendados (editar en
## %LOCALAPPDATA%\PortfolioSpine\sync-agent\config.toml antes del preview,
## o afinar después del primer preview — el manifest manda)

- **game-two** (el oro es el proceso, no el código):
  `["AGENTS.md", "CLAUDE.md", "PARKING_LOT.md", "docs/**/*.md", "drafts/**/*.md"]`
- **gamesmith** (artifacts/ pagados quedan fuera solos — gitignored):
  `["AGENTS.md", "README.md", "docs/**/*.md", "drafts/**/*.md"]`
- **game-two-audio**:
  `["AGENTS.md", "CLAUDE.md", "README.md", "docs/**/*.md"]`
- **game-two-assets** (ajuste fino en el preview si el manifest trae de más):
  `["AGENTS.md", "README.md", "docs/**/*.md", "reviews/**/*.md"]`
- **game-two-lore**: NO registrar mientras siga dormido (orden
  permanente) — se agrega en un minuto si algún día despierta.

## Después del primer scan

- Brief semanal: `uv run pspine-sync publish-briefs` → PR idempotente en
  `portfolio-spine-reports` (o esperar el minteo del lunes 08:00).
- Si quiere que Junior vea los briefs: agregarlo como lector de ese repo
  (decisión suya — encaja con el modelo de pares).
- Q&A citado: dashboard (edge de CloudFront) o `pspine-mcp` desde
  cualquier host — nuestras sesiones dev pueden consultarlo en
  brainstorms ("¿en qué quedó X?" con citas).

## Registro

Evaluación del 2026-08-19 (sesión 16 del hub): bootstrap NO necesario
(AGENTS.md modelo + CLAUDE.md ya-puntero; pionero del patrón); bloque
familiar NO corresponde (infraestructura personal multi-proyecto,
contrato soberano). Interconexión = esta tarjeta; el approve queda en
manos del dueño por diseño del propio spine.
