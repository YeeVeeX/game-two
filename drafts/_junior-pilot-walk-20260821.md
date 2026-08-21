# Pilot walk do assento Junior — ZONE 7 / T4 (2026-08-21)

Assento: Junior (pt-br). Duas sessões solo no save SCRATCH `tmp/pilot_walk/world.json`
(seed pela receita do ticket: `ruby -Isrc soak/seed_save.rb tmp/pilot_walk/world.json zone_7 60 3`).
O save vivo `saves/world.json` não foi tocado. Recorte A respeitado: zero código —
este rascunho banca medições e relatos humanos, nada mais.

## O que foi feito

- `git pull --ff-only` → main em `c5c146d` (ship do WB T4). Suíte completa nesta
  máquina: **994 runs, 18694 assertions, 0 failures** (~160 s), incluindo
  `test/tools/pilot_authoring_test.rb` — o pin eol-normalizado **passa no clone
  autocrlf do Windows** (a verificação que só este assento cobre).
- Dev walk humano do pilot T4 em duas sessões: (1) passeio livre, (2) repeat com
  `GAME_FRAME_PROBE=1`.
- Percurso completo: TOWN 1 → BASEMENT 1 → BASEMENT 2 → poço (toll pago, água
  drenada) → DUNGEON 1 → corda de volta.
- Aim v3 (Ctrl+direção) re-testado pelo humano após o pull: **FUNCIONA** — fecha o
  report J-1 ("segue desativado" era build velha, como adjudicado no docket).

## Ear-checks e feel (relato humano do Junior)

- **amb_town OUVIDO ao vivo na TOWN 1** — o gap nomeado do T4 (nenhum bot entrou na
  cidade, `amb_town` nunca exercitado) fecha com ear-check humano **PASS**. As trocas
  meadow→town→dungeon são audíveis e corretas por zona.
- Corda + poço: sensação **"muito boa"** (palavras dele).
- Layout/colisão/visual do poço drenado: nenhum estranhamento reportado.
- **OBSERVAÇÃO para decisão do hub**: `AUDIO ambience key=none` em `basement_1` e
  `basement_2` — os porões não têm ambiência nenhuma. Silêncio de design ou lacuna
  de autoria? Não é fix deste assento; fica a pergunta.

## ACHADO — lentidão geral nesta máquina (gatilho do ticket da cauda de frames)

Relato humano: "não rodou muito legal no meu pc", caracterizado como **lentidão
geral** (não engasgo pontual, não input lag, não restrito a uma área).

Números bancados:

- Sessão 2 (probe):
  `TELEMETRY frame_probe frames=11663 period{p50=16.8 p90=33.4 p99=50.0 max=185.5} update{p50=0.4 p95=1.1 max=62.8} draw{p50=3.9 p95=15.3 max=121.3} over20=1958 over35=316 over100=3`
  - **over20 = 16,8%** dos frames (1958/11663) — bem acima da cauda conhecida de ~7%.
  - update é barato (p95 1,1 ms); **a cauda mora no DRAW** (p95 15,3 ms ≈ o orçamento
    inteiro de 16,7 ms; max 121,3 ms). p90 do período = 33,4 ms = frame dobrado.
- Sessão 1 (sem probe): `AUDIO drift` monotônico, engine_pcm/expected ≈ +7,4% → +8,2%
  (tick 3600→9000). Sessão 2: ≈ +12,2% no tick 10800. O relógio de áudio corrobora o
  probe: os ticks perdem tempo real de forma crescente.
- Contexto: zonas T4 novas (town/água) nesta máquina. A distância para o baseline de
  ~7% sugere custo de draw do conteúdo novo, mas **medir ≠ diagnosticar** — a nomeação
  da causa fica com o hub/ticket.

O ticket da cauda (~7% over20, fechado NO-SHIP-BY-DEFAULT) estava gateado em "os
donos ainda sentirem lag": **o gatilho disparou** — owner Junior sentiu em solo e os
números medidos estão acima do baseline.

## Evidência (logs ficam nesta máquina; só o md5 é bancado — precedente 947441)

- Sessão 1: `game_two_session_1029647.log` — md5 `2c6f586568c6b9d913d5c67557d4979d`
- Sessão 2 (probe): `game_two_session_1032825.log` — md5 `df5779eb8a2074e0a32f511e5a6d8812`
- Saída limpa (Esc) nas duas sessões; `AUDIO teardown clean (dropped_cues=0)`;
  persist do scratch: `sessions=2 banked=75`.

## O que falta / rotas

- Porões sem ambiência → pergunta ao hub (design vs lacuna).
- Cauda de frames → gatilho disparado com números; diagnóstico e qualquer sonda nova
  em código são do hub, não deste assento.
- Coop S1 → este assento segue READY aguardando o invite (sem cobrança).
