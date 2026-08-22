# Primeira travessia humana do portão T5 — assento Junior (2026-08-21)

Assento: Junior (pt-br), jogando no **SAVE VIVO**. Sessão humana solo, saída
limpa (Esc), cadeia log↔save íntegra. Recorte A respeitado: zero código — este
rascunho banca a colheita da sessão e o depoimento do jogador com as palavras
exatas dele.

## Protocolo

- Repo no tip `61ccfa3` no launch (fetch 0 atrás) · guarda de instância única
  verificada antes do launch · sem `--fresh` · locale pt-br.
- Save vivo: loaded `digest=7b7ee2619a7d5d51c6ef1b86e4d2c62a sessions=3` →
  saved `digest=e94e2dd9823cfa157c8402c1be66bf74 sessions=4` (banked 103→141,
  provisions 1→0, seals 2→3). Arquivo pós-sessão md5
  `cf15a21903e03891f2b14ee2e22e94e9`.
- A validação de edges do boot (`3c4b988`) carregou o mundo limpo.

## O FATO: o portão foi cruzado

O log banca a primeira travessia humana da aresta T5 no mundo vivo:
`AUDIO ambience key=amb_town zone=zone_7` (×3) numa sessão do save vivo — a
laje aberta pela vitória earned (`boss_1_defeats: 1`) foi atravessada por
low_quay, e o jogador andou a TOWN 1.

Observação para o hub classificar: a sessão viva também registra
`AUDIO ambience zone=basement_1` (×1) e `zone=dungeon_1` (×1) — o subgrafo T4
(poço/porões/dungeon) ficou ALCANÇÁVEL no mundo vivo através da zone_7. Se o
esperado pós-T5 era só a cidade, isto é um delta a nomear; se D12-completo
implica o subgrafo inteiro, está conforme.

## Depoimento do Junior (palavras exatas)

Sobre o momento da travessia:

> "me senti em uma nova fase e com meu objetivo concluido"

Sobre a luta com o BOSS 1 (challenger):

> "eu sinto que a skill do chefão nao tem como desviar e pega por todo mapa
> dele. a luta foi bem tranquila o chefe me parece morrer com poucos hit, o
> squad morre pq corre para cima dos inimigos"

Sobre o retorno pelo portão (spawn a 4 tiles do challenger):

> "na verdade um pouco tenso mas na batalho foi de boa porque os minions não
> atacao entao virou uma luta de 1x1"

Sobre o mapa novo (TOWN 1):

> "duas salas vazias no novo mapa e não ter o quadrado de reviver seu squad e
> o outro de por nivel"

## Telemetria da sessão (linhas verbatim)

    TELEMETRY varekka engaged=1 chants=1 interrupted=0 seized=1 swap_escapes=0 slain=1 deaths_while_seized=0 burns=0 ends{expired=1 slain=0 died=0 zone_left=0 wiped=0}
    TELEMETRY quay entries=4 frames=9582 kills=63 deaths=8 banked_after{events=1 amount=133}
    TELEMETRY d1_fired carrying_deaths=2 wipes=1 corpse_looted=0 carried_lost=2 banked_events=2 fights=13 recovery_fights=0 negative_fights=2
    TELEMETRY a2_fired wipes=1 body_deaths=13 retargets{hate=38 lowhp=78 proximity=12 acquired=246 challenged=47} leashes=99 deepest_band=2 banked=2
    TELEMETRY arc breach{fired=1 first_frame=27197 banked_after=141} rehomed=1 camp_visits=3 d2{entered=1 kills=67} seal2_breached=0
    TELEMETRY v14 telegraphs_shown=102 first_special{striker=never blocker=3604 lobber=never}

(Demais linhas TELEMETRY no log bancado; nada omitido do arquivo.)

## Cruzamento depoimento × telemetria (leitura deste assento, sem diagnóstico)

- "chefe morre com poucos hit" ↔ `varekka slain=1`, canto expirado sem
  interrupção (`chants=1 interrupted=0 ends{expired=1}`) — o BOSS 1 foi morto
  nesta sessão. Junto com "a skill não tem como desviar e pega por todo mapa" e
  "os minions não atacam (1x1)", é insumo direto para a iteração de dread do
  BOSS-1 (docket: OPEN-FOR-EXPOSURE — esta é a exposição orgânica que se
  esperava; perguntas do ritual respondem-se com o bloco acima).
- "o squad morre pq corre para cima" ↔ `body_deaths=13 leashes=99
  retargets{acquired=246}` — reforça o finding A já bancado (aquisição de aggro
  da IA aliada por kit), agora com dados de uma sessão com wipe.
- Retorno a 4 tiles do challenger: "um pouco tenso mas foi de boa" — feedback
  pedido pela s30; o tile é dado em data se os owners quiserem ajustar.
- TOWN 1 sem estações ("quadrado de reviver" / "de por nivel") + duas salas
  vazias — rima com o finding B (banco nas zonas profundas); design v0 ou
  lacuna de conteúdo, decisão dos owners (v19).
- `first_special{striker=never}` DE NOVO — linha de watch do PARKING_LOT
  (whirlwind feel gap) ganha mais um ponto de dado.

## Evidência (log nesta máquina; md5 bancado — precedente 947441)

- `game_two_session_1419143.log` — md5 `562b5af706a0cec613e43a3de6691fe6`
- Save vivo pós-sessão — md5 `cf15a21903e03891f2b14ee2e22e94e9`

## Addendum — hipótese do Junior sobre a IA aliada, CONFIRMADA em leitura

Depois do bank acima, o Junior formulou (palavras exatas):

> "o q me parece é q as IA de aliados e inimigos é a mesma, então eles fazem
> as mesmas coisas quando veem inimigos"

Verificação read-only (Recorte A, nada alterado): **confirmado.**

- `src/game/controllers.rb:100` — um único `AiController` serve todas as
  facções; o comentário de cabeçalho (`:96-99`) declara "Husk-grade brain
  (deliberately dumb — gambits are A1)": aggro no hostil mais próximo, chase
  no flow field, swing em alcance de kit; aliados apenas ADICIONAM o follow
  do possessed quando sem alvo.
- `controllers.rb:106-135` — a cadeia de seleção de alvo (taunt → anchor →
  kit-hate → lowhp → sticky/proximity → nearest) é compartilhada; `:114` e
  `:162` usam o MESMO `creature.kit[:aggro_tiles]` para aliado e inimigo.
- Diferenças de aliado são só o follow (`:164-167`) e o flee seat-gated do
  terceiro corpo (`:154-158`, v18 D12).

Leitura deste assento: a hipótese do jogador descreve com precisão o design
v0 deliberado — e aponta para a lane R-A3 (IA do terceiro corpo), CONGELADA
até o brainstorm v19 por decisão ratificada. Insumo bancado para lá; zero
código devido agora.

## Rotas

- Colheita varekka/dread + primeira travessia → hub (J-lanes de harvest).
- Achados de design (estações da town, salas vazias, IA aliada, skill do boss,
  minions passivos no 1x1) → brainstorm v19, decisão conjunta dos owners.
- Subgrafo T4 alcançável no vivo → hub classificar (esperado vs delta).
- Coop S1 → este assento segue READY (agora com o portão já estreado).
