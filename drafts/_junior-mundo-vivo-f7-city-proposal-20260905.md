# MUNDO VIVO — FASE 7: ZONE 7 → CIDADE — PROPOSTA (não executada; ratificação dos DOIS peers)

**Por que proposta e não código:** a cidade toca o SAVE VIVO do Gabriel
(19 sessões: `(zone_7, [x,y])` de selo/estação/transição mudam de
coordenada → migração L9, D8) e é o desenho dele ("cardinal-crossroads
sketch"). Lei do repo: o dev propõe, os peers fecham; save-chain nunca é
cobaia. Tudo abaixo está pronto pra virar ticket na hora que os dois
disserem "vai".

## D1 — escala: **2× (88×56)** — decidido por NÚMERO (FASE 3 spike)

`flow_field.recompute!` por âncora (roda quando um inimigo muda de tile):
1× 2.8 ms · **2× 11.3 ms** · 3× 26.8 ms · 4× 49.3 ms (`tools/bench_flow_field.rb`).
Orçamento do tick 16.6 ms. Hub SAFE sem spawns = custo ~0 em jogo; com
**pátio de treino (D6)** vivo, 3×/4× estouram. **2× cabe com folga;
3× só com BFS limitado por raio** (ticket de SIM próprio, `world.rb` cap
1800 → extração owed). Draw (culled) não escala com o mapa: p95 8.4 ms
no pior caso hoje.

## Planta 2× (88×56) — a ZONE 7 atual é o quadrante NW, byte-preservado por OFFSET

```
   x: 0        22        44        66        88
y0 +---------+---------+---------+---------+
   | ZONE 7  | praça N | mercado | portão  |   ZONE 7 atual (44×28) fica em [0,0]:
   | ATUAL   | (poço   | placehol| ZONE 8  |   prado, casas, poço, banco, selo,
   | (offset | movido  | der (sem| (corda) |   buraco da torre, escadas dos
   | 0,0)    | ou não) | itens)  |         |   basements, boca da BRASA — tudo
y28+---------+---------+---------+---------+   nas MESMAS coordenadas (dx=dy=0).
   | cais →  | pátio de| praça S | bairro  |
   | ZONE 5  | treino  | (5      | leste   |   Novos quarteirões = regions com
   | (musgo) | (D6)    | entradas| (casas) |   intent próprio; entradas = 5
   |         | husk T0 | cardeais|         |   dungeons (torre N, BRASA S,
y56+---------+---------+---------+---------+   basements E, musgo W via cais,
                                               ZONE 8 NE) — cardinal sketch do Gabriel.
```

**Truque de migração:** crescendo o mapa pra E e pra S com a zona atual
fixa em `[0,0]`, **NENHUMA tupla existente muda** — `(zone_7,[33,14])`
(dreno do poço, breached no save do Gabriel) continua `[33,14]`. A
migração L9 vira **identidade** (D8: remap com dx=dy=0 = zero risco no
save vivo). O preço: o poço deixa de ser o "centro" geométrico (fica no
quadrante NW) — a praça CENTRAL da cidade é nova, em `[44..66, 28..56]`,
e a identidade `water_drained_by [33,14]` segue válida. Se os peers
preferirem o poço no centro exato: offset `(22,14)` → remap de 6 tuplas
(dreno, 2 escadas de basement, buraco da torre, boca da BRASA, way pro
musgo) + save migration testada em cópia — também pronto, custo maior.

## Quarteirões (regions com `intent`)

| Region | rect (2×) | intent | função |
|---|---|---|---|
| `town_1` (atual) | [23,1,20,26] | town | casas + poço + banco + selo (byte-igual) |
| `plaza_south` | [44,28,22,28] | town | praça das 5 entradas cardeais (placa por dungeon = `stations` decor) |
| `market` | [44,0,22,28] | town | mercado PLACEHOLDER (sem item system — PARKING_LOT) |
| `training_yard` | [22,28,22,28] | **training** (intent NOVO, whitelist em `tile_map.rb`) | husk T0 ×4, respawn longo; `safe:true` do hub NÃO cobre esta region (D6) |
| `east_ward` | [66,28,22,28] | town | casas (decor) + portão ZONE 8 movido pro NE? (hoje a corda sai do DUNGEON 1; a cidade pode ganhar um portão próprio = 2ª entrada da fronteira — decisão) |
| `quay` | [0,28,22,28] | town | cais → ZONE 5 (way atual `[1,14]` fica; o cais é ambiência: água + espuma + gotejar) |

## Ambiência (FASE 2, data-only)

Praça: `torch_flicker` ×12 · poço: `water_shimmer` (já) + `ripples` ·
cais: `water_shimmer` + `drips` · mercado: `dust_motes` + `light_shafts` ·
pátio: `dust_motes`. Tudo por `regions[].ambience` no sidecar
(`ambience_regions`, porta já aberta na FASE 2).

## Gates owed no ticket

`town_gates`, `multi_floor_descent`, `zone8_crossing`, `pilot_loop`
re-autorados (o hub é o coração de todo script que atravessa a cidade) ·
`rake map PROBES=1` (+ probes da praça/pátio) · soak `ZONES=zone_7` com
o pátio vivo · `rake perf` cenário cidade (o número do flow_field com 4
husks vivos) · Rule 2 em `town_gates`.

## Decisões pros peers (uma linha cada no hub)

- **D1**: 2× (recomendado, número) — ou 3× com o ticket do BFS limitado antes.
- **D8**: offset (0,0) = zero migração (recomendado) — ou poço no centro (remap de 6 tuplas).
- **D6**: pátio de treino sim/não (intent `training`, husk T0 ×4).
- **Portão ZONE 8 na cidade**: sim (2ª entrada da fronteira) / não (só pela torre).
- **Placa por dungeon na praça** (station decor, placeholder "DUNGEON N"): sim/não.

Execução estimada após o "vai": 1 sessão (tool `build_city.py` no padrão
do `build_brasa.py`, sidecar, regions, gates) + o sweep dos 4 scripts.
