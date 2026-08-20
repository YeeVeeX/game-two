# Junior — sessão 2 do ritual COMPLETA (joiner) — a corrente encaixou

**Data:** 2026-08-20, fim 02:11:22 · **Assento:** Junior (seat=2, joiner)
**Build:** `b6724ec` (pull antes de entrar) · **Log:**
`drafts/_v18-seventeenth-evidence/game_two_session_63472464.log`
(3642 B, md5 `8931b524183792964213afdf65c18792`; original em `%TEMP%` desta máquina)

## Linhas do oráculo (verbatim)

```
AUDIO on: device=1 sha=15f03e0219d6 lib=C:/Users/jr/Desktop/projeto-game-two/game-two-audio
TELEMETRY persist loaded digest=3a518bccf2b324f9fb1211ed2f7529f0 schema=1 banked=5 provisions=0 seals=2 marks=0 sessions=9 source=handshake
TELEMETRY sustain bought=0 used=0 refused=1
TELEMETRY netplay seat=2 ticks=36079 desyncs=0 stalls=268 stall_ms_max=843 reason=quit
AUDIO teardown clean (dropped_cues=0)
```

## Fatos mecânicos (registro; a adjudicação é do harvest)

- **CONTINUIDADE PROVADA do lado do joiner:** o `loaded` desta sessão é
  `3a518bcc…` sessions=9 — **exatamente o digest que a sessão 1 GRAVOU**
  (host s1: loaded `66784a92`/s8 → saved `3a518bcc`/s9, bancado em `2503f3a`).
  A sessão 2 entrou no mundo que a sessão 1 deixou, não em mundo novo.
- **Saída limpa** (`reason=quit`), **desyncs=0**, **ticks=36079** (≥36000 ✓).
- **AUDIO ON** de novo (device=1, sha do vendor) — ramo de novidade simétrica
  mantido nas DUAS sessões; teardown limpo, `dropped_cues=0`.
- **Sustain: `refused=1`** (mudou em relação à sessão 1, que foi 0/0/0) — houve
  UMA tentativa recusada, nenhuma compra, nenhum uso. Fato bruto; o roteamento
  (discoverability vs preço vs contexto) é do harvest, não deste draft.
- Stalls 268, pior 843 ms — o jogo esperou, nunca dessincronizou.
- Drift de áudio: `4043520` frames no tick 36000 (~112 fr/tick, mesma classe
  linear do débito já atribuído ao assento de áudio). Sink puro, sim intocada.

## Estado do ritual (contagem, não veredito)

- **DUAS sessões coop válidas deste assento**, ambas com saída limpa, desyncs=0,
  ticks ≥36000, e a segunda carregando o save da primeira → os quatro checks
  mecânicos da Half A têm a evidência do lado do joiner completa (a verificação
  formal, incluindo os pares host-side, é do dev of record).
- **Respostas: 0/8.** Quarentena de priming MANTIDA: o agente não perguntou,
  não sugeriu e não comentou nada das perguntas do ritual em nenhuma das duas
  sessões. As perguntas são do dono; as respostas do Junior são dele.
- Nada foi consertado nem editado durante as partidas.
