# MUNDO VIVO — FASE 3: tiles com cara de tile + spike de perf — Junior seat, 2026-09-05

**FREEZE: liberado** (s125). **CLAIMED:** FASE 3 (branch `junior/mundo-vivo`,
sobre FASE 2 `5644579`). Classe: presentation pura (SAFE); tipos de tile
novos = decorativos, `passability: floor` (registro enforça a wall law).

## O que existe agora

- **`src/app/tile_art.rb`** — `App::TileArt.rects(map, registry)`: relevo
  derivado da vizinhança, função PURA de grid+registry+palette, memoizado
  por mapa, merge horizontal, culled: **face de muro** (banda escura 8px na
  base de todo muro que encosta em chão/água — o "penhasco"), **borda
  clara** 2px no topo de muro que encara chão acima, **sombra** 6px
  (preto α70) no chão logo abaixo de um muro, **espuma** 2px clara em toda
  aresta de água voltada pra chão andável. Cores derivam da paleta da zona
  (muro ×0.62 / ×1.35, água ×1.9) — zero constante de cor nova; cada zona
  mantém identidade e ganha profundidade.
- **Grid de linhas OPCIONAL** (D7): `display.json grid_lines: false` por
  default — com faces, a grade virou ruído; `tile_faces: true` liga o
  passe. O gate decide, os peers ratificam.
- **`data/tiles.json`: +6 tipos DECORATIVOS** — `moss (m, int 9,
  ambience moss_sway 35%)`, `rubble (r, 10)`, `bones (b, 11)`,
  `lava_deco (L, 12, ambience lava_glow 50%)`, `puddle (p, 13, footstep
  water, ambience ripples 80%)`, `roots (R, 14)`. Todos `passability:
  floor`; footsteps de materiais existentes. Ficam disponíveis pro
  importer LDtk (int_grid 9–14) e pros sidecars/paletas da FASE 6.
- **Prova visível (lei "todo commit muda o que o player vê"):** `camp`
  (HUB 1, hand-authored, caminho legal) ganhou musgo ×10 nos cantos + poça
  ×2 (palette `moss`, `puddle`); passabilidade byte-igual (teste).
- Testes: `test/app/tile_art_test.rb` (6: face+sombra+borda no mapa
  sintético, espuma só voltada pra chão, interior vazio, toda zona viva
  pura+on-map, tipos novos registrados e SAFE, camp anda onde andava);
  `tile_registry_test` e `import_ldtk_test` atualizados pros 14 tipos.

## Spike de perf (o número decide — §4.3 do prompt mestre)

| Medida | Resultado |
|---|---|
| **(i) draw culled + faces + sprites + ambiência** (`GAME_FRAME_PROBE=1`, bot 900 ticks) | zone_7 `p50=1.8 p95=5.2` · piso -2 `p50=1.7 p95=4.3` · **ZONE 8 (64×40, maior) `p50=4.7 p95=8.4`** ms — pior caso = 51% do orçamento (16.6) |
| **(ii) camada estática pré-renderizada** | **NÃO NECESSÁRIA**: o draw culled não escala com o tamanho do mapa (viewport fixo ≈ 510 tiles visíveis). Riscos de (ii) (resample sob câmera fracionária — wb-t5; textura > limite GPU na cidade 4×) evitados sem custo |
| **flow_field.recompute!** (cidade sintética = zone_7 replicada k×, `tmp/_flow_bench.rb`) | **1× 2.8 ms · 2× 11.3 ms · 3× 26.8 ms · 4× 49.3 ms** por âncora — roda quando um inimigo muda de tile (`World#flow_to`, cache por âncora). Hub SAFE sem spawns = ~0 em jogo (só na entrada); pátio de treino (D6) numa cidade 3×/4× = estoura o tick de 16.6 |
| `rake perf` (sim, district) | inalterado (presentation não entra no tick) |

**→ D1 com número:** 2× (88×56) é o teto seguro com inimigos vivos na
cidade; 3×/4× exigem BFS limitado por raio no flow field (mudança de
SIM, ticket próprio, fora desta fase). Recomendação do dev: **cidade 2×
na FASE 7; 3× como upgrade quando o flow field bounded existir.**

## Evidências

| Prova | Resultado | Caminho |
|---|---|---|
| Suite | **1370 runs, 39021 assertions, 0 failures** | hooks |
| Determinismo `world_loop` (camp musgo/poça + district faces) | 10/10 byte-idênticas ×2 | `captures/world_loop_gate_*` |
| Determinismo `town_gates` (faces zone_7 + tochas) | 6/6 byte-idênticas ×2 | `captures/town_gates_gate_*` |
| Frames lidos | muros com penhasco+borda, sombra sob muro, grade sumiu, tiles contínuos; espuma nas arestas do poço | `tmp/f3_zoom.png`, `tmp/z7_f3.png` |
| Rule 2 (crítico) `world_loop` · `floor2_run` · `town_gates` | *(cadeia lançada; colado ao fechar)* | `tmp/wall/fase3_*.log` |

## Re-pin (nomeado)

FASE 3 muda TODO frame (faces em toda parede/água + grid off) → segunda e
ÚLTIMA parede inteira prevista no ciclo: **um sweep FASE 1+2+3** ao fim
(o sweep FASE 1 em curso no worktree fica como evidência da FASE 1 sozinha).

## Staging

`src/app/tile_art.rb` · `src/app/renderer.rb` · `data/tiles.json` ·
`data/display.json` · `data/zones/camp.json` · `test/app/tile_art_test.rb`
· `test/core/tile_registry_test.rb` · `test/tools/import_ldtk_test.rb` ·
`tmp/_flow_bench.rb` → `tools/bench_flow_field.rb` · este draft.
