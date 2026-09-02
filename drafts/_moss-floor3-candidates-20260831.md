# MUSGO — 3 candidatos pro piso -3 (2026-08-31, v2)

Etapa 2 da ordem do Junior (spec do swap:
`drafts/_swap-spec-medusa-to-dungeon1-20260831.md` §7.2). O escolhido
substitui o mapa antigo do boss como piso -3 PERMANENTE — fecha a
regressão de economia interim nomeada no spec §3. Descida temática
ratificada: raízes (-1) → mar (-2) → **MUSGO (-3)**.

**Histórico v1→v2→v3 (feedback do Junior, 2026-08-31, seat dele):**
v1: jardim de anéis + clareira REJEITADOS — "não gostei das duas de
cima... achei o mesmo conceito"; C (veias) aprovado ("é diferente").
Pedido: sala do boss AMPLA com POUCOS acessos → v2 (salão selado +
lago). v3: **A e C APROVADOS pelo Junior**; lago REJEITADO — pedido:
"sala de boss de videogame antigo: um labirinto e no final a sala do
boss" → B labirinto abaixo.

Gerador determinístico + validação BFS:
`drafts/_moss-candidates/build_moss_candidates.py` (iterar = mudar
parâmetro e re-rodar). Todos: entrada oeste (→ slow_door) + saída (→
ZONE 7, `requires_defeats: 1` como hoje) + posto do BOSS 1.
Fauna/spawns = ticket de aterrissagem (pacing table; alvo: clear ≥
vizinho -2, lei "deep pays more").

**Status: AGUARDA APROVAÇÃO DO GABRIEL** (palavra dele escolhe; 1 dos
3 ou re-rodada com ajustes).

## A — SALÃO SELADO (52x36, 797 tiles, BFS ✓)

Salões retangulares ligados por portas: entrada (oeste) → espinha
(corredor-salão N-S) → **O COFRE: sala do boss 15x17, a mais ampla do
jogo, com EXATOS 2 acessos** (corredor norte + corredor sul que
abraçam o vazio). O pedido do Junior executado literalmente.
Defesa: poucos acessos = a luta é PREPARÁVEL (escolhe a porta, fecha
a retirada — tática de cerco); a amplidão interna dá espaço de dodge
sem diluir o confronto. Gramática de salas+portas inédita nos pisos.
PNG: `drafts/_moss-candidates/A_salao_selado.png`

## B — LABIRINTO (62x28, 974 tiles, BFS ✓)

Maze old-school de verdade (recursive backtracker, seed 7,
determinístico; corredores 2-wide — dodge vivo), 3 becos re-ligados
em loop (braid — old-school sem frustração infinita), demais becos
preservados como becos (emboscada/recompensa). No fim, o corredor-
porta único → **sala clássica de boss: retangular 11x14, 4 pilares,
UMA porta — e a escada de saída ATRÁS do boss** (a transição pra
ZONE 7 já exige `requires_defeats: 1`: a saída só destranca com ele
morto, gramática exata de dungeon de videogame antigo).
Defesa: é a homenagem que o peer pediu, mecanicamente honesta — o
maze é conteúdo (navegação como desafio), a porta única faz a sala
do boss ser um COMPROMISSO (entrou, luta), e a saída atrás do corpo
fecha o arco.
PNG: `drafts/_moss-candidates/B_labirinto.png`

## C — VEIAS (56x36, 545 tiles, BFS ✓) — conceito já aprovado pelo Junior

Rede orgânica de veias de musgo escavadas na pedra maciça; loops
norte/sul, bolsão-emboscada no norte, câmara-coração a leste com o
boss.
Defesa: pressão de corredor, funil consciente até o coração; loops
(não becos) mantêm a lei do mundo JOINED dentro do piso. Densidade de
combate por tile mais alta dos três.
Lição T6b aplicada: bolsão norte re-ligado ao canal principal após o
BFS acusar 38 tiles órfãos na v1 (consertado, re-validado ZERO).
PNG: `drafts/_moss-candidates/C_veias.png`

## Fatos comparados

| | A salão selado | B labirinto | C veias |
|---|---|---|---|
| Tamanho | 52x36 | 62x28 | 56x36 |
| Tiles andáveis | 797 | 974 | 545 |
| Gramática | salas + portas | maze + sala clássica | funil orgânico |
| Sala do boss | AMPLA, 2 acessos | 11x14, 1 porta, saída atrás | coração, funil |
| Classe de luta | cerco preparável | navegação + compromisso | corpo-a-corpo denso |
| Landmark | o cofre | o maze inteiro | o coração |

**Status Junior (2026-08-31): A e C APROVADOS; B v3 (labirinto) é o
redesign do pedido dele — aguarda o olho dele.** Depois: trio pro
Gabriel escolher o que aterrissa no piso -3.

Recomendação do dev: **A** — executa o primeiro pedido do peer (ampla
+ poucos acessos) com a gramática que nenhum piso tem. B é a
homenagem old-school mais literal; C a pressão de corredor mais
densa. Os três agora são de famílias genuinamente diferentes.
