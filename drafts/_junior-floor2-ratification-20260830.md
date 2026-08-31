# Junior — ratificação do floor -2 (FIEHONJA jogado) + direção: ambience animada (2026-08-30)

Resposta async à pendência nomeada nos checkpoints s122/s123 ("async
ratification open" do floor -2). Colhida no seat dele pela sessão de
dev; veredito VERBATIM (typos e tudo — lei do projeto). A mensagem
chegou em três rajadas progressivas (recomeços de digitação); o trecho
final completo é o veredito:

> "eu acho que o mapa/jogo precisa e algumas animaçoes em voltar para
> os mapas parecerem mais vivo, no caso desse mapa, o mapa é embaixo
> da agua então tem q pensar que tem q ter elementos e animaçoes em
> volta que façam o player que está jogando setntir que está embaixo
> do mar. e isso tem q ser expandidos para todo os mapa e todo o
> projeto. avaliar o q tu acha. mas agora falando sobre a atual versao
> do mapa, tirando esse detalhe da animação o mapa está muito bem
> feito e encaixado a saido pagando 150 faz sentido estar no meio e os
> respawns estão bem feitos, eu gostei."

## 1. Floor -2 (ZONE 3 / district_two, o v3 FIEHONJA dele) — RATIFICADO

Leitura do dev (interpretação, separada da voz):

- **RATIFIED-J do floor -2: FECHADO — aprovado.** O recorded lean do
  T6b (v3 FIEHONJA como floor -2) fica confirmado pelo autor dos três
  conceitos: "o mapa está muito bem feito e encaixado", "eu gostei".
  Sem pedido de re-transcrição (v1/v2 seguem banked, sem uso).
- **O selo de 150 no meio: aprovado como desenho.** "a saido pagando
  150 faz sentido estar no meio" — dado verificado:
  `district_two.json` station seal em [41,13], `price:
  breach_cost_2` (=150 em `economy.json`), abre [42,13] → slow_door;
  x=41 de 88 = meio horizontal exato do mapa. O mesmo loop de fome de
  banco do floor -1, agora com preço fundo.
- **Respawns: aprovados.** "os respawns estão bem feitos" — fauna do
  T6b (lurker/warden) julgada em jogo pelo peer.
- **Fato honesto:** ele VIU o selo mas não pagou (banked 96 < 150,
  `seal2_breached=0`) — o pedágio segurou, que é o que pedágio faz. O
  floor -3 segue NÃO visitado (quay entries=0); a ratificação do
  MEDUSA LOWER adaptado (T7 §12) continua ABERTA.
- **Totem (T4): não exercitado** nesta sessão (heals=0 pulses=0) —
  nenhum veredito sobre ele ainda.

## 2. Direção de design RECORDED: ambience animada, underwater-first

O pedido dele (peer direction, FULL SEAT SYMMETRY): mapas precisam de
animações/elementos ambientes para parecerem VIVOS; no floor -2 o
tema é estar embaixo d'água — o player tem que SENTIR isso; e a
ambição é expandir para todos os mapas do projeto.

Avaliação do dev (ele pediu: "avaliar o q tu acha") — **CONCORDO, e o
buraco é real**: hoje o renderer só anima entidades; o chão é 100%
estático. Touchstone direto: a água/tochas animadas de Tibia carregam
a atmosfera do jogo inteiro com orçamento de sprite mínimo; princípio
Vlambeer (juice barato, sentível). Duas leis técnicas prendem a
execução:

1. **Tick-driven, nunca wall-clock** — animação ambiente deriva do
   contador de tick do sim (timebase lei do projeto), senão replays e
   capturas quebram o determinismo.
2. **Re-pin nomeado** — overlay animado em zona com script na parede
   muda md5 de frame → manifests afetados re-cortados como CUSTO
   NOMEADO do ticket, não surpresa no sweep.

Classe: **presentation (SAFE)** — "region ambience" já é
comportamento SAFE nomeado no AGENTS.md; zero sim. Não entra no delta
da NINETEENTH (que é sim-class), mas cada pouso é mudança visual →
gate Rule 2 obrigatório. Recomendação de rota: **piloto no floor -2**
(o tema submerso é o puxão mais forte — bolhas subindo, shimmer de
luz, sway) via bloco `ambience` data-driven no JSON da
zona/region-layer; expandir por região depois. Casa com a fila de
áudio já aprovada (stereo ambient stems + region-acoustics, gated em
palavra do owner) — visual e som da mesma região podem pousar juntos.

## Evidência de jogo (log no seat dele, digest md5)

Cópia em `tmp/junior-sessions/` (gitignored; original em `%TEMP%`):

- **Sessão 3** — o play do floor -2 (2026-08-30, build T7):
  `game_two_session_28101.log` md5 `e266afc5e848276c612d33837b0d26c3`.
  TELEMETRY: persist loaded digest=6a7cf5e7… sessions=2 → saved
  digest=a3074000… sessions=3 (saída limpa, cadeia solo dele
  contínua) · banked=96 · d2 entered=1 kills=12 · seal2_breached=0 ·
  quay entries=0 · totem heals=0 pulses=0 · progression level=5
  xp=555 · camp_visits=2 · zero wipes.

Nada de sim/balance tocado; note é docs-only. Próximos passos que
este note alimenta: (a) hub cola o RATIFIED-J do floor -2 onde a
foundation espera; (b) a direção de ambience vira spark/ticket de
presentation com as duas leis acima (peer direction recorded — falta
o concur do Gabriel para virar lane); (c) a ratificação do floor -3
segue aberta — próximo play dele precisa de banked ≥ 150 para o
pedágio do meio.
