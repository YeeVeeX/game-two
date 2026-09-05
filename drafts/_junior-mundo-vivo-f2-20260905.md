# MUNDO VIVO — FASE 2: ambiência (mapas VIVOS) — Junior seat, 2026-09-05

**FREEZE: liberado** (verdict s125). **CLAIMED:** FASE 2 (branch
`junior/mundo-vivo`, sobre a FASE 1 `5be2558`). Classe: presentation
pura (SAFE — "region ambience" já era vocabulário SAFE do AGENTS.md);
lane G executa por consequência do verdict.

## O que existe agora

- **`src/app/ambience.rb`** — `App::Ambience::Scene`: fontes memoizadas
  por mapa (função pura de zone config + registry), culling pelo
  `Renderer.rect_visible?`, desenho entre decor e transições (sob
  atores e sob o tint ambiente). **Tick-driven por lei:** toda animação
  = f(`world.frame`, seed FNV-1a da fonte, preset). Seno inteiro em
  tabela (64 entradas) — zero `Math.sin` em tempo de draw, zero
  `milliseconds`, zero `rand`. Envelope por curva (`rise`/`fall`/`flat`/
  `pulse`), wobble, drift, flicker 2-cores, `count`/`spread` por camada.
- **`data/ambience.json`** — 13 presets: `water_shimmer, bubbles,
  ripples, torch_flicker, fire, ember_sparks, lava_glow, grass_sway,
  moss_sway, spore_drift, fog_bank, drips, dust_motes, light_shafts`
  (DSL de camadas rect/band/tri/spark).
- **Três portas de dados** (zero código por zona):
  (a) `data/tiles.json` — tipo `water` ganhou `ambience: water_shimmer`
  (density 0.6) → **toda água de toda zona** tremula;
  (b) `regions[].ambience` (+ `ambience_density`, `ambience_tiles`) —
  **piloto piso -2 submerso (lane G):** `submerged_plain` bolhas 10% em
  todo o chão + `reef_drips` gotejar 30% na ruína;
  (c) `decor[] {kind: "ambience", preset}` — **ZONE 7: 10 tochas** nas
  paredes da praça do poço + pilares das casas (halo quente pulsando,
  chama tri com flicker, faíscas subindo).
- **Lei do caminho de edição respeitada:** `district_two` e `zone_7`
  são emissões do importer → NUNCA editados à mão. `tools/import_ldtk.rb`
  ganhou a chave de sidecar `ambience_regions` (anexa às Region
  entities do LDtk — mesma carta D2 do `decor`); os sidecars
  `authoring/district_two.sidecar.json` (+2 regions) e
  `authoring/zone_7.sidecar.json` (+10 decor) foram editados e
  re-emitidos; `test/tools/pilot_authoring_test.rb` (byte-pin) verde.
- **Registro/mapa:** `tile_registry.rb` aceita `ambience`/
  `ambience_density` (OPTIONAL keys); `tile_map.rb#normalize_region`
  carrega os riders; `zone_identity.rb` aceita `kind: "ambience"`
  (fonte animada, nada estático).
- `display.json`: `ambience: true` (switch de perf/debug).
- **`test/app/ambience_test.rb`** — 8 testes: presets bem-formados,
  envelope limitado em toda curva/fase, seed estável, fontes puras
  (dois loads idênticos), pilotos respiram (bubbles>50, drips>=3,
  10 tochas, poço tremula), switch desliga, riders sobrevivem à
  normalização, **e fontes idênticas ENTRE PROCESSOS** (subprocesso
  real).

## Bug pego pelo gate (recorded)

`floor2_run` v1: **frame_0000 não-determinístico** entre as duas
metades do gate. Causa: `r[:id].to_s.hash` no seed de região — Ruby
saltea `String#hash` POR PROCESSO. Trocado por FNV sobre
`"#{zone}/#{id}"`; teste cross-process novo torna a lei mecânica
(o mesmo furo que o TileVariants documentava desde o T3).

## Evidências

| Prova | Resultado | Caminho |
|---|---|---|
| Suite | **1364 runs, 0 failures** (inclui byte-pin do importer) | hooks |
| Determinismo `floor2_run` (piloto -2) | **10/10 byte-idênticas** ×2 (após o fix) | `captures/floor2_run_gate_*` |
| Determinismo `town_gates` (tochas) | **6/6 byte-idênticas** ×2 | `captures/town_gates_gate_*` |
| Frames lidos | bolhas subindo com fade + shimmer na água + gotejar na ruína (piso -2); halo/chama/faíscas nas 10 tochas + shimmer no poço (ZONE 7) — tudo SOB atores/portas | `tmp/f2_zoom.png`, `tmp/z7_zoom.png` |
| Rule 2 (crítico) `floor2_run` · `town_gates` · `zone8_crossing` | *(cadeia lançada; verdicts colados ao fechar)* | `tmp/wall/fase2_*.log` |
| Tick-driven grep | `milliseconds\|Time.now\|rand(` em ambience.rb = só no comentário da lei | — |
| Perf | *(rake perf + frame probe colados ao fechar)* | — |

## Custo de re-pin (nomeado)

Zonas com ambiência nova: `district_two` (floor2_run, multi_floor_descent),
`zone_7` (town_gates, dungeon_fork, multi_floor_descent, zone8_crossing…)
e toda zona com água (`~`: zone_7, district_two, zone_8, slow_door?).
A parede inteira já está sendo re-pinada pela FASE 1 (worktree) — a
FASE 2 entra na MESMA janela: um segundo sweep ao fim (FASE 1+2 juntas),
não dois.

## Staging

`src/app/ambience.rb` · `src/app/renderer.rb` · `src/app/window.rb` ·
`src/app/zone_identity.rb` · `src/core/tile_map.rb` ·
`src/core/tile_registry.rb` · `harness/scenes/world_scene.rb` ·
`tools/import_ldtk.rb` · `authoring/district_two.sidecar.json` ·
`authoring/zone_7.sidecar.json` · `data/zones/district_two.json` ·
`data/zones/zone_7.json` · `data/ambience.json` · `data/tiles.json` ·
`data/display.json` · `test/app/ambience_test.rb` ·
`test/game/zone_identity_data_test.rb` · este draft.
