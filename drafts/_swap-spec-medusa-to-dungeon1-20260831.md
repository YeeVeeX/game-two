# SWAP SPEC — MEDUSA LOWER → DUNGEON 1 slot; mapa antigo volta ao piso -3 (2026-08-31)

Peer direction (Junior, seat dele, 2026-08-31): MEDUSA LOWER sai do
piso -3 e entra no lugar do DUNGEON 1; o mapa antigo do boss volta ao
piso -3 até o mapa de MUSGO (novo, a desenhar) ser aprovado; a torre
ganha +3 andares abaixo da MEDUSA LOWER. Concur do Gabriel
(WhatsApp, mesmo dia, verbatim es-CR): "Mi idea inicial era hacer una
torre al revés, con varios pisos hacia abajo hasta llegar al boss" —
este swap é a execução dessa torre. Prioridade dele: (1) swap, (2) 3
candidatos de musgo pro piso -3, (3) 3 andares × 3 ideias da torre.

**TIMING LAW:** NADA aterrissa antes do verdict da NINETEENTH (freeze
armado 2026-08-30, spec §8 congela data/balance + zones + seams; alvo
~2026-09-01). Este doc + candidatos são docs-only, legais na janela.
O swap = primeiro ticket pós-verdict, gates completos.

## 1. Os três movimentos

**M1 — piso -3 (low_quay) ← mapa antigo do boss.** Fonte recuperada
byte-exata do git (`3d8bb2a^:data/zones/low_quay.json`, md5
`cb74f970db47a907f8bc52008f46963f`, staged em
`drafts/_swap-staging/low_quay_OLD_boss_map.json`). 46x21, dois
salões ligados por 3 vãos; rusher ×22 (xp 15) + rusher_hater ×7 (25)
+ challenger [43,15] (120) — BOSS 1 volta pro salão de baixo. Delta
única sobre o byte-exato: chave `"floor": -3` adicionada (o god-view
pós-T7 agrupa por floor; delta NOMEADA aqui). Validado hoje: BFS do
pack_spawn alcança as 2 transições + os 30 spawns (ZERO inalcançável);
preview: `drafts/_swap-staging/old_boss_map_preview.png`.

**M2 — DUNGEON 1 ← geometria MEDUSA LOWER (52x52) adaptada.** O nome
interno `dungeon_1` e o display "DUNGEON 1" NÃO mudam (minimiza
migração — saves referenciam zona por nome). Adaptações:

- **Entrada** (hole da ZONE 7 [33,14], selo de 40 na cidade intacto):
  spawn aterrissa na cabeça da serpente `[10,8]` (o tile onde o
  slow_door entrava na medusa).
- **Volta**: rope_spot perto da cabeça → zone_7 spawn [33,16]
  (equivalente ao [3,16] atual).
- **Corda pra ZONE 8** (a fronteira, `requires_level: 8`):
  re-endereçada pra tile alcançável do braço leste da serpente
  (candidato inicial [46,25]; fixado no ticket com BFS). zone_8
  return-spawn re-aponta pro novo tile. `zone8_crossing` re-gated.
- **Selo interno [17,2]→[18,2]: MORRE** com a geometria antiga →
  migração L9 (§2).
- **Buraco central [33,25]: INERTE nesta etapa** (marcador visual).
  Vira a escada pro andar 2 quando dungeon_2 existir — um pedaço
  gated por vez. O D-HOLE (T7) é REVERTIDO por esta ordem: o fundo
  da torre deixa de ser o boss do piso -3.
- **Fauna**: stinger ×24 + warden ×5 migram COM a geometria.
  **SEM challenger** — BOSS 1 não duplica (fica na ZONE 5); a torre
  ganha boss próprio no FUNDO (andar 4) em ciclo futuro.
  [DECISÃO ABERTA pros peers; recomendação: sem boss duplicado —
  duas arenas de BOSS 1 = defeats farmável duplo.]
- **floor**: dungeon_1 mantém `-1`; andares futuros da torre: -2/-3/-4.

**M3 — linhas de retorno restauradas** (2 linhas, 1 por arquivo):
zone_7→low_quay spawn `[24,50]` → `[43,19]` (valor pré-T7);
slow_door→low_quay spawn `[10,8]` → `[2,4]` (valor pré-T7).

## 2. Migração de save (L9)

Saves vivos podem ter o breach `(dungeon_1, [18,2])` — o decoder
estrito RECUSA tuple que não resolve (`save breached: X is not a seal
in Y`, save_state.rb). Mecanismo (precedente P8, one-hop lane):
valida sob regras atuais, **DROPA o tuple órfão exato
`(dungeon_1, [18,2])` com linha de log nomeada**, re-encoda. Sem
reembolso dos 40 (a porta serviu sua era) [DECISÃO ABERTA;
recomendação: sem reembolso]. Testes em save SCRATCH com tuple
forjado — o save real dos peers NUNCA é cobaia; upgrade acontece na
primeira carga pós-swap na máquina de cada um. Backup law (`.bak-<ts>`)
já existe no caminho `--fresh`; o ticket decide se a migração também
faz backup antes de re-encodar (recomendação: SIM).

## 3. Economia interim (regressão NOMEADA)

Piso -3 volta a pagar rusher 15 / hater 25 / challenger 120 → clear
~578 xp vs 2010 da medusa. A banda 13→15 fica mais lenta ATÉ o musgo
aterrissar (o musgo é a correção permanente). L5 segue satisfeito: os
24 stingers (65) + 5 wardens (90) continuam existindo — mudaram de
endereço (dungeon_1, alcançável na ZONE 7 a pack level 6 + selo de
40), não sumiram do mundo. Nenhum número de balance muda neste swap.

## 4. Consequências de wall (custos nomeados)

- `floor3_run` → RETIRED (coreografia era da medusa na ZONE 5).
- `varekka_duel` + `burn_duel` (retired) → **TENTATIVA DE REVIVAL**:
  foram autorados na geometria antiga que volta; replay verde =
  dívida de coreografia fechada DE GRAÇA. Se vermelho, re-author
  (dívida já existente, não nova).
- `dungeon_fork` + `multi_floor_descent` + `zone8_crossing` →
  re-gate; re-author onde a coreografia morrer (geometria do
  dungeon_1 mudou por inteiro).
- Canaries esperados byte-idênticos: `world_loop`, `floor1_run`,
  `floor2_run`, `town_gates`.
- Map probes: re-pin ZONE 5 (void→ripple antigo) + DUNGEON 1 (void
  novo) — custo nomeado do ticket.

## 5. Gates do ticket de aterrissagem

Suite + boot · Rule 2 gate nos scripts novos/revividos · canaries ·
map probes + critique · soak `ZONES=low_quay,dungeon_1` · teste de
migração em scratch (tuple forjado → drop nomeado → load verde) ·
language critique N/A esperado (zero strings novas).

## 6. Aprovações

- Junior: ordem dada + interpretação confirmada ("isso ai",
  2026-08-31) ✓
- Gabriel: concur da torre (WhatsApp) ✓; **ratificação formal owed
  no hub chat antes de aterrissar**: (a) reversão D-HOLE, (b) selo
  interno do dungeon_1 morre + migração drop-sem-reembolso, (c) BOSS
  1 não duplicado (torre ganha boss próprio no fundo, ciclo futuro).

## 7. Sequência pós-verdict

1. Ticket SWAP (M1+M2+M3 + migração + gates) — sessão fresca, CLAIMED.
2. Musgo -3: candidato aprovado pelo Gabriel entra no lugar do mapa
   antigo (ticket próprio, mesma classe de gates).
3. Torre: andares 2/3/4 aterrissam UM POR TICKET (lei: um pedaço
   gated por vez), cada um com o desenho aprovado dos 3×3 conceitos.
