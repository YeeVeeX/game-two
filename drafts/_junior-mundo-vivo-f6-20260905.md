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

## Fila da FASE 6

6.2 sentinela `floor3_run` do musgo (tuner) + soak · 6.3 `dungeon_2` (torre
"A divisória", stairs no buraco central, cap 15→16) · 6.4 `dungeon_3` (B
espiral) · 6.5 `dungeon_4` (C portão + `serpent_boss`, cap →18) · 6.6
`basement_3` · 6.7 BRASA (4 andares, `ember_*` + `ember_boss`, cap →21) ·
6.8 D5 (palavra dos peers).
