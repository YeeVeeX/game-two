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
| Rule 2 `town_gates` (10 tochas + poço) | **GATE PASS** (det 6/6 + vision PASS; manifest zone_entered=4) | `tmp/wall/fase2_town_gates.log` |
| Rule 2 `zone8_crossing` (água de ZONE 8 via tiles.json) | **GATE PASS** (det + vision). Manifest FAIL `body_regrown`/`tribute_paid` = **pré-existente** (census T6b/T7: "9 fails … basement_pocket, vat_economy, zone8_crossing, zone_catchup" — eventos de SIM, inalcançáveis por presentation) | `tmp/wall/fase2_zone8_crossing.log`; `drafts/_v20-t7-floor3-20260830.md` §369 |
| Rule 2 `floor2_run` (piloto -2) | vision FAIL `floor2_channel_reads` ("no second coral wall color visible") — **flip**: pixels de parede byte-idênticos aos quads (coral tinted `143,75,40` = 3064 amostras vs rocha `113,68,49` = 2526 no frame 2100; a ambiência não desenha sobre `#`/`%`); check passou 3/3 em runs anteriores. Manifest PASS (actor_died=26 fight_resolved=6). → re-run na parede | `tmp/wall/fase2_floor2_run.log`, `tmp/f2_full.png` |
| Tick-driven grep | `milliseconds\|Time.now\|rand(` em ambience.rb = só no comentário da lei | — |
| Perf (draw A/B, `GAME_FRAME_PROBE=1`, bot 900 ticks, máquina do Junior) | **ZONE 7:** ON `draw{p50=2.6 p95=5.0}` vs OFF `draw{p50=2.2 p95=4.5}` (+0.4/+0.5 ms) · **piso -2 (piloto):** ON `draw{p50=1.6 p95=5.1}` vs OFF `draw{p50=1.1 p95=2.9}` (+0.5/+2.2 ms). Orçamento 16.6 ms; `over35=0` em todos. Sprites+ambiência custam <1 ms p50 | `tmp/perf_on_z7.log` (ON = art+ambience; OFF = display `art_enabled:false, ambience:false`) |

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
