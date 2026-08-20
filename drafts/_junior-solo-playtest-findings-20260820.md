# Junior — achados de playtest SOLO (2026-08-20) + corroboração na telemetria

**Sessão:** solo, `GAME_FRAME_PROBE=1`, log `game_two_session_836781.log`, fim 18:56:52.
**Enquadramento permanente dele (vale aqui também):** relato e opinião **não são lei**;
qualquer mudança depende da validação do Gabriel.
**Status:** achado de playtest HUMANO (não é bot, não é ritual — o v18 já fechou).

## Relato do Junior, VERBATIM

> jogar sozinho con squad de maquinas é impossivel, tive um melhor desempenho jogando
> apenas com 1 personagem do que com os 3. os bots aliados alem de se matarem luram
> todos os bixos tornando impossivel o combate. quando jogo sozinho apenas com 1
> personagem posso escolher por onde vou e quais bixos vou lurar, tendo um progresso
> mais estrategico e com melhores resultados, sem gastar moedas conseguindo uma melhor
> economia. consegui matar o boss, só na consigo avançar mais pq a ultima sala de
> "espera" nao tem como depositar o dinheiro, entao tenho que voltar duas salas para
> depositar as moedas.

---

## CORREÇÃO DO JUNIOR (mesma noite, depois de eu já ter enviado) — VERBATIM

> deixa eu corrigir algumas coisas antes de voce mandar. eu usei somente 1 personagem no
> inicio para fazer economia mas depois de ter dinheiro eu usei todo o squad para
> conseguir passar para a sala do boss usando meus aliados como distração, depois na
> ultima sala do boss eu usei meus aliados a meu favor para derrotalo e limpar a sala,
> tendo bastante dinheiro nao tem problema em revivelos a todo momento. eu notei que o
> aliado que bate de longe está com uma inteligencia de sair de perto do minion para
> atacar entao isso é otimo, na minha visao o problema esta quando o minion entra no
> raio de visao deles e eles saem correndo para cima para atacar. o fix do ctrl+setas
> seque desativado.

**O que esta correção faz com o que está escrito abaixo (leitura do assento, marcada):**

1. **RETIRO a caracterização "a IA é NEGATIVA".** Usar um corpo só foi **fase inicial
   por economia**, não conclusão sobre o jogo: com dinheiro ele usou **o squad inteiro
   de propósito** — aliados como **distração** para chegar à sala do boss e como
   ferramenta para derrotá-lo e limpar a sala ("tendo bastante dinheiro nao tem problema
   em revivelos a todo momento"). Ou seja, os aliados funcionam como **recurso comprável**
   (paga-se revive, ganha-se distração/tanque). A premissa do pack de três **não** está
   invertida. Onde o texto abaixo diz o contrário, vale esta correção.
2. **RETIRO o argumento dos `first_special=never`.** Nunca acionar o *special* de um
   corpo **não** prova que o corpo não foi usado — ele usou os três. Erro de inferência
   meu; mesma classe do caso "confundi as palavras". Regra reforçada: telemetria
   agregada não prova intenção de jogo; o jogador prova.
3. **O achado real fica MAIS PRECISO, e o escopo ENCOLHE:** o recuo do aliado de alcance
   existe e ele **elogia** ("sair de perto do minion para atacar... isso é otimo").
   O problema é de **aquisição**, antes disso: *"quando o minion entra no raio de visao
   deles e eles saem correndo para cima para atacar"* — que é exatamente o achado (f)
   do diagnóstico já bancado: `aggro_tiles: 10` igual para todo o kit, então um corpo
   de alcance 6 sai correndo para fechar contato. Não é reescrever a IA: é **gatear a
   aquisição por kit** e/ou separar raio de visão de raio de aproximação.
4. **Ctrl + setas:** ele registra que "segue desativado". **Verificado no repo:** zero
   ocorrência de `Ctrl` em `data/bindings.json` e `src/core/input.rb`, nenhum intent de
   virar-parado em `src/` — **nunca foi implementado**, não foi desativado. Segue como
   Idea 1 do intake do v19 (`drafts/_junior-v19-ideas-20260819.md`, BANK), re-votada
   pelo dono ("nos faltó").
5. **CONTINUA valendo sem alteração:** o achado 2 (banco só em `camp`/`nest`,
   `low_quay` sem estação e beco sem saída, `quay banked_after{events=0 amount=0}`),
   o achado 3 (BOSS 1 morto — agora melhor explicado: caiu **com o squad usado de
   propósito**), e todos os números crus da telemetria (são log, não leitura).

---

## ACHADO 1 — leitura ORIGINAL do assento, agora CORRIGIDA pelo bloco acima

O que a R3 do ritual dizia: *"a IA morre muito, fica correndo pra dentro dos inimigos"*.
O que este relato acrescenta e **muda de grau**: com os três corpos o combate fica
**impossível**, e jogar com UM rende mais. Os aliados não só morrem — eles **atraem
todos os inimigos** ("luram"), tirando do jogador a escolha de rota e de quantos puxar
por vez. Isto não é "companheiro fraco": é **companheiro que subtrai**.

**Corroboração independente na telemetria da mesma sessão** (não é interpretação, são
as linhas do log):

| Linha | Valor | O que sustenta |
|---|---|---|
| `a2_fired body_deaths` | **28** | mortes de corpo em UMA sessão |
| `a2_fired wipes` | **11** | wipes completos do pack |
| `a2_fired retargets{lowhp=...}` | **220** | inimigos re-alvejando quem está com HP baixo — os aliados eram, repetidamente, o elo fraco |
| `a2_fired leashes` | **415** | leash disparando o tempo todo = corpos indo longe demais |
| `d1_fired carrying_deaths / carried_lost` | 6 / **2** | morreu carregando valor, perdeu 2× |
| `v13 whirl{casts=0}` | **0** | **nunca** usou o special do striker |
| `v14 first_special{striker=never, lobber=never, blocker=5267}` | — | **corroboração direta do relato:** ele jogou essencialmente UM corpo (o blocker) e nunca acionou os specials dos outros dois |

As duas últimas linhas são o ponto: a telemetria confirma, sem depender da palavra dele,
que ele **abandonou dois dos três corpos** — e ainda assim teve o melhor resultado da
sessão (matou o BOSS 1, ver achado 3).

**Leitura do assento (marcada como leitura, não é veredito):** isto atinge a identidade
central do jogo, não um número de balance. O pack de três é a premissa (`AGENTS.md`:
"you play a pack of three bodies"); se um corpo joga melhor que três, a premissa está
invertida na prática. Casa com o diagnóstico de código já bancado
(`_junior-work-split-offer-20260820.md` §4, achados a–d: `chase_step`/`surround_slot`
sem banda de distância por kit → o aliado fecha até ficar adjacente mesmo sendo o
lobber, cujo alcance é 6 tiles) e com o GAP de atribuição
(`_junior-ai-measurement-20260820.md`). **R-A3 segue CONGELADA por ordem do dono** —
este relato é insumo para o brainstorm do v19, não pedido de fix agora.

## ACHADO 2 — NOVO: não há banco nas zonas profundas (bloqueio de progressão)

Relato: *"a ultima sala de 'espera' nao tem como depositar o dinheiro, entao tenho que
voltar duas salas para depositar as moedas"*.

**Verificado nos dados (leitura de `data/zones/*.json`, nada alterado):**

| Zona | Estações |
|---|---|
| `camp` | bank · altar · vat |
| `nest` | bank · altar · vat |
| `district` | seal (pedágio) |
| `district_two` | seal (pedágio) |
| `slow_door` | **vat apenas** |
| `low_quay` | **NENHUMA** — e sua única saída volta para `slow_door` |

Ou seja: **`bank` existe somente nos dois hubs**. Da zona mais profunda (`low_quay`,
beco sem saída) até um banco são pelo menos duas transições de volta — exatamente o
que ele descreveu.

**E o próprio jogo já media isso:** `TELEMETRY quay entries=7 frames=19566 kills=114
deaths=13 banked_after{events=0 amount=0}` — em 7 entradas, 19.566 frames e 114 mortes
de inimigo no quay, **zero eventos de banco depois**. O instrumento registrou o sintoma
que ele sentiu; ninguém tinha lido a linha nesse sentido.

**Leitura do assento:** há duas interpretações legítimas e a escolha é de design, não
minha — (a) é lacuna de conteúdo (falta uma estação, ou um banco portátil/pago), ou
(b) é atrito intencional coerente com a lei "banque ou perca" (`d1`), e o custo de
voltar é o preço. O relato dele mostra que hoje isso lê como **bloqueio**, não como
tensão. Roteio como item de brainstorm; **não toquei em `data/**`** (fronteira do
Recorte A).

## ACHADO 3 — ele MATOU o BOSS 1, solo

`TELEMETRY varekka engaged=1 chants=2 seized=2 slain=1 deaths_while_seized=1` +
`arc breach{fired=2} seal2_breached=1 d2{entered=1 kills=100}` +
`persist banked 12 → 45`, `seals 0 → 2`, `sessions 1 → 2`.

Fato relevante para o item de dificuldade: **o BOSS 1 caiu jogando com um corpo só**,
depois de 11 wipes e 70 lutas. Contrasta com a R2 do ritual ("segue muito dificil
chegar no boss") em co-op. Registro do fato; a leitura é do brainstorm.

## Economia (fato dele, sem contra-prova)

Ele afirma economia melhor jogando com 1 ("sem gastar moedas"). A telemetria mostra
`sustain bought=0 used=0 refused=0` (não comprou suprimento nenhum) e
`banked_spent{inscribe=16 tribute=228}`. Não há na sessão um controle com 3 corpos para
comparar — então isto fica como **afirmação dele, não medida**.
