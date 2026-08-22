# Re-medição do assento Junior — J1 frame-tail fix `dd8ff40` (2026-08-21)

Assento: Junior (pt-br) — **o assento decisivo do gatilho J1** (ticket
`drafts/_wb-t5-wirein-20260821.md` §Junior re-measure). Recorte A respeitado:
zero código; este rascunho banca a re-medição pedida no recado pt-br do ticket.

## Protocolo cumprido

- `git pull --ff-only` ANTES de tudo → main em `1850676` (inclui `dd8ff40` J1
  render fix + `371aedd` T5 + `3c4b988` edge validation).
- Suíte completa neste clone autocrlf: **1004 runs, 18760 assertions, 0 failures**.
- **Mesma rota T4 do probe original** (exigência do protocolo de adjudicação):
  TOWN 1 → BASEMENT 1/2 → poço → DUNGEON 1 → corda de volta, no MESMO save
  scratch `tmp/pilot_walk/world.json` (o save vivo não se moveu).
- Medição limpa: a suíte terminou ANTES do launch (CPU ociosa durante o probe).
- Higiene de probe (lição da s28 aplicada): logs before/after preservados em
  arquivos DISTINTOS — nada sobrescrito.

## Números — antes (f60d51e bank) vs agora

| Métrica | Antes (pré-fix) | Previsto (ticket) | **Agora (pós-fix)** |
|---|---|---|---|
| `draw` p95 | 15,3 ms | ~8–9 ms | **8,5 ms** |
| `over20` | 16,8% (1958/11663) | rumo a ~7% ou abaixo | **5,15%** (744/14441) |
| período p90 | 33,4 ms | — | **17,5 ms** |
| `draw` p50 | 3,9 ms | — | **2,6 ms** |
| AUDIO drift (fim de run) | +12,2% | — | **+5,2%** |

Linha verbatim (pós-fix):

    TELEMETRY frame_probe frames=14441 period{p50=16.8 p90=17.5 p99=42.4 max=1469.6} update{p50=0.5 p95=2.1 max=121.9} draw{p50=2.6 p95=8.5 max=473.0} over20=744 over35=223 over100=9

Baseline verbatim (pré-fix, do bank `f60d51e`):

    TELEMETRY frame_probe frames=11663 period{p50=16.8 p90=33.4 p99=50.0 max=185.5} update{p50=0.4 p95=1.1 max=62.8} draw{p50=3.9 p95=15.3 max=121.3} over20=1958 over35=316 over100=3

## Veredito humano

O Junior jogou a rodada e classificou: **"muito mais leve"** — a lentidão geral
que disparou o gatilho não foi sentida.

## Classificação pela régua pré-declarada

Os dois critérios do ticket batem: draw p95 **8,5 ms** (dentro da janela ~8–9 ms
prevista) e over20 **5,15%** (ABAIXO do baseline de ~7% do mundo antigo), com o
feel humano confirmando. Pelos números e pela régua, esta re-medição aponta
**FECHA** — a adjudicação formal é da sessão do hub (J4), com os números deste
assento mandando.

## Ressalvas honestas (anotadas, não diagnosticadas)

- **over100 subiu 3 → 9**, com max período 1469,6 ms e draw max 473 ms — picos
  isolados (suspeita: cargas de zona/foco de janela; a rota desta rodada incluiu
  mais transições, inclusive low_quay). NÃO é a cauda contínua — o p90/p95
  contam a história do fix.
- update p95 1,1 → 2,1 ms — ruído, segue barato.
- Drift de áudio ainda positivo (+5,2%), consistente com os ~5% de over20
  residuais.

## Bônus da rodada

- **A aresta do T5 foi cruzada em jogo humano**: zone_7 → low_quay pela direção
  livre (scratch; `AUDIO ambience key=none zone=low_quay` ×2 no log). O edge
  funciona em play; a validação de boot (`3c4b988`) carregou o mundo limpo.
- Recebido: silêncio dos porões = **design v0** (docket) — pergunta do bank
  anterior respondida, sem pendência.

## Evidência (logs nesta máquina; md5 bancados — precedente 947441)

Preservados em `/tmp/junior_remeasure_evidence/` (nomes distintos, higiene s28):

- `before_fix_probe.log` — md5 `df5779eb8a2074e0a32f511e5a6d8812` (o bank de `f60d51e`)
- `before_fix_freewalk.log` — md5 `2c6f586568c6b9d913d5c67557d4979d`
- `after_fix_probe.log` — md5 `2675cd55e09aa39c1af84a0438948fa1`
  (original: `game_two_session_1415572.log`)

Saída limpa (Esc); persist scratch `sessions=3 banked=131`.

## Rotas

- Adjudicação J4 → hub (números deste assento entregues; classe sugerida FECHA).
- Coop S1 → este assento segue READY em `1850676` (mesmo tip, protocolo v3 ok).
- Primeira travessia do portão no SAVE VIVO (low_quay → zone_7 pela laje aberta)
  segue disponível — este assento se candidata na próxima sessão de jogo.
