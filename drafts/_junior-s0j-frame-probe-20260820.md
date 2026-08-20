# S0-J EXECUTADO — o segmento decisivo do T2, e a predição BATEU

**Data:** 2026-08-20 18:56 (fim da sessão) · **Assento:** Junior, **solo**, `GAME_FRAME_PROBE=1`
**Guardas cumpridas:** instância única verificada em chamada separada (nenhum `ruby.exe`
antes do launch) · sem `--fresh` · build `34bec50` == `origin/main` no momento do launch.
**Log:** `%TEMP%\game_two_session_836781.log` (8030 B, nesta máquina).

## A linha, verbatim

```
TELEMETRY frame_probe frames=127506 period{p50=16.8 p90=17.5 p99=42.8 max=1335.1}
  update{p50=0.8 p95=3.4 max=160.7} draw{p50=3.1 p95=7.1 max=355.3}
  over20=8643 over35=2012 over100=72
```

## Confronto com a predição pré-registrada

O runsheet (`_lag-probe-runsheet-20260820.md` §S0-J2, commit `638fa68`) pré-registrou,
a partir dos fatos de hardware que este assento bancou: **"period p50 ≈ 16.9 ms (59 Hz)
com um pico ~33.9 ms"**.

| Predição | Medido | Veredito |
|---|---|---|
| p50 ≈ 16,9 ms (teto de 59 Hz) | **p50 = 16,8 ms** | **BATEU** (59 Hz → 16,95 ms; erro 0,15 ms) |
| cauda em ~33,9 ms (quadro perdido = 2 × vsync) | p99 = 42,8 · **over35 = 2012** | BATEU em forma |

**A hipótese do teto de vsync está confirmada por medição.** Não é suspeita: p50 grudado
em 16,8 ms num monitor de 59 Hz é o vsync, não carga.

## O que a decomposição diz (leitura do assento, marcada como leitura)

- **A máquina NÃO está saturada no caso mediano.** `update p50 = 0,8 ms` (a sim é
  barata, como o `rake perf` sempre disse) e `draw p50 = 3,1 ms`. Soma ≈ **3,9 ms de
  trabalho num período de 16,8 ms** → o laço passa ~77% do tempo **ocioso, esperando o
  vsync**. Ou seja: o teto é o monitor, não o i3/HD3000 no dia a dia.
- **O que derruba a MÉDIA para ~53,5 Hz é a CAUDA, não o p50.** `over20 = 8643` de
  127506 quadros = **6,8%** dos quadros passam de 20 ms; `over35 = 2012` (1,6%);
  `over100 = 72`. Média puxada por 6,8% de quadros longos é exatamente como 59,5
  vira ~53,5.
- **Os travões de segundos existem e estão medidos:** `period max = 1335,1 ms` (1,3 s
  num quadro), `draw max = 355,3 ms`, `update max = 160,7 ms`. Isso corrobora a forense
  do host (picos de 0,8–3,3 s) **do lado do cliente**, e mostra que o pico nasce
  dentro do processo (draw/update), não só na rede.
- **Refino honesto da minha própria leitura de ontem:** eu escrevi que ~53,5 Hz era
  "91% de um teto de 59 Hz". A medição mostra algo mais preciso: **o teto é 59 Hz E a
  perda vem de uma cauda de 6,8%**. Duas causas somadas, não uma.

## Consequência para o lockstep (fato, não veredito)

Em lockstep o assento mais lento dita o passo: um teto de 59 Hz já impõe ~1,7% de
atraso estrutural sobre 60, e a cauda de 6,8% adiciona esperas do outro lado. Nenhum
ajuste de rede muda isso — coerente com a medição de rede desta madrugada, que mostrou
esta ponta como a boa (NAT fácil, UPnP, IP público, rota direta).

## Confundidor, repetido para não se perder

Os ajustes de rede/energia desta máquina foram feitos **depois** das sessões do ritual
(porta UDP fixa, firewall, Wi-Fi em desempenho máximo, USB sem suspensão). Reversão:
`net-tune-revert.ps1`. Não afetam CPU/GPU/refresh, mas a comparação com os números do
ritual não é de máquina idêntica.

## O que esta sessão NÃO é

Não é evidência de ritual (o v18 já fechou CUMPLIDO) e não foi conduzida como tal: é
o segmento S0-J do T2, medição pura. Foi jogo solo — mexeu no mundo SOLO do Junior
(`persist loaded 653f4231…` sessions=1 → `saved 1196b8e4…` sessions=2), nunca no save
de custódia do host.
