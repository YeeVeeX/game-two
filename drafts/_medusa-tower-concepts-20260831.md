# TORRE DA MEDUSA — 3 andares soterrados, padrões Tibia (2026-08-31, FINAL)

Etapa 3 da ordem do Junior (spec do swap:
`drafts/_swap-spec-medusa-to-dungeon1-20260831.md` §7.3). A torre
invertida do Gabriel: MEDUSA LOWER (pós-swap = DUNGEON 1, andar 1) →
3 andares abaixo, descendo pelo buraco central da serpente. Andares
aterrissam UM POR TICKET pós-verdict (lei: um pedaço gated por vez).

**APROVADO-J (2026-08-31, seat dele, verbatim):** "entendi, eu gostei
dessas 3 pode mandar" — o trio A/B/C fecha os 3 andares. Atribuição
default (dev, ratificável): **A = andar 2 · B = andar 3 · C = andar
4**. Aguarda: palavra do Gabriel (montagem
`drafts/_medusa-tower/TORRE_3_ANDARES.png` segue pra ele via peer).

## A direção que moldou tudo (iteração com o peer, mesma sessão)

1. Conceitos genéricos (tentáculos/catacumbas/fendas) → REJEITADOS
   ("quero copiar como é a medusa tower do tibia").
2. Torres geométricas limpas → REJEITADAS ("muito simples...
   não fique preso somente em redondo e quadrado, faça umas partes
   soltas").
3. Réplica orgânica + partes soltas → anel corrigido pra REDONDO
   ("o entorno pode ser redondo igual a medusa tower").
4. Interior = molde do quartinho → REJEITADO (faltava a mecânica:
   "tem uma parede grande que separa a entrada e a saída forçando o
   player a fazer toda a volta passando pelos inimigos").
5. Grama em volta → CAVERNA ("é para baixo da terra").
6. **Lei final do desenho:** "todo o mapa acessível tem que estar
   dentro do círculo, o resto tem que ser inacessível; quero que a
   volta seja maior internamente da porta que entra para a porta que
   sai" + "copie exatamente igual a linha vermelha" (transcrição, não
   interpretação).

## Os 3 andares (todos: rocha inacessível fora do círculo, muralha
## em ruína — estética escolhida — e volta forçada medida por BFS)

| Andar | Padrão | Fonte Tibia | Volta (reta→real) |
|---|---|---|---|
| **2** | **A DIVISÓRIA** — o "5" (espora N + topo + lateral + barra meio) + divisória colando na muralha sul + bolso "1" com a escada | piso -1 (`referencia_tibia_parede_divisoria.png`) | 27 → **59** |
| **3** | **B ESPIRAL** — espiral retangular: vertical+pé, topo, queda direita, barra do meio, queda interna, barra de baixo selando a leste | piso +1 (`referencia_tibia_linha_exata.png`), **escolha explícita do Junior ("a B deixa como está")** | 25 → **71** |
| **4** | **C PORTÃO-PEDÁGIO** — sala central de 2 portas + espora N + selo SW: o disco parte em duas metades, a ÚNICA ponte é através da sala | padrão novo na mesma gramática de linha reta | 20 → **56** |

Marcadores: dourado = entrada (chegada do andar de cima) · laranja =
escada pra baixo (no andar 4 vira o POSTO DO FUTURO BOSS da torre —
não existe andar 5; decisão espelhada no spec do swap §1) · amarelo =
pontos de loot (viram baú/item/elite no ticket — decisão de
recompensa, não de geometria).

## Validação (gerador determinístico, re-rodável)

`drafts/_medusa-tower/build_tower_candidates.py` — BFS 4-adjacente:
alcançabilidade total (zero órfãos nos 3), volta = distância real
entrada→escada vs Manhattan. Bugs pegos pelo validador NESTA sessão
(nunca por olho): colmeia v1 com 522 órfãos (escada diagonal não
conecta em 4-adj — carve ganhou tile-ponte), criptas v1 furando arco
(volta 150→108), divisória v1 parando 1 tile antes da muralha (volta
59→27 vazada).

## Referências Tibia banked (md5)

- `referencia_tibia_medusa_tower.png` `4d006217b16e34ef302ed5d2b1c17eda`
- `referencia_tibia_interior.png` `eb06fa3262eae756b8592d75273bc668`
- `referencia_tibia_parede_divisoria.png` `1c5fb8c577435a05f2eb761ac84eb0bd`
- `referencia_tibia_linha_exata.png` `273b9ac2dc75f7b9526989274d694ef3`
- ampliações de leitura: `_ref_divisoria_5x.png`, `_ref_linha_exata_6x.png`

## Superseded (mantidos no repo pra história, fora do plano)

Conceitos pré-direção-Tibia: F3 ninho/galeria/colmeia + F4
arena/sino/santuário (PNGs `ANDAR_3.png`/`ANDAR_4.png` da leva 1) e
as levas intermediárias do andar 2. A torre inteira agora fala o
padrão Tibia do peer.

## Sequência de aterrissagem (pós-verdict, inalterada)

1. Ticket SWAP (medusa lower → DUNGEON 1 + mapa antigo volta ao -3).
2. Musgo -3 (Gabriel escolhe entre A salão/B labirinto/C veias).
3. Torre: andar 2 → 3 → 4, um ticket cada, fauna+pacing por ticket.
