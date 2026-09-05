# MUNDO VIVO — FASE 6: grafo de dungeons — Junior seat, 2026-09-05

**FREEZE: liberado** (s125). **CLAIMED:** FASE 6 (branch `junior/mundo-vivo`).
Lei: **um andar por ticket**, com fauna da família, gates, pacing, `rake map
PROBES=1`, soak. Ordem do plano §7: swap → musgo → torre 2/3/4 → basement_3
→ BRASA → D5.

## Ticket 6.1 — O SWAP (+ musgo A direto no piso -3)

Spec: `drafts/_swap-spec-medusa-to-dungeon1-20260831.md` (Junior "isso aí";
Gabriel concur da torre no WhatsApp; 3 ratificações formais dele owed —
listadas no spec §6). **Decisão de execução (dev, recorded):** o "mapa
antigo interino" do spec (M1) foi PULADO — ele só existia porque o musgo
ainda não estava desenhado; com os candidatos A/C aprovados pelo Junior,
o musgo A entra DIRETO no piso -3 (uma re-gate da ZONE 5 a menos; a
regressão de economia interim do spec §3 nunca existe).

**Ferramenta:** `tools/swap_medusa_to_dungeon1.py` — determinística,
idempotente (recusa rodar 2×), registry-driven, BFS em toda chegada/
porta/spawn, edita SÓ `authoring/pilot.ldtk` + 2 sidecars (LDtk = verdade
espacial; `data/zones` re-emitido pelo importer, a única porta).
Desvios impressos e recorded:

- **DUNGEON 1 ← MEDUSA LOWER (52×52)**: chegada do buraco da ZONE 7 na
  cabeça da serpente `[10,8]`; corda de volta `[9,8]` → zone_7 `[33,16]`;
  **corda pra ZONE 8 re-endereçada `[29,4]` → `[29,7]`** (`[29,4]` é
  parede nesta geometria; `[29,7]` = andável mais próximo na borda norte
  da cabeça); **selo interno `[17,2]→[18,2]` MORRE**; buraco central
  INERTE (a escada pro andar 2 aterrissa com `dungeon_2`); fauna
  stinger×24 + warden×5 migram COM a geometria; **challenger NÃO** (BOSS 1
  não duplica — a torre ganha boss próprio: `serpent_boss`, FASE 5).
- **ZONE 5 ← MUSGO A "salão selado" (52×36)**: porta oeste `[1,18]` →
  slow_door (chegada 1 tile dentro, `[2,18]`); porta sul `[24,34]` →
  zone_7 `requires_defeats: 1` (chegada `[24,33]`); **BOSS 1 no cofre
  `[41,18]`** (15×17, 2 acessos); piso = tipo `moss` (FASE 3) com bolsões
  de `.`; fauna **spore_a ×14 + spore_b ×9** (FASE 4.5) → clear **1955 xp
  > 1780 do -2** (L6); `drop_gradient` 3.0/3.5/4.0 (hall/espinha/cofre);
  sidecar: paleta musgo, 4 tochas no cofre, `spore_drift` 6% + `light_shafts`
  no cofre (FASE 2).
- **Linhas de retorno**: zone_7→dungeon_1 spawn `[15,3]→[10,8]` e
  zone_7→low_quay `[24,50]→[24,33]` (emissão do pilot.ldtk move
  exatamente essas linhas); `slow_door.json` (hand) `[10,8]→[2,18]`;
  `zone_8.json` `[29,4]→[29,7]` — **byte-pin do intake movido
  CONSCIENTEMENTE** (`worldsmith_intake_test` `89ba053f…→fc7ccfc8…`,
  mesmo commit, 1 linha).
- **Migração L9 (save):** `Game::SaveState::RETIRED_SEALS =
  [["dungeon_1",[18,2]]]` + `migrate_retired_seals!` roda no envelope
  ANTES do decoder estrito (`SaveStore#load`); tupla nomeada é DROPADA com
  notice ("no refund"); lista nomeada, nunca wildcard; idempotente. Saves
  vivos com o selo antigo pago carregam limpos na primeira sessão pós-swap.
- **Bug pego ao vivo:** v1 do tool fazia porta = chegada (`[1,18]`) → o
  pack pousava e o gate disparava DE VOLTA no mesmo tick (ping-pong). A
  medusa evitava por 1 tile; agora toda chegada fica a 1 tile da porta
  (regra no tool, testes provam a travessia nas 2 direções).

**Parede / canary / probes (custos nomeados):** `floor3_run` (coreografado
na medusa em ZONE 5) → `harness/retired/`, stream preservado em
`F6_RETIREMENT`; `ACTIVE` = só `world_loop` (byte-UNCHANGED — asserted)
até o sentinela do musgo ser autorado pelo tuner (próximo ticket);
`rake map PROBES=1` **21/21** re-pinado (dungeon_1: void/cabeça/corda
`[9,8]`/frontier slab `[29,7]`; low_quay: musgo/cofre/posto/porta sul);
`dungeon_fork` determinismo 6/6 (crítico + `multi_floor_descent` +
`zone8_crossing` = re-gate na parede 1+2+3+6).

**Testes adaptados à geometria nova (o que cada um pina agora):**
`low_quay_test` (52×36, âncora `[1,18]`, fauna spore, clear > -2, bandas
hall/espinha/cofre) · `challenger_test` + `dread_test` (posto `[41,18]`,
stance fora de alcance recua pra espinha) · `zone_tier_test` (lê o kit
REAL da primeira fila — lei aditiva do tier) · `open_gate_composition`,
`tile_registry_test`, `pilot_loop_test`, `worldsmith_intake_test`
(portas/chegadas novas) · `interior_door_test`: os 2 testes do fork
viraram **prova da aposentadoria + da migração L9**.

| Prova | Resultado |
|---|---|
| Suite | **1397 runs, 43232 assertions, 0 failures** (byte-pin do importer verde) |
| `rake map PROBES=1` | **21/21 PASS** — god-view mostra a serpente em DUNGEON 1 e o salão selado em ZONE 5 |
| Determinismo `dungeon_fork` | 6/6 byte-idênticas ×2 |
| Rule 2 crítico (`dungeon_fork`, `town_gates`, `multi_floor_descent`, `zone8_crossing`) + sentinela do musgo + soak `ZONES=low_quay,dungeon_1` | *owed: cadeia lançada após o commit; sweep 1+2+3+6 antes do merge* |

## Ticket 6.3 — `dungeon_2` (torre andar 2 = padrão A "divisória") + cap 15→16

**Ferramenta genérica:** `tools/build_tower_floor.py <n> [--down]` — n=2/3/4
= padrões A/B/C (`drafts/_medusa-tower/build_tower_candidates.py`, agora
importável); splice do level `dungeon_<n>` no `pilot.ldtk` + sidecar,
idempotente (rebuild determinístico); liga o andar de CIMA com
`stairs_down` no tile de saída dele (dungeon_1 = buraco central `[33,25]`);
`--down` liga este andar ao de baixo quando ele existir. **Leis mecânicas
no tool:** rocha fora do anel = `%` (2ª classe de parede), muralha = `#`,
piso = `.`; chegadas a 1 tile de toda porta (ping-pong law); BFS
chegada→escada; **ratio da volta forçada impresso e recusado se < 1.8**.

- **dungeon_2**: 52×52, floor -2, "DUNGEON 2". Porta de cima `[28,44]`
  (stairs_up → dungeon_1 `[33,24]`, livre); chegada `[29,44]`; escada de
  descida `[33,22]` (INERTE até dungeon_3). **Volta forçada: real 59 vs
  Manhattan 27 = 2.19×** (a mecânica do T da Medusa Tower, pinada em
  teste). dungeon_1 ganhou `stairs_down` `[33,25]` → dungeon_2 `[29,44]`
  **`requires_level: 8`** (proposta: 8/10/12 nos andares 2/3/4 — a
  fronteira já pede 8).
- **Fauna (serpent, tier ≤ 3):** stinger ×8 · warden ×4 · serpent_a ×10
  · serpent_b ×5, distribuídas por bandas de distância da chegada (fraco
  → forte), Chebyshev ≥ 2 entre spawns. **Clear 2055 > dungeon_1 2010**
  (L6). Sidecar: pedra cinza / muralha ferrugem / rocha escura,
  `drop_gradient` 3.5/4.0/4.5, 8 tochas nas paredes internas, `dust_motes`.
- **Cap 15→16** (L5 riding o andar; `pacing_table.rb` bancado: E(16) =
  46000, ΔE 8480 ≈ 566 kills de stinger ≈ 4.1 clears do andar 2).
- **`test/game/tower_floor_test.rb` (7)** — tabela por andar (cresce com
  6.4/6.5): forma/profundidade · **tudo andável dentro do anel e
  alcançável; fora = rocha** · **volta forçada ≥ 1.8×** · escadas nos 2
  sentidos, gate só na descida, chegadas a 1 tile e passáveis ·
  fauna = censo autorado e clear > andar de cima · **descer da medusa
  aterrissa ao lado da escada e o pack FICA** (anti ping-pong ao vivo) ·
  cap 16. Pins atualizados: `tile_registry_test` (edge ratificado
  dungeon_1↔dungeon_2), `tile_map_test` (15 zonas), `map_artifact_test`
  (DUNGEON 2 no god-view), `interior_door_test` (3 ways no dungeon_1),
  `pilot_authoring_test` ZONES += dungeon_2.

| Prova | Resultado |
|---|---|
| Suite | **1404 runs, 47911 assertions, 0 failures** |
| `rake map PROBES=1` | 21/21 · god-view mostra a torre redonda com a divisória (fiel ao shot) |
| FASE 6.1 gates (cadeia) | `dungeon_fork` **GATE PASS** (manifest `seal_breached` FAIL = **esperado**: o selo foi aposentado — script owed re-author) · `multi_floor_descent` **GATE PASS + MANIFEST PASS** · zone8_crossing + soak: em curso |

## Tickets 6.4 + 6.5 — `dungeon_3` (B espiral) + `dungeon_4` (C portão-pedágio, o FUNDO com BOSS 2) + cap →18

Mesmo tool (`build_tower_floor.py 3` · `4` · `2 --down` · `3 --down`):
a torre inteira está LIGADA — zone_7 hole → DUNGEON 1 (medusa) → `[33,25]`
stairs (lvl 8) → DUNGEON 2 → `[33,22]` stairs (lvl 10) → DUNGEON 3 →
`[34,27]` stairs (lvl 12) → **DUNGEON 4 = o fundo** (sem descida; a
"escada" do padrão C vira piso comum). Voltas livres em toda escada.

| Andar | Padrão | Volta forçada (real/Manhattan) | Fauna | Clear xp |
|---|---|---|---|---|
| DUNGEON 1 | medusa (serpente) | — | stinger 24 · warden 5 | 2010 |
| DUNGEON 2 | A divisória | **59/27 = 2.19×** | stinger 8 · warden 4 · serpent_a 10 · serpent_b 5 | 2055 |
| DUNGEON 3 | B espiral | **71/25 = 2.84×** | stinger 6 · warden 4 · serpent_a 8 · serpent_b 8 · serpent_c 4 | 2382 |
| DUNGEON 4 | C portão-pedágio | **56/20 = 2.80×** | warden 4 · serpent_a 6 · serpent_b 8 · serpent_c 8 · **serpent_boss (BOSS 2)** @ `[25,13]` (a ponta mais longe da chegada, dist ≥ 40) | 2434 |

**L6 monotônico no grão do clear** (2010 < 2055 < 2382 < 2434) e no grão
do kind (tier ≤ n+1 por andar). **Cap 15 → 18** em três degraus (16/17/18
riding 2/3/4, plano §6; `pacing_table.rb`: E(18) = 66640, ΔE(18) = 10960 ≈
731 stingers ≈ 4.5 clears do andar 4). Rungs 8/10/12 monótonas, a primeira
= a da fronteira (recorded: proposta ajustável pelos peers).

**Testes (`tower_floor_test.rb`, 9):** a tabela FLOORS cobre os 3 andares
— cada lei verificada em cada andar; + **o fundo tem BOSS 2 (3 fases) na
ponta da volta e nenhuma escada adiante** + rungs monótonas. Pins: 17
zonas, god-view com DUNGEON 1–4, edges ratificados 1↔2↔3↔4, pilot ZONES.

| Prova | Resultado |
|---|---|
| Suite | **1406 runs, 57717 assertions, 0 failures** |
| `rake map PROBES=1` | 21/21 · god-view: serpente → divisória → espiral → portão (os 3 desenhos do Junior, ordem que ele aprovou "A=2, B=3, C=4") |
| Rule 2 + soak da torre | owed: `tower{2,3,4}_run` (tuner, ticket 6.2) + `rake soak ZONES=dungeon_2,dungeon_3,dungeon_4` |

## Fila da FASE 6

6.2 sentinelas (tuner): musgo `floor3_run` + `tower2_run` · re-author `dungeon_fork` (selo aposentado) · 6.6
`basement_3` · 6.7 BRASA (4 andares, `ember_*` + `ember_boss`, cap →21) ·
6.8 D5 (palavra dos peers).
